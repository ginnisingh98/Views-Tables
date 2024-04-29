--------------------------------------------------------
--  DDL for Package Body PA_DISPLAY_PERIOD_MASKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DISPLAY_PERIOD_MASKS" AS
/*$Header: PAFPPMKB.pls 120.2 2006/02/24 00:04:20 prachand noship $*/

--g_module_name VARCHAR2(100) := 'pa.plsql.PA_DISPLAY_PERIOD_MASKS';

  --P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  g_plan_period_start_name      gl_periods.period_name%TYPE := NULL;
  g_plan_period_start_date      gl_periods.end_date%TYPE := to_date(NULL);
  g_plan_period_end_name        gl_periods.period_name%TYPE := NULL;
  g_plan_period_end_date        gl_periods.end_date%TYPE := to_date(NULL);
  g_cpp_start_date              gl_periods.start_date%TYPE := to_date(NULL);
  g_cpp_end_date                gl_periods.end_date%TYPE := to_date(NULL);
  --g_tab_deleted                 boolean := FALSE;

  -- Bug Fix 3671424.
  -- Removing the hard coded string proeceeding and succeding in the code
  -- with the appropriate lookup meanings which 'll be translated.

  g_preceeding                  pa_lookups.meaning%TYPE := NULL;
  g_succeeding                  pa_lookups.meaning%TYPE := NULL;
  g_to                          pa_lookups.meaning%TYPE := NULL;



/*  get_current_period_start_date() will get the current periods start date
--  it MUST have the following parameters:
--  current_planning_period,
--	period_set_name,
--  time_phase_code,
--	and either accounterd_period_type set for 'GL'
--	OR pa_period_type set for 'PA'
--	it is called by get_periods()
*/

  FUNCTION get_current_period_start_date ( p_current_planning_period IN pa_budget_versions.current_planning_period%TYPE
                                           ,p_period_set_name        IN gl_sets_of_books.period_set_name%TYPE
										   ,p_time_phase_code        IN pa_proj_fp_options.cost_time_phased_code%TYPE
										   ,p_accounted_period_type  IN gl_sets_of_books.accounted_period_type%TYPE
										   ,p_pa_period_type         IN pa_implementations_all.pa_period_type%TYPE)
										   RETURN DATE IS

  l_current_period_start_date DATE; --RETURN value

/*
--  gl_periods_start_date_csr uses the decode function as follows :
--  if time phase code = 'G' then use accounted_period_type
--  if time phase code = 'P' then use pa_period_type
*/


  CURSOR gl_periods_start_date_csr IS
    SELECT gp.start_date
          ,gp.end_date
      FROM gl_periods gp
     WHERE gp.period_name            = p_current_planning_period
       AND gp.period_set_name        = p_period_set_name
       AND gp.period_type            = decode(P_time_phase_code,'G',p_accounted_period_type,'P',P_pa_period_type)
       AND gp.adjustment_period_flag = 'N';

  gl_periods_start_date_rec gl_periods_start_date_csr%ROWTYPE;

  BEGIN
    OPEN  gl_periods_start_date_csr;
    FETCH gl_periods_start_date_csr INTO gl_periods_start_date_rec;
    IF gl_periods_start_date_csr%NOTFOUND THEN
	      NULL;
              --hr_utility.trace('get_current_period_start_date.gl_periods_start_date_csr does not contain anything! exception');
              g_cpp_start_date := NULL;
              g_cpp_end_date   := NULL;
    ELSE
          l_current_period_start_date := gl_periods_start_date_rec.start_date;

              g_cpp_start_date := gl_periods_start_date_rec.start_date;
              g_cpp_end_date   := gl_periods_start_date_rec.end_date;

          --hr_utility.trace('g_cpp_start_date := '||to_char(g_cpp_start_date));
          --hr_utility.trace('g_cpp_end_date := '||to_char(g_cpp_end_date));

    END IF;
    CLOSE gl_periods_start_date_csr;

    RETURN l_current_period_start_date;

  END get_current_period_start_date;



  PROCEDURE get_plan_period_end ( p_planning_end_date       IN pa_resource_assignments.planning_end_date%TYPE
                                ,p_period_set_name          IN gl_sets_of_books.period_set_name%TYPE
                                ,p_time_phase_code          IN pa_proj_fp_options.cost_time_phased_code%TYPE
                                ,p_accounted_period_type    IN gl_sets_of_books.accounted_period_type%TYPE
                                ,p_pa_period_type           IN pa_implementations_all.pa_period_type%TYPE
                                )
IS



  CURSOR plan_period_end_csr IS
    SELECT gp.end_date
          ,gp.period_name
      FROM gl_periods gp
     WHERE p_planning_end_date BETWEEN gp.start_date AND gp.end_date
       AND gp.period_set_name        = p_period_set_name
       AND gp.period_type            = decode(P_time_phase_code,'G',p_accounted_period_type,'P',P_pa_period_type)
       AND gp.adjustment_period_flag = 'N';

  plan_period_end_rec plan_period_end_csr%ROWTYPE;

  BEGIN
    OPEN  plan_period_end_csr;
    FETCH plan_period_end_csr INTO plan_period_end_rec;
    IF plan_period_end_csr%NOTFOUND THEN
	      NULL;
              --hr_utility.trace('plan_period_end.plan_period_end_csr does not contain anything! exception');
              g_plan_period_end_name := NULL;
              g_plan_period_end_date := NULL;
    ELSE
              g_plan_period_end_name := plan_period_end_rec.period_name;
              g_plan_period_end_date := plan_period_end_rec.end_date;
          --hr_utility.trace('g_plan_period_end_name := '||g_plan_period_end_name);
          --hr_utility.trace('g_plan_period_end_date := '||g_plan_period_end_date);
    END IF;
    CLOSE plan_period_end_csr;

  END get_plan_period_end;



  PROCEDURE get_plan_period_start ( p_planning_start_date       IN pa_resource_assignments.planning_start_date%TYPE
                                ,p_period_set_name          IN gl_sets_of_books.period_set_name%TYPE
                                ,p_time_phase_code          IN pa_proj_fp_options.cost_time_phased_code%TYPE
                                ,p_accounted_period_type    IN gl_sets_of_books.accounted_period_type%TYPE
                                ,p_pa_period_type           IN pa_implementations_all.pa_period_type%TYPE
                                )
