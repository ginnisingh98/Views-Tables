--------------------------------------------------------
--  DDL for Package Body PSB_BUDGET_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_BUDGET_GROUPS_PVT" as
 /* $Header: PSBVBGPB.pls 120.8 2006/01/30 04:20:11 viraghun ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_BUDGET_GROUPS_PVT';

  /*For Bug No : 2230514 Start*/
  --g_debug_flag        VARCHAR2(1) := 'N';
  /*For Bug No : 2230514 End*/

  TYPE TokNameArray IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

  -- TokValArray contains values for all tokens

  TYPE TokValArray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

  TYPE g_budgetgroup_rec_type IS RECORD
      (budget_group_id         NUMBER,
       name                    VARCHAR2(80),
       parent_budget_group_id  NUMBER,
       effective_start_date    DATE,
       effective_end_date      DATE);

  TYPE g_budgetgroup_tbl_type is TABLE OF g_budgetgroup_rec_type
      INDEX BY BINARY_INTEGER;

  cursor c_BudgetGroup (RootBudgetGroup_ID NUMBER) is
    select budget_group_id,
	   name,
	   parent_budget_group_id,
	   set_of_books_id,
	   business_group_id,
	   budget_group_category_set_id,
	   ps_account_position_set_id,
	   nps_account_position_set_id,
	   effective_start_date,
	   effective_end_date
      from PSB_BUDGET_GROUPS
     where budget_group_type = 'R'
     start with budget_group_id = RootBudgetGroup_ID
   connect by prior budget_group_id = parent_budget_group_id;

  cursor c_AccSet (BudgetGroup_ID NUMBER) is
    select account_position_set_id,
	   name,
	   effective_start_date,
	   effective_end_date
      from psb_set_relations_v
     where account_or_position_type = 'A'
       and budget_group_id = BudgetGroup_ID;

  -- .. cursor of overlap ccid in psb_budget_accounts
  -- .. used in val_hierarchy and account_range_overlap procs
  -- .. to test duplicate account overlap
  --

  cursor c_Overlap_CCID (RootBudgetGroup_ID NUMBER,
			 BudgetGroup_ID NUMBER,
			 AccSet_ID NUMBER,
			 Start_Date DATE,
			 End_Date DATE) is
    select a.code_combination_id
      from psb_budget_accounts a,
	   psb_set_relations c
     where a.account_position_set_id = c.account_position_set_id
       and ((((End_Date is not null)
	 and ((c.effective_start_date <= End_Date)
	  and (c.effective_end_date is null))
	  or ((c.effective_start_date between Start_Date and End_Date)
	   or (c.effective_end_date between Start_Date and End_Date)
	  or ((c.effective_start_date < Start_Date)
	  and (c.effective_end_date > End_Date)))))
	  or ((End_Date is null)
	  and (nvl(c.effective_end_date, Start_Date) >= Start_Date)))
       /* for bug no 3824989 */
       -- and c.account_position_set_id <> AccSet_ID
       and c.budget_group_id <> BudgetGroup_ID
       /*For Bug No : 2255402 Start*/
       and exists
	  (select 1
	     from psb_budget_groups
	    where budget_group_id = c.budget_group_id
	      and (budget_group_id = RootBudgetGroup_ID
		or root_budget_group_id = RootBudgetGroup_ID))
       /*
       and c.budget_group_id in
	  (select budget_group_id
	     from psb_budget_groups
	    where (budget_group_id = RootBudgetGroup_ID
		or root_budget_group_id = RootBudgetGroup_ID))
       */
       /*For Bug No : 2255402 End*/
       and exists
	  (select 1
	     from psb_budget_accounts b
	    where a.code_combination_id = b.code_combination_id
	      and b.account_position_set_id = AccSet_ID);


    /* For bug 4991981 --> Removed the view psb_set_relations_v
     and used the table psb_set_relations. Also substituted
     bind variables for literals */

  cursor c_Overlap_Account_Range (RootBudgetGroup_ID NUMBER,
				  BudgetGroup_ID NUMBER,
				  AccSet_ID NUMBER,
				  Start_Date DATE,
				  End_Date DATE,
				  Inc_Type IN VARCHAR2 DEFAULT 'I',
				  Def_Seg  IN VARCHAR2 DEFAULT 'X') is
    select 'ACCOUNT RANGE OVERLAP'
      from psb_account_position_set_lines cmp,
	   psb_account_position_set_lines lst,
	   psb_set_relations a
     where (
		NVL(cmp.SEGMENT30_LOW,Def_Seg)  <= NVL(lst.SEGMENT30_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT30_HIGH,Def_Seg) >= NVL(lst.SEGMENT30_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT29_LOW,Def_Seg)  <= NVL(lst.SEGMENT29_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT29_HIGH,Def_Seg) >= NVL(lst.SEGMENT29_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT28_LOW,Def_Seg)  <= NVL(lst.SEGMENT28_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT28_HIGH,Def_Seg) >= NVL(lst.SEGMENT28_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT27_LOW,Def_Seg)  <= NVL(lst.SEGMENT27_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT27_HIGH,Def_Seg) >= NVL(lst.SEGMENT27_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT26_LOW,Def_Seg)  <= NVL(lst.SEGMENT26_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT26_HIGH,Def_Seg) >= NVL(lst.SEGMENT26_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT25_LOW,Def_Seg)  <= NVL(lst.SEGMENT25_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT25_HIGH,Def_Seg) >= NVL(lst.SEGMENT25_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT24_LOW,Def_Seg)  <= NVL(lst.SEGMENT24_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT24_HIGH,Def_Seg) >= NVL(lst.SEGMENT24_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT23_LOW,Def_Seg)  <= NVL(lst.SEGMENT23_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT23_HIGH,Def_Seg) >= NVL(lst.SEGMENT23_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT22_LOW,Def_Seg)  <= NVL(lst.SEGMENT22_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT22_HIGH,Def_Seg) >= NVL(lst.SEGMENT22_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT21_LOW,Def_Seg)  <= NVL(lst.SEGMENT21_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT21_HIGH,Def_Seg) >= NVL(lst.SEGMENT21_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT20_LOW,Def_Seg)  <= NVL(lst.SEGMENT20_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT20_HIGH,Def_Seg) >= NVL(lst.SEGMENT20_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT19_LOW,Def_Seg)  <= NVL(lst.SEGMENT19_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT19_HIGH,Def_Seg) >= NVL(lst.SEGMENT19_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT18_LOW,Def_Seg)  <= NVL(lst.SEGMENT18_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT18_HIGH,Def_Seg) >= NVL(lst.SEGMENT18_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT17_LOW,Def_Seg)  <= NVL(lst.SEGMENT17_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT17_HIGH,Def_Seg) >= NVL(lst.SEGMENT17_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT16_LOW,Def_Seg)  <= NVL(lst.SEGMENT16_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT16_HIGH,Def_Seg) >= NVL(lst.SEGMENT16_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT15_LOW,Def_Seg)  <= NVL(lst.SEGMENT15_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT15_HIGH,Def_Seg) >= NVL(lst.SEGMENT15_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT14_LOW,Def_Seg)  <= NVL(lst.SEGMENT14_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT14_HIGH,Def_Seg) >= NVL(lst.SEGMENT14_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT13_LOW,Def_Seg)  <= NVL(lst.SEGMENT13_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT13_HIGH,Def_Seg) >= NVL(lst.SEGMENT13_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT12_LOW,Def_Seg)  <= NVL(lst.SEGMENT12_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT12_HIGH,Def_Seg) >= NVL(lst.SEGMENT12_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT11_LOW,Def_Seg)  <= NVL(lst.SEGMENT11_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT11_HIGH,Def_Seg) >= NVL(lst.SEGMENT11_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT10_LOW,Def_Seg)  <= NVL(lst.SEGMENT10_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT10_HIGH,Def_Seg) >= NVL(lst.SEGMENT10_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT9_LOW,Def_Seg)  <= NVL(lst.SEGMENT9_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT9_HIGH,Def_Seg) >= NVL(lst.SEGMENT9_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT8_LOW,Def_Seg)  <= NVL(lst.SEGMENT8_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT8_HIGH,Def_Seg) >= NVL(lst.SEGMENT8_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT7_LOW,Def_Seg)  <= NVL(lst.SEGMENT7_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT7_HIGH,Def_Seg) >= NVL(lst.SEGMENT7_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT6_LOW,Def_Seg)  <= NVL(lst.SEGMENT6_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT6_HIGH,Def_Seg) >= NVL(lst.SEGMENT6_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT5_LOW,Def_Seg)  <= NVL(lst.SEGMENT5_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT5_HIGH,Def_Seg) >= NVL(lst.SEGMENT5_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT4_LOW,Def_Seg)  <= NVL(lst.SEGMENT4_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT4_HIGH,Def_Seg) >= NVL(lst.SEGMENT4_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT3_LOW,Def_Seg)  <= NVL(lst.SEGMENT3_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT3_HIGH,Def_Seg) >= NVL(lst.SEGMENT3_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT2_LOW,Def_Seg)  <= NVL(lst.SEGMENT2_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT2_HIGH,Def_Seg) >= NVL(lst.SEGMENT2_LOW,Def_Seg)
	  AND   NVL(cmp.SEGMENT1_LOW,Def_Seg)  <= NVL(lst.SEGMENT1_HIGH,Def_Seg)
	  AND   NVL(cmp.SEGMENT1_HIGH,Def_Seg) >= NVL(lst.SEGMENT1_LOW,Def_Seg)
	   )
       and lst.account_position_set_id = AccSet_ID
       and lst.include_or_exclude_type = Inc_Type
       and cmp.account_position_set_id = a.account_position_set_id
       and cmp.include_or_exclude_type = Inc_Type
       and ((((End_Date is not null)
	 and ((a.effective_start_date <= End_Date)
	  and (a.effective_end_date is null))
	  or ((a.effective_start_date between Start_Date and End_Date)
	   or (a.effective_end_date between Start_Date and End_Date)
	  or ((a.effective_start_date < Start_Date)
	  and (a.effective_end_date > End_Date)))))
	  or ((End_Date is null)
	  and (nvl(a.effective_end_date, Start_Date) >= Start_Date)))
       and a.account_position_set_id <> AccSet_ID
       and exists
	  (select 1
	     from psb_budget_groups
	    where budget_group_id = a.budget_group_id
	      and (budget_group_id = RootBudgetGroup_ID
		or root_budget_group_id = RootBudgetGroup_ID));

       /* For Bug No : 2255402 Start --> added the above exist clause
          and commented the one below
       and a.budget_group_id in
	  (select budget_group_id
	   d  from psb_budget_groups
	     where (budget_group_id = RootBudgetGroup_ID
		 or root_budget_group_id = RootBudgetGroup_ID));

       For Bug No : 2255402 End*/


  cursor c_Overlap_ps (ps_AccSet NUMBER,
		       nps_AccSet NUMBER) is
    select 'Personnel Services and Non-Personnel Services Account Sets Overlap'
      from dual
     where exists
	  (select 1
	     from psb_budget_accounts a,
		  psb_budget_accounts b
	    where a.code_combination_id = b.code_combination_id
	      and a.account_position_set_id = nps_AccSet
	      and b.account_position_set_id = ps_AccSet);

  cursor c_Overlap_ps_range (l_ps_AccSet NUMBER,
			     l_nps_AccSet NUMBER) is
    select 'Personnel Services and Non-Personnel Services Account Sets Overlap'
      from psb_account_position_set_lines ps,
	   psb_account_position_set_lines nps
     where (
		NVL(ps.SEGMENT30_LOW,'X')  <= NVL(nps.SEGMENT30_HIGH,'X')
	  AND   NVL(ps.SEGMENT30_HIGH,'X') >= NVL(nps.SEGMENT30_LOW,'X')
	  AND   NVL(ps.SEGMENT29_LOW,'X')  <= NVL(nps.SEGMENT29_HIGH,'X')
	  AND   NVL(ps.SEGMENT29_HIGH,'X') >= NVL(nps.SEGMENT29_LOW,'X')
	  AND   NVL(ps.SEGMENT28_LOW,'X')  <= NVL(nps.SEGMENT28_HIGH,'X')
	  AND   NVL(ps.SEGMENT28_HIGH,'X') >= NVL(nps.SEGMENT28_LOW,'X')
	  AND   NVL(ps.SEGMENT27_LOW,'X')  <= NVL(nps.SEGMENT27_HIGH,'X')
	  AND   NVL(ps.SEGMENT27_HIGH,'X') >= NVL(nps.SEGMENT27_LOW,'X')
	  AND   NVL(ps.SEGMENT26_LOW,'X')  <= NVL(nps.SEGMENT26_HIGH,'X')
	  AND   NVL(ps.SEGMENT26_HIGH,'X') >= NVL(nps.SEGMENT26_LOW,'X')
	  AND   NVL(ps.SEGMENT25_LOW,'X')  <= NVL(nps.SEGMENT25_HIGH,'X')
	  AND   NVL(ps.SEGMENT25_HIGH,'X') >= NVL(nps.SEGMENT25_LOW,'X')
	  AND   NVL(ps.SEGMENT24_LOW,'X')  <= NVL(nps.SEGMENT24_HIGH,'X')
	  AND   NVL(ps.SEGMENT24_HIGH,'X') >= NVL(nps.SEGMENT24_LOW,'X')
	  AND   NVL(ps.SEGMENT23_LOW,'X')  <= NVL(nps.SEGMENT23_HIGH,'X')
	  AND   NVL(ps.SEGMENT23_HIGH,'X') >= NVL(nps.SEGMENT23_LOW,'X')
	  AND   NVL(ps.SEGMENT22_LOW,'X')  <= NVL(nps.SEGMENT22_HIGH,'X')
	  AND   NVL(ps.SEGMENT22_HIGH,'X') >= NVL(nps.SEGMENT22_LOW,'X')
	  AND   NVL(ps.SEGMENT21_LOW,'X')  <= NVL(nps.SEGMENT21_HIGH,'X')
	  AND   NVL(ps.SEGMENT21_HIGH,'X') >= NVL(nps.SEGMENT21_LOW,'X')
	  AND   NVL(ps.SEGMENT20_LOW,'X')  <= NVL(nps.SEGMENT20_HIGH,'X')
	  AND   NVL(ps.SEGMENT20_HIGH,'X') >= NVL(nps.SEGMENT20_LOW,'X')
	  AND   NVL(ps.SEGMENT19_LOW,'X')  <= NVL(nps.SEGMENT19_HIGH,'X')
	  AND   NVL(ps.SEGMENT19_HIGH,'X') >= NVL(nps.SEGMENT19_LOW,'X')
	  AND   NVL(ps.SEGMENT18_LOW,'X')  <= NVL(nps.SEGMENT18_HIGH,'X')
	  AND   NVL(ps.SEGMENT18_HIGH,'X') >= NVL(nps.SEGMENT18_LOW,'X')
	  AND   NVL(ps.SEGMENT17_LOW,'X')  <= NVL(nps.SEGMENT17_HIGH,'X')
	  AND   NVL(ps.SEGMENT17_HIGH,'X') >= NVL(nps.SEGMENT17_LOW,'X')
	  AND   NVL(ps.SEGMENT16_LOW,'X')  <= NVL(nps.SEGMENT16_HIGH,'X')
	  AND   NVL(ps.SEGMENT16_HIGH,'X') >= NVL(nps.SEGMENT16_LOW,'X')
	  AND   NVL(ps.SEGMENT15_LOW,'X')  <= NVL(nps.SEGMENT15_HIGH,'X')
	  AND   NVL(ps.SEGMENT15_HIGH,'X') >= NVL(nps.SEGMENT15_LOW,'X')
	  AND   NVL(ps.SEGMENT14_LOW,'X')  <= NVL(nps.SEGMENT14_HIGH,'X')
	  AND   NVL(ps.SEGMENT14_HIGH,'X') >= NVL(nps.SEGMENT14_LOW,'X')
	  AND   NVL(ps.SEGMENT13_LOW,'X')  <= NVL(nps.SEGMENT13_HIGH,'X')
	  AND   NVL(ps.SEGMENT13_HIGH,'X') >= NVL(nps.SEGMENT13_LOW,'X')
	  AND   NVL(ps.SEGMENT12_LOW,'X')  <= NVL(nps.SEGMENT12_HIGH,'X')
	  AND   NVL(ps.SEGMENT12_HIGH,'X') >= NVL(nps.SEGMENT12_LOW,'X')
	  AND   NVL(ps.SEGMENT11_LOW,'X')  <= NVL(nps.SEGMENT11_HIGH,'X')
	  AND   NVL(ps.SEGMENT11_HIGH,'X') >= NVL(nps.SEGMENT11_LOW,'X')
	  AND   NVL(ps.SEGMENT10_LOW,'X')  <= NVL(nps.SEGMENT10_HIGH,'X')
	  AND   NVL(ps.SEGMENT10_HIGH,'X') >= NVL(nps.SEGMENT10_LOW,'X')
	  AND   NVL(ps.SEGMENT9_LOW,'X')  <= NVL(nps.SEGMENT9_HIGH,'X')
	  AND   NVL(ps.SEGMENT9_HIGH,'X') >= NVL(nps.SEGMENT9_LOW,'X')
	  AND   NVL(ps.SEGMENT8_LOW,'X')  <= NVL(nps.SEGMENT8_HIGH,'X')
	  AND   NVL(ps.SEGMENT8_HIGH,'X') >= NVL(nps.SEGMENT18_LOW,'X')
	  AND   NVL(ps.SEGMENT7_LOW,'X')  <= NVL(nps.SEGMENT7_HIGH,'X')
	  AND   NVL(ps.SEGMENT7_HIGH,'X') >= NVL(nps.SEGMENT7_LOW,'X')
	  AND   NVL(ps.SEGMENT6_LOW,'X')  <= NVL(nps.SEGMENT6_HIGH,'X')
	  AND   NVL(ps.SEGMENT6_HIGH,'X') >= NVL(nps.SEGMENT6_LOW,'X')
	  AND   NVL(ps.SEGMENT5_LOW,'X')  <= NVL(nps.SEGMENT5_HIGH,'X')
	  AND   NVL(ps.SEGMENT5_HIGH,'X') >= NVL(nps.SEGMENT5_LOW,'X')
	  AND   NVL(ps.SEGMENT4_LOW,'X')  <= NVL(nps.SEGMENT4_HIGH,'X')
	  AND   NVL(ps.SEGMENT4_HIGH,'X') >= NVL(nps.SEGMENT4_LOW,'X')
	  AND   NVL(ps.SEGMENT3_LOW,'X')  <= NVL(nps.SEGMENT3_HIGH,'X')
	  AND   NVL(ps.SEGMENT3_HIGH,'X') >= NVL(nps.SEGMENT3_LOW,'X')
	  AND   NVL(ps.SEGMENT2_LOW,'X')  <= NVL(nps.SEGMENT2_HIGH,'X')
	  AND   NVL(ps.SEGMENT2_HIGH,'X') >= NVL(nps.SEGMENT2_LOW,'X')
	  AND   NVL(ps.SEGMENT1_LOW,'X')  <= NVL(nps.SEGMENT1_HIGH,'X')
	  AND   NVL(ps.SEGMENT1_HIGH,'X') >= NVL(nps.SEGMENT1_LOW,'X')
	   )
       and ps.account_position_set_id = l_ps_AccSet
       and ps.include_or_exclude_type = 'I'
       and nps.account_position_set_id = l_nps_AccSet
       and nps.include_or_exclude_type = 'I';

  -- Characterset independent representation of chr(10)

  /*For Bug No : 2230514 Start*/
  --g_chr10 CONSTANT VARCHAR2(1) := FND_GLOBAL.Newline;
  /*For Bug No : 2230514 End*/

  -- Number of Message Tokens

  no_msg_tokens       NUMBER := 0;

  -- Message Token Name

  msg_tok_names       TokNameArray;

  -- Message Token Value

  msg_tok_val         TokValArray;

  /*For Bug No : 2230514 Start*/
  --g_dbug              VARCHAR2(2000) := 'starting';
  /*For Bug No : 2230514 End*/

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function Definition                        */
/*                                                                         */
/* ----------------------------------------------------------------------- */

