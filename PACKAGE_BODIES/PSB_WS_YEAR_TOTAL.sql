--------------------------------------------------------
--  DDL for Package Body PSB_WS_YEAR_TOTAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_YEAR_TOTAL" as
/* $Header: PSBVWYTB.pls 115.32 2004/01/22 08:01:33 sajgeo ship $ */
------------------------------------------------------------------------------------------
-- Worksheet Line Year
------------------------------------------------------------------------------------------

  g_segment_values    FND_FLEX_EXT.SegmentArray;
  g_segment_low       FND_FLEX_EXT.SegmentArray;
  g_segment_high      FND_FLEX_EXT.SegmentArray;
  g_segment_count     NUMBER;
  g_flex_delimiter    VARCHAR2(1);


  PROCEDURE assign_seg_values
  IS

    l_segment_index     NUMBER;
    l_segment_value     VARCHAR2(200);
    l_return_value      VARCHAR2(200);

  BEGIN
    for l_temp in 1..30 loop

      for l_index in 1..PSB_WS_ACCT1.g_num_segs loop

	if PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT'||l_temp then
	  l_segment_index := l_index;
	  exit;
	end if;

      end loop;

      if l_segment_index is null then
	g_segment_low(l_temp) := null;
	g_segment_high(l_temp) := null;
      else
      begin

	l_segment_value := g_segment_values(l_segment_index);

	if (l_segment_value = '' or l_segment_value is null) then
	  g_segment_low(l_temp) := null;
	  g_segment_high(l_temp) := null;
	elsif instr(l_segment_value, '#BETWEEN') <> 0 then
	  l_return_value := substr(l_segment_value, 0, (instr(l_segment_value, 'AND')-2));
	  g_segment_low(l_temp) := substr(l_return_value, instr(l_return_value, '#BETWEEN') + 9);
	  g_segment_high(l_temp) := substr(l_segment_value, instr(l_segment_value, 'AND') + 4);
	elsif instr(l_segment_value, '<=') <> 0 then
	  g_segment_low(l_temp) := null;
	  g_segment_high(l_temp) := substr(l_segment_value, instr(l_segment_value, '<=') + 3);
	elsif instr(l_segment_value, '>=') <> 0 then
	  g_segment_low(l_temp) := substr(l_segment_value, instr(l_segment_value, '>=') + 3);
	  g_segment_high(l_temp) := null;
	elsif instr(l_segment_value, '%') <> 0 then
	  g_segment_low(l_temp) := 'LK';
	  g_segment_high(l_temp) := l_segment_value;
	else
	  g_segment_low(l_temp) := l_segment_value;
	  g_segment_high(l_temp) := l_segment_value;
	end if;

      end;
      end if;

    end loop;

  END assign_seg_values;

  PROCEDURE Get_Totals
  (
    p_worksheet_id               NUMBER,
  --following 1 parameter added for DDSP
    p_profile_worksheet_id       NUMBER,
    p_user_id                    NUMBER,
    p_template_id                NUMBER,
    p_account_flag               VARCHAR2,
    p_currency_flag              VARCHAR2,
    p_spkg_flag                  VARCHAR2,
    p_spkg_selection_exists      VARCHAR2,
    p_spkg_name                  VARCHAR2,
    p_flexfield_low              VARCHAR2,
    p_flexfield_high             VARCHAR2,
    p_flexfield_delimiter        VARCHAR2,
    p_chart_of_accounts          NUMBER,
    p_flex_value                 VARCHAR2,
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
    p12_amount           OUT  NOCOPY     NUMBER
  ) IS
  --

/* Bug 3331024 Removed Rule hint */
    cursor c_sum_all is
      select NVL(SUM(column1),0)  A, NVL(SUM(column2),0)  B, NVL(SUM(column3),0)  C, NVL(SUM(column4),0)  D,
	     NVL(SUM(column5),0)  E, NVL(SUM(column6),0)  F, NVL(SUM(column7),0)  G, NVL(SUM(column8),0)  H,
	     NVL(SUM(column9),0)  I, NVL(SUM(column10),0) J, NVL(SUM(column11),0) K, NVL(SUM(column12),0) L,
	     DECODE(UPPER(account_type),'L','I','O','I','R','I','C','I','A','E','E') account_type
	FROM PSB_WS_YEAR_AMOUNTS_V  WYA
       WHERE worksheet_id = p_worksheet_id
       -- Changed reference to 'T' from 'C' for All accounts for bug 3191611
	 AND (p_account_flag = 'T' OR account_type = p_account_flag
	 OR account_type = DECODE(p_account_flag,'P','R','~')
	 OR account_type = DECODE(p_account_flag,'P','E','~')
	 OR account_type = DECODE(p_account_flag,'N','A','~')
	 OR account_type = DECODE(p_account_flag,'N','L','~')
	 OR account_type = DECODE(p_account_flag,'B','C','~')
	 OR account_type = DECODE(p_account_flag,'B','D','~'))
	 AND ((p_currency_flag = 'C' AND currency_code <> 'STAT')
	 OR (p_currency_flag = 'S' AND currency_code = 'STAT'))
	 AND ((p_template_id is NULL AND template_id is null) OR (p_template_id is NOT NULL AND template_id = p_template_id))
/* Bug No 2543015 Start */
	 AND (p_spkg_flag = 'A'
		OR (p_spkg_selection_exists = 'N'
			AND service_package_id IN
				(SELECT sp.service_package_id
				   FROM PSB_SERVICE_PACKAGES sp, PSB_WORKSHEETS w
				  WHERE sp.global_worksheet_id = nvl(w.global_worksheet_id, w.worksheet_id)
				    AND w.worksheet_id = p_worksheet_id
				    AND sp.name like p_spkg_name))
		OR (p_spkg_selection_exists = 'Y'
			AND service_package_id IN
				(SELECT service_package_id
				   FROM PSB_WS_SERVICE_PKG_PROFILES_V
				  WHERE worksheet_id = p_profile_worksheet_id
				    AND ((user_id =  p_user_id) or (p_user_id is null and user_id is null))
				    AND service_package_name like decode(p_spkg_name, '%', service_package_name, p_spkg_name))))
/* Bug No 2543015 End */
      GROUP by DECODE(UPPER(account_type),'L','I','O','I','R','I','C','I','A','E','E');

