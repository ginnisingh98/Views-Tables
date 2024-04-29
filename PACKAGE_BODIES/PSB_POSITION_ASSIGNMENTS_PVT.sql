--------------------------------------------------------
--  DDL for Package Body PSB_POSITION_ASSIGNMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_POSITION_ASSIGNMENTS_PVT" AS
/* $Header: PSBVPOAB.pls 120.2 2005/06/08 05:06:27 masethur ship $ */
--
-- Global Variables
--

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_POSITION_ASSIGNMENTS_PVT';
  G_DBUG              VARCHAR2(2000);

/* ----------------------------------------------------------------------- */
--
-- Private Procedure Declarations
--
--

-- Begin Table Handler Procedures
--

PROCEDURE UPDATE_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number   := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_position_assignment_id  in  number,
  p_pay_element_id        in number := FND_API.G_MISS_NUM,
  p_pay_element_option_id in number := FND_API.G_MISS_NUM,
  p_attribute_value_id    in number := FND_API.G_MISS_NUM,
  p_attribute_value       in varchar2 := FND_API.G_MISS_CHAR,
  p_effective_start_date  in date := FND_API.G_MISS_DATE,
  p_effective_end_date    in date := FND_API.G_MISS_DATE,
  p_element_value_type   in varchar2 := FND_API.G_MISS_CHAR,
  p_element_value         in number := FND_API.G_MISS_NUM,
  p_pay_basis             in varchar2 := FND_API.G_MISS_CHAR,
  p_employee_id           in number := FND_API.G_MISS_NUM,
  p_primary_employee_flag in varchar2 := FND_API.G_MISS_CHAR,
  p_global_default_flag   in varchar2 := FND_API.G_MISS_CHAR,
  p_assignment_default_rule_id in number := FND_API.G_MISS_NUM,
  p_modify_flag           in varchar2,
  p_mode                  in varchar2

  ) is
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
--
l_api_name      CONSTANT VARCHAR2(30) := 'Update_Row';
l_api_version   CONSTANT NUMBER := 1.0 ;
l_return_status VARCHAR2(1);
l_insert_flag   VARCHAR2(1) DEFAULT 'N';
l_worksheet_id  NUMBER ;
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
  --

  -- do the update of the record
  --
  -- truncated the p_effective_start_date and p_effective_end_date  for bug 4377166
     update PSB_POSITION_ASSIGNMENTS set
	pay_element_id = decode(p_pay_element_id, FND_API.G_MISS_NUM, pay_element_id, p_pay_element_id),
	pay_element_option_id = decode(p_pay_element_option_id, FND_API.G_MISS_NUM, pay_element_option_id, p_pay_element_option_id),
	attribute_value_id = decode(p_attribute_value_id, FND_API.G_MISS_NUM, attribute_value_id, p_attribute_value_id),
	attribute_value = decode(p_attribute_value, FND_API.G_MISS_CHAR, attribute_value, p_attribute_value),
	effective_start_date  = decode(p_effective_start_date, FND_API.G_MISS_DATE, effective_start_date, trunc(p_effective_start_date)),
	effective_end_date  = decode(p_effective_end_date, FND_API.G_MISS_DATE, effective_end_date, trunc(p_effective_end_date)),
	element_value_type = decode(p_element_value_type, FND_API.G_MISS_CHAR, element_value_type, p_element_value_type),
	element_value  = decode(p_element_value, FND_API.G_MISS_NUM, element_value, p_element_value),
	pay_basis = decode(p_pay_basis, FND_API.G_MISS_CHAR, pay_basis, p_pay_basis),
	employee_id = decode(p_employee_id, FND_API.G_MISS_NUM, employee_id, p_employee_id),
	primary_employee_flag = decode(p_primary_employee_flag,
				FND_API.G_MISS_CHAR,
				primary_employee_flag, p_primary_employee_flag),
	global_default_flag  = decode(p_global_default_flag, FND_API.G_MISS_CHAR, global_default_flag, p_global_default_flag),
	assignment_default_rule_id = decode(p_assignment_default_rule_id, FND_API.G_MISS_NUM, assignment_default_rule_id, p_assignment_default_rule_id),
	modify_flag  = p_modify_flag,
	last_update_date = p_last_update_date,
	last_updated_by = p_last_updated_by,
	last_update_login = p_last_update_login
     where position_assignment_id = p_position_assignment_id;

  if (sql%notfound) then
    -- raise no_data_found;
    raise FND_API.G_EXC_ERROR ;
  end if;


  --
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

   when FND_API.G_EXC_ERROR then
     --
     rollback to Update_Row ;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     rollback to Update_Row ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     rollback to Update_Row ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --

END UPDATE_ROW;
--
/* ------------------  A S S I G N M E N T S  ---------------------------- */


PROCEDURE INSERT_ROW (
  p_api_version          in number,
  p_init_msg_list        in varchar2 := fnd_api.g_false,
  p_commit               in varchar2 := fnd_api.g_false,
  p_validation_level     in number := fnd_api.g_valid_level_full,
  p_return_status        OUT  NOCOPY varchar2,
  p_msg_count            OUT  NOCOPY number,
  p_msg_data             OUT  NOCOPY varchar2,
  p_rowid                in OUT  NOCOPY varchar2,
  p_position_assignment_id  in OUT  NOCOPY number,
  p_data_extract_id      in number,
  p_worksheet_id         in number,
  p_position_id         in number,
  p_assignment_type in varchar2,
  p_attribute_id          in number,
  p_attribute_value_id    in number,
  p_attribute_value       in varchar2,
  p_pay_element_id        in number,
  p_pay_element_option_id in number,
  p_effective_start_date  in date,
  p_effective_end_date    in date,
  p_element_value_type   in varchar2,
  p_element_value         in number,
  p_currency_code         in varchar2,
  p_pay_basis             in varchar2,
  p_employee_id           in number,
  p_primary_employee_flag in varchar2,
  p_global_default_flag   in varchar2,
  p_assignment_default_rule_id in number,
  p_modify_flag           in varchar2,
  p_mode                  in varchar2
  ) is
    cursor C is select ROWID from PSB_POSITION_ASSIGNMENTS
      where position_assignment_id = p_position_assignment_id;
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
--
l_api_name      CONSTANT VARCHAR2(30) := 'Insert_Row' ;
l_api_version   CONSTANT NUMBER := 1.0 ;
l_return_status VARCHAR2(1);
l_pos_assignment_id NUMBER ;
--
BEGIN
  --
  SAVEPOINT INSERT_ROW ;
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
    raise FND_API.G_EXC_ERROR;
  end if;
  --

  -- assign pos assignment id
    SELECT psb_position_assignments_s.NEXTVAL
      INTO  p_position_assignment_id
      FROM dual;

  --
   insert into PSB_POSITION_ASSIGNMENTS (
    position_assignment_id   ,
    data_extract_id      ,
    worksheet_id         ,
    position_id        ,
    assignment_type  ,
    attribute_id          ,
    attribute_value_id     ,
    attribute_value       ,
    pay_element_id        ,
    pay_element_option_id  ,
    effective_start_date  ,
    effective_end_date   ,
    element_value_type    ,
    element_value       ,
    currency_code  ,
    pay_basis ,
    employee_id ,
    primary_employee_flag,
    global_default_flag    ,
    assignment_default_rule_id  ,
    modify_flag            ,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
  ) values (
    p_position_assignment_id   ,
    p_data_extract_id    ,
    p_worksheet_id         ,
    p_position_id        ,
    p_assignment_type  ,
    p_attribute_id          ,
    p_attribute_value_id     ,
    p_attribute_value       ,
    p_pay_element_id        ,
    p_pay_element_option_id  ,
    trunc(p_effective_start_date)  , -- truncated the date for bug 4377166
    trunc(p_effective_end_date)   ,  -- truncated the date for bug 4377166
    p_element_value_type    ,
    p_element_value       ,
    p_currency_code   ,
    p_pay_basis ,
    p_employee_id ,
    p_primary_employee_flag,
    p_global_default_flag    ,
    p_assignment_default_rule_id  ,
    p_modify_flag            ,
    p_last_update_date,
    p_last_updated_by,
    p_last_update_date,
    p_last_updated_by,
    p_last_update_login
  );
  --
  open c;
  fetch c into P_ROWID;
  if (c%notfound) then
    close c;
    raise FND_API.G_EXC_ERROR ;
    --raise no_data_found;
  end if;
  close c;
  --
  --p_position_assignment_id := l_pos_assignment_id ;
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
--
--

