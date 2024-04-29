--------------------------------------------------------
--  DDL for Package Body HR_BIS_ALERTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_BIS_ALERTS" AS
/* $Header: hrbistr.pkb 115.32 2003/12/29 02:14:11 prasharm ship $ */

c_ampersand			constant VARCHAR2(1) := fnd_global.local_chr(38);

g_orgprc_const                VARCHAR2(4) := 'SINR';

--Package Global Exceptions
e_g_fatal_error    exception;

--Targets etc...
e_g_no_tr_found    exception;
e_g_no_pm_found    exception;
e_g_no_pm_known    exception;
e_g_no_tl_found    exception;
e_g_no_tv_found    exception;
e_g_no_pd_found    exception;

--Others...
e_g_no_ff_bg      exception; -- bg for a ff
e_g_no_ff         exception; -- fast formula
e_g_no_bg         exception; -- business group
e_g_no_sg         exception; -- security group
e_g_bad_freq_code exception;
e_g_no_ap         exception; -- application_id for a resp
e_g_bmt_invalid   exception; -- Budget Meas type is not a lookup and hence not valid

--Function specific
e_g_tr_not_populated exception; -- Get_target_rec

e_g_bis_fn_error  exception; -- Error calling a bis function

-- Records

--Record to store the session details
TYPE hri_session_rec_type IS RECORD
       (user_id           NUMBER --fnd_GLOBAL.USER_ID
       ,resp_id           NUMBER
       ,resp_appl_id      NUMBER
       ,security_group_id NUMBER);

--Details of session at start
g_session_rec                hri_session_rec_type;

--Record to store the required Information pertaining to a target
TYPE hri_target_rec_type IS RECORD
      (measure_short_name          bisbv_performance_measures.measure_short_name%TYPE
      ,target_id                   bis_target_values.target_id%TYPE
      ,target_level_id             bisfv_target_levels.target_level_id%TYPE
      ,target_level_short_name     bisfv_target_levels.target_level_short_name%TYPE
      ,measure_id                  bisbv_performance_measures.measure_id%TYPE
      ,plan_id                     bis_target_values.plan_id%TYPE
      ,org_level_short_name        bisfv_target_levels.org_level_short_name%TYPE
      ,org_level_value_id          bisbv_targets.org_level_value_id%TYPE
      ,time_level_value_id         bisbv_targets.time_level_value_id%TYPE
      ,time_level_short_name       bisfv_target_levels.time_level_short_name%TYPE
      ,dim1_level_short_name       bisfv_target_levels.dimension1_level_short_name%TYPE
      ,dim1_level_value_id         bisbv_targets.dim1_level_value_id%TYPE
      ,dim2_level_short_name       bisfv_target_levels.dimension2_level_short_name%TYPE
      ,dim2_level_value_id         bisbv_targets.dim2_level_value_id%TYPE
      ,dim3_level_short_name       bisfv_target_levels.dimension3_level_short_name%TYPE
      ,dim3_level_value_id         bisbv_targets.dim3_level_value_id%TYPE
      ,dim4_level_short_name       bisfv_target_levels.dimension4_level_short_name%TYPE
      ,dim4_level_value_id         bisbv_targets.dim4_level_value_id%TYPE
      ,dim5_level_short_name	   bisfv_target_levels.dimension5_level_short_name%TYPE
      ,dim5_level_value_id         bisbv_targets.dim5_level_value_id%TYPE
      ,unit_of_measure             bisbv_target_levels.unit_of_measure%TYPE
      ,workflow_item_type          bisfv_target_levels.workflow_item_type%TYPE
      ,workflow_process_short_name bisfv_target_levels.workflow_process_short_name%TYPE
      ,target                      bisfv_targets.target%TYPE
      ,range1_low                  bisfv_targets.range1_low%TYPE
      ,range1_high                 bisfv_targets.range1_high%TYPE
      ,range2_low                  bisfv_targets.range2_low%TYPE
      ,range2_high                 bisfv_targets.range2_high%TYPE
      ,range3_low                  bisfv_targets.range3_low%TYPE
      ,range3_high                 bisfv_targets.range3_high%TYPE
      ,notify_resp1_id             fnd_responsibility.responsibility_id%TYPE
      ,notify_resp1_appl_id        fnd_responsibility.application_id%TYPE
      ,notify_resp1_short_name     bisfv_targets.notify_resp1_short_name%TYPE
      ,notify_resp1_name           bisfv_targets.notify_resp1_name%TYPE
      ,notify_resp2_id             fnd_responsibility.responsibility_id%TYPE
      ,notify_resp2_appl_id        fnd_responsibility.application_id%TYPE
      ,notify_resp2_short_name     bisfv_targets.notify_resp2_short_name%TYPE
      ,notify_resp2_name           bisfv_targets.notify_resp2_name%TYPE
      ,notify_resp3_id             fnd_responsibility.responsibility_id%TYPE
      ,notify_resp3_appl_id        fnd_responsibility.application_id%TYPE
      ,notify_resp3_short_name     bisfv_targets.notify_resp3_short_name%TYPE
      ,notify_resp3_name           bisfv_targets.notify_resp3_name%TYPE
     -- ,budget_measurement_type     hr_lookups.lookup_code%TYPE
      ,period_start_DATE	       DATE
      ,period_end_DATE             DATE);

--**********************************************************************
-- COMMON FUNCTIONS AND PROCEDURES
--**********************************************************************

--DEBUG FUNCTIONS--
-------------------------------------------------------------------------
--  pl - put line
--  NOTE all code must be commented out except NULL when delivered
-------------------------------------------------------------------------

PROCEDURE pl(p_text IN VARCHAR2,
             p_text2 IN VARCHAR2 DEFAULT NULL)
 IS

BEGIN
  --dbms_output.put_line(p_text);   -- *** NOTE THIS LINE MUST BE COMMENTED OUT BEFORE RETURNinG TO ARCS
  /*
  INSERT INTO hri.hri_debug
    (text1
    ,text2
    ,insert_date
    )
   VALUES
    (substr(p_text,1,239)
    ,substr(p_text2,1,239)
    ,sysdate
    )
   ;
   COMMIT;
  /**/
  /*
  CREATE TABLE HRI.HRI_DEBUG
  (
    TEXT1       VARCHAR2(240)
   ,TEXT2       VARCHAR2(240)
   ,INSERT_DATE DATE
  );
  /**/
  null;
END;

-------------------------------------------------------------------------
--  debug_hri_target_rec
--
--  UtilISes pl to debug target record
-------------------------------------------------------------------------
PROCEDURE debug_hri_target_rec
           (p_target_rec       IN hri_target_rec_type)
  IS
BEGIN
  pl('HRI TARGET REC => ');
  pl('  measure_short_name',p_target_rec.measure_short_name);
  pl('  target_id',to_char(p_target_rec.target_id));
  pl('  target_level_id',to_char(p_target_rec.target_level_id));
  pl('  indicator_id',to_char(p_target_rec.measure_id));
  pl('  Plan id ',to_char(p_target_rec.plan_id));
  pl('  Org     ',p_target_rec.org_level_short_name);
  pl('  Org id  ',p_target_rec.org_level_value_id);
  pl('  Time    ',p_target_rec.time_level_short_name);
  pl('  Time id ',p_target_rec.time_level_value_id);
  pl('  Dim1    ',p_target_rec.dim1_level_short_name);
  pl('  Dim1 id ',p_target_rec.dim1_level_value_id);
  pl('  Dim2    ',p_target_rec.dim2_level_short_name);
  pl('  Dim2 id ',p_target_rec.dim2_level_value_id);
  pl('  Dim3    ',p_target_rec.dim3_level_short_name);
  pl('  Dim3 id ',p_target_rec.dim3_level_value_id);
  pl('  Dim4    ',p_target_rec.dim4_level_short_name);
  pl('  Dim4 id ',p_target_rec.dim4_level_value_id);
  pl('  Dim5    ',p_target_rec.dim5_level_short_name);
  pl('  Dim5 id ',p_target_rec.dim5_level_value_id);
  pl('  Uom     ',p_target_rec.unit_of_measure);
  pl('  Workflow',p_target_rec.workflow_process_short_name);
  pl('  Range 1 Low',to_char(p_target_rec.RANGE1_LOW));
  pl('  Range 1 High',to_char(p_target_rec.RANGE1_HIGH));
  pl('  Range 2 Low',to_char(p_target_rec.RANGE2_LOW));
  pl('  Range 2 High',to_char(p_target_rec.RANGE2_HIGH));
  pl('  Range 3 Low',to_char(p_target_rec.RANGE3_LOW));
  pl('  Range 3 High',to_char(p_target_rec.RANGE3_HIGH));
 -- pl('  Bdgt M Type ',p_target_rec.budget_measurement_type); Bug 2530846

  pl('  Start date',to_char(p_target_rec.period_start_date));
  pl('  End Date',to_char(p_target_rec.period_END_date));

  pl('  Resp 1 ID',p_target_rec.notify_resp1_id);
  pl('  Resp 1 SN',p_target_rec.notify_resp1_short_name);
  pl('  Resp 1 LN',p_target_rec.notify_resp1_name);
  pl('  Resp 2 ID',p_target_rec.notify_resp2_id);
  pl('  Resp 2 SN',p_target_rec.notify_resp2_short_name);
  pl('  Resp 2 LN',p_target_rec.notify_resp2_name);
  pl('  Resp 3 ID',p_target_rec.notify_resp3_id);
  pl('  Resp 3 SN',p_target_rec.notify_resp3_short_name);
  pl('  Resp 3 LN',p_target_rec.notify_resp3_name);


END debug_hri_target_rec;

-------------------------------------------------------------------------
--  debug_bis_actual_rec
--
--  Utilises pl to debug bis actual record
-------------------------------------------------------------------------
PROCEDURE debug_bis_actual_rec
           (p_actual_rec         IN bis_actual_pub.actual_rec_type)
  IS
BEGIN

  pl('BIS ACTUAL REC => ');
  pl('  Actual ', p_actual_rec.actual);
  pl('  Target Lvl id ', to_char(p_actual_rec.target_level_id));
  pl('  Target Lvl SN ', p_actual_rec.target_level_short_name);
  pl('  Target Lvl LN ', p_actual_rec.target_level_name);
  pl('  Time V ID ',p_actual_rec.time_level_value_id);
  pl('  Time V N ',p_actual_rec.time_level_value_name);
  pl('  Org  V ID ',p_actual_rec.org_level_value_id);
  pl('  Org  V N ',p_actual_rec.org_level_value_name);
  pl('  Dim1 V ID ',p_actual_rec.dim1_level_value_id);
  pl('  Dim1 V N ',p_actual_rec.dim1_level_value_name);
  pl('  Dim2 V ID ',p_actual_rec.dim2_level_value_id);
  pl('  Dim2 V N ',p_actual_rec.dim2_level_value_name);
  pl('  Dim3 V ID ',p_actual_rec.dim3_level_value_id);
  pl('  Dim3 V N ',p_actual_rec.dim3_level_value_name);
  pl('  Dim4 V ID ',p_actual_rec.dim4_level_value_id);
  pl('  Dim4 V N ',p_actual_rec.dim4_level_value_name);
  pl('  Dim5 V ID ',p_actual_rec.dim5_level_value_id);
  pl('  Dim5 V N ',p_actual_rec.dim5_level_value_name);
  pl('  Resp ID ', to_char(p_actual_rec.responsibility_id));
  pl('  Resp SN ', p_actual_rec.responsibility_short_name);
  pl('  Resp LN ', p_actual_rec.responsibility_name);

END debug_bis_actual_rec;
--**********************************************************************
-- PRIVATE FUNCTIONS
--**********************************************************************
------------------------------------------------------------------------
--  Procedure:    Get_Dates_from_Time_Dim
--
--  Parameters:   Target_id
--
--  Description:  Returns the start and end date for the time dimension
------------------------------------------------------------------------
PROCEDURE get_dates_from_time_dim
          (p_time_level_value_id  IN     VARCHAR2
          ,o_period_start_date       OUT NOCOPY DATE
          ,o_period_end_date         OUT  NOCOPY DATE)
 IS
  --
  -- get the target start and end dates
  --
  CURSOR pd_cur (p_c_time_level_value_id VARCHAR2) IS
   SELECT start_date
        , end_date
     FROM bis_hr_months_v
    WHERE id = p_c_time_level_value_id
   UNION
   SELECT start_date
        , end_date
     FROM bis_hr_bimonths_v
    WHERE id = p_c_time_level_value_id
   UNION
   SELECT start_date
        , end_date
     FROM bis_hr_quarters_v
    WHERE id = p_c_time_level_value_id
   UNION
   SELECT start_date
        , end_date
     FROM bis_hr_semiyears_v
    WHERE id = p_c_time_level_value_id
   UNION
   SELECT start_date
        , end_date
     FROM bis_hr_years_v
    WHERE id = p_c_time_level_value_id;

BEGIN

  pl(' Time Level Value ID: ',p_time_level_value_id);
  --
  -- get the target period dates
  --
  OPEN pd_cur(p_time_level_value_id);
  FETCH pd_cur INTO
     o_period_start_date
    ,o_period_end_date;
  IF pd_cur%NOTFOUND THEN
     CLOSE pd_cur;
     RAISE e_g_no_pd_found;
  END IF;
  CLOSE pd_cur;

  pl(' Start Date: ',to_char(o_period_start_date));
  pl(' End Date: '  ,to_char(o_period_end_date));

END;
------------------------------------------------------------------------
--  Procedure:    Get_Target_rec
--
--  RETURN:       HRI_Target_Rec_Type - details derived FROM the target_id
--
--  Parameters:   Target_id
--
--  Description
--                This function queries all the relevant information
--                required concerning the target, including info at these
--                levels:
--                  indicator
--                  target level
--                  target
--                  time dimension calendars
------------------------------------------------------------------------
FUNCTION get_target_rec
          (p_target_id IN NUMBER)
 RETURN hri_target_rec_type
  IS

  --records from the cursors to be deleted
  l_bis_tarlev_rec bisfv_target_levels%rowtype;
  l_bis_target_rec bisfv_targets%rowtype;
  l_target_rec     hri_target_rec_type;

  --
  -- get the performance measure
  --
  CURSOR pm_cur (p_target_level_id IN NUMBER) IS
   SELECT pm.measure_id
        , pm.measure_short_name
     FROM bisbv_performance_measures pm
        , bisbv_target_levels tl
    WHERE pm.measure_id = tl.measure_id
      AND tl.target_level_id = p_target_level_id;
  --
  -- get the target level
  --
  CURSOR tl_cur (p_target_level_id IN NUMBER) IS
   SELECT *
     FROM bisfv_target_levels
    WHERE target_level_id = p_target_level_id;
  --
  -- get the target value
  --
  CURSOR tv_cur (p_target_id  IN NUMBER) IS
   SELECT *
     FROM bisfv_targets trg
    WHERE trg.target_id = p_target_id;

  -- Cursor to verify validity of the budget meaurement type
  -- at least one row returned if valid
  CURSOR  bmt_cur
           (p_c_bmt IN VARCHAR2)
   IS
   SELECT lookup_code
     FROM hr_lookups
    WHERE lookup_type = 'BUDGET_MEASUREMENT_TYPE'
      AND lookup_code = p_c_bmt;

  -- Cursor to obtain fnd_responsibility_id
  -- from role short name and ensure that the
  -- role currently exists as an FND responsibility
  CURSOR resp_id_cur
           (p_c_role_name IN VARCHAR2)
   IS
   SELECT wfr.orig_system_id
        , rsp.application_id
     FROM wf_roles           wfr
        , fnd_responsibility rsp
    WHERE wfr.orig_system_id = rsp.responsibility_id
      AND wfr.name = p_c_role_name
      AND wfr.orig_system like 'FND_RESP%';

