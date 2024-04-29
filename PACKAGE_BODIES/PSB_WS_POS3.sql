--------------------------------------------------------
--  DDL for Package Body PSB_WS_POS3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_POS3" AS
/* $Header: PSBVWP3B.pls 120.15.12010000.13 2010/02/22 11:51:50 rkotha ship $ */

  G_PKG_NAME     CONSTANT  VARCHAR2(30):= 'PSB_WS_POS3';

  TYPE TokNameArray IS TABLE OF VARCHAR2(100)
    INDEX BY BINARY_INTEGER;

  TYPE TokValArray IS TABLE OF VARCHAR2(1000)
    INDEX BY BINARY_INTEGER;

  -- Number of Message Tokens

  no_msg_tokens              NUMBER := 0;

  -- Message Token Name

  msg_tok_names              TokNameArray;

  -- Message Token Value

  msg_tok_val                TokValArray;

  g_dbug                     VARCHAR2(1000);

  /*Bug:5924932:start*/
  g_event_type               VARCHAR2(2);
  /*Bug:5924932:end*/

  /*bug:8235347:start*/
  g_parameter_id            NUMBER;
  g_start_date              DATE;
  g_del_latest_ws_details   BOOLEAN := TRUE;

  TYPE g_num_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE g_dte_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE g_char_type IS TABLE OF VARCHAR2(60) INDEX BY BINARY_INTEGER;

  g_pos_id              g_num_type;
  g_ws_id               g_num_type;
  g_pay_ele_id          g_num_type;
  g_pay_ele_option_id   g_num_type;
  g_eff_start_date      g_dte_type;
  g_eff_end_date        g_dte_type;
  g_ele_val_type        g_char_type;
  g_ele_value           g_num_type;
  g_pay_basis           g_char_type;

  TYPE g_ws_pos_dtl_rec IS RECORD
  (
    WORKSHEET_ID           NUMBER,
    PAY_ELEMENT_ID         NUMBER,
    PAY_ELEMENT_OPTION_ID  NUMBER,
    EFFECTIVE_START_DATE   DATE,
    EFFECTIVE_END_DATE     DATE,
    ELEMENT_VALUE_TYPE     VARCHAR2(60),
    ELEMENT_VALUE          NUMBER,
    PAY_BASIS              VARCHAR2(60)
  );

  TYPE g_ws_pos_dtl_tbl_type IS TABLE OF g_ws_pos_dtl_rec
  INDEX BY BINARY_INTEGER;

  g_ws_pos_dtl_tbl    g_ws_pos_dtl_tbl_type;
  /*bug:8235347:end*/


/*Bug:5924184:start*/
  g_autoinc_apply         NUMBER := 0;
/*Bug:5924184:end*/

/*Bug:6374881:start*/
  TYPE g_salary_assign_type IS RECORD
  (
    position_id              NUMBER,
    pay_element_id           NUMBER,
    pay_element_option_id    NUMBER,
    effective_start_date     DATE,
    element_value_type       VARCHAR2(10),
    effective_end_date       DATE,
    element_value            NUMBER,
    pay_basis                VARCHAR2(15)
  );

/*Bug:6374881:end*/

/*bug:6626807:start*/
  TYPE g_pos_assign_tbl_type IS TABLE OF g_salary_assign_type
  INDEX BY BINARY_INTEGER;

  g_pos_assign_tbl   g_pos_assign_tbl_type;
/*bug:6626807:end*/

  /* start bug 4104890 */
  -- variable to hold the global profile option for
  -- auto increment cost calculation period : PSB_AUTOINC_COST_CALPERIOD
  g_autoinc_period_profile   VARCHAR2(1);
  g_budget_calendar_id       NUMBER;
  /* End bug 4104890 */

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function Definition                        */
/*                                                                         */
/* ----------------------------------------------------------------------- */

PROCEDURE Process_ElemParam_Option
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_pay_element_id      IN   NUMBER,
  p_start_date          IN   DATE,
  p_end_date            IN   DATE,
  p_worksheet_id        IN   NUMBER,
  p_element_value_type  IN   VARCHAR2,
  p_element_value       IN   NUMBER,
  p_currency_code       IN   VARCHAR2
);

PROCEDURE Process_ElemParam_PI
( p_return_status          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id           IN   NUMBER,
  p_currency_code          IN   VARCHAR2,
  p_start_date             IN   DATE,
  p_end_date               IN   DATE,
  p_compound_annually      IN   VARCHAR2,
  p_compound_factor        IN   NUMBER,
  p_pay_element_id         IN   NUMBER,
  p_pay_element_option_id  IN   NUMBER,
  p_element_value          IN   NUMBER
);

PROCEDURE Process_PosParam_PI
( p_return_status          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id           IN   NUMBER,
  p_global_worksheet_id    IN   NUMBER,
  p_data_extract_id        IN   NUMBER,
  p_position_id            IN   NUMBER,
  p_currency_code          IN   VARCHAR2,
  p_start_date             IN   DATE,
  p_end_date               IN   DATE,
  p_compound_annually      IN   VARCHAR2,
  p_compound_factor        IN   NUMBER,
  p_pay_element_id         IN   NUMBER,
  p_pay_element_option_id  IN   NUMBER,
  p_element_value          IN   NUMBER
);

PROCEDURE Process_PosParam_AutoInc_Step
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_worksheet_id       IN   NUMBER,
  p_data_extract_id    IN   NUMBER,
  p_business_group_id  IN   NUMBER,
  p_position_id        IN   NUMBER,
  p_currency_code      IN   VARCHAR2,
  p_start_date         IN   DATE,
  p_end_date           IN   DATE,
  p_compound_annually  IN   VARCHAR2,
  p_compound_factor    IN   NUMBER := FND_API.G_MISS_NUM,
  p_increment_type     IN   VARCHAR2,
  p_increment_by       IN   NUMBER
);

PROCEDURE Process_PosCons_Detailed
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_worksheet_id                  IN   NUMBER,
  p_data_extract_id               IN   NUMBER,
  p_business_group_id             IN   NUMBER,
  p_sp_exists                     IN   VARCHAR2,
  p_constraint_set_name           IN   VARCHAR2,
  p_constraint_threshold          IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_fte_constraint                IN   VARCHAR2,
  p_budget_year_id                IN   NUMBER,
  p_budget_year_name              IN   VARCHAR2,
  p_year_start_date               IN   DATE,
  p_year_end_date                 IN   DATE,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER
);

PROCEDURE Process_PosCons
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_worksheet_id                  IN   NUMBER,
  p_data_extract_id               IN   NUMBER,
  p_business_group_id             IN   NUMBER,
  p_sp_exists                     IN   VARCHAR2,
  p_constraint_set_name           IN   VARCHAR2,
  p_constraint_threshold          IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_position_line_id              IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_id                   IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_name                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_year_id                IN   NUMBER,
  p_budget_year_name              IN   VARCHAR2,
  p_year_start_date               IN   DATE,
  p_year_end_date                 IN   DATE,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER,
  p_summ_flag                     IN   VARCHAR2
);

PROCEDURE Process_PosCons_Step
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_worksheet_id                  IN   NUMBER,
  p_data_extract_id               IN   NUMBER,
  p_business_group_id             IN   NUMBER,
  p_sp_exists                     IN   VARCHAR2,
  p_constraint_set_name           IN   VARCHAR2,
  p_constraint_threshold          IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_position_line_id              IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_id                   IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_name                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_year_id                IN   NUMBER,
  p_budget_year_name              IN   VARCHAR2,
  p_year_start_date               IN   DATE,
  p_year_end_date                 IN   DATE,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER,
  p_summ_flag                     IN   VARCHAR2,
  p_pay_element_id                IN   NUMBER,
  p_pay_element_option_id         IN   NUMBER,
  p_prefix_operator               IN   VARCHAR2,
  p_element_value_type            IN   VARCHAR2,
  p_element_value                 IN   NUMBER
);

PROCEDURE Process_FTECons
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_worksheet_id                  IN   NUMBER,
  p_data_extract_id               IN   NUMBER,
  p_sp_exists                     IN   VARCHAR2,
  p_constraint_set_name           IN   VARCHAR2,
  p_constraint_threshold          IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_position_line_id              IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_id                   IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_name                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_year_id                IN   NUMBER,
  p_budget_year_name              IN   VARCHAR2,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER,
  p_summ_flag                     IN   VARCHAR2
);

PROCEDURE Redist_Follow_Salary_Year
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER,
  p_flex_mapping_set_id  IN   NUMBER,
  p_rounding_factor      IN   NUMBER,
  p_data_extract_id      IN   NUMBER,
  p_business_group_id    IN   NUMBER,
  p_flex_code            IN   NUMBER,
  p_position_line_id     IN   NUMBER,
  p_position_id          IN   NUMBER,
  p_position_start_date  IN   DATE,
  p_position_end_date    IN   DATE,
  p_budget_year_id       IN   NUMBER,
  p_year_start_date      IN   DATE,
  p_year_end_date        IN   DATE,
  p_service_package_id   IN   NUMBER,
  p_stage_set_id         IN   NUMBER,
  p_start_stage_seq      IN   NUMBER,
  p_current_stage_seq    IN   NUMBER,
  p_func_currency        IN   VARCHAR2
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

PROCEDURE Apply_Element_Parameters
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_global_worksheet    IN   VARCHAR2,
  p_budget_group_id     IN   NUMBER,
  p_data_extract_id     IN   NUMBER,
  p_business_group_id   IN   NUMBER,
  p_func_currency       IN   VARCHAR2,
  p_budget_calendar_id  IN   NUMBER,
  p_parameter_set_id    IN   NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Apply_Element_Parameters';
  l_api_version         CONSTANT NUMBER         := 1.0;

  l_global_worksheet    VARCHAR2(1);
  l_budget_group_id     NUMBER;
  l_data_extract_id     NUMBER;
  l_budget_calendar_id  NUMBER;
  l_parameter_set_id    NUMBER;

  l_business_group_id   NUMBER;
  l_func_currency       VARCHAR2(10);

  l_compound_annually   VARCHAR2(1);
  l_compound_factor     NUMBER;

  l_year_index          BINARY_INTEGER;

  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_return_status       VARCHAR2(1);

  cursor c_WS is
    select global_worksheet_flag,
	   budget_group_id,
	   nvl(data_extract_id, global_data_extract_id) data_extract_id,
	   budget_calendar_id,
	   nvl(parameter_set_id, global_parameter_set_id) parameter_set_id
      from PSB_WORKSHEETS_V
     where worksheet_id = p_worksheet_id;

  cursor c_BG is
    select nvl(business_group_id, root_business_group_id) business_group_id,
	   nvl(currency_code, root_currency_code) currency_code
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = l_budget_group_id;

  cursor c_Parameter (Year_Start_Date DATE,
		      Year_End_Date DATE) is
    select parameter_id,
	   name,
	   parameter_autoinc_rule,
	   parameter_compound_annually,
	   currency_code,
	   effective_start_date,
	   effective_end_date
      from PSB_PARAMETER_ASSIGNMENTS_V
     where data_extract_id = l_data_extract_id
       and parameter_type = 'ELEMENT'
       and (((effective_start_date <= Year_End_Date)
	 and (effective_end_date is null))
	 or ((effective_start_date between Year_Start_Date and Year_End_Date)
	  or (effective_end_date between Year_Start_Date and Year_End_Date)
	 or ((effective_start_date < Year_Start_Date)
	 and (effective_end_date > Year_End_Date))))
       and parameter_set_id = l_parameter_set_id
     order by effective_start_date,
	      priority;

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if ((p_global_worksheet = FND_API.G_MISS_CHAR) or
      (p_budget_group_id = FND_API.G_MISS_NUM) or
      (p_data_extract_id = FND_API.G_MISS_NUM) or
      (p_budget_calendar_id = FND_API.G_MISS_NUM) or
      (p_parameter_set_id = FND_API.G_MISS_NUM)) then
  begin

    for c_WS_Rec in c_WS loop
      l_global_worksheet := c_WS_Rec.global_worksheet_flag;
      l_budget_group_id := c_WS_Rec.budget_group_id;
      l_data_extract_id := c_WS_Rec.data_extract_id;
      l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
      l_parameter_set_id := c_WS_Rec.parameter_set_id;
    end loop;

  end;
  end if;

  if ((l_global_worksheet is null) or (l_global_worksheet = 'N')) then
    l_global_worksheet := FND_API.G_FALSE;
  else
    l_global_worksheet := FND_API.G_TRUE;
  end if;

  if p_global_worksheet <> FND_API.G_MISS_CHAR then
    l_global_worksheet := p_global_worksheet;
  end if;

  if p_budget_group_id <> FND_API.G_MISS_NUM then
    l_budget_group_id := p_budget_group_id;
  end if;

  if p_data_extract_id <> FND_API.G_MISS_NUM then
    l_data_extract_id := p_data_extract_id;
  end if;

  if p_budget_calendar_id <> FND_API.G_MISS_NUM then
    l_budget_calendar_id := p_budget_calendar_id;
  end if;

  if p_parameter_set_id <> FND_API.G_MISS_NUM then
    l_parameter_set_id := p_parameter_set_id;
  end if;

  if ((p_business_group_id = FND_API.G_MISS_NUM) or
      (p_func_currency = FND_API.G_MISS_CHAR)) then
  begin

    for c_BG_Rec in c_BG loop
      l_business_group_id := c_BG_Rec.business_group_id;
      l_func_currency := c_BG_Rec.currency_code;
    end loop;

  end;
  end if;

  if p_business_group_id <> FND_API.G_MISS_NUM then
    l_business_group_id := p_business_group_id;
  end if;

  if p_func_currency <> FND_API.G_MISS_CHAR then
    l_func_currency := p_func_currency;
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

  for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

    if PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP') then
    begin

      for c_Parameter_Rec in c_Parameter (PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
					  PSB_WS_ACCT1.g_budget_years(l_year_index).end_date) loop

	if ((c_Parameter_Rec.parameter_autoinc_rule is null) or
	    (c_Parameter_Rec.parameter_autoinc_rule = 'N')) then
	begin

	  if ((c_Parameter_Rec.parameter_compound_annually is null) or
	      (c_Parameter_Rec.parameter_compound_annually = 'N')) then
            /*bug:7007854:start*/
            l_compound_factor := null;
            /*bug:7007854:end*/
	    l_compound_annually := FND_API.G_FALSE;
	  else
	    l_compound_annually := FND_API.G_TRUE;
	    l_compound_factor := greatest(ceil(months_between(PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
							      c_Parameter_Rec.effective_start_date) / 12), 0) + 1;
	  end if;

	  Process_ElemParam
		 (p_return_status => l_return_status,
		  p_worksheet_id => p_worksheet_id,
		  p_parameter_id => c_Parameter_Rec.parameter_id,
		  p_currency_code => nvl(c_Parameter_Rec.currency_code, l_func_currency),
		  p_start_date => greatest(PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
					   c_Parameter_Rec.effective_start_date),
		  p_end_date => least(PSB_WS_ACCT1.g_budget_years(l_year_index).end_date,
				  nvl(c_Parameter_Rec.effective_end_date, PSB_WS_ACCT1.g_budget_years(l_year_index).end_date)),
		  p_compound_annually => l_compound_annually,
		  p_compound_factor => l_compound_factor);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;

	end;
	else
	begin

	  if FND_API.to_Boolean(l_global_worksheet) then
	  begin

	    l_compound_factor := greatest(ceil(months_between(PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
							      c_Parameter_Rec.effective_start_date) / 12), 0) + 1;

	    Process_ElemParam_AutoInc
		   (p_return_status => l_return_status,
		    p_worksheet_id => p_worksheet_id,
		    p_data_extract_id => l_data_extract_id,
		    p_business_group_id => l_business_group_id,
		    p_parameter_id => c_Parameter_Rec.parameter_id,
		    p_currency_code => nvl(c_Parameter_Rec.currency_code, l_func_currency),
		    p_start_date => greatest(PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
					     c_Parameter_Rec.effective_start_date),
		    p_end_date => least(PSB_WS_ACCT1.g_budget_years(l_year_index).end_date,
				    nvl(c_Parameter_Rec.effective_end_date, PSB_WS_ACCT1.g_budget_years(l_year_index).end_date)),
		    p_compound_factor => l_compound_factor);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;

	  end;
	  end if;

	end;
	end if;

      end loop;

    end;
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
	   p_procedure_name => l_api_name);
     end if;

END Apply_Element_Parameters;

/* ----------------------------------------------------------------------- */
/* Bug No 2482305 Start */

PROCEDURE Revise_Element_Projections
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_parameter_id        IN   NUMBER,
  p_recalculate_flag    IN   BOOLEAN
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Revise_Element_Projections';
  l_api_version         CONSTANT NUMBER         := 1.0;

  l_global_worksheet            VARCHAR2(1);
  l_global_worksheet_id         NUMBER;
  l_data_extract_id             NUMBER;
  l_budget_calendar_id          NUMBER;
  l_business_group_id           NUMBER;
  l_func_currency               VARCHAR2(10);

  l_parameter_name              VARCHAR2(30);
  l_currency_code               VARCHAR2(15);
  l_effective_start_date        DATE;
  l_effective_end_date          DATE;
  l_compound_annually           VARCHAR2(1);
  l_compound_factor             NUMBER;
  l_autoinc_rule                VARCHAR2(1);

  l_year_start_date             DATE;
  l_year_end_date               DATE;

  l_year_index                  BINARY_INTEGER;

  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_return_status               VARCHAR2(1);

  l_position_line_id            NUMBER;
  l_num_positions               NUMBER := 0;
  l_root_budget_group_id        NUMBER;
  l_set_of_books_id             NUMBER;
  l_flex_code                   NUMBER;

 /*Bug:6133032:start*/
  l_local_copy_flag             VARCHAR2(1) := 'N';
  l_worksheet_id                NUMBER;
 /*Bug:6133032:end*/

 l_process_position        BOOLEAN := FALSE; --bug:8935662

  cursor c_Positions is
    select pp.position_id, pp.name
      from PSB_POSITIONS pp
     where pp.data_extract_id = l_data_extract_id
       and exists
	  (select 1
	     from PSB_POSITION_ASSIGNMENTS pa,
		  PSB_PARAMETER_FORMULAS pf
	    where pa.position_id = pp.position_id
	      and pa.data_extract_id = pp.data_extract_id
	      and pa.assignment_type = 'ELEMENT'
	      and (pa.worksheet_id is null or pa.worksheet_id = p_worksheet_id)
	      and pf.parameter_id = p_parameter_id
	      and pa.pay_element_id = pf.pay_element_id)
       and exists
	  (select 1
	     from PSB_WS_POSITION_LINES wpl,
		  PSB_WS_LINES_POSITIONS wlp
	    where wpl.position_line_id = wlp.position_line_id
	      and wlp.worksheet_id = p_worksheet_id
	      and wpl.position_id = pp.position_id);

  cursor c_WS is
    select a.global_worksheet_flag,
	   nvl(a.global_worksheet_id, a.worksheet_id) global_worksheet_id,
	   nvl(a.data_extract_id, a.global_data_extract_id) data_extract_id,
	   a.budget_calendar_id,
	   nvl(b.business_group_id, b.root_business_group_id) business_group_id,
	   nvl(b.currency_code, b.root_currency_code) currency_code,
	   nvl(b.root_budget_group_id, b.budget_group_id) root_budget_group_id,
	   nvl(b.set_of_books_id, b.root_set_of_books_id) set_of_books_id,
	   a.local_copy_flag   --bug:6133032
      from PSB_WORKSHEETS_V a,
	   PSB_BUDGET_GROUPS_V b
     where a.worksheet_id = p_worksheet_id
       and b.budget_group_id = a.budget_group_id;

 /*Bug:5753424: Modified the cursor to populate effective_start_date
   and effective_end_date from psb_entity_assignment*/
  cursor c_Parameter is
    select ppv.name,
	   ppv.currency_code,
	   pea.effective_start_date,
	   pea.effective_end_date,
	   ppv.parameter_compound_annually,
	   ppv.parameter_autoinc_rule
      from PSB_PARAMETERS_V ppv,
           psb_entity_assignment pea     --bug:5753424
     where parameter_id = p_parameter_id
       and pea.entity_id = ppv.parameter_id --bug:5753424
       and parameter_type = 'ELEMENT';

  cursor c_SOB is
    select chart_of_accounts_id
      from GL_SETS_OF_BOOKS
     where set_of_books_id = l_set_of_books_id;

BEGIN

    /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Revise_Element_Projections',
    'BEGIN Revise_Position_Projections');
   fnd_file.put_line(fnd_file.LOG,'BEGIN Revise_Element_Projections');
   fnd_file.put_line(fnd_file.LOG,'Worksheet_id is:'||p_worksheet_id);
   end if;
   /*end bug:5753424:end procedure level log*/

  -- Standard Start of API savepoint

  SAVEPOINT  Revise_Element_Projections_Pvt;

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  for c_WS_Rec in c_WS loop
    l_global_worksheet := c_WS_Rec.global_worksheet_flag;
    l_global_worksheet_id := c_WS_Rec.global_worksheet_id;
    l_data_extract_id := c_WS_Rec.data_extract_id;
    l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
    l_business_group_id := c_WS_Rec.business_group_id;
    l_func_currency := c_WS_Rec.currency_code;
    l_root_budget_group_id := c_WS_Rec.root_budget_group_id;
    l_set_of_books_id := c_WS_Rec.set_of_books_id;
    l_local_copy_flag := c_WS_Rec.local_copy_flag; --bug:6133032
  end loop;

  for c_SOB_Rec in c_SOB loop
    l_flex_code := c_SOB_Rec.chart_of_accounts_id;
    g_flex_code := l_flex_code ; -- Bug#4675858
  end loop;

  if ((l_global_worksheet is null) or (l_global_worksheet = 'N')) then
    l_global_worksheet := FND_API.G_FALSE;
  else
    l_global_worksheet := FND_API.G_TRUE;
  end if;

  /*bug:6133032:start*/
  if FND_API.to_Boolean(l_global_worksheet) then
     l_worksheet_id := NVL(l_global_worksheet_id,p_worksheet_id);
  else
     if l_local_copy_flag is null then
        l_worksheet_id := l_global_worksheet_id;
     elsif l_local_copy_flag = 'Y' then
        l_worksheet_id := p_worksheet_id;
     end if;
  end if;
 /*bug:6133032:end*/

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

  for c_Parameter_rec in c_Parameter loop
    g_note_parameter_name  := c_Parameter_Rec.name; -- Bug#4675858
    l_parameter_name       := c_Parameter_Rec.name;
    l_currency_code        := c_Parameter_Rec.currency_code;
    l_effective_start_date := c_Parameter_Rec.effective_start_date;
    l_effective_end_date   := c_Parameter_Rec.effective_end_date;
    l_compound_annually    := c_Parameter_Rec.parameter_compound_annually;
    l_autoinc_rule         := c_Parameter_Rec.parameter_autoinc_rule;
  end loop;

  if ((l_compound_annually is null) or (l_compound_annually = 'N')) then
    l_compound_annually := FND_API.G_FALSE;
  else
    l_compound_annually := FND_API.G_TRUE;
  end if;

  if ((l_autoinc_rule is null) or (l_autoinc_rule = 'N')) then
    l_autoinc_rule := FND_API.G_FALSE;
  else
    l_autoinc_rule := FND_API.G_TRUE;
  end if;

  for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

    if PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP') then
    begin

	l_year_start_date := PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
	l_year_end_date := PSB_WS_ACCT1.g_budget_years(l_year_index).end_date;

	if (((l_effective_start_date <= l_year_end_date) and
	     (l_effective_end_date is null)) or
	    ((l_effective_start_date between l_year_start_date and l_year_end_date) or
	     (l_effective_end_date between l_year_start_date and l_year_end_date) or
	    ((l_effective_start_date < l_year_start_date) and
	     (l_effective_end_date > l_year_end_date)))) then
	begin

	  if NOT FND_API.to_Boolean(l_autoinc_rule) then
	  begin

	    if FND_API.to_Boolean(l_compound_annually) then
	      l_compound_factor := greatest(ceil(months_between(l_year_start_date, l_effective_start_date) / 12), 0) + 1;
	    end if;

    /*start bug:5753424: STATEMENT level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Revise_Element_Projections',
    'Before call to Process_ElemParam for parameter:'||p_parameter_id);
   fnd_file.put_line(fnd_file.LOG,'Before call to Process_ElemParam for parameter:'||p_parameter_id);
   end if;
   /*end bug:5753424:end STATEMENT level log*/

	    Process_ElemParam
		 (p_return_status => l_return_status,
        /*Bug:6133032:passed l_worksheet_id for parameter p_worksheet_id */
		  p_worksheet_id => nvl(l_worksheet_id,p_worksheet_id),
		  p_parameter_id => p_parameter_id,
		  p_currency_code => nvl(l_currency_code, l_func_currency),
		  p_start_date => greatest(l_year_start_date, l_effective_start_date),
		  p_end_date => least(l_year_end_date, nvl(l_effective_end_date, l_year_end_date)),
		  p_compound_annually => l_compound_annually,
		  p_compound_factor => l_compound_factor);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;

	  end;
	  else
	  begin

	   /*if FND_API.to_Boolean(l_global_worksheet) then
	   begin*/ --commented for bug:6133032

	     l_compound_factor := greatest(ceil(months_between(l_year_start_date, l_effective_start_date) / 12), 0) + 1;

    /*start bug:5753424: STATEMENT level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Revise_Element_Projections',
    'Before call to Process_ElemParam_AutoInc for parameter:'||p_parameter_id);
   fnd_file.put_line(fnd_file.LOG,'Before call to Process_ElemParam_AutoInc for parameter:'||p_parameter_id);
   end if;
   /*end bug:5753424:end STATEMENT level log*/

	     Process_ElemParam_AutoInc
		   (p_return_status => l_return_status,
        /*Bug:6133032:passed l_worksheet_id for parameter p_worksheet_id */
		    p_worksheet_id => nvl(l_worksheet_id,p_worksheet_id),
		    p_data_extract_id => l_data_extract_id,
		    p_business_group_id => l_business_group_id,
		    p_parameter_id => p_parameter_id,
		    p_currency_code => nvl(l_currency_code, l_func_currency),
		    p_start_date => greatest(l_year_start_date, l_effective_start_date),
		    p_end_date => least(l_year_end_date, nvl(l_effective_end_date, l_year_end_date)),
		    p_compound_factor => l_compound_factor);

	     if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	       raise FND_API.G_EXC_ERROR;
	     end if;
	   /*end;
	   end if;*/--commented for bug:6133032

	 end;
	 end if;        -- End of autoinc_rule check

	end;
	end if;

    end;
    end if;

  end loop;

  for c_positions_rec in c_positions loop
  begin
      l_process_position := FALSE;  --bug:8935662

      if p_recalculate_flag then
      begin

    /*bug:8935662:Added if condition to avoid multiple executions of Cache_Salary_Dist
      for a given position*/
      if ((not g_pos_sal_dist_flag.EXISTS(c_Positions_Rec.position_id)) OR
        g_pos_sal_dist_flag(c_Positions_Rec.position_id) = 'Y') then
    /*bug:8935662:end*/

	PSB_WS_POS1.g_salary_budget_group_id := null;

	PSB_WS_POS1.Cache_Salary_Dist
	   (p_return_status => l_return_status,
        /*Bug:6133032:passed l_worksheet_id for parameter p_worksheet_id */
	    p_worksheet_id => NVL(l_worksheet_id,l_global_worksheet_id),
	    p_root_budget_group_id => l_root_budget_group_id,
	    p_flex_code => l_flex_code,
	    p_data_extract_id => l_data_extract_id,
	    p_position_id => c_Positions_Rec.position_id,
	    p_position_name => c_Positions_Rec.name,
	    p_start_date => PSB_WS_ACCT1.g_startdate_cy,
	    p_end_date => PSB_WS_ACCT1.g_end_est_date);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  g_pos_sal_dist_flag(c_Positions_Rec.position_id) := 'N'; --bug:8935662
	elsif l_return_status = FND_API.G_RET_STS_SUCCESS then
	  g_pos_sal_dist_flag(c_Positions_Rec.position_id) := 'Y'; --bug:8935662
	end if;
	/*bug:8935662:start*/
       end if;

       if g_pos_sal_dist_flag(c_Positions_Rec.position_id) = 'Y' then
         l_process_position := TRUE;
       else
         l_process_position := FALSE;
       end if;
        /*bug:8935662:end*/


   if l_process_position then --bug:8935662

	PSB_WS_POS1.Create_Position_Lines
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_position_line_id => l_position_line_id,
        /*Bug:6133032:passed l_worksheet_id for parameter p_worksheet_id */
	    p_worksheet_id => nvl(l_worksheet_id,p_worksheet_id),
	    p_position_id => c_Positions_Rec.position_id,
	    p_budget_group_id => PSB_WS_POS1.g_salary_budget_group_id);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

	PSB_WS_POS2.Calculate_Position_Cost
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
        /*Bug:6133032:passed l_worksheet_id for parameter p_worksheet_id */
	    p_worksheet_id => nvl(l_worksheet_id,p_worksheet_id),
       /*Bug:6133032:passed value for parameter p_global_worksheet_id*/
	    p_global_worksheet_id => nvl(l_worksheet_id,p_worksheet_id),
	    p_position_line_id => l_position_line_id,
        /*Start bug:5635570*/
            p_lparam_flag => FND_API.G_TRUE
       /*End bug:5635570*/
	    );

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;
  /*bug:8935662:start*/
   end if;
   /*bug:8935662:end*/
      end;
      end if;

      l_num_positions := l_num_positions + 1;

      if l_num_positions > PSB_WS_ACCT1.g_checkpoint_save then
	commit work;
	l_num_positions := 0;
	savepoint Revise_Element_Projections_Pvt;
      end if;

  end;
  end loop;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

     /*start bug:5753424: procedure level logging*/
   if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
     'PSB/LOCAL_PARAM_SET/PSBVWP3B/Revise_Element_Projections',
     'END Revise_Position_Projections');
    fnd_file.put_line(fnd_file.LOG,'END Revise_Element_Projections');
    end if;
   /*end bug:5753424:end procedure level log*/

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Revise_Element_Projections_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Revise_Element_Projections_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     rollback to Revise_Element_Projections_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Revise_Element_Projections;