IS



  CURSOR plan_period_start_csr IS
    SELECT gp.start_date
          ,gp.period_name
      FROM gl_periods gp
     WHERE p_planning_start_date BETWEEN gp.start_date AND gp.end_date
       AND gp.period_set_name        = p_period_set_name
       AND gp.period_type            = decode(P_time_phase_code,'G',p_accounted_period_type,'P',P_pa_period_type)
       AND gp.adjustment_period_flag = 'N';

  plan_period_start_rec plan_period_start_csr%ROWTYPE;

  BEGIN
    OPEN  plan_period_start_csr;
    FETCH plan_period_start_csr INTO plan_period_start_rec;
    IF plan_period_start_csr%NOTFOUND THEN
	      NULL;
              --hr_utility.trace('plan_period_start.plan_period_start_csr does not contain anything! exception');
              g_plan_period_start_name := NULL;
              g_plan_period_start_date  := NULL;
    ELSE
              g_plan_period_start_name := plan_period_start_rec.period_name;
              g_plan_period_start_date := plan_period_start_rec.start_date;
          --hr_utility.trace('g_plan_period_start_name       := '||g_plan_period_start_name);
          --hr_utility.trace('g_plan_period_start_date := '||to_char(g_plan_period_start_date));
    END IF;
    CLOSE plan_period_start_csr;

  END get_plan_period_start;


/*   get_period_mask_start() returns the min from_anchor_start from pa_period_mask_details
--   it will not return rows that have an from_anchor_start with -99999 or 99999
--   these are flags for preceeding and suceeding buckets
--   this function is called from get_periods to populate the pl/sql table with the
--   before anchor date records from gl_periods
*/
  FUNCTION get_period_mask_start( p_period_mask_id IN pa_period_mask_details.period_mask_id%TYPE) RETURN NUMBER
  IS

    l_period_mask_start pa_period_mask_details.from_anchor_start%type; --RETURN value

    CURSOR get_min_csr IS
    SELECT min(from_anchor_start) from_anchor_start_min
      FROM pa_period_mask_details
	 WHERE from_anchor_start NOT IN (-99999,99999)
       AND period_mask_id         =  p_period_mask_id;

   get_min_rec get_min_csr%ROWTYPE;

  BEGIN

    OPEN get_min_csr;
    FETCH get_min_csr INTO get_min_rec;
    IF get_min_csr%NOTFOUND
    THEN
    NULL;
    --hr_utility.trace('get_period_mask_start.get_min_csr does not contain anything! exception');
    ELSE
    l_period_mask_start := get_min_rec.from_anchor_start_min;
    --hr_utility.trace('l_period_mask_start := '||to_char(l_period_mask_start));
    END IF;
    CLOSE get_min_csr;

  RETURN l_period_mask_start;

  END get_period_mask_start;



/*   get_period_mask_end() returns the max from_anchor_end from pa_period_mask_details
--   it will not return rows that have an from_anchor_start with -99999 or 99999
--   these are flags for preceeding and suceeding buckets
--   this function is called from get_periods to populate the pl/sql table with the
--   after anchor date records from gl_periods
*/
  FUNCTION get_period_mask_end  ( p_period_mask_id IN pa_period_mask_details.period_mask_id%TYPE) RETURN NUMBER
  IS

    l_period_mask_end pa_period_mask_details.from_anchor_end%TYPE;

    CURSOR get_max_csr IS
      SELECT max(from_anchor_end) from_anchor_end_max
        FROM pa_period_mask_details
	   WHERE from_anchor_end NOT IN (-99999,99999)
         AND period_mask_id       = p_period_mask_id;

    get_max_rec get_max_csr%ROWTYPE;

  BEGIN

    OPEN get_max_csr;
    FETCH get_max_csr INTO get_max_rec;
    IF get_max_csr%NOTFOUND
    THEN
    NULL;
    --hr_utility.trace('get_period_mask_end.get_max_csr does not contain anything! exception');
    ELSE
    l_period_mask_end := get_max_rec.from_anchor_end_max;
    --hr_utility.trace('l_period_mask_end := '||to_char(l_period_mask_end));
    END IF;
    CLOSE get_max_csr;

    RETURN l_period_mask_end;

  END get_period_mask_end;






/*
--  get_periods() is the main function of this package
--  it populates the periods_tab pl/sql table with rows of data from gl_periods
--  within the masks start and end periods
--  it will also set the global variables g_preceeding_end and g_suceeding_start
--  these will be used for the proceeding buckets end period and suceeding buckets start period
--  get_periods will return 1 if it populates periods_tab pl/sql table successfully
*/
  FUNCTION get_periods ( p_budget_version_id  IN  pa_budget_versions.budget_version_id%TYPE,
                         p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE DEFAULT -1) RETURN NUMBER
  IS
   l_return                    NUMBER := 0; --RETURN value
   l_current_planning_period   pa_budget_versions.current_planning_period%TYPE;
   l_period_set_name           gl_sets_of_books.period_set_name%TYPE;
   l_accounted_period_type     gl_sets_of_books.accounted_period_type%TYPE;
   l_pa_period_type            pa_implementations_all.pa_period_type%TYPE;
   l_time_phase_code           pa_proj_fp_options.cost_time_phased_code%TYPE;
   l_period_mask_id            pa_period_mask_details.period_mask_id%TYPE;
   l_cpp_start_date            DATE;
   l_count                     NUMBER := 0 ; --counter variable
   l_plan_start_date           pa_resource_assignments.planning_start_date%TYPE;
   l_plan_end_date             pa_resource_assignments.planning_end_date%TYPE;


