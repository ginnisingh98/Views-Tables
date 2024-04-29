--------------------------------------------------------
--  DDL for Package Body PSB_WS_POS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_POS1" AS
/* $Header: PSBVWP1B.pls 120.20.12010000.4 2010/04/04 11:41:44 rkotha ship $ */

  G_PKG_NAME CONSTANT    VARCHAR2(30):= 'PSB_WS_POS1';

  cursor c_WS (Worksheet NUMBER) is
    select budget_calendar_id,
	   budget_group_id,
	   rounding_factor,
	   nvl(global_worksheet_id, worksheet_id) global_worksheet_id,
	   nvl(data_extract_id, global_data_extract_id) data_extract_id,
	   local_copy_flag
      from PSB_WORKSHEETS_V
     where worksheet_id = Worksheet;

  cursor c_Wfl_SP (PosLine NUMBER,
		   BudYr NUMBER,
		   SvcPkg NUMBER,
		   StSet NUMBER,
		   CurSeq NUMBER) is
    select fte_line_id,
	   period1_fte, period2_fte, period3_fte, period4_fte,
	   period5_fte, period6_fte, period7_fte, period8_fte,
	   period9_fte, period10_fte, period11_fte, period12_fte,
	   period13_fte, period14_fte, period15_fte, period16_fte,
	   period17_fte, period18_fte, period19_fte, period20_fte,
	   period21_fte, period22_fte, period23_fte, period24_fte,
	   period25_fte, period26_fte, period27_fte, period28_fte,
	   period29_fte, period30_fte, period31_fte, period32_fte,
	   period33_fte, period34_fte, period35_fte, period36_fte,
	   period37_fte, period38_fte, period39_fte, period40_fte,
	   period41_fte, period42_fte, period43_fte, period44_fte,
	   period45_fte, period46_fte, period47_fte, period48_fte,
	   period49_fte, period50_fte, period51_fte, period52_fte,
	   period53_fte, period54_fte, period55_fte, period56_fte,
	   period57_fte, period58_fte, period59_fte, period60_fte,
	   annual_fte
      from PSB_WS_FTE_LINES a
     where CurSeq between start_stage_seq and current_stage_seq
       and stage_set_id = StSet
       and service_package_id = SvcPkg
       and budget_year_id = BudYr
       and position_line_id = PosLine;

  cursor c_BG (BudGrp NUMBER) is
    select nvl(business_group_id, root_business_group_id) business_group_id
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = BudGrp;

  cursor c_FTESeq is
    select psb_ws_fte_lines_s.nextval FteLineID
      from dual;

  cursor c_BaseSP (GlobalWS NUMBER) is
    select service_package_id
      from PSB_SERVICE_PACKAGES
     where base_service_package = 'Y'
       and global_worksheet_id = GlobalWS;

  cursor c_Rec_Elements (DataExt NUMBER,
			 BusGrp NUMBER) is
    select pay_element_id
      from PSB_PAY_ELEMENTS
     where processing_type = 'R'
       and business_group_id = BusGrp
       and data_extract_id = DataExt
    /* For Bug No. 2250319 */
     order by pay_element_id;

  TYPE TokNameArray IS TABLE OF VARCHAR2(100)
    INDEX BY BINARY_INTEGER;

  TYPE TokValArray IS TABLE OF VARCHAR2(1000)
    INDEX BY BINARY_INTEGER;

  -- Message Tokens
  no_msg_tokens          NUMBER := 0;
  msg_tok_names          TokNameArray;
  msg_tok_val            TokValArray;

  -- To store last annual FTE ratio for elements within an element set.
  g_last_annual_fte_ratio   NUMBER;

  g_dbug                 VARCHAR2(1000);

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function Definition                        */
/*                                                                         */
/* ----------------------------------------------------------------------- */

-- This procedure prorates the Element Costs and Account Distributions
-- using the Period FTE Ratios and the Annual FTE Ratio

PROCEDURE Distribute_Position_Cost
( p_return_status            OUT  NOCOPY  VARCHAR2,
  p_insert_from_base         IN   VARCHAR2 := FND_API.G_FALSE,
  p_update_from_base         IN   VARCHAR2 := FND_API.G_FALSE,
  p_worksheet_id             IN   NUMBER,
  p_flex_mapping_set_id      IN   NUMBER := FND_API.G_MISS_NUM,
  p_rounding_factor          IN   NUMBER,
  p_position_line_id         IN   NUMBER,
  p_pay_element_id           IN   NUMBER,
  p_budget_year_id           IN   NUMBER,
  p_base_service_package_id  IN   NUMBER := FND_API.G_MISS_NUM,
  p_service_package_id       IN   NUMBER,
  p_stage_set_id             IN   NUMBER,
  p_start_stage_seq          IN   NUMBER,
  p_current_stage_seq        IN   NUMBER,
  p_budget_group_id          IN   NUMBER,
  /*For Bug No : 2811698 Start*/
  p_period_fte               IN   PSB_WS_ACCT1.g_prdamt_tbl_type,
  p_total_fte                IN   NUMBER,
  p_num_budget_periods       IN   NUMBER
 /*For Bug No : 2811698 End*/

);

PROCEDURE message_token
( tokname IN  VARCHAR2,
  tokval  IN  VARCHAR2
);

PROCEDURE add_message
( appname  IN  VARCHAR2,
  msgname  IN  VARCHAR2
);

/* ----------------------------------------------------------------------- */
/* Bug No 2278216 Start */

-- Initialize the PL/SQL Structures that temporarily store Position Account
-- Period Distribution for a year

PROCEDURE Initialize_Period_Dist IS

  l_init_index  BINARY_INTEGER;

BEGIN

  for l_init_index in 1..g_periods.Count loop
    g_periods(l_init_index).ccid := null;
    g_periods(l_init_index).element_type := null;
    g_periods(l_init_index).element_set_id := null;
    g_periods(l_init_index).budget_year_id := null;
    g_periods(l_init_index).percent := null;
    g_periods(l_init_index).period_start_date := null;
    g_periods(l_init_index).period_end_date := null;
  end loop;

  g_num_periods := 0;

END Initialize_Period_Dist;

/* Bug No 2278216 End */
/* ----------------------------------------------------------------------- */

-- Initialize the PL/SQL Structures that temporarily store Position Cost info

PROCEDURE Initialize_Calc
( p_init_index  NUMBER := FND_API.G_MISS_NUM
) IS

  l_init_index  BINARY_INTEGER;

BEGIN

  if p_init_index = FND_API.G_MISS_NUM then
  begin

    -- Initialize the entire structure

    for l_init_index in 1..g_pc_costs.Count loop
      g_pc_costs(l_init_index).pay_element_id := null;
      g_pc_costs(l_init_index).element_type := null;
      g_pc_costs(l_init_index).element_set_id := null;
      g_pc_costs(l_init_index).element_cost := null;
      g_pc_costs(l_init_index).budget_year_id := null;
      g_pc_costs(l_init_index).period1_amount := null;
      g_pc_costs(l_init_index).period2_amount := null;
      g_pc_costs(l_init_index).period3_amount := null;
      g_pc_costs(l_init_index).period4_amount := null;
      g_pc_costs(l_init_index).period5_amount := null;
      g_pc_costs(l_init_index).period6_amount := null;
      g_pc_costs(l_init_index).period7_amount := null;
      g_pc_costs(l_init_index).period8_amount := null;
      g_pc_costs(l_init_index).period9_amount := null;
      g_pc_costs(l_init_index).period10_amount := null;
      g_pc_costs(l_init_index).period11_amount := null;
      g_pc_costs(l_init_index).period12_amount := null;
      g_pc_costs(l_init_index).period13_amount := null;
      g_pc_costs(l_init_index).period14_amount := null;
      g_pc_costs(l_init_index).period15_amount := null;
      g_pc_costs(l_init_index).period16_amount := null;
      g_pc_costs(l_init_index).period17_amount := null;
      g_pc_costs(l_init_index).period18_amount := null;
      g_pc_costs(l_init_index).period19_amount := null;
      g_pc_costs(l_init_index).period20_amount := null;
      g_pc_costs(l_init_index).period21_amount := null;
      g_pc_costs(l_init_index).period22_amount := null;
      g_pc_costs(l_init_index).period23_amount := null;
      g_pc_costs(l_init_index).period24_amount := null;
      g_pc_costs(l_init_index).period25_amount := null;
      g_pc_costs(l_init_index).period26_amount := null;
      g_pc_costs(l_init_index).period27_amount := null;
      g_pc_costs(l_init_index).period28_amount := null;
      g_pc_costs(l_init_index).period29_amount := null;
      g_pc_costs(l_init_index).period30_amount := null;
      g_pc_costs(l_init_index).period31_amount := null;
      g_pc_costs(l_init_index).period32_amount := null;
      g_pc_costs(l_init_index).period33_amount := null;
      g_pc_costs(l_init_index).period34_amount := null;
      g_pc_costs(l_init_index).period35_amount := null;
      g_pc_costs(l_init_index).period36_amount := null;
      g_pc_costs(l_init_index).period37_amount := null;
      g_pc_costs(l_init_index).period38_amount := null;
      g_pc_costs(l_init_index).period39_amount := null;
      g_pc_costs(l_init_index).period40_amount := null;
      g_pc_costs(l_init_index).period41_amount := null;
      g_pc_costs(l_init_index).period42_amount := null;
      g_pc_costs(l_init_index).period43_amount := null;
      g_pc_costs(l_init_index).period44_amount := null;
      g_pc_costs(l_init_index).period45_amount := null;
      g_pc_costs(l_init_index).period46_amount := null;
      g_pc_costs(l_init_index).period47_amount := null;
      g_pc_costs(l_init_index).period48_amount := null;
      g_pc_costs(l_init_index).period49_amount := null;
      g_pc_costs(l_init_index).period50_amount := null;
      g_pc_costs(l_init_index).period51_amount := null;
      g_pc_costs(l_init_index).period52_amount := null;
      g_pc_costs(l_init_index).period53_amount := null;
      g_pc_costs(l_init_index).period54_amount := null;
      g_pc_costs(l_init_index).period55_amount := null;
      g_pc_costs(l_init_index).period56_amount := null;
      g_pc_costs(l_init_index).period57_amount := null;
      g_pc_costs(l_init_index).period58_amount := null;
      g_pc_costs(l_init_index).period59_amount := null;
      g_pc_costs(l_init_index).period60_amount := null;
    end loop;

    g_num_pc_costs := 0;

  end;
  else
  begin

    -- Initialize a specific record in the structure. This is to avoid
    -- referencing uninitialized columns in the record which was
    -- crashing the database

    g_pc_costs(p_init_index).pay_element_id := null;
    g_pc_costs(p_init_index).element_type := null;
    g_pc_costs(p_init_index).element_set_id := null;
    g_pc_costs(p_init_index).element_cost := null;
    g_pc_costs(p_init_index).budget_year_id := null;
    g_pc_costs(p_init_index).period1_amount := null;
    g_pc_costs(p_init_index).period2_amount := null;
    g_pc_costs(p_init_index).period3_amount := null;
    g_pc_costs(p_init_index).period4_amount := null;
    g_pc_costs(p_init_index).period5_amount := null;
    g_pc_costs(p_init_index).period6_amount := null;
    g_pc_costs(p_init_index).period7_amount := null;
    g_pc_costs(p_init_index).period8_amount := null;
    g_pc_costs(p_init_index).period9_amount := null;
    g_pc_costs(p_init_index).period10_amount := null;
    g_pc_costs(p_init_index).period11_amount := null;
    g_pc_costs(p_init_index).period12_amount := null;
    g_pc_costs(p_init_index).period13_amount := null;
    g_pc_costs(p_init_index).period14_amount := null;
    g_pc_costs(p_init_index).period15_amount := null;
    g_pc_costs(p_init_index).period16_amount := null;
    g_pc_costs(p_init_index).period17_amount := null;
    g_pc_costs(p_init_index).period18_amount := null;
    g_pc_costs(p_init_index).period19_amount := null;
    g_pc_costs(p_init_index).period20_amount := null;
    g_pc_costs(p_init_index).period21_amount := null;
    g_pc_costs(p_init_index).period22_amount := null;
    g_pc_costs(p_init_index).period23_amount := null;
    g_pc_costs(p_init_index).period24_amount := null;
    g_pc_costs(p_init_index).period25_amount := null;
    g_pc_costs(p_init_index).period26_amount := null;
    g_pc_costs(p_init_index).period27_amount := null;
    g_pc_costs(p_init_index).period28_amount := null;
    g_pc_costs(p_init_index).period29_amount := null;
    g_pc_costs(p_init_index).period30_amount := null;
    g_pc_costs(p_init_index).period31_amount := null;
    g_pc_costs(p_init_index).period32_amount := null;
    g_pc_costs(p_init_index).period33_amount := null;
    g_pc_costs(p_init_index).period34_amount := null;
    g_pc_costs(p_init_index).period35_amount := null;
    g_pc_costs(p_init_index).period36_amount := null;
    g_pc_costs(p_init_index).period37_amount := null;
    g_pc_costs(p_init_index).period38_amount := null;
    g_pc_costs(p_init_index).period39_amount := null;
    g_pc_costs(p_init_index).period40_amount := null;
    g_pc_costs(p_init_index).period41_amount := null;
    g_pc_costs(p_init_index).period42_amount := null;
    g_pc_costs(p_init_index).period43_amount := null;
    g_pc_costs(p_init_index).period44_amount := null;
    g_pc_costs(p_init_index).period45_amount := null;
    g_pc_costs(p_init_index).period46_amount := null;
    g_pc_costs(p_init_index).period47_amount := null;
    g_pc_costs(p_init_index).period48_amount := null;
    g_pc_costs(p_init_index).period49_amount := null;
    g_pc_costs(p_init_index).period50_amount := null;
    g_pc_costs(p_init_index).period51_amount := null;
    g_pc_costs(p_init_index).period52_amount := null;
    g_pc_costs(p_init_index).period53_amount := null;
    g_pc_costs(p_init_index).period54_amount := null;
    g_pc_costs(p_init_index).period55_amount := null;
    g_pc_costs(p_init_index).period56_amount := null;
    g_pc_costs(p_init_index).period57_amount := null;
    g_pc_costs(p_init_index).period58_amount := null;
    g_pc_costs(p_init_index).period59_amount := null;
    g_pc_costs(p_init_index).period60_amount := null;

  end;
  end if;

END Initialize_Calc;

/* ----------------------------------------------------------------------- */

-- Initialize the PL/SQL Structures that temporarily store Position Account
-- Distribution info

PROCEDURE Initialize_Dist IS

  l_init_index  BINARY_INTEGER;

BEGIN

  for l_init_index in 1..g_pd_costs.Count loop
     g_pd_costs(l_init_index).ccid := null;
     g_pd_costs(l_init_index).element_type := null;
     g_pd_costs(l_init_index).element_set_id := null;
     g_pd_costs(l_init_index).budget_year_id := null;
     g_pd_costs(l_init_index).ytd_amount := null;
     g_pd_costs(l_init_index).period1_amount := null;
     g_pd_costs(l_init_index).period2_amount := null;
     g_pd_costs(l_init_index).period3_amount := null;
     g_pd_costs(l_init_index).period4_amount := null;
     g_pd_costs(l_init_index).period5_amount := null;
     g_pd_costs(l_init_index).period6_amount := null;
     g_pd_costs(l_init_index).period7_amount := null;
     g_pd_costs(l_init_index).period8_amount := null;
     g_pd_costs(l_init_index).period9_amount := null;
     g_pd_costs(l_init_index).period10_amount := null;
     g_pd_costs(l_init_index).period11_amount := null;
     g_pd_costs(l_init_index).period12_amount := null;
     g_pd_costs(l_init_index).period13_amount := null;
     g_pd_costs(l_init_index).period14_amount := null;
     g_pd_costs(l_init_index).period15_amount := null;
     g_pd_costs(l_init_index).period16_amount := null;
     g_pd_costs(l_init_index).period17_amount := null;
     g_pd_costs(l_init_index).period18_amount := null;
     g_pd_costs(l_init_index).period19_amount := null;
     g_pd_costs(l_init_index).period20_amount := null;
     g_pd_costs(l_init_index).period21_amount := null;
     g_pd_costs(l_init_index).period22_amount := null;
     g_pd_costs(l_init_index).period23_amount := null;
     g_pd_costs(l_init_index).period24_amount := null;
     g_pd_costs(l_init_index).period25_amount := null;
     g_pd_costs(l_init_index).period26_amount := null;
     g_pd_costs(l_init_index).period27_amount := null;
     g_pd_costs(l_init_index).period28_amount := null;
     g_pd_costs(l_init_index).period29_amount := null;
     g_pd_costs(l_init_index).period30_amount := null;
     g_pd_costs(l_init_index).period31_amount := null;
     g_pd_costs(l_init_index).period32_amount := null;
     g_pd_costs(l_init_index).period33_amount := null;
     g_pd_costs(l_init_index).period34_amount := null;
     g_pd_costs(l_init_index).period35_amount := null;
     g_pd_costs(l_init_index).period36_amount := null;
     g_pd_costs(l_init_index).period37_amount := null;
     g_pd_costs(l_init_index).period38_amount := null;
     g_pd_costs(l_init_index).period39_amount := null;
     g_pd_costs(l_init_index).period40_amount := null;
     g_pd_costs(l_init_index).period41_amount := null;
     g_pd_costs(l_init_index).period42_amount := null;
     g_pd_costs(l_init_index).period43_amount := null;
     g_pd_costs(l_init_index).period44_amount := null;
     g_pd_costs(l_init_index).period45_amount := null;
     g_pd_costs(l_init_index).period46_amount := null;
     g_pd_costs(l_init_index).period47_amount := null;
     g_pd_costs(l_init_index).period48_amount := null;
     g_pd_costs(l_init_index).period49_amount := null;
     g_pd_costs(l_init_index).period50_amount := null;
     g_pd_costs(l_init_index).period51_amount := null;
     g_pd_costs(l_init_index).period52_amount := null;
     g_pd_costs(l_init_index).period53_amount := null;
     g_pd_costs(l_init_index).period54_amount := null;
     g_pd_costs(l_init_index).period55_amount := null;
     g_pd_costs(l_init_index).period56_amount := null;
     g_pd_costs(l_init_index).period57_amount := null;
     g_pd_costs(l_init_index).period58_amount := null;
     g_pd_costs(l_init_index).period59_amount := null;
     g_pd_costs(l_init_index).period60_amount := null;
  end loop;

  g_num_pd_costs := 0;

END Initialize_Dist;

/* ----------------------------------------------------------------------- */

-- Initialize the PL/SQL Structures that temporarily store Position Salary
-- Distribution info

PROCEDURE Initialize_Salary_Dist IS

  l_init_index  BINARY_INTEGER;

BEGIN

  for l_init_index in 1..g_salary_dist.Count loop
    g_salary_dist(l_init_index).ccid := null;
    g_salary_dist(l_init_index).amount := null;
    g_salary_dist(l_init_index).percent := null;
    g_salary_dist(l_init_index).start_date := null;
    g_salary_dist(l_init_index).end_date := null;
  end loop;

  g_num_salary_dist := 0;

END Initialize_Salary_Dist;

/* ----------------------------------------------------------------------- */

-- Initialize the PL/SQL Structures that temporarily store Position Element
-- Distribution info. This is invoked by Redistribute_Follow_Salary

PROCEDURE Initialize_Element_Dist IS

  l_init_index  BINARY_INTEGER;

BEGIN

  for l_init_index in 1..g_element_dist.Count loop
     g_element_dist(l_init_index).account_line_id := null;
     g_element_dist(l_init_index).ccid := null;
     g_element_dist(l_init_index).ytd_amount := null;
     g_element_dist(l_init_index).period1_amount := null;
     g_element_dist(l_init_index).period2_amount := null;
     g_element_dist(l_init_index).period3_amount := null;
     g_element_dist(l_init_index).period4_amount := null;
     g_element_dist(l_init_index).period5_amount := null;
     g_element_dist(l_init_index).period6_amount := null;
     g_element_dist(l_init_index).period7_amount := null;
     g_element_dist(l_init_index).period8_amount := null;
     g_element_dist(l_init_index).period9_amount := null;
     g_element_dist(l_init_index).period10_amount := null;
     g_element_dist(l_init_index).period11_amount := null;
     g_element_dist(l_init_index).period12_amount := null;
     g_element_dist(l_init_index).period13_amount := null;
     g_element_dist(l_init_index).period14_amount := null;
     g_element_dist(l_init_index).period15_amount := null;
     g_element_dist(l_init_index).period16_amount := null;
     g_element_dist(l_init_index).period17_amount := null;
     g_element_dist(l_init_index).period18_amount := null;
     g_element_dist(l_init_index).period19_amount := null;
     g_element_dist(l_init_index).period20_amount := null;
     g_element_dist(l_init_index).period21_amount := null;
     g_element_dist(l_init_index).period22_amount := null;
     g_element_dist(l_init_index).period23_amount := null;
     g_element_dist(l_init_index).period24_amount := null;
     g_element_dist(l_init_index).period25_amount := null;
     g_element_dist(l_init_index).period26_amount := null;
     g_element_dist(l_init_index).period27_amount := null;
     g_element_dist(l_init_index).period28_amount := null;
     g_element_dist(l_init_index).period29_amount := null;
     g_element_dist(l_init_index).period30_amount := null;
     g_element_dist(l_init_index).period31_amount := null;
     g_element_dist(l_init_index).period32_amount := null;
     g_element_dist(l_init_index).period33_amount := null;
     g_element_dist(l_init_index).period34_amount := null;
     g_element_dist(l_init_index).period35_amount := null;
     g_element_dist(l_init_index).period36_amount := null;
     g_element_dist(l_init_index).period37_amount := null;
     g_element_dist(l_init_index).period38_amount := null;
     g_element_dist(l_init_index).period39_amount := null;
     g_element_dist(l_init_index).period40_amount := null;
     g_element_dist(l_init_index).period41_amount := null;
     g_element_dist(l_init_index).period42_amount := null;
     g_element_dist(l_init_index).period43_amount := null;
     g_element_dist(l_init_index).period44_amount := null;
     g_element_dist(l_init_index).period45_amount := null;
     g_element_dist(l_init_index).period46_amount := null;
     g_element_dist(l_init_index).period47_amount := null;
     g_element_dist(l_init_index).period48_amount := null;
     g_element_dist(l_init_index).period49_amount := null;
     g_element_dist(l_init_index).period50_amount := null;
     g_element_dist(l_init_index).period51_amount := null;
     g_element_dist(l_init_index).period52_amount := null;
     g_element_dist(l_init_index).period53_amount := null;
     g_element_dist(l_init_index).period54_amount := null;
     g_element_dist(l_init_index).period55_amount := null;
     g_element_dist(l_init_index).period56_amount := null;
     g_element_dist(l_init_index).period57_amount := null;
     g_element_dist(l_init_index).period58_amount := null;
     g_element_dist(l_init_index).period59_amount := null;
     g_element_dist(l_init_index).period60_amount := null;
     g_element_dist(l_init_index).redist_flag := null;
  end loop;

  g_num_element_dist := 0;

END Initialize_Element_Dist;

/* ----------------------------------------------------------------------- */

-- Check whether the Budget Group for a Position is allowed within a
-- Worksheet. This is invoked by the Worksheet Modification module when
-- creating new Positions

FUNCTION Check_Allowed
( p_api_version               IN  NUMBER,
  p_validation_level          IN  NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_worksheet_id              IN  NUMBER,
  p_position_budget_group_id  IN  NUMBER
) RETURN VARCHAR2 IS

  l_api_name                  CONSTANT VARCHAR2(30) := 'Check_Allowed';
  l_api_version               CONSTANT NUMBER       := 1.0;

  l_budget_calendar_id        NUMBER;
  l_budget_group_id           NUMBER;

  l_return_status             VARCHAR2(1) := FND_API.G_FALSE;

  cursor c_Allowed is
    select 'Valid'
      from PSB_BUDGET_GROUPS
     where budget_group_type = 'R'
       and effective_start_date <= PSB_WS_ACCT1.g_startdate_pp
       and (effective_end_date is null
	 or effective_end_date >= PSB_WS_ACCT1.g_enddate_cy)
       and budget_group_id = p_position_budget_group_id
    start with budget_group_id = l_budget_group_id
   connect by prior budget_group_id = parent_budget_group_id;

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  for c_WS_Rec in c_WS (p_worksheet_id) loop
    l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
    l_budget_group_id := c_WS_Rec.budget_group_id;
  end loop;

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

  for c_Allowed_Rec in c_Allowed loop
    l_return_status := FND_API.G_TRUE;
  end loop;

  return l_return_status;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     return FND_API.G_FALSE;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     return FND_API.G_FALSE;

   when OTHERS then
     return FND_API.G_FALSE;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Check_Allowed;

