--------------------------------------------------------
--  DDL for Package Body PSB_POSITION_CONTROL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_POSITION_CONTROL_PVT" AS
/* $Header: PSBVWPCB.pls 120.30.12010000.6 2010/04/30 12:29:17 rkotha ship $ */

  G_PKG_NAME CONSTANT          VARCHAR2(30):= 'PSB_POSITION_CONTROL_PVT';

  -- for bug 4507389
  g_year_start_date			   DATE;
  g_year_end_date			   DATE;
  -- for bug 4507389

  /* start bug 4545590 */
  g_wks_no_date_overlap			BOOLEAN:= FALSE; --bug:6004284:assigned false
  g_wks_new_hr_budget			BOOLEAN;
  /* end bug 4545590 */

  /*bug:7037138:start*/
   g_data_extract_id         NUMBER;
   g_start_date              DATE;
   g_end_date                DATE;
   g_gl_flex_code            NUMBER;
   g_system_data_extract_id  NUMBER;
   g_hr_budget_id            NUMBER;

  TYPE g_char_arr IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
  TYPE g_flag_arr IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
  TYPE g_id_arr IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE g_num_arr IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE g_date_arr IS TABLE OF DATE INDEX BY BINARY_INTEGER;

  g_segment1           g_char_arr;
  g_segment2           g_char_arr;
  g_segment3           g_char_arr;
  g_segment4           g_char_arr;
  g_segment5           g_char_arr;
  g_segment6           g_char_arr;
  g_segment7           g_char_arr;
  g_segment8           g_char_arr;
  g_segment9           g_char_arr;
  g_segment10          g_char_arr;
  g_segment11          g_char_arr;
  g_segment12          g_char_arr;
  g_segment13          g_char_arr;
  g_segment14          g_char_arr;
  g_segment15          g_char_arr;
  g_segment16          g_char_arr;
  g_segment17          g_char_arr;
  g_segment18          g_char_arr;
  g_segment19          g_char_arr;
  g_segment20          g_char_arr;
  g_segment21          g_char_arr;
  g_segment22          g_char_arr;
  g_segment23          g_char_arr;
  g_segment24          g_char_arr;
  g_segment25          g_char_arr;
  g_segment26          g_char_arr;
  g_segment27          g_char_arr;
  g_segment28          g_char_arr;
  g_segment29          g_char_arr;
  g_segment30          g_char_arr;
  g_ccid               g_id_arr;
  g_dist_percent       g_num_arr;
  g_pay_element_id     g_id_arr;
  g_follow_salary      g_flag_arr;
  g_pay_element_name   g_char_arr;
  g_hr_position_id     g_num_arr;

  g_budget_set_id      g_num_arr;
  g_pos_id             g_num_arr;
  g_period_start_date  g_date_arr;
  g_period_end_date    g_date_arr;
  g_budget_set_cost    g_num_arr;

  TYPE g_hr_pos_details_rec IS RECORD
  (
    hr_position_id     NUMBER,
    start_index        NUMBER,
    end_index          NUMBER
   );

   TYPE g_hr_pos_details_tab_type IS TABLE OF g_hr_pos_details_rec INDEX BY BINARY_INTEGER;
   g_hr_pos_details_tab    g_hr_pos_details_tab_type;
   g_pos_details_tab       g_hr_pos_details_tab_type;

  g_hr_pos_id      g_num_arr;
  g_pd_start_date  g_date_arr;
  g_pd_end_date    g_date_arr;
  g_pd_fte            g_num_arr;
  g_pd_cost           g_num_arr;

  g_period_ind_tbl   g_hr_pos_details_tab_type;

  /*bug:7037138:end*/



  TYPE g_fte_rec_type IS RECORD
     ( position_fte_line_id  NUMBER,
       position_id           NUMBER,
       start_date            DATE,
       end_date              DATE,
       fte                   NUMBER,
       budget_revision_id    NUMBER,
       base_line_version     VARCHAR2(1),
       delete_flag           BOOLEAN);

  TYPE g_costs_rec_type IS RECORD
     ( position_element_line_id  NUMBER,
       position_id               NUMBER,
       pay_element_id            NUMBER,
       start_date                DATE,
       end_date                  DATE,
       currency_code             VARCHAR2(15),
       element_cost              NUMBER,
       budget_revision_id        NUMBER,
       base_line_version         VARCHAR2(1),
       delete_flag               BOOLEAN);

  TYPE g_accounts_rec_type IS RECORD
     ( position_account_line_id  NUMBER,
       position_id               NUMBER,
       start_date                DATE,
       end_date                  DATE,
       code_combination_id       NUMBER,
       budget_group_id           NUMBER,
       currency_code             VARCHAR2(15),
       amount                    NUMBER,
       budget_revision_id        NUMBER,
       base_line_version         VARCHAR2(1),
       delete_flag               BOOLEAN);

  TYPE g_fte_tbl_type IS TABLE OF g_fte_rec_type
     INDEX BY BINARY_INTEGER;

  TYPE g_costs_tbl_type IS TABLE OF g_costs_rec_type
     INDEX BY BINARY_INTEGER;

  TYPE g_accounts_tbl_type IS TABLE OF g_accounts_rec_type
     INDEX BY BINARY_INTEGER;

  TYPE g_map_rec_type IS RECORD
    (gl_segment_name       VARCHAR2(30),
     cost_segment_name     VARCHAR2(30),
     segment_value         VARCHAR2(100));

  TYPE g_map_tbl_type IS TABLE OF g_map_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE g_element_cost_rec_type IS RECORD
     ( budget_set_id           NUMBER,
       pay_element_id          NUMBER,
       element_cost            NUMBER );

  TYPE g_element_cost_tbl_type IS TABLE OF g_element_cost_rec_type
      INDEX BY BINARY_INTEGER;

  g_element_costs              g_element_cost_tbl_type;
  g_num_element_costs          NUMBER;

  TYPE g_element_dist_rec_type IS RECORD
    ( pay_element_id NUMBER,
      ccid           NUMBER,
      percent        NUMBER );

  TYPE g_element_dist_tbl_type IS TABLE OF g_element_dist_rec_type
      INDEX BY BINARY_INTEGER;

  g_element_dists              g_element_dist_tbl_type;
  g_num_element_dists          NUMBER;

  TYPE g_budgetset_dist_rec_type IS RECORD
    ( budget_set_id  NUMBER,
      ccid           NUMBER,
      amount         NUMBER,
      percent        NUMBER );

  TYPE g_budgetset_dist_tbl_type IS TABLE OF g_budgetset_dist_rec_type
      INDEX BY BINARY_INTEGER;

  g_budgetset_dists            g_budgetset_dist_tbl_type;
  g_num_budgetset_dists        NUMBER;

  g_fte                        g_fte_tbl_type;
  g_num_fte                    NUMBER;

  g_costs                      g_costs_tbl_type;
  g_num_costs                  NUMBER;

  g_accounts                   g_accounts_tbl_type;
  g_num_accounts               NUMBER;

  g_map_tab                    g_map_tbl_type;

  -- Added for Bug#2434152
  g_map_str                    VARCHAR2(8000);

  /* bug no 3670254 */
  -- These global variables will have the
  -- profile and attribute id values
  g_hrms_fte_upload_option     VARCHAR2(30);
  g_fte_attribute_id	       NUMBER;
  /* bug no 3670254 */

  -- TokNameArray contains names of all tokens
  TYPE TokNameArray IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

  -- TokValArray contains values for all tokens
  TYPE TokValArray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

  -- For Message Tokens
  no_msg_tokens                NUMBER := 0;
  msg_tok_names                TokNameArray;
  msg_tok_val                  TokValArray;

  /* bug no 3670254 */
  -- cursor for getting last active assignment FTE
  -- cursor used in API's create_pqh_budget_version
  -- and create_pqh_budget_detail to fetch FTE.
  CURSOR g_ass_fte_csr (c_data_extract_id       IN  NUMBER ,
                        c_position_id           IN  NUMBER ,
                        c_worksheet_id          IN  NUMBER ,
                        c_attribute_id          IN  NUMBER ,
                        c_budget_year_end_date  IN  DATE
                       ) IS
  SELECT ppf.attribute_Value
  FROM   psb_position_assignments ppf
  WHERE  ppf.data_extract_id = c_data_extract_id
  AND    ppf.position_id = c_position_id
  AND    nvl(worksheet_id, -1)  = nvl(c_worksheet_id, -1)
  AND    ppf.attribute_id = c_attribute_Id
  AND    c_budget_year_end_date BETWEEN effective_start_date AND
                                nvl(effective_end_date, c_budget_year_end_date);
  /* bug no 3670254 */


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


/* ----------------------------------------------------------------------- */

/*For Bug No : 1822364 Start*/
-- Upload Element Position Set Groups
PROCEDURE Copy_Position_Set_Groups
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_old_pay_element_id      IN   NUMBER,
  p_new_pay_element_id      IN   NUMBER,
  p_target_data_extract_id  IN   NUMBER,
  p_budget_group_id         IN   NUMBER,
  p_flex_mapping_set_id     IN   NUMBER,
  p_follow_salary           IN   VARCHAR2
);


/*-------------------------------------------------------------------------*/
-- Upload Position Sets that belong to Position set group

PROCEDURE Copy_Position_Sets
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_old_psg_id              IN   NUMBER,
  p_new_psg_id              IN   NUMBER,
  p_target_data_extract_id  IN   NUMBER,
  p_budget_group_id         IN   NUMBER
);

/*-------------------------------------------------------------------------*/

PROCEDURE Copy_Position_Set_Lines
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_old_posset_id           IN   NUMBER,
  p_new_posset_id           IN   NUMBER,
  p_target_data_extract_id  IN   NUMBER
);

/* ------------------------------------------------------------------------*/

PROCEDURE Copy_Element_Distributions
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_old_psg_id              IN   NUMBER,
  p_new_psg_id              IN   NUMBER,
  p_flex_mapping_set_id     IN   NUMBER,
  p_follow_salary           IN   VARCHAR2
);

/*-------------------------------------------------------------------------*/
/*For Bug No : 1822364 End*/


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

PROCEDURE Upload_Attribute_Values
( p_return_status             OUT  NOCOPY  VARCHAR2,
  p_source_data_extract_id    IN   NUMBER,
  p_source_business_group_id  IN   NUMBER,
  p_target_data_extract_id    IN   NUMBER
) IS

  l_attrval_already_exists    BOOLEAN;

  l_attribute_value_id        NUMBER;

  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_rowid                     ROWID;

  l_return_status             VARCHAR2(1);

  cursor c_attrval_seq is
    select PSB_ATTRIBUTE_VALUES_S.NEXTVAL seq
      from dual;

  cursor c_attrval is
    select *
      from PSB_ATTRIBUTE_VALUES a
     where data_extract_id = p_source_data_extract_id
       and exists
	  (select 1 from PSB_ATTRIBUTES_VL b
	    where b.attribute_id = a.attribute_id
	      and b.business_group_id = p_source_business_group_id)
       and attribute_value is not null;

  cursor c_attrval_exists (attrid NUMBER, attrval VARCHAR2) is
    select attribute_value_id
      from PSB_ATTRIBUTE_VALUES
     where attribute_value = attrval
       and attribute_id = attrid
       and data_extract_id = p_target_data_extract_id;

BEGIN

  -- Upload attribute values if required

  for c_attrval_rec in c_attrval loop

    l_attrval_already_exists := FALSE;

    -- Check if attribute value is already defined for target data extract

    for c_attrval_exists_rec in c_attrval_exists (c_attrval_rec.attribute_id, c_attrval_rec.attribute_value) loop
      l_attribute_value_id := c_attrval_exists_rec.attribute_value_id;
      l_attrval_already_exists := TRUE;
    end loop;

    if not l_attrval_already_exists then
    begin

      for c_attrval_seq_rec in c_attrval_seq loop
	l_attribute_value_id := c_attrval_seq_rec.seq;
      end loop;

      PSB_ATTRIBUTE_VALUES_PVT.Insert_Row
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_rowid => l_rowid,
	  p_attribute_value_id => l_attribute_value_id,
	  p_attribute_id => c_attrval_rec.attribute_id,
	  p_attribute_value => c_attrval_rec.attribute_value,
	  p_description => c_attrval_rec.description,
	  p_hr_value_id => c_attrval_rec.hr_value_id,
	  p_data_extract_id => p_target_data_extract_id,
	  p_attribute1 => c_attrval_rec.attribute1,
	  p_attribute2 => c_attrval_rec.attribute2,
	  p_attribute3 => c_attrval_rec.attribute3,
	  p_attribute4 => c_attrval_rec.attribute4,
	  p_attribute5 => c_attrval_rec.attribute5,
	  p_attribute6 => c_attrval_rec.attribute6,
	  p_attribute7 => c_attrval_rec.attribute7,
	  p_attribute8 => c_attrval_rec.attribute8,
	  p_attribute9 => c_attrval_rec.attribute9,
	  p_attribute10 => c_attrval_rec.attribute10,
	  p_attribute11 => c_attrval_rec.attribute11,
	  p_attribute12 => c_attrval_rec.attribute12,
	  p_attribute13 => c_attrval_rec.attribute13,
	  p_attribute14 => c_attrval_rec.attribute14,
	  p_attribute15 => c_attrval_rec.attribute15,
	  p_attribute16 => c_attrval_rec.attribute16,
	  p_attribute17 => c_attrval_rec.attribute17,
	  p_attribute18 => c_attrval_rec.attribute18,
	  p_attribute19 => c_attrval_rec.attribute19,
	  p_attribute20 => c_attrval_rec.attribute20,
	  p_attribute21 => c_attrval_rec.attribute21,
	  p_attribute22 => c_attrval_rec.attribute22,
	  p_attribute23 => c_attrval_rec.attribute23,
	  p_attribute24 => c_attrval_rec.attribute24,
	  p_attribute25 => c_attrval_rec.attribute25,
	  p_attribute26 => c_attrval_rec.attribute26,
	  p_attribute27 => c_attrval_rec.attribute27,
	  p_attribute28 => c_attrval_rec.attribute28,
	  p_attribute29 => c_attrval_rec.attribute29,
	  p_attribute30 => c_attrval_rec.attribute30,
	  p_context => c_attrval_rec.context,
	  p_last_update_date => sysdate,
	  p_last_updated_by => FND_GLOBAL.USER_ID,
	  p_last_update_login => FND_GLOBAL.LOGIN_ID,
	  p_created_by => FND_GLOBAL.USER_ID,
	  p_creation_date => sysdate);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    else
      /* Added the else part on 07/26/01. If the attribute value already exists
	 then update the with the current value. Changes done by Siva */
    begin
      PSB_ATTRIBUTE_VALUES_PVT.Update_Row
	 (p_api_version => 1.0,
	  p_init_msg_list => null,
	  p_commit => null,
	  p_validation_level => null,
	  p_return_status => l_return_status,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_attribute_value_id => l_attribute_value_id,
	  p_attribute_id => c_attrval_rec.attribute_id,
	  p_attribute_value => c_attrval_rec.attribute_value,
	  p_description => c_attrval_rec.description,
	  p_hr_value_id => c_attrval_rec.hr_value_id,
	  p_data_extract_id => p_target_data_extract_id,
	  p_attribute1 => c_attrval_rec.attribute1,
	  p_attribute2 => c_attrval_rec.attribute2,
	  p_attribute3 => c_attrval_rec.attribute3,
	  p_attribute4 => c_attrval_rec.attribute4,
	  p_attribute5 => c_attrval_rec.attribute5,
	  p_attribute6 => c_attrval_rec.attribute6,
	  p_attribute7 => c_attrval_rec.attribute7,
	  p_attribute8 => c_attrval_rec.attribute8,
	  p_attribute9 => c_attrval_rec.attribute9,
	  p_attribute10 => c_attrval_rec.attribute10,
	  p_attribute11 => c_attrval_rec.attribute11,
	  p_attribute12 => c_attrval_rec.attribute12,
	  p_attribute13 => c_attrval_rec.attribute13,
	  p_attribute14 => c_attrval_rec.attribute14,
	  p_attribute15 => c_attrval_rec.attribute15,
	  p_attribute16 => c_attrval_rec.attribute16,
	  p_attribute17 => c_attrval_rec.attribute17,
	  p_attribute18 => c_attrval_rec.attribute18,
	  p_attribute19 => c_attrval_rec.attribute19,
	  p_attribute20 => c_attrval_rec.attribute20,
	  p_attribute21 => c_attrval_rec.attribute21,
	  p_attribute22 => c_attrval_rec.attribute22,
	  p_attribute23 => c_attrval_rec.attribute23,
	  p_attribute24 => c_attrval_rec.attribute24,
	  p_attribute25 => c_attrval_rec.attribute25,
	  p_attribute26 => c_attrval_rec.attribute26,
	  p_attribute27 => c_attrval_rec.attribute27,
	  p_attribute28 => c_attrval_rec.attribute28,
	  p_attribute29 => c_attrval_rec.attribute29,
	  p_attribute30 => c_attrval_rec.attribute30,
	  p_context => c_attrval_rec.context,
	  p_last_update_date => sysdate,
	  p_last_updated_by => FND_GLOBAL.USER_ID,
	  p_last_update_login => FND_GLOBAL.LOGIN_ID);

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

END Upload_Attribute_Values;

/* ----------------------------------------------------------------------- */

PROCEDURE Upload_Element
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_source_data_extract_id  IN   NUMBER,
  p_target_data_extract_id  IN   NUMBER,
  p_pay_element_id          IN   NUMBER
) IS

  l_pay_element_id          NUMBER;
  l_rowid                   ROWID;
  lp_rowid                  ROWID;
  l_pay_element_option_id   NUMBER;
  l_attribute_value_id      NUMBER;
  l_position_set_group_id   NUMBER;
  l_position_set_id         NUMBER;
  l_line_sequence_id        NUMBER;
  l_value_sequence_id       NUMBER;
  l_set_relation_id         NUMBER;
  l_distribution_id         NUMBER;

  l_mapped_ccid             NUMBER;
  l_budget_year_type_id     NUMBER;

  l_year_start_date         DATE;
  l_year_end_date           DATE;

  l_element_exists          BOOLEAN;
  l_element_option_exists   BOOLEAN;
  l_position_set_exists     BOOLEAN;
  l_line_sequence_exists    BOOLEAN;
  l_value_sequence_exists   BOOLEAN;

  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_return_status           VARCHAR2(1);

/* Bug No 2579818 Start
-- moving this cursor to copy_elements procedure
  l_business_group_id       NUMBER;

  cursor c_extract is
    select business_group_id
      from PSB_DATA_EXTRACTS
     where data_extract_id = p_source_data_extract_id;
 Bug No 2579818 End */

  cursor c_elem is
    select *
      from PSB_PAY_ELEMENTS
     where pay_element_id = p_pay_element_id;

  cursor c_elemname_exists (elemname VARCHAR2) is
    select pay_element_id, rowid
      from PSB_PAY_ELEMENTS
     where name = elemname
       and data_extract_id = p_target_data_extract_id;

  cursor c_elemoptions (elemid NUMBER) is
    select *
      from PSB_PAY_ELEMENT_OPTIONS
     where pay_element_id = elemid;

  cursor c_elemoptions_exists (elemid NUMBER, optname VARCHAR2) is
    select pay_element_option_id
      from PSB_PAY_ELEMENT_OPTIONS
     where name = optname
       and pay_element_id = elemid;

  cursor c_elemrates (elemid NUMBER, elemoptionid NUMBER) is
    select *
      from PSB_PAY_ELEMENT_RATES
     where worksheet_id is null
       and pay_element_option_id = elemoptionid
       and pay_element_id = elemid;

  cursor c_elemrates_nooptions (elemid NUMBER) is
    select *
      from PSB_PAY_ELEMENT_RATES
     where worksheet_id is null
       and pay_element_id = elemid;

  cursor c_possetgrp (elemid NUMBER) is
    select *
      from PSB_ELEMENT_POS_SET_GROUPS
     where pay_element_id = elemid;

  cursor c_setrel (possetgrpid NUMBER) is
    select *
      from PSB_SET_RELATIONS
     where position_set_group_id = possetgrpid;

  cursor c_posset (possetid NUMBER) is
    select *
      from PSB_ACCOUNT_POSITION_SETS
     where account_position_set_id = possetid;

  cursor c_possetline (possetid NUMBER) is
    select *
      from PSB_ACCOUNT_POSITION_SET_LINES
     where account_position_set_id = possetid;

  cursor c_possetlineval (lineseqid NUMBER) is
    select *
      from PSB_POSITION_SET_LINE_VALUES
     where line_sequence_id = lineseqid;

  cursor c_posset_exists (possetname VARCHAR2) is
    select account_position_set_id, rowid
      from PSB_ACCOUNT_POSITION_SETS
     where data_extract_id = p_target_data_extract_id
       and account_or_position_type = 'P'
       and name = possetname;

  cursor c_possetlineval_exists (lineseqid NUMBER, attrval VARCHAR2) is
    select value_sequence_id
      from PSB_POSITION_SET_LINE_VALUES
     where attribute_value = attrval
       and line_sequence_id = lineseqid;

  cursor c_re_attrval (attrvalid NUMBER) is
    select a.attribute_value_id
      from PSB_ATTRIBUTE_VALUES a,
	   PSB_ATTRIBUTE_VALUES b
     where a.data_extract_id = p_target_data_extract_id
       and a.attribute_value = b.attribute_value
       and a.attribute_id    = b.attribute_id -- added for Bug#4262388
       and b.attribute_value_id = attrvalid;

  cursor c_possetline_exists (possetid NUMBER, attrid NUMBER) is
    select line_sequence_id
      from PSB_ACCOUNT_POSITION_SET_LINES
     where attribute_id = attrid
       and account_position_set_id = possetid;

  cursor c_elemdist (possetgrpid NUMBER) is
    select *
      from PSB_PAY_ELEMENT_DISTRIBUTIONS
     where position_set_group_id = possetgrpid;

  cursor c_elem_seq is
    select psb_pay_elements_s.nextval seq
      from dual;

  cursor c_elemoptions_seq is
    select psb_pay_element_options_s.nextval seq
      from dual;

  cursor c_posset_seq is
    select PSB_ACCOUNT_POSITION_SETS_S.NEXTVAL seq
      from dual;

  cursor c_possetline_seq is
    select PSB_ACCT_POSITION_SET_LINES_S.NEXTVAL seq
      from dual;

  cursor c_possetlineval_seq is
    select PSB_POSITION_SET_LINE_VALUES_S.NEXTVAL seq
      from dual;

  cursor c_setrel_seq is
    select PSB_SET_RELATIONS_S.NEXTVAL seq
      from dual;

  cursor c_elempossetgrp_seq is
    select PSB_ELEMENT_POS_SET_GROUPS_S.NEXTVAL seq
      from dual;

  cursor c_elemdist_seq is
    select PSB_PAY_ELEMENT_DISTRIBUTION_S.NEXTVAL seq
      from dual;

BEGIN

/* Bug No 2579818 Start
-- commented since calling it from copy_elements
  for c_extract_rec in c_extract loop
    l_business_group_id := c_extract_rec.business_group_id;
  end loop;

  Upload_Attribute_Values
	(p_return_status => l_return_status,
	 p_source_data_extract_id => p_source_data_extract_id,
	 p_source_business_group_id => l_business_group_id,
	 p_target_data_extract_id => p_target_data_extract_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;
 Bug No 2579818 End */

  for c_elem_rec in c_elem loop

    l_element_exists := FALSE;

    -- Check if element name exists in the target data extract

    for c_elemname_exists_rec in c_elemname_exists (c_elem_rec.name) loop
      l_pay_element_id := c_elemname_exists_rec.pay_element_id;
      l_rowid := c_elemname_exists_rec.rowid;
      l_element_exists := TRUE;
    end loop;

    if not l_element_exists then
    begin

      for c_elem_seq_rec in c_elem_seq loop
	l_pay_element_id := c_elem_seq_rec.seq;
      end loop;

      PSB_PAY_ELEMENTS_PVT.INSERT_ROW
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_row_id => l_rowid,
	  p_pay_element_id => l_pay_element_id,
	  p_budget_set_id => c_elem_rec.budget_set_id,
	  p_business_group_id => c_elem_rec.business_group_id,
	  p_data_extract_id => p_target_data_extract_id,
	  p_name => c_elem_rec.name,
	  p_description => c_elem_rec.description,
	  p_element_value_type => c_elem_rec.element_value_type,
	  p_formula_id => c_elem_rec.formula_id,
	  p_overwrite_flag => c_elem_rec.overwrite_flag,
	  p_required_flag => c_elem_rec.required_flag,
	  p_follow_salary => c_elem_rec.follow_salary,
	  p_pay_basis => c_elem_rec.pay_basis,
	  p_start_date => c_elem_rec.start_date,
	  p_end_date => c_elem_rec.end_date,
	  p_processing_type => c_elem_rec.processing_type,
	  p_period_type => c_elem_rec.period_type,
	  p_process_period_type => c_elem_rec.process_period_type,
	  p_max_element_value_type => c_elem_rec.max_element_value_type,
	  p_max_element_value => c_elem_rec.max_element_value,
	  p_salary_flag => c_elem_rec.salary_flag,
	  p_salary_type => c_elem_rec.salary_type,
	  p_option_flag => c_elem_rec.option_flag,
	  p_hr_element_type_id => c_elem_rec.hr_element_type_id,
	  p_attribute_category => c_elem_rec.attribute_category,
	  p_attribute1 => c_elem_rec.attribute1,
	  p_attribute2 => c_elem_rec.attribute2,
	  p_attribute3 => c_elem_rec.attribute3,
	  p_attribute4 => c_elem_rec.attribute4,
	  p_attribute5 => c_elem_rec.attribute5,
	  p_attribute6 => c_elem_rec.attribute6,
	  p_attribute7 => c_elem_rec.attribute7,
	  p_attribute8 => c_elem_rec.attribute8,
	  p_attribute9 => c_elem_rec.attribute9,
	  p_attribute10 => c_elem_rec.attribute10,
	  p_last_update_date => sysdate,
	  p_last_updated_by => FND_GLOBAL.USER_ID,
	  p_last_update_login => FND_GLOBAL.LOGIN_ID,
	  p_created_by => FND_GLOBAL.USER_ID,
	  p_creation_date => sysdate);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      if c_elem_rec.option_flag = 'Y' then
      begin

	for c_elemoptions_rec in c_elemoptions(c_elem_rec.pay_element_id) loop

	  for c_elemoptions_seq_rec in c_elemoptions_seq loop
	    l_pay_element_option_id := c_elemoptions_seq_rec.seq;
	  end loop;

	  PSB_PAY_ELEMENT_OPTIONS_PVT.INSERT_ROW
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_pay_element_option_id => l_pay_element_option_id,
	      p_pay_element_id => l_pay_element_id,
	      p_name => c_elemoptions_rec.name,
	      p_grade_step => c_elemoptions_rec.grade_step,
	      p_sequence_number => c_elemoptions_rec.sequence_number,
	      p_last_update_date => sysdate,
	      p_last_updated_by => FND_GLOBAL.USER_ID,
	      p_last_update_login => FND_GLOBAL.LOGIN_ID,
	      p_created_by => FND_GLOBAL.USER_ID,
	      p_creation_date => sysdate);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  for c_elemrates_rec in c_elemrates (c_elem_rec.pay_element_id, c_elemoptions_rec.pay_element_option_id) loop
	    PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
	       (p_api_version => 1.0,
		p_return_status => l_return_status,
		p_msg_count => l_msg_count,
		p_msg_data => l_msg_data,
		p_pay_element_id => l_pay_element_id,
		p_pay_element_option_id => l_pay_element_option_id,
		p_effective_start_date => c_elemrates_rec.effective_start_date,
		p_effective_end_date => c_elemrates_rec.effective_end_date,
		p_worksheet_id => null,
		p_element_value_type => c_elemrates_rec.element_value_type,
		p_element_value => c_elemrates_rec.element_value,
		p_pay_basis  => c_elemrates_rec.pay_basis,
		p_formula_id => c_elemrates_rec.formula_id,
		p_maximum_value => c_elemrates_rec.maximum_value,
		p_mid_value => c_elemrates_rec.mid_value,
		p_minimum_value => c_elemrates_rec.minimum_value,
		p_currency_code => c_elemrates_rec.currency_code);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;

	  end loop;

	end loop;

      end;
      else /* Elements without options */
      begin

	for c_elemrates_rec in c_elemrates_nooptions (c_elem_rec.pay_element_id) loop

	  PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_pay_element_id => l_pay_element_id,
	      p_pay_element_option_id => NULL,
	      p_effective_start_date => c_elemrates_rec.effective_start_date,
	      p_effective_end_date => c_elemrates_rec.effective_end_date,
	      p_worksheet_id => null,
	      p_element_value_type => c_elemrates_rec.element_value_type,
	      p_element_value => c_elemrates_rec.element_value,
	      p_pay_basis  => c_elemrates_rec.pay_basis,
	      p_formula_id => c_elemrates_rec.formula_id,
	      p_maximum_value => c_elemrates_rec.maximum_value,
	      p_mid_value => c_elemrates_rec.mid_value,
	      p_minimum_value => c_elemrates_rec.minimum_value,
	      p_currency_code => c_elemrates_rec.currency_code);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end loop;

      end; /* Elements without options */
      end if;

      -- Upload Element Position Set Groups

      for c_possetgrp_rec in c_possetgrp (c_elem_rec.pay_element_id) loop

	for c_elempossetgrp_seq_rec in c_elempossetgrp_seq loop
	  l_position_set_group_id := c_elempossetgrp_seq_rec.seq;
	end loop;

	PSB_ELEMENT_POS_SET_GROUPS_PVT.Insert_Row
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_position_set_group_id => l_position_set_group_id,
	    p_pay_element_id => l_pay_element_id,
	    p_name => c_possetgrp_rec.name,
	    p_last_update_date => sysdate,
	    p_last_updated_by => FND_GLOBAL.USER_ID,
	    p_last_update_login => FND_GLOBAL.LOGIN_ID,
	    p_created_by => FND_GLOBAL.USER_ID,
	    p_creation_date => sysdate);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

	-- Upload all Set Relations for the Position Set Group

	for c_setrel_rec in c_setrel (c_possetgrp_rec.position_set_group_id) loop

	  for c_posset_rec in c_posset (c_setrel_rec.account_position_set_id) loop

	    l_position_set_exists := FALSE;

	    lp_rowid := null;

	    for c_posset_exists_rec in c_posset_exists (c_posset_rec.name) loop
	      l_position_set_id := c_posset_exists_rec.account_position_set_id;
	      lp_rowid := c_posset_exists_rec.rowid;
	      l_position_set_exists := TRUE;
	    end loop;

	    if not l_position_set_exists then
	    begin

	      for c_posset_seq_rec in c_posset_seq loop
		l_position_set_id := c_posset_seq_rec.seq;
	      end loop;

	      PSB_ACCOUNT_POSITION_SET_PVT.Insert_Row
		 (p_api_version => 1.0,
		  p_return_status => l_return_status,
		  p_msg_count => l_msg_count,
		  p_msg_data => l_msg_data,
		  p_row_id => l_rowid,
		  p_account_position_set_id => l_position_set_id,
		  p_name => c_posset_rec.name,
		  p_set_of_books_id => c_posset_rec.set_of_books_id,
		  p_use_in_budget_group_flag => c_posset_rec.use_in_budget_group_flag,
		  p_data_extract_id => p_target_data_extract_id,
		  p_global_or_local_type => c_posset_rec.global_or_local_type,
		  p_account_or_position_type =>c_posset_rec.account_or_position_type,
		  p_attribute_selection_type => c_posset_rec.attribute_selection_type,
		  p_business_group_id => c_posset_rec.business_group_id,
		  p_last_update_date => sysdate,
		  p_last_updated_by => FND_GLOBAL.USER_ID,
		  p_last_update_login => FND_GLOBAL.LOGIN_ID,
		  p_created_by => FND_GLOBAL.USER_ID,
		  p_creation_date => sysdate);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      end if;

	      for c_possetline_rec in c_possetline (c_posset_rec.account_position_set_id) loop

		for c_possetline_seq_rec in c_possetline_seq loop
		  l_line_sequence_id := c_possetline_seq_rec.seq;
		end loop;

		PSB_ACCT_POSITION_SET_LINE_PVT.Insert_Row
		   (p_api_version => 1.0,
		    p_return_status => l_return_status,
		    p_msg_count => l_msg_count,
		    p_msg_data => l_msg_data,
		    p_row_id => l_rowid,
		    p_line_sequence_id => l_line_sequence_id,
		    p_account_position_set_id => l_position_set_id,
		    p_description => c_possetline_rec.description,
		    p_business_group_id => c_possetline_rec.business_group_id,
		    p_attribute_id => c_possetline_rec.attribute_id,
		    p_include_or_exclude_type => c_possetline_rec.include_or_exclude_type,
		    p_segment1_low => c_possetline_rec.segment1_low,
		    p_segment2_low => c_possetline_rec.segment2_low,
		    p_segment3_low => c_possetline_rec.segment3_low,
		    p_segment4_low => c_possetline_rec.segment4_low,
		    p_segment5_low => c_possetline_rec.segment5_low,
		    p_segment6_low => c_possetline_rec.segment6_low,
		    p_segment7_low => c_possetline_rec.segment7_low,
		    p_segment8_low => c_possetline_rec.segment8_low,
		    p_segment9_low => c_possetline_rec.segment9_low,
		    p_segment10_low => c_possetline_rec.segment10_low,
		    p_segment11_low => c_possetline_rec.segment11_low,
		    p_segment12_low => c_possetline_rec.segment12_low,
		    p_segment13_low => c_possetline_rec.segment13_low,
		    p_segment14_low => c_possetline_rec.segment14_low,
		    p_segment15_low => c_possetline_rec.segment15_low,
		    p_segment16_low => c_possetline_rec.segment16_low,
		    p_segment17_low => c_possetline_rec.segment17_low,
		    p_segment18_low => c_possetline_rec.segment18_low,
		    p_segment19_low => c_possetline_rec.segment19_low,
		    p_segment20_low => c_possetline_rec.segment20_low,
		    p_segment21_low => c_possetline_rec.segment21_low,
		    p_segment22_low => c_possetline_rec.segment22_low,
		    p_segment23_low => c_possetline_rec.segment23_low,
		    p_segment24_low => c_possetline_rec.segment24_low,
		    p_segment25_low => c_possetline_rec.segment25_low,
		    p_segment26_low => c_possetline_rec.segment26_low,
		    p_segment27_low => c_possetline_rec.segment27_low,
		    p_segment28_low => c_possetline_rec.segment28_low,
		    p_segment29_low => c_possetline_rec.segment29_low,
		    p_segment30_low => c_possetline_rec.segment30_low,
		    p_segment1_high => c_possetline_rec.segment1_high,
		    p_segment2_high => c_possetline_rec.segment2_high,
		    p_segment3_high => c_possetline_rec.segment3_high,
		    p_segment4_high => c_possetline_rec.segment4_high,
		    p_segment5_high => c_possetline_rec.segment5_high,
		    p_segment6_high => c_possetline_rec.segment6_high,
		    p_segment7_high => c_possetline_rec.segment7_high,
		    p_segment8_high => c_possetline_rec.segment8_high,
		    p_segment9_high => c_possetline_rec.segment9_high,
		    p_segment10_high => c_possetline_rec.segment10_high,
		    p_segment11_high => c_possetline_rec.segment11_high,
		    p_segment12_high => c_possetline_rec.segment12_high,
		    p_segment13_high => c_possetline_rec.segment13_high,
		    p_segment14_high => c_possetline_rec.segment14_high,
		    p_segment15_high => c_possetline_rec.segment15_high,
		    p_segment16_high => c_possetline_rec.segment16_high,
		    p_segment17_high => c_possetline_rec.segment17_high,
		    p_segment18_high => c_possetline_rec.segment18_high,
		    p_segment19_high => c_possetline_rec.segment19_high,
		    p_segment20_high => c_possetline_rec.segment20_high,
		    p_segment21_high => c_possetline_rec.segment21_high,
		    p_segment22_high => c_possetline_rec.segment22_high,
		    p_segment23_high => c_possetline_rec.segment23_high,
		    p_segment24_high => c_possetline_rec.segment24_high,
		    p_segment25_high => c_possetline_rec.segment25_high,
		    p_segment26_high => c_possetline_rec.segment26_high,
		    p_segment27_high => c_possetline_rec.segment27_high,
		    p_segment28_high => c_possetline_rec.segment28_high,
		    p_segment29_high => c_possetline_rec.segment29_high,
		    p_segment30_high => c_possetline_rec.segment30_high,
		    p_context => c_possetline_rec.context,
		    p_attribute1 => c_possetline_rec.attribute1,
		    p_attribute2 => c_possetline_rec.attribute2,
		    p_attribute3 => c_possetline_rec.attribute3,
		    p_attribute4 => c_possetline_rec.attribute4,
		    p_attribute5 => c_possetline_rec.attribute5,
		    p_attribute6 => c_possetline_rec.attribute6,
		    p_attribute7 => c_possetline_rec.attribute7,
		    p_attribute8 => c_possetline_rec.attribute8,
		    p_attribute9 => c_possetline_rec.attribute9,
		    p_attribute10 => c_possetline_rec.attribute10,
		    p_last_update_date => sysdate,
		    p_last_updated_by => FND_GLOBAL.USER_ID,
		    p_last_update_login => FND_GLOBAL.LOGIN_ID,
		    p_created_by => FND_GLOBAL.USER_ID,
		    p_creation_date => sysdate);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		end if;

		for c_possetlineval_rec in c_possetlineval (c_possetline_rec.line_sequence_id) loop

		  for c_re_attrval_rec in c_re_attrval (c_possetlineval_rec.attribute_value_id) loop
		    l_attribute_value_id := c_re_attrval_rec.attribute_value_id;
		  end loop;

		  for c_possetlineval_seq_rec in c_possetlineval_seq loop
		    l_value_sequence_id := c_possetlineval_seq_rec.seq;
		  end loop;

		  PSB_POS_SET_LINE_VALUES_PVT.Insert_Row
		     (p_api_version => 1.0,
		      p_return_status => l_return_status,
		      p_msg_count => l_msg_count,
		      p_msg_data => l_msg_data,
		      p_row_id => l_rowid,
		      p_value_sequence_id => l_value_sequence_id,
		      p_line_sequence_id => l_line_sequence_id,
		      p_attribute_value_id => l_attribute_value_id,
		      p_attribute_value => c_possetlineval_rec.attribute_value,
		      p_last_update_date => sysdate,
		      p_last_updated_by => FND_GLOBAL.USER_ID,
		      p_last_update_login => FND_GLOBAL.LOGIN_ID,
		      p_created_by => FND_GLOBAL.USER_ID,
		      p_creation_date => sysdate);

		  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		    raise FND_API.G_EXC_ERROR;
		  end if;

		end loop; /* Loop for Position Set Line Val */

	      end loop; /* For Position Set Line */

	    end; /* Position Set does not exist */
	    else
	    begin /* Position Set exists; only upload position set lines and attribute values */

	      for c_possetline_rec in c_possetline (c_posset_rec.account_position_set_id) loop

		l_line_sequence_exists := FALSE;

		for c_possetline_exists_rec in c_possetline_exists (l_position_set_id, c_possetline_rec.attribute_id) loop
		  l_line_sequence_id := c_possetline_exists_rec.line_sequence_id;
		  l_line_sequence_exists := TRUE;
		end loop;

		if not l_line_sequence_exists then
		begin

		  for c_possetline_seq_rec in c_possetline_seq loop
		    l_line_sequence_id := c_possetline_seq_rec.seq;
		  end loop;

		  PSB_ACCT_POSITION_SET_LINE_PVT.Insert_Row
		     (p_api_version => 1.0,
		      p_return_status => l_return_status,
		      p_msg_count => l_msg_count,
		      p_msg_data => l_msg_data,
		      p_row_id => l_rowid,
		      p_line_sequence_id => l_line_sequence_id,
		      p_account_position_set_id => l_position_set_id,
		      p_description => c_possetline_rec.description,
		      p_business_group_id => c_possetline_rec.business_group_id,
		      p_attribute_id => c_possetline_rec.attribute_id,
		      p_include_or_exclude_type => c_possetline_rec.include_or_exclude_type,
		      p_segment1_low => c_possetline_rec.segment1_low,
		      p_segment2_low => c_possetline_rec.segment2_low,
		      p_segment3_low => c_possetline_rec.segment3_low,
		      p_segment4_low => c_possetline_rec.segment4_low,
		      p_segment5_low => c_possetline_rec.segment5_low,
		      p_segment6_low => c_possetline_rec.segment6_low,
		      p_segment7_low => c_possetline_rec.segment7_low,
		      p_segment8_low => c_possetline_rec.segment8_low,
		      p_segment9_low => c_possetline_rec.segment9_low,
		      p_segment10_low => c_possetline_rec.segment10_low,
		      p_segment11_low => c_possetline_rec.segment11_low,
		      p_segment12_low => c_possetline_rec.segment12_low,
		      p_segment13_low => c_possetline_rec.segment13_low,
		      p_segment14_low => c_possetline_rec.segment14_low,
		      p_segment15_low => c_possetline_rec.segment15_low,
		      p_segment16_low => c_possetline_rec.segment16_low,
		      p_segment17_low => c_possetline_rec.segment17_low,
		      p_segment18_low => c_possetline_rec.segment18_low,
		      p_segment19_low => c_possetline_rec.segment19_low,
		      p_segment20_low => c_possetline_rec.segment20_low,
		      p_segment21_low => c_possetline_rec.segment21_low,
		      p_segment22_low => c_possetline_rec.segment22_low,
		      p_segment23_low => c_possetline_rec.segment23_low,
		      p_segment24_low => c_possetline_rec.segment24_low,
		      p_segment25_low => c_possetline_rec.segment25_low,
		      p_segment26_low => c_possetline_rec.segment26_low,
		      p_segment27_low => c_possetline_rec.segment27_low,
		      p_segment28_low => c_possetline_rec.segment28_low,
		      p_segment29_low => c_possetline_rec.segment29_low,
		      p_segment30_low => c_possetline_rec.segment30_low,
		      p_segment1_high => c_possetline_rec.segment1_high,
		      p_segment2_high => c_possetline_rec.segment2_high,
		      p_segment3_high => c_possetline_rec.segment3_high,
		      p_segment4_high => c_possetline_rec.segment4_high,
		      p_segment5_high => c_possetline_rec.segment5_high,
		      p_segment6_high => c_possetline_rec.segment6_high,
		      p_segment7_high => c_possetline_rec.segment7_high,
		      p_segment8_high => c_possetline_rec.segment8_high,
		      p_segment9_high => c_possetline_rec.segment9_high,
		      p_segment10_high => c_possetline_rec.segment10_high,
		      p_segment11_high => c_possetline_rec.segment11_high,
		      p_segment12_high => c_possetline_rec.segment12_high,
		      p_segment13_high => c_possetline_rec.segment13_high,
		      p_segment14_high => c_possetline_rec.segment14_high,
		      p_segment15_high => c_possetline_rec.segment15_high,
		      p_segment16_high => c_possetline_rec.segment16_high,
		      p_segment17_high => c_possetline_rec.segment17_high,
		      p_segment18_high => c_possetline_rec.segment18_high,
		      p_segment19_high => c_possetline_rec.segment19_high,
		      p_segment20_high => c_possetline_rec.segment20_high,
		      p_segment21_high => c_possetline_rec.segment21_high,
		      p_segment22_high => c_possetline_rec.segment22_high,
		      p_segment23_high => c_possetline_rec.segment23_high,
		      p_segment24_high => c_possetline_rec.segment24_high,
		      p_segment25_high => c_possetline_rec.segment25_high,
		      p_segment26_high => c_possetline_rec.segment26_high,
		      p_segment27_high => c_possetline_rec.segment27_high,
		      p_segment28_high => c_possetline_rec.segment28_high,
		      p_segment29_high => c_possetline_rec.segment29_high,
		      p_segment30_high => c_possetline_rec.segment30_high,
		      p_context => c_possetline_rec.context,
		      p_attribute1 => c_possetline_rec.attribute1,
		      p_attribute2 => c_possetline_rec.attribute2,
		      p_attribute3 => c_possetline_rec.attribute3,
		      p_attribute4 => c_possetline_rec.attribute4,
		      p_attribute5 => c_possetline_rec.attribute5,
		      p_attribute6 => c_possetline_rec.attribute6,
		      p_attribute7 => c_possetline_rec.attribute7,
		      p_attribute8 => c_possetline_rec.attribute8,
		      p_attribute9 => c_possetline_rec.attribute9,
		      p_attribute10 => c_possetline_rec.attribute10,
		      p_last_update_date => sysdate,
		      p_last_updated_by => FND_GLOBAL.USER_ID,
		      p_last_update_login => FND_GLOBAL.LOGIN_ID,
		      p_created_by => FND_GLOBAL.USER_ID,
		      p_creation_date => sysdate);

		  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		    raise FND_API.G_EXC_ERROR;
		  end if;

		  for c_possetlineval_rec in c_possetlineval (c_possetline_rec.line_sequence_id) loop

		    for c_re_attrval_rec in c_re_attrval (c_possetlineval_rec.attribute_value_id) loop
		      l_attribute_value_id := c_re_attrval_rec.attribute_value_id;
		    end loop;

		    for c_possetlineval_seq_rec in c_possetlineval_seq loop
		      l_value_sequence_id := c_possetlineval_seq_rec.seq;
		    end loop;

		    PSB_POS_SET_LINE_VALUES_PVT.Insert_Row
		       (p_api_version => 1.0,
			p_return_status => l_return_status,
			p_msg_count => l_msg_count,
			p_msg_data => l_msg_data,
			p_row_id => l_rowid,
			p_value_sequence_id => l_value_sequence_id,
			p_line_sequence_id => l_line_sequence_id,
			p_attribute_value_id => l_attribute_value_id,
			p_attribute_value => c_possetlineval_rec.attribute_value,
			p_last_update_date => sysdate,
			p_last_updated_by => FND_GLOBAL.USER_ID,
			p_last_update_login => FND_GLOBAL.LOGIN_ID,
			p_created_by => FND_GLOBAL.USER_ID,
			p_creation_date => sysdate);

		    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		      raise FND_API.G_EXC_ERROR;
		    end if;

		  end loop;

		end; /* Position Set exists, Line Sequence does not exist */
		else
		begin /* Position Set exists, Line Sequence also exists */

		  for c_possetlineval_rec in c_possetlineval (c_possetline_rec.line_sequence_id) loop

		    for c_re_attrval_rec in c_re_attrval (c_possetlineval_rec.attribute_value_id) loop
		      l_attribute_value_id := c_re_attrval_rec.attribute_value_id;
		    end loop;

		    for c_possetlineval_exists_rec in c_possetlineval_exists (l_line_sequence_id, c_possetlineval_rec.attribute_value) loop
		      l_value_sequence_id := c_possetlineval_exists_rec.value_sequence_id;
		      l_value_sequence_exists := TRUE;
		    end loop;

		    if not l_value_sequence_exists then
		    begin

		      for c_possetlineval_seq_rec in c_possetlineval_seq loop
			l_value_sequence_id := c_possetlineval_seq_rec.seq;
		      end loop;

		      PSB_POS_SET_LINE_VALUES_PVT.Insert_Row
			 (p_api_version => 1.0,
			  p_return_status => l_return_status,
			  p_msg_count => l_msg_count,
			  p_msg_data => l_msg_data,
			  p_row_id => l_rowid,
			  p_value_sequence_id => l_value_sequence_id,
			  p_line_sequence_id => l_line_sequence_id,
			  p_attribute_value_id => l_attribute_value_id,
			  p_attribute_value => c_possetlineval_rec.attribute_value,
			  p_last_update_date => sysdate,
			  p_last_updated_by => FND_GLOBAL.USER_ID,
			  p_last_update_login => FND_GLOBAL.LOGIN_ID,
			  p_created_by => FND_GLOBAL.USER_ID,
			  p_creation_date => sysdate);

		      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
			raise FND_API.G_EXC_ERROR;
		      end if;

		    end;
		    end if;

		  end loop; /* For Position Set Line Val */

		end; /* Position Set exists, Line Sequence also exists */
		end if;
	/*For Bug No : 1822371 Start*/
	--This has been commented because of the attribute selection type
	--should be same as the old Position Set.
	--This has been taken care during the build for Bug No : 1822364
	/*
		-- Since we're adding attribute values set the attribute selection type to 'O'

		if c_posset_rec.attribute_selection_type <> 'O' then
		begin

		  PSB_ACCOUNT_POSITION_SET_PVT.Update_Row
		     (p_api_version => 1.0,
		      p_return_status => l_return_status,
		      p_msg_count => l_msg_count,
		      p_msg_data => l_msg_data,
		      p_row_id => lp_rowid,
		      p_account_position_set_id => l_position_set_id,
		      p_name => c_posset_rec.name,
		      p_set_of_books_id => c_posset_rec.set_of_books_id,
		      p_data_extract_id => p_target_data_extract_id,
		      p_global_or_local_type => c_posset_rec.global_or_local_type,
		      p_account_or_position_type => c_posset_rec.account_or_position_type,
		      p_attribute_selection_type => 'O',
		      p_business_group_id => c_posset_rec.business_group_id,
		      p_last_update_date => sysdate,
		      p_last_updated_by => FND_GLOBAL.USER_ID,
		      p_last_update_login => FND_GLOBAL.LOGIN_ID);

		  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		    raise FND_API.G_EXC_ERROR;
		  end if;

		end;
		end if;
	 */
	/*For Bug No : 1822371 End*/

	      end loop;

	    end; /* Position Set exists; only upload position set lines and attribute values */
	    end if;

	    -- Upload Set Relations

	    for c_setrel_seq_rec in c_setrel_seq loop
	      l_set_relation_id := c_setrel_seq_rec.seq;
	    end loop;

	    PSB_SET_RELATION_PVT.Insert_Row
	       (p_api_version => 1.0,
		p_return_status => l_return_status,
		p_msg_count => l_msg_count,
		p_msg_data => l_msg_data,
		p_row_id => l_rowid,
		p_set_relation_id => l_set_relation_id,
		p_account_position_set_id => l_position_set_id,
		p_allocation_rule_id => null,
		p_budget_group_id => null,
		p_budget_workflow_rule_id => null,
		p_constraint_id => null,
		p_default_rule_id => null,
		p_parameter_id => null,
		p_position_set_group_id => l_position_set_group_id,
/* Budget Revision Rules Enhancement Start */
		p_rule_id => null,
		p_apply_balance_flag => null,
/* Budget Revision Rules Enhancement End */
		p_effective_start_date => null,
		p_effective_end_date => null,
		p_last_update_date => sysdate,
		p_last_updated_by => FND_GLOBAL.USER_ID,
		p_last_update_login => FND_GLOBAL.LOGIN_ID,
		p_created_by => FND_GLOBAL.USER_ID,
		p_creation_date => sysdate);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;

	  end loop; /* Position Sets */

	end loop; /* Set Relations */

	for c_elemdist_rec in c_elemdist (c_possetgrp_rec.position_set_group_id) loop

	  for c_elemdist_seq_rec in c_elemdist_seq loop
	    l_distribution_id := c_elemdist_seq_rec.seq;
	  end loop;

	  PSB_ELEMENT_DISTRIBUTIONS_PVT.Insert_Row
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_distribution_id => l_distribution_id,
	      p_position_set_group_id => l_position_set_group_id,
	      p_chart_of_accounts_id => c_elemdist_rec.chart_of_accounts_id,
	      p_effective_start_date => c_elemdist_rec.effective_start_date,
	      p_effective_end_date => c_elemdist_rec.effective_end_date,
	      p_distribution_percent => c_elemdist_rec.distribution_percent,
	      p_concatenated_segments => c_elemdist_rec.concatenated_segments,
	      p_code_combination_id => c_elemdist_rec.code_combination_id,
	      p_distribution_set_id => c_elemdist_rec.distribution_set_id,
	      p_segment1 => c_elemdist_rec.segment1,
	      p_segment2 => c_elemdist_rec.segment2,
	      p_segment3 => c_elemdist_rec.segment3,
	      p_segment4 => c_elemdist_rec.segment4,
	      p_segment5 => c_elemdist_rec.segment5,
	      p_segment6 => c_elemdist_rec.segment6,
	      p_segment7 => c_elemdist_rec.segment7,
	      p_segment8 => c_elemdist_rec.segment8,
	      p_segment9 => c_elemdist_rec.segment9,
	      p_segment10 => c_elemdist_rec.segment10,
	      p_segment11 => c_elemdist_rec.segment11,
	      p_segment12 => c_elemdist_rec.segment12,
	      p_segment13 => c_elemdist_rec.segment13,
	      p_segment14 => c_elemdist_rec.segment14,
	      p_segment15 => c_elemdist_rec.segment15,
	      p_segment16 => c_elemdist_rec.segment16,
	      p_segment17 => c_elemdist_rec.segment17,
	      p_segment18 => c_elemdist_rec.segment18,
	      p_segment19 => c_elemdist_rec.segment19,
	      p_segment20 => c_elemdist_rec.segment20,
	      p_segment21 => c_elemdist_rec.segment21,
	      p_segment22 => c_elemdist_rec.segment22,
	      p_segment23 => c_elemdist_rec.segment23,
	      p_segment24 => c_elemdist_rec.segment24,
	      p_segment25 => c_elemdist_rec.segment25,
	      p_segment26 => c_elemdist_rec.segment26,
	      p_segment27 => c_elemdist_rec.segment27,
	      p_segment28 => c_elemdist_rec.segment28,
	      p_segment29 => c_elemdist_rec.segment29,
	      p_segment30 => c_elemdist_rec.segment30,
	      p_last_update_date => sysdate,
	      p_last_updated_by => FND_GLOBAL.USER_ID,
	      p_last_update_login => FND_GLOBAL.LOGIN_ID,
	      p_created_by => FND_GLOBAL.USER_ID,
	      p_creation_date => sysdate);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end loop; /* Element Distribution */

      end loop; /* Element Position Set Group */

    end; /* Element does not exist */
    else
    begin /* Element already exists in the target data extract */

      -- update element definition

      PSB_PAY_ELEMENTS_PVT.UPDATE_ROW
	(p_api_version => 1.0,
	 p_return_status => l_return_status,
	 p_msg_count => l_msg_count,
	 p_msg_data => l_msg_data,
	 P_ROW_ID => l_rowid,
	 P_PAY_ELEMENT_ID => l_pay_element_id,
	 P_BUSINESS_GROUP_ID => c_elem_rec.business_group_id,
	 P_DATA_EXTRACT_ID => p_target_data_extract_id,
	 P_BUDGET_SET_ID => c_elem_rec.budget_set_id,
	 P_NAME => c_elem_rec.name,
	 P_DESCRIPTION => c_elem_rec.description,
	 P_ELEMENT_VALUE_TYPE => c_elem_rec.element_value_type,
	 P_FORMULA_ID => c_elem_rec.formula_id,
	 P_OVERWRITE_FLAG => c_elem_rec.overwrite_flag,
	 P_REQUIRED_FLAG => c_elem_rec.required_flag,
	 P_FOLLOW_SALARY => c_elem_rec.follow_salary,
	 P_PAY_BASIS => c_elem_rec.pay_basis,
	 P_START_DATE => c_elem_rec.start_date,
	 P_END_DATE => c_elem_rec.end_date,
	 P_PROCESSING_TYPE => c_elem_rec.processing_type,
	 P_PERIOD_TYPE => c_elem_rec.period_type,
	 P_PROCESS_PERIOD_TYPE => c_elem_rec.process_period_type,
	 P_MAX_ELEMENT_VALUE_TYPE => c_elem_rec.max_element_value_type,
	 P_MAX_ELEMENT_VALUE => c_elem_rec.max_element_value,
	 P_SALARY_FLAG => c_elem_rec.salary_flag,
	 P_SALARY_TYPE => c_elem_rec.salary_type,
	 P_OPTION_FLAG => c_elem_rec.option_flag,
	 P_HR_ELEMENT_TYPE_ID => c_elem_rec.hr_element_type_id,
	 P_ATTRIBUTE_CATEGORY => c_elem_rec.attribute_category,
	 P_ATTRIBUTE1 => c_elem_rec.attribute1,
	 P_ATTRIBUTE2 => c_elem_rec.attribute2,
	 P_ATTRIBUTE3 => c_elem_rec.attribute3,
	 P_ATTRIBUTE4 => c_elem_rec.attribute4,
	 P_ATTRIBUTE5 => c_elem_rec.attribute5,
	 P_ATTRIBUTE6 => c_elem_rec.attribute6,
	 P_ATTRIBUTE7 => c_elem_rec.attribute7,
	 P_ATTRIBUTE8 => c_elem_rec.attribute8,
	 P_ATTRIBUTE9 => c_elem_rec.attribute9,
	 P_ATTRIBUTE10 => c_elem_rec.attribute10,
	 P_LAST_UPDATE_DATE => sysdate,
	 P_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
	 P_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      if c_elem_rec.option_flag = 'Y' then
      begin

	for c_elemoptions_rec in c_elemoptions(c_elem_rec.pay_element_id) loop

	  l_element_option_exists := FALSE;

	  -- Check if Element Option already exists
         -- Changed the first parameter for bug 3476442
	 for c_elemoptions_exists_rec
	 in c_elemoptions_exists (l_pay_element_id, c_elemoptions_rec.name) loop
	    l_element_option_exists := TRUE;
	    l_pay_element_option_id :=
	                         c_elemoptions_exists_rec.pay_element_option_id;
	 end loop;

	  if not l_element_option_exists then
	  begin

	    for c_elemoptions_seq_rec in c_elemoptions_seq loop
	      l_pay_element_option_id := c_elemoptions_seq_rec.seq;
	    end loop;

	    PSB_PAY_ELEMENT_OPTIONS_PVT.INSERT_ROW
	       (p_api_version => 1.0,
		p_return_status => l_return_status,
		p_msg_count => l_msg_count,
		p_msg_data => l_msg_data,
		p_pay_element_option_id => l_pay_element_option_id,
		p_pay_element_id => l_pay_element_id,
		p_name => c_elemoptions_rec.name,
		p_grade_step => c_elemoptions_rec.grade_step,
		p_sequence_number => c_elemoptions_rec.sequence_number,
		p_last_update_date => sysdate,
		p_last_updated_by => FND_GLOBAL.USER_ID,
		p_last_update_login => FND_GLOBAL.LOGIN_ID,
		p_created_by => FND_GLOBAL.USER_ID,
		p_creation_date => sysdate);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;

	    for c_elemrates_rec in c_elemrates(c_elem_rec.pay_element_id, c_elemoptions_rec.pay_element_option_id) loop
	      PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
		 (p_api_version => 1.0,
		  p_return_status => l_return_status,
		  p_msg_count => l_msg_count,
		  p_msg_data => l_msg_data,
		  p_pay_element_id => l_pay_element_id,
		  p_pay_element_option_id => l_pay_element_option_id,
		  p_effective_start_date => c_elemrates_rec.effective_start_date,
		  p_effective_end_date => c_elemrates_rec.effective_end_date,
		  p_worksheet_id => null,
		  p_element_value_type => c_elemrates_rec.element_value_type,
		  p_element_value => c_elemrates_rec.element_value,
		  p_pay_basis  => c_elemrates_rec.pay_basis,
		  p_formula_id => c_elemrates_rec.formula_id,
		  p_maximum_value => c_elemrates_rec.maximum_value,
		  p_mid_value => c_elemrates_rec.mid_value,
		  p_minimum_value => c_elemrates_rec.minimum_value,
		  p_currency_code => c_elemrates_rec.currency_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      end if;

	    end loop;

	  end; /* Elemoption does not exist */
	  end if;

	end loop; /* Elemoptions */

      end; /* Option Flag = 'Y' */
      else
      begin

	for c_elemrates_rec in c_elemrates_nooptions (c_elem_rec.pay_element_id) loop

	  PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_pay_element_id => l_pay_element_id,
	      p_pay_element_option_id => NULL,
	      p_effective_start_date => c_elemrates_rec.effective_start_date,
	      p_effective_end_date => c_elemrates_rec.effective_end_date,
	      p_worksheet_id => null,
	      p_element_value_type => c_elemrates_rec.element_value_type,
	      p_element_value => c_elemrates_rec.element_value,
	      p_pay_basis  => c_elemrates_rec.pay_basis,
	      p_formula_id => c_elemrates_rec.formula_id,
	      p_maximum_value => c_elemrates_rec.maximum_value,
	      p_mid_value => c_elemrates_rec.mid_value,
	      p_minimum_value => c_elemrates_rec.minimum_value,
	      p_currency_code => c_elemrates_rec.currency_code);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end loop;

      end;
      end if;

    end; /* Element already exists in the target data extract */
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

END Upload_Element;

/* ----------------------------------------------------------------------- */

PROCEDURE Upload_Elements
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_source_data_extract_id  IN   NUMBER,
  p_target_data_extract_id  IN   NUMBER,
  p_worksheet_id            IN   NUMBER,
  p_budget_calendar_id      IN   NUMBER,
  p_flex_mapping_set_id     IN   NUMBER,
  p_budget_group_id         IN   NUMBER
) IS

  l_pay_element_id          NUMBER;
  l_rowid                   ROWID;
  l_pay_element_option_id   NUMBER;

  l_element_exists          BOOLEAN;
  l_element_option_exists   BOOLEAN;

  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_return_status           VARCHAR2(1);

  cursor c_elem is
    select *
      from PSB_PAY_ELEMENTS
     where data_extract_id = p_source_data_extract_id;

  cursor c_elemname_exists (elemname VARCHAR2) is
    select pay_element_id, rowid
      from PSB_PAY_ELEMENTS
     where name = elemname
       and data_extract_id = p_target_data_extract_id;

  cursor c_elemoptions (elemid NUMBER) is
    select *
      from PSB_PAY_ELEMENT_OPTIONS
     where pay_element_id = elemid;

  cursor c_elemoptions_exists (elemid NUMBER, optname VARCHAR2) is
    select pay_element_option_id
      from PSB_PAY_ELEMENT_OPTIONS
     where name = optname
       and pay_element_id = elemid;

  cursor c_elemrates (elemid NUMBER, elemoptionid NUMBER) is
    select *
      from PSB_PAY_ELEMENT_RATES a
     where a.pay_element_id = elemid
       and a.pay_element_option_id = elemoptionid
       and ((a.worksheet_id = p_worksheet_id)
	 or (a.worksheet_id is null
       and not exists
	  (select 1 from PSB_PAY_ELEMENT_RATES b
	    where b.pay_element_id = a.pay_element_id
	      and b.pay_element_option_id = a.pay_element_option_id
	      and b.worksheet_id = p_worksheet_id)));

  cursor c_elemrates_nooptions (elemid NUMBER) is
    select *
      from PSB_PAY_ELEMENT_RATES a
     where a.pay_element_id = elemid
       and ((a.worksheet_id = p_worksheet_id)
	 or (a.worksheet_id is null
       and not exists
	  (select 1 from PSB_PAY_ELEMENT_RATES b
	    where b.pay_element_id = a.pay_element_id
	      and b.worksheet_id = p_worksheet_id)));

  cursor c_elem_seq is
    select psb_pay_elements_s.nextval seq
      from dual;

  cursor c_elemoptions_seq is
    select psb_pay_element_options_s.nextval seq
      from dual;

BEGIN

  for c_elem_rec in c_elem loop

    l_element_exists := FALSE;
    l_rowid := null;

    -- Check if element name exists in the target data extract

    for c_elemname_exists_rec in c_elemname_exists (c_elem_rec.name) loop
      l_pay_element_id := c_elemname_exists_rec.pay_element_id;
      l_rowid := c_elemname_exists_rec.rowid;
      l_element_exists := TRUE;
    end loop;

    if not l_element_exists then
    begin

      for c_elem_seq_rec in c_elem_seq loop
	l_pay_element_id := c_elem_seq_rec.seq;
      end loop;

      PSB_PAY_ELEMENTS_PVT.INSERT_ROW
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_row_id => l_rowid,
	  p_pay_element_id => l_pay_element_id,
	  p_budget_set_id => c_elem_rec.budget_set_id,
	  p_business_group_id => c_elem_rec.business_group_id,
	  p_data_extract_id => p_target_data_extract_id,
	  p_name => c_elem_rec.name,
	  p_description => c_elem_rec.description,
	  p_element_value_type => c_elem_rec.element_value_type,
	  p_formula_id => c_elem_rec.formula_id,
	  p_overwrite_flag => c_elem_rec.overwrite_flag,
	  p_required_flag => c_elem_rec.required_flag,
	  p_follow_salary => c_elem_rec.follow_salary,
	  p_pay_basis => c_elem_rec.pay_basis,
	  p_start_date => c_elem_rec.start_date,
	  p_end_date => c_elem_rec.end_date,
	  p_processing_type => c_elem_rec.processing_type,
	  p_period_type => c_elem_rec.period_type,
	  p_process_period_type => c_elem_rec.process_period_type,
	  p_max_element_value_type => c_elem_rec.max_element_value_type,
	  p_max_element_value => c_elem_rec.max_element_value,
	  p_salary_flag => c_elem_rec.salary_flag,
	  p_salary_type => c_elem_rec.salary_type,
	  p_option_flag => c_elem_rec.option_flag,
	  p_hr_element_type_id => c_elem_rec.hr_element_type_id,
	  p_attribute_category => c_elem_rec.attribute_category,
	  p_attribute1 => c_elem_rec.attribute1,
	  p_attribute2 => c_elem_rec.attribute2,
	  p_attribute3 => c_elem_rec.attribute3,
	  p_attribute4 => c_elem_rec.attribute4,
	  p_attribute5 => c_elem_rec.attribute5,
	  p_attribute6 => c_elem_rec.attribute6,
	  p_attribute7 => c_elem_rec.attribute7,
	  p_attribute8 => c_elem_rec.attribute8,
	  p_attribute9 => c_elem_rec.attribute9,
	  p_attribute10 => c_elem_rec.attribute10,
	  p_last_update_date => sysdate,
	  p_last_updated_by => FND_GLOBAL.USER_ID,
	  p_last_update_login => FND_GLOBAL.LOGIN_ID,
	  p_created_by => FND_GLOBAL.USER_ID,
	  p_creation_date => sysdate);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      if c_elem_rec.option_flag = 'Y' then
      begin

	for c_elemoptions_rec in c_elemoptions(c_elem_rec.pay_element_id) loop

	  for c_elemoptions_seq_rec in c_elemoptions_seq loop
	    l_pay_element_option_id := c_elemoptions_seq_rec.seq;
	  end loop;

	  PSB_PAY_ELEMENT_OPTIONS_PVT.INSERT_ROW
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_pay_element_option_id => l_pay_element_option_id,
	      p_pay_element_id => l_pay_element_id,
	      p_name => c_elemoptions_rec.name,
	      p_grade_step => c_elemoptions_rec.grade_step,
	      p_sequence_number => c_elemoptions_rec.sequence_number,
	      p_last_update_date => sysdate,
	      p_last_updated_by => FND_GLOBAL.USER_ID,
	      p_last_update_login => FND_GLOBAL.LOGIN_ID,
	      p_created_by => FND_GLOBAL.USER_ID,
	      p_creation_date => sysdate);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  for c_elemrates_rec in c_elemrates (c_elem_rec.pay_element_id, c_elemoptions_rec.pay_element_option_id) loop
	    PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
	       (p_api_version => 1.0,
		p_return_status => l_return_status,
		p_msg_count => l_msg_count,
		p_msg_data => l_msg_data,
		p_pay_element_id => l_pay_element_id,
		p_pay_element_option_id => l_pay_element_option_id,
		p_effective_start_date => c_elemrates_rec.effective_start_date,
		p_effective_end_date => c_elemrates_rec.effective_end_date,
		p_worksheet_id => null,
		p_element_value_type => c_elemrates_rec.element_value_type,
		p_element_value => c_elemrates_rec.element_value,
		p_pay_basis  => c_elemrates_rec.pay_basis,
		p_formula_id => c_elemrates_rec.formula_id,
		p_maximum_value => c_elemrates_rec.maximum_value,
		p_mid_value => c_elemrates_rec.mid_value,
		p_minimum_value => c_elemrates_rec.minimum_value,
		p_currency_code => c_elemrates_rec.currency_code);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;

	  end loop;

	end loop;

      end;
      else /* Elements without options */
      begin

	for c_elemrates_rec in c_elemrates_nooptions (c_elem_rec.pay_element_id) loop

	  PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_pay_element_id => l_pay_element_id,
	      p_pay_element_option_id => null,
	      p_effective_start_date => c_elemrates_rec.effective_start_date,
	      p_effective_end_date => c_elemrates_rec.effective_end_date,
	      p_worksheet_id => null,
	      p_element_value_type => c_elemrates_rec.element_value_type,
	      p_element_value => c_elemrates_rec.element_value,
	      p_pay_basis  => c_elemrates_rec.pay_basis,
	      p_formula_id => c_elemrates_rec.formula_id,
	      p_maximum_value => c_elemrates_rec.maximum_value,
	      p_mid_value => c_elemrates_rec.mid_value,
	      p_minimum_value => c_elemrates_rec.minimum_value,
	      p_currency_code => c_elemrates_rec.currency_code);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end loop;

      end; /* Elements without options */
      end if;

	/*The code that was defined here has been removed and
	  implemented in the Copy_Position_Set_Groups procedure
	*/

    end; /* Element does not exist */
    else
    begin /* Element already exists in the target data extract */

      -- update element definition

      PSB_PAY_ELEMENTS_PVT.UPDATE_ROW
	(p_api_version => 1.0,
	 p_return_status => l_return_status,
	 p_msg_count => l_msg_count,
	 p_msg_data => l_msg_data,
	 P_ROW_ID => l_rowid,
	 P_PAY_ELEMENT_ID => l_pay_element_id,
	 P_BUSINESS_GROUP_ID => c_elem_rec.business_group_id,
	 P_DATA_EXTRACT_ID => p_target_data_extract_id,
	 P_BUDGET_SET_ID => c_elem_rec.budget_set_id,
	 P_NAME => c_elem_rec.name,
	 P_DESCRIPTION => c_elem_rec.description,
	 P_ELEMENT_VALUE_TYPE => c_elem_rec.element_value_type,
	 P_FORMULA_ID => c_elem_rec.formula_id,
	 P_OVERWRITE_FLAG => c_elem_rec.overwrite_flag,
	 P_REQUIRED_FLAG => c_elem_rec.required_flag,
	 P_FOLLOW_SALARY => c_elem_rec.follow_salary,
	 P_PAY_BASIS => c_elem_rec.pay_basis,
	 P_START_DATE => c_elem_rec.start_date,
	 P_END_DATE => c_elem_rec.end_date,
	 P_PROCESSING_TYPE => c_elem_rec.processing_type,
	 P_PERIOD_TYPE => c_elem_rec.period_type,
	 P_PROCESS_PERIOD_TYPE => c_elem_rec.process_period_type,
	 P_MAX_ELEMENT_VALUE_TYPE => c_elem_rec.max_element_value_type,
	 P_MAX_ELEMENT_VALUE => c_elem_rec.max_element_value,
	 P_SALARY_FLAG => c_elem_rec.salary_flag,
	 P_SALARY_TYPE => c_elem_rec.salary_type,
	 P_OPTION_FLAG => c_elem_rec.option_flag,
	 P_HR_ELEMENT_TYPE_ID => c_elem_rec.hr_element_type_id,
	 P_ATTRIBUTE_CATEGORY => c_elem_rec.attribute_category,
	 P_ATTRIBUTE1 => c_elem_rec.attribute1,
	 P_ATTRIBUTE2 => c_elem_rec.attribute2,
	 P_ATTRIBUTE3 => c_elem_rec.attribute3,
	 P_ATTRIBUTE4 => c_elem_rec.attribute4,
	 P_ATTRIBUTE5 => c_elem_rec.attribute5,
	 P_ATTRIBUTE6 => c_elem_rec.attribute6,
	 P_ATTRIBUTE7 => c_elem_rec.attribute7,
	 P_ATTRIBUTE8 => c_elem_rec.attribute8,
	 P_ATTRIBUTE9 => c_elem_rec.attribute9,
	 P_ATTRIBUTE10 => c_elem_rec.attribute10,
	 P_LAST_UPDATE_DATE => sysdate,
	 P_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
	 P_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      if c_elem_rec.option_flag = 'Y' then
      begin

	for c_elemoptions_rec in c_elemoptions(c_elem_rec.pay_element_id) loop

	  l_element_option_exists := FALSE;

	  -- Check if Element Option already exists

          -- Changed the first parameter for bug 3476442
	  for c_elemoptions_exists_rec in c_elemoptions_exists (l_pay_element_id, c_elemoptions_rec.name) loop
	    l_element_option_exists := TRUE;
	    l_pay_element_option_id :=
	                         c_elemoptions_exists_rec.pay_element_option_id;
	  end loop;

	  if not l_element_option_exists then
	  begin

	    for c_elemoptions_seq_rec in c_elemoptions_seq loop
	      l_pay_element_option_id := c_elemoptions_seq_rec.seq;
	    end loop;

	    PSB_PAY_ELEMENT_OPTIONS_PVT.INSERT_ROW
	       (p_api_version => 1.0,
		p_return_status => l_return_status,
		p_msg_count => l_msg_count,
		p_msg_data => l_msg_data,
		p_pay_element_option_id => l_pay_element_option_id,
		p_pay_element_id => l_pay_element_id,
		p_name => c_elemoptions_rec.name,
		p_grade_step => c_elemoptions_rec.grade_step,
		p_sequence_number => c_elemoptions_rec.sequence_number,
		p_last_update_date => sysdate,
		p_last_updated_by => FND_GLOBAL.USER_ID,
		p_last_update_login => FND_GLOBAL.LOGIN_ID,
		p_created_by => FND_GLOBAL.USER_ID,
		p_creation_date => sysdate);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;

	    for c_elemrates_rec in c_elemrates (c_elem_rec.pay_element_id, c_elemoptions_rec.pay_element_option_id) loop

	      PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
		 (p_api_version => 1.0,
		  p_return_status => l_return_status,
		  p_msg_count => l_msg_count,
		  p_msg_data => l_msg_data,
		  p_pay_element_id => l_pay_element_id,
		  p_pay_element_option_id => l_pay_element_option_id,
		  p_effective_start_date => c_elemrates_rec.effective_start_date,
		  p_effective_end_date => c_elemrates_rec.effective_end_date,
		  p_worksheet_id => null,
		  p_element_value_type => c_elemrates_rec.element_value_type,
		  p_element_value => c_elemrates_rec.element_value,
		  p_pay_basis  => c_elemrates_rec.pay_basis,
		  p_formula_id => c_elemrates_rec.formula_id,
		  p_maximum_value => c_elemrates_rec.maximum_value,
		  p_mid_value => c_elemrates_rec.mid_value,
		  p_minimum_value => c_elemrates_rec.minimum_value,
		  p_currency_code => c_elemrates_rec.currency_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      end if;

	    end loop;

	  end; /* Elemoption does not exist */
	  else
	  begin /* Element Option exists; only need to refresh the rates */

	    for c_elemrates_rec in c_elemrates (c_elem_rec.pay_element_id, c_elemoptions_rec.pay_element_option_id) loop

	      PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
		 (p_api_version => 1.0,
		  p_return_status => l_return_status,
		  p_msg_count => l_msg_count,
		  p_msg_data => l_msg_data,
		  p_pay_element_id => l_pay_element_id,
		  p_pay_element_option_id => l_pay_element_option_id,
		  p_effective_start_date => c_elemrates_rec.effective_start_date,
		  p_effective_end_date => c_elemrates_rec.effective_end_date,
		  p_worksheet_id => null,
		  p_element_value_type => c_elemrates_rec.element_value_type,
		  p_element_value => c_elemrates_rec.element_value,
		  p_pay_basis  => c_elemrates_rec.pay_basis,
		  p_formula_id => c_elemrates_rec.formula_id,
		  p_maximum_value => c_elemrates_rec.maximum_value,
		  p_mid_value => c_elemrates_rec.mid_value,
		  p_minimum_value => c_elemrates_rec.minimum_value,
		  p_currency_code => c_elemrates_rec.currency_code);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      end if;

	    end loop;

	  end;
	  end if;

	end loop; /* Elemoptions */

      end; /* Option Flag = 'Y' */
      else
      begin

	for c_elemrates_rec in c_elemrates_nooptions (c_elem_rec.pay_element_id) loop

	  PSB_PAY_ELEMENT_RATES_PVT.Modify_Element_Rates
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_pay_element_id => l_pay_element_id,
	      p_pay_element_option_id => null,
	      p_effective_start_date => c_elemrates_rec.effective_start_date,
	      p_effective_end_date => c_elemrates_rec.effective_end_date,
	      p_worksheet_id => null,
	      p_element_value_type => c_elemrates_rec.element_value_type,
	      p_element_value => c_elemrates_rec.element_value,
	      p_pay_basis  => c_elemrates_rec.pay_basis,
	      p_formula_id => c_elemrates_rec.formula_id,
	      p_maximum_value => c_elemrates_rec.maximum_value,
	      p_mid_value => c_elemrates_rec.mid_value,
	      p_minimum_value => c_elemrates_rec.minimum_value,
	      p_currency_code => c_elemrates_rec.currency_code);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end loop;

      end;
      end if;

    end; /* Element already exists in the target data extract */
    end if;

    /*For Bug No : 1822364 Start*/
    --Copy all the position set groups and position set details and
    --account distributions that are related to it
    Copy_Position_Set_Groups
	( p_return_status           =>  l_return_status,
	  p_old_pay_element_id      =>  c_elem_rec.pay_element_id,
	  p_new_pay_element_id      =>  l_pay_element_id,
	  p_target_data_extract_id  =>  p_target_data_extract_id,
	  p_budget_group_id         =>  p_budget_group_id,
	  p_flex_mapping_set_id     =>  p_flex_mapping_set_id,
	  p_follow_salary           =>  c_elem_rec.follow_salary
	);
     /*For Bug No : 1822364 Start*/

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

END Upload_Elements;

/* ----------------------------------------------------------------------- */
/*For Bug No : 2434152 Start*/
--The following procedure has been converted to
--BULK COLLECT

PROCEDURE Upload_Employees
( p_return_status             OUT  NOCOPY  VARCHAR2,
  p_source_data_extract_id    IN   NUMBER,
  p_source_business_group_id  IN   NUMBER,
  p_target_data_extract_id    IN   NUMBER
) IS

  TYPE Number_tbl_type IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
  TYPE Char_tbl_type   IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE Date_tbl_type   IS TABLE OF DATE          INDEX BY BINARY_INTEGER;

  l_emp_num       Char_tbl_type;
  l_hremp_id      Number_tbl_type;
  l_first_name    Char_tbl_type;
  l_full_name     Char_tbl_type;
  l_known_as      Char_tbl_type;
  l_last_name     Char_tbl_type;
  l_middle_names  Char_tbl_type;
  l_title         Char_tbl_type;

  /*For Bug No : 2594575 Start*/
  --Stop extracting secured data of employee
  --Removed the columns in psb_employees table
  /*For Bug No : 2594575 End*/

  CURSOR C_Emp_All IS
  SELECT EMPLOYEE_NUMBER        ,
	 HR_EMPLOYEE_ID         ,
	 FIRST_NAME             ,
	 FULL_NAME              ,
	 KNOWN_AS               ,
	 LAST_NAME              ,
	 MIDDLE_NAMES           ,
	 TITLE
    FROM PSB_EMPLOYEES emp
   WHERE emp.data_extract_id = p_source_data_extract_id
     AND emp.business_group_id = p_source_business_group_id
     AND NOT EXISTS (
	 SELECT 1
	   FROM PSB_EMPLOYEES
	  WHERE hr_employee_id = emp.hr_employee_id
	    AND data_extract_id = p_target_data_extract_id
	);

BEGIN

  OPEN C_Emp_All;

  LOOP
    FETCH C_Emp_All
      BULK COLLECT INTO l_emp_num,l_hremp_id,l_first_name,l_full_name,
			l_known_as,l_last_name,l_middle_names,l_title
      LIMIT g_limit_bulk_numrows;

    FORALL i IN 1..l_emp_num.count
      insert into PSB_EMPLOYEES
	    (employee_id,
	     data_extract_id,
	     business_group_id,
	     employee_number,
	     hr_employee_id,
	     first_name,
	     full_name,
	     known_as,
	     last_name,
	     middle_names,
	     title,
	     creation_date,
	     created_by,
	     last_update_date,
	     last_updated_by,
	     last_update_login)
      values (PSB_EMPLOYEES_S.NEXTVAL,
	     p_target_data_extract_id,
	     p_source_business_group_id,
	     l_emp_num(i),
	     l_hremp_id(i),
	     l_first_name(i),
	     l_full_name(i),
	     l_known_as(i),
	     l_last_name(i),
	     l_middle_names(i),
	     l_title(i),
	     sysdate,
	     FND_GLOBAL.USER_ID,
	     sysdate,
	     FND_GLOBAL.USER_ID,
	     FND_GLOBAL.LOGIN_ID);

    EXIT WHEN C_Emp_All%NOTFOUND;

  END LOOP;

  close C_Emp_All;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     if C_Emp_All%ISOPEN then
       close C_Emp_All;
     end if;
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     if C_Emp_All%ISOPEN then
       close C_Emp_All;
     end if;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     if C_Emp_All%ISOPEN then
       close C_Emp_All;
     end if;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Upload_Employees;

/*For Bug No : 2434152 End*/

/* ----------------------------------------------------------------------- */
/* Bug 3867577 Start */
-- This API will actually find out the budget year start date and
-- end date for the input date. These values will be used to insert
-- the distributions for each budget year.
PROCEDURE Get_Budget_Boundaries
( x_return_status          OUT  NOCOPY  VARCHAR2,
  p_budget_year_start_date OUT  NOCOPY  DATE,
  p_budget_year_end_date   OUT  NOCOPY  DATE,
  p_input_date             IN           DATE
) IS
  l_year_index NUMBER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FOR l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years LOOP
    IF p_input_date >=
         PSB_WS_ACCT1.g_budget_years(l_year_index).start_date
      AND
       p_input_date <=
         PSB_WS_ACCT1.g_budget_years(l_year_index).end_date
    THEN
      p_budget_year_start_date
        := PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
      p_budget_year_end_date
        := PSB_WS_ACCT1.g_budget_years(l_year_index).end_date;
      /* Got the info so come out of the loop */
      EXIT;
     END IF;
   END LOOP;
   -- If any of the boundary dates are NULL, put p_return_status to FALSE
   IF p_budget_year_start_date IS NULL
       /* Bug 4060926 Start */
       OR p_budget_year_end_date IS NULL THEN
       /* Bug 4060926 End */
     x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
END Get_Budget_Boundaries;
/* Bug 3867577 End */
/* ----------------------------------------------------------------------- */

/* ----------------------------------------------------------------------- */
/* Bug 3867577 Start */
-- This API will first pick the SDE distributions those overlap with
-- upload budget year(s). then it will modify these records in such a
-- way that there should not be any overlapping. Now it will delete those
-- overlapping distributions along with the insertion of modified
-- distributions. finally it will pick WS/SDE distributions those lies in
-- between upload year, and will insert them for SDE.
PROCEDURE Upload_Salary_Distribution
( x_return_status          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id           IN           NUMBER,
  p_source_data_extract_id IN           NUMBER,
  p_target_data_extract_id IN           NUMBER,
  p_position_id            IN           NUMBER,
  p_source_DE_position_id  IN           NUMBER,
  p_from_budget_year_id    IN           NUMBER,
  p_to_budget_year_id      IN           NUMBER,
  p_position_exists        IN           BOOLEAN
) IS

  l_year_start_date        DATE; --Will hold upload year start date
  l_year_end_date          DATE; --Will hold upload year end date
  l_budget_year_start_date DATE; --Will hold budget year start date
  l_budget_year_end_date   DATE; --Will hold budget year end date
  l_distr_start_date       DATE; --Will hold curr distribution start date
  l_distr_end_date         DATE; --Will hold curr distribution end date
  l_date_val               DATE; --Local var to hold the curr date value
  l_prev_distr_date        DATE;

  -- for bug 4507389
  l_calendar_start_date    DATE;
  -- for bug 4507389

  l_record_count           NUMBER :=0;
  l_chart_of_accounts_id   NUMBER;
  l_distribution_percent   NUMBER;
  l_code_combination_id    NUMBER;
  l_distribution_id        NUMBER;
  l_pos_line_id            NUMBER;
  l_rowid                  VARCHAR2(100);
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_return_status          VARCHAR2(1);
  l_count_ins_rec          NUMBER := 0;
  --l_pos_start_date         DATE; -- commented as part of bug fix 4507389
  l_derived_end_date       DATE;  --bug:9174814

  /* Bug 4060926 Start */
  -- Variable used for the debugging.
  l_debug_info             VARCHAR2(1000);
  /* Bug 4060926 End */

  -------------------------------------------------------------------
  -- Declare three TYPES represnting required datatypes
  TYPE Number_tbl_type IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
  TYPE Char_tbl_type   IS TABLE OF VARCHAR2(365) INDEX BY BINARY_INTEGER;
  TYPE Date_tbl_type   IS TABLE OF DATE          INDEX BY BINARY_INTEGER;
  -------------------------------------------------------------------
  --Record types those will hold the "existing" SDE distributions
  rec_distribution_id        Number_tbl_type;
  rec_position_id            Number_tbl_type;
  rec_data_extract_id        Number_tbl_type;
  rec_worksheet_id           Number_tbl_type;
  rec_start_date             Date_tbl_type;
  rec_end_date               Date_tbl_type;
  rec_chart_of_accounts_id   Number_tbl_type;
  rec_code_combination_id    Number_tbl_type;
  rec_distribution_percent   Number_tbl_type;
  rec_global_default_flag    Char_tbl_type;
  rec_dist_default_rule_id   Number_tbl_type;
  rec_project_id             Number_tbl_type;
  rec_task_id                Number_tbl_type;
  rec_award_id               Number_tbl_type;
  rec_exp_type               Char_tbl_type;
  rec_exp_org_id             Number_tbl_type;
  rec_cost_alloc_key_flex_id Number_tbl_type;
  rec_description            Char_tbl_type;
  -------------------------------------------------------------------
  -- Record types those will hold the "manipulated" SDE distributions
  ins_distribution_id        Number_tbl_type;
  ins_position_id            Number_tbl_type;
  ins_data_extract_id        Number_tbl_type;
  ins_worksheet_id           Number_tbl_type;
  ins_start_date             Date_tbl_type;
  ins_end_date               Date_tbl_type;
  ins_chart_of_accounts_id   Number_tbl_type;
  ins_code_combination_id    Number_tbl_type;
  ins_distribution_percent   Number_tbl_type;
  ins_global_default_flag    Char_tbl_type;
  ins_dist_default_rule_id   Number_tbl_type;
  ins_project_id             Number_tbl_type;
  ins_task_id                Number_tbl_type;
  ins_award_id               Number_tbl_type;
  ins_exp_type               Char_tbl_type;
  ins_exp_org_id             Number_tbl_type;
  ins_cost_alloc_key_flex_id Number_tbl_type;
  ins_description            Char_tbl_type;
  -------------------------------------------------------------------
  /* Bug 4060926 Start */
  -- Empty record types used for initialization
  /*
  -- No need for the empty record types.
  emp_distribution_id        Number_tbl_type;
  emp_position_id            Number_tbl_type;
  emp_data_extract_id        Number_tbl_type;
  emp_worksheet_id           Number_tbl_type;
  emp_start_date             Date_tbl_type;
  emp_end_date               Date_tbl_type;
  emp_chart_of_accounts_id   Number_tbl_type;
  emp_code_combination_id    Number_tbl_type;
  emp_distribution_percent   Number_tbl_type;
  emp_global_default_flag    Char_tbl_type;
  emp_dist_default_rule_id   Number_tbl_type;
  emp_project_id             Number_tbl_type;
  emp_task_id                Number_tbl_type;
  emp_award_id               Number_tbl_type;
  emp_exp_type               Char_tbl_type;
  emp_exp_org_id             Number_tbl_type;
  emp_cost_alloc_key_flex_id Number_tbl_type;
  emp_description            Char_tbl_type;
  */

  -- This cursor will fetch all the overlapping "existing" SDE
  -- distributions.
  CURSOR l_SDE_pos_distr_csr
  IS
  SELECT distribution_id, position_id, data_extract_id,
         worksheet_id, effective_start_date, effective_end_date,
         chart_of_accounts_id, code_combination_id, distribution_percent,
         global_default_flag, distribution_default_rule_id, project_id,
         task_id, award_id, expenditure_type, expenditure_organization_id,
         cost_allocation_key_flex_id, description
  FROM psb_position_pay_distributions b
  WHERE (((l_year_end_date IS NOT NULL)
           AND (((b.effective_start_date <= l_year_end_date)
           AND (b.effective_end_date IS NULL))
           OR ((b.effective_start_date
                  BETWEEN l_year_start_date AND l_year_end_date)
           OR (b.effective_end_date
                  BETWEEN l_year_start_date AND l_year_end_date)
           OR ((b.effective_start_date < l_year_start_date)
           AND (b.effective_end_date   > l_year_end_date)))))
           OR ((l_year_end_date IS NULL)
           AND (nvl(b.effective_end_date, l_year_start_date)
                      >= l_year_start_date)))
  AND position_id     = p_position_id
  AND worksheet_id IS NULL
  AND data_extract_id = p_target_data_extract_id;

  -- This cursor will pull all information from worksheet table
  -- only for above position_line_ids, SDE and worksheet_id.
  CURSOR l_WS_position_distr_csr(pos_id NUMBER, pos_line_id NUMBER,
                             start_date DATE, end_date DATE)
  IS
  SELECT DISTINCT
    pos_distr.distribution_id,     pos_distr.effective_start_date,
    pos_distr.effective_end_date,  pos_distr.chart_of_accounts_id,
    pos_distr.code_combination_id, pos_distr.distribution_percent
  FROM
    PSB_POSITION_PAY_DISTRIBUTIONS pos_distr
  WHERE EXISTS
    (
     SELECT 1
     FROM psb_ws_account_lines ws_lines
     WHERE pos_distr.code_combination_id = ws_lines.code_combination_id
     AND   ws_lines.salary_account_line  = 'Y'
     AND   ws_lines.ytd_amount           <> 0
     AND   ws_lines.budget_year_id BETWEEN p_from_budget_year_id
           AND p_to_budget_year_id
     AND ws_lines.position_line_id       = pos_line_id
    )
  AND pos_distr.position_id     = pos_id
  AND (
       (pos_distr.worksheet_id  = p_worksheet_id)
        OR (pos_distr.worksheet_id IS NULL
        AND NOT EXISTS
	    (SELECT 1
         FROM PSB_POSITION_PAY_DISTRIBUTIONS pay_distr
	     WHERE pay_distr.position_id = pos_distr.position_id
	     AND pay_distr.worksheet_id  = p_worksheet_id
        )
       )
      )
--  AND b.chart_of_accounts_id = p_gl_flex_code
  AND pos_distr.code_combination_id IS NOT NULL
  AND (((end_date IS NOT NULL)
  AND (((pos_distr.effective_start_date <= end_date)
  AND (pos_distr.effective_end_date IS NULL))
  OR ((pos_distr.effective_start_date BETWEEN start_date and end_date)
  OR (pos_distr.effective_end_date BETWEEN start_date and end_date)
  OR ((pos_distr.effective_start_date < start_date)
  AND (pos_distr.effective_end_date > end_date)))))
  OR ((end_date is null)
  AND (nvl(pos_distr.effective_end_date, start_date) >= start_date)))
  ORDER BY pos_distr.effective_start_date;
  -------------------------------------------------------------------
BEGIN
  /* Bug 4060926 Start */
  SAVEPOINT Upload_Salary_Position;
  l_debug_info := ' Upload Salary Distr API starts';

  -- for bug 4507389
  -- get the calendar start date from the cache used in package PSB_WS_ACCT1
  l_calendar_start_date := PSB_WS_ACCT1.g_budget_years(1).start_date;


  /* Bug 4060926 End */
  -- Get the upload budget year start date and end date

  /*
  FOR l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years LOOP
    IF PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id
        = p_from_budget_year_id THEN
      l_year_start_date
        := PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
    END IF;

    IF PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id
        = p_to_budget_year_id THEN
      l_year_end_date
        := PSB_WS_ACCT1.g_budget_years(l_year_index).end_date;
    END IF;
  END LOOP;
  */

  -- for bug 4507389
  -- The g_year_end_date and g_year_start_date are populated
  -- in API upload_worksheet where the budget calendar is cached.
  l_year_start_date := g_year_start_date;
  l_year_end_date := g_year_end_date;


  -- If position exists in SDE then we need to check the
  -- existing distributions
  IF p_position_exists THEN
    /* Bug 4060926 Start */
    l_debug_info := ' Position'||p_position_id||' exists';
    /* Bug 4060926 End */
    -- As the position exists in the target data extract, we need to
    -- manipulate the existing distributions. It's a data fix.
    OPEN l_SDE_pos_distr_csr;
    FETCH l_SDE_pos_distr_csr BULK COLLECT INTO
      rec_distribution_id, rec_position_id, rec_data_extract_id,
      rec_worksheet_id, rec_start_date, rec_end_date,
      rec_chart_of_accounts_id, rec_code_combination_id,
      rec_distribution_percent, rec_global_default_flag,
      rec_dist_default_rule_id, rec_project_id, rec_task_id,
      rec_award_id, rec_exp_type, rec_exp_org_id,
      rec_cost_alloc_key_flex_id, rec_description;
    Close l_SDE_pos_distr_csr;

    /* Bug 4060926 Start */
    l_debug_info := ' Starting the manipulation of the existing disr.';
    /* Bug 4060926 Start */

    FOR i in 1..rec_distribution_id.count
    LOOP
      -- If distribution is not end dated, manipulate
      -- them and populate them into record type.
      IF rec_end_date(i) IS NULL THEN
        IF rec_start_date(i) < l_year_start_date THEN

          SELECT PSB_POSITION_PAY_DISTR_S.NEXTVAL
          INTO l_distribution_id
          FROM dual;

          l_count_ins_rec                      := l_count_ins_rec + 1;
          ins_distribution_id(l_count_ins_rec) := l_distribution_id;
          ins_position_id(l_count_ins_rec)     := p_position_id;
          ins_data_extract_id(l_count_ins_rec)
            := p_target_data_extract_id;
          ins_worksheet_id(l_count_ins_rec) := NULL;
          ins_start_date(l_count_ins_rec)   := rec_start_date(i);
          ins_end_date(l_count_ins_rec)     := l_year_start_date - 1;
          ins_chart_of_accounts_id(l_count_ins_rec)
            := rec_chart_of_accounts_id(i);
          ins_code_combination_id(l_count_ins_rec)
            := rec_code_combination_id(i);
          ins_distribution_percent(l_count_ins_rec)
            := rec_distribution_percent(i);
          ins_global_default_flag(l_count_ins_rec)
            := rec_global_default_flag(i);
          ins_dist_default_rule_id(l_count_ins_rec)
            := rec_dist_default_rule_id(i);
          ins_project_id(l_count_ins_rec)  := rec_project_id(i);
          ins_task_id (l_count_ins_rec)    := rec_task_id(i);
          ins_award_id(l_count_ins_rec)    := rec_award_id(i);
          ins_exp_type(l_count_ins_rec)    := rec_exp_type(i);
          ins_exp_org_id(l_count_ins_rec)  := rec_exp_org_id(i);
          ins_cost_alloc_key_flex_id(l_count_ins_rec)
            := rec_cost_alloc_key_flex_id(i);
          ins_description(l_count_ins_rec) := rec_description(i);
        END IF;

        /*SELECT PSB_POSITION_PAY_DISTR_S.NEXTVAL
        INTO l_distribution_id
        FROM dual;

        l_count_ins_rec                      := l_count_ins_rec + 1;
        ins_distribution_id(l_count_ins_rec) := l_distribution_id;
        ins_position_id(l_count_ins_rec)     := p_position_id;
        ins_data_extract_id(l_count_ins_rec)
          := p_target_data_extract_id;
        ins_worksheet_id(l_count_ins_rec) := NULL;
        ins_start_date(l_count_ins_rec)   := l_year_end_date + 1;
        ins_end_date(l_count_ins_rec)     := NULL;
        ins_chart_of_accounts_id(l_count_ins_rec)
          := rec_chart_of_accounts_id(i);
        ins_code_combination_id(l_count_ins_rec)
          := rec_code_combination_id(i);
        ins_distribution_percent(l_count_ins_rec)
          := rec_distribution_percent(i);
        ins_global_default_flag(l_count_ins_rec)
          := rec_global_default_flag(i);
        ins_dist_default_rule_id(l_count_ins_rec)
          := rec_dist_default_rule_id(i);
        ins_project_id(l_count_ins_rec)  := rec_project_id(i);
        ins_task_id (l_count_ins_rec)    := rec_task_id(i);
        ins_award_id(l_count_ins_rec)    := rec_award_id(i);
        ins_exp_type(l_count_ins_rec)    := rec_exp_type(i);
        ins_exp_org_id(l_count_ins_rec)  := rec_exp_org_id(i);
        ins_cost_alloc_key_flex_id(l_count_ins_rec)
          := rec_cost_alloc_key_flex_id(i);
        ins_description(l_count_ins_rec) := rec_description(i);*/

      -- If distribution is end dated
      ELSE
        IF rec_start_date(i) < l_year_start_date THEN

          SELECT PSB_POSITION_PAY_DISTR_S.NEXTVAL
          INTO l_distribution_id
          FROM dual;

          l_count_ins_rec                      := l_count_ins_rec + 1;
          ins_distribution_id(l_count_ins_rec) := l_distribution_id;
          ins_position_id(l_count_ins_rec)     := p_position_id;
          ins_data_extract_id(l_count_ins_rec)
            := p_target_data_extract_id;
          ins_worksheet_id(l_count_ins_rec) := NULL;
          ins_start_date(l_count_ins_rec) := rec_start_date(i);
          ins_end_date(l_count_ins_rec)   := l_year_start_date - 1;
          ins_chart_of_accounts_id(l_count_ins_rec)
            := rec_chart_of_accounts_id(i);
          ins_code_combination_id(l_count_ins_rec)
            := rec_code_combination_id(i);
          ins_distribution_percent(l_count_ins_rec)
            := rec_distribution_percent(i);
          ins_global_default_flag(l_count_ins_rec)
            := rec_global_default_flag(i);
          ins_dist_default_rule_id(l_count_ins_rec)
            := rec_dist_default_rule_id(i);
          ins_project_id(l_count_ins_rec)  := rec_project_id(i);
          ins_task_id (l_count_ins_rec)    := rec_task_id(i);
          ins_award_id(l_count_ins_rec)    := rec_award_id(i);
          ins_exp_type(l_count_ins_rec)    := rec_exp_type(i);
          ins_exp_org_id(l_count_ins_rec)  := rec_exp_org_id(i);
          ins_cost_alloc_key_flex_id(l_count_ins_rec)
            := rec_cost_alloc_key_flex_id(i);
          ins_description(l_count_ins_rec) := rec_description(i);

          IF rec_end_date(i) > l_year_end_date THEN

            SELECT PSB_POSITION_PAY_DISTR_S.NEXTVAL
            INTO l_distribution_id
            FROM dual;

            l_count_ins_rec                      := l_count_ins_rec + 1;
            ins_distribution_id(l_count_ins_rec) := l_distribution_id;
            ins_position_id(l_count_ins_rec)     := p_position_id;
            ins_data_extract_id(l_count_ins_rec)
              := p_target_data_extract_id;
            ins_worksheet_id(l_count_ins_rec) := NULL;
            ins_start_date(l_count_ins_rec)   := l_year_end_date + 1;
            ins_end_date(l_count_ins_rec)     := rec_end_date(i);
            ins_chart_of_accounts_id(l_count_ins_rec)
              := rec_chart_of_accounts_id(i);
            ins_code_combination_id(l_count_ins_rec)
              := rec_code_combination_id(i);
            ins_distribution_percent(l_count_ins_rec)
              := rec_distribution_percent(i);
            ins_global_default_flag(l_count_ins_rec)
              := rec_global_default_flag(i);
            ins_dist_default_rule_id(l_count_ins_rec)
              := rec_dist_default_rule_id(i);
            ins_project_id(l_count_ins_rec)  := rec_project_id(i);
            ins_task_id (l_count_ins_rec)    := rec_task_id(i);
            ins_award_id(l_count_ins_rec)    := rec_award_id(i);
            ins_exp_type(l_count_ins_rec)    := rec_exp_type(i);
            ins_exp_org_id(l_count_ins_rec)  := rec_exp_org_id(i);
            ins_cost_alloc_key_flex_id(l_count_ins_rec)
              := rec_cost_alloc_key_flex_id(i);
            ins_description(l_count_ins_rec) := rec_description(i);
          END IF;
        ELSE
          -- Here we are only considering those records whose start date
          -- is in between upload start date and end date and end date is
          -- not between upload start date and end date. If so, then do
          -- nothing. These records will automatically be deleted.
          IF rec_end_date(i) > l_year_end_Date THEN

            SELECT PSB_POSITION_PAY_DISTR_S.NEXTVAL
            INTO l_distribution_id
            FROM dual;

            l_count_ins_rec                      := l_count_ins_rec + 1;
            ins_distribution_id(l_count_ins_rec) := l_distribution_id;
            ins_position_id(l_count_ins_rec)     := p_position_id;
            ins_data_extract_id(l_count_ins_rec)
              := p_target_data_extract_id;
            ins_worksheet_id(l_count_ins_rec) := NULL;
            ins_start_date(l_count_ins_rec)   := l_year_end_date + 1;
            ins_end_date(l_count_ins_rec)     := rec_end_date(i);
            ins_chart_of_accounts_id(l_count_ins_rec)
              := rec_chart_of_accounts_id(i);
            ins_code_combination_id(l_count_ins_rec)
              := rec_code_combination_id(i);
            ins_distribution_percent(l_count_ins_rec)
              := rec_distribution_percent(i);
            ins_global_default_flag(l_count_ins_rec)
              := rec_global_default_flag(i);
            ins_dist_default_rule_id(l_count_ins_rec)
              := rec_dist_default_rule_id(i);
            ins_project_id(l_count_ins_rec)  := rec_project_id(i);
            ins_task_id (l_count_ins_rec)    := rec_task_id(i);
            ins_award_id(l_count_ins_rec)    := rec_award_id(i);
            ins_exp_type(l_count_ins_rec)    := rec_exp_type(i);
            ins_exp_org_id(l_count_ins_rec)  := rec_exp_org_id(i);
            ins_cost_alloc_key_flex_id(l_count_ins_rec)
              := rec_cost_alloc_key_flex_id(i);
            ins_description(l_count_ins_rec) := rec_description(i);
          END IF;
        END IF;
      END IF;
    END LOOP;

    /* Bug 4060926 Start */
    l_debug_info := ' Manipulation of the existing disr completed.';
    /* Bug 4060926 Start */

    -- Now manipulated distributions are in the PL/SQL table.
    -- Delete c_pos_distr records and insert PL/SQL table records.

    FORALL i in 1..rec_distribution_id.COUNT
      DELETE FROM psb_position_pay_distributions
        WHERE distribution_id = rec_distribution_id(i);

    /* Bug 4060926 Start */
    l_debug_info := ' Bulk Deletion of the existing disr completed.';
    /* Bug 4060926 Start */

    FORALL i in 1..l_count_ins_rec
      INSERT INTO psb_position_pay_distributions(
        distribution_id, position_id, data_extract_id,
        worksheet_id, effective_start_date, effective_end_date,
        chart_of_accounts_id, code_combination_id, distribution_percent,
        global_default_flag, distribution_default_rule_id, project_id,
        task_id, award_id, expenditure_type, expenditure_organization_id,
        cost_allocation_key_flex_id, description, last_update_date,
        last_updated_by, last_update_login, created_by, creation_date)
     VALUES(
        ins_distribution_id(i), ins_position_id(i), ins_data_extract_id(i),
        ins_worksheet_id(i), ins_start_date(i), ins_end_date(i),
        ins_chart_of_accounts_id(i), ins_code_combination_id(i),
        ins_distribution_percent(i), ins_global_default_flag(i),
        ins_dist_default_rule_id(i), ins_project_id(i), ins_task_id(i),
        ins_award_id(i), ins_exp_type(i), ins_exp_org_id(i),
        ins_cost_alloc_key_flex_id(i), ins_description(i),
        SYSDATE, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID,
        FND_GLOBAL.USER_ID, SYSDATE
        );
    /* Bug 4060926 Start */
    l_debug_info := ' Bulk Insertion of the manipulated disr completed.';
    /* Bug 4060926 End */
  END IF;

    /* Bug 4060926 Start */
    l_debug_info := ' Out of the if block for existing positions.';
    /* Bug 4060926 End */


  -- Reinitialize the types
  l_count_ins_rec            := 0;

  /* Bug 4060926 Start */
  rec_distribution_id.DELETE;
  rec_position_id.DELETE;
  rec_data_extract_id.DELETE;
  rec_worksheet_id.DELETE;
  rec_start_date.DELETE;
  rec_end_date.DELETE;
  rec_chart_of_accounts_id.DELETE;
  rec_code_combination_id.DELETE;
  rec_distribution_percent.DELETE;
  rec_global_default_flag.DELETE;
  rec_dist_default_rule_id.DELETE;
  rec_project_id.DELETE;
  rec_task_id.DELETE;
  rec_award_id.DELETE;
  rec_exp_type.DELETE;
  rec_exp_org_id.DELETE;
  rec_cost_alloc_key_flex_id.DELETE;
  rec_description.DELETE;

  ins_distribution_id.DELETE;
  ins_position_id.DELETE;
  ins_data_extract_id.DELETE;
  ins_worksheet_id.DELETE;
  ins_start_date.DELETE;
  ins_end_date.DELETE;
  ins_chart_of_accounts_id.DELETE;
  ins_code_combination_id.DELETE;
  ins_distribution_percent.DELETE;
  ins_global_default_flag.DELETE;
  ins_dist_default_rule_id.DELETE;
  ins_project_id.DELETE;
  ins_task_id.DELETE;
  ins_award_id.DELETE;
  ins_exp_type.DELETE;
  ins_exp_org_id.DELETE;
  ins_cost_alloc_key_flex_id.DELETE;
  ins_description.DELETE;

  /* Bug 4060926 Start */
  -- No need of getting the position_start_date as this
  -- check no more exists.
  /*
  SELECT effective_start_date INTO l_pos_start_date
  FROM  psb_positions psb_pos
  WHERE psb_pos.position_id = p_source_DE_position_id;
  */


  -- fnd_file.put_line(fnd_file.log, ' Position start date : '||l_pos_start_date); -- commented as part of fix 4507389

  /* Bug 4060926 End */

  -- Now the SDE is containing the manipulated distributions. Fetch
  -- the relevent WS/SDE distributions and insert them directly after
  -- manipulating them.

  -- This statment will pull the position_line_ids from worksheet table
  -- those are existing in the worksheet to be uploaded.
  SELECT psb_pos_lines.position_line_id INTO l_pos_line_id
  FROM psb_ws_position_lines psb_pos_lines,
       psb_ws_lines_positions psb_lines_pos
  WHERE psb_pos_lines.position_line_id   = psb_lines_pos.position_line_id
  AND   psb_pos_lines.position_id        = p_source_DE_position_id
  AND   psb_lines_pos.worksheet_id       = p_worksheet_id;

  OPEN l_WS_position_distr_csr(p_source_DE_position_id, l_pos_line_id,
                               l_year_start_date, l_year_end_date
                              );
  FETCH l_WS_position_distr_csr BULK COLLECT INTO
    rec_distribution_id, rec_start_date,
    rec_end_date, rec_chart_of_accounts_id,
    rec_code_combination_id, rec_distribution_percent;
  CLOSE l_WS_position_distr_csr;

  /* Bug 4060926 Start */
  l_debug_info := ' Got all the distr existing in the ws to be uploaded';
  /* Bug 4060926 End */

  IF rec_distribution_id.FIRST IS NOT NULL
    AND rec_distribution_id.LAST IS NOT NULL
  THEN
    FOR indx IN rec_distribution_id.FIRST..rec_distribution_id.LAST
    LOOP
      BEGIN

        l_distr_start_date := rec_start_date(indx);
        l_distr_end_date   := rec_end_date(indx);

        -- If the position does not exist in the SDE, then
        -- we need to maintain the distribution from the start
        /*IF l_distr_start_date = l_pos_start_date
             AND
             p_position_exists = FALSE
        THEN
          SELECT PSB_POSITION_PAY_DISTR_S.NEXTVAL
          INTO l_distribution_id
          FROM dual;

          l_count_ins_rec                      := l_count_ins_rec + 1;
          ins_distribution_id(l_count_ins_rec) := l_distribution_id;
          ins_start_date(l_count_ins_rec)      := l_distr_start_date;
          ins_end_date(l_count_ins_rec)        := l_year_start_date - 1;
          ins_chart_of_accounts_id(l_count_ins_rec)
            := rec_chart_of_accounts_id(indx);
          ins_code_combination_id(l_count_ins_rec)
            := rec_code_combination_id(indx);
          ins_distribution_percent(l_count_ins_rec)
            := rec_distribution_percent(indx);
        END IF;*/

        -- IF end dating is done, we need to break them for budget
        -- year boundaries.
        IF l_distr_end_date is NOT NULL THEN
          -- If this is the first record then start with
          -- l_year_start_date otherwise start with l_distr_start_date.
          /* Bug 4060926 Start */
          --IF l_pos_start_date = l_distr_start_date THEN

	  --for bug 4507389 -- used l_date_val instead of l_record_count
          --IF l_record_count = 1 THEN
 	  IF ((l_date_val IS NULL)
 	     OR (l_distr_start_date < l_year_start_date)) THEN  --bug:9174814
          /* Bug 4060926 End */
            -- This is the first distribution
            l_date_val             := l_year_start_date;
            l_budget_year_end_date := l_year_start_date;
          ELSE
            l_date_val             := l_distr_start_date;
            l_budget_year_end_date := l_distr_start_date;
          END IF;

          /*bug:9174814:start*/
           if l_distr_end_date <= l_year_end_date then
              l_derived_end_date := l_distr_end_date;
           else
              l_derived_end_date := l_year_end_date;
           end if;
          /*bug:9174814:end*/

  /* bug:9174814:replaced l_distr_end_date with l_derived_end_date */
          WHILE( l_budget_year_end_date < l_derived_end_date)
          LOOP
            Get_Budget_Boundaries
             (x_return_status          => l_return_status,
              p_budget_year_start_date => l_budget_year_start_date,
              p_budget_year_end_date   => l_budget_year_end_date,
              p_input_date             => l_date_val
             );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              /* Bug 4060926 Start */
              l_debug_info := ' Error from 1st Get_Bud_bondaries API::>'
                                ||l_date_val||','||l_budget_year_start_date
                                ||l_budget_year_end_date;
              /* Bug 4060926 End */
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            -- If current record is end dated in mid year then next
            -- iteration of above call will give l_budget_year_start_date as
            -- last_budget_year_start date, so we need to expand this value.
            IF l_budget_year_start_date < l_date_val THEN
              l_budget_year_start_date := l_date_val;
            END IF;
            -- If current record is again end dated in mid year then the
            -- current iteration of above call will give
            -- l_budget_year_end_date as last_budget_year_end date,
            -- so we need to cut down this value.

            IF l_budget_year_end_date > l_distr_end_date then
              l_budget_year_end_date  := l_distr_end_date;
             END IF;

            IF(l_budget_year_end_date <= l_distr_end_date) THEN

              SELECT PSB_POSITION_PAY_DISTR_S.NEXTVAL
              INTO l_distribution_id
              FROM dual;
              l_count_ins_rec                      := l_count_ins_rec + 1;
              ins_distribution_id(l_count_ins_rec) := l_distribution_id;
              ins_start_date(l_count_ins_rec)      := l_budget_year_start_date;
              ins_end_date(l_count_ins_rec)        := l_budget_year_end_date;
              ins_chart_of_accounts_id(l_count_ins_rec)
                := rec_chart_of_accounts_id(indx);
              ins_code_combination_id(l_count_ins_rec)
                := rec_code_combination_id(indx);
              ins_distribution_percent(l_count_ins_rec)
                := rec_distribution_percent(indx);

              l_date_val := l_budget_year_end_date + 1;

            -- Insert the end dated distribution
            ELSE
              SELECT PSB_POSITION_PAY_DISTR_S.NEXTVAL
              INTO l_distribution_id
              FROM dual;

              l_count_ins_rec                      := l_count_ins_rec + 1;
              ins_distribution_id(l_count_ins_rec) := l_distribution_id;
              ins_start_date(l_count_ins_rec)      := l_date_val;
              ins_end_date(l_count_ins_rec)        := l_distr_end_date;
              ins_chart_of_accounts_id(l_count_ins_rec)
                := rec_chart_of_accounts_id(indx);
              ins_code_combination_id(l_count_ins_rec)
                := rec_code_combination_id(indx);
              ins_distribution_percent(l_count_ins_rec)
                := rec_distribution_percent(indx);

              l_date_val := l_budget_year_end_date + 1;
            END IF;
          END LOOP;
        -- The current record is not end dated
        ELSE
          /* Bug 4060926 Start */
          --IF l_pos_start_date = l_distr_start_date THEN

	  --for bug 4507389 -- used l_date_val instead of l_record_count
          --IF l_record_count = 1 THEN
	    IF l_date_val IS NULL THEN
          /* Bug 4060926 End */
              -- This is the first distribution
              l_date_val := l_year_start_date;
            ELSE
	      -- for bug 4507389
	      -- Added an if condition which checks if the distributiuon
	      -- start date falls outside the calendar start date. If yes
	      -- push it to budget year start date
	      IF l_distr_start_date < l_calendar_start_date THEN
	        l_date_val := l_year_start_date;
	      ELSE
                l_date_val := l_distr_start_date;
	      END IF;
            END IF;

          l_budget_year_start_date := l_date_val;
          WHILE(l_budget_year_start_date < l_year_end_date)
          LOOP
            Get_Budget_Boundaries
             (x_return_status          => l_return_status,
              p_budget_year_start_date => l_budget_year_start_date,
              p_budget_year_end_date   => l_budget_year_end_date,
              p_input_date             => l_date_val
             );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              /* Bug 4060926 Start */
              l_debug_info := ' Error from 2nd Get_Bud_bondaries API::>'
                                ||l_date_val||','||l_budget_year_start_date
                                ||l_budget_year_end_date||','||p_position_id;
              /* Bug 4060926 End */
              RAISE FND_API.G_EXC_ERROR;
            END IF;

            SELECT PSB_POSITION_PAY_DISTR_S.NEXTVAL
            INTO l_distribution_id
            FROM dual;
            l_count_ins_rec                      := l_count_ins_rec + 1;
            ins_distribution_id(l_count_ins_rec) := l_distribution_id;
            ins_start_date(l_count_ins_rec)      := l_date_val;
            ins_end_date(l_count_ins_rec)        := l_budget_year_end_date;
            ins_chart_of_accounts_id(l_count_ins_rec)
              := rec_chart_of_accounts_id(indx);
            ins_code_combination_id(l_count_ins_rec)
              := rec_code_combination_id(indx);
            ins_distribution_percent(l_count_ins_rec)
              := rec_distribution_percent(indx);

            l_budget_year_start_date := l_budget_year_end_date + 1;
            l_date_val               := l_budget_year_start_date;
          END LOOP;

          /*-- Populate the PL/SQL table with a non end dated record
          -- for the open ws record.
          SELECT PSB_POSITION_PAY_DISTR_S.NEXTVAL
          INTO l_distribution_id
          FROM dual;

          l_count_ins_rec                      := l_count_ins_rec + 1;
          ins_distribution_id(l_count_ins_rec) := l_distribution_id;
          ins_start_date(l_count_ins_rec)      := l_year_end_date + 1;
          ins_end_date(l_count_ins_rec)        := NULL;
          ins_chart_of_accounts_id(l_count_ins_rec)
            := rec_chart_of_accounts_id(indx);
          ins_code_combination_id(l_count_ins_rec)
            := rec_code_combination_id(indx);
          ins_distribution_percent(l_count_ins_rec)
            := rec_distribution_percent(indx);*/
        END IF;
      END;
      l_prev_distr_date := rec_start_date(indx);

    END LOOP;
  END IF;

  /* Bug 4060926 Start */
  l_debug_info := ' The PL/SQL table is now ready for the final DML.';
  /* Bug 4060926 End */

  -- Finally do the DML for the PL/SQL table
  FOR indx IN 1..l_count_ins_rec
  LOOP

    PSB_POSITION_PAY_DISTR_PVT.Modify_Distribution
     (p_api_version                  => 1.0,
      p_return_status                => l_return_status,
      p_msg_count                    => l_msg_count,
      p_msg_data                     => l_msg_data,
      p_distribution_id              => ins_distribution_id(indx),
      p_position_id                  => p_position_id,
      p_data_extract_id              => p_target_data_extract_id,
      p_worksheet_id                 => NULL,
      p_effective_start_date         => ins_start_date(indx),
      p_effective_end_date           => ins_end_date(indx),
      p_chart_of_accounts_id         => ins_chart_of_accounts_id(indx),
      p_code_combination_id          => ins_code_combination_id(indx),
      p_distribution_percent         => ins_distribution_percent(indx),
      p_global_default_flag          => NULL,
      p_distribution_default_rule_id => NULL,
      p_rowid                        => l_rowid,
      p_project_id                   => NULL,
      p_task_id                      => NULL,
      p_award_id                     => NULL,
      p_expenditure_type             => NULL,
      p_expenditure_organization_id  => NULL,
      p_description                  => NULL
     );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       /* Bug 4060926 Start */
       l_debug_info := ' Error from Mod_distr API for '||p_position_id;
       /* Bug 4060926 End */
       RAISE FND_API.G_EXC_ERROR;
     END IF;
  END LOOP;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    /* Bug 4060926 Star */
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_debug_info);
    /* Bug 4060926 End */
    ROLLBACK TO Upload_Salary_Position;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    /* Bug 4060926 Star */
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_debug_info);
    /* Bug 4060926 End */
    ROLLBACK TO Upload_Salary_Position;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    /* Bug 4060926 Star */
    FND_FILE.PUT_LINE(FND_FILE.LOG, l_debug_info);
    /* Bug 4060926 End */
    ROLLBACK TO Upload_Salary_Position;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Upload_Salary_Distribution;
/* ----------------------------------------------------------------------- */
/* Bug 3867577 End */

/* ----------------------------------------------------------------------- */
PROCEDURE Upload_Positions
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_worksheet_id            IN   NUMBER,
  p_budget_calendar_id      IN   NUMBER,
  p_flex_mapping_set_id     IN   NUMBER,
  p_source_data_extract_id  IN   NUMBER,
  p_target_data_extract_id  IN   NUMBER,
  /* Bug 3867577 Start */
  -- Need to have the upload budget year ids.
  p_from_budget_year_id     IN   NUMBER,
  p_to_budget_year_id       IN   NUMBER
  /* Bug 3867577 End */
) IS

  l_position_assignment_id  NUMBER;
  l_pay_element_id          NUMBER;
  l_pay_element_option_id   NUMBER;
  l_position_id             NUMBER;
  l_attribute_value_id      NUMBER;
  l_distribution_id         NUMBER;
  l_employee_id             NUMBER;

  l_mapped_ccid             NUMBER;
  l_budget_year_type_id     NUMBER;

  l_year_start_date         DATE;
  l_year_end_date           DATE;

  l_position_exists         BOOLEAN;

  l_rowid                   VARCHAR2(100);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_return_status           VARCHAR2(1);

  l_position_ctr            NUMBER := 0;

  /*For Bug No : 2434152 Start*/
  TYPE num20_arr    IS TABLE OF NUMBER(20);
  TYPE attr_value   IS TABLE OF PSB_ATTRIBUTE_VALUES.ATTRIBUTE_VALUE%TYPE;
  TYPE date_arr     IS TABLE OF DATE;

  TYPE attr_val_rec IS RECORD (attribute_id num20_arr, attribute_value_id num20_arr,attribute_value attr_value,effective_start_date date_arr,effective_end_date date_arr);
  l_attr_val        attr_val_rec;
  /*For Bug No : 2434152 End*/

  /* Bug 3867577 Start */
  -- This local variable will be used to determine the
  -- calling of API Upload_Salary_distribution.
  l_pos_distr_cnt  NUMBER;
  /* Bug 3867577 End */



  cursor c_positions is
    select pos.position_id, pos.position_definition_id, pos.hr_position_id, pos.hr_employee_id,pos.organization_id,
	   pos.business_group_id, pos.effective_start_date, pos.effective_end_date,
	   pos.set_of_books_id, pos.vacant_position_flag, pos.availability_status,
	   pos.transaction_id, pos.transaction_status, pos.new_position_flag,
	   pos.attribute1, pos.attribute2, pos.attribute3, pos.attribute4, pos.attribute5,
	   pos.attribute6, pos.attribute7, pos.attribute8, pos.attribute9, pos.attribute10,
	   pos.attribute11, pos.attribute12, pos.attribute13, pos.attribute14, pos.attribute15,
	   pos.attribute16, pos.attribute17, pos.attribute18, pos.attribute19, pos.attribute20,
	   pos.attribute_category, pos.name, wpl.budget_group_id
      from PSB_POSITIONS pos,
	   PSB_WS_POSITION_LINES wpl,
	   PSB_WS_LINES_POSITIONS wlp
     where data_extract_id = p_source_data_extract_id
       and wpl.position_id = pos.position_id
       and wlp.worksheet_id = p_worksheet_id
       and wlp.position_line_id = wpl.position_line_id;

 cursor c_position_exists (posname VARCHAR2, hrempid NUMBER, hrposid NUMBER) is
    select position_id
      from PSB_POSITIONS
     where name = posname
       and data_extract_id = p_target_data_extract_id
       and hr_position_id = hrposid
       -- For Bug number 2931727
       -- and (hrempid is null or hr_employee_id = hrempid);
       and (((hrempid is not null) and ((hr_employee_id = hrempid)
              or ((hr_employee_id is null) and
             not exists
             (select 1 from psb_positions
               where hr_position_id = hrposid
                 and hr_employee_id = hrempid
                 and data_extract_id = p_target_data_extract_id))))
            or ((hrempid is null) and (hr_employee_id is null)));

  cursor c_posassign_attr (positionid NUMBER) is
    select pas.attribute_id,
	   pas.attribute_value_id,
	   decode(pas.attribute_value_id,null,pas.attribute_value,patv.attribute_value) attribute_value,
	   pas.effective_start_date,
	   pas.effective_end_date
      from PSB_POSITION_ASSIGNMENTS pas,
	   PSB_ATTRIBUTES pat,
	   PSB_ATTRIBUTE_VALUES patv
     where pas.position_id = positionid
       and pas.assignment_type = 'ATTRIBUTE'
       and ((pas.worksheet_id = p_worksheet_id)
	 or (worksheet_id is null
	  and not exists
	  (select 1 from psb_position_assignments c
	    where c.position_id = positionid
	      and c.attribute_id = pas.attribute_id
	      and c.worksheet_id = p_worksheet_id)))
       and pas.attribute_id = pat.attribute_id
       and pas.attribute_value_id = patv.attribute_value_id(+);

  cursor c_re_attrval (attrvalid NUMBER) is
    select a.attribute_value_id
      from PSB_ATTRIBUTE_VALUES a,
	   PSB_ATTRIBUTE_VALUES b
     where a.data_extract_id = p_target_data_extract_id
       and a.attribute_value = b.attribute_value
       and a.attribute_id    = b.attribute_id -- added for Bug#4262388
       and b.attribute_value_id = attrvalid;

  cursor c_posassign_elem (positionid NUMBER) is
    select pas.pay_element_id,
	   pas.pay_element_option_id,
	   pas.pay_element_rate_id,
	   pas.effective_start_date,
	   pas.effective_end_date,
	   pas.element_value,
	   pas.element_value_type,
	   pas.currency_code,
	   pas.pay_basis
      from PSB_POSITION_ASSIGNMENTS pas,
	   PSB_PAY_ELEMENTS pe
     where pas.position_id = positionid
       and pas.assignment_type = 'ELEMENT'
       and ((pas.worksheet_id = p_worksheet_id)
	 or (worksheet_id is null
	  and not exists
	     (select 1 from PSB_POSITION_ASSIGNMENTS c
	       where c.position_id = positionid
		 and c.pay_element_id = pas.pay_element_id
		 and c.worksheet_id = p_worksheet_id)))
       and pas.pay_element_id = pe.pay_element_id;

  cursor c_re_elem (elemid NUMBER) is
    select a.pay_element_id
      from PSB_PAY_ELEMENTS a,
	   PSB_PAY_ELEMENTS b
     where a.name = b.name
       and a.data_extract_id = p_target_data_extract_id
       and b.pay_element_id = elemid;

  cursor c_re_elemopt (elemid NUMBER, elemoptid NUMBER) is
    select a.pay_element_option_id
      from PSB_PAY_ELEMENT_OPTIONS a,
	   PSB_PAY_ELEMENT_OPTIONS b
     where a.name = b.name
       and a.pay_element_id = elemid
       and b.pay_element_option_id = elemoptid
       and nvl(a.sequence_number, -1) = nvl(b.sequence_number, -1);

  cursor c_posassign_emp (positionid NUMBER) is
    select *
      from PSB_POSITION_ASSIGNMENTS pas
     where pas.position_id = positionid
       and pas.assignment_type = 'EMPLOYEE'
       and ((pas.worksheet_id = p_worksheet_id)
	 or (pas.worksheet_id is null
       and not exists
	  (select 1 from PSB_POSITION_ASSIGNMENTS c
	    where c.position_id = positionid
	      and c.primary_employee_flag = 'Y'
	      and c.worksheet_id = p_worksheet_id)));

  cursor c_re_emp (empid NUMBER) is
    select a.employee_id
      from PSB_EMPLOYEES a,
	   PSB_EMPLOYEES b
     /*For Bug No : 2434152 Start*/
     --where a.employee_number = b.employee_number
     where a.hr_employee_id = b.hr_employee_id
     /*For Bug No : 2434152 End*/
       and a.data_extract_id = p_target_data_extract_id
       and b.employee_id = empid;

  cursor c_position_distr (positionid NUMBER) is
    select *
      from PSB_POSITION_PAY_DISTRIBUTIONS a
     where a.position_id = positionid
       and ((a.worksheet_id = p_worksheet_id)
	 or (a.worksheet_id is null
       and not exists
	  (select 1 from PSB_POSITION_PAY_DISTRIBUTIONS c
	    where c.position_id = positionid
	      and c.worksheet_id = p_worksheet_id)));

  cursor c_pos_seq is
    select PSB_POSITIONS_S.NEXTVAL seq
      from dual;

  cursor c_posassign_seq is
    select PSB_POSITION_ASSIGNMENTS_S.NEXTVAL seq
      from dual;

  cursor c_posdistr_seq is
    select PSB_POSITION_PAY_DISTR_S.NEXTVAL seq
      from dual;

BEGIN

  -- Loop for all positions in the source data extract

  for c_positions_rec in c_positions loop
    /* Bug 3867577 Start */
    l_pos_distr_cnt := 0;
    /* Bug 3867577 End */

    l_position_ctr := l_position_ctr + 1;

    if l_position_ctr = g_checkpoint_save THEN
      commit work;
      l_position_ctr := 0;
    end if;

    l_position_exists := FALSE;

    for c_position_exists_rec in c_position_exists (c_positions_rec.name, c_positions_rec.hr_employee_id, c_positions_rec.hr_position_id) loop
      l_position_exists := TRUE;
      l_position_id := c_position_exists_rec.position_id;
    end loop;

    -- If position does not exist in the target data extract create the position

    if not l_position_exists then
    begin

      for c_pos_seq_rec in c_pos_seq loop
	l_position_id := c_pos_seq_rec.seq;
      end loop;

      PSB_POSITIONS_PVT.Insert_Row
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_rowid => l_rowid,
	  p_position_id => l_position_id,
	  p_budget_group_id => c_positions_rec.budget_group_id,
	  p_data_extract_id => p_target_data_extract_id,
	  p_position_definition_id => c_positions_rec.position_definition_id,
	  p_hr_position_id => c_positions_rec.hr_position_id,
	  p_hr_employee_id => c_positions_rec.hr_employee_id,
	  p_business_group_id => c_positions_rec.business_group_id,
	  -- de by org
	  p_organization_id => c_positions_rec.organization_id,
	  p_effective_start_date => c_positions_rec.effective_start_date,
	  p_effective_end_date => c_positions_rec.effective_end_date,
	  p_set_of_books_id => c_positions_rec.set_of_books_id,
	  p_vacant_position_flag => c_positions_rec.vacant_position_flag,
	  p_availability_status => c_positions_rec.availability_status,
	  p_transaction_id => c_positions_rec.transaction_id,
	  p_transaction_status => c_positions_rec.transaction_status,
	  p_attribute1 => c_positions_rec.attribute1,
	  p_attribute2 => c_positions_rec.attribute2,
	  p_attribute3 => c_positions_rec.attribute3,
	  p_attribute4 => c_positions_rec.attribute4,
	  p_attribute5 => c_positions_rec.attribute5,
	  p_attribute6 => c_positions_rec.attribute6,
	  p_attribute7 => c_positions_rec.attribute7,
	  p_attribute8 => c_positions_rec.attribute8,
	  p_attribute9 => c_positions_rec.attribute9,
	  p_attribute10 => c_positions_rec.attribute10,
	  p_attribute11 => c_positions_rec.attribute11,
	  p_attribute12 => c_positions_rec.attribute12,
	  p_attribute13 => c_positions_rec.attribute13,
	  p_attribute14 => c_positions_rec.attribute14,
	  p_attribute15 => c_positions_rec.attribute15,
	  p_attribute16 => c_positions_rec.attribute16,
	  p_attribute17 => c_positions_rec.attribute17,
	  p_attribute18 => c_positions_rec.attribute18,
	  p_attribute19 => c_positions_rec.attribute19,
	  p_attribute20 => c_positions_rec.attribute20,
	  p_attribute_category => c_positions_rec.attribute_category,
	  p_name => c_positions_rec.name);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      -- Upload Position Attribute Assignments
      open c_posassign_attr(c_positions_rec.position_id);
      loop
	fetch c_posassign_attr BULK COLLECT INTO l_attr_val.attribute_id,l_attr_val.attribute_value_id,
						l_attr_val.attribute_value,l_attr_val.effective_start_date,
						l_attr_val.effective_end_date LIMIT g_limit_bulk_numrows;

	for l_attr_index in 1..l_attr_val.attribute_id.count loop

	  if l_attr_val.attribute_value_id(l_attr_index) is not null then
	  begin

	    for c_re_attrval_rec in c_re_attrval (l_attr_val.attribute_value_id(l_attr_index)) loop
	      l_attribute_value_id := c_re_attrval_rec.attribute_value_id;
	    end loop;

	  end;
	  else
	    l_attribute_value_id := null;
	  end if;

	  for c_posassign_seq_rec in c_posassign_seq loop
	    l_position_assignment_id := c_posassign_seq_rec.seq;
	  end loop;

	  PSB_POSITION_ASSIGNMENTS_PVT.Insert_Row
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_rowid => l_rowid,
	    p_position_assignment_id => l_position_assignment_id,
	    p_data_extract_id => p_target_data_extract_id,
	    p_worksheet_id => null,
	    p_position_id => l_position_id,
	    p_assignment_type => 'ATTRIBUTE',
	    p_attribute_id => l_attr_val.attribute_id(l_attr_index),
	    p_attribute_value_id => l_attribute_value_id,
	    p_attribute_value => l_attr_val.attribute_value(l_attr_index),
	    p_pay_element_id => null,
	    p_pay_element_option_id => null,
	    p_effective_start_date => l_attr_val.effective_start_date(l_attr_index),
	    p_effective_end_date => l_attr_val.effective_end_date(l_attr_index),
	    p_element_value_type => null,
	    p_element_value => null,
	    p_currency_code => null,
	    p_pay_basis => null,
	    p_employee_id => null,
	    p_primary_employee_flag => null,
	    p_global_default_flag => null,
	    p_assignment_default_rule_id => null,
	    p_modify_flag => null);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end loop;
	exit when c_posassign_attr%NOTFOUND;

      end loop;
      close c_posassign_attr;

      -- Upload Position Element Assignments

      for c_posassign_elem_rec in c_posassign_elem (c_positions_rec.position_id) loop

	for c_re_elem_rec in c_re_elem (c_posassign_elem_rec.pay_element_id) loop
	  l_pay_element_id := c_re_elem_rec.pay_element_id;
	end loop;

	if c_posassign_elem_rec.pay_element_option_id is not null then
	begin

	  for c_re_elemopt_rec in c_re_elemopt (l_pay_element_id, c_posassign_elem_rec.pay_element_option_id) loop
	    l_pay_element_option_id := c_re_elemopt_rec.pay_element_option_id;
	  end loop;

	end;
	else
	  l_pay_element_option_id := null;
	end if;

	for c_posassign_seq_rec in c_posassign_seq loop
	  l_position_assignment_id := c_posassign_seq_rec.seq;
	end loop;

	PSB_POSITION_ASSIGNMENTS_PVT.Insert_Row
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_rowid => l_rowid,
	    p_position_assignment_id => l_position_assignment_id,
	    p_data_extract_id => p_target_data_extract_id,
	    p_worksheet_id => null,
	    p_position_id => l_position_id,
	    p_assignment_type => 'ELEMENT',
	    p_attribute_id => null,
	    p_attribute_value_id => null,
	    p_attribute_value => null,
	    p_pay_element_id => l_pay_element_id,
	    p_pay_element_option_id => l_pay_element_option_id,
	    p_effective_start_date => c_posassign_elem_rec.effective_start_date,
	    p_effective_end_date => c_posassign_elem_rec.effective_end_date,
	    p_element_value_type => c_posassign_elem_rec.element_value_type,
	    p_element_value => c_posassign_elem_rec.element_value,
	    p_currency_code => c_posassign_elem_rec.currency_code,
	    p_pay_basis => c_posassign_elem_rec.pay_basis,
	    p_employee_id => null,
	    p_primary_employee_flag => null,
	    p_global_default_flag => null,
	    p_assignment_default_rule_id => null,
	    p_modify_flag => null);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end loop;

      -- Upload Position Employee Assignments

      for c_posassign_emp_rec in c_posassign_emp (c_positions_rec.position_id) loop

	for c_re_emp_rec in c_re_emp (c_posassign_emp_rec.employee_id) loop
	  l_employee_id := c_re_emp_rec.employee_id;
	end loop;

	for c_posassign_seq_rec in c_posassign_seq loop
	  l_position_assignment_id := c_posassign_seq_rec.seq;
	end loop;

	PSB_POSITION_ASSIGNMENTS_PVT.Insert_Row
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_rowid => l_rowid,
	    p_position_assignment_id => l_position_assignment_id,
	    p_data_extract_id => p_target_data_extract_id,
	    p_worksheet_id => null,
	    p_position_id => l_position_id,
	    p_assignment_type => 'EMPLOYEE',
	    p_attribute_id => null,
	    p_attribute_value_id => null,
	    p_attribute_value => null,
	    p_pay_element_id => null,
	    p_pay_element_option_id => null,
	    p_effective_start_date => c_posassign_emp_rec.effective_start_date,
	    p_effective_end_date => c_posassign_emp_rec.effective_end_date,
	    p_element_value_type => null,
	    p_element_value => null,
	    p_currency_code => null,
	    p_pay_basis => null,
	    p_employee_id => l_employee_id,
	    p_primary_employee_flag => c_posassign_emp_rec.primary_employee_flag,
	    p_global_default_flag => null,
	    p_assignment_default_rule_id => null,
	    p_modify_flag => null);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end loop;

      -- Upload Position Salary Distributions

      for c_position_distr_rec in c_position_distr (c_positions_rec.position_id) loop
        /* Bug 3867577 Start */
        l_pos_distr_cnt := l_pos_distr_cnt + 1;
        /* Bug 3867577 End */
	-- if flex mapping was used in worksheet creation need to map the salary account distr
	-- by effective dates

	if p_flex_mapping_set_id is not null then
	begin

	  for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

	    if PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP') then
	    begin

	      l_budget_year_type_id := PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_type_id;
	      l_year_start_date := PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
	      l_year_end_date := PSB_WS_ACCT1.g_budget_years(l_year_index).end_date;

	      if (((c_position_distr_rec.effective_start_date < l_year_end_date) and
		   (c_position_distr_rec.effective_end_date is null)) or
		  ((c_position_distr_rec.effective_start_date between l_year_start_date and l_year_end_date) or
		   (c_position_distr_rec.effective_end_date between l_year_start_date and l_year_end_date) or
		  ((c_position_distr_rec.effective_start_date < l_year_start_date) and
		   (c_position_distr_rec.effective_end_date > l_year_end_date)))) then
	      begin

		l_mapped_ccid := PSB_FLEX_MAPPING_PVT.Get_Mapped_CCID
				    (p_api_version => 1.0,
				     p_ccid => c_position_distr_rec.code_combination_id,
				     p_budget_year_type_id => l_budget_year_type_id,
				     p_flexfield_mapping_set_id => p_flex_mapping_set_id,
				     p_mapping_mode => 'GL_POSTING');

		if l_mapped_ccid = 0 then
		  raise FND_API.G_EXC_ERROR;
		end if;

		for c_posdistr_seq_rec in c_posdistr_seq loop
		  l_distribution_id := c_posdistr_seq_rec.seq;
		end loop;

		PSB_POSITION_PAY_DISTR_PVT.Insert_Row
		   (p_api_version => 1.0,
		    p_return_status => l_return_status,
		    p_msg_count => l_msg_count,
		    p_msg_data => l_msg_data,
		    p_rowid => l_rowid,
		    p_distribution_id => l_distribution_id,
		    p_position_id => l_position_id,
		    p_data_extract_id => p_target_data_extract_id,
		    p_worksheet_id => null,
		    p_effective_start_date => l_year_start_date,
		    p_effective_end_date => l_year_end_date,
		    p_chart_of_accounts_id => c_position_distr_rec.chart_of_accounts_id,
		    p_code_combination_id => l_mapped_ccid,
		    p_distribution_percent => c_position_distr_rec.distribution_percent,
		    p_global_default_flag => null,
		    p_distribution_default_rule_id => null,
		    p_project_id => null,
		    p_task_id => null,
		    p_award_id => null,
		    p_expenditure_type => null,
		    p_expenditure_organization_id => null,
		    p_description => null);

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
      /* Bug 3867577 Start */
      -- Call the following API only once for each position.
      IF l_pos_distr_cnt = 1 THEN
        Upload_Salary_Distribution
          (
            x_return_status          => l_return_status,
            p_worksheet_id           => p_worksheet_id,
            p_source_data_extract_id => p_source_data_extract_id,
            p_target_data_extract_id => p_target_data_extract_id,
            p_position_id            => l_position_id,
            p_source_DE_position_id  => c_positions_rec.position_id,
            p_from_budget_year_id    => p_from_budget_year_id,
            p_to_budget_year_id      => p_to_budget_year_id,
            p_position_exists        => FALSE
          );

        IF  l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;



      -- Commenting out the existing bunch of code as no enddating
      -- scenario was handelled before. This issue will be handelled
      -- new API Upload_Salary_Distribution.

	  /*for c_posdistr_seq_rec in c_posdistr_seq loop
	    l_distribution_id := c_posdistr_seq_rec.seq;
	  end loop;

	  PSB_POSITION_PAY_DISTR_PVT.Insert_Row
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_rowid => l_rowid,
	      p_distribution_id => l_distribution_id,
	      p_position_id => l_position_id,
	      p_data_extract_id => p_target_data_extract_id,
	      p_worksheet_id => null,
	      p_effective_start_date => c_position_distr_rec.effective_start_date,
	      p_effective_end_date => c_position_distr_rec.effective_end_date,
	      p_chart_of_accounts_id => c_position_distr_rec.chart_of_accounts_id,
	      p_code_combination_id => c_position_distr_rec.code_combination_id,
	      p_distribution_percent => c_position_distr_rec.distribution_percent,
	      p_global_default_flag => null,
	      p_distribution_default_rule_id => null,
	      p_project_id => null,
	      p_task_id => null,
	      p_award_id => null,
	      p_expenditure_type => null,
	      p_expenditure_organization_id => null,
	      p_description => null);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;*/
      /* Bug 3867577 End */

	end;
	end if;

      end loop;

    end; /* Position does not exist */
    else


    begin /* Position exists; do an incremental refresh in this case */

         PSB_POSITIONS_PVT.UPDATE_ROW
         (
	  p_api_version            => 1.0,
	  p_init_msg_lISt          => FND_API.G_FALSE,
	  p_commit                 => FND_API.G_FALSE,
	  p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
	  p_return_status          => l_return_status,
	  p_msg_count              => l_msg_count,
	  p_msg_data               => l_msg_data,
	  p_position_id            => l_position_id,
	  p_data_extract_id        => p_target_data_extract_id,
	  p_budget_group_id        => c_positions_rec.budget_group_id,
	  p_position_definition_id => c_positions_rec.position_definition_id,
	  p_hr_position_id         => c_positions_rec.hr_position_id,
	  p_hr_employee_id         => c_positions_rec.hr_employee_id,
	  p_business_group_id      => c_positions_rec.business_group_id,
	  p_effective_start_date   => c_positions_rec.effective_start_date,
	  p_effective_end_date     => c_positions_rec.effective_end_date,
	  p_set_of_books_id        => c_positions_rec.set_of_books_id,
	  p_vacant_position_flag   => c_positions_rec.vacant_position_flag,
	  p_availability_status    => c_positions_rec.availability_status,
	  p_transaction_id         => c_positions_rec.transaction_id,
	  p_transaction_status     => c_positions_rec.transaction_status,
	  p_attribute1             => c_positions_rec.attribute1,
	  p_attribute2             => c_positions_rec.attribute2,
	  p_attribute3             => c_positions_rec.attribute3,
	  p_attribute4             => c_positions_rec.attribute4,
	  p_attribute5             => c_positions_rec.attribute5,
	  p_attribute6             => c_positions_rec.attribute6,
	  p_attribute7             => c_positions_rec.attribute7,
	  p_attribute8             => c_positions_rec.attribute8,
	  p_attribute9             => c_positions_rec.attribute9,
	  p_attribute10            => c_positions_rec.attribute10,
	  p_attribute11            => c_positions_rec.attribute11,
	  p_attribute12            => c_positions_rec.attribute12,
	  p_attribute13            => c_positions_rec.attribute13,
	  p_attribute14            => c_positions_rec.attribute14,
	  p_attribute15            => c_positions_rec.attribute15,
	  p_attribute16            => c_positions_rec.attribute16,
	  p_attribute17            => c_positions_rec.attribute17,
	  p_attribute18            => c_positions_rec.attribute18,
	  p_attribute19            => c_positions_rec.attribute19,
	  p_attribute20            => c_positions_rec.attribute20,
	  p_attribute_category     => c_positions_rec.attribute_category,
	  p_name                   => c_positions_rec.name);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      -- Upload Position Attribute Assignments

      open c_posassign_attr(c_positions_rec.position_id);
      loop
	fetch c_posassign_attr BULK COLLECT INTO l_attr_val.attribute_id,l_attr_val.attribute_value_id,
						l_attr_val.attribute_value,l_attr_val.effective_start_date,
						l_attr_val.effective_end_date LIMIT g_limit_bulk_numrows;

      for l_attr_index in 1..l_attr_val.attribute_id.count loop

	  if l_attr_val.attribute_value_id(l_attr_index) is not null then
	  begin

	    for c_re_attrval_rec in c_re_attrval (l_attr_val.attribute_value_id(l_attr_index)) loop
	      l_attribute_value_id := c_re_attrval_rec.attribute_value_id;
	    end loop;

	  end;
	  else
	    l_attribute_value_id := null;
	  end if;

	  PSB_POSITIONS_PVT.Modify_Assignment
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_position_assignment_id => l_position_assignment_id,
	    p_data_extract_id => p_target_data_extract_id,
	    p_worksheet_id => null,
	    p_position_id => l_position_id,
	    p_assignment_type => 'ATTRIBUTE',
	    p_attribute_id => l_attr_val.attribute_id(l_attr_index),
	    p_attribute_value_id => l_attribute_value_id,
	    p_attribute_value => l_attr_val.attribute_value(l_attr_index),
	    p_pay_element_id => null,
	    p_pay_element_option_id => null,
	    p_effective_start_date => l_attr_val.effective_start_date(l_attr_index),
	    p_effective_end_date => l_attr_val.effective_end_date(l_attr_index),
	    p_element_value_type => null,
	    p_element_value => null,
	    p_currency_code => null,
	    p_pay_basis => null,
	    p_employee_id => null,
	    p_primary_employee_flag => null,
	    p_global_default_flag => null,
	    p_assignment_default_rule_id => null,
	    p_modify_flag => null,
	    p_rowid => l_rowid);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end loop;
	exit when c_posassign_attr%NOTFOUND;

      end loop;
      close c_posassign_attr;

      -- Upload Position Element Assignments

      for c_posassign_elem_rec in c_posassign_elem (c_positions_rec.position_id) loop

	for c_re_elem_rec in c_re_elem (c_posassign_elem_rec.pay_element_id) loop
	  l_pay_element_id := c_re_elem_rec.pay_element_id;
	end loop;

	if c_posassign_elem_rec.pay_element_option_id is not null then
	begin

	  for c_re_elemopt_rec in c_re_elemopt (l_pay_element_id, c_posassign_elem_rec.pay_element_option_id) loop
	    l_pay_element_option_id := c_re_elemopt_rec.pay_element_option_id;
	  end loop;

	end;
	else
	  l_pay_element_option_id := null;
	end if;

	PSB_POSITIONS_PVT.Modify_Assignment
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_position_assignment_id => l_position_assignment_id,
	    p_data_extract_id => p_target_data_extract_id,
	    p_worksheet_id => null,
	    p_position_id => l_position_id,
	    p_assignment_type => 'ELEMENT',
	    p_attribute_id => null,
	    p_attribute_value_id => null,
	    p_attribute_value => null,
	    p_pay_element_id => l_pay_element_id,
	    p_pay_element_option_id => l_pay_element_option_id,
	    p_effective_start_date => c_posassign_elem_rec.effective_start_date,
	    p_effective_end_date => c_posassign_elem_rec.effective_end_date,
	    p_element_value_type => c_posassign_elem_rec.element_value_type,
	    p_element_value => c_posassign_elem_rec.element_value,
	    p_currency_code => c_posassign_elem_rec.currency_code,
	    p_pay_basis => c_posassign_elem_rec.pay_basis,
	    p_employee_id => null,
	    p_primary_employee_flag => null,
	    p_global_default_flag => null,
	    p_assignment_default_rule_id => null,
	    p_modify_flag => null,
	    p_rowid => l_rowid);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end loop;

      -- Upload Position Employee Assignments

      for c_posassign_emp_rec in c_posassign_emp (c_positions_rec.position_id) loop

	for c_re_emp_rec in c_re_emp (c_posassign_emp_rec.employee_id) loop
	  l_employee_id := c_re_emp_rec.employee_id;
	end loop;

	PSB_POSITIONS_PVT.Modify_Assignment
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_position_assignment_id => l_position_assignment_id,
	    p_data_extract_id => p_target_data_extract_id,
	    p_worksheet_id => null,
	    p_position_id => l_position_id,
	    p_assignment_type => 'EMPLOYEE',
	    p_attribute_id => null,
	    p_attribute_value_id => null,
	    p_attribute_value => null,
	    p_pay_element_id => null,
	    p_pay_element_option_id => null,
	    p_effective_start_date => c_posassign_emp_rec.effective_start_date,
	    p_effective_end_date => c_posassign_emp_rec.effective_end_date,
	    p_element_value_type => null,
	    p_element_value => null,
	    p_currency_code => null,
	    p_pay_basis => null,
	    p_employee_id => l_employee_id,
	    p_primary_employee_flag => c_posassign_emp_rec.primary_employee_flag,
	    p_global_default_flag => null,
	    p_assignment_default_rule_id => null,
	    p_modify_flag => null,
	    p_rowid => l_rowid);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end loop;

      -- Upload Position Salary Distributions

      for c_position_distr_rec in c_position_distr (c_positions_rec.position_id) loop
        /* Bug 3867577 Start */
        l_pos_distr_cnt := l_pos_distr_cnt + 1;
        /* Bug 3867577 End */

	-- if flex mapping was used in worksheet creation need to map the salary account distr
	-- by effective dates

	if p_flex_mapping_set_id is not null then
	begin

	  for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

	    if PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP') then
	    begin

	      l_budget_year_type_id := PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_type_id;
	      l_year_start_date := PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
	      l_year_end_date := PSB_WS_ACCT1.g_budget_years(l_year_index).end_date;

	      if (((c_position_distr_rec.effective_start_date < l_year_end_date) and
		   (c_position_distr_rec.effective_end_date is null)) or
		  ((c_position_distr_rec.effective_start_date between l_year_start_date and l_year_end_date) or
		   (c_position_distr_rec.effective_end_date between l_year_start_date and l_year_end_date) or
		  ((c_position_distr_rec.effective_start_date < l_year_start_date) and
		   (c_position_distr_rec.effective_end_date > l_year_end_date)))) then
	      begin

		l_mapped_ccid := PSB_FLEX_MAPPING_PVT.Get_Mapped_CCID
				    (p_api_version => 1.0,
				     p_ccid => c_position_distr_rec.code_combination_id,
				     p_budget_year_type_id => l_budget_year_type_id,
				     p_flexfield_mapping_set_id => p_flex_mapping_set_id,
				     p_mapping_mode => 'GL_POSTING');

		if l_mapped_ccid = 0 then
		  raise FND_API.G_EXC_ERROR;
		end if;

		PSB_POSITION_PAY_DISTR_PVT.Modify_Distribution
		   (p_api_version => 1.0,
		    p_return_status => l_return_status,
		    p_msg_count => l_msg_count,
		    p_msg_data => l_msg_data,
		    p_distribution_id => l_distribution_id,
		    p_position_id => l_position_id,
		    p_data_extract_id => p_target_data_extract_id,
		    p_worksheet_id => null,
		    p_effective_start_date => l_year_start_date,
		    p_effective_end_date => l_year_end_date,
		    p_chart_of_accounts_id => c_position_distr_rec.chart_of_accounts_id,
		    p_code_combination_id => l_mapped_ccid,
		    p_distribution_percent => c_position_distr_rec.distribution_percent,
		    p_global_default_flag => null,
		    p_distribution_default_rule_id => null,
		    p_rowid => l_rowid,
		    p_project_id => null,
		    p_task_id => null,
		    p_award_id => null,
		    p_expenditure_type => null,
		    p_expenditure_organization_id => null,
		    p_description => null);

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

	  /* Bug 3867577 Start */
      -- Call the following API only once for each position.
      IF l_pos_distr_cnt = 1 THEN
        Upload_Salary_Distribution
          (
            x_return_status          => l_return_status,
            p_worksheet_id           => p_worksheet_id,
            p_source_data_extract_id => p_source_data_extract_id,
            p_target_data_extract_id => p_target_data_extract_id,
            p_position_id            => l_position_id,
            p_source_DE_position_id  => c_positions_rec.position_id,
            p_from_budget_year_id    => p_from_budget_year_id,
            p_to_budget_year_id      => p_to_budget_year_id,
            p_position_exists        => TRUE
          );

        IF  l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      -- Commenting out the existing bunch of code as no enddating
      -- scenario was handelled before. This issue will be handelled
      -- new API Upload_Salary_Distribution.

      /*PSB_POSITION_PAY_DISTR_PVT.Modify_Distribution
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_distribution_id => l_distribution_id,
	      p_position_id => l_position_id,
	      p_data_extract_id => p_target_data_extract_id,
	      p_worksheet_id => null,
	      p_effective_start_date => c_position_distr_rec.effective_start_date,
	      p_effective_end_date => c_position_distr_rec.effective_end_date,
	      p_chart_of_accounts_id => c_position_distr_rec.chart_of_accounts_id,
	      p_code_combination_id => c_position_distr_rec.code_combination_id,
	      p_distribution_percent => c_position_distr_rec.distribution_percent,
	      p_global_default_flag => null,
	      p_distribution_default_rule_id => null,
	      p_rowid => l_rowid,
	      p_project_id => null,
	      p_task_id => null,
	      p_award_id => null,
	      p_expenditure_type => null,
	      p_expenditure_organization_id => null,
	      p_description => null);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if; */
      /* Bug 3867577 End */

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
     if c_posassign_attr%ISOPEN then
       close c_posassign_attr;
     end if;
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     if c_posassign_attr%ISOPEN then
       close c_posassign_attr;
     end if;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     if c_posassign_attr%ISOPEN then
       close c_posassign_attr;
     end if;
	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Upload_Positions;

/* ----------------------------------------------------------------------- */

PROCEDURE Upload_Position_Worksheet
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_worksheet_id            IN   NUMBER,
  p_flex_mapping_set_id     IN   NUMBER,
  p_budget_calendar_id      IN   NUMBER,
  p_target_data_extract_id  IN   NUMBER,
  p_hr_budget_id            IN   NUMBER
) IS

  l_position_id             NUMBER;
  l_budget_group_id         NUMBER;
  l_budget_year_id          NUMBER;
  l_budget_year_type_id     NUMBER;
  l_element_set_id          NUMBER;
  l_currency_code           VARCHAR2(15);
  l_pay_element_id          NUMBER;

  l_year_start_date         DATE;
  l_year_end_date           DATE;
  l_period1_start_date      DATE;
  l_period1_end_date        DATE;
  l_period2_start_date      DATE;
  l_period2_end_date        DATE;
  l_period3_start_date      DATE;
  l_period3_end_date        DATE;
  l_period4_start_date      DATE;
  l_period4_end_date        DATE;
  l_period5_start_date      DATE;
  l_period5_end_date        DATE;
  l_period6_start_date      DATE;
  l_period6_end_date        DATE;
  l_period7_start_date      DATE;
  l_period7_end_date        DATE;
  l_period8_start_date      DATE;
  l_period8_end_date        DATE;
  l_period9_start_date      DATE;
  l_period9_end_date        DATE;
  l_period10_start_date     DATE;
  l_period10_end_date       DATE;
  l_period11_start_date     DATE;
  l_period11_end_date       DATE;
  l_period12_start_date     DATE;
  l_period12_end_date       DATE;

  l_period1_amount          NUMBER;
  l_period2_amount          NUMBER;
  l_period3_amount          NUMBER;
  l_period4_amount          NUMBER;
  l_period5_amount          NUMBER;
  l_period6_amount          NUMBER;
  l_period7_amount          NUMBER;
  l_period8_amount          NUMBER;
  l_period9_amount          NUMBER;
  l_period10_amount         NUMBER;
  l_period11_amount         NUMBER;
  l_period12_amount         NUMBER;

  l_mapped_ccid             NUMBER;
  l_period_amount           PSB_WS_ACCT1.g_prdamt_tbl_type;

  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  /*For Bug No : 1808322 Start*/
  l_base_line_version       VARCHAR2(1);
  l_batch_size              NUMBER := g_limit_bulk_numrows;
  TYPE l_batch_pos_id_tbl         IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE l_batch_start_date_tbl     IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE l_batch_end_date_tbl       IS TABLE OF DATE INDEX BY BINARY_INTEGER;
  TYPE l_batch_cur_code_tbl       IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
  TYPE l_batch_fte_tbl            IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE l_batch_pay_element_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE l_batch_element_cost_tbl   IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE l_batch_cc_id_tbl          IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE l_batch_amount_tbl         IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE l_batch_bg_id_tbl          IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE l_update_tbl               IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

  l_fte_position_id       l_batch_pos_id_tbl;
  l_fte_start_date        l_batch_start_date_tbl;
  l_fte_end_date          l_batch_end_date_tbl;
  l_fte_fte               l_batch_fte_tbl;
  l_fte_update            l_update_tbl;

  l_cost_position_id      l_batch_pos_id_tbl;
  l_cost_start_date       l_batch_start_date_tbl;
  l_cost_end_date         l_batch_end_date_tbl;
  l_cost_element_id       l_batch_pay_element_id_tbl;
  l_cost_currency_code    l_batch_cur_code_tbl;
  l_cost_element_cost     l_batch_element_cost_tbl;
  l_cost_update           l_update_tbl;

  l_account_position_id   l_batch_pos_id_tbl;
  l_account_start_date    l_batch_start_date_tbl;
  l_account_end_date      l_batch_end_date_tbl;
  l_account_cc_id         l_batch_cc_id_tbl;
  l_account_currency_code l_batch_cur_code_tbl;
  l_account_amount        l_batch_amount_tbl;
  l_account_bg_id         l_batch_bg_id_tbl;
  l_account_update        l_update_tbl;

  l_count_fte             NUMBER := 0;
  l_count_costs           NUMBER := 0;
  l_count_accounts        NUMBER := 0;
  /*For Bug No : 1808322 End*/

  /*For Bug No : 2434152 Start*/
  l_position_ctr          NUMBER := 0;
  /*For Bug No : 2434152 End*/

  /* start bug 4545590 */
  TYPE l_num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  TYPE l_position_rec_type IS RECORD (
   position_id      l_num_tbl_type,
   position_line_id l_num_tbl_type);

  -- position record variable
  l_position_rec l_position_rec_type;
  /* end bug 4545590 */


  cursor c_wpl is
    /*For Bug No : 1808322 Start*/
      --The following sql statement has been commented because of
      --FTS on PSB_WS_POSITION_LINES table.
      --The same was achived by the next query

    /*select *
      from PSB_WS_POSITION_LINES a
     where exists
	  (select 1
	     from PSB_WS_LINES_POSITIONS b
	    where b.position_line_id = a.position_line_id
	      and b.worksheet_id = p_worksheet_id);*/

     -- for bug 4545590
     select a.position_id, a.position_line_id
       from PSB_WS_POSITION_LINES a,
	    PSB_WS_LINES_POSITIONS b
      where a.position_line_id = b.position_line_id
	and b.worksheet_id = p_worksheet_id;
    /*For Bug No : 1808322 End*/

  cursor c_wal_ps(poslineid NUMBER, budgetyearid NUMBER) is
    select code_combination_id, currency_code, sum(nvl(ytd_amount, 0)) annual_amount
      from PSB_WS_ACCOUNT_LINES
     where position_line_id = poslineid
       and budget_year_id = budgetyearid
       and end_stage_seq is null
     group by code_combination_id, currency_code;

  cursor c_wal_period(poslineid NUMBER, budgetyearid NUMBER) is
    select currency_code, element_set_id,
	   sum(nvl(ytd_amount,0)) annual_amount,
	   sum(nvl(period1_amount,0)) period1_amount,
	   sum(nvl(period2_amount,0)) period2_amount,
	   sum(nvl(period3_amount,0)) period3_amount,
	   sum(nvl(period4_amount,0)) period4_amount,
	   sum(nvl(period5_amount,0)) period5_amount,
	   sum(nvl(period6_amount,0)) period6_amount,
	   sum(nvl(period7_amount,0)) period7_amount,
	   sum(nvl(period8_amount,0)) period8_amount,
	   sum(nvl(period9_amount,0)) period9_amount,
	   sum(nvl(period10_amount,0)) period10_amount,
	   sum(nvl(period11_amount,0)) period11_amount,
	   sum(nvl(period12_amount,0)) period12_amount
      from psb_ws_account_lines
     where position_line_id = poslineid
       and budget_year_id   = budgetyearid
       and end_stage_seq is null
    group by currency_code, element_set_id;

  cursor c_wfl(poslineid NUMBER, budgetyearid NUMBER) is
    select sum(nvl(period1_fte, 0)) period1_fte, sum(nvl(period2_fte, 0)) period2_fte,
	   sum(nvl(period3_fte, 0)) period3_fte, sum(nvl(period4_fte, 0)) period4_fte,
	   sum(nvl(period5_fte, 0)) period5_fte, sum(nvl(period6_fte, 0)) period6_fte,
	   sum(nvl(period7_fte, 0)) period7_fte, sum(nvl(period8_fte, 0)) period8_fte,
	   sum(nvl(period9_fte, 0)) period9_fte, sum(nvl(period10_fte, 0)) period10_fte,
	   sum(nvl(period11_fte, 0)) period11_fte, sum(nvl(period12_fte, 0)) period12_fte
      from PSB_WS_FTE_LINES
     where position_line_id = poslineid
       and budget_year_id = budgetyearid
       and end_stage_seq is null;

  cursor c_wel(poslineid NUMBER, budgetyearid NUMBER, elemsetid NUMBER, currency VARCHAR2) is
    select pay_element_id, sum(nvl(element_cost, 0)) element_cost
      from PSB_WS_ELEMENT_LINES
     where position_line_id = poslineid
       and budget_year_id = budgetyearid
       and element_set_id = elemsetid
       and currency_code = currency
       and end_stage_seq is null
     group by pay_element_id;

  cursor c_re_elem (elemid NUMBER) is
    select a.pay_element_id
      from PSB_PAY_ELEMENTS a,
	   PSB_PAY_ELEMENTS b
     where a.name = b.name
       and a.data_extract_id = p_target_data_extract_id
       and b.pay_element_id = elemid;

  cursor c_re_pos (posid NUMBER) is
    select a.position_id, a.budget_group_id
      from PSB_POSITIONS a,
	   PSB_POSITIONS b
     where (((b.hr_employee_id is null) and
            (a.hr_employee_id is null))
             or ((b.hr_employee_id is not null )
                 and (a.hr_employee_id = b.hr_employee_id)))
       /* Start bug 3625364 */
       /*and a.name = b.name*/
       and a.hr_position_id = b.hr_position_id
       /* End bug 3625364 */
       and a.data_extract_id = p_target_data_extract_id
       and b.position_id = posid;

BEGIN

  /*For Bug No : 2434152 Start*/
  -- Standard Start of API savepoint
  Savepoint Upload_Position_Worksheet_Pvt;
  /*For Bug No : 2434152 End*/

  /*For Bug No : 1808322 Start*/
  FOR i IN 1..l_count_fte LOOP
    l_fte_position_id(i) := null;
    l_fte_start_date(i) := null;
    l_fte_end_date(i) := null;
    l_fte_fte(i) := null;
  END LOOP;

  FOR i IN 1..l_count_costs LOOP
    l_cost_position_id(i) := null;
    l_cost_start_date(i) := null;
    l_cost_end_date(i) := null;
    l_cost_element_id(i) := null;
    l_cost_currency_code(i) := null;
    l_cost_element_cost(i) := null;
  END LOOP;

  FOR i IN 1..l_count_accounts LOOP
    l_account_position_id(i) := null;
    l_account_start_date(i) := null;
    l_account_end_date(i) := null;
    l_account_cc_id(i) := null;
    l_account_currency_code(i) := null;
    l_account_amount(i) := null;
    l_account_bg_id(i) := null;
  END LOOP;
  /*For Bug No : 1808322 End*/

  /* start bug 4545590 */
  l_position_rec.position_id.delete;
  l_position_rec.position_line_id.delete;

  OPEN c_wpl;
  FETCH c_wpl BULK COLLECT INTO l_position_rec.position_id, l_position_rec.position_line_id;
  CLOSE c_wpl;
  /* end bug 4545590 */

  -- for bug 4545590
  --for c_wpl_rec in c_wpl loop
  for loop_var IN 1..l_position_rec.position_id.count LOOP

    /*For Bug No : 2434152 Start*/
    l_position_ctr := l_position_ctr + 1;
    /*For Bug No : 2434152 End*/

    -- for bug 4545590
    --for c_re_pos_rec in c_re_pos (c_wpl_rec.position_id) loop
    for c_re_pos_rec in c_re_pos (l_position_rec.position_id(loop_var)) loop
      l_position_id := c_re_pos_rec.position_id;
      l_budget_group_id := c_re_pos_rec.budget_group_id;
    end loop;

    for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

      l_budget_year_id := PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id;
      l_budget_year_type_id := PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_type_id;
      l_year_start_date := PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
      l_year_end_date := PSB_WS_ACCT1.g_budget_years(l_year_index).end_date;

      for l_period_index in 1..PSB_WS_ACCT1.g_num_budget_periods loop

	if PSB_WS_ACCT1.g_budget_periods(l_period_index).budget_year_id = l_budget_year_id then
	begin

	  if PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no = 1 then
	    l_period1_start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	    l_period1_end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	  elsif PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no = 2 then
	    l_period2_start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	    l_period2_end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	  elsif PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no = 3 then
	    l_period3_start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	    l_period3_end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	  elsif PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no = 4 then
	    l_period4_start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	    l_period4_end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	  elsif PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no = 5 then
	    l_period5_start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	    l_period5_end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	  elsif PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no = 6 then
	    l_period6_start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	    l_period6_end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	  elsif PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no = 7 then
	    l_period7_start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	    l_period7_end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	  elsif PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no = 8 then
	    l_period8_start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	    l_period8_end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	  elsif PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no = 9 then
	    l_period9_start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	    l_period9_end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	  elsif PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no = 10 then
	    l_period10_start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	    l_period10_end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	  elsif PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no = 11 then
	    l_period11_start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	    l_period11_end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	  elsif PSB_WS_ACCT1.g_budget_periods(l_period_index).long_sequence_no = 12 then
	    l_period12_start_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).start_date;
	    l_period12_end_date := PSB_WS_ACCT1.g_budget_periods(l_period_index).end_date;
	  end if;

	end;
	end if;

      end loop;

      -- for bug 4545590
      --for c_wfl_rec in c_wfl(c_wpl_rec.position_line_id, l_budget_year_id) loop
      for c_wfl_rec in c_wfl(l_position_rec.position_line_id(loop_var), l_budget_year_id) loop
       /*For Bug No : 1808322 Start*/
       if c_wfl_rec.period1_fte <> 0 then
       begin

	l_count_fte := l_count_fte + 1;
	l_fte_position_id(l_count_fte) := l_position_id;
	l_fte_start_date(l_count_fte) := l_period1_start_date;
	l_fte_end_date(l_count_fte) := l_period1_end_date;
	l_fte_fte(l_count_fte) := c_wfl_rec.period1_fte;

       end;
       end if;

       if c_wfl_rec.period2_fte <> 0 then
       begin

	l_count_fte := l_count_fte + 1;
	l_fte_position_id(l_count_fte) := l_position_id;
	l_fte_start_date(l_count_fte) := l_period2_start_date;
	l_fte_end_date(l_count_fte) := l_period2_end_date;
	l_fte_fte(l_count_fte) := c_wfl_rec.period2_fte;

       end;
       end if;

       if c_wfl_rec.period3_fte <> 0 then
       begin

	l_count_fte := l_count_fte + 1;
	l_fte_position_id(l_count_fte) := l_position_id;
	l_fte_start_date(l_count_fte) := l_period3_start_date;
	l_fte_end_date(l_count_fte) := l_period3_end_date;
	l_fte_fte(l_count_fte) := c_wfl_rec.period3_fte;

       end;
       end if;

       if c_wfl_rec.period4_fte <> 0 then
       begin

	l_count_fte := l_count_fte + 1;
	l_fte_position_id(l_count_fte) := l_position_id;
	l_fte_start_date(l_count_fte) := l_period4_start_date;
	l_fte_end_date(l_count_fte) := l_period4_end_date;
	l_fte_fte(l_count_fte) := c_wfl_rec.period4_fte;

       end;
       end if;

       if c_wfl_rec.period5_fte <> 0 then
       begin

	l_count_fte := l_count_fte + 1;
	l_fte_position_id(l_count_fte) := l_position_id;
	l_fte_start_date(l_count_fte) := l_period5_start_date;
	l_fte_end_date(l_count_fte) := l_period5_end_date;
	l_fte_fte(l_count_fte) := c_wfl_rec.period5_fte;

       end;
       end if;

       if c_wfl_rec.period6_fte <> 0 then
       begin

	l_count_fte := l_count_fte + 1;
	l_fte_position_id(l_count_fte) := l_position_id;
	l_fte_start_date(l_count_fte) := l_period6_start_date;
	l_fte_end_date(l_count_fte) := l_period6_end_date;
	l_fte_fte(l_count_fte) := c_wfl_rec.period6_fte;

       end;
       end if;

       if c_wfl_rec.period7_fte <> 0 then
       begin

	l_count_fte := l_count_fte + 1;
	l_fte_position_id(l_count_fte) := l_position_id;
	l_fte_start_date(l_count_fte) := l_period7_start_date;
	l_fte_end_date(l_count_fte) := l_period7_end_date;
	l_fte_fte(l_count_fte) := c_wfl_rec.period7_fte;

       end;
       end if;

       if c_wfl_rec.period8_fte <> 0 then
       begin

	l_count_fte := l_count_fte + 1;
	l_fte_position_id(l_count_fte) := l_position_id;
	l_fte_start_date(l_count_fte) := l_period8_start_date;
	l_fte_end_date(l_count_fte) := l_period8_end_date;
	l_fte_fte(l_count_fte) := c_wfl_rec.period8_fte;

       end;
       end if;

       if c_wfl_rec.period9_fte <> 0 then
       begin

	l_count_fte := l_count_fte + 1;
	l_fte_position_id(l_count_fte) := l_position_id;
	l_fte_start_date(l_count_fte) := l_period9_start_date;
	l_fte_end_date(l_count_fte) := l_period9_end_date;
	l_fte_fte(l_count_fte) := c_wfl_rec.period9_fte;

       end;
       end if;

       if c_wfl_rec.period10_fte <> 0 then
       begin

	l_count_fte := l_count_fte + 1;
	l_fte_position_id(l_count_fte) := l_position_id;
	l_fte_start_date(l_count_fte) := l_period10_start_date;
	l_fte_end_date(l_count_fte) := l_period10_end_date;
	l_fte_fte(l_count_fte) := c_wfl_rec.period10_fte;

       end;
       end if;

       if c_wfl_rec.period11_fte <> 0 then
       begin

	l_count_fte := l_count_fte + 1;
	l_fte_position_id(l_count_fte) := l_position_id;
	l_fte_start_date(l_count_fte) := l_period11_start_date;
	l_fte_end_date(l_count_fte) := l_period11_end_date;
	l_fte_fte(l_count_fte) := c_wfl_rec.period11_fte;

       end;
       end if;

       if c_wfl_rec.period12_fte <> 0 then
       begin

	l_count_fte := l_count_fte + 1;
	l_fte_position_id(l_count_fte) := l_position_id;
	l_fte_start_date(l_count_fte) := l_period12_start_date;
	l_fte_end_date(l_count_fte) := l_period12_end_date;
	l_fte_fte(l_count_fte) := c_wfl_rec.period12_fte;

       end;
       end if;
      /*For Bug No : 1808322 End*/
      end loop;

      -- for bug 4545590
      --for c_wal_period_rec in c_wal_period(c_wpl_rec.position_line_id, l_budget_year_id) loop
      for c_wal_period_rec in c_wal_period(l_position_rec.position_line_id(loop_var), l_budget_year_id) loop
	l_element_set_id := c_wal_period_rec.element_set_id;
	l_currency_code := c_wal_period_rec.currency_code;

	if c_wal_period_rec.annual_amount <> 0 then
	begin
	/*For Bug No : 1808322 Start*/

          -- for bug 4545590
	  --for c_wel_rec in c_wel(c_wpl_rec.position_line_id, l_budget_year_id, l_element_set_id, l_currency_code) loop
            for c_wel_rec in c_wel(l_position_rec.position_line_id(loop_var), l_budget_year_id, l_element_set_id, l_currency_code) loop

	      for c_re_elem_rec in c_re_elem(c_wel_rec.pay_element_id) loop
	        l_pay_element_id := c_re_elem_rec.pay_element_id;
	      end loop;

	    if c_wal_period_rec.period1_amount <> 0 then
	    begin

	      l_period1_amount := ((c_wel_rec.element_cost/c_wal_period_rec.annual_amount) * c_wal_period_rec.period1_amount);

	      l_count_costs := l_count_costs + 1;
	      l_cost_position_id(l_count_costs) := l_position_id;
	      l_cost_element_id(l_count_costs) := l_pay_element_id;
	      l_cost_start_date(l_count_costs) := l_period1_start_date;
	      l_cost_end_date(l_count_costs) := l_period1_end_date;
	      l_cost_currency_code(l_count_costs) := c_wal_period_rec.currency_code;
	      l_cost_element_cost(l_count_costs) := l_period1_amount;

	    end;
	    end if;

	    if c_wal_period_rec.period2_amount <> 0 then
	    begin

	      l_period2_amount := ((c_wel_rec.element_cost/c_wal_period_rec.annual_amount) * c_wal_period_rec.period2_amount);

	      l_count_costs := l_count_costs + 1;
	      l_cost_position_id(l_count_costs) := l_position_id;
	      l_cost_element_id(l_count_costs) := l_pay_element_id;
	      l_cost_start_date(l_count_costs) := l_period2_start_date;
	      l_cost_end_date(l_count_costs) := l_period2_end_date;
	      l_cost_currency_code(l_count_costs) := c_wal_period_rec.currency_code;
	      l_cost_element_cost(l_count_costs) := l_period2_amount;

	    end;
	    end if;

	    if c_wal_period_rec.period3_amount <> 0 then
	    begin

	      l_period3_amount := ((c_wel_rec.element_cost/c_wal_period_rec.annual_amount) * c_wal_period_rec.period3_amount);

	      l_count_costs := l_count_costs + 1;
	      l_cost_position_id(l_count_costs) := l_position_id;
	      l_cost_element_id(l_count_costs) := l_pay_element_id;
	      l_cost_start_date(l_count_costs) := l_period3_start_date;
	      l_cost_end_date(l_count_costs) := l_period3_end_date;
	      l_cost_currency_code(l_count_costs) := c_wal_period_rec.currency_code;
	      l_cost_element_cost(l_count_costs) := l_period3_amount;

	    end;
	    end if;

	    if c_wal_period_rec.period4_amount <> 0 then
	    begin

	      l_period4_amount := ((c_wel_rec.element_cost/c_wal_period_rec.annual_amount) * c_wal_period_rec.period4_amount);

	      l_count_costs := l_count_costs + 1;
	      l_cost_position_id(l_count_costs) := l_position_id;
	      l_cost_element_id(l_count_costs) := l_pay_element_id;
	      l_cost_start_date(l_count_costs) := l_period4_start_date;
	      l_cost_end_date(l_count_costs) := l_period4_end_date;
	      l_cost_currency_code(l_count_costs) := c_wal_period_rec.currency_code;
	      l_cost_element_cost(l_count_costs) := l_period4_amount;

	    end;
	    end if;

	    if c_wal_period_rec.period5_amount <> 0 then
	    begin

	      l_period5_amount := ((c_wel_rec.element_cost/c_wal_period_rec.annual_amount) * c_wal_period_rec.period5_amount);

	      l_count_costs := l_count_costs + 1;
	      l_cost_position_id(l_count_costs) := l_position_id;
	      l_cost_element_id(l_count_costs) := l_pay_element_id;
	      l_cost_start_date(l_count_costs) := l_period5_start_date;
	      l_cost_end_date(l_count_costs) := l_period5_end_date;
	      l_cost_currency_code(l_count_costs) := c_wal_period_rec.currency_code;
	      l_cost_element_cost(l_count_costs) := l_period5_amount;

	    end;
	    end if;

	    if c_wal_period_rec.period6_amount <> 0 then
	    begin

	      l_period6_amount := ((c_wel_rec.element_cost/c_wal_period_rec.annual_amount) * c_wal_period_rec.period6_amount);

	      l_count_costs := l_count_costs + 1;
	      l_cost_position_id(l_count_costs) := l_position_id;
	      l_cost_element_id(l_count_costs) := l_pay_element_id;
	      l_cost_start_date(l_count_costs) := l_period6_start_date;
	      l_cost_end_date(l_count_costs) := l_period6_end_date;
	      l_cost_currency_code(l_count_costs) := c_wal_period_rec.currency_code;
	      l_cost_element_cost(l_count_costs) := l_period6_amount;

	    end;
	    end if;

	    if c_wal_period_rec.period7_amount <> 0 then
	    begin

	      l_period7_amount := ((c_wel_rec.element_cost/c_wal_period_rec.annual_amount) * c_wal_period_rec.period7_amount);

	      l_count_costs := l_count_costs + 1;
	      l_cost_position_id(l_count_costs) := l_position_id;
	      l_cost_element_id(l_count_costs) := l_pay_element_id;
	      l_cost_start_date(l_count_costs) := l_period7_start_date;
	      l_cost_end_date(l_count_costs) := l_period7_end_date;
	      l_cost_currency_code(l_count_costs) := c_wal_period_rec.currency_code;
	      l_cost_element_cost(l_count_costs) := l_period7_amount;

	    end;
	    end if;

	    if c_wal_period_rec.period8_amount <> 0 then
	    begin

	      l_period8_amount := ((c_wel_rec.element_cost/c_wal_period_rec.annual_amount) * c_wal_period_rec.period8_amount);

	      l_count_costs := l_count_costs + 1;
	      l_cost_position_id(l_count_costs) := l_position_id;
	      l_cost_element_id(l_count_costs) := l_pay_element_id;
	      l_cost_start_date(l_count_costs) := l_period8_start_date;
	      l_cost_end_date(l_count_costs) := l_period8_end_date;
	      l_cost_currency_code(l_count_costs) := c_wal_period_rec.currency_code;
	      l_cost_element_cost(l_count_costs) := l_period8_amount;

	    end;
	    end if;

	    if c_wal_period_rec.period9_amount <> 0 then
	    begin

	      l_period9_amount := ((c_wel_rec.element_cost/c_wal_period_rec.annual_amount) * c_wal_period_rec.period9_amount);

	      l_count_costs := l_count_costs + 1;
	      l_cost_position_id(l_count_costs) := l_position_id;
	      l_cost_element_id(l_count_costs) := l_pay_element_id;
	      l_cost_start_date(l_count_costs) := l_period9_start_date;
	      l_cost_end_date(l_count_costs) := l_period9_end_date;
	      l_cost_currency_code(l_count_costs) := c_wal_period_rec.currency_code;
	      l_cost_element_cost(l_count_costs) := l_period9_amount;

	    end;
	    end if;

	    if c_wal_period_rec.period10_amount <> 0 then
	    begin

	      l_period10_amount := ((c_wel_rec.element_cost/c_wal_period_rec.annual_amount) * c_wal_period_rec.period10_amount);

	      l_count_costs := l_count_costs + 1;
	      l_cost_position_id(l_count_costs) := l_position_id;
	      l_cost_element_id(l_count_costs) := l_pay_element_id;
	      l_cost_start_date(l_count_costs) := l_period10_start_date;
	      l_cost_end_date(l_count_costs) := l_period10_end_date;
	      l_cost_currency_code(l_count_costs) := c_wal_period_rec.currency_code;
	      l_cost_element_cost(l_count_costs) := l_period10_amount;

	    end;
	    end if;

	    if c_wal_period_rec.period11_amount <> 0 then
	    begin

	      l_period11_amount := ((c_wel_rec.element_cost/c_wal_period_rec.annual_amount) * c_wal_period_rec.period11_amount);

	      l_count_costs := l_count_costs + 1;
	      l_cost_position_id(l_count_costs) := l_position_id;
	      l_cost_element_id(l_count_costs) := l_pay_element_id;
	      l_cost_start_date(l_count_costs) := l_period11_start_date;
	      l_cost_end_date(l_count_costs) := l_period11_end_date;
	      l_cost_currency_code(l_count_costs) := c_wal_period_rec.currency_code;
	      l_cost_element_cost(l_count_costs) := l_period11_amount;

	    end;
	    end if;

	    if c_wal_period_rec.period12_amount <> 0 then
	    begin

	      l_period12_amount := ((c_wel_rec.element_cost/c_wal_period_rec.annual_amount) * c_wal_period_rec.period12_amount);

	      l_count_costs := l_count_costs + 1;
	      l_cost_position_id(l_count_costs) := l_position_id;
	      l_cost_element_id(l_count_costs) := l_pay_element_id;
	      l_cost_start_date(l_count_costs) := l_period12_start_date;
	      l_cost_end_date(l_count_costs) := l_period12_end_date;
	      l_cost_currency_code(l_count_costs) := c_wal_period_rec.currency_code;
	      l_cost_element_cost(l_count_costs) := l_period12_amount;

	    end;
	    end if;

	  end loop; /* c_wel */
	/*For Bug No : 1808322 End*/

	end;
	end if; /* annual_amount <> 0 */

      end loop; /* c_wal_period */

      -- for bug 4545590
      --for c_wal_rec in c_wal_ps(c_wpl_rec.position_line_id, l_budget_year_id) loop
      for c_wal_rec in c_wal_ps(l_position_rec.position_line_id(loop_var), l_budget_year_id) loop

	if p_flex_mapping_set_id is not null then
	begin

	  l_mapped_ccid := PSB_FLEX_MAPPING_PVT.Get_Mapped_CCID
			      (p_api_version => 1.0,
			       p_ccid => c_wal_rec.code_combination_id,
			       p_budget_year_type_id => l_budget_year_type_id,
			       p_flexfield_mapping_set_id => p_flex_mapping_set_id,
			       p_mapping_mode => 'GL_POSTING');

	  if l_mapped_ccid = 0 then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end;
	else
	  l_mapped_ccid := c_wal_rec.code_combination_id;
	end if;

	/*For Bug No : 1808322 Start*/
	l_count_accounts := l_count_accounts + 1;
	l_account_position_id(l_count_accounts) := l_position_id;
	l_account_bg_id(l_count_accounts) := l_budget_group_id;
	l_account_start_date(l_count_accounts) := l_year_start_date;
	l_account_end_date(l_count_accounts) := l_year_end_date;
	l_account_cc_id(l_count_accounts) := l_mapped_ccid;
	l_account_currency_code(l_count_accounts) := c_wal_rec.currency_code;
	l_account_amount(l_count_accounts) := c_wal_rec.annual_amount;
	/*For Bug No : 1808322 End*/

      end loop; /* c_wal_ps */

    end loop; /* budget years */

    /*For Bug No : 1808322 Start*/
    --i. process the FTE lines
    IF ( l_count_fte >= l_batch_size) THEN
      FOR l_base_line IN 1..2 LOOP

	IF l_base_line = 1 THEN
	  l_base_line_version := 'O';
	ELSE
	  l_base_line_version := 'C';
	END IF;

        -- for bug 4545590
       IF NOT g_wks_new_hr_budget THEN

	FORALL i IN 1..l_count_fte
	UPDATE PSB_POSITION_FTE
	   SET fte =l_fte_fte(i),
	     last_update_date = sysdate,
	       last_updated_by = FND_GLOBAL.USER_ID,
	       last_update_login = FND_GLOBAL.LOGIN_ID
	 WHERE position_id = l_fte_position_id(i)
	   AND nvl(hr_budget_id,-1) = nvl(p_hr_budget_id,-1)
	   AND budget_revision_id is null
	   AND base_line_version = l_base_line_version
	   AND start_date = l_fte_start_date(i)
	   AND end_date = l_fte_end_date(i);

        END IF;

	FOR i IN 1..l_count_fte LOOP
	  -- for bug 4545590
	  IF (NOT g_wks_new_hr_budget) AND (SQL%BULK_ROWCOUNT(i) <> 0 )THEN
	    l_fte_update(i) := 'Y';
	  ELSE
	    l_fte_update(i) := 'N';
	  END IF;
	END LOOP;

	FOR i IN 1..l_count_fte LOOP
	  IF l_fte_update(i) = 'N' THEN

	    Modify_Position_FTE
	      (p_api_version => 1.0,
	       p_return_status => l_return_status,
	       p_msg_count => l_msg_count,
	       p_msg_data => l_msg_data,
	       p_position_id => l_fte_position_id(i),
	       p_hr_budget_id => p_hr_budget_id,
	       p_budget_revision_id => null,
	       p_base_line_version => l_base_line_version,
	       p_fte => l_fte_fte(i),
	       p_start_date => l_fte_start_date(i),
	       p_end_date => l_fte_end_date(i));

	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      raise FND_API.G_EXC_ERROR;
	    END IF;

	  END IF;
	END LOOP;
      END LOOP;

      l_count_fte := 0;
      l_fte_position_id.delete;
      l_fte_start_date.delete;
      l_fte_end_date.delete;
      l_fte_fte.delete;
      l_fte_update.delete;
     END IF;

    --ii. Process the costs lines
    IF ( l_count_costs >= l_batch_size) THEN
      FOR l_base_line IN 1..2 LOOP

	IF l_base_line = 1 THEN
	  l_base_line_version := 'O';
	ELSE
	  l_base_line_version := 'C';
	END IF;

        -- 4545590
        IF NOT g_wks_new_hr_budget THEN

	FORALL i IN 1..l_count_costs
	  UPDATE PSB_POSITION_COSTS
	     SET element_cost = l_cost_element_cost(i),
		 last_update_date = sysdate,
		 last_updated_by = FND_GLOBAL.USER_ID,
		 last_update_login = FND_GLOBAL.LOGIN_ID
	   WHERE position_id = l_cost_position_id(i)
	     AND nvl(hr_budget_id, -1) = nvl(p_hr_budget_id, -1)
	     AND pay_element_id = l_cost_element_id(i)
	     AND currency_code = l_cost_currency_code(i)
	     AND budget_revision_id is null
	     AND base_line_version = l_base_line_version
	     AND start_date = l_cost_start_date(i)
	     AND end_date = l_cost_end_date(i);

         END IF;

	  FOR i IN 1..l_count_costs LOOP
            -- for bug 4545590
	    IF (NOT g_wks_new_hr_budget) AND (SQL%BULK_ROWCOUNT(i) <> 0)  THEN
	      l_cost_update(i) := 'Y';
	    ELSE
	      l_cost_update(i) := 'N';
	    END IF;
	  END LOOP;

	  FOR i IN 1..l_count_costs LOOP
	    IF l_cost_update(i) = 'N' THEN

	     Modify_Position_Costs
	       (p_api_version => 1.0,
		p_return_status => l_return_status,
		p_msg_count => l_msg_count,
		p_msg_data => l_msg_data,
		p_position_id => l_cost_position_id(i),
		p_hr_budget_id => p_hr_budget_id,
		p_pay_element_id => l_cost_element_id(i),
		p_budget_revision_id => null,
		p_base_line_version => l_base_line_version,
		p_start_date => l_cost_start_date(i),
		p_end_date => l_cost_end_date(i),
		p_currency_code => l_cost_currency_code(i),
		p_element_cost => l_cost_element_cost(i));

	     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		raise FND_API.G_EXC_ERROR;
	     END IF;

	    END IF;
	END LOOP;
      END LOOP;

      l_count_costs := 0;
      l_cost_position_id.delete;
      l_cost_start_date.delete;
      l_cost_end_date.delete;
      l_cost_element_id.delete;
      l_cost_currency_code.delete;
      l_cost_element_cost.delete;
      l_cost_update.delete;

     END IF;

     --iii. process the account lines
     IF ( l_count_accounts >= l_batch_size) THEN

       FOR l_base_line IN 1..2 LOOP
	 IF l_base_line = 1 THEN
	   l_base_line_version := 'O';
	 ELSE
	   l_base_line_version := 'C';
	 END IF;

	-- for bug 4545590
         IF NOT g_wks_new_hr_budget THEN

	 FORALL i IN 1..l_count_accounts
	  UPDATE PSB_POSITION_ACCOUNTS
	     SET amount = l_account_amount(i),
		 budget_group_id = l_account_bg_id(i),
		 last_update_date = sysdate,
		 last_updated_by = FND_GLOBAL.USER_ID,
		 last_update_login = FND_GLOBAL.LOGIN_ID
	   WHERE position_id = l_account_position_id(i)
	     AND nvl(hr_budget_id, -1) = nvl(p_hr_budget_id, -1)
	     AND code_combination_id = l_account_cc_id(i)
	     AND currency_code = l_account_currency_code(i)
	     AND budget_revision_id is null
	     AND base_line_version = l_base_line_version
	     AND start_date = l_account_start_date(i)
	     AND end_date = l_account_end_date(i);

	  END IF;

	   FOR i IN 1..l_count_accounts LOOP
	    -- for bug 4545590
	    IF (NOT g_wks_new_hr_budget) AND (SQL%BULK_ROWCOUNT(i) <> 0) THEN
	      l_account_update(i) := 'Y';
	    ELSE
	      l_account_update(i) := 'N';
	    END IF;
	   END LOOP;

	   FOR i IN 1..l_count_accounts LOOP

	    IF l_account_update(i) = 'N' THEN
	     Modify_Position_Accounts
	      (p_api_version => 1.0,
	       p_return_status => l_return_status,
	       p_msg_count => l_msg_count,
	       p_msg_data => l_msg_data,
	       p_position_id => l_account_position_id(i),
	       p_hr_budget_id => p_hr_budget_id,
	       p_budget_revision_id => null,
	       p_budget_group_id => l_account_bg_id(i),
	       p_base_line_version => l_base_line_version,
	       p_start_date => l_account_start_date(i),
	       p_end_date => l_account_end_date(i),
	       p_code_combination_id => l_account_cc_id(i),
	       p_currency_code => l_account_currency_code(i),
	       p_amount => l_account_amount(i));

	     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	       raise FND_API.G_EXC_ERROR;
	     END IF;

	   END IF;
	 END LOOP;
       END LOOP;

       l_count_accounts := 0;
       l_account_position_id.delete;
       l_account_start_date.delete;
       l_account_end_date.delete;
       l_account_cc_id.delete;
       l_account_currency_code.delete;
       l_account_amount.delete;
       l_account_bg_id.delete;
       l_account_update.delete;

     END IF;
     /*For Bug No : 1808322 End*/

     /*For Bug No : 2434152 Start*/
     IF l_position_ctr = g_checkpoint_save THEN
       commit work;
       l_position_ctr := 0;
       Savepoint Upload_Position_Worksheet_Pvt;
     END IF;
     /*For Bug No : 2434152 End*/

  end loop; /* c_wpl */

 /*For Bug No : 1808322 Start*/
  --Process the remaining records existing in the PL/SQL tables

  --i. process the FTE lines
  IF ( l_count_fte > 0) THEN
    FOR l_base_line IN 1..2 LOOP

      IF l_base_line = 1 THEN
	l_base_line_version := 'O';
      ELSE
	l_base_line_version := 'C';
      END IF;

      -- for bug 4545590
      IF NOT g_wks_new_hr_budget THEN

      FORALL i IN 1..l_count_fte
      UPDATE PSB_POSITION_FTE
	 SET fte = l_fte_fte(i),
	     last_update_date = sysdate,
	     last_updated_by = FND_GLOBAL.USER_ID,
	     last_update_login = FND_GLOBAL.LOGIN_ID
       WHERE position_id = l_fte_position_id(i)
	 AND nvl(hr_budget_id,-1) = nvl(p_hr_budget_id,-1)
	 AND budget_revision_id is null
	 AND base_line_version = l_base_line_version
	 AND start_date = l_fte_start_date(i)
	 AND end_date = l_fte_end_date(i);

      END IF;

	FOR i IN 1..l_count_fte LOOP
	  -- for bug 4545590
	  IF (NOT g_wks_new_hr_budget) AND (SQL%BULK_ROWCOUNT(i) <> 0) THEN
	    l_fte_update(i) := 'Y';
	  ELSE
	    l_fte_update(i) := 'N';
	  END IF;
	END LOOP;

	FOR i IN 1..l_count_fte LOOP

	  IF l_fte_update(i) = 'N' THEN
	    Modify_Position_FTE
	      (p_api_version => 1.0,
	       p_return_status => l_return_status,
	       p_msg_count => l_msg_count,
	       p_msg_data => l_msg_data,
	       p_position_id => l_fte_position_id(i),
	       p_hr_budget_id => p_hr_budget_id,
	       p_budget_revision_id => null,
	       p_base_line_version => l_base_line_version,
	       p_fte => l_fte_fte(i),
	       p_start_date => l_fte_start_date(i),
	       p_end_date => l_fte_end_date(i));

	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      raise FND_API.G_EXC_ERROR;
	    END IF;
	  END IF;

	END LOOP;
    END LOOP;

    l_count_fte := 0;
    l_fte_position_id.delete;
    l_fte_start_date.delete;
    l_fte_end_date.delete;
    l_fte_fte.delete;
    l_fte_update.delete;

  END IF;

  --ii. Process the costs lines
  IF ( l_count_costs > 0) THEN
    FOR l_base_line IN 1..2 LOOP

      IF l_base_line = 1 THEN
	l_base_line_version := 'O';
      ELSE
	l_base_line_version := 'C';
      END IF;

      -- for bug 4545590
      IF NOT g_wks_new_hr_budget THEN

      FORALL i IN 1..l_count_costs
	  UPDATE PSB_POSITION_COSTS
	     SET element_cost = l_cost_element_cost(i),
		 last_update_date = sysdate,
		 last_updated_by = FND_GLOBAL.USER_ID,
		 last_update_login = FND_GLOBAL.LOGIN_ID
	   WHERE position_id = l_cost_position_id(i)
	     AND nvl(hr_budget_id, -1) = nvl(p_hr_budget_id, -1)
	     AND pay_element_id = l_cost_element_id(i)
	     AND currency_code = l_cost_currency_code(i)
	     AND budget_revision_id is null
	     AND base_line_version = l_base_line_version
	     AND start_date = l_cost_start_date(i)
	     AND end_date = l_cost_end_date(i);

       END IF;


	FOR i IN 1..l_count_costs LOOP
	  -- for bug 4545590
	  IF (NOT g_wks_new_hr_budget) AND (SQL%BULK_ROWCOUNT(i) <> 0) THEN
	    l_cost_update(i) := 'Y';
	  ELSE
	    l_cost_update(i) := 'N';
	  END IF;
	END LOOP;

	FOR i IN 1..l_count_costs LOOP
	  IF l_cost_update(i) = 'N' THEN

	    Modify_Position_Costs
	       (p_api_version => 1.0,
		p_return_status => l_return_status,
		p_msg_count => l_msg_count,
		p_msg_data => l_msg_data,
		p_position_id => l_cost_position_id(i),
		p_hr_budget_id => p_hr_budget_id,
		p_pay_element_id => l_cost_element_id(i),
		p_budget_revision_id => null,
		p_base_line_version => l_base_line_version,
		p_start_date => l_cost_start_date(i),
		p_end_date => l_cost_end_date(i),
		p_currency_code => l_cost_currency_code(i),
		p_element_cost => l_cost_element_cost(i));

	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		raise FND_API.G_EXC_ERROR;
	    END IF;

	    END IF;
      END LOOP;
    END LOOP;

    l_count_costs := 0;
    l_cost_position_id.delete;
    l_cost_start_date.delete;
    l_cost_end_date.delete;
    l_cost_element_id.delete;
    l_cost_currency_code.delete;
    l_cost_element_cost.delete;
    l_cost_update.delete;

   END IF;

   --iii. process the account lines
   IF ( l_count_accounts > 0) THEN

     FOR l_base_line IN 1..2 LOOP

       IF l_base_line = 1 THEN
	 l_base_line_version := 'O';
       ELSE
	 l_base_line_version := 'C';
       END IF;

	-- FOR BUG 4545590
       IF NOT g_wks_new_hr_budget THEN

       FORALL i IN 1..l_count_accounts
	  UPDATE PSB_POSITION_ACCOUNTS
	     SET amount = l_account_amount(i),
		 budget_group_id = l_account_bg_id(i),
		 last_update_date = sysdate,
		 last_updated_by = FND_GLOBAL.USER_ID,
		 last_update_login = FND_GLOBAL.LOGIN_ID
	   WHERE position_id = l_account_position_id(i)
	     AND nvl(hr_budget_id, -1) = nvl(p_hr_budget_id, -1)
	     AND code_combination_id = l_account_cc_id(i)
	     AND currency_code = l_account_currency_code(i)
	     AND budget_revision_id is null
	     AND base_line_version = l_base_line_version
	     AND start_date = l_account_start_date(i)
	     AND end_date = l_account_end_date(i);

	END IF;

	 FOR i IN 1..l_count_accounts LOOP
	  -- for bug 4545590
	  IF (NOT g_wks_new_hr_budget) AND (SQL%BULK_ROWCOUNT(i) <> 0) THEN
	    l_account_update(i) := 'Y';
	  ELSE
	    l_account_update(i) := 'N';
	  END IF;
	 END LOOP;

	 FOR i IN 1..l_count_accounts LOOP

	   IF l_account_update(i) = 'N' THEN
	     Modify_Position_Accounts
	      (p_api_version => 1.0,
	       p_return_status => l_return_status,
	       p_msg_count => l_msg_count,
	       p_msg_data => l_msg_data,
	       p_position_id => l_account_position_id(i),
	       p_hr_budget_id => p_hr_budget_id,
	       p_budget_revision_id => null,
	       p_budget_group_id => l_account_bg_id(i),
	       p_base_line_version => l_base_line_version,
	       p_start_date => l_account_start_date(i),
	       p_end_date => l_account_end_date(i),
	       p_code_combination_id => l_account_cc_id(i),
	       p_currency_code => l_account_currency_code(i),
	       p_amount => l_account_amount(i));

	   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     raise FND_API.G_EXC_ERROR;
	   END IF;

	   END IF;
       END LOOP;
     END LOOP;

     l_count_accounts := 0;
     l_account_position_id.delete;
     l_account_start_date.delete;
     l_account_end_date.delete;
     l_account_cc_id.delete;
     l_account_currency_code.delete;
     l_account_amount.delete;
     l_account_bg_id.delete;
     l_account_update.delete;

   END IF;
 /*For Bug No : 1808322 End*/

  /*For Bug No : 2434152 Start*/
  --Perform commit for all unsaved records
  commit work;
  /*For Bug No : 2434152 End*/

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     /*For Bug No : 2434152 Start*/
     rollback to Upload_Position_Worksheet_Pvt;
     /*For Bug No : 2434152 End*/
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     /*For Bug No : 2434152 Start*/
     rollback to Upload_Position_Worksheet_Pvt;
     /*For Bug No : 2434152 End*/
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     /*For Bug No : 2434152 Start*/
     rollback to Upload_Position_Worksheet_Pvt;
     /*For Bug No : 2434152 End*/
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Upload_Position_Worksheet;

/* ----------------------------------------------------------------------- */

PROCEDURE Record_Position_Transaction
( p_return_status          OUT  NOCOPY  VARCHAR2,
  p_msg_count              OUT  NOCOPY  NUMBER,
  p_msg_data               OUT  NOCOPY  VARCHAR2,
  p_event_type             IN   VARCHAR2,
  p_source_id              IN   NUMBER,
  p_hr_budget_id           IN   NUMBER,
  p_from_budget_year_id    IN   NUMBER,
  p_to_budget_year_id      IN   NUMBER,
  p_transfer_to_interface  IN   VARCHAR2,
  p_transfer_to_hrms       IN   VARCHAR2
) IS

  l_position_event_id      NUMBER;

  l_api_name               CONSTANT VARCHAR2(30)   := 'Record_Position_Transaction';

BEGIN

  if p_hr_budget_id is null then
  begin

    update PSB_POSITION_EVENTS_ALL
       set org_id = FND_PROFILE.VALUE('ORG_ID'),
	   transfer_to_interface = p_transfer_to_interface,
	   transfer_to_hrms = p_transfer_to_hrms,
	   interface_last_update_date = sysdate,
	   interface_last_updated_by = FND_GLOBAL.USER_ID,
	   interface_last_update_login = FND_GLOBAL.LOGIN_ID,
	   hrms_last_update_date = sysdate,
	   hrms_last_updated_by = FND_GLOBAL.USER_ID,
	   hrms_last_update_login = FND_GLOBAL.LOGIN_ID
     where event_type = p_event_type
       and source_id = p_source_id
       and from_budget_year_id = p_from_budget_year_id
       and to_budget_year_id = p_to_budget_year_id
       and hr_budget_id is null;

  end;
  else
  begin

    update PSB_POSITION_EVENTS_ALL
       set org_id = FND_PROFILE.VALUE('ORG_ID'),
	   transfer_to_interface = p_transfer_to_interface,
	   transfer_to_hrms = p_transfer_to_hrms,
	   interface_last_update_date = sysdate,
	   interface_last_updated_by = FND_GLOBAL.USER_ID,
	   interface_last_update_login = FND_GLOBAL.LOGIN_ID,
	   hrms_last_update_date = sysdate,
	   hrms_last_updated_by = FND_GLOBAL.USER_ID,
	   hrms_last_update_login = FND_GLOBAL.LOGIN_ID
     where event_type = p_event_type
       and source_id = p_source_id
       and from_budget_year_id = p_from_budget_year_id
       and to_budget_year_id = p_to_budget_year_id
       and hr_budget_id = p_hr_budget_id;

  end;
  end if;

  if SQL%NOTFOUND then
  begin

    INSERT INTO PSB_POSITION_EVENTS_ALL
	  (position_event_id,
	   event_type,
	   source_id,
	   org_id,
	   hr_budget_id,
	   from_budget_year_id,
	   to_budget_year_id,
	   transfer_to_interface,
	   transfer_to_hrms,
	   interface_created_by,
	   interface_creation_date,
	   interface_last_update_date,
	   interface_last_updated_by,
	   interface_last_update_login,
	   hrms_created_by,
	   hrms_creation_date,
	   hrms_last_update_date,
	   hrms_last_updated_by,
	   hrms_last_update_login)
    VALUES (PSB_POSITION_EVENTS_ALL_S.NEXTVAL,
	    p_event_type,
	    p_source_id,
	    FND_PROFILE.VALUE('ORG_ID'),
	    p_hr_budget_id,
	    p_from_budget_year_id,
	    p_to_budget_year_id,
	    p_transfer_to_interface,
	    p_transfer_to_hrms,
	    FND_GLOBAL.USER_ID,
	    sysdate,
	    sysdate,
	    FND_GLOBAL.USER_ID,
	    FND_GLOBAL.LOGIN_ID,
	    FND_GLOBAL.USER_ID,
	    sysdate,
	    sysdate,
	    FND_GLOBAL.USER_ID,
	    FND_GLOBAL.LOGIN_ID) RETURNING position_event_id into l_position_event_id;

  end;
  end if;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
END Record_Position_Transaction;

/* ----------------------------------------------------------------------- */

-- Check if position exists in Worksheet or Budget Revision

FUNCTION Position_Exists
( p_event_type              VARCHAR2,
  p_source_id               NUMBER,
  p_position_id             NUMBER) RETURN BOOLEAN IS

  l_position_exists         BOOLEAN := FALSE;

  cursor c_position_exists_bp is
    select 'Exists'
      from dual
     where exists
	  (select 'Exists'
	     from psb_ws_position_lines wpl, psb_ws_lines_positions wlp
	    where wpl.position_id = p_position_id
	      and wlp.position_line_id = wpl.position_line_id
	      and wlp.worksheet_id = p_source_id);

  cursor c_position_exists_br is
    select 'Exists'
      from dual
     where exists
	  (select 'Exists'
	     from psb_budget_revision_positions brp, psb_budget_revision_pos_lines brpl
	    where brp.position_id = p_position_id
	      and brpl.budget_revision_pos_line_id = brp.budget_revision_pos_line_id
	      and brpl.budget_revision_id = p_source_id);

BEGIN

  if p_event_type = 'BP' then
  begin

    for c_position_rec in c_position_exists_bp loop
      l_position_exists := TRUE;
    end loop;

  end;
  elsif p_event_type = 'BR' then
  begin

    for c_position_rec in c_position_exists_br loop
      l_position_exists := TRUE;
    end loop;

  end;
  end if;

  return l_position_exists;

END Position_Exists;

/* ----------------------------------------------------------------------- */

-- Check if account distribution for position exists in worksheet or budget
-- revision

FUNCTION AcctDist_Exists
( p_event_type   VARCHAR2,
  p_source_id    NUMBER,
  p_position_id  NUMBER) RETURN BOOLEAN IS

  l_dist_exists  BOOLEAN := FALSE;

  cursor c_dist_exists_bp is
    select 'Exists'
      from dual
     where exists
	  (select 'Exists'
	     from psb_ws_position_lines wpl, psb_ws_lines_positions wlp, psb_ws_account_lines wal
	    where wpl.position_id = p_position_id
	      and wlp.position_line_id = wpl.position_line_id
	      and wlp.worksheet_id = p_source_id
	      and wal.position_line_id = wpl.position_line_id);

  cursor c_dist_exists_br is
    select 'Exists'
      from dual
     where exists
	  (select 'Exists'
	     from psb_position_accounts
	    where budget_revision_id = p_source_id
	      and position_id = p_position_id);

BEGIN

  if p_event_type = 'BP' then
  begin

    for c_dist_rec in c_dist_exists_bp loop
      l_dist_exists := TRUE;
    end loop;

  end;
  elsif p_event_type = 'BR' then
  begin

    for c_dist_rec in c_dist_exists_br loop
      l_dist_exists := TRUE;
    end loop;

  end;
  end if;

  return l_dist_exists;

END AcctDist_Exists;

/* ----------------------------------------------------------------------- */

-- Check that the position budget is complete : all position transactions in
-- the worksheet or budget revision have been approved and all positions have
-- an account distribution for charging the position cost

PROCEDURE Validate_Position_Budget
( p_return_status  OUT  NOCOPY  VARCHAR2,
  --p_msg_count      OUT  NOCOPY  NUMBER,
  --p_msg_data       OUT  NOCOPY  VARCHAR2,
  p_event_type     IN   VARCHAR2,
  p_source_id      IN   NUMBER) IS

  l_data_extract_id     NUMBER;
  l_budget_group_id     NUMBER;
  l_no_hr_pos_count     NUMBER := 0;
  l_no_acct_dist        NUMBER := 0;

  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  cursor c_bp is
    select data_extract_id from psb_worksheets where worksheet_id = p_source_id;

  cursor c_revision is
    select budget_group_id from psb_budget_revisions where budget_revision_id = p_source_id;

  cursor c_position is
    select position_id, name, hr_position_id, hr_employee_id
      from psb_positions
     where data_extract_id = l_data_extract_id;

/* Fix for Bug #2642767 Start */
  cursor c_no_hr_position (positionid NUMBER) is
    select name, transaction_id
      from psb_positions
     where position_id = positionid
       and hr_position_id is null;
/* Fix for Bug #2642767 End */

  l_api_name               CONSTANT VARCHAR2(30)   := 'Validate_Position_Budget';

BEGIN

  if p_event_type = 'BP' then
  begin

    for c_worksheet_rec in c_bp loop
      l_data_extract_id := c_worksheet_rec.data_extract_id;
    end loop;

    for c_position_rec in c_position loop

      -- check if position exists in worksheet or budget revision

      if (Position_Exists(p_event_type => p_event_type, p_source_id => p_source_id,
	  p_position_id => c_position_rec.position_id)) then
      begin

	-- check that all positions are mapped to HR positions
	for c_no_hr_position_rec in c_no_hr_position (c_position_rec.position_id) loop
/* Fix for Bug #2642767 Start */
          if c_no_hr_position_rec.transaction_id is null then
     	      message_token('POSITION',c_no_hr_position_rec.name);
	      add_message('PSB', 'PSB_PQH_NO_HR_POSITION');
	  else
              message_token('POSITION',c_no_hr_position_rec.name);
              add_message('PSB', 'PSB_PQH_NO_HR_POSITION_TRX');
 	  end if;
	  l_no_hr_pos_count := l_no_hr_pos_count + 1;
	end loop;
/* Fix for Bug #2642767 End*/

	if not AcctDist_Exists (p_event_type => p_event_type, p_source_id => p_source_id,
				p_position_id => c_position_rec.position_id) then
	  message_token('POSITION', c_position_rec.name);
	  add_message('PSB', 'PSB_PQH_NO_DIST_POSITION');
	  l_no_acct_dist := l_no_acct_dist + 1;
	end if;

      end;
      end if;

    end loop;

  end;
  elsif p_event_type = 'BR' then
  begin

    for c_revision_rec in c_revision loop
      l_budget_group_id := c_revision_rec.budget_group_id;
    end loop;

    l_data_extract_id := PSB_BUDGET_REVISIONS_PVT.Find_System_Data_Extract
			    (p_budget_group_id => l_budget_group_id);

    for c_position_rec in c_position loop

      -- check if position exists in worksheet or budget revision

      if (Position_Exists(p_event_type => p_event_type, p_source_id => p_source_id,
	  p_position_id => c_position_rec.position_id)) then
      begin

	-- check that all positions are mapped to HR positions
	for c_no_hr_position_rec in c_no_hr_position (c_position_rec.position_id) loop
/* Fix for Bug #2642767 Start */
          if c_no_hr_position_rec.transaction_id is null then
              message_token('POSITION',c_no_hr_position_rec.name);
              add_message('PSB', 'PSB_PQH_NO_HR_POSITION');
          else
              message_token('POSITION',c_no_hr_position_rec.name);
              add_message('PSB', 'PSB_PQH_NO_HR_POSITION_TRX');
          end if;
/* Fix for Bug #2642767 End*/
	  l_no_hr_pos_count := l_no_hr_pos_count + 1;
	end loop;

	if not AcctDist_Exists (p_event_type => p_event_type, p_source_id => p_source_id,
				p_position_id => c_position_rec.position_id) then
	  message_token('POSITION', c_position_rec.name);
	  add_message('PSB', 'PSB_PQH_NO_DIST_POSITION');
	  l_no_acct_dist := l_no_acct_dist + 1;
	end if;

      end;
      end if;

    end loop;

  end;
  end if;

  if ((l_no_hr_pos_count > 0) or (l_no_acct_dist > 0)) then
    FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE', 'HR Pos Count 0');
    FND_MSG_PUB.Add;
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);

     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data  => l_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);

     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data  => l_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => l_msg_count,
				p_data  => l_msg_data);

END Validate_Position_Budget;

/* ----------------------------------------------------------------------- */

PROCEDURE Upload_Worksheet
( p_api_version          IN   NUMBER,
  p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status        OUT  NOCOPY  VARCHAR2,
  p_msg_count            OUT  NOCOPY  NUMBER,
  p_msg_data             OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER,
  p_hr_budget_id         IN   NUMBER,
  p_from_budget_year_id  IN   NUMBER,
  p_to_budget_year_id    IN   NUMBER
) IS

  l_api_name               CONSTANT VARCHAR2(30)   := 'Upload_Worksheet';
  l_api_version            CONSTANT NUMBER         := 1.0;

  l_data_extract_id        NUMBER;
  l_business_group_id      NUMBER;
  l_budget_group_id        NUMBER;
  l_budget_calendar_id     NUMBER;
  l_system_data_extract_id NUMBER;
  l_flex_mapping_set_id    NUMBER;
  l_position_id_flex_num   NUMBER;
  l_root_budget_group_id   NUMBER;
  l_root_set_of_books_id   NUMBER;
  l_root_short_name        VARCHAR2(20);
  l_data_extract_name      VARCHAR2(30);

  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);

  l_return_status          VARCHAR2(1);

  cursor c_WS is
    select a.data_extract_id,
	   b.business_group_id,
	   b.position_id_flex_num,
	   a.budget_calendar_id,
	   a.budget_group_id,
	   a.flex_mapping_set_id
      from PSB_WORKSHEETS a,
	   PSB_DATA_EXTRACTS b
     where a.worksheet_id = p_worksheet_id
       and b.data_extract_id = a.data_extract_id;

  cursor c_root_budget_group is
    Select nvl(root_budget_group_id, budget_group_id) budget_group_id,
	   nvl(root_set_of_books_id, set_of_books_id) set_of_books_id,
	   nvl(root_short_name, short_name) short_name,
	   business_group_id
      from psb_budget_groups_v
     where budget_group_id = l_budget_group_id;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Upload_Worksheet_Pvt;

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

  for c_WS_Rec in c_WS loop
    l_data_extract_id := c_WS_Rec.data_extract_id;
    l_business_group_id := c_WS_Rec.business_group_id;
    l_budget_group_id := c_WS_Rec.budget_group_id;
    l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
    l_flex_mapping_set_id := c_WS_Rec.flex_mapping_set_id;
    l_position_id_flex_num := c_WS_Rec.position_id_flex_num;
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
  /* start bug 4545590 */
  else
    -- The same calendar for the worksheet
    -- If the calendar is same, then there cannot be overlapping of periods
    g_wks_no_date_overlap := TRUE;
  /* end bug 4545590 */
  end if;

  -- for bug 4507389
  -- get the budget year start date and the budget year end date
  -- this is used to upload salary distributions
  FOR l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years LOOP
    IF PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id
        = p_from_budget_year_id THEN
      g_year_start_date
        := PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
    END IF;

    IF PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_id
        = p_to_budget_year_id THEN
      g_year_end_date
        := PSB_WS_ACCT1.g_budget_years(l_year_index).end_date;
    END IF;
  END LOOP;
  -- for bug 4507389


  l_system_data_extract_id := PSB_BUDGET_REVISIONS_PVT.Find_System_Data_Extract
				  (p_budget_group_id => l_budget_group_id);

  if l_system_data_extract_id is null then
  begin

    for c_root_budget_group_rec in c_root_budget_group loop
      l_root_budget_group_id := c_root_budget_group_rec.budget_group_id;
      l_root_set_of_books_id := c_root_budget_group_rec.set_of_books_id;
      l_root_short_name      := c_root_budget_group_rec.short_name;
    end loop;

    l_data_extract_name := fnd_message.get_string( 'PSB',
			   'PSB_SYSTEM_DATA_EXTRACT_NAME')||' '||l_root_short_name;

    INSERT INTO PSB_DATA_EXTRACTS
	  (DATA_EXTRACT_ID, DATA_EXTRACT_NAME, DATA_EXTRACT_METHOD,
	   SET_OF_BOOKS_ID, BUSINESS_GROUP_ID, BUDGET_GROUP_ID,
	   POSITION_ID_FLEX_NUM, BASE_SALARY_DATE, REQ_DATA_AS_OF_DATE,
	   LAST_EXTRACT_DATE, LAST_UPDATE_DATE, LAST_UPDATED_BY,
	   LAST_UPDATE_LOGIN, CREATED_BY, CREATION_DATE, SYSTEM_DATA_EXTRACT)
    VALUES (PSB_DATA_EXTRACTS_S.NEXTVAL, l_data_extract_name, 'CREATE',
	    l_root_set_of_books_id, l_business_group_id, l_root_budget_group_id,
	    l_position_id_flex_num, null, sysdate,
	    sysdate, sysdate, FND_GLOBAL.USER_ID,
	    FND_GLOBAL.LOGIN_ID, FND_GLOBAL.USER_ID, sysdate, 'Y') RETURNING data_extract_id into l_system_data_extract_id;

  end;
  end if;

  -- check that all position transactions in the worksheet have been approved

  Validate_Position_Budget
	 (p_return_status => l_return_status,
          --p_msg_count => l_msg_count,
          --p_msg_data => l_msg_data,
	  p_event_type => 'BP',
	  p_source_id => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Lock Worksheet in exclusive mode

  PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_concurrency_class => 'WORKSHEET_CONSOLIDATION',
      p_concurrency_entity_name => 'DATA_EXTRACT',
      p_concurrency_entity_id => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  Upload_Attribute_Values
       (p_return_status => l_return_status,
	p_source_data_extract_id => l_data_extract_id,
	p_source_business_group_id => l_business_group_id,
	p_target_data_extract_id => l_system_data_extract_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  commit work;

  Upload_Elements
       (p_return_status => l_return_status,
	p_source_data_extract_id => l_data_extract_id,
	p_target_data_extract_id => l_system_data_extract_id,
	p_worksheet_id => p_worksheet_id,
	p_budget_calendar_id => l_budget_calendar_id,
	p_flex_mapping_set_id => l_flex_mapping_set_id,
	p_budget_group_id => l_budget_group_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  commit work;

  Upload_Employees
      (p_return_status => l_return_status,
       p_source_data_extract_id => l_data_extract_id,
       p_source_business_group_id => l_business_group_id,
       p_target_data_extract_id => l_system_data_extract_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  commit work;

  Upload_Positions
      (p_return_status => l_return_status,
       p_worksheet_id => p_worksheet_id,
       p_budget_calendar_id => l_budget_calendar_id,
       p_flex_mapping_set_id => l_flex_mapping_set_id,
       p_source_data_extract_id => l_data_extract_id,
       p_target_data_extract_id => l_system_data_extract_id,
       /* Bug 3867577 Start */
       -- To synchronize with the added parameters.
       p_from_budget_year_id    => p_from_budget_year_id,
       p_to_budget_year_id      => p_to_budget_year_id
       /* Bug 3867577 End */
);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  commit work;
  /*For Bug No : 2434152 Start*/
  --Save point is not required since the COMMIT in
  --the following API call overrides the same.
  --SAVEPOINT     Upload_Worksheet_Pvt;
  /*For Bug No : 2434152 End*/

  -- Create Positions from the position sets for the system data extract

  PSB_BUDGET_POSITION_PVT.Populate_Budget_Positions
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_data_extract_id => l_system_data_extract_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  commit work;

  -- Lock Worksheet in exclusive mode

  PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_concurrency_class => 'WORKSHEET_CONSOLIDATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  Upload_Position_Worksheet
      (p_return_status => l_return_status,
       p_worksheet_id => p_worksheet_id,
       p_flex_mapping_set_id => l_flex_mapping_set_id,
       p_budget_calendar_id => l_budget_calendar_id,
       p_target_data_extract_id => l_system_data_extract_id,
       p_hr_budget_id => p_hr_budget_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  Record_Position_Transaction
      (p_return_status => l_return_status,
       p_msg_count => l_msg_count,
       p_msg_data => l_msg_data,
       p_event_type => 'BP',
       p_source_id => p_worksheet_id,
       p_hr_budget_id => p_hr_budget_id,
       p_from_budget_year_id => p_from_budget_year_id,
       p_to_budget_year_id => p_to_budget_year_id,
       p_transfer_to_interface => 'Y',
       p_transfer_to_hrms => 'N');

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Standard check of p_commit.
  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     /*For Bug No : 2434152 Start*/
     --rollback to Upload_Worksheet_Pvt;
     rollback;
     /*For Bug No : 2434152 End*/
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     /*For Bug No : 2434152 Start*/
     --rollback to Upload_Worksheet_Pvt;
     rollback;
     /*For Bug No : 2434152 End*/
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     /*For Bug No : 2434152 Start*/
     --rollback to Upload_Worksheet_Pvt;
     rollback;
     /*For Bug No : 2434152 End*/
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Upload_Worksheet;

/* ----------------------------------------------------------------------- */

-- This is the execution file for the concurrent program "Upload Worksheet
-- to Position Control" through Standard Report Submissions

PROCEDURE Upload_Worksheet_CP
( errbuf                 OUT  NOCOPY  VARCHAR2,
  retcode                OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER,
  p_hr_budget_id         IN   NUMBER,
  p_from_budget_year_id  IN   NUMBER,
  p_to_budget_year_id    IN   NUMBER,
  p_run_mode             IN   VARCHAR2
) IS

  l_api_name             CONSTANT VARCHAR2(30)   := 'Upload_Worksheet_CP';
  l_api_version          CONSTANT NUMBER         :=  1.0;

  l_return_status        VARCHAR2(1);
  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);

  /* bug no 3670254 */
  -- This variable stores the data extract used for worksheet
  l_data_extract_id 	 NUMBER;
  /* bug no 3670254 */

  -- for bug 4545590
  lp_num_var		 NUMBER := 0;

begin

  /* bug no 3670254 */
  -- get the profile value for FTE upload
  fnd_profile.get('PSB_HRMS_FTE_UPLOAD_OPTION', g_hrms_fte_upload_option);
  g_hrms_fte_upload_option := NVL(g_hrms_fte_upload_option, 'PERIOD');

  IF g_hrms_fte_upload_option = 'ASSIGNMENT' THEN
    -- fetch the data extract used for position worksheet
    FOR l_data_extract_rec IN (SELECT data_extract_id
	               	       FROM   psb_worksheets
	               	       WHERE  worksheet_id = p_worksheet_id)
    LOOP
      l_data_extract_Id := l_data_extract_rec.data_extract_id;
    END LOOP;

    -- This cursor gets the Attribute id for the business group
    -- associated with the data extract.
    FOR l_att_fte_rec IN (SELECT attribute_id FROM psb_attributes a,
                                                   psb_data_extracts b
			  WHERE a.business_group_id = b.business_group_id
			  AND a.system_attribute_type = 'FTE'
			  AND b.data_extract_id = l_data_extract_Id)
    LOOP
      g_fte_attribute_Id := l_att_fte_rec.attribute_id;
    END LOOP;
  END IF;
  /* Bug No 3670254 */

  /* Start Bug 4545590 */
  g_wks_no_date_overlap := FALSE;
  g_wks_new_hr_budget := FALSE;

  IF p_hr_budget_id IS NOT NULL THEN
    FOR li_csr IN ( SELECT 1 new_bud
			  FROM   dual
			  WHERE EXISTS (SELECT 1
			  		  FROM psb_position_events_all
			  		  WHERE event_type = 'BP'
			                AND hr_budget_id = p_hr_budget_id)) LOOP
      lp_num_var := li_csr.new_bud;
    END LOOP;

    IF lp_num_var = 0 THEN
    	g_wks_no_date_overlap := TRUE;
	g_wks_new_hr_budget := TRUE;
    END IF;

  END IF;
  /* End Bug 4545590 */


  Upload_Budget_HRMS
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_validation_level => FND_API.G_VALID_LEVEL_FULL,
	p_msg_count => l_msg_count,
	p_msg_data => l_msg_data,
	p_event_type => 'BP',
	p_source_id => p_worksheet_id,
	p_hr_budget_id => p_hr_budget_id,
	p_from_budget_year_id => p_from_budget_year_id,
	p_to_budget_year_id => p_to_budget_year_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  Upload_Worksheet
	(p_api_version => 1.0,
	 p_commit => FND_API.G_TRUE,
	 p_init_msg_list => FND_API.G_TRUE,
	 p_return_status => l_return_status,
	 p_msg_count => l_msg_count,
	 p_msg_data => l_msg_data,
	 p_worksheet_id => p_worksheet_id,
	 p_hr_budget_id => p_hr_budget_id,
	 p_from_budget_year_id => p_from_budget_year_id,
	 p_to_budget_year_id => p_to_budget_year_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  if ((p_run_mode = 'F') and (p_hr_budget_id is not null)) then
  begin

    Upload_Budget_HRMS
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_validation_level => FND_API.G_VALID_LEVEL_NONE,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_event_type => 'BP',
	  p_source_id => p_worksheet_id,
	  p_hr_budget_id => p_hr_budget_id,
	  p_from_budget_year_id => p_from_budget_year_id,
	  p_to_budget_year_id => p_to_budget_year_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;
    /* Start Bug No. 2322856 */
--  PSB_MESSAGE_S.Print_Success;
    /* End Bug No. 2322856 */
  retcode := 0;

  commit work;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     PSB_MESSAGE_S.Print_Error (p_mode => FND_FILE.LOG,
				p_print_header => FND_API.G_TRUE);
     retcode := 2;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     PSB_MESSAGE_S.Print_Error (p_mode => FND_FILE.LOG,
				p_print_header => FND_API.G_TRUE);
     retcode := 2;

   when OTHERS then
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     PSB_MESSAGE_S.Print_Error (p_mode => FND_FILE.LOG,
				p_print_header => FND_API.G_TRUE);
     retcode := 2;

END Upload_Worksheet_CP;

/* ----------------------------------------------------------------------- */

FUNCTION Prorate
(p_original_amount      NUMBER,
 p_original_start_date  DATE,
 p_original_end_date    DATE,
 p_new_start_date       DATE,
 p_new_end_date         DATE
) RETURN NUMBER IS

  l_prorated_value       NUMBER;

BEGIN

  l_prorated_value := p_original_amount
		      * (p_new_end_date - p_new_start_date + 1)
		      / (p_original_end_date - p_original_start_date + 1);

  return l_prorated_value;

END Prorate;

/* ----------------------------------------------------------------------- */

PROCEDURE Insert_Position_Accounts
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_msg_count             OUT  NOCOPY  NUMBER,
  p_msg_data              OUT  NOCOPY  VARCHAR2,
  p_position_id           IN   NUMBER,
  p_hr_budget_id          IN   NUMBER,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE,
  p_code_combination_id   IN   NUMBER,
  p_budget_group_id       IN   NUMBER,
  p_currency_code         IN   VARCHAR2,
  p_amount                IN   NUMBER,
  p_budget_revision_id    IN   NUMBER,
  p_base_line_version     IN   VARCHAR2
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Position_Accounts';
  l_position_account_line_id   NUMBER;

BEGIN

  insert into PSB_POSITION_ACCOUNTS
	(position_account_line_id, position_id, hr_budget_id, budget_revision_id, budget_group_id,
	 base_line_version, start_date, end_date, code_combination_id, currency_code,
	 amount, last_update_date, last_updated_by, last_update_login, created_by, creation_date)
   values (PSB_POSITION_ACCOUNTS_S.NEXTVAL, p_position_id, p_hr_budget_id, p_budget_revision_id, p_budget_group_id,
	   p_base_line_version, p_start_date, p_end_date, p_code_combination_id, p_currency_code,
	   p_amount, sysdate, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID, FND_GLOBAL.USER_ID, sysdate)
  RETURNING position_account_line_id into l_position_account_line_id;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Insert_Position_Accounts;

/* ----------------------------------------------------------------------- */

PROCEDURE Update_Position_Accounts
( p_return_status             OUT  NOCOPY  VARCHAR2,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
  p_position_account_line_id  IN   NUMBER,
  p_budget_group_id           IN   NUMBER,
  p_start_date                IN   DATE := FND_API.G_MISS_DATE,
  p_end_date                  IN   DATE := FND_API.G_MISS_DATE,
  p_amount                    IN   NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Position_Accounts';

BEGIN

  update PSB_POSITION_ACCOUNTS
     set amount = p_amount,
	 budget_group_id = p_budget_group_id,
	 start_date = decode(p_start_date, FND_API.G_MISS_DATE, start_date, p_start_date),
	 end_date = decode(p_end_date, FND_API.G_MISS_DATE, end_date, p_end_date),
	 last_update_date = sysdate,
	 last_updated_by = FND_GLOBAL.USER_ID,
	 last_update_login = FND_GLOBAL.LOGIN_ID
    where position_account_line_id = p_position_account_line_id;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Update_Position_Accounts;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_Position_Accounts
( p_return_status             OUT  NOCOPY  VARCHAR2,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
  p_position_account_line_id  IN   NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Delete_Position_Accounts';

BEGIN

  delete from PSB_POSITION_ACCOUNTS
   where position_account_line_id = p_position_account_line_id;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Delete_Position_Accounts;

/* ----------------------------------------------------------------------- */

PROCEDURE Modify_Position_Accounts
( p_api_version           IN   NUMBER,
  p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status         OUT  NOCOPY  VARCHAR2,
  p_msg_count             OUT  NOCOPY  NUMBER,
  p_msg_data              OUT  NOCOPY  VARCHAR2,
  p_position_id           IN   NUMBER,
  p_hr_budget_id          IN   NUMBER,
  p_budget_revision_id    IN   NUMBER,
  p_budget_group_id       IN   NUMBER,
  p_base_line_version     IN   VARCHAR2,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE,
  p_code_combination_id   IN   NUMBER,
  p_currency_code         IN   VARCHAR2,
  p_amount                IN   NUMBER
) IS

  l_api_name              CONSTANT VARCHAR2(30)   := 'Modify_Position_Accounts';
  l_api_version           CONSTANT NUMBER         := 1.0;

  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);

  l_created_record        BOOLEAN := FALSE;
  l_updated_record        BOOLEAN;

  l_return_status         VARCHAR2(1);
  /*For Bug No : 1808322 Start*/
  l_update_flag           BOOLEAN := TRUE;
  /*For Bug No : 1808322 End*/

  cursor c_Overlap is
    select *
      from PSB_POSITION_ACCOUNTS
     where position_id = p_position_id
       and nvl(hr_budget_id, -1) = nvl(p_hr_budget_id, -1)
       and code_combination_id = p_code_combination_id
       and currency_code = p_currency_code
       and nvl(budget_revision_id, -1) = nvl(p_budget_revision_id, -1)
       and nvl(base_line_version, FND_API.G_MISS_CHAR) = nvl(p_base_line_version, FND_API.G_MISS_CHAR)
       and ((((p_end_date is not null)
	 and ((start_date <= p_end_date)
	  and (end_date is null))
	  or ((start_date between p_start_date and p_end_date)
	   or (end_date between p_start_date and p_end_date)
	  or ((start_date < p_start_date)
	  and (end_date > p_end_date)))))
	  or ((p_end_date is null)
	  and (nvl(end_date, p_start_date) >= p_start_date)));

BEGIN

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

  /*For Bug No : 1808322 Start*/
  IF p_budget_revision_id IS NOT null  THEN
  /*For Bug No : 1808322 End*/

  update PSB_POSITION_ACCOUNTS
     set amount = p_amount,
	 budget_group_id = p_budget_group_id,
	 last_update_date = sysdate,
	 last_updated_by = FND_GLOBAL.USER_ID,
	 last_update_login = FND_GLOBAL.LOGIN_ID
   where position_id = p_position_id
     and nvl(hr_budget_id, -1) = nvl(p_hr_budget_id, -1)
     and code_combination_id = p_code_combination_id
     and currency_code = p_currency_code
     and nvl(budget_revision_id, -1) = nvl(p_budget_revision_id, -1)
     and nvl(base_line_version, FND_API.G_MISS_CHAR) = nvl(p_base_line_version, FND_API.G_MISS_CHAR)
     and start_date = p_start_date
     and nvl(end_date, FND_API.G_MISS_DATE) = nvl(p_end_date, FND_API.G_MISS_DATE);

  /*For Bug No : 1808322 Start*/
    IF SQL%NOTFOUND THEN
      l_update_flag := FALSE;
    END IF;

  ELSE
      l_update_flag := FALSE;
  END IF;

  if not l_update_flag then --SQL%NOTFOUND then
  /*For Bug No : 1808322 End*/
  begin

    for l_init_index in 1..g_accounts.Count loop
      g_accounts(l_init_index).position_account_line_id := null;
      g_accounts(l_init_index).position_id := null;
      g_accounts(l_init_index).start_date := null;
      g_accounts(l_init_index).end_date := null;
      g_accounts(l_init_index).code_combination_id := null;
      g_accounts(l_init_index).budget_group_id := null;
      g_accounts(l_init_index).currency_code := null;
      g_accounts(l_init_index).amount := null;
      g_accounts(l_init_index).budget_revision_id := null;
      g_accounts(l_init_index).base_line_version := null;
      g_accounts(l_init_index).delete_flag := null;
    end loop;

    g_num_accounts := 0;


    -- for bug 4545590
    -- this performance improvement is only for budget upload and not
    -- for budget revisions. So we need to check if budget revision id is null
    IF NOT (g_wks_no_date_overlap AND p_budget_revision_id IS NULL) THEN

    for c_Overlap_Rec in c_Overlap loop
      g_num_accounts := g_num_accounts + 1;

      g_accounts(g_num_accounts).position_account_line_id := c_Overlap_Rec.position_account_line_id;
      g_accounts(g_num_accounts).position_id := c_Overlap_Rec.position_id;
      g_accounts(g_num_accounts).start_date := c_Overlap_Rec.start_date;
      g_accounts(g_num_accounts).end_date := c_Overlap_Rec.end_date;
      g_accounts(g_num_accounts).code_combination_id := c_Overlap_Rec.code_combination_id;
      g_accounts(g_num_accounts).budget_group_id := c_Overlap_Rec.budget_group_id;
      g_accounts(g_num_accounts).currency_code := c_Overlap_Rec.currency_code;
      g_accounts(g_num_accounts).amount := c_Overlap_Rec.amount;
      g_accounts(g_num_accounts).budget_revision_id := c_Overlap_Rec.budget_revision_id;
      g_accounts(g_num_accounts).base_line_version := c_Overlap_Rec.base_line_version;
      g_accounts(g_num_accounts).delete_flag := TRUE;
    end loop;

    END IF;


    if g_num_accounts = 0 then
    begin

      Insert_Position_Accounts
	   (p_return_status => l_return_status,
	    p_msg_count     => l_msg_count,
	    p_msg_data      => l_msg_data,
	    p_position_id => p_position_id,
	    p_hr_budget_id => p_hr_budget_id,
	    p_start_date => p_start_date,
	    p_end_date => p_end_date,
	    p_code_combination_id => p_code_combination_id,
	    p_budget_group_id => p_budget_group_id,
	    p_currency_code => p_currency_code,
	    p_amount => p_amount,
	    p_budget_revision_id => p_budget_revision_id,
	    p_base_line_version => p_base_line_version);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

    end;
    else
    begin

      for l_account_index in 1..g_num_accounts loop

	l_updated_record := FALSE;

	/* Effective Start Date Matches */

	if g_accounts(l_account_index).start_date = p_start_date then
	begin

	  Update_Position_Accounts
		(p_return_status => l_return_status,
	         p_msg_count     => l_msg_count,
	         p_msg_data      => l_msg_data,
		 p_position_account_line_id => g_accounts(l_account_index).position_account_line_id,
		 p_budget_group_id => p_budget_group_id,
		 p_end_date => p_end_date,
		 p_amount => p_amount);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  g_accounts(l_account_index).delete_flag := FALSE;

	end;

	/* Effective Dates Overlap */
	elsif (((g_accounts(l_account_index).start_date <= (p_start_date - 1)) and
	       ((g_accounts(l_account_index).end_date is null) or
		(g_accounts(l_account_index).end_date > (p_start_date - 1)))) or
	       ((g_accounts(l_account_index).start_date > p_start_date) and
	       ((g_accounts(l_account_index).end_date is null) or
		(g_accounts(l_account_index).end_date > (p_end_date + 1))))) then
	begin

	  if ((g_accounts(l_account_index).start_date < (p_start_date - 1)) and
	     ((g_accounts(l_account_index).end_date is null) or
	      (g_accounts(l_account_index).end_date > (p_start_date - 1)))) then
	  begin

	    Update_Position_Accounts
		  (p_return_status => l_return_status,
	           p_msg_count     => l_msg_count,
	           p_msg_data      => l_msg_data,
		   p_position_account_line_id => g_accounts(l_account_index).position_account_line_id,
		   p_budget_group_id => p_budget_group_id,
		   p_end_date => p_start_date - 1,
		   p_amount => Prorate (p_original_amount => g_accounts(l_account_index).amount,
					p_original_start_date => g_accounts(l_account_index).start_date,
					p_original_end_date => g_accounts(l_account_index).end_date,
					p_new_start_date => g_accounts(l_account_index).start_date,
					p_new_end_date => p_start_date - 1));

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    else
	      l_updated_record := TRUE;
	    end if;

	    g_accounts(l_account_index).delete_flag := FALSE;

	  end;
	  elsif ((g_accounts(l_account_index).start_date > p_start_date) and
		((p_end_date is not null) and
		((g_accounts(l_account_index).end_date is null) or
		 (g_accounts(l_account_index).end_date > (p_end_date + 1))))) then
	  begin

	    Update_Position_Accounts
		  (p_return_status => l_return_status,
	           p_msg_count     => l_msg_count,
	           p_msg_data      => l_msg_data,
		   p_position_account_line_id => g_accounts(l_account_index).position_account_line_id,
		   p_budget_group_id => p_budget_group_id,
		   p_start_date => p_end_date + 1,
		   p_amount => Prorate (p_original_amount => g_accounts(l_account_index).amount,
					p_original_start_date => g_accounts(l_account_index).start_date,
					p_original_end_date => g_accounts(l_account_index).end_date,
					p_new_start_date => p_end_date + 1,
					p_new_end_date => g_accounts(l_account_index).end_date));

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    else
	      l_updated_record := FALSE;
	    end if;

	    g_accounts(l_account_index).delete_flag := FALSE;

	  end;
	  end if;

	  if not l_created_record then
	  begin

	    Insert_Position_Accounts
		  (p_return_status => l_return_status,
	           p_msg_count     => l_msg_count,
	           p_msg_data      => l_msg_data,
		   p_position_id => p_position_id,
		   p_hr_budget_id => p_hr_budget_id,
		   p_start_date => p_start_date,
		   p_end_date => p_end_date,
		   p_code_combination_id => p_code_combination_id,
		   p_budget_group_id => p_budget_group_id,
		   p_currency_code => p_currency_code,
		   p_amount => p_amount,
		   p_budget_revision_id => p_budget_revision_id,
		   p_base_line_version => p_base_line_version);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    else
	      l_created_record := TRUE;
	    end if;

	  end;
	  end if;

	  if p_end_date is not null then
	  begin

	    if nvl(g_accounts(l_account_index).end_date, (p_end_date + 1)) > (p_end_date + 1) then
	    begin

	      if l_updated_record then
	      begin

		Insert_Position_Accounts
		      (p_return_status => l_return_status,
	               p_msg_count     => l_msg_count,
	               p_msg_data      => l_msg_data,
		       p_position_id => g_accounts(l_account_index).position_id,
		       p_hr_budget_id => p_hr_budget_id,
		       p_start_date => p_end_date + 1,
		       p_end_date => g_accounts(l_account_index).end_date,
		       p_code_combination_id => g_accounts(l_account_index).code_combination_id,
		       p_budget_group_id => g_accounts(l_account_index).budget_group_id,
		       p_currency_code => g_accounts(l_account_index).currency_code,
		       p_amount => Prorate (p_original_amount => g_accounts(l_account_index).amount,
					    p_original_start_date => g_accounts(l_account_index).start_date,
					    p_original_end_date => g_accounts(l_account_index).end_date,
					    p_new_start_date => p_end_date + 1,
					    p_new_end_date => g_accounts(l_account_index).end_date),
		       p_budget_revision_id => g_accounts(l_account_index).budget_revision_id,
		       p_base_line_version => g_accounts(l_account_index).base_line_version);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		end if;

	      end;
	      else
	      begin

		Update_Position_Accounts
		      (p_return_status => l_return_status,
	               p_msg_count     => l_msg_count,
	               p_msg_data      => l_msg_data,
		       p_position_account_line_id => g_accounts(l_account_index).position_account_line_id,
		       p_budget_group_id => p_budget_group_id,
		       p_start_date => p_end_date + 1,
		       p_end_date => g_accounts(l_account_index).end_date,
		       p_amount => Prorate (p_original_amount => g_accounts(l_account_index).amount,
					    p_original_start_date => g_accounts(l_account_index).start_date,
					    p_original_end_date => g_accounts(l_account_index).end_date,
					    p_new_start_date => p_end_date + 1,
					    p_new_end_date => g_accounts(l_account_index).end_date));

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		end if;

		g_accounts(l_account_index).delete_flag := FALSE;

	      end;
	      end if;

	    end;
	    end if;

	  end;
	  end if;

	end;
	end if;

      end loop;

    end;
    end if;

    for l_account_index in 1..g_num_accounts loop

      if g_accounts(l_account_index).delete_flag then
      begin

	Delete_Position_Accounts
	      (p_return_status => l_return_status,
	       p_msg_count     => l_msg_count,
	       p_msg_data      => l_msg_data,
	       p_position_account_line_id => g_accounts(l_account_index).position_account_line_id);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

    end loop;

  end;
  end if;

  -- Standard check of p_commit.
  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Modify_Position_Accounts;

/* ----------------------------------------------------------------------- */

PROCEDURE Insert_Position_Costs
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_msg_count            OUT  NOCOPY  NUMBER,
  p_msg_data             OUT  NOCOPY  VARCHAR2,
  p_position_id          IN   NUMBER,
  p_hr_budget_id         IN   NUMBER,
  p_pay_element_id       IN   NUMBER,
  p_budget_revision_id   IN   NUMBER,
  p_base_line_version    IN   VARCHAR2,
  p_start_date           IN   DATE,
  p_end_date             IN   DATE,
  p_currency_code        IN   VARCHAR2,
  p_element_cost         IN   NUMBER
) IS

  l_api_name               CONSTANT VARCHAR2(30)   := 'Insert_Position_Costs';
  l_position_element_line_id  NUMBER;

BEGIN

  insert into PSB_POSITION_COSTS
	(position_element_line_id, position_id, hr_budget_id, pay_element_id, budget_revision_id,
	 base_line_version, currency_code, start_date, end_date,
	 element_cost, last_update_date, last_updated_by, last_update_login, created_by, creation_date)
   values (PSB_POSITION_COSTS_S.NEXTVAL, p_position_id, p_hr_budget_id, p_pay_element_id, p_budget_revision_id,
	   p_base_line_version, p_currency_code, p_start_date, p_end_date,
	   p_element_cost, sysdate, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID, FND_GLOBAL.USER_ID, sysdate)
  RETURNING position_element_line_id INTO l_position_element_line_id;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Insert_Position_Costs;

/* ----------------------------------------------------------------------- */

PROCEDURE Update_Position_Costs
( p_return_status             OUT  NOCOPY  VARCHAR2,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
  p_position_element_line_id  IN   NUMBER,
  p_start_date                IN   DATE := FND_API.G_MISS_DATE,
  p_end_date                  IN   DATE := FND_API.G_MISS_DATE,
  p_element_cost              IN   NUMBER
) IS

  l_api_name               CONSTANT VARCHAR2(30)   := 'Update_Position_Costs';

BEGIN

  update PSB_POSITION_COSTS
     set element_cost = p_element_cost,
	 start_date = decode(p_start_date, FND_API.G_MISS_DATE, start_date, p_start_date),
	 end_date = decode(p_end_date, FND_API.G_MISS_DATE, end_date, p_end_date),
	 last_update_date = sysdate,
	 last_updated_by = FND_GLOBAL.USER_ID,
	 last_update_login = FND_GLOBAL.LOGIN_ID
   where position_element_line_id = p_position_element_line_id;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Update_Position_Costs;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_Position_Costs
( p_return_status             OUT  NOCOPY  VARCHAR2,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
  p_position_element_line_id  IN   NUMBER
) IS

 l_api_name               CONSTANT VARCHAR2(30)   := 'Delete_Position_Costs';

BEGIN

  delete from PSB_POSITION_COSTS
   where position_element_line_id = p_position_element_line_id;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Delete_Position_Costs;

/* ----------------------------------------------------------------------- */

PROCEDURE Modify_Position_Costs
( p_api_version          IN   NUMBER,
  p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status        OUT  NOCOPY  VARCHAR2,
  p_msg_count            OUT  NOCOPY  NUMBER,
  p_msg_data             OUT  NOCOPY  VARCHAR2,
  p_position_id          IN   NUMBER,
  p_hr_budget_id         IN   NUMBER,
  p_pay_element_id       IN   NUMBER,
  p_budget_revision_id   IN   NUMBER,
  p_base_line_version    IN   VARCHAR2,
  p_start_date           IN   DATE,
  p_end_date             IN   DATE,
  p_currency_code        IN   VARCHAR2,
  p_element_cost         IN   NUMBER
) IS

  l_api_name             CONSTANT VARCHAR2(30)   := 'Modify_Position_Costs';
  l_api_version          CONSTANT NUMBER         := 1.0;

  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);

  l_created_record       BOOLEAN := FALSE;
  l_updated_record       BOOLEAN;

  l_return_status        VARCHAR2(1);
  /*For Bug No : 1808322 Start*/
  l_update_flag           BOOLEAN := TRUE;
  /*For Bug No : 1808322 End*/

  cursor c_Overlap is
    select *
      from PSB_POSITION_COSTS
     where position_id = p_position_id
       and nvl(hr_budget_id, -1) = nvl(p_hr_budget_id, -1)
       and pay_element_id = p_pay_element_id
       and currency_code = p_currency_code
       and nvl(budget_revision_id, -1) = nvl(p_budget_revision_id, -1)
       and nvl(base_line_version, FND_API.G_MISS_CHAR) = nvl(p_base_line_version, FND_API.G_MISS_CHAR)
       and ((((p_end_date is not null)
	 and ((start_date <= p_end_date)
	  and (end_date is null))
	  or ((start_date between p_start_date and p_end_date)
	   or (end_date between p_start_date and p_end_date)
	  or ((start_date < p_start_date)
	  and (end_date > p_end_date)))))
	  or ((p_end_date is null)
	  and (nvl(end_date, p_start_date) >= p_start_date)));

BEGIN

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

  /*For Bug No : 1808322 Start*/
  IF p_budget_revision_id IS NOT null THEN
  /*For Bug No : 1808322 End*/
  update PSB_POSITION_COSTS
     set element_cost = p_element_cost,
	 last_update_date = sysdate,
	 last_updated_by = FND_GLOBAL.USER_ID,
	 last_update_login = FND_GLOBAL.LOGIN_ID
   where position_id = p_position_id
     and nvl(hr_budget_id, -1) = nvl(p_hr_budget_id, -1)
     and pay_element_id = p_pay_element_id
     and currency_code = p_currency_code
     and nvl(budget_revision_id, -1) = nvl(p_budget_revision_id, -1)
     and nvl(base_line_version, FND_API.G_MISS_CHAR) = nvl(p_base_line_version, FND_API.G_MISS_CHAR)
     and start_date = p_start_date
     and nvl(end_date, FND_API.G_MISS_DATE) = nvl(p_end_date, FND_API.G_MISS_DATE);

  /*For Bug No : 1808322 Start*/
    IF SQL%NOTFOUND THEN
      l_update_flag := FALSE;
    END IF;

  ELSE
      l_update_flag := FALSE;
  END IF;

  if not l_update_flag then --if SQL%NOTFOUND then
  /*For Bug No : 1808322 End*/
  begin

    for l_init_index in 1..g_costs.Count loop
      g_costs(l_init_index).position_element_line_id := null;
      g_costs(l_init_index).position_id := null;
      g_costs(l_init_index).pay_element_id := null;
      g_costs(l_init_index).start_date := null;
      g_costs(l_init_index).end_date := null;
      g_costs(l_init_index).currency_code := null;
      g_costs(l_init_index).element_cost := null;
      g_costs(l_init_index).budget_revision_id := null;
      g_costs(l_init_index).base_line_version := null;
      g_costs(l_init_index).delete_flag := null;
    end loop;

    g_num_costs := 0;

    -- for bug 4545590
    -- this performance improvement is only for budget upload and not
    -- for budget revisions. So we need to check if budget revision id is null
    IF NOT (g_wks_no_date_overlap AND p_budget_revision_id IS NULL) THEN

    for c_Overlap_Rec in c_Overlap loop
      g_num_costs := g_num_costs + 1;

      g_costs(g_num_costs).position_element_line_id := c_Overlap_Rec.position_element_line_id;
      g_costs(g_num_costs).position_id := c_Overlap_Rec.position_id;
      g_costs(g_num_costs).start_date := c_Overlap_Rec.start_date;
      g_costs(g_num_costs).end_date := c_Overlap_Rec.end_date;
      g_costs(g_num_costs).currency_code := c_Overlap_Rec.currency_code;
      g_costs(g_num_costs).element_cost := c_Overlap_Rec.element_cost;
      g_costs(g_num_costs).budget_revision_id := c_Overlap_Rec.budget_revision_id;
      g_costs(g_num_costs).base_line_version := c_Overlap_Rec.base_line_version;
      g_costs(g_num_costs).delete_flag := TRUE;
    end loop;

    END IF;


    if g_num_costs = 0 then
    begin

      Insert_Position_Costs
	   (p_return_status => l_return_status,
	    p_msg_count     => l_msg_count,
	    p_msg_data      => l_msg_data,
	    p_position_id => p_position_id,
	    p_hr_budget_id => p_hr_budget_id,
	    p_pay_element_id => p_pay_element_id,
	    p_start_date => p_start_date,
	    p_end_date => p_end_date,
	    p_currency_code => p_currency_code,
	    p_element_cost => p_element_cost,
	    p_budget_revision_id => p_budget_revision_id,
	    p_base_line_version => p_base_line_version);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

    end;
    else
    begin

      for l_cost_index in 1..g_num_costs loop

	l_updated_record := FALSE;

	/* Effective Start Date Matches */

	if g_costs(l_cost_index).start_date = p_start_date then
	begin

	  Update_Position_Costs
		(p_return_status => l_return_status,
	         p_msg_count     => l_msg_count,
	         p_msg_data      => l_msg_data,
		 p_position_element_line_id => g_costs(l_cost_index).position_element_line_id,
		 p_end_date => p_end_date,
		 p_element_cost => p_element_cost);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  g_costs(l_cost_index).delete_flag := FALSE;

	end;

	/* Effective Dates Overlap */
	elsif (((g_costs(l_cost_index).start_date <= (p_start_date - 1)) and
	       ((g_costs(l_cost_index).end_date is null) or
		(g_costs(l_cost_index).end_date > (p_start_date - 1)))) or
	       ((g_costs(l_cost_index).start_date > p_start_date) and
	       ((g_costs(l_cost_index).end_date is null) or
		(g_costs(l_cost_index).end_date > (p_end_date + 1))))) then
	begin

	  if ((g_costs(l_cost_index).start_date < (p_start_date - 1)) and
	     ((g_costs(l_cost_index).end_date is null) or
	      (g_costs(l_cost_index).end_date > (p_start_date - 1)))) then
	  begin

	    Update_Position_Costs
		  (p_return_status => l_return_status,
	           p_msg_count     => l_msg_count,
	           p_msg_data      => l_msg_data,
		   p_position_element_line_id => g_costs(l_cost_index).position_element_line_id,
		   p_end_date => p_start_date - 1,
		   p_element_cost => Prorate (p_original_amount => g_costs(l_cost_index).element_cost,
					      p_original_start_date => g_costs(l_cost_index).start_date,
					      p_original_end_date => g_costs(l_cost_index).end_date,
					      p_new_start_date => g_costs(l_cost_index).start_date,
					      p_new_end_date => p_start_date - 1));

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    else
	      l_updated_record := TRUE;
	    end if;

	    g_costs(l_cost_index).delete_flag := FALSE;

	  end;
	  elsif ((g_costs(l_cost_index).start_date > p_start_date) and
		((p_end_date is not null) and
		((g_costs(l_cost_index).end_date is null) or
		 (g_costs(l_cost_index).end_date > (p_end_date + 1))))) then
	  begin

	    Update_Position_Costs
		  (p_return_status => l_return_status,
	           p_msg_count     => l_msg_count,
	           p_msg_data      => l_msg_data,
		   p_position_element_line_id => g_costs(l_cost_index).position_element_line_id,
		   p_start_date => p_end_date + 1,
		   p_element_cost => Prorate (p_original_amount => g_costs(l_cost_index).element_cost,
					      p_original_start_date => g_costs(l_cost_index).start_date,
					      p_original_end_date => g_costs(l_cost_index).end_date,
					      p_new_start_date => p_end_date + 1,
					      p_new_end_date => g_costs(l_cost_index).end_date));

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    else
	      l_updated_record := FALSE;
	    end if;

	    g_costs(l_cost_index).delete_flag := FALSE;

	  end;
	  end if;

	  if not l_created_record then
	  begin

	    Insert_Position_Costs
		  (p_return_status => l_return_status,
	           p_msg_count     => l_msg_count,
	           p_msg_data      => l_msg_data,
		   p_position_id => p_position_id,
		   p_hr_budget_id => p_hr_budget_id,
		   p_pay_element_id => p_pay_element_id,
		   p_start_date => p_start_date,
		   p_end_date => p_end_date,
		   p_currency_code => p_currency_code,
		   p_element_cost => p_element_cost,
		   p_budget_revision_id => p_budget_revision_id,
		   p_base_line_version => p_base_line_version);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    else
	      l_created_record := TRUE;
	    end if;

	  end;
	  end if;

	  if p_end_date is not null then
	  begin

	    if nvl(g_costs(l_cost_index).end_date, (p_end_date + 1)) > (p_end_date + 1) then
	    begin

	      if l_updated_record then
	      begin

		Insert_Position_Costs
		      (p_return_status => l_return_status,
	               p_msg_count     => l_msg_count,
	               p_msg_data      => l_msg_data,
		       p_position_id => g_costs(l_cost_index).position_id,
		       p_hr_budget_id => p_hr_budget_id,
		       p_pay_element_id => g_costs(l_cost_index).pay_element_id,
		       p_start_date => p_end_date + 1,
		       p_end_date => g_costs(l_cost_index).end_date,
		       p_currency_code => g_costs(l_cost_index).currency_code,
		       p_element_cost => Prorate (p_original_amount => g_costs(l_cost_index).element_cost,
						  p_original_start_date => g_costs(l_cost_index).start_date,
						  p_original_end_date => g_costs(l_cost_index).end_date,
						  p_new_start_date => p_end_date + 1,
						  p_new_end_date => g_costs(l_cost_index).end_date),
		       p_budget_revision_id => g_costs(l_cost_index).budget_revision_id,
		       p_base_line_version => g_costs(l_cost_index).base_line_version);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		end if;

	      end;
	      else
	      begin

		Update_Position_Costs
		      (p_return_status => l_return_status,
	               p_msg_count     => l_msg_count,
	               p_msg_data      => l_msg_data,
		       p_position_element_line_id => g_costs(l_cost_index).position_element_line_id,
		       p_start_date => p_end_date + 1,
		       p_end_date => g_costs(l_cost_index).end_date,
		       p_element_cost => Prorate (p_original_amount => g_costs(l_cost_index).element_cost,
						  p_original_start_date => g_costs(l_cost_index).start_date,
						  p_original_end_date => g_costs(l_cost_index).end_date,
						  p_new_start_date => p_end_date + 1,
						  p_new_end_date => g_costs(l_cost_index).end_date));

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		end if;

		g_costs(l_cost_index).delete_flag := FALSE;

	      end;
	      end if;

	    end;
	    end if;

	  end;
	  end if;

	end;
	end if;

      end loop;

    end;
    end if;

    for l_cost_index in 1..g_num_costs loop

      if g_costs(l_cost_index).delete_flag then
      begin

	Delete_Position_Costs
	      (p_return_status => l_return_status,
	       p_msg_count     => l_msg_count,
	       p_msg_data      => l_msg_data,
	       p_position_element_line_id => g_costs(l_cost_index).position_element_line_id);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

    end loop;

  end;
  end if;

  -- Standard check of p_commit.
  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Modify_Position_Costs;

/* ----------------------------------------------------------------------- */

PROCEDURE Insert_Position_FTE
( p_return_status          OUT  NOCOPY  VARCHAR2,
  p_msg_count              OUT  NOCOPY  NUMBER,
  p_msg_data               OUT  NOCOPY  VARCHAR2,
  p_position_id            IN   NUMBER,
  p_hr_budget_id           IN   NUMBER,
  p_budget_revision_id     IN   NUMBER,
  p_base_line_version      IN   VARCHAR2,
  p_start_date             IN   DATE,
  p_end_date               IN   DATE,
  p_fte                    IN   NUMBER
) IS

  l_api_name               CONSTANT VARCHAR2(30)   := 'Insert_Position_FTE';

  l_position_fte_line_id   NUMBER;

BEGIN


  insert into PSB_POSITION_FTE
	(position_fte_line_id, position_id, hr_budget_id, budget_revision_id, base_line_version,
	 start_date, end_date, fte, last_update_date, last_updated_by, last_update_login,
	 created_by, creation_date)
   VALUES (PSB_POSITION_FTE_S.NEXTVAL, p_position_id, p_hr_budget_id, p_budget_revision_id, p_base_line_version,
	   p_start_date, p_end_date, nvl(p_fte, 0), sysdate, FND_GLOBAL.USER_ID, FND_GLOBAL.LOGIN_ID,
	   FND_GLOBAL.USER_ID, sysdate) RETURNING position_fte_line_id INTO l_position_fte_line_id;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Insert_Position_FTE;

/* ----------------------------------------------------------------------- */

PROCEDURE Update_Position_FTE
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_msg_count             OUT  NOCOPY  NUMBER,
  p_msg_data              OUT  NOCOPY  VARCHAR2,
  p_position_fte_line_id  IN   NUMBER,
  p_start_date            IN   DATE := FND_API.G_MISS_DATE,
  p_end_date              IN   DATE := FND_API.G_MISS_DATE,
  p_fte                   IN   NUMBER
) IS

  l_api_name               CONSTANT VARCHAR2(30)   := 'Update_Position_FTE';

BEGIN

  update PSB_POSITION_FTE
     set fte = nvl(p_fte, 0),
	 start_date = decode(p_start_date, FND_API.G_MISS_DATE, start_date, p_start_date),
	 end_date = decode(p_end_date, FND_API.G_MISS_DATE, end_date, p_end_date),
	 last_update_date = sysdate,
	 last_updated_by = FND_GLOBAL.USER_ID,
	 last_update_login = FND_GLOBAL.LOGIN_ID
    where position_fte_line_id = p_position_fte_line_id;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Update_Position_FTE;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_Position_FTE
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_msg_count             OUT  NOCOPY  NUMBER,
  p_msg_data              OUT  NOCOPY  VARCHAR2,
  p_position_fte_line_id  IN   NUMBER
) IS

  l_api_name               CONSTANT VARCHAR2(30)   := 'Delete_Position_FTE';

BEGIN

  delete from PSB_POSITION_FTE
   where position_fte_line_id = p_position_fte_line_id;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Delete_Position_FTE;

/* ----------------------------------------------------------------------- */

PROCEDURE Modify_Position_FTE
( p_api_version            IN   NUMBER,
  p_init_msg_list          IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status          OUT  NOCOPY  VARCHAR2,
  p_msg_count              OUT  NOCOPY  NUMBER,
  p_msg_data               OUT  NOCOPY  VARCHAR2,
  p_position_id            IN   NUMBER,
  p_hr_budget_id           IN   NUMBER,
  p_budget_revision_id     IN   NUMBER,
  p_base_line_version      IN   VARCHAR2,
  p_start_date             IN   DATE,
  p_end_date               IN   DATE,
  p_fte                    IN   NUMBER
) IS

  l_api_name               CONSTANT VARCHAR2(30)   := 'Modify_Position_FTE';
  l_api_version            CONSTANT NUMBER         := 1.0;

  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);

  l_created_record         BOOLEAN := FALSE;
  l_updated_record         BOOLEAN;
  /*For Bug No : 1808322 Start*/
  l_update_flag           BOOLEAN := TRUE;
  /*For Bug No : 1808322 End*/

  l_return_status          VARCHAR2(1);

  cursor c_Overlap is
    select *
      from PSB_POSITION_FTE
     where position_id = p_position_id
       and nvl(hr_budget_id, -1) = nvl(p_hr_budget_id, -1)
       and nvl(budget_revision_id, -1) = nvl(p_budget_revision_id, -1)
       and nvl(base_line_version, FND_API.G_MISS_CHAR) = nvl(p_base_line_version, FND_API.G_MISS_CHAR)
       and ((((p_end_date is not null)
	 and ((start_date <= p_end_date)
	  and (end_date is null))
	  or ((start_date between p_start_date and p_end_date)
	   or (end_date between p_start_date and p_end_date)
	  or ((start_date < p_start_date)
	  and (end_date > p_end_date)))))
	  or ((p_end_date is null)
	  and (nvl(end_date, p_start_date) >= p_start_date)));

BEGIN

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

  /*For Bug No : 1808322 Start*/
  IF p_budget_revision_id IS NOT null  THEN
  /*For Bug No : 1808322 End*/

  update PSB_POSITION_FTE
     set fte = nvl(p_fte, 0),
	 last_update_date = sysdate,
	 last_updated_by = FND_GLOBAL.USER_ID,
	 last_update_login = FND_GLOBAL.LOGIN_ID
   where position_id = p_position_id
     and nvl(hr_budget_id, -1) = nvl(p_hr_budget_id, -1)
     and nvl(budget_revision_id, -1) = nvl(p_budget_revision_id, -1)
     and nvl(base_line_version, FND_API.G_MISS_CHAR) = nvl(p_base_line_version, FND_API.G_MISS_CHAR)
     and start_date = p_start_date
     and nvl(end_date, FND_API.G_MISS_DATE) = nvl(p_end_date, FND_API.G_MISS_DATE);

  /*For Bug No : 1808322 Start*/
    IF SQL%NOTFOUND THEN
      l_update_flag := FALSE;
    END IF;

  ELSE
      l_update_flag := FALSE;
  END IF;

  if not l_update_flag then --if SQL%NOTFOUND then
  /*For Bug No : 1808322 End*/
  begin

    for l_init_index in 1..g_fte.Count loop
      g_fte(l_init_index).position_fte_line_id := null;
      g_fte(l_init_index).position_id := null;
      g_fte(l_init_index).start_date := null;
      g_fte(l_init_index).end_date := null;
      g_fte(l_init_index).fte := null;
      g_fte(l_init_index).budget_revision_id := null;
      g_fte(l_init_index).base_line_version := null;
      g_fte(l_init_index).delete_flag := null;
    end loop;

    g_num_fte := 0;

    -- for bug 4545590
    -- this performance improvement is only for budget upload and not
    -- for budget revisions. So we need to check if budget revision id is null
    IF NOT (g_wks_no_date_overlap AND p_budget_revision_id IS NULL) THEN

    for c_Overlap_Rec in c_Overlap loop
      g_num_fte := g_num_fte + 1;

      g_fte(g_num_fte).position_fte_line_id := c_Overlap_Rec.position_fte_line_id;
      g_fte(g_num_fte).position_id := c_Overlap_Rec.position_id;
      g_fte(g_num_fte).start_date := c_Overlap_Rec.start_date;
      g_fte(g_num_fte).end_date := c_Overlap_Rec.end_date;
      g_fte(g_num_fte).budget_revision_id := c_Overlap_Rec.budget_revision_id;
      g_fte(g_num_fte).base_line_version := c_Overlap_Rec.base_line_version;
      g_fte(g_num_fte).delete_flag := TRUE;
    end loop;

    END IF;

    if g_num_fte = 0 then
    begin

      Insert_Position_FTE
	   (p_return_status => l_return_status,
	    p_msg_count     => l_msg_count,
	    p_msg_data      => l_msg_data,
	    p_position_id   => p_position_id,
	    p_hr_budget_id  => p_hr_budget_id,
	    p_start_date    => p_start_date,
	    p_end_date      => p_end_date,
	    p_fte           => p_fte,
	    p_budget_revision_id => p_budget_revision_id,
	    p_base_line_version  => p_base_line_version);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

    end;
    else
    begin

      for l_fte_index in 1..g_num_fte loop

	l_updated_record := FALSE;

	/* Effective Start Date Matches */

	if g_fte(l_fte_index).start_date = p_start_date then
	begin

	  Update_Position_FTE
		(p_return_status => l_return_status,
	         p_msg_count     => l_msg_count,
	         p_msg_data      => l_msg_data,
		 p_position_fte_line_id => g_fte(l_fte_index).position_fte_line_id,
		 p_end_date => p_end_date,
		 p_fte => p_fte);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  g_fte(l_fte_index).delete_flag := FALSE;

	end;

	/* Effective Dates Overlap */
	elsif (((g_fte(l_fte_index).start_date <= (p_start_date - 1)) and
	       ((g_fte(l_fte_index).end_date is null) or
		(g_fte(l_fte_index).end_date > (p_start_date - 1)))) or
	       ((g_fte(l_fte_index).start_date > p_start_date) and
	       ((g_fte(l_fte_index).end_date is null) or
		(g_fte(l_fte_index).end_date > (p_end_date + 1))))) then
	begin

	  if ((g_fte(l_fte_index).start_date < (p_start_date - 1)) and
	     ((g_fte(l_fte_index).end_date is null) or
	      (g_fte(l_fte_index).end_date > (p_start_date - 1)))) then
	  begin

	    Update_Position_FTE
		  (p_return_status => l_return_status,
	           p_msg_count     => l_msg_count,
	           p_msg_data      => l_msg_data,
		   p_position_fte_line_id => g_fte(l_fte_index).position_fte_line_id,
		   p_end_date => p_start_date - 1,
		   p_fte => g_fte(l_fte_index).fte);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    else
	      l_updated_record := TRUE;
	    end if;

	    g_fte(l_fte_index).delete_flag := FALSE;

	  end;
	  elsif ((g_fte(l_fte_index).start_date > p_start_date) and
		((p_end_date is not null) and
		((g_fte(l_fte_index).end_date is null) or
		 (g_fte(l_fte_index).end_date > (p_end_date + 1))))) then
	  begin

	    Update_Position_FTE
		  (p_return_status => l_return_status,
	           p_msg_count     => l_msg_count,
	           p_msg_data      => l_msg_data,
		   p_position_fte_line_id => g_fte(l_fte_index).position_fte_line_id,
		   p_start_date => p_end_date + 1,
		   p_fte => g_fte(l_fte_index).fte);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    else
	      l_updated_record := FALSE;
	    end if;

	    g_fte(l_fte_index).delete_flag := FALSE;

	  end;
	  end if;

	  if not l_created_record then
	  begin

	    Insert_Position_FTE
		  (p_return_status => l_return_status,
	           p_msg_count     => l_msg_count,
	           p_msg_data      => l_msg_data,
		   p_position_id => p_position_id,
		   p_hr_budget_id => p_hr_budget_id,
		   p_start_date => p_start_date,
		   p_end_date => p_end_date,
		   p_fte => p_fte,
		   p_budget_revision_id => p_budget_revision_id,
		   p_base_line_version => p_base_line_version);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    else
	      l_created_record := TRUE;
	    end if;

	  end;
	  end if;

	  if p_end_date is not null then
	  begin

	    if nvl(g_fte(l_fte_index).end_date, (p_end_date + 1)) > (p_end_date + 1) then
	    begin

	      if l_updated_record then
	      begin

		Insert_Position_FTE
		      (p_return_status => l_return_status,
	               p_msg_count     => l_msg_count,
	               p_msg_data      => l_msg_data,
		       p_position_id => g_fte(l_fte_index).position_id,
		       p_hr_budget_id => p_hr_budget_id,
		       p_start_date => p_end_date + 1,
		       p_end_date => g_fte(l_fte_index).end_date,
		       p_fte => g_fte(l_fte_index).fte,
		       p_budget_revision_id => g_fte(l_fte_index).budget_revision_id,
		       p_base_line_version => g_fte(l_fte_index).base_line_version);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		end if;

	      end;
	      else
	      begin

		Update_Position_FTE
		      (p_return_status => l_return_status,
	               p_msg_count     => l_msg_count,
	               p_msg_data      => l_msg_data,
		       p_position_fte_line_id => g_fte(l_fte_index).position_fte_line_id,
		       p_start_date => p_end_date + 1,
		       p_end_date => g_fte(l_fte_index).end_date,
		       p_fte => g_fte(l_fte_index).fte);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		end if;

		g_fte(l_fte_index).delete_flag := FALSE;

	      end;
	      end if;

	    end;
	    end if;

	  end;
	  end if;

	end;
	end if;

      end loop;

    end;
    end if;

    for l_fte_index in 1..g_num_fte loop

      if g_fte(l_fte_index).delete_flag then
      begin

	Delete_Position_FTE
	      (p_return_status => l_return_status,
	       p_msg_count     => l_msg_count,
	       p_msg_data      => l_msg_data,
	       p_position_fte_line_id => g_fte(l_fte_index).position_fte_line_id);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

    end loop;

  end;
  end if;

  -- Standard check of p_commit.
  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Modify_Position_FTE;

/* ----------------------------------------------------------------------- */

-- Check that every PSB budget group is mapped to an HR organization

PROCEDURE Validate_Budget_Group
( p_return_status    OUT  NOCOPY  VARCHAR2,
  p_msg_count        OUT  NOCOPY  NUMBER,
  p_msg_data         OUT  NOCOPY  VARCHAR2,
  p_event_type       IN   VARCHAR2,
  p_source_id        IN   NUMBER,
  p_budget_group_id  IN   NUMBER) IS

  -- Select all Budget Groups in the Budget Group Hierarchy; 'connect by' does a
  -- depth-first search

  cursor c_BG is
    select short_name, nvl(organization_id, business_group_id) organization_id,
	   effective_start_date, effective_end_date
      from PSB_BUDGET_GROUPS
     where budget_group_type = 'R'
     start with budget_group_id = p_budget_group_id
   connect by prior budget_group_id = parent_budget_group_id;

  l_org_notmapped    BOOLEAN := FALSE;

  l_api_name               CONSTANT VARCHAR2(30)   := 'Validate_Budget_Group';

BEGIN

  for c_BG_Rec in c_BG loop

    if ((p_event_type = 'BR') or
       ((p_event_type = 'BP') and ((c_BG_Rec.effective_start_date <= PSB_WS_ACCT1.g_startdate_pp)
			       and (c_BG_Rec.effective_end_date is null or c_BG_Rec.effective_end_date >= PSB_WS_ACCT1.g_enddate_cy)))) then
      if c_BG_Rec.organization_id is null then
	message_token('BUDGET_GROUP', c_BG_Rec.short_name);
	add_message('PSB', 'PSB_PQH_NO_ORG_MAPPING');
	l_org_notmapped := TRUE;
      end if;

    end if;

  end loop;

  if l_org_notmapped then
     FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
     FND_MESSAGE.SET_TOKEN('MESSAGE', ' Org Mapping Failed');
     FND_MSG_PUB.Add;
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Validate_Budget_Group;

/* ----------------------------------------------------------------------- */

-- check that HRMS budget periods are more granular than PSB budget periods

PROCEDURE Validate_Period_Granularity
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_msg_count            OUT  NOCOPY  NUMBER,
  p_msg_data             OUT  NOCOPY  VARCHAR2,
  p_hr_budget_id         IN   NUMBER,
  p_from_budget_year_id  IN   NUMBER,
  p_to_budget_year_id    IN   NUMBER) IS

  l_hrms_period_type          VARCHAR2(30);
  l_hrms_period               VARCHAR2(30);
  l_psb_period_type           VARCHAR2(10);
  /*For Bug No : 2556899 Start*/
  --Changed the folloiwng field size from 30 to 80
  l_psb_period                VARCHAR2(80);
  /*For Bug No : 2556899 End*/
  l_period_type_mismatch      BOOLEAN := FALSE;

  cursor c_hrms_period_type is
    select pc.proc_period_type
      from pqh_psb_budgets pb, pay_calendars pc
     where pb.budget_id = p_hr_budget_id
       and pc.period_set_name = pb.period_set_name;

  cursor c_psb_period_type is
    select min(period_distribution_type) psb_period_type
      from psb_budget_periods
     where budget_period_id between p_from_budget_year_id and p_to_budget_year_id
       and budget_period_type = 'Y';

  cursor c_psb_period is
    select meaning from fnd_lookups
     where lookup_type = 'PSB_PERIOD_DISTRIBUTION_TYPES'
       and lookup_code = l_psb_period_type;

  cursor c_hrms_period is
    select tpt.display_period_type
      from per_time_period_types tpt, per_time_period_rules tpr
     where tpr.number_per_fiscal_year = tpt.number_per_fiscal_year
       and tpr.proc_period_type = l_hrms_period_type;

  l_api_name               CONSTANT VARCHAR2(30)   := 'Validate_Period_Granularity';

BEGIN

  for c_hrms_period_type_rec in c_hrms_period_type loop
    l_hrms_period_type := c_hrms_period_type_rec.proc_period_type;
  end loop;

  for c_psb_period_type_rec in c_psb_period_type loop
    l_psb_period_type := c_psb_period_type_rec.psb_period_type;
  end loop;

  if l_psb_period_type = 'M' then
    if l_hrms_period_type not in ('F', 'CM', 'LM', 'SM', 'W') then
      l_period_type_mismatch := TRUE;
    end if;
  elsif l_psb_period_type = 'Q' then
    if l_hrms_period_type not in ('BM', 'F', 'CM', 'LM', 'Q', 'SM', 'W') then
      l_period_type_mismatch := TRUE;
    end if;
  elsif l_psb_period_type = 'S' then
    if l_hrms_period_type not in ('BM', 'F', 'CM', 'LM', 'Q', 'SM', 'SY', 'W') then
      l_period_type_mismatch := TRUE;
    end if;
  elsif l_psb_period_type = 'Y' then
    if l_hrms_period_type not in ('BM', 'F', 'CM', 'LM', 'Q', 'SM', 'SY', 'W', 'Y') then
      l_period_type_mismatch := TRUE;
    end if;
  end if;

  if l_period_type_mismatch then
  begin

    for c_hrms_period_rec in c_hrms_period loop
      l_hrms_period := c_hrms_period_rec.display_period_type;
    end loop;

    for c_psb_period_rec in c_psb_period loop
      l_psb_period := c_psb_period_rec.meaning;
    end loop;

    message_token('PSB_PERIOD_TYPE', l_psb_period);
    message_token('HRMS_PERIOD_TYPE', l_hrms_period);
    add_message('PSB', 'PSB_PQH_PERIOD_TYPE_MISMATCH');
    raise FND_API.G_EXC_ERROR;

  end;
  end if;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Validate_Period_Granularity;

/* ----------------------------------------------------------------------- */

-- Check if element exists in Worksheet or Budget Revision

FUNCTION Element_Exists
( p_event_type       VARCHAR2,
  p_source_id        NUMBER,
  p_data_extract_id  NUMBER,
  p_element_id       NUMBER) RETURN BOOLEAN IS

  l_element_id       NUMBER;
  l_element_exists   BOOLEAN := FALSE;

  cursor c_re_element is
    select b.pay_element_id
      from PSB_PAY_ELEMENTS a,
	   PSB_PAY_ELEMENTS b
     where a.pay_element_id = p_element_id
       and b.data_extract_id = p_data_extract_id
       and b.name = a.name;

  cursor c_element_exists_bp is
    select 'Exists'
      from dual
     where exists
	  (select 'Exists'
	     from psb_ws_lines_positions wlp, psb_ws_position_lines wpl, psb_position_assignments ppa
	    where wlp.worksheet_id = p_source_id
	      and wpl.position_line_id = wlp.position_line_id
	      and ppa.position_id = wpl.position_id
	      and ppa.pay_element_id = l_element_id
	   /* For Bug No. 2599262 : Start */
	      and (ppa.worksheet_id = p_source_id OR ppa.worksheet_id IS NULL)
	   /* For Bug No. 2599262 : End */
	   );

  cursor c_element_exists_br is
    select 'Exists'
      from dual
     where exists
	  (select 'Exists'
	     from psb_budget_revision_pos_lines brpl, psb_budget_revision_positions brp, psb_position_assignments ppa
	    where brpl.budget_revision_id = p_source_id
	      and brp.budget_revision_pos_line_id = brpl.budget_revision_pos_line_id
	      and ppa.position_id = brp.position_id
	      and ppa.pay_element_id = p_element_id
	   /* For Bug No. 2599262 : Start */
	      and (ppa.worksheet_id = p_source_id OR ppa.worksheet_id IS NULL)
	   /* For Bug No. 2599262 : End */
	   );

BEGIN

  if p_event_type = 'BP' then
  begin

    for c_re_element_rec in c_re_element loop
      l_element_id := c_re_element_rec.pay_element_id;
    end loop;

    for c_element_rec in c_element_exists_bp loop
      l_element_exists := TRUE;
    end loop;

  end;
  elsif p_event_type = 'BR' then
  begin

    for c_element_rec in c_element_exists_br loop
      l_element_exists := TRUE;
    end loop;

  end;
  end if;

  return l_element_exists;

END Element_Exists;

/* ----------------------------------------------------------------------- */

-- Get payroll_id for HRMS position

FUNCTION Get_Payroll
( p_hr_position_id        NUMBER,
  p_data_extract_id       NUMBER,
  p_effective_start_date  DATE,
  p_effective_end_date    DATE) RETURN NUMBER IS

  l_payroll_id            NUMBER;

  cursor c_position_payroll is
    select pay_freq_payroll_id
      from hr_all_positions_f
     where position_id = p_hr_position_id
       /*For Bug No : 2292003 Start*/
       --and p_effective_start_date between effective_start_date and effective_end_date
       and ((p_effective_start_date between effective_start_date and effective_end_date) OR
	    (p_effective_end_date between effective_start_date and effective_end_date)
	   );
       /*For Bug No : 2292003 End*/

  cursor c_assign_payroll is
    select payroll_id
      from per_all_assignments_f
     where position_id = p_hr_position_id
       and person_id in
	  (select hr_employee_id from PSB_POSITIONS
	    where hr_position_id = p_hr_position_id
	      and data_extract_id = p_data_extract_id)
       /*For Bug No : 2292003 Start*/
       --and p_effective_start_date between effective_start_date and effective_end_date
       and ((p_effective_start_date between effective_start_date and effective_end_date) OR
	    (p_effective_end_date between effective_start_date and effective_end_date)
	   )
       /*For Bug No : 2292003 End*/
       and assignment_type = 'E';

BEGIN

  for c_payroll_rec in c_position_payroll loop
    l_payroll_id := c_payroll_rec.pay_freq_payroll_id;
  end loop;

  if l_payroll_id is null then
  begin

    for c_payroll_rec in c_assign_payroll loop
      l_payroll_id := c_payroll_rec.payroll_id;
    end loop;

  end;
  end if;

  return l_payroll_id;

END Get_Payroll;

/* ----------------------------------------------------------------------- */

PROCEDURE Validate_Budget_Document
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_msg_count               OUT  NOCOPY  NUMBER,
  p_msg_data                OUT  NOCOPY  VARCHAR2,
  p_validation_level        IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_event_type              IN   VARCHAR2,
  p_source_id               IN   NUMBER,
  p_data_extract_id         IN   NUMBER,
  p_system_data_extract_id  IN   NUMBER) IS

  /*For Bug No : 2292003 Start*/
  --l_payroll_id              NUMBER;
  --l_no_payroll_count        NUMBER := 0;
  /*For Bug No : 2292003 End*/
  l_no_hr_pos_count         NUMBER := 0;

  cursor c_bpposition is
    select position_id, name, hr_position_id, hr_employee_id, effective_start_date
      from psb_positions
     where data_extract_id = p_data_extract_id;

  cursor c_brposition is
    select position_id, name, hr_position_id, hr_employee_id, effective_start_date
      from psb_positions
     where data_extract_id = p_system_data_extract_id;

/* Fix for Bug #2642767 Start */
  cursor c_no_hr_position (positionid NUMBER) is
    select name, transaction_id
      from psb_positions
     where position_id = positionid
       and hr_position_id is null;
/* Fix for Bug #2642767 End*/

  l_api_name               CONSTANT VARCHAR2(30)   := 'Validate_Budget_Document';

BEGIN

  -- find payroll for the position

  if p_event_type = 'BP' then
  begin

  for c_position_rec in c_bpposition loop

    -- check if position exists in worksheet or budget revision

    if (Position_Exists(p_event_type => p_event_type, p_source_id => p_source_id,
	p_position_id => c_position_rec.position_id)) then
    begin

      /*For Bug No : 2292003 Start*/
      /*if p_validation_level = FND_API.G_VALID_LEVEL_NONE then
	 --changed the c_position_rec.effective_start_date to g_de_as_of_date
	 --in the following call of the procedure
	 l_payroll_id := Get_Payroll(p_hr_position_id => c_position_rec.hr_position_id,
				  p_data_extract_id => p_data_extract_id
				  p_effective_start_date => g_de_as_of_date);

	 if l_payroll_id is null then
	   message_token('POSITION', c_position_rec.name);
	   add_message('PSB', 'PSB_PQH_POSITION_NO_PAYROLL');
	   l_no_payroll_count := l_no_payroll_count + 1;
	 end if;
      end if;*/
      /*For Bug No : 2292003 End*/

      -- check that all positions are mapped to HR positions
      if p_validation_level = FND_API.G_VALID_LEVEL_FULL then
	 for c_no_hr_position_rec in c_no_hr_position (c_position_rec.position_id) loop
/* Fix for Bug #2642767 Start */
          if c_no_hr_position_rec.transaction_id is null then
              message_token('POSITION',c_no_hr_position_rec.name);
              add_message('PSB', 'PSB_PQH_NO_HR_POSITION');
          else
              message_token('POSITION',c_no_hr_position_rec.name);
              add_message('PSB', 'PSB_PQH_NO_HR_POSITION_TRX');
          end if;
/* Fix for Bug #2642767 End*/
	   l_no_hr_pos_count := l_no_hr_pos_count + 1;
	 end loop;
      end if;

    end;
    end if;

  end loop;

  end;
  elsif p_event_type = 'BR' then
  begin

  for c_position_rec in c_brposition loop

    -- check if position exists in worksheet or budget revision

    if (Position_Exists(p_event_type => p_event_type, p_source_id => p_source_id,
	p_position_id => c_position_rec.position_id)) then
    begin

      /*For Bug No : 2292003 Start*/
      /*if p_validation_level = FND_API.G_VALID_LEVEL_NONE then
	 --changed the c_position_rec.effective_start_date to g_de_as_of_date
	 --in the following call of the procedure
	 l_payroll_id := Get_Payroll(p_hr_position_id => c_position_rec.hr_position_id,
				  p_data_extract_id => p_system_data_extract_id,
				  p_effective_start_date => g_de_as_of_date);

	 if l_payroll_id is null then
	   message_token('POSITION', c_position_rec.name);
	   add_message('PSB', 'PSB_PQH_POSITION_NO_PAYROLL');
	   l_no_payroll_count := l_no_payroll_count + 1;
	 end if;
      end if;*/
      /*For Bug No : 2292003 End*/

      -- check that all positions are mapped to HR positions
      if p_validation_level = FND_API.G_VALID_LEVEL_FULL then
	 for c_no_hr_position_rec in c_no_hr_position (c_position_rec.position_id) loop
/* Fix for Bug #2642767 Start */
          if c_no_hr_position_rec.transaction_id is null then
              message_token('POSITION',c_no_hr_position_rec.name);
              add_message('PSB', 'PSB_PQH_NO_HR_POSITION');
          else
              message_token('POSITION',c_no_hr_position_rec.name);
              add_message('PSB', 'PSB_PQH_NO_HR_POSITION_TRX');
          end if;
/* Fix for Bug #2642767 End*/
	   l_no_hr_pos_count := l_no_hr_pos_count + 1;
	 end loop;
      end if;

    end;
    end if;

  end loop;

  end;
  end if;

  if (l_no_hr_pos_count > 0) then
    FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE', 'No HR Pos Count');
    FND_MSG_PUB.Add;
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Validate_Budget_Document;

/* ----------------------------------------------------------------------- */

PROCEDURE Validate_Budget_Set
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_msg_count               OUT  NOCOPY  NUMBER,
  p_msg_data                OUT  NOCOPY  VARCHAR2,
  p_event_type              IN   VARCHAR2,
  p_source_id               IN   NUMBER,
  p_data_extract_id         IN   NUMBER,
  p_system_data_extract_id  IN   NUMBER) IS

  l_no_elem_count           NUMBER := 0;

  cursor c_no_element_map is
    select pay_element_id, name
      from psb_pay_elements
     where data_extract_id = p_system_data_extract_id
       and budget_set_id is null;

  l_api_name               CONSTANT VARCHAR2(30)   := 'Validate_Budget_Set';

BEGIN

  for c_no_element_map_rec in c_no_element_map loop

    if (Element_Exists(p_event_type => p_event_type, p_source_id => p_source_id, p_data_extract_id => p_data_extract_id, p_element_id => c_no_element_map_rec.pay_element_id)) then
      message_token('ELEMENT', c_no_element_map_rec.name);
      add_message('PSB', 'PSB_PQH_NO_ELEMENT_MAPPING');
      l_no_elem_count := l_no_elem_count + 1;
    end if;

  end loop;

  if l_no_elem_count > 0 then
    FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
    FND_MESSAGE.SET_TOKEN('MESSAGE', 'No Element Count');
    FND_MSG_PUB.Add;
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Validate_Budget_Set;

/* ----------------------------------------------------------------------- */

PROCEDURE Cache_Position_Costs
(p_return_status      OUT  NOCOPY VARCHAR2,
 p_event_type         IN  VARCHAR2,
 p_hr_budget_id       IN  NUMBER,
 p_hr_position_id     IN  NUMBER,
 p_source_id          IN  NUMBER,
 p_data_extract_id    IN  NUMBER,
 p_start_date         IN  DATE,
 p_end_date           IN  DATE,
 p_currency_code      IN  VARCHAR2) IS

  TYPE id_arr IS TABLE OF NUMBER(15);
  TYPE num_arr IS TABLE OF NUMBER;
  TYPE date_arr IS TABLE OF DATE;

  TYPE elem_costs IS RECORD (pay_element_id id_arr, budget_set_id id_arr, element_cost num_arr);
  l_element_costs     elem_costs;

  cursor c_Element_Costs is
    select ppe.pay_element_id, ppe.budget_set_id, sum(nvl(ppc.element_cost,0)) element_cost
      from psb_pay_elements ppe,
	   psb_position_costs ppc,
	   psb_positions pp
     where ppe.data_extract_id = p_data_extract_id
       and ppc.pay_element_id = ppe.pay_element_id
       and pp.data_extract_id = p_data_extract_id
       and pp.hr_position_id = p_hr_position_id
       and ppc.position_id = pp.position_id
       and nvl(ppc.hr_budget_id, -1) = nvl(p_hr_budget_id, -1)
       and ((p_event_type = 'BP' and ppc.base_line_version = 'C')
	   or (p_event_type = 'BR' and ppc.budget_revision_id = p_source_id))
       and ppc.currency_code = p_currency_code
       and ((ppc.start_date <= p_end_date) and (ppc.end_date >= p_start_date)) --bug:7037138:modified
    group by ppe.budget_set_id, ppe.pay_element_id;

BEGIN

  for l_init_index in 1..g_element_costs.Count loop
    g_element_costs(l_init_index).budget_set_id := null;
    g_element_costs(l_init_index).pay_element_id := null;
    g_element_costs(l_init_index).element_cost := null;
  end loop;

  g_num_element_costs := 0;

  open c_Element_Costs;
  loop

    fetch c_Element_Costs BULK COLLECT INTO l_element_costs.pay_element_id, l_element_costs.budget_set_id, l_element_costs.element_cost LIMIT g_limit_bulk_numrows;

    for l_cost_index in 1..l_element_costs.pay_element_id.count loop
      g_num_element_costs := g_num_element_costs + 1;
      g_element_costs(g_num_element_costs).budget_set_id := l_element_costs.budget_set_id(l_cost_index);
      g_element_costs(g_num_element_costs).pay_element_id := l_element_costs.pay_element_id(l_cost_index);
      g_element_costs(g_num_element_costs).element_cost := l_element_costs.element_cost(l_cost_index);
    end loop;
    exit when c_Element_Costs%NOTFOUND;

  end loop;
  close c_Element_Costs;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     if c_Element_Costs%ISOPEN then
       close c_Element_Costs;
     end if;
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     if c_Element_Costs%ISOPEN then
       close c_Element_Costs;
     end if;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     if c_Element_Costs%ISOPEN then
       close c_Element_Costs;
     end if;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

End Cache_Position_Costs;

/* ----------------------------------------------------------------------- */

PROCEDURE Distribute_Salary
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_source_id             IN   VARCHAR2,
  p_gl_flex_code          IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_hr_position_id        IN   NUMBER,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE
) IS

  TYPE id_arr IS TABLE OF NUMBER(15);
  TYPE num_arr IS TABLE OF NUMBER;

  TYPE dist_rec IS RECORD
      (pay_element_id id_arr, code_combination_id id_arr, distribution_percent num_arr);
  l_dist                  dist_rec;

  cursor c_Dist is
    select distinct c.pay_element_id, b.code_combination_id,
	   b.distribution_percent
      from PSB_PAY_ELEMENTS c, PSB_POSITION_PAY_DISTRIBUTIONS b
     where c.data_extract_id = p_data_extract_id
       and c.salary_flag = 'Y'
       and b.position_id in
	  (select a.position_id from PSB_POSITIONS a
	    where a.hr_position_id = p_hr_position_id
	      and a.data_extract_id = p_data_extract_id)
       and exists
	  (select 1 from PSB_POSITION_ASSIGNMENTS d
	    where d.position_id = b.position_id and d.pay_element_id = c.pay_element_id)
       and ((b.worksheet_id = p_source_id)
	 or (b.worksheet_id is null
       and not exists
	  (select 1 from PSB_POSITION_PAY_DISTRIBUTIONS c
	    where c.position_id = b.position_id
	      and c.worksheet_id = p_source_id)))
       and b.chart_of_accounts_id = p_gl_flex_code
       and b.code_combination_id is not null
       and (((p_end_date is not null)
	 and (((b.effective_start_date <= p_end_date)
	   and (b.effective_end_date is null))
	   or ((b.effective_start_date between p_start_date and p_end_date)
	   or (b.effective_end_date between p_start_date and p_end_date)
	   or ((b.effective_start_date < p_start_date)
	   and (b.effective_end_date > p_end_date)))))
	or ((p_end_date is null)
	and (nvl(b.effective_end_date, p_start_date) >= p_start_date)))
     order by b.distribution_percent desc;

  l_percent               NUMBER;

  l_return_status         VARCHAR2(1);

BEGIN

  PSB_WS_POS1.g_salary_budget_group_id := null;
  PSB_WS_POS1.Initialize_Salary_Dist;

  open c_Dist;
  loop

    fetch c_Dist BULK COLLECT into
      l_dist.pay_element_id, l_dist.code_combination_id, l_dist.distribution_percent LIMIT g_limit_bulk_numrows;

    for l_index in 1..l_dist.pay_element_id.count loop

      PSB_WS_POS1.g_num_salary_dist := PSB_WS_POS1.g_num_salary_dist + 1;

      PSB_WS_POS1.g_salary_dist(PSB_WS_POS1.g_num_salary_dist).ccid := l_dist.code_combination_id(l_index);
      PSB_WS_POS1.g_salary_dist(PSB_WS_POS1.g_num_salary_dist).percent := l_dist.distribution_percent(l_index);

      -- commented for bug # 4502946
      /*if l_dist.distribution_percent(l_index) < 1 then
	l_percent := l_dist.distribution_percent(l_index);
      else
	l_percent := l_dist.distribution_percent(l_index) / 100;
      end if;*/

      -- added for bug # 4502946
      l_percent := l_dist.distribution_percent(l_index) / 100;

      g_num_element_dists := g_num_element_dists + 1;

      g_element_dists(g_num_element_dists).pay_element_id := l_dist.pay_element_id(l_index);
      g_element_dists(g_num_element_dists).ccid := l_dist.code_combination_id(l_index);
      g_element_dists(g_num_element_dists).percent := l_percent;

    end loop;
    exit when c_Dist%NOTFOUND;

  end loop;
  close c_Dist;

  if p_gl_flex_code <> nvl(PSB_WS_ACCT1.g_flex_code, FND_API.G_MISS_NUM) then
  begin

    PSB_WS_ACCT1.Flex_Info
       (p_flex_code => p_gl_flex_code,
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
     if c_Dist%ISOPEN then
       close c_Dist;
     end if;
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     if c_Dist%ISOPEN then
       close c_Dist;
     end if;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     if c_Dist%ISOPEN then
       close c_Dist;
     end if;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Distribute_Salary;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                          PROCEDURE Distribute_Other_Elements              |
 +===========================================================================*/
PROCEDURE Distribute_Other_Elements
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_gl_flex_code          IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_hr_position_id        IN   NUMBER,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE
)
IS
  --
  l_ccid_val              FND_FLEX_EXT.SegmentArray;
  l_seg_val               FND_FLEX_EXT.SegmentArray;
  l_ccid                  NUMBER;
  l_start_date            DATE;
  l_end_date              DATE;
  l_dist_start_date       DATE;
  l_dist_end_date         DATE;
  l_amount                NUMBER;
  l_percent               NUMBER;

  /*bug:7037138:start*/
  l_bulk_fetch_req        BOOLEAN := FALSE;
  l_start_index           NUMBER;
  l_end_index             NUMBER;
  /*bug:7037138:end*/

  /* start bug 3666828 */
  l_hr_position_id 		  NUMBER;
  l_element_name 		  VARCHAR2(80);
  /* end bug 3666828 */

  --

  /*bug:7037138:Moved the table psb_positions to main query instead of sub query
    to facilitate fetching hr_position_id. */

  cursor c_Dist is
    select distinct a.segment1, a.segment2, a.segment3, a.segment4,
	   a.segment5, a.segment6, a.segment7, a.segment8,
	   a.segment9, a.segment10, a.segment11, a.segment12,
	   a.segment13, a.segment14, a.segment15, a.segment16,
	   a.segment17, a.segment18, a.segment19, a.segment20,
	   a.segment21, a.segment22, a.segment23, a.segment24,
	   a.segment25, a.segment26, a.segment27, a.segment28,
	   a.segment29, a.segment30,
	   a.code_combination_id, a.distribution_percent, e.pay_element_id,
           e.follow_salary, /* bug No: 3666828 */ e.name,
           pp.hr_position_id
      from PSB_PAY_ELEMENTS e, PSB_PAY_ELEMENT_DISTRIBUTIONS a,
	   PSB_ELEMENT_POS_SET_GROUPS b,
	   PSB_SET_RELATIONS c,
	   PSB_BUDGET_POSITIONS d,
	   PSB_POSITIONS pp
     where e.data_extract_id = p_data_extract_id
       and e.salary_flag <> 'Y'
       and a.chart_of_accounts_id = p_gl_flex_code
       and (((a.effective_start_date <= p_end_date)
	 and (a.effective_end_date is null))
	 or ((a.effective_start_date between p_start_date and p_end_date)
	  or (a.effective_end_date between p_start_date and p_end_date)
	 or ((a.effective_start_date < p_start_date)
	 and (a.effective_end_date > p_end_date))))
       and a.position_set_group_id = b.position_set_group_id
       and b.position_set_group_id = c.position_set_group_id
       and b.pay_element_id = e.pay_element_id
       and c.account_position_set_id = d.account_position_set_id
       and exists
	  (select 1 from PSB_POSITION_ASSIGNMENTS g
	    where g.position_id = d.position_id
            and g.pay_element_id = e.pay_element_id)
       and pp.position_id = d.position_id
       and pp.data_extract_id = p_data_extract_id
       order by pp.hr_position_id;

  --
BEGIN

 /*bug:7037138:start*/
  if (g_data_extract_id IS NULL OR
     g_start_date IS NULL OR
     g_gl_flex_code IS NULL) then

    g_data_extract_id := p_data_extract_id;
    g_start_date := p_start_date;
    g_end_date   := p_end_date;
    g_gl_flex_code := p_gl_flex_code;
    l_bulk_fetch_req := TRUE;
  elsif (g_data_extract_id <> p_data_extract_id OR
         g_start_date <> p_start_date OR
         g_end_date <> p_end_date OR
         g_gl_flex_code <> p_gl_flex_code) then

    g_data_extract_id := p_data_extract_id;
    g_start_date := p_start_date;
    g_end_date   := p_end_date;
    g_gl_flex_code := p_gl_flex_code;
    l_bulk_fetch_req := TRUE;
  end if;

  IF l_bulk_fetch_req THEN
     g_segment1.delete; g_segment2.delete; g_segment3.delete;
     g_segment4.delete; g_segment5.delete; g_segment6.delete;
     g_segment7.delete; g_segment8.delete; g_segment9.delete;
     g_segment10.delete; g_segment11.delete; g_segment12.delete;
     g_segment13.delete; g_segment14.delete; g_segment15.delete;
     g_segment16.delete; g_segment17.delete; g_segment18.delete;
     g_segment19.delete; g_segment20.delete; g_segment21.delete;
     g_segment22.delete; g_segment23.delete; g_segment24.delete;
     g_segment25.delete; g_segment26.delete; g_segment27.delete;
     g_segment28.delete; g_segment29.delete; g_segment30.delete;
     g_ccid.delete;
     g_dist_percent.delete;
     g_pay_element_id.delete;
     g_follow_salary.delete;
     g_pay_element_name.delete;
     g_hr_position_id.delete;

  open c_Dist;

  fetch c_Dist BULK COLLECT INTO
          g_segment1, g_segment2, g_segment3,
          g_segment4, g_segment5, g_segment6,
          g_segment7, g_segment8, g_segment9,
          g_segment10, g_segment11, g_segment12,
          g_segment13, g_segment14, g_segment15,
          g_segment16, g_segment17, g_segment18,
          g_segment19, g_segment20, g_segment21,
          g_segment22, g_segment23, g_segment24,
          g_segment25, g_segment26, g_segment27,
          g_segment28, g_segment29, g_segment30,
          g_ccid, g_dist_percent, g_pay_element_id,
          g_follow_salary, g_pay_element_name, g_hr_position_id;

  if c_Dist%NOTFOUND then
     close c_Dist;
  end if;

  IF c_Dist%ISOPEN THEN
     CLOSE c_Dist;
  END IF;

   if g_hr_position_id.count > 0 then
       for l_index in 1..g_hr_position_id.count loop
           g_hr_pos_details_tab(g_hr_position_id(l_index)).hr_position_id := g_hr_position_id(l_index);

           IF g_hr_pos_details_tab(g_hr_position_id(l_index)).start_index IS NULL THEN
              g_hr_pos_details_tab(g_hr_position_id(l_index)).start_index := l_index;
           END IF;

           g_hr_pos_details_tab(g_hr_position_id(l_index)).end_index := l_index;
       end loop;
     end if;

  END IF;

  IF g_hr_pos_details_tab.EXISTS(p_hr_position_id) THEN
        l_start_index  :=  g_hr_pos_details_tab(p_hr_position_id).start_index;
        l_end_index    :=  g_hr_pos_details_tab(p_hr_position_id).end_index;

       /*bug:7037138:end*/

    /*bug:7037138:modified the rest of the api to change the references of l_dist
      with the respective plsql tables used for bulk collecting data from c_dist cursor.*/

    for l_dist_index in l_start_index..l_end_index loop


      if g_follow_salary(l_dist_index) = 'Y' then
      begin

	for l_saldist_index in 1..PSB_WS_POS1.g_num_salary_dist loop

	  l_dist_start_date := greatest(l_start_date, PSB_WS_POS1.g_salary_dist(l_saldist_index).start_date);
	  l_dist_end_date := least(l_end_date, nvl(PSB_WS_POS1.g_salary_dist(l_saldist_index).end_date, l_end_date));

          -- commented for bug # 4502946
	  /*if PSB_WS_POS1.g_salary_dist(l_saldist_index).percent < 1 then
	    l_percent := PSB_WS_POS1.g_salary_dist(l_saldist_index).percent;
	  else
	    l_percent := PSB_WS_POS1.g_salary_dist(l_saldist_index).percent / 100;
	  end if;*/

          -- added for bug # 4502946
          l_percent := PSB_WS_POS1.g_salary_dist(l_saldist_index).percent / 100;

	  for l_init_index in 1..PSB_WS_ACCT1.g_num_segs loop
	    l_ccid_val(l_init_index) := null;
	    l_seg_val(l_init_index) := null;
	  end loop;



	  if not FND_FLEX_EXT.Get_Segments
	    (application_short_name => 'SQLGL',
	     key_flex_code => 'GL#',
	     structure_number => p_gl_flex_code,
	     combination_id => PSB_WS_POS1.g_salary_dist(l_saldist_index).ccid,
	     n_segments => PSB_WS_ACCT1.g_num_segs,
	     segments => l_ccid_val) then

               /* start bug 3666828 */
	       l_hr_position_id := p_hr_position_id;
	       l_element_name := g_pay_element_name(l_dist_index);
	       fnd_file.put_line(fnd_file.log, ' Element : '||l_element_name||' , Position id : '|| l_hr_position_id);
	       /* End bug 3666828 */

	    FND_MSG_PUB.Add;
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  for l_index in 1..PSB_WS_ACCT1.g_num_segs loop

	    if ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT1') and
		(g_segment1(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment1(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT2') and
		(g_segment2(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment2(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT3') and
		(g_segment3(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment3(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT4') and
		(g_segment4(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment4(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT5') and
		(g_segment5(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment5(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT6') and
		(g_segment6(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment6(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT7') and
		(g_segment7(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment7(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT8') and
		(g_segment8(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment8(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT9') and
		(g_segment9(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment9(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT10') and
		(g_segment10(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment10(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT11') and
		(g_segment11(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment11(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT12') and
		(g_segment12(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment12(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT13') and
		(g_segment13(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment13(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT14') and
		(g_segment14(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment14(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT15') and
		(g_segment15(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment15(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT16') and
		(g_segment16(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment16(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT17') and
		(g_segment17(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment17(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT18') and
		(g_segment18(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment18(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT19') and
		(g_segment19(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment19(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT20') and
		(g_segment20(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment20(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT21') and
		(g_segment21(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment21(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT22') and
		(g_segment22(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment22(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT23') and
		(g_segment23(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment23(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT24') and
		(g_segment24(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment24(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT25') and
		(g_segment25(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment25(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT26') and
		(g_segment26(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment26(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT27') and
		(g_segment27(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment27(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT28') and
		(g_segment28(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment28(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT29') and
		(g_segment29(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment29(l_dist_index);

	    elsif ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT30') and
		(g_segment30(l_dist_index) is not null)) then
	      l_seg_val(l_index) := g_segment30(l_dist_index);

	    else
	      l_seg_val(l_index) := l_ccid_val(l_index);
	    end if;

	  end loop;


	  if not FND_FLEX_EXT.Get_Combination_ID
	    (application_short_name => 'SQLGL',
	     key_flex_code => 'GL#',
	     structure_number => p_gl_flex_code,
	     validation_date => sysdate,
	     n_segments => PSB_WS_ACCT1.g_num_segs,
	     segments => l_seg_val,
	     combination_id => l_ccid) then

              /* start bug 3666828 */
	      l_hr_position_id := p_hr_position_id;
	      l_element_name := g_pay_element_name(l_dist_index);
	      fnd_file.put_line(fnd_file.log, 'Element : '||l_element_name||' , Position id : '|| l_hr_position_id);
	      /* End bug 3666828 */

	    FND_MSG_PUB.Add;
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  g_num_element_dists := g_num_element_dists + 1;

	  g_element_dists(g_num_element_dists).pay_element_id := g_pay_element_id(l_dist_index);
	  g_element_dists(g_num_element_dists).ccid := l_ccid;
	  g_element_dists(g_num_element_dists).percent := l_percent;

	end loop;

      end;
      else
      begin

        -- commented for bug # 4502946
	/*if l_dist.distribution_percent(l_dist_index) < 1 then
	  l_percent := l_dist.distribution_percent(l_dist_index);
	else
	  l_percent := l_dist.distribution_percent(l_dist_index) / 100;
	end if;*/

        -- added for bug # 4502946
        l_percent := g_dist_percent(l_dist_index) / 100;

	g_num_element_dists := g_num_element_dists + 1;

	g_element_dists(g_num_element_dists).pay_element_id := g_pay_element_id(l_dist_index);
	g_element_dists(g_num_element_dists).ccid := g_ccid(l_dist_index);
	g_element_dists(g_num_element_dists).percent := l_percent;

      end;
      end if;

    end loop;

  END IF; --bug:7037138

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  /* start bug 3666828 */
  --
  /*WHEN FND_API.G_EXC_ERROR THEN
    IF c_Dist%ISOPEN THEN
      CLOSE c_Dist;
    END IF;
    p_return_status := FND_API.G_RET_STS_ERROR;
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF c_Dist%ISOPEN THEN
      CLOSE c_Dist;
    END IF;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;*/
  --
  /* end bug 3666828 */
  WHEN OTHERS THEN
    IF c_Dist%ISOPEN THEN
      CLOSE c_Dist;
    END IF;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                'Distribute_Other_Elements');
    END IF;
    --
END Distribute_Other_Elements;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                   PROCEDURE Distribute_Position_Cost                      |
 +===========================================================================*/
PROCEDURE Distribute_Position_Cost
( p_return_status         OUT  NOCOPY  VARCHAR2,
  p_event_type            IN   VARCHAR2,
  p_source_id             IN   NUMBER,
  p_hr_budget_id          IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_gl_flex_code          IN   NUMBER,
  p_currency_code         IN   VARCHAR2,
  p_hr_position_id        IN   NUMBER,
  p_start_date            IN   DATE,
  p_end_date              IN   DATE
)
IS
  --
  l_return_status         VARCHAR2(1);
  l_setdist_exists_index  NUMBER;
  l_budget_set_id         NUMBER;
  l_start_date            DATE;
  l_budgetset_index       NUMBER := 0;
  l_budgetset_total       NUMBER := 0;
  --
BEGIN

  for l_init_index in 1..g_element_dists.Count loop
    g_element_dists(l_init_index).pay_element_id := null;
    g_element_dists(l_init_index).ccid := null;
    g_element_dists(l_init_index).percent := null;
  end loop;

  g_num_element_dists := 0;

  for l_init_index in 1..g_budgetset_dists.Count loop
    g_budgetset_dists(l_init_index).budget_set_id := null;
    g_budgetset_dists(l_init_index).ccid := null;
    g_budgetset_dists(l_init_index).amount := null;
    g_budgetset_dists(l_init_index).percent := null;
  end loop;

  g_num_budgetset_dists := 0;

  Cache_Position_Costs
  ( p_return_status   => l_return_status,
    p_event_type      => p_event_type,
    p_hr_budget_id    => p_hr_budget_id,
    p_hr_position_id  => p_hr_position_id,
    p_source_id       => p_source_id,
    p_data_extract_id => p_data_extract_id,
    p_start_date      => p_start_date,
    p_end_date        => p_end_date,
    p_currency_code   => p_currency_code
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF ;
  --

  Distribute_Salary
  ( p_return_status   => l_return_status,
    p_source_id       => p_source_id,
    p_gl_flex_code    => p_gl_flex_code,
    p_data_extract_id => p_data_extract_id,
    p_hr_position_id  => p_hr_position_id,
    p_start_date      => p_start_date,
    p_end_date        => p_end_date
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF ;
  --

  Distribute_Other_Elements
  ( p_return_status   => l_return_status,
    p_gl_flex_code    => p_gl_flex_code,
    p_data_extract_id => p_data_extract_id,
    p_hr_position_id  => p_hr_position_id,
    p_start_date      => p_start_date,
    p_end_date        => p_end_date
  );
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF ;
  --

  for l_cost_index in 1..g_num_element_costs loop

    for l_dist_index in 1..g_num_element_dists loop

      if g_element_dists(l_dist_index).pay_element_id = g_element_costs(l_cost_index).pay_element_id then
      begin

	l_setdist_exists_index := null;

	for l_setdist_index in 1..g_num_budgetset_dists loop

	  if ((g_budgetset_dists(l_setdist_index).budget_set_id = g_element_costs(l_cost_index).budget_set_id) and
	      (g_budgetset_dists(l_setdist_index).ccid = g_element_dists(l_dist_index).ccid)) then
	    l_setdist_exists_index := l_setdist_index;
	  end if;

	end loop;

	if l_setdist_exists_index is null then
	begin

	  g_num_budgetset_dists := g_num_budgetset_dists + 1;

	  g_budgetset_dists(g_num_budgetset_dists).budget_set_id := g_element_costs(l_cost_index).budget_set_id;
	  g_budgetset_dists(g_num_budgetset_dists).ccid := g_element_dists(l_dist_index).ccid;
	  g_budgetset_dists(g_num_budgetset_dists).amount := g_element_costs(l_cost_index).element_cost * g_element_dists(l_dist_index).percent;

	end;
	else
	  g_budgetset_dists(l_setdist_exists_index).amount := g_budgetset_dists(l_setdist_exists_index).amount +
				g_element_costs(l_cost_index).element_cost * g_element_dists(l_dist_index).percent;
	end if;

      end;
      end if;

    end loop;

  end loop;

  FOR l_setdist_index in 1..g_num_budgetset_dists LOOP

  -- Bug#3348467: Process elements only when the cost is non-zero.
  IF NVL(g_budgetset_dists(l_setdist_index).amount,0) <> 0 THEN

    if ( g_budgetset_dists(l_setdist_index).budget_set_id <>
         nvl(l_budget_set_id, -1)
         or
	 l_setdist_index = g_num_budgetset_dists
       )
    then

      if l_setdist_index = g_num_budgetset_dists then

	if g_budgetset_dists(l_setdist_index).budget_set_id <> nvl(l_budget_set_id, -1) then

	  if ((l_budgetset_index > 0) and (l_setdist_index > 1)) then
	    for l_dist_index in l_budgetset_index..(l_setdist_index - 1) loop
	      g_budgetset_dists(l_dist_index).percent := g_budgetset_dists(l_dist_index).amount * 100 / l_budgetset_total;
	    end loop;
	  end if;

	  l_budgetset_total := g_budgetset_dists(l_setdist_index).amount;

	  for l_dist_index in g_num_budgetset_dists..g_num_budgetset_dists loop
	    g_budgetset_dists(l_dist_index).percent := g_budgetset_dists(l_dist_index).amount * 100 / l_budgetset_total;
	  end loop;

	else

	  l_budgetset_total := l_budgetset_total + g_budgetset_dists(l_setdist_index).amount;

	  for l_dist_index in l_budgetset_index..l_setdist_index loop
	    g_budgetset_dists(l_dist_index).percent := g_budgetset_dists(l_dist_index).amount * 100 / l_budgetset_total;
	  end loop;

	end if;

      else

	if ((l_budgetset_index > 0) and (l_setdist_index > 1)) then
	  for l_dist_index in l_budgetset_index..(l_setdist_index - 1) loop
	    g_budgetset_dists(l_dist_index).percent := g_budgetset_dists(l_dist_index).amount * 100 / l_budgetset_total;
	  end loop;
	end if;

	l_budgetset_total := g_budgetset_dists(l_setdist_index).amount;
	l_budget_set_id := g_budgetset_dists(l_setdist_index).budget_set_id;
	l_budgetset_index := l_setdist_index;

      end if;

    else
      l_budgetset_total := l_budgetset_total + g_budgetset_dists(l_setdist_index).amount;
    end if;

  END IF;
  -- End processing elements only when the cost is non-zero.
  END LOOP;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  /* start bug 3666828 */
  --
  /*WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;*/
  --
  /* end bug 3666828 */

  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                'Distribute_Position_Cost') ;
    END IF;
    --
End Distribute_Position_Cost;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
PROCEDURE Create_Pqh_Budget_Version
 (p_return_status           OUT  NOCOPY  VARCHAR2,
  p_msg_count               OUT  NOCOPY  NUMBER,
  p_msg_data                OUT  NOCOPY  VARCHAR2,
  p_pqh_budget_version_id   OUT  NOCOPY  NUMBER,
  p_event_type              IN   VARCHAR2,
  p_source_id               IN   NUMBER,
  p_currency_code           IN   VARCHAR2,
  p_data_extract_id         IN   NUMBER,
  p_system_data_extract_id  IN   NUMBER,
  p_hr_budget_id            IN   NUMBER,
  p_pqh_budget_name         IN   VARCHAR2,
  p_start_date              IN   DATE,
  p_end_date                IN   DATE,
  p_budget_unit1            IN   VARCHAR2,
  p_budget_unit2            IN   VARCHAR2,
  p_budget_unit3            IN   VARCHAR2) IS

  l_version_found           BOOLEAN := FALSE;
  l_object_version_number   NUMBER;
  l_version_number          NUMBER;
  l_budget_version_id       NUMBER;
  l_budget_unit1_value      NUMBER;
  l_budget_unit2_value      NUMBER;
  l_budget_unit3_value      NUMBER;
  l_date_from               DATE;
  l_date_to                 DATE;
  l_original_fte            NUMBER;
  l_current_fte             NUMBER;
  l_revised_fte             NUMBER;
  l_revision_amount         NUMBER := 0;
  l_total_cost              NUMBER := 0;
  l_total_fte               NUMBER := 0;

  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_return_status           VARCHAR2(1);

  /* bug no 3670254 */
  -- these local variables will hold the values
  -- of FTE and position ID
  TYPE l_position_id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_position_id_tbl         l_position_id_tbl_type;

  l_fte_attribute_value     NUMBER;
  l_position_id	    	    NUMBER;
  /* bug no 3670254 */


  cursor c_brversion is
    select version_number, budget_version_id, object_version_number, date_from, date_to,
	   budget_unit1_value, budget_unit2_value, budget_unit3_value
      from pqh_psb_budget_versions
     where budget_id = p_hr_budget_id
       and version_number =
	  (select max(version_number) from pqh_psb_budget_versions
	    where budget_id = p_hr_budget_id);

  cursor c_bpversion is
    select version_number, budget_version_id, object_version_number
      from pqh_psb_budget_versions
     where budget_id = p_hr_budget_id
       and date_from = p_start_date
       and date_to = p_end_date;

  cursor c_total_cost_bp is
    select sum(ppc.element_cost) total_cost
      from psb_positions pp, psb_position_costs ppc
     where pp.data_extract_id = p_system_data_extract_id
       and exists
	  (select 'Exists'
	     from psb_positions pp1, psb_ws_position_lines wpl, psb_ws_lines_positions wlp
	    where pp1.data_extract_id = p_data_extract_id
	      and pp1.hr_position_id = pp.hr_position_id
	      and wpl.position_id = pp1.position_id
	      and wlp.position_line_id = wpl.position_line_id
	      and wlp.worksheet_id = p_source_id)
       and ppc.position_id = pp.position_id
       and ppc.hr_budget_id = p_hr_budget_id
       and ppc.base_line_version = 'O'
       and ppc.currency_code = p_currency_code
       and ppc.budget_revision_id is null
       and ((ppc.start_date between p_start_date and p_end_date)
	 or (ppc.end_date between p_start_date and p_end_date)
	 or ((ppc.start_date < p_start_date) and (ppc.end_date > p_end_date)));

  cursor c_revision_amount is
    select sum(decode(b.revision_type, 'I', b.revision_amount,
				       'D', -b.revision_amount)) revision_amount
      from psb_budget_revision_lines a,
	   psb_budget_revision_accounts b
     where a.budget_revision_id = p_source_id
       and b.budget_revision_acct_line_id = a.budget_revision_acct_line_id
       and b.position_id is not null;

  cursor c_total_fte_bp is
    select sum(avg(ppf.fte)) total_fte
      from psb_positions pp, psb_position_fte ppf
     where pp.data_extract_id = p_system_data_extract_id
       and exists
	  (select 'Exists'
	     from psb_positions pp1, psb_ws_position_lines wpl, psb_ws_lines_positions wlp
	    where pp1.data_extract_id = p_data_extract_id
	      and pp1.hr_position_id = pp.hr_position_id
	      and wpl.position_id = pp1.position_id
	      and wlp.position_line_id = wpl.position_line_id
	      and wlp.worksheet_id = p_source_id)
       and ppf.position_id = pp.position_id
       and ppf.hr_budget_id = p_hr_budget_id
       and ppf.base_line_version = 'O'
       and ppf.budget_revision_id is null
       and ((ppf.start_date between p_start_date and p_end_date)
	 or (ppf.end_date between p_start_date and p_end_date)
	 or ((ppf.start_date < p_start_date) and (ppf.end_date > p_end_date)))
     group by ppf.position_id;

  cursor c_revision_fte is
    select brp.position_id, brp.effective_start_date, brp.effective_end_date,
	   brp.revision_type, brp.revision_value_type, brp.revision_value
      from psb_budget_revision_pos_lines brpl,
	   psb_budget_revision_positions brp
     where brpl.budget_revision_id = p_source_id
       and brp.budget_revision_pos_line_id = brpl.budget_revision_pos_line_id;

  /* bug no 3670254 */
  -- This cursor is used to get the positions
  -- associated with the data extract.
  CURSOR l_position_csr
  IS
  SELECT position_id
  FROM   psb_ws_position_lines a, psb_ws_lines_positions b
  WHERE  worksheet_id = p_source_id
  AND    a.position_line_id = b.position_line_id;
  /* bug no 3670254 */


  l_api_name               CONSTANT VARCHAR2(30)   := 'Create_Pqh_Budget_Version';

BEGIN

  if p_event_type = 'BP' then
  begin

    for c_version_rec in c_bpversion loop
      l_version_number := c_version_rec.version_number;
      l_budget_version_id := c_version_rec.budget_version_id;
      l_object_version_number := c_version_rec.object_version_number;
      l_date_from := p_start_date;
      l_date_to := p_end_date;
      l_version_found := TRUE;
    end loop;

    if not l_version_found then
      message_token('BUDGET', p_pqh_budget_name);
      message_token('STARTDATE', p_start_date);
      message_token('ENDDATE', p_end_date);
      add_message('PSB', 'PSB_PQH_BP_VERSION_NOTFOUND');
      raise FND_API.G_EXC_ERROR;
    end if;

    for c_total_cost_rec in c_total_cost_bp loop
      l_total_cost := c_total_cost_rec.total_cost;
    end loop;

    /* bug no 3670254 */
    -- This loop should execute only when the profile value
    -- is 'ASSIGNMENT'.
    IF g_hrms_fte_upload_option = 'ASSIGNMENT' THEN
      -- get the positions in worksheet
      OPEN l_position_csr;
      --FOR l_position_rec IN l_position_csr
      LOOP
        -- delete the table before the bulk fetch
        l_position_id_tbl.DELETE;
        FETCH l_position_csr BULK COLLECT INTO l_position_id_tbl LIMIT 1000;

        FOR l_pos_cnt IN 1..l_position_id_tbl.COUNT
        LOOP
          l_position_id := l_position_id_tbl(l_pos_cnt);
	  l_fte_attribute_value := NULL;

          -- check is the position has worksheet level FTE
          FOR l_ass_fte_rec IN g_ass_fte_csr
          ( c_data_extract_id       => p_data_extract_id ,
            c_position_id           => l_position_id     ,
            c_worksheet_id          => p_source_id       ,
            c_attribute_id          => g_fte_attribute_id    ,
            c_budget_year_end_date  => p_end_date
          )
	  LOOP
   	    l_fte_attribute_value := l_ass_fte_rec.attribute_value;
      	  END LOOP;

      	  IF l_fte_attribute_value IS NULL THEN

            -- check if the position has DE level FTE
      	    FOR l_ass_fte_rec IN g_ass_fte_csr
            ( c_data_extract_id       => p_data_extract_id ,
              c_position_id           => l_position_id     ,
              c_worksheet_id          => NULL              ,
              c_attribute_id          => g_fte_attribute_id    ,
              c_budget_year_end_date  => p_end_date
            )
	    LOOP
    	      l_fte_attribute_value := l_ass_fte_rec.attribute_value;
      	    END LOOP;
      	  END IF;

          -- get the attribute value
      	  l_fte_attribute_value := Nvl(l_fte_attribute_value,0);

      	  -- fetch the FTE for all positions for that budget period
          l_total_fte := l_total_fte + l_fte_attribute_value;
        END LOOP;
        EXIT WHEN l_position_csr%NOTFOUND;
      END LOOP;
      CLOSE l_position_csr;

    ELSE
      FOR c_total_fte_rec in c_total_fte_bp
      LOOP
        l_total_fte := c_total_fte_rec.total_fte;
      END LOOP;
    END IF;
    /* bug no 3670254 */

    if nvl(p_budget_unit1, 'X') = 'FTE' then
       l_budget_unit1_value := l_total_fte;
    elsif nvl(p_budget_unit1, 'X') = 'MONEY' then
      l_budget_unit1_value := l_total_cost;
    end if;

    if nvl(p_budget_unit2, 'X') = 'FTE' then
      l_budget_unit2_value := l_total_fte;
    elsif nvl(p_budget_unit2, 'X') = 'MONEY' then
      l_budget_unit2_value := l_total_cost;
    end if;

    if nvl(p_budget_unit3, 'X') = 'FTE' then
      l_budget_unit3_value := l_total_fte;
    elsif nvl(p_budget_unit3, 'X') = 'MONEY' then
      l_budget_unit3_value := l_total_cost;
    end if;

  end;
  elsif p_event_type = 'BR' then
  begin

    for c_version_rec in c_brversion loop
      l_version_number := c_version_rec.version_number;
      l_budget_version_id := c_version_rec.budget_version_id;
      l_object_version_number := c_version_rec.object_version_number;
      l_budget_unit1_value := c_version_rec.budget_unit1_value;
      l_budget_unit2_value := c_version_rec.budget_unit2_value;
      l_budget_unit3_value := c_version_rec.budget_unit3_value;
      l_date_from := c_version_rec.date_from;
      l_date_to := c_version_rec.date_to;
      l_version_found := TRUE;
    end loop;

    if not l_version_found then
      message_token('BUDGET', p_pqh_budget_name);
      add_message('PSB', 'PSB_PQH_BR_VERSION_NOTFOUND');
      raise FND_API.G_EXC_ERROR;
    end if;

    for c_revision_amount_rec in c_revision_amount loop
      l_revision_amount := c_revision_amount_rec.revision_amount;
    end loop;

    l_total_fte := 0;

    for c_revision_fte_rec in c_revision_fte loop

      PSB_BUDGET_REVISIONS_PVT.Find_FTE
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_position_id => c_revision_fte_rec.position_id,
	  p_hr_budget_id => p_hr_budget_id,
	  p_budget_revision_id => p_source_id,
	  p_revision_type => c_revision_fte_rec.revision_type,
	  p_revision_value_type => c_revision_fte_rec.revision_value_type,
	  p_revision_value => c_revision_fte_rec.revision_value,
	  p_effective_start_date => c_revision_fte_rec.effective_start_date,
	  p_effective_end_date => c_revision_fte_rec.effective_end_date,
	  p_original_fte => l_original_fte,
	  p_current_fte => l_current_fte,
	  p_revised_fte => l_revised_fte);

      l_total_fte := l_total_fte + (l_revised_fte - l_current_fte);

    end loop;

    if nvl(p_budget_unit1, 'X') = 'FTE' then
      l_budget_unit1_value := l_budget_unit1_value + l_total_fte;
    elsif nvl(p_budget_unit1, 'X') = 'MONEY' then
      l_budget_unit1_value := l_budget_unit1_value + l_revision_amount;
    end if;

    if nvl(p_budget_unit2, 'X') = 'FTE' then
      l_budget_unit2_value := l_budget_unit2_value + l_total_fte;
    elsif nvl(p_budget_unit2, 'X') = 'MONEY' then
      l_budget_unit2_value := l_budget_unit2_value + l_revision_amount;
    end if;

    if nvl(p_budget_unit3, 'X') = 'FTE' then
      l_budget_unit3_value := l_budget_unit3_value + l_total_fte;
    elsif nvl(p_budget_unit3, 'X') = 'MONEY' then
      l_budget_unit3_value := l_budget_unit3_value + l_revision_amount;
    end if;

  end;
  end if;

  begin

    pqh_psb_interface_api.update_budget_version
      (p_validate              => false,
       p_budget_id             => p_hr_budget_id,
       p_budget_version_id     => l_budget_version_id,
       p_version_number        => l_version_number,
       p_date_from             => l_date_from,
       p_date_to               => l_date_to,
       p_transfered_to_gl_flag => 'N',
       p_xfer_to_other_apps_cd => 'N',
       p_object_version_number => l_object_version_number,
       p_budget_unit1_value    => l_budget_unit1_value,
       p_budget_unit2_value    => l_budget_unit2_value,
       p_budget_unit3_value    => l_budget_unit3_value,
       p_effective_date        => sysdate);

  EXCEPTION
    when OTHERS then
      FND_MSG_PUB.Add;
      message_token('BUDGET', p_pqh_budget_name);
      message_token('VERSION', l_version_number);
      message_token('STARTDATE', p_start_date);
      message_token('ENDDATE', p_end_date);
      add_message('PSB', 'PSB_PQH_UPDATE_BUDGET_VERSION');
      raise FND_API.G_EXC_ERROR;
  end;

  p_pqh_budget_version_id := l_budget_version_id;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
END Create_Pqh_Budget_Version;

/* ----------------------------------------------------------------------- */

FUNCTION Get_Segment_Val (p_index NUMBER) RETURN VARCHAR2 IS
  l_segment_value  VARCHAR2(25);
  l_index          BINARY_INTEGER;
BEGIN

  for l_index in 1..g_map_tab.count loop
    if g_map_tab(l_index).cost_segment_name = 'SEGMENT' || p_index then
      l_segment_value := g_map_tab(l_index).segment_value;
      exit;
    end if;
  end loop;

  return l_segment_value;

END Get_Segment_Val;

/* ----------------------------------------------------------------------- */

-- return cost allocation key flex ID for a GL CCID

FUNCTION Get_Cost_Keyflex_ID
(p_payroll_id           IN  NUMBER,
 p_gl_flex_code         IN  NUMBER,
 p_id_flex_num          IN  NUMBER,
 p_num_segments         IN  NUMBER,
 p_code_combination_id  IN  NUMBER) RETURN NUMBER IS

 l_cost_flex_id         NUMBER := 0;
 l_concat_segments      VARCHAR2(2000);

 l_dummy                BOOLEAN;
 l_no_of_segments       NUMBER;
 l_segment_array        FND_FLEX_EXT.SegmentArray;

BEGIN

    if g_map_str IS NOT NULL then
    begin
      EXECUTE IMMEDIATE g_map_str into l_cost_flex_id USING p_id_flex_num, p_code_combination_id;
    exception
      when OTHERS then
	l_cost_flex_id := 0;
    end;
    end if;

    if ((l_cost_flex_id = 0) and (nvl(g_map_tab.count, 0) <> 0)) then
    begin

      -- Fix for Bug: 3365072 - Start ...
      -- If the Cost Allocation KFF is not available then we have to
      -- create it. The PL/SQL table (g_map_tab) is populated with
      -- the segment values so that the call to Get_Segment_Val()
      -- returns the appropriate value which is used to call
      -- Hr_Entry.Maintain_Cost_Keyflex().

      l_dummy := fnd_flex_ext.get_segments( application_short_name => 'SQLGL',
                                            key_flex_code => 'GL#',
                                            structure_number => p_gl_flex_code,
                                            combination_id => p_code_combination_id,
                                            n_segments => l_no_of_segments,
                                            segments => l_segment_array );

      if not (l_dummy) then
        raise FND_API.G_EXC_ERROR;
      end if;

      for i in 1..30 loop
        g_map_tab(i).segment_value := null;
      end loop;

      for i in 1..l_no_of_segments loop

        for j in 1..30 loop

          if g_map_tab(j).gl_segment_name is not null
	                 and g_map_tab(j).segment_value is null then

            g_map_tab(j).segment_value := l_segment_array(i);
	    exit;

          end if;

	end loop;

      end loop;

    -- Fix for Bug: 3365072 - ... End

      l_cost_flex_id := hr_entry.maintain_cost_keyflex(
		   p_cost_keyflex_structure => p_id_flex_num,
		   p_cost_allocation_keyflex_id => -1,
		   p_concatenated_segments => null,
		   p_summary_flag => 'N',
		   p_start_date_active => null,
		   p_end_date_active => null,
		   p_segment1 => Get_Segment_Val(1),
		   p_segment2 => Get_Segment_Val(2),
		   p_segment3 => Get_Segment_Val(3),
		   p_segment4 => Get_Segment_Val(4),
		   p_segment5 => Get_Segment_Val(5),
		   p_segment6 => Get_Segment_Val(6),
		   p_segment7 => Get_Segment_Val(7),
		   p_segment8 => Get_Segment_Val(8),
		   p_segment9 => Get_Segment_Val(9),
		   p_segment10 => Get_Segment_Val(10),
		   p_segment11 => Get_Segment_Val(11),
		   p_segment12 => Get_Segment_Val(12),
		   p_segment13 => Get_Segment_Val(13),
		   p_segment14 => Get_Segment_Val(14),
		   p_segment15 => Get_Segment_Val(15),
		   p_segment16 => Get_Segment_Val(16),
		   p_segment17 => Get_Segment_Val(17),
		   p_segment18 => Get_Segment_Val(18),
		   p_segment19 => Get_Segment_Val(19),
		   p_segment20 => Get_Segment_Val(20),
		   p_segment21 => Get_Segment_Val(21),
		   p_segment22 => Get_Segment_Val(22),
		   p_segment23 => Get_Segment_Val(23),
		   p_segment24 => Get_Segment_Val(24),
		   p_segment25 => Get_Segment_Val(25),
		   p_segment26 => Get_Segment_Val(26),
		   p_segment27 => Get_Segment_Val(27),
		   p_segment28 => Get_Segment_Val(28),
		   p_segment29 => Get_Segment_Val(29),
		   p_segment30 => Get_Segment_Val(30));

    EXCEPTION
      when OTHERS then
	l_concat_segments := FND_FLEX_EXT.Get_Segs
			       (application_short_name => 'SQLGL',
				key_flex_code => 'GL#',
				structure_number => p_gl_flex_code,
				combination_id => p_code_combination_id);
	message_token('GL_ACCOUNT', l_concat_segments);
	add_message('PSB', 'PSB_PQH_MAINTAIN_COST_KEYFLEX');
	l_cost_flex_id := 0;

    end;
    end if;

  return l_cost_flex_id;

END Get_Cost_Keyflex_ID;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Pqh_Budget_Elements
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_msg_count               OUT  NOCOPY  NUMBER,
  p_msg_data                OUT  NOCOPY  VARCHAR2,
  p_event_type              IN   VARCHAR2,
  p_source_id               IN   NUMBER,
  p_business_group_id       IN   NUMBER,
  p_currency_code           IN   VARCHAR2,
  p_system_data_extract_id  IN   NUMBER,
  p_gl_flex_code            IN   NUMBER,
  p_pqh_budget_set_id       IN   NUMBER,
  p_dflt_budget_set_id      IN   NUMBER,
  p_hr_position_id          IN   NUMBER,
  p_payroll_id              IN   NUMBER,
  p_hr_budget_id            IN   NUMBER,
  p_position_name           IN   VARCHAR2,
  p_hr_employee_id          IN   NUMBER,
  p_effective_start_date    IN   DATE,
  p_period_start_date       IN   DATE,
  p_period_end_date         IN   DATE,
  p_num_segments            IN   NUMBER,
  p_id_flex_num             IN   NUMBER) IS

  l_pqh_budget_fund_src_id       NUMBER;
  l_pqh_budget_element_id        NUMBER;
  l_cost_keyflex_id              NUMBER;
  l_object_version_number        NUMBER;
  l_fund_object_version_number   NUMBER;

  cursor c_dflt_budget_elem is
    select dflt_budget_element_id,
	   element_type_id,
	   dflt_dist_percentage
      from pqh_psb_dflt_budget_elements
     where dflt_budget_set_id = p_dflt_budget_set_id;

  cursor c_pqh_budget_elements (elemtypeid NUMBER) is
    select *
      from pqh_psb_budget_elements
     where budget_set_id = p_pqh_budget_set_id
       and element_type_id = elemtypeid;

  cursor c_pqh_fund_srcs is
    select *
      from pqh_psb_budget_fund_srcs
     where budget_element_id = l_pqh_budget_element_id
       and cost_allocation_keyflex_id = l_cost_keyflex_id;

  c_pqh_budget_elements_rec      c_pqh_budget_elements%ROWTYPE;
  c_pqh_fund_srcs_rec            c_pqh_fund_srcs%ROWTYPE;

  l_api_name               CONSTANT VARCHAR2(30)   := 'Create_Pqh_Budget_Elements';

BEGIN

  for c_dflt_budget_elem_rec in c_dflt_budget_elem loop
    open c_pqh_budget_elements (c_dflt_budget_elem_rec.element_type_id);

    fetch c_pqh_budget_elements into c_pqh_budget_elements_rec;

    if c_pqh_budget_elements%NOTFOUND then
    begin

      pqh_psb_interface_api.create_budget_element
	(p_validate => false,
	 p_budget_element_id => l_pqh_budget_element_id,
	 p_budget_set_id => p_pqh_budget_set_id,
	 p_element_type_id => c_dflt_budget_elem_rec.element_type_id,
	 p_distribution_percentage => c_dflt_budget_elem_rec.dflt_dist_percentage,
	 p_object_version_number => l_object_version_number);

    EXCEPTION
      when OTHERS then
	FND_MSG_PUB.Add;
	message_token('POSITION', p_position_name);
	add_message('PSB', 'PSB_PQH_CREATE_BUDGET_ELEMENT');
	raise FND_API.G_EXC_ERROR;
    end;

    else
      l_pqh_budget_element_id := c_pqh_budget_elements_rec.budget_element_id;

      begin
	pqh_psb_interface_api.update_budget_element
	  (p_validate => false,
	   p_budget_element_id => c_pqh_budget_elements_rec.budget_element_id,
	   p_budget_set_id => p_pqh_budget_set_id,
	   p_element_type_id => c_dflt_budget_elem_rec.element_type_id,
	   p_distribution_percentage => c_dflt_budget_elem_rec.dflt_dist_percentage,
	   p_object_version_number => c_pqh_budget_elements_rec.object_version_number);

      EXCEPTION
	 when OTHERS then
	   FND_MSG_PUB.Add;
	   message_token('POSITION', p_position_name);
	   add_message('PSB', 'PSB_PQH_UPDATE_BUDGET_ELEMENT');
	   raise FND_API.G_EXC_ERROR;
      end;

    end if;

    close c_pqh_budget_elements;

    for l_dist_index in 1..g_num_budgetset_dists loop

      if g_budgetset_dists(l_dist_index).budget_set_id = p_dflt_budget_set_id then

	l_cost_keyflex_id := Get_Cost_Keyflex_ID (p_payroll_id => p_payroll_id,
						  p_gl_flex_code => p_gl_flex_code,
						  p_id_flex_num => p_id_flex_num,
						  p_num_segments => p_num_segments,
						  p_code_combination_id => g_budgetset_dists(l_dist_index).ccid);

	if l_cost_keyflex_id = 0 then
      	  FND_MESSAGE.SET_NAME('PSB','PSB_DEBUG_MESSAGE');
      	  FND_MESSAGE.SET_TOKEN('MESSAGE', 'Cost Keyflex not found');
      	  FND_MSG_PUB.Add;
	  raise FND_API.G_EXC_ERROR;
	end if;

	open c_pqh_fund_srcs;

	fetch c_pqh_fund_srcs into c_pqh_fund_srcs_rec;

	if c_pqh_fund_srcs%NOTFOUND then
	begin

	  pqh_psb_interface_api.create_budget_fund_src
	     (p_validate                       =>  false,
	      p_budget_fund_src_id             =>  l_pqh_budget_fund_src_id,
	      p_budget_element_id              =>  l_pqh_budget_element_id,
	      p_cost_allocation_keyflex_id     =>  l_cost_keyflex_id,
	      p_distribution_percentage        =>  g_budgetset_dists(l_dist_index).percent,
	      p_object_version_number          =>  l_fund_object_version_number);

	EXCEPTION
	  when OTHERS then
	    FND_MSG_PUB.Add;
	    message_token('POSITION', p_position_name);
	    add_message('PSB', 'PSB_PQH_CREATE_BUDGET_FUND_SRC');
	    raise FND_API.G_EXC_ERROR;
	end;
	else
	begin

	  l_pqh_budget_fund_src_id := c_pqh_fund_srcs_rec.budget_fund_src_id;

	  pqh_psb_interface_api.update_budget_fund_src
	     (p_validate                       =>  false,
	      p_budget_fund_src_id             =>  c_pqh_fund_srcs_rec.budget_fund_src_id,
	      p_budget_element_id              =>  l_pqh_budget_element_id,
	      p_cost_allocation_keyflex_id     =>  l_cost_keyflex_id,
	      p_distribution_percentage        =>  g_budgetset_dists(l_dist_index).percent,
	      p_object_version_number          =>  c_pqh_fund_srcs_rec.object_version_number);

	EXCEPTION
	  when OTHERS then
	    FND_MSG_PUB.Add;
	     message_token('POSITION', p_position_name);
	     add_message('PSB', 'PSB_PQH_UPDATE_BUDGET_FUND_SRC');
	     raise FND_API.G_EXC_ERROR;

	end;
	end if;

	close c_pqh_fund_srcs;

      end if;

    end loop;

  end loop;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Create_Pqh_Budget_Elements;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Pqh_Budget_Periods
 (p_return_status           OUT  NOCOPY  VARCHAR2,
  p_msg_count               OUT  NOCOPY  NUMBER,
  p_msg_data                OUT  NOCOPY  VARCHAR2,
  p_event_type              IN   VARCHAR2,
  p_source_id               IN   NUMBER,
  p_hr_budget_id            IN   NUMBER,
  p_currency_code           IN   VARCHAR2,
  p_business_group_id       IN   NUMBER,
  p_data_extract_id         IN   NUMBER,  --bug:7037138
  p_system_data_extract_id  IN   NUMBER,
  p_gl_flex_code            IN   NUMBER,
  p_start_date              IN   DATE,
  p_end_date                IN   DATE,
  p_pqh_budget_detail_id    IN   NUMBER,
  p_hr_position_id          IN   NUMBER,
  p_payroll_id              IN   NUMBER,
  p_position_name           IN   VARCHAR2,
  p_hr_employee_id          IN   NUMBER,
  p_effective_start_date    IN   DATE,
  p_budget_unit1            IN   VARCHAR2,
  p_budget_unit2            IN   VARCHAR2,
  p_budget_unit3            IN   VARCHAR2,
  p_num_segments            IN   NUMBER,
  p_id_flex_num             IN   NUMBER ,
  /* bug no 3670254 */
  -- this parameter will have assignment level FTE
  -- which is used to populate periods
  p_assignment_fte	    IN 	 NUMBER DEFAULT NULL
  ) IS

  l_budget_unit1_value      NUMBER;
  l_budget_unit2_value      NUMBER;
  l_budget_unit3_value      NUMBER;
  l_pqh_budget_period_id    NUMBER;
  l_pqh_budget_set_id       NUMBER;
  l_start_time_period_id    NUMBER;
  l_end_time_period_id      NUMBER;
  l_period_cost             NUMBER;
  l_budget_set_cost         NUMBER;
  l_object_version_number   NUMBER;
  l_set_obj_ver_num         NUMBER;
  l_return_status           VARCHAR2(1);

  TYPE l_time_period_rec_type IS RECORD
     (time_period_id        NUMBER,
      start_date            DATE,
      end_date              DATE);

  TYPE l_time_period_tbl_type IS TABLE OF l_time_period_rec_type
     INDEX BY BINARY_INTEGER;

  l_time_period             l_time_period_tbl_type;
  l_num_time_period         NUMBER;

  /*For Bug No : 2434152 Start*/
  TYPE num_arr  IS TABLE OF NUMBER;
  TYPE date_arr IS TABLE OF DATE;

  TYPE period_rec IS RECORD (start_date date_arr, end_date date_arr,fte num_arr, cost num_arr);
  l_period_rec        period_rec;

  TYPE budget_set_cost_rec IS RECORD (hr_budget_set_id num_arr, budget_set_cost num_arr);
  l_bs_cost   budget_set_cost_rec;

  /*For Bug No : 2434152 End*/

  /*bug:7037138:Modified the query to fetch records for all hr positions.
    This is to bulk collect the data for improving the performance */

  cursor c_period_rec is
    select a.hr_position_id, --bug:7037138
           a.start_date, a.end_date, a.fte, b.cost
      from
	  (
	   select pp.hr_position_id, --bug:7037138
                  ppf.start_date,
		  ppf.end_date,
		  sum(ppf.fte) fte
	     from psb_position_fte ppf,
		  psb_positions pp
	    where pp.data_extract_id = p_system_data_extract_id
	      and ppf.position_id = pp.position_id
	      and ppf.hr_budget_id = p_hr_budget_id
	      and ((p_event_type = 'BP' and ppf.base_line_version = 'C')
		   or (p_event_type = 'BR' and ppf.budget_revision_id = p_source_id))
              and ((ppf.start_date <= p_end_date) and (ppf.end_date >= p_start_date))  --bug:7037138:modified
	 group by pp.hr_position_id,             --bug:7037138:modified
                  ppf.start_date, ppf.end_date
	  ) a,
	  (select pp.hr_position_id, --bug:7037138
                  ppc.start_date, ppc.end_date, sum(ppc.element_cost) cost
	     from psb_position_costs ppc, psb_positions pp
	    where pp.data_extract_id = p_system_data_extract_id
	      and ppc.position_id = pp.position_id
	      and ppc.hr_budget_id = p_hr_budget_id
	      and ((p_event_type = 'BP' and ppc.base_line_version = 'C')
		   or (p_event_type = 'BR' and ppc.budget_revision_id = p_source_id))
	      and ppc.currency_code = p_currency_code
              and ((ppc.start_date <= p_end_date) and (ppc.end_date >= p_start_date))  --bug:7037138:modified
	 group by pp.hr_position_id,             --bug:7037138:modified
                  ppc.start_date, ppc.end_date
	   ) b
       where ((b.start_date <= a.end_date) and (b.end_date >= a.start_date))     --bug:7037138:modified
        /*bug:7037138:start*/
         and  a.hr_position_id = b.hr_position_id
         and exists
         (select 1
          from   psb_positions ppos
          where  ppos.hr_position_id = a.hr_position_id
         and  ppos.data_extract_id = decode(p_event_type, 'BP', p_data_extract_id, p_system_data_extract_id))
         order by a.hr_position_id, a.start_date, a.end_date ;
        /*bug:7037138:end*/

  cursor c_pqh_budget_periods (start_period_id NUMBER, end_period_id NUMBER) is
    select *
      from pqh_psb_budget_periods
     where budget_detail_id = p_pqh_budget_detail_id
       and start_time_period_id = start_period_id
       and end_time_period_id = end_period_id;

  cursor c_time_periods (startdate DATE) is
    select pt.time_period_id, pt.start_date, pt.end_date
      from per_time_periods pt, pqh_psb_budgets pb
     where pb.budget_id = p_hr_budget_id
       and pt.period_set_name = pb.period_set_name
       and startdate between pt.start_date and pt.end_date;

  cursor c_time_periods_br (startdate DATE, enddate DATE) is
    select pt.time_period_id, pt.start_date, pt.end_date
      from per_time_periods pt, pqh_psb_budgets pb
     where pb.budget_id = p_hr_budget_id
       and pt.period_set_name = pb.period_set_name
       and ((pt.start_date between startdate and enddate)
	 or (pt.end_date between startdate and enddate)
	 or ((pt.start_date < startdate) and (pt.end_date > enddate)));

/*bug:7037138:start*/

 /*bug:7037138:Modified the cursor to fetch budget set cost for all hr positions
   in the system data extract */

  cursor c_budget_set_cost is
select ppe.budget_set_id hr_budget_set_id,pp.hr_position_id,
       ppf.start_date,ppf.end_date,
	   sum(nvl(ppc.element_cost,0)) budget_set_cost
      from psb_pay_elements ppe,
	   psb_position_costs ppc,
	   psb_positions pp,
	   psb_position_fte ppf
     where ppe.data_extract_id = p_system_data_extract_id
       and pp.data_extract_id = p_system_data_extract_id
       and ppc.position_id = pp.position_id
       and ppc.pay_element_id = ppe.pay_element_id
       and ppc.hr_budget_id = p_hr_budget_id
   and ((p_event_type = 'BP' and ppc.base_line_version = 'C')
     or (p_event_type = 'BR' and ppc.budget_revision_id = p_source_id))
   and ((p_event_type = 'BP' and ppf.base_line_version = 'C')
     or (p_event_type = 'BR' and ppf.budget_revision_id = p_source_id))
       and ppc.currency_code = p_currency_code
   and ((ppf.start_date between p_start_date and p_end_date)
     or (ppf.end_date between p_start_date and p_end_date)
     or ((ppf.start_date < p_start_date) and (ppf.end_date > p_end_date)))
   and ((ppc.start_date between ppf.start_date and ppf.end_date)
     or (ppc.end_date between ppf.start_date and ppf.end_date)
     or ((ppc.start_date < ppf.start_date) and (ppc.end_date > ppf.end_date)))
 group by pp.hr_position_id,ppe.budget_set_id,ppf.start_date,ppf.end_date;

 l_bc_budget_set_cost   BOOLEAN := FALSE;
 l_start_ind            NUMBER := 0;
 l_end_ind              NUMBER := 0;

 l_bs_index            NUMBER;

 l_pd_start_ind    NUMBER := 0;
 l_pd_end_ind      NUMBER := 0;

/*bug:7037138:end*/

  cursor c_pqh_budget_sets (hrbudgetsetid NUMBER) is
    select *
      from pqh_psb_budget_sets
     where budget_period_id = l_pqh_budget_period_id
       and dflt_budget_set_id = hrbudgetsetid;

  c_time_periods_rec        c_time_periods%ROWTYPE;
  c_pqh_budget_periods_rec  c_pqh_budget_periods%ROWTYPE;
  c_pqh_budget_sets_rec     c_pqh_budget_sets%ROWTYPE;

  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);

  l_api_name               CONSTANT VARCHAR2(30)   := 'Create_Pqh_Budget_Periods';

BEGIN

  /*bug:7037138:start*/
  IF (g_system_data_extract_id IS NULL OR g_hr_budget_id IS NULL) THEN
     g_system_data_extract_id := p_system_data_extract_id;
     g_hr_budget_id := p_hr_budget_id;
     l_bc_budget_set_cost := TRUE;
  ELSIF (g_system_data_extract_id <> p_system_data_extract_id OR
         g_hr_budget_id <> p_hr_budget_id) THEN
      g_system_data_extract_id := p_system_data_extract_id;
      g_hr_budget_id := p_hr_budget_id;
      l_bc_budget_set_cost := TRUE;
  END IF;

  IF l_bc_budget_set_cost THEN

     g_budget_set_id.delete;
     g_pos_id.delete;
     g_period_start_date.delete;
     g_period_end_date.delete;
     g_budget_set_cost.delete;

     OPEN c_budget_set_cost;
     FETCH c_budget_set_cost BULK COLLECT INTO g_budget_set_id, g_pos_id,
                             g_period_start_date, g_period_end_date, g_budget_set_cost;

     IF c_budget_set_cost%NOTFOUND THEN
        CLOSE c_budget_set_cost;
     END IF;

     IF c_budget_set_cost%ISOPEN THEN
        CLOSE c_budget_set_cost;
     END IF;

  IF g_pos_id.count > 0 THEN
    FOR l_index IN 1..g_pos_id.count LOOP
        g_pos_details_tab(g_pos_id(l_index)).hr_position_id := g_pos_id(l_index);

        IF g_pos_details_tab(g_pos_id(l_index)).start_index IS NULL THEN
           g_pos_details_tab(g_pos_id(l_index)).start_index := l_index;
        END IF;

        g_pos_details_tab(g_pos_id(l_index)).end_index := l_index;
    END LOOP;

  END IF;

  END IF;

  IF g_pos_details_tab.exists(p_hr_position_id) THEN
        l_start_ind := g_pos_details_tab(p_hr_position_id).start_index;
        l_end_ind   := g_pos_details_tab(p_hr_position_id).end_index;
  END IF;


 /*Logic to bulk collect period amount records */
  IF g_hr_pos_id.COUNT = 0 THEN

  open c_period_rec;

  fetch c_period_rec BULK COLLECT INTO g_hr_pos_id, g_pd_start_date, g_pd_end_date, g_pd_fte, g_pd_cost;

  IF c_period_rec%NOTFOUND THEN
     CLOSE c_period_rec;
  END IF;

  IF c_period_rec%ISOPEN THEN
     CLOSE c_period_rec;
  END IF;

  for l_index in 1..g_hr_pos_id.count loop
     g_period_ind_tbl(g_hr_pos_id(l_index)).hr_position_id := g_hr_pos_id(l_index);

     IF g_period_ind_tbl(g_hr_pos_id(l_index)).start_index IS NULL THEN
       g_period_ind_tbl(g_hr_pos_id(l_index)).start_index := l_index;
     END IF;

       g_period_ind_tbl(g_hr_pos_id(l_index)).end_index := l_index;
  end loop;

 END IF;

  IF g_period_ind_tbl.exists(p_hr_position_id) THEN
     l_pd_start_ind   := g_period_ind_tbl(p_hr_position_id).start_index;
     l_pd_end_ind     := g_period_ind_tbl(p_hr_position_id).end_index;
  END IF;

  /*bug:7037138:end*/

  /*bug:7037138:Modified the rest of the api by replacing the references of l_period_rec
    with the plsql tables used for bulk collecting the records from c_period_rec cursor.*/

   for l_fte_index in l_pd_start_ind..l_pd_end_ind loop

    for l_init_index in 1..l_time_period.count loop
      l_time_period(l_init_index).time_period_id := null;
      l_time_period(l_init_index).start_date := null;
      l_time_period(l_init_index).end_date := null;
    end loop;

    l_num_time_period := 0;

    if p_event_type = 'BP' then
    begin

      for c_time_periods_rec in c_time_periods (g_pd_start_date(l_fte_index)) loop
	l_num_time_period := l_num_time_period + 1;
	l_time_period(l_num_time_period).time_period_id := c_time_periods_rec.time_period_id;
	l_time_period(l_num_time_period).start_date := c_time_periods_rec.start_date;
	l_time_period(l_num_time_period).end_date := c_time_periods_rec.end_date;
      end loop;

    end;
    elsif p_event_type = 'BR' then
    begin

      for c_time_periods_rec in c_time_periods_br(g_pd_start_date(l_fte_index), g_pd_end_date(l_fte_index)) loop
	l_num_time_period := l_num_time_period + 1;
	l_time_period(l_num_time_period).time_period_id := c_time_periods_rec.time_period_id;
	l_time_period(l_num_time_period).start_date := c_time_periods_rec.start_date;
	l_time_period(l_num_time_period).end_date := c_time_periods_rec.end_date;
      end loop;

    end;
    end if;

    if l_num_time_period = 0 then
      message_token('STARTDATE', g_pd_start_date(l_fte_index));
      add_message('PSB', 'PSB_PQH_TIME_PERIOD_NOT_FOUND');
      raise FND_API.G_EXC_ERROR;
    end if;

    l_period_cost := g_pd_cost(l_fte_index);

    if l_num_time_period > 1 then
       l_period_cost := l_period_cost / l_num_time_period;
    end if;

    for l_index in 1..l_num_time_period loop

      if nvl(p_budget_unit1, 'X') = 'FTE' then
        /* Bug No 3670254 */
        -- assign assignment level FTE to the variable
        IF p_assignment_fte IS NOT NULL THEN
          l_budget_unit1_value := p_assignment_fte;
        ELSE
	  l_budget_unit1_value := g_pd_fte(l_fte_index);
	END IF;
	/* Bug No 3670254 */
      elsif nvl(p_budget_unit1, 'X') = 'MONEY' then
	l_budget_unit1_value := l_period_cost;
      end if;

      if nvl(p_budget_unit2, 'X') = 'FTE' then

	/* Bug No 3670254 */
        -- assign assignment level FTE to the variable
        IF p_assignment_fte IS NOT NULL THEN
          l_budget_unit2_value := p_assignment_fte;
        ELSE
	  l_budget_unit2_value := g_pd_fte(l_fte_index);
	END IF;
	/* Bug No 3670254 */

      elsif nvl(p_budget_unit2, 'X') = 'MONEY' then
	l_budget_unit2_value := l_period_cost;
      end if;

      if nvl(p_budget_unit3, 'X') = 'FTE' then

	/* Bug No 3670254 */
        -- assign assignment level FTE to the variable
        IF p_assignment_fte IS NOT NULL THEN
          l_budget_unit3_value := p_assignment_fte;
        ELSE
	  l_budget_unit3_value := g_pd_fte(l_fte_index);
	END IF;
	/* Bug No 3670254 */

      elsif nvl(p_budget_unit3, 'X') = 'MONEY' then
	l_budget_unit3_value := l_period_cost;
      end if;

      l_start_time_period_id := l_time_period(l_index).time_period_id;
      l_end_time_period_id := l_time_period(l_index).time_period_id;

      open c_pqh_budget_periods(l_start_time_period_id, l_end_time_period_id);

      fetch c_pqh_budget_periods into c_pqh_budget_periods_rec;

      if c_pqh_budget_periods%NOTFOUND then
      begin

	pqh_psb_interface_api.create_budget_period
	  (p_validate => false,
	   p_budget_period_id => l_pqh_budget_period_id,
	   p_budget_detail_id => p_pqh_budget_detail_id,
	   p_start_time_period_id => l_start_time_period_id,
	   p_end_time_period_id => l_end_time_period_id,
	   p_budget_unit1_value_type_cd => 'V',
	   p_budget_unit1_value => l_budget_unit1_value,
	   p_budget_unit2_value_type_cd => 'V',
	   p_budget_unit2_value => l_budget_unit2_value,
	   p_budget_unit3_value_type_cd => 'V',
	   p_budget_unit3_value => l_budget_unit3_value,
	   p_object_version_number => l_object_version_number);

      EXCEPTION
	WHEN OTHERS THEN
	  FND_MSG_PUB.Add;
	  message_token('POSITION', p_position_name);
	  add_message('PSB', 'PSB_PQH_CREATE_BUDGET_PERIOD');
	  raise FND_API.G_EXC_ERROR;
      end;
      else
	l_pqh_budget_period_id := c_pqh_budget_periods_rec.budget_period_id;

	begin

	  pqh_psb_interface_api.update_budget_period
	    (p_validate => false,
	     p_budget_period_id => c_pqh_budget_periods_rec.budget_period_id,
	     p_budget_detail_id => c_pqh_budget_periods_rec.budget_detail_id,
	     p_start_time_period_id => c_pqh_budget_periods_rec.start_time_period_id,
	     p_end_time_period_id => c_pqh_budget_periods_rec.end_time_period_id,
	     p_budget_unit1_value_type_cd => 'V',
	     p_budget_unit1_value => l_budget_unit1_value,
	     p_budget_unit2_value_type_cd => 'V',
	     p_budget_unit2_value => l_budget_unit2_value,
	     p_budget_unit3_value_type_cd => 'V',
	     p_budget_unit3_value => l_budget_unit3_value,
	     p_object_version_number => c_pqh_budget_periods_rec.object_version_number);

	EXCEPTION
	  when OTHERS then
	    FND_MSG_PUB.Add;
	    message_token('POSITION', p_position_name);
	    add_message('PSB', 'PSB_PQH_UPDATE_BUDGET_PERIOD');
	    raise FND_API.G_EXC_ERROR;
	end;
      end if;

      close c_pqh_budget_periods;

      l_budget_unit1_value := null;
      l_budget_unit2_value := null;
      l_budget_unit3_value := null;

       /*bug:7037138:start*/
          l_budget_set_cost := 0;
          l_bs_index := null;

        for l_index in l_start_ind..l_end_ind loop

          if g_period_start_date(l_index) = g_pd_start_date(l_fte_index) and
             g_period_end_date(l_index) = g_pd_end_date(l_fte_index) then
              l_budget_set_cost := g_budget_set_cost(l_index);
              l_bs_index := l_index;
              exit;
          end if;

        end loop;

        if l_bs_index is not null then
        /*bug:7037138:end*/

	if l_num_time_period > 1 then
	  l_budget_set_cost := l_budget_set_cost / l_num_time_period;
	end if;

	if nvl(p_budget_unit1, 'X') = 'MONEY' then
	  l_budget_unit1_value := l_budget_set_cost;
	end if;

	if nvl(p_budget_unit2, 'X') = 'MONEY' then
	  l_budget_unit2_value := l_budget_set_cost;
	end if;

	if nvl(p_budget_unit3, 'X') = 'MONEY' then
	  l_budget_unit3_value := l_budget_set_cost;
	end if;

   /*start bug:7037138: STATEMENT level logging*/
  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then

     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
    'PSB/UPLOAD_POS_CTRL/PSBVWPCB/Create_Pqh_Budget_Periods',
    'p_hr_position_id:'||p_hr_position_id||' and budget_set_id:'||g_budget_set_id(l_bs_index)||
    'start date:'||g_pd_start_date(l_fte_index)||' and end date:'||g_pd_end_date(l_fte_index));

        /*fnd_file.put_line(fnd_file.LOG,'p_hr_position_id:'||p_hr_position_id||' and budget_set_id:'||g_budget_set_id(l_bs_index)||
                                       'start date:'||g_pd_start_date(l_fte_index)||' and end date:'||g_pd_end_date(l_fte_index));--bug:7037138
        */
   end if;
   /*end bug:7037138:end STATEMENT level log*/

	open c_pqh_budget_sets (g_budget_set_id(l_bs_index));

	fetch c_pqh_budget_sets into c_pqh_budget_sets_rec;

	if c_pqh_budget_sets%NOTFOUND then
	begin

	  pqh_psb_interface_api.create_budget_set
	    (p_validate => false,
	     p_budget_set_id => l_pqh_budget_set_id,
	     p_dflt_budget_set_id => g_budget_set_id(l_bs_index),
	     p_budget_period_id => l_pqh_budget_period_id,
	     p_budget_unit1_value_type_cd => 'V',
	     p_budget_unit1_value => l_budget_unit1_value,
	     p_budget_unit2_value_type_cd => 'V',
	     p_budget_unit2_value => l_budget_unit2_value,
	     p_budget_unit3_value_type_cd => 'V',
	     p_budget_unit3_value => l_budget_unit3_value,
	     p_object_version_number => l_set_obj_ver_num,
	     p_effective_date => sysdate);

	EXCEPTION
	  when OTHERS then
	    FND_MSG_PUB.Add;
	    message_token('POSITION', p_position_name);
	    add_message('PSB', 'PSB_PQH_CREATE_BUDGET_SET');
	    raise FND_API.G_EXC_ERROR;

	end;
	else

	  l_pqh_budget_set_id := c_pqh_budget_sets_rec.budget_set_id;

	  begin

	    pqh_psb_interface_api.update_budget_set
	       (p_validate => false,
		p_budget_set_id => c_pqh_budget_sets_rec.budget_set_id,
		p_dflt_budget_set_id => g_budget_set_id(l_bs_index),
		p_budget_period_id => l_pqh_budget_period_id,
		p_budget_unit1_value_type_cd => 'V',
		p_budget_unit1_value => l_budget_unit1_value,
		p_budget_unit2_value_type_cd => 'V',
		p_budget_unit2_value => l_budget_unit2_value,
		p_budget_unit3_value_type_cd => 'V',
		p_budget_unit3_value => l_budget_unit3_value,
		p_object_version_number => c_pqh_budget_sets_rec.object_version_number,
		p_effective_date => sysdate);

	  EXCEPTION
	    when OTHERS then
	      FND_MSG_PUB.Add;
	      message_token('POSITION', p_position_name);
	      add_message('PSB', 'PSB_PQH_UPDATE_BUDGET_SET');
	      raise FND_API.G_EXC_ERROR;
	  end;
	end if;

	close c_pqh_budget_sets;

	Create_Pqh_Budget_Elements
	     (p_return_status => l_return_status,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
	      p_event_type => p_event_type,
	      p_source_id => p_source_id,
	      p_business_group_id => p_business_group_id,
	      p_currency_code => p_currency_code,
	      p_system_data_extract_id => p_system_data_extract_id,
	      p_gl_flex_code => p_gl_flex_code,
	      p_pqh_budget_set_id => l_pqh_budget_set_id,
	      p_dflt_budget_set_id => g_budget_set_id(l_bs_index),
	      p_hr_position_id => p_hr_position_id,
	      p_payroll_id => p_payroll_id,
	      p_hr_budget_id => p_hr_budget_id,
	      p_position_name => p_position_name,
	      p_hr_employee_id => p_hr_employee_id,
	      p_effective_start_date => p_effective_start_date,
	      p_period_start_date => g_pd_start_date(l_fte_index),
	      p_period_end_date => g_pd_end_date(l_fte_index),
	      p_num_segments => p_num_segments,
	      p_id_flex_num => p_id_flex_num);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end if;

    end loop;

   end loop; /*End of fte Bulk fetch index loop*/


  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     if c_period_rec%ISOPEN then
       close c_period_rec;
     end if;
     if c_budget_set_cost%ISOPEN then
       close c_budget_set_cost;
     end if;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     if c_period_rec%ISOPEN then
       close c_period_rec;
     end if;
     if c_budget_set_cost%ISOPEN then
       close c_budget_set_cost;
     end if;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     if c_period_rec%ISOPEN then
       close c_period_rec;
     end if;
     if c_budget_set_cost%ISOPEN then
       close c_budget_set_cost;
     end if;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Create_Pqh_Budget_Periods;

/* ----------------------------------------------------------------------- */

PROCEDURE Map_Segments
(p_return_status  OUT  NOCOPY  VARCHAR2,
 p_position_name  IN   VARCHAR2,
 p_payroll_id     IN   NUMBER,
 p_sob_id         IN   NUMBER) IS

 l_payroll_name   VARCHAR2(80);
 l_index          BINARY_INTEGER := 0;

  cursor c_map_segments is
    select *
      from pay_payroll_gl_flex_maps
     where payroll_id = p_payroll_id
       and gl_set_of_books_id = p_sob_id;

  cursor c_payroll_name is
    /* Changed to pay_all_payrolls_f as part of Bug 2519492 */
    select payroll_name from pay_all_payrolls_f where payroll_id = p_payroll_id;

BEGIN

  g_map_str := NULL;

  for i in 1..30 loop
    g_map_tab(i).cost_segment_name := null;
  end loop;

  l_index := 0;

  for c_map_segments_rec in c_map_segments loop

    /*For Bug No : 2434152 Start*/
    IF c_map_segments_rec.payroll_cost_segment IS NOT NULL THEN
      IF g_map_str IS NULL THEN
	g_map_str := 'SELECT cost_allocation_keyflex_id '||
		      ' FROM pay_cost_allocation_keyflex cakf, gl_code_combinations glcc '||
		     ' WHERE cakf.id_flex_num = :b1 '||
		       ' AND cakf.'||c_map_segments_rec.payroll_cost_segment ||' = glcc.'||c_map_segments_rec.gl_account_segment ;
      ELSE
	g_map_str := g_map_str || ' AND cakf.'||c_map_segments_rec.payroll_cost_segment ||' = glcc.'||c_map_segments_rec.gl_account_segment ;
      END IF ;
    END IF ;
    /*For Bug No : 2434152 End*/

    l_index := l_index + 1;

    -- Prepare for later query to get cff id from cost allocation FF table.
    IF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT1' THEN
      g_map_tab(1).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(1).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT2' THEN
      g_map_tab(2).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(2).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT3' THEN
      g_map_tab(3).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(3).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT4' THEN
      g_map_tab(4).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(4).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT5' THEN
      g_map_tab(5).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(5).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT6' THEN
      g_map_tab(6).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(6).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT7' THEN
      g_map_tab(7).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(7).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT8' THEN
      g_map_tab(8).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(8).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT9' THEN
      g_map_tab(9).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(9).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT10' THEN
      g_map_tab(10).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(10).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT11' THEN
      g_map_tab(11).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(11).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT12' THEN
      g_map_tab(12).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(12).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT13' THEN
      g_map_tab(13).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(13).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT14' THEN
      g_map_tab(14).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(14).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT15' THEN
      g_map_tab(15).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(15).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT16' THEN
      g_map_tab(16).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(16).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT17' THEN
      g_map_tab(17).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(17).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT18' THEN
      g_map_tab(18).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(18).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT19' THEN
      g_map_tab(19).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(19).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT20' THEN
      g_map_tab(20).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(20).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT21' THEN
      g_map_tab(21).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(21).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT22' THEN
      g_map_tab(22).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(22).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT23' THEN
      g_map_tab(23).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(23).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT24' THEN
      g_map_tab(24).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(24).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT25' THEN
      g_map_tab(25).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(25).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT26' THEN
      g_map_tab(26).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(26).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT27' THEN
      g_map_tab(27).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(27).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT28' THEN
      g_map_tab(28).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(28).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT29' THEN
      g_map_tab(29).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(29).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    ELSIF c_map_segments_rec.PAYROLL_COST_SEGMENT = 'SEGMENT30' THEN
      g_map_tab(30).gl_segment_name   := c_map_segments_rec.GL_ACCOUNT_SEGMENT;
      g_map_tab(30).cost_segment_name := c_map_segments_rec.PAYROLL_COST_SEGMENT;
    END IF;

  end loop;

  if l_index = 0 then
  begin

    for c_payroll_rec in c_payroll_name loop
      l_payroll_name := c_payroll_rec.payroll_name;
      /* Bug 2519492 Start */
      exit;
      /* Bug 2519492 End */
    end loop;

    message_token('POSITION', p_position_name);
    message_token('PAYROLL', l_payroll_name);
    add_message('PSB', 'PSB_PQH_NO_PAYROLL_MAPPING');
    raise FND_API.G_EXC_ERROR;

  end;
  end if;

  /*For Bug No : 2434152 Start*/
  g_map_str := g_map_str||' AND glcc.code_combination_id= :b2' ;
  /*For Bug No : 2434152 End*/

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Map_Segments;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Pqh_Budget_Detail
( p_return_status          OUT  NOCOPY  VARCHAR2,
  p_msg_count              OUT  NOCOPY  NUMBER,
  p_msg_data               OUT  NOCOPY  VARCHAR2,
  p_event_type             IN   VARCHAR2,
  p_source_id              IN   NUMBER,
  p_currency_code          IN   VARCHAR2,
  p_business_group_id      IN   NUMBER,
  p_data_extract_id        IN   NUMBER,
  p_system_data_extract_id IN   NUMBER,
  p_gl_flex_code           IN   NUMBER,
  p_hr_budget_id           IN   NUMBER,
  p_pqh_budget_name        IN   VARCHAR2,
  p_pqh_budget_version_id  IN   NUMBER,
  p_start_date             IN   DATE,
  p_end_date               IN   DATE,
  p_budget_unit1           IN   VARCHAR2,
  p_budget_unit2           IN   VARCHAR2,
  p_budget_unit3           IN   VARCHAR2,
  p_budget_unit1_aggregate IN   VARCHAR2,
  p_budget_unit2_aggregate IN   VARCHAR2,
  p_budget_unit3_aggregate IN   VARCHAR2,
  p_id_flex_num            IN   NUMBER) IS

  l_budget_unit1_value          NUMBER;
  l_budget_unit2_value          NUMBER;
  l_budget_unit3_value          NUMBER;
  l_orig_budget_unit1_value     NUMBER;
  l_orig_budget_unit2_value     NUMBER;
  l_orig_budget_unit3_value     NUMBER;
  l_period_avg_value            NUMBER;
  l_change_fte_value            NUMBER;
  l_object_version_number       pqh_psb_budget_details.object_version_number%TYPE;
  l_new_object_version_number   pqh_psb_budget_details.object_version_number%TYPE;
  l_pqh_budget_detail_id        NUMBER;
  l_total_cost                  NUMBER := 0;
  l_revision_amount             NUMBER := 0;
  l_position_id                 NUMBER;
  l_att_position_id             NUMBER;
  l_org_id                      NUMBER;
  l_job_id                      NUMBER;
  l_hr_employee_id              NUMBER;
  l_position_name               VARCHAR2(240);
  l_effective_start_date        DATE;
  l_ver_object_version_number   pqh_psb_budget_versions.object_version_number%TYPE;
  l_version_number              NUMBER;
  l_start_date                  DATE;
  l_end_date                    DATE;
  l_payroll_id                  NUMBER;
  l_return_status               VARCHAR2(1);

   /*Start for bug#5634778*/
  l_temp_fte_attribute_value    NUMBER;
   /*End for bug#5634778*/

  /*For Bug No : 2434152 Start*/
  l_prev_payroll_id             NUMBER := -1;
  l_position_ctr                NUMBER := 0;

  TYPE id_arr IS TABLE OF NUMBER(15);
  TYPE num_arr IS TABLE OF NUMBER;

  TYPE pos_rec IS RECORD (hr_position_id id_arr, fte num_arr, cost num_arr);
  l_positions                   pos_rec;
  l_num_segments                NUMBER;
  l_sob_id                      NUMBER;
  /*For Bug No : 2434152 End*/

  cursor c_position is
    select a.fte_position_id, a.fte, b.cost
      from
	  (
	   select pp.hr_position_id fte_position_id, sum(avg_fte) fte
	     from
		 (select pp.position_id, avg(ppf.fte) avg_fte
		    from psb_positions pp, psb_position_fte ppf
		   where ppf.position_id = pp.position_id
		     and ppf.base_line_version = 'C'
		     and ppf.hr_budget_id = p_hr_budget_id
		     and ((ppf.start_date between p_start_date and p_end_date)
		       or (ppf.end_date between p_start_date and p_end_date)
		       or ((ppf.start_date < p_start_date) and (ppf.end_date > p_end_date)))
		   group by pp.position_id) pf, psb_positions pp
	     where pp.data_extract_id = p_system_data_extract_id
	       and pp.position_id = pf.position_id
	     group by pp.hr_position_id
	  ) a,
	  (
	   select pp.hr_position_id cost_position_id, sum(ppc.element_cost) cost
	     from psb_position_costs ppc, psb_positions pp
	    where pp.data_extract_id = p_system_data_extract_id
	      and ppc.hr_budget_id = p_hr_budget_id
	      and ppc.position_id = pp.position_id
	      and ppc.base_line_version = 'C'
	      and ppc.currency_code = p_currency_code
	      and ((ppc.start_date between p_start_date and p_end_date)
		or (ppc.end_date between p_start_date and p_end_date)
		or ((ppc.start_date < p_start_date) and (ppc.end_date > p_end_date)))
	     group by pp.hr_position_id
	   ) b
     where a.fte_position_id = b.cost_position_id;

  cursor c_hr_position (positionid NUMBER) is
    select position_id, hr_employee_id, name, effective_start_date
      from psb_positions
     where data_extract_id = decode(p_event_type, 'BP', p_data_extract_id, p_system_data_extract_id)
       and hr_position_id = positionid;
 /* Start for the bug#5634778 */
  -- Commented the below line to select all the positions for a particular HR position.
  --       and rownum < 2;
 /* End for the bug#5634778 */

  cursor c_att_position (positionid NUMBER) is
    select position_id
      from psb_positions
     where data_extract_id = p_system_data_extract_id
       and hr_position_id = positionid
       and rownum < 2;

  cursor c_pqh_budget_details(positionid NUMBER) is
    select *
      from pqh_psb_budget_details
     where budget_version_id = p_pqh_budget_version_id
       and position_id = positionid;

  cursor c_pqh_budget_details_new is
    select *
      from pqh_psb_budget_details
     where budget_version_id = p_pqh_budget_version_id
       and budget_detail_id = l_pqh_budget_detail_id;

  cursor c_position_cost_br (positionid NUMBER) is
    select sum(decode(b.revision_type, 'I', b.revision_amount,
				       'D', -b.revision_amount)) revision_amount
      from psb_budget_revision_lines a,
	   psb_budget_revision_accounts b,
	   psb_positions pp
     where a.budget_revision_id = p_source_id
       and b.budget_revision_acct_line_id = a.budget_revision_acct_line_id
       and pp.position_id = b.position_id
       and pp.data_extract_id = p_system_data_extract_id
       and pp.hr_position_id = positionid;

  cursor c_job(positionid NUMBER) is
    select a.attribute_id, a.attribute_value_id, c.attribute_value , hr_value_id
      from psb_position_assignments a,
	   psb_attributes b,
	   psb_attribute_values c
     where a.position_id  = positionid
       and a.data_extract_id = p_system_data_extract_id -- system_data_extract_id
       and a.attribute_id = b.attribute_id
       and b.system_attribute_type = 'JOB_CLASS'
       and c.attribute_value_id = a.attribute_value_id
       and c.data_extract_id = p_system_data_extract_id;

  cursor c_org(positionid NUMBER) is
    select a.attribute_id, a.attribute_value_id, c.attribute_value , hr_value_id
      from psb_position_assignments a,
	   psb_attributes b,
	   psb_attribute_values c
     where a.position_id  = positionid
       and a.data_extract_id = p_system_data_extract_id -- system_data_extract_id
       and a.attribute_id = b.attribute_id
       and b.system_attribute_type = 'ORG'
       and c.attribute_value_id = a.attribute_value_id
       and c.data_extract_id = p_system_data_extract_id;

  cursor c_version_details  is
    select *
      from pqh_psb_budget_versions
     where budget_version_id = p_pqh_budget_version_id;

  /*For Bug No : 2434152 Start*/
  cursor c_sob_id is
    select set_of_books_id
     from psb_data_extracts
    where data_extract_id = p_system_data_extract_id;
  /*For Bug No : 2434152 End*/

  c_pqh_budget_details_rec      c_pqh_budget_details%ROWTYPE;

  /* bug no 3670254 */
  -- local variable to hold assignment level FTE
  l_fte_attribute_value    NUMBER;
  /* bug no 3670254 */

  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_api_name               CONSTANT VARCHAR2(30)   := 'Create_Pqh_Budget_Detail';

BEGIN

  /*For Bug No : 2434152 Start*/
  for c_sob_id_rec in c_sob_id loop
    l_sob_id := c_sob_id_rec.set_of_books_id;
  end loop;
  /*For Bug No : 2434152 End*/

  l_change_fte_value := 0;

  open c_position;
  loop

    fetch c_position BULK COLLECT INTO l_positions.hr_position_id, l_positions.fte, l_positions.cost LIMIT g_limit_bulk_numrows;

    for l_position_index in 1..l_positions.hr_position_id.count loop

       /* Start bug#5634778*/
          l_temp_fte_attribute_value := NULL;
       /* End of bug#5634778*/

      /*For Bug No : 2434152 Start*/
      l_position_ctr := l_position_ctr + 1;
      /*For Bug No : 2434152 End*/

      for c_hr_position_rec in c_hr_position (l_positions.hr_position_id(l_position_index)) loop
	l_position_id := c_hr_position_rec.position_id;
	l_hr_employee_id := c_hr_position_rec.hr_employee_id;
	l_position_name := c_hr_position_rec.name;
	l_effective_start_date := c_hr_position_rec.effective_start_date;
       /*For Bug No : 2292003 Start*/
       --end loop is moved to end of the procedure
       --end loop;

       /*l_att_position_id := null;
       for c_att_position_rec in c_att_position(l_positions.hr_position_id(l_position_index)) loop
	 l_att_position_id := c_att_position_rec.position_id;
       end loop;*/
       /*For Bug No : 2292003 End*/

       if (Position_Exists(p_event_type => p_event_type, p_source_id => p_source_id,
	   p_position_id => l_position_id)) then
       begin

	 /*For Bug No : 2292003 Start*/
	 l_att_position_id := null;
	 for c_att_position_rec in c_att_position(l_positions.hr_position_id(l_position_index)) loop
	   l_att_position_id := c_att_position_rec.position_id;
	 end loop;
	 /*For Bug No : 2292003 End*/

	 /*For Bug No : 2292003 Start*/
	 --added the p_effective_end_date in the following
	 --call of the procedure and changed the date parameters also
	 l_payroll_id := Get_Payroll(p_hr_position_id => l_positions.hr_position_id(l_position_index), p_data_extract_id => p_system_data_extract_id,
				     p_effective_start_date => p_start_date,
				     p_effective_end_date   => p_end_date);
	 /*For Bug No : 2292003 End*/

	 if l_payroll_id is null then
	   message_token('POSITION', l_position_name);
	   add_message('PSB', 'PSB_PQH_POSITION_NO_PAYROLL');
	   raise FND_API.G_EXC_ERROR;
	 end if;

	 /*For Bug No : 2434152 Start*/
	 if ((l_prev_payroll_id = -1) or (l_prev_payroll_id <> l_payroll_id)) then
	   l_prev_payroll_id := l_payroll_id;
	   Map_Segments (p_payroll_id => l_payroll_id, p_sob_id => l_sob_id, p_position_name => l_position_name, p_return_status => l_return_status);
	 end if;
	 /*For Bug No : 2434152 End*/

	 if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	   raise FND_API.G_EXC_ERROR;
	 end if;

	 Distribute_Position_Cost
		   (p_return_status => l_return_status,
		    p_event_type => p_event_type,
		    p_source_id => p_source_id,
		    p_hr_budget_id => p_hr_budget_id,
		    p_data_extract_id => p_system_data_extract_id,
		    p_gl_flex_code => p_gl_flex_code,
		    p_currency_code => p_currency_code,
		    p_hr_position_id => l_positions.hr_position_id(l_position_index),
		    p_start_date => p_start_date,
		    p_end_date => p_end_date);

	 if l_return_status <> FND_API.G_RET_STS_SUCCESS then
           /* Start Bug 3666828 */
	   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Position Name : '||l_position_name||' Position ID :'||l_positions.hr_position_id(l_position_index));
	   /* End Bug 3666828 */

	   raise FND_API.G_EXC_ERROR;
	 end if;

	 l_org_id := null;
	 l_job_id := null;

	 for c_job_rec in c_job(l_att_position_id) loop
	   l_job_id := c_job_rec.hr_value_id;
	 end loop;

	 for c_org_rec in c_org(l_att_position_id) loop
	   l_org_id := c_org_rec.hr_value_id;
	 end loop;

	 if p_event_type = 'BP' then
	 begin

	   l_total_cost := l_positions.cost(l_position_index);

           /* bug no 3670254 */
           -- get assignment level FTE is the profile value is
           -- 'ASSIGNMENT'.
           IF g_hrms_fte_upload_option = 'ASSIGNMENT' THEN
             l_fte_attribute_value := NULL;

             FOR l_ass_fte_rec IN g_ass_fte_csr
               ( c_data_extract_id      => p_data_extract_id ,
                 c_position_id          => l_position_id     ,
                 c_worksheet_id         => p_source_id       ,
                 c_attribute_id         => g_fte_attribute_id    ,
                 c_budget_year_end_date => p_end_date
               )
	     LOOP
   	       l_fte_attribute_value := l_ass_fte_rec.attribute_value;
       /* Start bug#5634778*/
   	       l_temp_fte_attribute_value := NVL(l_temp_fte_attribute_value,0) + NVL(l_fte_attribute_value,0);
       /* End of bug#5634778*/
      	     END LOOP;

      	     IF l_fte_attribute_value IS NULL THEN
      	       FOR l_ass_fte_rec IN g_ass_fte_csr
                 ( c_data_extract_id       => p_data_extract_id ,
                   c_position_id           => l_position_id     ,
                   c_worksheet_id          => NULL              ,
                   c_attribute_id          => g_fte_attribute_id    ,
                   c_budget_year_end_date  => p_end_date
                 )
	       LOOP
    	         l_fte_attribute_value := l_ass_fte_rec.attribute_value;
       /* Start bug#5634778*/
   	           l_temp_fte_attribute_value := NVL(l_temp_fte_attribute_value,0) + NVL(l_fte_attribute_value,0);
       /* End of bug#5634778*/
      	       END LOOP;
      	     END IF;
             -- get the attribute value
      	     l_fte_attribute_value := Nvl(l_fte_attribute_value,0);
           END IF;
           /* bug no 3670254 */

     /*Start for bug#5634778*/
       l_fte_attribute_value:= l_temp_fte_attribute_value;
     /*End for bug#5634778*/

	   if nvl(p_budget_unit1, 'X') = 'FTE' then
             /* bug 3670254 */
             -- assign assignment level FTE to local variable
	     IF g_hrms_fte_upload_option = 'ASSIGNMENT' THEN
                 l_budget_unit1_value := l_fte_attribute_value;
             ELSE
	         l_budget_unit1_value := l_positions.fte(l_position_index);
             END IF;
             /* bug no 3670254 */

	   elsif nvl(p_budget_unit1, 'X') = 'MONEY' then
	     l_budget_unit1_value := l_total_cost;
	   end if;

	   if nvl(p_budget_unit2, 'X') = 'FTE' then
	     /* bug 3670254 */
             -- assign assignment level FTE to local variable
	     IF g_hrms_fte_upload_option = 'ASSIGNMENT' THEN
                 l_budget_unit2_value := l_fte_attribute_value;
             ELSE
	         l_budget_unit2_value := l_positions.fte(l_position_index);
             END IF;
             /* bug no 3670254 */
	   elsif nvl(p_budget_unit2, 'X') = 'MONEY' then
	     l_budget_unit2_value := l_total_cost;
	   end if;

	   if nvl(p_budget_unit3, 'X') = 'FTE' then

	     /* bug 3670254 */
             -- assign assignment level FTE to local variable
	     IF g_hrms_fte_upload_option = 'ASSIGNMENT' THEN
                 l_budget_unit3_value := l_fte_attribute_value;
             ELSE
	         l_budget_unit3_value := l_positions.fte(l_position_index);
             END IF;
             /* bug no 3670254 */

	   elsif nvl(p_budget_unit3, 'X') = 'MONEY' then
	     l_budget_unit3_value := l_total_cost;
	   end if;

	 end;
	 elsif p_event_type = 'BR' then
	 begin

	   for c_position_cost_rec in c_position_cost_br(l_positions.hr_position_id(l_position_index)) loop
	     l_revision_amount := c_position_cost_rec.revision_amount;
	   end loop;

	 end;
	 end if;

	 open c_pqh_budget_details(l_positions.hr_position_id(l_position_index));

	 fetch c_pqh_budget_details into c_pqh_budget_details_rec;

	 if c_pqh_budget_details%NOTFOUND then
	 begin

	   if p_event_type = 'BR' then
	   begin

	     if nvl(p_budget_unit1, 'X') = 'FTE' then
	       l_budget_unit1_value := l_positions.fte(l_position_index);
	     elsif nvl(p_budget_unit1, 'X') = 'MONEY' then
	       l_budget_unit1_value := l_revision_amount;
	     end if;

	     if nvl(p_budget_unit2, 'X') = 'FTE' then
	       l_budget_unit2_value := l_positions.fte(l_position_index);
	     elsif nvl(p_budget_unit2, 'X') = 'MONEY' then
	       l_budget_unit2_value := l_revision_amount;
	     end if;

	     if nvl(p_budget_unit3, 'X') = 'FTE' then
	       l_budget_unit3_value := l_positions.fte(l_position_index);
	     elsif nvl(p_budget_unit3, 'X') = 'MONEY' then
	       l_budget_unit3_value := l_revision_amount;
	     end if;

	   end;
	   end if;

	   pqh_psb_interface_api.create_budget_detail
	      (p_validate => false,
	       p_budget_detail_id => l_pqh_budget_detail_id,
	       p_position_id => l_positions.hr_position_id(l_position_index),
	       p_job_id => l_job_id,
	       p_organization_id => l_org_id,
	       p_budget_version_id => p_pqh_budget_version_id,
	       p_budget_unit1_value_type_cd => 'V',
	       p_budget_unit1_value => l_budget_unit1_value,
	       p_budget_unit2_value_type_cd => 'V',
	       p_budget_unit2_value => l_budget_unit2_value,
	       p_budget_unit3_value_type_cd => 'V',
	       p_budget_unit3_value => l_budget_unit3_value,
	       p_object_version_number => l_object_version_number);

	 EXCEPTION
	   WHEN OTHERS THEN
	     FND_MSG_PUB.Add;
	     message_token('POSITION', l_position_name);
	     add_message('PSB', 'PSB_PQH_CREATE_BUDGET_DETAIL');
	     raise FND_API.G_EXC_ERROR;

	 end;
	 else
	 begin

	   if p_event_type = 'BR' then
	   begin

	     if nvl(p_budget_unit1, 'X') = 'FTE' then
	       l_budget_unit1_value := l_positions.fte(l_position_index);
	     elsif nvl(p_budget_unit1, 'X') = 'MONEY' then
	       l_budget_unit1_value := c_pqh_budget_details_rec.budget_unit1_value + l_revision_amount;
	     end if;

	     if nvl(p_budget_unit2, 'X') = 'FTE' then
	       l_budget_unit2_value := l_positions.fte(l_position_index);
	     elsif nvl(p_budget_unit2, 'X') = 'MONEY' then
	       l_budget_unit2_value := c_pqh_budget_details_rec.budget_unit2_value + l_revision_amount;
	     end if;

	     if nvl(p_budget_unit3, 'X') = 'FTE' then
	       l_budget_unit3_value := l_positions.fte(l_position_index);
	     elsif nvl(p_budget_unit3, 'X') = 'MONEY' then
	       l_budget_unit3_value := c_pqh_budget_details_rec.budget_unit3_value + l_revision_amount;
	     end if;

	   end;
	   end if;

	   l_pqh_budget_detail_id := c_pqh_budget_details_rec.budget_detail_id;
	   l_object_version_number := c_pqh_budget_details_rec.object_version_number;

	   pqh_psb_interface_api.update_budget_detail
	     (p_validate => false,
	      p_budget_detail_id => c_pqh_budget_details_rec.budget_detail_id,
	      p_position_id => l_positions.hr_position_id(l_position_index),
	      p_job_id => l_job_id,
	      p_organization_id => l_org_id,
	      p_budget_version_id => c_pqh_budget_details_rec.budget_version_id,
	      p_budget_unit1_value_type_cd => 'V',
	      p_budget_unit1_value => l_budget_unit1_value,
	      p_budget_unit2_value_type_cd => 'V',
	      p_budget_unit2_value => l_budget_unit2_value,
	      p_budget_unit3_value_type_cd => 'V',
	      p_budget_unit3_value => l_budget_unit3_value,
	      p_object_version_number => c_pqh_budget_details_rec.object_version_number);

	 EXCEPTION
	   when OTHERS then
	     FND_MSG_PUB.Add;
	     message_token('POSITION', l_position_name);
	     add_message('PSB', 'PSB_PQH_UPDATE_BUDGET_DETAIL');
	     raise FND_API.G_EXC_ERROR;

	 end;
	 end if;

	 close c_pqh_budget_details;

	 Create_Pqh_Budget_Periods
	       (p_return_status => l_return_status,
                p_msg_count => l_msg_count,
                p_msg_data => l_msg_data,
		p_event_type => p_event_type,
		p_source_id   => p_source_id,
		p_hr_budget_id  => p_hr_budget_id,
		p_business_group_id => p_business_group_id,
		p_currency_code => p_currency_code,
		p_data_extract_id => p_data_extract_id,    --bug:7037138
		p_system_data_extract_id => p_system_data_extract_id,
		p_gl_flex_code => p_gl_flex_code,
		p_start_date => p_start_date,
		p_end_date => p_end_date,
		p_pqh_budget_detail_id => l_pqh_budget_detail_id,
		p_hr_position_id => l_positions.hr_position_id(l_position_index),
		p_payroll_id => l_payroll_id,
		p_position_name => l_position_name,
		p_hr_employee_id => l_hr_employee_id,
		p_effective_start_date => l_effective_start_date,
		p_budget_unit1 => p_budget_unit1,
		p_budget_unit2 => p_budget_unit2,
		p_budget_unit3 => p_budget_unit3,
		p_num_segments => l_num_segments,
		p_id_flex_num => p_id_flex_num ,
                /* bug no 3670254 */
                -- passing assignment level FTE to parameter
                -- if profile value is PERIOD, then attribute value is null
                -- and data flows according to existing system functionality.
                p_assignment_fte => l_fte_attribute_value);

	 if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	   raise FND_API.G_EXC_ERROR;
	 end if;

	 if p_event_type = 'BR' then
	 begin

	   if ((nvl(p_budget_unit1_aggregate, 'X') = 'AVERAGE') or (nvl(p_budget_unit2_aggregate, 'X') = 'AVERAGE') or
	       (nvl(p_budget_unit3_aggregate, 'X') = 'AVERAGE')) then
	   begin

	     l_period_avg_value := 0;

	     for c_pqh_budget_details_rec_new in c_pqh_budget_details_new loop
		 l_new_object_version_number := c_pqh_budget_details_rec_new.object_version_number;
	     end loop;

	     if (nvl(p_budget_unit1, 'X') = 'FTE' and nvl(p_budget_unit1_aggregate, 'X') = 'AVERAGE') then
	     begin

	       for c_period_avg_rec in
		  (select avg(budget_unit1_value) period_avg_value
		     from pqh_psb_budget_periods
		    where budget_detail_id = l_pqh_budget_detail_id) loop
		 l_period_avg_value := c_period_avg_rec.period_avg_value;
	       end loop;

	       begin

		 pqh_psb_interface_api.update_budget_detail
		    (p_validate => false,
		     p_budget_detail_id => l_pqh_budget_detail_id,
		     p_position_id => l_positions.hr_position_id(l_position_index),
		     p_budget_version_id => p_pqh_budget_version_id,
		     p_budget_unit1_value_type_cd => 'V',
		     p_budget_unit1_value => l_period_avg_value,
		     p_object_version_number => l_new_object_version_number);

	       EXCEPTION
		 when OTHERS then
		   FND_MSG_PUB.Add;
		   message_token('POSITION', l_position_name);
		   add_message('PSB', 'PSB_PQH_UPDATE_BUDGET_DETAIL');
		   raise FND_API.G_EXC_ERROR;

	       end;

	       l_change_fte_value := l_change_fte_value + (l_period_avg_value - l_budget_unit1_value);

	     end;
	     elsif (nvl(p_budget_unit2, 'X') = 'FTE' and nvl(p_budget_unit2_aggregate, 'X') = 'AVERAGE') then
	     begin

	       for c_period_avg_rec in
		  (select avg(budget_unit2_value) period_avg_value
		     from pqh_psb_budget_periods
		    where budget_detail_id = l_pqh_budget_detail_id) loop
		 l_period_avg_value := c_period_avg_rec.period_avg_value;
	       end loop;

	       begin

		 pqh_psb_interface_api.update_budget_detail
		    (p_validate => false,
		     p_budget_detail_id => l_pqh_budget_detail_id,
		     p_position_id => l_positions.hr_position_id(l_position_index),
		     p_budget_version_id => p_pqh_budget_version_id,
		     p_budget_unit2_value_type_cd => 'V',
		     p_budget_unit2_value => l_period_avg_value,
		     p_object_version_number => l_new_object_version_number);

	       EXCEPTION
		 when OTHERS then
		   FND_MSG_PUB.Add;
		   message_token('POSITION', l_position_name);
		   add_message('PSB', 'PSB_PQH_UPDATE_BUDGET_DETAIL');
		   raise FND_API.G_EXC_ERROR;

	       end;

	       l_change_fte_value := l_change_fte_value + (l_period_avg_value - l_budget_unit2_value);

	     end;
	     elsif (nvl(p_budget_unit3, 'X') = 'FTE' and nvl(p_budget_unit3_aggregate, 'X') = 'AVERAGE') then
	     begin

	       for c_period_avg_rec in
		  (select avg(budget_unit3_value) period_avg_value
		     from pqh_psb_budget_periods
		    where budget_detail_id = l_pqh_budget_detail_id) loop
		 l_period_avg_value := c_period_avg_rec.period_avg_value;
	       end loop;

	       begin

		 pqh_psb_interface_api.update_budget_detail
		    (p_validate => false,
		     p_budget_detail_id => l_pqh_budget_detail_id,
		     p_position_id => l_positions.hr_position_id(l_position_index),
		     p_budget_version_id => p_pqh_budget_version_id,
		     p_budget_unit3_value_type_cd => 'V',
		     p_budget_unit3_value => l_period_avg_value,
		     p_object_version_number => l_new_object_version_number);

	       EXCEPTION
		 when OTHERS then
		   FND_MSG_PUB.Add;
		   message_token('POSITION', l_position_name);
		   add_message('PSB', 'PSB_PQH_UPDATE_BUDGET_DETAIL');
		   raise FND_API.G_EXC_ERROR;

	       end;

	       l_change_fte_value := l_change_fte_value + (l_period_avg_value - l_budget_unit3_value);

	     end;
	     end if;

	     for c_version_details_rec in c_version_details loop
	       l_ver_object_version_number := c_version_details_rec.object_version_number;
	       l_version_number := c_version_details_rec.version_number;
	       l_start_date := c_version_details_rec.date_from;
	       l_end_date := c_version_details_rec.date_to;
	       l_orig_budget_unit1_value := c_version_details_rec.budget_unit1_value;
	       l_orig_budget_unit2_value := c_version_details_rec.budget_unit2_value;
	       l_orig_budget_unit3_value := c_version_details_rec.budget_unit3_value;
	     end loop;

	     if (nvl(p_budget_unit1, 'X') = 'FTE' and nvl(p_budget_unit1_aggregate, 'X') = 'AVERAGE') then
	       l_orig_budget_unit1_value := l_orig_budget_unit1_value + l_change_fte_value;
	     elsif (nvl(p_budget_unit2, 'X') = 'FTE' and nvl(p_budget_unit2_aggregate, 'X') = 'AVERAGE') then
	       l_orig_budget_unit2_value := l_orig_budget_unit2_value + l_change_fte_value;
	     elsif (nvl(p_budget_unit3, 'X') = 'FTE' and nvl(p_budget_unit3_aggregate, 'X') = 'AVERAGE') then
	       l_orig_budget_unit3_value := l_orig_budget_unit3_value + l_change_fte_value;
	     end if;

	     begin

	       pqh_psb_interface_api.update_budget_version
		 (p_validate              => false,
		  p_budget_id             => p_hr_budget_id,
		  p_budget_version_id     => p_pqh_budget_version_id,
		  p_version_number        => l_version_number,
		  p_object_version_number => l_ver_object_version_number,
		  p_date_from             => l_start_date,
		  p_date_to               => l_end_date,
		  p_transfered_to_gl_flag => 'N',
		  p_xfer_to_other_apps_cd => 'N',
		  p_budget_unit1_value    => l_orig_budget_unit1_value,
		  p_budget_unit2_value    => l_orig_budget_unit2_value,
		  p_budget_unit3_value    => l_orig_budget_unit3_value,
		  p_effective_date        => sysdate);

	     EXCEPTION
	       when OTHERS then
		 FND_MSG_PUB.Add;
		 message_token('BUDGET', p_pqh_budget_name);
		 message_token('VERSION', l_version_number);
		 message_token('STARTDATE', l_start_date);
		 message_token('ENDDATE', l_end_date);
		 add_message('PSB', 'PSB_PQH_UPDATE_BUDGET_VERSION');
		 raise FND_API.G_EXC_ERROR;

	     end;

	   end;
	   end if;

	 end;
	 end if;

       end;
       end if;
      /*For Bug No : 2292003 Start*/
      end loop;
      /*For Bug No : 2292003 End*/

      /*For Bug No : 2434152 Start*/
      IF l_position_ctr = g_checkpoint_save THEN
	commit work;
	l_position_ctr := 0;
      END IF;
      /*For Bug No : 2434152 End*/

    end loop;
    exit when c_position%NOTFOUND;

  end loop;
  close c_position;

  /*For Bug No : 2434152 Start*/
  --commit all unsaved records
  commit work;
  /*For Bug No : 2434152 End*/

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     if c_position%ISOPEN then
       close c_position;
     end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
 			p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     if c_position%ISOPEN then
       close c_position;
     end if;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
 			p_data  => p_msg_data);

   when OTHERS then
     if c_position%ISOPEN then
       close c_position;
     end if;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Create_Pqh_Budget_detail;

/* ----------------------------------------------------------------------- */

PROCEDURE Upload_Budget_HRMS
( p_api_version          IN   NUMBER,
  p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status        OUT  NOCOPY  VARCHAR2,
  p_msg_count            OUT  NOCOPY  NUMBER,
  p_msg_data             OUT  NOCOPY  VARCHAR2,
  p_event_type           IN   VARCHAR2,
  p_source_id            IN   NUMBER,
  p_hr_budget_id         IN   NUMBER,
  p_from_budget_year_id  IN   NUMBER,
  p_to_budget_year_id    IN   NUMBER
) IS

  l_api_name                  CONSTANT VARCHAR2(30)   := 'Upload_Budget_HRMS';
  l_api_version               CONSTANT NUMBER         := 1.0;

  l_pqh_budget_name           VARCHAR2(30);
  l_currency_code             VARCHAR2(15);
  l_business_group_id         NUMBER;
  l_pqh_budget_version_id     NUMBER;
  l_pqh_budget_detail_id      NUMBER;
  l_budget_unit1_id           NUMBER;
  l_budget_unit2_id           NUMBER;
  l_budget_unit3_id           NUMBER;
  l_budget_unit1_value        NUMBER;
  l_budget_unit2_value        NUMBER;
  l_budget_unit3_value        NUMBER;
  l_fte_type_id               NUMBER;
  l_money_type_id             NUMBER;
  l_budget_unit1              VARCHAR2(10);
  l_budget_unit2              VARCHAR2(10);
  l_budget_unit3              VARCHAR2(10);
  l_budget_unit1_aggregate    VARCHAR2(30);
  l_budget_unit2_aggregate    VARCHAR2(30);
  l_budget_unit3_aggregate    VARCHAR2(30);

  l_data_extract_id           NUMBER;
  l_budget_group_id           NUMBER;
  l_flex_code                 NUMBER;
  l_root_budget_group_id      NUMBER;
  l_budget_calendar_id        NUMBER;
  l_system_data_extract_id    NUMBER;
  l_start_date                DATE;
  l_end_date                  DATE;
  l_version_number            NUMBER;
  l_object_version_number     NUMBER;

  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_id_flex_num               NUMBER;

  cursor c_types is
    select shared_type_id, system_type_cd
      from per_shared_types_vl
     where system_type_cd in ('FTE', 'MONEY');

  cursor c_pqh_budget is
    select budget_name, currency_code, business_group_id, budget_unit1_id, budget_unit2_id,
	   budget_unit3_id, budget_unit1_aggregate, budget_unit2_aggregate, budget_unit3_aggregate
      from pqh_psb_budgets
     where budget_id = p_hr_budget_id;

 /*For Bug No : 2292003 Start*/
 --changed the view_name from per_business_groups to
 --per_business_groups_perf due to perf issues
  cursor c_business_group is
    select currency_code, to_number(cost_allocation_structure) id_flex_num
      from per_business_groups_perf
     where business_group_id = l_business_group_id;
 /*For Bug No : 2292003 End*/

  cursor c_BG is
    select nvl(chart_of_accounts_id, root_chart_of_accounts_id) flex_code,
	   nvl(root_budget_group_id, budget_group_id) root_budget_group_id
      from PSB_BUDGET_GROUPS_V
     where budget_group_id = l_budget_group_id;

  cursor c_WS is
    select budget_calendar_id, budget_group_id, data_extract_id
      from PSB_WORKSHEETS
     where worksheet_id = p_source_id;

  cursor c_BR is
    select budget_group_id
      from psb_budget_revisions
     where budget_revision_id = p_source_id;

  /*For Bug No : 2292003 Start*/
  --added the budget_calendar_id filter
  cursor c_budget_period is
    select min(start_date) start_date, max(end_date) end_date
      from psb_budget_periods
     where budget_period_id between p_from_budget_year_id and p_to_budget_year_id
       and budget_calendar_id = l_budget_calendar_id
       and budget_period_type = 'Y';
  /*For Bug No : 2292003 End*/

 cursor c_revision_dates is
   select min(start_date) start_date, max(end_date) end_date
     from psb_position_fte
    where budget_revision_id = p_source_id
      and hr_budget_id = p_hr_budget_id;

BEGIN

  if p_event_type = 'BP' then
  begin

    for c_WS_Rec in c_WS loop
      l_budget_group_id := c_WS_Rec.budget_group_id;
      l_budget_calendar_id := c_WS_Rec.budget_calendar_id;
      l_data_extract_id := c_WS_Rec.data_extract_id;
    end loop;

    /*bug:8471619:start*/
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
    /*bug:8471619:end*/

  end;
  elsif p_event_type = 'BR' then
  begin

    for c_BR_Rec in c_BR loop
      l_budget_group_id := c_BR_Rec.budget_group_id;
    end loop;

  end;
  end if;

  l_system_data_extract_id := PSB_BUDGET_REVISIONS_PVT.Find_System_Data_Extract
				  (p_budget_group_id => l_budget_group_id);

  -- check that all position transactions in the worksheet have been approved

  if p_event_type = 'BR' then
  begin

    Validate_Position_Budget
	   (p_return_status => l_return_status,
            --p_msg_count => l_msg_count,
            --p_msg_data => l_msg_data,
	    p_event_type => 'BR',
	    p_source_id => p_source_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  for c_BG_Rec in c_BG loop
    l_flex_code := c_BG_Rec.flex_code;
    l_root_budget_group_id := c_BG_Rec.root_budget_group_id;
  end loop;

  if p_event_type = 'BP' then
    for c_budget_period_rec in c_budget_period loop
      l_start_date := c_budget_period_rec.start_date;
      l_end_date := c_budget_period_rec.end_date;
    end loop;
  elsif p_event_type = 'BR' then
    for c_revision_dates_rec in c_revision_dates loop
      l_start_date := c_revision_dates_rec.start_date;
      l_end_date := c_revision_dates_rec.end_date;
    end loop;
  end if;

  if p_validation_level = FND_API.G_VALID_LEVEL_FULL then
  begin

    -- Validate the Budget Group Hierarchy
    Validate_Budget_Group
	   (p_return_status => l_return_status,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
	    p_event_type => p_event_type,
	    p_source_id => p_source_id,
	    p_budget_group_id => l_budget_group_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    end if;

    -- Validate Budget Period Granularity
    if p_hr_budget_id is not null then
       Validate_Period_Granularity
	    (p_return_status => l_return_status,
             p_msg_count => l_msg_count,
             p_msg_data => l_msg_data,
	     p_hr_budget_id => p_hr_budget_id,
	     p_from_budget_year_id => p_from_budget_year_id,
	     p_to_budget_year_id => p_to_budget_year_id);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;
    end if;

    -- Validate budget document being uploaded
    Validate_Budget_Document
	    (p_return_status => l_return_status,
             p_msg_count => l_msg_count,
             p_msg_data => l_msg_data,
	     p_validation_level => p_validation_level,
	     p_event_type => p_event_type,
	     p_source_id => p_source_id,
	     p_data_extract_id => l_data_extract_id,
	     p_system_data_extract_id => l_system_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  if p_validation_level = FND_API.G_VALID_LEVEL_NONE then
  begin

    -- Validate budget document being uploaded
    Validate_Budget_Document
	    (p_return_status => l_return_status,
             p_msg_count => l_msg_count,
             p_msg_data => l_msg_data,
	     p_validation_level => p_validation_level,
	     p_event_type => p_event_type,
	     p_source_id => p_source_id,
	     p_data_extract_id => l_data_extract_id,
	     p_system_data_extract_id => l_system_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    for c_types_rec in c_types loop

      if c_types_rec.system_type_cd = 'FTE' then
	l_fte_type_id := c_types_rec.shared_type_id;
      elsif c_types_rec.system_type_cd = 'MONEY' then
	l_money_type_id := c_types_rec.shared_type_id;
      end if;

    end loop;

    for c_pqh_budget_rec in c_pqh_budget loop
      l_pqh_budget_name := c_pqh_budget_rec.budget_name;
      l_business_group_id := c_pqh_budget_rec.business_group_id;
      l_currency_code := c_pqh_budget_rec.currency_code;
      l_budget_unit1_id := c_pqh_budget_rec.budget_unit1_id;
      l_budget_unit2_id := c_pqh_budget_rec.budget_unit2_id;
      l_budget_unit3_id := c_pqh_budget_rec.budget_unit3_id;
      l_budget_unit1_aggregate := c_pqh_budget_rec.budget_unit1_aggregate;
      l_budget_unit2_aggregate := c_pqh_budget_rec.budget_unit2_aggregate;
      l_budget_unit3_aggregate := c_pqh_budget_rec.budget_unit3_aggregate;
    end loop;

    for c_business_group_rec in c_business_group loop
      if l_currency_code is null then
	l_currency_code := c_business_group_rec.currency_code;
      end if;
      l_id_flex_num := c_business_group_rec.id_flex_num;
    end loop;

    if nvl(l_budget_unit1_id, 0) = l_fte_type_id then
      l_budget_unit1 := 'FTE';
    elsif nvl(l_budget_unit1_id, 0) = l_money_type_id then
      l_budget_unit1 := 'MONEY';
    end if;

    if nvl(l_budget_unit2_id, 0) = l_fte_type_id then
      l_budget_unit2 := 'FTE';
    elsif nvl(l_budget_unit2_id, 0) = l_money_type_id then
      l_budget_unit2 := 'MONEY';
    end if;

    if nvl(l_budget_unit3_id, 0) = l_fte_type_id then
      l_budget_unit3 := 'FTE';
    elsif nvl(l_budget_unit3_id, 0) = l_money_type_id then
      l_budget_unit3 := 'MONEY';
    end if;

    -- Validate budget set for fringe benefit elements
    Validate_Budget_Set
	    (p_return_status => l_return_status,
             p_msg_count => l_msg_count,
             p_msg_data => l_msg_data,
	     p_event_type => p_event_type,
	     p_source_id => p_source_id,
	     p_data_extract_id => l_data_extract_id,
	     p_system_data_extract_id => l_system_data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    Create_Pqh_Budget_Version
	  (p_return_status => l_return_status,
           p_msg_count => l_msg_count,
           p_msg_data => l_msg_data,
	   p_event_type => p_event_type,
	   p_source_id => p_source_id,
	   p_pqh_budget_version_id => l_pqh_budget_version_id,
	   p_data_extract_id => l_data_extract_id,
	   p_system_data_extract_id => l_system_data_extract_id,
	   p_currency_code => l_currency_code,
	   p_hr_budget_id => p_hr_budget_id,
	   p_pqh_budget_name => l_pqh_budget_name,
	   p_start_date => l_start_date,
	   p_end_date => l_end_date,
	   p_budget_unit1 => l_budget_unit1,
	   p_budget_unit2 => l_budget_unit2,
	   p_budget_unit3 => l_budget_unit3);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    commit work;

    Create_Pqh_Budget_Detail
	  (p_return_status => l_return_status,
           p_msg_count => l_msg_count,
           p_msg_data => l_msg_data,
	   p_event_type => p_event_type,
	   p_source_id => p_source_id,
	   p_currency_code => l_currency_code,
	   p_business_group_id => l_business_group_id,
	   p_system_data_extract_id => l_system_data_extract_id,
	   p_data_extract_id => l_data_extract_id,
	   p_gl_flex_code => l_flex_code,
	   p_hr_budget_id  => p_hr_budget_id,
	   p_pqh_budget_name => l_pqh_budget_name,
	   p_pqh_budget_version_id => l_pqh_budget_version_id,
	   p_start_date => l_start_date,
	   p_end_date => l_end_date,
	   p_budget_unit1 => l_budget_unit1,
	   p_budget_unit2 => l_budget_unit2,
	   p_budget_unit3 => l_budget_unit3,
	   p_budget_unit1_aggregate => l_budget_unit1_aggregate,
	   p_budget_unit2_aggregate => l_budget_unit2_aggregate,
	   p_budget_unit3_aggregate => l_budget_unit3_aggregate,
	   p_id_flex_num => l_id_flex_num);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    Record_Position_Transaction
	 (p_return_status => l_return_status,
          p_msg_count => l_msg_count,
          p_msg_data => l_msg_data,
	  p_event_type => p_event_type,
	  p_source_id => p_source_id,
	  p_hr_budget_id => p_hr_budget_id,
	  p_from_budget_year_id => p_from_budget_year_id,
	  p_to_budget_year_id => p_to_budget_year_id,
	  p_transfer_to_interface => 'Y',
	  p_transfer_to_hrms => 'Y');

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end;
  end if;

  -- Standard check of p_commit.
  IF FND_API.to_Boolean(p_commit) THEN
    commit work;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);


  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Upload_Budget_HRMS;

/* ----------------------------------------------------------------------- */

PROCEDURE Convert_Organization_Attr
( p_api_version        IN   NUMBER,
  p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit             IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level   IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status      OUT  NOCOPY  VARCHAR2,
  p_msg_count          OUT  NOCOPY  NUMBER,
  p_msg_data           OUT  NOCOPY  VARCHAR2,
  p_business_group_id  IN   NUMBER,
  p_attribute_id       IN   NUMBER
) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'Convert_Organization_Attr';
  l_api_version        CONSTANT NUMBER         := 1.0;

  l_sysorg_id          NUMBER;
  l_syscount           NUMBER;
  l_usrcount           NUMBER;

  cursor c_sysorg is
    select attribute_id
      from psb_attributes_vl
     where business_group_id = p_business_group_id
       and system_attribute_type = 'ORG';

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Convert_Organization_Attr;

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

  l_sysorg_id := NULL;

  for c_sysorg_rec in c_sysorg loop
    l_sysorg_id := C_sysorg_rec.attribute_id;
  end loop;

  if l_sysorg_id IS NOT NULL then
  begin

    select count(*)
      into l_syscount
      from psb_attribute_values
     where attribute_id = l_sysorg_id;

    select count(*)
      into l_usrcount
      from psb_attribute_values
     where attribute_id = p_attribute_id;

    if l_syscount >= l_usrcount then
    begin

      /* Number of system org attribute records more than user defined org attribute records */
      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_ATTRIBUTE_VALUES');
      Update psb_attribute_values
	 set attribute_id = l_sysorg_id
       where attribute_id = p_attribute_id;

      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_ATTRIBUTE_VALUES_I');
      Update psb_attribute_values_i
	 set attribute_id = l_sysorg_id
       where attribute_id = p_attribute_id;

      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_ACCOUNT_POSITION_SET_LINES');
      update psb_account_position_set_lines
	 set attribute_id = l_sysorg_id
       where attribute_id = p_attribute_id;

      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_PARAMETER_FORMULAS');
      Update psb_parameter_formulas
	 set attribute_id = l_sysorg_id
       where attribute_id = p_attribute_id;

      -- Bug#4466903
      -- Removed call to update psb_dss_dimension_mappings.

      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_DEFAULT_ASSIGNMENTS');
      Update psb_default_assignments
	 set attribute_id = l_sysorg_id
       where attribute_id = p_attribute_id;

      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_POSITION_ASSIGNMENTS');
      Update psb_position_assignments
	 set attribute_id = l_sysorg_id
       where attribute_id = p_attribute_id;

      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_ATTRIBUTES_TL');
      Delete from psb_attributes_tl
       where attribute_id = p_attribute_id;

      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_ATTRIBUTES');
      Delete from psb_attributes
       where attribute_id = p_attribute_id;

    end;
    else
    begin

      /* Number of system org attribute records less than user defined org attribute records */
      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_ATTRIBUTE_VALUES');
      Update psb_attribute_values
	 set attribute_id = p_attribute_id
       where attribute_id = l_sysorg_id;

      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_ATTRIBUTE_VALUES_I');
      Update psb_attribute_values_i
	 set attribute_id = p_attribute_id
       where attribute_id = l_sysorg_id;

      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_ACCOUNT_POSITION_SET_LINES');
      update psb_account_position_set_lines
	 set attribute_id = p_attribute_id
       where attribute_id = l_sysorg_id;

      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_PARAMETER_FORMULAS');
      Update psb_parameter_formulas
	 set attribute_id = p_attribute_id
       where attribute_id = l_sysorg_id;

      -- Bug#4466903
      -- Removed call to update psb_dss_dimension_mappings.

      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_DEFAULT_ASSIGNMENTS');
      Update psb_default_assignments
	 set attribute_id = p_attribute_id
       where attribute_id = l_sysorg_id;

      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_POSITION_ASSIGNMENTS');
      Update psb_position_assignments
	 set attribute_id = p_attribute_id
       where attribute_id = l_sysorg_id;

      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_ATTRIBUTES_TL');
      Delete from psb_attributes_tl
       where attribute_id = p_attribute_id;

      Update psb_attributes_tl
	 set attribute_id = p_attribute_id
       where attribute_id = l_sysorg_id;

      FND_FILE.put_line(FND_FILE.LOG, 'Updating Table PSB_ATTRIBUTES');
      Delete from psb_attributes
       where attribute_id = p_attribute_id;

      Update psb_attributes
	 set attribute_id = p_attribute_id
       where attribute_id = l_sysorg_id;

    end;
    end if;

  end;
  end if;

  -- Standard check of p_commit.
  IF FND_API.to_Boolean(p_commit) THEN
    commit work;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);


  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Convert_Organization_Attr;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Convert_Organization_Attr;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     rollback to Convert_Organization_Attr;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Convert_Organization_Attr;

/* ----------------------------------------------------------------------- */

-- This is the execution file for the concurrent program "Convert Organization
-- Attribute" through Standard Report Submissions

PROCEDURE Convert_Organization_Attr_CP
( errbuf               OUT  NOCOPY  VARCHAR2,
  retcode              OUT  NOCOPY  VARCHAR2,
  p_business_group_id  IN   NUMBER,
  p_attribute_id       IN   NUMBER
) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'Convert_Organization_Attr_CP';
  l_api_version        CONSTANT NUMBER         :=  1.0;

  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);

begin

  Convert_Organization_Attr
	(p_api_version => 1.0,
	 p_init_msg_list => FND_API.G_TRUE,
	 p_return_status => l_return_status,
	 p_msg_count => l_msg_count,
	 p_msg_data => l_msg_data,
	 p_business_group_id => p_business_group_id,
	 p_attribute_id => p_attribute_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;
    /* Start Bug No. 2322856 */
--  PSB_MESSAGE_S.Print_Success;
    /* End Bug No. 2322856 */
  retcode := 0;

  commit work;

EXCEPTION

   when FND_API.G_EXC_ERROR then
     PSB_MESSAGE_S.Print_Error (p_mode => FND_FILE.LOG,
				p_print_header => FND_API.G_TRUE);
     retcode := 2;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     PSB_MESSAGE_S.Print_Error (p_mode => FND_FILE.LOG,
				p_print_header => FND_API.G_TRUE);
     retcode := 2;

   when OTHERS then
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     PSB_MESSAGE_S.Print_Error (p_mode => FND_FILE.LOG,
				p_print_header => FND_API.G_TRUE);
     retcode := 2;

END Convert_Organization_Attr_CP;

/* ----------------------------------------------------------------------- */
-- Upload Element Position Set Groups

PROCEDURE Copy_Position_Set_Groups
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_old_pay_element_id      IN   NUMBER,
  p_new_pay_element_id      IN   NUMBER,
  p_target_data_extract_id  IN   NUMBER,
  p_budget_group_id         IN   NUMBER,
  p_flex_mapping_set_id     IN   NUMBER,
  p_follow_salary           IN   VARCHAR2
)IS
--
  l_possetgrp_id   NUMBER;
  l_possetgrp_exists     BOOLEAN;
--
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_return_status           VARCHAR2(1);
--
  cursor c_elempossetgrp_seq is
   select PSB_ELEMENT_POS_SET_GROUPS_S.NEXTVAL seq
    from dual;

  cursor c_possetgrp (elemid NUMBER) is
  select *  from PSB_ELEMENT_POS_SET_GROUPS
   where pay_element_id = elemid;

  cursor c_possetgrp_exists (psg_name VARCHAR2) is
    select position_set_group_id
      from PSB_ELEMENT_POS_SET_GROUPS
     where pay_element_id = p_new_pay_element_id
       and name = psg_name;
--
BEGIN
--
  for c_possetgrp_rec in c_possetgrp(p_old_pay_element_id) loop

   l_possetgrp_exists := FALSE;

   for c_possetgrp_exists_rec in c_possetgrp_exists (c_possetgrp_rec.name) loop
      l_possetgrp_id := c_possetgrp_exists_rec.position_set_group_id;
      l_possetgrp_exists := TRUE;
   end loop;

   if not l_possetgrp_exists then
    begin
	--Insert the position set group for new element
	for c_elempossetgrp_seq_rec in c_elempossetgrp_seq loop
	  l_possetgrp_id := c_elempossetgrp_seq_rec.seq;
	end loop;

	PSB_ELEMENT_POS_SET_GROUPS_PVT.Insert_Row
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_position_set_group_id => l_possetgrp_id,
	    p_pay_element_id => p_new_pay_element_id,
	    p_name => c_possetgrp_rec.name,
	    p_last_update_date => sysdate,
	    p_last_updated_by => FND_GLOBAL.USER_ID,
	    p_last_update_login => FND_GLOBAL.LOGIN_ID,
	    p_created_by => FND_GLOBAL.USER_ID,
	    p_creation_date => sysdate);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;
   end;
   end if;
   --Copy the Position sets that belong to the Position Set Group

   Copy_Position_Sets
     ( p_return_status            =>  l_return_status,
       p_old_psg_id               =>  c_possetgrp_rec.position_set_group_id,
       p_new_psg_id               =>  l_possetgrp_id,
       p_target_data_extract_id   =>  p_target_data_extract_id,
       p_budget_group_id          =>  p_budget_group_id);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   Copy_Element_Distributions
     (p_return_status           =>  l_return_status,
      p_old_psg_id              =>  c_possetgrp_rec.position_set_group_id,
      p_new_psg_id              =>  l_possetgrp_id,
      p_flex_mapping_set_id     =>  p_flex_mapping_set_id,
      p_follow_salary           =>  p_follow_salary);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

  end loop;
  p_return_status :=  FND_API.G_RET_STS_SUCCESS;
  --
  EXCEPTION
   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

End Copy_Position_Set_Groups;

/*---------------------------------------------------------------------------*/
-- Upload Position Sets that belong to Position set group

PROCEDURE Copy_Position_Sets
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_old_psg_id              IN   NUMBER,
  p_new_psg_id              IN   NUMBER,
  p_target_data_extract_id  IN   NUMBER,
  p_budget_group_id         IN   NUMBER
) IS
--
  l_position_set_id         NUMBER;
  l_position_set_exists     BOOLEAN;
  l_attribute_selection_type      VARCHAR2(1);
  l_rowid                   ROWID;
  lp_rowid                  ROWID;
  l_set_relation_id         NUMBER;
  l_set_rel_exists     BOOLEAN;
--
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_return_status           VARCHAR2(1);
--
  cursor c_setrel (possetgrpid NUMBER) is
    select *
      from PSB_SET_RELATIONS
     where position_set_group_id = possetgrpid;

  cursor c_set_rel_exists (possetgrpid NUMBER, pos_set_id NUMBER) is
    select set_relation_id
      from PSB_SET_RELATIONS
     where position_set_group_id = possetgrpid
       and account_position_set_id = pos_set_id;

  cursor c_posset (possetid NUMBER) is
    select *
      from PSB_ACCOUNT_POSITION_SETS
     where account_position_set_id = possetid;

  cursor c_posset_exists (possetname VARCHAR2) is
    select account_position_set_id , attribute_selection_type, rowid
      from PSB_ACCOUNT_POSITION_SETS
     where data_extract_id = p_target_data_extract_id
       and account_or_position_type = 'P'
       and name = possetname;

  cursor c_posset_seq is
    select PSB_ACCOUNT_POSITION_SETS_S.NEXTVAL seq
      from dual;

  cursor c_setrel_seq is
    select PSB_SET_RELATIONS_S.NEXTVAL seq
      from dual;


--
BEGIN
--
  for c_setrel_rec in c_setrel (p_old_psg_id) loop

    for c_posset_rec in c_posset (c_setrel_rec.account_position_set_id) loop

	    l_position_set_exists := FALSE;
	    lp_rowid := null;

	    for c_posset_exists_rec in c_posset_exists (c_posset_rec.name) loop
	      l_position_set_id := c_posset_exists_rec.account_position_set_id;
	      lp_rowid := c_posset_exists_rec.rowid;
	      l_attribute_selection_type := c_posset_rec.attribute_selection_type;
	      l_position_set_exists := TRUE;
	    end loop;

	    if not l_position_set_exists then
	    begin
	      --Insert the position set
	      for c_posset_seq_rec in c_posset_seq loop
		l_position_set_id := c_posset_seq_rec.seq;
	      end loop;

	      PSB_ACCOUNT_POSITION_SET_PVT.Insert_Row
		 (p_api_version => 1.0,
		  p_return_status => l_return_status,
		  p_msg_count => l_msg_count,
		  p_msg_data => l_msg_data,
		  p_row_id => l_rowid,
		  p_account_position_set_id => l_position_set_id,
		  p_name => c_posset_rec.name,
		  p_set_of_books_id => c_posset_rec.set_of_books_id,
		  p_use_in_budget_group_flag => c_posset_rec.use_in_budget_group_flag,
		  p_data_extract_id => p_target_data_extract_id,
		  p_budget_group_id => p_budget_group_id,
		  p_global_or_local_type => c_posset_rec.global_or_local_type,
		  p_account_or_position_type =>c_posset_rec.account_or_position_type,
		  p_attribute_selection_type => c_posset_rec.attribute_selection_type,
		  p_business_group_id => c_posset_rec.business_group_id,
		  p_last_update_date => sysdate,
		  p_last_updated_by => FND_GLOBAL.USER_ID,
		  p_last_update_login => FND_GLOBAL.LOGIN_ID,
		  p_created_by => FND_GLOBAL.USER_ID,
		  p_creation_date => sysdate);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		end if;
	       --Position set is inserted
	    end;
	    elsif c_posset_rec.attribute_selection_type <> l_attribute_selection_type then
		begin
	       --Update the Position Set with the new selection type
		  PSB_ACCOUNT_POSITION_SET_PVT.Update_Row
		     (p_api_version => 1.0,
		      p_return_status => l_return_status,
		      p_msg_count => l_msg_count,
		      p_msg_data => l_msg_data,
		      p_row_id => lp_rowid,
		      p_account_position_set_id => l_position_set_id,
		      p_name => c_posset_rec.name,
		      p_set_of_books_id => c_posset_rec.set_of_books_id,
		      p_data_extract_id => p_target_data_extract_id,
		      p_global_or_local_type => c_posset_rec.global_or_local_type,
		      p_account_or_position_type => c_posset_rec.account_or_position_type,
		      p_attribute_selection_type =>c_posset_rec.attribute_selection_type,
		      p_business_group_id => c_posset_rec.business_group_id,
		      p_last_update_date => sysdate,
		      p_last_updated_by => FND_GLOBAL.USER_ID,
		      p_last_update_login => FND_GLOBAL.LOGIN_ID);

		  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		    raise FND_API.G_EXC_ERROR;
		  end if;
		--Position set is updated
		end;
	     end if;
	-- Upload Set Relations
--
	    l_set_rel_exists := FALSE;
	    for c_set_rel_exists_rec in c_set_rel_exists (p_new_psg_id, l_position_set_id) loop
	      l_set_rel_exists := TRUE;
	    end loop;
	 if not l_set_rel_exists then
	    for c_setrel_seq_rec in c_setrel_seq loop
	      l_set_relation_id := c_setrel_seq_rec.seq;
	    end loop;

	    PSB_SET_RELATION_PVT.Insert_Row
	       (p_api_version => 1.0,
		p_return_status => l_return_status,
		p_msg_count => l_msg_count,
		p_msg_data => l_msg_data,
		p_row_id => l_rowid,
		p_set_relation_id => l_set_relation_id,
		p_account_position_set_id => l_position_set_id,
		p_allocation_rule_id => null,
		p_budget_group_id => null,
		p_budget_workflow_rule_id => null,
		p_constraint_id => null,
		p_default_rule_id => null,
		p_parameter_id => null,
		p_position_set_group_id => p_new_psg_id,
		/* Budget Revision Rules Enhancement Start */
		p_rule_id => null,
		p_apply_balance_flag => null,
		/* Budget Revision Rules Enhancement End */
		p_effective_start_date => null,
		p_effective_end_date => null,
		p_last_update_date => sysdate,
		p_last_updated_by => FND_GLOBAL.USER_ID,
		p_last_update_login => FND_GLOBAL.LOGIN_ID,
		p_created_by => FND_GLOBAL.USER_ID,
		p_creation_date => sysdate);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;
	  end if;

	     --Copy all position set lines that belong to the position set
	     Copy_Position_Set_Lines
	       (p_return_status           =>  l_return_status,
		p_old_posset_id           =>  c_posset_rec.account_position_set_id,
		p_new_posset_id           =>  l_position_set_id,
		p_target_data_extract_id  =>  p_target_data_extract_id
	       );

	  end loop; /* Position Sets */
	end loop; /* Set Relations */

	p_return_status :=  FND_API.G_RET_STS_SUCCESS;
  --
  EXCEPTION
  --
   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

End Copy_Position_Sets;

/*----------------------------------------------------------------------------*/

PROCEDURE Copy_Position_Set_Lines
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_old_posset_id           IN   NUMBER,
  p_new_posset_id           IN   NUMBER,
  p_target_data_extract_id  IN   NUMBER
)IS
--
  l_position_set_id         NUMBER;
  l_position_set_exists     BOOLEAN;
  l_attribute_selection_type      VARCHAR2(1);
  l_rowid                   ROWID;
  lp_rowid                  ROWID;
  l_set_relation_id         NUMBER;
  l_line_sequence_id        NUMBER;
  l_value_sequence_id       NUMBER;
  l_line_sequence_exists    BOOLEAN;
  l_value_sequence_exists   BOOLEAN;
  l_attribute_value_id      NUMBER;
--
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_return_status           VARCHAR2(1);
--
  cursor c_possetline (possetid NUMBER) is
    select *
      from PSB_ACCOUNT_POSITION_SET_LINES
     where account_position_set_id = possetid;

  cursor c_possetlineval (lineseqid NUMBER) is
    select *
      from PSB_POSITION_SET_LINE_VALUES
     where line_sequence_id = lineseqid;

  cursor c_re_attrval (attrvalid NUMBER) is
    select a.attribute_value_id
      from PSB_ATTRIBUTE_VALUES a,
	   PSB_ATTRIBUTE_VALUES b
     where a.data_extract_id = p_target_data_extract_id
       and a.attribute_value = b.attribute_value
       and a.attribute_id    = b.attribute_id -- added for Bug#4262388
       and b.attribute_value_id = attrvalid;

  cursor c_possetline_exists (possetid NUMBER, attrid NUMBER) is
    select line_sequence_id
      from PSB_ACCOUNT_POSITION_SET_LINES
     where attribute_id = attrid
       and account_position_set_id = possetid;

  cursor c_possetlineval_exists (lineseqid NUMBER, attr_val_id NUMBER) is
    select attribute_value_id
      from PSB_ATTRIBUTE_VALUES
     where attribute_value_id = attr_val_id
       and attribute_value in
	   (select a.attribute_value
	      from PSB_ATTRIBUTE_VALUES a,
		   PSB_POSITION_SET_LINE_VALUES b
	     where a.attribute_value_id = b.attribute_value_id
	       and b.line_sequence_id = lineseqid);

  cursor c_possetline_seq is
    select PSB_ACCT_POSITION_SET_LINES_S.NEXTVAL seq
      from dual;

   cursor c_possetlineval_seq is
    select PSB_POSITION_SET_LINE_VALUES_S.NEXTVAL seq
      from dual;
--
BEGIN
--
      for c_possetline_rec in c_possetline (p_old_posset_id) loop
	  l_line_sequence_exists := FALSE;
	  for c_possetline_exists_rec in c_possetline_exists (p_new_posset_id, c_possetline_rec.attribute_id) loop
	    l_line_sequence_id := c_possetline_exists_rec.line_sequence_id;
	    l_line_sequence_exists := TRUE;
	  end loop;

	     if not l_line_sequence_exists then
		begin

		  for c_possetline_seq_rec in c_possetline_seq loop
		    l_line_sequence_id := c_possetline_seq_rec.seq;
		  end loop;

		  PSB_ACCT_POSITION_SET_LINE_PVT.Insert_Row
		     (p_api_version => 1.0,
		      p_return_status => l_return_status,
		      p_msg_count => l_msg_count,
		      p_msg_data => l_msg_data,
		      p_row_id => l_rowid,
		      p_line_sequence_id => l_line_sequence_id,
		      p_account_position_set_id => p_new_posset_id,
		      p_description => c_possetline_rec.description,
		      p_business_group_id => c_possetline_rec.business_group_id,
		      p_attribute_id => c_possetline_rec.attribute_id,
		      p_include_or_exclude_type => c_possetline_rec.include_or_exclude_type,
		      p_segment1_low => c_possetline_rec.segment1_low,
		      p_segment2_low => c_possetline_rec.segment2_low,
		      p_segment3_low => c_possetline_rec.segment3_low,
		      p_segment4_low => c_possetline_rec.segment4_low,
		      p_segment5_low => c_possetline_rec.segment5_low,
		      p_segment6_low => c_possetline_rec.segment6_low,
		      p_segment7_low => c_possetline_rec.segment7_low,
		      p_segment8_low => c_possetline_rec.segment8_low,
		      p_segment9_low => c_possetline_rec.segment9_low,
		      p_segment10_low => c_possetline_rec.segment10_low,
		      p_segment11_low => c_possetline_rec.segment11_low,
		      p_segment12_low => c_possetline_rec.segment12_low,
		      p_segment13_low => c_possetline_rec.segment13_low,
		      p_segment14_low => c_possetline_rec.segment14_low,
		      p_segment15_low => c_possetline_rec.segment15_low,
		      p_segment16_low => c_possetline_rec.segment16_low,
		      p_segment17_low => c_possetline_rec.segment17_low,
		      p_segment18_low => c_possetline_rec.segment18_low,
		      p_segment19_low => c_possetline_rec.segment19_low,
		      p_segment20_low => c_possetline_rec.segment20_low,
		      p_segment21_low => c_possetline_rec.segment21_low,
		      p_segment22_low => c_possetline_rec.segment22_low,
		      p_segment23_low => c_possetline_rec.segment23_low,
		      p_segment24_low => c_possetline_rec.segment24_low,
		      p_segment25_low => c_possetline_rec.segment25_low,
		      p_segment26_low => c_possetline_rec.segment26_low,
		      p_segment27_low => c_possetline_rec.segment27_low,
		      p_segment28_low => c_possetline_rec.segment28_low,
		      p_segment29_low => c_possetline_rec.segment29_low,
		      p_segment30_low => c_possetline_rec.segment30_low,
		      p_segment1_high => c_possetline_rec.segment1_high,
		      p_segment2_high => c_possetline_rec.segment2_high,
		      p_segment3_high => c_possetline_rec.segment3_high,
		      p_segment4_high => c_possetline_rec.segment4_high,
		      p_segment5_high => c_possetline_rec.segment5_high,
		      p_segment6_high => c_possetline_rec.segment6_high,
		      p_segment7_high => c_possetline_rec.segment7_high,
		      p_segment8_high => c_possetline_rec.segment8_high,
		      p_segment9_high => c_possetline_rec.segment9_high,
		      p_segment10_high => c_possetline_rec.segment10_high,
		      p_segment11_high => c_possetline_rec.segment11_high,
		      p_segment12_high => c_possetline_rec.segment12_high,
		      p_segment13_high => c_possetline_rec.segment13_high,
		      p_segment14_high => c_possetline_rec.segment14_high,
		      p_segment15_high => c_possetline_rec.segment15_high,
		      p_segment16_high => c_possetline_rec.segment16_high,
		      p_segment17_high => c_possetline_rec.segment17_high,
		      p_segment18_high => c_possetline_rec.segment18_high,
		      p_segment19_high => c_possetline_rec.segment19_high,
		      p_segment20_high => c_possetline_rec.segment20_high,
		      p_segment21_high => c_possetline_rec.segment21_high,
		      p_segment22_high => c_possetline_rec.segment22_high,
		      p_segment23_high => c_possetline_rec.segment23_high,
		      p_segment24_high => c_possetline_rec.segment24_high,
		      p_segment25_high => c_possetline_rec.segment25_high,
		      p_segment26_high => c_possetline_rec.segment26_high,
		      p_segment27_high => c_possetline_rec.segment27_high,
		      p_segment28_high => c_possetline_rec.segment28_high,
		      p_segment29_high => c_possetline_rec.segment29_high,
		      p_segment30_high => c_possetline_rec.segment30_high,
		      p_context => c_possetline_rec.context,
		      p_attribute1 => c_possetline_rec.attribute1,
		      p_attribute2 => c_possetline_rec.attribute2,
		      p_attribute3 => c_possetline_rec.attribute3,
		      p_attribute4 => c_possetline_rec.attribute4,
		      p_attribute5 => c_possetline_rec.attribute5,
		      p_attribute6 => c_possetline_rec.attribute6,
		      p_attribute7 => c_possetline_rec.attribute7,
		      p_attribute8 => c_possetline_rec.attribute8,
		      p_attribute9 => c_possetline_rec.attribute9,
		      p_attribute10 => c_possetline_rec.attribute10,
		      p_last_update_date => sysdate,
		      p_last_updated_by => FND_GLOBAL.USER_ID,
		      p_last_update_login => FND_GLOBAL.LOGIN_ID,
		      p_created_by => FND_GLOBAL.USER_ID,
		      p_creation_date => sysdate);

		  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		    raise FND_API.G_EXC_ERROR;
		  end if;
	      end;
	      end if;


		for c_possetlineval_rec in c_possetlineval (c_possetline_rec.line_sequence_id) loop

		    for c_re_attrval_rec in c_re_attrval (c_possetlineval_rec.attribute_value_id) loop
		      l_attribute_value_id := c_re_attrval_rec.attribute_value_id;
		    end loop;
		      l_value_sequence_exists := FALSE;
		    for c_possetlineval_exists_rec in c_possetlineval_exists (l_line_sequence_id, c_possetlineval_rec.attribute_value_id) loop --c_possetlineval_rec.attribute_value) loop
		      l_value_sequence_exists := TRUE;
		    end loop;

		    if not l_value_sequence_exists then
		    begin

		      for c_possetlineval_seq_rec in c_possetlineval_seq loop
			l_value_sequence_id := c_possetlineval_seq_rec.seq;
		      end loop;

		      PSB_POS_SET_LINE_VALUES_PVT.Insert_Row
			 (p_api_version => 1.0,
			  p_return_status => l_return_status,
			  p_msg_count => l_msg_count,
			  p_msg_data => l_msg_data,
			  p_row_id => l_rowid,
			  p_value_sequence_id => l_value_sequence_id,
			  p_line_sequence_id => l_line_sequence_id,
			  p_attribute_value_id => l_attribute_value_id,
			  p_attribute_value => c_possetlineval_rec.attribute_value,
			  p_last_update_date => sysdate,
			  p_last_updated_by => FND_GLOBAL.USER_ID,
			  p_last_update_login => FND_GLOBAL.LOGIN_ID,
			  p_created_by => FND_GLOBAL.USER_ID,
			  p_creation_date => sysdate);

		      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
			raise FND_API.G_EXC_ERROR;
		      end if;

		    end;
		    end if;
		end loop; /* For Position Set Line Val */
	--
   end loop; /* For Position Set Lines */

  --
  EXCEPTION
  --
   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

End Copy_Position_Set_Lines;

/* ------------------------------------------------------------------------*/

PROCEDURE Copy_Element_Distributions
( p_return_status           OUT  NOCOPY  VARCHAR2,
  p_old_psg_id              IN   NUMBER,
  p_new_psg_id              IN   NUMBER,
  p_flex_mapping_set_id     IN   NUMBER,
  p_follow_salary           IN   VARCHAR2
)IS
--
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_return_status           VARCHAR2(1);
--
  l_distribution_id         NUMBER;
  l_mapped_ccid             NUMBER;
  l_budget_year_type_id     NUMBER;
  l_year_start_date         DATE;
  l_year_end_date           DATE;
  l_distribution_exists     BOOLEAN;
  l_distribution_percent    NUMBER;
--
  cursor c_elemdist (possetgrpid NUMBER) is
    select *
      from PSB_PAY_ELEMENT_DISTRIBUTIONS
     where position_set_group_id = possetgrpid;

  cursor c_elemdist_seq is
    select PSB_PAY_ELEMENT_DISTRIBUTION_S.NEXTVAL seq
      from dual;

  cursor c_elemdist_exists (psg_id NUMBER, cc_id NUMBER, con_segments VARCHAR2) is
    select distribution_id, distribution_percent
      from PSB_PAY_ELEMENT_DISTRIBUTIONS
     where position_set_group_id = psg_id
       and ((cc_id is not null and code_combination_id = cc_id) or (concatenated_segments = con_segments));
--
BEGIN
--
    for c_elemdist_rec in c_elemdist (p_old_psg_id) loop

	  -- if flex mapping was used in worksheet creation need to map the salary account distr
	  -- and distr for elements not following salary by effective dates

	  if ((p_flex_mapping_set_id is not null) and (nvl(p_follow_salary, 'N') = 'N')) then
	  begin

	    for l_year_index in 1..PSB_WS_ACCT1.g_num_budget_years loop

	      if PSB_WS_ACCT1.g_budget_years(l_year_index).year_type in ('CY', 'PP') then
	      begin

	       l_budget_year_type_id := PSB_WS_ACCT1.g_budget_years(l_year_index).budget_year_type_id;
	       l_year_start_date := PSB_WS_ACCT1.g_budget_years(l_year_index).start_date;
	       l_year_end_date := PSB_WS_ACCT1.g_budget_years(l_year_index).end_date;

		if (((c_elemdist_rec.effective_start_date < l_year_end_date) and
		     (c_elemdist_rec.effective_end_date is null)) or
		    ((c_elemdist_rec.effective_start_date between l_year_start_date and l_year_end_date) or
		     (c_elemdist_rec.effective_end_date between l_year_start_date and l_year_end_date) or
		    ((c_elemdist_rec.effective_start_date < l_year_start_date) and
		     (c_elemdist_rec.effective_end_date > l_year_end_date)))) then
		begin
		--
		  l_mapped_ccid := PSB_FLEX_MAPPING_PVT.Get_Mapped_CCID
				      (p_api_version => 1.0,
				       p_ccid => c_elemdist_rec.code_combination_id,
				       p_budget_year_type_id => l_budget_year_type_id,
				       p_flexfield_mapping_set_id => p_flex_mapping_set_id,
				       p_mapping_mode => 'GL_POSTING');

		  if l_mapped_ccid = 0 then
		    raise FND_API.G_EXC_ERROR;
		  end if;
		--Check whether the line is already exists or not, if exists update the line o/w insert new one

		  l_distribution_exists  := FALSE;
		  for c_elemdist_exists_rec in c_elemdist_exists (p_new_psg_id, l_mapped_ccid, c_elemdist_rec.concatenated_segments) loop
		    l_distribution_exists  := TRUE;
		    l_distribution_id := c_elemdist_exists_rec.distribution_id;
		    l_distribution_percent := c_elemdist_exists_rec.distribution_percent;
		  end loop;

		 if not l_distribution_exists then
		 begin
		 --Insert the line
		  for c_elemdist_seq_rec in c_elemdist_seq loop
		    l_distribution_id := c_elemdist_seq_rec.seq;
		  end loop;

		  PSB_ELEMENT_DISTRIBUTIONS_PVT.Insert_Row
		     (p_api_version => 1.0,
		      p_return_status => l_return_status,
		      p_msg_count => l_msg_count,
		      p_msg_data => l_msg_data,
		      p_distribution_id => l_distribution_id,
		      p_position_set_group_id => p_new_psg_id,
		      p_chart_of_accounts_id => c_elemdist_rec.chart_of_accounts_id,
		      p_effective_start_date => l_year_start_date,
		      p_effective_end_date => l_year_end_date,
		      p_distribution_percent => c_elemdist_rec.distribution_percent,
		      p_concatenated_segments => null,
		      p_code_combination_id => l_mapped_ccid,
		      p_distribution_set_id => c_elemdist_rec.distribution_set_id,
		      p_segment1 => null,
		      p_segment2 => null,
		      p_segment3 => null,
		      p_segment4 => null,
		      p_segment5 => null,
		      p_segment6 => null,
		      p_segment7 => null,
		      p_segment8 => null,
		      p_segment9 => null,
		      p_segment10 => null,
		      p_segment11 => null,
		      p_segment12 => null,
		      p_segment13 => null,
		      p_segment14 => null,
		      p_segment15 => null,
		      p_segment16 => null,
		      p_segment17 => null,
		      p_segment18 => null,
		      p_segment19 => null,
		      p_segment20 => null,
		      p_segment21 => null,
		      p_segment22 => null,
		      p_segment23 => null,
		      p_segment24 => null,
		      p_segment25 => null,
		      p_segment26 => null,
		      p_segment27 => null,
		      p_segment28 => null,
		      p_segment29 => null,
		      p_segment30 => null,
		      p_last_update_date => sysdate,
		      p_last_updated_by => FND_GLOBAL.USER_ID,
		      p_last_update_login => FND_GLOBAL.LOGIN_ID,
		      p_created_by => FND_GLOBAL.USER_ID,
		      p_creation_date => sysdate);

		  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		    raise FND_API.G_EXC_ERROR;
		  end if;
		end;    --End of insert line
		else
		begin   --Update line
		  PSB_ELEMENT_DISTRIBUTIONS_PVT.Update_Row
		     (p_api_version => 1.0,
		      p_return_status => l_return_status,
		      p_msg_count => l_msg_count,
		      p_msg_data => l_msg_data,
		      p_distribution_id => l_distribution_id,
		      p_position_set_group_id => p_new_psg_id,
		      p_chart_of_accounts_id => c_elemdist_rec.chart_of_accounts_id,
		      p_effective_start_date => l_year_start_date,
		      p_effective_end_date => l_year_end_date,
		      p_distribution_percent => c_elemdist_rec.distribution_percent,
		      p_concatenated_segments => null,
		      p_code_combination_id => l_mapped_ccid,
		      p_distribution_set_id => c_elemdist_rec.distribution_set_id,
		      p_segment1 => null,
		      p_segment2 => null,
		      p_segment3 => null,
		      p_segment4 => null,
		      p_segment5 => null,
		      p_segment6 => null,
		      p_segment7 => null,
		      p_segment8 => null,
		      p_segment9 => null,
		      p_segment10 => null,
		      p_segment11 => null,
		      p_segment12 => null,
		      p_segment13 => null,
		      p_segment14 => null,
		      p_segment15 => null,
		      p_segment16 => null,
		      p_segment17 => null,
		      p_segment18 => null,
		      p_segment19 => null,
		      p_segment20 => null,
		      p_segment21 => null,
		      p_segment22 => null,
		      p_segment23 => null,
		      p_segment24 => null,
		      p_segment25 => null,
		      p_segment26 => null,
		      p_segment27 => null,
		      p_segment28 => null,
		      p_segment29 => null,
		      p_segment30 => null,
		      p_last_update_date => sysdate,
		      p_last_updated_by => FND_GLOBAL.USER_ID,
		      p_last_update_login => FND_GLOBAL.LOGIN_ID);

		  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		    raise FND_API.G_EXC_ERROR;
		  end if;

		end;
		end if;         --End of update line

	      end;
	      end if;           --End of effective dates condition

	   end;
	   end if;              --End of Year condition for 'CY', 'PP'

	 end loop;

       end;                     --End of If part for flex mapping exists
       else
       begin                    --If flex mapping doesn't exists use the direct code_combination
       --
	 l_distribution_exists  := FALSE;
	 for c_elemdist_exists_rec in c_elemdist_exists (p_new_psg_id, c_elemdist_rec.code_combination_id, c_elemdist_rec.concatenated_segments) loop
	   l_distribution_exists  := TRUE;
	   l_distribution_id := c_elemdist_exists_rec.distribution_id;
	   l_distribution_percent := c_elemdist_exists_rec.distribution_percent;
	 end loop;

	 if  NOT l_distribution_exists   then
	 begin  --Insert the line
	 --
	    for c_elemdist_seq_rec in c_elemdist_seq loop
	      l_distribution_id := c_elemdist_seq_rec.seq;
	    end loop;

	    PSB_ELEMENT_DISTRIBUTIONS_PVT.Insert_Row
	       (p_api_version => 1.0,
		p_return_status => l_return_status,
		p_msg_count => l_msg_count,
		p_msg_data => l_msg_data,
		p_distribution_id => l_distribution_id,
		p_position_set_group_id => p_new_psg_id,
		p_chart_of_accounts_id => c_elemdist_rec.chart_of_accounts_id,
		p_effective_start_date => c_elemdist_rec.effective_start_date,
		p_effective_end_date => c_elemdist_rec.effective_end_date,
		p_distribution_percent => c_elemdist_rec.distribution_percent,
		p_concatenated_segments => c_elemdist_rec.concatenated_segments,
		p_code_combination_id => c_elemdist_rec.code_combination_id,
		p_distribution_set_id => c_elemdist_rec.distribution_set_id,
		p_segment1 => c_elemdist_rec.segment1,
		p_segment2 => c_elemdist_rec.segment2,
		p_segment3 => c_elemdist_rec.segment3,
		p_segment4 => c_elemdist_rec.segment4,
		p_segment5 => c_elemdist_rec.segment5,
		p_segment6 => c_elemdist_rec.segment6,
		p_segment7 => c_elemdist_rec.segment7,
		p_segment8 => c_elemdist_rec.segment8,
		p_segment9 => c_elemdist_rec.segment9,
		p_segment10 => c_elemdist_rec.segment10,
		p_segment11 => c_elemdist_rec.segment11,
		p_segment12 => c_elemdist_rec.segment12,
		p_segment13 => c_elemdist_rec.segment13,
		p_segment14 => c_elemdist_rec.segment14,
		p_segment15 => c_elemdist_rec.segment15,
		p_segment16 => c_elemdist_rec.segment16,
		p_segment17 => c_elemdist_rec.segment17,
		p_segment18 => c_elemdist_rec.segment18,
		p_segment19 => c_elemdist_rec.segment19,
		p_segment20 => c_elemdist_rec.segment20,
		p_segment21 => c_elemdist_rec.segment21,
		p_segment22 => c_elemdist_rec.segment22,
		p_segment23 => c_elemdist_rec.segment23,
		p_segment24 => c_elemdist_rec.segment24,
		p_segment25 => c_elemdist_rec.segment25,
		p_segment26 => c_elemdist_rec.segment26,
		p_segment27 => c_elemdist_rec.segment27,
		p_segment28 => c_elemdist_rec.segment28,
		p_segment29 => c_elemdist_rec.segment29,
		p_segment30 => c_elemdist_rec.segment30,
		p_last_update_date => sysdate,
		p_last_updated_by => FND_GLOBAL.USER_ID,
		p_last_update_login => FND_GLOBAL.LOGIN_ID,
		p_created_by => FND_GLOBAL.USER_ID,
		p_creation_date => sysdate);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;
	  end;          --End of Insert line where flex mapping doesn't exist
	  else
	  begin         --Update the line
	  --
	    PSB_ELEMENT_DISTRIBUTIONS_PVT.Update_Row
	       (p_api_version => 1.0,
		p_return_status => l_return_status,
		p_msg_count => l_msg_count,
		p_msg_data => l_msg_data,
		p_distribution_id => l_distribution_id,
		p_position_set_group_id => p_new_psg_id,
		p_chart_of_accounts_id => c_elemdist_rec.chart_of_accounts_id,
		p_effective_start_date => c_elemdist_rec.effective_start_date,
		p_effective_end_date => c_elemdist_rec.effective_end_date,
		p_distribution_percent => c_elemdist_rec.distribution_percent,
		p_concatenated_segments => c_elemdist_rec.concatenated_segments,
		p_code_combination_id => c_elemdist_rec.code_combination_id,
		p_distribution_set_id => c_elemdist_rec.distribution_set_id,
		p_segment1 => c_elemdist_rec.segment1,
		p_segment2 => c_elemdist_rec.segment2,
		p_segment3 => c_elemdist_rec.segment3,
		p_segment4 => c_elemdist_rec.segment4,
		p_segment5 => c_elemdist_rec.segment5,
		p_segment6 => c_elemdist_rec.segment6,
		p_segment7 => c_elemdist_rec.segment7,
		p_segment8 => c_elemdist_rec.segment8,
		p_segment9 => c_elemdist_rec.segment9,
		p_segment10 => c_elemdist_rec.segment10,
		p_segment11 => c_elemdist_rec.segment11,
		p_segment12 => c_elemdist_rec.segment12,
		p_segment13 => c_elemdist_rec.segment13,
		p_segment14 => c_elemdist_rec.segment14,
		p_segment15 => c_elemdist_rec.segment15,
		p_segment16 => c_elemdist_rec.segment16,
		p_segment17 => c_elemdist_rec.segment17,
		p_segment18 => c_elemdist_rec.segment18,
		p_segment19 => c_elemdist_rec.segment19,
		p_segment20 => c_elemdist_rec.segment20,
		p_segment21 => c_elemdist_rec.segment21,
		p_segment22 => c_elemdist_rec.segment22,
		p_segment23 => c_elemdist_rec.segment23,
		p_segment24 => c_elemdist_rec.segment24,
		p_segment25 => c_elemdist_rec.segment25,
		p_segment26 => c_elemdist_rec.segment26,
		p_segment27 => c_elemdist_rec.segment27,
		p_segment28 => c_elemdist_rec.segment28,
		p_segment29 => c_elemdist_rec.segment29,
		p_segment30 => c_elemdist_rec.segment30,
		p_last_update_date => sysdate,
		p_last_updated_by => FND_GLOBAL.USER_ID,
		p_last_update_login => FND_GLOBAL.LOGIN_ID);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;
	  end;
	  end if;       --End of Insert line where flex mapping doesn't exist

	end;
	end if;

      end loop; /* Element Distribution */
    --
  EXCEPTION
    --
    when FND_API.G_EXC_ERROR then
      p_return_status := FND_API.G_RET_STS_ERROR;

End Copy_Element_Distributions;
/*---------------------------------------------------------------------------*/

END PSB_Position_Control_Pvt;

/
