--------------------------------------------------------
--  DDL for Package Body GL_BIS_ALERTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BIS_ALERTS_PKG" as
/* $Header: glubisab.pls 120.7 2005/05/05 01:36:17 kvora ship $ */

  ---
  --- PRIVATE VARIABLES
  ---

      c_gl_revenue_pm   VARCHAR2(30) := 'FIIGLREVENUE';
      c_gl_company      VARCHAR2(30) := 'GL COMPANY';
      c_t_gl_companys   VARCHAR2(30) := 'TOTAL GL COMPANIES';
      c_gl_sm           VARCHAR2(30) := 'GL SECONDARY MEASURE';
      c_t_gl_sms        VARCHAR2(30) := 'TOTAL GL SECONDARY MEASURES';

      g_period_name     VARCHAR2(15);   -- period name
      g_period_set_name VARCHAR2(15);   -- accounting calendar name
      g_period_num      NUMBER(15);     -- accounting period number
      g_period_year     NUMBER(15);     -- accounting period year
      g_period_pos      NUMBER(15);     -- relative period position

      trg_select        VARCHAR2(2000); -- Buffer for dynamic sql stmt

      g_return_status   VARCHAR2(1);
      g_msg_count       NUMBER;
      g_msg_data        VARCHAR2(250);
      g_error_tbl       BIS_UTILITIES_PUB.error_tbl_type;
      g_msg_buf         VARCHAR2(240);

      g_old_org_id      VARCHAR2(80);   -- temp. storage of org id

      -- Cursor to retrieve all target levels
      CURSOR c_target_level IS
      SELECT tl.target_level_id                       target_level_id,
             tl.dimension1_level_id                   dim1_level_id,
             tl.dimension2_level_id                   dim2_level_id,
             decode(dl1.dimension_level_short_name,
                    c_t_gl_companys, -1,
                    c_gl_company,     0)              dim1_level_code,
             decode(dl2.dimension_level_short_name,
                    c_t_gl_sms,      -1,
                    c_gl_sm,          0)              dim2_level_code,
             workflow_item_type                       wf_item_type,
             workflow_process_short_name              wf_process
      FROM   bis_indicators             ind,
             bisbv_target_levels        tl,
             bisbv_dimension_levels     dl1,
             bisbv_dimension_levels     dl2
      WHERE  ind.short_name                   = c_gl_revenue_pm
      AND    tl.measure_id                    = ind.indicator_id
      AND    dl1.dimension_level_id           = tl.dimension1_level_id
      AND    dl2.dimension_level_id           = tl.dimension2_level_id
      AND NOT (dl1.dimension_level_short_name = c_t_gl_companys
          AND dl2.dimension_level_short_name  = c_gl_sm)
      ORDER BY tl.target_level_id;

  ---
  --- PRIVATE FUNCTIONS
  ---

  --
  -- Procedure
  --   get_period_info
  -- Purpose
  --   Get period info
  -- History
  --   28-MAY-1999      K Vora        Created
  -- Arguments
  --   pp_period_id     Period set name + Period name
  -- Example
  --   gl_bis_alerts.get_period_info('Accounting+JAN-99');

  PROCEDURE get_period_info(
    pp_period_id        VARCHAR2) IS
  BEGIN

    -- Get period name and period set name
    SELECT substr(pp_period_id,
                 instr(pp_period_id, '+') + 1,
                 length(pp_period_id)),
           substr(pp_period_id,
                 1, instr(pp_period_id, '+') -1)
    INTO   g_period_name,
           g_period_set_name
    FROM   DUAL;

    -- Get period number and period year
    SELECT p.period_num,
           p.period_year
    INTO   g_period_num,
           g_period_year
    FROM   gl_periods p
    WHERE  period_set_name = g_period_set_name
    AND    period_name     = g_period_name;

  END get_period_info;


  --
  -- Procedure
  --   build_sql_statement
  -- Purpose
  --   Build dynamic SQL statement for target cursor. Retrieve segment number
  --   number information only if target is defined for a specific GL Company
  --   or GL Secondary Measure.
  -- History
  --   28-MAY-1999      K Vora        Created
  -- Arguments
  --   p_dim1_level_code     -1 - TOTAL GL COMPANYS
  --                          0 - GL COMPANY
  --   p_dim2_level_code     -1 - TOTAL GL SECONDARY MEASURES
  --                          0 - GL SECONDARY MEASURE
  -- Example
  --   gl_bis_alerts.build_sql_statement(
  --     p_dim1_level_code => 0,
  --     p_dim2_level_code => 0);

  PROCEDURE build_sql_statement(
     p_dim1_level_code        NUMBER,
     p_dim2_level_code        NUMBER) IS
  BEGIN

    trg_select := 'SELECT '                        ||
                  '  trg.target_id '               ||
                  ', bplan.plan_id '               ||
                  ', bplan.name '                  ||
                  ', trg.org_level_value_id '      ||
                  ', sob.name '                    ||
                  ', sob.chart_of_accounts_id '    ||
                  ', trg.time_level_value_id '     ||
                  ', trg.dim1_level_value_id '     ||
                  ', trg.dim2_level_value_id '     ||
                  ', trg.range1_low * -1'          ||
                  ', trg.range1_high '             ||
                  ', trg.range2_low * -1'          ||
                  ', trg.range2_high '             ||
                  ', trg.range3_low * -1'          ||
                  ', trg.range3_high '             ||
                  ', trg.notify_resp1_id '         ||
                  ', trg.notify_resp1_short_name ' ||
                  ', trg.notify_resp2_id '         ||
                  ', trg.notify_resp2_short_name ' ||
                  ', trg.notify_resp3_id '         ||
                  ', trg.notify_resp3_short_name ';


    IF (p_dim1_level_code = 0) THEN
       trg_select := trg_select || ', sg1.segment_num ';
    ELSE
       trg_select := trg_select || ', -1 ';
    END IF;

    IF (p_dim2_level_code = 0) THEN
       trg_select := trg_select || ', sg2.segment_num ';
    ELSE
       trg_select := trg_select || ', -1  ';
    END IF;

    trg_select := trg_select ||
                  'FROM '                          ||
                  '  bisbv_targets        trg '    ||
                  ', bisbv_business_plans bplan '  ||
                  ', bisbv_target_levels  tl '     ||
                  ', gl_sets_of_books     sob ';

    IF (p_dim1_level_code = 0) THEN
       trg_select := trg_select ||
                     ', bis_flex_mappings_v  fm1 ' ||
                     ', fnd_id_flex_segments sg1 ';
    END IF;

    IF (p_dim2_level_code = 0) THEN
       trg_select := trg_select ||
                     ', bis_flex_mappings_v  fm2 ' ||
                     ', fnd_id_flex_segments sg2 ';
    END IF;

    trg_select := trg_select ||
        'WHERE  tl.target_level_id           = :target_level_id '   ||
        'AND    trg.target_level_id          = tl.target_level_id ' ||
        'AND    trg.time_level_value_id      = :period_id '         ||
        'AND    bplan.plan_id                = trg.plan_id '        ||
        'AND    sob.set_of_books_id          = to_number(trg.org_level_value_id) ';

    IF (p_dim1_level_code = 0) THEN
       trg_select := trg_select ||
        'AND    fm1.level_id                 = :dim1_level_id '           ||
        'AND    fm1.application_id           = 101 '                      ||
        'AND    fm1.id_flex_code             = ''GL#'' '                  ||
        'AND    fm1.structure_num            = sob.chart_of_accounts_id ' ||
        'AND    sg1.application_id           = 101 '                      ||
        'AND    sg1.id_flex_code             = ''GL#'' '                  ||
        'AND    sg1.id_flex_num              = fm1.structure_num '        ||
        'AND    sg1.application_column_name  = fm1.application_column_name ';
    END IF;

    IF (p_dim2_level_code = 0) THEN
       trg_select := trg_select ||
        'AND    fm2.level_id                 = :dim2_level_id '           ||
        'AND    fm2.application_id           = 101 '                      ||
        'AND    fm2.id_flex_code             = ''GL#'' '                  ||
        'AND    fm2.structure_num            = sob.chart_of_accounts_id ' ||
        'AND    sg2.application_id           = 101 '                      ||
        'AND    sg2.id_flex_code             = ''GL#'' '                  ||
        'AND    sg2.id_flex_num              = fm2.structure_num '        ||
        'AND    sg2.application_column_name  = fm2.application_column_name ' ||
        'ORDER BY trg.org_level_value_id';
    END IF;

  END build_sql_statement;


  --
  -- Function
  --   calculate_amount
  -- Purpose
  --   Retrieve actual revenue and planned revenue for the dimension values.
  -- History
  --   28-MAY-1999      K Vora        Created
  -- Arguments
  --   p_organization_id     Set of books id
  --   p_dim1_id             Dimension1 value
  --   p_dim1_segnum         Mapped segment number
  --   p_dim2_id             Dimension2 value
  --   p_dim2_segnum         Mapped segment number
  --   p_amount_type         A - Retrieve actual revenue
  --                         B - Retrieve planned revenue
  -- Returns
  --   revenue or planned revenue
  -- Example
  --   l_actual := gl_bis_alerts.calculate_amount(
  --      p_organization_id => '1491',
  --      p_dim1_id         => '01',
  --      p_dim1_segnum     => 1,
  --      p_dim2_id         => '110',
  --      p_dim2_segnum     => 2,
  --      p_amount_type     => 'A');
  -- Notes
  --   p_dim1_segnum and p_dim2_segnum hold the segment number of the segment
  --   that particular dimension is mapped to, else the value is -1.
  --   If the balancing segment is the first segment, then p_dim1_segnum holds
  --   value 1. If the cost center segment is the fourth segment, and the
  --   second dimension is mapped to the cost center segment, p_dim2_segnum
  --   holds value 4. If the second dimension is not mapped, p_dim2_segnum
  --   holds value -1.

  FUNCTION calculate_amount(
     p_organization_id      VARCHAR2,
     p_dim1_id              VARCHAR2,
     p_dim1_segnum          NUMBER,
     p_dim2_id              VARCHAR2,
     p_dim2_segnum          NUMBER,
     p_amount_type          VARCHAR2
     ) RETURN NUMBER IS

     l_num_per_year         NUMBER;    -- Number of periods in a fiscal year
     ret_amount             NUMBER;

  BEGIN

    -- Calculate relative period position
    IF p_organization_id <> g_old_org_id THEN

       SELECT pt.number_per_fiscal_year
       INTO   l_num_per_year
       FROM   gl_sets_of_books sob,
              gl_period_types  pt
       WHERE  sob.set_of_books_id = to_number(p_organization_id)
       AND    pt.period_type = sob.accounted_period_type;

       g_period_pos := g_period_year * l_num_per_year + g_period_num;
       g_old_org_id := p_organization_id;

    END IF;