/* Bug No 2482305 End */
/* ----------------------------------------------------------------------- */

PROCEDURE Process_ElemParam
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_worksheet_id       IN   NUMBER,
  p_parameter_id       IN   NUMBER,
  p_currency_code      IN   VARCHAR2,
  p_start_date         IN   DATE,
  p_end_date           IN   DATE,
  p_compound_annually  IN   VARCHAR2,
  p_compound_factor    IN   NUMBER
) IS

  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  l_element_value       NUMBER;
  l_element_value_type  VARCHAR(2);

  l_start_date          DATE;
  l_end_date            DATE;

  l_return_status       VARCHAR2(1);

  cursor c_Formula is
    select pay_element_id,
	   pay_element_option_id,
	   element_value_type,
	   element_value,
	   effective_start_date,
	   effective_end_date
      from PSB_PARAMETER_FORMULAS
     where parameter_id = p_parameter_id
     order by step_number;

BEGIN

  for c_Formula_Rec in c_Formula loop

    l_start_date := greatest(nvl(c_Formula_Rec.effective_start_date, p_start_date), p_start_date);
    l_end_date := least(nvl(c_Formula_Rec.effective_end_date, p_end_date), p_end_date);

    if ((l_start_date <= l_end_date) and
       ((l_start_date between p_start_date and p_end_date) or
	(l_end_date between p_start_date and p_end_date))) then
    begin

      if c_Formula_Rec.element_value_type = 'PI' then
      begin

	Process_ElemParam_PI
	       (p_return_status => l_return_status,
		p_worksheet_id => p_worksheet_id,
		p_currency_code => p_currency_code,
		p_start_date => l_start_date,
		p_end_date => l_end_date,
		p_compound_annually => p_compound_annually,
		p_compound_factor => p_compound_factor,
		p_pay_element_id => c_Formula_Rec.pay_element_id,
		p_pay_element_option_id => c_Formula_Rec.pay_element_option_id,
		p_element_value => c_Formula_Rec.element_value);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      elsif c_Formula_Rec.element_value_type = 'PS' then
      begin

	if FND_API.to_Boolean(p_compound_annually) then
	begin

        /* Bug 3786457 Start */
        /* if c_Formula_Rec.element_value < 1 then
             l_element_value := c_Formula_Rec.element_value * POWER(1 + c_Formula_Rec.element_value, p_compound_factor);
           else
             l_element_value := c_Formula_Rec.element_value * POWER(1 + c_Formula_Rec.element_value / 100, p_compound_factor);
           end if; */
           l_element_value
           := c_Formula_Rec.element_value * POWER(1 + c_Formula_Rec.element_value / 100, p_compound_factor);
        /* Bug 3786457 End */

	end;
	else
	  l_element_value := c_Formula_Rec.element_value;
	end if;

	l_element_value_type := c_Formula_Rec.element_value_type;

      end;
      else
	l_element_value := c_Formula_Rec.element_value;
	l_element_value_type := c_Formula_Rec.element_value_type;
      end if;

      if c_Formula_Rec.element_value_type <> 'PI' then
      begin

	if c_Formula_Rec.pay_element_option_id is null then
	begin

	  Process_ElemParam_Option
		 (p_return_status => l_return_status,
		  p_pay_element_id => c_Formula_Rec.pay_element_id,
		  p_start_date => l_start_date,
		  p_end_date => l_end_date,
		  p_worksheet_id => p_worksheet_id,
		  p_element_value_type => l_element_value_type,
		  p_element_value => l_element_value,
		  p_currency_code => p_currency_code);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end;
	else
	begin

	  PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_pay_element_id => c_Formula_Rec.pay_element_id,
	      p_pay_element_option_id => c_Formula_Rec.pay_element_option_id,
	      p_effective_start_date => l_start_date,
	      p_effective_end_date => l_end_date,
	      p_worksheet_id => p_worksheet_id,
	      p_element_value_type => l_element_value_type,
	      p_element_value => l_element_value,
	      p_formula_id => null,
	      p_pay_basis => null,
	      p_maximum_value => null,
	      p_mid_value => null,
	      p_minimum_value => null,
	      p_currency_code => p_currency_code);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end;
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

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => 'Process_ElemParam');
     end if;

END Process_ElemParam;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_ElemParam_Option
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_pay_element_id      IN   NUMBER,
  p_start_date          IN   DATE,
  p_end_date            IN   DATE,
  p_worksheet_id        IN   NUMBER,
  p_element_value_type  IN   VARCHAR2,
  p_element_value       IN   NUMBER,
  p_currency_code       IN   VARCHAR2
) IS

  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  l_return_status       VARCHAR2(1);
  l_option_flag         VARCHAR2(1);

  cursor c_ElemOption is
    select pay_element_option_id
      from PSB_PAY_ELEMENT_OPTIONS
     where pay_element_id = p_pay_element_id;

BEGIN

  l_option_flag := 'N';

  for c_ElemOption_Rec in c_ElemOption loop

    l_option_flag := 'Y';

    PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_msg_count => l_msg_count,
	p_msg_data => l_msg_data,
	p_pay_element_id => p_pay_element_id,
	p_pay_element_option_id => c_ElemOption_Rec.pay_element_option_id,
	p_effective_start_date => p_start_date,
	p_effective_end_date => p_end_date,
	p_worksheet_id => p_worksheet_id,
	p_element_value_type => p_element_value_type,
	p_element_value => p_element_value,
	p_formula_id => null,
	p_pay_basis => null,
	p_maximum_value => null,
	p_mid_value => null,
	p_minimum_value => null,
	p_currency_code => p_currency_code);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end loop;

  if (l_option_flag = 'N') then
    PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_msg_count => l_msg_count,
	p_msg_data => l_msg_data,
	p_pay_element_id => p_pay_element_id,
	p_pay_element_option_id => null,
	p_effective_start_date => p_start_date,
	p_effective_end_date => p_end_date,
	p_worksheet_id => p_worksheet_id,
	p_element_value_type => p_element_value_type,
	p_element_value => p_element_value,
	p_formula_id => null,
	p_pay_basis => null,
	p_maximum_value => null,
	p_mid_value => null,
	p_minimum_value => null,
	p_currency_code => p_currency_code);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
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
     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => 'Process_ElemParam_Option');
     end if;

END Process_ElemParam_Option;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_ElemParam_PI
( p_return_status          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id           IN   NUMBER,
  p_currency_code          IN   VARCHAR2,
  p_start_date             IN   DATE,
  p_end_date               IN   DATE,
  p_compound_annually      IN   VARCHAR2,
  p_compound_factor        IN   NUMBER,
  p_pay_element_id         IN   NUMBER,
  p_pay_element_option_id  IN   NUMBER,
  p_element_value          IN   NUMBER
) IS

  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);

  l_element_value          NUMBER;
  l_element_value_type     VARCHAR(2);

  l_return_status          VARCHAR2(1);

  cursor c_ElemRates is
    select pay_element_option_id,
	   effective_start_date,
	   effective_end_date,
	   element_value_type,
	   element_value,
	   formula_id,
	   pay_basis
      from PSB_PAY_ELEMENT_RATES
     where worksheet_id is null
       and currency_code = p_currency_code
       and ((p_pay_element_option_id is null)
	 or (pay_element_option_id = p_pay_element_option_id))
       and (((effective_start_date <= p_end_date)
	 and (effective_end_date is null))
	 or ((effective_start_date between p_start_date and p_end_date)
	  or (effective_end_date between p_start_date and p_end_date)
	 or ((effective_start_date < p_start_date)
	 and (effective_end_date > p_end_date))))
       and pay_element_id = p_pay_element_id;

BEGIN

  for c_ElemRates_Rec in c_ElemRates loop

    if c_ElemRates_Rec.element_value_type in ('A', 'PS') then
    begin

      if FND_API.to_Boolean(p_compound_annually) then
      begin

      /* Bug 3786457 Start */
      /* IF p_element_value < 1 THEN
           l_element_value := c_ElemRates_Rec.element_value * POWER(1 + p_element_value, p_compound_factor);
         ELSE
           l_element_value := c_ElemRates_Rec.element_value * POWER(1 + p_element_value / 100, p_compound_factor);
         END IF; */
         l_element_value
          := c_ElemRates_Rec.element_value * POWER(1 + p_element_value / 100, p_compound_factor);
      /* Bug 3786457 End */

      end;
      else
      begin

        /* Bug 3786457 Start */
        /* IF p_element_value < 1 THEN
             l_element_value := c_ElemRates_Rec.element_value * (1 + p_element_value);
           ELSE
             l_element_value := c_ElemRates_Rec.element_value * (1 + p_element_value / 100);
           END IF;  */
           l_element_value
            := c_ElemRates_Rec.element_value * (1 + p_element_value / 100);
        /* Bug 3786457 End */

      end;
      end if;

      l_element_value_type := c_ElemRates_Rec.element_value_type;

      PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_pay_element_id => p_pay_element_id,
	  p_pay_element_option_id => c_ElemRates_Rec.pay_element_option_id,
	  p_effective_start_date => greatest(c_ElemRates_Rec.effective_start_date, p_start_date),
	  p_effective_end_date => least(nvl(c_ElemRates_Rec.effective_end_date, p_end_date), p_end_date),
	  p_worksheet_id => p_worksheet_id,
	  p_element_value_type => l_element_value_type,
	  p_element_value => l_element_value,
	  p_formula_id => null,
	  p_pay_basis => c_ElemRates_Rec.pay_basis,
	  p_maximum_value => null,
	  p_mid_value => null,
	  p_minimum_value => null,
	  p_currency_code => p_currency_code);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
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
	   p_procedure_name => 'Process_ElemParam_PI');
     end if;

END Process_ElemParam_PI;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_ElemParam_AutoInc
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_worksheet_id       IN   NUMBER,
  p_data_extract_id    IN   NUMBER,
  p_business_group_id  IN   NUMBER,
  p_parameter_id       IN   NUMBER,
  p_currency_code      IN   VARCHAR2,
  p_start_date         IN   DATE,
  p_end_date           IN   DATE,
  p_compound_factor    IN   NUMBER
) IS

  l_increment_by       NUMBER;
  l_increment_type     VARCHAR2(1);

  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);

  l_element_value      NUMBER;
  l_maximum_value      NUMBER;
  l_mid_value          NUMBER;
  l_minimum_value      NUMBER;

  l_return_status      VARCHAR2(1);

  cursor c_Formula is
    select increment_by,
	   increment_type
      from PSB_PARAMETER_FORMULAS
     where parameter_id = p_parameter_id;

  cursor c_ElemRates is
    select a.pay_element_id,
	   a.pay_element_option_id,
	   a.effective_start_date,
	   a.effective_end_date,
	   a.element_value_type,
	   a.element_value,
	   a.formula_id,
	   a.pay_basis,
	   a.maximum_value,
	   a.mid_value,
	   a.minimum_value
      from PSB_PAY_ELEMENT_RATES a,
	   PSB_PAY_ELEMENTS b
     where a.worksheet_id is null
       and a.currency_code = p_currency_code
       and (((a.effective_start_date <= p_end_date)
	 and (a.effective_end_date is null))
	 or ((a.effective_start_date between p_start_date and p_end_date)
	  or (a.effective_end_date between p_start_date and p_end_date)
	 or ((a.effective_start_date < p_start_date)
	 and (a.effective_end_date > p_end_date))))
       and a.pay_element_id = b.pay_element_id
       and b.salary_flag = 'Y'
       and b.processing_type = 'R'
       and b.business_group_id = p_business_group_id
       and b.data_extract_id = p_data_extract_id;

BEGIN

  for c_Formula_Rec in c_Formula loop
    l_increment_by := c_Formula_Rec.increment_by;
    l_increment_type := c_Formula_Rec.increment_type;
  end loop;

  for c_ElemRates_Rec in c_ElemRates loop

    if l_increment_type = 'A' then
    begin

      if c_ElemRates_Rec.element_value_type = 'A' then
      begin

	l_element_value := c_ElemRates_Rec.element_value + l_increment_by * p_compound_factor;
	l_maximum_value := c_ElemRates_Rec.maximum_value + l_increment_by * p_compound_factor;
	l_mid_value := c_ElemRates_Rec.mid_value + l_increment_by * p_compound_factor;
	l_minimum_value := c_ElemRates_Rec.minimum_value + l_increment_by * p_compound_factor;

	PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_pay_element_id => c_ElemRates_Rec.pay_element_id,
	    p_pay_element_option_id => c_ElemRates_Rec.pay_element_option_id,
	    p_effective_start_date => greatest(c_ElemRates_Rec.effective_start_date, p_start_date),
	    p_effective_end_date => least(nvl(c_ElemRates_Rec.effective_end_date, p_end_date), p_end_date),
	    p_worksheet_id => p_worksheet_id,
	    p_element_value_type => c_ElemRates_Rec.element_value_type,
	    p_element_value => l_element_value,
	    p_formula_id => c_ElemRates_Rec.formula_id,
	    p_pay_basis => c_ElemRates_Rec.pay_basis,
	    p_maximum_value => l_maximum_value,
	    p_mid_value => l_mid_value,
	    p_minimum_value => l_minimum_value,
	    p_currency_code => p_currency_code);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

    end;
    elsif l_increment_type = 'P' then
    begin

      if c_ElemRates_Rec.element_value_type = 'A' then
      begin

      /* Bug 2820755 Start */

      /* if l_increment_by < 1 then
	   l_element_value := c_ElemRates_Rec.element_value * POWER(1 + l_increment_by, p_compound_factor);
	   l_maximum_value := c_ElemRates_Rec.maximum_value * POWER(1 + l_increment_by, p_compound_factor);
	   l_mid_value := c_ElemRates_Rec.mid_value * POWER(1 + l_increment_by, p_compound_factor);
	   l_minimum_value := c_ElemRates_Rec.minimum_value * POWER(1 + l_increment_by, p_compound_factor);
	 else
	   l_element_value := c_ElemRates_Rec.element_value * POWER(1 + l_increment_by / 100, p_compound_factor);
	   l_maximum_value := c_ElemRates_Rec.maximum_value * POWER(1 + l_increment_by / 100, p_compound_factor);
	   l_mid_value := c_ElemRates_Rec.mid_value * POWER(1 + l_increment_by / 100, p_compound_factor);
	   l_minimum_value := c_ElemRates_Rec.minimum_value * POWER(1 + l_increment_by / 100, p_compound_factor);
	 end if; */

        l_element_value
          := c_ElemRates_Rec.element_value * POWER(1 + l_increment_by / 100, p_compound_factor);
        l_maximum_value
          := c_ElemRates_Rec.maximum_value * POWER(1 + l_increment_by / 100, p_compound_factor);
        l_mid_value
          := c_ElemRates_Rec.mid_value * POWER(1 + l_increment_by / 100, p_compound_factor);
        l_minimum_value
          := c_ElemRates_Rec.minimum_value * POWER(1 + l_increment_by / 100, p_compound_factor);
      /* Bug 2820755 End */

	PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_pay_element_id => c_ElemRates_Rec.pay_element_id,
	    p_pay_element_option_id => c_ElemRates_Rec.pay_element_option_id,
	    p_effective_start_date => greatest(c_ElemRates_Rec.effective_start_date, p_start_date),
	    p_effective_end_date => least(nvl(c_ElemRates_Rec.effective_end_date, p_end_date), p_end_date),
	    p_worksheet_id => p_worksheet_id,
	    p_element_value_type => c_ElemRates_Rec.element_value_type,
	    p_element_value => l_element_value,
	    p_formula_id => c_ElemRates_Rec.formula_id,
	    p_pay_basis => c_ElemRates_Rec.pay_basis,
	    p_maximum_value => l_maximum_value,
	    p_mid_value => l_mid_value,
	    p_minimum_value => l_minimum_value,
	    p_currency_code => p_currency_code);

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

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => 'Process_ElemParam_AutoInc');
     end if;

END Process_ElemParam_AutoInc;

/* ----------------------------------------------------------------------- */

FUNCTION Position_Exists
( p_event_type    VARCHAR2,
  p_worksheet_id  NUMBER,
  p_position_id   NUMBER) RETURN BOOLEAN IS

  l_position_exists       BOOLEAN := FALSE;

  cursor c_WS is
    select 'Exists'
      from dual
     where exists
	  (select 1 from PSB_WS_LINES_POSITIONS wlp, PSB_WS_POSITION_LINES wpl
	    where wlp.worksheet_id = p_worksheet_id
	      and wpl.position_line_id = wlp.position_line_id
	      and wpl.position_id = p_position_id);

  cursor c_BR is
    select 'Exists'
      from dual
     where exists
	  (select 1 from PSB_BUDGET_REVISION_POS_LINES brpl, PSB_BUDGET_REVISION_POSITIONS brp
	    where brpl.budget_revision_id = p_worksheet_id
	      and brp.budget_revision_pos_line_id = brpl.budget_revision_pos_line_id
	      and brp.position_id = p_position_id);

BEGIN

  if p_event_type = 'BP' then
    for c_WS_Rec in c_WS loop
      l_position_exists := TRUE;
    end loop;
  elsif p_event_type = 'BR' then
    for c_BR_Rec in c_BR loop
      l_position_exists := TRUE;
    end loop;
  end if;

  return l_position_exists;

END Position_Exists;

/* ----------------------------------------------------------------------- */

PROCEDURE Revise_Position_Projections
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  x_msg_data          OUT  NOCOPY  VARCHAR2,
  x_msg_count         OUT  NOCOPY  NUMBER,
  p_worksheet_id      IN   NUMBER,
  p_parameter_id      IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Revise_Position_Projections';
  l_api_version       CONSTANT NUMBER         := 1.0;

  l_global_worksheet      VARCHAR2(1);
  l_global_worksheet_id   NUMBER;
  l_data_extract_id       NUMBER;
  l_budget_calendar_id    NUMBER;
  l_business_group_id     NUMBER;
  l_func_currency         VARCHAR2(10);

  l_parameter_name        VARCHAR2(30);
  l_currency_code         VARCHAR2(15);
  l_effective_start_date  DATE;
  l_effective_end_date    DATE;
  l_compound_annually     VARCHAR2(1);
  l_compound_factor       NUMBER;
  l_autoinc_rule          VARCHAR2(1);

  l_year_start_date       DATE;
  l_year_end_date         DATE;

  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  l_return_status         VARCHAR2(1);

  /*Bug:6133032:start*/
  l_local_copy_flag             VARCHAR2(1) := 'N';
  l_worksheet_id                NUMBER;
 /*Bug:6133032:end*/

  cursor c_WS is
    select a.global_worksheet_flag,
	   nvl(a.global_worksheet_id, a.worksheet_id) global_worksheet_id,
	   nvl(a.data_extract_id, a.global_data_extract_id) data_extract_id,
	   a.budget_calendar_id,
	   nvl(b.business_group_id, b.root_business_group_id) business_group_id,
	   nvl(b.currency_code, b.root_currency_code) currency_code,
	   a.local_copy_flag   --bug:6133032
      from PSB_WORKSHEETS_V a,
	   PSB_BUDGET_GROUPS_V b
     where a.worksheet_id = p_worksheet_id
       and b.budget_group_id = a.budget_group_id;

/*Bug:5753424:Modified the cursor*/
  cursor c_Parameter is
    select ppv.name,
	   ppv.currency_code,
	   pea.effective_start_date,
	   pea.effective_end_date,
	   ppv.parameter_compound_annually,
	   ppv.parameter_autoinc_rule
      from PSB_PARAMETERS_V ppv,
           psb_entity_assignment pea  --bug:5753424
     where parameter_id = p_parameter_id
       and pea.entity_id = ppv.parameter_id  --bug:5753424
       and parameter_type = 'POSITION';

BEGIN

    /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Revise_Position_Projections',
    'BEGIN Revise_Position_Projections');
   fnd_file.put_line(fnd_file.LOG,'BEGIN Revise_Position_Projections');
   end if;
   /*end bug:5753424:end procedure level log*/

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  /* start bug 4104890*/
  -- this is applied for local parameters
  FND_PROFILE.GET('PSB_AUTOINC_COST_CALPERIOD', g_autoinc_period_profile);
  /* end bug 4104890*/


  for c_WS_Rec in c_WS loop
    l_global_worksheet := c_WS_Rec.global_worksheet_flag;
    l_global_worksheet_id := c_WS_Rec.global_worksheet_id;
    l_data_extract_id := c_WS_Rec.data_extract_id;
    l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
    l_business_group_id := c_WS_Rec.business_group_id;
    l_func_currency := c_WS_Rec.currency_code;
    l_local_copy_flag := c_WS_Rec.local_copy_flag; --bug:6133032
  end loop;

    /* start bug 4104890 */
    -- get the calendar Id
    g_budget_calendar_id := l_budget_calendar_id;
    /* end bug 4104890   */

  if ((l_global_worksheet is null) or (l_global_worksheet = 'N')) then
    l_global_worksheet := FND_API.G_FALSE;
  else
    l_global_worksheet := FND_API.G_TRUE;
  end if;

   /*bug:6133032:start*/
  if FND_API.to_Boolean(l_global_worksheet) then
     l_worksheet_id := nvl(l_global_worksheet_id,p_worksheet_id);
  else
     if l_local_copy_flag is null then
        l_worksheet_id := l_global_worksheet_id;
     elsif l_local_copy_flag = 'Y' then
        l_worksheet_id := p_worksheet_id;
     end if;
  end if;
 /*bug:6133032:end*/

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

  for c_Parameter_rec in c_Parameter loop
    l_parameter_name := c_Parameter_Rec.name;
    l_currency_code := c_Parameter_Rec.currency_code;
    l_effective_start_date := c_Parameter_Rec.effective_start_date;
    l_effective_end_date := c_Parameter_Rec.effective_end_date;
    l_compound_annually := c_Parameter_Rec.parameter_compound_annually;
    l_autoinc_rule := c_Parameter_Rec.parameter_autoinc_rule;
  end loop;

  if ((l_compound_annually is null) or (l_compound_annually = 'N')) then
    l_compound_annually := FND_API.G_FALSE;
  else
    l_compound_annually := FND_API.G_TRUE;
  end if;

  if ((l_autoinc_rule is null) or (l_autoinc_rule = 'N')) then
    l_autoinc_rule := FND_API.G_FALSE;
  else
    l_autoinc_rule := FND_API.G_TRUE;
  end if;

/* Bug No 2482305 Start */
-- added NOT in the condition

  if not FND_API.to_Boolean(l_autoinc_rule) then
/* Bug No 2482305 End */
  begin

    for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

      if PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP') then
      begin

	l_year_start_date := PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
	l_year_end_date := PSB_WS_ACCT1.g_budget_years(l_year_index).end_date;

	if (((l_effective_start_date <= l_year_end_date) and
	     (l_effective_end_date is null)) or
	    ((l_effective_start_date between l_year_start_date and l_year_end_date) or
	     (l_effective_end_date between l_year_start_date and l_year_end_date) or
	    ((l_effective_start_date < l_year_start_date) and
	     (l_effective_end_date > l_year_end_date)))) then
	begin

	  if FND_API.to_Boolean(l_compound_annually) then
	    l_compound_factor := greatest(ceil(months_between(l_year_start_date, l_effective_start_date) / 12), 0) + 1;
	  end if;

    /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Revise_Position_Projections',
    'Before call - Process_PosParam_Detailed for parameter:'||p_parameter_id);
   fnd_file.put_line(fnd_file.LOG,'Before call - Process_PosParam_Detailed for parameter:'||p_parameter_id);
   end if;
   /*end bug:5753424:end statement level log*/

	  Process_PosParam_Detailed
		 (p_return_status => l_return_status,
		  p_event_type => 'BP',
		  p_local_parameter => 'Y',
         /*Bug:6133032:passed l_worksheet_id for parameter p_worksheet_id */
		  p_worksheet_id => nvl(l_worksheet_id,p_worksheet_id),
		  p_global_worksheet_id => l_global_worksheet_id,
		  p_global_worksheet => l_global_worksheet,
		  p_data_extract_id => l_data_extract_id,
		  p_business_group_id => l_business_group_id,
		  p_parameter_id => p_parameter_id,
		  p_parameter_start_date => l_effective_start_date,
		  p_compound_annually => l_compound_annually,
		  p_compound_factor => l_compound_factor,
/* Bug No 2482305 Start */
--                p_parameter_autoinc_rule => 'Y',
		  p_parameter_autoinc_rule => 'N',
/* Bug No 2482305 End */
		  p_currency_code => nvl(l_currency_code, l_func_currency),
		  p_start_date => greatest(l_year_start_date, l_effective_start_date),
		  p_end_date => least(l_year_end_date, nvl(l_effective_end_date, l_year_end_date)),
		  p_recalculate_flag => TRUE);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end;
	end if;

      end;
      end if;

    end loop;

  end;
  else
  begin

    /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Revise_Position_Projections',
    'Before call - Process_PosParam_Detailed for parameter:'||p_parameter_id);
   fnd_file.put_line(fnd_file.LOG,'Before call - Process_PosParam_Detailed for parameter:'||p_parameter_id);
   end if;
   /*end bug:5753424:end statement level log*/

    -- Process all the non-Autoincrement rules
    Process_PosParam_Detailed
	   (p_return_status => l_return_status,
	    p_event_type => 'BP',
	    p_local_parameter => 'Y',
     /*Bug:6133032:passed l_worksheet_id for parameter p_worksheet_id */
	    p_worksheet_id => nvl(l_worksheet_id,p_worksheet_id),
	    p_global_worksheet_id => l_global_worksheet_id,
	    p_global_worksheet => l_global_worksheet,
	    p_data_extract_id => l_data_extract_id,
	    p_business_group_id => l_business_group_id,
	    p_parameter_id => p_parameter_id,
	    p_parameter_start_date => l_effective_start_date,
	    p_compound_annually => l_compound_annually,
/* Bug No 2482305 Start */
--           p_parameter_autoinc_rule => 'N',
	    p_parameter_autoinc_rule => 'Y',
/* Bug No 2482305 End */
	    p_currency_code => nvl(l_currency_code, l_func_currency),
	    p_start_date => greatest(PSB_WS_ACCT1.g_startdate_cy, l_effective_start_date),
	    p_end_date => least(PSB_WS_ACCT1.g_end_est_date, nvl(l_effective_end_date, PSB_WS_ACCT1.g_end_est_date)),
	    p_recalculate_flag => TRUE);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  g_note_parameter_name := null;
   fnd_file.put_line(fnd_file.LOG,'deleting records from g_pos_assign_tbl');--bug:6626807
   g_pos_assign_tbl.delete;--bug:6626807

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

    /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Revise_Position_Projections',
    'END Revise_Position_Projections');
   fnd_file.put_line(fnd_file.LOG,'END Revise_Position_Projections');
   end if;
   /*end bug:5753424:end procedure level log*/

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data => x_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data => x_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data => x_msg_data);

