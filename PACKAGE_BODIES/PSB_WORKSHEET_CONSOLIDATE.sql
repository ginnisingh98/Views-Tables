--------------------------------------------------------
--  DDL for Package Body PSB_WORKSHEET_CONSOLIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WORKSHEET_CONSOLIDATE" AS
/* $Header: PSBVWCDB.pls 120.4 2005/08/09 09:29:56 masethur ship $ */

  G_PKG_NAME CONSTANT          VARCHAR2(30):= 'PSB_WORKSHEET_CONSOLIDATE';

  g_userid                     NUMBER;
  g_loginid                    NUMBER;

  g_global_worksheet_id        NUMBER;
  g_global_data_extract_id     NUMBER;
  g_global_business_group_id   NUMBER;

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

/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function Definition                        */
/*                                                                         */
/* ----------------------------------------------------------------------- */

PROCEDURE Consolidate_Attributes
( p_return_status            OUT  NOCOPY  VARCHAR2,
  p_local_data_extract_id    IN   NUMBER,
  p_local_business_group_id  IN   NUMBER
);

PROCEDURE Consolidate_Elements
( p_return_status            OUT  NOCOPY  VARCHAR2,
  p_local_worksheet_id       IN   NUMBER,
  p_local_data_extract_id    IN   NUMBER,
  p_local_business_group_id  IN   NUMBER
);

PROCEDURE Consolidate_Employees
( p_return_status            OUT  NOCOPY  VARCHAR2,
  p_local_data_extract_id    IN   NUMBER,
  p_local_business_group_id  IN   NUMBER
);

PROCEDURE Consolidate_Positions
( p_return_status            OUT  NOCOPY  VARCHAR2,
  p_local_worksheet_id       IN   NUMBER,
  p_local_data_extract_id    IN   NUMBER,
  p_local_business_group_id  IN   NUMBER
);

PROCEDURE Consolidate_Service_Packages
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_local_worksheet_id   IN   NUMBER
);

PROCEDURE Consolidate_Local_Worksheets
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_local_worksheet_id   IN   NUMBER,
  p_global_worksheet_id  IN   NUMBER
);

PROCEDURE message_token
( tokname  IN  VARCHAR2,
  tokval   IN  VARCHAR2);

PROCEDURE add_message
(appname  IN  VARCHAR2,
 msgname  IN  VARCHAR2);

/* ----------------------------------------------------------------------- */

PROCEDURE Consolidate_Attributes
( p_return_status            OUT  NOCOPY  VARCHAR2,
  p_local_data_extract_id    IN   NUMBER,
  p_local_business_group_id  IN   NUMBER
) IS

  l_attr_already_exists      VARCHAR2(1);
  l_attrval_already_exists   VARCHAR2(1);

  l_attribute_id             NUMBER;
  l_attribute_value_id       NUMBER;

  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_rowid                    VARCHAR2(100);

  l_return_status            VARCHAR2(1);

  cursor c_attr_seq is
    select PSB_ATTRIBUTES_S.NEXTVAL seq
      from dual;

  cursor c_attrval_seq is
    select PSB_ATTRIBUTE_VALUES_S.NEXTVAL seq
      from dual;

  cursor c_attr is
    select *
      from PSB_ATTRIBUTES
     where business_group_id = p_local_business_group_id;

  cursor c_attrname_exists (attrname VARCHAR2) is
    select attribute_id
      from PSB_ATTRIBUTES
     where name = attrname
       and business_group_id = g_global_business_group_id;

  cursor c_attrval (attrid NUMBER) is
    select *
      from PSB_ATTRIBUTE_VALUES
     where attribute_id = attrid
       and data_extract_id = p_local_data_extract_id;

  cursor c_attrval_exists (attrid NUMBER, attrval VARCHAR2) is
    select attribute_value_id
      from PSB_ATTRIBUTE_VALUES
     where attribute_value = attrval
       and attribute_id = attrid
       and data_extract_id = g_global_data_extract_id;

BEGIN

  -- Loop for each attribute in business group of local worksheet

  for c_attr_rec in c_attr loop

    l_attr_already_exists := FND_API.G_FALSE;

    -- Check if same attribute is already defined in business group of global worksheet

    for c_attrname_exists_rec in c_attrname_exists (c_attr_rec.name) loop
      l_attribute_id := c_attrname_exists_rec.attribute_id;
      l_attr_already_exists := FND_API.G_TRUE;
    end loop;

    -- if attribute doesn't already exist in business group of global worksheet create the
    -- attribute and all its values

    if not FND_API.to_Boolean(l_attr_already_exists) then
    begin

      for c_attr_seq_rec in c_attr_seq loop
	l_attribute_id := c_attr_seq_rec.seq;
      end loop;

      PSB_POSITION_ATTRIBUTES_PVT.Insert_Row
	    (p_api_version => 1.0,
	     p_return_status => l_return_status,
	     p_msg_count => l_msg_count,
	     p_msg_data => l_msg_data,
	     p_row_id => l_rowid,
	     p_attribute_id => l_attribute_id,
	     p_business_group_id => g_global_business_group_id,
	     p_name => c_attr_rec.name,
	     p_display_in_worksheet => c_attr_rec.display_in_worksheet,
	     p_display_sequence => c_attr_rec.display_sequence,
	     p_display_prompt => c_attr_rec.display_prompt,
	     p_required_for_import_flag => c_attr_rec.required_for_import_flag,
	     p_required_for_positions_flag => c_attr_rec.required_for_positions_flag,
	     p_allow_in_position_set_flag => c_attr_rec.allow_in_position_set_flag,
	     p_value_table_flag => c_attr_rec.value_table_flag,
	     p_protected_flag => c_attr_rec.protected_flag,
	     p_definition_type => c_attr_rec.definition_type,
	     p_definition_structure => c_attr_rec.definition_structure,
	     p_definition_table => c_attr_rec.definition_table,
	     p_definition_column => c_attr_rec.definition_column,
	     p_attribute_type_id => c_attr_rec.attribute_type_id,
	     p_data_type => c_attr_rec.data_type,
	     p_application_id => c_attr_rec.application_id,
	     p_system_attribute_type => c_attr_rec.system_attribute_type,
	     p_last_update_date => sysdate,
	     p_last_updated_by => g_userid,
	     p_last_update_login => g_loginid,
	     p_created_by => g_userid,
	     p_creation_date => sysdate);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      for c_attrval_rec in c_attrval (c_attr_rec.attribute_id) loop

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
	    p_attribute_id => l_attribute_id,
	    p_attribute_value => c_attrval_rec.attribute_value,
	    p_description => c_attrval_rec.description,
	    p_hr_value_id => c_attrval_rec.hr_value_id,
	    p_data_extract_id => g_global_data_extract_id,
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
	    p_last_updated_by => g_userid,
	    p_last_update_login => g_loginid,
	    p_created_by => g_userid,
	    p_creation_date => sysdate);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end loop;

    end;
    else
    begin

      -- Attribute already exists for the global business group. Only
      -- consolidate attribute values if required

      for c_attrval_rec in c_attrval (l_attribute_id) loop

	l_attrval_already_exists := FND_API.G_FALSE;

	-- Check if attribute value is already defined in data extract of global worksheet

	for c_attrval_exists_rec in c_attrval_exists (l_attribute_id, c_attrval_rec.attribute_value) loop
	  l_attribute_value_id := c_attrval_exists_rec.attribute_value_id;
	  l_attrval_already_exists := FND_API.G_TRUE;
	end loop;

	if not FND_API.to_Boolean(l_attrval_already_exists) then
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
	      p_attribute_id => l_attribute_id,
	      p_attribute_value => c_attrval_rec.attribute_value,
	      p_description => c_attrval_rec.description,
	      p_hr_value_id => c_attrval_rec.hr_value_id,
	      p_data_extract_id => g_global_data_extract_id,
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
	      p_last_updated_by => g_userid,
	      p_last_update_login => g_loginid,
	      p_created_by => g_userid,
	      p_creation_date => sysdate);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
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

END Consolidate_Attributes;

/* ----------------------------------------------------------------------- */