/* Bug 3331024 Removed Rule hint */
    cursor c_sum_partial is
      select  NVL(SUM(column1),0)  A, NVL(SUM(column2),0)  B, NVL(SUM(column3),0)  C, NVL(SUM(column4),0)  D,
	     NVL(SUM(column5),0)  E, NVL(SUM(column6),0)  F, NVL(SUM(column7),0)  G, NVL(SUM(column8),0)  H,
	     NVL(SUM(column9),0)  I, NVL(SUM(column10),0) J, NVL(SUM(column11),0) K, NVL(SUM(column12),0) L,
	     DECODE(UPPER(account_type),'L','I','O','I','R','I','C','I','A','E','E') account_type
	FROM PSB_WS_YEAR_AMOUNTS_V  WYA
       WHERE worksheet_id = p_worksheet_id
       -- Changed reference to 'T' from 'C' for All accounts for bug 3191611
	 AND (p_account_flag = 'T' OR account_type = p_account_flag
	        OR account_type = DECODE(p_account_flag,'P','R','~')
		OR account_type = DECODE(p_account_flag,'P','E','~')
		OR account_type = DECODE(p_account_flag,'N','A','~')
		OR account_type = DECODE(p_account_flag,'N','L','~')
		OR account_type = DECODE(p_account_flag,'B','C','~')
		OR account_type = DECODE(p_account_flag,'B','D','~'))
	        AND ((p_currency_flag = 'C' AND currency_code <> 'STAT')
		OR (p_currency_flag = 'S' AND currency_code = 'STAT'))
	        AND ((p_template_id is NULL AND template_id is null)
		OR (p_template_id is NOT NULL AND template_id = p_template_id))
/* Bug No 2543015 Start */
	 AND (p_spkg_flag = 'A'
		OR (p_spkg_selection_exists = 'N'
			AND service_package_id IN
				(SELECT sp.service_package_id
				   FROM PSB_SERVICE_PACKAGES sp, PSB_WORKSHEETS w
				  WHERE sp.global_worksheet_id = nvl(w.global_worksheet_id, w.worksheet_id)
				    AND w.worksheet_id = p_worksheet_id
				    AND sp.name like p_spkg_name))
		OR (p_spkg_selection_exists = 'Y'
			AND service_package_id IN
				(SELECT service_package_id
				   FROM PSB_WS_SERVICE_PKG_PROFILES_V
				  WHERE worksheet_id = p_profile_worksheet_id
				    AND ((user_id =  p_user_id) or (p_user_id is null and user_id is null))
				    AND service_package_name like decode(p_spkg_name, '%', service_package_name, p_spkg_name))))