------------------------------------------------------
BEGIN
  pl('--------------------');
  pl('*Get Target Rec','Start');
  pl(' Get Target ',to_char(p_target_id));

  --
  -- get the target value for this target
  --
  OPEN tv_cur(p_target_id);
  FETCH tv_cur INTO l_bis_target_rec;
  IF tv_cur%NOTFOUND THEN
    CLOSE tv_cur;
    RAISE e_g_no_tr_found;
  END IF;
  CLOSE tv_cur;
  --
  -- get the target level
  --
  OPEN tl_cur(l_bis_target_rec.target_level_id);
  FETCH tl_cur INTO l_bis_tarlev_rec;
  IF tl_cur%NOTFOUND THEN
     CLOSE tl_cur;
     RAISE e_g_no_tl_found;
  END IF;
  CLOSE tl_cur;
  --
  -- get the performance measure
  --
  OPEN pm_cur(l_bis_target_rec.target_level_id);
  FETCH pm_cur INTO
      l_target_rec.measure_id
     ,l_target_rec.measure_short_name;
  IF pm_cur%NOTFOUND THEN
     CLOSE pm_cur;
     RAISE e_g_no_pm_found;
  END IF;
  CLOSE pm_cur;

  -- FiX FOR BUG 1578137
  --Get the 3 fnd resp ids from the role
  -- and confirm they are FND RESPs
  --Get ROLE 1 ID
  OPEN resp_id_cur (l_bis_target_rec.notify_resp1_short_name);
  FETCH resp_id_cur INTO
     l_target_rec.notify_resp1_id
    ,l_target_rec.notify_resp1_appl_id;
  -- Make sure the ID is NULL
  -- this will be used later as a check whether to verify
  -- whether a responsibility and target has been setup
  -- for role 1
  IF resp_id_cur%NOTFOUND THEN
    l_target_rec.notify_resp1_id := NULL;
  END IF;
  CLOSE resp_id_cur;

  --Get ROLE 2 ID
  OPEN resp_id_cur (l_bis_target_rec.notify_resp2_short_name);
  FETCH resp_id_cur INTO
     l_target_rec.notify_resp2_id
    ,l_target_rec.notify_resp2_appl_id;
  -- Make sure the ID is NULL
  -- this will be used later as a check whether to verify
  -- whether a responsibility and target has been setup
  -- for role 2
  IF resp_id_cur%NOTFOUND THEN
    l_target_rec.notify_resp2_id := NULL;
  END IF;
  CLOSE resp_id_cur;

  --Get ROLE 3 ID
  OPEN resp_id_cur (l_bis_target_rec.notify_resp3_short_name);
  FETCH resp_id_cur INTO
     l_target_rec.notify_resp3_id
    ,l_target_rec.notify_resp3_appl_id;
  -- Make sure the ID is NULL
  -- this will be used later as a check whether to verify
  -- whether a responsibility and target has been setup
  -- for role 3
  IF resp_id_cur%NOTFOUND THEN
    l_target_rec.notify_resp3_id := NULL;
  END IF;
  CLOSE resp_id_cur;

  --
  -- get the target period dates
  --
  get_dates_from_time_dim
    (l_bis_target_rec.time_level_value_id
    ,l_target_rec.period_start_date
    ,l_target_rec.period_end_date);

  --
  -- copy the target dimensions to the target record. This will be passed as a parameter
  -- to the calculate actuals procedure
  --

  --  measure_short_name  and id - done
  l_target_rec.target_id                   := p_target_id;
  l_target_rec.target_level_id             := l_bis_tarlev_rec.target_level_id;
  l_target_rec.target_level_short_name     := l_bis_tarlev_rec.target_level_short_name;

  l_target_rec.plan_id                     := l_bis_target_rec.plan_id;
  l_target_rec.org_level_short_name        := l_bis_tarlev_rec.org_level_short_name;
  l_target_rec.org_level_value_id          := l_bis_target_rec.org_level_value_id;
  l_target_rec.time_level_value_id         := l_bis_target_rec.time_level_value_id;
  l_target_rec.time_level_short_name       := l_bis_tarlev_rec.time_level_short_name;
  l_target_rec.dim1_level_short_name       := l_bis_tarlev_rec.dimension1_level_short_name;
  l_target_rec.dim1_level_value_id         := l_bis_target_rec.dim1_level_value_id;
  l_target_rec.dim2_level_short_name       := l_bis_tarlev_rec.dimension2_level_short_name;
  l_target_rec.dim2_level_value_id         := l_bis_target_rec.dim2_level_value_id;
  l_target_rec.dim3_level_short_name       := l_bis_tarlev_rec.dimension3_level_short_name;
  l_target_rec.dim3_level_value_id         := l_bis_target_rec.dim3_level_value_id;
  l_target_rec.dim4_level_short_name       := l_bis_tarlev_rec.dimension4_level_short_name;
  l_target_rec.dim4_level_value_id         := l_bis_target_rec.dim4_level_value_id;
  l_target_rec.dim5_level_short_name       := l_bis_tarlev_rec.dimension5_level_short_name;
  l_target_rec.dim5_level_value_id         := l_bis_target_rec.dim5_level_value_id;
  l_target_rec.unit_of_measure             := l_bis_tarlev_rec.unit_of_measure;
  l_target_rec.workflow_item_type          := l_bis_tarlev_rec.workflow_item_type;
  l_target_rec.workflow_process_short_name := l_bis_tarlev_rec.workflow_process_short_name;
  l_target_rec.target                      := l_bis_target_rec.target;
  l_target_rec.range1_low                  := l_bis_target_rec.range1_low;
  l_target_rec.range1_high                 := l_bis_target_rec.range1_high;
  l_target_rec.range2_low                  := l_bis_target_rec.range2_low;
  l_target_rec.range2_high                 := l_bis_target_rec.range2_high;
  l_target_rec.range3_low                  := l_bis_target_rec.range3_low;
  l_target_rec.range3_high                 := l_bis_target_rec.range3_high;
  l_target_rec.notify_resp1_short_name     := l_bis_target_rec.notify_resp1_short_name;
  l_target_rec.notify_resp1_name           := l_bis_target_rec.notify_resp1_name;
  l_target_rec.notify_resp2_short_name     := l_bis_target_rec.notify_resp2_short_name;
  l_target_rec.notify_resp2_name           := l_bis_target_rec.notify_resp2_name;
  l_target_rec.notify_resp3_short_name     := l_bis_target_rec.notify_resp3_short_name;
  l_target_rec.notify_resp3_name           := l_bis_target_rec.notify_resp3_name;

  -- Get the Budget Meas Type
  --  Required for:
  --  1) Key to ABV if exists
  --  2) Compiling name of budget FF

  -- Can't use uom because that is translated and is un-reliable
  -- If the measure is
  --  manpower variance, manpower separation or recruitment
  -- then a budget is required
  --  otherwise set it to null
  IF l_target_rec.measure_short_name
       IN ('HRMSPFTE','HRMSPHEAD'
          ,'HRMVRFTE','HRMVRHEAD'
          ,'HRRCSFTE','HRRCSHEAD')
    THEN
    -- Best way to find budget code is to strip it from the measure name
    --  measure name composed <APP Name(2 Char)><Measure type(4 Char)><Budget Type>
    --  I don't like this because the code could have spaces in it,
    --  could be v long and relies on the code representing the budget!!
    OPEN bmt_cur(substr(l_target_rec.measure_short_name,6));
    -- Bug 2530846 replacing use of budget_measurement_type with Unit_of_measure
    FETCH bmt_cur INTO l_target_rec.unit_of_measure;
    IF bmt_cur%NOTFOUND THEN
      CLOSE bmt_cur;
      pl(' Budget Measurement Type not valid :', substr(l_target_rec.measure_short_name,6));
      RAISE e_g_bmt_invalid;
    END IF;
    CLOSE bmt_cur;

  ELSE
    -- Bug 2530846 replacing use of budget_measurement_type with Unit_of_measure
    l_target_rec.unit_of_measure   := to_char(NULL);
  END IF;

  --debug_hri_target_rec(l_target_rec);

  pl('*Get Target Rec','End');
  pl('--------------------');
  RETURN l_target_rec;


EXCEPTION
  WHEN e_g_no_tr_found THEN
    pl('*Get Target Rec','NO TR Exception - End');
    RAISE e_g_tr_not_populated;
  WHEN e_g_no_pm_found THEN
    pl('*Get Target Rec','NO PM Exception - End');
    RAISE e_g_tr_not_populated;
  WHEN e_g_no_tl_found THEN
    pl('*Get Target Rec','NO TL Exception - End');
    RAISE e_g_tr_not_populated;
  WHEN e_g_no_tv_found THEN
    pl('*Get Target Rec','NO TV Exception - End');
    RAISE e_g_tr_not_populated;
  WHEN e_g_no_pd_found THEN
    pl('*Get Target Rec','NO PD Exception - End');
    RAISE e_g_tr_not_populated;
  WHEN e_g_bmt_invalid THEN
    pl('*Get Target Rec','BMT Invalid Exception - End');
    RAISE e_g_tr_not_populated;
  WHEN OTHERS THEN
    pl('*Get Target Rec','Other Exception - End');
    RAISE e_g_tr_not_populated;

END Get_Target_rec;
------------------------------------------------------------------------
--  Function:     Get_bis_actual_rec
--
--  RETURN:       bis_actual_pub.actual_rec_type
--
--  Description:  This function returns the data in the bis actual
--                record format required for calculating the actuals
--
------------------------------------------------------------------------
FUNCTION get_bis_actual_rec
           (p_target_rec   IN     hri_target_rec_type)
  RETURN
   bis_actual_pub.actual_rec_type
  IS

  l_actual_rec  bis_actual_pub.actual_rec_type;

BEGIN
  l_actual_rec.target_level_id           := p_target_rec.target_level_id;
  l_actual_rec.target_level_short_name   := p_target_rec.target_level_short_name;
  --l_actual_rec.target_level_name         := p_target_rec.target_level_name;
  l_actual_rec.time_level_value_id       := p_target_rec.time_level_value_id;
  l_actual_rec.time_level_value_name     := p_target_rec.time_level_short_name;
  l_actual_rec.org_level_value_id        := p_target_rec.org_level_value_id;
  l_actual_rec.org_level_value_name      := p_target_rec.org_level_short_name;
  l_actual_rec.dim1_level_value_id       := p_target_rec.dim1_level_value_id;
  l_actual_rec.dim1_level_value_name     := p_target_rec.dim1_level_short_name;
  l_actual_rec.dim2_level_value_id       := p_target_rec.dim2_level_value_id;
  l_actual_rec.dim2_level_value_name     := p_target_rec.dim2_level_short_name;
  l_actual_rec.dim3_level_value_id       := p_target_rec.dim3_level_value_id;
  l_actual_rec.dim3_level_value_name     := p_target_rec.dim3_level_short_name;
  l_actual_rec.dim4_level_value_id       := p_target_rec.dim4_level_value_id;
  l_actual_rec.dim4_level_value_name     := p_target_rec.dim4_level_short_name;
  l_actual_rec.dim5_level_value_id       := p_target_rec.dim5_level_value_id;
  l_actual_rec.dim5_level_value_name     := p_target_rec.dim5_level_short_name;
  --l_actual_rec.responsibility_id         := p_target_rec.responsibility_id;
  --l_actual_rec.responsibility_short_name := p_target_rec.responsibility_short_name;
  --l_actual_rec.responsibility_name       := p_target_rec.responsibility_name;

  RETURN l_actual_rec;

END get_bis_actual_rec;
------------------------------------------------------------------------
--  Procedure:    Get_Session
--
--  RETURN:       HRI_Session_Rec_Type - details of session
--
--  Parameters:   None session is setup of global variables
--
--  Description
--                This function queries all the relevant information
--                required concerning the current session allowing the
--                session to be recreated exactly. includes:
--                  USER
--                  Responsibility
--
------------------------------------------------------------------------
FUNCTION get_session
 RETURN HRI_Session_Rec_Type
 IS
  l_session_rec hri_session_rec_type;

BEGIN
  l_session_rec.user_id           :=  fnd_global.user_id;
  l_session_rec.resp_id           :=  fnd_global.resp_id;
  l_session_rec.resp_appl_id      :=  fnd_global.resp_appl_id;
  l_session_rec.security_group_id :=  fnd_global.security_group_id;

  RETURN l_session_rec;

END get_session;
------------------------------------------------------------------------
--  Procedure:    set_session
--
--  Parameters:   HRI_Session_Rec_Type
--
--  Description
--                This function recreates session specIFied IN Session
--                Rec.
--                  USER
--                  Responsibility
--
------------------------------------------------------------------------
PROCEDURE set_session
            (p_session_rec IN  hri_session_rec_type)
 IS
BEGIN

  fnd_global.apps_initialize
     (p_session_rec.user_id
     ,p_session_rec.resp_id
     ,p_session_rec.resp_appl_id
     ,p_session_rec.security_group_id
     );

END set_session;

PROCEDURE debug_session
            (p_session_rec IN hri_session_rec_type)
 IS
BEGIN
  pl(' Session USER_ID',to_char(p_session_rec.user_id));
  pl(' Session RESP_ID',to_char(p_session_rec.resp_id));
  pl(' Session resp_appl_id',to_char(p_session_rec.resp_appl_id));
  pl(' Session security_group_id',to_char(p_session_rec.security_group_id));
END debug_session;
-------------------------------------------------------------------------
--  hr_budget
-------------------------------------------------------------------------
--
-- This is function is required  for targets where the target value is
-- obtained from the database and not entered by the user. An example of
-- this is manpower variance where the target value is obtained from a
-- HR budget.
--
--
FUNCTION hr_budget(p_rec IN bis_target_pub.target_rec_type) RETURN NUMBER IS

BEGIN
  RETURN 1;
END;

-------------------------------------------------------------------------
--  Calculate percentage
-------------------------------------------------------------------------

FUNCTION percent(p_target IN NUMBER, p_percent IN NUMBER) RETURN NUMBER IS

BEGIN
  RETURN (p_target/100)*nvl(p_percent,0);
END;


--**********************************************************************
-- TEXT TRANSLATIONS
--**********************************************************************

-------------------------------------------------------------------------
-- Translate All
-------------------------------------------------------------------------


function translate_all RETURN VARCHAR2 IS
BEGIN
  fnd_message.set_name ('HRI','HR_BIS_ALL');
  RETURN fnd_message.get;
END;


-------------------------------------------------------------------------
-- Translate Location
-------------------------------------------------------------------------

function translate_location(p_location_id IN NUMBER) RETURN VARCHAR2 IS
BEGIN
 IF p_location_id = -1 THEN
   RETURN translate_all;
 ELSE
   RETURN hr_general.decode_location(p_location_id);
 END IF;
END;

-------------------------------------------------------------------------
-- Translate Job
-------------------------------------------------------------------------
-- This function accepts the job ID as a parameter and will RETURN the
-- job name. IF the job id is -1 THEN 'All' is RETURNed.
--
FUNCTION translate_job(p_job_id IN NUMBER) RETURN VARCHAR2 IS
BEGIN
 IF p_job_id = -1 THEN
   RETURN translate_all;
 ELSE
   RETURN hr_reports.get_job(p_job_id);
 END IF;
END;


