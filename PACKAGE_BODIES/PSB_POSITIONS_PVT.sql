--------------------------------------------------------
--  DDL for Package Body PSB_POSITIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_POSITIONS_PVT" AS
/* $Header: PSBVPOSB.pls 120.26.12010000.6 2009/10/01 11:27:03 rkotha ship $ */
--
-- Global Variables
--

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_POSITIONS_PVT';
  G_DBUG              VARCHAR2(2000);

  TYPE g_assign_rec_type IS RECORD
     ( position_assignment_id      NUMBER,
       data_extract_id             NUMBER,
       worksheet_id                NUMBER,
       position_id                 NUMBER,
       assignment_type             VARCHAR2(10),
       attribute_id                NUMBER,
       attribute_value_id          NUMBER,
       --UTF8 changes for Bug No : 2615261
       attribute_value             VARCHAR2(240),
       pay_element_id              NUMBER,
       pay_element_option_id       NUMBER,
       effective_start_date        DATE,
       effective_end_date          DATE,
       element_value_type          VARCHAR2(2),
       element_value               NUMBER,
       currency_code               VARCHAR2(10),
       pay_basis                   VARCHAR2(10),
       employee_id                 NUMBER,
       primary_employee_flag       VARCHAR2(1),
       global_default_flag         VARCHAR2(1),
       assignment_default_rule_id  NUMBER,
       modify_flag                 VARCHAR2(1),
       delete_flag                 VARCHAR2(1) );

  TYPE g_assign_tbl_type IS TABLE OF g_assign_rec_type
     INDEX BY BINARY_INTEGER;

  -- Number array.
  TYPE Number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER ;

  -- Character array.
  TYPE Character_tbl_type IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER ;

  -- Date array.
  TYPE Date_tbl_type IS TABLE OF DATE INDEX BY BINARY_INTEGER ;

  g_assign                         g_assign_tbl_type;
  g_num_assign                     NUMBER;
  g_validation_mode                VARCHAR2(15);

/* ------------------Private Procedure Declarations----------------------- */

PROCEDURE MODIFY_ASSIGNMENT_WS
( p_return_status               OUT  NOCOPY     VARCHAR2,
  p_position_assignment_id      IN OUT  NOCOPY  NUMBER,
  p_data_extract_id             IN      NUMBER,
  p_worksheet_id                IN      NUMBER,
  p_position_id                 IN      NUMBER,
  p_assignment_type             IN      VARCHAR2,
  p_attribute_id                IN      NUMBER,
  p_attribute_value_id          IN      NUMBER,
  p_attribute_value             IN      VARCHAR2,
  p_pay_element_id              IN      NUMBER,
  p_pay_element_option_id       IN      NUMBER,
  p_effective_start_date        IN      DATE,
  p_effective_end_date          IN      DATE,
  p_element_value_type          IN      VARCHAR2,
  p_element_value               IN      NUMBER,
  p_currency_code               IN      VARCHAR2,
  p_pay_basis                   IN      VARCHAR2,
  p_employee_id                 IN      NUMBER,
  p_primary_employee_flag       IN      VARCHAR2,
  p_global_default_flag         IN      VARCHAR2,
  p_assignment_default_rule_id  IN      NUMBER,
  p_modify_flag                 IN      VARCHAR2,
  p_rowid                       IN OUT  NOCOPY  VARCHAR2
);

PROCEDURE CREATE_ASSIGNMENT_POSITION
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER,
  p_data_extract_id      IN   NUMBER,
  p_position_id          IN   NUMBER,
  p_position_start_date  IN   DATE,
  p_position_end_date    IN   DATE,
  p_ruleset_id           IN   NUMBER
);

PROCEDURE CREATE_DISTRIBUTION_POSITION
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER,
  p_data_extract_id      IN   NUMBER,
  p_position_id          IN   NUMBER,
  p_position_start_date  IN   DATE,
  p_position_end_date    IN   DATE,
  p_ruleset_id           IN   NUMBER
);

PROCEDURE CREATE_ELEMENT_ASSIGNMENT
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER,
  p_data_extract_id      IN   NUMBER,
  p_position_id          IN   NUMBER,
  p_position_start_date  IN   DATE,
  p_position_end_date    IN   DATE
);

/* For Bug 4644241 --> Reverting Back to the old fix
   This will maintain the old functionality */
PROCEDURE Apply_Global_Default
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER,
  p_data_extract_id      IN   NUMBER,
  p_position_id          IN   NUMBER,
  p_position_start_date  IN   DATE,
  p_position_end_date    IN   DATE
);


PROCEDURE OUTPUT_MESSAGE_TO_TABLE
( p_worksheet_id IN NUMBER,
  p_return_status OUT  NOCOPY VARCHAR2
);

PROCEDURE VALIDATE_POSITION
( p_worksheet_id            IN NUMBER,
  p_position_id             IN NUMBER,
  p_name                    IN VARCHAR2,
  p_employee_number         IN VARCHAR2,
  p_data_extract_id         IN NUMBER,
  p_root_budget_group_id    IN NUMBER,
  p_set_of_books_id         IN NUMBER,
  p_budget_calendar_id      IN NUMBER,
  p_chart_of_accounts_id    IN NUMBER,
  p_position_start_date     IN DATE,
  p_position_end_date       IN DATE,
  p_startdate_pp            IN DATE,
  p_enddate_cy              IN DATE,
  p_effective_start_date    IN DATE,
  p_effective_end_date      IN DATE,
  p_error_flag          IN OUT  NOCOPY VARCHAR2,
  p_return_status          OUT  NOCOPY VARCHAR2
);

PROCEDURE VALIDATE_DISTRIBUTION
( p_position_id             IN NUMBER,
  p_worksheet_id            IN NUMBER,
  p_name                    IN VARCHAR2,
  p_employee_number         IN VARCHAR2,
  p_position_flag       IN OUT  NOCOPY VARCHAR2,
  p_data_extract_id         IN NUMBER,
  p_root_budget_group_id      IN NUMBER,
  p_set_of_books_id         IN NUMBER,
  p_budget_calendar_id      IN NUMBER,
  p_chart_of_accounts_id    IN NUMBER,
  p_startdate_pp            IN DATE,
  p_enddate_cy              IN DATE,
  p_effective_start_date    IN DATE,
  p_effective_end_date      IN DATE,
  p_error_flag          IN OUT  NOCOPY VARCHAR2,
  p_return_status          OUT  NOCOPY VARCHAR2
);

PROCEDURE SET_POS_HEADING
(                    p_position_flag   IN OUT  NOCOPY VARCHAR2,
		     p_position_name   IN  VARCHAR2,
		     p_employee_number IN VARCHAR2,
		     p_error_flag      IN OUT  NOCOPY VARCHAR2
);

-- Bug 1308558. Mass Position Assginment Rules
-- new api created for applying the Element and Attribute
-- assignments to positions
/* Bug 4273099 moved this to package spec
PROCEDURE Apply_Position_Default_Rules
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status               OUT  NOCOPY     VARCHAR2,
  x_msg_count                   OUT  NOCOPY     NUMBER,
  x_msg_data                    OUT  NOCOPY     VARCHAR2,
  p_position_assignment_id      IN OUT  NOCOPY  NUMBER,
  p_data_extract_id             IN      NUMBER,
  p_position_id                 IN      NUMBER,
  p_assignment_type             IN      VARCHAR2,
  p_attribute_id                IN      NUMBER,
  p_attribute_value_id          IN      NUMBER,
  p_attribute_value             IN      VARCHAR2,
  p_pay_element_id              IN      NUMBER,
  p_pay_element_option_id       IN      NUMBER,
  p_effective_start_date        IN      DATE,
  p_effective_end_date          IN      DATE,
  p_element_value_type          IN      VARCHAR2,
  p_element_value               IN      NUMBER,
  p_currency_code               IN      VARCHAR2,
  p_pay_basis                   IN      VARCHAR2,
  p_employee_id                 IN      NUMBER,
  p_primary_employee_flag       IN      VARCHAR2,
  p_global_default_flag         IN      VARCHAR2,
  p_assignment_default_rule_id  IN      NUMBER,
  p_modify_flag                 IN      VARCHAR2,
  p_mode                        IN      VARCHAR2 := 'R'
);
*/

/*===========================================================================+
 |                             PROCEDURE pd                                  |
 +===========================================================================*/
-- API to print debug information, used during development only.
PROCEDURE pd( p_message  IN  VARCHAR2) IS
BEGIN
  NULL ;
  --DBMS_OUTPUT.Put_Line(p_message) ;
END pd ;
/*---------------------------------------------------------------------------*/


/*----------------------- Table Handler Procedures ----------------------- */
PROCEDURE INSERT_ROW (
  p_api_version            in number,
  p_init_msg_list          in varchar2 := fnd_api.g_false,
  p_commit                 in varchar2 := fnd_api.g_false,
  p_validation_level       in number   := fnd_api.g_valid_level_full,
  p_return_status          OUT  NOCOPY varchar2,
  p_msg_count              OUT  NOCOPY number,
  p_msg_data               OUT  NOCOPY varchar2,
  p_rowid                  in OUT  NOCOPY varchar2,
  p_position_id            in number,
  -- de by org
  p_organization_id        in number := NULL,
  p_data_extract_id        in number,
  p_position_definition_id in number,
  p_hr_position_id         in number,
  p_hr_employee_id         in number := fnd_api.g_miss_num ,
  p_business_group_id      in number,
  p_budget_group_id        in number := fnd_api.g_miss_num ,
  p_effective_start_date   in date,
  p_effective_end_date     in date,
  p_set_of_books_id        in number,
  p_vacant_position_flag   in varchar2,
  p_availability_status    in varchar2 := fnd_api.g_miss_char ,
  p_transaction_id         in number   := fnd_api.g_miss_num ,
  p_transaction_status     in varchar2 := fnd_api.g_miss_char ,
  p_new_position_flag      in varchar2 := fnd_api.g_miss_char ,
  p_attribute1          in varchar2,
  p_attribute2          in varchar2,
  p_attribute3          in varchar2,
  p_attribute4          in varchar2,
  p_attribute5          in varchar2,
  p_attribute6          in varchar2,
  p_attribute7          in varchar2,
  p_attribute8          in varchar2,
  p_attribute9          in varchar2,
  p_attribute10         in varchar2,
  p_attribute11         in varchar2,
  p_attribute12         in varchar2,
  p_attribute13         in varchar2,
  p_attribute14         in varchar2,
  p_attribute15         in varchar2,
  p_attribute16         in varchar2,
  p_attribute17         in varchar2,
  p_attribute18         in varchar2,
  p_attribute19         in varchar2,
  p_attribute20         in varchar2,
  p_attribute_category  in varchar2,
  p_name                in varchar2,
  p_mode                in varchar2 := 'R'

  ) is
    cursor C is select ROWID from PSB_POSITIONS
      where POSITION_ID = P_POSITION_ID;
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
--
l_api_name        CONSTANT VARCHAR2(30) := 'Insert_Row' ;
l_api_version     CONSTANT NUMBER := 1.0 ;
l_return_status   VARCHAR2(1);
--
l_hr_employee_id         psb_positions.hr_employee_id%TYPE ;
l_budget_group_id        psb_positions.budget_group_id%TYPE;
l_availability_status    psb_positions.availability_status%TYPE;
l_transaction_id         psb_positions.transaction_id%TYPE;
l_transaction_status     psb_positions.transaction_status%TYPE;
l_new_position_flag      psb_positions.new_position_flag%TYPE;
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
    raise FND_API.G_EXC_ERROR;
  end if;
  --

  --  Resolve p_hr_employee_id parameter.
  IF p_hr_employee_id = FND_API.G_MISS_NUM THEN
    l_hr_employee_id := NULL ;
  ELSE
    l_hr_employee_id := p_hr_employee_id ;
  END IF;

  --  Resolve p_budget_group_id parameter.
  IF p_budget_group_id = FND_API.G_MISS_NUM THEN
    l_budget_group_id := NULL ;
  ELSE
    l_budget_group_id := p_budget_group_id ;
  END IF;

  --  Resolve p_availability_status , p_transaction_id and p_transaction_status
  --  parameters.

  IF p_availability_status = FND_API.G_MISS_CHAR THEN
    l_availability_status := NULL ;
  ELSE
    l_availability_status := p_availability_status ;
  END IF;

  IF p_transaction_id = FND_API.G_MISS_NUM THEN
    l_transaction_id := NULL ;
  ELSE
    l_transaction_id := p_transaction_id ;
  END IF;

  IF p_transaction_status = FND_API.G_MISS_CHAR THEN
    l_transaction_status := NULL ;
  ELSE
    l_transaction_status := p_transaction_status ;
  END IF;

  --  Resolve p_new_position_flag parameter.
  IF p_new_position_flag = FND_API.G_MISS_CHAR THEN
    l_new_position_flag := NULL ;
  ELSE
    l_new_position_flag := p_new_position_flag ;
  END IF;

  insert into PSB_POSITIONS (
  position_id           ,
  organization_id       ,
  data_extract_id       ,
  position_definition_id,
  hr_position_id        ,
  hr_employee_id        ,
  business_group_id     ,
  budget_group_id       ,
  effective_start_date  ,
  effective_end_date    ,
  set_of_books_id       ,
  vacant_position_flag  ,
  availability_status   ,
  transaction_id        ,
  transaction_status    ,
  new_position_flag     ,
  attribute1            ,
  attribute2            ,
  attribute3            ,
  attribute4            ,
  attribute5            ,
  attribute6            ,
  attribute7            ,
  attribute8            ,
  attribute9            ,
  attribute10           ,
  attribute11           ,
  attribute12           ,
  attribute13           ,
  attribute14           ,
  attribute15           ,
  attribute16           ,
  attribute17           ,
  attribute18           ,
  attribute19           ,
  attribute20           ,
  attribute_category    ,
  name                  ,
  creation_date         ,
  created_by            ,
  last_update_date      ,
  last_updated_by       ,
  last_update_login
  )
  values
  (
  p_position_id         ,
  p_organization_id     ,
  p_data_extract_id     ,
  p_position_definition_id ,
  p_hr_position_id      ,
  l_hr_employee_id      ,
  p_business_group_id   ,
  l_budget_group_id     ,
  p_effective_start_date,
  p_effective_end_date  ,
  p_set_of_books_id     ,
  p_vacant_position_flag,
  l_availability_status ,
  l_transaction_id      ,
  l_transaction_status  ,
  l_new_position_flag   ,
  p_attribute1          ,
  p_attribute2          ,
  p_attribute3          ,
  p_attribute4          ,
  p_attribute5          ,
  p_attribute6          ,
  p_attribute7          ,
  p_attribute8          ,
  p_attribute9          ,
  p_attribute10         ,
  p_attribute11         ,
  p_attribute12         ,
  p_attribute13         ,
  p_attribute14         ,
  p_attribute15         ,
  p_attribute16         ,
  p_attribute17         ,
  p_attribute18         ,
  p_attribute19         ,
  p_attribute20         ,
  p_attribute_category  ,
  p_name                ,
  p_last_update_date    ,
  p_last_updated_by     ,
  p_last_update_date    ,
  p_last_updated_by     ,
  p_last_update_login
  );
  --
  open c;
  fetch c into P_ROWID;
  if (c%notfound) then
    close c;
    raise FND_API.G_EXC_ERROR ;
  end if;
  close c;
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
/* ----------------------------------------------------------------------- */

PROCEDURE LOCK_ROW (
  p_api_version            in number,
  p_init_msg_list          in varchar2 := fnd_api.g_false,
  p_commit                 in varchar2 := fnd_api.g_false,
  p_validation_level       in number   := fnd_api.g_valid_level_full,
  p_return_status          OUT  NOCOPY varchar2,
  p_msg_count              OUT  NOCOPY number,
  p_msg_data               OUT  NOCOPY varchar2,
  p_row_locked             OUT  NOCOPY varchar2,
  p_position_id            in number,
  p_data_extract_id        in number,
  p_position_definition_id in number,
  p_hr_position_id         in number,
  p_business_group_id      in number,
  p_effective_start_date   in date,
  p_effective_end_date     in date,
  p_set_of_books_id        in number,
  p_vacant_position_flag   in varchar2,
  p_attribute1          in varchar2,
  p_attribute2          in varchar2,
  p_attribute3          in varchar2,
  p_attribute4          in varchar2,
  p_attribute5          in varchar2,
  p_attribute6          in varchar2,
  p_attribute7          in varchar2,
  p_attribute8          in varchar2,
  p_attribute9          in varchar2,
  p_attribute10         in varchar2,
  p_attribute11         in varchar2,
  p_attribute12         in varchar2,
  p_attribute13         in varchar2,
  p_attribute14         in varchar2,
  p_attribute15         in varchar2,
  p_attribute16         in varchar2,
  p_attribute17         in varchar2,
  p_attribute18         in varchar2,
  p_attribute19         in varchar2,
  p_attribute20         in varchar2,
  p_attribute_category  in varchar2,
  p_name                in varchar2

) is
  cursor c1 is select
    position_id         ,
    data_extract_id     ,
    position_definition_id ,
    hr_position_id      ,
    business_group_id   ,
    effective_start_date,
    effective_end_date  ,
    set_of_books_id     ,
    vacant_position_flag,
    attribute1          ,
    attribute2          ,
    attribute3          ,
    attribute4          ,
    attribute5          ,
    attribute6          ,
    attribute7          ,
    attribute8          ,
    attribute9          ,
    attribute10         ,
    attribute11         ,
    attribute12         ,
    attribute13         ,
    attribute14         ,
    attribute15         ,
    attribute16         ,
    attribute17         ,
    attribute18         ,
    attribute19         ,
    attribute20         ,
    attribute_category  ,
    name
    from PSB_POSITIONS
    where position_id = P_position_id
    for update of position_id nowait;
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
  if ( (tlinfo.position_id = P_position_id)
      AND (tlinfo.data_extract_id = P_data_extract_id)
      AND (tlinfo.effective_start_date  = P_effective_start_date)

      AND ((tlinfo.position_definition_id = P_position_definition_id)
	   OR ((tlinfo.position_definition_id is null)
	      AND (P_position_definition_id is null)))

      AND ((tlinfo.hr_position_id = P_hr_position_id)
	   OR ((tlinfo.hr_position_id is null)
	       AND (P_hr_position_id is null)))

      AND ((tlinfo.business_group_id = P_business_group_id )
	   OR ((tlinfo.business_group_id  is null)
	       AND (P_business_group_id  is null)))

      AND ((tlinfo.effective_end_date = P_effective_end_date)
	   OR ((tlinfo.effective_end_date is null)
	       AND (P_effective_end_date is null)))

      AND ((tlinfo.set_of_books_id = P_set_of_books_id)
	   OR ((tlinfo.set_of_books_id  is null)
	       AND (P_set_of_books_id  is null)))

      AND ((tlinfo.name = P_name)
	   OR ((tlinfo.name  is null)
	       AND (P_name  is null)))

      AND ((tlinfo.vacant_position_flag = P_vacant_position_flag)
	   OR ((tlinfo.vacant_position_flag is null)
	       AND (P_vacant_position_flag is null)))

      AND ((tlinfo.attribute_category = P_attribute_category)
	   OR ((tlinfo.attribute_category is null)
	       AND (P_attribute_category is null)))

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
      AND ((tlinfo.ATTRIBUTE11 = P_ATTRIBUTE11)
	   OR ((tlinfo.ATTRIBUTE11 is null)
	       AND (P_ATTRIBUTE11 is null)))
      AND ((tlinfo.ATTRIBUTE12 = P_ATTRIBUTE12)
	   OR ((tlinfo.ATTRIBUTE12 is null)
	       AND (P_ATTRIBUTE12 is null)))
      AND ((tlinfo.ATTRIBUTE13 = P_ATTRIBUTE13)
	   OR ((tlinfo.ATTRIBUTE13 is null)
	       AND (P_ATTRIBUTE13 is null)))
      AND ((tlinfo.ATTRIBUTE14 = P_ATTRIBUTE14)
	   OR ((tlinfo.ATTRIBUTE14 is null)
	       AND (P_ATTRIBUTE14 is null)))
      AND ((tlinfo.ATTRIBUTE15 = P_ATTRIBUTE15)
	   OR ((tlinfo.ATTRIBUTE15 is null)
	       AND (P_ATTRIBUTE15 is null)))
      AND ((tlinfo.ATTRIBUTE16 = P_ATTRIBUTE16)
	   OR ((tlinfo.ATTRIBUTE16 is null)
	       AND (P_ATTRIBUTE16 is null)))
      AND ((tlinfo.ATTRIBUTE17 = P_ATTRIBUTE17)
	   OR ((tlinfo.ATTRIBUTE17 is null)
	       AND (P_ATTRIBUTE17 is null)))
      AND ((tlinfo.ATTRIBUTE18 = P_ATTRIBUTE18)
	   OR ((tlinfo.ATTRIBUTE18 is null)
	       AND (P_ATTRIBUTE18 is null)))
      AND ((tlinfo.ATTRIBUTE19 = P_ATTRIBUTE19)
	   OR ((tlinfo.ATTRIBUTE19 is null)
	       AND (P_ATTRIBUTE19 is null)))
      AND ((tlinfo.ATTRIBUTE20 = P_ATTRIBUTE20)
	   OR ((tlinfo.ATTRIBUTE20 is null)
	       AND (P_ATTRIBUTE20 is null)))

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
/* ----------------------------------------------------------------------- */

PROCEDURE UPDATE_ROW (
  p_api_version            in number,
  p_init_msg_list          in varchar2 := fnd_api.g_false,
  p_commit                 in varchar2 := fnd_api.g_false,
  p_validation_level       in number   := fnd_api.g_valid_level_full,
  p_return_status          OUT  NOCOPY varchar2,
  p_msg_count              OUT  NOCOPY number,
  p_msg_data               OUT  NOCOPY varchar2,
  p_position_id            in number,
  -- de by org
  p_organization_id        in number := NULL,
  p_data_extract_id        in number,
  p_position_definition_id in number,
  p_hr_position_id         in number,
  p_hr_employee_id         in number := fnd_api.g_miss_num ,
  p_business_group_id      in number,
  p_budget_group_id        in number := fnd_api.g_miss_num ,
  p_effective_start_date   in date,
  p_effective_end_date     in date,
  p_set_of_books_id        in number,
  p_vacant_position_flag   in varchar2,
  p_availability_status in varchar2 := fnd_api.g_miss_char ,
  p_transaction_id      in number   := fnd_api.g_miss_num ,
  p_transaction_status  in varchar2 := fnd_api.g_miss_char ,
  p_new_position_flag      in varchar2 := fnd_api.g_miss_char ,
  p_attribute1          in varchar2,
  p_attribute2          in varchar2,
  p_attribute3          in varchar2,
  p_attribute4          in varchar2,
  p_attribute5          in varchar2,
  p_attribute6          in varchar2,
  p_attribute7          in varchar2,
  p_attribute8          in varchar2,
  p_attribute9          in varchar2,
  p_attribute10         in varchar2,
  p_attribute11         in varchar2,
  p_attribute12         in varchar2,
  p_attribute13         in varchar2,
  p_attribute14         in varchar2,
  p_attribute15         in varchar2,
  p_attribute16         in varchar2,
  p_attribute17         in varchar2,
  p_attribute18         in varchar2,
  p_attribute19         in varchar2,
  p_attribute20         in varchar2,
  p_attribute_category  in varchar2,
  p_name                in varchar2,
  p_mode                in varchar2 := 'R'

  ) is
    P_LAST_UPDATE_DATE DATE;
    P_LAST_UPDATED_BY NUMBER;
    P_LAST_UPDATE_LOGIN NUMBER;
--
l_api_name        CONSTANT VARCHAR2(30) := 'Update Row';
l_api_version     CONSTANT NUMBER := 1.0 ;
l_return_status   VARCHAR2(1);
--
l_hr_employee_id        psb_positions.hr_employee_id%TYPE ;
l_budget_group_id       psb_positions.budget_group_id%TYPE ;
l_availability_status   psb_positions.availability_status%TYPE;
l_transaction_id        psb_positions.transaction_id%TYPE;
l_transaction_status    psb_positions.transaction_status%TYPE;
l_new_position_flag     psb_positions.new_position_flag%TYPE;
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


  --  Resolve p_hr_employee_id parameter.
  IF p_hr_employee_id = FND_API.G_MISS_NUM THEN
    l_hr_employee_id := NULL ;
  ELSE
    l_hr_employee_id := p_hr_employee_id ;
  END IF;

  --  Resolve p_budget_group_id parameter.
  IF p_budget_group_id = FND_API.G_MISS_NUM THEN
    l_budget_group_id := NULL ;
  ELSE
    l_budget_group_id := p_budget_group_id ;
  END IF;

  --  Resolve p_availability_status , p_transaction_id and p_transaction_status
  --  parameters.

  IF p_availability_status = FND_API.G_MISS_CHAR THEN
    l_availability_status := NULL ;
  ELSE
    l_availability_status := p_availability_status ;
  END IF;

  IF p_transaction_id = FND_API.G_MISS_NUM THEN
    l_transaction_id := NULL ;
  ELSE
    l_transaction_id := p_transaction_id ;
  END IF;

  IF p_transaction_status = FND_API.G_MISS_CHAR THEN
    l_transaction_status := NULL ;
  ELSE
    l_transaction_status := p_transaction_status ;
  END IF;

  --  Resolve p_new_position_flag parameter.
  IF p_new_position_flag = FND_API.G_MISS_CHAR THEN
    l_new_position_flag := NULL ;
  ELSE
    l_new_position_flag := p_new_position_flag ;
  END IF;

  --
  -- do the update of the record
  --
  update PSB_POSITIONS set
     position_id = p_position_id                    ,
    -- de by org
     organization_id = nvl(p_organization_id,organization_id),
     data_extract_id = p_data_extract_id            ,
     position_definition_id = p_position_definition_id ,
     hr_position_id = p_hr_position_id              ,
     hr_employee_id = l_hr_employee_id              ,
     business_group_id =  p_business_group_id       ,
     budget_group_id =  l_budget_group_id           ,
     effective_start_Date = p_effective_start_date  ,
     effective_end_date  = p_effective_end_date     ,
     set_of_books_id = p_set_of_books_id            ,
     vacant_position_flag = p_vacant_position_flag  ,
     availability_status  = l_availability_status   ,
     transaction_id       = l_transaction_id        ,
     transaction_status   = l_transaction_status    ,
     new_position_flag    = l_new_position_flag     ,
     attribute1 = p_attribute1           ,
     attribute2 = p_attribute2           ,
     attribute3 = p_attribute3           ,
     attribute4 = p_attribute4           ,
     attribute5 = p_attribute5           ,
     attribute6 = p_attribute6           ,
     attribute7 = p_attribute7           ,
     attribute8 = p_attribute8           ,
     attribute9 = p_attribute9           ,
     attribute10 = p_attribute10         ,
     attribute11 = p_attribute11         ,
     attribute12 = p_attribute12         ,
     attribute13 = p_attribute13         ,
     attribute14 = p_attribute14         ,
     attribute15=  p_attribute15         ,
     attribute16 = p_attribute16         ,
     attribute17 = p_attribute17         ,
     attribute18 = p_attribute18         ,
     attribute19 = p_attribute19         ,
     attribute20 = p_attribute20         ,
     attribute_category = p_attribute_category  ,
     name = p_name                        ,
     last_update_date = p_last_update_date,
     last_updated_by = p_last_updated_by  ,
     last_update_login = p_last_update_login
  where position_id = p_position_id
  ;
  if (sql%notfound) then
    -- raise no_data_found;
    raise FND_API.G_EXC_ERROR ;
  end if;
  --
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
/* ----------------------------------------------------------------------- */

PROCEDURE ADD_ROW (
  p_api_version            in number,
  p_init_msg_list          in varchar2 := fnd_api.g_false,
  p_commit                 in varchar2 := fnd_api.g_false,
  p_validation_level       in number   := fnd_api.g_valid_level_full,
  p_return_status          OUT  NOCOPY varchar2,
  p_msg_count              OUT  NOCOPY number,
  p_msg_data               OUT  NOCOPY varchar2,
  p_rowid                  in OUT  NOCOPY varchar2,
  p_position_id            in number,
  p_organization_id        in number,
  p_data_extract_id        in number,
  p_position_definition_id in number,
  p_hr_position_id         in number,
  p_business_group_id      in number,
  p_effective_start_date   in date,
  p_effective_end_date     in date,
  p_set_of_books_id        in number,
  p_vacant_position_flag   in varchar2,
  p_attribute1          in varchar2,
  p_attribute2          in varchar2,
  p_attribute3          in varchar2,
  p_attribute4          in varchar2,
  p_attribute5          in varchar2,
  p_attribute6          in varchar2,
  p_attribute7          in varchar2,
  p_attribute8          in varchar2,
  p_attribute9          in varchar2,
  p_attribute10         in varchar2,
  p_attribute11         in varchar2,
  p_attribute12         in varchar2,
  p_attribute13         in varchar2,
  p_attribute14         in varchar2,
  p_attribute15         in varchar2,
  p_attribute16         in varchar2,
  p_attribute17         in varchar2,
  p_attribute18         in varchar2,
  p_attribute19         in varchar2,
  p_attribute20         in varchar2,
  p_attribute_category  in varchar2,
  p_name                in varchar2,
  p_mode                in varchar2 := 'R'


  ) is
  cursor c1 is select rowid from PSB_POSITIONS
     where position_id = p_position_id
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
  p_api_version => p_api_version,
  p_init_msg_list => p_init_msg_list,
  p_commit => p_commit,
  p_validation_level => p_validation_level,
  p_return_status => p_return_status,
  p_msg_count => p_msg_count,
  p_msg_data => p_msg_data,
  p_rowid => p_rowid,
  p_position_id => p_position_id,
  p_organization_id => p_organization_id,
  p_data_extract_id => p_data_extract_id,
  p_position_definition_id => p_position_definition_id ,
  p_hr_position_id => p_hr_position_id,
  p_business_group_id => p_business_group_id,
  p_effective_start_date => p_effective_start_date,
  p_effective_end_date => p_effective_end_date,
  p_set_of_books_id => p_set_of_books_id,
  p_vacant_position_flag => p_vacant_position_flag,
  p_attribute1 => p_attribute1          ,
  p_attribute2 => p_attribute2          ,
  p_attribute3 => p_attribute3          ,
  p_attribute4 => p_attribute4          ,
  p_attribute5 => p_attribute5          ,
  p_attribute6 => p_attribute6          ,
  p_attribute7 => p_attribute7          ,
  p_attribute8 => p_attribute8          ,
  p_attribute9 => p_attribute9          ,
  p_attribute10 => p_attribute10         ,
  p_attribute11 => p_attribute11        ,
  p_attribute12 => p_attribute12        ,
  p_attribute13 => p_attribute13        ,
  p_attribute14 => p_attribute14        ,
  p_attribute15 => p_attribute15        ,
  p_attribute16 => p_attribute16        ,
  p_attribute17 => p_attribute17        ,
  p_attribute18 => p_attribute18         ,
  p_attribute19 => p_attribute19         ,
  p_attribute20 => p_attribute20         ,
  p_attribute_category => p_attribute_category  ,
  p_name => p_name                ,
  p_mode => p_mode
  );
  --
  if FND_API.to_Boolean (p_commit) then
     commit work;
  end if;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

  return;
