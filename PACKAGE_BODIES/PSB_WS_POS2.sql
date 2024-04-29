--------------------------------------------------------
--  DDL for Package Body PSB_WS_POS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_POS2" AS
/* $Header: PSBVWP2B.pls 120.22.12010000.11 2010/04/03 11:10:35 rkotha ship $ */

  G_PKG_NAME     CONSTANT  VARCHAR2(30):= 'PSB_WS_POS2';

  g_default_fte  CONSTANT  NUMBER := 0; --bug:7461135:modified default value to '0'
  g_pos_start_date         DATE; -- bug 5065066

  TYPE g_poselasgn_rec_type IS RECORD
     ( worksheet_id           NUMBER,
       start_date             DATE,
       end_date               DATE,
       pay_element_id         NUMBER,
       pay_element_option_id  NUMBER,
       pay_basis              VARCHAR2(10),
       element_value_type     VARCHAR2(2),
       element_value          NUMBER,
       use_in_calc            BOOLEAN,
       salary_flag            VARCHAR2(1) --bug:5880186
       );

  TYPE g_poselasgn_tbl_type IS TABLE OF g_poselasgn_rec_type
      INDEX BY BINARY_INTEGER;

  g_poselem_assignments      g_poselasgn_tbl_type;
  g_num_poselem_assignments  NUMBER;

  /*bug:5635570:start*/
  g_recalc_flag       BOOLEAN := FALSE;
  /*bug:5635570:end*/

  TYPE g_poselrate_rec_type IS RECORD
     ( worksheet_id           NUMBER,
       start_date             DATE,
       end_date               DATE,
       pay_element_id         NUMBER,
       pay_element_option_id  NUMBER,
       pay_basis              VARCHAR2(10),
       element_value_type     VARCHAR2(2),
       element_value          NUMBER,
       formula_id             NUMBER );

  TYPE g_poselrate_tbl_type IS TABLE OF g_poselrate_rec_type
      INDEX BY BINARY_INTEGER;

  g_poselem_rates            g_poselrate_tbl_type;
  g_num_poselem_rates        NUMBER;

  TYPE g_posfte_rec_type IS RECORD
     ( worksheet_id          NUMBER,
       start_date            DATE,
       end_date              DATE,
       fte                   NUMBER );

  TYPE g_posfte_tbl_type IS TABLE OF g_posfte_rec_type
      INDEX BY BINARY_INTEGER;

  g_posfte_assignments       g_posfte_tbl_type;
  g_num_posfte_assignments   NUMBER;

  TYPE g_poswkh_rec_type IS RECORD
     ( worksheet_id          NUMBER,
       start_date            DATE,
       end_date              DATE,
       default_weekly_hours  NUMBER );

  TYPE g_poswkh_tbl_type IS TABLE OF g_poswkh_rec_type
      INDEX BY BINARY_INTEGER;

  g_poswkh_assignments      g_poswkh_tbl_type;
  g_num_poswkh_assignments  NUMBER;

  g_monthly_profile          PSB_WS_ACCT1.g_prdamt_tbl_type;
  g_num_monthly_profile      NUMBER := 0;

  g_quarterly_profile        PSB_WS_ACCT1.g_prdamt_tbl_type;
  g_num_quarterly_profile    NUMBER := 0;

  g_semiannual_profile       PSB_WS_ACCT1.g_prdamt_tbl_type;
  g_num_semiannual_profile   NUMBER := 0;

  TYPE g_posrecalc_rec_type IS RECORD
     ( element_line_id NUMBER, pay_element_id NUMBER,
       service_package_id NUMBER, recalc_flag VARCHAR2(1));

  TYPE g_posrecalc_tbl_type IS TABLE OF g_posrecalc_rec_type
      INDEX BY BINARY_INTEGER;

  g_pc_recalc_costs      g_posrecalc_tbl_type;
  g_num_pc_recalc_costs  NUMBER;

  TYPE g_posredist_rec_type IS RECORD
     ( account_line_id NUMBER, ccid NUMBER, service_package_id NUMBER,
       element_set_id NUMBER, budget_group_id NUMBER, redist_flag VARCHAR2(1));

  TYPE g_posredist_tbl_type IS TABLE OF g_posredist_rec_type
      INDEX BY BINARY_INTEGER;

  g_pd_recalc_costs      g_posredist_tbl_type;
  g_num_pd_recalc_costs  NUMBER;

  TYPE g_posrecalcfte_rec_type IS RECORD
     ( fte_line_id NUMBER, annual_fte NUMBER, ratio NUMBER,
       service_package_id NUMBER, recalc_flag VARCHAR2(1));

  TYPE g_posrecalcfte_tbl_type IS TABLE OF g_posrecalcfte_rec_type
      INDEX BY BINARY_INTEGER;

  g_pf_recalc_fte        g_posrecalcfte_tbl_type;
  g_num_pf_recalc_fte    NUMBER;

  TYPE TokNameArray IS TABLE OF VARCHAR2(100)
    INDEX BY BINARY_INTEGER;

  TYPE TokValArray IS TABLE OF VARCHAR2(1000)
    INDEX BY BINARY_INTEGER;

/* Bug No 1920021 Start */
  g_weekly_hours_worksheet_id   NUMBER;
/* Bug No 1920021 End */

/*For Bug No : 2811698 Start*/
  g_fte_profile_option          VARCHAR2(1);
/*For Bug No : 2811698 End*/

  -- Number of Message Tokens

  no_msg_tokens              NUMBER := 0;

  -- Message Token Name

  msg_tok_names              TokNameArray;

  -- Message Token Value

  msg_tok_val                TokValArray;

  g_dbug                     VARCHAR2(1000);

/* ----------------------------------------------------------------------- */
/*                      Private Function Definition                        */
/* ----------------------------------------------------------------------- */


/*===========================================================================+
 |                             PROCEDURE pd                                  |
 +===========================================================================*/
--
-- API to print debug information, used during only development.
--
PROCEDURE pd( p_message   IN     VARCHAR2)
IS
BEGIN
  NULL ;
  --DBMS_OUTPUT.Put_Line(p_message) ;
END pd ;
/*---------------------------------------------------------------------------*/


PROCEDURE Calculate_Position_Cost_Year
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_data_extract_id    IN   NUMBER,
  p_business_group_id  IN   NUMBER,
  p_position_line_id   IN   NUMBER,
  p_position_id        IN   NUMBER,
  p_position_name      IN   VARCHAR2,
  p_budget_year_id     IN   NUMBER,
  p_year_start_date    IN   DATE,
  p_year_end_date      IN   DATE
);

PROCEDURE Cache_FTE_Profile
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_position_id        IN   NUMBER,
  p_data_extract_id    IN   NUMBER,
  p_business_group_id  IN   NUMBER
);

PROCEDURE Distribute_Position_Cost
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_root_budget_group_id  IN   NUMBER,
  p_flex_code             IN   NUMBER,
  p_rounding_factor       IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_business_group_id     IN   NUMBER,
  p_position_id           IN   NUMBER,
  p_position_line_id      IN   NUMBER,
  p_budget_year_id        IN   NUMBER,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE
);

PROCEDURE Distribute_Salary
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_pay_element_id        IN   NUMBER,
  p_root_budget_group_id  IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_flex_code             IN   NUMBER,
  p_rounding_factor       IN   NUMBER,
  p_position_line_id      IN   NUMBER,
  p_position_id           IN   NUMBER,
  p_budget_year_id        IN   NUMBER,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE
);

PROCEDURE Distribute_Other_Elements
( p_return_status     OUT  NOCOPY  VARCHAR2,
  p_pay_element_id    IN   NUMBER,
  p_data_extract_id   IN   NUMBER,
  p_flex_code         IN   NUMBER,
  p_rounding_factor   IN   NUMBER,
  p_position_line_id  IN   NUMBER,
  p_position_id       IN   NUMBER,
  p_budget_year_id    IN   NUMBER,
  p_start_date        IN   DATE,
  p_end_date          IN   DATE
);

PROCEDURE Update_Position_Cost
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_position_line_id     IN   NUMBER,
  p_position_start_date  IN   DATE,
  p_position_end_date    IN   DATE,
  p_worksheet_id         IN   NUMBER,
  p_flex_mapping_set_id  IN   NUMBER,
  p_global_worksheet_id  IN   NUMBER,
  p_func_currency        IN   VARCHAR2,
  p_rounding_factor      IN   NUMBER,
  p_service_package_id   IN   NUMBER,
  p_stage_set_id         IN   NUMBER,
  p_start_stage_seq      IN   NUMBER,
  p_current_stage_seq    IN   NUMBER,
  p_budget_year_id       IN   NUMBER,
  p_budget_group_id      IN   NUMBER
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

PROCEDURE Create_Worksheet_Positions
( p_return_status              OUT  NOCOPY  VARCHAR2,
  p_root_budget_group_id       IN   NUMBER,
  p_global_worksheet_id        IN   NUMBER,
  p_worksheet_id               IN   NUMBER,
  p_global_worksheet           IN   VARCHAR2,
  p_budget_group_id            IN   NUMBER,
  p_worksheet_numyrs           IN   NUMBER,
  p_rounding_factor            IN   NUMBER,
  p_service_package_id         IN   NUMBER,
  p_stage_set_id               IN   NUMBER,
  p_start_stage_seq            IN   NUMBER,
  p_current_stage_seq          IN   NUMBER,
  p_data_extract_id            IN   NUMBER,
  p_business_group_id          IN   NUMBER,
  p_budget_calendar_id         IN   NUMBER,
  p_parameter_set_id           IN   NUMBER,
  p_func_currency              IN   VARCHAR2,
  p_flex_mapping_set_id        IN   NUMBER,
  p_flex_code                  IN   NUMBER,
  p_apply_element_parameters   IN   VARCHAR2,
  p_apply_position_parameters  IN   VARCHAR2
) IS

  l_position_line_id           NUMBER;
  l_num_positions              NUMBER := 0;

  l_return_status              VARCHAR2(1);

  cursor c_Positions is
    select position_id,
	   name,
	   effective_start_date,
	   effective_end_date
      from PSB_POSITIONS
     where (((effective_start_date <= PSB_WS_ACCT1.g_end_est_date)
	 and (effective_end_date is null))
	 or ((effective_start_date between PSB_WS_ACCT1.g_startdate_cy and PSB_WS_ACCT1.g_end_est_date)
	  or (effective_end_date between PSB_WS_ACCT1.g_startdate_cy and PSB_WS_ACCT1.g_end_est_date)
	 or ((effective_start_date < PSB_WS_ACCT1.g_startdate_cy)
	 and (effective_end_date > PSB_WS_ACCT1.g_end_est_date))))
       and business_group_id = p_business_group_id
       and data_extract_id = p_data_extract_id;

BEGIN

  if ((nvl(PSB_WS_POS1.g_data_extract_id, FND_API.G_MISS_NUM) <> p_data_extract_id) or
      (nvl(PSB_WS_POS1.g_business_group_id, FND_API.G_MISS_NUM) <> p_business_group_id)) then
  begin

    PSB_WS_POS1.Cache_Elements
       (p_return_status => l_return_status,
	p_data_extract_id => p_data_extract_id,
	p_business_group_id => p_business_group_id,
	p_worksheet_id => p_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  if nvl(PSB_WS_POS1.g_attr_busgrp_id, FND_API.G_MISS_NUM) <> p_business_group_id then
  begin

    PSB_WS_POS1.Cache_Named_Attributes
       (p_return_status => l_return_status,
	p_business_group_id => p_business_group_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  if FND_API.to_Boolean(p_apply_element_parameters) then
  begin

    PSB_WS_POS3.Apply_Element_Parameters
       (p_api_version => 1.0,
	p_worksheet_id => p_worksheet_id,
	p_global_worksheet => p_global_worksheet,
	p_budget_group_id => p_budget_group_id,
	p_data_extract_id => p_data_extract_id,
	p_business_group_id => p_business_group_id,
	p_func_currency => p_func_currency,
	p_budget_calendar_id => p_budget_calendar_id,
	p_parameter_set_id => p_parameter_set_id,
	p_return_status => l_return_status);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  commit work;

  if FND_API.to_Boolean(p_apply_position_parameters) then
  begin

  PSB_WS_POS3.Apply_Position_Parameters
     (p_api_version => 1.0,
      p_worksheet_id => p_worksheet_id,
      p_global_worksheet => p_global_worksheet,
      p_budget_group_id => p_budget_group_id,
      p_data_extract_id => p_data_extract_id,
      p_business_group_id => p_business_group_id,
      p_func_currency => p_func_currency,
      p_budget_calendar_id => p_budget_calendar_id,
      p_parameter_set_id => p_parameter_set_id,
      p_return_status => l_return_status);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  end;
  end if;

  commit work;

  for c_Positions_Rec in c_Positions loop

    PSB_WS_POS1.g_salary_budget_group_id := null;

    PSB_WS_POS1.Cache_Salary_Dist
       (p_return_status => l_return_status,
	p_worksheet_id => p_global_worksheet_id,
	p_root_budget_group_id => p_root_budget_group_id,
	p_flex_code => p_flex_code,
	p_data_extract_id => p_data_extract_id,
	p_position_id => c_Positions_Rec.position_id,
	p_position_name => c_Positions_Rec.name,
	p_start_date => PSB_WS_ACCT1.g_startdate_cy,
	p_end_date => PSB_WS_ACCT1.g_end_est_date);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    PSB_WS_POS1.Create_Position_Lines
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_position_line_id => l_position_line_id,
	p_worksheet_id => p_worksheet_id,
	p_position_id => c_Positions_Rec.position_id,
	p_budget_group_id => PSB_WS_POS1.g_salary_budget_group_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    G_POS_START_DATE := c_Positions_Rec.effective_start_date; -- Bug 5065066

    Calculate_Position_Cost
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_worksheet_id => p_worksheet_id,
	      p_position_line_id => l_position_line_id,
	      p_recalculate_flag => FND_API.G_TRUE,
	      p_root_budget_group_id => p_root_budget_group_id,
	      p_global_worksheet_id => p_global_worksheet_id,
	      p_assign_worksheet_id => p_global_worksheet_id,
	      p_worksheet_numyrs => p_worksheet_numyrs,
	      p_rounding_factor => p_rounding_factor,
	      p_service_package_id => p_service_package_id,
	      p_stage_set_id => p_stage_set_id,
	      p_start_stage_seq => p_start_stage_seq,
	      p_current_stage_seq => p_current_stage_seq,
	      p_data_extract_id => p_data_extract_id,
	      p_business_group_id => p_business_group_id,
	      p_budget_calendar_id => p_budget_calendar_id,
	      p_func_currency => p_func_currency,
	      p_flex_mapping_set_id => p_flex_mapping_set_id,
	      p_flex_code => p_flex_code,
	      p_position_id => c_Positions_Rec.position_id,
	      p_position_name => c_Positions_Rec.name,
	      p_position_start_date => c_Positions_Rec.effective_start_date,
	      p_position_end_date => c_Positions_Rec.effective_end_date);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    l_num_positions := l_num_positions + 1;

    if l_num_positions > PSB_WS_ACCT1.g_checkpoint_save then
      commit work;
      l_num_positions := 0;
    end if;

  end loop;


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
	   p_procedure_name => 'Create_Worksheet_Positions');
     end if;

END Create_Worksheet_Positions;

/* ----------------------------------------------------------------------- */

PROCEDURE Calculate_Position_Cost
( p_api_version           IN   NUMBER,
  p_validation_level      IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id          IN   NUMBER,
  p_position_line_id      IN   NUMBER,
  p_recalculate_flag      IN   VARCHAR2 := FND_API.G_TRUE,
  p_root_budget_group_id  IN   NUMBER,
  p_global_worksheet_id   IN   NUMBER,
  p_assign_worksheet_id   IN   NUMBER,
  p_worksheet_numyrs      IN   NUMBER,
  p_rounding_factor       IN   NUMBER,
  p_service_package_id    IN   NUMBER,
  p_stage_set_id          IN   NUMBER,
  p_start_stage_seq       IN   NUMBER,
  p_current_stage_seq     IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_business_group_id     IN   NUMBER,
  p_budget_calendar_id    IN   NUMBER,
  p_func_currency         IN   VARCHAR2,
  p_flex_mapping_set_id   IN   NUMBER,
  p_flex_code             IN   NUMBER,
  p_position_id           IN   NUMBER,
  p_position_name         IN   VARCHAR2,
  p_position_start_date   IN   DATE,
  p_position_end_date     IN   DATE,
  p_budget_year_id        IN   NUMBER,
  /*Start bug:5635570*/
  p_lparam_flag           IN   VARCHAR2 := FND_API.G_FALSE
  /*End bug:5635570*/
) IS

  l_api_name              CONSTANT VARCHAR2(30) := 'Calculate_Position_Cost';
  l_api_version           CONSTANT NUMBER       := 1.0;

  l_start_date            DATE;
  l_end_date              DATE;

  l_init_index            BINARY_INTEGER;
  l_year_index            BINARY_INTEGER;

  l_global_worksheet_id   NUMBER;
  l_assign_worksheet_id   NUMBER;
  l_stage_set_id          NUMBER;
  l_data_extract_id       NUMBER;
  l_budget_group_id       NUMBER;
  l_budget_calendar_id    NUMBER;
  l_ws_num_years          NUMBER;
  l_rounding_factor       NUMBER;
  l_current_stage_seq     NUMBER;

  l_root_budget_group_id  NUMBER;
  l_business_group_id     NUMBER;
  l_func_currency         VARCHAR2(15);
  l_flex_code             NUMBER;

  l_position_line_id      NUMBER;
  l_position_id           NUMBER;
  l_position_name         VARCHAR2(240);
  l_position_start_date   DATE;
  l_position_end_date     DATE;

  /* bug 3446226 Start */
  l_fte_start_date   DATE;
  l_fte_end_date     DATE;
  /* bug 3446226 End */

  l_service_package_id    NUMBER;
  l_start_stage_seq       NUMBER;

  l_element_found         BOOLEAN;

  l_attribute_value       NUMBER;

  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);

  cursor c_WS is
    select nvl(global_worksheet_id, worksheet_id) global_worksheet_id,
	   decode(local_copy_flag, 'Y', worksheet_id, nvl(global_worksheet_id, worksheet_id)) assign_worksheet_id,
	   stage_set_id,
	   nvl(data_extract_id, global_data_extract_id) data_extract_id,
	   budget_group_id,
	   budget_calendar_id,
	   num_proposed_years,
	   rounding_factor,
	   current_stage_seq
      from PSB_WORKSHEETS_V
     where worksheet_id = p_worksheet_id;

  cursor c_SP is
    select service_package_id
      from PSB_SERVICE_PACKAGES
     where base_service_package = 'Y'
       and global_worksheet_id = l_global_worksheet_id;

  cursor c_BG is
    select nvl(root_budget_group_id, budget_group_id) root_budget_group_id,
	   nvl(business_group_id, root_business_group_id) business_group_id,
	   nvl(currency_code, root_currency_code) currency_code,
	   nvl(chart_of_accounts_id, root_chart_of_accounts_id) chart_of_accounts_id
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = l_budget_group_id;

  cursor c_Positions is
    select a.position_id,
	   a.name,
	   a.effective_start_date,
	   a.effective_end_date
      from PSB_POSITIONS a,
	   PSB_WS_POSITION_LINES b
     where a.position_id = b.position_id
       and b.position_line_id = p_position_line_id;