-------------------------------------------------------------------------
-- Translate Job Category
-------------------------------------------------------------------------
-- This function accepts the job category ID as a parameter and will return the
-- name of the job category. IF the job category id is -1 then 'All' is returned.
--
FUNCTION translate_job_category(p_jobcat_id IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
 IF p_jobcat_id = '-1' THEN
   RETURN translate_all;
 ELSE
   RETURN hr_reports.get_lookup_meaning('JOB_CATEGORIES',p_jobcat_id);
 END IF;
END;


-------------------------------------------------------------------------
-- Translate include Subordinate indicator
-------------------------------------------------------------------------

FUNCTION translate_orgprc(p_orgprc IN VARCHAR2) RETURN VARCHAR2 IS

  l_text hr_lookups.meaning%TYPE;

BEGIN
  IF p_orgprc = 'SINR' THEN
     l_text := Hr_General.Decode_Lookup('YES_NO','N');
  ELSIF p_orgprc = 'SINR' THEN
     l_text := Hr_General.Decode_Lookup('YES_NO','Y');
  ELSE
     l_text := '';
  END IF;
  RETURN l_text;
END;

-------------------------------------------------------------------------
-- Get Activity Version Name
-------------------------------------------------------------------------

FUNCTION get_activity_version_name
          (p_activity_version_id IN NUMBER)
 RETURN VARCHAR2
 IS

 l_activity_version_name ota_activity_versions.version_name%TYPE;

 CURSOR av_cur (p_activity_version_id IN NUMBER) IS
 SELECT version_name
   FROM ota_activity_versions
  WHERE activity_version_id = p_activity_version_id;


BEGIN

 IF p_activity_version_id = -1 THEN
    l_activity_version_name := translate_all;
 ELSE
    OPEN av_cur(p_activity_version_id);
    FETCH av_cur INTO l_activity_version_name;
    CLOSE av_cur;
 END IF;

 RETURN l_activity_version_name;

END;

-------------------------------------------------------------------------
--
--  Function:    ORG_SECURITY_GROUP
--
--
--  Descrition:  Get the security group of the target organzation.
--               This is required as a parametr when calling
--               apps_initialize and as a parameter on the report url.
--
-------------------------------------------------------------------------
FUNCTION get_org_security_group_id
          (p_organization_id IN NUMBER)
 RETURN NUMBER
 IS

   l_security_group_id per_business_groups.security_group_id%TYPE; --Varchar2
  --
  -- get the security group id
  --
  CURSOR sg_cur(p_organization_id IN VARCHAR2) IS
  SELECT b.security_group_id
    FROM per_business_groups b
       , hr_all_organization_units o
   where o.business_group_id = b.business_group_id
     AND o.organization_id = p_organization_id;

BEGIN

 pl('*Get_org_security_group_id','Start');
 pl(' org_id',to_char(p_organization_id));

 OPEN sg_cur(p_organization_id);
 FETCH sg_cur INTO l_security_group_id;
 IF sg_cur%NOTFOUND THEN
    CLOSE sg_cur;
    RAISE e_g_no_sg;
 END IF;
 CLOSE sg_cur;

 pl(' security_group_id',l_security_group_id);
 pl('*Get_org_security_group_id','End');
 RETURN to_number(l_security_group_id);

END get_org_security_group_id;
-------------------------------------------------------------------------
--
--  VALIDATE THE RESPONSIBLITIES ORGANIZATION SECURITY
--
-------------------------------------------------------------------------
--
-- Verify that notify responsibility is authorized to access details from
-- the target organization. If the responsibility does not have access to
-- the organization processing will be aborted.
-------------------------------------------------------------------------
FUNCTION validate_resp_org_security
          (p_responsibility_id   IN fnd_responsibility.responsibility_id%TYPE
          ,p_application_id      IN fnd_responsibility.application_id%TYPE
          ,p_organization_id     IN hr_all_organization_units.organization_id%TYPE)
 RETURN BOOLEAN
 IS

  l_dummy        NUMBER;
  l_status       boolean;

  l_business_group_id           per_business_groups.business_group_id%TYPE;
  l_security_group_id           NUMBER; -- Not per_business_groups.security_group_id%TYPE this is varchar2
  l_org_structure_version_id 	per_org_structure_versions.org_structure_version_id%TYPE;

  -- Holds the session at the start of the function
  --  used to return the session back to original
  l_session_rec                 hri_session_rec_type;

  --
  -- OH_CUR ORGANIZATION IN HIERARCHY
  --
  CURSOR oh_cur(p_org_structure_version_id IN NUMBER
               ,p_organization_id          IN NUMBER) IS
   SELECT  1
     FROM  per_org_structure_elements ose
     WHERE ose.org_structure_version_id     = p_org_structure_version_id
      AND (ose.organization_id_child        = p_organization_id
            or ose.organization_id_parent   = p_organization_id
          ) ;

BEGIN

  pl('*Validate Resp Org Security', 'Start');
   -- Get current session
  l_session_rec := get_session;
  pl('Session changed at start: ');
  debug_session(l_session_rec);

  pl(' Alert - Responsibility id: ',to_char(p_responsibility_id));
  pl(' Alert - Organization id: ',to_char(p_organization_id));
  pl(' Alert - Resp Appl id: ',to_char(p_application_id));

  l_security_group_id := get_org_security_group_id(p_organization_id);

  pl(' Alert - Security Group id: ',to_char(l_security_group_id));
  --
  -- Changes the session globals
  -- and get the business group and organization structure version id

  -- NOTE:
  -- Solution to issues in bug 1413300 (not inserting into actuals table)
  -- USER_ID can not be NULL because of issues of inserting a value into a NOT NULL column
  -- USER_ID can not be -1 because of condition in HR_GENERAL.Get_Business_Group
  -- Using -2
  hrFastAnswers.initialize
  		(-2
  		,p_responsibility_id
  		,p_application_id
  		,l_business_group_id
  		,l_org_structure_version_id
        ,l_security_group_id);

  pl(' Alert - Business group id: ',to_char(l_business_group_id));
  pl(' Alert - Org structure version id: ',to_char(l_org_structure_version_id));
  --put out current session for debug purposes
  pl('Session changed to: ');
  debug_session(get_session);

  --
  -- check that the organization is part of the responsibilities hierarchy
  --

  OPEN oh_cur (l_org_structure_version_id
              ,p_organization_id);
  FETCH oh_cur INTO l_dummy;
  IF oh_cur%NOTFOUND THEN
    l_status := FALSE;
    pl('False');
  ELSE
    l_status := TRUE;
    pl('True');
  END IF;
  CLOSE oh_cur;

  --Return the session back to original
  set_session(l_session_rec);
  pl('Session returned to conditions at start: ');
  debug_session(l_session_rec);

  pl('*Validate Resp Org Security', 'End');

  RETURN l_status;

END validate_resp_org_security;

-------------------------------------------------------------------------
--
--  PROCEDURE:     get resp details
--  Parameter:     p_resp_no
--                 p_target_rec  - hri target record type
--  Return params  o_resp_id
--                 o_resp_short_name
--                 o_resp_name
--
--  Description:   Simplet Proc to cut down coding.
--                 Returns the appropriate resp detail columns for a
--                 resp number.  Resp number corresponds to the target
--                 responsibility number.
-------------------------------------------------------------------------
PROCEDURE get_resp_details
            (p_resp_no          IN  NUMBER
            ,p_target_rec       IN  hri_target_rec_type
            ,o_resp_id          OUT NOCOPY fnd_responsibility.responsibility_id%TYPE
            ,o_resp_appl_id     OUT NOCOPY fnd_responsibility.application_id%TYPE
            ,o_resp_short_name  OUT NOCOPY bisfv_targets.notify_resp1_short_name%TYPE
            ,o_resp_name        OUT NOCOPY bisfv_targets.notify_resp1_name%TYPE)
 IS
BEGIN
  IF p_resp_no = 1 THEN
    o_resp_id          := p_target_rec.notify_resp1_id;
    o_resp_appl_id     := p_target_rec.notify_resp1_appl_id;
    o_resp_short_name  := p_target_rec.notify_resp1_short_name;
    o_resp_name        := p_target_rec.notify_resp1_name;
  ELSIF p_resp_no = 2 THEN
    o_resp_id          := p_target_rec.notify_resp2_id;
    o_resp_appl_id     := p_target_rec.notify_resp2_appl_id;
    o_resp_short_name  := p_target_rec.notify_resp2_short_name;
    o_resp_name        := p_target_rec.notify_resp2_name;
  ELSIF p_resp_no = 3 THEN
    o_resp_id          := p_target_rec.notify_resp3_id;
    o_resp_appl_id     := p_target_rec.notify_resp3_appl_id;
    o_resp_short_name  := p_target_rec.notify_resp3_short_name;
    o_resp_name        := p_target_rec.notify_resp3_name;
  ELSE
    RAISE no_data_found;
  END IF;

END get_resp_details;
-------------------------------------------------------------------------
--
--  FUNCTION:      FREQUENCY_CODE
--  Description:   This procedure returns the name of the time
--                 dimension and the equivalent HR frequency
--
--  Parameter:     p_time_short_name - freq. name HR BIS dim code
--
--  Return:        frequency code from FREQUENCY lookup
--
-------------------------------------------------------------------------

FUNCTION frequency_code (p_time_short_name IN VARCHAR2)
 RETURN VARCHAR2
 IS

  l_frequency VARCHAR2(2);

BEGIN

  IF p_time_short_name = 'HR MONTH' THEN
   l_frequency := 'CM';
  ELSIF p_time_short_name = 'HR BIMONTH' THEN
   l_frequency := 'BM';
  ELSIF p_time_short_name = 'HR QUARTER' THEN
   l_frequency := 'Q';
  ELSIF p_time_short_name = 'HR SEMIYEAR' THEN
   l_frequency := 'SY';
  ELSIF p_time_short_name = 'HR YEAR' THEN
   l_frequency := 'Y';
  ELSE
    RAISE e_g_bad_freq_code;
  END IF;

  RETURN l_frequency;

END frequency_code;

-------------------------------------------------------------------------
--
--  PROCEDURE:     get_report_date_params
--
--  Description:   This procedure returns the report start date and freq
--                 code for the time short name and period start
--                 date.
--
-------------------------------------------------------------------------
PROCEDURE get_report_date_params
          (p_time_level_short_name IN     VARCHAR2
          ,p_period_start_date     IN     DATE
          ,o_freq_code                OUT NOCOPY VARCHAR2
          ,o_start_date               OUT NOCOPY VARCHAR2)
 IS
  l_freq              VARCHAR2(2);
  l_report_start_date DATE;

BEGIN

  l_freq := frequency_code(p_time_level_short_name);

  IF l_freq = 'CM' THEN
    l_report_start_date  := add_months(p_period_start_date,-12);
  ELSIF l_freq = 'BM' THEN
    l_report_start_date  := add_months(p_period_start_date,-12);
  ELSIF l_freq = 'Q' THEN
    l_report_start_date  := add_months(p_period_start_date,-24);
  ELSIF l_freq = 'SY' THEN
    l_report_start_date  := add_months(p_period_start_date,-24);
  ELSIF l_freq = 'Y' THEN
    l_report_start_date  := add_months(p_period_start_date,-48);
  END IF;

  pl('frequency: ',l_freq);
  pl('start date: ',to_char(l_report_start_date,'DD-MON-YYYY'));

  o_freq_code  := l_freq;
  o_start_date := l_report_start_date;

END get_report_date_params;

-------------------------------------------------------------------------
--                                                                     --
--  FUNCTION:     GET_FORMULA_ID                                       --
--                                                                     --
-------------------------------------------------------------------------
FUNCTION get_formula_id
		(p_business_group_id IN NUMBER
		,p_budget_type       IN VARCHAR2)
 RETURN ff_formulas.formula_id%TYPE
 IS

  CURSOR formula_cur
          (p_c_business_group_id NUMBER
          ,p_c_formula_name      VARCHAR2)
   IS
   SELECT formula_id
     FROM ff_formulas_f
    WHERE ( (p_c_business_group_id IS null
              AND business_group_id IS null )
            OR
           p_c_business_group_id = business_group_id
          )
      AND trunc(sysdate) BETWEEN
            effective_start_date AND effective_end_date
      AND formula_name = p_c_formula_name;

  l_formula_id ff_formulas.formula_id%TYPE;

BEGIN
  pl('*Get Formula id','Start');
  pl('  Budgt Type : ', p_budget_type);

  IF p_budget_type IN ('FTE','HEAD') THEN
   OPEN formula_cur(p_business_group_id
                   ,'BUDGET_'||p_budget_type);
   FETCH formula_cur INTO l_formula_id;
   IF formula_cur%NOTFOUND THEN
     pl(' Custom ff not found: ','BUDGET_'||p_budget_type);
     CLOSE formula_cur;
     OPEN formula_cur(NULL
                     ,'TEMPLATE_'||p_budget_type);
     FETCH formula_cur INTO l_formula_id;
       IF formula_cur%NOTFOUND THEN
         CLOSE formula_cur;
         RAISE e_g_no_ff;
       END IF;
     CLOSE formula_cur;
   ELSE
     CLOSE formula_cur;
   END IF;

  -- IF the fast formula was not an FTE or HEAD FF then
  ELSE
   OPEN formula_cur(p_business_group_id
                   ,p_budget_type);
   FETCH formula_cur INTO l_formula_id;
   IF formula_cur%NOTFOUND THEN
     pl(' Custom ff not found: ',p_budget_type);
     CLOSE formula_cur;
     OPEN formula_cur(null
                     ,'TEMPLATE_'||p_budget_type);
     FETCH formula_cur INTO l_formula_id;
       IF formula_cur%NOTFOUND THEN
         CLOSE formula_cur;
         RAISE e_g_no_ff;
       END IF;
     CLOSE formula_cur;
   ELSE
     CLOSE formula_cur;
   END IF;
  END IF;
  RETURN l_formula_id;

EXCEPTION
  WHEN e_g_no_ff THEN
    pl('*Get Formula',' Exception - No FF Found - End');
    RAISE e_g_no_ff;

END get_formula_id;

-------------------------------------------------------------------------
--
--  FUNCTION:     get_ORG_BUSINESS_GROUP_id(p_org_id)
--
--  Parameters    organization id
--
--  RETURNs       business group id
--
--  Description:  This function returns the business group of a given
--                organization. the function is used when posting
--                actuals as the business group is required when
--                getting the fast formula id. The fast formula ID IS
--                required when calculating the assignmnet budget
--                measurement value.
--
-------------------------------------------------------------------------

FUNCTION get_org_business_group_id
          (p_org_id IN NUMBER)
 RETURN NUMBER
 IS
--
-- This cursor gets the organizations business group
--
CURSOR c_bg_id
       (p_c_org_id NUMBER)
 IS
  SELECT business_group_id
    FROM hr_all_organization_units
   WHERE sysdate
          BETWEEN date_from
              AND nvl(date_to, hr_general.end_of_time)
     AND organization_id = p_c_org_id;

l_business_group_id  hr_all_organization_units.business_group_id%TYPE;

BEGIN

  pl('*Get Org Business Group id','Start');
  pl('p_org_id',to_char(p_org_id));
  OPEN c_bg_id(p_org_id);
  FETCH c_bg_id INTO l_business_group_id;
  pl('p_org_id',to_char(l_business_group_id));
  IF c_bg_id%NOTFOUND THEN
    CLOSE c_bg_id;
    pl('raise e_g_no_bg');
    RAISE e_g_no_bg;
   END IF;
  CLOSE c_bg_id;
  pl('Business Group id',to_char(l_business_group_id));
  pl('*Get Org Business Group id','End');
  RETURN l_business_group_id;

END get_org_business_group_id;
-------------------------------------------------------------------------
--
--  Post Actuals
--
-------------------------------------------------------------------------
PROCEDURE post_actual
           (p_actual_rec IN bis_ACTUAL_PUB.Actual_Rec_Type)
 IS

 x_error_Tbl     bis_UTILITIES_PUB.Error_Tbl_Type;
 x_msg_count     NUMBER;
 x_msg_data      VARCHAR2(30);
 x_return_status VARCHAR2(30);

 l_Measure_short_name bis_indicators.short_name%TYPE;

BEGIN

  pl('*Post Actual','Start');

  debug_bis_actual_rec(p_actual_rec);

  IF p_actual_rec.actual IS NOT NULL THEN
    pl(' Posting actual...');
    bis_ACTUAL_PUB.Post_Actual( p_api_version   => 1.0
                              , p_commit        => FND_API.G_TRUE
                              , p_Actual_Rec    => p_actual_rec
                              , x_return_status => x_return_status
                              , x_msg_count     => x_msg_count
                              , x_msg_data      => x_msg_data
                              , x_error_Tbl     => x_error_Tbl);

    IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
      RAISE e_g_bis_fn_error;
    END IF;
    pl(' BIS Post actual return status ', x_return_status);
  END IF;

  pl('*Post Actual','End');

EXCEPTION
  WHEN OTHERS THEN
    -- carry on because this may be called many times
    pl('*Post Actual','Exception Raised - End');

END;
-------------------------------------------------------------------------
-- ********************************************************************
-------------------------------------------------------------------------
-- *********************************************************************
--
--                        START OF PMF DEFINITIONS
--
-- *********************************************************************
-------------------------------------------------------------------------
-- *********************************************************************
-------------------------------------------------------------------------

-- **********************************************************************
--
--                M A N P O W E R   S E P A R A T I O N S
--
-- **********************************************************************

-------------------------------------------------------------------------
-- SEND MANPOWER SEPARATION notification
-------------------------------------------------------------------------
-- This procedure is called when the actual manpower separations exceed
-- the target value. The procedure will build the notification message
-- text, which includes a hypertext link to run the manpower losses report,
-- and will then pass the notification to the workflow engine for
-- dIStribution.
--
PROCEDURE send_notification_hrmsp
           (p_resp_no     IN NUMBER
           ,p_target      IN NUMBER
           ,p_actual      IN NUMBER
           ,p_target_rec  IN hri_target_rec_type)
 IS

l_bmt_name	      hr_lookups.meaning%TYPE;
l_dummy           VARCHAR2(2000);
l_freq_code       VARCHAR2(4);
l_subject         fnd_new_messages.message_text%TYPE;
l_message         VARCHAR2(2000);
l_org_name        per_organization_units.name%TYPE;
l_period_name     VARCHAR2(50);
l_param           VARCHAR2(2000);
l_report_name     VARCHAR2(8) := 'HRMNPLOS';
l_return_status   VARCHAR2(2000);

l_start_date      DATE;

l_error           VARCHAR2(2000);

-- Session params
l_security_group_id  per_business_groups.security_group_id%TYPE;
l_business_group_id  hr_all_organization_units.business_group_id%TYPE;
l_resp_id            fnd_responsibility.responsibility_id%TYPE;
l_resp_short_name    bisfv_targets.notify_resp1_short_name%TYPE;
l_resp_name          bisfv_targets.notify_resp1_name%TYPE;
l_resp_appl_id       fnd_responsibility.application_id%TYPE;

l_formula_id         ff_formulas_f.formula_id%TYPE;

BEGIN
  pl('----------------------------------');
  pl('*SEND MPS notification','Start');
  pl('----------------------------------');
  -----------------------------------------------------------------------
  -- Build the notification subject line and message text
  -----------------------------------------------------------------------
  --
  -- Get the following information that will be shown on the notification
  -- and populate the relevant tokens in the message HR_BIS_PMF_SUBJECT
  --
  -- 1. Get Session parameters for the report
  -- 2. Get Parameter Names:
  --    Organzation
  --    Budget Measurement Type
  --    Period
  -- 3. build notification text
  -- 4. get the report frequency, number of periods and start date
  -- 5. build the report parameter string
  -- 6. start the workflow process
  --
  -- ---------------------------------------------------------------------
  -- 1. Get Session parameters for the report
  -- ---------------------------------------------------------------------
  get_resp_details(p_resp_no
                  ,p_target_rec
                  ,l_resp_id
                  ,l_resp_appl_id
                  ,l_resp_short_name
                  ,l_resp_name);
  l_business_group_id := get_org_business_group_id(p_target_rec.org_level_value_id);
  l_security_group_id := get_org_security_group_id(p_target_rec.org_level_value_id);
  -- ---------------------------------------------------------------------
  -- 2. Get the parameter names
  -- ---------------------------------------------------------------------
  --
  -- Organization
  --
  hr_reports.get_organization(p_target_rec.org_level_value_id
                             ,l_org_name
                             ,l_dummy);
  pl(' org name : ',l_org_name);
  --
  -- Budget Name
  --
  -- Bug 2530846 replacing use of budget_measurement_type with Unit_of_measure
  l_bmt_name := hr_reports.get_lookup_meaning('BUDGET_MEASUREMENT_TYPE'
                                             ,p_target_rec.unit_of_measure);
  pl(' bmt name : ',l_bmt_name);
  --
  -- Period Name
  --
  l_period_name := to_char(p_target_rec.period_start_date,'DD-MON-YYYY')
                           ||' - '||to_char(p_target_rec.period_END_date,'DD-MON-YYYY');
  pl(' period name :',l_period_name);
  -- ---------------------------------------------------------------------
  -- 3. Build the notification text
  -- ---------------------------------------------------------------------
  --
  -- Build subject message text
  --
  fnd_message.set_name('HRI','HR_BIS_PMF_HRMSP_SUBJECT');
  l_subject := fnd_message.get;
  --
  -- Build the body message text
  --
  fnd_message.set_name('HRI','HR_BIS_PMF_HRMSP_MSG');
  fnd_message.set_token('ORGANIZATION',l_org_name);
  fnd_message.set_token('PERIOD', l_period_name);
  fnd_message.set_token('BUDGET',l_bmt_name);
  fnd_message.set_token('TARGET',p_target);
  fnd_message.set_token('ACTUAL',p_actual);
  --fnd_message.set_token('ROLE',l_resp_name);
  l_message := fnd_message.get;
  pl(' Message:',l_message);
  -- ---------------------------------------------------------------------
  -- 4. build the report parameter string
  -- ---------------------------------------------------------------------
  -- Build the url that will be used to run the report from the
  -- notification.
  l_report_name := 'HRMNPLOS';

  get_report_date_params(p_target_rec.time_level_short_name
                        ,p_target_rec.period_start_date
                        ,l_freq_code
                        ,l_start_date);
  pl(' Frequency: ',l_freq_code);
  pl(' Start date: ',to_char(l_start_date,'DD-MON-YYYY'));

  -- Added formula id as Workforce Losses requires it for fast formula
  -- Bug 2530846
  l_formula_id := get_formula_id(l_business_group_id
                                ,p_target_rec.unit_of_measure);
  pl(' Formula_id: ',to_char(l_formula_id));


  -- Bug 2530846 replacing use of budget_measurement_type with Unit_of_measure
  l_param := 'org_id='        ||p_target_rec.org_level_value_id   ||'*'||
             'orgprc='        ||g_orgprc_const                    ||'*'||
             'bpl_id='        ||p_target_rec.plan_id        ||'*'||
             'bgttyp='        ||p_target_rec.unit_of_measure||'*'||
             'bus_id='        ||to_char(l_business_group_id)||'*'||
             'formul='        ||to_char(l_formula_id)       ||'*'||
             'frqncy='        ||l_freq_code                 ||'*'||
             'geolvl=1*'      ||
             'geoval=-1*'     ||
             'job_id=-1*'     ||
             'jobcat=__ALL__*'||
             'prodid=-1*'     ||
             'startd='        ||to_char(l_start_date,'YYYY-MM-DD')||'*'||
             'end_dt='        ||to_char(p_target_rec.period_end_date,'YYYY-MM-DD')  ||'*'||
             'viewby=HR_BIS_TIME*'||
                       c_ampersand||'responsibility_application_id='
                                  ||to_char(l_resp_appl_id)||
  	                   c_ampersand||'security_group_id='
                                  ||l_security_group_id;

  pl('wf      ',p_target_rec.workflow_item_type);
  pl('process ',p_target_rec.workflow_process_short_name);
  pl('resp    ',l_resp_short_name);
  pl('resp id ',to_char(l_resp_id));
  pl('applic  ',to_char(l_resp_appl_id));
  pl('secgrp  ',l_security_group_id);
  pl('param   ',substr(l_param,1,240));
  pl('report  ',l_report_name);
  pl('message ',substr(l_message,1,240));
  pl('subject ',l_subject);
  -- ---------------------------------------------------------------------
  -- 5. start the workflow process
  -- ---------------------------------------------------------------------
  pl('start workflow process');
  bis_util.strt_wf_process
		(p_exception_message    => l_message
		,p_msg_subject          => l_subject
		,p_exception_date	    => sysdate
 	    ,p_item_type            => p_target_rec.workflow_item_type
		,p_wf_process		    => p_target_rec.workflow_process_short_name
		,p_notify_resp_name     => l_resp_short_name
		,p_report_name1		    => l_report_name
		,p_report_param1	    => l_param
        ,p_report_resp1_id     	=> l_resp_id
        ,x_return_status       	=> l_return_status);

  pl(' Resp id',to_char(l_resp_id));

  pl(' Workflow return status: ',l_return_status);

  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
     RAISE e_g_bis_fn_error;
  END IF;

  pl('*SEND Manpower Separation notification','End');

END send_notification_hrmsp;

-----------------------------------------------------------------------
--  CALCULATE ACTUAL MANPOWER SEPARATIONS
-----------------------------------------------------------------------

FUNCTION hrmsp_actual
          (p_actual_rec  IN bis_actual_pub.actual_rec_type
          ,p_bmtype      IN VARCHAR2)
 RETURN NUMBER
 IS

l_budget_value		NUMBER(38,2);			-- budget measurement value
l_loss_type 		VARCHAR2(20);	 		-- type of separation
l_separated_count 	NUMBER(38,2);			-- count of separated people

l_period_start_date DATE;
l_period_end_date   DATE;

l_business_group_id NUMBER;

l_formula_id        ff_formulas_f.formula_id%TYPE;

--
-- get each assignment that has separated IN the period defined
-- by the target time dimension
--
-- This Cursor has been changed due to bug 1718083 to be exactly the same
-- as the Workforce Seperations report. JRHYDE
--
-- A Loss occurs when the last day of a person's assignment occurs prior to
-- the date of the period and the asg start date is prior to the first day of
-- the period
CURSOR asg_cur
	(p_c_organization_id   IN NUMBER
	,p_c_period_start_date IN date
	,p_c_period_end_date   IN date) IS
 SELECT asg.assignment_id
      , asg.effective_end_date
   FROM per_all_assignments_f asg
      , per_assignment_status_types ast
  WHERE p_c_period_start_date-1 between
           asg.effective_start_date and
           asg.effective_end_date
    AND asg.assignment_type           = 'E'
    AND asg.organization_id           = p_c_organization_id
    AND asg.assignment_status_type_id = ast.assignment_status_type_id
    AND ast.per_system_status         = 'ACTIVE_ASSIGN'
    AND NOT EXISTS
  	 (SELECT null
	    FROM per_all_assignments_f asg2,
 		     per_assignment_status_types ast2
	   WHERE p_c_period_end_date between
                     asg2.effective_start_date and
                     asg2.effective_end_date
           AND asg2.assignment_type           = 'E'
           AND asg2.assignment_id             = asg.assignment_id
           AND asg2.assignment_status_type_id = ast2.assignment_status_type_id
           AND ast2.per_system_status         = 'ACTIVE_ASSIGN'
           AND asg2.organization_id           = p_c_organization_id);

BEGIN
  pl('*HRMSP ACTUAL','Start');

  --
  -- Get the fast formula ID of the FTE or HEAD. This is used to
  -- calculate the budget measurement value of an employees assignment.
  --

  --Business Group is that of the organization of the - JRHYDE
  l_business_group_id := get_org_business_group_id(to_number(p_actual_rec.org_level_value_id));

  l_formula_id        := get_formula_id(l_business_group_id
                                       ,p_bmtype);

  pl('fast formula id: ',to_char(l_formula_id));

  --Get start and end dates from the time dim
  get_dates_from_time_dim
    (p_actual_rec.time_level_value_id
    ,l_period_start_date
    ,l_period_end_date);

  --
  -- Loop through each employee assignment that separated in the period defined
  -- by the PMF time dimesnion and then calculate the budget measurement value
  -- using the budget measurement type specified as a unit of measurement.
  --
  pl('Loop through employees separated in the target period');
  l_separated_count := 0;
  FOR asg_rec IN asg_cur
  		(to_number(p_actual_rec.org_level_value_id)
  		,l_period_start_date
  		,l_period_end_date) LOOP

    pl(' asg id: ',to_char(asg_rec.assignment_id));
    l_loss_type := hrfastanswers.getassignmentcategory
  	                 (p_assignment_id      => asg_rec.assignment_id
  	                 ,p_period_start_date  => l_period_start_date
  	                 ,p_period_END_date    => l_period_end_date
  	                 ,p_top_org  	       => p_actual_rec.org_level_value_id
  	                 ,p_movement_type      => 'OUT');

   pl(' loss: ',l_loss_type);

   IF l_loss_type = 'SEPARATED' THEN

     l_budget_value := hrfastanswers.getbudgetvalue
                            (p_budget_metric_formula_id => l_formula_id
       	                    ,p_budget_metric            => p_bmtype
               	            ,p_assignment_id            => asg_rec.assignment_id
                       	    ,p_effective_date           => asg_rec.effective_end_date
                		    ,p_session_date             => sysdate);

     pl(p_bmtype
       ,to_char(l_budget_value));

     l_separated_count := l_separated_count + l_budget_value;
   END IF;

  END LOOP;

 pl('actual = ',to_char(l_separated_count));
 pl('*HRMSP ACTUAL','End');

 RETURN l_separated_count;

EXCEPTION
  WHEN e_g_no_bg THEN
    pl('No BG found for FF');
    RAISE e_g_no_ff_bg;

END;

-------------------------------------------------------------------------
-- PROCESS MANPOWER SEPARATION TARGETS
-------------------------------------------------------------------------

PROCEDURE process_hrmsp
           (p_target_rec  IN hri_target_rec_type)
 IS

l_actual  NUMBER(22,2);
l_mod_target bisfv_targets.target%TYPE;

l_actual_rec        bis_actual_pub.actual_rec_type;

BEGIN

  pl('*PROCESS MANPOWER SEPARATION TARGET','Start');

/* IS THIS ACTUALLY NEEDED -JRHYDE 20/12/00
   hrFastAnswers.LoadOrgHierarchy(p_target_rec.org_level_value_id
                               ,g_org_structure_version_id);*/

  -- Convert the data from target record format into an actual record format
  l_actual_rec := get_bis_actual_rec(p_target_rec);

  IF p_target_rec.measure_short_name = 'HRMSPFTE' THEN
    l_actual := hrmsp_actual(l_actual_rec,'FTE');
  ELSIF p_target_rec.measure_short_name = 'HRMSPHEAD' THEN
    l_actual := hrmsp_actual(l_actual_rec,'HEAD');
  END IF;

  pl('actual: ',to_char(l_actual));
  pl('target: ',to_char(p_target_rec.target));

  --
  -- Send a notification if
  -- The actual value of workforce separations is
  -- greater than the target.
  -- If a value of -1 has been returned
  -- then abort processing as an error has occurred.
  --
  -- This process will be repeated for each of the three levels
  -- of notification that are available
  --
  IF l_actual = -1 THEN
    pl('Actual = -1','No workflow');
    null;
  ELSE
    IF p_target_rec.notify_resp1_id IS NOT NULL THEN
    /* 115.11 */
      IF validate_resp_org_security
           (p_target_rec.notify_resp1_id
           ,p_target_rec.notify_resp1_appl_id
           ,to_number(p_target_rec.org_level_value_id)) THEN
        l_mod_target := p_target_rec.target
                         + ((p_target_rec.target/100)*nvl(p_target_rec.range1_high,0));
        pl(' Processing responsibility 1: ',p_target_rec.notify_resp1_short_name);
        pl(' Modified target: ',l_mod_target);
        pl(' Actual: ',l_actual);
        IF l_actual > l_mod_target THEN
          send_notification_hrmsp(1
                                 ,l_mod_target
                                 ,l_actual
                                 ,p_target_rec);
        END IF;  -- actual < target
      END IF;  -- valid resp1_id security
    END IF;  --notify_resp1_id not null

    IF p_target_rec.notify_resp2_id IS NOT NULL THEN
      IF validate_resp_org_security
           (p_target_rec.notify_resp2_id
           ,p_target_rec.notify_resp2_appl_id
           ,to_number(p_target_rec.org_level_value_id)) THEN
        l_mod_target := p_target_rec.target
                         + ((p_target_rec.target/100)*nvl(p_target_rec.range2_high,0));
        pl(' Processing responsibility 2: ',p_target_rec.notify_resp2_short_name);
        pl(' Modified target: ',l_mod_target);
        pl(' Actual: ',l_actual);
        IF l_actual > l_mod_target THEN
          send_notification_hrmsp(2
                                 ,l_mod_target
                                 ,l_actual
                                 ,p_target_rec);
        END IF;  -- actual < target
      END IF;  -- valid resp2_id security
    END IF;  --notify_resp2_id not null

    IF p_target_rec.notify_resp3_id IS NOT NULL THEN
      IF validate_resp_org_security
           (p_target_rec.notify_resp3_id
           ,p_target_rec.notify_resp3_appl_id
           ,to_number(p_target_rec.org_level_value_id)) THEN
        l_mod_target := p_target_rec.target
                         + ((p_target_rec.target/100)*nvl(p_target_rec.range3_high,0));
        pl(' Processing responsibility 3: ',p_target_rec.notify_resp3_short_name);
        pl(' Modified target: ',l_mod_target);
        pl(' Actual: ',l_actual);
        IF l_actual > l_mod_target THEN
          send_notification_hrmsp(3
                                 ,l_mod_target
                                 ,l_actual
                                 ,p_target_rec);
        END IF;  -- actual < target
      END IF;  -- valid resp3_id security
    END IF;  --notify_resp3_id not null
  END IF; --actual = -1
 pl('*PROCESS MANPOWER SEPARATION TARGET','End');
END;

-- **********************************************************************
--
--                    M A N P O W E R   V A R I A N C E
--
-- **********************************************************************

-------------------------------------------------------------------------
--
--  SEND A MANPOWER VARIANCE notification
--
-------------------------------------------------------------------------
--
-- This procedure builds the notification message including the URL
-- to run the manpoiwer variance report and issues a call to the workflow
-- engine to send the notification.
--

PROCEDURE send_notification_hrmvr
           (p_type       IN VARCHAR2
           ,p_resp_no    IN NUMBER  --No. between 1-3 signifying which resp
           ,p_target     IN NUMBER
           ,p_actual     IN NUMBER
           ,p_target_rec IN hri_target_rec_type)
 IS

  l_subject 	    fnd_new_messages.message_text%TYPE;
  l_message         VARCHAR2(2000);
  l_freq_code       VARCHAR2(4);
  l_dummy   	    VARCHAR2(2000);
  l_start_date      date;
  l_report_name     VARCHAR2(8);
  l_return_status   VARCHAR2(2000);
  l_error	        VARCHAR2(2000);
  l_param	        VARCHAR2(2000);

  -- Dimension Params
  l_org_name	    per_organization_units.name%TYPE;
  l_org_type	    hr_lookups.meaning%TYPE;
  l_orgprc  	    hr_lookups.meaning%TYPE;
  l_bmt_name        hr_lookups.meaning%TYPE;
  l_job_name        per_jobs.name%TYPE;
  l_job_cat         hr_lookups.meaning%TYPE;
  l_loc_name        hr_locations.location_code%TYPE;

  l_period_name     VARCHAR2(50);

  -- Session params
  l_security_group_id  per_business_groups.security_group_id%TYPE;
  l_business_group_id  hr_all_organization_units.business_group_id%TYPE;
  l_resp_id            fnd_responsibility.responsibility_id%TYPE;
  l_resp_short_name    bisfv_targets.notify_resp1_short_name%TYPE;
  l_resp_name          bisfv_targets.notify_resp1_name%TYPE;
  l_resp_appl_id       fnd_responsibility.application_id%TYPE;

BEGIN

  pl('-----------------------------------');
  pl('*SEND Manpower Variance notification','Start');
  pl('-----------------------------------');
  pl(' type: ',p_type);
  pl(' responsibility no',to_char(p_resp_no));
  pl(' actual: ',to_char(p_actual));
  -----------------------------------------------------------------------
  -- Build the notification subject line and message text
  -----------------------------------------------------------------------
  --
  -- Get the following information that will be shown on the notification
  -- and populate the relevant tokens in the message HR_BIS_PMF_SUBJECT
  --
  -- 1. Get Session parameters for the report
  -- 2. Get Parameter Names:
  --    Organzation name
  --    Location
  --    Job or Job Category
  --    Budget Measurement Type Name
  --    Period name
  -- 3. build notification text
  -- 4. get the report frequency, number of periods and start date
  -- 5. build the report parameter string
  -- 6. start the workflow process
  --
   -- ---------------------------------------------------------------------
  -- 1. Get Session parameters for the report
  -- ---------------------------------------------------------------------
  get_resp_details(p_resp_no
                  ,p_target_rec
                  ,l_resp_id
                  ,l_resp_appl_id
                  ,l_resp_short_name
                  ,l_resp_name);
  l_business_group_id := get_org_business_group_id(p_target_rec.org_level_value_id);
  l_security_group_id := get_org_security_group_id(p_target_rec.org_level_value_id);
  -- ---------------------------------------------------------------------
  -- 2. Get the parameter names
  -- ---------------------------------------------------------------------
  --
  -- Organization
  --
  hr_reports.get_organization(p_target_rec.org_level_value_id,l_org_name,l_org_type);
  l_orgprc   := translate_orgprc(g_orgprc_const);
  pl(' org name: ',l_org_name);
  --
  -- Location
  --
  l_loc_name := translate_location(p_target_rec.dim1_level_value_id);
  pl(' loc name: ',l_loc_name);
  --
  -- Job / Job Category
  --
  IF p_target_rec.dim2_level_short_name = 'TOTAL GEOGRAPHY' THEN
    l_job_name := translate_all;
    l_job_cat  := translate_all;
  ELSIF p_target_rec.dim2_level_short_name = 'JOB' THEN
    l_job_name := translate_job(p_target_rec.dim2_level_value_id);
    l_job_cat  := translate_all;
  ELSIF p_target_rec.dim2_level_short_name = 'JOB CATEGORY' THEN
    l_job_name := translate_all;
    l_job_cat  := translate_job_category(p_target_rec.dim2_level_value_id);
  END IF;
  pl(' job name: ',l_job_name);
  pl(' job category name: ',l_job_cat);
  --
  -- Budget
  --
  l_bmt_name := hr_reports.get_lookup_meaning
                ('BUDGET_MEASUREMENT_TYPE',p_target_rec.unit_of_measure);
  pl(' bmt name: ',l_bmt_name);
  --
  -- Period
  --
  l_period_name := to_char(p_target_rec.period_start_date,'DD-MON-YYYY')
                           ||' - '||to_char(p_target_rec.period_END_date,'DD-MON-YYYY');
  pl(' Period Name:',l_period_name);
  -- ---------------------------------------------------------------------
  -- 2. Build the notification text
  -- ---------------------------------------------------------------------
  --
  -- Build subject message text
  --
  IF p_type = 'ABOVE' THEN
   fnd_message.set_name('HRI','HR_BIS_PMF_HRMVR_HIGH_SUBJECT');
   l_subject := fnd_message.get;
  ELSE
   fnd_message.set_name('HRI','HR_BIS_PMF_HRMVR_LOW_SUBJECT');
   l_subject := fnd_message.get;
  END IF;
  --
  -- Build the body message text
  --
  IF p_type = 'ABOVE' THEN
   fnd_message.set_name('HRI','HR_BIS_PMF_HRMVR_HIGH_MSG');
  ELSE
   fnd_message.set_name('HRI','HR_BIS_PMF_HRMVR_LOW_MSG');
  END IF;
  fnd_message.set_token('ORGANIZATION',l_org_name);
  fnd_message.set_token('JOB',l_job_name);
  fnd_message.set_token('CATEGORY',l_job_cat);
  fnd_message.set_token('LOCATION',l_loc_name);
  fnd_message.set_token('PERIOD',l_period_name);
  fnd_message.set_token('BUDGET',l_bmt_name);
  fnd_message.set_token('TARGET',p_target);
  fnd_message.set_token('ACTUAL',p_actual);
  --fnd_message.set_token('ROLE',l_resp_name);
  l_message := fnd_message.get;
  pl(' Message:',l_message);

  -- ---------------------------------------------------------------------
  -- 4. build the report parameter string
  -- ---------------------------------------------------------------------
  -- Build the url that will be used to run the report from the
  -- notification.
  l_report_name := 'HRMNPSUM';

  get_report_date_params(p_target_rec.time_level_short_name
                        ,p_target_rec.period_start_date
                        ,l_freq_code
                        ,l_start_date);
  pl(' Frequency: ',l_freq_code);
  pl(' Start date: ',to_char(l_start_date,'DD-MON-YYYY'));

  l_param := 'org_id='             ||p_target_rec.org_level_value_id   ||'*'||
             'orgprc='             ||g_orgprc_const                    ||'*'||
             'bpl_id='             ||p_target_rec.plan_id              ||'*'||
             'bgttyp='             ||p_target_rec.unit_of_measure      ||'*'||
             'frqncy='             ||l_freq_code                       ||'*'||
             'geolvl=1*'           ||
             'geoval=-1*'          ||
             'bus_id='             ||to_char(l_business_group_id)      ||'*'||
             'prodid=-1*'          ||
             'startd='             ||to_char(l_start_date,'YYYY-MM-DD')||'*'||
             'end_dt='             ||to_char(p_target_rec.period_END_date,'YYYY-MM-DD')||'*'||
             'viewby=HR_BIS_TIME*';

  IF p_target_rec.dim2_level_short_name = 'JOB' THEN
    l_param := l_param          ||
               'job_id='        ||p_target_rec.dim2_level_value_id    ||'*'||
               'jobcat=__ALL__*';
  ELSIF p_target_rec.dim1_level_short_name = 'JOB CATEGORY' THEN
    l_param := l_param          ||
               'job_id=-1*'     ||
               'jobcat='        ||p_target_rec.dim2_level_value_id    ||'*';
  ELSE
    l_param := l_param          ||
               'job_id=-1*'     ||
               'jobcat=__ALL__*';
  END IF;

  l_param := l_param ||
            c_ampersand||'responsibility_application_id='
                       ||to_char(l_resp_appl_id)||
            c_ampersand||'security_group_id='
                       ||l_security_group_id;

  pl('wf      ',p_target_rec.workflow_item_type);
  pl('process ',p_target_rec.workflow_process_short_name);
  pl('resp    ',l_resp_short_name);
  pl('resp id ',to_char(l_resp_id));
  pl('applic  ',to_char(l_resp_appl_id));
  pl('secgrp  ',l_security_group_id);
  pl('param   ',substr(l_param,1,240));
  pl('report  ',l_report_name);
  pl('message ',substr(l_message,1,240));
  pl('subject ',l_subject);
  -- ---------------------------------------------------------------------
  -- 5. start the workflow process
  -- ---------------------------------------------------------------------
  pl('start workflow process');
  bis_util.strt_wf_process
		(p_exception_message	=> l_message
		,p_msg_subject		    => l_subject
		,p_exception_date	    => sysdate
 	    ,p_item_type            => p_target_rec.workflow_item_type
		,p_wf_process		    => p_target_rec.workflow_process_short_name
		,p_notify_resp_name     => l_resp_short_name
		,p_report_name1		    => l_report_name
		,p_report_param1	    => l_param
        ,p_report_resp1_id     	=> l_resp_id
        ,x_return_status       	=> l_return_status);

  pl(' Resp id : ',to_char(l_resp_id));

  pl(' Workflow return status : ',l_return_status);

  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    RAISE e_g_bis_fn_error;
  END IF;

  pl('*SEND Manpower Variance notification','End');

END;
-------------------------------------------------------------------------
--
--  Compare actual to target
--
-------------------------------------------------------------------------
PROCEDURE hrmvr_compare_values
            (p_target_rec IN hri_target_rec_type
            ,p_actual     IN NUMBER) IS

 l_mod_target 	bisfv_targets.target%TYPE;

BEGIN
--
-- process range 1
--
  IF p_target_rec.notify_resp1_id IS NOT NULL THEN
    IF validate_resp_org_security
       (p_target_rec.notify_resp1_id
       ,p_target_rec.notify_resp1_appl_id
       ,to_number(p_target_rec.org_level_value_id)) THEN
      IF p_target_rec.range1_high IS NOT NULL THEN
        l_mod_target := p_target_rec.target + ((p_target_rec.target/100)*p_target_rec.range1_high);
        pl(' Processing responsibility 1: ',p_target_rec.notify_resp1_short_name);
        pl(' Modified target: ',l_mod_target);
        pl(' Actual: ',p_actual);
        IF p_actual > l_mod_target THEN
          send_notification_hrmvr('ABOVE'
                                 ,1
                                 ,l_mod_target
                                 ,p_actual
                                 ,p_target_rec);
        END IF;
      END IF;  --range high
      IF p_target_rec.range1_low IS NOT NULL THEN
         l_mod_target := p_target_rec.target
                         -  ((p_target_rec.target/100)*p_target_rec.range1_low);
        pl(' Processing responsibility 1: ',p_target_rec.notify_resp1_short_name);
        pl(' Modified target: ',l_mod_target);
        pl(' Actual: ',p_actual);
        IF p_actual < l_mod_target THEN
            send_notification_hrmvr('BELOW'
                                    ,1
                                    ,l_mod_target
                                    ,p_actual
                                    ,p_target_rec);
        END IF;
      END IF;  -- range low
    END IF;  -- valid resp1_id security
  END IF;  --notify_resp1_id not null

  --
  -- process range 2
  --
  IF p_target_rec.notify_resp2_id IS NOT NULL THEN
    IF validate_resp_org_security
         (p_target_rec.notify_resp2_id
         ,p_target_rec.notify_resp2_appl_id
         ,to_number(p_target_rec.org_level_value_id)) THEN
      IF p_target_rec.range2_high IS NOT NULL THEN
        l_mod_target := p_target_rec.target
                        + ((p_target_rec.target/100)*p_target_rec.range2_high);
        pl(' Processing responsibility 2: ',p_target_rec.notify_resp2_short_name);
        pl(' Modified target: ',l_mod_target);
        pl(' Actual: ',p_actual);
        IF p_actual > l_mod_target THEN
          send_notification_hrmvr('ABOVE'
                                 ,2
                                 ,l_mod_target
                                 ,p_actual
                                 ,p_target_rec);
        END IF;
      END IF;  -- range high
      IF p_target_rec.range2_low IS NOT NULL THEN
        l_mod_target := p_target_rec.target
                         - ((p_target_rec.target/100)*p_target_rec.range2_low);
        pl(' Processing responsibility 2: ',p_target_rec.notify_resp2_short_name);
        pl(' Modified target: ',l_mod_target);
        pl(' Actual: ',p_actual);
        IF p_actual < l_mod_target THEN
          send_notification_hrmvr('BELOW'
                                 ,2
                                 ,l_mod_target
                                 ,p_actual
                                 ,p_target_rec);
        END IF;
      END IF;  -- range low
    END IF;  -- valid resp2_id security
  END IF;  --notify_resp2_id not null

--
-- process range 3
--
  IF p_target_rec.notify_resp3_id IS NOT NULL THEN
    IF validate_resp_org_security
         (p_target_rec.notify_resp3_id
         ,p_target_rec.notify_resp3_appl_id
         ,to_number(p_target_rec.org_level_value_id)) THEN
      IF p_target_rec.range3_high IS NOT NULL THEN
        l_mod_target := p_target_rec.target
                         + ((p_target_rec.target/100)*p_target_rec.range3_high);
        pl(' Processing responsibility 3: ',p_target_rec.notify_resp3_short_name);
        pl(' Modified target: ',l_mod_target);
        pl(' Actual: ',p_actual);
        IF p_actual > l_mod_target THEN
          send_notification_hrmvr('ABOVE'
                                 ,3
                                 ,l_mod_target
                                 ,p_actual
                                 ,p_target_rec);
        END IF;
      END IF;  -- range high
      IF p_target_rec.range3_low IS NOT NULL THEN
        l_mod_target := p_target_rec.target
                         - ((p_target_rec.target/100)*p_target_rec.range3_low);
        pl(' Processing responsibility 3: ',p_target_rec.notify_resp3_short_name);
        pl(' Modified target: ',l_mod_target);
        pl(' Actual: ',p_actual);
        IF p_actual < l_mod_target THEN
          send_notification_hrmvr('BELOW'
                                 ,3
                                 ,l_mod_target
                                 ,p_actual
                                 ,p_target_rec);
        END IF;
      END IF;  -- range low
    END IF;  -- valid resp3_id security
  END IF;  --notify_resp3_id not null

END hrmvr_compare_values;

-------------------------------------------------------------------------
--
--  CALCULATE THE ACTUAL MANPOWER VARIANCE
--
-------------------------------------------------------------------------
--
-- This procedure will calculate the total actual manpower as of today
-- filtered using the target dimensions.
--

FUNCTION hrmvr_actual
           (p_actual_rec   IN bis_actual_pub.actual_rec_type
           ,p_bmtype       IN VARCHAR2)
 RETURN NUMBER
 IS

l_budget_value		NUMBER(20,2) := 0;
l_total_manpower	NUMBER(20,2) := 0;

l_business_group_id NUMBER;

l_period_start_date DATE;
l_period_end_date   DATE;

l_formula_id 		ff_formulas.formula_id%TYPE;

--
-- Get the total manpower matching the target dimensions
--
-- This Cursor has been changed due to bug 1718083 to be exactly the same
-- as the Workforce Total report. JRHYDE
--
-- To make this the same as the report have to calculate the abv at the end
-- of the period. As total workforce is counted when an assignment exists
-- on the end date and the start date. Regardless of whether it is the same date track row,
-- as long as it is the same assignment. But the report also factors in any
-- Gains occuring during the period.  So this equates to all assignments at the
-- end of a period.
  CURSOR mv_cur
          (p_c_business_group_id  NUMBER
          ,p_c_actual_rec         bis_actual_pub.actual_rec_type
          ,p_c_period_start_date  DATE
          ,p_c_period_end_date    DATE)
     IS
    SELECT asg.assignment_id
         , asg.effective_start_date
      FROM per_all_assignments_f asg
         , per_assignment_status_types ast
     WHERE ( (p_c_actual_rec.dim2_level_value_name = 'JOB CATEGORY'
               AND   asg.job_id IN (SELECT jei.job_id
                                      FROM per_job_extra_info jei
                                     WHERE jei.jei_information1 = p_c_actual_rec.dim2_level_value_id)
             )
             OR
             (p_c_actual_rec.dim2_level_value_name = 'JOB'
               AND
              asg.job_id = to_number(p_c_actual_rec.dim2_level_value_id) )
             OR
             (p_c_actual_rec.dim2_level_value_name = 'TOTAL JOBS')
           )
       AND ( (p_c_actual_rec.dim1_level_value_name = 'LOCATION'
               AND
              asg.location_id = to_number(p_c_actual_rec.dim3_level_value_id))
             OR
            p_c_actual_rec.dim1_level_value_name = 'TOTAL GEOGRAPHY'
           )
       AND asg.business_group_id = p_c_business_group_id
       AND asg.organization_id = to_number(p_c_actual_rec.org_level_value_id)
       AND asg.assignment_status_type_id = ast.assignment_status_type_id
       AND ast.per_system_status = 'ACTIVE_ASSIGN'
       AND asg.assignment_type = 'E' -- Bug 2357061
       AND p_c_period_end_date BETWEEN
            asg.effective_start_date AND
            asg.effective_end_date
       /* Commented out because of the method in HRMNPSUM used to calc TOTAL
       AND EXISTS
           (SELECT null
              FROM per_all_assignments_f asg2
                 , per_assignment_status_types ast2
             WHERE p_c_period_start_date-1 BETWEEN
                     asg2.effective_start_date AND
                     asg2.effective_end_date
               AND asg2.assignment_id             = asg.assignment_id
               AND asg2.assignment_status_type_id = ast2.assignment_status_type_id
               AND ast2.per_system_status         = 'ACTIVE_ASSIGN'
               AND asg2.organization_id           = p_c_actual_rec.org_level_value_id
           )
       */
       ;

BEGIN

  pl('*HRMVR actual','Start');
  --
  -- If a fast formula exists this will be used to calculate the
  -- manpower value
  --
  l_business_group_id := get_org_business_group_id(to_number(p_actual_rec.org_level_value_id));
  pl(' Business Group id',to_char(l_business_group_id));
  pl(' unit of measure ',p_bmtype);
  l_formula_id        := get_formula_id(l_business_group_id
                                       ,p_bmtype);
  pl(' formula id ',to_char(l_formula_id));
  pl(' dim1 ',p_actual_rec.dim1_level_value_id);
  pl(' dim2 ',p_actual_rec.dim2_level_value_id);
  pl(' dim3 ',p_actual_rec.dim3_level_value_id);
  pl(' dim1 ',p_actual_rec.dim1_level_value_name);
  pl(' dim2 ',p_actual_rec.dim2_level_value_name);
  pl(' dim3 ',p_actual_rec.dim3_level_value_name);


  --Get start and end dates from the time dim
  get_dates_from_time_dim
    (p_actual_rec.time_level_value_id
    ,l_period_start_date
    ,l_period_end_date);
  --
  -- get all the eligible assignments
  --
  pl('loop through assignments');

  FOR mv_rec IN mv_cur
                 (l_business_group_id
                 ,p_actual_rec
                 ,l_period_start_date
                 ,l_period_end_date)
    LOOP
    pl(' assignment id ',to_char(mv_rec.assignment_id));

    l_budget_value := HrFastAnswers.GetBudgetValue
                            (p_budget_metric_formula_id => l_formula_id
                            ,p_budget_metric            => p_bmtype
                            ,p_assignment_id            => mv_rec.assignment_id
                            ,p_effective_date           => mv_rec.effective_start_date
                            ,p_session_date             => sysdate);

    pl(p_bmtype
      ,to_char(l_budget_value));

    l_total_manpower := l_total_manpower + l_budget_value;
  END LOOP;

  pl('Actual = ',to_char(l_total_manpower));
  pl('*HRMVR actual','End');

  RETURN  l_total_manpower;

END hrmvr_actual;

-------------------------------------------------------------------------
--
--  PROCESS MANPOWER VARIANCE TARGETS
--
-------------------------------------------------------------------------

PROCEDURE process_hrmvr
             (p_target_rec IN hri_target_rec_type)
 IS

l_actual            NUMBER(22,2);
l_budget_value	  NUMBER(22,2);
l_budget_id         per_budgets_v.budget_id%TYPE;
l_business_group_id NUMBER;

l_actual_rec        bis_actual_pub.actual_rec_type;

--
-- get the budget value
--

CURSOR bv_cur(p_budget_id         IN NUMBER
             ,p_business_group_id IN NUMBER
             ,p_target_rec        IN hri_target_rec_type) IS
   SELECT sum(bval.value) budget_value
     FROM per_budget_values	bval
        , per_budget_elements	be
        , per_budget_versions	bver
        , per_time_periods	tp
  	    , per_budgets_v		bud
     where	bud.unit                = p_target_rec.unit_of_measure
       AND  bud.business_group_id	= l_business_group_id
       AND	bud.budget_id		    = p_budget_id
       AND	bud.budget_id		    = bver.budget_id
       AND  trunc(sysdate) BETWEEN
              bver.date_FROM AND nvl( bver.date_to, SYSDATE+1 )
       AND	be.budget_version_id	= bver.budget_version_id
       AND	be.budget_element_id	= bval.budget_element_id
       AND	tp.time_period_id	    = bval.time_period_id
       AND 	be.organization_id      = p_target_rec.org_level_value_id
       AND  ((p_target_rec.dim2_level_short_name = 'JOB CATEGORY'
       AND   be.job_id IN (SELECT jei.job_id
                             FROM per_job_extra_info jei
                            WHERE jei.jei_information1 = p_target_rec.dim2_level_value_id))
       OR    (p_target_rec.dim2_level_short_name = 'JOB'
               AND  be.job_id = p_target_rec.dim2_level_value_id)
       OR    (p_target_rec.dim2_level_short_name = 'TOTAL JOBS'))
               AND	tp.start_date = p_target_rec.period_start_date
       AND	tp.END_date   = p_target_rec.period_END_date;

BEGIN

  pl('*Processing manpower variance','Start');
  pl(' Dim3 (budget) ',p_target_rec.dim3_level_value_id);

  -- Convert the date from target record format into an actual record format
  l_actual_rec := get_bis_actual_rec(p_target_rec);

  --
  -- IF the target based on a HR budget (i.e. dimension 3 is populate)
  -- then get the target value from the budget
  -- otherwise use the value from the target itself.
  -- Note: If the target contains both the name
  -- of a budget and a target value, the target value is ignored.
  --

  -- hrFastAnswers.LoadOrgHierarchy(p_target_rec.org_level_value_id,g_org_structure_version_id);

  IF (p_target_rec.dim3_level_value_id = '-1'
       OR
      p_target_rec.dim3_level_value_id IS NULL )
    THEN

    pl(' Budget not specified so using target values');

    IF p_target_rec.measure_short_name = 'HRMVRFTE' THEN
       l_actual := hrmvr_actual(l_actual_rec,'FTE');
    ELSIF p_target_rec.measure_short_name = 'HRMVRHEAD' THEN
       l_actual := hrmvr_actual(l_actual_rec,'HEAD');
    END IF;
    pl(' actual ',to_char(l_actual));
    hrmvr_compare_values(p_target_rec
                        ,l_actual);
  ELSE
    l_budget_id := to_NUMBER(substr(p_target_rec.dim3_level_value_id
                                   ,instr(p_target_rec.dim3_level_value_id,'+')+1));
    l_business_group_id := get_org_business_group_id(to_number(p_target_rec.org_level_value_id));
    pl(' Budget used so querying budget');
    OPEN bv_cur(l_budget_id
               ,l_business_group_id
               ,p_target_rec);
    FETCH bv_cur
      INTO l_actual;

    IF bv_cur%NOTFOUND THEN
       CLOSE bv_cur;
    ELSE
       CLOSE bv_cur;
       pl(' budget target ',to_char(p_target_rec.target));

       IF p_target_rec.measure_short_name = 'HRMVRFTE' THEN
         l_actual := hrmvr_actual(l_actual_rec,'FTE');
       ELSIF p_target_rec.measure_short_name = 'HRMVRHEAD' THEN
         l_actual := hrmvr_actual(l_actual_rec,'HEAD');
       END IF;

       hrmvr_compare_values(p_target_rec
                           ,l_actual);
    END IF;
 END IF;
 pl('*Processing manpower variance','End');

END;

-- **********************************************************************
--
--                       RECRUITMENT SUCCESS
--
-- **********************************************************************


-------------------------------------------------------------------------
--
--  SEND RECRUITMENT SUCCESS notification
--
-------------------------------------------------------------------------
-- This procedure will build and send a recruitment success notification.
-- It is called from the procedure hrrcs_process if the actual recruitment
-- success rate is less than the targeted success rate.
--

PROCEDURE send_notification_hrrcs
           (p_resp_no    IN NUMBER
           ,p_target     IN NUMBER
           ,p_actual     IN NUMBER
           ,p_target_rec hri_target_rec_type)
 IS

l_subject       fnd_new_messages.message_text%TYPE;
l_message       VARCHAR2(2000);
l_freq_code     VARCHAR2(4);
l_dummy         VARCHAR2(2000);
l_param         VARCHAR2(2000);
l_error         VARCHAR2(2000);

l_start_date    DATE;
l_report_name   VARCHAR2(8) := 'HRCOMREC';
l_return_status VARCHAR2(2000);

l_actual        VARCHAR2(30);
l_target        VARCHAR2(30);

l_org_name	    per_organization_units.name%TYPE;
l_org_type	    hr_lookups.meaning%TYPE;
l_orgprc    	hr_lookups.meaning%TYPE;
l_bmt_name  	hr_lookups.meaning%TYPE;
l_job_name  	per_jobs.name%TYPE;
l_job_cat   	hr_lookups.meaning%TYPE  := '';
l_loc_name  	hr_locations.location_code%TYPE;

l_period_name  VARCHAR2(50);

-- Session params
l_security_group_id  per_business_groups.security_group_id%TYPE;
l_business_group_id  hr_all_organization_units.business_group_id%TYPE;
l_resp_id            fnd_responsibility.responsibility_id%TYPE;
l_resp_short_name    bisfv_targets.notify_resp1_short_name%TYPE;
l_resp_name          bisfv_targets.notify_resp1_name%TYPE;
l_resp_appl_id       fnd_responsibility.application_id%TYPE;

BEGIN

  pl('-------------------------------------');
  pl('*SEND recruitment success notification','Start');

  -----------------------------------------------------------------------
  -- Build the notification subject line and message text
  -----------------------------------------------------------------------
  --
  -- Get the following information that will be shown on the notification
  -- and populate the relevant tokens in the message HR_BIS_PMF_SUBJECT
  --
  -- 1. Get Session parameters for the report
  -- 2. Get Parameter Names:
  --    Organzation name
  --    Location
  --    Job or Job Category
  --    Budget Measurement Type Name
  --    Period name
  -- 3. build notification text
  -- 4. get the report frequency, number of periods and start date
  -- 5. build the report parameter string
  -- 6. start the workflow process
  --
  -- ---------------------------------------------------------------------
  -- 1. Get Session parameters for the report
  -- ---------------------------------------------------------------------
  get_resp_details(p_resp_no
                  ,p_target_rec
                  ,l_resp_id
                  ,l_resp_appl_id
                  ,l_resp_short_name
                  ,l_resp_name);
  l_business_group_id := get_org_business_group_id(p_target_rec.org_level_value_id);
  l_security_group_id := get_org_security_group_id(p_target_rec.org_level_value_id);
  -- ---------------------------------------------------------------------
  -- 1. Get the parameter names
  -- ---------------------------------------------------------------------
  --
  -- Organization
  --
  hr_reports.get_organization(p_target_rec.org_level_value_id,l_org_name,l_org_type);
  l_orgprc   := translate_orgprc(g_orgprc_const);
  pl(' org name: ',l_org_name);
  --
  -- Location
  --
  l_loc_name          := translate_location(p_target_rec.dim1_level_value_id);
  pl(' loc name : ',l_loc_name);
  --
  -- Job / Job Category
  --
  IF p_target_rec.dim2_level_short_name = 'JOB' THEN
     l_job_name := translate_job(p_target_rec.dim2_level_value_id);
     l_job_cat  := translate_all;
  ELSIF p_target_rec.dim2_level_short_name = 'JOB CATEGORY' THEN
     l_job_name := translate_all;
     l_job_cat  := translate_job_category(p_target_rec.dim2_level_value_id);
  ELSIF p_target_rec.dim2_level_short_name = 'TOTAL JOBS' THEN
     l_job_name := translate_all;
     l_job_cat  := translate_all;
  END IF;
  pl(' job name: ',l_job_name);
  pl(' job category name: ',l_job_cat);
  --
  -- Budget Name
  --
  -- Bug 2530846 replacing use of budget_measurement_type with Unit_of_measure
  l_bmt_name := hr_reports.get_lookup_meaning('BUDGET_MEASUREMENT_TYPE'
                                             ,p_target_rec.unit_of_measure);
  pl(' bmt name: ',l_bmt_name);
  --
  -- Period Name
  --
  l_period_name := to_char(p_target_rec.period_start_date,'DD-MON-YYYY')
                           ||' - '||to_char(p_target_rec.period_END_date,'DD-MON-YYYY');
  pl(' period name: ',l_period_name);
  -- ---------------------------------------------------------------------
  -- 2. Build the notification text
  -- ---------------------------------------------------------------------
  --
  -- Build subject message text
  --
  fnd_message.set_name('HRI','HR_BIS_PMF_HRRCS_SUBJECT');
  l_subject := fnd_message.get;
  --
  -- Add Percent signs to actual values
  --
  l_actual := to_char(p_actual)||'%';
  l_target := to_char(p_target)||'%';
  --
  -- Build the body message text
  --
  fnd_message.set_name('HRI','HR_BIS_PMF_HRRCS_MSG');
  fnd_message.set_token('ORGANIZATION',l_org_name);
  fnd_message.set_token('LOCATION',l_loc_name);
  fnd_message.set_token('JOB',l_job_name);
  fnd_message.set_token('CATEGORY',l_job_cat);
  fnd_message.set_token('PERIOD',l_period_name);
  fnd_message.set_token('TARGET',l_target);
  fnd_message.set_token('ACTUAL',l_actual);
  -- Bug 2530846 replacing use of budget_measurement_type with Unit_of_measure
  fnd_message.set_token('BUDGET',l_bmt_name);
  --fnd_message.set_token('ROLE',l_resp_name);
  l_message := fnd_message.get;
  pl(' Message:',l_message);

  -- ---------------------------------------------------------------------
  -- 4. build the report parameter string
  -- ---------------------------------------------------------------------
  -- Build the url that will be used to run the report from the
  -- notification.
  l_report_name := 'HRCOMREC';

  get_report_date_params(p_target_rec.time_level_short_name
                        ,p_target_rec.period_start_date
                        ,l_freq_code
                        ,l_start_date);
  pl(' Frequency: ',l_freq_code);
  pl('Start date: ',to_char(l_start_date,'DD-MON-YYYY'));

  -- Bug 2530846 replacing use of budget_measurement_type with Unit_of_measure
  l_param := 'org_id=' 	||p_target_rec.org_level_value_id   ||'*'||
             'orgprc='  ||g_orgprc_const                    ||'*'||
             'bus_id='  ||to_char(l_business_group_id)      ||'*'||
             'bpl_id='  ||p_target_rec.plan_id              ||'*'||
             'bgttyp='  ||p_target_rec.unit_of_measure      ||'*'||
             'frqncy='  ||l_freq_code                       ||'*'||
             'startd='  ||to_char(l_start_date,'YYYY-MM-DD')||'*'||
             'end_dt='  ||to_char(p_target_rec.period_END_date,'YYYY-MM-DD')||'*';

  IF p_target_rec.dim2_level_short_name = 'JOB' THEN
     l_param := l_param||
               'job_id='  ||p_target_rec.dim2_level_value_id    ||'*'||
               'jobcat=__ALL__*';
  ELSIF p_target_rec.dim2_level_short_name = 'JOB CATEGORY' THEN
     l_param := l_param||
               'job_id=-1*'||
               'jobcat='  ||p_target_rec.dim2_level_value_id    ||'*';
  ELSE
     l_param := l_param||
               'job_id=-1*'||
               'jobcat=__ALL__*';
  END IF;
  --
  -- Append the responsibility and security group ID to the URL. This is used by
  -- ICX to switch the responsibility when running the report.
  --
  l_param := l_param ||
             c_ampersand||'responsibility_application_id='
                        ||to_char(l_resp_appl_id)||
             c_ampersand||'security_group_id='
                        ||l_security_group_id;

  pl('wf      ',p_target_rec.workflow_item_type);
  pl('process ',p_target_rec.workflow_process_short_name);
  pl('resp    ',l_resp_short_name);
  pl('resp id ',to_char(l_resp_id));
  pl('applic  ',to_char(l_resp_appl_id));
  pl('secgrp  ',l_security_group_id);
  pl('param   ',substr(l_param,1,240));
  pl('report  ',l_report_name);
  pl('message ',substr(l_message,1,240));
  pl('subject ',l_subject);
  -- ---------------------------------------------------------------------
  -- 5. start the workflow process
  -- ---------------------------------------------------------------------
  pl('start workflow process');
  bis_util.strt_wf_process
		(p_exception_message	=> l_message
		,p_msg_subject		    => l_subject
		,p_exception_date	    => sysdate
 	    ,p_item_type            => p_target_rec.workflow_item_type
		,p_wf_process		    => p_target_rec.workflow_process_short_name
		,p_notify_resp_name     => l_resp_short_name
		,p_report_name1		    => l_report_name
		,p_report_param1	    => l_param
        ,p_report_resp1_id     	=> l_resp_id
        ,x_return_status       	=> l_return_status);

  pl(' Resp id : ',to_char(l_resp_id));

  pl(' Workflow return status : ',l_return_status);

  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
     RAISE e_g_bis_fn_error;
  END IF;

  pl('*SEND Recruitment Success notification','End');

END;

-------------------------------------------------------------------------
--
--  CALCULATE RECRUITMENT SUCCESS ACTUAL
--
-------------------------------------------------------------------------
--
-- This function will calculate and return the recruitment success rate. the
-- recruitment success rate is the percentage of vacant places that were
-- successfully filled.
--
FUNCTION hrrcs_actual
           (p_actual_rec  IN bis_actual_pub.actual_rec_type
           ,p_bmtype      IN VARCHAR2)
  RETURN NUMBER
  IS

  l_success_rate	    NUMBER;
  l_total_vacancies     NUMBER;
  l_total_assignments	NUMBER;

  l_period_start_date   DATE;
  l_period_end_date     DATE;

  l_business_group_id	NUMBER;
  l_budget_value        NUMBER;

  l_formula_id           ff_formulas_f.formula_id%TYPE;

--
-- This cursor gets each vacancy that closed in period defined by the
-- pmf time dimension
--

CURSOR vac_cur(p_c_actual_rec         bis_actual_pub.actual_rec_type
              ,p_c_bmtype             VARCHAR2
              ,p_c_period_start_date  DATE
              ,p_c_period_end_date    DATE)
  IS
 SELECT  v.budget_measurement_value
      ,  v.vacancy_id
   FROM  per_vacancies v
  WHERE  ( (p_c_actual_rec.dim2_level_value_name = 'JOB CATEGORY'
             AND  v.job_id IN
                 (SELECT jei.job_id
                  FROM per_job_extra_info jei
                  WHERE jei.jei_information1
                      = p_c_actual_rec.dim2_level_value_id)
           )
            OR
           (p_c_actual_rec.dim2_level_value_name = 'JOB'
             AND v.job_id = to_number(p_c_actual_rec.dim2_level_value_id)
           )
            OR
           (p_c_actual_rec.dim2_level_value_name = 'TOTAL JOBS')
         )
    AND  ( (p_c_actual_rec.dim1_level_value_name = 'LOCATION'
             AND v.location_id = to_number(p_c_actual_rec.dim1_level_value_id)
           )
             OR
           (p_c_actual_rec.dim1_level_value_name = 'TOTAL GEOGRAPHY')
         )
    AND v.budget_measurement_type = p_c_bmtype
    AND v.status = 'CLOSED'  --Closed vacancy, bug 2449031
    AND v.date_to BETWEEN
           p_c_period_start_date AND p_c_period_end_date
    AND v.organization_id = p_actual_rec.org_level_value_id;

--
-- This cursor gets the first instance of an employee assignment that
-- was created from a given vacancy
--
CURSOR asg_cur (p_vacancy_id IN NUMBER) IS
 SELECT a.assignment_id
      , a.vacancy_id
      , a.effective_start_date
   FROM per_all_assignments_f a
  WHERE (a.assignment_id, a.effective_start_date) IN
          (SELECT b.assignment_id,min(b.effective_start_date)
             FROM per_all_assignments_f b
            WHERE b.assignment_type = 'E'
              AND b.vacancy_id = p_vacancy_id
           GROUP BY b.assignment_id);

BEGIN

  pl('*HRRCS Actual','Start');
  --
  -- Get the fast formula ID of the FTE or HEAD. This is used to
  -- calculate the budget measurement value of an employees assignment
  --
  l_business_group_id :=
  get_org_business_group_id(to_number(p_actual_rec.org_level_value_id));

  pl('Business Group id: ',  l_business_group_id);
  l_formula_id        := get_formula_id(l_business_group_id
                                       ,p_bmtype);
  pl('Formula id ',to_char(l_formula_id));

  --Get start and end dates from the time dim
  get_dates_from_time_dim
    (p_actual_rec.time_level_value_id
    ,l_period_start_date
    ,l_period_end_date);

  --
  -- Loop through each vacancy that closed in the period defined by the pmf
  -- time dimension and calculate the total number of vacancies.
  --
  l_total_vacancies   := 0;
  l_total_assignments := 0;

  FOR vac_rec IN vac_cur(p_actual_rec
                        ,p_bmtype
                        ,l_period_start_date
                        ,l_period_end_date)
    LOOP

    pl('Vacancy  ',to_char(vac_rec.vacancy_id));
    pl('Openings ',to_char(vac_rec.budget_measurement_value));

    l_total_vacancies := l_total_vacancies+vac_rec.budget_measurement_value;
    --
    -- get the budget value for each employee assignment created from
    -- this vacancy
    --
    FOR asg_rec IN asg_cur(vac_rec.vacancy_id) LOOP
      pl(' Asg ',to_char(asg_rec.assignment_id));

      l_budget_value := hrFastAnswers.getBudgetValue
  	                       (p_budget_metric_formula_id => l_formula_id
        	               ,p_budget_metric            => p_bmtype
                	       ,p_assignment_id            => asg_rec.assignment_id
                           ,p_effective_date           => asg_rec.effective_start_date
                       	   ,p_session_date             => sysdate);

      l_total_assignments := l_total_assignments + l_budget_value;
      pl(p_bmtype,to_char(l_budget_value));

    END LOOP;
  END LOOP;
  --
  -- Calculate the recruitment success rate
  --
  pl('Total vacancies: ',to_char(l_total_vacancies));
  pl('Total assignments: ',to_char(l_total_assignments));

  IF l_total_vacancies = 0 THEN
    l_success_rate := null;
  ELSIF l_total_assignments = 0  THEN
    l_success_rate := 0;
  ELSE
    l_success_rate := round((l_total_assignments / l_total_vacancies ) * 100,1);
  END IF;

  pl('+Success rate: ',to_char(l_success_rate));
  pl('*HRRCS Actual','End');

  RETURN l_success_rate;

END hrrcs_actual;

-------------------------------------------------------------------------
--
--  PROCESS RECRUITMENT SUCCESS TARGETS
--
-------------------------------------------------------------------------
--
-- This procedure will calculate the actual recruitment success rates
-- using the target dimensions and will compare it to the target value. If
-- that actual value is below the target value then a notification is sent. The
-- notification is sent to the notIFy responsibility specIFied IN the target.
--
--
PROCEDURE process_hrrcs
            (p_target_rec IN hri_target_rec_type)
 IS

 l_actual            NUMBER;
 l_mod_target        bisfv_targets.target%TYPE;
 l_actual_rec        bis_actual_pub.actual_rec_type;

BEGIN

  pl('*Process Recruitment Success Target','Start');

  -- Convert the data from target record format into an actual record format
  l_actual_rec := get_bis_actual_rec(p_target_rec);

  IF p_target_rec.measure_short_name = 'HRRCSFTE' THEN
     l_actual := hrrcs_actual(l_actual_rec,'FTE');
  ELSIF p_target_rec.measure_short_name = 'HRRCSHEAD' THEN
     l_actual := hrrcs_actual(l_actual_rec,'HEAD');
  END IF;

  --
  -- Send a notification if the actual success rate is below the
  -- the target success rate.
  -- If a value of -1 has been returned
  -- then abort processing as an error has occurred.
  --
  IF l_actual = -1 THEN
    null;
  ELSE
    IF p_target_rec.notify_resp1_id IS NOT NULL THEN
      IF validate_resp_org_security
           (p_target_rec.notify_resp1_id
           ,p_target_rec.notify_resp1_appl_id
           ,to_number(p_target_rec.org_level_value_id)) THEN
        l_mod_target := p_target_rec.target - percent(p_target_rec.target,p_target_rec.range1_low);
        pl(' Processing responsibility 1: ',p_target_rec.notify_resp1_short_name);
        pl(' Modified target: ',l_mod_target);
        pl(' Actual: ',l_actual);
        IF l_actual < l_mod_target THEN
          send_notification_hrrcs(1
                                 ,l_mod_target
                                 ,l_actual
                                 ,p_target_rec);
        END IF;  -- actual < target
      END IF;  -- valid resp1_id security
    END IF;  --notify_resp1_id not null
    --
    IF p_target_rec.notify_resp2_id IS NOT NULL THEN
      IF validate_resp_org_security
           (p_target_rec.notify_resp2_id
           ,p_target_rec.notify_resp2_appl_id
           ,to_number(p_target_rec.org_level_value_id)) THEN
        l_mod_target := p_target_rec.target - percent(p_target_rec.target,p_target_rec.range2_low);
        pl(' Processing responsibility 2: ',p_target_rec.notify_resp2_short_name);
        pl(' Modified target: ',l_mod_target);
        pl(' Actual: ',l_actual);
        IF l_actual < l_mod_target THEN
        send_notification_hrrcs(2
                               ,l_mod_target
                               ,l_actual
                               ,p_target_rec);
        END IF;  -- actual < target
      END IF;  -- valid resp2_id security
    END IF;  --notify_resp2_id not null
    --
    IF p_target_rec.notify_resp3_id IS NOT NULL THEN
      IF validate_resp_org_security
           (p_target_rec.notify_resp3_id
           ,p_target_rec.notify_resp3_appl_id
           ,to_number(p_target_rec.org_level_value_id)) THEN
        l_mod_target := p_target_rec.target - percent(p_target_rec.target,p_target_rec.range3_low);
        pl(' Processing responsibility 3: ',p_target_rec.notify_resp3_short_name);
        pl(' Modified target: ',l_mod_target);
        pl(' Actual: ',l_actual);
        IF l_actual < l_mod_target THEN
        send_notification_hrrcs(3
                               ,l_mod_target
                               ,l_actual
                               ,p_target_rec);
        END IF;  -- actual < target
      END IF;  -- valid resp3_id security
    END IF;  --notify_resp3_id not null
  END IF;  -- actual = -1

  pl('*Process Recruitment Success Target','End');

END process_hrrcs;

-- **********************************************************************
--
--                       TRAINING SUCCESS
--
-- **********************************************************************

-------------------------------------------------------------------------
--
--  Procedure: send_notification_HRTRS
--
-------------------------------------------------------------------------


PROCEDURE send_notification_hrtrs
           (p_resp_no     IN NUMBER
           ,p_target      IN NUMBER
           ,p_actual      IN NUMBER
           ,p_target_rec  IN hri_target_rec_type)
 IS

 l_subject          fnd_new_messages.message_text%TYPE;
 l_message          VARCHAR2(2000);
 l_freq_code        VARCHAR2(4);
 l_periods          NUMBER;
 l_dummy            VARCHAR2(2000);
 l_start_date       date;
 l_return_status    VARCHAR2(2000);
 l_param            VARCHAR2(2000);
 l_error            VARCHAR2(2000);

 l_report_name      VARCHAR2(8) := 'HRTRNSUC';

 l_activity_version_name  	ota_activity_versions.version_name%TYPE;	-- name of training course (activity version)
 l_actual           VARCHAR2(80);                      -- Actual value (e.g. 25%)
 l_job_cat          hr_lookups.meaning%TYPE;           -- Job category
 l_job_name         per_jobs.name%TYPE;	               -- Job name
 l_loc_name         hr_locations.location_code%TYPE;   -- Location name
 l_org_name         per_organization_units.name%TYPE;  -- Organization name
 l_org_type         hr_lookups.meaning%TYPE;           --
 l_orgprc           hr_lookups.meaning%TYPE;           -- include subordinate indicator (yes/no)
 l_target			VARCHAR2(80);                      -- Target value (e.g. 75%)
 l_period_name      VARCHAR2(50);

 -- Session params
 l_security_group_id  per_business_groups.security_group_id%TYPE;
 l_business_group_id  hr_all_organization_units.business_group_id%TYPE;
 l_resp_id            fnd_responsibility.responsibility_id%TYPE;
 l_resp_short_name    bisfv_targets.notify_resp1_short_name%TYPE;
 l_resp_name          bisfv_targets.notify_resp1_name%TYPE;
 l_resp_appl_id       fnd_responsibility.application_id%TYPE;

BEGIN

  pl('----------------------------------');
  pl('*SEND Training Success notification','Start');
  pl('----------------------------------');
  -----------------------------------------------------------------------
  -- Build the notification subject line and message text
  -----------------------------------------------------------------------
  --
  -- Get the following information that will be shown on the notification
  -- and populate the relevant tokens in the message HR_BIS_PMF_SUBJECT
  --
  -- 1. Get Session parameters for the report
  -- 2. Get Parameter Names:
  --    Organzation
  --    Location
  --    Job or Job Category
  --    Training Activity
  --    Period
  -- 3. build notification text
  -- 4. get the report frequency, number of periods and start date
  -- 5. build the report parameter string
  -- 6. start the workflow process
  --
  -- ---------------------------------------------------------------------
  -- 1. Get Session parameters for the report
  -- ---------------------------------------------------------------------
  get_resp_details(p_resp_no
                  ,p_target_rec
                  ,l_resp_id
                  ,l_resp_appl_id
                  ,l_resp_short_name
                  ,l_resp_name);
  l_business_group_id := get_org_business_group_id(p_target_rec.org_level_value_id);
  l_security_group_id := get_org_security_group_id(p_target_rec.org_level_value_id);
  -- ---------------------------------------------------------------------
  -- 2. Get the parameter names
  -- ---------------------------------------------------------------------
  --
  -- Organization
  --
  hr_reports.get_organization(p_target_rec.org_level_value_id,l_org_name,l_dummy);
  l_orgprc   := translate_orgprc(g_orgprc_const);
  pl(' org name: ',l_org_name);
  --
  -- Location
  --
  l_loc_name := translate_location(p_target_rec.dim1_level_value_id);
  pl(' loc name: ',l_loc_name);
  --
  -- Job / Job Category
  --
  IF p_target_rec.dim2_level_short_name = 'JOB' THEN
     l_job_name := hr_reports.get_job(p_target_rec.dim2_level_value_id);
     l_job_cat  := translate_all;
  ELSIF p_target_rec.dim2_level_short_name = 'JOB CATEGORY' THEN
     l_job_name := translate_all;
     l_job_cat  := hr_reports.get_lookup_meaning('JOB_CATEGORIES',p_target_rec.dim2_level_value_id);
  ELSIF p_target_rec.dim2_level_short_name = 'TOTAL JOBS' THEN
     l_job_name := translate_all;
     l_job_cat  := translate_all;
  END IF;
  pl(' job name: ',l_job_name);
  pl(' jobcat name: ',l_job_cat);
  --
  -- Training Activity Version
  --
  l_activity_version_name := get_activity_version_name(p_target_rec.dim3_level_value_id);
  pl(' Train Act Ver name: ',l_activity_version_name);
  --
  -- Period Name
  --
  l_period_name := to_char(p_target_rec.period_start_date,'DD-MON-YYYY')
                           ||' - '||to_char(p_target_rec.period_END_date,'DD-MON-YYYY');
  pl(' Period Name:',l_period_name);
  --
  -- Include % on target and actual values
  --
  l_actual := to_char(p_actual)||'%';
  l_target := to_char(p_target)||'%';
  -- ---------------------------------------------------------------------
  -- 2. Build the notification text
  -- ---------------------------------------------------------------------
  --
  -- Build subject message text
  --
  fnd_message.set_name('HRI','HR_BIS_PMF_HRTRS_SUBJECT');
  l_subject := fnd_message.get;
  --
  -- Build the body message text
  --
  -- If the target has the activity version (i.e. the name of the training course) set
  -- then we need to use the notification that does not include the link to the
  -- training report this is because the training report does not have the activity
  -- version as a parameter
  --
  IF p_target_rec.dim3_level_short_name = 'TOTAL ACTIVITY VERSIONS' THEN
     fnd_message.set_name('HRI','HR_BIS_PMF_HRTRS_MSG');
  ELSE
     fnd_message.set_name('HRI','HR_BIS_PMF_HRTRS_MSG_NO_URL');
  END IF;
  fnd_message.set_token('ORGANIZATION',l_org_name);
  fnd_message.set_token('LOCATION',l_loc_name);
  fnd_message.set_token('JOB',l_job_name);
  fnd_message.set_token('CATEGORY',l_job_cat);
  fnd_message.set_token('ACTIVITY',l_activity_version_name);
  fnd_message.set_token('PERIOD',l_period_name);
  fnd_message.set_token('TARGET',l_target);
  fnd_message.set_token('ACTUAL',l_actual);
  --fnd_message.set_token('ROLE',l_resp_name);
  l_message := fnd_message.get;
  pl(' Message:', l_message);

  -- ---------------------------------------------------------------------
  -- 4. build the report parameter string
  -- ---------------------------------------------------------------------
  -- Build the url that will be used to run the report from the
  -- notification.
  l_report_name := 'HRTRNSUC';

  get_report_date_params(p_target_rec.time_level_short_name
                        ,p_target_rec.period_start_date
                        ,l_freq_code
                        ,l_start_date);

  pl(' Frequency: ',l_freq_code);
  pl(' Start date: ',to_char(l_start_date,'DD-MON-YYYY'));

  l_param   :=  'org_id='   ||p_target_rec.org_level_value_id   ||'*'||
                'orgprc='   ||g_orgprc_const                    ||'*'||
                'bpl_id='   ||p_target_rec.plan_id              ||'*'||
                'loc_id='   ||p_target_rec.dim1_level_value_id  ||'*'||
                'frqncy='   ||l_freq_code                       ||'*'||
                'startd='   ||to_char(l_start_date,'YYYY-MM-DD')||'*'||
                'end_dt='   ||to_char(p_target_rec.period_end_date,'YYYY-MM-DD')||'*';

   IF p_target_rec.dim2_level_short_name = 'JOB' THEN
     l_param := l_param ||
                'job_id='||p_target_rec.dim2_level_value_id||'*'||
                'jobcat=__ALL__*';
   ELSIF p_target_rec.dim2_level_short_name = 'JOB CATEGORY' THEN
     l_param := l_param ||
                'jobcat='||p_target_rec.dim2_level_value_id||'*'||
                'job_id=-1*';
   ELSIF p_target_rec.dim2_level_short_name = 'TOTAL JOBS' THEN
     l_param := l_param ||
                'jobcat=__ALL__*'||
                'job_id=-1*';
   END IF;

   l_param := l_param ||
              c_ampersand||'responsibility_application_id='
                         ||to_char(l_resp_appl_id)||
              c_ampersand||'security_group_id='
                         ||l_security_group_id;

  pl('wf      ',p_target_rec.workflow_item_type);
  pl('process ',p_target_rec.workflow_process_short_name);
  pl('resp    ',l_resp_short_name);
  pl('resp id ',to_char(l_resp_id));
  pl('applic  ',to_char(l_resp_appl_id));
  pl('secgrp  ',l_security_group_id);
  pl('param   ',substr(l_param,1,240));
  pl('report  ',l_report_name);
  pl('message ',substr(l_message,1,240));
  pl('subject ',l_subject);
  -- ---------------------------------------------------------------------
  -- 5. start the workflow process
  -- ---------------------------------------------------------------------
  pl(' start workflow process');
  bis_util.strt_wf_process
		(p_exception_message	=> l_message
		,p_msg_subject		    => l_subject
		,p_exception_date	    => sysdate
 	    ,p_item_type            => p_target_rec.workflow_item_type
		,p_wf_process		    => p_target_rec.workflow_process_short_name
		,p_notify_resp_name     => l_resp_short_name
		,p_report_name1		    => l_report_name
		,p_report_param1	    => l_param
        ,p_report_resp1_id     	=> l_resp_id
        ,x_return_status       	=> l_return_status);

  pl(' Resp id',to_char(l_resp_id));

  pl(' Workflow return status: ',l_return_status);

  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    RAISE e_g_bis_fn_error;
  END IF;

  pl('*SEND Training Success notification','End');

END;

-------------------------------------------------------------------------
--
--  CALCULATE ACTUAL TRAINING SUCCESS
--
-------------------------------------------------------------------------
--
-- This function will return the actual training success rate based on
-- the dimensions held in the p_target_rec record. This record is either
-- populated from infrmation contained in the target or when posting actuals
-- it is populated from the performance measure section of the configurable
-- home page. The actual training success rate is expressed as a percentage of
-- successful training hours against total training hours
--


FUNCTION hrtrs_actual
           (p_actual_rec  IN bis_actual_pub.actual_rec_type)
 RETURN NUMBER
 IS

l_actual              NUMBER;
l_these_hours         NUMBER;
l_total_delivered     NUMBER;
l_total_success       NUMBER;

l_period_start_date   DATE;
l_period_end_date     DATE;

l_business_group_id   NUMBER;

l_formula_id          ff_formulas_f.formula_id%TYPE;

-- get the training duration for each attendance to a scheduled event
-- that start date lies between the period start and end date
--
-- This Cursor has been changed due to bug 1718083 to be exactly the same
-- as the Workforce Total report. JRHYDE
--
CURSOR train_dur_cur(p_c_actual_rec         bis_actual_pub.actual_rec_type
                    ,p_c_period_start_date  DATE
                    ,p_c_period_end_date    DATE)
  IS
 SELECT asg.assignment_id
      , asg.organization_id
      , evt.duration
      , evt.duration_units
      , ver.version_name
      , evt.title
      , dbk.successful_attendance_flag
   FROM per_assignments_f        asg
      , ota_booking_status_types bst
      , ota_activity_versions    ver
      , ota_events               evt
      , ota_delegate_bookings    dbk
  WHERE dbk.delegate_assignment_id = asg.assignment_id
    AND evt.course_start_date BETWEEN
           asg.effective_start_date AND asg.effective_end_date
    AND dbk.booking_status_type_id = bst.booking_status_type_id
    AND bst.type = 'A'  -- Attended
    AND dbk.event_id = evt.event_id
    AND asg.assignment_type = 'E'
    AND evt.event_type = 'SCHEDULED'
    AND evt.activity_version_id = ver.activity_version_id
    AND nvl(evt.event_status, 'X') <> 'C' /*Not Cancelled*/
    /* Time Dim */
    AND evt.course_end_date < trunc(sysdate)
    AND evt.course_end_date BETWEEN
          p_c_period_start_date AND
          p_c_period_end_date
    /* Org Dim*/
    AND asg.organization_id = p_c_actual_rec.org_level_value_id
    /* Dim 1  Location*/
    AND (  (p_c_actual_rec.dim1_level_value_name = 'LOCATION'
        AND asg.location_id = p_c_actual_rec.dim1_level_value_id)
      OR   (p_c_actual_rec.dim1_level_value_name = 'TOTAL GEOGRAPHY')
        )
    /* Dim 2 Job or Job Category*/
    AND (  (p_c_actual_rec.dim2_level_value_name = 'TOTAL JOBS')
       OR  (p_c_actual_rec.dim2_level_value_name = 'JOB CATEGORY'
        AND asg.job_id IN (SELECT jei.job_id
                             FROM per_job_extra_info jei
                            WHERE jei.jei_information1 = p_c_actual_rec.dim2_level_value_id))
      OR   (p_c_actual_rec.dim2_level_value_name = 'JOB'
       AND  asg.job_id = p_c_actual_rec.dim2_level_value_id)
        )
    /* Dim 3 Activity Version */
    AND (  (p_c_actual_rec.dim3_level_value_name = 'ACTIVITY VERSION'
        AND evt.activity_version_id = p_c_actual_rec.dim3_level_value_id)
      OR   (p_c_actual_rec.dim3_level_value_name = 'TOTAL ACTIVITY VERSIONS')
        );

BEGIN

  pl('*HRTRS actual','Start');

  -- Initialise the hours counters
  l_total_delivered := 0;
  l_total_success   := 0;

  l_business_group_id := get_org_business_group_id(to_number(p_actual_rec.org_level_value_id));

  l_formula_id        := get_formula_id(l_business_group_id
                                      ,'BIS_TRAINING_CONVERT_DURATION');
  pl(' Formula id: ',to_char(l_formula_id));

  --Get start and end dates from the time dim
  get_dates_from_time_dim
    (p_actual_rec.time_level_value_id
    ,l_period_start_date
    ,l_period_end_date);


  --
  -- Loop through all training duration rows
  --
  FOR evt_dur_rec IN train_dur_cur(p_actual_rec
                                  ,l_period_start_date
                                  ,l_period_end_date)
    LOOP
    pl(' Asg id: ',to_char(evt_dur_rec.assignment_id));
    pl(' Duration: ', to_char(evt_dur_rec.duration));
    pl(' Duration Units: ', evt_dur_rec.duration_units);
    -- Run FF to convert duration to hours
    l_these_hours := HrFastAnswers.TrainingConvertDuration
                      (l_formula_id
                      ,evt_dur_rec.duration
                      ,evt_dur_rec.duration_units
                      ,'H'
                      ,evt_dur_rec.version_name
                      ,evt_dur_rec.title
                      ,sysdate);
    -- Ensure that if the fast formula returns null
    -- the total isn't corrupted
    IF l_these_hours IS NOT NULL THEN
      l_total_delivered := l_total_delivered + l_these_hours;
      pl(' Successful Attendance: ', evt_dur_rec.successful_attendance_flag);
      IF evt_dur_rec.successful_attendance_flag = 'Y' THEN
        l_total_success := l_total_success + l_these_hours;
      END IF;
    END IF;
  END LOOP;

  pl('Total delivered: ',to_char(l_total_delivered));
  pl('Total success: ',to_char(l_total_success));
  --
  -- Calculate the success rate and return value
  --
  IF l_total_delivered = 0 THEN
    l_actual := NULL;
  ELSIF l_total_success = 0 THEN
    l_actual := 0;
  ELSE
    l_actual := round(( l_total_success / l_total_delivered  ) * 100,1);
  END IF;

  pl('Actual : ',to_char(l_actual));
  pl('*HRTRS actual','End');
  RETURN l_actual;

END;

-------------------------------------------------------------------------
--
-- PROCESS TRAINING SUCCESS TARGETS
--
-------------------------------------------------------------------------

PROCEDURE process_hrtrs
           (p_target_rec  IN hri_target_rec_type)
 IS

l_actual                NUMBER;
l_mod_target            NUMBER;
l_org_struct_version_id per_org_structure_versions.org_structure_version_id%TYPE;

l_actual_rec            bis_actual_pub.actual_rec_type;

BEGIN

  pl('*Processing Training Success Target','Start');

  -- hrFastAnswers.LoadOrgHierarchy(p_target_rec.org_level_value_id,l_org_struct_version_id);

  -- Convert the data from target record format into an actual record format
  l_actual_rec := get_bis_actual_rec(p_target_rec);

  l_actual := hrtrs_actual(l_actual_rec);

  --
  -- Send a notification if the actual success rate is below the
  -- the target success rate. If a value of -1 has been returned
  -- then abort processing as an error has occurred.
  --

  IF l_actual = -1 THEN
    null;
  ELSE
    IF p_target_rec.notify_resp1_id IS NOT NULL THEN
      IF validate_resp_org_security
         (p_target_rec.notify_resp1_id
         ,p_target_rec.notify_resp1_appl_id
         ,to_number(p_target_rec.org_level_value_id)) THEN
        l_mod_target := p_target_rec.target - percent(p_target_rec.target,p_target_rec.range1_low);
        pl(' Processing responsibility 1: ',p_target_rec.notify_resp1_short_name);
        pl(' Modified target: ',l_mod_target);
        pl(' Actual: ',l_actual);
        IF l_actual < l_mod_target THEN
          send_notification_hrtrs(1
                                 ,l_mod_target
                                 ,l_actual
                                 ,p_target_rec);
        END IF;  -- actual < target
      END IF;  -- valid resp1_id security
    END IF;  --notify_resp1_id not null
    --
    IF p_target_rec.notify_resp2_id IS NOT NULL THEN
      IF validate_resp_org_security
         (p_target_rec.notify_resp2_id
         ,p_target_rec.notify_resp2_appl_id
         ,to_number(p_target_rec.org_level_value_id)) THEN
        l_mod_target := p_target_rec.target - percent(p_target_rec.target,p_target_rec.range2_low);
        pl(' Processing responsibility 2: ',p_target_rec.notify_resp2_short_name);
        pl(' Modified target: ',l_mod_target);
        pl(' Actual: ',l_actual);
        IF l_actual < l_mod_target THEN
          send_notification_hrtrs(2
                                 ,l_mod_target
                                 ,l_actual
                                 ,p_target_rec);
        END IF;  -- actual < target
      END IF;  -- valid resp2_id security
    END IF;  --notify_resp2_id not null
    --
    IF p_target_rec.notify_resp3_id IS NOT NULL THEN
      IF validate_resp_org_security
         (p_target_rec.notify_resp3_id
         ,p_target_rec.notify_resp3_appl_id
         ,to_number(p_target_rec.org_level_value_id)) THEN
        l_mod_target := p_target_rec.target - percent(p_target_rec.target,p_target_rec.range1_low);
        pl(' Processing responsibility 3: ',p_target_rec.notify_resp3_short_name);
        pl(' Modified target: ',l_mod_target);
        pl(' Actual: ',l_actual);
        IF l_actual < l_mod_target THEN
          send_notification_hrtrs(3
                                 ,l_mod_target
                                 ,l_actual
                                 ,p_target_rec);
        END IF;  -- actual < target
      END IF;  -- valid resp3_id security
    END IF;  --notify_resp3_id not null
  END IF; -- actual = -1

  pl('*Processing Training Success Target','End');

END;
-------------------------------------------------------------------------
-- *********************************************************************
-------------------------------------------------------------------------
-- *********************************************************************
--
--                        END OF PMF DEFINITIONS
--
-- *********************************************************************
-------------------------------------------------------------------------
-- *********************************************************************
-------------------------------------------------------------------------

-------------------------------------------------------------------------
--  Procedure:    Post_target_level_actuals
--
--  Parameters:   Target_rec - Target Record containing all required
--                information pertaining to the original target param
--
--  Description
--                This procedure loops through all the user selections
--                i.e. the required actuals, and calculates the
--                corresponding actuals for each and posts to the actuals
--                table (using post_actuals).
--
-------------------------------------------------------------------------
PROCEDURE post_target_level_actuals
           (p_target_rec  IN hri_target_rec_type)
  IS

  --Table of records containing the users indicator selections
  -- i.e. what the users want to see on their home page
  l_user_selection_tbl       bis_INDICATOR_REGION_PUB.indicator_Region_Tbl_Type;

  --Needed to pass target_level_short_name into the bis record
  --bis_actual_pub.retrieve_user_selections
  l_target_level_rec         bis_TARGET_LEVEL_PUB.Target_Level_Rec_Type;

  -- Needed to pass specification to post_actuals
  l_actual_rec               bis_ACTUAL_PUB.Actual_Rec_Type;

  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_error_tbl                bis_UTILITIES_PUB.Error_Tbl_Type;
  i                          NUMBER := 0;
  l_actual                   NUMBER(38,2);

  l_security_group_id  per_business_groups.security_group_id%TYPE;

BEGIN
  pl('--------------------');
  pl('*POST TARGET LEVEL ACTUALS','Start');
  --
  -- Get all the user selections (these are the performance measures that the user
  -- has setup on their home page). We only get the ones for the current target level
  -- this means that to dISplay actuals on the home page providing they have targets
  -- set up.
  --
  pl('Retreive User Selections');
  l_target_level_rec.target_Level_Short_Name  := p_target_rec.target_level_short_name;
  pl(' target_level_short_name',p_target_rec.target_level_short_name);

  bis_actual_pub.Retrieve_User_Selections
    ( p_api_version                  => 1.0
     ,p_Target_Level_Rec             => l_Target_Level_Rec
     ,x_indicator_Region_Tbl         => l_user_selection_Tbl
     ,x_return_status                => l_return_status
     ,x_msg_count                    => l_msg_count
     ,x_msg_data                     => l_msg_data
     ,x_error_Tbl                    => l_error_tbl
    );
  pl('return status: ',l_return_status);

  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
    -- One reason for excpetion may be that 0 rows are returned
    -- hence the use of an exception to stop this bombing the
    -- whole process and not calcing the targets
    RAISE e_g_bis_fn_error;
  END IF;

  -- Preparring the actual record
  -- Using p_target_rec VALUES for l_target_rec to stop any un necessary
  -- re querying of this target level data that is correct for the target.
  -- Don't use l_user_selection_tbl.dimx_Level_Value_Name to supply
  -- dimensionx_level_short_name because:
  -- The base table bis_user_ind_selections doesn't contain the short_names
  -- and bis_actual_pub.retrieve_user_selections which calls
  -- bis_indicator_region_pvt.rectrieve_user_ind_selections - doesn't
  -- actually query this from bis_target_levels and put it in the
  -- l_user_selection_tbl!! So have to query these ourselves.
  -- Using the p_target_rec becuase this data is target level info
  -- which is common to all user selections
  l_actual_rec.time_level_value_id       := p_target_rec.time_level_value_id;
  l_actual_rec.org_level_value_name      := p_target_rec.org_level_short_name;
  l_actual_rec.dim1_level_value_name     := p_target_rec.dim1_level_short_name;
  l_actual_rec.dim2_level_value_name     := p_target_rec.dim2_level_short_name;
  l_actual_rec.dim3_level_value_name     := p_target_rec.dim3_level_short_name;
  l_actual_rec.dim4_level_value_name     := p_target_rec.dim4_level_short_name;
  l_actual_rec.dim5_level_value_name     := p_target_rec.dim5_level_short_name;

  pl('Count of user selections ', to_char(l_user_selection_Tbl.COUNT));

  -- Loop through all user selections (for this target level)
  -- calculating and publishing the actuals for each
  FOR i IN 1..l_user_selection_Tbl.count LOOP

    l_actual_rec.target_level_id           := l_user_selection_tbl(i).target_level_id;
    l_actual_rec.target_level_short_name   := l_user_selection_tbl(i).target_level_short_name;
    l_actual_rec.Responsibility_id         := l_user_selection_tbl(i).Responsibility_id;
    l_actual_rec.Responsibility_short_name := l_user_selection_tbl(i).Responsibility_short_name;
    l_actual_rec.Responsibility_name       := l_user_selection_tbl(i).Responsibility_name;
    l_actual_rec.target_level_id           := l_user_selection_tbl(i).target_level_id;
    l_actual_rec.org_level_value_id        := l_user_selection_tbl(i).org_level_value_id;
    l_actual_rec.dim1_level_value_id       := l_user_selection_tbl(i).dim1_level_value_id;
    l_actual_rec.dim2_level_value_id       := l_user_selection_tbl(i).dim2_level_value_id;
    l_actual_rec.dim3_level_value_id       := l_user_selection_tbl(i).dim3_level_value_id;
    l_actual_rec.dim4_level_value_id       := l_user_selection_tbl(i).dim4_level_value_id;
    l_actual_rec.dim5_level_value_id       := l_user_selection_tbl(i).dim5_level_value_id;

    --l_actual_rec.Responsibility_ID         := p_target_rec.notify_resp1_id;
    --l_actual_rec.Responsibility_Short_Name := p_target_rec.notify_resp1_short_name;
    --l_actual_rec.Responsibility_Name       := p_target_rec.notify_resp1_name;

    --debug_bis_actual_rec(l_actual_rec);

    -- Transfer control to the appropriate module which will calculate
    -- and post the actual values to the users home page.
    --
    -- Note: The function retrieve_user_ind_selections does not RETURN
    -- the responsibility AND we are therefore unable to verIFy that
    -- the user is authorized to access information on the given
    -- organization. Core bis have been requested to provide the
    -- responsibility.
    --

    pl('Target Measure Short Name =',p_target_rec.measure_short_name);

    IF p_target_rec.measure_short_name = 'HRMSPFTE' THEN
       l_actual_rec.actual := hrmsp_actual(l_actual_rec,'FTE');
       post_actual(l_actual_rec);
    ELSIF p_target_rec.measure_short_name = 'HRMSPHEAD' THEN
       l_actual_rec.actual := hrmsp_actual(l_actual_rec,'HEAD');
       post_actual(l_actual_rec);
    ELSIF p_target_rec.measure_short_name = 'HRMVRFTE' THEN
       l_actual_rec.actual := hrmvr_actual(l_actual_rec,'FTE');
       post_actual(l_actual_rec);
    ELSIF p_target_rec.measure_short_name = 'HRMVRHEAD' THEN
       l_actual_rec.actual := hrmvr_actual(l_actual_rec,'HEAD');
       post_actual(l_actual_rec);
    ELSIF p_target_rec.measure_short_name = 'HRRCSFTE' THEN
       l_actual_rec.actual := hrrcs_actual(l_actual_rec,'FTE');
       post_actual(l_actual_rec);
    ELSIF p_target_rec.measure_short_name = 'HRRCSHEAD' THEN
       l_actual_rec.actual := hrrcs_actual(l_actual_rec,'HEAD');
       post_actual(l_actual_rec);
    ELSIF p_target_rec.measure_short_name = 'HRTRS' THEN
       l_actual_rec.actual := hrtrs_actual(l_actual_rec);
       post_actual(l_actual_rec);
    END IF;

  END LOOP;

  pl('*POST TARGET LEVEL ACTUALS','End');
  pl('--------------------');
EXCEPTION
-- Need to continue if this exceptions so the process can continue
-- with processing the targets
 WHEN OTHERS THEN
  NULL;

END post_target_level_actuals;

--***********************************************************************
--
--    PUBLIC FUNCTIONS AND PROCEDURE
--
--***********************************************************************

------------------------------------------------------------------------------------------------
--
--  Procedure:    Calc_and_post_target_actuals
--
--  Parameters:   Target id
--
--  Description:  This procedure is design as a method of debugging the actual posting methods.
--                Calculates the actuals for the target specified without first calculating the
--                targets.
--
------------------------------------------------------------------------------------------------
PROCEDURE calc_and_post_target_actuals
           (p_target_id IN NUMBER
           ,p_date      IN DATE DEFAULT SYSDATE)
  IS

  l_target_rec  hri_target_rec_type;
  l_session_rec hri_session_rec_type;

BEGIN
  pl('*Calc and Post Target Actuals', 'Start');
  pl('Target id',to_char(p_target_id));
  l_session_rec := get_session;
  debug_session(l_session_rec);

  l_target_rec  := get_target_rec(p_target_id);
  post_target_level_actuals(l_target_rec);

END calc_and_post_target_actuals;
------------------------------------------------------------------------------------------------
--
--  Procedure:    PROCESS_PMF_ALERT
--
--  Parameters:   Target id
--
--  Description
--                This procedure is the common entry point for all HR target values. It IS
--                called by the HR alerts for each target value selected for processing (refer
--                to the HR alerts for more details of the selection procedure). The procedure
--                will retreive details of the target AND pass control to the relevant routine.
--
--                The performance measures currently supported are:
--
--                MSP = Manpower separation
--                MVR = Manpower variance
--                TRS = Training success
--                RCS = Recruitment success
--
--
--  Note
--                To verify that the actual has been posted check in:
--                   BIS.BIS_ACTUAL_VALUES
--                To verify that the notification has been posted check in:
--                   APPLSYS.WF
------------------------------------------------------------------------------------------------

PROCEDURE process_target
           (p_target_id IN NUMBER)
  IS

l_subject	VARCHAR2(80);
l_message	VARCHAR2(2000);
l_date		date;
l_param		VARCHAR2(2000);

l_target_rec  hri_target_rec_type;
l_session_rec hri_session_rec_type;

e_fatal_error       exception;
e_pm_not_found 		exception;
e_pm_not_known		exception;
e_tl_not_found  	exception;
e_tv_not_found  	exception;
e_pd_not_found  	exception;

BEGIN

  pl('*PROCESS TARGET ','Start');
  pl(' TARGET = ',to_char(p_target_id));

  --get the session, record to package globals and output details to debug
  g_session_rec := get_session;
  debug_session(g_session_rec);

  ----------------------------------------------------------------------------------
  -- Get the target's details
  ----------------------------------------------------------------------------------
  l_target_rec := Get_Target_Rec(p_target_id);

  debug_hri_target_rec(l_target_rec);

  ---------------------------------------------------------------------------------
  -- Rerieve user selections and calculate the respective actuals
  -- This is prior to the target calculations as a precution
  --  because in the target calculations the apps globals may be changed
  --  causing issues with inserting actuals see bug 1413300
  ----------------------------------------------------------------------------------
  post_target_level_actuals(l_target_rec);

  -- Check if any of the responsibilities exist
  -- Otherwise skip the target processing and exit
  IF (l_target_rec.notify_resp1_id IS NOT NULL
     OR
    l_target_rec.notify_resp2_id IS NOT NULL
     OR
    l_target_rec.notify_resp3_id IS NOT NULL
    ) THEN

    pl('Checking responsibilities of targets');
    ----------------------------------------------------------------------------------
    -- Transfer control to the correct module
    ----------------------------------------------------------------------------------
    -- PROCESS_HRMSP Manpower separation
    -- PROCESS_HRMVR Manpower variance
    -- PROCESS_HRRCS Recruitment success
    -- PROCESS_HRTRS Training success
    IF l_target_rec.measure_short_name IN ('HRMSPFTE','HRMSPHEAD') THEN
        process_hrmsp(l_target_rec);
    ELSIF l_target_rec.measure_short_name IN ('HRMVRFTE','HRMVRHEAD') THEN
        process_hrmvr(l_target_rec);
    ELSIF l_target_rec.measure_short_name IN ('HRRCSFTE','HRRCSHEAD') THEN
        process_hrrcs(l_target_rec);
    ELSIF l_target_rec.measure_short_name = 'HRTRS' THEN
        process_hrtrs(l_target_rec);
    END IF;
  END IF; -- A target resp exists

  pl('*PROCESS TARGET ','END');
/*
EXCEPTION
 WHEN OTHERS THEN
  g_error_msg := substr(sqlerrm,1,2000);
  RAISE;
*/
END process_target;

END;

/