end if;

close c1;

UPDATE_ROW (
  p_api_version => p_api_version,
  p_init_msg_list => p_init_msg_list,
  p_commit => p_commit,
  p_validation_level => p_validation_level,
  p_return_status => p_return_status,
  p_msg_count => p_msg_count,
  p_msg_data => p_msg_data,
  p_position_id => p_position_id,
  p_organization_id => p_organization_id,
  p_data_extract_id => p_data_extract_id,
  p_position_definition_id => p_position_definition_id ,
  p_hr_position_id => p_hr_position_id      ,
  p_business_group_id => p_business_group_id   ,
  p_effective_start_date => p_effective_start_date,
  p_effective_end_date => p_effective_end_date  ,
  p_set_of_books_id => p_set_of_books_id     ,
  p_vacant_position_flag => p_vacant_position_flag,
  p_attribute1 => p_attribute1          ,
  p_attribute2 => p_attribute2          ,
  p_attribute3 => p_attribute3          ,
  p_attribute4 => p_attribute4          ,
  p_attribute5 => p_attribute5          ,
  p_attribute6 => p_attribute6          ,
  p_attribute7 => p_attribute7          ,
  p_attribute8 => p_attribute8          ,
  p_attribute9 => p_attribute9          ,
  p_attribute10 => p_attribute10         ,
  p_attribute11 => p_attribute11        ,
  p_attribute12 => p_attribute12        ,
  p_attribute13 => p_attribute13        ,
  p_attribute14 => p_attribute14        ,
  p_attribute15 => p_attribute15        ,
  p_attribute16 => p_attribute16        ,
  p_attribute17 => p_attribute17        ,
  p_attribute18 => p_attribute18         ,
  p_attribute19 => p_attribute19         ,
  p_attribute20 => p_attribute20         ,
  p_attribute_category => p_attribute_category  ,
  p_name => p_name                ,
  p_mode => p_mode
  );
  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

END ADD_ROW;
--
/* ----------------------------------------------------------------------- */

PROCEDURE DELETE_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number   := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_position_id         in number
) is
--
l_api_name    CONSTANT VARCHAR2(30) := 'Delete Row' ;
l_api_version CONSTANT NUMBER := 1.0 ;

l_return_status        VARCHAR2(1);
l_count                NUMBER;
--
BEGIN
  --
  SAVEPOINT Delete_Row ;
  --
  -- Initialize message list if p_init_msg_list is set to TRUE.
  --
  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;
  --
  p_return_status := FND_API.G_RET_STS_SUCCESS ;
  --
  -- validate first

  SELECT count(*) into l_count
    FROM psb_ws_position_lines
   WHERE position_id = p_position_id;

  IF (l_count <> 0) THEN
	fnd_message.set_name('PSB', 'PSB_POSITION_IN_WORKSHEET');
	fnd_msg_pub.add ;
	raise fnd_api.g_exc_error ;
  END IF;
  --

  delete from PSB_POSITIONS
  where position_id = p_position_id;
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
     rollback to Delete_Row;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     rollback to Delete_Row;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     rollback to Delete_Row ;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
END DELETE_ROW;

/*----------------------------------------------------------------*/

PROCEDURE Delete_Assignments
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
  ) IS

  l_api_name          CONSTANT VARCHAR2(30) := 'Delete_Assignments';
  l_api_version       CONSTANT NUMBER := 1.0 ;

BEGIN

  SAVEPOINT Delete_Assignments_Pvt;

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  delete from PSB_POSITION_ASSIGNMENTS
   where worksheet_id = p_worksheet_id;


  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Delete_Assignments_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Delete_Assignments_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     rollback to Delete_Assignments_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Delete_Assignments;

/*----------------------------------------------------------------*/

PROCEDURE Delete_Assignment_Employees
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_data_extract_id   IN   NUMBER
  ) IS

  l_api_name          CONSTANT VARCHAR2(30) := 'Delete_Assignment_Employees';
  l_api_version       CONSTANT NUMBER := 1.0 ;

BEGIN

  SAVEPOINT Delete_Assignment_Emp_Pvt;

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  delete from PSB_POSITION_ASSIGNMENTS
   where assignment_type = 'EMPLOYEE'
     and data_extract_id = p_data_extract_id;


  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Delete_Assignment_Emp_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Delete_Assignment_Emp_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     rollback to Delete_Assignment_Emp_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Delete_Assignment_Employees;

/*----------------------------------------------------------------*/

PROCEDURE Modify_Assignment
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status               OUT  NOCOPY     VARCHAR2,
  p_msg_count                   OUT  NOCOPY     NUMBER,
  p_msg_data                    OUT  NOCOPY     VARCHAR2,
  p_position_assignment_id      IN OUT  NOCOPY  NUMBER,
  p_data_extract_id             IN      NUMBER,
  p_worksheet_id                IN      NUMBER,
  p_position_id                 IN      NUMBER,
  p_assignment_type             IN      VARCHAR2,
  p_attribute_id                IN      NUMBER,
  p_attribute_value_id          IN      NUMBER,
  p_attribute_value             IN      VARCHAR2,
  p_pay_element_id              IN      NUMBER,
  p_pay_element_option_id       IN      NUMBER,
  p_effective_start_date        IN      DATE,
  p_effective_end_date          IN      DATE,
  p_element_value_type          IN      VARCHAR2,
  p_element_value               IN      NUMBER,
  p_currency_code               IN      VARCHAR2,
  p_pay_basis                   IN      VARCHAR2,
  p_employee_id                 IN      NUMBER,
  p_primary_employee_flag       IN      VARCHAR2,
  p_global_default_flag         IN      VARCHAR2,
  p_assignment_default_rule_id  IN      NUMBER,
  p_modify_flag                 IN      VARCHAR2,
  p_rowid                       IN OUT  NOCOPY  VARCHAR2,
  p_mode                        IN      VARCHAR2 := 'R'
) IS

  l_api_name                    CONSTANT VARCHAR2(30) := 'Modify_Assignment';
  l_api_version                 CONSTANT NUMBER       := 1.0 ;

  cursor c_Overlap is
    select position_assignment_id,
	   data_extract_id,
	   worksheet_id,
	   position_id,
	   assignment_type,
	   attribute_id,
	   attribute_value_id,
	   attribute_value,
	   pay_element_id,
	   pay_element_option_id,
	   effective_start_date,
	   effective_end_date,
	   element_value_type,
	   element_value,
	   currency_code,
	   pay_basis,
	   employee_id,
	   primary_employee_flag,
	   global_default_flag,
	   assignment_default_rule_id,
	   modify_flag
      from PSB_POSITION_ASSIGNMENTS
     where (worksheet_id is null or worksheet_id = p_worksheet_id)
       and (((p_assignment_type = 'ATTRIBUTE')
	 and (attribute_id = p_attribute_id))
	 or ((p_assignment_type = 'EMPLOYEE')
	 and (employee_id = p_employee_id))
	 or ((p_assignment_type = 'ELEMENT')
	 and (pay_element_id = p_pay_element_id)
	 and ((p_currency_code is null) or (currency_code = p_currency_code))))
       and ((((p_effective_end_date is not null)
	 and ((effective_start_date <= p_effective_end_date)
	  and (effective_end_date is null))
	  or ((effective_start_date between p_effective_start_date and p_effective_end_date)
	   or (effective_end_date between p_effective_start_date and p_effective_end_date)
	  or ((effective_start_date < p_effective_start_date)
	  and (effective_end_date > p_effective_end_date)))))
	  or ((p_effective_end_date is null)
	  and (nvl(effective_end_date, p_effective_start_date) >= p_effective_start_date)))
       and position_id = p_position_id;


 /*bug:6392080:start*/
  cursor c_attr_overlap is
    select position_assignment_id,
	   data_extract_id,
	   worksheet_id,
	   position_id,
	   assignment_type,
	   attribute_id,
	   attribute_value_id,
	   attribute_value,
	   pay_element_id,
	   pay_element_option_id,
	   effective_start_date,
	   effective_end_date,
	   element_value_type,
	   element_value,
	   currency_code,
	   pay_basis,
	   employee_id,
	   primary_employee_flag,
	   global_default_flag,
	   assignment_default_rule_id,
	   modify_flag
      from PSB_POSITION_ASSIGNMENTS ppa
     where ((worksheet_id = p_worksheet_id) or (worksheet_id is null
       and not exists
          (select 1
             from psb_position_assignments ppa1
            where ppa1.position_id = p_position_id
              and ((p_currency_code is null) or (ppa1.currency_code = p_currency_code))
              and ppa1.assignment_type = 'ATTRIBUTE'
              and ppa1.attribute_id = ppa.attribute_id
              and ppa1.worksheet_id = p_worksheet_id
          )))
       and p_assignment_type = 'ATTRIBUTE'
       and attribute_id = p_attribute_id
	 and ((p_currency_code is null) or (currency_code = p_currency_code))
       and ((((p_effective_end_date is not null)
	 and ((effective_start_date <= p_effective_end_date)
	  and (effective_end_date is null))
	  or ((effective_start_date between p_effective_start_date and p_effective_end_date)
	   or (effective_end_date between p_effective_start_date and p_effective_end_date)
	  or ((effective_start_date < p_effective_start_date)
	  and (effective_end_date > p_effective_end_date)))))
	  or ((p_effective_end_date is null)
	  and (nvl(effective_end_date, p_effective_start_date) >= p_effective_start_date)))
       and position_id = p_position_id;
 /*bug:6392080:end*/

  --
  --   c_salary_overlap returns all salary for the position which overlaps the input record
  --   and exclude any base record which have any overlapping WS assignment for the p_worksheet_id
  --   This cursor is used when the input record is a salary element; all others use c_overlap
  --
  --   Salary should not have any duplicate for any date range regarless of the salary element
  --   and are now processed regarless of the salary element
  --
  --   When an ovelap exists, the input salary (regardless of the pay_element_id) supercedes the
  --   overlap records. These overlaps are processed using the same logic as c_overlap.
  --   The salary overlap is treated as a set so there is no test that the pay_element_id is =
  --   p_pay_element_id.
  --
  --   This changed the way the form displays the salary since they are now treated as a set
  --
  cursor c_Salary_Overlap is
    select a.position_assignment_id,
	   a.data_extract_id,
	   a.worksheet_id,
	   a.position_id,
	   a.assignment_type,
	   a.attribute_id,
	   a.attribute_value_id,
	   a.attribute_value,
	   a.pay_element_id,
	   a.pay_element_option_id,
	   a.effective_start_date,
	   a.effective_end_date,
	   a.element_value_type,
	   a.element_value,
	   a.currency_code,
	   a.pay_basis,
	   a.employee_id,
	   a.primary_employee_flag,
	   a.global_default_flag,
	   a.assignment_default_rule_id,
	   a.modify_flag
      from PSB_POSITION_ASSIGNMENTS a,
	   PSB_PAY_ELEMENTS el
     where
	  ( (nvl(a.worksheet_id, FND_API.G_MISS_NUM) = nvl(p_worksheet_id, FND_API.G_MISS_NUM)) OR
	      (p_worksheet_id is not null and worksheet_id is null
	      and not exists
	      (select 1 from
	       psb_position_assignments c ,psb_pay_elements pe2
	       where c.position_id = a.position_id
	       and c.pay_element_id = pe2.pay_element_id
	       and pe2.salary_flag = 'Y'
	       and c.worksheet_id = p_worksheet_id
	       and ( (
		nvl(c.effective_start_date,PSB_POSITIONS_PVT.GET_end_date+1) between
		nvl(a.effective_start_date,PSB_POSITIONS_PVT.GET_end_date) and
		nvl(a.effective_end_date,nvl(PSB_POSITIONS_PVT.GET_end_date,
		c.effective_start_date ))) or (
		nvl(a.effective_start_date,PSB_POSITIONS_PVT.GET_end_date+1) between
		nvl(c.effective_start_date,PSB_POSITIONS_PVT.GET_end_date) and
		nvl(c.effective_end_date,nvl(PSB_POSITIONS_PVT.GET_end_date,
		a.effective_start_date ))) )
	       )
	    )
	    )
       and ( (p_currency_code is null) or (currency_code = p_currency_code))
       and ((((p_effective_end_date is not null)
	 and ((effective_start_date <= p_effective_end_date)
	  and (effective_end_date is null))
	  or ((effective_start_date between p_effective_start_date and p_effective_end_date)
	   or (effective_end_date between p_effective_start_date and p_effective_end_date)
	  or ((effective_start_date < p_effective_start_date)
	  and (effective_end_date > p_effective_end_date)))))
	  or ((p_effective_end_date is null)
	  and (nvl(effective_end_date, p_effective_start_date) >= p_effective_start_date)))
       and position_id = p_position_id
       and a.assignment_type = 'ELEMENT'
       and a.pay_element_id = el.pay_element_id
       and el.salary_flag = 'Y';

  cursor c_Salary is
    select salary_flag
      from PSB_PAY_ELEMENTS
     where pay_element_id = p_pay_element_id;

   /*For Bug No : 2847566 Start*/
     Cursor C_Get_Pay_Basis Is
    Select pay_basis
       From psb_position_assignments
     Where ((worksheet_id is null) or (worksheet_id = p_worksheet_id))
          And assignment_type = 'ELEMENT'
          And position_id = p_position_id
          And pay_basis is not null
          And ROWNUM < 2;

	  l_pay_basis               VARCHAR2(10);
    /*For Bug No : 2847566 End*/


  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);

  l_rowid                   VARCHAR2(100);
  l_position_assignment_id  NUMBER;
  l_worksheet_id            NUMBER;
  l_out_worksheet_id        NUMBER;
  l_out_start_date          DATE;
  l_out_end_date            DATE;

  l_salary_flag             VARCHAR2(1);
  l_salary_failed           VARCHAR2(1);

  l_init_index              BINARY_INTEGER;
  l_assign_index            BINARY_INTEGER;

  l_created_record          VARCHAR2(1):= FND_API.G_FALSE;
  l_updated_record          VARCHAR2(1);

  l_ws_overlap              VARCHAR2(1):= FND_API.G_FALSE;

  l_userid                  NUMBER;
  l_loginid                 NUMBER;

  /* start bug no 4213882 */
  l_element_id NUMBER;
  /* end bug no 4213882 */