END Revise_Position_Projections;

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Position_Parameters
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_global_worksheet    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_group_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_data_extract_id     IN   NUMBER := FND_API.G_MISS_NUM,
  p_business_group_id   IN   NUMBER := FND_API.G_MISS_NUM,
  p_func_currency       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_calendar_id  IN   NUMBER := FND_API.G_MISS_NUM,
  p_parameter_set_id    IN   NUMBER := FND_API.G_MISS_NUM
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Apply_Position_Parameters';
  l_api_version         CONSTANT NUMBER         := 1.0;

  l_global_worksheet    VARCHAR2(1);
  l_budget_group_id     NUMBER;
  l_data_extract_id     NUMBER;
  l_budget_calendar_id  NUMBER;
  l_parameter_set_id    NUMBER;

  l_business_group_id   NUMBER;
  l_func_currency       VARCHAR2(10);

  l_compound_annually   VARCHAR2(1);
  l_compound_factor     NUMBER;

  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_return_status       VARCHAR2(1);

  cursor c_WS is
    select global_worksheet_flag,
	   budget_group_id,
	   nvl(data_extract_id, global_data_extract_id) data_extract_id,
	   budget_calendar_id,
	   nvl(parameter_set_id, global_parameter_set_id) parameter_set_id
      from PSB_WORKSHEETS_V
     where worksheet_id = p_worksheet_id;

  cursor c_BG is
    select nvl(business_group_id, root_business_group_id) business_group_id,
	   nvl(currency_code, root_currency_code) currency_code
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = l_budget_group_id;

  cursor c_Parameter (Year_Start_Date DATE,
		      Year_End_Date DATE) is
    select parameter_id,
	   name,
	   parameter_compound_annually,
	   currency_code,
	   effective_start_date,
	   effective_end_date
      from PSB_PARAMETER_ASSIGNMENTS_V
     where parameter_autoinc_rule = 'N'
       and data_extract_id = l_data_extract_id
       and parameter_type = 'POSITION'
       and (((effective_start_date <= Year_End_Date)
	 and (effective_end_date is null))
	 or ((effective_start_date between Year_Start_Date and Year_End_Date)
	  or (effective_end_date between Year_Start_Date and Year_End_Date)
	 or ((effective_start_date < Year_Start_Date)
	 and (effective_end_date > Year_End_Date))))
       and parameter_set_id = l_parameter_set_id
     order by effective_start_date,
	      priority;

  cursor c_ParamAutoInc (Start_Date DATE,
			 End_Date DATE) is
    select parameter_id,
	   name,
	   parameter_compound_annually,
	   currency_code,
	   effective_start_date,
	   effective_end_date
      from PSB_PARAMETER_ASSIGNMENTS_V
     where parameter_autoinc_rule = 'Y'
       and data_extract_id = l_data_extract_id
       and parameter_type = 'POSITION'
       and (((effective_start_date <= End_Date)
	 and (effective_end_date is null))
	 or ((effective_start_date between Start_Date and End_Date)
	  or (effective_end_date between Start_Date and End_Date)
	 or ((effective_start_date < Start_Date)
	 and (effective_end_date > End_Date))))
       and parameter_set_id = l_parameter_set_id
     order by effective_start_date,
	      priority;

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  /* start bug 4104890*/
  FND_PROFILE.GET('PSB_AUTOINC_COST_CALPERIOD', g_autoinc_period_profile);
  /* end bug 4104890*/

  if ((p_global_worksheet = FND_API.G_MISS_CHAR) or
      (p_budget_group_id = FND_API.G_MISS_NUM) or
      (p_data_extract_id = FND_API.G_MISS_NUM) or
      (p_budget_calendar_id = FND_API.G_MISS_NUM) or
      (p_parameter_set_id = FND_API.G_MISS_NUM)) then
  begin

    for c_WS_Rec in c_WS loop
      l_global_worksheet := c_WS_Rec.global_worksheet_flag;
      l_budget_group_id := c_WS_Rec.budget_group_id;
      l_data_extract_id := c_WS_Rec.data_extract_id;
      l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
      l_parameter_set_id := c_WS_Rec.parameter_set_id;
    end loop;

  end;
  end if;

  /* start bug 4104890 */
  IF (p_budget_calendar_id = FND_API.G_MISS_NUM) THEN
    g_budget_calendar_id := l_budget_calendar_id;
  ELSE
    g_budget_calendar_id := p_budget_calendar_id;
  END IF;
  /* end bug 4104890 */


  if ((l_global_worksheet is null) or (l_global_worksheet = 'N')) then
    l_global_worksheet := FND_API.G_FALSE;
  else
    l_global_worksheet := FND_API.G_TRUE;
  end if;

  if p_global_worksheet <> FND_API.G_MISS_CHAR then
    l_global_worksheet := p_global_worksheet;
  end if;

  if p_budget_group_id <> FND_API.G_MISS_NUM then
    l_budget_group_id := p_budget_group_id;
  end if;

  if p_data_extract_id <> FND_API.G_MISS_NUM then
    l_data_extract_id := p_data_extract_id;
  end if;

  if p_budget_calendar_id <> FND_API.G_MISS_NUM then
    l_budget_calendar_id := p_budget_calendar_id;
  end if;

  if p_parameter_set_id <> FND_API.G_MISS_NUM then
    l_parameter_set_id := p_parameter_set_id;
  end if;

  if ((p_business_group_id = FND_API.G_MISS_NUM) or
      (p_func_currency = FND_API.G_MISS_CHAR)) then
  begin

    for c_BG_Rec in c_BG loop
      l_business_group_id := c_BG_Rec.business_group_id;
      l_func_currency := c_BG_Rec.currency_code;
    end loop;

  end;
  end if;

  if p_business_group_id <> FND_API.G_MISS_NUM then
    l_business_group_id := p_business_group_id;
  end if;

  if p_func_currency <> FND_API.G_MISS_CHAR then
    l_func_currency := p_func_currency;
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

  for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

    if PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP') then
    begin

      for c_Parameter_Rec in c_Parameter (PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
					  PSB_WS_ACCT1.g_budget_years(l_year_index).end_date) loop

	if ((c_Parameter_Rec.parameter_compound_annually is null) or
	    (c_Parameter_Rec.parameter_compound_annually = 'N')) then
	  l_compound_annually := FND_API.G_FALSE;
        /*bug:7007854:start*/
          l_compound_factor := null;
        /*bug:7007854:end*/
	else
	  l_compound_annually := FND_API.G_TRUE;
	  l_compound_factor := greatest(ceil(months_between(PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
							    c_Parameter_Rec.effective_start_date) / 12), 0) + 1;
	end if;

	Process_PosParam_Detailed
	       (p_return_status => l_return_status,
		p_event_type => 'BP',
		p_local_parameter => 'N',
		p_worksheet_id => p_worksheet_id,
		p_global_worksheet_id => p_worksheet_id,
		p_global_worksheet => l_global_worksheet,
		p_data_extract_id => l_data_extract_id,
		p_business_group_id => l_business_group_id,
		p_parameter_id => c_Parameter_Rec.parameter_id,
		p_parameter_start_date => c_Parameter_Rec.effective_start_date,
		p_compound_annually => l_compound_annually,
		p_compound_factor => l_compound_factor,
		p_parameter_autoinc_rule => 'N',
		p_currency_code => nvl(c_Parameter_Rec.currency_code, l_func_currency),
		p_start_date => greatest(PSB_WS_ACCT1.g_budget_years(l_year_index).start_date, c_Parameter_Rec.effective_start_date),
		p_end_date => least(PSB_WS_ACCT1.g_budget_years(l_year_index).end_date,
				nvl(c_Parameter_Rec.effective_end_date, PSB_WS_ACCT1.g_budget_years(l_year_index).end_date)));

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end loop;

    end;
    end if;

  end loop;

  -- Process all the Autoincrement rules

  for c_Parameter_Rec in c_ParamAutoInc (PSB_WS_ACCT1.g_startdate_cy,
					 PSB_WS_ACCT1.g_end_est_date) loop

    if ((c_Parameter_Rec.parameter_compound_annually is null) or
	(c_Parameter_Rec.parameter_compound_annually = 'N')) then
      l_compound_annually := FND_API.G_FALSE;
    else
      l_compound_annually := FND_API.G_TRUE;
    end if;

    Process_PosParam_Detailed
	   (p_return_status => l_return_status,
	    p_event_type => 'BP',
	    p_local_parameter => 'N',
	    p_worksheet_id => p_worksheet_id,
	    p_global_worksheet_id => p_worksheet_id,
	    p_global_worksheet => l_global_worksheet,
	    p_data_extract_id => l_data_extract_id,
	    p_business_group_id => l_business_group_id,
	    p_parameter_id => c_Parameter_Rec.parameter_id,
	    p_parameter_start_date => c_Parameter_Rec.effective_start_date,
	    p_compound_annually => l_compound_annually,
	    p_parameter_autoinc_rule => 'Y',
	    p_currency_code => nvl(c_Parameter_Rec.currency_code, l_func_currency),
	    p_start_date => greatest(PSB_WS_ACCT1.g_startdate_cy, c_Parameter_Rec.effective_start_date),
	    p_end_date => least(PSB_WS_ACCT1.g_end_est_date, nvl(c_Parameter_Rec.effective_end_date, PSB_WS_ACCT1.g_end_est_date)));

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end loop;

    fnd_file.put_line(fnd_file.LOG,'deleting records from g_pos_assign_tbl');--bug:6626807
    g_pos_assign_tbl.delete;--bug:6626807

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

END Apply_Position_Parameters;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_PosParam_Detailed
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_event_type              IN   VARCHAR2,
  p_local_parameter         IN   VARCHAR2,
  p_global_worksheet_id     IN   NUMBER,
  p_worksheet_id            IN   NUMBER,
  p_global_worksheet        IN   VARCHAR2,
  p_data_extract_id         IN   NUMBER,
  p_business_group_id       IN   NUMBER,
  p_parameter_id            IN   NUMBER,
  p_parameter_start_date    IN   DATE,
  p_compound_annually       IN   VARCHAR2,
  p_compound_factor         IN   NUMBER := FND_API.G_MISS_NUM,
  p_parameter_autoinc_rule  IN   VARCHAR2,
  p_currency_code           IN   VARCHAR2,
  p_start_date              IN   DATE,
  p_end_date                IN   DATE,
  p_recalculate_flag        IN   BOOLEAN := FALSE
) IS

  l_root_budget_group_id    NUMBER;
  l_set_of_books_id         NUMBER;
  l_flex_code               NUMBER;
  l_position_line_id        NUMBER;

  l_num_positions           NUMBER := 0;
  l_return_status           VARCHAR2(1);

  l_api_name          CONSTANT VARCHAR2(30)     := 'Process_PosParam_Detailed';

/* Bug No 2594596 Start */
  l_compound_factor             NUMBER;
/* Bug No 2594596 End */

/* Bug No 1808330 Start */
  l_position_id                 NUMBER(20);
  l_budget_revision_pos_line_id NUMBER(20);
  l_note                        VARCHAR2(4000); -- Bug#4571412

  l_msg_data                    VARCHAR2(2000);
  l_msg_count                   NUMBER;

 /*bug:6133032:start*/
  l_worksheet_id                NUMBER;
  l_local_copy_flag             VARCHAR2(1) := 'N';
 /*bug:6133032:end*/

 l_process_position           BOOLEAN; --bug:8935662

  cursor c_BR_positions is
    select a.budget_revision_pos_line_id
      from PSB_BUDGET_REVISION_POSITIONS a,
	   PSB_BUDGET_REVISION_POS_LINES b
     where b.budget_revision_id = p_worksheet_id
       and a.position_id = l_position_id
       and a.budget_revision_pos_line_id = b.budget_revision_pos_line_id;
/* Bug No 1808330 End */

  cursor c_Positions is
    select a.position_id,
	   c.name,
	   c.new_position_flag --bug:6374881
      from PSB_BUDGET_POSITIONS a,
	   PSB_SET_RELATIONS b,
	   PSB_POSITIONS c
     where a.data_extract_id = p_data_extract_id
       and a.account_position_set_id = b.account_position_set_id
       and b.parameter_id = p_parameter_id
       and c.position_id = a.position_id;

  cursor c_BG is
    select nvl(b.root_budget_group_id, b.budget_group_id) root_budget_group_id,
	   nvl(b.set_of_books_id, b.root_set_of_books_id) set_of_books_id
      from PSB_WORKSHEETS_V a,
	   PSB_BUDGET_GROUPS_V b
     where a.worksheet_id = p_worksheet_id
       and b.budget_group_id = a.budget_group_id;

  cursor c_SOB is
    select chart_of_accounts_id
      from GL_SETS_OF_BOOKS
     where set_of_books_id = l_set_of_books_id;

  cursor c_ParamName is
    select name from PSB_ENTITY where entity_id = p_parameter_id;

 /*bug:6626807:start*/

    l_pos_assign_count  NUMBER :=0;
    l_pos_found         BOOLEAN := FALSE;

    cursor c_Pos_Assign_csr(p_position_id NUMBER) is
    select a.position_id,
           a.pay_element_id,  --bug:8566969
           a.pay_element_option_id,
	   a.effective_start_date,
	   a.effective_end_date,
	   a.element_value_type,
	   a.element_value,
	   a.pay_basis
      from PSB_POSITION_ASSIGNMENTS a,
           PSB_PAY_ELEMENTS ppe
     where a.currency_code = p_currency_code
       and ppe.pay_element_id = a.pay_element_id
       and ppe.data_extract_id = p_data_extract_id
       and a.assignment_type = 'ELEMENT'
       and a.position_id = p_position_id
       and (a.worksheet_id = p_worksheet_id or (a.worksheet_id is null
       and not exists
      (select 1
         from psb_position_assignments ppa1
        where ppa1.pay_element_id = a.pay_element_id
          and ppa1.position_id = p_position_id
          and ppa1.worksheet_id = p_worksheet_id
          and (((ppa1.effective_start_date between
                a.effective_start_date and nvl(a.effective_end_date,ppa1.effective_start_date)) OR
               (ppa1.effective_end_date between
                a.effective_start_date and nvl(a.effective_end_date,ppa1.effective_end_date)) OR
                (ppa1.effective_start_date <= nvl(a.effective_end_date,a.effective_start_date) AND
                 (ppa1.effective_end_date IS NULL OR ppa1.effective_end_date > a.effective_end_date)))))))
     order by a.effective_start_date;
 /*bug:6626807:end*/

BEGIN

   /*Bug:5924932:start*/
    g_event_type  := p_event_type;
  /*Bug:5924932:end*/

    /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam_Detailed',
    'BEGIN Process_PosParam_Detailed');
     fnd_file.put_line(fnd_file.LOG,'BEGIN Process_PosParam_Detailed');
   end if;
   /*end bug:5753424:end procedure level log*/

  if p_recalculate_flag then
  begin

    for c_BG_Rec in c_BG loop
      l_root_budget_group_id := c_BG_Rec.root_budget_group_id;
      l_set_of_books_id := c_BG_Rec.set_of_books_id;
    end loop;

    for c_SOB_Rec in c_SOB loop
      l_flex_code := c_SOB_Rec.chart_of_accounts_id;
      g_flex_code := l_flex_code ; -- Bug#4675858
    end loop;

  end;
  end if;

   /*Bug:6133032:start*/
     if FND_API.to_Boolean(p_global_worksheet) then
       l_worksheet_id := p_worksheet_id;
     else
       for l_ws_rec in (select * from psb_worksheets
                         where worksheet_id = p_worksheet_id) loop
         l_local_copy_flag := l_ws_rec.local_copy_flag;
       end loop;

       IF l_local_copy_flag IS NULL THEN
          l_worksheet_id := p_global_worksheet_id;
       ELSIF l_local_copy_flag = 'Y' THEN
          l_worksheet_id := p_worksheet_id;
       END IF;

     end if;
   /*Bug:6133032:end*/

/* Bug No 2594596 Start */
  if p_compound_factor <> FND_API.G_MISS_NUM then
    l_compound_factor := p_compound_factor;
  else
    l_compound_factor := 1;
  end if;
/* Bug No 2594596 End */

  for c_Positions_Rec in c_Positions loop

    if ((p_local_parameter = 'N') or ((p_local_parameter = 'Y') and Position_Exists(p_event_type, p_worksheet_id, c_Positions_Rec.position_id))) then
    begin

    /*bug:6626807:start*/
    l_pos_assign_count := g_pos_assign_tbl.count;
    l_pos_found := FALSE;

    for i in 1..g_pos_assign_tbl.count loop
        if g_pos_assign_tbl(i).position_id = c_Positions_Rec.position_id then
	  l_pos_found := TRUE;
	end if;
    end loop;
   IF NOT l_pos_found THEN
    FOR l_pos_assign_rec IN c_Pos_Assign_csr(c_Positions_Rec.position_id) LOOP
      l_pos_assign_count := l_pos_assign_count + 1;
      g_pos_assign_tbl(l_pos_assign_count).position_id := l_pos_assign_rec.position_id;
      g_pos_assign_tbl(l_pos_assign_count).pay_element_id := l_pos_assign_rec.pay_element_id;  --bug:8566969
      g_pos_assign_tbl(l_pos_assign_count).pay_element_option_id := l_pos_assign_rec.pay_element_option_id;
      g_pos_assign_tbl(l_pos_assign_count).effective_start_date := l_pos_assign_rec.effective_start_date;
      g_pos_assign_tbl(l_pos_assign_count).effective_end_date := l_pos_assign_rec.effective_end_date;
      g_pos_assign_tbl(l_pos_assign_count).element_value_type := l_pos_assign_rec.element_value_type;
      g_pos_assign_tbl(l_pos_assign_count).element_value := l_pos_assign_rec.element_value;
      g_pos_assign_tbl(l_pos_assign_count).pay_basis := l_pos_assign_rec.pay_basis;
    END LOOP;
   END IF;
    /*bug:6626807:end*/

	/*bug:8935662:start*/
	l_process_position := FALSE;

      if ((not g_pos_sal_dist_flag.EXISTS(c_Positions_Rec.position_id)) OR
        g_pos_sal_dist_flag(c_Positions_Rec.position_id) = 'Y') then

        PSB_WS_POS1.g_salary_budget_group_id := NULL;
    /*bug:8935662:end*/

	PSB_WS_POS1.Cache_Salary_Dist
	   (p_return_status => l_return_status,
        /*Bug:6133032:passed l_worksheet_id for parameter p_worksheet_id */
	    p_worksheet_id => NVL(l_worksheet_id,p_global_worksheet_id),
	    p_root_budget_group_id => l_root_budget_group_id,
	    p_flex_code => l_flex_code,
	    p_data_extract_id => p_data_extract_id,
	    p_position_id => c_Positions_Rec.position_id,
	    p_position_name => c_Positions_Rec.name,
	    p_start_date => PSB_WS_ACCT1.g_startdate_cy,
	    p_end_date => PSB_WS_ACCT1.g_end_est_date);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	   g_pos_sal_dist_flag(c_Positions_Rec.position_id) := 'N';--bug:8935662
	elsif l_return_status = FND_API.G_RET_STS_SUCCESS then
	   g_pos_sal_dist_flag(c_Positions_Rec.position_id) := 'Y';--bug:8935662
	end if;

       end if;

       if g_pos_sal_dist_flag(c_Positions_Rec.position_id) = 'Y' then
         l_process_position := TRUE;
       else
         l_process_position := FALSE;
       end if;

  if l_process_position then
   /*bug:8935662:end*/

      if p_local_parameter = 'Y' then
      begin

	for c_ParamName_Rec in c_ParamName loop
	  g_note_parameter_name := c_ParamName_Rec.name;
	end loop;

/* Bug No 1808330 Start */
	if p_event_type = 'BR' then
	   l_position_id := c_Positions_Rec.position_id;

	   for c_BR_positions_rec in c_BR_positions loop
		l_budget_revision_pos_line_id := c_BR_positions_rec.budget_revision_pos_line_id;
	   end loop;

---- Create Note Id and Inserts a record in PSB_WS_ACCOUNT_LINE_NOTES table

	   FND_MESSAGE.SET_NAME('PSB', 'PSB_PARAMETER_NOTE_CREATION');
	   FND_MESSAGE.SET_TOKEN('NAME', g_note_parameter_name);
	   FND_MESSAGE.SET_TOKEN('DATE', sysdate);
	   l_note := FND_MESSAGE.GET;

	   PSB_BUDGET_REVISIONS_PVT.Create_Note
	   ( p_return_status    => l_return_status
           , p_account_line_id  => NULL
           , p_position_line_id => l_budget_revision_pos_line_id
           , p_note             => l_note
           , p_flex_code        => g_flex_code -- Bug#4675858
	   , p_cc_id            => NULL        -- Bug#4675858
           ) ;

	   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	   end if;
       end if;
----
/* Bug No 1808330 End */

      end;
      end if;

      if ((p_parameter_autoinc_rule is null) or (p_parameter_autoinc_rule = 'N')) then
      begin

/* Bug No 2594596 Start */
-- input parameter changed from p_compound_factor to l_compound_factor

    /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam_Detailed',
    'Before call to Process_PosParam for parameter:'||p_parameter_id);
     fnd_file.put_line(fnd_file.LOG,'Before call to Process_PosParam for parameter:'||p_parameter_id);
   end if;
   /*end bug:5753424:end statement level log*/

	Process_PosParam
	       (p_return_status => l_return_status,
                x_msg_data      => l_msg_data,
                x_msg_count     => l_msg_count,
		p_worksheet_id => p_worksheet_id,
   /*Bug:6133032:passed l_worksheet_id for p_global_worksheet_id*/
		p_global_worksheet_id => nvl(l_worksheet_id,p_global_worksheet_id),
		p_data_extract_id => p_data_extract_id,
		p_position_id => c_Positions_Rec.position_id,
		p_parameter_id => p_parameter_id,
		p_currency_code => p_currency_code,
		p_start_date => p_start_date,
		p_end_date => p_end_date,
		p_compound_annually => p_compound_annually,
		p_compound_factor => l_compound_factor);

/* Bug No 2594596 End */
	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      else
      begin

	/*if FND_API.to_Boolean(p_global_worksheet) then
	begin*/ --commented for bug:6133032

    /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam_Detailed',
    'Before call to Process_PosParam_AutoInc for parameter:'||p_parameter_id);
     fnd_file.put_line(fnd_file.LOG,'Before call to Process_PosParam_AutoInc for parameter:'||p_parameter_id);
   end if;
   /*end bug:5753424:end statement level log*/

	  Process_PosParam_AutoInc
		 (p_return_status => l_return_status,
                  x_msg_data      => l_msg_data,
                  x_msg_count     => l_msg_count,
          /*Bug:6133032:passed l_worksheet_id for the param: p_worksheet_id */
		  p_worksheet_id => nvl(l_worksheet_id,p_worksheet_id),
		  p_data_extract_id => p_data_extract_id,
		  p_business_group_id => p_business_group_id,
		  p_position_id => c_Positions_Rec.position_id,
		  p_parameter_id => p_parameter_id,
		  p_parameter_start_date => p_parameter_start_date,
		  p_currency_code => p_currency_code,
		  p_start_date => p_start_date,
		  p_end_date => p_end_date);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	/*end;
	end if;*/--commented for bug:6133032

      end;
      end if;

      if p_recalculate_flag then
      begin

	PSB_WS_POS1.g_salary_budget_group_id := null;

	PSB_WS_POS1.Create_Position_Lines
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_position_line_id => l_position_line_id,
        /*Bug:6133032:passed l_worksheet_id for parameter p_worksheet_id */
            p_worksheet_id => nvl(l_worksheet_id,p_worksheet_id),
	    p_position_id => c_Positions_Rec.position_id,
	    p_budget_group_id => PSB_WS_POS1.g_salary_budget_group_id);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

	PSB_WS_POS2.Calculate_Position_Cost
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
        /*Bug:6133032:passed l_worksheet_id for parameter p_worksheet_id */
	    p_worksheet_id => nvl(l_worksheet_id,p_worksheet_id),
	/*Bug:6133032:passed l_worksheet_id for parameter p_global_worksheet_id */
	    p_global_worksheet_id => nvl(l_worksheet_id,p_worksheet_id),
	    p_position_line_id => l_position_line_id,
        /*Start bug:5635570*/
            p_lparam_flag => FND_API.G_TRUE
       /*End bug:5635570*/
	    );

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

      l_num_positions := l_num_positions + 1;

      if l_num_positions > PSB_WS_ACCT1.g_checkpoint_save then
	commit work;
	l_num_positions := 0;
      end if;

    /*bug:8935662:start*/
     end if;
    /*bug:8935662:end*/

    end;
    end if;

  end loop;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

    /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam_Detailed',
    'END Process_PosParam_Detailed');
     fnd_file.put_line(fnd_file.LOG,'END Process_PosParam_Detailed');
   end if;
   /*end bug:5753424:end procedure level log*/

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

END Process_PosParam_Detailed;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_PosParam
( p_return_status        OUT  NOCOPY  VARCHAR2,
  x_msg_data             OUT  NOCOPY  VARCHAR2,
  x_msg_count            OUT  NOCOPY  NUMBER,
  p_worksheet_id         IN   NUMBER,
  p_global_worksheet_id  IN   NUMBER,
  p_data_extract_id      IN   NUMBER,
  p_position_id          IN   NUMBER,
  p_parameter_id         IN   NUMBER,
  p_currency_code        IN   VARCHAR2,
  p_start_date           IN   DATE,
  p_end_date             IN   DATE,
  p_compound_annually    IN   VARCHAR2,
  p_compound_factor      IN   NUMBER
) IS

  l_element_value_type  VARCHAR2(2);
  l_element_value       NUMBER;

  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  l_posasgn_id          NUMBER;
  l_rowid               VARCHAR2(100);

  l_start_date          DATE;
  l_end_date            DATE;

  l_return_status       VARCHAR2(1);

  l_api_name          CONSTANT VARCHAR2(30)     := 'Process_PosParam';

  cursor c_Formula is
    select assignment_type,
	   attribute_id,
	   attribute_value,
	   pay_element_id,
	   pay_element_option_id,
	   element_value_type,
	   element_value,
	   effective_start_date,
	   effective_end_date
      from PSB_PARAMETER_FORMULAS
     where parameter_id = p_parameter_id
     order by step_number;