/* Bug No 2543015 End */
	 AND EXISTS
	    (select 1 from gl_code_combinations
	      where code_combination_id = WYA.code_combination_id
		and chart_of_accounts_id = p_chart_of_accounts
		and ( (segment1 is null) or (g_segment_low(1) is null and g_segment_high(1) is null) or (g_segment_low(1) is null and segment1 <= g_segment_high(1)) or (g_segment_high(1) is null and segment1 >= g_segment_low(1)) or
			(g_segment_low(1) = 'LK' and segment1 like g_segment_high(1)) or (g_segment_low(1) is not null and g_segment_high(1) is not null and g_segment_low(1) <> 'LK' and segment1 between g_segment_low(1) and g_segment_high(1)) )
		and ( (segment2 is null) or (g_segment_low(2) is null and g_segment_high(2) is null) or (g_segment_low(2) is null and segment2 <= g_segment_high(2)) or (g_segment_high(2) is null and segment2 >= g_segment_low(2)) or
			(g_segment_low(2) = 'LK' and segment2 like g_segment_high(2)) or (g_segment_low(2) is not null and g_segment_high(2) is not null and g_segment_low(2) <> 'LK' and segment2 between g_segment_low(2) and g_segment_high(2)) )
		and ( (segment3 is null) or (g_segment_low(3) is null and g_segment_high(3) is null) or (g_segment_low(3) is null and segment3 <= g_segment_high(3)) or (g_segment_high(3) is null and segment3 >= g_segment_low(3)) or
			(g_segment_low(3) = 'LK' and segment3 like g_segment_high(3)) or (g_segment_low(3) is not null and g_segment_high(3) is not null and g_segment_low(3) <> 'LK' and segment3 between g_segment_low(3) and g_segment_high(3)) )
		and ( (segment4 is null) or (g_segment_low(4) is null and g_segment_high(4) is null) or (g_segment_low(4) is null and segment4 <= g_segment_high(4)) or (g_segment_high(4) is null and segment4 >= g_segment_low(4)) or
			(g_segment_low(4) = 'LK' and segment4 like g_segment_high(4)) or (g_segment_low(4) is not null and g_segment_high(4) is not null and g_segment_low(4) <> 'LK' and segment4 between g_segment_low(4) and g_segment_high(4)) )
		and ( (segment5 is null) or (g_segment_low(5) is null and g_segment_high(5) is null) or (g_segment_low(5) is null and segment5 <= g_segment_high(5)) or (g_segment_high(5) is null and segment5 >= g_segment_low(5)) or
			(g_segment_low(5) = 'LK' and segment5 like g_segment_high(5)) or (g_segment_low(5) is not null and g_segment_high(5) is not null and g_segment_low(5) <> 'LK' and segment5 between g_segment_low(5) and g_segment_high(5)) )
		and ( (segment6 is null) or (g_segment_low(6) is null and g_segment_high(6) is null) or (g_segment_low(6) is null and segment6 <= g_segment_high(6)) or (g_segment_high(6) is null and segment6 >= g_segment_low(6)) or
			(g_segment_low(6) = 'LK' and segment6 like g_segment_high(6)) or (g_segment_low(6) is not null and g_segment_high(6) is not null and g_segment_low(6) <> 'LK' and segment6 between g_segment_low(6) and g_segment_high(6)) )
		and ( (segment7 is null) or (g_segment_low(7) is null and g_segment_high(7) is null) or (g_segment_low(7) is null and segment7 <= g_segment_high(7)) or (g_segment_high(7) is null and segment7 >= g_segment_low(7)) or
			(g_segment_low(7) = 'LK' and segment7 like g_segment_high(7)) or (g_segment_low(7) is not null and g_segment_high(7) is not null and g_segment_low(7) <> 'LK' and segment7 between g_segment_low(7) and g_segment_high(7)) )
		and ( (segment8 is null) or (g_segment_low(8) is null and g_segment_high(8) is null) or (g_segment_low(8) is null and segment8 <= g_segment_high(8)) or (g_segment_high(8) is null and segment8 >= g_segment_low(8)) or
			(g_segment_low(8) = 'LK' and segment8 like g_segment_high(8)) or (g_segment_low(8) is not null and g_segment_high(8) is not null and g_segment_low(8) <> 'LK' and segment8 between g_segment_low(8) and g_segment_high(8)) )
		and ( (segment9 is null) or (g_segment_low(9) is null and g_segment_high(9) is null) or (g_segment_low(9) is null and segment9 <= g_segment_high(9)) or (g_segment_high(9) is null and segment9 >= g_segment_low(9)) or
			(g_segment_low(9) = 'LK' and segment9 like g_segment_high(9)) or (g_segment_low(9) is not null and g_segment_high(9) is not null and g_segment_low(9) <> 'LK' and segment9 between g_segment_low(9) and g_segment_high(9)) )
		and ( (segment10 is null) or (g_segment_low(10) is null and g_segment_high(10) is null) or (g_segment_low(10) is null and segment10 <= g_segment_high(10)) or (g_segment_high(10) is null and segment10 >= g_segment_low(10)) or
			(g_segment_low(10) = 'LK' and segment10 like g_segment_high(10)) or (g_segment_low(10) is not null and g_segment_high(10) is not null and g_segment_low(10) <> 'LK' and segment10 between g_segment_low(10) and g_segment_high(10)) )
		and ( (segment11 is null) or (g_segment_low(11) is null and g_segment_high(11) is null) or (g_segment_low(11) is null and segment11 <= g_segment_high(11)) or (g_segment_high(11) is null and segment11 >= g_segment_low(11)) or
			(g_segment_low(11) = 'LK' and segment11 like g_segment_high(11)) or (g_segment_low(11) is not null and g_segment_high(11) is not null and g_segment_low(11) <> 'LK' and segment11 between g_segment_low(11) and g_segment_high(11)) )
		and ( (segment12 is null) or (g_segment_low(12) is null and g_segment_high(12) is null) or (g_segment_low(12) is null and segment12 <= g_segment_high(12)) or (g_segment_high(12) is null and segment12 >= g_segment_low(12)) or
			(g_segment_low(12) = 'LK' and segment12 like g_segment_high(12)) or (g_segment_low(12) is not null and g_segment_high(12) is not null and g_segment_low(12) <> 'LK' and segment12 between g_segment_low(12) and g_segment_high(12)) )
		and ( (segment13 is null) or (g_segment_low(13) is null and g_segment_high(13) is null) or (g_segment_low(13) is null and segment13 <= g_segment_high(13)) or (g_segment_high(13) is null and segment13 >= g_segment_low(13)) or
			(g_segment_low(13) = 'LK' and segment13 like g_segment_high(13)) or (g_segment_low(13) is not null and g_segment_high(13) is not null and g_segment_low(13) <> 'LK' and segment13 between g_segment_low(13) and g_segment_high(13)) )
		and ( (segment14 is null) or (g_segment_low(14) is null and g_segment_high(14) is null) or (g_segment_low(14) is null and segment14 <= g_segment_high(14)) or (g_segment_high(14) is null and segment14 >= g_segment_low(14)) or
			(g_segment_low(14) = 'LK' and segment14 like g_segment_high(14)) or (g_segment_low(14) is not null and g_segment_high(14) is not null and g_segment_low(14) <> 'LK' and segment14 between g_segment_low(14) and g_segment_high(14)) )
		and ( (segment15 is null) or (g_segment_low(15) is null and g_segment_high(15) is null) or (g_segment_low(15) is null and segment15 <= g_segment_high(15)) or (g_segment_high(15) is null and segment15 >= g_segment_low(15)) or
			(g_segment_low(15) = 'LK' and segment15 like g_segment_high(15)) or (g_segment_low(15) is not null and g_segment_high(15) is not null and g_segment_low(15) <> 'LK' and segment15 between g_segment_low(15) and g_segment_high(15)) )
		and ( (segment16 is null) or (g_segment_low(16) is null and g_segment_high(16) is null) or (g_segment_low(16) is null and segment16 <= g_segment_high(16)) or (g_segment_high(16) is null and segment16 >= g_segment_low(16)) or
			(g_segment_low(16) = 'LK' and segment16 like g_segment_high(16)) or (g_segment_low(16) is not null and g_segment_high(16) is not null and g_segment_low(16) <> 'LK' and segment16 between g_segment_low(16) and g_segment_high(16)) )
		and ( (segment17 is null) or (g_segment_low(17) is null and g_segment_high(17) is null) or (g_segment_low(17) is null and segment17 <= g_segment_high(17)) or (g_segment_high(17) is null and segment17 >= g_segment_low(17)) or
			(g_segment_low(17) = 'LK' and segment17 like g_segment_high(17)) or (g_segment_low(17) is not null and g_segment_high(17) is not null and g_segment_low(17) <> 'LK' and segment17 between g_segment_low(17) and g_segment_high(17)) )
		and ( (segment18 is null) or (g_segment_low(18) is null and g_segment_high(18) is null) or (g_segment_low(18) is null and segment18 <= g_segment_high(18)) or (g_segment_high(18) is null and segment18 >= g_segment_low(18)) or
			(g_segment_low(18) = 'LK' and segment18 like g_segment_high(18)) or (g_segment_low(18) is not null and g_segment_high(18) is not null and g_segment_low(18) <> 'LK' and segment18 between g_segment_low(18) and g_segment_high(18)) )
		and ( (segment19 is null) or (g_segment_low(19) is null and g_segment_high(19) is null) or (g_segment_low(19) is null and segment19 <= g_segment_high(19)) or (g_segment_high(19) is null and segment19 >= g_segment_low(19)) or
			(g_segment_low(19) = 'LK' and segment19 like g_segment_high(19)) or (g_segment_low(19) is not null and g_segment_high(19) is not null and g_segment_low(19) <> 'LK' and segment19 between g_segment_low(19) and g_segment_high(19)) )
		and ( (segment20 is null) or (g_segment_low(20) is null and g_segment_high(20) is null) or (g_segment_low(20) is null and segment20 <= g_segment_high(20)) or (g_segment_high(20) is null and segment20 >= g_segment_low(20)) or
			(g_segment_low(20) = 'LK' and segment20 like g_segment_high(20)) or (g_segment_low(20) is not null and g_segment_high(20) is not null and g_segment_low(20) <> 'LK' and segment20 between g_segment_low(20) and g_segment_high(20)) )
		and ( (segment21 is null) or (g_segment_low(21) is null and g_segment_high(21) is null) or (g_segment_low(21) is null and segment21 <= g_segment_high(21)) or (g_segment_high(21) is null and segment21 >= g_segment_low(21)) or
			(g_segment_low(21) = 'LK' and segment21 like g_segment_high(21)) or (g_segment_low(21) is not null and g_segment_high(21) is not null and g_segment_low(21) <> 'LK' and segment21 between g_segment_low(21) and g_segment_high(21)) )
		and ( (segment22 is null) or (g_segment_low(22) is null and g_segment_high(22) is null) or (g_segment_low(22) is null and segment22 <= g_segment_high(22)) or (g_segment_high(22) is null and segment22 >= g_segment_low(22)) or
			(g_segment_low(22) = 'LK' and segment22 like g_segment_high(22)) or (g_segment_low(22) is not null and g_segment_high(22) is not null and g_segment_low(22) <> 'LK' and segment22 between g_segment_low(22) and g_segment_high(22)) )
		and ( (segment23 is null) or (g_segment_low(23) is null and g_segment_high(23) is null) or (g_segment_low(23) is null and segment23 <= g_segment_high(23)) or (g_segment_high(23) is null and segment23 >= g_segment_low(23)) or
			(g_segment_low(23) = 'LK' and segment23 like g_segment_high(23)) or (g_segment_low(23) is not null and g_segment_high(23) is not null and g_segment_low(23) <> 'LK' and segment23 between g_segment_low(23) and g_segment_high(23)) )
		and ( (segment24 is null) or (g_segment_low(24) is null and g_segment_high(24) is null) or (g_segment_low(24) is null and segment24 <= g_segment_high(24)) or (g_segment_high(24) is null and segment24 >= g_segment_low(24)) or
			(g_segment_low(24) = 'LK' and segment24 like g_segment_high(24)) or (g_segment_low(24) is not null and g_segment_high(24) is not null and g_segment_low(24) <> 'LK' and segment24 between g_segment_low(24) and g_segment_high(24)) )
		and ( (segment25 is null) or (g_segment_low(25) is null and g_segment_high(25) is null) or (g_segment_low(25) is null and segment25 <= g_segment_high(25)) or (g_segment_high(25) is null and segment25 >= g_segment_low(25)) or
			(g_segment_low(25) = 'LK' and segment25 like g_segment_high(25)) or (g_segment_low(25) is not null and g_segment_high(25) is not null and g_segment_low(25) <> 'LK' and segment25 between g_segment_low(25) and g_segment_high(25)) )
		and ( (segment26 is null) or (g_segment_low(26) is null and g_segment_high(26) is null) or (g_segment_low(26) is null and segment26 <= g_segment_high(26)) or (g_segment_high(26) is null and segment26 >= g_segment_low(26)) or
			(g_segment_low(26) = 'LK' and segment26 like g_segment_high(26)) or (g_segment_low(26) is not null and g_segment_high(26) is not null and g_segment_low(26) <> 'LK' and segment26 between g_segment_low(26) and g_segment_high(26)) )
		and ( (segment27 is null) or (g_segment_low(27) is null and g_segment_high(27) is null) or (g_segment_low(27) is null and segment27 <= g_segment_high(27)) or (g_segment_high(27) is null and segment27 >= g_segment_low(27)) or
			(g_segment_low(27) = 'LK' and segment27 like g_segment_high(27)) or (g_segment_low(27) is not null and g_segment_high(27) is not null and g_segment_low(27) <> 'LK' and segment27 between g_segment_low(27) and g_segment_high(27)) )
		and ( (segment28 is null) or (g_segment_low(28) is null and g_segment_high(28) is null) or (g_segment_low(28) is null and segment28 <= g_segment_high(28)) or (g_segment_high(28) is null and segment28 >= g_segment_low(28)) or
			(g_segment_low(28) = 'LK' and segment28 like g_segment_high(28)) or (g_segment_low(28) is not null and g_segment_high(28) is not null and g_segment_low(28) <> 'LK' and segment28 between g_segment_low(28) and g_segment_high(28)) )
		and ( (segment29 is null) or (g_segment_low(29) is null and g_segment_high(29) is null) or (g_segment_low(29) is null and segment29 <= g_segment_high(29)) or (g_segment_high(29) is null and segment29 >= g_segment_low(29)) or
			(g_segment_low(29) = 'LK' and segment29 like g_segment_high(29)) or (g_segment_low(29) is not null and g_segment_high(29) is not null and g_segment_low(29) <> 'LK' and segment29 between g_segment_low(29) and g_segment_high(29)) )
		and ( (segment30 is null) or (g_segment_low(30) is null and g_segment_high(30) is null) or (g_segment_low(30) is null and segment30 <= g_segment_high(30)) or (g_segment_high(30) is null and segment30 >= g_segment_low(30)) or
			(g_segment_low(30) = 'LK' and segment30 like g_segment_high(30)) or (g_segment_low(30) is not null and g_segment_high(30) is not null and g_segment_low(30) <> 'LK' and segment30 between g_segment_low(30) and g_segment_high(30)) ))
		GROUP BY DECODE(UPPER(account_type),'L','I','O','I','R','I','C','I','A','E','E');