/* ----------------------------------------------------------------------- */

-- Cache all Elements for a Data Extract and Business Group that are valid
-- within the projection period for a Worksheet (specified by
-- PSB_WS_ACCT1.g_startdate_cy and PSB_WS_ACCT1.g_end_est_date)

PROCEDURE Cache_Elements
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_data_extract_id    IN   NUMBER,
  p_business_group_id  IN   NUMBER,
  p_worksheet_id       IN   NUMBER
) IS

  l_budget_calendar_id  NUMBER;

  l_init_index          BINARY_INTEGER;

  l_return_status       VARCHAR2(1);

  cursor c_Elements is
    select pay_element_id,
	   name,
	   processing_type,
	   max_element_value_type,
	   max_element_value,
	   option_flag,
	   overwrite_flag,
	   salary_flag,
	   salary_type,
	   follow_salary,
	   period_type,
	   process_period_type
      from PSB_PAY_ELEMENTS
     where (((start_date <= PSB_WS_ACCT1.g_end_est_date)
	 and (end_date is null))
	 or ((start_date between PSB_WS_ACCT1.g_startdate_cy and PSB_WS_ACCT1.g_end_est_date)
	  or (end_date between PSB_WS_ACCT1.g_startdate_cy and PSB_WS_ACCT1.g_end_est_date)
	 or ((start_date < PSB_WS_ACCT1.g_startdate_cy)
	 and (end_date > PSB_WS_ACCT1.g_end_est_date))))
       and business_group_id = p_business_group_id
       and data_extract_id = p_data_extract_id
     order by salary_flag desc,
	      pay_element_id;

BEGIN

  for l_init_index in 1..g_elements.Count loop
    g_elements(l_init_index).pay_element_id := null;
    g_elements(l_init_index).element_name := null;
    g_elements(l_init_index).processing_type := null;
    g_elements(l_init_index).max_element_value_type := null;
    g_elements(l_init_index).max_element_value := null;
    g_elements(l_init_index).salary_flag := null;
    g_elements(l_init_index).option_flag := null;
    g_elements(l_init_index).overwrite_flag := null;
    g_elements(l_init_index).salary_type := null;
    g_elements(l_init_index).follow_salary := null;
    g_elements(l_init_index).period_type := null;
    g_elements(l_init_index).process_period_type := null;
  end loop;

  g_num_elements := 0;

  if g_budget_calendar_id is null then
  begin

    for c_WS_Rec in c_WS (p_worksheet_id) loop
      l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
    end loop;

  end;
  end if;

  if g_budget_calendar_id is not null then
    l_budget_calendar_id := g_budget_calendar_id;
  end if;

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

  for c_Elements_Rec in c_Elements loop

    g_num_elements := g_num_elements + 1;

    g_elements(g_num_elements).pay_element_id := c_Elements_Rec.pay_element_id;
    g_elements(g_num_elements).element_name := c_Elements_Rec.name;
    g_elements(g_num_elements).processing_type := c_Elements_Rec.processing_type;
    g_elements(g_num_elements).max_element_value_type := c_Elements_Rec.max_element_value_type;
    g_elements(g_num_elements).max_element_value := c_Elements_Rec.max_element_value;
    g_elements(g_num_elements).option_flag := c_Elements_Rec.option_flag;
    g_elements(g_num_elements).overwrite_flag := c_Elements_Rec.overwrite_flag;
    g_elements(g_num_elements).salary_flag := c_Elements_Rec.salary_flag;
    g_elements(g_num_elements).salary_type := c_Elements_Rec.salary_type;
    g_elements(g_num_elements).follow_salary := c_Elements_Rec.follow_salary;
    g_elements(g_num_elements).period_type := c_Elements_Rec.period_type;
    g_elements(g_num_elements).process_period_type := c_Elements_Rec.process_period_type;
  end loop;

  g_data_extract_id := p_data_extract_id;
  g_business_group_id := p_business_group_id;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Cache_Elements;

/* ----------------------------------------------------------------------- */

-- Cache specific named attribute identifiers for a Business Group. These
-- attributes are used in the Worksheet Creation process

PROCEDURE Cache_Named_Attributes
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_business_group_id  IN   NUMBER
) IS

  cursor c_Attributes is
    select attribute_id               ,
	   system_attribute_type      ,
           NVL(value_table_flag, 'N') value_table_flag
      from PSB_ATTRIBUTES
     where system_attribute_type IN ('FTE', 'DEFAULT_WEEKLY_HOURS',
				     'HIREDATE', 'ADJUSTMENT_DATE')
       and business_group_id = p_business_group_id;

BEGIN

  for c_Attributes_Rec in c_Attributes loop

    if c_Attributes_Rec.system_attribute_type = 'FTE' then
      g_fte_id := c_Attributes_Rec.attribute_id;
    elsif c_Attributes_Rec.system_attribute_type = 'DEFAULT_WEEKLY_HOURS' then
      g_default_wklyhrs_id      := c_Attributes_Rec.attribute_id;
      g_default_wklyhrs_vt_flag := c_Attributes_Rec.value_table_flag;
    elsif c_Attributes_Rec.system_attribute_type = 'HIREDATE' then
      g_hiredate_id := c_Attributes_Rec.attribute_id;
    elsif c_Attributes_Rec.system_attribute_type = 'ADJUSTMENT_DATE' then
      g_adjdate_id := c_Attributes_Rec.attribute_id;
    end if;

  end loop;

  g_attr_busgrp_id := p_business_group_id;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Cache_Named_Attributes;

/* ----------------------------------------------------------------------- */

-- Cache Attribute Values for Hiredate and Adjustment Date for a Position

PROCEDURE Cache_Named_Attribute_Values
( p_return_status    OUT  NOCOPY  VARCHAR2,
  p_worksheet_id     IN   NUMBER,
  p_data_extract_id  IN   NUMBER,
  p_position_id      IN   NUMBER,
  /* start bug 4104890 */
  p_local_parameter_flag  IN   VARCHAR2 := 'N'
  /* End bug 4104890 */
) IS

  l_adjdate_value_id      NUMBER;
  l_hiredate_value_id     NUMBER;

  /* Bug 4075170 Start */
  l_param_info            VARCHAR2(4000);
  l_debug_info            VARCHAR2(4000);
  /* Bug 4075170 End */

  /*cursor c_Attributes is
    select attribute_id,
	   attribute_value,
	   attribute_value_id
      from PSB_POSITION_ASSIGNMENTS
     where attribute_id in (g_hiredate_id, g_adjdate_id)
       and worksheet_id is null
       and assignment_type = 'ATTRIBUTE'
       and position_id = p_position_id;*/

  /* start bug 4104890 */
  CURSOR c_Attributes
  IS
  SELECT attribute_id,
         attribute_value,
         attribute_value_id
    FROM PSB_POSITION_ASSIGNMENTS po1
   WHERE attribute_id IN (g_hiredate_id, g_adjdate_id)
     AND (    (worksheet_id = p_worksheet_id
          AND (p_local_parameter_flag = 'Y'))
         OR ( worksheet_id IS NULL
            AND ( (NOT EXISTS ( SELECT 1
                                  FROM psb_position_assignments po2
                                 WHERE po1.position_id = po2.position_id
                                   AND po1.attribute_id = po2.attribute_id
                                   AND   po2.worksheet_id = p_worksheet_id))
                                   OR (  p_local_parameter_flag = 'N'))))
     AND assignment_type = 'ATTRIBUTE'
     AND position_id = p_position_id;
   /* End bug 4104890 */


  cursor c_AttrVal is
    select attribute_value_id,
	   attribute_value
      from PSB_ATTRIBUTE_VALUES
     where attribute_value_id in (l_hiredate_value_id, l_adjdate_value_id);

BEGIN

  /* Bug 4075170 Start */
  l_param_info := 'WS_id::'||p_worksheet_id
                  ||', DE_id::'||p_data_extract_id
                  ||', Position_id::'||p_position_id;
  l_debug_info := 'Starting Cache_Named_Attribute_Values API';
  /* Bug 4075170 End */

  g_adjustment_date := null;
  g_hiredate := null;

  for c_Attributes_Rec in c_Attributes loop

    if c_Attributes_Rec.attribute_id = g_adjdate_id then
    begin
      g_adjustment_date := fnd_date.canonical_to_date(c_Attributes_Rec.attribute_value);
      l_adjdate_value_id := nvl(c_Attributes_Rec.attribute_value_id, 0);
    end;
    elsif c_Attributes_Rec.attribute_id = g_hiredate_id then
    begin
      g_hiredate := fnd_date.canonical_to_date(c_Attributes_Rec.attribute_value);
      l_hiredate_value_id := nvl(c_Attributes_Rec.attribute_value_id, 0);
    end;
    end if;

  end loop;

  if (((g_adjustment_date is null) and (l_adjdate_value_id <> 0)) or
      ((g_hiredate is null) and (l_hiredate_value_id <> 0))) then
  begin

    for c_AttrVal_Rec in c_AttrVal loop

      if c_AttrVal_Rec.attribute_value_id = l_adjdate_value_id then
	g_adjustment_date := fnd_date.canonical_to_date(c_AttrVal_Rec.attribute_value);
      elsif c_AttrVal_Rec.attribute_value_id = l_hiredate_value_id then
	g_hiredate := fnd_date.canonical_to_date(c_AttrVal_Rec.attribute_value);
      end if;

    end loop;

  end;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     /* Bug 4075170 Start */
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Last Status::>'||l_debug_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parameter Info::'||l_param_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error Type:: FND_API.G_EXC_ERROR');
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cache_Named_Attribute_Values API '
                                     ||'failed due to the following error');
     FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
     /* Bug 4075170 End */

     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     /* Bug 4075170 Start */
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Last Status::>'||l_debug_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parameter Info::'||l_param_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error Type:: FND_API.G_EXC_UNEXPECTED_ERROR');
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cache_Named_Attribute_Values API '
                                     ||'failed due to the following error');
     FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
     /* Bug 4075170 End */

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     /* Bug 4075170 Start */
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Last Status::>'||l_debug_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parameter Info::'||l_param_info);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error Type:: WHEN OTHERS');
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cache_Named_Attribute_Values API '
                                     ||'failed due to the following error');
     FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
     /* Bug 4075170 End */

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Cache_Named_Attribute_Values;

/* ----------------------------------------------------------------------- */

-- Return the conversion factor from the HRMS Period Type (p_hrms_period_type)
-- to the PSB Budget Period Type (p_budget_period_type)

PROCEDURE HRMS_Factor
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_hrms_period_type    IN   VARCHAR2,
  p_budget_period_type  IN   VARCHAR2,
  p_position_name       IN   VARCHAR2,
  p_element_name        IN   VARCHAR2,
  p_start_date          IN   DATE,
  p_end_date            IN   DATE,
  p_factor              OUT  NOCOPY  NUMBER
) IS

  l_factor              NUMBER;

  cursor c_Factor is
    select factor
      from PSB_HRMS_FACTORS
     where hrms_period_type = p_hrms_period_type
       and budget_period_type = p_budget_period_type;

BEGIN

  for c_Factor_Rec in c_Factor loop
    l_factor := c_Factor_Rec.factor;
  end loop;

  if l_factor is null then
    message_token('HRMS_PERIOD', p_hrms_period_type);
    message_token('PSB_PERIOD', p_budget_period_type);
    message_token('POSITION', p_position_name);
    message_token('ELEMENT', p_element_name);
    message_token('START_DATE', p_start_date);
    message_token('END_DATE', p_end_date);
    add_message('PSB', 'PSB_FACTOR_NOT_DEFINED');
    raise FND_API.G_EXC_ERROR;
  end if;

  p_factor := l_factor;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END HRMS_Factor;

/* ----------------------------------------------------------------------- */

-- Cache Salary Distribution for a Position for specific date range

PROCEDURE Cache_Salary_Dist
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id          IN   NUMBER,
  p_root_budget_group_id  IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_flex_code             IN   NUMBER,
  p_position_id           IN   NUMBER,
  p_position_name         IN   VARCHAR2,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE
) IS

  l_saldist_found         BOOLEAN := FALSE;
  l_budget_group_found    BOOLEAN := FALSE;

  l_concat_segments       VARCHAR2(2000);

  l_init_index            BINARY_INTEGER;

  l_return_status         VARCHAR2(1);

 /*bug:5261798:Modified query to fetch DE records only when there is not even a single distribution
   record at worksheet level */

  cursor c_WSDist is
    select code_combination_id,
	   distribution_percent,
	   effective_start_date,
	   effective_end_date
      from PSB_POSITION_PAY_DISTRIBUTIONS a
     where position_id = p_position_id
       and chart_of_accounts_id = p_flex_code
       and code_combination_id is not null
       and ((worksheet_id = p_worksheet_id) or (worksheet_id is null
       and not exists
	   (select 1
	      from psb_position_pay_distributions c
	     where  c.position_id = a.position_id
	     and c.chart_of_accounts_id = p_flex_code
	     and c.code_combination_id is not null
	     and c.worksheet_id = p_worksheet_id
	   )))
       -- commented for bug 3216145
       -- if there exists worksheet specific records
       -- pick up the data
       /*
       and (((p_end_date is not null)
	 and (((effective_start_date <= p_end_date)
	   and (effective_end_date is null))
	   or ((effective_start_date between p_start_date and p_end_date)
	   or (effective_end_date between p_start_date and p_end_date)
	   or ((effective_start_date < p_start_date)
	   and (effective_end_date > p_end_date)))))
	or ((p_end_date is null)
	and (nvl(effective_end_date, p_start_date) >= p_start_date))) */

     order by distribution_percent desc;
/* Bug No 2782604 End */

 /*bug:5261798:Modified query to fetch DE records only when there is not even a single distribution
   record at worksheet level */

  cursor c_Dist is
    select code_combination_id,
	   distribution_percent,
	   effective_start_date,
	   effective_end_date
      from PSB_POSITION_PAY_DISTRIBUTIONS a
     where code_combination_id is not null
/* Bug No 2747205 Start */
       and chart_of_accounts_id = p_flex_code
       and (worksheet_id is null
       and not exists
	   (select 1
	      from psb_position_pay_distributions c
	     where c.position_id = a.position_id
	     and c.chart_of_accounts_id = p_flex_code
	     and c.code_combination_id is null
	     and c.worksheet_id = p_worksheet_id
	   ))
--       and worksheet_id is null
--       and chart_of_accounts_id = p_flex_code
--       and (((p_end_date is not null)
--	 and (((effective_start_date <= p_end_date)
--	   and (effective_end_date is null))
--	   or ((effective_start_date between p_start_date and p_end_date)
--	   or (effective_end_date between p_start_date and p_end_date)
--	   or ((effective_start_date < p_start_date)
--	   and (effective_end_date > p_end_date)))))
--	or ((p_end_date is null)
--	and (nvl(effective_end_date, p_start_date) >= p_start_date)))
/* Bug No 2747205 End */
       and position_id = p_position_id
     order by distribution_percent desc;

  cursor c_Budget_Group (CCID NUMBER) is
    select a.budget_group_id,
	   b.num_proposed_years
      from PSB_SET_RELATIONS a,
	   PSB_BUDGET_GROUPS b,
	   PSB_BUDGET_ACCOUNTS c
     where a.budget_group_id = b.budget_group_id
       and b.effective_start_date <= PSB_WS_ACCT1.g_startdate_pp
       and (b.effective_end_date is null
	 or b.effective_end_date >= PSB_WS_ACCT1.g_enddate_cy)
       and b.budget_group_type = 'R'
       and ((b.budget_group_id = p_root_budget_group_id) or
	    (b.root_budget_group_id = p_root_budget_group_id))
       and a.account_position_set_id = c.account_position_set_id
       and c.code_combination_id = CCID;

BEGIN

  Initialize_Salary_Dist;

  for c_Dist_Rec in c_WSDist loop

    l_saldist_found := TRUE;

    if nvl(g_salary_budget_group_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
    begin

      for c_Budget_Group_Rec in c_Budget_Group (c_Dist_Rec.code_combination_id) loop
	g_salary_budget_group_id := c_Budget_Group_Rec.budget_group_id;
	g_budget_group_numyrs := c_Budget_Group_Rec.num_proposed_years;
	l_budget_group_found := TRUE;
      end loop;

      -- Budget Group for a Position is the Budget Group assigned to the CCID with
      -- the maximum distribution percentage

      if not l_budget_group_found then
      begin

	l_concat_segments := FND_FLEX_EXT.Get_Segs
				(application_short_name => 'SQLGL',
				 key_flex_code => 'GL#',
				 structure_number => p_flex_code,
				 combination_id => c_Dist_Rec.code_combination_id);

	message_token('CCID', l_concat_segments);
	message_token('POSITION', p_position_name);
	add_message('PSB', 'PSB_CANNOT_ASSIGN_BUDGET_GROUP');
	raise FND_API.G_EXC_ERROR;

      end;
      end if;

    end;
    end if;

    g_num_salary_dist := g_num_salary_dist + 1;

    g_salary_dist(g_num_salary_dist).ccid := c_Dist_Rec.code_combination_id;
    g_salary_dist(g_num_salary_dist).percent := c_Dist_Rec.distribution_percent;
    g_salary_dist(g_num_salary_dist).start_date := c_Dist_Rec.effective_start_date;
    g_salary_dist(g_num_salary_dist).end_date := c_Dist_Rec.effective_end_date;

  end loop;

  if not l_saldist_found then
  begin

    for c_Dist_Rec in c_Dist loop

      l_saldist_found := TRUE;

      if nvl(g_salary_budget_group_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
      begin

	for c_Budget_Group_Rec in c_Budget_Group (c_Dist_Rec.code_combination_id) loop
	  g_salary_budget_group_id := c_Budget_Group_Rec.budget_group_id;
	  g_budget_group_numyrs := c_Budget_Group_Rec.num_proposed_years;
	  l_budget_group_found := TRUE;
	end loop;

	-- Budget Group for a Position is the Budget Group assigned to the CCID with
	-- the maximum distribution percentage

	if not l_budget_group_found then
	begin

	  l_concat_segments := FND_FLEX_EXT.Get_Segs
				  (application_short_name => 'SQLGL',
				   key_flex_code => 'GL#',
				   structure_number => p_flex_code,
				   combination_id => c_Dist_Rec.code_combination_id);

	  message_token('CCID', l_concat_segments);
	  message_token('POSITION', p_position_name);
	  add_message('PSB', 'PSB_CANNOT_ASSIGN_BUDGET_GROUP');
	  raise FND_API.G_EXC_ERROR;

	end;
	end if;

      end;
      end if;

      g_num_salary_dist := g_num_salary_dist + 1;

      g_salary_dist(g_num_salary_dist).ccid := c_Dist_Rec.code_combination_id;
      g_salary_dist(g_num_salary_dist).percent := c_Dist_Rec.distribution_percent;
      g_salary_dist(g_num_salary_dist).start_date := c_Dist_Rec.effective_start_date;
      g_salary_dist(g_num_salary_dist).end_date := c_Dist_Rec.effective_end_date;

    end loop;

  end;
  end if;

  -- If Salary Distribution is not found return an error. Salary Distribution is
  -- needed to create a Worksheet specific instance of a Position (identified by
  -- position_line_id)

  if not l_saldist_found then
    message_token('POSITION', p_position_name);
    message_token('START_DATE', p_start_date);
    message_token('END_DATE', p_end_date);
    add_message('PSB', 'PSB_NO_SALARY_DISTRIBUTION');
    raise FND_API.G_EXC_ERROR;
  end if;

  if p_flex_code <> nvl(PSB_WS_ACCT1.g_flex_code, FND_API.G_MISS_NUM) then
  begin

    PSB_WS_ACCT1.Flex_Info
       (p_flex_code => p_flex_code,
	p_return_status => l_return_status);

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

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Cache_Salary_Dist;

/* ----------------------------------------------------------------------- */

-- Create Worksheet specific instance of a Position. A unique Position Line
-- ID is created for a Position for every Global Worksheet and Local Copy
-- of a Worksheet. This also creates an entry in the Position Matrix table
-- (PSB_WS_LINES_POSITIONS) for the current Worksheet. Entries for the Parent
-- Worksheets, for Distributed Worksheets, must be created using the
-- Worksheet Operations APIs

PROCEDURE Create_Position_Lines
( p_api_version               IN   NUMBER,
  p_validation_level          IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_position_line_id          OUT  NOCOPY  NUMBER,
  p_worksheet_id              IN   NUMBER,
  p_position_id               IN   NUMBER,
  p_budget_group_id           IN   NUMBER,
  p_copy_of_position_line_id  IN   NUMBER := FND_API.G_MISS_NUM
) IS

  l_api_name                  CONSTANT VARCHAR2(30)   := 'Create_Position_Lines';
  l_api_version               CONSTANT NUMBER         := 1.0;

  l_userid                    NUMBER;
  l_loginid                   NUMBER;

  l_instance_exists           VARCHAR2(1) := FND_API.G_FALSE;

  l_poslineid                 NUMBER;
  l_budget_group_id           NUMBER;

  l_return_status             VARCHAR2(1);

  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);

  cursor c_PosLine is
    select b.position_line_id,
	   b.budget_group_id
      from PSB_WS_LINES_POSITIONS a,
	   PSB_WS_POSITION_LINES b
     where a.position_line_id = b.position_line_id
       and a.worksheet_id = g_global_worksheet_id
       and b.position_id = p_position_id;

  cursor c_Seq is
    select psb_ws_position_lines_s.nextval PosLineID
      from dual;

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  l_userid := FND_GLOBAL.USER_ID;
  l_loginid := FND_GLOBAL.LOGIN_ID;

  if g_global_worksheet_id is null
     or g_budget_calendar_id is null  --bug:8235347:added the condition
  then
  begin

    for c_WS_Rec in c_WS (p_worksheet_id) loop

      g_local_copy_flag := c_WS_Rec.local_copy_flag;

      if c_WS_Rec.local_copy_flag = 'Y' then
	g_global_worksheet_id := p_worksheet_id;
      else
	g_global_worksheet_id := c_WS_Rec.global_worksheet_id;
      end if;

      g_budget_calendar_id := c_WS_Rec.budget_calendar_id;

    end loop;

  end;
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

  for c_PosLine_Rec in c_PosLine loop
    l_poslineid := c_PosLine_Rec.position_line_id;
    l_budget_group_id := c_PosLine_Rec.budget_group_id;
    l_instance_exists := FND_API.G_TRUE;
  end loop;

  if FND_API.to_Boolean(l_instance_exists) then
  begin

    if p_budget_group_id <> l_budget_group_id then
    begin

      update PSB_WS_POSITION_LINES
	 set budget_group_id = p_budget_group_id,
	     copy_of_position_line_id = decode(p_copy_of_position_line_id, FND_API.G_MISS_NUM, null, p_copy_of_position_line_id),
	     last_update_date = sysdate,
	     last_updated_by = l_userid,
	     last_update_login = l_loginid
       where position_line_id = l_poslineid;

      delete from PSB_WS_LINES_POSITIONS
       where position_line_id = l_poslineid;

      if g_local_copy_flag = 'Y' then
      begin

	Create_Position_Matrix
	      (p_api_version => 1.0,
	       p_return_status => l_return_status,
	       p_worksheet_id => p_worksheet_id,
	       p_position_line_id => l_poslineid);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      else
      begin

	for c_Distribute_WS_Rec in PSB_WS_ACCT1.c_Distribute_WS (g_global_worksheet_id,
								 p_budget_group_id,
								 PSB_WS_ACCT1.g_startdate_pp,
								 PSB_WS_ACCT1.g_enddate_cy) loop

	  Create_Position_Matrix
		(p_api_version => 1.0,
		 p_return_status => l_return_status,
		 p_worksheet_id => c_Distribute_WS_Rec.worksheet_id,
		 p_position_line_id => l_poslineid);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end loop;

      end;
      end if;

    end;
    end if;

  end;
  else
  begin

    for c_Seq_Rec in c_Seq loop
      l_poslineid := c_Seq_Rec.PosLineID;
    end loop;

    insert into PSB_WS_POSITION_LINES
	  (position_line_id,
	   position_id,
	   budget_group_id,
	   copy_of_position_line_id,
	   last_update_date,
	   last_updated_by,
	   last_update_login,
	   created_by,
	   creation_date)
   values (l_poslineid,
	   p_position_id,
	   p_budget_group_id,
	   decode(p_copy_of_position_line_id, FND_API.G_MISS_NUM, null, p_copy_of_position_line_id),
	   sysdate,
	   l_userid,
	   l_loginid,
	   l_userid,
	   sysdate);

    if g_local_copy_flag = 'Y' then
    begin

      Create_Position_Matrix
	    (p_api_version => 1.0,
	     p_return_status => l_return_status,
	     p_worksheet_id => p_worksheet_id,
	     p_position_line_id => l_poslineid);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    else
    begin

      for c_Distribute_WS_Rec in PSB_WS_ACCT1.c_Distribute_WS (g_global_worksheet_id,
							       p_budget_group_id,
							       PSB_WS_ACCT1.g_startdate_pp,
							       PSB_WS_ACCT1.g_enddate_cy) loop

	Create_Position_Matrix
	      (p_api_version => 1.0,
	       p_return_status => l_return_status,
	       p_worksheet_id => c_Distribute_WS_Rec.worksheet_id,
	       p_position_line_id => l_poslineid);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end loop;

    end;
    end if;

  end;
  end if;

  p_position_line_id := l_poslineid;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data  => l_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);