BEGIN

   /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam',
    'BEGIN Process_PosParam');
   fnd_file.put_line(fnd_file.LOG,'BEGIN Process_PosParam');
   end if;
   /*end bug:5753424:end procedure level log*/

  for c_Formula_Rec in c_Formula loop

    l_start_date := greatest(nvl(c_Formula_Rec.effective_start_date, p_start_date), p_start_date);
    l_end_date := least(nvl(c_Formula_Rec.effective_end_date, p_end_date), p_end_date);

    if ((l_start_date <= l_end_date) and
       ((l_start_date between p_start_date and p_end_date) or
	(l_end_date between p_start_date and p_end_date))) then
    begin

      if c_Formula_Rec.assignment_type = 'ELEMENT' then
      begin

	if c_Formula_Rec.element_value_type = 'PI' then
	begin

    /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam',
    'Before call to Process_PosParam_PI for position:'||p_position_id||' and element id:'||c_Formula_Rec.pay_element_id);
   fnd_file.put_line(fnd_file.LOG,'Before call to Process_PosParam_PI for position:'||p_position_id||' and element id:'||c_Formula_Rec.pay_element_id);
   end if;
   /*end bug:5753424:end statement level log*/

          /*Bug:8235347:start*/
           IF (NVL(g_parameter_id,0) <> p_parameter_id OR NVL(g_start_date,trunc(sysdate)) <> p_start_date) THEN
             g_del_latest_ws_details := TRUE;
             g_parameter_id := p_parameter_id;
             g_start_date   := p_start_date;
           ELSE
             g_del_latest_ws_details := FALSE;
           END IF;

          /*Bug:8235347:end*/

	  Process_PosParam_PI
		 (p_return_status => l_return_status,
		  p_worksheet_id => p_worksheet_id,
		  p_global_worksheet_id => p_global_worksheet_id,
		  p_data_extract_id => p_data_extract_id,
		  p_position_id => p_position_id,
		  p_currency_code => p_currency_code,
		  p_start_date => l_start_date,
		  p_end_date => l_end_date,
		  p_compound_annually => p_compound_annually,
		  p_compound_factor => p_compound_factor,
		  p_pay_element_id => c_Formula_Rec.pay_element_id,
		  p_pay_element_option_id => c_Formula_Rec.pay_element_option_id,
		  p_element_value => c_Formula_Rec.element_value);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end;
	elsif c_Formula_Rec.element_value_type = 'PS' then
	begin

	  if FND_API.to_Boolean(p_compound_annually) then
	  begin

            -- Bug 3786457 commented the following
            /* if c_Formula_Rec.element_value < 1 then
                 l_element_value := c_Formula_Rec.element_value * POWER(1 + c_Formula_Rec.element_value, p_compound_factor);
               else
                 l_element_value := c_Formula_Rec.element_value * POWER(1 + c_Formula_Rec.element_value / 100, p_compound_factor);
               end if; */
               l_element_value
                := c_Formula_Rec.element_value * POWER(1 + c_Formula_Rec.element_value / 100, p_compound_factor);
            /* Bug 3786457 End */

	  end;
	  else
	    l_element_value := c_Formula_Rec.element_value;
	  end if;

	  l_element_value_type := c_Formula_Rec.element_value_type;

    /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam',
    'Before call to PSB_POSITIONS_PVT.Modify_Assignment for position:'||p_position_id||' and element id:'||c_Formula_Rec.pay_element_id);
   fnd_file.put_line(fnd_file.LOG,'Before call to PSB_POSITIONS_PVT.Modify_Assignment for position:'||p_position_id||' and element id:'||c_Formula_Rec.pay_element_id);
   end if;
   /*end bug:5753424:end statement level log*/

	  PSB_POSITIONS_PVT.Modify_Assignment
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_position_assignment_id => l_posasgn_id,
	      p_data_extract_id => p_data_extract_id,
	      p_worksheet_id => p_global_worksheet_id,
	      p_position_id => p_position_id,
	      p_assignment_type => c_Formula_Rec.assignment_type,
	      p_attribute_id => null,
	      p_attribute_value_id => null,
	      p_attribute_value => null,
	      p_pay_element_id => c_Formula_Rec.pay_element_id,
	      p_pay_element_option_id => c_Formula_Rec.pay_element_option_id,
	      p_effective_start_date => l_start_date,
	      p_effective_end_date => l_end_date,
	      p_element_value_type => l_element_value_type,
	      p_element_value => l_element_value,
	      p_currency_code => p_currency_code,
	      p_pay_basis => null,
	      p_global_default_flag => null,
	      p_assignment_default_rule_id => null,
	      p_modify_flag => null,
	      p_rowid => l_rowid,
	      p_employee_id => null,
	      p_primary_employee_flag => null);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end;
	else
	begin

	  l_element_value := c_Formula_Rec.element_value;
	  l_element_value_type := c_Formula_Rec.element_value_type;

    /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam',
    'Before call to PSB_POSITIONS_PVT.Modify_Assignment for position:'||p_position_id||' and element id:'||c_Formula_Rec.pay_element_id);
   fnd_file.put_line(fnd_file.LOG,'Before call to PSB_POSITIONS_PVT.Modify_Assignment for position:'||p_position_id||' and element id:'||c_Formula_Rec.pay_element_id);
   end if;
   /*end bug:5753424:end statement level log*/

	  PSB_POSITIONS_PVT.Modify_Assignment
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_position_assignment_id => l_posasgn_id,
	      p_data_extract_id => p_data_extract_id,
	      p_worksheet_id => p_global_worksheet_id,
	      p_position_id => p_position_id,
	      p_assignment_type => c_Formula_Rec.assignment_type,
	      p_attribute_id => null,
	      p_attribute_value_id => null,
	      p_attribute_value => null,
	      p_pay_element_id => c_Formula_Rec.pay_element_id,
	      p_pay_element_option_id => c_Formula_Rec.pay_element_option_id,
	      p_effective_start_date => l_start_date,
	      p_effective_end_date => l_end_date,
	      p_element_value_type => l_element_value_type,
	      p_element_value => l_element_value,
	      p_currency_code => p_currency_code,
	      p_pay_basis => null,
	      p_global_default_flag => null,
	      p_assignment_default_rule_id => null,
	      p_modify_flag => null,
	      p_rowid => l_rowid,
	      p_employee_id => null,
	      p_primary_employee_flag => null);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end;
	end if;

      end;
      elsif c_Formula_Rec.assignment_type = 'ATTRIBUTE' then
      begin

    /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam',
    'Before call to PSB_POSITIONS_PVT.Modify_Assignment for assign type ATTRIBUTE and position:'||p_position_id||' and p_attribute_id:'||c_Formula_Rec.attribute_id);
   fnd_file.put_line(fnd_file.LOG,'Before call to PSB_POSITIONS_PVT.Modify_Assignment for assign type ATTRIBUTE and position:'||p_position_id||' and p_attribute_id:'||c_Formula_Rec.attribute_id);
   end if;
   /*end bug:5753424:end statement level log*/

	PSB_POSITIONS_PVT.Modify_Assignment
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_position_assignment_id => l_posasgn_id,
	    p_data_extract_id => p_data_extract_id,
	    p_worksheet_id => p_global_worksheet_id,
	    p_position_id => p_position_id,
	    p_assignment_type => c_Formula_Rec.assignment_type,
	    p_attribute_id => c_Formula_Rec.attribute_id,
	    p_attribute_value_id => null,
	    p_attribute_value => c_Formula_Rec.attribute_value,
	    p_pay_element_id => null,
	    p_pay_element_option_id => null,
	    p_effective_start_date => l_start_date,
	    p_effective_end_date => l_end_date,
	    p_element_value_type => null,
	    p_element_value => null,
	    p_currency_code => null,
	    p_pay_basis => null,
	    p_global_default_flag => null,
	    p_assignment_default_rule_id => null,
	    p_modify_flag => null,
	    p_rowid => l_rowid,
	    p_employee_id => null,
	    p_primary_employee_flag => null);

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

    /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam',
    'END Process_PosParam');
   fnd_file.put_line(fnd_file.LOG,'END Process_PosParam');
   end if;
   /*end bug:5753424:end procedure level log*/

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data => x_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data => x_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Process_PosParam;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_PosParam_PI
( p_return_status          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id           IN   NUMBER,
  p_global_worksheet_id    IN   NUMBER,
  p_data_extract_id        IN   NUMBER,
  p_position_id            IN   NUMBER,
  p_currency_code          IN   VARCHAR2,
  p_start_date             IN   DATE,
  p_end_date               IN   DATE,
  p_compound_annually      IN   VARCHAR2,
  p_compound_factor        IN   NUMBER,
  p_pay_element_id         IN   NUMBER,
  p_pay_element_option_id  IN   NUMBER,
  p_element_value          IN   NUMBER
) IS

  l_element_value          NUMBER;

  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);

  l_posasgn_id             NUMBER;
  l_rowid                  VARCHAR2(100);

  l_return_status          VARCHAR2(1);
  /*Bug:5924932:start*/
  l_elem_value             NUMBER;
  l_pay_element_option_id  NUMBER;
  /*Bug:5924932:end*/

  /*Bug:6626807:modified the cursor c_Elem to make sure that cursor first looks for Worksheet level
    records. If worksheet level records are not available then cursor picks DE level
    records*/
  cursor c_Elem is
    select a.worksheet_id,
           a.pay_element_option_id,
	   a.effective_start_date,
	   a.effective_end_date,
	   a.element_value_type,
	   a.element_value,
	   a.pay_basis
      from PSB_POSITION_ASSIGNMENTS a,
           PSB_PAY_ELEMENTS ppe
     where a.currency_code = p_currency_code
       and ppe.pay_element_id = p_pay_element_id
       and ppe.data_extract_id = p_data_extract_id
       and ((p_pay_element_option_id is null) or (a.pay_element_option_id = p_pay_element_option_id))
       and (((a.effective_start_date <= p_end_date)
	 and (a.effective_end_date is null))
	 or ((a.effective_start_date between p_start_date and p_end_date)
	  or (a.effective_end_date between (p_start_date-1) and p_end_date)  --bug:8566969:modified p_start_date to p_start_date-1
	 or ((a.effective_start_date < p_start_date)
	 and (a.effective_end_date > p_end_date))))
       and a.pay_element_id = p_pay_element_id
       and a.assignment_type = 'ELEMENT'
       and a.position_id = p_position_id
       and (a.worksheet_id = p_worksheet_id or (a.worksheet_id is null
       and not exists
      (select 1
         from psb_position_assignments ppa1
        where ppa1.pay_element_id = a.pay_element_id
          and ppa1.position_id = p_position_id
          and ppa1.worksheet_id = p_worksheet_id
          and (((ppa1.effective_start_date between
                a.effective_start_date and nvl(a.effective_end_date,ppa1.effective_start_date)) OR
               (ppa1.effective_end_date between
                a.effective_start_date and nvl(a.effective_end_date,ppa1.effective_end_date)) OR
                (ppa1.effective_start_date <= nvl(a.effective_end_date,a.effective_start_date) AND
                 (ppa1.effective_end_date IS NULL OR ppa1.effective_end_date > a.effective_end_date)))))))
      order by a.effective_start_date desc; --bug:8566969

  cursor c_ElemRates (StartDate DATE,
		      EndDate DATE) is
    select pay_element_option_id,
	   effective_start_date,
	   effective_end_date,
	   element_value_type,
	   element_value,
	   formula_id,
	   pay_basis
      from PSB_PAY_ELEMENT_RATES
     where worksheet_id is null
       and ((p_pay_element_option_id is null) or
       (pay_element_option_id = nvl(l_pay_element_option_id, p_pay_element_option_id)))   --bug:6626807:modified
       and (((effective_start_date <= EndDate)
	 and (effective_end_date is null))
	 or ((effective_start_date between StartDate and EndDate)
	  or (effective_end_date between StartDate and EndDate)
	 or ((effective_start_date < StartDate)
	 and (effective_end_date > EndDate))))
       and pay_element_id = p_pay_element_id;

  /*Bug:6374881:start*/

  TYPE l_elem_rec_type IS RECORD
  (
      pay_element_option_id  NUMBER,
      effective_start_date   DATE,
      effective_end_date     DATE,
      element_value_type     VARCHAR2(15),
      element_value          NUMBER,
      pay_basis              VARCHAR2(15)
  );

  TYPE l_elem_rec_tab_type IS TABLE OF l_elem_rec_type INDEX BY BINARY_INTEGER;
  l_elem_rec_tab    l_elem_rec_tab_type;

   l_index                      NUMBER := 0;

 /*Bug:6374881:end*/

/*bug:6626807:start*/

  l_ws_record    BOOLEAN := FALSE;
  l_start_date   DATE;
  l_end_date     DATE;
  l_modify_assign BOOLEAN := FALSE;

  /*Bug:6626807:Cursor which picks the latest salary assignment record for a given position.
    This cursor is used in case when no record is returned by c_Elem cursor */

  cursor c_latestrec_ws IS
  select   pbp.position_id,   --bug:8235347
           a.worksheet_id,
           a.pay_element_id,
           a.pay_element_option_id,
	   a.effective_start_date,
	   a.effective_end_date,
	   a.element_value_type,
	   a.element_value,
	   a.pay_basis
      from PSB_POSITION_ASSIGNMENTS a,
           PSB_PAY_ELEMENTS ppe,
       /*Bug:8235347:start*/
           PSB_BUDGET_POSITIONS pbp,
	   PSB_SET_RELATIONS b,
	   PSB_POSITIONS c
       /*Bug:8235347:end*/
     where a.currency_code = p_currency_code
       /*Bug:8235347:start*/
       and pbp.data_extract_id = p_data_extract_id
       and pbp.account_position_set_id = b.account_position_set_id
       and b.parameter_id = g_parameter_id
       and c.position_id = pbp.position_id
       /*Bug:8235347:end*/
       and a.assignment_type = 'ELEMENT'
       and a.pay_element_id = ppe.pay_element_id
       and ppe.data_extract_id = p_data_extract_id
       and a.position_id = pbp.position_id       --Bug:8235347:modified
       and a.worksheet_id = p_worksheet_id
       and a.effective_start_date = (select max(ppa2.effective_start_date)
                                        from psb_position_assignments ppa2
                                       where ppa2.currency_code = p_currency_code
                                         and ppa2.position_id = pbp.position_id    --Bug:8235347:modified
 	                                 and ppa2.assignment_type = 'ELEMENT'
 	                                 and ppa2.pay_element_id = a.pay_element_id
                                         and ppa2.worksheet_id = p_worksheet_id);

  /*bug:6626807:end*/

  l_api_name            CONSTANT VARCHAR2(30)   := 'Process_PosParam_PI';

BEGIN

    /*start bug:8235347: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam_PI',
                    'Process_PosParam_PI::p_start_date:'||p_start_date||'  p_end_date:'||p_end_date||'  p_element_id:'||p_pay_element_id
                     ||'  p_pay_element_option_id:'||p_pay_element_option_id);
    /*fnd_file.put_line(fnd_file.LOG,'Process_PosParam_PI::p_start_date:'||p_start_date
                                   ||'  p_end_date:'||p_end_date
                                   ||'  p_element_id:'||p_pay_element_id
                                   ||'  p_pay_element_option_id:'||p_pay_element_option_id); */--bug:6626807
   end if;
   /*end bug:8235347:end statement level log*/

  /*Bug:8235347:start*/
  IF g_del_latest_ws_details THEN
    g_pos_id.delete;
    g_ws_id.delete;
    g_pay_ele_id.delete;
    g_pay_ele_option_id.delete;
    g_eff_start_date.delete;
    g_eff_end_date.delete;
    g_ele_val_type.delete;
    g_ele_value.delete;
    g_pay_basis.delete;
    g_ws_pos_dtl_tbl.delete;
    OPEN c_latestrec_ws;
    FETCH c_latestrec_ws BULK COLLECT INTO g_pos_id,g_ws_id,g_pay_ele_id,g_pay_ele_option_id,
                                           g_eff_start_date,g_eff_end_date,g_ele_val_type,g_ele_value,g_pay_basis;
    CLOSE c_latestrec_ws;

    FOR l_pos_index IN 1..g_pos_id.COUNT LOOP
      g_ws_pos_dtl_tbl(g_pos_id(l_pos_index)).worksheet_id := g_ws_id(l_pos_index);
      g_ws_pos_dtl_tbl(g_pos_id(l_pos_index)).pay_element_id := g_pay_ele_id(l_pos_index);
      g_ws_pos_dtl_tbl(g_pos_id(l_pos_index)).pay_element_option_id := g_pay_ele_option_id(l_pos_index);
      g_ws_pos_dtl_tbl(g_pos_id(l_pos_index)).effective_start_date := g_eff_start_date(l_pos_index);
      g_ws_pos_dtl_tbl(g_pos_id(l_pos_index)).effective_end_date := g_eff_end_date(l_pos_index);
      g_ws_pos_dtl_tbl(g_pos_id(l_pos_index)).element_value_type := g_ele_val_type(l_pos_index);
      g_ws_pos_dtl_tbl(g_pos_id(l_pos_index)).element_value := g_ele_value(l_pos_index);
      g_ws_pos_dtl_tbl(g_pos_id(l_pos_index)).pay_basis := g_pay_basis(l_pos_index);
    END LOOP;

  END IF;
  /*Bug:8235347:end*/

 /*Bug:6374881:start*/

 for c_Elem_Rec in c_Elem loop

  /*bug:8566969:start*/
  if ((c_Elem_Rec.effective_start_date between p_start_date and p_end_date) or
      (c_Elem_Rec.effective_end_date between p_start_date and p_end_date) or
      ((c_Elem_Rec.effective_start_date <= p_end_date) and
       (c_Elem_Rec.effective_end_date >= p_start_date or c_Elem_Rec.effective_end_date is null))) then
    /*bug:8566969:end*/

   l_index := l_index + 1;

   l_elem_rec_tab(l_index).pay_element_option_id := c_Elem_Rec.pay_element_option_id;
   l_elem_rec_tab(l_index).effective_start_date := c_Elem_Rec.effective_start_date;
   l_elem_rec_tab(l_index).effective_end_date := c_Elem_Rec.effective_end_date;
   l_elem_rec_tab(l_index).element_value_type := c_Elem_Rec.element_value_type;
   l_elem_rec_tab(l_index).element_value := c_Elem_Rec.element_value;
   l_elem_rec_tab(l_index).pay_basis := c_Elem_Rec.pay_basis;

      /*bug:8566969:start*/
  elsif c_Elem_Rec.effective_end_date IS NOT NULL AND c_Elem_Rec.effective_end_date < p_start_date AND
        l_index = 0 THEN

   l_index := l_index + 1;
   l_elem_rec_tab(l_index).pay_element_option_id := c_Elem_Rec.pay_element_option_id;
   l_elem_rec_tab(l_index).effective_start_date := c_Elem_Rec.effective_start_date;
   l_elem_rec_tab(l_index).effective_end_date := c_Elem_Rec.effective_end_date;
   l_elem_rec_tab(l_index).element_value_type := c_Elem_Rec.element_value_type;
   l_elem_rec_tab(l_index).element_value := c_Elem_Rec.element_value;
   l_elem_rec_tab(l_index).pay_basis := c_Elem_Rec.pay_basis;
  end if;
    /*bug:8566969:end*/

    /*start bug:8235347: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam_PI',
                    'l_elem_rec_tab::effective_start_date:'||c_Elem_Rec.effective_start_date||
                    ' and effective_end_date:'||c_Elem_Rec.effective_end_date||
                    ' element_value:'||c_Elem_Rec.element_value);
    /*fnd_file.put_line(fnd_file.LOG, 'l_elem_rec_tab::effective_start_date:'||c_Elem_Rec.effective_start_date||
                                    ' and effective_end_date:'||c_Elem_Rec.effective_end_date||
                                    ' element_value:'||c_Elem_Rec.element_value); */--bug:6626807
  end if;
   /*end bug:8235347:end statement level log*/

   --bug:6626807:start
     l_ws_record := TRUE;
   --bug:6626807:end
 end loop;

 /*bug:6626807:start*/
 --If Record is not found in the date range of p_start_date and p_end_date either at WS/DE levels,
 --then latest record at WS level is fetched by the cursor - c_latestrec_ws. This record is
 --used for the processing of the parameter.

 IF NOT l_ws_record THEN
   --FOR l_latestwsrec IN c_latestrec_ws LOOP
   IF g_ws_pos_dtl_tbl.exists(p_position_id) THEN           --bug:8235347:modified
     IF ((g_ws_pos_dtl_tbl(p_position_id).pay_element_id = p_pay_element_id AND
        (p_pay_element_option_id IS NULL OR p_pay_element_option_id=g_ws_pos_dtl_tbl(p_position_id).pay_element_option_id) AND
        (g_ws_pos_dtl_tbl(p_position_id).effective_end_date IS NOT NULL AND (g_ws_pos_dtl_tbl(p_position_id).effective_end_date < p_start_date)))) THEN

	 l_index := l_index + 1;
         l_elem_rec_tab(l_index).pay_element_option_id := g_ws_pos_dtl_tbl(p_position_id).pay_element_option_id;
         l_elem_rec_tab(l_index).effective_start_date := g_ws_pos_dtl_tbl(p_position_id).effective_start_date;
         l_elem_rec_tab(l_index).effective_end_date := g_ws_pos_dtl_tbl(p_position_id).effective_end_date;
         l_elem_rec_tab(l_index).element_value_type := g_ws_pos_dtl_tbl(p_position_id).element_value_type;
         l_elem_rec_tab(l_index).element_value := g_ws_pos_dtl_tbl(p_position_id).element_value;
         l_elem_rec_tab(l_index).pay_basis := g_ws_pos_dtl_tbl(p_position_id).pay_basis;

         l_start_date := p_start_date;
	 l_end_date   := p_end_date;

    /*start bug:8235347: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam_PI',
                    'Latest Record at Pos Level is added to l_elem_rec_tab'||
                    ' having start date as:'||g_ws_pos_dtl_tbl(p_position_id).effective_start_date||
                    ' and end date as:'||g_ws_pos_dtl_tbl(p_position_id).effective_end_date||
                    ' element value as:'||g_ws_pos_dtl_tbl(p_position_id).element_value);
       /*  fnd_file.put_line(fnd_file.LOG, 'Latest Record at Pos Level is added to l_elem_rec_tab'||
                           ' having start date as:'||g_ws_pos_dtl_tbl(p_position_id).effective_start_date||
                           ' and end date as:'||g_ws_pos_dtl_tbl(p_position_id).effective_end_date||
                           ' element value as:'||g_ws_pos_dtl_tbl(p_position_id).element_value); */--bug:6626807
  end if;
   /*end bug:8235347:end statement level log*/

     END IF;
   END IF;  --bug:8235347:modified
 END IF;
  /*bug:6626807:end*/

  /*Bug:6374881:end*/

  --for c_Elem_Rec in c_Elem loop --bug:6374881
 /*Bug:6374881: Used the logic to loop through plsql table l_elem_rec_tab
   instead of for loop directly on c_Elem cursor. Modified the references of
   c_Elem_Rec as l_elem_rec_tab(c_Elem_Rec) in the proc. */

  for c_Elem_Rec in 1..l_elem_rec_tab.count loop

    /*start bug:8235347: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam_PI',
                    'Inside Loop (c_Elem) in proc - Process_PosParam_PI:start date::'||
                    l_elem_rec_tab(c_Elem_Rec).effective_start_date||' End date:'||
                    l_elem_rec_tab(c_Elem_Rec).effective_end_date||' Value:'||
                    l_elem_rec_tab(c_Elem_Rec).element_value);
    /* fnd_file.put_line(fnd_file.LOG, 'Inside Loop (c_Elem) in proc - Process_PosParam_PI:start date::'||
                                    l_elem_rec_tab(c_Elem_Rec).effective_start_date||' End date:'||
                                    l_elem_rec_tab(c_Elem_Rec).effective_end_date||' Value:'||
                                    l_elem_rec_tab(c_Elem_Rec).element_value); */
  end if;
 /*end bug:8235347:end statement level log*/

  /*bug:6626807:start*/
   l_pay_element_option_id := null;
    l_start_date   := null;
    l_end_date     := null;
    l_modify_assign := FALSE;
  /*bug:6626807:end*/

 /*bug:6374881:end*/

    if l_elem_rec_tab(c_Elem_Rec).element_value is null then
    begin

   /*Bug:5924932:start*/
   IF g_event_type = 'BP' THEN

        /*bug:6626807:start*/
      IF l_start_date IS NULL OR l_end_date IS NULL THEN
	    IF l_elem_rec_tab(c_Elem_Rec).effective_end_date IS NULL THEN
	       l_end_date := p_end_date;
	    ELSIF l_elem_rec_tab(c_Elem_Rec).effective_end_date between p_start_date AND p_end_date THEN
	        l_end_date := l_elem_rec_tab(c_Elem_Rec).effective_end_date;
	    ELSIF l_elem_rec_tab(c_Elem_Rec).effective_end_date > p_end_date THEN
	        l_end_date := p_end_date;
	    END IF;

	    IF l_end_date IS NULL THEN
	      l_end_date := p_end_date;
	    END IF;

	    IF l_elem_rec_tab(c_Elem_Rec).effective_start_date <= p_start_date THEN
	        l_start_date := p_start_date;
	    ELSIF l_elem_rec_tab(c_Elem_Rec).effective_start_date BETWEEN p_start_date AND p_end_date THEN
	        l_start_date := l_elem_rec_tab(c_Elem_Rec).effective_start_date;
	    END IF;
     END IF;

      FOR i IN 1..g_pos_assign_tbl.COUNT LOOP

	  IF (g_pos_assign_tbl(i).position_id = p_position_id AND
	      g_pos_assign_tbl(i).pay_element_id = p_pay_element_id AND     --bug:8566969:added
             ((l_start_date between g_pos_assign_tbl(i).effective_start_date
	      AND NVL(g_pos_assign_tbl(i).effective_end_date,l_start_date)) OR
	      (l_end_date between g_pos_assign_tbl(i).effective_start_date
	      AND NVL(g_pos_assign_tbl(i).effective_end_date,l_end_date)))) THEN

             IF g_pos_assign_tbl(i).pay_element_option_id = l_elem_rec_tab(c_Elem_Rec).pay_element_option_id THEN
               l_pay_element_option_id := l_elem_rec_tab(c_Elem_Rec).pay_element_option_id;
               exit;  --bug:8566969:added
             ELSIF l_elem_rec_tab(c_Elem_Rec).pay_element_option_id IS NULL AND
                   g_pos_assign_tbl(i).pay_element_option_id IS NULL THEN
               l_pay_element_option_id := null;
             ELSE
               l_pay_element_option_id := g_pos_assign_tbl(i).pay_element_option_id;
               l_elem_value := g_pos_assign_tbl(i).element_value;
             END IF;

	   END IF;
      END LOOP;

         IF l_pay_element_option_id IS NULL THEN
           l_pay_element_option_id := l_elem_rec_tab(c_Elem_Rec).pay_element_option_id;
         END IF;
        IF l_elem_value IS NULL THEN
         FOR c_ElemRates_Rec in c_ElemRates (l_start_date,l_end_date) LOOP
           l_elem_value := c_ElemRates_Rec.element_value;
         END LOOP;
        END IF;
        /*bug:6626807:end*/

    ELSIF g_event_type = 'BR' THEN
         /*bug:6626807:start*/
    FOR c_ElemRates_Rec in c_ElemRates (l_elem_rec_tab(c_Elem_Rec).effective_start_date, nvl(l_elem_rec_tab(c_Elem_Rec).effective_end_date, p_end_date)) loop
      l_elem_value := c_ElemRates_Rec.element_value;
    END LOOP;
        /*bug:6626807:end*/
    END IF;
   /*Bug:5924932:end*/

	if l_elem_rec_tab(c_Elem_Rec).element_value_type in ('A', 'PS') then
	begin

	  if FND_API.to_Boolean(p_compound_annually) then
	  begin

            /* Bug 3786457 Start */
            /* IF p_element_value < 1 THEN
                l_element_value
                 := c_ElemRates_Rec.element_value * POWER(1 + p_element_value, p_compound_factor);
               ELSE
                l_element_value
                 := c_ElemRates_Rec.element_value * POWER(1 + p_element_value / 100, p_compound_factor);
               END IF;  */
            /*Modified the below condition for calculating l_element_value
              based on l_elem_value instead of c_ElemRates_Rec.element_value for bug:5924932*/
               l_element_value
                := l_elem_value * POWER(1 + p_element_value / 100, p_compound_factor); --Bug:5924932:modified
            /* Bug 3786457 End */

	  end;
	  else
	  begin

            /* Bug 3786457 Start */

            /*IF p_element_value < 1 THEN
                l_element_value := c_ElemRates_Rec.element_value * (1 + p_element_value);
              ELSE
                l_element_value := c_ElemRates_Rec.element_value * (1 + p_element_value / 100);
              END IF; */

            /*Modified the below condition for calculating l_element_value
              based on l_elem_value instead of c_ElemRates_Rec.element_value for bug:5924932*/

	        l_element_value := l_elem_value * (1 + p_element_value / 100); --Bug:5924932:modified

            /* Bug 3786457 End */

	  end;
	  end if;
   /*start bug:8235347: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam_PI',
                    'PosParam_PI::start_date(1):'||l_start_date||'  end_date(1):'||l_end_date||
                    '  l_pay_element_option_id(1):'||l_pay_element_option_id||
                    '  l_element_value(1):'||l_element_value);

     /* fnd_file.put_line(fnd_file.LOG,'PosParam_PI::start_date(1):'||l_start_date);
      fnd_file.put_line(fnd_file.LOG,'PosParam_PI::end_date(1):'||l_end_date);
      fnd_file.put_line(fnd_file.LOG,'PosParam_PI::l_pay_element_option_id(1):'||l_pay_element_option_id);
      fnd_file.put_line(fnd_file.LOG,'PosParam_PI::l_element_value(1):'||l_element_value); */--bug:6626807
  end if;
  /*end bug:8235347:end statement level log*/

      /*bug:6626807:start*/
        IF p_pay_element_option_id IS NULL AND l_pay_element_option_id IS NULL THEN
          l_modify_assign := TRUE;
        ELSIF nvl(l_pay_element_option_id,l_elem_rec_tab(c_Elem_Rec).pay_element_option_id)
              = p_pay_element_option_id THEN
           l_modify_assign := TRUE;
        END IF;

     IF l_modify_assign THEN
      /*bug:6626807:end*/

	  PSB_POSITIONS_PVT.Modify_Assignment
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_position_assignment_id => l_posasgn_id,
	      p_data_extract_id => p_data_extract_id,
	      p_worksheet_id => p_global_worksheet_id,
	      p_position_id => p_position_id,
	      p_assignment_type => 'ELEMENT',
	      p_attribute_id => null,
	      p_attribute_value_id => null,
	      p_attribute_value => null,
	      p_pay_element_id => p_pay_element_id,
     /*Bug:5924932: Changed the value passed to p_pay_element_option_id from
        c_ElemRates_Rec.pay_element_option_id to l_pay_element_option_id */
	      p_pay_element_option_id => NVL(l_pay_element_option_id,l_elem_rec_tab(c_Elem_Rec).pay_element_option_id),
	      p_effective_start_date => l_start_date,--bug:6626807
	      p_effective_end_date => l_end_date,--bug:6626807
	      p_element_value_type => l_elem_rec_tab(c_Elem_Rec).element_value_type,
	      p_element_value => l_element_value,
	      p_currency_code => p_currency_code,
	      p_pay_basis => null, --bug:6626807:passed null value
	      p_global_default_flag => null,
	      p_assignment_default_rule_id => null,
	      p_modify_flag => null,
	      p_rowid => l_rowid,
	      p_employee_id => null,
	      p_primary_employee_flag => null);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  /*bug:6626807:start*/
	   IF l_start_date = l_elem_rec_tab(c_Elem_Rec).effective_start_date AND
              l_end_date < l_elem_rec_tab(c_Elem_Rec).effective_end_date THEN

               l_start_date := l_end_date + 1;
               l_end_date := l_elem_rec_tab(c_Elem_Rec).effective_end_date;

	  PSB_POSITIONS_PVT.Modify_Assignment
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_position_assignment_id => l_posasgn_id,
	      p_data_extract_id => p_data_extract_id,
	      p_worksheet_id => p_global_worksheet_id,
	      p_position_id => p_position_id,
	      p_assignment_type => 'ELEMENT',
	      p_attribute_id => null,
	      p_attribute_value_id => null,
	      p_attribute_value => null,
	      p_pay_element_id => p_pay_element_id,
     /*Bug:5924932: Changed the value passed to p_pay_element_option_id from
        c_ElemRates_Rec.pay_element_option_id to l_pay_element_option_id */
	      p_pay_element_option_id => NVL(l_pay_element_option_id,l_elem_rec_tab(c_Elem_Rec).pay_element_option_id),
	      p_effective_start_date => l_start_date,--bug:6626807
	      --bug:6626807:used l_end_date instead of p_end_date
	      p_effective_end_date => l_end_date,--bug:6626807
	      p_element_value_type => l_elem_rec_tab(c_Elem_Rec).element_value_type,
	      p_element_value => l_element_value,
	      p_currency_code => p_currency_code,
	      p_pay_basis => null, --bug:6626807:passed null
	      p_global_default_flag => null,
	      p_assignment_default_rule_id => null,
	      p_modify_flag => null,
	      p_rowid => l_rowid,
	      p_employee_id => null,
	      p_primary_employee_flag => null);

 	     if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	        raise FND_API.G_EXC_ERROR;
	     end if;

            END IF;
       END IF; -- IF l_modify_assign
	  /*bug:6626807:end*/

	end;
	end if;

    end;
    else
    begin

        /*bug:6626807:start*/
	  IF l_start_date IS NULL OR l_end_date IS NULL THEN
	    IF l_elem_rec_tab(c_Elem_Rec).effective_end_date IS NULL THEN
	       l_end_date := p_end_date;
	    ELSIF l_elem_rec_tab(c_Elem_Rec).effective_end_date between p_start_date AND p_end_date THEN
	        l_end_date := l_elem_rec_tab(c_Elem_Rec).effective_end_date;
	    ELSIF l_elem_rec_tab(c_Elem_Rec).effective_end_date > p_end_date THEN
	        l_end_date := p_end_date;
	    END IF;

	    IF l_end_date IS NULL THEN
	      l_end_date := p_end_date;
	    END IF;

	    IF l_elem_rec_tab(c_Elem_Rec).effective_start_date <= p_start_date THEN
	        l_start_date := p_start_date;
	    ELSIF l_elem_rec_tab(c_Elem_Rec).effective_start_date BETWEEN p_start_date AND p_end_date THEN
	        l_start_date := l_elem_rec_tab(c_Elem_Rec).effective_start_date;
	    END IF;
	   END IF;
        /*bug:6626807:end*/

      /*Bug:5924932:start*/
    IF g_event_type = 'BP' THEN

        /*bug:6626807:start*/
        l_pay_element_option_id := l_elem_rec_tab(c_Elem_Rec).pay_element_option_id;

	FOR i IN 1..g_pos_assign_tbl.COUNT LOOP

	  IF (g_pos_assign_tbl(i).position_id = p_position_id AND
	      g_pos_assign_tbl(i).pay_element_id = p_pay_element_id AND     --bug:8566969:added condition
             ((l_start_date between g_pos_assign_tbl(i).effective_start_date
	      AND NVL(g_pos_assign_tbl(i).effective_end_date,l_start_date)) OR
	      (l_end_date between g_pos_assign_tbl(i).effective_start_date
	      AND NVL(g_pos_assign_tbl(i).effective_end_date,l_end_date)))) THEN

             l_elem_value := g_pos_assign_tbl(i).element_value; --bug:8566969

             IF g_pos_assign_tbl(i).pay_element_option_id = l_elem_rec_tab(c_Elem_Rec).pay_element_option_id THEN
               l_pay_element_option_id := l_elem_rec_tab(c_Elem_Rec).pay_element_option_id;
               exit;      --bug:8566969:added
             ELSIF l_elem_rec_tab(c_Elem_Rec).pay_element_option_id IS NULL AND
                   g_pos_assign_tbl(i).pay_element_option_id IS NULL THEN
               l_pay_element_option_id := null;
             ELSE
               l_pay_element_option_id := g_pos_assign_tbl(i).pay_element_option_id;
             END IF;

	   END IF;
        END LOOP;

	IF l_elem_value IS NULL THEN
         FOR c_ElemRates_Rec in c_ElemRates (l_start_date,l_end_date) LOOP
            l_elem_value := c_ElemRates_Rec.element_value;
 	 END LOOP;
	ELSIF l_elem_value IS NULL THEN
           l_elem_value := l_elem_rec_tab(c_Elem_Rec).element_value;
	END IF;
        /*bug:6626807:end*/

    ELSIF g_event_type = 'BR' THEN
        l_pay_element_option_id := l_elem_rec_tab(c_Elem_Rec).pay_element_option_id; --bug:6626807
        l_elem_value := l_elem_rec_tab(c_Elem_Rec).element_value;
    END IF;
    /*Bug:5924932:end*/


        IF l_elem_rec_tab(c_Elem_Rec).element_value_type IN ('A','PS') THEN

        begin
        /* Bug 3786457 Start */
        /* if p_element_value < 1 then
            l_element_value := c_Elem_Rec.element_value * POWER(1 + p_element_value, p_compound_factor);
           else
            l_element_value := c_Elem_Rec.element_value * POWER(1 + p_element_value / 100, p_compound_factor);
           end if; */
           /*Bug:5924932:Modified the below condition to use l_elem_value instead of
             c_Elem_Rec.element_value while calculating l_element_value*/
           l_element_value
            := l_elem_value * POWER(1 + p_element_value / 100, p_compound_factor);--Bug:5924932:modified
         /* Bug 3786457 End */
	end;
	else
	begin
           /*Bug:5924932:Modified the below conditions to use l_elem_value instead of
             c_Elem_Rec.element_value while calculating l_element_value*/
	  if p_element_value < 1 then
	    l_element_value := l_elem_value * (1 + p_element_value);--Bug:5924932:modified
	  else
	    l_element_value := l_elem_value * (1 + p_element_value / 100);--Bug:5924932:modified
	  end if;

	end;
	end if;

   /*start bug:8235347: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam_PI',
                    'PosParam_PI::start_date(2):'||l_start_date||' end_date(2):'||l_end_date||
                    '  l_pay_element_option_id(2):'||l_pay_element_option_id||
                    '  l_element_value(2):'||l_element_value);

      /*fnd_file.put_line(fnd_file.LOG,'PosParam_PI::start_date(2):'||l_start_date);
      fnd_file.put_line(fnd_file.LOG,'PosParam_PI::end_date(2):'||l_end_date);
      fnd_file.put_line(fnd_file.LOG,'PosParam_PI::l_pay_element_option_id(2):'||l_pay_element_option_id);
      fnd_file.put_line(fnd_file.LOG,'PosParam_PI::l_element_value(2):'||l_element_value); */--bug:6626807
  end if;
   /*end bug:8235347: statement level logging*/

      /*bug:6626807:start*/
        IF p_pay_element_option_id IS NULL AND l_pay_element_option_id IS NULL THEN
          l_modify_assign := TRUE;
        ELSIF nvl(l_pay_element_option_id,l_elem_rec_tab(c_Elem_Rec).pay_element_option_id)
              = p_pay_element_option_id THEN
           l_modify_assign := TRUE;
        END IF;

     IF l_modify_assign THEN
      /*bug:6626807:end*/

	PSB_POSITIONS_PVT.Modify_Assignment
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_position_assignment_id => l_posasgn_id,
	    p_data_extract_id => p_data_extract_id,
	    p_worksheet_id => p_global_worksheet_id,
	    p_position_id => p_position_id,
	    p_assignment_type => 'ELEMENT',
	    p_attribute_id => null,
	    p_attribute_value_id => null,
	    p_attribute_value => null,
	    p_pay_element_id => p_pay_element_id,
     /*Bug:5924932: Changed the value passed to p_pay_element_option_id from
        c_Elem_Rec.pay_element_option_id to l_pay_element_option_id */
	    p_pay_element_option_id => NVL(l_pay_element_option_id,l_elem_rec_tab(c_Elem_Rec).pay_element_option_id),
          --bug:6626807:used l_start_date instead of p_start_date
	    p_effective_start_date => nvl(l_start_date,p_start_date),
          --bug:6626807:used l_end_date instead of p_end_date
	    p_effective_end_date => nvl(l_end_date,p_end_date),
	    p_element_value_type => l_elem_rec_tab(c_Elem_Rec).element_value_type,
	    p_element_value => l_element_value,
	    p_currency_code => p_currency_code,
	    p_pay_basis => null, --bug:6626807:passed null value
	    p_global_default_flag => null,
	    p_assignment_default_rule_id => null,
	    p_modify_flag => null,
	    p_rowid => l_rowid,
	    p_employee_id => null,
	    p_primary_employee_flag => null);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

     /*bug:6626807:start*/
     IF l_start_date = l_elem_rec_tab(c_Elem_Rec).effective_start_date AND
        l_end_date < l_elem_rec_tab(c_Elem_Rec).effective_end_date THEN
             l_start_date := l_end_date + 1;
             l_end_date := l_elem_rec_tab(c_Elem_Rec).effective_end_date;

	PSB_POSITIONS_PVT.Modify_Assignment
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_position_assignment_id => l_posasgn_id,
	    p_data_extract_id => p_data_extract_id,
	    p_worksheet_id => p_global_worksheet_id,
	    p_position_id => p_position_id,
	    p_assignment_type => 'ELEMENT',
	    p_attribute_id => null,
	    p_attribute_value_id => null,
	    p_attribute_value => null,
	    p_pay_element_id => p_pay_element_id,
     /*Bug:5924932: Changed the value passed to p_pay_element_option_id from
        c_Elem_Rec.pay_element_option_id to l_pay_element_option_id */
	    p_pay_element_option_id => NVL(l_pay_element_option_id,l_elem_rec_tab(c_Elem_Rec).pay_element_option_id),
          --bug:6626807:used l_start_date instead of p_start_date
	    p_effective_start_date => nvl(l_start_date,p_start_date),
          --bug:6626807:used l_end_date instead of p_end_date
	    p_effective_end_date => nvl(l_end_date,p_end_date),
	    p_element_value_type => l_elem_rec_tab(c_Elem_Rec).element_value_type,
	    p_element_value => l_element_value,
	    p_currency_code => p_currency_code,
	    p_pay_basis => null, --bug:6626807:passed null value
	    p_global_default_flag => null,
	    p_assignment_default_rule_id => null,
	    p_modify_flag => null,
	    p_rowid => l_rowid,
	    p_employee_id => null,
	    p_primary_employee_flag => null);

 	 if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	   raise FND_API.G_EXC_ERROR;
	 end if;

       END IF;
     END IF;-- IF l_modify_assign
     /*bug:6626807:end*/

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