--
    l_cr_dr    NUMBER;
    ltot1 number:=0;
    ltot2 number:=0;
    ltot3 number:=0;
    ltot4 number:=0;
    ltot5 number:=0;
    ltot6 number:=0;
    ltot7 number:=0;
    ltot8 number:=0;
    ltot9 number:=0;
    ltot10 number:=0;
    ltot11 number:=0;
    ltot12 number:=0;
    l_return_status     VARCHAR2(1);

 BEGIN

   if (nvl(p_flex_value, '%') <> '%') then
   begin

     if p_chart_of_accounts <> nvl(PSB_WS_ACCT1.g_flex_code, 0) then
     begin

       PSB_WS_ACCT1.Flex_Info (p_flex_code => p_chart_of_accounts, p_return_status => l_return_status);

     end;
     end if;

     g_flex_delimiter := fnd_flex_ext.get_delimiter(application_short_name => 'SQLGL',
						  key_flex_code => 'GL#',
						  structure_number => p_chart_of_accounts);

     g_segment_count := FND_FLEX_EXT.breakup_segments(p_flex_value, g_flex_delimiter, g_segment_values);

    /*For Bug No : 2012827 Start*/
     for i in g_segment_count+1..30 loop
       g_segment_values(i) := null;
     end loop;
    /*For Bug No : 2012827 End*/

     assign_seg_values;

     for c_sum_partial_rec in c_sum_partial loop

      if c_sum_partial_rec.account_type = 'I' then
	ltot1 := ltot1 + c_sum_partial_rec.A;
	ltot2 := ltot2 + c_sum_partial_rec.B;
	ltot3 := ltot3 + c_sum_partial_rec.C;
	ltot4 := ltot4 + c_sum_partial_rec.D;
	ltot5 := ltot5 + c_sum_partial_rec.E;
	ltot6 := ltot6 + c_sum_partial_rec.F;
	ltot7 := ltot7 + c_sum_partial_rec.G;
	ltot8 := ltot8 + c_sum_partial_rec.H;
	ltot9 := ltot9 + c_sum_partial_rec.I;
	ltot10 := ltot10 + c_sum_partial_rec.J;
	ltot11 := ltot11 + c_sum_partial_rec.K;
	ltot12 := ltot12 + c_sum_partial_rec.L;
      ELSE
	ltot1 := ltot1 - c_sum_partial_rec.A;
	ltot2 := ltot2 - c_sum_partial_rec.B;
	ltot3 := ltot3 - c_sum_partial_rec.C;
	ltot4 := ltot4 - c_sum_partial_rec.D;
	ltot5 := ltot5 - c_sum_partial_rec.E;
	ltot6 := ltot6 - c_sum_partial_rec.F;
	ltot7 := ltot7 - c_sum_partial_rec.G;
	ltot8 := ltot8 - c_sum_partial_rec.H;
	ltot9 := ltot9 - c_sum_partial_rec.I;
	ltot10 := ltot10 - c_sum_partial_rec.J;
	ltot11 := ltot11 - c_sum_partial_rec.K;
	ltot12 := ltot12 - c_sum_partial_rec.L;
      END IF;

     end loop;

   end;
   else
   begin

     FOR c_sum_all_rec IN c_sum_all LOOP

      IF c_sum_all_rec.account_type = 'I' THEN
	ltot1 := ltot1 + c_sum_all_rec.A;
	ltot2 := ltot2 + c_sum_all_rec.B;
	ltot3 := ltot3 + c_sum_all_rec.C;
	ltot4 := ltot4 + c_sum_all_rec.D;
	ltot5 := ltot5 + c_sum_all_rec.E;
	ltot6 := ltot6 + c_sum_all_rec.F;
	ltot7 := ltot7 + c_sum_all_rec.G;
	ltot8 := ltot8 + c_sum_all_rec.H;
	ltot9 := ltot9 + c_sum_all_rec.I;
	ltot10 := ltot10 + c_sum_all_rec.J;
	ltot11 := ltot11 + c_sum_all_rec.K;
	ltot12 := ltot12 + c_sum_all_rec.L;
      ELSE
	ltot1 := ltot1 - c_sum_all_rec.A;
	ltot2 := ltot2 - c_sum_all_rec.B;
	ltot3 := ltot3 - c_sum_all_rec.C;
	ltot4 := ltot4 - c_sum_all_rec.D;
	ltot5 := ltot5 - c_sum_all_rec.E;
	ltot6 := ltot6 - c_sum_all_rec.F;
	ltot7 := ltot7 - c_sum_all_rec.G;
	ltot8 := ltot8 - c_sum_all_rec.H;
	ltot9 := ltot9 - c_sum_all_rec.I;
	ltot10 := ltot10 - c_sum_all_rec.J;
	ltot11 := ltot11 - c_sum_all_rec.K;
	ltot12 := ltot12 - c_sum_all_rec.L;
      END IF;
    END LOOP;

   end;
   END IF;

  IF p_account_flag in ('A','E','N') THEN
     l_cr_dr := -1;
  ELSE
     l_cr_dr := 1;
  END IF;
  p1_amount  := ltot1 * l_cr_dr;
  p2_amount  := ltot2 * l_cr_dr;
  p3_amount  := ltot3 * l_cr_dr;
  p4_amount  := ltot4 * l_cr_dr;
  p5_amount  := ltot5 * l_cr_dr;
  p6_amount  := ltot6 * l_cr_dr;
  p7_amount  := ltot7 * l_cr_dr;
  p8_amount  := ltot8 * l_cr_dr;
  p9_amount  := ltot9 * l_cr_dr;
  p10_amount := ltot10 * l_cr_dr;
  p11_amount := ltot11 * l_cr_dr;
  p12_amount := ltot12 * l_cr_dr;

  END Get_Totals;


