--------------------------------------------------------
--  DDL for Package Body PSB_PURGE_DATA_EXTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_PURGE_DATA_EXTRACT_PVT" AS
/* $Header: PSBPHRXB.pls 115.5 2002/11/12 11:04:01 msuram ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_PURGE_DATA_EXTRACT_PVT';
  g_dbug     VARCHAR2(2000);

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
  ( tokname  IN  VARCHAR2,
    tokval   IN  VARCHAR2
  );

  PROCEDURE add_message
  ( appname  IN  VARCHAR2,
    msgname  IN  VARCHAR2
  );

/* ----------------------------------------------------------------------- */

PROCEDURE Purge_Data_Extract
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  p_purge               OUT  NOCOPY     VARCHAR2
) AS

  l_pay_element_id           number;
  l_account_position_set_id  number;
  l_worksheet_cnt            number := 0;
  l_return_status            varchar2(1);
  l_msg_count                number;
  l_msg_data                 varchar2(2000);


  Cursor C_Entity_Set is
    Select entity_set_id
      from psb_entity_set
     where data_extract_id = p_data_extract_id;

  Cursor C_Entity is
    Select entity_id
      from psb_entity
     where data_extract_id = p_data_extract_id;

  Cursor C_Positions is
    Select position_id
      from psb_positions
     where data_extract_id = p_data_extract_id;

  Cursor C_Defaults is
    Select default_rule_id,
	   entity_id
      from psb_defaults
     where data_extract_id = p_data_extract_id;

  Cursor C_Elements is
    Select pay_element_id
      from psb_pay_elements
     where data_extract_id = p_data_extract_id;

  Cursor C_Set_Groups is
    Select position_set_group_id
      from psb_element_pos_set_groups
     where pay_element_id = l_pay_element_id;

  Cursor C_Attribute_Values is
    Select attribute_id,attribute_value_id
      from psb_attribute_values
     where data_extract_id = p_data_extract_id;

  Cursor C_Account_Position_Sets is
    Select account_position_set_id
      from psb_account_position_sets
     where data_extract_id = p_data_extract_id;

  Cursor C_Position_Set_Lines is
    Select line_sequence_id
      from psb_account_position_set_lines
     where account_position_set_id = l_account_position_set_id;

  Cursor C_Review_Group_Rules is
    Select budget_workflow_rule_id
      from psb_budget_workflow_rules
     where data_extract_id = p_data_extract_id;


  l_api_name            CONSTANT VARCHAR2(30)   := 'Purge_Data_Extract';
  l_api_version         CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Purge_Data_Extract;

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
  p_purge         := 'PURGE';

  -- API body
  Begin
  begin
     delete psb_positions_i
      where data_extract_id = p_data_extract_id;
     commit work;
     exception
       when NO_DATA_FOUND then
	null;
     end;
     begin
     delete psb_salary_i
      where data_extract_id = p_data_extract_id;
     commit work;
     exception
       when NO_DATA_FOUND then
	null;
     end;
     begin
     delete psb_employees_i
      where data_extract_id = p_data_extract_id;
     commit work;

     exception
       when NO_DATA_FOUND then
	null;
     end;

     begin
     delete psb_cost_distributions_i
      where data_extract_id = p_data_extract_id;
     commit work;

     exception
       when NO_DATA_FOUND then
	null;
     end;


     begin
     delete psb_attribute_values_i
      where data_extract_id = p_data_extract_id;

     commit work;
     exception
       when NO_DATA_FOUND then
	null;
     end;

     begin
     delete psb_employee_assignments_i
      where data_extract_id = p_data_extract_id;
     commit work;

     exception
       when NO_DATA_FOUND then
	null;
     end;

     begin
     delete psb_reentrant_process_status
      where process_uid = p_data_extract_id
	and process_type = 'HR DATA EXTRACT';
     commit work;
     exception
       when NO_DATA_FOUND then
	null;
     end;

    Select count(*)
      into l_worksheet_cnt
      from psb_worksheets
     where data_extract_id = p_data_extract_id;

    if (l_worksheet_cnt > 0) then
       FND_MESSAGE.SET_NAME('PSB', 'PSB_DE_CANNOT_BE_DELETED');
       FND_MSG_PUB.Add;
       p_purge := 'NO_PURGE';
       raise FND_API.G_EXC_ERROR;
    End if;
  End;

  For C_Entity_Set_Rec in C_Entity_Set
  Loop
     Begin
      Delete psb_entity_assignment
       where entity_set_id = C_Entity_Set_Rec.entity_set_id;
     exception When NO_DATA_FOUND then
      null;
     End;
  End Loop;
  commit work;
  Begin
    Delete psb_entity_set
     where data_extract_id = p_data_extract_id;
  exception When NO_DATA_FOUND then
    null;
  End;

  commit work;
  For C_Entity_Rec in C_Entity
  Loop
     Begin
      Delete psb_entity_assignment
       where entity_id = C_Entity_Rec.entity_id;
     exception When NO_DATA_FOUND then
      null;
     End;
  End Loop;
  Begin
    Delete psb_entity
     where data_extract_id = p_data_extract_id;
  exception When NO_DATA_FOUND then
    null;
  End;

  commit work;
  For C_Positions_Rec in C_Positions
  Loop
     Begin
       Delete psb_position_assignments
	where position_id = C_Positions_Rec.position_id;
     exception When NO_DATA_FOUND then
      null;
     End;
     Begin
       Delete psb_budget_positions
	where position_id = C_Positions_Rec.position_id;
     exception When NO_DATA_FOUND then
      null;
     End;
     Begin
       Delete psb_position_pay_distributions
	where position_id = C_Positions_Rec.position_id;
     exception When NO_DATA_FOUND then
      null;
     End;
  End Loop;
  Begin
    Delete psb_positions
     where data_extract_id = p_data_extract_id;
  exception When NO_DATA_FOUND then
    null;
  End;

  commit work;
  Begin
    Delete psb_employees
     where data_extract_id = p_data_extract_id;
  exception When NO_DATA_FOUND then
    null;
  End;

  commit work;
  For C_Default_Rec in C_Defaults
  Loop

     Begin
       Delete Psb_Set_Relations
	where default_rule_id = C_Default_Rec.default_rule_id;
     exception When NO_DATA_FOUND then
      null;
     End;

     Begin
       Delete Psb_Default_Account_Distrs
	where default_rule_id = C_Default_Rec.default_rule_id;
     exception When NO_DATA_FOUND then
      null;
     End;

     Begin
       Delete Psb_Default_Assignments
	where default_rule_id = C_Default_Rec.default_rule_id;
     exception When NO_DATA_FOUND then
      null;
     End;

     Begin
       Delete Psb_Entity
	where entity_id = C_Default_Rec.entity_id;

       Delete Psb_allocrule_percents
	where allocation_rule_id = C_Default_Rec.entity_id;

     exception When NO_DATA_FOUND then
      null;
     End;

  End Loop;

  Begin
    Delete Psb_Defaults
     where data_extract_id = p_data_extract_id;
  exception When NO_DATA_FOUND then
     null;
  End;

  commit work;
  For C_Element_rec in C_Elements
  Loop
    l_pay_element_id := C_Element_rec.pay_element_id;
    Begin
      Delete Psb_pay_element_options
       where pay_element_id = C_Element_Rec.pay_element_id;
     exception When NO_DATA_FOUND then
      null;
     End;

    Begin
      Delete Psb_pay_element_rates
       where pay_element_id = C_Element_Rec.pay_element_id;
     exception When NO_DATA_FOUND then
      null;
    End;

    For C_Set_Group_Rec in C_Set_Groups
    Loop
     Begin
      Delete Psb_Pay_Element_Distributions
       where position_set_group_id = C_Set_Group_Rec.position_set_group_id;
     exception When NO_DATA_FOUND then
      null;
     End;

     Begin
      Delete Psb_Set_Relations
       where position_set_group_id = C_Set_Group_Rec.position_set_group_id;
     exception When NO_DATA_FOUND then
      null;
     End;

    End Loop;
    Begin
      Delete Psb_Element_Pos_Set_Groups
       where pay_element_id = l_pay_element_id;
     exception When NO_DATA_FOUND then
      null;
    End;
    End Loop;

    Begin
      Delete Psb_Pay_Elements
       where data_extract_id = p_data_extract_id;
     exception When NO_DATA_FOUND then
      null;
    End;

    commit work;
    For C_Account_Position_Set_Rec in C_Account_Position_Sets
    Loop
    l_account_position_set_id := C_Account_Position_Set_Rec.account_position_set_id;
    Begin
      Delete Psb_Set_Relations
       where account_position_set_id = C_Account_Position_Set_Rec.account_position_set_id;
    exception When NO_DATA_FOUND then
      null;
    End;
    For C_Lines_Rec in C_Position_Set_Lines
    Loop
     Begin
	Delete Psb_Position_Set_Line_values
	 where line_sequence_id = C_Lines_Rec.line_sequence_id;
     exception When NO_DATA_FOUND then
      null;
     End;
    End Loop;
    Begin
      Delete Psb_Account_Position_Set_Lines
       where account_position_set_id = C_Account_Position_Set_Rec.account_position_set_id;

     exception When NO_DATA_FOUND then
      null;
    End;

    Begin
      Delete Psb_Budget_Positions
       where account_position_set_id = C_Account_Position_Set_Rec.account_position_set_id;
    exception When NO_DATA_FOUND then
      null;
    End;
    End Loop;

    Begin
      Delete Psb_Account_Position_Sets
       where data_extract_id = p_data_extract_id;

     exception When NO_DATA_FOUND then
      null;
    End;

    commit work;
    For C_Attribute_Value_Rec in C_Attribute_Values
    Loop
     Begin
	Delete Psb_Position_Set_Line_Values
	 where attribute_value_id = C_Attribute_Value_Rec.attribute_value_id;
     exception When NO_DATA_FOUND then
      null;
     End;
    End Loop;

    Begin
      Delete Psb_Attribute_Values
       where data_extract_id = p_data_extract_id;
     exception When NO_DATA_FOUND then
      null;
    End;

    commit work;

    For C_Review_Group_Rule_Rec in C_Review_Group_Rules
    Loop
      Begin
	Delete Psb_Set_Relations
	 where budget_workflow_rule_id = C_Review_Group_Rule_Rec.budget_workflow_rule_id;

      exception When NO_DATA_FOUND then
      null;
     End;
    End Loop;

    commit work;
    Begin
      Delete Psb_Budget_Workflow_Rules
       where data_extract_id = p_data_extract_id;
     exception When NO_DATA_FOUND then
      null;
    End;

    Delete Psb_Data_Extracts
     where data_extract_id = p_data_extract_id;

    commit work;
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

     /*For Bug No : 2577889 Start*/
     --rollback to Purge_Data_Extract;
     rollback;
     /*For Bug No : 2577889 End*/

     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then

     /*For Bug No : 2577889 Start*/
     --rollback to Purge_Data_Extract;
     rollback;
     /*For Bug No : 2577889 End*/

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then

     /*For Bug No : 2577889 Start*/
     --rollback to Purge_Data_Extract;
     rollback;
     /*For Bug No : 2577889 End*/

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Purge_Data_Extract;