PROCEDURE Consolidate_Elements
( p_return_status            OUT  NOCOPY  VARCHAR2,
  p_local_worksheet_id       IN   NUMBER,
  p_local_data_extract_id    IN   NUMBER,
  p_local_business_group_id  IN   NUMBER
) IS

  l_element_exists           VARCHAR2(1);
  l_position_set_exists      VARCHAR2(1);
  l_line_sequence_exists     VARCHAR2(1);
  l_value_sequence_exists    VARCHAR2(1);
  l_element_option_exists    VARCHAR2(1);

  l_worksheet_id             NUMBER;
  l_attribute_id             NUMBER;
  l_attribute_value_id       NUMBER;

  l_pay_element_id           NUMBER;
  l_pay_element_option_id    NUMBER;
  l_pay_element_rate_id      NUMBER;
  l_position_set_group_id    NUMBER;
  l_position_set_id          NUMBER;
  l_line_sequence_id         NUMBER;
  l_value_sequence_id        NUMBER;
  l_set_relation_id          NUMBER;
  l_distribution_id          NUMBER;

  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_rowid                    VARCHAR2(100);

  l_return_status            VARCHAR2(1);

  cursor c_elem is
    select *
      from PSB_PAY_ELEMENTS
     where data_extract_id = p_local_data_extract_id;

  cursor c_elemname_exists (elemname VARCHAR2) is
    select pay_element_id
      from PSB_PAY_ELEMENTS
     where name = elemname
       and data_extract_id = g_global_data_extract_id;

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
     where (worksheet_id is null or worksheet_id = p_local_worksheet_id)
       and pay_element_option_id = elemoptionid
       and pay_element_id = elemid;

  cursor c_elemrates_nooptions (elemid NUMBER) is
    select *
      from PSB_PAY_ELEMENT_RATES
     where (worksheet_id is null or worksheet_id = p_local_worksheet_id)
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
    select account_position_set_id
      from PSB_ACCOUNT_POSITION_SETS
     where data_extract_id = g_global_data_extract_id
       and account_or_position_type = 'P'
       and name = possetname;

  cursor c_possetlineval_exists (lineseqid NUMBER, attrval VARCHAR2) is
    select value_sequence_id
      from PSB_POSITION_SET_LINE_VALUES
     where attribute_value = attrval
       and line_sequence_id = lineseqid;

  cursor c_re_attr (attrid NUMBER) is
    select a.attribute_id
      from PSB_ATTRIBUTES a,
	   PSB_ATTRIBUTES b
     where a.business_group_id = g_global_business_group_id
       and a.name = b.name
       and b.attribute_id = attrid;

  cursor c_re_attrval (attrvalid NUMBER) is
    select a.attribute_value_id
      from PSB_ATTRIBUTE_VALUES a,
	   PSB_ATTRIBUTE_VALUES b
     where a.data_extract_id = g_global_data_extract_id
       and a.attribute_value = b.attribute_value
       and a.attribute_id = b.attribute_id -- added this for Bug #4262388
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

  cursor c_elemrates_seq is
    select psb_pay_element_rates_s.nextval seq
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

  for c_elem_rec in c_elem loop

    l_element_exists := FND_API.G_FALSE;

    -- Check if element name exists in the global data extract

    for c_elemname_exists_rec in c_elemname_exists (c_elem_rec.name) loop
      l_pay_element_id := c_elemname_exists_rec.pay_element_id;
      l_element_exists := FND_API.G_TRUE;
    end loop;

    if not FND_API.to_Boolean(l_element_exists) then
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
	  p_business_group_id => g_global_business_group_id,
	  p_data_extract_id => g_global_data_extract_id,
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
	  p_last_updated_by => g_userid,
	  p_last_update_login => g_loginid,
	  p_created_by => g_userid,
	  p_creation_date => sysdate);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      if c_elem_rec.option_flag = 'Y' then
      begin

	for c_elemoptions_rec in c_elemoptions (c_elem_rec.pay_element_id) loop

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
	      p_last_updated_by => g_userid,
	      p_last_update_login => g_loginid,
	      p_created_by => g_userid,
	      p_creation_date => sysdate);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	  for c_elemrates_rec in c_elemrates (c_elem_rec.pay_element_id, c_elemoptions_rec.pay_element_option_id) loop

	    for c_elemrates_seq_rec in c_elemrates_seq loop
	      l_pay_element_rate_id := c_elemrates_seq_rec.seq;
	    end loop;

	    if c_elemrates_rec.worksheet_id is null then
	      l_worksheet_id := null;
	    else
	      l_worksheet_id := g_global_worksheet_id;
	    end if;

	    PSB_PAY_ELEMENT_RATES_PVT.Insert_Row
	       (p_api_version => 1.0,
		p_return_status => l_return_status,
		p_msg_count => l_msg_count,
		p_msg_data => l_msg_data,
		p_pay_element_rate_id => l_pay_element_rate_id,
		p_pay_element_option_id => l_pay_element_option_id,
		p_pay_element_id => l_pay_element_id,
		p_effective_start_date => c_elemrates_rec.effective_start_date,
		p_effective_end_date => c_elemrates_rec.effective_end_date,
		p_worksheet_id => l_worksheet_id,
		p_element_value_type => c_elemrates_rec.element_value_type,
		p_element_value => c_elemrates_rec.element_value,
		p_pay_basis  => c_elemrates_rec.pay_basis,
		p_formula_id => c_elemrates_rec.formula_id,
		p_maximum_value => c_elemrates_rec.maximum_value,
		p_mid_value => c_elemrates_rec.mid_value,
		p_minimum_value => c_elemrates_rec.minimum_value,
		p_currency_code => c_elemrates_rec.currency_code,
		p_last_update_date => sysdate,
		p_last_updated_by => g_userid,
		p_last_update_login => g_loginid,
		p_created_by => g_userid,
		p_creation_date => sysdate);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;

	  end loop;

	end loop;

      end;
      else
      begin

	for c_elemrates_rec in c_elemrates_nooptions (c_elem_rec.pay_element_id) loop

	  for c_elemrates_seq_rec in c_elemrates_seq loop
	    l_pay_element_rate_id := c_elemrates_seq_rec.seq;
	  end loop;

	  if c_elemrates_rec.worksheet_id is null then
	    l_worksheet_id := null;
	  else
	    l_worksheet_id := g_global_worksheet_id;
	  end if;

	  PSB_PAY_ELEMENT_RATES_PVT.Insert_Row
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_pay_element_rate_id => l_pay_element_rate_id,
	      p_pay_element_option_id => NULL,
	      p_pay_element_id => l_pay_element_id,
	      p_effective_start_date => c_elemrates_rec.effective_start_date,
	      p_effective_end_date => c_elemrates_rec.effective_end_date,
	      p_worksheet_id => l_worksheet_id,
	      p_element_value_type => c_elemrates_rec.element_value_type,
	      p_element_value => c_elemrates_rec.element_value,
	      p_pay_basis  => c_elemrates_rec.pay_basis,
	      p_formula_id => c_elemrates_rec.formula_id,
	      p_maximum_value => c_elemrates_rec.maximum_value,
	      p_mid_value => c_elemrates_rec.mid_value,
	      p_minimum_value => c_elemrates_rec.minimum_value,
	      p_currency_code => c_elemrates_rec.currency_code,
	      p_last_update_date => sysdate,
	      p_last_updated_by => g_userid,
	      p_last_update_login => g_loginid,
	      p_created_by => g_userid,
	      p_creation_date => sysdate);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end loop;

      end;
      end if;

      -- Consolidate Element Position Set Groups

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
	    p_last_updated_by => g_userid,
	    p_last_update_login => g_loginid,
	    p_created_by => g_userid,
	    p_creation_date => sysdate);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

	-- Consolidate all Set Relations for the Position Set Group

	for c_setrel_rec in c_setrel (c_possetgrp_rec.position_set_group_id) loop

	  for c_posset_rec in c_posset (c_setrel_rec.account_position_set_id) loop

	    l_position_set_exists := FND_API.G_FALSE;

	    for c_posset_exists_rec in c_posset_exists (c_posset_rec.name) loop
	      l_position_set_id := c_posset_exists_rec.account_position_set_id;
	      l_position_set_exists := FND_API.G_TRUE;
	    end loop;

	    if not FND_API.to_Boolean(l_position_set_exists) then
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
		  p_use_in_budget_group_flag => c_posset_rec.use_in_budget_group_flag,
		  p_set_of_books_id => c_posset_rec.set_of_books_id,
		  p_data_extract_id => g_global_data_extract_id,
		  p_global_or_local_type => c_posset_rec.global_or_local_type,
		  p_account_or_position_type => c_posset_rec.account_or_position_type,
		  p_attribute_selection_type => c_posset_rec.attribute_selection_type,
		  p_business_group_id => c_posset_rec.business_group_id,
		  p_last_update_date => sysdate,
		  p_last_updated_by => g_userid,
		  p_last_update_login => g_loginid,
		  p_created_by => g_userid,
		  p_creation_date => sysdate);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      end if;

	      for c_possetline_rec in c_possetline (c_posset_rec.account_position_set_id) loop

		for c_re_attr_rec in c_re_attr (c_possetline_rec.attribute_id) loop
		  l_attribute_id := c_re_attr_rec.attribute_id;
		end loop;

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
		    p_business_group_id => g_global_business_group_id,
		    p_attribute_id => l_attribute_id,
		    p_include_or_exclude_type => c_possetline_rec.include_or_exclude_type,
		    p_segment1_low => c_possetline_rec.segment1_low, p_segment2_low => c_possetline_rec.segment2_low,
		    p_segment3_low => c_possetline_rec.segment3_low, p_segment4_low => c_possetline_rec.segment4_low,
		    p_segment5_low => c_possetline_rec.segment5_low, p_segment6_low => c_possetline_rec.segment6_low,
		    p_segment7_low => c_possetline_rec.segment7_low, p_segment8_low => c_possetline_rec.segment8_low,
		    p_segment9_low => c_possetline_rec.segment9_low, p_segment10_low => c_possetline_rec.segment10_low,
		    p_segment11_low => c_possetline_rec.segment11_low, p_segment12_low => c_possetline_rec.segment12_low,
		    p_segment13_low => c_possetline_rec.segment13_low, p_segment14_low => c_possetline_rec.segment14_low,
		    p_segment15_low => c_possetline_rec.segment15_low, p_segment16_low => c_possetline_rec.segment16_low,
		    p_segment17_low => c_possetline_rec.segment17_low, p_segment18_low => c_possetline_rec.segment18_low,
		    p_segment19_low => c_possetline_rec.segment19_low, p_segment20_low => c_possetline_rec.segment20_low,
		    p_segment21_low => c_possetline_rec.segment21_low, p_segment22_low => c_possetline_rec.segment22_low,
		    p_segment23_low => c_possetline_rec.segment23_low, p_segment24_low => c_possetline_rec.segment24_low,
		    p_segment25_low => c_possetline_rec.segment25_low, p_segment26_low => c_possetline_rec.segment26_low,
		    p_segment27_low => c_possetline_rec.segment27_low, p_segment28_low => c_possetline_rec.segment28_low,
		    p_segment29_low => c_possetline_rec.segment29_low, p_segment30_low => c_possetline_rec.segment30_low,
		    p_segment1_high => c_possetline_rec.segment1_high, p_segment2_high => c_possetline_rec.segment2_high,
		    p_segment3_high => c_possetline_rec.segment3_high, p_segment4_high => c_possetline_rec.segment4_high,
		    p_segment5_high => c_possetline_rec.segment5_high, p_segment6_high => c_possetline_rec.segment6_high,
		    p_segment7_high => c_possetline_rec.segment7_high, p_segment8_high => c_possetline_rec.segment8_high,
		    p_segment9_high => c_possetline_rec.segment9_high, p_segment10_high => c_possetline_rec.segment10_high,
		    p_segment11_high => c_possetline_rec.segment11_high, p_segment12_high => c_possetline_rec.segment12_high,
		    p_segment13_high => c_possetline_rec.segment13_high, p_segment14_high => c_possetline_rec.segment14_high,
		    p_segment15_high => c_possetline_rec.segment15_high, p_segment16_high => c_possetline_rec.segment16_high,
		    p_segment17_high => c_possetline_rec.segment17_high, p_segment18_high => c_possetline_rec.segment18_high,
		    p_segment19_high => c_possetline_rec.segment19_high, p_segment20_high => c_possetline_rec.segment20_high,
		    p_segment21_high => c_possetline_rec.segment21_high, p_segment22_high => c_possetline_rec.segment22_high,
		    p_segment23_high => c_possetline_rec.segment23_high, p_segment24_high => c_possetline_rec.segment24_high,
		    p_segment25_high => c_possetline_rec.segment25_high, p_segment26_high => c_possetline_rec.segment26_high,
		    p_segment27_high => c_possetline_rec.segment27_high, p_segment28_high => c_possetline_rec.segment28_high,
		    p_segment29_high => c_possetline_rec.segment29_high, p_segment30_high => c_possetline_rec.segment30_high,
		    p_context => c_possetline_rec.context,
		    p_attribute1 => c_possetline_rec.attribute1, p_attribute2 => c_possetline_rec.attribute2,
		    p_attribute3 => c_possetline_rec.attribute3, p_attribute4 => c_possetline_rec.attribute4,
		    p_attribute5 => c_possetline_rec.attribute5, p_attribute6 => c_possetline_rec.attribute6,
		    p_attribute7 => c_possetline_rec.attribute7, p_attribute8 => c_possetline_rec.attribute8,
		    p_attribute9 => c_possetline_rec.attribute9, p_attribute10 => c_possetline_rec.attribute10,
		    p_last_update_date => sysdate,
		    p_last_updated_by => g_userid,
		    p_last_update_login => g_loginid,
		    p_created_by => g_userid,
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
		      p_last_updated_by => g_userid,
		      p_last_update_login => g_loginid,
		      p_created_by => g_userid,
		      p_creation_date => sysdate);

		  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		    raise FND_API.G_EXC_ERROR;
		  end if;

		end loop;

	      end loop;

	    end; /* Position Set does not exist */
	    else
	    begin /* Position Set exists; only consolidate position set lines and attribute values */

	      for c_possetline_rec in c_possetline (c_posset_rec.account_position_set_id) loop

		l_line_sequence_exists := FND_API.G_FALSE;

		-- Find attribute id for the global business group

		for c_re_attr_rec in c_re_attr (c_possetline_rec.attribute_id) loop
		  l_attribute_id := c_re_attr_rec.attribute_id;
		end loop;

		for c_possetline_exists_rec in c_possetline_exists (l_position_set_id, l_attribute_id) loop
		  l_line_sequence_id := c_possetline_exists_rec.line_sequence_id;
		  l_line_sequence_exists := FND_API.G_TRUE;
		end loop;

		if not FND_API.to_Boolean(l_line_sequence_exists) then
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
		      p_business_group_id => g_global_business_group_id,
		      p_attribute_id => l_attribute_id,
		      p_include_or_exclude_type => c_possetline_rec.include_or_exclude_type,
		      p_segment1_low => c_possetline_rec.segment1_low, p_segment2_low => c_possetline_rec.segment2_low,
		      p_segment3_low => c_possetline_rec.segment3_low, p_segment4_low => c_possetline_rec.segment4_low,
		      p_segment5_low => c_possetline_rec.segment5_low, p_segment6_low => c_possetline_rec.segment6_low,
		      p_segment7_low => c_possetline_rec.segment7_low, p_segment8_low => c_possetline_rec.segment8_low,
		      p_segment9_low => c_possetline_rec.segment9_low, p_segment10_low => c_possetline_rec.segment10_low,
		      p_segment11_low => c_possetline_rec.segment11_low, p_segment12_low => c_possetline_rec.segment12_low,
		      p_segment13_low => c_possetline_rec.segment13_low, p_segment14_low => c_possetline_rec.segment14_low,
		      p_segment15_low => c_possetline_rec.segment15_low, p_segment16_low => c_possetline_rec.segment16_low,
		      p_segment17_low => c_possetline_rec.segment17_low, p_segment18_low => c_possetline_rec.segment18_low,
		      p_segment19_low => c_possetline_rec.segment19_low, p_segment20_low => c_possetline_rec.segment20_low,
		      p_segment21_low => c_possetline_rec.segment21_low, p_segment22_low => c_possetline_rec.segment22_low,
		      p_segment23_low => c_possetline_rec.segment23_low, p_segment24_low => c_possetline_rec.segment24_low,
		      p_segment25_low => c_possetline_rec.segment25_low, p_segment26_low => c_possetline_rec.segment26_low,
		      p_segment27_low => c_possetline_rec.segment27_low, p_segment28_low => c_possetline_rec.segment28_low,
		      p_segment29_low => c_possetline_rec.segment29_low, p_segment30_low => c_possetline_rec.segment30_low,
		      p_segment1_high => c_possetline_rec.segment1_high, p_segment2_high => c_possetline_rec.segment2_high,
		      p_segment3_high => c_possetline_rec.segment3_high, p_segment4_high => c_possetline_rec.segment4_high,
		      p_segment5_high => c_possetline_rec.segment5_high, p_segment6_high => c_possetline_rec.segment6_high,
		      p_segment7_high => c_possetline_rec.segment7_high, p_segment8_high => c_possetline_rec.segment8_high,
		      p_segment9_high => c_possetline_rec.segment9_high, p_segment10_high => c_possetline_rec.segment10_high,
		      p_segment11_high => c_possetline_rec.segment11_high, p_segment12_high => c_possetline_rec.segment12_high,
		      p_segment13_high => c_possetline_rec.segment13_high, p_segment14_high => c_possetline_rec.segment14_high,
		      p_segment15_high => c_possetline_rec.segment15_high, p_segment16_high => c_possetline_rec.segment16_high,
		      p_segment17_high => c_possetline_rec.segment17_high, p_segment18_high => c_possetline_rec.segment18_high,
		      p_segment19_high => c_possetline_rec.segment19_high, p_segment20_high => c_possetline_rec.segment20_high,
		      p_segment21_high => c_possetline_rec.segment21_high, p_segment22_high => c_possetline_rec.segment22_high,
		      p_segment23_high => c_possetline_rec.segment23_high, p_segment24_high => c_possetline_rec.segment24_high,
		      p_segment25_high => c_possetline_rec.segment25_high, p_segment26_high => c_possetline_rec.segment26_high,
		      p_segment27_high => c_possetline_rec.segment27_high, p_segment28_high => c_possetline_rec.segment28_high,
		      p_segment29_high => c_possetline_rec.segment29_high, p_segment30_high => c_possetline_rec.segment30_high,
		      p_context => c_possetline_rec.context,
		      p_attribute1 => c_possetline_rec.attribute1, p_attribute2 => c_possetline_rec.attribute2,
		      p_attribute3 => c_possetline_rec.attribute3, p_attribute4 => c_possetline_rec.attribute4,
		      p_attribute5 => c_possetline_rec.attribute5, p_attribute6 => c_possetline_rec.attribute6,
		      p_attribute7 => c_possetline_rec.attribute7, p_attribute8 => c_possetline_rec.attribute8,
		      p_attribute9 => c_possetline_rec.attribute9, p_attribute10 => c_possetline_rec.attribute10,
		      p_last_update_date => sysdate,
		      p_last_updated_by => g_userid,
		      p_last_update_login => g_loginid,
		      p_created_by => g_userid,
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
			p_last_updated_by => g_userid,
			p_last_update_login => g_loginid,
			p_created_by => g_userid,
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
		      l_value_sequence_exists := FND_API.G_TRUE;
		    end loop;

		    if not FND_API.to_Boolean(l_value_sequence_exists) then
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
			  p_last_updated_by => g_userid,
			  p_last_update_login => g_loginid,
			  p_created_by => g_userid,
			  p_creation_date => sysdate);

		      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
			raise FND_API.G_EXC_ERROR;
		      end if;

		    end;
		    end if;

		  end loop;

		end;
		end if;

		-- Since we're adding attribute values set the attribute selection type to 'O'

		if c_posset_rec.attribute_selection_type <> 'O' then
		begin

		  PSB_ACCOUNT_POSITION_SET_PVT.Update_Row
		     (p_api_version => 1.0,
		      p_return_status => l_return_status,
		      p_msg_count => l_msg_count,
		      p_msg_data => l_msg_data,
		      p_row_id => l_rowid,
		      p_account_position_set_id => l_position_set_id,
		      p_name => c_posset_rec.name,
		      p_set_of_books_id => c_posset_rec.set_of_books_id,
		      p_data_extract_id => g_global_data_extract_id,
		      p_global_or_local_type => c_posset_rec.global_or_local_type,
		      p_account_or_position_type => c_posset_rec.account_or_position_type,
		      p_attribute_selection_type => 'O',
		      p_business_group_id => g_global_business_group_id,
		      p_last_update_date => sysdate,
		      p_last_updated_by => g_userid,
		      p_last_update_login => g_loginid);

		  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		    raise FND_API.G_EXC_ERROR;
		  end if;

		end;
		end if;

	      end loop;

	    end;
	    end if;

	    -- Consolidate Set Relations

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
		p_allocation_rule_id => NULL,
		p_budget_group_id => NULL,
		p_budget_workflow_rule_id => NULL,
		p_constraint_id => NULL,
		p_default_rule_id => NULL,
		p_parameter_id => NULL,
		p_position_set_group_id => l_position_set_group_id,
