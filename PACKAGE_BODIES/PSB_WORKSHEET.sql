--------------------------------------------------------
--  DDL for Package Body PSB_WORKSHEET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WORKSHEET" AS
/* $Header: PSBVWCMB.pls 120.15.12010000.3 2009/03/30 12:59:10 rkotha ship $ */

  G_PKG_NAME CONSTANT        VARCHAR2(30):= 'PSB_WORKSHEET';

  -- TokNameArray contains names of all tokens

  TYPE TokNameArray IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

  -- TokValArray contains values for all tokens

  TYPE TokValArray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

  -- number of Message Tokens

  no_msg_tokens                NUMBER := 0;

  -- Message Token Name

  msg_tok_names                TokNameArray;

  -- Message Token Value

  msg_tok_val                  TokValArray;

  g_set_of_books_id            NUMBER;
  g_set_of_books_name          VARCHAR2(30);
  g_business_group_id          NUMBER;
  g_flex_code                  NUMBER;
  g_currency_code              VARCHAR2(15);
  g_budgetary_control          VARCHAR2(1);

  g_budget_group_name          VARCHAR2(80);

  g_budget_group_id            NUMBER;
  /* Bug 3543845 start */
  -- Commented out then made the following variable public
  --g_parameter_set_id           NUMBER;
  --g_num_years_to_allocate      NUMBER;
  --g_budget_by_position         VARCHAR2(1);
  --g_root_budget_group_id       NUMBER;
  /* Bug 3543845 End */

  g_constraint_set_id          NUMBER;
  g_data_extract_id            NUMBER;
  g_data_extract_name          VARCHAR2(30);
  g_global_worksheet           VARCHAR2(1);
  g_global_worksheet_option    VARCHAR2(1);
  g_budget_version_id          NUMBER;
  g_gl_budget_set_id           NUMBER;
  -- g_gl_cutoff_period           DATE;
  /* made the above global variable public.declared it in the spec
     Bug 3469514 */

  /* Bug 3458191 start */
  -- Moving the following variables to public
  -- g_budget_calendar_id         NUMBER;
  -- g_allocrule_set_id           NUMBER;
  -- g_global_worksheet_id        NUMBER;
  -- g_local_copy_flag            VARCHAR2(1);
  -- g_rounding_factor            NUMBER;
  -- g_stage_set_id               NUMBER;
  -- g_current_stage_seq          NUMBER;
  -- g_flex_mapping_set_id        NUMBER;
  /* Bug 3458191 end */

  g_use_revised_element_rates  VARCHAR2(1);
  g_num_proposed_years         NUMBER;
  g_start_stage_seq            NUMBER;
  g_incl_stat_bal              VARCHAR2(1);
  g_incl_trans_bal             VARCHAR2(1);
  g_incl_adj_period            VARCHAR2(1);
  g_create_non_pos_line_items  VARCHAR2(1);
  g_apply_element_parameters   VARCHAR2(1);
  g_apply_position_parameters  VARCHAR2(1);
  g_create_positions           VARCHAR2(1);
  g_create_summary_totals      VARCHAR2(1);
  g_apply_constraints          VARCHAR2(1);
  g_include_gl_commit_balance  VARCHAR2(1);
  g_include_gl_oblig_balance   VARCHAR2(1);
  g_include_gl_other_balance   VARCHAR2(1);
  g_include_cbc_commit_balance VARCHAR2(1);
  g_include_cbc_oblig_balance  VARCHAR2(1);
  g_include_cbc_budget_balance VARCHAR2(1);

  /* bug no 4725091 */
  g_include_gl_forward_balance VARCHAR2(1);


  g_service_package_id         NUMBER;

  g_cs_name                    VARCHAR2(30);
  g_cs_threshold               NUMBER;

  g_sp1_status                 VARCHAR2(1);
  g_sp2_status                 VARCHAR2(1);
  g_sp3_status                 VARCHAR2(1);
  g_sp4_status                 VARCHAR2(1);

  g_chr10 CONSTANT VARCHAR2(1) := FND_GLOBAL.Newline;

  g_dbug                       VARCHAR2(1000);

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function Definition                        */
/*                                                                         */
/* ----------------------------------------------------------------------- */

PROCEDURE Initialize
( p_worksheet_id   IN   NUMBER,
  p_return_status  OUT  NOCOPY  VARCHAR2);

PROCEDURE Cache_Worksheet_Variables
( p_worksheet_id   IN   NUMBER,
  p_return_status  OUT  NOCOPY  VARCHAR2);

PROCEDURE Check_DataExt_Completion
( p_data_extract_id  IN   NUMBER,
  p_return_status    OUT  NOCOPY  VARCHAR2);

PROCEDURE message_token
( tokname  IN  VARCHAR2,
  tokval   IN  VARCHAR2);

PROCEDURE add_message
(appname  IN  VARCHAR2,
 msgname  IN  VARCHAR2);

/* ----------------------------------------------------------------------- */

PROCEDURE Check_Reentrant_Status
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_parameter_set_id    IN   NUMBER,
  p_constraint_set_id   IN   NUMBER,
  p_allocrule_set_id    IN   NUMBER,
  p_budget_calendar_id  IN   NUMBER,
  p_budget_group_id     IN   NUMBER,
  p_data_extract_id     IN   NUMBER,
  p_gl_budget_set_id    IN   NUMBER
) IS

  l_return_status       VARCHAR2(1);

  l_count_glset1        NUMBER;
  l_lud_glset1          DATE;
  l_count_glset2        NUMBER;
  l_lud_glset2          DATE;

  l_count_ps1           NUMBER;
  l_lud_ps1             DATE;
  l_count_ps2           NUMBER;
  l_lud_ps2             DATE;

  l_count_cs1           NUMBER;
  l_lud_cs1             DATE;
  l_count_cs2           NUMBER;
  l_lud_cs2             DATE;

  l_count_ar1           NUMBER;
  l_lud_ar1             DATE;
  l_count_ar2           NUMBER;
  l_lud_ar2             DATE;

  l_count_bc            NUMBER;
  l_lud_bc              DATE;

  l_count_bg1           NUMBER;
  l_lud_bg1             DATE;
  l_count_bg2           NUMBER;
  l_lud_bg2             DATE;

  l_lud_de              DATE;

  l_count_assign        NUMBER;
  l_lud_assign          DATE;

  l_count_rates         NUMBER;
  l_lud_rates           DATE;

  l_count_dist          NUMBER;
  l_lud_dist            DATE;

  l_rec_found           VARCHAR2(1) := FND_API.G_FALSE;
  l_restart             VARCHAR2(1);

  cursor c_Reent_Status is
    select to_number(attribute1) count_ps1,
	   to_date(attribute2, 'YYYY/MM/DD HH24:MI:SS') lud_ps1,
	   to_number(attribute3) count_ps2,
	   to_date(attribute4, 'YYYY/MM/DD HH24:MI:SS') lud_ps2,
	   to_number(attribute5) count_cs1,
	   to_date(attribute6, 'YYYY/MM/DD HH24:MI:SS') lud_cs1,
	   to_number(attribute7) count_cs2,
	   to_date(attribute8, 'YYYY/MM/DD HH24:MI:SS') lud_cs2,
	   to_number(attribute9) count_ar1,
	   to_date(attribute10, 'YYYY/MM/DD HH24:MI:SS') lud_ar1,
	   to_number(attribute11) count_ar2,
	   to_date(attribute12, 'YYYY/MM/DD HH24:MI:SS') lud_ar2,
	   to_number(attribute13) count_bc,
	   to_date(attribute14, 'YYYY/MM/DD HH24:MI:SS') lud_bc,
	   to_number(attribute15) count_bg1,
	   to_date(attribute16, 'YYYY/MM/DD HH24:MI:SS') lud_bg1,
	   to_number(attribute17) count_bg2,
	   to_date(attribute18, 'YYYY/MM/DD HH24:MI:SS') lud_bg2,
	   to_date(attribute19, 'YYYY/MM/DD HH24:MI:SS') lud_de,
	   to_number(attribute20) count_assign,
	   to_date(attribute21, 'YYYY/MM/DD HH24:MI:SS') lud_assign,
	   to_number(attribute22) count_rates,
	   to_date(attribute23, 'YYYY/MM/DD HH24:MI:SS') lud_rates,
	   to_number(attribute24) count_dist,
	   to_date(attribute25, 'YYYY/MM/DD HH24:MI:SS') lud_dist,
	   to_number(attribute26) count_glset1,
	   to_date(attribute27, 'YYYY/MM/DD HH24:MI:SS') lud_glset1,
	   to_number(attribute28) count_glset2,
	   to_date(attribute29, 'YYYY/MM/DD HH24:MI:SS') lud_glset2,
           TO_DATE(attribute30, 'YYYY/MM/DD HH24:MI:SS') gcd_ws,
	   sp1_status,
	   sp2_status,
	   sp3_status,
	   sp4_status
      from PSB_REENTRANT_PROCESS_STATUS
     where process_type = 'WORKSHEET_CREATION'
       and process_uid = p_worksheet_id;

  cursor c_glset1 is
    select Count(*) count_glset1,
	   Max(last_update_date) lud_glset1
      from PSB_GL_BUDGETS
     where gl_budget_set_id = p_gl_budget_set_id;

  cursor c_glset2 is
    select Count(*) count_glset2,
	   Max(last_update_date) lud_glset2
      from PSB_SET_RELATIONS
     where gl_budget_id in
	  (select gl_budget_id
	     from PSB_GL_BUDGETS
	    where gl_budget_set_id = p_gl_budget_set_id);

  cursor c_ps1 is
    select Count(*) count_ps1,
	   Max(last_update_date) lud_ps1
      from PSB_PARAMETER_ASSIGNMENTS_V
     where parameter_set_id = p_parameter_set_id;

  cursor c_ps2 is
    select Count(*) count_ps2,
	   Max(last_update_date) lud_ps2
      from PSB_SET_RELATIONS
     where parameter_id in
	  (select parameter_id
	     from PSB_PARAMETER_ASSIGNMENTS_V
	    where parameter_set_id = p_parameter_set_id);

  cursor c_cs1 is
    select Count(*) count_cs1,
	   Max(last_update_date) lud_cs1
      from PSB_CONSTRAINT_ASSIGNMENTS_V
     where constraint_set_id = p_constraint_set_id;

  cursor c_cs2 is
    select Count(*) count_cs2,
	   Max(last_update_date) lud_cs2
      from PSB_SET_RELATIONS
     where constraint_id in
	  (select constraint_id
	     from PSB_CONSTRAINT_ASSIGNMENTS_V
	    where constraint_set_id = p_constraint_set_id);

  cursor c_ar1 is
    select Count(*) count_ar1,
	   Max(last_update_date) lud_ar1
      from PSB_ALLOCRULE_ASSIGNMENTS_V
     where allocrule_set_id = p_allocrule_set_id;

  cursor c_ar2 is
    select Count(*) count_ar2,
	   Max(last_update_date) lud_ar2
      from PSB_SET_RELATIONS
     where allocation_rule_id in
	  (select allocrule_id
	     from PSB_ALLOCRULE_ASSIGNMENTS_V
	    where allocrule_set_id = p_allocrule_set_id);

  cursor c_bc is
    select Count(*) count_bc,
	   Max(last_update_date) lud_bc
      from PSB_BUDGET_PERIODS
     where budget_period_type = 'Y'
       and budget_calendar_id = p_budget_calendar_id;

  cursor c_bg1 is
    select Count(*) count_bg1,
	   Max(last_update_date) lud_bg1
      from PSB_BUDGET_GROUPS
     where budget_group_type = 'R'
       and effective_start_date <= PSB_WS_ACCT1.g_startdate_pp
       and (effective_end_date is null or effective_end_date >= PSB_WS_ACCT1.g_enddate_cy)
     start with budget_group_id = p_budget_group_id
   connect by prior budget_group_id = parent_budget_group_id;

  cursor c_bg2 is
    select Count(*) count_bg2,
	   Max(last_update_date) lud_bg2
      from PSB_SET_RELATIONS
     where budget_group_id in
	  (select budget_group_id
	     from PSB_BUDGET_GROUPS
	    where budget_group_type = 'R'
	      and effective_start_date <= PSB_WS_ACCT1.g_startdate_pp
	      and (effective_end_date is null or effective_end_date >= PSB_WS_ACCT1.g_enddate_cy)
	    start with budget_group_id = p_budget_group_id
	  connect by prior budget_group_id = parent_budget_group_id);

  cursor c_de is
    select last_extract_date lud_de
      from PSB_DATA_EXTRACTS
     where data_extract_id = p_data_extract_id;

  cursor c_assign is
    select count(*) count_assign,
	   Max(last_update_date) lud_assign
      from PSB_POSITION_ASSIGNMENTS
     where data_extract_id = p_data_extract_id;

  cursor c_rates is
    select count(*) count_rates,
	   Max(last_update_date) lud_rates
      from PSB_PAY_ELEMENT_RATES
     where pay_element_id in
	  (select pay_element_id
	     from PSB_PAY_ELEMENTS
	    where data_extract_id = p_data_extract_id);

  cursor c_dist is
    select count(*) count_dist,
	   Max(last_update_date) lud_dist
      from PSB_POSITION_PAY_DISTRIBUTIONS
     where data_extract_id = p_data_extract_id;