/*===========================================================================+
 |                   PROCEDURE Purge_Data_Extract_CP                         |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Purge Data Extract'

PROCEDURE Purge_Data_Extract_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_data_extract_id            IN      NUMBER
)
IS
  --
  l_api_name       CONSTANT VARCHAR2(30)   := 'Purge_Data_Extract_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_data_extract_name       VARCHAR2(30);
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  l_purge                   VARCHAR2(20);

BEGIN


  Select data_extract_name
    into l_data_extract_name
    from psb_data_extracts
   where data_extract_id = p_data_extract_id;

  message_token('DATA_EXTRACT_NAME',l_data_extract_name);
  add_message('PSB', 'PSB_DATA_EXTRACT');

  PSB_PURGE_DATA_EXTRACT_PVT.Purge_Data_Extract
  (p_api_version        => 1.0,
   p_init_msg_list      => FND_API.G_TRUE,
   p_return_status      => l_return_status,
   p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
   p_msg_count          => l_msg_count,
   p_msg_data           => l_msg_data,
   p_data_extract_id    => p_data_extract_id,
   p_purge              => l_purge );


  if l_purge <> 'PURGE' THEN
      message_token('PROCESS', 'Delete Data Extract');
      add_message('PSB', 'PSB_EXTRACT_FAILURE_MESSAGE');
      raise FND_API.G_EXC_ERROR;
  end if;

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  END IF;
  --
  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;
  --
  COMMIT WORK;

EXCEPTION
  --
  WHEN OTHERS THEN
    --
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
    --
    PSB_MESSAGE_S.Print_Error( p_mode         => FND_FILE.OUTPUT,
			       p_print_header => FND_API.G_TRUE);
    --
    retcode := 2 ;
    --
END Purge_Data_Extract_CP;

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

  -- Get Debug Information

  -- This Module is used to retrieve Debug Information for this routine. It
  -- prints Debug Information when run as a Batch Process from SQL*Plus. For
  -- the Debug Information to be printed on the Screen, the SQL*Plus parameter
  -- 'Serveroutput' should be set to 'ON'

  FUNCTION get_debug RETURN VARCHAR2 AS

  BEGIN

    return(g_dbug);

  END get_debug;

/* ----------------------------------------------------------------------- */

END PSB_PURGE_DATA_EXTRACT_PVT;

/
