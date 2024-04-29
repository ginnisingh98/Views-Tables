--------------------------------------------------------
--  DDL for Package Body PSB_WS_PERIOD_TOTAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_PERIOD_TOTAL" as
/* $Header: PSBVWPTB.pls 120.8 2006/01/09 06:08:35 maniskum ship $ */


  PROCEDURE Get_Totals
  (
    p_worksheet_id               NUMBER,
    p_profile_worksheet_id       NUMBER,
    p_budget_year_id             NUMBER,
    p_balance_type               VARCHAR2,
    p_user_id                    NUMBER,
    p_template_id                NUMBER,
    p_account_flag               VARCHAR2,
    p_currency_flag              VARCHAR2,
    p_spkg_flag                  VARCHAR2,
    p_spkg_selection_exists      VARCHAR2,
/* Bug No 2543015 Start */
    p_spkg_name                  VARCHAR2,
/* Bug No 2543015 End */
    p_flexfield_low              VARCHAR2,
    p_flexfield_high             VARCHAR2,
    p_flexfield_delimiter        VARCHAR2,
    p_chart_of_accounts          NUMBER,
    p1_amount            OUT  NOCOPY     NUMBER,
    p2_amount            OUT  NOCOPY     NUMBER,
    p3_amount            OUT  NOCOPY     NUMBER,
    p4_amount            OUT  NOCOPY     NUMBER,
    p5_amount            OUT  NOCOPY     NUMBER,
    p6_amount            OUT  NOCOPY     NUMBER,
    p7_amount            OUT  NOCOPY     NUMBER,
    p8_amount            OUT  NOCOPY     NUMBER,
    p9_amount            OUT  NOCOPY     NUMBER,
    p10_amount           OUT  NOCOPY     NUMBER,
    p11_amount           OUT  NOCOPY     NUMBER,
    p12_amount           OUT  NOCOPY     NUMBER,
    p_year_amount        OUT  NOCOPY     NUMBER
  )
   IS


    l1_amount NUMBER;
    l2_amount NUMBER;
    l3_amount NUMBER;
    l4_amount NUMBER;
    l5_amount NUMBER;
    l6_amount NUMBER;
    l7_amount NUMBER;
    l8_amount NUMBER;
    l9_amount NUMBER;
    l10_amount NUMBER;
    l11_amount NUMBER;
    l12_amount NUMBER;
    l_year_amount NUMBER;


    l_sql      VARCHAR2(5000);
    l_ignore       INTEGER;
    l_cursor_id    INTEGER;

    l_max_num_of_segments  NUMBER;
    l_num_of_low_segments  NUMBER;
    l_num_of_high_segments NUMBER;

    query_condition        VARCHAR2(2000) default NULL;
    high_value             VARCHAR2(240);
    low_value              VARCHAR2(240);

    high_segments          fnd_flex_ext.SegmentArray;
    low_segments           fnd_flex_ext.SegmentArray;
    delim                  VARCHAR2(1);

    l_flex_condition       VARCHAR2(2000);
    l_segment_condition    VARCHAR2(2000);
    l_segment_num          NUMBER;
    l_segment_col          VARCHAR2(30);
    l_acct_type            NUMBER(2);

    /* Start bug #4924031 */
    l_id_flex_code    fnd_id_flex_structures.id_flex_code%TYPE;
    l_application_id  fnd_id_flex_structures.application_id%TYPE;
    /* End bug #4924031 */

    CURSOR flex_cur is
      SELECT APPLICATION_COLUMN_NAME
        FROM FND_ID_FLEX_SEGMENTS
       WHERE ID_FLEX_CODE = l_id_flex_code      -- bug #4924031
         AND application_id = l_application_id  -- bug #4924031
	       AND ID_FLEX_NUM = p_chart_of_accounts
	       AND SEGMENT_NUM = l_segment_num;

    flex_rec flex_cur%ROWTYPE;

  BEGIN

    /* Start bug #4924031 */
    l_id_flex_code    := 'GL#';
    l_application_id  := 101;
    /* End bug #4924031 */

    delim := fnd_flex_ext.get_delimiter(
			  application_short_name => 'SQLGL',
			  key_flex_code          => 'GL#',
			  structure_number       => p_chart_of_accounts
			  );

    -- breakup the segments into an array
    l_num_of_low_segments := 0;
    l_num_of_high_segments := 0;
    IF  p_flexfield_low IS NOT NULL then
      l_num_of_low_segments :=  fnd_flex_ext.breakup_segments
				(concatenated_segs => p_flexfield_low,
				 delimiter         => delim,
				 segments          => low_segments);
    END IF;

    IF  p_flexfield_high IS NOT NULL then
      l_num_of_high_segments :=  fnd_flex_ext.breakup_segments
				 (concatenated_segs => p_flexfield_high,
				  delimiter         => delim,
				  segments          => high_segments);
    END IF;

    l_max_num_of_segments := greatest(l_num_of_low_segments,l_num_of_high_segments);


    --
    -- build the query condition.
    --
    query_condition := 'AND 1 = 1 ';
    l_segment_num := 0;
    IF l_max_num_of_segments >= 1 THEN

      for i in 1.. l_max_num_of_segments
      loop

	l_segment_num := l_segment_num + 1;
	OPEN flex_cur;
	FETCH flex_cur INTO  flex_rec;
	IF flex_cur%FOUND THEN
	  l_segment_col := flex_rec.APPLICATION_COLUMN_NAME;
	END IF;
	CLOSE flex_cur;

	--dbms_output.put_line('Segment Number  : ' || l_segment_num);
	--dbms_output.put_line('Segment Name  : ' || l_segment_col);

	IF low_segments.exists(i) THEN
	  low_value := low_segments(i);
	END IF;

	IF high_segments.exists(i) THEN
	  high_value := high_segments(i);
	END IF;

	--dbms_output.put_line('Low Value  :' || low_value);
	--dbms_output.put_line('High Value :' || high_value);


	-- Build the query condition.
	--
	IF ((low_value IS NOT NULL) AND (high_value IS NULL)) THEN
	  query_condition := query_condition ||' AND ' || l_segment_col  || ' >= ' || '''' ||low_value|| '''';

	ELSIF ((low_value IS NULL) AND (high_value IS NOT NULL)) THEN
	  query_condition := query_condition ||' AND ' || l_segment_col  || '<= ' || '''' || high_value|| '''';

	ELSIF (low_value = high_value) THEN
	  query_condition := query_condition ||' AND ' ||l_segment_col || ' Like '|| '''' ||low_value|| '''';

	ELSIF ((low_value IS NOT NULL) AND (high_value IS NOT NULL)) THEN
	  query_condition := query_condition ||' AND ' ||l_segment_col || ' BETWEEN ' ||
			    ''''|| low_value || '''' || ' AND ' || ''''|| high_value|| '''';

	END IF;


      end loop;


    END IF;

    --dbms_output.put_line(query_condition);