BEGIN

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  l_userid := FND_GLOBAL.USER_ID;
  l_loginid := FND_GLOBAL.LOGIN_ID;


  --++
  -- modified update_row to pass pay_element_id and modify with input p_pay_element_id for salary overlap
  -- added order by on cursors

  update PSB_POSITION_ASSIGNMENTS
     set attribute_value_id = decode(p_attribute_value_id, null, attribute_value_id, p_attribute_value_id),
	 attribute_value = decode(p_attribute_value, null, attribute_value, p_attribute_value),
	 pay_element_option_id = decode(p_pay_element_option_id, null, pay_element_option_id, p_pay_element_option_id),
	 element_value_type = decode(p_element_value_type, null, element_value_type, p_element_value_type),
	 element_value = decode(p_element_value, null, element_value, p_element_value),
	 currency_code = decode(p_currency_code, null, currency_code, p_currency_code),
	 pay_basis = decode(p_pay_basis, null, pay_basis, p_pay_basis),
	 primary_employee_flag = decode(p_primary_employee_flag, null, primary_employee_flag, p_primary_employee_flag),
	 global_default_flag = decode(p_global_default_flag, null, global_default_flag, p_global_default_flag),
	 assignment_default_rule_id = decode(p_assignment_default_rule_id, null, assignment_default_rule_id, p_assignment_default_rule_id),
	 modify_flag = decode(p_modify_flag, null, modify_flag, p_modify_flag),
	 last_update_date = sysdate,
	 last_updated_by = l_userid,
	 last_update_login = l_loginid
   where nvl(worksheet_id, FND_API.G_MISS_NUM) = nvl(p_worksheet_id, FND_API.G_MISS_NUM)
     and (((p_assignment_type = 'ELEMENT') and (pay_element_id = p_pay_element_id))
       or ((p_assignment_type = 'ATTRIBUTE') and (attribute_id = p_attribute_id))
       or ((p_assignment_type = 'EMPLOYEE') and (employee_id = p_employee_id)))
     and nvl(effective_end_date, FND_API.G_MISS_DATE) = nvl(p_effective_end_date, FND_API.G_MISS_DATE)
     and effective_start_date = p_effective_start_date
     and position_id = p_position_id;


  if SQL%NOTFOUND then
  --
  --  When no exact match is found for the input record, we process it
  --  (i)   set the array using either of c_overlap or c_salary_overlap depeding on salary flag
  --  (ii)  if no match found then just do an insert
  --  (iii) if match found and modify_flag is 'N'
  --  (iv)  if match found and modify_flag is 'Y' or null
  --
  begin

    l_salary_failed := FND_API.G_FALSE;

    /*For Bug No : 2847566 Start*/
       l_pay_basis := p_pay_basis;
    /*For Bug No : 2847566 End*/

    if p_assignment_type = 'ELEMENT' then

       for c_Salary_Rec in c_Salary loop
	  l_salary_flag := c_Salary_Rec.salary_flag;
       end loop;

      /*For Bug No : 2847566 Start*/
       --following logic has been added to ensure that pay_basis
       -- is being inserted for allsalary type elements. This is
       --particularly required when there are salary elements
     --defined in PSB. We need to get pay_basis from existing element assignment

         if (l_salary_flag = 'Y' and p_pay_basis is null) then

           for  C_Get_Pay_Basis_Rec in C_Get_Pay_Basis loop
              l_pay_basis := C_Get_Pay_Basis_Rec.pay_basis;
           end loop;

         end if;
       /*For Bug No : 2847566 End*/

    end if;

    for l_init_index in 1..g_assign.Count loop
      g_assign(l_init_index).position_assignment_id := null;
      g_assign(l_init_index).data_extract_id := null;
      g_assign(l_init_index).worksheet_id := null;
      g_assign(l_init_index).position_id := null;
      g_assign(l_init_index).assignment_type := null;
      g_assign(l_init_index).attribute_id := null;
      g_assign(l_init_index).attribute_value_id := null;
      g_assign(l_init_index).attribute_value := null;
      g_assign(l_init_index).pay_element_id := null;
      g_assign(l_init_index).pay_element_option_id := null;
      g_assign(l_init_index).effective_start_date := null;
      g_assign(l_init_index).effective_end_date := null;
      g_assign(l_init_index).element_value_type := null;
      g_assign(l_init_index).element_value := null;
      g_assign(l_init_index).currency_code := null;
      g_assign(l_init_index).pay_basis := null;
      g_assign(l_init_index).employee_id := null;
      g_assign(l_init_index).primary_employee_flag := null;
      g_assign(l_init_index).global_default_flag := null;
      g_assign(l_init_index).assignment_default_rule_id := null;
      g_assign(l_init_index).modify_flag := null;
      g_assign(l_init_index).delete_flag := null;
    end loop;

    g_num_assign := 0;

    /*bug:6392080:start*/
    if p_assignment_type = 'ATTRIBUTE' then

    for c_Overlap_Rec in c_attr_overlap loop
      g_num_assign := g_num_assign + 1;

      g_assign(g_num_assign).position_assignment_id := c_Overlap_Rec.position_assignment_id;
      g_assign(g_num_assign).data_extract_id := c_Overlap_Rec.data_extract_id;
      g_assign(g_num_assign).worksheet_id := c_Overlap_Rec.worksheet_id;
      g_assign(g_num_assign).position_id := c_Overlap_Rec.position_id;
      g_assign(g_num_assign).assignment_type := c_Overlap_Rec.assignment_type;
      g_assign(g_num_assign).attribute_id := c_Overlap_Rec.attribute_id;
      g_assign(g_num_assign).attribute_value_id := c_Overlap_Rec.attribute_value_id;
      g_assign(g_num_assign).attribute_value := c_Overlap_Rec.attribute_value;
      g_assign(g_num_assign).pay_element_id := c_Overlap_Rec.pay_element_id;
      g_assign(g_num_assign).pay_element_option_id := c_Overlap_Rec.pay_element_option_id;
      g_assign(g_num_assign).effective_start_date := c_Overlap_Rec.effective_start_date;
      g_assign(g_num_assign).effective_end_date := c_Overlap_Rec.effective_end_date;
      g_assign(g_num_assign).element_value_type := c_Overlap_Rec.element_value_type;
      g_assign(g_num_assign).element_value := c_Overlap_Rec.element_value;
      g_assign(g_num_assign).currency_code := c_Overlap_Rec.currency_code;
      g_assign(g_num_assign).pay_basis := c_Overlap_Rec.pay_basis;
      g_assign(g_num_assign).employee_id := c_Overlap_Rec.employee_id;
      g_assign(g_num_assign).primary_employee_flag := c_Overlap_Rec.primary_employee_flag;
      g_assign(g_num_assign).global_default_flag := c_Overlap_Rec.global_default_flag;
      g_assign(g_num_assign).assignment_default_rule_id := c_Overlap_Rec.assignment_default_rule_id;
      g_assign(g_num_assign).modify_flag := c_Overlap_Rec.modify_flag;
      g_assign(g_num_assign).delete_flag := FND_API.G_TRUE;

      if g_assign(g_num_assign).worksheet_id = p_worksheet_id then
      begin

	if not FND_API.to_Boolean(l_ws_overlap) then
	  l_ws_overlap := FND_API.G_TRUE;
	end if;

      end;
      end if;

    end loop;
    /*bug:6392080:end*/

    --
    -- set the array using either cursor depending on salary flag
    -- set l_ws_overlap if any overlap is WS specific. This flag will be used to control
    -- processing of the base overlap
    --
    elsif l_salary_flag = 'Y' then

    for c_Overlap_Rec in c_Salary_Overlap loop
      g_num_assign := g_num_assign + 1;

      g_assign(g_num_assign).position_assignment_id := c_Overlap_Rec.position_assignment_id;
      g_assign(g_num_assign).data_extract_id := c_Overlap_Rec.data_extract_id;
      g_assign(g_num_assign).worksheet_id := c_Overlap_Rec.worksheet_id;
      g_assign(g_num_assign).position_id := c_Overlap_Rec.position_id;
      g_assign(g_num_assign).assignment_type := c_Overlap_Rec.assignment_type;
      g_assign(g_num_assign).attribute_id := c_Overlap_Rec.attribute_id;
      g_assign(g_num_assign).attribute_value_id := c_Overlap_Rec.attribute_value_id;
      g_assign(g_num_assign).attribute_value := c_Overlap_Rec.attribute_value;
      g_assign(g_num_assign).pay_element_id := c_Overlap_Rec.pay_element_id;
      g_assign(g_num_assign).pay_element_option_id := c_Overlap_Rec.pay_element_option_id;
      g_assign(g_num_assign).effective_start_date := c_Overlap_Rec.effective_start_date;
      g_assign(g_num_assign).effective_end_date := c_Overlap_Rec.effective_end_date;
      g_assign(g_num_assign).element_value_type := c_Overlap_Rec.element_value_type;
      g_assign(g_num_assign).element_value := c_Overlap_Rec.element_value;
      g_assign(g_num_assign).currency_code := c_Overlap_Rec.currency_code;
      g_assign(g_num_assign).pay_basis := c_Overlap_Rec.pay_basis;
      g_assign(g_num_assign).employee_id := c_Overlap_Rec.employee_id;
      g_assign(g_num_assign).primary_employee_flag := c_Overlap_Rec.primary_employee_flag;
      g_assign(g_num_assign).global_default_flag := c_Overlap_Rec.global_default_flag;
      g_assign(g_num_assign).assignment_default_rule_id := c_Overlap_Rec.assignment_default_rule_id;
      g_assign(g_num_assign).modify_flag := c_Overlap_Rec.modify_flag;
      g_assign(g_num_assign).delete_flag := FND_API.G_TRUE;

      if g_assign(g_num_assign).worksheet_id = p_worksheet_id then
      begin

	if not FND_API.to_Boolean(l_ws_overlap) then
	  l_ws_overlap := FND_API.G_TRUE;
	end if;

      end;
      end if;

    end loop;
    else

    for c_Overlap_Rec in c_Overlap loop
      g_num_assign := g_num_assign + 1;

      g_assign(g_num_assign).position_assignment_id := c_Overlap_Rec.position_assignment_id;
      g_assign(g_num_assign).data_extract_id := c_Overlap_Rec.data_extract_id;
      g_assign(g_num_assign).worksheet_id := c_Overlap_Rec.worksheet_id;
      g_assign(g_num_assign).position_id := c_Overlap_Rec.position_id;
      g_assign(g_num_assign).assignment_type := c_Overlap_Rec.assignment_type;
      g_assign(g_num_assign).attribute_id := c_Overlap_Rec.attribute_id;
      g_assign(g_num_assign).attribute_value_id := c_Overlap_Rec.attribute_value_id;
      g_assign(g_num_assign).attribute_value := c_Overlap_Rec.attribute_value;
      g_assign(g_num_assign).pay_element_id := c_Overlap_Rec.pay_element_id;
      g_assign(g_num_assign).pay_element_option_id := c_Overlap_Rec.pay_element_option_id;
      g_assign(g_num_assign).effective_start_date := c_Overlap_Rec.effective_start_date;
      g_assign(g_num_assign).effective_end_date := c_Overlap_Rec.effective_end_date;
      g_assign(g_num_assign).element_value_type := c_Overlap_Rec.element_value_type;
      g_assign(g_num_assign).element_value := c_Overlap_Rec.element_value;
      g_assign(g_num_assign).currency_code := c_Overlap_Rec.currency_code;
      g_assign(g_num_assign).pay_basis := c_Overlap_Rec.pay_basis;
      g_assign(g_num_assign).employee_id := c_Overlap_Rec.employee_id;
      g_assign(g_num_assign).primary_employee_flag := c_Overlap_Rec.primary_employee_flag;
      g_assign(g_num_assign).global_default_flag := c_Overlap_Rec.global_default_flag;
      g_assign(g_num_assign).assignment_default_rule_id := c_Overlap_Rec.assignment_default_rule_id;
      g_assign(g_num_assign).modify_flag := c_Overlap_Rec.modify_flag;
      g_assign(g_num_assign).delete_flag := FND_API.G_TRUE;

      if g_assign(g_num_assign).worksheet_id = p_worksheet_id then
      begin

	if not FND_API.to_Boolean(l_ws_overlap) then
	  l_ws_overlap := FND_API.G_TRUE;
	end if;

      end;
      end if;

    end loop;
    end if;

    --
    -- no overlap found
    -- modified this routine to remove salary validation since salary now uses a
    -- different cursor which includes all salary. If there is no overlap, then it means
    -- there was no overlap of any salary so we can insert the input
    --

    if ((g_num_assign = 0) and
       ((p_modify_flag is null) or (p_modify_flag = 'Y'))) then
    begin

      /* No Overlaps, Input not for protecting assignment: direct insert */
      -- removed salary validation
      begin

	PSB_POSITION_ASSIGNMENTS_PVT.Insert_Row
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_rowid => l_rowid,
	    p_position_assignment_id => l_position_assignment_id,
	    p_data_extract_id => p_data_extract_id,
	    p_worksheet_id => p_worksheet_id,
	    p_position_id => p_position_id,
	    p_assignment_type => p_assignment_type,
	    p_attribute_id => p_attribute_id,
	    p_attribute_value_id => p_attribute_value_id,
	    p_attribute_value => p_attribute_value,
	    p_pay_element_id => p_pay_element_id,
	    p_pay_element_option_id => p_pay_element_option_id,
	    p_effective_start_date => p_effective_start_date,
	    p_effective_end_date => p_effective_end_date,
	    p_element_value_type => p_element_value_type,
	    p_element_value => p_element_value,
	    p_currency_code => p_currency_code,
	    /* For Bug No. 2847566 Start */
	    --p_pay_basis => p_pay_basis,
	    p_pay_basis  => l_pay_basis,
	    /* For Bug No. 2847566 End */
	    p_employee_id => p_employee_id,
	    p_primary_employee_flag => p_primary_employee_flag,
	    p_global_default_flag => p_global_default_flag,
	    p_assignment_default_rule_id => p_assignment_default_rule_id,
	    p_modify_flag => p_modify_flag,
	    p_mode => p_mode);

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

	p_rowid := l_rowid;
	p_position_assignment_id := l_position_assignment_id;

      end;

    end;
    else
    begin

     --
     -- 1 or more Base or Worksheet Overlaps exists for overlap records where a worksheet overlap exists or do not exist
     -- p_modify_flag of 'N' means the assignment is protected from changes
     -- the p_modify_flag is set to 'N' only when there are element constraints
     --
     -- modified 'if' statement to include test on pay_element_id and option_id if input is a salary element
     --
      if p_modify_flag = 'N' then
      begin

	/* Set Protected Flag for Position Assignment */

	for l_assign_index in 1..g_num_assign loop

	  if FND_API.to_Boolean(l_ws_overlap) then
	  begin

	    /* Worksheet Overlap, Update Protected Flag for the Assignment */
	    -- modified 'if' statement to include test on pay_element_id and option_id if input is a salary element

	    if ((g_assign(l_assign_index).worksheet_id = p_worksheet_id) and
		((nvl(g_assign(l_assign_index).pay_element_option_id, FND_API.G_MISS_NUM) = nvl(p_pay_element_option_id, FND_API.G_MISS_NUM)))
		 OR
		 (l_salary_flag='Y'
		  and nvl(g_assign(l_assign_index).pay_element_option_id, FND_API.G_MISS_NUM) = nvl(p_pay_element_option_id, FND_API.G_MISS_NUM)
		  and nvl(g_assign(l_assign_index).pay_element_id, FND_API.G_MISS_NUM) = nvl(p_pay_element_id, FND_API.G_MISS_NUM)
		 )
		) then
	    begin

	      PSB_POSITION_ASSIGNMENTS_PVT.Update_Row
		 (p_api_version => 1.0,
		  p_return_status => l_return_status,
		  p_msg_count => l_msg_count,
		  p_msg_data => l_msg_data,
		  p_position_assignment_id => g_assign(l_assign_index).position_assignment_id,
		  p_modify_flag => p_modify_flag,
		  p_mode => p_mode);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      end if;

	      g_assign(l_assign_index).delete_flag := FND_API.G_FALSE;

	    end;
	    end if;

	  end;
	  else
	  begin

	    /* There is No Worksheet Overlap, so Replicate Base Overlap and update Protected Flag for the Assignment */
	    -- modified 'if' statement to include test on pay_element_id and option_id if input is a salary element


	    if ((nvl(g_assign(l_assign_index).pay_element_option_id, FND_API.G_MISS_NUM) = nvl(p_pay_element_option_id, FND_API.G_MISS_NUM)
	       )
		 OR
		 (l_salary_flag='Y'
		  and nvl(g_assign(l_assign_index).pay_element_option_id, FND_API.G_MISS_NUM) = nvl(p_pay_element_option_id, FND_API.G_MISS_NUM)
		  and nvl(g_assign(l_assign_index).pay_element_id, FND_API.G_MISS_NUM) = nvl(p_pay_element_id, FND_API.G_MISS_NUM)
		 )
	       ) then
	    begin

	      Modify_Assignment_WS
		    (p_return_status => l_return_status,
		     p_position_assignment_id => l_position_assignment_id,
		     p_data_extract_id => p_data_extract_id,
		     p_worksheet_id => p_worksheet_id,
		     p_position_id => p_position_id,
		     p_assignment_type => g_assign(l_assign_index).assignment_type,
		     p_attribute_id => g_assign(l_assign_index).attribute_id,
		     p_attribute_value_id => g_assign(l_assign_index).attribute_value_id,
		     p_attribute_value => g_assign(l_assign_index).attribute_value,
		     p_pay_element_id => g_assign(l_assign_index).pay_element_id,
		     p_pay_element_option_id => g_assign(l_assign_index).pay_element_option_id,
		     p_effective_start_date => greatest(g_assign(l_assign_index).effective_start_date, p_effective_start_date),
		     p_effective_end_date => least(nvl(g_assign(l_assign_index).effective_end_date, p_effective_end_date), p_effective_end_date),
		     p_element_value_type => g_assign(l_assign_index).element_value_type,
		     p_element_value => g_assign(l_assign_index).element_value,
		     p_currency_code => nvl(p_currency_code, g_assign(l_assign_index).currency_code),
		     p_pay_basis => g_assign(l_assign_index).pay_basis,
		     p_employee_id => g_assign(l_assign_index).employee_id,
		     p_primary_employee_flag => g_assign(l_assign_index).primary_employee_flag,
		     p_global_default_flag => g_assign(l_assign_index).global_default_flag,
		     p_assignment_default_rule_id => g_assign(l_assign_index).assignment_default_rule_id,
		     p_modify_flag => p_modify_flag,
		     p_rowid => l_rowid);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      end if;

	      p_rowid := l_rowid;
	      p_position_assignment_id := l_position_assignment_id;

	    end;
	    end if;

	  end;
	  end if;

	end loop;

      end; /* end Check for modify_flag 'N'*/
      else
      begin

	--
	-- overlap exists and modify_flag is 'Y' or null
	-- for each record in the ovelap,
	--   check input dates with the overlap records
	--   (i)   start_date matches
	--   (ii)  overlap dates and overlap records have the same worksheet id
	--         - depending on the overlap's start date and input's start date either
	--           update the overlap's start date or create a new record
	--         - depending on the overlap's end date and input's end date either
	--           update the overlap's end date or create a new record
	--         - modified the update row to pass pay_element_id and pay_element_option_id due to the salary change
	--   (iii) overlap dates and overlap records is base and input is not base (= p_worksheet_id) and
	--         there is NO worksheet overlap in the overlap records.
	--         (If there are worksheet overlaps, it will will be processed in (ii) ).
	--         - always create the input record since the overlap is a base
	--         - create a record from the input's end date +1 to the overlaps's end date
	--           if the overlap's end date is beyond the input's end date
	--
	--  Modified the all update_row api  to pass pay_element_id and pay_element_option_id due to the salary change

	for l_assign_index in 1..g_num_assign loop

	  l_updated_record := FND_API.G_FALSE;

	  /* Effective Start Date Matches */

	  --   (i)   start_date matches
	  --
	  --   this logic is performed for form changes of base assignments when in modify position WS or budget revision
	  --   for which p_worksheet_id is not null. The form initially shows the base where the start date is not
	  --   updateable. When changing for example the end date, this routine will create a WS specific record.
	  --   If the original record is a WS specific and the end date is modified, the overlap  is updated
	  --
	  --   If the change was done from Modify Positions form which processes only base, then just update the record
	  --
	  --   From the form, the only possible routines processed for this api are :
	  --     - 1 overlap only where effective date matches either base or Ws specific
	  --     - no overlap since the form already tests for overlaps (g_num_assign is 0)
	  --
	  --   This logic is also performed when called from other than form and the start date matches
	  --   ** This poses a problem when the start date matches with overlap and the routine is called from other than
	  --   form. This routine will be performed, but the other overlaps will be processed using the other routines
	  --   depending on the date. The result will be overlap assignments.
	  --   Note that the overlap cursors do not control the way the record is retrieved so the overlap records
	  --   may come in any order, i.e., overlap with date matches as the first record or last record or middle record
	  --
	  if g_assign(l_assign_index).effective_start_date = p_effective_start_date then
	  begin
	    if ((nvl(g_assign(l_assign_index).worksheet_id, FND_API.G_MISS_NUM) = nvl(p_worksheet_id, FND_API.G_MISS_NUM)) and
	       ((g_assign(l_assign_index).modify_flag is null) or (g_assign(l_assign_index).modify_flag = 'Y'))) then
	    begin

	      --+ pass input pay_element_id and pay_element_option_id so that salary overlap will result
	      --+ of update will have the new input salary values

	      PSB_POSITION_ASSIGNMENTS_PVT.Update_Row
		 (p_api_version => 1.0,
		  p_return_status => l_return_status,
		  p_msg_count => l_msg_count,
		  p_msg_data => l_msg_data,
		  p_position_assignment_id => g_assign(l_assign_index).position_assignment_id,
		  p_pay_element_option_id => p_pay_element_option_id,
		  p_attribute_value_id => p_attribute_value_id,
		  p_attribute_value => p_attribute_value,
		  p_effective_end_date => p_effective_end_date,
		  p_pay_element_id     => p_pay_element_id,
		  p_element_value_type => p_element_value_type,
		  p_element_value => p_element_value,
		  p_global_default_flag => p_global_default_flag,
		  p_assignment_default_rule_id => p_assignment_default_rule_id,
		  p_modify_flag => p_modify_flag,
		  p_pay_basis => g_assign(l_assign_index).pay_basis,
		  p_employee_id => p_employee_id,
		  p_primary_employee_flag => p_primary_employee_flag,
		  p_mode => p_mode);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR;
	      end if;

	      g_assign(l_assign_index).delete_flag := FND_API.G_FALSE;

	    end;
	    elsif ((g_assign(l_assign_index).worksheet_id is null) and (p_worksheet_id is not null) and
		   (not FND_API.to_Boolean(l_ws_overlap))) then
	    begin
	      PSB_POSITION_ASSIGNMENTS_PVT.Insert_Row
		 (p_api_version => 1.0,
		  p_return_status => l_return_status,
		  p_msg_count => l_msg_count,
		  p_msg_data => l_msg_data,
		  p_rowid => l_rowid,
		  p_position_assignment_id => l_position_assignment_id,
		  p_data_extract_id => p_data_extract_id,
		  p_worksheet_id => p_worksheet_id,
		  p_position_id => p_position_id,
		  p_assignment_type => p_assignment_type,
		  p_attribute_id => p_attribute_id,
		  p_attribute_value_id => p_attribute_value_id,
		  p_attribute_value => p_attribute_value,
		  p_pay_element_id => p_pay_element_id,
		  p_pay_element_option_id => p_pay_element_option_id,
		  p_effective_start_date => p_effective_start_date,
		  p_effective_end_date => p_effective_end_date,
		  p_element_value_type => p_element_value_type,
		  p_element_value => p_element_value,
		  p_currency_code => nvl(p_currency_code, g_assign(l_assign_index).currency_code),
		  p_pay_basis => g_assign(l_assign_index).pay_basis,
		  p_employee_id => p_employee_id,
		  p_primary_employee_flag => p_primary_employee_flag,
		  p_global_default_flag => p_global_default_flag,
		  p_assignment_default_rule_id => p_assignment_default_rule_id,
		  p_modify_flag => p_modify_flag,
		  p_mode => p_mode);

	      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		raise FND_API.G_EXC_ERROR ;
	      end if;

	      p_rowid := l_rowid;
	      p_position_assignment_id := l_position_assignment_id;

	    end;
	    end if;

	  end;

	  /* Effective Dates Overlap */

	  --   (ii)  overlap dates and overlap records have the same worksheet id
	  --  process overlap records here
	  --  modified if statement to include test on  p_effective_end_date is null so that if
	  --   overlap.start_date > input.start_date and p_end is null the overlap will not be ignored
	  --  modified plus to minus for end date test ('OR' condition) to include overlaps with end date = input end date
	  --     since these records are ignored and input is not processed

	  elsif (((g_assign(l_assign_index).effective_start_date <= (p_effective_start_date - 1)) and
		 ((g_assign(l_assign_index).effective_end_date is null) or
		  (p_effective_end_date is null) or
		  (g_assign(l_assign_index).effective_end_date > (p_effective_start_date - 1)))) or
		 ((g_assign(l_assign_index).effective_start_date > p_effective_start_date) and
		 ((g_assign(l_assign_index).effective_end_date is null) or
		  (p_effective_end_date is null) or
		  (g_assign(l_assign_index).effective_end_date > (p_effective_end_date - 1))))) then
	  begin

	    if ((nvl(g_assign(l_assign_index).worksheet_id, FND_API.G_MISS_NUM) = nvl(p_worksheet_id, FND_API.G_MISS_NUM)) and
	       ((g_assign(l_assign_index).modify_flag is null) or (g_assign(l_assign_index).modify_flag = 'Y'))) then
	    begin

	      if ((g_assign(l_assign_index).effective_start_date < (p_effective_start_date - 1)) and
		 ((g_assign(l_assign_index).effective_end_date is null) or
		  (g_assign(l_assign_index).effective_end_date > (p_effective_start_date - 1)))) then
	      begin
		--++ pass input pay_element_option_id so that if input is salary, the updated row will
		--++ reflect the input value

                /*  start bug no 4213882 */
		IF PSB_HR_POPULATE_DATA_PVT.g_pop_assignment = 'Y' AND
		   PSB_HR_POPULATE_DATA_PVT.g_extract_method = 'REFRESH' THEN
		   l_element_id := g_assign(l_assign_index).pay_element_id;
	        ELSE
	           l_element_id := p_pay_element_id;
	        END IF;
	       /* end bug no 4213882 */

		PSB_POSITION_ASSIGNMENTS_PVT.Update_Row
		   (p_api_version => 1.0,
		    p_return_status => l_return_status,
		    p_msg_count => l_msg_count,
		    p_msg_data => l_msg_data,
		    p_position_assignment_id => g_assign(l_assign_index).position_assignment_id,
/* Bug No 2259505 Start */
-- Uncommented the first line and commented the second line
		    p_pay_element_option_id => g_assign(l_assign_index).pay_element_option_id,
--                    p_pay_element_option_id => p_pay_element_option_id,
/* Bug No 2259505 End */
		    p_attribute_value_id => g_assign(l_assign_index).attribute_value_id,
		    p_attribute_value => g_assign(l_assign_index).attribute_value,
		    p_effective_end_date => p_effective_start_date - 1,
		    /* start bug no 4213882 */
		    p_pay_element_id     => l_element_id,
                    /* End bug no   4213882 */
		    p_element_value_type => g_assign(l_assign_index).element_value_type,
		    p_element_value => g_assign(l_assign_index).element_value,
		    p_global_default_flag => g_assign(l_assign_index).global_default_flag,
		    p_assignment_default_rule_id => g_assign(l_assign_index).assignment_default_rule_id,
		    p_modify_flag => g_assign(l_assign_index).modify_flag,
		    p_pay_basis => g_assign(l_assign_index).pay_basis,
		    p_employee_id => g_assign(l_assign_index).employee_id,
		    p_primary_employee_flag => g_assign(l_assign_index).primary_employee_flag,
		    p_mode => p_mode);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		else
		  l_updated_record := FND_API.G_TRUE;
		end if;

		g_assign(l_assign_index).delete_flag := FND_API.G_FALSE;

	      end;
	      elsif ((g_assign(l_assign_index).effective_start_date > p_effective_start_date) and
		    ((p_effective_end_date is not null) and
		    ((g_assign(l_assign_index).effective_end_date is null) or
		     (g_assign(l_assign_index).effective_end_date > (p_effective_end_date - 1))))) then
	      begin

		--++ pass input pay_element_option_id so that if input is salary, the updated row will
		--++ reflect the input value
                /*  start bug no 4213882 */
		IF PSB_HR_POPULATE_DATA_PVT.g_pop_assignment = 'Y' AND
		   PSB_HR_POPULATE_DATA_PVT.g_extract_method = 'REFRESH' THEN
		   l_element_id := g_assign(l_assign_index).pay_element_id;
	        ELSE
	           l_element_id := p_pay_element_id;
	        END IF;
	        /* end bug no 4213882 */

		PSB_POSITION_ASSIGNMENTS_PVT.Update_Row
		   (p_api_version => 1.0,
		    p_return_status => l_return_status,
		    p_msg_count => l_msg_count,
		    p_msg_data => l_msg_data,
		    p_position_assignment_id => g_assign(l_assign_index).position_assignment_id,
/* Bug No 2259505 Start */
-- Commented the first line and Uncommented the second line
--                    p_pay_element_option_id => p_pay_element_option_id,
		    p_pay_element_option_id => g_assign(l_assign_index).pay_element_option_id,
/* Bug No 2259505 End */
		    p_attribute_value_id => g_assign(l_assign_index).attribute_value_id,
		    p_attribute_value => g_assign(l_assign_index).attribute_value,
		    p_effective_start_date => p_effective_end_date + 1,
		     /* start bug no 4213882 */
		    p_pay_element_id     => l_element_id,
                    /* start bug no 4213882 */
		    p_element_value_type => g_assign(l_assign_index).element_value_type,
		    p_element_value => g_assign(l_assign_index).element_value,
		    p_global_default_flag => g_assign(l_assign_index).global_default_flag,
		    p_assignment_default_rule_id => g_assign(l_assign_index).assignment_default_rule_id,
		    p_modify_flag => g_assign(l_assign_index).modify_flag,
		    p_pay_basis => g_assign(l_assign_index).pay_basis,
		    p_employee_id => g_assign(l_assign_index).employee_id,
		    p_primary_employee_flag => g_assign(l_assign_index).primary_employee_flag,
		    p_mode => p_mode);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		else
		  l_updated_record := FND_API.G_FALSE;
		end if;

		g_assign(l_assign_index).delete_flag := FND_API.G_FALSE;

	      end;
	      end if;

	      if not FND_API.to_Boolean(l_created_record) then
	      begin
                /* start bug 4153562 */
                -- check for the extract method and check whether parameter start date
                -- is greater than the overlap record start date.
		   IF NOT ((PSB_HR_POPULATE_DATA_PVT.g_extract_method = 'REFRESH') AND
		           (g_assign(l_assign_index).effective_start_date > p_effective_start_date) AND
		           (p_effective_end_date is null)) THEN
		/* end bug 4153562 */

		PSB_POSITION_ASSIGNMENTS_PVT.Insert_Row
		   (p_api_version => 1.0,
		    p_return_status => l_return_status,
		    p_msg_count => l_msg_count,
		    p_msg_data => l_msg_data,
		    p_rowid => l_rowid,
		    p_position_assignment_id => l_position_assignment_id,
		    p_data_extract_id => p_data_extract_id,
		    p_worksheet_id => p_worksheet_id,
		    p_position_id => p_position_id,
		    p_assignment_type => p_assignment_type,
		    p_attribute_id => p_attribute_id,
		    p_attribute_value_id => p_attribute_value_id,
		    p_attribute_value => p_attribute_value,
		    p_pay_element_id => p_pay_element_id,
		    p_pay_element_option_id => p_pay_element_option_id,
		    p_effective_start_date => p_effective_start_date,
		    p_effective_end_date => p_effective_end_date,
		    p_element_value_type => p_element_value_type,
		    p_element_value => p_element_value,
		    p_currency_code => p_currency_code,
		    p_pay_basis => g_assign(l_assign_index).pay_basis,
		    p_employee_id => p_employee_id,
		    p_primary_employee_flag => p_primary_employee_flag,
		    p_global_default_flag => p_global_default_flag,
		    p_assignment_default_rule_id => p_assignment_default_rule_id,
		    p_modify_flag => p_modify_flag,
		    p_mode => p_mode);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		else
		  l_created_record := FND_API.G_TRUE;
		end if;

		p_rowid := l_rowid;
		p_position_assignment_id := l_position_assignment_id;

                  /* start bug 4153562 */
		  END IF;
		  /* end bug 4153562 */

	      end;
	      end if;

	      if p_effective_end_date is not null then
	      begin

		if nvl(g_assign(l_assign_index).effective_end_date, (p_effective_end_date + 1)) > (p_effective_end_date + 1) then
		begin

		  if FND_API.to_Boolean(l_updated_record) then
		  begin

		    PSB_POSITION_ASSIGNMENTS_PVT.Insert_Row
		       (p_api_version => 1.0,
			p_return_status => l_return_status,
			p_msg_count => l_msg_count,
			p_msg_data => l_msg_data,
			p_rowid => l_rowid,
			p_position_assignment_id => l_position_assignment_id,
			p_data_extract_id => g_assign(l_assign_index).data_extract_id,
			p_worksheet_id => p_worksheet_id,
			p_position_id => g_assign(l_assign_index).position_id,
			p_assignment_type => g_assign(l_assign_index).assignment_type,
			p_attribute_id => g_assign(l_assign_index).attribute_id,
			p_attribute_value_id => g_assign(l_assign_index).attribute_value_id,
			p_attribute_value => g_assign(l_assign_index).attribute_value,
			p_pay_element_id => g_assign(l_assign_index).pay_element_id,
			p_pay_element_option_id => g_assign(l_assign_index).pay_element_option_id,
			p_effective_start_date => p_effective_end_date + 1,
			p_effective_end_date => g_assign(l_assign_index).effective_end_date,
			p_element_value_type => g_assign(l_assign_index).element_value_type,
			p_element_value => g_assign(l_assign_index).element_value,
			p_currency_code => g_assign(l_assign_index).currency_code,
			p_pay_basis => g_assign(l_assign_index).pay_basis,
			p_employee_id => g_assign(l_assign_index).employee_id,
			p_primary_employee_flag => g_assign(l_assign_index).primary_employee_flag,
			p_global_default_flag => g_assign(l_assign_index).global_default_flag,
			p_assignment_default_rule_id => g_assign(l_assign_index).assignment_default_rule_id,
			p_modify_flag => g_assign(l_assign_index).modify_flag,
			p_mode => p_mode);

		    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		      raise FND_API.G_EXC_ERROR;
		    end if;

		    p_rowid := l_rowid;
		    p_position_assignment_id := l_position_assignment_id;

		  end;
		  else
		  begin

		--++ pass input pay_element_option_id so that if input is salary, the updated row will
		--++ reflect the input value
		    PSB_POSITION_ASSIGNMENTS_PVT.Update_Row
		       (p_api_version => 1.0,
			p_return_status => l_return_status,
			p_msg_count => l_msg_count,
			p_msg_data => l_msg_data,
			p_position_assignment_id => g_assign(l_assign_index).position_assignment_id,
/* Bug No 2259505 Start */
-- Uncommented the first line and commented the second line
			p_pay_element_option_id => g_assign(l_assign_index).pay_element_option_id,
--                        p_pay_element_option_id => p_pay_element_option_id,
/* Bug No 2259505 End */
			p_attribute_value_id => g_assign(l_assign_index).attribute_value_id,
			p_attribute_value => g_assign(l_assign_index).attribute_value,
			p_effective_start_date => p_effective_end_date + 1,
			p_effective_end_date => g_assign(l_assign_index).effective_end_date,
			p_pay_element_id     => p_pay_element_id,
			p_element_value_type => g_assign(l_assign_index).element_value_type,
			p_element_value => g_assign(l_assign_index).element_value,
			p_pay_basis => g_assign(l_assign_index).pay_basis,
			p_employee_id => g_assign(l_assign_index).employee_id,
			p_primary_employee_flag => g_assign(l_assign_index).primary_employee_flag,
			p_global_default_flag => g_assign(l_assign_index).global_default_flag,
			p_assignment_default_rule_id => g_assign(l_assign_index).assignment_default_rule_id,
			p_modify_flag => g_assign(l_assign_index).modify_flag,
			p_mode => p_mode);

		    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		      raise FND_API.G_EXC_ERROR;
		    end if;

		    g_assign(l_assign_index).delete_flag := FND_API.G_FALSE;

		  end;
		  end if;

		end;
		end if;

	      end;
	      end if;

	    end;
	    --
	    --   (iii) overlap dates and overlap records is base and input is not base (= p_worksheet_id) and
	    --         there is NO worksheet overlap in the overlap records.
	    --
	    elsif ((g_assign(l_assign_index).worksheet_id is null) and (p_worksheet_id is not null) and
		   (not FND_API.to_Boolean(l_ws_overlap))) then
	    begin

	      if ((g_assign(l_assign_index).effective_start_date <= (p_effective_start_date - 1)) and
		 ((g_assign(l_assign_index).effective_end_date is null) or
		  (g_assign(l_assign_index).effective_end_date > (p_effective_start_date - 1)))) then
	      begin

		Modify_Assignment_WS
		      (p_return_status => l_return_status,
		       p_position_assignment_id => l_position_assignment_id,
		       p_data_extract_id => p_data_extract_id,
		       p_worksheet_id => p_worksheet_id,
		       p_position_id => p_position_id,
		       p_assignment_type => g_assign(l_assign_index).assignment_type,
		       p_attribute_id => g_assign(l_assign_index).attribute_id,
		       p_attribute_value_id => g_assign(l_assign_index).attribute_value_id,
		       p_attribute_value => g_assign(l_assign_index).attribute_value,
		       p_pay_element_id => g_assign(l_assign_index).pay_element_id,
		       p_pay_element_option_id => g_assign(l_assign_index).pay_element_option_id,
		       p_effective_start_date => g_assign(l_assign_index).effective_start_date,
		       p_effective_end_date => p_effective_start_date - 1,
		       p_element_value_type => g_assign(l_assign_index).element_value_type,
		       p_element_value => g_assign(l_assign_index).element_value,
		       p_currency_code => nvl(p_currency_code, g_assign(l_assign_index).currency_code),
		       p_pay_basis => g_assign(l_assign_index).pay_basis,
		       p_employee_id => g_assign(l_assign_index).employee_id,
		       p_primary_employee_flag => g_assign(l_assign_index).primary_employee_flag,
		       p_global_default_flag => g_assign(l_assign_index).global_default_flag,
		       p_assignment_default_rule_id => g_assign(l_assign_index).assignment_default_rule_id,
		       p_modify_flag => g_assign(l_assign_index).modify_flag,
		       p_rowid => l_rowid);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		end if;

		p_rowid := l_rowid;
		p_position_assignment_id := l_position_assignment_id;

	      end;
	      elsif ((g_assign(l_assign_index).effective_start_date > p_effective_start_date) and
		    ((p_effective_end_date is not null) and
		    ((g_assign(l_assign_index).effective_end_date is null) or
		     (g_assign(l_assign_index).effective_end_date > (p_effective_end_date + 1))))) then
	      begin

		Modify_Assignment_WS
		      (p_return_status => l_return_status,
		       p_position_assignment_id => l_position_assignment_id,
		       p_data_extract_id => p_data_extract_id,
		       p_worksheet_id => p_worksheet_id,
		       p_position_id => p_position_id,
		       p_assignment_type => g_assign(l_assign_index).assignment_type,
		       p_attribute_id => g_assign(l_assign_index).attribute_id,
		       p_attribute_value_id => g_assign(l_assign_index).attribute_value_id,
		       p_attribute_value => g_assign(l_assign_index).attribute_value,
		       p_pay_element_id => g_assign(l_assign_index).pay_element_id,
		       p_pay_element_option_id => g_assign(l_assign_index).pay_element_option_id,
		       p_effective_start_date => p_effective_end_date + 1,
		       p_effective_end_date => g_assign(l_assign_index).effective_end_date,
		       p_element_value_type => g_assign(l_assign_index).element_value_type,
		       p_element_value => g_assign(l_assign_index).element_value,
		       p_currency_code => nvl(p_currency_code, g_assign(l_assign_index).currency_code),
		       p_pay_basis => g_assign(l_assign_index).pay_basis,
		       p_employee_id => g_assign(l_assign_index).employee_id,
		       p_primary_employee_flag => g_assign(l_assign_index).primary_employee_flag,
		       p_global_default_flag => g_assign(l_assign_index).global_default_flag,
		       p_assignment_default_rule_id => g_assign(l_assign_index).assignment_default_rule_id,
		       p_modify_flag => g_assign(l_assign_index).modify_flag,
		       p_rowid => l_rowid);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		end if;

		p_rowid := l_rowid;
		p_position_assignment_id := l_position_assignment_id;

	      end;
	      end if;

	      if not FND_API.to_Boolean(l_created_record) then
	      begin

		PSB_POSITION_ASSIGNMENTS_PVT.Insert_Row
		   (p_api_version => 1.0,
		    p_return_status => l_return_status,
		    p_msg_count => l_msg_count,
		    p_msg_data => l_msg_data,
		    p_rowid => l_rowid,
		    p_position_assignment_id => l_position_assignment_id,
		    p_data_extract_id => p_data_extract_id,
		    p_worksheet_id => p_worksheet_id,
		    p_position_id => p_position_id,
		    p_assignment_type => p_assignment_type,
		    p_attribute_id => p_attribute_id,
		    p_attribute_value_id => p_attribute_value_id,
		    p_attribute_value => p_attribute_value,
		    p_pay_element_id => p_pay_element_id,
		    p_pay_element_option_id => p_pay_element_option_id,
		    p_effective_start_date => p_effective_start_date,
		    p_effective_end_date => p_effective_end_date,
		    p_element_value_type => p_element_value_type,
		    p_element_value => p_element_value,
		    p_currency_code => nvl(p_currency_code, g_assign(l_assign_index).currency_code),
		    p_pay_basis => g_assign(l_assign_index).pay_basis,
		    p_employee_id => p_employee_id,
		    p_primary_employee_flag => p_primary_employee_flag,
		    p_global_default_flag => p_global_default_flag,
		    p_assignment_default_rule_id => p_assignment_default_rule_id,
		    p_modify_flag => p_modify_flag,
		    p_mode => p_mode);

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  raise FND_API.G_EXC_ERROR;
		else
		  l_created_record := FND_API.G_TRUE;
		end if;

		p_rowid := l_rowid;
		p_position_assignment_id := l_position_assignment_id;

	      end;
	      end if;

	      if p_effective_end_date is not null then
	      begin

		if nvl(g_assign(l_assign_index).effective_end_date, (p_effective_end_date + 1)) > (p_effective_end_date + 1) then
		begin

		  Modify_Assignment_WS
			(p_return_status => l_return_status,
			 p_position_assignment_id => l_position_assignment_id,
			 p_data_extract_id => g_assign(l_assign_index).data_extract_id,
			 p_worksheet_id => p_worksheet_id,
			 p_position_id => g_assign(l_assign_index).position_id,
			 p_assignment_type => g_assign(l_assign_index).assignment_type,
			 p_attribute_id => g_assign(l_assign_index).attribute_id,
			 p_attribute_value_id => g_assign(l_assign_index).attribute_value_id,
			 p_attribute_value => g_assign(l_assign_index).attribute_value,
			 p_pay_element_id => g_assign(l_assign_index).pay_element_id,
			 p_pay_element_option_id => g_assign(l_assign_index).pay_element_option_id,
			 p_effective_start_date => p_effective_end_date + 1,
			 p_effective_end_date => g_assign(l_assign_index).effective_end_date,
			 p_element_value_type => g_assign(l_assign_index).element_value_type,
			 p_element_value => g_assign(l_assign_index).element_value,
			 p_currency_code => g_assign(l_assign_index).currency_code,
			 p_pay_basis => g_assign(l_assign_index).pay_basis,
			 p_employee_id => g_assign(l_assign_index).employee_id,
			 p_primary_employee_flag => g_assign(l_assign_index).primary_employee_flag,
			 p_global_default_flag => g_assign(l_assign_index).global_default_flag,
			 p_assignment_default_rule_id => g_assign(l_assign_index).assignment_default_rule_id,
			 p_modify_flag => g_assign(l_assign_index).modify_flag,
			 p_rowid => l_rowid);

		  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		    raise FND_API.G_EXC_ERROR;
		  end if;

		  p_rowid := l_rowid;
		  p_position_assignment_id := l_position_assignment_id;

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

    end;
    end if;

    --+ finally, delete all overlap records with delete_flag set only if WS id  is not null
    --  ** Deleting only worksheet specific records is a problem
    --  (i)  This could result in created or updated records which overlaps the original overlaps
    --       that were not deleted for base assignments.
    --       i.e.,  input record: 01-jun-99 -- 01-jul-00
    --              overlap       01-jul-97 -- 29-jun-99
    --                            30-jun-99 -- 01-jul-00 ** this record is not processed because it did not
    --                                                      pass the date test
    --
    --              Result:       01-jul-97 -- 31-may-99  updated record
    --                            01-jul-99 -- 01-jul-00  new record
    --                            30-jun-99 -- 01-jul-00  original overlap not deleted
    --
    --  (ii) This logic, in combination with ignoring overlaps which do not meet the input start/end dates
    --       will cause in deleting any WS specific record but not process the input record. This will
    --       result in only the original base assignments.
    --
    for l_assign_index in 1..g_num_assign loop

      if (
            /* start bug 4153562 */
            -- we need to delete in case we have any overlap records
            (PSB_HR_POPULATE_DATA_PVT.g_extract_method = 'REFRESH') OR
            /* end bug 4153562 */
          (FND_API.to_Boolean(g_assign(l_assign_index).delete_flag)) and (g_assign(l_assign_index).worksheet_id is not null)
         ) then
      begin

        /* Start bug 4153562 */
        -- if the method is refresh and the overlap start date
        -- is greater than the input start date, then delete the overlap record
        -- as it again created the overlap record. This is only in case of refresh
        -- for worksheet specific records, it is bound to create the records, this
        -- logic is not being used.

	IF (PSB_HR_POPULATE_DATA_PVT.g_extract_method = 'REFRESH') THEN
          IF ( g_assign(l_assign_index).effective_start_date > p_effective_start_date ) THEN

             	PSB_POSITION_ASSIGNMENTS_PVT.Delete_Row
	       (p_api_version => 1.0,
	    	p_return_status => l_return_status,
	    	p_msg_count => l_msg_count,
	    	p_msg_data => l_msg_data,
	    	p_position_assignment_id => g_assign(l_assign_index).position_assignment_id);

          END IF;
        ELSE
        /* End bug 4153562 */

	PSB_POSITION_ASSIGNMENTS_PVT.Delete_Row
	   (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
	    p_position_assignment_id => g_assign(l_assign_index).position_assignment_id);

         /* Start Bug 4153562 */
	 END IF;
	 /* End Bug 4153562 */

	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

    end loop;

  end;
  end if;

  -- adding this for position control integration so that positions are automatically added to
  -- position sets when attribute assignments are changed inside the worksheet

  if p_rowid is not null then
    begin
      -- bug #5450510
      -- added parameter p_data_extract_id to the following api
      PSB_BUDGET_POSITION_PVT.Add_Position_To_Position_Sets
      (p_api_version => 1.0,
       p_return_status => l_return_status,
       p_msg_count => l_msg_count,
       p_msg_data => l_msg_data,
       p_position_id => p_position_id,
       p_data_extract_id => p_data_extract_id);

    end;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

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

    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
			       l_api_name);
    end if;

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			       p_data  => p_msg_data);