PROCEDURE Val_Budget_Group
( p_budget_group_id       IN   NUMBER,
  p_budget_group_name     IN   VARCHAR2,
  p_effective_start_date  IN   DATE,
  p_effective_end_date    IN   DATE,
  p_return_status         OUT  NOCOPY  VARCHAR2
);

PROCEDURE message_token
( tokname  IN  VARCHAR2,
  tokval   IN  VARCHAR2
);

PROCEDURE Output_Message_To_Table
( p_budget_group_id IN NUMBER
);

PROCEDURE add_message
( appname  IN  VARCHAR2,
  msgname  IN  VARCHAR2
);

PROCEDURE Validate_PSB_Accounts_And_GL
( p_top_budget_group_id  IN   NUMBER,
  p_flex_code            IN   NUMBER,
  p_return_status        OUT  NOCOPY  VARCHAR2
);

PROCEDURE Validate_BGCCID_vs_PS_NPS
( p_top_budget_group_id  IN   NUMBER,
  p_flex_code            IN   NUMBER,
  p_ps_account_set_id    IN   NUMBER,
  p_nps_account_set_id   IN   NUMBER,
  p_return_status        OUT  NOCOPY  VARCHAR2
);

PROCEDURE Validate_BG_ORGANIZATION
( p_top_budget_group_id  IN   NUMBER,
  p_return_status        OUT  NOCOPY  VARCHAR2
);

/* ----------------------------------------------------------------------- */

/*For Bug No : 2230514 Start*/
/*
PROCEDURE debug
( p_message   IN   VARCHAR2) IS

BEGIN

  if g_debug_flag = 'Y' then
    null;
--  dbms_output.put_line(p_message);
  end if;

END debug;
*/
/*For Bug No : 2230514 End*/

/* ----------------------------------------------------------------------- */

PROCEDURE Check_Budget_Group_Freeze
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_budget_group_id   IN   NUMBER
) AS

  l_api_name          CONSTANT VARCHAR2(30) := 'Check_Budget_Group_Freeze';
  l_api_version       CONSTANT NUMBER       := 1.0;

  l_freeze_flag       VARCHAR2(1);

  cursor c_FreezeFlag is
    select nvl(freeze_hierarchy_flag, root_freeze_hierarchy_flag) freeze_hierarchy_flag
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = p_budget_group_id;

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  for c_FreezeFlag_Rec in c_FreezeFlag loop
    l_freeze_flag := c_FreezeFlag_Rec.freeze_hierarchy_flag;
  end loop;

  if ((l_freeze_flag is null) or (l_freeze_flag = 'N')) then
    raise FND_API.G_EXC_ERROR;
  end if;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


  -- Initialize API Return Status to Success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
	(p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Check_Budget_Group_Freeze;

/* ----------------------------------------------------------------------- */

PROCEDURE Val_Budget_Group
( p_budget_group_id       IN   NUMBER,
  p_budget_group_name     IN   VARCHAR2,
  p_effective_start_date  IN   DATE,
  p_effective_end_date    IN   DATE,
  p_return_status         OUT  NOCOPY  VARCHAR2
) AS

  -- Find CCIDs that overlap for the same effective dates

  cursor c_Overlap (AccSet_ID NUMBER,
		    Start_Date DATE,
		    End_Date DATE) is
    select 'Account Sets Overlap'
      from psb_budget_accounts a,
	   psb_budget_accounts b,
	   psb_set_relations_v c
     where a.code_combination_id = b.code_combination_id
       and b.account_position_set_id = AccSet_ID
       and a.account_position_set_id = c.account_position_set_id
       and ((((End_Date is not null)
	 and ((c.effective_start_date <= End_Date)
	  and (c.effective_end_date is null))
	  or ((c.effective_start_date between Start_Date and End_Date)
	   or (c.effective_end_date between Start_Date and End_Date)
	  or ((c.effective_start_date < Start_Date)
	  and (c.effective_end_date > End_Date)))))
	  or ((End_Date is null)
	  and (nvl(c.effective_end_date, Start_Date) >= Start_Date)))
       and c.account_position_set_id <> AccSet_ID
       and c.account_or_position_type = 'A'
       and c.budget_group_id = p_budget_group_id;

BEGIN

  -- Check for a specific Budget Group :
  --
  --   (1) Account Set Effective Dates bounded by Budget Group Effective Dates
  --   (2) No Overlap in Account Assignments for the same Effective Dates

  for c_AccSet_Rec in c_AccSet (p_budget_group_id) loop

    if p_effective_end_date is null then

      if (c_AccSet_Rec.effective_start_date < p_effective_start_date) then
	message_token('ACCOUNT_SET', c_AccSet_Rec.name);
	message_token('BUDGET_GROUP', p_budget_group_name);
	add_message('PSB', 'ACCSET_EFF_DATE_OUT_OF_RANGE');
	raise FND_API.G_EXC_ERROR;
      end if;

    else

      if (c_AccSet_Rec.effective_start_date not between p_effective_start_date
						    and p_effective_end_date) then
	message_token('ACCOUNT_SET', c_AccSet_Rec.name);
	message_token('BUDGET_GROUP', p_budget_group_name);
	add_message('PSB', 'ACCSET_EFF_DATE_OUT_OF_RANGE');
	raise FND_API.G_EXC_ERROR;
      end if;

      if (nvl(c_AccSet_Rec.effective_end_date, p_effective_end_date) not between
	      p_effective_start_date and p_effective_end_date) then
	message_token('ACCOUNT_SET', c_AccSet_Rec.name);
	message_token('BUDGET_GROUP', p_budget_group_name);
	add_message('PSB', 'ACCSET_EFF_DATE_OUT_OF_RANGE');
	raise FND_API.G_EXC_ERROR;
      end if;

    end if;

    for c_Overlap_Rec in c_Overlap (c_AccSet_Rec.account_position_set_id,
				    c_AccSet_Rec.effective_start_date,
				    c_AccSet_Rec.effective_end_date) loop
      message_token('ACCOUNT_SET', c_AccSet_Rec.name);
      message_token('BUDGET_GROUP', p_budget_group_name);
      add_message('PSB', 'ACCSET_BG_OVERLAP');
      raise FND_API.G_EXC_ERROR;
    end loop;

  end loop;


  -- Initialize API Return Status to Success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Val_Budget_Group;

/* ----------------------------------------------------------------------- */

PROCEDURE Val_Budget_Group_Hierarchy
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_budget_group_id     IN   NUMBER,
  p_budget_by_position  IN   VARCHAR2 := 'N',
  p_validate_ranges     IN   VARCHAR2 := FND_API.G_TRUE,
  p_force_freeze        IN   VARCHAR2 := 'N',
  p_check_missing_acct  IN   VARCHAR2 := FND_API.G_TRUE
) AS

  l_api_name            CONSTANT VARCHAR2(30) := 'Val_Budget_Group_Hierarchy';
  l_api_version         CONSTANT NUMBER := 1.0;

  l_budget_group        g_budgetgroup_tbl_type;

  l_account_range_overlap_flag  VARCHAR2(1) := 'N' ;
  l_budget_group_error  VARCHAR2(1) := 'N' ;
  l_missing_ccid_flag   VARCHAR2(1) := 'N' ;
  l_missing_nps_ps_ccid VARCHAR2(1) := 'N' ;

  l_bg_index            BINARY_INTEGER := 1;
  l_init_index          BINARY_INTEGER;
  l_search_index        BINARY_INTEGER;

  l_parent_name         VARCHAR2(100);
  l_parent_start_date   DATE;
  l_parent_end_date     DATE;

  l_flex_code           NUMBER;

  l_concat_segments     VARCHAR2(2000);

  l_ps_account_set_id   NUMBER;
  l_nps_account_set_id  NUMBER;

  l_return_status       VARCHAR2(1);

  cursor c_Flex is
    select nvl(chart_of_accounts_id, root_chart_of_accounts_id) flex_code
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = p_budget_group_id;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Val_Budget_Group_Hierarchy_Pvt;


  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Check for Budget Group Hierarchy :
  --
  --   (1) Child Budget Group Effective Dates within Effective Dates of Parent Budget Group
  --   (2) No Duplicate Account Set Assignments within the Hierarchy for the same Effective Dates
  --   (3) Complete Data for Root Budget Group (SOB, Business Group, Budget Group Category Set,
  --       Personnel Services Account Set, Non_Personnel Services Account Set)
  --   (4) Check that Ranges for the Personnel Services and Non-Personnel Services Account Sets do not overlap

  for l_init_index in 1..l_budget_group.Count loop
    l_budget_group(l_init_index).budget_group_id := null;
    l_budget_group(l_init_index).name := null;
    l_budget_group(l_init_index).parent_budget_group_id := null;
    l_budget_group(l_init_index).effective_start_date := null;
    l_budget_group(l_init_index).effective_end_date := null;
  end loop;

  for c_Flex_Rec in c_Flex loop
    l_flex_code := c_Flex_Rec.flex_code;
  end loop;

  for c_BudgetGroup_Rec in c_BudgetGroup (p_budget_group_id) loop

    Val_Budget_Group
       (p_budget_group_id => c_BudgetGroup_Rec.budget_group_id,
	p_budget_group_name => c_BudgetGroup_Rec.name,
	p_effective_start_date => c_BudgetGroup_Rec.effective_start_date,
	p_effective_end_date => c_BudgetGroup_Rec.effective_end_date,
	p_return_status => l_return_status);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      message_token('BUDGET_GROUP', c_BudgetGroup_Rec.name);
      add_message('PSB', 'PSB_INVALID_BUDGET_GROUP');
      l_budget_group_error := 'Y';
    end if;

    -- Note : this is a DFS so we need to cache these Budget Groups

    if (c_BudgetGroup_Rec.budget_group_id = p_budget_group_id) then
    begin

      l_ps_account_set_id := c_BudgetGroup_Rec.ps_account_position_set_id;
      l_nps_account_set_id := c_BudgetGroup_Rec.nps_account_position_set_id;

      -- Root Budget Group Definition must be complete

      if ((c_BudgetGroup_Rec.set_of_books_id is null) or
	  ((p_budget_by_position = 'Y') and (c_BudgetGroup_Rec.business_group_id is null)) or
/* Bug No 2610221 Start */
-- Removed the category_set check since it is not mandatory
--	  (c_BudgetGroup_Rec.budget_group_category_set_id is null) or
/* Bug No 2610221 End */
	  (c_BudgetGroup_Rec.ps_account_position_set_id is null) or
	  (c_BudgetGroup_Rec.nps_account_position_set_id is null)) then

	add_message('PSB', 'INVALID_ROOT_BG_DEFN');
	l_budget_group_error := 'Y';
      end if;

      -- Ranges for Personnel Services and Non Personnel Services Account Sets should not Overlap

      for c_Overlap_ps_Rec in c_Overlap_ps (c_BudgetGroup_Rec.ps_account_position_set_id,
					    c_BudgetGroup_Rec.nps_account_position_set_id) loop
	message_token('BUDGET_GROUP', c_BudgetGroup_Rec.name);
	add_message('PSB', 'CCID_OVERLAP');
	l_budget_group_error := 'Y';
      end loop;

      if FND_API.to_Boolean(p_validate_ranges) then
      begin

	l_account_range_overlap_flag := 'N';

	for c_Overlap_ps_Rec in c_Overlap_ps_range (c_BudgetGroup_Rec.ps_account_position_set_id,
						    c_BudgetGroup_Rec.nps_account_position_set_id) loop
	  message_token('BUDGET_GROUP', c_BudgetGroup_Rec.name);
	  add_message('PSB', 'CCID_OVERLAP');
	  l_account_range_overlap_flag := 'Y'; -- set flag
	end loop;

	if ((l_account_range_overlap_flag = 'Y') and
	    (p_force_freeze = 'N')) then
	  l_budget_group_error := 'Y';
	end if ;

      end;
      end if;

    end;
    else
    begin

      for l_search_index in 1..l_bg_index - 1 loop

	if (l_budget_group(l_search_index).budget_group_id = c_BudgetGroup_Rec.parent_budget_group_id) then
	  l_parent_name := l_budget_group(l_search_index).name;
	  l_parent_start_date := l_budget_group(l_search_index).effective_start_date;
	  l_parent_end_date := l_budget_group(l_search_index).effective_end_date;
	  exit;
	end if;

      end loop;

      -- Child Budget Group Effective Dates must be bounded by the corresponding
      -- values for the parent Budget Group

      if l_parent_end_date is null then

	if (c_BudgetGroup_Rec.effective_start_date < l_parent_start_date) then
	  message_token('BUDGET_GROUP', c_BudgetGroup_Rec.name);
	  message_token('PARENT_BUDGET_GROUP', l_parent_name);
	  add_message('PSB', 'BG_EFF_DATE_OUT_OF_RANGE');
	  l_budget_group_error := 'Y';
	end if;

      else
      begin

	if (c_BudgetGroup_Rec.effective_start_date not between l_parent_start_date
							   and l_parent_end_date) then
	  message_token('BUDGET_GROUP', c_BudgetGroup_Rec.name);
	  message_token('PARENT_BUDGET_GROUP', l_parent_name);
	  add_message('PSB', 'BG_EFF_DATE_OUT_OF_RANGE');
	  l_budget_group_error := 'Y';
	end if;

	if (nvl(c_BudgetGroup_Rec.effective_end_date, l_parent_end_date) not between
			      l_parent_start_date and l_parent_end_date) then
	  message_token('BUDGET_GROUP', c_BudgetGroup_Rec.name);
	  message_token('PARENT_BUDGET_GROUP', l_parent_name);
	  add_message('PSB', 'BG_EFF_DATE_OUT_OF_RANGE');
	  l_budget_group_error := 'Y';
	end if;

      end;
      end if;

    end;
    end if;

    for c_AccSet_Rec in c_Accset (c_BudgetGroup_Rec.budget_group_id) loop

      for c_Overlap_CCID_Rec in c_Overlap_CCID (p_budget_group_id,
						c_BudgetGroup_Rec.budget_group_id,
						c_AccSet_Rec.account_position_set_id,
						c_AccSet_Rec.effective_start_date,
						c_AccSet_Rec.effective_end_date) loop

	l_concat_segments := FND_FLEX_EXT.Get_Segs
				(application_short_name => 'SQLGL',
				 key_flex_code => 'GL#',
				 structure_number => l_flex_code,
				 combination_id => c_Overlap_CCID_Rec.code_combination_id);

	message_token('CCID', l_concat_segments);
	message_token('ACCOUNT_SET', c_AccSet_Rec.name);
	message_token('BUDGET_GROUP',c_budgetgroup_rec.name);
	add_message('PSB', 'ACCSET_BGH_OVERLAP');
	l_budget_group_error := 'Y';
      end loop;

      if FND_API.to_Boolean(p_validate_ranges) then
      begin

	l_account_range_overlap_flag := 'N';

	for c_Overlap_Account_Range_Rec in c_Overlap_Account_Range (p_budget_group_id,
								    c_BudgetGroup_Rec.budget_group_id,
								    c_AccSet_Rec.account_position_set_id,
								    c_AccSet_Rec.effective_start_date,
								    c_AccSet_Rec.effective_end_date) loop
	  message_token('BUDGET_GROUP',c_budgetgroup_rec.name);
	  message_token('ACCOUNT_SET', c_AccSet_Rec.name);
	  add_message('PSB', 'PSB_OVERLAP_ACCT_RANGE');
	  l_account_range_overlap_flag := 'Y'; -- set flag
	end loop;

  -- .. freeze ....., use value of l_account_range_overlap_flag
  --    to either force freeze or not, depending on user selection

	if ((l_account_range_overlap_flag = 'Y') and
	    (p_force_freeze = 'N')) then
	  l_budget_group_error := 'Y';
	end if ;

      end;
      end if;

    end loop;

    l_budget_group(l_bg_index).budget_group_id := c_BudgetGroup_Rec.budget_group_id;
    l_budget_group(l_bg_index).name := c_BudgetGroup_Rec.name;
    l_budget_group(l_bg_index).parent_budget_group_id := c_BudgetGroup_Rec.parent_budget_group_id;
    l_budget_group(l_bg_index).effective_start_date := c_BudgetGroup_Rec.effective_start_date;
    l_budget_group(l_bg_index).effective_end_date := c_BudgetGroup_Rec.effective_end_date;

    l_bg_index := l_bg_index + 1;

  end loop;

  --
  -- validate psb accounts vs gl accounts
  --
  if FND_API.to_Boolean(p_check_missing_acct) then

     Validate_PSB_Accounts_And_GL
	     (p_top_budget_group_id => p_budget_group_id,
	      p_flex_code => l_flex_code,
	      p_return_status => l_return_status);

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN

	 l_missing_ccid_flag := 'Y';

	 -- flag indicates there was error
	 IF (p_force_freeze = 'N')  then
	   l_budget_group_error := 'Y';
	 END IF;

     end if;
  --
  end if;

  --
  -- validate budget group's ccid is in nps/ps ccid
  -- do not bypass error even if force freeze on
  --

  Validate_BGCCID_vs_PS_NPS
	     (p_top_budget_group_id => p_budget_group_id,
	      p_ps_account_set_id => l_ps_account_set_id,
	      p_nps_account_set_id => l_nps_account_set_id,
	      p_flex_code => l_flex_code,
	      p_return_status => l_return_status);

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    -- this will fail... ws creation will fail it too

    l_budget_group_error := 'Y';

  END IF;


     Validate_BG_Organization
	     (p_top_budget_group_id => p_budget_group_id,
	      p_return_status => l_return_status);

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN

	 l_missing_ccid_flag := 'Y';
	 -- soft validation only
     end if;
  --
  --
  -- Initialize API Return Status to Success
  -- and update freeze flag
  --
    IF (l_budget_group_error <> 'Y')  THEN

      update PSB_BUDGET_GROUPS
	 set freeze_hierarchy_flag = 'Y'
       where budget_group_id = p_budget_group_id;

       p_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE
       p_return_status := FND_API.G_RET_STS_ERROR  ;
  END IF;

  -- add final messages to error file
  -- reverse order b/c insert error will insert it in desc order

  add_message('PSB', 'PSB_BG_ERROR_DUMMY1');
  add_message('PSB', 'PSB_BG_ERROR_DUMMY');
  add_message('PSB', 'PSB_BG_ERROR_DUMMY1');
  -- dummy message to separate final msg from validation errors

  IF (l_budget_group_error <>  'Y') THEN
	IF ( l_missing_ccid_flag = 'Y' OR
	   l_account_range_overlap_flag = 'Y') THEN
	   add_message('PSB', 'PSB_WARNING_VALIDATE_BGP');
	END IF;
	add_message('PSB', 'PSB_SUCCESS_VALIDATE_BGP');
  ELSE
	IF ( l_missing_ccid_flag = 'Y' OR
	   l_account_range_overlap_flag = 'Y') THEN
	   add_message('PSB', 'PSB_WARNING_VALIDATE_BGP_FAIL2');
	   add_message('PSB', 'PSB_WARNING_VALIDATE_BGP_FAIL');
	   add_message('PSB', 'PSB_WARNING_VALIDATE_BGP');
	END IF;
	add_message('PSB', 'PSB_FAILURE_VALIDATE_BGP');
  END IF;


  -- write to file
  IF (l_budget_group_error =  'Y' OR
      l_missing_ccid_flag = 'Y' OR
      l_account_range_overlap_flag = 'Y'
     ) THEN

      Output_Message_To_Table(p_budget_group_id  => p_budget_group_id);
  ELSE
      delete from PSB_ERROR_MESSAGES
       where source_process = 'VALIDATE_BUDGET_HIERARCHY'
	 and process_id = p_budget_group_id;
      -- to delete previous error for the budget group
  END IF;

  -- add messages to empty stack for out and log file
  IF (l_budget_group_error <>  'Y') THEN
	add_message('PSB', 'PSB_SUCCESS_VALIDATE_BGP');
	IF ( l_missing_ccid_flag = 'Y' OR
	   l_account_range_overlap_flag = 'Y') THEN
	   add_message('PSB', 'PSB_WARNING_VALIDATE_BGP');
	END IF;
  ELSE
	add_message('PSB', 'PSB_FAILURE_VALIDATE_BGP');
	IF ( l_missing_ccid_flag = 'Y' OR
	   l_account_range_overlap_flag = 'Y') THEN
	   add_message('PSB', 'PSB_WARNING_VALIDATE_BGP');
	   add_message('PSB', 'PSB_WARNING_VALIDATE_BGP_FAIL');
	   add_message('PSB', 'PSB_WARNING_VALIDATE_BGP_FAIL2');
	END IF;
  END IF;

  -- Standard check of p_commit

  if FND_API.to_Boolean(p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


  -- Initialize API Return Status to Success
  --
  -- p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Val_Budget_Group_Hierarchy_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Val_Budget_Group_Hierarchy_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

   when OTHERS then
     rollback to Val_Budget_Group_Hierarchy_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);

     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Val_Budget_Group_Hierarchy;