/* Bug No 3140882 Start */

	IF p_account_flag = 'A' OR p_account_flag = 'E' OR p_account_flag = 'D' THEN
      		l_acct_type := -1;
    	ELSE
      		l_acct_type := 1;
	END IF;

    l_sql := 'SELECT  ' ||
	      '  NVL(SUM(decode(account_type,''A'',-period1_amount,''E'',-period1_amount,''D'',-period1_amount,period1_amount)),0) * :b_acct_type  A ' ||
	      ' ,NVL(SUM(decode(account_type,''A'',-period2_amount,''E'',-period2_amount,''D'',-period2_amount,period2_amount)),0) * :b_acct_type  B ' ||
	      ' ,NVL(SUM(decode(account_type,''A'',-period3_amount,''E'',-period3_amount,''D'',-period3_amount,period3_amount)),0) * :b_acct_type  C ' ||
	      ' ,NVL(SUM(decode(account_type,''A'',-period4_amount,''E'',-period4_amount,''D'',-period4_amount,period4_amount)),0) * :b_acct_type  D ' ||
	      ' ,NVL(SUM(decode(account_type,''A'',-period5_amount,''E'',-period5_amount,''D'',-period5_amount,period5_amount)),0) * :b_acct_type  E ' ||
	      ' ,NVL(SUM(decode(account_type,''A'',-period6_amount,''E'',-period6_amount,''D'',-period6_amount,period6_amount)),0) * :b_acct_type  F ' ||
	      ' ,NVL(SUM(decode(account_type,''A'',-period7_amount,''E'',-period7_amount,''D'',-period7_amount,period7_amount)),0) * :b_acct_type  G ' ||
	      ' ,NVL(SUM(decode(account_type,''A'',-period8_amount,''E'',-period8_amount,''D'',-period8_amount,period8_amount)),0) * :b_acct_type  H ' ||
	      ' ,NVL(SUM(decode(account_type,''A'',-period9_amount,''E'',-period9_amount,''D'',-period9_amount,period9_amount)),0) * :b_acct_type  I ' ||
	      ' ,NVL(SUM(decode(account_type,''A'',-period10_amount,''E'',-period10_amount,''D'',-period10_amount,period10_amount)),0) * :b_acct_type J ' ||
	      ' ,NVL(SUM(decode(account_type,''A'',-period11_amount,''E'',-period11_amount,''D'',-period11_amount,period11_amount)),0) * :b_acct_type K ' ||
	      ' ,NVL(SUM(decode(account_type,''A'',-period12_amount,''E'',-period12_amount,''D'',-period12_amount,period12_amount)),0) * :b_acct_type L ' ||
	      ' ,NVL(SUM(decode(account_type,''A'',-ytd_amount,''E'',-ytd_amount,''D'',-ytd_amount,ytd_amount)),0) * :b_acct_type M ' ||
	      ' FROM psb_ws_line_period_v  WLP ' ||
	      ' WHERE worksheet_id = :b_worksheet_id ' ||
	      ' AND budget_year_id = :b_budget_year_id ' ||
	      ' AND balance_type = :b_balance_type ' ||
	      ' AND (:b_account_flag = ''T'' OR account_type = :b_account_flag  '  ||
	      '       OR (account_type = DECODE(:b_account_flag,''P'',''R'',''~'') OR account_type = DECODE(:b_account_flag,''P'',''E'',''~'')) '||
	      '       OR (account_type = DECODE(:b_account_flag,''N'',''A'',''~'') OR account_type = DECODE(:b_account_flag,''N'',''L'',''~'')) '||
              '       OR (account_type = DECODE(:b_account_flag,''B'',''D'',''~'') OR account_type = DECODE(:b_account_flag,''B'',''C'',''~'')) '||
	      '     ) '||