/* Bug No 2521570 Start */
/*****  cursor c_Element_Assignments is
    select worksheet_id,
	   pay_element_id,
	   pay_element_option_id,
	   pay_basis,
	   element_value_type,
	   element_value,
	   effective_start_date,
	   effective_end_date
      from PSB_POSITION_ASSIGNMENTS
     where (worksheet_id is null or worksheet_id = l_assign_worksheet_id)
       and currency_code = l_func_currency
       and assignment_type = 'ELEMENT'
       and (((effective_start_date <= l_end_date)
	 and (effective_end_date is null))
	 or ((effective_start_date between l_start_date and l_end_date)
	  or (effective_end_date between l_start_date and l_end_date)
	 or ((effective_start_date < l_start_date)
	 and (effective_end_date > l_end_date))))
       and position_id = l_position_id
     order by effective_start_date,
	      effective_end_date,
	      element_value desc;*****/

/*Bug:5648017:Modified the cursor c_Element_Assignments*/

cursor c_Element_Assignments is
select nvl(ppa.worksheet_id,l_assign_worksheet_id) worksheet_id,
       ppa.pay_element_id,
       ppa.pay_element_option_id,
       ppa.pay_basis,
       ppa.element_value_type,
       ppa.element_value,
       ppa.effective_start_date,
       ppa.effective_end_date,
       ppe.salary_flag         --bug:5880186
  from PSB_POSITION_ASSIGNMENTS ppa, psb_pay_elements ppe
 where ppa.currency_code = l_func_currency
   and ppa.assignment_type = 'ELEMENT'
   and ppa.position_id = l_position_id
   and ppa.pay_element_id = ppe.pay_element_id
   and ppa.data_extract_id = ppe.data_extract_id
   and ((ppa.effective_start_date between l_start_date and l_end_date) or
        (nvl(ppa.effective_end_date,l_end_date) between l_start_date and l_end_date) or
        ((ppa.effective_start_date < l_end_date and
        (nvl(ppa.effective_end_date,l_end_date) > l_start_date))))
   and (ppa.worksheet_id=l_assign_worksheet_id or (ppa.worksheet_id is null and
        ( not exists
         (select 1
            from psb_position_assignments ppa1, psb_pay_elements ppe1
           where ppa1.assignment_type = 'ELEMENT'
             and   ppa1.position_id = ppa.position_id
             and   ppa1.worksheet_id = l_assign_worksheet_id
             and   ppe1.pay_element_id = ppa1.pay_element_id
             and   ppe1.salary_flag = ppe.salary_flag
	     /*bug:6530657:start*/
	     and  ((ppe1.salary_flag = 'N' and ppe1.pay_element_id = ppe.pay_element_id)
	           or (ppe1.salary_flag = 'Y'))
	     /*bug:6530657:end*/
             and   (ppa1.effective_start_date between
                    ppa.effective_start_date and nvl(ppa.effective_end_date,ppa1.effective_start_date)
              or    ppa.effective_start_date between
                     ppa1.effective_start_date and nvl(ppa1.effective_end_date,ppa.effective_start_date))
              ))))
  order by ppa.effective_start_date,ppa.effective_end_date;

/*End of modification for bug:5648017*/