END Create_Position_Lines;

/* ----------------------------------------------------------------------- */

-- Create or Update entries in the Position Matrix table
-- (PSB_WS_LINES_POSITIONS)

PROCEDURE Create_Position_Matrix
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_position_line_id  IN   NUMBER,
  p_freeze_flag       IN   VARCHAR2 := FND_API.G_FALSE,
  p_view_line_flag    IN   VARCHAR2 := FND_API.G_TRUE
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Create_Position_Matrix';
  l_api_version       CONSTANT NUMBER         := 1.0;

  l_userid            NUMBER;
  l_loginid           NUMBER;

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  l_userid := FND_GLOBAL.USER_ID;
  l_loginid := FND_GLOBAL.LOGIN_ID;

  update PSB_WS_LINES_POSITIONS
     set freeze_flag = decode(p_freeze_flag, FND_API.G_FALSE, null, FND_API.G_TRUE, 'Y', p_freeze_flag),
	 view_line_flag = decode(p_view_line_flag, FND_API.G_TRUE, 'Y', FND_API.G_FALSE, null, p_view_line_flag),
	 last_update_date = sysdate,
	 last_updated_by = l_userid,
	 last_update_login = l_loginid
   where position_line_id = p_position_line_id
     and worksheet_id = p_worksheet_id;

  if SQL%NOTFOUND then
  begin

    insert into PSB_WS_LINES_POSITIONS
	  (worksheet_id,
	   position_line_id,
	   freeze_flag,
	   view_line_flag,
	   last_update_date,
	   last_updated_by,
	   last_update_login,
	   created_by,
	   creation_date)
     values
	  (p_worksheet_id,
	   p_position_line_id,
	   decode(p_freeze_flag, FND_API.G_FALSE, null, FND_API.G_TRUE, 'Y', p_freeze_flag),
	   decode(p_view_line_flag, FND_API.G_TRUE, 'Y', FND_API.G_FALSE, null, p_view_line_flag),
	   sysdate,
	   l_userid,
	   l_loginid,
	   l_userid,
	   sysdate);

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
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Create_Position_Matrix;

/* ----------------------------------------------------------------------- */

-- Set p_recalculate_flag to true when manually creating new FTE/SP entries
-- (from the Modify Worksheet module - Form, Spreadsheet or OFA).
-- If new FTE/SP entry overlaps with existing entry for same SP, the Element
-- Costs, Annual FTE, Account Distributions for the existing entry are prorated
-- to reflect the new entry. If FTE/SP entry does not overlap with any existing
-- entry, new Element Costs, Annual FTE, Account Distributions are created by
-- prorating the entries for the base SP
-- Proration of Element Costs and Account Distributions are done only for
-- recurring Elements since non-recurring Elements are by definition independent
-- of FTE

PROCEDURE Create_FTE_Lines
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_fte_line_id         OUT  NOCOPY  NUMBER,
  p_check_spfl_exists   IN   VARCHAR2 := FND_API.G_TRUE,
  p_recalculate_flag    IN   VARCHAR2 := FND_API.G_FALSE,
  p_worksheet_id        IN   NUMBER,
  p_flex_mapping_set_id IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_line_id    IN   NUMBER,
  p_budget_year_id      IN   NUMBER,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_annual_fte          IN   NUMBER := FND_API.G_MISS_NUM,
  p_service_package_id  IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_start_stage_seq     IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq   IN   NUMBER,
  p_end_stage_seq       IN   NUMBER := FND_API.G_MISS_NUM,
  p_period_fte          IN   PSB_WS_ACCT1.g_prdamt_tbl_type
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Create_FTE_Lines';
  l_api_version         CONSTANT NUMBER         := 1.0;

  l_userid              NUMBER;
  l_loginid             NUMBER;

  l_budget_calendar_id  NUMBER;
  l_budget_group_id     NUMBER;
  l_rounding_factor     NUMBER;
  l_data_extract_id     NUMBER;

  l_business_group_id   NUMBER;

  l_num_budget_periods  NUMBER;

  l_ftelineid           NUMBER;

  l_fte                 NUMBER;
  l_period_fte          PSB_WS_ACCT1.g_prdamt_tbl_type;
  l_annual_fte          NUMBER;
  /*For Bug No : 2811698 Start*/
  l_total_fte           NUMBER := 0;
  /*For Bug No : 2811698 End*/

  l_spflid              NUMBER;
  l_spfte               PSB_WS_ACCT1.g_prdamt_tbl_type;
  l_spannual_fte        NUMBER;
  l_spfl_exists         VARCHAR2(1) := FND_API.G_FALSE;

  l_global_wsid         NUMBER;
  l_base_spid           NUMBER;

  l_start_stage_seq     NUMBER;

  l_year_index          BINARY_INTEGER;
  l_index               BINARY_INTEGER;

  l_return_status       VARCHAR2(1);
  l_msg_data            VARCHAR2(2000);
  l_msg_count           NUMBER;

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  l_userid := FND_GLOBAL.USER_ID;
  l_loginid := FND_GLOBAL.LOGIN_ID;

  --Total cost would be the sum of all the periods
  /*For Bug No : 2811698 Start*/
  for l_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
    l_total_fte := l_total_fte + nvl(p_period_fte(l_index),0);
  end loop;
  /*For Bug No : 2811698 End*/

  if p_start_stage_seq = FND_API.G_MISS_NUM then
    l_start_stage_seq := p_current_stage_seq;
  else
    l_start_stage_seq := p_start_stage_seq;
  end if;

  if FND_API.to_Boolean(p_check_spfl_exists) then
  begin

    -- For a Service Package overlap try to identify the target FTE Line

    for c_Wfl_Rec in c_Wfl_SP (p_position_line_id, p_budget_year_id, p_service_package_id,
			       p_stage_set_id, p_current_stage_seq) loop

      l_spflid := c_Wfl_Rec.fte_line_id;
      l_spfte(1) := c_Wfl_Rec.period1_fte; l_spfte(2) := c_Wfl_Rec.period2_fte;
      l_spfte(3) := c_Wfl_Rec.period3_fte; l_spfte(4) := c_Wfl_Rec.period4_fte;
      l_spfte(5) := c_Wfl_Rec.period5_fte; l_spfte(6) := c_Wfl_Rec.period6_fte;
      l_spfte(7) := c_Wfl_Rec.period7_fte; l_spfte(8) := c_Wfl_Rec.period8_fte;
      l_spfte(9) := c_Wfl_Rec.period9_fte; l_spfte(10) := c_Wfl_Rec.period10_fte;
      l_spfte(11) := c_Wfl_Rec.period11_fte; l_spfte(12) := c_Wfl_Rec.period12_fte;
      l_spfte(13) := c_Wfl_Rec.period13_fte; l_spfte(14) := c_Wfl_Rec.period14_fte;
      l_spfte(15) := c_Wfl_Rec.period15_fte; l_spfte(16) := c_Wfl_Rec.period16_fte;
      l_spfte(17) := c_Wfl_Rec.period17_fte; l_spfte(18) := c_Wfl_Rec.period18_fte;
      l_spfte(19) := c_Wfl_Rec.period19_fte; l_spfte(20) := c_Wfl_Rec.period20_fte;
      l_spfte(21) := c_Wfl_Rec.period21_fte; l_spfte(22) := c_Wfl_Rec.period22_fte;
      l_spfte(23) := c_Wfl_Rec.period23_fte; l_spfte(24) := c_Wfl_Rec.period24_fte;
      l_spfte(25) := c_Wfl_Rec.period25_fte; l_spfte(26) := c_Wfl_Rec.period26_fte;
      l_spfte(27) := c_Wfl_Rec.period27_fte; l_spfte(28) := c_Wfl_Rec.period28_fte;
      l_spfte(29) := c_Wfl_Rec.period29_fte; l_spfte(30) := c_Wfl_Rec.period30_fte;
      l_spfte(31) := c_Wfl_Rec.period31_fte; l_spfte(32) := c_Wfl_Rec.period32_fte;
      l_spfte(33) := c_Wfl_Rec.period33_fte; l_spfte(34) := c_Wfl_Rec.period34_fte;
      l_spfte(35) := c_Wfl_Rec.period35_fte; l_spfte(36) := c_Wfl_Rec.period36_fte;
      l_spfte(37) := c_Wfl_Rec.period37_fte; l_spfte(38) := c_Wfl_Rec.period38_fte;
      l_spfte(39) := c_Wfl_Rec.period39_fte; l_spfte(40) := c_Wfl_Rec.period40_fte;
      l_spfte(41) := c_Wfl_Rec.period41_fte; l_spfte(42) := c_Wfl_Rec.period42_fte;
      l_spfte(43) := c_Wfl_Rec.period43_fte; l_spfte(44) := c_Wfl_Rec.period44_fte;
      l_spfte(45) := c_Wfl_Rec.period45_fte; l_spfte(46) := c_Wfl_Rec.period46_fte;
      l_spfte(47) := c_Wfl_Rec.period47_fte; l_spfte(48) := c_Wfl_Rec.period48_fte;
      l_spfte(49) := c_Wfl_Rec.period49_fte; l_spfte(50) := c_Wfl_Rec.period50_fte;
      l_spfte(51) := c_Wfl_Rec.period51_fte; l_spfte(52) := c_Wfl_Rec.period52_fte;
      l_spfte(53) := c_Wfl_Rec.period53_fte; l_spfte(54) := c_Wfl_Rec.period54_fte;
      l_spfte(55) := c_Wfl_Rec.period55_fte; l_spfte(56) := c_Wfl_Rec.period56_fte;
      l_spfte(57) := c_Wfl_Rec.period57_fte; l_spfte(58) := c_Wfl_Rec.period58_fte;
      l_spfte(59) := c_Wfl_Rec.period59_fte; l_spfte(60) := c_Wfl_Rec.period60_fte;
      l_spannual_fte := c_Wfl_Rec.annual_fte;

      l_spfl_exists := FND_API.G_TRUE;

    end loop;

  end;
  end if;

  if ((p_annual_fte = FND_API.G_MISS_NUM) or
      (FND_API.to_Boolean(l_spfl_exists)) or
      (FND_API.to_Boolean(p_recalculate_flag))) then
  begin

    for c_WS_Rec in c_WS (p_worksheet_id) loop
      l_global_wsid := c_WS_Rec.global_worksheet_id;
      l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
      l_budget_group_id := c_WS_Rec.budget_group_id;
      l_rounding_factor := c_WS_Rec.rounding_factor;
      l_data_extract_id := c_WS_Rec.data_extract_id;
    end loop;

    for c_BG_Rec in c_BG (l_budget_group_id) loop
      l_business_group_id := c_BG_Rec.business_group_id;
    end loop;

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

    for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

      -- Find number of Budget Periods in the Budget Year : this is used to compute the Annual FTE

      if PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id = p_budget_year_id then
	l_num_budget_periods := PSB_WS_ACCT1.g_budget_years(l_year_index).num_budget_periods;
      end if;

    end loop;

  end;
  end if;

  -- Annual FTE is computed by summing up the Period FTEs and dividing by the number of
  -- budget periods in the Budget Year

  l_annual_fte := 0;

  for l_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop

    if FND_API.to_Boolean(l_spfl_exists) then
    begin

      l_fte := nvl(p_period_fte(l_index), 0) + nvl(l_spfte(l_index), 0);

    end;
    else
      l_fte := nvl(p_period_fte(l_index), 0);
    end if;

    if l_fte = 0 then
      l_period_fte(l_index) := null;
    else
      l_period_fte(l_index) := l_fte;
    end if;

    l_annual_fte := l_annual_fte + l_fte;

  end loop;

  if p_annual_fte <> FND_API.G_MISS_NUM then
    l_annual_fte := p_annual_fte;
  else
  begin

    if l_num_budget_periods <> 0 then
      l_annual_fte := l_annual_fte / l_num_budget_periods;
    end if;

  end;
  end if;

  if FND_API.to_Boolean(l_spfl_exists) then
  begin

    update PSB_WS_FTE_LINES
       set period1_fte = l_period_fte(1), period2_fte = l_period_fte(2),
	   period3_fte = l_period_fte(3), period4_fte = l_period_fte(4),
	   period5_fte = l_period_fte(5), period6_fte = l_period_fte(6),
	   period7_fte = l_period_fte(7), period8_fte = l_period_fte(8),
	   period9_fte = l_period_fte(9), period10_fte = l_period_fte(10),
	   period11_fte = l_period_fte(11), period12_fte = l_period_fte(12),
	   period13_fte = l_period_fte(13), period14_fte = l_period_fte(14),
	   period15_fte = l_period_fte(15), period16_fte = l_period_fte(16),
	   period17_fte = l_period_fte(17), period18_fte = l_period_fte(18),
	   period19_fte = l_period_fte(19), period20_fte = l_period_fte(20),
	   period21_fte = l_period_fte(21), period22_fte = l_period_fte(22),
	   period23_fte = l_period_fte(23), period24_fte = l_period_fte(24),
	   period25_fte = l_period_fte(25), period26_fte = l_period_fte(26),
	   period27_fte = l_period_fte(27), period28_fte = l_period_fte(28),
	   period29_fte = l_period_fte(29), period30_fte = l_period_fte(30),
	   period31_fte = l_period_fte(31), period32_fte = l_period_fte(32),
	   period33_fte = l_period_fte(33), period34_fte = l_period_fte(34),
	   period35_fte = l_period_fte(35), period36_fte = l_period_fte(36),
	   period37_fte = l_period_fte(37), period38_fte = l_period_fte(38),
	   period39_fte = l_period_fte(39), period40_fte = l_period_fte(40),
	   period41_fte = l_period_fte(41), period42_fte = l_period_fte(42),
	   period43_fte = l_period_fte(43), period44_fte = l_period_fte(44),
	   period45_fte = l_period_fte(45), period46_fte = l_period_fte(46),
	   period47_fte = l_period_fte(47), period48_fte = l_period_fte(48),
	   period49_fte = l_period_fte(49), period50_fte = l_period_fte(50),
	   period51_fte = l_period_fte(51), period52_fte = l_period_fte(52),
	   period53_fte = l_period_fte(53), period54_fte = l_period_fte(54),
	   period55_fte = l_period_fte(55), period56_fte = l_period_fte(56),
	   period57_fte = l_period_fte(57), period58_fte = l_period_fte(58),
	   period59_fte = l_period_fte(59), period60_fte = l_period_fte(60),
	   end_stage_seq = decode(p_end_stage_seq, FND_API.G_MISS_NUM, end_stage_seq, p_end_stage_seq),
	   annual_fte = l_annual_fte,
	   last_update_date = sysdate,
	   last_updated_by = l_userid,
	   last_update_login = l_loginid
     where fte_line_id = l_spflid;

  end;
  else
  begin

    update PSB_WS_FTE_LINES
       set period1_fte = l_period_fte(1), period2_fte = l_period_fte(2),
	   period3_fte = l_period_fte(3), period4_fte = l_period_fte(4),
	   period5_fte = l_period_fte(5), period6_fte = l_period_fte(6),
	   period7_fte = l_period_fte(7), period8_fte = l_period_fte(8),
	   period9_fte = l_period_fte(9), period10_fte = l_period_fte(10),
	   period11_fte = l_period_fte(11), period12_fte = l_period_fte(12),
	   period13_fte = l_period_fte(13), period14_fte = l_period_fte(14),
	   period15_fte = l_period_fte(15), period16_fte = l_period_fte(16),
	   period17_fte = l_period_fte(17), period18_fte = l_period_fte(18),
	   period19_fte = l_period_fte(19), period20_fte = l_period_fte(20),
	   period21_fte = l_period_fte(21), period22_fte = l_period_fte(22),
	   period23_fte = l_period_fte(23), period24_fte = l_period_fte(24),
	   period25_fte = l_period_fte(25), period26_fte = l_period_fte(26),
	   period27_fte = l_period_fte(27), period28_fte = l_period_fte(28),
	   period29_fte = l_period_fte(29), period30_fte = l_period_fte(30),
	   period31_fte = l_period_fte(31), period32_fte = l_period_fte(32),
	   period33_fte = l_period_fte(33), period34_fte = l_period_fte(34),
	   period35_fte = l_period_fte(35), period36_fte = l_period_fte(36),
	   period37_fte = l_period_fte(37), period38_fte = l_period_fte(38),
	   period39_fte = l_period_fte(39), period40_fte = l_period_fte(40),
	   period41_fte = l_period_fte(41), period42_fte = l_period_fte(42),
	   period43_fte = l_period_fte(43), period44_fte = l_period_fte(44),
	   period45_fte = l_period_fte(45), period46_fte = l_period_fte(46),
	   period47_fte = l_period_fte(47), period48_fte = l_period_fte(48),
	   period49_fte = l_period_fte(49), period50_fte = l_period_fte(50),
	   period51_fte = l_period_fte(51), period52_fte = l_period_fte(52),
	   period53_fte = l_period_fte(53), period54_fte = l_period_fte(54),
	   period55_fte = l_period_fte(55), period56_fte = l_period_fte(56),
	   period57_fte = l_period_fte(57), period58_fte = l_period_fte(58),
	   period59_fte = l_period_fte(59), period60_fte = l_period_fte(60),
	   end_stage_seq = decode(p_end_stage_seq, FND_API.G_MISS_NUM, end_stage_seq, p_end_stage_seq),
	   annual_fte = l_annual_fte,
	   last_update_date = sysdate,
	   last_updated_by = l_userid,
	   last_update_login = l_loginid
     where p_current_stage_seq between start_stage_seq and current_stage_seq
       and stage_set_id = p_stage_set_id
       and service_package_id = p_service_package_id
       and budget_year_id = p_budget_year_id
       and position_line_id = p_position_line_id;

  end;
  end if;

  if SQL%NOTFOUND then
  begin

    for c_FTESeq_Rec in c_FTESeq loop
      l_ftelineid := c_FTESeq_Rec.FTELineID;
    end loop;

    for l_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop

      l_fte := nvl(p_period_fte(l_index), 0);

      if l_fte = 0 then
	    l_period_fte(l_index) := null;
      else
	    l_period_fte(l_index) := l_fte;
      end if;

    end loop;

    insert into PSB_WS_FTE_LINES
	  (fte_line_id,
	   position_line_id,
	   budget_year_id,
	   service_package_id,
	   stage_set_id,
	   start_stage_seq,
	   current_stage_seq,
	   end_stage_seq,
	   period1_fte, period2_fte, period3_fte, period4_fte,
	   period5_fte, period6_fte, period7_fte, period8_fte,
	   period9_fte, period10_fte, period11_fte, period12_fte,
	   period13_fte, period14_fte, period15_fte, period16_fte,
	   period17_fte, period18_fte, period19_fte, period20_fte,
	   period21_fte, period22_fte, period23_fte, period24_fte,
	   period25_fte, period26_fte, period27_fte, period28_fte,
	   period29_fte, period30_fte, period31_fte, period32_fte,
	   period33_fte, period34_fte, period35_fte, period36_fte,
	   period37_fte, period38_fte, period39_fte, period40_fte,
	   period41_fte, period42_fte, period43_fte, period44_fte,
	   period45_fte, period46_fte, period47_fte, period48_fte,
	   period49_fte, period50_fte, period51_fte, period52_fte,
	   period53_fte, period54_fte, period55_fte, period56_fte,
	   period57_fte, period58_fte, period59_fte, period60_fte,
	   annual_fte,
	   last_update_date,
	   last_updated_by,
	   last_update_login,
	   created_by,
	   creation_date)
   values (l_ftelineid,
	   p_position_line_id,
	   p_budget_year_id,
	   p_service_package_id,
	   p_stage_set_id,
	   l_start_stage_seq,
	   p_current_stage_seq,
	   decode(p_end_stage_seq, FND_API.G_MISS_NUM, null, p_end_stage_seq),
	   l_period_fte(1), l_period_fte(2), l_period_fte(3), l_period_fte(4),
	   l_period_fte(5), l_period_fte(6), l_period_fte(7), l_period_fte(8),
	   l_period_fte(9), l_period_fte(10), l_period_fte(11), l_period_fte(12),
	   l_period_fte(13), l_period_fte(14), l_period_fte(15), l_period_fte(16),
	   l_period_fte(17), l_period_fte(18), l_period_fte(19), l_period_fte(20),
	   l_period_fte(21), l_period_fte(22), l_period_fte(23), l_period_fte(24),
	   l_period_fte(25), l_period_fte(26), l_period_fte(27), l_period_fte(28),
	   l_period_fte(29), l_period_fte(30), l_period_fte(31), l_period_fte(32),
	   l_period_fte(33), l_period_fte(34), l_period_fte(35), l_period_fte(36),
	   l_period_fte(37), l_period_fte(38), l_period_fte(39), l_period_fte(40),
	   l_period_fte(41), l_period_fte(42), l_period_fte(43), l_period_fte(44),
	   l_period_fte(45), l_period_fte(46), l_period_fte(47), l_period_fte(48),
	   l_period_fte(49), l_period_fte(50), l_period_fte(51), l_period_fte(52),
	   l_period_fte(53), l_period_fte(54), l_period_fte(55), l_period_fte(56),
	   l_period_fte(57), l_period_fte(58), l_period_fte(59), l_period_fte(60),
	   l_annual_fte,
	   sysdate,
	   l_userid,
	   l_loginid,
	   l_userid,
	   sysdate);

    p_fte_line_id := l_ftelineid;

    if FND_API.to_Boolean(p_recalculate_flag) then
    begin

      for c_BaseSP_Rec in c_BaseSP (l_global_wsid) loop
	    l_base_spid := c_BaseSP_Rec.service_package_id;
      end loop;

      for c_Elements_Rec in c_Rec_Elements (l_data_extract_id,
					    l_business_group_id) loop

    --pass the total_fte , and period_fte and number of budget periods
    --so the FTE proration will be calculated in the calle procedure itself
    --This is to ensure that FTE proration will happen based on the yearly FTE
    --and not on period level FTE
	Distribute_Position_Cost
	      (p_return_status => l_return_status,
	       p_insert_from_base => FND_API.G_TRUE,
	       p_worksheet_id => p_worksheet_id,
	       p_flex_mapping_set_id => p_flex_mapping_set_id,
	       p_rounding_factor => l_rounding_factor,
	       p_position_line_id => p_position_line_id,
	       p_pay_element_id => c_Elements_Rec.pay_element_id,
	       p_budget_year_id => p_budget_year_id,
	       p_base_service_package_id => l_base_spid,
	       p_service_package_id => p_service_package_id,
	       p_stage_set_id => p_stage_set_id,
	       p_start_stage_seq => l_start_stage_seq,
	       p_current_stage_seq => p_current_stage_seq,
	       p_budget_group_id => p_budget_group_id,
               /*For Bug No : 2811698 Start*/
               p_period_fte      => p_period_fte,
               p_total_fte      => l_total_fte,
               p_num_budget_periods => l_num_budget_periods
               /*For Bug No : 2811698 End*/
        );

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end loop;

    end;
    end if;

  end;
  else
  begin

    if ((FND_API.to_Boolean(p_recalculate_flag)) or
	(FND_API.to_Boolean(l_spfl_exists))) then
    begin

      for c_Elements_Rec in c_Rec_Elements (l_data_extract_id,
					    l_business_group_id) loop
	Distribute_Position_Cost
	      (p_return_status => l_return_status,
	       p_worksheet_id => p_worksheet_id,
	       p_flex_mapping_set_id => p_flex_mapping_set_id,
	       p_rounding_factor => l_rounding_factor,
	       p_position_line_id => p_position_line_id,
	       p_pay_element_id => c_Elements_Rec.pay_element_id,
	       p_budget_year_id => p_budget_year_id,
	       p_service_package_id => p_service_package_id,
	       p_stage_set_id => p_stage_set_id,
	       p_start_stage_seq => l_start_stage_seq,
	       p_current_stage_seq => p_current_stage_seq,
	       p_budget_group_id => p_budget_group_id,
               /*For Bug No : 2811698 Start*/
               p_period_fte      => p_period_fte,
               p_total_fte      => l_total_fte,
               p_num_budget_periods => l_num_budget_periods
               /*For Bug No : 2811698 End*/
        );

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end loop;

    end;
    end if;

  end;
  end if;

  if ((FND_API.to_Boolean(p_recalculate_flag)) or
      (FND_API.to_Boolean(l_spfl_exists))) then
  begin

    -- Redistribute the Annual FTE across the Recurring Salary Distributions

    Update_Annual_FTE
	  (p_api_version => 1.0,
	   p_return_status => l_return_status,
	   p_worksheet_id => p_worksheet_id,
	   p_position_line_id => p_position_line_id,
	   p_budget_year_id => p_budget_year_id,
	   p_service_package_id => p_service_package_id,
	   p_stage_set_id => p_stage_set_id,
	   p_current_stage_seq => p_current_stage_seq,
	   p_budget_group_id => p_budget_group_id);

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
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);