END Modify_Assignment;

/*----------------------------------------------------------------*/

PROCEDURE Modify_Assignment_WS
( p_return_status               OUT  NOCOPY     VARCHAR2,
  p_position_assignment_id      IN OUT  NOCOPY  NUMBER,
  p_data_extract_id             IN      NUMBER,
  p_worksheet_id                IN      NUMBER,
  p_position_id                 IN      NUMBER,
  p_assignment_type             IN      VARCHAR2,
  p_attribute_id                IN      NUMBER,
  p_attribute_value_id          IN      NUMBER,
  p_attribute_value             IN      VARCHAR2,
  p_pay_element_id              IN      NUMBER,
  p_pay_element_option_id       IN      NUMBER,
  p_effective_start_date        IN      DATE,
  p_effective_end_date          IN      DATE,
  p_element_value_type          IN      VARCHAR2,
  p_element_value               IN      NUMBER,
  p_currency_code               IN      VARCHAR2,
  p_pay_basis                   IN      VARCHAR2,
  p_employee_id                 IN      NUMBER,
  p_primary_employee_flag       IN      VARCHAR2,
  p_global_default_flag         IN      VARCHAR2,
  p_assignment_default_rule_id  IN      NUMBER,
  p_modify_flag                 IN      VARCHAR2,
  p_rowid                       IN OUT  NOCOPY  VARCHAR2
) IS

  cursor c_Overlap is
    select position_assignment_id
      from PSB_POSITION_ASSIGNMENTS
     where worksheet_id = p_worksheet_id
       and (((p_assignment_type = 'ATTRIBUTE')
	 and (attribute_id = p_attribute_id))
	 or ((p_assignment_type = 'EMPLOYEE')
	 and (employee_id = p_employee_id))
	 or ((p_assignment_type = 'ELEMENT')
	 and (pay_element_id = p_pay_element_id)
	 and ((p_currency_code is null) or (currency_code = p_currency_code))))
       and ((((p_effective_end_date is not null)
	 and ((effective_start_date <= p_effective_end_date)
	  and (effective_end_date is null))
	  or ((effective_start_date between p_effective_start_date and p_effective_end_date)
	   or (effective_end_date between p_effective_start_date and p_effective_end_date)
	  or ((effective_start_date < p_effective_start_date)
	  and (effective_end_date > p_effective_end_date)))))
	  or ((p_effective_end_date is null)
	  and (nvl(effective_end_date, p_effective_start_date) >= p_effective_start_date)))
       and position_id = p_position_id;

  cursor c_Salary is
    select salary_flag
      from PSB_PAY_ELEMENTS
     where pay_element_id = p_pay_element_id;

  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);

  l_salary_flag             VARCHAR2(1);
  l_salary_failed           VARCHAR2(1);

  l_position_assignment_id  NUMBER;
  l_rowid                   VARCHAR2(100);
  l_assignment_found        VARCHAR2(1) := FND_API.G_FALSE;

BEGIN

  for c_Overlap_Rec in c_Overlap loop
    l_assignment_found := FND_API.G_TRUE;
  end loop;

  if not FND_API.to_Boolean(l_assignment_found) then
    -- removed salary validation since we now process salary as a set of all salary elements
    -- and not individually as the input salary(pay element id). The main api modify_assignments
    -- should process all the overlaps records - deleting all existing overlaps

    begin

      PSB_POSITION_ASSIGNMENTS_PVT.Insert_Row
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_rowid => l_rowid,
	  p_position_assignment_id => l_position_assignment_id,
	  p_data_extract_id => p_data_extract_id,
	  p_worksheet_id => p_worksheet_id,
	  p_position_id => p_position_id,
	  p_assignment_type => p_assignment_type,
	  p_attribute_id => p_attribute_id,
	  p_attribute_value_id => p_attribute_value_id,
	  p_attribute_value => p_attribute_value,
	  p_pay_element_id => p_pay_element_id,
	  p_pay_element_option_id => p_pay_element_option_id,
	  p_effective_start_date => p_effective_start_date,
	  p_effective_end_date => p_effective_end_date,
	  p_element_value_type => p_element_value_type,
	  p_element_value => p_element_value,
	  p_currency_code => p_currency_code,
	  p_pay_basis => p_pay_basis,
	  p_employee_id => p_employee_id,
	  p_primary_employee_flag => p_primary_employee_flag,
	  p_global_default_flag => p_global_default_flag,
	  p_assignment_default_rule_id => p_assignment_default_rule_id,
	  p_modify_flag => p_modify_flag);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	raise FND_API.G_EXC_ERROR;
      end if;

      p_rowid := l_rowid;
      p_position_assignment_id := l_position_assignment_id;


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

END Modify_Assignment_WS;

/* ------------------------------------------------------------------------- */

PROCEDURE Create_Default_Assignments
( p_api_version          IN   NUMBER,
  p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status        OUT  NOCOPY  VARCHAR2,
  p_msg_count            OUT  NOCOPY  NUMBER,
  p_msg_data             OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_data_extract_id      IN   NUMBER,
  p_position_id          IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_start_date  IN   DATE := FND_API.G_MISS_DATE,
  p_position_end_date    IN   DATE := FND_API.G_MISS_DATE,
  p_ruleset_id           IN   NUMBER
)
IS
  --
  l_api_name         CONSTANT VARCHAR2(30)   := 'Create_Default_Assignments';
  l_api_version      CONSTANT NUMBER         := 1.0;
  --
  l_return_status             VARCHAR2(1);
  l_position_start_date       DATE;
  l_position_end_date         DATE;
  l_position_id_tbl           Number_tbl_type;
  l_vacant_position_flag_tbl  Character_tbl_type;
  l_effective_start_date_tbl  Date_tbl_type;
  l_effective_end_date_tbl    Date_tbl_type;
  --
  CURSOR l_positions_csr IS
  SELECT position_id,
	 vacant_position_flag,
	 effective_start_date,
	 effective_end_date
  FROM   psb_positions
  WHERE  data_extract_id = p_data_extract_id ;
  --
  CURSOR c_Position IS
  SELECT effective_start_date,
	 effective_end_date
  FROM   psb_positions
  WHERE  position_id = p_position_id ;
  --
BEGIN

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  -- Check if default rules to be applied for all positions or not.
  IF p_position_id = FND_API.G_MISS_NUM THEN

    -- Apply default rules to the all positions.
    OPEN l_positions_csr ;
    LOOP

      l_position_id_tbl.DELETE ;
      FETCH l_positions_csr BULK COLLECT INTO l_position_id_tbl          ,
                                              l_vacant_position_flag_tbl ,
                                              l_effective_start_date_tbl ,
                                              l_effective_end_date_tbl
                                              LIMIT 500 ;

      IF l_position_id_tbl.COUNT = 0 THEN
        EXIT;
      END IF;

      -- Loop to process positions in the current bulk fetch.
      FOR i IN 1..l_position_id_tbl.COUNT
      LOOP

        /* For Bug 4644241 --> Reverting Back to the old fix
           This will maintain the old functionality. Added Ruleset ID Check */

        IF (  p_ruleset_id IS NOT NULL ) OR
           ( l_vacant_position_flag_tbl(i) = 'Y' AND  p_ruleset_id IS NULL) THEN
        -- added the extra parameter p_ruleset_id

          Create_Assignment_Position
    	  ( p_return_status       => l_return_status,
	    p_worksheet_id        => p_worksheet_id,
            p_data_extract_id     => p_data_extract_id,
	    p_position_id         => l_position_id_tbl(i),
	    p_position_start_date => l_effective_start_date_tbl(i),
	    p_position_end_date   => l_effective_end_date_tbl(i),
            p_ruleset_id          => p_ruleset_id
          ) ;

          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF ;

          -- 1308558. added the extra parameter p_ruleset_id
	  Create_Distribution_Position
	  ( p_return_status       => l_return_status,
	    p_worksheet_id        => p_worksheet_id,
	    p_data_extract_id     => p_data_extract_id,
	    p_position_id         => l_position_id_tbl(i),
	    p_position_start_date => l_effective_start_date_tbl(i),
	    p_position_end_date   => l_effective_end_date_tbl(i),
            p_ruleset_id          => p_ruleset_id
          );

	  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    RAISE FND_API.G_EXC_ERROR;
	  END IF ;

      /* For Bug 4644241 --> Reverting Back to the old fix
         This will maintain the old functionality. Added Ruleset ID Check */

        ELSIF ( l_vacant_position_flag_tbl(i) IS NULL OR
                l_vacant_position_flag_tbl(i) = 'N' ) AND ( p_ruleset_id IS NULL)
        THEN

          Create_Element_Assignment
	  ( p_return_status       => l_return_status,
	    p_worksheet_id        => p_worksheet_id,
	    p_data_extract_id     => p_data_extract_id,
	    p_position_id         => l_position_id_tbl(i),
	    p_position_start_date => l_effective_start_date_tbl(i),
	    p_position_end_date   => l_effective_end_date_tbl(i)
          ) ;
          --
	  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    RAISE FND_API.G_EXC_ERROR;
	  END IF ;

        END IF ;

       /* For Bug 4644241 --> Reverting Back to the old fix
         This will maintain the old functionality. Reimplementing the apply_global_default
         API. */

       IF (p_ruleset_id IS NULL) THEN
         Apply_Global_Default
        ( p_return_status       => l_return_status,
  	  p_worksheet_id        => p_worksheet_id,
  	  p_data_extract_id     => p_data_extract_id,
	  p_position_id         => l_position_id_tbl(i),
	  p_position_start_date => l_effective_start_date_tbl(i),
	  p_position_end_date   => l_effective_end_date_tbl(i)
        );
        --
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;


      END LOOP ;
      -- End loop to process positions in the current bulk fetch.

      -- Commit all processed positions to keep memory consumption small.
      COMMIT ;

    END LOOP ;
    -- End applying default rules to the all positions.

  ELSE

    -- Apply default rules to the given position only.
    if ((p_position_start_date = FND_API.G_MISS_DATE) or
	(p_position_end_date = FND_API.G_MISS_DATE))
    then
      --
      for c_Position_Rec in c_Position loop
	l_position_start_date := c_Position_Rec.effective_start_date;
	l_position_end_date := c_Position_Rec.effective_end_date;
      end loop;
      --
    end if;

    if p_position_start_date <> FND_API.G_MISS_DATE then
      l_position_start_date := p_position_start_date;
    end if;

    if p_position_end_date <> FND_API.G_MISS_DATE then
      l_position_end_date := p_position_end_date;
    end if;

    -- 1308558. added the extra parameter p_ruleset_id
    Create_Assignment_Position
	  (p_return_status => l_return_status,
	   p_worksheet_id => p_worksheet_id,
	   p_data_extract_id => p_data_extract_id,
	   p_position_id => p_position_id,
	   p_position_start_date => l_position_start_date,
	   p_position_end_date => l_position_end_date,
           p_ruleset_id        => p_ruleset_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    -- 1308558. added the extra parameter p_ruleset_id
    Create_Distribution_Position
	  (p_return_status => l_return_status,
	   p_worksheet_id => p_worksheet_id,
	   p_data_extract_id => p_data_extract_id,
	   p_position_id => p_position_id,
	   p_position_start_date => l_position_start_date,
	   p_position_end_date => l_position_end_date,
           p_ruleset_id        => p_ruleset_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

    /* For Bug 4644241 --> Reverting Back to the old fix
     This will maintain the old functionality. Reimplementing the apply_global_default
     API. */

    IF (p_ruleset_id IS NULL) THEN
      Apply_Global_Default
	 (p_return_status => l_return_status,
	  p_worksheet_id => p_worksheet_id,
	  p_data_extract_id => p_data_extract_id,
	  p_position_id => p_position_id,
	  p_position_start_date => l_position_start_date,
	  p_position_end_date => l_position_end_date);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
      end if;
    END IF;

    -- End applying default rules to the given position only.

  END IF ;
  -- End checkng if default rules to be applied for all positions.

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard check of p_commit.
  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);
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
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     then
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Create_Default_Assignments;

/* ------------------------------------------------------------------------- */

-- 1308558 Mass Position Assignment Rules Enhancement
-- added the extra parameter p_ruleset_id for passing the
-- id for the default ruleset

PROCEDURE Create_Assignment_Position
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER,
  p_data_extract_id      IN   NUMBER,
  p_position_id          IN   NUMBER,
  p_position_start_date  IN   DATE,
  p_position_end_date    IN   DATE,
  p_ruleset_id           IN   NUMBER
) IS

  l_worksheet_id         NUMBER;
  l_posasgn_id           NUMBER;
  l_rowid                VARCHAR2(100);

  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);

  l_return_status        VARCHAR2(1);

  /* For Bug 4644241 --> Reverting Back to the old fix
     This will maintain the old functionality */

 /*Bug:5940448:removed the table PSB_BUDGET_POSITIONS from the below
   query and the validation is performed just before calling the
   Apply_Position_Default_Rules api */

  CURSOR c_Assignments is
    SELECT a.default_rule_id,
	   b.priority,
	   b.global_default_flag,
	   c.account_position_set_id, --bug:5940448
	   a.assignment_type,
	   a.attribute_id,
	   a.attribute_value_id,
	   a.attribute_value,
	   a.pay_element_id,
	   a.pay_element_option_id,
	   a.pay_basis,
	   a.element_value_type,
	   a.element_value,
	   a.currency_code
      FROM PSB_DEFAULT_ASSIGNMENTS a,
	   PSB_DEFAULTS b,
	   PSB_SET_RELATIONS c
     WHERE a.default_rule_id = b.default_rule_id
     AND b.priority is not null
     AND b.default_rule_id = c.default_rule_id
     AND b.data_extract_id = p_data_extract_id
     order by b.priority;


  /* 1308558 In the following cursor added the join for
     selecting only the assignments for a given default ruleset */

  -- Bug 4237598 Modified the following cursor
  -- so that it will pick rule details for global
  -- and non-global default rules

  -- Bug 5040737 used order by 2 clause in the following cursor

 /*Bug:5940448:removed the table PSB_BUDGET_POSITIONS from the below
   query and the validation is performed just before calling the
   Apply_Position_Default_Rules api */

  CURSOR c_Assignment_Ruleset IS
    SELECT a.default_rule_id,
	   f.priority priority,
	   b.global_default_flag,
           b.overwrite,
	   c.account_position_set_id, --bug:5940448
	   a.assignment_type,
	   a.attribute_id,
	   a.attribute_value_id,
	   a.attribute_value,
	   a.pay_element_id,
	   a.pay_element_option_id,
	   a.pay_basis,
	   a.element_value_type,
	   a.element_value,
	   a.currency_code
      FROM psb_default_assignments a,
	   psb_defaults b,
	   psb_set_relations c,
           psb_entity_set e,
           psb_entity_assignment f
     WHERE a.default_rule_id = b.default_rule_id
    -- AND f.priority IS NOT NULL
       AND b.data_extract_id = p_data_extract_id --bug:5940448
       AND b.default_rule_id = c.default_rule_id
       AND e.entity_set_id   = f.entity_set_id
       AND f.entity_id       = b.default_rule_id
       AND e.data_extract_id = p_data_extract_id
       AND e.entity_type     = 'DEFAULT_RULE'
       AND e.entity_set_id   = p_ruleset_id
     UNION
    SELECT a.default_rule_id,
           d.priority priority,
           b.global_default_flag,
           b.overwrite,
	   null account_position_set_id, --bug:5940448
	   a.assignment_type,
	   a.attribute_id,
	   a.attribute_value_id,
	   a.attribute_value,
	   a.pay_element_id,
	   a.pay_element_option_id,
	   a.pay_basis,
	   a.element_value_type,
	   a.element_value,
	   a.currency_code
      FROM psb_default_assignments a,
	   psb_defaults b,
           psb_entity_set c,
           psb_entity_assignment d
     WHERE a.default_rule_id     = b.default_rule_id
       AND b.global_default_flag = 'Y'
       AND b.data_extract_id     = p_data_extract_id
       AND c.entity_set_id       = d.entity_set_id
       AND b.default_rule_id     = d.entity_id
       AND c.data_extract_id     = p_data_extract_id
       AND c.entity_type         = 'DEFAULT_RULE'
       AND c.entity_set_id       = p_ruleset_id
       ORDER BY 2;