END Process_PosParam_PI;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_PosParam_AutoInc
( p_return_status         OUT  NOCOPY  VARCHAR2,
  x_msg_data              OUT  NOCOPY  VARCHAR2,
  x_msg_count             OUT  NOCOPY  NUMBER,
  p_worksheet_id          IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_business_group_id     IN   NUMBER,
  p_position_id           IN   NUMBER,
  p_parameter_id          IN   NUMBER,
  p_parameter_start_date  IN   DATE,
  p_currency_code         IN   VARCHAR2,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE
) IS

  l_start_date             DATE;
  l_end_date               DATE;

  l_multiplier             NUMBER;

  l_compound_annually      VARCHAR2(1);
  l_compound_factor        NUMBER;

  l_hiredate_between_from  NUMBER;
  l_hiredate_between_to    NUMBER;
  l_adjdate_between_from   NUMBER;
  l_adjdate_between_to     NUMBER;
  l_increment_by           NUMBER;
  l_increment_type         VARCHAR2(1);

  l_return_status          VARCHAR2(1);

  /* start bug 4104890*/
  l_mid_point              NUMBER;
  l_current_day            NUMBER;
  l_cp_start_date          DATE;
  l_np_start_date          DATE;
  /* end bug 4104890*/


  l_api_name          CONSTANT VARCHAR2(30)     := 'Process_PosParam_AutoInc';

  cursor c_Formula is
    select hiredate_between_from,
	   hiredate_between_to,
	   adjdate_between_from,
	   adjdate_between_to,
	   increment_by,
	   increment_type
      from PSB_PARAMETER_FORMULAS
     where parameter_id = p_parameter_id;

BEGIN

    /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam_AutoInc',
    'BEGIN Process_PosParam_AutoInc');
   fnd_file.put_line(fnd_file.LOG,'BEGIN Process_PosParam_AutoInc');
   end if;
   /*end bug:5753424:end procedure level log*/

  for c_Formula_Rec in c_Formula loop
    l_hiredate_between_from := c_Formula_Rec.hiredate_between_from;
    l_hiredate_between_to := c_Formula_Rec.hiredate_between_to;
    l_adjdate_between_from := c_Formula_Rec.adjdate_between_from;
    l_adjdate_between_to := c_Formula_Rec.adjdate_between_to;
    l_increment_by := c_Formula_Rec.increment_by;
    l_increment_type := c_Formula_Rec.increment_type;
  end loop;

  -- fix done for bug no 4104890
  -- added the p_local_parameter flag
  PSB_WS_POS1.Cache_Named_Attribute_Values
     (p_return_status => l_return_status,
      p_worksheet_id => p_worksheet_id,
      p_data_extract_id => p_data_extract_id,
      p_position_id => p_position_id,
      p_local_parameter_flag => 'Y');


  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  if l_hiredate_between_from is not null then
  begin

    l_compound_factor := greatest(ceil((p_start_date - p_parameter_start_date) / l_hiredate_between_from), 0) + 1;
    l_multiplier := greatest(ceil((p_start_date - PSB_WS_POS1.g_hiredate) / l_hiredate_between_from), 0);

    /* start bug 4104890 */
      IF l_multiplier <= 0 THEN
        l_multiplier := 1;
      END IF;
    /* start bug 4104890 */

    loop

      /* start bug 4104890*/
      fnd_file.put_line(fnd_file.log, 'position id : '||p_position_id||' hire date : '||PSB_WS_POS1.g_hiredate);
      /* End bug 4104890*/

      l_start_date := PSB_WS_POS1.g_hiredate + l_hiredate_between_from * l_multiplier;

      /* start bug 4104890*/
      FOR l_periods IN
       (SELECT start_date,
               end_date+1 end_date
        FROM psb_budget_periods
        WHERE budget_period_type = 'C'
        AND l_start_date between start_date AND end_date
        AND budget_calendar_id = g_budget_calendar_id
       )
      LOOP
        l_cp_start_date := l_periods.start_date;
 	l_np_start_date := l_periods.end_date;
 	fnd_file.put_line(fnd_file.log, ' current period :'||l_cp_start_date||' next period : '||l_np_start_date);
      END LOOP;

      IF l_start_date between p_start_date and p_end_date THEN
        IF g_autoinc_period_profile = 'C' THEN
          -- current period
          l_start_date := l_cp_start_date;

        ELSIF g_autoinc_period_profile = 'N' THEN
          -- next period
          l_start_date := l_np_start_date;
        ELSE
          -- month mid point
          l_mid_point := ceil((trunc(l_np_start_date - 1) - trunc(l_cp_start_date))/2);
          l_current_day := trunc(l_start_date) - trunc(l_cp_start_date);

          IF l_current_day <= l_mid_point THEN
            l_start_date := l_cp_start_date;
          ELSE
            l_start_date := l_np_start_date;
          END IF;
        END IF;
      END IF;
      /* End bug 4104890 */

      if l_start_date between p_start_date and p_end_date then
      begin

    /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam_AutoInc',
    'Before call to Process_PosParam_AutoInc_Step for position:'||p_position_id);
   fnd_file.put_line(fnd_file.LOG,'Before call to Process_PosParam_AutoInc_Step for position:'||p_position_id);
   end if;
   /*end bug:5753424:end statement level log*/

  g_autoinc_apply := g_autoinc_apply + 1;  --5924184

	Process_PosParam_AutoInc_Step
	       (p_return_status => l_return_status,
		p_worksheet_id => p_worksheet_id,
		p_data_extract_id => p_data_extract_id,
		p_business_group_id => p_business_group_id,
		p_position_id => p_position_id,
		p_currency_code => p_currency_code,
		p_start_date => l_start_date,
		p_end_date => null,
		p_compound_annually => FND_API.G_TRUE,
		p_compound_factor => l_compound_factor,
		p_increment_type => l_increment_type,
		p_increment_by => l_increment_by);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

	l_compound_factor := l_compound_factor + 1;
	l_multiplier := l_multiplier + 1;

      end;
      else
	exit;
      end if;

    end loop;

  end;
  elsif l_adjdate_between_from is not null then
  begin

    l_compound_factor := greatest(ceil((p_start_date - p_parameter_start_date) / l_adjdate_between_from), 0) + 1;
    l_multiplier := greatest(ceil((p_start_date - PSB_WS_POS1.g_adjustment_date) / l_adjdate_between_from), 0);

    /* start bug 4104890 */
    IF l_multiplier <= 0 THEN
      l_multiplier := 1;
    END IF;
    /* start bug 4104890 */

    loop

      /* start bug 4104890*/
      fnd_file.put_line(fnd_file.log, 'position id : '||p_position_id||'  adjustment date : '||PSB_WS_POS1.g_adjustment_date);
      /* End bug 4104890*/

      l_start_date := PSB_WS_POS1.g_adjustment_date + l_adjdate_between_from * l_multiplier;

      /* start bug 4104890*/
      FOR l_periods IN
      (SELECT start_date ,
              end_date+1 end_date
       FROM psb_budget_periods
       WHERE budget_period_type = 'C'
       AND l_start_date between start_date AND end_date
       AND budget_calendar_id = g_budget_calendar_id
      )
      LOOP
        l_cp_start_date := l_periods.start_date;
        l_np_start_date := l_periods.end_date;
        fnd_file.put_line(fnd_file.log, ' current period :'||l_cp_start_date||' next period : '||l_np_start_date);
      END LOOP;


      IF l_start_date between p_start_date and p_end_date THEN
        IF g_autoinc_period_profile = 'C' THEN
          -- current period
          l_start_date := l_cp_start_date;

        ELSIF g_autoinc_period_profile = 'N' THEN
          -- next period
          l_start_date := l_np_start_date;

        ELSE
          -- month mid point
          l_mid_point := ceil((trunc(l_np_start_date - 1) - trunc(l_cp_start_date))/2);
          l_current_day := trunc(l_start_date) - trunc(l_cp_start_date);

          IF l_current_day <= l_mid_point THEN
            l_start_date := l_cp_start_date;
          ELSE
            l_start_date := l_np_start_date;
          END IF;
        END IF;
      END IF;
      /* End bug 4104890 */

      if l_start_date between p_start_date and p_end_date then
      begin

    /*start bug:5753424: statement level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam_AutoInc',
    'Before call to Process_PosParam_AutoInc_Step for position:'||p_position_id);
   fnd_file.put_line(fnd_file.LOG,'Before call to Process_PosParam_AutoInc_Step for position:'||p_position_id);
   end if;
   /*end bug:5753424:end statement level log*/

      g_autoinc_apply := g_autoinc_apply + 1;  --5924184

	Process_PosParam_AutoInc_Step
	       (p_return_status => l_return_status,
		p_worksheet_id  => p_worksheet_id,
		p_data_extract_id => p_data_extract_id,
		p_business_group_id => p_business_group_id,
		p_position_id => p_position_id,
		p_currency_code => p_currency_code,
		p_start_date => l_start_date,
		p_end_date => null,
		p_compound_annually => FND_API.G_TRUE,
		p_compound_factor => l_compound_factor,
		p_increment_type => l_increment_type,
		p_increment_by => l_increment_by);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

	l_compound_factor := l_compound_factor + 1;
	l_multiplier := l_multiplier + 1;

      end;
      else
	exit;
      end if;

    end loop;

  end;
  end if;

 /*Bug:5924184: To use the p_compound_factor in
  Process_PosParam_AutoInc_Step for the first record. This is required
  when the parameter is applied from a date prior to current year start date*/

 g_autoinc_apply := 0; --5924184

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

    /*start bug:5753424: procedure level logging*/
  if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
    'PSB/LOCAL_PARAM_SET/PSBVWP3B/Process_PosParam_AutoInc',
    'END Process_PosParam_AutoInc');
   fnd_file.put_line(fnd_file.LOG,'END Process_PosParam_AutoInc');
   end if;
   /*end bug:5753424:end procedure level log*/

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data => x_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data => x_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Process_PosParam_AutoInc;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_PosParam_AutoInc_Step
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_worksheet_id       IN   NUMBER,
  p_data_extract_id    IN   NUMBER,
  p_business_group_id  IN   NUMBER,
  p_position_id        IN   NUMBER,
  p_currency_code      IN   VARCHAR2,
  p_start_date         IN   DATE,
  p_end_date           IN   DATE,
  p_compound_annually  IN   VARCHAR2,
  p_compound_factor    IN   NUMBER := FND_API.G_MISS_NUM,
  p_increment_type     IN   VARCHAR2,
  p_increment_by       IN   NUMBER
) IS

  l_element_value           NUMBER;

  l_nextrate_found          VARCHAR2(1);
  l_option_name             VARCHAR2(80);
  l_sequence_number         NUMBER;
  l_increment_by            NUMBER;
  l_pay_element_option_id   NUMBER;

  l_posasgn_id              NUMBER;
  l_rowid                   VARCHAR2(100);

  l_num_steps               NUMBER;

  l_return_status           VARCHAR2(1);
  l_msg_data                VARCHAR2(2000);
  l_msg_count               NUMBER;

   /*Bug:5924184:Start */
  l_override_value         NUMBER;
  l_compound_factor        NUMBER;
  l_pay_basis              PSB_PAY_ELEMENT_RATES.pay_basis%TYPE;
   /*Bug:5924184:End */

  l_api_name            CONSTANT VARCHAR2(30)   := 'Process_PosParam_AutoInc_Step';

  cursor c_Elem is
    select a.pay_element_id,
	   a.pay_element_option_id,
	   a.effective_start_date,
	   a.effective_end_date,
	   a.element_value_type,
	   a.element_value,
	   a.pay_basis,
    /* For Bug No. 2263220 : Start */
	   b.option_flag
    /* For Bug No. 2263220 : End */
      from PSB_POSITION_ASSIGNMENTS a,
	   PSB_PAY_ELEMENTS b
     where a.currency_code = p_currency_code
       and (((p_end_date is not null)
	 and (((a.effective_start_date <= p_end_date)
	   and (a.effective_end_date is null))
	   or ((a.effective_start_date between p_start_date and p_end_date)
	   or (a.effective_end_date between p_start_date and p_end_date)
	   or ((a.effective_start_date < p_start_date)
	   and (a.effective_end_date > p_end_date)))))
	or ((p_end_date is null)
    /*Bug:6374881:start*/
       and ((p_start_date between a.effective_start_date and nvl(a.effective_end_date,p_start_date)) )))
       and ((a.worksheet_id=p_worksheet_id or ((a.worksheet_id is null
       and not exists
      (select 1
         from psb_position_assignments ppa1
        where ppa1.pay_element_id = a.pay_element_id
          and ppa1.position_id = p_position_id
          and ppa1.worksheet_id = p_worksheet_id
          and ((ppa1.effective_start_date between
               a.effective_start_date and nvl(a.effective_end_date,ppa1.effective_start_date)) or
              (a.effective_start_date between
              ppa1.effective_start_date and nvl(ppa1.effective_end_date,a.effective_start_date)))) ))))
    /*Bug:6374881:end*/
       and a.pay_element_id = b.pay_element_id
       and a.position_id = p_position_id
       and b.salary_flag = 'Y'
       and b.processing_type = 'R'
       and b.business_group_id = p_business_group_id
       and b.data_extract_id = p_data_extract_id;

  cursor c_ElemRates (ElemID NUMBER,
		      ElemOptID NUMBER,
		      StartDate DATE,
		      EndDate DATE) is
    select element_value_type,
	   element_value,
	   formula_id,
	   pay_basis,
	   effective_start_date,
	   effective_end_date
      from PSB_PAY_ELEMENT_RATES
     where worksheet_id is null
       and ((ElemOptID is null) or (pay_element_option_id = ElemOptID))
       and (((EndDate is not null)
	 and (((effective_start_date <= EndDate)
	   and (effective_end_date is null))
	   or ((effective_start_date between StartDate and EndDate)
	   or (effective_end_date between StartDate and EndDate)
	   or ((effective_start_date < StartDate)
	   and (effective_end_date > EndDate)))))
	or ((EndDate is null)
	and (nvl(effective_end_date, StartDate) >= StartDate)))
       and pay_element_id = ElemID;

  cursor c_ElemOptions (ElemOptID NUMBER) is
    select name,
	   sequence_number
      from PSB_PAY_ELEMENT_OPTIONS
     where pay_element_option_id = ElemOptID;

  cursor c_NextOption (ElementID NUMBER,
		       OptionName VARCHAR2,
		       SeqNum NUMBER) is
    select pay_element_option_id,
	   sequence_number
      from PSB_PAY_ELEMENT_OPTIONS
     where sequence_number =
	  (select min(sequence_number)
	     from PSB_PAY_ELEMENT_OPTIONS
	    where sequence_number > SeqNum
	      and name = OptionName
	      and pay_element_id = ElementID)
       and name = OptionName
       and pay_element_id = ElementID;

 /*Bug:5924184:Start */

  cursor c_worksheet_record_csr(ElementID NUMBER) is
    select a.pay_element_id,
	   a.pay_element_option_id,
	   a.effective_start_date,
	   a.effective_end_date,
	   a.element_value_type,
	   a.element_value,
	   a.pay_basis
    from PSB_POSITION_ASSIGNMENTS a
   where a.worksheet_id = p_worksheet_id
     and a.position_id  = p_position_id
     and a.pay_element_id = ElementID
     and a.currency_code = p_currency_code
     and p_start_date between a.effective_start_date and NVL(a.effective_end_date,p_start_date)
    order by a.effective_start_date;

 /*Bug:5924184:end */