/* Bug No 3140882 End */
	      ' AND (   (:b_currency_flag = ''C'' AND currency_code <> ''STAT'') '  ||
	      '       OR ' ||
	      '         (:b_currency_flag = ''S'' AND currency_code = ''STAT'') ' ||
	      '     ) '  ||
	      ' AND (   (:b_template_id is NULL  AND template_id is null) ' ||
	      '       OR ' ||
	      '         (:b_template_id is NOT NULL  AND template_id = :b_template_id) ' ||
	      '     ) ' ||
/* Bug No 2543015 Start */
	      ' AND ( :b_spkg_flag = ''A''   ' ||
	      '      OR (:b_spkg_selection_exists = ''N'' ' ||
	      '      AND service_package_id in ( select sp.service_package_id       ' ||
	      '                                  from  PSB_SERVICE_PACKAGES sp, PSB_WORKSHEETS w  ' ||
	      '                                 where sp.global_worksheet_id = nvl(w.global_worksheet_id, w.worksheet_id) ' ||
	      '                                 and w.worksheet_id = :b_profile_worksheet_id   ' ||
	      '                                 and sp.name like :b_spkg_name)  ' ||
	      '         ) ' ||
	      '      OR (:b_spkg_selection_exists = ''Y'' ' ||
	      '      AND service_package_id in ( select service_package_id       ' ||
	      '                                  from  PSB_WS_SERVICE_PKG_PROFILES_V  ' ||
	      '                                 where worksheet_id = :b_profile_worksheet_id   ' ||
	      '                                   and (user_id =  :b_user_id or (:b_user_id is null and user_id is null)) ' ||
	      '                                   and service_package_name like :b_spkg_name)  ' ||
	      '         ) ' ||
	      '     ) ' ;
/* Bug No 2543015 End */


     l_flex_condition := ' and (code_combination_id  ' ||
		     '    = (select code_combination_id from gl_code_combinations '||
		     '    where WLP.code_combination_id = code_combination_id  '||
		     '    and chart_of_accounts_id = :b_chart_of_accounts ' ||
		     query_condition || '))' ;

     l_sql := l_sql || l_flex_condition;

     l_cursor_id := dbms_sql.open_cursor;

     -- Parsing the statement.
     dbms_sql.parse(l_cursor_id, l_sql, dbms_sql.v7);

     -- Bind input variables
     dbms_sql.bind_variable(l_cursor_id, ':b_acct_type', l_acct_type);
     dbms_sql.bind_variable(l_cursor_id, ':b_worksheet_id', p_worksheet_id);
     dbms_sql.bind_variable(l_cursor_id, ':b_account_flag', p_account_flag);
     dbms_sql.bind_variable(l_cursor_id, ':b_currency_flag',p_currency_flag);
     dbms_sql.bind_variable(l_cursor_id, ':b_template_id', p_template_id);
     dbms_sql.bind_variable(l_cursor_id, ':b_spkg_flag', p_spkg_flag);
     dbms_sql.bind_variable(l_cursor_id, ':b_spkg_selection_exists', p_spkg_selection_exists);
/* Bug No 2543015 Start */
     dbms_sql.bind_variable(l_cursor_id, ':b_spkg_name', p_spkg_name);