PROCEDURE Position_Totals
 (
  pworksheet_id                 number,
--following 1 parameter added for DDSP
  pprofile_worksheet_id         number,
  pposition_line_id             number,
  paccount_flag                 varchar2,
  pcurrency_flag                varchar2,
  pservice_package_flag         varchar2,
  pselection_exists             varchar2,
  puser_id                      number,
  pchart_of_accounts_id         number,
  pspkg_name                    varchar2,
  pflex_value                   varchar2,
  ptcolumn1             OUT  NOCOPY     number,
  ptcolumn2             OUT  NOCOPY     number,
  ptcolumn3             OUT  NOCOPY     number,
  ptcolumn4             OUT  NOCOPY     number,
  ptcolumn5             OUT  NOCOPY     number,
  ptcolumn6             OUT  NOCOPY     number,
  ptcolumn7             OUT  NOCOPY     number,
  ptcolumn8             OUT  NOCOPY     number,
  ptcolumn9             OUT  NOCOPY     number,
  ptcolumn10            OUT  NOCOPY     number,
  ptcolumn11            OUT  NOCOPY     number,
  ptcolumn12            OUT  NOCOPY     number

 ) IS

/* Bug 3331024 Remove Rule Hint */
  cursor c_sum_all is
      select NVL(SUM(column1),0)  A, NVL(SUM(column2),0)  B, NVL(SUM(column3),0)  C, NVL(SUM(column4),0)  D,
	     NVL(SUM(column5),0)  E, NVL(SUM(column6),0)  F, NVL(SUM(column7),0)  G, NVL(SUM(column8),0)  H,
	     NVL(SUM(column9),0)  I, NVL(SUM(column10),0) J, NVL(SUM(column11),0) K, NVL(SUM(column12),0) L
	FROM PSB_WS_YEAR_POSITION_AMOUNTS_V  WYA
       WHERE worksheet_id = pworksheet_id
	 AND position_line_id = pposition_line_id
	 AND ((pcurrency_flag = 'C' AND currency_code <> 'STAT') OR (pcurrency_flag = 'S' AND currency_code = 'STAT'))
	 AND template_id is null
/* Bug No 2543015 Start */
	 AND (pservice_package_flag = 'A'
		OR (pselection_exists = 'N'
			AND service_package_id IN
				(SELECT sp.service_package_id
				   FROM PSB_SERVICE_PACKAGES sp, PSB_WORKSHEETS w
				  WHERE sp.global_worksheet_id = nvl(w.global_worksheet_id, w.worksheet_id)
				    AND w.worksheet_id = pworksheet_id
				    AND sp.name like pspkg_name))
		OR (pselection_exists = 'Y'
			AND service_package_id IN
				(SELECT service_package_id
				   FROM PSB_WS_SERVICE_PKG_PROFILES_V
				  WHERE worksheet_id = pprofile_worksheet_id
				    AND ((user_id =  puser_id) or (puser_id is null and user_id is null))
				    AND service_package_name like decode(pspkg_name, '%', service_package_name, pspkg_name))));
/* Bug No 2543015 End */