BEGIN

  if p_gl_budget_set_id is not null then
  begin

    for c_glset1_rec in c_glset1 loop
      l_count_glset1 := c_glset1_rec.count_glset1;
      l_lud_glset1 := c_glset1_rec.lud_glset1;
    end loop;

    for c_glset2_rec in c_glset2 loop
      l_count_glset2 := c_glset2_rec.count_glset2;
      l_lud_glset2 := c_glset2_rec.lud_glset2;
    end loop;

  end;
  end if;

  if p_parameter_set_id is not null then
  begin

    for c_ps1_rec in c_ps1 loop
      l_count_ps1 := c_ps1_rec.count_ps1;
      l_lud_ps1 := c_ps1_rec.lud_ps1;
    end loop;

    for c_ps2_rec in c_ps2 loop
      l_count_ps2 := c_ps2_rec.count_ps2;
      l_lud_ps2 := c_ps2_rec.lud_ps2;
    end loop;

  end;
  end if;

  if p_constraint_set_id is not null then
  begin

    for c_cs1_rec in c_cs1 loop
      l_count_cs1 := c_cs1_rec.count_cs1;
      l_lud_cs1 := c_cs1_rec.lud_cs1;
    end loop;

    for c_cs2_rec in c_cs2 loop
      l_count_cs2 := c_cs2_rec.count_cs2;
      l_lud_cs2 := c_cs2_rec.lud_cs2;
    end loop;

  end;
  end if;

  if p_allocrule_set_id is not null then
  begin

    for c_ar1_rec in c_ar1 loop
      l_count_ar1 := c_ar1_rec.count_ar1;
      l_lud_ar1 := c_ar1_rec.lud_ar1;
    end loop;

    for c_ar2_rec in c_ar2 loop
      l_count_ar2 := c_ar2_rec.count_ar2;
      l_lud_ar2 := c_ar2_rec.lud_ar2;
    end loop;

  end;
  end if;

  if p_data_extract_id is not null then
  begin

    for c_de_rec in c_de loop
      l_lud_de := c_de_rec.lud_de;
    end loop;

    for c_assign_rec in c_assign loop
      l_count_assign := c_assign_rec.count_assign;
      l_lud_assign := c_assign_rec.lud_assign;
    end loop;

    for c_rates_rec in c_rates loop
      l_count_rates := c_rates_rec.count_rates;
      l_lud_rates := c_rates_rec.lud_rates;
    end loop;

    for c_dist_rec in c_dist loop
      l_count_dist := c_dist_rec.count_dist;
      l_lud_dist := c_dist_rec.lud_dist;
    end loop;

  end;
  end if;

  for c_bc_rec in c_bc loop
    l_count_bc := c_bc_rec.count_bc;
    l_lud_bc := c_bc_rec.lud_bc;
  end loop;

  for c_bg1_rec in c_bg1 loop
    l_count_bg1 := c_bg1_rec.count_bg1;
    l_lud_bg1 := c_bg1_rec.lud_bg1;
  end loop;

  for c_bg2_rec in c_bg2 loop
    l_count_bg2 := c_bg2_rec.count_bg2;
    l_lud_bg2 := c_bg2_rec.lud_bg2;
  end loop;

  for c_Reent_Status_Rec in c_Reent_Status loop

    l_rec_found := FND_API.G_TRUE;

    if ((nvl(c_Reent_Status_Rec.count_ps1, FND_API.G_MISS_NUM) <> nvl(l_count_ps1, FND_API.G_MISS_NUM)) or
	(nvl(c_Reent_Status_Rec.lud_ps1, FND_API.G_MISS_DATE) <> nvl(l_lud_ps1, FND_API.G_MISS_DATE)) or
	(nvl(c_Reent_Status_Rec.count_ps2, FND_API.G_MISS_NUM) <> nvl(l_count_ps2, FND_API.G_MISS_NUM)) or
	(nvl(c_Reent_Status_Rec.lud_ps2, FND_API.G_MISS_DATE) <> nvl(l_lud_ps2, FND_API.G_MISS_DATE)) or
	(nvl(c_Reent_Status_Rec.count_glset1, FND_API.G_MISS_NUM) <> nvl(l_count_glset1, FND_API.G_MISS_NUM)) or
	(nvl(c_Reent_Status_Rec.lud_glset1, FND_API.G_MISS_DATE) <> nvl(l_lud_glset1, FND_API.G_MISS_DATE)) or
	(nvl(c_Reent_Status_Rec.count_glset2, FND_API.G_MISS_NUM) <> nvl(l_count_glset2, FND_API.G_MISS_NUM)) or
	(nvl(c_Reent_Status_Rec.lud_glset2, FND_API.G_MISS_DATE) <> nvl(l_lud_glset2, FND_API.G_MISS_DATE)) or
	(nvl(c_Reent_Status_Rec.count_ar1, FND_API.G_MISS_NUM) <> nvl(l_count_ar1, FND_API.G_MISS_NUM)) or
	(nvl(c_Reent_Status_Rec.lud_ar1, FND_API.G_MISS_DATE) <> nvl(l_lud_ar1, FND_API.G_MISS_DATE)) or
	(nvl(c_Reent_Status_Rec.count_ar2, FND_API.G_MISS_NUM) <> nvl(l_count_ar2, FND_API.G_MISS_NUM)) or
	(nvl(c_Reent_Status_Rec.lud_ar2, FND_API.G_MISS_DATE) <> nvl(l_lud_ar2, FND_API.G_MISS_DATE)) or
	(nvl(c_Reent_Status_Rec.count_bc, FND_API.G_MISS_NUM) <> nvl(l_count_bc, FND_API.G_MISS_NUM)) or
	(nvl(c_Reent_Status_Rec.lud_bc, FND_API.G_MISS_DATE) <> nvl(l_lud_bc, FND_API.G_MISS_DATE)) or
	(nvl(c_Reent_Status_Rec.count_bg1, FND_API.G_MISS_NUM) <> nvl(l_count_bg1, FND_API.G_MISS_NUM)) or
	(nvl(c_Reent_Status_Rec.lud_bg1, FND_API.G_MISS_DATE) <> nvl(l_lud_bg1, FND_API.G_MISS_DATE)) or
	(nvl(c_Reent_Status_Rec.count_bg2, FND_API.G_MISS_NUM) <> nvl(l_count_bg2, FND_API.G_MISS_NUM)) or
	(nvl(c_Reent_Status_Rec.lud_bg2, FND_API.G_MISS_DATE) <> nvl(l_lud_bg2, FND_API.G_MISS_DATE)) OR

        /* Bug 3525832 Start */
        (nvl(c_Reent_Status_Rec.gcd_ws, FND_API.G_MISS_DATE) <> nvl(g_gl_cutoff_period, FND_API.G_MISS_DATE))) THEN
        /* Bug 3525832 End */

    begin
      g_sp1_status := 'I';
      g_sp2_status := 'I';
      g_sp3_status := 'I';
      g_sp4_status := 'I';
      l_restart := FND_API.G_FALSE;
    end;
    else
    begin

      if ((nvl(c_Reent_Status_Rec.lud_de, FND_API.G_MISS_DATE) <> nvl(l_lud_de, FND_API.G_MISS_DATE)) or
	  (nvl(c_Reent_Status_Rec.count_assign, FND_API.G_MISS_NUM) <> nvl(l_count_assign, FND_API.G_MISS_NUM)) or
	  (nvl(c_Reent_Status_Rec.lud_assign, FND_API.G_MISS_DATE) <> nvl(l_lud_assign, FND_API.G_MISS_DATE)) or
	  (nvl(c_Reent_Status_Rec.count_rates, FND_API.G_MISS_NUM) <> nvl(l_count_rates, FND_API.G_MISS_NUM)) or
	  (nvl(c_Reent_Status_Rec.lud_rates, FND_API.G_MISS_DATE) <> nvl(l_lud_rates, FND_API.G_MISS_DATE)) or
	  (nvl(c_Reent_Status_Rec.count_dist, FND_API.G_MISS_NUM) <> nvl(l_count_dist, FND_API.G_MISS_NUM)) or
	  (nvl(c_Reent_Status_Rec.lud_dist, FND_API.G_MISS_DATE) <> nvl(l_lud_dist, FND_API.G_MISS_DATE))) then
      begin
	g_sp1_status := c_Reent_Status_Rec.sp1_status;
	g_sp2_status := 'I';
	g_sp3_status := 'I';
	g_sp4_status := 'I';
      end;
      elsif ((nvl(c_Reent_Status_Rec.count_cs1, FND_API.G_MISS_NUM) <> nvl(l_count_cs1, FND_API.G_MISS_NUM)) or
	     (nvl(c_Reent_Status_Rec.lud_cs1, FND_API.G_MISS_DATE) <> nvl(l_lud_cs1, FND_API.G_MISS_DATE)) or
	     (nvl(c_Reent_Status_Rec.count_cs2, FND_API.G_MISS_NUM) <> nvl(l_count_cs2, FND_API.G_MISS_NUM)) or
	     (nvl(c_Reent_Status_Rec.lud_cs2, FND_API.G_MISS_DATE) <> nvl(l_lud_cs2, FND_API.G_MISS_DATE))) then
      begin
	g_sp1_status := c_Reent_status_rec.sp1_status;
	g_sp2_status := c_Reent_status_rec.sp2_status;
	g_sp3_status := c_Reent_status_rec.sp3_status;
	g_sp4_status := 'I';
      end;
      else
      begin
	g_sp1_status := c_Reent_status_rec.sp1_status;
	g_sp2_status := c_Reent_status_rec.sp2_status;
	g_sp3_status := c_Reent_status_rec.sp3_status;
	g_sp4_status := c_Reent_status_rec.sp4_status;
      end;
      end if;

      l_restart := FND_API.G_TRUE;

    end;
    end if;

  end loop;

  if not FND_API.to_Boolean(l_rec_found) then
  begin

    insert into PSB_REENTRANT_PROCESS_STATUS
	  (process_type, process_uid,
	   attribute1, attribute2,
	   attribute3, attribute4,
	   attribute5, attribute6,
	   attribute7, attribute8,
	   attribute9, attribute10,
	   attribute11, attribute12,
	   attribute13, attribute14,
	   attribute15, attribute16,
	   attribute17, attribute18,
	   attribute19, attribute20,
	   attribute21, attribute22,
	   attribute23, attribute24,
	   attribute25, attribute26,
	   attribute27, attribute28,
	   attribute29, attribute30,
	   sp1_status, sp2_status,
	   sp3_status, sp4_status,
	   sp5_status, sp6_status,
	   sp7_status, sp8_status,
	   sp9_status, sp10_status,
	   sp11_status, sp12_status,
	   sp13_status, sp14_status,
	   sp15_status, sp16_status,
	   sp17_status, sp18_status,
	   sp19_status, sp20_status,
	   sp21_status, sp22_status,
	   sp23_status, sp24_status,
	   sp25_status, sp26_status,
	   sp27_status, sp28_status,
	   sp29_status, sp30_status)
  values ('WORKSHEET_CREATION', p_worksheet_id,
	   to_char(l_count_ps1), to_char(l_lud_ps1, 'YYYY/MM/DD HH24:MI:SS'),
	   to_char(l_count_ps2), to_char(l_lud_ps2, 'YYYY/MM/DD HH24:MI:SS'),
	   to_char(l_count_cs1), to_char(l_lud_cs1, 'YYYY/MM/DD HH24:MI:SS'),
	   to_char(l_count_cs2), to_char(l_lud_cs2, 'YYYY/MM/DD HH24:MI:SS'),
	   to_char(l_count_ar1), to_char(l_lud_ar1, 'YYYY/MM/DD HH24:MI:SS'),
	   to_char(l_count_ar2), to_char(l_lud_ar2, 'YYYY/MM/DD HH24:MI:SS'),
	   to_char(l_count_bc), to_char(l_lud_bc, 'YYYY/MM/DD HH24:MI:SS'),
	   to_char(l_count_bg1), to_char(l_lud_bg1, 'YYYY/MM/DD HH24:MI:SS'),
	   to_char(l_count_bg2), to_char(l_lud_bg2, 'YYYY/MM/DD HH24:MI:SS'),
	   to_char(l_lud_de, 'YYYY/MM/DD HH24:MI:SS'),
	   to_char(l_count_assign), to_char(l_lud_assign, 'YYYY/MM/DD HH24:MI:SS'),
	   to_char(l_count_rates), to_char(l_lud_rates, 'YYYY/MM/DD HH24:MI:SS'),
	   to_char(l_count_dist), to_char(l_lud_dist, 'YYYY/MM/DD HH24:MI:SS'),
	   to_char(l_count_glset1), to_char(l_lud_glset1, 'YYYY/MM/DD HH24:MI:SS'),
	   to_char(l_count_glset2), to_char(l_lud_glset2, 'YYYY/MM/DD HH24:MI:SS'),

           /* Bug 3525832 Start */
	   TO_CHAR(g_gl_cutoff_period, 'YYYY/MM/DD HH24:MI:SS'),
           /* Bug 3525832 End */

	   'I', 'I',
	   'I', 'I',
	   null, null,
	   null, null,
	   null, null,
	   null, null,
	   null, null,
	   null, null,
	   null, null,
	   null, null,
	   null, null,
	   null, null,
	   null, null,
	   null, null,
	   null, null);

    g_sp1_status := 'I';
    g_sp2_status := 'I';
    g_sp3_status := 'I';
    g_sp4_status := 'I';

    l_restart := FND_API.G_FALSE;
    /*start bug#8304054*/
    EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN

     g_sp1_status := 'I';
     g_sp2_status := 'I';
     g_sp3_status := 'I';
     g_sp4_status := 'I';
    /*end bug#8304054*/

  end;
  end if;

  if FND_API.to_Boolean(l_restart) then
  begin

    update PSB_REENTRANT_PROCESS_STATUS
       set sp1_status = g_sp1_status,
	   sp2_status = g_sp2_status,
	   sp3_status = g_sp3_status,
	   sp4_status = g_sp4_status
     where process_type = 'WORKSHEET_CREATION'
       and process_uid = p_worksheet_id;

  end;
  else
  begin

    update PSB_REENTRANT_PROCESS_STATUS
       set attribute1 = to_char(l_count_ps1),
	   attribute2 = to_char(l_lud_ps1, 'YYYY/MM/DD HH24:MI:SS'),
	   attribute3 = to_char(l_count_ps2),
	   attribute4 = to_char(l_lud_ps2, 'YYYY/MM/DD HH24:MI:SS'),
	   attribute5 = to_char(l_count_cs1),
	   attribute6 = to_char(l_lud_cs1, 'YYYY/MM/DD HH24:MI:SS'),
	   attribute7 = to_char(l_count_cs2),
	   attribute8 = to_char(l_lud_cs2, 'YYYY/MM/DD HH24:MI:SS'),
	   attribute9 = to_char(l_count_ar1),
	   attribute10 = to_char(l_lud_ar1, 'YYYY/MM/DD HH24:MI:SS'),
	   attribute11 = to_char(l_count_ar2),
	   attribute12 = to_char(l_lud_ar2, 'YYYY/MM/DD HH24:MI:SS'),
	   attribute13 = to_char(l_count_bc),
	   attribute14 = to_char(l_lud_bc, 'YYYY/MM/DD HH24:MI:SS'),
	   attribute15 = to_char(l_count_bg1),
	   attribute16 = to_char(l_lud_bg1, 'YYYY/MM/DD HH24:MI:SS'),
	   attribute17 = to_char(l_count_bg2),
	   attribute18 = to_char(l_lud_bg2, 'YYYY/MM/DD HH24:MI:SS'),
	   attribute19 = to_char(l_lud_de, 'YYYY/MM/DD HH24:MI:SS'),
	   attribute20 = to_char(l_count_assign),
	   attribute21 = to_char(l_lud_assign, 'YYYY/MM/DD HH24:MI:SS'),
	   attribute22 = to_char(l_count_rates),
	   attribute23 = to_char(l_lud_rates, 'YYYY/MM/DD HH24:MI:SS'),
	   attribute24 = to_char(l_count_dist),
	   attribute25 = to_char(l_lud_dist, 'YYYY/MM/DD HH24:MI:SS'),
	   attribute26 = to_char(l_count_glset1),
	   attribute27 = to_char(l_lud_glset1, 'YYYY/MM/DD HH24:MI:SS'),
	   attribute28 = to_char(l_count_glset2),
	   attribute29 = to_char(l_lud_glset2, 'YYYY/MM/DD HH24:MI:SS'),

           /* Bug 3525832 Start */
           attribute30 = TO_CHAR(g_gl_cutoff_period, 'YYYY/MM/DD HH24:MI:SS'),
           /* Bug 3525832 End */

	   sp1_status = g_sp1_status,
	   sp2_status = g_sp2_status,
	   sp3_status = g_sp3_status,
	   sp4_status = g_sp4_status
     where process_type = 'WORKSHEET_CREATION'
       and process_uid = p_worksheet_id;

  end;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Check_Reentrant_Status;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_WS_Line_Items
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'Create_WS_Line_Items';
  l_api_version        CONSTANT NUMBER         := 1.0;

  l_validation_status  VARCHAR2(1);
  l_return_status      VARCHAR2(1);

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  PSB_WORKSHEET.Update_Worksheet
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_worksheet_id => p_worksheet_id,
      p_ws_creation_complete => 'N');

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  Initialize (p_worksheet_id => p_worksheet_id,
	      p_return_status => l_return_status);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  /*For Bug No : 2260391 Start*/
  /*if g_current_stage_seq <> g_start_stage_seq then
    add_message('PSB', 'PSB_CANNOT_RECREATE_WORKSHEET');
    raise FND_API.G_EXC_ERROR;
  end if;*/
  /*For Bug No : 2260391 End*/

  if g_budget_calendar_id <> nvl(PSB_WS_ACCT1.g_budget_calendar_id, FND_API.G_MISS_NUM) then
  begin

    PSB_WS_ACCT1.Cache_Budget_Calendar
       (p_return_status => l_return_status,
	p_budget_calendar_id => g_budget_calendar_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  PSB_WS_POS1.g_budget_calendar_id := g_budget_calendar_id;
  PSB_WS_POS1.g_budget_group_id := g_budget_group_id;
  PSB_WS_POS1.g_global_worksheet_id := nvl(g_global_worksheet_id, p_worksheet_id);
  PSB_WS_POS1.g_local_copy_flag := g_local_copy_flag;

  Check_Reentrant_Status
       (p_return_status => l_return_status,
	p_worksheet_id => p_worksheet_id,
	p_parameter_set_id => g_parameter_set_id,
	p_constraint_set_id => g_constraint_set_id,
	p_allocrule_set_id => g_allocrule_set_id,
	p_budget_calendar_id => g_budget_calendar_id,
	p_budget_group_id => g_budget_group_id,
	p_data_extract_id => g_data_extract_id,
	p_gl_budget_set_id => g_gl_budget_set_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'WORKSHEET_CREATION',
      p_concurrency_entity_name  => 'WORKSHEET',
      p_concurrency_entity_id    => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  if g_sp1_status = 'I' then
  begin

    PSB_WS_ACCT2.Create_Worksheet_Accounts
       (p_return_status => l_return_status,
	p_worksheet_id => p_worksheet_id,
	p_rounding_factor => g_rounding_factor,
	p_stage_set_id => g_stage_set_id,
	p_service_package_id => g_service_package_id,
	p_start_stage_seq => g_start_stage_seq,
	p_allocrule_set_id => g_allocrule_set_id,
	p_budget_group_id => g_budget_group_id,
	p_flex_code => g_flex_code,
	p_parameter_set_id => g_parameter_set_id,
	p_budget_calendar_id => g_budget_calendar_id,
	p_gl_cutoff_period => g_gl_cutoff_period,
	p_include_gl_commit_balance => g_include_gl_commit_balance,
	p_include_gl_oblig_balance => g_include_gl_oblig_balance,
	p_include_gl_other_balance => g_include_gl_other_balance,
	p_budget_version_id => g_budget_version_id,
	p_flex_mapping_set_id => g_flex_mapping_set_id,
	p_gl_budget_set_id => g_gl_budget_set_id,
	p_set_of_books_id => g_set_of_books_id,
	p_set_of_books_name => g_set_of_books_name,
	p_func_currency => g_currency_code,
	p_budgetary_control => g_budgetary_control,
	p_incl_stat_bal => g_incl_stat_bal,
	p_incl_trans_bal => g_incl_trans_bal,
	p_incl_adj_period => g_incl_adj_period,
	p_num_proposed_years => g_num_proposed_years,
	p_num_years_to_allocate => g_num_years_to_allocate,
	p_budget_by_position => g_budget_by_position,
        /* Bug No 4725091 */
        P_incl_gl_fwd_balance => g_include_gl_forward_balance);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    update PSB_REENTRANT_PROCESS_STATUS
       set sp1_status = 'C'
     where process_type = 'WORKSHEET_CREATION'
       and process_uid = p_worksheet_id;

    commit work;

  end;
  end if;

  g_dbug := g_dbug || g_chr10 ||
	   'Create_WS_Line_Items: After Phase 1';

  if FND_API.to_Boolean(g_budget_by_position) then
  begin

    if g_sp2_status = 'I' then
    begin

      PSB_WS_POS2.Create_Worksheet_Positions
	 (p_return_status => l_return_status,
	  p_root_budget_group_id => g_root_budget_group_id,
	  p_global_worksheet_id => g_global_worksheet_id,
	  p_worksheet_id => p_worksheet_id,
	  p_global_worksheet => g_global_worksheet,
	  p_budget_group_id => g_budget_group_id,
	  p_worksheet_numyrs => g_num_proposed_years,
	  p_rounding_factor => g_rounding_factor,
	  p_service_package_id => g_service_package_id,
	  p_stage_set_id => g_stage_set_id,
	  p_start_stage_seq => g_start_stage_seq,
	  p_current_stage_seq => g_current_stage_seq,
	  p_data_extract_id => g_data_extract_id,
	  p_business_group_id => g_business_group_id,
	  p_budget_calendar_id => g_budget_calendar_id,
	  p_parameter_set_id => g_parameter_set_id,
	  p_func_currency => g_currency_code,
	  p_flex_mapping_set_id => g_flex_mapping_set_id,
	  p_flex_code => g_flex_code,
	  p_apply_element_parameters => g_apply_element_parameters,
	  p_apply_position_parameters => g_apply_position_parameters);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      update PSB_REENTRANT_PROCESS_STATUS
	 set sp2_status = 'C'
       where process_type = 'WORKSHEET_CREATION'
	 and process_uid = p_worksheet_id;

      commit work;

    end;
    end if;

  end;
  end if;

  g_dbug := g_dbug || g_chr10 ||
	   'Create_WS_Line_Items: After Phase 2';

  if g_sp3_status = 'I' then
  begin

    PSB_WS_ACCT2.Create_Rollup_Totals
       (p_api_version => 1.0,
	p_worksheet_id => p_worksheet_id,
	p_rounding_factor => g_rounding_factor,
	p_stage_set_id => g_stage_set_id,
	p_current_stage_seq => g_current_stage_seq,
	p_set_of_books_id => g_set_of_books_id,
	p_flex_code => g_flex_code,
	p_budget_group_id => g_budget_group_id,
	p_budget_calendar_id => g_budget_calendar_id,
	p_return_status => l_return_status);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    update PSB_REENTRANT_PROCESS_STATUS
       set sp3_status = 'C'
     where process_type = 'WORKSHEET_CREATION'
       and process_uid = p_worksheet_id;

    commit work;

  end;
  end if;

  g_dbug := g_dbug || g_chr10 ||
	   'Create_WS_Line_Items: After Phase 3';

  if nvl(g_constraint_set_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
  begin

    if g_sp4_status = 'I' then
    begin

      Apply_Constraints
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_validation_status => l_validation_status,
	    p_worksheet_id => p_worksheet_id,
	    p_budget_group_id => g_budget_group_id,
	    p_flex_code => g_flex_code,
	    p_func_currency => g_currency_code,
	    p_global_worksheet_id => nvl(g_global_worksheet_id, p_worksheet_id),
	    p_constraint_set_id => g_constraint_set_id,
	    p_constraint_set_name => g_cs_name,
	    p_constraint_set_threshold => g_cs_threshold,
	    p_budget_calendar_id => g_budget_calendar_id,
	    p_data_extract_id => g_data_extract_id,
	    p_business_group_id => g_business_group_id,
	    p_budget_by_position => g_budget_by_position);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      update PSB_REENTRANT_PROCESS_STATUS
	 set sp4_status = 'C'
       where process_type = 'WORKSHEET_CREATION'
	 and process_uid = p_worksheet_id;

    end;
    end if;

  end;
  end if;

  PSB_WORKSHEET.Update_Worksheet
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_worksheet_id => p_worksheet_id,
      p_ws_creation_complete => 'Y');

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  commit work;

  PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'WORKSHEET_CREATION',
      p_concurrency_entity_name  => 'WORKSHEET',
      p_concurrency_entity_id    => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
  end if;

  g_dbug := g_dbug || g_chr10 ||
	   'Create_WS_Line_Items: After Phase 4';

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);

     end if;