/*
--  get_name_and_type_csr is used to select the parameters needed for
--  get_current_period_start_date(),get_gl_periods_before_csr,get_gl_periods_after_csr
--  get_current_period_start_date() must return a start date for  get_gl_periods_before_csr
--  and get_gl_periods_after_csr to run
--  period_set_name and accounted_period_type exist in table gl_set_of_books
--  current_planning_period and period_mask_id exist in table pa_budget_versions
--  pa_period_type exists in pa_implementations_all
--  to find the time phase code decode is used
--  IF pbv.version_type = COST the time phase code = ppfo.cost_time_phased_code
--  IF pbv.version_type = REVENUE the time phase code = ppfo.revenue_time_phased_code
--  ELSE the time phase code = ppfo.all_time_phased_code
--  p_budget_version_id is a parameter IN
--  use nvl(ppa.org_id,-99)   = nvl(pia.org_id,-99) to return at least one row if columns are null
*/


 CURSOR get_name_and_type_csr IS
   SELECT gsb.period_set_name
         ,gsb.accounted_period_type
	 ,pbv.current_planning_period
	 ,pbv.period_mask_id
	 ,pia.pa_period_type
	 ,decode(pbv.version_type,
	        'COST',ppfo.cost_time_phased_code,
                'REVENUE',ppfo.revenue_time_phased_code,
				 ppfo.all_time_phased_code) time_phase_code
	 FROM gl_sets_of_books       gsb
	     ,pa_implementations_all pia
             ,pa_projects_all        ppa
	     ,pa_budget_versions     pbv
	     ,pa_proj_fp_options     ppfo
	WHERE ppa.project_id        = pbv.project_id
	  AND pbv.budget_version_id = ppfo.fin_plan_version_id
	  AND ppa.org_id            = pia.org_id
	  AND gsb.set_of_books_id   = pia.set_of_books_id
	  AND pbv.budget_version_id = p_budget_version_id;


  CURSOR get_resource_asg_dates IS
         SELECT planning_start_date,
                planning_end_date
          FROM  pa_resource_assignments
         WHERE  resource_assignment_id = p_resource_assignment_id;

  get_name_and_type_rec       get_name_and_type_csr%ROWTYPE;

/*
--  get_gl_periods_before_csr returns all rows from gl_periods
--  before or equal to current planning period start date
--  get_gl_periods_before_csr uses the decode function use the correct period type GL and PA periods
--  G = 'GL' and P = 'PA'
*/

   -- Bug Fix 3663107.
   -- The display mask is not forming properly. This is happening because of the
   -- where condition in this cursos.
   -- Consider the scenario where Current Planning Period is prior to the planning
   -- Start Date.
   -- Current Planning Period is JAN-03 and Planning Start Date is 02-MAR-03.
   -- Due to the where conditions in the cursor to restrict the gl periods before the
   -- current planning period and falling between the planning dates is not
   -- returning any values thus resulting into the wrong mask.
   --
   -- Need to remove the where condition which assumes that the current planning
   -- period is always between the planning periods.
   -- As a fix remove the planning dates restriction here and make sure that
   -- the select which will call the functions in this package are restricting
   -- the constructed mask between the planning dates.
   --
   -- Here in the cursor commenting the following two where conditions
   --
   --     AND gp.end_date              >= nvl(l_plan_start_date, gp.end_date)
   --     AND l_cpp_start_date between g_plan_period_start_date  and g_plan_period_end_datE
   --
   -- Made sure that the select in the FpEditPlanLinesTableVO has the following where cond.
   --
   -- and exists (select 'x' from dual
   --              where (pp.planning_start_date between pp.start_date and pp.end_date OR
   --                     pp.planning_end_date between pp.start_date and pp.end_date OR
   --                     (pp.start_date >= pp.planning_start_date and
   --                     pp.end_date <= pp.planning_end_date)))

   -- End of Fix for Bug 3663107.

   CURSOR get_gl_periods_before_csr IS
     SELECT *
       FROM gl_periods gp
      WHERE gp.period_set_name        = l_period_set_name
        AND gp.period_type            =  decode(l_time_phase_code,'G',l_accounted_period_type,
                                                                  'P',l_pa_period_type)
        AND gp.start_date            <= l_cpp_start_date
        AND gp.adjustment_period_flag = 'N'
        --AND nvl(l_plan_start_date,gp.start_date) between gp.start_date and gp.end_date
        --AND gp.end_date              >= nvl(l_plan_start_date, gp.end_date)
        -- Bug Fix 3475010. Additional PP masks are getting created.
        -- Modified the following where condition as we are trying to compare
        -- Period's start with plan start date instead of the plan's start date's
        -- period's start date.
        -- Need to compare the like wise things.

        -- AND l_cpp_start_date between l_plan_start_date  and l_plan_end_date
        -- AND l_cpp_start_date between g_plan_period_start_date  and g_plan_period_end_datE
      ORDER BY gp.start_date DESC;