BEGIN

 l_compound_factor := p_compound_factor; --5924184

  -- Loop for all Positions assigned to recurring Salary Elements

  for c_Elem_Rec in c_Elem loop

 /*Bug:5924184:start */
  IF g_event_type = 'BP' THEN

    FOR c_worksheet_rec IN c_worksheet_record_csr(c_Elem_Rec.pay_element_id) LOOP
      l_override_value        := c_worksheet_rec.element_value;
      l_pay_element_option_id := c_worksheet_rec.pay_element_option_id;
      l_pay_basis             := c_worksheet_rec.pay_basis;
    END LOOP;

  END IF;

  IF g_autoinc_apply = 1 THEN
     l_compound_factor := p_compound_factor;
  ELSIF l_override_value IS NOT NULL THEN
       l_compound_factor := 1;
  END IF;

 /*Bug:5924184:end */

    if p_increment_type = 'A' then
    begin

      if c_Elem_Rec.element_value is null then
      begin

	for c_ElemRates_Rec in c_ElemRates (c_Elem_Rec.pay_element_id,
					    c_Elem_Rec.pay_element_option_id,
					    c_Elem_Rec.effective_start_date,
					    c_Elem_Rec.effective_end_date) loop

	  if c_ElemRates_Rec.element_value_type = 'A' then
	  begin

	    if FND_API.to_Boolean(p_compound_annually) then
    /*Bug:5924184:modified p_compound_factor to l_compound_factor.
                  Used l_override_value for element_value calculation. If the value
                  is null, then used c_ElemRates_Rec.element_value */
	      l_element_value := NVL(l_override_value,c_ElemRates_Rec.element_value) + p_increment_by * l_compound_factor;
	    else
	      l_element_value := NVL(l_override_value,c_ElemRates_Rec.element_value) + p_increment_by;
	    end if;

	    PSB_POSITIONS_PVT.Modify_Assignment
	       (p_api_version => 1.0,
		p_return_status => l_return_status,
		p_msg_count => l_msg_count,
		p_msg_data => l_msg_data,
		p_position_assignment_id => l_posasgn_id,
		p_data_extract_id => p_data_extract_id,
		p_worksheet_id => p_worksheet_id,
		p_position_id => p_position_id,
		p_assignment_type => 'ELEMENT',
		p_attribute_id => null,
		p_attribute_value_id => null,
		p_attribute_value => null,
		p_pay_element_id => c_Elem_Rec.pay_element_id,
  /*Bug:5924184:applied NVL to use l_pay_element_option_id as the primary value for p_pay_element_option_id*/
		p_pay_element_option_id => NVL(l_pay_element_option_id,c_Elem_Rec.pay_element_option_id),
		p_effective_start_date => greatest(c_ElemRates_Rec.effective_start_date, p_start_date),
		p_effective_end_date => least(nvl(c_ElemRates_Rec.effective_end_date, p_end_date), p_end_date),
		p_element_value_type => c_ElemRates_Rec.element_value_type,
		p_element_value => l_element_value,
		p_currency_code => p_currency_code,
    /*Bug:5924184:applied NVL to use l_pay_basis as the primary value for p_pay_basis*/
		p_pay_basis => NVL(l_pay_basis,c_ElemRates_Rec.pay_basis),
		p_global_default_flag => null,
		p_assignment_default_rule_id => null,
		p_modify_flag => null,
		p_rowid => l_rowid,
		p_employee_id => null,
		p_primary_employee_flag => null);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;

	  end;
	  end if;

	end loop;

      end;
      else
      begin

	if c_Elem_Rec.element_value_type = 'A' then
	begin

	  if FND_API.to_Boolean(p_compound_annually) then
    /*Bug:5924184:modified p_compound_factor to l_compound_factor.
                  Used l_override_value for element_value calculation. If the value
                  is null, then used c_Elem_Rec.element_value */
	    l_element_value := NVL(l_override_value,c_Elem_Rec.element_value) + p_increment_by * l_compound_factor;
	  else
	    l_element_value := NVL(l_override_value,c_Elem_Rec.element_value) + p_increment_by;
	  end if;

	  PSB_POSITIONS_PVT.Modify_Assignment
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_position_assignment_id => l_posasgn_id,
	      p_data_extract_id => p_data_extract_id,
	      p_worksheet_id => p_worksheet_id,
	      p_position_id => p_position_id,
	      p_assignment_type => 'ELEMENT',
	      p_attribute_id => null,
	      p_attribute_value_id => null,
	      p_attribute_value => null,
	      p_pay_element_id => c_Elem_Rec.pay_element_id,
  /*Bug:5924184:applied NVL to use l_pay_element_option_id as the primary value for p_pay_element_option_id*/
	      p_pay_element_option_id => NVL(l_pay_element_option_id,c_Elem_Rec.pay_element_option_id),
	      p_effective_start_date => greatest(c_Elem_Rec.effective_start_date, p_start_date),
	      p_effective_end_date => least(nvl(c_Elem_Rec.effective_end_date, p_end_date), p_end_date),
	      p_element_value_type => c_Elem_Rec.element_value_type,
	      p_element_value => l_element_value,
	      p_currency_code => p_currency_code,
  /*Bug:5924184:applied NVL to use l_pay_basis as the primary value for p_pay_basis*/
	      p_pay_basis => NVL(l_pay_basis,c_Elem_Rec.pay_basis),
	      p_global_default_flag => null,
	      p_assignment_default_rule_id => null,
	      p_modify_flag => null,
	      p_rowid => l_rowid,
	      p_employee_id => null,
	      p_primary_employee_flag => null);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end;
	end if;

      end;
      end if;

    end;
    elsif p_increment_type = 'P' then
    begin

      if c_Elem_Rec.element_value is null then
      begin

	for c_ElemRates_Rec in c_ElemRates (c_Elem_Rec.pay_element_id,
					    c_Elem_Rec.pay_element_option_id,
					    c_Elem_Rec.effective_start_date,
					    c_Elem_Rec.effective_end_date) loop

	  if c_ElemRates_Rec.element_value_type = 'A' then
	  begin

	    if FND_API.to_Boolean(p_compound_annually) then
	    begin
              /* Bug 2820755 Start */

	      /* if p_increment_by < 1 then
		l_element_value := c_ElemRates_Rec.element_value * POWER(1 + p_increment_by, p_compound_factor);
	      else
		l_element_value := c_ElemRates_Rec.element_value * POWER(1 + p_increment_by / 100, p_compound_factor);
	      end if; */

	      fnd_file.put_line(fnd_file.log, 'source element value : '||c_ElemRates_Rec.element_value);
	      fnd_file.put_line(fnd_file.log, 'increment factor : '||p_increment_by);

    /*Bug:5924184:modified p_compound_factor to l_compound_factor.
                  Used l_override_value for element_value calculation. If the value
                  is null, then used c_ElemRates_Rec.element_value */

             l_element_value := NVL(l_override_value,c_ElemRates_Rec.element_value) * POWER(1 + p_increment_by / 100, l_compound_factor);
              /* Bug 2820755 End */

	    end;
	    else
	    begin
              /* Bug 2820755 Start */

	      /* if p_increment_by < 1 then
		l_element_value := c_ElemRates_Rec.element_value * (1 + p_increment_by);
	      else
		l_element_value := c_ElemRates_Rec.element_value * (1 + p_increment_by / 100);
	      end if; */

              fnd_file.put_line(fnd_file.log, 'source element value : '||c_ElemRates_Rec.element_value);
	      fnd_file.put_line(fnd_file.log, 'increment factor : '||p_increment_by);

              l_element_value
               := NVL(l_override_value,c_ElemRates_Rec.element_value) * (1 + p_increment_by / 100);
              /* Bug 2820755 End */

	    end;
	    end if;

	    PSB_POSITIONS_PVT.Modify_Assignment
	       (p_api_version => 1.0,
		p_return_status => l_return_status,
		p_msg_count => l_msg_count,
		p_msg_data => l_msg_data,
		p_position_assignment_id => l_posasgn_id,
		p_data_extract_id => p_data_extract_id,
		p_worksheet_id => p_worksheet_id,
		p_position_id => p_position_id,
		p_assignment_type => 'ELEMENT',
		p_attribute_id => null,
		p_attribute_value_id => null,
		p_attribute_value => null,
		p_pay_element_id => c_Elem_Rec.pay_element_id,
  /*Bug:5924184:applied NVL to use l_pay_element_option_id as the primary value for p_pay_element_option_id*/
		p_pay_element_option_id => NVL(l_pay_element_option_id,c_Elem_Rec.pay_element_option_id),
		p_effective_start_date => greatest(c_ElemRates_Rec.effective_start_date, p_start_date),
		p_effective_end_date => least(nvl(c_ElemRates_Rec.effective_end_date, p_end_date), p_end_date),
		p_element_value_type => c_ElemRates_Rec.element_value_type,
		p_element_value => l_element_value,
		p_currency_code => p_currency_code,
  /*Bug:5924184:applied NVL to use l_pay_basis as the primary value for p_pay_basis*/
		p_pay_basis => NVL(l_pay_basis,c_ElemRates_Rec.pay_basis),
		p_global_default_flag => null,
		p_assignment_default_rule_id => null,
		p_modify_flag => null,
		p_rowid => l_rowid,
		p_employee_id => null,
		p_primary_employee_flag => null);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;

	  end;
	  end if;

	end loop;
      end;
      else
      begin

	if c_Elem_Rec.element_value_type = 'A' then
	begin

	  if FND_API.to_Boolean(p_compound_annually) then
	  begin

            /* Start Bug No : 4281800 */
            -- commented for bug no 4281800
	    /* if p_increment_by < 1 then
	      l_element_value := c_Elem_Rec.element_value * POWER(1 + p_increment_by, p_compound_factor);
	    else
	      l_element_value := c_Elem_Rec.element_value * POWER(1 + p_increment_by / 100, p_compound_factor);
	    end if; */
            /* End Bug No : 4281800 */

            /* Start Bug No : 4281800 */
	    fnd_file.put_line(fnd_file.log, 'source element value : '||c_Elem_Rec.element_value);
	    fnd_file.put_line(fnd_file.log, 'increment factor : '||p_increment_by);

    /*Bug:5924184:modified p_compound_factor to l_compound_factor.
                  Used l_override_value for element_value calculation. If the value
                  is null, then used c_Elem_Rec.element_value */
            l_element_value
               := NVL(l_override_value,c_Elem_Rec.element_value) * POWER(1 + p_increment_by / 100, l_compound_factor);

	    /* End Bug No : 4281800 */

	  end;
	  else
	  begin

             /* Start Bug No : 4281800 */
             -- commented for bug no 4281800
            /* if p_increment_by < 1 then
	      l_element_value := c_Elem_Rec.element_value * (1 + p_increment_by);
	    else
	      l_element_value := c_Elem_Rec.element_value * (1 + p_increment_by / 100);
	    end if; */
            /* End Bug No : 4281800 */

            /* Start Bug No : 4281800 */

	    fnd_file.put_line(fnd_file.log, 'source element value : '||c_Elem_Rec.element_value);
	    fnd_file.put_line(fnd_file.log, 'increment factor : '||p_increment_by);

            l_element_value
               := NVL(l_override_value,c_Elem_Rec.element_value) * (1 + p_increment_by / 100);

	   /* End Bug No : 4281800 */

	  end;
	  end if;

	  PSB_POSITIONS_PVT.Modify_Assignment
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_position_assignment_id => l_posasgn_id,
	      p_data_extract_id => p_data_extract_id,
	      p_worksheet_id => p_worksheet_id,
	      p_position_id => p_position_id,
	      p_assignment_type => 'ELEMENT',
	      p_attribute_id => null,
	      p_attribute_value_id => null,
	      p_attribute_value => null,
	      p_pay_element_id => c_Elem_Rec.pay_element_id,
  /*Bug:5924184:applied NVL to use l_pay_element_option_id as the primary value for p_pay_element_option_id*/
	      p_pay_element_option_id => NVL(l_pay_element_option_id,c_Elem_Rec.pay_element_option_id),
	      p_effective_start_date => greatest(c_Elem_Rec.effective_start_date, p_start_date),
	      p_effective_end_date => least(nvl(c_Elem_Rec.effective_end_date, p_end_date), p_end_date),
	      p_element_value_type => c_Elem_Rec.element_value_type,
	      p_element_value => l_element_value,
	      p_currency_code => p_currency_code,
  /*Bug:5924184:applied NVL to use l_pay_basis as the primary value for p_pay_basis*/
	      p_pay_basis => NVL(l_pay_basis,c_Elem_Rec.pay_basis),
	      p_global_default_flag => null,
	      p_assignment_default_rule_id => null,
	      p_modify_flag => null,
	      p_rowid => l_rowid,
	      p_employee_id => null,
	      p_primary_employee_flag => null);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end;
	end if;

      end;
      end if;

    end;

    /* For Bug No. 2263220 : Start */
    -- If Increment Type is 'Step' then, the parameter should not be applied to Non Grade Salary elements.
    --elsif p_increment_type = 'S' then
    elsif (p_increment_type = 'S' and c_Elem_Rec.option_flag = 'Y') then
    /* For Bug No. 2263220 : End */

     begin

      l_nextrate_found := FND_API.G_FALSE;

      for c_ElemOptions_Rec in c_ElemOptions (c_Elem_Rec.pay_element_option_id) loop
	l_option_name := c_ElemOptions_Rec.name;
	l_sequence_number := c_ElemOptions_Rec.sequence_number;
      end loop;

      if FND_API.to_Boolean(p_compound_annually) then
	l_increment_by := p_increment_by * p_compound_factor;
      else
	l_increment_by := p_increment_by;
      end if;

      for l_num_steps in 1..l_increment_by loop

	for c_NextOption_Rec in c_NextOption (c_Elem_Rec.pay_element_id,
					      l_option_name,
					      l_sequence_number) loop

	  l_nextrate_found := FND_API.G_TRUE;
	  l_pay_element_option_id := c_NextOption_Rec.pay_element_option_id;
	  l_sequence_number := c_NextOption_Rec.sequence_number;
	end loop;

      end loop;

      if not FND_API.to_Boolean(l_nextrate_found) then
	l_pay_element_option_id := c_Elem_Rec.pay_element_option_id;
      end if;

      PSB_POSITIONS_PVT.Modify_Assignment
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_position_assignment_id => l_posasgn_id,
	  p_data_extract_id => p_data_extract_id,
	  p_worksheet_id => p_worksheet_id,
	  p_position_id => p_position_id,
	  p_assignment_type => 'ELEMENT',
	  p_attribute_id => null,
	  p_attribute_value_id => null,
	  p_attribute_value => null,
	  p_pay_element_id => c_Elem_Rec.pay_element_id,
	  p_pay_element_option_id => l_pay_element_option_id,
	  p_effective_start_date => greatest(c_Elem_Rec.effective_start_date, p_start_date),
	  p_effective_end_date => least(nvl(c_Elem_Rec.effective_end_date, p_end_date), p_end_date),
	  p_element_value_type => null,
	  p_element_value => null,
	  p_currency_code => p_currency_code,
	  p_pay_basis => null,
	  p_global_default_flag => null,
	  p_assignment_default_rule_id => null,
	  p_modify_flag => null,
	  p_rowid => l_rowid,
	  p_employee_id => null,
	  p_primary_employee_flag => null);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
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


END Process_PosParam_AutoInc_Step;

/* ----------------------------------------------------------------------- */

PROCEDURE Redistribute_Follow_Salary
( p_api_version         IN   NUMBER,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_position_line_id    IN   NUMBER,
  p_budget_year_id      IN   NUMBER := FND_API.G_MISS_NUM,
  p_service_package_id  IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_func_currency       IN   VARCHAR2 := FND_API.G_MISS_CHAR
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Redistribute_Follow_Salary';
  l_api_version         CONSTANT NUMBER         := 1.0;

  l_budget_calendar_id  NUMBER;
  l_flex_mapping_set_id NUMBER;
  l_rounding_factor     NUMBER;
  l_data_extract_id     NUMBER;
  l_budget_group_id     NUMBER;
  l_current_stage_seq   NUMBER;

  l_start_stage_seq     NUMBER;

  l_business_group_id   NUMBER;
  l_flex_code           NUMBER;
  l_func_currency       VARCHAR2(15);

  l_position_id         NUMBER;
  l_position_start_date DATE;
  l_position_end_date   DATE;

  l_year_index          BINARY_INTEGER;
  l_year_start_date     DATE;
  l_year_end_date       DATE;

  l_return_status       VARCHAR2(1);

  cursor c_WS is
    select budget_calendar_id,
	   flex_mapping_set_id,
	   rounding_factor,
	   nvl(data_extract_id, global_data_extract_id) data_extract_id,
	   budget_group_id,
	   current_stage_seq
      from PSB_WORKSHEETS_V
     where worksheet_id = p_worksheet_id;

  cursor c_BG is
    select nvl(business_group_id, root_business_group_id) business_group_id,
	   nvl(chart_of_accounts_id, root_chart_of_accounts_id) chart_of_accounts_id,
	   nvl(currency_code, root_currency_code) currency_code
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = l_budget_group_id;

  cursor c_Positions is
    select a.position_id,
	   a.effective_start_date,
	   a.effective_end_date
      from PSB_POSITIONS a,
	   PSB_WS_POSITION_LINES b
     where a.position_id = b.position_id
       and b.position_line_id = p_position_line_id;

  cursor c_Year is
    select start_date,
	   end_date
      from PSB_BUDGET_PERIODS
     where budget_period_id = p_budget_year_id;

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
    l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
    l_flex_mapping_set_id := c_WS_Rec.flex_mapping_set_id;
    l_rounding_factor := c_WS_Rec.rounding_factor;
    l_data_extract_id := c_WS_Rec.data_extract_id;
    l_budget_group_id := c_WS_Rec.budget_group_id;
    l_current_stage_seq := c_WS_Rec.current_stage_seq;
  end loop;

  l_start_stage_seq := l_current_stage_seq;

  for c_BG_Rec in c_BG loop
    l_business_group_id := c_BG_Rec.business_group_id;
    l_flex_code := c_BG_Rec.chart_of_accounts_id;
    l_func_currency := c_BG_Rec.currency_code;
  end loop;

  if p_func_currency <> FND_API.G_MISS_CHAR then
    l_func_currency := p_func_currency;
  end if;

  for c_Positions_Rec in c_Positions loop
    l_position_id := c_Positions_Rec.position_id;
    l_position_start_date := c_Positions_Rec.effective_start_date;
    l_position_end_date := c_Positions_Rec.effective_end_date;
  end loop;

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

  if l_flex_code <> nvl(PSB_WS_ACCT1.g_flex_code, FND_API.G_MISS_NUM) then
  begin

    PSB_WS_ACCT1.Flex_Info
       (p_return_status => l_return_status,
	p_flex_code => l_flex_code);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  if p_budget_year_id <> FND_API.G_MISS_NUM then
  begin

    for c_Year_Rec in c_Year loop
      l_year_start_date := c_Year_Rec.start_date;
      l_year_end_date := c_Year_Rec.end_date;
    end loop;

    PSB_WS_POS1.g_salary_budget_group_id := null;

    Redist_Follow_Salary_Year
	  (p_return_status => l_return_status,
	   p_worksheet_id => p_worksheet_id,
	   p_flex_mapping_set_id => l_flex_mapping_set_id,
	   p_rounding_factor => l_rounding_factor,
	   p_data_extract_id => l_data_extract_id,
	   p_business_group_id => l_business_group_id,
	   p_flex_code => l_flex_code,
	   p_position_line_id => p_position_line_id,
	   p_position_id => l_position_id,
	   p_position_start_date => l_position_start_date,
	   p_position_end_date => l_position_end_date,
	   p_budget_year_id => p_budget_year_id,
	   p_year_start_date => l_year_start_date,
	   p_year_end_date => l_year_end_date,
	   p_service_package_id => p_service_package_id,
	   p_stage_set_id => p_stage_set_id,
	   p_start_stage_seq => l_start_stage_seq,
	   p_current_stage_seq => l_current_stage_seq,
	   p_func_currency => l_func_currency);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  else
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

    for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

      PSB_WS_POS1.g_salary_budget_group_id := null;

      Redist_Follow_Salary_Year
	    (p_return_status => l_return_status,
	     p_worksheet_id => p_worksheet_id,
	     p_flex_mapping_set_id => l_flex_mapping_set_id,
	     p_rounding_factor => l_rounding_factor,
	     p_data_extract_id => l_data_extract_id,
	     p_business_group_id => l_business_group_id,
	     p_flex_code => l_flex_code,
	     p_position_line_id => p_position_line_id,
	     p_position_id => l_position_id,
	     p_position_start_date => l_position_start_date,
	     p_position_end_date => l_position_end_date,
	     p_budget_year_id => PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id,
	     p_year_start_date => PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
	     p_year_end_date => PSB_WS_ACCT1.g_budget_years(l_year_index).end_date,
	     p_service_package_id => p_service_package_id,
	     p_stage_set_id => p_stage_set_id,
	     p_start_stage_seq => l_start_stage_seq,
	     p_current_stage_seq => l_current_stage_seq,
	     p_func_currency => l_func_currency);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end loop;

  end;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

END Redistribute_Follow_Salary;

/* ----------------------------------------------------------------------- */

PROCEDURE Redist_Follow_Salary_Year
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER,
  p_flex_mapping_set_id  IN   NUMBER,
  p_rounding_factor      IN   NUMBER,
  p_data_extract_id      IN   NUMBER,
  p_business_group_id    IN   NUMBER,
  p_flex_code            IN   NUMBER,
  p_position_line_id     IN   NUMBER,
  p_position_id          IN   NUMBER,
  p_position_start_date  IN   DATE,
  p_position_end_date    IN   DATE,
  p_budget_year_id       IN   NUMBER,
  p_year_start_date      IN   DATE,
  p_year_end_date        IN   DATE,
  p_service_package_id   IN   NUMBER,
  p_stage_set_id         IN   NUMBER,
  p_start_stage_seq      IN   NUMBER,
  p_current_stage_seq    IN   NUMBER,
  p_func_currency        IN   VARCHAR2
) IS

  l_start_date           DATE;
  l_end_date             DATE;

  l_account_line_id      NUMBER;
  l_ytd_amount           NUMBER;
  l_period_amount        PSB_WS_ACCT1.g_prdamt_tbl_type;

  l_init_index           BINARY_INTEGER;
  l_element_index        BINARY_INTEGER;
  l_pdist_index          BINARY_INTEGER;
  l_eldist_index         BINARY_INTEGER;
  l_dist_index           BINARY_INTEGER;

  l_return_status        VARCHAR2(1);

  cursor c_Salary_Dist is
    select /*+ ORDERED INDEX(a PSB_WS_ACCOUNT_LINES_N5) */
	   code_combination_id,
	   budget_group_id,
	   ytd_amount
      from PSB_WS_ACCOUNT_LINES a
     where salary_account_line = 'Y'
       and p_current_stage_seq between start_stage_seq and current_stage_seq
       and currency_code = p_func_currency
       and stage_set_id = p_stage_set_id
       and service_package_id = p_service_package_id
       and budget_year_id = p_budget_year_id
       and position_line_id = p_position_line_id;

  cursor c_Element_Cost is
    select /*+ ORDERED USE_NL(a b) INDEX(a PSB_WS_ELEMENT_LINES_N1) INDEX(b PSB_PAY_ELEMENTS_U1) */
	   a.pay_element_id,
	   a.element_set_id,
	   a.element_cost
      from PSB_WS_ELEMENT_LINES a,
	   PSB_PAY_ELEMENTS b
     where p_current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.currency_code = p_func_currency
       and a.pay_element_id = b.pay_element_id
       and a.stage_set_id = p_stage_set_id
       and a.service_package_id = p_service_package_id
       and a.budget_year_id = p_budget_year_id
       and a.position_line_id = p_position_line_id
       and b.follow_salary = 'Y'
       and b.business_group_id = p_business_group_id
       and b.data_extract_id = p_data_extract_id;

  cursor c_Element_Dist is
    select /*+ ORDERED USE_NL(a b c) INDEX(a PSB_WS_ACCOUNT_LINES_N5) INDEX(b PSB_WS_ELEMENT_LINES_N1) INDEX(c PSB_PAY_ELEMENTS_U1) */
	   a.account_line_id,
	   a.code_combination_id,
	   a.ytd_amount,
	   a.period1_amount, a.period2_amount, a.period3_amount,
	   a.period4_amount, a.period5_amount, a.period6_amount,
	   a.period7_amount, a.period8_amount, a.period9_amount,
	   a.period10_amount, a.period11_amount, a.period12_amount,
	   a.period13_amount, a.period14_amount, a.period15_amount,
	   a.period16_amount, a.period17_amount, a.period18_amount,
	   a.period19_amount, a.period20_amount, a.period21_amount,
	   a.period22_amount, a.period23_amount, a.period24_amount,
	   a.period25_amount, a.period26_amount, a.period27_amount,
	   a.period28_amount, a.period29_amount, a.period30_amount,
	   a.period31_amount, a.period32_amount, a.period33_amount,
	   a.period34_amount, a.period35_amount, a.period36_amount,
	   a.period37_amount, a.period38_amount, a.period39_amount,
	   a.period40_amount, a.period41_amount, a.period42_amount,
	   a.period43_amount, a.period44_amount, a.period45_amount,
	   a.period46_amount, a.period47_amount, a.period48_amount,
	   a.period49_amount, a.period50_amount, a.period51_amount,
	   a.period52_amount, a.period53_amount, a.period54_amount,
	   a.period55_amount, a.period56_amount, a.period57_amount,
	   a.period58_amount, a.period59_amount, a.period60_amount
      from PSB_WS_ACCOUNT_LINES a,
	   PSB_WS_ELEMENT_LINES b,
	   PSB_PAY_ELEMENTS c
     where a.element_set_id = b.element_set_id
       and p_current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.stage_set_id = p_stage_set_id
       and a.service_package_id = p_service_package_id
       and a.budget_year_id = p_budget_year_id
       and a.position_line_id = p_position_line_id
       and p_current_stage_seq between b.start_stage_seq and b.current_stage_seq
       and b.currency_code = p_func_currency
       and b.pay_element_id = c.pay_element_id
       and b.stage_set_id = p_stage_set_id
       and b.service_package_id = p_service_package_id
       and b.budget_year_id = p_budget_year_id
       and b.position_line_id = p_position_line_id
       and c.follow_salary = 'Y'
       and c.business_group_id = p_business_group_id
       and c.data_extract_id = p_data_extract_id;