END Create_WS_Line_Items;

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Constraints
( p_api_version               IN   NUMBER,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_validation_status         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id              IN   NUMBER,
  p_budget_group_id           IN   NUMBER := FND_API.G_MISS_NUM,
  p_flex_code                 IN   NUMBER := FND_API.G_MISS_NUM,
  p_func_currency             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_global_worksheet_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_constraint_set_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_constraint_set_name       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_constraint_set_threshold  IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_calendar_id        IN   NUMBER := FND_API.G_MISS_NUM,
  p_data_extract_id           IN   NUMBER := FND_API.G_MISS_NUM,
  p_business_group_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_by_position        IN   VARCHAR2 := FND_API.G_MISS_CHAR
) IS

  l_api_name                  CONSTANT VARCHAR2(30)   := 'Apply_Constraints';
  l_api_version               CONSTANT NUMBER         := 1.0;

  l_budget_group_id           NUMBER;
  l_global_worksheet_id       NUMBER;
  l_constraint_set_id         NUMBER;
  l_budget_calendar_id        NUMBER;
  l_data_extract_id           NUMBER;
  l_business_group_id         NUMBER;
  l_budget_by_position        VARCHAR2(1);

  l_flex_code                 NUMBER;
  l_func_currency             VARCHAR2(10);

  l_cs_name                   VARCHAR2(30);
  l_cs_threshold              NUMBER;

  l_constraint_set_status     VARCHAR2(1) := 'S';
  l_validation_status         VARCHAR2(1);

  l_return_status             VARCHAR2(1);
  l_msg_data                  VARCHAR2(2000);
  l_msg_count                 NUMBER;

  cursor c_WS is
    select budget_group_id,
	   nvl(global_worksheet_id, worksheet_id) global_worksheet_id,
	   nvl(constraint_set_id, global_constraint_set_id) constraint_set_id,
	   budget_calendar_id,
	   nvl(data_extract_id, global_data_extract_id) data_extract_id,
	   budget_by_position
      from PSB_WORKSHEETS_V
     where worksheet_id = p_worksheet_id;

  cursor c_BG is
    select nvl(chart_of_accounts_id, root_chart_of_accounts_id) chart_of_accounts_id,
	   nvl(currency_code, root_currency_code) currency_code,
	   nvl(business_group_id, root_business_group_id) business_group_id
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = l_budget_group_id;

  cursor c_ConstSet is
    select name,
	   constraint_threshold
      from PSB_CONSTRAINT_SETS_V
     where constraint_set_id = l_constraint_set_id;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if ((p_budget_group_id = FND_API.G_MISS_NUM) or
      (p_global_worksheet_id = FND_API.G_MISS_NUM) or
      (p_constraint_set_id = FND_API.G_MISS_NUM) or
      (p_budget_calendar_id = FND_API.G_MISS_NUM) or
      (p_data_extract_id = FND_API.G_MISS_NUM) or
      (p_budget_by_position = FND_API.G_MISS_CHAR)) then
  begin

    for c_WS_Rec in c_WS loop
      l_budget_group_id := c_WS_Rec.budget_group_id;
      l_global_worksheet_id := c_WS_Rec.global_worksheet_id;
      l_constraint_set_id := c_WS_Rec.constraint_set_id;
      l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
      l_data_extract_id := c_WS_Rec.data_extract_id;
      l_budget_by_position := c_WS_Rec.budget_by_position;
    end loop;

  end;
  end if;

  if p_budget_group_id <> FND_API.G_MISS_NUM then
    l_budget_group_id := p_budget_group_id;
  end if;

  if p_global_worksheet_id <> FND_API.G_MISS_NUM then
    l_global_worksheet_id := p_global_worksheet_id;
  end if;

  if p_constraint_set_id <> FND_API.G_MISS_NUM then
    l_constraint_set_id := p_constraint_set_id;
  end if;

  if p_budget_calendar_id <> FND_API.G_MISS_NUM then
    l_budget_calendar_id := p_budget_calendar_id;
  end if;

  if p_data_extract_id <> FND_API.G_MISS_NUM then
    l_data_extract_id := p_data_extract_id;
  end if;

  if ((p_flex_code = FND_API.G_MISS_NUM) or
      (p_func_currency = FND_API.G_MISS_CHAR) or
      (p_business_group_id = FND_API.G_MISS_NUM)) then
  begin

    for c_BG_Rec in c_BG loop
      l_flex_code := c_BG_Rec.chart_of_accounts_id;
      l_func_currency := c_BG_Rec.currency_code;
      l_business_group_id := c_BG_Rec.business_group_id;
    end loop;

  end;
  end if;

  if p_flex_code <> FND_API.G_MISS_NUM then
    l_flex_code := p_flex_code;
  end if;

  if p_func_currency <> FND_API.G_MISS_CHAR then
    l_func_currency := p_func_currency;
  end if;

  if p_business_group_id <> FND_API.G_MISS_NUM then
    l_business_group_id := p_business_group_id;
  end if;

  if ((l_budget_by_position is null) or (l_budget_by_position = 'N')) then
    l_budget_by_position := FND_API.G_FALSE;
  else
    l_budget_by_position := FND_API.G_TRUE;
  end if;

  if p_budget_by_position <> FND_API.G_MISS_CHAR then
    l_budget_by_position := p_budget_by_position;
  end if;

  if ((p_constraint_set_name = FND_API.G_MISS_CHAR) or
      (p_constraint_set_threshold = FND_API.G_MISS_NUM)) then
  begin

    for c_ConstSet_Rec in c_ConstSet loop
      l_cs_name := c_ConstSet_Rec.name;
      l_cs_threshold := c_ConstSet_Rec.constraint_threshold;
    end loop;

  end;
  end if;

  if p_constraint_set_name <> FND_API.G_MISS_CHAR then
    l_cs_name := p_constraint_set_name;
  end if;

  if p_constraint_set_threshold <> FND_API.G_MISS_NUM then
    l_cs_threshold := p_constraint_set_threshold;
  end if;

  if nvl(l_constraint_set_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
  begin

    delete from PSB_ERROR_MESSAGES
     where source_process = 'WORKSHEET_CREATION'
       and process_id = p_worksheet_id;

    if l_budget_calendar_id <> nvl(PSB_WS_ACCT1.g_budget_calendar_id, FND_API.G_MISS_NUM) then
    begin

      PSB_WS_ACCT1.Cache_Budget_Calendar
	 (p_return_status => l_return_status,
	  p_budget_calendar_id => l_budget_calendar_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

    PSB_WS_ACCT1.Apply_Account_Constraints
       (p_return_status => l_return_status,
	p_validation_status => l_validation_status,
	p_worksheet_id => p_worksheet_id,
	p_flex_mapping_set_id => g_flex_mapping_set_id,
	p_budget_group_id => l_budget_group_id,
	p_flex_code => l_flex_code,
	p_func_currency => l_func_currency,
	p_constraint_set_id => l_constraint_set_id,
	p_constraint_set_name => l_cs_name,
	p_constraint_threshold => l_cs_threshold,
	p_budget_calendar_id => l_budget_calendar_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    l_constraint_set_status := l_validation_status;

    if FND_API.to_Boolean(l_budget_by_position) then
    begin

      PSB_WS_POS3.Apply_Position_Constraints
	 (p_return_status => l_return_status,
	  p_validation_status => l_validation_status,
	  p_worksheet_id => p_worksheet_id,
	  p_budget_calendar_id => l_budget_calendar_id,
	  p_data_extract_id => l_data_extract_id,
	  p_business_group_id => l_business_group_id,
	  p_func_currency => l_func_currency,
	  p_constraint_set_id => l_constraint_set_id,
	  p_constraint_set_name => l_cs_name,
	  p_constraint_threshold => l_cs_threshold);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      if ((l_constraint_set_status = 'S') and
	  (l_validation_status <> 'S')) then
	l_constraint_set_status := l_validation_status;
      elsif ((l_constraint_set_status = 'E') and
	     (l_validation_status = 'F')) then
	l_constraint_set_status := l_validation_status;
      elsif ((l_constraint_set_status = 'W') and
	     (l_validation_status in ('F', 'E'))) then
	l_constraint_set_status := l_validation_status;
      end if;

      PSB_WS_POS3.Apply_Element_Constraints
	 (p_return_status => l_return_status,
	  p_worksheet_id => l_global_worksheet_id,
	  p_budget_calendar_id => l_budget_calendar_id,
	  p_data_extract_id => l_data_extract_id,
	  p_constraint_set_id => l_constraint_set_id,
	  p_constraint_set_name => l_cs_name,
	  p_constraint_threshold => l_cs_threshold);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  end;
  end if;


  -- Initialize API return status to success

  p_validation_status := l_constraint_set_status;
  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);


   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);

END Apply_Constraints;

/* ----------------------------------------------------------------------- */

PROCEDURE Validate_Entity_Set
( p_api_version        IN   NUMBER,
  p_validation_level   IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status      OUT  NOCOPY  VARCHAR2,
  p_data_extract_id    IN   NUMBER,
  p_parameter_set_id   IN   NUMBER,
  p_constraint_set_id  IN   NUMBER
) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'Validate_Entity_Set';
  l_api_version        CONSTANT NUMBER         := 1.0;

  l_exists             VARCHAR2(1);

  cursor c_ParamSet is
    select 'Exists'
      from PSB_ENTITY_SET
     where (p_data_extract_id is null or data_extract_id = p_data_extract_id)
       and entity_set_id = p_parameter_set_id;

  cursor c_ConsSet is
    select 'Exists'
      from PSB_ENTITY_SET
     where (p_data_extract_id is null or data_extract_id = p_data_extract_id)
       and entity_set_id = p_constraint_set_id;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  l_exists := FND_API.G_FALSE;

  if p_parameter_set_id is not null then
  begin

    for c_ParamSet_Rec in c_ParamSet loop
      l_exists := FND_API.G_TRUE;
    end loop;

    if not FND_API.to_Boolean(l_exists) then
      add_message('PSB', 'PSB_INVALID_PARAMETER_SET');
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  l_exists := FND_API.G_FALSE;

  if p_constraint_set_id is not null then
  begin

    for c_ConsSet_Rec in c_ConsSet loop
      l_exists := FND_API.G_TRUE;
    end loop;

    if not FND_API.to_Boolean(l_exists) then
      add_message('PSB', 'PSB_INVALID_CONSTRAINT_SET');
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);

     end if;