/* Bug No 2543015 End */
     dbms_sql.bind_variable(l_cursor_id, ':b_user_id', p_user_id);
     dbms_sql.bind_variable(l_cursor_id, ':b_chart_of_accounts', p_chart_of_accounts);
     dbms_sql.bind_variable(l_cursor_id, ':b_budget_year_id', p_budget_year_id);
     dbms_sql.bind_variable(l_cursor_id, ':b_balance_type', p_balance_type);
     dbms_sql.bind_variable(l_cursor_id, ':b_profile_worksheet_id', p_profile_worksheet_id);

     -- define output variables

     dbms_sql.define_column(l_cursor_id, 1, l1_amount);
     dbms_sql.define_column(l_cursor_id, 2, l2_amount);
     dbms_sql.define_column(l_cursor_id, 3, l3_amount);
     dbms_sql.define_column(l_cursor_id, 4, l4_amount);
     dbms_sql.define_column(l_cursor_id, 5, l5_amount);
     dbms_sql.define_column(l_cursor_id, 6, l6_amount);
     dbms_sql.define_column(l_cursor_id, 7, l7_amount);
     dbms_sql.define_column(l_cursor_id, 8, l8_amount);
     dbms_sql.define_column(l_cursor_id, 9, l9_amount);
     dbms_sql.define_column(l_cursor_id, 10, l10_amount);
     dbms_sql.define_column(l_cursor_id, 11, l11_amount);
     dbms_sql.define_column(l_cursor_id, 12, l12_amount);
     dbms_sql.define_column(l_cursor_id, 13, l_year_amount);

     -- execute
     l_ignore := dbms_sql.execute(l_cursor_id);
     -- fetch
     l_ignore := dbms_sql.fetch_rows(l_cursor_id );

     -- retrieve the value
     dbms_sql.column_value(l_cursor_id,1,l1_amount);
     dbms_sql.column_value(l_cursor_id,2,l2_amount);
     dbms_sql.column_value(l_cursor_id,3,l3_amount);
     dbms_sql.column_value(l_cursor_id,4,l4_amount);
     dbms_sql.column_value(l_cursor_id,5,l5_amount);
     dbms_sql.column_value(l_cursor_id,6,l6_amount);
     dbms_sql.column_value(l_cursor_id,7,l7_amount);
     dbms_sql.column_value(l_cursor_id,8,l8_amount);
     dbms_sql.column_value(l_cursor_id,9,l9_amount);
     dbms_sql.column_value(l_cursor_id,10,l10_amount);
     dbms_sql.column_value(l_cursor_id,11,l11_amount);
     dbms_sql.column_value(l_cursor_id,12,l12_amount);
     dbms_sql.column_value(l_cursor_id,13,l_year_amount);

     p1_amount  := l1_amount;
     p2_amount  := l2_amount;
     p3_amount  := l3_amount;
     p4_amount  := l4_amount;
     p5_amount  := l5_amount;
     p6_amount  := l6_amount;
     p7_amount  := l7_amount;
     p8_amount  := l8_amount;
     p9_amount  := l9_amount;
     p10_amount := l10_amount;
     p11_amount := l11_amount;
     p12_amount := l12_amount;
     p_year_amount := l_year_amount;

     -- close the cursor
     dbms_sql.close_cursor(l_cursor_id);


  END Get_Totals;



  PROCEDURE Get_Data_Selection_Profile
  (
   p_current_worksheet_id   IN  NUMBER,
   p_current_user_id        IN  NUMBER,
   p_global_profile_user_id IN  NUMBER,
   p_profile_worksheet_id   OUT  NOCOPY NUMBER,
   p_profile_user_id        OUT  NOCOPY NUMBER
  )
   IS

   l_global_worksheet_flag varchar2(1):= NULL;
   l_global_worksheet_id psb_worksheets.global_worksheet_id%TYPE;
   l_local_copy_flag varchar2(1):= NULL;
   l_parent_worksheet_id psb_worksheets.copy_of_worksheet_id%TYPE;
   l_dummy varchar2(1) := '0';
   /* for bug no 3564160 */
   l_profile_flag    VARCHAR2(1) := '0';
   l_inherit_profile varchar2(3) := NULL;

   Cursor C (v_ws_id Number, v_user_id Number) IS
      SELECT '1'
	FROM psb_ws_user_profiles
       WHERE worksheet_id = v_ws_id
	 AND user_id = v_user_id;

   Cursor C_global(v_global_worksheet_id Number) IS
      SELECT '1'
	FROM psb_ws_user_profiles
       WHERE worksheet_id = v_global_worksheet_id
	 AND user_id IS NULL;

   Cursor C_CurrWS IS
      SELECT global_worksheet_flag,
	     global_worksheet_id,
	     local_copy_flag,
	     copy_of_worksheet_id
	FROM psb_worksheets
       WHERE worksheet_id = p_current_worksheet_id;

   BEGIN
	l_inherit_profile := FND_PROFILE.VALUE('PSB_INHERIT_DATA_SELECTION_PROFILE');

	FOR C_rec IN C(p_current_worksheet_id, p_current_user_id)
	loop
	   l_profile_flag := '1';
	end loop;

	IF l_profile_flag = '1' THEN
	   p_profile_worksheet_id := p_current_worksheet_id;
	   p_profile_user_id := p_current_user_id;
	ELSE
	   FOR  C_CurrWS_rec IN C_CurrWS
	   Loop
	       l_global_worksheet_flag  := C_CurrWS_rec.global_worksheet_flag;
	       l_global_worksheet_id    := C_CurrWS_rec.global_worksheet_id;
	       l_local_copy_flag        := C_CurrWS_rec.local_copy_flag;
	       l_parent_worksheet_id    := C_CurrWS_rec.copy_of_worksheet_id;
	   End Loop;

	   IF l_global_worksheet_flag = 'Y' THEN

	      Begin
		  FOR C_global_rec IN C_global(p_current_worksheet_id)
		  loop
		     l_profile_flag := '2';
		  end loop;
		  IF l_profile_flag = '2' THEN
		     p_profile_worksheet_id := p_current_worksheet_id;
		     p_profile_user_id := p_global_profile_user_id;
		     RETURN;
		  ELSE
		     p_profile_worksheet_id := p_current_worksheet_id;
		     p_profile_user_id := p_current_user_id;
		     RETURN;
		  END IF;
	       End;

	  /* For Bug No. 2544320 : Start
	     If profile option 'Inherit Global Profile' is NULL, it should be defaulted to 'No'. */
	   -- ELSIF nvl(l_inherit_profile, 'Y') = 'Y' THEN
	      ELSIF nvl(l_inherit_profile, 'N') = 'Y' THEN
	  /* For Bug No. 2544320 : End */

	       Begin
		  IF  l_local_copy_flag = 'Y' THEN
		     FOR C_rec IN C(l_parent_worksheet_id, p_current_user_id)
		     loop
			   l_profile_flag := '3';
		     end loop;

		     IF l_profile_flag = '3' THEN
			   p_profile_worksheet_id := l_parent_worksheet_id;
			   p_profile_user_id := p_current_user_id;
			   RETURN;
		     ELSE
			   /* start bug 3564160 */
		       -- check for global data
		     	FOR C_Global_Rec IN C_Global (l_global_worksheet_id)
		     	LOOP
		     	  l_profile_flag := '4';
		     	END LOOP;

		     	IF l_profile_flag = '4' THEN
		     	  p_profile_worksheet_id := l_global_worksheet_id;
			 	  p_profile_user_id := p_global_profile_user_id;
			 	  RETURN;
		     	ELSE
			 	  p_profile_worksheet_id := p_current_worksheet_id;
			 	  p_profile_user_id := p_current_user_id;
			 	  RETURN;
			 	END IF;
			   /* end bug 3564160 */
		     END IF;
		  ELSE
		     FOR C_global_rec IN C_global(l_global_worksheet_id)
		     loop
			l_profile_flag := '4';
		     end loop;
		     IF l_profile_flag = '4' THEN
			p_profile_worksheet_id := l_global_worksheet_id;
			p_profile_user_id := p_global_profile_user_id;
			RETURN;
		     ELSE
			p_profile_worksheet_id := p_current_worksheet_id;
			p_profile_user_id := p_current_user_id;
			RETURN;
		     END IF;
		  END IF;
	       End;

	   ELSE
         /* start bug 3564160 */
	   	 IF  l_local_copy_flag = 'Y' THEN
	   	   -- check it with parent
	   	   FOR C_rec IN C(l_parent_worksheet_id, p_current_user_id)
		   LOOP
		     l_profile_flag := '5';
		   END LOOP;

		   IF l_profile_flag = '5' THEN
		     p_profile_worksheet_id := l_parent_worksheet_id;
			 p_profile_user_id := p_current_user_id;
			 RETURN;
		   END IF;
		 END IF;
		 /* end bug 3564160 */

	     p_profile_worksheet_id := p_current_worksheet_id;
	     p_profile_user_id := p_current_user_id;
	   END IF;

      END IF;

   End Get_Data_Selection_Profile;



END PSB_WS_PERIOD_TOTAL;

/