BEGIN

  PSB_WS_POS1.Initialize_Calc;

  PSB_WS_POS1.Initialize_Dist;

  PSB_WS_POS1.Initialize_Salary_Dist;

  PSB_WS_POS1.Initialize_Element_Dist;

  for c_Salary_Rec in c_Salary_Dist loop

    PSB_WS_POS1.g_num_salary_dist := PSB_WS_POS1.g_num_salary_dist + 1;
    l_ytd_amount := nvl(l_ytd_amount, 0) + c_Salary_Rec.ytd_amount;

    PSB_WS_POS1.g_salary_dist(PSB_WS_POS1.g_num_salary_dist).ccid := c_Salary_Rec.code_combination_id;
    PSB_WS_POS1.g_salary_dist(PSB_WS_POS1.g_num_salary_dist).amount := c_Salary_Rec.ytd_amount;
    PSB_WS_POS1.g_salary_dist(PSB_WS_POS1.g_num_salary_dist).start_date := p_year_start_date;
    PSB_WS_POS1.g_salary_dist(PSB_WS_POS1.g_num_salary_dist).end_date := p_year_end_date;

    if nvl(PSB_WS_POS1.g_salary_budget_group_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
      PSB_WS_POS1.g_salary_budget_group_id := c_Salary_Rec.budget_group_id;
    end if;

  end loop;

  for l_salary_index in 1..PSB_WS_POS1.g_num_salary_dist loop

    if l_ytd_amount = 0 then
      PSB_WS_POS1.g_salary_dist(l_salary_index).percent := 0;
    else
      PSB_WS_POS1.g_salary_dist(l_salary_index).percent := PSB_WS_POS1.g_salary_dist(l_salary_index).amount / l_ytd_amount * 100;
    end if;

  end loop;

  for c_Element_Cost_Rec in c_Element_Cost loop

    PSB_WS_POS1.g_num_pc_costs := PSB_WS_POS1.g_num_pc_costs + 1;

    PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).pay_element_id := c_Element_Cost_Rec.pay_element_id;
    PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).element_set_id := c_Element_Cost_Rec.element_set_id;
    PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).element_cost := c_Element_Cost_Rec.element_cost;
    PSB_WS_POS1.g_pc_costs(PSB_WS_POS1.g_num_pc_costs).budget_year_id := p_budget_year_id;

  end loop;

  for c_Element_Dist_Rec in c_Element_Dist loop

    PSB_WS_POS1.g_num_element_dist := PSB_WS_POS1.g_num_element_dist + 1;

    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).account_line_id := c_Element_Dist_Rec.account_line_id;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).ccid := c_Element_Dist_Rec.code_combination_id;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).ytd_amount := c_Element_Dist_Rec.ytd_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period1_amount := c_Element_Dist_Rec.period1_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period2_amount := c_Element_Dist_Rec.period2_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period3_amount := c_Element_Dist_Rec.period3_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period4_amount := c_Element_Dist_Rec.period4_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period5_amount := c_Element_Dist_Rec.period5_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period6_amount := c_Element_Dist_Rec.period6_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period7_amount := c_Element_Dist_Rec.period7_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period8_amount := c_Element_Dist_Rec.period8_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period9_amount := c_Element_Dist_Rec.period9_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period10_amount := c_Element_Dist_Rec.period10_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period11_amount := c_Element_Dist_Rec.period11_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period12_amount := c_Element_Dist_Rec.period12_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period13_amount := c_Element_Dist_Rec.period13_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period14_amount := c_Element_Dist_Rec.period14_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period15_amount := c_Element_Dist_Rec.period15_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period16_amount := c_Element_Dist_Rec.period16_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period17_amount := c_Element_Dist_Rec.period17_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period18_amount := c_Element_Dist_Rec.period18_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period19_amount := c_Element_Dist_Rec.period19_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period20_amount := c_Element_Dist_Rec.period20_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period21_amount := c_Element_Dist_Rec.period21_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period22_amount := c_Element_Dist_Rec.period22_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period23_amount := c_Element_Dist_Rec.period23_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period24_amount := c_Element_Dist_Rec.period24_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period25_amount := c_Element_Dist_Rec.period25_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period26_amount := c_Element_Dist_Rec.period26_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period27_amount := c_Element_Dist_Rec.period27_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period28_amount := c_Element_Dist_Rec.period28_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period29_amount := c_Element_Dist_Rec.period29_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period30_amount := c_Element_Dist_Rec.period30_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period31_amount := c_Element_Dist_Rec.period31_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period32_amount := c_Element_Dist_Rec.period32_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period33_amount := c_Element_Dist_Rec.period33_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period34_amount := c_Element_Dist_Rec.period34_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period35_amount := c_Element_Dist_Rec.period35_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period36_amount := c_Element_Dist_Rec.period36_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period37_amount := c_Element_Dist_Rec.period37_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period38_amount := c_Element_Dist_Rec.period38_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period39_amount := c_Element_Dist_Rec.period39_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period40_amount := c_Element_Dist_Rec.period40_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period41_amount := c_Element_Dist_Rec.period41_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period42_amount := c_Element_Dist_Rec.period42_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period43_amount := c_Element_Dist_Rec.period43_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period44_amount := c_Element_Dist_Rec.period44_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period45_amount := c_Element_Dist_Rec.period45_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period46_amount := c_Element_Dist_Rec.period46_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period47_amount := c_Element_Dist_Rec.period47_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period48_amount := c_Element_Dist_Rec.period48_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period49_amount := c_Element_Dist_Rec.period49_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period50_amount := c_Element_Dist_Rec.period50_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period51_amount := c_Element_Dist_Rec.period51_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period52_amount := c_Element_Dist_Rec.period52_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period53_amount := c_Element_Dist_Rec.period53_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period54_amount := c_Element_Dist_Rec.period54_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period55_amount := c_Element_Dist_Rec.period55_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period56_amount := c_Element_Dist_Rec.period56_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period57_amount := c_Element_Dist_Rec.period57_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period58_amount := c_Element_Dist_Rec.period58_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period59_amount := c_Element_Dist_Rec.period59_amount;
    PSB_WS_POS1.g_element_dist(PSB_WS_POS1.g_num_element_dist).period60_amount := c_Element_Dist_Rec.period60_amount;

  end loop;

  l_start_date := greatest(p_year_start_date, p_position_start_date);
  l_end_date := least(p_year_end_date, nvl(p_position_end_date, p_year_end_date));

  for l_element_index in 1..PSB_WS_POS1.g_num_elements loop

    if PSB_WS_POS1.g_elements(l_element_index).follow_salary = 'Y' then
    begin

      PSB_WS_POS1.Distribute_Following_Elements
	 (p_return_status => l_return_status,
	  p_redistribute => FND_API.G_TRUE,
	  p_pay_element_id => PSB_WS_POS1.g_elements(l_element_index).pay_element_id,
	  p_data_extract_id => p_data_extract_id,
	  p_flex_code => p_flex_code,
	  p_business_group_id => p_business_group_id,
	  p_rounding_factor => p_rounding_factor,
	  p_position_line_id => p_position_line_id,
	  p_position_id => p_position_id,
	  p_budget_year_id => p_budget_year_id,
	  p_start_date => l_start_date,
	  p_end_date => l_end_date);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  end loop;

  for l_pdist_index in 1..PSB_WS_POS1.g_num_pd_costs loop

    l_dist_index := null;

    for l_eldist_index in 1..PSB_WS_POS1.g_num_element_dist loop

      if PSB_WS_POS1.g_pd_costs(l_pdist_index).ccid = PSB_WS_POS1.g_element_dist(l_eldist_index).ccid then
	PSB_WS_POS1.g_element_dist(l_eldist_index).redist_flag := 'Y';
	l_dist_index := l_eldist_index;
	exit;
      end if;

    end loop;

    if l_dist_index is null then
    begin

      for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
	l_period_amount(l_init_index) := null;
      end loop;

      if PSB_WS_POS1.g_num_element_dist > 0 then
      begin

	l_period_amount(1) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period1_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(2) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period2_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(3) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period3_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(4) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period4_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(5) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period5_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(6) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period6_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(7) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period7_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(8) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period8_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(9) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period9_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(10) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period10_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(11) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period11_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(12) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period12_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(13) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period13_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(14) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period14_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(15) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period15_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(16) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period16_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(17) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period17_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(18) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period18_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(19) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period19_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(20) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period20_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(21) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period21_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(22) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period22_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(23) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period23_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(24) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period24_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(25) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period25_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(26) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period26_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(27) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period27_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(28) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period28_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(29) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period29_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(30) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period30_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(31) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period31_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(32) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period32_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(33) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period33_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(34) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period34_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(35) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period35_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(36) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period36_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(37) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period37_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(38) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period38_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(39) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period39_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(40) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period40_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(41) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period41_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(42) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period42_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(43) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period43_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(44) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period44_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(45) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period45_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(46) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period46_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(47) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period47_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(48) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period48_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(49) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period49_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(50) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period50_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(51) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period51_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(52) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period52_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(53) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period53_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(54) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period54_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(55) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period55_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(56) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period56_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(57) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period57_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(58) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period58_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(59) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period59_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;
	l_period_amount(60) := PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount *
					  PSB_WS_POS1.g_element_dist(1).period60_amount / PSB_WS_POS1.g_element_dist(1).ytd_amount;

      end;
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
	  p_budget_group_id => PSB_WS_POS1.g_salary_budget_group_id,
	  p_ccid => PSB_WS_POS1.g_pd_costs(l_pdist_index).ccid,
	  p_currency_code => p_func_currency,
	  p_balance_type => 'E',
	  p_ytd_amount => PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount,
	  p_period_amount => l_period_amount,
	  p_position_line_id => p_position_line_id,
	  p_element_set_id => PSB_WS_POS1.g_pd_costs(l_pdist_index).element_set_id,
	  p_service_package_id => p_service_package_id,
	  p_start_stage_seq => p_start_stage_seq,
	  p_current_stage_seq => p_current_stage_seq);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    else
    begin

      for l_init_index in 1..PSB_WS_ACCT1.g_max_num_amounts loop
	l_period_amount(l_init_index) := null;
      end loop;

      l_period_amount(1) := PSB_WS_POS1.g_element_dist(l_dist_index).period1_amount;
      l_period_amount(2) := PSB_WS_POS1.g_element_dist(l_dist_index).period2_amount;
      l_period_amount(3) := PSB_WS_POS1.g_element_dist(l_dist_index).period3_amount;
      l_period_amount(4) := PSB_WS_POS1.g_element_dist(l_dist_index).period4_amount;
      l_period_amount(5) := PSB_WS_POS1.g_element_dist(l_dist_index).period5_amount;
      l_period_amount(6) := PSB_WS_POS1.g_element_dist(l_dist_index).period6_amount;
      l_period_amount(7) := PSB_WS_POS1.g_element_dist(l_dist_index).period7_amount;
      l_period_amount(8) := PSB_WS_POS1.g_element_dist(l_dist_index).period8_amount;
      l_period_amount(9) := PSB_WS_POS1.g_element_dist(l_dist_index).period9_amount;
      l_period_amount(10) := PSB_WS_POS1.g_element_dist(l_dist_index).period10_amount;
      l_period_amount(11) := PSB_WS_POS1.g_element_dist(l_dist_index).period11_amount;
      l_period_amount(12) := PSB_WS_POS1.g_element_dist(l_dist_index).period12_amount;
      l_period_amount(13) := PSB_WS_POS1.g_element_dist(l_dist_index).period13_amount;
      l_period_amount(14) := PSB_WS_POS1.g_element_dist(l_dist_index).period14_amount;
      l_period_amount(15) := PSB_WS_POS1.g_element_dist(l_dist_index).period15_amount;
      l_period_amount(16) := PSB_WS_POS1.g_element_dist(l_dist_index).period16_amount;
      l_period_amount(17) := PSB_WS_POS1.g_element_dist(l_dist_index).period17_amount;
      l_period_amount(18) := PSB_WS_POS1.g_element_dist(l_dist_index).period18_amount;
      l_period_amount(19) := PSB_WS_POS1.g_element_dist(l_dist_index).period19_amount;
      l_period_amount(20) := PSB_WS_POS1.g_element_dist(l_dist_index).period20_amount;
      l_period_amount(21) := PSB_WS_POS1.g_element_dist(l_dist_index).period21_amount;
      l_period_amount(22) := PSB_WS_POS1.g_element_dist(l_dist_index).period22_amount;
      l_period_amount(23) := PSB_WS_POS1.g_element_dist(l_dist_index).period23_amount;
      l_period_amount(24) := PSB_WS_POS1.g_element_dist(l_dist_index).period24_amount;
      l_period_amount(25) := PSB_WS_POS1.g_element_dist(l_dist_index).period25_amount;
      l_period_amount(26) := PSB_WS_POS1.g_element_dist(l_dist_index).period26_amount;
      l_period_amount(27) := PSB_WS_POS1.g_element_dist(l_dist_index).period27_amount;
      l_period_amount(28) := PSB_WS_POS1.g_element_dist(l_dist_index).period28_amount;
      l_period_amount(29) := PSB_WS_POS1.g_element_dist(l_dist_index).period29_amount;
      l_period_amount(30) := PSB_WS_POS1.g_element_dist(l_dist_index).period30_amount;
      l_period_amount(31) := PSB_WS_POS1.g_element_dist(l_dist_index).period31_amount;
      l_period_amount(32) := PSB_WS_POS1.g_element_dist(l_dist_index).period32_amount;
      l_period_amount(33) := PSB_WS_POS1.g_element_dist(l_dist_index).period33_amount;
      l_period_amount(34) := PSB_WS_POS1.g_element_dist(l_dist_index).period34_amount;
      l_period_amount(35) := PSB_WS_POS1.g_element_dist(l_dist_index).period35_amount;
      l_period_amount(36) := PSB_WS_POS1.g_element_dist(l_dist_index).period36_amount;
      l_period_amount(37) := PSB_WS_POS1.g_element_dist(l_dist_index).period37_amount;
      l_period_amount(38) := PSB_WS_POS1.g_element_dist(l_dist_index).period38_amount;
      l_period_amount(39) := PSB_WS_POS1.g_element_dist(l_dist_index).period39_amount;
      l_period_amount(40) := PSB_WS_POS1.g_element_dist(l_dist_index).period40_amount;
      l_period_amount(41) := PSB_WS_POS1.g_element_dist(l_dist_index).period41_amount;
      l_period_amount(42) := PSB_WS_POS1.g_element_dist(l_dist_index).period42_amount;
      l_period_amount(43) := PSB_WS_POS1.g_element_dist(l_dist_index).period43_amount;
      l_period_amount(44) := PSB_WS_POS1.g_element_dist(l_dist_index).period44_amount;
      l_period_amount(45) := PSB_WS_POS1.g_element_dist(l_dist_index).period45_amount;
      l_period_amount(46) := PSB_WS_POS1.g_element_dist(l_dist_index).period46_amount;
      l_period_amount(47) := PSB_WS_POS1.g_element_dist(l_dist_index).period47_amount;
      l_period_amount(48) := PSB_WS_POS1.g_element_dist(l_dist_index).period48_amount;
      l_period_amount(49) := PSB_WS_POS1.g_element_dist(l_dist_index).period49_amount;
      l_period_amount(50) := PSB_WS_POS1.g_element_dist(l_dist_index).period50_amount;
      l_period_amount(51) := PSB_WS_POS1.g_element_dist(l_dist_index).period51_amount;
      l_period_amount(52) := PSB_WS_POS1.g_element_dist(l_dist_index).period52_amount;
      l_period_amount(53) := PSB_WS_POS1.g_element_dist(l_dist_index).period53_amount;
      l_period_amount(54) := PSB_WS_POS1.g_element_dist(l_dist_index).period54_amount;
      l_period_amount(55) := PSB_WS_POS1.g_element_dist(l_dist_index).period55_amount;
      l_period_amount(56) := PSB_WS_POS1.g_element_dist(l_dist_index).period56_amount;
      l_period_amount(57) := PSB_WS_POS1.g_element_dist(l_dist_index).period57_amount;
      l_period_amount(58) := PSB_WS_POS1.g_element_dist(l_dist_index).period58_amount;
      l_period_amount(59) := PSB_WS_POS1.g_element_dist(l_dist_index).period59_amount;
      l_period_amount(60) := PSB_WS_POS1.g_element_dist(l_dist_index).period60_amount;

      PSB_WS_ACCT1.Create_Account_Dist
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_worksheet_id => p_worksheet_id,
	  p_distribute_flag => FND_API.G_TRUE,
	  p_account_line_id => PSB_WS_POS1.g_element_dist(l_dist_index).account_line_id,
	  p_check_stages => FND_API.G_FALSE,
	  p_ytd_amount => PSB_WS_POS1.g_pd_costs(l_pdist_index).ytd_amount,
	  p_period_amount => l_period_amount,
	  p_budget_group_id => PSB_WS_POS1.g_salary_budget_group_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  end loop;

  for l_eldist_index in 1..PSB_WS_POS1.g_num_element_dist loop

    if PSB_WS_POS1.g_element_dist(l_eldist_index).redist_flag is null then
    begin

      PSB_WORKSHEET.Delete_WAL
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_account_line_id => PSB_WS_POS1.g_element_dist(l_eldist_index).account_line_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  end loop;

  PSB_WS_POS1.Update_Annual_FTE
     (p_api_version => 1.0,
      p_return_status => p_return_status,
      p_worksheet_id => p_worksheet_id,
      p_position_line_id => p_position_line_id,
      p_budget_year_id => p_budget_year_id,
      p_service_package_id => p_service_package_id,
      p_stage_set_id => p_stage_set_id,
      p_current_stage_seq => p_current_stage_seq,
      p_budget_group_id => PSB_WS_POS1.g_salary_budget_group_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
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
     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
 			      'Redist_Follow_Salary_Year');
     end if;

END Redist_Follow_Salary_Year;

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Element_Constraints
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id          IN   NUMBER,
  p_budget_calendar_id    IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_constraint_set_id     IN   NUMBER,
  p_constraint_set_name   IN   VARCHAR2,
  p_constraint_threshold  IN   NUMBER
) IS

  l_return_status         VARCHAR2(1);

  cursor c_Constraint is
    select constraint_id,
	   name,
	   currency_code,
	   severity_level,
	   effective_start_date,
	   effective_end_date
      from PSB_CONSTRAINT_ASSIGNMENTS_V
     where constraint_type = 'ELEMENT'
       and (((effective_start_date <= PSB_WS_ACCT1.g_end_est_date)
	 and (effective_end_date is null))
	 or ((effective_start_date between PSB_WS_ACCT1.g_startdate_cy and PSB_WS_ACCT1.g_end_est_date)
	  or (effective_end_date between PSB_WS_ACCT1.g_startdate_cy and PSB_WS_ACCT1.g_end_est_date)
	 or ((effective_start_date < PSB_WS_ACCT1.g_startdate_cy)
	 and (effective_end_date > PSB_WS_ACCT1.g_end_est_date))))
       and constraint_set_id = p_constraint_set_id;

BEGIN

  for c_Constraint_Rec in c_Constraint loop

    Process_ElemCons_Detailed
	   (p_return_status => l_return_status,
	    p_worksheet_id => p_worksheet_id,
	    p_data_extract_id => p_data_extract_id,
	    p_constraint_id => c_Constraint_Rec.constraint_id,
	    p_start_date => c_Constraint_Rec.effective_start_date,
	    p_end_date => nvl(c_Constraint_Rec.effective_end_date, PSB_WS_ACCT1.g_end_est_date));

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
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
     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
 			      'Apply_Element_Constraints');
     end if;

END Apply_Element_Constraints;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_ElemCons_Detailed
( p_return_status    OUT  NOCOPY  VARCHAR2,
  p_worksheet_id     IN   NUMBER,
  p_data_extract_id  IN   NUMBER,
  p_constraint_id    IN   NUMBER,
  p_start_date       IN   DATE,
  p_end_date         IN   DATE
) IS

  l_posasgn_id       NUMBER;
  l_rowid            VARCHAR2(100);

  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);

  l_return_status    VARCHAR2(1);

  cursor c_Formula is
    select pay_element_id,
	   pay_element_option_id,
	   nvl(effective_start_date, p_start_date) effective_start_date,
	   nvl(effective_end_date, p_end_date) effective_end_date,
	   allow_modify
      from PSB_CONSTRAINT_FORMULAS
     where constraint_id = p_constraint_id
     order by step_number;

  cursor c_Positions is
    select a.position_id
      from PSB_BUDGET_POSITIONS a,
	   PSB_SET_RELATIONS b
     where a.data_extract_id = p_data_extract_id
       and a.account_position_set_id = b.account_position_set_id
       and b.constraint_id = p_constraint_id;

BEGIN

  for c_Formula_Rec in c_Formula loop

    if c_Formula_Rec.allow_modify = 'N' then
    begin

      for c_Positions_Rec in c_Positions loop

	PSB_POSITIONS_PVT.Modify_Assignment
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_position_assignment_id => l_posasgn_id,
	    p_data_extract_id => p_data_extract_id,
	    p_worksheet_id => p_worksheet_id,
	    p_position_id => c_Positions_Rec.position_id,
	    p_assignment_type => 'ELEMENT',
	    p_attribute_id => null,
	    p_attribute_value_id => null,
	    p_attribute_value => null,
	    p_pay_element_id => c_Formula_Rec.pay_element_id,
	    p_pay_element_option_id => c_Formula_Rec.pay_element_option_id,
	    p_effective_start_date => c_Formula_Rec.effective_start_date,
	    p_effective_end_date => c_Formula_Rec.effective_end_date,
	    p_element_value_type => null,
	    p_element_value => null,
	    p_currency_code => null,
	    p_pay_basis => null,
	    p_global_default_flag => null,
	    p_assignment_default_rule_id => null,
	    p_modify_flag => c_Formula_Rec.allow_modify,
	    p_rowid => l_rowid,
	    p_employee_id => null,
	    p_primary_employee_flag => null);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end loop;

    end;
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
     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
 			      'Process_ElemCons_Detailed');
     end if;

END Process_ElemCons_Detailed;

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Position_Constraints
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_validation_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id          IN   NUMBER,
  p_budget_calendar_id    IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_business_group_id     IN   NUMBER,
  p_func_currency         IN   VARCHAR2,
  p_constraint_set_id     IN   NUMBER,
  p_constraint_set_name   IN   VARCHAR2,
  p_constraint_threshold  IN   NUMBER
) IS

  l_year_index                 BINARY_INTEGER;

  l_cons_validation_status     VARCHAR2(1);
  l_consset_validation_status  VARCHAR2(1) := 'S';

  l_sp_exists                  VARCHAR2(1) := FND_API.G_FALSE;

  l_return_status              VARCHAR2(1);

  cursor c_Constraint (Year_Start_Date DATE,
		       Year_End_Date DATE) is
    select constraint_id,
	   name,
	   currency_code,
	   severity_level,
	   fte_constraint,
	   effective_start_date,
	   effective_end_date,
	   constraint_detailed_flag
      from PSB_CONSTRAINT_ASSIGNMENTS_V
     where constraint_type = 'POSITION'
       and (((effective_start_date <= Year_End_Date)
	 and (effective_end_date is null))
	 or ((effective_start_date between Year_Start_Date and Year_End_Date)
	  or (effective_end_date between Year_Start_Date and Year_End_Date)
	 or ((effective_start_date < Year_Start_Date)
	 and (effective_end_date > Year_End_Date))))
       and constraint_set_id = p_constraint_set_id
     order by severity_level desc;

  -- Check whether Constraints should be applied for specific Service Packages

  cursor c_SP is
    select 'x'
      from dual
     where exists
	  (select 'Service Package Exists'
	     from PSB_WS_SUBMIT_SERVICE_PACKAGES
	    where worksheet_id = p_worksheet_id);

BEGIN

  for c_SP_Rec in c_SP loop
    l_sp_exists := FND_API.G_TRUE;
  end loop;

  for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

    if PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP') then
    begin

      for c_Constraint_Rec in c_Constraint (PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
					    PSB_WS_ACCT1.g_budget_years(l_year_index).end_date) loop

	if ((c_Constraint_Rec.constraint_detailed_flag is null) or
	    (c_Constraint_Rec.constraint_detailed_flag = 'N')) then
	begin

	  if ((c_Constraint_Rec.fte_constraint is null) or (c_Constraint_Rec.fte_constraint = 'N')) then
	  begin

	    Process_PosCons
		   (p_worksheet_id => p_worksheet_id,
		    p_data_extract_id => p_data_extract_id,
		    p_business_group_id => p_business_group_id,
		    p_sp_exists => l_sp_exists,
		    p_constraint_set_name => p_constraint_set_name,
		    p_constraint_threshold => p_constraint_threshold,
		    p_constraint_id => c_Constraint_Rec.constraint_id,
		    p_constraint_name => c_Constraint_Rec.name,
		    p_budget_year_id => PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id,
		    p_budget_year_name => PSB_WS_ACCT1.g_budget_years(l_year_index).year_name,
		    p_year_start_date => PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
		    p_year_end_date => PSB_WS_ACCT1.g_budget_years(l_year_index).end_date,
		    p_currency_code => nvl(c_Constraint_Rec.currency_code, p_func_currency),
		    p_severity_level => c_Constraint_Rec.severity_level,
		    p_summ_flag => FND_API.G_TRUE,
		    p_constraint_validation_status => l_cons_validation_status,
		    p_return_status => l_return_status);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;

	  end;
	  else
	  begin

	    Process_FTECons
		   (p_worksheet_id => p_worksheet_id,
		    p_data_extract_id => p_data_extract_id,
		    p_sp_exists => l_sp_exists,
		    p_constraint_set_name => p_constraint_set_name,
		    p_constraint_threshold => p_constraint_threshold,
		    p_constraint_id => c_Constraint_Rec.constraint_id,
		    p_constraint_name => c_Constraint_Rec.name,
		    p_budget_year_id => PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id,
		    p_budget_year_name => PSB_WS_ACCT1.g_budget_years(l_year_index).year_name,
		    p_currency_code => nvl(c_Constraint_Rec.currency_code, p_func_currency),
		    p_severity_level => c_Constraint_Rec.severity_level,
		    p_summ_flag => FND_API.G_TRUE,
		    p_constraint_validation_status => l_cons_validation_status,
		    p_return_status => l_return_status);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;

	  end;
	  end if;

	  if ((l_consset_validation_status = 'S') and
	      (l_cons_validation_status <> 'S')) then
	    l_consset_validation_status := l_cons_validation_status;
	  elsif ((l_consset_validation_status = 'E') and
		 (l_cons_validation_status = 'F')) then
	    l_consset_validation_status := l_cons_validation_status;
	  elsif ((l_consset_validation_status = 'W') and
		 (l_cons_validation_status in ('F', 'E'))) then
	    l_consset_validation_status := l_cons_validation_status;
	  end if;

	end;
	else
	begin

	  Process_PosCons_Detailed
		 (p_return_status => l_return_status,
		  p_constraint_validation_status => l_cons_validation_status,
		  p_worksheet_id => p_worksheet_id,
		  p_data_extract_id => p_data_extract_id,
		  p_business_group_id => p_business_group_id,
		  p_sp_exists => l_sp_exists,
		  p_constraint_set_name => p_constraint_set_name,
		  p_constraint_threshold => p_constraint_threshold,
		  p_constraint_id => c_Constraint_Rec.constraint_id,
		  p_constraint_name => c_Constraint_Rec.name,
		  p_fte_constraint => c_Constraint_Rec.fte_constraint,
		  p_budget_year_id => PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id,
		  p_budget_year_name => PSB_WS_ACCT1.g_budget_years(l_year_index).year_name,
		  p_year_start_date => PSB_WS_ACCT1.g_budget_years(l_year_index).start_date,
		  p_year_end_date => PSB_WS_ACCT1.g_budget_years(l_year_index).end_date,
		  p_currency_code => nvl(c_Constraint_Rec.currency_code, p_func_currency),
		  p_severity_level => c_Constraint_Rec.severity_level);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  if ((l_consset_validation_status = 'S') and
	      (l_cons_validation_status <> 'S')) then
	    l_consset_validation_status := l_cons_validation_status;
	  elsif ((l_consset_validation_status = 'E') and
		 (l_cons_validation_status = 'F')) then
	    l_consset_validation_status := l_cons_validation_status;
	  elsif ((l_consset_validation_status = 'W') and
		 (l_cons_validation_status in ('F', 'E'))) then
	    l_consset_validation_status := l_cons_validation_status;
	  end if;

	end;
	end if;

      end loop;

    end;
    end if;

  end loop;


  -- Initialize API return status to success

  p_validation_status := l_consset_validation_status;
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
     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
 			      'Apply_Position_Constraints');
     end if;

END Apply_Position_Constraints;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_PosCons_Detailed
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_worksheet_id                  IN   NUMBER,
  p_data_extract_id               IN   NUMBER,
  p_business_group_id             IN   NUMBER,
  p_sp_exists                     IN   VARCHAR2,
  p_constraint_set_name           IN   VARCHAR2,
  p_constraint_threshold          IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_fte_constraint                IN   VARCHAR2,
  p_budget_year_id                IN   NUMBER,
  p_budget_year_name              IN   VARCHAR2,
  p_year_start_date               IN   DATE,
  p_year_end_date                 IN   DATE,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER
) IS

  l_cons_validation_status        VARCHAR2(1) := 'S';
  l_detailed_status               VARCHAR2(1);

  l_return_status                 VARCHAR2(1);

  cursor c_Positions is
    select d.position_id,
	   c.name,
	   a.position_line_id
      from PSB_WS_LINES_POSITIONS a,
	   PSB_WS_POSITION_LINES b,
	   PSB_POSITIONS c,
	   PSB_BUDGET_POSITIONS d,
	   PSB_SET_RELATIONS e
     where a.position_line_id = b.position_line_id
       and a.worksheet_id = p_worksheet_id
       and b.position_id = c.position_id
       and c.position_id = d.position_id
       and d.data_extract_id = p_data_extract_id
       and d.account_position_set_id = e.account_position_set_id
       and e.constraint_id = p_constraint_id;

BEGIN

  for c_Positions_Rec in c_Positions loop

    if ((p_fte_constraint is null) or (p_fte_constraint = 'N')) then
    begin

      Process_PosCons
	     (p_worksheet_id => p_worksheet_id,
	      p_data_extract_id => p_data_extract_id,
	      p_business_group_id => p_business_group_id,
	      p_sp_exists => p_sp_exists,
	      p_constraint_set_name => p_constraint_set_name,
	      p_constraint_threshold => p_constraint_threshold,
	      p_constraint_id => p_constraint_id,
	      p_constraint_name => p_constraint_name,
	      p_position_line_id => c_Positions_Rec.position_line_id,
	      p_position_id => c_Positions_Rec.position_id,
	      p_position_name => c_Positions_Rec.name,
	      p_budget_year_id => p_budget_year_id,
	      p_budget_year_name => p_budget_year_name,
	      p_year_start_date => p_year_start_date,
	      p_year_end_date => p_year_end_date,
	      p_currency_code => p_currency_code,
	      p_severity_level => p_severity_level,
	      p_summ_flag => FND_API.G_FALSE,
	      p_constraint_validation_status => l_detailed_status,
	      p_return_status => l_return_status);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    else
    begin

      Process_FTECons
	     (p_worksheet_id => p_worksheet_id,
	      p_data_extract_id => p_data_extract_id,
	      p_sp_exists => p_sp_exists,
	      p_constraint_set_name => p_constraint_set_name,
	      p_constraint_threshold => p_constraint_threshold,
	      p_constraint_id => p_constraint_id,
	      p_constraint_name => p_constraint_name,
	      p_position_line_id => c_Positions_Rec.position_line_id,
	      p_position_id => c_Positions_Rec.position_id,
	      p_position_name => c_Positions_Rec.name,
	      p_budget_year_id => p_budget_year_id,
	      p_budget_year_name => p_budget_year_name,
	      p_currency_code => p_currency_code,
	      p_severity_level => p_severity_level,
	      p_summ_flag => FND_API.G_FALSE,
	      p_constraint_validation_status => l_detailed_status,
	      p_return_status => l_return_status);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

    if ((l_cons_validation_status = 'S') and
	(l_detailed_status <> 'S')) then
      l_cons_validation_status := l_detailed_status;
    elsif ((l_cons_validation_status = 'E') and
	   (l_detailed_status = 'F')) then
      l_cons_validation_status := l_detailed_status;
    end if;

  end loop;


  -- Initialize API return status to success

  p_constraint_validation_status := l_cons_validation_status;
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
     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
 			      'Process_PosCons_Detailed');
     end if;

END Process_PosCons_Detailed;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_PosCons
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_worksheet_id                  IN   NUMBER,
  p_data_extract_id               IN   NUMBER,
  p_business_group_id             IN   NUMBER,
  p_sp_exists                     IN   VARCHAR2,
  p_constraint_set_name           IN   VARCHAR2,
  p_constraint_threshold          IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_position_line_id              IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_id                   IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_name                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_year_id                IN   NUMBER,
  p_budget_year_name              IN   VARCHAR2,
  p_year_start_date               IN   DATE,
  p_year_end_date                 IN   DATE,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER,
  p_summ_flag                     IN   VARCHAR2
) IS

  l_cons_validation_status        VARCHAR2(1) := 'S';
  l_detailed_status               VARCHAR2(1);

  l_return_status                 VARCHAR2(1);

  cursor c_Formula is
    select pay_element_id,
	   pay_element_option_id,
	   prefix_operator,
	   nvl(currency_code, p_currency_code) currency_code,
	   element_value_type,
	   element_value
      from PSB_CONSTRAINT_FORMULAS
     where constraint_id = p_constraint_id
     order by step_number;

BEGIN

  for c_Formula_Rec in c_Formula loop

    Process_PosCons_Step
	   (p_return_status => l_return_status,
	    p_constraint_validation_status => l_detailed_status,
	    p_worksheet_id => p_worksheet_id,
	    p_data_extract_id => p_data_extract_id,
	    p_business_group_id => p_business_group_id,
	    p_sp_exists => p_sp_exists,
	    p_constraint_set_name => p_constraint_set_name,
	    p_constraint_threshold => p_constraint_threshold,
	    p_constraint_id => p_constraint_id,
	    p_constraint_name => p_constraint_name,
	    p_position_line_id => p_position_line_id,
	    p_position_id => p_position_id,
	    p_position_name => p_position_name,
	    p_budget_year_id => p_budget_year_id,
	    p_budget_year_name => p_budget_year_name,
	    p_year_start_date => p_year_start_date,
	    p_year_end_date => p_year_end_date,
	    p_currency_code => c_Formula_Rec.currency_code,
	    p_severity_level => p_severity_level,
	    p_summ_flag => p_summ_flag,
	    p_pay_element_id => c_Formula_Rec.pay_element_id,
	    p_pay_element_option_id => c_Formula_Rec.pay_element_option_id,
	    p_prefix_operator => c_Formula_Rec.prefix_operator,
	    p_element_value_type => c_Formula_Rec.element_value_type,
	    p_element_value => c_Formula_Rec.element_value);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    if ((l_cons_validation_status = 'S') and
	(l_detailed_status <> 'S')) then
      l_cons_validation_status := l_detailed_status;
    elsif ((l_cons_validation_status = 'E') and
	   (l_detailed_status = 'F')) then
      l_cons_validation_status := l_detailed_status;
    end if;

  end loop;


  -- Initialize API return status to success

  p_constraint_validation_status := l_cons_validation_status;
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
     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
 			      'Process_PosCons');
     end if;