END Validate_Entity_Set;

/* ----------------------------------------------------------------------- */

PROCEDURE Pre_Create_Line_Items
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Pre_Create_Line_Items';
  l_api_version       CONSTANT NUMBER         := 1.0;

  l_return_status     VARCHAR2(1);

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  Initialize (p_worksheet_id => p_worksheet_id,
	      p_return_status => l_return_status);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  /*For Bug No : 2260391 Start*/
  /*if g_current_stage_seq <> g_start_stage_seq then
    add_message('PSB', 'PSB_CANNOT_RECREATE_WORKSHEET');
    raise FND_API.G_EXC_ERROR;
  end if;*/
  /*For Bug No : 2260391 Start*/

  delete from PSB_ERROR_MESSAGES
   where source_process = 'WORKSHEET_CREATION'
     and process_id = p_worksheet_id;

  PSB_WORKSHEET.Update_Worksheet
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_worksheet_id => p_worksheet_id,
      p_ws_creation_complete => 'N');

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);

     end if;

END Pre_Create_Line_Items;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Acct_Line_Items
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'Create_Acct_Line_Items';
  l_api_version        CONSTANT NUMBER         := 1.0;

  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER ;
  l_msg_data           VARCHAR2(2000) ;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  Initialize (p_worksheet_id => p_worksheet_id,
	      p_return_status => l_return_status);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  if g_budget_calendar_id <> nvl(PSB_WS_ACCT1.g_budget_calendar_id, FND_API.G_MISS_NUM) then
  begin

    PSB_WS_ACCT1.Cache_Budget_Calendar
       (p_return_status => l_return_status,
	p_budget_calendar_id => g_budget_calendar_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  /* Bug 3543845 Start: Check whether the worksheet creation process is
     executed for the first time.
  */
  g_ws_first_time_creation_flag := TRUE;
  FOR l_ws_first_time_creation_rec IN
  (
    SELECT 1
    FROM   PSB_REENTRANT_PROCESS_STATUS
    WHERE  PROCESS_UID = p_worksheet_id AND
           PROCESS_TYPE = 'WORKSHEET_CREATION'
  )
  LOOP
    g_ws_first_time_creation_flag := FALSE;
  END LOOP;
  /* Bug 3543845 End */

  PSB_WS_POS1.g_budget_calendar_id := g_budget_calendar_id;
  PSB_WS_POS1.g_budget_group_id := g_budget_group_id;
  PSB_WS_POS1.g_global_worksheet_id := nvl(g_global_worksheet_id, p_worksheet_id);
  PSB_WS_POS1.g_local_copy_flag := g_local_copy_flag;

  Check_Reentrant_Status
       (p_return_status => l_return_status,
	p_worksheet_id => p_worksheet_id,
	p_parameter_set_id => g_parameter_set_id,
	p_constraint_set_id => g_constraint_set_id,
	p_allocrule_set_id => g_allocrule_set_id,
	p_budget_calendar_id => g_budget_calendar_id,
	p_budget_group_id => g_budget_group_id,
	p_data_extract_id => g_data_extract_id,
	p_gl_budget_set_id => g_gl_budget_set_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'WORKSHEET_CREATION',
      p_concurrency_entity_name  => 'WORKSHEET',
      p_concurrency_entity_id    => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  if g_sp1_status = 'I' then
  begin

    if ((FND_API.to_Boolean(g_include_cbc_commit_balance)) or
	(FND_API.to_Boolean(g_include_cbc_oblig_balance)) or
	(FND_API.to_Boolean(g_include_cbc_budget_balance))) then
    begin

      PSB_COMMITMENTS_PVT.Create_Commitment_Line_Items
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_worksheet_id => p_worksheet_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	message_token('WORKSHEET', p_worksheet_id);
	add_message('PSB', 'PSB_CANNOT_CREATE_COMMITMENT_W');
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    else
    begin

      PSB_WS_ACCT2.Create_Worksheet_Accounts
	 (p_return_status => l_return_status,
	  p_worksheet_id => p_worksheet_id,
	  p_rounding_factor => g_rounding_factor,
	  p_stage_set_id => g_stage_set_id,
	  p_service_package_id => g_service_package_id,
	  p_start_stage_seq => g_start_stage_seq,
	  p_allocrule_set_id => g_allocrule_set_id,
	  p_budget_group_id => g_budget_group_id,
	  p_flex_code => g_flex_code,
	  p_parameter_set_id => g_parameter_set_id,
	  p_budget_calendar_id => g_budget_calendar_id,
	  p_gl_cutoff_period => g_gl_cutoff_period,
	  p_include_gl_commit_balance => g_include_gl_commit_balance,
	  p_include_gl_oblig_balance => g_include_gl_oblig_balance,
	  p_include_gl_other_balance => g_include_gl_other_balance,
	  p_budget_version_id => g_budget_version_id,
	  p_flex_mapping_set_id => g_flex_mapping_set_id,
	  p_gl_budget_set_id => g_gl_budget_set_id,
	  p_set_of_books_id => g_set_of_books_id,
	  p_set_of_books_name => g_set_of_books_name,
	  p_func_currency => g_currency_code,
	  p_budgetary_control => g_budgetary_control,
	  p_incl_stat_bal => g_incl_stat_bal,
	  p_incl_trans_bal => g_incl_trans_bal,
	  p_incl_adj_period => g_incl_adj_period,
	  p_num_proposed_years => g_num_proposed_years,
	  p_num_years_to_allocate => g_num_years_to_allocate,
	  p_budget_by_position => g_budget_by_position,
          /* bug no 4725091 */
          P_incl_gl_fwd_balance => g_include_gl_forward_balance);


      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

    update PSB_REENTRANT_PROCESS_STATUS
       set sp1_status = 'C'
     where process_type = 'WORKSHEET_CREATION'
       and process_uid = p_worksheet_id;

    commit work;

  end;
  end if;

  PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
     (p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_concurrency_class        => 'WORKSHEET_CREATION',
      p_concurrency_entity_name  => 'WORKSHEET',
      p_concurrency_entity_id    => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);

     end if;

END Create_Acct_Line_Items;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Pos_Line_Items
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'Create_Pos_Line_Items';
  l_api_version        CONSTANT NUMBER         := 1.0;

  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  Initialize (p_worksheet_id => p_worksheet_id,
	      p_return_status => l_return_status);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  if FND_API.to_Boolean(g_budget_by_position) then
  begin

    if g_budget_calendar_id <> nvl(PSB_WS_ACCT1.g_budget_calendar_id, FND_API.G_MISS_NUM) then
    begin

      PSB_WS_ACCT1.Cache_Budget_Calendar
	 (p_return_status => l_return_status,
	  p_budget_calendar_id => g_budget_calendar_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

    PSB_WS_POS1.g_budget_calendar_id := g_budget_calendar_id;
    PSB_WS_POS1.g_budget_group_id := g_budget_group_id;
    PSB_WS_POS1.g_global_worksheet_id := nvl(g_global_worksheet_id, p_worksheet_id);

    Check_Reentrant_Status
	 (p_return_status => l_return_status,
	  p_worksheet_id => p_worksheet_id,
	  p_parameter_set_id => g_parameter_set_id,
	  p_constraint_set_id => g_constraint_set_id,
	  p_allocrule_set_id => g_allocrule_set_id,
	  p_budget_calendar_id => g_budget_calendar_id,
	  p_budget_group_id => g_budget_group_id,
	  p_data_extract_id => g_data_extract_id,
	  p_gl_budget_set_id => g_gl_budget_set_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    if g_sp2_status = 'I' then
    begin

      PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
	 (p_api_version              => 1.0  ,
	  p_return_status            => l_return_status,
	  p_concurrency_class        => 'WORKSHEET_CREATION',
	  p_concurrency_entity_name  => 'WORKSHEET',
	  p_concurrency_entity_id    => p_worksheet_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
      end if;

      PSB_WS_POS2.Create_Worksheet_Positions
	 (p_return_status => l_return_status,
	  p_root_budget_group_id => g_root_budget_group_id,
	  p_global_worksheet_id => g_global_worksheet_id,
	  p_worksheet_id => p_worksheet_id,
	  p_global_worksheet => g_global_worksheet,
	  p_budget_group_id => g_budget_group_id,
	  p_worksheet_numyrs => g_num_proposed_years,
	  p_rounding_factor => g_rounding_factor,
	  p_service_package_id => g_service_package_id,
	  p_stage_set_id => g_stage_set_id,
	  p_start_stage_seq => g_start_stage_seq,
	  p_current_stage_seq => g_current_stage_seq,
	  p_data_extract_id => g_data_extract_id,
	  p_business_group_id => g_business_group_id,
	  p_budget_calendar_id => g_budget_calendar_id,
	  p_parameter_set_id => g_parameter_set_id,
	  p_func_currency => g_currency_code,
	  p_flex_mapping_set_id => g_flex_mapping_set_id,
	  p_flex_code => g_flex_code,
	  p_apply_element_parameters => g_apply_element_parameters,
	  p_apply_position_parameters => g_apply_position_parameters);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	 (p_api_version              => 1.0  ,
	  p_return_status            => l_return_status,
	  p_concurrency_class        => 'WORKSHEET_CREATION',
	  p_concurrency_entity_name  => 'WORKSHEET',
	  p_concurrency_entity_id    => p_worksheet_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
      end if;

      update PSB_REENTRANT_PROCESS_STATUS
	 set sp2_status = 'C'
       where process_type = 'WORKSHEET_CREATION'
	 and process_uid = p_worksheet_id;

      commit work;

    end;
    end if;

  end;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);

     end if;

END Create_Pos_Line_Items;

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Acct_Constraints
( p_api_version               IN   NUMBER,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_worksheet_id              IN   NUMBER
) IS

  l_api_name                  CONSTANT VARCHAR2(30)   := 'Apply_Acct_Constraints';
  l_api_version               CONSTANT NUMBER         := 1.0;

  l_budget_group_id           NUMBER;
  l_global_worksheet_id       NUMBER;
  l_constraint_set_id         NUMBER;
  l_budget_calendar_id        NUMBER;
  l_data_extract_id           NUMBER;
  l_business_group_id         NUMBER;
  l_budget_by_position        VARCHAR2(1);

  l_flex_code                 NUMBER;
  l_func_currency             VARCHAR2(10);

  l_cs_name                   VARCHAR2(30);
  l_cs_threshold              NUMBER;

  l_return_status             VARCHAR2(1);
  l_validation_status         VARCHAR2(1);

  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);

  cursor c_WS is
    select budget_group_id,
	   nvl(global_worksheet_id, worksheet_id) global_worksheet_id,
	   nvl(constraint_set_id, global_constraint_set_id) constraint_set_id,
	   budget_calendar_id,
	   nvl(data_extract_id, global_data_extract_id) data_extract_id,
	   budget_by_position
      from PSB_WORKSHEETS_V
     where worksheet_id = p_worksheet_id;

  cursor c_BG is
    select nvl(chart_of_accounts_id, root_chart_of_accounts_id) chart_of_accounts_id,
	   nvl(currency_code, root_currency_code) currency_code,
	   nvl(business_group_id, root_business_group_id) business_group_id
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = l_budget_group_id;

  cursor c_ConstSet is
    select name,
	   constraint_threshold
      from PSB_CONSTRAINT_SETS_V
     where constraint_set_id = l_constraint_set_id;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  for c_WS_Rec in c_WS loop
    l_budget_group_id := c_WS_Rec.budget_group_id;
    l_global_worksheet_id := c_WS_Rec.global_worksheet_id;
    l_constraint_set_id := c_WS_Rec.constraint_set_id;
    l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
    l_data_extract_id := c_WS_Rec.data_extract_id;
    l_budget_by_position := c_WS_Rec.budget_by_position;
  end loop;

  for c_BG_Rec in c_BG loop
    l_flex_code := c_BG_Rec.chart_of_accounts_id;
    l_func_currency := c_BG_Rec.currency_code;
    l_business_group_id := c_BG_Rec.business_group_id;
  end loop;

  for c_ConstSet_Rec in c_ConstSet loop
    l_cs_name := c_ConstSet_Rec.name;
    l_cs_threshold := c_ConstSet_Rec.constraint_threshold;
  end loop;

  Initialize (p_worksheet_id => p_worksheet_id,
	      p_return_status => l_return_status);

  if nvl(l_constraint_set_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
  begin

    if l_budget_calendar_id <> nvl(PSB_WS_ACCT1.g_budget_calendar_id, FND_API.G_MISS_NUM) then
    begin

      PSB_WS_ACCT1.Cache_Budget_Calendar
	 (p_return_status => l_return_status,
	  p_budget_calendar_id => l_budget_calendar_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

    Check_Reentrant_Status
       (p_return_status => l_return_status,
	p_worksheet_id => p_worksheet_id,
	p_parameter_set_id => g_parameter_set_id,
	p_constraint_set_id => g_constraint_set_id,
	p_allocrule_set_id => g_allocrule_set_id,
	p_budget_calendar_id => g_budget_calendar_id,
	p_budget_group_id => g_budget_group_id,
	p_data_extract_id => g_data_extract_id,
	p_gl_budget_set_id => g_gl_budget_set_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
     raise FND_API.G_EXC_ERROR;
    end if;

    PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
       (p_api_version              => 1.0  ,
	p_return_status            => l_return_status,
	p_concurrency_class        => 'WORKSHEET_CREATION',
	p_concurrency_entity_name  => 'WORKSHEET',
	p_concurrency_entity_id    => p_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
    end if;

    PSB_WS_ACCT1.Apply_Account_Constraints
       (p_return_status => l_return_status,
	p_validation_status => l_validation_status,
	p_worksheet_id => p_worksheet_id,
	p_flex_mapping_set_id => g_flex_mapping_set_id,
	p_budget_group_id => l_budget_group_id,
	p_flex_code => l_flex_code,
	p_func_currency => l_func_currency,
	p_constraint_set_id => l_constraint_set_id,
	p_constraint_set_name => l_cs_name,
	p_constraint_threshold => l_cs_threshold,
	p_budget_calendar_id => l_budget_calendar_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
       (p_api_version              => 1.0  ,
	p_return_status            => l_return_status,
	p_concurrency_class        => 'WORKSHEET_CREATION',
	p_concurrency_entity_name  => 'WORKSHEET',
	p_concurrency_entity_id    => p_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);

     end if;

END Apply_Acct_Constraints;

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Pos_Constraints
( p_api_version               IN   NUMBER,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_worksheet_id              IN   NUMBER
) IS

  l_api_name                  CONSTANT VARCHAR2(30)   := 'Apply_Pos_Constraints';
  l_api_version               CONSTANT NUMBER         := 1.0;

  l_budget_group_id           NUMBER;
  l_global_worksheet_id       NUMBER;
  l_constraint_set_id         NUMBER;
  l_budget_calendar_id        NUMBER;
  l_data_extract_id           NUMBER;
  l_business_group_id         NUMBER;
  l_budget_by_position        VARCHAR2(1);

  l_flex_code                 NUMBER;
  l_func_currency             VARCHAR2(10);

  l_cs_name                   VARCHAR2(30);
  l_cs_threshold              NUMBER;

  l_return_status             VARCHAR2(1);
  l_validation_status         VARCHAR2(1);

  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);

  cursor c_WS is
    select budget_group_id,
	   nvl(global_worksheet_id, worksheet_id) global_worksheet_id,
	   nvl(constraint_set_id, global_constraint_set_id) constraint_set_id,
	   budget_calendar_id,
	   nvl(data_extract_id, global_data_extract_id) data_extract_id,
	   budget_by_position
      from PSB_WORKSHEETS_V
     where worksheet_id = p_worksheet_id;

  cursor c_BG is
    select nvl(chart_of_accounts_id, root_chart_of_accounts_id) chart_of_accounts_id,
	   nvl(currency_code, root_currency_code) currency_code,
	   nvl(business_group_id, root_business_group_id) business_group_id
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = l_budget_group_id;

  cursor c_ConstSet is
    select name,
	   constraint_threshold
      from PSB_CONSTRAINT_SETS_V
     where constraint_set_id = l_constraint_set_id;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  for c_WS_Rec in c_WS loop
    l_budget_group_id := c_WS_Rec.budget_group_id;
    l_global_worksheet_id := c_WS_Rec.global_worksheet_id;
    l_constraint_set_id := c_WS_Rec.constraint_set_id;
    l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
    l_data_extract_id := c_WS_Rec.data_extract_id;
    l_budget_by_position := c_WS_Rec.budget_by_position;
  end loop;

  for c_BG_Rec in c_BG loop
    l_flex_code := c_BG_Rec.chart_of_accounts_id;
    l_func_currency := c_BG_Rec.currency_code;
    l_business_group_id := c_BG_Rec.business_group_id;
  end loop;

  for c_ConstSet_Rec in c_ConstSet loop
    l_cs_name := c_ConstSet_Rec.name;
    l_cs_threshold := c_ConstSet_Rec.constraint_threshold;
  end loop;

  if nvl(l_constraint_set_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
  begin

    if l_budget_calendar_id <> nvl(PSB_WS_ACCT1.g_budget_calendar_id, FND_API.G_MISS_NUM) then
    begin

      PSB_WS_ACCT1.Cache_Budget_Calendar
	 (p_return_status => l_return_status,
	  p_budget_calendar_id => l_budget_calendar_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

    if l_budget_by_position = 'Y' then
    begin

      Check_Reentrant_Status
	 (p_return_status => l_return_status,
	  p_worksheet_id => p_worksheet_id,
	  p_parameter_set_id => g_parameter_set_id,
	  p_constraint_set_id => g_constraint_set_id,
	  p_allocrule_set_id => g_allocrule_set_id,
	  p_budget_calendar_id => g_budget_calendar_id,
	  p_budget_group_id => g_budget_group_id,
	  p_data_extract_id => g_data_extract_id,
	  p_gl_budget_set_id => g_gl_budget_set_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
	 (p_api_version              => 1.0  ,
	  p_return_status            => l_return_status,
	  p_concurrency_class        => 'WORKSHEET_CREATION',
	  p_concurrency_entity_name  => 'WORKSHEET',
	  p_concurrency_entity_id    => p_worksheet_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
      end if;

      PSB_WS_POS3.Apply_Position_Constraints
	 (p_return_status => l_return_status,
	  p_validation_status => l_validation_status,
	  p_worksheet_id => p_worksheet_id,
	  p_budget_calendar_id => l_budget_calendar_id,
	  p_data_extract_id => l_data_extract_id,
	  p_business_group_id => l_business_group_id,
	  p_func_currency => l_func_currency,
	  p_constraint_set_id => l_constraint_set_id,
	  p_constraint_set_name => l_cs_name,
	  p_constraint_threshold => l_cs_threshold);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	 (p_api_version              => 1.0  ,
	  p_return_status            => l_return_status,
	  p_concurrency_class        => 'WORKSHEET_CREATION',
	  p_concurrency_entity_name  => 'WORKSHEET',
	  p_concurrency_entity_id    => p_worksheet_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  end;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);

     end if;

END Apply_Pos_Constraints;

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Elem_Constraints
( p_api_version               IN   NUMBER,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_worksheet_id              IN   NUMBER
) IS

  l_api_name                  CONSTANT VARCHAR2(30)   := 'Apply_Elem_Constraints';
  l_api_version               CONSTANT NUMBER         := 1.0;

  l_budget_group_id           NUMBER;
  l_global_worksheet_id       NUMBER;
  l_constraint_set_id         NUMBER;
  l_budget_calendar_id        NUMBER;
  l_data_extract_id           NUMBER;
  l_business_group_id         NUMBER;
  l_budget_by_position        VARCHAR2(1);

  l_flex_code                 NUMBER;
  l_func_currency             VARCHAR2(10);

  l_cs_name                   VARCHAR2(30);
  l_cs_threshold              NUMBER;

  l_return_status             VARCHAR2(1);

  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);

  cursor c_WS is
    select budget_group_id,
	   nvl(global_worksheet_id, worksheet_id) global_worksheet_id,
	   nvl(constraint_set_id, global_constraint_set_id) constraint_set_id,
	   budget_calendar_id,
	   nvl(data_extract_id, global_data_extract_id) data_extract_id,
	   budget_by_position
      from PSB_WORKSHEETS_V
     where worksheet_id = p_worksheet_id;

  cursor c_BG is
    select nvl(chart_of_accounts_id, root_chart_of_accounts_id) chart_of_accounts_id,
	   nvl(currency_code, root_currency_code) currency_code,
	   nvl(business_group_id, root_business_group_id) business_group_id
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = l_budget_group_id;

  cursor c_ConstSet is
    select name,
	   constraint_threshold
      from PSB_CONSTRAINT_SETS_V
     where constraint_set_id = l_constraint_set_id;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  for c_WS_Rec in c_WS loop
    l_budget_group_id := c_WS_Rec.budget_group_id;
    l_global_worksheet_id := c_WS_Rec.global_worksheet_id;
    l_constraint_set_id := c_WS_Rec.constraint_set_id;
    l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
    l_data_extract_id := c_WS_Rec.data_extract_id;
    l_budget_by_position := c_WS_Rec.budget_by_position;
  end loop;

  for c_BG_Rec in c_BG loop
    l_flex_code := c_BG_Rec.chart_of_accounts_id;
    l_func_currency := c_BG_Rec.currency_code;
    l_business_group_id := c_BG_Rec.business_group_id;
  end loop;

  for c_ConstSet_Rec in c_ConstSet loop
    l_cs_name := c_ConstSet_Rec.name;
    l_cs_threshold := c_ConstSet_Rec.constraint_threshold;
  end loop;

  Initialize (p_worksheet_id => p_worksheet_id,
	      p_return_status => l_return_status);

  if nvl(l_constraint_set_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
  begin

    if l_budget_calendar_id <> nvl(PSB_WS_ACCT1.g_budget_calendar_id, FND_API.G_MISS_NUM) then
    begin

      PSB_WS_ACCT1.Cache_Budget_Calendar
	 (p_return_status => l_return_status,
	  p_budget_calendar_id => l_budget_calendar_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

    Check_Reentrant_Status
       (p_return_status => l_return_status,
	p_worksheet_id => p_worksheet_id,
	p_parameter_set_id => g_parameter_set_id,
	p_constraint_set_id => g_constraint_set_id,
	p_allocrule_set_id => g_allocrule_set_id,
	p_budget_calendar_id => g_budget_calendar_id,
	p_budget_group_id => g_budget_group_id,
	p_data_extract_id => g_data_extract_id,
	p_gl_budget_set_id => g_gl_budget_set_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
       (p_api_version              => 1.0  ,
	p_return_status            => l_return_status,
	p_concurrency_class        => 'WORKSHEET_CREATION',
	p_concurrency_entity_name  => 'WORKSHEET',
	p_concurrency_entity_id    => p_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
    end if;

    PSB_WS_POS3.Apply_Element_Constraints
       (p_return_status => l_return_status,
	p_worksheet_id => l_global_worksheet_id,
	p_budget_calendar_id => l_budget_calendar_id,
	p_data_extract_id => l_data_extract_id,
	p_constraint_set_id => l_constraint_set_id,
	p_constraint_set_name => l_cs_name,
	p_constraint_threshold => l_cs_threshold);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
       (p_api_version              => 1.0  ,
	p_return_status            => l_return_status,
	p_concurrency_class        => 'WORKSHEET_CREATION',
	p_concurrency_entity_name  => 'WORKSHEET',
	p_concurrency_entity_id    => p_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     PSB_CONCURRENCY_CONTROL_PVT.Release_Concurrency_Control
	(p_api_version              => 1.0  ,
	 p_return_status            => l_return_status,
	 p_concurrency_class        => 'WORKSHEET_CREATION',
	 p_concurrency_entity_name  => 'WORKSHEET',
	 p_concurrency_entity_id    => p_worksheet_id);

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);

     end if;

END Apply_Elem_Constraints;

/*------------------------------------------------------------------------------*/

PROCEDURE Post_Create_Line_Items
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'Post_Create_Line_Items';
  l_api_version        CONSTANT NUMBER         := 1.0;

  l_return_status      VARCHAR2(1);

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  PSB_WORKSHEET.Update_Worksheet
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_worksheet_id => p_worksheet_id,
      p_ws_creation_complete => 'Y');

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);

     end if;

END Post_Create_Line_Items;

/*------------------------------------------------------------------------------*/

PROCEDURE Delete_WS_Line_Items
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_global_worksheet  IN   VARCHAR2 := FND_API.G_TRUE
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Delete_WS_Line_Items';
  l_api_version       CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean(p_global_worksheet) then
  begin

    delete from PSB_POSITION_ASSIGNMENTS
     where worksheet_id = p_worksheet_id;

    delete from PSB_PAY_ELEMENT_RATES
     where worksheet_id = p_worksheet_id;

    delete from PSB_WS_POSITION_LINES
     where position_line_id in
	  (select position_line_id
	     from PSB_WS_LINES_POSITIONS
	    where worksheet_id = p_worksheet_id);

    delete from PSB_WS_FTE_LINES
     where position_line_id in
	  (select position_line_id
	     from PSB_WS_LINES_POSITIONS
	    where worksheet_id = p_worksheet_id);

    delete from PSB_WS_ELEMENT_LINES
     where position_line_id in
	  (select position_line_id
	     from PSB_WS_LINES_POSITIONS
	    where worksheet_id = p_worksheet_id);

  end;
  end if;

  delete from PSB_WS_LINES_POSITIONS
   where worksheet_id = p_worksheet_id;

  if FND_API.to_Boolean(p_global_worksheet) then
  begin

    delete from PSB_WS_ACCOUNT_LINES
     where account_line_id in
	  (select account_line_id
	     from PSB_WS_LINES
	    where worksheet_id =  p_worksheet_id);

  end;
  end if;

  delete from PSB_WS_LINES
   where worksheet_id = p_worksheet_id;

  delete from PSB_REENTRANT_PROCESS_STATUS
   where process_type = 'WORKSHEET_CREATION'
     and process_uid = p_worksheet_id;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);

     end if;

END Delete_WS_Line_Items;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Worksheet
( p_api_version                       IN   NUMBER,
  p_validation_level                  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status                     OUT  NOCOPY  VARCHAR2,
  p_budget_group_id                   IN   NUMBER,
  p_budget_calendar_id                IN   NUMBER,
  p_worksheet_type                    IN   VARCHAR2,
  p_name                              IN   VARCHAR2,
  p_description                       IN   VARCHAR2,
  p_ws_creation_complete              IN   VARCHAR2,
  p_stage_set_id                      IN   NUMBER,
  p_current_stage_seq                 IN   NUMBER,
  p_global_worksheet_id               IN   NUMBER,
  p_global_worksheet_flag             IN   VARCHAR2,
  p_global_worksheet_option           IN   VARCHAR2,
  p_local_copy_flag                   IN   VARCHAR2,
  p_copy_of_worksheet_id              IN   NUMBER,
  p_freeze_flag                       IN   VARCHAR2,
  p_budget_by_position                IN   VARCHAR2,
  p_use_revised_element_rates         IN   VARCHAR2,
  p_num_proposed_years                IN   NUMBER,
  p_num_years_to_allocate             IN   NUMBER,
  p_rounding_factor                   IN   NUMBER,
  p_gl_cutoff_period                  IN   DATE,
  p_budget_version_id                 IN   NUMBER,
  p_gl_budget_set_id                  IN   NUMBER,
  p_include_stat_balance              IN   VARCHAR2,
  p_include_trans_balance             IN   VARCHAR2,
  p_include_adj_period                IN   VARCHAR2,
  p_data_extract_id                   IN   NUMBER,
  p_parameter_set_id                  IN   NUMBER,
  p_constraint_set_id                 IN   NUMBER,
  p_allocrule_set_id                  IN   NUMBER,
  p_date_submitted                    IN   DATE,
  p_submitted_by                      IN   NUMBER,
  p_attribute1                        IN   VARCHAR2,
  p_attribute2                        IN   VARCHAR2,
  p_attribute3                        IN   VARCHAR2,
  p_attribute4                        IN   VARCHAR2,
  p_attribute5                        IN   VARCHAR2,
  p_attribute6                        IN   VARCHAR2,
  p_attribute7                        IN   VARCHAR2,
  p_attribute8                        IN   VARCHAR2,
  p_attribute9                        IN   VARCHAR2,
  p_attribute10                       IN   VARCHAR2,
  p_context                           IN   VARCHAR2,
  p_create_non_pos_line_items         IN   VARCHAR2,
  p_apply_element_parameters          IN   VARCHAR2,
  p_apply_position_parameters         IN   VARCHAR2,
  p_create_positions                  IN   VARCHAR2,
  p_create_summary_totals             IN   VARCHAR2,
  p_apply_constraints                 IN   VARCHAR2,
  p_flex_mapping_set_id               IN   NUMBER,
  p_include_gl_commit_balance         IN   VARCHAR2,
  p_include_gl_oblig_balance          IN   VARCHAR2,
  p_include_gl_other_balance          IN   VARCHAR2,
  p_include_cbc_commit_balance        IN   VARCHAR2,
  p_include_cbc_oblig_balance         IN   VARCHAR2,
  p_include_cbc_budget_balance        IN   VARCHAR2,
  p_federal_ws_flag		      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
 /* bug no 4725091 */
  p_include_gl_forwd_balance          IN   VARCHAR2,
  p_worksheet_id                      OUT  NOCOPY  NUMBER
) IS

  l_api_name                   CONSTANT VARCHAR2(30)   := 'Create_Worksheet';
  l_api_version                CONSTANT NUMBER         := 1.0;

  l_worksheet_id               NUMBER;
  l_worksheet_name             VARCHAR2(80);
  l_userid                     NUMBER;
  l_loginid                    NUMBER;
  l_start_stage_seq            NUMBER;

  cursor c_Stage is
    select min(sequence_number) sequence_number
     from psb_budget_stages
    where budget_stage_set_id = p_stage_set_id;

  cursor c_Seq is
    select psb_worksheets_s.nextval worksheet_id
      from dual;

  cursor c_Budget_Group is
    select short_name
     from psb_budget_groups
    where budget_group_id = p_budget_group_id;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Get Who Values

  l_userid := FND_GLOBAL.USER_ID;
  l_loginid := FND_GLOBAL.LOGIN_ID;

  for c_Stage_Rec in c_Stage loop
    l_start_stage_seq := c_Stage_Rec.sequence_number;
  end loop;

  for c_Seq_Rec in c_Seq loop
    l_worksheet_id := c_Seq_Rec.Worksheet_ID;
  end loop;

  for c_Budget_Group_Rec in C_Budget_Group loop
    l_worksheet_name := c_Budget_Group_Rec.short_name || ' - '|| to_char(l_worksheet_id);
  end loop;

  insert into PSB_WORKSHEETS
	(worksheet_id,
	 budget_group_id,
	 budget_calendar_id,
	 worksheet_type,
	 name,
	 description,
	 ws_creation_complete,
	 stage_set_id,
	 current_stage_seq,
	 global_worksheet_id,
	 global_worksheet_flag,
	 global_worksheet_option,
	 local_copy_flag,
	 copy_of_worksheet_id,
	 freeze_flag,
	 budget_by_position,
	 use_revised_element_rates,
	 num_proposed_years,
	 num_years_to_allocate,
	 rounding_factor,
	 gl_cutoff_period,
	 budget_version_id,
	 gl_budget_set_id,
	 include_stat_balance,
	 include_translated_balance,
	 include_adjustment_periods,
	 data_extract_id,
	 parameter_set_id,
	 constraint_set_id,
	 allocrule_set_id,
	 date_submitted,
	 submitted_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 created_by,
	 creation_date,
	 attribute1,
	 attribute2,
	 attribute3,
	 attribute4,
	 attribute5,
	 attribute6,
	 attribute7,
	 attribute8,
	 attribute9,
	 attribute10,
	 context,
	 create_non_pos_line_items,
	 apply_element_parameters,
	 apply_position_parameters,
	 create_positions,
	 create_summary_totals,
	 apply_constraints,
	 flex_mapping_set_id,
	 include_gl_commit_balance,
	 include_gl_oblig_balance,
	 include_gl_other_balance,
	 include_cbc_commit_balance,
	 include_cbc_oblig_balance,
	 include_cbc_budget_balance,
	 /* For Bug 3157960, added the federal ws flag */
	 federal_ws_flag,
         /* bug no 4725091 */
         include_gl_forward_balance)
  values (l_worksheet_id,
	 p_budget_group_id,
	 p_budget_calendar_id,
	 p_worksheet_type,
	 decode(p_name, FND_API.G_MISS_CHAR, l_worksheet_name, null, l_worksheet_name, p_name),
	 p_description,
	 decode(p_ws_creation_complete, FND_API.G_MISS_CHAR, null, p_ws_creation_complete),
	 p_stage_set_id,
	 decode(p_current_stage_seq, FND_API.G_MISS_NUM, l_start_stage_seq, null, l_start_stage_seq, p_current_stage_seq),
	 decode(p_global_worksheet_id, FND_API.G_MISS_NUM, null, p_global_worksheet_id),
	 decode(p_global_worksheet_flag, FND_API.G_MISS_CHAR, null, p_global_worksheet_flag),
	 decode(p_global_worksheet_option, FND_API.G_MISS_CHAR, null, p_global_worksheet_option),
	 decode(p_local_copy_flag, FND_API.G_MISS_CHAR, null, p_local_copy_flag),
	 decode(p_copy_of_worksheet_id, FND_API.G_MISS_NUM, null, p_copy_of_worksheet_id),
	 decode(p_freeze_flag, FND_API.G_MISS_CHAR, null, p_freeze_flag),
	 decode(p_budget_by_position, FND_API.G_MISS_CHAR, null, p_budget_by_position),
	 decode(p_use_revised_element_rates, FND_API.G_MISS_CHAR, null, p_use_revised_element_rates),
	 decode(p_num_proposed_years, FND_API.G_MISS_NUM, null, p_num_proposed_years),
	 decode(p_num_years_to_allocate, FND_API.G_MISS_NUM, null, p_num_years_to_allocate),
	 decode(p_rounding_factor, FND_API.G_MISS_NUM, null, p_rounding_factor),
	 decode(p_gl_cutoff_period, FND_API.G_MISS_DATE, null, p_gl_cutoff_period),
	 decode(p_budget_version_id, FND_API.G_MISS_NUM, null, p_budget_version_id),
	 decode(p_gl_budget_set_id, FND_API.G_MISS_NUM, null, p_gl_budget_set_id),
	 decode(p_include_stat_balance, FND_API.G_MISS_CHAR, null, p_include_stat_balance),
	 decode(p_include_trans_balance, FND_API.G_MISS_CHAR, null, p_include_trans_balance),
	 decode(p_include_adj_period, FND_API.G_MISS_CHAR, null, p_include_adj_period),
	 decode(p_data_extract_id, FND_API.G_MISS_NUM, null, p_data_extract_id),
	 decode(p_parameter_set_id, FND_API.G_MISS_NUM, null, p_parameter_set_id),
	 decode(p_constraint_set_id, FND_API.G_MISS_NUM, null, p_constraint_set_id),
	 decode(p_allocrule_set_id, FND_API.G_MISS_NUM, null, p_allocrule_set_id),
	 decode(p_date_submitted, FND_API.G_MISS_DATE, null, p_date_submitted),
	 decode(p_submitted_by, FND_API.G_MISS_NUM, null, p_submitted_by),
	 sysdate,
	 l_userid,
	 l_loginid,
	 l_userid,
	 sysdate,
	 decode(p_attribute1, FND_API.G_MISS_CHAR, null, p_attribute1),
	 decode(p_attribute2, FND_API.G_MISS_CHAR, null, p_attribute2),
	 decode(p_attribute3, FND_API.G_MISS_CHAR, null, p_attribute3),
	 decode(p_attribute4, FND_API.G_MISS_CHAR, null, p_attribute4),
	 decode(p_attribute5, FND_API.G_MISS_CHAR, null, p_attribute5),
	 decode(p_attribute6, FND_API.G_MISS_CHAR, null, p_attribute6),
	 decode(p_attribute7, FND_API.G_MISS_CHAR, null, p_attribute7),
	 decode(p_attribute8, FND_API.G_MISS_CHAR, null, p_attribute8),
	 decode(p_attribute9, FND_API.G_MISS_CHAR, null, p_attribute9),
	 decode(p_attribute10, FND_API.G_MISS_CHAR, null, p_attribute10),
	 decode(p_context, FND_API.G_MISS_CHAR, null, p_context),
	 decode(p_create_non_pos_line_items, FND_API.G_MISS_CHAR, null, p_create_non_pos_line_items),
	 decode(p_apply_element_parameters, FND_API.G_MISS_CHAR, null, p_apply_element_parameters),
	 decode(p_apply_position_parameters, FND_API.G_MISS_CHAR, null, p_apply_position_parameters),
	 decode(p_create_positions, FND_API.G_MISS_CHAR, null, p_create_positions),
	 decode(p_create_summary_totals, FND_API.G_MISS_CHAR, null, p_create_summary_totals),
	 decode(p_apply_constraints, FND_API.G_MISS_CHAR, null, p_apply_constraints),
	 decode(p_flex_mapping_set_id, FND_API.G_MISS_NUM, null, p_flex_mapping_set_id),
	 decode(p_include_gl_commit_balance, FND_API.G_MISS_CHAR, null, p_include_gl_commit_balance),
	 decode(p_include_gl_oblig_balance, FND_API.G_MISS_CHAR, null, p_include_gl_oblig_balance),
	 decode(p_include_gl_other_balance, FND_API.G_MISS_CHAR, null, p_include_gl_other_balance),
	 decode(p_include_cbc_commit_balance, FND_API.G_MISS_CHAR, null, p_include_cbc_commit_balance),
	 decode(p_include_cbc_oblig_balance, FND_API.G_MISS_CHAR, null, p_include_cbc_oblig_balance),
	 decode(p_include_cbc_budget_balance, FND_API.G_MISS_CHAR, null, p_include_cbc_oblig_balance),
	 decode(p_federal_ws_flag,FND_API.G_MISS_CHAR,null,p_federal_ws_flag),
         /* bug no 4725091 */
         decode(p_include_gl_forwd_balance,FND_API.G_MISS_CHAR, null, p_include_gl_forwd_balance)
         );

  p_worksheet_id := l_worksheet_id;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Create_Worksheet;

/* ----------------------------------------------------------------------- */

PROCEDURE Update_Worksheet
( p_api_version                       IN   NUMBER,
  p_validation_level                  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status                     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id                      IN   NUMBER := FND_API.G_MISS_NUM,
  p_worksheet_type                    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_description                       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ws_creation_complete              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_global_worksheet_id               IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq                 IN   NUMBER := FND_API.G_MISS_NUM,
  p_local_copy_flag                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_copy_of_worksheet_id              IN   NUMBER := FND_API.G_MISS_NUM,
  p_freeze_flag                       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_use_revised_element_rates         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  /* Bug # 3083970 */
  p_num_proposed_years                IN   NUMBER := FND_API.G_MISS_NUM,
  p_rounding_factor                   IN   NUMBER  := FND_API.G_MISS_NUM,
  /* End bug */
  p_date_submitted                    IN   DATE := FND_API.G_MISS_DATE,
  p_submitted_by                      IN   NUMBER := FND_API.G_MISS_NUM,
  p_attribute1                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute2                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute3                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute4                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute5                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute6                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute7                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute8                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute9                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute10                       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_context                           IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_create_non_pos_line_items         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_apply_element_parameters          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_apply_position_parameters         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_create_positions                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_create_summary_totals             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_apply_constraints                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_gl_commit_balance         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_gl_oblig_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_gl_other_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_cbc_commit_balance        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_cbc_oblig_balance         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_cbc_budget_balance        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  /* For Bug No. 2312657 : Start */
  p_gl_cutoff_period                  IN   DATE := NULL,
  p_gl_budget_set_id                  IN   NUMBER := NULL,
  /* For Bug No. 2312657 : End */
  p_federal_ws_flag                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  /* bug no 4725091 */
  p_include_gl_forwd_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR
) IS

  l_api_name                   CONSTANT VARCHAR2(30)   := 'Update_Worksheet';
  l_api_version                CONSTANT NUMBER         := 1.0;

  l_userid                     NUMBER;
  l_loginid                    NUMBER;

  /* BUG 3239307 Start */
  l_gl_cutoff_period           DATE;
  /* BUG 3239307 End */

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Get Who Values

  l_userid := FND_GLOBAL.USER_ID;
  l_loginid := FND_GLOBAL.LOGIN_ID;

  /* BUG 3239307 Start */
  select gl_cutoff_period
  into   l_gl_cutoff_period
  from   psb_worksheets
  where  worksheet_id = p_worksheet_id;
  /* BUG 3239307 End */

  update PSB_WORKSHEETS
     set worksheet_type = decode(p_worksheet_type, FND_API.G_MISS_CHAR, worksheet_type, p_worksheet_type),
	 description = decode(p_description, FND_API.G_MISS_CHAR, description, p_description),
	 ws_creation_complete = decode(p_ws_creation_complete, FND_API.G_MISS_CHAR, ws_creation_complete, p_ws_creation_complete),
	 global_worksheet_id = decode(p_global_worksheet_id, FND_API.G_MISS_NUM, global_worksheet_id, p_global_worksheet_id),
	 current_stage_seq = decode(p_current_stage_seq, FND_API.G_MISS_NUM, current_stage_seq, p_current_stage_seq),
	 local_copy_flag = decode(p_local_copy_flag, FND_API.G_MISS_CHAR, local_copy_flag, p_local_copy_flag),
	 copy_of_worksheet_id = decode(p_copy_of_worksheet_id, FND_API.G_MISS_NUM, copy_of_worksheet_id, p_copy_of_worksheet_id),
	 freeze_flag = decode(p_freeze_flag, FND_API.G_MISS_CHAR, freeze_flag, p_freeze_flag),
	 use_revised_element_rates = decode(p_use_revised_element_rates, FND_API.G_MISS_CHAR, use_revised_element_rates, p_use_revised_element_rates),
	  /* Bug # 3083970 */
	 num_proposed_years = decode(p_num_proposed_years, FND_API.G_MISS_NUM, num_proposed_years, p_num_proposed_years),
	 rounding_factor = decode(p_rounding_factor, FND_API.G_MISS_NUM, rounding_factor, p_rounding_factor),
	  /* End Bug # 3083970 */
	 date_submitted = decode(p_date_submitted, FND_API.G_MISS_DATE, date_submitted, p_date_submitted),
	 submitted_by = decode(p_submitted_by, FND_API.G_MISS_NUM, submitted_by, p_submitted_by),
	 last_update_date = sysdate,
	 last_updated_by = l_userid,
	 last_update_login = l_loginid,
	 attribute1 = decode(p_attribute1, FND_API.G_MISS_CHAR, attribute1, p_attribute1),
	 attribute2 = decode(p_attribute2, FND_API.G_MISS_CHAR, attribute2, p_attribute2),
	 attribute3 = decode(p_attribute3, FND_API.G_MISS_CHAR, attribute3, p_attribute3),
	 attribute4 = decode(p_attribute4, FND_API.G_MISS_CHAR, attribute4, p_attribute4),
	 attribute5 = decode(p_attribute5, FND_API.G_MISS_CHAR, attribute5, p_attribute5),
	 attribute6 = decode(p_attribute6, FND_API.G_MISS_CHAR, attribute6, p_attribute6),
	 attribute7 = decode(p_attribute7, FND_API.G_MISS_CHAR, attribute7, p_attribute7),
	 attribute8 = decode(p_attribute8, FND_API.G_MISS_CHAR, attribute8, p_attribute8),
	 attribute9 = decode(p_attribute9, FND_API.G_MISS_CHAR, attribute9, p_attribute9),
	 attribute10 = decode(p_attribute10, FND_API.G_MISS_CHAR, attribute10, p_attribute10),
	 context = decode(p_context, FND_API.G_MISS_CHAR, context, p_context),
	 create_non_pos_line_items = decode(p_create_non_pos_line_items, FND_API.G_MISS_CHAR, create_non_pos_line_items, p_create_non_pos_line_items),
	 apply_element_parameters = decode(p_apply_element_parameters, FND_API.G_MISS_CHAR, apply_element_parameters, p_apply_element_parameters),
	 apply_position_parameters = decode(p_apply_position_parameters, FND_API.G_MISS_CHAR, apply_position_parameters, p_apply_position_parameters),
	 create_positions = decode(p_create_positions, FND_API.G_MISS_CHAR, create_positions, p_create_positions),
	 create_summary_totals = decode(p_create_summary_totals, FND_API.G_MISS_CHAR, create_summary_totals, p_create_summary_totals),
	 apply_constraints = decode(p_apply_constraints, FND_API.G_MISS_CHAR, apply_constraints, p_apply_constraints),
	 include_gl_commit_balance = decode(p_include_gl_commit_balance, FND_API.G_MISS_CHAR, include_gl_commit_balance, p_include_gl_commit_balance),
	 include_gl_oblig_balance = decode(p_include_gl_oblig_balance, FND_API.G_MISS_CHAR, include_gl_oblig_balance, p_include_gl_oblig_balance),
	 include_gl_other_balance = decode(p_include_gl_other_balance, FND_API.G_MISS_CHAR, include_gl_other_balance, p_include_gl_other_balance),
	 include_cbc_commit_balance = decode(p_include_cbc_commit_balance, FND_API.G_MISS_CHAR, include_cbc_commit_balance, p_include_cbc_commit_balance),
	 include_cbc_oblig_balance = decode(p_include_cbc_oblig_balance, FND_API.G_MISS_CHAR, include_cbc_oblig_balance, p_include_cbc_oblig_balance),
	 include_cbc_budget_balance = decode(p_include_cbc_budget_balance, FND_API.G_MISS_CHAR, include_cbc_budget_balance, p_include_cbc_budget_balance),
	 /* For Bug No. 2312657 : Start */
	 gl_cutoff_period = decode(p_gl_cutoff_period, NULL, gl_cutoff_period, p_gl_cutoff_period),
	 gl_budget_set_id = decode(p_gl_budget_set_id, NULL, gl_budget_set_id, p_gl_budget_set_id),
	 /* For Bug No. 2312657 : End */
	 /* For Bug 3157960, added the federal ws flag */
	 federal_Ws_flag = decode(p_federal_ws_flag,FND_API.G_MISS_CHAR,federal_Ws_flag,p_federal_ws_flag),
         /* bug no 4725091 */
         include_gl_forward_balance = decode(p_include_gl_forwd_balance, FND_API.G_MISS_CHAR, include_gl_forward_balance, p_include_gl_forwd_balance)
  where worksheet_id = p_worksheet_id;

  /* BUG 3239307 Start */
  if (NVL(p_gl_cutoff_period, to_date('31-12-4712', 'dd-mm-yyyy')) <>
    NVL(l_gl_cutoff_period, to_date('31-12-4712', 'dd-mm-yyyy')))
  then
    update psb_worksheets
    set    gl_cutoff_period = p_gl_cutoff_period
    where  global_worksheet_id = p_worksheet_id;
  end if;
  /* BUG 3239307 End */

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Update_Worksheet;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_Worksheet
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Delete_Worksheet';
  l_api_version       CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  delete from PSB_WORKSHEETS
   where worksheet_id = p_worksheet_id;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Delete_Worksheet;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_WAL
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_account_line_id   IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Delete_WAL';
  l_api_version       CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  delete from PSB_WS_ACCOUNT_LINES
   where account_line_id = p_account_line_id;

--delete from PSB_WS_LINES a
-- where exists
--      (select 1
--         from PSB_WS_ACCOUNT_LINES b
--        where b.copy_of_account_line_id = p_account_line_id
--          and b.account_line_id = a.account_line_id);

--delete from PSB_WS_ACCOUNT_LINES
-- where copy_of_account_line_id = p_account_line_id;

  delete from PSB_WS_LINES
   where account_line_id = p_account_line_id;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Delete_WAL;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_WPL
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_position_line_id  IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Delete_WPL';
  l_api_version       CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  delete from PSB_WS_FTE_LINES
   where position_line_id = p_position_line_id;

  delete from PSB_WS_ELEMENT_LINES
   where position_line_id = p_position_line_id;

  delete from PSB_WS_LINES
   where account_line_id in
	(select account_line_id
	   from PSB_WS_ACCOUNT_LINES
	  where element_set_id is not null
	    and position_line_id = p_position_line_id);

  delete from PSB_WS_ACCOUNT_LINES
   where position_line_id = p_position_line_id;

  delete from PSB_WS_LINES_POSITIONS
   where position_line_id = p_position_line_id;

  delete from PSB_POSITION_ASSIGNMENTS
   where position_id =
	(select position_id
	   from PSB_WS_POSITION_LINES
	  where position_line_id = p_position_line_id)
     and worksheet_id =
	(select nvl(global_worksheet_id, worksheet_id)
	   from PSB_WORKSHEETS
	  where worksheet_id = p_worksheet_id);

  delete from PSB_WS_POSITION_LINES
   where position_line_id = p_position_line_id;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Delete_WPL;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_WFL
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_fte_line_id       IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Delete_WFL';
  l_api_version       CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  delete from PSB_WS_FTE_LINES
   where fte_line_id = p_fte_line_id;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Delete_WFL;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_WEL
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_element_line_id   IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Delete_WEL';
  l_api_version       CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  delete from PSB_WS_ELEMENT_LINES
   where element_line_id = p_element_line_id;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Delete_WEL;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_Summary_Lines
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Delete_Summary_Lines';
  l_api_version       CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  delete from PSB_WS_ACCOUNT_LINES
   where template_id is not null
     and account_line_id in
	(select account_line_id
	   from PSB_WS_LINES
	  where worksheet_id = p_worksheet_id);

  delete from PSB_WS_LINES a
   where a.worksheet_id = p_worksheet_id
     and not exists
	(select 1
	   from PSB_WS_ACCOUNT_LINES b
	  where b.account_line_id = a.account_line_id);


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Delete_Summary_Lines;

/* ----------------------------------------------------------------------- */

PROCEDURE Initialize
( p_worksheet_id   IN   NUMBER,
  p_return_status  OUT  NOCOPY  VARCHAR2
) IS

  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);

BEGIN

  Cache_Worksheet_Variables
       (p_worksheet_id => p_worksheet_id,
	p_return_status => l_return_status);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_BUDGET_GROUPS_PVT.Check_Budget_Group_Freeze
     (p_api_version => 1.0,
      p_budget_group_id => g_budget_group_id,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    message_token('ROOT_BUDGET_GROUP', g_budget_group_name);
    add_message('PSB', 'PSB_FREEZE_BG_HIERARCHY');
    raise FND_API.G_EXC_ERROR;
  end if;

  if FND_API.to_Boolean(g_budget_by_position) then
  begin

    Check_DataExt_Completion
	 (p_return_status => l_return_status,
	  p_data_extract_id => g_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      message_token('DATA_EXTRACT', g_data_extract_name);
      add_message('PSB', 'PSB_DATA_EXTRACT_INCOMPLETE');
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

END Initialize;

/* ----------------------------------------------------------------------- */

PROCEDURE Cache_Worksheet_Variables
( p_worksheet_id   IN   NUMBER,
  p_return_status  OUT  NOCOPY  VARCHAR2
) IS

  l_new_base_sp    VARCHAR2(1) := FND_API.G_TRUE;
  l_name           VARCHAR2(2000);

  l_userid         NUMBER;
  l_loginid        NUMBER;

  cursor c_WS is
    select budget_group_id,
	   budget_calendar_id,
	   nvl(parameter_set_id, global_parameter_set_id) parameter_set_id,
	   nvl(constraint_set_id, global_constraint_set_id) constraint_set_id,
	   nvl(allocrule_set_id, global_allocrule_set_id) allocrule_set_id,
	   nvl(data_extract_id, global_data_extract_id) data_extract_id,
	   data_extract_name,
	   nvl(global_worksheet_id, worksheet_id) global_worksheet_id,
	   local_copy_flag,
	   global_worksheet_flag,
	   global_worksheet_option,
	   rounding_factor,
	   budget_version_id,
	   gl_budget_set_id,
	   gl_cutoff_period,
	   budget_by_position,
	   use_revised_element_rates,
	   num_proposed_years,
	   num_years_to_allocate,
	   stage_set_id,
	   current_stage_seq,
	   include_stat_balance,
	   include_translated_balance,
	   include_adjustment_periods,
	   create_non_pos_line_items,
	   apply_element_parameters,
	   apply_position_parameters,
	   create_positions,
	   create_summary_totals,
	   apply_constraints,
	   flex_mapping_set_id,
	   include_gl_commit_balance,
	   include_gl_oblig_balance,
	   include_gl_other_balance,
	   include_cbc_commit_balance,
	   include_cbc_oblig_balance,
	   include_cbc_budget_balance,
           /* Bug No 4725091 */
           include_gl_forward_balance
      from PSB_WORKSHEETS_V
     where worksheet_id = p_worksheet_id;

  -- Bug 3543845: Add root_budget_greoup, ps_account_position_set_id, and
  -- nps_account_position_set_id for caching purposes.
  cursor c_BG is
    select nvl(root_budget_group_id, budget_group_id) root_budget_group_id,
           nvl(set_of_books_id, root_set_of_books_id) set_of_books_id,
           nvl(business_group_id, root_business_group_id) business_group_id,
           nvl(name, root_name) name,
           root_budget_group,
           ps_account_position_set_id psapsid,
           nps_account_position_set_id npsapsid
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = g_budget_group_id;

  cursor c_Sob is
    select currency_code,
	   chart_of_accounts_id,
	   name,
	   enable_budgetary_control_flag
      from GL_SETS_OF_BOOKS
     where set_of_books_id = g_set_of_books_id;

  cursor c_SP is
    select service_package_id
      from PSB_SERVICE_PACKAGES
     where base_service_package = 'Y'
       and global_worksheet_id = g_global_worksheet_id;

  cursor c_sp_seq is
    select psb_service_packages_s.nextval ServicePackageID
      from dual;

  cursor c_Stage is
    select Min(sequence_number) sequence_number
      from PSB_BUDGET_STAGES
     where budget_stage_set_id = g_stage_set_id;

  cursor c_ConstSet is
    select name,
	   constraint_threshold
      from PSB_CONSTRAINT_SETS_V
     where constraint_set_id = g_constraint_set_id;

BEGIN

  l_userid := FND_GLOBAL.USER_ID;
  l_loginid := FND_GLOBAL.LOGIN_ID;

  for c_WS_Rec in c_WS loop
    g_budget_group_id := c_WS_Rec.budget_group_id;
    g_budget_calendar_id := c_WS_Rec.budget_calendar_id;
    g_parameter_set_id := c_WS_Rec.parameter_set_id;
    g_constraint_set_id := c_WS_Rec.constraint_set_id;
    g_allocrule_set_id := c_WS_Rec.allocrule_set_id;
    g_data_extract_id := c_WS_Rec.data_extract_id;
    g_data_extract_name := c_WS_Rec.data_extract_name;
    g_global_worksheet_id := c_WS_Rec.global_worksheet_id;
    g_local_copy_flag := c_WS_Rec.local_copy_flag;
    g_global_worksheet := c_WS_Rec.global_worksheet_flag;
    g_global_worksheet_option := c_WS_Rec.global_worksheet_option;
    g_rounding_factor := c_WS_Rec.rounding_factor;
    g_budget_version_id := c_WS_Rec.budget_version_id;
    g_gl_budget_set_id := c_WS_Rec.gl_budget_set_id;
    g_gl_cutoff_period := c_WS_Rec.gl_cutoff_period;
    g_budget_by_position := c_WS_Rec.budget_by_position;
    g_use_revised_element_rates := c_WS_Rec.use_revised_element_rates;
    g_num_proposed_years := c_WS_Rec.num_proposed_years;
    g_num_years_to_allocate := c_WS_Rec.num_years_to_allocate;
    g_stage_set_id := c_WS_Rec.stage_set_id;
    g_current_stage_seq := c_WS_Rec.current_stage_seq;
    g_incl_stat_bal := c_WS_Rec.include_stat_balance;
    g_incl_trans_bal := c_WS_Rec.include_translated_balance;
    g_incl_adj_period := c_WS_Rec.include_adjustment_periods;
    g_flex_mapping_set_id        := c_WS_Rec.flex_mapping_set_id;
    g_create_non_pos_line_items  := c_WS_Rec.create_non_pos_line_items;
    g_apply_element_parameters   := c_WS_Rec.apply_element_parameters;
    g_apply_position_parameters  := c_WS_Rec.apply_position_parameters;
    g_create_positions           := c_WS_Rec.create_positions;
    g_create_summary_totals      := c_WS_Rec.create_summary_totals;
    g_apply_constraints          := c_WS_Rec.apply_constraints;
    g_include_gl_commit_balance  := c_WS_Rec.include_gl_commit_balance;
    g_include_gl_oblig_balance   := c_WS_Rec.include_gl_oblig_balance;
    g_include_gl_other_balance   := c_WS_Rec.include_gl_other_balance;
    g_include_cbc_commit_balance := c_WS_Rec.include_cbc_commit_balance;
    g_include_cbc_oblig_balance  := c_WS_Rec.include_cbc_oblig_balance;
    g_include_cbc_budget_balance  := c_WS_Rec.include_cbc_budget_balance;
    /* Bug No 4725091 */
    g_include_gl_forward_balance := c_WS_Rec.include_gl_forward_balance;
  end loop;

  if ((g_global_worksheet is null) or (g_global_worksheet = 'N')) then
    g_global_worksheet := FND_API.G_FALSE;
  else
    g_global_worksheet := FND_API.G_TRUE;
  end if;

  if ((g_budget_by_position is null) or (g_budget_by_position = 'N')) then
    g_budget_by_position := FND_API.G_FALSE;
  else
    g_budget_by_position := FND_API.G_TRUE;
  end if;

  if ((g_use_revised_element_rates is null) or (g_use_revised_element_rates = 'N')) then
    g_use_revised_element_rates := FND_API.G_FALSE;
  else
    g_use_revised_element_rates := FND_API.G_TRUE;
  end if;

  if ((g_incl_stat_bal is null) or (g_incl_stat_bal = 'N')) then
    g_incl_stat_bal := FND_API.G_FALSE;
  else
    g_incl_stat_bal := FND_API.G_TRUE;
  end if;

  if ((g_incl_trans_bal is null) or (g_incl_trans_bal = 'N')) then
    g_incl_trans_bal := FND_API.G_FALSE;
  else
    g_incl_trans_bal := FND_API.G_TRUE;
  end if;

  if ((g_incl_adj_period is null) or (g_incl_adj_period = 'N')) then
    g_incl_adj_period := FND_API.G_FALSE;
  else
    g_incl_adj_period := FND_API.G_TRUE;
  end if;

  if ((g_create_non_pos_line_items is null) or (g_create_non_pos_line_items  = 'N')) then
    g_create_non_pos_line_items := FND_API.G_FALSE;
  else
    g_create_non_pos_line_items := FND_API.G_TRUE;
  end if;

  if ((g_apply_element_parameters is null) or (g_apply_element_parameters  = 'N')) then
    g_apply_element_parameters := FND_API.G_FALSE;
  else
    g_apply_element_parameters := FND_API.G_TRUE;
  end if;

  if ((g_apply_position_parameters is null) or (g_apply_position_parameters  = 'N')) then
    g_apply_position_parameters := FND_API.G_FALSE;
  else
    g_apply_position_parameters := FND_API.G_TRUE;
  end if;

  if ((g_create_positions is null) or (g_create_positions  = 'N')) then
    g_create_positions := FND_API.G_FALSE;
  else
    g_create_positions := FND_API.G_TRUE;
  end if;

  if ((g_create_summary_totals is null) or (g_create_summary_totals  = 'N')) then
    g_create_summary_totals := FND_API.G_FALSE;
  else
    g_create_summary_totals := FND_API.G_TRUE;
  end if;

  if ((g_apply_constraints is null) or (g_apply_constraints  = 'N')) then
    g_apply_constraints := FND_API.G_FALSE;
  else
    g_apply_constraints := FND_API.G_TRUE;
  end if;

  if ((g_include_gl_commit_balance is null) or (g_include_gl_commit_balance = 'N')) then
    g_include_gl_commit_balance := FND_API.G_FALSE;
  else
    g_include_gl_commit_balance := FND_API.G_TRUE;
  end if;

  if ((g_include_gl_oblig_balance is null) or (g_include_gl_oblig_balance = 'N')) then
    g_include_gl_oblig_balance := FND_API.G_FALSE;
  else
    g_include_gl_oblig_balance := FND_API.G_TRUE;
  end if;

  if ((g_include_gl_other_balance is null) or (g_include_gl_other_balance = 'N')) then
    g_include_gl_other_balance := FND_API.G_FALSE;
  else
    g_include_gl_other_balance := FND_API.G_TRUE;
  end if;

  if ((g_include_cbc_commit_balance is null) or (g_include_cbc_commit_balance = 'N')) then
    g_include_cbc_commit_balance := FND_API.G_FALSE;
  else
    g_include_cbc_commit_balance := FND_API.G_TRUE;
  end if;

  if ((g_include_cbc_oblig_balance is null) or (g_include_cbc_oblig_balance = 'N')) then
    g_include_cbc_oblig_balance := FND_API.G_FALSE;
  else
    g_include_cbc_oblig_balance := FND_API.G_TRUE;
  end if;

  if ((g_include_cbc_budget_balance is null) or (g_include_cbc_budget_balance = 'N')) then
    g_include_cbc_budget_balance := FND_API.G_FALSE;
  else
    g_include_cbc_budget_balance := FND_API.G_TRUE;
  end if;

  /* bug no 4725091 */
  if (g_include_gl_forward_balance is null) or (g_include_gl_forward_balance = 'N') then
    g_include_gl_forward_balance := fnd_api.g_false;
  else
    g_include_gl_forward_balance := fnd_api.g_true;
  end if;
  /* bug no 4725091 */


  for c_BG_Rec in c_BG loop
    g_root_budget_group_id := c_BG_Rec.root_budget_group_id;
    g_set_of_books_id := c_BG_Rec.set_of_books_id;
    g_business_group_id := c_BG_Rec.business_group_id;
    g_budget_group_name := c_BG_Rec.name;

    /* Bug 3543845 start : Cache ps_acct_pos_set_id and nps_acct_pos_set_id */
    IF (c_BG_Rec.root_budget_group = 'Y')
    THEN

      g_ps_acct_pos_set_id := c_BG_Rec.psapsid;
      g_nps_acct_pos_set_id := c_BG_Rec.npsapsid;

    ELSE

      SELECT ps_account_position_set_id,
             nps_account_position_set_id
           INTO
             g_ps_acct_pos_set_id,
             g_nps_acct_pos_set_id
      FROM   PSB_BUDGET_GROUPS
      WHERE  budget_group_id = g_root_budget_group_id;

    END IF;
    /* Bug 3543845 End */
  end loop;

  for c_Sob_Rec in c_Sob loop
    g_currency_code        := c_Sob_Rec.currency_code;
    g_flex_code            := c_Sob_Rec.chart_of_accounts_id;
    g_chart_of_accounts_id := g_flex_code; -- Bug#4571412
    g_set_of_books_name    := c_Sob_Rec.name;
    g_budgetary_control    := c_Sob_Rec.enable_budgetary_control_flag;
  end loop;

  if ((g_budgetary_control is null) or (g_budgetary_control = 'N')) then
    g_budgetary_control := FND_API.G_FALSE;
  else
    g_budgetary_control := FND_API.G_TRUE;
  end if;

  for c_SP_Rec in c_SP loop
    g_service_package_id := c_SP_Rec.service_package_id;
    l_new_base_sp := FND_API.G_FALSE;
  end loop;

  if FND_API.to_Boolean(l_new_base_sp) then
  begin

    for c_sp_seq_rec in c_sp_seq loop
      g_service_package_id := c_sp_seq_rec.ServicePackageID;
    end loop;

    add_message('PSB', 'PSB_BASE_SERVICE_PACKAGE');
    l_name := FND_MSG_PUB.Get
		 (p_encoded => FND_API.G_FALSE);
    FND_MSG_PUB.Delete_Msg;

    insert into PSB_SERVICE_PACKAGES
	  (service_package_id, global_worksheet_id,
	   base_service_package, name,
	   short_name, description, priority,
	   last_update_date, last_updated_by,
	   last_update_login, created_by, creation_date)
     values (g_service_package_id, p_worksheet_id,
	     'Y', substr(l_name, 1, 30),
	     substr(l_name, 1, 15), l_name, null,
	     sysdate, l_userid,
	     l_loginid, l_userid, sysdate);

  end;
  end if;

  for c_Stage_Rec in c_Stage loop
    g_start_stage_seq := c_Stage_Rec.sequence_number;
  end loop;

  for c_ConstSet_Rec in c_ConstSet loop
    g_cs_name := c_ConstSet_Rec.name;
    g_cs_threshold := c_ConstSet_Rec.constraint_threshold;
  end loop;

  -- Bug 3458191: Caching g_worksheet_id for account creation cp
  g_worksheet_id := p_worksheet_id;

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Cache_Worksheet_Variables;

/* ----------------------------------------------------------------------- */

PROCEDURE Check_DataExt_Completion
( p_data_extract_id  IN   NUMBER,
  p_return_status    OUT  NOCOPY  VARCHAR2
) IS

  l_status           VARCHAR2(1);

  cursor c_DataExtract is
    select data_extract_status
      from PSB_DATA_EXTRACTS
     where data_extract_id = p_data_extract_id;

BEGIN

  for c_DataExtract_Rec in c_DataExtract loop
    l_status := nvl(c_DataExtract_Rec.data_extract_status, 'I');
  end loop;

  if l_status <> 'C' then
    raise FND_API.G_EXC_ERROR;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Check_DataExt_Completion;

/* ----------------------------------------------------------------------- */

-- Add Token and Value to the Message Token array

PROCEDURE message_token(tokname IN VARCHAR2,
			tokval  IN VARCHAR2) IS

BEGIN

  if no_msg_tokens is null then
    no_msg_tokens := 1;
  else
    no_msg_tokens := no_msg_tokens + 1;
  end if;

  msg_tok_names(no_msg_tokens) := tokname;
  msg_tok_val(no_msg_tokens) := tokval;

END message_token;

/* ----------------------------------------------------------------------- */

-- Define a Message Token with a Value and set the Message Name

-- Calls FND_MESSAGE server package to set the Message Stack. This message is
-- retrieved by the calling program.

PROCEDURE add_message(appname IN VARCHAR2,
		      msgname IN VARCHAR2) IS

  i  BINARY_INTEGER;

BEGIN

  if ((appname is not null) and
      (msgname is not null)) then

    FND_MESSAGE.SET_NAME(appname, msgname);

    if no_msg_tokens is not null then

      for i in 1..no_msg_tokens loop
	FND_MESSAGE.SET_TOKEN(msg_tok_names(i), msg_tok_val(i));
      end loop;

    end if;

    FND_MSG_PUB.Add;

  end if;

  -- Clear Message Token stack

  no_msg_tokens := 0;

END add_message;

/* ----------------------------------------------------------------------- */

  -- Get Debug Information

  -- This Module is used to retrieve Debug Information for this routine. It
  -- prints Debug Information when run as a Batch Process from SQL*Plus. For
  -- the Debug Information to be printed on the Screen, the SQL*Plus parameter
  -- 'Serveroutput' should be set to 'ON'

FUNCTION Get_Debug RETURN VARCHAR2 IS

BEGIN

  return(g_dbug);

END Get_Debug;

/* ----------------------------------------------------------------------- */

END PSB_WORKSHEET;

/