PROCEDURE LOCK_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number   := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_row_locked          OUT  NOCOPY varchar2,
  p_position_assignment_id  in number,
  p_data_extract_id      in number,
  p_worksheet_id         in number,
  p_position_id         in number,
  p_assignment_type in varchar2,
  p_attribute_id          in number,
  p_attribute_value_id    in number,
  p_attribute_value       in varchar2,
  p_pay_element_id        in number,
  p_pay_element_option_id in number,
  p_effective_start_date  in date,
  p_effective_end_date    in date,
  p_element_value_type   in varchar2,
  p_element_value         in number,
  p_currency_code         in varchar2,
  p_pay_basis             in varchar2,
  p_employee_id           in number,
  p_primary_employee_flag in varchar2,
  p_global_default_flag   in varchar2,
  p_assignment_default_rule_id in number,
  p_modify_flag           in varchar2
) is
  cursor c1 is select
    position_assignment_id   ,
    data_extract_id      ,
    worksheet_id         ,
    position_id        ,
    assignment_type  ,
    attribute_id          ,
    attribute_value_id     ,
    attribute_value       ,
    pay_element_id        ,
    pay_element_option_id  ,
    effective_start_date  ,
    effective_end_date   ,
    element_value_type    ,
    element_value       ,
    currency_code ,
    pay_basis ,
    employee_id ,
    primary_employee_flag ,
    global_default_flag    ,
    assignment_default_rule_id  ,
    modify_flag
    from PSB_POSITION_ASSIGNMENTS
    where position_assignment_id = P_position_assignment_id
    for update of position_assignment_id nowait;
  tlinfo c1%rowtype;