-- Bug 1746807 - string literals in the 2 DECODE() statements are now
-- enclosed by single quotes to prevent "ORA-01722: invalid number" errors.

    -- Calculate amount
    --bug 3329868 - For revenue , the sign should be reversed when it
    -- it is send to the PMF region.

    BEGIN
      SELECT -1*period_to_date
      INTO   ret_amount
      FROM   gl_oasis_summary_data
      WHERE  set_of_books_id   = to_number(p_organization_id)
      AND    fin_item_id       = 'REVENUE'
      AND    drilldown_segnum1 = p_dim1_segnum
      AND    drilldown_segnum2 = p_dim2_segnum
      AND    actual_flag       = p_amount_type
      AND    drilldown_segval1 = decode(p_dim1_segnum, -1, '-1', p_dim1_id)
      AND    drilldown_segval2 = decode(p_dim2_segnum, -1, '-1', p_dim2_id)
      AND    relative_period_pos = g_period_pos;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      NULL;
    END;

    RETURN(ret_amount);
  END calculate_amount;


  --
  -- Procedure
  --   post_actual
  -- Purpose
  --   Post revenue amounts to set performance measures on personal homepage
  -- History
  --   28-MAY-1999      K Vora        Created
  -- Arguments
  --   p_target_level_id     Target level id
  --   p_organization_id     Set of books id
  --   p_time_id             Period name + Period set name
  --   p_dim1_id             Dimension1 value
  --   p_dim2_id             Dimension2 value
  --   p_actual              Actual amount
  -- Example
  --   gl_bis_alerts.post_actual(
  --      p_target_level_id => 1533,
  --      p_organization_id => '1491',
  --      p_time_id         => 'Accounting+July-99',
  --      p_dim1_id         => '01',
  --      p_dim2_id         => '110'
  --      p_actual          => 101345)

  PROCEDURE post_actual(
     p_target_level_id      NUMBER,
     p_organization_id      VARCHAR2,
     p_time_id              VARCHAR2,
     p_dim1_id              VARCHAR2,
     p_dim2_id              VARCHAR2,
     p_actual               NUMBER
     ) IS

    -- Record containing actual info
    v_actual_rec           BIS_ACTUAL_PUB.Actual_Rec_Type;

  BEGIN

    -- Initialize actuals record
    v_actual_rec.target_level_id     := p_target_level_id;
    v_actual_rec.org_level_value_id  := p_organization_id;
    v_actual_rec.time_level_value_id := p_time_id;
    v_actual_rec.dim1_level_value_id := p_dim1_id;
    v_actual_rec.dim2_level_value_id := p_dim2_id;