/* Bug 3331024 Remove Rule Hint */
  cursor c_sum_partial is
      select NVL(SUM(column1),0)  A, NVL(SUM(column2),0)  B, NVL(SUM(column3),0)  C, NVL(SUM(column4),0)  D,
	     NVL(SUM(column5),0)  E, NVL(SUM(column6),0)  F, NVL(SUM(column7),0)  G, NVL(SUM(column8),0)  H,
	     NVL(SUM(column9),0)  I, NVL(SUM(column10),0) J, NVL(SUM(column11),0) K, NVL(SUM(column12),0) L
	FROM PSB_WS_YEAR_POSITION_AMOUNTS_V  WYA
       WHERE worksheet_id = pworksheet_id
	 AND position_line_id = pposition_line_id
	 AND ((pcurrency_flag = 'C' AND currency_code <> 'STAT') OR (pcurrency_flag = 'S' AND currency_code = 'STAT'))
	 AND template_id is null
/* Bug No 2543015 Start */
	 AND (pservice_package_flag = 'A'
		OR (pselection_exists = 'N'
			AND service_package_id IN
				(SELECT sp.service_package_id
				   FROM PSB_SERVICE_PACKAGES sp, PSB_WORKSHEETS w
				  WHERE sp.global_worksheet_id = nvl(w.global_worksheet_id, w.worksheet_id)
				    AND w.worksheet_id = pworksheet_id
				    AND sp.name like pspkg_name))
		OR (pselection_exists = 'Y'
			AND service_package_id IN
				(SELECT service_package_id
				   FROM PSB_WS_SERVICE_PKG_PROFILES_V
				  WHERE worksheet_id = pprofile_worksheet_id
				    AND ((user_id =  puser_id) or (puser_id is null and user_id is null))
				    AND service_package_name like decode(pspkg_name, '%', service_package_name, pspkg_name))))