BEGIN


  if p_worksheet_id = FND_API.G_MISS_NUM then
    l_worksheet_id := null;
  else
    l_worksheet_id := p_worksheet_id;
  end if;

  -- 1308558.Mass Position Assignment Rules

  IF p_ruleset_id IS NULL THEN

  FOR c_Assignments_Rec in c_Assignments LOOP

        /* For Bug 4644241 --> Reverting Back to the old fix
           This will maintain the old functionality */

  /*Bug:5940448:start*/
   /*Below for loop is to check whether the position is part of the psb_budget_positions.
     ie., part of the position set*/

    for l_pos_rec in (select 1 from psb_budget_positions
                       where account_position_set_id = c_Assignments_Rec.account_position_set_id
	                 and data_extract_id = p_data_extract_id
        		 and position_id = p_position_id) loop
  /*Bug:5940448:end*/

        Apply_Position_Default_Rules
 	  (p_api_version => 1.0,
	   x_return_status => l_return_status,
	   x_msg_count => l_msg_count,
	   x_msg_data => l_msg_data,
	   p_position_assignment_id => l_posasgn_id,
	   p_data_extract_id => p_data_extract_id,
	   p_position_id => p_position_id,
	   p_assignment_type => c_Assignments_Rec.assignment_type,
	   p_attribute_id => c_Assignments_Rec.attribute_id,
	   p_attribute_value_id => c_Assignments_Rec.attribute_value_id,
	   p_attribute_value => c_Assignments_Rec.attribute_value,
	   p_pay_element_id => c_Assignments_Rec.pay_element_id,
	   p_pay_element_option_id => c_Assignments_Rec.pay_element_option_id,
           p_effective_start_date => p_position_start_date,
	   p_effective_end_date => p_position_end_date,
	   p_element_value_type => c_Assignments_Rec.element_value_type,
	   p_element_value => c_Assignments_Rec.element_value,
	   p_currency_code => c_Assignments_Rec.currency_code,
	   p_pay_basis => c_Assignments_Rec.pay_basis,
	   p_employee_id => null,
	   p_primary_employee_flag => null,
	   p_global_default_flag => c_Assignments_Rec.global_default_flag,
	   p_assignment_default_rule_id => c_Assignments_Rec.default_rule_id,
	   p_modify_flag => 'Y',
           p_worksheet_id => null);

       IF l_return_status  <> fnd_api.g_ret_sts_success THEN
         raise FND_API.G_EXC_ERROR;
       END IF;

  /*Bug:5940448:start*/
    end loop;
  /*Bug:5940448:end*/

  END LOOP;

  ELSE

    FOR c_Assignments_Rec in c_Assignment_Ruleset
    LOOP

  /*Bug:5940448:start*/
   /*Below for loop make sure that position default rule will get executed
     for the position only if the position is part of the position set of
     the default rule or the default rule is a global rule */

    for l_pos_rec in (select 1 from psb_budget_positions
                       where account_position_set_id = c_Assignments_Rec.account_position_set_id
	                 and data_extract_id = p_data_extract_id
        		 and position_id = p_position_id
        	       union
                       select 1
		         from dual
  		        where c_Assignments_Rec.global_default_flag = 'Y'
		      ) loop
  /*Bug:5940448:end*/

    Apply_Position_Default_Rules
	  (p_api_version => 1.0,
	   x_return_status => l_return_status,
	   x_msg_count => l_msg_count,
	   x_msg_data => l_msg_data,
	   p_position_assignment_id => l_posasgn_id,
	   p_data_extract_id => p_data_extract_id,
	   p_position_id => p_position_id,
	   p_assignment_type => c_Assignments_Rec.assignment_type,
	   p_attribute_id => c_Assignments_Rec.attribute_id,
	   p_attribute_value_id => c_Assignments_Rec.attribute_value_id,
	   p_attribute_value => c_Assignments_Rec.attribute_value,
	   p_pay_element_id => c_Assignments_Rec.pay_element_id,
	   p_pay_element_option_id => c_Assignments_Rec.pay_element_option_id,
           p_effective_start_date => p_position_start_date,
	   p_effective_end_date => p_position_end_date,
	   p_element_value_type => c_Assignments_Rec.element_value_type,
	   p_element_value => c_Assignments_Rec.element_value,
	   p_currency_code => c_Assignments_Rec.currency_code,
	   p_pay_basis => c_Assignments_Rec.pay_basis,
	   p_employee_id => null,
	   p_primary_employee_flag => null,
	   p_global_default_flag => c_Assignments_Rec.global_default_flag,
	   p_assignment_default_rule_id => c_Assignments_Rec.default_rule_id,
	   p_modify_flag => c_Assignments_Rec.overwrite,
           p_worksheet_id=> null);

  /*Bug:5940448:start*/
    end loop;
  /*Bug:5940448:end*/

    END LOOP;

    /* Moved the check inside the for loop
       as a part of bug fix 4644241 */

    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
    end if;

  END IF;


   -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Create_Assignment_Position;

/* ------------------------------------------------------------------------- */

-- 1308558 Mass Position Assignment Rules Enhancement
-- added the extra parameter p_ruleset_id for passing the
-- id for the default ruleset

PROCEDURE Create_Distribution_Position
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER,
  p_data_extract_id      IN   NUMBER,
  p_position_id          IN   NUMBER,
  p_position_start_date  IN   DATE,
  p_position_end_date    IN   DATE,
  p_ruleset_id           IN   NUMBER
) IS

  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);

  l_default_rule_id      NUMBER;
  l_priority             NUMBER;
  l_global_default_flag  VARCHAR2(1);

  l_local_dist_exists    VARCHAR2(1) := FND_API.G_FALSE;
  l_global_dist_exists   VARCHAR2(1) := FND_API.G_FALSE;

  l_distribution_id      NUMBER;
  l_rowid                VARCHAR2(100);

  l_return_status        VARCHAR2(1);
  l_overwrite_flag       VARCHAR2(1);


  /* For Bug 4644241 --> Reverting Back to the old fix
   This will maintain the old functionality */
  l_exists		     VARCHAR2(30);


  /* For Bug 4644241 --> Reverting Back to the old fix
   This will maintain the old functionality. The old cursor c_priority
   is retained */

  CURSOR c_Priority IS
    SELECT a.default_rule_id,
	   a.priority,
	   a.global_default_flag
      FROM PSB_DEFAULTS a,
	   PSB_SET_RELATIONS b,
	   PSB_BUDGET_POSITIONS c
     WHERE EXISTS
	  (SELECT 1
	     FROM PSB_DEFAULT_ACCOUNT_DISTRS d
	    WHERE d.default_rule_id = a.default_rule_id)
       AND a.priority is not null
       AND a.default_rule_id = b.default_rule_id
       AND b.account_position_set_id = c.account_position_set_id
       AND c.data_extract_id = p_data_extract_id
       AND c.position_id = p_position_id
       ORDER BY a.priority;



  -- 1308558 modified the following cursor to select only
  -- the details for a given default ruleset

  -- Bug 4237598 Modified the following cursor
  -- so that it will pick rule details for global
  -- and non-global default rules

  -- Bug 5040737 used order by 2 clause in the following cursor
  CURSOR c_Priority_ruleset IS
    SELECT a.default_rule_id,
	   f.priority priority,
	   a.global_default_flag,
           a.overwrite
      FROM psb_defaults a,
	   psb_set_relations b,
	   psb_budget_positions c,
           psb_entity_set e,
           psb_entity_assignment f
     WHERE EXISTS  -- Bug 4226623 added the exists clause
           (SELECT 1
	      FROM PSB_DEFAULT_ACCOUNT_DISTRS d
	     WHERE d.default_rule_id = a.default_rule_id)
    -- AND f.priority is not null
       AND a.default_rule_id = b.default_rule_id
       AND b.account_position_set_id = c.account_position_set_id
       AND c.data_extract_id = p_data_extract_id
       AND c.position_id     = p_position_id
       AND e.entity_set_id   = f.entity_set_id
       AND f.entity_id       = a.default_rule_id
       AND e.data_extract_id = p_data_extract_id
       AND e.entity_type     = 'DEFAULT_RULE'
       AND e.entity_set_id   = p_ruleset_id
  UNION
    SELECT a.default_rule_id,
	   c.priority priority,
           a.global_default_flag,
           a.overwrite
      FROM psb_defaults a,
           psb_entity_set b,
           psb_entity_assignment c
     WHERE EXISTS (SELECT 1
	      FROM PSB_DEFAULT_ACCOUNT_DISTRS d
	     WHERE d.default_rule_id = a.default_rule_id)
       AND a.global_default_flag = 'Y'
       AND a.data_extract_id     = p_data_extract_id
       AND b.entity_set_id       = c.entity_set_id
       AND a.default_rule_id     = c.entity_id
       AND b.data_extract_id     = p_data_extract_id
       AND b.entity_type         = 'DEFAULT_RULE'
       AND b.entity_set_id       = p_ruleset_id
       ORDER BY 2;

  /* For Bug 4644241 --> Reverting Back to the old fix
   This will maintain the old functionality */
  TYPE l_global_dist_csr_type IS REF CURSOR;
  l_global_dist_csr l_global_dist_csr_type;


  cursor c_Dist is
    select chart_of_accounts_id,
	   code_combination_id,
	   distribution_percent
      from PSB_DEFAULT_ACCOUNT_DISTRS
     where default_rule_id = l_default_rule_id;

  CURSOR l_distribution_id_csr
    IS
    SELECT *
    FROM PSB_POSITION_PAY_DISTRIBUTIONS
    WHERE (((p_position_end_date IS NOT NULL)
	   AND (((effective_start_date <= p_position_end_date)
	   AND (effective_end_date IS NULL))
	   OR ((effective_start_date BETWEEN p_position_start_date AND p_position_end_date)
	   OR (effective_end_date BETWEEN p_position_start_date AND p_position_end_date)
	   OR ((effective_start_date < p_position_start_date)
	   AND (effective_end_date > p_position_end_date)))))
	   OR ((p_position_end_date IS NULL)
	   AND (NVL(effective_end_date, p_position_start_date) >= p_position_start_date)))
           AND data_extract_id = p_data_extract_id
           AND position_id     = p_position_id
           /* Bug 4545909 Start */
           AND ((worksheet_id IS NULL AND NOT EXISTS
                (SELECT 1 FROM psb_position_pay_distributions
                 WHERE worksheet_id = p_worksheet_id
                   AND position_id  = p_position_id))
                    OR worksheet_id = p_worksheet_id
                    OR(worksheet_id IS NULL AND p_worksheet_id IS NULL));
           /* Bug 4545909 End */

BEGIN

  IF p_ruleset_id is NULL THEN

    FOR c_Priority_Rec in c_Priority LOOP

      IF c_Priority_Rec.priority <> nvl(l_priority, FND_API.G_MISS_NUM) THEN
        l_default_rule_id := c_Priority_Rec.default_rule_id;
        l_priority := c_Priority_Rec.priority;
        l_global_default_flag := c_Priority_Rec.global_default_flag;
      END IF;

    l_local_dist_exists := FND_API.G_TRUE;

    END LOOP;

   /* For Bug 4644241 --> Reverting Back to the old fix
      This will maintain the old functionality */
    OPEN l_global_dist_csr FOR
     SELECT 'Exists'
      FROM dual
     WHERE EXISTS
	  (SELECT 1
	     FROM PSB_DEFAULT_ACCOUNT_DISTRS a,
		  PSB_DEFAULTS b
            WHERE a.default_rule_id     = b.default_rule_id
	      AND b.global_default_flag = 'Y'
	      AND b.data_extract_id     = p_data_extract_id);
    FETCH l_global_dist_csr INTO l_exists;
    CLOSE l_global_dist_csr;

    IF l_exists IS NOT NULL THEN
      l_global_dist_exists := FND_API.G_TRUE;
    END IF;

    IF ((FND_API.to_Boolean(l_local_dist_exists)) OR
      (FND_API.to_Boolean(l_global_dist_exists))) THEN
    BEGIN

    PSB_POSITION_PAY_DISTR_PVT.Delete_Distributions_Position
       (p_api_version => 1.0,
	p_return_status => l_return_status,
	p_msg_count => l_msg_count,
	p_msg_data => l_msg_data,
	p_position_id => p_position_id);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    END IF;

    END;
    END IF;

    /* For Bug 4644241 --> Reverting Back to the old fix
       This will maintain the old functionality */

    IF NOT FND_API.to_Boolean(l_global_dist_exists) THEN

      FOR c_Dist_Rec in c_Dist LOOP

        PSB_POSITION_PAY_DISTR_PVT.Modify_Distribution_WS
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_worksheet_id => p_worksheet_id,
	  p_distribution_id => l_distribution_id,
	  p_position_id => p_position_id,
	  p_data_extract_id => p_data_extract_id,
	  p_effective_start_date => p_position_start_date,
	  p_effective_end_date => p_position_end_date,
	  p_chart_of_accounts_id => c_Dist_Rec.chart_of_accounts_id,
	  p_code_combination_id => c_Dist_Rec.code_combination_id,
	  p_distribution_percent => c_Dist_Rec.distribution_percent,
	  p_global_default_flag => l_global_default_flag,
	  p_distribution_default_rule_id => l_default_rule_id,
	  p_rowid => l_rowid);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  raise FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
    END IF;

  ELSE -- gets executed when p_ruleset_id is not null

    FOR c_Priority_Rec in c_Priority_ruleset LOOP

   -- IF c_Priority_Rec.priority <> nvl(l_priority, FND_API.G_MISS_NUM) THEN
      l_default_rule_id     := c_Priority_Rec.default_rule_id;
      l_priority            := c_Priority_Rec.priority;
      l_global_default_flag := c_Priority_Rec.global_default_flag;
   -- END IF;

    IF NVL(c_priority_rec.global_default_flag,'N') = 'N' THEN
      l_local_dist_exists := FND_API.G_TRUE;
    END IF;

    l_overwrite_flag    := c_priority_rec.overwrite;

    IF l_overwrite_flag IS NULL THEN
      l_overwrite_flag    := 'N';
    END IF;

    /* For Bug 4644241 --> Reverting Back to the old fix
       This will maintain the old functionality */

    OPEN l_global_dist_csr FOR
      SELECT 'Exists'
      FROM dual
     WHERE EXISTS
	  (SELECT 1
	     FROM PSB_DEFAULT_ACCOUNT_DISTRS a,
		  PSB_DEFAULTS b
            WHERE a.default_rule_id     = b.default_rule_id
	      AND b.global_default_flag = 'Y'
	      AND b.data_extract_id     = p_data_extract_id
              AND a.default_rule_id     = l_default_rule_id
             );
    FETCH l_global_dist_csr INTO l_exists;
    CLOSE l_global_dist_csr;


    IF l_exists IS NOT NULL THEN
      l_global_dist_exists := FND_API.G_TRUE;
    END IF;

    IF l_overwrite_flag <> 'N' THEN

      IF ((FND_API.to_Boolean(l_local_dist_exists)) OR
        (FND_API.to_Boolean(l_global_dist_exists))) THEN
      BEGIN

      PSB_POSITION_PAY_DISTR_PVT.Delete_Distributions_Position
         (p_api_version => 1.0,
          p_return_status => l_return_status,
          p_msg_count => l_msg_count,
          p_msg_data => l_msg_data,
          p_position_id => p_position_id,
          p_worksheet_id => NULL);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
      END IF;
      END;
      END IF;
    END IF;

    g_distr_percent_total:= 0;

    FOR l_distribution_id_csr_rec IN l_distribution_id_csr
    LOOP
      g_distr_percent_total
        := g_distr_percent_total + l_distribution_id_csr_rec.distribution_percent;
    END LOOP;
 -- Bug 4237598 commented the following condition
 -- IF NOT FND_API.to_Boolean(l_global_dist_exists) THEN
 -- BEGIN

      FOR c_Dist_Rec in c_Dist LOOP


        PSB_POSITION_PAY_DISTR_PVT.Modify_Distribution_WS
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_worksheet_id => NULL,
	  p_distribution_id => l_distribution_id,
 	  p_position_id => p_position_id,
	  p_data_extract_id => p_data_extract_id,
	  p_effective_start_date => p_position_start_date,
	  p_effective_end_date => p_position_end_date,
          p_modify_flag => l_overwrite_flag,
	  p_chart_of_accounts_id => c_Dist_Rec.chart_of_accounts_id,
	  p_code_combination_id => c_Dist_Rec.code_combination_id,
	  p_distribution_percent => c_Dist_Rec.distribution_percent,
	  p_global_default_flag => l_global_default_flag,
	  p_distribution_default_rule_id => l_default_rule_id,
	  p_rowid => l_rowid,
          p_ruleset_id => p_ruleset_id);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   raise FND_API.G_EXC_ERROR;
       END IF;

      END LOOP;

 -- END;
 -- END IF;

    END LOOP;

  END IF;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Create_Distribution_Position;

/* ------------------------------------------------------------------------- */

PROCEDURE Create_Element_Assignment
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER,
  p_data_extract_id      IN   NUMBER,
  p_position_id          IN   NUMBER,
  p_position_start_date  IN   DATE,
  p_position_end_date    IN   DATE
) IS

  l_api_name             CONSTANT VARCHAR2(30)   := 'Create_Element_Assignment';
  l_api_version          CONSTANT NUMBER         := 1.0;

  l_worksheet_id         NUMBER;
  l_posasgn_id           NUMBER;
  l_rowid                VARCHAR2(100);

  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);

  l_return_status        VARCHAR2(1);

  cursor c_Assignments is
    select a.default_rule_id,
	   b.priority,
	   b.global_default_flag,
	   a.pay_element_id,
	   a.pay_element_option_id,
	   a.pay_basis,
	   a.element_value_type,
	   a.element_value,
	   a.currency_code
      from PSB_DEFAULT_ASSIGNMENTS a,
	   PSB_DEFAULTS b,
	   PSB_SET_RELATIONS c,
	   PSB_BUDGET_POSITIONS d
     where EXISTS
	   ( select 1
	     from   PSB_PAY_ELEMENTS pe
	     where  pe.salary_flag     <> 'Y'
	     and    pe.data_extract_id = p_data_extract_id
             and    pe.pay_element_id  = a.pay_element_id
           )
       and a.assignment_type = 'ELEMENT'
       and a.default_rule_id = b.default_rule_id
       and b.priority is not null
       and b.default_rule_id = c.default_rule_id
       and c.account_position_set_id = d.account_position_set_id
       and d.data_extract_id = p_data_extract_id
       and d.position_id = p_position_id
     order by b.priority;

BEGIN

  if p_worksheet_id = FND_API.G_MISS_NUM then
    l_worksheet_id := null;
  else
    l_worksheet_id := p_worksheet_id;
  end if;

  /* for bug 4644241 --> Changed the procedure from Modify Assignment to
     apply_default_rules. This is taken care to see that no overlapping
     assignment gets created.  */

  for c_Assignments_Rec in c_Assignments loop

    Apply_Position_Default_Rules
 	  (p_api_version => 1.0,
	   x_return_status => l_return_status,
	   x_msg_count => l_msg_count,
	   x_msg_data => l_msg_data,
	   p_position_assignment_id => l_posasgn_id,
	   p_data_extract_id => p_data_extract_id,
	   p_position_id => p_position_id,
	   p_assignment_type => 'ELEMENT',
	   p_attribute_id => null,
	   p_attribute_value_id => null,
	   p_attribute_value => null,
	   p_pay_element_id => c_Assignments_Rec.pay_element_id,
	   p_pay_element_option_id => c_Assignments_Rec.pay_element_option_id,
           p_effective_start_date => p_position_start_date,
	   p_effective_end_date => p_position_end_date,
	   p_element_value_type => c_Assignments_Rec.element_value_type,
	   p_element_value => c_Assignments_Rec.element_value,
	   p_currency_code => c_Assignments_Rec.currency_code,
	   p_pay_basis => c_Assignments_Rec.pay_basis,
	   p_employee_id => null,
	   p_primary_employee_flag => null,
	   p_global_default_flag => c_Assignments_Rec.global_default_flag,
	   p_assignment_default_rule_id => c_Assignments_Rec.default_rule_id,
	   p_modify_flag => 'Y',
           p_worksheet_id => null);

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

END Create_Element_Assignment;

/* For Bug 4644241 --> Reverting Back to the old fix
   This will maintain the old functionality. Old Apply Global
   Default before Mass position assignment enhancement retained.
*/

/* ------------------------------------------------------------------------- */

PROCEDURE Apply_Global_Default
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER,
  p_data_extract_id      IN   NUMBER,
  p_position_id          IN   NUMBER,
  p_position_start_date  IN   DATE,
  p_position_end_date    IN   DATE
) IS

  l_worksheet_id         NUMBER;
  l_posasgn_id           NUMBER;
  l_rowid                VARCHAR2(100);

  l_distribution_id      NUMBER;

  l_msg_count            NUMBER;
  l_msg_data             VARCHAR2(2000);

  l_return_status        VARCHAR2(1);

  -- For Bug 4644241
  l_distr_exists         BOOLEAN;



  cursor c_Assignments is
    select a.default_rule_id,
	   a.assignment_type,
	   a.attribute_id,
	   a.attribute_value_id,
	   a.attribute_value,
	   a.pay_element_id,
	   a.pay_element_option_id,
	   a.pay_basis,
	   a.element_value_type,
	   a.element_value,
	   a.currency_code
      from PSB_DEFAULT_ASSIGNMENTS a,
	   PSB_DEFAULTS b
     where a.default_rule_id = b.default_rule_id
       and b.global_default_flag = 'Y'
       and b.data_extract_id = p_data_extract_id;

  cursor c_Dist is
    select a.default_rule_id,
	   a.chart_of_accounts_id,
	   a.code_combination_id,
	   a.distribution_percent
      from PSB_DEFAULT_ACCOUNT_DISTRS a,
	   PSB_DEFAULTS b
     where a.default_rule_id = b.default_rule_id
       and b.global_default_flag = 'Y'
       and b.data_extract_id = p_data_extract_id;

BEGIN

  if p_worksheet_id = FND_API.G_MISS_NUM then
    l_worksheet_id := null;
  else
    l_worksheet_id := p_worksheet_id;
  end if;

  /* For Bug 4644241 --> Change the API call from modify assignment to
     apply_position_default_rules. This will take care of not creating
     overlapping assignments */

  for c_Assignments_Rec in c_Assignments loop

      Apply_Position_Default_Rules
 	  (p_api_version => 1.0,
	   x_return_status => l_return_status,
	   x_msg_count => l_msg_count,
	   x_msg_data => l_msg_data,
	   p_position_assignment_id => l_posasgn_id,
	   p_data_extract_id => p_data_extract_id,
	   p_position_id => p_position_id,
	   p_assignment_type => c_Assignments_Rec.assignment_type,
	   p_attribute_id => c_Assignments_Rec.attribute_id,
	   p_attribute_value_id => c_Assignments_Rec.attribute_value_id,
	   p_attribute_value => c_Assignments_Rec.attribute_value,
	   p_pay_element_id => c_Assignments_Rec.pay_element_id,
	   p_pay_element_option_id => c_Assignments_Rec.pay_element_option_id,
           p_effective_start_date => p_position_start_date,
	   p_effective_end_date => p_position_end_date,
	   p_element_value_type => c_Assignments_Rec.element_value_type,
	   p_element_value => c_Assignments_Rec.element_value,
	   p_currency_code => c_Assignments_Rec.currency_code,
	   p_pay_basis => c_Assignments_Rec.pay_basis,
	   p_employee_id => null,
	   p_primary_employee_flag => null,
	   p_global_default_flag => 'Y',
	   p_assignment_default_rule_id => c_Assignments_Rec.default_rule_id,
	   p_modify_flag => 'Y',
           p_worksheet_id => null);

        if l_return_status <> FND_API.G_RET_STS_SUCCESS then
          raise FND_API.G_EXC_ERROR;
        end if;

  end loop;

    /* for bug 4644241 --> Make sure that the distribution is
    100 % and does not go beyond that */
    l_distr_exists := TRUE;

    IF l_worksheet_id IS NULL THEN
      FOR l_pos_distr_rec IN ( SELECT 1
                               FROM dual
                               WHERE NOT EXISTS ( SELECT 1
                                                  FROM   psb_position_pay_distributions
                                                  WHERE  position_id = p_position_id
                                                  AND    data_extract_id = p_data_extract_id
                                                  AND    worksheet_id IS NULL))
      LOOP
        l_distr_exists := FALSE;
      END LOOP;
    ELSE
      FOR l_pos_distr_rec IN ( SELECT 1
                               FROM dual
                               WHERE NOT EXISTS ( SELECT 1
                                                  FROM   psb_position_pay_distributions
                                                  WHERE  position_id = p_position_id
                                                  AND    data_extract_id = p_data_extract_id
                                                  AND    worksheet_id = l_worksheet_id))
      LOOP
        l_distr_exists := FALSE;
      END LOOP;
    END IF;

  for c_Dist_Rec in c_Dist loop

    IF NOT l_distr_exists THEN

      PSB_POSITION_PAY_DISTR_PVT.Modify_Distribution_WS
       (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_worksheet_id => l_worksheet_id,
	  p_distribution_id => l_distribution_id,
	  p_position_id => p_position_id,
	  p_data_extract_id => p_data_extract_id,
	  p_effective_start_date => p_position_start_date,
	  p_effective_end_date => p_position_end_date,
	  p_chart_of_accounts_id => c_Dist_Rec.chart_of_accounts_id,
	  p_code_combination_id => c_Dist_Rec.code_combination_id,
	  p_distribution_percent => c_Dist_Rec.distribution_percent,
	  p_global_default_flag => 'Y',
	  p_distribution_default_rule_id => c_Dist_Rec.default_rule_id,
	  p_rowid => l_rowid);

       if l_return_status <> FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
      end if;

    END IF;


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