-- S.Bhattal, 31-JAN-2000, bug 1407747, reversed the sign of the actual.
-- So credit Revenue (negative amount) will be posted as a positive amount.
-- Debit Revenue (positive amount) will be posted as a negative amount.
-- This is required for display of Actuals on the BIS PHP.

-- No need to reverse the sign of the actual as it is done in
-- the procedure calculate_amount bug#3329868

    v_actual_rec.actual       :=  p_actual;

    BIS_ACTUAL_PUB.post_actual(
      p_api_version           => 1.0,
      p_commit                => FND_API.G_TRUE,
      p_actual_rec            => v_actual_rec,
      x_return_status         => g_return_status,
      x_msg_count             => g_msg_count,
      x_msg_data              => g_msg_data,
      x_error_tbl             => g_error_tbl);

  END post_actual;


  --
  -- Procedure
  --   send_notification
  -- Purpose
  --   Start workflow notification process
  -- History
  --   28-MAY-1999      K Vora        Created
  -- Arguments
  --   p_type                ABOVE or BELOW tolerance range
  --   p_wf_item_type        Workflow item type
  --   p_wf_process          Workflow process
  --   p_resp_id             Responsibility to be notified
  --   p_resp                Responsibility to be notified
  --   p_sob_name            Name of the set of books
  --   p_dim2_id             Dimension1 value
  --   p_dim2_id             Dimension2 value
  --   p_actual              Actual revenue
  --   p_target              Planned revenue
  --   p_variance_percent    Variance percent
  -- Example
  --   gl_bis_alerts.send_notification(
  --      p_type            => 'ABOVE',
  --      p_wf_item_type    => 'FIIBISWF',
  --      p_wf_process      => 'FII_REVENUE_NOTIFICATION',
  --      p_resp            => 'CFO Responsibility',
  --      p_resp_id         => 1002841,
  --      p_sob_name        => 'Vision Operations',
  --      p_dim1_id         => '01',
  --      p_dim2_id         => '110',
  --      p_actual          => 12000,
  --      p_target          => 11650,
  --      p_variance_percent=> 3);

  PROCEDURE send_notification(
     p_type                 VARCHAR2,
     p_wf_item_type         VARCHAR2,
     p_wf_process           VARCHAR2,
     p_resp_id              NUMBER,
     p_resp                 VARCHAR2,
     p_sob_name             VARCHAR2,
     p_dim1_id              VARCHAR2,
     p_dim2_id              VARCHAR2,
     p_actual               NUMBER,
     p_target               NUMBER,
     p_variance_percent     NUMBER,
     p_range_low            NUMBER,
     p_range_high           NUMBER) IS

    l_report_name           VARCHAR2(10);
    l_subject               VARCHAR2(500);
    l_message               VARCHAR2(1000);
    l_param                 VARCHAR2(250);
    l_variance_percent      NUMBER;
    l_dim1_value            VARCHAR2(80);
    l_dim2_value            VARCHAR2(80);
    l_dim1_name             VARCHAR2(80);
    l_dim2_name             VARCHAR2(80);

    send_notification_error EXCEPTION;

  BEGIN

    l_report_name := 'FIIGLFIR';

    IF p_variance_percent = 9999 THEN
       l_variance_percent := NULL;
    ELSE
       l_variance_percent := round(p_variance_percent, 3);
    END IF;