END Create_FTE_Lines;

/* ----------------------------------------------------------------------- */

-- Changes allowed for FTE/SP entries :
--
-- (i) Change SP only : if (start_stage_seq <> current_stage_seq) for current
--     record
--     (a) create new stage for all entries for the same SP including :
--         FTE/SP record (in PSB_WS_FTE_LINES)
--         Element Cost records for all recurring elements (in PSB_WS_ELEMENT_LINES)
--         Account Dist records for all recurring elements (in PSB_WS_ACCOUNT_LINES)
--     (b) recalculate for all recurring elements

-- (ii) Change FTE only : if (start_stage_seq <> current_stage_seq) for current
--      record
--     (a) create new stage for all entries for the same SP including :
--         FTE/SP record (in PSB_WS_FTE_LINES)
--         Element Cost records for all recurring elements (in PSB_WS_ELEMENT_LINES)
--         Account Dist records for all recurring elements (in PSB_WS_ACCOUNT_LINES)
--     (b) recalculate for all recurring elements

-- (iii) Change FTE and SP : if (start_stage_seq <> current_stage_seq) for current
--       record
--     (a) create new stage for all entries for the same SP including :
--         FTE/SP record (in PSB_WS_FTE_LINES)
--         Element Cost records for all recurring elements (in PSB_WS_ELEMENT_LINES)
--         Account Dist records for all recurring elements (in PSB_WS_ACCOUNT_LINES)
--     (b) recalculate for all recurring elements

-- Note : Recalculation and Redistribution of Element Costs and Accounting Distributions
-- are done only for recurring Elements since non-recurring Elements are by
-- definition independent of FTE

PROCEDURE Create_FTE_Lines
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_check_stages        IN   VARCHAR2 := FND_API.G_TRUE,
  p_worksheet_id        IN   NUMBER,
  p_fte_line_id         IN   NUMBER,
  p_service_package_id  IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq   IN   NUMBER := FND_API.G_MISS_NUM,
  p_period_fte          IN   PSB_WS_ACCT1.g_prdamt_tbl_type,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Create_FTE_Lines';
  l_api_version         CONSTANT NUMBER         := 1.0;

  l_new_stage           VARCHAR2(1) := FND_API.G_FALSE;

  l_previous_stage_seq  NUMBER;

  l_userid              NUMBER;
  l_loginid             NUMBER;

  l_position_line_id    NUMBER;
  l_budget_year_id      NUMBER;
  l_service_package_id  NUMBER;
  l_stage_set_id        NUMBER;
  l_start_stage_seq     NUMBER;
  l_current_stage_seq   NUMBER;
  l_end_stage_seq       NUMBER;
  l_period_fte          PSB_WS_ACCT1.g_prdamt_tbl_type;
  l_annual_fte          NUMBER;
  l_new_annual_fte      NUMBER;

  l_budget_calendar_id  NUMBER;
  l_budget_group_id     NUMBER;
  l_rounding_factor     NUMBER;
  l_data_extract_id     NUMBER;

  l_business_group_id   NUMBER;

  l_fte                 NUMBER;
  /*For Bug No : 2811698 Start*/
  l_total_fte           NUMBER := 0;
  /*For Bug No : 2811698 End*/
  l_num_budget_periods  NUMBER;

  l_fte_line_id         NUMBER;

  l_spflid              NUMBER;
  l_spfte               PSB_WS_ACCT1.g_prdamt_tbl_type;
  -- Added l_bind_fte as part of fix for bug 3132485
  l_bind_fte            PSB_WS_ACCT1.g_prdamt_tbl_type;
  l_spfl_exists         VARCHAR2(1) := FND_API.G_FALSE;

  l_recalculate_flag    VARCHAR2(1) := FND_API.G_FALSE;

  sql_wfl               VARCHAR2(6000);
  num_wfl               INTEGER;

  l_year_index          BINARY_INTEGER;
  l_index               BINARY_INTEGER;

  l_global_wsid         NUMBER;
  l_base_spid           NUMBER;

  l_update_from_base    VARCHAR2(1) := FND_API.G_FALSE;

  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_temp_buf            VARCHAR2(2000);

  cursor c_Wfl is
    select position_line_id,
	   budget_year_id,
	   service_package_id,
	   stage_set_id,
	   start_stage_seq,
	   current_stage_seq,
	   end_stage_seq,
	   period1_fte, period2_fte, period3_fte, period4_fte,
	   period5_fte, period6_fte, period7_fte, period8_fte,
	   period9_fte, period10_fte, period11_fte, period12_fte,
	   period13_fte, period14_fte, period15_fte, period16_fte,
	   period17_fte, period18_fte, period19_fte, period20_fte,
	   period21_fte, period22_fte, period23_fte, period24_fte,
	   period25_fte, period26_fte, period27_fte, period28_fte,
	   period29_fte, period30_fte, period31_fte, period32_fte,
	   period33_fte, period34_fte, period35_fte, period36_fte,
	   period37_fte, period38_fte, period39_fte, period40_fte,
	   period41_fte, period42_fte, period43_fte, period44_fte,
	   period45_fte, period46_fte, period47_fte, period48_fte,
	   period49_fte, period50_fte, period51_fte, period52_fte,
	   period53_fte, period54_fte, period55_fte, period56_fte,
	   period57_fte, period58_fte, period59_fte, period60_fte,
	   annual_fte
      from PSB_WS_FTE_LINES
     where fte_line_id = p_fte_line_id;

  cursor c_PrevStage is
    select Max(sequence_number) sequence_number
      from PSB_BUDGET_STAGES
     where sequence_number < l_current_stage_seq
       and budget_stage_set_id = l_stage_set_id;

BEGIN

  -- Standard call to check for call compatibility


  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  --Total cost would be the sum of all the periods
  /*For Bug No : 2811698 Start*/
  for l_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
    l_total_fte := l_total_fte + nvl(p_period_fte(l_index),0);
  end loop;
  /*For Bug No : 2811698 End*/

  for c_Wfl_Rec in c_Wfl loop
    l_position_line_id := c_Wfl_Rec.position_line_id;
    l_budget_year_id := c_Wfl_Rec.budget_year_id;
    l_service_package_id := c_Wfl_Rec.service_package_id;
    l_stage_set_id := c_Wfl_Rec.stage_set_id;
    l_start_stage_seq := c_Wfl_Rec.start_stage_seq;
    l_current_stage_seq := c_Wfl_Rec.current_stage_seq;
    l_end_stage_seq := c_Wfl_Rec.end_stage_seq;
    l_period_fte(1) := c_Wfl_Rec.period1_fte; l_period_fte(2) := c_Wfl_Rec.period2_fte;
    l_period_fte(3) := c_Wfl_Rec.period3_fte; l_period_fte(4) := c_Wfl_Rec.period4_fte;
    l_period_fte(5) := c_Wfl_Rec.period5_fte; l_period_fte(6) := c_Wfl_Rec.period6_fte;
    l_period_fte(7) := c_Wfl_Rec.period7_fte; l_period_fte(8) := c_Wfl_Rec.period8_fte;
    l_period_fte(9) := c_Wfl_Rec.period9_fte; l_period_fte(10) := c_Wfl_Rec.period10_fte;
    l_period_fte(11) := c_Wfl_Rec.period11_fte; l_period_fte(12) := c_Wfl_Rec.period12_fte;
    l_period_fte(13) := c_Wfl_Rec.period13_fte; l_period_fte(14) := c_Wfl_Rec.period14_fte;
    l_period_fte(15) := c_Wfl_Rec.period15_fte; l_period_fte(16) := c_Wfl_Rec.period16_fte;
    l_period_fte(17) := c_Wfl_Rec.period17_fte; l_period_fte(18) := c_Wfl_Rec.period18_fte;
    l_period_fte(19) := c_Wfl_Rec.period19_fte; l_period_fte(20) := c_Wfl_Rec.period20_fte;
    l_period_fte(21) := c_Wfl_Rec.period21_fte; l_period_fte(22) := c_Wfl_Rec.period22_fte;
    l_period_fte(23) := c_Wfl_Rec.period23_fte; l_period_fte(24) := c_Wfl_Rec.period24_fte;
    l_period_fte(25) := c_Wfl_Rec.period25_fte; l_period_fte(26) := c_Wfl_Rec.period26_fte;
    l_period_fte(27) := c_Wfl_Rec.period27_fte; l_period_fte(28) := c_Wfl_Rec.period28_fte;
    l_period_fte(29) := c_Wfl_Rec.period29_fte; l_period_fte(30) := c_Wfl_Rec.period30_fte;
    l_period_fte(31) := c_Wfl_Rec.period31_fte; l_period_fte(32) := c_Wfl_Rec.period32_fte;
    l_period_fte(33) := c_Wfl_Rec.period33_fte; l_period_fte(34) := c_Wfl_Rec.period34_fte;
    l_period_fte(35) := c_Wfl_Rec.period35_fte; l_period_fte(36) := c_Wfl_Rec.period36_fte;
    l_period_fte(37) := c_Wfl_Rec.period37_fte; l_period_fte(38) := c_Wfl_Rec.period38_fte;
    l_period_fte(39) := c_Wfl_Rec.period39_fte; l_period_fte(40) := c_Wfl_Rec.period40_fte;
    l_period_fte(41) := c_Wfl_Rec.period41_fte; l_period_fte(42) := c_Wfl_Rec.period42_fte;
    l_period_fte(43) := c_Wfl_Rec.period43_fte; l_period_fte(44) := c_Wfl_Rec.period44_fte;
    l_period_fte(45) := c_Wfl_Rec.period45_fte; l_period_fte(46) := c_Wfl_Rec.period46_fte;
    l_period_fte(47) := c_Wfl_Rec.period47_fte; l_period_fte(48) := c_Wfl_Rec.period48_fte;
    l_period_fte(49) := c_Wfl_Rec.period49_fte; l_period_fte(50) := c_Wfl_Rec.period50_fte;
    l_period_fte(51) := c_Wfl_Rec.period51_fte; l_period_fte(52) := c_Wfl_Rec.period52_fte;
    l_period_fte(53) := c_Wfl_Rec.period53_fte; l_period_fte(54) := c_Wfl_Rec.period54_fte;
    l_period_fte(55) := c_Wfl_Rec.period55_fte; l_period_fte(56) := c_Wfl_Rec.period56_fte;
    l_period_fte(57) := c_Wfl_Rec.period57_fte; l_period_fte(58) := c_Wfl_Rec.period58_fte;
    l_period_fte(59) := c_Wfl_Rec.period59_fte; l_period_fte(60) := c_Wfl_Rec.period60_fte;
    l_annual_fte := c_Wfl_Rec.annual_fte;
  end loop;


  -- If Service Package is being modified, check whether the target FTE line exists

  if ((p_service_package_id <> FND_API.G_MISS_NUM) and
      (p_service_package_id <> l_service_package_id)) then
  begin

    for c_Wfl_Rec in c_Wfl_SP (l_position_line_id, l_budget_year_id, p_service_package_id,
			       l_stage_set_id, l_current_stage_seq) loop
      l_spflid := c_Wfl_Rec.fte_line_id;
      l_spfte(1) := c_Wfl_Rec.period1_fte; l_spfte(2) := c_Wfl_Rec.period2_fte;
      l_spfte(3) := c_Wfl_Rec.period3_fte; l_spfte(4) := c_Wfl_Rec.period4_fte;
      l_spfte(5) := c_Wfl_Rec.period5_fte; l_spfte(6) := c_Wfl_Rec.period6_fte;
      l_spfte(7) := c_Wfl_Rec.period7_fte; l_spfte(8) := c_Wfl_Rec.period8_fte;
      l_spfte(9) := c_Wfl_Rec.period9_fte; l_spfte(10) := c_Wfl_Rec.period10_fte;
      l_spfte(11) := c_Wfl_Rec.period11_fte; l_spfte(12) := c_Wfl_Rec.period12_fte;
      l_spfte(13) := c_Wfl_Rec.period13_fte; l_spfte(14) := c_Wfl_Rec.period14_fte;
      l_spfte(15) := c_Wfl_Rec.period15_fte; l_spfte(16) := c_Wfl_Rec.period16_fte;
      l_spfte(17) := c_Wfl_Rec.period17_fte; l_spfte(18) := c_Wfl_Rec.period18_fte;
      l_spfte(19) := c_Wfl_Rec.period19_fte; l_spfte(20) := c_Wfl_Rec.period20_fte;
      l_spfte(21) := c_Wfl_Rec.period21_fte; l_spfte(22) := c_Wfl_Rec.period22_fte;
      l_spfte(23) := c_Wfl_Rec.period23_fte; l_spfte(24) := c_Wfl_Rec.period24_fte;
      l_spfte(25) := c_Wfl_Rec.period25_fte; l_spfte(26) := c_Wfl_Rec.period26_fte;
      l_spfte(27) := c_Wfl_Rec.period27_fte; l_spfte(28) := c_Wfl_Rec.period28_fte;
      l_spfte(29) := c_Wfl_Rec.period29_fte; l_spfte(30) := c_Wfl_Rec.period30_fte;
      l_spfte(31) := c_Wfl_Rec.period31_fte; l_spfte(32) := c_Wfl_Rec.period32_fte;
      l_spfte(33) := c_Wfl_Rec.period33_fte; l_spfte(34) := c_Wfl_Rec.period34_fte;
      l_spfte(35) := c_Wfl_Rec.period35_fte; l_spfte(36) := c_Wfl_Rec.period36_fte;
      l_spfte(37) := c_Wfl_Rec.period37_fte; l_spfte(38) := c_Wfl_Rec.period38_fte;
      l_spfte(39) := c_Wfl_Rec.period39_fte; l_spfte(40) := c_Wfl_Rec.period40_fte;
      l_spfte(41) := c_Wfl_Rec.period41_fte; l_spfte(42) := c_Wfl_Rec.period42_fte;
      l_spfte(43) := c_Wfl_Rec.period43_fte; l_spfte(44) := c_Wfl_Rec.period44_fte;
      l_spfte(45) := c_Wfl_Rec.period45_fte; l_spfte(46) := c_Wfl_Rec.period46_fte;
      l_spfte(47) := c_Wfl_Rec.period47_fte; l_spfte(48) := c_Wfl_Rec.period48_fte;
      l_spfte(49) := c_Wfl_Rec.period49_fte; l_spfte(50) := c_Wfl_Rec.period50_fte;
      l_spfte(51) := c_Wfl_Rec.period51_fte; l_spfte(52) := c_Wfl_Rec.period52_fte;
      l_spfte(53) := c_Wfl_Rec.period53_fte; l_spfte(54) := c_Wfl_Rec.period54_fte;
      l_spfte(55) := c_Wfl_Rec.period55_fte; l_spfte(56) := c_Wfl_Rec.period56_fte;
      l_spfte(57) := c_Wfl_Rec.period57_fte; l_spfte(58) := c_Wfl_Rec.period58_fte;
      l_spfte(59) := c_Wfl_Rec.period59_fte; l_spfte(60) := c_Wfl_Rec.period60_fte;

      l_spfl_exists := FND_API.G_TRUE;
    end loop;

    l_new_stage := FND_API.G_TRUE;

    -- Delete target FTE line if it exists since entries for the target FTE line will
    -- be added to the current FTE line

    if FND_API.to_Boolean(l_spfl_exists) then
    begin

      l_recalculate_flag := FND_API.G_TRUE;

      PSB_WORKSHEET.Delete_WFL
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_fte_line_id => l_spflid);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  end;
  end if;

  -- Create new Stage if any of the existing Period FTEs are being updated and the Start Stage Seq for
  -- the current FTE line is different from the Current Stage Sequence

  for l_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
    if nvl(p_period_fte(l_index), FND_API.G_MISS_NUM) <> nvl(l_period_fte(l_index), FND_API.G_MISS_NUM) then
      l_new_stage := FND_API.G_TRUE;
      l_recalculate_flag := FND_API.G_TRUE;
      exit;
    end if;

  end loop;

  if ((FND_API.to_Boolean(l_new_stage)) and
      (l_start_stage_seq = l_current_stage_seq)) then
    l_new_stage := FND_API.G_FALSE;
  end if;

  l_userid := FND_GLOBAL.USER_ID;
  l_loginid := FND_GLOBAL.LOGIN_ID;

  if ((FND_API.to_Boolean(p_check_stages)) and
      (FND_API.to_Boolean(l_new_stage)) and
      (l_start_stage_seq < l_current_stage_seq)) then
  begin

    for c_PrevStage_Rec in c_PrevStage loop
      l_previous_stage_seq := c_PrevStage_Rec.sequence_number;
    end loop;

    for c_FTESeq_Rec in c_FTESeq loop
      l_fte_line_id := c_FTESeq_Rec.FTELineID;
    end loop;

    sql_wfl := 'insert into PSB_WS_FTE_LINES ' ||
		      '(fte_line_id, ' ||
		       'position_line_id, ' ||
		       'budget_year_id, ' ||
		       'service_package_id, ' ||
		       'stage_set_id, ' ||
		       'start_stage_seq, ' ||
		       'current_stage_seq, ' ||
		       'end_stage_seq, ';

    for l_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
      sql_wfl := sql_wfl ||
		'period' || l_index || '_fte, ';
    end loop;

    -- Bug#5030383
    -- Replaced l_fte_line_id by :b_fte_line_id
    -- Replaced l_previous_stage_seq by :b_previous_stage_seq
    sql_wfl := sql_wfl ||
	      'annual_fte, ' ||
	      'last_update_date, ' ||
	      'last_updated_by, ' ||
	      'last_update_login, ' ||
	      'created_by, ' ||
	      'creation_date) ' ||
      'select :b_fte_line_id, ' ||
	      'position_line_id, ' ||
	      'budget_year_id, ' ||
	      'service_package_id, ' ||
	      'stage_set_id, ' ||
	      'start_stage_seq, ' ||
	      ':b_previous_stage_seq, ' ||
	      ':b_previous_stage_seq, ';

    for l_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
      sql_wfl := sql_wfl ||
		'period' || l_index || '_fte, ';
    end loop;

    -- Bug#5030383
    -- Replaced sysdate       by :b_last_update_date
    -- Replaced l_userid      by :b_last_updated_by
    -- Replaced l_loginid     by :b_last_update_login
    -- Replaced l_userid      by :b_created_by
    -- Replaced sysdate       by :b_creation_date
    -- Replaced p_fte_line_id by :b_fte_line_id
    sql_wfl := sql_wfl ||
	       'annual_fte, ' ||
	       ':b_last_update_date, ' ||
	       ':b_last_updated_by, ' ||
	       ':b_last_update_login , ' ||
	       ':b_created_by, ' ||
	      ':b_creation_date ' ||
	 'from PSB_WS_FTE_LINES ' ||
	'where fte_line_id = :b_fte_line_id';

    -- Replaced PSB_WS_ACCT1.dsql_execute with execute immediate for bug 3132485
    -- Bug#5030383

    EXECUTE IMMEDIATE
      sql_wfl
    USING
      l_fte_line_id
    , l_previous_stage_seq
    , l_previous_stage_seq
    , SYSDATE
    , l_userid
    , l_loginid
    , l_userid
    , SYSDATE
    , p_fte_line_id ;

    /*
    num_wfl := PSB_WS_ACCT1.dsql_execute(sql_wfl);

    if num_wfl < 0 then
      raise FND_API.G_EXC_ERROR;
    end if;
    */

  end;
  end if;

  l_new_annual_fte := 0;

  sql_wfl := 'update PSB_WS_FTE_LINES ' ||
	'set service_package_id = decode( :p_service_package_id1 , :gmn1,'||
                       	'service_package_id, :p_service_package_id2  ), ';

  for l_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop

    if FND_API.to_Boolean(l_spfl_exists) then
      l_fte := nvl(p_period_fte(l_index), 0) + nvl(l_spfte(l_index), 0);
    else
      l_fte := nvl(p_period_fte(l_index), 0);
    end if;

    -- Replaced l_fte with bind variable for Bug 3132485
    if l_fte = 0 then
      l_bind_fte(l_index) := null;
      sql_wfl := sql_wfl ||
		'period' || l_index || '_fte = :l_fte, ';
    else
      l_bind_fte(l_index) := l_fte;
      sql_wfl := sql_wfl ||
		'period' || l_index || '_fte = ' || ':l_fte' || ', ';
    end if;

    l_new_annual_fte := l_new_annual_fte + l_fte;

  end loop;

  -- If new Stage is created, update the Start and Current Stage Sequences to reflect
  -- the new Stage; otherwise, update the Current Stage Sequence if it is being changed
  -- from Worksheet Operations

  if ((FND_API.to_Boolean(p_check_stages)) and
      (FND_API.to_Boolean(l_new_stage)) and
      (l_start_stage_seq < l_current_stage_seq)) then
  begin
    -- Bug#5030383
    -- Replaced literals by b_start_stage_seq and :b_current_stage_seq
    sql_wfl := sql_wfl ||
	      'start_stage_seq   = :b_start_stage_seq, ' ||
	      'current_stage_seq = :b_current_stage_seq, ';

  end;
  else
  begin
  -- Replaced p_current_stage_seq and FND_API.G_MISS_NUM with bind variables for
  -- bug 3132485
    sql_wfl := sql_wfl ||
               'current_stage_seq = decode( :p_current_stage_seq1 , :gmn2 ,'||
	       'current_stage_seq,  :p_current_stage_seq2 ), ';

  end;
  end if;

  if FND_API.to_Boolean(l_recalculate_flag) then
  begin

    for c_WS_Rec in c_WS (p_worksheet_id) loop
      l_global_wsid := c_WS_Rec.global_worksheet_id;
      l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
      l_budget_group_id := c_WS_Rec.budget_group_id;
      l_rounding_factor := c_WS_Rec.rounding_factor;
      l_data_extract_id := c_WS_Rec.data_extract_id;
    end loop;

    for c_BG_Rec in c_BG (l_budget_group_id) loop
      l_business_group_id := c_BG_Rec.business_group_id;
    end loop;

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

    for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

      if PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id = l_budget_year_id then
	l_num_budget_periods := PSB_WS_ACCT1.g_budget_years(l_year_index).num_budget_periods;
      end if;

    end loop;

    if l_num_budget_periods <> 0 then
      l_new_annual_fte := l_new_annual_fte / l_num_budget_periods;
    end if;
    -- Replaced l_new_annual_fte with bind variable for fix for bug 3132485
    sql_wfl := sql_wfl ||
	      'annual_fte = ' || ':l_new_annual_fte' || ', ';

  end;
  end if;

  -- Bug#5030383
  -- Replaced sysdate       by :b_last_update_date
  -- Replaced l_userid      by :b_last_updated_by
  -- Replaced l_loginid     by :b_last_update_login
  -- Replaced p_fte_line_id by :b_fte_line_id
  sql_wfl := sql_wfl ||
	    'last_update_date  = :b_last_update_date, ' ||
	    'last_updated_by   = :b_last_updated_by, ' ||
	    'last_update_login = :b_last_update_login ' ||
      'where fte_line_id       = :b_fte_line_id' ;

  -- Commented this as part of fix for Bug 3132485
  /*
  num_wfl := PSB_WS_ACCT1.dsql_execute(sql_wfl);

  if num_wfl < 0 then
    raise FND_API.G_EXC_ERROR;
  end if;
  */

  -- start of bug 3353382
  if ((FND_API.to_Boolean(p_check_stages)) and
      (FND_API.to_Boolean(l_new_stage)) and
      (l_start_stage_seq < l_current_stage_seq)) then

    if FND_API.to_Boolean(l_recalculate_flag) then

      -- Bug#5030383

      EXECUTE IMMEDIATE sql_wfl USING
      p_service_package_id,FND_API.G_MISS_NUM,p_service_package_id,
      l_bind_fte(1),l_bind_fte(2),l_bind_fte(3),l_bind_fte(4),
      l_bind_fte(5),l_bind_fte(6),l_bind_fte(7),l_bind_fte(8),
      l_bind_fte(9),l_bind_fte(10),l_bind_fte(11),l_bind_fte(12),
      l_bind_fte(13),l_bind_fte(14),l_bind_fte(15),l_bind_fte(16),
      l_bind_fte(17),l_bind_fte(18),l_bind_fte(19),l_bind_fte(20),
      l_bind_fte(21),l_bind_fte(22),l_bind_fte(23),l_bind_fte(24),
      l_bind_fte(25),l_bind_fte(26),l_bind_fte(27),l_bind_fte(28),
      l_bind_fte(29),l_bind_fte(30),l_bind_fte(31),l_bind_fte(32),
      l_bind_fte(33),l_bind_fte(34),l_bind_fte(35),l_bind_fte(36),
      l_bind_fte(37),l_bind_fte(38),l_bind_fte(39),l_bind_fte(40),
      l_bind_fte(41),l_bind_fte(42),l_bind_fte(43),l_bind_fte(44),
      l_bind_fte(45),l_bind_fte(46),l_bind_fte(47),l_bind_fte(48),
      l_bind_fte(49),l_bind_fte(50),l_bind_fte(51),l_bind_fte(52),
      l_bind_fte(53),l_bind_fte(54),l_bind_fte(55),l_bind_fte(56),
      l_bind_fte(57),l_bind_fte(58),l_bind_fte(59),l_bind_fte(60),
      l_current_stage_seq, l_current_stage_seq,l_new_annual_fte,   --bug:8235347:modified
      SYSDATE, l_userid, l_loginid, p_fte_line_id ;

    else
      -- Bug#5030383

      EXECUTE IMMEDIATE sql_wfl USING
      p_service_package_id,FND_API.G_MISS_NUM,p_service_package_id,
      l_bind_fte(1),l_bind_fte(2),l_bind_fte(3),l_bind_fte(4),
      l_bind_fte(5),l_bind_fte(6),l_bind_fte(7),l_bind_fte(8),
      l_bind_fte(9),l_bind_fte(10),l_bind_fte(11),l_bind_fte(12),
      l_bind_fte(13),l_bind_fte(14),l_bind_fte(15),l_bind_fte(16),
      l_bind_fte(17),l_bind_fte(18),l_bind_fte(19),l_bind_fte(20),
      l_bind_fte(21),l_bind_fte(22),l_bind_fte(23),l_bind_fte(24),
      l_bind_fte(25),l_bind_fte(26),l_bind_fte(27),l_bind_fte(28),
      l_bind_fte(29),l_bind_fte(30),l_bind_fte(31),l_bind_fte(32),
      l_bind_fte(33),l_bind_fte(34),l_bind_fte(35),l_bind_fte(36),
      l_bind_fte(37),l_bind_fte(38),l_bind_fte(39),l_bind_fte(40),
      l_bind_fte(41),l_bind_fte(42),l_bind_fte(43),l_bind_fte(44),
      l_bind_fte(45),l_bind_fte(46),l_bind_fte(47),l_bind_fte(48),
      l_bind_fte(49),l_bind_fte(50),l_bind_fte(51),l_bind_fte(52),
      l_bind_fte(53),l_bind_fte(54),l_bind_fte(55),l_bind_fte(56),
      l_bind_fte(57),l_bind_fte(58),l_bind_fte(59),l_bind_fte(60),
      l_current_stage_seq, l_current_stage_seq, SYSDATE, l_userid,
      l_loginid, p_fte_line_id ;

    end if;
  else

    if FND_API.to_Boolean(l_recalculate_flag) then
      -- Bug#5030383

      EXECUTE IMMEDIATE sql_wfl USING
      p_service_package_id,FND_API.G_MISS_NUM,p_service_package_id,
      l_bind_fte(1),l_bind_fte(2),l_bind_fte(3),l_bind_fte(4),
      l_bind_fte(5),l_bind_fte(6),l_bind_fte(7),l_bind_fte(8),
      l_bind_fte(9),l_bind_fte(10),l_bind_fte(11),l_bind_fte(12),
      l_bind_fte(13),l_bind_fte(14),l_bind_fte(15),l_bind_fte(16),
      l_bind_fte(17),l_bind_fte(18),l_bind_fte(19),l_bind_fte(20),
      l_bind_fte(21),l_bind_fte(22),l_bind_fte(23),l_bind_fte(24),
      l_bind_fte(25),l_bind_fte(26),l_bind_fte(27),l_bind_fte(28),
      l_bind_fte(29),l_bind_fte(30),l_bind_fte(31),l_bind_fte(32),
      l_bind_fte(33),l_bind_fte(34),l_bind_fte(35),l_bind_fte(36),
      l_bind_fte(37),l_bind_fte(38),l_bind_fte(39),l_bind_fte(40),
      l_bind_fte(41),l_bind_fte(42),l_bind_fte(43),l_bind_fte(44),
      l_bind_fte(45),l_bind_fte(46),l_bind_fte(47),l_bind_fte(48),
      l_bind_fte(49),l_bind_fte(50),l_bind_fte(51),l_bind_fte(52),
      l_bind_fte(53),l_bind_fte(54),l_bind_fte(55),l_bind_fte(56),
      l_bind_fte(57),l_bind_fte(58),l_bind_fte(59),l_bind_fte(60),
      p_current_stage_seq,FND_API.G_MISS_NUM,p_current_stage_seq,
      l_new_annual_fte, SYSDATE, l_userid, l_loginid, p_fte_line_id ;

    else
      -- Bug#5030383

      EXECUTE IMMEDIATE sql_wfl USING
      p_service_package_id,FND_API.G_MISS_NUM,p_service_package_id,
      l_bind_fte(1),l_bind_fte(2),l_bind_fte(3),l_bind_fte(4),
      l_bind_fte(5),l_bind_fte(6),l_bind_fte(7),l_bind_fte(8),
      l_bind_fte(9),l_bind_fte(10),l_bind_fte(11),l_bind_fte(12),
      l_bind_fte(13),l_bind_fte(14),l_bind_fte(15),l_bind_fte(16),
      l_bind_fte(17),l_bind_fte(18),l_bind_fte(19),l_bind_fte(20),
      l_bind_fte(21),l_bind_fte(22),l_bind_fte(23),l_bind_fte(24),
      l_bind_fte(25),l_bind_fte(26),l_bind_fte(27),l_bind_fte(28),
      l_bind_fte(29),l_bind_fte(30),l_bind_fte(31),l_bind_fte(32),
      l_bind_fte(33),l_bind_fte(34),l_bind_fte(35),l_bind_fte(36),
      l_bind_fte(37),l_bind_fte(38),l_bind_fte(39),l_bind_fte(40),
      l_bind_fte(41),l_bind_fte(42),l_bind_fte(43),l_bind_fte(44),
      l_bind_fte(45),l_bind_fte(46),l_bind_fte(47),l_bind_fte(48),
      l_bind_fte(49),l_bind_fte(50),l_bind_fte(51),l_bind_fte(52),
      l_bind_fte(53),l_bind_fte(54),l_bind_fte(55),l_bind_fte(56),
      l_bind_fte(57),l_bind_fte(58),l_bind_fte(59),l_bind_fte(60),
      p_current_stage_seq,FND_API.G_MISS_NUM,p_current_stage_seq,
      SYSDATE, l_userid, l_loginid, p_fte_line_id ;

    end if;

  end if;

  --EXECUTE IMMEDIATE sql_wfl USING
  --p_service_package_id,FND_API.G_MISS_NUM,p_service_package_id,
  --l_bind_fte(1),l_bind_fte(2),l_bind_fte(3),l_bind_fte(4),
  --l_bind_fte(5),l_bind_fte(6),l_bind_fte(7),l_bind_fte(8),
  --l_bind_fte(9),l_bind_fte(10),l_bind_fte(11),l_bind_fte(12),
  --l_bind_fte(13),l_bind_fte(14),l_bind_fte(15),l_bind_fte(16),
  --l_bind_fte(17),l_bind_fte(18),l_bind_fte(19),l_bind_fte(20),
  --l_bind_fte(21),l_bind_fte(22),l_bind_fte(23),l_bind_fte(24),
  --l_bind_fte(25),l_bind_fte(26),l_bind_fte(27),l_bind_fte(28),
  --l_bind_fte(29),l_bind_fte(30),l_bind_fte(31),l_bind_fte(32),
  --l_bind_fte(33),l_bind_fte(34),l_bind_fte(35),l_bind_fte(36),
  --l_bind_fte(37),l_bind_fte(38),l_bind_fte(39),l_bind_fte(40),
  --l_bind_fte(41),l_bind_fte(42),l_bind_fte(43),l_bind_fte(44),
  --l_bind_fte(45),l_bind_fte(46),l_bind_fte(47),l_bind_fte(48),
  --l_bind_fte(49),l_bind_fte(50),l_bind_fte(51),l_bind_fte(52),
  --l_bind_fte(53),l_bind_fte(54),l_bind_fte(55),l_bind_fte(56),
  --l_bind_fte(57),l_bind_fte(58),l_bind_fte(59),l_bind_fte(60),
  --p_current_stage_seq,FND_API.G_MISS_NUM,p_current_stage_seq,
  --l_new_annual_fte;

  -- end of bug 3353382

  if FND_API.to_Boolean(l_recalculate_flag) then
  begin

    if ((p_service_package_id <> FND_API.G_MISS_NUM) and
	(p_service_package_id <> l_service_package_id)) then
      l_service_package_id := p_service_package_id;
    end if;

    for c_Elements_Rec in c_Rec_Elements (l_data_extract_id,
					  l_business_group_id) loop

    --pass the total_fte , and period_fte and number of budget periods
    --so the FTE proration will be calculated in the calle procedure itself
    --This is to ensure that FTE proration will happen based on the yearly FTE
    --and not on period level FTE
      Distribute_Position_Cost
		(p_return_status => l_return_status,
		 p_update_from_base => l_update_from_base,
		 p_worksheet_id => p_worksheet_id,
		 p_rounding_factor => l_rounding_factor,
		 p_position_line_id => l_position_line_id,
		 p_pay_element_id => c_Elements_Rec.pay_element_id,
		 p_budget_year_id => l_budget_year_id,
		 p_base_service_package_id => l_base_spid,
		 p_service_package_id => l_service_package_id,
		 p_stage_set_id => l_stage_set_id,
		 p_start_stage_seq => l_start_stage_seq,
		 p_current_stage_seq => l_current_stage_seq,
		 p_budget_group_id => p_budget_group_id,
                 /*For Bug No : 2811698 Start*/
                 p_period_fte      => p_period_fte,
                 p_total_fte      => l_total_fte,
                 p_num_budget_periods => l_num_budget_periods
                 /*For Bug No : 2811698 End*/
   );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end loop;

    -- Reallocate Annual FTE across the non-recurring Salary Distributions

    Update_Annual_FTE
	  (p_api_version => 1.0,
	   p_return_status => l_return_status,
	   p_worksheet_id => p_worksheet_id,
	   p_position_line_id => l_position_line_id,
	   p_budget_year_id => l_budget_year_id,
	   p_service_package_id => l_service_package_id,
	   p_stage_set_id => l_stage_set_id,
	   p_current_stage_seq => l_current_stage_seq,
	   p_budget_group_id => p_budget_group_id);

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
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data  => l_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);
END Create_FTE_Lines;