/* Budget Revision Rules Enhancement Start */
		p_rule_id => NULL,
		p_apply_balance_flag => NULL,
/* Budget Revision Rules Enhancement End */
		p_effective_start_date => c_setrel_rec.effective_start_date,
		p_effective_end_date => c_setrel_rec.effective_end_date,
		p_last_update_date => sysdate,
		p_last_updated_by => g_userid,
		p_last_update_login => g_loginid,
		p_created_by => g_userid,
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
	      p_segment1 => c_elemdist_rec.segment1, p_segment2 => c_elemdist_rec.segment2,
	      p_segment3 => c_elemdist_rec.segment3, p_segment4 => c_elemdist_rec.segment4,
	      p_segment5 => c_elemdist_rec.segment5, p_segment6 => c_elemdist_rec.segment6,
	      p_segment7 => c_elemdist_rec.segment7, p_segment8 => c_elemdist_rec.segment8,
	      p_segment9 => c_elemdist_rec.segment9, p_segment10 => c_elemdist_rec.segment10,
	      p_segment11 => c_elemdist_rec.segment11, p_segment12 => c_elemdist_rec.segment12,
	      p_segment13 => c_elemdist_rec.segment13, p_segment14 => c_elemdist_rec.segment14,
	      p_segment15 => c_elemdist_rec.segment15, p_segment16 => c_elemdist_rec.segment16,
	      p_segment17 => c_elemdist_rec.segment17, p_segment18 => c_elemdist_rec.segment18,
	      p_segment19 => c_elemdist_rec.segment19, p_segment20 => c_elemdist_rec.segment20,
	      p_segment21 => c_elemdist_rec.segment21, p_segment22 => c_elemdist_rec.segment22,
	      p_segment23 => c_elemdist_rec.segment23, p_segment24 => c_elemdist_rec.segment24,
	      p_segment25 => c_elemdist_rec.segment25, p_segment26 => c_elemdist_rec.segment26,
	      p_segment27 => c_elemdist_rec.segment27, p_segment28 => c_elemdist_rec.segment28,
	      p_segment29 => c_elemdist_rec.segment29, p_segment30 => c_elemdist_rec.segment30,
	      p_last_update_date => sysdate,
	      p_last_updated_by => g_userid,
	      p_last_update_login => g_loginid,
	      p_created_by => g_userid,
	      p_creation_date => sysdate);

	  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	    raise FND_API.G_EXC_ERROR;
	  end if;

	end loop; /* Element Distribution */

      end loop; /* Element Position Set Group */

    end; /* Element doesn't exist */
    else
    begin /* Element already exists in the global data extract */

      if c_elem_rec.option_flag = 'Y' then
      begin

	for c_elemoptions_rec in c_elemoptions (c_elem_rec.pay_element_id) loop

	  l_element_option_exists := FND_API.G_FALSE;

	  -- Check if Element Option already exists

	  for c_elemoptions_exists_rec in c_elemoptions_exists (c_elem_rec.pay_element_id, c_elemoptions_rec.name) loop
	    l_element_option_exists := FND_API.G_TRUE;
	  end loop;

	  if not FND_API.to_Boolean(l_element_option_exists) then
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
		p_last_updated_by => g_userid,
		p_last_update_login => g_loginid,
		p_created_by => g_userid,
		p_creation_date => sysdate);

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	      raise FND_API.G_EXC_ERROR;
	    end if;

	    for c_elemrates_rec in c_elemrates (c_elem_rec.pay_element_id, c_elemoptions_rec.pay_element_option_id) loop

	      if c_elemrates_rec.worksheet_id is null then
		l_worksheet_id := null;
	      else
		l_worksheet_id := g_global_worksheet_id;
	      end if;

	      for c_elemrates_seq_rec in c_elemrates_seq loop
		l_pay_element_rate_id := c_elemrates_seq_rec.seq;
	      end loop;

	      PSB_PAY_ELEMENT_RATES_PVT.Insert_Row
		 (p_api_version => 1.0,
		  p_return_status => l_return_status,
		  p_msg_count => l_msg_count,
		  p_msg_data => l_msg_data,
		  p_pay_element_rate_id => l_pay_element_rate_id,
		  p_pay_element_option_id => l_pay_element_option_id,
		  p_pay_element_id => l_pay_element_id,
		  p_effective_start_date => c_elemrates_rec.effective_start_date,
		  p_effective_end_date => c_elemrates_rec.effective_end_date,
		  p_worksheet_id => l_worksheet_id,
		  p_element_value_type => c_elemrates_rec.element_value_type,
		  p_element_value => c_elemrates_rec.element_value,
		  p_pay_basis => c_elemrates_rec.pay_basis,
		  p_formula_id => c_elemrates_rec.formula_id,
		  p_maximum_value => c_elemrates_rec.maximum_value,
		  p_mid_value => c_elemrates_rec.mid_value,
		  p_minimum_value => c_elemrates_rec.minimum_value,
		  p_currency_code => c_elemrates_rec.currency_code,
		  p_last_update_date => sysdate,
		  p_last_updated_by => g_userid,
		  p_last_update_login => g_loginid,
		  p_created_by => g_userid,
		  p_creation_date => sysdate);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      end if;

	    end loop;

	  end;
	  end if;

	end loop;

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