/* Bug No 2521570 End */

  cursor c_Element_Rates is
    select a.worksheet_id,
	   a.pay_element_id,
	   a.pay_element_option_id,
	   a.pay_basis,
	   a.element_value_type,
	   a.element_value,
	   a.formula_id,
	   a.effective_start_date,
	   a.effective_end_date
      from PSB_PAY_ELEMENT_RATES a,
	   PSB_PAY_ELEMENTS b
     where (a.worksheet_id is null or a.worksheet_id = l_global_worksheet_id)
       and a.currency_code = l_func_currency
       and exists
	  (select 1
	     from PSB_POSITION_ASSIGNMENTS c
	    where nvl(c.pay_element_option_id, FND_API.G_MISS_NUM) = nvl(a.pay_element_option_id, FND_API.G_MISS_NUM)
	      and (c.worksheet_id is null or c.worksheet_id = l_assign_worksheet_id)
	      and c.currency_code = l_func_currency
	      and (((c.effective_start_date <= l_end_date)
		and (c.effective_end_date is null))
		or ((c.effective_start_date between l_start_date and l_end_date)
		 or (c.effective_end_date between l_start_date and l_end_date)
		or ((c.effective_start_date < l_start_date)
		and (c.effective_end_date > l_end_date))))
	      and c.pay_element_id = a.pay_element_id
	      and c.position_id = l_position_id)
       and (((a.effective_start_date <= l_end_date)
	 and (a.effective_end_date is null))
	 or ((a.effective_start_date between l_start_date and l_end_date)
	  or (a.effective_end_date between l_start_date and l_end_date)
	 or ((a.effective_start_date < l_start_date)
	 and (a.effective_end_date > l_end_date))))
       and a.pay_element_id = b.pay_element_id
       and b.business_group_id = l_business_group_id
       and b.data_extract_id = l_data_extract_id
     order by a.worksheet_id,
	      a.effective_start_date,
	      a.effective_end_date,
	      a.element_value desc;


 /*Bug:6392080:Modified query to pick worksheet level records only. If no worksheet level
          attribute record exists, then DE level record will be considered*/
  cursor c_Attribute_Assignments is
    select worksheet_id,
	   effective_start_date,
	   effective_end_date,
	   attribute_id,
           -- Fixed bug # 3683644
	   FND_NUMBER.canonical_to_number(attribute_value) attribute_value,
	   attribute_value_id
      from PSB_POSITION_ASSIGNMENTS ppa
     where attribute_id in (PSB_WS_POS1.g_fte_id, PSB_WS_POS1.g_default_wklyhrs_id)
       and (worksheet_id = l_assign_worksheet_id or (worksheet_id is null and
       not exists
          (select 1
             from psb_position_assignments ppa1
            where ppa1.worksheet_id = l_assign_worksheet_id
              and ppa1.attribute_id = ppa.attribute_id
              and ppa1.data_extract_id = ppa.data_extract_id
              and ppa1.assignment_type = 'ATTRIBUTE'
              and ppa1.position_id = l_position_id
          )))
       and (worksheet_id is null or worksheet_id = l_assign_worksheet_id)
       and assignment_type = 'ATTRIBUTE'
       and (((effective_start_date <= l_end_date)
	 and (effective_end_date is null))
	 or ((effective_start_date between l_start_date and l_end_date)
	  or (effective_end_date between l_start_date and l_end_date)
	 or ((effective_start_date < l_start_date)
	 and (effective_end_date > l_end_date))))
       and position_id = l_position_id
     order by worksheet_id,
	      effective_start_date,
	      effective_end_date,
	      FND_NUMBER.canonical_to_number(attribute_value) desc; -- Fixed bug # 3683644

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if ((nvl(p_global_worksheet_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) or
      (nvl(p_assign_worksheet_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) or
      (nvl(p_worksheet_numyrs, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) or
      (nvl(p_rounding_factor, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) or
      (nvl(p_stage_set_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) or
      (nvl(p_current_stage_seq, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) or
      (nvl(p_data_extract_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) or
      (nvl(p_budget_calendar_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM)) then
  begin

    for c_WS_Rec in c_WS loop
      l_global_worksheet_id := c_WS_Rec.global_worksheet_id;
      l_assign_worksheet_id := c_WS_Rec.assign_worksheet_id;
      l_ws_num_years := c_WS_Rec.num_proposed_years;
      l_rounding_factor := c_WS_Rec.rounding_factor;
      l_stage_set_id := c_WS_Rec.stage_set_id;
      l_current_stage_seq := c_WS_Rec.current_stage_seq;
      l_data_extract_id := c_WS_Rec.data_extract_id;
      l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
      l_budget_group_id := c_WS_Rec.budget_group_id;
    end loop;

  end;
  end if;

  if nvl(p_global_worksheet_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
    l_global_worksheet_id := p_global_worksheet_id;
  end if;

  if nvl(p_assign_worksheet_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
    l_assign_worksheet_id := p_assign_worksheet_id;
  end if;

/* Bug No 1920021 Start */
   g_weekly_hours_worksheet_id := l_assign_worksheet_id;
/* Bug No 1920021 End */

  /*For Bug No : 2811698 Start*/
  --Cache the FTE profile option in a global field due to performance issues
  --and this will be used across the process
  IF g_fte_profile_option IS NULL THEN
    g_fte_profile_option := nvl(fnd_profile.value('PSB_USE_FTE_ALLOCATION'),'N');
   END IF;
  /*For Bug No : 2811698 End*/

  if nvl(p_worksheet_numyrs, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
    l_ws_num_years := p_worksheet_numyrs;
  end if;

  if nvl(p_rounding_factor, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
    l_rounding_factor := p_rounding_factor;
  end if;

  if nvl(p_stage_set_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
    l_stage_set_id := p_stage_set_id;
  end if;

  if nvl(p_current_stage_seq, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
    l_current_stage_seq := p_current_stage_seq;
  end if;

  if nvl(p_data_extract_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
    l_data_extract_id := p_data_extract_id;
  end if;

  if nvl(p_budget_calendar_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
    l_budget_calendar_id := p_budget_calendar_id;
  end if;

  if nvl(p_service_package_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
  begin

    for c_sp_rec in c_sp loop
      l_service_package_id := c_sp_rec.service_package_id;
    end loop;

  end;
  else
    l_service_package_id := p_service_package_id;
  end if;

  if nvl(p_start_stage_seq, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
    l_start_stage_seq := l_current_stage_seq;
  else
    l_start_stage_seq := p_start_stage_seq;
  end if;

  if ((nvl(p_root_budget_group_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) or
      (nvl(p_business_group_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) or
      (nvl(p_func_currency, FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR) or
      (nvl(p_flex_code, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM)) then
  begin

    for c_BG_Rec in c_BG loop
      l_root_budget_group_id := c_BG_Rec.root_budget_group_id;
      l_business_group_id := c_BG_Rec.business_group_id;
      l_func_currency := c_BG_Rec.currency_code;
      l_flex_code := c_BG_Rec.chart_of_accounts_id;
    end loop;

  end;
  end if;

  if nvl(p_root_budget_group_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
    l_root_budget_group_id := p_root_budget_group_id;
  end if;

  if nvl(p_business_group_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
    l_business_group_id := p_business_group_id;
  end if;

  if nvl(p_func_currency, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
    l_func_currency := p_func_currency;
  end if;

  if nvl(p_flex_code, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
    l_flex_code := p_flex_code;
  end if;

  if ((nvl(p_position_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) or
      (nvl(p_position_name, FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR) or
      (nvl(p_position_start_date, FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE) or
      (nvl(p_position_end_date, FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE)) then
  begin

    for c_Positions_Rec in c_Positions loop
      l_position_id := c_Positions_Rec.position_id;
      l_position_name := c_Positions_Rec.name;
      l_position_start_date := c_Positions_Rec.effective_start_date;
      l_position_end_date := c_Positions_Rec.effective_end_date;
    end loop;

  end;
  end if;

  if nvl(p_position_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
    l_position_id := p_position_id;
  end if;

  if nvl(p_position_name, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR then
    l_position_name := p_position_name;
  end if;

  if nvl(p_position_start_date, FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE then
    l_position_start_date := p_position_start_date;
  end if;

  if nvl(p_position_end_date, FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE then
    l_position_end_date := p_position_end_date;
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

  /*bug:5635570:start*/
  IF FND_API.to_Boolean(p_lparam_flag) THEN
    g_recalc_flag := FALSE;
  ELSE
    g_recalc_flag := TRUE;
  END IF;
  /*bug:5635570:end*/

  l_start_date := greatest(PSB_WS_ACCT1.g_startdate_cy, l_position_start_date);
  l_end_date := least(PSB_WS_ACCT1.g_end_est_date, nvl(l_position_end_date, PSB_WS_ACCT1.g_end_est_date));

  if FND_API.to_Boolean(p_recalculate_flag) then
  begin

    PSB_WS_POS1.g_salary_budget_group_id := null;

    PSB_WS_POS1.Cache_Salary_Dist
       (p_return_status => l_return_status,
	p_worksheet_id => nvl(l_assign_worksheet_id,l_global_worksheet_id), --bug:6133040:used NVL to pass l_assign_worksheet_id.
	p_root_budget_group_id => l_root_budget_group_id,
	p_flex_code => l_flex_code,
	p_data_extract_id => l_data_extract_id,
	p_position_id => l_position_id,
	p_position_name => l_position_name,
	p_start_date => l_start_date,
	p_end_date => l_end_date);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    PSB_WS_POS1.Create_Position_Lines
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_position_line_id => l_position_line_id,
	p_worksheet_id => p_worksheet_id,
	p_position_id => l_position_id,
	p_budget_group_id => PSB_WS_POS1.g_salary_budget_group_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  for l_init_index in 1..g_poselem_assignments.Count loop
    g_poselem_assignments(l_init_index).worksheet_id := null;
    g_poselem_assignments(l_init_index).start_date := null;
    g_poselem_assignments(l_init_index).end_date := null;
    g_poselem_assignments(l_init_index).pay_element_id := null;
    g_poselem_assignments(l_init_index).pay_element_option_id := null;
    g_poselem_assignments(l_init_index).pay_basis := null;
    g_poselem_assignments(l_init_index).element_value_type := null;
    g_poselem_assignments(l_init_index).element_value := null;
    g_poselem_assignments(l_init_index).use_in_calc := null;
  end loop;

  g_num_poselem_assignments := 0;

  for l_init_index in 1..g_poselem_rates.Count loop
    g_poselem_rates(l_init_index).worksheet_id := null;
    g_poselem_rates(l_init_index).start_date := null;
    g_poselem_rates(l_init_index).end_date := null;
    g_poselem_rates(l_init_index).pay_element_id := null;
    g_poselem_rates(l_init_index).pay_element_option_id := null;
    g_poselem_rates(l_init_index).pay_basis := null;
    g_poselem_rates(l_init_index).element_value_type := null;
    g_poselem_rates(l_init_index).element_value := null;
    g_poselem_rates(l_init_index).formula_id := null;
  end loop;

  g_num_poselem_rates := 0;

  for l_init_index in 1..g_posfte_assignments.Count loop
    g_posfte_assignments(l_init_index).worksheet_id := null;
    g_posfte_assignments(l_init_index).start_date := null;
    g_posfte_assignments(l_init_index).end_date := null;
    g_posfte_assignments(l_init_index).fte := null;
  end loop;

  g_num_posfte_assignments := 0;

  for l_init_index in 1..g_poswkh_assignments.Count loop
    g_poswkh_assignments(l_init_index).worksheet_id := null;
    g_poswkh_assignments(l_init_index).start_date := null;
    g_poswkh_assignments(l_init_index).end_date := null;
    g_poswkh_assignments(l_init_index).default_weekly_hours := null;
  end loop;

  g_num_poswkh_assignments := 0;

  if nvl(PSB_WS_POS1.g_attr_busgrp_id, FND_API.G_MISS_NUM) <> l_business_group_id then
  begin

    PSB_WS_POS1.Cache_Named_Attributes
       (p_return_status => l_return_status,
	p_business_group_id => l_business_group_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  PSB_WS_POS1.Cache_Named_Attribute_Values
     (p_return_status => l_return_status,
      p_worksheet_id => l_assign_worksheet_id,
      p_data_extract_id => l_data_extract_id,
      p_position_id => l_position_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  if ((nvl(PSB_WS_POS1.g_data_extract_id, FND_API.G_MISS_NUM) <> l_data_extract_id) or
      (nvl(PSB_WS_POS1.g_business_group_id, FND_API.G_MISS_NUM) <> l_business_group_id)) then
  begin

    PSB_WS_POS1.Cache_Elements
       (p_return_status => l_return_status,
	p_data_extract_id => l_data_extract_id,
	p_business_group_id => l_business_group_id,
	p_worksheet_id => p_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  for c_Element_Assignments_Rec in c_Element_Assignments loop

    g_num_poselem_assignments := g_num_poselem_assignments + 1;

    g_poselem_assignments(g_num_poselem_assignments).worksheet_id := c_Element_Assignments_Rec.worksheet_id;
    g_poselem_assignments(g_num_poselem_assignments).start_date := c_Element_Assignments_Rec.effective_start_date;
    g_poselem_assignments(g_num_poselem_assignments).end_date := c_Element_Assignments_Rec.effective_end_date;
    g_poselem_assignments(g_num_poselem_assignments).pay_element_id := c_Element_Assignments_Rec.pay_element_id;
    g_poselem_assignments(g_num_poselem_assignments).pay_element_option_id := c_Element_Assignments_Rec.pay_element_option_id;
    g_poselem_assignments(g_num_poselem_assignments).pay_basis := c_Element_Assignments_Rec.pay_basis;
    g_poselem_assignments(g_num_poselem_assignments).element_value_type := c_Element_Assignments_Rec.element_value_type;
    g_poselem_assignments(g_num_poselem_assignments).element_value := c_Element_Assignments_Rec.element_value;
    g_poselem_assignments(g_num_poselem_assignments).use_in_calc := FALSE;
    g_poselem_assignments(g_num_poselem_assignments).salary_flag := c_Element_Assignments_Rec.salary_flag; --bug:5880186

    /*start bug:7192891: STATEMENT level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/CALC_POS_COST/PSBVWP2B/Calculate_Position_Cost',
    'Element id:'||c_Element_Assignments_Rec.pay_element_id||' Start Date:'||c_Element_Assignments_Rec.effective_start_date||
    ' End Date:'||c_Element_Assignments_Rec.effective_end_date);

   fnd_file.put_line(fnd_file.LOG,'Element id:'||c_Element_Assignments_Rec.pay_element_id||' Start Date:'||c_Element_Assignments_Rec.effective_start_date||
                                  ' End Date:'||c_Element_Assignments_Rec.effective_end_date);
   end if;
   /*end bug:7192891:end STATEMENT level log*/

  end loop;

  for l_element_index in 1..PSB_WS_POS1.g_num_elements loop

    l_element_found := FALSE;

    for l_elemassign_index in 1..g_num_poselem_assignments loop

      if ((g_poselem_assignments(l_elemassign_index).pay_element_id = PSB_WS_POS1.g_elements(l_element_index).pay_element_id) and
	  (g_poselem_assignments(l_elemassign_index).worksheet_id is not null)) then
      begin
	l_element_found := TRUE;
	g_poselem_assignments(l_elemassign_index).use_in_calc := TRUE;
      end;
      end if;

    end loop;

    if not (l_element_found) then
    begin

      for l_elemassign_index in 1..g_num_poselem_assignments loop

	if ((g_poselem_assignments(l_elemassign_index).pay_element_id = PSB_WS_POS1.g_elements(l_element_index).pay_element_id) and
	    (g_poselem_assignments(l_elemassign_index).worksheet_id is null)) then
	  g_poselem_assignments(l_elemassign_index).use_in_calc := TRUE;
	end if;

      end loop;

    end;
    end if;

  end loop;

  for c_Element_Rates_Rec in c_Element_Rates loop

    g_num_poselem_rates := g_num_poselem_rates + 1;

    g_poselem_rates(g_num_poselem_rates).worksheet_id := c_Element_Rates_Rec.worksheet_id;
    g_poselem_rates(g_num_poselem_rates).start_date := c_Element_Rates_Rec.effective_start_date;
    g_poselem_rates(g_num_poselem_rates).end_date := c_Element_Rates_Rec.effective_end_date;
    g_poselem_rates(g_num_poselem_rates).pay_element_id := c_Element_Rates_Rec.pay_element_id;
    g_poselem_rates(g_num_poselem_rates).pay_element_option_id := c_Element_Rates_Rec.pay_element_option_id;
    g_poselem_rates(g_num_poselem_rates).pay_basis := c_Element_Rates_Rec.pay_basis;
    g_poselem_rates(g_num_poselem_rates).element_value_type := c_Element_Rates_Rec.element_value_type;
    g_poselem_rates(g_num_poselem_rates).element_value := c_Element_Rates_Rec.element_value;
    g_poselem_rates(g_num_poselem_rates).formula_id := c_Element_Rates_Rec.formula_id;

  end loop;

  for c_Attributes_Rec in c_Attribute_Assignments loop

    l_attribute_value := null;

    if ((c_Attributes_Rec.attribute_value is null) and (c_Attributes_Rec.attribute_value_id is not null)) then
      l_attribute_value := Get_Attribute_Value(c_Attributes_Rec.attribute_value_id);
    end if;

    if c_Attributes_Rec.attribute_id = PSB_WS_POS1.g_fte_id then
    begin

      g_num_posfte_assignments := g_num_posfte_assignments + 1;

      g_posfte_assignments(g_num_posfte_assignments).worksheet_id := c_Attributes_Rec.worksheet_id;
      g_posfte_assignments(g_num_posfte_assignments).start_date := c_Attributes_Rec.effective_start_date;
      g_posfte_assignments(g_num_posfte_assignments).end_date := c_Attributes_Rec.effective_end_date;
      g_posfte_assignments(g_num_posfte_assignments).fte := nvl(c_Attributes_Rec.attribute_value, l_attribute_value);

    end;
    elsif c_Attributes_Rec.attribute_id = PSB_WS_POS1.g_default_wklyhrs_id then
    begin

      g_num_poswkh_assignments := g_num_poswkh_assignments + 1;

      g_poswkh_assignments(g_num_poswkh_assignments).worksheet_id := c_Attributes_Rec.worksheet_id;
      g_poswkh_assignments(g_num_poswkh_assignments).start_date := c_Attributes_Rec.effective_start_date;
      g_poswkh_assignments(g_num_poswkh_assignments).end_date := c_Attributes_Rec.effective_end_date;
      g_poswkh_assignments(g_num_poswkh_assignments).default_weekly_hours := nvl(c_Attributes_Rec.attribute_value, l_attribute_value);

    end;
    end if;

  end loop;

  if g_num_poselem_assignments > 0 then
  begin

    PSB_WS_POS1.Initialize_Calc;

    PSB_WS_POS1.Initialize_Dist;

    /*For Bug No : 2811698 Start*/
    --Call the folowing procedure when FTE profile option is set to 'Y'
    if g_fte_profile_option = 'Y' then
      Cache_FTE_Profile
	   (p_return_status => l_return_status,
  	    p_position_id => l_position_id,
	    p_data_extract_id => l_data_extract_id,
 	    p_business_group_id => l_business_group_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
      end if;
    end if;
    /*For Bug No : 2811698 End*/

    -- the following IF clause is added as part of bug fix#4379636
    IF P_BUDGET_YEAR_ID IS NOT NULL THEN

    FOR l_year_index IN 1..PSB_WS_ACCT1.g_num_budget_years LOOP

      if PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP')
      and PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id = p_budget_year_id then
      begin

	Calculate_Position_Cost_Year
		 (p_return_status => l_return_status,
		  p_data_extract_id => l_data_extract_id,
		  p_business_group_id => l_business_group_id,
		  p_position_line_id => p_position_line_id,
		  p_position_id => l_position_id,
		  p_position_name => l_position_name,
		  p_budget_year_id => p_budget_year_id,
		  p_year_start_date => PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
		  p_year_end_date => PSB_WS_ACCT1.g_budget_years(l_year_index).end_date);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

    END LOOP;

    ELSE

    FOR l_year_index IN 1..PSB_WS_ACCT1.g_num_budget_years LOOP

      if PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP') then
      begin

	Calculate_Position_Cost_Year
		 (p_return_status => l_return_status,
		  p_data_extract_id => l_data_extract_id,
		  p_business_group_id => l_business_group_id,
		  p_position_line_id => p_position_line_id,
		  p_position_id => l_position_id,
		  p_position_name => l_position_name,
		  p_budget_year_id => PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id,
		  p_year_start_date => PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
		  p_year_end_date => PSB_WS_ACCT1.g_budget_years(l_year_index).end_date);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

    END LOOP;
    END IF;

    -- the following IF clause is added as part of bug fix#4379636
    IF P_BUDGET_YEAR_ID IS NOT NULL THEN

    FOR l_year_index IN 1..PSB_WS_ACCT1.g_num_budget_years LOOP

      IF PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP') AND
      PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id = p_budget_year_id THEN
      begin

	l_start_date := greatest(PSB_WS_ACCT1.g_budget_years(l_year_index).start_date, l_position_start_date);
	l_end_date := least(PSB_WS_ACCT1.g_budget_years(l_year_index).end_date, nvl(l_position_end_date,
							 PSB_WS_ACCT1.g_budget_years(l_year_index).end_date));

	Distribute_Position_Cost
		 (p_return_status => l_return_status,
		  p_root_budget_group_id => l_root_budget_group_id,
		  p_flex_code => l_flex_code,
		  p_rounding_factor => l_rounding_factor,
		  p_data_extract_id => l_data_extract_id,
		  p_business_group_id => l_business_group_id,
		  p_position_id => l_position_id,
		  p_position_line_id => p_position_line_id,
		  p_budget_year_id => p_budget_year_id,
		  p_start_date => l_start_date,
		  p_end_date => l_end_date);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

    END LOOP;

    ELSE

    FOR l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years LOOP

      if PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP') then
      begin

	l_start_date := greatest(PSB_WS_ACCT1.g_budget_years(l_year_index).start_date, l_position_start_date);
	l_end_date := least(PSB_WS_ACCT1.g_budget_years(l_year_index).end_date, nvl(l_position_end_date,
							 PSB_WS_ACCT1.g_budget_years(l_year_index).end_date));

	Distribute_Position_Cost
		 (p_return_status => l_return_status,
		  p_root_budget_group_id => l_root_budget_group_id,
		  p_flex_code => l_flex_code,
		  p_rounding_factor => l_rounding_factor,
		  p_data_extract_id => l_data_extract_id,
		  p_business_group_id => l_business_group_id,
		  p_position_id => l_position_id,
		  p_position_line_id => p_position_line_id,
		  p_budget_year_id => PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id,
		  p_start_date => l_start_date,
		  p_end_date => l_end_date);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;
    END LOOP;
    END IF;

    /* bug 3446226 Start */
    FOR l_init_index in 1..g_posfte_assignments.Count LOOP

    IF g_posfte_assignments(l_init_index).start_date > l_position_start_date THEN
      l_fte_start_date:= g_posfte_assignments(l_init_index).start_date;
    ELSE
      l_fte_start_date := l_position_start_date;
    END IF;

    IF g_posfte_assignments(l_init_index).end_date < l_position_end_date THEN
      l_fte_end_date := g_posfte_assignments(l_init_index).end_date;
    ELSE
      l_fte_end_date := l_position_end_date;
    END IF;

    END LOOP;
    /* bug 3446226 End */

    -- the following IF clause is added as part of bug fix#4379636
    IF p_budget_year_id IS NOT NULL THEN

    FOR l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years LOOP

      IF PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP') AND
      PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id = p_budget_year_id THEN

      begin

         --bug:7192891:start
	if (PSB_WS_ACCT1.g_budget_years(l_year_index).start_date <= nvl(l_position_end_date, PSB_WS_ACCT1.g_end_est_date) AND
           PSB_WS_ACCT1.g_budget_years(l_year_index).end_date >= nvl(l_position_start_date, PSB_WS_ACCT1.g_startdate_pp)) THEN
        begin
         --bug:7192891:end

          -- bug 3446226 passed l_fte_start_date and l_fte_end_date instead of
          -- l_position_start_date and l_position_end_date

    /*start bug:7192891: STATEMENT level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/CALC_POS_COST/PSBVWP2B/Calculate_Position_Cost',
    'Before Calling Update Position Cost::'||' year start date:'||PSB_WS_ACCT1.g_budget_years(l_year_index).start_date||
    ' pos end date:'||l_position_end_date||' year end date:'||PSB_WS_ACCT1.g_budget_years(l_year_index).end_date||
    ' pos start date:'||l_position_start_date);

   fnd_file.put_line(fnd_file.LOG, 'Before Calling Update Position Cost::'||' year start date:'||PSB_WS_ACCT1.g_budget_years(l_year_index).start_date||
                                   ' pos end date:'||l_position_end_date||' year end date:'||PSB_WS_ACCT1.g_budget_years(l_year_index).end_date||
                                   ' pos start date:'||l_position_start_date);
   end if;
   /*end bug:7192891:end STATEMENT level log*/

	  Update_Position_Cost
		(p_return_status => l_return_status,
		 p_position_line_id => p_position_line_id,
		 p_position_start_date => l_fte_start_date,
		 p_position_end_date => l_fte_end_date,
		 p_worksheet_id => p_worksheet_id,
		 p_flex_mapping_set_id => p_flex_mapping_set_id,
		 p_global_worksheet_id => l_global_worksheet_id,
		 p_func_currency => l_func_currency,
		 p_rounding_factor => l_rounding_factor,
		 p_service_package_id => l_service_package_id,
		 p_stage_set_id => l_stage_set_id,
		 p_start_stage_seq => l_start_stage_seq,
		 p_current_stage_seq => l_current_stage_seq,
		 p_budget_year_id => p_budget_year_id,
		 p_budget_group_id => PSB_WS_POS1.g_salary_budget_group_id);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end;
	end if;

      end;
      end if;

    end loop;

    ELSE

    FOR l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years LOOP

      IF PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP') THEN
      BEGIN

        --bug:7192891:start
	if (PSB_WS_ACCT1.g_budget_years(l_year_index).start_date <= nvl(l_position_end_date, PSB_WS_ACCT1.g_end_est_date) AND
           PSB_WS_ACCT1.g_budget_years(l_year_index).end_date >= nvl(l_position_start_date, PSB_WS_ACCT1.g_startdate_pp)) THEN
        begin
        --bug:7192891:end

    /*start bug:7192891: STATEMENT level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/CALC_POS_COST/PSBVWP2B/Calculate_Position_Cost',
    'Before Calling Update Position Cost-1::'||' year start date:'||PSB_WS_ACCT1.g_budget_years(l_year_index).start_date||
    ' pos end date:'||l_position_end_date||' year end date:'||PSB_WS_ACCT1.g_budget_years(l_year_index).end_date||
    ' pos start date:'||l_position_start_date);

   fnd_file.put_line(fnd_file.LOG, 'Before Calling Update Position Cost::'||' year start date:'||PSB_WS_ACCT1.g_budget_years(l_year_index).start_date||
                                   ' pos end date:'||l_position_end_date||' year end date:'||PSB_WS_ACCT1.g_budget_years(l_year_index).end_date||
                                   ' pos start date:'||l_position_start_date);
   end if;
   /*end bug:7192891:end STATEMENT level log*/

          -- bug 3446226 passed l_fte_start_date and l_fte_end_date instead of
          -- l_position_start_date and l_position_end_date

	  Update_Position_Cost
		(p_return_status => l_return_status,
		 p_position_line_id => p_position_line_id,
		 p_position_start_date => l_fte_start_date,
		 p_position_end_date => l_fte_end_date,
		 p_worksheet_id => p_worksheet_id,
		 p_flex_mapping_set_id => p_flex_mapping_set_id,
		 p_global_worksheet_id => l_global_worksheet_id,
		 p_func_currency => l_func_currency,
		 p_rounding_factor => l_rounding_factor,
		 p_service_package_id => l_service_package_id,
		 p_stage_set_id => l_stage_set_id,
		 p_start_stage_seq => l_start_stage_seq,
		 p_current_stage_seq => l_current_stage_seq,
		 p_budget_year_id => PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id,
		 p_budget_group_id => PSB_WS_POS1.g_salary_budget_group_id);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end;
	end if;

      end;
      end if;

    END LOOP;

    END IF;

  END;
  END IF;


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

END Calculate_Position_Cost;

/* ----------------------------------------------------------------------- */

PROCEDURE Calculate_Position_Cost_Year
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_data_extract_id    IN   NUMBER,
  p_business_group_id  IN   NUMBER,
  p_position_line_id   IN   NUMBER,
  p_position_id        IN   NUMBER,
  p_position_name      IN   VARCHAR2,
  p_budget_year_id     IN   NUMBER,
  p_year_start_date    IN   DATE,
  p_year_end_date      IN   DATE
) IS

  /* Bug#1920021: Start
     Bug#3212814: Modified the first statment and added the second one. We
     need to find attribute values based on value table flag for attribute.
  */
  CURSOR l_default_weekly_hrs_csr IS
         -- Fixed bug # 3683644
  SELECT MAX(FND_NUMBER.canonical_TO_NUMBER(attribute_value)) attribute_value
  FROM   psb_position_assignments
  WHERE  attribute_id    = PSB_WS_POS1.g_default_wklyhrs_id
  AND    (worksheet_id IS NULL OR worksheet_id = g_weekly_hours_worksheet_id)
  AND    assignment_type = 'ATTRIBUTE'
  AND    position_id     = p_position_id ;
  --
  CURSOR l_default_weekly_hrs_vt_csr IS
         -- Fixed bug # 3683644
  SELECT MAX(FND_NUMBER.canonical_TO_NUMBER(vals.attribute_value)) attribute_value
  FROM   psb_position_assignments  asgn ,
         psb_attribute_values      vals
  WHERE  asgn.attribute_id    = PSB_WS_POS1.g_default_wklyhrs_id
  AND    ( asgn.worksheet_id IS NULL
           OR
           asgn.worksheet_id = g_weekly_hours_worksheet_id
         )
  AND    asgn.assignment_type    = 'ATTRIBUTE'
  AND    asgn.position_id        = p_position_id
  and    vals.attribute_value_id = asgn.attribute_value_id ;
  --
  /* Bug No 1920021 End */

  l_fte                    NUMBER;
  l_fte_profile            NUMBER;
  l_default_weekly_hours   NUMBER;
  l_pay_element_id         NUMBER;
  l_pay_element_option_id  NUMBER;
  l_element_name           VARCHAR2(30);
  l_pay_basis              VARCHAR2(10);
  l_element_value_type     VARCHAR2(2);
  l_element_value          NUMBER;
  l_formula_id             NUMBER;

  l_budget_period_id       NUMBER;
  l_budget_period_type     VARCHAR2(1);
  l_calc_period_type       VARCHAR2(1);
  l_calc_start_date        DATE;
  l_calc_end_date          DATE;

  l_long_index             NUMBER;

  l_year_index             BINARY_INTEGER;
  l_period_index           BINARY_INTEGER;
  l_calcperiod_index       BINARY_INTEGER;
  l_element_index          BINARY_INTEGER;
  l_assign_index           BINARY_INTEGER;
  l_rate_index             BINARY_INTEGER;
  l_salary_index           BINARY_INTEGER;

  l_ws_assignment          VARCHAR2(1);
  l_element_assigned       VARCHAR2(1);
  l_calc_element_assigned  VARCHAR2(1);

  l_factor                 NUMBER;
  l_element_cost           NUMBER;
  l_ytd_element_cost       NUMBER;

  l_last_period_index      NUMBER;

  l_salary_defined         VARCHAR2(1) := FND_API.G_FALSE;
  l_salary_element_value   NUMBER;
  l_max_element_value      NUMBER;

  -- Bug#3140849: To stores maximum element value per FTE.
  l_max_elem_value_per_fte NUMBER;

  l_assign_period          VARCHAR2(1);
  l_calculate_from_salary  VARCHAR2(1);
  l_assign_period_index    NUMBER;

  l_processing_type        VARCHAR2(1);
  l_nonrec_calculated      VARCHAR2(1);

  l_salary_indexes         PSB_WS_ACCT1.g_prdamt_tbl_type;
  l_num_salary_indexes     NUMBER;

  l_return_status          VARCHAR2(1);
  l_msg_data               VARCHAR2(2000);
  l_msg_count              NUMBER;
/*bug:5880186:start*/
  l_skip_assign_period_flag   VARCHAR2(1);
  l_processed_ele_sal_flag    VARCHAR2(1);
  l_other_ele_sal_flag        VARCHAR2(1);
/*bug:5880186:end*/

  -- for bug 2622404
  l_nonelm_calc_flag	       VARCHAR2(1) := fnd_api.g_false;

  /* Bug 5065066 Start */
  l_year_start_date             DATE;
  l_period_ctr                  NUMBER;
  /* Bug 5065066 End */

  l_api_name              CONSTANT VARCHAR2(30) := 'Calculate_Position_Cost_Year';

BEGIN

  for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

    if PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id = p_budget_year_id then
      l_last_period_index := PSB_WS_ACCT1.g_budget_years(l_year_index).last_period_index;
      exit;
    end if;

  end loop;

  for l_salary_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
    l_salary_indexes(l_salary_index) := null;
  end loop;

  l_num_salary_indexes := 0;
  l_salary_element_value := 0;

  for l_element_index in 1..PSB_WS_POS1.g_num_elements loop

    l_pay_element_id := PSB_WS_POS1.g_elements(l_element_index).pay_element_id;
    l_element_name := PSB_WS_POS1.g_elements(l_element_index).element_name;
    l_processing_type :=PSB_WS_POS1.g_elements(l_element_index).processing_type;
    l_element_assigned := FND_API.G_FALSE;
    l_nonrec_calculated := FND_API.G_FALSE;

    for l_assign_index in 1..g_num_poselem_assignments loop

      if ((g_poselem_assignments(l_assign_index).pay_element_id = l_pay_element_id) and
	(((g_poselem_assignments(l_assign_index).start_date <= p_year_end_date) and
	  (g_poselem_assignments(l_assign_index).end_date is null)) or
	 ((g_poselem_assignments(l_assign_index).start_date between p_year_start_date and p_year_end_date) or
	  (g_poselem_assignments(l_assign_index).end_date between p_year_start_date and p_year_end_date) or
	 ((g_poselem_assignments(l_assign_index).start_date < p_year_start_date) and
	  (g_poselem_assignments(l_assign_index).end_date > p_year_end_date)))) and
	  (g_poselem_assignments(l_assign_index).use_in_calc)) then
	l_element_assigned := FND_API.G_TRUE;
	exit;
      end if;

    end loop;

    if FND_API.to_Boolean(l_element_assigned) then
    begin

    /* Bug 5065066 Start */
    FOR l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years
    LOOP
      IF PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id
         = p_budget_year_id THEN
        l_year_start_date
          := PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
      END IF;
    END LOOP;
    /* Bug 5065066 End */

      if nvl(PSB_WS_POS1.g_elements(l_element_index).process_period_type, 'FIRST') = 'FIRST' then
      /* Bug 5065066 Start */
      --	l_assign_period_index := 1;
      IF l_year_start_date < g_pos_start_date THEN
        l_period_ctr := 0;
        FOR l_period_index IN 1..PSB_WS_ACCT1.g_num_budget_periods
        LOOP
          IF PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id =
          p_budget_year_id THEN
            l_period_ctr := l_period_ctr +1 ;
          END IF;

          IF PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id =
             p_budget_year_id  AND
             g_pos_start_date BETWEEN
             PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date AND
             PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date THEN

               l_assign_period_index  := l_period_ctr;
          END IF;
        END LOOP;
      ELSE
          l_assign_period_index := 1 ;
      END IF;
      /* Bug 5065066 End */
      else
        l_assign_period_index := l_last_period_index;
      end if;

      PSB_WS_POS1.g_num_pc_costs := PSB_WS_POS1.g_num_pc_costs + 1;

      PSB_WS_POS1.Initialize_Calc
	 (p_init_index => PSB_WS_POS1.g_num_pc_costs);

      PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).pay_element_id := l_pay_element_id;
      PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).budget_year_id := p_budget_year_id;

      l_ytd_element_cost := 0;

      l_calculate_from_salary := FND_API.G_FALSE;
      l_assign_period := FND_API.G_FALSE;

      for l_period_index in 1..PSB_WS_ACCT1.g_num_budget_periods loop

	if PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id = p_budget_year_id then
	begin

	  l_element_cost := 0;
	  l_fte := 0; --bug:7461135

	  l_long_index := PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no;
	  l_budget_period_id := PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_period_id;
	  l_budget_period_type := PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_period_type;

	  for l_calcperiod_index in 1..PSB_WS_ACCT1.g_num_calc_periods loop

	    if ((PSB_WS_ACCT1.g_calculation_periods(l_calcperiod_index).budget_period_id = l_budget_period_id) and
	       ((l_processing_type = 'R') or
	       ((l_processing_type = 'N') and (not FND_API.to_Boolean(l_nonrec_calculated))))) then
	    begin

	      l_ws_assignment := FND_API.G_FALSE;
	      l_calc_element_assigned := FND_API.G_FALSE;

              -- for bug 2622404
              l_nonelm_calc_flag := fnd_api.g_false;

	      l_calc_period_type := PSB_WS_ACCT1.g_calculation_periods(l_calcperiod_index).calc_period_type;
	      l_calc_start_date := PSB_WS_ACCT1.g_calculation_periods(l_calcperiod_index).start_date;
	      l_calc_end_date := PSB_WS_ACCT1.g_calculation_periods(l_calcperiod_index).end_date;

	    /*For Bug No : 2811698 Start*/
            --commented the following code as this is moved to other place
            /*if l_calc_period_type = 'M' and g_num_monthly_profile > 0 then
  	      l_fte_profile := nvl(g_monthly_profile(l_long_index), 0);
	    elsif l_calc_period_type = 'Q' and g_num_quarterly_profile > 0 then
		  l_fte_profile := nvl(g_quarterly_profile(l_long_index), 0);
	    elsif l_calc_period_type = 'S' and g_num_semiannual_profile > 0  then
		  l_fte_profile := nvl(g_semiannual_profile(l_long_index), 0);
	    end if;*/
	    /*For Bug No : 2811698 End*/

	      for l_assign_index in 1..g_num_poselem_assignments loop

		if ((g_poselem_assignments(l_assign_index).pay_element_id = l_pay_element_id) and
		    (g_poselem_assignments(l_assign_index).worksheet_id is not null) and
		  (((g_poselem_assignments(l_assign_index).start_date <= l_calc_end_date) and
		    (g_poselem_assignments(l_assign_index).end_date is null)) or
		   ((g_poselem_assignments(l_assign_index).start_date between l_calc_start_date and l_calc_end_date) or
		    (g_poselem_assignments(l_assign_index).end_date between l_calc_start_date and l_calc_end_date) or
		   ((g_poselem_assignments(l_assign_index).start_date < l_calc_start_date) and
		    (g_poselem_assignments(l_assign_index).end_date > l_calc_end_date))))) then
		begin

        /*Bug:5880186:start*/
        l_processed_ele_sal_flag := g_poselem_assignments(l_assign_index).salary_flag;

        IF l_processed_ele_sal_flag = 'Y' THEN
           l_skip_assign_period_flag := 'N';
   	   l_other_ele_sal_flag := 'N';

           FOR l_assign_rec IN 1..g_num_poselem_assignments LOOP
             IF (g_poselem_assignments(l_assign_rec).pay_element_id <> g_poselem_assignments(l_assign_index).pay_element_id and
                 g_poselem_assignments(l_assign_rec).end_date between l_calc_start_date and l_calc_end_date and
                 g_poselem_assignments(l_assign_index).start_date between l_calc_start_date and l_calc_end_date and
                 g_poselem_assignments(l_assign_rec).end_date < g_poselem_assignments(l_assign_index).start_date)  THEN

  	         l_other_ele_sal_flag := g_poselem_assignments(l_assign_rec).salary_flag;

               IF l_other_ele_sal_flag = l_processed_ele_sal_flag THEN
                 l_skip_assign_period_flag := 'Y';
	       END IF;
             END IF;
           END LOOP;

	   IF l_skip_assign_period_flag = 'Y' THEN
             EXIT;
           END IF;

        END IF;
     /*Bug:5880186:end*/

		  l_ws_assignment := FND_API.G_TRUE;
		  l_calc_element_assigned := FND_API.G_TRUE;

		  l_pay_basis := g_poselem_assignments(l_assign_index).pay_basis;
		  l_pay_element_option_id := g_poselem_assignments(l_assign_index).pay_element_option_id;
		  l_element_value_type := g_poselem_assignments(l_assign_index).element_value_type;
		  l_element_value := g_poselem_assignments(l_assign_index).element_value;

		  if l_processing_type = 'N' then
		    l_nonrec_calculated := FND_API.G_TRUE;
		  end if;

		  exit;

		end;
		end if;

	      end loop;

	      if not FND_API.to_Boolean(l_ws_assignment) then
	      begin

		for l_assign_index in 1..g_num_poselem_assignments loop

		  if ((g_poselem_assignments(l_assign_index).pay_element_id = l_pay_element_id) and
		      (g_poselem_assignments(l_assign_index).worksheet_id is null) and
		    (((g_poselem_assignments(l_assign_index).start_date <= l_calc_end_date) and
		      (g_poselem_assignments(l_assign_index).end_date is null)) or
		     ((g_poselem_assignments(l_assign_index).start_date between l_calc_start_date and l_calc_end_date) or
		      (g_poselem_assignments(l_assign_index).end_date between l_calc_start_date and l_calc_end_date) or
		     ((g_poselem_assignments(l_assign_index).start_date < l_calc_start_date) and
		      (g_poselem_assignments(l_assign_index).end_date > l_calc_end_date)))) and
		      (g_poselem_assignments(l_assign_index).use_in_calc)) then
		  begin
                   /*Bug:5880186:start*/

		       l_processed_ele_sal_flag := g_poselem_assignments(l_assign_index).salary_flag;

		       IF l_processed_ele_sal_flag = 'Y' THEN
			 l_skip_assign_period_flag := 'N';
			 l_other_ele_sal_flag := 'N';

		         FOR l_assign_rec IN 1..g_num_poselem_assignments LOOP
			  IF (g_poselem_assignments(l_assign_rec).pay_element_id <> g_poselem_assignments(l_assign_index).pay_element_id and
			      g_poselem_assignments(l_assign_rec).end_date between l_calc_start_date and l_calc_end_date and
			      g_poselem_assignments(l_assign_index).start_date between l_calc_start_date and l_calc_end_date and
			      g_poselem_assignments(l_assign_rec).end_date < g_poselem_assignments(l_assign_index).start_date)  THEN

			     l_other_ele_sal_flag := g_poselem_assignments(l_assign_rec).salary_flag;

				IF l_other_ele_sal_flag = l_processed_ele_sal_flag THEN
				   l_skip_assign_period_flag := 'Y';
				END IF;
			  END IF;
			 END LOOP;

			    IF l_skip_assign_period_flag = 'Y' THEN
			       EXIT;
			    END IF;

			 END IF;
		       /*Bug:5880186:end*/

		    l_calc_element_assigned := FND_API.G_TRUE;

		    l_pay_basis := g_poselem_assignments(l_assign_index).pay_basis;
		    l_pay_element_option_id := g_poselem_assignments(l_assign_index).pay_element_option_id;
		    l_element_value_type := g_poselem_assignments(l_assign_index).element_value_type;
		    l_element_value := g_poselem_assignments(l_assign_index).element_value;

		    if l_processing_type = 'N' then
		      l_nonrec_calculated := FND_API.G_TRUE;
		    end if;

		    exit;

		  end;
		  end if;

		end loop;

	      end;
	      end if;

	      if FND_API.to_Boolean(l_calc_element_assigned) then
	      begin

		-- for bug 2622404
                l_nonelm_calc_flag := fnd_api.g_true;

		if l_element_value is null then
		begin

		  for l_rate_index in 1..g_num_poselem_rates loop

		    if ((g_poselem_rates(l_rate_index).pay_element_id = l_pay_element_id) and
			(nvl(g_poselem_rates(l_rate_index).pay_element_option_id, FND_API.G_MISS_NUM) =
				    nvl(l_pay_element_option_id, FND_API.G_MISS_NUM)) and
		      (((g_poselem_rates(l_rate_index).start_date <= l_calc_end_date) and
			(g_poselem_rates(l_rate_index).end_date is null)) or
		       ((g_poselem_rates(l_rate_index).start_date between l_calc_start_date and l_calc_end_date) or
			(g_poselem_rates(l_rate_index).end_date between l_calc_start_date and l_calc_end_date) or
		       ((g_poselem_rates(l_rate_index).start_date < l_calc_start_date) and
			(g_poselem_rates(l_rate_index).end_date > l_calc_end_date))))) then
		    begin

		      if l_pay_basis is null then
			l_pay_basis := g_poselem_rates(l_rate_index).pay_basis;
		      end if;

		      l_element_value_type := g_poselem_rates(l_rate_index).element_value_type;
		      l_element_value := g_poselem_rates(l_rate_index).element_value;
		      l_formula_id := g_poselem_rates(l_rate_index).formula_id;
		      exit;

		    end;
		    end if;

		  end loop;

		end;
		end if;

		for l_assign_index in 1..g_num_posfte_assignments loop

		  if (((g_posfte_assignments(l_assign_index).start_date <= l_calc_end_date) and
		      (g_posfte_assignments(l_assign_index).end_date is null)) or
		     ((g_posfte_assignments(l_assign_index).start_date between l_calc_start_date and l_calc_end_date) or
		      (g_posfte_assignments(l_assign_index).end_date between l_calc_start_date and l_calc_end_date) or
		     ((g_posfte_assignments(l_assign_index).start_date < l_calc_start_date) and
		      (g_posfte_assignments(l_assign_index).end_date > l_calc_end_date)))) then
		  begin
            	    /*For Bug No : 2811698 Start*/
		    --l_fte := g_posfte_assignments(l_assign_index).fte;
                   if g_fte_profile_option = 'Y' then
		      l_fte := nvl(g_posfte_assignments(l_assign_index).fte,g_default_fte);
                   else
		      l_fte := g_posfte_assignments(l_assign_index).fte;
                   end if;
                   /*For Bug No : 2811698 End*/
		    exit;

		  end;
		  end if;

		end loop;

		for l_assign_index in 1..g_num_poswkh_assignments loop

/* Bug No 2539186 Start */
		  l_default_weekly_hours := NULL;
/* Bug No 2539186 End */

		  if (((g_poswkh_assignments(l_assign_index).start_date <= l_calc_end_date) and
		      (g_poswkh_assignments(l_assign_index).end_date is null)) or
		     ((g_poswkh_assignments(l_assign_index).start_date between l_calc_start_date and l_calc_end_date) or
		      (g_poswkh_assignments(l_assign_index).end_date between l_calc_start_date and l_calc_end_date) or
		     ((g_poswkh_assignments(l_assign_index).start_date < l_calc_start_date) and
		      (g_poswkh_assignments(l_assign_index).end_date > l_calc_end_date)))) then
		  begin

		    l_default_weekly_hours := g_poswkh_assignments(l_assign_index).default_weekly_hours;
		    exit;

		  end;
		  end if;

		end loop;

                /* Bug No 1920021 Start */
		if l_default_weekly_hours is NULL and l_pay_basis = 'HOURLY'
                then

                  IF PSB_WS_POS1.g_default_wklyhrs_vt_flag = 'N' THEN
                    --
		    for l_default_weekly_hrs_rec in l_default_weekly_hrs_csr
                    loop
		      l_default_weekly_hours :=
                                    l_default_weekly_hrs_rec.attribute_value ;
		    end loop;
                    --
                  ELSIF PSB_WS_POS1.g_default_wklyhrs_vt_flag = 'Y' THEN
                    --
		    for l_default_weekly_hrs_rec in l_default_weekly_hrs_vt_csr
                    loop
		      l_default_weekly_hours :=
                                    l_default_weekly_hrs_rec.attribute_value ;
		    end loop;
                    --
                  END IF ;

		end if;
                /* Bug No 1920021 End */

		if l_element_value_type = 'PI' then
		  message_token('ELEMENT_VALUE_TYPE', l_element_value_type);
		  message_token('ELEMENT', PSB_WS_POS1.g_elements(l_element_index).element_name);
		  message_token('POSITION', p_position_name);
		  add_message('PSB', 'PSB_INVALID_ASSIGNMENT_TYPE');
		  raise FND_API.G_EXC_ERROR;
		end if;

                /*For Bug No : 2811698 Start*/
                --changed the l_fte_profile values when null from g_default_fte to 0
                --added the following IF condition to make sure that this
                --will be done when FTE profile option is set to 'Y'
                --l_fte_profile will hold the fte attribute value, if no FTE profile is
                --available in the allocation rule
                l_fte_profile := l_fte;
    	        if  g_fte_profile_option = 'Y' then
	          if l_calc_period_type = 'M' and g_num_monthly_profile > 0 then
  		    l_fte_profile := nvl(g_monthly_profile(l_long_index), 0);
	          elsif l_calc_period_type = 'Q' and g_num_quarterly_profile > 0 then
		    l_fte_profile := nvl(g_quarterly_profile(l_long_index), 0);
	          elsif l_calc_period_type = 'S' and g_num_semiannual_profile > 0  then
		    l_fte_profile := nvl(g_semiannual_profile(l_long_index), 0);
	          end if;
	        end if;
	        /*For Bug No : 2811698 End*/

		if PSB_WS_POS1.g_elements(l_element_index).salary_flag = 'Y' then
		begin

		  /* start bug 2622404 */
		  IF l_element_value IS NULL THEN
		    l_element_value := 0;
		  END IF;
		  /* end bug 2622404 */


		  if l_processing_type = 'N' then
		    l_element_cost := l_element_value;
		  else
		  begin

		    if l_pay_basis = 'ANNUAL' then
		    begin

		      PSB_WS_POS1.HRMS_Factor
			 (p_return_status => l_return_status,
			  p_hrms_period_type => 'Y',
			  p_budget_period_type => l_calc_period_type,
			  p_position_name => p_position_name,
			  p_element_name => l_element_name,
			  p_start_date => l_calc_start_date,
			  p_end_date => l_calc_end_date,
			  p_factor => l_factor);

		      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
			raise FND_API.G_EXC_ERROR;
		      end if;

                     /*For Bug No : 2811698 Start*/
		     if g_fte_profile_option = 'Y' then
		      l_element_cost := l_element_cost +
					l_element_value * l_fte_profile * l_factor;
                     else
		      l_element_cost := l_element_cost +
					l_element_value * nvl(l_fte, g_default_fte) * l_factor;
                     end if;
                     /*For Bug No : 2811698 End*/

		    end;
		    elsif l_pay_basis = 'HOURLY' then
		    begin

		      PSB_WS_POS1.HRMS_Factor
			 (p_return_status => l_return_status,
			  p_hrms_period_type => 'W',
			  p_budget_period_type => l_calc_period_type,
			  p_position_name => p_position_name,
			  p_element_name => l_element_name,
			  p_start_date => l_calc_start_date,
			  p_end_date => l_calc_end_date,
			  p_factor => l_factor);

		      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
			raise FND_API.G_EXC_ERROR;
		      end if;

		      if l_default_weekly_hours is null then
			message_token('ATTRIBUTE', 'DEFAULT_WEEKLY_HOURS');
			message_token('POSITION', p_position_name);
			message_token('START_DATE', l_calc_start_date);
			message_token('END_DATE', l_calc_end_date);
			add_message('PSB', 'PSB_INVALID_NAMED_ATTRIBUTE');
			raise FND_API.G_EXC_ERROR;
		      end if;

                     /*For Bug No : 2811698 Start*/
		     if g_fte_profile_option = 'Y' then
		      l_element_cost := l_element_cost +
					l_element_value * l_fte_profile * l_default_weekly_hours * l_factor;
                     else
		      l_element_cost := l_element_cost +
					l_element_value * nvl(l_fte, g_default_fte) * l_default_weekly_hours * l_factor;
                     end if;
                     /*For Bug No : 2811698 End*/

		    end;
		    elsif l_pay_basis = 'MONTHLY' then
		    begin

		      PSB_WS_POS1.HRMS_Factor
			 (p_return_status => l_return_status,
			  p_hrms_period_type => 'CM',
			  p_budget_period_type => l_calc_period_type,
			  p_position_name => p_position_name,
			  p_element_name => l_element_name,
			  p_start_date => l_calc_start_date,
			  p_end_date => l_calc_end_date,
			  p_factor => l_factor);

		      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
			raise FND_API.G_EXC_ERROR;
		      end if;

                     /*For Bug No : 2811698 Start*/
		     if g_fte_profile_option = 'Y' then
		      l_element_cost := l_element_cost +
					l_element_value * l_fte_profile * l_factor;
                     else
		      l_element_cost := l_element_cost +
					l_element_value * nvl(l_fte, g_default_fte) * l_factor;
                     end if;
                     /*For Bug No : 2811698 End*/

		    end;
		    elsif l_pay_basis = 'PERIOD' then
		    begin

		      PSB_WS_POS1.HRMS_Factor
			 (p_return_status => l_return_status,
			  p_hrms_period_type => PSB_WS_POS1.g_elements(l_element_index).period_type,
			  p_budget_period_type => l_calc_period_type,
			  p_position_name => p_position_name,
			  p_element_name => l_element_name,
			  p_start_date => l_calc_start_date,
			  p_end_date => l_calc_end_date,
			  p_factor => l_factor);

		      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
			raise FND_API.G_EXC_ERROR;
		      end if;

                     /*For Bug No : 2811698 Start*/
		     if g_fte_profile_option = 'Y' then
		      l_element_cost := l_element_cost +
					l_element_value * l_fte_profile * l_factor;
                     else
		      l_element_cost := l_element_cost +
					l_element_value * nvl(l_fte, g_default_fte) * l_factor;
                     end if;
                    /*For Bug No : 2811698 End*/

		    end;
		    else
		      message_token('POSITION', p_position_name);
		      message_token('START_DATE', l_calc_start_date);
		      message_token('END_DATE', l_calc_end_date);
		      add_message('PSB', 'PSB_INVALID_SALARY_BASIS');
		      raise FND_API.G_EXC_ERROR;
		    end if;

		  end;
		  end if;

		end;
		else
		begin

		  /* start bug 2622404 */
		  IF l_element_value IS NULL THEN
		    l_element_value := 0;
		  END IF;
		  /* end bug 2622404 */

		  if l_element_value_type = 'PS' then
		  begin

                    -- bug 3786457.commented out the following IF
		    -- if l_element_value >= 1 then
		      l_element_value := l_element_value / 100;
		    -- end if;

		    l_calculate_from_salary := FND_API.G_TRUE;
		    exit;

		  end;
		  elsif l_element_value_type = 'A' then
		  begin

		    if l_processing_type = 'N' then
		      l_element_cost := l_element_value;
		    else
		    begin

		      PSB_WS_POS1.HRMS_Factor
			 (p_return_status => l_return_status,
			  p_hrms_period_type => PSB_WS_POS1.g_elements(l_element_index).period_type,
			  p_budget_period_type => l_calc_period_type,
			  p_position_name => p_position_name,
			  p_element_name => l_element_name,
			  p_start_date => l_calc_start_date,
			  p_end_date => l_calc_end_date,
			  p_factor => l_factor);

		      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
			raise FND_API.G_EXC_ERROR;
		      end if;

                     /*For Bug No : 2811698 Start*/
		     if g_fte_profile_option = 'Y' then
 		       if l_factor < 1 then
			    l_ytd_element_cost := l_ytd_element_cost +
					      l_element_value * l_fte_profile * l_factor;
			    l_assign_period := FND_API.G_TRUE;
		       else
			    l_element_cost := l_element_cost +
					  l_element_value * l_fte_profile * l_factor;
		       end if;
                     else
		       if l_factor < 1 then
			    l_ytd_element_cost := l_ytd_element_cost +
					      l_element_value * nvl(l_fte, g_default_fte) * l_factor;
			    l_assign_period := FND_API.G_TRUE;
		       else
			    l_element_cost := l_element_cost +
					  l_element_value * nvl(l_fte, g_default_fte) * l_factor;
		       end if;
                     end if;
                    /*For Bug No : 2811698 End*/

		    end;
		    end if;

		  end;
		  end if;

		end;
		end if;

	      end;
	      end if;

	    end;
	    end if;

	  end loop; /* Calculation Periods */

          --
          -- Bug#3140849: Enforce maximum element value by FTE.
          --
          --pd('l_element_name:' || l_element_name);
          IF PSB_WS_POS1.g_elements(l_element_index).max_element_value_type
             = 'A'
          THEN
            l_max_elem_value_per_fte :=
                    PSB_WS_POS1.g_elements(l_element_index).max_element_value;
          ELSE

            -- bug 3786457. commented out the following IF
            /* IF PSB_WS_POS1.g_elements(l_element_index).max_element_value < 1
            THEN
              l_max_elem_value_per_fte := PSB_WS_POS1.g_elements(l_element_index).max_element_value * l_salary_element_value;
            ELSE
              l_max_elem_value_per_fte := PSB_WS_POS1.g_elements(l_element_index).max_element_value * l_salary_element_value / 100;
            END IF ; */

            l_max_elem_value_per_fte := PSB_WS_POS1.g_elements(l_element_index).max_element_value * l_salary_element_value / 100;

            --
          END IF ;

          -- Set variable as it is used in all subsequence processing.
          l_max_element_value := l_max_elem_value_per_fte ;

          IF PSB_WS_POS1.g_elements(l_element_index).max_element_value_type
             = 'A'
          THEN
            l_max_element_value := l_max_elem_value_per_fte * l_fte_profile ;
          END IF ;
          --pd('l_max_element_value:' || l_max_element_value);
          --
          -- Bug#3140849: End
          --

	  if ((FND_API.to_Boolean(l_calculate_from_salary)) and
	      (FND_API.to_Boolean(l_salary_defined)) and
	      (l_ytd_element_cost <= nvl(l_max_element_value, l_ytd_element_cost))) then
	  begin

	    for l_salary_index in 1..l_num_salary_indexes loop

	      -- for bug 2622404
              -- added additional check of calculation flag. Repeated the same
	      -- check for all the 60 periods defined.

	      if l_long_index = 1 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period1_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period1_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 2 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period2_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period2_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 3 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period3_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period3_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 4 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period4_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period4_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 5 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period5_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period5_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 6 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period6_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period6_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 7 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period7_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period7_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 8 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period8_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period8_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 9 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period9_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period9_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 10 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period10_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period10_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 11 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period11_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period11_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 12 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period12_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period12_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 13 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period13_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period13_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 14 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period14_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period14_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 15 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period15_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period15_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 16 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period16_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period16_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 17 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period17_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period17_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 18 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period18_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period18_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 19 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period19_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period19_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 20 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period20_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period20_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 21 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period21_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period21_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 22 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period22_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period22_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 23 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period23_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period23_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 24 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period24_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period24_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 25 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period25_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period25_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 26 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period26_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period26_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 27 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period27_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period27_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 28 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period28_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period28_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 29 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period29_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period29_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 30 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period30_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period30_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 31 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period31_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period31_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 32 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period32_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period32_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 33 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period33_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period33_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 34 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period34_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period34_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 35 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period35_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period35_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 36 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period36_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period36_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 37 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period37_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period37_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 38 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period38_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period38_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 39 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period39_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period39_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 40 and (fnd_api.to_boolean(l_nonelm_calc_flag)) and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period40_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period40_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 41 then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period41_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period41_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 42 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period42_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period42_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 43 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period43_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period43_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 44 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period44_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period44_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 45 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period45_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period45_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 46 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period46_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period46_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 47 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period47_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period47_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 48 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period48_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period48_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 49 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period49_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period49_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 50 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period50_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period50_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 51 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period51_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period51_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 52 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period52_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period52_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 53 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period53_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period53_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 54 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period54_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period54_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 55 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period55_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period55_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 56 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period56_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period56_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 57 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period57_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period57_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 58 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period58_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period58_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 59 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period59_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period59_amount := l_element_cost;

		end;
		end if;

	      end;
	      elsif l_long_index = 60 and (fnd_api.to_boolean(l_nonelm_calc_flag)) then
	      begin

		l_element_cost := PSB_WS_POS1.g_pc_costs(l_salary_indexes(l_salary_index)).period60_amount * l_element_value;

		if l_element_cost <> 0 then
		begin

		  l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

		  if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		    l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
		  end if;

		  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period60_amount := l_element_cost;

		end;
		end if;

	      end;
	      end if;

	    end loop;

	  end;
	  else
	  begin

	    if not FND_API.to_Boolean(l_assign_period) then
	    begin

	      l_ytd_element_cost := l_ytd_element_cost + l_element_cost;

	      if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
		l_element_cost := greatest((l_max_element_value - (l_ytd_element_cost - l_element_cost)), 0);
	      end if;

	      if l_long_index = 1 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period1_amount := l_element_cost;
	      elsif l_long_index = 2 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period2_amount := l_element_cost;
	      elsif l_long_index = 3 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period3_amount := l_element_cost;
	      elsif l_long_index = 4 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period4_amount := l_element_cost;
	      elsif l_long_index = 5 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period5_amount := l_element_cost;
	      elsif l_long_index = 6 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period6_amount := l_element_cost;
	      elsif l_long_index = 7 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period7_amount := l_element_cost;
	      elsif l_long_index = 8 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period8_amount := l_element_cost;
	      elsif l_long_index = 9 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period9_amount := l_element_cost;
	      elsif l_long_index = 10 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period10_amount := l_element_cost;
	      elsif l_long_index = 11 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period11_amount := l_element_cost;
	      elsif l_long_index = 12 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period12_amount := l_element_cost;
	      elsif l_long_index = 13 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period13_amount := l_element_cost;
	      elsif l_long_index = 14 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period14_amount := l_element_cost;
	      elsif l_long_index = 15 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period15_amount := l_element_cost;
	      elsif l_long_index = 16 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period16_amount := l_element_cost;
	      elsif l_long_index = 17 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period17_amount := l_element_cost;
	      elsif l_long_index = 18 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period18_amount := l_element_cost;
	      elsif l_long_index = 19 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period19_amount := l_element_cost;
	      elsif l_long_index = 20 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period20_amount := l_element_cost;
	      elsif l_long_index = 21 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period21_amount := l_element_cost;
	      elsif l_long_index = 22 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period22_amount := l_element_cost;
	      elsif l_long_index = 23 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period23_amount := l_element_cost;
	      elsif l_long_index = 24 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period24_amount := l_element_cost;
	      elsif l_long_index = 25 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period25_amount := l_element_cost;
	      elsif l_long_index = 26 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period26_amount := l_element_cost;
	      elsif l_long_index = 27 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period27_amount := l_element_cost;
	      elsif l_long_index = 28 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period28_amount := l_element_cost;
	      elsif l_long_index = 29 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period29_amount := l_element_cost;
	      elsif l_long_index = 30 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period30_amount := l_element_cost;
	      elsif l_long_index = 31 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period31_amount := l_element_cost;
	      elsif l_long_index = 32 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period32_amount := l_element_cost;
	      elsif l_long_index = 33 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period33_amount := l_element_cost;
	      elsif l_long_index = 34 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period34_amount := l_element_cost;
	      elsif l_long_index = 35 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period35_amount := l_element_cost;
	      elsif l_long_index = 36 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period36_amount := l_element_cost;
	      elsif l_long_index = 37 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period37_amount := l_element_cost;
	      elsif l_long_index = 38 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period38_amount := l_element_cost;
	      elsif l_long_index = 39 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period39_amount := l_element_cost;
	      elsif l_long_index = 40 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period40_amount := l_element_cost;
	      elsif l_long_index = 41 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period41_amount := l_element_cost;
	      elsif l_long_index = 42 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period42_amount := l_element_cost;
	      elsif l_long_index = 43 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period43_amount := l_element_cost;
	      elsif l_long_index = 44 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period44_amount := l_element_cost;
	      elsif l_long_index = 45 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period45_amount := l_element_cost;
	      elsif l_long_index = 46 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period46_amount := l_element_cost;
	      elsif l_long_index = 47 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period47_amount := l_element_cost;
	      elsif l_long_index = 48 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period48_amount := l_element_cost;
	      elsif l_long_index = 49 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period49_amount := l_element_cost;
	      elsif l_long_index = 50 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period50_amount := l_element_cost;
	      elsif l_long_index = 51 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period51_amount := l_element_cost;
	      elsif l_long_index = 52 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period52_amount := l_element_cost;
	      elsif l_long_index = 53 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period53_amount := l_element_cost;
	      elsif l_long_index = 54 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period54_amount := l_element_cost;
	      elsif l_long_index = 55 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period55_amount := l_element_cost;
	      elsif l_long_index = 56 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period56_amount := l_element_cost;
	      elsif l_long_index = 57 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period57_amount := l_element_cost;
	      elsif l_long_index = 58 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period58_amount := l_element_cost;
	      elsif l_long_index = 59 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period59_amount := l_element_cost;
	      elsif l_long_index = 60 then
		PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period60_amount := l_element_cost;
	      end if;

	    end;
	    end if;

	  end;
	  end if;

	end;
	end if;

      end loop; /* Budget Periods */

      if FND_API.to_Boolean(l_assign_period) then
      begin

	if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
	  l_ytd_element_cost := l_max_element_value;
	end if;

	if l_assign_period_index = 1 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period1_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 2 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period2_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 3 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period3_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 4 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period4_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 5 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period5_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 6 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period6_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 7 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period7_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 8 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period8_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 9 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period9_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 10 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period10_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 11 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period11_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 12 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period12_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 13 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period13_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 14 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period14_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 15 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period15_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 16 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period16_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 17 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period17_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 18 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period18_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 19 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period19_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 20 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period20_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 21 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period21_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 22 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period22_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 23 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period23_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 24 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period24_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 25 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period25_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 26 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period26_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 27 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period27_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 28 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period28_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 29 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period29_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 30 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period30_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 31 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period31_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 32 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period32_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 33 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period33_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 34 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period34_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 35 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period35_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 36 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period36_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 37 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period37_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 38 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period38_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 39 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period39_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 40 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period40_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 41 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period41_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 42 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period42_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 43 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period43_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 44 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period44_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 45 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period45_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 46 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period46_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 47 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period47_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 48 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period48_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 49 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period49_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 50 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period50_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 51 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period51_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 52 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period52_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 53 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period53_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 54 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period54_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 55 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period55_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 56 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period56_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 57 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period57_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 58 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period58_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 59 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period59_amount := l_ytd_element_cost;
	elsif l_assign_period_index = 60 then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).period60_amount := l_ytd_element_cost;
	end if;

      end;
      end if;

      /* For Bug No : 2115867 Start */
      --The following one line has been commented because of the maximum value
      -- has to be taken when YTD_Amount is more than it
      -- PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).element_cost := l_ytd_element_cost;

      if l_ytd_element_cost > nvl(l_max_element_value, l_ytd_element_cost) then
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).element_cost := l_max_element_value;
	else
	  PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).element_cost := l_ytd_element_cost;
      end if;
      /* For Bug No : 2115867 End */

      if PSB_WS_POS1.g_elements(l_element_index).salary_flag = 'Y' then
	l_salary_defined := FND_API.G_TRUE;
	l_num_salary_indexes := l_num_salary_indexes + 1;

        -- Bug#3140849: Enforce maximum element value by FTE.
        -- Fixing the following statement. We need to use value computed in
        -- the immediate prior IF statement.
	/*l_salary_element_value:=l_salary_element_value+l_ytd_element_cost;*/
	l_salary_element_value := l_salary_element_value +
              PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).element_cost;
        --
	l_salary_indexes(l_num_salary_indexes) := PSB_WS_POS1.g_num_pc_costs;
	PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).element_type := 'S';
      end if;

      if PSB_WS_POS1.g_elements(l_element_index).follow_salary = 'Y' then
	PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).element_type := 'F';
      end if;

    end;
    end if;


  end loop; /* Elements */


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

END Calculate_Position_Cost_Year;

/* ----------------------------------------------------------------------- */

PROCEDURE Cache_FTE_Profile
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_position_id        IN   NUMBER,
  p_data_extract_id    IN   NUMBER,
  p_business_group_id  IN   NUMBER
) IS

  l_entity_id          NUMBER;

  l_init_index         BINARY_INTEGER;

  /*For Bug No : 2811698 Start*/
  --added the entity_id in order by clause of all the following
  --select statements to make sure that we get right values when
  --there are more than one profiles with same priority
  cursor c_Monthly_Profile is
    select b.entity_id,
	   a.percent
      from PSB_ALLOCRULE_PERCENTS a,
	   PSB_DEFAULTS b
     where a.number_of_periods = 12
       and a.allocation_rule_id = b.entity_id
       and ((nvl(b.global_default_flag, 'N') = 'N'
       and exists
	  (select 1
	     from PSB_BUDGET_POSITIONS c,
		  PSB_SET_RELATIONS d
	    where c.position_id = p_position_id
	      and c.account_position_set_id = d.account_position_set_id
	      and d.default_rule_id = b.default_rule_id))
	or b.global_default_flag = 'Y')
       and b.business_group_id = p_business_group_id
       and b.data_extract_id = p_data_extract_id
     order by b.priority,b.entity_id,
	      a.period_num;

  cursor c_Quarterly_Profile is
    select b.entity_id,
	   a.percent
      from PSB_ALLOCRULE_PERCENTS a,
	   PSB_DEFAULTS b
     where a.number_of_periods = 4
       and a.allocation_rule_id = b.entity_id
       and ((nvl(b.global_default_flag, 'N') = 'N'
       and exists
	  (select 1
	     from PSB_BUDGET_POSITIONS c,
		  PSB_SET_RELATIONS d
	    where c.position_id = p_position_id
	      and c.account_position_set_id = d.account_position_set_id
	      and d.default_rule_id = b.default_rule_id))
	or b.global_default_flag = 'Y')
       and b.business_group_id = p_business_group_id
       and b.data_extract_id = p_data_extract_id
     order by b.priority,b.entity_id,
	      a.period_num;

  cursor c_Semiannual_Profile is
    select b.entity_id,
	   a.percent
      from PSB_ALLOCRULE_PERCENTS a,
	   PSB_DEFAULTS b
     where a.number_of_periods = 2
       and a.allocation_rule_id = b.entity_id
       and ((nvl(b.global_default_flag, 'N') = 'N'
       and exists
	  (select 1
	     from PSB_BUDGET_POSITIONS c,
		  PSB_SET_RELATIONS d
	    where c.position_id = p_position_id
	      and c.account_position_set_id = d.account_position_set_id
	      and d.default_rule_id = b.default_rule_id))
	or b.global_default_flag = 'Y')
       and b.business_group_id = p_business_group_id
       and b.data_extract_id = p_data_extract_id
     order by b.priority,b.entity_id,
	      a.period_num;

BEGIN

  for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
    g_monthly_profile(l_init_index) := null;
    g_quarterly_profile(l_init_index) := null;
    g_semiannual_profile(l_init_index) := null;
  end loop;

  g_num_monthly_profile := 0;
  g_num_quarterly_profile := 0;
  g_num_semiannual_profile := 0;

  for c_Monthly_Profile_Rec in c_Monthly_Profile loop

    if c_Monthly_Profile_Rec.entity_id <> nvl(l_entity_id, FND_API.G_MISS_NUM) then
    begin

      for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
	g_monthly_profile(l_init_index) := null;
      end loop;

      g_num_monthly_profile := 0;

      l_entity_id := c_Monthly_Profile_Rec.entity_id;

    end;
    end if;

    g_num_monthly_profile := g_num_monthly_profile + 1;
    g_monthly_profile(g_num_monthly_profile) := c_Monthly_Profile_Rec.percent;

  end loop;

  l_entity_id := null;

  for c_Quarterly_Profile_Rec in c_Quarterly_Profile loop

    if c_Quarterly_Profile_Rec.entity_id <> nvl(l_entity_id, FND_API.G_MISS_NUM) then
    begin

      for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
	g_quarterly_profile(l_init_index) := null;
      end loop;

      g_num_quarterly_profile := 0;

      l_entity_id := c_Quarterly_Profile_Rec.entity_id;

    end;
    end if;

    g_num_quarterly_profile := g_num_quarterly_profile + 1;
    g_quarterly_profile(g_num_quarterly_profile) := c_Quarterly_Profile_Rec.percent;

  end loop;

  l_entity_id := null;

  for c_Semiannual_Profile_Rec in c_Semiannual_Profile loop

    if c_Semiannual_Profile_Rec.entity_id <> nvl(l_entity_id, FND_API.G_MISS_NUM) then
    begin

      for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
	g_semiannual_profile(l_init_index) := null;
      end loop;

      g_num_semiannual_profile := 0;

      l_entity_id := c_Semiannual_Profile_Rec.entity_id;

    end;
    end if;

    g_num_semiannual_profile := g_num_semiannual_profile + 1;
    g_semiannual_profile(g_num_semiannual_profile) := c_Semiannual_Profile_Rec.percent;

  end loop;


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
	   p_procedure_name => 'Cache_FTE_Profile');
     end if;

END Cache_FTE_Profile;

/* ----------------------------------------------------------------------- */

PROCEDURE Distribute_Position_Cost
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_root_budget_group_id  IN   NUMBER,
  p_flex_code             IN   NUMBER,
  p_rounding_factor       IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_business_group_id     IN   NUMBER,
  p_position_id           IN   NUMBER,
  p_position_line_id      IN   NUMBER,
  p_budget_year_id        IN   NUMBER,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE
) IS

  l_element_index         BINARY_INTEGER;

  l_return_status         VARCHAR2(1);
  l_msg_data              VARCHAR2(2000);
  l_msg_count             NUMBER;

  l_api_name             CONSTANT VARCHAR2(30) := 'Distribute_Position_Cost';

BEGIN

  for l_element_index in 1..PSB_WS_POS1.g_num_elements loop

    if PSB_WS_POS1.g_elements(l_element_index).salary_flag = 'Y' then
    begin

      Distribute_Salary
		(p_return_status => l_return_status,
		 p_pay_element_id => PSB_WS_POS1.g_elements(l_element_index).pay_element_id,
		 p_root_budget_group_id => p_root_budget_group_id,
		 p_data_extract_id => p_data_extract_id,
		 p_flex_code => p_flex_code,
		 p_rounding_factor => p_rounding_factor,
		 p_position_line_id => p_position_line_id,
		 p_position_id => p_position_id,
		 p_budget_year_id => p_budget_year_id,
		 p_start_date => p_start_date,
		 p_end_date => p_end_date);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    else
    begin

      if PSB_WS_POS1.g_elements(l_element_index).follow_salary = 'Y' then
      begin

	PSB_WS_POS1.Distribute_Following_Elements
	   (p_return_status => l_return_status,
	    p_pay_element_id => PSB_WS_POS1.g_elements(l_element_index).pay_element_id,
	    p_data_extract_id => p_data_extract_id,
	    p_flex_code => p_flex_code,
	    p_business_group_id => p_business_group_id,
	    p_rounding_factor => p_rounding_factor,
	    p_position_line_id => p_position_line_id,
	    p_position_id => p_position_id,
	    p_budget_year_id => p_budget_year_id,
	    p_start_date => p_start_date,
	    p_end_date => p_end_date);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      else
      begin

	Distribute_Other_Elements
		  (p_return_status => l_return_status,
		   p_pay_element_id => PSB_WS_POS1.g_elements(l_element_index).pay_element_id,
		   p_data_extract_id => p_data_extract_id,
		   p_flex_code => p_flex_code,
		   p_rounding_factor => p_rounding_factor,
		   p_position_line_id => p_position_line_id,
		   p_position_id => p_position_id,
		   p_budget_year_id => p_budget_year_id,
		   p_start_date => p_start_date,
		   p_end_date => p_end_date);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

    end;
    end if;

  end loop;


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

PROCEDURE Distribute_Salary
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_pay_element_id        IN   NUMBER,
  p_root_budget_group_id  IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_flex_code             IN   NUMBER,
  p_rounding_factor       IN   NUMBER,
  p_position_line_id      IN   NUMBER,
  p_position_id           IN   NUMBER,
  p_budget_year_id        IN   NUMBER,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE
) IS

  l_salary_index         BINARY_INTEGER;
  l_calc_index           BINARY_INTEGER;
  l_saldist_index        BINARY_INTEGER;

  l_percent              NUMBER;

  l_elem_found           VARCHAR2(1) := FND_API.G_FALSE;

  l_new_start_date       DATE;
  l_new_end_date         DATE;
  l_update_dist          BOOLEAN;

/* Bug No 2278216 Start */
  l_return_status        VARCHAR2(1);
  l_rounding_difference  NUMBER;
/* Bug No 2278216 End */
  l_msg_data             VARCHAR2(2000);
  l_msg_count            NUMBER;

  l_api_name             CONSTANT VARCHAR2(30) := 'Distribute_Salary';

BEGIN

  for l_calc_index in 1..PSB_WS_POS1.g_num_pc_costs loop

    if ((PSB_WS_POS1.g_pc_costs(l_calc_index).budget_year_id = p_budget_year_id) and
	(PSB_WS_POS1.g_pc_costs(l_calc_index).pay_element_id = p_pay_element_id)) then
      l_salary_index := l_calc_index;
      l_elem_found := FND_API.G_TRUE;
      exit;
    end if;

  end loop;

  if FND_API.to_Boolean(l_elem_found) then
  begin

/* Bug No 2278216 Start */
    PSB_WS_POS1.Initialize_Period_Dist;
/* Bug No 2278216 End */

    PSB_WS_POS1.g_pc_costs(l_salary_index).element_set_id := p_pay_element_id;

    l_rounding_difference := 0;

    for l_saldist_index in 1..PSB_WS_POS1.g_num_salary_dist loop

      l_update_dist := FALSE;

      if (((PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date <= p_end_date) and
	   (PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date is null)) or
	  ((PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date between p_start_date and p_end_date) or
	   (PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date between p_start_date and p_end_date) or
	  ((PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date < p_start_date) and
	   (PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date > p_end_date)))) then
      begin

	l_new_start_date := greatest(p_start_date, PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date);
	l_new_end_date := least(p_end_date, nvl(PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date, p_end_date));

        -- commented for bug # 4502946
	/*if PSB_WS_POS1.g_salary_dist(l_saldist_index).percent < 1 then
	  l_percent := PSB_WS_POS1.g_salary_dist(l_saldist_index).percent;
	else
	  l_percent := PSB_WS_POS1.g_salary_dist(l_saldist_index).percent / 100;
	end if;*/

        -- added for bug # 4502946
        l_percent := PSB_WS_POS1.g_salary_dist(l_saldist_index).percent / 100;

      for j in 1..PSB_WS_POS1.g_num_pd_costs loop

	if ((PSB_WS_POS1.g_pd_costs(j).ccid = PSB_WS_POS1.g_salary_dist(l_saldist_index).ccid) and
	    (PSB_WS_POS1.g_pd_costs(j).element_set_id = p_pay_element_id) and
	    (PSB_WS_POS1.g_pd_costs(j).budget_year_id = p_budget_year_id)) then
	       /*For Bug No : 2782604 Start*/
	       --PSB_WS_POS1.g_num_pd_costs := j;
	       /*For Bug No : 2782604 End*/
	       l_update_dist := TRUE;
	       exit;
	end if;

      end loop;

/* Bug No 2278216 Start */
-- Created a separate procedure for calculating period amounts

	if not (l_update_dist) then
	begin

	  PSB_WS_POS1.g_num_pd_costs := PSB_WS_POS1.g_num_pd_costs + 1;

	  PSB_WS_POS1.g_pd_costs(PSB_WS_POS1.g_num_pd_costs).ccid := PSB_WS_POS1.g_salary_dist(l_saldist_index).ccid;
	  PSB_WS_POS1.g_pd_costs(PSB_WS_POS1.g_num_pd_costs).budget_year_id := p_budget_year_id;
	  PSB_WS_POS1.g_pd_costs(PSB_WS_POS1.g_num_pd_costs).element_type := 'S';
	  PSB_WS_POS1.g_pd_costs(PSB_WS_POS1.g_num_pd_costs).element_set_id := p_pay_element_id;

	end;
	end if;

	PSB_WS_POS1.g_num_periods := PSB_WS_POS1.g_num_periods + 1;

	PSB_WS_POS1.g_periods(PSB_WS_POS1.g_num_periods).ccid := PSB_WS_POS1.g_salary_dist(l_saldist_index).ccid;
	PSB_WS_POS1.g_periods(PSB_WS_POS1.g_num_periods).budget_year_id := p_budget_year_id;
	PSB_WS_POS1.g_periods(PSB_WS_POS1.g_num_periods).element_type := 'S';
	PSB_WS_POS1.g_periods(PSB_WS_POS1.g_num_periods).element_set_id := p_pay_element_id;
	PSB_WS_POS1.g_periods(PSB_WS_POS1.g_num_periods).percent := l_percent;
	PSB_WS_POS1.g_periods(PSB_WS_POS1.g_num_periods).period_start_date := l_new_start_date;
	PSB_WS_POS1.g_periods(PSB_WS_POS1.g_num_periods).period_end_date := l_new_end_date;

      end;
      end if;

    end loop;

	for l_dist_index in 1..PSB_WS_POS1.g_num_pd_costs loop

	if ((PSB_WS_POS1.g_pd_costs(l_dist_index).budget_year_id = p_budget_year_id)
	  and (PSB_WS_POS1.g_pd_costs(l_dist_index).element_type = 'S')
	  and (PSB_WS_POS1.g_pd_costs(l_dist_index).element_set_id = p_pay_element_id)) then

	    for l_period_index in 1..PSB_WS_POS1.g_num_periods loop

	       if ((PSB_WS_POS1.g_periods(l_period_index).ccid = PSB_WS_POS1.g_pd_costs(l_dist_index).ccid)
		  and (PSB_WS_POS1.g_periods(l_period_index).element_set_id = PSB_WS_POS1.g_pd_costs(l_dist_index).element_set_id)
		  and (PSB_WS_POS1.g_periods(l_period_index).element_type = 'S')
		  and (PSB_WS_POS1.g_periods(l_period_index).budget_year_id = PSB_WS_POS1.g_pd_costs(l_dist_index).budget_year_id)) then

		PSB_WS_POS1.Distribute_Periods
		(p_return_status        => l_return_status,
		 p_ccid                 => PSB_WS_POS1.g_pd_costs(l_dist_index).ccid,
		 p_element_type         => 'S',
		 p_element_set_id       => PSB_WS_POS1.g_pd_costs(l_dist_index).element_set_id,
		 p_budget_year_id       => p_budget_year_id,
		 p_dist_start_date      => PSB_WS_POS1.g_periods(l_period_index).period_start_date,
		 p_dist_end_date        => PSB_WS_POS1.g_periods(l_period_index).period_end_date,
		 p_start_date           => p_start_date,
		 p_end_date             => p_end_date,
		 p_element_index        => l_salary_index,
		 p_dist_index           => l_dist_index,
		 p_percent              => PSB_WS_POS1.g_periods(l_period_index).percent);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		end if;

		end if;

	    end loop;

	end if;
	end loop;

/* Bug No 2278216 End */

   if p_rounding_factor is not null then
     l_rounding_difference := l_rounding_difference +
				(round(PSB_WS_POS1.g_pc_costs(l_salary_index).element_cost / p_rounding_factor)
				    * p_rounding_factor - PSB_WS_POS1.g_pc_costs(l_salary_index).element_cost);
   end if;

   PSB_WS_POS1.g_pc_costs(l_salary_index).element_cost := PSB_WS_POS1.g_pc_costs(l_salary_index).element_cost +
							    l_rounding_difference;

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

END Distribute_Salary;

/* ----------------------------------------------------------------------- */

PROCEDURE Distribute_Other_Elements
( p_return_status     OUT  NOCOPY  VARCHAR2,
  p_pay_element_id    IN   NUMBER,
  p_data_extract_id   IN   NUMBER,
  p_flex_code         IN   NUMBER,
  p_rounding_factor   IN   NUMBER,
  p_position_line_id  IN   NUMBER,
  p_position_id       IN   NUMBER,
  p_budget_year_id    IN   NUMBER,
  p_start_date        IN   DATE,
  p_end_date          IN   DATE
) IS

  l_rounding_difference  NUMBER;

  l_calc_index           BINARY_INTEGER;
  l_element_index        BINARY_INTEGER;

  l_percent              NUMBER;
  l_elem_found           VARCHAR2(1) := FND_API.G_FALSE;

  l_start_date           DATE;
  l_end_date             DATE;

  l_update_dist          BOOLEAN;

/* Bug No 2278216 Start */
  l_return_status       VARCHAR2(1);
/* Bug No 2278216 End */

  l_msg_data            VARCHAR2(2000);
  l_msg_count           NUMBER;

  l_api_name            CONSTANT VARCHAR2(30) := 'Distribute_Other_Elements';

  cursor c_Dist is
    select a.code_combination_id,
	   a.distribution_percent,
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
       and d.position_id = p_position_id
     order by a.distribution_percent desc;

BEGIN

  for l_calc_index in 1..PSB_WS_POS1.g_num_pc_costs loop

    if ((PSB_WS_POS1.g_pc_costs(l_calc_index).budget_year_id = p_budget_year_id) and
	(PSB_WS_POS1.g_pc_costs(l_calc_index).pay_element_id = p_pay_element_id)) then
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

    l_rounding_difference := 0;

    for c_Dist_Rec in c_Dist loop

      l_update_dist := FALSE;

      if (((c_Dist_Rec.effective_start_date <= p_start_date) and
	     (c_Dist_Rec.effective_end_date is null)) or
	    ((c_Dist_Rec.effective_start_date between p_start_date and p_end_date) or
	     (c_Dist_Rec.effective_end_date between p_start_date and p_end_date) or
	    ((c_Dist_Rec.effective_start_date < p_start_date) and
	     (c_Dist_Rec.effective_end_date > p_end_date)))) then
      begin
	l_start_date := greatest(p_start_date, c_Dist_Rec.effective_start_date);
	l_end_date := least(p_end_date, nvl(c_Dist_Rec.effective_end_date, p_end_date));

	PSB_WS_POS1.g_pc_costs(l_element_index).element_set_id := p_pay_element_id;

        -- commented for bug # 4502946
	/*if c_Dist_Rec.distribution_percent < 1 then
	  l_percent := c_Dist_Rec.distribution_percent;
	else
	  l_percent := c_Dist_Rec.distribution_percent / 100;
	end if;*/

        -- added for bug # 4502946
        l_percent := c_Dist_Rec.distribution_percent / 100;

	for j in 1..PSB_WS_POS1.g_num_pd_costs loop
	  if ((PSB_WS_POS1.g_pd_costs(j).ccid = c_Dist_Rec.code_combination_id) and
	      (PSB_WS_POS1.g_pd_costs(j).element_set_id = p_pay_element_id) and
	      (PSB_WS_POS1.g_pd_costs(j).budget_year_id = p_budget_year_id)) then
	       /*For Bug No : 2782604 Start*/
	       --PSB_WS_POS1.g_num_pd_costs := j;
	       /*For Bug No : 2782604 End*/
		 l_update_dist := TRUE;
		 exit;
	  end if;
	end loop;

/* Bug No 2278216 Start */
-- Created a separate procedure for calculating period amounts

	if not (l_update_dist) then
	begin
	    PSB_WS_POS1.g_num_pd_costs := PSB_WS_POS1.g_num_pd_costs + 1;

	    PSB_WS_POS1.g_pd_costs(PSB_WS_POS1.g_num_pd_costs).budget_year_id := p_budget_year_id;
	    PSB_WS_POS1.g_pd_costs(PSB_WS_POS1.g_num_pd_costs).element_type := 'O';
	    PSB_WS_POS1.g_pd_costs(PSB_WS_POS1.g_num_pd_costs).ccid := c_Dist_Rec.code_combination_id;
	    PSB_WS_POS1.g_pd_costs(PSB_WS_POS1.g_num_pd_costs).element_set_id := p_pay_element_id;
	end;
	end if;

	PSB_WS_POS1.g_num_periods := PSB_WS_POS1.g_num_periods + 1;

	PSB_WS_POS1.g_periods(PSB_WS_POS1.g_num_periods).ccid := c_Dist_Rec.code_combination_id;
	PSB_WS_POS1.g_periods(PSB_WS_POS1.g_num_periods).budget_year_id := p_budget_year_id;
	PSB_WS_POS1.g_periods(PSB_WS_POS1.g_num_periods).element_type := 'O';
	PSB_WS_POS1.g_periods(PSB_WS_POS1.g_num_periods).element_set_id := p_pay_element_id;
	PSB_WS_POS1.g_periods(PSB_WS_POS1.g_num_periods).percent := l_percent;
	PSB_WS_POS1.g_periods(PSB_WS_POS1.g_num_periods).period_start_date := l_start_date;
	PSB_WS_POS1.g_periods(PSB_WS_POS1.g_num_periods).period_end_date := l_end_date;

      end;
      end if;

    end loop;

	for l_dist_index in 1..PSB_WS_POS1.g_num_pd_costs loop

	if ((PSB_WS_POS1.g_pd_costs(l_dist_index).budget_year_id = p_budget_year_id)
	  and (PSB_WS_POS1.g_pd_costs(l_dist_index).element_type = 'O')
	  and (PSB_WS_POS1.g_pd_costs(l_dist_index).element_set_id = p_pay_element_id)) then

	    for l_period_index in 1..PSB_WS_POS1.g_num_periods loop

	       if ((PSB_WS_POS1.g_periods(l_period_index).ccid = PSB_WS_POS1.g_pd_costs(l_dist_index).ccid)
		  and (PSB_WS_POS1.g_periods(l_period_index).element_set_id = PSB_WS_POS1.g_pd_costs(l_dist_index).element_set_id)
		  and (PSB_WS_POS1.g_periods(l_period_index).element_type = 'O')
		  and (PSB_WS_POS1.g_periods(l_period_index).budget_year_id = PSB_WS_POS1.g_pd_costs(l_dist_index).budget_year_id)) then

		PSB_WS_POS1.Distribute_Periods
		(p_return_status        => l_return_status,
		 p_ccid                 => PSB_WS_POS1.g_pd_costs(l_dist_index).ccid,
		 p_element_type         => 'O',
		 p_element_set_id       => PSB_WS_POS1.g_pd_costs(l_dist_index).element_set_id,
		 p_budget_year_id       => p_budget_year_id,
		 p_dist_start_date      => PSB_WS_POS1.g_periods(l_period_index).period_start_date,
		 p_dist_end_date        => PSB_WS_POS1.g_periods(l_period_index).period_end_date,
		 p_start_date           => p_start_date,
		 p_end_date             => p_end_date,
		 p_element_index        => l_element_index,
		 p_dist_index           => l_dist_index,
		 p_percent              => PSB_WS_POS1.g_periods(l_period_index).percent);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		end if;

		end if;

	    end loop;

	end if;
	end loop;

/* Bug No 2278216 End */

   if p_rounding_factor is not null then
     l_rounding_difference := l_rounding_difference +
				(round(PSB_WS_POS1.g_pc_costs(l_element_index).element_cost / p_rounding_factor)
				    * p_rounding_factor - PSB_WS_POS1.g_pc_costs(l_element_index).element_cost);
   end if;

   PSB_WS_POS1.g_pc_costs(l_element_index).element_cost := PSB_WS_POS1.g_pc_costs(l_element_index).element_cost +
							    l_rounding_difference;

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

END Distribute_Other_Elements;

/* ----------------------------------------------------------------------- */

PROCEDURE Update_Position_Cost
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_position_line_id     IN   NUMBER,
  p_position_start_date  IN   DATE,
  p_position_end_date    IN   DATE,
  p_worksheet_id         IN   NUMBER,
  p_flex_mapping_set_id  IN   NUMBER,
  p_global_worksheet_id  IN   NUMBER,
  p_func_currency        IN   VARCHAR2,
  p_rounding_factor      IN   NUMBER,
  p_service_package_id   IN   NUMBER,
  p_stage_set_id         IN   NUMBER,
  p_start_stage_seq      IN   NUMBER,
  p_current_stage_seq    IN   NUMBER,
  p_budget_year_id       IN   NUMBER,
  p_budget_group_id      IN   NUMBER
) IS

  l_start_date           DATE;
  l_end_date             DATE;
  l_budget_period_type   VARCHAR2(1);
  l_long_sequence_no     NUMBER;

  l_annual_fte           NUMBER;
  l_period_fte           PSB_WS_ACCT1.g_prdamt_tbl_type;
  l_num_budget_periods   NUMBER;

  l_fte_line_id          NUMBER;
  l_element_line_id      NUMBER;
  l_account_line_id      NUMBER;

  l_fte_assigned         VARCHAR2(1);
  l_position_exists      VARCHAR2(1);

  l_sal_account_line     VARCHAR2(1);

  l_period_amount        PSB_WS_ACCT1.g_prdamt_tbl_type;

  l_fte_index            BINARY_INTEGER;
  l_elemcost_index       BINARY_INTEGER;
  l_element_index        BINARY_INTEGER;
  l_wel_index            BINARY_INTEGER;
  l_dist_index           BINARY_INTEGER;
  l_wal_index            BINARY_INTEGER;
  l_init_index           BINARY_INTEGER;
  l_assign_index         BINARY_INTEGER;
  l_year_index           BINARY_INTEGER;
  l_period_index         BINARY_INTEGER;
  l_recalc_cost_index    BINARY_INTEGER;
  l_recalc_dist_index    BINARY_INTEGER;

  l_element_set_id       NUMBER;
  l_elemdist_exists      BOOLEAN;
  l_year_calculated      BOOLEAN := FALSE;

  l_processing_type      VARCHAR2(1);
  l_factor               NUMBER;

  l_old_ytd_amount       NUMBER;
  l_new_ytd_amount       NUMBER;
  l_element_cost         NUMBER;

  l_attr_fte             NUMBER := 0; --bug:5635570
  l_populate_attr_fte    BOOLEAN := FALSE; --bug:8650415

  l_note                 VARCHAR2(4000); --Bug#4571412
  l_return_status        VARCHAR2(1);
  l_msg_data             VARCHAR2(2000);
  l_msg_count            NUMBER;

  l_budget_year_name     VARCHAR2(15); -- Bug#4571412

  l_api_name              CONSTANT VARCHAR2(30) := 'Update_Position_Cost';

  cursor c_Position_Dist is
    select /*+ ORDERED INDEX(a PSB_WS_ACCOUNT_LINES_N5) */
	   account_line_id, code_combination_id,
	   service_package_id, element_set_id, budget_group_id
      from PSB_WS_ACCOUNT_LINES a
     where position_line_id = p_position_line_id
       and budget_year_id = p_budget_year_id
       and end_stage_seq is null;

  cursor c_Position_Cost is
    select element_line_id, service_package_id, pay_element_id
      from PSB_WS_ELEMENT_LINES
     where position_line_id = p_position_line_id
       and budget_year_id = p_budget_year_id
       and end_stage_seq is null;

  cursor c_Position_FTE is
    select /*+ ORDERED INDEX(a PSB_WS_FTE_LINES_N1) */
	   fte_line_id, annual_fte, service_package_id
      from PSB_WS_FTE_LINES a
     where position_line_id = p_position_line_id
       and budget_year_id = p_budget_year_id
       and end_stage_seq is null;

  cursor c_sp is
    select service_package_id
      from PSB_SERVICE_PACKAGES
     where global_worksheet_id = p_global_worksheet_id;

BEGIN

    /*start bug:7192891: STATEMENT level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/CALC_POS_COST/PSBVWP2B/Update_Position_Cost',
    'Inside Update Position Cost::'||'  budget year id is:'||p_budget_year_id);

   fnd_file.put_line(fnd_file.LOG, 'Inside Update Position Cost::'||'  budget year id is:'||p_budget_year_id);
   end if;
   /*end bug:7192891:end STATEMENT level log*/

  for l_init_index in 1..g_pf_recalc_fte.Count loop
    g_pf_recalc_fte(l_init_index).fte_line_id := null;
    g_pf_recalc_fte(l_init_index).annual_fte := null;
    g_pf_recalc_fte(l_init_index).service_package_id := null;
    g_pf_recalc_fte(l_init_index).ratio := null;
    g_pf_recalc_fte(l_init_index).recalc_flag := null;
  end loop;

  g_num_pf_recalc_fte := 0;

  for l_init_index in 1..g_pc_recalc_costs.Count loop
    g_pc_recalc_costs(l_init_index).element_line_id := null;
    g_pc_recalc_costs(l_init_index).pay_element_id := null;
    g_pc_recalc_costs(l_init_index).service_package_id := null;
    g_pc_recalc_costs(l_init_index).recalc_flag := null;
  end loop;

  g_num_pc_recalc_costs := 0;

  for l_init_index in 1..g_pd_recalc_costs.Count loop
    g_pd_recalc_costs(l_init_index).account_line_id := null;
    g_pd_recalc_costs(l_init_index).ccid := null;
    g_pd_recalc_costs(l_init_index).element_set_id := null;
    g_pd_recalc_costs(l_init_index).service_package_id := null;
    g_pd_recalc_costs(l_init_index).budget_group_id := null;
    g_pd_recalc_costs(l_init_index).redist_flag := null;
  end loop;

  g_num_pd_recalc_costs := 0;


  -- Store all the current costs, account distribution and FTE distribution
  for c_Position_FTE_Rec in c_Position_FTE loop
    g_num_pf_recalc_fte := g_num_pf_recalc_fte + 1;
    g_pf_recalc_fte(g_num_pf_recalc_fte).fte_line_id := c_Position_FTE_Rec.fte_line_id;
    g_pf_recalc_fte(g_num_pf_recalc_fte).service_package_id := c_Position_FTE_Rec.service_package_id;
    g_pf_recalc_fte(g_num_pf_recalc_fte).annual_fte := c_Position_FTE_Rec.annual_fte;
    g_pf_recalc_fte(g_num_pf_recalc_fte).ratio := null;
  end loop;

  for c_Position_Cost_Rec in c_Position_Cost loop
    g_num_pc_recalc_costs := g_num_pc_recalc_costs + 1;
    g_pc_recalc_costs(g_num_pc_recalc_costs).element_line_id := c_Position_Cost_Rec.element_line_id;
    g_pc_recalc_costs(g_num_pc_recalc_costs).pay_element_id := c_Position_Cost_Rec.pay_element_id;
    g_pc_recalc_costs(g_num_pc_recalc_costs).service_package_id := c_Position_Cost_Rec.service_package_id;
  end loop;

  for c_Position_Dist_Rec in c_Position_Dist loop
    g_num_pd_recalc_costs := g_num_pd_recalc_costs + 1;
    g_pd_recalc_costs(g_num_pd_recalc_costs).account_line_id := c_Position_Dist_Rec.account_line_id;
    g_pd_recalc_costs(g_num_pd_recalc_costs).ccid := c_Position_Dist_Rec.code_combination_id;
    g_pd_recalc_costs(g_num_pd_recalc_costs).element_set_id := c_Position_Dist_Rec.element_set_id;
    g_pd_recalc_costs(g_num_pd_recalc_costs).service_package_id := c_Position_Dist_Rec.service_package_id;
    g_pd_recalc_costs(g_num_pd_recalc_costs).budget_group_id := c_Position_Dist_Rec.budget_group_id;
  end loop;

  l_annual_fte := 0;
  l_attr_fte   := 0; --bug:7461135

  for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
    l_period_fte(l_init_index) := null;
  end loop;

  for l_elemcost_index in 1..PSB_WS_POS1.g_num_pc_costs loop

    if ((PSB_WS_POS1.g_pc_costs(l_elemcost_index).budget_year_id = p_budget_year_id) and
	(PSB_WS_POS1.g_pc_costs(l_elemcost_index).element_set_id is not null)) then
      l_year_calculated := TRUE;
      exit;
    end if;

  end loop;

  if l_year_calculated then
  begin

    for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

      if PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id = p_budget_year_id then
	l_num_budget_periods := PSB_WS_ACCT1.g_budget_years(l_year_index).num_budget_periods;
        l_budget_year_name   := PSB_WS_ACCT1.g_budget_years(l_year_index).year_name; -- Bug#4571412
      end if;

    end loop;

    /*start bug:7192891: STATEMENT level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/CALC_POS_COST/PSBVWP2B/Update_Position_Cost',
    'inside l_year_calculated for year:'||l_budget_year_name);

     fnd_file.put_line(fnd_file.LOG, 'inside l_year_calculated for year:'||l_budget_year_name);
   end if;
   /*end bug:7192891:end STATEMENT level log*/

    for l_period_index in 1..PSB_WS_ACCT1.g_num_budget_periods loop

      if PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id = p_budget_year_id then
      begin

	l_start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	l_end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	l_budget_period_type := PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_period_type;
	l_long_sequence_no := PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no;

	l_fte_assigned := FND_API.G_FALSE;

        /*For Bug No : 2811698 Start*/
        --Following condition has been changed to execute when there is no FTE profile option set
        --or when there is FTE profile option not set and corresponding profile is not available
        if ((g_recalc_flag) AND ((g_fte_profile_option = 'N') OR    --bug:5635570:added g_recalc_flag condition
            ((l_budget_period_type = 'M' AND g_num_monthly_profile = 0) OR
             (l_budget_period_type = 'Q' AND g_num_quarterly_profile = 0) OR
             (l_budget_period_type = 'S' AND g_num_semiannual_profile = 0) OR
             (l_budget_period_type = 'Y') --bug:8650415
             ))) then

 	  for l_assign_index in 1..g_num_posfte_assignments loop

  	    if (((g_posfte_assignments(l_assign_index).start_date <= l_start_date) and
	         (g_posfte_assignments(l_assign_index).end_date is null)) or
  	        ((g_posfte_assignments(l_assign_index).start_date between l_start_date and l_end_date) or
	         (g_posfte_assignments(l_assign_index).end_date between l_start_date and l_end_date) or
	        ((g_posfte_assignments(l_assign_index).start_date < l_start_date) and
 	         (g_posfte_assignments(l_assign_index).end_date > l_end_date)))) then
 	    begin

	      l_period_fte(l_long_sequence_no) := g_posfte_assignments(l_assign_index).fte;
	      l_annual_fte := l_annual_fte + g_posfte_assignments(l_assign_index).fte;
	      l_fte_assigned := FND_API.G_TRUE;
	      exit;

	    end;
	    end if;

	  end loop;
    /*bug:5635570:start*/
        elsif ((NOT g_recalc_flag) AND (g_num_pf_recalc_fte > 0)) then

            for l_fte_index in 1..g_num_pf_recalc_fte loop
  	      if g_pf_recalc_fte(l_fte_index).service_package_id = p_service_package_id then

                  l_period_fte(l_long_sequence_no) := g_pf_recalc_fte(l_fte_index).annual_fte;
                  l_annual_fte := l_annual_fte + g_pf_recalc_fte(l_fte_index).annual_fte;
                  l_fte_assigned := FND_API.G_TRUE;

 	      end if;
            end loop;


          if g_fte_profile_option = 'Y' then

             if l_budget_period_type = 'M' AND g_num_monthly_profile > 0 then
               l_attr_fte := l_attr_fte + nvl(g_monthly_profile(l_long_sequence_no), 0);
             end if;
             if l_budget_period_type = 'Q' AND g_num_quarterly_profile > 0 then
               l_attr_fte := l_attr_fte + nvl(g_quarterly_profile(l_long_sequence_no), 0);
             end if;
             if l_budget_period_type = 'S' AND g_num_semiannual_profile > 0 then
               l_attr_fte := l_attr_fte + nvl(g_semiannual_profile(l_long_sequence_no), 0);
             end if;

          end if;

            /*bug:8650415:start*/
	  if (l_attr_fte = 0 OR l_populate_attr_fte) then
            /*bug:8650415:end*/
   	    for l_assign_index in 1..g_num_posfte_assignments loop

  	     if (((g_posfte_assignments(l_assign_index).start_date <= l_start_date) and
	          (g_posfte_assignments(l_assign_index).end_date is null)) or
  	         ((g_posfte_assignments(l_assign_index).start_date between l_start_date and l_end_date) or
	          (g_posfte_assignments(l_assign_index).end_date between l_start_date and l_end_date) or
	         ((g_posfte_assignments(l_assign_index).start_date < l_start_date) and
 	          (g_posfte_assignments(l_assign_index).end_date > l_end_date)))) then
 	     begin
	       l_attr_fte := l_attr_fte + g_posfte_assignments(l_assign_index).fte; --bug:7461135:modified
	       l_populate_attr_fte := TRUE;  --bug:8650415
	       exit;
	     end;
	     end if;

	   end loop;
	  end if;

     /*bug:5635570:end*/

        end if;
        /*For Bug No : 2811698 End*/

	if not FND_API.to_Boolean(l_fte_assigned) then
	begin

	  l_position_exists := FND_API.G_FALSE;

	  if (((p_position_start_date <= l_start_date) and
	       (p_position_end_date is null)) or
	      ((p_position_start_date between l_start_date and l_end_date) or
	       (p_position_end_date between l_start_date and l_end_date) or
	      ((p_position_start_date < l_start_date) and
	       (p_position_end_date > l_end_date)))) then

	    l_position_exists := FND_API.G_TRUE;
	  end if;

	  if FND_API.to_Boolean(l_position_exists) then
	  begin

	    if l_budget_period_type = 'M' then
	    begin

	      if g_num_monthly_profile = 0 then
		l_period_fte(l_long_sequence_no) := g_default_fte;
		l_annual_fte := l_annual_fte + g_default_fte;
	      else
                /*For Bug No : 2811698 Start*/
                --replaced the g_default_fte to zero in the folowing code
		l_period_fte(l_long_sequence_no) := nvl(g_monthly_profile(l_long_sequence_no), 0);
		l_annual_fte := l_annual_fte + nvl(g_monthly_profile(l_long_sequence_no), 0);
                /*For Bug No : 2811698 End*/
	      end if;

	    end;
	    elsif l_budget_period_type = 'Q' then
	    begin

	      if g_num_quarterly_profile = 0 then
		l_period_fte(l_long_sequence_no) := g_default_fte;
		l_annual_fte := l_annual_fte + g_default_fte;
	      else
                /*For Bug No : 2811698 Start*/
                --replaced the g_default_fte to zero in the folowing code
		l_period_fte(l_long_sequence_no) := nvl(g_quarterly_profile(l_long_sequence_no), 0);
		l_annual_fte := l_annual_fte + nvl(g_quarterly_profile(l_long_sequence_no), 0);
                /*For Bug No : 2811698 End*/
	      end if;

	    end;
	    elsif l_budget_period_type = 'S' then
	    begin

	      if g_num_semiannual_profile = 0 then
                l_period_fte(l_long_sequence_no) := g_default_fte;
	        l_annual_fte := l_annual_fte + g_default_fte;
	      else
                /*For Bug No : 2811698 Start*/
                --replaced the g_default_fte to zero in the folowing code
		l_period_fte(l_long_sequence_no) := nvl(g_semiannual_profile(l_long_sequence_no), 0);
		l_annual_fte := l_annual_fte + nvl(g_semiannual_profile(l_long_sequence_no), 0);
                /*For Bug No : 2811698 End*/
	      end if;

	    end;
	    end if;

	  end;
	  end if;

	end;
	end if;

      end;
      end if;

    end loop;

    if l_num_budget_periods <> 0 then
      l_annual_fte := l_annual_fte / l_num_budget_periods;
      l_attr_fte := l_attr_fte/l_num_budget_periods;  --bug:7461135
    end if;


    if g_num_pf_recalc_fte > 0 then
    begin

      for l_fte_index in 1..g_num_pf_recalc_fte loop

	if g_pf_recalc_fte(l_fte_index).service_package_id = p_service_package_id then
	begin

	  g_pf_recalc_fte(l_fte_index).ratio := l_annual_fte;

	  PSB_WS_POS1.Create_FTE_Lines
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_worksheet_id => p_worksheet_id,
	      p_fte_line_id => g_pf_recalc_fte(l_fte_index).fte_line_id,
	      p_current_stage_seq => p_current_stage_seq,
	      p_period_fte => l_period_fte,
	      p_budget_group_id => p_budget_group_id);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end;
	else
	begin

	  if l_annual_fte <> 0 then
	    g_pf_recalc_fte(l_fte_index).ratio := g_pf_recalc_fte(l_fte_index).annual_fte / l_annual_fte;
	  end if;

	end;
	end if;

      end loop;

    end;
    else
    begin

      PSB_WS_POS1.Create_FTE_Lines
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_fte_line_id => l_fte_line_id,
	  p_check_spfl_exists => FND_API.G_FALSE,
	  p_worksheet_id => p_worksheet_id,
	  p_flex_mapping_set_id => p_flex_mapping_set_id,
	  p_position_line_id => p_position_line_id,
	  p_budget_year_id => p_budget_year_id,
	  p_budget_group_id => p_budget_group_id,
	  p_annual_fte => l_annual_fte,
	  p_service_package_id => p_service_package_id,
	  p_stage_set_id => p_stage_set_id,
	  p_start_stage_seq => p_start_stage_seq,
	  p_current_stage_seq => p_current_stage_seq,
	  p_period_fte => l_period_fte);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      g_num_pf_recalc_fte := g_num_pf_recalc_fte + 1;
      g_pf_recalc_fte(g_num_pf_recalc_fte).fte_line_id := l_fte_line_id;
      g_pf_recalc_fte(g_num_pf_recalc_fte).service_package_id := p_service_package_id;
      g_pf_recalc_fte(g_num_pf_recalc_fte).annual_fte := l_annual_fte;
      g_pf_recalc_fte(g_num_pf_recalc_fte).ratio := l_annual_fte;

    end;
    end if;

    for l_elemcost_index in 1..PSB_WS_POS1.g_num_pc_costs loop

    /*start bug:7192891: STATEMENT level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/CALC_POS_COST/PSBVWP2B/Update_Position_Cost',
    'Element id (update position cost):'||PSB_WS_POS1.g_pc_costs(l_elemcost_index).pay_element_id);

     fnd_file.put_line(fnd_file.LOG, 'Element id (update position cost):'||PSB_WS_POS1.g_pc_costs(l_elemcost_index).pay_element_id);
   end if;
   /*end bug:7192891:end STATEMENT level log*/

      if ((PSB_WS_POS1.g_pc_costs(l_elemcost_index).budget_year_id = p_budget_year_id) and
	  (PSB_WS_POS1.g_pc_costs(l_elemcost_index).element_set_id is not null)) then
      begin

	l_element_set_id := PSB_WS_POS1.g_pc_costs(l_elemcost_index).element_set_id;
	l_elemdist_exists := FALSE;

	for l_element_index in 1..PSB_WS_POS1.g_num_elements loop

	  if PSB_WS_POS1.g_elements(l_element_index).pay_element_id = PSB_WS_POS1.g_pc_costs(l_elemcost_index).pay_element_id then
	    l_processing_type := PSB_WS_POS1.g_elements(l_element_index).processing_type;
	    exit;
	  end if;

	end loop;

	for l_fte_index in 1..g_num_pf_recalc_fte loop

          /*bug:5635570:start*/
          if (g_pf_recalc_fte(l_fte_index).service_package_id = p_service_package_id) then
	    if g_recalc_flag then
	      l_factor := 1;
	    elsif l_attr_fte <> 0 then
	      l_factor := l_annual_fte/l_attr_fte;
	    end if;
          elsif (g_pf_recalc_fte(l_fte_index).service_package_id <> p_service_package_id) then
             if (l_annual_fte = 0 and l_attr_fte <> 0) then
              l_factor := g_pf_recalc_fte(l_fte_index).annual_fte/l_attr_fte;
             elsif NOT g_recalc_flag AND l_attr_fte <> 0 then
              l_factor := g_pf_recalc_fte(l_fte_index).annual_fte/l_attr_fte;
             else
              l_factor := g_pf_recalc_fte(l_fte_index).ratio;
             end if;
          else
            l_factor := g_pf_recalc_fte(l_fte_index).ratio;
	  end if;
	  /*bug:5635570:end*/

	  for l_dist_index in 1..PSB_WS_POS1.g_num_pd_costs loop

	    if ((PSB_WS_POS1.g_pd_costs(l_dist_index).budget_year_id = p_budget_year_id) and
		(PSB_WS_POS1.g_pd_costs(l_dist_index).element_set_id = l_element_set_id)) then
	    begin

	      l_elemdist_exists := TRUE;

	      for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
		l_period_amount(l_init_index) := null;
	      end loop;

	      l_period_amount(1) := PSB_WS_POS1.g_pd_costs(l_dist_index).period1_amount;
	      l_period_amount(2) := PSB_WS_POS1.g_pd_costs(l_dist_index).period2_amount;
	      l_period_amount(3) := PSB_WS_POS1.g_pd_costs(l_dist_index).period3_amount;
	      l_period_amount(4) := PSB_WS_POS1.g_pd_costs(l_dist_index).period4_amount;
	      l_period_amount(5) := PSB_WS_POS1.g_pd_costs(l_dist_index).period5_amount;
	      l_period_amount(6) := PSB_WS_POS1.g_pd_costs(l_dist_index).period6_amount;
	      l_period_amount(7) := PSB_WS_POS1.g_pd_costs(l_dist_index).period7_amount;
	      l_period_amount(8) := PSB_WS_POS1.g_pd_costs(l_dist_index).period8_amount;
	      l_period_amount(9) := PSB_WS_POS1.g_pd_costs(l_dist_index).period9_amount;
	      l_period_amount(10) := PSB_WS_POS1.g_pd_costs(l_dist_index).period10_amount;
	      l_period_amount(11) := PSB_WS_POS1.g_pd_costs(l_dist_index).period11_amount;
	      l_period_amount(12) := PSB_WS_POS1.g_pd_costs(l_dist_index).period12_amount;
	      l_period_amount(13) := PSB_WS_POS1.g_pd_costs(l_dist_index).period13_amount;
	      l_period_amount(14) := PSB_WS_POS1.g_pd_costs(l_dist_index).period14_amount;
	      l_period_amount(15) := PSB_WS_POS1.g_pd_costs(l_dist_index).period15_amount;
	      l_period_amount(16) := PSB_WS_POS1.g_pd_costs(l_dist_index).period16_amount;
	      l_period_amount(17) := PSB_WS_POS1.g_pd_costs(l_dist_index).period17_amount;
	      l_period_amount(18) := PSB_WS_POS1.g_pd_costs(l_dist_index).period18_amount;
	      l_period_amount(19) := PSB_WS_POS1.g_pd_costs(l_dist_index).period19_amount;
	      l_period_amount(20) := PSB_WS_POS1.g_pd_costs(l_dist_index).period20_amount;
	      l_period_amount(21) := PSB_WS_POS1.g_pd_costs(l_dist_index).period21_amount;
	      l_period_amount(22) := PSB_WS_POS1.g_pd_costs(l_dist_index).period22_amount;
	      l_period_amount(23) := PSB_WS_POS1.g_pd_costs(l_dist_index).period23_amount;
	      l_period_amount(24) := PSB_WS_POS1.g_pd_costs(l_dist_index).period24_amount;
	      l_period_amount(25) := PSB_WS_POS1.g_pd_costs(l_dist_index).period25_amount;
	      l_period_amount(26) := PSB_WS_POS1.g_pd_costs(l_dist_index).period26_amount;
	      l_period_amount(27) := PSB_WS_POS1.g_pd_costs(l_dist_index).period27_amount;
	      l_period_amount(28) := PSB_WS_POS1.g_pd_costs(l_dist_index).period28_amount;
	      l_period_amount(29) := PSB_WS_POS1.g_pd_costs(l_dist_index).period29_amount;
	      l_period_amount(30) := PSB_WS_POS1.g_pd_costs(l_dist_index).period30_amount;
	      l_period_amount(31) := PSB_WS_POS1.g_pd_costs(l_dist_index).period31_amount;
	      l_period_amount(32) := PSB_WS_POS1.g_pd_costs(l_dist_index).period32_amount;
	      l_period_amount(33) := PSB_WS_POS1.g_pd_costs(l_dist_index).period33_amount;
	      l_period_amount(34) := PSB_WS_POS1.g_pd_costs(l_dist_index).period34_amount;
	      l_period_amount(35) := PSB_WS_POS1.g_pd_costs(l_dist_index).period35_amount;
	      l_period_amount(36) := PSB_WS_POS1.g_pd_costs(l_dist_index).period36_amount;
	      l_period_amount(37) := PSB_WS_POS1.g_pd_costs(l_dist_index).period37_amount;
	      l_period_amount(38) := PSB_WS_POS1.g_pd_costs(l_dist_index).period38_amount;
	      l_period_amount(39) := PSB_WS_POS1.g_pd_costs(l_dist_index).period39_amount;
	      l_period_amount(40) := PSB_WS_POS1.g_pd_costs(l_dist_index).period40_amount;
	      l_period_amount(41) := PSB_WS_POS1.g_pd_costs(l_dist_index).period41_amount;
	      l_period_amount(42) := PSB_WS_POS1.g_pd_costs(l_dist_index).period42_amount;
	      l_period_amount(43) := PSB_WS_POS1.g_pd_costs(l_dist_index).period43_amount;
	      l_period_amount(44) := PSB_WS_POS1.g_pd_costs(l_dist_index).period44_amount;
	      l_period_amount(45) := PSB_WS_POS1.g_pd_costs(l_dist_index).period45_amount;
	      l_period_amount(46) := PSB_WS_POS1.g_pd_costs(l_dist_index).period46_amount;
	      l_period_amount(47) := PSB_WS_POS1.g_pd_costs(l_dist_index).period47_amount;
	      l_period_amount(48) := PSB_WS_POS1.g_pd_costs(l_dist_index).period48_amount;
	      l_period_amount(49) := PSB_WS_POS1.g_pd_costs(l_dist_index).period49_amount;
	      l_period_amount(50) := PSB_WS_POS1.g_pd_costs(l_dist_index).period50_amount;
	      l_period_amount(51) := PSB_WS_POS1.g_pd_costs(l_dist_index).period51_amount;
	      l_period_amount(52) := PSB_WS_POS1.g_pd_costs(l_dist_index).period52_amount;
	      l_period_amount(53) := PSB_WS_POS1.g_pd_costs(l_dist_index).period53_amount;
	      l_period_amount(54) := PSB_WS_POS1.g_pd_costs(l_dist_index).period54_amount;
	      l_period_amount(55) := PSB_WS_POS1.g_pd_costs(l_dist_index).period55_amount;
	      l_period_amount(56) := PSB_WS_POS1.g_pd_costs(l_dist_index).period56_amount;
	      l_period_amount(57) := PSB_WS_POS1.g_pd_costs(l_dist_index).period57_amount;
	      l_period_amount(58) := PSB_WS_POS1.g_pd_costs(l_dist_index).period58_amount;
	      l_period_amount(59) := PSB_WS_POS1.g_pd_costs(l_dist_index).period59_amount;
	      l_period_amount(60) := PSB_WS_POS1.g_pd_costs(l_dist_index).period60_amount;

	      if PSB_WS_POS1.g_pd_costs(l_dist_index).element_type = 'S' then
		l_sal_account_line := FND_API.G_TRUE;
	      else
		l_sal_account_line := FND_API.G_FALSE;
	      end if;

	      -- For each recalculated distribution, match the recalculated distribution
	      -- with the current distribution for the position

	      l_wal_index := null;

	      for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
		l_period_amount(l_init_index) := l_period_amount(l_init_index) * l_factor;
	      end loop;

             /*bug:7461135:start*/
 	      if p_rounding_factor is not null then
 	        l_old_ytd_amount := round(PSB_WS_POS1.g_pd_costs(l_dist_index).ytd_amount/p_rounding_factor) * p_rounding_factor;
 	        l_new_ytd_amount := round((l_old_ytd_amount * l_factor)/p_rounding_factor) * p_rounding_factor;
 	      else
 	        l_old_ytd_amount := PSB_WS_POS1.g_pd_costs(l_dist_index).ytd_amount;
 	        l_new_ytd_amount := PSB_WS_POS1.g_pd_costs(l_dist_index).ytd_amount * l_factor;
	      end if;
             /*bug:7461135:end*/

	      for l_recalc_dist_index in 1..g_num_pd_recalc_costs loop

		if ((PSB_WS_POS1.g_pd_costs(l_dist_index).ccid = g_pd_recalc_costs(l_recalc_dist_index).ccid) and
		    (PSB_WS_POS1.g_pd_costs(l_dist_index).element_set_id = g_pd_recalc_costs(l_recalc_dist_index).element_set_id) and
		    (PSB_WS_POS1.g_salary_budget_group_id = g_pd_recalc_costs(l_recalc_dist_index).budget_group_id) and
		    (g_pf_recalc_fte(l_fte_index).service_package_id = g_pd_recalc_costs(l_recalc_dist_index).service_package_id)) then
		begin

		  g_pd_recalc_costs(l_recalc_dist_index).redist_flag := 'Y';
		  l_wal_index := l_recalc_dist_index;

		  PSB_WS_ACCT1.Create_Account_Dist
		     (p_api_version => 1.0,
		      p_return_status => l_return_status,
		      p_worksheet_id => p_worksheet_id,
		      p_account_line_id => g_pd_recalc_costs(l_recalc_dist_index).account_line_id,
		      p_ytd_amount => l_new_ytd_amount,
		      p_period_amount => l_period_amount,
		      p_current_stage_seq => p_current_stage_seq,
		      p_budget_group_id => p_budget_group_id);

		  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		    raise FND_API.G_EXC_ERROR;
		  end if;

/* Bug No 1584464 Start */
---- Create Note Id and Inserts a record in PSB_WS_ACCOUNT_LINE_NOTES table

		  if PSB_WS_POS3.g_note_parameter_name is not null then
		  begin

		    FND_MESSAGE.SET_NAME('PSB', 'PSB_PARAMETER_NOTE_CREATION');
		    FND_MESSAGE.SET_TOKEN('NAME', PSB_WS_POS3.g_note_parameter_name);
		    FND_MESSAGE.SET_TOKEN('DATE', sysdate);
		    l_note := FND_MESSAGE.GET;

                    -- Bug#4571412.
                    -- Added parameters to make the call in sync
                    -- with its definition.
                    PSB_WS_ACCT1.Create_Note
                    ( p_return_status         => l_return_status
                    , p_account_line_id       => g_pd_recalc_costs(l_recalc_dist_index).account_line_id
                    , p_note                  => l_note
                    , p_chart_of_accounts_id  => PSB_WS_POS3.g_flex_code -- Bug#4675858
                    , p_budget_year           => l_budget_year_name
                    , p_cc_id                 => g_pd_recalc_costs(l_recalc_dist_index).ccid
                    , p_concatenated_segments => NULL
                    ) ;

		    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		      raise FND_API.G_EXC_ERROR;
		    end if;

----
/* Bug No 1584464 End */

		  end;
		  end if;

		end;
		end if;

	      end loop;

	      if l_wal_index is null then
	      begin

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
		    p_budget_group_id => PSB_WS_POS1.g_salary_budget_group_id,
		    p_ccid => PSB_WS_POS1.g_pd_costs(l_dist_index).ccid,
		    p_currency_code => p_func_currency,
		    p_balance_type => 'E',
		    p_ytd_amount => l_new_ytd_amount,
                    p_annual_fte => l_annual_fte,--Bug 3140801
		    p_period_amount => l_period_amount,
		    p_position_line_id => p_position_line_id,
		    p_element_set_id => PSB_WS_POS1.g_pd_costs(l_dist_index).element_set_id,
		    p_salary_account_line => l_sal_account_line,
		    p_service_package_id => g_pf_recalc_fte(l_fte_index).service_package_id,
		    p_start_stage_seq => p_start_stage_seq,
		    p_current_stage_seq => p_current_stage_seq);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		end if;

	      end;
	      end if;

	    end;
	    end if;

	  end loop;

	  if l_elemdist_exists then
	  begin

	    -- For each recalculated cost, match the recalculated cost with the current cost for the position

	    l_wel_index := null;

            /*bug:7461135:start*/
           if (p_rounding_factor is not null) then
            l_element_cost := round((PSB_WS_POS1.g_pc_costs(l_elemcost_index).element_cost * l_factor)/p_rounding_factor) * p_rounding_factor;
          else
            l_element_cost := PSB_WS_POS1.g_pc_costs(l_elemcost_index).element_cost * l_factor;
          end if;
           /*bug:7461135:end*/


	    for l_recalc_cost_index in 1..g_num_pc_recalc_costs loop

	      if ((PSB_WS_POS1.g_pc_costs(l_elemcost_index).pay_element_id = g_pc_recalc_costs(l_recalc_cost_index).pay_element_id) and
		  (g_pf_recalc_fte(l_fte_index).service_package_id = g_pc_recalc_costs(l_recalc_cost_index).service_package_id)) then
	      begin

		g_pc_recalc_costs(l_recalc_cost_index).recalc_flag := 'Y';
		l_wel_index := l_recalc_cost_index;

		PSB_WS_POS1.Create_Element_Lines
		   (p_api_version => 1.0,
		    p_return_status => l_return_status,
		    p_element_line_id => g_pc_recalc_costs(l_recalc_cost_index).element_line_id,
		    p_current_stage_seq => p_current_stage_seq,
		    p_element_cost => l_element_cost);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		end if;

	      end;
	      end if;

	    end loop;

	    if l_wel_index is null then
	    begin

	      PSB_WS_POS1.Create_Element_Lines
		 (p_api_version => 1.0,
		  p_return_status => l_return_status,
		  p_element_line_id => l_element_line_id,
		  p_check_spel_exists => FND_API.G_FALSE,
		  p_position_line_id => p_position_line_id,
		  p_budget_year_id => p_budget_year_id,
		  p_pay_element_id => PSB_WS_POS1.g_pc_costs(l_elemcost_index).pay_element_id,
		  p_currency_code => p_func_currency,
		  p_element_cost => l_element_cost,
		  p_element_set_id => PSB_WS_POS1.g_pc_costs(l_elemcost_index).element_set_id,
		  p_service_package_id => g_pf_recalc_fte(l_fte_index).service_package_id,
		  p_stage_set_id => p_stage_set_id,
		  p_start_stage_seq => p_start_stage_seq,
		  p_current_stage_seq => p_current_stage_seq);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      end if;

	    end;
	    end if;

	  end;
	  end if; /* elemdist exists */

	end loop; /* Loop for Service Package */

      end;
      end if;

    end loop;

  end;
  end if; /* year calculated */


  /* commented for bug 4627338
     as th updation has been moved outside the
     loop after the call to create_account_dist
     which reflects the latest YTD amount */

  /*
  for c_sp_rec in c_sp loop

    PSB_WS_POS1.Update_Annual_FTE
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_worksheet_id => p_worksheet_id,
	p_position_line_id => p_position_line_id,
	p_budget_year_id => p_budget_year_id,
	p_service_package_id => c_sp_rec.service_package_id,
	p_stage_set_id => p_stage_set_id,
	p_current_stage_seq => p_current_stage_seq,
	p_budget_group_id => p_budget_group_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end loop;
  */


  /*For Bug No : 3008353 Start*/
  --we shouldn't remove any lines from the prev stages when the
  --cost is computed as zero in the current stage. Hence assiging the
  --NULL values to the table so as the new cost will be zero and old cost
  --will remain exists for the previous stages with the new API call

  for l_recalc_cost_index in 1..g_num_pc_recalc_costs loop

    if g_pc_recalc_costs(l_recalc_cost_index).recalc_flag is null then
    begin

      PSB_WS_POS1.Create_Element_Lines
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_element_line_id => g_pc_recalc_costs(l_recalc_cost_index).element_line_id,
	    p_current_stage_seq => p_current_stage_seq,
	    p_element_cost => 0);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  end loop;

  for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
    l_period_amount(l_init_index) := NULL;
  end loop;

  for l_recalc_dist_index in 1..g_num_pd_recalc_costs loop

    if g_pd_recalc_costs(l_recalc_dist_index).redist_flag is null then
    begin

      PSB_WS_ACCT1.Create_Account_Dist
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_worksheet_id => p_worksheet_id,
	    p_account_line_id => g_pd_recalc_costs(l_recalc_dist_index).account_line_id,
	    p_ytd_amount => 0,
	    p_period_amount => l_period_amount,
	    p_current_stage_seq => p_current_stage_seq,
	    p_budget_group_id => p_budget_group_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  end loop;

  /*For Bug No : 3008353 End*/

  -- for bug 4627338
  for c_sp_rec in c_sp loop

    PSB_WS_POS1.Update_Annual_FTE
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_worksheet_id => p_worksheet_id,
	p_position_line_id => p_position_line_id,
	p_budget_year_id => p_budget_year_id,
	p_service_package_id => c_sp_rec.service_package_id,
	p_stage_set_id => p_stage_set_id,
	p_current_stage_seq => p_current_stage_seq,
	p_budget_group_id => p_budget_group_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end loop;

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

END Update_Position_Cost;

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

  -- Get Attribute Value for an Attribute Value Identifier

FUNCTION Get_Attribute_Value (p_attribute_value_id IN NUMBER) RETURN NUMBER IS

  l_attribute_value   NUMBER;

  cursor c_AttrVal is
           -- Fixed bug # 3683644
    select FND_NUMBER.canonical_to_number(attribute_value) attribute_value
      from PSB_ATTRIBUTE_VALUES
     where attribute_value_id = p_attribute_value_id;

BEGIN

  for c_AttrVal_Rec in c_AttrVal loop
    l_attribute_value := c_AttrVal_Rec.attribute_value;
  end loop;

  return l_attribute_value;

END Get_Attribute_Value;

/* ----------------------------------------------------------------------- */


END PSB_WS_POS2;

/