/*
--  get_gl_periods_after_csr returns all rows from gl_periods
--  after current planning period start date
--  get_gl_periods_before_csr uses the decode function use the correct period type GL and PA periods
--  G = 'GL' and P = 'PA'
*/
   -- Bug Fix 3663107.
   -- The display mask is not forming properly. This is happening because of the
   -- where condition in this cursos.
   -- Consider the scenario where Current Planning Period is after/between the planning
   -- Start Date/dates.
   -- Current Planning Period is APR-03 and Planning Dates are 02-MAR-03 to 31-DEC-03.
   -- Due to the where conditions in the cursor to restrict the gl periods after the
   -- current planning period and falling between the planning dates is not
   -- returning proper values and resulting into the wrong mask.
   --
   -- Need to remove the where condition which assumes that the current planning
   -- period is always between the planning periods.
   -- As a fix remove the planning dates restriction here and make sure that
   -- the select which will call the functions in this package are restricting
   -- the constructed mask between the planning dates.
   --
   -- Here in the cursor commenting the following two where conditions
   -- AND gp.start_date               <= nvl(g_plan_period_end_date, gp.start_date)
   --
   -- Made sure that the select in the FpEditPlanLinesTableVO has the following where cond.
   --
   -- and exists (select 'x' from dual
   --              where (pp.planning_start_date between pp.start_date and pp.end_date OR
   --                     pp.planning_end_date between pp.start_date and pp.end_date OR
   --                     (pp.start_date >= pp.planning_start_date and
   --                     pp.end_date <= pp.planning_end_date)))

   -- End of Fix for Bug 3663107.

  CURSOR get_gl_periods_after_csr IS
    SELECT *
      FROM gl_periods gp
     WHERE gp.period_set_name        = l_period_set_name
       AND gp.period_type            =  decode(l_time_phase_code,'G',l_accounted_period_type,
                                                                 'P',l_pa_period_type)
       AND gp.start_date             > l_cpp_start_date
       AND gp.adjustment_period_flag = 'N'
        -- Bug Fix 3475010. Additional PP masks are getting created.
        -- Modified the following where condition as we are trying to compare
        -- Period's start with plan end date instead of the plan's end date's
        -- period's end date.
        -- Need to compare the like wise things.
       -- AND gp.start_date               <= nvl(l_plan_end_date, gp.start_date)
       -- AND gp.start_date               <= nvl(g_plan_period_end_date, gp.start_date)
     ORDER BY gp.start_date;

  -- Bug Fix 3671424.
  -- removing the hard coded strings.

l_lookup_type  PA_LOOKUPS.LOOKUP_TYPE%TYPE ;

l_prec  PA_LOOKUPS.LOOKUP_CODE%TYPE ;
l_succ  PA_LOOKUPS.LOOKUP_CODE%TYPE ;
l_to    PA_LOOKUPS.LOOKUP_CODE%TYPE ;

  CURSOR get_preceeding_csr IS
         SELECT meaning
          FROM  pa_lookups
         WHERE  lookup_type = l_lookup_type
           AND   lookup_code = l_prec ;

  CURSOR get_succeeding_csr IS
         SELECT meaning
          FROM  pa_lookups
         WHERE  lookup_type = l_lookup_type
           AND   lookup_code = l_succ ;

  CURSOR get_to_csr IS
         SELECT meaning
          FROM  pa_lookups
         WHERE  lookup_type = l_lookup_type
           AND   lookup_code = l_to ;




  BEGIN
    --hr_utility.trace('Entered PA_DISPLAY_PERIOD_MASKS');

    --hr_utility.trace('p_budget_version_id := '||to_char(p_budget_version_id));
    --hr_utility.trace('p_resource_assignment_id := '||to_char(p_resource_assignment_id));

    -- Bug Fix 3671424
    -- removing the hard coded strings in the code to avoid translation issues.

    l_lookup_type  := 'PA_PERIOD_MASK';
    l_prec  := 'PRECEEDING';
    l_succ  := 'SUCCEEDING';
    l_to    := 'TO';

    OPEN  get_preceeding_csr;
    FETCH get_preceeding_csr INTO g_preceeding;
    CLOSE get_preceeding_csr;

    OPEN  get_succeeding_csr;
    FETCH get_succeeding_csr INTO g_succeeding;
    CLOSE get_succeeding_csr;

    OPEN  get_to_csr;
    FETCH get_to_csr INTO g_to;
    CLOSE get_to_csr;


    OPEN  get_name_and_type_csr;
    FETCH get_name_and_type_csr INTO get_name_and_type_rec;
    IF get_name_and_type_csr%NOTFOUND THEN
    NULL;
    --hr_utility.trace('get_periods.get_name_and_type_csr does not contain anything! exception');
    ELSE
    g_period_mask_id          := get_name_and_type_rec.period_mask_id;
    l_current_planning_period := get_name_and_type_rec.current_planning_period;
    l_period_set_name         := get_name_and_type_rec.period_set_name;
    l_accounted_period_type   := get_name_and_type_rec.accounted_period_type;
    l_pa_period_type          := get_name_and_type_rec.pa_period_type;
    l_time_phase_code         := get_name_and_type_rec.time_phase_code;

    -----remove below after testing ---------
    --hr_utility.trace('g_period_mask_id '||g_period_mask_id);
    --hr_utility.trace('l_current_planning_period '||l_current_planning_period);
    --hr_utility.trace('l_period_set_name '||l_period_set_name);
    --hr_utility.trace('l_accounted_period_type '||l_accounted_period_type);
    --hr_utility.trace('l_pa_period_type '||l_pa_period_type);
    --hr_utility.trace('l_time_phase_code '||l_time_phase_code);
    ----remove above after testing ----------

    l_return := 1; --successful RETURN
    END IF;

    -- Bug Fix 3868062.
    -- Adding close cursor statement.
    CLOSE get_name_and_type_csr;

    OPEN get_resource_asg_dates;
    FETCH get_resource_asg_dates INTO l_plan_start_date, l_plan_end_date;
    IF get_resource_asg_dates%NOTFOUND THEN
       l_plan_start_date := to_date(null);
       l_plan_end_date   := to_date(null);
    END IF;

    -- Bug Fix 3868062.
    -- Adding close cursor statement.
    CLOSE get_resource_asg_dates;

    --hr_utility.trace('l_plan_start_date := '||to_char(l_plan_start_date));
    --hr_utility.trace('l_plan_end_date := '||to_char(l_plan_end_date));