/* ----------------------------------------------------------------------- */

PROCEDURE INSERT_ROW (
  p_api_version                  in number,
  p_init_msg_list                in varchar2 := fnd_api.g_false,
  p_commit                       in varchar2 := fnd_api.g_false,
  p_validation_level             in number := fnd_api.g_valid_level_full,
  p_return_status                OUT  NOCOPY varchar2,
  p_msg_count                    OUT  NOCOPY number,
  p_msg_data                     OUT  NOCOPY varchar2,
  p_rowid                        in OUT  NOCOPY varchar2,
  p_budget_group_id              in number,
  p_name                         in varchar2,
  p_short_name                   in varchar2,
  p_root_budget_group            in varchar2,
  p_parent_budget_group_id       in number,
  p_root_budget_group_id         in number,
  p_ps_account_position_set_id   in number,
  p_nps_account_position_set_id  in number,
  p_budget_group_category_set_id in number,
  p_effective_start_date         in date,
  p_effective_end_date           in date,
  p_freeze_hierarchy_flag        in varchar2,
  p_description                  in varchar2,
  p_set_of_books_id              in number,
  p_business_group_id            in number,
  p_num_proposed_years           in number,
  p_narrative_description        in varchar2,
  p_budget_group_type            in varchar2,
  p_organization_id              in number ,
  p_request_id                   in number,
  p_segment1_type                in number,
  p_segment2_type                in number,
  p_segment3_type                in number,
  p_segment4_type                in number,
  p_segment5_type                in number,
  p_segment6_type                in number,
  p_segment7_type                in number,
  p_segment8_type                in number,
  p_segment9_type                in number,
  p_segment10_type               in number,
  p_segment11_type               in number,
  p_segment12_type               in number,
  p_segment13_type               in number,
  p_segment14_type               in number,
  p_segment15_type               in number,
  p_segment16_type               in number,
  p_segment17_type               in number,
  p_segment18_type               in number,
  p_segment19_type               in number,
  p_segment20_type               in number,
  p_segment21_type               in number,
  p_segment22_type               in number,
  p_segment23_type               in number,
  p_segment24_type               in number,
  p_segment25_type               in number,
  p_segment26_type               in number,
  p_segment27_type               in number,
  p_segment28_type               in number,
  p_segment29_type               in number,
  p_segment30_type               in number,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_context                      in varchar2,
  p_mode                         in varchar2 := 'R'
  ) AS

    cursor C is select ROWID from PSB_BUDGET_GROUPS
      where BUDGET_GROUP_ID = P_BUDGET_GROUP_ID;
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
--
l_api_name      CONSTANT VARCHAR2(30) := 'Insert_Row' ;
l_api_version   CONSTANT NUMBER := 1.0 ;
l_return_status VARCHAR2(1);
--

BEGIN
  --
  SAVEPOINT Insert_Row ;
  --
  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  P_LAST_UPDATE_DATE := SYSDATE;
  if(P_MODE = 'I') then
    P_LAST_UPDATED_BY := 1;
    P_LAST_UPDATE_LOGIN := 0;
  elsif (P_MODE = 'R') then
    P_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if P_LAST_UPDATED_BY is NULL then
      P_LAST_UPDATED_BY := -1;
    end if;
    P_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if P_LAST_UPDATE_LOGIN is NULL then
      P_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    FND_MSG_PUB.Add ;
    raise FND_API.G_EXC_ERROR ;
  end if;

  insert into PSB_BUDGET_GROUPS (
    budget_group_id,
    name,
    short_name,
    root_budget_group,
    parent_budget_group_id,
    root_budget_group_id,
    ps_account_position_set_id,
    nps_account_position_set_id,
    budget_group_category_set_id,
    effective_start_date,
    effective_end_date,
    freeze_hierarchy_flag,
    description,
    set_of_books_id,
    business_group_id,
    num_proposed_years,
    narrative_description,
    budget_group_type,
    organization_id,
    request_id,
    segment1_type,
    segment2_type,
    segment3_type,
    segment4_type,
    segment5_type,
    segment6_type,
    segment7_type,
    segment8_type,
    segment9_type,
    segment10_type,
    segment11_type,
    segment12_type,
    segment13_type,
    segment14_type,
    segment15_type,
    segment16_type,
    segment17_type,
    segment18_type,
    segment19_type,
    segment20_type,
    segment21_type,
    segment22_type,
    segment23_type,
    segment24_type,
    segment25_type,
    segment26_type,
    segment27_type,
    segment28_type,
    segment29_type,
    segment30_type,
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
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  ) values (
    p_budget_group_id,
    p_name,
    p_short_name,
    p_root_budget_group,
    p_parent_budget_group_id,
    p_root_budget_group_id,
    p_ps_account_position_set_id,
    p_nps_account_position_set_id,
    p_budget_group_category_set_id,
    p_effective_start_date,
    p_effective_end_date,
    p_freeze_hierarchy_flag,
    p_description,
    p_set_of_books_id,
    p_business_group_id,
    p_num_proposed_years,
    p_narrative_description,
    p_budget_group_type,
    p_organization_id,
    p_request_id,
    p_segment1_type,
    p_segment2_type,
    p_segment3_type,
    p_segment4_type,
    p_segment5_type,
    p_segment6_type,
    p_segment7_type,
    p_segment8_type,
    p_segment9_type,
    p_segment10_type,
    p_segment11_type,
    p_segment12_type,
    p_segment13_type,
    p_segment14_type,
    p_segment15_type,
    p_segment16_type,
    p_segment17_type,
    p_segment18_type,
    p_segment19_type,
    p_segment20_type,
    p_segment21_type,
    p_segment22_type,
    p_segment23_type,
    p_segment24_type,
    p_segment25_type,
    p_segment26_type,
    p_segment27_type,
    p_segment28_type,
    p_segment29_type,
    p_segment30_type,
    p_attribute1,
    p_attribute2,
    p_attribute3,
    p_attribute4,
    p_attribute5,
    p_attribute6,
    p_attribute7,
    p_attribute8,
    p_attribute9,
    p_attribute10,
    p_context,
    p_last_update_date,
    p_last_updated_by,
    p_last_update_date,
    p_last_updated_by,
    p_last_update_login
  );

  open c;
  fetch c into P_ROWID;
  if (c%notfound) then
    close c;
    raise FND_API.G_EXC_ERROR ;
  end if;
  close c;

  --
  -- Standard check of p_commit.
  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);
  --

EXCEPTION
   --
   when FND_API.G_EXC_ERROR then
     --
     rollback to INSERT_ROW ;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     rollback to INSERT_ROW ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     rollback to INSERT_ROW ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
END INSERT_ROW;

/*---------------------------------------------------------------*/