/* ----------------------------------------------------------------------- */


-- Recalculate Position Element Costs and Position Account Distributions
-- using the pre-computed Period FTE Ratios and the Annual FTE Ratio

PROCEDURE Distribute_Position_Cost
( p_return_status            OUT  NOCOPY  VARCHAR2,
  p_insert_from_base         IN   VARCHAR2 := FND_API.G_FALSE,
  p_update_from_base         IN   VARCHAR2 := FND_API.G_FALSE,
  p_worksheet_id             IN   NUMBER,
  p_flex_mapping_set_id      IN   NUMBER := FND_API.G_MISS_NUM,
  p_rounding_factor          IN   NUMBER,
  p_position_line_id         IN   NUMBER,
  p_pay_element_id           IN   NUMBER,
  p_budget_year_id           IN   NUMBER,
  p_base_service_package_id  IN   NUMBER := FND_API.G_MISS_NUM,
  p_service_package_id       IN   NUMBER,
  p_stage_set_id             IN   NUMBER,
  p_start_stage_seq          IN   NUMBER,
  p_current_stage_seq        IN   NUMBER,
  p_budget_group_id          IN   NUMBER,
  /*For Bug No : 2811698 Start*/
  p_period_fte               IN   PSB_WS_ACCT1.g_prdamt_tbl_type,
  p_total_fte                IN   NUMBER,
  p_num_budget_periods       IN   NUMBER
  /*For Bug No : 2811698 End*/
) IS

  l_account_line_id          NUMBER;
  l_period_amount            PSB_WS_ACCT1.g_prdamt_tbl_type;

  l_salary_account_line      VARCHAR2(1);
  l_ytd_amount               NUMBER;
  l_annual_fte               NUMBER;

  l_rounding_diff            NUMBER;

  l_element_line_id          NUMBER;
  l_element_cost             NUMBER;
  /*For Bug No : 2811698 Start*/
  l_single_fte_amount       NUMBER;
  l_annual_fte_ratio        NUMBER;
 /*For Bug No : 2811698 End*/

  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);

  l_api_name                 CONSTANT VARCHAR2(30) := 'Distribute_Position_Cost';

  cursor c_Base_Element_Cost is
    select element_line_id,
	   element_set_id,
	   currency_code,
	   element_cost
      from PSB_WS_ELEMENT_LINES a
     where p_current_stage_seq between start_stage_seq and current_stage_seq
       and pay_element_id = p_pay_element_id
       and stage_set_id = p_stage_set_id
       and service_package_id = p_base_service_package_id
       and budget_year_id = p_budget_year_id
       and position_line_id = p_position_line_id;

  cursor c_Base_Element_Dist is
    select a.account_line_id,
	   a.budget_group_id,
	   a.code_combination_id,
	   a.currency_code,
	   a.ytd_amount,
	   a.annual_fte,
	   a.element_set_id,
	   a.salary_account_line,
	   a.period1_amount, a.period2_amount, a.period3_amount, a.period4_amount,
	   a.period5_amount, a.period6_amount, a.period7_amount, a.period8_amount,
	   a.period9_amount, a.period10_amount, a.period11_amount, a.period12_amount,
	   a.period13_amount, a.period14_amount, a.period15_amount, a.period16_amount,
	   a.period17_amount, a.period18_amount, a.period19_amount, a.period20_amount,
	   a.period21_amount, a.period22_amount, a.period23_amount, a.period24_amount,
	   a.period25_amount, a.period26_amount, a.period27_amount, a.period28_amount,
	   a.period29_amount, a.period30_amount, a.period31_amount, a.period32_amount,
	   a.period33_amount, a.period34_amount, a.period35_amount, a.period36_amount,
	   a.period37_amount, a.period38_amount, a.period39_amount, a.period40_amount,
	   a.period41_amount, a.period42_amount, a.period43_amount, a.period44_amount,
	   a.period45_amount, a.period46_amount, a.period47_amount, a.period48_amount,
	   a.period49_amount, a.period50_amount, a.period51_amount, a.period52_amount,
	   a.period53_amount, a.period54_amount, a.period55_amount, a.period56_amount,
	   a.period57_amount, a.period58_amount, a.period59_amount, a.period60_amount
      from PSB_WS_ACCOUNT_LINES a,
	   PSB_WS_ELEMENT_LINES b
     where a.element_set_id = b.element_set_id
       and p_current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.stage_set_id = p_stage_set_id
       and a.service_package_id = p_base_service_package_id
       and a.budget_year_id = p_budget_year_id
       and a.position_line_id = p_position_line_id
       and p_current_stage_seq between b.start_stage_seq and b.current_stage_seq
       and b.service_package_id = p_base_service_package_id
       and b.pay_element_id = p_pay_element_id
       and b.budget_year_id = p_budget_year_id
       and b.position_line_id = p_position_line_id;

  cursor c_Element_Cost is
    select element_line_id,
	   element_set_id,
	   currency_code,
	   element_cost
      from PSB_WS_ELEMENT_LINES a
     where p_current_stage_seq between start_stage_seq and current_stage_seq
       and pay_element_id = p_pay_element_id
       and stage_set_id = p_stage_set_id
       and service_package_id = p_service_package_id
       and budget_year_id = p_budget_year_id
       and position_line_id = p_position_line_id;

  cursor c_Element_Dist is
    select a.account_line_id,
	   a.budget_group_id,
	   a.code_combination_id,
	   a.currency_code,
	   a.ytd_amount,
	   a.annual_fte,
	   a.element_set_id,
	   a.salary_account_line,
	   a.period1_amount, a.period2_amount, a.period3_amount, a.period4_amount,
	   a.period5_amount, a.period6_amount, a.period7_amount, a.period8_amount,
	   a.period9_amount, a.period10_amount, a.period11_amount, a.period12_amount,
	   a.period13_amount, a.period14_amount, a.period15_amount, a.period16_amount,
	   a.period17_amount, a.period18_amount, a.period19_amount, a.period20_amount,
	   a.period21_amount, a.period22_amount, a.period23_amount, a.period24_amount,
	   a.period25_amount, a.period26_amount, a.period27_amount, a.period28_amount,
	   a.period29_amount, a.period30_amount, a.period31_amount, a.period32_amount,
	   a.period33_amount, a.period34_amount, a.period35_amount, a.period36_amount,
	   a.period37_amount, a.period38_amount, a.period39_amount, a.period40_amount,
	   a.period41_amount, a.period42_amount, a.period43_amount, a.period44_amount,
	   a.period45_amount, a.period46_amount, a.period47_amount, a.period48_amount,
	   a.period49_amount, a.period50_amount, a.period51_amount, a.period52_amount,
	   a.period53_amount, a.period54_amount, a.period55_amount, a.period56_amount,
	   a.period57_amount, a.period58_amount, a.period59_amount, a.period60_amount
      from PSB_WS_ACCOUNT_LINES a,
	   PSB_WS_ELEMENT_LINES b
     where a.element_set_id = b.element_set_id
       and p_current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.stage_set_id = p_stage_set_id
       and a.service_package_id = p_service_package_id
       and a.budget_year_id = p_budget_year_id
       and a.position_line_id = p_position_line_id
       and p_current_stage_seq between b.start_stage_seq and b.current_stage_seq
       and b.service_package_id = p_service_package_id
       and b.pay_element_id = p_pay_element_id
       and b.budget_year_id = p_budget_year_id
       and b.position_line_id = p_position_line_id;


   /* For Bug No. 2250319 : Start */

   cursor c_Element_Set(element_set NUMBER) IS
       SELECT 1
	 FROM PSB_WS_ELEMENT_LINES
	WHERE position_line_id = p_position_line_id
	  AND budget_year_id   = p_budget_year_id
	  AND element_set_id   = element_set
	  AND pay_element_id   < p_pay_element_id;

     l_acct_distributed BOOLEAN := FALSE;

   /* For Bug No. 2250319 : End */

  /* Bug 4379636 Start */
  l_root_budget_group_id      NUMBER;
  l_position_id               NUMBER;
  l_budget_group_id           NUMBER;
  l_set_of_books_id           NUMBER;
  l_data_extract_id           NUMBER;
  l_chart_of_accounts_id      NUMBER;
  l_budget_calendar_id        NUMBER;
  l_distr_percent             NUMBER;
  l_else_flag                 VARCHAR2(1) := 'N';
  l_ccid                      NUMBER;

  CURSOR c_ws IS
    SELECT data_extract_id,
           budget_calendar_id,
           budget_group_id
      FROM psb_worksheets
     WHERE worksheet_id = p_worksheet_id;

  CURSOR c_bg IS
    SELECT nvl(root_budget_group_id, budget_group_id) root_budget_group_id,
           nvl(set_of_books_id, root_set_of_books_id) set_of_books_id
      FROM PSB_BUDGET_GROUPS_V
     WHERE budget_group_id = l_budget_group_id;

  CURSOR c_sob IS
    SELECT chart_of_accounts_id
      FROM GL_SETS_OF_BOOKS
     WHERE set_of_books_id = l_set_of_books_id;

  CURSOR c_positions IS
    SELECT position_id
      FROM psb_ws_position_lines
     WHERE position_line_id = p_position_line_id;

  CURSOR c_fte IS
    SELECT annual_fte
      FROM psb_ws_fte_lines
     WHERE position_line_id = p_position_line_id
       AND budget_year_id= p_budget_year_id;

  CURSOR c_pos_group IS
    SELECT pay_element_id,
           distribution_percent,
           code_combination_id
      FROM psb_element_pos_set_groups pepsg ,
           psb_pay_element_distributions pped
     WHERE pepsg.position_set_group_id = pped.position_set_group_id
       AND pepsg.pay_element_id = p_pay_element_id
       AND code_combination_id  = l_ccid;

  /* Bug 4379636 End */