-- calling get_plan_period_start and get_plan_period_end
   --hr_utility.trace('calling get_plan_period_end to populate g_plan_period_end_name and g_plan_period_end_date');
            get_plan_period_end ( p_planning_end_date      => l_plan_end_date
                                 ,p_period_set_name        => l_period_set_name
                                 ,p_time_phase_code        => l_time_phase_code
                                 ,p_accounted_period_type  => l_accounted_period_type
                                 ,p_pa_period_type         => l_pa_period_type
                                 );
   --hr_utility.trace('g_plan_period_end_name       := '||g_plan_period_end_name);
   --hr_utility.trace('g_plan_period_end_date := '||to_char(g_plan_period_end_date));



   --hr_utility.trace('calling get_plan_period_start to populate g_plan_period_start_name and g_plan_period_start_date');
            get_plan_period_start ( p_planning_start_date      => l_plan_start_date
                                   ,p_period_set_name        => l_period_set_name
                                   ,p_time_phase_code        => l_time_phase_code
                                   ,p_accounted_period_type  => l_accounted_period_type
                                   ,p_pa_period_type         => l_pa_period_type
                                   );
   --hr_utility.trace('g_plan_period_start_name     := '||g_plan_period_start_name);
   --hr_utility.trace('g_plan_period_start_date := '||to_char(g_plan_period_start_date));

-- get min AND max of the current mask
    g_get_mask_start := pa_display_period_masks.get_period_mask_start(g_period_mask_id);
    g_get_mask_end   := pa_display_period_masks.get_period_mask_end(g_period_mask_id);

    -----remove below after testing ---------
    --hr_utility.trace('g_get_mask_start '||g_get_mask_start);
    --hr_utility.trace('g_get_mask_end '||g_get_mask_end);
    -----remove above after testing -------------





    l_cpp_start_date := get_current_period_start_date (p_current_planning_period => l_current_planning_period
                                                  ,p_period_set_name         => l_period_set_name
                                                  ,p_time_phase_code         => l_time_phase_code
                                                  ,p_accounted_period_type   => l_accounted_period_type
                                                  ,p_pa_period_type          => l_pa_period_type);

    --hr_utility.trace('l_cpp_start_date :='||to_char(l_cpp_start_date));

/*
--  populate periods_tab pl/sql table with data
--  first delete tables data if  the pl/sql table has session data
*/

/* Commenting out the fix done for bug 3631320 for bug fix 3964651. */

/*
    -- Bug Fix 3631320
    -- blindly deleting this is causing the table population
    -- an overhead. Need to delete this for the first time
    -- subsequently we dont delete but rather we directly read
    -- from it.

    -- To acheive this we use a package variable and populate this
    -- after delete and use this value before deleting again.
*/
   -- IF (periods_tab.first IS NOT NULL AND NOT g_tab_deleted)
    IF periods_tab.first IS NOT NULL
    THEN periods_tab.DELETE;
    --g_tab_deleted := TRUE;
    END IF;
    -----------------BEFORE RECORDS -------------
    l_count := 0;

    FOR rec IN get_gl_periods_before_csr
    LOOP
      IF l_count           >= g_get_mask_start THEN
      periods_tab(l_count) := rec;
      l_count              := l_count - 1;
      ELSE
      NULL;
      END IF;
    END LOOP;

    ---------------AFTER RECORDS -----------------------
    l_count := 0;
    FOR rec in get_gl_periods_after_csr
    LOOP
      l_count := l_count + 1;
      IF l_count           <= g_get_mask_end THEN
      periods_tab(l_count) := rec;
      ELSE
      NULL;
      END IF;
    END LOOP;

   ----- SHOW DATA in TABLES  REMOVE after Testing ----
    g_preceeding_end := to_date(NULL);
    g_suceeding_start := to_date(NULL);

    --hr_utility.trace('First => ' ||periods_tab.FIRST);
    --hr_utility.trace('Last  => ' ||periods_tab.LAST);

    IF periods_tab.COUNT > 0 THEN
       FOR x in periods_tab.first..periods_tab.last
       LOOP

         NULL;
         --hr_utility.trace(x);
         --hr_utility.trace(periods_tab(x).period_name||', '||periods_tab(x).start_date ||', '||periods_tab(x).end_date);
       END LOOP;

       /*
       --  set global variables g_preceeding_end and g_suceeding_start
       --  must convert periods_tab.start_date and periods_tab.end_date to char
       --  then back to date.  Otherwise incrementing/decrementing by 1
       --  will increment/decrement by months rather than days
       */
             g_preceeding_end  := to_date(to_char(periods_tab(periods_tab.FIRST).start_date,'DD-MM-YYYY'),
                                      'DD-MM-YYYY') - 1 ;

             g_suceeding_start := to_date(to_char(periods_tab(periods_tab.LAST).end_date,'DD-MM-YYYY'),
                                      'DD-MM-YYYY') + 1 ;

             if g_preceeding_end < g_plan_period_start_date then
                g_preceeding_end:= NULL;
             end if;

             if g_suceeding_start > g_plan_period_end_date then
                g_suceeding_start := NULL;
             end if;

             if g_plan_period_end_date < periods_tab(periods_tab.FIRST).start_date then
                g_preceeding_end := g_plan_period_end_date;
             end if;

             if g_plan_period_start_date > periods_tab(periods_tab.LAST).end_date then
                g_suceeding_start := g_plan_period_start_date;
             end if;
    ELSE
      if g_plan_period_end_date < g_cpp_start_date then
         g_preceeding_end := g_plan_period_end_date;
      end if;

    END IF;
   ----- SHOW DATA in TABLES  REMOVE ABOVE before Testing ----


   ----- remove after testing -----

   --hr_utility.trace('g_preceeding_end '  ||g_preceeding_end );
   --hr_utility.trace('g_suceeding_start ' ||g_suceeding_start);
   --hr_utility.trace('Leaving PA_DISPLAY_PERIOD_MASKS');
   RETURN l_return;
  END   get_periods;