PROCEDURE LOCK_ROW (
  p_api_version                  in number,
  p_init_msg_list                in varchar2 := FND_API.G_FALSE,
  p_commit                       in varchar2 := FND_API.G_FALSE,
  p_validation_level             in number :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status                OUT  NOCOPY varchar2,
  p_msg_count                    OUT  NOCOPY number,
  p_msg_data                     OUT  NOCOPY varchar2,
  p_lock_row                     OUT  NOCOPY varchar2,
  p_budget_group_id              in number,
  p_name                         in varchar2,
  p_short_name                   in varchar2,
  p_root_budget_group            in varchar2,
  p_parent_budget_group_id       in number,
  p_root_budget_group_id         in number,
  p_ps_account_position_set_id   in number,
  p_nps_account_position_set_id  in number,
  p_budget_group_category_set_id in number,
  p_effective_start_date         in date,
  p_effective_end_date           in date,
  p_freeze_hierarchy_flag        in varchar2,
  p_description                  in varchar2,
  p_set_of_books_id              in number,
  p_business_group_id            in number,
  p_num_proposed_years           in number,
  p_narrative_description        in varchar2,
  p_budget_group_type            in varchar2,
  p_organization_id              in number ,
  p_request_id                   in number,
  p_segment1_type                in number,
  p_segment2_type                in number,
  p_segment3_type                in number,
  p_segment4_type                in number,
  p_segment5_type                in number,
  p_segment6_type                in number,
  p_segment7_type                in number,
  p_segment8_type                in number,
  p_segment9_type                in number,
  p_segment10_type               in number,
  p_segment11_type               in number,
  p_segment12_type               in number,
  p_segment13_type               in number,
  p_segment14_type               in number,
  p_segment15_type               in number,
  p_segment16_type               in number,
  p_segment17_type               in number,
  p_segment18_type               in number,
  p_segment19_type               in number,
  p_segment20_type               in number,
  p_segment21_type               in number,
  p_segment22_type               in number,
  p_segment23_type               in number,
  p_segment24_type               in number,
  p_segment25_type               in number,
  p_segment26_type               in number,
  p_segment27_type               in number,
  p_segment28_type               in number,
  p_segment29_type               in number,
  p_segment30_type               in number,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_context                      in varchar2
) as

  cursor c1 is select
      name,
      short_name,
      root_budget_group,
      parent_budget_group_id,
      root_budget_group_id,
      ps_account_position_set_id,
      nps_account_position_set_id,
      budget_group_category_set_id,
      effective_start_date,
      effective_end_date,
      freeze_hierarchy_flag,
      description,
      set_of_books_id,
      business_group_id,
      num_proposed_years,
      narrative_description,
      budget_group_type,
      organization_id,
      request_id,
      segment1_type,
      segment2_type,
      segment3_type,
      segment4_type,
      segment5_type,
      segment6_type,
      segment7_type,
      segment8_type,
      segment9_type,
      segment10_type,
      segment11_type,
      segment12_type,
      segment13_type,
      segment14_type,
      segment15_type,
      segment16_type,
      segment17_type,
      segment18_type,
      segment19_type,
      segment20_type,
      segment21_type,
      segment22_type,
      segment23_type,
      segment24_type,
      segment25_type,
      segment26_type,
      segment27_type,
      segment28_type,
      segment29_type,
      segment30_type,
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
      context
    from PSB_BUDGET_GROUPS
    where BUDGET_GROUP_ID = P_BUDGET_GROUP_ID
    for update of BUDGET_GROUP_ID nowait;
  tlinfo c1%rowtype;
--
l_api_name      CONSTANT VARCHAR2(30) := 'Lock_Row';
l_api_version   CONSTANT NUMBER := 1.0 ;

--
BEGIN
  --
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  if ( (tlinfo.NAME = P_NAME)
      AND (tlinfo.SHORT_NAME = P_SHORT_NAME)
      AND ((tlinfo.ROOT_BUDGET_GROUP = P_ROOT_BUDGET_GROUP)
	   OR ((tlinfo.ROOT_BUDGET_GROUP is null)
	       AND (P_ROOT_BUDGET_GROUP is null)))
      AND ((tlinfo.PARENT_BUDGET_GROUP_ID = P_PARENT_BUDGET_GROUP_ID)
	   OR ((tlinfo.PARENT_BUDGET_GROUP_ID is null)
	       AND (P_PARENT_BUDGET_GROUP_ID is null)))
      AND ((tlinfo.ROOT_BUDGET_GROUP_ID = P_ROOT_BUDGET_GROUP_ID)
	   OR ((tlinfo.ROOT_BUDGET_GROUP_ID is null)
	       AND (P_ROOT_BUDGET_GROUP_ID is null)))
      AND ((tlinfo.PS_ACCOUNT_POSITION_SET_ID = P_PS_ACCOUNT_POSITION_SET_ID)
	   OR ((tlinfo.PS_ACCOUNT_POSITION_SET_ID is null)
	       AND (P_PS_ACCOUNT_POSITION_SET_ID is null)))
      AND ((tlinfo.NPS_ACCOUNT_POSITION_SET_ID = P_NPS_ACCOUNT_POSITION_SET_ID)
	   OR ((tlinfo.NPS_ACCOUNT_POSITION_SET_ID is null)
	       AND (P_NPS_ACCOUNT_POSITION_SET_ID is null)))
      AND ((tlinfo.BUDGET_GROUP_CATEGORY_SET_ID = P_BUDGET_GROUP_CATEGORY_SET_ID)
	   OR ((tlinfo.BUDGET_GROUP_CATEGORY_SET_ID is null)
	       AND (P_BUDGET_GROUP_CATEGORY_SET_ID is null)))
      AND (tlinfo.EFFECTIVE_START_DATE = P_EFFECTIVE_START_DATE)
      AND ((tlinfo.EFFECTIVE_END_DATE = P_EFFECTIVE_END_DATE)
	   OR ((tlinfo.EFFECTIVE_END_DATE is null)
	       AND (P_EFFECTIVE_END_DATE is null)))
      AND ((tlinfo.FREEZE_HIERARCHY_FLAG = P_FREEZE_HIERARCHY_FLAG)
	   OR ((tlinfo.FREEZE_HIERARCHY_FLAG is null)
	       AND (P_FREEZE_HIERARCHY_FLAG is null)))
      AND ((tlinfo.DESCRIPTION = P_DESCRIPTION)
	   OR ((tlinfo.DESCRIPTION is null)
	       AND (P_DESCRIPTION is null)))
      AND ((tlinfo.SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID)
	   OR ((tlinfo.SET_OF_BOOKS_ID is null)
	       AND (P_SET_OF_BOOKS_ID is null)))
      AND ((tlinfo.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID)
	   OR ((tlinfo.BUSINESS_GROUP_ID is null)
	       AND (P_BUSINESS_GROUP_ID is null)))
      AND ((tlinfo.ORGANIZATION_ID  = P_ORGANIZATION_ID )
	   OR ((tlinfo.ORGANIZATION_ID  is null)
	       AND (P_ORGANIZATION_ID  is null)))
      AND ((tlinfo.NUM_PROPOSED_YEARS = P_NUM_PROPOSED_YEARS)
	   OR ((tlinfo.NUM_PROPOSED_YEARS is null)
	       AND (P_NUM_PROPOSED_YEARS is null)))
      AND ((tlinfo.NARRATIVE_DESCRIPTION = P_NARRATIVE_DESCRIPTION)
	   OR ((tlinfo.NARRATIVE_DESCRIPTION is null)
	       AND (P_NARRATIVE_DESCRIPTION is null)))
      AND ((tlinfo.BUDGET_GROUP_TYPE = P_BUDGET_GROUP_TYPE)
	   OR ((tlinfo.BUDGET_GROUP_TYPE is null)
	       AND (P_BUDGET_GROUP_TYPE is null)))
      AND ((tlinfo.REQUEST_ID = P_REQUEST_ID)
	   OR ((tlinfo.REQUEST_ID is null)
	       AND (P_REQUEST_ID is null)))
      AND ((tlinfo.SEGMENT1_TYPE = P_SEGMENT1_TYPE)
	   OR ((tlinfo.SEGMENT1_TYPE is null)
	       AND (P_SEGMENT1_TYPE is null)))
      AND ((tlinfo.SEGMENT2_TYPE = P_SEGMENT2_TYPE)
	   OR ((tlinfo.SEGMENT2_TYPE is null)
	       AND (P_SEGMENT2_TYPE is null)))
      AND ((tlinfo.SEGMENT3_TYPE = P_SEGMENT3_TYPE)
	   OR ((tlinfo.SEGMENT3_TYPE is null)
	       AND (P_SEGMENT3_TYPE is null)))
      AND ((tlinfo.SEGMENT4_TYPE = P_SEGMENT4_TYPE)
	   OR ((tlinfo.SEGMENT4_TYPE is null)
	       AND (P_SEGMENT4_TYPE is null)))
      AND ((tlinfo.SEGMENT5_TYPE = P_SEGMENT5_TYPE)
	   OR ((tlinfo.SEGMENT5_TYPE is null)
	       AND (P_SEGMENT5_TYPE is null)))
      AND ((tlinfo.SEGMENT6_TYPE = P_SEGMENT6_TYPE)
	   OR ((tlinfo.SEGMENT6_TYPE is null)
	       AND (P_SEGMENT6_TYPE is null)))
      AND ((tlinfo.SEGMENT7_TYPE = P_SEGMENT7_TYPE)
	   OR ((tlinfo.SEGMENT7_TYPE is null)
	       AND (P_SEGMENT7_TYPE is null)))
      AND ((tlinfo.SEGMENT8_TYPE = P_SEGMENT8_TYPE)
	   OR ((tlinfo.SEGMENT8_TYPE is null)
	       AND (P_SEGMENT8_TYPE is null)))
      AND ((tlinfo.SEGMENT9_TYPE = P_SEGMENT9_TYPE)
	   OR ((tlinfo.SEGMENT9_TYPE is null)
	       AND (P_SEGMENT9_TYPE is null)))
      AND ((tlinfo.SEGMENT10_TYPE = P_SEGMENT10_TYPE)
	   OR ((tlinfo.SEGMENT10_TYPE is null)
	       AND (P_SEGMENT10_TYPE is null)))
      AND ((tlinfo.SEGMENT11_TYPE = P_SEGMENT11_TYPE)
	   OR ((tlinfo.SEGMENT11_TYPE is null)
	       AND (P_SEGMENT11_TYPE is null)))
      AND ((tlinfo.SEGMENT12_TYPE = P_SEGMENT12_TYPE)
	   OR ((tlinfo.SEGMENT12_TYPE is null)
	       AND (P_SEGMENT12_TYPE is null)))
      AND ((tlinfo.SEGMENT13_TYPE = P_SEGMENT13_TYPE)
	   OR ((tlinfo.SEGMENT13_TYPE is null)
	       AND (P_SEGMENT13_TYPE is null)))
      AND ((tlinfo.SEGMENT14_TYPE = P_SEGMENT14_TYPE)
	   OR ((tlinfo.SEGMENT14_TYPE is null)
	       AND (P_SEGMENT14_TYPE is null)))
      AND ((tlinfo.SEGMENT15_TYPE = P_SEGMENT15_TYPE)
	   OR ((tlinfo.SEGMENT15_TYPE is null)
	       AND (P_SEGMENT15_TYPE is null)))
      AND ((tlinfo.SEGMENT16_TYPE = P_SEGMENT16_TYPE)
	   OR ((tlinfo.SEGMENT16_TYPE is null)
	       AND (P_SEGMENT16_TYPE is null)))
      AND ((tlinfo.SEGMENT17_TYPE = P_SEGMENT17_TYPE)
	   OR ((tlinfo.SEGMENT17_TYPE is null)
	       AND (P_SEGMENT17_TYPE is null)))
      AND ((tlinfo.SEGMENT18_TYPE = P_SEGMENT18_TYPE)
	   OR ((tlinfo.SEGMENT18_TYPE is null)
	       AND (P_SEGMENT18_TYPE is null)))
      AND ((tlinfo.SEGMENT19_TYPE = P_SEGMENT19_TYPE)
	   OR ((tlinfo.SEGMENT19_TYPE is null)
	       AND (P_SEGMENT19_TYPE is null)))
      AND ((tlinfo.SEGMENT20_TYPE = P_SEGMENT20_TYPE)
	   OR ((tlinfo.SEGMENT20_TYPE is null)
	       AND (P_SEGMENT20_TYPE is null)))
      AND ((tlinfo.SEGMENT21_TYPE = P_SEGMENT21_TYPE)
	   OR ((tlinfo.SEGMENT21_TYPE is null)
	       AND (P_SEGMENT21_TYPE is null)))
      AND ((tlinfo.SEGMENT22_TYPE = P_SEGMENT22_TYPE)
	   OR ((tlinfo.SEGMENT22_TYPE is null)
	       AND (P_SEGMENT22_TYPE is null)))
      AND ((tlinfo.SEGMENT23_TYPE = P_SEGMENT23_TYPE)
	   OR ((tlinfo.SEGMENT23_TYPE is null)
	       AND (P_SEGMENT23_TYPE is null)))
      AND ((tlinfo.SEGMENT24_TYPE = P_SEGMENT24_TYPE)
	   OR ((tlinfo.SEGMENT24_TYPE is null)
	       AND (P_SEGMENT24_TYPE is null)))
      AND ((tlinfo.SEGMENT25_TYPE = P_SEGMENT25_TYPE)
	   OR ((tlinfo.SEGMENT25_TYPE is null)
	       AND (P_SEGMENT25_TYPE is null)))
      AND ((tlinfo.SEGMENT26_TYPE = P_SEGMENT26_TYPE)
	   OR ((tlinfo.SEGMENT26_TYPE is null)
	       AND (P_SEGMENT26_TYPE is null)))
      AND ((tlinfo.SEGMENT27_TYPE = P_SEGMENT27_TYPE)
	   OR ((tlinfo.SEGMENT27_TYPE is null)
	       AND (P_SEGMENT27_TYPE is null)))
      AND ((tlinfo.SEGMENT28_TYPE = P_SEGMENT28_TYPE)
	   OR ((tlinfo.SEGMENT28_TYPE is null)
	       AND (P_SEGMENT28_TYPE is null)))
      AND ((tlinfo.SEGMENT29_TYPE = P_SEGMENT29_TYPE)
	   OR ((tlinfo.SEGMENT29_TYPE is null)
	       AND (P_SEGMENT29_TYPE is null)))
      AND ((tlinfo.SEGMENT30_TYPE = P_SEGMENT30_TYPE)
	   OR ((tlinfo.SEGMENT30_TYPE is null)
	       AND (P_SEGMENT30_TYPE is null)))
      AND ((tlinfo.ATTRIBUTE1 = P_ATTRIBUTE1)
	   OR ((tlinfo.ATTRIBUTE1 is null)
	       AND (P_ATTRIBUTE1 is null)))
      AND ((tlinfo.ATTRIBUTE2 = P_ATTRIBUTE2)
	   OR ((tlinfo.ATTRIBUTE2 is null)
	       AND (P_ATTRIBUTE2 is null)))
      AND ((tlinfo.ATTRIBUTE3 = P_ATTRIBUTE3)
	   OR ((tlinfo.ATTRIBUTE3 is null)
	       AND (P_ATTRIBUTE3 is null)))
      AND ((tlinfo.ATTRIBUTE4 = P_ATTRIBUTE4)
	   OR ((tlinfo.ATTRIBUTE4 is null)
	       AND (P_ATTRIBUTE4 is null)))
      AND ((tlinfo.ATTRIBUTE5 = P_ATTRIBUTE5)
	   OR ((tlinfo.ATTRIBUTE5 is null)
	       AND (P_ATTRIBUTE5 is null)))
      AND ((tlinfo.ATTRIBUTE6 = P_ATTRIBUTE6)
	   OR ((tlinfo.ATTRIBUTE6 is null)
	       AND (P_ATTRIBUTE6 is null)))
      AND ((tlinfo.ATTRIBUTE7 = P_ATTRIBUTE7)
	   OR ((tlinfo.ATTRIBUTE7 is null)
	       AND (P_ATTRIBUTE7 is null)))
      AND ((tlinfo.ATTRIBUTE8 = P_ATTRIBUTE8)
	   OR ((tlinfo.ATTRIBUTE8 is null)
	       AND (P_ATTRIBUTE8 is null)))
      AND ((tlinfo.ATTRIBUTE9 = P_ATTRIBUTE9)
	   OR ((tlinfo.ATTRIBUTE9 is null)
	       AND (P_ATTRIBUTE9 is null)))
      AND ((tlinfo.ATTRIBUTE10 = P_ATTRIBUTE10)
	   OR ((tlinfo.ATTRIBUTE10 is null)
	       AND (P_ATTRIBUTE10 is null)))
      AND ((tlinfo.CONTEXT = P_CONTEXT)
	   OR ((tlinfo.CONTEXT is null)
	       AND (P_CONTEXT is null)))
  ) then
    p_lock_row := FND_API.G_TRUE;
  else
    FND_MESSAGE.Set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception ;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
	  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
	       ROLLBACK TO Lock_Row ;
	       p_lock_row := FND_API.G_FALSE;
	       p_return_status := FND_API.G_RET_STS_ERROR;
	       FND_MSG_PUB.Count_And_Get ( p_count => p_msg_count,
	       p_data => p_msg_data );

END LOCK_ROW;

/*---------------------------------------------------------------*/