/* Bug No 2543015 End */
	 AND EXISTS
	    (select 1 from gl_code_combinations
	      where code_combination_id = WYA.code_combination_id
		and chart_of_accounts_id = pchart_of_accounts_id
		and ( (segment1 is null) or (g_segment_low(1) is null and g_segment_high(1) is null) or (g_segment_low(1) is null and segment1 <= g_segment_high(1)) or (g_segment_high(1) is null and segment1 >= g_segment_low(1)) or
			(g_segment_low(1) = 'LK' and segment1 like g_segment_high(1)) or (g_segment_low(1) is not null and g_segment_high(1) is not null and g_segment_low(1) <> 'LK' and segment1 between g_segment_low(1) and g_segment_high(1)) )
		and ( (segment2 is null) or (g_segment_low(2) is null and g_segment_high(2) is null) or (g_segment_low(2) is null and segment2 <= g_segment_high(2)) or (g_segment_high(2) is null and segment2 >= g_segment_low(2)) or
			(g_segment_low(2) = 'LK' and segment2 like g_segment_high(2)) or (g_segment_low(2) is not null and g_segment_high(2) is not null and g_segment_low(2) <> 'LK' and segment2 between g_segment_low(2) and g_segment_high(2)) )
		and ( (segment3 is null) or (g_segment_low(3) is null and g_segment_high(3) is null) or (g_segment_low(3) is null and segment3 <= g_segment_high(3)) or (g_segment_high(3) is null and segment3 >= g_segment_low(3)) or
			(g_segment_low(3) = 'LK' and segment3 like g_segment_high(3)) or (g_segment_low(3) is not null and g_segment_high(3) is not null and g_segment_low(3) <> 'LK' and segment3 between g_segment_low(3) and g_segment_high(3)) )
		and ( (segment4 is null) or (g_segment_low(4) is null and g_segment_high(4) is null) or (g_segment_low(4) is null and segment4 <= g_segment_high(4)) or (g_segment_high(4) is null and segment4 >= g_segment_low(4)) or
			(g_segment_low(4) = 'LK' and segment4 like g_segment_high(4)) or (g_segment_low(4) is not null and g_segment_high(4) is not null and g_segment_low(4) <> 'LK' and segment4 between g_segment_low(4) and g_segment_high(4)) )
		and ( (segment5 is null) or (g_segment_low(5) is null and g_segment_high(5) is null) or (g_segment_low(5) is null and segment5 <= g_segment_high(5)) or (g_segment_high(5) is null and segment5 >= g_segment_low(5)) or
			(g_segment_low(5) = 'LK' and segment5 like g_segment_high(5)) or (g_segment_low(5) is not null and g_segment_high(5) is not null and g_segment_low(5) <> 'LK' and segment5 between g_segment_low(5) and g_segment_high(5)) )
		and ( (segment6 is null) or (g_segment_low(6) is null and g_segment_high(6) is null) or (g_segment_low(6) is null and segment6 <= g_segment_high(6)) or (g_segment_high(6) is null and segment6 >= g_segment_low(6)) or
			(g_segment_low(6) = 'LK' and segment6 like g_segment_high(6)) or (g_segment_low(6) is not null and g_segment_high(6) is not null and g_segment_low(6) <> 'LK' and segment6 between g_segment_low(6) and g_segment_high(6)) )
		and ( (segment7 is null) or (g_segment_low(7) is null and g_segment_high(7) is null) or (g_segment_low(7) is null and segment7 <= g_segment_high(7)) or (g_segment_high(7) is null and segment7 >= g_segment_low(7)) or
			(g_segment_low(7) = 'LK' and segment7 like g_segment_high(7)) or (g_segment_low(7) is not null and g_segment_high(7) is not null and g_segment_low(7) <> 'LK' and segment7 between g_segment_low(7) and g_segment_high(7)) )
		and ( (segment8 is null) or (g_segment_low(8) is null and g_segment_high(8) is null) or (g_segment_low(8) is null and segment8 <= g_segment_high(8)) or (g_segment_high(8) is null and segment8 >= g_segment_low(8)) or
			(g_segment_low(8) = 'LK' and segment8 like g_segment_high(8)) or (g_segment_low(8) is not null and g_segment_high(8) is not null and g_segment_low(8) <> 'LK' and segment8 between g_segment_low(8) and g_segment_high(8)) )
		and ( (segment9 is null) or (g_segment_low(9) is null and g_segment_high(9) is null) or (g_segment_low(9) is null and segment9 <= g_segment_high(9)) or (g_segment_high(9) is null and segment9 >= g_segment_low(9)) or
			(g_segment_low(9) = 'LK' and segment9 like g_segment_high(9)) or (g_segment_low(9) is not null and g_segment_high(9) is not null and g_segment_low(9) <> 'LK' and segment9 between g_segment_low(9) and g_segment_high(9)) )
		and ( (segment10 is null) or (g_segment_low(10) is null and g_segment_high(10) is null) or (g_segment_low(10) is null and segment10 <= g_segment_high(10)) or (g_segment_high(10) is null and segment10 >= g_segment_low(10)) or
			(g_segment_low(10) = 'LK' and segment10 like g_segment_high(10)) or (g_segment_low(10) is not null and g_segment_high(10) is not null and g_segment_low(10) <> 'LK' and segment10 between g_segment_low(10) and g_segment_high(10)) )
		and ( (segment11 is null) or (g_segment_low(11) is null and g_segment_high(11) is null) or (g_segment_low(11) is null and segment11 <= g_segment_high(11)) or (g_segment_high(11) is null and segment11 >= g_segment_low(11)) or
			(g_segment_low(11) = 'LK' and segment11 like g_segment_high(11)) or (g_segment_low(11) is not null and g_segment_high(11) is not null and g_segment_low(11) <> 'LK' and segment11 between g_segment_low(11) and g_segment_high(11)) )
		and ( (segment12 is null) or (g_segment_low(12) is null and g_segment_high(12) is null) or (g_segment_low(12) is null and segment12 <= g_segment_high(12)) or (g_segment_high(12) is null and segment12 >= g_segment_low(12)) or
			(g_segment_low(12) = 'LK' and segment12 like g_segment_high(12)) or (g_segment_low(12) is not null and g_segment_high(12) is not null and g_segment_low(12) <> 'LK' and segment12 between g_segment_low(12) and g_segment_high(12)) )
		and ( (segment13 is null) or (g_segment_low(13) is null and g_segment_high(13) is null) or (g_segment_low(13) is null and segment13 <= g_segment_high(13)) or (g_segment_high(13) is null and segment13 >= g_segment_low(13)) or
			(g_segment_low(13) = 'LK' and segment13 like g_segment_high(13)) or (g_segment_low(13) is not null and g_segment_high(13) is not null and g_segment_low(13) <> 'LK' and segment13 between g_segment_low(13) and g_segment_high(13)) )
		and ( (segment14 is null) or (g_segment_low(14) is null and g_segment_high(14) is null) or (g_segment_low(14) is null and segment14 <= g_segment_high(14)) or (g_segment_high(14) is null and segment14 >= g_segment_low(14)) or
			(g_segment_low(14) = 'LK' and segment14 like g_segment_high(14)) or (g_segment_low(14) is not null and g_segment_high(14) is not null and g_segment_low(14) <> 'LK' and segment14 between g_segment_low(14) and g_segment_high(14)) )
		and ( (segment15 is null) or (g_segment_low(15) is null and g_segment_high(15) is null) or (g_segment_low(15) is null and segment15 <= g_segment_high(15)) or (g_segment_high(15) is null and segment15 >= g_segment_low(15)) or
			(g_segment_low(15) = 'LK' and segment15 like g_segment_high(15)) or (g_segment_low(15) is not null and g_segment_high(15) is not null and g_segment_low(15) <> 'LK' and segment15 between g_segment_low(15) and g_segment_high(15)) )
		and ( (segment16 is null) or (g_segment_low(16) is null and g_segment_high(16) is null) or (g_segment_low(16) is null and segment16 <= g_segment_high(16)) or (g_segment_high(16) is null and segment16 >= g_segment_low(16)) or
			(g_segment_low(16) = 'LK' and segment16 like g_segment_high(16)) or (g_segment_low(16) is not null and g_segment_high(16) is not null and g_segment_low(16) <> 'LK' and segment16 between g_segment_low(16) and g_segment_high(16)) )
		and ( (segment17 is null) or (g_segment_low(17) is null and g_segment_high(17) is null) or (g_segment_low(17) is null and segment17 <= g_segment_high(17)) or (g_segment_high(17) is null and segment17 >= g_segment_low(17)) or
			(g_segment_low(17) = 'LK' and segment17 like g_segment_high(17)) or (g_segment_low(17) is not null and g_segment_high(17) is not null and g_segment_low(17) <> 'LK' and segment17 between g_segment_low(17) and g_segment_high(17)) )
		and ( (segment18 is null) or (g_segment_low(18) is null and g_segment_high(18) is null) or (g_segment_low(18) is null and segment18 <= g_segment_high(18)) or (g_segment_high(18) is null and segment18 >= g_segment_low(18)) or
			(g_segment_low(18) = 'LK' and segment18 like g_segment_high(18)) or (g_segment_low(18) is not null and g_segment_high(18) is not null and g_segment_low(18) <> 'LK' and segment18 between g_segment_low(18) and g_segment_high(18)) )
		and ( (segment19 is null) or (g_segment_low(19) is null and g_segment_high(19) is null) or (g_segment_low(19) is null and segment19 <= g_segment_high(19)) or (g_segment_high(19) is null and segment19 >= g_segment_low(19)) or
			(g_segment_low(19) = 'LK' and segment19 like g_segment_high(19)) or (g_segment_low(19) is not null and g_segment_high(19) is not null and g_segment_low(19) <> 'LK' and segment19 between g_segment_low(19) and g_segment_high(19)) )
		and ( (segment20 is null) or (g_segment_low(20) is null and g_segment_high(20) is null) or (g_segment_low(20) is null and segment20 <= g_segment_high(20)) or (g_segment_high(20) is null and segment20 >= g_segment_low(20)) or
			(g_segment_low(20) = 'LK' and segment20 like g_segment_high(20)) or (g_segment_low(20) is not null and g_segment_high(20) is not null and g_segment_low(20) <> 'LK' and segment20 between g_segment_low(20) and g_segment_high(20)) )
		and ( (segment21 is null) or (g_segment_low(21) is null and g_segment_high(21) is null) or (g_segment_low(21) is null and segment21 <= g_segment_high(21)) or (g_segment_high(21) is null and segment21 >= g_segment_low(21)) or
			(g_segment_low(21) = 'LK' and segment21 like g_segment_high(21)) or (g_segment_low(21) is not null and g_segment_high(21) is not null and g_segment_low(21) <> 'LK' and segment21 between g_segment_low(21) and g_segment_high(21)) )
		and ( (segment22 is null) or (g_segment_low(22) is null and g_segment_high(22) is null) or (g_segment_low(22) is null and segment22 <= g_segment_high(22)) or (g_segment_high(22) is null and segment22 >= g_segment_low(22)) or
			(g_segment_low(22) = 'LK' and segment22 like g_segment_high(22)) or (g_segment_low(22) is not null and g_segment_high(22) is not null and g_segment_low(22) <> 'LK' and segment22 between g_segment_low(22) and g_segment_high(22)) )
		and ( (segment23 is null) or (g_segment_low(23) is null and g_segment_high(23) is null) or (g_segment_low(23) is null and segment23 <= g_segment_high(23)) or (g_segment_high(23) is null and segment23 >= g_segment_low(23)) or
			(g_segment_low(23) = 'LK' and segment23 like g_segment_high(23)) or (g_segment_low(23) is not null and g_segment_high(23) is not null and g_segment_low(23) <> 'LK' and segment23 between g_segment_low(23) and g_segment_high(23)) )
		and ( (segment24 is null) or (g_segment_low(24) is null and g_segment_high(24) is null) or (g_segment_low(24) is null and segment24 <= g_segment_high(24)) or (g_segment_high(24) is null and segment24 >= g_segment_low(24)) or
			(g_segment_low(24) = 'LK' and segment24 like g_segment_high(24)) or (g_segment_low(24) is not null and g_segment_high(24) is not null and g_segment_low(24) <> 'LK' and segment24 between g_segment_low(24) and g_segment_high(24)) )
		and ( (segment25 is null) or (g_segment_low(25) is null and g_segment_high(25) is null) or (g_segment_low(25) is null and segment25 <= g_segment_high(25)) or (g_segment_high(25) is null and segment25 >= g_segment_low(25)) or
			(g_segment_low(25) = 'LK' and segment25 like g_segment_high(25)) or (g_segment_low(25) is not null and g_segment_high(25) is not null and g_segment_low(25) <> 'LK' and segment25 between g_segment_low(25) and g_segment_high(25)) )
		and ( (segment26 is null) or (g_segment_low(26) is null and g_segment_high(26) is null) or (g_segment_low(26) is null and segment26 <= g_segment_high(26)) or (g_segment_high(26) is null and segment26 >= g_segment_low(26)) or
			(g_segment_low(26) = 'LK' and segment26 like g_segment_high(26)) or (g_segment_low(26) is not null and g_segment_high(26) is not null and g_segment_low(26) <> 'LK' and segment26 between g_segment_low(26) and g_segment_high(26)) )
		and ( (segment27 is null) or (g_segment_low(27) is null and g_segment_high(27) is null) or (g_segment_low(27) is null and segment27 <= g_segment_high(27)) or (g_segment_high(27) is null and segment27 >= g_segment_low(27)) or
			(g_segment_low(27) = 'LK' and segment27 like g_segment_high(27)) or (g_segment_low(27) is not null and g_segment_high(27) is not null and g_segment_low(27) <> 'LK' and segment27 between g_segment_low(27) and g_segment_high(27)) )
		and ( (segment28 is null) or (g_segment_low(28) is null and g_segment_high(28) is null) or (g_segment_low(28) is null and segment28 <= g_segment_high(28)) or (g_segment_high(28) is null and segment28 >= g_segment_low(28)) or
			(g_segment_low(28) = 'LK' and segment28 like g_segment_high(28)) or (g_segment_low(28) is not null and g_segment_high(28) is not null and g_segment_low(28) <> 'LK' and segment28 between g_segment_low(28) and g_segment_high(28)) )
		and ( (segment29 is null) or (g_segment_low(29) is null and g_segment_high(29) is null) or (g_segment_low(29) is null and segment29 <= g_segment_high(29)) or (g_segment_high(29) is null and segment29 >= g_segment_low(29)) or
			(g_segment_low(29) = 'LK' and segment29 like g_segment_high(29)) or (g_segment_low(29) is not null and g_segment_high(29) is not null and g_segment_low(29) <> 'LK' and segment29 between g_segment_low(29) and g_segment_high(29)) )
		and ( (segment30 is null) or (g_segment_low(30) is null and g_segment_high(30) is null) or (g_segment_low(30) is null and segment30 <= g_segment_high(30)) or (g_segment_high(30) is null and segment30 >= g_segment_low(30)) or
			(g_segment_low(30) = 'LK' and segment30 like g_segment_high(30)) or (g_segment_low(30) is not null and g_segment_high(30) is not null and g_segment_low(30) <> 'LK' and segment30 between g_segment_low(30) and g_segment_high(30)) ));

     l_return_status     VARCHAR2(1);
  begin

   if (nvl(pflex_value, '%') <> '%') then
   begin

     if pchart_of_accounts_id <> nvl(PSB_WS_ACCT1.g_flex_code, 0) then
     begin

       PSB_WS_ACCT1.Flex_Info (p_flex_code => pchart_of_accounts_id, p_return_status => l_return_status);

     end;
     end if;

     g_flex_delimiter := fnd_flex_ext.get_delimiter(application_short_name => 'SQLGL',
						  key_flex_code => 'GL#',
						  structure_number => pchart_of_accounts_id);

     g_segment_count := FND_FLEX_EXT.breakup_segments(pflex_value, g_flex_delimiter, g_segment_values);

    /*For Bug No : 2012827 Start*/
     for i in g_segment_count+1..30 loop
       g_segment_values(i) := null;
     end loop;
    /*For Bug No : 2012827 End*/

     assign_seg_values;

     for c_sum_partial_rec in c_sum_partial loop

	ptcolumn1 := c_sum_partial_rec.A;
	ptcolumn2 := c_sum_partial_rec.B;
	ptcolumn3 := c_sum_partial_rec.C;
	ptcolumn4 := c_sum_partial_rec.D;
	ptcolumn5 := c_sum_partial_rec.E;
	ptcolumn6 := c_sum_partial_rec.F;
	ptcolumn7 := c_sum_partial_rec.G;
	ptcolumn8 := c_sum_partial_rec.H;
	ptcolumn9 := c_sum_partial_rec.I;
	ptcolumn10 := c_sum_partial_rec.J;
	ptcolumn11 := + c_sum_partial_rec.K;
	ptcolumn12 := c_sum_partial_rec.L;

     end loop;

   end;
   else
   begin

     FOR c_sum_all_rec IN c_sum_all LOOP

	ptcolumn1 := c_sum_all_rec.A;
	ptcolumn2 := c_sum_all_rec.B;
	ptcolumn3 := c_sum_all_rec.C;
	ptcolumn4 := c_sum_all_rec.D;
	ptcolumn5 := c_sum_all_rec.E;
	ptcolumn6 := c_sum_all_rec.F;
	ptcolumn7 := c_sum_all_rec.G;
	ptcolumn8 := c_sum_all_rec.H;
	ptcolumn9 := c_sum_all_rec.I;
	ptcolumn10 := c_sum_all_rec.J;
	ptcolumn11 := c_sum_all_rec.K;
	ptcolumn12 := c_sum_all_rec.L;

     END LOOP;

   end;
   end if;

 END Position_Totals;

END PSB_WS_YEAR_TOTAL;

/