END Process_PosCons;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_PosCons_Step
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_worksheet_id                  IN   NUMBER,
  p_data_extract_id               IN   NUMBER,
  p_business_group_id             IN   NUMBER,
  p_sp_exists                     IN   VARCHAR2,
  p_constraint_set_name           IN   VARCHAR2,
  p_constraint_threshold          IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_position_line_id              IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_id                   IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_name                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_year_id                IN   NUMBER,
  p_budget_year_name              IN   VARCHAR2,
  p_year_start_date               IN   DATE,
  p_year_end_date                 IN   DATE,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER,
  p_summ_flag                     IN   VARCHAR2,
  p_pay_element_id                IN   NUMBER,
  p_pay_element_option_id         IN   NUMBER,
  p_prefix_operator               IN   VARCHAR2,
  p_element_value_type            IN   VARCHAR2,
  p_element_value                 IN   NUMBER
) IS

  l_cons_failed                   VARCHAR2(1) := FND_API.G_FALSE;

  l_salary_total                  NUMBER := 0;
  l_posset_total                  NUMBER := 0;
  l_cons_total                    NUMBER := 0;

  l_reqid                         NUMBER;
  l_userid                        NUMBER;
  l_description                   VARCHAR2(2000);

  l_grade_name                    VARCHAR2(80);
  l_grade_step                    NUMBER;

  cursor c_Grade is
    select name grade_name,
	   grade_step
      from PSB_PAY_ELEMENT_OPTIONS
     where pay_element_option_id = p_pay_element_option_id;

  cursor c_SalaryNeqAll is
    select a.name position_name,
	   b.name,
	   b.grade_step
      from PSB_POSITIONS a,
	   PSB_PAY_ELEMENT_OPTIONS b,
	   PSB_POSITION_ASSIGNMENTS c
     where exists
	  (select 1
	     from PSB_BUDGET_POSITIONS d,
		  PSB_SET_RELATIONS e
	    where d.data_extract_id = p_data_extract_id
	      and d.position_id = c.position_id
	      and d.account_position_set_id = e.account_position_set_id
	      and e.constraint_id = p_constraint_id)
       and a.position_id = c.position_id
       and b.pay_element_option_id = c.pay_element_option_id
       and c.pay_element_option_id <> p_pay_element_option_id
       and ((c.worksheet_id is null) or (c.worksheet_id = p_worksheet_id))
       and (((c.effective_start_date <= p_year_start_date)
	 and (c.effective_end_date is null))
	 or ((c.effective_start_date between p_year_start_date and p_year_end_date)
	  or (c.effective_end_date between p_year_start_date and p_year_end_date)
	 or ((c.effective_start_date < p_year_start_date)
	 and (c.effective_end_date > p_year_end_date))))
       and c.pay_element_id = p_pay_element_id;

  cursor c_SalaryNeq is
    select a.name,
	   a.grade_step
      from PSB_PAY_ELEMENT_OPTIONS a,
	   PSB_POSITION_ASSIGNMENTS b
     where a.pay_element_option_id = b.pay_element_option_id
       and b.pay_element_option_id <> p_pay_element_option_id
       and (((b.effective_start_date <= p_year_start_date)
	 and (b.effective_end_date is null))
	 or ((b.effective_start_date between p_year_start_date and p_year_end_date)
	  or (b.effective_end_date between p_year_start_date and p_year_end_date)
	 or ((b.effective_start_date < p_year_start_date)
	 and (b.effective_end_date > p_year_end_date))))
       and b.pay_element_id = p_pay_element_id
       and b.position_id = p_position_id;

  cursor c_SumAll is
    select sum(nvl(a.element_cost, 0)) Sum_Elem
      from PSB_WS_ELEMENT_LINES a,
	   PSB_WORKSHEETS b
     where exists
	  (select 1
	     from PSB_WS_LINES_POSITIONS c,
		  PSB_WS_POSITION_LINES d,
		  PSB_BUDGET_POSITIONS e,
		  PSB_SET_RELATIONS f
	    where c.position_line_id = a.position_line_id
	      and c.position_line_id = d.position_line_id
	      and c.worksheet_id = p_worksheet_id
	      and d.position_id = e.position_id
	      and e.data_extract_id = p_data_extract_id
	      and e.account_position_set_id = f.account_position_set_id
	      and f.constraint_id = p_constraint_id)
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.currency_code = p_currency_code
       and a.stage_set_id = b.stage_set_id
       and a.budget_year_id = p_budget_year_id
       and a.pay_element_id = p_pay_element_id
       and b.worksheet_id = p_worksheet_id;

  cursor c_SumAll_Salary is
    select sum(nvl(a.element_cost, 0)) Sum_Elem
      from PSB_WS_ELEMENT_LINES a,
	   PSB_WORKSHEETS b,
	   PSB_PAY_ELEMENTS c
     where exists
	  (select 1
	     from PSB_WS_LINES_POSITIONS d,
		  PSB_WS_POSITION_LINES e,
		  PSB_BUDGET_POSITIONS f,
		  PSB_SET_RELATIONS g
	    where d.position_line_id = a.position_line_id
	      and d.position_line_id = e.position_line_id
	      and d.worksheet_id = p_worksheet_id
	      and e.position_id = f.position_id
	      and f.data_extract_id = p_data_extract_id
	      and f.account_position_set_id = g.account_position_set_id
	      and g.constraint_id = p_constraint_id)
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.currency_code = p_currency_code
       and a.stage_set_id = b.stage_set_id
       and a.budget_year_id = p_budget_year_id
       and a.pay_element_id = c.pay_element_id
       and b.worksheet_id = p_worksheet_id
       and c.processing_type = 'R'
       and c.salary_flag = 'Y'
       and c.business_group_id = p_business_group_id
       and c.data_extract_id = p_data_extract_id;

  cursor c_SumAllSP is
    select sum(nvl(a.element_cost, 0)) Sum_Elem
      from PSB_WS_ELEMENT_LINES a,
	   PSB_WORKSHEETS b
     where exists
	  (select 1
	     from PSB_WS_LINES_POSITIONS c,
		  PSB_WS_POSITION_LINES d,
		  PSB_BUDGET_POSITIONS e,
		  PSB_SET_RELATIONS f
	    where c.position_line_id = a.position_line_id
	      and c.position_line_id = d.position_line_id
	      and c.worksheet_id = p_worksheet_id
	      and d.position_id = e.position_id
	      and e.data_extract_id = p_data_extract_id
	      and e.account_position_set_id = f.account_position_set_id
	      and f.constraint_id = p_constraint_id)
       and exists
	  (select 1
	     from PSB_WS_SUBMIT_SERVICE_PACKAGES g
	    where g.service_package_id = a.service_package_id
	      and g.worksheet_id = p_worksheet_id)
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.currency_code = p_currency_code
       and a.stage_set_id = b.stage_set_id
       and a.budget_year_id = p_budget_year_id
       and a.pay_element_id = p_pay_element_id
       and b.worksheet_id = p_worksheet_id;

  cursor c_SumAllSP_Salary is
    select sum(nvl(a.element_cost, 0)) Sum_Elem
      from PSB_WS_ELEMENT_LINES a,
	   PSB_WORKSHEETS b,
	   PSB_PAY_ELEMENTS c
     where exists
	  (select 1
	     from PSB_WS_LINES_POSITIONS d,
		  PSB_WS_POSITION_LINES e,
		  PSB_BUDGET_POSITIONS f,
		  PSB_SET_RELATIONS g
	    where d.position_line_id = a.position_line_id
	      and d.position_line_id = e.position_line_id
	      and d.worksheet_id = p_worksheet_id
	      and e.position_id = f.position_id
	      and f.data_extract_id = p_data_extract_id
	      and f.account_position_set_id = g.account_position_set_id
	      and g.constraint_id = p_constraint_id)
       and exists
	  (select 1
	     from PSB_WS_SUBMIT_SERVICE_PACKAGES h
	    where h.service_package_id = a.service_package_id
	      and h.worksheet_id = p_worksheet_id)
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.currency_code = p_currency_code
       and a.stage_set_id = b.stage_set_id
       and a.budget_year_id = p_budget_year_id
       and a.pay_element_id = c.pay_element_id
       and b.worksheet_id = p_worksheet_id
       and c.processing_type = 'R'
       and c.salary_flag = 'Y'
       and c.business_group_id = p_business_group_id
       and c.data_extract_id = p_data_extract_id;

  cursor c_Sum is
    select /*+ ORDERED USE_NL(b a) INDEX(b PSB_WORKSHEETS_U1) INDEX(a PSB_WS_ELEMENT_LINES_N1) */
	   sum(nvl(a.element_cost, 0)) Sum_Elem
      from PSB_WS_ELEMENT_LINES a,
	   PSB_WORKSHEETS b
     where a.currency_code = p_currency_code
       and a.stage_set_id = b.stage_set_id
       and a.pay_element_id = p_pay_element_id
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.budget_year_id = p_budget_year_id
       and a.position_line_id = p_position_line_id
       and b.worksheet_id = p_worksheet_id;

  cursor c_Sum_Salary is
    select /*+ ORDERED INDEX(a PSB_WS_ELEMENT_LINES_N1) */
	   sum(nvl(a.element_cost, 0)) Sum_Elem
      from PSB_WS_ELEMENT_LINES a,
	   PSB_WORKSHEETS b,
	   PSB_PAY_ELEMENTS c
     where a.currency_code = p_currency_code
       and a.stage_set_id = b.stage_set_id
       and a.pay_element_id = c.pay_element_id
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.budget_year_id = p_budget_year_id
       and a.position_line_id = p_position_line_id
       and b.worksheet_id = p_worksheet_id
       and c.processing_type = 'R'
       and c.salary_flag = 'Y'
       and c.business_group_id = p_business_group_id
       and c.data_extract_id = p_data_extract_id;

  cursor c_SumSP is
    select /*+ ORDERED USE_NL(b a) INDEX(b PSB_WORKSHEETS_U1) INDEX(a PSB_WS_ELEMENT_LINES_N1) */
	   sum(nvl(a.element_cost, 0)) Sum_Elem
      from PSB_WS_ELEMENT_LINES a,
	   PSB_WORKSHEETS b
     where exists
	  (select 1
	     from PSB_WS_SUBMIT_SERVICE_PACKAGES d
	    where d.service_package_id = a.service_package_id
	      and d.worksheet_id = p_worksheet_id)
       and a.currency_code = p_currency_code
       and a.stage_set_id = b.stage_set_id
       and a.pay_element_id = p_pay_element_id
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.budget_year_id = p_budget_year_id
       and a.position_line_id = p_position_line_id
       and b.worksheet_id = p_worksheet_id;

  cursor c_SumSP_Salary is
    select /*+ ORDERED INDEX(a PSB_WS_ELEMENT_LINES_N1) */
	   sum(nvl(a.element_cost, 0)) Sum_Elem
      from PSB_WS_ELEMENT_LINES a,
	   PSB_WORKSHEETS b,
	   PSB_PAY_ELEMENTS c
     where exists
	  (select 1
	     from PSB_WS_SUBMIT_SERVICE_PACKAGES d
	    where d.service_package_id = a.service_package_id
	      and d.worksheet_id = p_worksheet_id)
       and a.currency_code = p_currency_code
       and a.stage_set_id = b.stage_set_id
       and a.pay_element_id = c.pay_element_id
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.budget_year_id = p_budget_year_id
       and a.position_line_id = p_position_line_id
       and b.worksheet_id = p_worksheet_id
       and c.processing_type = 'R'
       and c.salary_flag = 'Y'
       and c.business_group_id = p_business_group_id
       and c.data_extract_id = p_data_extract_id;

BEGIN

  if not FND_API.to_Boolean(p_summ_flag) then
  begin

    if FND_API.to_Boolean(p_sp_exists) then
    begin

      if p_pay_element_option_id is null then
      begin

	for c_Sum_Rec in c_SumSP loop
	  l_posset_total := c_Sum_Rec.Sum_Elem;
	end loop;

	if p_element_value_type = 'PS' then
	begin

	  for c_Sum_Salary_Rec in c_SumSP_Salary loop
	    l_salary_total := c_Sum_Salary_Rec.Sum_Elem;
	  end loop;

	end;
	end if;

      end;
      end if;

    end;
    else
    begin

      if p_pay_element_option_id is null then
      begin

	for c_Sum_Rec in c_Sum loop
	  l_posset_total := c_Sum_Rec.Sum_Elem;
	end loop;

	if p_element_value_type = 'PS' then
	begin

	  for c_Sum_Salary_Rec in c_Sum_Salary loop
	    l_salary_total := c_Sum_Salary_Rec.Sum_Elem;
	  end loop;

	end;
	end if;

      end;
      end if;

    end;
    end if;

    if p_pay_element_option_id is not null then
    begin

      for c_Grade_Rec in c_Grade loop
	l_grade_name := c_Grade_Rec.grade_name;
	l_grade_step := c_Grade_Rec.grade_step;
      end loop;

      if p_prefix_operator = '<>' then
      begin

	l_userid := FND_GLOBAL.USER_ID;
	l_reqid := FND_GLOBAL.CONC_REQUEST_ID;

	for c_SalaryNeq_Rec in c_SalaryNeq loop

	  message_token('CONSTRAINT_SET', p_constraint_set_name);
	  message_token('THRESHOLD', p_constraint_threshold);
	  message_token('CONSTRAINT', p_constraint_name);
	  message_token('SEVERITY_LEVEL', p_severity_level);
	  message_token('ASSIGNMENT_VALUE', c_SalaryNeq_Rec.name || ' ' || c_SalaryNeq_Rec.grade_step);
	  message_token('OPERATOR', p_prefix_operator);
	  message_token('FORMULA_VALUE', l_grade_name || ' ' || l_grade_step);
	  message_token('NAME', p_position_name);
	  message_token('YEAR', p_budget_year_name);
	  add_message('PSB', 'PSB_CONSTRAINT_FAILURE');

	  l_description := FND_MSG_PUB.Get
			      (p_encoded => FND_API.G_FALSE);
	  FND_MSG_PUB.Delete_Msg;

	  insert into PSB_ERROR_MESSAGES
		     (Concurrent_Request_ID,
		      Process_ID,
		      Source_Process,
		      Description,
		      Creation_Date,
		      Created_By)
	      values (l_reqid,
		      p_worksheet_id,
		      'WORKSHEET_CREATION',
		      l_description,
		      sysdate,
		      l_userid);

	  if nvl(p_severity_level, -1) >= p_constraint_threshold then
	    p_constraint_validation_status := 'F';
	  else
	    p_constraint_validation_status := 'E';
	  end if;

	end loop;

      end;
      end if;

    end;
    end if;

  end;
  else
  begin

    if FND_API.to_Boolean(p_sp_exists) then
    begin

      if p_pay_element_option_id is null then
      begin

	for c_SumAll_Rec in c_SumAllSP loop
	  l_posset_total := c_SumAll_Rec.Sum_Elem;
	end loop;

	if p_element_value_type = 'PS' then
	begin

	  for c_SumAll_Salary_Rec in c_SumAllSP_Salary loop
	    l_salary_total := c_SumAll_Salary_Rec.Sum_Elem;
	  end loop;

	end;
	end if;

      end;
      end if;

    end;
    else
    begin

      if p_pay_element_option_id is null then
      begin

	for c_SumAll_Rec in c_SumAll loop
	  l_posset_total := c_SumAll_Rec.Sum_Elem;
	end loop;

	if p_element_value_type = 'PS' then
	begin

	  for c_SumAll_Salary_Rec in c_SumAll_Salary loop
	    l_salary_total := c_SumAll_Salary_Rec.Sum_Elem;
	  end loop;

	end;
	end if;

      end;
      end if;

    end;
    end if;

    if p_pay_element_option_id is not null then
    begin

      for c_Grade_Rec in c_Grade loop
	l_grade_name := c_Grade_Rec.grade_name;
	l_grade_step := c_Grade_Rec.grade_step;
      end loop;

      if p_prefix_operator = '<>' then
      begin

	l_userid := FND_GLOBAL.USER_ID;
	l_reqid := FND_GLOBAL.CONC_REQUEST_ID;

	for c_SalaryNeqAll_Rec in c_SalaryNeqAll loop

	  message_token('CONSTRAINT_SET', p_constraint_set_name);
	  message_token('THRESHOLD', p_constraint_threshold);
	  message_token('CONSTRAINT', p_constraint_name);
	  message_token('SEVERITY_LEVEL', p_severity_level);
	  message_token('ASSIGNMENT_VALUE', c_SalaryNeqAll_Rec.name || ' ' || c_SalaryNeqAll_Rec.grade_step);
	  message_token('OPERATOR', p_prefix_operator);
	  message_token('FORMULA_VALUE', l_grade_name || ' ' || l_grade_step);
	  message_token('NAME', c_SalaryNeqAll_Rec.position_name);
	  message_token('YEAR', p_budget_year_name);
	  add_message('PSB', 'PSB_CONSTRAINT_FAILURE');

	  l_description := FND_MSG_PUB.Get
			      (p_encoded => FND_API.G_FALSE);
	  FND_MSG_PUB.Delete_Msg;

	  insert into PSB_ERROR_MESSAGES
		     (Concurrent_Request_ID,
		      Process_ID,
		      Source_Process,
		      Description,
		      Creation_Date,
		      Created_By)
	      values (l_reqid,
		      p_worksheet_id,
		      'WORKSHEET_CREATION',
		      l_description,
		      sysdate,
		      l_userid);

	  if nvl(p_severity_level, -1) >= p_constraint_threshold then
	    p_constraint_validation_status := 'F';
	  else
	    p_constraint_validation_status := 'E';
	  end if;

	end loop;

      end;
      end if;

    end;
    end if;

  end;
  end if;

  if p_element_value_type = 'PS' then
  begin
    /* Bug 3786457 Start */
    /* if p_element_value < 1 then
        l_cons_total := p_element_value * l_salary_total;
       else
        l_cons_total := p_element_value * l_salary_total / 100;
       end if; */
       l_cons_total := p_element_value * l_salary_total / 100;
    /* Bug 3786457 End */

  end;
  elsif p_element_value_type = 'A' then
    l_cons_total := p_element_value;
  end if;

  if l_posset_total is not null then
  begin

    if p_prefix_operator = '<=' then

      if l_posset_total <= l_cons_total then
	l_cons_failed := FND_API.G_TRUE;
      end if;

    elsif p_prefix_operator = '>=' then

      if l_posset_total >= l_cons_total then
	l_cons_failed := FND_API.G_TRUE;
      end if;

    elsif p_prefix_operator = '<' then

      if l_posset_total < l_cons_total then
	l_cons_failed := FND_API.G_TRUE;
      end if;

    elsif p_prefix_operator = '>' then

      if l_posset_total > l_cons_total then
	l_cons_failed := FND_API.G_TRUE;
      end if;

    elsif p_prefix_operator = '=' then

      if l_posset_total = l_cons_total then
	l_cons_failed := FND_API.G_TRUE;
      end if;

    elsif p_prefix_operator = '<>' then

      if l_posset_total <> l_cons_total then
	l_cons_failed := FND_API.G_TRUE;
      end if;

    end if;

  end;
  end if;

  if FND_API.to_Boolean(l_cons_failed) then
  begin

    if nvl(p_severity_level, -1) >= p_constraint_threshold then
      p_constraint_validation_status := 'F';
    else
      p_constraint_validation_status := 'E';
    end if;

    l_userid := FND_GLOBAL.USER_ID;
    l_reqid := FND_GLOBAL.CONC_REQUEST_ID;

    message_token('CONSTRAINT_SET', p_constraint_set_name);
    message_token('THRESHOLD', p_constraint_threshold);
    message_token('CONSTRAINT', p_constraint_name);
    message_token('SEVERITY_LEVEL', p_severity_level);
    message_token('ASSIGNMENT_VALUE', l_posset_total);
    message_token('OPERATOR', p_prefix_operator);
    message_token('FORMULA_VALUE', l_cons_total);

    if FND_API.to_Boolean(p_summ_flag) then
      message_token('NAME', p_constraint_name);
    else
      message_token('NAME', p_position_name);
    end if;

    message_token('YEAR', p_budget_year_name);
    add_message('PSB', 'PSB_CONSTRAINT_FAILURE');

    l_description := FND_MSG_PUB.Get
			(p_encoded => FND_API.G_FALSE);
    FND_MSG_PUB.Delete_Msg;

    insert into PSB_ERROR_MESSAGES
	       (Concurrent_Request_ID,
		Process_ID,
		Source_Process,
		Description,
		Creation_Date,
		Created_By)
	values (l_reqid,
		p_worksheet_id,
		'WORKSHEET_CREATION',
		l_description,
		sysdate,
		l_userid);

  end;
  else
    p_constraint_validation_status := 'S';
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
     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
 			      'Process_PosCons_Step');
     end if;

END Process_PosCons_Step;

/* ----------------------------------------------------------------------- */

PROCEDURE Process_FTECons
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_worksheet_id                  IN   NUMBER,
  p_data_extract_id               IN   NUMBER,
  p_sp_exists                     IN   VARCHAR2,
  p_constraint_set_name           IN   VARCHAR2,
  p_constraint_threshold          IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_position_line_id              IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_id                   IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_name                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_year_id                IN   NUMBER,
  p_budget_year_name              IN   VARCHAR2,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER,
  p_summ_flag                     IN   VARCHAR2
) IS

  l_cons_failed                   VARCHAR2(1) := FND_API.G_FALSE;

  l_posset_total                  NUMBER := 0;
  l_cons_total                    NUMBER := 0;

  l_reqid                         NUMBER;
  l_userid                        NUMBER;
  l_description                   VARCHAR2(2000);

  cursor c_Formula is
    select prefix_operator,
	   amount
      from PSB_CONSTRAINT_FORMULAS
     where constraint_id = p_constraint_id;

  cursor c_SumAll is
    select sum(nvl(a.annual_fte, 0)) Sum_FTE
      from PSB_WS_FTE_LINES a,
	   PSB_WORKSHEETS b
     where exists
	  (select 1
	     from PSB_WS_LINES_POSITIONS c,
		  PSB_WS_POSITION_LINES d,
		  PSB_BUDGET_POSITIONS e,
		  PSB_SET_RELATIONS f
	    where c.position_line_id = a.position_line_id
	      and c.position_line_id = d.position_line_id
	      and c.worksheet_id = p_worksheet_id
	      and d.position_id = e.position_id
	      and e.data_extract_id = p_data_extract_id
	      and e.account_position_set_id = f.account_position_set_id
	      and f.constraint_id = p_constraint_id)
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.stage_set_id = b.stage_set_id
       and a.budget_year_id = p_budget_year_id
       and b.worksheet_id = p_worksheet_id;

  cursor c_SumAllSP is
    select sum(nvl(a.annual_fte, 0)) Sum_FTE
      from PSB_WS_FTE_LINES a,
	   PSB_WORKSHEETS b
     where exists
	  (select 1
	     from PSB_WS_LINES_POSITIONS c,
		  PSB_WS_POSITION_LINES d,
		  PSB_BUDGET_POSITIONS e,
		  PSB_SET_RELATIONS f
	    where c.position_line_id = a.position_line_id
	      and c.position_line_id = d.position_line_id
	      and c.worksheet_id = p_worksheet_id
	      and d.position_id = e.position_id
	      and e.data_extract_id = p_data_extract_id
	      and e.account_position_set_id = f.account_position_set_id
	      and f.constraint_id = p_constraint_id)
       and exists
	  (select 1
	     from PSB_WS_SUBMIT_SERVICE_PACKAGES g
	    where g.service_package_id = a.service_package_id
	      and g.worksheet_id = p_worksheet_id)
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.stage_set_id = b.stage_set_id
       and a.budget_year_id = p_budget_year_id
       and b.worksheet_id = p_worksheet_id;

  cursor c_Sum is
    select /*+ ORDERED USE_NL(b a) INDEX(b PSB_WORKSHEETS_U1) INDEX(a PSB_WS_ELEMENT_LINES_N1) */
	   sum(nvl(a.annual_fte, 0)) Sum_FTE
      from PSB_WS_FTE_LINES a,
	   PSB_WORKSHEETS b
     where b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.stage_set_id = b.stage_set_id
       and a.budget_year_id = p_budget_year_id
       and a.position_line_id = p_position_line_id
       and b.worksheet_id = p_worksheet_id;

  cursor c_SumSP is
    select /*+ ORDERED USE_NL(b a) INDEX(b PSB_WORKSHEETS_U1) INDEX(a PSB_WS_ELEMENT_LINES_N1) */
	   sum(nvl(a.annual_fte, 0)) Sum_FTE
      from PSB_WS_FTE_LINES a,
	   PSB_WORKSHEETS b
     where exists
	  (select 1
	     from PSB_WS_SUBMIT_SERVICE_PACKAGES d
	    where d.worksheet_id = p_worksheet_id
	      and d.service_package_id = a.service_package_id)
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.stage_set_id = b.stage_set_id
       and a.budget_year_id = p_budget_year_id
       and a.position_line_id = p_position_line_id
       and b.worksheet_id = p_worksheet_id;

BEGIN

  for c_Formula_Rec in c_Formula loop

    l_cons_total := c_Formula_Rec.amount;

    if not FND_API.to_Boolean(p_summ_flag) then
    begin

      if FND_API.to_Boolean(p_sp_exists) then
      begin

	for c_Sum_Rec in c_SumSP loop
	  l_posset_total := c_Sum_Rec.Sum_FTE;
	end loop;

      end;
      else
      begin

	for c_Sum_Rec in c_Sum loop
	  l_posset_total := c_Sum_Rec.Sum_FTE;
	end loop;

      end;
      end if;

    end;
    else
    begin

      if FND_API.to_Boolean(p_sp_exists) then
      begin

	for c_SumAll_Rec in c_SumAllSP loop
	  l_posset_total := c_SumAll_Rec.Sum_FTE;
	end loop;

      end;
      else
      begin

	for c_SumAll_Rec in c_SumAll loop
	  l_posset_total := c_SumAll_Rec.Sum_FTE;
	end loop;

      end;
      end if;

    end;
    end if;

    if l_posset_total is not null then
    begin

      if c_Formula_Rec.prefix_operator = '<=' then

	if l_posset_total <= l_cons_total then
	  l_cons_failed := FND_API.G_TRUE;
	end if;

      elsif c_Formula_Rec.prefix_operator = '>=' then

	if l_posset_total >= l_cons_total then
	  l_cons_failed := FND_API.G_TRUE;
	end if;

      elsif c_Formula_Rec.prefix_operator = '<' then

	if l_posset_total < l_cons_total then
	  l_cons_failed := FND_API.G_TRUE;
	end if;

      elsif c_Formula_Rec.prefix_operator = '>' then

	if l_posset_total > l_cons_total then
	  l_cons_failed := FND_API.G_TRUE;
	end if;

      elsif c_Formula_Rec.prefix_operator = '=' then

	if l_posset_total = l_cons_total then
	  l_cons_failed := FND_API.G_TRUE;
	end if;

      elsif c_Formula_Rec.prefix_operator = '<>' then

	if l_posset_total = l_cons_total then
	  l_cons_failed := FND_API.G_TRUE;
	end if;

      end if;

    end;
    end if;

    if FND_API.to_Boolean(l_cons_failed) then
    begin

      if nvl(p_severity_level, -1) >= p_constraint_threshold then
	p_constraint_validation_status := 'F';
      else
	p_constraint_validation_status := 'E';
      end if;

      l_userid := FND_GLOBAL.USER_ID;
      l_reqid := FND_GLOBAL.CONC_REQUEST_ID;

      message_token('CONSTRAINT_SET', p_constraint_set_name);
      message_token('THRESHOLD', p_constraint_threshold);
      message_token('CONSTRAINT', p_constraint_name);
      message_token('SEVERITY_LEVEL', p_severity_level);
      message_token('ASSIGNMENT_VALUE', l_posset_total);
      message_token('OPERATOR', c_Formula_Rec.prefix_operator);
      message_token('FORMULA_VALUE', l_cons_total);

      if FND_API.to_Boolean(p_summ_flag) then
	message_token('NAME', p_constraint_name);
      else
	message_token('NAME', p_position_name);
      end if;

      message_token('YEAR', p_budget_year_name);
      add_message('PSB', 'PSB_CONSTRAINT_FAILURE');

      l_description := FND_MSG_PUB.Get
			  (p_encoded => FND_API.G_FALSE);
      FND_MSG_PUB.Delete_Msg;

      insert into PSB_ERROR_MESSAGES
		 (Concurrent_Request_ID,
		  Process_ID,
		  Source_Process,
		  Description,
		  Creation_Date,
		  Created_By)
	  values (l_reqid,
		  p_worksheet_id,
		  'WORKSHEET_CREATION',
		  l_description,
		  sysdate,
		  l_userid);

    end;
    else
      p_constraint_validation_status := 'S';
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
     FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
 			      'Process_FTECons');
     end if;

END Process_FTECons;

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

  -- This Module is used to retrieve Debug Information for this Package. It
  -- prints Debug Information when run as a Batch Process from SQL*Plus. For
  -- the Debug Information to be printed on the Screen, the SQL*Plus parameter
  -- 'Serveroutput' should be set to 'ON'

FUNCTION Get_Debug RETURN VARCHAR2 IS

BEGIN

  return(g_dbug);

END Get_Debug;

/* ----------------------------------------------------------------------- */


END PSB_WS_POS3;

/