PROCEDURE UPDATE_ROW (
  p_api_version                  in number,
  p_init_msg_list                in varchar2 := fnd_api.g_false,
  p_commit                       in varchar2 := fnd_api.g_false,
  p_validation_level             in number   := fnd_api.g_valid_level_full,
  p_return_status                OUT  NOCOPY varchar2,
  p_msg_count                    OUT  NOCOPY number,
  p_msg_data                     OUT  NOCOPY varchar2,

  p_budget_group_id              in number,
  p_name                         in varchar2,
  p_short_name                   in varchar2,
  p_root_budget_group            in varchar2,
  p_parent_budget_group_id       in number,
  p_root_budget_group_id         in number,
  p_ps_account_position_set_id   in number,
  p_nps_account_position_set_id  in number,
  p_budget_group_category_set_id in number,
  p_effective_start_date         in date,
  p_effective_end_date           in date,
  p_freeze_hierarchy_flag        in varchar2,
  p_description                  in varchar2,
  p_set_of_books_id              in number,
  p_business_group_id            in number,
  p_num_proposed_years           in number,
  p_narrative_description        in varchar2,
  p_budget_group_type            in varchar2,
  p_organization_id              in number ,
  p_request_id                   in number,
  p_segment1_type                in number,
  p_segment2_type                in number,
  p_segment3_type                in number,
  p_segment4_type                in number,
  p_segment5_type                in number,
  p_segment6_type                in number,
  p_segment7_type                in number,
  p_segment8_type                in number,
  p_segment9_type                in number,
  p_segment10_type               in number,
  p_segment11_type               in number,
  p_segment12_type               in number,
  p_segment13_type               in number,
  p_segment14_type               in number,
  p_segment15_type               in number,
  p_segment16_type               in number,
  p_segment17_type               in number,
  p_segment18_type               in number,
  p_segment19_type               in number,
  p_segment20_type               in number,
  p_segment21_type               in number,
  p_segment22_type               in number,
  p_segment23_type               in number,
  p_segment24_type               in number,
  p_segment25_type               in number,
  p_segment26_type               in number,
  p_segment27_type               in number,
  p_segment28_type               in number,
  p_segment29_type               in number,
  p_segment30_type               in number,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_context                      in varchar2,
  p_mode                         in varchar2 := 'R'
  ) AS

    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
--
l_api_name      CONSTANT VARCHAR2(30) := 'Update Row';
l_api_version   CONSTANT NUMBER := 1.0 ;
--
BEGIN
  --
  SAVEPOINT Update_Row ;
  --
  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  --

  P_LAST_UPDATE_DATE := SYSDATE;
  if(P_MODE = 'I') then
    P_LAST_UPDATED_BY := 1;
    P_LAST_UPDATE_LOGIN := 0;
  elsif (P_MODE = 'R') then
    P_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if P_LAST_UPDATED_BY is NULL then
      P_LAST_UPDATED_BY := -1;
    end if;
    P_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if P_LAST_UPDATE_LOGIN is NULL then
      P_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    FND_MSG_PUB.Add ;
    raise FND_API.G_EXC_ERROR ;
  end if;


  update PSB_BUDGET_GROUPS set
    name                         = p_name,
    short_name                   = p_short_name,
    root_budget_group            = p_root_budget_group,
    parent_budget_group_id       = p_parent_budget_group_id,
    root_budget_group_id         = p_root_budget_group_id,
    ps_account_position_set_id   = p_ps_account_position_set_id,
    nps_account_position_set_id  = p_nps_account_position_set_id,
    budget_group_category_set_id = p_budget_group_category_set_id,
    effective_start_date         = p_effective_start_date,
    effective_end_date           = p_effective_end_date,
    freeze_hierarchy_flag        = p_freeze_hierarchy_flag,
    description                  = p_description,
    set_of_books_id              = p_set_of_books_id,
    business_group_id            = p_business_group_id,
    num_proposed_years           = p_num_proposed_years,
    narrative_description        = p_narrative_description,
    budget_group_type            = p_budget_group_type,
    organization_id              = p_organization_id ,
    request_id                   = p_request_id,
    segment1_type                = p_segment1_type,
    segment2_type                = p_segment2_type,
    segment3_type                = p_segment3_type,
    segment4_type                = p_segment4_type,
    segment5_type                = p_segment5_type,
    segment6_type                = p_segment6_type,
    segment7_type                = p_segment7_type,
    segment8_type                = p_segment8_type,
    segment9_type                = p_segment9_type,
    segment10_type               = p_segment10_type,
    segment11_type               = p_segment11_type,
    segment12_type               = p_segment12_type,
    segment13_type               = p_segment13_type,
    segment14_type               = p_segment14_type,
    segment15_type               = p_segment15_type,
    segment16_type               = p_segment16_type,
    segment17_type               = p_segment17_type,
    segment18_type               = p_segment18_type,
    segment19_type               = p_segment19_type,
    segment20_type               = p_segment20_type,
    segment21_type               = p_segment21_type,
    segment22_type               = p_segment22_type,
    segment23_type               = p_segment23_type,
    segment24_type               = p_segment24_type,
    segment25_type               = p_segment25_type,
    segment26_type               = p_segment26_type,
    segment27_type               = p_segment27_type,
    segment28_type               = p_segment28_type,
    segment29_type               = p_segment29_type,
    segment30_type               = p_segment30_type,
    attribute1                   = p_attribute1,
    attribute2                   = p_attribute2,
    attribute3                   = p_attribute3,
    attribute4                   = p_attribute4,
    attribute5                   = p_attribute5,
    attribute6                   = p_attribute6,
    attribute7                   = p_attribute7,
    attribute8                   = p_attribute8,
    attribute9                   = p_attribute9,
    attribute10                  = p_attribute10,
    context                      = p_context,
    last_update_date             = p_last_update_date,
    last_updated_by              = p_last_updated_by,
    last_update_login            = p_last_update_login
  where BUDGET_GROUP_ID = P_BUDGET_GROUP_ID
  ;

  if (sql%notfound) then
    raise FND_API.G_EXC_ERROR;
  end if;

  --
  -- Standard check of p_commit.
  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);
  --


EXCEPTION
   --
   when FND_API.G_EXC_ERROR then
     --
     rollback to UPDATE_ROW ;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     rollback to UPDATE_ROW ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     rollback to UPDATE_ROW ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --


END UPDATE_ROW;

/*---------------------------------------------------------------*/

PROCEDURE ADD_ROW (
  p_api_version                  in number,
  p_init_msg_list                in varchar2 := fnd_api.g_false,
  p_commit                       in varchar2 := fnd_api.g_false,
  p_validation_level             in number   := fnd_api.g_valid_level_full,
  p_return_status                OUT  NOCOPY varchar2,
  p_msg_count                    OUT  NOCOPY number,
  p_msg_data                     OUT  NOCOPY varchar2,
  p_rowid                        in OUT  NOCOPY varchar2,
  p_budget_group_id              in number,
  p_name                         in varchar2,
  p_short_name                   in varchar2,
  p_root_budget_group            in varchar2,
  p_parent_budget_group_id       in number,
  p_root_budget_group_id         in number,
  p_ps_account_position_set_id   in number,
  p_nps_account_position_set_id  in number,
  p_budget_group_category_set_id in number,
  p_effective_start_date         in date,
  p_effective_end_date           in date,
  p_freeze_hierarchy_flag        in varchar2,
  p_description                  in varchar2,
  p_set_of_books_id              in number,
  p_business_group_id            in number,
  p_num_proposed_years           in number,
  p_narrative_description        in varchar2,
  p_budget_group_type            in varchar2,
  p_organization_id              in number ,
  p_request_id                   in number,
  p_segment1_type                in number,
  p_segment2_type                in number,
  p_segment3_type                in number,
  p_segment4_type                in number,
  p_segment5_type                in number,
  p_segment6_type                in number,
  p_segment7_type                in number,
  p_segment8_type                in number,
  p_segment9_type                in number,
  p_segment10_type               in number,
  p_segment11_type               in number,
  p_segment12_type               in number,
  p_segment13_type               in number,
  p_segment14_type               in number,
  p_segment15_type               in number,
  p_segment16_type               in number,
  p_segment17_type               in number,
  p_segment18_type               in number,
  p_segment19_type               in number,
  p_segment20_type               in number,
  p_segment21_type               in number,
  p_segment22_type               in number,
  p_segment23_type               in number,
  p_segment24_type               in number,
  p_segment25_type               in number,
  p_segment26_type               in number,
  p_segment27_type               in number,
  p_segment28_type               in number,
  p_segment29_type               in number,
  p_segment30_type               in number,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_context                      in varchar2,
  p_mode                         in varchar2 := 'R'
) AS

  cursor c1 is select rowid from PSB_BUDGET_GROUPS
     where BUDGET_GROUP_ID = P_BUDGET_GROUP_ID
  ;
  dummy c1%rowtype;
--
l_api_name    CONSTANT VARCHAR2(30) := 'Add Row' ;
l_api_version CONSTANT NUMBER := 1.0 ;
--
BEGIN
  --
  SAVEPOINT Add_Row ;
  --
  -- Initialize message list if p_init_msg_list is set to TRUE.
  --
  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  open c1;
  fetch c1 into dummy;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     p_api_version,
     p_init_msg_list,
     p_commit,
     p_validation_level,
     p_return_status,
     p_msg_count,
     p_msg_data,
     p_rowid,
     p_budget_group_id,
     p_name,
     p_short_name,
     p_root_budget_group,
     p_parent_budget_group_id,
     p_root_budget_group_id,
     p_ps_account_position_set_id,
     p_nps_account_position_set_id,
     p_budget_group_category_set_id,
     p_effective_start_date,
     p_effective_end_date,
     p_freeze_hierarchy_flag,
     p_description,
     p_set_of_books_id,
     p_business_group_id,
     p_num_proposed_years,
     p_narrative_description,
     p_budget_group_type,
     p_organization_id,
     p_request_id,
     p_segment1_type,
     p_segment2_type,
     p_segment3_type,
     p_segment4_type,
     p_segment5_type,
     p_segment6_type,
     p_segment7_type,
     p_segment8_type,
     p_segment9_type,
     p_segment10_type,
     p_segment11_type,
     p_segment12_type,
     p_segment13_type,
     p_segment14_type,
     p_segment15_type,
     p_segment16_type,
     p_segment17_type,
     p_segment18_type,
     p_segment19_type,
     p_segment20_type,
     p_segment21_type,
     p_segment22_type,
     p_segment23_type,
     p_segment24_type,
     p_segment25_type,
     p_segment26_type,
     p_segment27_type,
     p_segment28_type,
     p_segment29_type,
     p_segment30_type,
     p_attribute1,
     p_attribute2,
     p_attribute3,
     p_attribute4,
     p_attribute5,
     p_attribute6,
     p_attribute7,
     p_attribute8,
     p_attribute9,
     p_attribute10,
     p_context,
     p_mode);
    return;
  end if;
  close c1;

  UPDATE_ROW (
   p_api_version,
   p_init_msg_list,
   p_commit,
   p_validation_level,
   p_return_status,
   p_msg_count,
   p_msg_data,
   p_budget_group_id,
   p_name,
   p_short_name,
   p_root_budget_group,
   p_parent_budget_group_id,
   p_root_budget_group_id,
   p_ps_account_position_set_id,
   p_nps_account_position_set_id,
   p_budget_group_category_set_id,
   p_effective_start_date,
   p_effective_end_date,
   p_freeze_hierarchy_flag,
   p_description,
   p_set_of_books_id,
   p_business_group_id,
   p_num_proposed_years,
   p_narrative_description,
   p_budget_group_type,
   p_organization_id,
   p_request_id,
   p_segment1_type,
   p_segment2_type,
   p_segment3_type,
   p_segment4_type,
   p_segment5_type,
   p_segment6_type,
   p_segment7_type,
   p_segment8_type,
   p_segment9_type,
   p_segment10_type,
   p_segment11_type,
   p_segment12_type,
   p_segment13_type,
   p_segment14_type,
   p_segment15_type,
   p_segment16_type,
   p_segment17_type,
   p_segment18_type,
   p_segment19_type,
   p_segment20_type,
   p_segment21_type,
   p_segment22_type,
   p_segment23_type,
   p_segment24_type,
   p_segment25_type,
   p_segment26_type,
   p_segment27_type,
   p_segment28_type,
   p_segment29_type,
   p_segment30_type,
   p_attribute1,
   p_attribute2,
   p_attribute3,
   p_attribute4,
   p_attribute5,
   p_attribute6,
   p_attribute7,
   p_attribute8,
   p_attribute9,
   p_attribute10,
   p_context,
   p_mode);

  --
  -- Standard check of p_commit.
  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);
  --

EXCEPTION
   --
   when FND_API.G_EXC_ERROR then
     --
     rollback to ADD_ROW ;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     rollback to ADD_ROW ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     rollback to ADD_ROW ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
END ADD_ROW;

/*---------------------------------------------------------------*/

PROCEDURE DELETE_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_budget_group_id     in number,
  p_delete              OUT  NOCOPY varchar2
) AS
 cursor C1 is
	select budget_group_id,
	       short_name
	  from psb_budget_groups
	 where budget_group_type = 'R'
	 start with budget_group_id = p_budget_group_id
     connect by prior budget_group_id = parent_budget_group_id;

  l_budget_group_id     NUMBER;
  l_api_name            CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version         CONSTANT NUMBER         := 1.0;

  CURSOR c_p1 IS
     SELECT 'PSB_POSITION_ACCOUNTS'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_POSITION_ACCOUNTS
       WHERE budget_group_id = l_budget_group_id
      );
   l_p1_exists           VARCHAR2(1) := FND_API.G_FALSE;

  CURSOR c_p2 IS
     SELECT 'PSB_ACCOUNT_POSITION_SETS'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_ACCOUNT_POSITION_SETS
       WHERE budget_group_id = l_budget_group_id
      );
   l_p2_exists           VARCHAR2(1) := FND_API.G_FALSE;
  CURSOR c_p3 IS
     SELECT 'PSB_BUDGET_REVISIONS'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_BUDGET_REVISIONS
       WHERE budget_group_id = l_budget_group_id
      );
   l_p3_exists           VARCHAR2(1) := FND_API.G_FALSE;
  CURSOR c_p4 IS
     SELECT 'PSB_BUDGET_REVISION_POSITIONS'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_BUDGET_REVISION_POSITIONS
       WHERE budget_group_id = l_budget_group_id
      );
   l_p4_exists           VARCHAR2(1) := FND_API.G_FALSE;
  CURSOR c_p5 IS
     SELECT 'PSB_BUDGET_REVISION_ACCOUNTS'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_BUDGET_REVISION_ACCOUNTS
       WHERE budget_group_id = l_budget_group_id
      );
   l_p5_exists           VARCHAR2(1) := FND_API.G_FALSE;
  CURSOR c_p6 IS
     SELECT 'PSB_BUDGET_WORKFLOW_RULES'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_BUDGET_WORKFLOW_RULES
       WHERE budget_group_id = l_budget_group_id
      );
   l_p6_exists           VARCHAR2(1) := FND_API.G_FALSE;
  CURSOR c_p7 IS
     SELECT 'PSB_DATA_EXTRACTS'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_DATA_EXTRACTS
       WHERE budget_group_id = l_budget_group_id
      );
   l_p7_exists           VARCHAR2(1) := FND_API.G_FALSE;

  CURSOR c_p8 IS
     SELECT 'PSB_WS_POSITION_LINES'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_WS_POSITION_LINES
       WHERE budget_group_id = l_budget_group_id
      );
   l_p8_exists           VARCHAR2(1) := FND_API.G_FALSE;
  CURSOR c_p9 IS
     SELECT 'PSB_POSITIONS'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_POSITIONS
       WHERE budget_group_id = l_budget_group_id
      );
   l_p9_exists           VARCHAR2(1) := FND_API.G_FALSE;

  CURSOR c_p10 IS
     SELECT 'PSB_ENTITY_SET'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_ENTITY_SET
       WHERE budget_group_id = l_budget_group_id
      );
   l_p10_exists           VARCHAR2(1) := FND_API.G_FALSE;

  CURSOR c_p11 IS
     SELECT 'PSB_ENTITY'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_ENTITY
       WHERE budget_group_id = l_budget_group_id
      );
   l_p11_exists           VARCHAR2(1) := FND_API.G_FALSE;

  CURSOR c_p12 IS
     SELECT 'PSB_WS_DISTRIBUTION_RULE_LINES'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_WS_DISTRIBUTION_RULE_LINES
       WHERE budget_group_id = l_budget_group_id
      );
   l_p12_exists           VARCHAR2(1) := FND_API.G_FALSE;

  CURSOR c_p13 IS
     SELECT 'PSB_WS_DISTRIBUTION_RULES'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_WS_DISTRIBUTION_RULES
       WHERE budget_group_id = l_budget_group_id
      );
   l_p13_exists           VARCHAR2(1) := FND_API.G_FALSE;

  CURSOR c_p14 IS
     SELECT 'PSB_WS_LINE_BALANCES_I'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_WS_LINE_BALANCES_I
       WHERE budget_group_id = l_budget_group_id
      );
   l_p14_exists           VARCHAR2(1) := FND_API.G_FALSE;

  CURSOR c_p15 IS
     SELECT 'PSB_WORKSHEETS'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_WORKSHEETS
       WHERE budget_group_id = l_budget_group_id
      );
   l_p15_exists           VARCHAR2(1) := FND_API.G_FALSE;

  CURSOR c_p16 IS
     SELECT 'PSB_WS_ACCOUNT_LINES'
       FROM dual
      WHERE exists
      (SELECT 1
	FROM PSB_WS_ACCOUNT_LINES
       WHERE budget_group_id = l_budget_group_id
      );
   l_p16_exists           VARCHAR2(1) := FND_API.G_FALSE;


BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT Delete_Row;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body



  for c1rec in C1 LOOP

     l_budget_group_id := c1rec.budget_group_id;

     -- integrity check
     for c_p1_rec in c_p1 loop
       l_p1_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p1_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_POSITION_ACCOUNTS' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;

     for c_p2_rec in c_p2 loop
       l_p2_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p2_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_ACCOUNT_POSITION_SETS' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;

     for c_p3_rec in c_p3 loop
       l_p3_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p3_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_BUDGET_REVISIONS' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;

     for c_p4_rec in c_p4 loop
       l_p4_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p4_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_BUDGET_REVISION_POSITIONS' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;

     for c_p5_rec in c_p5 loop
       l_p5_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p5_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_BUDGET_REVISION_ACCOUNTS' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;

     for c_p6_rec in c_p6 loop
       l_p6_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p6_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_BUDGET_WORKFLOW_RULES' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;

     for c_p7_rec in c_p7 loop
       l_p7_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p7_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_DATA_EXTRACTS' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;

     for c_p8_rec in c_p8 loop
       l_p8_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p8_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_WS_POSITION_LINES' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;

     for c_p9_rec in c_p9 loop
       l_p9_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p9_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_POSITIONS' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;

     for c_p10_rec in c_p10 loop
       l_p10_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p10_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_ENTITY_SET' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;

     for c_p11_rec in c_p11 loop
       l_p11_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p11_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_ENTITY' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;

     for c_p12_rec in c_p12 loop
       l_p12_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p12_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_WS_DISTRIBUTION_RULE_LINES' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;

     for c_p13_rec in c_p13 loop
       l_p13_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p13_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_WS_DISTRIBUTION_RULES' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;

     for c_p14_rec in c_p14 loop
       l_p14_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p14_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_WS_LINE_BALANCES_I' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;

     for c_p15_rec in c_p15 loop
       l_p15_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p15_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_WORKSHEETS' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;

     for c_p16_rec in c_p16 loop
       l_p16_exists := FND_API.G_TRUE;
     end loop;

     IF FND_API.to_Boolean(l_p16_exists) THEN
       rollback to Delete_Row;
       message_token('TABLE','PSB_WS_ACCOUNT_LINES' );
       message_token('BUDGET_GROUP', c1rec.short_name);
       add_message('PSB', 'PSB_BG_CANNOT_BE_DELETED');
       p_delete := 'NO_DELETE';
       raise FND_API.G_EXC_ERROR;
      end if;




  -- proceed with deletion

  delete psb_budget_groups where budget_group_id = c1rec.budget_group_id;
  delete psb_budget_group_resp where budget_group_id = c1rec.budget_group_id;
  if (sql%notfound) then
   null;
  end if;
  delete psb_set_relations where budget_group_id = c1rec.budget_group_id;
  if (sql%notfound) then
   null;
  end if;
  delete psb_budget_group_categories where budget_group_id = c1rec.budget_group_id;
  if (sql%notfound) then
   null;
  end if;
  end loop;
  -- deleting top level bg
  delete psb_budget_groups where budget_group_id = p_budget_group_id;
  delete psb_budget_group_resp where budget_group_id = p_budget_group_id;
  if (sql%notfound) then
   null;
  end if;
  delete psb_set_relations where budget_group_id = p_budget_group_id;
  if (sql%notfound) then
   null;
  end if;
  delete psb_budget_group_categories where budget_group_id = p_budget_group_id;
  if (sql%notfound) then
   null;
  end if;

  p_delete := 'DELETE';
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- End of API body.

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Delete_Row;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Delete_Row;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Delete_Row;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Delete_Row;

PROCEDURE Delete_Review_Group (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,

  p_budget_group_id     in number
) AS
--
l_api_name    CONSTANT VARCHAR2(30) := 'Delete Review Group' ;
l_api_version CONSTANT NUMBER := 1.0 ;
--
BEGIN
  --
  SAVEPOINT Delete_Review_Group ;
  --
  -- Initialize message list if p_init_msg_list is set to TRUE.
  --
  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  delete from PSB_BUDGET_GROUPS
  where BUDGET_GROUP_ID = P_BUDGET_GROUP_ID;
  if (sql%notfound) then
    raise FND_API.G_EXC_ERROR ;
  end if;

  delete psb_budget_group_resp where budget_group_id = P_BUDGET_GROUP_ID;
  if (sql%notfound) then
   null;
  end if;
  --
  -- Standard check of p_commit.
  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);
  --

EXCEPTION
   --
   when FND_API.G_EXC_ERROR then
     --
     rollback to Delete_Review_Group ;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     rollback to Delete_Review_Group ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     rollback to DELETE_ROW ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --

END Delete_Review_Group;

/*---------------------------------------------------------------*/

PROCEDURE Copy_Budget_Group
( p_api_version          IN     NUMBER,
  p_init_msg_list        IN     VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN     NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_src_budget_group_id  IN     NUMBER,
  p_curr_budget_group_id IN     NUMBER,
  p_return_status        OUT  NOCOPY    VARCHAR2,
  p_msg_count            OUT  NOCOPY    NUMBER,
  p_msg_data             OUT  NOCOPY    VARCHAR2
) AS

    Cursor BG_grp_Cur Is
    select short_name
      from psb_budget_groups
     where budget_group_id = p_curr_budget_group_id ;
    Bgg_Rec  BG_grp_Cur%ROWTYPE;

  Cursor BG_resp_Cur Is
    select responsibility_id,responsibility_type
      from psb_budget_group_resp
     where budget_group_id = p_src_budget_group_id
       and responsibility_type = 'R';

    Bgr_Rec  BG_resp_Cur%ROWTYPE;

   Cursor BG_Role_Cur Is
     select wf_role_name,wf_role_orig_system,wf_role_orig_system_id,
	      responsibility_type from
	      psb_budget_group_resp
	where budget_group_id = p_src_budget_group_id
	  and responsibility_type = 'N';

     Bgw_Rec  BG_Role_Cur%ROWTYPE;


    Cursor BG_WF_Cur Is
	   select stage_id
	     from psb_budget_group_categories
	    where budget_group_id = p_src_budget_group_id;

     Bgwf_Rec  BG_WF_Cur%ROWTYPE;

    Cursor BG_SR_Cur IS
	   select name,
		  set_relation_id,
		  set_of_books_id,
		  data_extract_id,
		  global_or_local_type,
		  account_or_position_type ,
		  business_group_id ,
		  effective_start_date,
		  effective_end_date,
		  account_position_set_id,
		  attribute_selection_type,
		  use_in_budget_group_flag
	     from psb_set_relations_v
	    where budget_group_id = p_src_budget_group_id;

     Bgsr_Rec BG_SR_Cur%ROWTYPE;

    Cursor BG_AL_Cur IS
	   select
		 LINE_SEQUENCE_ID,
		 ACCOUNT_POSITION_SET_ID,
		 DESCRIPTION,
		 BUSINESS_GROUP_ID,
		 ATTRIBUTE_ID,
		 INCLUDE_OR_EXCLUDE_TYPE,
		 SEGMENT1_LOW           ,
		 SEGMENT2_LOW           ,
		 SEGMENT3_LOW           ,
		 SEGMENT4_LOW           ,
		 SEGMENT5_LOW           ,
		 SEGMENT6_LOW           ,
		 SEGMENT7_LOW           ,
		 SEGMENT8_LOW           ,
		 SEGMENT9_LOW           ,
		 SEGMENT10_LOW          ,
		 SEGMENT11_LOW          ,
		 SEGMENT12_LOW          ,
		 SEGMENT13_LOW          ,
		 SEGMENT14_LOW          ,
		 SEGMENT15_LOW          ,
		 SEGMENT16_LOW          ,
		 SEGMENT17_LOW          ,
		 SEGMENT18_LOW          ,
		 SEGMENT19_LOW          ,
		 SEGMENT20_LOW          ,
		 SEGMENT21_LOW          ,
		 SEGMENT22_LOW          ,
		 SEGMENT23_LOW          ,
		 SEGMENT24_LOW          ,
		 SEGMENT25_LOW          ,
		 SEGMENT26_LOW          ,
		 SEGMENT27_LOW          ,
		 SEGMENT28_LOW          ,
		 SEGMENT29_LOW          ,
		 SEGMENT30_LOW          ,
		 SEGMENT1_HIGH          ,
		 SEGMENT2_HIGH          ,
		 SEGMENT3_HIGH          ,
		 SEGMENT4_HIGH          ,
		 SEGMENT5_HIGH          ,
		 SEGMENT6_HIGH          ,
		 SEGMENT7_HIGH          ,
		 SEGMENT8_HIGH          ,
		 SEGMENT9_HIGH          ,
		 SEGMENT10_HIGH         ,
		 SEGMENT11_HIGH         ,
		 SEGMENT12_HIGH         ,
		 SEGMENT13_HIGH         ,
		 SEGMENT14_HIGH         ,
		 SEGMENT15_HIGH         ,
		 SEGMENT16_HIGH         ,
		 SEGMENT17_HIGH         ,
		 SEGMENT18_HIGH         ,
		 SEGMENT19_HIGH         ,
		 SEGMENT20_HIGH         ,
		 SEGMENT21_HIGH         ,
		 SEGMENT22_HIGH         ,
		 SEGMENT23_HIGH         ,
		 SEGMENT24_HIGH         ,
		 SEGMENT25_HIGH         ,
		 SEGMENT26_HIGH         ,
		 SEGMENT27_HIGH         ,
		 SEGMENT28_HIGH         ,
		 SEGMENT29_HIGH         ,
		 SEGMENT30_HIGH         ,
		 CONTEXT        ,
		 ATTRIBUTE1     ,
		 ATTRIBUTE2     ,
		 ATTRIBUTE3     ,
		 ATTRIBUTE4     ,
		 ATTRIBUTE5     ,
		 ATTRIBUTE6     ,
		 ATTRIBUTE7     ,
		 ATTRIBUTE8     ,
		 ATTRIBUTE9     ,
		 ATTRIBUTE10
	  from   PSB_ACCT_POSITION_SET_LINES_V
	 where   account_position_set_id = Bgsr_Rec.account_position_set_id;

   Bgal_Rec  BG_AL_Cur%ROWTYPE;

    l_api_name          CONSTANT VARCHAR2(30)   := 'Copy_Budget_Group';
    l_api_version         CONSTANT NUMBER       := 1.0;
    l_last_update_date    date;
    l_last_updated_by     number;
    l_last_update_login   number;
    l_creation_date       date;
    l_created_by          number;
    l_budget_group_resp_id number;
    l_budget_group_category_id number;
    l_curr_bg_short_name  Varchar2(30);
    l_set_name_seq        number := NULL;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Copy_Budget_Group;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  l_last_update_date := sysdate;
  l_last_updated_by := FND_GLOBAL.USER_ID;
  l_last_update_login :=FND_GLOBAL.LOGIN_ID;
  l_creation_date     := sysdate;
  l_created_by        := FND_GLOBAL.USER_ID;

  Open BG_grp_Cur;
  Fetch BG_grp_Cur INTO BGG_Rec;
  l_curr_bg_short_name := BGG_Rec.Short_Name;
  Close BG_grp_Cur;

  -- API body
  Begin
    Open BG_resp_Cur;

    Loop
      Fetch BG_resp_Cur INTO Bgr_Rec;

      if BG_resp_Cur%NOTFOUND then
	EXIT;
      else
	 select PSB_BUDGET_GROUP_RESP_S.NEXTVAL
	   Into l_budget_group_resp_id  from DUAL ;

	Insert into psb_budget_group_resp
	(budget_group_resp_id,
	 budget_group_id,
	 responsibility_id,
	 responsibility_type,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 created_by,
	 creation_date)
	 values
	 (
	  l_budget_group_resp_id,
	  p_curr_budget_group_id,
	  Bgr_Rec.responsibility_id,
	  Bgr_Rec.responsibility_type,
	  l_last_update_date,
	  l_last_updated_by,
	  l_last_update_login,
	  l_created_by,
	  l_creation_date);

      end if;
    end loop;
    CLOSE BG_resp_Cur ;

  end;
  begin
    Open BG_Role_Cur;

    Loop
      Fetch BG_Role_Cur INTO Bgw_Rec;

      if BG_Role_Cur%NOTFOUND then
	EXIT;
      else
	 select PSB_BUDGET_GROUP_RESP_S.NEXTVAL
	   Into l_budget_group_resp_id  from DUAL ;

	Insert into psb_budget_group_resp
	(budget_group_resp_id,
	 budget_group_id,
	 wf_role_name,
	 wf_role_orig_system,
	 wf_role_orig_system_id,
	 responsibility_type,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 created_by,
	 creation_date)
	 values
	 (
	  l_budget_group_resp_id,
	  p_curr_budget_group_id,
	  Bgw_Rec.wf_role_name,
	  Bgw_Rec.wf_role_orig_system,
	  Bgw_Rec.wf_role_orig_system_id,
	  Bgw_Rec.responsibility_type,
	  l_last_update_date,
	  l_last_updated_by,
	  l_last_update_login,
	  l_created_by,
	  l_creation_date);

      end if;
    end loop;
    CLOSE BG_Role_Cur ;

  end;

  begin
    Open BG_WF_Cur;

    Loop
      Fetch BG_WF_Cur INTO Bgwf_Rec;

      if BG_WF_Cur%NOTFOUND then
	EXIT;
      else
	 select psb_budget_group_categories_s.NEXTVAL
	   Into l_budget_group_category_id  from DUAL ;

	Insert into psb_budget_group_categories
	( budget_group_category_id     ,
	  budget_group_id   ,
	  stage_id          ,
	  last_updated_date ,
	  last_updated_by   ,
	  last_update_login ,
	  created_by        ,
	  created_date )
	  values
	  (l_budget_group_category_id,
	  p_curr_budget_group_id,
	  Bgwf_Rec.stage_id,
	  l_last_update_date,
	  l_last_updated_by,
	  l_last_update_login,
	  l_created_by,
	  l_creation_date);

      end if;
    end loop;
    Close BG_WF_Cur ;


  end;
  declare
       l_row_id         varchar2(100);
       l_row_id1        varchar2(100);
       l_return_status  varchar2(1);
       l_return_status1 varchar2(1);
       l_msg_count      number;
       l_msg_data       varchar2(2000);
       l_msg_count1     number;
       l_msg_data1      varchar2(2000);
       l_name           varchar2(100);
       l_account_position_set_id number;
       l_set_relation_id number;
       l_valid         boolean;
       l_repeat        number;
       l_count         number;


  begin
    Open BG_SR_Cur;

    Loop
      Fetch BG_SR_Cur INTO Bgsr_Rec;

      if BG_SR_Cur%NOTFOUND then
	EXIT;
      else
       -- initialize
       l_account_position_set_id := NULL;

       -- get set name

       l_name   := l_curr_bg_short_name;
       l_valid  := FALSE;
       l_repeat := 0;

       loop
	 l_repeat := nvl(l_repeat,0) + 1;
	 exit when l_repeat > 10 ;
	 select count(*) INTO l_count
	   from   psb_account_position_sets
	   where  name = l_name
	     and  account_or_position_type = 'A'
	     and  global_or_local_type = 'G' ;

	 if l_count = 0 then
	   l_valid := TRUE;
	   EXIT;
	 else
	   l_set_name_seq := nvl(l_set_name_seq,0) + 1;
	   l_name   := l_curr_bg_short_name || l_set_name_seq ;
	 end if;

       end loop ; -- end test of set name

       if not l_valid then
