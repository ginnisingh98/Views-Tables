--------------------------------------------------------
--  DDL for Package Body PSB_WS_ACCT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WS_ACCT1" AS
/* $Header: PSBVWA1B.pls 120.56.12010000.13 2009/12/21 08:39:41 rkotha ship $ */

  G_PKG_NAME CONSTANT   VARCHAR2(30):= 'PSB_WS_ACCT1';

  TYPE TokNameArray IS TABLE OF VARCHAR2(100)
    INDEX BY BINARY_INTEGER;

  TYPE TokValArray IS TABLE OF VARCHAR2(1000)
    INDEX BY BINARY_INTEGER;

/* Bug No 2719865 Start */
  g_first_ccid		BOOLEAN := TRUE;
/* Bug No 2719865 End */

  g_est_last_period_index  NUMBER := 0; --bug:7148726

  -- Number of Message Tokens

  no_msg_tokens         NUMBER := 0;

  -- Message Token Name

  msg_tok_names         TokNameArray;

  -- Message Token Value

  msg_tok_val           TokValArray;

  g_dbug                VARCHAR2(1000);
  g_create_zero_bal     VARCHAR2(1);


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
  --FND_FILE.put_line(FND_FILE.LOG, p_message);
END pd ;
/*---------------------------------------------------------------------------*/


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

  i  PLS_INTEGER;

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

-- Cache Budget Years, Budget Periods and Calculation Periods, after sorting
-- by Start Date, so that it can be reused across modules in the Worksheet
-- Creation process

PROCEDURE Cache_Budget_Calendar
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_budget_calendar_id  IN   NUMBER
) IS

  l_init_index          PLS_INTEGER;
  l_year_index          PLS_INTEGER := 1;
  l_period_index        PLS_INTEGER := 1;
  l_calcp_index         PLS_INTEGER := 1;
  l_long_index          PLS_INTEGER;

  l_num_budget_periods  NUMBER;
  l_num_calc_periods    NUMBER;

  /*Bug:8650415:start*/
  l_lstart_date   DATE;
  l_start_date    DATE;
  l_end_date      DATE;
  /*Bug:8650415:end*/

  l_firstpp             BOOLEAN := TRUE;

  cursor c_BudYr is
    select a.budget_period_id,
	   a.budget_year_type_id,
	   b.year_category_type,
	   period_distribution_type,
	   calculation_period_type,
	   a.name,
	   a.start_date,
	   a.end_date
      from PSB_BUDGET_YEAR_TYPES b,
	   PSB_BUDGET_PERIODS a
     where b.budget_year_type_id = a.budget_year_type_id
       and a.budget_period_type = 'Y'
       and a.budget_calendar_id = p_budget_calendar_id
     order by a.start_date;

  cursor c_BudPrd (budyr_id NUMBER) is
    select budget_period_id,
	   start_date,
	   end_date
      from PSB_BUDGET_PERIODS
     where budget_period_type = 'P'
       and parent_budget_period_id = budyr_id
       and budget_calendar_id = p_budget_calendar_id
     order by start_date;

  cursor c_CalcPrd (budyr_id NUMBER,
		    startdate DATE,
		    enddate DATE) is
    select budget_period_id,
	   start_date,
	   end_date
      from PSB_BUDGET_PERIODS
     where end_date <= enddate
       and start_date >= startdate
       and budget_period_type = 'C'
       and parent_budget_period_id = budyr_id
       and budget_calendar_id = p_budget_calendar_id
     order by start_date;

BEGIN

  for l_init_index in 1..g_budget_years.Count loop
    g_budget_years(l_init_index).budget_year_id := null;
    g_budget_years(l_init_index).budget_year_type_id := null;
    g_budget_years(l_init_index).year_type := null;
    g_budget_years(l_init_index).year_name := null;
    g_budget_years(l_init_index).start_date := null;
    g_budget_years(l_init_index).end_date := null;
    g_budget_years(l_init_index).num_budget_periods := null;
    g_budget_years(l_init_index).last_period_index := null;
  end loop;

  for l_init_index in 1..g_budget_periods.Count loop
    g_budget_periods(l_init_index).budget_period_id := null;
    g_budget_periods(l_init_index).budget_period_type := null;
    g_budget_periods(l_init_index).long_sequence_no := null;
    g_budget_periods(l_init_index).start_date := null;
    g_budget_periods(l_init_index).end_date := null;
    g_budget_periods(l_init_index).budget_year_id := null;
    g_budget_periods(l_init_index).num_calc_periods := null;
  end loop;

  for l_init_index in 1..g_calculation_periods.Count loop
    g_calculation_periods(l_init_index).calc_period_id := null;
    g_calculation_periods(l_init_index).calc_period_type := null;
    g_calculation_periods(l_init_index).start_date := null;
    g_calculation_periods(l_init_index).end_date := null;
    g_calculation_periods(l_init_index).budget_period_id := null;
  end loop;

  g_num_budget_years := 0;
  g_max_num_years := 0;
  g_num_budget_periods := 0;
  g_num_calc_periods := 0;

  g_budget_calendar_id := p_budget_calendar_id;

  for c_BudYr_Rec in c_BudYr loop

    g_num_budget_years := g_num_budget_years + 1;

    g_budget_years(l_year_index).budget_year_id := c_BudYr_Rec.budget_period_id;
    g_budget_years(l_year_index).budget_year_type_id := c_BudYr_Rec.budget_year_type_id;
    g_budget_years(l_year_index).year_type := c_BudYr_Rec.year_category_type;
    g_budget_years(l_year_index).year_name := c_BudYr_Rec.name;
    g_budget_years(l_year_index).start_date := c_BudYr_Rec.start_date;
    g_budget_years(l_year_index).end_date := c_BudYr_Rec.end_date;

    if c_BudYr_Rec.year_category_type = 'PP' then
    begin

      g_max_num_years := g_max_num_years + 1;

      if l_firstpp then

	l_firstpp := FALSE;

	g_startdate_pp := c_BudYr_Rec.Start_Date;
	g_end_est_date := c_BudYr_Rec.End_Date;

      end if;

      if c_BudYr_Rec.end_date > g_end_est_date then
	g_end_est_date := c_BudYr_Rec.end_date;
      end if;

    end;
    end if;

    if c_BudYr_Rec.year_category_type = 'CY' then
      g_startdate_cy := c_BudYr_Rec.Start_Date;
      g_enddate_cy := c_BudYr_Rec.End_Date;
    end if;

    l_long_index := 1;

    l_num_budget_periods := 0;

    for c_BudPrd_Rec in c_BudPrd (c_BudYr_Rec.budget_period_id) loop

      g_num_budget_periods := g_num_budget_periods + 1;
      l_num_budget_periods := l_num_budget_periods + 1;

      g_budget_periods(l_period_index).budget_period_id := c_BudPrd_Rec.budget_period_id;
      g_budget_periods(l_period_index).budget_period_type := c_BudYr_Rec.period_distribution_type;
      g_budget_periods(l_period_index).long_sequence_no := l_long_index;
      g_budget_periods(l_period_index).start_date := c_BudPrd_Rec.start_date;
      g_budget_periods(l_period_index).end_date := c_BudPrd_Rec.end_date;
      g_budget_periods(l_period_index).budget_year_id := c_BudYr_Rec.budget_period_id;

      l_num_calc_periods := 0;

      for c_CalcPrd_Rec in c_CalcPrd (c_BudYr_Rec.budget_period_id,
				      c_BudPrd_Rec.start_date,
				      c_BudPrd_Rec.end_date) loop
	g_num_calc_periods := g_num_calc_periods + 1;
	l_num_calc_periods := l_num_calc_periods + 1;

	g_calculation_periods(l_calcp_index).calc_period_id := c_CalcPrd_Rec.budget_period_id;
	g_calculation_periods(l_calcp_index).calc_period_type := c_BudYr_Rec.calculation_period_type;
	g_calculation_periods(l_calcp_index).start_date := c_CalcPrd_Rec.start_date;
	g_calculation_periods(l_calcp_index).end_date := c_CalcPrd_Rec.end_date;
	g_calculation_periods(l_calcp_index).budget_period_id := c_BudPrd_Rec.budget_period_id;

	l_calcp_index := l_calcp_index + 1;
      end loop;

      g_budget_periods(l_period_index).num_calc_periods := l_num_calc_periods;

      l_period_index := l_period_index + 1;

      l_long_index := l_long_index + 1;

      if l_long_index > g_max_num_amounts then
	add_message('PSB', 'NUM_BUDGET_PERIODS_CEILING');
	raise FND_API.G_EXC_ERROR;
      end if;

    end loop;

    /*Bug:8650415:Start*/
    IF c_BudYr_Rec.period_distribution_type = 'Y' THEN

      l_start_date := c_BudYr_Rec.start_date ;
      l_end_date   := c_BudYr_Rec.start_date ;

      --
      WHILE l_end_date < c_BudYr_Rec.end_date LOOP

        IF c_BudYr_Rec.calculation_period_type = 'M' THEN
          l_lstart_date := l_start_date ;
        ELSIF c_BudYr_Rec.calculation_period_type = 'Q' THEN
          l_lstart_date := ADD_MONTHS(l_start_date, 2);
        ELSIF c_BudYr_Rec.calculation_period_type = 'S' THEN
          l_lstart_date := ADD_MONTHS(l_start_date, 5) ;
        ELSIF c_BudYr_Rec.calculation_period_type = 'Y' THEN
          l_lstart_date := ADD_MONTHS(l_start_date, 11);
        END IF;
        --
        l_end_date := LAST_DAY(l_lstart_date) ;

        g_num_budget_periods := g_num_budget_periods + 1;
        l_num_budget_periods := l_num_budget_periods + 1;
        g_budget_periods(l_period_index).budget_period_id := l_period_index;
        g_budget_periods(l_period_index).budget_period_type := c_BudYr_Rec.period_distribution_type;
        g_budget_periods(l_period_index).long_sequence_no := l_long_index;
        g_budget_periods(l_period_index).start_date := l_start_date;
        g_budget_periods(l_period_index).end_date := l_end_date;
        g_budget_periods(l_period_index).budget_year_id := c_BudYr_Rec.budget_period_id;

        if c_BudYr_Rec.calculation_period_type = 'Y' then
           l_num_calc_periods := 0;
           g_num_calc_periods := g_num_calc_periods + 1;
           l_num_calc_periods := l_num_calc_periods + 1;

           g_calculation_periods(l_calcp_index).calc_period_type := c_BudYr_Rec.calculation_period_type;
           g_calculation_periods(l_calcp_index).start_date := c_BudYr_Rec.start_date;
           g_calculation_periods(l_calcp_index).end_date := c_BudYr_Rec.end_date;
           g_calculation_periods(l_calcp_index).budget_period_id := l_period_index;
           l_calcp_index := l_calcp_index + 1;

        else
          for c_CalcPrd_Rec in c_CalcPrd (c_BudYr_Rec.budget_period_id,
    				          l_start_date,
				          l_end_date) loop
	    g_num_calc_periods := g_num_calc_periods + 1;
            l_num_calc_periods := l_num_calc_periods + 1;

  	    g_calculation_periods(l_calcp_index).calc_period_id := c_CalcPrd_Rec.budget_period_id;
	    g_calculation_periods(l_calcp_index).calc_period_type := c_BudYr_Rec.calculation_period_type;
	    g_calculation_periods(l_calcp_index).start_date := c_CalcPrd_Rec.start_date;
	    g_calculation_periods(l_calcp_index).end_date := c_CalcPrd_Rec.end_date;
	    g_calculation_periods(l_calcp_index).budget_period_id := l_period_index;
	    l_calcp_index := l_calcp_index + 1;
          end loop;

        end if;
        g_budget_periods(l_period_index).num_calc_periods := l_num_calc_periods;


        l_start_date := l_end_date + 1 ;
        l_period_index := l_period_index + 1;
        l_long_index := l_long_index + 1;

        if l_long_index > g_max_num_amounts then
  	  add_message('PSB', 'NUM_BUDGET_PERIODS_CEILING');
	  raise FND_API.G_EXC_ERROR;
        end if;

      END LOOP;  --end while


    END IF;
    /*Bug:8650415:End*/

    g_budget_years(l_year_index).num_budget_periods := l_num_budget_periods;
    g_budget_years(l_year_index).last_period_index := l_long_index - 1;

    -- Bug#3126462: Support Percent type allocation rules for CY estimates
    -- We need to cache number of periods in CY. This info used when processing
    -- allocation rules for CY later on.
    IF c_BudYr_Rec.year_category_type = 'CY' THEN
      g_cy_num_periods := l_num_budget_periods ;
    END IF;

    l_year_index := l_year_index + 1;

  end loop;

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => 'Cache_Budget_Calendar');

END Cache_Budget_Calendar;

/* ----------------------------------------------------------------------- */

PROCEDURE Get_Budget_Calendar_Info
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_budget_calendar_id  IN   NUMBER,
  p_startdate_pp        OUT  NOCOPY  DATE,
  p_enddate_cy          OUT  NOCOPY  DATE
) IS
  --
  l_return_status       VARCHAR2(1);
  --
BEGIN

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Get budget calendar related info.
  --
  IF NVL(g_budget_calendar_id, -99) <> p_budget_calendar_id THEN
    --
    Cache_Budget_Calendar
    (
       p_return_status         =>  l_return_status ,
       p_budget_calendar_id    =>  p_budget_calendar_id
    );
    --
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR ;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;
    --
  END IF ;

  -- Set the out parameters.
  p_startdate_pp := g_startdate_pp ;
  p_enddate_cy   := g_enddate_cy ;

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  --
END Get_Budget_Calendar_Info;

/* ----------------------------------------------------------------------- */

-- Map Account based on flex mapping set

FUNCTION Map_Account
( p_flex_mapping_set_id  IN  NUMBER,
  p_ccid                 IN  NUMBER,
  p_budget_year_type_id  IN  NUMBER
) RETURN NUMBER IS

  l_mapped_ccid          NUMBER;

BEGIN

  if p_flex_mapping_set_id is not null then
  begin

    l_mapped_ccid := PSB_FLEX_MAPPING_PVT.Get_Mapped_CCID
			(p_api_version => 1.0,
			 p_ccid => p_ccid,
			 p_budget_year_type_id => p_budget_year_type_id,
			 p_flexfield_mapping_set_id => p_flex_mapping_set_id,
			 p_mapping_mode => 'WORKSHEET');
  end;
  else
    l_mapped_ccid := p_ccid;
  end if;

  RETURN l_mapped_ccid;

END Map_Account;

/* ----------------------------------------------------------------------- */

-- Check CCID Type by matching the CCID against the Personnel and Non-Personnel
-- Account Sets defined for the Budget Group

PROCEDURE Check_CCID_Type
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_ccid_type         OUT  NOCOPY  VARCHAR2,
  p_flex_code         IN   NUMBER,
  p_ccid              IN   NUMBER,
  p_budget_group_id   IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Check_CCID_Type';
  l_api_version       CONSTANT NUMBER         := 1.0;

  l_concat_segments   VARCHAR2(2000);

  l_ccid_type         VARCHAR2(30);

  /* Bug 3543845 start: add the following variables */
  l_root_budget_group_id NUMBER;
  l_root_budget_group    VARCHAR2(1);
  l_ps_acct_pos_set_id   NUMBER;
  l_nps_acct_pos_set_id  NUMBER;

  -- comment out the following cursor since the query is in the body now.
  /*
  cursor c_CCID1 is
    select root_budget_group_id,
	   root_budget_group,
	   ps_account_position_set_id psid,
	   nps_account_position_set_id npsid
      from PSB_BUDGET_GROUPS
     where budget_group_id = p_budget_group_id;

  cursor c_CCID2 (BudgetGroupID NUMBER) is
    select ps_account_position_set_id psid,
	   nps_account_position_set_id npsid
      from PSB_BUDGET_GROUPS
    where budget_group_id = BudgetGroupID;
  */
  /* Bug 3543845 end */

  cursor c_CCID_Type (AccSet_ID NUMBER,
		      CCID NUMBER) is
    select 1
      from PSB_BUDGET_ACCOUNTS
     where account_position_set_id = AccSet_ID
       and code_combination_id = CCID;

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  /* Bug 3543845 start: Use caching when available */

  IF PSB_WORKSHEET.g_ws_creation_flag
  THEN

    l_ps_acct_pos_set_id := PSB_WORKSHEET.g_ps_acct_pos_set_id;
    l_nps_acct_pos_set_id := PSB_WORKSHEET.g_nps_acct_pos_set_id;

  ELSE

    SELECT root_budget_group_id,
           root_budget_group,
           ps_account_position_set_id,
           nps_account_position_set_id
         INTO
           l_root_budget_group_id,
           l_root_budget_group,
           l_ps_acct_pos_set_id,
           l_nps_acct_pos_set_id
    FROM   PSB_BUDGET_GROUPS
    WHERE  budget_group_id = p_budget_group_id;

    IF l_root_budget_group is NULL OR l_root_budget_group = 'N'
    THEN
      SELECT ps_account_position_set_id,
             nps_account_position_set_id
           INTO
             l_ps_acct_pos_set_id,
             l_nps_acct_pos_set_id
      FROM   PSB_BUDGET_GROUPS
      WHERE  budget_group_id = l_root_budget_group_id;
    END IF;


  END IF;

  /* Comment out the following lines
  for c_CCID1_Rec in c_CCID1 loop

    if c_CCID1_Rec.root_budget_group = 'Y' then
    begin

      for c_CCID_Type_Rec in c_CCID_Type (c_CCID1_REC.psid, p_ccid) loop
	l_ccid_type := 'PERSONNEL_SERVICES';
      end loop;

      if l_ccid_type is null then
      begin

	for c_CCID_Type_Rec in c_CCID_Type (c_CCID1_REC.npsid, p_ccid) loop
	  l_ccid_type := 'NON_PERSONNEL_SERVICES';
	end loop;

      end;
      end if;

    end;
    else
    begin

      for c_CCID2_Rec in c_CCID2 (c_CCID1_Rec.root_budget_group_id) loop

	for c_CCID_Type_Rec in c_CCID_Type (c_CCID2_REC.psid, p_ccid) loop
	  l_ccid_type := 'PERSONNEL_SERVICES';
	end loop;

	if l_ccid_type is null then
	begin

	  for c_CCID_Type_Rec in c_CCID_Type (c_CCID2_REC.npsid, p_ccid) loop
	    l_ccid_type := 'NON_PERSONNEL_SERVICES';
	  end loop;

	end;
	end if;

      end loop;

    end;
    end if;

  end loop;
  */
  -- Add the following to find out the l_ccid_type
  l_ccid_type := NULL;

  for l_CCID_Type_Rec in c_CCID_Type (l_ps_acct_pos_set_id, p_ccid)
  loop
    l_ccid_type := 'PERSONNEL_SERVICES';
  end loop;

  if l_ccid_type is null then
  begin
    for l_CCID_Type_Rec in c_CCID_Type (l_nps_acct_pos_set_id, p_ccid)
    loop
      l_ccid_type := 'NON_PERSONNEL_SERVICES';
    end loop;
  end;
  end if;

  /* Bug 3543845 End */

  if l_ccid_type is null then
  begin

    l_concat_segments := FND_FLEX_EXT.Get_Segs
			    (application_short_name => 'SQLGL',
			     key_flex_code => 'GL#',
			     structure_number => p_flex_code,
			     combination_id => p_ccid);

    message_token('CCID', l_concat_segments);
    add_message('PSB', 'INVALID_ACCOUNT_TYPE');
    raise FND_API.G_EXC_ERROR;

  end;
  else
    p_ccid_type := l_ccid_type;
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

END Check_CCID_Type;

/* ----------------------------------------------------------------------- */

-- Cache CCIDs for the Account Set

PROCEDURE Find_CCIDs
( p_return_status   OUT  NOCOPY  VARCHAR2,
  p_account_set_id  IN   NUMBER
) IS

  cursor c_ccids is
    select a.code_combination_id,
	   b.start_date_active,
	   b.end_date_active
       from GL_CODE_COMBINATIONS b,
	   PSB_BUDGET_ACCOUNTS a
       where b.enabled_flag = 'Y'
       /* Bug 3692601 Start */
       AND b.detail_budgeting_allowed_flag = 'Y'
       /* Bug 3692601 End */
       and b.code_combination_id = a.code_combination_id
       and a.account_position_set_id = p_account_set_id;

  l_init_index      PLS_INTEGER;
  l_ccid_index      PLS_INTEGER := 1;

BEGIN

  for l_init_index in 1..g_ccids.Count loop
    g_ccids(l_init_index).ccid := null;
    g_ccids(l_init_index).start_date := null;
    g_ccids(l_init_index).end_date := null;
  end loop;

  g_num_ccids := 0;

  g_account_set_id := p_account_set_id;

  for c_ccids_rec in c_ccids loop

    g_ccids(l_ccid_index).ccid := c_ccids_rec.code_combination_id;
    g_ccids(l_ccid_index).start_date := c_ccids_rec.start_date_active;
    g_ccids(l_ccid_index).end_date := c_ccids_rec.end_date_active;

    g_num_ccids := g_num_ccids + 1;
    l_ccid_index := l_ccid_index + 1;

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
	   p_procedure_name => 'Find_CCIDs');
     end if;

END Find_CCIDs;

/* ----------------------------------------------------------------------- */

-- Create Worksheet Account Distribution in PSB_WS_ACCOUNT_LINES. If
-- entry already exists, it updates existing entry (if p_check_spal_exists
-- is FND_API.G_FALSE); otherwise, it increments the existing entry (if
-- p_check_spal_exists is FND_API.G_TRUE)

-- This API must be called when creating a new Account Distribution

PROCEDURE Create_Account_Dist
( p_api_version              IN   NUMBER,
  p_validation_level         IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_account_line_id          OUT  NOCOPY  NUMBER,
  p_worksheet_id             IN   NUMBER,
  p_check_spal_exists        IN   VARCHAR2 := FND_API.G_TRUE,
  p_gl_cutoff_period         IN   DATE := FND_API.G_MISS_DATE,
  p_allocrule_set_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_calendar_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_rounding_factor          IN   NUMBER := FND_API.G_MISS_NUM,
  p_stage_set_id             IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_year_id           IN   NUMBER,
  p_budget_group_id          IN   NUMBER,
  p_ccid                     IN   NUMBER := FND_API.G_MISS_NUM,
  p_flex_mapping_set_id      IN   NUMBER := FND_API.G_MISS_NUM,
  p_map_accounts             IN   BOOLEAN := FALSE,
  p_functional_transaction   IN   VARCHAR2 := NULL,
  p_flex_code                IN   NUMBER := FND_API.G_MISS_NUM,
  p_concatenated_segments    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_startdate_pp             IN   DATE := FND_API.G_MISS_DATE,
  p_template_id              IN   NUMBER := FND_API.G_MISS_NUM,
  p_currency_code            IN   VARCHAR2,
  p_balance_type             IN   VARCHAR2,
  p_ytd_amount               IN   NUMBER,
  p_distribute_flag          IN   VARCHAR2 := FND_API.G_FALSE,
  p_annual_fte               IN   NUMBER := FND_API.G_MISS_NUM,
  p_period_amount            IN   g_prdamt_tbl_type,
  p_position_line_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_element_set_id           IN   NUMBER := FND_API.G_MISS_NUM,
  p_salary_account_line      IN   VARCHAR2 := FND_API.G_FALSE,
  p_service_package_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_start_stage_seq          IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq        IN   NUMBER := FND_API.G_MISS_NUM,
  p_end_stage_seq            IN   NUMBER := FND_API.G_MISS_NUM,
  p_copy_of_account_line_id  IN   NUMBER := FND_API.G_MISS_NUM,
  /* bug start 3996052 */
  p_update_cy_estimate       IN   VARCHAR2 := 'N'
  /* bug end 3996052 */
) IS

  l_api_name                 CONSTANT VARCHAR2(30)   := 'Create_Account_Dist';
  l_api_version              CONSTANT NUMBER         := 1.0;

  l_ytd_amount               NUMBER;
  l_rounded_ytd_amount       NUMBER;
  l_rounding_difference      NUMBER;
  l_period_amount            NUMBER;
  l_period_amount_tbl        g_prdamt_tbl_type;
  l_period_amounts           g_prdamt_tbl_type;

  l_userid                   NUMBER;
  l_loginid                  NUMBER;
  l_requestid                NUMBER;

  -- Bug 3347507
  l_original_start_stage_seq NUMBER;
  l_start_stage_seq          NUMBER;
  l_current_stage_seq        NUMBER;
  l_acclineid                NUMBER;
  l_ccid                     NUMBER;

  l_service_package_id       NUMBER;

  l_account_type             VARCHAR2(1);
  l_template_id              NUMBER;

  cur_wal                    PLS_INTEGER;
  sql_wal                    VARCHAR2(1000);
  num_wal                    PLS_INTEGER;

  l_gl_cutoff_period         DATE;
  l_global_worksheet_id      NUMBER;
  l_allocrule_set_id         NUMBER;
  l_budget_calendar_id       NUMBER;
  l_rounding_factor          NUMBER;
  l_stage_set_id             NUMBER;
  l_flex_mapping_set_id      NUMBER;
  l_local_copy_flag          VARCHAR2(1);

  l_budget_periods           g_budgetperiod_tbl_type;
  l_year_index               PLS_INTEGER;
  l_init_index               PLS_INTEGER;
  l_period_index             PLS_INTEGER;
  l_last_period_index        NUMBER;
  l_budget_year_type_id      NUMBER;

  l_start_date               DATE;
  l_end_date                 DATE;
  l_ccid_start_date          DATE;
  l_ccid_end_date            DATE;

  l_spal_id                  NUMBER;
  l_spal_budget_group_id     NUMBER;
  l_spytd_amount             NUMBER;
  l_spal_exists              BOOLEAN := FALSE;

  l_index                    PLS_INTEGER;

  l_account_line_id          NUMBER;
  l_budget_group_id          NUMBER;
  l_budget_group_changed     BOOLEAN := FALSE;
  l_current_requestid        NUMBER;
  l_current_fte              NUMBER;
  l_current_ytdamt           NUMBER;
  l_current_prdamt           g_prdamt_tbl_type;
  l_flexmap_increment        BOOLEAN := FALSE;

  l_set_of_books_id          NUMBER;
  l_budget_year_type         VARCHAR2(20); --bug:7597096
  l_return_status            VARCHAR2(1);

  /* Bug 3458191: Remove the following cursor and replace it by two queries
     inside the body.
  cursor c_WS is
    select gl_cutoff_period,
           nvl(global_worksheet_id, worksheet_id) global_worksheet_id,
           nvl(allocrule_set_id, global_allocrule_set_id) allocrule_set_id,
           budget_calendar_id,
           rounding_factor,
           stage_set_id,
           flex_mapping_set_id,
           current_stage_seq,
           local_copy_flag
      from PSB_WORKSHEETS_V
     where worksheet_id = p_worksheet_id;
  */

  cursor c_sp is
    select service_package_id
      from PSB_SERVICE_PACKAGES
     where base_service_package = 'Y'
       and global_worksheet_id = l_global_worksheet_id;

  cursor c_CCID is
    select start_date_active,
	   end_date_active
      from GL_CODE_COMBINATIONS
     where code_combination_id = l_ccid;

  cursor c_sp_seq is
    select psb_service_packages_s.nextval ServicePackageID
      from dual;