END Consolidate_Elements;

/* ----------------------------------------------------------------------- */

PROCEDURE Consolidate_Employees
( p_return_status            OUT  NOCOPY  VARCHAR2,
  p_local_data_extract_id    IN   NUMBER,
  p_local_business_group_id  IN   NUMBER
) IS

  l_employee_id              NUMBER;

  l_employee_exists          VARCHAR2(1);

  l_return_status            VARCHAR2(1);

  cursor c_emp is
    select *
      from PSB_EMPLOYEES
     where business_group_id = p_local_business_group_id
       and data_extract_id = p_local_data_extract_id;

  cursor c_emp_exists (empno NUMBER) is
    select employee_id
      from psb_employees
     where employee_number = empno
       and data_extract_id = g_global_data_extract_id;

  cursor c_emp_seq is
    select PSB_EMPLOYEES_S.NEXTVAL seq
      from dual;

BEGIN

  -- Loop for all employees in the local data extract

  for c_emp_rec in c_emp loop

    l_employee_exists := FND_API.G_FALSE;

    for c_emp_exists_rec in c_emp_exists (c_emp_rec.employee_number) loop
      l_employee_exists := FND_API.G_TRUE;
    end loop;

    -- If employee does not already exist in the global data extract create the employee

    if not FND_API.to_Boolean(l_employee_exists) then
    begin

      for c_emp_seq_rec in c_emp_seq loop
	l_employee_id := c_emp_seq_rec.seq;
      end loop;

     /*For Bug No : 2594575 Start*/
     --Stop extracting secured data of employee
     --Removed the columns in psb_employees table
     /*For Bug No : 2594575 End*/

     insert into PSB_EMPLOYEES
	    (employee_id, data_extract_id, business_group_id,
	     employee_number, hr_employee_id, first_name,
	     full_name, known_as, last_name,
	     middle_names, title,
	     creation_date, created_by, last_update_date,
	     last_updated_by, last_update_login)
     values (l_employee_id, g_global_data_extract_id, g_global_business_group_id,
	     c_emp_rec.employee_number, c_emp_rec.hr_employee_id, c_emp_rec.first_name,
	     c_emp_rec.full_name, c_emp_rec.known_as, c_emp_rec.last_name,
	     c_emp_rec.middle_names, c_emp_rec.title,
	     sysdate, g_userid, sysdate,
	     g_userid, g_loginid);

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

END Consolidate_Employees;

/* ----------------------------------------------------------------------- */

