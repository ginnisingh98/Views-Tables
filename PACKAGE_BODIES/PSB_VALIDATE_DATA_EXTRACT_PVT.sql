--------------------------------------------------------
--  DDL for Package Body PSB_VALIDATE_DATA_EXTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_VALIDATE_DATA_EXTRACT_PVT" AS
/* $Header: PSBPPVHB.pls 120.3 2005/03/02 17:39:26 viraghun ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_VALIDATE_DATA_EXTRACT_PVT';
  g_dbug              VARCHAR2(2000);

  TYPE TokNameArray IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

  -- TokValArray contains values for all tokens

  TYPE TokValArray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;

  -- Number of Message Tokens
  no_msg_tokens       NUMBER := 0;

  -- Message Token Name
  msg_tok_names       TokNameArray;

  -- Message Token Value
  msg_tok_val         TokValArray;

  PROCEDURE message_token
  ( tokname IN  VARCHAR2,
    tokval  IN  VARCHAR2
  );

  PROCEDURE add_message
  ( appname  IN  VARCHAR2,
    msgname  IN  VARCHAR2
  );

/* ----------------------------------------------------------------------- */

PROCEDURE Data_Extract_Summary
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_data_extract_id     IN      NUMBER
)
AS
  l_positions           number;
  l_vacant_positions    number;
  l_employee_cnt        number;
  l_salary_cnt          number;
  l_cost_cnt            number;
  l_attr_cnt            number;
  l_emp_assign_cnt      number;
  l_msg_buf             varchar2(1000);
  l_msg_count           number;
  l_reqid               number;
  l_userid              number;
  l_restart_id          number;
  l_status              varchar2(1);
  l_return_status       varchar2(1);
  l_msg_data            varchar2(1000);

  l_api_name            CONSTANT VARCHAR2(30)   := 'Data_Extract_Summary';
  l_api_version         CONSTANT NUMBER         :=  1.0;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT     Data_Extract_Summary;

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

  Select count(*)
    into l_positions
    from psb_positions_i
   where data_extract_id   = p_data_extract_id
     and hr_employee_id is not null;

   add_message('PSB','PSB_DE_SUMMARY_HEADER');
   message_token('POSITION_COUNT',l_positions );
   add_message('PSB', 'PSB_ASSIGNED_POSITIONS_COUNT');

   Select count(*)
     into l_vacant_positions
     from psb_positions_i pp
    where pp.data_extract_id      = p_data_extract_id
     and hr_employee_id is null;

   message_token('VACANT_POSITION',l_vacant_positions );
   add_message('PSB', 'PSB_VACANT_POSITIONS_COUNT');

   Select count(*)
     into l_employee_cnt
     from psb_employees_i
    where data_extract_id = p_data_extract_id;

   message_token('EMPLOYEE_COUNT',l_employee_cnt );
   add_message('PSB', 'PSB_EMPLOYEES_COUNT');

   Select count(*)
     into l_salary_cnt
     from psb_salary_i
    where data_extract_id = p_data_extract_id;

   message_token('SALARY_COUNT',l_salary_cnt );
   add_message('PSB', 'PSB_SALARY_COUNT');

   Select count(*)
     into l_cost_cnt
     from psb_cost_distributions_i
    where data_extract_id = p_data_extract_id;

   message_token('COST_COUNT',l_cost_cnt );
   add_message('PSB', 'PSB_COST_DISTRIBUTION_COUNT');

   Select count(*)
     into l_attr_cnt
     from psb_attribute_values_i
    where data_extract_id = p_data_extract_id;

   message_token('ATTRIBUTE_COUNT',l_attr_cnt );
   add_message('PSB', 'PSB_ATTRIBUTE_VALUE_COUNT');

   Select count(*)
     into l_emp_assign_cnt
     from psb_employee_assignments_i
    where data_extract_id = p_data_extract_id;

   message_token('EMP_ASSIGN_COUNT',l_emp_assign_cnt );
   add_message('PSB', 'PSB_EMP_ASSIGN_COUNT');

   /* delete from PSB_ERROR_MESSAGES
    where process_id = p_data_extract_id;

   l_reqid  := FND_GLOBAL.CONC_REQUEST_ID;
   l_userid := FND_GLOBAL.USER_ID;

   FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			       p_data  => l_msg_data );
   IF l_msg_count > 0 THEN

     l_msg_data := FND_MSG_PUB.Get
		  (p_msg_index    => FND_MSG_PUB.G_NEXT,
		   p_encoded      => FND_API.G_FALSE);

      PSB_MESSAGE_S.INSERT_ERROR
      (p_source_process   => 'DATA_EXTRACT_VALIDATION',
       p_process_id       =>  p_data_extract_id,
       p_msg_count        =>  l_msg_count,
       p_msg_data         =>  l_msg_data);

   end if; */

  PSB_HR_EXTRACT_DATA_PVT.Reentrant_Process
  ( p_api_version              => 1.0  ,
    p_return_status            => l_return_status,
    p_msg_count                => l_msg_count,
    p_msg_data                 => l_msg_data,
    p_data_extract_id          => p_data_extract_id,
    p_extract_method           => p_extract_method,
    p_process                  => 'Data Extract Summary'
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

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

     rollback to Data_Extract_Summary;

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     rollback to Data_Extract_Summary;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     rollback to Data_Extract_Summary;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Data_Extract_Summary;
/*---------------------------------------------------------------------------*/



/*===========================================================================+
 |                         PROCEDURE Validate_Data_Extract                   |
 +===========================================================================*/
PROCEDURE Validate_Data_Extract
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  p_business_group_id   IN      NUMBER
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Validata_Data_Extract';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  --
  l_return_status       varchar2(1);
  l_msg_count           number;
  l_msg_data            varchar2(1000);
  --
  /* Bug#3256987: This validation is no more required.
  l_position_id         number;
  l_attribute_name      varchar2(30);
  l_tmp                 varchar2(1);
  --
  Cursor C_Emp_Assign is
    Select 'x'
      from Psb_employee_assignments_i
     where hr_position_id  = l_position_id
       and attribute_name  = l_attribute_name
       and data_extract_id + 0 = p_data_extract_id;
  */
  --

  /* start bug no 4170600 */
  CURSOR l_msg_csr
  IS
  SELECT description
  FROM psb_error_messages
  WHERE concurrent_request_id = -4712;
  /* end bug no 4170600 */

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT     Validate_Data_Extract;

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

  add_message('PSB','PSB_DE_VALIDATION_HEADER');

  For C_grade_val_rec in
  (
    Select pei.hr_position_id, pp.hr_position_name,
           pei.hr_employee_id, pei.first_name||' '||pei.last_name name,
           pei.assignment_id,
           pei.employee_number,pei.pay_basis,
           pei.salary_type,pei.rate_or_payscale_id,
           pei.grade_id,pei.grade_step,
           pei.sequence_number,pei.element_value,
           pei.proposed_salary
      from psb_employees_i pei,
           psb_positions_i pp
     where pei.data_extract_id = p_data_extract_id
       and pp.data_extract_id  = p_data_extract_id
       and pei.hr_position_id  = pp.hr_position_id
       and pei.hr_employee_id  = pp.hr_employee_id
     order by pei.last_name
  )
  Loop

    --l_position_id   := C_grade_val_rec.hr_position_id;
    if (C_grade_val_rec.grade_id <> 0 OR C_grade_val_rec.grade_id is not null)
    then
      --
      if ( (C_grade_val_rec.salary_type = 'STEP')
           and
	   ( C_grade_val_rec.grade_step = 0 or
             C_grade_val_rec.grade_step is null
           )
         )
      then
        message_token('POSITION_NAME', C_grade_val_rec.hr_position_name);
	message_token('EMPLOYEE_NAME',C_grade_val_rec.name);
	message_token('EMPLOYEE_NUMBER',C_grade_val_rec.employee_number);
	message_token('GRADE_ID',C_grade_val_rec.grade_id);
	add_message('PSB', 'PSB_INVALID_GRADE_STEP');
      end if;
      --
    end if;

    /*
    Bug#3256987: Flag required_for_import_flag corresponds to "Use in Default
                 Rules" option for attributes. This validation is not required.
    --
    For C_Attr_Rec in
    ( Select attribute_id,name
      from   psb_attributes_VL
      where  business_group_id = p_business_group_id
      and    required_for_import_flag = 'Y'
    )
    Loop
      --
      l_attribute_name := C_Attr_Rec.name;
      Open  C_Emp_Assign;
      Fetch C_Emp_Assign into l_tmp;
      Close C_Emp_Assign;
      --
      if (l_tmp is null) then
	 message_token('POSITION_NAME', C_grade_val_rec.hr_position_name);
	 message_token('ATTRIBUTE',     C_Attr_Rec.name);
	 add_message  ('PSB',           'PSB_ATTRIBUTE_MISSING');
      end if;
      --
    End Loop;
    --
    */

  End Loop;

 /* start bug no 4170600 */
  FOR l_msg_rec IN l_msg_csr
  LOOP
    message_token('ERROR_MESSAGE', l_msg_rec.description);
    add_message  ('PSB', 'PSB_DATA_EXTRACT_ERR_MSG');
  END LOOP;

  DELETE FROM PSB_ERROR_MESSAGES
  WHERE concurrent_request_id = -4712;
  /* end bug no 4170600 */


  PSB_HR_EXTRACT_DATA_PVT.Reentrant_Process
  ( p_api_version              => 1.0  ,
    p_return_status            => l_return_status,
    p_msg_count                => l_msg_count,
    p_msg_data                 => l_msg_data,
    p_data_extract_id          => p_data_extract_id,
    p_extract_method           => p_extract_method,
    p_process                  => 'Validate Data Extract'
  ) ;
  --
  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Standard check of p_commit.
  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);
EXCEPTION
   --
   when FND_API.G_EXC_ERROR then
     rollback to Validate_Data_Extract;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
   --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Validate_Data_Extract;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
   --
   when OTHERS then
     rollback to Validate_Data_Extract;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
   --
END Validate_Data_Extract;
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
  FUNCTION get_debug RETURN VARCHAR2 AS
  BEGIN
    return(g_dbug);
  END get_debug;
/* ----------------------------------------------------------------------- */

END PSB_VALIDATE_DATA_EXTRACT_PVT;

/