--        debug('not to be updated');
	  EXIT;
       end if;


       PSB_Account_Position_Set_PVT.Insert_Row
       (
	    p_api_version              => 1.0,
	    p_init_msg_list            => FND_API.G_TRUE,
	    p_commit                   => FND_API.G_FALSE,
	    p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
	    p_return_status            => l_return_status,
	    p_msg_count                => l_msg_count,
	    p_msg_data                 => l_msg_data,
	    p_row_id                   => l_row_id,
	    p_account_position_set_id  => l_account_position_set_id,
	    p_name                     => l_name,
	    p_set_of_books_id          => Bgsr_Rec.set_of_books_id,
	    p_data_extract_id          => Bgsr_Rec.data_extract_id,
	    p_global_or_local_type     => Bgsr_Rec.Global_or_Local_Type,
	    p_account_or_position_type => Bgsr_Rec.account_or_position_type,
	    p_attribute_selection_type => Bgsr_Rec.attribute_selection_type,
	    p_business_group_id        => Bgsr_Rec.business_group_id,
	    p_last_update_date         => l_last_update_date,
	    p_last_updated_by          => l_last_updated_by,
	    p_last_update_login        => l_last_update_login,
	    p_created_by               => l_created_by,
	    p_creation_date            => l_creation_date,
	    p_use_in_budget_group_flag => Bgsr_Rec.use_in_budget_group_flag
      );

     if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      --
	FND_MSG_PUB.Get( p_msg_index     => 1  ,
			 p_encoded       => FND_API.G_FALSE     ,
			 p_data          => l_msg_data          ,
			 p_msg_index_out => l_msg_count
		       );
      --debug(l_msg_data);
     end if;
     l_set_relation_id := NULL;

      PSB_Set_Relation_PVT.Insert_Row
      (
	 p_api_version              => 1.0,
	 p_init_msg_list            => FND_API.G_TRUE,
	 p_commit                   => FND_API.G_FALSE,
	 p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status            => l_return_status1,
	 p_msg_count                => l_msg_count1,
	 p_msg_data                 => l_msg_data1,
	 p_Row_Id                   => l_row_id1,
	 p_Set_Relation_Id          => l_set_relation_id,
	 p_Account_Position_Set_Id  => l_account_position_set_id,
	 p_Allocation_Rule_Id      => null,
	 p_Budget_Group_Id         => p_curr_budget_group_id,
	 p_Budget_Workflow_Rule_Id => null,
	 p_Constraint_Id           => null,
	 p_Default_Rule_Id         => null,
	 p_Parameter_Id            => null,
	 p_Position_Set_Group_Id   => null,
/* Budget Revision Rules Enhancement Start */
	 p_rule_id                 => null,
	 p_apply_balance_flag      => null,
/* Budget Revision Rules Enhancement End */
	 p_Effective_Start_Date    => Bgsr_Rec.effective_start_date,
	 p_Effective_End_Date      => BGsr_Rec.effective_end_date,
	 p_last_update_date        => l_last_update_date,
	 p_last_updated_by         => l_last_updated_by,
	 p_last_update_login       => l_last_update_login,
	 p_created_by              => l_created_by,
	 p_creation_date           => l_creation_date
   );

     if l_return_status1 <> FND_API.G_RET_STS_SUCCESS then
      --
       FND_MSG_PUB.Get( p_msg_index     => 1  ,
			p_encoded       => FND_API.G_FALSE     ,
			p_data          => l_msg_data1         ,
			p_msg_index_out => l_msg_count1
		      );
       --debug(l_msg_data1);
     end if;

    declare
       l_row_id2        varchar2(100);
       l_return_status2 varchar2(1);
       l_msg_count2     number;
       l_msg_data2      varchar2(2000);
       l_line_sequence_id number;

     begin
     if NOT (BG_AL_Cur%ISOPEN) then
	Open BG_AL_Cur;
     end if;

     Loop
      Fetch BG_AL_Cur INTO Bgal_Rec;

      if BG_AL_Cur%NOTFOUND then
	EXIT;
      else
      l_line_sequence_id := NULL;

      PSB_Acct_Pos_Set_Line_I_PVT.Insert_Row
      (
	  p_api_version              => 1.0,
	  p_init_msg_list            => FND_API.G_TRUE,
	  p_commit                   => FND_API.G_FALSE,
	  p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
	  p_return_status            => l_return_status2,
	  p_msg_count                => l_msg_count2,
	  p_msg_data                 => l_msg_data2,
	  p_Row_Id                   => l_row_id2,
	  p_line_sequence_id         => l_line_sequence_id,
	  p_account_position_set_id  => l_account_position_set_id,
	  p_description              => Bgal_Rec.description,
	  p_business_group_id        => Bgal_Rec.business_group_id,
	  p_attribute_id             => Bgal_Rec.attribute_id,
	  p_include_or_exclude_type  => Bgal_Rec.include_or_exclude_type,
	  p_segment1_low             => Bgal_Rec.segment1_low,
	  p_segment2_low             => Bgal_Rec.segment2_low,
	  p_segment3_low             => Bgal_Rec.segment3_low,
	  p_segment4_low             => Bgal_Rec.segment4_low,
	  p_segment5_low             => Bgal_Rec.segment5_low ,
	  p_segment6_low             => Bgal_Rec.segment6_low,
	  p_segment7_low             => Bgal_Rec.segment7_low,
	  p_segment8_low             => Bgal_Rec.segment8_low,
	  p_segment9_low             => Bgal_Rec.segment9_low,
	  p_segment10_low            => Bgal_Rec.segment10_low,
	  p_segment11_low            => Bgal_Rec.segment11_low,
	  p_segment12_low            => Bgal_Rec.segment12_low,
	  p_segment13_low            => Bgal_Rec.segment13_low,
	  p_segment14_low            => Bgal_Rec.segment14_low,
	  p_segment15_low            => Bgal_Rec.segment15_low,
	  p_segment16_low            => Bgal_Rec.segment16_low,
	  p_segment17_low            => Bgal_Rec.segment17_low,
	  p_segment18_low            => Bgal_Rec.segment18_low,
	  p_segment19_low            => Bgal_Rec.segment19_low,
	  p_segment20_low            => Bgal_Rec.segment20_low,
	  p_segment21_low            => Bgal_Rec.segment21_low,
	  p_segment22_low            => Bgal_Rec.segment22_low,
	  p_segment23_low            => Bgal_Rec.segment23_low,
	  p_segment24_low            => Bgal_Rec.segment24_low,
	  p_segment25_low            => Bgal_Rec.segment25_low,
	  p_segment26_low            => Bgal_Rec.segment26_low,
	  p_segment27_low            => Bgal_Rec.segment27_low,
	  p_segment28_low            => Bgal_Rec.segment28_low,
	  p_segment29_low            => Bgal_Rec.segment29_low,
	  p_segment30_low            => Bgal_Rec.segment30_low,
	  p_segment1_high            => Bgal_Rec.segment1_high,
	  p_segment2_high            => Bgal_Rec.segment2_high,
	  p_segment3_high            => Bgal_Rec.segment3_high,
	  p_segment4_high            => Bgal_Rec.segment4_high,
	  p_segment5_high            => Bgal_Rec.segment5_high,
	  p_segment6_high            => Bgal_Rec.segment6_high,
	  p_segment7_high            => Bgal_Rec.segment7_high,
	  p_segment8_high            => Bgal_Rec.segment8_high,
	  p_segment9_high            => Bgal_Rec.segment9_high,
	  p_segment10_high           => Bgal_Rec.segment10_high,
	  p_segment11_high           => Bgal_Rec.segment11_high,
	  p_segment12_high           => Bgal_Rec.segment12_high,
	  p_segment13_high           => Bgal_Rec.segment13_high,
	  p_segment14_high           => Bgal_Rec.segment14_high,
	  p_segment15_high           => Bgal_Rec.segment15_high,
	  p_segment16_high           => Bgal_Rec.segment16_high,
	  p_segment17_high           => Bgal_Rec.segment17_high,
	  p_segment18_high           => Bgal_Rec.segment18_high,
	  p_segment19_high           => Bgal_Rec.segment19_high,
	  p_segment20_high           => Bgal_Rec.segment20_high,
	  p_segment21_high           => Bgal_Rec.segment21_high,
	  p_segment22_high           => Bgal_Rec.segment22_high,
	  p_segment23_high           => Bgal_Rec.segment23_high,
	  p_segment24_high           => Bgal_Rec.segment24_high,
	  p_segment25_high           => Bgal_Rec.segment25_high,
	  p_segment26_high           => Bgal_Rec.segment26_high,
	  p_segment27_high           => Bgal_Rec.segment27_high,
	  p_segment28_high           => Bgal_Rec.segment28_high,
	  p_segment29_high           => Bgal_Rec.segment29_high,
	  p_segment30_high           => Bgal_Rec.segment30_high,
	  p_context                  => Bgal_Rec.context,
	  p_attribute1               => Bgal_Rec.attribute1,
	  p_attribute2               => Bgal_Rec.attribute2,
	  p_attribute3               => Bgal_Rec.attribute3,
	  p_attribute4               => Bgal_Rec.attribute4,
	  p_attribute5               => Bgal_Rec.attribute5,
	  p_attribute6               => Bgal_Rec.attribute6,
	  p_attribute7               => Bgal_Rec.attribute7,
	  p_attribute8               => Bgal_Rec.attribute8,
	  p_attribute9               => Bgal_Rec.attribute9,
	  p_attribute10              => Bgal_Rec.attribute10,
	  p_last_update_date        => l_last_update_date,
	  p_last_updated_by         => l_last_updated_by,
	  p_last_update_login       => l_last_update_login,
	  p_created_by              => l_created_by,
	  p_creation_date           => l_creation_date
  );
     if l_return_status2 <> FND_API.G_RET_STS_SUCCESS then
      --
       FND_MSG_PUB.Get( p_msg_index     => 1  ,
			p_encoded       => FND_API.G_FALSE     ,
			p_data          => l_msg_data2         ,
			p_msg_index_out => l_msg_count2
		      );
       --debug(l_msg_data2);
     end if;

      end if;
    end loop;

    if BG_AL_Cur%ISOPEN then
       Close BG_AL_Cur ;
    end if ;
  end;

 end if;
 end loop;

 if BG_SR_Cur%ISOPEN then
    Close BG_SR_Cur ;
 end if ;

 end;
  -- End of API body.

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Copy_Budget_Group;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Copy_Budget_Group;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Copy_Budget_Group;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Copy_Budget_Group;

/* ----------------------------------------------------------------------- */

PROCEDURE Account_Overlap_Validation
( p_api_version          IN     NUMBER,
  p_init_msg_list        IN     VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status        OUT  NOCOPY    VARCHAR2,
  p_msg_count            OUT  NOCOPY    NUMBER,
  p_msg_data             OUT  NOCOPY    VARCHAR2,
  p_budget_group_id      IN     NUMBER
) AS

  l_api_name             CONSTANT VARCHAR2(30)  := 'Account_Overlap_Validation';
  l_api_version          CONSTANT NUMBER        := 1.0;

  -- .. budget groups for global worksheet flag
  -- .. ?? include only official WS??

  CURSOR  c_top_level_bg IS
   SELECT budget_group_id,PS_ACCOUNT_POSITION_SET_ID,
	  NPS_ACCOUNT_POSITION_SET_ID,name,chart_of_accounts_id
     FROM psb_budget_groups_v
    WHERE root_budget_group = 'Y'
      AND (((p_budget_group_id is not null) and
	    (budget_group_id = p_budget_group_id))
	  or (p_budget_group_id is null));

  l_flex_code         NUMBER;
  l_error_flag        VARCHAR2(1) := 'N';
  l_concat_segments   VARCHAR2(2000);
  l_return_status     VARCHAR2(1);

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Account_Overlap_Validation;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  /* --- S T A R T   OF   A P I  */

  FOR c_top_level_bg_rec in c_top_level_bg LOOP

    l_flex_code := c_top_level_bg_rec.chart_of_accounts_id;

      for c_Overlap_ps_Rec in c_Overlap_ps (
			   c_top_level_bg_rec.ps_account_position_set_id,
			   c_top_level_bg_rec.nps_account_position_set_id) loop

	l_error_flag := 'Y' ;
	message_token('BUDGET_GROUP', c_top_level_bg_rec.name);
	add_message('PSB', 'CCID_OVERLAP');
      end loop;

      FOR c_hier_budget_group_rec in c_BudgetGroup(c_top_level_bg_rec.budget_group_id) LOOP
		  --
	 FOR c_AccSet_Rec in c_Accset (c_hier_budget_group_rec.budget_group_id) loop
	  /*For Bug No : 2230514 Start*/
	    --g_dbug := g_dbug || g_chr10 || to_char(c_hier_budget_group_rec.budget_group_id) ;
	  /*For Bug No : 2230514 End*/
	    FOR c_Overlap_CCID_Rec in c_Overlap_CCID
				     (c_top_level_bg_rec.budget_group_id ,
				      c_hier_budget_group_rec.budget_group_id ,
				      c_AccSet_Rec.account_position_set_id ,
				      c_AccSet_Rec.effective_start_date ,
				      c_AccSet_Rec.effective_end_date) LOOP

	      l_error_flag := 'Y' ;
	      --g_dbug := g_dbug || g_chr10 ||
	      --   'overlap on budget group : ' ||
	      --    to_char(c_hier_budget_group_rec.budget_group_id);
	      l_concat_segments := FND_FLEX_EXT.Get_Segs
				(application_short_name => 'SQLGL',
				 key_flex_code => 'GL#',
				 structure_number => l_flex_code,
				 combination_id => c_Overlap_CCID_Rec.code_combination_id);

	      message_token('CCID',l_concat_segments) ;
	      message_token('ACCOUNT_SET', c_AccSet_Rec.name);
	      message_token('BUDGET_GROUP',c_hier_budget_group_rec.name);
	      message_token('TOP_BUDGET_GROUP',c_top_level_bg_rec.name);
	      add_message('PSB', 'PSB_BGH_OVERLAP_ACCOUNTS');
	     --
	   END LOOP;

     END LOOP;


	 -- .. validate ccid for each account sets


      END LOOP ;


    Validate_PSB_Accounts_And_GL
	 ( p_top_budget_group_id       => p_budget_group_id,
	   p_flex_code             => l_flex_code,
	   p_return_status             => l_return_status);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      l_error_flag := 'Y';
    end if;

  END LOOP;

  IF l_error_flag = 'Y' then

      Output_Message_To_Table(p_budget_group_id  => p_budget_group_id);

  END IF ;
  --
  /* --- */


  -- End of API body.

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then

     rollback to Account_Overlap_Validation;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Account_Overlap_Validation;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Account_Overlap_Validation;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Account_Overlap_Validation ;

/* ----------------------------------------------------------------------- */

PROCEDURE Validate_PSB_Accounts_And_GL
( p_top_budget_group_id  IN   NUMBER,
  p_flex_code            IN   NUMBER,
  p_return_status        OUT  NOCOPY  VARCHAR2
) AS

  l_concat               VARCHAR2(2000);
  l_error_flag           VARCHAR2(1) := FND_API.G_FALSE;
  l_error_count          NUMBER := 0;

  /* start bug 4030864 */
  l_count                NUMBER := 0;
  /* End bug 4030864 */

  /*For Bug No : 2519314 Start*/
  TYPE l_missing_accts_tbl  IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
  l_missing_accts l_missing_accts_tbl;
  /*For Bug No : 2519314 End*/

  /*For Bug No : 2255402 Start*/
   cursor c_Missing_Accounts IS
       select gcc.code_combination_id
	 from gl_code_combinations gcc
	where gcc.chart_of_accounts_id = p_flex_code
	  and gcc.detail_budgeting_allowed_flag = 'Y'
	  and gcc.enabled_flag = 'Y'
	  /*For Bug No : 2359795 Start*/
	  and gcc.summary_flag = 'N'
	  and gcc.template_id is null
	  /*For Bug No : 2359795 End*/
	  and not exists(select 1
			     from PSB_BUDGET_ACCOUNTS b,
			      PSB_SET_RELATIONS_V c,
				PSB_BUDGET_GROUPS d
				  where b.code_combination_id = gcc.code_combination_id
				    and b.account_position_set_id = c.account_position_set_id
			      and c.budget_group_id = d.budget_group_id
			      and (d.budget_group_id = p_top_budget_group_id or
				   d.root_budget_group_id = p_top_budget_group_id));
  /*For Bug No : 2255402 End*/