--for bug 2166758: change -1 to '-1' to avoid
--                 ORA-06502: PL/SQL: numeric or value error:
--                 character to number conversion error
    IF p_dim1_id = '-1' THEN
       SELECT dl.dimension_level_name, dl.dimension_level_name
       INTO   l_dim1_value, l_dim1_name
       FROM   bisbv_dimension_levels dl
       WHERE  dl.dimension_level_short_name = c_t_gl_companys;
    ELSE
       l_dim1_value := p_dim1_id;
       SELECT dl.dimension_level_name
       INTO   l_dim1_name
       FROM   bisbv_dimension_levels dl
       WHERE  dl.dimension_level_short_name = c_gl_company;
    END IF;

--for bug 2166758: change -1 to '-1' to avoid
--                 ORA-06502: PL/SQL: numeric or value error:
--                 character to number conversion error
    IF p_dim2_id = '-1' THEN
       SELECT dl.dimension_level_name, dl.dimension_level_name
       INTO   l_dim2_value, l_dim2_name
       FROM   bisbv_dimension_levels dl
       WHERE  dl.dimension_level_short_name = c_t_gl_sms;
    ELSE
       l_dim2_value := p_dim2_id;
       SELECT dl.dimension_level_name
       INTO   l_dim2_name
       FROM   bisbv_dimension_levels dl
       WHERE  dl.dimension_level_short_name = c_gl_sm;
    END IF;

    IF p_type = 'ABOVE' THEN
       FND_MESSAGE.set_name('SQLGL', 'GL_BIS_REVPMF_ABOVE_SUBJECT');
       FND_MESSAGE.set_token('PERIOD_NAME',       g_period_name);
       FND_MESSAGE.set_token('DIM1_NAME',         l_dim1_name);
       FND_MESSAGE.set_token('DIM2_NAME',         l_dim2_name);
       FND_MESSAGE.set_token('ACTUAL',            abs(p_actual));
       FND_MESSAGE.set_token('TARGET',            abs(p_target));
       l_subject := FND_MESSAGE.get;
       FND_MESSAGE.set_name('SQLGL', 'GL_BIS_REVPMF_ABOVE_MESSAGE');

    ELSE
       FND_MESSAGE.set_name('SQLGL', 'GL_BIS_REVPMF_BELOW_SUBJECT');
       FND_MESSAGE.set_token('PERIOD_NAME',       g_period_name);
       FND_MESSAGE.set_token('DIM1_NAME',         l_dim1_name);
       FND_MESSAGE.set_token('DIM2_NAME',         l_dim2_name);
       FND_MESSAGE.set_token('ACTUAL',            abs(p_actual));
       FND_MESSAGE.set_token('TARGET',            abs(p_target));
       l_subject := FND_MESSAGE.get;
       FND_MESSAGE.set_name('SQLGL', 'GL_BIS_REVPMF_BELOW_MESSAGE');
    END IF;

    FND_MESSAGE.set_token('SET_OF_BOOKS_NAME', p_sob_name);
    FND_MESSAGE.set_token('PERIOD_NAME',       g_period_name);
    FND_MESSAGE.set_token('DIM1_VALUE',        l_dim1_value);
    FND_MESSAGE.set_token('DIM2_VALUE',        l_dim2_value);
    FND_MESSAGE.set_token('ACTUAL',            abs(p_actual));
    FND_MESSAGE.set_token('TARGET',            abs(p_target));
    FND_MESSAGE.set_token('VARIANCE',          (p_target - p_actual));
    FND_MESSAGE.set_token('VPERCENT',          l_variance_percent);
    FND_MESSAGE.set_token('VRANGE_LOW',        p_range_low);
    FND_MESSAGE.set_token('VRANGE_HIGH',       p_range_high);
    l_message := FND_MESSAGE.get;

    l_param := 'P_REPORT_ID=REVENUE*P_TARGET_PERIOD=' || g_period_name ||
               '*P_DRILLDOWN_LEVEL=';
    IF p_dim1_id = '-1' THEN
       l_param := l_param || '0';
    ELSE
       IF p_dim2_id = '-1' THEN
          l_param := l_param || '1';
       ELSE
          l_param := l_param || '2';
       END IF;
    END IF;

    l_param := l_param || '*P_DRILLDOWN_SEGVAL1=' || p_dim1_id
                 || '*P_DRILLDOWN_SEGVAL2=' || p_dim2_id || '*';

      BIS_UTIL.strt_wf_process(
      p_exception_message	=> l_message,
      p_msg_subject		=> l_subject,
      p_exception_date	        => sysdate,
      p_item_type               => p_wf_item_type,
      p_wf_process		=> p_wf_process,
      p_notify_resp_name        => p_resp,
      p_report_name1		=> l_report_name,
      p_report_param1	        => l_param,
      p_report_resp1_id     	=> p_resp_id,
      x_return_status       	=> g_return_status);
    IF g_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE send_notification_error;
    END IF;

  EXCEPTION
    WHEN send_notification_error THEN
      g_msg_buf := FND_MESSAGE.get_string('SQLGL','GL_BIS_REVPMF_MESSAGE_ERROR');
     -- dbms_output.put_line(g_msg_buf);
    WHEN OTHERS THEN
     -- dbms_output.put_line(g_msg_buf);
       null;

  END send_notification;


  ---
  --- PUBLIC FUNCTIONS
  ---

  --
  -- Procedure
  --   check_revenue
  -- Purpose
  --   Compares actual revenue versus planned revenue amounts
  --   and sends notifications.
  -- History
  --   28-MAY-1999  K Vora       Created
  -- Arguments
  --   p_period_id		Period set name + Period name
  -- Example
  --   gl_bis_alerts_pkg.check_revenue( 'Accounting+JAN-99');
  --

  PROCEDURE check_revenue(p_period_id   IN VARCHAR2) IS

    -- Define weak REF CURSOR type for dynamic SQL
    TYPE Target_Rec_Type IS REF CURSOR;
    c_target_rec           Target_Rec_Type;
    trg_rec                Target_Info_Rec_Type;

    l_actual               NUMBER;             -- revenue amount
    l_target               NUMBER;             -- planned revenue amount
    l_variance_percent     NUMBER;             -- percentage of difference
                                               -- between actual and target
    l_type                 VARCHAR2(5);        -- ABOVE - actual > target
                                               -- BELOW - actual < target

  BEGIN

    g_msg_buf := FND_MESSAGE.get_string('SQLGL', 'GL_BIS_REVPMF_START');
   -- dbms_output.put_line(g_msg_buf);

    g_old_org_id := '-1';
    get_period_info(
      pp_period_id  => p_period_id);

    -- Process each target level
    FOR tl_rec IN c_target_level LOOP

      -- Build target cursor statement
      build_sql_statement(
        p_dim1_level_code => tl_rec.dim1_level_code,
        p_dim2_level_code => tl_rec.dim2_level_code);

      -- Loop thru target records
      IF ((tl_rec.dim1_level_code = -1) AND
          (tl_rec.dim2_level_code = -1)) THEN
         OPEN c_target_rec FOR trg_select USING
              tl_rec.target_level_id, p_period_id;

      ELSIF ((tl_rec.dim1_level_code = 0) AND
             (tl_rec.dim2_level_code = -1)) THEN
         OPEN c_target_rec FOR trg_select USING
              tl_rec.target_level_id, p_period_id, tl_rec.dim1_level_id;

      ELSIF ((tl_rec.dim1_level_code = 0) AND
             (tl_rec.dim2_level_code = 0)) THEN
         OPEN c_target_rec FOR trg_select USING
              tl_rec.target_level_id, p_period_id,
              tl_rec.dim1_level_id, tl_rec.dim2_level_id;
      END IF;

      LOOP
        FETCH c_target_rec INTO trg_rec;
        EXIT WHEN c_target_rec%NOTFOUND;

        -- Calculate actual revenue amount
        l_actual := calculate_amount(
          p_organization_id  => trg_rec.org_level_value_id,
          p_dim1_id          => trg_rec.dim1_level_value_id,
          p_dim1_segnum      => trg_rec.dim1_segnum,
          p_dim2_id          => trg_rec.dim2_level_value_id,
          p_dim2_segnum      => trg_rec.dim2_segnum,
          p_amount_type      => 'A');

        -- Calculate planned revenue amount
        l_target := calculate_amount(
          p_organization_id  => trg_rec.org_level_value_id,
          p_dim1_id          => trg_rec.dim1_level_value_id,
          p_dim1_segnum      => trg_rec.dim1_segnum,
          p_dim2_id          => trg_rec.dim2_level_value_id,
          p_dim2_segnum      => trg_rec.dim2_segnum,
          p_amount_type      => 'B');

        -- Calculate difference
        IF (l_actual IS NOT NULL) AND (l_target IS NOT NULL) THEN
           IF (l_target <> 0) THEN
             l_variance_percent := (((l_actual - l_target) / l_target) * 100);
           ELSE
              l_variance_percent := 9999;
           END IF;
           IF l_variance_percent < 0 THEN
              l_type := 'BELOW';
           ELSE
              l_type := 'ABOVE';
           END IF;
        ELSE
           g_msg_buf := FND_MESSAGE.get_string('SQLGL',
                                               'GL_BIS_REVPMF_NO_REVENUE');
           --dbms_output.put_line(g_msg_buf);
        END IF;

        -- Determine in which range the variance percentage falls in
        IF (l_actual <> l_target) THEN

           -- Process range 3
           IF (((trg_rec.range3_low IS NOT NULL) AND
                (l_variance_percent < trg_rec.range3_low)) OR
               ((trg_rec.range3_high IS NOT NULL) AND
                (l_variance_percent > trg_rec.range3_high))) THEN

              IF trg_rec.notify_resp3_short_name IS NOT NULL THEN
                send_notification(
                  p_type                => l_type,
                  p_wf_item_type        => tl_rec.wf_item_type,
                  p_wf_process          => tl_rec.wf_process,
                  p_resp_id             => trg_rec.notify_resp3_id,
                  p_resp                => trg_rec.notify_resp3_short_name,
                  p_sob_name            => trg_rec.sob_name,
                  p_dim1_id             => trg_rec.dim1_level_value_id,
                  p_dim2_id             => trg_rec.dim2_level_value_id,
                  p_actual              => l_actual,
                  p_target              => l_target,
                  p_variance_percent    => l_variance_percent,
                  p_range_low           => trg_rec.range3_low,
                  p_range_high          => trg_rec.range3_high);
              END IF;

           -- Process range 2
           ELSIF (((trg_rec.range2_low IS NOT NULL) AND
                   (l_variance_percent < trg_rec.range2_low)) OR
                  ((trg_rec.range2_high IS NOT NULL) AND
                   (l_variance_percent > trg_rec.range2_high))) THEN

              IF trg_rec.notify_resp2_short_name IS NOT NULL THEN
                send_notification(
                  p_type                => l_type,
                  p_wf_item_type        => tl_rec.wf_item_type,
                  p_wf_process          => tl_rec.wf_process,
                  p_resp_id             => trg_rec.notify_resp2_id,
                  p_resp                => trg_rec.notify_resp2_short_name,
                  p_sob_name            => trg_rec.sob_name,
                  p_dim1_id             => trg_rec.dim1_level_value_id,
                  p_dim2_id             => trg_rec.dim2_level_value_id,
                  p_actual              => l_actual,
                  p_target              => l_target,
                  p_variance_percent    => l_variance_percent,
                  p_range_low           => trg_rec.range2_low,
                  p_range_high          => trg_rec.range2_high);
              END IF;

           -- Process range 1
           ELSIF (((trg_rec.range1_low IS NOT NULL) AND
                   (l_variance_percent < trg_rec.range1_low)) OR
                  ((trg_rec.range1_high IS NOT NULL) AND
                   (l_variance_percent > trg_rec.range1_high))) THEN

              IF trg_rec.notify_resp1_short_name IS NOT NULL THEN
                send_notification(
                  p_type                => l_type,
                  p_wf_item_type        => tl_rec.wf_item_type,
                  p_wf_process          => tl_rec.wf_process,
                  p_resp_id             => trg_rec.notify_resp1_id,
                  p_resp                => trg_rec.notify_resp1_short_name,
                  p_sob_name            => trg_rec.sob_name,
                  p_dim1_id             => trg_rec.dim1_level_value_id,
                  p_dim2_id             => trg_rec.dim2_level_value_id,
                  p_actual              => l_actual,
                  p_target              => l_target,
                  p_variance_percent    => l_variance_percent,
                  p_range_low           => trg_rec.range1_low,
                  p_range_high          => trg_rec.range1_high);
              END IF;
           END IF;     -- process all ranges
        END IF;     -- l_actual <> l_target

      END LOOP;         -- loop through target records

      CLOSE c_target_rec;

    END LOOP;            -- Loop through target levels
    g_msg_buf := FND_MESSAGE.get_string('SQLGL', 'GL_BIS_REVPMF_SUCCESS');
    -- dbms_output.put_line(g_msg_buf);

  EXCEPTION WHEN OTHERS THEN
    /* dbms_output.put_line('Error!!! -> ' ||  substrb(SQLERRM, 1, 230));
     dbms_output.put_line(substrb(SQLERRM, 231, 230));
     dbms_output.put_line('======= TRG_SELECT =======');
     dbms_output.put_line(substrb(trg_select, 1,   245));
     dbms_output.put_line(substrb(trg_select, 246, 245));
     dbms_output.put_line(substrb(trg_select, 491, 245));
     dbms_output.put_line('=========================='); */

     g_msg_buf := FND_MESSAGE.get_string('SQLGL', 'GL_BIS_REVPMF_EXCEPTION');
    -- dbms_output.put_line(g_msg_buf);

  END check_revenue;


  --
  -- Function
  --   set_performance_measures
  -- Purpose
  --   Set values for performance measures monitored on personal home page
  -- History
  --   01-JUL-1999  K Vora       Created
  -- Arguments
  --   p_sob_id                 Set of books id
  --   p_mapped_segnum1         Segment number of segment mapped to GL COMPANY
  --   p_mapped_segnum2         Segment number of segment mapped to GL SECONDARY MEASURE
  -- Returns
  --   TRUE  - Performance Measure value was updated correctly
  --   FALSE - Performance Measure value was not set
  -- Example
  --   ret_value := gl_bis_alerts_pkg.check_revenue( 1491, 1, 2);
  --

  FUNCTION set_performance_measures(p_sob_id           IN NUMBER,
                                    p_mapped_segnum1   IN NUMBER,
                                    p_mapped_segnum2   IN NUMBER)
           RETURN BOOLEAN IS

    -- Record containing target level info
    l_target_level_rec     BIS_TARGET_LEVEL_PUB.Target_Level_Rec_Type;

    -- Table containing monitored indicators
    l_user_selection_tbl   BIS_INDICATOR_REGION_PUB.Indicator_Region_Tbl_Type;

    l_period_id            VARCHAR2(80);      -- Period set name + Period name
    l_dim1_segnum          NUMBER;            -- mapped segment number
    l_dim2_segnum          NUMBER;            -- mapped segment number
    l_actual               NUMBER;            -- revenue amount
    i                      BINARY_INTEGER;

    SET_PM_ERROR EXCEPTION;

  BEGIN

    g_old_org_id := '-1';

    -- Get current period information
    SELECT per.period_set_name || '+' || per.period_name
    INTO   l_period_id
    FROM   gl_sets_of_books sob,
           gl_periods       per
    WHERE  sob.set_of_books_id = p_sob_id
    AND    per.period_set_name = sob.period_set_name
    AND    per.period_type     = sob.accounted_period_type
    AND    trunc(sysdate) between per.start_date and per.end_date
    AND    nvl(per.adjustment_period_flag,'N')='N'; --bug3457467

    get_period_info(
      pp_period_id  => l_period_id);

    -- Process each target level
    FOR tl_rec IN c_target_level LOOP

      -- Get indicators user wants to monitor
      l_target_level_rec.target_level_id := tl_rec.target_level_id;

      BIS_ACTUAL_PUB.retrieve_user_selections
        (p_api_version             =>  1.0,
         p_target_level_rec        =>  l_target_level_rec,
         x_indicator_region_tbl    =>  l_user_selection_tbl,
         x_return_status           =>  g_return_status,
         x_msg_count               =>  g_msg_count,
         x_msg_data                =>  g_msg_data,
         x_error_tbl               =>  g_error_tbl);
      IF g_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE SET_PM_ERROR;
      END IF;

      -- Loop through all the monitored indicators
      i := l_user_selection_tbl.FIRST;
      WHILE i IS NOT NULL LOOP

        -- Process only those performance measures for sob id parameter
        IF l_user_selection_tbl(i).org_level_value_id = to_char(p_sob_id) THEN

           -- If dimension level is GL COMPANY
           IF (tl_rec.dim1_level_code = 0) THEN
              l_dim1_segnum := p_mapped_segnum1;
           ELSE
              l_dim1_segnum := -1;
           END IF;

           -- If dimension level is GL SECONDARY MEASURE
           IF (tl_rec.dim2_level_code = 0) THEN
              l_dim2_segnum := p_mapped_segnum2;
           ELSE
              l_dim2_segnum := -1;
          END IF;

           -- Calculate actual revenue amount
           l_actual := calculate_amount(
           p_organization_id  => l_user_selection_tbl(i).org_level_value_id,
           p_dim1_id          => l_user_selection_tbl(i).dim1_level_value_id,
           p_dim1_segnum      => l_dim1_segnum,
           p_dim2_id          => l_user_selection_tbl(i).dim2_level_value_id,
           p_dim2_segnum      => l_dim2_segnum,
           p_amount_type      => 'A');

           -- Post actual values
           post_actual(
           p_target_level_id => tl_rec.target_level_id,
           p_organization_id => to_char(p_sob_id),
           p_time_id         => l_period_id,
           p_dim1_id         => l_user_selection_tbl(i).dim1_level_value_id,
           p_dim2_id         => l_user_selection_tbl(i).dim2_level_value_id,
           p_actual          => nvl(l_actual, 0));
           IF g_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE SET_PM_ERROR;
           END IF;
        END IF;

        i := l_user_selection_tbl.NEXT(i);

      END LOOP;        -- l_user_selection_tbl loop

    END LOOP;      -- Loop through target levels
    RETURN TRUE;
  EXCEPTION WHEN SET_PM_ERROR THEN
       RETURN FALSE;
  END set_performance_measures;

  --
  -- Function
  --   get_ctarget
  -- Purpose
  --   Dummy function. Always returns -1.
  -- History
  --   28-MAY-1999  K Vora       Created
  -- Arguments
  --   p_target_rec              Target information
  -- Example
  --   gl_bis_alerts_pkg.get_ctarget(p_target_rec =>_target_rec);
  --
  FUNCTION get_ctarget(
                p_target_rec  IN BIS_TARGET_PUB.Target_Rec_Type)
                RETURN NUMBER IS

    l_period_id            VARCHAR2(80);      -- Period set name + Period name
    l_segment1_num         NUMBER;            -- mapped segment number
    l_segment2_num         NUMBER;            -- mapped segment number
    l_target               NUMBER;            -- planned revenue amount

    CURSOR c_segment1_num IS
    SELECT sg.segment_num
    FROM   bisbv_target_levels    tl,
           bisbv_dimension_levels dl,
           gl_sets_of_books       sob,
           bis_flex_mappings_v    fm,
           fnd_id_flex_segments   sg
    WHERE  tl.target_level_id              = p_target_rec.target_level_id
    AND    dl.dimension_level_id           = tl.dimension1_level_id
    AND    dl.dimension_level_short_name  <> c_t_gl_companys
    AND    fm.level_id                     = tl.dimension1_level_id
    AND    fm.application_id               = 101
    AND    fm.id_flex_code                 = 'GL#'
    AND    fm.structure_num                = sob.chart_of_accounts_id
    AND    sg.application_id               = 101
    AND    sg.id_flex_code                 = 'GL#'
    AND    sg.id_flex_num                  = fm.structure_num
    AND    sg.application_column_name      = fm.application_column_name
    AND    sob.set_of_books_id   = to_number(p_target_rec.org_level_value_id);

    CURSOR c_segment2_num IS
    SELECT sg.segment_num
    FROM   bisbv_target_levels    tl,
           bisbv_dimension_levels dl,
           gl_sets_of_books       sob,
           bis_flex_mappings_v    fm,
           fnd_id_flex_segments   sg
    WHERE  tl.target_level_id              = p_target_rec.target_level_id
    AND    dl.dimension_level_id           = tl.dimension1_level_id
    AND    dl.dimension_level_short_name  <> c_t_gl_sms
    AND    fm.level_id                     = tl.dimension2_level_id
    AND    fm.application_id               = 101
    AND    fm.id_flex_code                 = 'GL#'
    AND    fm.structure_num                = sob.chart_of_accounts_id
    AND    sg.application_id               = 101
    AND    sg.id_flex_code                 = 'GL#'
    AND    sg.id_flex_num                  = fm.structure_num
    AND    sg.application_column_name      = fm.application_column_name
    AND    sob.set_of_books_id   = to_number(p_target_rec.org_level_value_id);

  BEGIN
    g_old_org_id := '-1';

    -- Get current period information
    SELECT per.period_set_name || '+' || per.period_name
    INTO   l_period_id
    FROM   gl_sets_of_books sob,
           gl_periods       per
    WHERE  sob.set_of_books_id = to_number(p_target_rec.org_level_value_id)
    AND    per.period_set_name = sob.period_set_name
    AND    per.period_type     = sob.accounted_period_type
    AND    trunc(sysdate) between per.start_date and per.end_date
    AND    nvl(per.adjustment_period_flag,'N')='N'; --bug3457467

    get_period_info(
      pp_period_id  => l_period_id);

    OPEN c_segment1_num;
    FETCH c_segment1_num INTO l_segment1_num;
    IF (c_segment1_num%NOTFOUND) THEN
       l_segment1_num := -1;
    END IF;
    CLOSE c_segment1_num;

    OPEN c_segment2_num;
    FETCH c_segment2_num INTO l_segment2_num;
    IF (c_segment2_num%NOTFOUND) THEN
       l_segment2_num := -1;
    END IF;
    CLOSE c_segment2_num;

    -- Calculate planned revenue amount
    l_target := calculate_amount(
      p_organization_id  => p_target_rec.org_level_value_id,
      p_dim1_id          => p_target_rec.dim1_level_value_id,
      p_dim1_segnum      => l_segment1_num,
      p_dim2_id          => p_target_rec.dim2_level_value_id,
      p_dim2_segnum      => l_segment2_num,
      p_amount_type      => 'B');
    RETURN(l_target);

  EXCEPTION WHEN OTHERS THEN
    RETURN(-1);
  END get_ctarget;

END GL_BIS_ALERTS_PKG;

/