BEGIN
  /* Bug 4379636 Start */

  FOR c_ws_rec IN c_ws
  LOOP
    l_data_extract_id         := c_ws_rec.data_extract_id;
    l_budget_calendar_id      := c_ws_rec.budget_calendar_id;
    l_budget_group_id         :=  c_ws_rec.budget_group_id;
  END LOOP;

 if l_budget_calendar_id <> nvl(PSB_WS_ACCT1.g_budget_calendar_id, FND_API.G_MISS_NUM) then --bug:8235347:Added if condition
  psb_ws_acct1.cache_budget_calendar
      (
         p_return_status         =>  l_return_status ,
         p_budget_calendar_id    =>  l_budget_calendar_id
      );
 end if;    --bug:8235347:added

  FOR c_bg_rec IN c_bg
  LOOP
    l_root_budget_group_id := c_bg_rec.root_budget_group_id;
    l_set_of_books_id      := c_bg_rec.set_of_books_id;
  END LOOP;

  FOR c_sob_rec IN c_sob
  LOOP
    l_chart_of_accounts_id := c_sob_rec.chart_of_accounts_id;
  END LOOP;

  FOR c_positions_rec IN c_positions
  LOOP
    l_position_id := c_positions_rec.position_id;
  END LOOP;

  PSB_WS_POS1.Cache_Salary_Dist
         (p_return_status => l_return_status,
	  p_worksheet_id => p_worksheet_id,
	  p_root_budget_group_id => l_root_budget_group_id,
	  p_flex_code => l_chart_of_accounts_id,
	  p_data_extract_id => l_data_extract_id,
	  p_position_id => l_position_id,
	  p_position_name => null,
	  p_start_date => PSB_WS_ACCT1.g_startdate_cy,
	  p_end_date => PSB_WS_ACCT1.g_end_est_date);

  /* Bug 4379636 End */

  l_rounding_diff := 0;

  if FND_API.to_Boolean(p_insert_from_base) then
  begin

    for c_Element_Dist_Rec in c_Base_Element_Dist loop

      for l_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
  	    l_period_amount(l_index) := null;
      end loop;

      /* Bug 4379636 Start */
      IF c_Element_Dist_Rec.salary_account_line = 'Y' THEN

      FOR i in 1..g_salary_dist.count
      LOOP

        IF c_Element_Dist_Rec.code_combination_id = g_salary_dist(i).ccid THEN
          l_distr_percent := g_salary_dist(i).percent;
        END IF;
      END LOOP;
      ELSE
        l_ccid := c_element_dist_rec.code_combination_id;
        l_distr_percent := 100;
        FOR c_pos_group_rec IN c_pos_group
        LOOP
          IF c_pos_group_rec.distribution_percent IS NOT NULL THEN
            l_distr_percent := c_pos_group_rec.distribution_percent;
          ELSE
            l_distr_percent := 100;
          END IF;
        END LOOP;
      END IF;
      /* Bug 4379636 End */

      /*For Bug No : 2811698 Start*/
      --changed the logic to calculate the FTE proration here itself
      --instead of from Prorate_FTE_Base. This will ensure that period costs
      --will come properly.
      if (nvl(c_Element_Dist_Rec.annual_fte,0) <> 0) then

        /* Bug 4379636 Start */
        -- l_annual_fte_ratio := p_total_fte / (c_Element_Dist_Rec.annual_fte * p_num_budget_periods);
        l_annual_fte_ratio := ( (p_total_fte / p_num_budget_periods) * l_distr_percent/100)
                              / c_Element_Dist_Rec.annual_fte;
	/* Bug 4379636 End */

        l_ytd_amount := c_Element_Dist_Rec.ytd_amount * l_annual_fte_ratio;
      else
        l_annual_fte_ratio := 0;
        l_ytd_amount := 0;
      end if;
      if (p_total_fte <> 0) then
        l_single_fte_amount := l_ytd_amount / p_total_fte;
      else
        l_single_fte_amount := 0;
      end if;

      for l_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
        if nvl(p_period_fte(l_index),0) = 0 then
          l_period_amount(l_index) := NULL;
        else
          l_period_amount(l_index) := l_single_fte_amount * p_period_fte(l_index);
        end if;
      end loop;
      /*For Bug No : 2811698 End*/

      if p_rounding_factor is not null then
	l_rounding_diff := l_rounding_diff +
			   round(l_ytd_amount / p_rounding_factor) * p_rounding_factor - l_ytd_amount;
      end if;

      /*For Bug No : 2811698 Start*/
 	  l_annual_fte := p_total_fte / p_num_budget_periods;
      /*For Bug No : 2811698 End*/

      if c_Element_Dist_Rec.salary_account_line is null then
	l_salary_account_line := FND_API.G_FALSE;
      else
	l_salary_account_line := FND_API.G_TRUE;
      end if;

      PSB_WS_ACCT1.Create_Account_Dist
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_account_line_id => l_account_line_id,
	  p_worksheet_id => p_worksheet_id,
	  p_flex_mapping_set_id => p_flex_mapping_set_id,
	  p_map_accounts => TRUE,
	  p_check_spal_exists => FND_API.G_FALSE,
	  p_gl_cutoff_period => null,
	  p_allocrule_set_id => null,
	  p_budget_calendar_id => null,
	  p_rounding_factor => p_rounding_factor,
	  p_stage_set_id => p_stage_set_id,
	  p_budget_year_id => p_budget_year_id,
	  p_budget_group_id => c_Element_Dist_Rec.budget_group_id,
	  p_ccid => c_Element_Dist_Rec.code_combination_id,
	  p_currency_code => c_Element_Dist_Rec.currency_code,
	  p_balance_type => 'E',
	  p_ytd_amount => l_ytd_amount,
          /*For Bug No : 2811698 Start*/
	  --p_annual_fte => c_Element_Dist_Rec.annual_fte * g_annual_fte_ratio,
	  p_annual_fte => l_annual_fte,
          /*For Bug No : 2811698 End*/
	  p_period_amount => l_period_amount,
	  p_position_line_id => p_position_line_id,
	  p_element_set_id => c_Element_Dist_Rec.element_set_id,
	  p_salary_account_line => l_salary_account_line,
	  p_service_package_id => p_service_package_id,
	  p_start_stage_seq => p_start_stage_seq,
	  p_current_stage_seq => p_current_stage_seq);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end loop;

    for c_Element_Cost_Rec in c_Base_Element_Cost loop

      Create_Element_Lines
	    (p_api_version => 1.0,
	     p_return_status => l_return_status,
	     p_element_line_id => l_element_line_id,
	     p_check_spel_exists => FND_API.G_FALSE,
	     p_position_line_id => p_position_line_id,
	     p_budget_year_id => p_budget_year_id,
	     p_pay_element_id => p_pay_element_id,
	     p_currency_code => c_Element_Cost_Rec.currency_code,
             /*For Bug No : 2811698 Start*/
	     --p_element_cost => (c_Element_Cost_Rec.element_cost * nvl(g_annual_fte_ratio, 0) + l_rounding_diff),
	     p_element_cost => (c_Element_Cost_Rec.element_cost * l_annual_fte_ratio + l_rounding_diff),
             /*For Bug No : 2811698 End*/
	     p_element_set_id => c_Element_Cost_Rec.element_set_id,
	     p_service_package_id => p_service_package_id,
	     p_stage_set_id => p_stage_set_id,
	     p_start_stage_seq => p_start_stage_seq,
	     p_current_stage_seq => p_current_stage_seq);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end loop;

  end;
  else
  begin

    for c_Element_Dist_Rec in c_Element_Dist loop

      for l_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
	l_period_amount(l_index) := null;
      end loop;

      /* Bug 4379636 Start */
      IF c_Element_Dist_Rec.salary_account_line = 'Y' THEN

      FOR i in 1..g_salary_dist.count
      LOOP

      IF c_Element_Dist_Rec.code_combination_id = g_salary_dist(i).ccid THEN
        l_distr_percent := g_salary_dist(i).percent;
      END IF;
      END LOOP;
      ELSE
        l_ccid := c_element_dist_rec.code_combination_id;
        l_distr_percent := 100;
        FOR c_pos_group_rec IN c_pos_group
        LOOP
          IF c_pos_group_rec.distribution_percent IS NOT NULL THEN
            l_distr_percent := c_pos_group_rec.distribution_percent;
          ELSE
            l_distr_percent := 100;
          END IF;
        END LOOP;
      END IF;
      /* Bug 4379636 End */

      if FND_API.to_Boolean(p_update_from_base) then
      begin

	for c_Base_Element_Dist_Rec in c_Base_Element_Dist loop

	  if c_Base_Element_Dist_Rec.code_combination_id = c_Element_Dist_Rec.code_combination_id then
	  begin

           /*For Bug No : 2811698 Start*/
           --changed the logic to calculate the FTE proration here itself
           --instead of from Prorate_FTE_Base. This will ensure that period costs
           --will come properly.
           if (nvl(c_Base_Element_Dist_Rec.annual_fte,0) <> 0) then

             /* Bug 4379636 Start */
             -- l_annual_fte_ratio := p_total_fte / (c_Base_Element_Dist_Rec.annual_fte * p_num_budget_periods);
             l_annual_fte_ratio := ( (p_total_fte / p_num_budget_periods) * l_distr_percent/100) /
                                   c_Base_Element_Dist_Rec.annual_fte;
	     /* Bug 4379636 End */

             l_ytd_amount := c_Base_Element_Dist_Rec.ytd_amount * l_annual_fte_ratio;
           else
             l_annual_fte_ratio := 0;
             l_ytd_amount := 0;
           end if;
           if (p_total_fte <> 0) then
             l_single_fte_amount := l_ytd_amount / p_total_fte;
           else
             l_single_fte_amount := 0;
           end if;

           for l_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
             if nvl(p_period_fte(l_index),0) = 0 then
	        l_period_amount(l_index) := NULL;
             else
	        l_period_amount(l_index) := l_single_fte_amount * p_period_fte(l_index);
             end if;
           end loop;
           /*For Bug No : 2811698 End*/

	    if p_rounding_factor is not null then
	      l_rounding_diff := l_rounding_diff +
				 round(l_ytd_amount / p_rounding_factor) * p_rounding_factor - l_ytd_amount;
	    end if;

            /*For Bug No : 2811698 Start*/
	    --l_annual_fte := c_Base_Element_Dist_Rec.annual_fte * g_annual_fte_ratio;
 	    l_annual_fte := p_total_fte / p_num_budget_periods;
            /*For Bug No : 2811698 End*/

	  end;
	  end if;

	end loop;

      end;
      else
      begin

        /*For Bug No : 2811698 Start*/
        --changed the logic to calculate the FTE proration here itself
        --instead of from Prorate_FTE_Base. This will ensure that period costs
        --will come properly.
        if (nvl(c_Element_Dist_Rec.annual_fte,0) <> 0) then
          /* Bug 4379636 Start */
          -- l_annual_fte_ratio := p_total_fte / (c_Element_Dist_Rec.annual_fte * p_num_budget_periods);
          l_annual_fte_ratio := ( (p_total_fte / p_num_budget_periods) * l_distr_percent/100) / c_Element_Dist_Rec.annual_fte;

	  /* Bug 4379636 End */
          l_ytd_amount := c_Element_Dist_Rec.ytd_amount * l_annual_fte_ratio;
        else
          l_annual_fte_ratio := 0;
          l_ytd_amount := 0;
        end if;
        if (p_total_fte <> 0) then
          l_single_fte_amount := l_ytd_amount / p_total_fte;
        else
          l_single_fte_amount := 0;
        end if;

        for l_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
          if nvl(p_period_fte(l_index),0) = 0 then
	    l_period_amount(l_index) := NULL;
          else
	    l_period_amount(l_index) := l_single_fte_amount * p_period_fte(l_index);
          end if;
        end loop;
        /*For Bug No : 2811698 End*/

	if p_rounding_factor is not null then
	  l_rounding_diff := l_rounding_diff +
			     round(l_ytd_amount / p_rounding_factor) * p_rounding_factor - l_ytd_amount;
	end if;

        /*For Bug No : 2811698 Start*/
	--l_annual_fte := c_Element_Dist_Rec.annual_fte * g_annual_fte_ratio;
 	l_annual_fte := p_total_fte / p_num_budget_periods;
        /*For Bug No : 2811698 End*/

      end;
      end if;

     /* For Bug No. 2250319 : Start */
     -- If Account Distribution corresponding to a particular Element_Set_Id is modified for FTE, it should not be modified again.
      l_acct_distributed := FALSE;

      for c_Element_Set_Rec in c_Element_Set(c_Element_Dist_Rec.element_set_id) loop
	l_acct_distributed := TRUE;
      end loop;

      IF NOT l_acct_distributed THEN
     /* For Bug No. 2250319 : End */

      PSB_WS_ACCT1.Create_Account_Dist
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_worksheet_id => p_worksheet_id,
	  p_account_line_id => c_Element_Dist_Rec.account_line_id,
	  p_ytd_amount => l_ytd_amount,
	  p_annual_fte => l_annual_fte,
	  p_period_amount => l_period_amount,
	  p_service_package_id => p_service_package_id,
	  p_current_stage_seq => p_current_stage_seq,
	  p_budget_group_id => p_budget_group_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      -- For Bug No. 2250319
      END IF;

      --
      -- (SRawat: Found while fixing 3140849).
      -- If mulitple elements correspond to same element set, during processing
      -- of very first element, psb_ws_account_lines will get updated for the
      -- element set for annual_fte. This means we need to cache annual fte
      -- to process rest of the elements within the same element set rather
      -- than reading it from psb_ws_account_lines. Note l_acct_distributed is
      -- always FALSE for the very first element on a per element set basis.
      --
      IF NOT l_acct_distributed THEN
        -- Processing very first element within the set. Cache the value to be
        -- used by the subsequent elements within the set.
        g_last_annual_fte_ratio := l_annual_fte_ratio ;
      ELSE
        -- Processing subsequent elements within the set. Get the cache value.
        l_annual_fte_ratio := g_last_annual_fte_ratio ;
      END IF;

    end loop;

    for c_Element_Cost_Rec in c_Element_Cost loop

      if FND_API.to_Boolean(p_update_from_base) then
      begin
	    for c_Base_Element_Cost_Rec in c_Base_Element_Cost loop
	      l_element_cost := c_Base_Element_Cost_Rec.element_cost * nvl(l_annual_fte_ratio, 0) + l_rounding_diff;
	    end loop;
      end;
      else
	      l_element_cost := c_Element_Cost_Rec.element_cost * nvl(l_annual_fte_ratio, 0) + l_rounding_diff;
      end if;

      Create_Element_Lines
	    (p_api_version => 1.0,
	     p_return_status => l_return_status,
	     p_element_line_id => c_Element_Cost_Rec.element_line_id,
	     p_element_cost => l_element_cost,
	     p_service_package_id => p_service_package_id,
	     p_current_stage_seq => p_current_stage_seq);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end loop;

  end;
  end if;


  -- Initialize API return status to success

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

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);

END Distribute_Position_Cost;

/* ----------------------------------------------------------------------- */

-- Create or Update existing Position Element Cost line. Use this API when
-- the element_line_id identifier is not known

PROCEDURE Create_Element_Lines
( p_api_version             IN   NUMBER,
  p_validation_level        IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status           OUT  NOCOPY  VARCHAR2,
  p_element_line_id         OUT  NOCOPY  NUMBER,
  p_check_spel_exists       IN   VARCHAR2 := FND_API.G_TRUE,
  p_position_line_id        IN   NUMBER,
  p_budget_year_id          IN   NUMBER,
  p_pay_element_id          IN   NUMBER,
  p_currency_code           IN   VARCHAR2,
  p_element_cost            IN   NUMBER,
  p_element_set_id          IN   NUMBER,
  p_service_package_id      IN   NUMBER,
  p_stage_set_id            IN   NUMBER,
  p_start_stage_seq         IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq       IN   NUMBER,
  p_end_stage_seq           IN   NUMBER := FND_API.G_MISS_NUM,
  p_functional_transaction  IN   VARCHAR2 := NULL
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Create_Element_Lines';
  l_api_version         CONSTANT NUMBER         := 1.0;

  l_userid              NUMBER;
  l_loginid             NUMBER;

  l_element_line_id     NUMBER;
  l_start_stage_seq     NUMBER;
  l_set_of_books_id     NUMBER;
  l_spelid              NUMBER;
  l_spelcost            NUMBER;
  l_spel_exists         VARCHAR2(1) := FND_API.G_FALSE;

  l_return_status       VARCHAR2(1);
  l_msg_data            VARCHAR2(2000);
  l_msg_count           NUMBER;

  cursor c_Seq is
    select psb_ws_element_lines_s.nextval ElmLineID
      from dual;

  cursor c_Wel_SP is
    select element_line_id,
	   element_cost
      from PSB_WS_ELEMENT_LINES a
     where p_current_stage_seq between start_stage_seq and current_stage_seq
       and pay_element_id = p_pay_element_id
       and stage_set_id = p_stage_set_id
       and service_package_id = p_service_package_id
       and budget_year_id = p_budget_year_id
       and position_line_id = p_position_line_id;

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  l_userid := FND_GLOBAL.USER_ID;
  l_loginid := FND_GLOBAL.LOGIN_ID;

  if p_start_stage_seq = FND_API.G_MISS_NUM then
    l_start_stage_seq := p_current_stage_seq;
  else
    l_start_stage_seq := p_start_stage_seq;
  end if;

  if FND_API.to_Boolean(p_check_spel_exists) then
  begin

    for c_Wel_Rec in c_Wel_SP loop
      l_spelid := c_Wel_Rec.element_line_id;
      l_spelcost := c_Wel_Rec.element_cost;

      l_spel_exists := FND_API.G_TRUE;
    end loop;

  end;
  end if;

  if FND_API.to_Boolean(l_spel_exists) then
  begin

    update PSB_WS_ELEMENT_LINES
       set element_cost = nvl(p_element_cost, 0),
	   element_set_id = p_element_set_id,
	   current_stage_seq = p_current_stage_seq,
	   end_stage_seq = decode(p_end_stage_seq, FND_API.G_MISS_NUM, end_stage_seq, p_end_stage_seq),
	   last_update_date = sysdate,
	   last_updated_by = l_userid,
	   last_update_login = l_loginid
     where element_line_id = l_spelid;

  end;
  else
  begin

    update PSB_WS_ELEMENT_LINES a
       set element_cost = nvl(p_element_cost, 0),
	   element_set_id = p_element_set_id,
	   current_stage_seq = p_current_stage_seq,
	   end_stage_seq = decode(p_end_stage_seq, FND_API.G_MISS_NUM, end_stage_seq, p_end_stage_seq),
	   last_update_date = sysdate,
	   last_updated_by = l_userid,
	   last_update_login = l_loginid
     where start_stage_seq = p_start_stage_seq
       and currency_code = p_currency_code
       and pay_element_id = p_pay_element_id
       and stage_set_id = p_stage_set_id
       and service_package_id = p_service_package_id
       and budget_year_id = p_budget_year_id
       and position_line_id = p_position_line_id;

  end;
  end if;

  if SQL%NOTFOUND then
  begin

    for c_Seq_Rec in c_Seq loop
      l_element_line_id := c_Seq_Rec.ElmLineID;
    end loop;

    insert into PSB_WS_ELEMENT_LINES
	  (element_line_id,
	   position_line_id,
	   budget_year_id,
	   pay_element_id,
	   currency_code,
	   element_cost,
	   element_set_id,
	   service_package_id,
	   stage_set_id,
	   start_stage_seq,
	   current_stage_seq,
	   end_stage_seq,
	   last_update_date,
	   last_updated_by,
	   last_update_login,
	   created_by,
	   creation_date,
	   functional_transaction)
   values (l_element_line_id,
	   p_position_line_id,
	   p_budget_year_id,
	   p_pay_element_id,
	   p_currency_code,
	   nvl(p_element_cost, 0),
	   p_element_set_id,
	   p_service_package_id,
	   p_stage_set_id,
	   l_start_stage_seq,
	   p_current_stage_seq,
	   decode(p_end_stage_seq, FND_API.G_MISS_NUM, null, p_end_stage_seq),
	   sysdate,
	   l_userid,
	   l_loginid,
	   l_userid,
	   sysdate,
	   p_functional_transaction);

    p_element_line_id := l_element_line_id;

  end;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data  => l_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);

END Create_Element_Lines;

/* ----------------------------------------------------------------------- */

-- Update existing Position Element Cost line and create new Stages if
-- required and the flag p_check_stages is set to FND_API.G_TRUE

PROCEDURE Create_Element_Lines
( p_api_version             IN   NUMBER,
  p_validation_level        IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status           OUT  NOCOPY  VARCHAR2,
  p_check_stages            IN   VARCHAR2 := FND_API.G_TRUE,
  p_element_line_id         IN   NUMBER,
  p_service_package_id      IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq       IN   NUMBER := FND_API.G_MISS_NUM,
  p_element_cost            IN   NUMBER := FND_API.G_MISS_NUM
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Create_Element_Lines';
  l_api_version         CONSTANT NUMBER         := 1.0;

  l_new_stage           VARCHAR2(1) := FND_API.G_FALSE;

  l_previous_stage_seq  NUMBER;

  l_userid              NUMBER;
  l_loginid             NUMBER;

  l_position_line_id    NUMBER;
  l_budget_year_id      NUMBER;
  l_pay_element_id      NUMBER;
  l_currency_code       VARCHAR2(10);
  l_element_cost        NUMBER;
  l_element_set_id      NUMBER;
  l_service_package_id  NUMBER;
  l_stage_set_id        NUMBER;
  l_start_stage_seq     NUMBER;
  l_current_stage_seq   NUMBER;
  l_end_stage_seq       NUMBER;

  l_spelid              NUMBER;
  l_spelcost            NUMBER;
  l_spel_exists         VARCHAR2(1) := FND_API.G_FALSE;

  sql_wel               VARCHAR2(6000);
  num_wel               INTEGER;

  l_set_of_books_id     NUMBER;
  l_element_line_id     NUMBER;

  l_return_status       VARCHAR2(1);
  l_msg_data            VARCHAR2(2000);
  l_msg_count           NUMBER;

  cursor c_ElmSeq is
    select psb_ws_element_lines_s.nextval ElmLineID
      from dual;

  cursor c_PrevStage is
    select Max(sequence_number) sequence_number
      from PSB_BUDGET_STAGES
     where sequence_number < l_current_stage_seq
       and budget_stage_set_id = l_stage_set_id;

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  sql_wel := 'select position_line_id, budget_year_id, pay_element_id, currency_code, element_cost, ' ||
	     'element_set_id, service_package_id, stage_set_id, start_stage_seq, current_stage_seq, ' ||
	     'end_stage_seq ' ||
	     'from PSB_WS_ELEMENT_LINES ' ||
	    'where element_line_id = :ElemLineID';

  execute immediate sql_wel into
    l_position_line_id, l_budget_year_id, l_pay_element_id, l_currency_code, l_element_cost, l_element_set_id,
    l_service_package_id, l_stage_set_id, l_start_stage_seq, l_current_stage_seq, l_end_stage_seq
    using p_element_line_id;

  -- If Service Package is being modified, check whether the target element line exists

  if ((p_service_package_id <> FND_API.G_MISS_NUM) and
      (p_service_package_id <> l_service_package_id)) then
  begin

    sql_wel := 'select ' ||
	       'element_line_id, element_cost ' ||
	       'from PSB_WS_ELEMENT_LINES a ' ||
	      'where :current_stage_seq between start_stage_seq and current_stage_seq ' ||
		'and pay_element_id = :pay_element_id ' ||
		'and stage_set_id = :stage_set_id ' ||
		'and service_package_id = :service_package_id ' ||
		'and budget_year_id = :budget_year_id ' ||
		'and position_line_id = :position_line_id';

    begin

      execute immediate sql_wel into
	l_spelid, l_spelcost
       using l_current_stage_seq, l_pay_element_id, l_stage_set_id, p_service_package_id, l_budget_year_id,
	     l_position_line_id;

      l_spel_exists := FND_API.G_TRUE;

    exception
      when others then
	l_spel_exists := FND_API.G_FALSE;
    end;

    l_new_stage := FND_API.G_TRUE;

    if FND_API.to_Boolean(l_spel_exists) then
    begin

      PSB_WORKSHEET.Delete_WEL
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_element_line_id => l_spelid);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  end;
  end if;

  if ((p_element_cost <> FND_API.G_MISS_NUM) and
      (p_element_cost <> l_element_cost)) then
    l_new_stage := FND_API.G_TRUE;
  end if;

  if ((FND_API.to_Boolean(l_new_stage)) and
      (l_start_stage_seq = l_current_stage_seq)) then
    l_new_stage := FND_API.G_FALSE;
  end if;

  l_userid := FND_GLOBAL.USER_ID;
  l_loginid := FND_GLOBAL.LOGIN_ID;

  if ((FND_API.to_Boolean(p_check_stages)) and
      (FND_API.to_Boolean(l_new_stage)) and
      (l_start_stage_seq < l_current_stage_seq)) then
  begin

    for c_PrevStage_Rec in c_PrevStage loop
      l_previous_stage_seq := c_PrevStage_Rec.sequence_number;
    end loop;

    for c_ElmSeq_Rec in c_ElmSeq loop
      l_element_line_id := c_ElmSeq_Rec.ElmLineID;
    end loop;

    -- Bug#5030383
    -- Replaced l_element_line_id    by :b_element_line_id
    -- Replaced stage_seq            by :b_current_stage_seq and :b_end_stage_seq
    -- Replaced sysdate              by :b_last_update_date  and :b_creation_date
    -- Replaced l_userid             by :b_last_updated_by
    -- Replaced l_loginid            by :b_last_update_login
    -- Replaced p_element_line_id    by :b_element_line_id
    sql_wel := 'insert into PSB_WS_ELEMENT_LINES ' ||
		      '(element_line_id, ' ||
		       'position_line_id, ' ||
		       'budget_year_id, ' ||
		       'pay_element_id, ' ||
		       'currency_code, ' ||
		       'element_cost, ' ||
		       'element_set_id, ' ||
		       'service_package_id, ' ||
		       'stage_set_id, ' ||
		       'start_stage_seq, ' ||
		       'current_stage_seq, ' ||
		       'end_stage_seq, ' ||
		       'functional_transaction, ' ||
		       'last_update_date, ' ||
		       'last_updated_by, ' ||
		       'last_update_login, ' ||
		       'created_by, ' ||
		       'creation_date) ' ||
	       'select :b_element_line_id, ' ||
		       'position_line_id, ' ||
		       'budget_year_id, ' ||
		       'pay_element_id, ' ||
		       'currency_code, ' ||
		       'element_cost, ' ||
		       'element_set_id, ' ||
		       'service_package_id, ' ||
		       'stage_set_id, ' ||
		       'start_stage_seq, ' ||
		       ':b_current_stage_seq, ' ||
		       ':b_end_stage_seq, ' ||
		       'functional_transaction, ' ||
		      ':b_last_update_date, ' ||
		      ':b_last_updated_by, ' ||
		      ':b_last_update_login, ' ||
		      ':b_last_updated_by, ' ||
		     ':b_creation_date ' ||
		'from PSB_WS_ELEMENT_LINES ' ||
	       'where element_line_id = :b_element_line_id' ;

    -- Bug#5030383

    EXECUTE IMMEDIATE
      sql_wel
    USING
      l_element_line_id
    , l_previous_stage_seq
    , l_previous_stage_seq
    , SYSDATE
    , l_userid
    , l_loginid
    , l_userid
    , SYSDATE
    , p_element_line_id ;