/*
--  get_min_start_period, get_max_end_period, get_min_start_date, get_max_end_date
--  are used by the start_period, end_period, start_date, and end_date functions
*/
  FUNCTION get_min_start_period  RETURN VARCHAR2
  IS
    l_min_start_period         gl_periods.period_name%TYPE;

  BEGIN
    l_min_start_period := periods_tab(periods_tab.FIRST).period_name;
    --hr_utility.trace('l_min_start_period :='||l_min_start_period);
    RETURN l_min_start_period;

  END get_min_start_period;



  FUNCTION get_max_end_period    RETURN VARCHAR2
  IS
    l_max_start_period         gl_periods.period_name%TYPE;

  BEGIN
    l_max_start_period := periods_tab(periods_tab.LAST).period_name;
    --hr_utility.trace('l_max_start_period :='||l_max_start_period);
    RETURN l_max_start_period;
  END get_max_end_period;




  FUNCTION get_min_start_date    RETURN DATE
  IS
    l_min_start_date  DATE;
  BEGIN
    l_min_start_date := periods_tab(periods_tab.FIRST).start_date;
    --hr_utility.trace('l_min_start_date := '||to_char(l_min_start_date));
    RETURN l_min_start_date;
  END get_min_start_date;




  FUNCTION get_max_end_date      RETURN DATE
  IS
    l_max_end_date    DATE;
  BEGIN
    l_max_end_date := periods_tab(periods_tab.last).end_date;
    --hr_utility.trace('l_max_end_date := '||to_char(l_max_end_date));
    RETURN l_max_end_date;
  END get_max_end_date;



/*
-- start_period is the function to be used by the select statement to
-- return the start period that corresponds to the masks from_anchor_position
--  if the from_anchor_position = -99999 or 99999 then set these to Preceeding and Suceeding periods
*/

  FUNCTION start_period ( p_from_anchor_position IN pa_period_mask_details.from_anchor_position%TYPE ) RETURN VARCHAR2
  IS

    -- Bug 3671424.
    -- THe gl periods period name is only 15 chars long where
    -- as our local variable may need to store a string preceeding
    -- periods or succeeding periods.
    -- so making it longer than 15 by changing it to lookups meaning %type.

    --l_start_period              gl_periods.period_name%TYPE;
    l_start_period              pa_lookups.meaning%TYPE;

    CURSOR get_period_mask_details_csr IS
	 SELECT from_anchor_start
	       ,from_anchor_end
       FROM pa_period_mask_details
	  WHERE from_anchor_position = p_from_anchor_position
	    AND period_mask_id       = g_period_mask_id;

   get_period_mask_details_rec get_period_mask_details_csr%ROWTYPE;


  BEGIN
    -- Bug Fix 3671424
    -- Changing the start and end period names
    -- from preceeding to preceeding periods
    -- the smae for the end period also.

    IF p_from_anchor_position = -99999
    -- Bug Fix 3671424.
    --THEN l_start_period := 'Preceeding';
    THEN l_start_period := g_preceeding;
    ELSIF p_from_anchor_position = 99999
    --THEN l_start_period := 'Suceeding';
    THEN l_start_period := g_succeeding;
    ELSE

      OPEN get_period_mask_details_csr;
      FETCH get_period_mask_details_csr INTO get_period_mask_details_rec;
           IF get_period_mask_details_csr%NOTFOUND THEN
              NULL;
              --hr_utility.trace('start_period.get_period_mask_details_csr does not contain anything! exception');
        ELSIF
              pa_display_period_masks.periods_tab.EXISTS(get_period_mask_details_rec.from_anchor_start)
         THEN l_start_period :=
		      pa_display_period_masks.periods_tab(get_period_mask_details_rec.from_anchor_start).period_name;

/*
--  if from_anchor_start does not exist check if from_anchor_end exists
--  set start period = periods_tab.first period name
*/
        ELSIF
              (pa_display_period_masks.periods_tab.EXISTS(get_period_mask_details_rec.from_anchor_end))
         THEN l_start_period := get_min_start_period;
/*
--  if from_anchor_start and from_anchor_end do not exist then
--  set start period = NULL
*/

        ELSE l_start_period := NULL;
       END IF;
    CLOSE get_period_mask_details_csr;

   END IF;
   --hr_utility.trace('l_start_period := '||l_start_period);
  RETURN l_start_period;

END start_period;

/*
-- end_period is the function to be used by the select statement to
-- return the end period that corresponds to the masks from_anchor_position
--  if the from_anchor_position = -99999 or 99999 then set these to Preceeding and Suceeding periods
*/

  FUNCTION end_period   ( p_from_anchor_position IN pa_period_mask_details.from_anchor_position%TYPE ) RETURN VARCHAR2
  IS

    -- Bug 3671424.
    -- THe gl periods period name is only 15 chars long where
    -- as our local variable may need to store a string preceeding
    -- periods or succeeding periods.
    -- so making it longer than 15 by changing it to lookups meaning %type.


    --l_end_period         gl_periods.period_name%TYPE;
    l_end_period        pa_lookups.meaning%TYPE;

    CURSOR get_period_mask_details_csr IS
	 SELECT from_anchor_start
	       ,from_anchor_end
	   FROM pa_period_mask_details
	  WHERE from_anchor_position = p_from_anchor_position
	    AND period_mask_id = g_period_mask_id;

    get_period_mask_details_rec get_period_mask_details_csr%ROWTYPE;


  BEGIN
    -- Bug Fix 3671424
    -- Changing the start and end period names
    -- from preceeding to preceeding periods
    -- the smae for the end period also.

    IF p_from_anchor_position = -99999
    -- Bug Fix 367142
    --THEN l_end_period := 'Preceeding';
    THEN l_end_period := g_preceeding;
    ELSIF p_from_anchor_position = 99999
    --THEN l_end_period := 'Suceeding';
    THEN l_end_period := g_succeeding;
    ELSE

      OPEN get_period_mask_details_csr;
      FETCH get_period_mask_details_csr INTO get_period_mask_details_rec;
        IF get_period_mask_details_csr%NOTFOUND
        THEN NULL;
             --hr_utility.trace('end_period.get_period_mask_details_csr does not contain anything! exception');
        ELSIF
        pa_display_period_masks.periods_tab.EXISTS(get_period_mask_details_rec.from_anchor_end)
        THEN l_end_period :=
             pa_display_period_masks.periods_tab(get_period_mask_details_rec.from_anchor_end).period_name;


/*
--  if from_anchor_end does not exist check if from_anchor_start exists
--  set end period = periods_tab.last period name
*/
        ELSIF
        (pa_display_period_masks.periods_tab.EXISTS(get_period_mask_details_rec.from_anchor_start))
        THEN
        l_end_period := get_max_end_period;