PROCEDURE Consolidate_Positions
( p_return_status            OUT  NOCOPY  VARCHAR2,
  p_local_worksheet_id       IN   NUMBER,
  p_local_data_extract_id    IN   NUMBER,
  p_local_business_group_id  IN   NUMBER
) IS

  l_position_id              NUMBER;
  l_position_assignment_id   NUMBER;
  l_distribution_id          NUMBER;

  l_attribute_id             NUMBER;
  l_attribute_value_id       NUMBER;
  l_worksheet_id             NUMBER;
  l_pay_element_id           NUMBER;
  l_pay_element_option_id    NUMBER;
  l_employee_id              NUMBER;

  l_position_exists          VARCHAR2(1);

  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_rowid                    VARCHAR2(100);

  l_return_status            VARCHAR2(1);

  cursor c_positions is
    select *
      from PSB_POSITIONS
     where data_extract_id = p_local_data_extract_id;

  cursor c_position_exists (posname VARCHAR2, hrposid NUMBER, hrempid NUMBER) is
    select position_id
      from PSB_POSITIONS
     where ((hrposid is null and (hrempid is null or hr_employee_id = hrempid) and name = posname)
	or ((hr_position_id = hrposid) and (hrempid is null or hr_employee_id = hrempid)))
       and data_extract_id = g_global_data_extract_id;

  cursor c_posassign_attr (positionid NUMBER) is
    select *
      from PSB_POSITION_ASSIGNMENTS
     where (worksheet_id is null or worksheet_id = p_local_worksheet_id)
       and assignment_type = 'ATTRIBUTE'
       and position_id = positionid;

  cursor c_re_attr (attrid NUMBER) is
    select a.attribute_id
      from PSB_ATTRIBUTES a,
	   PSB_ATTRIBUTES b
     where a.business_group_id = g_global_business_group_id
       and a.name = b.name
       and b.attribute_id = attrid;

  cursor c_re_attrval (attrvalid NUMBER) is
    select a.attribute_value_id
      from PSB_ATTRIBUTE_VALUES a,
	   PSB_ATTRIBUTE_VALUES b
     where a.data_extract_id = g_global_data_extract_id
       and a.attribute_value = b.attribute_value
       and a.attribute_id = b.attribute_id -- added this for Bug #4262388
       and b.attribute_value_id = attrvalid;

  cursor c_posassign_elem (positionid NUMBER) is
    select *
      from PSB_POSITION_ASSIGNMENTS
     where (worksheet_id is null or worksheet_id = p_local_worksheet_id)
       and assignment_type = 'ELEMENT'
       and position_id = positionid;

  cursor c_re_elem (elemid NUMBER) is
    select a.pay_element_id
      from PSB_PAY_ELEMENTS a,
	   PSB_PAY_ELEMENTS b
     where a.name = b.name
       and a.data_extract_id = g_global_data_extract_id
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
      from PSB_POSITION_ASSIGNMENTS
     where (worksheet_id is null or worksheet_id = p_local_worksheet_id)
       and assignment_type = 'EMPLOYEE'
       and position_id = positionid;

  cursor c_re_emp (empid NUMBER) is
    select a.employee_id
      from PSB_EMPLOYEES a,
	   PSB_EMPLOYEES b
     where a.employee_number = b.employee_number
       and a.data_extract_id = g_global_data_extract_id
       and b.employee_id = empid;

  cursor c_position_distr (positionid NUMBER) is
    select *
      from PSB_POSITION_PAY_DISTRIBUTIONS
     where position_id = positionid
       and (worksheet_id is null or worksheet_id = p_local_worksheet_id);

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

  -- Loop for all positions in the local data extract

  for c_positions_rec in c_positions loop

    l_position_exists := FND_API.G_FALSE;

    for c_position_exists_rec in c_position_exists (c_positions_rec.name, c_positions_rec.hr_position_id, c_positions_rec.hr_employee_id) loop
      l_position_exists := FND_API.G_TRUE;
    end loop;

    -- If position does not exist in the global data extract create the position

    if not FND_API.to_Boolean(l_position_exists) then
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
	  p_data_extract_id => g_global_data_extract_id,
	  p_position_definition_id => c_positions_rec.position_definition_id,
	  p_hr_position_id => c_positions_rec.hr_position_id,
	  p_hr_employee_id => c_positions_rec.hr_employee_id,
	  p_business_group_id => g_global_business_group_id,
	  -- de by org
	  p_organization_id => c_positions_rec.organization_id,
	  p_effective_start_date => c_positions_rec.effective_start_date,
	  p_effective_end_date => c_positions_rec.effective_end_date,
	  p_set_of_books_id => c_positions_rec.set_of_books_id,
	  p_vacant_position_flag => c_positions_rec.vacant_position_flag,
	  p_availability_status => c_positions_rec.availability_status,
	  p_transaction_id => c_positions_rec.transaction_id,
	  p_transaction_status => c_positions_rec.transaction_status,
	  p_new_position_flag => c_positions_rec.new_position_flag,
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

      -- Consolidate Position Attribute Assignments

      for c_posassign_attr_rec in c_posassign_attr (c_positions_rec.position_id) loop

	if c_posassign_attr_rec.worksheet_id is null then
	  l_worksheet_id := null;
	else
	  l_worksheet_id := g_global_worksheet_id;
	end if;

	for c_re_attr_rec in c_re_attr (c_posassign_attr_rec.attribute_id) loop
	  l_attribute_id := c_re_attr_rec.attribute_id;
	end loop;

	if c_posassign_attr_rec.attribute_value_id is not null then
	begin

	  for c_re_attrval_rec in c_re_attrval (c_posassign_attr_rec.attribute_value_id) loop
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
	    p_data_extract_id => g_global_data_extract_id,
	    p_worksheet_id => l_worksheet_id,
	    p_position_id => l_position_id,
	    p_assignment_type => 'ATTRIBUTE',
	    p_attribute_id => l_attribute_id,
	    p_attribute_value_id => l_attribute_value_id,
	    p_attribute_value => c_posassign_attr_rec.attribute_value,
	    p_pay_element_id => null,
	    p_pay_element_option_id => null,
	    p_effective_start_date => c_posassign_attr_rec.effective_start_date,
	    p_effective_end_date => c_posassign_attr_rec.effective_end_date,
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

      -- Consolidate Position Element Assignments

      for c_posassign_elem_rec in c_posassign_elem (c_positions_rec.position_id) loop

	if c_posassign_elem_rec.worksheet_id is null then
	  l_worksheet_id := null;
	else
	  l_worksheet_id := g_global_worksheet_id;
	end if;

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
	    p_data_extract_id => g_global_data_extract_id,
	    p_worksheet_id => l_worksheet_id,
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

      -- Consolidate Position Employee Assignments

      for c_posassign_emp_rec in c_posassign_emp (c_positions_rec.position_id) loop

	if c_posassign_emp_rec.worksheet_id is null then
	  l_worksheet_id := null;
	else
	  l_worksheet_id := g_global_worksheet_id;
	end if;

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
	    p_data_extract_id => g_global_data_extract_id,
	    p_worksheet_id => l_worksheet_id,
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

      -- Consolidate Position Salary Distributions

      for c_position_distr_rec in c_position_distr (c_positions_rec.position_id) loop

	if c_position_distr_rec.worksheet_id is null then
	  l_worksheet_id := null;
	else
	  l_worksheet_id := g_global_worksheet_id;
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
	    p_worksheet_id => l_worksheet_id,
	    p_position_id => l_position_id,
	    p_data_extract_id => g_global_data_extract_id,
	    p_effective_start_date => c_position_distr_rec.effective_start_date,
	    p_effective_end_date => c_position_distr_rec.effective_end_date,
	    p_chart_of_accounts_id => c_position_distr_rec.chart_of_accounts_id,
	    p_code_combination_id => c_position_distr_rec.code_combination_id,
	    p_distribution_percent => c_position_distr_rec.distribution_percent,
	    p_global_default_flag => null,
	    p_distribution_default_rule_id => null,
	    p_project_id => c_position_distr_rec.project_id,
	    p_task_id => c_position_distr_rec.task_id,
	    p_award_id => c_position_distr_rec.award_id,
	    p_expenditure_type => c_position_distr_rec.expenditure_type,
	    p_expenditure_organization_id => c_position_distr_rec.expenditure_organization_id,
	    p_description => c_position_distr_rec.description);

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

END Consolidate_Positions;

/* ----------------------------------------------------------------------- */

PROCEDURE Consolidate_Service_Packages
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_local_worksheet_id   IN   NUMBER
) IS

  l_service_package_id   NUMBER;

  l_sp_exists            VARCHAR2(1);

  l_return_status        VARCHAR2(1);

  cursor c_sp is
    select *
      from PSB_SERVICE_PACKAGES
     where global_worksheet_id = p_local_worksheet_id;

  cursor c_sp_exists (name VARCHAR2) is
    select service_package_id
      from PSB_SERVICE_PACKAGES
     where short_name = name
       and global_worksheet_id = g_global_worksheet_id;

  cursor c_sp_seq is
    select PSB_SERVICE_PACKAGES_S.NEXTVAL seq
      from dual;

BEGIN

  -- Loop for all service packages in the local worksheet

  for c_sp_rec in c_sp loop

    l_sp_exists := FND_API.G_FALSE;

    for c_sp_exists_rec in c_sp_exists (c_sp_rec.short_name) loop
      l_sp_exists := FND_API.G_TRUE;
    end loop;

    if not FND_API.to_Boolean(l_sp_exists) then
    begin

      for c_sp_seq_rec in c_sp_seq loop
	l_service_package_id := c_sp_seq_rec.seq;
      end loop;

      insert into PSB_SERVICE_PACKAGES
	    (service_package_id, global_worksheet_id, base_service_package, name,
	     short_name, description, priority, last_update_date, last_updated_by,
	     last_update_login, created_by, creation_date)
      values (l_service_package_id, g_global_worksheet_id, c_sp_rec.base_service_package, c_sp_rec.name,
	      c_sp_rec.short_name, c_sp_rec.description, c_sp_rec.priority, sysdate, g_userid,
	      g_loginid, g_userid, sysdate);

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

END Consolidate_Service_Packages;

/* ----------------------------------------------------------------------- */

PROCEDURE Consolidate_Local_Worksheets
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_local_worksheet_id   IN   NUMBER,
  p_global_worksheet_id  IN   NUMBER
) IS

  l_period_amount       PSB_WS_ACCT1.g_prdamt_tbl_type;
  l_period_fte          PSB_WS_ACCT1.g_prdamt_tbl_type;

  l_account_line_id     NUMBER;
  l_position_line_id    NUMBER;
  l_fte_line_id         NUMBER;
  l_element_line_id     NUMBER;

  l_service_package_id  NUMBER;
  l_pay_element_id      NUMBER;
  l_position_id         NUMBER;

  l_position_exists     BOOLEAN;

  l_return_status       VARCHAR2(1);

  cursor c_wal_nps is
    select *
      from PSB_WS_ACCOUNT_LINES a
     where position_line_id is null
       and exists
	  (select 1
	     from PSB_WS_LINES b
	    where b.account_line_id = a.account_line_id
	      and b.worksheet_id = p_local_worksheet_id)
     order by a.code_combination_id, a.current_stage_seq;

  cursor c_wal_ps (poslineid NUMBER) is
    select *
      from PSB_WS_ACCOUNT_LINES
     where position_line_id = poslineid
     order by position_line_id, current_stage_seq;

  cursor c_wpl is
    select *
      from PSB_WS_POSITION_LINES a
     where exists
	  (select 1
	     from PSB_WS_LINES_POSITIONS b
	    where b.position_line_id = a.position_line_id
	      and b.worksheet_id = p_local_worksheet_id);

  cursor c_wfl (poslineid NUMBER) is
    select *
      from PSB_WS_FTE_LINES
     where position_line_id = poslineid
     order by position_line_id, current_stage_seq;

  cursor c_wel (poslineid NUMBER) is
    select *
      from PSB_WS_ELEMENT_LINES
     where position_line_id = poslineid
     order by position_line_id, current_stage_seq;

  cursor c_re_elem (elemid NUMBER) is
    select a.pay_element_id
      from PSB_PAY_ELEMENTS a,
	   PSB_PAY_ELEMENTS b
     where a.name = b.name
       and a.data_extract_id = g_global_data_extract_id
       and b.pay_element_id = elemid;

  cursor c_re_pos (posid NUMBER) is
    select a.position_id
      from PSB_POSITIONS a,
	   PSB_POSITIONS b
     where (b.hr_employee_id is null or a.hr_employee_id = b.hr_employee_id)
       and a.name = b.name
       and a.data_extract_id = g_global_data_extract_id
       and b.position_id = posid;

  cursor c_position_exists (posid NUMBER) is
    select 'Exists'
      from dual
     where exists
	  (select 1
	     from PSB_WS_POSITION_LINES a,
		  PSB_WS_LINES_POSITIONS b
	    where a.position_line_id = b.position_line_id
	      and a.position_id = posid
	      and b.worksheet_id = p_global_worksheet_id);

  cursor c_re_sp (spid NUMBER) is
    select a.service_package_id
      from PSB_SERVICE_PACKAGES a,
	   PSB_SERVICE_PACKAGES b
     where a.short_name = b.short_name
       and a.global_worksheet_id = g_global_worksheet_id
       and b.service_package_id = spid;