--Bug:5929875:Moved psb_ws_lines table to main query to avoid sub-query.
  cursor c_wal1 is
    select a.account_line_id, a.budget_group_id, request_id, annual_fte, ytd_amount,
	   period1_amount, period2_amount, period3_amount, period4_amount,
	   period5_amount, period6_amount, period7_amount, period8_amount,
	   period9_amount, period10_amount, period11_amount, period12_amount,
	   period13_amount, period14_amount, period15_amount, period16_amount,
	   period17_amount, period18_amount, period19_amount, period20_amount,
	   period21_amount, period22_amount, period23_amount, period24_amount,
	   period25_amount, period26_amount, period27_amount, period28_amount,
	   period29_amount, period30_amount, period31_amount, period32_amount,
	   period33_amount, period34_amount, period35_amount, period36_amount,
	   period37_amount, period38_amount, period39_amount, period40_amount,
	   period41_amount, period42_amount, period43_amount, period44_amount,
	   period45_amount, period46_amount, period47_amount, period48_amount,
	   period49_amount, period50_amount, period51_amount, period52_amount,
	   period53_amount, period54_amount, period55_amount, period56_amount,
	   period57_amount, period58_amount, period59_amount, period60_amount
      from PSB_WS_ACCOUNT_LINES a, psb_ws_lines pwl
     where currency_code = p_currency_code
       and l_current_stage_seq between start_stage_seq and current_stage_seq
       and balance_type = p_balance_type
       and template_id = p_template_id
       and position_line_id is null
       and pwl.account_line_id = a.account_line_id
       and pwl.worksheet_id = decode(nvl(l_local_copy_flag, 'N'), 'Y', p_worksheet_id, l_global_worksheet_id)
       and stage_set_id = l_stage_set_id
       and service_package_id = l_service_package_id
       and budget_year_id = p_budget_year_id
       and code_combination_id = l_ccid;

  cursor c_wal2 is
    select account_line_id, budget_group_id, request_id, annual_fte, ytd_amount,
	   period1_amount, period2_amount, period3_amount, period4_amount,
	   period5_amount, period6_amount, period7_amount, period8_amount,
	   period9_amount, period10_amount, period11_amount, period12_amount,
	   period13_amount, period14_amount, period15_amount, period16_amount,
	   period17_amount, period18_amount, period19_amount, period20_amount,
	   period21_amount, period22_amount, period23_amount, period24_amount,
	   period25_amount, period26_amount, period27_amount, period28_amount,
	   period29_amount, period30_amount, period31_amount, period32_amount,
	   period33_amount, period34_amount, period35_amount, period36_amount,
	   period37_amount, period38_amount, period39_amount, period40_amount,
	   period41_amount, period42_amount, period43_amount, period44_amount,
	   period45_amount, period46_amount, period47_amount, period48_amount,
	   period49_amount, period50_amount, period51_amount, period52_amount,
	   period53_amount, period54_amount, period55_amount, period56_amount,
	   period57_amount, period58_amount, period59_amount, period60_amount
      from PSB_WS_ACCOUNT_LINES a
     where currency_code = p_currency_code
       and l_current_stage_seq between start_stage_seq and current_stage_seq
       and balance_type = p_balance_type
       and template_id is null
       and position_line_id = p_position_line_id
       and element_set_id = p_element_set_id
       and stage_set_id = l_stage_set_id
       and service_package_id = l_service_package_id
       and budget_year_id = p_budget_year_id
       and code_combination_id = l_ccid;

 --Bug:5929875:Moved psb_ws_lines table to main query to avoid sub-query.
  cursor c_wal3 is
    select a.account_line_id, a.budget_group_id, request_id, annual_fte, ytd_amount,
	   period1_amount, period2_amount, period3_amount, period4_amount,
	   period5_amount, period6_amount, period7_amount, period8_amount,
	   period9_amount, period10_amount, period11_amount, period12_amount,
	   period13_amount, period14_amount, period15_amount, period16_amount,
	   period17_amount, period18_amount, period19_amount, period20_amount,
	   period21_amount, period22_amount, period23_amount, period24_amount,
	   period25_amount, period26_amount, period27_amount, period28_amount,
	   period29_amount, period30_amount, period31_amount, period32_amount,
	   period33_amount, period34_amount, period35_amount, period36_amount,
	   period37_amount, period38_amount, period39_amount, period40_amount,
	   period41_amount, period42_amount, period43_amount, period44_amount,
	   period45_amount, period46_amount, period47_amount, period48_amount,
	   period49_amount, period50_amount, period51_amount, period52_amount,
	   period53_amount, period54_amount, period55_amount, period56_amount,
	   period57_amount, period58_amount, period59_amount, period60_amount
      from PSB_WS_ACCOUNT_LINES a, psb_ws_lines pwl
     where currency_code = p_currency_code
       and l_current_stage_seq between start_stage_seq and current_stage_seq
       and balance_type = p_balance_type
       and template_id is null
       and position_line_id is null
       and pwl.account_line_id = a.account_line_id
       and pwl.worksheet_id = decode(nvl(l_local_copy_flag, 'N'), 'Y', p_worksheet_id, l_global_worksheet_id)
       and stage_set_id = l_stage_set_id
       and service_package_id = l_service_package_id
       and budget_year_id = p_budget_year_id
       and code_combination_id = l_ccid;

 /*Bug:5929875:start*/
  /*Cursor to find existing account line based on the values passed to Input parameters.
    This cursor is written to avoid the dynamic sql as part of perf fix:5929875*/
  CURSOR c_aline_csr IS
  SELECT a.account_line_id,a.budget_group_id,a.ytd_amount,a.start_stage_seq
  FROM   psb_ws_account_lines a,psb_ws_lines b
  WHERE  l_current_stage_seq between start_stage_seq and current_stage_seq
  AND    ((p_template_id <> FND_API.G_MISS_NUM AND a.template_id = p_template_id) OR
          (a.template_id IS NULL))
  AND    ((p_position_line_id <> FND_API.G_MISS_NUM AND a.position_line_id = p_position_line_id) OR
          (a.position_line_id IS NULL))
  AND    ((p_element_set_id <> FND_API.G_MISS_NUM AND a.element_set_id = p_element_set_id) OR
          (a.element_set_id IS NULL))
  AND    a.currency_code       = p_currency_code
  AND    a.balance_type        = p_balance_type
  AND    a.stage_set_id        = l_stage_set_id
  AND    a.service_package_id  = l_service_package_id
  AND    a.budget_year_id      = p_budget_year_id
  AND    a.code_combination_id = l_ccid
  AND    b.account_line_id     = a.account_line_id
  AND    b.worksheet_id        = p_worksheet_id;


  /*Cursor to find existing account line based on the values passed to Input parameters.
    This cursor is written to avoid the dynamic sql as part of perf fix:5929875*/

  CURSOR c_aline_pos_csr IS
  SELECT a.account_line_id,a.budget_group_id,a.ytd_amount,a.start_stage_seq
  FROM   psb_ws_account_lines a
  WHERE  l_current_stage_seq between start_stage_seq and current_stage_seq
  AND    ((p_template_id <> FND_API.G_MISS_NUM AND a.template_id = p_template_id) OR
          (a.template_id IS NULL))
  AND    ((p_position_line_id <> FND_API.G_MISS_NUM AND a.position_line_id = p_position_line_id) OR
          (a.position_line_id IS NULL))
  AND    ((p_element_set_id <> FND_API.G_MISS_NUM AND a.element_set_id = p_element_set_id) OR
          (a.element_set_id IS NULL))
  AND    a.currency_code       = p_currency_code
  AND    a.balance_type        = p_balance_type
  AND    a.stage_set_id        = l_stage_set_id
  AND    a.service_package_id  = l_service_package_id
  AND    a.budget_year_id      = p_budget_year_id
  AND    a.code_combination_id = l_ccid;

  /*Bug:5929875:end*/

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
  l_requestid := FND_GLOBAL.CONC_REQUEST_ID;

  -- Substitute default values for parameters that were not passed in

  if ((nvl(p_gl_cutoff_period, FND_API.G_MISS_DATE) = FND_API.G_MISS_DATE) or
      (nvl(p_allocrule_set_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) or
      (nvl(p_budget_calendar_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) or
      (nvl(p_rounding_factor, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) or
      (nvl(p_flex_mapping_set_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) or
      (nvl(p_stage_set_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) or
      (nvl(p_current_stage_seq, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM)) then
  begin
    /* Bug 3458191: The following is removed using new conditions instead
    for c_WS_Rec in c_WS loop
      l_gl_cutoff_period := c_WS_Rec.gl_cutoff_period;
      l_allocrule_set_id := c_WS_Rec.allocrule_set_id;
      l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
      l_rounding_factor := c_WS_Rec.rounding_factor;
      l_flex_mapping_set_id := c_WS_Rec.flex_mapping_set_id;
      l_stage_set_id := c_WS_Rec.stage_set_id;
      l_current_stage_seq := c_WS_Rec.current_stage_seq;
    end loop;
    */

    /* Bug 3458191 start */
    -- Check the g_ws_creation_flag to determine whether to use the
    -- cached worksheet values.
    IF PSB_WORKSHEET.g_ws_creation_flag
       AND
       PSB_WORKSHEET.g_worksheet_id = p_worksheet_id
    THEN
      -- Retrieve the worksheet values from cache to avoiding extra query
      l_global_worksheet_id := PSB_WORKSHEET.g_global_worksheet_id;
      l_local_copy_flag := PSB_WORKSHEET.g_local_copy_flag;
      l_gl_cutoff_period := PSB_WORKSHEET.g_gl_cutoff_period;
      l_allocrule_set_id := PSB_WORKSHEET.g_allocrule_set_id;
      l_budget_calendar_id := PSB_WORKSHEET.g_budget_calendar_id;
      l_rounding_factor := PSB_WORKSHEET.g_rounding_factor;
      l_flex_mapping_set_id := PSB_WORKSHEET.g_flex_mapping_set_id;
      l_stage_set_id := PSB_WORKSHEET.g_stage_set_id;
      l_current_stage_seq := PSB_WORKSHEET.g_current_stage_seq;

   /*Bug:5929875:start*/
    ELSIF (PSB_WS_ACCT1.g_global_worksheet_id IS NOT NULL
           AND
           PSB_WS_ACCT1.g_global_worksheet_id = p_worksheet_id)
    THEN
      l_global_worksheet_id := PSB_WS_ACCT1.g_global_worksheet_id;
      l_local_copy_flag     := PSB_WS_ACCT1.g_local_copy_flag;
      l_gl_cutoff_period    := PSB_WS_ACCT1.g_gl_cutoff_period;
      l_allocrule_set_id    := PSB_WS_ACCT1.g_allocrule_set_id;
      l_budget_calendar_id  := PSB_WS_ACCT1.gl_budget_calendar_id;
      l_rounding_factor     := PSB_WS_ACCT1.g_rounding_factor;
      l_flex_mapping_set_id := PSB_WS_ACCT1.g_flex_mapping_set_id;
      l_stage_set_id        := PSB_WS_ACCT1.g_stage_set_id;
      l_current_stage_seq   := PSB_WS_ACCT1.g_current_stage_seq;
   /*Bug:5929875:end*/

    ELSE

      SELECT DECODE(global_worksheet_flag, 'Y', worksheet_id,
                    global_worksheet_id) global_worksheet_id,
             local_copy_flag,
	     /* start bug 3871839 */
	     current_stage_seq
	     /* End bug 3871839 */
           INTO
             l_global_worksheet_id,
             l_local_copy_flag,
	     /* start bug 3871839 */
	     l_current_stage_seq
	     /* end bug 3871839 */
      FROM   psb_worksheets
      WHERE  worksheet_id = p_worksheet_id;

      SELECT gl_cutoff_period,
             allocrule_set_id allocrule_set_id,
             budget_calendar_id,
             rounding_factor,
             stage_set_id,
             flex_mapping_set_id
             /* Bug no :3871839 commented out stage sequence*/
	     /* current_stage_seq */
           INTO
             l_gl_cutoff_period,
             l_allocrule_set_id,
             l_budget_calendar_id,
             l_rounding_factor,
             l_stage_set_id,
             l_flex_mapping_set_id
	     /* Bug No :3871839 Commented out l_current_stage_sequence */
            /*l_current_stage_seq*/
      FROM   psb_worksheets
      WHERE  worksheet_id = l_global_worksheet_id;

   /*Bug:5929875:start*/
      PSB_WS_ACCT1.g_global_worksheet_id     :=  l_global_worksheet_id;
      PSB_WS_ACCT1.g_local_copy_flag	       :=  l_local_copy_flag;
      PSB_WS_ACCT1.g_gl_cutoff_period	       :=  l_gl_cutoff_period;
      PSB_WS_ACCT1.g_allocrule_set_id	       :=  l_allocrule_set_id;
      PSB_WS_ACCT1.gl_budget_calendar_id     :=  l_budget_calendar_id;
      PSB_WS_ACCT1.g_rounding_factor	       :=  l_rounding_factor;
      PSB_WS_ACCT1.g_flex_mapping_set_id     :=  l_flex_mapping_set_id;
      PSB_WS_ACCT1.g_stage_set_id	           :=  l_stage_set_id;
      PSB_WS_ACCT1.g_current_stage_seq       :=  l_current_stage_seq;
   /*Bug:5929875:end*/
    END IF;
    /* Bug 3458191 end */
  end;
  end if;

  -- Override default values for parameters that were passed in

  if p_gl_cutoff_period <> FND_API.G_MISS_DATE then
    l_gl_cutoff_period := p_gl_cutoff_period;
  end if;

  if p_allocrule_set_id <> FND_API.G_MISS_NUM then
    l_allocrule_set_id := p_allocrule_set_id;
  end if;

  if p_budget_calendar_id <> FND_API.G_MISS_NUM then
    l_budget_calendar_id := p_budget_calendar_id;
  end if;

  if p_rounding_factor <> FND_API.G_MISS_NUM then
    l_rounding_factor := p_rounding_factor;
  end if;

  if p_stage_set_id <> FND_API.G_MISS_NUM then
    l_stage_set_id := p_stage_set_id;
  end if;

  if p_flex_mapping_set_id <> FND_API.G_MISS_NUM then
    l_flex_mapping_set_id := p_flex_mapping_set_id;
  end if;

  if p_current_stage_seq <> FND_API.G_MISS_NUM then
    l_current_stage_seq := p_current_stage_seq;
  end if;

  if p_start_stage_seq = FND_API.G_MISS_NUM then
    l_start_stage_seq := l_current_stage_seq;
  else
    l_start_stage_seq := p_start_stage_seq;
  end if;

  /* Bug 3458191: Change condition since global_worksheet_id and
     local_copy_flag have cached.
  if ((PSB_WS_POS1.g_global_worksheet_id is null) or
      (PSB_WS_POS1.g_local_copy_flag is null)) then
  begin

    for c_WS_Rec in c_WS loop
      l_global_worksheet_id := c_WS_Rec.global_worksheet_id;
      l_local_copy_flag := c_WS_Rec.local_copy_flag;
    end loop;

  end;
  else
  */

  -- Bug 3458191: New condition to replace the above ELSE condition
  if ((PSB_WS_POS1.g_global_worksheet_id is not null)
      and
      (PSB_WS_POS1.g_local_copy_flag is not null))
  then
    l_global_worksheet_id := PSB_WS_POS1.g_global_worksheet_id;
    l_local_copy_flag := PSB_WS_POS1.g_local_copy_flag;
  end if;

  if p_service_package_id = FND_API.G_MISS_NUM then
  begin

    for c_sp_rec in c_sp loop
      l_service_package_id := c_sp_rec.service_package_id;
    end loop;

  end;
  else
    l_service_package_id := p_service_package_id;
  end if;

  -- Either CCID or (Chart of Accounts ID and Concatenated Segments) must
  -- be entered

  if p_ccid = FND_API.G_MISS_NUM then
  begin

    if ((p_flex_code = FND_API.G_MISS_NUM) or
	(p_concatenated_segments = FND_API.G_MISS_CHAR)) then

      message_token('ROUTINE', 'PSB_WS_ACCT1.Create_Account_Dist');
      add_message('PSB', 'PSB_INVALID_ARGUMENT');
      raise FND_API.G_EXC_ERROR;

    end if;

    l_ccid := FND_FLEX_EXT.Get_CCID
		 (application_short_name => 'SQLGL',
		  key_flex_code => 'GL#',
		  structure_number => p_flex_code,
		  validation_date => to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),
		  concatenated_segments => p_concatenated_segments);

    if l_ccid = 0 then
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  else
    l_ccid := p_ccid;
  end if;

  -- Cache Budget Calendar so that it can be reused across the Worksheet Creation
  -- Modules

  if l_budget_calendar_id <> nvl(g_budget_calendar_id, FND_API.G_MISS_NUM) then
  begin

    Cache_Budget_Calendar
	 (p_return_status => l_return_status,
	  p_budget_calendar_id => l_budget_calendar_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  -- Find last Budget Period for the Budget Year. The rounding difference is adjusted
  -- to the last period

  for l_year_index in 1..g_num_budget_years loop

    if g_budget_years(l_year_index).budget_year_id = p_budget_year_id then
      l_last_period_index := g_budget_years(l_year_index).last_period_index;
      l_budget_year_type_id := g_budget_years(l_year_index).budget_year_type_id;
      l_budget_year_type := g_budget_years(l_year_index).year_type;            --bug:7597096
      exit;
    end if;

  end loop;

  -- If FlexMapping Set has been defined map the ccid based on the flex mapping
  -- Flex Mapping is done only for detailed non-position accounts that have an annual balance

  if ((p_map_accounts) and
      (nvl(p_template_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) and (p_ytd_amount <> 0)) then
  begin

    l_ccid := Map_Account
		 (p_flex_mapping_set_id => l_flex_mapping_set_id,
		  p_ccid => l_ccid,
		  p_budget_year_type_id => l_budget_year_type_id);

    l_flexmap_increment := TRUE;

  end;
  end if;

  -- p_check_spal_exists must be set to FND_API.G_TRUE if called from any Worksheet
  -- Modification module (Form, Spreadsheet, OFA)

  if FND_API.to_boolean(p_check_spal_exists) then
  begin

    -- Find existing Account Line that matches the Account Line specified by the input
    -- parameters

/*bug:5929875:start:replaced the dynamic sql logic with static sqls*/
    if p_position_line_id = FND_API.G_MISS_NUM then

      FOR l_aline_rec IN c_aline_csr LOOP
         l_spal_id                  := l_aline_rec.account_line_id;
         l_spal_budget_group_id     := l_aline_rec.budget_group_id;
         l_spytd_amount             := l_aline_rec.ytd_amount;
         l_original_start_stage_seq := l_aline_rec.start_stage_seq;

         l_spal_exists := TRUE;
      END LOOP;
    else
      FOR l_aline_pos_rec IN c_aline_pos_csr LOOP
         l_spal_id                  := l_aline_pos_rec.account_line_id;
         l_spal_budget_group_id     := l_aline_pos_rec.budget_group_id;
         l_spytd_amount             := l_aline_pos_rec.ytd_amount;
         l_original_start_stage_seq := l_aline_pos_rec.start_stage_seq;

         l_spal_exists := TRUE;
      END LOOP;

    end if;
/*bug:5929875:end*/

    if l_spal_budget_group_id <> p_budget_group_id then
      l_budget_group_changed := TRUE;
    end if;

  end;
  end if;

  -- p_distribute_flag must be set to FND_API.G_TRUE to automatically
  -- distribute YTD Amounts into Period Amounts for CY and PP Budget
  -- Years. This may be set to FND_API.G_TRUE when called from any
  -- Worksheet Modification module (Form, Spreadsheet, OFA)

  if FND_API.to_Boolean(p_distribute_flag) then
  begin

    for c_CCID_Rec in c_CCID loop
      l_ccid_start_date := c_CCID_Rec.start_date_active;
      l_ccid_end_date := c_CCID_Rec.end_date_active;
    end loop;

    for l_year_index in 1..g_num_budget_years loop

      if g_budget_years(l_year_index).budget_year_id = p_budget_year_id then
      begin

	l_start_date := g_budget_years(l_year_index).start_date;
	l_end_date := g_budget_years(l_year_index).end_date;

	for l_init_index in 1..l_budget_periods.Count loop
	  l_budget_periods(l_init_index).budget_period_id := null;
	  l_budget_periods(l_init_index).start_date := null;
	  l_budget_periods(l_init_index).end_date := null;
	  l_budget_periods(l_init_index).long_sequence_no := null;
	  l_budget_periods(l_init_index).budget_year_id := null;
	end loop;

	l_init_index := 1;

	for l_period_index in 1..g_num_budget_periods loop

	  if g_budget_periods(l_period_index).budget_year_id = p_budget_year_id then
	  begin

	    -- Pick up all Budget Periods for a PP Budget Year or all Budget Periods after the
	    -- GL Cutoff Date for a CY Budget Year

	    if (((l_ccid_start_date is null) or
		 (l_ccid_start_date <= g_budget_periods(l_period_index).start_date)) and
		((l_ccid_end_date is null) or
		 (l_ccid_end_date >= g_budget_periods(l_period_index).end_date)) and
		((g_budget_years(l_year_index).year_type = 'PP') or
		((g_budget_years(l_year_index).year_type = 'CY') and
		((l_gl_cutoff_period is null) or (l_gl_cutoff_period < g_budget_periods(l_period_index).start_date))))) then
	    begin

	      l_budget_periods(l_init_index).budget_period_id := g_budget_periods(l_period_index).budget_period_id;
	      l_budget_periods(l_init_index).long_sequence_no := g_budget_periods(l_period_index).long_sequence_no;
	      l_budget_periods(l_init_index).start_date := g_budget_periods(l_period_index).start_date;
	      l_budget_periods(l_init_index).end_date := g_budget_periods(l_period_index).end_date;
	      l_budget_periods(l_init_index).budget_year_id := p_budget_year_id;

	      l_init_index := l_init_index + 1;

	    end;
	    end if;

	  end;
	  end if;

	end loop;

      end;
      end if;

    end loop;

    for l_index in 1..g_max_num_amounts loop
      l_period_amount_tbl(l_index) := null;
    end loop;

    /* Bug 3352171 start */
    -- Comment out the following two lines. The allocation logic will be
    -- handled in the PSB_WS_ACCT2.Distribute_Account_Lines function.
    --if nvl(l_allocrule_set_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
    --begin
    /* Bug 3352171 end */

    -- If existing Account Line was found, add YTD Amount to YTD Amount of
    -- existing line

    if l_spal_exists then
      /* bug start 3996052 */
      IF NVL(p_update_cy_estimate, 'N') = 'Y' THEN
	l_ytd_amount := nvl(p_ytd_amount, 0);
      ELSE
        l_ytd_amount := nvl(p_ytd_amount, 0) + l_spytd_amount;
      END IF;
      /* bug end 3996052 */
    else
      l_ytd_amount := nvl(p_ytd_amount, 0);
    end if;

    PSB_WS_ACCT2.Distribute_Account_Lines
    ( p_return_status => l_return_status,
      p_worksheet_id => p_worksheet_id,
      p_flex_mapping_set_id => l_flex_mapping_set_id,
      p_budget_year_type_id => l_budget_year_type_id,
      p_allocrule_set_id => l_allocrule_set_id,
      p_budget_calendar_id => l_budget_calendar_id,
      p_currency_code => p_currency_code,
      p_ccid => l_ccid,
      p_ytd_amount => l_ytd_amount,
      p_allocation_type => NULL,     --Bug:5013900:changed value from 'PERCENT' to NULL.
      /* Bug No 2342169 Start */
      p_rounding_factor => l_rounding_factor,
      /* Bug No 2342169 End */
      p_effective_start_date => l_start_date,
      p_effective_end_date => l_end_date,
      p_budget_periods => l_budget_periods,
      p_period_amount => l_period_amount_tbl);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    /* Bug 3352171 start */
    -- comment out the following two lines. The allocation logic should not
    -- be handling here.
    --end;
    --end if;
    /* Bug 3352171 end */

  end;
  end if;

  l_ytd_amount := 0;

  -- First, try to update existing Account Line to determine if it exists; if it does not exist
  -- insert the new Account Line

  for l_index in 1..g_max_num_amounts loop

    if FND_API.to_Boolean(p_distribute_flag) then
    begin

      if l_rounding_factor is null then
	l_period_amount := l_period_amount_tbl(l_index);
      else
	l_period_amount := ROUND(l_period_amount_tbl(l_index)/l_rounding_factor) * l_rounding_factor;
      end if;

      l_ytd_amount := l_ytd_amount + nvl(l_period_amount, 0);

    end;
    else
    begin

      if l_rounding_factor is null then
	l_period_amount := p_period_amount(l_index);
      else
	l_period_amount := ROUND(p_period_amount(l_index)/l_rounding_factor) * l_rounding_factor;
      end if;

      l_ytd_amount := l_ytd_amount + nvl(l_period_amount, 0);

    end;
    end if;

  end loop;

  if l_rounding_factor is null then
  begin

    if l_spal_exists then
      /* bug start 3996052 */
      IF NVL(p_update_cy_estimate, 'N') = 'Y' THEN
        l_rounded_ytd_amount := nvl(p_ytd_amount, 0);
      ELSE
        l_rounded_ytd_amount := nvl(p_ytd_amount, 0) + l_spytd_amount;
      END IF;
      /* bug end 3996052 */
    else
      l_rounded_ytd_amount := nvl(p_ytd_amount, 0);
    end if;

    l_rounding_difference := 0;

  end;
  else
  begin

    l_rounded_ytd_amount := ROUND(nvl(p_ytd_amount, 0)/l_rounding_factor) * l_rounding_factor;

    if l_spal_exists then
      /* bug start 3996052 */
      IF NVL(p_update_cy_estimate, 'N') = 'Y' THEN
        l_rounded_ytd_amount := l_rounded_ytd_amount;
      ELSE
        l_rounded_ytd_amount := l_rounded_ytd_amount + l_spytd_amount;
      END IF;
      /* bug end 3996052 */
    end if;

/* Bug No 2379695 Start */
-- Commented the IF condition
--    if ((l_ytd_amount > 0) and (l_rounded_ytd_amount > 0)) then
      l_rounding_difference := l_rounded_ytd_amount - l_ytd_amount;
--    end if;
/* Bug No 2379695 End */

  end;
  end if;

  for l_index in 1..g_max_num_amounts loop

    if FND_API.to_Boolean(p_distribute_flag) then
    begin

      if l_rounding_factor is null then
	l_period_amount := l_period_amount_tbl(l_index);
      else
	l_period_amount := ROUND(l_period_amount_tbl(l_index)/l_rounding_factor) * l_rounding_factor;
      end if;

    end;
    else
    begin

      if l_rounding_factor is null then
	l_period_amount := p_period_amount(l_index);
      else
	l_period_amount := ROUND(p_period_amount(l_index)/l_rounding_factor) * l_rounding_factor;
      end if;

    end;
    end if;

    if l_period_amount is null then
    begin
     --bug:7290972:replaced l_rounded_ytd_amount with l_rounding_difference
      if ((l_index = l_last_period_index) and (l_rounding_difference <> 0)) then
	l_period_amounts(l_index) := nvl(l_rounding_difference, 0);
      else
	l_period_amounts(l_index) := null;
      end if;

    end;
    else
    begin
      --bug:7290972:replaced l_rounded_ytd_amount with l_rounding_difference
      if ((l_index = l_last_period_index) and (l_rounding_difference <> 0)) then
	l_period_amounts(l_index) := l_period_amount + nvl(l_rounding_difference, 0);
      else
	l_period_amounts(l_index) := l_period_amount;
      end if;

    end;
    end if;

  end loop;

  /* Bug 3347507 start */
  -- If an existing account line was found, check whether the start_stage_seq
  -- is the same as current stage seq. If start_stage_seq is differ from the
  -- current stage seq, the program should create a new account line with the
  -- incremented values for the current stage seq and end stage the current
  -- account line.
  -- if l_spal_exists then
  if l_spal_exists and
     (l_original_start_stage_seq <> l_current_stage_seq
      OR l_budget_year_type = 'CY') then                     --bug:7597096
  begin

    Create_Account_Dist
    (
      p_api_version                 => 1.0,
      p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
      p_return_status               => l_return_status,
      p_worksheet_id                => p_worksheet_id,
      p_distribute_flag             => p_distribute_flag,
      p_account_line_id             => l_spal_id,
      p_ytd_amount                  => l_rounded_ytd_amount,
      p_service_package_id          => l_service_package_id,
      p_period_amount               => p_period_amount,
      /* start bug 4128196 */
      p_update_cy_estimate          => NVL(p_update_cy_estimate, 'N')
      /* end bug  4128196 */
    );
  end;

  -- If existing Account Line was found but the start stage is the same as the current stage,
  -- increment the values for the account line with the values passed in by the input parameters
  elsif l_spal_exists then
  /* Bug 3347507 end */
  begin


    update PSB_WS_ACCOUNT_LINES a
       set budget_group_id = p_budget_group_id,
	   current_stage_seq = l_current_stage_seq,
	   end_stage_seq = decode(p_end_stage_seq, FND_API.G_MISS_NUM, end_stage_seq, p_end_stage_seq),
	   annual_fte = decode(nvl(p_annual_fte, FND_API.G_MISS_NUM), FND_API.G_MISS_NUM, annual_fte, nvl(p_annual_fte, FND_API.G_MISS_NUM)),
	   copy_of_account_line_id = decode(p_copy_of_account_line_id, FND_API.G_MISS_NUM, copy_of_account_line_id, p_copy_of_account_line_id),
	   period1_amount = l_period_amounts(1), period2_amount = l_period_amounts(2),
	   period3_amount = l_period_amounts(3), period4_amount = l_period_amounts(4),
	   period5_amount = l_period_amounts(5), period6_amount = l_period_amounts(6),
	   period7_amount = l_period_amounts(7), period8_amount = l_period_amounts(8),
	   period9_amount = l_period_amounts(9), period10_amount = l_period_amounts(10),
	   period11_amount = l_period_amounts(11), period12_amount = l_period_amounts(12),
	   period13_amount = l_period_amounts(13), period14_amount = l_period_amounts(14),
	   period15_amount = l_period_amounts(15), period16_amount = l_period_amounts(16),
	   period17_amount = l_period_amounts(17), period18_amount = l_period_amounts(18),
	   period19_amount = l_period_amounts(19), period20_amount = l_period_amounts(20),
	   period21_amount = l_period_amounts(21), period22_amount = l_period_amounts(22),
	   period23_amount = l_period_amounts(23), period24_amount = l_period_amounts(24),
	   period25_amount = l_period_amounts(25), period26_amount = l_period_amounts(26),
	   period27_amount = l_period_amounts(27), period28_amount = l_period_amounts(28),
	   period29_amount = l_period_amounts(29), period30_amount = l_period_amounts(30),
	   period31_amount = l_period_amounts(31), period32_amount = l_period_amounts(32),
	   period33_amount = l_period_amounts(33), period34_amount = l_period_amounts(34),
	   period35_amount = l_period_amounts(35), period36_amount = l_period_amounts(36),
	   period37_amount = l_period_amounts(37), period38_amount = l_period_amounts(38),
	   period39_amount = l_period_amounts(39), period40_amount = l_period_amounts(40),
	   period41_amount = l_period_amounts(41), period42_amount = l_period_amounts(42),
	   period43_amount = l_period_amounts(43), period44_amount = l_period_amounts(44),
	   period45_amount = l_period_amounts(45), period46_amount = l_period_amounts(46),
	   period47_amount = l_period_amounts(47), period48_amount = l_period_amounts(48),
	   period49_amount = l_period_amounts(49), period50_amount = l_period_amounts(50),
	   period51_amount = l_period_amounts(51), period52_amount = l_period_amounts(52),
	   period53_amount = l_period_amounts(53), period54_amount = l_period_amounts(54),
	   period55_amount = l_period_amounts(55), period56_amount = l_period_amounts(56),
	   period57_amount = l_period_amounts(57), period58_amount = l_period_amounts(58),
	   period59_amount = l_period_amounts(59), period60_amount = l_period_amounts(60),
	   ytd_amount = l_rounded_ytd_amount,
	   last_update_date = sysdate,
	   last_updated_by = l_userid,
	   last_update_login = l_loginid
     where account_line_id = l_spal_id;

      l_account_line_id := l_spal_id;


  end;
  else
  begin


    if p_template_id <> FND_API.G_MISS_NUM then
    begin

      -- Non-Position Account Line must be unique across Global Worksheets and
      -- Local Copies of Worksheets; Position Line IDs are anyway unique across
      -- Global Worksheets and Local Copies of Worksheets


      for c_wal_rec in c_wal1 loop
	l_account_line_id := c_wal_rec.account_line_id;
	l_budget_group_id := c_wal_rec.budget_group_id;
	l_current_requestid := c_wal_rec.request_id;
	l_current_fte := c_wal_rec.annual_fte; l_current_ytdamt := c_wal_rec.ytd_amount;
	l_current_prdamt(1) := c_wal_rec.period1_amount; l_current_prdamt(2) := c_wal_rec.period2_amount;
	l_current_prdamt(3) := c_wal_rec.period3_amount; l_current_prdamt(4) := c_wal_rec.period4_amount;
	l_current_prdamt(5) := c_wal_rec.period5_amount; l_current_prdamt(6) := c_wal_rec.period6_amount;
	l_current_prdamt(7) := c_wal_rec.period7_amount; l_current_prdamt(8) := c_wal_rec.period8_amount;
	l_current_prdamt(9) := c_wal_rec.period9_amount; l_current_prdamt(10) := c_wal_rec.period10_amount;
	l_current_prdamt(11) := c_wal_rec.period11_amount; l_current_prdamt(12) := c_wal_rec.period12_amount;
	l_current_prdamt(13) := c_wal_rec.period13_amount; l_current_prdamt(14) := c_wal_rec.period14_amount;
	l_current_prdamt(15) := c_wal_rec.period15_amount; l_current_prdamt(16) := c_wal_rec.period16_amount;
	l_current_prdamt(17) := c_wal_rec.period17_amount; l_current_prdamt(18) := c_wal_rec.period18_amount;
	l_current_prdamt(19) := c_wal_rec.period19_amount; l_current_prdamt(20) := c_wal_rec.period20_amount;
	l_current_prdamt(21) := c_wal_rec.period21_amount; l_current_prdamt(22) := c_wal_rec.period22_amount;
	l_current_prdamt(23) := c_wal_rec.period23_amount; l_current_prdamt(24) := c_wal_rec.period24_amount;
	l_current_prdamt(25) := c_wal_rec.period25_amount; l_current_prdamt(26) := c_wal_rec.period26_amount;
	l_current_prdamt(27) := c_wal_rec.period27_amount; l_current_prdamt(28) := c_wal_rec.period28_amount;
	l_current_prdamt(29) := c_wal_rec.period29_amount; l_current_prdamt(30) := c_wal_rec.period30_amount;
	l_current_prdamt(31) := c_wal_rec.period31_amount; l_current_prdamt(32) := c_wal_rec.period32_amount;
	l_current_prdamt(33) := c_wal_rec.period33_amount; l_current_prdamt(34) := c_wal_rec.period34_amount;
	l_current_prdamt(35) := c_wal_rec.period35_amount; l_current_prdamt(36) := c_wal_rec.period36_amount;
	l_current_prdamt(37) := c_wal_rec.period37_amount; l_current_prdamt(38) := c_wal_rec.period38_amount;
	l_current_prdamt(39) := c_wal_rec.period39_amount; l_current_prdamt(40) := c_wal_rec.period40_amount;
	l_current_prdamt(41) := c_wal_rec.period41_amount; l_current_prdamt(42) := c_wal_rec.period42_amount;
	l_current_prdamt(43) := c_wal_rec.period43_amount; l_current_prdamt(44) := c_wal_rec.period44_amount;
	l_current_prdamt(45) := c_wal_rec.period45_amount; l_current_prdamt(46) := c_wal_rec.period46_amount;
	l_current_prdamt(47) := c_wal_rec.period47_amount; l_current_prdamt(48) := c_wal_rec.period48_amount;
	l_current_prdamt(49) := c_wal_rec.period49_amount; l_current_prdamt(50) := c_wal_rec.period50_amount;
	l_current_prdamt(51) := c_wal_rec.period51_amount; l_current_prdamt(52) := c_wal_rec.period52_amount;
	l_current_prdamt(53) := c_wal_rec.period53_amount; l_current_prdamt(54) := c_wal_rec.period54_amount;
	l_current_prdamt(55) := c_wal_rec.period55_amount; l_current_prdamt(56) := c_wal_rec.period56_amount;
	l_current_prdamt(57) := c_wal_rec.period57_amount; l_current_prdamt(58) := c_wal_rec.period58_amount;
	l_current_prdamt(59) := c_wal_rec.period59_amount; l_current_prdamt(60) := c_wal_rec.period60_amount;
      end loop;

      if ((nvl(l_current_requestid, FND_API.G_MISS_NUM) <> nvl(l_requestid, FND_API.G_MISS_NUM)) or
	  (p_balance_type = 'E')) then
	l_flexmap_increment := FALSE;
      end if;

      if l_flexmap_increment then
      begin

	update PSB_WS_ACCOUNT_LINES
	   set budget_group_id = p_budget_group_id,
	       current_stage_seq = l_current_stage_seq,
	       end_stage_seq = decode(p_end_stage_seq, FND_API.G_MISS_NUM, end_stage_seq, p_end_stage_seq),
	       annual_fte = decode(nvl(p_annual_fte, FND_API.G_MISS_NUM), FND_API.G_MISS_NUM, annual_fte, p_annual_fte + nvl(l_current_fte, 0)),
	       copy_of_account_line_id = decode(p_copy_of_account_line_id, FND_API.G_MISS_NUM, copy_of_account_line_id, p_copy_of_account_line_id),
	       period1_amount = l_period_amounts(1) + l_current_prdamt(1),
	       period2_amount = l_period_amounts(2) + l_current_prdamt(2),
	       period3_amount = l_period_amounts(3) + l_current_prdamt(3),
	       period4_amount = l_period_amounts(4) + l_current_prdamt(4),
	       period5_amount = l_period_amounts(5) + l_current_prdamt(5),
	       period6_amount = l_period_amounts(6) + l_current_prdamt(6),
	       period7_amount = l_period_amounts(7) + l_current_prdamt(7),
	       period8_amount = l_period_amounts(8) + l_current_prdamt(8),
	       period9_amount = l_period_amounts(9) + l_current_prdamt(9),
	       period10_amount = l_period_amounts(10) + l_current_prdamt(10),
	       period11_amount = l_period_amounts(11) + l_current_prdamt(11),
	       period12_amount = l_period_amounts(12) + l_current_prdamt(12),
	       period13_amount = l_period_amounts(13) + l_current_prdamt(13),
	       period14_amount = l_period_amounts(14) + l_current_prdamt(14),
	       period15_amount = l_period_amounts(15) + l_current_prdamt(15),
	       period16_amount = l_period_amounts(16) + l_current_prdamt(16),
	       period17_amount = l_period_amounts(17) + l_current_prdamt(17),
	       period18_amount = l_period_amounts(18) + l_current_prdamt(18),
	       period19_amount = l_period_amounts(19) + l_current_prdamt(19),
	       period20_amount = l_period_amounts(20) + l_current_prdamt(20),
	       period21_amount = l_period_amounts(21) + l_current_prdamt(21),
	       period22_amount = l_period_amounts(22) + l_current_prdamt(22),
	       period23_amount = l_period_amounts(23) + l_current_prdamt(23),
	       period24_amount = l_period_amounts(24) + l_current_prdamt(24),
	       period25_amount = l_period_amounts(25) + l_current_prdamt(25),
	       period26_amount = l_period_amounts(26) + l_current_prdamt(26),
	       period27_amount = l_period_amounts(27) + l_current_prdamt(27),
	       period28_amount = l_period_amounts(28) + l_current_prdamt(28),
	       period29_amount = l_period_amounts(29) + l_current_prdamt(29),
	       period30_amount = l_period_amounts(30) + l_current_prdamt(30),
	       period31_amount = l_period_amounts(31) + l_current_prdamt(31),
	       period32_amount = l_period_amounts(32) + l_current_prdamt(32),
	       period33_amount = l_period_amounts(33) + l_current_prdamt(33),
	       period34_amount = l_period_amounts(34) + l_current_prdamt(34),
	       period35_amount = l_period_amounts(35) + l_current_prdamt(35),
	       period36_amount = l_period_amounts(36) + l_current_prdamt(36),
	       period37_amount = l_period_amounts(37) + l_current_prdamt(37),
	       period38_amount = l_period_amounts(38) + l_current_prdamt(38),
	       period39_amount = l_period_amounts(39) + l_current_prdamt(39),
	       period40_amount = l_period_amounts(40) + l_current_prdamt(40),
	       period41_amount = l_period_amounts(41) + l_current_prdamt(41),
	       period42_amount = l_period_amounts(42) + l_current_prdamt(42),
	       period43_amount = l_period_amounts(43) + l_current_prdamt(43),
	       period44_amount = l_period_amounts(44) + l_current_prdamt(44),
	       period45_amount = l_period_amounts(45) + l_current_prdamt(45),
	       period46_amount = l_period_amounts(46) + l_current_prdamt(46),
	       period47_amount = l_period_amounts(47) + l_current_prdamt(47),
	       period48_amount = l_period_amounts(48) + l_current_prdamt(48),
	       period49_amount = l_period_amounts(49) + l_current_prdamt(49),
	       period50_amount = l_period_amounts(50) + l_current_prdamt(50),
	       period51_amount = l_period_amounts(51) + l_current_prdamt(51),
	       period52_amount = l_period_amounts(52) + l_current_prdamt(52),
	       period53_amount = l_period_amounts(53) + l_current_prdamt(53),
	       period54_amount = l_period_amounts(54) + l_current_prdamt(54),
	       period55_amount = l_period_amounts(55) + l_current_prdamt(55),
	       period56_amount = l_period_amounts(56) + l_current_prdamt(56),
	       period57_amount = l_period_amounts(57) + l_current_prdamt(57),
	       period58_amount = l_period_amounts(58) + l_current_prdamt(58),
	       period59_amount = l_period_amounts(59) + l_current_prdamt(59),
	       period60_amount = l_period_amounts(60) + l_current_prdamt(60),
	       ytd_amount = l_rounded_ytd_amount + l_current_ytdamt,
	       last_update_date = sysdate,
	       last_updated_by = l_userid,
	       last_update_login = l_loginid,
	       request_id = l_requestid
	 where account_line_id = l_account_line_id;

      end;
      else
      begin

	update PSB_WS_ACCOUNT_LINES
	   set budget_group_id = p_budget_group_id,
	       current_stage_seq = l_current_stage_seq,
	       end_stage_seq = decode(p_end_stage_seq, FND_API.G_MISS_NUM, end_stage_seq, p_end_stage_seq),
	       annual_fte = decode(nvl(p_annual_fte, FND_API.G_MISS_NUM), FND_API.G_MISS_NUM, annual_fte, p_annual_fte),
	       copy_of_account_line_id = decode(p_copy_of_account_line_id, FND_API.G_MISS_NUM, copy_of_account_line_id, p_copy_of_account_line_id),
	       period1_amount = l_period_amounts(1), period2_amount = l_period_amounts(2),
	       period3_amount = l_period_amounts(3), period4_amount = l_period_amounts(4),
	       period5_amount = l_period_amounts(5), period6_amount = l_period_amounts(6),
	       period7_amount = l_period_amounts(7), period8_amount = l_period_amounts(8),
	       period9_amount = l_period_amounts(9), period10_amount = l_period_amounts(10),
	       period11_amount = l_period_amounts(11), period12_amount = l_period_amounts(12),
	       period13_amount = l_period_amounts(13), period14_amount = l_period_amounts(14),
	       period15_amount = l_period_amounts(15), period16_amount = l_period_amounts(16),
	       period17_amount = l_period_amounts(17), period18_amount = l_period_amounts(18),
	       period19_amount = l_period_amounts(19), period20_amount = l_period_amounts(20),
	       period21_amount = l_period_amounts(21), period22_amount = l_period_amounts(22),
	       period23_amount = l_period_amounts(23), period24_amount = l_period_amounts(24),
	       period25_amount = l_period_amounts(25), period26_amount = l_period_amounts(26),
	       period27_amount = l_period_amounts(27), period28_amount = l_period_amounts(28),
	       period29_amount = l_period_amounts(29), period30_amount = l_period_amounts(30),
	       period31_amount = l_period_amounts(31), period32_amount = l_period_amounts(32),
	       period33_amount = l_period_amounts(33), period34_amount = l_period_amounts(34),
	       period35_amount = l_period_amounts(35), period36_amount = l_period_amounts(36),
	       period37_amount = l_period_amounts(37), period38_amount = l_period_amounts(38),
	       period39_amount = l_period_amounts(39), period40_amount = l_period_amounts(40),
	       period41_amount = l_period_amounts(41), period42_amount = l_period_amounts(42),
	       period43_amount = l_period_amounts(43), period44_amount = l_period_amounts(44),
	       period45_amount = l_period_amounts(45), period46_amount = l_period_amounts(46),
	       period47_amount = l_period_amounts(47), period48_amount = l_period_amounts(48),
	       period49_amount = l_period_amounts(49), period50_amount = l_period_amounts(50),
	       period51_amount = l_period_amounts(51), period52_amount = l_period_amounts(52),
	       period53_amount = l_period_amounts(53), period54_amount = l_period_amounts(54),
	       period55_amount = l_period_amounts(55), period56_amount = l_period_amounts(56),
	       period57_amount = l_period_amounts(57), period58_amount = l_period_amounts(58),
	       period59_amount = l_period_amounts(59), period60_amount = l_period_amounts(60),
	       ytd_amount = l_rounded_ytd_amount,
	       last_update_date = sysdate,
	       last_updated_by = l_userid,
	       last_update_login = l_loginid,
	       request_id = l_requestid
	 where account_line_id = l_account_line_id;

      end;
      end if;

        if l_budget_group_id <> p_budget_group_id then
	  l_budget_group_changed := TRUE;
        end if;


    end;
    else
    begin

      if p_position_line_id <> FND_API.G_MISS_NUM then
      begin


	for c_wal_rec in c_wal2 loop
	  l_account_line_id := c_wal_rec.account_line_id;
	  l_budget_group_id := c_wal_rec.budget_group_id;
	  l_current_requestid := c_wal_rec.request_id;
	  l_current_fte := c_wal_rec.annual_fte; l_current_ytdamt := c_wal_rec.ytd_amount;
	  l_current_prdamt(1) := c_wal_rec.period1_amount; l_current_prdamt(2) := c_wal_rec.period2_amount;
	  l_current_prdamt(3) := c_wal_rec.period3_amount; l_current_prdamt(4) := c_wal_rec.period4_amount;
	  l_current_prdamt(5) := c_wal_rec.period5_amount; l_current_prdamt(6) := c_wal_rec.period6_amount;
	  l_current_prdamt(7) := c_wal_rec.period7_amount; l_current_prdamt(8) := c_wal_rec.period8_amount;
	  l_current_prdamt(9) := c_wal_rec.period9_amount; l_current_prdamt(10) := c_wal_rec.period10_amount;
	  l_current_prdamt(11) := c_wal_rec.period11_amount; l_current_prdamt(12) := c_wal_rec.period12_amount;
	  l_current_prdamt(13) := c_wal_rec.period13_amount; l_current_prdamt(14) := c_wal_rec.period14_amount;
	  l_current_prdamt(15) := c_wal_rec.period15_amount; l_current_prdamt(16) := c_wal_rec.period16_amount;
	  l_current_prdamt(17) := c_wal_rec.period17_amount; l_current_prdamt(18) := c_wal_rec.period18_amount;
	  l_current_prdamt(19) := c_wal_rec.period19_amount; l_current_prdamt(20) := c_wal_rec.period20_amount;
	  l_current_prdamt(21) := c_wal_rec.period21_amount; l_current_prdamt(22) := c_wal_rec.period22_amount;
	  l_current_prdamt(23) := c_wal_rec.period23_amount; l_current_prdamt(24) := c_wal_rec.period24_amount;
	  l_current_prdamt(25) := c_wal_rec.period25_amount; l_current_prdamt(26) := c_wal_rec.period26_amount;
	  l_current_prdamt(27) := c_wal_rec.period27_amount; l_current_prdamt(28) := c_wal_rec.period28_amount;
	  l_current_prdamt(29) := c_wal_rec.period29_amount; l_current_prdamt(30) := c_wal_rec.period30_amount;
	  l_current_prdamt(31) := c_wal_rec.period31_amount; l_current_prdamt(32) := c_wal_rec.period32_amount;
	  l_current_prdamt(33) := c_wal_rec.period33_amount; l_current_prdamt(34) := c_wal_rec.period34_amount;
	  l_current_prdamt(35) := c_wal_rec.period35_amount; l_current_prdamt(36) := c_wal_rec.period36_amount;
	  l_current_prdamt(37) := c_wal_rec.period37_amount; l_current_prdamt(38) := c_wal_rec.period38_amount;
	  l_current_prdamt(39) := c_wal_rec.period39_amount; l_current_prdamt(40) := c_wal_rec.period40_amount;
	  l_current_prdamt(41) := c_wal_rec.period41_amount; l_current_prdamt(42) := c_wal_rec.period42_amount;
	  l_current_prdamt(43) := c_wal_rec.period43_amount; l_current_prdamt(44) := c_wal_rec.period44_amount;
	  l_current_prdamt(45) := c_wal_rec.period45_amount; l_current_prdamt(46) := c_wal_rec.period46_amount;
	  l_current_prdamt(47) := c_wal_rec.period47_amount; l_current_prdamt(48) := c_wal_rec.period48_amount;
	  l_current_prdamt(49) := c_wal_rec.period49_amount; l_current_prdamt(50) := c_wal_rec.period50_amount;
	  l_current_prdamt(51) := c_wal_rec.period51_amount; l_current_prdamt(52) := c_wal_rec.period52_amount;
	  l_current_prdamt(53) := c_wal_rec.period53_amount; l_current_prdamt(54) := c_wal_rec.period54_amount;
	  l_current_prdamt(55) := c_wal_rec.period55_amount; l_current_prdamt(56) := c_wal_rec.period56_amount;
	  l_current_prdamt(57) := c_wal_rec.period57_amount; l_current_prdamt(58) := c_wal_rec.period58_amount;
	  l_current_prdamt(59) := c_wal_rec.period59_amount; l_current_prdamt(60) := c_wal_rec.period60_amount;
	end loop;

	if ((nvl(l_current_requestid, FND_API.G_MISS_NUM) <> nvl(l_requestid, FND_API.G_MISS_NUM)) or
	    (p_balance_type = 'E')) then
	  l_flexmap_increment := FALSE;
	end if;

	if l_flexmap_increment then
	begin

	  update PSB_WS_ACCOUNT_LINES
	     set budget_group_id = p_budget_group_id,
		 current_stage_seq = l_current_stage_seq,
		 end_stage_seq = decode(p_end_stage_seq, FND_API.G_MISS_NUM, end_stage_seq, p_end_stage_seq),
		 annual_fte = decode(nvl(p_annual_fte, FND_API.G_MISS_NUM), FND_API.G_MISS_NUM, annual_fte, p_annual_fte + nvl(l_current_fte, 0)),
		 copy_of_account_line_id = decode(p_copy_of_account_line_id, FND_API.G_MISS_NUM, copy_of_account_line_id, p_copy_of_account_line_id),
		 period1_amount = l_period_amounts(1) + l_current_prdamt(1),
		 period2_amount = l_period_amounts(2) + l_current_prdamt(2),
		 period3_amount = l_period_amounts(3) + l_current_prdamt(3),
		 period4_amount = l_period_amounts(4) + l_current_prdamt(4),
		 period5_amount = l_period_amounts(5) + l_current_prdamt(5),
		 period6_amount = l_period_amounts(6) + l_current_prdamt(6),
		 period7_amount = l_period_amounts(7) + l_current_prdamt(7),
		 period8_amount = l_period_amounts(8) + l_current_prdamt(8),
		 period9_amount = l_period_amounts(9) + l_current_prdamt(9),
		 period10_amount = l_period_amounts(10) + l_current_prdamt(10),
		 period11_amount = l_period_amounts(11) + l_current_prdamt(11),
		 period12_amount = l_period_amounts(12) + l_current_prdamt(12),
		 period13_amount = l_period_amounts(13) + l_current_prdamt(13),
		 period14_amount = l_period_amounts(14) + l_current_prdamt(14),
		 period15_amount = l_period_amounts(15) + l_current_prdamt(15),
		 period16_amount = l_period_amounts(16) + l_current_prdamt(16),
		 period17_amount = l_period_amounts(17) + l_current_prdamt(17),
		 period18_amount = l_period_amounts(18) + l_current_prdamt(18),
		 period19_amount = l_period_amounts(19) + l_current_prdamt(19),
		 period20_amount = l_period_amounts(20) + l_current_prdamt(20),
		 period21_amount = l_period_amounts(21) + l_current_prdamt(21),
		 period22_amount = l_period_amounts(22) + l_current_prdamt(22),
		 period23_amount = l_period_amounts(23) + l_current_prdamt(23),
		 period24_amount = l_period_amounts(24) + l_current_prdamt(24),
		 period25_amount = l_period_amounts(25) + l_current_prdamt(25),
		 period26_amount = l_period_amounts(26) + l_current_prdamt(26),
		 period27_amount = l_period_amounts(27) + l_current_prdamt(27),
		 period28_amount = l_period_amounts(28) + l_current_prdamt(28),
		 period29_amount = l_period_amounts(29) + l_current_prdamt(29),
		 period30_amount = l_period_amounts(30) + l_current_prdamt(30),
		 period31_amount = l_period_amounts(31) + l_current_prdamt(31),
		 period32_amount = l_period_amounts(32) + l_current_prdamt(32),
		 period33_amount = l_period_amounts(33) + l_current_prdamt(33),
		 period34_amount = l_period_amounts(34) + l_current_prdamt(34),
		 period35_amount = l_period_amounts(35) + l_current_prdamt(35),
		 period36_amount = l_period_amounts(36) + l_current_prdamt(36),
		 period37_amount = l_period_amounts(37) + l_current_prdamt(37),
		 period38_amount = l_period_amounts(38) + l_current_prdamt(38),
		 period39_amount = l_period_amounts(39) + l_current_prdamt(39),
		 period40_amount = l_period_amounts(40) + l_current_prdamt(40),
		 period41_amount = l_period_amounts(41) + l_current_prdamt(41),
		 period42_amount = l_period_amounts(42) + l_current_prdamt(42),
		 period43_amount = l_period_amounts(43) + l_current_prdamt(43),
		 period44_amount = l_period_amounts(44) + l_current_prdamt(44),
		 period45_amount = l_period_amounts(45) + l_current_prdamt(45),
		 period46_amount = l_period_amounts(46) + l_current_prdamt(46),
		 period47_amount = l_period_amounts(47) + l_current_prdamt(47),
		 period48_amount = l_period_amounts(48) + l_current_prdamt(48),
		 period49_amount = l_period_amounts(49) + l_current_prdamt(49),
		 period50_amount = l_period_amounts(50) + l_current_prdamt(50),
		 period51_amount = l_period_amounts(51) + l_current_prdamt(51),
		 period52_amount = l_period_amounts(52) + l_current_prdamt(52),
		 period53_amount = l_period_amounts(53) + l_current_prdamt(53),
		 period54_amount = l_period_amounts(54) + l_current_prdamt(54),
		 period55_amount = l_period_amounts(55) + l_current_prdamt(55),
		 period56_amount = l_period_amounts(56) + l_current_prdamt(56),
		 period57_amount = l_period_amounts(57) + l_current_prdamt(57),
		 period58_amount = l_period_amounts(58) + l_current_prdamt(58),
		 period59_amount = l_period_amounts(59) + l_current_prdamt(59),
		 period60_amount = l_period_amounts(60) + l_current_prdamt(60),
		 ytd_amount = l_rounded_ytd_amount + l_current_ytdamt,
		 last_update_date = sysdate,
		 last_updated_by = l_userid,
		 last_update_login = l_loginid,
		 request_id = l_requestid
	   where account_line_id = l_account_line_id;

	end;
	else
	begin

	  update PSB_WS_ACCOUNT_LINES
	     set budget_group_id = p_budget_group_id,
		 current_stage_seq = l_current_stage_seq,
		 end_stage_seq = decode(p_end_stage_seq, FND_API.G_MISS_NUM, end_stage_seq, p_end_stage_seq),
		 annual_fte = decode(nvl(p_annual_fte, FND_API.G_MISS_NUM), FND_API.G_MISS_NUM, annual_fte, p_annual_fte),
		 copy_of_account_line_id = decode(p_copy_of_account_line_id, FND_API.G_MISS_NUM, copy_of_account_line_id, p_copy_of_account_line_id),
		 period1_amount = l_period_amounts(1), period2_amount = l_period_amounts(2),
		 period3_amount = l_period_amounts(3), period4_amount = l_period_amounts(4),
		 period5_amount = l_period_amounts(5), period6_amount = l_period_amounts(6),
		 period7_amount = l_period_amounts(7), period8_amount = l_period_amounts(8),
		 period9_amount = l_period_amounts(9), period10_amount = l_period_amounts(10),
		 period11_amount = l_period_amounts(11), period12_amount = l_period_amounts(12),
		 period13_amount = l_period_amounts(13), period14_amount = l_period_amounts(14),
		 period15_amount = l_period_amounts(15), period16_amount = l_period_amounts(16),
		 period17_amount = l_period_amounts(17), period18_amount = l_period_amounts(18),
		 period19_amount = l_period_amounts(19), period20_amount = l_period_amounts(20),
		 period21_amount = l_period_amounts(21), period22_amount = l_period_amounts(22),
		 period23_amount = l_period_amounts(23), period24_amount = l_period_amounts(24),
		 period25_amount = l_period_amounts(25), period26_amount = l_period_amounts(26),
		 period27_amount = l_period_amounts(27), period28_amount = l_period_amounts(28),
		 period29_amount = l_period_amounts(29), period30_amount = l_period_amounts(30),
		 period31_amount = l_period_amounts(31), period32_amount = l_period_amounts(32),
		 period33_amount = l_period_amounts(33), period34_amount = l_period_amounts(34),
		 period35_amount = l_period_amounts(35), period36_amount = l_period_amounts(36),
		 period37_amount = l_period_amounts(37), period38_amount = l_period_amounts(38),
		 period39_amount = l_period_amounts(39), period40_amount = l_period_amounts(40),
		 period41_amount = l_period_amounts(41), period42_amount = l_period_amounts(42),
		 period43_amount = l_period_amounts(43), period44_amount = l_period_amounts(44),
		 period45_amount = l_period_amounts(45), period46_amount = l_period_amounts(46),
		 period47_amount = l_period_amounts(47), period48_amount = l_period_amounts(48),
		 period49_amount = l_period_amounts(49), period50_amount = l_period_amounts(50),
		 period51_amount = l_period_amounts(51), period52_amount = l_period_amounts(52),
		 period53_amount = l_period_amounts(53), period54_amount = l_period_amounts(54),
		 period55_amount = l_period_amounts(55), period56_amount = l_period_amounts(56),
		 period57_amount = l_period_amounts(57), period58_amount = l_period_amounts(58),
		 period59_amount = l_period_amounts(59), period60_amount = l_period_amounts(60),
		 ytd_amount = l_rounded_ytd_amount,
		 last_update_date = sysdate,
		 last_updated_by = l_userid,
		 last_update_login = l_loginid,
		 request_id = l_requestid
	   where account_line_id = l_account_line_id;

	end;
	end if;

	if l_budget_group_id <> p_budget_group_id then
	  l_budget_group_changed := TRUE;
	end if;




      end;
      else
      begin

	-- Non-Position Account Line must be unique across Global Worksheets and
	-- Local Copies of Worksheets; Position Line IDs are anyway unique across
	-- Global Worksheets and Local Copies of Worksheets


	for c_wal_rec in c_wal3 loop
	  l_account_line_id := c_wal_rec.account_line_id;
	  l_budget_group_id := c_wal_rec.budget_group_id;
	  l_current_requestid := c_wal_rec.request_id;
	  l_current_fte := c_wal_rec.annual_fte; l_current_ytdamt := c_wal_rec.ytd_amount;
	  l_current_prdamt(1) := c_wal_rec.period1_amount; l_current_prdamt(2) := c_wal_rec.period2_amount;
	  l_current_prdamt(3) := c_wal_rec.period3_amount; l_current_prdamt(4) := c_wal_rec.period4_amount;
	  l_current_prdamt(5) := c_wal_rec.period5_amount; l_current_prdamt(6) := c_wal_rec.period6_amount;
	  l_current_prdamt(7) := c_wal_rec.period7_amount; l_current_prdamt(8) := c_wal_rec.period8_amount;
	  l_current_prdamt(9) := c_wal_rec.period9_amount; l_current_prdamt(10) := c_wal_rec.period10_amount;
	  l_current_prdamt(11) := c_wal_rec.period11_amount; l_current_prdamt(12) := c_wal_rec.period12_amount;
	  l_current_prdamt(13) := c_wal_rec.period13_amount; l_current_prdamt(14) := c_wal_rec.period14_amount;
	  l_current_prdamt(15) := c_wal_rec.period15_amount; l_current_prdamt(16) := c_wal_rec.period16_amount;
	  l_current_prdamt(17) := c_wal_rec.period17_amount; l_current_prdamt(18) := c_wal_rec.period18_amount;
	  l_current_prdamt(19) := c_wal_rec.period19_amount; l_current_prdamt(20) := c_wal_rec.period20_amount;
	  l_current_prdamt(21) := c_wal_rec.period21_amount; l_current_prdamt(22) := c_wal_rec.period22_amount;
	  l_current_prdamt(23) := c_wal_rec.period23_amount; l_current_prdamt(24) := c_wal_rec.period24_amount;
	  l_current_prdamt(25) := c_wal_rec.period25_amount; l_current_prdamt(26) := c_wal_rec.period26_amount;
	  l_current_prdamt(27) := c_wal_rec.period27_amount; l_current_prdamt(28) := c_wal_rec.period28_amount;
	  l_current_prdamt(29) := c_wal_rec.period29_amount; l_current_prdamt(30) := c_wal_rec.period30_amount;
	  l_current_prdamt(31) := c_wal_rec.period31_amount; l_current_prdamt(32) := c_wal_rec.period32_amount;
	  l_current_prdamt(33) := c_wal_rec.period33_amount; l_current_prdamt(34) := c_wal_rec.period34_amount;
	  l_current_prdamt(35) := c_wal_rec.period35_amount; l_current_prdamt(36) := c_wal_rec.period36_amount;
	  l_current_prdamt(37) := c_wal_rec.period37_amount; l_current_prdamt(38) := c_wal_rec.period38_amount;
	  l_current_prdamt(39) := c_wal_rec.period39_amount; l_current_prdamt(40) := c_wal_rec.period40_amount;
	  l_current_prdamt(41) := c_wal_rec.period41_amount; l_current_prdamt(42) := c_wal_rec.period42_amount;
	  l_current_prdamt(43) := c_wal_rec.period43_amount; l_current_prdamt(44) := c_wal_rec.period44_amount;
	  l_current_prdamt(45) := c_wal_rec.period45_amount; l_current_prdamt(46) := c_wal_rec.period46_amount;
	  l_current_prdamt(47) := c_wal_rec.period47_amount; l_current_prdamt(48) := c_wal_rec.period48_amount;
	  l_current_prdamt(49) := c_wal_rec.period49_amount; l_current_prdamt(50) := c_wal_rec.period50_amount;
	  l_current_prdamt(51) := c_wal_rec.period51_amount; l_current_prdamt(52) := c_wal_rec.period52_amount;
	  l_current_prdamt(53) := c_wal_rec.period53_amount; l_current_prdamt(54) := c_wal_rec.period54_amount;
	  l_current_prdamt(55) := c_wal_rec.period55_amount; l_current_prdamt(56) := c_wal_rec.period56_amount;
	  l_current_prdamt(57) := c_wal_rec.period57_amount; l_current_prdamt(58) := c_wal_rec.period58_amount;
	  l_current_prdamt(59) := c_wal_rec.period59_amount; l_current_prdamt(60) := c_wal_rec.period60_amount;
	end loop;

	if ((nvl(l_current_requestid, FND_API.G_MISS_NUM) <> nvl(l_requestid, FND_API.G_MISS_NUM)) or
	    (p_balance_type = 'E')) then
	  l_flexmap_increment := FALSE;
	end if;

	if l_flexmap_increment then
	begin

	  update PSB_WS_ACCOUNT_LINES
	     set budget_group_id = p_budget_group_id,
		 current_stage_seq = l_current_stage_seq,
		 end_stage_seq = decode(p_end_stage_seq, FND_API.G_MISS_NUM, end_stage_seq, p_end_stage_seq),
		 annual_fte = decode(nvl(p_annual_fte, FND_API.G_MISS_NUM), FND_API.G_MISS_NUM, annual_fte, p_annual_fte + nvl(l_current_fte, 0)),
		 copy_of_account_line_id = decode(p_copy_of_account_line_id, FND_API.G_MISS_NUM, copy_of_account_line_id, p_copy_of_account_line_id),
		 period1_amount = l_period_amounts(1) + l_current_prdamt(1),
		 period2_amount = l_period_amounts(2) + l_current_prdamt(2),
		 period3_amount = l_period_amounts(3) + l_current_prdamt(3),
		 period4_amount = l_period_amounts(4) + l_current_prdamt(4),
		 period5_amount = l_period_amounts(5) + l_current_prdamt(5),
		 period6_amount = l_period_amounts(6) + l_current_prdamt(6),
		 period7_amount = l_period_amounts(7) + l_current_prdamt(7),
		 period8_amount = l_period_amounts(8) + l_current_prdamt(8),
		 period9_amount = l_period_amounts(9) + l_current_prdamt(9),
		 period10_amount = l_period_amounts(10) + l_current_prdamt(10),
		 period11_amount = l_period_amounts(11) + l_current_prdamt(11),
		 period12_amount = l_period_amounts(12) + l_current_prdamt(12),
		 period13_amount = l_period_amounts(13) + l_current_prdamt(13),
		 period14_amount = l_period_amounts(14) + l_current_prdamt(14),
		 period15_amount = l_period_amounts(15) + l_current_prdamt(15),
		 period16_amount = l_period_amounts(16) + l_current_prdamt(16),
		 period17_amount = l_period_amounts(17) + l_current_prdamt(17),
		 period18_amount = l_period_amounts(18) + l_current_prdamt(18),
		 period19_amount = l_period_amounts(19) + l_current_prdamt(19),
		 period20_amount = l_period_amounts(20) + l_current_prdamt(20),
		 period21_amount = l_period_amounts(21) + l_current_prdamt(21),
		 period22_amount = l_period_amounts(22) + l_current_prdamt(22),
		 period23_amount = l_period_amounts(23) + l_current_prdamt(23),
		 period24_amount = l_period_amounts(24) + l_current_prdamt(24),
		 period25_amount = l_period_amounts(25) + l_current_prdamt(25),
		 period26_amount = l_period_amounts(26) + l_current_prdamt(26),
		 period27_amount = l_period_amounts(27) + l_current_prdamt(27),
		 period28_amount = l_period_amounts(28) + l_current_prdamt(28),
		 period29_amount = l_period_amounts(29) + l_current_prdamt(29),
		 period30_amount = l_period_amounts(30) + l_current_prdamt(30),
		 period31_amount = l_period_amounts(31) + l_current_prdamt(31),
		 period32_amount = l_period_amounts(32) + l_current_prdamt(32),
		 period33_amount = l_period_amounts(33) + l_current_prdamt(33),
		 period34_amount = l_period_amounts(34) + l_current_prdamt(34),
		 period35_amount = l_period_amounts(35) + l_current_prdamt(35),
		 period36_amount = l_period_amounts(36) + l_current_prdamt(36),
		 period37_amount = l_period_amounts(37) + l_current_prdamt(37),
		 period38_amount = l_period_amounts(38) + l_current_prdamt(38),
		 period39_amount = l_period_amounts(39) + l_current_prdamt(39),
		 period40_amount = l_period_amounts(40) + l_current_prdamt(40),
		 period41_amount = l_period_amounts(41) + l_current_prdamt(41),
		 period42_amount = l_period_amounts(42) + l_current_prdamt(42),
		 period43_amount = l_period_amounts(43) + l_current_prdamt(43),
		 period44_amount = l_period_amounts(44) + l_current_prdamt(44),
		 period45_amount = l_period_amounts(45) + l_current_prdamt(45),
		 period46_amount = l_period_amounts(46) + l_current_prdamt(46),
		 period47_amount = l_period_amounts(47) + l_current_prdamt(47),
		 period48_amount = l_period_amounts(48) + l_current_prdamt(48),
		 period49_amount = l_period_amounts(49) + l_current_prdamt(49),
		 period50_amount = l_period_amounts(50) + l_current_prdamt(50),
		 period51_amount = l_period_amounts(51) + l_current_prdamt(51),
		 period52_amount = l_period_amounts(52) + l_current_prdamt(52),
		 period53_amount = l_period_amounts(53) + l_current_prdamt(53),
		 period54_amount = l_period_amounts(54) + l_current_prdamt(54),
		 period55_amount = l_period_amounts(55) + l_current_prdamt(55),
		 period56_amount = l_period_amounts(56) + l_current_prdamt(56),
		 period57_amount = l_period_amounts(57) + l_current_prdamt(57),
		 period58_amount = l_period_amounts(58) + l_current_prdamt(58),
		 period59_amount = l_period_amounts(59) + l_current_prdamt(59),
		 period60_amount = l_period_amounts(60) + l_current_prdamt(60),
		 ytd_amount = l_rounded_ytd_amount + l_current_ytdamt,
		 last_update_date = sysdate,
		 last_updated_by = l_userid,
		 last_update_login = l_loginid,
		 request_id = l_requestid
	   where account_line_id = l_account_line_id;

	end;
	else
	begin

	  update PSB_WS_ACCOUNT_LINES
	     set budget_group_id = p_budget_group_id,
		 current_stage_seq = l_current_stage_seq,
		 end_stage_seq = decode(p_end_stage_seq, FND_API.G_MISS_NUM, end_stage_seq, p_end_stage_seq),
		 annual_fte = decode(nvl(p_annual_fte, FND_API.G_MISS_NUM), FND_API.G_MISS_NUM, annual_fte, p_annual_fte),
		 copy_of_account_line_id = decode(p_copy_of_account_line_id, FND_API.G_MISS_NUM, copy_of_account_line_id, p_copy_of_account_line_id),
		 period1_amount = l_period_amounts(1), period2_amount = l_period_amounts(2),
		 period3_amount = l_period_amounts(3), period4_amount = l_period_amounts(4),
		 period5_amount = l_period_amounts(5), period6_amount = l_period_amounts(6),
		 period7_amount = l_period_amounts(7), period8_amount = l_period_amounts(8),
		 period9_amount = l_period_amounts(9), period10_amount = l_period_amounts(10),
		 period11_amount = l_period_amounts(11), period12_amount = l_period_amounts(12),
		 period13_amount = l_period_amounts(13), period14_amount = l_period_amounts(14),
		 period15_amount = l_period_amounts(15), period16_amount = l_period_amounts(16),
		 period17_amount = l_period_amounts(17), period18_amount = l_period_amounts(18),
		 period19_amount = l_period_amounts(19), period20_amount = l_period_amounts(20),
		 period21_amount = l_period_amounts(21), period22_amount = l_period_amounts(22),
		 period23_amount = l_period_amounts(23), period24_amount = l_period_amounts(24),
		 period25_amount = l_period_amounts(25), period26_amount = l_period_amounts(26),
		 period27_amount = l_period_amounts(27), period28_amount = l_period_amounts(28),
		 period29_amount = l_period_amounts(29), period30_amount = l_period_amounts(30),
		 period31_amount = l_period_amounts(31), period32_amount = l_period_amounts(32),
		 period33_amount = l_period_amounts(33), period34_amount = l_period_amounts(34),
		 period35_amount = l_period_amounts(35), period36_amount = l_period_amounts(36),
		 period37_amount = l_period_amounts(37), period38_amount = l_period_amounts(38),
		 period39_amount = l_period_amounts(39), period40_amount = l_period_amounts(40),
		 period41_amount = l_period_amounts(41), period42_amount = l_period_amounts(42),
		 period43_amount = l_period_amounts(43), period44_amount = l_period_amounts(44),
		 period45_amount = l_period_amounts(45), period46_amount = l_period_amounts(46),
		 period47_amount = l_period_amounts(47), period48_amount = l_period_amounts(48),
		 period49_amount = l_period_amounts(49), period50_amount = l_period_amounts(50),
		 period51_amount = l_period_amounts(51), period52_amount = l_period_amounts(52),
		 period53_amount = l_period_amounts(53), period54_amount = l_period_amounts(54),
		 period55_amount = l_period_amounts(55), period56_amount = l_period_amounts(56),
		 period57_amount = l_period_amounts(57), period58_amount = l_period_amounts(58),
		 period59_amount = l_period_amounts(59), period60_amount = l_period_amounts(60),
		 ytd_amount = l_rounded_ytd_amount,
		 last_update_date = sysdate,
		 last_updated_by = l_userid,
		 last_update_login = l_loginid,
		 request_id = l_requestid
	   where account_line_id = l_account_line_id;

	end;
	end if;

	if l_budget_group_id <> p_budget_group_id then
	  l_budget_group_changed := TRUE;
	end if;


      end;
      end if;

    end;
    end if;

  end;
  end if;


   /* Bug 3305778 Start */

  IF g_create_zero_bal is null THEN
   BEGIN

    FND_PROFILE.GET
       (name => 'PSB_CREATE_ZERO_BALANCE_ACCT',
	val => g_create_zero_bal);

    IF g_create_zero_bal is null THEN
      -- Bug 3543845: Change default behavior to not creating zero balance
      g_create_zero_bal := 'N';
    END IF;

   END;
  END IF;

  -- Try to Insert if Update was unsuccessful
  --if SQL%NOTFOUND then

  IF (SQL%NOTFOUND) AND ((p_ytd_amount <> 0) OR ((p_ytd_amount = 0) AND (g_create_zero_bal = 'Y'))
   /*Bug:5876100:start*/
   OR (PSB_WS_ACCT2.g_ugb_create_est_bal = 'Y')) THEN
   /*Bug:5876100:end*/

   /* Bug 3305778 End */

  begin

    GL_CODE_COMBINATIONS_PKG.Select_Columns
      (X_code_combination_id => l_ccid,
       X_account_type => l_account_type,
       X_template_id => l_template_id);

    for l_index in 1..g_max_num_amounts loop

      if FND_API.to_Boolean(p_distribute_flag) then
      begin

	if l_rounding_factor is null then
	  l_period_amount := l_period_amount_tbl(l_index);
	else
	  l_period_amount := ROUND(l_period_amount_tbl(l_index)/l_rounding_factor) * l_rounding_factor;
	end if;

      end;
      else
      begin

	if l_rounding_factor is null then
	  l_period_amount := p_period_amount(l_index);
	else
	  l_period_amount := ROUND(p_period_amount(l_index)/l_rounding_factor) * l_rounding_factor;
	end if;

      end;
      end if;

      if l_period_amount is null then
      begin
	/* Bug 3247563 Start */
	--if ((l_index = l_last_period_index) and (l_ytd_amount <> 0)) then
	if (l_index = l_last_period_index) then
	/* Bug 3247563 End */

	  l_period_amounts(l_index) := nvl(l_rounding_difference, 0);
	else
	  l_period_amounts(l_index) := null;
	end if;

      end;
      else
      begin

	-- Adjust rounding difference to the last Budget Period

	/* Bug 3247563 Start */
	--if ((l_index = l_last_period_index) and (l_ytd_amount <> 0)) then
	if (l_index = l_last_period_index) then
	/* Bug 3247563 End */

	  l_period_amounts(l_index) := l_period_amount + nvl(l_rounding_difference, 0);
	else
	  l_period_amounts(l_index) := l_period_amount;
	end if;

      end;
      end if;

    end loop;

    insert into PSB_WS_ACCOUNT_LINES
	  (account_line_id, code_combination_id, position_line_id, service_package_id, budget_group_id,
	   element_set_id, salary_account_line, stage_set_id, start_stage_seq, current_stage_seq,
	   end_stage_seq, copy_of_account_line_id, last_update_date, last_updated_by,
	   last_update_login, created_by, creation_date, template_id, budget_year_id, annual_fte,
	   currency_code, account_type, balance_type,
	   period1_amount, period2_amount, period3_amount, period4_amount, period5_amount, period6_amount,
	   period7_amount, period8_amount, period9_amount, period10_amount, period11_amount, period12_amount,
	   period13_amount, period14_amount, period15_amount, period16_amount, period17_amount, period18_amount,
	   period19_amount, period20_amount, period21_amount, period22_amount, period23_amount, period24_amount,
	   period25_amount, period26_amount, period27_amount, period28_amount, period29_amount, period30_amount,
	   period31_amount, period32_amount, period33_amount, period34_amount, period35_amount, period36_amount,
	   period37_amount, period38_amount, period39_amount, period40_amount, period41_amount, period42_amount,
	   period43_amount, period44_amount, period45_amount, period46_amount, period47_amount, period48_amount,
	   period49_amount, period50_amount, period51_amount, period52_amount, period53_amount, period54_amount,
	   period55_amount, period56_amount, period57_amount, period58_amount, period59_amount, period60_amount,
	   ytd_amount, request_id, functional_transaction)
    values (psb_ws_account_lines_s.nextval,
	    l_ccid,
	    decode(p_position_line_id, FND_API.G_MISS_NUM, null, p_position_line_id),
	    l_service_package_id,
	    p_budget_group_id,
	    decode(p_element_set_id, FND_API.G_MISS_NUM, null, p_element_set_id),
	    decode(p_salary_account_line, FND_API.G_FALSE, null, 'Y'),
	    l_stage_set_id,
	    decode(p_start_stage_seq, FND_API.G_MISS_NUM, l_start_stage_seq, p_start_stage_seq),
	    l_current_stage_seq,
	    decode(p_end_stage_seq, FND_API.G_MISS_NUM, null, p_end_stage_seq),
	    decode(p_copy_of_account_line_id, FND_API.G_MISS_NUM, null, p_copy_of_account_line_id),
	    sysdate, l_userid, l_loginid, l_userid, sysdate,
	    decode(p_template_id, FND_API.G_MISS_NUM, null, p_template_id),
	    p_budget_year_id,
	    decode(nvl(p_annual_fte, FND_API.G_MISS_NUM), FND_API.G_MISS_NUM, null, nvl(p_annual_fte, FND_API.G_MISS_NUM)),
	    p_currency_code, l_account_type, p_balance_type,
	    l_period_amounts(1), l_period_amounts(2), l_period_amounts(3), l_period_amounts(4), l_period_amounts(5),
	    l_period_amounts(6), l_period_amounts(7), l_period_amounts(8), l_period_amounts(9), l_period_amounts(10),
	    l_period_amounts(11), l_period_amounts(12), l_period_amounts(13), l_period_amounts(14), l_period_amounts(15),
	    l_period_amounts(16), l_period_amounts(17), l_period_amounts(18), l_period_amounts(19), l_period_amounts(20),
	    l_period_amounts(21), l_period_amounts(22), l_period_amounts(23), l_period_amounts(24), l_period_amounts(25),
	    l_period_amounts(26), l_period_amounts(27), l_period_amounts(28), l_period_amounts(29), l_period_amounts(30),
	    l_period_amounts(31), l_period_amounts(32), l_period_amounts(33), l_period_amounts(34), l_period_amounts(35),
	    l_period_amounts(36), l_period_amounts(37), l_period_amounts(38), l_period_amounts(39), l_period_amounts(40),
	    l_period_amounts(41), l_period_amounts(42), l_period_amounts(43), l_period_amounts(44), l_period_amounts(45),
	    l_period_amounts(46), l_period_amounts(47), l_period_amounts(48), l_period_amounts(49), l_period_amounts(50),
	    l_period_amounts(51), l_period_amounts(52), l_period_amounts(53), l_period_amounts(54), l_period_amounts(55),
	    l_period_amounts(56), l_period_amounts(57), l_period_amounts(58), l_period_amounts(59), l_period_amounts(60),
	    l_rounded_ytd_amount, l_requestid, p_functional_transaction)
    returning account_line_id into l_acclineid;

    -- Create an entry in PSB_WS_LINES for all worksheets to which the CCID or Position belongs

    if p_position_line_id <> FND_API.G_MISS_NUM then
    begin

      insert into PSB_WS_LINES
	    (worksheet_id, account_line_id, freeze_flag,
	     view_line_flag, last_update_date, last_updated_by,
	     last_update_login, created_by, creation_date)
      select worksheet_id, l_acclineid, freeze_flag,
	     view_line_flag, sysdate, l_userid,
	     l_loginid, l_userid, sysdate
	from PSB_WS_LINES_POSITIONS
       where position_line_id = p_position_line_id;

    end;
    else
    begin

      -- Bug 3543845: During ws creation, distributed ws does not exist.
      -- if l_local_copy_flag = 'Y' then
      if PSB_WORKSHEET.g_ws_creation_flag OR
         l_local_copy_flag = 'Y'
      then
      begin

	insert into PSB_WS_LINES
	      (worksheet_id, account_line_id, freeze_flag,
	       view_line_flag, last_update_date, last_updated_by,
	       last_update_login, created_by, creation_date)
	 values (p_worksheet_id, l_acclineid, null,
		 'Y', sysdate, l_userid,
		 l_loginid, l_userid, sysdate);
      end;
      else
      begin
	for c_Distribute_WS_Rec in c_Distribute_WS (l_global_worksheet_id, p_budget_group_id,
						    g_startdate_pp,
						    g_enddate_cy) loop
          insert into PSB_WS_LINES
		(worksheet_id, account_line_id, freeze_flag,
		 view_line_flag, last_update_date, last_updated_by,
		 last_update_login, created_by, creation_date)
	   values (c_Distribute_WS_Rec.worksheet_id, l_acclineid, null,
		   'Y', sysdate, l_userid,
		   l_loginid, l_userid, sysdate);

	end loop;

      end;
      end if;

    end;
    end if;

    p_account_line_id := l_acclineid;

  end;
  else
  begin

    -- Update was successful; if budget group was changed reassign worksheets

    if l_budget_group_changed
    and l_account_line_id is not null --bug:6608635
    then

    begin

      delete from psb_ws_lines
       where account_line_id = l_account_line_id;

      -- Create an entry in PSB_WS_LINES for all worksheets to which the CCID or Position belongs

      if p_position_line_id <> FND_API.G_MISS_NUM then
      begin

	insert into PSB_WS_LINES
	      (worksheet_id, account_line_id, freeze_flag,
	       view_line_flag, last_update_date, last_updated_by,
	       last_update_login, created_by, creation_date)
	select worksheet_id, l_account_line_id, freeze_flag,
	       view_line_flag, sysdate, l_userid,
	       l_loginid, l_userid, sysdate
	  from PSB_WS_LINES_POSITIONS
	 where position_line_id = p_position_line_id;

      end;
      else
      begin

        -- Bug 3543845: During ws creation, distributed ws does not exist.
        -- Also flip the condition to make it readable.
        -- if nvl(l_local_copy_flag, 'N') <> 'Y' then
        if PSB_WORKSHEET.g_ws_creation_flag OR
           l_local_copy_flag = 'Y'
        then
	begin

	  insert into PSB_WS_LINES
		(worksheet_id, account_line_id, freeze_flag,
		 view_line_flag, last_update_date, last_updated_by,
		 last_update_login, created_by, creation_date)
	   values (p_worksheet_id, l_account_line_id, null,
		   'Y', sysdate, l_userid,
		   l_loginid, l_userid, sysdate);

	end;
	else
        begin

	  for c_Distribute_WS_Rec in c_Distribute_WS (l_global_worksheet_id, p_budget_group_id,
						      g_startdate_pp,
						      g_enddate_cy) loop
            insert into PSB_WS_LINES
		  (worksheet_id, account_line_id, freeze_flag,
		   view_line_flag, last_update_date, last_updated_by,
		   last_update_login, created_by, creation_date)
	     values (c_Distribute_WS_Rec.worksheet_id, l_account_line_id, null,
		     'Y', sysdate, l_userid,
		     l_loginid, l_userid, sysdate);

	  end loop;

	end;
	end if;

      end;
      end if;

    end;
    end if;

    p_account_line_id := l_account_line_id;

  end;
  end if;

 p_account_line_id := nvl(p_account_line_id,l_spal_id);--bug:9107577

 /*Bug:5876100:start*/
 PSB_WS_ACCT2.g_ugb_create_est_bal := 'N';
 /*Bug:5876100:end*/

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

END Create_Account_Dist;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                      PROCEDURE Create_Account_Dist                        |
 +===========================================================================*/
--
-- This API must be called when updating an existing Account Line.
-- p_distribute_flag must be set to FND_API.G_TRUE to automatically distribute
-- the YTD Amount into Period Amounts. If existing YTD Amount is 0 and
-- p_ytd_amount is not 0, distribution is done using the Period Allocation
-- rules; otherwise, the existing period amounts are prorated in the ratio of
-- the YTD Amount p_check_stages must be set to FND_API.G_TRUE to automatically
-- create new Stage for the Account Line
--
PROCEDURE Create_Account_Dist
( p_api_version              IN   NUMBER,
  p_validation_level         IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_worksheet_id             IN   NUMBER,
  p_distribute_flag          IN   VARCHAR2 := FND_API.G_FALSE,
  p_account_line_id          IN   NUMBER,
  p_check_stages             IN   VARCHAR2 := FND_API.G_TRUE,
  p_ytd_amount               IN   NUMBER := FND_API.G_MISS_NUM,
  p_annual_fte               IN   NUMBER := FND_API.G_MISS_NUM,
  p_period_amount            IN   g_prdamt_tbl_type,
  p_budget_group_id          IN   NUMBER := FND_API.G_MISS_NUM,
  p_service_package_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq        IN   NUMBER := FND_API.G_MISS_NUM,
  p_copy_of_account_line_id  IN   NUMBER := FND_API.G_MISS_NUM,
  /* start bug 4128196 */
  p_update_cy_estimate       IN   VARCHAR2 := 'N'
  /* end bug 4128196   */
)
IS
  --
  l_api_name                 CONSTANT VARCHAR2(30)   := 'Create_Account_Dist';
  l_api_version              CONSTANT NUMBER         := 1.0;
  l_userid                   NUMBER;
  l_loginid                  NUMBER;
  --
  cur_wal                    PLS_INTEGER;
  sql_wal                    VARCHAR2(1000);
  num_wal                    PLS_INTEGER;
  cur_wsacc                  PLS_INTEGER;
  sql_wsacc                  VARCHAR2(6000);
  num_wsacc                  PLS_INTEGER;

  -- For bug#2440100
  l_period_empty             BOOLEAN := TRUE;

  l_stage_set_id             NUMBER;
  l_new_stage                BOOLEAN := FALSE;
  l_previous_stage           NUMBER;
  l_acclineid                NUMBER;
  l_period_amount            NUMBER;
  l_rounding_factor          NUMBER;
  l_allocrule_set_id         NUMBER;
  l_global_worksheet_id      NUMBER;
  l_budget_calendar_id       NUMBER;
  l_gl_cutoff_period         DATE;
  l_local_copy_flag          VARCHAR2(1);
  l_period_amount_tbl        g_prdamt_tbl_type;
  l_ccid                     NUMBER;
  l_budget_group_id          NUMBER;
  l_template_id              NUMBER;
  l_position_line_id         NUMBER;
  l_element_set_id           NUMBER;
  l_budget_year_id           NUMBER;
  l_currency_code            VARCHAR2(15);
  l_start_stage_seq          NUMBER;
  l_current_stage_seq        NUMBER;
  l_service_package_id       NUMBER;
  l_balance_type             VARCHAR2(1);
  l_prdamt_tbl               g_prdamt_tbl_type;
  --
  l_running_ytd_amount       NUMBER := 0;
  l_old_ytd_amount           NUMBER;
  l_new_ytd_amount           NUMBER;
  l_rounding_difference      NUMBER;
  l_allocate_ytd_amount      NUMBER;

  /* Bug No 2342169 Start */
  l_redist_palloc            VARCHAR2(1) := null;
  l_budget_year_type         VARCHAR2(30);
  l_cy_ytd_amount            NUMBER ;
  /* Bug No 2342169 End */

  l_spal_id                  NUMBER;
  l_spytd_amount             NUMBER;
  l_spal_exists              BOOLEAN := FALSE;
  --
  l_budget_periods           g_budgetperiod_tbl_type;
  l_distribute1_flag         BOOLEAN := FALSE;
  l_distribute2_flag         BOOLEAN := FALSE;
  --
  l_start_date               DATE;
  l_end_date                 DATE;
  l_ccid_start_date          DATE;
  l_ccid_end_date            DATE;

  l_index                    PLS_INTEGER;
  l_init_index               PLS_INTEGER;
  l_year_index               PLS_INTEGER;
  l_period_index             PLS_INTEGER;
  l_last_period_index        NUMBER;
  --

  -- Bug#3258892
  l_cy_start_index           NUMBER;

  l_budget_group_changed     BOOLEAN := FALSE;
  l_root_budget_group_id     NUMBER;
  l_new_budget_group_id      NUMBER;
  --
  l_set_of_books_id          NUMBER;
  l_flex_mapping_set_id      NUMBER;
  l_budget_year_type_id      NUMBER;
  l_return_status            VARCHAR2(1);

  l_last_update_date         DATE := SYSDATE; --Bug:5929875

  -- bug no 4128196
  l_running_total			 NUMBER := 0;

  --
  cursor c_WS is
    select a.stage_set_id,
	   a.rounding_factor,
	   nvl(a.allocrule_set_id, a.global_allocrule_set_id) allocrule_set_id,
	   nvl(a.global_worksheet_id, a.worksheet_id) global_worksheet_id,
	   a.budget_calendar_id,
	   a.flex_mapping_set_id,
	   a.gl_cutoff_period,
	   nvl(b.root_budget_group_id, b.budget_group_id) root_budget_group_id,
	   local_copy_flag,
	   a.current_stage_seq  --bug:6019074
      from PSB_WORKSHEETS_V a, PSB_BUDGET_GROUPS b
     where a.worksheet_id = p_worksheet_id
       and b.budget_group_id = a.budget_group_id;
  --
  cursor c_CCID is
    select start_date_active,
	   end_date_active
      from GL_CODE_COMBINATIONS
     where code_combination_id = l_ccid;
  --
  cursor c_Stage is
    select Max(sequence_number) sequence_number
      from PSB_BUDGET_STAGES
     where sequence_number < l_current_stage_seq
       and budget_stage_set_id = l_stage_set_id;
  --
  --bug:5929875:modified the cursor to select code_combination_id
  --            and removed num_proposed_years from select list.
  --            removed the condition on ccid.
  cursor c_Budget_Group is
    select a.budget_group_id,
	   c.code_combination_id
      from PSB_SET_RELATIONS a,
	   PSB_BUDGET_GROUPS b,
	   PSB_BUDGET_ACCOUNTS c
     where a.budget_group_id = b.budget_group_id
	and (((b.effective_start_date <= l_end_date)
	  and (b.effective_end_date is null))
	  or ((b.effective_start_date between l_start_date and l_end_date)
	   or (b.effective_end_date between l_start_date and l_end_date)
	  or ((b.effective_start_date < l_start_date)
	  and (b.effective_end_date > l_end_date))))
       and b.budget_group_type = 'R'
       and ((b.budget_group_id = l_root_budget_group_id) or
	    (b.root_budget_group_id = l_root_budget_group_id))
       and a.account_position_set_id = c.account_position_set_id;
  --
  cursor c_seq is
    select PSB_WS_ACCOUNT_LINES_S.NEXTVAL seq
      from dual;

  -- Bug No 2354918 Start
  cursor c_WAL is
    select period1_amount, period2_amount, period3_amount, period4_amount,
	   period5_amount, period6_amount, period7_amount, period8_amount,
	   period9_amount, period10_amount, period11_amount, period12_amount,
	   period13_amount, period14_amount, period15_amount, period16_amount,
	   period17_amount, period18_amount, period19_amount, period20_amount,
	   period21_amount, period22_amount, period23_amount, period24_amount,
	   period25_amount, period26_amount, period27_amount, period28_amount,
	   period29_amount, period30_amount, period31_amount, period32_amount,
	   period33_amount, period34_amount, period35_amount, period36_amount,
	   period37_amount, period38_amount, period39_amount, period40_amount,
	   period41_amount, period42_amount, period43_amount, period44_amount,
	   period45_amount, period46_amount, period47_amount, period48_amount,
	   period49_amount, period50_amount, period51_amount, period52_amount,
	   period53_amount, period54_amount, period55_amount, period56_amount,
	   period57_amount, period58_amount, period59_amount, period60_amount,
	   budget_year_id
      from PSB_WS_ACCOUNT_LINES
     where account_line_id = p_account_line_id
       and position_line_id is null;
  --
  --Bug:5929875:start
  CURSOR c_acct_line_csr IS
  select code_combination_id, budget_group_id, template_id, position_line_id,
	       element_set_id, budget_year_id, currency_code, stage_set_id, start_stage_seq,
	       current_stage_seq, service_package_id, balance_type,
	       period1_amount, period2_amount, period3_amount, period4_amount,
	       period5_amount, period6_amount, period7_amount, period8_amount,
	       period9_amount, period10_amount, period11_amount, period12_amount,
	       period13_amount, period14_amount, period15_amount, period16_amount,
	       period17_amount, period18_amount, period19_amount, period20_amount,
	       period21_amount, period22_amount, period23_amount, period24_amount,
	       period25_amount, period26_amount, period27_amount, period28_amount,
	       period29_amount, period30_amount, period31_amount, period32_amount,
	       period33_amount, period34_amount, period35_amount, period36_amount,
	       period37_amount, period38_amount, period39_amount, period40_amount,
	       period41_amount, period42_amount, period43_amount, period44_amount,
	       period45_amount, period46_amount, period47_amount, period48_amount,
	       period49_amount, period50_amount, period51_amount, period52_amount,
	       period53_amount, period54_amount, period55_amount, period56_amount,
	       period57_amount, period58_amount, period59_amount, period60_amount,
	       ytd_amount
	  from PSB_WS_ACCOUNT_LINES
	 where account_line_id = p_account_line_id;
  --Bug:5929875:end

BEGIN

  -- Standard call to check for call compatibility
  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  for l_index in 1..g_max_num_amounts loop
    l_prdamt_tbl(l_index) := null;
    l_period_amount_tbl(l_index) := null;
  end loop;

 --Bug:5929875:start
  IF g_root_budget_group_id IS NULL THEN
 --Bug:5929875:end
  for c_WS_Rec in c_WS loop
    l_stage_set_id := c_WS_Rec.stage_set_id;
    l_rounding_factor := c_WS_Rec.rounding_factor;
    l_allocrule_set_id := c_WS_Rec.allocrule_set_id;
    l_global_worksheet_id := c_WS_Rec.global_worksheet_id;
    l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
    l_flex_mapping_set_id := c_WS_Rec.flex_mapping_set_id;
    l_gl_cutoff_period := c_WS_Rec.gl_cutoff_period;
    l_root_budget_group_id := c_WS_Rec.root_budget_group_id;
    l_local_copy_flag := c_WS_Rec.local_copy_flag;


 --Bug:5929875:start
    g_stage_set_id := c_WS_Rec.stage_set_id;
    g_rounding_factor := c_WS_Rec.rounding_factor;
    g_allocrule_set_id := c_WS_Rec.allocrule_set_id;
    g_global_worksheet_id := c_WS_Rec.global_worksheet_id;
    g_flex_mapping_set_id := c_WS_Rec.flex_mapping_set_id;
    g_gl_cutoff_period := c_WS_Rec.gl_cutoff_period;
    g_root_budget_group_id := c_WS_Rec.root_budget_group_id;
    g_local_copy_flag := c_WS_Rec.local_copy_flag;
    g_current_stage_seq := c_WS_Rec.current_stage_seq; --bug:6019074
   end loop;

  ELSE
     l_stage_set_id := g_stage_set_id;
     l_rounding_factor := g_rounding_factor;
     l_allocrule_set_id := g_allocrule_set_id;
     l_global_worksheet_id := g_global_worksheet_id ;
     l_budget_calendar_id :=  g_budget_calendar_id;
     l_flex_mapping_set_id := g_flex_mapping_set_id;
     l_gl_cutoff_period := g_gl_cutoff_period ;
     l_root_budget_group_id := g_root_budget_group_id;
     l_local_copy_flag := g_local_copy_flag;

  END IF;
 --Bug:5929875:end

  /*bug:5929875:Replaced dynamic sql with the cursor - c_acct_line_csr*/
   FOR l_acct_line_rec IN c_acct_line_csr LOOP
     l_ccid               := l_acct_line_rec.code_combination_id;
     l_budget_group_id    := l_acct_line_rec.budget_group_id;
     l_template_id        := l_acct_line_rec.template_id;
     l_position_line_id   := l_acct_line_rec.position_line_id;
     l_element_set_id     := l_acct_line_rec.element_set_id;
     l_budget_year_id     := l_acct_line_rec.budget_year_id;
     l_currency_code      := l_acct_line_rec.currency_code;
     l_stage_set_id       := l_acct_line_rec.stage_set_id;
     l_start_stage_seq    := l_acct_line_rec.start_stage_seq;
     l_current_stage_seq  := l_acct_line_rec.current_stage_seq;
     l_service_package_id := l_acct_line_rec.service_package_id;
     l_balance_type       := l_acct_line_rec.balance_type;
     l_prdamt_tbl(1)      := l_acct_line_rec.period1_amount;
     l_prdamt_tbl(2)      := l_acct_line_rec.period2_amount;
     l_prdamt_tbl(3)      := l_acct_line_rec.period3_amount;
     l_prdamt_tbl(4)      := l_acct_line_rec.period4_amount;
     l_prdamt_tbl(5)      := l_acct_line_rec.period5_amount;
     l_prdamt_tbl(6)      := l_acct_line_rec.period6_amount;
     l_prdamt_tbl(7)      := l_acct_line_rec.period7_amount;
     l_prdamt_tbl(8)      := l_acct_line_rec.period8_amount;
     l_prdamt_tbl(9)      := l_acct_line_rec.period9_amount;
     l_prdamt_tbl(10)     := l_acct_line_rec.period10_amount;
     l_prdamt_tbl(11)     := l_acct_line_rec.period11_amount;
     l_prdamt_tbl(12)     := l_acct_line_rec.period12_amount;
     l_prdamt_tbl(13)     := l_acct_line_rec.period13_amount;
     l_prdamt_tbl(14)     := l_acct_line_rec.period14_amount;
     l_prdamt_tbl(15)     := l_acct_line_rec.period15_amount;
     l_prdamt_tbl(16)     := l_acct_line_rec.period16_amount;
     l_prdamt_tbl(17)     := l_acct_line_rec.period17_amount;
     l_prdamt_tbl(18)     := l_acct_line_rec.period18_amount;
     l_prdamt_tbl(19)     := l_acct_line_rec.period19_amount;
     l_prdamt_tbl(20)     := l_acct_line_rec.period20_amount;
     l_prdamt_tbl(21)     := l_acct_line_rec.period21_amount;
     l_prdamt_tbl(22)     := l_acct_line_rec.period22_amount;
     l_prdamt_tbl(23)     := l_acct_line_rec.period23_amount;
     l_prdamt_tbl(24)     := l_acct_line_rec.period24_amount;
     l_prdamt_tbl(25)     := l_acct_line_rec.period25_amount;
     l_prdamt_tbl(26)     := l_acct_line_rec.period26_amount;
     l_prdamt_tbl(27)     := l_acct_line_rec.period27_amount;
     l_prdamt_tbl(28)     := l_acct_line_rec.period28_amount;
     l_prdamt_tbl(29)     := l_acct_line_rec.period29_amount;
     l_prdamt_tbl(30)     := l_acct_line_rec.period30_amount;
     l_prdamt_tbl(31)     := l_acct_line_rec.period31_amount;
     l_prdamt_tbl(32)     := l_acct_line_rec.period32_amount;
     l_prdamt_tbl(33)     := l_acct_line_rec.period33_amount;
     l_prdamt_tbl(34)     := l_acct_line_rec.period34_amount;
     l_prdamt_tbl(35)     := l_acct_line_rec.period35_amount;
     l_prdamt_tbl(36)     := l_acct_line_rec.period36_amount;
     l_prdamt_tbl(37)     := l_acct_line_rec.period37_amount;
     l_prdamt_tbl(38)     := l_acct_line_rec.period38_amount;
     l_prdamt_tbl(39)     := l_acct_line_rec.period39_amount;
     l_prdamt_tbl(40)     := l_acct_line_rec.period40_amount;
     l_prdamt_tbl(41)     := l_acct_line_rec.period41_amount;
     l_prdamt_tbl(42)     := l_acct_line_rec.period42_amount;
     l_prdamt_tbl(43)     := l_acct_line_rec.period43_amount;
     l_prdamt_tbl(44)     := l_acct_line_rec.period44_amount;
     l_prdamt_tbl(45)     := l_acct_line_rec.period45_amount;
     l_prdamt_tbl(46)     := l_acct_line_rec.period46_amount;
     l_prdamt_tbl(47)     := l_acct_line_rec.period47_amount;
     l_prdamt_tbl(48)     := l_acct_line_rec.period48_amount;
     l_prdamt_tbl(49)     := l_acct_line_rec.period49_amount;
     l_prdamt_tbl(50)     := l_acct_line_rec.period50_amount;
     l_prdamt_tbl(51)     := l_acct_line_rec.period51_amount;
     l_prdamt_tbl(52)     := l_acct_line_rec.period52_amount;
     l_prdamt_tbl(53)     := l_acct_line_rec.period53_amount;
     l_prdamt_tbl(54)     := l_acct_line_rec.period54_amount;
     l_prdamt_tbl(55)     := l_acct_line_rec.period55_amount;
     l_prdamt_tbl(56)     := l_acct_line_rec.period56_amount;
     l_prdamt_tbl(57)     := l_acct_line_rec.period57_amount;
     l_prdamt_tbl(58)     := l_acct_line_rec.period58_amount;
     l_prdamt_tbl(59)     := l_acct_line_rec.period59_amount;
     l_prdamt_tbl(60)     := l_acct_line_rec.period60_amount;
     l_old_ytd_amount     := l_acct_line_rec.ytd_amount;

   END LOOP;
  /*End of addition for bug:5929875*/

  -- If Service Package is being modified, check whether the target account line exists

  if ((p_service_package_id <> FND_API.G_MISS_NUM) and
      (p_service_package_id <> l_service_package_id)) then
  begin

    sql_wal := 'select account_line_id, ' ||
		      'ytd_amount ' ||
		 'from PSB_WS_ACCOUNT_LINES a ' ||
		'where currency_code = ''' || l_currency_code || ''' ' ||
		  'and ' || l_current_stage_seq || ' between start_stage_seq and current_stage_seq ' ||
		  'and balance_type = ''' || l_balance_type || ''' ';

    if l_template_id is not null then
      sql_wal := sql_wal ||
		'and template_id = ' || l_template_id || ' ';
    else
      sql_wal := sql_wal ||
		'and template_id is null ';
    end if;

    -- For Position Account Lines, must match the Position Line ID and Element Set ID

    if l_position_line_id is not null then
      sql_wal := sql_wal ||
		'and position_line_id = ' || l_position_line_id || ' ';
    else
      sql_wal := sql_wal ||
		'and position_line_id is null ';
    end if;

    if l_element_set_id is not null then
      sql_wal := sql_wal ||
		'and element_set_id = ' || l_element_set_id || ' ';
    else
      sql_wal := sql_wal ||
		'and element_set_id is null ';
    end if;

    if l_position_line_id is null then
    begin

      sql_wal := sql_wal ||
		'and exists ' ||
		    '(select 1 ' ||
		       'from PSB_WS_LINES b ' ||
		      'where b.account_line_id = a.account_line_id ' ||
			'and b.worksheet_id = ' || p_worksheet_id || ') ';

    end;
    end if;

    sql_wal := sql_wal ||
	      'and stage_set_id = ' || l_stage_set_id || ' ' ||
	      'and service_package_id = ' || p_service_package_id || ' ' ||
	      'and budget_year_id = ' || l_budget_year_id || ' ' ||
	      'and budget_group_id = ' || l_budget_group_id || ' ' ||
	      'and code_combination_id = ' || l_ccid;

    cur_wal := dbms_sql.open_cursor;
    dbms_sql.parse(cur_wal, sql_wal, dbms_sql.v7);

    dbms_sql.define_column(cur_wal, 1, l_spal_id);
    dbms_sql.define_column(cur_wal, 2, l_spytd_amount);

    num_wal := dbms_sql.execute(cur_wal);

    loop

      if dbms_sql.fetch_rows(cur_wal) = 0 then
	exit;
      end if;

      dbms_sql.column_value(cur_wal, 1, l_spal_id);
      dbms_sql.column_value(cur_wal, 2, l_spytd_amount);

      l_spal_exists := TRUE;

    end loop;

    dbms_sql.close_cursor(cur_wal);

  end;
  end if;

  -- Now determine if new Stage is to be inserted

  if (((p_service_package_id <> FND_API.G_MISS_NUM) and
       (p_service_package_id <> l_service_package_id)) or
      ((p_ytd_amount <> FND_API.G_MISS_NUM) and
       (p_ytd_amount <> l_old_ytd_amount))) then
    l_new_stage := TRUE;
  end if;

 /*For Bug No : 2440100 Start*/
  --the following code has been implemented since the p_period_amount
  --doen't hold any values if the API call happens from Form
  if not l_new_stage then

    for l_index in 1..g_max_num_amounts loop
      if p_period_amount(l_index) is not null then
	l_period_empty := FALSE;
	exit;
      end if;
    end loop;

    if not l_period_empty then
      for l_index in 1..g_max_num_amounts loop

       if nvl(p_period_amount(l_index), FND_API.G_MISS_NUM) <> nvl(l_prdamt_tbl(l_index), FND_API.G_MISS_NUM) then
	l_new_stage := TRUE;
	exit;
       end if;

      end loop;
    end if;
  end if;
  --the following code is now available in the above block
  /*for l_index in 1..g_max_num_amounts loop

    if nvl(p_period_amount(l_index), FND_API.G_MISS_NUM) <> nvl(l_prdamt_tbl(l_index), FND_API.G_MISS_NUM) then
      l_new_stage := TRUE;
      exit;
    end if;

  end loop;*/
  /*For Bug No : 2440100 End*/

  if ((l_new_stage) and
      (l_start_stage_seq = l_current_stage_seq)) then
    l_new_stage := FALSE;
  end if;

  l_userid := FND_GLOBAL.USER_ID;
  l_loginid := FND_GLOBAL.LOGIN_ID;

  if ((FND_API.to_Boolean(p_check_stages)) and
      (l_new_stage) and
      (l_start_stage_seq < l_current_stage_seq)) then
  begin

    -- Find Previous Stage for the Budget Stage Set

    for c_Stage_Rec in c_Stage loop
      l_previous_stage := c_Stage_Rec.sequence_number;
    end loop;

    for c_seq_rec in c_seq loop
      l_acclineid := c_seq_rec.seq;
    end loop;

    insert into PSB_WS_ACCOUNT_LINES
	  (account_line_id, code_combination_id, position_line_id, service_package_id, budget_group_id,
	   element_set_id, salary_account_line, stage_set_id, start_stage_seq, current_stage_seq,
	   end_stage_seq, copy_of_account_line_id, last_update_date, last_updated_by,
	   last_update_login, created_by, creation_date, template_id, budget_year_id, annual_fte,
	   currency_code, account_type, balance_type,
	   period1_amount, period2_amount, period3_amount, period4_amount, period5_amount, period6_amount,
	   period7_amount, period8_amount, period9_amount, period10_amount, period11_amount, period12_amount,
	   period13_amount, period14_amount, period15_amount, period16_amount, period17_amount, period18_amount,
	   period19_amount, period20_amount, period21_amount, period22_amount, period23_amount, period24_amount,
	   period25_amount, period26_amount, period27_amount, period28_amount, period29_amount, period30_amount,
	   period31_amount, period32_amount, period33_amount, period34_amount, period35_amount, period36_amount,
	   period37_amount, period38_amount, period39_amount, period40_amount, period41_amount, period42_amount,
	   period43_amount, period44_amount, period45_amount, period46_amount, period47_amount, period48_amount,
	   period49_amount, period50_amount, period51_amount, period52_amount, period53_amount, period54_amount,
	   period55_amount, period56_amount, period57_amount, period58_amount, period59_amount, period60_amount,
	   ytd_amount, functional_transaction)
    select l_acclineid,
	   code_combination_id, position_line_id, service_package_id, budget_group_id,
	   element_set_id, salary_account_line, stage_set_id, start_stage_seq,
	   l_previous_stage,
	   l_previous_stage,
	   copy_of_account_line_id, sysdate,
	   l_userid, l_loginid, l_userid,
	   sysdate, template_id, budget_year_id, annual_fte, currency_code, account_type, balance_type,
	   period1_amount, period2_amount, period3_amount, period4_amount, period5_amount, period6_amount,
	   period7_amount, period8_amount, period9_amount, period10_amount, period11_amount, period12_amount,
	   period13_amount, period14_amount, period15_amount, period16_amount, period17_amount, period18_amount,
	   period19_amount, period20_amount, period21_amount, period22_amount, period23_amount, period24_amount,
	   period25_amount, period26_amount, period27_amount, period28_amount, period29_amount, period30_amount,
	   period31_amount, period32_amount, period33_amount, period34_amount, period35_amount, period36_amount,
	   period37_amount, period38_amount, period39_amount, period40_amount, period41_amount, period42_amount,
	   period43_amount, period44_amount, period45_amount, period46_amount, period47_amount, period48_amount,
	   period49_amount, period50_amount, period51_amount, period52_amount, period53_amount, period54_amount,
	   period55_amount, period56_amount, period57_amount, period58_amount, period59_amount, period60_amount,
	   ytd_amount, functional_transaction
      from PSB_WS_ACCOUNT_LINES
     where account_line_id = p_account_line_id;

    -- Create an entry for all the worksheets assigned to the current account line

    insert into PSB_WS_LINES
	  (worksheet_id, account_line_id, freeze_flag,
	   view_line_flag, last_update_date, last_updated_by,
	   last_update_login, created_by, creation_date)
    select worksheet_id, l_acclineid, freeze_flag,
	   view_line_flag, sysdate, l_userid,
	   l_loginid, l_userid, sysdate
      from PSB_WS_LINES
     where account_line_id = p_account_line_id;

  end;
  end if;

  -- If Service package is being modified and the target Account Line already exists,
  -- delete the target Account Line and increment values to the current Account Line

  if l_spal_exists then
  begin

    PSB_WORKSHEET.Delete_WAL
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_account_line_id => l_spal_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  -- Cache Budget Calendar

  if l_budget_calendar_id <> nvl(g_budget_calendar_id, FND_API.G_MISS_NUM) then
  begin

    Cache_Budget_Calendar
	 (p_return_status => l_return_status,
	  p_budget_calendar_id => l_budget_calendar_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  -- Find last Period index for the Budget Year to adjust the rounding difference
/* Bug No 2354918 Start */
   g_cy_start_index := 0;
/* Bug No 2354918 End */

  for l_year_index in 1..g_num_budget_years loop

    if g_budget_years(l_year_index).budget_year_id = l_budget_year_id then
      l_last_period_index := g_budget_years(l_year_index).last_period_index;
      l_start_date := g_budget_years(l_year_index).start_date;
      l_end_date := g_budget_years(l_year_index).end_date;
      l_budget_year_type_id := g_budget_years(l_year_index).budget_year_type_id;

/* Bug No 2354918 Start */
      l_budget_year_type := g_budget_years(l_year_index).year_type;

      if l_budget_year_type = 'CY' then
	for l_period_index in 1..g_num_budget_periods loop
	  if (g_budget_periods(l_period_index).budget_year_id = l_budget_year_id
	     and g_budget_periods(l_period_index).end_date <=
		 nvl(l_gl_cutoff_period, g_budget_years(l_year_index).end_date)) then
	  begin

	    g_cy_start_index := g_cy_start_index + 1;

	  end;
	  end if;
	end loop;
      end if;
/* Bug No 2354918 End */

      exit;
    end if;

  end loop;

/* Bug No 2342169 Start */
  g_cy_start_index := g_cy_start_index + 1;
/* Bug No 2342169 End */

  -- Bug#3128597: Support prorated allocation during annual amount updation
  -- The following is not needed. Proration logic should not use allocation
  -- if any period amount is not null.
  /*
  for i in g_cy_start_index..l_last_period_index loop
    if (nvl(l_prdamt_tbl(i), 0) = 0) then
	l_redist_palloc := 'Y';
	exit;
    end if;
  end loop;
  */
  -- Bug#3128597: End

  if p_budget_group_id <> FND_API.G_MISS_NUM then
    l_new_budget_group_id := p_budget_group_id;
  else
  begin

--bug:5929875:start
 /* bug:5929875:For the first time c_budget_group is executed and budget_group_id values
    are stored in plsql table g_bg_ccid_tbl. From next time onwards, the plsql table is
    referred for retrieving the budget_group_id details. This avoids repeated execution
    of the cursor c_budget_group. */

  IF PSB_WS_ACCT1.g_bg_ccid_tbl.COUNT = 0 THEN
   FOR l_budget_group_rec IN c_budget_group LOOP

      PSB_WS_ACCT1.g_bg_ccid_tbl(l_budget_group_rec.code_combination_id).ccid :=
                                  l_budget_group_rec.code_combination_id;

      PSB_WS_ACCT1.g_bg_ccid_tbl(l_budget_group_rec.code_combination_id).budget_group_id :=
                                  l_budget_group_rec.budget_group_id;

   END LOOP;
  END IF;

 IF PSB_WS_ACCT1.g_bg_ccid_tbl.EXISTS(l_ccid) THEN
   l_new_budget_group_id := PSB_WS_ACCT1.g_bg_ccid_tbl(l_ccid).budget_group_id;
 ELSE
   l_new_budget_group_id := null;
 END IF;

 --bug:5929875:end


  end;
  end if;

  if l_budget_group_id <> nvl(l_new_budget_group_id, l_budget_group_id) then
    l_budget_group_changed := TRUE;
  else
    l_new_budget_group_id := l_budget_group_id;
  end if;

/* Bug No 2354918 Start */
  l_cy_ytd_amount := 0;

  if l_budget_year_type = 'CY' then

  for c_WAL_Rec in c_WAL loop
  if c_WAL_Rec.budget_year_id = l_budget_year_id then

    if 1 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period1_amount, 0);
    end if;

    if 2 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period2_amount, 0);
    end if;

    if 3 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period3_amount, 0);
    end if;

    if 4 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period4_amount, 0);
    end if;

    if 5 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period5_amount, 0);
    end if;

    if 6 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period6_amount, 0);
    end if;

    if 7 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period7_amount, 0);
    end if;

    if 8 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period8_amount, 0);
    end if;

    if 9 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period9_amount, 0);
    end if;

    if 10 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period10_amount, 0);
    end if;

    if 11 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period11_amount, 0);
    end if;

    if 12 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period12_amount, 0);
    end if;

    if 13 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period13_amount, 0);
    end if;

    if 14 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period14_amount, 0);
    end if;

    if 15 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period15_amount, 0);
    end if;

    if 16 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period16_amount, 0);
    end if;

    if 17 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period17_amount, 0);
    end if;

    if 18 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period18_amount, 0);
    end if;

    if 19 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period19_amount, 0);
    end if;

    if 20 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period20_amount, 0);
    end if;

    if 21 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period21_amount, 0);
    end if;

    if 22 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period22_amount, 0);
    end if;

    if 23 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period23_amount, 0);
    end if;

    if 24 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period24_amount, 0);
    end if;

    if 25 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period25_amount, 0);
    end if;

    if 26 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period26_amount, 0);
    end if;

    if 27 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period27_amount, 0);
    end if;

    if 28 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period28_amount, 0);
    end if;

    if 29 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period29_amount, 0);
    end if;

    if 30 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period30_amount, 0);
    end if;

    if 31 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period31_amount, 0);
    end if;

    if 32 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period32_amount, 0);
    end if;

    if 33 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period33_amount, 0);
    end if;

    if 34 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period34_amount, 0);
    end if;

    if 35 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period35_amount, 0);
    end if;

    if 36 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period36_amount, 0);
    end if;

    if 37 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period37_amount, 0);
    end if;

    if 38 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period38_amount, 0);
    end if;

    if 39 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period39_amount, 0);
    end if;

    if 40 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period40_amount, 0);
    end if;

    if 41 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period41_amount, 0);
    end if;

    if 42 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period42_amount, 0);
    end if;

    if 43 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period43_amount, 0);
    end if;

    if 44 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period44_amount, 0);
    end if;

    if 45 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period45_amount, 0);
    end if;

    if 46 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period46_amount, 0);
    end if;

    if 47 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period47_amount, 0);
    end if;

    if 48 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period48_amount, 0);
    end if;

    if 49 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period49_amount, 0);
    end if;

    if 50 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period50_amount, 0);
    end if;

    if 51 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period51_amount, 0);
    end if;

    if 52 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period52_amount, 0);
    end if;

    if 53 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period53_amount, 0);
    end if;

    if 54 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period54_amount, 0);
    end if;

    if 55 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period55_amount, 0);
    end if;

    if 56 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period56_amount, 0);
    end if;

    if 57 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period57_amount, 0);
    end if;

    if 58 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period58_amount, 0);
    end if;

    if 59 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period59_amount, 0);
    end if;

    if 60 between 1 and g_cy_start_index - 1 then
      l_cy_ytd_amount := l_cy_ytd_amount + nvl(c_WAL_Rec.period60_amount, 0);
    end if;


  end if;
  end loop;

  end if;
/* Bug No 2354918 End */

  if FND_API.to_Boolean(p_distribute_flag) then
  begin

    -- If current YTD Amount is 0 and new YTD Amount is not 0, distribute
    -- using the Period Allocation rules.

/* Bug No 2342169 Start */
    -- if (((l_old_ytd_amount = 0) or (nvl(l_redist_palloc, 'N') = 'Y') or
    -- (l_budget_year_type = 'CY')) and
/* Bug No 2342169 End */

    -- Bug#3128597: Support prorated allocation during annual amount updation
    if ( ( l_old_ytd_amount = 0 or nvl(l_redist_palloc, 'N') = 'Y'
           or (l_old_ytd_amount = l_cy_ytd_amount)
         )
         and
         ( nvl(p_ytd_amount, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM)
       )
    then
    -- Bug#3128597: End
    begin
      for c_CCID_Rec in c_CCID loop
	l_ccid_start_date := c_CCID_Rec.start_date_active;
	l_ccid_end_date := c_CCID_Rec.end_date_active;
      end loop;

      for l_year_index in 1..g_num_budget_years loop

	if g_budget_years(l_year_index).budget_year_id = l_budget_year_id then
	begin

	  l_start_date := g_budget_years(l_year_index).start_date;
	  l_end_date := g_budget_years(l_year_index).end_date;

	  for l_init_index in 1..l_budget_periods.Count loop
	    l_budget_periods(l_init_index).budget_period_id := null;
	    l_budget_periods(l_init_index).start_date := null;
	    l_budget_periods(l_init_index).end_date := null;
	    l_budget_periods(l_init_index).long_sequence_no := null;
	    l_budget_periods(l_init_index).budget_year_id := null;
	  end loop;

	  l_init_index := 1;

	  for l_period_index in 1..g_num_budget_periods loop

	    if g_budget_periods(l_period_index).budget_year_id = l_budget_year_id then
	    begin

	      -- Get all Budget Periods for the PP Budget Year or all Budget Periods beyond the
	      -- GL Cutoff Date for the CY Budget Year

	      if (((l_ccid_start_date is null) or
		   (l_ccid_start_date <= g_budget_periods(l_period_index).start_date)) and
		  ((l_ccid_end_date is null) or
		   (l_ccid_end_date >= g_budget_periods(l_period_index).end_date)) and
		  ((g_budget_years(l_year_index).year_type = 'PP') or ((g_budget_years(l_year_index).year_type = 'CY') and
		  ((l_gl_cutoff_period is null) or (l_gl_cutoff_period < g_budget_periods(l_period_index).start_date))))) then
	      begin

		l_budget_periods(l_init_index).budget_period_id := g_budget_periods(l_period_index).budget_period_id;
		l_budget_periods(l_init_index).long_sequence_no := g_budget_periods(l_period_index).long_sequence_no;
		l_budget_periods(l_init_index).start_date := g_budget_periods(l_period_index).start_date;
		l_budget_periods(l_init_index).end_date := g_budget_periods(l_period_index).end_date;
		l_budget_periods(l_init_index).budget_year_id := l_budget_year_id;

		l_init_index := l_init_index + 1;

	      end;
	      end if;

	    end;
	    end if;

	  end loop;

	end;
	end if;

      end loop;

      /* Bug 3352171 start */
      -- Comment out the following two lines. The allocation logic will be
      -- handled in the PSB_WS_ACCT2.Distribute_Account_Lines function.
      --if nvl(l_allocrule_set_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
      -- then
      --begin
      /* Bug 3352171 end */

      if l_spal_exists then
        l_allocate_ytd_amount := nvl(p_ytd_amount, 0) + l_spytd_amount;
      else
        l_allocate_ytd_amount := nvl(p_ytd_amount, 0);
      end if;

      PSB_WS_ACCT2.Distribute_Account_Lines
      ( p_return_status => l_return_status,
        p_worksheet_id => p_worksheet_id,
        p_flex_mapping_set_id => l_flex_mapping_set_id,
        p_budget_year_type_id => l_budget_year_type_id,
        p_allocrule_set_id => l_allocrule_set_id,
        p_budget_calendar_id => l_budget_calendar_id,
        p_currency_code => l_currency_code,
        p_ccid => l_ccid,
        /* Bug No 2354918 Start */
        -- p_ytd_amount => l_allocate_ytd_amount,
        p_ytd_amount => (l_allocate_ytd_amount - l_cy_ytd_amount),
        /* Bug No 2354918 End */
        p_allocation_type => NULL, --Bug:5013900:Changed PERCENT to NULL.
        /* Bug No 2342169 Start */
        p_rounding_factor => l_rounding_factor,
        /* Bug No 2342169 End */
        p_effective_start_date => l_start_date,
        p_effective_end_date => l_end_date,
        p_budget_periods => l_budget_periods,
        p_period_amount => l_period_amount_tbl);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
      end if;

      /* Bug 3352171 start */
      -- comment out the following two lines. The allocation logic should not
      -- be handling here.
      --end;
      --end if;
      /* Bug 3352171 end */

      l_distribute1_flag := TRUE;

    end;

    -- If current YTD Amount is not 0, prorate the period amounts in the ratio
    -- of the YTD Amounts

    /* Bug No 2354918 Start */
    --elsif ((l_old_ytd_amount <> 0) and (l_budget_year_type <> 'CY') and
    /* Bug No 2354918 End */

    -- Bug#3128597: Support prorated allocation during annual amount updation
    elsif ( (l_old_ytd_amount <> 0) and
	    (nvl(p_ytd_amount, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM))
    then
    -- Bug#3128597: End
    begin

      if l_spal_exists then
	l_allocate_ytd_amount := nvl(p_ytd_amount, 0) + l_spytd_amount;
      else
	l_allocate_ytd_amount := nvl(p_ytd_amount, 0);
      end if;

      PSB_WS_ACCT2.Distribute_Account_Lines
	 (p_return_status => l_return_status,
	  p_worksheet_id => p_worksheet_id,
	  p_service_package_id => l_service_package_id,
	  p_stage_set_id => l_stage_set_id,
	  p_current_stage_seq => l_current_stage_seq,
	  p_account_line_id => p_account_line_id,
	  p_rounding_factor => l_rounding_factor,
	  p_old_ytd_amount => l_old_ytd_amount,
	  p_new_ytd_amount => l_allocate_ytd_amount,
	  p_cy_ytd_amount  => l_cy_ytd_amount,
	  p_budget_group_id => l_new_budget_group_id);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      l_distribute2_flag := TRUE;

    end;
    end if;

  end;
  end if;

  -- Update PSB_WS_ACCOUNT_LINES with input parameter values passed in.
  -- Bug#3132485: Replaced references to G_MISS_NUM by bind ones.

  -- Bug#5030613
  -- Replaced l_new_budget_group_id by b_budget_group_id bind variable.

  --replaced dynamic sql with static sql as part of perf fix:5929875

  -- Bug#3128597: Support prorated allocation during annual amount updation
  -- We need to process only estimate periods in this loop for CY/PP years.
  /* for l_index in 1..g_max_num_amounts loop */
  /* for l_index in g_cy_start_index..l_last_period_index loop */
  -- Bug#3128597: End

  -- Bug#3258892: For position account lines, we calculate estimate balances
  -- for entire CY from position costs and ignore GL cut-off date.
  IF l_position_line_id IS NOT NULL THEN
    l_cy_start_index := 1 ;
  ELSE
    l_cy_start_index := g_cy_start_index ;
  END IF;
  --
  FOR l_index IN l_cy_start_index..l_last_period_index LOOP

    if FND_API.to_Boolean(p_distribute_flag) then
    begin

      IF l_distribute1_flag THEN
      /* Bug 3197852 Start */
        IF l_rounding_factor is null THEN
          l_period_amount := l_period_amount_tbl(l_index);
        ELSE
          l_period_amount := ROUND(l_period_amount_tbl(l_index)/l_rounding_factor) * l_rounding_factor;
        END IF;
      /* Bug 3197852 End */
	l_running_ytd_amount := l_running_ytd_amount + nvl(l_period_amount, 0);

      END IF;

    end;
    else
    begin

      if l_rounding_factor is null then
	l_period_amount := p_period_amount(l_index);
      else
	l_period_amount := ROUND(p_period_amount(l_index)/l_rounding_factor) * l_rounding_factor;
      end if;

      l_running_ytd_amount := l_running_ytd_amount + nvl(l_period_amount, 0);

    end;
    end if;

  end loop;

/* Bug No 2354918 Start */
  if l_cy_ytd_amount <> 0 then
     l_running_ytd_amount := l_running_ytd_amount + l_cy_ytd_amount;
  end if;
/* Bug No 2354918 End */

  if l_rounding_factor is null then
  begin

    if l_spal_exists then
      l_new_ytd_amount := nvl(p_ytd_amount, 0) + l_spytd_amount;
    else
      l_new_ytd_amount := nvl(p_ytd_amount, 0);
    end if;

    l_rounding_difference := 0;

  end;
  else
  begin

    l_new_ytd_amount := ROUND(nvl(p_ytd_amount, 0) / l_rounding_factor) * l_rounding_factor;

    if l_spal_exists then
      l_new_ytd_amount := l_new_ytd_amount + l_spytd_amount;
    end if;

    /* Bug No 2379695 Start */
    -- Commented the IF condition
    --    if ((l_running_ytd_amount > 0) and (l_new_ytd_amount > 0)) then
    --    end if;

    /* start bug 4128196 */
    IF NVL(p_update_cy_estimate, 'N') = 'Y' THEN
      l_rounding_difference := 0;
    ELSE
      l_rounding_difference := l_new_ytd_amount - l_running_ytd_amount;
    END IF;
    /* end bug 4128196 */


    /* Bug No 2379695 End */

  end;
  end if;

  if not FND_API.to_Boolean(p_distribute_flag) then
  begin

    for l_index in 1..g_max_num_amounts loop

      if l_rounding_factor is null then
	l_period_amount := p_period_amount(l_index);
      else
	l_period_amount := ROUND(p_period_amount(l_index)/l_rounding_factor) * l_rounding_factor;
      end if;

     /* start bug no 4128196 */
	IF NVL(p_update_cy_estimate, 'N') = 'Y' THEN
	  l_running_total := NVL(l_running_total, 0) + NVL(l_period_amount, 0);
	END IF;
     /* end bug no 4128196 */


      if l_period_amount is null then
      begin

	if l_index = l_last_period_index then
          /* Bug 3663044: Use binding variables
	  sql_wsacc := sql_wsacc ||
		      'period' || l_index || '_amount = ' || nvl(l_rounding_difference, 0)  || ', ';
          */
          l_prdamt_tbl(l_index) := nvl(l_rounding_difference, 0);
	else
          /* Bug 3663044: Use binding variables
	  sql_wsacc := sql_wsacc ||
		      'period' || l_index || '_amount = null, ';
          */
          l_prdamt_tbl(l_index) := null;
	end if;

      end;
      else
      begin

	if l_index = l_last_period_index then
          /* Bug 3663044: Use binding variables
	  sql_wsacc := sql_wsacc ||
		      'period' || l_index || '_amount = ' || (l_period_amount + nvl(l_rounding_difference, 0)) || ', ';
          */

           /* start bug no 4128196 */
	   IF NVL(p_update_cy_estimate, 'N') = 'Y' THEN
             l_prdamt_tbl(l_index) := l_period_amount +
                                      (l_new_ytd_amount - l_running_total) +
                                      NVL(l_rounding_difference, 0);

	  ELSE
             l_prdamt_tbl(l_index) := l_period_amount +
                                   nvl(l_rounding_difference, 0);
          END IF;
	  /* end bug no 4128196 */

	else
          /* Bug 3663044: Use binding variables
	  sql_wsacc := sql_wsacc ||
		      'period' || l_index || '_amount = ' || l_period_amount || ', ';
          */
          l_prdamt_tbl(l_index) := l_period_amount;
	end if;

      end;
      end if;


    end loop;


  end;
  else
  begin

    if l_distribute1_flag then
    begin

      for l_index in 1..g_max_num_amounts loop

	if l_rounding_factor is null then
	  l_period_amount := l_period_amount_tbl(l_index);
	else
	  l_period_amount := ROUND(l_period_amount_tbl(l_index)/l_rounding_factor) * l_rounding_factor;
	end if;

       /* start bug no 4128196 */
	IF NVL(p_update_cy_estimate, 'N') = 'Y' THEN
	  l_running_total := NVL(l_running_total, 0) + NVL(l_period_amount, 0);
	END IF;
      /* end bug no 4128196 */

	if l_period_amount is null then
	begin

	  if l_index = l_last_period_index then
            /* Bug 3663044: Use binding variables
	    sql_wsacc := sql_wsacc ||
			'period' || l_index || '_amount = ' || nvl(l_rounding_difference, 0) || ', ';
            */
            l_prdamt_tbl(l_index) := nvl(l_rounding_difference, 0);
/* Bug No 2354918 Start */
--          else
	  elsif l_index >= g_cy_start_index then
/* Bug No 2354918 End */
            /* Bug 3663044: Use binding variables
	    sql_wsacc := sql_wsacc ||
			'period' || l_index || '_amount = null, ';
            */
            l_prdamt_tbl(l_index) := null;
	  end if;

	end;
	else
	begin

	  if l_index = l_last_period_index then
            /* Bug 3663044: Use binding variables
	    sql_wsacc := sql_wsacc ||
			'period' || l_index || '_amount = ' || (l_period_amount + nvl(l_rounding_difference, 0)) || ', ';
            */

          /* start bug no 4128196 */
	  IF NVL(p_update_cy_estimate, 'N') = 'Y' THEN
             l_prdamt_tbl(l_index) := l_period_amount +
                                      (l_new_ytd_amount - l_running_total) +
                                      NVL(l_rounding_difference, 0);

	  ELSE
            l_prdamt_tbl(l_index) := l_period_amount +
                                     nvl(l_rounding_difference, 0);
          END IF;
          /* end bug no 4128196 */

/* Bug No 2354918 Start */
--          else
	  elsif l_index >= g_cy_start_index then
/* Bug No 2354918 End */
            /* Bug 3663044: Use binding variables
	    sql_wsacc := sql_wsacc ||
			'period' || l_index || '_amount = ' || l_period_amount || ', ';
            */
            l_prdamt_tbl(l_index) := l_period_amount;
	  end if;

	end;
	end if;


      end loop;

    end;
    end if;

  end;
  end if;

  --
  -- If new Stage has been created, update Start Stage and Current Stage
  -- Sequences for the current Account Line; otherwise, update Current Stage
  -- Sequence only if passed in as input parameter value
  --

  -- Bug#3132485: Replaced references to G_MISS_NUM by bind ones.
  /*
  -- num_wsacc := dsql_execute(sql_wsacc);
  if num_wsacc < 0 then
    raise FND_API.G_EXC_ERROR;
  end if;
  */

  -- Note there are 2 variations of the statement requiring different number
  -- of bind variables. The following condition causes the variations.
  IF (     FND_API.To_Boolean( p_check_stages )
       AND l_new_stage
       AND ( l_start_stage_seq < l_current_stage_seq )
     )
  THEN
    -- Bug 3663044: Add the condition for NOT l_distribute1_flag
    IF FND_API.to_Boolean(p_distribute_flag) and NOT l_distribute1_flag then

      /*Added for bug:5929875:start*/
      UPDATE psb_ws_account_lines
      set service_package_id = decode(p_service_package_id, FND_API.G_MISS_NUM, service_package_id, p_service_package_id),
      budget_group_id = l_new_budget_group_id,
      copy_of_account_line_id = decode(p_copy_of_account_line_id,FND_API.G_MISS_NUM,copy_of_account_line_id,p_copy_of_account_line_id),
      annual_fte = decode(nvl(p_annual_fte, FND_API.G_MISS_NUM), FND_API.G_MISS_NUM, annual_fte, nvl(p_annual_fte, FND_API.G_MISS_NUM)),
      last_update_date = l_last_update_date,
      last_updated_by = l_userid,
      last_update_login = l_loginid,
      start_stage_seq   = l_current_stage_seq,
      current_stage_seq = l_current_stage_seq
      WHERE account_line_id = p_account_line_id;
      /*bug:5929875:end*/

    ELSE

      /*Added for bug:5929875:start*/
      UPDATE psb_ws_account_lines
      set   service_package_id = decode(p_service_package_id, FND_API.G_MISS_NUM, service_package_id, p_service_package_id),
            budget_group_id = l_new_budget_group_id,
            copy_of_account_line_id = decode(p_copy_of_account_line_id,FND_API.G_MISS_NUM,copy_of_account_line_id,p_copy_of_account_line_id),
            annual_fte = decode(nvl(p_annual_fte, FND_API.G_MISS_NUM), FND_API.G_MISS_NUM, annual_fte, nvl(p_annual_fte, FND_API.G_MISS_NUM)),
	    period1_amount = l_prdamt_tbl(1),period2_amount = l_prdamt_tbl(2),
	    period3_amount = l_prdamt_tbl(3),period4_amount = l_prdamt_tbl(4),
	    period5_amount = l_prdamt_tbl(5),period6_amount = l_prdamt_tbl(6),
	    period7_amount = l_prdamt_tbl(7),period8_amount = l_prdamt_tbl(8),
	    period9_amount = l_prdamt_tbl(9),period10_amount = l_prdamt_tbl(10),
	    period11_amount = l_prdamt_tbl(11),period12_amount = l_prdamt_tbl(12),
	    period13_amount = l_prdamt_tbl(13),period14_amount = l_prdamt_tbl(14),
	    period15_amount = l_prdamt_tbl(15),period16_amount = l_prdamt_tbl(16),
	    period17_amount = l_prdamt_tbl(17),period18_amount = l_prdamt_tbl(18),
	    period19_amount = l_prdamt_tbl(19),period20_amount = l_prdamt_tbl(20),
	    period21_amount = l_prdamt_tbl(21),period22_amount = l_prdamt_tbl(22),
	    period23_amount = l_prdamt_tbl(23),period24_amount = l_prdamt_tbl(24),
	    period25_amount = l_prdamt_tbl(25),period26_amount = l_prdamt_tbl(26),
	    period27_amount = l_prdamt_tbl(27),period28_amount = l_prdamt_tbl(28),
	    period29_amount = l_prdamt_tbl(29),period30_amount = l_prdamt_tbl(30),
	    period31_amount = l_prdamt_tbl(31),period32_amount = l_prdamt_tbl(32),
	    period33_amount = l_prdamt_tbl(33),period34_amount = l_prdamt_tbl(34),
	    period35_amount = l_prdamt_tbl(35),period36_amount = l_prdamt_tbl(36),
	    period37_amount = l_prdamt_tbl(37),period38_amount = l_prdamt_tbl(38),
	    period39_amount = l_prdamt_tbl(39),period40_amount = l_prdamt_tbl(40),
	    period41_amount = l_prdamt_tbl(41),period42_amount = l_prdamt_tbl(42),
	    period43_amount = l_prdamt_tbl(43),period44_amount = l_prdamt_tbl(44),
	    period45_amount = l_prdamt_tbl(45),period46_amount = l_prdamt_tbl(46),
	    period47_amount = l_prdamt_tbl(47),period48_amount = l_prdamt_tbl(48),
	    period49_amount = l_prdamt_tbl(49),period50_amount = l_prdamt_tbl(50),
	    period51_amount = l_prdamt_tbl(51),period52_amount = l_prdamt_tbl(52),
	    period53_amount = l_prdamt_tbl(53),period54_amount = l_prdamt_tbl(54),
	    period55_amount = l_prdamt_tbl(55),period56_amount = l_prdamt_tbl(56),
	    period57_amount = l_prdamt_tbl(57),period58_amount = l_prdamt_tbl(58),
	    period59_amount = l_prdamt_tbl(59),period60_amount = l_prdamt_tbl(60),
	    ytd_amount = l_new_ytd_amount,
	    last_update_date = l_last_update_date,
	    last_updated_by = l_userid,
	    last_update_login = l_loginid,
	    start_stage_seq   = l_current_stage_seq,
	    current_stage_seq = l_current_stage_seq
      WHERE account_line_id = p_account_line_id;
      /*bug:5929875:end*/
    END IF ;
  ELSE

    -- Bug 3663044: Add the condition for NOT l_distribute1_flag
    IF FND_API.to_Boolean(p_distribute_flag) and NOT l_distribute1_flag then

     /*Added for bug:5929875:start:replaced dynamic sql with static sql*/
      UPDATE psb_ws_account_lines
      set   service_package_id = decode(p_service_package_id, FND_API.G_MISS_NUM, service_package_id, p_service_package_id),
            budget_group_id = l_new_budget_group_id,
            copy_of_account_line_id = decode(p_copy_of_account_line_id,FND_API.G_MISS_NUM,copy_of_account_line_id,p_copy_of_account_line_id),
            annual_fte = decode(nvl(p_annual_fte, FND_API.G_MISS_NUM), FND_API.G_MISS_NUM, annual_fte, nvl(p_annual_fte, FND_API.G_MISS_NUM)),
       	    last_update_date = l_last_update_date,
	          last_updated_by = l_userid,
	          last_update_login = l_loginid,
	          current_stage_seq = decode(p_current_stage_seq, FND_API.G_MISS_NUM, current_stage_seq,p_current_stage_seq)
      WHERE account_line_id = p_account_line_id;
      /*bug:5929875:end*/

    ELSE

      /*Added for bug:5929875:start:used static update sql instead of dynamic sql*/
      UPDATE psb_ws_account_lines
      set   service_package_id = decode(p_service_package_id, FND_API.G_MISS_NUM, service_package_id, p_service_package_id),
            budget_group_id = l_new_budget_group_id,
            copy_of_account_line_id = decode(p_copy_of_account_line_id,FND_API.G_MISS_NUM,copy_of_account_line_id,p_copy_of_account_line_id),
            annual_fte = decode(nvl(p_annual_fte, FND_API.G_MISS_NUM), FND_API.G_MISS_NUM, annual_fte, nvl(p_annual_fte, FND_API.G_MISS_NUM)),
	    period1_amount = l_prdamt_tbl(1),period2_amount = l_prdamt_tbl(2),
	    period3_amount = l_prdamt_tbl(3),period4_amount = l_prdamt_tbl(4),
	    period5_amount = l_prdamt_tbl(5),period6_amount = l_prdamt_tbl(6),
	    period7_amount = l_prdamt_tbl(7),period8_amount = l_prdamt_tbl(8),
	    period9_amount = l_prdamt_tbl(9),period10_amount = l_prdamt_tbl(10),
	    period11_amount = l_prdamt_tbl(11),period12_amount = l_prdamt_tbl(12),
	    period13_amount = l_prdamt_tbl(13),period14_amount = l_prdamt_tbl(14),
	    period15_amount = l_prdamt_tbl(15),period16_amount = l_prdamt_tbl(16),
	    period17_amount = l_prdamt_tbl(17),period18_amount = l_prdamt_tbl(18),
	    period19_amount = l_prdamt_tbl(19),period20_amount = l_prdamt_tbl(20),
	    period21_amount = l_prdamt_tbl(21),period22_amount = l_prdamt_tbl(22),
	    period23_amount = l_prdamt_tbl(23),period24_amount = l_prdamt_tbl(24),
	    period25_amount = l_prdamt_tbl(25),period26_amount = l_prdamt_tbl(26),
	    period27_amount = l_prdamt_tbl(27),period28_amount = l_prdamt_tbl(28),
	    period29_amount = l_prdamt_tbl(29),period30_amount = l_prdamt_tbl(30),
	    period31_amount = l_prdamt_tbl(31),period32_amount = l_prdamt_tbl(32),
	    period33_amount = l_prdamt_tbl(33),period34_amount = l_prdamt_tbl(34),
	    period35_amount = l_prdamt_tbl(35),period36_amount = l_prdamt_tbl(36),
	    period37_amount = l_prdamt_tbl(37),period38_amount = l_prdamt_tbl(38),
	    period39_amount = l_prdamt_tbl(39),period40_amount = l_prdamt_tbl(40),
	    period41_amount = l_prdamt_tbl(41),period42_amount = l_prdamt_tbl(42),
	    period43_amount = l_prdamt_tbl(43),period44_amount = l_prdamt_tbl(44),
	    period45_amount = l_prdamt_tbl(45),period46_amount = l_prdamt_tbl(46),
	    period47_amount = l_prdamt_tbl(47),period48_amount = l_prdamt_tbl(48),
	    period49_amount = l_prdamt_tbl(49),period50_amount = l_prdamt_tbl(50),
	    period51_amount = l_prdamt_tbl(51),period52_amount = l_prdamt_tbl(52),
	    period53_amount = l_prdamt_tbl(53),period54_amount = l_prdamt_tbl(54),
	    period55_amount = l_prdamt_tbl(55),period56_amount = l_prdamt_tbl(56),
	    period57_amount = l_prdamt_tbl(57),period58_amount = l_prdamt_tbl(58),
	    period59_amount = l_prdamt_tbl(59),period60_amount = l_prdamt_tbl(60),
            ytd_amount        = l_new_ytd_amount,
	    last_update_date  = l_last_update_date,
	    last_updated_by   = l_userid,
	    last_update_login = l_loginid,
	    current_stage_seq = decode(p_current_stage_seq, FND_API.G_MISS_NUM, current_stage_seq,p_current_stage_seq)
 WHERE account_line_id = p_account_line_id;
      /*bug:5929875:end*/
    END IF;

  END IF ;

  -- Update was successful; if budget group was changed reassign worksheets
  IF l_budget_group_changed
  THEN
    BEGIN
      DELETE FROM psb_ws_lines
       WHERE account_line_id = p_account_line_id;

      -- Create an entry in PSB_WS_LINES for all worksheets to which the CCID or Position belongs

      IF l_position_line_id IS NOT NULL
      THEN
        BEGIN
          INSERT INTO PSB_WS_LINES
          (worksheet_id, account_line_id, freeze_flag, view_line_flag,
           last_update_date, last_updated_by, last_update_login, created_by,
           creation_date)
          SELECT worksheet_id, p_account_line_id, freeze_flag, view_line_flag,
                 sysdate, l_userid,l_loginid, l_userid, sysdate
            FROM PSB_WS_LINES_POSITIONS
           WHERE position_line_id = l_position_line_id;

          /* Start bug #4167811 */
          UPDATE psb_ws_account_lines SET budget_group_changed = 'Y'
           WHERE account_line_id = p_account_line_id;
          /* End bug #4167811 */
        END;

      ELSE
        BEGIN

          -- Bug 3543845: During ws creation, distributed ws does not exist.
          -- Also flip the condition to make it readable.
          -- if nvl(l_local_copy_flag, 'N') <> 'Y' then
          IF PSB_WORKSHEET.g_ws_creation_flag OR l_local_copy_flag = 'Y'
          THEN
            BEGIN

              INSERT INTO PSB_WS_LINES
              (worksheet_id, account_line_id, freeze_flag, view_line_flag,
               last_update_date, last_updated_by, last_update_login,
               created_by, creation_date)
              VALUES (p_worksheet_id, p_account_line_id, null, 'Y', sysdate,
              l_userid, l_loginid, l_userid, sysdate);
            END;

          ELSE
            BEGIN
              FOR c_Distribute_WS_Rec IN c_Distribute_WS(l_global_worksheet_id,
                p_budget_group_id, g_startdate_pp, g_enddate_cy)
              LOOP
                INSERT INTO PSB_WS_LINES
                (worksheet_id, account_line_id, freeze_flag, view_line_flag,
                 last_update_date, last_updated_by, last_update_login,
                 created_by, creation_date)
                VALUES (c_Distribute_WS_Rec.worksheet_id, p_account_line_id,
                null,'Y', sysdate, l_userid, l_loginid, l_userid, sysdate);
              END LOOP;
            END;

          END IF; -- End of : IF PSB_WORKSHEET.g_ws_creation_flag OR ...
        END;

      END IF; -- End of : IF l_position_line_id IS NOT NULL
    END;

  END IF; -- End of : IF l_budget_group_changed

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if dbms_sql.is_open(cur_wsacc) then
       dbms_sql.close_cursor(cur_wsacc);
     end if;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Create_Account_Dist;

/* ----------------------------------------------------------------------- */

-- Copy Actual Balances for Current Year as Estimate Balances up to the
-- GL Cutoff Period. This is needed because Actual and Estimate Balances
-- are stored as separate entries in PSB_WS_ACCOUNT_LINES

PROCEDURE Copy_CY_Estimates
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id        IN   NUMBER,
  p_service_package_id  IN   NUMBER,
  p_rounding_factor     IN   NUMBER,
  p_start_stage_seq     IN   NUMBER,
  p_budget_group_id     IN   NUMBER,
  p_stage_set_id        IN   NUMBER,
  p_budget_year_id      IN   NUMBER,
  p_ccid                IN   NUMBER,
  p_currency_code       IN   VARCHAR2
) IS

  l_return_status       VARCHAR2(1);

  l_init_index          PLS_INTEGER;

  l_account_line_id     NUMBER;

  l_ytd_amount          NUMBER := 0;
  l_period_amount       g_prdamt_tbl_type;

    /*bug:7148726:start*/
  l_total_est_amount    NUMBER := 0;
  l_end_index           NUMBER := 0;
  l_budget_calendar_id  NUMBER := 0;
    /*bug:7148726:end*/

  -- Bug 3543845
  -- l_create_zero_bal     VARCHAR2(1);

  -- There are 2 separate cursors c_WAL_Act (for Actuals) and c_WAL_Est
  -- (for Estimates) to avoid static binding of cursors

/* Bug:5929875:modified the cursor to avoid the exists clause.
   psb_ws_lines table moved from exists clause to main query. */

  cursor c_WAL_Act is
    select ytd_amount,
	   period1_amount, period2_amount, period3_amount, period4_amount,
	   period5_amount, period6_amount, period7_amount, period8_amount,
	   period9_amount, period10_amount, period11_amount, period12_amount,
	   period13_amount, period14_amount, period15_amount, period16_amount,
	   period17_amount, period18_amount, period19_amount, period20_amount,
	   period21_amount, period22_amount, period23_amount, period24_amount,
	   period25_amount, period26_amount, period27_amount, period28_amount,
	   period29_amount, period30_amount, period31_amount, period32_amount,
	   period33_amount, period34_amount, period35_amount, period36_amount,
	   period37_amount, period38_amount, period39_amount, period40_amount,
	   period41_amount, period42_amount, period43_amount, period44_amount,
	   period45_amount, period46_amount, period47_amount, period48_amount,
	   period49_amount, period50_amount, period51_amount, period52_amount,
	   period53_amount, period54_amount, period55_amount, period56_amount,
	   period57_amount, period58_amount, period59_amount, period60_amount
      from PSB_WS_ACCOUNT_LINES a, PSB_WS_LINES b
     where a.template_id is null
       and a.position_line_id is null
       and a.currency_code = p_currency_code
       and p_start_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.balance_type = 'A'
       and b.account_line_id = a.account_line_id
       and b.worksheet_id = p_worksheet_id
       and a.stage_set_id = p_stage_set_id
       and a.service_package_id = p_service_package_id
       and a.budget_year_id = p_budget_year_id
       and a.budget_group_id = p_budget_group_id
       and a.code_combination_id = p_ccid;

/* Bug:5929875:modified the cursor to avoid the exists clause.
   psb_ws_lines table moved from exists clause to main query. */

  cursor c_WAL_Est is
    select ytd_amount,
	   period1_amount, period2_amount, period3_amount, period4_amount,
	   period5_amount, period6_amount, period7_amount, period8_amount,
	   period9_amount, period10_amount, period11_amount, period12_amount,
	   period13_amount, period14_amount, period15_amount, period16_amount,
	   period17_amount, period18_amount, period19_amount, period20_amount,
	   period21_amount, period22_amount, period23_amount, period24_amount,
	   period25_amount, period26_amount, period27_amount, period28_amount,
	   period29_amount, period30_amount, period31_amount, period32_amount,
	   period33_amount, period34_amount, period35_amount, period36_amount,
	   period37_amount, period38_amount, period39_amount, period40_amount,
	   period41_amount, period42_amount, period43_amount, period44_amount,
	   period45_amount, period46_amount, period47_amount, period48_amount,
	   period49_amount, period50_amount, period51_amount, period52_amount,
	   period53_amount, period54_amount, period55_amount, period56_amount,
	   period57_amount, period58_amount, period59_amount, period60_amount
      from PSB_WS_ACCOUNT_LINES a,PSB_WS_LINES b
     where a.template_id is null
       and a.position_line_id is null
       and a.currency_code = p_currency_code
       and p_start_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.balance_type = 'E'
       and b.account_line_id = a.account_line_id
       and b.worksheet_id = p_worksheet_id
       and a.stage_set_id = p_stage_set_id
       and a.service_package_id = p_service_package_id
       and a.budget_year_id = p_budget_year_id
       and a.budget_group_id = p_budget_group_id
       and a.code_combination_id = p_ccid;

/*bug:7148726:start*/
  cursor c_BudPrd (budyr_id NUMBER) is
    select count(*) periodcnt
      from PSB_BUDGET_PERIODS
     where budget_period_type = 'P'
       and parent_budget_period_id = budyr_id
       and budget_calendar_id = l_budget_calendar_id;
/*bug:7148726:end*/

BEGIN

/*bug:7148726:start*/
 /* g_est_last_period_index is populated with last estimate period index in the current year.*/

  IF  NVL(g_est_last_period_index,0) = 0 THEN
   for l_ws_rec in (select budget_calendar_id
                      from psb_worksheets
                      where worksheet_id=p_worksheet_id) loop
       l_budget_calendar_id := l_ws_rec.budget_calendar_id;
   end loop;

   for l_budprd_rec in c_BudPrd(p_budget_year_id) loop
     g_est_last_period_index := l_budprd_rec.periodcnt;
   end loop;
  END IF;
/*bug:7148726:end*/

  for l_init_index in 1..g_max_num_amounts loop
    l_period_amount(l_init_index) := null;
  end loop;

  for c_WAL_Rec in c_WAL_Act loop

    l_ytd_amount := c_WAL_Rec.ytd_amount;

    if c_WAL_Rec.period1_amount is not null then
      l_period_amount(1) := c_WAL_Rec.period1_amount;
    end if;

    if c_WAL_Rec.period2_amount is not null then
      l_period_amount(2) := c_WAL_Rec.period2_amount;
    end if;

    if c_WAL_Rec.period3_amount is not null then
      l_period_amount(3) := c_WAL_Rec.period3_amount;
    end if;

    if c_WAL_Rec.period4_amount is not null then
      l_period_amount(4) := c_WAL_Rec.period4_amount;
    end if;

    if c_WAL_Rec.period5_amount is not null then
      l_period_amount(5) := c_WAL_Rec.period5_amount;
    end if;

    if c_WAL_Rec.period6_amount is not null then
      l_period_amount(6) := c_WAL_Rec.period6_amount;
    end if;

    if c_WAL_Rec.period7_amount is not null then
      l_period_amount(7) := c_WAL_Rec.period7_amount;
    end if;

    if c_WAL_Rec.period8_amount is not null then
      l_period_amount(8) := c_WAL_Rec.period8_amount;
    end if;

    if c_WAL_Rec.period9_amount is not null then
      l_period_amount(9) := c_WAL_Rec.period9_amount;
    end if;

    if c_WAL_Rec.period10_amount is not null then
      l_period_amount(10) := c_WAL_Rec.period10_amount;
    end if;

    if c_WAL_Rec.period11_amount is not null then
      l_period_amount(11) := c_WAL_Rec.period11_amount;
    end if;

    if c_WAL_Rec.period12_amount is not null then
      l_period_amount(12) := c_WAL_Rec.period12_amount;
    end if;

    if c_WAL_Rec.period13_amount is not null then
      l_period_amount(13) := c_WAL_Rec.period13_amount;
    end if;

    if c_WAL_Rec.period14_amount is not null then
      l_period_amount(14) := c_WAL_Rec.period14_amount;
    end if;

    if c_WAL_Rec.period15_amount is not null then
      l_period_amount(15) := c_WAL_Rec.period15_amount;
    end if;

    if c_WAL_Rec.period16_amount is not null then
      l_period_amount(16) := c_WAL_Rec.period16_amount;
    end if;

    if c_WAL_Rec.period17_amount is not null then
      l_period_amount(17) := c_WAL_Rec.period17_amount;
    end if;

    if c_WAL_Rec.period18_amount is not null then
      l_period_amount(18) := c_WAL_Rec.period18_amount;
    end if;

    if c_WAL_Rec.period19_amount is not null then
      l_period_amount(19) := c_WAL_Rec.period19_amount;
    end if;

    if c_WAL_Rec.period20_amount is not null then
      l_period_amount(20) := c_WAL_Rec.period20_amount;
    end if;

    if c_WAL_Rec.period21_amount is not null then
      l_period_amount(21) := c_WAL_Rec.period21_amount;
    end if;

    if c_WAL_Rec.period22_amount is not null then
      l_period_amount(22) := c_WAL_Rec.period22_amount;
    end if;

    if c_WAL_Rec.period23_amount is not null then
      l_period_amount(23) := c_WAL_Rec.period23_amount;
    end if;

    if c_WAL_Rec.period24_amount is not null then
      l_period_amount(24) := c_WAL_Rec.period24_amount;
    end if;

    if c_WAL_Rec.period25_amount is not null then
      l_period_amount(25) := c_WAL_Rec.period25_amount;
    end if;

    if c_WAL_Rec.period26_amount is not null then
      l_period_amount(26) := c_WAL_Rec.period26_amount;
    end if;

    if c_WAL_Rec.period27_amount is not null then
      l_period_amount(27) := c_WAL_Rec.period27_amount;
    end if;

    if c_WAL_Rec.period28_amount is not null then
      l_period_amount(28) := c_WAL_Rec.period28_amount;
    end if;

    if c_WAL_Rec.period29_amount is not null then
      l_period_amount(29) := c_WAL_Rec.period29_amount;
    end if;

    if c_WAL_Rec.period30_amount is not null then
      l_period_amount(30) := c_WAL_Rec.period30_amount;
    end if;

    if c_WAL_Rec.period31_amount is not null then
      l_period_amount(31) := c_WAL_Rec.period31_amount;
    end if;

    if c_WAL_Rec.period32_amount is not null then
      l_period_amount(32) := c_WAL_Rec.period32_amount;
    end if;

    if c_WAL_Rec.period33_amount is not null then
      l_period_amount(33) := c_WAL_Rec.period33_amount;
    end if;

    if c_WAL_Rec.period34_amount is not null then
      l_period_amount(34) := c_WAL_Rec.period34_amount;
    end if;

    if c_WAL_Rec.period35_amount is not null then
      l_period_amount(35) := c_WAL_Rec.period35_amount;
    end if;

    if c_WAL_Rec.period36_amount is not null then
      l_period_amount(36) := c_WAL_Rec.period36_amount;
    end if;

    if c_WAL_Rec.period37_amount is not null then
      l_period_amount(37) := c_WAL_Rec.period37_amount;
    end if;

    if c_WAL_Rec.period38_amount is not null then
      l_period_amount(38) := c_WAL_Rec.period38_amount;
    end if;

    if c_WAL_Rec.period39_amount is not null then
      l_period_amount(39) := c_WAL_Rec.period39_amount;
    end if;

    if c_WAL_Rec.period40_amount is not null then
      l_period_amount(40) := c_WAL_Rec.period40_amount;
    end if;

    if c_WAL_Rec.period41_amount is not null then
      l_period_amount(41) := c_WAL_Rec.period41_amount;
    end if;

    if c_WAL_Rec.period42_amount is not null then
      l_period_amount(42) := c_WAL_Rec.period42_amount;
    end if;

    if c_WAL_Rec.period43_amount is not null then
      l_period_amount(43) := c_WAL_Rec.period43_amount;
    end if;

    if c_WAL_Rec.period44_amount is not null then
      l_period_amount(44) := c_WAL_Rec.period44_amount;
    end if;

    if c_WAL_Rec.period45_amount is not null then
      l_period_amount(45) := c_WAL_Rec.period45_amount;
    end if;

    if c_WAL_Rec.period46_amount is not null then
      l_period_amount(46) := c_WAL_Rec.period46_amount;
    end if;

    if c_WAL_Rec.period47_amount is not null then
      l_period_amount(47) := c_WAL_Rec.period47_amount;
    end if;

    if c_WAL_Rec.period48_amount is not null then
      l_period_amount(48) := c_WAL_Rec.period48_amount;
    end if;

    if c_WAL_Rec.period49_amount is not null then
      l_period_amount(49) := c_WAL_Rec.period49_amount;
    end if;

    if c_WAL_Rec.period50_amount is not null then
      l_period_amount(50) := c_WAL_Rec.period50_amount;
    end if;

    if c_WAL_Rec.period51_amount is not null then
      l_period_amount(51) := c_WAL_Rec.period51_amount;
    end if;

    if c_WAL_Rec.period52_amount is not null then
      l_period_amount(52) := c_WAL_Rec.period52_amount;
    end if;

    if c_WAL_Rec.period53_amount is not null then
      l_period_amount(53) := c_WAL_Rec.period53_amount;
    end if;

    if c_WAL_Rec.period54_amount is not null then
      l_period_amount(54) := c_WAL_Rec.period54_amount;
    end if;

    if c_WAL_Rec.period55_amount is not null then
      l_period_amount(55) := c_WAL_Rec.period55_amount;
    end if;

    if c_WAL_Rec.period56_amount is not null then
      l_period_amount(56) := c_WAL_Rec.period56_amount;
    end if;

    if c_WAL_Rec.period57_amount is not null then
      l_period_amount(57) := c_WAL_Rec.period57_amount;
    end if;

    if c_WAL_Rec.period58_amount is not null then
      l_period_amount(58) := c_WAL_Rec.period58_amount;
    end if;

    if c_WAL_Rec.period59_amount is not null then
      l_period_amount(59) := c_WAL_Rec.period59_amount;
    end if;

    if c_WAL_Rec.period60_amount is not null then
      l_period_amount(60) := c_WAL_Rec.period60_amount;
    end if;

    exit;

  end loop;

  -- Added the following condition as part of bug fix 3469514
  IF g_enddate_cy <> NVL(PSB_WORKSHEET.g_gl_cutoff_period,FND_API.G_MISS_DATE) THEN

  for c_WAL_Rec in c_WAL_Est loop

    l_ytd_amount := l_ytd_amount + c_WAL_Rec.ytd_amount;

    if ((c_WAL_Rec.period1_amount is not null) and
	(c_WAL_Rec.period1_amount <> 0)) then
      l_period_amount(1) := c_WAL_Rec.period1_amount;
    end if;

    if ((c_WAL_Rec.period2_amount is not null) and
	(c_WAL_Rec.period2_amount <> 0)) then
      l_period_amount(2) := c_WAL_Rec.period2_amount;
    end if;

    if ((c_WAL_Rec.period3_amount is not null) and
	(c_WAL_Rec.period3_amount <> 0)) then
      l_period_amount(3) := c_WAL_Rec.period3_amount;
    end if;

    if ((c_WAL_Rec.period4_amount is not null) and
	(c_WAL_Rec.period4_amount <> 0)) then
      l_period_amount(4) := c_WAL_Rec.period4_amount;
    end if;

    if ((c_WAL_Rec.period5_amount is not null) and
	(c_WAL_Rec.period5_amount <> 0)) then
      l_period_amount(5) := c_WAL_Rec.period5_amount;
    end if;

    if ((c_WAL_Rec.period6_amount is not null) and
	(c_WAL_Rec.period6_amount <> 0)) then
      l_period_amount(6) := c_WAL_Rec.period6_amount;
    end if;

    if ((c_WAL_Rec.period7_amount is not null) and
	(c_WAL_Rec.period7_amount <> 0)) then
      l_period_amount(7) := c_WAL_Rec.period7_amount;
    end if;

    if ((c_WAL_Rec.period8_amount is not null) and
	(c_WAL_Rec.period8_amount <> 0)) then
      l_period_amount(8) := c_WAL_Rec.period8_amount;
    end if;

    if ((c_WAL_Rec.period9_amount is not null) and
	(c_WAL_Rec.period9_amount <> 0)) then
      l_period_amount(9) := c_WAL_Rec.period9_amount;
    end if;

    if ((c_WAL_Rec.period10_amount is not null) and
	(c_WAL_Rec.period10_amount <> 0)) then
      l_period_amount(10) := c_WAL_Rec.period10_amount;
    end if;

    if ((c_WAL_Rec.period11_amount is not null) and
	(c_WAL_Rec.period11_amount <> 0)) then
      l_period_amount(11) := c_WAL_Rec.period11_amount;
    end if;

    if ((c_WAL_Rec.period12_amount is not null) and
	(c_WAL_Rec.period12_amount <> 0)) then
      l_period_amount(12) := c_WAL_Rec.period12_amount;
    end if;

    if ((c_WAL_Rec.period13_amount is not null) and
	(c_WAL_Rec.period13_amount <> 0)) then
      l_period_amount(13) := c_WAL_Rec.period13_amount;
    end if;

    if ((c_WAL_Rec.period14_amount is not null) and
	(c_WAL_Rec.period14_amount <> 0)) then
      l_period_amount(14) := c_WAL_Rec.period14_amount;
    end if;

    if ((c_WAL_Rec.period15_amount is not null) and
	(c_WAL_Rec.period15_amount <> 0)) then
      l_period_amount(15) := c_WAL_Rec.period15_amount;
    end if;

    if ((c_WAL_Rec.period16_amount is not null) and
	(c_WAL_Rec.period16_amount <> 0)) then
      l_period_amount(16) := c_WAL_Rec.period16_amount;
    end if;

    if ((c_WAL_Rec.period17_amount is not null) and
	(c_WAL_Rec.period17_amount <> 0)) then
      l_period_amount(17) := c_WAL_Rec.period17_amount;
    end if;

    if ((c_WAL_Rec.period18_amount is not null) and
	(c_WAL_Rec.period18_amount <> 0)) then
      l_period_amount(18) := c_WAL_Rec.period18_amount;
    end if;

    if ((c_WAL_Rec.period19_amount is not null) and
	(c_WAL_Rec.period19_amount <> 0)) then
      l_period_amount(19) := c_WAL_Rec.period19_amount;
    end if;

    if ((c_WAL_Rec.period20_amount is not null) and
	(c_WAL_Rec.period20_amount <> 0)) then
      l_period_amount(20) := c_WAL_Rec.period20_amount;
    end if;

    if ((c_WAL_Rec.period21_amount is not null) and
	(c_WAL_Rec.period21_amount <> 0)) then
      l_period_amount(21) := c_WAL_Rec.period21_amount;
    end if;

    if ((c_WAL_Rec.period22_amount is not null) and
	(c_WAL_Rec.period22_amount <> 0)) then
      l_period_amount(22) := c_WAL_Rec.period22_amount;
    end if;

    if ((c_WAL_Rec.period23_amount is not null) and
	(c_WAL_Rec.period23_amount <> 0)) then
      l_period_amount(23) := c_WAL_Rec.period23_amount;
    end if;

    if ((c_WAL_Rec.period24_amount is not null) and
	(c_WAL_Rec.period24_amount <> 0)) then
      l_period_amount(24) := c_WAL_Rec.period24_amount;
    end if;

    if ((c_WAL_Rec.period25_amount is not null) and
	(c_WAL_Rec.period25_amount <> 0)) then
      l_period_amount(25) := c_WAL_Rec.period25_amount;
    end if;

    if ((c_WAL_Rec.period26_amount is not null) and
	(c_WAL_Rec.period26_amount <> 0)) then
      l_period_amount(26) := c_WAL_Rec.period26_amount;
    end if;

    if ((c_WAL_Rec.period27_amount is not null) and
	(c_WAL_Rec.period27_amount <> 0)) then
      l_period_amount(27) := c_WAL_Rec.period27_amount;
    end if;

    if ((c_WAL_Rec.period28_amount is not null) and
	(c_WAL_Rec.period28_amount <> 0)) then
      l_period_amount(28) := c_WAL_Rec.period28_amount;
    end if;

    if ((c_WAL_Rec.period29_amount is not null) and
	(c_WAL_Rec.period29_amount <> 0)) then
      l_period_amount(29) := c_WAL_Rec.period29_amount;
    end if;

    if ((c_WAL_Rec.period30_amount is not null) and
	(c_WAL_Rec.period30_amount <> 0)) then
      l_period_amount(30) := c_WAL_Rec.period30_amount;
    end if;

    if ((c_WAL_Rec.period31_amount is not null) and
	(c_WAL_Rec.period31_amount <> 0)) then
      l_period_amount(31) := c_WAL_Rec.period31_amount;
    end if;

    if ((c_WAL_Rec.period32_amount is not null) and
	(c_WAL_Rec.period32_amount <> 0)) then
      l_period_amount(32) := c_WAL_Rec.period32_amount;
    end if;

    if ((c_WAL_Rec.period33_amount is not null) and
	(c_WAL_Rec.period33_amount <> 0)) then
      l_period_amount(33) := c_WAL_Rec.period33_amount;
    end if;

    if ((c_WAL_Rec.period34_amount is not null) and
	(c_WAL_Rec.period34_amount <> 0)) then
      l_period_amount(34) := c_WAL_Rec.period34_amount;
    end if;

    if ((c_WAL_Rec.period35_amount is not null) and
	(c_WAL_Rec.period35_amount <> 0)) then
      l_period_amount(35) := c_WAL_Rec.period35_amount;
    end if;

    if ((c_WAL_Rec.period36_amount is not null) and
	(c_WAL_Rec.period36_amount <> 0)) then
      l_period_amount(36) := c_WAL_Rec.period36_amount;
    end if;

    if ((c_WAL_Rec.period37_amount is not null) and
	(c_WAL_Rec.period37_amount <> 0)) then
      l_period_amount(37) := c_WAL_Rec.period37_amount;
    end if;

    if ((c_WAL_Rec.period38_amount is not null) and
	(c_WAL_Rec.period38_amount <> 0)) then
      l_period_amount(38) := c_WAL_Rec.period38_amount;
    end if;

    if ((c_WAL_Rec.period39_amount is not null) and
	(c_WAL_Rec.period39_amount <> 0)) then
      l_period_amount(39) := c_WAL_Rec.period39_amount;
    end if;

    if ((c_WAL_Rec.period40_amount is not null) and
	(c_WAL_Rec.period40_amount <> 0)) then
      l_period_amount(40) := c_WAL_Rec.period40_amount;
    end if;

    if ((c_WAL_Rec.period41_amount is not null) and
	(c_WAL_Rec.period41_amount <> 0)) then
      l_period_amount(41) := c_WAL_Rec.period41_amount;
    end if;

    if ((c_WAL_Rec.period42_amount is not null) and
	(c_WAL_Rec.period42_amount <> 0)) then
      l_period_amount(42) := c_WAL_Rec.period42_amount;
    end if;

    if ((c_WAL_Rec.period43_amount is not null) and
	(c_WAL_Rec.period43_amount <> 0)) then
      l_period_amount(43) := c_WAL_Rec.period43_amount;
    end if;

    if ((c_WAL_Rec.period44_amount is not null) and
	(c_WAL_Rec.period44_amount <> 0)) then
      l_period_amount(44) := c_WAL_Rec.period44_amount;
    end if;

    if ((c_WAL_Rec.period45_amount is not null) and
	(c_WAL_Rec.period45_amount <> 0)) then
      l_period_amount(45) := c_WAL_Rec.period45_amount;
    end if;

    if ((c_WAL_Rec.period46_amount is not null) and
	(c_WAL_Rec.period46_amount <> 0)) then
      l_period_amount(46) := c_WAL_Rec.period46_amount;
    end if;

    if ((c_WAL_Rec.period47_amount is not null) and
	(c_WAL_Rec.period47_amount <> 0)) then
      l_period_amount(47) := c_WAL_Rec.period47_amount;
    end if;

    if ((c_WAL_Rec.period48_amount is not null) and
	(c_WAL_Rec.period48_amount <> 0)) then
      l_period_amount(48) := c_WAL_Rec.period48_amount;
    end if;

    if ((c_WAL_Rec.period49_amount is not null) and
	(c_WAL_Rec.period49_amount <> 0)) then
      l_period_amount(49) := c_WAL_Rec.period49_amount;
    end if;

    if ((c_WAL_Rec.period50_amount is not null) and
	(c_WAL_Rec.period50_amount <> 0)) then
      l_period_amount(50) := c_WAL_Rec.period50_amount;
    end if;

    if ((c_WAL_Rec.period51_amount is not null) and
	(c_WAL_Rec.period51_amount <> 0)) then
      l_period_amount(51) := c_WAL_Rec.period51_amount;
    end if;

    if ((c_WAL_Rec.period52_amount is not null) and
	(c_WAL_Rec.period52_amount <> 0)) then
      l_period_amount(52) := c_WAL_Rec.period52_amount;
    end if;

    if ((c_WAL_Rec.period53_amount is not null) and
	(c_WAL_Rec.period53_amount <> 0)) then
      l_period_amount(53) := c_WAL_Rec.period53_amount;
    end if;

    if ((c_WAL_Rec.period54_amount is not null) and
	(c_WAL_Rec.period54_amount <> 0)) then
      l_period_amount(54) := c_WAL_Rec.period54_amount;
    end if;

    if ((c_WAL_Rec.period55_amount is not null) and
	(c_WAL_Rec.period55_amount <> 0)) then
      l_period_amount(55) := c_WAL_Rec.period55_amount;
    end if;

    if ((c_WAL_Rec.period56_amount is not null) and
	(c_WAL_Rec.period56_amount <> 0)) then
      l_period_amount(56) := c_WAL_Rec.period56_amount;
    end if;

    if ((c_WAL_Rec.period57_amount is not null) and
	(c_WAL_Rec.period57_amount <> 0)) then
      l_period_amount(57) := c_WAL_Rec.period57_amount;
    end if;

    if ((c_WAL_Rec.period58_amount is not null) and
	(c_WAL_Rec.period58_amount <> 0)) then
      l_period_amount(58) := c_WAL_Rec.period58_amount;
    end if;

    if ((c_WAL_Rec.period59_amount is not null) and
	(c_WAL_Rec.period59_amount <> 0)) then
      l_period_amount(59) := c_WAL_Rec.period59_amount;
    end if;

    if ((c_WAL_Rec.period60_amount is not null) and
	(c_WAL_Rec.period60_amount <> 0)) then
      l_period_amount(60) := c_WAL_Rec.period60_amount;
    end if;

    exit;

  end loop;
  END IF;

  /*bug:7148726:start*/
  FOR i in 1..l_period_amount.COUNT LOOP
   IF p_rounding_factor is null then
       l_total_est_amount := l_total_est_amount + nvl(l_period_amount(i),0);
   ELSE
       l_total_est_amount := l_total_est_amount + nvl(ROUND(l_period_amount(i)/p_rounding_factor)*p_rounding_factor,0);
   END IF;
  END LOOP;

  l_end_index   := g_est_last_period_index ;

  IF nvl(l_ytd_amount,0) <> nvl(l_total_est_amount,0) THEN
     l_period_amount(l_end_index) := nvl(ROUND(l_period_amount(l_end_index)/p_rounding_factor)*p_rounding_factor,0) +
                                     (nvl(l_ytd_amount,0) - nvl(l_total_est_amount,0));
  END IF;
  /*bug:7148726:end*/

  -- Create Zero Balances Profile Option : this specifies whether non-Position
  -- CCIDs with zero YTD Amounts should be created in PSB_WS_ACCOUNT_LINES

  --commented the following statements for bug 3305778
  /* Bug 3543845: Reactivate the following statements, use g_create_zero_bal
     and add a new condition to improve performance
  */
  IF g_create_zero_bal is null THEN

    FND_PROFILE.GET
      (name => 'PSB_CREATE_ZERO_BALANCE_ACCT',
       val => g_create_zero_bal);

    if g_create_zero_bal is null then
      -- Bug 3543845: Change default behavior to not creating zero balance
      g_create_zero_bal := 'N';
    end if;
  END IF;

  -- Bug 3543845: Check whether the worksheet creation process is executed for
  -- the first time. If it is the first time, then check the ytd_amount and
  -- create zero balance profile. Otherwise, call the create_account_Dist
  -- without any filtering.
  IF ( PSB_WORKSHEET.g_ws_first_time_creation_flag
       and
         (  l_ytd_amount <> 0
            OR
            PSB_WS_ACCT2.g_running_total <> 0  --bug 3704360. added this clause.
            OR
          ( l_ytd_amount = 0 and g_create_zero_bal = 'Y' )
         )
     )
     OR
     NOT PSB_WORKSHEET.g_ws_first_time_creation_flag
  THEN
  /*  comment out by bug 3305778
  if ((l_ytd_amount <> 0) or
     ((l_ytd_amount = 0) and (l_create_zero_bal = 'Y'))) then */

  begin

    --pd('4: Call Create_Account_Dist=> ccid=' || TO_CHAR(p_ccid) ||
    --   ', p_budget_year_id=' || TO_CHAR(p_budget_year_id) ||
    --   ', p_ytd_amount=' || TO_CHAR(l_ytd_amount));

    Create_Account_Dist
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_account_line_id => l_account_line_id,
	p_worksheet_id => p_worksheet_id,
	p_service_package_id => p_service_package_id,
	p_check_spal_exists => FND_API.G_FALSE,
	p_gl_cutoff_period => null,
	p_allocrule_set_id => null,
	p_budget_calendar_id => null,
	p_rounding_factor => p_rounding_factor,
	p_stage_set_id => p_stage_set_id,
	p_budget_year_id => p_budget_year_id,
	p_budget_group_id => p_budget_group_id,
	p_ccid => p_ccid,
	p_currency_code => p_currency_code,
	p_balance_type => 'E',
	p_ytd_amount => l_ytd_amount,
	p_period_amount => l_period_amount,
	p_start_stage_seq => p_start_stage_seq,
	p_current_stage_seq => p_start_stage_seq);

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
     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => 'Copy_CY_Estimates');
     end if;

END Copy_CY_Estimates;

/* ----------------------------------------------------------------------- */

PROCEDURE Update_YTD_Amount
( p_api_version       IN   NUMBER,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_account_line_id   IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)     := 'Update_YTD_Amount';
  l_api_version       CONSTANT NUMBER           := 1.0;

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  update PSB_WS_ACCOUNT_LINES
     set ytd_amount = nvl(period1_amount, 0) + nvl(period2_amount, 0) + nvl(period3_amount, 0) +
		      nvl(period4_amount, 0) + nvl(period5_amount, 0) + nvl(period6_amount, 0) +
		      nvl(period7_amount, 0) + nvl(period8_amount, 0) + nvl(period9_amount, 0) +
		      nvl(period10_amount, 0) + nvl(period11_amount, 0) + nvl(period12_amount, 0) +
		      nvl(period13_amount, 0) + nvl(period14_amount, 0) + nvl(period15_amount, 0) +
		      nvl(period16_amount, 0) + nvl(period17_amount, 0) + nvl(period18_amount, 0) +
		      nvl(period19_amount, 0) + nvl(period20_amount, 0) + nvl(period21_amount, 0) +
		      nvl(period22_amount, 0) + nvl(period23_amount, 0) + nvl(period24_amount, 0) +
		      nvl(period25_amount, 0) + nvl(period26_amount, 0) + nvl(period27_amount, 0) +
		      nvl(period28_amount, 0) + nvl(period29_amount, 0) + nvl(period30_amount, 0) +
		      nvl(period31_amount, 0) + nvl(period32_amount, 0) + nvl(period33_amount, 0) +
		      nvl(period34_amount, 0) + nvl(period35_amount, 0) + nvl(period36_amount, 0) +
		      nvl(period37_amount, 0) + nvl(period38_amount, 0) + nvl(period39_amount, 0) +
		      nvl(period40_amount, 0) + nvl(period41_amount, 0) + nvl(period42_amount, 0) +
		      nvl(period43_amount, 0) + nvl(period44_amount, 0) + nvl(period45_amount, 0) +
		      nvl(period46_amount, 0) + nvl(period47_amount, 0) + nvl(period48_amount, 0) +
		      nvl(period49_amount, 0) + nvl(period50_amount, 0) + nvl(period51_amount, 0) +
		      nvl(period52_amount, 0) + nvl(period53_amount, 0) + nvl(period54_amount, 0) +
		      nvl(period55_amount, 0) + nvl(period56_amount, 0) + nvl(period57_amount, 0) +
		      nvl(period58_amount, 0) + nvl(period59_amount, 0) + nvl(period60_amount, 0)
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

END Update_YTD_Amount;

/* ----------------------------------------------------------------------- */

-- Cache AFF Column Names for the Chart of Accounts

PROCEDURE Flex_Info
( p_return_status  OUT  NOCOPY  VARCHAR2,
  p_flex_code      IN   NUMBER
) IS

  cursor c_seginfo is
    select application_column_name
      from fnd_id_flex_segments
     where application_id = 101
       and id_flex_code = 'GL#'
       and id_flex_num = p_flex_code
       and enabled_flag = 'Y'
     order by segment_num;

BEGIN

  for l_init_index in 1..g_seg_name.Count loop
    g_seg_name(l_init_index) := null;
  end loop;

  g_num_segs := 0;

  g_flex_code := p_flex_code;

  for c_Seginfo_Rec in c_seginfo loop
    g_num_segs := g_num_segs + 1;
    g_seg_name(g_num_segs) := c_Seginfo_Rec.application_column_name;
  end loop;

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
	   p_procedure_name => 'Flex_Info');
     end if;

END Flex_Info;

/* ------------------------------------------------------------------------- */

  -- Execute a Dynamic SQL Statement with no Bind Variables

  -- Returns number of rows processed or -1 if error (add_message)
  -- Return Value is valid only for insert, update and delete statements

FUNCTION dsql_execute
( sql_statement  IN  VARCHAR2
) RETURN NUMBER IS

  cursornum   INTEGER;
  nprocessed  INTEGER;

BEGIN

  cursornum := dbms_sql.open_cursor;
  dbms_sql.parse(cursornum, sql_statement, dbms_sql.v7);
  nprocessed := dbms_sql.execute(cursornum);
  dbms_sql.close_cursor(cursornum);
  return(nprocessed);


EXCEPTION

  when OTHERS then

    if dbms_sql.is_open(cursornum) then
      dbms_sql.close_cursor(cursornum);
    end if;

    -- Dynamic SQL Exception

    message_token('ROUTINE', 'PSB_WS_ACCT1.dsql_execute');
    message_token('ERROR', SQLERRM);
    add_message('PSB', 'PSB_UNHANDLED_EXCEPTION');

    return(-1);

END dsql_execute;

/* ------------------------------------------------------------------------- */

PROCEDURE DSQL_Budget_Balance
( p_return_status      OUT  NOCOPY  VARCHAR2,
  p_sql_statement      OUT  NOCOPY  VARCHAR2,
  p_set_of_books_id    IN   NUMBER,
  p_budgetary_control  IN   VARCHAR2,
  p_budget_version_id  IN   NUMBER,
  p_gl_budget_set_id   IN   NUMBER,
  p_incl_adj_period    IN   VARCHAR2,
  p_map_criteria       IN   VARCHAR2
) IS

  sql_budget_balance   VARCHAR2(1000);

BEGIN

  -- Bug#3317262: Added missing budgetary debit and credit account types.

  -- removed the pipe condition and sum function from the query
  -- for bug 4256345

  /* bug no 4725091 --> Modified the query to include the carry forward balance */

  sql_budget_balance := 'select gs.start_date, gs.end_date, ' ||
             'decode(:ACCOUNT_TYPE, ''A'', 1, ''E'', 1, ''D'', 1, ''L'', -1, ''O'', -1, ''R'', -1, ''C'', -1 ) * ' ||
             '(nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0)), ' ||
             '(nvl(gb.BEGIN_BALANCE_DR, 0) - nvl(gb.BEGIN_BALANCE_CR,0)) '||
	     'from GL_BALANCES gb, ' ||
	     'GL_PERIOD_STATUSES gs ';

  if p_gl_budget_set_id is null then
  begin

    if FND_API.to_Boolean(p_budgetary_control) then
      /* for bug 4866848 --> added the table gl_budorg_bc_options */
      sql_budget_balance := sql_budget_balance ||
			   ', GL_BUDGET_ASSIGNMENTS ga
                            , GL_BUDORG_BC_OPTIONS  gc ';
    end if;

  end;
  end if;

  -- Bug#4310414
  -- gb.set_of_books_id to gb.ledger_id

  -- Bug#5030613
  -- Replaced literal by bind variable.
  sql_budget_balance := sql_budget_balance ||
		       'where gb.ledger_id = :B_SET_OF_BOOKS_ID ' ||
			 'and gb.currency_code = :CURRENCY_CODE ' ||
			 'and gb.code_combination_id = :CCID ' ||
			 'and ((gb.translated_flag is null) or (gb.translated_flag = ''Y'')) ' ||
			 'and gb.actual_flag = ''B'' ';

  -- If a budget set is assigned to the worksheet find the funding budget for the CCID from
  -- the budget set. If a budget set is not assigned to the worksheet :
  -- (i) if budgetary control is enabled, get the balance for the funding budget assigned to the CCID
  -- in the GL Budget Org
  -- (ii) if budgetary control is disabled, get the balance for the funding budget in the worksheet definition

  if p_gl_budget_set_id is null then
  begin

    if FND_API.to_Boolean(p_budgetary_control) then
      /* for bug --> 4866848 Add additional join condition for the range_id */
      sql_budget_balance := sql_budget_balance ||
			   'and ga.code_combination_id = :CCID ' ||
			   'and gb.budget_version_id = gc.funding_budget_version_id
                            and ga.range_id = gc.range_id ';
    end if;

  end;
  else
    sql_budget_balance := sql_budget_balance ||
			 'and gb.budget_version_id = :BUDGET_VERSION_ID ';
  end if;

  -- for bug 4256345
  -- removing the pipe

  -- Bug#5030613
  -- Replaced literal by bind variable.
  sql_budget_balance := sql_budget_balance ||
		       'and gb.period_name = gs.period_name ' ||
		       'and gb.period_type = gs.period_type ' ||
		       'and gb.period_year = gs.period_year ' ||
		       'and gb.period_num = gs.period_num ' ||
		       'and gs.set_of_books_id = :B_SET_OF_BOOKS_ID ' ||
		       'and gs.application_id = 101 ';

  -- Map the GL Period Start Date or End Date to the PSB Budget Period based on the
  -- Profile Option

  if p_map_criteria = 'S' then
    sql_budget_balance := sql_budget_balance ||
			 'and gs.start_date between :START_DATE and :END_DATE ';
  else
    sql_budget_balance := sql_budget_balance ||
			 'and gs.end_date between :START_DATE and :END_DATE ';
  end if;

  -- Include GL Adjustment Periods if specified in the Worksheet definition

  if not FND_API.to_Boolean(p_incl_adj_period) then
    sql_budget_balance := sql_budget_balance ||
			 'and gs.adjustment_period_flag = ''N'' ';
  end if;

  -- for bug 4256345
  -- since sum will not be there, no need for group by
  /*
  sql_budget_balance := sql_budget_balance ||
		       'group by gs.start_date, gs.end_date'; */


  -- Initialize API return status to success

  p_sql_statement := sql_budget_balance;
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
	   p_procedure_name => 'DSQL_Budget_Balance');
     end if;

END DSQL_Budget_Balance;

/* ------------------------------------------------------------------------- */

PROCEDURE DSQL_Actual_Balance
( p_return_status    OUT  NOCOPY  VARCHAR2,
  p_sql_statement    OUT  NOCOPY  VARCHAR2,
  p_set_of_books_id  IN   NUMBER,
  p_incl_adj_period  IN   VARCHAR2,
  p_map_criteria     IN   VARCHAR2
) IS

  sql_actual_balance      VARCHAR2(1000);

BEGIN

  -- Bug#3317262: Added missing budgetary debit and credit account types.

  -- for bug 4256345
  -- removing sum function and pipe function
  -- Bug#4310414
  -- gb.set_of_books_id to gb.ledger_id

  -- Bug#5030613
  -- Replaced literal by bind variable.
  sql_actual_balance := 'select gs.start_date, gs.end_date, ' ||
       'decode(:ACCOUNT_TYPE, ''A'', 1, ''E'', 1, ''D'', 1, ''L'', -1, ''O'', -1, ''R'', -1, ''C'', -1 ) * ' ||
       '(nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0)) ' ||
       'from GL_BALANCES gb, ' ||
       'GL_PERIOD_STATUSES gs ' ||
       'where gb.ledger_id = :B_SET_OF_BOOKS_ID ' ||
       'and gb.currency_code = :CURRENCY_CODE ' ||
       'and gb.code_combination_id = :CCID ' ||
       'and ((gb.translated_flag is null) or (gb.translated_flag = ''Y'')) ' ||
       'and gb.actual_flag = ''A'' ' ||
       'and gb.period_name = gs.period_name ' ||
       'and gb.period_type = gs.period_type ' ||
       'and gb.period_year = gs.period_year ' ||
       'and gb.period_num = gs.period_num ' ||
       'and gs.set_of_books_id = :B_SET_OF_BOOKS_ID ' ||
       'and gs.application_id = 101 ';

  -- Map the GL Period Start Date or End Date to the PSB Budget Period based on the
  -- Profile Option

  if p_map_criteria = 'S' then
    sql_actual_balance := sql_actual_balance ||
			 'and gs.start_date between :START_DATE and :END_DATE ';
  else
    sql_actual_balance := sql_actual_balance ||
			 'and gs.end_date between :START_DATE and :END_DATE ';
  end if;

  -- Include GL Adjustment Periods if specified in the Worksheet definition

  if not FND_API.to_Boolean(p_incl_adj_period) then
    sql_actual_balance := sql_actual_balance ||
			 'and gs.adjustment_period_flag = ''N'' ';
  end if;

  -- for bug 4256345
  -- commenting out the group function as sum is removed
  /*
  sql_actual_balance := sql_actual_balance ||
		       'group by gs.start_date, gs.end_date'; */


  -- Initialize API return status to success

  p_sql_statement := sql_actual_balance;
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
	   p_procedure_name => 'DSQL_Actual_Balance');
     end if;

END DSQL_Actual_Balance;

/* ------------------------------------------------------------------------- */

PROCEDURE DSQL_Encum_Balance
( p_return_status              OUT  NOCOPY  VARCHAR2,
  p_sql_statement              OUT  NOCOPY  VARCHAR2,
  p_set_of_books_id            IN   NUMBER,
  p_incl_adj_period            IN   VARCHAR2,
  p_map_criteria               IN   VARCHAR2,
  p_include_gl_commit_balance  IN   VARCHAR2,
  p_include_gl_oblig_balance   IN   VARCHAR2,
  p_include_gl_other_balance   IN   VARCHAR2
) IS

  l_commit_enc_type_id         NUMBER;
  l_oblig_enc_type_id          NUMBER;

  sql_encum_balance            VARCHAR2(1000);

  -- Bug#5030613 Start
  -- Commenting the cursor. The same check will now be done in
  -- PSB_WS_ACCT2.Map_GL_Balances API.
  /*cursor c_fin is
    select purch_encumbrance_type_id, req_encumbrance_type_id
      from financials_system_parameters; */
  -- Bug#5030613 End

BEGIN
  -- Bug#5030613 Start
  -- Commenting the cursor. The same check will now be done in
  -- PSB_WS_ACCT2.Map_GL_Balances API.
  /*for c_fin_rec in c_fin loop
    l_commit_enc_type_id := c_fin_rec.req_encumbrance_type_id;
    l_oblig_enc_type_id := c_fin_rec.purch_encumbrance_type_id;
  end loop; */
  -- Bug#5030613 End

  -- Bug#3317262: Added missing budgetary debit and credit account types.

  -- for bug 4256345
  -- removing sum and pipe function from the query

  /* bug no 4725091 --> Modified the query to include the carry forward balance */

  -- Bug#5030613
  -- Replaced literals by bind variables.
  sql_encum_balance := 'select gs.start_date, gs.end_date, ' ||
       'decode(:ACCOUNT_TYPE, ''A'', 1, ''E'', 1, ''D'', 1, ''L'', -1, ''O'', -1, ''R'', -1, ''C'', -1 ) * ' ||
       '(nvl(gb.period_net_dr, 0) - nvl(gb.period_net_cr, 0)), ' ||
       '(nvl(gb.BEGIN_BALANCE_DR, 0) - nvl(gb.BEGIN_BALANCE_CR, 0)) '||
       'from GL_BALANCES gb, ' ||
       'GL_PERIOD_STATUSES gs ' ||
       'where gb.ledger_id = :B_SET_OF_BOOKS_ID ' ||
       'and gb.currency_code = :CURRENCY_CODE ' ||
       'and gb.code_combination_id = :CCID ' ||
       'and ((gb.translated_flag is null) or (gb.translated_flag = ''Y'')) ' ||
       'and gb.actual_flag = ''E'' ' ||
       'and gb.period_name = gs.period_name ' ||
       'and gb.period_type = gs.period_type ' ||
       'and gb.period_year = gs.period_year ' ||
       'and gb.period_num = gs.period_num ' ||
       'and gs.set_of_books_id = :B_SET_OF_BOOKS_ID ' ||
       'and gs.application_id = 101 ';

  -- Bug#5030613 Start
  -- Commenting the cursor. The same check will now be done in
  -- PSB_WS_ACCT2.Map_GL_Balances API.

  -- Extract encumbrance balances, Include Other Encum Balances.
  /* if FND_API.to_Boolean(p_include_gl_other_balance) then
  begin

    if not FND_API.to_Boolean(p_include_gl_commit_balance) then
    begin

      if not FND_API.to_Boolean(p_include_gl_oblig_balance) then
	sql_encum_balance := sql_encum_balance ||
			    'and gb.encumbrance_type_id not in (' || l_oblig_enc_type_id || ',' ||
								     l_commit_enc_type_id || ') ';
      else
	sql_encum_balance := sql_encum_balance ||
			    'and gb.encumbrance_type_id not in (' || l_commit_enc_type_id || ') ';
      end if;

    end;
    else
    begin

      if not FND_API.to_Boolean(p_include_gl_oblig_balance) then
	sql_encum_balance := sql_encum_balance ||
			    'and gb.encumbrance_type_id not in (' || l_oblig_enc_type_id || ') ';
      end if;

    end;
    end if;

  end;
  else
  begin

    if not FND_API.to_Boolean(p_include_gl_commit_balance) then
    begin

      if FND_API.to_Boolean(p_include_gl_oblig_balance) then
	sql_encum_balance := sql_encum_balance ||
			    'and gb.encumbrance_type_id in (' || l_oblig_enc_type_id || ') ';
      end if;

    end;
    else
    begin

      if not FND_API.to_Boolean(p_include_gl_oblig_balance) then
	sql_encum_balance := sql_encum_balance ||
			    'and gb.encumbrance_type_id in (' || l_commit_enc_type_id || ') ';
      else
	sql_encum_balance := sql_encum_balance ||
			    'and gb.encumbrance_type_id in (' || l_commit_enc_type_id || ',' || l_oblig_enc_type_id || ') ';
      end if;

    end;
    end if;

  end;
  end if;*/
  -- Bug#5030613 End

  -- Map the GL Period Start Date or End Date to the PSB Budget Period based on the
  -- Profile Option

  if p_map_criteria = 'S' then
    sql_encum_balance := sql_encum_balance ||
			'and gs.start_date between :START_DATE and :END_DATE ';
  else
    sql_encum_balance := sql_encum_balance ||
			'and gs.end_date between :START_DATE and :END_DATE ';
  end if;

  -- Include GL Adjustment Periods if specified in the Worksheet definition

  if not FND_API.to_Boolean(p_incl_adj_period) then
    sql_encum_balance := sql_encum_balance ||
			'and gs.adjustment_period_flag = ''N'' ';
  end if;

  -- for bug 4256345
  -- commenting out the group by function as sum is commented out
  /*
  sql_encum_balance := sql_encum_balance ||
		      'group by gs.start_date, gs.end_date'; */


  -- Initialize API return status to success

  p_sql_statement := sql_encum_balance;
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
	   p_procedure_name => 'DSQL_Encum_Balance');
     end if;

END DSQL_Encum_Balance;

/* ----------------------------------------------------------------------- */

-- Compute Line Total for Constraint

FUNCTION Compute_Line_Total
( p_worksheet_id         IN  NUMBER,
  p_sp_exists            IN  BOOLEAN,
  p_flex_mapping_set_id  IN  NUMBER,
  p_budget_calendar_id   IN  NUMBER,
  p_ccid                 IN  NUMBER,
  p_budget_year_type_id  IN  NUMBER,
  p_balance_type         IN  VARCHAR2,
  p_currency_code        IN  VARCHAR2,
  /* start bug 4256345 */
  p_budget_period_id      IN   NUMBER,
  p_stage_set_id          IN   NUMBER,
  p_current_stage_seq     IN   NUMBER
  /* start bug 4256345 */
) RETURN NUMBER IS

  l_mapped_ccid          NUMBER;
  l_ytd_amount           NUMBER := 0;

  -- Compute sum of WS Account Lines for a Constraint Formula of type 1 or type 2.
  -- This is applicable for all Service Packages

/* For Bug No. 2214715 : Start  */
/*  Existing Cursor definition is commented and modified one is added as follows :
  cursor c_Type12 is
    select nvl(a.ytd_amount, 0) YTD_Amount
      from PSB_WS_ACCOUNT_LINES a,
	   PSB_WORKSHEETS b,
	   PSB_BUDGET_PERIODS c
     where a.code_combination_id = l_mapped_ccid
       and a.balance_type = p_balance_type
       and a.currency_code = p_currency_code
       and exists
	  (select 1
	     from PSB_WORKSHEETS b,
		  PSB_BUDGET_PERIODS c
	    where b.worksheet_id = p_worksheet_id
	      and a.stage_set_id = b.stage_set_id
	      and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
	      and c.budget_calendar_id = p_budget_calendar_id
	      and a.budget_year_id = c.budget_period_id
	      and c.budget_period_type = 'Y'
	      and c.budget_year_type_id = p_budget_year_type_id)
       and exists
	  (select 1
	     from PSB_WS_LINES
	    where account_line_id = a.account_line_id
	      and worksheet_id = p_worksheet_id);
*/

  -- for bug 4256345
  -- commenting the cursor
/*
  cursor c_Type12 is
  select sum(nvl(a.ytd_amount, 0)) YTD_Amount
      from PSB_WORKSHEETS b,
	   PSB_WS_LINES d,
	   PSB_WS_ACCOUNT_LINES a,
	   PSB_BUDGET_PERIODS c
     where b.worksheet_id = p_worksheet_id
       and d.worksheet_id = b.worksheet_id
       and d.account_line_id = a.account_line_id
       and a.code_combination_id = l_mapped_ccid
       and a.balance_type = p_balance_type
       and a.currency_code = p_currency_code
       and a.stage_set_id = b.stage_set_id
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and c.budget_calendar_id = p_budget_calendar_id
       and a.budget_year_id = c.budget_period_id
       and c.budget_period_type = 'Y'
       and c.budget_year_type_id = p_budget_year_type_id; */

/* For Bug No. 2214715 : End  */

  -- Compute sum of WS Account Lines for a Constraint Formula of type 1 or type 2.
  -- This is applicable for all Service Packages that have been selected for
  -- submission in Worksheet Operations

/* For Bug No. 2214715 : Start  */
/*  Existing Cursor definition is commented and modified one is added as follows :
  cursor c_Type12SP is
    select nvl(a.ytd_amount, 0) YTD_Amount
      from PSB_WS_ACCOUNT_LINES a,
	   PSB_WORKSHEETS b,
	   PSB_BUDGET_PERIODS c
     where a.code_combination_id = l_mapped_ccid
       and a.balance_type = p_balance_type
       and a.currency_code = p_currency_code
       and exists
	  (select 1
	     from PSB_WORKSHEETS b,
		  PSB_BUDGET_PERIODS c
	    where b.worksheet_id = p_worksheet_id
	      and a.stage_set_id = b.stage_set_id
	      and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
	      and c.budget_calendar_id = p_budget_calendar_id
	      and a.budget_year_id = c.budget_period_id
	      and c.budget_period_type = 'Y'
	      and c.budget_year_type_id = p_budget_year_type_id)
       and exists
	  (select 1
	     from PSB_WS_LINES
	    where account_line_id = a.account_line_id
	      and worksheet_id = p_worksheet_id)
       and exists
	  (select 1
	     from PSB_WS_SUBMIT_SERVICE_PACKAGES d
	    where d.service_package_id = a.service_package_id
	      and d.worksheet_id = p_worksheet_id);
*/


  -- for bug 4256345
  -- commenting the cursor

  /*
  cursor c_Type12SP is
  select sum(nvl(a.ytd_amount, 0)) YTD_Amount
      from PSB_WORKSHEETS b,
	   PSB_WS_LINES d,
	   PSB_WS_ACCOUNT_LINES a,
	   PSB_BUDGET_PERIODS c
     where b.worksheet_id = p_worksheet_id
       and d.worksheet_id = b.worksheet_id
       and d.account_line_id = a.account_line_id
       and a.code_combination_id = l_mapped_ccid
       and a.balance_type = p_balance_type
       and a.currency_code = p_currency_code
       and a.stage_set_id = b.stage_set_id
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and c.budget_calendar_id = p_budget_calendar_id
       and a.budget_year_id = c.budget_period_id
       and c.budget_period_type = 'Y'
       and c.budget_year_type_id = p_budget_year_type_id
       and exists
	  (select 1
	     from PSB_WS_SUBMIT_SERVICE_PACKAGES e
	    where e.service_package_id = a.service_package_id
	      and e.worksheet_id = p_worksheet_id); */

/* For Bug No. 2214715 : End  */

BEGIN

  l_mapped_ccid := Map_Account
		      (p_flex_mapping_set_id => p_flex_mapping_set_id,
		       p_ccid => p_ccid,
		       p_budget_year_type_id => p_budget_year_type_id);


  if p_sp_exists then
  begin

   -- commenting the cursor for Bug No : 4256345
   /*
    for c_Type12_Rec in c_Type12SP loop
      l_ytd_amount := c_Type12_Rec.YTD_Amount;
    end loop;
   */

   FOR l_ytd_rec IN (SELECT NVL(A.YTD_AMOUNT, 0) YTD_AMOUNT
    			 FROM PSB_WS_LINES WSL,
                          PSB_WS_ACCOUNT_LINES A
                     WHERE A.CODE_COMBINATION_ID = l_mapped_ccid
                     AND   A.BUDGET_YEAR_ID = p_budget_period_id
                     AND   A.BALANCE_TYPE = p_balance_type
                     AND   A.CURRENCY_CODE = p_currency_code
                     AND   A.STAGE_SET_ID = p_stage_set_id
                     AND   p_current_stage_seq
                     BETWEEN A.START_STAGE_SEQ AND A.CURRENT_STAGE_SEQ
                     AND   WSL.WORKSHEET_ID = p_worksheet_id
                     AND   WSL.ACCOUNT_LINE_ID = A.ACCOUNT_LINE_ID
                     AND   EXISTS( SELECT 1
            					   FROM	PSB_WS_SUBMIT_SERVICE_PACKAGES S
            					   WHERE S.SERVICE_PACKAGE_ID = A.SERVICE_PACKAGE_ID
            					   AND	S.WORKSHEET_ID = p_worksheet_id))
			 LOOP
			   l_ytd_amount := l_ytd_amount + l_ytd_rec.ytd_amount;
			 END LOOP;

  end;
  else
  begin

    -- commenting the cursor for Bug No : 4256345
    /*
    for c_Type12_Rec in c_Type12 loop
      l_ytd_amount := c_Type12_Rec.YTD_Amount;
    end loop;
    */

    FOR l_ytd_rec IN (SELECT NVL(A.YTD_AMOUNT, 0) YTD_AMOUNT
    			  FROM PSB_WS_LINES WSL,
                           PSB_WS_ACCOUNT_LINES A
    			  WHERE A.CODE_COMBINATION_ID = l_mapped_ccid
    			  AND   A.BUDGET_YEAR_ID = p_budget_period_id
    			  AND   A.BALANCE_TYPE = p_balance_type
    			  AND   A.CURRENCY_CODE = p_currency_code
    			  AND   A.STAGE_SET_ID = p_stage_set_id
    			  AND   p_current_stage_seq
    			  BETWEEN A.START_STAGE_SEQ AND A.CURRENT_STAGE_SEQ
    			  AND   WSL.WORKSHEET_ID = p_worksheet_id
    			  AND   WSL.ACCOUNT_LINE_ID = A.ACCOUNT_LINE_ID)
     LOOP
       l_ytd_amount := l_ytd_amount + l_ytd_rec.ytd_amount;
     END LOOP;

  end;
  end if;

  RETURN l_ytd_amount;

END Compute_Line_Total;

/* ----------------------------------------------------------------------- */

-- Compute Sum Total for Account

FUNCTION Compute_Account_Total
( p_worksheet_id         IN  NUMBER,
  p_sp_exists            IN  BOOLEAN,
  p_flex_mapping_set_id  IN  NUMBER,
  p_ccid                 IN  NUMBER,
  p_budget_year_id       IN  NUMBER,
  p_budget_year_type_id  IN  NUMBER,
  p_currency_code        IN  VARCHAR2
) RETURN NUMBER IS

  l_mapped_ccid          NUMBER;
  l_ytd_amount           NUMBER := 0;

  -- Compute Sum of WS Account Lines for individual CCIDs.
  -- This is applicable when the Detailed Flag is Set and is for all Service Packages

  cursor c_Sum is
    select sum(nvl(a.ytd_amount,0)) Sum_Acc
      from PSB_WS_ACCOUNT_LINES a,
	   PSB_WORKSHEETS b
     where exists
	  (select 1
	     from PSB_WS_LINES
	    where account_line_id = a.account_line_id
	      and worksheet_id = p_worksheet_id)
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.balance_type = 'E'
       and a.stage_set_id = b.stage_set_id
       and a.currency_code = p_currency_code
       and a.budget_year_id = p_budget_year_id
       and a.code_combination_id = l_mapped_ccid
       and b.worksheet_id = p_worksheet_id;

  -- Compute Sum of WS Account Lines for individual CCIDs.
  -- This is applicable when the Detailed Flag is Set and is for all Service Packages
  -- that have been selected for submission in Worksheet Operations

  cursor c_SumSP is
    select sum(nvl(a.ytd_amount,0)) Sum_Acc
      from PSB_WS_ACCOUNT_LINES a,
	   PSB_WORKSHEETS b
     where exists
	  (select 1
	     from PSB_WS_SUBMIT_SERVICE_PACKAGES c
	    where c.service_package_id = a.service_package_id
	      and c.worksheet_id = p_worksheet_id)
       and exists
	  (select 1
	     from PSB_WS_LINES
	    where account_line_id = a.account_line_id
	      and worksheet_id = p_worksheet_id)
       and b.current_stage_seq between a.start_stage_seq and a.current_stage_seq
       and a.balance_type = 'E'
       and a.stage_set_id = b.stage_set_id
       and a.currency_code = p_currency_code
       and a.budget_year_id = p_budget_year_id
       and a.code_combination_id = l_mapped_ccid
       and b.worksheet_id = p_worksheet_id;

BEGIN

  l_mapped_ccid := Map_Account
		      (p_flex_mapping_set_id => p_flex_mapping_set_id,
		       p_ccid => p_ccid,
		       p_budget_year_type_id => p_budget_year_type_id);

  if p_sp_exists then
  begin

    for c_Sum_Rec in c_SumSP loop
      l_ytd_amount := c_Sum_Rec.Sum_Acc;
    end loop;

  end;
  else
  begin

    for c_Sum_Rec in c_Sum loop
      l_ytd_amount := c_Sum_Rec.Sum_Acc;
    end loop;

  end;
  end if;

  -- For Bug No. 2854288 added the following if condition
  if l_ytd_amount is NULL then
    RETURN 0;
  else
    RETURN l_ytd_amount;
  end if;

END Compute_Account_Total;

/* ----------------------------------------------------------------------- */

-- Added the following function for Bug No. 3206445

-- Determine whether a Summary Constraint Set contains positive only , negative
-- only or mixture of positive and negative account types. The function returns
-- the correction factor required, if any, for the Summary Total i.e. the
-- function returns:

-- (i) 1 if there is no correction required in the Summary Total for a
-- Constraint Account Set. This happens when positive only or mixture of
-- positive and negative account types are chosen.

-- (ii) -1 if there is correction required in the Summary Total for a
-- Constraint Account Set. This happens when negative only account types
-- are chosen.

FUNCTION Compute_Correction_Factor
(   p_constraint_id  IN NUMBER,
    p_worksheet_id   IN NUMBER
) RETURN NUMBER IS

 -- Find distinct account types of the accounts assigned to the account sets
 -- included in the constraint.

  cursor c_Account_types is
    select distinct f.account_type
      from psb_budget_accounts d,
	   psb_set_relations_v e,
           psb_ws_account_lines f,
           psb_ws_lines g
     where d.account_position_set_id = e.account_position_set_id
       and e.account_or_position_type = 'A'
       and e.constraint_id = p_constraint_id
       and d.code_combination_id = f.code_combination_id
       and f.account_line_id = g.account_line_id
       and g.worksheet_id = p_worksheet_id;

BEGIN

    FOR C_Account_types_rec in C_account_types LOOP
       IF C_Account_types_rec.account_type in ('C','L','O','R') THEN
       -- If there is one positive account type, then no correction required.
          RETURN 1;
       END IF;
    END LOOP;

   -- No positive account types in the account set. Hence make the summary total
   -- positive.
   RETURN -1;

END Compute_Correction_Factor;

/* ----------------------------------------------------------------------- */

-- Added the following function for Bug No. 3206445

-- Determine whether a Account Type is positive or negative. The
-- function returns:

-- (i) 1 if the account type is positive. This happens when the account
-- type is one of Budgetary CR (C),Liabilities (L),Owners Equity (O) or
-- Revenues (R).

-- (ii) -1 if the account type is negative. This happens when the account
-- type is one of Assets (A),Budgetary Debit (D) or Expenses (E).


FUNCTION Compute_Account_Type_Factor
( p_ccid   IN NUMBER,
  p_worksheet_id IN NUMBER
) RETURN NUMBER IS

  cursor c_Account_types is
    select distinct account_type
      from gl_code_combinations
       where code_combination_id = p_ccid;

BEGIN

    FOR C_Account_types_rec in C_account_types LOOP
       IF C_Account_types_rec.account_type in ('L','C','R','O') THEN
       -- positive account type
          RETURN 1;
       ELSE
       -- negative account type
          RETURN -1;
       END IF;
    END LOOP;
    -- If account line not in GLC,return 1
    RETURN 1;

END Compute_Account_Type_Factor;



/* ------------------------------------------------------------------------ */
-- Compute Total for Summary Constraint Account Sets

FUNCTION Compute_Sum_Total
( p_worksheet_id         IN  NUMBER,
  p_sp_exists            IN  BOOLEAN,
  p_constraint_id        IN  NUMBER,
  p_flex_mapping_set_id  IN  NUMBER,
  p_budget_year_id       IN  NUMBER,
  p_budget_year_type_id  IN  NUMBER,
  p_currency_code        IN  VARCHAR2,
  p_budget_group_id 	 IN  NUMBER
) RETURN NUMBER IS

  /* Bug 3608191 Start */
  l_budget_group_id NUMBER;

  CURSOR l_Budget_Group_csr (c_budgetgroup_id NUMBER)
  IS
  SELECT budget_group_id
  FROM   psb_budget_groups
  WHERE  budget_group_type    = 'R'
  START  WITH budget_group_id      = c_budgetgroup_id
  CONNECT BY prior budget_group_id = parent_budget_group_id;

  -- Find individual accounts assigned to the Constraint
  CURSOR l_Accounts_csr
  IS
  SELECT d.code_combination_id, e.account_position_set_id
  FROM    psb_budget_accounts d,
          psb_set_relations e
  WHERE d.account_position_set_id = e.account_position_set_id
  AND e.constraint_id = p_constraint_id
  AND EXISTS
  (SELECT 1
  FROM    psb_budget_accounts a,
          psb_set_relations b
  WHERE a.account_position_set_id = b.account_position_set_id
  AND b.budget_group_id = l_budget_group_id
  AND a.code_combination_id = d.code_combination_id);

  CURSOR l_Accounts_global_csr
  IS
  SELECT d.code_combination_id, e.account_position_set_id
  FROM    psb_budget_accounts d,
          psb_set_relations e
  WHERE d.account_position_set_id = e.account_position_set_id
  --AND e.account_or_position_type = 'A'
  AND e.constraint_id = p_constraint_id;
  /* Bug 3608191 End */

  l_ytd_amount           NUMBER;
  l_sum_amount           NUMBER := 0;
  l_correction_factor    NUMBER;
  l_account_type_factor  NUMBER;

  /* Bug 3608191 Start */
  l_processed_flag 		 VARCHAR2(1) := 'N';
  l_global_ws_flag		 VARCHAR2(1) := 'N';
  /* Bug 3608191 End */


BEGIN

  /* Bug 3608191 : Start */
  BEGIN
    SELECT global_worksheet_flag
      INTO l_global_ws_flag
      FROM psb_worksheets
     WHERE worksheet_id = p_worksheet_id;
  END;

  l_processed_flag := 'N';

IF l_global_ws_flag = 'Y' THEN

  FOR l_Accounts_global_csr_Rec in l_Accounts_global_csr loop

    l_processed_flag := 'Y';

    l_ytd_amount := Compute_Account_Total (p_worksheet_id => p_worksheet_id,
					   p_sp_exists => p_sp_exists,
					   p_flex_mapping_set_id => p_flex_mapping_set_id,
					   p_ccid => l_Accounts_global_csr_rec.code_combination_id,
					   p_budget_year_id => p_budget_year_id,
					   p_budget_year_type_id => p_budget_year_type_id,
					   p_currency_code => p_currency_code);

    -- For Bug No. 2854288 added the following IF condition
    if l_ytd_amount is not NULL then
      -- Added l_account_type_factor for Bug No. 3206445
      l_account_type_factor := Compute_Account_Type_Factor(
                                   p_ccid => l_Accounts_global_csr_rec.code_combination_id,
                                   p_worksheet_id => p_worksheet_id);
      l_sum_amount := l_sum_amount + l_account_type_factor * l_ytd_amount;
    end if;

  END LOOP;

ELSE


  l_processed_flag := 'N';

  FOR l_Budget_Group_csr_Rec IN l_Budget_Group_csr (p_budget_group_id) LOOP
    -- Find Account Sets for the Budget Group
    l_budget_group_id  := l_Budget_Group_csr_Rec.budget_group_id;

    FOR l_Accounts_csr_Rec in l_Accounts_csr
    LOOP

      l_processed_flag := 'Y';

      l_ytd_amount := Compute_Account_Total (p_worksheet_id => p_worksheet_id,
					   p_sp_exists => p_sp_exists,
					   p_flex_mapping_set_id => p_flex_mapping_set_id,
					   p_ccid => l_Accounts_csr_Rec.code_combination_id,
					   p_budget_year_id => p_budget_year_id,
					   p_budget_year_type_id => p_budget_year_type_id,
					   p_currency_code => p_currency_code);

      -- For Bug No. 2854288 added the following IF condition
      if l_ytd_amount is not NULL then
        -- Added l_account_type_factor for Bug No. 3206445
        l_account_type_factor := Compute_Account_Type_Factor(
                                   p_ccid => l_Accounts_csr_Rec.code_combination_id,
                                   p_worksheet_id => p_worksheet_id);
        l_sum_amount := l_sum_amount + l_account_type_factor * l_ytd_amount;
      end if;

    END LOOP;

  END LOOP;

END IF;
/* Bug 3608191 : End */


  -- For Bug No. 3206445 Start
  l_correction_factor := Compute_Correction_Factor(
                                      p_worksheet_id => p_worksheet_id,
                                      p_constraint_id => p_constraint_id);

  /* Bug 3608191 : Added IF statement */
  IF l_processed_flag = 'Y' THEN
    RETURN l_correction_factor * l_sum_amount;
  ELSE
    RETURN NULL;
  END IF;

END Compute_Sum_Total;

/* ----------------------------------------------------------------------- */

-- Process Detailed Constraint for an individual CCID or Summary Constraint
-- for all CCIDs

PROCEDURE Process_Constraint
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_worksheet_id                  IN   NUMBER,
  p_sp_exists                     IN   BOOLEAN,
  p_constraint_set_name           IN   VARCHAR2,
  p_constraint_threshold          IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_flex_code                     IN   NUMBER,
  p_flex_delimiter                IN   VARCHAR2,
  p_ccid                          IN   NUMBER := 0,
  p_budget_calendar_id            IN   NUMBER,
  p_budget_year_id                IN   NUMBER,
  p_budget_year_name              IN   VARCHAR2,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER,
  p_summ_flag                     IN   BOOLEAN,
  p_flex_mapping_set_id           IN   NUMBER,
  p_budget_year_type_id           IN   NUMBER,
  p_budget_group_id		  		  IN   NUMBER,
  /* start bug 4256345 */
  p_budget_period_id      		  IN   NUMBER,
  p_stage_set_id          		  IN   NUMBER,
  p_current_stage_seq     		  IN   NUMBER
  /* end bug 4256345 */

) IS

  cursor c_Formula is
    select step_number,
	   prefix_operator,
	   budget_year_type_id,
	   balance_type,
	   currency_code,
	   nvl(amount, 0) amount,
	   postfix_operator,
	   segment1, segment2, segment3,
	   segment4, segment5, segment6,
	   segment7, segment8, segment9,
	   segment10, segment11, segment12,
	   segment13, segment14, segment15,
	   segment16, segment17, segment18,
	   segment19, segment20, segment21,
	   segment22, segment23, segment24,
	   segment25, segment26, segment27,
	   segment28, segment29, segment30
      from PSB_CONSTRAINT_FORMULAS
     where constraint_id = p_constraint_id
     order by step_number;

  /* Bug 2321186 Start */
  CURSOR c_Accounts IS
    SELECT d.code_combination_id
      FROM psb_budget_accounts d,
	   psb_set_relations e
     WHERE d.account_position_set_id  = e.account_position_set_id
       AND e.constraint_id            = p_constraint_id;

  l_sum_amount          NUMBER := 0;
  l_account_type_factor NUMBER;
  l_correction_factor   NUMBER;
  /* Bug 2321186 End */

  l_first_line       BOOLEAN := TRUE;

/* Bug No 2719865 Start */
  l_ccid_defined     BOOLEAN := TRUE;
/* Bug No 2719865 End */

  l_cons_failed      BOOLEAN := FALSE;
  l_type1            BOOLEAN;
  l_type2            BOOLEAN;
  l_type3            BOOLEAN;
  l_type4            BOOLEAN;
  l_type5            BOOLEAN;

  l_ytd_amount       NUMBER;
  l_line_total       NUMBER := 0;
  l_accset_total     NUMBER := 0;
  l_cons_total       NUMBER := 0;

  /*Start bug:5710663*/
  l_stage_set_id      NUMBER;
  l_current_stage_seq NUMBER;
  l_budget_period_id  NUMBER;
  /*End bug:5710663*/

  l_operator         VARCHAR2(2);

  l_reqid            NUMBER;
  l_userid           NUMBER;
  l_description      VARCHAR2(2000) := null;

  l_init_index       PLS_INTEGER;
  l_index            PLS_INTEGER;

  l_ccid             NUMBER;
  l_seg_val          FND_FLEX_EXT.SegmentArray;
  l_ccid_val         FND_FLEX_EXT.SegmentArray;

  l_concat_segments  VARCHAR2(2000) := null;

  l_mapped_ccid      NUMBER;

  l_return_status    VARCHAR2(1);
  l_msg_data         VARCHAR2(2000);
  l_msg_count        NUMBER;

  l_api_name          CONSTANT VARCHAR2(30)   := 'Process_Constraint';

BEGIN

  -- Cache number of Segments and the Application Column Names for the
  -- Segments

  if p_flex_code <> nvl(g_flex_code, 0) then
  begin

    Flex_Info
       (p_flex_code => p_flex_code,
	p_return_status => l_return_status);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  -- Get the individual Segment values for the CCID

  if p_ccid <> 0 then
  begin

    if not FND_FLEX_EXT.Get_Segments
      (application_short_name => 'SQLGL',
       key_flex_code => 'GL#',
       structure_number => p_flex_code,
       combination_id => p_ccid,
       n_segments => g_num_segs,
       segments => l_ccid_val) then

      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

   /* start bug: 5710663*/
  /*For populating l_stage_set_id and l_current_stage_seq variables as in some scenarios
    p_stage_set_id and p_current_stage_seq are passed as Null */
   FOR l_worksheet_rec IN (select current_stage_seq,stage_set_id
                             from psb_worksheets
                            where worksheet_id = p_worksheet_id) LOOP
      l_stage_set_id      := l_worksheet_rec.stage_set_id;
      l_current_stage_seq := l_worksheet_rec.current_stage_seq;
   END LOOP;
  /* End: 5710663*/

  -- Parse the Constraint Formula

  for c_Formula_Rec in c_Formula loop

    -- Each Formula Line is of the following types :
    --
    -- Type1: Depends on Account Set Assignments
    --       (Step, Prefix Operator, Postfix Operator, Period, Balance Type, Currency, Amount have values; Account is blank; this is valid only if 'Detailed' flag is set for the Constraint)
    --
    -- Type2: Depends on Account defined in Formula Line
    --       (Step, Prefix Operator, Period, Balance Type, Account, Currency have values; Amount and Postfix Operator are optional; all the Segment Values should be entered if 'Detailed' flag is not set for the Constraint)
    --
    -- Type3: Flat Amount assignment
    --       (Step, Prefix Operator, Amount have values; Period, Balance Type, Account, Currency, Postfix Operator are blank)
    --
    -- Type4: Depends on Account Set Assignments (Only for budget revisions)
    --       (Step, Prefix Operator, Postfix Operator, Balance Type, Currency, Amount have values; Account, Period are blank; this is valid only if 'Detailed' flag is set for the Constraint)
    --
    -- Type5: Depends on Account Set Assignments
    --       (Step, Prefix Operator, Postfix Operator, Period, Balance Type, Currency, Amount have values; Account is blank;
    --        Detailed flag is unchecked for the constarint.
    --
    l_type1 := FALSE;
    l_type2 := FALSE;
    l_type3 := FALSE;
    l_type4 := FALSE;
    l_type5 := FALSE;

    for l_init_index in 1..g_num_segs loop
      l_seg_val(l_init_index) := null;
    end loop;

 /* Start bug: 5710663 */
  /*For fetching budget period id that formula refers to */
    l_budget_period_id := null;
   FOR l_period_rec in  (select a.budget_period_id
                           from PSB_BUDGET_PERIODS a
                          where a.budget_year_type_id = c_Formula_Rec.budget_year_type_id
                            and a.budget_period_type = 'Y'
                            and a.budget_calendar_id = p_budget_calendar_id) LOOP
       l_budget_period_id := l_period_rec.budget_period_id;
   END LOOP;
  /* End: 5710663*/

    if l_first_line then

      l_first_line := FALSE;

      -- Prefix Operator for the 1st line of a Constraint Formula should be either of :
      -- '<=', '>=', '<', '>', '=', '<>'

      if c_Formula_Rec.prefix_operator not in ('<=', '>=', '<', '>', '=', '<>') then
	message_token('CONSTRAINT', p_constraint_name);
	message_token('STEPID', c_Formula_Rec.step_number);
	message_token('OPERATOR', '[<=, >=, <, >, =, <>]');
	add_message('PSB', 'PSB_INVALID_CONS_OPR');
	raise FND_API.G_EXC_ERROR;
      else
	l_operator := c_Formula_Rec.prefix_operator;
      end if;
    else

      -- Prefix Operator for the other lines of a Constraint Formula should be either of :
      -- '+', '-', '*', '/'

      if c_Formula_Rec.prefix_operator not in ('+', '-', '*', '/') then
	message_token('CONSTRAINT', p_constraint_name);
	message_token('STEPID', c_Formula_Rec.step_number);
	message_token('OPERATOR', '[+, -, *, /]');
	add_message('PSB', 'PSB_INVALID_CONS_OPR');
	raise FND_API.G_EXC_ERROR;
      end if;
    end if;


    -- Check Formula Type

    if ((c_Formula_Rec.prefix_operator is not null) and
	(c_Formula_Rec.postfix_operator is not null) and
	(c_Formula_Rec.budget_year_type_id is not null) and
	(c_Formula_Rec.balance_type is not null) and
	(c_Formula_Rec.currency_code is not null) and
	(c_Formula_Rec.amount is not null) and
       ((c_Formula_Rec.segment1 is null) and (c_Formula_Rec.segment2 is null) and (c_Formula_Rec.segment3 is null) and
	(c_Formula_Rec.segment4 is null) and (c_Formula_Rec.segment5 is null) and (c_Formula_Rec.segment6 is null) and
	(c_Formula_Rec.segment7 is null) and (c_Formula_Rec.segment8 is null) and (c_Formula_Rec.segment9 is null) and
	(c_Formula_Rec.segment10 is null) and (c_Formula_Rec.segment11 is null) and (c_Formula_Rec.segment12 is null) and
	(c_Formula_Rec.segment13 is null) and (c_Formula_Rec.segment14 is null) and (c_Formula_Rec.segment15 is null) and
	(c_Formula_Rec.segment16 is null) and (c_Formula_Rec.segment17 is null) and (c_Formula_Rec.segment18 is null) and
	(c_Formula_Rec.segment19 is null) and (c_Formula_Rec.segment20 is null) and (c_Formula_Rec.segment21 is null) and
	(c_Formula_Rec.segment22 is null) and (c_Formula_Rec.segment23 is null) and (c_Formula_Rec.segment24 is null) and
	(c_Formula_Rec.segment25 is null) and (c_Formula_Rec.segment26 is null) and (c_Formula_Rec.segment27 is null) and
	(c_Formula_Rec.segment28 is null) and (c_Formula_Rec.segment29 is null) and (c_Formula_Rec.segment30 is null))) then
    begin

      if p_summ_flag then

     -- commented out the following statements as part of bug fix 2321186
     /* begin
	  message_token('CONSTRAINT', p_constraint_name);
	  add_message('PSB', 'PSB_INVALID_CONS_FORMULA');
	  raise FND_API.G_EXC_ERROR;
        end; */

        /* Bug 2321186 Start */
        l_type5 := TRUE;
        /* Bug 2321186 End */

      else
	l_type1 := TRUE;
      end if;

    end;
    elsif ((c_Formula_Rec.prefix_operator is not null) and
	   (c_Formula_Rec.budget_year_type_id is not null) and
	   (c_Formula_Rec.balance_type is not null) and
	   (c_Formula_Rec.currency_code is not null) and
	  ((c_Formula_Rec.segment1 is not null) or (c_Formula_Rec.segment2 is not null) or (c_Formula_Rec.segment3 is not null) or
	   (c_Formula_Rec.segment4 is not null) or (c_Formula_Rec.segment5 is not null) or (c_Formula_Rec.segment6 is not null) or
	   (c_Formula_Rec.segment7 is not null) or (c_Formula_Rec.segment8 is not null) or (c_Formula_Rec.segment9 is not null) or
	   (c_Formula_Rec.segment10 is not null) or (c_Formula_Rec.segment11 is not null) or (c_Formula_Rec.segment12 is not null) or
	   (c_Formula_Rec.segment13 is not null) or (c_Formula_Rec.segment14 is not null) or (c_Formula_Rec.segment15 is not null) or
	   (c_Formula_Rec.segment16 is not null) or (c_Formula_Rec.segment17 is not null) or (c_Formula_Rec.segment18 is not null) or
	   (c_Formula_Rec.segment19 is not null) or (c_Formula_Rec.segment20 is not null) or (c_Formula_Rec.segment21 is not null) or
	   (c_Formula_Rec.segment22 is not null) or (c_Formula_Rec.segment23 is not null) or (c_Formula_Rec.segment24 is not null) or
	   (c_Formula_Rec.segment25 is not null) or (c_Formula_Rec.segment26 is not null) or (c_Formula_Rec.segment27 is not null) or
	   (c_Formula_Rec.segment28 is not null) or (c_Formula_Rec.segment29 is not null) or (c_Formula_Rec.segment30 is not null))) then
    begin
      l_type2 := TRUE;
    end;
    elsif ((c_Formula_Rec.prefix_operator is not null) and
	   (c_Formula_Rec.amount is not null) and
	   (c_Formula_Rec.budget_year_type_id is null) and
	   (c_Formula_Rec.balance_type is null) and
	   (c_Formula_Rec.currency_code is null) and
	   (c_Formula_Rec.postfix_operator is null) and
	  ((c_Formula_Rec.segment1 is null) and (c_Formula_Rec.segment2 is null) and (c_Formula_Rec.segment3 is null) and
	   (c_Formula_Rec.segment4 is null) and (c_Formula_Rec.segment5 is null) and (c_Formula_Rec.segment6 is null) and
	   (c_Formula_Rec.segment7 is null) and (c_Formula_Rec.segment8 is null) and (c_Formula_Rec.segment9 is null) and
	   (c_Formula_Rec.segment10 is null) and (c_Formula_Rec.segment11 is null) and (c_Formula_Rec.segment12 is null) and
	   (c_Formula_Rec.segment13 is null) and (c_Formula_Rec.segment14 is null) and (c_Formula_Rec.segment15 is null) and
	   (c_Formula_Rec.segment16 is null) and (c_Formula_Rec.segment17 is null) and (c_Formula_Rec.segment18 is null) and
	   (c_Formula_Rec.segment19 is null) and (c_Formula_Rec.segment20 is null) and (c_Formula_Rec.segment21 is null) and
	   (c_Formula_Rec.segment22 is null) and (c_Formula_Rec.segment23 is null) and (c_Formula_Rec.segment24 is null) and
	   (c_Formula_Rec.segment25 is null) and (c_Formula_Rec.segment26 is null) and (c_Formula_Rec.segment27 is null) and
	   (c_Formula_Rec.segment28 is null) and (c_Formula_Rec.segment29 is null) and (c_Formula_Rec.segment30 is null))) then
    begin
      l_type3 := TRUE;
    end;
    elsif ((c_Formula_Rec.prefix_operator is not null) and
	   (c_Formula_Rec.postfix_operator is not null) and
	   (c_Formula_Rec.balance_type in ('O', 'C')) and
	   (c_Formula_Rec.currency_code is not null) and
	   (c_Formula_Rec.amount is not null) and
	  ((c_Formula_Rec.budget_year_type_id is null) and
	   (c_Formula_Rec.segment1 is null) and (c_Formula_Rec.segment2 is null) and (c_Formula_Rec.segment3 is null) and
	   (c_Formula_Rec.segment4 is null) and (c_Formula_Rec.segment5 is null) and (c_Formula_Rec.segment6 is null) and
	   (c_Formula_Rec.segment7 is null) and (c_Formula_Rec.segment8 is null) and (c_Formula_Rec.segment9 is null) and
	   (c_Formula_Rec.segment10 is null) and (c_Formula_Rec.segment11 is null) and (c_Formula_Rec.segment12 is null) and
	   (c_Formula_Rec.segment13 is null) and (c_Formula_Rec.segment14 is null) and (c_Formula_Rec.segment15 is null) and
	   (c_Formula_Rec.segment16 is null) and (c_Formula_Rec.segment17 is null) and (c_Formula_Rec.segment18 is null) and
	   (c_Formula_Rec.segment19 is null) and (c_Formula_Rec.segment20 is null) and (c_Formula_Rec.segment21 is null) and
	   (c_Formula_Rec.segment22 is null) and (c_Formula_Rec.segment23 is null) and (c_Formula_Rec.segment24 is null) and
	   (c_Formula_Rec.segment25 is null) and (c_Formula_Rec.segment26 is null) and (c_Formula_Rec.segment27 is null) and
	   (c_Formula_Rec.segment28 is null) and (c_Formula_Rec.segment29 is null) and (c_Formula_Rec.segment30 is null))) then
    begin

      if p_summ_flag then
      begin
	message_token('CONSTRAINT', p_constraint_name);
	add_message('PSB', 'PSB_INVALID_CONS_FORMULA');
	raise FND_API.G_EXC_ERROR;
      end;
      else
	l_type4 := TRUE;
      end if;

    end;
    else
    begin
      message_token('CONSTRAINT', p_constraint_name);
      add_message('PSB', 'PSB_INVALID_CONS_FORMULA');
      raise FND_API.G_EXC_ERROR;
    end;
    end if;

    if l_type1 then
    begin

      l_ytd_amount := Compute_Line_Total (p_worksheet_id => p_worksheet_id,
					  p_sp_exists => p_sp_exists,
					  p_flex_mapping_set_id => p_flex_mapping_set_id,
					  p_budget_calendar_id => p_budget_calendar_id,
					  p_ccid => p_ccid,
					  p_budget_year_type_id => c_Formula_Rec.budget_year_type_id,
					  p_balance_type => c_Formula_Rec.balance_type,
					  p_currency_code => c_Formula_Rec.currency_code,
               /* start bug 4256345 */
           /*Bug#5710663: Modified the value passed for param - p_budget_period_id
                          from p_budget_period_id to l_budget_period_id*/
	  				  p_budget_period_id => l_budget_period_id,
          /* Bug#5710663: Modified the values passed to params -
            p_stage_set_id, p_current_stage_seq to handle the Null values*/
  					  p_stage_set_id     => NVL(p_stage_Set_id,l_stage_set_id),
  					  p_current_stage_seq => NVL(p_current_stage_seq,l_current_stage_seq)
          /* End Bug#5710663*/
  					  /* end bug   4256345 */
                              );

      if c_Formula_Rec.postfix_operator = '+' then
	l_line_total := l_ytd_amount + c_Formula_Rec.amount;
      elsif c_Formula_Rec.postfix_operator = '-' then
	l_line_total := l_ytd_Amount - c_Formula_Rec.amount;
      elsif c_Formula_Rec.postfix_operator = '*' then
	l_line_total := l_ytd_amount * c_Formula_Rec.amount;
      elsif c_Formula_Rec.postfix_operator = '/' then
      begin

	-- Avoid divide-by-zero error

	if nvl(c_Formula_Rec.amount, 0) = 0 then
	  l_line_total := 0;
	else
	  l_line_total := l_ytd_amount / c_Formula_Rec.amount;
	end if;

      end;
      else
      begin
	message_token('CONSTRAINT', p_constraint_name);
	add_message('PSB', 'PSB_INVALID_CONS_FORMULA');
	raise FND_API.G_EXC_ERROR;
      end;
      end if;

    end;
    elsif l_type2 then
    begin

      for l_index in 1..g_num_segs loop

	if ((g_seg_name(l_index) = 'SEGMENT1') and
	    (c_Formula_Rec.segment1 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment1;

	elsif ((g_seg_name(l_index) = 'SEGMENT2') and
	    (c_Formula_Rec.segment2 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment2;

	elsif ((g_seg_name(l_index) = 'SEGMENT3') and
	    (c_Formula_Rec.segment3 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment3;

	elsif ((g_seg_name(l_index) = 'SEGMENT4') and
	    (c_Formula_Rec.segment4 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment4;

	elsif ((g_seg_name(l_index) = 'SEGMENT5') and
	    (c_Formula_Rec.segment5 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment5;

	elsif ((g_seg_name(l_index) = 'SEGMENT6') and
	    (c_Formula_Rec.segment6 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment6;

	elsif ((g_seg_name(l_index) = 'SEGMENT7') and
	    (c_Formula_Rec.segment7 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment7;

	elsif ((g_seg_name(l_index) = 'SEGMENT8') and
	    (c_Formula_Rec.segment8 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment8;

	elsif ((g_seg_name(l_index) = 'SEGMENT9') and
	    (c_Formula_Rec.segment9 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment9;

	elsif ((g_seg_name(l_index) = 'SEGMENT10') and
	    (c_Formula_Rec.segment10 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment10;

	elsif ((g_seg_name(l_index) = 'SEGMENT11') and
	    (c_Formula_Rec.segment11 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment11;

	elsif ((g_seg_name(l_index) = 'SEGMENT12') and
	    (c_Formula_Rec.segment12 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment12;

	elsif ((g_seg_name(l_index) = 'SEGMENT13') and
	    (c_Formula_Rec.segment13 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment13;

	elsif ((g_seg_name(l_index) = 'SEGMENT14') and
	    (c_Formula_Rec.segment14 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment14;

	elsif ((g_seg_name(l_index) = 'SEGMENT15') and
	    (c_Formula_Rec.segment15 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment15;

	elsif ((g_seg_name(l_index) = 'SEGMENT16') and
	    (c_Formula_Rec.segment16 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment16;

	elsif ((g_seg_name(l_index) = 'SEGMENT17') and
	    (c_Formula_Rec.segment17 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment17;

	elsif ((g_seg_name(l_index) = 'SEGMENT18') and
	    (c_Formula_Rec.segment18 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment18;

	elsif ((g_seg_name(l_index) = 'SEGMENT19') and
	    (c_Formula_Rec.segment19 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment19;

	elsif ((g_seg_name(l_index) = 'SEGMENT20') and
	    (c_Formula_Rec.segment20 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment20;

	elsif ((g_seg_name(l_index) = 'SEGMENT21') and
	    (c_Formula_Rec.segment21 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment21;

	elsif ((g_seg_name(l_index) = 'SEGMENT22') and
	    (c_Formula_Rec.segment22 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment22;

	elsif ((g_seg_name(l_index) = 'SEGMENT23') and
	    (c_Formula_Rec.segment23 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment23;

	elsif ((g_seg_name(l_index) = 'SEGMENT24') and
	    (c_Formula_Rec.segment24 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment24;

	elsif ((g_seg_name(l_index) = 'SEGMENT25') and
	    (c_Formula_Rec.segment25 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment25;

	elsif ((g_seg_name(l_index) = 'SEGMENT26') and
	    (c_Formula_Rec.segment26 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment26;

	elsif ((g_seg_name(l_index) = 'SEGMENT27') and
	    (c_Formula_Rec.segment27 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment27;

	elsif ((g_seg_name(l_index) = 'SEGMENT28') and
	    (c_Formula_Rec.segment28 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment28;

	elsif ((g_seg_name(l_index) = 'SEGMENT29') and
	    (c_Formula_Rec.segment29 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment29;

	elsif ((g_seg_name(l_index) = 'SEGMENT30') and
	    (c_Formula_Rec.segment30 is not null)) then
	  l_seg_val(l_index) := c_Formula_Rec.segment30;

	else
	begin

	  if p_summ_flag then
	    l_type2 := FALSE;
	  else
	    l_seg_val(l_index) := l_ccid_val(l_index);

/* Bug No 2719865 Start */
	  l_ccid_defined := FALSE;
/* Bug No 2719865 End */

	  end if;

	end;
	end if;

      end loop;

      if l_type2 then
      begin

	-- No new Code Combinations are created from the Constraints Module. If a
	-- composed Code Combination does not already exist in GL, it is not created
	-- dynamically

	l_concat_segments := FND_FLEX_EXT.Concatenate_Segments
				(n_segments => g_num_segs,
				 segments => l_seg_val,
				 delimiter => p_flex_delimiter);

	if not FND_FLEX_KEYVAL.Validate_Segs
		  (operation => 'FIND_COMBINATION',
		   appl_short_name => 'SQLGL',
		   key_flex_code => 'GL#',
		   structure_number => p_flex_code,
		   concat_segments => l_concat_segments) then

/* Bug No 2719865 Start */
	  if (g_first_ccid) then
  	    FND_MSG_PUB.Add;
	    g_first_ccid := FALSE;
	    message_token('CONSTRAINT', p_constraint_name);
	    message_token('CCID', l_concat_segments);
	    add_message('PSB', 'PSB_DISABLED_ACCT_CONSTRAINT');
	  end if;

	  if ((not l_ccid_defined) and (not g_first_ccid)) then
  	    FND_MSG_PUB.Add;
	    message_token('CONSTRAINT', p_constraint_name);
	    message_token('CCID', l_concat_segments);
	    add_message('PSB', 'PSB_DISABLED_ACCT_CONSTRAINT');
	  end if;
/* Bug No 2719865 End */

	else
	begin

	  l_ccid := FND_FLEX_KEYVAL.Combination_ID;

   /*Bug 5710663: Commented the if condition on p_sp_exists
     as this condition avoids the validation of l_type2
     formulas until the table - psb_ws_submit_service_packages
     is populated.*/
	/*if p_sp_exists then
	  begin*/

	    l_ytd_amount := Compute_Line_Total (p_worksheet_id => p_worksheet_id,
						p_sp_exists => p_sp_exists,
						p_flex_mapping_set_id => p_flex_mapping_set_id,
						p_budget_calendar_id => p_budget_calendar_id,
						p_ccid => l_ccid,
						p_budget_year_type_id => c_Formula_Rec.budget_year_type_id,
						p_balance_type => c_Formula_Rec.balance_type,
						p_currency_code => c_Formula_Rec.currency_code,
					    /* bug no 4256345 */
           /* Bug#5710663:modified the value passed for param - p_budget_period_id
                          from p_budget_period_id to l_budget_period_id*/
	  				p_budget_period_id => l_budget_period_id,
         /* Bug#5710663: Modified the values passed to params -
                         p_stage_set_id, p_current_stage_seq to handle Null value*/
  					p_stage_set_id     => NVL(p_stage_Set_id,l_stage_set_id),
  					p_current_stage_seq => NVL(p_current_stage_seq,l_current_stage_seq)
          /* End Bug#5710663*/
  					    /* bug no 4256345 */
					    );

	    if c_Formula_Rec.postfix_operator = '+' then
	      l_line_total := l_ytd_amount + c_Formula_Rec.amount;
	    elsif c_Formula_Rec.postfix_operator = '-' then
	      l_line_total := l_ytd_amount - c_Formula_Rec.amount;
	    elsif c_Formula_Rec.postfix_operator = '*' then
	      l_line_total := l_ytd_amount * c_Formula_Rec.amount;
	    elsif c_Formula_Rec.postfix_operator = '/' then
	    begin

	      -- Avoid divide-by-zero error

	      if nvl(c_Formula_Rec.amount, 0) = 0 then
		l_line_total := 0;
	      else
		l_line_total := l_ytd_amount / c_Formula_Rec.amount;
	      end if;

	    end;
	    else
	      l_line_total := l_ytd_amount;
	    end if;
  /*Start bug: 5710663*/
	 /*end;
	  end if;*/
  /*End bug: 5710663*/
	end;
	end if;

      end;
      else
      begin
	message_token('CONSTRAINT', p_constraint_name);
	add_message('PSB', 'PSB_INVALID_CONS_FORMULA');
	raise FND_API.G_EXC_ERROR;
      end;
      end if;

    end;
    elsif l_type3 then
      l_line_total := c_Formula_Rec.amount;

    /* Bug 2321186 Start*/
    ELSIF l_type5 then

    FOR c_Accounts_Rec in c_Accounts LOOP

      l_ytd_amount := Compute_Line_Total (p_worksheet_id => p_worksheet_id,
						p_sp_exists => p_sp_exists,
						p_flex_mapping_set_id => p_flex_mapping_set_id,
						p_budget_calendar_id => p_budget_calendar_id,
						p_ccid => c_Accounts_Rec.code_combination_id,
						p_budget_year_type_id => c_Formula_Rec.budget_year_type_id,
						p_balance_type => c_Formula_Rec.balance_type,
						p_currency_code => c_Formula_Rec.currency_code,
						/* start bug 4256345 */
           /* Bug#5710663:Modified the value passed for param - p_budget_period_id
                          from p_budget_period_id to l_budget_period_id*/
	  				p_budget_period_id => l_budget_period_id,
         /* Bug#5710663: Modified the values passed to params -
            p_stage_set_id, p_current_stage_seq to handle Null value*/
  					p_stage_set_id     => NVL(p_stage_Set_id,l_stage_set_id),
  					p_current_stage_seq => NVL(p_current_stage_seq,l_current_stage_seq)
          /* End Bug#5710663*/
  					    /* end bug 4256345 */
					    );


      IF l_ytd_amount IS NOT NULL THEN
         l_account_type_factor := Compute_Account_Type_Factor(
                                   p_ccid         => c_Accounts_Rec.code_combination_id,
                                   p_worksheet_id => p_worksheet_id
                                                             );

         l_sum_amount := l_sum_amount + l_account_type_factor * l_ytd_amount;
      END IF;

    END LOOP;

    IF l_sum_amount is NOT NULL THEN
      l_correction_factor := Compute_Correction_Factor(
                                      p_worksheet_id => p_worksheet_id,
                                      p_constraint_id => p_constraint_id);

      l_sum_amount        := l_correction_factor * l_sum_amount;
    END IF;

      IF c_Formula_Rec.postfix_operator = '+' THEN
	l_line_total := l_sum_amount + c_Formula_Rec.amount;
      ELSIF c_Formula_Rec.postfix_operator = '-' THEN
	l_line_total := l_sum_Amount - c_Formula_Rec.amount;
      ELSIF c_Formula_Rec.postfix_operator = '*' THEN
	l_line_total := l_sum_amount * c_Formula_Rec.amount;
      ELSIF c_Formula_Rec.postfix_operator = '/' THEN

        BEGIN

	-- Avoid divide-by-zero error
	IF nvl(c_Formula_Rec.amount, 0) = 0 THEN
	  l_line_total := 0;
	ELSE
	  l_line_total := l_sum_amount / c_Formula_Rec.amount;
	END IF;

        END;
      ELSE
        BEGIN
	  message_token('CONSTRAINT', p_constraint_name);
	  add_message('PSB', 'PSB_INVALID_CONS_FORMULA');
	  raise FND_API.G_EXC_ERROR;
        END;
      END IF;
      /* Bug 2321186 End */
    END IF;

    if c_Formula_Rec.prefix_operator in ('=', '<>', '<=', '>=', '<', '>') then
      l_cons_total := l_line_total;
    elsif c_Formula_Rec.prefix_operator = '+' then
      l_cons_total := l_cons_total + l_line_total;
    elsif c_Formula_Rec.prefix_operator = '-' then
      l_cons_total := l_cons_total - l_line_total;
    elsif c_Formula_Rec.prefix_operator = '*' then
      l_cons_total := l_cons_total * l_line_total;
    elsif c_Formula_Rec.prefix_operator = '/' then
    begin

      -- Avoid divide-by-zero error

      if nvl(l_line_total, 0) = 0 then
	l_cons_total := 0;
      else
	l_cons_total := l_cons_total / l_line_total;
      end if;

    end;
    end if;

  end loop;


  -- Compute Sum of Account Sets or CCID assigned to the Constraint

  if not p_summ_flag then
  begin

    l_ytd_amount := Compute_Account_Total (p_worksheet_id => p_worksheet_id,
					   p_sp_exists => p_sp_exists,
					   p_flex_mapping_set_id => p_flex_mapping_set_id,
					   p_ccid => p_ccid,
					   p_budget_year_id => p_budget_year_id,
					   p_budget_year_type_id => p_budget_year_type_id,
					   p_currency_code => p_currency_code);

    l_accset_total := l_ytd_amount;

  end;
  else
  begin

    l_accset_total := Compute_Sum_Total (p_worksheet_id => p_worksheet_id,
					 p_sp_exists => p_sp_exists,
					 p_constraint_id => p_constraint_id,
					 p_flex_mapping_set_id => p_flex_mapping_set_id,
					 p_budget_year_id => p_budget_year_id,
					 p_budget_year_type_id => p_budget_year_type_id,
					 p_currency_code => p_currency_code,
					 p_budget_group_id => p_budget_group_id);

  end;
  end if;

  if l_accset_total is not null then
  begin

    if l_operator = '<=' then

      if l_accset_total <= l_cons_total then
	l_cons_failed := TRUE;
      end if;

    elsif l_operator = '>=' then

      if l_accset_total >= l_cons_total then
	l_cons_failed := TRUE;
      end if;

    elsif l_operator = '<' then

      if l_accset_total < l_cons_total then
	l_cons_failed := TRUE;
      end if;

    elsif l_operator = '>' then

      if l_accset_total > l_cons_total then
	l_cons_failed := TRUE;
      end if;

    elsif l_operator = '=' then

      if l_accset_total = l_cons_total then
	l_cons_failed := TRUE;
      end if;

    elsif l_operator = '<>' then

      if l_accset_total <> l_cons_total then
	l_cons_failed := TRUE;
      end if;

    end if;

    if l_cons_failed then
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
      message_token('ASSIGNMENT_VALUE', l_accset_total);
      message_token('OPERATOR', l_operator);
      message_token('FORMULA_VALUE', l_cons_total);

      if p_summ_flag then
	message_token('NAME', p_constraint_name);
      else
      begin

	l_mapped_ccid := Map_Account
			    (p_flex_mapping_set_id => p_flex_mapping_set_id,
			     p_ccid => p_ccid,
			     p_budget_year_type_id => p_budget_year_type_id);

	l_concat_segments := FND_FLEX_EXT.Get_Segs
				(application_short_name => 'SQLGL',
				 key_flex_code => 'GL#',
				 structure_number => p_flex_code,
				 combination_id => l_mapped_ccid);

	message_token('NAME', l_concat_segments);

      end;
      end if;

      message_token('YEAR', p_budget_year_name);
      add_message('PSB', 'PSB_CONSTRAINT_FAILURE');

      l_description := FND_MSG_PUB.Get
			  (p_encoded => FND_API.G_FALSE);
      FND_MSG_PUB.Delete_Msg;

      -- Constraint Validation failures are logged in PSB_ERROR_MESSAGES and
      -- viewed using a Form called from the Modify Worksheet module

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

END Process_Constraint;

/* ----------------------------------------------------------------------- */

-- Process Constraint that has the detailed flag set for individual CCIDs

PROCEDURE Apply_Detailed_Account
( p_return_status                 OUT  NOCOPY  VARCHAR2,
  p_constraint_validation_status  OUT  NOCOPY  VARCHAR2,
  p_worksheet_id                  IN   NUMBER,
  p_budget_group_id               IN   NUMBER,
  p_sp_exists                     IN   BOOLEAN,
  p_constraint_set_name           IN   VARCHAR2,
  p_constraint_threshold          IN   NUMBER,
  p_constraint_id                 IN   NUMBER,
  p_constraint_name               IN   VARCHAR2,
  p_flex_code                     IN   NUMBER,
  p_flex_delimiter                IN   VARCHAR2,
  p_budget_calendar_id            IN   NUMBER,
  p_budget_year_id                IN   NUMBER,
  p_budget_year_name              IN   VARCHAR2,
  p_currency_code                 IN   VARCHAR2,
  p_severity_level                IN   NUMBER,
  p_flex_mapping_set_id           IN   NUMBER,
  p_budget_year_type_id           IN   NUMBER,
  /* start bug 4256345 */
  p_budget_period_id			  IN   NUMBER,
  p_stage_set_id				  IN   NUMBER,
  p_current_stage_seq			  IN   NUMBER
  /* end bug 4256345 */
) IS

  l_return_status                 VARCHAR2(1);
  l_msg_data                      VARCHAR2(2000);
  l_msg_count                     NUMBER;

  l_cons_validation_status        VARCHAR2(1) := 'S';
  l_detailed_status               VARCHAR2(1);

  -- CCIDs assigned to the Constraint : select CCIDs that also belong to the Budget Group Hierarchy

  cursor c_CCID is
    select a.code_combination_id ccid
      from PSB_BUDGET_ACCOUNTS a,
	   PSB_SET_RELATIONS_V b
     where exists
	  (select 1
	     from PSB_BUDGET_ACCOUNTS c,
		  PSB_SET_RELATIONS_V d
	    where c.account_position_set_id = d.account_position_set_id
	      and c.code_combination_id = a.code_combination_id
	      and d.account_or_position_type = 'A'
	      and exists
		 (select 1
		    from psb_budget_groups e
		   where e.budget_group_type = 'R'
		     and e.effective_start_date <= g_startdate_pp
		     and (e.effective_end_date is null or e.effective_end_date >= g_enddate_cy)
		     and e.budget_group_id = d.budget_group_id
		   start with e.budget_group_id = p_budget_group_id
		 connect by prior e.budget_group_id = e.parent_budget_group_id))
       and a.account_position_set_id = b.account_position_set_id
       and b.account_or_position_type = 'A'
       and b.constraint_id = p_constraint_id;

  l_api_name          CONSTANT VARCHAR2(30)   := 'Apply_Detailed_Account';

BEGIN

  for c_CCID_Rec in c_CCID loop

    Process_Constraint
	   (p_worksheet_id => p_worksheet_id,
	    p_sp_exists => p_sp_exists,
	    p_constraint_set_name => p_constraint_set_name,
	    p_constraint_threshold => p_constraint_threshold,
	    p_constraint_id => p_constraint_id,
	    p_constraint_name => p_constraint_name,
	    p_flex_code => p_flex_code,
	    p_flex_delimiter => p_flex_delimiter,
	    p_ccid => c_CCID_Rec.ccid,
	    p_budget_calendar_id => p_budget_calendar_id,
	    p_budget_year_id => p_budget_year_id,
	    p_budget_year_name => p_budget_year_name,
	    p_currency_code => p_currency_code,
	    p_severity_level => p_severity_level,
	    p_summ_flag => FALSE,
	    p_constraint_validation_status => l_detailed_status,
	    p_flex_mapping_set_id => p_flex_mapping_set_id,
	    p_budget_year_type_id => p_budget_year_type_id,
    	    p_budget_group_id => p_budget_group_id,
	    p_return_status => l_return_status,
            /* bug no 4256345 */
    	    p_budget_period_id  => p_budget_period_id,
    	    p_stage_set_id      => p_stage_set_id,
    	    p_current_Stage_seq => p_current_stage_seq
    	    /* bug no 4256345 */
            );

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

END Apply_Detailed_Account;

/* ----------------------------------------------------------------------- */

-- Constraint applies to the 'E'stimate Line Items for 'CY' and 'PP' Budget
-- Years for the Currency in the Constraint Definition

-- The following restrictions apply to Constraints :
--
-- For Type1 Lines, the 'Detailed' Flag must be set
--
-- For Type2 Lines, the 'Detailed' Flag must be set for partial Code Combinations
-- to be entered in the Formula Section. If the 'Detailed' Flag is not set, the
-- full Code Combination must be entered in the Formula Section

-- p_validation_status has the following values : 'F'atal, 'E'rror, 'W'arning,
-- 'S'uccess

PROCEDURE Apply_Account_Constraints
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_validation_status     OUT  NOCOPY  VARCHAR2,
  p_worksheet_id          IN   NUMBER,
  p_flex_mapping_set_id   IN   NUMBER,
  p_budget_group_id       IN   NUMBER,
  p_flex_code             IN   NUMBER,
  p_func_currency         IN   VARCHAR2,
  p_constraint_set_id     IN   NUMBER,
  p_constraint_set_name   IN   VARCHAR2,
  p_constraint_threshold  IN   NUMBER,
  p_budget_calendar_id    IN   NUMBER
) IS

  l_return_status              VARCHAR2(1);
  l_msg_data                   VARCHAR2(2000);
  l_msg_count                  NUMBER;

  l_year_index                 PLS_INTEGER;

  l_cons_validation_status     VARCHAR2(1);
  l_consset_validation_status  VARCHAR2(1) := 'S';

  l_flex_delimiter             VARCHAR2(1);

  l_sp_exists                  BOOLEAN := FALSE;

  cursor c_Constraint (Year_Start_Date DATE,
		       Year_End_Date DATE) is
    select constraint_id,
	   name,
	   currency_code,
	   severity_level,
	   effective_start_date,
	   effective_end_date,
	   constraint_detailed_flag
      from PSB_CONSTRAINT_ASSIGNMENTS_V
     where constraint_type = 'ACCOUNT'
       and (((effective_start_date <= Year_End_Date)
	 and (effective_end_date is null))
	 or ((effective_start_date between Year_Start_Date and Year_End_Date)
	  or (effective_end_date between Year_Start_Date and Year_End_Date)
	  or ((effective_start_date < Year_Start_Date)
	  and (effective_end_date > Year_End_Date))))
       and constraint_set_id = p_constraint_set_id
     order by severity_level desc,
	      effective_start_date,
	      effective_end_date;

  -- Check whether Constraints should be applied for specific Service Packages

  cursor c_SP is
    select 'x'
      from dual
     where exists
	  (select 'Service Package Exists'
	     from PSB_WS_SUBMIT_SERVICE_PACKAGES
	    where worksheet_id = p_worksheet_id);


  l_api_name          CONSTANT VARCHAR2(30)   := 'Apply_Account_Constraints';

  /* start bug 4256345 */
  l_stage_set_id        NUMBER;
  l_current_stage_seq   NUMBER;
  TYPE l_budget_period_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_budget_period_tbl l_budget_period_tbl_type;
  /* end bug  4256345 */


BEGIN

  l_flex_delimiter := FND_FLEX_EXT.Get_Delimiter
			 (application_short_name => 'SQLGL',
			  key_flex_code => 'GL#',
			  structure_number => p_flex_code);

  for c_SP_Rec in c_SP loop
    l_sp_exists := TRUE;
  end loop;

  /* start bug 4256345 */
  FOR l_stage_rec IN ( SELECT stage_set_id, current_stage_seq
  					   FROM   psb_worksheets
  					   WHERE  worksheet_id = p_worksheet_id)
  LOOP
    l_stage_set_id := l_stage_rec.stage_set_id;
    l_current_stage_seq := l_stage_rec.current_Stage_seq;
  END LOOP;

  FOR l_budget_period_rec IN (select budget_period_id, budget_year_type_id
       						  from psb_budget_periods
       					      where budget_calendar_id = p_budget_calendar_id
       					      and budget_period_type = 'Y'
       					      and parent_budget_period_id is null
  						     )
  LOOP
    l_budget_period_tbl(l_budget_period_rec.budget_year_type_id) :=
                    l_budget_period_rec.budget_period_id;
  END LOOP;
  /* end bug 4256345 */


  for l_year_index in 1..g_num_budget_years loop

    if (g_budget_years(l_year_index).year_type in ('CY', 'PP')) then
    begin

      for c_Constraint_Rec in c_Constraint (g_budget_years(l_year_index).start_date,
					    g_budget_years(l_year_index).end_date) loop

	if ((c_Constraint_Rec.constraint_detailed_flag is null) or
	    (c_Constraint_Rec.constraint_detailed_flag = 'N')) then
	begin

	  Process_Constraint
		 (p_worksheet_id => p_worksheet_id,
		  p_sp_exists => l_sp_exists,
		  p_constraint_set_name => p_constraint_set_name,
		  p_constraint_threshold => p_constraint_threshold,
		  p_constraint_id => c_Constraint_Rec.constraint_id,
		  p_constraint_name => c_Constraint_Rec.name,
		  p_flex_code => p_flex_code,
		  p_flex_delimiter => l_flex_delimiter,
		  p_budget_calendar_id => p_budget_calendar_id,
		  p_budget_year_id => g_budget_years(l_year_index).budget_year_id,
		  p_budget_year_name => g_budget_years(l_year_index).year_name,
		  p_currency_code => nvl(c_Constraint_Rec.currency_code, p_func_currency),
		  p_severity_level => c_Constraint_Rec.severity_level,
		  p_summ_flag => TRUE,
		  p_constraint_validation_status => l_cons_validation_status,
		  p_flex_mapping_set_id => p_flex_mapping_set_id,
		  p_budget_year_type_id => g_budget_years(l_year_index).budget_year_type_id,
  		  p_budget_group_id => p_budget_group_id,
                  /* start bug 4256345 */
		  p_budget_period_id    => l_budget_period_tbl(g_budget_years(l_year_index).budget_year_type_id),
		  p_stage_set_id        => l_stage_set_id,
		  p_current_stage_seq   => l_current_stage_seq,
		  /* end bug  4256345 */
		  p_return_status => l_return_status);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  -- Assign a proper validation status for the Constraint Set based on the validation
	  -- status for the individual Constraints

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

	  -- For a Constraint with the detailed flag set, call this procedure which
	  -- processes constraints for individual CCIDs. This is to avoid static
	  -- binding

	  Apply_Detailed_Account
	       (p_return_status => l_return_status,
		p_constraint_validation_status => l_cons_validation_status,
		p_worksheet_id => p_worksheet_id,
		p_budget_group_id => p_budget_group_id,
		p_sp_exists => l_sp_exists,
		p_constraint_set_name => p_constraint_set_name,
		p_constraint_threshold => p_constraint_threshold,
		p_constraint_id => c_Constraint_Rec.constraint_id,
		p_constraint_name => c_Constraint_Rec.name,
		p_flex_code => p_flex_code,
		p_flex_delimiter => l_flex_delimiter,
		p_budget_calendar_id => p_budget_calendar_id,
		p_budget_year_id => g_budget_years(l_year_index).budget_year_id,
		p_budget_year_name => g_budget_years(l_year_index).year_name,
		p_currency_code => nvl(c_Constraint_Rec.currency_code, p_func_currency),
		p_severity_level => c_Constraint_Rec.severity_level,
		p_flex_mapping_set_id => p_flex_mapping_set_id,
		p_budget_year_type_id => g_budget_years(l_year_index).budget_year_type_id,
    		/* start bug 4256345 */
		p_budget_period_id    => l_budget_period_tbl(g_budget_years(l_year_index).budget_year_type_id),
		p_stage_set_id        => l_stage_set_id,
		p_current_stage_seq   => l_current_stage_seq
		/* end bug  4256345 */
		);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  -- Assign a proper validation status for the Constraint Set based on the validation
	  -- status for the individual Constraints

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

END Apply_Account_Constraints;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/

-- Bug#4571412
-- Added parameters p_char_of_accounts_id, p_budget_year, p_cc_id
-- to explain newly created message if update statment for
-- PSB_WS_ACCOUNT_LINE_NOTES fails.

-- API created for Bug#1584464
PROCEDURE Create_Note
( p_return_status         OUT NOCOPY VARCHAR2,
  p_account_line_id       IN         NUMBER,
  p_note                  IN         VARCHAR2,
  p_chart_of_accounts_id  IN         NUMBER,
  p_budget_year           IN         VARCHAR2,
  p_cc_id                 IN         NUMBER,
  p_concatenated_segments IN        VARCHAR2
)
IS
  --
  l_change_note      VARCHAR2(1);
  l_note_id          NUMBER;
  --
  -- Bug#4571412
  l_message_text    VARCHAR2(4000);
  l_concat_segments VARCHAR2(2000);

  cursor c_note_id is
  select note_id
  from PSB_WS_ACCOUNT_LINES
  where account_line_id = p_account_line_id;
  --
BEGIN
  --
  FND_PROFILE.GET
  ( name => 'PSB_EDIT_CREATE_NOTES',
    val => l_change_note);

  if nvl(l_change_note, 'Y') = 'Y' then
  begin

    for c_note_rec in c_note_id loop
      l_note_id := c_note_rec.note_id;
    end loop;

    if l_note_id is null then
    begin

      Insert into PSB_WS_ACCOUNT_LINE_NOTES
	(note_id, note, last_update_date, last_updated_by, last_update_login, created_by, creation_date)
      values (psb_ws_account_line_notes_s.nextval, p_note, sysdate, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID, FND_GLOBAL.USER_ID, sysdate)
      returning note_id into l_note_id;

      update PSB_WS_ACCOUNT_LINES
	 set note_id = l_note_id
       where account_line_id = p_account_line_id;

    end;
    else
      BEGIN
        UPDATE PSB_WS_ACCOUNT_LINE_NOTES
	SET note              = note || FND_GLOBAL.NewLine || p_note,
	    last_update_date  = sysdate,
	    last_updated_by   = FND_GLOBAL.USER_ID,
	    last_update_login = FND_GLOBAL.LOGIN_ID,
	    created_by        = FND_GLOBAL.USER_ID,
	    creation_date     = sysdate
        WHERE note_id         = l_note_id;

      -- Bug#4571412
      EXCEPTION
        WHEN others THEN

	  -- Bug#4675858
	  -- Set packaged variable to TRUE. This variable
	  -- will be checked to set the CP status to warning
	  -- if holding TRUE value.
	  PSB_WS_ACCT1.g_soft_error_flag := TRUE ;

          IF p_concatenated_segments IS NULL THEN
            l_concat_segments
              := FND_FLEX_EXT.Get_Segs
                 (application_short_name => 'SQLGL',
                  key_flex_code          => 'GL#',
                  structure_number       => p_chart_of_accounts_id,
                  combination_id         => p_cc_id
                 );
          ELSE
            l_concat_segments := p_concatenated_segments;
          END IF;

          FND_MESSAGE.SET_NAME('PSB', 'PSB_WS_NOTES_EXCEEDED_LIMIT');
          FND_MESSAGE.SET_TOKEN('BUDGET_YEAR', p_budget_year);
          FND_MESSAGE.SET_TOKEN('ACCOUNTING_FLEXFIELD', l_concat_segments);
          --FND_MSG_PUB.Add;
          l_message_text := FND_MESSAGE.GET;
          FND_FILE.PUT_LINE(FND_FILE.LOG, l_message_text);
          --
      END;
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

END Create_Note;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
-- Get Debug Information
FUNCTION Get_Debug RETURN VARCHAR2 IS
BEGIN
  return(g_dbug);
END Get_Debug;
/*---------------------------------------------------------------------------*/


END PSB_WS_ACCT1;

/