/*    if num_wel < 0 then
      raise FND_API.G_EXC_ERROR;
    end if; */

    update PSB_WS_ELEMENT_LINES
       set element_cost = decode(p_element_cost, FND_API.G_MISS_NUM, element_cost, null, 0, p_element_cost),
	   service_package_id = decode(p_service_package_id, FND_API.G_MISS_NUM, service_package_id, p_service_package_id),
	   start_stage_seq = l_current_stage_seq,
	   current_stage_seq = l_current_stage_seq,
	   last_update_date = sysdate,
	   last_updated_by = l_userid,
	   last_update_login = l_loginid
     where element_line_id = p_element_line_id;

  end;
  else
  begin

    update PSB_WS_ELEMENT_LINES
       set element_cost = decode(p_element_cost, FND_API.G_MISS_NUM, element_cost, null, 0, p_element_cost),
	   service_package_id = decode(p_service_package_id, FND_API.G_MISS_NUM, service_package_id, p_service_package_id),
	   current_stage_seq = decode(p_current_stage_seq, FND_API.G_MISS_NUM, current_stage_seq, p_current_stage_seq),
	   last_update_date = sysdate,
	   last_updated_by = l_userid,
	   last_update_login = l_loginid
     where element_line_id = p_element_line_id;

  end;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data  => l_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data => l_msg_data);

END Create_Element_Lines;

/* ----------------------------------------------------------------------- */

-- Distribute the computed Annual FTE across the recurring Salary Account
-- Distributions

PROCEDURE Update_Annual_FTE
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_position_line_id    IN   NUMBER,
  p_budget_year_id      IN   NUMBER,
  p_service_package_id  IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_current_stage_seq   IN   NUMBER,
  p_budget_group_id     IN   NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Annual_FTE';
  l_api_version         CONSTANT NUMBER         := 1.0;

  l_ytd_amount          NUMBER;
  l_period_amount       PSB_WS_ACCT1.g_prdamt_tbl_type;
  l_annual_fte          NUMBER;

  l_init_index          BINARY_INTEGER;
  l_salary_index        BINARY_INTEGER;

  l_return_status       VARCHAR2(1);

  cursor c_FTE is
    select annual_fte
      from PSB_WS_FTE_LINES a
     where p_current_stage_seq between start_stage_seq and current_stage_seq
       and stage_set_id = p_stage_set_id
       and service_package_id = p_service_package_id
       and budget_year_id = p_budget_year_id
       and position_line_id = p_position_line_id;

  cursor c_Salary_Dist is
    select a.account_line_id,
	   a.ytd_amount,
	   a.period1_amount, a.period2_amount, a.period3_amount, a.period4_amount,
	   a.period5_amount, a.period6_amount, a.period7_amount, a.period8_amount,
	   a.period9_amount, a.period10_amount, a.period11_amount, a.period12_amount,
	   a.period13_amount, a.period14_amount, a.period15_amount, a.period16_amount,
	   a.period17_amount, a.period18_amount, a.period19_amount, a.period20_amount,
	   a.period21_amount, a.period22_amount, a.period23_amount, a.period24_amount,
	   a.period25_amount, a.period26_amount, a.period27_amount, a.period28_amount,
	   a.period29_amount, a.period30_amount, a.period31_amount, a.period32_amount,
	   a.period33_amount, a.period34_amount, a.period35_amount, a.period36_amount,
	   a.period37_amount, a.period38_amount, a.period39_amount, a.period40_amount,
	   a.period41_amount, a.period42_amount, a.period43_amount, a.period44_amount,
	   a.period45_amount, a.period46_amount, a.period47_amount, a.period48_amount,
	   a.period49_amount, a.period50_amount, a.period51_amount, a.period52_amount,
	   a.period53_amount, a.period54_amount, a.period55_amount, a.period56_amount,
	   a.period57_amount, a.period58_amount, a.period59_amount, a.period60_amount
      from PSB_WS_ACCOUNT_LINES a
     where exists
	  (select 1
	     from PSB_PAY_ELEMENTS b,
		  PSB_WS_ELEMENT_LINES c
	    where b.processing_type = 'R'
	      and b.pay_element_id = c.pay_element_id
	      and c.element_set_id = a.element_set_id
	      and c.budget_year_id = p_budget_year_id
	      and c.position_line_id = p_position_line_id)
       and a.salary_account_line = 'Y'
       and p_current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.stage_set_id = p_stage_set_id
       and a.service_package_id = p_service_package_id
       and a.budget_year_id = p_budget_year_id
       and a.position_line_id = p_position_line_id;

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  l_ytd_amount := 0;

  Initialize_Element_Dist;

  for c_Salary_Dist_Rec in c_Salary_Dist loop

    g_num_element_dist := g_num_element_dist + 1;

    l_ytd_amount := l_ytd_amount + c_Salary_Dist_Rec.ytd_amount;

    g_element_dist(g_num_element_dist).account_line_id := c_Salary_Dist_Rec.account_line_id;
    g_element_dist(g_num_element_dist).ytd_amount := c_Salary_Dist_Rec.ytd_amount;
    g_element_dist(g_num_element_dist).period1_amount := c_Salary_Dist_Rec.period1_amount;
    g_element_dist(g_num_element_dist).period2_amount := c_Salary_Dist_Rec.period2_amount;
    g_element_dist(g_num_element_dist).period3_amount := c_Salary_Dist_Rec.period3_amount;
    g_element_dist(g_num_element_dist).period4_amount := c_Salary_Dist_Rec.period4_amount;
    g_element_dist(g_num_element_dist).period5_amount := c_Salary_Dist_Rec.period5_amount;
    g_element_dist(g_num_element_dist).period6_amount := c_Salary_Dist_Rec.period6_amount;
    g_element_dist(g_num_element_dist).period7_amount := c_Salary_Dist_Rec.period7_amount;
    g_element_dist(g_num_element_dist).period8_amount := c_Salary_Dist_Rec.period8_amount;
    g_element_dist(g_num_element_dist).period9_amount := c_Salary_Dist_Rec.period9_amount;
    g_element_dist(g_num_element_dist).period10_amount := c_Salary_Dist_Rec.period10_amount;
    g_element_dist(g_num_element_dist).period11_amount := c_Salary_Dist_Rec.period11_amount;
    g_element_dist(g_num_element_dist).period12_amount := c_Salary_Dist_Rec.period12_amount;
    g_element_dist(g_num_element_dist).period13_amount := c_Salary_Dist_Rec.period13_amount;
    g_element_dist(g_num_element_dist).period14_amount := c_Salary_Dist_Rec.period14_amount;
    g_element_dist(g_num_element_dist).period15_amount := c_Salary_Dist_Rec.period15_amount;
    g_element_dist(g_num_element_dist).period16_amount := c_Salary_Dist_Rec.period16_amount;
    g_element_dist(g_num_element_dist).period17_amount := c_Salary_Dist_Rec.period17_amount;
    g_element_dist(g_num_element_dist).period18_amount := c_Salary_Dist_Rec.period18_amount;
    g_element_dist(g_num_element_dist).period19_amount := c_Salary_Dist_Rec.period19_amount;
    g_element_dist(g_num_element_dist).period20_amount := c_Salary_Dist_Rec.period20_amount;
    g_element_dist(g_num_element_dist).period21_amount := c_Salary_Dist_Rec.period21_amount;
    g_element_dist(g_num_element_dist).period22_amount := c_Salary_Dist_Rec.period22_amount;
    g_element_dist(g_num_element_dist).period23_amount := c_Salary_Dist_Rec.period23_amount;
    g_element_dist(g_num_element_dist).period24_amount := c_Salary_Dist_Rec.period24_amount;
    g_element_dist(g_num_element_dist).period25_amount := c_Salary_Dist_Rec.period25_amount;
    g_element_dist(g_num_element_dist).period26_amount := c_Salary_Dist_Rec.period26_amount;
    g_element_dist(g_num_element_dist).period27_amount := c_Salary_Dist_Rec.period27_amount;
    g_element_dist(g_num_element_dist).period28_amount := c_Salary_Dist_Rec.period28_amount;
    g_element_dist(g_num_element_dist).period29_amount := c_Salary_Dist_Rec.period29_amount;
    g_element_dist(g_num_element_dist).period30_amount := c_Salary_Dist_Rec.period30_amount;
    g_element_dist(g_num_element_dist).period31_amount := c_Salary_Dist_Rec.period31_amount;
    g_element_dist(g_num_element_dist).period32_amount := c_Salary_Dist_Rec.period32_amount;
    g_element_dist(g_num_element_dist).period33_amount := c_Salary_Dist_Rec.period33_amount;
    g_element_dist(g_num_element_dist).period34_amount := c_Salary_Dist_Rec.period34_amount;
    g_element_dist(g_num_element_dist).period35_amount := c_Salary_Dist_Rec.period35_amount;
    g_element_dist(g_num_element_dist).period36_amount := c_Salary_Dist_Rec.period36_amount;
    g_element_dist(g_num_element_dist).period37_amount := c_Salary_Dist_Rec.period37_amount;
    g_element_dist(g_num_element_dist).period38_amount := c_Salary_Dist_Rec.period38_amount;
    g_element_dist(g_num_element_dist).period39_amount := c_Salary_Dist_Rec.period39_amount;
    g_element_dist(g_num_element_dist).period40_amount := c_Salary_Dist_Rec.period40_amount;
    g_element_dist(g_num_element_dist).period41_amount := c_Salary_Dist_Rec.period41_amount;
    g_element_dist(g_num_element_dist).period42_amount := c_Salary_Dist_Rec.period42_amount;
    g_element_dist(g_num_element_dist).period43_amount := c_Salary_Dist_Rec.period43_amount;
    g_element_dist(g_num_element_dist).period44_amount := c_Salary_Dist_Rec.period44_amount;
    g_element_dist(g_num_element_dist).period45_amount := c_Salary_Dist_Rec.period45_amount;
    g_element_dist(g_num_element_dist).period46_amount := c_Salary_Dist_Rec.period46_amount;
    g_element_dist(g_num_element_dist).period47_amount := c_Salary_Dist_Rec.period47_amount;
    g_element_dist(g_num_element_dist).period48_amount := c_Salary_Dist_Rec.period48_amount;
    g_element_dist(g_num_element_dist).period49_amount := c_Salary_Dist_Rec.period49_amount;
    g_element_dist(g_num_element_dist).period50_amount := c_Salary_Dist_Rec.period50_amount;
    g_element_dist(g_num_element_dist).period51_amount := c_Salary_Dist_Rec.period51_amount;
    g_element_dist(g_num_element_dist).period52_amount := c_Salary_Dist_Rec.period52_amount;
    g_element_dist(g_num_element_dist).period53_amount := c_Salary_Dist_Rec.period53_amount;
    g_element_dist(g_num_element_dist).period54_amount := c_Salary_Dist_Rec.period54_amount;
    g_element_dist(g_num_element_dist).period55_amount := c_Salary_Dist_Rec.period55_amount;
    g_element_dist(g_num_element_dist).period56_amount := c_Salary_Dist_Rec.period56_amount;
    g_element_dist(g_num_element_dist).period57_amount := c_Salary_Dist_Rec.period57_amount;
    g_element_dist(g_num_element_dist).period58_amount := c_Salary_Dist_Rec.period58_amount;
    g_element_dist(g_num_element_dist).period59_amount := c_Salary_Dist_Rec.period59_amount;
    g_element_dist(g_num_element_dist).period60_amount := c_Salary_Dist_Rec.period60_amount;

  end loop;

  if l_ytd_amount <> 0 then
  begin

    for c_FTE_Rec in c_FTE loop
      l_annual_fte := c_FTE_Rec.annual_fte;
    end loop;

    for l_salary_index in 1..g_num_element_dist loop

      for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
	l_period_amount(l_init_index) := null;
      end loop;

      l_period_amount(1) := g_element_dist(l_salary_index).period1_amount;
      l_period_amount(2) := g_element_dist(l_salary_index).period2_amount;
      l_period_amount(3) := g_element_dist(l_salary_index).period3_amount;
      l_period_amount(4) := g_element_dist(l_salary_index).period4_amount;
      l_period_amount(5) := g_element_dist(l_salary_index).period5_amount;
      l_period_amount(6) := g_element_dist(l_salary_index).period6_amount;
      l_period_amount(7) := g_element_dist(l_salary_index).period7_amount;
      l_period_amount(8) := g_element_dist(l_salary_index).period8_amount;
      l_period_amount(9) := g_element_dist(l_salary_index).period9_amount;
      l_period_amount(10) := g_element_dist(l_salary_index).period10_amount;
      l_period_amount(11) := g_element_dist(l_salary_index).period11_amount;
      l_period_amount(12) := g_element_dist(l_salary_index).period12_amount;
      l_period_amount(13) := g_element_dist(l_salary_index).period13_amount;
      l_period_amount(14) := g_element_dist(l_salary_index).period14_amount;
      l_period_amount(15) := g_element_dist(l_salary_index).period15_amount;
      l_period_amount(16) := g_element_dist(l_salary_index).period16_amount;
      l_period_amount(17) := g_element_dist(l_salary_index).period17_amount;
      l_period_amount(18) := g_element_dist(l_salary_index).period18_amount;
      l_period_amount(19) := g_element_dist(l_salary_index).period19_amount;
      l_period_amount(20) := g_element_dist(l_salary_index).period20_amount;
      l_period_amount(21) := g_element_dist(l_salary_index).period21_amount;
      l_period_amount(22) := g_element_dist(l_salary_index).period22_amount;
      l_period_amount(23) := g_element_dist(l_salary_index).period23_amount;
      l_period_amount(24) := g_element_dist(l_salary_index).period24_amount;
      l_period_amount(25) := g_element_dist(l_salary_index).period25_amount;
      l_period_amount(26) := g_element_dist(l_salary_index).period26_amount;
      l_period_amount(27) := g_element_dist(l_salary_index).period27_amount;
      l_period_amount(28) := g_element_dist(l_salary_index).period28_amount;
      l_period_amount(29) := g_element_dist(l_salary_index).period29_amount;
      l_period_amount(30) := g_element_dist(l_salary_index).period30_amount;
      l_period_amount(31) := g_element_dist(l_salary_index).period31_amount;
      l_period_amount(32) := g_element_dist(l_salary_index).period32_amount;
      l_period_amount(33) := g_element_dist(l_salary_index).period33_amount;
      l_period_amount(34) := g_element_dist(l_salary_index).period34_amount;
      l_period_amount(35) := g_element_dist(l_salary_index).period35_amount;
      l_period_amount(36) := g_element_dist(l_salary_index).period36_amount;
      l_period_amount(37) := g_element_dist(l_salary_index).period37_amount;
      l_period_amount(38) := g_element_dist(l_salary_index).period38_amount;
      l_period_amount(39) := g_element_dist(l_salary_index).period39_amount;
      l_period_amount(40) := g_element_dist(l_salary_index).period40_amount;
      l_period_amount(41) := g_element_dist(l_salary_index).period41_amount;
      l_period_amount(42) := g_element_dist(l_salary_index).period42_amount;
      l_period_amount(43) := g_element_dist(l_salary_index).period43_amount;
      l_period_amount(44) := g_element_dist(l_salary_index).period44_amount;
      l_period_amount(45) := g_element_dist(l_salary_index).period45_amount;
      l_period_amount(46) := g_element_dist(l_salary_index).period46_amount;
      l_period_amount(47) := g_element_dist(l_salary_index).period47_amount;
      l_period_amount(48) := g_element_dist(l_salary_index).period48_amount;
      l_period_amount(49) := g_element_dist(l_salary_index).period49_amount;
      l_period_amount(50) := g_element_dist(l_salary_index).period50_amount;
      l_period_amount(51) := g_element_dist(l_salary_index).period51_amount;
      l_period_amount(52) := g_element_dist(l_salary_index).period52_amount;
      l_period_amount(53) := g_element_dist(l_salary_index).period53_amount;
      l_period_amount(54) := g_element_dist(l_salary_index).period54_amount;
      l_period_amount(55) := g_element_dist(l_salary_index).period55_amount;
      l_period_amount(56) := g_element_dist(l_salary_index).period56_amount;
      l_period_amount(57) := g_element_dist(l_salary_index).period57_amount;
      l_period_amount(58) := g_element_dist(l_salary_index).period58_amount;
      l_period_amount(59) := g_element_dist(l_salary_index).period59_amount;
      l_period_amount(60) := g_element_dist(l_salary_index).period60_amount;

      PSB_WS_ACCT1.Create_Account_Dist
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_worksheet_id => p_worksheet_id,
	  p_account_line_id => g_element_dist(l_salary_index).account_line_id,
	  p_check_stages => FND_API.G_FALSE,
	  p_ytd_amount => g_element_dist(l_salary_index).ytd_amount,
	  p_annual_fte => l_annual_fte * g_element_dist(l_salary_index).ytd_amount / l_ytd_amount,
	  p_period_amount => l_period_amount,
	  p_budget_group_id => p_budget_group_id,
	  p_service_package_id => p_service_package_id,
	  p_current_stage_seq => p_current_stage_seq);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end loop;

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
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Update_Annual_FTE;

/* ----------------------------------------------------------------------- */

PROCEDURE Distribute_Following_Elements
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_redistribute       IN   VARCHAR2 := FND_API.G_FALSE,
  p_pay_element_id     IN   NUMBER,
  p_data_extract_id    IN   NUMBER,
  p_flex_code          IN   NUMBER,
  p_business_group_id  IN   NUMBER,
  p_rounding_factor    IN   NUMBER,
  p_position_line_id   IN   NUMBER,
  p_position_id        IN   NUMBER,
  p_budget_year_id     IN   NUMBER,
  p_start_date         IN   DATE,
  p_end_date           IN   DATE
) IS

  l_ccid_val             FND_FLEX_EXT.SegmentArray;
  l_seg_val              FND_FLEX_EXT.SegmentArray;
  l_ccid                 NUMBER;

  l_start_date           DATE;
  l_end_date             DATE;
  l_dist_start_date      DATE;
  l_dist_end_date        DATE;

  l_rounding_difference  NUMBER;

  l_init_index           BINARY_INTEGER;
  l_calc_index           BINARY_INTEGER;
  l_saldist_index        BINARY_INTEGER;
  l_dist_index           BINARY_INTEGER;
  l_element_index        BINARY_INTEGER;
  l_index                BINARY_INTEGER;

  l_elem_found           VARCHAR2(1) := FND_API.G_FALSE;
  l_dist_found           VARCHAR2(1);

  l_percent              NUMBER;
  l_element_set_id       NUMBER;

  l_flex_delimiter       VARCHAR2(1);
  l_concat_segments      VARCHAR2(2000);

/* Bug No 2278216 Start */
  l_return_status       VARCHAR2(1);
/* Bug No 2278216 End */

  cursor c_Dist is
    select a.segment1, a.segment2, a.segment3, a.segment4,
	   a.segment5, a.segment6, a.segment7, a.segment8,
	   a.segment9, a.segment10, a.segment11, a.segment12,
	   a.segment13, a.segment14, a.segment15, a.segment16,
	   a.segment17, a.segment18, a.segment19, a.segment20,
	   a.segment21, a.segment22, a.segment23, a.segment24,
	   a.segment25, a.segment26, a.segment27, a.segment28,
	   a.segment29, a.segment30,
	   a.effective_start_date, a.effective_end_date
      from PSB_PAY_ELEMENT_DISTRIBUTIONS a,
	   PSB_ELEMENT_POS_SET_GROUPS b,
	   PSB_SET_RELATIONS c,
	   PSB_BUDGET_POSITIONS d
     where a.chart_of_accounts_id = p_flex_code
       and (((a.effective_start_date <= p_end_date)
	 and (a.effective_end_date is null))
	 or ((a.effective_start_date between p_start_date and p_end_date)
	  or (a.effective_end_date between p_start_date and p_end_date)
	 or ((a.effective_start_date < p_start_date)
	 and (a.effective_end_date > p_end_date))))
       and a.position_set_group_id = b.position_set_group_id
       and b.position_set_group_id = c.position_set_group_id
       and b.pay_element_id = p_pay_element_id
       and c.account_position_set_id = d.account_position_set_id
       and d.data_extract_id = p_data_extract_id
       and d.position_id = p_position_id;

BEGIN

  for l_calc_index in 1..g_num_pc_costs loop

    if ((g_pc_costs(l_calc_index).budget_year_id = p_budget_year_id) and
	(g_pc_costs(l_calc_index).pay_element_id = p_pay_element_id)) then
      l_element_index := l_calc_index;
      l_elem_found := FND_API.G_TRUE;
      exit;
    end if;

  end loop;

  if FND_API.to_Boolean(l_elem_found) then
  begin

/* Bug No 2278216 Start */
   PSB_WS_POS1.Initialize_Period_Dist;