BEGIN

  -- First Consolidate all non-Position Account Lines

  for c_wal_rec in c_wal_nps loop

    l_period_amount(1) := c_wal_rec.period1_amount; l_period_amount(2) := c_wal_rec.period2_amount;
    l_period_amount(3) := c_wal_rec.period3_amount; l_period_amount(4) := c_wal_rec.period4_amount;
    l_period_amount(5) := c_wal_rec.period5_amount; l_period_amount(6) := c_wal_rec.period6_amount;
    l_period_amount(7) := c_wal_rec.period7_amount; l_period_amount(8) := c_wal_rec.period8_amount;
    l_period_amount(9) := c_wal_rec.period9_amount; l_period_amount(10) := c_wal_rec.period10_amount;
    l_period_amount(11) := c_wal_rec.period11_amount; l_period_amount(12) := c_wal_rec.period12_amount;
    l_period_amount(13) := c_wal_rec.period13_amount; l_period_amount(14) := c_wal_rec.period14_amount;
    l_period_amount(15) := c_wal_rec.period15_amount; l_period_amount(16) := c_wal_rec.period16_amount;
    l_period_amount(17) := c_wal_rec.period17_amount; l_period_amount(18) := c_wal_rec.period18_amount;
    l_period_amount(19) := c_wal_rec.period19_amount; l_period_amount(20) := c_wal_rec.period20_amount;
    l_period_amount(21) := c_wal_rec.period21_amount; l_period_amount(22) := c_wal_rec.period22_amount;
    l_period_amount(23) := c_wal_rec.period23_amount; l_period_amount(24) := c_wal_rec.period24_amount;
    l_period_amount(25) := c_wal_rec.period25_amount; l_period_amount(26) := c_wal_rec.period26_amount;
    l_period_amount(27) := c_wal_rec.period27_amount; l_period_amount(28) := c_wal_rec.period28_amount;
    l_period_amount(29) := c_wal_rec.period29_amount; l_period_amount(30) := c_wal_rec.period30_amount;
    l_period_amount(31) := c_wal_rec.period31_amount; l_period_amount(32) := c_wal_rec.period32_amount;
    l_period_amount(33) := c_wal_rec.period33_amount; l_period_amount(34) := c_wal_rec.period34_amount;
    l_period_amount(35) := c_wal_rec.period35_amount; l_period_amount(36) := c_wal_rec.period36_amount;
    l_period_amount(37) := c_wal_rec.period37_amount; l_period_amount(38) := c_wal_rec.period38_amount;
    l_period_amount(39) := c_wal_rec.period39_amount; l_period_amount(40) := c_wal_rec.period40_amount;
    l_period_amount(41) := c_wal_rec.period41_amount; l_period_amount(42) := c_wal_rec.period42_amount;
    l_period_amount(43) := c_wal_rec.period43_amount; l_period_amount(44) := c_wal_rec.period44_amount;
    l_period_amount(45) := c_wal_rec.period45_amount; l_period_amount(46) := c_wal_rec.period46_amount;
    l_period_amount(47) := c_wal_rec.period47_amount; l_period_amount(48) := c_wal_rec.period48_amount;
    l_period_amount(49) := c_wal_rec.period49_amount; l_period_amount(50) := c_wal_rec.period50_amount;
    l_period_amount(51) := c_wal_rec.period51_amount; l_period_amount(52) := c_wal_rec.period52_amount;
    l_period_amount(53) := c_wal_rec.period53_amount; l_period_amount(54) := c_wal_rec.period54_amount;
    l_period_amount(55) := c_wal_rec.period55_amount; l_period_amount(56) := c_wal_rec.period56_amount;
    l_period_amount(57) := c_wal_rec.period57_amount; l_period_amount(58) := c_wal_rec.period58_amount;
    l_period_amount(59) := c_wal_rec.period59_amount; l_period_amount(60) := c_wal_rec.period60_amount;

    for c_re_sp_rec in c_re_sp (c_wal_rec.service_package_id) loop
      l_service_package_id := c_re_sp_rec.service_package_id;
    end loop;

    PSB_WS_ACCT1.Create_Account_Dist
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_account_line_id => l_account_line_id,
	p_worksheet_id => g_global_worksheet_id,
	p_check_spal_exists => FND_API.G_FALSE,
	p_gl_cutoff_period => null,
	p_allocrule_set_id => null,
	p_budget_calendar_id => null,
	p_rounding_factor => null,
	p_stage_set_id => c_wal_rec.stage_set_id,
	p_budget_year_id => c_wal_rec.budget_year_id,
	p_budget_group_id => c_wal_rec.budget_group_id,
	p_ccid => c_wal_rec.code_combination_id,
	p_flex_code => null,
	p_template_id => c_wal_rec.template_id,
	p_currency_code => c_wal_rec.currency_code,
	p_balance_type => c_wal_rec.balance_type,
	p_ytd_amount => c_wal_rec.ytd_amount,
	p_period_amount => l_period_amount,
	p_service_package_id => l_service_package_id,
	p_start_stage_seq => c_wal_rec.start_stage_seq,
	p_current_stage_seq => c_wal_rec.current_stage_seq,
	p_end_stage_seq => c_wal_rec.end_stage_seq,
	p_copy_of_account_line_id => null);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  end loop;

  -- Now Consolidate all Position Lines

  for c_wpl_rec in c_wpl loop

    for c_re_pos_rec in c_re_pos (c_wpl_rec.position_id) loop
      l_position_id := c_re_pos_rec.position_id;
    end loop;

    l_position_exists := FALSE;

    for c_position_exists_rec in c_position_exists (l_position_id) loop
      l_position_exists := TRUE;
    end loop;

    if not (l_position_exists) then
    begin

      PSB_WS_POS1.Create_Position_Lines
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_position_line_id => l_position_line_id,
	  p_worksheet_id => g_global_worksheet_id,
	  p_position_id => l_position_id,
	  p_budget_group_id => c_wpl_rec.budget_group_id,
	  p_copy_of_position_line_id => null);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      for c_wfl_rec in c_wfl (c_wpl_rec.position_line_id) loop

	l_period_fte(1) := c_wfl_rec.period1_fte; l_period_fte(2) := c_wfl_rec.period2_fte;
	l_period_fte(3) := c_wfl_rec.period3_fte; l_period_fte(4) := c_wfl_rec.period4_fte;
	l_period_fte(5) := c_wfl_rec.period5_fte; l_period_fte(6) := c_wfl_rec.period6_fte;
	l_period_fte(7) := c_wfl_rec.period7_fte; l_period_fte(8) := c_wfl_rec.period8_fte;
	l_period_fte(9) := c_wfl_rec.period9_fte; l_period_fte(10) := c_wfl_rec.period10_fte;
	l_period_fte(11) := c_wfl_rec.period11_fte; l_period_fte(12) := c_wfl_rec.period12_fte;
	l_period_fte(13) := c_wfl_rec.period13_fte; l_period_fte(14) := c_wfl_rec.period14_fte;
	l_period_fte(15) := c_wfl_rec.period15_fte; l_period_fte(16) := c_wfl_rec.period16_fte;
	l_period_fte(17) := c_wfl_rec.period17_fte; l_period_fte(18) := c_wfl_rec.period18_fte;
	l_period_fte(19) := c_wfl_rec.period19_fte; l_period_fte(20) := c_wfl_rec.period20_fte;
	l_period_fte(21) := c_wfl_rec.period21_fte; l_period_fte(22) := c_wfl_rec.period22_fte;
	l_period_fte(23) := c_wfl_rec.period23_fte; l_period_fte(24) := c_wfl_rec.period24_fte;
	l_period_fte(25) := c_wfl_rec.period25_fte; l_period_fte(26) := c_wfl_rec.period26_fte;
	l_period_fte(27) := c_wfl_rec.period27_fte; l_period_fte(28) := c_wfl_rec.period28_fte;
	l_period_fte(29) := c_wfl_rec.period29_fte; l_period_fte(30) := c_wfl_rec.period30_fte;
	l_period_fte(31) := c_wfl_rec.period31_fte; l_period_fte(32) := c_wfl_rec.period32_fte;
	l_period_fte(33) := c_wfl_rec.period33_fte; l_period_fte(34) := c_wfl_rec.period34_fte;
	l_period_fte(35) := c_wfl_rec.period35_fte; l_period_fte(36) := c_wfl_rec.period36_fte;
	l_period_fte(37) := c_wfl_rec.period37_fte; l_period_fte(38) := c_wfl_rec.period38_fte;
	l_period_fte(39) := c_wfl_rec.period39_fte; l_period_fte(40) := c_wfl_rec.period40_fte;
	l_period_fte(41) := c_wfl_rec.period41_fte; l_period_fte(42) := c_wfl_rec.period42_fte;
	l_period_fte(43) := c_wfl_rec.period43_fte; l_period_fte(44) := c_wfl_rec.period44_fte;
	l_period_fte(45) := c_wfl_rec.period45_fte; l_period_fte(46) := c_wfl_rec.period46_fte;
	l_period_fte(47) := c_wfl_rec.period47_fte; l_period_fte(48) := c_wfl_rec.period48_fte;
	l_period_fte(49) := c_wfl_rec.period49_fte; l_period_fte(50) := c_wfl_rec.period50_fte;
	l_period_fte(51) := c_wfl_rec.period51_fte; l_period_fte(52) := c_wfl_rec.period52_fte;
	l_period_fte(53) := c_wfl_rec.period53_fte; l_period_fte(54) := c_wfl_rec.period54_fte;
	l_period_fte(55) := c_wfl_rec.period55_fte; l_period_fte(56) := c_wfl_rec.period56_fte;
	l_period_fte(57) := c_wfl_rec.period57_fte; l_period_fte(58) := c_wfl_rec.period58_fte;
	l_period_fte(59) := c_wfl_rec.period59_fte; l_period_fte(60) := c_wfl_rec.period60_fte;

	for c_re_sp_rec in c_re_sp (c_wfl_rec.service_package_id) loop
	  l_service_package_id := c_re_sp_rec.service_package_id;
	end loop;

	PSB_WS_POS1.Create_FTE_Lines
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_fte_line_id => l_fte_line_id,
	    p_check_spfl_exists => FND_API.G_FALSE,
	    p_worksheet_id => g_global_worksheet_id,
	    p_position_line_id => l_position_line_id,
	    p_budget_year_id => c_wfl_rec.budget_year_id,
	    p_annual_fte => c_wfl_rec.annual_fte,
	    p_service_package_id => l_service_package_id,
	    p_stage_set_id => c_wfl_rec.stage_set_id,
	    p_start_stage_seq => c_wfl_rec.start_stage_seq,
	    p_current_stage_seq => c_wfl_rec.current_stage_seq,
	    p_end_stage_seq => c_wfl_rec.end_stage_seq,
	    p_period_fte => l_period_fte);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end loop;

      for c_wel_rec in c_wel (c_wpl_rec.position_line_id) loop

	for c_re_sp_rec in c_re_sp (c_wel_rec.service_package_id) loop
	  l_service_package_id := c_re_sp_rec.service_package_id;
	end loop;

	for c_re_elem_rec in c_re_elem (c_wel_rec.pay_element_id) loop
	  l_pay_element_id := c_re_elem_rec.pay_element_id;
	end loop;

	PSB_WS_POS1.Create_Element_Lines
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_element_line_id => l_element_line_id,
	    p_check_spel_exists => FND_API.G_FALSE,
	    p_position_line_id => l_position_line_id,
	    p_budget_year_id => c_wel_rec.budget_year_id,
	    p_pay_element_id => l_pay_element_id,
	    p_currency_code => c_wel_rec.currency_code,
	    p_element_cost => c_wel_rec.element_cost,
	    p_element_set_id => c_wel_rec.element_set_id,
	    p_service_package_id => l_service_package_id,
	    p_stage_set_id => c_wel_rec.stage_set_id,
	    p_start_stage_seq => c_wel_rec.start_stage_seq,
	    p_current_stage_seq => c_wel_rec.current_stage_seq,
	    p_end_stage_seq => c_wel_rec.end_stage_seq);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end loop;

      for c_wal_rec in c_wal_ps (c_wpl_rec.position_line_id) loop

	l_period_amount(1) := c_wal_rec.period1_amount; l_period_amount(2) := c_wal_rec.period2_amount;
	l_period_amount(3) := c_wal_rec.period3_amount; l_period_amount(4) := c_wal_rec.period4_amount;
	l_period_amount(5) := c_wal_rec.period5_amount; l_period_amount(6) := c_wal_rec.period6_amount;
	l_period_amount(7) := c_wal_rec.period7_amount; l_period_amount(8) := c_wal_rec.period8_amount;
	l_period_amount(9) := c_wal_rec.period9_amount; l_period_amount(10) := c_wal_rec.period10_amount;
	l_period_amount(11) := c_wal_rec.period11_amount; l_period_amount(12) := c_wal_rec.period12_amount;
	l_period_amount(13) := c_wal_rec.period13_amount; l_period_amount(14) := c_wal_rec.period14_amount;
	l_period_amount(15) := c_wal_rec.period15_amount; l_period_amount(16) := c_wal_rec.period16_amount;
	l_period_amount(17) := c_wal_rec.period17_amount; l_period_amount(18) := c_wal_rec.period18_amount;
	l_period_amount(19) := c_wal_rec.period19_amount; l_period_amount(20) := c_wal_rec.period20_amount;
	l_period_amount(21) := c_wal_rec.period21_amount; l_period_amount(22) := c_wal_rec.period22_amount;
	l_period_amount(23) := c_wal_rec.period23_amount; l_period_amount(24) := c_wal_rec.period24_amount;
	l_period_amount(25) := c_wal_rec.period25_amount; l_period_amount(26) := c_wal_rec.period26_amount;
	l_period_amount(27) := c_wal_rec.period27_amount; l_period_amount(28) := c_wal_rec.period28_amount;
	l_period_amount(29) := c_wal_rec.period29_amount; l_period_amount(30) := c_wal_rec.period30_amount;
	l_period_amount(31) := c_wal_rec.period31_amount; l_period_amount(32) := c_wal_rec.period32_amount;
	l_period_amount(33) := c_wal_rec.period33_amount; l_period_amount(34) := c_wal_rec.period34_amount;
	l_period_amount(35) := c_wal_rec.period35_amount; l_period_amount(36) := c_wal_rec.period36_amount;
	l_period_amount(37) := c_wal_rec.period37_amount; l_period_amount(38) := c_wal_rec.period38_amount;
	l_period_amount(39) := c_wal_rec.period39_amount; l_period_amount(40) := c_wal_rec.period40_amount;
	l_period_amount(41) := c_wal_rec.period41_amount; l_period_amount(42) := c_wal_rec.period42_amount;
	l_period_amount(43) := c_wal_rec.period43_amount; l_period_amount(44) := c_wal_rec.period44_amount;
	l_period_amount(45) := c_wal_rec.period45_amount; l_period_amount(46) := c_wal_rec.period46_amount;
	l_period_amount(47) := c_wal_rec.period47_amount; l_period_amount(48) := c_wal_rec.period48_amount;
	l_period_amount(49) := c_wal_rec.period49_amount; l_period_amount(50) := c_wal_rec.period50_amount;
	l_period_amount(51) := c_wal_rec.period51_amount; l_period_amount(52) := c_wal_rec.period52_amount;
	l_period_amount(53) := c_wal_rec.period53_amount; l_period_amount(54) := c_wal_rec.period54_amount;
	l_period_amount(55) := c_wal_rec.period55_amount; l_period_amount(56) := c_wal_rec.period56_amount;
	l_period_amount(57) := c_wal_rec.period57_amount; l_period_amount(58) := c_wal_rec.period58_amount;
	l_period_amount(59) := c_wal_rec.period59_amount; l_period_amount(60) := c_wal_rec.period60_amount;

	for c_re_sp_rec in c_re_sp (c_wal_rec.service_package_id) loop
	  l_service_package_id := c_re_sp_rec.service_package_id;
	end loop;

	PSB_WS_ACCT1.Create_Account_Dist
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_account_line_id => l_account_line_id,
	    p_worksheet_id => g_global_worksheet_id,
	    p_check_spal_exists => FND_API.G_FALSE,
	    p_gl_cutoff_period => null,
	    p_allocrule_set_id => null,
	    p_budget_calendar_id => null,
	    p_rounding_factor => null,
	    p_stage_set_id => c_wal_rec.stage_set_id,
	    p_budget_year_id => c_wal_rec.budget_year_id,
	    p_budget_group_id => c_wal_rec.budget_group_id,
	    p_ccid => c_wal_rec.code_combination_id,
	    p_currency_code => c_wal_rec.currency_code,
	    p_balance_type => c_wal_rec.balance_type,
	    p_ytd_amount => c_wal_rec.ytd_amount,
	    p_period_amount => l_period_amount,
	    p_position_line_id => l_position_line_id,
	    p_element_set_id => c_wal_rec.element_set_id,
	    p_salary_account_line => c_wal_rec.salary_account_line,
	    p_service_package_id => l_service_package_id,
	    p_start_stage_seq => c_wal_rec.start_stage_seq,
	    p_current_stage_seq => c_wal_rec.current_stage_seq,
	    p_end_stage_seq => c_wal_rec.end_stage_seq);

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