--
l_api_name      CONSTANT VARCHAR2(30) := 'Lock_Row' ;
l_api_version   CONSTANT NUMBER := 1.0 ;
l_return_status VARCHAR2(1);
--
BEGIN
  --
  SAVEPOINT Lock_Row ;
  --
  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  p_row_locked    := FND_API.G_TRUE ;
  --
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    fnd_msg_pub.add ;
    close c1;
    raise fnd_api.g_exc_error ;
  end if;
  close c1;
  --
  if ( (tlinfo.position_assignment_id = P_position_assignment_id)
      AND (tlinfo.data_extract_id = P_data_extract_id)
      AND ((tlinfo.worksheet_id = P_worksheet_id)
	   OR ((tlinfo.worksheet_id is null)
	       AND (P_worksheet_id is null)))
      AND (tlinfo.position_id  = P_position_id)
      AND (tlinfo.effective_start_date  = P_effective_start_date)
      AND ((tlinfo.effective_end_date = P_effective_end_date)
	   OR ((tlinfo.effective_end_date is null)
	       AND (P_effective_end_date is null)))
      AND ((tlinfo.assignment_type = P_assignment_type )
	   OR ((tlinfo.assignment_type  is null)
	       AND (P_assignment_type  is null)))
      AND ((tlinfo.attribute_id = P_attribute_id)
	   OR ((tlinfo.attribute_id is null)
	       AND (P_attribute_id is null)))
      AND ((tlinfo.attribute_value_id = P_attribute_value_id)
	   OR ((tlinfo.attribute_value_id  is null)
	       AND (P_attribute_value_id is null)))
      AND ((tlinfo.attribute_value = P_attribute_value)
	   OR ((tlinfo.attribute_value is null)
	       AND (P_attribute_value is null)))
      AND ((tlinfo.pay_element_id= p_pay_element_id)
	   OR ((tlinfo.pay_element_id is null)
	       AND (P_pay_element_id is null)))
      AND ((tlinfo.pay_element_option_id = P_pay_element_option_id)
	   OR ((tlinfo.pay_element_option_id is null)
	       AND (P_pay_element_option_id is null)))
      AND ((tlinfo.element_value_type = P_element_value_type)
	   OR ((tlinfo.element_value_type is null)
	      AND (P_element_value_type is null)))
      AND ((tlinfo.element_value = P_element_value)
	   OR ((tlinfo.element_value is null)
	       AND (P_element_value is null)))
      AND ((tlinfo.currency_code = P_currency_code)
	   OR ((tlinfo.currency_code is null)
	       AND (P_currency_code is null)))
      AND ((tlinfo.pay_basis = P_pay_basis)
	   OR ((tlinfo.pay_basis is null)
	       AND (P_pay_basis is null)))
      AND ((tlinfo.employee_id = P_employee_id)
	   OR ((tlinfo.employee_id is null)
	       AND (P_employee_id is null)))
      AND ((tlinfo.primary_employee_flag = P_primary_employee_flag)
	   OR ((tlinfo.primary_employee_flag is null)
	       AND (P_primary_employee_flag is null)))
      AND ((tlinfo.global_default_flag = P_global_default_flag)
	   OR ((tlinfo.global_default_flag is null)
	       AND (P_global_default_flag is null)))
      AND ((tlinfo.assignment_default_rule_id = P_assignment_default_rule_id)
	   OR ((tlinfo.assignment_default_rule_id is null)
	       AND (P_assignment_default_rule_id is null)))
      AND ((tlinfo.modify_flag = P_modify_flag)
	   OR ((tlinfo.modify_flag is null)
	       AND (P_modify_flag is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    fnd_msg_pub.add ;
    raise fnd_api.g_exc_error ;
  end if;

EXCEPTION
  when app_exception.record_lock_exception then
     --
     rollback to LOCK_ROW ;
     p_row_locked    := FND_API.G_FALSE ;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
  when FND_API.G_EXC_ERROR then
     --
     rollback to LOCK_ROW ;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     rollback to LOCK_ROW ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     rollback to LOCK_ROW ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
END LOCK_ROW;


--
PROCEDURE DELETE_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_position_assignment_id in number
) is
--
l_api_name    CONSTANT VARCHAR2(30) := 'Delete Row' ;
l_api_version CONSTANT NUMBER := 1.0 ;

l_return_status        VARCHAR2(1);
--
BEGIN
  --
  SAVEPOINT DELETE_ROW ;
  --
  -- Initialize message list if p_init_msg_list is set to TRUE.
  --
  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;

  --
  delete from PSB_POSITION_ASSIGNMENTS
  where position_assignment_id = p_position_assignment_id;
  if (sql%notfound) THEN
   null;
  end if;

  -- Standard check of p_commit.
  --
  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);
  --
EXCEPTION
   when FND_API.G_EXC_ERROR then
     --
     rollback to DELETE_ROW;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     rollback to DELETE_ROW;
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
     end if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
END DELETE_ROW;

--
--
-- End of Table Handler Procedures
--
/* ----------------------------------------------------------------------- */

  -- Get Debug Information

  -- This Module is used to retrieve Debug Information for Funds Checker. It
  -- prints Debug Information when run as a Batch Process from SQL*Plus. For
  -- the Debug Information to be printed on the Screen, the SQL*Plus parameter
  -- 'Serveroutput' should be set to 'ON'

  FUNCTION get_debug RETURN VARCHAR2 IS

  BEGIN

    return(g_dbug);

  END get_debug;

/* ----------------------------------------------------------------------- */

END PSB_POSITION_ASSIGNMENTS_PVT ;

/