/*
--  if from_anchor_start and from_anchor_end do not exist then
--  set end period = NULL
*/
        ELSE l_end_period := NULL;
        END IF;
      CLOSE get_period_mask_details_csr;

    END IF;

    --hr_utility.trace('l_end_period := '||l_end_period);

  RETURN l_end_period;

END end_period;


/*
--  display_name() is used to display the name of start period and end period together
--  if start period = end period then display only start period
--  if start period or end period is null then display null
--  else display start period - end period
*/
  FUNCTION display_name ( p_from_anchor_position IN pa_period_mask_details.from_anchor_position%TYPE ) RETURN VARCHAR2
  IS
    l_display_name varchar2(2000);
  BEGIN
    IF p_from_anchor_position = -99999 THEN
       IF g_preceeding_end IS NULL THEN
             l_display_name := NULL;
       ELSE
            -- Bug Fix 3671424
            -- l_display_name := 'Preceeding';
            l_display_name := g_preceeding;
       END IF;
    ELSIF p_from_anchor_position = 99999 THEN
       IF g_suceeding_start IS NULL THEN
             l_display_name := NULL;
       ELSE
            -- Bug Fix 3671424
            -- l_display_name := 'Suceeding';
            l_display_name := g_succeeding;
       END IF;
    ELSIF
    pa_display_period_masks.start_period(p_from_anchor_position) = pa_display_period_masks.end_period(p_from_anchor_position)
    THEN
    l_display_name := pa_display_period_masks.start_period(p_from_anchor_position);
    ELSIF
    pa_display_period_masks.start_period(p_from_anchor_position) IS NULL OR
    pa_display_period_masks.end_period(p_from_anchor_position) IS NULL
    THEN l_display_name := NULL;
    ELSE
     -- Bug Fix 3671424
     -- l_display_name := pa_display_period_masks.start_period(p_from_anchor_position) || ' - '
     l_display_name := pa_display_period_masks.start_period(p_from_anchor_position) || ' '||g_to||' '
                       || pa_display_period_masks.end_period(p_from_anchor_position);
    END IF;

    --hr_utility.trace('l_display_name := '||l_display_name);
   RETURN l_display_name;

  END display_name;

/*
--  start_date is the function to be used by the select statement to
--  return the start date that corresponds to the masks from_anchor_position
--  if the from_anchor_position = -99999 set start date = 01-JAN-0001
--  if the from_anchor_position = 99999 set start date = g_suceeding start
*/

  FUNCTION start_date   ( p_from_anchor_position IN pa_period_mask_details.from_anchor_position%TYPE ) RETURN DATE
  IS
    l_start_date date;

    CURSOR get_period_mask_details_csr IS
	 SELECT from_anchor_start
	       ,from_anchor_end
       FROM pa_period_mask_details
	  WHERE from_anchor_position = p_from_anchor_position
	    AND period_mask_id = g_period_mask_id;

    get_period_mask_details_rec         get_period_mask_details_csr%ROWTYPE;

  BEGIN

    IF p_from_anchor_position = -99999
    THEN l_start_date:= to_date('01/01/0001','DD/MM/YYYY');
    ELSIF p_from_anchor_position = 99999
    THEN l_start_date:= pa_display_period_masks.g_suceeding_start;
    ELSE

     OPEN get_period_mask_details_csr;
     FETCH get_period_mask_details_csr INTO get_period_mask_details_rec;
       IF get_period_mask_details_csr%NOTFOUND THEN
       NULL;
       --hr_utility.trace('start_date.get_period_mask_details_csr does not contain anything! exception');
       ELSIF
       pa_display_period_masks.periods_tab.EXISTS(get_period_mask_details_rec.from_anchor_start)
       THEN l_start_date :=
            pa_display_period_masks.periods_tab(get_period_mask_details_rec.from_anchor_start).start_date;

/*
--  if from_anchor_start does not exist check if from_anchor_end exists
--  set start date = periods_tab.first start_date
*/
       ELSIF
       (pa_display_period_masks.periods_tab.EXISTS(get_period_mask_details_rec.from_anchor_end))
       THEN l_start_date := get_min_start_date;

/*
--  if from_anchor_start and from_anchor_end do not exist then
--  set start date = NULL
*/
       ELSE l_start_date :=  NULL;
       END IF;
     CLOSE get_period_mask_details_csr;

    END IF;

  --hr_utility.trace('l_start_date := '||to_char(l_start_date));
  RETURN l_start_date;

END start_date;

/*
--  end_date is the function to be used by the select statement to
--  return the start date that corresponds to the masks from_anchor_position
--  if the from_anchor_position = -99999 set start date = g_preceeding_end
--  if the from_anchor_position = 99999 set start date = '31-DEC-4712'
*/
  FUNCTION end_date     ( p_from_anchor_position IN pa_period_mask_details.from_anchor_position%TYPE ) RETURN DATE
  IS
    l_end_date DATE;

    CURSOR get_period_mask_details_csr IS
	 SELECT from_anchor_start
	       ,from_anchor_end
	   FROM pa_period_mask_details
	  WHERE from_anchor_position = p_from_anchor_position
	    AND period_mask_id = g_period_mask_id;

   get_period_mask_details_rec        get_period_mask_details_csr%ROWTYPE;

  BEGIN

    IF p_from_anchor_position = -99999
    THEN l_end_date:= pa_display_period_masks.g_preceeding_end;
    ELSIF p_from_anchor_position = 99999
    THEN l_end_date:= to_date('31/12/4712','DD/MM/YYYY'); --xin
    ELSE

      OPEN get_period_mask_details_csr;
      FETCH get_period_mask_details_csr INTO get_period_mask_details_rec;
        IF get_period_mask_details_csr%NOTFOUND
        THEN
        NULL;
        --hr_utility.trace('end_date.get_period_mask_details_csr does not contain anything! exception');
        ELSIF
        pa_display_period_masks.periods_tab.EXISTS(get_period_mask_details_rec.from_anchor_end)
        THEN l_end_date :=
             pa_display_period_masks.periods_tab(get_period_mask_details_rec.from_anchor_end).end_date;