END Apply_Global_Default;

/*-----------------------------------------------------------------*/


PROCEDURE Initialize_View ( p_worksheet_id  in number,
			    p_start_date    in date,
			    p_end_date      in date,
			    p_select_date   in date := fnd_api.g_miss_date
			   ) IS

BEGIN

    g_Worksheet_ID := p_Worksheet_ID;
    g_Start_Date   := p_start_date;
    g_End_Date     := p_end_date;

    if p_select_date <> fnd_api.g_miss_date then
	g_Select_Date := p_Select_date ;
    else
	g_Select_Date := Null ;
    end if;

    if (p_worksheet_id IS NULL) then
       g_worksheet_flag := 'N' ;
    else
       g_worksheet_flag := 'Y' ;
    end if ;

END Initialize_View;

/*-----------------------------------------------------------------*/

PROCEDURE Define_Worksheet_Values (
	    p_api_version              in number,
	    p_init_msg_list            in varchar2 := fnd_api.g_false,
	    p_commit                   in varchar2 := fnd_api.g_false,
	    p_validation_level         in number   := fnd_api.g_valid_level_full,
	    p_return_status            OUT  NOCOPY varchar2,
	    p_msg_count                OUT  NOCOPY number,
	    p_msg_data                 OUT  NOCOPY varchar2,
	    p_worksheet_id             in number,
	    p_position_id              in number,
	    p_pos_effective_start_date in date  := FND_API.G_MISS_DATE,
	    p_pos_effective_end_date   in date  := FND_API.G_MISS_DATE,
	    p_budget_source            in varchar2 := FND_API.G_MISS_CHAR,
	    p_out_worksheet_id         OUT  NOCOPY number,
	    p_out_start_date           OUT  NOCOPY date,
	    p_out_end_date             OUT  NOCOPY date) IS

     l_api_name         CONSTANT VARCHAR2(30) := 'Define_Worksheet_Values';
     l_worksheet_id NUMBER ;
     l_global_worksheet_id NUMBER ;
     l_local_copy_flag VARCHAR2(1) ;
     l_budget_calendar_id NUMBER ;
     l_cal_start_date DATE ;
     l_cal_end_date DATE ;
     l_pos_effective_start_date DATE ;
     l_pos_effective_end_date DATE ;
     l_out_start_date DATE ;
     l_out_end_date DATE ;
     l_out_worksheet_id NUMBER ;
     l_return_status  VARCHAR2(1);
     --
     cursor position_csr IS
	 SELECT effective_start_date ,
		effective_end_date
	   FROM psb_positions
	  WHERE position_id = p_position_id ;
     cursor worksheet_csr IS
	 SELECT worksheet_id,local_copy_flag,global_worksheet_id,
		budget_calendar_id
	   FROM psb_worksheets
	  WHERE worksheet_id = p_worksheet_id ;
     cursor calendar_csr IS
	 SELECT     min(start_date) ,     max(end_date)
	   FROM psb_worksheets w,psb_budget_periods b
	  WHERE b.budget_calendar_id = w.budget_calendar_id AND
		w.worksheet_id = l_out_worksheet_id AND
		budget_period_type = 'Y';
     cursor rev_csr IS
	 SELECT decode(global_budget_revision,'Y',budget_revision_id,global_budget_revision_id)
	   FROM psb_budget_revisions
	  WHERE budget_revision_id = p_worksheet_id;


BEGIN

     --
     if FND_API.to_Boolean (p_init_msg_list) then
	FND_MSG_PUB.initialize;
     end if;

      -- STEP 1
      -- determine the worksheet id
      -- distributed worksheets should use global WS id
      -- local copy should be its WS id
      -- for revision, use revision id and start/end date

     if p_worksheet_id IS NULL THEN
	-- this is for base assignment
	l_out_worksheet_id := p_worksheet_id ;
     else

       if nvl(p_budget_source,'BP') = 'BR' THEN
       -- revision
	   OPEN rev_csr ;
	   FETCH rev_csr INTO    l_out_worksheet_id;

	   -- revision do not need date values so they may be null.. use position
	   -- revision now has same structure as worksheet

	   if (rev_csr%NOTFOUND)  THEN
	      FND_MESSAGE.SET_NAME('PSB', 'PSB_REVISION_NOT_FOUND') ;
	      FND_MSG_PUB.Add ;
	      raise FND_API.G_EXC_ERROR ;
	   end if;
	   CLOSE rev_csr ;

	else

	-- worksheet processing

	   OPEN worksheet_csr ;
	   FETCH worksheet_csr INTO l_worksheet_id ,
				 l_local_copy_flag ,
				 l_global_worksheet_id ,
				 l_budget_calendar_id ;
	   if (worksheet_csr%NOTFOUND)  THEN
	      FND_MESSAGE.SET_NAME('PSB', 'PSB_WORKSHEET_NOT_FOUND') ;
	      FND_MSG_PUB.Add ;
	      raise FND_API.G_EXC_ERROR ;
	   end if;
	   CLOSE worksheet_csr ;

	   if (l_local_copy_flag = 'Y') THEN
	      l_out_worksheet_id := l_worksheet_id ;
	   else
	      if (l_global_worksheet_id IS NOT NULL) THEN
		 l_out_worksheet_id := l_global_worksheet_id ;
		 -- if not global worksheet,use global worksheet id
	      else
		 l_out_worksheet_id := l_worksheet_id ;
		 -- if global worksheet, global worksheet id is null so use
		 -- the input worksheet id
	      end if;
	   end if ;

	   -- get calendar min/max to compare with position's eff start/end date

	   OPEN calendar_csr ;
	   FETCH calendar_csr INTO l_cal_start_date,
			       l_cal_end_date ;
	   if (calendar_csr%NOTFOUND) THEN
	      FND_MESSAGE.SET_NAME('PSB', 'PSB_CALENDAR_NOT_FOUND') ;
	      FND_MSG_PUB.Add ;
	      raise FND_API.G_EXC_ERROR ;
	   end if;
	   --
	   CLOSE calendar_csr ;

	end if; -- end of ws vs rev

     end if ;

     -- STEP 2
     -- get position start/end date if not available, calling prg will
     -- just input position id

     l_pos_effective_start_date := p_pos_effective_start_date;
     l_pos_effective_end_date   := p_pos_effective_end_date;
     -- is the default

     if (p_position_id IS NOT NULL) then
	    -- get pos effec date from table
	    OPEN position_csr ;
	    FETCH position_csr INTO l_pos_effective_start_date,
				    l_pos_effective_end_date ;
	    if (position_csr%NOTFOUND) then
		 FND_MESSAGE.SET_NAME('PSB', 'PSB_POSITION_NOT_FOUND') ;
		 FND_MSG_PUB.Add ;
		 raise FND_API.G_EXC_ERROR ;
	    end if;
	    CLOSE position_csr ;
     end if;

     --
     -- supersede value of out_dates with input start and end dates
     -- if position id is not null to use the input values in case
     -- users changes the dates without saving them.
     -- If position id is null such as when creating new positions
     -- from forms and position has not been saved yet, use input dates
     --
     if (p_pos_effective_start_date <> FND_API.G_MISS_DATE ) then

	   l_out_start_date := p_pos_effective_start_date ;
	   l_out_end_date   := p_pos_effective_end_date ;
	--
     end if;

     -- STEP 3.
     -- next determine what date to use
     -- always use position start date since this is more constricting
     -- than calendar date; this will allow them also to assign with s
     -- start date before the calendar start date which is true of
     -- a base assignment
     -- if from maintain position or budget revision, always use position date

      if (p_worksheet_id IS NULL) then
	 l_out_start_date := p_pos_effective_start_date ;
	 l_out_end_date   := p_pos_effective_end_date ;
	 -- from maintain positios
      elsif nvl(p_budget_source,'BP') = 'BR' THEN
	 l_out_start_date := l_pos_effective_start_date ;
	 l_out_end_date   := p_pos_effective_end_date ;
	 -- for bg rev, use position's start date and passed end date
	 -- end date needed b/c assignments_v will not work if it is null
	 -- BR should pass an end date
      else

	    l_out_start_date := l_pos_effective_start_date ;

	    if (l_pos_effective_end_date   IS NULL) then
	       l_out_end_date := l_cal_end_date;
	    else
	       -- use earliest end date
	       if (l_cal_end_date <= l_pos_effective_end_date) then
		  l_out_end_date := l_cal_end_date;
	       else
		  l_out_end_date := l_pos_effective_end_date ;
	       end if;

	    end if;

     end if;

    --
    -- move to OUT  NOCOPY parameters
    p_out_worksheet_id := l_out_worksheet_id ;
    p_out_start_date   := l_out_start_date ;
    p_out_end_date     := l_out_end_date ;

    p_return_status    := FND_API.G_RET_STS_SUCCESS ;

    -- Standard call to get message count and if count is 1, get message info.

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			       p_data  => p_msg_data);
    --

EXCEPTION
   --
   when FND_API.G_EXC_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when FND_API.G_EXC_UNEXPECTED_ERROR then
     --
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
   when OTHERS then
     --
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
     --
END Define_Worksheet_Values ;

/* -------------------------------------------------------------------- */
--
-- Validate_Salary validates that there is only one salary for a date.
-- This is called from the application form of any of the positions form
-- and from PSBWPI2B.pls
-- The cursor was modified by expanding the where clause on worksheet_id
-- (i) so that base salary with no WS salary are also selected by the cursor;
-- this fixes a bug where entering a WS specific salary that overlapped
-- the base did not give an error from the form
--
-- (ii) and conversely, excludes those base for which there exists a WS specific
-- salary of any salary element;
--
--
PROCEDURE Validate_Salary
( p_api_version           IN   NUMBER,
  p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level      IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status         OUT  NOCOPY  VARCHAR2,
  p_msg_count             OUT  NOCOPY  NUMBER,
  p_msg_data              OUT  NOCOPY  VARCHAR2,
  p_worksheet_id          IN   NUMBER,
  p_position_id           IN   NUMBER,
  p_effective_start_date  IN   DATE,
  p_effective_end_date    IN   DATE,
  p_pay_element_id        IN   NUMBER,
  p_data_extract_id       IN   NUMBER,
  p_rowid                 IN   VARCHAR2
) IS

  l_api_name              CONSTANT VARCHAR2(30) := 'Validate_Salary';
  l_api_version           CONSTANT NUMBER       := 1.0;

  cursor c_Overlap is
    select a.rowid,a.pay_element_id,  --bug:7507448
           'Salary Overlaps'
      from PSB_POSITION_ASSIGNMENTS a,
	   PSB_PAY_ELEMENTS b
     where ((((p_effective_end_date is not null)
       and ((a.effective_start_date <= p_effective_end_date)
	and (a.effective_end_date is null))
	or ((a.effective_start_date between p_effective_start_date and nvl(p_effective_end_date,a.effective_start_date))  --bug:7507448:modified
	 or (a.effective_end_date between p_effective_start_date and nvl(p_effective_end_date,a.effective_end_date))      --bug:7507448:modified
	or ((a.effective_start_date < p_effective_start_date)
	and (a.effective_end_date > p_effective_end_date)))))
	or ((p_effective_end_date is null)
	and (nvl(a.effective_end_date, p_effective_start_date) >= p_effective_start_date)))
      and ( (nvl(a.worksheet_id, FND_API.G_MISS_NUM) = nvl(p_worksheet_id, FND_API.G_MISS_NUM)) OR
	      (p_worksheet_id is not null and worksheet_id is null
	      and not exists
	      (select 1 from
	       psb_position_assignments c ,psb_pay_elements pe2
	       where c.position_id = a.position_id
	       and c.pay_element_id = pe2.pay_element_id
	       and pe2.salary_flag = 'Y'
	       and c.worksheet_id = p_worksheet_id
	       and ( (
		nvl(c.effective_start_date,PSB_POSITIONS_PVT.GET_end_date+1) between
		nvl(a.effective_start_date,PSB_POSITIONS_PVT.GET_end_date) and
		nvl(a.effective_end_date,nvl(PSB_POSITIONS_PVT.GET_end_date,
		c.effective_start_date ))) or (
		nvl(a.effective_start_date,PSB_POSITIONS_PVT.GET_end_date+1) between
		nvl(c.effective_start_date,PSB_POSITIONS_PVT.GET_end_date) and
		nvl(c.effective_end_date,nvl(PSB_POSITIONS_PVT.GET_end_date,
		a.effective_start_date ))) )
	       )
	    )
	    )
      and a.pay_element_id = b.pay_element_id
      and a.position_id = p_position_id
      and a.rowid <> nvl(p_rowid,0)         --bug:7507448
      and b.salary_flag = 'Y'
      and b.data_extract_id = p_data_extract_id;


  l_return_status         VARCHAR2(1);
  l_salary_overlaps       VARCHAR2(1) := FND_API.G_FALSE;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  for c_Overlap_Rec in c_Overlap loop
    l_salary_overlaps := FND_API.G_TRUE;
  end loop;

  if FND_API.to_Boolean(l_salary_overlaps) then
  begin

      FND_MESSAGE.SET_NAME('PSB', 'PSB_MULTIPLE_SALARY_IN_PERIOD');
      FND_MSG_PUB.Add;

      raise FND_API.G_EXC_ERROR;

  end;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);


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

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Validate_Salary;

/* -------------------------------------------------------------------- */

  -- Calling program should check p_return_status
  -- if successful, check p_validation_status of either 'S'-uccessful or 'E'-rror
  --
  -- p_worksheet_id is the global worksheet id
  --


PROCEDURE Position_WS_Validation
( p_api_version          in number,
  p_init_msg_list        in varchar2 := fnd_api.g_false,
  p_commit               in varchar2 := fnd_api.g_false,
  p_validation_level     in number   := fnd_api.g_valid_level_full,
  p_return_status        OUT  NOCOPY varchar2,
  p_msg_count            OUT  NOCOPY number,
  p_msg_data             OUT  NOCOPY varchar2,
  p_worksheet_id         in number,
  p_validation_status    OUT  NOCOPY varchar2,
  p_validation_mode      IN VARCHAR2
) IS

  l_api_name              CONSTANT VARCHAR2(30) := 'Position_WS_Validation';
  l_api_version           CONSTANT NUMBER       := 1.0;
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);

  l_data_extract_id                NUMBER;
  l_budget_calendar_id             NUMBER;
  l_budget_group_id                NUMBER;
  l_root_budget_group_id           NUMBER;
  l_chart_of_accounts_id           NUMBER;
  l_set_of_books_id                NUMBER;
  l_error_flag                     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  CURSOR c_ws IS
     SELECT data_extract_id,
	    budget_calendar_id,
	    budget_group_id
       FROM psb_worksheets
      WHERE worksheet_id = p_worksheet_id;

  CURSOR c_bg IS
    SELECT nvl(root_budget_group_id,budget_group_id) ,
	   nvl(root_chart_of_accounts_id,chart_of_accounts_id),
	   nvl(root_set_of_books_id,set_of_books_id)
      FROM psb_budget_groups_v
     WHERE budget_group_id = l_budget_group_id;

BEGIN
  -- Standard call to check for call compatibility.

  g_validation_mode := p_validation_mode;

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  OPEN c_ws;
  FETCH c_ws INTO
	    l_data_extract_id,
	    l_budget_calendar_id,
	    l_budget_group_id;
  CLOSE c_ws;

  OPEN c_bg;
  FETCH c_bg INTO
	l_root_budget_group_id,
	l_chart_of_accounts_id,
	l_set_of_books_id;
  CLOSE c_bg;


  PSB_WS_ACCT1.Flex_Info
       (p_flex_code => l_chart_of_accounts_id,
	p_return_status => l_return_status);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
  END IF;


     -- get calendar start/end dates
  if l_budget_calendar_id <> nvl(PSB_WS_ACCT1.g_budget_calendar_id, FND_API.G_MISS_NUM) then
  begin

    PSB_WS_ACCT1.Cache_Budget_Calendar(p_return_status => p_return_status,
				       p_budget_calendar_id => l_budget_calendar_id);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR ;
    END IF ;

  end;
  end if;

  --++++++++


   FOR  l_positions_rec IN
	(SELECT pos.position_id,
		pos.effective_start_date,
		pos.effective_end_date,
		pos.name ,
		emp.employee_number
	  FROM  psb_positions pos,
		psb_employees emp
	 WHERE  pos.data_extract_id = l_data_extract_id
	   AND  pos.hr_employee_id = emp.hr_employee_id(+)
	   AND  emp.data_extract_id(+) = l_data_extract_id
	 ORDER BY name
	)

    LOOP


	   VALIDATE_POSITION ( p_worksheet_id => p_worksheet_id,
			       p_position_id => l_positions_rec.position_id,
			       p_name => l_positions_rec.name,
			       p_employee_number => l_positions_rec.employee_number,
			       p_data_extract_id => l_data_extract_id,
			       p_root_budget_group_id => l_root_budget_group_id,
			       p_set_of_books_id => l_set_of_books_id,
			       p_budget_calendar_id => l_budget_calendar_id,
			       p_chart_of_accounts_id => l_chart_of_accounts_id,
			       p_position_start_date => l_positions_rec.effective_start_date,
			       p_position_end_date => l_positions_rec.effective_end_date,
			       p_startdate_pp => PSB_WS_ACCT1.g_startdate_pp,
			       p_enddate_cy => PSB_WS_ACCT1.g_enddate_cy,
			       p_effective_start_date => PSB_WS_ACCT1.g_startdate_cy,
			       p_effective_end_date => PSB_WS_ACCT1.g_end_est_date,
			       p_error_flag => l_error_flag,
			       p_return_status => l_return_status);



	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR ;
	    END IF ;

    END LOOP;
    --

    IF p_validation_mode = 'STANDALONE' THEN

      IF NVL(l_error_flag,FND_API.G_RET_STS_SUCCESS) =
                        FND_API.G_RET_STS_SUCCESS THEN

        FND_MESSAGE.SET_NAME('PSB', 'PSB_VAL_LINE');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('PSB', 'PSB_NO_WS_VALID_ERR');
        FND_MSG_PUB.ADD;
        FND_MESSAGE.SET_NAME('PSB', 'PSB_VAL_LINE');
        FND_MSG_PUB.ADD;
      END IF;

    END IF;

    Output_Message_To_Table(p_worksheet_id,
			    p_return_status);

    p_validation_status := l_error_flag ;
    p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

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

    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
			       l_api_name);
    end if;

    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			       p_data  => p_msg_data);

END Position_WS_Validation;

/* -------------------------------------------------------------------- */

PROCEDURE VALIDATE_POSITION
( p_worksheet_id            IN NUMBER,
  p_position_id             IN NUMBER,
  p_name                    IN VARCHAR2,
  p_employee_number         IN VARCHAR2,
  p_data_extract_id         IN NUMBER,
  p_root_budget_group_id    IN NUMBER,
  p_set_of_books_id         IN NUMBER,
  p_budget_calendar_id      IN NUMBER,
  p_chart_of_accounts_id    IN NUMBER,
  p_position_start_date     IN DATE,
  p_position_end_date       IN DATE,
  p_startdate_pp            IN DATE,
  p_enddate_cy              IN DATE,
  p_effective_start_date    IN DATE,
  p_effective_end_date      IN DATE,
  p_error_flag          IN OUT  NOCOPY VARCHAR2,
  p_return_status          OUT  NOCOPY VARCHAR2
) IS

  l_api_name              CONSTANT VARCHAR2(30) := 'VALIDATE_POSITION';

  l_job_exists            VARCHAR2(1) := FND_API.G_FALSE;
  l_salary_exists         VARCHAR2(1) := FND_API.G_FALSE;
  l_pay_basis_invalid     VARCHAR2(1) := FND_API.G_FALSE;
  l_hourly_salary_exists  VARCHAR2(1) := FND_API.G_FALSE;
  l_weekly_hours_exists   VARCHAR2(1) := FND_API.G_TRUE;
  l_salary_distr_exists   VARCHAR2(1) := FND_API.G_FALSE;
  l_calc_exists           VARCHAR2(1) := FND_API.G_FALSE;
  l_return_status         VARCHAR2(1);
  l_position_flag         VARCHAR2(1) := NULL;
  l_salary_start_date     DATE;
  l_salary_end_date       DATE;
  l_data_extract_id       NUMBER;
  l_budget_calendar_id    NUMBER;
  l_budget_group_id       NUMBER;
  l_chart_of_accounts_id  NUMBER;


  CURSOR c_ws IS
     SELECT data_extract_id,
	    budget_calendar_id,
	    budget_group_id
       FROM psb_worksheets
      WHERE worksheet_id = p_worksheet_id;

  CURSOR c_job IS
     SELECT 'Job Exists'
       FROM dual
      WHERE exists
     (SELECT 1
	FROM psb_attribute_values patv,
	     psb_position_assignments pass,
	     psb_attributes pat
       WHERE patv.attribute_value_id = pass.attribute_value_id
	 AND (pass.worksheet_id is NULL OR pass.worksheet_id = p_worksheet_id)
	 AND pass.attribute_id = pat.attribute_id
	 AND pass.position_id = p_position_id
	 AND pat.system_attribute_type = 'JOB_CLASS');
  --++ just check that a job exist regardless of date. WS creation does not
  --++ use the job's date

  CURSOR c_salary IS
     SELECT pass.effective_start_date,pass.effective_end_date,pass.pay_basis
	FROM psb_pay_elements pe,
	     psb_position_assignments pass
       WHERE pe.salary_flag = 'Y'
	 AND pe.pay_element_id = pass.pay_element_id
	 AND (pass.worksheet_id is NULL OR pass.worksheet_id = p_worksheet_id)
	 AND (((pass.effective_start_date <= p_effective_end_date)
	   and (pass.effective_end_date is null))
	   or ((pass.effective_start_date between p_effective_start_date and p_effective_end_date)
	    or (pass.effective_end_date between p_effective_start_date and p_effective_end_date)
	   or ((pass.effective_start_date < p_effective_start_date)
	   and (pass.effective_end_date > p_effective_end_date))))
	 AND pass.position_id = p_position_id ;
  --++ salary cursor

  CURSOR c_pay_basis IS
    SELECT 'Invalid Pay Basis'
       FROM DUAL
      WHERE EXISTS
     (SELECT 1
	FROM psb_pay_elements pe,
	     psb_position_assignments pass
       WHERE NVL(pass.pay_basis,'DUMMY') NOT IN ('ANNUAL', 'HOURLY', 'MONTHLY', 'PERIOD')
	 AND pe.salary_flag = 'Y'
	 AND pe.pay_element_id = pass.pay_element_id
	 AND (pass.worksheet_id is NULL OR pass.worksheet_id = p_worksheet_id)
	 AND (((pass.effective_start_date <= p_effective_end_date)
	 AND (pass.effective_end_date is null))
	 OR ((pass.effective_start_date between p_effective_start_date and p_effective_end_date)
	 OR (pass.effective_end_date between p_effective_start_date and p_effective_end_date)
	 OR ((pass.effective_start_date < p_effective_start_date)
	 AND (pass.effective_end_date > p_effective_end_date))))
	 AND pass.position_id = p_position_id);

/* Bug No 1920021 Start */
/* --- Commented the following 11 Lines ---
  CURSOR c_Calc_Periods IS
     SELECt bp.start_date,
	    bp.end_date
       FROM psb_budget_periods bp
      WHERE bp.budget_period_type = 'C'
	AND bp.budget_calendar_id = p_budget_calendar_id
      ORDER by bp.start_date;
      -- get calculation period (proposed year) for the calendar
      -- to be used in validation of default wkly hours

  CURSOR c_weekly_hours (calc_start_date DATE, calc_end_date DATE) IS
--- */

  CURSOR c_weekly_hours IS
     SELECT 'Default Weekly Hours Exists'
       FROM dual
      WHERE exists
     (SELECT 1
	FROM psb_attributes pat,
	     psb_position_assignments pass
       WHERE pat.attribute_id = pass.attribute_id
	 AND pat.system_attribute_type = 'DEFAULT_WEEKLY_HOURS'
	 AND (pass.worksheet_id is NULL OR pass.worksheet_id = p_worksheet_id)
	 AND pass.position_id = p_position_id);

/* --- Commented the following 8 Lines ---
	 AND (((pass.effective_start_date <= calc_end_date)
	   and (pass.effective_end_date is null))
	   or ((pass.effective_start_date between calc_start_date and calc_end_date)
	    or (pass.effective_end_date between calc_start_date and calc_end_date)
	   or ((pass.effective_start_date < calc_start_date)
	   and (pass.effective_end_date > calc_end_date))))
	 AND pass.position_id = p_position_id);
  --++ that wkly hours exists within c_calc_periods (calculation pd)
--- */

/* Bug No 1920021 End */



  l_calc_start_date                DATE;
  l_calc_end_date                  DATE;
  l_end_est_date                   DATE;
  l_startdate_cy                   DATE;
  l_ccid_val                       FND_FLEX_EXT.SegmentArray;
  l_seg_val                        FND_FLEX_EXT.SegmentArray;
  l_ccid                           NUMBER;
  l_ccid_overwritten               NUMBER;
  l_flex_delimiter                 VARCHAR2(1);
  l_concat_segments                VARCHAR2(2000);
  l_last_index                     NUMBER;
  l_dynamic_insert_flag            VARCHAR2(1) := 'N';
  l_firstpp                        BOOLEAN     := TRUE;

