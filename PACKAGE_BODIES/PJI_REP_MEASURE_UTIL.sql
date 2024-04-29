--------------------------------------------------------
--  DDL for Package Body PJI_REP_MEASURE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_REP_MEASURE_UTIL" AS
/* $Header: PJIRX15B.pls 120.25.12010000.10 2010/04/01 04:22:59 arbandyo ship $ */

/**
 ** constants for logging
 **/
g_msg_level_highest_detail    NUMBER;
g_msg_level_normal_flow       NUMBER;
g_msg_level_data_bug          NUMBER;
g_msg_level_data_corruption   NUMBER;
g_msg_level_runtime_info      NUMBER;
g_msg_level_proc_call         NUMBER;
g_msg_level_low_detail        NUMBER;
g_msg_level_lowest_detail     NUMBER;
g_debug_mode VARCHAR2(1) := NVL(Fnd_Profile.value('PA_DEBUG_MODE'),'N');

/**
 ** measure types
 **/
g_CurrencyType                VARCHAR2(10);
g_PercentType                 VARCHAR2(10);
g_HoursType                   VARCHAR2(10);
g_IndexType                   VARCHAR2(10);
g_OtherType                  VARCHAR2(10);
g_DaysType					  VARCHAR2(10);

/**
 ** Constants for the number of decimal places to use for the different types
 **/
g_CurrencyDecimalPlaces       NUMBER; -- number of decimal places for Currency measures
g_HoursDecimalPlaces          NUMBER; -- number of decimal places for effort measures
g_PercentDecimalPlaces        NUMBER; -- number of decimal places for percentage measures
g_IndexDecimalPlaces          NUMBER; -- number of decimal places for index measures
g_currency_size               NUMBER; -- maximum size of the currency measures strings

/**
 ** plan type constants for understanding which plan types are present in the current plan version
 **/
g_Actual_is_present           NUMBER;
g_CstFcst_is_present          NUMBER;
g_CstBudget_is_present        NUMBER;
g_CstBudget2_is_present       NUMBER;
g_RevFcst_is_present          NUMBER;
g_RevBudget_is_present        NUMBER;
g_RevBudget2_is_present       NUMBER;
g_OrigCstFcst_is_present      NUMBER;
g_OrigCstBudget_is_present    NUMBER;
g_OrigCstBudget2_is_present   NUMBER;
g_OrigRevFcst_is_present      NUMBER;
g_OrigRevBudget_is_present    NUMBER;
g_OrigRevBudget2_is_present   NUMBER;
g_CstPriorfcst_is_present     NUMBER;
g_RevPriorfcst_is_present     NUMBER;
g_Actual_CstBudget            NUMBER;
g_Actual_CstFcst              NUMBER;
g_Actual_CstRevBudget         NUMBER;
g_Actual_RevBudget            NUMBER;
g_Actual_RevFcst			  NUMBER;
g_CstRevBudget                NUMBER;
g_CstRevBudget2               NUMBER;
g_CstRevFcst                  NUMBER;
g_CstBudget_CstFcst           NUMBER;
g_RevBudget_RevFcst           NUMBER;
g_CstRevBudgetFcst            NUMBER;
g_CstOrigCstBudget            NUMBER;
g_CstFcst_OrigCstBudget       NUMBER;
g_CstRevBudgetOrigbudget      NUMBER;
g_RevBudgetOrigbudget         NUMBER;
g_CstRevOrigbudgetFcst        NUMBER;
g_RevBudgetFcst               NUMBER;
g_RevOrigbudgetFcst           NUMBER;
g_RevFcstRevPriorfcst         NUMBER;
g_CstRevFcstPriorfcst         NUMBER;
g_Cst_FcstPriorfcst           NUMBER;
g_CstFcstCstPriorfcst		  NUMBER;
g_ProjList					  VARCHAR2(10):='PROJLIST';
g_Prepare					  VARCHAR2(10):='PREPARE';
g_Exception					  VARCHAR2(10):='EXCEPTION';

PROCEDURE compute_proj_perf_exceptions
(
    p_commit_flag               IN VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
    , x_return_status           OUT NOCOPY VARCHAR2
)

IS

  l_DaysSinceITD                 NUMBER;
  l_DaysInPeriod                 NUMBER;
  i                              NUMBER;
  l_WBS_Version_ID               NUMBER;
  l_WBS_Element_Id               NUMBER;
  l_RBS_Version_ID               NUMBER;
  l_RBS_Element_Id               NUMBER;
  l_calendar_id                  NUMBER;
  l_report_date_julian           NUMBER ;
  l_period_name                  VARCHAR2(255);
  l_actual_version_id            NUMBER;
  l_cstforecast_version_id       NUMBER;
  l_cstbudget_version_id         NUMBER;
  l_cstbudget2_version_id        NUMBER;
  l_revforecast_version_id       NUMBER;
  l_revbudget_version_id         NUMBER;
  l_revbudget2_version_id        NUMBER;
  l_orig_cstforecast_version_id  NUMBER;
  l_orig_cstbudget_version_id    NUMBER;
  l_orig_cstbudget2_version_id   NUMBER;
  l_orig_revforecast_version_id  NUMBER;
  l_orig_revbudget_version_id    NUMBER;
  l_orig_revbudget2_version_id   NUMBER;
  l_prior_cstforecast_version_id NUMBER;
  l_prior_revforecast_version_id NUMBER;
  l_actual_plantype_id           NUMBER;
  l_cstforecast_plantype_id      NUMBER;
  l_cstbudget_plantype_id        NUMBER;
  l_cstbudget2_plantype_id       NUMBER;
  l_revforecast_plantype_id      NUMBER;
  l_revbudget_plantype_id        NUMBER;
  l_revbudget2_plantype_id       NUMBER;
  l_currency_record_type         NUMBER;
  l_Currency_Code                VARCHAR2(255);
  l_factor_by                    NUMBER;
  l_effort_uom                   NUMBER;
  l_time_slice                   NUMBER;
  l_prg_rollup                   VARCHAR2(1);
  l_report_type                  VARCHAR2(255);
  l_sql_errm                     VARCHAR2(255);
  l_org_id                       NUMBER;
  l_currency_type_msg_name       VARCHAR2(255);
  l_Return_Status                VARCHAR2(255);
  l_Msg_Count                    NUMBER;
  l_Msg_Data                     VARCHAR2(255);
  l_measure_set_codes_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
  l_xtd_types_tbl                SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
  l_measure_set_types            SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
  l_ptd_values                   SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_qtd_values                   SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ytd_values                   SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_itd_values                   SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ac_values                    SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_prp_values                   SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ptd_html                     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  l_qtd_html                     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  l_ytd_html                     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  l_itd_html                     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  l_ac_html                      SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  l_prp_html                     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;

  l_project_ids_tbl              SYSTEM.PA_NUM_TBL_TYPE;
  l_calendar_type_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
  l_currency_type_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
  l_rowids_tbl                   SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  l_measure_ids_tbl              SYSTEM.PA_NUM_TBL_TYPE;
  l_measure_values_tbl           SYSTEM.PA_NUM_TBL_TYPE;

  l_ptd_trans_id	     		 SYSTEM.PA_NUM_TBL_TYPE;
  l_ytd_trans_id	     		 SYSTEM.PA_NUM_TBL_TYPE;
  l_qtd_trans_id	     		 SYSTEM.PA_NUM_TBL_TYPE;
  l_itd_trans_id	     		 SYSTEM.PA_NUM_TBL_TYPE;
  l_ac_trans_id	     	 		 SYSTEM.PA_NUM_TBL_TYPE;
  l_prp_trans_id	     		 SYSTEM.PA_NUM_TBL_TYPE;

  l_ptd_meaning      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ytd_meaning      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_qtd_meaning      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_itd_meaning      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ac_meaning       SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_prp_meaning      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;


  l_exception_indicator_tbl		 SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  l_plan_version_ids	     	 SYSTEM.PA_NUM_TBL_TYPE;
  l_i NUMBER;
  x NUMBER;

  l_slice_name VARCHAR2(30);

BEGIN

	NULL;

  IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG(
	    'PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions: beginning execution....',
	    TRUE, g_msg_level_proc_call
	  );
  END IF;
  l_msg_count     := 0;
  l_return_status := Fnd_Api.G_RET_STS_SUCCESS;


  --BEGIN
  --  DELETE PA_PERF_TEMP_OBJ_MEASURE_debug;
  --  INSERT INTO PA_PERF_TEMP_OBJ_MEASURE_debug SELECT * FROM PA_PERF_TEMP_OBJ_MEASURE;
  --  COMMIT;
  --END;


  --
  -- derive distinct combinations of {project_id, calendar_type, currency_type}:
  -- each of these "combinations" will result in a distinct call to retrieveData
  --
  BEGIN
    SELECT DISTINCT
      excp.object_id project_id
    , excp.calendar_type
    , excp.currency_type
    BULK COLLECT INTO
      l_project_ids_tbl
    , l_calendar_type_tbl
    , l_currency_type_tbl
    FROM
      pa_perf_temp_obj_measure excp
    WHERE 1=1
    AND excp.object_type = 'PA_PROJECTS';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN;
    WHEN OTHERS THEN
      NULL;
  END;

  IF l_project_ids_tbl.COUNT < 1 THEN
      RETURN;
  END IF;

  IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG(
	    'PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions: l_project_ids_tbl.LAST ' ||
	    '(collected from table PA_PERF_TEMP_OBJ_MEASURE) = ' || l_project_ids_tbl.LAST,
	    TRUE, g_msg_level_runtime_info
	  );
  END IF;


  --x := l_project_ids_tbl.LAST;
  --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions', 'l_project_ids_tbl.LAST='||TO_CHAR(x),SYSDATE);



  --
  -- for every project/cal/currency combination, find the related measures
  -- and compute its excp
  --
  FOR i IN 1..l_project_ids_tbl.LAST LOOP

    --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions', 'i='||i||', project_id= '||TO_CHAR(l_project_ids_tbl(i)),SYSDATE);
    --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions', 'i='||i||', calendar_type= '||l_calendar_type_tbl(i),SYSDATE);
    --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions', 'i='||i||', currency type= '||l_currency_type_tbl(i),SYSDATE);


    --
    -- first obtain the measures and the measures_sets that we'll compute in
    -- this loop iteration: the l_measure_set_codes_tbl collection will be
    -- passed in to retrieveData. We'll need the xtd_type after retrieveData
    -- to properly fill l_measure_values_tbl with the right timeslice value,
    -- since retrieveData() retrieves the values of each input measure set
    -- for all available timeslices. We'll use the rowid to efficiently
    -- update the table with the row-related measure values and period_name.
    --
	-- Ning add order by , so that we can easility build the measure_set_code with measure_code
	-- Array in retrieveData. Fix for performance bug 3999480
    BEGIN
      SELECT
        ROWIDTOCHAR(excp.ROWID)
      , excp.measure_id
      , msrs.measure_set_code
      , msrs.xtd_type
      , NULL
      BULK COLLECT INTO
        l_rowids_tbl
      , l_measure_ids_tbl
      , l_measure_set_codes_tbl
      , l_xtd_types_tbl
      , l_measure_values_tbl --will contain the values for the requested measures
      FROM
        pa_perf_temp_obj_measure excp
      , pji_mt_measures_b msrs
      WHERE 1=1
      AND excp.object_type = 'PA_PROJECTS'
      AND msrs.measure_id  = excp.measure_id
      AND excp.object_id     = l_project_ids_tbl(i)
      AND excp.calendar_type = l_calendar_type_tbl(i)
      AND excp.currency_type = l_currency_type_tbl(i)
	  ORDER BY msrs.measure_set_code;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;



    --x:= l_measure_set_codes_tbl.LAST;
    --INSERT INTO pji_rep_debug_msg VALUES('i='||i,'l_measure_set_codes_tbl.LAST = ' || x,SYSDATE);



    -- if no measures exceptions are found for the current project, will do nothing
    IF l_measure_set_codes_tbl.LAST > 0 THEN


	  Pji_Rep_Util.Derive_Pa_Calendar_Info(p_project_id =>l_project_ids_tbl(i)
	  , p_calendar_type => l_calendar_type_tbl(i)
	  , x_calendar_id => l_calendar_id
	  , x_report_date_julian => l_report_date_julian
	  , x_period_name => l_period_name
	  , x_slice_name => l_slice_name
	  , x_return_status => x_return_status
	  , x_msg_count => x_msg_count
	  , x_msg_data => x_msg_data
	  );


      --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions', 'i='||i||', l_calendar_id = ' || TO_CHAR(l_calendar_id),SYSDATE);
      --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions', 'i='||i||', l_org_id = ' || TO_CHAR(l_org_id),SYSDATE);
      --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions', 'i='||i||', l_period_name = ' || l_period_name,SYSDATE);
      --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions', 'i='||i||', l_report_date_julian = ' || l_report_date_julian,SYSDATE);



      --
      -- deriving currency_type, currency_record_type, currency_code
      --

      IF l_currency_type_tbl(i)    = 'G' THEN
        l_currency_type_msg_name := 'PJI_REP_GLOBAL_CURRENCY';
        l_currency_record_type   := 1;
        l_Currency_Code          := Pji_Utils.get_global_primary_currency;
      ELSIF l_currency_type_tbl(i) = 'G2' THEN
        l_currency_type_msg_name := 'PJI_REP_GLOBAL2_CURRENCY';
        l_currency_record_type   := 2;
        l_Currency_Code          := Pji_Utils.get_global_secondary_currency;
      ELSIF l_currency_type_tbl(i) = 'F' THEN
        l_currency_type_msg_name := 'PJI_REP_PROJ_FUNC_CURRENCY';
        l_currency_record_type   := 4;
        BEGIN
          SELECT projfunc_currency_code
          INTO  l_Currency_Code
          FROM  pa_projects_all
          WHERE project_id = l_project_ids_tbl(i);
        EXCEPTION
          WHEN OTHERS THEN
            l_Currency_Code := NULL;
        END;
      ELSIF l_currency_type_tbl(i) = 'P' THEN
        l_currency_type_msg_name := 'PJI_REP_PROJ_CURRENCY';
        l_currency_record_type   := 8;
        BEGIN
          SELECT project_currency_code
          INTO  l_Currency_Code
          FROM  pa_projects_all
          WHERE project_id = l_project_ids_tbl(i);
        EXCEPTION
          WHEN OTHERS THEN
            l_Currency_Code := NULL;
        END;
      END IF;


      --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions', 'i='||i||', l_currency_type_msg_name = ' || l_currency_type_msg_name,SYSDATE);


      --
      -- derive other default values parameters except calendar_type
      -- and currency_type
      --

      Pji_Rep_Util.Derive_Default_Plan_Versions(l_project_ids_tbl(i)
          , l_actual_version_id
          , l_cstforecast_version_id
          , l_cstbudget_version_id
          , l_cstbudget2_version_id
          , l_revforecast_version_id
          , l_revbudget_version_id
          , l_revbudget2_version_id
          , l_orig_cstforecast_version_id
          , l_orig_cstbudget_version_id
          , l_orig_cstbudget2_version_id
          , l_orig_revforecast_version_id
          , l_orig_revbudget_version_id
          , l_orig_revbudget2_version_id
          , l_prior_cstforecast_version_id
          , l_prior_revforecast_version_id
          , l_return_status, l_msg_count, l_msg_data);

	  --bug 4355820, only compute project amount for exception generation
      l_prg_rollup := 'N';--Pji_Rep_Util.Derive_Prg_Rollup_Flag(l_project_ids_tbl(i));



	l_plan_version_ids := SYSTEM.PA_NUM_TBL_TYPE(
       l_actual_version_id
      , l_cstforecast_version_id
      , l_cstbudget_version_id
      , l_cstbudget2_version_id
      , l_revforecast_version_id
      , l_revbudget_version_id
      , l_revbudget2_version_id
      , l_orig_cstbudget_version_id
      , l_orig_cstbudget2_version_id
      , l_orig_revbudget_version_id
      , l_orig_revbudget2_version_id
      , l_prior_cstforecast_version_id
      , l_prior_revforecast_version_id);

		l_i := 1;
		WHILE l_i <= l_plan_version_ids.COUNT AND l_wbs_version_id IS NULL LOOP
			IF l_plan_version_ids(l_i) IS NOT NULL THEN
		      Pji_Rep_Util.Derive_Default_WBS_Parameters(l_project_ids_tbl(i)
		          , l_plan_version_ids(l_i)
		          , l_WBS_Version_ID, l_WBS_Element_Id
		          , l_return_status, l_msg_count, l_msg_data);
			END IF;
		  l_i := l_i+1;
		END LOOP;



      l_Factor_By := Pji_Rep_Util.Derive_Factorby(l_project_ids_tbl(i),
                       l_cstbudget_version_id, l_return_status, l_msg_count, l_Msg_Data);
      l_Effort_UOM := Pji_Rep_Util.get_effort_uom(l_project_ids_tbl(i));

      l_time_slice  := 1376;
      l_report_type := 'TS';  -- prfTaskResFlag

      -- derive plan types
      get_plan_type_info( l_project_ids_tbl(i), l_actual_version_id,
          l_cstforecast_version_id, l_cstbudget_version_id, l_cstbudget2_version_id,
          l_revforecast_version_id, l_revbudget_version_id, l_revbudget2_version_id,
          l_orig_cstforecast_version_id, l_orig_cstbudget_version_id, l_orig_cstbudget2_version_id,
          l_orig_revforecast_version_id, l_orig_revbudget_version_id, l_orig_revbudget2_version_id,
          l_actual_plantype_id,
          l_cstforecast_plantype_id, l_cstbudget_plantype_id, l_cstbudget2_plantype_id,
          l_revforecast_plantype_id, l_revbudget_plantype_id, l_revbudget2_plantype_id,
          l_Return_Status, l_Msg_Count, l_Msg_Data);


      --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions',
      --     'i='||i||', l_WBS_Element_Id = ' || TO_CHAR(l_WBS_Element_Id),SYSDATE);
      --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions',
      --     'i='||i||', l_cstbudget_version_id = ' || TO_CHAR(l_cstbudget_version_id),SYSDATE);
      --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions',
      --     'i='||i||', l_cstforecast_version_id = ' || TO_CHAR(l_cstforecast_version_id),SYSDATE);
      --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions',
      --     'i='||i||', l_revbudget_version_id = ' || TO_CHAR(l_revbudget_version_id),SYSDATE);
      --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions',
      --     'i='||i||', l_revforecast_version_id = ' || TO_CHAR(l_revforecast_version_id),SYSDATE);
      --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions',
      --     'i='||i||', l_cstbudget_plantype_id = ' || TO_CHAR(l_cstbudget_plantype_id),SYSDATE);
      --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions',
      --     'i='||i||', l_cstforecast_plantype_id = ' || TO_CHAR(l_cstforecast_plantype_id),SYSDATE);
      --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions',
      --     'i='||i||', l_revbudget_plantype_id = ' || TO_CHAR(l_revbudget_plantype_id),SYSDATE);
      --INSERT INTO pji_rep_debug_msg VALUES('PJI_REP_MEASURE_UTIL.compute_proj_perf_exceptions',
      --     'i='||i||', l_revforecast_plantype_id = ' || TO_CHAR(l_revforecast_plantype_id),SYSDATE);


      -- retrieve data related to the wanted measures sets, using default parameters
      retrieveData(l_project_ids_tbl(i),  l_WBS_Version_Id, l_WBS_Element_Id, -1, -1,
          l_calendar_id, l_calendar_type_tbl(i),  l_report_date_julian,
          l_actual_version_id,
          l_cstforecast_version_id, l_cstbudget_version_id, l_cstbudget2_version_id,
          l_revforecast_version_id, l_revbudget_version_id, l_revbudget2_version_id,
          l_orig_cstforecast_version_id, l_orig_cstbudget_version_id, l_orig_cstbudget2_version_id,
          l_orig_revforecast_version_id, l_orig_revbudget_version_id, l_orig_revbudget2_version_id,
          l_prior_cstforecast_version_id, l_prior_revforecast_version_id,
          l_actual_plantype_id,
          l_cstforecast_plantype_id, l_cstbudget_plantype_id, l_cstbudget2_plantype_id,
          l_revforecast_plantype_id, l_revbudget_plantype_id, l_revbudget2_plantype_id,
          l_currency_record_type, l_Currency_Code, l_factor_by, l_effort_uom,
          l_currency_type_tbl(i), l_time_slice, l_prg_rollup, l_report_type,
		  l_period_name,
          l_measure_set_codes_tbl,
		  'Y', 'Y', 'Y',
		  g_Exception, NULL, l_exception_indicator_tbl,
          -- outputs below
          l_measure_set_types,
          l_ptd_values, l_qtd_values, l_ytd_values, l_itd_values, l_ac_values, l_prp_values,
          l_ptd_html, l_qtd_html, l_ytd_html, l_itd_html, l_ac_html, l_prp_html,
		  l_ptd_trans_id, l_qtd_trans_id, l_ytd_trans_id, l_itd_trans_id, l_ac_trans_id, l_prp_trans_id,
		  l_ptd_meaning, l_qtd_meaning, l_ytd_meaning, l_itd_meaning, l_ac_meaning, l_prp_meaning,
          l_DaysSinceITD, l_DaysInPeriod, l_Return_Status, l_Msg_Count, l_Msg_Data);

		  /* Bug 6914287 changed the order of the trans_id variables to match the procedure definition */

    -- build l_measure_values_tbl
      FOR j IN 1..l_measure_set_codes_tbl.LAST LOOP

	  /* Bug 4213641
	  	 Remove the revert format logic here by Ning, we will handle this in retrieveData,
	  	 if we see the calling type is exception, we will not format it

        IF    l_xtd_types_tbl(j) = 'PTD' THEN
            l_measure_values_tbl(j) := TO_NUMBER(REPLACE(REPLACE(l_ptd_values(j),',',NULL), '%',NULL));
        ELSIF l_xtd_types_tbl(j) = 'QTD' THEN
            l_measure_values_tbl(j) := TO_NUMBER(REPLACE(REPLACE(l_qtd_values(j),',',NULL), '%',NULL));
        ELSIF l_xtd_types_tbl(j) = 'YTD' THEN
            l_measure_values_tbl(j) := TO_NUMBER(REPLACE(REPLACE(l_ytd_values(j),',',NULL), '%',NULL));
        ELSIF l_xtd_types_tbl(j) = 'ITD' THEN
            l_measure_values_tbl(j) := TO_NUMBER(REPLACE(REPLACE(l_itd_values(j),',',NULL), '%',NULL));
        ELSIF l_xtd_types_tbl(j) = 'AC'  THEN
            l_measure_values_tbl(j) := TO_NUMBER(REPLACE(REPLACE(l_ac_values(j), ',',NULL), '%',NULL));
        ELSIF l_xtd_types_tbl(j) = 'PRP' THEN
            l_measure_values_tbl(j) := TO_NUMBER(REPLACE(REPLACE(l_prp_values(j),',',NULL), '%',NULL));
        ELSE
            l_measure_values_tbl(j) := NULL;
        END IF;
*/
        IF    l_xtd_types_tbl(j) = 'PTD' THEN
            l_measure_values_tbl(j) := TO_NUMBER(l_ptd_values(j));
        ELSIF l_xtd_types_tbl(j) = 'QTD' THEN
            l_measure_values_tbl(j) := TO_NUMBER(l_qtd_values(j));
        ELSIF l_xtd_types_tbl(j) = 'YTD' THEN
            l_measure_values_tbl(j) := TO_NUMBER(l_ytd_values(j));
        ELSIF l_xtd_types_tbl(j) = 'ITD' THEN
            l_measure_values_tbl(j) := TO_NUMBER(l_itd_values(j));
        ELSIF l_xtd_types_tbl(j) = 'AC'  THEN
            l_measure_values_tbl(j) := TO_NUMBER(l_ac_values(j));
        ELSIF l_xtd_types_tbl(j) = 'PRP' THEN
            l_measure_values_tbl(j) := TO_NUMBER(l_prp_values(j));
        ELSE
            l_measure_values_tbl(j) := NULL;
        END IF;


      END LOOP;

	  FORALL j IN 1..l_measure_set_codes_tbl.LAST
        UPDATE pa_perf_temp_obj_measure
        SET    measure_value = l_measure_values_tbl(j)
             , period_name   = l_period_name
        WHERE  ROWID = CHARTOROWID(l_rowids_tbl(j));

    END IF;

    -- Initilizing WBS version and WBS element id every time diff project is selected  for bug 4346574
    l_wbs_version_id:=NULL;
    l_wbs_element_id:=NULL;

  END LOOP;

  IF l_msg_count IS NULL OR l_msg_count = 0 THEN
      x_msg_count     := 0;
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  ELSE
      x_msg_count     := l_msg_count;
      x_return_status := l_return_status;
  END IF;

  -- ##########################################################
  --BEGIN
  --INSERT INTO PA_PERF_TEMP_OBJ_MEASURE_debug SELECT * FROM PA_PERF_TEMP_OBJ_MEASURE;
  --COMMIT;
  --END;
  -- ##########################################################

  IF UPPER(p_commit_flag) ='Y' THEN
    COMMIT;
  END IF;

END Compute_Proj_Perf_Exceptions;



FUNCTION Get_Measure_Label(p_measure_code IN VARCHAR2) RETURN VARCHAR2 IS

  l_measure_label VARCHAR2(240);

BEGIN

	SELECT NAME INTO l_measure_label
	FROM pji_mt_measures_vl
	WHERE measure_code = p_measure_code;

  RETURN l_measure_label;

END;



PROCEDURE Get_Measure_Labels
(
  p_measure_codes_tbl IN SYSTEM.PA_VARCHAR2_80_TBL_TYPE
	, p_measure_labels_tbl OUT NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE
	, x_return_status OUT NOCOPY VARCHAR2
	, x_msg_count OUT NOCOPY NUMBER
	, x_msg_data OUT NOCOPY VARCHAR2
) IS

  l_measure_labels_tbl SYSTEM.PA_VARCHAR2_240_TBL_TYPE;
  l_sql_errm VARCHAR2(255);

BEGIN
  l_measure_labels_tbl := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
	--
	-- Check if the array needs processing.
	--
	IF p_measure_codes_tbl.COUNT > 0 THEN
		FOR i IN p_measure_codes_tbl.FIRST..p_measure_codes_tbl.LAST
		LOOP
			--
			-- Extend the array before using it.
			--
			l_measure_labels_tbl.EXTEND;
			--
			-- Fetch the translated name for the measure code.
			--
			BEGIN
				SELECT NAME INTO l_measure_labels_tbl(i)
				FROM pji_mt_measures_vl
				WHERE measure_code = p_measure_codes_tbl(i);
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				x_return_status := Fnd_Api.G_RET_STS_ERROR;
        l_sql_errm := SQLERRM();
        Pji_Rep_Util.Add_Message(
          p_app_short_name=>'PJI',
          p_msg_name=> 'PJI_REP_GENERIC_MSG',
          p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,
          p_token1=>'PROC_NAME',
          p_token1_value=>'PJI_REP_MEASURE_UTIL.Get_Measure_Labels; No Data Found Error: '
                                                                   ||l_sql_errm
        );
			WHEN OTHERS THEN
				x_return_status := Fnd_Api.G_RET_STS_ERROR;
        l_sql_errm := SQLERRM();
        Pji_Rep_Util.Add_Message(
          p_app_short_name=>'PJI',
          p_msg_name=> 'PJI_REP_GENERIC_MSG',
          p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR,
          p_token1=>'PROC_NAME',
          p_token1_value=>'PJI_REP_MEASURE_UTIL.Get_Measure_Labels; SQL Error: '
                                                                   ||l_sql_errm
        );
			END;
		END LOOP;
	END IF;
	p_measure_labels_tbl:=l_measure_labels_tbl;
END Get_Measure_Labels;

PROCEDURE Get_Measure_Attributes
(
  p_measure_codes_tbl          IN SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_measure_set_codes_tbl    OUT NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE
  , x_timeslices_tbl   		OUT NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE
  , x_measure_id_tbl		OUT NOCOPY  SYSTEM.PA_NUM_TBL_TYPE
  , x_return_status              OUT NOCOPY VARCHAR2
  , x_msg_count                  OUT NOCOPY NUMBER
  , x_msg_data                   OUT NOCOPY VARCHAR2 -- not used
)
IS
  l_sql_errm                     VARCHAR2(255);

BEGIN
  IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG('entering get_financial_measures',TRUE, g_msg_level_runtime_info);
  END IF;

	IF x_return_status IS NULL THEN
		x_msg_count := 0;
		x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
	END IF;

  x_measure_set_codes_tbl        := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
  x_timeslices_tbl              := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
  x_measure_id_tbl			:= SYSTEM.PA_NUM_TBL_TYPE();


  x_measure_set_codes_tbl.extend(p_measure_codes_tbl.LAST);
  x_timeslices_tbl.extend(p_measure_codes_tbl.LAST);
  x_measure_id_tbl.extend(p_measure_codes_tbl.LAST);

  FOR i IN 1..p_measure_codes_tbl.LAST  LOOP

    -- alternative strategy for the SQL statement below:
    --   l_measure_set_code(i) := SUBSTR(p_measure_codes_tbl(i), 1, LENGTH(p_measure_codes_tbl(i)));
    --   l_timeslices(i) := SUBSTR(p_measure_codes_tbl(i), -3, 3);
    BEGIN

      SELECT
        measure_set_code
      , xtd_type
	  , measure_id
      INTO
         x_measure_set_codes_tbl(i)
        ,x_timeslices_tbl(i)
		,x_measure_id_tbl(i)
      FROM PJI_MT_MEASURES_B
      WHERE measure_code = p_measure_codes_tbl(i);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
		x_msg_count := x_msg_count + 1;
        Pji_Rep_Util.Add_Message(
          p_app_short_name=> 'PJI',
          p_msg_name=> 'PJI_REP_UNDEFINED_MSR_CODE',
          p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR);
      WHEN TOO_MANY_ROWS THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
		x_msg_count := x_msg_count + 1;
        Pji_Rep_Util.Add_Message(
          p_app_short_name=> 'PJI',
          p_msg_name=> 'PJI_REP_DUPLICATED_MSR_CODE',
          p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR);
      WHEN OTHERS THEN
        x_return_status := Fnd_Api.G_RET_STS_ERROR;
        l_sql_errm := SQLERRM();
		x_msg_count := x_msg_count + 1;
        Pji_Rep_Util.Add_Message(
          p_app_short_name=> 'PJI',
          p_msg_name=> 'PJI_REP_GENERIC_MSG',
          p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING,
          p_token1=>'PROC_NAME',
          p_token1_value=>'PJI_REP_MEASURE_UTIL.Get_Financial_Measures; ' ||
            'SQL Error: ' || l_sql_errm
        );

    END;

  END LOOP;

  IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG('leaving get_measure_attributes',TRUE, g_msg_level_runtime_info);
  END IF;

END Get_Measure_Attributes;

PROCEDURE Get_Financial_Measures
(
  p_project_id                   NUMBER
  , p_measure_codes_tbl          IN SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , p_measure_set_codes_tbl          IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL
  , p_timeslices_tbl   				 IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL
  , p_measure_id_tbl		 		 IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL
  , x_measure_values_tbl         OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_exception_indicator_tbl OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  --, x_exception_labels_tbl       OUT NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE
  , x_return_status              OUT NOCOPY VARCHAR2
  , x_msg_count                  OUT NOCOPY NUMBER
  , x_msg_data                   OUT NOCOPY VARCHAR2 -- not used
)
IS

  l_Return_Status                VARCHAR2(255);
  l_Msg_Count                    NUMBER;
  l_Msg_Data                     VARCHAR2(255);
  l_DaysSinceITD                 NUMBER;
  l_DaysInPeriod                 NUMBER;
  i                              NUMBER;
  l_measure_set_codes_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
  l_timeslices_tbl                   SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
  l_measure_type                 SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
  l_ptd_values                   SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_qtd_values                   SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ytd_values                   SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_itd_values                   SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ac_values                    SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_prp_values                   SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ptd_html                     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  l_qtd_html                     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  l_ytd_html                     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  l_itd_html                     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  l_ac_html                      SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  l_prp_html                     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  l_ptd_trans_id	     		 SYSTEM.PA_NUM_TBL_TYPE;
  l_ytd_trans_id	     		 SYSTEM.PA_NUM_TBL_TYPE;
  l_qtd_trans_id	     		 SYSTEM.PA_NUM_TBL_TYPE;
  l_itd_trans_id	     		 SYSTEM.PA_NUM_TBL_TYPE;
  l_ac_trans_id	     	 		 SYSTEM.PA_NUM_TBL_TYPE;
  l_prp_trans_id	     		 SYSTEM.PA_NUM_TBL_TYPE;
  l_ptd_meaning      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ytd_meaning      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_qtd_meaning      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_itd_meaning      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ac_meaning       SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_prp_meaning      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_WBS_Version_ID               NUMBER;
  l_WBS_Element_Id               NUMBER;
  l_RBS_Version_ID               NUMBER;
  l_RBS_Element_Id               NUMBER;
  l_calendar_id                  NUMBER;
  l_calendar_type                VARCHAR2(1);
  l_report_date_julian           NUMBER ;
  l_period_name                  VARCHAR2(255);
  l_actual_version_id            NUMBER;
  l_cstforecast_version_id       NUMBER;
  l_cstbudget_version_id         NUMBER;
  l_cstbudget2_version_id        NUMBER;
  l_revforecast_version_id       NUMBER;
  l_revbudget_version_id         NUMBER;
  l_revbudget2_version_id        NUMBER;
  l_orig_cstforecast_version_id  NUMBER;
  l_orig_cstbudget_version_id    NUMBER;
  l_orig_cstbudget2_version_id   NUMBER;
  l_orig_revforecast_version_id  NUMBER;
  l_orig_revbudget_version_id    NUMBER;
  l_orig_revbudget2_version_id   NUMBER;
  l_prior_cstforecast_version_id NUMBER;
  l_prior_revforecast_version_id NUMBER;
  l_actual_plantype_id           NUMBER;
  l_cstforecast_plantype_id      NUMBER;
  l_cstbudget_plantype_id        NUMBER;
  l_cstbudget2_plantype_id       NUMBER;
  l_revforecast_plantype_id      NUMBER;
  l_revbudget_plantype_id        NUMBER;
  l_revbudget2_plantype_id       NUMBER;
  l_currency_record_type         NUMBER;
  l_Currency_Code                VARCHAR2(255);
  l_factor_by                    NUMBER;
  l_effort_uom                   NUMBER;
  l_currency_type                VARCHAR2(255);
  l_time_slice                   NUMBER;
  l_prg_rollup                   VARCHAR2(1);
  l_report_type                  VARCHAR2(255);
  l_sql_errm                     VARCHAR2(255);
  l_tmp_measure_code             VARCHAR2(255);
  l_tmp_measure_set_code         VARCHAR2(255);
  l_tmp_xtd_type                 VARCHAR2(255);
  l_effective_i                  NUMBER;
  l_slice_name					 VARCHAR2(80);

  l_plan_version_ids	     	 SYSTEM.PA_NUM_TBL_TYPE;
  l_i NUMBER;

 -- Add by Ning, besides passing the measure_set_code, also pass the measure_ids
  l_measure_id_tbl		 		 SYSTEM.PA_NUM_TBL_TYPE;
BEGIN
	NULL;

  IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG('entering get_measure_attributes',TRUE, g_msg_level_runtime_info);
  END IF;

	x_msg_count := 0;
	x_return_status := Fnd_Api.G_RET_STS_SUCCESS;


  l_measure_set_codes_tbl        := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
  l_timeslices_tbl              := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
  x_measure_values_tbl      := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
  x_exception_indicator_tbl := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
  l_measure_id_tbl			:= SYSTEM.PA_NUM_TBL_TYPE();
  --x_exception_labels_tbl    := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();

  IF p_measure_codes_tbl.LAST < 1 THEN
    x_measure_values_tbl := NULL;
    x_exception_indicator_tbl := NULL;
    RETURN;
  END IF;


  IF p_measure_set_codes_tbl.COUNT>0 THEN     -- Bug 8810949
	  l_measure_set_codes_tbl := p_measure_set_codes_tbl;
	  l_timeslices_tbl := p_timeslices_tbl;
	  l_measure_id_tbl := p_measure_id_tbl;
  ELSE
	  l_measure_set_codes_tbl.extend(p_measure_codes_tbl.LAST);
	  l_timeslices_tbl.extend(p_measure_codes_tbl.LAST);
	  l_measure_id_tbl.extend(p_measure_codes_tbl.LAST);
	  -- obtain measure set name and timeslice (PTD, ITD, AC....) related to the input measures
	  FOR i IN 1..p_measure_codes_tbl.LAST  LOOP

	    -- alternative strategy for the SQL statement below:
	    --   l_measure_set_code(i) := SUBSTR(p_measure_codes_tbl(i), 1, LENGTH(p_measure_codes_tbl(i)));
	    --   l_timeslices(i) := SUBSTR(p_measure_codes_tbl(i), -3, 3);
	    BEGIN

	      SELECT
	        measure_set_code
	      , xtd_type
		  , measure_id
	      INTO
	         l_measure_set_codes_tbl(i)
	        ,l_timeslices_tbl(i)
			,l_measure_id_tbl(i)
	      FROM PJI_MT_MEASURES_B
	      WHERE measure_code = p_measure_codes_tbl(i);

	    EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	        x_return_status := Fnd_Api.G_RET_STS_ERROR;
	        Pji_Rep_Util.Add_Message(
	          p_app_short_name=> 'PJI',
	          p_msg_name=> 'PJI_REP_UNDEFINED_MSR_CODE',
	          p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR);
	      WHEN TOO_MANY_ROWS THEN
	        x_return_status := Fnd_Api.G_RET_STS_ERROR;
	        Pji_Rep_Util.Add_Message(
	          p_app_short_name=> 'PJI',
	          p_msg_name=> 'PJI_REP_DUPLICATED_MSR_CODE',
	          p_msg_type=>Pji_Rep_Util.G_RET_STS_ERROR);
	      WHEN OTHERS THEN
	        l_sql_errm := SQLERRM();
	        Pji_Rep_Util.Add_Message(
	          p_app_short_name=> 'PJI',
	          p_msg_name=> 'PJI_REP_GENERIC_MSG',
	          p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING,
	          p_token1=>'PROC_NAME',
	          p_token1_value=>'PJI_REP_MEASURE_UTIL.Get_Financial_Measures; ' ||
	            'SQL Error: ' || l_sql_errm
	        );

	    END;

	  END LOOP;
  END IF;
  --
  -- derive default values parameters for measure retrieval
  --

  Pji_Rep_Util.Derive_Default_Calendar_Info(p_project_id, l_calendar_type, l_calendar_id,
  l_period_name, l_report_date_julian, l_slice_name
      , l_return_status, l_msg_count, l_msg_data);

  Pji_Rep_Util.Derive_Default_Plan_Versions(p_project_id
      , l_actual_version_id
      , l_cstforecast_version_id
      , l_cstbudget_version_id
      , l_cstbudget2_version_id
      , l_revforecast_version_id
      , l_revbudget_version_id
      , l_revbudget2_version_id
      , l_orig_cstforecast_version_id
      , l_orig_cstbudget_version_id
      , l_orig_cstbudget2_version_id
      , l_orig_revforecast_version_id
      , l_orig_revbudget_version_id
      , l_orig_revbudget2_version_id
      , l_prior_cstforecast_version_id
      , l_prior_revforecast_version_id
      , l_return_status, l_msg_count, l_msg_data);

  Pji_Rep_Util.Derive_Default_Currency_Info(p_project_id
      , l_currency_record_type, l_currency_code, l_currency_type
      , l_return_status, l_msg_count, l_msg_data);

  --bug 4355820, only compute project amount for project list
  l_prg_rollup := 'N'; --Pji_Rep_Util.Derive_Prg_Rollup_Flag(p_project_id);


	l_plan_version_ids := SYSTEM.PA_NUM_TBL_TYPE(
       l_actual_version_id
      , l_cstforecast_version_id
      , l_cstbudget_version_id
      , l_cstbudget2_version_id
      , l_revforecast_version_id
      , l_revbudget_version_id
      , l_revbudget2_version_id
      , l_orig_cstbudget_version_id
      , l_orig_cstbudget2_version_id
      , l_orig_revbudget_version_id
      , l_orig_revbudget2_version_id
      , l_prior_cstforecast_version_id
      , l_prior_revforecast_version_id);

		l_i := 1;
		WHILE l_i <= l_plan_version_ids.COUNT AND l_wbs_version_id IS NULL LOOP
			IF l_plan_version_ids(l_i) IS NOT NULL THEN
		      Pji_Rep_Util.Derive_Default_WBS_Parameters(p_project_id
		          , l_plan_version_ids(l_i)
		          , l_WBS_Version_ID, l_WBS_Element_Id
		          , l_return_status, l_msg_count, l_msg_data);
			END IF;
		  l_i := l_i+1;
		END LOOP;


  l_Factor_By := Pji_Rep_Util.Derive_Factorby(p_project_id, l_cstbudget_version_id, l_return_status, l_msg_count, l_Msg_Data);
  l_Effort_UOM := Pji_Rep_Util.get_effort_uom(p_project_id);

  l_time_slice  := 1376;
  l_report_type := 'TS';  -- prfTaskResFlag

  -- derive plan types
  get_plan_type_info( p_project_id, l_actual_version_id,
      l_cstforecast_version_id, l_cstbudget_version_id, l_cstbudget2_version_id,
      l_revforecast_version_id, l_revbudget_version_id, l_revbudget2_version_id,
      l_orig_cstforecast_version_id, l_orig_cstbudget_version_id, l_orig_cstbudget2_version_id,
      l_orig_revforecast_version_id, l_orig_revbudget_version_id, l_orig_revbudget2_version_id,
      l_actual_plantype_id,
      l_cstforecast_plantype_id, l_cstbudget_plantype_id, l_cstbudget2_plantype_id,
      l_revforecast_plantype_id, l_revbudget_plantype_id, l_revbudget2_plantype_id,
      l_Return_Status, l_Msg_Count, l_Msg_Data);

  -- retrieve data related to the wanted measures sets, using default parameters
  retrieveData(p_Project_Id,  l_WBS_Version_ID, l_WBS_Element_Id, -1, -1,
      l_calendar_id, l_calendar_type,  l_report_date_julian,
      l_actual_version_id,
      l_cstforecast_version_id, l_cstbudget_version_id, l_cstbudget2_version_id,
      l_revforecast_version_id, l_revbudget_version_id, l_revbudget2_version_id,
      l_orig_cstforecast_version_id, l_orig_cstbudget_version_id, l_orig_cstbudget2_version_id,
      l_orig_revforecast_version_id, l_orig_revbudget_version_id, l_orig_revbudget2_version_id,
      l_prior_cstforecast_version_id, l_prior_revforecast_version_id,
      l_actual_plantype_id,
      l_cstforecast_plantype_id, l_cstbudget_plantype_id, l_cstbudget2_plantype_id,
      l_revforecast_plantype_id, l_revbudget_plantype_id, l_revbudget2_plantype_id,
      l_currency_record_type, l_Currency_Code, l_factor_by, l_effort_uom,
      l_currency_type, l_time_slice, l_prg_rollup, l_report_type,
	  l_period_name,
      l_measure_set_codes_tbl,
	  'Y', 'Y', 'Y',
	  g_ProjList, l_measure_id_tbl,x_exception_indicator_tbl,
	  l_measure_type,
      l_ptd_values, l_qtd_values, l_ytd_values, l_itd_values, l_ac_values, l_prp_values,
      l_ptd_html, l_qtd_html, l_ytd_html, l_itd_html, l_ac_html, l_prp_html,
	  l_ptd_trans_id, l_qtd_trans_id, l_ytd_trans_id, l_itd_trans_id, l_ac_trans_id, l_prp_trans_id,
	  l_ptd_meaning, l_qtd_meaning, l_ytd_meaning, l_itd_meaning, l_ac_meaning, l_prp_meaning,
      l_DaysSinceITD, l_DaysInPeriod, l_Return_Status, l_Msg_Count, l_Msg_Data);


  x_measure_values_tbl.EXTEND(l_measure_set_codes_tbl.LAST);
  --Bug 5088377 Initialize the collection before extending
  IF (x_exception_indicator_tbl is NULL) THEN
      x_exception_indicator_tbl := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
  END IF;
  x_exception_indicator_tbl.EXTEND(l_measure_set_codes_tbl.LAST);
  --x_exception_labels_tbl.EXTEND(l_measure_set_code.LAST);

  -- build x_measure_values_tbl and x_exception_indicator_tbl collections.
  -- NB: l_***_values arrays have, as per their contruction, the same length as
  -- x_measure_values_tbl, who has the same length as l_measure_set_code array.
  FOR i IN 1..x_measure_values_tbl.LAST
      LOOP
      IF l_timeslices_tbl(i) = 'PTD' THEN
          x_measure_values_tbl(i) := l_ptd_values(i);
--          x_exception_indicator_tbl(i) := l_ptd_html(i);
      ELSIF l_timeslices_tbl(i) = 'QTD' THEN
          x_measure_values_tbl(i) := l_qtd_values(i);
--          x_exception_indicator_tbl(i) := l_qtd_html(i);
      ELSIF l_timeslices_tbl(i) = 'YTD' THEN
          x_measure_values_tbl(i) := l_ytd_values(i);
--          x_exception_indicator_tbl(i) := l_ytd_html(i);
      ELSIF l_timeslices_tbl(i) = 'ITD' THEN
          x_measure_values_tbl(i) := l_itd_values(i);
--          x_exception_indicator_tbl(i) := l_itd_html(i);
      ELSIF l_timeslices_tbl(i) = 'AC' THEN
          x_measure_values_tbl(i) := l_ac_values(i);
--          x_exception_indicator_tbl(i) := l_ac_html(i);
      ELSIF l_timeslices_tbl(i) = 'PRP' THEN
          x_measure_values_tbl(i) := l_prp_values(i);
--          x_exception_indicator_tbl(i) := l_prp_html(i);
      ELSE
          x_measure_values_tbl(i) := NULL;
--          x_exception_indicator_tbl(i) := NULL;
      END IF;

  END LOOP;

  IF l_msg_count IS NULL OR l_msg_count = 0 THEN
      x_msg_count  := 0;
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  ELSE
      x_msg_count := l_msg_count;
      x_return_status := l_return_status;
  END IF;

  IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG('leaving get_financial_measures',TRUE, g_msg_level_runtime_info);
  END IF;

END Get_Financial_Measures;



--
-- This implementation calls get_financial_measures().
--
PROCEDURE Get_Activity_Measures
(
    p_project_id                NUMBER
    , p_measure_codes_tbl       IN SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , p_measure_set_codes_tbl          IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL
  , p_timeslices_tbl   				 IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL
  , p_measure_id_tbl		 		 IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL
    , x_measure_values_tbl      OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
    , x_exception_indicator_tbl OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
    --, x_exception_labels_tbl    OUT NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
) IS
BEGIN
  NULL;

  Get_Financial_Measures(p_project_id
    , p_measure_codes_tbl
	, p_measure_set_codes_tbl
	, p_timeslices_tbl
	, p_measure_id_tbl
    , x_measure_values_tbl
    , x_exception_indicator_tbl
    , x_return_status
    , x_msg_count
    , x_msg_data);

END Get_Activity_Measures;



/**
 ** For a given Project_id and a set of Currenct plan versions,
 ** this API extracts their relative
 ** Original plan versions IDs and plan types IDs.
 **
 ** History
 **   21-APR-2004   EPASQUIN    Created
 **   28-APR-2004   EPASQUIN    Added NO_DATA_FOUND exception handl3rs.
 **/
PROCEDURE get_plan_type_info
(
    p_project_id               NUMBER
  , pActualVersionId	         NUMBER
  , pCstForecastVersionId	     NUMBER
  , pCstBudgetVersionId	       NUMBER
  , pCstBudget2VersionId	     NUMBER
  , pRevForecastVersionId 	   NUMBER
  , pRevBudgetVersionId	       NUMBER
  , pRevBudget2VersionId	     NUMBER
  , xOrigCstForecastVersionId  OUT NOCOPY NUMBER
  , xOrigCstBudgetVersionId    OUT NOCOPY NUMBER
  , xOrigCstBudget2VersionId   OUT NOCOPY NUMBER
  , xOrigRevForecastVersionId  OUT NOCOPY NUMBER
  , xOrigRevBudgetVersionId    OUT NOCOPY NUMBER
  , xOrigRevBudget2VersionId   OUT NOCOPY NUMBER
  , xActualPlanTypeId	         OUT NOCOPY NUMBER
  , xCstForecastPlanTypeId     OUT NOCOPY NUMBER
  , xCstBudgetPlanTypeId	     OUT NOCOPY NUMBER
  , xCstBudget2PlanTypeId	     OUT NOCOPY NUMBER
  , xRevForecastPlanTypeId     OUT NOCOPY NUMBER
  , xRevBudgetPlanTypeId	     OUT NOCOPY NUMBER
  , xRevBudget2PlanTypeId	     OUT NOCOPY NUMBER
  , x_return_status            OUT NOCOPY VARCHAR2
  , x_msg_count                OUT NOCOPY NUMBER
  , x_msg_data                 OUT NOCOPY VARCHAR2
)

IS

  l_sql_errm VARCHAR2(255);

BEGIN

  x_msg_count := 0;
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  xActualPlanTypeId := -1;

  -- Cost Forecast
  BEGIN
      SELECT
      pbv.fin_plan_type_id         curr_plan_type
      ,orig_pbv.budget_version_id  orig_plan_version
      INTO
      xCstForecastPlanTypeId
      ,xOrigCstForecastVersionId
      FROM
      pa_budget_versions     pbv
      , pa_budget_versions   orig_pbv
      , pa_fin_plan_types_b  orig_pfptb
     -- , pa_fin_plan_types_tl orig_pfptt
      WHERE 1=1
      AND pbv.budget_version_id = pCstForecastVersionId
      AND pbv.fin_plan_type_id  = orig_pbv.fin_plan_type_id
      AND orig_pbv.project_id = p_project_id
      AND orig_pbv.budget_status_code = 'B'
      AND orig_pbv.current_original_flag = 'Y'
      AND orig_pbv.version_type IN ('COST','ALL')
      AND orig_pbv.fin_plan_type_id = orig_pfptb.fin_plan_type_id
     -- AND orig_pfptb.fin_plan_type_id = orig_pfptt.fin_plan_type_id
      AND orig_pfptb.plan_class_code IN ('FORECAST')
     -- AND orig_pfptt.LANGUAGE = USERENV('LANG')
      ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          xCstForecastPlanTypeId    := NULL;
          xOrigCstForecastVersionId := NULL;
      WHEN OTHERS THEN
        l_sql_errm := SQLERRM();
        Pji_Rep_Util.Add_Message(
          p_app_short_name=>'PJI',
          p_msg_name=>'PJI_REP_GENERIC_MSG',
          p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING,
          p_token1=>'PROC_NAME',
          p_token1_value=>'PJI_REP_MEASURE_UTIL.get_plan_type_info: ' ||
            'SQL Error during Cost Forecast query : ' || l_sql_errm
        );

  END;

  -- Cost Budget
  BEGIN
      SELECT
      pbv.fin_plan_type_id         curr_plan_type
      ,orig_pbv.budget_version_id  orig_plan_version
      INTO
      xCstBudgetPlanTypeId
      ,xOrigCstBudgetVersionId
      FROM
      pa_budget_versions     pbv
      , pa_budget_versions   orig_pbv
      , pa_fin_plan_types_b  orig_pfptb
      --, pa_fin_plan_types_tl orig_pfptt
      WHERE 1=1
      AND pbv.budget_version_id = pCstBudgetVersionId
      AND pbv.fin_plan_type_id  = orig_pbv.fin_plan_type_id
      AND orig_pbv.project_id = p_project_id
      AND orig_pbv.budget_status_code = 'B'
      AND orig_pbv.current_original_flag = 'Y'
      AND orig_pbv.version_type IN ('COST','ALL')
      AND orig_pbv.fin_plan_type_id = orig_pfptb.fin_plan_type_id
     -- AND orig_pfptb.fin_plan_type_id = orig_pfptt.fin_plan_type_id
      AND orig_pfptb.plan_class_code IN ('BUDGET')
      --AND orig_pfptt.LANGUAGE = USERENV('LANG')
      ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          xCstBudgetPlanTypeId    := NULL;
          xOrigCstBudgetVersionId := NULL;
      WHEN OTHERS THEN
        l_sql_errm := SQLERRM();
        Pji_Rep_Util.Add_Message(p_app_short_name=>'PJI',
            p_msg_name=>'PJI_REP_GENERIC_MSG',
            p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING,
            p_token1=>'PROC_NAME',
            p_token1_value=>'PJI_REP_MEASURE_UTIL.get_plan_type_info: ' ||
              'SQL Error during Cost Budget query: ' || l_sql_errm
        );
  END;

  -- Cost Budget 2
  BEGIN
  	SELECT
      pbv.fin_plan_type_id         curr_plan_type
      ,orig_pbv.budget_version_id  orig_plan_version
      INTO
      xCstBudget2PlanTypeId
      ,xOrigCstBudget2VersionId
      FROM
      pa_budget_versions     pbv
      , pa_budget_versions   orig_pbv
      , pa_fin_plan_types_b  orig_pfptb
      --, pa_fin_plan_types_tl orig_pfptt
      WHERE 1=1
      AND pbv.budget_version_id = pCstBudget2VersionId
      AND pbv.fin_plan_type_id  = orig_pbv.fin_plan_type_id
      AND orig_pbv.project_id = p_project_id
      AND orig_pbv.budget_status_code = 'B'
      AND orig_pbv.current_original_flag = 'Y'
      AND orig_pbv.version_type IN ('COST','ALL')
      AND orig_pbv.fin_plan_type_id = orig_pfptb.fin_plan_type_id
     -- AND orig_pfptb.fin_plan_type_id = orig_pfptt.fin_plan_type_id
      AND orig_pfptb.plan_class_code IN ('BUDGET')
      --AND orig_pfptt.LANGUAGE = USERENV('LANG')
      ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          xCstBudget2PlanTypeId    := NULL;
          xOrigCstBudget2VersionId := NULL;
      WHEN OTHERS THEN
        l_sql_errm := SQLERRM();
        Pji_Rep_Util.Add_Message(
          p_app_short_name=>'PJI',
          p_msg_name=>'PJI_REP_GENERIC_MSG',
          p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING,
          p_token1=>'PROC_NAME',
          p_token1_value=>'PJI_REP_MEASURE_UTIL.get_plan_type_info: '||
            'SQL Error during Cost Budget 2 query: ' || l_sql_errm
        );
  END;

  -- Revenue Forecast
  BEGIN
      SELECT
      pbv.fin_plan_type_id         curr_plan_type
      ,orig_pbv.budget_version_id  orig_plan_version
      INTO
      xRevForecastPlanTypeId
      ,xOrigRevForecastVersionId
      FROM
      pa_budget_versions     pbv
      , pa_budget_versions   orig_pbv
      , pa_fin_plan_types_b  orig_pfptb
     -- , pa_fin_plan_types_tl orig_pfptt
      WHERE 1=1
      AND pbv.budget_version_id = pRevForecastVersionId
      AND pbv.fin_plan_type_id  = orig_pbv.fin_plan_type_id
      AND orig_pbv.project_id = p_project_id
      AND orig_pbv.budget_status_code = 'B'
      AND orig_pbv.current_original_flag = 'Y'
      AND orig_pbv.version_type IN ('REVENUE','ALL')
      AND orig_pbv.fin_plan_type_id = orig_pfptb.fin_plan_type_id
    --  AND orig_pfptb.fin_plan_type_id = orig_pfptt.fin_plan_type_id
      AND orig_pfptb.plan_class_code IN ('FORECAST')
     -- AND orig_pfptt.LANGUAGE = USERENV('LANG')
      ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          xRevForecastPlanTypeId    := NULL;
          xOrigRevForecastVersionId := NULL;
      WHEN OTHERS THEN
        l_sql_errm := SQLERRM();
        Pji_Rep_Util.Add_Message(
          p_app_short_name=>'PJI',
          p_msg_name=>'PJI_REP_GENERIC_MSG',
          p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING,
          p_token1=>'PROC_NAME',
          p_token1_value=>'PJI_REP_MEASURE_UTIL.get_plan_type_info: ' ||
            'SQL Error during Revenue Forecast query: '|| l_sql_errm
        );
  END;

  -- Revenue Budget
  BEGIN
      SELECT
      pbv.fin_plan_type_id         curr_plan_type
      ,orig_pbv.budget_version_id  orig_plan_version
      INTO
      xRevBudgetPlanTypeId
      ,xOrigRevBudgetVersionId
      FROM
      pa_budget_versions     pbv
      , pa_budget_versions   orig_pbv
      , pa_fin_plan_types_b  orig_pfptb
      --, pa_fin_plan_types_tl orig_pfptt
      WHERE 1=1
      AND pbv.budget_version_id = pRevBudgetVersionId
      AND pbv.fin_plan_type_id  = orig_pbv.fin_plan_type_id
      AND orig_pbv.project_id = p_project_id
      AND orig_pbv.budget_status_code = 'B'
      AND orig_pbv.current_original_flag = 'Y'
      AND orig_pbv.version_type IN ('REVENUE','ALL')
      AND orig_pbv.fin_plan_type_id = orig_pfptb.fin_plan_type_id
     -- AND orig_pfptb.fin_plan_type_id = orig_pfptt.fin_plan_type_id
      AND orig_pfptb.plan_class_code IN ('BUDGET')
     -- AND orig_pfptt.LANGUAGE = USERENV('LANG')
      ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          xRevBudgetPlanTypeId    := NULL;
          xOrigRevBudgetVersionId := NULL;
      WHEN OTHERS THEN
        l_sql_errm := SQLERRM();
        Pji_Rep_Util.Add_Message(p_app_short_name=>'PJI',
          p_msg_name=>'PJI_REP_GENERIC_MSG',
          p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING,
          p_token1=>'PROC_NAME',
          p_token1_value=>'PJI_REP_MEASURE_UTIL.get_plan_type_info: ' ||
            'SQL Error during Revenue Budget query: ' || l_sql_errm
        );
  END;

  -- Revenue Budget 2
  BEGIN
  	SELECT
      pbv.fin_plan_type_id         curr_plan_type
      ,orig_pbv.budget_version_id  orig_plan_version
      INTO
      xRevBudget2PlanTypeId
      ,xOrigRevBudget2VersionId
      FROM
      pa_budget_versions     pbv
      , pa_budget_versions   orig_pbv
      , pa_fin_plan_types_b  orig_pfptb
     -- , pa_fin_plan_types_tl orig_pfptt
      WHERE 1=1
      AND pbv.budget_version_id = pRevBudget2VersionId
      AND pbv.fin_plan_type_id  = orig_pbv.fin_plan_type_id
      AND orig_pbv.project_id = p_project_id
      AND orig_pbv.budget_status_code = 'B'
      AND orig_pbv.current_original_flag = 'Y'
      AND orig_pbv.version_type IN ('REVENUE','ALL')
      AND orig_pbv.fin_plan_type_id = orig_pfptb.fin_plan_type_id
    --  AND orig_pfptb.fin_plan_type_id = orig_pfptt.fin_plan_type_id
      AND orig_pfptb.plan_class_code IN ('BUDGET')
     -- AND orig_pfptt.LANGUAGE = USERENV('LANG')
      ;
  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          xRevBudget2PlanTypeId    := NULL;
          xOrigRevBudget2VersionId := NULL;
      WHEN OTHERS THEN
        l_sql_errm := SQLERRM();
        Pji_Rep_Util.Add_Message(p_app_short_name=>'PJI',
          p_msg_name=>'PJI_REP_GENERIC_MSG',
          p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING,
          p_token1=>'PROC_NAME',
          p_token1_value=>'PJI_REP_MEASURE_UTIL.get_plan_type_info: ' ||
            'SQL Error during Revenue Budget 2 query: ' || l_sql_errm
        );
  END;

END get_plan_type_info;



/**
 ** This API prepares, calculates, retrieves the measures to be used by
 ** Overview Page and breakdown pages. The measures are stored on the
 ** temporary table PJI_REP_XTD_MEASURES_TMP.
 **
 ** Return: xDaysSinceITD = number of days since Inception to Date
 ** Return: xDaysInPeriod = number of days in current period
 **
 ** History
 **   16-MAR-2004   EPASQUIN    Created
 **   21-APR-2004   EPASQUIN    Introduced Plan_types parameters
 **/
PROCEDURE prepareData
(
    pProjectId			            NUMBER
  , pWBSVersionId		            NUMBER
  , pWBSElementId	              NUMBER
  , pRBSVersionId		            NUMBER
  , pRBSElementId	              NUMBER
  , pCalendarId                 NUMBER
  , pCalendarType               VARCHAR2
  , pPeriodDateJulian           NUMBER
  , pActualVersionId	          NUMBER
  , pCstForecastVersionId	      NUMBER
  , pCstBudgetVersionId	        NUMBER
  , pCstBudget2VersionId	      NUMBER
  , pRevForecastVersionId	      NUMBER
  , pRevBudgetVersionId         NUMBER
  , pRevBudget2VersionId	      NUMBER
  , pOrigCstForecastVersionId	  NUMBER
  , pOrigCstBudgetVersionId	    NUMBER
  , pOrigCstBudget2VersionId	  NUMBER
  , pOrigRevForecastVersionId	  NUMBER
  , pOrigRevBudgetVersionId	    NUMBER
  , pOrigRevBudget2VersionId	  NUMBER
  , pPriorCstForecastVersionId  NUMBER
  , pPriorRevForecastVersionId  NUMBER
  , pActualPlanTypeId	          NUMBER
  , pCstForecastPlanTypeId      NUMBER
  , pCstBudgetPlanTypeId	      NUMBER
  , pCstBudget2PlanTypeId	      NUMBER
  , pRevForecastPlanTypeId      NUMBER
  , pRevBudgetPlanTypeId	      NUMBER
  , pRevBudget2PlanTypeId	      NUMBER
  , pCurrencyRecordType	        NUMBER
  , pCurrencyCode		            VARCHAR2
  , pFactorBy                   NUMBER   -- to be applied to every CURRENCY measure
  , pEffortUOM                  NUMBER   -- to be applied to every HOURS measure
  , pCurrencyType		            VARCHAR2
  , pTimeSlice                  NUMBER
  , pPrgRollup                  VARCHAR2
  , pReportType                 VARCHAR2
  , pWBSRollupFlag				VARCHAR2 DEFAULT 'Y'
  , pRBSRollupFlag				VARCHAR2 DEFAULT 'Y'
  , pPeriodName					VARCHAR2
  , xDaysSinceITD               OUT NOCOPY NUMBER
  , xDaysInPeriod               OUT NOCOPY NUMBER
  , x_return_status	            OUT NOCOPY VARCHAR2
  , x_msg_count		              OUT NOCOPY NUMBER
  , x_msg_data		              OUT NOCOPY VARCHAR2
) AS

  x_measure_set_code	SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
  x_measure_name	    SYSTEM.PA_VARCHAR2_240_TBL_TYPE;
  x_measure_type	    SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
  x_ptd_value		      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  x_qtd_value		      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  x_ytd_value		      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  x_itd_value		      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  x_ac_value		      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  x_prp_value	        SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  x_ptd_html	        SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  x_qtd_html	        SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  x_ytd_html	        SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  x_itd_html	        SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  x_ac_html	          SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  x_prp_html	        SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  x_ptd_trans_id	     SYSTEM.PA_NUM_TBL_TYPE;
  x_ytd_trans_id	     SYSTEM.PA_NUM_TBL_TYPE;
  x_qtd_trans_id	     SYSTEM.PA_NUM_TBL_TYPE;
  x_itd_trans_id	     SYSTEM.PA_NUM_TBL_TYPE;
  x_ac_trans_id	     	 SYSTEM.PA_NUM_TBL_TYPE;
  x_prp_trans_id	     SYSTEM.PA_NUM_TBL_TYPE;
  x_ptd_meaning      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  x_ytd_meaning      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  x_qtd_meaning      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  x_itd_meaning      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  x_ac_meaning       SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  x_prp_meaning      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;

  l_exception_indicator_tbl		SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;
  l_sql_errm          VARCHAR2(255);

BEGIN
	NULL;

  IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG('entering preparedata',TRUE, g_msg_level_runtime_info);
  END IF;


	--
	-- Delete the existing records in temporary table.
	--
	DELETE PJI_REP_XTD_MEASURES_TMP;

  BEGIN

  	--
  	-- Fetch the translated measure names from the lookups.
    -- Measure_Types elements can be in ['CURRENCY', 'PERCENT', 'HOURS', 'INDEX', 'OTHERS']
    -- We must exclude the measures outside the PO scope.
  	--
  	SELECT measure_set_code
  	, NULL -- calculated later in the code -- measure_format
  	, name
  	, NULL -- calculated later in the code
  	, NULL -- calculated later in the code
   	, NULL -- calculated later in the code
  	, NULL -- calculated later in the code
   	, NULL -- calculated later in the code
  	, NULL -- calculated later in the code
   	BULK COLLECT INTO x_measure_set_code
  	, x_measure_type
  	, x_measure_name
  	, x_ptd_value
  	, x_qtd_value
  	, x_ytd_value
  	, x_itd_value
    , x_ac_value
    , x_prp_value
  	FROM pji_mt_measure_sets_vl
  	WHERE 1=1
    AND measure_set_type IN ('SEEDED', 'CUSTOM_STORED', 'CUSTOM_CALC')
	AND measure_set_code LIKE 'PPF%'
    ORDER BY measure_set_code;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
        x_return_status := Pji_Rep_Util.G_RET_STS_WARNING;
        Pji_Rep_Util.Add_Message(p_app_short_name=>'PJI',
            p_msg_name=>'PJI_REP_UNDEFINED_MSR_CODE',
            p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING);
    WHEN OTHERS THEN
      l_sql_errm := SQLERRM();
      x_return_status := Pji_Rep_Util.G_RET_STS_WARNING;
      Pji_Rep_Util.Add_Message(
        p_app_short_name=>'PJI',
        p_msg_name=>'PJI_REP_GENERIC_MSG',
        p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING,
        p_token1=>'PROC_NAME',
        p_token1_value=>'PJI_REP_MEASURE_UTIL; SQL_Error: ' || l_sql_errm
      );

  END;

	retrieveData(pProjectId, pWBSVersionId, pWBSElementId, pRBSVersionId, pRBSElementId,
        pCalendarId, pCalendarType, pPeriodDateJulian,
        pActualVersionId,
        pCstForecastVersionId, pCstBudgetVersionId, pCstBudget2VersionId,
        pRevForecastVersionId, pRevBudgetVersionId, pRevBudget2VersionId,
        pOrigCstForecastVersionId, pOrigCstBudgetVersionId, pOrigCstBudget2VersionId,
        pOrigRevForecastVersionId, pOrigRevBudgetVersionId, pOrigRevBudget2VersionId,
        pPriorCstForecastVersionId, pPriorRevForecastVersionId,
        pActualPlanTypeId,
        pCstForecastPlanTypeId, pCstBudgetPlanTypeId, pCstBudget2PlanTypeId,
        pRevForecastPlanTypeId, pRevBudgetPlanTypeId, pRevBudget2PlanTypeId,
        pCurrencyRecordType, pCurrencyCode, pFactorBy, pEffortUOM,
        pCurrencyType, pTimeSlice, pPrgRollup, pReportType,
		pPeriodName,
        x_measure_set_code,
		'N', pWBSRollupFlag, pRBSRollupFlag,
		g_Prepare, NULL, l_exception_indicator_tbl,
		x_measure_type, x_ptd_value, x_qtd_value,
        x_ytd_value, x_itd_value, x_ac_value, x_prp_value,
        x_ptd_html, x_qtd_html, x_ytd_html, x_itd_html, x_ac_html, x_prp_html,
		x_ptd_trans_id, x_ytd_trans_id, x_qtd_trans_id, x_itd_trans_id, x_ac_trans_id, x_prp_trans_id,
		x_ptd_meaning, x_qtd_meaning, x_ytd_meaning, x_itd_meaning, x_ac_meaning, x_prp_meaning,
        xDaysSinceITD, xDaysInPeriod, x_return_status, x_msg_count, x_msg_data);
		  /* Bug 6914287 changed the order of the trans_id variables to match the procedure definition */

  IF x_measure_set_code.COUNT < 1 THEN
      RETURN;
  END IF;


  --FOR i IN 1..x_measure_set_code.COUNT LOOP
  --  dbms_output.put_line(x_measure_set_code(i)||'='||x_itd_value(i)||'; html('||i||')='||x_itd_html(i));
  --END LOOP;

  --
	-- Bulk Insert the amounts into the temporary table.
	--
  FORALL i IN 1..x_measure_set_code.LAST
  INSERT INTO PJI_REP_XTD_MEASURES_TMP
  (
    MEASURE_SET_CODE, MEASURE_TYPE, MEASURE_LABEL,
    PTD_VALUE, QTD_VALUE, YTD_VALUE, ITD_VALUE, AC_VALUE, PRP_VALUE,
    PTD_HTML, QTD_HTML, YTD_HTML, ITD_HTML, AC_HTML, PRP_HTML,
	PTD_TRANS_ID, QTD_TRANS_ID, YTD_TRANS_ID, ITD_TRANS_ID, AC_TRANS_ID, PRP_TRANS_ID,
	PTD_MEANING,QTD_MEANING,YTD_MEANING,ITD_MEANING,AC_MEANING,PRP_MEANING
  )
  VALUES (
    x_measure_set_code(i), x_measure_type(i), x_measure_name(i),
    x_ptd_value(i), x_qtd_value(i), x_ytd_value(i), x_itd_value(i), x_ac_value(i), x_prp_value(i),
    x_ptd_html(i), x_qtd_html(i), x_ytd_html(i), x_itd_html(i), x_ac_html(i), x_prp_html(i),
	x_ptd_trans_id(i), x_qtd_trans_id(i), x_ytd_trans_id(i), x_itd_trans_id(i), x_ac_trans_id(i), x_prp_trans_id(i),
	x_ptd_meaning(i), x_qtd_meaning(i), x_ytd_meaning(i), x_itd_meaning(i), x_ac_meaning(i), x_prp_meaning(i)
  );

  IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG('leaving preparedata',TRUE, g_msg_level_runtime_info);
  END IF;

	COMMIT;



END prepareData;


/**
 ** Given a list of wanted measures, this API retrieves them in collections
 ** executing all necessary calculations.
 ** The user is not required to initialize the output collections.
 **
 **   return: xDaysSinceITD = number of days since Inception to Date
 **   return: xDaysInPeriod = number of days in current period
 **   return: x_measure_type = collection with measure types
 **   return: x_ptd_value = collection with PTD measure values
 **   return: x_qtd_value = collection with QTD measure values
 **   return: x_ytd_value = collection with YTD measure values
 **   return: x_itd_value = collection with ITD measure values
 **   return: x_ac_value = collection with AT Completion measure values
 **   return: x_prp_value = collection with Prior Period measure values
 **   return: x_ptd_html = collection with HTML code for PTD measure values
 **   return: x_qtd_html = collection with HTML code for QTD measure values
 **   return: x_ytd_html = collection with HTML code for YTD measure values
 **   return: x_itd_html = collection with HTML code for ITD measure values
 **   return: x_ac_html = collection with HTML code for At Completion measure values
 **   return: x_prp_html = collection with HTML code for Prior Period measure values
 **
 **/
PROCEDURE retrieveData
(
  pProjectId                    NUMBER
  , pWBSVersionId		            NUMBER
  , pWBSElementId               NUMBER
  , pRBSVersionId               NUMBER
  , pRBSElementId               NUMBER
  , pCalendarId                 NUMBER
  , pCalendarType               VARCHAR2
  , pPeriodDateJulian           NUMBER
  , pActualVersionId            NUMBER
  , pCstForecastVersionId       NUMBER
  , pCstBudgetVersionId         NUMBER
  , pCstBudget2VersionId        NUMBER
  , pRevForecastVersionId       NUMBER
  , pRevBudgetVersionId         NUMBER
  , pRevBudget2VersionId        NUMBER
  , pOrigCstForecastVersionId   NUMBER
  , pOrigCstBudgetVersionId     NUMBER
  , pOrigCstBudget2VersionId    NUMBER
  , pOrigRevForecastVersionId   NUMBER
  , pOrigRevBudgetVersionId     NUMBER
  , pOrigRevBudget2VersionId    NUMBER
  , pPriorCstForecastVersionId  NUMBER
  , pPriorRevForecastVersionId  NUMBER
  , pActualPlanTypeId           NUMBER
  , pCstForecastPlanTypeId      NUMBER
  , pCstBudgetPlanTypeId        NUMBER
  , pCstBudget2PlanTypeId       NUMBER
  , pRevForecastPlanTypeId      NUMBER
  , pRevBudgetPlanTypeId        NUMBER
  , pRevBudget2PlanTypeId       NUMBER
  , pCurrencyRecordType         NUMBER
  , pCurrencyCode               VARCHAR2
  , pFactorBy                   NUMBER   -- to be applied to every CURRENCY measure
  , pEffortUOM                  NUMBER   -- to be applied to every HOURS measure
  , pCurrencyType               VARCHAR2
  , pTimeSlice                  NUMBER
  , pPrgRollup                  VARCHAR2
  , pReportType                 VARCHAR2
  , pPeriodName					VARCHAR2
  , p_measure_set_code          IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE
  , p_raw_text_flag				VARCHAR2 DEFAULT 'Y'
  , pWBSRollupFlag				VARCHAR2 DEFAULT 'Y'
  , pRBSRollupFlag				VARCHAR2 DEFAULT 'Y'
  , pCallingType				VARCHAR2
  , p_measure_id_tbl			IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL
  , x_exception_indicator_tbl	OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  , x_measure_type              OUT NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE
  , x_ptd_value                 OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_qtd_value                 OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_ytd_value                 OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_itd_value                 OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_ac_value                  OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_prp_value                 OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_ptd_html                  OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  , x_qtd_html                  OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  , x_ytd_html                  OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  , x_itd_html                  OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  , x_ac_html                   OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  , x_prp_html                  OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  , x_ptd_trans_id	     		OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
  , x_ytd_trans_id	     		OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
  , x_qtd_trans_id	     		OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
  , x_itd_trans_id	     		OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
  , x_ac_trans_id	     	 	OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
  , x_prp_trans_id	     	 	OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE
  , x_ptd_meaning      OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_ytd_meaning      OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_qtd_meaning      OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_itd_meaning      OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_ac_meaning       OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , x_prp_meaning      OUT NOCOPY SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , xDaysSinceITD               OUT NOCOPY NUMBER
  , xDaysInPeriod               OUT NOCOPY NUMBER
  , x_return_status             IN OUT NOCOPY VARCHAR2
  , x_msg_count                 IN OUT NOCOPY NUMBER
  , x_msg_data                  IN OUT NOCOPY VARCHAR2
) AS

  l_overview_type               pji_rep_overview_type_tbl; --table of objects

  l_temp_overview_type			pji_rep_overview_type_tbl;
  l_result_index				NUMBER;

  l_pji_facts                   pji_ac_proj_f_rec;
  l_pji_facts_null              pji_ac_proj_f_rec;
  l_completed_percentage        NUMBER;
  l_planned_work_qt             prf_over_time_amounts_rec;
  l_incr_work_qt                prf_over_time_amounts_rec;
  l_amt_over_time_null          prf_over_time_amounts_rec;
  l_actual_index                NUMBER;
  l_cost_forecast_index         NUMBER;
  l_cost_budget_index           NUMBER;
  l_cost_budget2_index          NUMBER;
  l_rev_forecast_index          NUMBER;
  l_rev_budget_index            NUMBER;
  l_rev_budget2_index           NUMBER;
  l_orig_cost_forecast_index    NUMBER;
  l_orig_cost_budget_index      NUMBER;
  l_orig_cost_budget2_index     NUMBER;
  l_orig_rev_forecast_index     NUMBER;
  l_orig_rev_budget_index       NUMBER;
  l_orig_rev_budget2_index      NUMBER;
  l_prior_cost_forecast_index   NUMBER;
  l_prior_rev_forecast_index    NUMBER;
  l_check_plan_versions         NUMBER;
  ptd_measure_ids_tbl           SYSTEM.PA_NUM_TBL_TYPE;
  qtd_measure_ids_tbl           SYSTEM.PA_NUM_TBL_TYPE;
  ytd_measure_ids_tbl           SYSTEM.PA_NUM_TBL_TYPE;
  itd_measure_ids_tbl           SYSTEM.PA_NUM_TBL_TYPE;
  ac_measure_ids_tbl            SYSTEM.PA_NUM_TBL_TYPE;
  prp_measure_ids_tbl           SYSTEM.PA_NUM_TBL_TYPE;
  l_seeded_measures             SYSTEM.PA_Num_Tbl_Type;
  l_seeded_measures_ptd         SYSTEM.PA_Num_Tbl_Type;
  l_seeded_measures_qtd         SYSTEM.PA_Num_Tbl_Type;
  l_seeded_measures_ytd         SYSTEM.PA_Num_Tbl_Type;
  l_seeded_measures_itd         SYSTEM.PA_Num_Tbl_Type;
  l_seeded_measures_ac          SYSTEM.PA_Num_Tbl_Type;
  l_seeded_measures_prp         SYSTEM.PA_Num_Tbl_Type;
  l_fp_calc_custom_measures_ptd      SYSTEM.PA_Num_Tbl_Type;
  l_fp_calc_custom_measures_qtd      SYSTEM.PA_Num_Tbl_Type;
  l_fp_calc_custom_measures_ytd      SYSTEM.PA_Num_Tbl_Type;
  l_fp_calc_custom_measures_itd      SYSTEM.PA_Num_Tbl_Type;
  l_fp_calc_custom_measures_ac       SYSTEM.PA_Num_Tbl_Type;
  l_fp_calc_custom_measures_prp      SYSTEM.PA_Num_Tbl_Type;
  l_ac_calc_custom_measures_ptd      SYSTEM.PA_Num_Tbl_Type;
  l_ac_calc_custom_measures_qtd      SYSTEM.PA_Num_Tbl_Type;
  l_ac_calc_custom_measures_ytd      SYSTEM.PA_Num_Tbl_Type;
  l_ac_calc_custom_measures_itd      SYSTEM.PA_Num_Tbl_Type;
  l_ac_calc_custom_measures_ac       SYSTEM.PA_Num_Tbl_Type;
  l_ac_calc_custom_measures_prp      SYSTEM.PA_Num_Tbl_Type;
  l_fp_custom_measures_ptd      SYSTEM.PA_Num_Tbl_Type;
  l_fp_custom_measures_qtd      SYSTEM.PA_Num_Tbl_Type;
  l_fp_custom_measures_ytd      SYSTEM.PA_Num_Tbl_Type;
  l_fp_custom_measures_itd      SYSTEM.PA_Num_Tbl_Type;
  l_fp_custom_measures_ac       SYSTEM.PA_Num_Tbl_Type;
  l_fp_custom_measures_prp      SYSTEM.PA_Num_Tbl_Type;
  l_ac_custom_measures_ptd      SYSTEM.PA_Num_Tbl_Type;
  l_ac_custom_measures_qtd      SYSTEM.PA_Num_Tbl_Type;
  l_ac_custom_measures_ytd      SYSTEM.PA_Num_Tbl_Type;
  l_ac_custom_measures_itd      SYSTEM.PA_Num_Tbl_Type;
  l_ac_custom_measures_ac       SYSTEM.PA_Num_Tbl_Type;
  l_ac_custom_measures_prp      SYSTEM.PA_Num_Tbl_Type;
  l_fp_cus_meas_formats            SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
  l_ac_cus_meas_formats            SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
  l_fp_custom_measures_ptd_char SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_fp_custom_measures_qtd_char SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_fp_custom_measures_ytd_char SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_fp_custom_measures_itd_char SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_fp_custom_measures_ac_char  SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_fp_custom_measures_prp_char SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ac_custom_measures_ptd_char SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ac_custom_measures_qtd_char SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ac_custom_measures_ytd_char SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ac_custom_measures_itd_char SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ac_custom_measures_ac_char  SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ac_custom_measures_prp_char SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_num                         NUMBER;
  i                             NUMBER;
  l_PrgRollupFlag1              VARCHAR2(1);
  l_PrgRollupFlag2              VARCHAR2(1);
  l_sql_errm                    VARCHAR2(255);
  l_org_id                      NUMBER;
  l_project_type_class          VARCHAR2(30);
  l_capital_proj_mask           NUMBER;
  l_total_funding               NUMBER;
  l_backlog                     NUMBER;
  S                             VARCHAR2(255);
  l_factor_by                   NUMBER;
  l_effort_UOM                  NUMBER;
  l_temp_excp_meaning	     	SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_indirect_proj_mask			NUMBER;
  l_contract_proj_mask			NUMBER;
  /* Added by Ning for the pass-in pRBSRollupFlag */
  l_rbs_aggr_level				VARCHAR2(1);
  l_next_invoice_date			DATE;
  l_start_date					DATE;
  l_billing_cycle_id			NUMBER;
  l_billing_offset				NUMBER;
  l_seeded_measure_count		NUMBER;
  l_hours_per_day				NUMBER;

  l_ptd_value					SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_qtd_value					SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ytd_value					SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_itd_value					SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_ac_value					SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_prp_value					SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_cust_measure_number			NUMBER;

   --
   -- Added following local variables for bug 3898511
   -- These variable are used to remove literals from a sqls used to fetch
   -- data from reporting fact table and activity based facts
   --
   l_calendarType_E                     VARCHAR2(1)   := 'E';
   l_calendarType_A                     VARCHAR2(1)   := 'A';
   l_julianFormat                       VARCHAR2(1)   := 'j';
   l_reportType_TS                      VARCHAR2(2)   := 'TS';
   l_reportType_TA                      VARCHAR2(2)   := 'TA';
   l_reportType_RA                      VARCHAR2(2)   := 'RA';
   l_reportType_RS                      VARCHAR2(2)   := 'RS';
   l_rbs_aggr_level_L                   VARCHAR2(1)   := 'L';
   l_rbs_aggr_level_T                   VARCHAR2(1)   := 'T';
   l_WBSRollupFlag_N                    VARCHAR2(1)   := 'N';
   -- till here for bug 3898511

  -- Adding following 8 variables for bug 4194804
  l_measure1                           NUMBER;
  l_measure2                           NUMBER;
  l_measure3                           NUMBER;
  l_measure4                           NUMBER;
  l_measure5                           NUMBER;
  l_measure6                           NUMBER;
  l_measure7                           NUMBER;
  l_measures_total                     NUMBER;

  -- project type consistent flag
  l_ptc_flag 	  			 	 	   VARCHAR2(1);

BEGIN

  NULL;

  IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG(
	    'PJI_REP_MEASURE_UTIL.retrieveData: beginning execution....',
	    TRUE, g_msg_level_proc_call
	  );
  END IF;
  --
  -- some sanity checks and defaults
  --

  IF pPrgRollup = 'Y' THEN
    l_PrgRollupFlag1 := 'Y';
    l_PrgRollupFlag2 := 'N';
  ELSE
    l_PrgRollupFlag1 := 'N';
    l_PrgRollupFlag2 := 'N';
  END IF;

  l_factor_by := pFactorBy;
  IF pFactorBy IS NULL OR pFactorBy = 0 THEN
    l_factor_by := 1;
  END IF;

  l_effort_UOM := pEffortUOM;
  IF pEffortUOM IS NULL OR pEffortUOM = 0 THEN
    l_effort_UOM := 1;
  END IF;

  SELECT pia.fte_day
  INTO l_hours_per_day
  FROM pa_implementations_all pia, pa_projects_all ppa WHERE pia.org_id = ppa.org_id and ppa.project_id = pProjectId;

/* To handle the program reporting when current version and orginal version are same
 * we have to generate a local table with current version orginal version in different
 * rows even the version id is same. So we will fix the index of those plan versions
 * as the follow:
 * we removed original forecast index because there is no such version*/
  l_actual_index		          := 1;
  l_cost_forecast_index	      := 2;
  l_cost_budget_index	        := 3;
  l_cost_budget2_index	      := 4;
  l_rev_forecast_index	      := 5;
  l_rev_budget_index	        := 6;
  l_rev_budget2_index	        := 7;
  l_orig_cost_budget_index	  := 8;
  l_orig_cost_budget2_index	  := 9;
  l_orig_rev_budget_index	    := 10;
  l_orig_rev_budget2_index	  := 11;
  l_prior_cost_forecast_index := 12;
  l_prior_rev_forecast_index  := 13;
  l_check_plan_versions       := 0;

  IF x_return_status IS NULL THEN
      x_msg_count := 0;
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
  END IF;

  l_overview_type := pji_rep_overview_type_tbl();
  l_temp_overview_type := pji_rep_overview_type_tbl();


  IF p_measure_set_code.COUNT < 1 THEN
      RETURN;
  END IF;

  --
  -- derive project type class for current project
  --

	Pji_Rep_Util.Check_Proj_Type_Consistency(pProjectId
	, pWBSVersionId
	, 'FINANCIAL'
	, l_ptc_flag
	, x_return_status
	, x_msg_count
	, x_msg_data);

  IF (pPrgRollup = 'Y') AND (l_ptc_flag = 'F') THEN
  	 l_capital_proj_mask := 1;
	 l_indirect_proj_mask := 1;
	 l_contract_proj_mask := 1;
  ELSE
	  BEGIN
	    SELECT DISTINCT UPPER(t.project_type_class_code)
	    INTO l_project_type_class
	    FROM pa_projects_all   p
	    , pa_project_types_all t
	    WHERE 1=1
	    AND p.project_id = pProjectId
	    AND p.project_type = t.project_type
	    AND p.org_id = t.org_id;
	  EXCEPTION
	    WHEN OTHERS THEN
	      l_project_type_class := 'CONTRACT';
	  END;

	  --
	  -- this mask is used to nullify all capital related measures for
	  -- non-capital projects
	  --
	  IF l_project_type_class = 'CAPITAL' THEN
	    l_capital_proj_mask := 1;
	  ELSE
	    l_capital_proj_mask := NULL;
	  END IF;

	  IF l_project_type_class = 'INDIRECT' THEN
	    l_indirect_proj_mask := 1;
	  ELSE
	    l_indirect_proj_mask := NULL;
	  END IF;

	  IF l_project_type_class = 'CONTRACT' THEN
	    l_contract_proj_mask := 1;
	  ELSE
	    l_contract_proj_mask := NULL;
	  END IF;
  END IF;
  /* Added by Ning for the pass-in pRBSRollupFlag */
  IF (pRBSRollupFlag = 'Y') THEN
  	 l_rbs_aggr_level := 'R';
  ELSE
  	 l_rbs_aggr_level := 'L';
  END IF;

  /* Added by Ning to get the next invoice date */
  SELECT start_date, billing_cycle_id,
            billing_offset
    INTO l_start_date, l_billing_cycle_id, l_billing_offset
    FROM pa_projects_all
    WHERE project_id = pProjectId;

  l_next_invoice_date :=
  Pa_Billing_Cycles_Pkg.get_next_billing_date(
  						X_Project_ID => pProjectId,
						X_Project_Start_Date => l_start_date,
						X_Billing_Cycle_ID => l_billing_cycle_id,
						X_Billing_Offset_Days => l_billing_offset,
						X_Bill_Thru_Date  => NULL,
						X_Last_Bill_Thru_Date => NULL);

  --
	-- Fetch the data from the reporting fact table.
  -- Notes:
  -- 1. l_overview_type is a collection (table) of objects having structure:
  -- plan_version_id, plan_type_id, and various sums.
  -- 2. l_overview_type collects the SUMs of ALL the amount values from
  -- reporting lines for all plan types.
  -- 3. The l_overview_type collection is grouped by plan_type_id and plan_version_id.
  -- The masks are arithmetic selectors able to include (if their value = 1) or
  -- exclude (if their value is 0) a term in the sum.
  -- E.g. the qtd_mask is 1 for all the CURR_PERIOD and PREV_PERIOD record types,
  -- and 0 for the PREV_QUARTER and PREV_YEAR record types,
  -- so it will automatically exclude all the ytd, itd amounts from the QTD sums.
  -- Using the parameter pTimeSlice we exclude all the records which have a
  -- record type above the selected threshold
	--
  BEGIN

    SELECT
    pji_rep_overview_type(
	plan_version_id
    ,plan_type_id
    ,SUM(ptd_mask * raw_cost)
    ,SUM(ptd_mask * brdn_cost)
    ,SUM(ptd_mask * revenue * l_contract_proj_mask)
    ,SUM(ptd_mask * bill_raw_cost * l_contract_proj_mask)
    ,SUM(ptd_mask * bill_brdn_cost * l_contract_proj_mask)
    ,SUM(ptd_mask * billable_equipment_hours * l_contract_proj_mask)
    ,SUM(ptd_mask * bill_labor_raw_cost * l_contract_proj_mask)
    ,SUM(ptd_mask * bill_labor_brdn_cost * l_contract_proj_mask)
    ,SUM(ptd_mask * bill_labor_hrs * l_contract_proj_mask)
    ,SUM(ptd_mask * capitalizable_raw_cost * l_capital_proj_mask)
    ,SUM(ptd_mask * capitalizable_brdn_cost * l_capital_proj_mask)
    ,SUM(ptd_mask * equipment_hours)
	,SUM(ptd_mask * equipment_raw_cost)
	,SUM(ptd_mask * equipment_brdn_cost)
    ,SUM(ptd_mask * labor_raw_cost)
    ,SUM(ptd_mask * labor_brdn_cost)
    ,SUM(ptd_mask * labor_hrs)
    ,SUM(ptd_mask * labor_revenue * l_contract_proj_mask)
    ,SUM(ptd_mask * 0) --unbilled_cost
    ,SUM(ptd_mask * 0) --capitalized_cost
    ,SUM(itd_mask * sup_inv_committed_cost)
    ,SUM(itd_mask * po_committed_cost)
    ,SUM(itd_mask * pr_committed_cost)
    ,SUM(itd_mask * oth_committed_cost)
    ,SUM(qtd_mask * raw_cost)
    ,SUM(qtd_mask * brdn_cost)
    ,SUM(qtd_mask * revenue * l_contract_proj_mask)
    ,SUM(qtd_mask * bill_raw_cost * l_contract_proj_mask)
    ,SUM(qtd_mask * bill_brdn_cost * l_contract_proj_mask)
    ,SUM(qtd_mask * billable_equipment_hours * l_contract_proj_mask)
    ,SUM(qtd_mask * bill_labor_raw_cost * l_contract_proj_mask)
    ,SUM(qtd_mask * bill_labor_brdn_cost * l_contract_proj_mask)
    ,SUM(qtd_mask * bill_labor_hrs * l_contract_proj_mask)
    ,SUM(qtd_mask * capitalizable_raw_cost * l_capital_proj_mask)
    ,SUM(qtd_mask * capitalizable_brdn_cost * l_capital_proj_mask)
    ,SUM(qtd_mask * equipment_hours)
	,SUM(qtd_mask * equipment_raw_cost)
	,SUM(qtd_mask * equipment_brdn_cost)
    ,SUM(qtd_mask * labor_raw_cost)
    ,SUM(qtd_mask * labor_brdn_cost)
    ,SUM(qtd_mask * labor_hrs)
    ,SUM(qtd_mask * labor_revenue * l_contract_proj_mask)
    ,SUM(qtd_mask * 0) --unbilled_cost
    ,SUM(qtd_mask * 0) --capitalized_cost
    ,SUM(itd_mask * sup_inv_committed_cost) -- added for 6864037
    ,SUM(itd_mask * po_committed_cost) -- added for 6864037
    ,SUM(itd_mask * pr_committed_cost) -- added for 6864037
    ,SUM(itd_mask * oth_committed_cost) -- added for 6864037
    ,SUM(ytd_mask * raw_cost)
    ,SUM(ytd_mask * brdn_cost)
    ,SUM(ytd_mask * revenue * l_contract_proj_mask)
    ,SUM(ytd_mask * bill_raw_cost * l_contract_proj_mask)
    ,SUM(ytd_mask * bill_brdn_cost * l_contract_proj_mask)
    ,SUM(ytd_mask * billable_equipment_hours * l_contract_proj_mask)
    ,SUM(ytd_mask * bill_labor_raw_cost * l_contract_proj_mask)
    ,SUM(ytd_mask * bill_labor_brdn_cost * l_contract_proj_mask)
    ,SUM(ytd_mask * bill_labor_hrs * l_contract_proj_mask)
    ,SUM(ytd_mask * capitalizable_raw_cost * l_capital_proj_mask)
    ,SUM(ytd_mask * capitalizable_brdn_cost * l_capital_proj_mask)
    ,SUM(ytd_mask * equipment_hours)
	,SUM(ytd_mask * equipment_raw_cost)
	,SUM(ytd_mask * equipment_brdn_cost)
    ,SUM(ytd_mask * labor_raw_cost)
    ,SUM(ytd_mask * labor_brdn_cost)
    ,SUM(ytd_mask * labor_hrs)
    ,SUM(ytd_mask * labor_revenue * l_contract_proj_mask)
    ,SUM(ytd_mask * 0) --unbilled_cost
    ,SUM(ytd_mask * 0) --capitalized_cost
    ,SUM(itd_mask * sup_inv_committed_cost) -- added for 6864037
    ,SUM(itd_mask * po_committed_cost) -- added for 6864037
    ,SUM(itd_mask * pr_committed_cost) -- added for 6864037
    ,SUM(itd_mask * oth_committed_cost) -- added for 6864037
    ,SUM(itd_mask * raw_cost)
    ,SUM(itd_mask * brdn_cost)
    ,SUM(itd_mask * revenue * l_contract_proj_mask)
    ,SUM(itd_mask * bill_raw_cost * l_contract_proj_mask)
    ,SUM(itd_mask * bill_brdn_cost * l_contract_proj_mask)
    ,SUM(itd_mask * billable_equipment_hours * l_contract_proj_mask)
    ,SUM(itd_mask * bill_labor_raw_cost * l_contract_proj_mask)
    ,SUM(itd_mask * bill_labor_brdn_cost * l_contract_proj_mask)
    ,SUM(itd_mask * bill_labor_hrs * l_contract_proj_mask)
    ,SUM(itd_mask * capitalizable_raw_cost * l_capital_proj_mask)
    ,SUM(itd_mask * capitalizable_brdn_cost * l_capital_proj_mask)
    ,SUM(itd_mask * equipment_hours)
	,SUM(itd_mask * equipment_raw_cost)
	,SUM(itd_mask * equipment_brdn_cost)
    ,SUM(itd_mask * labor_raw_cost)
    ,SUM(itd_mask * labor_brdn_cost)
    ,SUM(itd_mask * labor_hrs)
    ,SUM(itd_mask * labor_revenue * l_contract_proj_mask)
    ,SUM(itd_mask * 0) --unbilled_cost
    ,SUM(itd_mask * 0) --capitalized_cost
    ,SUM(ac_mask * sup_inv_committed_cost)
    ,SUM(ac_mask * po_committed_cost)
    ,SUM(ac_mask * pr_committed_cost)
    ,SUM(ac_mask * oth_committed_cost)
    ,SUM(ac_mask * raw_cost)
    ,SUM(ac_mask * brdn_cost)
    ,SUM(ac_mask * revenue * l_contract_proj_mask)
    ,SUM(ac_mask * bill_raw_cost * l_contract_proj_mask)
    ,SUM(ac_mask * bill_brdn_cost * l_contract_proj_mask)
    ,SUM(ac_mask * billable_equipment_hours * l_contract_proj_mask)
    ,SUM(ac_mask * bill_labor_raw_cost * l_contract_proj_mask)
    ,SUM(ac_mask * bill_labor_brdn_cost * l_contract_proj_mask)
    ,SUM(ac_mask * bill_labor_hrs * l_contract_proj_mask)
    ,SUM(ac_mask * capitalizable_raw_cost * l_capital_proj_mask)
    ,SUM(ac_mask * capitalizable_brdn_cost * l_capital_proj_mask)
    ,SUM(ac_mask * equipment_hours)
	,SUM(ac_mask * equipment_raw_cost)
	,SUM(ac_mask * equipment_brdn_cost)
    ,SUM(ac_mask * labor_raw_cost)
    ,SUM(ac_mask * labor_brdn_cost)
    ,SUM(ac_mask * labor_hrs)
    ,SUM(ac_mask * labor_revenue * l_contract_proj_mask)
    ,SUM(ac_mask * 0) --unbilled_cost
    ,SUM(ac_mask * 0) --capitalized_cost
    ,SUM(ac_mask * sup_inv_committed_cost)
    ,SUM(ac_mask * po_committed_cost)
    ,SUM(ac_mask * pr_committed_cost)
    ,SUM(ac_mask * oth_committed_cost)
    ,SUM(prp_mask * raw_cost)
    ,SUM(prp_mask * brdn_cost)
    ,SUM(prp_mask * revenue * l_contract_proj_mask)
    ,SUM(prp_mask * bill_raw_cost * l_contract_proj_mask)
    ,SUM(prp_mask * bill_brdn_cost * l_contract_proj_mask)
    ,SUM(prp_mask * billable_equipment_hours * l_contract_proj_mask)
    ,SUM(prp_mask * bill_labor_raw_cost * l_contract_proj_mask)
    ,SUM(prp_mask * bill_labor_brdn_cost * l_contract_proj_mask)
    ,SUM(prp_mask * bill_labor_hrs * l_contract_proj_mask)
    ,SUM(prp_mask * capitalizable_raw_cost * l_capital_proj_mask)
    ,SUM(prp_mask * capitalizable_brdn_cost * l_capital_proj_mask)
    ,SUM(prp_mask * equipment_hours)
	,SUM(prp_mask * equipment_raw_cost)
	,SUM(prp_mask * equipment_brdn_cost)
    ,SUM(prp_mask * labor_raw_cost)
    ,SUM(prp_mask * labor_brdn_cost)
    ,SUM(prp_mask * labor_hrs)
    ,SUM(prp_mask * labor_revenue * l_contract_proj_mask)
    ,SUM(prp_mask * 0) --unbilled_cost
    ,SUM(prp_mask * 0) --capitalized_cost
    ,NULL
    ,NULL
    ,NULL
    ,NULL
    ,SUM(ptd_mask * fct.custom1)
    ,SUM(ptd_mask * fct.custom2)
    ,SUM(ptd_mask * fct.custom3)
    ,SUM(ptd_mask * fct.custom4)
    ,SUM(ptd_mask * fct.custom5)
    ,SUM(ptd_mask * fct.custom6)
    ,SUM(ptd_mask * fct.custom7)
    ,SUM(ptd_mask * fct.custom8)
    ,SUM(ptd_mask * fct.custom9)
    ,SUM(ptd_mask * fct.custom10)
    ,SUM(ptd_mask * fct.custom11)
    ,SUM(ptd_mask * fct.custom12)
    ,SUM(ptd_mask * fct.custom13)
    ,SUM(ptd_mask * fct.custom14)
    ,SUM(ptd_mask * fct.custom15)
    ,SUM(ptd_mask * fct.custom16)
    ,SUM(ptd_mask * fct.custom17)
    ,SUM(ptd_mask * fct.custom18)
    ,SUM(ptd_mask * fct.custom19)
    ,SUM(ptd_mask * fct.custom20)
    ,SUM(ptd_mask * fct.custom21)
    ,SUM(ptd_mask * fct.custom22)
    ,SUM(ptd_mask * fct.custom23)
    ,SUM(ptd_mask * fct.custom24)
    ,SUM(ptd_mask * fct.custom25)
    ,SUM(ptd_mask * fct.custom26)
    ,SUM(ptd_mask * fct.custom27)
    ,SUM(ptd_mask * fct.custom28)
    ,SUM(ptd_mask * fct.custom29)
    ,SUM(ptd_mask * fct.custom30)
    ,SUM(qtd_mask * fct.custom1)
    ,SUM(qtd_mask * fct.custom2)
    ,SUM(qtd_mask * fct.custom3)
    ,SUM(qtd_mask * fct.custom4)
    ,SUM(qtd_mask * fct.custom5)
    ,SUM(qtd_mask * fct.custom6)
    ,SUM(qtd_mask * fct.custom7)
    ,SUM(qtd_mask * fct.custom8)
    ,SUM(qtd_mask * fct.custom9)
    ,SUM(qtd_mask * fct.custom10)
    ,SUM(qtd_mask * fct.custom11)
    ,SUM(qtd_mask * fct.custom12)
    ,SUM(qtd_mask * fct.custom13)
    ,SUM(qtd_mask * fct.custom14)
    ,SUM(qtd_mask * fct.custom15)
    ,SUM(qtd_mask * fct.custom16)
    ,SUM(qtd_mask * fct.custom17)
    ,SUM(qtd_mask * fct.custom18)
    ,SUM(qtd_mask * fct.custom19)
    ,SUM(qtd_mask * fct.custom20)
    ,SUM(qtd_mask * fct.custom21)
    ,SUM(qtd_mask * fct.custom22)
    ,SUM(qtd_mask * fct.custom23)
    ,SUM(qtd_mask * fct.custom24)
    ,SUM(qtd_mask * fct.custom25)
    ,SUM(qtd_mask * fct.custom26)
    ,SUM(qtd_mask * fct.custom27)
    ,SUM(qtd_mask * fct.custom28)
    ,SUM(qtd_mask * fct.custom29)
    ,SUM(qtd_mask * fct.custom30)
    ,SUM(ytd_mask * fct.custom1)
    ,SUM(ytd_mask * fct.custom2)
    ,SUM(ytd_mask * fct.custom3)
    ,SUM(ytd_mask * fct.custom4)
    ,SUM(ytd_mask * fct.custom5)
    ,SUM(ytd_mask * fct.custom6)
    ,SUM(ytd_mask * fct.custom7)
    ,SUM(ytd_mask * fct.custom8)
    ,SUM(ytd_mask * fct.custom9)
    ,SUM(ytd_mask * fct.custom10)
    ,SUM(ytd_mask * fct.custom11)
    ,SUM(ytd_mask * fct.custom12)
    ,SUM(ytd_mask * fct.custom13)
    ,SUM(ytd_mask * fct.custom14)
    ,SUM(ytd_mask * fct.custom15)
    ,SUM(ytd_mask * fct.custom16)
    ,SUM(ytd_mask * fct.custom17)
    ,SUM(ytd_mask * fct.custom18)
    ,SUM(ytd_mask * fct.custom19)
    ,SUM(ytd_mask * fct.custom20)
    ,SUM(ytd_mask * fct.custom21)
    ,SUM(ytd_mask * fct.custom22)
    ,SUM(ytd_mask * fct.custom23)
    ,SUM(ytd_mask * fct.custom24)
    ,SUM(ytd_mask * fct.custom25)
    ,SUM(ytd_mask * fct.custom26)
    ,SUM(ytd_mask * fct.custom27)
    ,SUM(ytd_mask * fct.custom28)
    ,SUM(ytd_mask * fct.custom29)
    ,SUM(ytd_mask * fct.custom30)
    ,SUM(itd_mask * fct.custom1)
    ,SUM(itd_mask * fct.custom2)
    ,SUM(itd_mask * fct.custom3)
    ,SUM(itd_mask * fct.custom4)
    ,SUM(itd_mask * fct.custom5)
    ,SUM(itd_mask * fct.custom6)
    ,SUM(itd_mask * fct.custom7)
    ,SUM(itd_mask * fct.custom8)
    ,SUM(itd_mask * fct.custom9)
    ,SUM(itd_mask * fct.custom10)
    ,SUM(itd_mask * fct.custom11)
    ,SUM(itd_mask * fct.custom12)
    ,SUM(itd_mask * fct.custom13)
    ,SUM(itd_mask * fct.custom14)
    ,SUM(itd_mask * fct.custom15)
    ,SUM(itd_mask * fct.custom16)
    ,SUM(itd_mask * fct.custom17)
    ,SUM(itd_mask * fct.custom18)
    ,SUM(itd_mask * fct.custom19)
    ,SUM(itd_mask * fct.custom20)
    ,SUM(itd_mask * fct.custom21)
    ,SUM(itd_mask * fct.custom22)
    ,SUM(itd_mask * fct.custom23)
    ,SUM(itd_mask * fct.custom24)
    ,SUM(itd_mask * fct.custom25)
    ,SUM(itd_mask * fct.custom26)
    ,SUM(itd_mask * fct.custom27)
    ,SUM(itd_mask * fct.custom28)
    ,SUM(itd_mask * fct.custom29)
    ,SUM(itd_mask * fct.custom30)
    ,SUM(ac_mask * fct.custom1)
    ,SUM(ac_mask * fct.custom2)
    ,SUM(ac_mask * fct.custom3)
    ,SUM(ac_mask * fct.custom4)
    ,SUM(ac_mask * fct.custom5)
    ,SUM(ac_mask * fct.custom6)
    ,SUM(ac_mask * fct.custom7)
    ,SUM(ac_mask * fct.custom8)
    ,SUM(ac_mask * fct.custom9)
    ,SUM(ac_mask * fct.custom10)
    ,SUM(ac_mask * fct.custom11)
    ,SUM(ac_mask * fct.custom12)
    ,SUM(ac_mask * fct.custom13)
    ,SUM(ac_mask * fct.custom14)
    ,SUM(ac_mask * fct.custom15)
    ,SUM(ac_mask * fct.custom16)
    ,SUM(ac_mask * fct.custom17)
    ,SUM(ac_mask * fct.custom18)
    ,SUM(ac_mask * fct.custom19)
    ,SUM(ac_mask * fct.custom20)
    ,SUM(ac_mask * fct.custom21)
    ,SUM(ac_mask * fct.custom22)
    ,SUM(ac_mask * fct.custom23)
    ,SUM(ac_mask * fct.custom24)
    ,SUM(ac_mask * fct.custom25)
    ,SUM(ac_mask * fct.custom26)
    ,SUM(ac_mask * fct.custom27)
    ,SUM(ac_mask * fct.custom28)
    ,SUM(ac_mask * fct.custom29)
    ,SUM(ac_mask * fct.custom30)
    ,SUM(prp_mask * fct.custom1)
    ,SUM(prp_mask * fct.custom2)
    ,SUM(prp_mask * fct.custom3)
    ,SUM(prp_mask * fct.custom4)
    ,SUM(prp_mask * fct.custom5)
    ,SUM(prp_mask * fct.custom6)
    ,SUM(prp_mask * fct.custom7)
    ,SUM(prp_mask * fct.custom8)
    ,SUM(prp_mask * fct.custom9)
    ,SUM(prp_mask * fct.custom10)
    ,SUM(prp_mask * fct.custom11)
    ,SUM(prp_mask * fct.custom12)
    ,SUM(prp_mask * fct.custom13)
    ,SUM(prp_mask * fct.custom14)
    ,SUM(prp_mask * fct.custom15)
    ,SUM(prp_mask * fct.custom16)
    ,SUM(prp_mask * fct.custom17)
    ,SUM(prp_mask * fct.custom18)
    ,SUM(prp_mask * fct.custom19)
    ,SUM(prp_mask * fct.custom20)
    ,SUM(prp_mask * fct.custom21)
    ,SUM(prp_mask * fct.custom22)
    ,SUM(prp_mask * fct.custom23)
    ,SUM(prp_mask * fct.custom24)
    ,SUM(prp_mask * fct.custom25)
    ,SUM(prp_mask * fct.custom26)
    ,SUM(prp_mask * fct.custom27)
    ,SUM(prp_mask * fct.custom28)
    ,SUM(prp_mask * fct.custom29)
    ,SUM(prp_mask * fct.custom30)
    )
    BULK COLLECT INTO l_temp_overview_type
    FROM PJI_FP_XBS_ACCUM_F_V fct --PA_REPORTING_LINES
    , (SELECT time_id, period_type_id, pCalendarType calendar_type
         ,SIGN(bitand(record_type_id,g_ptd_record_type))  ptd_mask
         ,SIGN(bitand(record_type_id,g_qtd_record_type))  qtd_mask
         ,SIGN(bitand(record_type_id,g_ytd_record_type))  ytd_mask
         ,SIGN(bitand(record_type_id,g_itd_record_type))  itd_mask
         ,0 ac_mask
         ,0 prp_mask
       FROM
       PJI_TIME_CAL_RPT_STRUCT
       WHERE 1=1
       AND bitand(record_type_id,pTimeSlice) = record_type_id --the records above the selected slice are excluded
       AND calendar_id = pCalendarId
       AND report_date = TO_DATE(pPeriodDateJulian,l_julianFormat)
       AND pCalendarType <> l_calendarType_E
       UNION ALL
       SELECT time_id, period_type_id, pCalendarType calendar_type
         ,SIGN(bitand(record_type_id,g_ptd_record_type))  ptd_mask
         ,SIGN(bitand(record_type_id,g_qtd_record_type))  qtd_mask
         ,SIGN(bitand(record_type_id,g_ytd_record_type))  ytd_mask
         ,SIGN(bitand(record_type_id,g_itd_record_type))  itd_mask
         ,0 ac_mask
         ,0 prp_mask
       FROM
       PJI_TIME_RPT_STRUCT
       WHERE 1=1
       AND bitand(record_type_id,pTimeSlice) = record_type_id
       AND report_date = TO_DATE(pPeriodDateJulian,l_julianFormat)
       AND pCalendarType = l_calendarType_E
       UNION ALL
       -- At Completion:
       SELECT -1 time_id, 2048 period_type_id, l_calendarType_A calendar_type
         ,0 ptd_mask
         ,0 qtd_mask
         ,0 ytd_mask
         ,0 itd_mask
         ,1 ac_mask
         ,0 prp_mask
       FROM  dual
       UNION ALL
       -- Prior Period:
       SELECT cal_period_id time_id, 32 period_type_id, pCalendarType calendar_type
         ,0 ptd_mask
         ,0 qtd_mask
         ,0 ytd_mask
         ,0 itd_mask
         ,0 ac_mask
         ,1 prp_mask
       FROM
       pji_time_cal_period_V
       WHERE 1=1
       --this is the first date of the period - 1 day, so I get the previous period, otherwise i'd get the curr. period
       AND TO_DATE(pPeriodDateJulian,l_julianFormat)-1 BETWEEN start_date AND end_date
       AND calendar_id = pCalendarId
       AND pCalendarType <> l_calendarType_E
       UNION ALL
       SELECT ent_period_id time_id, 32 period_type_id, pCalendarType calendar_type
         ,0 ptd_mask
         ,0 qtd_mask
         ,0 ytd_mask
         ,0 itd_mask
         ,0 ac_mask
         ,1 prp_mask
       FROM
       pji_time_ent_period_V
       WHERE 1=1
       AND TO_DATE(pPeriodDateJulian,l_julianFormat)-1 BETWEEN start_date AND end_date
       AND pCalendarType = l_calendarType_E
       ) TIME
    WHERE 1=1
    AND fct.prg_rollup_flag IN (l_PrgRollupFlag1,l_PrgRollupFlag2)
    AND (
        (pReportType = l_reportType_TS AND fct.rbs_aggr_level = l_rbs_aggr_level_T)
       OR
    ((pReportType IN (l_reportType_TA, l_reportType_RA, l_reportType_RS)) AND (fct.rbs_aggr_level IN (l_rbs_aggr_level, l_rbs_aggr_level_L)))
        )
	AND fct.wbs_rollup_flag IN (l_WBSRollupFlag_N, pWBSRollupFlag)
    AND fct.project_id = pProjectId
    AND fct.project_element_id = pWBSElementId
    AND fct.rbs_version_id = pRBSVersionId
   	AND fct.rbs_element_id = pRBSElementId
    AND fct.currency_code = pCurrencyCode
    AND bitand(fct.curr_record_type_id,pCurrencyRecordType) = pCurrencyRecordType
    AND fct.period_type_id = TIME.period_type_id
    AND fct.time_id        = TIME.time_id
    AND (fct.calendar_type = TIME.calendar_type OR TIME.calendar_type = l_calendarType_A)
    AND fct.plan_version_id IN (
            pActualVersionId
          , pCstForecastVersionId
          , pCstBudgetVersionId
          , pCstBudget2VersionId
          , pRevForecastVersionId
          , pRevBudgetVersionId
          , pRevBudget2VersionId
          , pOrigCstForecastVersionId
          , pOrigCstBudgetVersionId
          , pOrigCstBudget2VersionId
          , pOrigRevForecastVersionId
          , pOrigRevBudgetVersionId
          , pOrigRevBudget2VersionId
          , pPriorCstForecastVersionId
          , pPriorRevForecastVersionId
		  , DECODE(fct.prg_rollup_flag, 'Y', -3,-99)
		  , DECODE(fct.prg_rollup_Flag, 'Y', -4,-99)
        )
    AND fct.plan_type_id IN (
         	-1
          , pCstForecastPlanTypeId
          , pCstBudgetPlanTypeId
          , pCstBudget2PlanTypeId
          , pRevForecastPlanTypeId
          , pRevBudgetPlanTypeId
          , pRevBudget2PlanTypeId
        )
    GROUP BY plan_version_id, fct.plan_type_id;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      -- in case no data is found, we still can go on and return empty arrays
	  IF g_debug_mode = 'Y' THEN
	      Pji_Utils.WRITE2LOG(
	        'PJI_REP_MEASURE_UTIL.retrieveData: NO_DATA_FOUND on reporting lines SQL query.',
	        TRUE, g_msg_level_low_detail
	      );
	  END IF;
    WHEN OTHERS THEN
      --
      l_sql_errm := SQLERRM();
      Pji_Rep_Util.Add_Message(p_app_short_name=>'PJI',
        p_msg_name=>'PJI_REP_GENERIC_MSG',
        p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING,
        p_token1=>'PROC_NAME',
        p_token1_value=>'PJI_REP_MEASURE_UTIL; Reporting lines facts query SQL Error: ' || l_sql_errm);

  END;


  --
  -- for every object in the collection, depending on which version_id is selected
  -- from the params, we set up as many index NUMBERs as the number of version_id
  -- input params (we have 13 version_ids):
  -- l_rev_budget_index, l_rev_budget2_index, l_rev_forecast_index, ....
  -- We use these numbers as indexes to later access the same collection and
  -- save the various values into the PTD/ITD_VALUES collections;
  -- this way we are able to know which object in the collection is related
  -- to which versionId.
  -- e.g. if we know that object at index `i' is related to pCstForecastVersionId,
  -- then we save that `i' in a var, l_cost_forecast_index.
  --

  	l_overview_type.EXTEND(13);
	FOR i IN l_overview_type.FIRST .. l_overview_type.LAST LOOP
		l_overview_type(i) := pji_rep_overview_type(NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
		NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
		);
	END LOOP;

	IF l_temp_overview_type.COUNT > 0 THEN

		FOR i IN l_temp_overview_type.FIRST..l_temp_overview_type.LAST LOOP

			IF l_temp_overview_type(i).plan_version_id = pActualVersionId THEN
				l_result_index:=l_actual_index;

				IF (bitand(g_Actual_is_present,l_check_plan_versions)<>g_Actual_is_present) THEN
				   l_check_plan_versions := g_Actual_is_present +l_check_plan_versions;
				END IF;
				Merge_Overview_Type(i, l_temp_overview_type, l_result_index, l_overview_type);
			END IF;

			IF (l_temp_overview_type(i).plan_version_id = pCstForecastVersionId
			   OR l_temp_overview_type(i).plan_version_id = -3) AND
         	   l_temp_overview_type(i).plan_type_id = pCstForecastPlanTypeId THEN
				l_result_index:=l_cost_forecast_index;
				IF (bitand(g_CstFcst_is_present ,l_check_plan_versions)<>g_CstFcst_is_present) THEN
				   l_check_plan_versions := g_CstFcst_is_present +l_check_plan_versions;
				END IF;
				Merge_Overview_Type(i, l_temp_overview_type, l_result_index, l_overview_type);
			END IF;

			IF (l_temp_overview_type(i).plan_version_id = pCstBudgetVersionId
			   OR l_temp_overview_type(i).plan_version_id = -3) AND
         	   l_temp_overview_type(i).plan_type_id = pCstBudgetPlanTypeId THEN
				l_result_index:=l_cost_budget_index;
				IF (bitand(g_CstBudget_is_present ,l_check_plan_versions)<>g_CstBudget_is_present) THEN
				   l_check_plan_versions := g_CstBudget_is_present + l_check_plan_versions;
				END IF;
				Merge_Overview_Type(i, l_temp_overview_type, l_result_index, l_overview_type);
			END IF;

			IF (l_temp_overview_type(i).plan_version_id = pCstBudget2VersionId
			   OR l_temp_overview_type(i).plan_version_id = -3) AND
         	   l_temp_overview_type(i).plan_type_id = pCstBudget2PlanTypeId THEN
				l_result_index:=l_cost_budget2_index;
				IF (bitand(g_CstBudget2_is_present ,l_check_plan_versions)<>g_CstBudget2_is_present) THEN
				   l_check_plan_versions := g_CstBudget2_is_present + l_check_plan_versions;
				END IF;
				Merge_Overview_Type(i, l_temp_overview_type, l_result_index, l_overview_type);
			END IF;

			IF (l_temp_overview_type(i).plan_version_id = pRevForecastVersionId
			   OR l_temp_overview_type(i).plan_version_id = -3) AND
         	   l_temp_overview_type(i).plan_type_id = pRevForecastPlanTypeId THEN
				l_result_index:=l_rev_forecast_index;
				IF (bitand(g_RevFcst_is_present ,l_check_plan_versions)<>g_RevFcst_is_present) THEN
				   l_check_plan_versions := g_RevFcst_is_present + l_check_plan_versions;
				END IF;
				Merge_Overview_Type(i, l_temp_overview_type, l_result_index, l_overview_type);
			END IF;

			IF (l_temp_overview_type(i).plan_version_id = pRevBudgetVersionId
			   OR l_temp_overview_type(i).plan_version_id = -3) AND
         	   l_temp_overview_type(i).plan_type_id = pRevBudgetPlanTypeId THEN
				l_result_index:=l_rev_budget_index;
				IF (bitand(g_RevBudget_is_present ,l_check_plan_versions)<>g_RevBudget_is_present) THEN
				   l_check_plan_versions := g_RevBudget_is_present + l_check_plan_versions;
				END IF;
				Merge_Overview_Type(i, l_temp_overview_type, l_result_index, l_overview_type);
			END IF;

			IF (l_temp_overview_type(i).plan_version_id = pRevBudget2VersionId
			   OR l_temp_overview_type(i).plan_version_id = -3) AND
         	   l_temp_overview_type(i).plan_type_id = pRevBudget2PlanTypeId THEN
				l_result_index:=l_rev_budget2_index;
				IF (bitand(g_RevBudget2_is_present ,l_check_plan_versions)<>g_RevBudget2_is_present) THEN
				   l_check_plan_versions := g_RevBudget2_is_present + l_check_plan_versions;
				END IF;
				Merge_Overview_Type(i, l_temp_overview_type, l_result_index, l_overview_type);
			END IF;


			IF (l_temp_overview_type(i).plan_version_id = pOrigCstBudgetVersionId
			   OR l_temp_overview_type(i).plan_version_id = -4) AND
         	   l_temp_overview_type(i).plan_type_id = pCstBudgetPlanTypeId THEN
				l_result_index:=l_orig_cost_budget_index;
				IF (bitand(g_OrigCstBudget_is_present ,l_check_plan_versions)<>g_OrigCstBudget_is_present) THEN
				   l_check_plan_versions := g_OrigCstBudget_is_present + l_check_plan_versions;
				END IF;
				Merge_Overview_Type(i, l_temp_overview_type, l_result_index, l_overview_type);
			END IF;

			IF (l_temp_overview_type(i).plan_version_id = pOrigCstBudget2VersionId
			   OR l_temp_overview_type(i).plan_version_id = -4) AND
			   l_temp_overview_type(i).plan_type_id = pCstBudget2PlanTypeId THEN
				l_result_index:=l_orig_cost_budget2_index;
				IF (bitand(g_OrigCstBudget2_is_present ,l_check_plan_versions)<>g_OrigCstBudget2_is_present) THEN
				   l_check_plan_versions := g_OrigCstBudget2_is_present + l_check_plan_versions;
				END IF;
				Merge_Overview_Type(i, l_temp_overview_type, l_result_index, l_overview_type);
			END IF;

		    IF (l_temp_overview_type(i).plan_version_id = pOrigRevBudgetVersionId
			   OR l_temp_overview_type(i).plan_version_id = -4) AND
		       l_temp_overview_type(i).plan_type_id = pRevBudgetPlanTypeId THEN
		        l_result_index:=l_orig_rev_budget_index;
				IF (bitand(g_OrigRevBudget_is_present ,l_check_plan_versions)<>g_OrigRevBudget_is_present) THEN
				   l_check_plan_versions := g_OrigRevBudget_is_present + l_check_plan_versions;
				END IF;
				Merge_Overview_Type(i, l_temp_overview_type, l_result_index, l_overview_type);
			END IF;

			IF (l_temp_overview_type(i).plan_version_id = pOrigRevBudget2VersionId
			   OR l_temp_overview_type(i).plan_version_id = -4) AND
			   l_temp_overview_type(i).plan_type_id = pRevBudget2PlanTypeId THEN
				l_result_index:=l_orig_rev_budget2_index;
				IF (bitand(g_OrigRevBudget2_is_present ,l_check_plan_versions)<>g_OrigRevBudget2_is_present) THEN
				   l_check_plan_versions := g_OrigRevBudget2_is_present + l_check_plan_versions;
				END IF;
				Merge_Overview_Type(i, l_temp_overview_type, l_result_index, l_overview_type);
			END IF;

	      IF l_temp_overview_type(i).plan_version_id = pPriorCstForecastVersionId AND
	         l_temp_overview_type(i).plan_type_id = pCstForecastPlanTypeId THEN
	         	l_result_index:=l_prior_cost_forecast_index;
				l_check_plan_versions := g_CstPriorfcst_is_present + l_check_plan_versions;
				Merge_Overview_Type(i, l_temp_overview_type, l_result_index, l_overview_type);
	      END IF;

	      IF l_temp_overview_type(i).plan_version_id = pPriorRevForecastVersionId AND
	         l_temp_overview_type(i).plan_type_id = pRevForecastPlanTypeId THEN
	         	l_result_index:=l_prior_rev_forecast_index;
				l_check_plan_versions := g_RevPriorfcst_is_present + l_check_plan_versions;
				Merge_Overview_Type(i, l_temp_overview_type, l_result_index, l_overview_type);
	      END IF;

		END LOOP;

	END IF;


  --
  -- we shift the entire collection one place to the right
  -- to leave the first cell empty to use when there isn't an available plan type
  --

  IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG(
	    'PJI_REP_MEASURE_UTIL.retrieveData: project_id= ' || pProjectId ||
	    '; plan versions info: l_actual_index= ' || l_actual_index ||
	    '; l_cost_forecast_index= ' || l_cost_forecast_index ||
	    '; l_cost_budget_index= '   || l_cost_budget_index   ||
	    '; l_cost_budget2_index= '  || l_cost_budget2_index  ||
	    '; l_rev_forecast_index= ' || l_rev_forecast_index ||
	    '; l_rev_budget_index= '   || l_rev_budget_index   ||
	    '; l_rev_budget2_index= '  || l_rev_budget2_index  ||
	    '; l_overview_type collection length:= '  || l_overview_type.LAST,
	    TRUE, g_msg_level_runtime_info
	  );
  END IF;
  --
  -- collect and summarize the status of all plan versions into a single bit array (a NUMBER)
  --


  -- ########### DEBUG BEGIN ##################################################
  /*
  FOR i IN 1..(l_overview_type.LAST) LOOP
    dbms_output.put_line('## record: ' || i);
    dbms_output.put_line('type.itd_bill_burdened_cost='||l_overview_type(i).itd_bill_burdened_cost);
    dbms_output.put_line('type.itd_burdened_cost='||l_overview_type(i).itd_burdened_cost);
  END LOOP;
  dbms_output.put_line('-----\nl_check_plan_versions: ' || l_check_plan_versions);
  */
  -- ########### DEBUG END ####################################################


  --
	-- Similar logic for activity based facts
	--
  BEGIN

    SELECT
     SUM(ptd_mask * fct.active_backlog)
    ,SUM(ptd_mask * fct.additional_funding_amount)
    ,SUM(ptd_mask * fct.ar_cash_applied_amount)
    ,SUM(ptd_mask * fct.ar_credit_memo_amount)
    ,SUM(ptd_mask * fct.ar_invoice_amount)
    ,SUM(ptd_mask * fct.ar_invoice_write_off_amount)
    ,SUM(ptd_mask * fct.ar_invoice_count)
    ,SUM(ptd_mask * fct.ar_amount_due)
    ,SUM(ptd_mask * fct.ar_amount_overdue)
    ,SUM(ptd_mask * fct.cancelled_funding_amount)
    ,SUM(ptd_mask * fct.dormant_backlog_inactiv)
    ,SUM(ptd_mask * fct.dormant_backlog_start)
    ,SUM(ptd_mask * fct.funding_adjustment_amount)
    ,SUM(ptd_mask * fct.initial_funding_amount)
    ,SUM(ptd_mask * fct.lost_backlog)
    ,SUM(ptd_mask * fct.revenue * l_contract_proj_mask)
    ,SUM(ptd_mask * fct.revenue_at_risk * l_contract_proj_mask)
    ,SUM(ptd_mask * fct.revenue_writeoff)
    ,SUM(ptd_mask * fct.unbilled_receivables)
    ,SUM(ptd_mask * fct.unearned_revenue)
    ,SUM(qtd_mask * fct.active_backlog)
    ,SUM(qtd_mask * fct.additional_funding_amount)
    ,SUM(qtd_mask * fct.ar_cash_applied_amount)
    ,SUM(qtd_mask * fct.ar_credit_memo_amount)
    ,SUM(qtd_mask * fct.ar_invoice_amount)
    ,SUM(qtd_mask * fct.ar_invoice_write_off_amount)
    ,SUM(qtd_mask * fct.ar_invoice_count)
    ,SUM(qtd_mask * fct.ar_amount_due)
    ,SUM(qtd_mask * fct.ar_amount_overdue)
    ,SUM(qtd_mask * fct.cancelled_funding_amount)
    ,SUM(qtd_mask * fct.dormant_backlog_inactiv)
    ,SUM(qtd_mask * fct.dormant_backlog_start)
    ,SUM(qtd_mask * fct.funding_adjustment_amount)
    ,SUM(qtd_mask * fct.initial_funding_amount)
    ,SUM(qtd_mask * fct.lost_backlog)
    ,SUM(qtd_mask * fct.revenue * l_contract_proj_mask)
    ,SUM(qtd_mask * fct.revenue_at_risk * l_contract_proj_mask)
    ,SUM(qtd_mask * fct.revenue_writeoff)
    ,SUM(qtd_mask * fct.unbilled_receivables)
    ,SUM(qtd_mask * fct.unearned_revenue)
    ,SUM(ytd_mask * fct.active_backlog)
    ,SUM(ytd_mask * fct.additional_funding_amount)
    ,SUM(ytd_mask * fct.ar_cash_applied_amount)
    ,SUM(ytd_mask * fct.ar_credit_memo_amount)
    ,SUM(ytd_mask * fct.ar_invoice_amount)
    ,SUM(ytd_mask * fct.ar_invoice_write_off_amount)
    ,SUM(ytd_mask * fct.ar_invoice_count)
    ,SUM(ytd_mask * fct.ar_amount_due)
    ,SUM(ytd_mask * fct.ar_amount_overdue)
    ,SUM(ytd_mask * fct.cancelled_funding_amount)
    ,SUM(ytd_mask * fct.dormant_backlog_inactiv)
    ,SUM(ytd_mask * fct.dormant_backlog_start)
    ,SUM(ytd_mask * fct.funding_adjustment_amount)
    ,SUM(ytd_mask * fct.initial_funding_amount)
    ,SUM(ytd_mask * fct.lost_backlog)
    ,SUM(ytd_mask * fct.revenue * l_contract_proj_mask)
    ,SUM(ytd_mask * fct.revenue_at_risk * l_contract_proj_mask)
    ,SUM(ytd_mask * fct.revenue_writeoff)
    ,SUM(ytd_mask * fct.unbilled_receivables)
    ,SUM(ytd_mask * fct.unearned_revenue)
    ,SUM(itd_mask * fct.active_backlog)
    ,SUM(itd_mask * fct.additional_funding_amount)
    ,SUM(itd_mask * fct.ar_cash_applied_amount)
    ,SUM(itd_mask * fct.ar_credit_memo_amount)
    ,SUM(itd_mask * fct.ar_invoice_amount)
    ,SUM(itd_mask * fct.ar_invoice_write_off_amount)
    ,SUM(itd_mask * fct.ar_invoice_count)
    ,SUM(itd_mask * fct.ar_amount_due)
    ,SUM(itd_mask * fct.ar_amount_overdue)
    ,SUM(itd_mask * fct.cancelled_funding_amount)
    ,SUM(itd_mask * fct.dormant_backlog_inactiv)
    ,SUM(itd_mask * fct.dormant_backlog_start)
    ,SUM(itd_mask * fct.funding_adjustment_amount)
    ,SUM(itd_mask * fct.initial_funding_amount)
    ,SUM(itd_mask * fct.lost_backlog)
    ,SUM(itd_mask * fct.revenue * l_contract_proj_mask)
    ,SUM(itd_mask * fct.revenue_at_risk * l_contract_proj_mask)
    ,SUM(itd_mask * fct.revenue_writeoff)
    ,SUM(itd_mask * fct.unbilled_receivables)
    ,SUM(itd_mask * fct.unearned_revenue)
    ,SUM(ac_mask * fct.active_backlog)
    ,SUM(ac_mask * fct.additional_funding_amount)
    ,SUM(ac_mask * fct.ar_cash_applied_amount)
    ,SUM(ac_mask * fct.ar_credit_memo_amount)
    ,SUM(ac_mask * fct.ar_invoice_amount)
    ,SUM(ac_mask * fct.ar_invoice_write_off_amount)
    ,SUM(ac_mask * fct.ar_invoice_count)
    ,SUM(ac_mask * fct.ar_amount_due)
    ,SUM(ac_mask * fct.ar_amount_overdue)
    ,SUM(ac_mask * fct.cancelled_funding_amount)
    ,SUM(ac_mask * fct.dormant_backlog_inactiv)
    ,SUM(ac_mask * fct.dormant_backlog_start)
    ,SUM(ac_mask * fct.funding_adjustment_amount)
    ,SUM(ac_mask * fct.initial_funding_amount)
    ,SUM(ac_mask * fct.lost_backlog)
    ,SUM(ac_mask * fct.revenue * l_contract_proj_mask)
    ,SUM(ac_mask * fct.revenue_at_risk * l_contract_proj_mask)
    ,SUM(ac_mask * fct.revenue_writeoff)
    ,SUM(ac_mask * fct.unbilled_receivables)
    ,SUM(ac_mask * fct.unearned_revenue)
    ,SUM(prp_mask * fct.active_backlog)
    ,SUM(prp_mask * fct.additional_funding_amount)
    ,SUM(prp_mask * fct.ar_cash_applied_amount)
    ,SUM(prp_mask * fct.ar_credit_memo_amount)
    ,SUM(prp_mask * fct.ar_invoice_amount)
    ,SUM(prp_mask * fct.ar_invoice_write_off_amount)
    ,SUM(prp_mask * fct.ar_invoice_count)
    ,SUM(prp_mask * fct.ar_amount_due)
    ,SUM(prp_mask * fct.ar_amount_overdue)
    ,SUM(prp_mask * fct.cancelled_funding_amount)
    ,SUM(prp_mask * fct.dormant_backlog_inactiv)
    ,SUM(prp_mask * fct.dormant_backlog_start)
    ,SUM(prp_mask * fct.funding_adjustment_amount)
    ,SUM(prp_mask * fct.initial_funding_amount)
    ,SUM(prp_mask * fct.lost_backlog)
    ,SUM(prp_mask * fct.revenue * l_contract_proj_mask)
    ,SUM(prp_mask * fct.revenue_at_risk * l_contract_proj_mask)
    ,SUM(prp_mask * fct.revenue_writeoff)
    ,SUM(prp_mask * fct.unbilled_receivables)
    ,SUM(prp_mask * fct.unearned_revenue)
    ,SUM(ptd_mask * fct.custom1)
    ,SUM(ptd_mask * fct.custom2)
    ,SUM(ptd_mask * fct.custom3)
    ,SUM(ptd_mask * fct.custom4)
    ,SUM(ptd_mask * fct.custom5)
    ,SUM(ptd_mask * fct.custom6)
    ,SUM(ptd_mask * fct.custom7)
    ,SUM(ptd_mask * fct.custom8)
    ,SUM(ptd_mask * fct.custom9)
    ,SUM(ptd_mask * fct.custom10)
    ,SUM(ptd_mask * fct.custom11)
    ,SUM(ptd_mask * fct.custom12)
    ,SUM(ptd_mask * fct.custom13)
    ,SUM(ptd_mask * fct.custom14)
    ,SUM(ptd_mask * fct.custom15)
    ,SUM(ptd_mask * fct.custom16)
    ,SUM(ptd_mask * fct.custom17)
    ,SUM(ptd_mask * fct.custom18)
    ,SUM(ptd_mask * fct.custom19)
    ,SUM(ptd_mask * fct.custom20)
    ,SUM(ptd_mask * fct.custom21)
    ,SUM(ptd_mask * fct.custom22)
    ,SUM(ptd_mask * fct.custom23)
    ,SUM(ptd_mask * fct.custom24)
    ,SUM(ptd_mask * fct.custom25)
    ,SUM(ptd_mask * fct.custom26)
    ,SUM(ptd_mask * fct.custom27)
    ,SUM(ptd_mask * fct.custom28)
    ,SUM(ptd_mask * fct.custom29)
    ,SUM(ptd_mask * fct.custom30)
    ,SUM(qtd_mask * fct.custom1)
    ,SUM(qtd_mask * fct.custom2)
    ,SUM(qtd_mask * fct.custom3)
    ,SUM(qtd_mask * fct.custom4)
    ,SUM(qtd_mask * fct.custom5)
    ,SUM(qtd_mask * fct.custom6)
    ,SUM(qtd_mask * fct.custom7)
    ,SUM(qtd_mask * fct.custom8)
    ,SUM(qtd_mask * fct.custom9)
    ,SUM(qtd_mask * fct.custom10)
    ,SUM(qtd_mask * fct.custom11)
    ,SUM(qtd_mask * fct.custom12)
    ,SUM(qtd_mask * fct.custom13)
    ,SUM(qtd_mask * fct.custom14)
    ,SUM(qtd_mask * fct.custom15)
    ,SUM(qtd_mask * fct.custom16)
    ,SUM(qtd_mask * fct.custom17)
    ,SUM(qtd_mask * fct.custom18)
    ,SUM(qtd_mask * fct.custom19)
    ,SUM(qtd_mask * fct.custom20)
    ,SUM(qtd_mask * fct.custom21)
    ,SUM(qtd_mask * fct.custom22)
    ,SUM(qtd_mask * fct.custom23)
    ,SUM(qtd_mask * fct.custom24)
    ,SUM(qtd_mask * fct.custom25)
    ,SUM(qtd_mask * fct.custom26)
    ,SUM(qtd_mask * fct.custom27)
    ,SUM(qtd_mask * fct.custom28)
    ,SUM(qtd_mask * fct.custom29)
    ,SUM(qtd_mask * fct.custom30)
    ,SUM(ytd_mask * fct.custom1)
    ,SUM(ytd_mask * fct.custom2)
    ,SUM(ytd_mask * fct.custom3)
    ,SUM(ytd_mask * fct.custom4)
    ,SUM(ytd_mask * fct.custom5)
    ,SUM(ytd_mask * fct.custom6)
    ,SUM(ytd_mask * fct.custom7)
    ,SUM(ytd_mask * fct.custom8)
    ,SUM(ytd_mask * fct.custom9)
    ,SUM(ytd_mask * fct.custom10)
    ,SUM(ytd_mask * fct.custom11)
    ,SUM(ytd_mask * fct.custom12)
    ,SUM(ytd_mask * fct.custom13)
    ,SUM(ytd_mask * fct.custom14)
    ,SUM(ytd_mask * fct.custom15)
    ,SUM(ytd_mask * fct.custom16)
    ,SUM(ytd_mask * fct.custom17)
    ,SUM(ytd_mask * fct.custom18)
    ,SUM(ytd_mask * fct.custom19)
    ,SUM(ytd_mask * fct.custom20)
    ,SUM(ytd_mask * fct.custom21)
    ,SUM(ytd_mask * fct.custom22)
    ,SUM(ytd_mask * fct.custom23)
    ,SUM(ytd_mask * fct.custom24)
    ,SUM(ytd_mask * fct.custom25)
    ,SUM(ytd_mask * fct.custom26)
    ,SUM(ytd_mask * fct.custom27)
    ,SUM(ytd_mask * fct.custom28)
    ,SUM(ytd_mask * fct.custom29)
    ,SUM(ytd_mask * fct.custom30)
    ,SUM(itd_mask * fct.custom1)
    ,SUM(itd_mask * fct.custom2)
    ,SUM(itd_mask * fct.custom3)
    ,SUM(itd_mask * fct.custom4)
    ,SUM(itd_mask * fct.custom5)
    ,SUM(itd_mask * fct.custom6)
    ,SUM(itd_mask * fct.custom7)
    ,SUM(itd_mask * fct.custom8)
    ,SUM(itd_mask * fct.custom9)
    ,SUM(itd_mask * fct.custom10)
    ,SUM(itd_mask * fct.custom11)
    ,SUM(itd_mask * fct.custom12)
    ,SUM(itd_mask * fct.custom13)
    ,SUM(itd_mask * fct.custom14)
    ,SUM(itd_mask * fct.custom15)
    ,SUM(itd_mask * fct.custom16)
    ,SUM(itd_mask * fct.custom17)
    ,SUM(itd_mask * fct.custom18)
    ,SUM(itd_mask * fct.custom19)
    ,SUM(itd_mask * fct.custom20)
    ,SUM(itd_mask * fct.custom21)
    ,SUM(itd_mask * fct.custom22)
    ,SUM(itd_mask * fct.custom23)
    ,SUM(itd_mask * fct.custom24)
    ,SUM(itd_mask * fct.custom25)
    ,SUM(itd_mask * fct.custom26)
    ,SUM(itd_mask * fct.custom27)
    ,SUM(itd_mask * fct.custom28)
    ,SUM(itd_mask * fct.custom29)
    ,SUM(itd_mask * fct.custom30)
    ,SUM(ac_mask * fct.custom1)
    ,SUM(ac_mask * fct.custom2)
    ,SUM(ac_mask * fct.custom3)
    ,SUM(ac_mask * fct.custom4)
    ,SUM(ac_mask * fct.custom5)
    ,SUM(ac_mask * fct.custom6)
    ,SUM(ac_mask * fct.custom7)
    ,SUM(ac_mask * fct.custom8)
    ,SUM(ac_mask * fct.custom9)
    ,SUM(ac_mask * fct.custom10)
    ,SUM(ac_mask * fct.custom11)
    ,SUM(ac_mask * fct.custom12)
    ,SUM(ac_mask * fct.custom13)
    ,SUM(ac_mask * fct.custom14)
    ,SUM(ac_mask * fct.custom15)
    ,SUM(ac_mask * fct.custom16)
    ,SUM(ac_mask * fct.custom17)
    ,SUM(ac_mask * fct.custom18)
    ,SUM(ac_mask * fct.custom19)
    ,SUM(ac_mask * fct.custom20)
    ,SUM(ac_mask * fct.custom21)
    ,SUM(ac_mask * fct.custom22)
    ,SUM(ac_mask * fct.custom23)
    ,SUM(ac_mask * fct.custom24)
    ,SUM(ac_mask * fct.custom25)
    ,SUM(ac_mask * fct.custom26)
    ,SUM(ac_mask * fct.custom27)
    ,SUM(ac_mask * fct.custom28)
    ,SUM(ac_mask * fct.custom29)
    ,SUM(ac_mask * fct.custom30)
    ,SUM(prp_mask * fct.custom1)
    ,SUM(prp_mask * fct.custom2)
    ,SUM(prp_mask * fct.custom3)
    ,SUM(prp_mask * fct.custom4)
    ,SUM(prp_mask * fct.custom5)
    ,SUM(prp_mask * fct.custom6)
    ,SUM(prp_mask * fct.custom7)
    ,SUM(prp_mask * fct.custom8)
    ,SUM(prp_mask * fct.custom9)
    ,SUM(prp_mask * fct.custom10)
    ,SUM(prp_mask * fct.custom11)
    ,SUM(prp_mask * fct.custom12)
    ,SUM(prp_mask * fct.custom13)
    ,SUM(prp_mask * fct.custom14)
    ,SUM(prp_mask * fct.custom15)
    ,SUM(prp_mask * fct.custom16)
    ,SUM(prp_mask * fct.custom17)
    ,SUM(prp_mask * fct.custom18)
    ,SUM(prp_mask * fct.custom19)
    ,SUM(prp_mask * fct.custom20)
    ,SUM(prp_mask * fct.custom21)
    ,SUM(prp_mask * fct.custom22)
    ,SUM(prp_mask * fct.custom23)
    ,SUM(prp_mask * fct.custom24)
    ,SUM(prp_mask * fct.custom25)
    ,SUM(prp_mask * fct.custom26)
    ,SUM(prp_mask * fct.custom27)
    ,SUM(prp_mask * fct.custom28)
    ,SUM(prp_mask * fct.custom29)
    ,SUM(prp_mask * fct.custom30)
    INTO l_pji_facts
	  FROM PJI_AC_XBS_ACCUM_F_V fct
	  ,(SELECT time_id, period_type_id, pCalendarType calendar_type
             ,SIGN(bitand(record_type_id,g_ptd_record_type))  ptd_mask
             ,SIGN(bitand(record_type_id,g_qtd_record_type))  qtd_mask
             ,SIGN(bitand(record_type_id,g_ytd_record_type))  ytd_mask
             ,SIGN(bitand(record_type_id,g_itd_record_type)) itd_mask
             ,0 ac_mask
             ,0 prp_mask
      FROM
      PJI_TIME_CAL_RPT_STRUCT
      WHERE 1=1
      AND bitand(record_type_id,pTimeSlice) = record_type_id
      AND calendar_id = pCalendarId
      AND report_date = TO_DATE(pPeriodDateJulian,l_julianFormat)
      AND pCalendarType <> l_calendarType_E
      UNION ALL
      SELECT time_id, period_type_id, pCalendarType
               ,SIGN(bitand(record_type_id,g_ptd_record_type))  ptd_mask
               ,SIGN(bitand(record_type_id,g_qtd_record_type))  qtd_mask
               ,SIGN(bitand(record_type_id,g_ytd_record_type))  ytd_mask
               ,SIGN(bitand(record_type_id,g_itd_record_type)) itd_mask
               ,0 ac_mask
               ,0 prp_mask
      FROM
      PJI_TIME_RPT_STRUCT
      WHERE 1=1
      AND bitand(record_type_id,pTimeSlice) = record_type_id
      AND report_date = TO_DATE(pPeriodDateJulian,l_julianFormat)
      AND pCalendarType = l_calendarType_E
      UNION ALL
      -- at completion
      SELECT -1 time_id, 2048 period_type_id, l_calendarType_A calendar_type
            ,0 ptd_mask
            ,0 qtd_mask
            ,0 ytd_mask
            ,0 itd_mask
            ,1 ac_mask
            ,0 prp_mask
      FROM  dual
      UNION ALL
      -- prior period
      SELECT cal_period_id time_id, 32 period_type_id, pCalendarType calendar_type
        ,0 ptd_mask
        ,0 qtd_mask
        ,0 ytd_mask
        ,0 itd_mask
        ,0 ac_mask
        ,1 prp_mask
      FROM
      pji_time_cal_period_V
      WHERE 1=1
      AND TO_DATE(pPeriodDateJulian,l_julianFormat)-1 BETWEEN start_date AND end_date -- report_date
      AND calendar_id = pCalendarId
      AND pCalendarType <> l_calendarType_E
      UNION ALL
      SELECT ent_period_id time_id, 32 period_type_id, pCalendarType calendar_type
        ,0 ptd_mask
        ,0 qtd_mask
        ,0 ytd_mask
        ,0 itd_mask
        ,0 ac_mask
        ,1 prp_mask
      FROM
      pji_time_ent_period_V
      WHERE 1=1
      AND TO_DATE(pPeriodDateJulian,l_julianFormat)-1 BETWEEN start_date AND end_date -- report_date
      AND pCalendarType = l_calendarType_E
      ) TIME
	  WHERE 1=1
    AND fct.project_id = pProjectId
    AND fct.project_element_id = pWBSElementId
    AND fct.currency_code = pCurrencyCode
    AND bitand(fct.curr_record_type_id,pCurrencyRecordType) = pCurrencyRecordType
    AND fct.prg_rollup_flag IN (l_PrgRollupFlag1,l_PrgRollupFlag2)
    AND fct.time_id        = TIME.time_id
    AND fct.period_type_id = TIME.period_type_id
    AND (fct.calendar_type = TIME.calendar_type OR TIME.calendar_type = l_calendarType_A);

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      -- in case no data is found, we still can go on and eventually return empty arrays
      l_pji_facts := l_pji_facts_null;

    WHEN OTHERS THEN
      l_sql_errm := SQLERRM();
      Pji_Rep_Util.Add_Message(
        p_app_short_name=>'PJI',
        p_msg_name=> 'PJI_REP_GENERIC_MSG',
        p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING,
        p_token1=>'PROC_NAME',
        p_token1_value=>'PJI_REP_MEASURE_UTIL; activity facts query SQL Error: ' || l_sql_errm);
  END;

  --
  -- need to consider the rollup element
  --
/*
  BEGIN
    SELECT completed_percentage/100
    INTO l_completed_percentage
    FROM pji_rep_xbs_denorm
    WHERE project_id = pProjectId
    --AND parent_element_id = pWBSElementId
    AND child_element_id  = pWBSElementId
    AND rollup_flag = 'Y'
    AND wbs_version_id = pWBSVersionId;
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      l_completed_percentage := NULL;
      x_return_status := Pji_Rep_Util.G_RET_STS_WARNING;
      Pji_Rep_Util.Add_Message(p_app_short_name=>'PJI',
                               p_msg_name=>'PJI_REP_INVALID_COMPLETED_PERC',
                               p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING);
    WHEN OTHERS THEN
      l_completed_percentage := NULL;
  END;
*/
	Pji_Rep_Util.Derive_Percent_Complete(pProjectId,
  									   pWBSVersionId,
									   pWBSElementId,
									   'Y',
									   pPeriodDateJulian,
									   'FINANCIAL',
									   pCalendarType,
									   pCalendarId,
									   pPrgRollup,
									   l_completed_percentage,
									   x_return_status,
									   x_msg_count,
									   x_msg_data);

  l_completed_percentage := l_completed_percentage/100;
  --
  -- Planned WORK Quantity.
 	-- Currently we don't do PLanned Work quantity
  --
  BEGIN
    SELECT
      wq_planned_quantity
      , wq_planned_quantity
      , wq_planned_quantity
      , wq_planned_quantity
      , wq_planned_quantity
      , wq_planned_quantity
    INTO l_planned_work_qt
    FROM pa_proj_elem_ver_schedule
    WHERE project_id = pProjectId
    AND calendar_id = pCalendarId
    AND element_version_id = pWBSElementId;
  EXCEPTION
    -- since we don't do work quantity, we simply swallow these errors
    WHEN OTHERS THEN
      l_planned_work_qt := l_amt_over_time_null;
  END;



  --
  -- Note:
 	-- Currently we don't do planned Work quantity related measures
  --
  BEGIN
    SELECT
      wq_planned_quantity
      , wq_planned_quantity
      , wq_planned_quantity
      , wq_planned_quantity
      , wq_planned_quantity
      , wq_planned_quantity
    INTO l_incr_work_qt
    FROM
      pa_proj_elem_ver_schedule   pevs
      , pa_percent_completes      pc
    WHERE pevs.project_id = pProjectId
    AND calendar_id = pCalendarId
    AND element_version_id = pWBSElementId
    AND pevs.project_id = pc.project_id
    AND pc.object_type = 'PA_TASKS'
    AND pc.published_flag = 'Y'
    AND pc.OBJECT_VERSION_ID = pWBSElementId;
  EXCEPTION
    -- since we don't do work quantity, we simply swallow these errors
    WHEN OTHERS THEN
      l_incr_work_qt := l_amt_over_time_null;
  END;


  --
  -- calculate the number of days since inception to date
  --
  BEGIN
    SELECT
      report_date.end_date - start_date +1
      , org_id
    INTO
      xDaysSinceITD
      , l_org_id
    FROM pa_projects_all,
	( SELECT end_date
      FROM pji_time_ent_period_v
      WHERE 1=1
      AND TO_DATE(pPeriodDateJulian,'j') BETWEEN start_date AND end_date
      AND pCalendarType = 'E'
      UNION ALL
      SELECT end_date
      FROM pji_time_cal_period_v
      WHERE 1=1
      AND (TO_DATE(pPeriodDateJulian,'j') BETWEEN start_date AND end_date)
      AND calendar_id = pCalendarId
      AND pCalendarType <> 'E'
	 ) report_date
    WHERE project_id = pProjectId;

  EXCEPTION
    WHEN OTHERS THEN
      xDaysSinceITD := NULL;
      l_org_id := 458; -- PJI default
  END;


  --
  -- calculate the number of days in the period
  --
  BEGIN
    SELECT days
    INTO xDaysInPeriod
    FROM (
      SELECT (end_date - start_date+1) days
      FROM pji_time_ent_period_v
      WHERE 1=1
      AND TO_DATE(pPeriodDateJulian,'j') BETWEEN start_date AND end_date
      AND pCalendarType = 'E'
      UNION ALL
      SELECT (end_date - start_date+1) days
      FROM pji_time_cal_period_v
      WHERE 1=1
      AND (TO_DATE(pPeriodDateJulian,'j') BETWEEN start_date AND end_date)
      AND calendar_id = pCalendarId
      AND pCalendarType <> 'E'
    );
  EXCEPTION
    --
    --WHEN NO_DATA_FOUND THEN
    --  xDaysInPeriod := 0;
    --  x_return_status := Pji_Rep_Util.G_RET_STS_WARNING;
    --  Pji_Rep_Util.Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_INVALID_TIME_DIMENSION',p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING);
    --WHEN TOO_MANY_ROWS THEN
    --  xDaysInPeriod := 0;
    --  x_return_status := Pji_Rep_Util.G_RET_STS_WARNING;
    --  Pji_Rep_Util.Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_INVALID_TIME_DIMENSION',p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING);
    --
    WHEN OTHERS THEN
      xDaysInPeriod := NULL;
      --x_return_status := Pji_Rep_Util.G_RET_STS_WARNING;
      --Pji_Rep_Util.Add_Message(p_app_short_name=> 'PJI',p_msg_name=> 'PJI_REP_INVALID_TIME_DIMENSION',p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING);
  END;


  --
  -- get the HTML code for the color indicators for each PTD measure
  --

  ptd_measure_ids_tbl := SYSTEM.PA_NUM_TBL_TYPE();
  ptd_measure_ids_tbl.EXTEND(p_measure_set_code.LAST);
  qtd_measure_ids_tbl := SYSTEM.PA_NUM_TBL_TYPE();
  qtd_measure_ids_tbl.EXTEND(p_measure_set_code.LAST);
  ytd_measure_ids_tbl := SYSTEM.PA_NUM_TBL_TYPE();
  ytd_measure_ids_tbl.EXTEND(p_measure_set_code.LAST);
  itd_measure_ids_tbl := SYSTEM.PA_NUM_TBL_TYPE();
  itd_measure_ids_tbl.EXTEND(p_measure_set_code.LAST);
  ac_measure_ids_tbl  := SYSTEM.PA_NUM_TBL_TYPE();
  ac_measure_ids_tbl.EXTEND(p_measure_set_code.LAST);
  prp_measure_ids_tbl := SYSTEM.PA_NUM_TBL_TYPE();
  prp_measure_ids_tbl.EXTEND(p_measure_set_code.LAST);


  --
  -- derive the measure IDs for all the input measure set codes
  --

  IF pCallingType = g_Prepare THEN

	  IF (pPrgRollup <> 'Y') THEN
	  	  -- this query condition has to be the same with the mesaure_set_code query in preparedata
		  SELECT
		   MAX(DECODE (XTD_TYPE,'PTD',m.MEASURE_ID,NULL)),
		   MAX(DECODE (XTD_TYPE,'QTD',m.MEASURE_ID,NULL)),
		   MAX(DECODE (XTD_TYPE,'YTD',m.MEASURE_ID,NULL)),
		   MAX(DECODE (XTD_TYPE,'ITD',m.MEASURE_ID,NULL)),
		   MAX(DECODE (XTD_TYPE,'AC',m.MEASURE_ID,NULL)),
		   MAX(DECODE (XTD_TYPE,'PRP',m.MEASURE_ID,NULL))
		  BULK COLLECT INTO
		       ptd_measure_ids_tbl
		     , qtd_measure_ids_tbl
		     , ytd_measure_ids_tbl
		     , itd_measure_ids_tbl
		     , ac_measure_ids_tbl
		     , prp_measure_ids_tbl
		  FROM
		    pji_mt_measures_b  m,
			pji_mt_measure_sets_b S
		  WHERE 1=1
		   AND m.measure_set_code = S.measure_set_code
		   AND S.measure_set_type IN ('SEEDED', 'CUSTOM_STORED', 'CUSTOM_CALC')
		   AND m.measure_set_code LIKE 'PPF%'
		   GROUP BY m.measure_set_code
		   ORDER BY m.measure_set_code;

		  x_ptd_html := Pa_Perf_Excp_Utils.get_measure_indicator_list('PA_PROJECTS',
		                  pProjectId, ptd_measure_ids_tbl, pCalendarType, pPeriodName, p_raw_text_flag,x_ptd_trans_id,x_ptd_meaning);
		 /* Changes for Bug 6914287 starts */
		  x_qtd_html := Pa_Perf_Excp_Utils.get_measure_indicator_list('PA_PROJECTS',
		                  pProjectId, qtd_measure_ids_tbl, pCalendarType, pPeriodName, p_raw_text_flag,x_qtd_trans_id,x_qtd_meaning);

		  x_ytd_html := Pa_Perf_Excp_Utils.get_measure_indicator_list('PA_PROJECTS',
		                  pProjectId, ytd_measure_ids_tbl, pCalendarType, pPeriodName, p_raw_text_flag,x_ytd_trans_id,x_ytd_meaning);
		/* Changes for Bug 6914287 ends */
		  x_itd_html := Pa_Perf_Excp_Utils.get_measure_indicator_list('PA_PROJECTS',
		                  pProjectId, itd_measure_ids_tbl, pCalendarType, pPeriodName, p_raw_text_flag,x_itd_trans_id,x_itd_meaning);

		  x_ac_html := Pa_Perf_Excp_Utils.get_measure_indicator_list('PA_PROJECTS',
		                  pProjectId, ac_measure_ids_tbl, pCalendarType, pPeriodName, p_raw_text_flag,x_ac_trans_id,x_ac_meaning);

		/*  x_prp_html := Pa_Perf_Excp_Utils.get_measure_indicator_list('PA_PROJECTS',
		                  pProjectId, prp_measure_ids_tbl, pCalendarType, l_period_name, p_raw_text_flag,x_prp_trans_id,l_temp_excp_meaning);
		*/
	END IF;
  ELSIF pCallingType = g_ProjList THEN
	  x_exception_indicator_tbl := Pa_Perf_Excp_Utils.get_measure_indicator_list('PA_PROJECTS',
	                  pProjectId, p_measure_id_tbl, pCalendarType, pPeriodName, p_raw_text_flag,x_ptd_trans_id,l_temp_excp_meaning);
  END IF;

  --
  -- calculate measure color indicators
  --

  IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG('before calling exception API',TRUE, g_msg_level_runtime_info);
  END IF;


  IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG('after calling exception API',TRUE, g_msg_level_runtime_info);
  END IF;

  --
  -- the Pa_Perf_Excp_Utils.get_measure_indicator_list could return a NULL
  -- collection, so I have to eventually create collections of the tight
  -- length, because at the exit of retrieveData I expect to have all the
  -- output collections long as the p_measure_set_code input collection.
  --

  IF x_ptd_html IS NULL THEN
    x_ptd_html := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
    x_ptd_html.EXTEND(p_measure_set_code.LAST);
	x_ptd_trans_id := SYSTEM.pa_NUM_TBL_TYPE();
	x_ptd_trans_id.extend(p_measure_set_code.LAST);
	x_ptd_meaning := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
	x_ptd_meaning.extend(p_measure_set_code.LAST);
  END IF;

  IF x_qtd_html IS NULL THEN
    x_qtd_html := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
    x_qtd_html.EXTEND(p_measure_set_code.LAST);
	x_qtd_trans_id := SYSTEM.pa_NUM_TBL_TYPE();
	x_qtd_trans_id.extend(p_measure_set_code.LAST);
	x_qtd_meaning := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
	x_qtd_meaning.extend(p_measure_set_code.LAST);
  END IF;

  IF x_ytd_html IS NULL THEN
    x_ytd_html := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
    x_ytd_html.EXTEND(p_measure_set_code.LAST);
	x_ytd_trans_id := SYSTEM.pa_NUM_TBL_TYPE();
	x_ytd_trans_id.extend(p_measure_set_code.LAST);
	x_ytd_meaning := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
	x_ytd_meaning.extend(p_measure_set_code.LAST);
  END IF;

  IF x_itd_html IS NULL THEN
    x_itd_html := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
    x_itd_html.EXTEND(p_measure_set_code.LAST);
	x_itd_trans_id := SYSTEM.pa_NUM_TBL_TYPE();
	x_itd_trans_id.extend(p_measure_set_code.LAST);
	x_itd_meaning := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
	x_itd_meaning.extend(p_measure_set_code.LAST);
  END IF;

  IF x_ac_html IS NULL THEN
    x_ac_html := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
    x_ac_html.EXTEND(p_measure_set_code.LAST);
	x_ac_trans_id := SYSTEM.pa_NUM_TBL_TYPE();
	x_ac_trans_id.extend(p_measure_set_code.LAST);
	x_ac_meaning := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
	x_ac_meaning.extend(p_measure_set_code.LAST);
  END IF;

  IF x_prp_html IS NULL THEN
    x_prp_html := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
    x_prp_html.EXTEND(p_measure_set_code.LAST);
	x_prp_trans_id := SYSTEM.pa_NUM_TBL_TYPE();
	x_prp_trans_id.extend(p_measure_set_code.LAST);
	x_prp_meaning := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
	x_prp_meaning.extend(p_measure_set_code.LAST);
  END IF;

  --FOR i IN 1..x_itd_html.last LOOP
  --  dbms_output.put_line('meas_id(' || i || ')= ' || itd_measure_ids_tbl(i)||'; itd_html(' || i || ')= ' || x_itd_html(i));
  --END LOOP;


  --
  -- initialize all the remaining output collections
  --
  x_measure_type:=  SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
  x_ptd_value		:=  SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
  x_qtd_value		:=  SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
  x_ytd_value		:=  SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
  x_itd_value		:=  SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
  x_ac_value		:=  SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
  x_prp_value		:=  SYSTEM.PA_VARCHAR2_80_TBL_TYPE();

  x_measure_type.EXTEND(p_measure_set_code.LAST);
  x_ptd_value.EXTEND(p_measure_set_code.LAST);
  x_qtd_value.EXTEND(p_measure_set_code.LAST);
  x_ytd_value.EXTEND(p_measure_set_code.LAST);
  x_itd_value.EXTEND(p_measure_set_code.LAST);
  x_ac_value.EXTEND(p_measure_set_code.LAST);
  x_prp_value.EXTEND(p_measure_set_code.LAST);

  l_ptd_value		:=  SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
  l_qtd_value		:=  SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
  l_ytd_value		:=  SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
  l_itd_value		:=  SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
  l_ac_value		:=  SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
  l_prp_value		:=  SYSTEM.PA_VARCHAR2_80_TBL_TYPE();

  l_ptd_value.EXTEND(p_measure_set_code.LAST);
  l_qtd_value.EXTEND(p_measure_set_code.LAST);
  l_ytd_value.EXTEND(p_measure_set_code.LAST);
  l_itd_value.EXTEND(p_measure_set_code.LAST);
  l_ac_value.EXTEND(p_measure_set_code.LAST);
  l_prp_value.EXTEND(p_measure_set_code.LAST);

  /*x_qtd_html    :=  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
  x_ytd_html    :=  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
  x_ac_html     :=  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
  x_prp_html    :=  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();
  x_qtd_html.EXTEND(p_measure_set_code.LAST);
  x_ytd_html.EXTEND(p_measure_set_code.LAST);
  x_ac_html.EXTEND(p_measure_set_code.LAST);
  x_prp_html.EXTEND(p_measure_set_code.LAST);
  */

  --
  -- initialize custom measures arrays
  --

  l_seeded_measures             := SYSTEM.PA_Num_Tbl_Type();

  l_fp_custom_measures_ptd := SYSTEM.PA_NUM_TBL_TYPE(
  						   	    l_overview_type(l_actual_index).ptd_custom_1,
								l_overview_type(l_actual_index).ptd_custom_2,
								l_overview_type(l_actual_index).ptd_custom_3,
								l_overview_type(l_actual_index).ptd_custom_4,
								l_overview_type(l_actual_index).ptd_custom_5,
								l_overview_type(l_actual_index).ptd_custom_6,
								l_overview_type(l_actual_index).ptd_custom_7,
								l_overview_type(l_actual_index).ptd_custom_8,
								l_overview_type(l_actual_index).ptd_custom_9,
								l_overview_type(l_actual_index).ptd_custom_10,
								l_overview_type(l_actual_index).ptd_custom_11,
								l_overview_type(l_actual_index).ptd_custom_12,
								l_overview_type(l_actual_index).ptd_custom_13,
								l_overview_type(l_actual_index).ptd_custom_14,
								l_overview_type(l_actual_index).ptd_custom_15
								);
  l_fp_custom_measures_qtd := SYSTEM.PA_NUM_TBL_TYPE(
  								l_overview_type(l_actual_index).qtd_custom_1,
								l_overview_type(l_actual_index).qtd_custom_2,
								l_overview_type(l_actual_index).qtd_custom_3,
								l_overview_type(l_actual_index).qtd_custom_4,
								l_overview_type(l_actual_index).qtd_custom_5,
								l_overview_type(l_actual_index).qtd_custom_6,
								l_overview_type(l_actual_index).qtd_custom_7,
								l_overview_type(l_actual_index).qtd_custom_8,
								l_overview_type(l_actual_index).qtd_custom_9,
								l_overview_type(l_actual_index).qtd_custom_10,
								l_overview_type(l_actual_index).qtd_custom_11,
								l_overview_type(l_actual_index).qtd_custom_12,
								l_overview_type(l_actual_index).qtd_custom_13,
								l_overview_type(l_actual_index).qtd_custom_14,
								l_overview_type(l_actual_index).qtd_custom_15
								);
  l_fp_custom_measures_ytd := SYSTEM.PA_NUM_TBL_TYPE(
  								l_overview_type(l_actual_index).ytd_custom_1,
								l_overview_type(l_actual_index).ytd_custom_2,
								l_overview_type(l_actual_index).ytd_custom_3,
								l_overview_type(l_actual_index).ytd_custom_4,
								l_overview_type(l_actual_index).ytd_custom_5,
								l_overview_type(l_actual_index).ytd_custom_6,
								l_overview_type(l_actual_index).ytd_custom_7,
								l_overview_type(l_actual_index).ytd_custom_8,
								l_overview_type(l_actual_index).ytd_custom_9,
								l_overview_type(l_actual_index).ytd_custom_10,
								l_overview_type(l_actual_index).ytd_custom_11,
								l_overview_type(l_actual_index).ytd_custom_12,
								l_overview_type(l_actual_index).ytd_custom_13,
								l_overview_type(l_actual_index).ytd_custom_14,
								l_overview_type(l_actual_index).ytd_custom_15
								);
  l_fp_custom_measures_itd := SYSTEM.PA_NUM_TBL_TYPE(
  								l_overview_type(l_actual_index).itd_custom_1,
								l_overview_type(l_actual_index).itd_custom_2,
								l_overview_type(l_actual_index).itd_custom_3,
								l_overview_type(l_actual_index).itd_custom_4,
								l_overview_type(l_actual_index).itd_custom_5,
								l_overview_type(l_actual_index).itd_custom_6,
								l_overview_type(l_actual_index).itd_custom_7,
								l_overview_type(l_actual_index).itd_custom_8,
								l_overview_type(l_actual_index).itd_custom_9,
								l_overview_type(l_actual_index).itd_custom_10,
								l_overview_type(l_actual_index).itd_custom_11,
								l_overview_type(l_actual_index).itd_custom_12,
								l_overview_type(l_actual_index).itd_custom_13,
								l_overview_type(l_actual_index).itd_custom_14,
								l_overview_type(l_actual_index).itd_custom_15
								);
  l_fp_custom_measures_ac  := SYSTEM.PA_NUM_TBL_TYPE(
  								l_overview_type(l_actual_index).ac_custom_1,
								l_overview_type(l_actual_index).ac_custom_2,
								l_overview_type(l_actual_index).ac_custom_3,
								l_overview_type(l_actual_index).ac_custom_4,
								l_overview_type(l_actual_index).ac_custom_5,
								l_overview_type(l_actual_index).ac_custom_6,
								l_overview_type(l_actual_index).ac_custom_7,
								l_overview_type(l_actual_index).ac_custom_8,
								l_overview_type(l_actual_index).ac_custom_9,
								l_overview_type(l_actual_index).ac_custom_10,
								l_overview_type(l_actual_index).ac_custom_11,
								l_overview_type(l_actual_index).ac_custom_12,
								l_overview_type(l_actual_index).ac_custom_13,
								l_overview_type(l_actual_index).ac_custom_14,
								l_overview_type(l_actual_index).ac_custom_15
								);
  l_fp_custom_measures_prp := SYSTEM.PA_NUM_TBL_TYPE(
  								l_overview_type(l_actual_index).prp_custom_1,
								l_overview_type(l_actual_index).prp_custom_2,
								l_overview_type(l_actual_index).prp_custom_3,
								l_overview_type(l_actual_index).prp_custom_4,
								l_overview_type(l_actual_index).prp_custom_5,
								l_overview_type(l_actual_index).prp_custom_6,
								l_overview_type(l_actual_index).prp_custom_7,
								l_overview_type(l_actual_index).prp_custom_8,
								l_overview_type(l_actual_index).prp_custom_9,
								l_overview_type(l_actual_index).prp_custom_10,
								l_overview_type(l_actual_index).prp_custom_11,
								l_overview_type(l_actual_index).prp_custom_12,
								l_overview_type(l_actual_index).prp_custom_13,
								l_overview_type(l_actual_index).prp_custom_14,
								l_overview_type(l_actual_index).prp_custom_15
								);

  l_ac_custom_measures_ptd := SYSTEM.PA_NUM_TBL_TYPE(
  								l_pji_facts.ptd_custom_1,
								l_pji_facts.ptd_custom_2,
								l_pji_facts.ptd_custom_3,
								l_pji_facts.ptd_custom_4,
								l_pji_facts.ptd_custom_5,
								l_pji_facts.ptd_custom_6,
								l_pji_facts.ptd_custom_7,
								l_pji_facts.ptd_custom_8,
								l_pji_facts.ptd_custom_9,
								l_pji_facts.ptd_custom_10,
								l_pji_facts.ptd_custom_11,
								l_pji_facts.ptd_custom_12,
								l_pji_facts.ptd_custom_13,
								l_pji_facts.ptd_custom_14,
								l_pji_facts.ptd_custom_15
								);
  l_ac_custom_measures_qtd := SYSTEM.PA_NUM_TBL_TYPE(
  								l_pji_facts.qtd_custom_1,
								l_pji_facts.qtd_custom_2,
								l_pji_facts.qtd_custom_3,
								l_pji_facts.qtd_custom_4,
								l_pji_facts.qtd_custom_5,
								l_pji_facts.qtd_custom_6,
								l_pji_facts.qtd_custom_7,
								l_pji_facts.qtd_custom_8,
								l_pji_facts.qtd_custom_9,
								l_pji_facts.qtd_custom_10,
								l_pji_facts.qtd_custom_11,
								l_pji_facts.qtd_custom_12,
								l_pji_facts.qtd_custom_13,
								l_pji_facts.qtd_custom_14,
								l_pji_facts.qtd_custom_15
								);
  l_ac_custom_measures_ytd := SYSTEM.PA_NUM_TBL_TYPE(
  								l_pji_facts.ytd_custom_1,
								l_pji_facts.ytd_custom_2,
								l_pji_facts.ytd_custom_3,
								l_pji_facts.ytd_custom_4,
								l_pji_facts.ytd_custom_5,
								l_pji_facts.ytd_custom_6,
								l_pji_facts.ytd_custom_7,
								l_pji_facts.ytd_custom_8,
								l_pji_facts.ytd_custom_9,
								l_pji_facts.ytd_custom_10,
								l_pji_facts.ytd_custom_11,
								l_pji_facts.ytd_custom_12,
								l_pji_facts.ytd_custom_13,
								l_pji_facts.ytd_custom_14,
								l_pji_facts.ytd_custom_15
								);
  l_ac_custom_measures_itd := SYSTEM.PA_NUM_TBL_TYPE(
  								l_pji_facts.itd_custom_1,
								l_pji_facts.itd_custom_2,
								l_pji_facts.itd_custom_3,
								l_pji_facts.itd_custom_4,
								l_pji_facts.itd_custom_5,
								l_pji_facts.itd_custom_6,
								l_pji_facts.itd_custom_7,
								l_pji_facts.itd_custom_8,
								l_pji_facts.itd_custom_9,
								l_pji_facts.itd_custom_10,
								l_pji_facts.itd_custom_11,
								l_pji_facts.itd_custom_12,
								l_pji_facts.itd_custom_13,
								l_pji_facts.itd_custom_14,
								l_pji_facts.itd_custom_15
								);
  l_ac_custom_measures_ac  := SYSTEM.PA_NUM_TBL_TYPE(
  								l_pji_facts.ac_custom_1,
								l_pji_facts.ac_custom_2,
								l_pji_facts.ac_custom_3,
								l_pji_facts.ac_custom_4,
								l_pji_facts.ac_custom_5,
								l_pji_facts.ac_custom_6,
								l_pji_facts.ac_custom_7,
								l_pji_facts.ac_custom_8,
								l_pji_facts.ac_custom_9,
								l_pji_facts.ac_custom_10,
								l_pji_facts.ac_custom_11,
								l_pji_facts.ac_custom_12,
								l_pji_facts.ac_custom_13,
								l_pji_facts.ac_custom_14,
								l_pji_facts.ac_custom_15
								);
  l_ac_custom_measures_prp := SYSTEM.PA_NUM_TBL_TYPE(
  								l_pji_facts.prp_custom_1,
								l_pji_facts.prp_custom_2,
								l_pji_facts.prp_custom_3,
								l_pji_facts.prp_custom_4,
								l_pji_facts.prp_custom_5,
								l_pji_facts.prp_custom_6,
								l_pji_facts.prp_custom_7,
								l_pji_facts.prp_custom_8,
								l_pji_facts.prp_custom_9,
								l_pji_facts.prp_custom_10,
								l_pji_facts.prp_custom_11,
								l_pji_facts.prp_custom_12,
								l_pji_facts.prp_custom_13,
								l_pji_facts.prp_custom_14,
								l_pji_facts.prp_custom_15
								);

  l_seeded_measure_count :=45;
  l_seeded_measures.extend(l_seeded_measure_count);

  --
  -- compute AC (Activity facts related) Custom Measures
  --

  l_seeded_measures(1) := l_pji_facts.ptd_additional_funding_amount;
  l_seeded_measures(2) := l_pji_facts.ptd_ar_invoice_count;
  l_seeded_measures(3) := l_pji_facts.ptd_initial_funding_amount;
  l_seeded_measures(4) := l_pji_facts.ptd_revenue_writeoff;

  Pji_Calc_Engine.Compute_AC_Measures(l_seeded_measures,
    l_ac_calc_custom_measures_ptd, x_return_status, x_msg_count, x_msg_data);

  l_seeded_measures(1) := l_pji_facts.qtd_additional_funding_amount;
  l_seeded_measures(2) := l_pji_facts.qtd_ar_invoice_count;
  l_seeded_measures(3) := l_pji_facts.qtd_initial_funding_amount;
  l_seeded_measures(4) := l_pji_facts.qtd_revenue_writeoff;

  Pji_Calc_Engine.Compute_AC_Measures(l_seeded_measures,
    l_ac_calc_custom_measures_qtd, x_return_status, x_msg_count, x_msg_data);

  l_seeded_measures(1) := l_pji_facts.ytd_additional_funding_amount;
  l_seeded_measures(2) := l_pji_facts.ytd_ar_invoice_count;
  l_seeded_measures(3) := l_pji_facts.ytd_initial_funding_amount;
  l_seeded_measures(4) := l_pji_facts.ytd_revenue_writeoff;

  Pji_Calc_Engine.Compute_AC_Measures(l_seeded_measures,
    l_ac_calc_custom_measures_ytd, x_return_status, x_msg_count, x_msg_data);

  l_seeded_measures(1) := l_pji_facts.itd_additional_funding_amount;
  l_seeded_measures(2) := l_pji_facts.itd_ar_invoice_count;
  l_seeded_measures(3) := l_pji_facts.itd_initial_funding_amount;
  l_seeded_measures(4) := l_pji_facts.itd_revenue_writeoff;

  Pji_Calc_Engine.Compute_AC_Measures(l_seeded_measures,
    l_ac_calc_custom_measures_itd, x_return_status, x_msg_count, x_msg_data);

  l_seeded_measures(1) := l_pji_facts.ac_additional_funding_amount;
  l_seeded_measures(2) := l_pji_facts.ac_ar_invoice_count;
  l_seeded_measures(3) := l_pji_facts.ac_initial_funding_amount;
  l_seeded_measures(4) := l_pji_facts.ac_revenue_writeoff;

  Pji_Calc_Engine.Compute_AC_Measures(l_seeded_measures,
    l_ac_calc_custom_measures_ac, x_return_status, x_msg_count, x_msg_data);

  l_seeded_measures(1) := l_pji_facts.prp_additional_funding_amount;
  l_seeded_measures(2) := l_pji_facts.prp_ar_invoice_count;
  l_seeded_measures(3) := l_pji_facts.prp_initial_funding_amount;
  l_seeded_measures(4) := l_pji_facts.prp_revenue_writeoff;

  Pji_Calc_Engine.Compute_ac_Measures(l_seeded_measures,
    l_ac_calc_custom_measures_prp, x_return_status, x_msg_count, x_msg_data);

  --
  -- compute FP custom measures
  --

-- input values array preparation for PTD
  l_seeded_measures(1)  := l_overview_type(l_actual_index).ptd_bill_equipment_hrs;
  l_seeded_measures(2)  := l_overview_type(l_actual_index).ptd_bill_burdened_cost;
  l_seeded_measures(3)  := l_overview_type(l_actual_index).ptd_bill_labor_hrs;
  l_seeded_measures(4)  := l_overview_type(l_actual_index).ptd_burdened_cost -
  						   l_overview_type(l_actual_index).ptd_raw_cost;
/*  l_seeded_measures(5)  := l_overview_type(l_cost_budget2_index).ptd_burdened_cost;
  l_seeded_measures(6)  := l_overview_type(l_cost_budget2_index).ptd_equipment_hrs;
  l_seeded_measures(7)  := l_overview_type(l_cost_budget2_index).ptd_labor_hrs;
  l_seeded_measures(8)  := l_overview_type(l_rev_budget2_index).ptd_revenue;
  l_seeded_measures(9)  := l_overview_type(l_cost_budget2_index).ptd_raw_cost; commented for bug 9485251 */
  /* Order changed for bug 9485251 */
  l_seeded_measures(5)  := l_overview_type(l_cost_budget_index).ptd_burdened_cost;
  l_seeded_measures(6)  := l_overview_type(l_cost_budget_index).ptd_equipment_hrs;
  l_seeded_measures(7) := l_overview_type(l_cost_budget_index).ptd_labor_hrs;
  l_seeded_measures(8) := l_overview_type(l_rev_budget_index).ptd_revenue;
  l_seeded_measures(9)  := l_overview_type(l_cost_budget_index).ptd_raw_cost;
  l_seeded_measures(10)  := l_overview_type(l_actual_index).ptd_capitalizable_brdn_cost ;
  l_seeded_measures(11)  := l_overview_type(l_actual_index).ptd_equipment_brdn_cost;
  l_seeded_measures(12) := l_overview_type(l_cost_forecast_index).ptd_burdened_cost;
  l_seeded_measures(13) := l_overview_type(l_cost_forecast_index).ptd_equipment_hrs;
  l_seeded_measures(14) := l_overview_type(l_cost_forecast_index).ptd_labor_hrs;
  l_seeded_measures(15) := l_overview_type(l_rev_forecast_index).ptd_revenue;
  l_seeded_measures(16) := l_overview_type(l_actual_index).ptd_labor_raw_cost;
  l_seeded_measures(17) := l_overview_type(l_actual_index).ptd_burdened_cost -
                           l_overview_type(l_actual_index).ptd_bill_burdened_cost;
  l_seeded_measures(18) := l_overview_type(l_actual_index).ptd_equipment_hrs -
                           l_overview_type(l_actual_index).ptd_bill_equipment_hrs ;
  l_seeded_measures(19) := l_overview_type(l_actual_index).ptd_labor_hrs -
                           l_overview_type(l_actual_index).ptd_bill_labor_hrs ;
  l_seeded_measures(20) := l_overview_type(l_actual_index).ptd_burdened_cost -
                           NVL(l_overview_type(l_actual_index).ptd_bill_burdened_cost,0) -
						   l_overview_type(l_actual_index).ptd_capitalizable_brdn_cost ;
/*  l_seeded_measures(26) := l_overview_type(l_orig_cost_budget2_index).ptd_burdened_cost;
  l_seeded_measures(27) := l_overview_type(l_orig_cost_budget2_index).ptd_equipment_hrs;
  l_seeded_measures(28) := l_overview_type(l_orig_cost_budget2_index).ptd_labor_hrs;
  l_seeded_measures(29) := l_overview_type(l_orig_rev_budget2_index).ptd_revenue; commented for bug 9485251 */
  /* Order changed for bug 9485251 */
  l_seeded_measures(21) := l_overview_type(l_orig_cost_budget_index).ptd_burdened_cost;
  l_seeded_measures(22) := l_overview_type(l_orig_cost_budget_index).ptd_equipment_hrs;
  l_seeded_measures(23) := l_overview_type(l_orig_cost_budget_index).ptd_labor_hrs;
  l_seeded_measures(24) := l_overview_type(l_orig_rev_budget_index).ptd_revenue;
  l_seeded_measures(25) := l_overview_type(l_actual_index).ptd_oth_committed_cost;
  l_seeded_measures(26) := l_overview_type(l_actual_index).ptd_po_committed_cost;
  l_seeded_measures(27) := l_completed_percentage;
  l_seeded_measures(28) := l_overview_type(l_actual_index).ptd_pr_committed_cost;
  l_seeded_measures(29) := l_overview_type(l_actual_index).ptd_revenue;
  l_seeded_measures(30) := l_overview_type(l_actual_index).ptd_raw_cost;
  l_seeded_measures(31) := l_overview_type(l_actual_index).ptd_sup_inv_committed_cost;
  l_seeded_measures(32) := l_overview_type(l_actual_index).ptd_burdened_cost;
  l_seeded_measures(33) := l_overview_type(l_actual_index).ptd_sup_inv_committed_cost +
     					   l_overview_type(l_actual_index).ptd_oth_committed_cost +
						   l_overview_type(l_actual_index).ptd_po_committed_cost +
						   l_overview_type(l_actual_index).ptd_pr_committed_cost;
  l_seeded_measures(34) := l_overview_type(l_actual_index).ptd_equipment_hrs;
  l_seeded_measures(35) := l_overview_type(l_actual_index).ptd_labor_burdened_cost;
  l_seeded_measures(36) := l_overview_type(l_actual_index).ptd_labor_hrs;
  -- compute PTD custom FP measures
  Pji_Calc_Engine.Compute_FP_Measures(l_seeded_measures,
    l_fp_calc_custom_measures_ptd, x_return_status, x_msg_count, x_msg_data);

  -- input values array preparation for QTD
  l_seeded_measures(1)  := l_overview_type(l_actual_index).qtd_bill_equipment_hrs;
  l_seeded_measures(2)  := l_overview_type(l_actual_index).qtd_bill_burdened_cost;
  l_seeded_measures(3)  := l_overview_type(l_actual_index).qtd_bill_labor_hrs;
  l_seeded_measures(4)  := l_overview_type(l_actual_index).qtd_burdened_cost -
  						   l_overview_type(l_actual_index).qtd_raw_cost;
/*  l_seeded_measures(5)  := l_overview_type(l_cost_budget2_index).qtd_burdened_cost;
  l_seeded_measures(6)  := l_overview_type(l_cost_budget2_index).qtd_equipment_hrs;
  l_seeded_measures(7)  := l_overview_type(l_cost_budget2_index).qtd_labor_hrs;
  l_seeded_measures(8)  := l_overview_type(l_rev_budget2_index).qtd_revenue;
  l_seeded_measures(9)  := l_overview_type(l_cost_budget2_index).qtd_raw_cost; commented for bug 9485251 */
  /* Order changed for bug 9485251 */
  l_seeded_measures(5)  := l_overview_type(l_cost_budget_index).qtd_burdened_cost;
  l_seeded_measures(6)  := l_overview_type(l_cost_budget_index).qtd_equipment_hrs;
  l_seeded_measures(7) := l_overview_type(l_cost_budget_index).qtd_labor_hrs;
  l_seeded_measures(8) := l_overview_type(l_rev_budget_index).qtd_revenue;
  l_seeded_measures(9)  := l_overview_type(l_cost_budget_index).qtd_raw_cost;
  l_seeded_measures(10)  := l_overview_type(l_actual_index).qtd_capitalizable_brdn_cost ;
  l_seeded_measures(11)  := l_overview_type(l_actual_index).qtd_equipment_brdn_cost;
  l_seeded_measures(12) := l_overview_type(l_cost_forecast_index).qtd_burdened_cost;
  l_seeded_measures(13) := l_overview_type(l_cost_forecast_index).qtd_equipment_hrs;
  l_seeded_measures(14) := l_overview_type(l_cost_forecast_index).qtd_labor_hrs;
  l_seeded_measures(15) := l_overview_type(l_rev_forecast_index).qtd_revenue;
  l_seeded_measures(16) := l_overview_type(l_actual_index).qtd_labor_raw_cost;
  l_seeded_measures(17) := l_overview_type(l_actual_index).qtd_burdened_cost -
                           l_overview_type(l_actual_index).qtd_bill_burdened_cost;
  l_seeded_measures(18) := l_overview_type(l_actual_index).qtd_equipment_hrs -
                           l_overview_type(l_actual_index).qtd_bill_equipment_hrs ;
  l_seeded_measures(19) := l_overview_type(l_actual_index).qtd_labor_hrs -
                           l_overview_type(l_actual_index).qtd_bill_labor_hrs ;
  l_seeded_measures(20) := l_overview_type(l_actual_index).qtd_burdened_cost -
                           NVL(l_overview_type(l_actual_index).qtd_bill_burdened_cost,0) -
						   l_overview_type(l_actual_index).qtd_capitalizable_brdn_cost ;
/*  l_seeded_measures(26) := l_overview_type(l_orig_cost_budget2_index).qtd_burdened_cost;
  l_seeded_measures(27) := l_overview_type(l_orig_cost_budget2_index).qtd_equipment_hrs;
  l_seeded_measures(28) := l_overview_type(l_orig_cost_budget2_index).qtd_labor_hrs;
  l_seeded_measures(29) := l_overview_type(l_orig_rev_budget2_index).qtd_revenue; commented for bug 9485251 */
  /* Order changed for bug 9485251 */
  l_seeded_measures(21) := l_overview_type(l_orig_cost_budget_index).qtd_burdened_cost;
  l_seeded_measures(22) := l_overview_type(l_orig_cost_budget_index).qtd_equipment_hrs;
  l_seeded_measures(23) := l_overview_type(l_orig_cost_budget_index).qtd_labor_hrs;
  l_seeded_measures(24) := l_overview_type(l_orig_rev_budget_index).qtd_revenue;
  l_seeded_measures(25) := l_overview_type(l_actual_index).qtd_oth_committed_cost;
  l_seeded_measures(26) := l_overview_type(l_actual_index).qtd_po_committed_cost;
  l_seeded_measures(27) := l_completed_percentage;
  l_seeded_measures(28) := l_overview_type(l_actual_index).qtd_pr_committed_cost;
  l_seeded_measures(29) := l_overview_type(l_actual_index).qtd_revenue;
  l_seeded_measures(30) := l_overview_type(l_actual_index).qtd_raw_cost;
  l_seeded_measures(31) := l_overview_type(l_actual_index).qtd_sup_inv_committed_cost;
  l_seeded_measures(32) := l_overview_type(l_actual_index).qtd_burdened_cost;
  l_seeded_measures(33) := l_overview_type(l_actual_index).qtd_sup_inv_committed_cost +
     					   l_overview_type(l_actual_index).qtd_oth_committed_cost +
						   l_overview_type(l_actual_index).qtd_po_committed_cost +
						   l_overview_type(l_actual_index).qtd_pr_committed_cost;
  l_seeded_measures(34) := l_overview_type(l_actual_index).qtd_equipment_hrs;
  l_seeded_measures(35) := l_overview_type(l_actual_index).qtd_labor_burdened_cost;
  l_seeded_measures(36) := l_overview_type(l_actual_index).qtd_labor_hrs;
  -- compute QTD custom FP measures
  Pji_Calc_Engine.Compute_FP_Measures(l_seeded_measures,
    l_fp_calc_custom_measures_qtd, x_return_status, x_msg_count, x_msg_data);

  -- input values array preparation for YTD
  l_seeded_measures(1)  := l_overview_type(l_actual_index).ytd_bill_equipment_hrs;
  l_seeded_measures(2)  := l_overview_type(l_actual_index).ytd_bill_burdened_cost;
  l_seeded_measures(3)  := l_overview_type(l_actual_index).ytd_bill_labor_hrs;
  l_seeded_measures(4)  := l_overview_type(l_actual_index).ytd_burdened_cost -
  						   l_overview_type(l_actual_index).ytd_raw_cost;
/*  l_seeded_measures(5)  := l_overview_type(l_cost_budget2_index).ytd_burdened_cost;
  l_seeded_measures(6)  := l_overview_type(l_cost_budget2_index).ytd_equipment_hrs;
  l_seeded_measures(7)  := l_overview_type(l_cost_budget2_index).ytd_labor_hrs;
  l_seeded_measures(8)  := l_overview_type(l_rev_budget2_index).ytd_revenue;
  l_seeded_measures(9)  := l_overview_type(l_cost_budget2_index).ytd_raw_cost; commented for bug 9485251 */
  /* Order changed for bug 9485251 */
  l_seeded_measures(5)  := l_overview_type(l_cost_budget_index).ytd_burdened_cost;
  l_seeded_measures(6)  := l_overview_type(l_cost_budget_index).ytd_equipment_hrs;
  l_seeded_measures(7) := l_overview_type(l_cost_budget_index).ytd_labor_hrs;
  l_seeded_measures(8) := l_overview_type(l_rev_budget_index).ytd_revenue;
  l_seeded_measures(9)  := l_overview_type(l_cost_budget_index).ytd_raw_cost;
  l_seeded_measures(10)  := l_overview_type(l_actual_index).ytd_capitalizable_brdn_cost ;
  l_seeded_measures(11)  := l_overview_type(l_actual_index).ytd_equipment_brdn_cost;
  l_seeded_measures(12) := l_overview_type(l_cost_forecast_index).ytd_burdened_cost;
  l_seeded_measures(13) := l_overview_type(l_cost_forecast_index).ytd_equipment_hrs;
  l_seeded_measures(14) := l_overview_type(l_cost_forecast_index).ytd_labor_hrs;
  l_seeded_measures(15) := l_overview_type(l_rev_forecast_index).ytd_revenue;
  l_seeded_measures(16) := l_overview_type(l_actual_index).ytd_labor_raw_cost;
  l_seeded_measures(17) := l_overview_type(l_actual_index).ytd_burdened_cost -
                         l_overview_type(l_actual_index).ytd_bill_burdened_cost;
  l_seeded_measures(18) := l_overview_type(l_actual_index).ytd_equipment_hrs -
                           l_overview_type(l_actual_index).ytd_bill_equipment_hrs ;
  l_seeded_measures(19) := l_overview_type(l_actual_index).ytd_labor_hrs -
                           l_overview_type(l_actual_index).ytd_bill_labor_hrs ;
  l_seeded_measures(20) := l_overview_type(l_actual_index).ytd_burdened_cost -
                           NVL(l_overview_type(l_actual_index).ytd_bill_burdened_cost,0) -
						   l_overview_type(l_actual_index).ytd_capitalizable_brdn_cost ;
/*  l_seeded_measures(26) := l_overview_type(l_orig_cost_budget2_index).ytd_burdened_cost;
  l_seeded_measures(27) := l_overview_type(l_orig_cost_budget2_index).ytd_equipment_hrs;
  l_seeded_measures(28) := l_overview_type(l_orig_cost_budget2_index).ytd_labor_hrs;
  l_seeded_measures(29) := l_overview_type(l_orig_rev_budget2_index).ytd_revenue; commented for bug 9485251 */
  /* Order changed for bug 9485251 */
  l_seeded_measures(21) := l_overview_type(l_orig_cost_budget_index).ytd_burdened_cost;
  l_seeded_measures(22) := l_overview_type(l_orig_cost_budget_index).ytd_equipment_hrs;
  l_seeded_measures(23) := l_overview_type(l_orig_cost_budget_index).ytd_labor_hrs;
  l_seeded_measures(24) := l_overview_type(l_orig_rev_budget_index).ytd_revenue;
  l_seeded_measures(25) := l_overview_type(l_actual_index).ytd_oth_committed_cost;
  l_seeded_measures(26) := l_overview_type(l_actual_index).ytd_po_committed_cost;
  l_seeded_measures(27) := l_completed_percentage;
  l_seeded_measures(28) := l_overview_type(l_actual_index).ytd_pr_committed_cost;
  l_seeded_measures(29) := l_overview_type(l_actual_index).ytd_revenue;
  l_seeded_measures(30) := l_overview_type(l_actual_index).ytd_raw_cost;
  l_seeded_measures(31) := l_overview_type(l_actual_index).ytd_sup_inv_committed_cost;
  l_seeded_measures(32) := l_overview_type(l_actual_index).ytd_burdened_cost;
  l_seeded_measures(33) := l_overview_type(l_actual_index).ytd_sup_inv_committed_cost +
     					   l_overview_type(l_actual_index).ytd_oth_committed_cost +
						   l_overview_type(l_actual_index).ytd_po_committed_cost +
						   l_overview_type(l_actual_index).ytd_pr_committed_cost;
  l_seeded_measures(34) := l_overview_type(l_actual_index).ytd_equipment_hrs;
  l_seeded_measures(35) := l_overview_type(l_actual_index).ytd_labor_burdened_cost;
  l_seeded_measures(36) := l_overview_type(l_actual_index).ytd_labor_hrs;
  -- compute YTD custom FP measures
  Pji_Calc_Engine.Compute_FP_Measures(l_seeded_measures,
    l_fp_calc_custom_measures_ytd, x_return_status, x_msg_count, x_msg_data);

  -- input values array preparation for ITD
  l_seeded_measures(1)  := l_overview_type(l_actual_index).itd_bill_equipment_hrs;
  l_seeded_measures(2)  := l_overview_type(l_actual_index).itd_bill_burdened_cost;
  l_seeded_measures(3)  := l_overview_type(l_actual_index).itd_bill_labor_hrs;
  l_seeded_measures(4)  := l_overview_type(l_actual_index).itd_burdened_cost -
  						   l_overview_type(l_actual_index).itd_raw_cost;
/*  l_seeded_measures(5)  := l_overview_type(l_cost_budget2_index).itd_burdened_cost;
  l_seeded_measures(6)  := l_overview_type(l_cost_budget2_index).itd_equipment_hrs;
  l_seeded_measures(7)  := l_overview_type(l_cost_budget2_index).itd_labor_hrs;
  l_seeded_measures(8)  := l_overview_type(l_rev_budget2_index).itd_revenue;
  l_seeded_measures(9)  := l_overview_type(l_cost_budget2_index).itd_raw_cost;  commented for bug 9485251 */
  /* Order changed for bug 9485251 */
  l_seeded_measures(5)  := l_overview_type(l_cost_budget_index).itd_burdened_cost;
  l_seeded_measures(6)  := l_overview_type(l_cost_budget_index).itd_equipment_hrs;
  l_seeded_measures(7) := l_overview_type(l_cost_budget_index).itd_labor_hrs;
  l_seeded_measures(8) := l_overview_type(l_rev_budget_index).itd_revenue;
  l_seeded_measures(9)  := l_overview_type(l_cost_budget_index).itd_raw_cost;
  l_seeded_measures(10)  := l_overview_type(l_actual_index).itd_capitalizable_brdn_cost ;
  l_seeded_measures(11)  := l_overview_type(l_actual_index).itd_equipment_brdn_cost;
  l_seeded_measures(12) := l_overview_type(l_cost_forecast_index).itd_burdened_cost;
  l_seeded_measures(13) := l_overview_type(l_cost_forecast_index).itd_equipment_hrs;
  l_seeded_measures(14) := l_overview_type(l_cost_forecast_index).itd_labor_hrs;
  l_seeded_measures(15) := l_overview_type(l_rev_forecast_index).itd_revenue;
  l_seeded_measures(16) := l_overview_type(l_actual_index).itd_labor_raw_cost;
  l_seeded_measures(17) := l_overview_type(l_actual_index).itd_burdened_cost -
                         l_overview_type(l_actual_index).itd_bill_burdened_cost;
  l_seeded_measures(18) := l_overview_type(l_actual_index).itd_equipment_hrs -
                           l_overview_type(l_actual_index).itd_bill_equipment_hrs ;
  l_seeded_measures(19) := l_overview_type(l_actual_index).itd_labor_hrs -
                           l_overview_type(l_actual_index).itd_bill_labor_hrs ;
  l_seeded_measures(20) := l_overview_type(l_actual_index).itd_burdened_cost -
                           NVL(l_overview_type(l_actual_index).itd_bill_burdened_cost,0) -
						   l_overview_type(l_actual_index).itd_capitalizable_brdn_cost ;
/*  l_seeded_measures(26) := l_overview_type(l_orig_cost_budget2_index).itd_burdened_cost;
  l_seeded_measures(27) := l_overview_type(l_orig_cost_budget2_index).itd_equipment_hrs;
  l_seeded_measures(28) := l_overview_type(l_orig_cost_budget2_index).itd_labor_hrs;
  l_seeded_measures(29) := l_overview_type(l_orig_rev_budget2_index).itd_revenue; commented for bug 9485251 */
  /* Order changed for bug 9485251 */
  l_seeded_measures(21) := l_overview_type(l_orig_cost_budget_index).itd_burdened_cost;
  l_seeded_measures(22) := l_overview_type(l_orig_cost_budget_index).itd_equipment_hrs;
  l_seeded_measures(23) := l_overview_type(l_orig_cost_budget_index).itd_labor_hrs;
  l_seeded_measures(24) := l_overview_type(l_orig_rev_budget_index).itd_revenue;
  l_seeded_measures(25) := l_overview_type(l_actual_index).itd_oth_committed_cost;
  l_seeded_measures(26) := l_overview_type(l_actual_index).itd_po_committed_cost;
  l_seeded_measures(27) := l_completed_percentage;
  l_seeded_measures(28) := l_overview_type(l_actual_index).itd_pr_committed_cost;
  l_seeded_measures(29) := l_overview_type(l_actual_index).itd_revenue;
  l_seeded_measures(30) := l_overview_type(l_actual_index).itd_raw_cost;
  l_seeded_measures(31) := l_overview_type(l_actual_index).itd_sup_inv_committed_cost;
  l_seeded_measures(32) := l_overview_type(l_actual_index).itd_burdened_cost;
  l_seeded_measures(33) := l_overview_type(l_actual_index).itd_sup_inv_committed_cost +
     					   l_overview_type(l_actual_index).itd_oth_committed_cost +
						   l_overview_type(l_actual_index).itd_po_committed_cost +
						   l_overview_type(l_actual_index).itd_pr_committed_cost;
  l_seeded_measures(34) := l_overview_type(l_actual_index).itd_equipment_hrs;
  l_seeded_measures(35) := l_overview_type(l_actual_index).itd_labor_burdened_cost;
  l_seeded_measures(36) := l_overview_type(l_actual_index).itd_labor_hrs;
  -- compute ITD custom FP measures
  Pji_Calc_Engine.Compute_FP_Measures(l_seeded_measures,
    l_fp_calc_custom_measures_itd, x_return_status, x_msg_count, x_msg_data);


  -- input values array preparation for AT COMPL
  l_seeded_measures(1)  := l_overview_type(l_actual_index).ac_bill_equipment_hrs;
  l_seeded_measures(2)  := l_overview_type(l_actual_index).ac_bill_burdened_cost;
  l_seeded_measures(3)  := l_overview_type(l_actual_index).ac_bill_labor_hrs;
  l_seeded_measures(4)  := l_overview_type(l_actual_index).ac_burdened_cost -
  						   l_overview_type(l_actual_index).ac_raw_cost;
/*  l_seeded_measures(5)  := l_overview_type(l_cost_budget2_index).ac_burdened_cost;
  l_seeded_measures(6)  := l_overview_type(l_cost_budget2_index).ac_equipment_hrs;
  l_seeded_measures(7)  := l_overview_type(l_cost_budget2_index).ac_labor_hrs;
  l_seeded_measures(8)  := l_overview_type(l_rev_budget2_index).ac_revenue;
  l_seeded_measures(9)  := l_overview_type(l_cost_budget2_index).ac_raw_cost; commented for bug 9485251 */
  /* Order changed for bug 9485251 */
  l_seeded_measures(5)  := l_overview_type(l_cost_budget_index).ac_burdened_cost;
  l_seeded_measures(6)  := l_overview_type(l_cost_budget_index).ac_equipment_hrs;
  l_seeded_measures(7) := l_overview_type(l_cost_budget_index).ac_labor_hrs;
  l_seeded_measures(8) := l_overview_type(l_rev_budget_index).ac_revenue;
  l_seeded_measures(9)  := l_overview_type(l_cost_budget_index).ac_raw_cost;
  l_seeded_measures(10)  := l_overview_type(l_actual_index).ac_capitalizable_brdn_cost ;
  l_seeded_measures(11)  := l_overview_type(l_actual_index).ac_equipment_brdn_cost;
  l_seeded_measures(12) := l_overview_type(l_cost_forecast_index).ac_burdened_cost;
  l_seeded_measures(13) := l_overview_type(l_cost_forecast_index).ac_equipment_hrs;
  l_seeded_measures(14) := l_overview_type(l_cost_forecast_index).ac_labor_hrs;
  l_seeded_measures(15) := l_overview_type(l_rev_forecast_index).ac_revenue;
  l_seeded_measures(16) := l_overview_type(l_actual_index).ac_labor_raw_cost;
  l_seeded_measures(17) := l_overview_type(l_actual_index).ac_burdened_cost -
                           l_overview_type(l_actual_index).ac_bill_burdened_cost;
  l_seeded_measures(18) := l_overview_type(l_actual_index).ac_equipment_hrs -
                           l_overview_type(l_actual_index).ac_bill_equipment_hrs ;
  l_seeded_measures(19) := l_overview_type(l_actual_index).ac_labor_hrs -
                           l_overview_type(l_actual_index).ac_bill_labor_hrs ;
  l_seeded_measures(20) := l_overview_type(l_actual_index).ac_burdened_cost -
                           NVL(l_overview_type(l_actual_index).ac_bill_burdened_cost,0) -
						   l_overview_type(l_actual_index).ac_capitalizable_brdn_cost ;
/*  l_seeded_measures(26) := l_overview_type(l_orig_cost_budget2_index).ac_burdened_cost;
  l_seeded_measures(27) := l_overview_type(l_orig_cost_budget2_index).ac_equipment_hrs;
  l_seeded_measures(28) := l_overview_type(l_orig_cost_budget2_index).ac_labor_hrs;
  l_seeded_measures(29) := l_overview_type(l_orig_rev_budget2_index).ac_revenue; commented for bug 9485251 */
  /* Order changed for bug 9485251 */
  l_seeded_measures(21) := l_overview_type(l_orig_cost_budget_index).ac_burdened_cost;
  l_seeded_measures(22) := l_overview_type(l_orig_cost_budget_index).ac_equipment_hrs;
  l_seeded_measures(23) := l_overview_type(l_orig_cost_budget_index).ac_labor_hrs;
  l_seeded_measures(24) := l_overview_type(l_orig_rev_budget_index).ac_revenue;
  l_seeded_measures(25) := l_overview_type(l_actual_index).ac_oth_committed_cost;
  l_seeded_measures(26) := l_overview_type(l_actual_index).ac_po_committed_cost;
  l_seeded_measures(27) := l_completed_percentage;
  l_seeded_measures(28) := l_overview_type(l_actual_index).ac_pr_committed_cost;
  l_seeded_measures(29) := l_overview_type(l_actual_index).ac_revenue;
  l_seeded_measures(30) := l_overview_type(l_actual_index).ac_raw_cost;
  l_seeded_measures(31) := l_overview_type(l_actual_index).ac_sup_inv_committed_cost;
  l_seeded_measures(32) := l_overview_type(l_actual_index).ac_burdened_cost;
  l_seeded_measures(33) := l_overview_type(l_actual_index).ac_sup_inv_committed_cost +
     					   l_overview_type(l_actual_index).ac_oth_committed_cost +
						   l_overview_type(l_actual_index).ac_po_committed_cost +
						   l_overview_type(l_actual_index).ac_pr_committed_cost;
  l_seeded_measures(34) := l_overview_type(l_actual_index).ac_equipment_hrs;
  l_seeded_measures(35) := l_overview_type(l_actual_index).ac_labor_burdened_cost;
  l_seeded_measures(36) := l_overview_type(l_actual_index).ac_labor_hrs;
  -- compute AT COMPL custom FP measures
  Pji_Calc_Engine.Compute_FP_Measures(l_seeded_measures,
    l_fp_calc_custom_measures_ac, x_return_status, x_msg_count, x_msg_data);

  -- input values array preparation for PRIOR PERIOD
  l_seeded_measures(1)  := l_overview_type(l_actual_index).prp_bill_equipment_hrs;
  l_seeded_measures(2)  := l_overview_type(l_actual_index).prp_bill_burdened_cost;
  l_seeded_measures(3)  := l_overview_type(l_actual_index).prp_bill_labor_hrs;
  l_seeded_measures(4)  := l_overview_type(l_actual_index).prp_burdened_cost -
  						   l_overview_type(l_actual_index).prp_raw_cost;
/*  l_seeded_measures(5)  := l_overview_type(l_cost_budget2_index).prp_burdened_cost;
  l_seeded_measures(6)  := l_overview_type(l_cost_budget2_index).prp_equipment_hrs;
  l_seeded_measures(7)  := l_overview_type(l_cost_budget2_index).prp_labor_hrs;
  l_seeded_measures(8)  := l_overview_type(l_rev_budget2_index).prp_revenue;
  l_seeded_measures(9)  := l_overview_type(l_cost_budget2_index).prp_raw_cost;  commented for bug 9485251 */
  /* Order changed for bug 9485251 */
  l_seeded_measures(5)  := l_overview_type(l_cost_budget_index).prp_burdened_cost;
  l_seeded_measures(6)  := l_overview_type(l_cost_budget_index).prp_equipment_hrs;
  l_seeded_measures(7) := l_overview_type(l_cost_budget_index).prp_labor_hrs;
  l_seeded_measures(8) := l_overview_type(l_rev_budget_index).prp_revenue;
  l_seeded_measures(9)  := l_overview_type(l_cost_budget_index).prp_raw_cost;
  l_seeded_measures(10)  := l_overview_type(l_actual_index).prp_capitalizable_brdn_cost ;
  l_seeded_measures(11)  := l_overview_type(l_actual_index).prp_equipment_brdn_cost;
  l_seeded_measures(12) := l_overview_type(l_cost_forecast_index).prp_burdened_cost;
  l_seeded_measures(13) := l_overview_type(l_cost_forecast_index).prp_equipment_hrs;
  l_seeded_measures(14) := l_overview_type(l_cost_forecast_index).prp_labor_hrs;
  l_seeded_measures(15) := l_overview_type(l_rev_forecast_index).prp_revenue;
  l_seeded_measures(16) := l_overview_type(l_actual_index).prp_labor_raw_cost;
  l_seeded_measures(17) := l_overview_type(l_actual_index).prp_burdened_cost -
                           l_overview_type(l_actual_index).prp_bill_burdened_cost;
  l_seeded_measures(18) := l_overview_type(l_actual_index).prp_equipment_hrs -
                           l_overview_type(l_actual_index).prp_bill_equipment_hrs ;
  l_seeded_measures(19) := l_overview_type(l_actual_index).prp_labor_hrs -
                           l_overview_type(l_actual_index).prp_bill_labor_hrs ;
  l_seeded_measures(20) := l_overview_type(l_actual_index).prp_burdened_cost -
                           NVL(l_overview_type(l_actual_index).prp_bill_burdened_cost,0) -
						   l_overview_type(l_actual_index).prp_capitalizable_brdn_cost ;
/*  l_seeded_measures(26) := l_overview_type(l_orig_cost_budget2_index).prp_burdened_cost;
  l_seeded_measures(27) := l_overview_type(l_orig_cost_budget2_index).prp_equipment_hrs;
  l_seeded_measures(28) := l_overview_type(l_orig_cost_budget2_index).prp_labor_hrs;
  l_seeded_measures(29) := l_overview_type(l_orig_rev_budget2_index).prp_revenue; commented for bug 9485251 */
  /* Order changed for bug 9485251 */
  l_seeded_measures(21) := l_overview_type(l_orig_cost_budget_index).prp_burdened_cost;
  l_seeded_measures(22) := l_overview_type(l_orig_cost_budget_index).prp_equipment_hrs;
  l_seeded_measures(23) := l_overview_type(l_orig_cost_budget_index).prp_labor_hrs;
  l_seeded_measures(24) := l_overview_type(l_orig_rev_budget_index).prp_revenue;
  l_seeded_measures(25) := l_overview_type(l_actual_index).prp_oth_committed_cost;
  l_seeded_measures(26) := l_overview_type(l_actual_index).prp_po_committed_cost;
  l_seeded_measures(27) := l_completed_percentage;
  l_seeded_measures(28) := l_overview_type(l_actual_index).prp_pr_committed_cost;
  l_seeded_measures(29) := l_overview_type(l_actual_index).prp_revenue;
  l_seeded_measures(30) := l_overview_type(l_actual_index).prp_raw_cost;
  l_seeded_measures(31) := l_overview_type(l_actual_index).prp_sup_inv_committed_cost;
  l_seeded_measures(32) := l_overview_type(l_actual_index).prp_burdened_cost;
  l_seeded_measures(33) := l_overview_type(l_actual_index).prp_sup_inv_committed_cost +
     					   l_overview_type(l_actual_index).prp_oth_committed_cost +
						   l_overview_type(l_actual_index).prp_po_committed_cost +
						   l_overview_type(l_actual_index).prp_pr_committed_cost;
  l_seeded_measures(34) := l_overview_type(l_actual_index).prp_equipment_hrs;
  l_seeded_measures(35) := l_overview_type(l_actual_index).prp_labor_burdened_cost;
  l_seeded_measures(36) := l_overview_type(l_actual_index).prp_labor_hrs;
  -- compute PRIOR PERIOD custom FP measures
  Pji_Calc_Engine.Compute_FP_Measures(l_seeded_measures,
    l_fp_calc_custom_measures_prp, x_return_status, x_msg_count, x_msg_data);

  --
  -- all l_fp_custom_measures_XXX lists have the same length
  -- we also assume that Pji_Calc_Engine APIs always return arrays
  -- that are 15 elements long
  --
  l_fp_custom_measures_ptd.extend(15);
  l_fp_custom_measures_qtd.extend(15);
  l_fp_custom_measures_ytd.extend(15);
  l_fp_custom_measures_itd.extend(15);
  l_fp_custom_measures_ac .extend(15);
  l_fp_custom_measures_prp.extend(15);

  l_ac_custom_measures_ptd.extend(15);
  l_ac_custom_measures_qtd.extend(15);
  l_ac_custom_measures_ytd.extend(15);
  l_ac_custom_measures_itd.extend(15);
  l_ac_custom_measures_ac .extend(15);
  l_ac_custom_measures_prp.extend(15);

  FOR i IN 1..15 LOOP
	  l_fp_custom_measures_ptd(i+15) := l_fp_calc_custom_measures_ptd(i);
	  l_fp_custom_measures_qtd(i+15) := l_fp_calc_custom_measures_qtd(i);
	  l_fp_custom_measures_ytd(i+15) := l_fp_calc_custom_measures_ytd(i);
	  l_fp_custom_measures_itd(i+15) := l_fp_calc_custom_measures_itd(i);
	  l_fp_custom_measures_ac(i+15) := l_fp_calc_custom_measures_ac(i);
	  l_fp_custom_measures_prp(i+15) := l_fp_calc_custom_measures_prp(i);

	  l_ac_custom_measures_ptd(i+15) := l_ac_calc_custom_measures_ptd(i);
	  l_ac_custom_measures_qtd(i+15) := l_ac_calc_custom_measures_qtd(i);
	  l_ac_custom_measures_ytd(i+15) := l_ac_calc_custom_measures_ytd(i);
	  l_ac_custom_measures_itd(i+15) := l_ac_calc_custom_measures_itd(i);
	  l_ac_custom_measures_ac(i+15) := l_ac_calc_custom_measures_ac(i);
	  l_ac_custom_measures_prp(i+15) := l_ac_calc_custom_measures_prp(i);
  END LOOP;

  l_fp_cus_meas_formats := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
  l_ac_cus_meas_formats := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
  BEGIN
    SELECT measure_format
    BULK COLLECT INTO l_fp_cus_meas_formats
    FROM pji_mt_measure_sets_b
    WHERE 1=1
    AND measure_set_type IN ('CUSTOM_CALC','CUSTOM_STORED')
    AND measure_source = 'FP'
    ORDER BY TO_NUMBER(SUBSTR(measure_set_code,16,2));

    SELECT measure_format
    BULK COLLECT INTO l_ac_cus_meas_formats
    FROM pji_mt_measure_sets_b
    WHERE 1=1
    AND measure_set_type IN ('CUSTOM_CALC','CUSTOM_STORED')
    AND measure_source = 'AC'
    ORDER BY TO_NUMBER(SUBSTR(measure_set_code,16,2));

  EXCEPTION
    WHEN OTHERS THEN
      l_sql_errm := SQLERRM();
	  IF g_debug_mode = 'Y' THEN
	      Pji_Utils.WRITE2LOG(
	        'PJI_REP_MEASURE_UTIL.retrieveData: project_id= ' || pProjectId ||
	        '; error during bulk collect on l_cus_meas_formats collection: '|| l_sql_errm,
	        TRUE, g_msg_level_runtime_info
	      );
	  END IF;
  END;


  -- sanity extension in case pji_mt_measure_sets_vl is not properly loaded
  l_fp_cus_meas_formats.extend(30);
  l_ac_cus_meas_formats.extend(30);

/*
  l_fp_custom_measures_ptd_char.extend(30);
  l_fp_custom_measures_qtd_char.extend(30);
  l_fp_custom_measures_ytd_char.extend(30);
  l_fp_custom_measures_itd_char.extend(30);
  l_fp_custom_measures_ac_char.extend(30);
  l_fp_custom_measures_prp_char.extend(30);

  l_ac_custom_measures_ptd_char.extend(30);
  l_ac_custom_measures_qtd_char.extend(30);
  l_ac_custom_measures_ytd_char.extend(30);
  l_ac_custom_measures_itd_char.extend(30);
  l_ac_custom_measures_ac_char.extend(30);
  l_ac_custom_measures_prp_char.extend(30);
*/

  FOR i IN 1..30 LOOP

    IF l_fp_cus_meas_formats(i) = g_CurrencyType THEN

      l_fp_custom_measures_ptd(i) := l_fp_custom_measures_ptd(i) / l_factor_by;
      l_fp_custom_measures_qtd(i) := l_fp_custom_measures_qtd(i) / l_factor_by;
      l_fp_custom_measures_ytd(i) := l_fp_custom_measures_ytd(i) / l_factor_by;
      l_fp_custom_measures_itd(i) := l_fp_custom_measures_itd(i) / l_factor_by;
      l_fp_custom_measures_ac(i)  := l_fp_custom_measures_ac(i) / l_factor_by;
      l_fp_custom_measures_prp(i) := l_fp_custom_measures_prp(i) / l_factor_by;

    ELSIF l_fp_cus_meas_formats(i) = g_HoursType THEN

      l_fp_custom_measures_ptd(i) := l_fp_custom_measures_ptd(i) / l_effort_UOM;
      l_fp_custom_measures_qtd(i) := l_fp_custom_measures_qtd(i) / l_effort_UOM;
      l_fp_custom_measures_ytd(i) := l_fp_custom_measures_ytd(i) / l_effort_UOM;
      l_fp_custom_measures_itd(i) := l_fp_custom_measures_itd(i) / l_effort_UOM;
      l_fp_custom_measures_ac(i)  := l_fp_custom_measures_ac(i)  / l_effort_UOM;
      l_fp_custom_measures_prp(i) := l_fp_custom_measures_prp(i) / l_effort_UOM;
	END IF;

	IF l_ac_cus_meas_formats(i) = g_CurrencyType THEN

      l_ac_custom_measures_ptd(i) := l_ac_custom_measures_ptd(i) / l_factor_by;
      l_ac_custom_measures_qtd(i) := l_ac_custom_measures_qtd(i) / l_factor_by;
      l_ac_custom_measures_ytd(i) := l_ac_custom_measures_ytd(i) / l_factor_by;
      l_ac_custom_measures_itd(i) := l_ac_custom_measures_itd(i) / l_factor_by;
      l_ac_custom_measures_ac(i)  := l_ac_custom_measures_ac(i) / l_factor_by;
      l_ac_custom_measures_prp(i) := l_ac_custom_measures_prp(i) / l_factor_by;

    ELSIF l_ac_cus_meas_formats(i) = g_HoursType THEN

      l_ac_custom_measures_ptd(i) := l_ac_custom_measures_ptd(i) / l_effort_UOM;
      l_ac_custom_measures_qtd(i) := l_ac_custom_measures_qtd(i) / l_effort_UOM;
      l_ac_custom_measures_ytd(i) := l_ac_custom_measures_ytd(i) / l_effort_UOM;
      l_ac_custom_measures_itd(i) := l_ac_custom_measures_itd(i) / l_effort_UOM;
      l_ac_custom_measures_ac(i)  := l_ac_custom_measures_ac(i)  / l_effort_UOM;
      l_ac_custom_measures_prp(i) := l_ac_custom_measures_prp(i) / l_effort_UOM;
	END IF;

  END LOOP;



  --dbms_output.put_line('p_measure_set_code.LAST='||p_measure_set_code.LAST);
  --IF l_overview_type.COUNT > 1 THEN
  --  dbms_output.put_line('l_overview_type.COUNT ='||l_overview_type.COUNT);
  --END IF;


  --
  -- for every measure, compute the amounts
  --
  FOR i IN 1..p_measure_set_code.LAST	LOOP

    BEGIN

      IF p_measure_set_code(i) = 'PPF_MSR_ACWP' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- Actual cost of Work performed
        x_measure_type(i) := g_CurrencyType; -- then apply radix (thousand point), ask for API
      /* Starts Added for bug 6961599 */
        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_burdened_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_burdened_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_actual_index).ytd_burdened_cost / l_factor_by;
      /* Ends Added for bug 6961599 */
   	    l_itd_value(i):=l_overview_type(l_actual_index).itd_burdened_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_burdened_cost / l_factor_by;


      ELSIF p_measure_set_code(i) = 'PPF_MSR_AF' THEN
        --Additional Funding Amount (PJI_AC_PROJ_F)
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_pji_facts.ptd_additional_funding_amount / l_factor_by;

        l_qtd_value(i):=l_pji_facts.qtd_additional_funding_amount / l_factor_by;

        l_ytd_value(i):=l_pji_facts.ytd_additional_funding_amount / l_factor_by;

        l_itd_value(i):=l_pji_facts.itd_additional_funding_amount / l_factor_by;

        l_ac_value(i):=l_pji_facts.ac_additional_funding_amount / l_factor_by;

        l_prp_value(i):=l_pji_facts.prp_additional_funding_amount / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_B' THEN
        --
        -- Backlog (PJI_AC_PROJ_F) (it IS a currency measure)
        --
        x_measure_type(i) := g_CurrencyType;

 /* Starts added for bug 6961599 */
        l_measure1       := l_pji_facts.ptd_additional_funding_amount;
        l_measure2       := l_pji_facts.ptd_cancelled_funding_amount;
        l_measure3       := l_pji_facts.ptd_funding_adjustment_amount;
        l_measure4       := l_pji_facts.ptd_initial_funding_amount;

        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_ptd_value(i):= (l_measures_total - NVL(l_overview_type(l_actual_index).ptd_revenue,0)) / l_factor_by;


		IF l_ptd_value(i) < 0  THEN
		   l_ptd_value(i) := 0;
		END IF;

        l_measure1       := l_pji_facts.qtd_additional_funding_amount;
        l_measure2       := l_pji_facts.qtd_cancelled_funding_amount;
        l_measure3       := l_pji_facts.qtd_funding_adjustment_amount;
        l_measure4       := l_pji_facts.qtd_initial_funding_amount;

        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_qtd_value(i):= (l_measures_total - NVL(l_overview_type(l_actual_index).qtd_revenue,0)) / l_factor_by;


		IF l_qtd_value(i) < 0  THEN
		   l_qtd_value(i) := 0;
		END IF;

        l_measure1       := l_pji_facts.ytd_additional_funding_amount;
        l_measure2       := l_pji_facts.ytd_cancelled_funding_amount;
        l_measure3       := l_pji_facts.ytd_funding_adjustment_amount;
        l_measure4       := l_pji_facts.ytd_initial_funding_amount;

        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_ytd_value(i):= (l_measures_total - NVL(l_overview_type(l_actual_index).ytd_revenue,0)) / l_factor_by;


		IF l_ytd_value(i) < 0  THEN
		   l_ytd_value(i) := 0;
		END IF;

/* Ends added for bug 6961599 */
/*  commented for 6961599
        l_ptd_value(i)   := NULL;
        l_qtd_value(i)   := NULL;
        l_ytd_value(i)   := NULL;
*/
       -- Added for bug 4194804
        l_measure1       := l_pji_facts.itd_additional_funding_amount;
        l_measure2       := l_pji_facts.itd_cancelled_funding_amount;
        l_measure3       := l_pji_facts.itd_funding_adjustment_amount;
        l_measure4       := l_pji_facts.itd_initial_funding_amount;

        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );


        l_itd_value(i):= (l_measures_total - NVL(l_overview_type(l_actual_index).itd_revenue,0)) / l_factor_by;

/* commented for bug 4194804  (l_pji_facts.itd_additional_funding_amount + l_pji_facts.itd_cancelled_funding_amount +
   l_pji_facts.itd_funding_adjustment_amount + l_pji_facts.itd_initial_funding_amount
	         			 - l_overview_type(l_actual_index).itd_revenue) / l_factor_by;
*/


		IF l_itd_value(i) < 0  THEN
		   l_itd_value(i) := 0;
		END IF;
  		--l_itd_value(i) := 10;

/*        l_ac_value(i):= l_itd_value(i); - Commented for Bug 6485047*/

	/* Revised calculation for At Completion Backlog - Bug 6485047*/
        l_measure1       := l_pji_facts.ac_additional_funding_amount;
        l_measure2       := l_pji_facts.ac_cancelled_funding_amount;
        l_measure3       := l_pji_facts.ac_funding_adjustment_amount;
        l_measure4       := l_pji_facts.ac_initial_funding_amount;

        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );


        l_ac_value(i):= (l_measures_total - NVL(l_overview_type(l_actual_index).ac_revenue,0)) / l_factor_by;
		IF l_ac_value(i) < 0  THEN
		   l_ac_value(i) := 0;
		END IF;


        /*Changes for Bug 6485047 end here*/

        l_prp_value(i):= NULL;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_BA' THEN
        -- Billed Amount (from PJI_AC_PROJ_F)
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_pji_facts.ptd_ar_invoice_amount / l_factor_by; /* Modified for bug 6961599 */
        l_qtd_value(i):=l_pji_facts.qtd_ar_invoice_amount / l_factor_by; /* Modified for bug 6961599 */
        l_ytd_value(i):=l_pji_facts.ytd_ar_invoice_amount / l_factor_by; /* Modified for bug 6961599 */
        l_itd_value(i):=l_pji_facts.itd_ar_invoice_amount / l_factor_by;
        l_ac_value(i) :=l_pji_facts.ac_ar_invoice_amount / l_factor_by;
        l_prp_value(i):=NULL;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_BDR' THEN
        --
        -- Backlog Days Remaining (PJI_AC_PROJ_F)
        --      backlog / revenue * days since inception to date
        --
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):= NULL;
        l_qtd_value(i):= NULL;
        l_ytd_value(i):= NULL;

        IF l_overview_type(l_actual_index).itd_revenue <> 0 THEN

             -- Added for bug 4194804
              l_measure1       := l_pji_facts.itd_additional_funding_amount;
              l_measure2       := l_pji_facts.itd_cancelled_funding_amount;
              l_measure3       := l_pji_facts.itd_funding_adjustment_amount;
              l_measure4       := l_pji_facts.itd_initial_funding_amount;
              l_measures_total := Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                                ,p_measure2 => l_measure2
                                                                ,p_measure3 => l_measure3
                                                                ,p_measure4 => l_measure4
                                                              );

              l_num := l_measures_total - NVL(l_overview_type(l_actual_index).itd_revenue,0);

/* commented for bug 4194804
              l_num := l_pji_facts.itd_additional_funding_amount +
                       l_pji_facts.itd_cancelled_funding_amount +
                       l_pji_facts.itd_funding_adjustment_amount +
                       l_pji_facts.itd_initial_funding_amount -
                       l_overview_type(l_actual_index).itd_revenue; */

          IF l_num < 0 THEN
            l_num := 0;
          END IF;

	        l_num := (l_num / l_overview_type(l_actual_index).itd_revenue) * xDaysSinceITD;
	        l_itd_value(i):= TRUNC(l_num);
        ELSE
          l_itd_value(i):= NULL;
        END IF;

        l_ac_value(i):= NULL; /* Bug 6485047*/
        l_prp_value(i):= NULL;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_BIC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- Billable Cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_bill_burdened_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_bill_burdened_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_actual_index).ytd_bill_burdened_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_actual_index).itd_bill_burdened_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_bill_burdened_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_actual_index).prp_bill_burdened_cost / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_BCPOTC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- Billable Cost % of total cost= Billable Cost / Total Cost
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_actual_index).ptd_burdened_cost <> 0 THEN
          l_ptd_value(i):=100 * l_overview_type(l_actual_index).ptd_bill_burdened_cost /
                          l_overview_type(l_actual_index).ptd_burdened_cost;
        END IF;

        IF l_overview_type(l_actual_index).qtd_burdened_cost <> 0 THEN
          l_qtd_value(i):=100 * l_overview_type(l_actual_index).qtd_bill_burdened_cost /
                          l_overview_type(l_actual_index).qtd_burdened_cost;
        END IF;

        IF l_overview_type(l_actual_index).ytd_burdened_cost <> 0 THEN
          l_ytd_value(i):=100 * l_overview_type(l_actual_index).ytd_bill_burdened_cost /
                          l_overview_type(l_actual_index).ytd_burdened_cost;
        END IF;

        IF l_overview_type(l_actual_index).itd_burdened_cost <> 0 THEN
          l_itd_value(i):=100 * l_overview_type(l_actual_index).itd_bill_burdened_cost /
                          l_overview_type(l_actual_index).itd_burdened_cost;
        END IF;

        IF l_overview_type(l_actual_index).ac_burdened_cost <> 0 THEN
          l_ac_value(i):=100 * l_overview_type(l_actual_index).ac_bill_burdened_cost /
                          l_overview_type(l_actual_index).ac_burdened_cost;
        END IF;

        IF l_overview_type(l_actual_index).prp_burdened_cost <> 0 THEN
          l_prp_value(i):=100 * l_overview_type(l_actual_index).prp_bill_burdened_cost /
                          l_overview_type(l_actual_index).prp_burdened_cost;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_BPTF' THEN
        -- Backlog % of Total Funding (PJI_AC_PROJ_F) =
        --      backlog / (init funding amt + addn funding amt + funding adjustment amt + cancelled funding amt)
        --
        x_measure_type(i) := g_PercentType;

	/* Starts added for bug 6961599 */
	-- FOR PTD
        l_measure1       := l_pji_facts.ptd_initial_funding_amount;
        l_measure2       := l_pji_facts.ptd_additional_funding_amount;
        l_measure3       := l_pji_facts.ptd_funding_adjustment_amount;
        l_measure4       := l_pji_facts.ptd_cancelled_funding_amount;


        l_measures_total := Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                          ,p_measure2 => l_measure2
                                                          ,p_measure3 => l_measure3
                                                          ,p_measure4 => l_measure4
                                                        );
        l_total_funding := l_measures_total;


        IF l_total_funding <> 0 THEN

          l_backlog := l_total_funding - NVL(l_overview_type(l_actual_index).ptd_revenue,0);

          IF l_backlog < 0 THEN
            l_backlog := 0;
          END IF;

          l_num := 100 * l_backlog / l_total_funding;

         l_ptd_value(i):= l_num;

        ELSE

          l_ptd_value(i):= NULL;

        END IF;

			-- FOR QTD
        l_measure1       := l_pji_facts.qtd_initial_funding_amount;
        l_measure2       := l_pji_facts.qtd_additional_funding_amount;
        l_measure3       := l_pji_facts.qtd_funding_adjustment_amount;
        l_measure4       := l_pji_facts.qtd_cancelled_funding_amount;


        l_measures_total := Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                          ,p_measure2 => l_measure2
                                                          ,p_measure3 => l_measure3
                                                          ,p_measure4 => l_measure4
                                                        );
        l_total_funding := l_measures_total;


        IF l_total_funding <> 0 THEN

          l_backlog := l_total_funding - NVL(l_overview_type(l_actual_index).qtd_revenue,0);

          IF l_backlog < 0 THEN
            l_backlog := 0;
          END IF;

          l_num := 100 * l_backlog / l_total_funding;

         l_qtd_value(i):= l_num;

        ELSE

          l_qtd_value(i):= NULL;

        END IF;

			-- FOR YTD
        l_measure1       := l_pji_facts.ytd_initial_funding_amount;
        l_measure2       := l_pji_facts.ytd_additional_funding_amount;
        l_measure3       := l_pji_facts.ytd_funding_adjustment_amount;
        l_measure4       := l_pji_facts.ytd_cancelled_funding_amount;


        l_measures_total := Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                          ,p_measure2 => l_measure2
                                                          ,p_measure3 => l_measure3
                                                          ,p_measure4 => l_measure4
                                                        );
        l_total_funding := l_measures_total;


        IF l_total_funding <> 0 THEN

          l_backlog := l_total_funding - NVL(l_overview_type(l_actual_index).ytd_revenue,0);

          IF l_backlog < 0 THEN
            l_backlog := 0;
          END IF;

          l_num := 100 * l_backlog / l_total_funding;

         l_ytd_value(i):= l_num;

        ELSE

          l_ytd_value(i):= NULL;

        END IF;

	/* Ends added for bug 6961599 */

/* Commented for bug 6961599
        l_ptd_value(i):= NULL;
        l_qtd_value(i):= NULL;
        l_ytd_value(i):= NULL;
*/
             -- Added for bug 4194804
        l_measure1       := l_pji_facts.itd_initial_funding_amount;
        l_measure2       := l_pji_facts.itd_additional_funding_amount;
        l_measure3       := l_pji_facts.itd_funding_adjustment_amount;
        l_measure4       := l_pji_facts.itd_cancelled_funding_amount;

        l_measures_total := Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                          ,p_measure2 => l_measure2
                                                          ,p_measure3 => l_measure3
                                                          ,p_measure4 => l_measure4
                                                        );
        l_total_funding := l_measures_total;

/* Commented for bug 4194804
        l_total_funding := l_pji_facts.itd_initial_funding_amount    +
                           l_pji_facts.itd_additional_funding_amount +
                           l_pji_facts.itd_funding_adjustment_amount +
                           l_pji_facts.itd_cancelled_funding_amount;
*/

        IF l_total_funding <> 0 THEN

          l_backlog := l_total_funding - NVL(l_overview_type(l_actual_index).itd_revenue,0);

          IF l_backlog < 0 THEN
            l_backlog := 0;
          END IF;

          l_num := 100 * l_backlog / l_total_funding;
          l_itd_value(i):=l_num;

        ELSE

          l_itd_value(i):= NULL;

        END IF;


	/* Bug 6485047 - changes start here*/
        l_measure1       := l_pji_facts.ac_initial_funding_amount;
        l_measure2       := l_pji_facts.ac_additional_funding_amount;
        l_measure3       := l_pji_facts.ac_funding_adjustment_amount;
        l_measure4       := l_pji_facts.ac_cancelled_funding_amount;


        l_measures_total := Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                          ,p_measure2 => l_measure2
                                                          ,p_measure3 => l_measure3
                                                          ,p_measure4 => l_measure4
                                                        );
        l_total_funding := l_measures_total;


        IF l_total_funding <> 0 THEN

          l_backlog := l_total_funding - NVL(l_overview_type(l_actual_index).ac_revenue,0);

          IF l_backlog < 0 THEN
            l_backlog := 0;
          END IF;

          l_num := 100 * l_backlog / l_total_funding;

         l_ac_value(i):= l_num;

        ELSE

          l_ac_value(i):= NULL;

        END IF;

	/*Bug 6485047 - changes end here*/

	l_prp_value(i):= NULL;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_BUC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- Burden Cost = Burdened cost - Raw Cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=(l_overview_type(l_actual_index).ptd_burdened_cost -
                                 NVL(l_overview_type(l_actual_index).ptd_raw_cost,0)) / l_factor_by;

        l_qtd_value(i):=(l_overview_type(l_actual_index).qtd_burdened_cost -
                                 NVL(l_overview_type(l_actual_index).qtd_raw_cost,0)) / l_factor_by;

        l_ytd_value(i):=(l_overview_type(l_actual_index).ytd_burdened_cost -
                                 NVL(l_overview_type(l_actual_index).ytd_raw_cost,0)) / l_factor_by;

        l_itd_value(i):=(l_overview_type(l_actual_index).itd_burdened_cost -
                                 NVL(l_overview_type(l_actual_index).itd_raw_cost,0)) / l_factor_by;

        l_ac_value(i):=(l_overview_type(l_actual_index).ac_burdened_cost -
                                NVL(l_overview_type(l_actual_index).ac_raw_cost,0)) / l_factor_by;

        l_prp_value(i):=(l_overview_type(l_actual_index).prp_burdened_cost -
                                 NVL(l_overview_type(l_actual_index).prp_raw_cost,0)) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_BCWP' AND bitand(l_check_plan_versions, g_CstBudget_is_present) = g_CstBudget_is_present THEN
        -- Budget Cost of Work Performed = burd cost * completed percentage
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=NULL;

        l_qtd_value(i):=NULL;

        l_ytd_value(i):=NULL;

        l_itd_value(i):=l_overview_type(l_cost_budget_index).ac_burdened_cost * l_completed_percentage / l_factor_by;

        l_ac_value(i):=l_overview_type(l_cost_budget_index).ac_burdened_cost * l_completed_percentage / l_factor_by;

        l_prp_value(i):=NULL;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_BCWS' AND bitand(l_check_plan_versions, g_CstBudget_is_present) = g_CstBudget_is_present THEN
        -- Budget Cost of Work Scheduled =  BurdenedCost(budget PLAN)
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=NULL;

        l_qtd_value(i):=NULL;

        l_ytd_value(i):=NULL;

        l_itd_value(i):=l_overview_type(l_cost_budget_index).itd_burdened_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_cost_budget_index).ac_burdened_cost / l_factor_by;

        l_prp_value(i):=NULL;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_BEH' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- billable equipment hours
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_bill_equipment_hrs / l_effort_UOM;

        --l_overview_type(l_actual_index).ptd_bill_equipment_hrs

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_bill_equipment_hrs / l_effort_UOM;

        l_ytd_value(i):=l_overview_type(l_actual_index).ytd_bill_equipment_hrs / l_effort_UOM;

        l_itd_value(i):=l_overview_type(l_actual_index).itd_bill_equipment_hrs / l_effort_UOM;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_bill_equipment_hrs / l_effort_UOM;

        l_prp_value(i):=l_overview_type(l_actual_index).prp_bill_equipment_hrs / l_effort_UOM;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_BLH' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- billable labor hours
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_bill_labor_hrs / l_effort_UOM;

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_bill_labor_hrs / l_effort_UOM;

        l_ytd_value(i):=l_overview_type(l_actual_index).ytd_bill_labor_hrs / l_effort_UOM;

        l_itd_value(i):=l_overview_type(l_actual_index).itd_bill_labor_hrs / l_effort_UOM;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_bill_labor_hrs / l_effort_UOM;

        l_prp_value(i):=l_overview_type(l_actual_index).prp_bill_labor_hrs / l_effort_UOM;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_BPEPOTE' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- billable labor hours % = billable labor hours / total labor hrs
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_actual_index).ptd_labor_hrs <> 0 THEN
          l_ptd_value(i):=100 * l_overview_type(l_actual_index).ptd_bill_labor_hrs /
                          l_overview_type(l_actual_index).ptd_labor_hrs;
        END IF;

        IF l_overview_type(l_actual_index).qtd_labor_hrs <> 0 THEN
          l_qtd_value(i):=100 * l_overview_type(l_actual_index).qtd_bill_labor_hrs /
                          l_overview_type(l_actual_index).qtd_labor_hrs;
        END IF;

        IF l_overview_type(l_actual_index).ytd_labor_hrs <> 0 THEN
          l_ytd_value(i):=100 * l_overview_type(l_actual_index).ytd_bill_labor_hrs /
                          l_overview_type(l_actual_index).ytd_labor_hrs;
        END IF;

        IF l_overview_type(l_actual_index).itd_labor_hrs <> 0 THEN
          l_itd_value(i):=100 * l_overview_type(l_actual_index).itd_bill_labor_hrs /
                          l_overview_type(l_actual_index).itd_labor_hrs;
        END IF;

        IF l_overview_type(l_actual_index).ac_labor_hrs <> 0 THEN
          l_ac_value(i):=100 * l_overview_type(l_actual_index).ac_bill_labor_hrs /
                          l_overview_type(l_actual_index).ac_labor_hrs;
        END IF;

        IF l_overview_type(l_actual_index).prp_labor_hrs <> 0 THEN
          l_prp_value(i):=100 * l_overview_type(l_actual_index).prp_bill_labor_hrs /
                          l_overview_type(l_actual_index).prp_labor_hrs;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CA' THEN
        --cash paid (from PJI_AC_PROJ_F)
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_pji_facts.ptd_ar_cash_applied_amount / l_factor_by;

        l_qtd_value(i):=l_pji_facts.qtd_ar_cash_applied_amount / l_factor_by;

        l_ytd_value(i):=l_pji_facts.ytd_ar_cash_applied_amount / l_factor_by;

        l_itd_value(i):=l_pji_facts.itd_ar_cash_applied_amount / l_factor_by;

        l_ac_value(i):=l_pji_facts.ac_ar_cash_applied_amount / l_factor_by;

        l_prp_value(i):=l_pji_facts.prp_ar_cash_applied_amount / l_factor_by;

      ELSIF (p_measure_set_code(i) = 'PPF_MSR_CB2C' OR p_measure_set_code(i) = 'PPF_MSR_PV2') AND bitand(l_check_plan_versions, g_CstBudget2_is_present) = g_CstBudget2_is_present THEN
        -- current Budget 2 Cost
        x_measure_type(i) := g_CurrencyType;

	  	IF p_measure_set_code(i) = 'PPF_MSR_CB2C' THEN
	        l_ptd_value(i):=l_overview_type(l_cost_budget2_index).ptd_burdened_cost / l_factor_by;

	        l_qtd_value(i):=l_overview_type(l_cost_budget2_index).qtd_burdened_cost / l_factor_by;

	        l_ytd_value(i):=l_overview_type(l_cost_budget2_index).ytd_burdened_cost / l_factor_by;

	        l_prp_value(i):=l_overview_type(l_cost_budget2_index).prp_burdened_cost / l_factor_by;

		END IF;

        l_itd_value(i):=l_overview_type(l_cost_budget2_index).itd_burdened_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_cost_budget2_index).ac_burdened_cost / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CB2EH' AND bitand(l_check_plan_versions, g_CstBudget2_is_present) = g_CstBudget2_is_present THEN
        -- current budget 2 equipment hours
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=l_overview_type(l_cost_budget2_index).ptd_equipment_hrs / l_effort_UOM;

        l_qtd_value(i):=l_overview_type(l_cost_budget2_index).qtd_equipment_hrs / l_effort_UOM;

        l_ytd_value(i):=l_overview_type(l_cost_budget2_index).ytd_equipment_hrs / l_effort_UOM;

        l_itd_value(i):=l_overview_type(l_cost_budget2_index).itd_equipment_hrs / l_effort_UOM;

        l_ac_value(i):=l_overview_type(l_cost_budget2_index).ac_equipment_hrs / l_effort_UOM;

        l_prp_value(i):=l_overview_type(l_cost_budget2_index).prp_equipment_hrs / l_effort_UOM;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CB2LH' AND bitand(l_check_plan_versions, g_CstBudget2_is_present) = g_CstBudget2_is_present THEN
        -- current budget 2 labor hours
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=l_overview_type(l_cost_budget2_index).ptd_labor_hrs / l_effort_UOM;

        l_qtd_value(i):=l_overview_type(l_cost_budget2_index).qtd_labor_hrs / l_effort_UOM;

        l_ytd_value(i):=l_overview_type(l_cost_budget2_index).ytd_labor_hrs / l_effort_UOM;

        l_itd_value(i):=l_overview_type(l_cost_budget2_index).itd_labor_hrs / l_effort_UOM;

        l_ac_value(i):=l_overview_type(l_cost_budget2_index).ac_labor_hrs / l_effort_UOM;

        l_prp_value(i):=l_overview_type(l_cost_budget2_index).prp_labor_hrs / l_effort_UOM;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CB2M' /*AND bitand(l_check_plan_versions, g_CstRevBudget2) = g_CstRevBudget2*/ THEN --commented for bug 6958448
        -- Current budget 2 margin =
        --      current budget 2 revenue - current budget 2 cost
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=(nvl(l_overview_type(l_rev_budget2_index).ptd_revenue,0)-
                                 nvl(l_overview_type(l_cost_budget2_index).ptd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_qtd_value(i):=(nvl(l_overview_type(l_rev_budget2_index).qtd_revenue,0)-
                                 nvl(l_overview_type(l_cost_budget2_index).qtd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_ytd_value(i):=(nvl(l_overview_type(l_rev_budget2_index).ytd_revenue,0)-
                                 nvl(l_overview_type(l_cost_budget2_index).ytd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_itd_value(i):=(nvl(l_overview_type(l_rev_budget2_index).itd_revenue,0)-
                                 nvl(l_overview_type(l_cost_budget2_index).itd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_ac_value(i):=(nvl(l_overview_type(l_rev_budget2_index).ac_revenue,0)-
                                nvl(l_overview_type(l_cost_budget2_index).ac_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_prp_value(i):=(nvl(l_overview_type(l_rev_budget2_index).prp_revenue,0)-
                                 nvl(l_overview_type(l_cost_budget2_index).prp_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CB2R' AND bitand(l_check_plan_versions, g_RevBudget2_is_present) = g_RevBudget2_is_present THEN
        -- Current Budget 2 Revenue
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_rev_budget2_index).ptd_revenue / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_rev_budget2_index).qtd_revenue / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_rev_budget2_index).ytd_revenue / l_factor_by;

        l_itd_value(i):=l_overview_type(l_rev_budget2_index).itd_revenue / l_factor_by;

        l_ac_value(i):=l_overview_type(l_rev_budget2_index).ac_revenue / l_factor_by;

        l_prp_value(i):=l_overview_type(l_rev_budget2_index).prp_revenue / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CB2C' AND bitand(l_check_plan_versions, g_CstBudget2_is_present) = g_CstBudget2_is_present THEN
        -- current Budget 2 Raw Cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_cost_budget2_index).ptd_raw_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_cost_budget2_index).qtd_raw_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_cost_budget2_index).ytd_raw_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_cost_budget2_index).itd_raw_cost / l_factor_by;

        l_ac_value(i) :=l_overview_type(l_cost_budget2_index).ac_raw_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_cost_budget2_index).prp_raw_cost / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CB2MP' /*AND bitand(l_check_plan_versions, g_CstRevBudget2) = g_CstRevBudget2 */THEN --commented for bug 6958448
        -- Current budget 2 margin percent =
        --      current budget 2 margin / current budget 2 revenue * 100
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_rev_budget2_index).ptd_revenue <> 0 THEN
            l_num:= nvl(l_overview_type(l_rev_budget2_index).ptd_revenue,0)-nvl(l_overview_type(l_cost_budget2_index).ptd_burdened_cost,0); -- NVL for Bug#6844202
            l_ptd_value(i):=(l_num / l_overview_type(l_rev_budget2_index).ptd_revenue) * 100;
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget2_index).qtd_revenue <> 0 THEN
            l_num:= nvl(l_overview_type(l_rev_budget2_index).qtd_revenue,0)-nvl(l_overview_type(l_cost_budget2_index).qtd_burdened_cost,0); -- NVL for Bug#6844202
            l_qtd_value(i):=(l_num / l_overview_type(l_rev_budget2_index).qtd_revenue) * 100;
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget2_index).ytd_revenue <> 0 THEN
            l_num:= nvl(l_overview_type(l_rev_budget2_index).ytd_revenue,0)-nvl(l_overview_type(l_cost_budget2_index).ytd_burdened_cost,0); -- NVL for Bug#6844202
            l_ytd_value(i):=(l_num / l_overview_type(l_rev_budget2_index).ytd_revenue) * 100;
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget2_index).itd_revenue <> 0 THEN
            l_num:= nvl(l_overview_type(l_rev_budget2_index).itd_revenue,0)-nvl(l_overview_type(l_cost_budget2_index).itd_burdened_cost,0); -- NVL for Bug#6844202
            l_itd_value(i):=(l_num / l_overview_type(l_rev_budget2_index).itd_revenue) * 100;
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget2_index).ac_revenue <> 0 THEN
            l_num:= nvl(l_overview_type(l_rev_budget2_index).ac_revenue,0)-nvl(l_overview_type(l_cost_budget2_index).ac_burdened_cost,0); -- NVL for Bug#6844202
            l_ac_value(i):=(l_num / l_overview_type(l_rev_budget2_index).ac_revenue) * 100;
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget2_index).prp_revenue <> 0 THEN
            l_num:= nvl(l_overview_type(l_rev_budget2_index).prp_revenue,0)-nvl(l_overview_type(l_cost_budget2_index).prp_burdened_cost,0); -- NVL for Bug#6844202
            l_prp_value(i):=(l_num / l_overview_type(l_rev_budget2_index).prp_revenue) * 100;
        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CBBC' AND bitand(l_check_plan_versions, g_CstBudget_is_present) = g_CstBudget_is_present THEN
        -- Current Budget Cost
        x_measure_type(i):= g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_cost_budget_index).ptd_burdened_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_cost_budget_index).qtd_burdened_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_cost_budget_index).ytd_burdened_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_cost_budget_index).itd_burdened_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_cost_budget_index).ac_burdened_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_cost_budget_index).prp_burdened_cost / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CBCTC'
        AND bitand(l_check_plan_versions, g_Actual_CstBudget) = g_Actual_CstBudget THEN
        --
        -- Current Budget Cost - Total Cost
        --
        x_measure_type(i):= g_CurrencyType;

        l_ptd_value(i):=NULL;

        l_qtd_value(i):=NULL;

        l_ytd_value(i):=NULL;

        l_itd_value(i):=(l_overview_type(l_cost_budget_index).itd_burdened_cost -
                        l_overview_type(l_actual_index).ytd_burdened_cost) / l_factor_by;

        l_ac_value(i) :=(l_overview_type(l_cost_budget_index).ac_burdened_cost  -
                        l_overview_type(l_actual_index).ac_burdened_cost) / l_factor_by;

        l_prp_value(i):=NULL;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CBCVOB' AND bitand(l_check_plan_versions, g_CstOrigCstBudget) = g_CstOrigCstBudget THEN
        -- curr budget cost variance from orig budget
        --      (Current Budget Cost - Original Budget Cost)
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):= (l_overview_type(l_cost_budget_index).ptd_burdened_cost -
                         l_overview_type(l_orig_cost_budget_index).ptd_burdened_cost) / l_factor_by;

        l_qtd_value(i):= (l_overview_type(l_cost_budget_index).qtd_burdened_cost -
                         l_overview_type(l_orig_cost_budget_index).qtd_burdened_cost) / l_factor_by;

        l_ytd_value(i):= (l_overview_type(l_cost_budget_index).ytd_burdened_cost -
                         l_overview_type(l_orig_cost_budget_index).ytd_burdened_cost) / l_factor_by;

        l_itd_value(i):= (l_overview_type(l_cost_budget_index).itd_burdened_cost -
                         l_overview_type(l_orig_cost_budget_index).itd_burdened_cost) / l_factor_by;

        l_ac_value(i):=  (l_overview_type(l_cost_budget_index).ac_burdened_cost -
                         l_overview_type(l_orig_cost_budget_index).ac_burdened_cost) / l_factor_by;

        l_prp_value(i):= (l_overview_type(l_cost_budget_index).prp_burdened_cost -
                         l_overview_type(l_orig_cost_budget_index).prp_burdened_cost) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CBEH' AND bitand(l_check_plan_versions, g_CstBudget_is_present) = g_CstBudget_is_present THEN
        -- current budget equipment hours
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=l_overview_type(l_cost_budget_index).ptd_equipment_hrs / l_effort_UOM;

        l_qtd_value(i):=l_overview_type(l_cost_budget_index).qtd_equipment_hrs / l_effort_UOM;

        l_ytd_value(i):=l_overview_type(l_cost_budget_index).ytd_equipment_hrs / l_effort_UOM;

        l_itd_value(i):=l_overview_type(l_cost_budget_index).itd_equipment_hrs / l_effort_UOM;

        l_ac_value(i):=l_overview_type(l_cost_budget_index).ac_equipment_hrs / l_effort_UOM;

        l_prp_value(i):=l_overview_type(l_cost_budget_index).prp_equipment_hrs / l_effort_UOM;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CBLH' AND bitand(l_check_plan_versions, g_CstBudget_is_present) = g_CstBudget_is_present THEN
        -- current budget 2 labor hours
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=l_overview_type(l_cost_budget_index).ptd_labor_hrs / l_effort_UOM;

        l_qtd_value(i):=l_overview_type(l_cost_budget_index).qtd_labor_hrs / l_effort_UOM;

        l_ytd_value(i):=l_overview_type(l_cost_budget_index).ytd_labor_hrs / l_effort_UOM;

        l_itd_value(i):=l_overview_type(l_cost_budget_index).itd_labor_hrs / l_effort_UOM;

        l_ac_value(i):=l_overview_type(l_cost_budget_index).ac_labor_hrs / l_effort_UOM;

        l_prp_value(i):=l_overview_type(l_cost_budget_index).prp_labor_hrs / l_effort_UOM;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CBM' /*AND bitand(l_check_plan_versions, g_CstRevBudget) = g_CstRevBudget*/ THEN --commented for bug 6958448
        --
        -- Current budget margin =
        --      current budget revenue - current budget cost
        --
        x_measure_type(i) := g_CurrencyType;

	l_ptd_value(i):=(nvl(l_overview_type(l_rev_budget_index).ptd_revenue,0)-nvl(l_overview_type(l_cost_budget_index).ptd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_qtd_value(i):=(nvl(l_overview_type(l_rev_budget_index).qtd_revenue,0)-nvl(l_overview_type(l_cost_budget_index).qtd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_ytd_value(i):=(nvl(l_overview_type(l_rev_budget_index).ytd_revenue,0)-nvl(l_overview_type(l_cost_budget_index).ytd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_itd_value(i):=(nvl(l_overview_type(l_rev_budget_index).itd_revenue,0)-nvl(l_overview_type(l_cost_budget_index).itd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_ac_value(i):=(nvl(l_overview_type(l_rev_budget_index).ac_revenue,0)-nvl(l_overview_type(l_cost_budget_index).ac_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_prp_value(i):=(nvl(l_overview_type(l_rev_budget_index).prp_revenue,0)-nvl(l_overview_type(l_cost_budget_index).prp_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CBMP' /*AND bitand(l_check_plan_versions, g_CstRevBudget) = g_CstRevBudget*/ THEN --commented for bug 6958448
        -- Current budget margin percent =
        --      current budget margin / current budget revenue * 100
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_rev_budget_index).ptd_revenue <> 0 THEN
            l_num:= nvl(l_overview_type(l_rev_budget_index).ptd_revenue,0)-nvl(l_overview_type(l_cost_budget_index).ptd_burdened_cost,0); -- NVL for Bug#6844202
            l_ptd_value(i):=(l_num / l_overview_type(l_rev_budget_index).ptd_revenue) * 100;
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget_index).qtd_revenue <> 0 THEN
            l_num:= nvl(l_overview_type(l_rev_budget_index).qtd_revenue,0)-nvl(l_overview_type(l_cost_budget_index).qtd_burdened_cost,0); -- NVL for Bug#6844202
            l_qtd_value(i):=(l_num / l_overview_type(l_rev_budget_index).qtd_revenue) * 100;
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget_index).ytd_revenue <> 0 THEN
            l_num:= nvl(l_overview_type(l_rev_budget_index).ytd_revenue,0)-nvl(l_overview_type(l_cost_budget_index).ytd_burdened_cost,0); -- NVL for Bug#6844202
            l_ytd_value(i):=(l_num / l_overview_type(l_rev_budget_index).ytd_revenue) * 100;
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget_index).itd_revenue <> 0 THEN
            l_num:= nvl(l_overview_type(l_rev_budget_index).itd_revenue,0)-nvl(l_overview_type(l_cost_budget_index).itd_burdened_cost,0); -- NVL for Bug#6844202
            l_itd_value(i):=(l_num / l_overview_type(l_rev_budget_index).itd_revenue) * 100;
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget_index).ac_revenue <> 0 THEN
            l_num:= nvl(l_overview_type(l_rev_budget_index).ac_revenue,0)-nvl(l_overview_type(l_cost_budget_index).ac_burdened_cost,0); -- NVL for Bug#6844202
            l_ac_value(i):=(l_num / l_overview_type(l_rev_budget_index).ac_revenue) * 100;
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget_index).prp_revenue <> 0 THEN
            l_num:= nvl(l_overview_type(l_rev_budget_index).prp_revenue,0)-nvl(l_overview_type(l_cost_budget_index).prp_burdened_cost,0); -- NVL for Bug#6844202
            l_prp_value(i):=(l_num / l_overview_type(l_rev_budget_index).prp_revenue) * 100;
        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CBMPVOB' AND bitand(l_check_plan_versions, g_CstRevBudgetOrigBudget) = g_CstRevBudgetOrigBudget THEN
        -- Current budget margin percent variance from original budget =
        --      (budget rev. * orig. budget burdened cost - orig. budget rev * budget Burden cost)/ (budget rev.*orig.budget Rev)
        --
        x_measure_type(i) := g_IndexType;

        l_num := l_overview_type(l_rev_budget_index).ptd_revenue * l_overview_type(l_orig_rev_budget_index).ptd_revenue;
        IF l_num <> 0 THEN
            l_ptd_value(i):= 100 * (
                             l_overview_type(l_rev_budget_index).ptd_revenue *
                             l_overview_type(l_orig_cost_budget_index).ptd_burdened_cost -
                             l_overview_type(l_orig_rev_budget_index).ptd_revenue *
                             l_overview_type(l_cost_budget_index).ptd_burdened_cost)/l_num;
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_budget_index).qtd_revenue * l_overview_type(l_orig_rev_budget_index).qtd_revenue;
        IF l_num <> 0 THEN
            l_qtd_value(i):= 100 * (
                             l_overview_type(l_rev_budget_index).qtd_revenue *
                             l_overview_type(l_orig_cost_budget_index).qtd_burdened_cost -
                             l_overview_type(l_orig_rev_budget_index).qtd_revenue *
                             l_overview_type(l_cost_budget_index).qtd_burdened_cost)/l_num;
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_budget_index).ytd_revenue * l_overview_type(l_orig_rev_budget_index).ytd_revenue;
        IF l_num <> 0 THEN
            l_ytd_value(i):= 100 * (
                             l_overview_type(l_rev_budget_index).ytd_revenue *
                             l_overview_type(l_orig_cost_budget_index).ytd_burdened_cost -
                             l_overview_type(l_orig_rev_budget_index).ytd_revenue *
                             l_overview_type(l_cost_budget_index).ytd_burdened_cost)/l_num;
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_budget_index).itd_revenue * l_overview_type(l_orig_rev_budget_index).itd_revenue;
        IF l_num <> 0 THEN
            l_itd_value(i):= 100 * (
                             l_overview_type(l_rev_budget_index).itd_revenue *
                             l_overview_type(l_orig_cost_budget_index).itd_burdened_cost -
                             l_overview_type(l_orig_rev_budget_index).itd_revenue *
                             l_overview_type(l_cost_budget_index).itd_burdened_cost)/l_num;
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_budget_index).ac_revenue * l_overview_type(l_orig_rev_budget_index).ac_revenue;
        IF l_num <> 0 THEN
            l_ac_value(i):= 100 * (
                            l_overview_type(l_rev_budget_index).ac_revenue *
                            l_overview_type(l_orig_cost_budget_index).ac_burdened_cost -
                            l_overview_type(l_orig_rev_budget_index).ac_revenue *
                            l_overview_type(l_cost_budget_index).ac_burdened_cost)/l_num;
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_budget_index).prp_revenue * l_overview_type(l_orig_rev_budget_index).prp_revenue;
        IF l_num <> 0 THEN
            l_prp_value(i):= 100 * (
                             l_overview_type(l_rev_budget_index).prp_revenue *
                             l_overview_type(l_orig_cost_budget_index).prp_burdened_cost -
                             l_overview_type(l_orig_rev_budget_index).prp_revenue *
                             l_overview_type(l_cost_budget_index).prp_burdened_cost)/l_num;
        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CBMVOB' AND bitand(l_check_plan_versions, g_CstRevBudgetOrigBudget) = g_CstRevBudgetOrigBudget THEN
        -- Current budget margin variance from original budget =
        --      (budget rev. - budget Burden cost) - (orig budget rev - orig budget burd. cost)
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):= (
                         l_overview_type(l_rev_budget_index).ptd_revenue +
                         l_overview_type(l_orig_cost_budget_index).ptd_burdened_cost -
                         l_overview_type(l_orig_rev_budget_index).ptd_revenue -
                         l_overview_type(l_cost_budget_index).ptd_burdened_cost) / l_factor_by;

        l_qtd_value(i):= (
                         l_overview_type(l_rev_budget_index).qtd_revenue +
                         l_overview_type(l_orig_cost_budget_index).qtd_burdened_cost -
                         l_overview_type(l_orig_rev_budget_index).qtd_revenue -
                         l_overview_type(l_cost_budget_index).qtd_burdened_cost) / l_factor_by;
 /* Corrected the YTD formula for bug 6961599 */
        l_ytd_value(i):= (
                         l_overview_type(l_rev_budget_index).ytd_revenue+
                         l_overview_type(l_orig_cost_budget_index).ytd_burdened_cost -
                         l_overview_type(l_orig_rev_budget_index).ytd_revenue -
                         l_overview_type(l_cost_budget_index).ytd_burdened_cost) / l_factor_by;

        l_itd_value(i):= (
                         l_overview_type(l_rev_budget_index).itd_revenue +
                         l_overview_type(l_orig_cost_budget_index).itd_burdened_cost -
                         l_overview_type(l_orig_rev_budget_index).itd_revenue -
                         l_overview_type(l_cost_budget_index).itd_burdened_cost) / l_factor_by;

        l_ac_value(i) := (
                         l_overview_type(l_rev_budget_index).ac_revenue +
                         l_overview_type(l_orig_cost_budget_index).ac_burdened_cost -
                         l_overview_type(l_orig_rev_budget_index).ac_revenue -
                         l_overview_type(l_cost_budget_index).ac_burdened_cost) / l_factor_by;

        l_prp_value(i):= (
                         l_overview_type(l_rev_budget_index).prp_revenue +
                         l_overview_type(l_orig_cost_budget_index).prp_burdened_cost -
                         l_overview_type(l_orig_rev_budget_index).prp_revenue -
                         l_overview_type(l_cost_budget_index).prp_burdened_cost) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CBR' AND bitand(l_check_plan_versions, g_RevBudget_is_present) = g_RevBudget_is_present THEN
        -- Current Budget Revenue
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_rev_budget_index).ptd_revenue / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_rev_budget_index).qtd_revenue / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_rev_budget_index).ytd_revenue / l_factor_by;

        l_itd_value(i):=l_overview_type(l_rev_budget_index).itd_revenue / l_factor_by;

        l_ac_value(i):=l_overview_type(l_rev_budget_index).ac_revenue / l_factor_by;

        l_prp_value(i):=l_overview_type(l_rev_budget_index).prp_revenue / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CBRC' AND bitand(l_check_plan_versions, g_CstBudget_is_present) = g_CstBudget_is_present THEN
        -- Current Budget Raw Cost
        x_measure_type(i):= g_CurrencyType;

        l_ptd_value(i):= l_overview_type(l_cost_budget_index).ptd_raw_cost / l_factor_by;

        l_qtd_value(i):= l_overview_type(l_cost_budget_index).qtd_raw_cost / l_factor_by;

        l_ytd_value(i):= l_overview_type(l_cost_budget_index).ytd_raw_cost / l_factor_by;

        l_itd_value(i):= l_overview_type(l_cost_budget_index).itd_raw_cost / l_factor_by;

        l_ac_value(i) := l_overview_type(l_cost_budget_index).ac_raw_cost / l_factor_by;

        l_prp_value(i):= l_overview_type(l_cost_budget_index).prp_raw_cost / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CB2RC' AND bitand(l_check_plan_versions, g_CstBudget2_is_present) = g_CstBudget2_is_present THEN
        -- Current Budget 2 Raw Cost
        x_measure_type(i):= g_CurrencyType;

        l_ptd_value(i):= l_overview_type(l_cost_budget2_index).ptd_raw_cost / l_factor_by;

        l_qtd_value(i):= l_overview_type(l_cost_budget2_index).qtd_raw_cost / l_factor_by;

        l_ytd_value(i):= l_overview_type(l_cost_budget2_index).ytd_raw_cost / l_factor_by;

        l_itd_value(i):= l_overview_type(l_cost_budget2_index).itd_raw_cost / l_factor_by;

        l_ac_value(i) := l_overview_type(l_cost_budget2_index).ac_raw_cost / l_factor_by;

        l_prp_value(i):= l_overview_type(l_cost_budget2_index).prp_raw_cost / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CBRVOB' AND bitand(l_check_plan_versions, g_CstOrigCstBudget) = g_CstOrigCstBudget THEN
        -- curr budget Revenue variance from orig budget
        --      (Current Budget Revenue - Original Budget revenue)
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):= (l_overview_type(l_rev_budget_index).ptd_revenue -
                         l_overview_type(l_orig_rev_budget_index).ptd_revenue) / l_factor_by;

        l_qtd_value(i):= (l_overview_type(l_rev_budget_index).qtd_revenue -
                         l_overview_type(l_orig_rev_budget_index).qtd_revenue) / l_factor_by;

        l_ytd_value(i):= (l_overview_type(l_rev_budget_index).ytd_revenue -
                         l_overview_type(l_orig_rev_budget_index).ytd_revenue) / l_factor_by;

        l_itd_value(i):= (l_overview_type(l_rev_budget_index).itd_revenue -
                         l_overview_type(l_orig_rev_budget_index).itd_revenue) / l_factor_by;

        l_ac_value(i) := (l_overview_type(l_rev_budget_index).ac_revenue -
                         l_overview_type(l_orig_rev_budget_index).ac_revenue)  / l_factor_by;

        l_prp_value(i):= (l_overview_type(l_rev_budget_index).prp_revenue -
                         l_overview_type(l_orig_rev_budget_index).prp_revenue) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CCPTC' AND
            bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        --
        -- Capital Cost  % of Total Cost =
        --      Actual Capitalizable Burden Cost / Actual Burden cost
        --
        x_measure_type(i) := g_PercentType;

--        IF l_capital_proj_mask = 1 THEN

          IF l_overview_type(l_actual_index).ptd_burdened_cost <> 0 THEN
              l_ptd_value(i):= 100 * (l_overview_type(l_actual_index).ptd_capitalizable_brdn_cost /
                                             l_overview_type(l_actual_index).ptd_burdened_cost);
          ELSE
              l_ptd_value(i):= NULL;
          END IF;

          IF l_overview_type(l_actual_index).qtd_burdened_cost <> 0 THEN
              l_qtd_value(i):=100 * (l_overview_type(l_actual_index).qtd_capitalizable_brdn_cost /
                                            l_overview_type(l_actual_index).qtd_burdened_cost);
          ELSE
              l_qtd_value(i):= NULL;
          END IF;

          IF l_overview_type(l_actual_index).ytd_burdened_cost <> 0 THEN
              l_ytd_value(i):=100 * (l_overview_type(l_actual_index).ytd_capitalizable_brdn_cost /
                                            l_overview_type(l_actual_index).ytd_burdened_cost);
          ELSE
              l_ytd_value(i):= NULL;
          END IF;

          IF l_overview_type(l_actual_index).itd_burdened_cost <> 0 THEN
              l_itd_value(i):=100 * (l_overview_type(l_actual_index).itd_capitalizable_brdn_cost /
                                            l_overview_type(l_actual_index).itd_burdened_cost);
          ELSE
              l_itd_value(i):= NULL;
          END IF;

          IF l_overview_type(l_actual_index).ac_burdened_cost <> 0 THEN
              l_ac_value(i):=100 * (l_overview_type(l_actual_index).ac_capitalizable_brdn_cost /
                                           l_overview_type(l_actual_index).ac_burdened_cost);
          ELSE
              l_ac_value(i):= NULL;
          END IF;

          IF l_overview_type(l_actual_index).prp_burdened_cost <> 0 THEN
              l_prp_value(i):=100 * (l_overview_type(l_actual_index).prp_capitalizable_brdn_cost /
                                            l_overview_type(l_actual_index).prp_burdened_cost);
          ELSE
              l_prp_value(i):= NULL;
          END IF;

--        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CFRVPF' AND
            bitand(l_check_plan_versions, g_RevFcstRevPriorfcst) = g_RevFcstRevPriorfcst THEN
        --
        -- Current Forecast Revenue Variance from Prior Forecast =
        --   Curr. Forecast Revenue - Prior Forecast Revenue
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=(l_overview_type(l_rev_forecast_index).ptd_revenue -
                        l_overview_type(l_prior_rev_forecast_index).ptd_revenue) / l_factor_by;
/* Un-Commented the code for Bug 7681638 i.e reverted fix of 6961599 */
  /* Commented for bug 6961599 as this measure shouldn't display values for QTD/YTD */
        l_qtd_value(i):=(l_overview_type(l_rev_forecast_index).qtd_revenue -
                        l_overview_type(l_prior_rev_forecast_index).qtd_revenue) / l_factor_by;

        l_ytd_value(i):=(l_overview_type(l_rev_forecast_index).ytd_revenue -
                        l_overview_type(l_prior_rev_forecast_index).ytd_revenue) / l_factor_by;
  /* Commented the code for Bug 7681638 Start
        l_qtd_value(i):=NULL;

        l_ytd_value(i):=NULL;
   Commented the code for Bug 7681638 End */


        l_itd_value(i):=(l_overview_type(l_rev_forecast_index).itd_revenue -
                        l_overview_type(l_prior_rev_forecast_index).itd_revenue) / l_factor_by;

        l_ac_value(i) :=(l_overview_type(l_rev_forecast_index).ac_revenue -
                        l_overview_type(l_prior_rev_forecast_index).ac_revenue)  / l_factor_by;

        l_prp_value(i):=(l_overview_type(l_rev_forecast_index).prp_revenue -
                        l_overview_type(l_prior_rev_forecast_index).prp_revenue) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CM' THEN
        --credit memos (from PJI_AC_PROJ_F)
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_pji_facts.ptd_ar_credit_memo_amount / l_factor_by;

        l_qtd_value(i):=l_pji_facts.qtd_ar_credit_memo_amount / l_factor_by;

        l_ytd_value(i):=l_pji_facts.ytd_ar_credit_memo_amount / l_factor_by;

        l_itd_value(i):=l_pji_facts.itd_ar_credit_memo_amount / l_factor_by;

        l_ac_value(i):=l_pji_facts.ac_ar_credit_memo_amount / l_factor_by;

        l_prp_value(i):=l_pji_facts.prp_ar_credit_memo_amount / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CP' THEN
        --cash paid (duplicate of cash allocated (from PJI_AC_PROJ_F)
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_pji_facts.ptd_ar_cash_applied_amount / l_factor_by;

        l_qtd_value(i):=l_pji_facts.qtd_ar_cash_applied_amount / l_factor_by;

        l_ytd_value(i):=l_pji_facts.ytd_ar_cash_applied_amount / l_factor_by;

        l_itd_value(i):=l_pji_facts.itd_ar_cash_applied_amount / l_factor_by;

        l_ac_value(i):=l_pji_facts.ac_ar_cash_applied_amount / l_factor_by;

        l_prp_value(i):=l_pji_facts.prp_ar_cash_applied_amount / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CPI' AND bitand(l_check_plan_versions, g_Actual_CstBudget) = g_Actual_CstBudget THEN
        -- Cost performance index =
        --      budget burden cost * completed percentage / actual burden cost
        --
        x_measure_type(i) := g_IndexType;

        l_ptd_value(i):=NULL;

        l_qtd_value(i):=NULL;

        l_ytd_value(i):=NULL;

        IF l_overview_type(l_actual_index).itd_burdened_cost <> 0 THEN
            l_itd_value(i):=(l_overview_type(l_cost_budget_index).ac_burdened_cost * l_completed_percentage
                            / l_overview_type(l_actual_index).itd_burdened_cost);
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_actual_index).ac_burdened_cost <> 0 THEN
            l_ac_value(i):=(l_overview_type(l_cost_budget_index).ac_burdened_cost * l_completed_percentage
                            / l_overview_type(l_actual_index).ac_burdened_cost);
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        l_prp_value(i):= NULL;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CRBVOB' AND bitand(l_check_plan_versions, g_RevBudgetOrigbudget) = g_RevBudgetOrigbudget THEN
        --
        -- Current Rev Budget Variance from Original Budget=
        --      (Budget Rev - Orig Budget Rev )
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=(l_overview_type(l_rev_budget_index).ptd_revenue -
                        l_overview_type(l_orig_rev_budget_index).ptd_revenue) / l_factor_by;

        l_qtd_value(i):=(l_overview_type(l_rev_budget_index).qtd_revenue -
                        l_overview_type(l_orig_rev_budget_index).qtd_revenue) / l_factor_by;

        l_ytd_value(i):=(l_overview_type(l_rev_budget_index).ytd_revenue -
                        l_overview_type(l_orig_rev_budget_index).ytd_revenue) / l_factor_by;

        l_itd_value(i):=(l_overview_type(l_rev_budget_index).itd_revenue -
                        l_overview_type(l_orig_rev_budget_index).itd_revenue) / l_factor_by;

        l_ac_value(i) :=(l_overview_type(l_rev_budget_index).ac_revenue -
                        l_overview_type(l_orig_rev_budget_index).ac_revenue)  / l_factor_by;

        l_prp_value(i):=(l_overview_type(l_rev_budget_index).prp_revenue -
                        l_overview_type(l_orig_rev_budget_index).prp_revenue) / l_factor_by;

      ELSIF  p_measure_set_code(i) = 'PPF_MSR_CV' AND bitand(l_check_plan_versions, g_Actual_CstBudget) = g_Actual_CstBudget THEN
        --
        -- Cost variance =
        --      (Actual Burden Cost - Current Budget Cost)
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=(l_overview_type(l_actual_index).ptd_burdened_cost -
                        l_overview_type(l_cost_budget_index).ptd_burdened_cost) / l_factor_by;

        l_qtd_value(i):=(l_overview_type(l_actual_index).qtd_burdened_cost -
                        l_overview_type(l_cost_budget_index).qtd_burdened_cost) / l_factor_by;

        l_ytd_value(i):=(l_overview_type(l_actual_index).ytd_burdened_cost -
                        l_overview_type(l_cost_budget_index).ytd_burdened_cost) / l_factor_by;

        l_itd_value(i):=(l_overview_type(l_actual_index).itd_burdened_cost -
                        l_overview_type(l_cost_budget_index).itd_burdened_cost) / l_factor_by;

        l_ac_value(i):= (l_overview_type(l_actual_index).ac_burdened_cost -
                        l_overview_type(l_cost_budget_index).ac_burdened_cost)  / l_factor_by;

        l_prp_value(i):=(l_overview_type(l_actual_index).prp_burdened_cost -
                        l_overview_type(l_cost_budget_index).prp_burdened_cost) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CZC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present  THEN
        --
        -- capitalized cost
        --
        x_measure_type(i) := g_CurrencyType;

--        IF l_capital_proj_mask = 1 THEN

          l_ptd_value(i):=l_overview_type(l_actual_index).ptd_capitalizable_brdn_cost / l_factor_by;

          l_qtd_value(i):=l_overview_type(l_actual_index).qtd_capitalizable_brdn_cost / l_factor_by;

          l_ytd_value(i):=l_overview_type(l_actual_index).ytd_capitalizable_brdn_cost / l_factor_by;

          l_itd_value(i):=l_overview_type(l_actual_index).itd_capitalizable_brdn_cost / l_factor_by;

          l_ac_value(i):=l_overview_type(l_actual_index).ac_capitalizable_brdn_cost / l_factor_by;

          l_prp_value(i):=l_overview_type(l_actual_index).prp_capitalizable_brdn_cost / l_factor_by;

--        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_DSO' THEN
        --
        -- Days Sales Outstanding (PJI_AC_PROJ_F)
        --      (cash allocated / Billed Amount) * number of days in the period
        --
        x_measure_type(i) := g_DaysType;
/*
        IF l_pji_facts.ptd_ar_invoice_amount <> 0 THEN
            l_num := (l_pji_facts.ptd_ar_cash_applied_amount / l_pji_facts.ptd_ar_invoice_amount) * xDaysInPeriod;
            l_ptd_value(i):=l_num;
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_pji_facts.qtd_ar_invoice_amount <> 0 THEN
            l_num := (l_pji_facts.qtd_ar_cash_applied_amount / l_pji_facts.qtd_ar_invoice_amount) * xDaysInPeriod;
            l_qtd_value(i):=l_num;
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_pji_facts.ytd_ar_invoice_amount <> 0 THEN
            l_num := (l_pji_facts.ytd_ar_cash_applied_amount / l_pji_facts.ytd_ar_invoice_amount) * xDaysInPeriod;
            l_ytd_value(i):=l_num;
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

*/

        IF l_pji_facts.itd_ar_invoice_amount <> 0 THEN
            l_itd_value(i):=(Pji_Rep_Util.MEASURES_TOTAL(l_pji_facts.itd_ar_amount_due,l_pji_facts.itd_ar_amount_overdue) / l_pji_facts.itd_ar_invoice_amount) * xDaysSinceITD;
        ELSE
            l_itd_value(i):= NULL;
        END IF;
/*
        IF l_pji_facts.ac_ar_invoice_amount <> 0 THEN
            l_num := (l_pji_facts.ac_ar_cash_applied_amount / l_pji_facts.ac_ar_invoice_amount) * xDaysInPeriod;
            l_ac_value(i):=l_num;
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_pji_facts.prp_ar_invoice_amount <> 0 THEN
            l_num := (l_pji_facts.prp_ar_cash_applied_amount / l_pji_facts.prp_ar_invoice_amount) * xDaysInPeriod;
            l_prp_value(i):=l_num;
        ELSE
            l_prp_value(i):= NULL;
        END IF;
*/
      ELSIF  p_measure_set_code(i) = 'PPF_MSR_ELM' AND bitand(l_check_plan_versions, g_Actual_is_Present) = g_Actual_is_Present THEN
        --
        -- Effective labor multiplier =
        --      Actual revenue / actual labor burdened cost
        --
        x_measure_type(i) := g_IndexType;
      --Bug fix 7226979
        IF l_overview_type(l_actual_index).ptd_labor_burdened_cost <> 0 THEN
            l_ptd_value(i):=(l_overview_type(l_actual_index).ptd_revenue /
                                           l_overview_type(l_actual_index).ptd_labor_burdened_cost);
        ELSE
            l_ptd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_actual_index).qtd_labor_burdened_cost <> 0 THEN
            l_qtd_value(i):=(l_overview_type(l_actual_index).qtd_revenue /
                                           l_overview_type(l_actual_index).qtd_labor_burdened_cost);
        ELSE
            l_qtd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_actual_index).ytd_labor_burdened_cost <> 0 THEN
            l_ytd_value(i):=(l_overview_type(l_actual_index).ytd_revenue /
                                           l_overview_type(l_actual_index).ytd_labor_burdened_cost);
        ELSE
            l_ytd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_actual_index).itd_labor_burdened_cost <> 0 THEN
            l_itd_value(i):=(l_overview_type(l_actual_index).itd_revenue /
                                           l_overview_type(l_actual_index).itd_labor_burdened_cost);
        ELSE
            l_itd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_actual_index).ac_labor_burdened_cost <> 0 THEN
            l_ac_value(i):=(l_overview_type(l_actual_index).ac_revenue /
                                           l_overview_type(l_actual_index).ac_labor_burdened_cost);
        ELSE
            l_ac_value(i):=NULL;
        END IF;

        IF l_overview_type(l_actual_index).prp_labor_burdened_cost <> 0 THEN
            l_prp_value(i):=(l_overview_type(l_actual_index).prp_revenue /
                                           l_overview_type(l_actual_index).prp_labor_burdened_cost);
        ELSE
            l_prp_value(i):=NULL;
        END IF;
      --Bug fix 7226979

      ELSIF p_measure_set_code(i) = 'PPF_MSR_ETC' AND bitand(l_check_plan_versions, g_Actual_CstFcst) = g_Actual_CstFcst THEN
        --
        -- E.T.C. =
        --      forecast brdn cost - actual burdened cost
        --
        x_measure_type(i) := g_CurrencyType;
/*
        l_ptd_value(i):=(l_overview_type(l_cost_forecast_index).ptd_burdened_cost - NVL(l_overview_type(l_actual_index).ptd_burdened_cost,0)) / l_factor_by;

        l_qtd_value(i):=(l_overview_type(l_cost_forecast_index).qtd_burdened_cost - NVL(l_overview_type(l_actual_index).qtd_burdened_cost,0)) / l_factor_by;

        l_ytd_value(i):=(l_overview_type(l_cost_forecast_index).ytd_burdened_cost - NVL(l_overview_type(l_actual_index).ytd_burdened_cost,0)) / l_factor_by;
*/
        l_itd_value(i):=(l_overview_type(l_cost_forecast_index).ac_burdened_cost - NVL(l_overview_type(l_actual_index).itd_burdened_cost,0)) / l_factor_by;

		IF l_itd_value(i) < 0 THEN
		   l_itd_value(i) := 0;
		END IF;
/*
        l_ac_value(i):=(l_overview_type(l_cost_forecast_index).ac_burdened_cost - NVL(l_overview_type(l_actual_index).ac_burdened_cost,0)) / l_factor_by;

        l_prp_value(i):=(l_overview_type(l_cost_forecast_index).prp_burdened_cost - NVL(l_overview_type(l_actual_index).prp_burdened_cost,0)) / l_factor_by;
*/

      ELSIF p_measure_set_code(i) = 'PPF_MSR_ETCEH' AND bitand(l_check_plan_versions, g_Actual_CstFcst) = g_Actual_CstFcst THEN
        -- ETC equipment hours
        x_measure_type(i) := g_HoursType;
/*
        l_ptd_value(i):=(l_overview_type(l_cost_forecast_index).ptd_equipment_hrs - NVL(l_overview_type(l_actual_index).ptd_equipment_hrs,0)) / l_effort_UOM;

        l_qtd_value(i):=(l_overview_type(l_cost_forecast_index).qtd_equipment_hrs - NVL(l_overview_type(l_actual_index).qtd_equipment_hrs,0)) / l_effort_UOM;

        l_ytd_value(i):=(l_overview_type(l_cost_forecast_index).ytd_equipment_hrs - NVL(l_overview_type(l_actual_index).ytd_equipment_hrs,0)) / l_effort_UOM;
*/
        l_itd_value(i):=(l_overview_type(l_cost_forecast_index).ac_equipment_hrs - NVL(l_overview_type(l_actual_index).itd_equipment_hrs,0)) / l_effort_UOM;

		IF l_itd_value(i) < 0 THEN
		   l_itd_value(i) := 0;
		END IF;

/*
        l_ac_value(i):=(l_overview_type(l_cost_forecast_index).ac_equipment_hrs - NVL(l_overview_type(l_actual_index).ac_equipment_hrs,0)) / l_effort_UOM;

        l_prp_value(i):=(l_overview_type(l_cost_forecast_index).prp_equipment_hrs - NVL(l_overview_type(l_actual_index).prp_equipment_hrs,0)) / l_effort_UOM;
*/
      ELSIF p_measure_set_code(i) = 'PPF_MSR_ETCLH' AND bitand(l_check_plan_versions, g_Actual_CstFcst) = g_Actual_CstFcst THEN
        -- ETC labor hours
        x_measure_type(i) := g_HoursType;

/*        l_ptd_value(i):=(l_overview_type(l_cost_forecast_index).ptd_labor_hrs - NVL(l_overview_type(l_actual_index).ptd_labor_hrs,0)) / l_effort_UOM;

        l_qtd_value(i):=(l_overview_type(l_cost_forecast_index).qtd_labor_hrs - NVL(l_overview_type(l_actual_index).qtd_labor_hrs,0)) / l_effort_UOM;

        l_ytd_value(i):=(l_overview_type(l_cost_forecast_index).ytd_labor_hrs - NVL(l_overview_type(l_actual_index).ytd_labor_hrs,0)) / l_effort_UOM;
*/
        l_itd_value(i):=(l_overview_type(l_cost_forecast_index).ac_labor_hrs - NVL(l_overview_type(l_actual_index).itd_labor_hrs,0)) / l_effort_UOM;

		IF l_itd_value(i) < 0 THEN
		   l_itd_value(i) := 0;
		END IF;

/*
        l_ac_value(i):=(l_overview_type(l_cost_forecast_index).ac_labor_hrs - NVL(l_overview_type(l_actual_index).ac_labor_hrs,0)) / l_effort_UOM;

        l_prp_value(i):=(l_overview_type(l_cost_forecast_index).prp_labor_hrs - NVL(l_overview_type(l_actual_index).prp_labor_hrs,0)) / l_effort_UOM;
  */
      ELSIF p_measure_set_code(i) = 'PPF_MSR_EVCV' AND bitand(l_check_plan_versions, g_Actual_CstBudget) = g_Actual_CstBudget THEN
        --
        -- Earned Value Cost variance =
        --   Budget Burdened Cost * Completed Perc - Actual Burdened Cost
        --
        x_measure_type(i) := g_CurrencyType;

/*        l_ptd_value(i):= (l_overview_type(l_cost_budget_index).ptd_burdened_cost * l_completed_percentage -
                         l_overview_type(l_actual_index).ptd_burdened_cost) / l_factor_by;

        l_qtd_value(i):= (l_overview_type(l_cost_budget_index).qtd_burdened_cost * l_completed_percentage -
                         l_overview_type(l_actual_index).qtd_burdened_cost) / l_factor_by;

        l_ytd_value(i):= (l_overview_type(l_cost_budget_index).ytd_burdened_cost * l_completed_percentage -
                         l_overview_type(l_actual_index).ytd_burdened_cost) / l_factor_by;
*/
        l_itd_value(i):= (l_overview_type(l_cost_budget_index).ac_burdened_cost * l_completed_percentage -
                         l_overview_type(l_actual_index).itd_burdened_cost) / l_factor_by;

        l_ac_value(i) := (l_overview_type(l_cost_budget_index).ac_burdened_cost  * l_completed_percentage -
                         l_overview_type(l_actual_index).ac_burdened_cost) / l_factor_by;

/*        l_prp_value(i):= (l_overview_type(l_cost_budget_index).prp_burdened_cost * l_completed_percentage -
                         l_overview_type(l_actual_index).prp_burdened_cost) / l_factor_by;
  */
      ELSIF p_measure_set_code(i) = 'PPF_MSR_EVSV' AND bitand(l_check_plan_versions, g_CstBudget_is_present) = g_CstBudget_is_present THEN
        --
        -- Earned Value Schedule variance =
        --   Budget Burdened Cost * Completed Perc - Budget Burdened Cost
        --
        x_measure_type(i) := g_CurrencyType;
/*
        l_ptd_value(i):= (l_overview_type(l_cost_budget_index).ptd_burdened_cost * l_completed_percentage -
                         l_overview_type(l_cost_budget_index).ptd_burdened_cost) / l_factor_by;

        l_qtd_value(i):= (l_overview_type(l_cost_budget_index).qtd_burdened_cost * l_completed_percentage -
                         l_overview_type(l_cost_budget_index).qtd_burdened_cost) / l_factor_by;

        l_ytd_value(i):= (l_overview_type(l_cost_budget_index).ytd_burdened_cost * l_completed_percentage -
                         l_overview_type(l_cost_budget_index).ytd_burdened_cost) / l_factor_by;
*/
        l_itd_value(i):= (l_overview_type(l_cost_budget_index).ac_burdened_cost * l_completed_percentage -
                         l_overview_type(l_cost_budget_index).itd_burdened_cost) / l_factor_by;

        l_ac_value(i) := (l_overview_type(l_cost_budget_index).ac_burdened_cost  * l_completed_percentage -
                         l_overview_type(l_cost_budget_index).ac_burdened_cost)  / l_factor_by;

/*        l_prp_value(i):= (l_overview_type(l_cost_budget_index).prp_burdened_cost * l_completed_percentage -
                         l_overview_type(l_cost_budget_index).prp_burdened_cost) / l_factor_by;
  */
      ELSIF p_measure_set_code(i) = 'PPF_MSR_EXP' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present  THEN
        -- expense cost =
        --      actual burd cost - actual capitalizable burd cost
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=(l_overview_type(l_actual_index).ptd_burdened_cost - l_overview_type(l_actual_index).ptd_capitalizable_brdn_cost) / l_factor_by;

        l_qtd_value(i):=(l_overview_type(l_actual_index).qtd_burdened_cost - l_overview_type(l_actual_index).qtd_capitalizable_brdn_cost) / l_factor_by;

        l_ytd_value(i):=(l_overview_type(l_actual_index).ytd_burdened_cost - l_overview_type(l_actual_index).ytd_capitalizable_brdn_cost) / l_factor_by;

        l_itd_value(i):=(l_overview_type(l_actual_index).itd_burdened_cost - l_overview_type(l_actual_index).itd_capitalizable_brdn_cost) / l_factor_by;

        l_ac_value(i):=(l_overview_type(l_actual_index).ac_burdened_cost - l_overview_type(l_actual_index).ac_capitalizable_brdn_cost) / l_factor_by;

        l_prp_value(i):=(l_overview_type(l_actual_index).prp_burdened_cost - l_overview_type(l_actual_index).prp_capitalizable_brdn_cost) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FA' THEN
        -- funding adjustments (from PJI_AC_PROJ_F)
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_pji_facts.ptd_funding_adjustment_amount / l_factor_by;

        l_qtd_value(i):=l_pji_facts.qtd_funding_adjustment_amount / l_factor_by;

        l_ytd_value(i):=l_pji_facts.ytd_funding_adjustment_amount / l_factor_by;

        l_itd_value(i):=l_pji_facts.itd_funding_adjustment_amount / l_factor_by;

        l_ac_value(i):=l_pji_facts.ac_funding_adjustment_amount / l_factor_by;

        l_prp_value(i):=l_pji_facts.prp_funding_adjustment_amount / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FC' AND bitand(l_check_plan_versions, g_CstFcst_is_present) = g_CstFcst_is_present THEN
        --
        -- forecast cost (at completion)
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_cost_forecast_index).ptd_burdened_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_cost_forecast_index).qtd_burdened_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_cost_forecast_index).ytd_burdened_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_cost_forecast_index).itd_burdened_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_cost_forecast_index).ac_burdened_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_cost_forecast_index).prp_burdened_cost / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FCV' AND bitand(l_check_plan_versions, g_CstBudget_CstFcst) = g_CstBudget_CstFcst THEN
        --
        -- forecast cost variance =
        --      (Forecast Burdened Cost - Budget Burdened cost)
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=(l_overview_type(l_cost_forecast_index).ptd_burdened_cost -
                                       l_overview_type(l_cost_budget_index).ptd_burdened_cost) / l_factor_by;

        l_qtd_value(i):=(l_overview_type(l_cost_forecast_index).qtd_burdened_cost -
                                       l_overview_type(l_cost_budget_index).qtd_burdened_cost) / l_factor_by;

        l_ytd_value(i):=(l_overview_type(l_cost_forecast_index).ytd_burdened_cost -
                                       l_overview_type(l_cost_budget_index).ytd_burdened_cost) / l_factor_by;

        l_itd_value(i):=(l_overview_type(l_cost_forecast_index).itd_burdened_cost -
                                       l_overview_type(l_cost_budget_index).itd_burdened_cost) / l_factor_by;

        l_ac_value(i) :=(l_overview_type(l_cost_forecast_index).ac_burdened_cost -
                                       l_overview_type(l_cost_budget_index).ac_burdened_cost) / l_factor_by;

        l_prp_value(i):=(l_overview_type(l_cost_forecast_index).prp_burdened_cost -
                                       l_overview_type(l_cost_budget_index).prp_burdened_cost) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FCVP' AND
            bitand(l_check_plan_versions, g_CstBudget_CstFcst) = g_CstBudget_CstFcst THEN
        --
        -- forecast cost variance % =
        --      (Forecast burdened Cost - Current Cost Budget) / Current Cost Budget * 100
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_cost_budget_index).ptd_burdened_cost <> 0 THEN
            l_ptd_value(i):=100 * (l_overview_type(l_cost_forecast_index).ptd_burdened_cost -
                            l_overview_type(l_cost_budget_index).ptd_burdened_cost) /
                            l_overview_type(l_cost_budget_index).ptd_burdened_cost;
        ELSE
            l_ptd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).qtd_burdened_cost <> 0 THEN
            l_qtd_value(i):=100 * (l_overview_type(l_cost_forecast_index).qtd_burdened_cost -
                            l_overview_type(l_cost_budget_index).qtd_burdened_cost) /
                            l_overview_type(l_cost_budget_index).qtd_burdened_cost;
        ELSE
            l_qtd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ytd_burdened_cost <> 0 THEN
            l_ytd_value(i):=100 * (l_overview_type(l_cost_forecast_index).ytd_burdened_cost -
                            l_overview_type(l_cost_budget_index).ytd_burdened_cost) /
                            l_overview_type(l_cost_budget_index).ytd_burdened_cost;
        ELSE
            l_ytd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).itd_burdened_cost <> 0 THEN
            l_itd_value(i):=100 * (l_overview_type(l_cost_forecast_index).itd_burdened_cost -
                            l_overview_type(l_cost_budget_index).itd_burdened_cost) /
                            l_overview_type(l_cost_budget_index).itd_burdened_cost;
        ELSE
            l_itd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ac_burdened_cost <> 0 THEN
            l_ac_value(i):=100 * (l_overview_type(l_cost_forecast_index).ac_burdened_cost -
                           l_overview_type(l_cost_budget_index).ac_burdened_cost) /
                           l_overview_type(l_cost_budget_index).ac_burdened_cost;
        ELSE
            l_ac_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).prp_burdened_cost <> 0 THEN
            l_prp_value(i):=100 * (l_overview_type(l_cost_forecast_index).prp_burdened_cost -
                            l_overview_type(l_cost_budget_index).prp_burdened_cost) /
                            l_overview_type(l_cost_budget_index).prp_burdened_cost;
        ELSE
            l_prp_value(i):=NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FCVOB' AND bitand(l_check_plan_versions, g_CstFcst_OrigCstBudget) = g_CstFcst_OrigCstBudget  THEN
        --
        -- forecast cost variance from original budget
        --   (forecast Cost - Original budget Cost)
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=
            (l_overview_type(l_cost_forecast_index).ptd_burdened_cost -
                   l_overview_type(l_orig_cost_budget_index).ptd_burdened_cost) / l_factor_by;

        l_qtd_value(i):=
            (l_overview_type(l_cost_forecast_index).qtd_burdened_cost -
                   l_overview_type(l_orig_cost_budget_index).qtd_burdened_cost) / l_factor_by;

        l_ytd_value(i):=
            (l_overview_type(l_cost_forecast_index).ytd_burdened_cost -
                   l_overview_type(l_orig_cost_budget_index).ytd_burdened_cost) / l_factor_by;

        l_itd_value(i):=
            (l_overview_type(l_cost_forecast_index).itd_burdened_cost -
                   l_overview_type(l_orig_cost_budget_index).itd_burdened_cost) / l_factor_by;

        l_ac_value(i):=
            (l_overview_type(l_cost_forecast_index).ac_burdened_cost -
                   l_overview_type(l_orig_cost_budget_index).ac_burdened_cost)  / l_factor_by;

        l_prp_value(i):=
            (l_overview_type(l_cost_forecast_index).prp_burdened_cost -
                   l_overview_type(l_orig_cost_budget_index).prp_burdened_cost) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FEH' AND bitand(l_check_plan_versions, g_CstFcst_is_present) = g_CstFcst_is_present THEN
        -- forecast equipment hours
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=l_overview_type(l_cost_forecast_index).ptd_equipment_hrs / l_effort_UOM;

        l_qtd_value(i):=l_overview_type(l_cost_forecast_index).qtd_equipment_hrs / l_effort_UOM;

        l_ytd_value(i):=l_overview_type(l_cost_forecast_index).ytd_equipment_hrs / l_effort_UOM;


        l_itd_value(i):=l_overview_type(l_cost_forecast_index).itd_equipment_hrs / l_effort_UOM;

        l_ac_value(i):=l_overview_type(l_cost_forecast_index).ac_equipment_hrs / l_effort_UOM;

        l_prp_value(i):=l_overview_type(l_cost_forecast_index).prp_equipment_hrs / l_effort_UOM;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FEHVP' AND bitand(l_check_plan_versions, g_CstBudget_CstFcst) = g_CstBudget_CstFcst THEN
        -- Changed from Actual to Budget for bug 3954485
        --
        -- forecast equip hours variance %
        --      (forecast equip Hours - budget equip Hours) / budget equip Hours * 100
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_cost_budget_index).ptd_equipment_hrs <> 0 THEN
            l_ptd_value(i):=100 * (l_overview_type(l_cost_forecast_index).ptd_equipment_hrs -
                                  l_overview_type(l_cost_budget_index).ptd_equipment_hrs) /
                                  l_overview_type(l_cost_budget_index).ptd_equipment_hrs;
        ELSE
            l_ptd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).qtd_equipment_hrs <> 0 THEN
            l_qtd_value(i):=100 * (l_overview_type(l_cost_forecast_index).qtd_equipment_hrs -
                                  l_overview_type(l_cost_budget_index).qtd_equipment_hrs) /
                                  l_overview_type(l_cost_budget_index).qtd_equipment_hrs;
        ELSE
            l_qtd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ytd_equipment_hrs <> 0 THEN
            l_ytd_value(i):=100 * (l_overview_type(l_cost_forecast_index).ytd_equipment_hrs -
                                  l_overview_type(l_cost_budget_index).ytd_equipment_hrs) /
                                  l_overview_type(l_cost_budget_index).ytd_equipment_hrs;
        ELSE
            l_ytd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).itd_equipment_hrs <> 0 THEN
            l_itd_value(i):=100 * (l_overview_type(l_cost_forecast_index).itd_equipment_hrs -
                                  l_overview_type(l_cost_budget_index).itd_equipment_hrs) /
                                  l_overview_type(l_cost_budget_index).itd_equipment_hrs;
        ELSE
            l_itd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ac_equipment_hrs <> 0 THEN
            l_ac_value(i):=100 * (l_overview_type(l_cost_forecast_index).ac_equipment_hrs -
                                  l_overview_type(l_cost_budget_index).ac_equipment_hrs) /
                                  l_overview_type(l_cost_budget_index).ac_equipment_hrs;
        ELSE
            l_ac_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).prp_equipment_hrs <> 0 THEN
            l_prp_value(i):=100 * (l_overview_type(l_cost_forecast_index).prp_equipment_hrs -
                                  l_overview_type(l_cost_budget_index).prp_equipment_hrs) /
                                  l_overview_type(l_cost_budget_index).prp_equipment_hrs;
        ELSE
            l_prp_value(i):=NULL;
        END IF;

      ELSIF (p_measure_set_code(i) = 'PPF_MSR_FPH') AND bitand(l_check_plan_versions, g_CstFcst_is_present) = g_CstFcst_is_present THEN
        -- forecast people hours
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):= l_overview_type(l_cost_forecast_index).ptd_labor_hrs / l_effort_UOM;

        l_qtd_value(i):= l_overview_type(l_cost_forecast_index).qtd_labor_hrs / l_effort_UOM;

        l_ytd_value(i):= l_overview_type(l_cost_forecast_index).ytd_labor_hrs / l_effort_UOM;

        l_itd_value(i):=l_overview_type(l_cost_forecast_index).itd_labor_hrs / l_effort_UOM;

        l_ac_value(i):=l_overview_type(l_cost_forecast_index).ac_labor_hrs / l_effort_UOM;

        l_prp_value(i):= l_overview_type(l_cost_forecast_index).prp_labor_hrs / l_effort_UOM;

      ELSIF (p_measure_set_code(i) = 'PPF_MSR_FPHVP') AND bitand(l_check_plan_versions, g_CstBudget_CstFcst) = g_CstBudget_CstFcst THEN
        -- Changed from Actual to Budget for bug 3954485
        --
        -- forecast labor hours variance %
        --      (forecast Labor Hours - budget Labor Hours) / budget Labor Hours * 100
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_cost_budget_index).ptd_labor_hrs <> 0 THEN
            l_ptd_value(i):=100 * (l_overview_type(l_cost_forecast_index).ptd_labor_hrs -
                                  l_overview_type(l_cost_budget_index).ptd_labor_hrs) /
                                  l_overview_type(l_cost_budget_index).ptd_labor_hrs;
        ELSE
            l_ptd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).qtd_labor_hrs <> 0 THEN
            l_qtd_value(i):=100 * (l_overview_type(l_cost_forecast_index).qtd_labor_hrs -
                                  l_overview_type(l_cost_budget_index).qtd_labor_hrs) /
                                  l_overview_type(l_cost_budget_index).qtd_labor_hrs;
        ELSE
            l_qtd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ytd_labor_hrs <> 0 THEN
            l_ytd_value(i):=100 * (l_overview_type(l_cost_forecast_index).ytd_labor_hrs -
                                  l_overview_type(l_cost_budget_index).ytd_labor_hrs) /
                                  l_overview_type(l_cost_budget_index).ytd_labor_hrs;
        ELSE
            l_ytd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).itd_labor_hrs <> 0 THEN
            l_itd_value(i):=100 * (l_overview_type(l_cost_forecast_index).itd_labor_hrs -
                                  l_overview_type(l_cost_budget_index).itd_labor_hrs) /
                                  l_overview_type(l_cost_budget_index).itd_labor_hrs;
        ELSE
            l_itd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ac_labor_hrs <> 0 THEN
            l_ac_value(i):=100 * (l_overview_type(l_cost_forecast_index).ac_labor_hrs -
                                  l_overview_type(l_cost_budget_index).ac_labor_hrs) /
                                  l_overview_type(l_cost_budget_index).ac_labor_hrs;
        ELSE
            l_ac_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).prp_labor_hrs <> 0 THEN
            l_prp_value(i):=100 * (l_overview_type(l_cost_forecast_index).prp_labor_hrs -
                                  l_overview_type(l_cost_budget_index).prp_labor_hrs) /
                                  l_overview_type(l_cost_budget_index).prp_labor_hrs;
        ELSE
            l_prp_value(i):=NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FM' /*AND bitand(l_check_plan_versions, g_CstRevFcst) = g_CstRevFcst*/ THEN --commented for bug 6958448
        --
        -- forecast margin =
        --      Forecast Revenue - Forecast Burdened Cost
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=(nvl(l_overview_type(l_rev_forecast_index).ptd_revenue,0) - nvl(l_overview_type(l_cost_forecast_index).ptd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_qtd_value(i):=(nvl(l_overview_type(l_rev_forecast_index).qtd_revenue,0) - nvl(l_overview_type(l_cost_forecast_index).qtd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_ytd_value(i):=(nvl(l_overview_type(l_rev_forecast_index).ytd_revenue,0) - nvl(l_overview_type(l_cost_forecast_index).ytd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_itd_value(i):=(nvl(l_overview_type(l_rev_forecast_index).itd_revenue,0) - nvl(l_overview_type(l_cost_forecast_index).itd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_ac_value(i):=(nvl(l_overview_type(l_rev_forecast_index).ac_revenue,0) - nvl(l_overview_type(l_cost_forecast_index).ac_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_prp_value(i):=(nvl(l_overview_type(l_rev_forecast_index).prp_revenue,0) - nvl(l_overview_type(l_cost_forecast_index).prp_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FMP' /*AND bitand(l_check_plan_versions, g_CstRevFcst) = g_CstRevFcst */ THEN --commented for bug 6958448
        --
        -- forecast margin percent =
        --      (Forecast Revenue - Forecast Cost) / Forecast Revenue * 100
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_rev_forecast_index).ptd_revenue <> 0 THEN
            l_ptd_value(i):= 100*(nvl(l_overview_type(l_rev_forecast_index).ptd_revenue,0) -
                                    nvl(l_overview_type(l_cost_forecast_index).ptd_burdened_cost,0)) /
                                    l_overview_type(l_rev_forecast_index).ptd_revenue; -- NVL for Bug#6844202
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_forecast_index).qtd_revenue <> 0 THEN
            l_qtd_value(i):= 100*(nvl(l_overview_type(l_rev_forecast_index).qtd_revenue,0) -
                                  nvl(l_overview_type(l_cost_forecast_index).qtd_burdened_cost,0))/
                                  l_overview_type(l_rev_forecast_index).qtd_revenue; -- NVL for Bug#6844202
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_forecast_index).ytd_revenue <> 0 THEN
            l_ytd_value(i):= 100*(nvl(l_overview_type(l_rev_forecast_index).ytd_revenue,0) -
                                  nvl(l_overview_type(l_cost_forecast_index).ytd_burdened_cost,0))/
                                  l_overview_type(l_rev_forecast_index).ytd_revenue; -- NVL for Bug#6844202
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_forecast_index).itd_revenue <> 0 THEN
            l_itd_value(i):= 100*(nvl(l_overview_type(l_rev_forecast_index).itd_revenue,0) -
                                  nvl(l_overview_type(l_cost_forecast_index).itd_burdened_cost,0))/
                                  l_overview_type(l_rev_forecast_index).itd_revenue; -- NVL for Bug#6844202
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_forecast_index).ac_revenue <> 0 THEN
            l_ac_value(i):= 100*(nvl(l_overview_type(l_rev_forecast_index).ac_revenue,0) -
                                  nvl(l_overview_type(l_cost_forecast_index).ac_burdened_cost,0))/
                                  l_overview_type(l_rev_forecast_index).ac_revenue; -- NVL for Bug#6844202
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_forecast_index).prp_revenue <> 0 THEN
            l_prp_value(i):= 100*(nvl(l_overview_type(l_rev_forecast_index).prp_revenue,0) -
                                  nvl(l_overview_type(l_cost_forecast_index).prp_burdened_cost,0))/
                                  l_overview_type(l_rev_forecast_index).prp_revenue; -- NVL for Bug#6844202
        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FMPV' AND bitand(l_check_plan_versions, g_CstRevBudgetFcst) = g_CstRevBudgetFcst THEN
        --
        -- forecast margin percent variance =
        --      ((rev forecast * budget burden bost) - (rev budget * forecast burden cost)) / (rev forecast * rev budget)
        --
        x_measure_type(i) := g_IndexType;

        l_num := l_overview_type(l_rev_forecast_index).ptd_revenue * l_overview_type(l_rev_budget_index).ptd_revenue;
        IF l_num <> 0 THEN
            l_ptd_value(i):= (100*(
                             l_overview_type(l_rev_forecast_index).ptd_revenue * l_overview_type(l_cost_budget_index).ptd_burdened_cost -
                             l_overview_type(l_rev_budget_index).ptd_revenue * l_overview_type(l_cost_forecast_index).ptd_burdened_cost
                             )/l_num);
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_forecast_index).qtd_revenue * l_overview_type(l_rev_budget_index).qtd_revenue;
        IF l_num <> 0 THEN
            l_qtd_value(i):= (100*(
                             l_overview_type(l_rev_forecast_index).qtd_revenue * l_overview_type(l_cost_budget_index).qtd_burdened_cost -
                             l_overview_type(l_rev_budget_index).qtd_revenue * l_overview_type(l_cost_forecast_index).qtd_burdened_cost
                             )/l_num);
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_forecast_index).ytd_revenue * l_overview_type(l_rev_budget_index).ytd_revenue;
        IF l_num <> 0 THEN
            l_ytd_value(i):= (100*(
                             l_overview_type(l_rev_forecast_index).ytd_revenue * l_overview_type(l_cost_budget_index).ytd_burdened_cost -
                             l_overview_type(l_rev_budget_index).ytd_revenue * l_overview_type(l_cost_forecast_index).ytd_burdened_cost
                             )/l_num);
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_forecast_index).itd_revenue * l_overview_type(l_rev_budget_index).itd_revenue;
        IF l_num <> 0 THEN
            l_itd_value(i):= (100*(
                             l_overview_type(l_rev_forecast_index).itd_revenue * l_overview_type(l_cost_budget_index).itd_burdened_cost -
                             l_overview_type(l_rev_budget_index).itd_revenue * l_overview_type(l_cost_forecast_index).itd_burdened_cost
                             )/l_num);
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_forecast_index).ac_revenue * l_overview_type(l_rev_budget_index).ac_revenue;
        IF l_num <> 0 THEN
            l_ac_value(i):=  (100*(l_overview_type(
                             l_rev_forecast_index).ac_revenue * l_overview_type(l_cost_budget_index).ac_burdened_cost -
                             l_overview_type(l_rev_budget_index).ac_revenue * l_overview_type(l_cost_forecast_index).ac_burdened_cost
                             )/l_num);
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_forecast_index).prp_revenue * l_overview_type(l_rev_budget_index).prp_revenue;
        IF l_num <> 0 THEN
            l_prp_value(i):= (100*(
                             l_overview_type(l_rev_forecast_index).prp_revenue * l_overview_type(l_cost_budget_index).prp_burdened_cost -
                             l_overview_type(l_rev_budget_index).prp_revenue * l_overview_type(l_cost_forecast_index).prp_burdened_cost
                             )/l_num);
        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FMPVOB' AND bitand(l_check_plan_versions, g_CstRevOrigbudgetFcst) = g_CstRevOrigbudgetFcst THEN
        --
        -- forecast margin percent variance from orig. budget =
        --      ((rev forecast * orig budget burden cost) - (rev orig budget * forecast burden cost)) / (rev forecast * rev orig budget)
        --
        x_measure_type(i) := g_IndexType;

        l_num := l_overview_type(l_rev_forecast_index).ptd_revenue * l_overview_type(l_orig_rev_budget_index).ptd_revenue;
        IF l_num <> 0 THEN
            l_ptd_value(i):= 100*(l_overview_type(l_rev_forecast_index).ptd_revenue *
                             l_overview_type(l_orig_cost_budget_index).ptd_burdened_cost -
                             l_overview_type(l_orig_rev_budget_index).ptd_revenue *
                             l_overview_type(l_cost_forecast_index).ptd_burdened_cost)/l_num;
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_forecast_index).qtd_revenue * l_overview_type(l_orig_rev_budget_index).qtd_revenue;
        IF l_num <> 0 THEN
            l_qtd_value(i):= 100*(l_overview_type(l_rev_forecast_index).qtd_revenue *
                             l_overview_type(l_orig_cost_budget_index).qtd_burdened_cost -
                             l_overview_type(l_orig_rev_budget_index).qtd_revenue *
                             l_overview_type(l_cost_forecast_index).qtd_burdened_cost)/l_num;
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_forecast_index).ytd_revenue * l_overview_type(l_orig_rev_budget_index).ytd_revenue;
        IF l_num <> 0 THEN
            l_ytd_value(i):= 100*(l_overview_type(l_rev_forecast_index).ytd_revenue *
                             l_overview_type(l_orig_cost_budget_index).ytd_burdened_cost -
                             l_overview_type(l_orig_rev_budget_index).ytd_revenue *
                             l_overview_type(l_cost_forecast_index).ytd_burdened_cost)/l_num;
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_forecast_index).itd_revenue * l_overview_type(l_orig_rev_budget_index).itd_revenue;
        IF l_num <> 0 THEN
            l_itd_value(i):= 100*(l_overview_type(l_rev_forecast_index).itd_revenue *
                             l_overview_type(l_orig_cost_budget_index).itd_burdened_cost -
                             l_overview_type(l_orig_rev_budget_index).itd_revenue *
                             l_overview_type(l_cost_forecast_index).itd_burdened_cost)/l_num;
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_forecast_index).ac_revenue * l_overview_type(l_orig_rev_budget_index).ac_revenue;
        IF l_num <> 0 THEN
            l_ac_value(i) := 100*(l_overview_type(l_rev_forecast_index).ac_revenue *
                             l_overview_type(l_orig_cost_budget_index).ac_burdened_cost -
                             l_overview_type(l_orig_rev_budget_index).ac_revenue *
                             l_overview_type(l_cost_forecast_index).ac_burdened_cost)/l_num;
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_forecast_index).prp_revenue * l_overview_type(l_orig_rev_budget_index).prp_revenue;
        IF l_num <> 0 THEN
            l_prp_value(i):= 100*(l_overview_type(l_rev_forecast_index).prp_revenue *
                             l_overview_type(l_orig_cost_budget_index).prp_burdened_cost -
                             l_overview_type(l_orig_rev_budget_index).prp_revenue *
                             l_overview_type(l_cost_forecast_index).prp_burdened_cost)/l_num;
        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FMPVPFC' AND bitand(l_check_plan_versions, g_CstRevFcstPriorfcst) = g_CstRevFcstPriorfcst THEN
        --
        -- forecast margin percent variance from prior forecast =
        -- 100*(rev prior forecast * (rev forecast - fcst burden cost) - rev forecast * (rev prior fcst - prior fcst burden cost)) / (rev forecast * rev prior fcst)
        -- Bug 5523168 : Corrected the formula to compute PPF_MSR_FMPVPFC
        --
        x_measure_type(i) := g_IndexType;

        l_num := l_overview_type(l_rev_forecast_index).ptd_revenue * l_overview_type(l_prior_rev_forecast_index).ptd_revenue;
        IF l_num <> 0 THEN
            l_ptd_value(i):= 100*(l_overview_type(l_prior_rev_forecast_index).ptd_revenue *
             (l_overview_type(l_rev_forecast_index).ptd_revenue - l_overview_type(l_cost_forecast_index).ptd_burdened_cost)
                             - l_overview_type(l_rev_forecast_index).ptd_revenue *
	     (l_overview_type(l_prior_rev_forecast_index).ptd_revenue - l_overview_type(l_prior_cost_forecast_index).ptd_burdened_cost)
			     )/l_num;
        ELSE
            l_ptd_value(i):= NULL;
        END IF;
/* Un-Commented the code for Bug 7681638 i.e reverted fix of 6961599 */
     /* Commented for bug 6961599 as this measure shouldn't display values for QTD/YDT */
        l_num := l_overview_type(l_rev_forecast_index).qtd_revenue * l_overview_type(l_prior_rev_forecast_index).qtd_revenue;
        IF l_num <> 0 THEN
            l_qtd_value(i):= 100*(l_overview_type(l_prior_rev_forecast_index).qtd_revenue *
             (l_overview_type(l_rev_forecast_index).qtd_revenue - l_overview_type(l_cost_forecast_index).qtd_burdened_cost)
                             - l_overview_type(l_rev_forecast_index).qtd_revenue *
	     (l_overview_type(l_prior_rev_forecast_index).qtd_revenue - l_overview_type(l_prior_cost_forecast_index).qtd_burdened_cost)
			     )/l_num;
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_forecast_index).ytd_revenue * l_overview_type(l_prior_rev_forecast_index).ytd_revenue;
        IF l_num <> 0 THEN
            l_ytd_value(i):= 100*(l_overview_type(l_prior_rev_forecast_index).ytd_revenue *
             (l_overview_type(l_rev_forecast_index).ytd_revenue - l_overview_type(l_cost_forecast_index).ytd_burdened_cost)
                             - l_overview_type(l_rev_forecast_index).ytd_revenue *
	     (l_overview_type(l_prior_rev_forecast_index).ytd_revenue - l_overview_type(l_prior_cost_forecast_index).ytd_burdened_cost)
			     )/l_num;
        ELSE
            l_ytd_value(i):= NULL;
        END IF;
      /* Commented the code for Bug 7681638 Start
	l_qtd_value(i):= NULL;
	l_ytd_value(i):= NULL;
	     Commented the code for Bug 7681638 End */

        l_num := l_overview_type(l_rev_forecast_index).itd_revenue * l_overview_type(l_prior_rev_forecast_index).itd_revenue;
        IF l_num <> 0 THEN
            l_itd_value(i):= 100*(l_overview_type(l_prior_rev_forecast_index).itd_revenue *
             (l_overview_type(l_rev_forecast_index).itd_revenue - l_overview_type(l_cost_forecast_index).itd_burdened_cost)
                             - l_overview_type(l_rev_forecast_index).itd_revenue *
	     (l_overview_type(l_prior_rev_forecast_index).itd_revenue - l_overview_type(l_prior_cost_forecast_index).itd_burdened_cost)
			     )/l_num;
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_forecast_index).ac_revenue * l_overview_type(l_prior_rev_forecast_index).ac_revenue;
        IF l_num <> 0 THEN
            l_ac_value(i):= 100*(l_overview_type(l_prior_rev_forecast_index).ac_revenue *
             (l_overview_type(l_rev_forecast_index).ac_revenue - l_overview_type(l_cost_forecast_index).ac_burdened_cost)
                             - l_overview_type(l_rev_forecast_index).ac_revenue *
	     (l_overview_type(l_prior_rev_forecast_index).ac_revenue - l_overview_type(l_prior_cost_forecast_index).ac_burdened_cost)
			     )/l_num;
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_rev_forecast_index).prp_revenue * l_overview_type(l_prior_rev_forecast_index).prp_revenue;
        IF l_num <> 0 THEN
            l_prp_value(i):= 100*(l_overview_type(l_prior_rev_forecast_index).prp_revenue *
             (l_overview_type(l_rev_forecast_index).prp_revenue - l_overview_type(l_cost_forecast_index).prp_burdened_cost)
                             - l_overview_type(l_rev_forecast_index).prp_revenue *
	     (l_overview_type(l_prior_rev_forecast_index).prp_revenue - l_overview_type(l_prior_cost_forecast_index).prp_burdened_cost)
			     )/l_num;
        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FMV' AND bitand(l_check_plan_versions, g_CstRevBudgetFcst) = g_CstRevBudgetFcst THEN
        --
        -- forecast margin variance =
        --      (forecast rev - rev budget ) - (forecast burden cost - budget burden cost)
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):= (l_overview_type(l_rev_forecast_index).ptd_revenue +
                         l_overview_type(l_cost_budget_index).ptd_burdened_cost -
                         l_overview_type(l_rev_budget_index).ptd_revenue -
                         l_overview_type(l_cost_forecast_index).ptd_burdened_cost) / l_factor_by;

        l_qtd_value(i):= (l_overview_type(l_rev_forecast_index).qtd_revenue +
                         l_overview_type(l_cost_budget_index).qtd_burdened_cost -
                         l_overview_type(l_rev_budget_index).qtd_revenue -
                         l_overview_type(l_cost_forecast_index).qtd_burdened_cost) / l_factor_by;

        l_ytd_value(i):= (l_overview_type(l_rev_forecast_index).ytd_revenue +
                         l_overview_type(l_cost_budget_index).ytd_burdened_cost -
                         l_overview_type(l_rev_budget_index).ytd_revenue -
                         l_overview_type(l_cost_forecast_index).ytd_burdened_cost) / l_factor_by;

        l_itd_value(i):= (l_overview_type(l_rev_forecast_index).itd_revenue +
                         l_overview_type(l_cost_budget_index).itd_burdened_cost -
                         l_overview_type(l_rev_budget_index).itd_revenue -
                         l_overview_type(l_cost_forecast_index).itd_burdened_cost) / l_factor_by;

        l_ac_value(i) := (l_overview_type(l_rev_forecast_index).ac_revenue +
                         l_overview_type(l_cost_budget_index).ac_burdened_cost -
                         l_overview_type(l_rev_budget_index).ac_revenue -
                         l_overview_type(l_cost_forecast_index).ac_burdened_cost)  / l_factor_by;

        l_prp_value(i):= (l_overview_type(l_rev_forecast_index).prp_revenue +
                         l_overview_type(l_cost_budget_index).prp_burdened_cost -
                         l_overview_type(l_rev_budget_index).prp_revenue -
                         l_overview_type(l_cost_forecast_index).prp_burdened_cost) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FMVOB' AND bitand(l_check_plan_versions, g_CstRevOrigbudgetFcst) = g_CstRevOrigbudgetFcst THEN
        --
        -- forecast margin variance from orig budget =
        --      (rev forecast + orig budget burden cost - rev orig budget - forecast burden cost)
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):= (l_overview_type(l_rev_forecast_index).ptd_revenue +
                         l_overview_type(l_orig_cost_budget_index).ptd_burdened_cost -
                         l_overview_type(l_orig_rev_budget_index).ptd_revenue -
                         l_overview_type(l_cost_forecast_index).ptd_burdened_cost) / l_factor_by;

        l_qtd_value(i):= (l_overview_type(l_rev_forecast_index).qtd_revenue +
                         l_overview_type(l_orig_cost_budget_index).qtd_burdened_cost -
                         l_overview_type(l_orig_rev_budget_index).qtd_revenue -
                         l_overview_type(l_cost_forecast_index).qtd_burdened_cost) / l_factor_by;

        l_ytd_value(i):= (l_overview_type(l_rev_forecast_index).ytd_revenue +
                         l_overview_type(l_orig_cost_budget_index).ytd_burdened_cost -
                         l_overview_type(l_orig_rev_budget_index).ytd_revenue -
                         l_overview_type(l_cost_forecast_index).ytd_burdened_cost) / l_factor_by;

        l_itd_value(i):= (l_overview_type(l_rev_forecast_index).itd_revenue +
                         l_overview_type(l_orig_cost_budget_index).itd_burdened_cost -
                         l_overview_type(l_orig_rev_budget_index).itd_revenue -
                         l_overview_type(l_cost_forecast_index).itd_burdened_cost) / l_factor_by;

        l_ac_value(i) := (l_overview_type(l_rev_forecast_index).ac_revenue +
                         l_overview_type(l_orig_cost_budget_index).ac_burdened_cost -
                         l_overview_type(l_orig_rev_budget_index).ac_revenue -
                         l_overview_type(l_cost_forecast_index).ac_burdened_cost) / l_factor_by;

        l_prp_value(i):= (l_overview_type(l_rev_forecast_index).prp_revenue +
                         l_overview_type(l_orig_cost_budget_index).prp_burdened_cost -
                         l_overview_type(l_orig_rev_budget_index).prp_revenue -
                         l_overview_type(l_cost_forecast_index).prp_burdened_cost) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_CFMVPF' AND bitand(l_check_plan_versions, g_CstRevFcstPriorfcst) = g_CstRevFcstPriorfcst THEN
        --
        -- Current forecast margin variance from prior forecast =
        --      (forecast rev + prior forecast burdened cost - prior forecast rev - forecast burden cost)
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):= (l_overview_type(l_rev_forecast_index).ptd_revenue +
                         l_overview_type(l_prior_cost_forecast_index).ptd_burdened_cost -
                         l_overview_type(l_prior_rev_forecast_index).ptd_revenue -
                         l_overview_type(l_cost_forecast_index).ptd_burdened_cost) / l_factor_by;

        l_qtd_value(i):= (l_overview_type(l_rev_forecast_index).qtd_revenue +
                         l_overview_type(l_prior_cost_forecast_index).qtd_burdened_cost -
                         l_overview_type(l_prior_rev_forecast_index).qtd_revenue -
                         l_overview_type(l_cost_forecast_index).qtd_burdened_cost) / l_factor_by;

        l_ytd_value(i):= (l_overview_type(l_rev_forecast_index).ytd_revenue +
                         l_overview_type(l_prior_cost_forecast_index).ytd_burdened_cost -
                         l_overview_type(l_prior_rev_forecast_index).ytd_revenue -
                         l_overview_type(l_cost_forecast_index).ytd_burdened_cost) / l_factor_by;

        l_itd_value(i):= (l_overview_type(l_rev_forecast_index).itd_revenue +
                         l_overview_type(l_prior_cost_forecast_index).itd_burdened_cost -
                         l_overview_type(l_prior_rev_forecast_index).itd_revenue -
                         l_overview_type(l_cost_forecast_index).itd_burdened_cost) / l_factor_by;

        l_ac_value(i) := (l_overview_type(l_rev_forecast_index).ac_revenue +
                         l_overview_type(l_prior_cost_forecast_index).ac_burdened_cost -
                         l_overview_type(l_prior_rev_forecast_index).ac_revenue -
                         l_overview_type(l_cost_forecast_index).ac_burdened_cost) / l_factor_by;

        l_prp_value(i):= (l_overview_type(l_rev_forecast_index).prp_revenue +
                         l_overview_type(l_prior_cost_forecast_index).prp_burdened_cost -
                         l_overview_type(l_prior_rev_forecast_index).prp_revenue -
                         l_overview_type(l_cost_forecast_index).prp_burdened_cost) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FR' AND bitand(l_check_plan_versions, g_RevFcst_is_present) = g_RevFcst_is_present  THEN
        --forecast revenue
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_rev_forecast_index).ptd_revenue / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_rev_forecast_index).qtd_revenue / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_rev_forecast_index).ytd_revenue / l_factor_by;

        l_itd_value(i):=l_overview_type(l_rev_forecast_index).itd_revenue / l_factor_by;

        l_ac_value(i):=l_overview_type(l_rev_forecast_index).ac_revenue / l_factor_by;

        l_prp_value(i):=l_overview_type(l_rev_forecast_index).prp_revenue / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FRAR' AND bitand(l_check_plan_versions, g_RevFcst_is_present) = g_RevFcst_is_present  THEN
        --
        --forecast revenue at risk =
        --  forecast revenue - (initial_funding_amount + additional_funding_amount +
        --  funding_adjustment_amount + cancelled_funding_amount)
        --
        x_measure_type(i) := g_CurrencyType;

/*        l_ptd_value(i):= (l_overview_type(l_rev_forecast_index).ptd_revenue -
                                  (l_pji_facts.ptd_initial_funding_amount +
                                   l_pji_facts.ptd_additional_funding_amount +
                                   l_pji_facts.ptd_funding_adjustment_amount +
                                   l_pji_facts.ptd_cancelled_funding_amount)) / l_factor_by;

        l_qtd_value(i):= (l_overview_type(l_rev_forecast_index).qtd_revenue -
                                  (l_pji_facts.qtd_initial_funding_amount +
                                   l_pji_facts.qtd_additional_funding_amount +
                                   l_pji_facts.qtd_funding_adjustment_amount +
                                   l_pji_facts.qtd_cancelled_funding_amount)) / l_factor_by;

        l_ytd_value(i):= (l_overview_type(l_rev_forecast_index).ytd_revenue -
                                  (l_pji_facts.ytd_initial_funding_amount +
                                   l_pji_facts.ytd_additional_funding_amount +
                                   l_pji_facts.ytd_funding_adjustment_amount +
                                   l_pji_facts.ytd_cancelled_funding_amount)) / l_factor_by;
*/

/*  commented out for bug 4194804
        l_itd_value(i):= (l_overview_type(l_rev_forecast_index).itd_revenue -
                                  (l_pji_facts.itd_initial_funding_amount +
                                   l_pji_facts.itd_additional_funding_amount +
                                   l_pji_facts.itd_funding_adjustment_amount +
                                   l_pji_facts.itd_cancelled_funding_amount)) / l_factor_by;
*/

        -- Added for bug 4194804
        l_measure1       := l_pji_facts.itd_initial_funding_amount;
        l_measure2       := l_pji_facts.itd_additional_funding_amount;
        l_measure3       := l_pji_facts.itd_funding_adjustment_amount;
        l_measure4       := l_pji_facts.itd_cancelled_funding_amount;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_itd_value(i):= (l_overview_type(l_rev_forecast_index).itd_revenue - NVL(l_measures_total,0) )/l_factor_by;

		IF l_itd_value(i) < 0  THEN
		   l_itd_value(i) := 0;
		END IF;

		--bug 7150594 l_ac_value(i) := l_itd_value(i);

	   l_measure1       := l_pji_facts.ac_additional_funding_amount;
       l_measure2       := l_pji_facts.ac_cancelled_funding_amount;
       l_measure3       := l_pji_facts.ac_funding_adjustment_amount;
       l_measure4       := l_pji_facts.ac_initial_funding_amount;

       l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                          ,p_measure2 => l_measure2
                                                          ,p_measure3 => l_measure3
                                                          ,p_measure4 => l_measure4
                                                        );


       l_num  := l_overview_type(l_rev_forecast_index).ac_revenue - NVL(l_measures_total,0);


		IF l_num < 0 THEN
		   l_num := 0;
		END IF;

        l_ac_value(i):=l_num / l_factor_by;

-- bug 7150594 changes end


/*
        l_ac_value(i) := (l_overview_type(l_rev_forecast_index).ac_revenue  -
                                  (l_pji_facts.ac_initial_funding_amount +
                                   l_pji_facts.ac_additional_funding_amount +
                                   l_pji_facts.ac_funding_adjustment_amount +
                                   l_pji_facts.ac_cancelled_funding_amount)) / l_factor_by;

        l_prp_value(i):= (l_overview_type(l_rev_forecast_index).prp_revenue -
                                  (l_pji_facts.prp_initial_funding_amount +
                                   l_pji_facts.prp_additional_funding_amount +
                                   l_pji_facts.prp_funding_adjustment_amount +
                                   l_pji_facts.prp_cancelled_funding_amount)) / l_factor_by;
*/

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FRV' AND bitand(l_check_plan_versions, g_RevBudgetFcst) = g_RevBudgetFcst THEN
        --
        -- forecast revenue variance =
        -- (Forecast Revenue - Current Budget Revenue)
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):= (l_overview_type(l_rev_forecast_index).ptd_revenue -
                         l_overview_type(l_rev_budget_index).ptd_revenue) / l_factor_by;

        l_qtd_value(i):= (l_overview_type(l_rev_forecast_index).qtd_revenue -
                         l_overview_type(l_rev_budget_index).qtd_revenue) / l_factor_by;

        l_ytd_value(i):= (l_overview_type(l_rev_forecast_index).ytd_revenue -
                         l_overview_type(l_rev_budget_index).ytd_revenue) / l_factor_by;

        l_itd_value(i):= (l_overview_type(l_rev_forecast_index).itd_revenue -
                         l_overview_type(l_rev_budget_index).itd_revenue) / l_factor_by;

        l_ac_value(i) := (l_overview_type(l_rev_forecast_index).ac_revenue -
                         l_overview_type(l_rev_budget_index).ac_revenue) / l_factor_by;

        l_prp_value(i):= (l_overview_type(l_rev_forecast_index).prp_revenue -
                         l_overview_type(l_rev_budget_index).prp_revenue) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FRVOB' AND bitand(l_check_plan_versions, g_RevOrigbudgetFcst) = g_RevOrigbudgetFcst THEN
        --
        -- forecast revenue variance from orig budget =
        --      (Forecast Revenue - Orig Budget Revenue)
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):= (l_overview_type(l_rev_forecast_index).ptd_revenue -
                         l_overview_type(l_orig_rev_budget_index).ptd_revenue) / l_factor_by;

        l_qtd_value(i):= (l_overview_type(l_rev_forecast_index).qtd_revenue -
                         l_overview_type(l_orig_rev_budget_index).qtd_revenue) / l_factor_by;

        l_ytd_value(i):= (l_overview_type(l_rev_forecast_index).ytd_revenue -
                         l_overview_type(l_orig_rev_budget_index).ytd_revenue) / l_factor_by;

        l_itd_value(i):= (l_overview_type(l_rev_forecast_index).itd_revenue -
                         l_overview_type(l_orig_rev_budget_index).itd_revenue) / l_factor_by;

        l_ac_value(i) := (l_overview_type(l_rev_forecast_index).ac_revenue -
                         l_overview_type(l_orig_rev_budget_index).ac_revenue)  / l_factor_by;

        l_prp_value(i):= (l_overview_type(l_rev_forecast_index).prp_revenue -
                         l_overview_type(l_orig_rev_budget_index).prp_revenue) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FUC' THEN
        -- funding cancellations (from PJI_AC_PROJ_F)
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_pji_facts.ptd_cancelled_funding_amount / l_factor_by;

        l_qtd_value(i):=l_pji_facts.qtd_cancelled_funding_amount / l_factor_by;

        l_ytd_value(i):=l_pji_facts.ytd_cancelled_funding_amount / l_factor_by;

        l_itd_value(i):=l_pji_facts.itd_cancelled_funding_amount / l_factor_by;

        l_ac_value(i):=l_pji_facts.ac_cancelled_funding_amount / l_factor_by;

        l_prp_value(i):=l_pji_facts.prp_cancelled_funding_amount / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_IW' THEN
        -- invoice writeoffs (from PJI_AC_PROJ_F)
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_pji_facts.ptd_ar_invoice_writeoff_amount / l_factor_by;

        l_qtd_value(i):=l_pji_facts.qtd_ar_invoice_writeoff_amount / l_factor_by;

        l_ytd_value(i):=l_pji_facts.ytd_ar_invoice_writeoff_amount / l_factor_by;

        l_itd_value(i):=l_pji_facts.itd_ar_invoice_writeoff_amount / l_factor_by;

        l_ac_value(i):=l_pji_facts.ac_ar_invoice_writeoff_amount / l_factor_by;

        l_prp_value(i):=l_pji_facts.prp_ar_invoice_writeoff_amount / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_LBC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present  THEN
        -- labor burdened cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=(l_overview_type(l_actual_index).ptd_labor_burdened_cost - l_overview_type(l_actual_index).ptd_labor_raw_cost) / l_factor_by;

        l_qtd_value(i):=(l_overview_type(l_actual_index).qtd_labor_burdened_cost - l_overview_type(l_actual_index).qtd_labor_raw_cost) / l_factor_by;

        l_ytd_value(i):=(l_overview_type(l_actual_index).ytd_labor_burdened_cost - l_overview_type(l_actual_index).ytd_labor_raw_cost) / l_factor_by;

        l_itd_value(i):=(l_overview_type(l_actual_index).itd_labor_burdened_cost - l_overview_type(l_actual_index).itd_labor_raw_cost) / l_factor_by;

        l_ac_value(i):=(l_overview_type(l_actual_index).ac_labor_burdened_cost - l_overview_type(l_actual_index).ac_labor_raw_cost) / l_factor_by;

        l_prp_value(i):=(l_overview_type(l_actual_index).prp_labor_burdened_cost - l_overview_type(l_actual_index).prp_labor_raw_cost) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_LRC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present  THEN
        -- labor raw cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_labor_raw_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_labor_raw_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_actual_index).ytd_labor_raw_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_actual_index).itd_labor_raw_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_labor_raw_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_actual_index).prp_labor_raw_cost / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_M' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        --
        -- Margin =
        --      Revenue - Burdened Cost
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=(nvl(l_overview_type(l_actual_index).ptd_revenue,0) -
                                nvl(l_overview_type(l_actual_index).ptd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_qtd_value(i):=(nvl(l_overview_type(l_actual_index).qtd_revenue,0) -
                                nvl(l_overview_type(l_actual_index).qtd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_ytd_value(i):=(nvl(l_overview_type(l_actual_index).ytd_revenue,0) -
                                nvl(l_overview_type(l_actual_index).ytd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_itd_value(i):=(nvl(l_overview_type(l_actual_index).itd_revenue,0) -
                                nvl(l_overview_type(l_actual_index).itd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_ac_value(i) :=(nvl(l_overview_type(l_actual_index).ac_revenue,0) -
                                nvl(l_overview_type(l_actual_index).ac_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_prp_value(i):=(nvl(l_overview_type(l_actual_index).prp_revenue,0) -
                                nvl(l_overview_type(l_actual_index).prp_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

      ELSIF p_measure_set_code(i) = 'PPF_MSR_MP' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        --
        -- Margin Percent =
        --      Margin / Revenue = (Revenue - Burdened Cost) / Revenue * 100
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_actual_index).ptd_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_actual_index).ptd_revenue,0) - nvl(l_overview_type(l_actual_index).ptd_burdened_cost,0); -- NVL for Bug#6844202
            IF l_num IS NOT NULL THEN
              l_ptd_value(i):=(l_num / l_overview_type(l_actual_index).ptd_revenue) * 100;
            ELSE
              l_ptd_value(i):= NULL;
            END IF;
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_actual_index).qtd_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_actual_index).qtd_revenue,0) - nvl(l_overview_type(l_actual_index).qtd_burdened_cost,0); -- NVL for Bug#6844202
            IF l_num IS NOT NULL THEN
              l_qtd_value(i):=(l_num / l_overview_type(l_actual_index).qtd_revenue) * 100;
            ELSE
              l_qtd_value(i):= NULL;
            END IF;
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_actual_index).ytd_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_actual_index).ytd_revenue,0) - nvl(l_overview_type(l_actual_index).ytd_burdened_cost,0); -- NVL for Bug#6844202
            IF l_num IS NOT NULL THEN
              l_ytd_value(i):=(l_num / l_overview_type(l_actual_index).ytd_revenue) *100;
            ELSE
              l_ytd_value(i):= NULL;
            END IF;
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_actual_index).itd_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_actual_index).itd_revenue,0) - nvl(l_overview_type(l_actual_index).itd_burdened_cost,0); -- NVL for Bug#6844202
            IF l_num IS NOT NULL THEN
              l_itd_value(i):=(l_num / l_overview_type(l_actual_index).itd_revenue) *100;
            ELSE
              l_itd_value(i):= NULL;
            END IF;
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_actual_index).ac_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_actual_index).ac_revenue,0) - nvl(l_overview_type(l_actual_index).ac_burdened_cost,0); -- NVL for Bug#6844202
            IF l_num IS NOT NULL THEN
              l_ac_value(i):=(l_num / l_overview_type(l_actual_index).ac_revenue) *100;
            ELSE
              l_ac_value(i):= NULL;
            END IF;
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_actual_index).prp_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_actual_index).prp_revenue,0) - nvl(l_overview_type(l_actual_index).prp_burdened_cost,0); -- NVL for Bug#6844202
            IF l_num IS NOT NULL THEN
              l_prp_value(i):=(l_num / l_overview_type(l_actual_index).prp_revenue) *100;
            ELSE
              l_prp_value(i):= NULL;
            END IF;
        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_MPV' AND bitand(l_check_plan_versions, g_Actual_CstRevBudget) = g_Actual_CstRevBudget THEN
        --
        -- margin percent variance =
        --      ((actual rev * budget burden bost) - (rev budget * actual burden cost)) / (actual rev * rev budget)
        --
        x_measure_type(i) := g_IndexType;

        l_num := l_overview_type(l_actual_index).ptd_revenue * l_overview_type(l_rev_budget_index).ptd_revenue;
        IF l_num <> 0 THEN
            l_ptd_value(i):= 100*(l_overview_type(l_actual_index).ptd_revenue * l_overview_type(l_cost_budget_index).ptd_burdened_cost -
                             l_overview_type(l_rev_budget_index).ptd_revenue * l_overview_type(l_actual_index).ptd_burdened_cost)/l_num;
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_actual_index).qtd_revenue * l_overview_type(l_rev_budget_index).qtd_revenue;
        IF l_num <> 0 THEN
            l_qtd_value(i):= 100*(l_overview_type(l_actual_index).qtd_revenue * l_overview_type(l_cost_budget_index).qtd_burdened_cost -
                             l_overview_type(l_rev_budget_index).qtd_revenue * l_overview_type(l_actual_index).qtd_burdened_cost)/l_num;
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_actual_index).ytd_revenue * l_overview_type(l_rev_budget_index).ytd_revenue;
        IF l_num <> 0 THEN
            l_ytd_value(i):= 100*(l_overview_type(l_actual_index).ytd_revenue * l_overview_type(l_cost_budget_index).ytd_burdened_cost -
                             l_overview_type(l_rev_budget_index).ytd_revenue * l_overview_type(l_actual_index).ytd_burdened_cost)/l_num;
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_actual_index).itd_revenue * l_overview_type(l_rev_budget_index).itd_revenue;
        IF l_num <> 0 THEN
            l_itd_value(i):= 100*(l_overview_type(l_actual_index).itd_revenue * l_overview_type(l_cost_budget_index).itd_burdened_cost -
                             l_overview_type(l_rev_budget_index).itd_revenue * l_overview_type(l_actual_index).itd_burdened_cost)/l_num;
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_actual_index).ac_revenue * l_overview_type(l_rev_budget_index).ac_revenue;
        IF l_num <> 0 THEN
            l_ac_value(i):= 100*(l_overview_type(l_actual_index).ac_revenue * l_overview_type(l_cost_budget_index).ac_burdened_cost -
                             l_overview_type(l_rev_budget_index).ac_revenue * l_overview_type(l_actual_index).ac_burdened_cost)/l_num;
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_actual_index).prp_revenue * l_overview_type(l_rev_budget_index).prp_revenue;
        IF l_num <> 0 THEN
            l_prp_value(i):= 100*(l_overview_type(l_actual_index).prp_revenue * l_overview_type(l_cost_budget_index).prp_burdened_cost -
                             l_overview_type(l_rev_budget_index).prp_revenue * l_overview_type(l_actual_index).prp_burdened_cost)/l_num;
        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_MV' AND bitand(l_check_plan_versions, g_Actual_CstRevBudget) = g_Actual_CstRevBudget THEN
        --
        -- margin variance =
        --      (actual rev + budget burden cost - rev budget - actual burden cost) / (rev budget - budget burden cost)
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):= (l_overview_type(l_actual_index).ptd_revenue + l_overview_type(l_cost_budget_index).ptd_burdened_cost -
                         l_overview_type(l_rev_budget_index).ptd_revenue - l_overview_type(l_actual_index).ptd_burdened_cost) / l_factor_by;

        l_qtd_value(i):= (l_overview_type(l_actual_index).qtd_revenue + l_overview_type(l_cost_budget_index).qtd_burdened_cost -
                         l_overview_type(l_rev_budget_index).qtd_revenue - l_overview_type(l_actual_index).qtd_burdened_cost) / l_factor_by;

        l_ytd_value(i):= (l_overview_type(l_actual_index).ytd_revenue + l_overview_type(l_cost_budget_index).ytd_burdened_cost -
                         l_overview_type(l_rev_budget_index).ytd_revenue - l_overview_type(l_actual_index).ytd_burdened_cost) / l_factor_by;

        l_itd_value(i):= (l_overview_type(l_actual_index).itd_revenue + l_overview_type(l_cost_budget_index).itd_burdened_cost -
                         l_overview_type(l_rev_budget_index).itd_revenue - l_overview_type(l_actual_index).itd_burdened_cost) / l_factor_by;

        l_ac_value(i) := (l_overview_type(l_actual_index).ac_revenue + l_overview_type(l_cost_budget_index).ac_burdened_cost -
                         l_overview_type(l_rev_budget_index).ac_revenue - l_overview_type(l_actual_index).ac_burdened_cost) / l_factor_by;

        l_prp_value(i):= (l_overview_type(l_actual_index).prp_revenue + l_overview_type(l_cost_budget_index).prp_burdened_cost -
                         l_overview_type(l_rev_budget_index).prp_revenue - l_overview_type(l_actual_index).prp_burdened_cost) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_NBC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present  THEN
        --
        -- non billable cost =
        --      actual burd cost - actual billable burd cost - actual capitalizable burd cost
        --
        x_measure_type(i) := g_CurrencyType;

        -- Added Factor by for bug 4251793
        -- Added for bug  4194804

	  	IF l_contract_proj_mask = 1 THEN
	       l_measure1       := l_overview_type(l_actual_index).ptd_bill_burdened_cost;
	       l_measure2       := NULL; --l_overview_type(l_actual_index).ptd_capitalizable_brdn_cost;
	       l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
	                                                          ,p_measure2 => l_measure2
	                                                        );

	        l_ptd_value(i):= (l_overview_type(l_actual_index).ptd_burdened_cost - NVL(l_measures_total,0)) / l_factor_by;

	        -- Added for bug  4194804
	       l_measure1       := l_overview_type(l_actual_index).qtd_bill_burdened_cost;
	       l_measure2       := NULL; --l_overview_type(l_actual_index).qtd_capitalizable_brdn_cost;
	       l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
	                                                          ,p_measure2 => l_measure2
	                                                        );

	        l_qtd_value(i):= (l_overview_type(l_actual_index).qtd_burdened_cost - NVL(l_measures_total,0))/ l_factor_by;

	        -- Added for bug  4194804
	       l_measure1       := l_overview_type(l_actual_index).ytd_bill_burdened_cost;
	       l_measure2       := NULL; --l_overview_type(l_actual_index).ytd_capitalizable_brdn_cost;
	       l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
	                                                          ,p_measure2 => l_measure2
	                                                        );

	        l_ytd_value(i):= (l_overview_type(l_actual_index).ytd_burdened_cost - NVL(l_measures_total,0)) / l_factor_by;

	        -- Added for bug  4194804
	       l_measure1       := l_overview_type(l_actual_index).itd_bill_burdened_cost;
	       l_measure2       := NULL; --l_overview_type(l_actual_index).itd_capitalizable_brdn_cost;
	       l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
	                                                          ,p_measure2 => l_measure2
	                                                        );

	        l_itd_value(i):= (l_overview_type(l_actual_index).itd_burdened_cost - NVL(l_measures_total,0)) / l_factor_by;

	        -- Added for bug  4194804
	       l_measure1       := l_overview_type(l_actual_index).ac_bill_burdened_cost;
	       l_measure2       := NULL; --l_overview_type(l_actual_index).ac_capitalizable_brdn_cost;
	       l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
	                                                          ,p_measure2 => l_measure2
	                                                        );

	        l_ac_value(i):= (l_overview_type(l_actual_index).ac_burdened_cost - NVL(l_measures_total,0)) / l_factor_by;

	        -- Added for bug  4194804
	       l_measure1       := l_overview_type(l_actual_index).prp_bill_burdened_cost;
	       l_measure2       := NULL; --l_overview_type(l_actual_index).prp_capitalizable_brdn_cost;
	       l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
	                                                          ,p_measure2 => l_measure2
	                                                        );

	        l_prp_value(i):= (l_overview_type(l_actual_index).prp_burdened_cost - NVL(l_measures_total,0)) / l_factor_by;
		END IF;


      ELSIF p_measure_set_code(i) = 'PPF_MSR_NBEH' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present  THEN
        --
        --  non billable equipment hours =
        --      equipment hrs - billable equipment hrs
        --
        x_measure_type(i) := g_HoursType;

		IF l_contract_proj_mask=1 THEN

	        l_ptd_value(i):=(l_overview_type(l_actual_index).ptd_equipment_hrs - NVL(l_overview_type(l_actual_index).ptd_bill_equipment_hrs,0)) / l_effort_UOM;

	        l_qtd_value(i):=(l_overview_type(l_actual_index).qtd_equipment_hrs - NVL(l_overview_type(l_actual_index).qtd_bill_equipment_hrs,0)) / l_effort_UOM;

	        l_ytd_value(i):=(l_overview_type(l_actual_index).ytd_equipment_hrs - NVL(l_overview_type(l_actual_index).ytd_bill_equipment_hrs,0)) / l_effort_UOM;

	        l_itd_value(i):=(l_overview_type(l_actual_index).itd_equipment_hrs - NVL(l_overview_type(l_actual_index).itd_bill_equipment_hrs,0)) / l_effort_UOM;

	        l_ac_value(i):=(l_overview_type(l_actual_index).ac_equipment_hrs - NVL(l_overview_type(l_actual_index).ac_bill_equipment_hrs,0)) / l_effort_UOM;

	        l_prp_value(i):=(l_overview_type(l_actual_index).prp_equipment_hrs - NVL(l_overview_type(l_actual_index).prp_bill_equipment_hrs,0)) / l_effort_UOM;
		END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_NBLH' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present  THEN
        --
        -- non billable labor hours =
        --      labor hrs - billable labor hrs
        --
        x_measure_type(i) := g_HoursType;

	  	IF l_contract_proj_mask = 1 THEN
	        l_ptd_value(i):=(l_overview_type(l_actual_index).ptd_labor_hrs - NVL(l_overview_type(l_actual_index).ptd_bill_labor_hrs,0)) / l_effort_UOM;

	        l_qtd_value(i):=(l_overview_type(l_actual_index).qtd_labor_hrs - NVL(l_overview_type(l_actual_index).qtd_bill_labor_hrs,0)) / l_effort_UOM;

		    l_ytd_value(i):=(l_overview_type(l_actual_index).ytd_labor_hrs - NVL(l_overview_type(l_actual_index).ytd_bill_labor_hrs,0)) / l_effort_UOM;

	        l_itd_value(i):=(l_overview_type(l_actual_index).itd_labor_hrs - NVL(l_overview_type(l_actual_index).itd_bill_labor_hrs,0)) / l_effort_UOM;

	        l_ac_value(i):=(l_overview_type(l_actual_index).ac_labor_hrs - NVL(l_overview_type(l_actual_index).ac_bill_labor_hrs,0)) / l_effort_UOM;

	        l_prp_value(i):=(l_overview_type(l_actual_index).prp_labor_hrs - NVL(l_overview_type(l_actual_index).prp_bill_labor_hrs,0)) / l_effort_UOM;
		END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_NCA' THEN
        -- number of cash applications (from PJI_AC_PROJ_F)  #### TO BE DONE ####
        x_measure_type(i) := g_OtherType;

        l_ptd_value(i):=NULL /*l_pji_facts.ptd_)*/;

        l_qtd_value(i):=NULL /*l_pji_facts.qtd_)*/;

        l_ytd_value(i):=NULL /*l_pji_facts.ytd_)*/;

        l_itd_value(i):=NULL /*l_pji_facts.itd_)*/;

        l_ac_value(i):=NULL /*l_pji_facts.ac_)*/;

        l_prp_value(i):=NULL /*l_pji_facts.prp_)*/;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_NCO' THEN
        -- number of change orders (from PJI_AC_PROJ_F)  #### TO BE DONE ####
        x_measure_type(i) := g_OtherType;

        l_ptd_value(i):=NULL /*l_pji_facts.ptd_)*/;

        l_qtd_value(i):=NULL /*l_pji_facts.qtd_)*/;

        l_ytd_value(i):=NULL /*l_pji_facts.ytd_)*/;

        l_itd_value(i):=NULL /*l_pji_facts.itd_)*/;

        l_ac_value(i):=NULL /*l_pji_facts.ac_)*/;

        l_prp_value(i):=NULL /*l_pji_facts.prp_)*/;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_NCZC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present  THEN
        --
        -- non capitalizable cost =
        --      actual burd cost - actual billable burd cost - actual capitalizable burd cost
        --
        x_measure_type(i) := g_CurrencyType;

        IF l_capital_proj_mask = 1 THEN

/* Commented out for bug  4194804
          l_ptd_value(i):= (l_overview_type(l_actual_index).ptd_burdened_cost - NVL(l_overview_type(l_actual_index).ptd_bill_burdened_cost,0) -
                             l_overview_type(l_actual_index).ptd_capitalizable_brdn_cost) / l_factor_by;

          l_qtd_value(i):= (l_overview_type(l_actual_index).qtd_burdened_cost - NVL(l_overview_type(l_actual_index).qtd_bill_burdened_cost,0) -
                             l_overview_type(l_actual_index).qtd_capitalizable_brdn_cost) / l_factor_by;

          l_ytd_value(i):= (l_overview_type(l_actual_index).ytd_burdened_cost - NVL(l_overview_type(l_actual_index).ytd_bill_burdened_cost,0) -
                             l_overview_type(l_actual_index).ytd_capitalizable_brdn_cost) / l_factor_by;

          l_itd_value(i):= (l_overview_type(l_actual_index).itd_burdened_cost - NVL(l_overview_type(l_actual_index).itd_bill_burdened_cost,0) -
                             l_overview_type(l_actual_index).itd_capitalizable_brdn_cost) / l_factor_by;

          l_ac_value(i):= (l_overview_type(l_actual_index).ac_burdened_cost - NVL(l_overview_type(l_actual_index).ac_bill_burdened_cost,0) -
                             l_overview_type(l_actual_index).ac_capitalizable_brdn_cost) / l_factor_by;

          l_prp_value(i):= (l_overview_type(l_actual_index).prp_burdened_cost - NVL(l_overview_type(l_actual_index).prp_bill_burdened_cost,0) -
                             l_overview_type(l_actual_index).prp_capitalizable_brdn_cost) / l_factor_by;

*/

        -- Added for bug  4194804
       l_measure1       := NULL; --l_overview_type(l_actual_index).ptd_bill_burdened_cost;
       l_measure2       := l_overview_type(l_actual_index).ptd_capitalizable_brdn_cost;
       l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                          ,p_measure2 => l_measure2
                                                        );

       l_ptd_value(i):= (l_overview_type(l_actual_index).ptd_burdened_cost - NVL(l_measures_total,0)) / l_factor_by;

        -- Added for bug  4194804
       l_measure1       := NULL; --l_overview_type(l_actual_index).qtd_bill_burdened_cost;
       l_measure2       := l_overview_type(l_actual_index).qtd_capitalizable_brdn_cost;
       l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                          ,p_measure2 => l_measure2
                                                        );

       l_qtd_value(i):= (l_overview_type(l_actual_index).qtd_burdened_cost - NVL(l_measures_total,0)) / l_factor_by;

        -- Added for bug  4194804
       l_measure1       := NULL; --l_overview_type(l_actual_index).ytd_bill_burdened_cost;
       l_measure2       := l_overview_type(l_actual_index).ytd_capitalizable_brdn_cost;
       l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                          ,p_measure2 => l_measure2
                                                        );

       l_ytd_value(i):= (l_overview_type(l_actual_index).ytd_burdened_cost - NVL(l_measures_total,0)) / l_factor_by;

        -- Added for bug  4194804
       l_measure1       := NULL; --l_overview_type(l_actual_index).itd_bill_burdened_cost;
       l_measure2       := l_overview_type(l_actual_index).itd_capitalizable_brdn_cost;
       l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                          ,p_measure2 => l_measure2
                                                        );

       l_itd_value(i):= (l_overview_type(l_actual_index).itd_burdened_cost - NVL(l_measures_total,0)) / l_factor_by;

        -- Added for bug  4194804
       l_measure1       := NULL; --l_overview_type(l_actual_index).ac_bill_burdened_cost;
       l_measure2       := l_overview_type(l_actual_index).ac_capitalizable_brdn_cost;
       l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                          ,p_measure2 => l_measure2
                                                        );

       l_ac_value(i):= (l_overview_type(l_actual_index).ac_burdened_cost - NVL(l_measures_total,0)) / l_factor_by;

        -- Added for bug  4194804
       l_measure1       := NULL; --l_overview_type(l_actual_index).prp_bill_burdened_cost;
       l_measure2       := l_overview_type(l_actual_index).prp_capitalizable_brdn_cost;
       l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                          ,p_measure2 => l_measure2
                                                        );

       l_prp_value(i):= (l_overview_type(l_actual_index).prp_burdened_cost - NVL(l_measures_total,0)) / l_factor_by;



       END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_NII' THEN
        -- number of invoice issued (from PJI_AC_PROJ_F)
        x_measure_type(i) := g_OtherType;

        l_ptd_value(i):=l_pji_facts.ptd_ar_invoice_count;

        l_qtd_value(i):=l_pji_facts.qtd_ar_invoice_count;

        l_ytd_value(i):=l_pji_facts.ytd_ar_invoice_count;

        l_itd_value(i):=l_pji_facts.itd_ar_invoice_count;

        l_ac_value(i):=l_pji_facts.ac_ar_invoice_count;

        l_prp_value(i):=l_pji_facts.prp_ar_invoice_count;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OB2C' AND bitand(l_check_plan_versions, g_OrigCstBudget2_is_present) = g_OrigCstBudget2_is_present  THEN
        -- Original Budget 2 Cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_orig_cost_budget2_index).ptd_burdened_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_orig_cost_budget2_index).qtd_burdened_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_orig_cost_budget2_index).ytd_burdened_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_orig_cost_budget2_index).itd_burdened_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_orig_cost_budget2_index).ac_burdened_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_orig_cost_budget2_index).prp_burdened_cost / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OB2EH' AND bitand(l_check_plan_versions, g_OrigCstBudget2_is_present) = g_OrigCstBudget2_is_present  THEN
        -- Original Budget 2 equipment Hours
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=l_overview_type(l_orig_cost_budget2_index).ptd_equipment_hrs / l_effort_UOM;

        l_qtd_value(i):=l_overview_type(l_orig_cost_budget2_index).qtd_equipment_hrs / l_effort_UOM;

        l_ytd_value(i):=l_overview_type(l_orig_cost_budget2_index).ytd_equipment_hrs / l_effort_UOM;

        l_itd_value(i):=l_overview_type(l_orig_cost_budget2_index).itd_equipment_hrs / l_effort_UOM;

        l_ac_value(i):=l_overview_type(l_orig_cost_budget2_index).ac_equipment_hrs / l_effort_UOM;

        l_prp_value(i):=l_overview_type(l_orig_cost_budget2_index).prp_equipment_hrs / l_effort_UOM;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OB2LH' AND bitand(l_check_plan_versions, g_OrigCstBudget2_is_present) = g_OrigCstBudget2_is_present  THEN
        -- Original Budget People Hours
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=l_overview_type(l_orig_cost_budget2_index).ptd_labor_hrs / l_effort_UOM;

        l_qtd_value(i):=l_overview_type(l_orig_cost_budget2_index).qtd_labor_hrs / l_effort_UOM;

        l_ytd_value(i):=l_overview_type(l_orig_cost_budget2_index).ytd_labor_hrs / l_effort_UOM;

        l_itd_value(i):=l_overview_type(l_orig_cost_budget2_index).itd_labor_hrs / l_effort_UOM;

        l_ac_value(i):=l_overview_type(l_orig_cost_budget2_index).ac_labor_hrs / l_effort_UOM;

        l_prp_value(i):=l_overview_type(l_orig_cost_budget2_index).prp_labor_hrs / l_effort_UOM;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OB2M' AND bitand(l_check_plan_versions, g_OrigCstBudget2_is_present) = g_OrigCstBudget2_is_present THEN
        --
        -- Original Budget 2 Margin =
        --      o.b.2 Revenue - o.b.2 Burdened Cost
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=(nvl(l_overview_type(l_orig_rev_budget2_index).ptd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget2_index).ptd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_qtd_value(i):=(nvl(l_overview_type(l_orig_rev_budget2_index).qtd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget2_index).qtd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_ytd_value(i):=(nvl(l_overview_type(l_orig_rev_budget2_index).ytd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget2_index).ytd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_itd_value(i):=(nvl(l_overview_type(l_orig_rev_budget2_index).itd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget2_index).itd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_ac_value(i):=(nvl(l_overview_type(l_orig_rev_budget2_index).ac_revenue,0) - nvl(l_overview_type(l_orig_cost_budget2_index).ac_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_prp_value(i):=(nvl(l_overview_type(l_orig_cost_budget2_index).prp_revenue,0) - nvl(l_overview_type(l_orig_cost_budget2_index).prp_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OB2MP' AND bitand(l_check_plan_versions, g_OrigCstBudget2_is_present) = g_OrigCstBudget2_is_present THEN
        --
        -- OB2 Margin Percent =
        --      OB2 Margin / OB2 Revenue = (OB2 Revenue - OB2 Burdened Cost) / OB2 Revenue * 100
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_orig_rev_budget2_index).ptd_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_orig_rev_budget2_index).ptd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget2_index).ptd_burdened_cost,0); -- NVL for Bug#6844202
            l_ptd_value(i):=(l_num / l_overview_type(l_orig_rev_budget2_index).ptd_revenue) * 100;
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_rev_budget2_index).qtd_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_orig_rev_budget2_index).qtd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget2_index).qtd_burdened_cost,0); -- NVL for Bug#6844202
            l_qtd_value(i):=(l_num / l_overview_type(l_orig_rev_budget2_index).qtd_revenue) * 100;
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_rev_budget2_index).ytd_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_orig_rev_budget2_index).ytd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget2_index).ytd_burdened_cost,0); -- NVL for Bug#6844202
            l_ytd_value(i):=(l_num / l_overview_type(l_orig_rev_budget2_index).ytd_revenue) *100;
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_rev_budget2_index).itd_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_orig_rev_budget2_index).itd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget2_index).itd_burdened_cost,0); -- NVL for Bug#6844202
            l_itd_value(i):=(l_num / l_overview_type(l_orig_rev_budget2_index).itd_revenue) *100;
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_rev_budget2_index).ac_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_orig_rev_budget2_index).ac_revenue,0) - nvl(l_overview_type(l_orig_cost_budget2_index).ac_burdened_cost,0); -- NVL for Bug#6844202
            l_ac_value(i):=(l_num / l_overview_type(l_orig_rev_budget2_index).ac_revenue) *100;
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_rev_budget2_index).prp_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_orig_rev_budget2_index).prp_revenue,0) - nvl(l_overview_type(l_orig_cost_budget2_index).prp_burdened_cost,0); -- NVL for Bug#6844202
            l_prp_value(i):=(l_num / l_overview_type(l_orig_rev_budget2_index).prp_revenue) *100;
        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OB2R' AND bitand(l_check_plan_versions, g_OrigCstBudget2_is_present) = g_OrigCstBudget2_is_present THEN
        -- Original Budget 2 Revenue
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_orig_rev_budget2_index).ptd_revenue / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_orig_rev_budget2_index).qtd_revenue / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_orig_rev_budget2_index).ytd_revenue / l_factor_by;

        l_itd_value(i):=l_overview_type(l_orig_rev_budget2_index).itd_revenue / l_factor_by;

        l_ac_value(i):=l_overview_type(l_orig_rev_budget2_index).ac_revenue / l_factor_by;

        l_prp_value(i):=l_overview_type(l_orig_rev_budget2_index).prp_revenue / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OB2RC' AND bitand(l_check_plan_versions, g_OrigCstBudget2_is_present) = g_OrigCstBudget2_is_present THEN
        -- Original Budget 2 raw cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_orig_cost_budget2_index).ptd_raw_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_orig_cost_budget2_index).qtd_raw_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_orig_cost_budget2_index).ytd_raw_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_orig_cost_budget2_index).itd_raw_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_orig_cost_budget2_index).ac_raw_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_orig_cost_budget2_index).prp_raw_cost / l_factor_by;

      ELSIF  p_measure_set_code(i) = 'PPF_MSR_OBBCV' AND bitand(l_check_plan_versions, g_OrigCstBudget_is_present) = g_OrigCstBudget_is_present AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        --
        -- Cost variance from Original budget:
        --      Actual Cost - Original budget Cost
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=(l_overview_type(l_actual_index).ptd_burdened_cost -
                        l_overview_type(l_orig_cost_budget_index).ptd_burdened_cost) / l_factor_by;

        l_qtd_value(i):=(l_overview_type(l_actual_index).qtd_burdened_cost -
                        l_overview_type(l_orig_cost_budget_index).qtd_burdened_cost) / l_factor_by;

        l_ytd_value(i):=(l_overview_type(l_actual_index).ytd_burdened_cost -
                        l_overview_type(l_orig_cost_budget_index).ytd_burdened_cost) / l_factor_by;

        l_itd_value(i):=(l_overview_type(l_actual_index).itd_burdened_cost -
                        l_overview_type(l_orig_cost_budget_index).itd_burdened_cost) / l_factor_by;

        l_ac_value(i):= (l_overview_type(l_actual_index).ac_burdened_cost -
                        l_overview_type(l_orig_cost_budget_index).ac_burdened_cost)  / l_factor_by;

        l_prp_value(i):=(l_overview_type(l_actual_index).prp_burdened_cost -
                        l_overview_type(l_orig_cost_budget_index).prp_burdened_cost) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OBC' AND bitand(l_check_plan_versions, g_OrigCstBudget_is_present) = g_OrigCstBudget_is_present  THEN
        -- Original Budget Cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_orig_cost_budget_index).ptd_burdened_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_orig_cost_budget_index).qtd_burdened_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_orig_cost_budget_index).ytd_burdened_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_orig_cost_budget_index).itd_burdened_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_orig_cost_budget_index).ac_burdened_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_orig_cost_budget_index).prp_burdened_cost / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OBEH' AND bitand(l_check_plan_versions, g_OrigCstBudget_is_present) = g_OrigCstBudget_is_present  THEN
        -- Original Budget equipment Hours
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=l_overview_type(l_orig_cost_budget_index).ptd_equipment_hrs / l_effort_UOM;

        l_qtd_value(i):=l_overview_type(l_orig_cost_budget_index).qtd_equipment_hrs / l_effort_UOM;

        l_ytd_value(i):=l_overview_type(l_orig_cost_budget_index).ytd_equipment_hrs / l_effort_UOM;

        l_itd_value(i):=l_overview_type(l_orig_cost_budget_index).itd_equipment_hrs / l_effort_UOM;

        l_ac_value(i):=l_overview_type(l_orig_cost_budget_index).ac_equipment_hrs / l_effort_UOM;

        l_prp_value(i):=l_overview_type(l_orig_cost_budget_index).prp_equipment_hrs / l_effort_UOM;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OBLH' AND bitand(l_check_plan_versions, g_OrigCstBudget_is_present) = g_OrigCstBudget_is_present  THEN
        -- Original Budget People Hours
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=l_overview_type(l_orig_cost_budget_index).ptd_labor_hrs / l_effort_UOM;

        l_qtd_value(i):=l_overview_type(l_orig_cost_budget_index).qtd_labor_hrs / l_effort_UOM;

        l_ytd_value(i):=l_overview_type(l_orig_cost_budget_index).ytd_labor_hrs / l_effort_UOM;

        l_itd_value(i):=l_overview_type(l_orig_cost_budget_index).itd_labor_hrs / l_effort_UOM;

        l_ac_value(i):=l_overview_type(l_orig_cost_budget_index).ac_labor_hrs / l_effort_UOM;

        l_prp_value(i):=l_overview_type(l_orig_cost_budget_index).prp_labor_hrs / l_effort_UOM;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OBM' AND bitand(l_check_plan_versions, g_OrigCstBudget_is_present) = g_OrigCstBudget_is_present THEN
        --
        -- Original Budget Margin =
        --      o.b. Revenue - o.b. Burdened Cost
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=(nvl(l_overview_type(l_orig_rev_budget_index).ptd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget_index).ptd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_qtd_value(i):=(nvl(l_overview_type(l_orig_rev_budget_index).qtd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget_index).qtd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_ytd_value(i):=(nvl(l_overview_type(l_orig_rev_budget_index).ytd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget_index).ytd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_itd_value(i):=(nvl(l_overview_type(l_orig_rev_budget_index).itd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget_index).itd_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_ac_value(i):=(nvl(l_overview_type(l_orig_rev_budget_index).ac_revenue,0) - nvl(l_overview_type(l_orig_cost_budget_index).ac_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

        l_prp_value(i):=(nvl(l_overview_type(l_orig_rev_budget_index).prp_revenue,0) - nvl(l_overview_type(l_orig_cost_budget_index).prp_burdened_cost,0)) / l_factor_by; -- NVL for Bug#6844202

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OBMP' AND bitand(l_check_plan_versions, g_OrigCstBudget_is_present) = g_OrigCstBudget_is_present THEN
        --
        -- OB Margin Percent =
        --      OB Margin / OB Revenue = (OB Revenue - OB Burdened Cost) / OB Revenue * 100
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_orig_rev_budget_index).ptd_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_orig_rev_budget_index).ptd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget_index).ptd_burdened_cost,0); -- NVL for Bug#6844202
            l_ptd_value(i):=(l_num / l_overview_type(l_orig_rev_budget_index).ptd_revenue) * 100;
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_rev_budget_index).qtd_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_orig_rev_budget_index).qtd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget_index).qtd_burdened_cost,0); -- NVL for Bug#6844202
            l_qtd_value(i):=(l_num / l_overview_type(l_orig_rev_budget_index).qtd_revenue) * 100;
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_rev_budget_index).ytd_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_orig_rev_budget_index).ytd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget_index).ytd_burdened_cost,0); -- NVL for Bug#6844202
            l_ytd_value(i):=(l_num / l_overview_type(l_orig_rev_budget_index).ytd_revenue) *100;
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_rev_budget_index).itd_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_orig_rev_budget_index).itd_revenue,0) - nvl(l_overview_type(l_orig_cost_budget_index).itd_burdened_cost,0); -- NVL for Bug#6844202
            l_itd_value(i):=(l_num / l_overview_type(l_orig_rev_budget_index).itd_revenue) *100;
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_rev_budget_index).ac_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_orig_rev_budget_index).ac_revenue,0) - nvl(l_overview_type(l_orig_cost_budget_index).ac_burdened_cost,0); -- NVL for Bug#6844202
            l_ac_value(i):=(l_num / l_overview_type(l_orig_rev_budget_index).ac_revenue) *100;
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_rev_budget_index).prp_revenue <> 0 THEN
            l_num := nvl(l_overview_type(l_orig_rev_budget_index).prp_revenue,0) - nvl(l_overview_type(l_orig_cost_budget_index).prp_burdened_cost,0); -- NVL for Bug#6844202
            l_prp_value(i):=(l_num / l_overview_type(l_orig_rev_budget_index).prp_revenue) *100;
        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OBR' AND bitand(l_check_plan_versions, g_OrigCstBudget_is_present) = g_OrigCstBudget_is_present THEN
        -- Original Budget Revenue
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_orig_rev_budget_index).ptd_revenue / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_orig_rev_budget_index).qtd_revenue / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_orig_rev_budget_index).ytd_revenue / l_factor_by;

        l_itd_value(i):=l_overview_type(l_orig_rev_budget_index).itd_revenue / l_factor_by;

        l_ac_value(i):=l_overview_type(l_orig_rev_budget_index).ac_revenue / l_factor_by;

        l_prp_value(i):=l_overview_type(l_orig_rev_budget_index).prp_revenue / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OCC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- Other Committed Cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_oth_committed_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_oth_committed_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_actual_index).ytd_oth_committed_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_actual_index).itd_oth_committed_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_oth_committed_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_actual_index).prp_oth_committed_cost / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OF' THEN
        -- original funding (from PJI_AC_PROJ_F)
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_pji_facts.ptd_initial_funding_amount / l_factor_by;

        l_qtd_value(i):=l_pji_facts.qtd_initial_funding_amount / l_factor_by;

        l_ytd_value(i):=l_pji_facts.ytd_initial_funding_amount / l_factor_by;

        l_itd_value(i):=l_pji_facts.itd_initial_funding_amount / l_factor_by;

        l_ac_value(i):=l_pji_facts.ac_initial_funding_amount / l_factor_by;

        l_prp_value(i):=l_pji_facts.prp_initial_funding_amount / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_OR' THEN
        -- outstanding receivables (from PJI_AC_PROJ_F)
        x_measure_type(i) := g_CurrencyType;
/* Starts added for bug 6961599 */
		l_measures_total := Pji_Rep_Util.Measures_Total(   p_measure1 => l_pji_facts.ptd_ar_amount_due
                                                                       ,p_measure2 => l_pji_facts.ptd_ar_amount_overdue
                                                                     );
        l_ptd_value(i):= l_measures_total/l_factor_by;

		l_measures_total := Pji_Rep_Util.Measures_Total(   p_measure1 => l_pji_facts.qtd_ar_amount_due
                                                                       ,p_measure2 => l_pji_facts.qtd_ar_amount_overdue
                                                                     );
        l_qtd_value(i):= l_measures_total/l_factor_by;

    	l_measures_total := Pji_Rep_Util.Measures_Total(   p_measure1 => l_pji_facts.ytd_ar_amount_due
                                                                       ,p_measure2 => l_pji_facts.ytd_ar_amount_overdue
                                                                     );
        l_ytd_value(i):= l_measures_total/l_factor_by;

/* Ends added for bug 6961599 */

/* Commented for bug 6961599
        l_ptd_value(i):=NULL;

        l_qtd_value(i):=NULL;

        l_ytd_value(i):=NULL;
*/
		l_measures_total := Pji_Rep_Util.Measures_Total(   p_measure1 => l_pji_facts.itd_ar_amount_due
                                                                       ,p_measure2 => l_pji_facts.itd_ar_amount_overdue
                                                                     );
        l_itd_value(i):= l_measures_total/l_factor_by;


		l_measures_total := Pji_Rep_Util.Measures_Total(   p_measure1 => l_pji_facts.ac_ar_amount_due
                                                                       ,p_measure2 => l_pji_facts.ac_ar_amount_overdue
                                                                     );

        l_ac_value(i):= l_measures_total/l_factor_by;

        l_prp_value(i):=NULL;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_PC' AND bitand(l_check_plan_versions, g_Actual_CstFcst) = g_Actual_CstFcst THEN
        --  percent complete =
        --      actual burd cost / forecast burd cost
        --
        x_measure_type(i) := g_PercentType;

/* Uncommented for bug 6961599 */
        IF l_overview_type(l_cost_forecast_index).ptd_burdened_cost <> 0 THEN
            l_ptd_value(i):=100 * (l_overview_type(l_actual_index).ptd_burdened_cost /
                            l_overview_type(l_cost_forecast_index).ptd_burdened_cost);
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_forecast_index).qtd_burdened_cost <> 0 THEN
            l_qtd_value(i):=100 * (l_overview_type(l_actual_index).qtd_burdened_cost /
                            l_overview_type(l_cost_forecast_index).qtd_burdened_cost);
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_forecast_index).ytd_burdened_cost <> 0 THEN
            l_ytd_value(i):=100 * (l_overview_type(l_actual_index).ytd_burdened_cost /
                            l_overview_type(l_cost_forecast_index).ytd_burdened_cost);
        ELSE
            l_ytd_value(i):= NULL;
        END IF;
/* Uncommented for bug 6961599 */
        IF l_overview_type(l_cost_forecast_index).itd_burdened_cost <> 0 THEN
            l_itd_value(i):=100 * (l_overview_type(l_actual_index).itd_burdened_cost /
                            l_overview_type(l_cost_forecast_index).itd_burdened_cost);
         /* Modified the itd calulation from ac to itd burdened cost for Bug 7681638 */
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_forecast_index).ac_burdened_cost <> 0 THEN
            l_ac_value(i):=100 * (l_overview_type(l_actual_index).ac_burdened_cost /
                           l_overview_type(l_cost_forecast_index).ac_burdened_cost);
        ELSE
            l_ac_value(i):= NULL;
        END IF;
/*
        IF l_overview_type(l_cost_forecast_index).prp_burdened_cost <> 0 THEN
            l_prp_value(i):=100 * (l_overview_type(l_actual_index).prp_burdened_cost /
                            l_overview_type(l_cost_forecast_index).prp_burdened_cost);
        ELSE
            l_prp_value(i):= NULL;
        END IF;
*/
      ELSIF p_measure_set_code(i) = 'PPF_MSR_PDR' THEN
        -- past due receivables (from PJI_AC_PROJ_F)
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=NULL;

        l_qtd_value(i):=NULL;

        l_ytd_value(i):=NULL;

        l_itd_value(i):=l_pji_facts.itd_ar_amount_overdue / l_factor_by;

        l_ac_value(i):=l_pji_facts.ac_ar_amount_overdue / l_factor_by;

        l_prp_value(i):=NULL;

      ELSIF  p_measure_set_code(i) = 'PPF_MSR_PFCV' AND bitand(l_check_plan_versions, g_Cst_FcstPriorfcst) = g_Cst_FcstPriorfcst THEN
        --
        -- Forecast Cost variance from Prior Forecast
        --      (Forecast Cost - Prior Forecast Cost)
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=(l_overview_type(l_cost_forecast_index).ptd_burdened_cost -
                        l_overview_type(l_prior_cost_forecast_index).ptd_burdened_cost) / l_factor_by;
/* Un-Commented the code for Bug 7681638 i.e reverted fix of 6961599 */
		/* Commented for bug 6961599 as this measure shouldn't display values for QTD/YTD */
        l_qtd_value(i):=(l_overview_type(l_cost_forecast_index).qtd_burdened_cost -
                        l_overview_type(l_prior_cost_forecast_index).qtd_burdened_cost) / l_factor_by;

        l_ytd_value(i):=(l_overview_type(l_cost_forecast_index).ytd_burdened_cost -
                        l_overview_type(l_prior_cost_forecast_index).ytd_burdened_cost) / l_factor_by;
/* Commented the code for Bug 7681638 Start
        l_qtd_value(i):=NULL;

        l_ytd_value(i):=NULL;
 Commented the code for Bug 7681638 End */

        l_itd_value(i):=(l_overview_type(l_cost_forecast_index).itd_burdened_cost -
                        l_overview_type(l_prior_cost_forecast_index).itd_burdened_cost) / l_factor_by;

        l_ac_value(i):= (l_overview_type(l_cost_forecast_index).ac_burdened_cost -
                        l_overview_type(l_prior_cost_forecast_index).ac_burdened_cost)  / l_factor_by;

        l_prp_value(i):=(l_overview_type(l_cost_forecast_index).prp_burdened_cost -
                        l_overview_type(l_prior_cost_forecast_index).prp_burdened_cost) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_POCC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- purchased orders committed cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_po_committed_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_po_committed_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_actual_index).ytd_po_committed_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_actual_index).itd_po_committed_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_po_committed_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_actual_index).prp_po_committed_cost / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_PPC' THEN
        --Physical Percent Complete (from PA_PERCENT_COMPLETES)
        x_measure_type(i) := g_PercentType;

        l_ptd_value(i):=NULL;
        l_qtd_value(i):=NULL;
        l_ytd_value(i):=NULL;

        IF l_completed_percentage IS NOT NULL THEN
          l_itd_value(i):=l_completed_percentage * 100;
          l_ac_value(i):=l_completed_percentage * 100;
        ELSE
          l_itd_value(i):=NULL;
          l_ac_value(i) :=NULL;
        END IF;

        l_prp_value(i):=NULL;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_PRCC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- purchased requisitions committed cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_pr_committed_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_pr_committed_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_actual_index).ytd_pr_committed_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_actual_index).itd_pr_committed_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_pr_committed_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_actual_index).prp_pr_committed_cost / l_factor_by;

       ELSIF p_measure_set_code(i) = 'PPF_MSR_PS' AND bitand(l_check_plan_versions, g_Actual_CstBudget) = g_Actual_CstBudget THEN
        --
        --  percent spent =
        --      actual burd cost / budget burdened cost
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_cost_budget_index).ptd_burdened_cost <> 0 THEN
            l_ptd_value(i):=100 * (l_overview_type(l_actual_index).ptd_burdened_cost /
                            l_overview_type(l_cost_budget_index).ptd_burdened_cost);
        ELSE
            l_ptd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).qtd_burdened_cost <> 0 THEN
            l_qtd_value(i):=100 * (l_overview_type(l_actual_index).qtd_burdened_cost /
                            l_overview_type(l_cost_budget_index).qtd_burdened_cost);
        ELSE
            l_qtd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ytd_burdened_cost <> 0 THEN
            l_ytd_value(i):=100 * (l_overview_type(l_actual_index).ytd_burdened_cost /
                            l_overview_type(l_cost_budget_index).ytd_burdened_cost);
        ELSE
           l_ytd_value(i):=NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).itd_burdened_cost <> 0 THEN
            l_itd_value(i):=100 * (l_overview_type(l_actual_index).itd_burdened_cost /
                            l_overview_type(l_cost_budget_index).itd_burdened_cost);
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ac_burdened_cost <> 0 THEN
            l_ac_value(i):=100 * (l_overview_type(l_actual_index).ac_burdened_cost /
                            l_overview_type(l_cost_budget_index).ac_burdened_cost);
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).prp_burdened_cost <> 0 THEN
            l_prp_value(i):=100 * (l_overview_type(l_actual_index).prp_burdened_cost /
                            l_overview_type(l_cost_budget_index).prp_burdened_cost);
        ELSE
            l_prp_value(i):= NULL;
        END IF;


      ELSIF p_measure_set_code(i) = 'PPF_MSR_PSE' AND bitand(l_check_plan_versions, g_Actual_CstBudget) = g_Actual_CstBudget THEN
        --
        --  percent spent effort =
        --      (actual equipment hrs + actual labor hrs) / (curr budget equipment hrs + curr budget labor hrs)
        --
        x_measure_type(i) := g_PercentType;

        l_num := l_overview_type(l_cost_budget_index).ptd_labor_hrs +
                 l_overview_type(l_cost_budget_index).ptd_equipment_hrs;
        IF l_num <> 0 THEN
            l_ptd_value(i):=100 * (l_overview_type(l_actual_index).ptd_equipment_hrs +
                            l_overview_type(l_actual_index).ptd_labor_hrs) / l_num;
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_cost_budget_index).qtd_labor_hrs +
                 l_overview_type(l_cost_budget_index).qtd_equipment_hrs;
        IF l_num <> 0 THEN
            l_qtd_value(i):=100 * (l_overview_type(l_actual_index).qtd_equipment_hrs +
                            l_overview_type(l_actual_index).qtd_labor_hrs) / l_num;
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_cost_budget_index).ytd_labor_hrs +
                 l_overview_type(l_cost_budget_index).ytd_equipment_hrs;
        IF l_num <> 0 THEN
            l_ytd_value(i):=100 * (l_overview_type(l_actual_index).ytd_equipment_hrs +
                            l_overview_type(l_actual_index).ytd_labor_hrs) / l_num;
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_cost_budget_index).itd_labor_hrs +
                 l_overview_type(l_cost_budget_index).itd_equipment_hrs;
        IF l_num <> 0 THEN
            l_itd_value(i):=100 * (l_overview_type(l_actual_index).itd_equipment_hrs +
                            l_overview_type(l_actual_index).itd_labor_hrs) / l_num;
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_cost_budget_index).ac_labor_hrs +
                 l_overview_type(l_cost_budget_index).ac_equipment_hrs;
        IF l_num <> 0 THEN
            l_ac_value(i):=100 * (l_overview_type(l_actual_index).ac_equipment_hrs +
                           l_overview_type(l_actual_index).ac_labor_hrs) / l_num;
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        l_num := l_overview_type(l_cost_budget_index).prp_labor_hrs +
                 l_overview_type(l_cost_budget_index).prp_equipment_hrs;
        IF l_num <> 0 THEN
            l_prp_value(i):=100 * (l_overview_type(l_actual_index).prp_equipment_hrs +
                            l_overview_type(l_actual_index).prp_labor_hrs) / l_num;
        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_PSEH' AND bitand(l_check_plan_versions, g_Actual_CstBudget) = g_Actual_CstBudget THEN
        --
        --  percent spent equipment hours =
        --      actual equipment hrs / curr budget equipment hrs
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_cost_budget_index).ptd_equipment_hrs <> 0 THEN
            l_ptd_value(i):=100 * (l_overview_type(l_actual_index).ptd_equipment_hrs /
                            l_overview_type(l_cost_budget_index).ptd_equipment_hrs);
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).qtd_equipment_hrs <> 0 THEN
            l_qtd_value(i):=100 * (l_overview_type(l_actual_index).qtd_equipment_hrs /
                            l_overview_type(l_cost_budget_index).qtd_equipment_hrs);
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ytd_equipment_hrs <> 0 THEN
            l_ytd_value(i):=100 * (l_overview_type(l_actual_index).ytd_equipment_hrs /
                            l_overview_type(l_cost_budget_index).ytd_equipment_hrs);
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).itd_equipment_hrs <> 0 THEN
            l_itd_value(i):=100 * (l_overview_type(l_actual_index).itd_equipment_hrs /
                            l_overview_type(l_cost_budget_index).itd_equipment_hrs);
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ac_equipment_hrs <> 0 THEN
            l_ac_value(i):=100 * (l_overview_type(l_actual_index).ac_equipment_hrs /
                           l_overview_type(l_cost_budget_index).ac_equipment_hrs);
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).prp_equipment_hrs <> 0 THEN
            l_prp_value(i):=100 * (l_overview_type(l_actual_index).prp_equipment_hrs /
                            l_overview_type(l_cost_budget_index).prp_equipment_hrs);
        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_PSLH' AND bitand(l_check_plan_versions, g_Actual_CstBudget) = g_Actual_CstBudget THEN
        --  percent spent labor hours =
        --      actual labor hrs / curr budget labor hrs
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_cost_budget_index).ptd_labor_hrs <> 0 THEN
            l_ptd_value(i):=100 * (l_overview_type(l_actual_index).ptd_labor_hrs /
                            l_overview_type(l_cost_budget_index).ptd_labor_hrs);
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).qtd_labor_hrs <> 0 THEN
            l_qtd_value(i):=100 * (l_overview_type(l_actual_index).qtd_labor_hrs /
                            l_overview_type(l_cost_budget_index).qtd_labor_hrs);
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ytd_labor_hrs <> 0 THEN
            l_ytd_value(i):=100 * (l_overview_type(l_actual_index).ytd_labor_hrs /
                            l_overview_type(l_cost_budget_index).ytd_labor_hrs);
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).itd_labor_hrs <> 0 THEN
            l_itd_value(i):=100 * (l_overview_type(l_actual_index).itd_labor_hrs /
                            l_overview_type(l_cost_budget_index).itd_labor_hrs);
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ac_labor_hrs <> 0 THEN
            l_ac_value(i):=100 * (l_overview_type(l_actual_index).ac_labor_hrs /
                           l_overview_type(l_cost_budget_index).ac_labor_hrs);
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).prp_labor_hrs <> 0 THEN
            l_prp_value(i):=100 * (l_overview_type(l_actual_index).prp_labor_hrs /
                            l_overview_type(l_cost_budget_index).prp_labor_hrs);
        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_PWQ' THEN
        -- Planned work quantity
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=l_planned_work_qt.ptd / l_effort_UOM;

        l_qtd_value(i):=l_planned_work_qt.qtd / l_effort_UOM;

        l_ytd_value(i):=l_planned_work_qt.ytd / l_effort_UOM;

        l_itd_value(i):=l_planned_work_qt.itd / l_effort_UOM;

        l_ac_value(i):=l_planned_work_qt.ac / l_effort_UOM;

        l_prp_value(i):=l_planned_work_qt.prp / l_effort_UOM;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_R' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- Revenue
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_revenue / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_revenue / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_actual_index).ytd_revenue / l_factor_by;

        l_itd_value(i):=l_overview_type(l_actual_index).itd_revenue / l_factor_by;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_revenue / l_factor_by;

        l_prp_value(i):=l_overview_type(l_actual_index).prp_revenue / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_RC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- raw cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_raw_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_raw_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_actual_index).ytd_raw_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_actual_index).itd_raw_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_raw_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_actual_index).prp_raw_cost / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_RR' THEN
        -- revenue at risk (from PJI_AC_PROJ_F)
        x_measure_type(i) := g_CurrencyType;
        l_ptd_value(i):= NULL;

        l_qtd_value(i):= NULL;

        l_ytd_value(i):= NULL;

        /* Commented out for bug 4194804
            l_num := l_overview_type(l_actual_index).itd_revenue - l_pji_facts.itd_additional_funding_amount
                 - l_pji_facts.itd_cancelled_funding_amount
			  	 - l_pji_facts.itd_funding_adjustment_amount
				 - l_pji_facts.itd_initial_funding_amount;
  */
        -- Added for bug  4194804
       l_measure1       := l_pji_facts.itd_additional_funding_amount;
       l_measure2       := l_pji_facts.itd_cancelled_funding_amount;
       l_measure3       := l_pji_facts.itd_funding_adjustment_amount;
       l_measure4       := l_pji_facts.itd_initial_funding_amount;

       l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                          ,p_measure2 => l_measure2
                                                          ,p_measure3 => l_measure3
                                                          ,p_measure4 => l_measure4
                                                        );

       l_num  := l_overview_type(l_actual_index).itd_revenue - NVL(l_measures_total,0);


		IF l_num < 0 THEN
		   l_num := 0;
		END IF;

        l_itd_value(i):=l_num / l_factor_by;

      /* Bug 6485047 Changes start here*/
       l_measure1       := l_pji_facts.ac_additional_funding_amount;
       l_measure2       := l_pji_facts.ac_cancelled_funding_amount;
       l_measure3       := l_pji_facts.ac_funding_adjustment_amount;
       l_measure4       := l_pji_facts.ac_initial_funding_amount;

       l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                          ,p_measure2 => l_measure2
                                                          ,p_measure3 => l_measure3
                                                          ,p_measure4 => l_measure4
                                                        );


       l_num  := l_overview_type(l_actual_index).ac_revenue - NVL(l_measures_total,0);


		IF l_num < 0 THEN
		   l_num := 0;
		END IF;

        l_ac_value(i):=l_num / l_factor_by;


	/*Bug 6485047 Changes end here*/

        l_prp_value(i):= NULL;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_RV' AND bitand(l_check_plan_versions, g_Actual_RevBudget) = g_Actual_RevBudget  THEN
        --
        -- revenue variance =
        --      (actual revenue - current budget revenue)
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=(l_overview_type(l_actual_index).ptd_revenue -
                        l_overview_type(l_rev_budget_index).ptd_revenue) / l_factor_by;

        l_qtd_value(i):=(l_overview_type(l_actual_index).qtd_revenue -
                        l_overview_type(l_rev_budget_index).qtd_revenue) / l_factor_by;

        l_ytd_value(i):=(l_overview_type(l_actual_index).ytd_revenue -
                        l_overview_type(l_rev_budget_index).ytd_revenue) / l_factor_by;

        l_itd_value(i):=(l_overview_type(l_actual_index).itd_revenue -
                        l_overview_type(l_rev_budget_index).itd_revenue) / l_factor_by;

        l_ac_value(i) :=(l_overview_type(l_actual_index).ac_revenue -
                        l_overview_type(l_rev_budget_index).ac_revenue) / l_factor_by;

        l_prp_value(i):=(l_overview_type(l_actual_index).prp_revenue -
                        l_overview_type(l_rev_budget_index).prp_revenue) / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_RW' THEN
        -- revenue write offs (from PJI_AC_PROJ_F)
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_pji_facts.ptd_revenue_writeoff / l_factor_by;

        l_qtd_value(i):=l_pji_facts.qtd_revenue_writeoff / l_factor_by;

        l_ytd_value(i):=l_pji_facts.ytd_revenue_writeoff / l_factor_by;

        l_itd_value(i):=l_pji_facts.itd_revenue_writeoff / l_factor_by;

        l_ac_value(i):=l_pji_facts.ac_revenue_writeoff / l_factor_by;

        l_prp_value(i):=l_pji_facts.prp_revenue_writeoff / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_RWQ' THEN
        --
        -- Remaining Work Quantity (only lowest level task) =
        --      WQ_PLANNED_QUANTITY (ELEMENT_VERSION_ID=PROJECT_ELEMENT_ID) -
        --      INCREMENTAL_WORK_QUANTITY (PUBLISHED_FLAG='Y',OBJECT_TYPE='PA_TASKS',OBJECT_VERSION_ID=PROJECT_ELEMENT_ID)
        --
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=(l_planned_work_qt.ptd - l_incr_work_qt.ptd) / l_effort_UOM;

        l_qtd_value(i):=(l_planned_work_qt.qtd - l_incr_work_qt.qtd) / l_effort_UOM;

        l_ytd_value(i):=(l_planned_work_qt.ytd - l_incr_work_qt.ytd) / l_effort_UOM;

        l_itd_value(i):=(l_planned_work_qt.itd - l_incr_work_qt.itd) / l_effort_UOM;

        l_ac_value(i):=(l_planned_work_qt.ac - l_incr_work_qt.ac) / l_effort_UOM;

        l_prp_value(i):=(l_planned_work_qt.prp - l_incr_work_qt.prp) / l_effort_UOM;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_SICC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- supplier invoices committed cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_sup_inv_committed_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_sup_inv_committed_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_actual_index).ytd_sup_inv_committed_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_actual_index).itd_sup_inv_committed_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_sup_inv_committed_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_actual_index).prp_sup_inv_committed_cost / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_SPI' AND bitand(l_check_plan_versions, g_CstBudget_is_present) = g_CstBudget_is_present THEN
        -- Schedule performance index =
        --      (budget burden cost * completed percentage) / budget burden cost
        --
        x_measure_type(i) := g_IndexType;

        l_ptd_value(i):=NULL;

        l_qtd_value(i):=NULL;

        l_ytd_value(i):=NULL;

        IF l_overview_type(l_cost_budget_index).itd_burdened_cost <> 0 THEN
            l_itd_value(i):=((l_overview_type(l_cost_budget_index).ac_burdened_cost * l_completed_percentage)
                            / l_overview_type(l_cost_budget_index).itd_burdened_cost);
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ac_burdened_cost <> 0 THEN
            l_ac_value(i):=((l_overview_type(l_cost_budget_index).ac_burdened_cost * l_completed_percentage)
                            / l_overview_type(l_cost_budget_index).ac_burdened_cost);
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        l_prp_value(i):= NULL;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_TC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- total cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_burdened_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_burdened_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_actual_index).ytd_burdened_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_actual_index).itd_burdened_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_burdened_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_actual_index).prp_burdened_cost / l_factor_by;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_TCC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        --
        -- total committed cost =
        -- supplier invoice committed cost + purchase orders committed cost + purchase requisitions committed cost + other committed cost
        --
        x_measure_type(i) := g_CurrencyType;

        -- Added for bug 4194804
        l_measure1       := l_overview_type(l_actual_index).ptd_sup_inv_committed_cost;
        l_measure2       := l_overview_type(l_actual_index).ptd_po_committed_cost;
        l_measure3       := l_overview_type(l_actual_index).ptd_pr_committed_cost;
        l_measure4       := l_overview_type(l_actual_index).ptd_oth_committed_cost;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_ptd_value(i):= l_measures_total/l_factor_by;

        -- Added for bug 4194804
        l_measure1       := l_overview_type(l_actual_index).qtd_sup_inv_committed_cost;
        l_measure2       := l_overview_type(l_actual_index).qtd_po_committed_cost;
        l_measure3       := l_overview_type(l_actual_index).qtd_pr_committed_cost;
        l_measure4       := l_overview_type(l_actual_index).qtd_oth_committed_cost;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_qtd_value(i):= l_measures_total/l_factor_by;

        -- Added for bug 4194804
        l_measure1       := l_overview_type(l_actual_index).ytd_sup_inv_committed_cost;
        l_measure2       := l_overview_type(l_actual_index).ytd_po_committed_cost;
        l_measure3       := l_overview_type(l_actual_index).ytd_pr_committed_cost;
        l_measure4       := l_overview_type(l_actual_index).ytd_oth_committed_cost;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_ytd_value(i):= l_measures_total/l_factor_by;

        -- Added for bug 4194804
        l_measure1       := l_overview_type(l_actual_index).itd_sup_inv_committed_cost;
        l_measure2       := l_overview_type(l_actual_index).itd_po_committed_cost;
        l_measure3       := l_overview_type(l_actual_index).itd_pr_committed_cost;
        l_measure4       := l_overview_type(l_actual_index).itd_oth_committed_cost;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_itd_value(i):= l_measures_total/l_factor_by;

        -- Added for bug 4194804
        l_measure1       := l_overview_type(l_actual_index).ac_sup_inv_committed_cost;
        l_measure2       := l_overview_type(l_actual_index).ac_po_committed_cost;
        l_measure3       := l_overview_type(l_actual_index).ac_pr_committed_cost;
        l_measure4       := l_overview_type(l_actual_index).ac_oth_committed_cost;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_ac_value(i):= l_measures_total/l_factor_by;

        -- Added for bug 4194804
        l_measure1       := l_overview_type(l_actual_index).prp_sup_inv_committed_cost;
        l_measure2       := l_overview_type(l_actual_index).prp_po_committed_cost;
        l_measure3       := l_overview_type(l_actual_index).prp_pr_committed_cost;
        l_measure4       := l_overview_type(l_actual_index).prp_oth_committed_cost;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_prp_value(i):= l_measures_total/l_factor_by;

     /* Commented for bug 4194804
        l_ptd_value(i):=(l_overview_type(l_actual_index).ptd_sup_inv_committed_cost + l_overview_type(l_actual_index).ptd_po_committed_cost +
                         l_overview_type(l_actual_index).ptd_pr_committed_cost + l_overview_type(l_actual_index).ptd_oth_committed_cost) / l_factor_by;

        l_qtd_value(i):=(l_overview_type(l_actual_index).qtd_sup_inv_committed_cost + l_overview_type(l_actual_index).qtd_po_committed_cost +
                         l_overview_type(l_actual_index).qtd_pr_committed_cost + l_overview_type(l_actual_index).qtd_oth_committed_cost) / l_factor_by;

        l_ytd_value(i):=(l_overview_type(l_actual_index).ytd_sup_inv_committed_cost + l_overview_type(l_actual_index).ytd_po_committed_cost +
                         l_overview_type(l_actual_index).ytd_pr_committed_cost + l_overview_type(l_actual_index).ytd_oth_committed_cost) / l_factor_by;

        l_itd_value(i):=(l_overview_type(l_actual_index).itd_sup_inv_committed_cost + l_overview_type(l_actual_index).itd_po_committed_cost +
                         l_overview_type(l_actual_index).itd_pr_committed_cost + l_overview_type(l_actual_index).itd_oth_committed_cost) / l_factor_by;

        l_ac_value(i):=(l_overview_type(l_actual_index).ac_sup_inv_committed_cost + l_overview_type(l_actual_index).ac_po_committed_cost +
                         l_overview_type(l_actual_index).ac_pr_committed_cost + l_overview_type(l_actual_index).ac_oth_committed_cost) / l_factor_by;

        l_prp_value(i):=(l_overview_type(l_actual_index).prp_sup_inv_committed_cost + l_overview_type(l_actual_index).prp_po_committed_cost +
                         l_overview_type(l_actual_index).prp_pr_committed_cost + l_overview_type(l_actual_index).prp_oth_committed_cost) / l_factor_by;
*/


      ELSIF p_measure_set_code(i) = 'PPF_MSR_TCCC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- total cost + committed cost
        x_measure_type(i) := g_CurrencyType;

        -- Added for bug 4194804
        l_measure1       := l_overview_type(l_actual_index).ptd_sup_inv_committed_cost;
        l_measure2       := l_overview_type(l_actual_index).ptd_po_committed_cost;
        l_measure3       := l_overview_type(l_actual_index).ptd_pr_committed_cost;
        l_measure4       := l_overview_type(l_actual_index).ptd_oth_committed_cost;
        l_measure5       := l_overview_type(l_actual_index).ptd_burdened_cost;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                           ,p_measure5 => l_measure5
                                                         );

        l_ptd_value(i):= l_measures_total/l_factor_by;

         -- Added for bug 4194804
        l_measure1       := l_overview_type(l_actual_index).qtd_sup_inv_committed_cost;
        l_measure2       := l_overview_type(l_actual_index).qtd_po_committed_cost;
        l_measure3       := l_overview_type(l_actual_index).qtd_pr_committed_cost;
        l_measure4       := l_overview_type(l_actual_index).qtd_oth_committed_cost;
        l_measure5       := l_overview_type(l_actual_index).qtd_burdened_cost;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                           ,p_measure5 => l_measure5
                                                         );
        l_qtd_value(i):= l_measures_total/l_factor_by;

         -- Added for bug 4194804
        l_measure1       := l_overview_type(l_actual_index).ytd_sup_inv_committed_cost;
        l_measure2       := l_overview_type(l_actual_index).ytd_po_committed_cost;
        l_measure3       := l_overview_type(l_actual_index).ytd_pr_committed_cost;
        l_measure4       := l_overview_type(l_actual_index).ytd_oth_committed_cost;
        l_measure5       := l_overview_type(l_actual_index).ytd_burdened_cost;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                           ,p_measure5 => l_measure5
                                                         );

        l_ytd_value(i):= l_measures_total/l_factor_by;

        -- Added for bug  4194804
        l_measure1       := l_overview_type(l_actual_index).itd_sup_inv_committed_cost;
        l_measure2       := l_overview_type(l_actual_index).itd_po_committed_cost;
        l_measure3       := l_overview_type(l_actual_index).itd_pr_committed_cost;
        l_measure4       := l_overview_type(l_actual_index).itd_oth_committed_cost;
        l_measure5       := l_overview_type(l_actual_index).itd_burdened_cost;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                           ,p_measure5 => l_measure5
                                                         );

        l_itd_value(i):= l_measures_total/l_factor_by;

        -- Added for bug  4194804
        l_measure1       := l_overview_type(l_actual_index).ac_sup_inv_committed_cost;
        l_measure2       := l_overview_type(l_actual_index).ac_po_committed_cost;
        l_measure3       := l_overview_type(l_actual_index).ac_pr_committed_cost;
        l_measure4       := l_overview_type(l_actual_index).ac_oth_committed_cost;
        l_measure5       := l_overview_type(l_actual_index).ac_burdened_cost;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                           ,p_measure5 => l_measure5
                                                         );

        l_ac_value(i):= l_measures_total/l_factor_by;

        -- Added for bug  4194804
        l_measure1       := l_overview_type(l_actual_index).prp_sup_inv_committed_cost;
        l_measure2       := l_overview_type(l_actual_index).prp_po_committed_cost;
        l_measure3       := l_overview_type(l_actual_index).prp_pr_committed_cost;
        l_measure4       := l_overview_type(l_actual_index).prp_oth_committed_cost;
        l_measure5       := l_overview_type(l_actual_index).prp_burdened_cost;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                           ,p_measure5 => l_measure5
                                                         );

        l_prp_value(i):= l_measures_total/l_factor_by;

/* Commented for bug 4194804
        l_ptd_value(i):=(l_overview_type(l_actual_index).ptd_sup_inv_committed_cost + l_overview_type(l_actual_index).ptd_po_committed_cost +
                         l_overview_type(l_actual_index).ptd_pr_committed_cost + l_overview_type(l_actual_index).ptd_oth_committed_cost +
                         l_overview_type(l_actual_index).ptd_burdened_cost) / l_factor_by;

        l_qtd_value(i):=(l_overview_type(l_actual_index).qtd_sup_inv_committed_cost + l_overview_type(l_actual_index).qtd_po_committed_cost +
                         l_overview_type(l_actual_index).qtd_pr_committed_cost + l_overview_type(l_actual_index).qtd_oth_committed_cost +
                         l_overview_type(l_actual_index).qtd_burdened_cost) / l_factor_by;

        l_ytd_value(i):=(l_overview_type(l_actual_index).ytd_sup_inv_committed_cost + l_overview_type(l_actual_index).ytd_po_committed_cost +
                         l_overview_type(l_actual_index).ytd_pr_committed_cost + l_overview_type(l_actual_index).ytd_oth_committed_cost +
                         l_overview_type(l_actual_index).ytd_burdened_cost) / l_factor_by;

        l_itd_value(i):=(l_overview_type(l_actual_index).itd_sup_inv_committed_cost + l_overview_type(l_actual_index).itd_po_committed_cost +
                         l_overview_type(l_actual_index).itd_pr_committed_cost + l_overview_type(l_actual_index).itd_oth_committed_cost +
                         l_overview_type(l_actual_index).itd_burdened_cost) / l_factor_by;

        l_ac_value(i):=(l_overview_type(l_actual_index).ac_sup_inv_committed_cost + l_overview_type(l_actual_index).ac_po_committed_cost +
                         l_overview_type(l_actual_index).ac_pr_committed_cost + l_overview_type(l_actual_index).ac_oth_committed_cost +
                         l_overview_type(l_actual_index).ac_burdened_cost) / l_factor_by;

        l_prp_value(i):=(l_overview_type(l_actual_index).prp_sup_inv_committed_cost + l_overview_type(l_actual_index).prp_po_committed_cost +
                         l_overview_type(l_actual_index).prp_pr_committed_cost + l_overview_type(l_actual_index).prp_oth_committed_cost +
                         l_overview_type(l_actual_index).prp_burdened_cost) / l_factor_by;

*/

      ELSIF p_measure_set_code(i) = 'PPF_MSR_TLC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present  THEN
        --Total labor cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_labor_burdened_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_labor_burdened_cost / l_factor_by;

        l_ytd_value(i) := l_overview_type(l_actual_index).ytd_labor_burdened_cost / l_factor_by;

        l_itd_value(i) := l_overview_type(l_actual_index).itd_labor_burdened_cost / l_factor_by;

        l_ac_value(i) := l_overview_type(l_actual_index).ac_labor_burdened_cost / l_factor_by;

        l_prp_value(i) := l_overview_type(l_actual_index).prp_labor_burdened_cost / l_factor_by;

      ELSIF (p_measure_set_code(i) = 'PPF_MSR_TEH' OR p_measure_set_code(i) = 'PPF_MSR_THE') AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present  THEN
        --Total equipment hours
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_equipment_hrs / l_effort_UOM;

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_equipment_hrs / l_effort_UOM;

        l_ytd_value(i):=l_overview_type(l_actual_index).ytd_equipment_hrs / l_effort_UOM;

        l_itd_value(i):=l_overview_type(l_actual_index).itd_equipment_hrs / l_effort_UOM;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_equipment_hrs / l_effort_UOM;

        l_prp_value(i):=l_overview_type(l_actual_index).prp_equipment_hrs / l_effort_UOM;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_TLH' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present  THEN
        --Total labor hours
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_labor_hrs / l_effort_UOM;

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_labor_hrs / l_effort_UOM;

        l_ytd_value(i):=l_overview_type(l_actual_index).ytd_labor_hrs / l_effort_UOM;

        l_itd_value(i):=l_overview_type(l_actual_index).itd_labor_hrs / l_effort_UOM;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_labor_hrs / l_effort_UOM;

        l_prp_value(i):=l_overview_type(l_actual_index).prp_labor_hrs / l_effort_UOM;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_TNF' THEN
        -- Total Net Funding (from PJI_AC_PROJ_F) =
        --      initial_funding_amount + additional_funding_amount + funding_adjustment_amount + cancelled_funding_amount
        --
        x_measure_type(i) := g_CurrencyType;


        -- Added for bug  4194804
        l_measure1       := l_pji_facts.ptd_initial_funding_amount;
        l_measure2       := l_pji_facts.ptd_additional_funding_amount;
        l_measure3       := l_pji_facts.ptd_funding_adjustment_amount;
        l_measure4       := l_pji_facts.ptd_cancelled_funding_amount;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_ptd_value(i):= l_measures_total/l_factor_by;

        -- Added for bug  4194804
        l_measure1       := l_pji_facts.qtd_initial_funding_amount;
        l_measure2       := l_pji_facts.qtd_additional_funding_amount;
        l_measure3       := l_pji_facts.qtd_funding_adjustment_amount;
        l_measure4       := l_pji_facts.qtd_cancelled_funding_amount;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_qtd_value(i):= l_measures_total/l_factor_by;

        -- Added for bug  4194804
        l_measure1       := l_pji_facts.ytd_initial_funding_amount;
        l_measure2       := l_pji_facts.ytd_additional_funding_amount;
        l_measure3       := l_pji_facts.ytd_funding_adjustment_amount;
        l_measure4       := l_pji_facts.ytd_cancelled_funding_amount;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_ytd_value(i):= l_measures_total/l_factor_by;

        -- Added for bug  4194804
        l_measure1       := l_pji_facts.itd_initial_funding_amount;
        l_measure2       := l_pji_facts.itd_additional_funding_amount;
        l_measure3       := l_pji_facts.itd_funding_adjustment_amount;
        l_measure4       := l_pji_facts.itd_cancelled_funding_amount;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_itd_value(i):= l_measures_total/l_factor_by;

        -- Added for bug  4194804
        l_measure1       := l_pji_facts.ac_initial_funding_amount;
        l_measure2       := l_pji_facts.ac_additional_funding_amount;
        l_measure3       := l_pji_facts.ac_funding_adjustment_amount;
        l_measure4       := l_pji_facts.ac_cancelled_funding_amount;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_ac_value(i):= l_measures_total/l_factor_by;

        -- Added for bug  4194804
        l_measure1       := l_pji_facts.prp_initial_funding_amount;
        l_measure2       := l_pji_facts.prp_additional_funding_amount;
        l_measure3       := l_pji_facts.prp_funding_adjustment_amount;
        l_measure4       := l_pji_facts.prp_cancelled_funding_amount;
        l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                           ,p_measure2 => l_measure2
                                                           ,p_measure3 => l_measure3
                                                           ,p_measure4 => l_measure4
                                                         );

        l_prp_value(i):= l_measures_total/l_factor_by;


/* Commented for bug 4194804
        l_ptd_value(i) := (l_pji_facts.ptd_initial_funding_amount + l_pji_facts.ptd_additional_funding_amount +
                 l_pji_facts.ptd_funding_adjustment_amount + l_pji_facts.ptd_cancelled_funding_amount)/ l_factor_by;

        l_qtd_value(i) := (l_pji_facts.qtd_initial_funding_amount + l_pji_facts.qtd_additional_funding_amount +
                 l_pji_facts.qtd_funding_adjustment_amount + l_pji_facts.qtd_cancelled_funding_amount)/ l_factor_by;

        l_ytd_value(i) := (l_pji_facts.ytd_initial_funding_amount + l_pji_facts.ytd_additional_funding_amount +
                l_pji_facts.ytd_funding_adjustment_amount + l_pji_facts.ytd_cancelled_funding_amount)/ l_factor_by;

        l_itd_value(i) := (l_pji_facts.itd_initial_funding_amount + l_pji_facts.itd_additional_funding_amount +
                l_pji_facts.itd_funding_adjustment_amount + l_pji_facts.itd_cancelled_funding_amount)/ l_factor_by;

        l_ac_value(i) := (l_pji_facts.ac_initial_funding_amount + l_pji_facts.ac_additional_funding_amount +
                l_pji_facts.ac_funding_adjustment_amount + l_pji_facts.ac_cancelled_funding_amount)/ l_factor_by;

        l_prp_value(i) := (l_pji_facts.prp_initial_funding_amount + l_pji_facts.prp_additional_funding_amount +
                l_pji_facts.prp_funding_adjustment_amount + l_pji_facts.prp_cancelled_funding_amount)/ l_factor_by;
*/

      ELSIF p_measure_set_code(i) = 'PPF_MSR_TRDO' THEN
        -- Total receivables Days Outstanding (from PJI_AC_PROJ_F)
        --      ((cash allocated + unbilled receivables) / ar_invoice_amount) * number of days in the period
        --
        x_measure_type(i) := g_DaysType;

/*        IF l_pji_facts.ptd_ar_invoice_amount <> 0 THEN
            l_ptd_value(i):=((l_pji_facts.ptd_ar_cash_applied_amount + l_pji_facts.ptd_unbilled_receivables) / l_pji_facts.ptd_ar_invoice_amount) * xDaysInPeriod;
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_pji_facts.qtd_ar_invoice_amount <> 0 THEN
            l_qtd_value(i):=((l_pji_facts.qtd_ar_cash_applied_amount + l_pji_facts.qtd_unbilled_receivables) / l_pji_facts.qtd_ar_invoice_amount) * xDaysInPeriod;
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_pji_facts.ytd_ar_invoice_amount <> 0 THEN
            l_ytd_value(i):=((l_pji_facts.ytd_ar_cash_applied_amount + l_pji_facts.ytd_unbilled_receivables) / l_pji_facts.ytd_ar_invoice_amount) * xDaysInPeriod;
        ELSE
            l_ytd_value(i):= NULL;
        END IF;
*/


        IF l_pji_facts.itd_ar_invoice_amount <> 0 THEN
/* Commented for bug 4194804
      l_itd_value(i):=((l_pji_facts.itd_ar_invoice_amount - l_pji_facts.itd_ar_cash_applied_amount + l_pji_facts.itd_unbilled_receivables) / l_pji_facts.itd_ar_invoice_amount) * xDaysSinceITD;  */

                     -- Added for bug  4194804
                    l_measure1       := l_pji_facts.itd_ar_amount_due;
					l_measure2		 := l_pji_facts.itd_ar_amount_overdue;
                    l_measure2       := l_pji_facts.itd_unbilled_receivables;
                    l_measures_total :=  Pji_Rep_Util.Measures_Total(   p_measure1 => l_measure1
                                                                       ,p_measure2 => l_measure2
																	   ,p_measure3 => l_measure3
                                                                     );

                    l_itd_value(i):= ( NVL(l_measures_total,0) /l_pji_facts.itd_ar_invoice_amount ) * xDaysSinceITD;

        ELSE
            l_itd_value(i):= NULL;
        END IF;
/*
		l_ac_value(i) := l_itd_value(i);


        IF l_pji_facts.ac_ar_invoice_amount <> 0 THEN
            l_ac_value(i):=((l_pji_facts.ac_ar_cash_applied_amount + l_pji_facts.ac_unbilled_receivables) / l_pji_facts.ac_ar_invoice_amount) * xDaysInPeriod;
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_pji_facts.prp_ar_invoice_amount <> 0 THEN
            l_prp_value(i):=((l_pji_facts.prp_ar_cash_applied_amount + l_pji_facts.prp_unbilled_receivables) / l_pji_facts.prp_ar_invoice_amount) * xDaysInPeriod;
        ELSE
            l_prp_value(i):= NULL;
        END IF;
*/

/* Unbilled Cost is scoped out
      ELSIF p_measure_set_code(i) = 'PPF_MSR_UBC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present  THEN
        -- unbilled cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=NULL;

        l_qtd_value(i):=NULL;

        l_ytd_value(i):=NULL;

        l_itd_value(i):=l_overview_type(l_actual_index).itd_unbilled_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_unbilled_cost / l_factor_by;

        l_prp_value(i):=NULL;
*/
      ELSIF p_measure_set_code(i) = 'PPF_MSR_UBR' THEN
        -- unbilled receivables (from PJI_AC_PROJ_F)
        x_measure_type(i) := g_CurrencyType;
/* Starts added for bug 6961599 */
        l_ptd_value(i):=l_pji_facts.ptd_unbilled_receivables / l_factor_by;

        l_qtd_value(i):=l_pji_facts.qtd_unbilled_receivables / l_factor_by;

	    l_ytd_value(i):=l_pji_facts.ytd_unbilled_receivables / l_factor_by;

/* Ends added for bug 6961599 */

/* Commented for bug 6961599
        l_ptd_value(i):=NULL;

        l_qtd_value(i):=NULL;

        l_ytd_value(i):=NULL;
*/
        l_itd_value(i):=l_pji_facts.itd_unbilled_receivables / l_factor_by;

        l_ac_value(i):=l_pji_facts.ac_unbilled_receivables / l_factor_by;

        l_prp_value(i):=NULL;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_UER' THEN
        -- unearned_revenue (from PJI_AC_PROJ_F)
        x_measure_type(i) := g_CurrencyType;

/* Starts added for bug 6961599 */
        l_ptd_value(i):=l_pji_facts.ptd_unearned_revenue / l_factor_by;

        l_qtd_value(i):=l_pji_facts.qtd_unearned_revenue / l_factor_by;

	    l_ytd_value(i):=l_pji_facts.ytd_unearned_revenue / l_factor_by;

/* Ends added for bug 6961599 */

/* Commented for bug 6961599
        l_ptd_value(i):=NULL;

        l_qtd_value(i):=NULL;

        l_ytd_value(i):=NULL;
*/

        l_itd_value(i):=l_pji_facts.itd_unearned_revenue / l_factor_by;

        l_ac_value(i):=l_pji_facts.ac_unearned_revenue / l_factor_by;

        l_prp_value(i):=NULL;

/* New measures added by Ning */
      ELSIF  p_measure_set_code(i) = 'PPF_MSR_CVP' AND bitand(l_check_plan_versions, g_Actual_CstBudget) = g_Actual_CstBudget THEN
        --
        -- Cost variance Percent=
        --      (Actual Burden Cost - Current Budget Cost)/Current Budget Cost)
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_cost_budget_index).ptd_burdened_cost <> 0 THEN
            l_ptd_value(i):= 100*(l_overview_type(l_actual_index).ptd_burdened_cost -
                                    l_overview_type(l_cost_budget_index).ptd_burdened_cost) /
                                    l_overview_type(l_cost_budget_index).ptd_burdened_cost;
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).itd_burdened_cost <> 0 THEN
            l_itd_value(i):= 100*(l_overview_type(l_actual_index).itd_burdened_cost -
                                    l_overview_type(l_cost_budget_index).itd_burdened_cost) /
                                    l_overview_type(l_cost_budget_index).itd_burdened_cost;
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).qtd_burdened_cost <> 0 THEN
            l_qtd_value(i):= 100*(l_overview_type(l_actual_index).qtd_burdened_cost -
                                    l_overview_type(l_cost_budget_index).qtd_burdened_cost) /
                                    l_overview_type(l_cost_budget_index).qtd_burdened_cost;
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ytd_burdened_cost <> 0 THEN
            l_ytd_value(i):= 100*(l_overview_type(l_actual_index).ytd_burdened_cost -
                                    l_overview_type(l_cost_budget_index).ytd_burdened_cost) /
                                    l_overview_type(l_cost_budget_index).ytd_burdened_cost;
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ac_burdened_cost <> 0 THEN
            l_ac_value(i):= 100*(l_overview_type(l_actual_index).ac_burdened_cost -
                                    l_overview_type(l_cost_budget_index).ac_burdened_cost) /
                                    l_overview_type(l_cost_budget_index).ac_burdened_cost;
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).prp_burdened_cost <> 0 THEN
            l_prp_value(i):= 100*(l_overview_type(l_actual_index).prp_burdened_cost -
                                    l_overview_type(l_cost_budget_index).prp_burdened_cost) /
                                    l_overview_type(l_cost_budget_index).prp_burdened_cost;
        ELSE
            l_ac_value(i):= NULL;
        END IF;


      ELSIF p_measure_set_code(i) = 'PPF_MSR_MVP' AND bitand(l_check_plan_versions, g_Actual_CstRevBudget) = g_Actual_CstRevBudget THEN
        --
        -- margin variance % =
        --      (Actual Revenue - Actual Burdended Cost) - (Current Budget Revenue - Current Budget Burdended Cost)
		-- / (Current Budget Revenue - Current Budget Burdended Cost) * 100
        --
        x_measure_type(i) := g_PercentType;

	    IF (NVL(l_overview_type(l_cost_budget_index).ptd_burdened_cost,0) - NVL(l_overview_type(l_rev_budget_index).ptd_revenue,0) ) <>0 THEN
           l_ptd_value(i):= 100*((l_overview_type(l_actual_index).ptd_revenue
						 - l_overview_type(l_actual_index).ptd_burdened_cost) -
						 (l_overview_type(l_rev_budget_index).ptd_revenue-
                         l_overview_type(l_cost_budget_index).ptd_burdened_cost
                         )) /(l_overview_type(l_rev_budget_index).ptd_revenue-
                         l_overview_type(l_cost_budget_index).ptd_burdened_cost);
        ELSE
           l_ptd_value(i):=NULL;
        END IF;

	    IF (NVL(l_overview_type(l_cost_budget_index).qtd_burdened_cost,0) - NVL(l_overview_type(l_rev_budget_index).qtd_revenue,0) ) <>0 THEN
           l_qtd_value(i):= 100*((l_overview_type(l_actual_index).qtd_revenue
						 - l_overview_type(l_actual_index).qtd_burdened_cost) -
                         (l_overview_type(l_rev_budget_index).qtd_revenue -
						 l_overview_type(l_cost_budget_index).qtd_burdened_cost
                         ))/ (l_overview_type(l_rev_budget_index).qtd_revenue -
						 l_overview_type(l_cost_budget_index).qtd_burdened_cost);
        ELSE
           l_qtd_value(i):=NULL;
        END IF;

	    IF ( NVL(l_overview_type(l_cost_budget_index).ytd_burdened_cost,0) - NVL(l_overview_type(l_rev_budget_index).ytd_revenue,0) ) <>0 THEN
           l_ytd_value(i):= 100*((l_overview_type(l_actual_index).ytd_revenue
						 - l_overview_type(l_actual_index).ytd_burdened_cost) -
                         (l_overview_type(l_rev_budget_index).ytd_revenue-
						 l_overview_type(l_cost_budget_index).ytd_burdened_cost
                         )) / (l_overview_type(l_rev_budget_index).ytd_revenue -
						 l_overview_type(l_cost_budget_index).ytd_burdened_cost);
        ELSE
           l_ytd_value(i):=NULL;
        END IF;

	    IF (NVL(l_overview_type(l_cost_budget_index).itd_burdened_cost,0) - NVL(l_overview_type(l_rev_budget_index).itd_revenue,0) ) <>0 THEN
           l_itd_value(i):= 100*((l_overview_type(l_actual_index).itd_revenue
						 - l_overview_type(l_actual_index).itd_burdened_cost) -
                         (l_overview_type(l_rev_budget_index).itd_revenue -
						 l_overview_type(l_cost_budget_index).itd_burdened_cost
                         )) / (l_overview_type(l_rev_budget_index).itd_revenue -
						 l_overview_type(l_cost_budget_index).itd_burdened_cost);
        ELSE
           l_itd_value(i):=NULL;
        END IF;

	    IF (NVL(l_overview_type(l_cost_budget_index).ac_burdened_cost,0) - NVL(l_overview_type(l_rev_budget_index).ac_revenue,0)) <>0 THEN
           l_ac_value(i):= 100*((l_overview_type(l_actual_index).ac_revenue
						 - l_overview_type(l_actual_index).ac_burdened_cost) -
                         (l_overview_type(l_rev_budget_index).ac_revenue -
						 l_overview_type(l_cost_budget_index).ac_burdened_cost
                         )) / (l_overview_type(l_rev_budget_index).ac_revenue
						 - l_overview_type(l_cost_budget_index).ac_burdened_cost);
        ELSE
           l_ac_value(i):=NULL;
        END IF;

	    IF (NVL(l_overview_type(l_cost_budget_index).prp_burdened_cost,0) - NVL(l_overview_type(l_rev_budget_index).prp_revenue,0)) <>0 THEN
           l_prp_value(i):= 100*((l_overview_type(l_actual_index).prp_revenue
						 - l_overview_type(l_actual_index).prp_burdened_cost) -
                         (l_overview_type(l_cost_budget_index).prp_burdened_cost -
                         l_overview_type(l_rev_budget_index).prp_revenue
                         )) / (l_overview_type(l_rev_budget_index).prp_revenue -
						 l_overview_type(l_cost_budget_index).prp_burdened_cost);
        ELSE
           l_prp_value(i):=NULL;
        END IF;
      ELSIF  p_measure_set_code(i) = 'PPF_MSR_RVP' AND bitand(l_check_plan_versions, g_Actual_RevBudget) = g_Actual_RevBudget THEN
        --
        -- Revenue variance Percent=
        --      (Actual Revenue - Current Budget Revenue)/Current Budget Revenue)
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_rev_budget_index).ptd_revenue <> 0 THEN
            l_ptd_value(i):= 100*(l_overview_type(l_actual_index).ptd_revenue -
                                    l_overview_type(l_rev_budget_index).ptd_revenue) /
                                    l_overview_type(l_rev_budget_index).ptd_revenue;
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget_index).qtd_revenue <> 0 THEN
            l_qtd_value(i):= 100*(l_overview_type(l_actual_index).qtd_revenue -
                                    l_overview_type(l_rev_budget_index).qtd_revenue) /
                                    l_overview_type(l_rev_budget_index).qtd_revenue;
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget_index).ytd_revenue <> 0 THEN
            l_ytd_value(i):= 100*(l_overview_type(l_actual_index).ytd_revenue -
                                    l_overview_type(l_rev_budget_index).ytd_revenue) /
                                    l_overview_type(l_rev_budget_index).ytd_revenue;
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget_index).itd_revenue <> 0 THEN
            l_itd_value(i):= 100*(l_overview_type(l_actual_index).itd_revenue -
                                    l_overview_type(l_rev_budget_index).itd_revenue) /
                                    l_overview_type(l_rev_budget_index).itd_revenue;
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget_index).ac_revenue <> 0 THEN
            l_ac_value(i):= 100*(l_overview_type(l_actual_index).ac_revenue -
                                    l_overview_type(l_rev_budget_index).ac_revenue) /
                                    l_overview_type(l_rev_budget_index).ac_revenue;
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget_index).prp_revenue <> 0 THEN
            l_prp_value(i):= 100*(l_overview_type(l_actual_index).prp_revenue -
                                    l_overview_type(l_rev_budget_index).prp_revenue) /
                                    l_overview_type(l_rev_budget_index).prp_revenue;
        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_FMVP' AND bitand(l_check_plan_versions, g_CstRevBudgetFcst) = g_CstRevBudgetFcst THEN
        --
        -- Forecast margin variance % =
        --      (Forecast Revenue - Forecast Burdended Cost) - (Current Budget Revenue - Current Budget Burdended Cost)
		-- / (Current Budget Revenue - Current Budget Burdended Cost) * 100
        --
        x_measure_type(i) := g_PercentType;

	    IF (NVL(l_overview_type(l_cost_budget_index).ptd_burdened_cost,0) - NVL(l_overview_type(l_rev_budget_index).ptd_revenue,0)) <>0 THEN
           l_ptd_value(i):= 100*((l_overview_type(l_rev_forecast_index).ptd_revenue
						 - l_overview_type(l_cost_forecast_index).ptd_burdened_cost) -
                         (l_overview_type(l_rev_budget_index).ptd_revenue -
						 l_overview_type(l_cost_budget_index).ptd_burdened_cost
                         )) / (l_overview_type(l_rev_budget_index).ptd_revenue -
						 l_overview_type(l_cost_budget_index).ptd_burdened_cost);
        ELSE
           l_ptd_value(i):=NULL;
        END IF;

	    IF (NVL(l_overview_type(l_cost_budget_index).qtd_burdened_cost,0) - NVL(l_overview_type(l_rev_budget_index).qtd_revenue,0) ) <>0 THEN
           l_qtd_value(i):= 100*((l_overview_type(l_rev_forecast_index).qtd_revenue
						 - l_overview_type(l_cost_forecast_index).qtd_burdened_cost) -
                         (l_overview_type(l_rev_budget_index).qtd_revenue -
						 l_overview_type(l_cost_budget_index).qtd_burdened_cost
                         )) / (l_overview_type(l_rev_budget_index).qtd_revenue -
						 l_overview_type(l_cost_budget_index).qtd_burdened_cost);
        ELSE
           l_qtd_value(i):=NULL;
        END IF;

	    IF (NVL(l_overview_type(l_cost_budget_index).qtd_burdened_cost,0)  - NVL(l_overview_type(l_rev_budget_index).qtd_revenue,0) ) <>0 THEN
           l_qtd_value(i):= 100*((l_overview_type(l_rev_forecast_index).qtd_revenue
						 - l_overview_type(l_cost_forecast_index).qtd_burdened_cost) -
                         (l_overview_type(l_rev_budget_index).qtd_revenue -
						 l_overview_type(l_cost_budget_index).qtd_burdened_cost
                         )) / (l_overview_type(l_rev_budget_index).qtd_revenue -
						 l_overview_type(l_cost_budget_index).qtd_burdened_cost);
        ELSE
           l_qtd_value(i):=NULL;
        END IF;

	    IF (NVL(l_overview_type(l_cost_budget_index).ytd_burdened_cost,0)  - NVL(l_overview_type(l_rev_budget_index).ytd_revenue,0)) <>0 THEN
           l_ytd_value(i):= 100*((l_overview_type(l_rev_forecast_index).ytd_revenue
						 - l_overview_type(l_cost_forecast_index).ytd_burdened_cost) -
                         (l_overview_type(l_rev_budget_index).ytd_revenue -
						 l_overview_type(l_cost_budget_index).ytd_burdened_cost
                         )) / (l_overview_type(l_rev_budget_index).ytd_revenue -
						 l_overview_type(l_cost_budget_index).ytd_burdened_cost);
        ELSE
           l_ytd_value(i):=NULL;
        END IF;

	    IF (NVL(l_overview_type(l_cost_budget_index).itd_burdened_cost,0) - NVL(l_overview_type(l_rev_budget_index).itd_revenue,0)) <>0 THEN
           l_itd_value(i):= 100*((l_overview_type(l_rev_forecast_index).itd_revenue
						 - l_overview_type(l_cost_forecast_index).itd_burdened_cost) -
                         (l_overview_type(l_rev_budget_index).itd_revenue -
						 l_overview_type(l_cost_budget_index).itd_burdened_cost
                         )) / (l_overview_type(l_rev_budget_index).itd_revenue -
						 l_overview_type(l_cost_budget_index).itd_burdened_cost);
        ELSE
           l_itd_value(i):=NULL;
        END IF;

	    IF (NVL(l_overview_type(l_cost_budget_index).ac_burdened_cost,0) - NVL(l_overview_type(l_rev_budget_index).ac_revenue,0)) <>0 THEN
           l_ac_value(i):= 100*((l_overview_type(l_rev_forecast_index).ac_revenue
						 - l_overview_type(l_cost_forecast_index).ac_burdened_cost) -
                         (l_overview_type(l_rev_budget_index).ac_revenue -
						 l_overview_type(l_cost_budget_index).ac_burdened_cost
                         )) / (l_overview_type(l_rev_budget_index).ac_revenue -
						 l_overview_type(l_cost_budget_index).ac_burdened_cost);
        ELSE
           l_ac_value(i):=NULL;
        END IF;

	    IF (NVL(l_overview_type(l_cost_budget_index).prp_burdened_cost,0) - NVL(l_overview_type(l_rev_budget_index).prp_revenue,0)) <>0 THEN
           l_prp_value(i):= 100*((l_overview_type(l_rev_forecast_index).prp_revenue
						 - l_overview_type(l_cost_forecast_index).prp_burdened_cost) -
                         (l_overview_type(l_rev_budget_index).prp_revenue -
						 l_overview_type(l_cost_budget_index).prp_burdened_cost
                         )) / (l_overview_type(l_rev_budget_index).prp_revenue -
						 l_overview_type(l_cost_budget_index).prp_burdened_cost);
        ELSE
           l_prp_value(i):=NULL;
        END IF;


      ELSIF  p_measure_set_code(i) = 'PPF_MSR_FRVP' AND bitand(l_check_plan_versions, g_RevBudget_RevFcst ) = g_RevBudget_RevFcst  THEN
        --
        -- Forecast Revenue variance Percent=
        --      (Forecast Revenue - Current Budget Revenue)/Current Budget Revenue)
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_rev_budget_index).ptd_revenue <> 0 THEN
            l_ptd_value(i):= 100*(l_overview_type(l_rev_forecast_index).ptd_revenue -
                                    l_overview_type(l_rev_budget_index).ptd_revenue) /
                                    l_overview_type(l_rev_budget_index).ptd_revenue;
        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget_index).qtd_revenue <> 0 THEN
            l_qtd_value(i):= 100*(l_overview_type(l_rev_forecast_index).qtd_revenue -
                                    l_overview_type(l_rev_budget_index).qtd_revenue) /
                                    l_overview_type(l_rev_budget_index).qtd_revenue;
        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget_index).ytd_revenue <> 0 THEN
            l_ytd_value(i):= 100*(l_overview_type(l_rev_forecast_index).ytd_revenue -
                                    l_overview_type(l_rev_budget_index).ytd_revenue) /
                                    l_overview_type(l_rev_budget_index).ytd_revenue;
        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget_index).itd_revenue <> 0 THEN
            l_itd_value(i):= 100*(l_overview_type(l_rev_forecast_index).itd_revenue -
                                    l_overview_type(l_rev_budget_index).itd_revenue) /
                                    l_overview_type(l_rev_budget_index).itd_revenue;
        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget_index).ac_revenue <> 0 THEN
            l_ac_value(i):= 100*(l_overview_type(l_rev_forecast_index).ac_revenue -
                                    l_overview_type(l_rev_budget_index).ac_revenue) /
                                    l_overview_type(l_rev_budget_index).ac_revenue;
        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_rev_budget_index).prp_revenue <> 0 THEN
            l_prp_value(i):= 100*(l_overview_type(l_rev_forecast_index).prp_revenue -
                                    l_overview_type(l_rev_budget_index).prp_revenue) /
                                    l_overview_type(l_rev_budget_index).prp_revenue;
        ELSE
            l_prp_value(i):= NULL;
        END IF;



      ELSIF  p_measure_set_code(i) = 'PPF_MSR_CBCVPOB' AND bitand(l_check_plan_versions, g_CstOrigCstBudget ) = g_CstOrigCstBudget  THEN
        --
        -- Current Budget Cost variance Percent from Original Budget:
        --      (Current Budget Cost - Original Budget Cost)/Original Budget Cost)
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_orig_cost_budget_index).ptd_burdened_cost <> 0 THEN
            l_ptd_value(i):= 100*(l_overview_type(l_cost_budget_index).ptd_burdened_cost -
                                    l_overview_type(l_orig_cost_budget_index).ptd_burdened_cost) /
                                    l_overview_type(l_orig_cost_budget_index).ptd_burdened_cost;

        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_cost_budget_index).qtd_burdened_cost <> 0 THEN
            l_qtd_value(i):= 100*(l_overview_type(l_cost_budget_index).qtd_burdened_cost -
                                    l_overview_type(l_orig_cost_budget_index).qtd_burdened_cost) /
                                    l_overview_type(l_orig_cost_budget_index).qtd_burdened_cost;

        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_cost_budget_index).ytd_burdened_cost <> 0 THEN
            l_ytd_value(i):= 100*(l_overview_type(l_cost_budget_index).ytd_burdened_cost -
                                    l_overview_type(l_orig_cost_budget_index).ytd_burdened_cost) /
                                    l_overview_type(l_orig_cost_budget_index).ytd_burdened_cost;

        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_cost_budget_index).itd_burdened_cost <> 0 THEN
            l_itd_value(i):= 100*(l_overview_type(l_cost_budget_index).itd_burdened_cost -
                                    l_overview_type(l_orig_cost_budget_index).itd_burdened_cost) /
                                    l_overview_type(l_orig_cost_budget_index).itd_burdened_cost;

        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_cost_budget_index).ac_burdened_cost <> 0 THEN
            l_ac_value(i):= 100*(l_overview_type(l_cost_budget_index).ac_burdened_cost -
                                    l_overview_type(l_orig_cost_budget_index).ac_burdened_cost) /
                                    l_overview_type(l_orig_cost_budget_index).ac_burdened_cost;

        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_cost_budget_index).prp_burdened_cost <> 0 THEN
            l_prp_value(i):= 100*(l_overview_type(l_cost_budget_index).prp_burdened_cost -
                                    l_overview_type(l_orig_cost_budget_index).prp_burdened_cost) /
                                    l_overview_type(l_orig_cost_budget_index).prp_burdened_cost;

        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF  p_measure_set_code(i) = 'PPF_MSR_CBRVPOB' AND bitand(l_check_plan_versions, g_RevBudgetOrigbudget ) = g_RevBudgetOrigbudget THEN
        --
        -- Current budget Revenue variance Percent From Original Budget
        --      (Current Budget Revenue - Original Budget Revenue)/Original Budget Revenue)
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_orig_rev_budget_index).ptd_revenue <> 0 THEN
            l_ptd_value(i):= 100*(l_overview_type(l_rev_budget_index).ptd_revenue -
                                    l_overview_type(l_orig_rev_budget_index).ptd_revenue) /
                                    l_overview_type(l_orig_rev_budget_index).ptd_revenue;

        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_rev_budget_index).qtd_revenue <> 0 THEN
            l_qtd_value(i):= 100*(l_overview_type(l_rev_budget_index).qtd_revenue -
                                    l_overview_type(l_orig_rev_budget_index).qtd_revenue) /
                                    l_overview_type(l_orig_rev_budget_index).qtd_revenue;

        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_rev_budget_index).ytd_revenue <> 0 THEN
            l_ytd_value(i):= 100*(l_overview_type(l_rev_budget_index).ytd_revenue -
                                    l_overview_type(l_orig_rev_budget_index).ytd_revenue) /
                                    l_overview_type(l_orig_rev_budget_index).ytd_revenue;

        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_rev_budget_index).itd_revenue <> 0 THEN
            l_itd_value(i):= 100*(l_overview_type(l_rev_budget_index).itd_revenue -
                                    l_overview_type(l_orig_rev_budget_index).itd_revenue) /
                                    l_overview_type(l_orig_rev_budget_index).itd_revenue;

        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_rev_budget_index).ac_revenue <> 0 THEN
            l_ac_value(i):= 100*(l_overview_type(l_rev_budget_index).ac_revenue -
                                    l_overview_type(l_orig_rev_budget_index).ac_revenue) /
                                    l_overview_type(l_orig_rev_budget_index).ac_revenue;

        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_orig_rev_budget_index).prp_revenue <> 0 THEN
            l_prp_value(i):= 100*(l_overview_type(l_rev_budget_index).prp_revenue -
                                    l_overview_type(l_orig_rev_budget_index).prp_revenue) /
                                    l_overview_type(l_orig_rev_budget_index).prp_revenue;

        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_ERC' AND bitand(l_check_plan_versions, g_Actual_CstFcst) = g_Actual_CstFcst THEN
        --
        -- E.T.C. Raw Cost=
        --      forecast raw cost - actual raw cost
        --
        x_measure_type(i) := g_CurrencyType;

/*        l_ptd_value(i):= NULL;--(l_overview_type(l_cost_forecast_index).ptd_raw_cost - l_overview_type(l_actual_index).ptd_raw_cost) / l_factor_by;

        l_qtd_value(i):= NULL; --(l_overview_type(l_cost_forecast_index).qtd_raw_cost - l_overview_type(l_actual_index).qtd_raw_cost) / l_factor_by;

        l_ytd_value(i):= NULL; --(l_overview_type(l_cost_forecast_index).ytd_raw_cost - l_overview_type(l_actual_index).ytd_raw_cost) / l_factor_by;
*/
        l_itd_value(i):=(l_overview_type(l_cost_forecast_index).ac_raw_cost - NVL(l_overview_type(l_actual_index).itd_raw_cost,0)) / l_factor_by;

		IF l_itd_value(i) < 0 THEN
		   l_itd_value(i) := 0;
		END IF;


/*        l_ac_value(i):=(l_overview_type(l_cost_forecast_index).ac_raw_cost - l_overview_type(l_actual_index).ac_raw_cost) / l_factor_by;

        l_prp_value(i):= NULL; --(l_overview_type(l_cost_forecast_index).prp_raw_cost - l_overview_type(l_actual_index).prp_raw_cost) / l_factor_by;
*/
      ELSIF p_measure_set_code(i) = 'PPF_MSR_ER' AND bitand(l_check_plan_versions, g_Actual_RevFcst) = g_Actual_RevFcst THEN
        --
        -- E.T.C. Revenue=
        --      forecast revenue - actual revenue
        --
        x_measure_type(i) := g_CurrencyType;

/*        l_ptd_value(i):= NULL; --(l_overview_type(l_rev_forecast_index).ptd_revenue - l_overview_type(l_actual_index).ptd_revenue) / l_factor_by;

        l_qtd_value(i):= NULL; --(l_overview_type(l_rev_forecast_index).qtd_revenue - l_overview_type(l_actual_index).qtd_revenue) / l_factor_by;

        l_ytd_value(i):= NULL; --(l_overview_type(l_rev_forecast_index).ytd_revenue - l_overview_type(l_actual_index).ytd_revenue) / l_factor_by;
*/
        l_itd_value(i):=(l_overview_type(l_rev_forecast_index).ac_revenue - NVL(l_overview_type(l_actual_index).itd_revenue,0)) / l_factor_by;

		IF l_itd_value(i) < 0 THEN
		   l_itd_value(i) := 0;
		END IF;

/*
        l_ac_value(i):=(l_overview_type(l_rev_forecast_index).ac_revenue - l_overview_type(l_actual_index).ac_revenue) / l_factor_by;

        l_prp_value(i):= NULL; --(l_overview_type(l_rev_forecast_index).prp_revenue - l_overview_type(l_actual_index).prp_revenue) / l_factor_by;
*/
      ELSIF p_measure_set_code(i) = 'PPF_MSR_OBOC' AND bitand(l_check_plan_versions, g_OrigCstBudget_is_present) = g_OrigCstBudget_is_present THEN
        -- Original Budget Raw Cost
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_orig_cost_budget_index).ptd_raw_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_orig_cost_budget_index).qtd_raw_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_orig_cost_budget_index).ytd_raw_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_orig_cost_budget_index).itd_raw_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_orig_cost_budget_index).ac_raw_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_orig_cost_budget_index).prp_raw_cost / l_factor_by;

      ELSIF  p_measure_set_code(i) = 'PPF_MSR_PEVP' AND bitand(l_check_plan_versions, g_Actual_CstBudget) = g_Actual_CstBudget THEN
        --
        --  People Effort variance Percent=
        --      (Actual People Effort - Current Budget People Effort)/Current Budget People Effort)
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_cost_budget_index).ptd_labor_hrs <> 0 THEN
            l_ptd_value(i):= 100*(l_overview_type(l_actual_index).ptd_labor_hrs -
                                    l_overview_type(l_cost_budget_index).ptd_labor_hrs) /
                                    l_overview_type(l_cost_budget_index).ptd_labor_hrs;

        ELSE
            l_ptd_value(i):= NULL;
        END IF;


        IF l_overview_type(l_cost_budget_index).qtd_labor_hrs <> 0 THEN
            l_qtd_value(i):= 100*(l_overview_type(l_actual_index).qtd_labor_hrs -
                                    l_overview_type(l_cost_budget_index).qtd_labor_hrs) /
                                    l_overview_type(l_cost_budget_index).qtd_labor_hrs;

        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ytd_labor_hrs <> 0 THEN
            l_ytd_value(i):= 100*(l_overview_type(l_actual_index).ytd_labor_hrs -
                                    l_overview_type(l_cost_budget_index).ytd_labor_hrs) /
                                    l_overview_type(l_cost_budget_index).ytd_labor_hrs;

        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).itd_labor_hrs <> 0 THEN
            l_itd_value(i):= 100*(l_overview_type(l_actual_index).itd_labor_hrs -
                                    l_overview_type(l_cost_budget_index).itd_labor_hrs) /
                                    l_overview_type(l_cost_budget_index).itd_labor_hrs;

        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ac_labor_hrs <> 0 THEN
            l_ac_value(i):= 100*(l_overview_type(l_actual_index).ac_labor_hrs -
                                    l_overview_type(l_cost_budget_index).ac_labor_hrs) /
                                    l_overview_type(l_cost_budget_index).ac_labor_hrs;

        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).prp_labor_hrs <> 0 THEN
            l_prp_value(i):= 100*(l_overview_type(l_actual_index).prp_labor_hrs -
                                    l_overview_type(l_cost_budget_index).prp_labor_hrs) /
                                    l_overview_type(l_cost_budget_index).prp_labor_hrs;

        ELSE
            l_prp_value(i):= NULL;
        END IF;


      ELSIF  p_measure_set_code(i) = 'PPF_MSR_EEVP' AND bitand(l_check_plan_versions, g_Actual_CstBudget) = g_Actual_CstBudget THEN
        --
        --  Equipment Effort variance Percent=
        --      (Actual Equipment Effort - Current Budget Equipment Effort)/Current Budget Equipment Effort)
        --
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_cost_budget_index).ptd_equipment_hrs <> 0 THEN
            l_ptd_value(i):= 100*(l_overview_type(l_actual_index).ptd_equipment_hrs -
                                    l_overview_type(l_cost_budget_index).ptd_equipment_hrs) /
                                    l_overview_type(l_cost_budget_index).ptd_equipment_hrs;

        ELSE
            l_ptd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).qtd_equipment_hrs <> 0 THEN
            l_qtd_value(i):= 100*(l_overview_type(l_actual_index).qtd_equipment_hrs -
                                    l_overview_type(l_cost_budget_index).qtd_equipment_hrs) /
                                    l_overview_type(l_cost_budget_index).qtd_equipment_hrs;

        ELSE
            l_qtd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ytd_equipment_hrs <> 0 THEN
            l_ytd_value(i):= 100*(l_overview_type(l_actual_index).ytd_equipment_hrs -
                                    l_overview_type(l_cost_budget_index).ytd_equipment_hrs) /
                                    l_overview_type(l_cost_budget_index).ytd_equipment_hrs;

        ELSE
            l_ytd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).itd_equipment_hrs <> 0 THEN
            l_itd_value(i):= 100*(l_overview_type(l_actual_index).itd_equipment_hrs -
                                    l_overview_type(l_cost_budget_index).itd_equipment_hrs) /
                                    l_overview_type(l_cost_budget_index).itd_equipment_hrs;

        ELSE
            l_itd_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).ac_equipment_hrs <> 0 THEN
            l_ac_value(i):= 100*(l_overview_type(l_actual_index).ac_equipment_hrs -
                                    l_overview_type(l_cost_budget_index).ac_equipment_hrs) /
                                    l_overview_type(l_cost_budget_index).ac_equipment_hrs;

        ELSE
            l_ac_value(i):= NULL;
        END IF;

        IF l_overview_type(l_cost_budget_index).prp_equipment_hrs <> 0 THEN
            l_prp_value(i):= 100*(l_overview_type(l_actual_index).prp_equipment_hrs -
                                    l_overview_type(l_cost_budget_index).prp_equipment_hrs) /
                                    l_overview_type(l_cost_budget_index).prp_equipment_hrs;

        ELSE
            l_prp_value(i):= NULL;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_EBC' AND bitand(l_check_plan_versions, g_Actual_is_present  ) = g_Actual_is_present   THEN
        --
        -- E.T.C. Raw Cost=
        --      forecast raw cost - actual raw cost
        --
        x_measure_type(i) := g_CurrencyType;

        l_ptd_value(i):=l_overview_type(l_actual_index).ptd_equipment_brdn_cost / l_factor_by;

        l_qtd_value(i):=l_overview_type(l_actual_index).qtd_equipment_brdn_cost / l_factor_by;

        l_ytd_value(i):=l_overview_type(l_actual_index).ytd_equipment_brdn_cost / l_factor_by;

        l_itd_value(i):=l_overview_type(l_actual_index).itd_equipment_brdn_cost / l_factor_by;

        l_ac_value(i):=l_overview_type(l_actual_index).ac_equipment_brdn_cost / l_factor_by;

        l_prp_value(i):=l_overview_type(l_actual_index).prp_equipment_brdn_cost / l_factor_by;
		/* Modified the following measure set code from PPF_MSR_CFEVPF to PPF_MSR_CFEFPF for bug 6961599 */
      ELSIF p_measure_set_code(i) = 'PPF_MSR_CFEFPF' AND bitand(l_check_plan_versions, g_Cst_FcstPriorfcst   ) = g_Cst_FcstPriorfcst    THEN
        --
        -- Current Forecast Effort Variance from Prior Forecast
        --      Current Forecast Effort - Prior Forecast
        --
        x_measure_type(i) := g_HoursType;

        l_ptd_value(i):=((l_overview_type(l_cost_forecast_index).ptd_labor_hrs+l_overview_type(l_cost_forecast_index).ptd_equipment_hrs)
								-(l_overview_type(l_prior_cost_forecast_index).ptd_labor_hrs+l_overview_type(l_prior_cost_forecast_index).ptd_equipment_hrs)) / l_effort_UOM;

        l_qtd_value(i):=((l_overview_type(l_cost_forecast_index).qtd_labor_hrs+l_overview_type(l_cost_forecast_index).qtd_equipment_hrs)
								-(l_overview_type(l_prior_cost_forecast_index).qtd_labor_hrs+l_overview_type(l_prior_cost_forecast_index).qtd_equipment_hrs)) / l_effort_UOM;

        l_ytd_value(i):=((l_overview_type(l_cost_forecast_index).ytd_labor_hrs+l_overview_type(l_cost_forecast_index).ytd_equipment_hrs)
								-(l_overview_type(l_prior_cost_forecast_index).ytd_labor_hrs+l_overview_type(l_prior_cost_forecast_index).ytd_equipment_hrs)) / l_effort_UOM;

        l_itd_value(i):=((l_overview_type(l_cost_forecast_index).itd_labor_hrs+l_overview_type(l_cost_forecast_index).itd_equipment_hrs)
								-(l_overview_type(l_prior_cost_forecast_index).itd_labor_hrs+l_overview_type(l_prior_cost_forecast_index).itd_equipment_hrs)) / l_effort_UOM;

        l_ac_value(i):=((l_overview_type(l_cost_forecast_index).ac_labor_hrs+l_overview_type(l_cost_forecast_index).ac_equipment_hrs)
								-(l_overview_type(l_prior_cost_forecast_index).ac_labor_hrs+l_overview_type(l_prior_cost_forecast_index).ac_equipment_hrs)) / l_effort_UOM;

        l_prp_value(i):=((l_overview_type(l_cost_forecast_index).prp_labor_hrs+l_overview_type(l_cost_forecast_index).prp_equipment_hrs)
								-(l_overview_type(l_prior_cost_forecast_index).prp_labor_hrs+l_overview_type(l_prior_cost_forecast_index).prp_equipment_hrs)) / l_effort_UOM;


      ELSIF p_measure_set_code(i) = 'PPF_MSR_NID' THEN
        --
		-- Next invoice date
        --
        x_measure_type(i) := g_OtherType;

		IF (l_contract_proj_mask = 1) AND (pPrgRollup = 'N') THEN

	/*        l_ptd_value(i):= l_next_invoice_date;

	        l_qtd_value(i):= l_next_invoice_date;

	        l_ytd_value(i):= l_next_invoice_date;
	*/
	        l_itd_value(i):= l_next_invoice_date;

	        l_ac_value(i):= l_next_invoice_date;

	--        l_prp_value(i):= l_next_invoice_date;
	    END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_BEHP' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- billable equipment hours % = billable equipment hours / total equipment hrs
        x_measure_type(i) := g_PercentType;

        IF l_overview_type(l_actual_index).ptd_equipment_hrs <> 0 THEN
          l_ptd_value(i):=100 * l_overview_type(l_actual_index).ptd_bill_equipment_hrs /
                          l_overview_type(l_actual_index).ptd_equipment_hrs;
        END IF;

        IF l_overview_type(l_actual_index).qtd_equipment_hrs <> 0 THEN
          l_qtd_value(i):=100 * l_overview_type(l_actual_index).qtd_bill_equipment_hrs /
                          l_overview_type(l_actual_index).qtd_equipment_hrs;
        END IF;

        IF l_overview_type(l_actual_index).ytd_equipment_hrs <> 0 THEN
          l_ytd_value(i):=100 * l_overview_type(l_actual_index).ytd_bill_equipment_hrs /
                          l_overview_type(l_actual_index).ytd_equipment_hrs;
        END IF;

        IF l_overview_type(l_actual_index).itd_equipment_hrs <> 0 THEN
          l_itd_value(i):=100 * l_overview_type(l_actual_index).itd_bill_equipment_hrs /
                          l_overview_type(l_actual_index).itd_equipment_hrs;
        END IF;

        IF l_overview_type(l_actual_index).ac_equipment_hrs <> 0 THEN
          l_ac_value(i):=100 * l_overview_type(l_actual_index).ac_bill_equipment_hrs /
                          l_overview_type(l_actual_index).ac_equipment_hrs;
        END IF;

        IF l_overview_type(l_actual_index).prp_equipment_hrs <> 0 THEN
          l_prp_value(i):=100 * l_overview_type(l_actual_index).prp_bill_equipment_hrs /
                          l_overview_type(l_actual_index).prp_equipment_hrs;
        END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_NBCPOTC' AND bitand(l_check_plan_versions, g_Actual_is_present) = g_Actual_is_present THEN
        -- Nonbillable Cost % of total cost= Nonbillable Cost / Total Cost
        x_measure_type(i) := g_PercentType;

		IF l_contract_proj_mask = 1 THEN
	        IF l_overview_type(l_actual_index).ptd_burdened_cost <> 0 THEN
	          l_ptd_value(i):=100 * (l_overview_type(l_actual_index).ptd_burdened_cost - l_overview_type(l_actual_index).ptd_bill_burdened_cost -
	                          NVL(l_overview_type(l_actual_index).ptd_capitalizable_brdn_cost,0)) /
	                          l_overview_type(l_actual_index).ptd_burdened_cost;


	          l_ptd_value(i):=TO_NUMBER(l_ptd_value(i));
	        END IF;

	        IF l_overview_type(l_actual_index).qtd_burdened_cost <> 0 THEN
	          l_qtd_value(i):=100 * (l_overview_type(l_actual_index).qtd_burdened_cost - l_overview_type(l_actual_index).qtd_bill_burdened_cost -
	                          NVL(l_overview_type(l_actual_index).qtd_capitalizable_brdn_cost,0)) /
	                          l_overview_type(l_actual_index).qtd_burdened_cost;
	        END IF;

	        IF l_overview_type(l_actual_index).ytd_burdened_cost <> 0 THEN
	          l_ytd_value(i):=100 * (l_overview_type(l_actual_index).ytd_burdened_cost - l_overview_type(l_actual_index).ytd_bill_burdened_cost -
	                          NVL(l_overview_type(l_actual_index).ytd_capitalizable_brdn_cost,0)) /
	                          l_overview_type(l_actual_index).ytd_burdened_cost;
	        END IF;

	        IF l_overview_type(l_actual_index).itd_burdened_cost <> 0 THEN
	          l_itd_value(i):=100 * (l_overview_type(l_actual_index).itd_burdened_cost - l_overview_type(l_actual_index).itd_bill_burdened_cost -
	                          NVL(l_overview_type(l_actual_index).itd_capitalizable_brdn_cost,0)) /
	                          l_overview_type(l_actual_index).itd_burdened_cost;
	        END IF;

	        IF l_overview_type(l_actual_index).ac_burdened_cost <> 0 THEN
	          l_ac_value(i):=100 * (l_overview_type(l_actual_index).ac_burdened_cost - l_overview_type(l_actual_index).ac_bill_burdened_cost -
	                          NVL(l_overview_type(l_actual_index).ac_capitalizable_brdn_cost,0)) /
	                          l_overview_type(l_actual_index).ac_burdened_cost;
	        END IF;

	        IF l_overview_type(l_actual_index).prp_burdened_cost <> 0 THEN
	          l_prp_value(i):=100 * (l_overview_type(l_actual_index).prp_burdened_cost - l_overview_type(l_actual_index).prp_bill_burdened_cost -
	                          NVL(l_overview_type(l_actual_index).prp_capitalizable_brdn_cost,0)) /
	                          l_overview_type(l_actual_index).prp_burdened_cost;
	        END IF;
		END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_TCPI' AND bitand(l_check_plan_versions, g_Actual_CstBudget) = g_Actual_CstBudget THEN
        -- To Completion Percent Index
        x_measure_type(i) := g_IndexType;

		IF (NVL(l_overview_type(l_cost_budget_index).ac_burdened_cost,0) - NVL(l_overview_type(l_actual_index).itd_burdened_cost,0)) = 0 THEN
		   l_itd_value(i) := NULL;
		ELSE
		   l_itd_value(i) := (l_overview_type(l_cost_budget_index).ac_burdened_cost - NVL(l_overview_type(l_cost_budget_index).ac_burdened_cost,0) * l_completed_percentage)/
		   (l_overview_type(l_cost_budget_index).ac_burdened_cost - NVL(l_overview_type(l_actual_index).itd_burdened_cost,0) );
		END IF;

      ELSIF p_measure_set_code(i) = 'PPF_MSR_ADR' AND bitand(l_check_plan_versions, g_Actual_CstBudget) = g_Actual_CstBudget THEN
        -- Average Daily Rate
        x_measure_type(i) := g_IndexType;

		IF (NVL(l_overview_type(l_actual_index).ptd_equipment_hrs,0)+NVL(l_overview_type(l_actual_index).ptd_labor_hrs,0)) <> 0 THEN
		   l_ptd_value(i) := l_hours_per_day * l_overview_type(l_actual_index).ptd_revenue / (NVL(l_overview_type(l_actual_index).ptd_equipment_hrs,0)+NVL(l_overview_type(l_actual_index).ptd_labor_hrs,0));
		END IF;

		IF (NVL(l_overview_type(l_actual_index).itd_equipment_hrs,0)+NVL(l_overview_type(l_actual_index).itd_labor_hrs,0)) <> 0 THEN
		   l_itd_value(i) := l_hours_per_day * l_overview_type(l_actual_index).itd_revenue / (NVL(l_overview_type(l_actual_index).itd_equipment_hrs,0)+NVL(l_overview_type(l_actual_index).itd_labor_hrs,0));
		END IF;
		--Added for fix of Bug 7150631
		IF (NVL(l_overview_type(l_actual_index).qtd_equipment_hrs,0)+NVL(l_overview_type(l_actual_index).qtd_labor_hrs,0)) <> 0 THEN
		   l_qtd_value(i) := l_hours_per_day * l_overview_type(l_actual_index).qtd_revenue / (NVL(l_overview_type(l_actual_index).qtd_equipment_hrs,0)+NVL(l_overview_type(l_actual_index).qtd_labor_hrs,0));
		END IF;

		IF (NVL(l_overview_type(l_actual_index).ytd_equipment_hrs,0)+NVL(l_overview_type(l_actual_index).ytd_labor_hrs,0)) <> 0 THEN
		   l_ytd_value(i) := l_hours_per_day * l_overview_type(l_actual_index).ytd_revenue / (NVL(l_overview_type(l_actual_index).ytd_equipment_hrs,0)+NVL(l_overview_type(l_actual_index).ytd_labor_hrs,0));
		END IF;

		IF (NVL(l_overview_type(l_actual_index).ac_equipment_hrs,0)+NVL(l_overview_type(l_actual_index).ac_labor_hrs,0)) <> 0 THEN
		   l_ac_value(i) := l_hours_per_day * l_overview_type(l_actual_index).ac_revenue / (NVL(l_overview_type(l_actual_index).ac_equipment_hrs,0)+NVL(l_overview_type(l_actual_index).ac_labor_hrs,0));
		END IF;
		--End of fix for Bug 7150631

      ELSIF SUBSTR(p_measure_set_code(i),0,15) = 'PPF_MSR_FP_CUST' THEN

	    l_cust_measure_number := TO_NUMBER(SUBSTR(p_measure_set_code(i),16,2));

  	    x_measure_type(i) := l_fp_cus_meas_formats(l_cust_measure_number);

        l_ptd_value(i):=l_fp_custom_measures_ptd(l_cust_measure_number);

        l_qtd_value(i):=l_fp_custom_measures_qtd(l_cust_measure_number);

        l_ytd_value(i):=l_fp_custom_measures_ytd(l_cust_measure_number);

        l_itd_value(i):=l_fp_custom_measures_itd(l_cust_measure_number);

        l_ac_value(i):=l_fp_custom_measures_ac(l_cust_measure_number);

        l_prp_value(i):=l_fp_custom_measures_prp(l_cust_measure_number);

      ELSIF SUBSTR(p_measure_set_code(i),0,15) = 'PPF_MSR_AC_CUST' THEN

	    l_cust_measure_number := TO_NUMBER(SUBSTR(p_measure_set_code(i),16,2));

  	    x_measure_type(i) := l_ac_cus_meas_formats(l_cust_measure_number);

        l_ptd_value(i):=l_ac_custom_measures_ptd(l_cust_measure_number);

        l_qtd_value(i):=l_ac_custom_measures_qtd(l_cust_measure_number);

        l_ytd_value(i):=l_ac_custom_measures_ytd(l_cust_measure_number);

        l_itd_value(i):=l_ac_custom_measures_itd(l_cust_measure_number);

        l_ac_value(i):=l_ac_custom_measures_ac(l_cust_measure_number);

        l_prp_value(i):=l_ac_custom_measures_prp(l_cust_measure_number);


      END IF;


    EXCEPTION WHEN OTHERS THEN

      l_sql_errm := SQLERRM();
      Pji_Rep_Util.Add_Message(
        p_app_short_name=>'PJI',
        p_msg_name=> 'PJI_REP_GENERIC_MSG',
        p_msg_type=>Pji_Rep_Util.G_RET_STS_WARNING,
        p_token1=>'PROC_NAME',
        p_token1_value=>'PJI_REP_MEASURE_UTIL; SQL Error during computation '||
          'of measure '||p_measure_set_code(i)||' : '|| l_sql_errm
      );

    END;

    -- do formatting for Currency measures
	IF pCallingType = g_Exception THEN
	  x_ptd_value(i):= l_ptd_value(i);
      x_qtd_value(i):= l_qtd_value(i);
      x_ytd_value(i):= l_ytd_value(i);
      x_itd_value(i):= l_itd_value(i);
      x_ac_value(i) := l_ac_value(i);
      x_prp_value(i):= l_prp_value(i);
    ELSIF x_measure_type(i) = g_CurrencyType THEN
/*      IF SIGN(l_ptd_value(i)) < 0 THEN
        s := '-';
      ELSE
        s := '';
      END IF;
      x_ptd_value(i) := s||TO_CHAR(ABS(l_ptd_value(i)),Fnd_Currency.get_format_mask(pCurrencyCode,g_currency_size));

      s := '';
*/
   	  IF l_ptd_value(i) IS NOT NULL THEN
	   	  x_ptd_value(i) := TO_CHAR(TO_NUMBER(l_ptd_value(i)),Fnd_Currency.get_format_mask(pCurrencyCode,g_currency_size));
	  END IF;
     -- Changed from x_qtd_value to l_qtd_value for bug 3954603
/*      IF SIGN(l_qtd_value(i)) < 0 THEN
        s := '-';
      ELSE
        s := '';
      END IF;
      x_qtd_value(i) := s||TO_CHAR(ABS(l_qtd_value(i)),Fnd_Currency.get_format_mask(pCurrencyCode,g_currency_size));
*/
   	  IF l_qtd_value(i) IS NOT NULL THEN
	  	 x_qtd_value(i) := TO_CHAR(TO_NUMBER(l_qtd_value(i)),Fnd_Currency.get_format_mask(pCurrencyCode,g_currency_size));
	  END IF;
      -- Changed from x_ytd_value to l_ytd_value for bug 3954603
/*      IF SIGN(l_ytd_value(i)) < 0 THEN
        s := '-';
      ELSE
        s := '';
      END IF;
      x_ytd_value(i) := s||TO_CHAR(ABS(l_ytd_value(i)),Fnd_Currency.get_format_mask(pCurrencyCode,g_currency_size));
*/
   	  IF l_ytd_value(i) IS NOT NULL THEN
	  	 x_ytd_value(i) := TO_CHAR(TO_NUMBER(l_ytd_value(i)),Fnd_Currency.get_format_mask(pCurrencyCode,g_currency_size));
	  END IF;
      -- Changed from x_itd_value to l_itd_value for bug 3954603
/*      IF SIGN(l_itd_value(i)) < 0 THEN
        s := '-';
      ELSE
        s := '';
      END IF;
      x_itd_value(i) := s||TO_CHAR(ABS(l_itd_value(i)),Fnd_Currency.get_format_mask(pCurrencyCode,g_currency_size));
*/
   	  IF l_itd_value(i) IS NOT NULL THEN
	     x_itd_value(i) := TO_CHAR(TO_NUMBER(l_itd_value(i)),Fnd_Currency.get_format_mask(pCurrencyCode,g_currency_size));
	  END IF;
      -- Changed from x_ac_value to l_ac_value for bug 3954603
/*      IF SIGN(l_ac_value(i)) < 0 THEN
        s := '-';
      ELSE
        s := '';
      END IF;
      x_ac_value(i)  := s||TO_CHAR(ABS(l_ac_value(i)), Fnd_Currency.get_format_mask(pCurrencyCode,g_currency_size));
*/
   	  IF l_ac_value(i) IS NOT NULL THEN
	    x_ac_value(i)  := TO_CHAR(TO_NUMBER(l_ac_value(i)), Fnd_Currency.get_format_mask(pCurrencyCode,g_currency_size));
	  END IF;
      -- Changed from x_prp_value to l_prp_value for bug 3954603
/*      IF SIGN(l_prp_value(i)) < 0 THEN
        s := '-';
      ELSE
        s := '';
      END IF;
      x_prp_value(i) := s||TO_CHAR(ABS(l_prp_value(i)),Fnd_Currency.get_format_mask(pCurrencyCode,g_currency_size));
*/
  	  IF l_prp_value(i) IS NOT NULL THEN
	     x_prp_value(i) := TO_CHAR(TO_NUMBER(l_prp_value(i)),Fnd_Currency.get_format_mask(pCurrencyCode,g_currency_size));
	  END IF;
    ELSIF x_measure_type(i) = g_PercentType THEN -- Formatting for Percent measures
         /*
          *  Removing concatenated '%' sign to make overview page consistent with other pages.
          *  This changes are done for bug 3936453
          */
	  IF l_ptd_value(i) IS NOT NULL THEN
	  	 x_ptd_value(i) := TO_CHAR(ROUND(l_ptd_value(i), g_PercentDecimalPlaces));
	  ELSE
	  	 x_ptd_value(i) := NULL;
	  END IF;

	  IF l_qtd_value(i) IS NOT NULL THEN
	  	 x_qtd_value(i) := TO_CHAR(ROUND(l_qtd_value(i), g_PercentDecimalPlaces));
	  ELSE
	  	 x_qtd_value(i) := NULL;
	  END IF;

	  IF l_ytd_value(i) IS NOT NULL THEN
	  	 x_ytd_value(i) := TO_CHAR(ROUND(l_ytd_value(i), g_PercentDecimalPlaces));
	  ELSE
	  	 x_ytd_value(i) := NULL;
	  END IF;

	  IF l_itd_value(i) IS NOT NULL THEN
	  	 x_itd_value(i) := TO_CHAR(ROUND(l_itd_value(i), g_PercentDecimalPlaces));
	  ELSE
	  	 x_itd_value(i) := NULL;
	  END IF;

	  IF l_ac_value(i) IS NOT NULL THEN
	  	 x_ac_value(i) := TO_CHAR(ROUND(l_ac_value(i), g_PercentDecimalPlaces));
	  ELSE
	  	 x_ac_value(i) := NULL;
	  END IF;

	  IF l_prp_value(i) IS NOT NULL THEN
	  	 x_prp_value(i) := TO_CHAR(ROUND(l_prp_value(i), g_PercentDecimalPlaces));
	  ELSE
	  	 x_prp_value(i) := NULL;
	  END IF;

    ELSIF x_measure_type(i) = g_IndexType THEN -- Formatting for Index measures

	  IF l_ptd_value(i) IS NOT NULL THEN
	  	 x_ptd_value(i):=TO_CHAR(ROUND(l_ptd_value(i), g_IndexDecimalPlaces));
	  ELSE
	  	 x_ptd_value(i) := NULL;
	  END IF;

	  IF l_qtd_value(i) IS NOT NULL THEN
	  	 x_qtd_value(i):=TO_CHAR(ROUND(l_qtd_value(i), g_IndexDecimalPlaces));
	  ELSE
	  	 x_qtd_value(i) := NULL;
	  END IF;

	  IF l_ytd_value(i) IS NOT NULL THEN
	     x_ytd_value(i):=TO_CHAR(ROUND(l_ytd_value(i), g_IndexDecimalPlaces));
	  ELSE
	  	 x_ytd_value(i) := NULL;
	  END IF;

	  IF l_itd_value(i) IS NOT NULL THEN
	  	 x_itd_value(i):=TO_CHAR(ROUND(l_itd_value(i), g_IndexDecimalPlaces));
	  ELSE
	  	 x_itd_value(i) := NULL;
	  END IF;

	  IF l_ac_value(i) IS NOT NULL THEN
	  	 x_ac_value(i) :=TO_CHAR(ROUND(l_ac_value(i) , g_IndexDecimalPlaces));
	  ELSE
	  	 x_ac_value(i) := NULL;
	  END IF;

	  IF l_prp_value(i) IS NOT NULL THEN
	     x_prp_value(i):=TO_CHAR(ROUND(l_prp_value(i), g_IndexDecimalPlaces));
	  ELSE
	  	 x_prp_value(i) := NULL;
	  END IF;

	ELSIF x_measure_type(i) = g_DaysType THEN

      x_ptd_value(i):= TO_CHAR(ROUND(l_ptd_value(i),0));
      x_qtd_value(i):= TO_CHAR(ROUND(l_qtd_value(i),0));
      x_ytd_value(i):= TO_CHAR(ROUND(l_ytd_value(i),0));
      x_itd_value(i):= TO_CHAR(ROUND(l_itd_value(i),0));
      x_ac_value(i) := TO_CHAR(ROUND(l_ac_value(i),0));
      x_prp_value(i):= TO_CHAR(ROUND(l_prp_value(i),0));
	ELSIF x_measure_type(i) = g_HoursType THEN
      x_ptd_value(i):= TO_CHAR(ROUND(l_ptd_value(i),5));
      x_qtd_value(i):= TO_CHAR(ROUND(l_qtd_value(i),5));
      x_ytd_value(i):= TO_CHAR(ROUND(l_ytd_value(i),5));
      x_itd_value(i):= TO_CHAR(ROUND(l_itd_value(i),5));
      x_ac_value(i) := TO_CHAR(ROUND(l_ac_value(i),5));
      x_prp_value(i):= TO_CHAR(ROUND(l_prp_value(i),5));
	ELSE
      x_ptd_value(i):= l_ptd_value(i);
      x_qtd_value(i):= l_qtd_value(i);
      x_ytd_value(i):= l_ytd_value(i);
      x_itd_value(i):= l_itd_value(i);
      x_ac_value(i) := l_ac_value(i);
      x_prp_value(i):= l_prp_value(i);

    END IF;

  END LOOP;

  IF g_debug_mode = 'Y' THEN
	  Pji_Utils.WRITE2LOG(
	    'PJI_REP_MEASURE_UTIL.retrieveData: reached end.',
	    TRUE, g_msg_level_proc_call
	  );
  END IF;

  COMMIT;

END retrieveData;

PROCEDURE Merge_Overview_Type
(
 p_source_index IN NUMBER
 ,p_source_table IN pji_rep_overview_type_tbl
 ,p_target_index IN NUMBER
 ,p_target_table IN OUT NOCOPY pji_rep_overview_type_tbl
)
IS
BEGIN

p_target_table(p_target_index).ptd_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_raw_cost 	,	p_source_table(p_source_index).ptd_raw_cost 	);
p_target_table(p_target_index).ptd_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_burdened_cost 	,	p_source_table(p_source_index).ptd_burdened_cost 	);
p_target_table(p_target_index).ptd_revenue 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_revenue 	,	p_source_table(p_source_index).ptd_revenue 	);
p_target_table(p_target_index).ptd_bill_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_bill_raw_cost 	,	p_source_table(p_source_index).ptd_bill_raw_cost 	);
p_target_table(p_target_index).ptd_bill_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_bill_burdened_cost 	,	p_source_table(p_source_index).ptd_bill_burdened_cost 	);
p_target_table(p_target_index).ptd_bill_equipment_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_bill_equipment_hrs 	,	p_source_table(p_source_index).ptd_bill_equipment_hrs 	);
p_target_table(p_target_index).ptd_bill_labor_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_bill_labor_raw_cost 	,	p_source_table(p_source_index).ptd_bill_labor_raw_cost 	);
p_target_table(p_target_index).ptd_bill_labor_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_bill_labor_burdened_cost 	,	p_source_table(p_source_index).ptd_bill_labor_burdened_cost 	);
p_target_table(p_target_index).ptd_bill_labor_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_bill_labor_hrs 	,	p_source_table(p_source_index).ptd_bill_labor_hrs 	);
p_target_table(p_target_index).ptd_capitalizable_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_capitalizable_raw_cost 	,	p_source_table(p_source_index).ptd_capitalizable_raw_cost 	);
p_target_table(p_target_index).ptd_capitalizable_brdn_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_capitalizable_brdn_cost 	,	p_source_table(p_source_index).ptd_capitalizable_brdn_cost 	);
p_target_table(p_target_index).ptd_equipment_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_equipment_hrs 	,	p_source_table(p_source_index).ptd_equipment_hrs 	);
p_target_table(p_target_index).ptd_equipment_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_equipment_raw_cost 	,	p_source_table(p_source_index).ptd_equipment_raw_cost 	);
p_target_table(p_target_index).ptd_equipment_brdn_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_equipment_brdn_cost 	,	p_source_table(p_source_index).ptd_equipment_brdn_cost 	);
p_target_table(p_target_index).ptd_labor_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_labor_raw_cost 	,	p_source_table(p_source_index).ptd_labor_raw_cost 	);
p_target_table(p_target_index).ptd_labor_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_labor_burdened_cost 	,	p_source_table(p_source_index).ptd_labor_burdened_cost 	);
p_target_table(p_target_index).ptd_labor_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_labor_hrs 	,	p_source_table(p_source_index).ptd_labor_hrs 	);
p_target_table(p_target_index).ptd_labor_revenue 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_labor_revenue 	,	p_source_table(p_source_index).ptd_labor_revenue 	);
p_target_table(p_target_index).ptd_unbilled_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_unbilled_cost 	,	p_source_table(p_source_index).ptd_unbilled_cost 	);
p_target_table(p_target_index).ptd_capitalized_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_capitalized_cost 	,	p_source_table(p_source_index).ptd_capitalized_cost 	);
p_target_table(p_target_index).ptd_sup_inv_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_sup_inv_committed_cost 	,	p_source_table(p_source_index).ptd_sup_inv_committed_cost 	);
p_target_table(p_target_index).ptd_po_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_po_committed_cost 	,	p_source_table(p_source_index).ptd_po_committed_cost 	);
p_target_table(p_target_index).ptd_pr_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_pr_committed_cost 	,	p_source_table(p_source_index).ptd_pr_committed_cost 	);
p_target_table(p_target_index).ptd_oth_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_oth_committed_cost 	,	p_source_table(p_source_index).ptd_oth_committed_cost 	);
p_target_table(p_target_index).qtd_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_raw_cost 	,	p_source_table(p_source_index).qtd_raw_cost 	);
p_target_table(p_target_index).qtd_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_burdened_cost 	,	p_source_table(p_source_index).qtd_burdened_cost 	);
p_target_table(p_target_index).qtd_revenue 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_revenue 	,	p_source_table(p_source_index).qtd_revenue 	);
p_target_table(p_target_index).qtd_bill_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_bill_raw_cost 	,	p_source_table(p_source_index).qtd_bill_raw_cost 	);
p_target_table(p_target_index).qtd_bill_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_bill_burdened_cost 	,	p_source_table(p_source_index).qtd_bill_burdened_cost 	);
p_target_table(p_target_index).qtd_bill_equipment_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_bill_equipment_hrs 	,	p_source_table(p_source_index).qtd_bill_equipment_hrs 	);
p_target_table(p_target_index).qtd_bill_labor_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_bill_labor_raw_cost 	,	p_source_table(p_source_index).qtd_bill_labor_raw_cost 	);
p_target_table(p_target_index).qtd_bill_labor_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_bill_labor_burdened_cost 	,	p_source_table(p_source_index).qtd_bill_labor_burdened_cost 	);
p_target_table(p_target_index).qtd_bill_labor_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_bill_labor_hrs 	,	p_source_table(p_source_index).qtd_bill_labor_hrs 	);
p_target_table(p_target_index).qtd_capitalizable_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_capitalizable_raw_cost 	,	p_source_table(p_source_index).qtd_capitalizable_raw_cost 	);
p_target_table(p_target_index).qtd_capitalizable_brdn_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_capitalizable_brdn_cost 	,	p_source_table(p_source_index).qtd_capitalizable_brdn_cost 	);
p_target_table(p_target_index).qtd_equipment_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_equipment_hrs 	,	p_source_table(p_source_index).qtd_equipment_hrs 	);
p_target_table(p_target_index).qtd_equipment_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_equipment_raw_cost 	,	p_source_table(p_source_index).qtd_equipment_raw_cost 	);
p_target_table(p_target_index).qtd_equipment_brdn_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_equipment_brdn_cost 	,	p_source_table(p_source_index).qtd_equipment_brdn_cost 	);
p_target_table(p_target_index).qtd_labor_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_labor_raw_cost 	,	p_source_table(p_source_index).qtd_labor_raw_cost 	);
p_target_table(p_target_index).qtd_labor_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_labor_burdened_cost 	,	p_source_table(p_source_index).qtd_labor_burdened_cost 	);
p_target_table(p_target_index).qtd_labor_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_labor_hrs 	,	p_source_table(p_source_index).qtd_labor_hrs 	);
p_target_table(p_target_index).qtd_labor_revenue 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_labor_revenue 	,	p_source_table(p_source_index).qtd_labor_revenue 	);
p_target_table(p_target_index).qtd_unbilled_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_unbilled_cost 	,	p_source_table(p_source_index).qtd_unbilled_cost 	);
p_target_table(p_target_index).qtd_capitalized_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_capitalized_cost 	,	p_source_table(p_source_index).qtd_capitalized_cost 	);
p_target_table(p_target_index).qtd_sup_inv_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_sup_inv_committed_cost 	,	p_source_table(p_source_index).qtd_sup_inv_committed_cost 	);
p_target_table(p_target_index).qtd_po_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_po_committed_cost 	,	p_source_table(p_source_index).qtd_po_committed_cost 	);
p_target_table(p_target_index).qtd_pr_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_pr_committed_cost 	,	p_source_table(p_source_index).qtd_pr_committed_cost 	);
p_target_table(p_target_index).qtd_oth_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_oth_committed_cost 	,	p_source_table(p_source_index).qtd_oth_committed_cost 	);
p_target_table(p_target_index).ytd_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_raw_cost 	,	p_source_table(p_source_index).ytd_raw_cost 	);
p_target_table(p_target_index).ytd_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_burdened_cost 	,	p_source_table(p_source_index).ytd_burdened_cost 	);
p_target_table(p_target_index).ytd_revenue 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_revenue 	,	p_source_table(p_source_index).ytd_revenue 	);
p_target_table(p_target_index).ytd_bill_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_bill_raw_cost 	,	p_source_table(p_source_index).ytd_bill_raw_cost 	);
p_target_table(p_target_index).ytd_bill_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_bill_burdened_cost 	,	p_source_table(p_source_index).ytd_bill_burdened_cost 	);
p_target_table(p_target_index).ytd_bill_equipment_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_bill_equipment_hrs 	,	p_source_table(p_source_index).ytd_bill_equipment_hrs 	);
p_target_table(p_target_index).ytd_bill_labor_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_bill_labor_raw_cost 	,	p_source_table(p_source_index).ytd_bill_labor_raw_cost 	);
p_target_table(p_target_index).ytd_bill_labor_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_bill_labor_burdened_cost 	,	p_source_table(p_source_index).ytd_bill_labor_burdened_cost 	);
p_target_table(p_target_index).ytd_bill_labor_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_bill_labor_hrs 	,	p_source_table(p_source_index).ytd_bill_labor_hrs 	);
p_target_table(p_target_index).ytd_capitalizable_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_capitalizable_raw_cost 	,	p_source_table(p_source_index).ytd_capitalizable_raw_cost 	);
p_target_table(p_target_index).ytd_capitalizable_brdn_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_capitalizable_brdn_cost 	,	p_source_table(p_source_index).ytd_capitalizable_brdn_cost 	);
p_target_table(p_target_index).ytd_equipment_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_equipment_hrs 	,	p_source_table(p_source_index).ytd_equipment_hrs 	);
p_target_table(p_target_index).ytd_equipment_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_equipment_raw_cost 	,	p_source_table(p_source_index).ytd_equipment_raw_cost 	);
p_target_table(p_target_index).ytd_equipment_brdn_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_equipment_brdn_cost 	,	p_source_table(p_source_index).ytd_equipment_brdn_cost 	);
p_target_table(p_target_index).ytd_labor_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_labor_raw_cost 	,	p_source_table(p_source_index).ytd_labor_raw_cost 	);
p_target_table(p_target_index).ytd_labor_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_labor_burdened_cost 	,	p_source_table(p_source_index).ytd_labor_burdened_cost 	);
p_target_table(p_target_index).ytd_labor_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_labor_hrs 	,	p_source_table(p_source_index).ytd_labor_hrs 	);
p_target_table(p_target_index).ytd_labor_revenue 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_labor_revenue 	,	p_source_table(p_source_index).ytd_labor_revenue 	);
p_target_table(p_target_index).ytd_unbilled_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_unbilled_cost 	,	p_source_table(p_source_index).ytd_unbilled_cost 	);
p_target_table(p_target_index).ytd_capitalized_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_capitalized_cost 	,	p_source_table(p_source_index).ytd_capitalized_cost 	);
p_target_table(p_target_index).ytd_sup_inv_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_sup_inv_committed_cost 	,	p_source_table(p_source_index).ytd_sup_inv_committed_cost 	);
p_target_table(p_target_index).ytd_po_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_po_committed_cost 	,	p_source_table(p_source_index).ytd_po_committed_cost 	);
p_target_table(p_target_index).ytd_pr_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_pr_committed_cost 	,	p_source_table(p_source_index).ytd_pr_committed_cost 	);
p_target_table(p_target_index).ytd_oth_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_oth_committed_cost 	,	p_source_table(p_source_index).ytd_oth_committed_cost 	);
p_target_table(p_target_index).itd_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_raw_cost 	,	p_source_table(p_source_index).itd_raw_cost 	);
p_target_table(p_target_index).itd_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_burdened_cost 	,	p_source_table(p_source_index).itd_burdened_cost 	);
p_target_table(p_target_index).itd_revenue 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_revenue 	,	p_source_table(p_source_index).itd_revenue 	);
p_target_table(p_target_index).itd_bill_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_bill_raw_cost 	,	p_source_table(p_source_index).itd_bill_raw_cost 	);
p_target_table(p_target_index).itd_bill_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_bill_burdened_cost 	,	p_source_table(p_source_index).itd_bill_burdened_cost 	);
p_target_table(p_target_index).itd_bill_equipment_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_bill_equipment_hrs 	,	p_source_table(p_source_index).itd_bill_equipment_hrs 	);
p_target_table(p_target_index).itd_bill_labor_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_bill_labor_raw_cost 	,	p_source_table(p_source_index).itd_bill_labor_raw_cost 	);
p_target_table(p_target_index).itd_bill_labor_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_bill_labor_burdened_cost 	,	p_source_table(p_source_index).itd_bill_labor_burdened_cost 	);
p_target_table(p_target_index).itd_bill_labor_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_bill_labor_hrs 	,	p_source_table(p_source_index).itd_bill_labor_hrs 	);
p_target_table(p_target_index).itd_capitalizable_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_capitalizable_raw_cost 	,	p_source_table(p_source_index).itd_capitalizable_raw_cost 	);
p_target_table(p_target_index).itd_capitalizable_brdn_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_capitalizable_brdn_cost 	,	p_source_table(p_source_index).itd_capitalizable_brdn_cost 	);
p_target_table(p_target_index).itd_equipment_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_equipment_hrs 	,	p_source_table(p_source_index).itd_equipment_hrs 	);
p_target_table(p_target_index).itd_equipment_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_equipment_raw_cost 	,	p_source_table(p_source_index).itd_equipment_raw_cost 	);
p_target_table(p_target_index).itd_equipment_brdn_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_equipment_brdn_cost 	,	p_source_table(p_source_index).itd_equipment_brdn_cost 	);
p_target_table(p_target_index).itd_labor_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_labor_raw_cost 	,	p_source_table(p_source_index).itd_labor_raw_cost 	);
p_target_table(p_target_index).itd_labor_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_labor_burdened_cost 	,	p_source_table(p_source_index).itd_labor_burdened_cost 	);
p_target_table(p_target_index).itd_labor_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_labor_hrs 	,	p_source_table(p_source_index).itd_labor_hrs 	);
p_target_table(p_target_index).itd_labor_revenue 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_labor_revenue 	,	p_source_table(p_source_index).itd_labor_revenue 	);
p_target_table(p_target_index).itd_unbilled_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_unbilled_cost 	,	p_source_table(p_source_index).itd_unbilled_cost 	);
p_target_table(p_target_index).itd_capitalized_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_capitalized_cost 	,	p_source_table(p_source_index).itd_capitalized_cost 	);
p_target_table(p_target_index).itd_sup_inv_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_sup_inv_committed_cost 	,	p_source_table(p_source_index).itd_sup_inv_committed_cost 	);
p_target_table(p_target_index).itd_po_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_po_committed_cost 	,	p_source_table(p_source_index).itd_po_committed_cost 	);
p_target_table(p_target_index).itd_pr_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_pr_committed_cost 	,	p_source_table(p_source_index).itd_pr_committed_cost 	);
p_target_table(p_target_index).itd_oth_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_oth_committed_cost 	,	p_source_table(p_source_index).itd_oth_committed_cost 	);
p_target_table(p_target_index).ac_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_raw_cost 	,	p_source_table(p_source_index).ac_raw_cost 	);
p_target_table(p_target_index).ac_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_burdened_cost 	,	p_source_table(p_source_index).ac_burdened_cost 	);
p_target_table(p_target_index).ac_revenue 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_revenue 	,	p_source_table(p_source_index).ac_revenue 	);
p_target_table(p_target_index).ac_bill_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_bill_raw_cost 	,	p_source_table(p_source_index).ac_bill_raw_cost 	);
p_target_table(p_target_index).ac_bill_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_bill_burdened_cost 	,	p_source_table(p_source_index).ac_bill_burdened_cost 	);
p_target_table(p_target_index).ac_bill_equipment_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_bill_equipment_hrs 	,	p_source_table(p_source_index).ac_bill_equipment_hrs 	);
p_target_table(p_target_index).ac_bill_labor_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_bill_labor_raw_cost 	,	p_source_table(p_source_index).ac_bill_labor_raw_cost 	);
p_target_table(p_target_index).ac_bill_labor_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_bill_labor_burdened_cost 	,	p_source_table(p_source_index).ac_bill_labor_burdened_cost 	);
p_target_table(p_target_index).ac_bill_labor_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_bill_labor_hrs 	,	p_source_table(p_source_index).ac_bill_labor_hrs 	);
p_target_table(p_target_index).ac_capitalizable_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_capitalizable_raw_cost 	,	p_source_table(p_source_index).ac_capitalizable_raw_cost 	);
p_target_table(p_target_index).ac_capitalizable_brdn_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_capitalizable_brdn_cost 	,	p_source_table(p_source_index).ac_capitalizable_brdn_cost 	);
p_target_table(p_target_index).ac_equipment_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_equipment_hrs 	,	p_source_table(p_source_index).ac_equipment_hrs 	);
p_target_table(p_target_index).ac_equipment_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_equipment_raw_cost 	,	p_source_table(p_source_index).ac_equipment_raw_cost 	);
p_target_table(p_target_index).ac_equipment_brdn_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_equipment_brdn_cost 	,	p_source_table(p_source_index).ac_equipment_brdn_cost 	);
p_target_table(p_target_index).ac_labor_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_labor_raw_cost 	,	p_source_table(p_source_index).ac_labor_raw_cost 	);
p_target_table(p_target_index).ac_labor_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_labor_burdened_cost 	,	p_source_table(p_source_index).ac_labor_burdened_cost 	);
p_target_table(p_target_index).ac_labor_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_labor_hrs 	,	p_source_table(p_source_index).ac_labor_hrs 	);
p_target_table(p_target_index).ac_labor_revenue 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_labor_revenue 	,	p_source_table(p_source_index).ac_labor_revenue 	);
p_target_table(p_target_index).ac_unbilled_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_unbilled_cost 	,	p_source_table(p_source_index).ac_unbilled_cost 	);
p_target_table(p_target_index).ac_capitalized_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_capitalized_cost 	,	p_source_table(p_source_index).ac_capitalized_cost 	);
p_target_table(p_target_index).ac_sup_inv_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_sup_inv_committed_cost 	,	p_source_table(p_source_index).ac_sup_inv_committed_cost 	);
p_target_table(p_target_index).ac_po_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_po_committed_cost 	,	p_source_table(p_source_index).ac_po_committed_cost 	);
p_target_table(p_target_index).ac_pr_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_pr_committed_cost 	,	p_source_table(p_source_index).ac_pr_committed_cost 	);
p_target_table(p_target_index).ac_oth_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_oth_committed_cost 	,	p_source_table(p_source_index).ac_oth_committed_cost 	);
p_target_table(p_target_index).prp_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_raw_cost 	,	p_source_table(p_source_index).prp_raw_cost 	);
p_target_table(p_target_index).prp_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_burdened_cost 	,	p_source_table(p_source_index).prp_burdened_cost 	);
p_target_table(p_target_index).prp_revenue 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_revenue 	,	p_source_table(p_source_index).prp_revenue 	);
p_target_table(p_target_index).prp_bill_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_bill_raw_cost 	,	p_source_table(p_source_index).prp_bill_raw_cost 	);
p_target_table(p_target_index).prp_bill_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_bill_burdened_cost 	,	p_source_table(p_source_index).prp_bill_burdened_cost 	);
p_target_table(p_target_index).prp_bill_equipment_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_bill_equipment_hrs 	,	p_source_table(p_source_index).prp_bill_equipment_hrs 	);
p_target_table(p_target_index).prp_bill_labor_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_bill_labor_raw_cost 	,	p_source_table(p_source_index).prp_bill_labor_raw_cost 	);
p_target_table(p_target_index).prp_bill_labor_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_bill_labor_burdened_cost 	,	p_source_table(p_source_index).prp_bill_labor_burdened_cost 	);
p_target_table(p_target_index).prp_bill_labor_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_bill_labor_hrs 	,	p_source_table(p_source_index).prp_bill_labor_hrs 	);
p_target_table(p_target_index).prp_capitalizable_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_capitalizable_raw_cost 	,	p_source_table(p_source_index).prp_capitalizable_raw_cost 	);
p_target_table(p_target_index).prp_capitalizable_brdn_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_capitalizable_brdn_cost 	,	p_source_table(p_source_index).prp_capitalizable_brdn_cost 	);
p_target_table(p_target_index).prp_equipment_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_equipment_hrs 	,	p_source_table(p_source_index).prp_equipment_hrs 	);
p_target_table(p_target_index).prp_equipment_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_equipment_raw_cost 	,	p_source_table(p_source_index).prp_equipment_raw_cost 	);
p_target_table(p_target_index).prp_equipment_brdn_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_equipment_brdn_cost 	,	p_source_table(p_source_index).prp_equipment_brdn_cost 	);
p_target_table(p_target_index).prp_labor_raw_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_labor_raw_cost 	,	p_source_table(p_source_index).prp_labor_raw_cost 	);
p_target_table(p_target_index).prp_labor_burdened_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_labor_burdened_cost 	,	p_source_table(p_source_index).prp_labor_burdened_cost 	);
p_target_table(p_target_index).prp_labor_hrs 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_labor_hrs 	,	p_source_table(p_source_index).prp_labor_hrs 	);
p_target_table(p_target_index).prp_labor_revenue 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_labor_revenue 	,	p_source_table(p_source_index).prp_labor_revenue 	);
p_target_table(p_target_index).prp_unbilled_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_unbilled_cost 	,	p_source_table(p_source_index).prp_unbilled_cost 	);
p_target_table(p_target_index).prp_capitalized_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_capitalized_cost 	,	p_source_table(p_source_index).prp_capitalized_cost 	);
p_target_table(p_target_index).prp_sup_inv_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_sup_inv_committed_cost 	,	p_source_table(p_source_index).prp_sup_inv_committed_cost 	);
p_target_table(p_target_index).prp_po_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_po_committed_cost 	,	p_source_table(p_source_index).prp_po_committed_cost 	);
p_target_table(p_target_index).prp_pr_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_pr_committed_cost 	,	p_source_table(p_source_index).prp_pr_committed_cost 	);
p_target_table(p_target_index).prp_oth_committed_cost 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_oth_committed_cost 	,	p_source_table(p_source_index).prp_oth_committed_cost 	);
p_target_table(p_target_index).ptd_custom_1 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_1 	,	p_source_table(p_source_index).ptd_custom_1 	);
p_target_table(p_target_index).ptd_custom_2 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_2 	,	p_source_table(p_source_index).ptd_custom_2 	);
p_target_table(p_target_index).ptd_custom_3 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_3 	,	p_source_table(p_source_index).ptd_custom_3 	);
p_target_table(p_target_index).ptd_custom_4 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_4 	,	p_source_table(p_source_index).ptd_custom_4 	);
p_target_table(p_target_index).ptd_custom_5 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_5 	,	p_source_table(p_source_index).ptd_custom_5 	);
p_target_table(p_target_index).ptd_custom_6 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_6 	,	p_source_table(p_source_index).ptd_custom_6 	);
p_target_table(p_target_index).ptd_custom_7 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_7 	,	p_source_table(p_source_index).ptd_custom_7 	);
p_target_table(p_target_index).ptd_custom_8 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_8 	,	p_source_table(p_source_index).ptd_custom_8 	);
p_target_table(p_target_index).ptd_custom_9 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_9 	,	p_source_table(p_source_index).ptd_custom_9 	);
p_target_table(p_target_index).ptd_custom_10 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_10 	,	p_source_table(p_source_index).ptd_custom_10 	);
p_target_table(p_target_index).ptd_custom_11 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_11 	,	p_source_table(p_source_index).ptd_custom_11 	);
p_target_table(p_target_index).ptd_custom_12 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_12 	,	p_source_table(p_source_index).ptd_custom_12 	);
p_target_table(p_target_index).ptd_custom_13 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_13 	,	p_source_table(p_source_index).ptd_custom_13 	);
p_target_table(p_target_index).ptd_custom_14 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_14 	,	p_source_table(p_source_index).ptd_custom_14 	);
p_target_table(p_target_index).ptd_custom_15 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_15 	,	p_source_table(p_source_index).ptd_custom_15 	);
p_target_table(p_target_index).ptd_custom_16 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_16 	,	p_source_table(p_source_index).ptd_custom_16 	);
p_target_table(p_target_index).ptd_custom_17 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_17 	,	p_source_table(p_source_index).ptd_custom_17 	);
p_target_table(p_target_index).ptd_custom_18 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_18 	,	p_source_table(p_source_index).ptd_custom_18 	);
p_target_table(p_target_index).ptd_custom_19 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_19 	,	p_source_table(p_source_index).ptd_custom_19 	);
p_target_table(p_target_index).ptd_custom_20 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_20 	,	p_source_table(p_source_index).ptd_custom_20 	);
p_target_table(p_target_index).ptd_custom_21 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_21 	,	p_source_table(p_source_index).ptd_custom_21 	);
p_target_table(p_target_index).ptd_custom_22 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_22 	,	p_source_table(p_source_index).ptd_custom_22 	);
p_target_table(p_target_index).ptd_custom_23 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_23 	,	p_source_table(p_source_index).ptd_custom_23 	);
p_target_table(p_target_index).ptd_custom_24 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_24 	,	p_source_table(p_source_index).ptd_custom_24 	);
p_target_table(p_target_index).ptd_custom_25 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_25 	,	p_source_table(p_source_index).ptd_custom_25 	);
p_target_table(p_target_index).ptd_custom_26 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_26 	,	p_source_table(p_source_index).ptd_custom_26 	);
p_target_table(p_target_index).ptd_custom_27 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_27 	,	p_source_table(p_source_index).ptd_custom_27 	);
p_target_table(p_target_index).ptd_custom_28 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_28 	,	p_source_table(p_source_index).ptd_custom_28 	);
p_target_table(p_target_index).ptd_custom_29 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_29 	,	p_source_table(p_source_index).ptd_custom_29 	);
p_target_table(p_target_index).ptd_custom_30 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ptd_custom_30 	,	p_source_table(p_source_index).ptd_custom_30 	);
p_target_table(p_target_index).qtd_custom_1 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_1 	,	p_source_table(p_source_index).qtd_custom_1 	);
p_target_table(p_target_index).qtd_custom_2 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_2 	,	p_source_table(p_source_index).qtd_custom_2 	);
p_target_table(p_target_index).qtd_custom_3 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_3 	,	p_source_table(p_source_index).qtd_custom_3 	);
p_target_table(p_target_index).qtd_custom_4 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_4 	,	p_source_table(p_source_index).qtd_custom_4 	);
p_target_table(p_target_index).qtd_custom_5 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_5 	,	p_source_table(p_source_index).qtd_custom_5 	);
p_target_table(p_target_index).qtd_custom_6 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_6 	,	p_source_table(p_source_index).qtd_custom_6 	);
p_target_table(p_target_index).qtd_custom_7 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_7 	,	p_source_table(p_source_index).qtd_custom_7 	);
p_target_table(p_target_index).qtd_custom_8 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_8 	,	p_source_table(p_source_index).qtd_custom_8 	);
p_target_table(p_target_index).qtd_custom_9 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_9 	,	p_source_table(p_source_index).qtd_custom_9 	);
p_target_table(p_target_index).qtd_custom_10 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_10 	,	p_source_table(p_source_index).qtd_custom_10 	);
p_target_table(p_target_index).qtd_custom_11 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_11 	,	p_source_table(p_source_index).qtd_custom_11 	);
p_target_table(p_target_index).qtd_custom_12 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_12 	,	p_source_table(p_source_index).qtd_custom_12 	);
p_target_table(p_target_index).qtd_custom_13 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_13 	,	p_source_table(p_source_index).qtd_custom_13 	);
p_target_table(p_target_index).qtd_custom_14 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_14 	,	p_source_table(p_source_index).qtd_custom_14 	);
p_target_table(p_target_index).qtd_custom_15 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_15 	,	p_source_table(p_source_index).qtd_custom_15 	);
p_target_table(p_target_index).qtd_custom_16 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_16 	,	p_source_table(p_source_index).qtd_custom_16 	);
p_target_table(p_target_index).qtd_custom_17 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_17 	,	p_source_table(p_source_index).qtd_custom_17 	);
p_target_table(p_target_index).qtd_custom_18 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_18 	,	p_source_table(p_source_index).qtd_custom_18 	);
p_target_table(p_target_index).qtd_custom_19 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_19 	,	p_source_table(p_source_index).qtd_custom_19 	);
p_target_table(p_target_index).qtd_custom_20 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_20 	,	p_source_table(p_source_index).qtd_custom_20 	);
p_target_table(p_target_index).qtd_custom_21 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_21 	,	p_source_table(p_source_index).qtd_custom_21 	);
p_target_table(p_target_index).qtd_custom_22 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_22 	,	p_source_table(p_source_index).qtd_custom_22 	);
p_target_table(p_target_index).qtd_custom_23 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_23 	,	p_source_table(p_source_index).qtd_custom_23 	);
p_target_table(p_target_index).qtd_custom_24 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_24 	,	p_source_table(p_source_index).qtd_custom_24 	);
p_target_table(p_target_index).qtd_custom_25 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_25 	,	p_source_table(p_source_index).qtd_custom_25 	);
p_target_table(p_target_index).qtd_custom_26 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_26 	,	p_source_table(p_source_index).qtd_custom_26 	);
p_target_table(p_target_index).qtd_custom_27 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_27 	,	p_source_table(p_source_index).qtd_custom_27 	);
p_target_table(p_target_index).qtd_custom_28 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_28 	,	p_source_table(p_source_index).qtd_custom_28 	);
p_target_table(p_target_index).qtd_custom_29 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_29 	,	p_source_table(p_source_index).qtd_custom_29 	);
p_target_table(p_target_index).qtd_custom_30 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).qtd_custom_30 	,	p_source_table(p_source_index).qtd_custom_30 	);
p_target_table(p_target_index).ytd_custom_1 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_1 	,	p_source_table(p_source_index).ytd_custom_1 	);
p_target_table(p_target_index).ytd_custom_2 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_2 	,	p_source_table(p_source_index).ytd_custom_2 	);
p_target_table(p_target_index).ytd_custom_3 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_3 	,	p_source_table(p_source_index).ytd_custom_3 	);
p_target_table(p_target_index).ytd_custom_4 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_4 	,	p_source_table(p_source_index).ytd_custom_4 	);
p_target_table(p_target_index).ytd_custom_5 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_5 	,	p_source_table(p_source_index).ytd_custom_5 	);
p_target_table(p_target_index).ytd_custom_6 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_6 	,	p_source_table(p_source_index).ytd_custom_6 	);
p_target_table(p_target_index).ytd_custom_7 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_7 	,	p_source_table(p_source_index).ytd_custom_7 	);
p_target_table(p_target_index).ytd_custom_8 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_8 	,	p_source_table(p_source_index).ytd_custom_8 	);
p_target_table(p_target_index).ytd_custom_9 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_9 	,	p_source_table(p_source_index).ytd_custom_9 	);
p_target_table(p_target_index).ytd_custom_10 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_10 	,	p_source_table(p_source_index).ytd_custom_10 	);
p_target_table(p_target_index).ytd_custom_11 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_11 	,	p_source_table(p_source_index).ytd_custom_11 	);
p_target_table(p_target_index).ytd_custom_12 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_12 	,	p_source_table(p_source_index).ytd_custom_12 	);
p_target_table(p_target_index).ytd_custom_13 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_13 	,	p_source_table(p_source_index).ytd_custom_13 	);
p_target_table(p_target_index).ytd_custom_14 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_14 	,	p_source_table(p_source_index).ytd_custom_14 	);
p_target_table(p_target_index).ytd_custom_15 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_15 	,	p_source_table(p_source_index).ytd_custom_15 	);
p_target_table(p_target_index).ytd_custom_16 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_16 	,	p_source_table(p_source_index).ytd_custom_16 	);
p_target_table(p_target_index).ytd_custom_17 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_17 	,	p_source_table(p_source_index).ytd_custom_17 	);
p_target_table(p_target_index).ytd_custom_18 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_18 	,	p_source_table(p_source_index).ytd_custom_18 	);
p_target_table(p_target_index).ytd_custom_19 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_19 	,	p_source_table(p_source_index).ytd_custom_19 	);
p_target_table(p_target_index).ytd_custom_20 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_20 	,	p_source_table(p_source_index).ytd_custom_20 	);
p_target_table(p_target_index).ytd_custom_21 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_21 	,	p_source_table(p_source_index).ytd_custom_21 	);
p_target_table(p_target_index).ytd_custom_22 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_22 	,	p_source_table(p_source_index).ytd_custom_22 	);
p_target_table(p_target_index).ytd_custom_23 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_23 	,	p_source_table(p_source_index).ytd_custom_23 	);
p_target_table(p_target_index).ytd_custom_24 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_24 	,	p_source_table(p_source_index).ytd_custom_24 	);
p_target_table(p_target_index).ytd_custom_25 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_25 	,	p_source_table(p_source_index).ytd_custom_25 	);
p_target_table(p_target_index).ytd_custom_26 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_26 	,	p_source_table(p_source_index).ytd_custom_26 	);
p_target_table(p_target_index).ytd_custom_27 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_27 	,	p_source_table(p_source_index).ytd_custom_27 	);
p_target_table(p_target_index).ytd_custom_28 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_28 	,	p_source_table(p_source_index).ytd_custom_28 	);
p_target_table(p_target_index).ytd_custom_29 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_29 	,	p_source_table(p_source_index).ytd_custom_29 	);
p_target_table(p_target_index).ytd_custom_30 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ytd_custom_30 	,	p_source_table(p_source_index).ytd_custom_30 	);
p_target_table(p_target_index).itd_custom_1 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_1 	,	p_source_table(p_source_index).itd_custom_1 	);
p_target_table(p_target_index).itd_custom_2 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_2 	,	p_source_table(p_source_index).itd_custom_2 	);
p_target_table(p_target_index).itd_custom_3 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_3 	,	p_source_table(p_source_index).itd_custom_3 	);
p_target_table(p_target_index).itd_custom_4 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_4 	,	p_source_table(p_source_index).itd_custom_4 	);
p_target_table(p_target_index).itd_custom_5 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_5 	,	p_source_table(p_source_index).itd_custom_5 	);
p_target_table(p_target_index).itd_custom_6 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_6 	,	p_source_table(p_source_index).itd_custom_6 	);
p_target_table(p_target_index).itd_custom_7 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_7 	,	p_source_table(p_source_index).itd_custom_7 	);
p_target_table(p_target_index).itd_custom_8 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_8 	,	p_source_table(p_source_index).itd_custom_8 	);
p_target_table(p_target_index).itd_custom_9 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_9 	,	p_source_table(p_source_index).itd_custom_9 	);
p_target_table(p_target_index).itd_custom_10 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_10 	,	p_source_table(p_source_index).itd_custom_10 	);
p_target_table(p_target_index).itd_custom_11 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_11 	,	p_source_table(p_source_index).itd_custom_11 	);
p_target_table(p_target_index).itd_custom_12 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_12 	,	p_source_table(p_source_index).itd_custom_12 	);
p_target_table(p_target_index).itd_custom_13 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_13 	,	p_source_table(p_source_index).itd_custom_13 	);
p_target_table(p_target_index).itd_custom_14 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_14 	,	p_source_table(p_source_index).itd_custom_14 	);
p_target_table(p_target_index).itd_custom_15 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_15 	,	p_source_table(p_source_index).itd_custom_15 	);
p_target_table(p_target_index).itd_custom_16 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_16 	,	p_source_table(p_source_index).itd_custom_16 	);
p_target_table(p_target_index).itd_custom_17 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_17 	,	p_source_table(p_source_index).itd_custom_17 	);
p_target_table(p_target_index).itd_custom_18 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_18 	,	p_source_table(p_source_index).itd_custom_18 	);
p_target_table(p_target_index).itd_custom_19 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_19 	,	p_source_table(p_source_index).itd_custom_19 	);
p_target_table(p_target_index).itd_custom_20 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_20 	,	p_source_table(p_source_index).itd_custom_20 	);
p_target_table(p_target_index).itd_custom_21 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_21 	,	p_source_table(p_source_index).itd_custom_21 	);
p_target_table(p_target_index).itd_custom_22 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_22 	,	p_source_table(p_source_index).itd_custom_22 	);
p_target_table(p_target_index).itd_custom_23 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_23 	,	p_source_table(p_source_index).itd_custom_23 	);
p_target_table(p_target_index).itd_custom_24 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_24 	,	p_source_table(p_source_index).itd_custom_24 	);
p_target_table(p_target_index).itd_custom_25 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_25 	,	p_source_table(p_source_index).itd_custom_25 	);
p_target_table(p_target_index).itd_custom_26 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_26 	,	p_source_table(p_source_index).itd_custom_26 	);
p_target_table(p_target_index).itd_custom_27 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_27 	,	p_source_table(p_source_index).itd_custom_27 	);
p_target_table(p_target_index).itd_custom_28 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_28 	,	p_source_table(p_source_index).itd_custom_28 	);
p_target_table(p_target_index).itd_custom_29 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_29 	,	p_source_table(p_source_index).itd_custom_29 	);
p_target_table(p_target_index).itd_custom_30 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).itd_custom_30 	,	p_source_table(p_source_index).itd_custom_30 	);
p_target_table(p_target_index).ac_custom_1 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_1 	,	p_source_table(p_source_index).ac_custom_1 	);
p_target_table(p_target_index).ac_custom_2 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_2 	,	p_source_table(p_source_index).ac_custom_2 	);
p_target_table(p_target_index).ac_custom_3 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_3 	,	p_source_table(p_source_index).ac_custom_3 	);
p_target_table(p_target_index).ac_custom_4 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_4 	,	p_source_table(p_source_index).ac_custom_4 	);
p_target_table(p_target_index).ac_custom_5 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_5 	,	p_source_table(p_source_index).ac_custom_5 	);
p_target_table(p_target_index).ac_custom_6 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_6 	,	p_source_table(p_source_index).ac_custom_6 	);
p_target_table(p_target_index).ac_custom_7 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_7 	,	p_source_table(p_source_index).ac_custom_7 	);
p_target_table(p_target_index).ac_custom_8 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_8 	,	p_source_table(p_source_index).ac_custom_8 	);
p_target_table(p_target_index).ac_custom_9 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_9 	,	p_source_table(p_source_index).ac_custom_9 	);
p_target_table(p_target_index).ac_custom_10 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_10 	,	p_source_table(p_source_index).ac_custom_10 	);
p_target_table(p_target_index).ac_custom_11 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_11 	,	p_source_table(p_source_index).ac_custom_11 	);
p_target_table(p_target_index).ac_custom_12 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_12 	,	p_source_table(p_source_index).ac_custom_12 	);
p_target_table(p_target_index).ac_custom_13 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_13 	,	p_source_table(p_source_index).ac_custom_13 	);
p_target_table(p_target_index).ac_custom_14 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_14 	,	p_source_table(p_source_index).ac_custom_14 	);
p_target_table(p_target_index).ac_custom_15 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_15 	,	p_source_table(p_source_index).ac_custom_15 	);
p_target_table(p_target_index).ac_custom_16 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_16 	,	p_source_table(p_source_index).ac_custom_16 	);
p_target_table(p_target_index).ac_custom_17 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_17 	,	p_source_table(p_source_index).ac_custom_17 	);
p_target_table(p_target_index).ac_custom_18 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_18 	,	p_source_table(p_source_index).ac_custom_18 	);
p_target_table(p_target_index).ac_custom_19 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_19 	,	p_source_table(p_source_index).ac_custom_19 	);
p_target_table(p_target_index).ac_custom_20 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_20 	,	p_source_table(p_source_index).ac_custom_20 	);
p_target_table(p_target_index).ac_custom_21 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_21 	,	p_source_table(p_source_index).ac_custom_21 	);
p_target_table(p_target_index).ac_custom_22 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_22 	,	p_source_table(p_source_index).ac_custom_22 	);
p_target_table(p_target_index).ac_custom_23 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_23 	,	p_source_table(p_source_index).ac_custom_23 	);
p_target_table(p_target_index).ac_custom_24 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_24 	,	p_source_table(p_source_index).ac_custom_24 	);
p_target_table(p_target_index).ac_custom_25 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_25 	,	p_source_table(p_source_index).ac_custom_25 	);
p_target_table(p_target_index).ac_custom_26 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_26 	,	p_source_table(p_source_index).ac_custom_26 	);
p_target_table(p_target_index).ac_custom_27 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_27 	,	p_source_table(p_source_index).ac_custom_27 	);
p_target_table(p_target_index).ac_custom_28 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_28 	,	p_source_table(p_source_index).ac_custom_28 	);
p_target_table(p_target_index).ac_custom_29 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_29 	,	p_source_table(p_source_index).ac_custom_29 	);
p_target_table(p_target_index).ac_custom_30 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).ac_custom_30 	,	p_source_table(p_source_index).ac_custom_30 	);
p_target_table(p_target_index).prp_custom_1 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_1 	,	p_source_table(p_source_index).prp_custom_1 	);
p_target_table(p_target_index).prp_custom_2 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_2 	,	p_source_table(p_source_index).prp_custom_2 	);
p_target_table(p_target_index).prp_custom_3 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_3 	,	p_source_table(p_source_index).prp_custom_3 	);
p_target_table(p_target_index).prp_custom_4 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_4 	,	p_source_table(p_source_index).prp_custom_4 	);
p_target_table(p_target_index).prp_custom_5 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_5 	,	p_source_table(p_source_index).prp_custom_5 	);
p_target_table(p_target_index).prp_custom_6 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_6 	,	p_source_table(p_source_index).prp_custom_6 	);
p_target_table(p_target_index).prp_custom_7 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_7 	,	p_source_table(p_source_index).prp_custom_7 	);
p_target_table(p_target_index).prp_custom_8 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_8 	,	p_source_table(p_source_index).prp_custom_8 	);
p_target_table(p_target_index).prp_custom_9 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_9 	,	p_source_table(p_source_index).prp_custom_9 	);
p_target_table(p_target_index).prp_custom_10 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_10 	,	p_source_table(p_source_index).prp_custom_10 	);
p_target_table(p_target_index).prp_custom_11 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_11 	,	p_source_table(p_source_index).prp_custom_11 	);
p_target_table(p_target_index).prp_custom_12 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_12 	,	p_source_table(p_source_index).prp_custom_12 	);
p_target_table(p_target_index).prp_custom_13 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_13 	,	p_source_table(p_source_index).prp_custom_13 	);
p_target_table(p_target_index).prp_custom_14 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_14 	,	p_source_table(p_source_index).prp_custom_14 	);
p_target_table(p_target_index).prp_custom_15 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_15 	,	p_source_table(p_source_index).prp_custom_15 	);
p_target_table(p_target_index).prp_custom_16 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_16 	,	p_source_table(p_source_index).prp_custom_16 	);
p_target_table(p_target_index).prp_custom_17 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_17 	,	p_source_table(p_source_index).prp_custom_17 	);
p_target_table(p_target_index).prp_custom_18 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_18 	,	p_source_table(p_source_index).prp_custom_18 	);
p_target_table(p_target_index).prp_custom_19 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_19 	,	p_source_table(p_source_index).prp_custom_19 	);
p_target_table(p_target_index).prp_custom_20 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_20 	,	p_source_table(p_source_index).prp_custom_20 	);
p_target_table(p_target_index).prp_custom_21 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_21 	,	p_source_table(p_source_index).prp_custom_21 	);
p_target_table(p_target_index).prp_custom_22 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_22 	,	p_source_table(p_source_index).prp_custom_22 	);
p_target_table(p_target_index).prp_custom_23 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_23 	,	p_source_table(p_source_index).prp_custom_23 	);
p_target_table(p_target_index).prp_custom_24 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_24 	,	p_source_table(p_source_index).prp_custom_24 	);
p_target_table(p_target_index).prp_custom_25 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_25 	,	p_source_table(p_source_index).prp_custom_25 	);
p_target_table(p_target_index).prp_custom_26 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_26 	,	p_source_table(p_source_index).prp_custom_26 	);
p_target_table(p_target_index).prp_custom_27 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_27 	,	p_source_table(p_source_index).prp_custom_27 	);
p_target_table(p_target_index).prp_custom_28 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_28 	,	p_source_table(p_source_index).prp_custom_28 	);
p_target_table(p_target_index).prp_custom_29 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_29 	,	p_source_table(p_source_index).prp_custom_29 	);
p_target_table(p_target_index).prp_custom_30 	:=	Pji_Rep_Util.measures_total(	p_target_table(p_target_index).prp_custom_30 	,	p_source_table(p_source_index).prp_custom_30 	);

END Merge_Overview_Type;

/** Added for Bug 7533980
 * This procedure would be called from setFinancialAndActivityMeasuresWRP
 * method defined in ProjectListGenVOImpl. In accepts a table of Project
 * ids and returns back two tables that have financial measures and
 * exception indicators for All the passed project ids.
 */
PROCEDURE Get_Financial_Measures_wrp
(
    p_project_id_tbl             IN SYSTEM.pa_num_tbl_type
  , p_measure_codes_tbl          IN SYSTEM.PA_VARCHAR2_80_TBL_TYPE
  , p_measure_set_codes_tbl      IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL
  , p_timeslices_tbl   		 IN SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT NULL
  , p_measure_id_tbl		 IN SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL
  , x_measure_values_tbl         OUT NOCOPY SYSTEM.PJI_FIN_MEAS_REC_TBL_TYPE
  , x_exception_indicator_tbl    OUT NOCOPY SYSTEM.PJI_EXCP_IND_REC_TBL_TYPE
  --, x_exception_labels_tbl       OUT NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE
  , x_return_status              OUT NOCOPY VARCHAR2
  , x_msg_count                  OUT NOCOPY NUMBER
  , x_msg_data                   OUT NOCOPY VARCHAR2 -- not used
)
IS

  x_sec_ret_code          VARCHAR2(1);

  l_sec_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_sec_msg_count         NUMBER      := 0;
  l_sec_msg_data          VARCHAR2(1) := NULL;

  l_measure_values_tbl      SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
  l_exception_indicator_tbl SYSTEM.PA_VARCHAR2_2000_TBL_TYPE;

  l_pji_fin_meas_rec  SYSTEM.PJI_FIN_MEAS_REC;
  l_pji_fin_meas_rec_tbl    SYSTEM.PJI_FIN_MEAS_REC_TBL_TYPE ;

  l_pji_excp_ind_rec  SYSTEM.PJI_EXCP_IND_REC;
  l_pji_excp_ind_rec_tbl SYSTEM.PJI_EXCP_IND_REC_TBL_TYPE;

  l_project_id_tbl            SYSTEM.pa_num_tbl_type;

BEGIN

  l_project_id_tbl := p_project_id_tbl;

  IF (p_project_id_tbl.COUNT < 1 ) THEN
    x_measure_values_tbl := NULL ;
    x_exception_indicator_tbl := NULL ;
    RETURN ;
  END IF ;

  ----------------
  l_pji_fin_meas_rec := NULL ;
  l_pji_fin_meas_rec_tbl := SYSTEM.PJI_FIN_MEAS_REC_TBL_TYPE();
  l_pji_fin_meas_rec_tbl := SYSTEM.PJI_FIN_MEAS_REC_TBL_TYPE (l_pji_fin_meas_rec); -- initialize

  l_pji_fin_meas_rec_tbl.extend((p_project_id_tbl.COUNT - 1 ));

  -------------
  l_pji_excp_ind_rec := NULL ;
  l_pji_excp_ind_rec_tbl := SYSTEM.PJI_EXCP_IND_REC_TBL_TYPE();
  l_pji_excp_ind_rec_tbl := SYSTEM.PJI_EXCP_IND_REC_TBL_TYPE (l_pji_excp_ind_rec); -- initialize

  l_pji_excp_ind_rec_tbl.extend((p_project_id_tbl.COUNT - 1 ));

  --------------

FOR i IN l_project_id_tbl.FIRST .. l_project_id_tbl.LAST LOOP

l_measure_values_tbl      := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
l_exception_indicator_tbl := SYSTEM.PA_VARCHAR2_2000_TBL_TYPE();

x_sec_ret_code := 'F';

PA_SECURITY_PVT.check_user_privilege
   (
      p_privilege     => 'PA_MY_PROJ_MAIN_TAB_PSI_COL',
      p_object_name   => 'PA_PROJECTS',
      p_object_key    => l_project_id_tbl(i),
      x_ret_code      => x_sec_ret_code,
      x_return_status => l_sec_return_status,
      x_msg_count     => l_sec_msg_count,
      x_msg_data      => l_sec_msg_data
   );

IF (x_sec_ret_code = 'T') THEN

Get_Financial_Measures
(
   p_project_id            => l_project_id_tbl(i)
 , p_measure_codes_tbl     => p_measure_codes_tbl
 , p_measure_set_codes_tbl => p_measure_set_codes_tbl
 , p_timeslices_tbl        => p_timeslices_tbl
 , p_measure_id_tbl        => p_measure_id_tbl
 , x_measure_values_tbl    => l_measure_values_tbl
 , x_exception_indicator_tbl => l_exception_indicator_tbl
 --, x_exception_labels_tbl    OUT NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE -- remove
 , x_return_status           =>  x_return_status
 , x_msg_count               =>  x_msg_count
 , x_msg_data                =>  x_msg_data

);


l_pji_fin_meas_rec := SYSTEM.PJI_FIN_MEAS_REC( p_project_id_tbl(i),
l_measure_values_tbl(1) ,
l_measure_values_tbl(2) ,
l_measure_values_tbl(3) ,
l_measure_values_tbl(4) ,
l_measure_values_tbl(5) ,
l_measure_values_tbl(6) ,
l_measure_values_tbl(7) ,
l_measure_values_tbl(8) ,
l_measure_values_tbl(9) ,
l_measure_values_tbl(10) ,
l_measure_values_tbl(11) ,
l_measure_values_tbl(12) ,
l_measure_values_tbl(13) ,
l_measure_values_tbl(14) ,
l_measure_values_tbl(15) ,
l_measure_values_tbl(16) ,
l_measure_values_tbl(17) ,
l_measure_values_tbl(18) ,
l_measure_values_tbl(19) ,
l_measure_values_tbl(20) ,
l_measure_values_tbl(21) ,
l_measure_values_tbl(22) ,
l_measure_values_tbl(23) ,
l_measure_values_tbl(24) ,
l_measure_values_tbl(25) ,
l_measure_values_tbl(26) ,
l_measure_values_tbl(27) ,
l_measure_values_tbl(28) ,
l_measure_values_tbl(29) ,
l_measure_values_tbl(30) ,
l_measure_values_tbl(31) ,
l_measure_values_tbl(32) ,
l_measure_values_tbl(33) ,
l_measure_values_tbl(34) ,
l_measure_values_tbl(35) ,
l_measure_values_tbl(36) ,
l_measure_values_tbl(37) ,
l_measure_values_tbl(38) ,
l_measure_values_tbl(39) ,
l_measure_values_tbl(40) ,
l_measure_values_tbl(41) ,
l_measure_values_tbl(42) ,
l_measure_values_tbl(43) ,
l_measure_values_tbl(44) ,
l_measure_values_tbl(45) ,
l_measure_values_tbl(46) ,
l_measure_values_tbl(47) ,
l_measure_values_tbl(48) ,
l_measure_values_tbl(49) ,
l_measure_values_tbl(50) ,
l_measure_values_tbl(51) ,
l_measure_values_tbl(52) ,
l_measure_values_tbl(53) ,
l_measure_values_tbl(54) ,
l_measure_values_tbl(55) ,
l_measure_values_tbl(56) ,
l_measure_values_tbl(57) ,
l_measure_values_tbl(58) ,
l_measure_values_tbl(59) ,
l_measure_values_tbl(60) ,
l_measure_values_tbl(61) ,
l_measure_values_tbl(62) ,
l_measure_values_tbl(63) ,
l_measure_values_tbl(64) ,
l_measure_values_tbl(65) ,
l_measure_values_tbl(66) ,
l_measure_values_tbl(67) ,
l_measure_values_tbl(68) ,
l_measure_values_tbl(69) ,
l_measure_values_tbl(70) ,
l_measure_values_tbl(71) ,
l_measure_values_tbl(72) ,
l_measure_values_tbl(73) ,
l_measure_values_tbl(74) ,
l_measure_values_tbl(75) ,
l_measure_values_tbl(76) ,
l_measure_values_tbl(77) ,
l_measure_values_tbl(78) ,
l_measure_values_tbl(79) ,
l_measure_values_tbl(80) ,
l_measure_values_tbl(81) ,      -- Bug 8810949 : Start
l_measure_values_tbl(82) ,
l_measure_values_tbl(83) ,
l_measure_values_tbl(84) ,
l_measure_values_tbl(85) ,
l_measure_values_tbl(86) ,
l_measure_values_tbl(87) ,
l_measure_values_tbl(88) ,
l_measure_values_tbl(89) ,
l_measure_values_tbl(90) ,
l_measure_values_tbl(91) ,
l_measure_values_tbl(92) ,
l_measure_values_tbl(93) ,
l_measure_values_tbl(94) ,
l_measure_values_tbl(95) ,
l_measure_values_tbl(96) ,
l_measure_values_tbl(97) ,
l_measure_values_tbl(98) ,
l_measure_values_tbl(99) ,
l_measure_values_tbl(100) ,
l_measure_values_tbl(101) ,
l_measure_values_tbl(102) ,
l_measure_values_tbl(103) ,
l_measure_values_tbl(104) ,
l_measure_values_tbl(105) ,
l_measure_values_tbl(106) ,
l_measure_values_tbl(107) ,
l_measure_values_tbl(108) ,
l_measure_values_tbl(109) ,
l_measure_values_tbl(110) ,
l_measure_values_tbl(111) ,
l_measure_values_tbl(112) ,
l_measure_values_tbl(113) ,
l_measure_values_tbl(114) ,
l_measure_values_tbl(115) ,
l_measure_values_tbl(116) ,
l_measure_values_tbl(117) ,
l_measure_values_tbl(118) ,
l_measure_values_tbl(119) ,
l_measure_values_tbl(120) ,
l_measure_values_tbl(121) ,
l_measure_values_tbl(122) ,
l_measure_values_tbl(123) ,
l_measure_values_tbl(124) ,
l_measure_values_tbl(125) ,
l_measure_values_tbl(126) ,
l_measure_values_tbl(127) ,
l_measure_values_tbl(128) ,
l_measure_values_tbl(129) ,
l_measure_values_tbl(130) ,
l_measure_values_tbl(131) ,
l_measure_values_tbl(132) ,
l_measure_values_tbl(133) ,
l_measure_values_tbl(134) ,
l_measure_values_tbl(135) ,
l_measure_values_tbl(136) ,
l_measure_values_tbl(137) ,
l_measure_values_tbl(138) ,
l_measure_values_tbl(139) ,
l_measure_values_tbl(140) ,
l_measure_values_tbl(141) ,
l_measure_values_tbl(142) ,
l_measure_values_tbl(143) ,
l_measure_values_tbl(144) ,
l_measure_values_tbl(145) ,
l_measure_values_tbl(146) ,
l_measure_values_tbl(147) ,
l_measure_values_tbl(148) ,
l_measure_values_tbl(149) ,
l_measure_values_tbl(150) ,
l_measure_values_tbl(151) ,
l_measure_values_tbl(152) ,
l_measure_values_tbl(153) ,
l_measure_values_tbl(154) ,
l_measure_values_tbl(155) ,
l_measure_values_tbl(156) ,
l_measure_values_tbl(157) ,
l_measure_values_tbl(158) ,
l_measure_values_tbl(159) ,
l_measure_values_tbl(160) ,
l_measure_values_tbl(161) ,
l_measure_values_tbl(162) ,
l_measure_values_tbl(163) );      -- Bug 8810949 : End

l_pji_fin_meas_rec_tbl(i) := l_pji_fin_meas_rec;

----------------

l_pji_excp_ind_rec := SYSTEM.PJI_EXCP_IND_REC( p_project_id_tbl(i),
l_exception_indicator_tbl(1) ,
l_exception_indicator_tbl(2) ,
l_exception_indicator_tbl(3) ,
l_exception_indicator_tbl(4) ,
l_exception_indicator_tbl(5) ,
l_exception_indicator_tbl(6) ,
l_exception_indicator_tbl(7) ,
l_exception_indicator_tbl(8) ,
l_exception_indicator_tbl(9) ,
l_exception_indicator_tbl(10) ,
l_exception_indicator_tbl(11) ,
l_exception_indicator_tbl(12) ,
l_exception_indicator_tbl(13) ,
l_exception_indicator_tbl(14) ,
l_exception_indicator_tbl(15) ,
l_exception_indicator_tbl(16) ,
l_exception_indicator_tbl(17) ,
l_exception_indicator_tbl(18) ,
l_exception_indicator_tbl(19) ,
l_exception_indicator_tbl(20) ,
l_exception_indicator_tbl(21) ,
l_exception_indicator_tbl(22) ,
l_exception_indicator_tbl(23) ,
l_exception_indicator_tbl(24) ,
l_exception_indicator_tbl(25) ,
l_exception_indicator_tbl(26) ,
l_exception_indicator_tbl(27) ,
l_exception_indicator_tbl(28) ,
l_exception_indicator_tbl(29) ,
l_exception_indicator_tbl(30) ,
l_exception_indicator_tbl(31) ,
l_exception_indicator_tbl(32) ,
l_exception_indicator_tbl(33) ,
l_exception_indicator_tbl(34) ,
l_exception_indicator_tbl(35) ,
l_exception_indicator_tbl(36) ,
l_exception_indicator_tbl(37) ,
l_exception_indicator_tbl(38) ,
l_exception_indicator_tbl(39) ,
l_exception_indicator_tbl(40) ,
l_exception_indicator_tbl(41) ,
l_exception_indicator_tbl(42) ,
l_exception_indicator_tbl(43) ,
l_exception_indicator_tbl(44) ,
l_exception_indicator_tbl(45) ,
l_exception_indicator_tbl(46) ,
l_exception_indicator_tbl(47) ,
l_exception_indicator_tbl(48) ,
l_exception_indicator_tbl(49) ,
l_exception_indicator_tbl(50) ,
l_exception_indicator_tbl(51) ,
l_exception_indicator_tbl(52) ,
l_exception_indicator_tbl(53) ,
l_exception_indicator_tbl(54) ,
l_exception_indicator_tbl(55) ,
l_exception_indicator_tbl(56) ,
l_exception_indicator_tbl(57) ,
l_exception_indicator_tbl(58) ,
l_exception_indicator_tbl(59) ,
l_exception_indicator_tbl(60) ,
l_exception_indicator_tbl(61) ,
l_exception_indicator_tbl(62) ,
l_exception_indicator_tbl(63) ,
l_exception_indicator_tbl(64) ,
l_exception_indicator_tbl(65) ,
l_exception_indicator_tbl(66) ,
l_exception_indicator_tbl(67) ,
l_exception_indicator_tbl(68) ,
l_exception_indicator_tbl(69) ,
l_exception_indicator_tbl(70) ,
l_exception_indicator_tbl(71) ,
l_exception_indicator_tbl(72) ,
l_exception_indicator_tbl(73) ,
l_exception_indicator_tbl(74) ,
l_exception_indicator_tbl(75) ,
l_exception_indicator_tbl(76) ,
l_exception_indicator_tbl(77) ,
l_exception_indicator_tbl(78) ,
l_exception_indicator_tbl(79) ,
l_exception_indicator_tbl(80) ,
l_exception_indicator_tbl(81) ,      -- Bug 8810949 : Start
l_exception_indicator_tbl(82) ,
l_exception_indicator_tbl(83) ,
l_exception_indicator_tbl(84) ,
l_exception_indicator_tbl(85) ,
l_exception_indicator_tbl(86) ,
l_exception_indicator_tbl(87) ,
l_exception_indicator_tbl(88) ,
l_exception_indicator_tbl(89) ,
l_exception_indicator_tbl(90) ,
l_exception_indicator_tbl(91) ,
l_exception_indicator_tbl(92) ,
l_exception_indicator_tbl(93) ,
l_exception_indicator_tbl(94) ,
l_exception_indicator_tbl(95) ,
l_exception_indicator_tbl(96) ,
l_exception_indicator_tbl(97) ,
l_exception_indicator_tbl(98) ,
l_exception_indicator_tbl(99) ,
l_exception_indicator_tbl(100) ,
l_exception_indicator_tbl(101) ,
l_exception_indicator_tbl(102) ,
l_exception_indicator_tbl(103) ,
l_exception_indicator_tbl(104) ,
l_exception_indicator_tbl(105) ,
l_exception_indicator_tbl(106) ,
l_exception_indicator_tbl(107) ,
l_exception_indicator_tbl(108) ,
l_exception_indicator_tbl(109) ,
l_exception_indicator_tbl(110) ,
l_exception_indicator_tbl(111) ,
l_exception_indicator_tbl(112) ,
l_exception_indicator_tbl(113) ,
l_exception_indicator_tbl(114) ,
l_exception_indicator_tbl(115) ,
l_exception_indicator_tbl(116) ,
l_exception_indicator_tbl(117) ,
l_exception_indicator_tbl(118) ,
l_exception_indicator_tbl(119) ,
l_exception_indicator_tbl(120) ,
l_exception_indicator_tbl(121) ,
l_exception_indicator_tbl(122) ,
l_exception_indicator_tbl(123) ,
l_exception_indicator_tbl(124) ,
l_exception_indicator_tbl(125) ,
l_exception_indicator_tbl(126) ,
l_exception_indicator_tbl(127) ,
l_exception_indicator_tbl(128) ,
l_exception_indicator_tbl(129) ,
l_exception_indicator_tbl(130) ,
l_exception_indicator_tbl(131) ,
l_exception_indicator_tbl(132) ,
l_exception_indicator_tbl(133) ,
l_exception_indicator_tbl(134) ,
l_exception_indicator_tbl(135) ,
l_exception_indicator_tbl(136) ,
l_exception_indicator_tbl(137) ,
l_exception_indicator_tbl(138) ,
l_exception_indicator_tbl(139) ,
l_exception_indicator_tbl(140) ,
l_exception_indicator_tbl(141) ,
l_exception_indicator_tbl(142) ,
l_exception_indicator_tbl(143) ,
l_exception_indicator_tbl(144) ,
l_exception_indicator_tbl(145) ,
l_exception_indicator_tbl(146) ,
l_exception_indicator_tbl(147) ,
l_exception_indicator_tbl(148) ,
l_exception_indicator_tbl(149) ,
l_exception_indicator_tbl(150) ,
l_exception_indicator_tbl(151) ,
l_exception_indicator_tbl(152) ,
l_exception_indicator_tbl(153) ,
l_exception_indicator_tbl(154) ,
l_exception_indicator_tbl(155) ,
l_exception_indicator_tbl(156) ,
l_exception_indicator_tbl(157) ,
l_exception_indicator_tbl(158) ,
l_exception_indicator_tbl(159) ,
l_exception_indicator_tbl(160) ,
l_exception_indicator_tbl(161) ,
l_exception_indicator_tbl(162) ,
l_exception_indicator_tbl(163) );      -- Bug 8810949 : End

l_pji_excp_ind_rec_tbl(i) := l_pji_excp_ind_rec;

END IF ; -- IF (x_sec_ret_code = 'T')

END LOOP ;

x_measure_values_tbl := l_pji_fin_meas_rec_tbl;
x_exception_indicator_tbl := l_pji_excp_ind_rec_tbl;

END Get_Financial_Measures_wrp;

BEGIN

g_msg_level_highest_detail := 6;
g_msg_level_normal_flow    := 5;
g_msg_level_data_bug       := 5;
g_msg_level_data_corruption:= 5;
g_msg_level_proc_call      := 5;
g_msg_level_runtime_info   := 5;
g_msg_level_low_detail     := 2;
g_msg_level_lowest_detail  := 1;

g_CurrencyType             := 'CURRENCY';
g_PercentType              := 'PERCENT';
g_HoursType                := 'EFFORT';
g_IndexType                := 'INDEX';
g_OtherType               := 'OTHER';
g_DaysType				   := 'DAYS';

g_CurrencyDecimalPlaces    := 0; -- Currencies must be rounded to the nearest integer ##TBD##
g_HoursDecimalPlaces       := 0; -- Hours must be rounded to the nearest integer
g_PercentDecimalPlaces     := 2; -- Percentages must be rounded to 2 decimal place
g_IndexDecimalPlaces       := 2; -- Indexes must be rounded to 2 decimal place
g_currency_size            := 30;

g_Actual_is_present        := 1;
g_CstFcst_is_present       := 2;
g_CstBudget_is_present     := 4;
g_CstBudget2_is_present    := 8;
g_RevFcst_is_present       := 16;
g_RevBudget_is_present     := 32;
g_RevBudget2_is_present    := 64;
g_OrigCstFcst_is_present   := 128;
g_OrigCstBudget_is_present := 256;
g_OrigCstBudget2_is_present:= 512;
g_OrigRevFcst_is_present   := 1024;
g_OrigRevBudget_is_present := 2048;
g_OrigRevBudget2_is_present:= 4096;
g_CstPriorfcst_is_present  := 8192;
g_RevPriorfcst_is_present  := 16384;
g_Actual_CstBudget         := g_Actual_is_present + g_CstBudget_is_present;
g_Actual_CstFcst           := g_Actual_is_present + g_CstFcst_is_present;
g_Actual_CstRevBudget      := g_Actual_is_present + g_CstBudget_is_present + g_RevBudget_is_present;
g_Actual_RevBudget         := g_Actual_is_present + g_RevBudget_is_present;
g_Actual_RevFcst           := g_Actual_is_present + g_RevFcst_is_present;
g_CstRevBudget             := g_CstBudget_is_present + g_RevBudget_is_present;
g_CstRevBudget2            := g_CstBudget2_is_present + g_RevBudget2_is_present;
g_CstRevFcst               := g_CstFcst_is_present + g_RevFcst_is_present;
g_CstBudget_CstFcst        := g_CstBudget_is_present + g_CstFcst_is_present;
g_RevBudget_RevFcst        := g_RevBudget_is_present + g_RevFcst_is_present;
g_CstRevBudgetFcst         := g_CstBudget_is_present + g_RevBudget_is_present + g_CstFcst_is_present + g_RevFcst_is_present;
g_CstOrigCstBudget         := g_CstBudget_is_present + g_OrigCstBudget_is_present;
g_CstFcst_OrigCstBudget    := g_CstFcst_is_present + g_OrigCstBudget_is_present;
g_CstRevBudgetOrigbudget   := g_CstBudget_is_present + g_RevBudget_is_present + g_OrigCstBudget_is_present + g_OrigRevBudget_is_present;
g_RevBudgetOrigbudget      := g_RevBudget_is_present + g_OrigRevBudget_is_present;
g_CstRevOrigbudgetFcst     := g_OrigCstBudget_is_present + g_OrigRevBudget_is_present + g_CstFcst_is_present + g_RevFcst_is_present;
g_RevBudgetFcst            := g_RevBudget_is_present + g_RevFcst_is_present;
g_RevOrigbudgetFcst        := g_RevFcst_is_present + g_OrigRevBudget_is_present;
g_CstRevFcstPriorfcst      := g_CstPriorfcst_is_present + g_RevPriorfcst_is_present + g_CstFcst_is_present + g_RevFcst_is_present;
g_RevFcstRevPriorfcst      := g_RevFcst_is_present + g_RevPriorfcst_is_present;
g_CstFcstCstPriorfcst      := g_CstFcst_is_present + g_CstPriorfcst_is_present;
g_Cst_FcstPriorfcst        := g_CstBudget_is_present + g_CstPriorfcst_is_present;

END Pji_Rep_Measure_Util;

/