/* Bug No 2278216 End */

    for l_calc_index in REVERSE 1..(l_element_index - 1) loop

      if g_pc_costs(l_calc_index).pay_element_id = p_pay_element_id then
	l_element_set_id := g_pc_costs(l_calc_index).element_set_id;
	exit;
      end if;

    end loop;

    l_rounding_difference := 0;

    for c_Dist_Rec in c_Dist loop

	if (((c_Dist_Rec.effective_start_date <= p_start_date) and
	     (c_Dist_Rec.effective_end_date is null)) or
	    ((c_Dist_Rec.effective_start_date between p_start_date and p_end_date) or
	     (c_Dist_Rec.effective_end_date between p_start_date and p_end_date) or
	    ((c_Dist_Rec.effective_start_date < p_start_date) and
	     (c_Dist_Rec.effective_end_date > p_end_date)))) then
	Begin
	  l_start_date := greatest(p_start_date, c_Dist_Rec.effective_start_date);
	  l_end_date := least(p_end_date, nvl(c_Dist_Rec.effective_end_date, p_end_date));

      for l_saldist_index in 1..g_num_salary_dist loop

	 if (((PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date <= l_end_date) and
		 (PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date is null)) or
		((PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date between l_start_date and l_end_date) or
		 (PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date between l_start_date and l_end_date) or
		((PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date < l_start_date) and
		 (PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date > l_end_date)))) then
	 begin

	  l_dist_start_date := greatest(l_start_date, PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date);
	  l_dist_end_date := least(l_end_date, nvl(PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date, l_end_date));

	l_dist_found := FND_API.G_FALSE;

        -- commented for bug # 4502946
	/*if g_salary_dist(l_saldist_index).percent < 1 then
	  l_percent := g_salary_dist(l_saldist_index).percent;
	else
	  l_percent := g_salary_dist(l_saldist_index).percent / 100;
	end if;*/

        -- added for bug # 4502946
        l_percent := g_salary_dist(l_saldist_index).percent / 100;

	for l_init_index in 1..PSB_WS_ACCT1.g_num_segs loop
	  l_ccid_val(l_init_index) := null;
	  l_seg_val(l_init_index) := null;
	end loop;

	if not FND_FLEX_EXT.Get_Segments
	  (application_short_name => 'SQLGL',
	   key_flex_code => 'GL#',
	   structure_number => p_flex_code,
	   combination_id => g_salary_dist(l_saldist_index).ccid,
	   n_segments => PSB_WS_ACCT1.g_num_segs,
	   segments => l_ccid_val) then

	  FND_MSG_PUB.Add;
	  raise FND_API.G_EXC_ERROR;
	end if;

	for l_index in 1..PSB_WS_ACCT1.g_num_segs loop

	  if ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT1') and
	      (c_Dist_Rec.segment1 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment1;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT2') and
	      (c_Dist_Rec.segment2 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment2;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT3') and
	      (c_Dist_Rec.segment3 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment3;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT4') and
	      (c_Dist_Rec.segment4 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment4;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT5') and
	      (c_Dist_Rec.segment5 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment5;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT6') and
	      (c_Dist_Rec.segment6 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment6;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT7') and
	      (c_Dist_Rec.segment7 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment7;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT8') and
	      (c_Dist_Rec.segment8 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment8;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT9') and
	      (c_Dist_Rec.segment9 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment9;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT10') and
	      (c_Dist_Rec.segment10 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment10;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT11') and
	      (c_Dist_Rec.segment11 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment11;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT12') and
	      (c_Dist_Rec.segment12 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment12;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT13') and
	      (c_Dist_Rec.segment13 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment13;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT14') and
	      (c_Dist_Rec.segment14 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment14;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT15') and
	      (c_Dist_Rec.segment15 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment15;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT16') and
	      (c_Dist_Rec.segment16 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment16;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT17') and
	      (c_Dist_Rec.segment17 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment17;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT18') and
	      (c_Dist_Rec.segment18 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment18;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT19') and
	      (c_Dist_Rec.segment19 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment19;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT20') and
	      (c_Dist_Rec.segment20 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment20;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT21') and
	      (c_Dist_Rec.segment21 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment21;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT22') and
	      (c_Dist_Rec.segment22 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment22;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT23') and
	      (c_Dist_Rec.segment23 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment23;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT24') and
	      (c_Dist_Rec.segment24 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment24;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT25') and
	      (c_Dist_Rec.segment25 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment25;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT26') and
	      (c_Dist_Rec.segment26 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment26;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT27') and
	      (c_Dist_Rec.segment27 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment27;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT28') and
	      (c_Dist_Rec.segment28 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment28;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT29') and
	      (c_Dist_Rec.segment29 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment29;

	  elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT30') and
	      (c_Dist_Rec.segment30 is not null)) then
	    l_seg_val(l_index) := c_Dist_Rec.segment30;

	  else
	    l_seg_val(l_index) := l_ccid_val(l_index);
	  end if;

	end loop;

	if not FND_FLEX_EXT.Get_Combination_ID
	  (application_short_name => 'SQLGL',
	   key_flex_code => 'GL#',
	   structure_number => p_flex_code,
	   validation_date => sysdate,
	   n_segments => PSB_WS_ACCT1.g_num_segs,
	   segments => l_seg_val,
	   combination_id => l_ccid) then
	begin

	  l_flex_delimiter := FND_FLEX_EXT.Get_Delimiter
				(application_short_name => 'SQLGL',
				 key_flex_code => 'GL#',
				 structure_number => p_flex_code);

	  l_concat_segments := FND_FLEX_EXT.Concatenate_Segments
				 (n_segments => PSB_WS_ACCT1.g_num_segs,
				  segments => l_seg_val,
				  delimiter => l_flex_delimiter);

	  FND_MSG_PUB.Add;
	  message_token('ACCOUNT', l_concat_segments);
	  add_message('PSB', 'PSB_GL_CCID_FAILURE');
	  raise FND_API.G_EXC_ERROR;

	end;
	end if;

	for l_index in REVERSE 1..g_num_pd_costs loop

	  if ((g_pd_costs(l_index).ccid = l_ccid) and
	      (g_pd_costs(l_index).budget_year_id = p_budget_year_id) and
	      (g_pd_costs(l_index).element_type = 'F')) then
	     l_element_set_id := g_pd_costs(l_index).element_set_id;
	     l_dist_index := l_index;
	     l_dist_found := FND_API.G_TRUE;
	     exit;
	  end if;

	end loop;

/* Bug No 2278216 Start */
-- Created a separate procedure for calculating period amounts

	if not FND_API.to_Boolean(l_dist_found) then
	begin
	    g_num_pd_costs := g_num_pd_costs + 1;

	    g_pd_costs(g_num_pd_costs).budget_year_id := p_budget_year_id;
	    g_pd_costs(g_num_pd_costs).element_type := 'F';
	    g_pd_costs(g_num_pd_costs).ccid := l_ccid;

	    if not FND_API.to_Boolean(p_redistribute) then
	    begin
		if l_element_set_id is null then
		  l_element_set_id := p_pay_element_id;
		end if;

		if g_pc_costs(l_element_index).element_set_id is null then
		  g_pc_costs(l_element_index).element_set_id := l_element_set_id;
		end if;

		g_pd_costs(g_num_pd_costs).element_set_id := l_element_set_id;
	    end;
	    else
		l_element_set_id := g_pc_costs(l_element_index).element_set_id;

		g_pd_costs(g_num_pd_costs).element_set_id := l_element_set_id;
	    end if;
	end;
	else
	begin
	    if not FND_API.to_Boolean(p_redistribute) then
	    begin
		if g_pc_costs(l_element_index).element_set_id is null then
		  g_pc_costs(l_element_index).element_set_id := l_element_set_id;
		end if;
	    end;
	    end if;
	end;
	end if;

	g_num_periods := g_num_periods + 1;

	g_periods(g_num_periods).ccid := l_ccid;
	g_periods(g_num_periods).budget_year_id := g_pd_costs(g_num_pd_costs).budget_year_id;
	g_periods(g_num_periods).element_type := 'F';
	g_periods(g_num_periods).element_set_id := l_element_set_id;
	g_periods(g_num_periods).percent := l_percent;
	g_periods(g_num_periods).period_start_date := l_dist_start_date;
	g_periods(g_num_periods).period_end_date := l_dist_end_date;

	end;
	end if;

       end loop;

      end;
      end if;

    end loop;

   l_rounding_difference := 0;

   for l_dist_index in 1..g_num_pd_costs loop

     if ((g_pd_costs(l_dist_index).budget_year_id = p_budget_year_id)
	and (g_pd_costs(l_dist_index).element_type = 'F')
	and (g_pd_costs(l_dist_index).element_set_id = l_element_set_id)) then

       if not FND_API.to_Boolean(p_redistribute) then
       begin

	 for l_period_index in 1..g_num_periods loop
	 if ((g_periods(l_period_index).ccid = g_pd_costs(l_dist_index).ccid)
		and (g_periods(l_period_index).element_set_id = g_pd_costs(l_dist_index).element_set_id)
		and (g_periods(l_period_index).element_type = 'F')
		and (g_periods(l_period_index).budget_year_id = g_pd_costs(l_dist_index).budget_year_id)) then

	   Distribute_Periods
	     (p_return_status           => l_return_status,
	      p_ccid                    => g_pd_costs(l_dist_index).ccid,
	      p_element_type            => 'F',
	      p_element_set_id          => g_pd_costs(l_dist_index).element_set_id,
	      p_budget_year_id          => p_budget_year_id,
	      p_dist_start_date         => g_periods(l_period_index).period_start_date,
	      p_dist_end_date           => g_periods(l_period_index).period_end_date,
	      p_start_date              => p_start_date,
	      p_end_date                => p_end_date,
	      p_element_index           => l_element_index,
	      p_dist_index              => l_dist_index,
	      p_percent                 => g_periods(l_period_index).percent);

	   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	     raise FND_API.G_EXC_ERROR;
	   end if;

	  end if;
	  end loop;

	end;
	end if;

     end if;
   end loop;

   if p_rounding_factor is not null then
     l_rounding_difference := l_rounding_difference +
				(round(g_pc_costs(l_element_index).element_cost / p_rounding_factor)
				    * p_rounding_factor - g_pc_costs(l_element_index).element_cost);
   end if;

   g_pc_costs(l_element_index).element_cost := g_pc_costs(l_element_index).element_cost +
							   l_rounding_difference;
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

END Distribute_Following_Elements;

/* ------------------------------------------------------------------------- */
-- Compute the Account distribution for the Following Elements

PROCEDURE Distribute_Periods
( p_return_status               OUT  NOCOPY  VARCHAR2,
  p_ccid                        IN   NUMBER,
  p_element_type                IN   VARCHAR2,
  p_element_set_id              IN   NUMBER,
  p_budget_year_id              IN   NUMBER,
  p_dist_start_date             IN   DATE,
  p_dist_end_date               IN   DATE,
  p_start_date                  IN   DATE,
  p_end_date                    IN   DATE,
  p_element_index               IN   NUMBER,
  p_dist_index                  IN   NUMBER,
  p_percent                     IN   NUMBER
) IS

  l_num_budget_periods          NUMBER := 0;
  l_dist_periods                NUMBER;
  l_no_init_dist_periods        NUMBER;
  l_dist_flag                   VARCHAR2(1);
  l_start_num                   NUMBER;
  l_end_num                     NUMBER;

  l_year_index                  BINARY_INTEGER;

  /* Bug 3610713 Start */
  l_year_start_date             DATE;
  l_ctr                         NUMBER;
  /* Bug 3610713 End */

BEGIN
      /* Bug 3610713 Start */
      FOR l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years
      LOOP

      IF PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id = p_budget_year_id THEN
        l_year_start_date := PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
      END IF;

      END LOOP;
      /* Bug 3610713 End */

      l_num_budget_periods := 0;
      for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_periods loop
	if (PSB_WS_ACCT1.g_budget_periods(l_year_index).budget_year_id = p_budget_year_id) then
	   l_num_budget_periods := l_num_budget_periods + 1;
	end if;
      end loop;

      l_dist_periods := (l_num_budget_periods * months_between(p_dist_end_date, p_dist_start_date - 1)) / 12;
      l_no_init_dist_periods := (l_num_budget_periods * months_between(p_dist_start_date, p_start_date)) / 12;

      l_dist_flag := NULL;

      IF (l_no_init_dist_periods = 0) THEN

        /* Bug 3610713 Start */
        IF l_year_start_date < p_dist_start_date THEN

          l_ctr := 0;
        FOR l_period_index IN 1..PSB_WS_ACCT1.g_num_budget_periods
        LOOP

          IF PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id =
                                                      p_budget_year_id THEN
            l_ctr := l_ctr +1 ;
          END IF;

          IF PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id =
             p_budget_year_id  AND
             p_dist_start_date BETWEEN
             PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date AND
             PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date THEN

              l_start_num := l_ctr;
              l_end_num   := (l_ctr-1) + ceil(l_dist_periods);
          END IF;
        END LOOP;
        ELSE
          l_start_num := 1;
          l_end_num   := ceil(l_dist_periods);
        END IF;
        /* Bug 3610713 End */
	  l_dist_flag := 'Y';

      ELSE

        /* Bug 3610713 Start */
        IF l_year_start_date < p_dist_start_date THEN

          l_ctr := 0;
        FOR l_period_index IN 1..PSB_WS_ACCT1.g_num_budget_periods
        LOOP

          IF PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id =
                                                      p_budget_year_id THEN
            l_ctr := l_ctr +1 ;
          END IF;

          IF PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id =
             p_budget_year_id  AND
             p_dist_start_date BETWEEN
             PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date AND
             PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date THEN

              l_start_num := l_ctr;
              l_end_num   := (l_ctr-1) + ceil(l_dist_periods);
          END IF;
        END LOOP;
        ELSE
          l_start_num := floor(l_no_init_dist_periods+1);
	  l_end_num   := ceil(least(l_no_init_dist_periods + l_dist_periods, l_num_budget_periods));
        END IF;
        /* Bug 3610713 End */

      END IF;

     if ((g_pd_costs(p_dist_index).ccid = p_ccid)
       and (g_pd_costs(p_dist_index).element_type = p_element_type)
       and (g_pd_costs(p_dist_index).element_set_id = p_element_set_id)
       and (g_pd_costs(p_dist_index).budget_year_id = p_budget_year_id)) then

	if 1 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period1_amount  := nvl(g_pd_costs(p_dist_index).period1_amount,0)
							+ nvl(g_pc_costs(p_element_index).period1_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period1_amount,0) * p_percent;
	end if;

	if 2 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period2_amount  := nvl(g_pd_costs(p_dist_index).period2_amount,0)
							+ nvl(g_pc_costs(p_element_index).period2_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period2_amount,0) * p_percent;
	end if;

	if 3 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period3_amount  := nvl(g_pd_costs(p_dist_index).period3_amount,0)
							+ nvl(g_pc_costs(p_element_index).period3_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period3_amount,0) * p_percent;
	end if;

	if 4 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period4_amount  := nvl(g_pd_costs(p_dist_index).period4_amount,0)
							+ nvl(g_pc_costs(p_element_index).period4_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period4_amount,0) * p_percent;
	end if;

	if 5 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period5_amount  := nvl(g_pd_costs(p_dist_index).period5_amount,0)
							+ nvl(g_pc_costs(p_element_index).period5_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period5_amount,0) * p_percent;
	end if;

	if 6 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period6_amount  := nvl(g_pd_costs(p_dist_index).period6_amount,0)
							+ nvl(g_pc_costs(p_element_index).period6_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period6_amount,0) * p_percent;
	end if;

	if 7 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period7_amount  := nvl(g_pd_costs(p_dist_index).period7_amount,0)
							+ nvl(g_pc_costs(p_element_index).period7_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period7_amount,0) * p_percent;
	end if;

	if 8 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period8_amount  := nvl(g_pd_costs(p_dist_index).period8_amount,0)
							+ nvl(g_pc_costs(p_element_index).period8_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period8_amount,0) * p_percent;
	end if;

	if 9 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period9_amount  := nvl(g_pd_costs(p_dist_index).period9_amount,0)
							+ nvl(g_pc_costs(p_element_index).period9_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period9_amount,0) * p_percent;
	end if;

	if 10 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period10_amount  := nvl(g_pd_costs(p_dist_index).period10_amount,0)
							+ nvl(g_pc_costs(p_element_index).period10_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period10_amount,0) * p_percent;
	end if;

	if 11 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period11_amount  := nvl(g_pd_costs(p_dist_index).period11_amount,0)
							+ nvl(g_pc_costs(p_element_index).period11_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period11_amount,0) * p_percent;
	end if;

	if 12 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period12_amount  := nvl(g_pd_costs(p_dist_index).period12_amount,0)
							+ nvl(g_pc_costs(p_element_index).period12_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period12_amount,0) * p_percent;
	end if;

	if 13 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period13_amount  := nvl(g_pd_costs(p_dist_index).period13_amount,0)
							+ nvl(g_pc_costs(p_element_index).period13_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period1_amount,0) * p_percent;
	end if;

	if 14 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period14_amount  := nvl(g_pd_costs(p_dist_index).period14_amount,0)
							+ nvl(g_pc_costs(p_element_index).period14_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period14_amount,0) * p_percent;
	end if;

	if 15 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period15_amount  := nvl(g_pd_costs(p_dist_index).period15_amount,0)
							+ nvl(g_pc_costs(p_element_index).period15_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period15_amount,0) * p_percent;
	end if;

	if 16 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period16_amount  := nvl(g_pd_costs(p_dist_index).period16_amount,0)
							+ nvl(g_pc_costs(p_element_index).period16_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period16_amount,0) * p_percent;
	end if;

	if 17 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period17_amount  := nvl(g_pd_costs(p_dist_index).period17_amount,0)
							+ nvl(g_pc_costs(p_element_index).period17_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period17_amount,0) * p_percent;
	end if;

	if 18 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period18_amount  := nvl(g_pd_costs(p_dist_index).period18_amount,0)
							+ nvl(g_pc_costs(p_element_index).period18_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period18_amount,0) * p_percent;
	end if;

	if 19 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period19_amount  := nvl(g_pd_costs(p_dist_index).period19_amount,0)
							+ nvl(g_pc_costs(p_element_index).period19_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period19_amount,0) * p_percent;
	end if;

	if 20 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period20_amount  := nvl(g_pd_costs(p_dist_index).period20_amount,0)
							+ nvl(g_pc_costs(p_element_index).period20_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period20_amount,0) * p_percent;
	end if;

	if 21 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period21_amount  := nvl(g_pd_costs(p_dist_index).period21_amount,0)
							+ nvl(g_pc_costs(p_element_index).period21_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period21_amount,0) * p_percent;
	end if;

	if 22 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period22_amount  := nvl(g_pd_costs(p_dist_index).period22_amount,0)
							+ nvl(g_pc_costs(p_element_index).period22_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period22_amount,0) * p_percent;
	end if;

	if 23 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period23_amount  := nvl(g_pd_costs(p_dist_index).period23_amount,0)
							+ nvl(g_pc_costs(p_element_index).period23_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period23_amount,0) * p_percent;
	end if;

	if 24 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period24_amount  := nvl(g_pd_costs(p_dist_index).period24_amount,0)
							+ nvl(g_pc_costs(p_element_index).period24_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period24_amount,0) * p_percent;
	end if;

	if 25 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period25_amount  := nvl(g_pd_costs(p_dist_index).period25_amount,0)
							+ nvl(g_pc_costs(p_element_index).period25_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period25_amount,0) * p_percent;
	end if;

	if 26 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period26_amount  := nvl(g_pd_costs(p_dist_index).period26_amount,0)
							+ nvl(g_pc_costs(p_element_index).period26_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period26_amount,0) * p_percent;
	end if;

	if 27 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period27_amount  := nvl(g_pd_costs(p_dist_index).period27_amount,0)
							+ nvl(g_pc_costs(p_element_index).period27_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period27_amount,0) * p_percent;
	end if;

	if 28 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period28_amount  := nvl(g_pd_costs(p_dist_index).period28_amount,0)
							+ nvl(g_pc_costs(p_element_index).period28_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period28_amount,0) * p_percent;
	end if;

	if 29 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period29_amount  := nvl(g_pd_costs(p_dist_index).period29_amount,0)
							+ nvl(g_pc_costs(p_element_index).period29_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period29_amount,0) * p_percent;
	end if;

	if 30 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period30_amount  := nvl(g_pd_costs(p_dist_index).period30_amount,0)
							+ nvl(g_pc_costs(p_element_index).period30_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period30_amount,0) * p_percent;
	end if;

	if 31 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period31_amount  := nvl(g_pd_costs(p_dist_index).period31_amount,0)
							+ nvl(g_pc_costs(p_element_index).period31_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period31_amount,0) * p_percent;
	end if;

	if 32 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period32_amount  := nvl(g_pd_costs(p_dist_index).period32_amount,0)
							+ nvl(g_pc_costs(p_element_index).period32_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period32_amount,0) * p_percent;
	end if;

	if 33 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period33_amount  := nvl(g_pd_costs(p_dist_index).period33_amount,0)
							+ nvl(g_pc_costs(p_element_index).period33_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period33_amount,0) * p_percent;
	end if;

	if 34 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period34_amount  := nvl(g_pd_costs(p_dist_index).period34_amount,0)
							+ nvl(g_pc_costs(p_element_index).period34_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period34_amount,0) * p_percent;
	end if;

	if 35 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period35_amount  := nvl(g_pd_costs(p_dist_index).period35_amount,0)
							+ nvl(g_pc_costs(p_element_index).period35_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period35_amount,0) * p_percent;
	end if;

	if 36 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period36_amount  := nvl(g_pd_costs(p_dist_index).period36_amount,0)
							+ nvl(g_pc_costs(p_element_index).period36_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period36_amount,0) * p_percent;
	end if;

	if 37 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period37_amount  := nvl(g_pd_costs(p_dist_index).period37_amount,0)
							+ nvl(g_pc_costs(p_element_index).period37_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period37_amount,0) * p_percent;
	end if;

	if 38 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period38_amount  := nvl(g_pd_costs(p_dist_index).period38_amount,0)
							+ nvl(g_pc_costs(p_element_index).period38_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period38_amount,0) * p_percent;
	end if;

	if 39 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period39_amount  := nvl(g_pd_costs(p_dist_index).period39_amount,0)
							+ nvl(g_pc_costs(p_element_index).period39_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period39_amount,0) * p_percent;
	end if;

	if 40 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period40_amount  := nvl(g_pd_costs(p_dist_index).period40_amount,0)
							+ nvl(g_pc_costs(p_element_index).period40_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period40_amount,0) * p_percent;
	end if;

	if 41 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period4_amount  := nvl(g_pd_costs(p_dist_index).period41_amount,0)
							+ nvl(g_pc_costs(p_element_index).period41_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period41_amount,0) * p_percent;
	end if;

	if 42 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period42_amount  := nvl(g_pd_costs(p_dist_index).period42_amount,0)
							+ nvl(g_pc_costs(p_element_index).period42_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period42_amount,0) * p_percent;
	end if;

	if 43 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period43_amount  := nvl(g_pd_costs(p_dist_index).period43_amount,0)
							+ nvl(g_pc_costs(p_element_index).period43_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period43_amount,0) * p_percent;
	end if;

	if 44 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period44_amount  := nvl(g_pd_costs(p_dist_index).period44_amount,0)
							+ nvl(g_pc_costs(p_element_index).period44_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period44_amount,0) * p_percent;
	end if;

	if 45 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period45_amount  := nvl(g_pd_costs(p_dist_index).period45_amount,0)
							+ nvl(g_pc_costs(p_element_index).period45_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period45_amount,0) * p_percent;
	end if;

	if 46 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period46_amount  := nvl(g_pd_costs(p_dist_index).period46_amount,0)
							+ nvl(g_pc_costs(p_element_index).period46_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period46_amount,0) * p_percent;
	end if;

	if 47 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period47_amount  := nvl(g_pd_costs(p_dist_index).period47_amount,0)
							+ nvl(g_pc_costs(p_element_index).period47_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period47_amount,0) * p_percent;
	end if;

	if 48 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period48_amount  := nvl(g_pd_costs(p_dist_index).period48_amount,0)
							+ nvl(g_pc_costs(p_element_index).period48_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period48_amount,0) * p_percent;
	end if;

	if 49 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period49_amount  := nvl(g_pd_costs(p_dist_index).period49_amount,0)
							+ nvl(g_pc_costs(p_element_index).period49_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period49_amount,0) * p_percent;
	end if;

	if 50 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period50_amount  := nvl(g_pd_costs(p_dist_index).period50_amount,0)
							+ nvl(g_pc_costs(p_element_index).period50_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period50_amount,0) * p_percent;
	end if;

	if 51 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period51_amount  := nvl(g_pd_costs(p_dist_index).period51_amount,0)
							+ nvl(g_pc_costs(p_element_index).period51_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period51_amount,0) * p_percent;
	end if;

	if 52 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period52_amount  := nvl(g_pd_costs(p_dist_index).period52_amount,0)
							+ nvl(g_pc_costs(p_element_index).period52_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period52_amount,0) * p_percent;
	end if;

	if 53 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period53_amount  := nvl(g_pd_costs(p_dist_index).period53_amount,0)
							+ nvl(g_pc_costs(p_element_index).period53_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period53_amount,0) * p_percent;
	end if;

	if 54 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period54_amount  := nvl(g_pd_costs(p_dist_index).period54_amount,0)
							+ nvl(g_pc_costs(p_element_index).period54_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period54_amount,0) * p_percent;
	end if;

	if 55 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period55_amount  := nvl(g_pd_costs(p_dist_index).period55_amount,0)
							+ nvl(g_pc_costs(p_element_index).period55_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period55_amount,0) * p_percent;
	end if;

	if 56 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period56_amount  := nvl(g_pd_costs(p_dist_index).period56_amount,0)
							+ nvl(g_pc_costs(p_element_index).period56_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period56_amount,0) * p_percent;
	end if;

	if 57 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period57_amount  := nvl(g_pd_costs(p_dist_index).period57_amount,0)
							+ nvl(g_pc_costs(p_element_index).period57_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period57_amount,0) * p_percent;
	end if;

	if 58 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period58_amount  := nvl(g_pd_costs(p_dist_index).period58_amount,0)
							+ nvl(g_pc_costs(p_element_index).period58_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period58_amount,0) * p_percent;
	end if;

	if 59 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period59_amount  := nvl(g_pd_costs(p_dist_index).period59_amount,0)
							+ nvl(g_pc_costs(p_element_index).period59_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period59_amount,0) * p_percent;
	end if;

	if 60 between l_start_num and l_end_num then
	   g_pd_costs(p_dist_index).period60_amount  := nvl(g_pd_costs(p_dist_index).period60_amount,0)
							+ nvl(g_pc_costs(p_element_index).period60_amount,0) * p_percent;
	   g_pd_costs(p_dist_index).ytd_amount := nvl(g_pd_costs(p_dist_index).ytd_amount, 0)
							+ nvl(g_pc_costs(p_element_index).period60_amount,0) * p_percent;
	end if;

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

END Distribute_Periods;

/* Bug No 2278216 End */
/* ------------------------------------------------------------------------- */

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

  -- This Module is used to retrieve Debug Information for this Package. It
  -- prints Debug Information when run as a Batch Process from SQL*Plus. For
  -- the Debug Information to be printed on the Screen, the SQL*Plus parameter
  -- 'Serveroutput' should be set to 'ON'

FUNCTION Get_Debug RETURN VARCHAR2 IS
BEGIN
  return(g_dbug);
END Get_Debug;

/* ----------------------------------------------------------------------- */

END PSB_WS_POS1;

/