BEGIN

  OPEN c_ws;
  FETCH c_ws INTO
	    l_data_extract_id,
	    l_budget_calendar_id,
	    l_budget_group_id;
  CLOSE c_ws;

  /* Bug 3247574 start.
     Changes done for Worksheet Exception Report */
  FOR c_budyr_rec IN(
    SELECT a.budget_period_id,
	   a.budget_year_type_id,
	   b.year_category_type,
	   period_distribution_type,
	   calculation_period_type,
	   a.name,
	   a.start_date,
	   a.end_date
      FROM psb_budget_year_types b,
	   psb_budget_periods    a
     WHERE b.budget_year_type_id = a.budget_year_type_id
       AND a.budget_period_type  = 'Y'
       AND a.budget_calendar_id  = P_budget_calendar_id
       ORDER BY a.start_date)
  LOOP


    IF c_budyr_rec.year_category_type = 'PP' THEN

      IF l_firstpp THEN
        l_firstpp := FALSE;
        l_end_est_date := c_BudYr_Rec.End_Date;
      END IF;


      IF c_budyr_rec.end_date > l_end_est_date THEN
        l_end_est_date := c_BudYr_Rec.end_date;
      END IF;

    END IF;

    IF c_budyr_rec.year_category_type = 'CY' THEN
      l_startdate_cy := c_budyr_rec.Start_Date;
    END IF;

  END LOOP;


  FOR c_dist_ws_rec IN(
    SELECT code_combination_id,
	   distribution_percent,
	   effective_start_date,
	   effective_end_date
      FROM psb_position_pay_distributions a
     WHERE code_combination_id is not null
       AND chart_of_accounts_id = p_chart_of_accounts_id
       AND (worksheet_id is null
       AND NOT EXISTS
	   (SELECT 1
	      FROM psb_position_pay_distributions c
	     WHERE (
		   ( NVL(c.effective_start_date, l_end_est_date + 1)
			BETWEEN NVL(a.effective_start_date, l_end_est_date)
			AND NVL(a.effective_end_date, NVL(l_end_est_date, c.effective_start_date)))
		OR ( NVL(a.effective_start_date, l_end_est_date + 1)
			BETWEEN NVL(c.effective_start_date, l_end_est_date)
			AND NVL(c.effective_end_date, NVL(l_end_est_date, a.effective_start_date)))
		   )
	     AND c.position_id          = a.position_id
	     AND c.chart_of_accounts_id = p_chart_of_accounts_id
	     AND c.code_combination_id is null
	     AND c.worksheet_id         = p_worksheet_id
	   ))
             AND position_id = p_position_id
     ORDER BY distribution_percent desc)
  LOOP

    l_ccid := c_dist_ws_rec.code_combination_id;

  END LOOP;


  --++++++++
  --   start of processing
  --++++++++
  --new validations


  /* The following code checks for non-existent account
     combinations in GL */

  -- for getting segment count

  FOR c_seg_count_rec IN(SELECT COUNT(segment_num) segment_count
            FROM fnd_id_flex_segments
            WHERE id_flex_code     =   'GL#'
                  AND ID_FLEX_NUM  =   p_chart_of_accounts_id
                  AND ENABLED_FLAG =   'Y')

  LOOP
    l_last_index := c_seg_count_rec.segment_count;
  END LOOP;

  IF l_ccid is NOT NULL THEN

  FOR c_dist_rec in(SELECT DISTINCT a.code_combination_id, a.segment1, a.segment2,
           a.segment3, a.segment4,
	   a.segment5, a.segment6, a.segment7, a.segment8,
	   a.segment9, a.segment10, a.segment11, a.segment12,
	   a.segment13, a.segment14, a.segment15, a.segment16,
	   a.segment17, a.segment18, a.segment19, a.segment20,
	   a.segment21, a.segment22, a.segment23, a.segment24,
	   a.segment25, a.segment26, a.segment27, a.segment28,
	   a.segment29, a.segment30,
	   a.effective_start_date, a.effective_end_date,
           e.position_id
	   FROM
                psb_pay_element_distributions a,
                psb_pay_elements b,
                psb_element_pos_Set_groups c,
                psb_set_relations d,
	        psb_budget_positions e,
                psb_position_assignments f
           WHERE
                a.position_set_group_id          =  c.position_set_group_id
                AND b.pay_element_id             =  c.pay_element_id
                AND b.data_extract_id            =  l_data_extract_id
                AND b.data_extract_id            =  e.data_extract_id
                AND d.account_position_set_id    =  e.account_position_set_id
                AND c.position_set_group_id      =  d.position_set_group_id
                AND e.position_id                =  p_position_id
                AND e.position_id                =  f.position_id
                AND f.assignment_type            =  'ELEMENT'
                AND f.pay_element_id             =  b.pay_element_id)

  /* Bug 3692601 Start */
  --                AND a.code_combination_id IS NULL)
  /* Bug 3692601 End */
  LOOP

  /* Bug 3692601 Start */
  IF c_dist_rec.code_combination_id IS NULL THEN
  /* Bug 3692601 End */

  FOR l_init_index in 1..l_last_index
  LOOP
    l_seg_val(l_init_index)  := NULL;
    l_ccid_val(l_init_index) := NULL;
  END LOOP;

  IF NOT FND_FLEX_EXT.Get_Segments
	  (application_short_name => 'SQLGL',
	   key_flex_code => 'GL#',
	   structure_number => p_chart_of_accounts_id,
	   combination_id => l_ccid,
	   n_segments => l_last_index,
	   segments => l_ccid_val) THEN

	  FND_MSG_PUB.Add;
	  raise FND_API.G_EXC_ERROR;
  END IF;

	FOR l_index IN 1..l_last_index LOOP

	  IF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT1') AND
	      (c_Dist_Rec.segment1 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment1;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT2') AND
	      (c_Dist_Rec.segment2 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment2;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT3') AND
	      (c_Dist_Rec.segment3 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment3;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT4') AND
	      (c_Dist_Rec.segment4 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment4;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT5') AND
	      (c_Dist_Rec.segment5 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment5;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT6') AND
	      (c_Dist_Rec.segment6 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment6;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT7') AND
	      (c_Dist_Rec.segment7 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment7;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT8') AND
	      (c_Dist_Rec.segment8 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment8;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT9') AND
	      (c_Dist_Rec.segment9 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment9;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT10') AND
	      (c_Dist_Rec.segment10 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment10;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT11') AND
	      (c_Dist_Rec.segment11 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment11;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT12') AND
	      (c_Dist_Rec.segment12 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment12;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT13') AND
	      (c_Dist_Rec.segment13 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment13;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT14') AND
	      (c_Dist_Rec.segment14 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment14;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT15') AND
	      (c_Dist_Rec.segment15 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment15;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT16') AND
	      (c_Dist_Rec.segment16 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment16;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT17') AND
	      (c_Dist_Rec.segment17 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment17;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT18') AND
	      (c_Dist_Rec.segment18 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment18;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT19') AND
	      (c_Dist_Rec.segment19 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment19;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT20') AND
	      (c_Dist_Rec.segment20 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment20;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT21') AND
	      (c_Dist_Rec.segment21 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment21;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT22') AND
	      (c_Dist_Rec.segment22 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment22;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT23') AND
	      (c_Dist_Rec.segment23 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment23;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT24') AND
	      (c_Dist_Rec.segment24 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment24;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT25') AND
	      (c_Dist_Rec.segment25 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment25;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT26') AND
	      (c_Dist_Rec.segment26 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment26;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT27') AND
	      (c_Dist_Rec.segment27 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment27;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT28') AND
	      (c_Dist_Rec.segment28 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment28;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT29') AND
	      (c_Dist_Rec.segment29 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment29;

	  ELSIF ((PSB_WS_ACCT1.g_seg_name(l_index) = 'SEGMENT30') AND
	      (c_Dist_Rec.segment30 IS NOT NULL)) THEN
	    l_seg_val(l_index) := c_Dist_Rec.segment30;
          ELSE
	   l_seg_val(l_index) := l_ccid_val(l_index);
	  END IF;


	END LOOP;


        l_flex_delimiter := FND_FLEX_EXT.Get_Delimiter
				(application_short_name => 'SQLGL',
				 key_flex_code          => 'GL#',
				 structure_number       =>  p_chart_of_accounts_id);

	l_concat_segments := FND_FLEX_EXT.Concatenate_Segments
				 (n_segments  => l_last_index,
				  segments    => l_seg_val,
				  delimiter   => l_flex_delimiter);


        IF NOT fnd_flex_keyval.validate_segs(operation	=>'FIND_COMBINATION',
			 appl_short_name	=>'SQLGL',
			 key_flex_code		=>'GL#',
		  	 structure_number	=>p_chart_of_accounts_id,
		 	 concat_segments	=>l_concat_segments)      THEN

	BEGIN
          /* Bug 3692601 Start */

          IF NVL(g_validation_mode,'WSC') <> 'STANDALONE'
          AND NVL(p_error_flag,FND_API.G_RET_STS_SUCCESS) <> FND_API.G_RET_STS_ERROR THEN
            SET_POS_HEADING(l_position_flag ,p_name,
                           p_employee_number,p_error_flag);

            p_error_flag := FND_API.G_RET_STS_SUCCESS;
          ELSE
            SET_POS_HEADING(l_position_flag ,p_name,
                           p_employee_number,p_error_flag);

          END IF;

          FND_MESSAGE.SET_NAME('PSB', 'PSB_GL_CCID_FAILURE');
          FND_MESSAGE.SET_TOKEN('ACCOUNT', l_concat_segments);
          FND_MSG_PUB.ADD;
          /* Bug 3692601 End */
	END;
        /* Bug 3692601 Start */
        ELSE
          l_ccid_overwritten := FND_FLEX_EXT.get_ccid
                       (application_short_name => 'SQLGL',
                        key_flex_code => 'GL#',
                        structure_number => p_chart_of_accounts_id,
                        validation_date	 => SYSDATE,
                        concatenated_segments => l_concat_segments);
          IF l_ccid_overwritten > 0 THEN
            FOR cc_rec IN
              (SELECT detail_budgeting_allowed_flag, summary_flag
               FROM GL_CODE_COMBINATIONS
               WHERE code_combination_id = l_ccid_overwritten
              )
            LOOP
              IF cc_rec.detail_budgeting_allowed_flag = 'N'
                 OR cc_rec.summary_flag = 'Y' THEN
                SET_POS_HEADING(l_position_flag, p_name,p_employee_number, p_error_flag);
                FND_MESSAGE.Set_Name('PSB', 'PSB_SUMMARY_DETAIL_BUDGETING');
                FND_MESSAGE.SET_TOKEN('ACCOUNT', l_concat_segments);
                FND_MSG_PUB.ADD;
              END IF;
            END LOOP;
          END IF;
        /* Bug 3692601 End */
	END IF;

  /* Bug 3692601 Start */
  ELSE
    FOR cc_rec IN
                 (SELECT detail_budgeting_allowed_flag, summary_flag
                  FROM GL_CODE_COMBINATIONS
                  WHERE code_combination_id = c_dist_rec.code_combination_id
                 )
    LOOP
      IF cc_rec.detail_budgeting_allowed_flag = 'N'
      OR cc_rec.summary_flag = 'Y' THEN
        l_concat_segments := FND_FLEX_EXT.Get_Segs
                             (application_short_name => 'SQLGL',
                              key_flex_code => 'GL#',
                              structure_number => p_chart_of_accounts_id,
                              combination_id => c_dist_rec.code_combination_id);
        SET_POS_HEADING(l_position_flag, p_name,p_employee_number, p_error_flag);
        FND_MESSAGE.Set_Name('PSB', 'PSB_SUMMARY_DETAIL_BUDGETING');
        FND_MESSAGE.SET_TOKEN('ACCOUNT', l_concat_segments);
        FND_MSG_PUB.ADD;
      END IF;
    END LOOP;
  END IF;
  /* Bug 3692601 End */

  END LOOP;
  END IF;

  /* Bug 3247574 End */

   FOR l_calcperiod_index in 1..PSB_WS_ACCT1.g_num_calc_periods LOOP

    l_calc_start_date := PSB_WS_ACCT1.g_calculation_periods(l_calcperiod_index).start_date;
    l_calc_end_date   := PSB_WS_ACCT1.g_calculation_periods(l_calcperiod_index).end_date;

   END LOOP;

   for c_job_rec in c_job loop
       l_job_exists := FND_API.G_TRUE;
   end loop;

   IF NOT FND_API.to_Boolean(l_job_exists)  THEN
      SET_POS_HEADING(l_position_flag,
		      p_name,p_employee_number,p_error_flag           );
      FND_MESSAGE.SET_NAME('PSB', 'PSB_VAL_NO_JOB_ATTRIBUTE');
      FND_MSG_PUB.Add;
   END IF;

   --++ paybasis
   /* Bug 3247574 Start
      Changes done for Worksheet Exception Report  */
   /* The following code checks for Invalid Pay Basis
      attached to a position */

   FOR c_pay_basis_rec in c_pay_basis LOOP
       l_pay_basis_invalid := FND_API.G_TRUE;
   END LOOP;

   IF FND_API.to_Boolean(l_pay_basis_invalid) THEN
      /* SET_POS_HEADING(l_position_flag ,
		      p_name,p_employee_number,p_error_flag           );
      FND_MESSAGE.SET_NAME('PSB', 'PSB_VAL_INVALID_PAY_BASIS');
      FND_MSG_PUB.Add; */
      SET_POS_HEADING(l_position_flag,
		      p_name,p_employee_number,p_error_flag );
      FND_MESSAGE.SET_NAME('PSB', 'PSB_INVALID_SALARY_BASIS');
      FND_MESSAGE.SET_TOKEN('POSITION', p_name);
      FND_MESSAGE.SET_TOKEN('START_DATE', l_calc_start_date);
      FND_MESSAGE.SET_TOKEN('END_DATE', l_calc_end_date);
      FND_MSG_PUB.ADD;
   END IF;

   /* Bug 3247574 End */

   --+ validate that salary exists in calendar and that
   --+ salary distribution exists for each of salary assignments
   --+ if salary has HOURLY pay basis, then check that default wkly hours exists
   --+ for each calculation period of the salary


  for c_salary_rec in c_salary loop

      l_salary_exists := FND_API.G_TRUE;

      --+ get the stinger date between calendar date and salary date
      --+ p_effective_end_date is always not null since it the calendar's end date

      l_salary_start_date := greatest(c_salary_rec.effective_start_date, p_effective_start_date);
      l_salary_end_date := least(nvl(c_salary_rec.effective_end_date, p_effective_end_date), p_effective_end_date);

      --++ if hourly salary basis, check that wkly salary exists for each of calculation pd
      --++ within salary range
      if c_salary_rec.pay_basis = 'HOURLY' then

/* Bug No 1920021 Start */
/* --- Commented the following 8 Lines ---
	 for c_calc_periods_rec in c_calc_periods loop

	  if (((l_salary_start_date <= c_calc_periods_rec.end_date)
	      and (l_salary_end_date is null))
	       or ((l_salary_start_date between c_calc_periods_rec.start_date and c_calc_periods_rec.end_date)
	       or (l_salary_end_date between c_calc_periods_rec.start_date and c_calc_periods_rec.end_date)
	       or ((l_salary_start_date < c_calc_periods_rec.start_date)
	      and (l_salary_end_date > c_calc_periods_rec.end_date)))) then
--- */
/* Bug No 1920021 End */

	  begin

/* Bug No 1920021 Start */
---             l_calc_exists := FND_API.G_FALSE;
	     l_weekly_hours_exists := FND_API.G_FALSE;
/* Bug No 1920021 End */

	     for c_weekly_hours_rec in c_weekly_hours loop

/* Bug No 1920021 Start */
/* --- Commented the following 2 Lines, added 3rd line --- */
--              (c_calc_periods_rec.start_date, c_calc_periods_rec.end_date) loop

---             l_calc_exists := FND_API.G_TRUE;
	     l_weekly_hours_exists := FND_API.G_TRUE;
/* Bug No 1920021 End */

	     end loop;

/* Bug No 1920021 Start */
 --- Commented the following 3 Lines ---
--             IF NOT FND_API.to_Boolean(l_calc_exists) THEN
--                l_weekly_hours_exists := FND_API.G_FALSE;
--             END IF;
/* Bug No 1920021 End */

	   end;

/* Bug No 1920021 Start */
/* --- Commented the following 2 Lines --- */
--           end if;

--         end loop;
/* Bug No 1920021 End */

	 if NOT FND_API.to_Boolean(l_weekly_hours_exists) THEN
	    SET_POS_HEADING(l_position_flag ,
		      p_name,p_employee_number,p_error_flag           );
	    FND_MESSAGE.SET_NAME('PSB', 'PSB_VAL_NO_DEFAULT_WEEK_HOURS');
	    FND_MSG_PUB.Add;
	 end if;

      end if;

      --++ then check if there are distributions within the salary date range comp_date

      VALIDATE_DISTRIBUTION(
			p_position_id      => p_position_id,
			p_worksheet_id     => p_worksheet_id,
			p_name             => p_name,
			p_employee_number  => p_employee_number,
			p_position_flag    => l_position_flag,
			p_data_extract_id  => p_data_extract_id,
			p_root_budget_group_id  => p_root_budget_group_id,
			p_set_of_books_id       => p_set_of_books_id,
			p_budget_calendar_id    => p_budget_calendar_id,
			p_chart_of_accounts_id  => p_chart_of_accounts_id,
			p_startdate_pp          => p_startdate_pp,
			p_enddate_cy            => p_enddate_cy,
			p_effective_start_date  => l_salary_start_date,
			p_effective_end_date    => l_salary_end_date,
			p_error_flag            => p_error_flag,
			p_return_status         => l_return_status);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 raise FND_API.G_EXC_ERROR ;
      end if ;

  end loop; -- end salary_rec


   IF NOT FND_API.to_Boolean(l_salary_exists)  THEN

      SET_POS_HEADING(l_position_flag ,
	p_name,p_employee_number,p_error_flag           );
      FND_MESSAGE.SET_NAME('PSB', 'PSB_VAL_MISSING_SALARY');
      FND_MSG_PUB.Add;
   END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR then

     p_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR then

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS then

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END IF;

END VALIDATE_POSITION;

/* -------------------------------------------------------------------- */

PROCEDURE VALIDATE_DISTRIBUTION
( p_position_id             IN NUMBER,
  p_worksheet_id            IN NUMBER,
  p_name                    IN VARCHAR2,
  p_employee_number         IN VARCHAR2,
  p_position_flag       IN OUT  NOCOPY VARCHAR2,
  p_data_extract_id         IN NUMBER,
  p_root_budget_group_id      IN NUMBER,
  p_set_of_books_id         IN NUMBER,
  p_budget_calendar_id      IN NUMBER,
  p_chart_of_accounts_id    IN NUMBER,
  p_startdate_pp            IN DATE,
  p_enddate_cy              IN DATE,
  p_effective_start_date    IN DATE,
  p_effective_end_date      IN DATE,
  p_error_flag          IN OUT  NOCOPY VARCHAR2,
  p_return_status          OUT  NOCOPY VARCHAR2
) IS

  l_api_name              CONSTANT VARCHAR2(30) := 'VALIDATE_DISTRIBUTION';
  l_return_status         VARCHAR2(1);
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(2000);
  --
  l_check_allowed_ret_status VARCHAR2(1);
  l_concat_segments       VARCHAR2(2000);
  l_out_budget_group_id   NUMBER;
  l_out_ccid              NUMBER;
  l_startdate_pp          DATE;
  l_enddate_cy            DATE;
  l_salary_distr_exists   VARCHAR2(1) := FND_API.G_FALSE;

  --

  CURSOR c_sum IS
     SELECT x_sum.sum_tot,x_sum.start_date
       FROM
      (SELECT SUM(distribution_percent) sum_tot ,
	      effective_start_date start_date
	 FROM psb_position_pay_distributions
	WHERE code_combination_id IS NOT NULL
	  AND worksheet_id is null
	  AND position_id  = p_position_id
	  AND (((effective_start_date <= p_effective_end_date)
	  AND (effective_end_date is null))
	  OR ((effective_start_date between p_effective_start_date and p_effective_end_date)
	  OR (effective_end_date between p_effective_start_date and p_effective_end_date)
	 OR ((effective_start_date < p_effective_start_date)
	 AND (effective_end_date > p_effective_end_date))))
       GROUP BY position_id,effective_start_date
      ) x_sum
      WHERE x_sum.sum_tot <> 100
     UNION
     SELECT x_sum.sum_tot,x_sum.start_date
       FROM
      (SELECT SUM(distribution_percent) sum_tot ,
	      effective_start_date start_date
	 FROM psb_position_pay_distributions
	WHERE code_combination_id IS NOT NULL
	  AND worksheet_id = p_worksheet_id
	  AND position_id  = p_position_id
	  AND (((effective_start_date <= p_effective_end_date)
	  AND (effective_end_date is null))
	  OR ((effective_start_date between p_effective_start_date and p_effective_end_date)
	  OR (effective_end_date between p_effective_start_date and p_effective_end_date)
	 OR ((effective_start_date < p_effective_start_date)
	 AND (effective_end_date > p_effective_end_date))))
       GROUP BY position_id,effective_start_date
      ) x_sum
      WHERE x_sum.sum_tot <> 100;

BEGIN

  FOR  l_s_distributions_rec IN c_sum
  LOOP

     SET_POS_HEADING(p_position_flag ,
			 p_name,p_employee_number,p_error_flag           );
     FND_MESSAGE.SET_NAME('PSB', 'PSB_VAL_INCOMPLETE_DISTR');
     FND_MSG_PUB.Add;

  END LOOP;

  --++

  FOR  l_distributions_rec IN

     (SELECT position_id,
	     code_combination_id
	     FROM psb_position_pay_distributions
	    WHERE position_id = p_position_id
	      AND code_combination_id IS NOT NULL
	 AND (((effective_start_date <= p_effective_end_date)
	  AND (effective_end_date is null))
	  OR ((effective_start_date between p_effective_start_date and p_effective_end_date)
	  OR (effective_end_date between p_effective_start_date and p_effective_end_date)
	 OR ((effective_start_date < p_effective_start_date)
	 AND (effective_end_date > p_effective_end_date))))

     )

     LOOP

     l_salary_distr_exists   := FND_API.G_TRUE; -- distribution exists

     l_concat_segments := FND_FLEX_EXT.Get_Segs(
		       application_short_name => 'SQLGL',
		       key_flex_code => 'GL#',
		       structure_number => p_chart_of_accounts_id,
		       combination_id => l_distributions_rec.code_combination_id
		       );
		       -- concatenated

     PSB_VALIDATE_ACCT_PVT.Validate_Account (
	    p_api_version                =>    1.0,
	    p_commit                     =>    FND_API.G_FALSE,
	    p_validation_level           =>    FND_API.G_VALID_LEVEL_FULL,
	    p_return_status              =>    l_return_status,
	    p_msg_count                  =>    l_msg_count,
	    p_msg_data                   =>    l_msg_data,
	    p_parent_budget_group_id     =>    p_root_budget_group_id,
	    p_startdate_pp               =>    p_startdate_pp,
	    p_enddate_cy                 =>    p_enddate_cy ,
	    p_set_of_books_id            =>    p_set_of_books_id,
	    p_flex_code                  =>    p_chart_of_accounts_id,
	    p_create_budget_account      =>    FND_API.G_FALSE,
	    p_worksheet_id               =>    p_worksheet_id,
	    p_in_ccid                    =>    l_distributions_rec.code_combination_id,
	    p_out_ccid                   =>    l_out_ccid,
	    p_budget_group_id            =>    l_out_budget_group_id
	    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS then

	 SET_POS_HEADING(p_position_flag ,
			 p_name,p_employee_number,p_error_flag           );
	 FND_MESSAGE.SET_NAME('PSB', 'PSB_VAL_CCID_NOTIN_BG');
	 FND_MESSAGE.SET_TOKEN('CCID', l_concat_segments);
	 FND_MSG_PUB.Add;

    ELSE
       -- validate in in account range
       -- ... next check if the budget group belongs to the worksheet's
       -- ... budget group's hierarchy
       -- ... call wrapper


	 l_check_allowed_ret_status:= PSB_POSITIONS_I_PVT.Check_Allowed
	   (
	    p_api_version                =>    1.0,
	    p_init_msg_list              =>    FND_API.G_FALSE,
	    p_validation_level           =>    FND_API.G_VALID_LEVEL_FULL,
	    p_msg_count                  =>    l_msg_count,
	    p_msg_data                   =>    l_msg_data,
	    p_worksheet_id               =>    p_worksheet_id,
	    p_position_budget_group_id   =>    l_out_budget_group_id
	    )   ;

       IF l_check_allowed_ret_status <> FND_API.G_TRUE THEN
	  SET_POS_HEADING(p_position_flag ,
			  p_name,p_employee_number,p_error_flag           );
	  FND_MESSAGE.SET_NAME('PSB', 'PSB_VAL_INVALID_CCID_IN_BG');
	  FND_MESSAGE.SET_TOKEN('CCID', l_concat_segments);
	  FND_MSG_PUB.Add;

       END IF;

  --
     END IF;


     END LOOP;

     IF NOT FND_API.to_Boolean(l_salary_distr_exists)  THEN
	SET_POS_HEADING(p_position_flag ,
		      p_name,p_employee_number,p_error_flag           );
	FND_MESSAGE.SET_NAME('PSB', 'PSB_VAL_MISSING_DISTRIBUTIONS');
	FND_MSG_PUB.Add;
     END IF;

  p_return_status := FND_API.G_RET_STS_SUCCESS;
 --
EXCEPTION

  WHEN FND_API.G_EXC_ERROR then

     p_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR then

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS then

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END IF;

END VALIDATE_DISTRIBUTION;

/* -------------------------------------------------------------------- */

PROCEDURE Output_Message_To_Table(p_worksheet_id IN NUMBER,
				  p_return_status OUT  NOCOPY VARCHAR2) AS

   l_api_name             CONSTANT VARCHAR2(30) := 'Output_Message_To_Table';
   l_reqid NUMBER;
   l_rep_req_id NUMBER;
   l_userid NUMBER;
   l_msg_count NUMBER;
   l_msg_buf varchar2(1000);

BEGIN


   delete from PSB_ERROR_MESSAGES
    where source_process = 'POSITION_WORKSHEET_EXCEPTION'
      and process_id = p_worksheet_id;

   l_reqid  := FND_GLOBAL.CONC_REQUEST_ID;
   l_userid := FND_GLOBAL.USER_ID;

   FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
			       p_data  => l_msg_buf );

   PSB_MESSAGE_S.Insert_Error ( p_source_process => 'POSITION_WORKSHEET_EXCEPTION',
				p_process_id     => p_worksheet_id,
				p_msg_count      => l_msg_count,
				p_msg_data       => l_msg_buf,
				p_desc_sequence  => FND_API.G_FALSE) ;

   -- initialize error message stack --
      FND_MSG_PUB.initialize;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

END  Output_Message_To_Table;

/* -------------------------------------------------------------------- */

PROCEDURE SET_POS_HEADING(
		     p_position_flag   IN OUT  NOCOPY VARCHAR2,
		     p_position_name   IN VARCHAR2,
		     p_employee_number IN VARCHAR2,
		     p_error_flag      IN OUT  NOCOPY VARCHAR2
) IS

BEGIN
   IF p_position_flag IS NULL THEN
      -- header
      p_position_flag := 'Y';
      FND_MESSAGE.SET_NAME('PSB', 'PSB_VAL_LINE');
      FND_MSG_PUB.Add;
      FND_MESSAGE.SET_NAME('PSB', 'PSB_VAL_POSITION');
      FND_MESSAGE.SET_TOKEN('NAME', p_position_name);
      FND_MESSAGE.SET_TOKEN('EMP', p_employee_number);
      FND_MSG_PUB.Add;
      FND_MESSAGE.SET_NAME('PSB', 'PSB_VAL_LINE');
      FND_MSG_PUB.Add;

   END IF;
   p_error_flag := FND_API.G_RET_STS_ERROR ;


END SET_POS_HEADING;


/* ------------------------------------------------------------------------- */

-- Check whether the Budget Group for a Position is allowed within a
-- Worksheet. This is invoked by the Worksheet Modification module when
-- creating new Positions

FUNCTION Rev_Check_Allowed
( p_api_version               IN  NUMBER,
  p_validation_level          IN  NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_startdate_pp              IN DATE,
  p_enddate_cy                IN DATE,
  p_worksheet_id              IN NUMBER,
  p_position_budget_group_id  IN  NUMBER
) RETURN VARCHAR2 IS

  l_api_name                  CONSTANT VARCHAR2(30) := 'Check_Allowed';
  l_api_version               CONSTANT NUMBER       := 1.0;

  l_budget_group_id           NUMBER;

  l_return_status             VARCHAR2(1) := FND_API.G_FALSE;

  cursor c_Allowed is
    select 'Valid'
      from PSB_BUDGET_GROUPS
     where budget_group_type = 'R'
       and (p_startdate_pp is null or effective_start_date <= p_startdate_pp)
       and (effective_end_date is null
	 or effective_end_date >= p_enddate_cy)
       and budget_group_id = p_position_budget_group_id
    start with budget_group_id = l_budget_group_id
   connect by prior budget_group_id = parent_budget_group_id;
  -- validation for budget revision that ccid belong to bg hierarchy
  -- pp date is position end date w/c may be null; cy date is pos start date

  cursor c_WS (Worksheet NUMBER) is
    select budget_group_id
      from PSB_BUDGET_REVISIONS
     where budget_revision_id = Worksheet;

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
    l_budget_group_id := c_WS_Rec.budget_group_id;
  end loop;

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

END Rev_Check_Allowed;

FUNCTION Get_Worksheet_ID RETURN NUMBER IS
  BEGIN
     Return g_Worksheet_ID;
  END Get_Worksheet_ID;

FUNCTION Get_Start_Date RETURN DATE IS
  BEGIN
     Return g_Start_Date;
  END Get_Start_Date;

FUNCTION Get_End_Date RETURN DATE IS
  BEGIN
     Return g_End_Date;
  END Get_End_Date;

FUNCTION Get_Select_Date RETURN DATE IS
  BEGIN
     Return g_Select_Date;
  END Get_Select_Date;


FUNCTION Get_Worksheet_Flag RETURN varchar2 IS
  BEGIN
     Return g_Worksheet_Flag;
  END Get_Worksheet_Flag;

/* ------------------------------------------------------------------------- */

-- Get Debug Information
FUNCTION get_debug RETURN VARCHAR2 IS
BEGIN
  return(g_dbug);
END get_debug;

/* ----------------------------------------------------------------------- */

/* Start Bug 3422919 */

FUNCTION get_employee_id
(
  p_data_extract_id       IN NUMBER,
  p_worksheet_id          IN NUMBER := NULL,
  p_position_id           IN NUMBER
) RETURN NUMBER IS

  l_emp_id            NUMBER;

BEGIN

IF 	p_worksheet_id IS NULL THEN

	SELECT 	emp.employee_id
        INTO  	l_emp_id
	FROM 	psb_employees emp, psb_position_assignments pavb
	WHERE 	pavb.position_id = p_position_id
	AND 	pavb.assignment_type = 'EMPLOYEE'
	AND 	emp.data_extract_id = p_data_extract_id
	AND 	emp.employee_id = pavb.employee_id
	AND 	rownum=1
	AND 	pavb.worksheet_id IS NULL
	ORDER BY pavb.effective_start_date DESC;

ELSE
        SELECT 	emp.employee_id
        INTO  	l_emp_id
	FROM  	psb_employees emp, psb_position_assignments pavb
	WHERE 	pavb.position_id = p_position_id
	AND   	pavb.assignment_type = 'EMPLOYEE'
	AND   	emp.data_extract_id = p_data_extract_id
	AND   	emp.employee_id = pavb.employee_id
	AND   	rownum=1
	AND   	(pavb.worksheet_id = p_worksheet_id
		OR pavb.worksheet_id IS NULL)
	ORDER BY pavb.effective_start_date DESC,
	      	NVL(pavb.worksheet_id,0) DESC;

END IF;

RETURN(l_emp_id);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     RETURN(NULL);
WHEN OTHERS THEN
     RETURN(NULL);

END get_employee_id;

FUNCTION get_employee_number
(
  p_data_extract_id       IN NUMBER,
  p_worksheet_id          IN NUMBER := NULL,
  p_position_id           IN NUMBER
) RETURN VARCHAR2 IS

  l_emp_number            VARCHAR2(240);

BEGIN

IF 	p_worksheet_id IS NULL THEN

	SELECT 	emp.employee_number
        INTO  	l_emp_number
	FROM 	psb_employees emp, psb_position_assignments pavb
	WHERE 	pavb.position_id = p_position_id
	AND 	pavb.assignment_type = 'EMPLOYEE'
	AND 	emp.data_extract_id = p_data_extract_id
	AND 	emp.employee_id = pavb.employee_id
	AND 	rownum=1
	AND 	pavb.worksheet_id IS NULL
	ORDER BY pavb.effective_start_date DESC;

ELSE
        SELECT 	emp.employee_number
        INTO  	l_emp_number
	FROM  	psb_employees emp, psb_position_assignments pavb
	WHERE 	pavb.position_id = p_position_id
	AND   	pavb.assignment_type = 'EMPLOYEE'
	AND   	emp.data_extract_id = p_data_extract_id
	AND   	emp.employee_id = pavb.employee_id
	AND   	rownum=1
	AND   	(pavb.worksheet_id = p_worksheet_id
		OR pavb.worksheet_id IS NULL)
	ORDER BY pavb.effective_start_date DESC,
	      	NVL(pavb.worksheet_id,0) DESC;

END IF;

RETURN(l_emp_number);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     RETURN(NULL);
WHEN OTHERS THEN
     RETURN(NULL);

END get_employee_number;


FUNCTION get_employee_name
(
  p_data_extract_id       IN NUMBER,
  p_worksheet_id          IN NUMBER := NULL,
  p_position_id           IN NUMBER
) RETURN VARCHAR2 IS

  l_emp_name            VARCHAR2(240);

BEGIN

IF	p_worksheet_id	IS NULL THEN

        SELECT 	emp.full_name
       	INTO  	l_emp_name
	FROM 	psb_employees emp, psb_position_assignments pavb
	WHERE 	pavb.position_id = p_position_id
	AND 	pavb.assignment_type = 'EMPLOYEE'
	AND 	emp.data_extract_id = p_data_extract_id
	AND 	emp.employee_id = pavb.employee_id
	AND 	rownum=1
	AND 	pavb.worksheet_id IS NULL
	ORDER BY pavb.effective_start_date DESC;

ELSE
        SELECT 	emp.full_name
       	INTO  	l_emp_name
	FROM  	psb_employees emp, psb_position_assignments pavb
	WHERE 	pavb.position_id = p_position_id
	AND   	pavb.assignment_type = 'EMPLOYEE'
	AND   	emp.data_extract_id = p_data_extract_id
	AND   	emp.employee_id = pavb.employee_id
	AND   	rownum=1
	AND   	(pavb.worksheet_id = p_worksheet_id
		OR pavb.worksheet_id IS NULL)
	ORDER BY pavb.effective_start_date DESC,
	      	NVL(pavb.worksheet_id,0) DESC;

END IF;

RETURN(l_emp_name);

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     RETURN(NULL);
WHEN OTHERS THEN
     RETURN(NULL);

END get_employee_name;


FUNCTION get_job_name
( p_data_extract_id       IN NUMBER,
  p_worksheet_id          IN NUMBER := NULL,
  p_position_id           IN NUMBER
) RETURN VARCHAR2 IS

  l_job_name            VARCHAR2(240);

BEGIN

IF 	p_worksheet_id	IS NULL THEN

	SELECT 	patv.attribute_value
       	INTO   	l_job_name
	FROM 	psb_attribute_values patv,
	        psb_position_assignments pava
	WHERE 	patv.attribute_value_id = pava.attribute_value_id
	AND 	pava.position_id = p_position_id
	AND 	patv.data_extract_id = p_data_extract_id
	AND 	rownum=1
	AND EXISTS
		(SELECT 1 FROM psb_attributes pat
		WHERE 	pat.attribute_id = pava.attribute_id
		AND 	pat.system_attribute_type = 'JOB_CLASS')
	AND 	pava.worksheet_id IS NULL
	ORDER BY pava.effective_start_date DESC;
ELSE

	SELECT patv.attribute_value
        INTO   l_job_name
	FROM   psb_attribute_values patv,
	       psb_position_assignments pava
	WHERE  patv.attribute_value_id = pava.attribute_value_id
	AND    pava.position_id = p_position_id
	AND    patv.data_extract_id = p_data_extract_id
	AND    rownum=1
	AND    exists (SELECT 1 from psb_attributes pat
                       WHERE pat.attribute_id = pava.attribute_id
		       AND pat.system_attribute_type = 'JOB_CLASS')
	AND 	(pava.worksheet_id = p_worksheet_id
		OR pava.worksheet_id IS NULL)
	ORDER BY pava.effective_start_date DESC,
		NVL(pava.worksheet_id,0) DESC;
END IF;

RETURN(l_job_name);

EXCEPTION
WHEN NO_DATA_FOUND THEN
     RETURN(NULL);
WHEN OTHERS THEN
     RETURN(NULL);

END get_job_name;

/* End Bug 3422919 */

/* Bug 1308558 Start */
-- new api created for applying the Element and Attribute
-- assignments to positions

PROCEDURE Apply_Position_Default_Rules
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status               OUT  NOCOPY     VARCHAR2,
  x_msg_count                   OUT  NOCOPY     NUMBER,
  x_msg_data                    OUT  NOCOPY     VARCHAR2,
  p_position_assignment_id      IN OUT  NOCOPY  NUMBER,
  p_data_extract_id             IN      NUMBER,
  p_position_id                 IN      NUMBER,
  p_assignment_type             IN      VARCHAR2,
  p_attribute_id                IN      NUMBER,
  p_attribute_value_id          IN      NUMBER,
  p_attribute_value             IN      VARCHAR2,
  p_pay_element_id              IN      NUMBER,
  p_pay_element_option_id       IN      NUMBER,
  p_effective_start_date        IN      DATE,
  p_effective_end_date          IN      DATE,
  p_element_value_type          IN      VARCHAR2,
  p_element_value               IN      NUMBER,
  p_currency_code               IN      VARCHAR2,
  p_pay_basis                   IN      VARCHAR2,
  p_employee_id                 IN      NUMBER,
  p_primary_employee_flag       IN      VARCHAR2,
  p_global_default_flag         IN      VARCHAR2,
  p_assignment_default_rule_id  IN      NUMBER,
  p_modify_flag                 IN      VARCHAR2,
  p_mode                        IN      VARCHAR2 := 'R' ,
  p_worksheet_id                IN      NUMBER
) IS

  l_api_name                    CONSTANT VARCHAR2(30) := 'Apply_Position_Default_Rules';
  l_api_version                 CONSTANT NUMBER       := 1.0 ;
  l_position_assignment_id      NUMBER;
  l_matching_assmt              BOOLEAN := FALSE;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(2000);
  l_rowid                       VARCHAR2(100);
  l_pay_basis                   VARCHAR2(10);
  l_pay_element_id              NUMBER;

  l_userid                      NUMBER;
  l_loginid                     NUMBER;
  l_pos_salary_flag             VARCHAR2(1) := 'N';
  l_def_salary_flag             VARCHAR2(1) := 'N';

  CURSOR l_salary IS
    SELECT salary_flag
      FROM PSB_PAY_ELEMENTS ppay
     WHERE ppay.pay_element_id = l_pay_element_id;


  CURSOR l_get_pay_basis IS
    SELECT pay_basis
      FROM psb_position_assignments past
     WHERE past.assignment_type = 'ELEMENT'
       AND past.position_id  = p_position_id
       AND past.pay_basis IS NOT NULL
       AND ROWNUM < 2;

  l_count           NUMBER;
  l_de_exists       BOOLEAN := FALSE;
  l_element_id  NUMBER;

  CURSOR l_exists IS SELECT assignment_type,pay_element_id
    FROM psb_position_assignments
   WHERE (((p_assignment_type = 'ELEMENT') AND (p_assignment_type = assignment_type))
      OR ((p_assignment_type = 'ATTRIBUTE')  AND (attribute_id = p_attribute_id))
      OR ((p_assignment_type = 'EMPLOYEE')   AND (employee_id = p_employee_id)))
     AND data_extract_id = p_data_extract_id
     AND position_id     = p_position_id and worksheet_id IS NULL;

  CURSOR l_element IS SELECT pay_element_id,salary_flag
    FROM psb_pay_elements
   WHERE pay_element_id = l_element_id;


BEGIN
  SAVEPOINT Apply_Position_Default_Rules;

  l_userid  := FND_GLOBAL.USER_ID;
  l_loginid := FND_GLOBAL.LOGIN_ID;

  /*Bug:5473134: Moved the initialization of l_pay_basis to the beginning
    of the procedure as, for Non-Overwrite Rules, this initialization is skipped.*/
  l_pay_basis := p_pay_basis;  -- Bug:5473134

  IF p_assignment_type = 'ELEMENT' THEN
    l_pay_element_id := p_pay_element_id;

    FOR l_Salary_Rec IN l_Salary
    LOOP
      l_def_salary_flag := l_Salary_Rec.salary_flag;
    END LOOP;
  END IF;

  /* Bug 4545909 Start */
  FOR l_exists_rec IN l_exists
  LOOP
    IF l_exists_rec.assignment_type = 'ELEMENT' THEN
      l_element_id  :=  l_exists_rec.pay_element_id;
      FOR l_element_rec in l_element
      LOOP
        IF l_element_rec.salary_flag = 'Y' and p_pay_basis IS NOT NULL THEN
          l_de_exists := TRUE;
        ELSIF l_element_rec.pay_element_id = p_pay_element_id THEN
          l_de_exists := TRUE;
        END IF;
      END LOOP;
    ELSE
      l_de_exists := TRUE;
    END IF;
  END LOOP;
  /* Bug 4545909 End */

  -- following code processes overwrite default rules.
  IF p_modify_flag = 'Y' THEN
  -- bug 5002080 changed the set clause for modify_flag below
  UPDATE PSB_POSITION_ASSIGNMENTS
     SET attribute_value_id = DECODE(p_attribute_value_id, NULL, attribute_value_id, p_attribute_value_id),
	 attribute_value = DECODE(p_attribute_value, NULL, attribute_value, p_attribute_value),
	 pay_element_option_id = DECODE(p_pay_element_option_id, NULL, pay_element_option_id, p_pay_element_option_id),
	 element_value_type = DECODE(p_element_value_type, NULL, element_value_type, p_element_value_type),
	 element_value = DECODE(p_element_value, NULL, element_value, p_element_value),
	 currency_code = DECODE(p_currency_code, NULL, currency_code, p_currency_code),
	 pay_basis = DECODE(p_pay_basis, NULL, pay_basis, p_pay_basis),
	 primary_employee_flag = DECODE(p_primary_employee_flag, NULL, primary_employee_flag, p_primary_employee_flag),
	 global_default_flag = DECODE(p_global_default_flag, NULL, global_default_flag, p_global_default_flag),
	 assignment_default_rule_id = DECODE(p_assignment_default_rule_id, NULL, assignment_default_rule_id, p_assignment_default_rule_id),
	 modify_flag = DECODE(p_modify_flag, NULL, modify_flag, 'Y'),
	 last_update_date = SYSDATE,
	 last_updated_by = l_userid,
	 last_update_login = l_loginid
   WHERE (((p_assignment_type = 'ELEMENT')   AND (pay_element_id = p_pay_element_id))
      OR ((p_assignment_type = 'ATTRIBUTE') AND (attribute_id = p_attribute_id))
      OR ((p_assignment_type = 'EMPLOYEE')  AND (employee_id = p_employee_id)))
      AND data_extract_id = p_data_extract_id
      AND position_id     = p_position_id
      AND (worksheet_id   = p_worksheet_id OR (worksheet_id IS NULL AND p_worksheet_id IS NULL)); -- bug 4545909


  IF SQL%NOTFOUND THEN




    IF p_assignment_type = 'ELEMENT' THEN


      IF (l_def_salary_flag = 'Y') THEN

        FOR l_assignment_rec IN (SELECT past.position_assignment_id
                                   FROM psb_position_assignments past ,
                                                psb_pay_elements ppay
          WHERE past.data_extract_id  = p_data_extract_id
            AND ((worksheet_id IS NULL AND p_worksheet_id IS NULL)
                     OR worksheet_id = p_worksheet_id)
            AND past.position_id      = p_position_id
            AND past.pay_element_id   = ppay.pay_element_id
            AND past.assignment_type  = 'ELEMENT'
            AND ppay.salary_flag       = 'Y'
            AND(((p_effective_end_date IS NOT NULL)
            AND (((past.effective_start_date <= p_effective_end_date)
            AND (past.effective_end_date IS NULL))
             OR ((past.effective_start_date BETWEEN p_effective_start_date AND p_effective_end_date)
             OR (past.effective_end_date BETWEEN p_effective_start_date AND p_effective_end_date)
             OR ((past.effective_start_date < p_effective_start_date)
            AND (past.effective_end_date > p_effective_end_date)))))
             OR ((p_effective_end_date IS NULL)
            AND (NVL(past.effective_end_date, p_effective_start_date) >= p_effective_start_date)))
            )
        LOOP

          PSB_POSITION_ASSIGNMENTS_PVT.delete_row
           (p_api_version => 1.0,
	    p_return_status => l_return_status,
	    p_msg_count => l_msg_count,
	    p_msg_data => l_msg_data,
            p_position_assignment_id => l_assignment_rec.position_assignment_id );
        END LOOP;


        IF (p_pay_basis IS NULL) THEN

          FOR  l_Get_Pay_Basis_Rec IN l_Get_Pay_Basis LOOP
            l_pay_basis := l_Get_Pay_Basis_Rec.pay_basis;
          END LOOP;

        END IF;

      END IF;
    END IF;

    -- Bug 4545909 added the following IF clause
    -- the first insert_row call create the worksheet specific record
    -- the second insert_row call create the extract specific record
    IF l_de_exists THEN

      PSB_POSITION_ASSIGNMENTS_PVT.Insert_Row
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_rowid => l_rowid,
	      p_position_assignment_id => l_position_assignment_id,
	      p_data_extract_id => p_data_extract_id,
	      p_worksheet_id => p_worksheet_id,
	      p_position_id => p_position_id,
	      p_assignment_type => p_assignment_type,
              p_attribute_id => p_attribute_id,
	      p_attribute_value_id => p_attribute_value_id,
	      p_attribute_value => p_attribute_value,
	      p_pay_element_id => p_pay_element_id,
	      p_pay_element_option_id => p_pay_element_option_id,
	      p_effective_start_date => p_effective_start_date,
	      p_effective_end_date => p_effective_end_date,
	      p_element_value_type => p_element_value_type,
	      p_element_value => p_element_value,
	      p_currency_code => p_currency_code,
	      p_pay_basis  => l_pay_basis,
	      p_employee_id => p_employee_id,
	      p_primary_employee_flag => p_primary_employee_flag,
	      p_global_default_flag => p_global_default_flag,
	      p_assignment_default_rule_id => p_assignment_default_rule_id,
	      p_modify_flag => p_modify_flag,
	      p_mode => p_mode);

	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	    END IF;

    ELSE

      PSB_POSITION_ASSIGNMENTS_PVT.Insert_Row
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_rowid => l_rowid,
	      p_position_assignment_id => l_position_assignment_id,
	      p_data_extract_id => p_data_extract_id,
	      p_worksheet_id => NULL,
	      p_position_id => p_position_id,
	      p_assignment_type => p_assignment_type,
	      p_attribute_id => p_attribute_id,
	      p_attribute_value_id => p_attribute_value_id,
	      p_attribute_value => p_attribute_value,
	      p_pay_element_id => p_pay_element_id,
	      p_pay_element_option_id => p_pay_element_option_id,
	      p_effective_start_date => p_effective_start_date,
	      p_effective_end_date => p_effective_end_date,
	      p_element_value_type => p_element_value_type,
	      p_element_value => p_element_value,
	      p_currency_code => p_currency_code,
	      p_pay_basis  => l_pay_basis,
	      p_employee_id => p_employee_id,
	      p_primary_employee_flag => p_primary_employee_flag,
	      p_global_default_flag => p_global_default_flag,
	      p_assignment_default_rule_id => p_assignment_default_rule_id,
	      p_modify_flag => p_modify_flag,
	      p_mode => p_mode);

	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	    END IF;
    END IF;

  END IF;

  ELSE

    l_matching_assmt := FALSE;

    FOR l_pos_assignment_rec IN( SELECT *
                                       FROM psb_position_assignments past
         WHERE past.data_extract_id = p_data_extract_id
           AND past.position_id     = p_position_id
           AND ((worksheet_id IS NULL AND NOT EXISTS
               (SELECT 1 FROM psb_position_assignments ppa
                 WHERE ppa.worksheet_id  = p_worksheet_id
                   AND ppa.position_id   = p_position_id AND
       (p_assignment_type = 'ATTRIBUTE' AND past.attribute_id = ppa.attribute_id) OR
       (p_assignment_type = 'ELEMENT'   AND past.pay_element_id = ppa.pay_element_id)))
                    OR  worksheet_id = p_worksheet_id
                    OR (worksheet_id IS NULL AND p_worksheet_id IS NULL))
           AND (((p_effective_end_date IS NOT NULL)
           AND (((past.effective_start_date <= p_effective_end_date)
           AND (past.effective_end_date IS NULL))
            OR ((past.effective_start_date BETWEEN p_effective_start_date AND p_effective_end_date)
            OR (past.effective_end_date BETWEEN p_effective_start_date AND p_effective_end_date)
            OR ((past.effective_start_date < p_effective_start_date)
           AND (past.effective_end_date > p_effective_end_date)))))
            OR ((p_effective_end_date IS NULL)
           AND (NVL(past.effective_end_date, p_effective_start_date) >= p_effective_start_date)))
                 )

    LOOP
      l_pos_salary_flag := 'N';

    IF l_pos_assignment_rec.assignment_type = 'ELEMENT' THEN

      l_pay_element_id := l_pos_assignment_rec.pay_element_id;

      FOR l_Salary_Rec IN l_Salary
      LOOP
        l_pos_salary_flag := l_Salary_Rec.salary_flag;
      END LOOP;
    END IF;



    IF (p_assignment_type = 'ATTRIBUTE' AND p_attribute_id = l_pos_assignment_rec.attribute_id) OR
       (p_assignment_type = 'ELEMENT' AND p_pay_element_id = l_pos_assignment_rec.pay_element_id) OR
       (p_assignment_type = 'ELEMENT' AND p_assignment_type = l_pos_assignment_rec.assignment_type
        AND l_pos_salary_flag= 'Y' AND l_def_salary_flag= 'Y')  THEN


      l_matching_assmt := TRUE;

    END IF;

    END LOOP;


    IF l_matching_assmt <> TRUE THEN

    -- Bug 4545909. added the following IF clause
    IF l_de_exists THEN
        PSB_POSITION_ASSIGNMENTS_PVT.Insert_Row
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_rowid => l_rowid,
	      p_position_assignment_id => l_position_assignment_id,
	      p_data_extract_id => p_data_extract_id,
	      p_worksheet_id => p_worksheet_id,
	      p_position_id => p_position_id,
	      p_assignment_type => p_assignment_type,
	      p_attribute_id => p_attribute_id,
	      p_attribute_value_id => p_attribute_value_id,
	      p_attribute_value => p_attribute_value,
	      p_pay_element_id => p_pay_element_id,
	      p_pay_element_option_id => p_pay_element_option_id,
	      p_effective_start_date => p_effective_start_date,
	      p_effective_end_date => p_effective_end_date,
	      p_element_value_type => p_element_value_type,
	      p_element_value => p_element_value,
	      p_currency_code => p_currency_code,
	      p_pay_basis  => l_pay_basis,
	      p_employee_id => p_employee_id,
	      p_primary_employee_flag => p_primary_employee_flag,
	      p_global_default_flag => p_global_default_flag,
	      p_assignment_default_rule_id => p_assignment_default_rule_id,
	      -- p_modify_flag => p_modify_flag,
              p_modify_flag => 'Y', -- bug 5002080
	      p_mode => p_mode);
    ELSE
        PSB_POSITION_ASSIGNMENTS_PVT.Insert_Row
	     (p_api_version => 1.0,
	      p_return_status => l_return_status,
	      p_msg_count => l_msg_count,
	      p_msg_data => l_msg_data,
	      p_rowid => l_rowid,
	      p_position_assignment_id => l_position_assignment_id,
	      p_data_extract_id => p_data_extract_id,
	      p_worksheet_id => NULL,
	      p_position_id => p_position_id,
	      p_assignment_type => p_assignment_type,
	      p_attribute_id => p_attribute_id,
	      p_attribute_value_id => p_attribute_value_id,
	      p_attribute_value => p_attribute_value,
	      p_pay_element_id => p_pay_element_id,
	      p_pay_element_option_id => p_pay_element_option_id,
	      p_effective_start_date => p_effective_start_date,
	      p_effective_end_date => p_effective_end_date,
	      p_element_value_type => p_element_value_type,
	      p_element_value => p_element_value,
	      p_currency_code => p_currency_code,
	      p_pay_basis  => l_pay_basis,
	      p_employee_id => p_employee_id,
	      p_primary_employee_flag => p_primary_employee_flag,
	      p_global_default_flag => p_global_default_flag,
	      p_assignment_default_rule_id => p_assignment_default_rule_id,
	      -- p_modify_flag => p_modify_flag,
              p_modify_flag => 'Y', -- bug 5002080
	      p_mode => p_mode);
    END IF;

    END IF;

  END IF;

    /*Bug:5940448:start*/

     /*Api - PSB_BUDGET_POSITION_PVT.Add_Position_To_Position_Sets is called for
       assignment type - 'ATTRIBUTE'. This is because, position sets may
       get affected due to the default rules which changes the 'Attribute assignments' */

	if p_assignment_type = 'ATTRIBUTE' then

           PSB_BUDGET_POSITION_PVT.Add_Position_To_Position_Sets
            (p_api_version => 1.0,
             p_return_status => l_return_status,
             p_msg_count => l_msg_count,
             p_msg_data => l_msg_data,
             p_position_id => p_position_id,
    	     p_worksheet_id => p_worksheet_id,
             p_data_extract_id => p_data_extract_id
            );

           if l_return_status <> FND_API.G_RET_STS_SUCCESS then
             raise FND_API.G_EXC_ERROR;
           end if;
	end if;

   /*Bug:5940448:end*/

  IF FND_API.to_Boolean (p_commit) THEN
    COMMIT WORK;
  END IF;


  -- Initialize API return status to success

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Standard call to get message count and if count is 1, get message info

  FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
			     p_data  => x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Apply_Position_Default_Rules;
     x_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Apply_Position_Default_Rules;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO Apply_Position_Default_Rules;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
				p_data  => x_msg_data);

End Apply_Position_Default_Rules;
/* Bug 1308558 End */


END PSB_POSITIONS_PVT ;

/