END Consolidate_Local_Worksheets;

/* ----------------------------------------------------------------------- */

PROCEDURE Consolidate_Worksheets
( p_api_version          IN   NUMBER,
  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status        OUT  NOCOPY  VARCHAR2,
  p_global_worksheet_id  IN   NUMBER
) IS

  l_api_name             CONSTANT VARCHAR2(30)   := 'Consolidate_Worksheets';
  l_api_version          CONSTANT NUMBER         := 1.0;

  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);

  l_return_status        VARCHAR2(1);

  cursor c_Global_WS is
    select b.data_extract_id,
	   a.business_group_id
      from PSB_DATA_EXTRACTS a,
	   PSB_WORKSHEETS b
     where a.data_extract_id = b.data_extract_id
       and b.worksheet_id = p_global_worksheet_id;

  cursor c_Local_WS_Pos is
    select c.local_worksheet_id,
	   b.data_extract_id,
	   a.business_group_id
      from PSB_DATA_EXTRACTS a,
	   PSB_WORKSHEETS b,
	   PSB_WS_CONSOLIDATION_DETAILS c
     where a.data_extract_id = b.data_extract_id
       and b.worksheet_id = c.local_worksheet_id
       and c.global_worksheet_id = p_global_worksheet_id;

  cursor c_Local_WS is
    select local_worksheet_id
      from PSB_WS_CONSOLIDATION_DETAILS
     where global_worksheet_id = p_global_worksheet_id;

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
      p_worksheet_id => p_global_worksheet_id,
      p_ws_creation_complete => 'N');

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  commit work;

  -- Lock Global Worksheet in Exclusive Mode

  PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_concurrency_class => 'WORKSHEET_CONSOLIDATION',
      p_concurrency_entity_name => 'WORKSHEET',
      p_concurrency_entity_id => p_global_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  for c_Global_WS_Rec in c_Global_WS loop
    g_global_data_extract_id := c_Global_WS_Rec.data_extract_id;
    g_global_business_group_id := c_Global_WS_Rec.business_group_id;
  end loop;

  g_global_worksheet_id := p_global_worksheet_id;
  g_userid := FND_GLOBAL.USER_ID;
  g_loginid := FND_GLOBAL.LOGIN_ID;

  -- Worksheet Consolidation is a 3-phase process. In the first phase the building
  -- blocks for all the worksheets (attributes, elements, employees, positions)
  -- are consolidated to eliminate duplication. In the second phase the service
  -- packages for all the local worksheets are consolidated. In the third phase all
  -- the local worksheets are consolidated

  for c_Local_WS_Rec in c_Local_WS_Pos loop

    PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_concurrency_class => 'WORKSHEET_CONSOLIDATION',
	p_concurrency_entity_name => 'DATA_EXTRACT',
	p_concurrency_entity_id => c_Local_WS_Rec.data_extract_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    Consolidate_Attributes
	       (p_return_status => l_return_status,
		p_local_data_extract_id => c_Local_WS_Rec.data_extract_id,
		p_local_business_group_id => c_Local_WS_Rec.business_group_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    Consolidate_Elements
	       (p_return_status => l_return_status,
		p_local_worksheet_id => c_Local_WS_Rec.local_worksheet_id,
		p_local_data_extract_id => c_Local_WS_Rec.data_extract_id,
		p_local_business_group_id => c_Local_WS_Rec.business_group_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    Consolidate_Employees
	       (p_return_status => l_return_status,
		p_local_data_extract_id => c_Local_WS_Rec.data_extract_id,
		p_local_business_group_id => c_Local_WS_Rec.business_group_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    Consolidate_Positions
	       (p_return_status => l_return_status,
		p_local_worksheet_id => c_Local_WS_Rec.local_worksheet_id,
		p_local_data_extract_id => c_Local_WS_Rec.data_extract_id,
		p_local_business_group_id => c_Local_WS_Rec.business_group_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    commit work;

  end loop;

  -- Create Positions from the consolidated Position Sets

  PSB_Budget_Position_Pvt.Populate_Budget_Positions
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_msg_count => l_msg_count,
      p_msg_data => l_msg_data,
      p_data_extract_id => g_global_data_extract_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
  end if;

  -- In the second phase consolidate the service packages for all local worksheets

  for c_Local_WS_Rec in c_Local_WS loop

    -- Lock Local Worksheet in Exclusive Mode

    PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_concurrency_class => 'WORKSHEET_CONSOLIDATION',
	p_concurrency_entity_name => 'WORKSHEET',
	p_concurrency_entity_id => c_Local_WS_Rec.local_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    Consolidate_Service_Packages
	       (p_return_status => l_return_status,
		p_local_worksheet_id => c_Local_WS_Rec.local_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    commit work;

  end loop;

  -- In the third phase consolidate all local worksheets

  for c_Local_WS_Rec in c_Local_WS loop

    -- Lock Local Worksheet in Exclusive Mode

    PSB_CONCURRENCY_CONTROL_PVT.Enforce_Concurrency_Control
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_concurrency_class => 'WORKSHEET_CONSOLIDATION',
	p_concurrency_entity_name => 'WORKSHEET',
	p_concurrency_entity_id => c_Local_WS_Rec.local_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    Consolidate_Local_Worksheets
	       (p_return_status => l_return_status,
		p_local_worksheet_id => c_Local_WS_Rec.local_worksheet_id,
		p_global_worksheet_id => p_global_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    commit work;

  end loop;

  PSB_WORKSHEET.Update_Worksheet
     (p_api_version => 1.0,
      p_return_status => l_return_status,
      p_worksheet_id => p_global_worksheet_id,
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

END Consolidate_Worksheets;

/* ----------------------------------------------------------------------- */

PROCEDURE Validate_Consolidation
( p_api_version          IN   NUMBER,
  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status        OUT  NOCOPY  VARCHAR2,
  p_global_worksheet_id  IN   NUMBER
) IS

  l_api_name             CONSTANT VARCHAR2(30)   := 'Validate_Consolidation';
  l_api_version          CONSTANT NUMBER         := 1.0;

  l_freeze_flag          VARCHAR2(1);
  l_stage_set_id         NUMBER;
  l_current_stage_seq    NUMBER;
  l_budget_calendar_id   NUMBER;
  l_budget_by_position   VARCHAR2(1);
  l_budget_group_id      NUMBER;
  l_set_of_books_id      NUMBER;

  l_budget_group_exists  VARCHAR2(1);

  l_return_status        VARCHAR2(1);

  cursor c_Global_WS is
    select nvl(b.freeze_flag, 'N') freeze_flag,
	   b.stage_set_id,
	   b.current_stage_seq,
	   b.budget_calendar_id,
	   b.budget_by_position,
	   b.budget_group_id,
	   nvl(a.set_of_books_id, a.root_set_of_books_id) set_of_books_id
      from PSB_BUDGET_GROUPS_V a,
	   PSB_WORKSHEETS b
     where a.budget_group_id = b.budget_group_id
       and b.worksheet_id = p_global_worksheet_id;

  cursor c_Local_WS is
    select b.name,
	   b.global_worksheet_flag,
	   b.stage_set_id,
	   b.current_stage_seq,
	   b.budget_calendar_id,
	   b.budget_by_position,
	   b.budget_group_id,
	   nvl(a.set_of_books_id, a.root_set_of_books_id) set_of_books_id
      from PSB_BUDGET_GROUPS_V a,
	   PSB_WORKSHEETS b,
	   PSB_WS_CONSOLIDATION_DETAILS c
     where a.budget_group_id = b.budget_group_id
       and b.worksheet_id = c.local_worksheet_id
       and c.global_worksheet_id = p_global_worksheet_id;

  cursor c_BudGrp (budgetgroup_id NUMBER) is
    select budget_group_id
      from PSB_BUDGET_GROUPS
     where budget_group_type = 'R'
       and budget_group_id = budgetgroup_id
       and effective_start_date <= PSB_WS_ACCT1.g_startdate_pp
       and (effective_end_date is null or effective_end_date >= PSB_WS_ACCT1.g_enddate_cy)
     start with budget_group_id = l_budget_group_id
   connect by prior budget_group_id = parent_budget_group_id;



BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  for c_Global_WS_Rec in c_Global_WS loop
    l_freeze_flag := c_Global_WS_Rec.freeze_flag;
    l_stage_set_id := c_Global_WS_Rec.stage_set_id;
    l_current_stage_seq := c_Global_WS_Rec.current_stage_seq;
    l_budget_calendar_id := c_Global_WS_Rec.budget_calendar_id;
    l_budget_by_position := c_Global_WS_Rec.budget_by_position;
    l_budget_group_id := c_Global_WS_Rec.budget_group_id;
    l_set_of_books_id := c_Global_WS_Rec.set_of_books_id;
  end loop;

  if l_freeze_flag = 'Y' then
    add_message('PSB', 'PSB_TARGET_WORKSHEET_IS_FROZEN');
    raise FND_API.G_EXC_ERROR;
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

  for c_Local_WS_Rec in c_Local_WS loop

    -- Check that every local worksheet is a global worksheet

    if c_Local_WS_Rec.global_worksheet_flag <> 'Y' then
      message_token('WORKSHEET', c_Local_WS_Rec.name);
      add_message('PSB', 'PSB_CONS_NOT_GLOBAL');
      raise FND_API.G_EXC_ERROR;
    end if;

    -- Check that the stage set of every local worksheet matches the global worksheet

    if c_Local_WS_Rec.stage_set_id <> l_stage_set_id then
      message_token('WORKSHEET', c_Local_WS_Rec.name);
      add_message('PSB', 'PSB_CONS_MISMATCH_STAGESET');
      raise FND_API.G_EXC_ERROR;
    end if;

    -- Check that the current stage sequence of every local worksheet matches the global worksheet

    if c_Local_WS_Rec.current_stage_seq <> l_current_stage_seq then
      message_token('WORKSHEET', c_Local_WS_Rec.name);
      add_message('PSB', 'PSB_CONS_MISMATCH_STAGESEQ');
      raise FND_API.G_EXC_ERROR;
    end if;

    -- Check that the set of books for every local worksheet matches the global worksheet

    if c_Local_WS_Rec.set_of_books_id <> l_set_of_books_id then
      message_token('WORKSHEET', c_Local_WS_Rec.name);
      add_message('PSB', 'PSB_CONS_MISMATCH_SOB');
      raise FND_API.G_EXC_ERROR;
    end if;

    -- Check that the budget calendar of every local worksheet matches the global worksheet

    if c_Local_WS_Rec.budget_calendar_id <> l_budget_calendar_id then
      message_token('WORKSHEET', c_Local_WS_Rec.name);
      add_message('PSB', 'PSB_CONS_MISMATCH_CAL');
      raise FND_API.G_EXC_ERROR;
    end if;

    -- Check that position worksheets are not consolidated into a line-item global worksheet

    if ((l_budget_by_position = 'N') and (c_Local_WS_Rec.budget_by_position <> l_budget_by_position)) then
      message_token('WORKSHEET', c_Local_WS_Rec.name);
      add_message('PSB', 'PSB_CONS_MISMATCH_POS');
      raise FND_API.G_EXC_ERROR;
    end if;

    -- Check that the budget group of every local worksheet belongs to the global worksheet budget group hierarchy

    l_budget_group_exists := FND_API.G_FALSE;

    for c_BudGrp_Rec in c_BudGrp (c_Local_WS_Rec.budget_group_id) loop
      l_budget_group_exists := FND_API.G_TRUE;
    end loop;

    if not FND_API.to_Boolean(l_budget_group_exists) then
    begin

      if c_Local_WS_Rec.budget_group_id <> l_budget_group_id then
	message_token('WORKSHEET', c_Local_WS_Rec.name);
	add_message('PSB', 'PSB_CONS_MISMATCH_BGH');
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
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

END Validate_Consolidation;

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

END PSB_WORKSHEET_CONSOLIDATE;

/