BEGIN

  /*For Bug No : 2519314 Start*/
  --following validation has been converted to BULK FETCH to reduce the fetch count
  open c_Missing_Accounts;
  loop

    fetch c_Missing_Accounts BULK COLLECT INTO l_missing_accts
			     LIMIT PSB_WS_ACCT1.g_limit_bulk_numrows;

  /* Start bug 4030864 */
  IF l_missing_accts.count > 0 THEN
    l_count := l_count + 1;
    IF l_count = 1 THEN
      DELETE PSB_ERROR_MESSAGES
      WHERE SOURCE_PROCESS = 'VALIDATE_BUDGET_HIERARCHY'
      AND process_id = p_top_budget_group_id;
    END IF;
  END IF;
  /* End bug 4030864 */

    for l_acct_index in 1..l_missing_accts.count loop

      l_concat := FND_FLEX_EXT.Get_Segs
		   (application_short_name => 'SQLGL',
		    key_flex_code => 'GL#',
		    structure_number => p_flex_code,
		    combination_id => l_missing_accts(l_acct_index));

      message_token('CCID', l_concat);
      add_message('PSB', 'PSB_MISSING_BUDGET_ACCOUNTS');

      l_error_flag := FND_API.G_TRUE;

    end loop;

    /* Start bug no 4030864 */
      IF l_missing_accts.count > 0 THEN
        l_missing_accts.delete;
        PSB_MESSAGE_S.l_batch_error_flag := true;
	PSB_MESSAGE_S.BATCH_INSERT_ERROR('VALIDATE_BUDGET_HIERARCHY',
                                     p_top_budget_group_id);

        PSB_MESSAGE_S.Print_Error ( p_mode       => FND_FILE.OUTPUT ,
				          p_print_header =>  FND_API.G_TRUE) ;

	fnd_msg_pub.initialize;
      END IF;
    /* End bug no 4030864 */

    exit when c_Missing_Accounts%NOTFOUND;

  end loop;
  close c_Missing_Accounts;
  /*For Bug No : 2519314 End*/

  if FND_API.to_Boolean(l_error_flag) then
    raise FND_API.G_EXC_ERROR;
  end if;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      if c_Missing_Accounts%ISOPEN then
	close c_Missing_Accounts;
      end if;
      p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
      if c_Missing_Accounts%ISOPEN then
	close c_Missing_Accounts;
      end if;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      if c_Missing_Accounts%ISOPEN then
	close c_Missing_Accounts;
      end if;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--
END Validate_PSB_Accounts_And_GL;


/* ----------------------------------------------------------------------- */

PROCEDURE Validate_BGCCID_vs_PS_NPS
( p_top_budget_group_id  IN   NUMBER,
  p_flex_code            IN   NUMBER,
  p_ps_account_set_id    IN   NUMBER,
  p_nps_account_set_id   IN   NUMBER,
  p_return_status        OUT  NOCOPY  VARCHAR2
) AS

  l_concat               VARCHAR2(2000);
  l_error_flag           VARCHAR2(1) := FND_API.G_FALSE;
  l_error_count          NUMBER := 0;

   cursor c_Missing_Accounts IS
       SELECT a.code_combination_id ccid,b.name bg_name ,s.name set_name
	 FROM psb_budget_accounts a,
	      psb_set_relations_v s,
	      psb_budget_groups_v b
	WHERE b.budget_group_id = s.budget_group_id
	  AND b.budget_group_type = 'R'
	  AND nvl(b.root_budget_group_id, b.budget_group_id) = p_top_budget_group_id
	  AND  s.account_position_set_id = a.account_position_set_id
	  AND NOT EXISTS
	    (SELECT z.code_combination_id from psb_budget_accounts z
	     WHERE z.account_position_set_id in (p_ps_account_set_id, p_nps_account_set_id)
	       AND a.code_combination_id = z.code_combination_id);

BEGIN

  for c_Missing_Accounts_Rec in c_Missing_Accounts loop

    l_concat := FND_FLEX_EXT.Get_Segs
		   (application_short_name => 'SQLGL',
		    key_flex_code => 'GL#',
		    structure_number => p_flex_code,
		    combination_id => c_Missing_Accounts_Rec.ccid);

    message_token('CCID', l_concat);
    message_token('ACCSET', c_Missing_Accounts_Rec.set_name);
    message_token('BGID', c_Missing_Accounts_Rec.set_name);
    add_message('PSB', 'PSB_CCID_NOT_IN_PS_NPS');

    l_error_flag := FND_API.G_TRUE;

  end loop;

  if FND_API.to_Boolean(l_error_flag) then
    raise FND_API.G_EXC_ERROR;
  end if;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--
END Validate_BGCCID_vs_PS_NPS;

--++ procedure is called by api needing a validation of organization for budget group hier

PROCEDURE Validate_Budget_Group_Org
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_top_budget_group_id   IN   NUMBER
) AS

  l_api_name          CONSTANT VARCHAR2(30) := 'Validate_Budget_Group_Org';
  l_api_version       CONSTANT NUMBER       := 1.0;
  l_return_status VARCHAR2(1);



BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  Validate_BG_ORGANIZATION(p_top_budget_group_id => p_top_budget_group_id,
			   p_return_status       => l_return_status);

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    raise FND_API.G_EXC_ERROR;
  END IF;

  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data => p_msg_data);


  -- Initialize API Return Status to Success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
	(p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data => p_msg_data);

END Validate_Budget_Group_Org;

PROCEDURE Validate_BG_ORGANIZATION
( p_top_budget_group_id  IN   NUMBER,
  p_return_status        OUT  NOCOPY  VARCHAR2
) AS

  l_error_flag           VARCHAR2(1) := FND_API.G_FALSE;
  l_error_count          NUMBER := 0;


   cursor c_Missing_org IS
       SELECT budget_group_id ,short_name
	 FROM psb_budget_groups_v
	WHERE budget_group_type = 'R'
	  AND nvl(root_budget_group_id, budget_group_id) =
	      p_top_budget_group_id
	      AND organization_id is null;
   cursor c_Missing_Top_org IS
       SELECT budget_group_id, short_name
	 FROM psb_budget_groups_v
	WHERE budget_group_type = 'R'
	  AND budget_group_id = p_top_budget_group_id
	      AND business_group_id is null;


   cursor c_Invalid_ORG IS
       SELECT budget_group_id, bg.short_name
	 FROM psb_budget_groups_v bg
	WHERE budget_group_type = 'R'
	  AND root_budget_group_id = p_top_budget_group_id
	  AND nvl(root_budget_group,'N') = 'N'
	  and not exists
	  (select 'exists' from per_organization_units
	   where organization_id = bg.organization_id and
		 business_group_id = bg.root_business_group_id);


BEGIN

  for c_Missing_Org_Rec in c_Missing_Org loop

    message_token('BG_NAME', c_Missing_Org_Rec.short_name);
    add_message('PSB', 'PSB_BG_MISSING_ORG');
    l_error_flag := FND_API.G_TRUE;

  end loop;

  for c_Missing_Top_org_rec in c_Missing_Top_org loop

    message_token('BGNAME', c_Missing_Top_Org_Rec.short_name);
    add_message('PSB', 'PSB_BG_TOPBG_MISSING_ORG');

    l_error_flag := FND_API.G_TRUE;

  end loop;

  for c_Invalid_Org_Rec in c_Invalid_Org  loop

    message_token('BGNAME', c_Invalid_Org_Rec.short_name);
    add_message('PSB', 'PSB_BG_INVALID_ORG');

    l_error_flag := FND_API.G_TRUE;

  end loop;

  if FND_API.to_Boolean(l_error_flag) then
    raise FND_API.G_EXC_ERROR;
  end if;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
--
END Validate_BG_ORGANIZATION ;

/* ----------------------------------------------------------------------- */

-- Add Token and Value to the Message Token array

PROCEDURE message_token(tokname IN VARCHAR2,
			tokval  IN VARCHAR2) AS

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
		      msgname IN VARCHAR2) AS

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

PROCEDURE Output_Message_To_Table(p_budget_group_id IN NUMBER) AS

   l_reqid NUMBER;
   l_rep_req_id NUMBER;
   l_userid NUMBER;
   l_msg_count NUMBER;
   l_msg_buf varchar2(1000);

  /* Start bug no 4030864 */
  l_max_sequence_number NUMBER := 0;
  /* End bug no 4030864 */


BEGIN
   /* Start bug no 4030864 */
   IF PSB_MESSAGE_S.l_batch_error_flag = FALSE THEN
     delete from PSB_ERROR_MESSAGES
     where source_process = 'VALIDATE_BUDGET_HIERARCHY'
     and process_id = p_budget_group_id;
   END IF;
   /* End bug no 4030864 */


   l_reqid  := FND_GLOBAL.CONC_REQUEST_ID;
   l_userid := FND_GLOBAL.USER_ID;

   FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			       p_data  => l_msg_buf );

  /* Start bug no 4030864 */
  -- performance bug
   IF PSB_MESSAGE_S.l_batch_error_flag = FALSE THEN
     PSB_MESSAGE_S.Insert_Error ( p_source_process => 'VALIDATE_BUDGET_HIERARCHY',
				  p_process_id     => p_budget_group_id,
				  p_msg_count      => l_msg_count,
				  p_msg_data       => l_msg_buf,
				  p_desc_sequence  => FND_API.G_TRUE) ;
   ELSE
     PSB_MESSAGE_S.BATCH_INSERT_ERROR ( p_source_process => 'VALIDATE_BUDGET_HIERARCHY',
					p_process_id     => p_budget_group_id);

     -- end of session
     FOR l_max_seq_rec IN (
       SELECT max(sequence_number) + 1 max_seq
       FROM psb_error_messages
       WHERE process_id = p_budget_group_id
       AND source_process = 'VALIDATE_BUDGET_HIERARCHY')
     LOOP
       l_max_sequence_number := l_max_seq_rec.max_seq;
     END LOOP;

     IF l_max_sequence_number > 0 THEN
       UPDATE psb_error_messages
       SET sequence_number = (l_max_sequence_number - sequence_number)
       WHERE process_id = p_budget_group_id
       AND source_process = 'VALIDATE_BUDGET_HIERARCHY';
     END IF;
   END IF;
  /* End bug no 4030864 */

   -- submit concurrent request for error report
   l_rep_req_id := Fnd_Request.Submit_Request
		       (application   => 'PSB'                          ,
			program       => 'PSBRPERR'                     ,
			description   => 'Validate Budget Group Error Report',
			start_time    =>  NULL                          ,
			sub_request   =>  FALSE                         ,
			argument1     =>  'Validate_Budget_Hierarchy',
			argument2     =>  p_budget_group_id,
			argument3     =>  l_reqid
		      );
   --
   if l_rep_req_id = 0 then
   --
	  fnd_message.set_name('PSB', 'PSB_FAIL_TO_SUBMIT_REQUEST');
   --
   end if;
   --
   -- initialize error message stack --
      FND_MSG_PUB.initialize;

END  Output_Message_To_Table;


/* ----------------------------------------------------------------------- */
-- C O N C U R R E N T   R E Q U E S T S
/* ----------------------------------------------------------------------- */


/*===========================================================================+
 |                   PROCEDURE Val Budget Group Hierarchy CP           |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program
-- Val Budget Group Hierarchy CP through Standard Report Submissions.
--
PROCEDURE Val_Budget_Group_Hierarchy_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_budget_group_id           IN       NUMBER  ,
  p_force_freeze              IN       VARCHAR2
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Val_Budget_Group_Hierarchy_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  --
BEGIN
  --

  PSB_BUDGET_GROUPS_PVT.Val_Budget_Group_Hierarchy
     (p_api_version   => 1.0,
      p_init_msg_list => FND_API.G_TRUE,
      p_commit        => FND_API.G_TRUE,
      p_return_status => l_return_status,
      p_msg_count     => l_msg_count,
      p_msg_data      => l_msg_data,
      p_budget_group_id => p_budget_group_id,
      p_force_freeze    => p_force_freeze);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.OUTPUT ,
				  p_print_header =>  FND_API.G_TRUE) ;
      raise FND_API.G_EXC_ERROR;
  elsif (l_msg_count > 0) THEN
    -- informational  message
      PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.OUTPUT ,
				  p_print_header =>  FND_API.G_FALSE) ;

      /* Start Bug No. 2322856 */
--    PSB_MESSAGE_S.Print_Success;
      /* End Bug No. 2322856 */
    retcode := 0 ;

  else
    -- a success
      /* Start Bug No. 2322856 */
--    PSB_MESSAGE_S.Print_Success;
      /* End Bug No. 2322856 */
    retcode := 0 ;
    --debug('The program completed successfully');
  end if;

  --
  COMMIT WORK;
  --
EXCEPTION
  --

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE ) ;
     retcode := 2 ;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE ) ;
     retcode := 2 ;
     --

   WHEN OTHERS THEN
     --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
       --
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
				l_api_name  ) ;
     END IF ;
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE ) ;
     retcode := 2 ;
     --
END Val_Budget_Group_Hierarchy_CP ;


/* ----------------------------------------------------------------------- */


/*===========================================================================+
 |                   PROCEDURE Delete Row CP                           |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program  Create Budget Journal
-- through Standard Report Submissions.
--
PROCEDURE DELETE_ROW_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_budget_group_id           IN       NUMBER
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'DELETE_ROW_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  l_delete                  VARCHAR(20) ;
  --
BEGIN
  --

  PSB_BUDGET_GROUPS_PVT.DELETE_ROW
     (p_api_version => 1.0,
      p_init_msg_list => FND_API.G_TRUE,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_budget_group_id => p_budget_group_id,
      p_delete          => l_delete);


  if l_delete <> 'DELETE' THEN
    FND_FILE.put_line(FND_FILE.LOG,'The Budget Group Cannot Be Deleted');
    raise FND_API.G_EXC_ERROR;
  end if;


  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
    /* Start Bug No. 2322856 */
--  PSB_MESSAGE_S.Print_Success;
    /* End Bug No. 2322856 */
  retcode := 0 ;
  --
  COMMIT WORK;
  --
EXCEPTION
  --

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE ) ;
     retcode := 2 ;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE ) ;
     retcode := 2 ;
     --
   WHEN OTHERS THEN
     --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
       --
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
				l_api_name  ) ;
     END IF ;
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE ) ;
     retcode := 2 ;
    --
END Delete_Row_CP ;

/*===========================================================================+
 |                   PROCEDURE Account Overlap Validation CP                 |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program
-- Account Overlap Validation CP through Standard Report Submissions.
--
PROCEDURE Account_Overlap_Validation_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_budget_group_id           IN       NUMBER
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Account_Overlap_Validation_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  --
BEGIN
  --
 PSB_BUDGET_GROUPS_PVT.Account_Overlap_Validation
     (p_api_version   => 1.0,
      p_init_msg_list => FND_API.G_TRUE,
      p_return_status => l_return_status,
      p_msg_count     => l_msg_count,
      p_msg_data      => l_msg_data,
      p_budget_group_id => p_budget_group_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  elsif (l_msg_count > 0) THEN
    -- informational message --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.OUTPUT ,
				p_print_header =>  FND_API.G_FALSE) ;

    /* Start Bug No. 2322856 */
--    PSB_MESSAGE_S.Print_Success;
    /* End Bug No. 2322856 */
    retcode := 0 ;
  else
    -- successful msg --
      /* Start Bug No. 2322856 */
--    PSB_MESSAGE_S.Print_Success;
      /* End Bug No. 2322856 */
    retcode := 0 ;
  end if;

  --
  COMMIT WORK;
  --
EXCEPTION
  --

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE ) ;
     retcode := 2 ;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE ) ;
     retcode := 2 ;
     --
   WHEN OTHERS THEN
    --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
       FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
    --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE ) ;
    retcode := 2 ;
    --
END Account_Overlap_Validation_CP ;


/* ----------------------------------------------------------------------- */

-- Get Debug Information

-- This Module is used to retrieve Debug Information for this Package. It
-- prints Debug Information when run as a Batch Process from SQL*Plus. For
-- the Debug Information to be printed on the Screen, the SQL*Plus parameter
-- 'Serveroutput' should be set to 'ON'

/*For Bug No : 2230514 Start*/
/*
FUNCTION get_debug RETURN VARCHAR2 AS

BEGIN

  return(g_dbug);

END get_debug;
*/
/*For Bug No : 2230514 End*/
/* ----------------------------------------------------------------------- */


END PSB_BUDGET_GROUPS_PVT;

/