/*
--  if from_anchor_end does not exist check if from_anchor_start exists
--  set end date= periods_tab.last end_date
*/
        ELSIF
        (pa_display_period_masks.periods_tab.EXISTS(get_period_mask_details_rec.from_anchor_start))
        THEN l_end_date :=  get_max_end_date;

/*
--  if from_anchor_start and from_anchor_end do not exist then
--  set end date = NULL
*/
        ELSE l_end_date :=  NULL;
        END IF;
      CLOSE get_period_mask_details_csr;
    END IF;

    --hr_utility.trace('l_end_date := '||to_char(l_end_date));
    RETURN l_end_date;

  END end_date;

    /* The update_current_pp is called from the Edit Plan Lines Page to update
      the current planning period in the pa_budget_versions table and pa_proj_fp_options
      table.
  */
-- Bug Fix 3975683
  -- Added record version numbers which will be used
  -- to see if the record is already is updates or not
  -- and update the version number as well.

  PROCEDURE update_current_pp (p_budget_version_id      IN  pa_budget_versions.budget_version_id%TYPE,
                               p_current_planning_period IN pa_budget_versions.current_planning_period%TYPE,
                               p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
                               p_bud_rec_ver_num         IN pa_budget_versions.record_version_number%TYPE,
                               p_fp_rec_ver_num          IN pa_proj_fp_options.record_version_number%TYPE,
                               X_Return_Status          OUT NOCOPY Varchar2,
                               X_Msg_Count              OUT NOCOPY Number,
           		               X_Msg_Data               OUT NOCOPY Varchar2) IS

  CURSOR get_version_type_csr(p_budget_version_id NUMBER) IS
  SELECT version_type
  FROM pa_budget_versions
  WHERE budget_version_id = p_budget_version_id;

  l_version_type PA_BUDGET_VERSIONS.version_type%TYPE;
  l_curr_plan_period PA_BUDGET_VERSIONS.current_planning_period%type;
  BEGIN
	-- Initialize values
	X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
	X_Msg_Count     	:= 0;
	X_Msg_Data		:= Null;
  -- Make sure that the parameter is not null.
  if p_current_planning_period is null then
  		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     	:= 1;
		X_Msg_Data		:= 'PA_NULL_CURR_PLAN_PERIOD';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_NULL_CURR_PLAN_PERIOD');
        RAISE FND_API.G_EXC_ERROR;
  end if;
-- Fix for Bug 4898791
  BEGIN
          l_curr_plan_period := null;
          SELECT DISTINCT(period_name) into l_curr_plan_period FROM gl_periods where period_name=p_current_planning_period;
exception
when no_data_found
then
                X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     	:= 1;
		X_Msg_Data		:= 'PA_INVALID_CURR_PLAN_PERIOD';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_INVALID_CURR_PLAN_PERIOD');
        RAISE FND_API.G_EXC_ERROR;

    END;  -- End of Fix for Bug 4898791

  OPEN get_version_type_csr(p_budget_version_id);
  FETCH get_version_type_csr INTO l_version_type;
  CLOSE get_version_type_csr;

  -- Bug Fix 3975683
  -- Started updating the record_version_number

  UPDATE pa_budget_versions
  SET    current_planning_period = p_current_planning_period,
         record_version_number = record_version_number + 1
  WHERE  budget_version_id = p_budget_version_id
    AND  record_version_number = p_bud_rec_ver_num;

    IF sql%rowcount = 0 THEN
  		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     	:= 1;
		X_Msg_Data		:= 'PA_RECORD_ALREADY_UPDATED';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_RECORD_ALREADY_UPDATED');
        RAISE FND_API.G_EXC_ERROR;
    END if;

     IF l_version_type = 'COST' THEN
             UPDATE pa_proj_fp_options
             SET    COST_CURRENT_PLANNING_PERIOD         =   p_current_planning_period,
                    record_version_number = record_version_number + 1
             WHERE  FIN_PLAN_VERSION_ID = p_budget_version_id
               AND  record_version_number = p_fp_rec_ver_num;
     ELSIF l_version_type = 'REVENUE' THEN
             UPDATE pa_proj_fp_options
             SET    REV_CURRENT_PLANNING_PERIOD         =   p_current_planning_period,
                    record_version_number = record_version_number + 1
             WHERE  FIN_PLAN_VERSION_ID = p_budget_version_id
               AND  record_version_number = p_fp_rec_ver_num;
     ELSIF l_version_type = 'ALL' THEN
             UPDATE pa_proj_fp_options
             SET    ALL_CURRENT_PLANNING_PERIOD         =   p_current_planning_period,
                    record_version_number = record_version_number + 1
             WHERE  FIN_PLAN_VERSION_ID = p_budget_version_id
               AND  record_version_number = p_fp_rec_ver_num;
     END IF;

    IF sql%rowcount = 0 THEN
  		X_Return_Status 	:= Fnd_Api.G_Ret_Sts_Error;
		X_Msg_Count     	:= 1;
		X_Msg_Data		:= 'PA_RECORD_ALREADY_UPDATED';
		Pa_Utils.Add_Message
               		(P_App_Short_Name  => 'PA',
                	 P_Msg_Name        => 'PA_RECORD_ALREADY_UPDATED');
        RAISE FND_API.G_EXC_ERROR;
    END if;

  X_Msg_Data         := Null;
  X_Return_Status    := Fnd_Api.G_Ret_Sts_Success;

IF FND_API.to_boolean( p_commit )
THEN
  COMMIT;
END IF;

  EXCEPTION
        WHEN FND_API.G_EXC_ERROR
        THEN
        X_return_status := FND_API.G_RET_STS_ERROR;

        When Others Then
		Raise;

  END update_current_pp;

END pa_display_period_masks;

/
