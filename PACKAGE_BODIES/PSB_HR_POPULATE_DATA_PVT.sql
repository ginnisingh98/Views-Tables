--------------------------------------------------------
--  DDL for Package Body PSB_HR_POPULATE_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_HR_POPULATE_DATA_PVT" AS
/* $Header: PSBVHRPB.pls 120.43.12010000.7 2010/04/30 14:11:07 rkotha ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'PSB_HR_POPULATE_DATA_PVT';
  g_dbug      VARCHAR2(15000);

  TYPE g_glcostmap_rec_type IS RECORD
	(gl_account_segment      VARCHAR2(30),
	payroll_cost_segment    VARCHAR2(30));

  TYPE g_glcostmap_tbl_type IS TABLE OF g_glcostmap_rec_type
  INDEX BY BINARY_INTEGER;

 -- de by org
 TYPE g_org_status_tbl_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

 g_org_status g_org_status_tbl_type;

  PROCEDURE Create_Salary_Distributions
  (p_return_status       OUT  NOCOPY  VARCHAR2,
   p_data_extract_id     IN   NUMBER,
   p_extract_method      IN   VARCHAR2,
   p_restart_position_id IN   NUMBER,
   -- de by org
   p_extract_by_org      IN   VARCHAR2
  );

  PROCEDURE Create_Salary_Dist_Pos
  ( p_return_status        OUT  NOCOPY  VARCHAR2,
    p_data_extract_id      IN   NUMBER,
    p_position_id          IN   NUMBER,
    p_position_start_DATE  IN   DATE,
    p_position_END_DATE    IN   DATE
  );

  FUNCTION check_vacancy(p_position_id in NUMBER,
			 p_data_extract_id in NUMBER)
  RETURN VARCHAR2;


 PROCEDURE Populate_Salary_Assignments
 ( p_return_status       OUT  NOCOPY VARCHAR2,
   p_position_id         in  NUMBER,
   p_date_effective      in  DATE,
   p_date_end            in  DATE,
   p_data_extract_id     in  NUMBER,
   p_business_group_id   in  NUMBER,
   p_set_of_books_id     in  NUMBER,
   p_entry_grade_rule_id in  NUMBER,
   p_entry_step_id       in  NUMBER := FND_API.G_MISS_NUM,
   p_entry_grade_id      in  NUMBER,
   p_pay_basis_id        in  NUMBER);

 PROCEDURE Update_Worksheet_Values
 ( p_return_status            OUT  NOCOPY  VARCHAR2,
   p_position_id               in  NUMBER ,
   p_org_id                    in  NUMBER);

 -- de by org
 PROCEDURE Cache_Org_Status
 ( p_return_status          OUT NOCOPY VARCHAR2,
   p_data_extract_id        IN         NUMBER,
   p_extract_by_org         IN         VARCHAR2);
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                             PROCEDURE pd                                  |
 +===========================================================================*/
-- API to print debug information used during only development.
PROCEDURE pd( p_message   IN     VARCHAR2)
IS
BEGIN
  NULL ;
  --DBMS_OUTPUT.Put_Line(p_message) ;
END pd ;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                          PROCEDURE Process_Exception                      |
 +===========================================================================*/
-- Bug#3109841: Added to return error message as per HR forms requirements.
PROCEDURE Process_Exception ( p_api_name   IN     VARCHAR2)
IS
  l_msg_count              NUMBER ;
  l_msg_data               VARCHAR2(1000) ;
BEGIN
  --
  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME ,
                              p_api_name ) ;
  END IF;
  --
  FND_MSG_PUB.Get( p_msg_index     => 1               ,
                   p_encoded       => FND_API.G_FALSE ,
                   p_data          => l_msg_data      ,
                   p_msg_index_out => l_msg_count
                 ) ;
  --
  FND_MESSAGE.SET_NAME ('PSB',    'PSB_DEBUG_MESSAGE') ;
  FND_MESSAGE.SET_TOKEN('MESSAGE', l_msg_data ) ;
  FND_MESSAGE.RAISE_ERROR;
  --
END Process_Exception ;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
-- de by org
--
-- This Procedure caches the status of all the organizations selected for a
-- data extract run when extract by org flag is enabled. If extract by org
-- is not enabled it caches the statuses of all organizations pertaining to the
-- Business Group
--
PROCEDURE Cache_Org_Status
( p_return_status           OUT NOCOPY    VARCHAR2,
  p_data_extract_id         IN  NUMBER,
  p_extract_by_org          IN  VARCHAR2)
AS

 Cursor C_org_status is
  SELECT organization_id,
         decode(completion_status,'C','REFRESH','CREATE') extract_method
    FROM psb_data_extract_orgs
   WHERE data_extract_id = p_data_extract_id
     AND (p_extract_by_org = 'N'
      OR (p_extract_by_org = 'Y' AND select_flag = 'Y'));

 TYPE l_org_status_tbl_type IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
 l_org_status l_org_status_tbl_type;


 TYPE l_organization_id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 l_organization_id l_organization_id_tbl_type;

 i BINARY_INTEGER;

BEGIN

-- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

   Open C_org_Status;
   Fetch C_org_Status BULK collect into
   l_organization_id,l_org_status;
   Close C_org_status;

   FOR i in l_organization_id.first..l_organization_id.last LOOP
     g_org_status(l_organization_id(i)) := l_org_status(i);
   END LOOP;

EXCEPTION

WHEN OTHERS THEN
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END cache_org_status;

PROCEDURE set_global(g_var_name IN VARCHAR2,
		     g_var_value IN VARCHAR2)
AS
Begin
  if (g_var_name = 'G_PSB_BUDGET_GROUP_ID') then
     g_psb_budget_group_id := to_number(g_var_value);
  elsif (g_var_name = 'G_PSB_WORKSHEET_ID') then
     g_psb_worksheet_id := to_number(g_var_value);
  elsif (g_var_name = 'G_PSB_DATA_EXTRACT_ID') then
     g_psb_data_extract_id := to_number(g_var_value);
  elsif (g_var_name = 'G_PSB_BUSINESS_GROUP_ID') then
     g_psb_business_group_id := to_number(g_var_value);
  elsif (g_var_name = 'G_PSB_CURRENT_FORM') then
     g_psb_current_form := g_var_value;
  elsif (g_var_name = 'G_PSB_APPLICATION_ID') then
     g_psb_application_id := to_number(g_var_value);
  elsif (g_var_name = 'G_PSB_ORG_ID') then
     g_psb_org_id := to_number(g_var_value);
  elsif (g_var_name = 'G_PSB_REVISION_START_DATE') then
     g_psb_revision_start_date := fnd_date.chardate_to_date(g_var_value) ;
  elsif (g_var_name = 'G_PSB_REVISION_END_DATE') then
     g_psb_revision_end_date := fnd_date.chardate_to_date(g_var_value) ;
  end if;
END set_global;

Function get_global(g_var_name IN VARCHAR2) return varchar2
AS
Begin
  if (g_var_name = 'G_PSB_BUDGET_GROUP_ID') then
     return to_char(g_psb_budget_group_id) ;
  elsif (g_var_name = 'G_PSB_WORKSHEET_ID') then
     return to_char(g_psb_worksheet_id) ;
  elsif (g_var_name = 'G_PSB_DATA_EXTRACT_ID') then
     return to_char(g_psb_data_extract_id);
  elsif (g_var_name = 'G_PSB_BUSINESS_GROUP_ID') then
     return to_char(g_psb_business_group_id) ;
  elsif (g_var_name = 'G_PSB_CURRENT_FORM') then
     return g_psb_current_form ;
  elsif (g_var_name = 'G_PSB_APPLICATION_ID') then
     return g_psb_application_id ;
  elsif (g_var_name = 'G_PSB_ORG_ID') then
     return g_psb_org_id ;
  elsif (g_var_name = 'G_PSB_REVISION_START_DATE') then
     return g_psb_revision_start_date ;
  elsif (g_var_name = 'G_PSB_REVISION_END_DATE') then
     return g_psb_revision_end_date ;
  end if;

END get_global;

PROCEDURE Populate_Salary_Assignments
( p_return_status       OUT  NOCOPY VARCHAR2,
  p_position_id         in  NUMBER,
  p_date_effective      in  DATE,
  p_date_end            in  DATE,
  p_data_extract_id     in  NUMBER,
  p_business_group_id   in  NUMBER,
  p_set_of_books_id     in  NUMBER,
  p_entry_grade_rule_id in  NUMBER,
  p_entry_step_id       in  NUMBER := FND_API.G_MISS_NUM,
  p_entry_grade_id      in  NUMBER,
  p_pay_basis_id        in  NUMBER)
IS
   --
   -- Variables for retrieving salary details of a position
   --
  l_rowid               VARCHAR2(100);
  l_grade_rule_id       number;
  l_grade_id_flex_num   number;
  l_step_id             number;
  l_salary_type         varchar2(15);
  l_rate_type           varchar2(10);
  l_rate_or_payscale_id number;
  l_grade_step          number;
  l_grade_spine_id      number;
  l_pay_basis_id        number;
  l_pay_basis           varchar2(30);
  l_sequence            number;
  l_value               number;
  l_session_date        date;
  l_grade_or_spinal_point_id number;
  l_rate_or_payscale_name varchar2(30);
  l_grade_id            number;
  l_grade_name          varchar2(80);

  l_position_assignment_id number := 0;
  l_pay_element_id         number;
  l_pay_element_option_id  number;
  l_pay_element_rate_id    number;
  l_currency_code          varchar2(30) := '';
  l_return_status          varchar2(1);
  l_msg_count              number;
  l_msg_data               varchar2(1000);
  l_msg                    varchar2(2000);
  -- dynamic sql
 /* l_sql_stmt                varchar2(500);
  TYPE C_gradeCurTyp IS REF CURSOR;
  c_grade_cv    C_gradeCurTyp; */


  Cursor C_session is
    SELECT effective_date
      FROM FND_SESSIONS
     WHERE session_id = USERENV('sessionid');

  Cursor C_grade_spine is
     SELECT grade_spine_id
	  FROM per_spinal_point_steps
	 WHERE step_id = p_entry_step_id;

  Cursor C_Pay_Grade is
    SELECT effective_start_date,
	   effective_end_date,
	   rate_id,
	   grade_or_spinal_point_id,
	   rate_type,
	   maximum,
	   mid_value,
	   minimum,
	   sequence,
	   value
      FROM PAY_GRADE_RULES
     WHERE business_group_id = p_business_group_id
       AND grade_rule_id     = p_entry_grade_rule_id;

  Cursor  C_payscale is
    SELECT parent_spine_id
      FROM PER_SPINAL_POINTS
     WHERE spinal_point_id = l_grade_or_spinal_point_id
       AND business_group_id = p_business_group_id;

  Cursor C_pay_basis is
    SELECT pay_basis
      FROM PER_PAY_BASES
     WHERE pay_basis_id = p_pay_basis_id;

  Cursor  C_payname is
     SELECT name
       FROM PER_PARENT_SPINES
      WHERE parent_spine_id = l_rate_or_payscale_id
	AND business_group_id = p_business_group_id;

  Cursor C_rate is
      SELECT name
	FROM PAY_RATES
       WHERE rate_id = l_rate_or_payscale_id;

  Cursor C_flex_num is
	select grade_structure
	  from per_business_groups
	 where business_group_id = p_business_group_id;

  Cursor C_Currency is
     Select currency_code
       from gl_sets_of_books
      where set_of_books_id = p_set_of_books_id;

  Cursor C_grade is
     SELECT grade_id,name
       FROM PER_GRADES
      WHERE grade_id = p_entry_grade_id
	AND business_group_id = p_business_group_id;

  Cursor C_pay_elements_step IS
     Select ppe.pay_element_id ,ppe.salary_type,
	    ppo.pay_element_option_id
       FROM psb_pay_elements ppe,
	    psb_pay_element_options ppo
      WHERE ppe.data_extract_id = p_data_extract_id
	AND ppe.salary_type     = 'STEP'
	AND ppe.name            = l_rate_or_payscale_name
	AND ppe.pay_element_id  = ppo.pay_element_id
	AND ppo.name            = l_grade_name
	AND ppo.grade_step      = l_grade_step
	AND ppo.sequence_number = l_sequence;

  Cursor C_pay_elements_rate IS
     Select ppe.pay_element_id ,ppe.salary_type,
	    ppo.pay_element_option_id
       FROM psb_pay_elements ppe,
	    psb_pay_element_options ppo
      WHERE ppe.data_extract_id = p_data_extract_id
	AND ppe.salary_type     = 'RATE'
	AND ppe.name            = l_rate_or_payscale_name
	AND ppe.pay_element_id  = ppo.pay_element_id
	AND ppo.name            = l_grade_name;

  Cursor C_pay_element_rates IS
     Select pay_element_rate_id,
	    effective_start_DATE,
	    effective_END_DATE,
	    element_value,
	    currency_code
       FROM psb_pay_element_rates
      WHERE pay_element_id        = l_pay_element_id
	AND pay_element_option_id = l_pay_element_option_id;

  l_last_update_date    DATE;
  l_last_updated_BY     number;
  l_last_update_login   number;
  l_creation_date       DATE;
  l_created_by          number;

BEGIN
  /* Bug 4222417 Start */
  l_last_update_date  := SYSDATE;
  l_last_updated_BY   := FND_GLOBAL.USER_ID;
  l_last_update_login := FND_GLOBAL.LOGIN_ID;
  l_creation_date     := SYSDATE;
  l_created_by        := FND_GLOBAL.USER_ID;
  /* Bug 4222417 End */

   --hr_utility.trace_on;
   hr_utility.set_location(' Inside Salary Assignment',333);

   For C_flex_rec in C_flex_num
   Loop
     l_grade_id_flex_num := C_flex_rec.grade_structure;
   End Loop;

   hr_utility.set_location(' date_effective XX '||p_date_effective,333);
   hr_utility.set_location(' date_end XX '||p_date_end,333);
   hr_utility.set_location(' dtxid XX '||p_data_extract_id,333);
   hr_utility.set_location(' bSid XX '||p_business_group_id,333);
   hr_utility.set_location(' sob XX '||p_set_of_books_id,333);
   hr_utility.set_location(' entry grade rule XX '||p_entry_grade_rule_id,333);
   hr_utility.set_location(' step XX '||p_entry_step_id,333);
   hr_utility.set_location(' grade id XX '||p_entry_grade_id,333);
   hr_utility.set_location(' pay basis XX '||p_pay_basis_id,333);
   hr_utility.set_location(' -----------------------------',333);

   For C_Pay_Grade_Rec in C_Pay_Grade
   Loop

     l_rate_type := C_Pay_Grade_Rec.rate_type;
     For C_Grade_Rec in C_Grade
     Loop
       l_grade_id   := C_Grade_Rec.grade_id;
       l_grade_name := C_Grade_Rec.name;
     End Loop;

    --+ grade name using dynamic sql
   /* l_sql_stmt :=
	 'SELECT pg.grade_id,pgv.concatenated_segments '||
	 '  FROM PER_GRADES pg,PER_GRADE_DEFINITIONS_KFV pgv ' ||
	 ' WHERE pg.grade_id =  ' || p_entry_grade_id ||
	 '   AND pg.business_group_id = ' || p_business_group_id ||
	 '   AND pg.grade_definition_id = pgv.grade_definition_id ' ||
	 '   AND pgv.id_flex_num        = ' || l_grade_id_flex_num   ;
     OPEN c_grade_cv FOR l_sql_stmt;
     LOOP
       FETCH c_grade_cv into l_grade_id,l_grade_name ;
       EXIT WHEN c_grade_cv%NOTFOUND;
     END LOOP;
     CLOSE c_grade_cv;  */

     hr_utility.set_location(' cursor grade name '||l_grade_name,335);

     For C_pay_basis_rec in C_pay_basis
     Loop
       l_pay_basis := C_pay_basis_rec.pay_basis;
     End Loop;

     hr_utility.set_location(' pay basis '||l_pay_basis ||
			     ' ratetype ' || l_rate_type,336);

     if (l_rate_type = 'G') then
	l_rate_or_payscale_id := C_Pay_Grade_Rec.rate_id;
	l_value     := fnd_number.canonical_to_number(C_Pay_Grade_Rec.value);
	l_salary_type         := 'RATE';

	hr_utility.set_location(' payscale '||l_rate_or_payscale_id,335);
	For C_Rate_Rec in C_Rate
	Loop
	  l_rate_or_payscale_name := C_Rate_Rec.name;
	  hr_utility.set_location(' Inside ZZ2 '||l_rate_or_payscale_id,335);
	End Loop;

	FOR C_pay_elements_rate_rec in C_pay_elements_rate
	LOOP
	 l_pay_element_id        := C_pay_elements_rate_rec.pay_element_id;
	 l_salary_type           := C_pay_elements_rate_rec.salary_type;
	 l_pay_element_option_id := C_pay_elements_rate_rec.pay_element_option_id;
	END LOOP;

     else
	l_grade_or_spinal_point_id := C_Pay_Grade_Rec.grade_or_spinal_point_id;
	l_sequence := C_Pay_Grade_Rec.sequence;
	l_value := fnd_number.canonical_to_number( C_Pay_Grade_Rec.value);
	l_salary_type := 'STEP';

	For C_grade_spine_rec in C_grade_spine
	Loop
	  l_grade_spine_id := C_grade_spine_rec.grade_spine_id;
	End Loop;

	For C_session_rec in C_session
	Loop
	  l_session_date := C_session_rec.effective_date;
	end Loop;

	hr_utility.set_location('  ZZ9 session date '||l_session_date ,336);
	per_spinal_point_steps_pkg.pop_flds(l_grade_step,
					    l_session_date,
					    l_grade_or_spinal_point_id,
					    l_grade_spine_id);

	hr_utility.set_location('  after pop_flds ' ,336);
	For C_Payscale_rec in C_Payscale
	Loop
	  l_rate_or_payscale_id := C_Payscale_rec.parent_spine_id;
	End Loop;

	FOR C_Payname_Rec in C_Payname
	LOOP
	  l_rate_or_payscale_name := C_Payname_Rec.name;
	END LOOP;

	FOR C_pay_elements_step_rec in C_pay_elements_step
	LOOP
	  l_pay_element_id        := C_pay_elements_step_rec.pay_element_id;
	  l_pay_element_option_id :=
			      C_pay_elements_step_rec.pay_element_option_id;
	END LOOP;

     end if;

   if (l_pay_element_id is null) then
     Select psb_pay_elements_s.nextval INTO l_pay_element_id
     FROM   dual;

     PSB_PAY_ELEMENTS_PVT.INSERT_ROW
     ( p_api_version             =>  1.0,
       p_init_msg_lISt           => NULL,
       p_commit                  => NULL,
       p_validation_level        => NULL,
       p_return_status           => l_return_status,
       p_msg_count               => l_msg_count,
       p_msg_data                     => l_msg_data,
       p_row_id                  => l_rowid,
       p_pay_element_id          => l_pay_element_id,
       p_business_group_id       => p_business_group_id,
       p_data_extract_id         => p_data_extract_id,
       p_name                    => l_rate_or_payscale_name,
       p_description             => NULL,
       p_element_value_type      => 'A',
       p_formula_id              => NULL,
       p_overwrite_flag          => 'Y',
       p_required_flag           => NULL,
       p_follow_salary           => NULL,
       p_pay_basis               => l_pay_basis,
       p_start_date              => p_date_effective,
       p_end_date                => NULL,
       p_processing_type         => 'R',
       p_period_type             => NULL,
       p_process_period_type     => NULL,
       p_max_element_value_type  => NULL,
       p_max_element_value       => NULL,
       p_salary_flag             => 'Y',
       p_salary_type             => l_salary_type,
       p_option_flag             => 'N',
       p_hr_element_type_id      => NULL,
       p_attribute_category      => NULL,
       p_attribute1              => NULL,
       p_attribute2              => NULL,
       p_attribute3              => NULL,
       p_attribute4              => NULL,
       p_attribute5              => NULL,
       p_attribute6              => NULL,
       p_attribute7              => NULL,
       p_attribute8              => NULL,
       p_attribute9              => NULL,
       p_attribute10             => NULL,
       p_last_update_date        => l_last_update_date,
       p_last_updated_by         => l_last_updated_by,
       p_last_update_login       => l_last_update_login,
       p_created_by              => l_created_by,
       p_creation_date           => l_creation_date
       );

       iF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    RAISE FND_API.G_EXC_ERROR;
       END IF;
       end if;

       If (l_pay_element_option_id is null) then

           -- Bug 4222417 moved the following statements
           -- to the beginning of the api
        /* l_last_update_date  := sysdate;
	   l_last_updated_BY   := FND_GLOBAL.USER_ID;
	   l_last_update_login := FND_GLOBAL.LOGIN_ID;
	   l_creation_date     := sysdate;
	   l_created_by        := FND_GLOBAL.USER_ID; */

	  Select psb_pay_element_options_s.nextval
	     INTO l_pay_element_option_id
	     FROM dual;

	  PSB_PAY_ELEMENT_OPTIONS_PVT.INSERT_ROW
	  ( p_api_version             =>  1.0,
	    p_init_msg_list           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_pay_element_option_id   => l_pay_element_option_id,
	    p_pay_element_id          => l_pay_element_id,
	    p_name                    => l_grade_name,
	    p_grade_step              => l_grade_step,
	    p_sequence_number         => l_sequence,
	    p_last_update_date        => l_last_update_date,
	    p_last_updated_by         => l_last_updated_by,
	    p_last_update_login       => l_last_update_login,
	    p_created_by              => l_created_by,
	    p_creation_date           => l_creation_date
	   );

	   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     RAISE FND_API.G_EXC_ERROR;
	   END IF;


	   Select psb_pay_element_rates_s.nextval
	     INTO l_pay_element_rate_id
	     FROM dual;

	  For C_Currency_Rec in C_Currency
	  Loop
	    l_currency_code := C_Currency_Rec.currency_code;
	  End Loop;

	  PSB_PAY_ELEMENT_RATES_PVT.INSERT_ROW
	  ( p_api_version             =>  1.0,
	    p_init_msg_list           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_pay_element_rate_id     => l_pay_element_rate_id,
	    p_pay_element_option_id   => l_pay_element_option_id,
	    p_pay_element_id          => l_pay_element_id,
	    p_effective_start_date    => p_date_effective,
	    p_effective_END_DATE      => p_date_end,
	    p_worksheet_id            => NULL,
	    p_element_value_type      => 'A',
	    p_element_value           =>
                   fnd_number.canonical_to_number(C_Pay_Grade_Rec.value),
	    p_pay_basIS               => l_pay_basis,
	    p_FORmula_id              => NULL,
	    p_maximum_value           =>
                   fnd_number.canonical_to_number(C_Pay_Grade_Rec.maximum),
	    p_mid_value               =>
                   fnd_number.canonical_to_number(C_Pay_Grade_Rec.mid_value),
	    p_minimum_value           =>
                   fnd_number.canonical_to_number(C_Pay_Grade_Rec.minimum),
	    p_currency_code           => l_currency_code,
	    p_last_update_date        => l_last_update_date,
	    p_last_updated_by         => l_last_updated_by,
	    p_last_update_login       => l_last_update_login,
	    p_created_by              => l_created_by,
	    p_creation_date           => l_creation_date
	   ) ;

	   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     RAISE FND_API.G_EXC_ERROR;
	   END IF;

   end if;
   End Loop;

   FOR C_pay_element_rates_rec in C_pay_element_rates
   LOOP
    l_pay_element_rate_id  := C_pay_element_rates_rec.pay_element_rate_id;
    l_currency_code        := C_pay_element_rates_rec.currency_code;
   END LOOP;

   IF l_pay_element_id is null and
      l_pay_element_option_id is null  and
      l_value is null then

      null;
      hr_utility.set_location('  """ :: ele and option id is NULLLLL   ' ,336);
      -- do not insert if there is nothing to insert
   ELSE

      hr_utility.set_location('  ::: > before ASSinsert  ' ,336);

      PSB_POSITION_ASSIGNMENTS_PVT.INSERT_ROW
      (
     p_api_version             => 1,
     p_init_msg_list           => NULL,
     p_commit                  => NULL,
     p_validation_level        => NULL,
     p_return_status           => l_return_status,
     p_msg_count               => l_msg_count,
     p_msg_data                => l_msg_data,
     p_rowid                   => l_rowid,
     p_position_assignment_id  => l_position_assignment_id,
     p_data_extract_id         => p_data_extract_id,
     p_worksheet_id            => NULL,
     p_position_id             => p_position_id,
     p_assignment_type         => 'ELEMENT',
     p_attribute_id            => NULL,
     p_attribute_value_id      => NULL,
     p_attribute_value         => NULL,
     p_pay_element_id          => l_pay_element_id,
     p_pay_element_option_id   => l_pay_element_option_id,
     p_effective_start_date    => p_date_effective,
     p_effective_END_DATE      => p_date_end,
     p_element_value_type      => 'A',
     p_element_value           => l_value,
     p_currency_code           => l_currency_code,
     p_pay_basIS               => l_pay_basis,
     p_employee_id             => NULL,
     p_primary_employee_flag   => NULL,
     p_global_default_flag     => NULL,
     p_assignment_default_rule_id => NULL,
     p_modify_flag             => NULL,
     p_mode                    => 'R'
     );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 hr_utility.set_location('fail insert assignments - stat is ' ||
				l_return_status,983);
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  raise FND_API.G_EXC_ERROR;
      end if;

    END IF;

   hr_utility.set_location(' -------E N D  S U CESS-------',333);
  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --hr_utility.trace_off;
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    hr_utility.set_location(' salary G_EXC_ERROR ----------',333);
    --hr_utility.trace_off;
    p_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    hr_utility.set_location(' G_EXC_UNEXPECTED_ERROR ------',333);
    --hr_utility.trace_off;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    --hr_utility.trace_off;
    hr_utility.set_location(' G_RET_STS_UNEXP_ERRORR ------',333);

End Populate_Salary_Assignments;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                   PROCEDURE Populate_Attribute_Assignments (Pvt)          |
 +===========================================================================*/
PROCEDURE Populate_Attribute_Assignments
(
  p_return_status            OUT NOCOPY  VARCHAR2,
  p_new_position_id          IN          NUMBER ,
  p_position_id              IN          NUMBER := FND_API.G_MISS_NUM,
  p_position_transaction_id  IN          NUMBER := FND_API.G_MISS_NUM,
  p_job_id                   IN          NUMBER ,
  p_organization_id          IN          NUMBER ,
  p_fte                      IN          NUMBER ,
  p_frequency                IN          VARCHAR2,
  p_working_hours            IN          NUMBER ,
  p_earliest_hire_date       IN          DATE,
  p_entry_grade_id           IN          NUMBER ,
  p_date_effective           IN          DATE,
  p_date_end                 IN          DATE,
  p_data_extract_id          IN          NUMBER,
  p_business_group_id        IN          NUMBER
)
IS
  l_definition_structure    varchar2(30);
  l_definition_table        varchar2(30);
  l_definition_column       varchar2(30);
  l_id_flex_code            varchar2(4);
  l_application_id          number;
  l_application_table_name  varchar2(30);
  l_set_defining_column     varchar2(30);
  l_id_flex_num             number;
  l_job_id_flex_num         number;
  l_application_column_name varchar2(30);
  l_definition_type         varchar2(30);
  --UTF8 changes for Bug No : 2615261
  lp_attribute_value        psb_attribute_values.attribute_value%TYPE;
  l_attribute_id            number;
  l_attribute_type_id       number;
  l_attribute_name          varchar2(30);
  l_attribute_value_id      number;
  --UTF8 changes for Bug No : 2615261
  l_attribute_value         psb_attribute_values.attribute_value%TYPE;
  l_position_assignment_id number := 0;

  l_select_tab              varchar2(30);
  l_select_key              varchar2(30);
  l_param_value             number;

  l_sql_stmt                varchar2(1000);
  v_cursorid                integer;
  v_dummy                   integer;
  v_segment                 varchar2(80);
  v_dcursorid               integer;
  v_ddummy                  integer;
  v_dsegment                varchar2(80);
  d_sql_stmt                varchar2(500);
  v_qcursorid               integer;
  v_qdummy                  integer;
  v_qsegment                varchar2(80);
  q_sql_stmt                varchar2(500);
  v_ocursorid               integer;
  v_odummy                  integer;
  v_osegment                varchar2(80);
  v_odate                   date;
  v_onumber                 number;
  o_sql_stmt                varchar2(500);
  l_alias1                  varchar2(10);
  l_value_table_flag        varchar2(1);
  l_lookup_type             varchar2(30);

  l_return_status          varchar2(1);
  l_msg_count              number;
  l_msg_data               varchar2(1000);
  l_message_text           varchar2(2000);
  l_rowid                  varchar2(100);

  l_last_update_date    DATE;
  l_last_updated_BY     number;
  l_last_update_login   number;
  l_creation_date       DATE;
  l_created_by          number;
  l_valid_attribute     varchar2(1) := 'N';

 Cursor C_Attributes is
   Select  attribute_id,name,definition_type,definition_structure,
	   definition_table, definition_column,system_attribute_type,
	   attribute_type_id,data_type,
	   nvl(value_table_flag,'N') value_table_flag
    from psb_attributes_vl
   where business_group_id = p_business_group_id
     -- Added for Bug#2820825
     and (system_attribute_type is null OR system_attribute_type <> 'HIREDATE');

 Cursor C_Attribute_Type is
    Select name, select_table,
           /*For Bug No : 2820825 Start*/
	   substr(select_table,1,instr(select_table,' ',1)-1) select_tab,
           /*For Bug No : 2820825 End*/
	   select_column,select_key,
	   link_key,decode(link_type,'A','PER_ALL_ASSIGNMENTS','E',
	   'PER_ALL_PEOPLE','P', 'HR_ALL_POSITIONS','PER_ALL_ASSIGNMENTS')
	   link_type,link_type l_alias2,
	   select_where
      From Psb_attribute_types
    Where  attribute_type = l_definition_type
      and  attribute_type_id = l_attribute_type_id;

 Cursor C_job_structure is
    Select job_structure
      from per_business_groups
     where business_group_id = p_business_group_id;

 Cursor C_Pos_Job is
    Select name
      from per_jobs
     where job_id = p_job_id;

 Cursor C_Pos_Org is
    Select name
      from hr_all_organization_units
     where organization_id = p_organization_id;

  Cursor C_pos_values is
    Select attribute_value_id
      FROM psb_attribute_values
     WHERE attribute_id = l_attribute_id
       AND decode(l_definition_type, 'DFF',hr_value_id,
		  attribute_value) = lp_attribute_value
       AND data_extract_id  = p_data_extract_id;

  Cursor C_key_33 is
       Select application_id,id_flex_code,
	      application_table_name,
	      set_defining_column_name
	from  fnd_id_flexs
       where id_flex_name = l_definition_structure;

  Cursor C_key_44 is
    SELECT fseg.application_column_name
	    FROM fnd_id_flex_structures_vl fstr,fnd_id_flex_segments_vl fseg
     WHERE fstr.application_id = l_application_id
	     AND fstr.id_flex_code   = l_id_flex_code
	     AND fstr.id_flex_structure_name = l_definition_table
	     AND fstr.id_flex_code   = fseg.id_flex_code
	     AND fstr.id_flex_num    = fseg.id_flex_num
	     AND fseg.segment_name   = l_definition_column
	     AND fstr.application_id = fseg.application_id;  -- bug #4924031

   Cursor C_dff_33 is
     Select application_id,application_table_name,
	    context_column_name
       from fnd_descriptive_flexs_vl
      where descriptive_flexfield_name = l_definition_structure;

   Cursor C_dff_44 is
    Select fcol.application_column_name
     from  fnd_descr_flex_contexts_vl fcon,fnd_descr_flex_column_usages fcol
     where fcon.application_id = fcol.application_id
       and fcon.descriptive_flexfield_name = l_definition_structure
       and fcon.descriptive_flex_context_code = l_definition_table
       and fcon.descriptive_flexfield_name = fcol.descriptive_flexfield_name
    and fcon.descriptive_flex_context_code = fcol.descriptive_flex_context_code
    and fcol.end_user_column_name = l_definition_column;

   Cursor C_Qc_55 is
     Select lookup_type
       from per_common_lookup_types_v
      where lookup_type_meaning = l_definition_table;

BEGIN

  -- Initialize the standard parameters.
  -- p_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- This procedure will create assignments from incremental data extract. If
  -- it is a system_attribute_type, then it is a candidate for adding to the
  -- position_assignments.
  -- If it is not system_attributes, then only when the definition types meet
  -- certain conditions will the attribute be added to the positions i.e., if
  -- KFF, structure should either be 'Job Flexfield','Position Flexfield' or ,
  -- 'Grade Flexfield. In both cases, attribute will be written to position
  -- assgn only if either attribute_value_id or attribute_value is not null.

  --hr_utility.trace_on;

  For C_Attribute_Rec in C_Attributes
  Loop -- L1


    lp_attribute_value     := NULL;
    l_attribute_type_id    := C_Attribute_Rec.attribute_type_id;
    l_attribute_id         := C_Attribute_Rec.attribute_id;
    l_attribute_name       := C_Attribute_Rec.name;
    l_definition_type      := C_Attribute_Rec.definition_type;
    l_definition_structure := C_Attribute_Rec.definition_structure;
    l_definition_table     := C_Attribute_Rec.definition_table;
    l_definition_column    := C_Attribute_Rec.definition_column;

    hr_utility.set_location(' Attribute tuype  '||
			    C_Attribute_Rec.system_attribute_type ,888);

    l_valid_attribute := 'N' ; -- initial setting for each record

    if (C_Attribute_Rec.system_attribute_type is not null) then --I1
      if (C_Attribute_Rec.system_attribute_type = 'JOB_CLASS') then --I2

	 l_valid_attribute := 'Y' ;
	 For C_job_structure_rec in C_job_structure
	 Loop
	   l_job_id_flex_num := C_job_structure_rec.job_structure;
	 End Loop;

	 For C_Pos_Job_Rec in C_Pos_Job
	 Loop
	   lp_attribute_value := C_Pos_Job_Rec.name;
	 End Loop;

      elsif (C_Attribute_Rec.system_attribute_type = 'ORG') then

	 l_valid_attribute := 'Y' ;
	 For C_Org_Rec in C_Pos_Org
	 Loop
	   lp_attribute_value := C_Org_Rec.name;
	 End Loop;
	 hr_utility.set_location(' JOB value '||l_attribute_value,888);

      elsif (C_Attribute_Rec.system_attribute_type = 'FTE') then
	 hr_utility.set_location(' FTE value ',888);
	 lp_attribute_value := p_fte;
	 l_valid_attribute := 'Y' ;

      elsif C_Attribute_Rec.system_attribute_type = 'DEFAULT_WEEKLY_HOURS' then
	if (p_frequency = 'W') then
	 lp_attribute_value := fnd_number.number_to_canonical(p_working_hours);
	end if;
	 l_valid_attribute := 'Y' ;
      -- Bug#2109120: Commenting
      /*
         elsif (C_Attribute_Rec.system_attribute_type = 'HIREDATE') then
	 lp_attribute_value :=fnd_date.date_to_canonical(p_earliest_hire_date);
	 l_valid_attribute := 'Y' ;
      */
      end if; -- I2
    else
     -- ++ start of non-system attributes
     -- ++ C_Attribute_Rec.system_attribute_type is null)

     l_select_tab := NULL;
     l_select_key := NULL;
     l_param_value   := NULL;

     if (l_definition_type = 'KFF') then
       if (l_definition_structure in
                      ('Job Flexfield','Position Flexfield','Grade Flexfield'))
       then
	l_valid_attribute := 'Y' ;
	For C_key_rec in C_key_33
	Loop
	   l_application_id      := C_key_rec.application_id;
	   l_id_flex_code        := C_key_rec.id_flex_code;
	   l_set_defining_column := C_key_rec.set_defining_column_name;
	   For C_key_str_rec in C_key_44
	   Loop
	      l_application_column_name :=
			 C_key_str_rec.application_column_name;
	   End Loop;
	End Loop;

	--hr_utility.set_location(' Attribute Struct '||
	--                            l_definition_structure,666);

	v_cursorid := dbms_sql.open_cursor;
	if (l_definition_structure = 'Job Flexfield') then
	    l_sql_stmt := 'Select '||l_application_column_name||
			 ' From  Per_jobs,per_job_definitions '||
			 ' Where per_jobs.job_id = '||p_job_id||
			 '   and per_jobs.job_definition_id = '||
			 ' per_job_definitions.job_definition_id';

	    dbms_sql.parse(v_cursorid,l_sql_stmt,dbms_sql.v7);
	    dbms_sql.define_column(v_cursorid,1,v_segment,80);
	elsif (l_definition_structure = 'Position Flexfield') then
	 if (p_position_id = FND_API.G_MISS_NUM) then
	     l_select_tab := 'PQH_POSITION_TRANSACTIONS';
	     l_select_key := 'POSITION_TRANSACTION_ID';
	     l_param_value   := p_position_transaction_id;
	 else
	     l_select_tab := 'HR_ALL_POSITIONS';
	     l_select_key := 'POSITION_ID';
	     l_param_value   := p_position_id;
	 end if;

	 /* Bug 3504183 Added a space after AND in line 1029 */
	 /*For Bug No : 2991818 Start*/
	 l_sql_stmt := 'Select '||l_application_column_name||
		  ' From '||l_select_tab||','||'per_position_definitions '||
		  ' Where '||l_select_tab||'.'||l_select_key||' = '||
		    ' :v_param_value and '||
		    l_select_tab||'.'||'position_definition_id = '||
		    ' per_position_definitions.position_definition_id';

	   dbms_sql.parse(v_cursorid,l_sql_stmt,dbms_sql.v7);
	   dbms_sql.bind_variable(v_cursorid,':v_param_value',l_param_value);
	   /*For Bug No : 2991818 End*/
	   dbms_sql.define_column(v_cursorid,1,v_segment,80);

	elsif (l_definition_structure = 'Grade Flexfield') then
	 l_sql_stmt := 'Select '||l_application_column_name||
	       ' From  Per_grades,per_grade_definitions '||
	       ' Where per_grades.grade_id = '||p_entry_grade_id||
	       '   and per_grades.grade_definition_id = '||
		    ' per_grade_definitions.grade_definition_id';
	 dbms_sql.parse(v_cursorid,l_sql_stmt,dbms_sql.v7);
	 dbms_sql.define_column(v_cursorid,1,v_segment,80);
	end if;
	v_dummy := DBMS_SQL.EXECUTE(v_cursorid);

	loop
	  v_segment := '';
	  if DBMS_SQL.FETCH_ROWS(v_cursorid) = 0 then
	     exit;
	  end if;
	  dbms_sql.column_value(v_cursorid,1,v_segment);
	  lp_attribute_value := v_segment;
	end loop;

	--hr_utility.set_location('Attribute Success'||lp_attribute_value,666);
       end if;
      elsif (l_definition_type = 'DFF') then
	 For Attr_Type_Rec in C_Attribute_Type
	 Loop
	   if ((Attr_Type_Rec.link_type = 'HR_ALL_POSITIONS')
	       and (Attr_Type_Rec.select_tab = 'HR_ALL_POSITIONS')) then

	       l_valid_attribute := 'Y' ;

	      if (p_position_id = FND_API.G_MISS_NUM) then
		 l_select_tab := 'PQH_POSITION_TRANSACTIONS';
		 l_select_key := 'POSITION_TRANSACTION_ID';
		 l_param_value   := p_position_transaction_id;
	      else
		 l_select_tab := 'HR_ALL_POSITIONS';
		 l_select_key := 'POSITION_ID';
		 l_param_value   := p_position_id;
	      end if;

	      if (dbms_sql.IS_OPEN(v_dcursorid)) then
		 dbms_sql.close_cursor(v_dcursorid);
	      end if;

	      For C_dff_rec in C_dff_33
	      Loop
		l_application_id          := C_dff_rec.application_id;
		l_application_table_name  := C_dff_rec.application_table_name;

		For C_dff_str_rec in C_dff_44
		Loop
		  l_application_column_name :=
				C_dff_str_rec.application_column_name;
		End Loop;
	      End Loop;
	      Begin
		Select ltrim(rtrim(substr(Attr_type_rec.select_table,
		       instr(Attr_type_rec.select_table,' ',1),
		       length(Attr_type_rec.select_table)
		       - instr(Attr_type_rec.select_table,' ',1) + 1)))
		  into l_alias1
		  from dual;
	      end;
	      v_dcursorid := dbms_sql.open_cursor;
              /* For Bug No. 2991818 Start */
	      d_sql_stmt := 'Select '||l_alias1||'.'
			    ||l_application_column_name||
		   '  From '||l_select_tab||' '||
			    l_alias1||' , '||
		   ' Where '||l_alias1||'.'||
		     l_select_key||' = :v_param_value';

	      if (Attr_type_rec.select_where is not null) then
		 d_sql_stmt := d_sql_stmt||' and '||Attr_type_rec.select_where;
	      end if;

	      dbms_sql.parse(v_dcursorid,d_sql_stmt,dbms_sql.v7);
       	      dbms_sql.bind_variable(v_dcursorid,':v_param_value',
                                                   l_param_value);
              /*For Bug No : 2991818 End*/
	      dbms_sql.define_column(v_dcursorid,1,v_dsegment,80);


	      v_ddummy := DBMS_SQL.EXECUTE(v_dcursorid);

	     loop

	       if DBMS_SQL.FETCH_ROWS(v_dcursorid) = 0 then
		  exit;
	       end if;

	      dbms_sql.column_value(v_dcursorid,1,v_dsegment);
	      lp_attribute_value := v_dsegment;
	     end loop;

	  end if;
	  end loop;

      elsif (l_definition_type = 'QC'
         and p_position_id <> FND_API.G_MISS_NUM   --bug:8468347
            ) then

	For Attr_Type_Rec in C_Attribute_Type
	 Loop
	   if ((Attr_Type_Rec.link_type = 'HR_ALL_POSITIONS') and
	       (Attr_Type_Rec.select_tab = 'HR_ALL_POSITIONS')) then

	      l_valid_attribute := 'Y' ;

 	      l_select_tab := 'HR_ALL_POSITIONS';
	      l_select_key := 'POSITION_ID';
	      l_param_value   := p_position_id;

	   if dbms_sql.is_open(v_qcursorid) then
	      dbms_sql.close_cursor(v_qcursorid);
	   end if;

	   l_lookup_type := Attr_type_rec.name;

	   Begin
	     Select ltrim(rtrim(substr(Attr_type_rec.select_table,
		    instr(Attr_type_rec.select_table,' ',1),
		   length(Attr_type_rec.select_table)
		    - instr(Attr_type_rec.select_table,' ',1) + 1)))
	      into l_alias1
	      from dual;
	   end;


	   v_qcursorid := dbms_sql.open_cursor;
	  /* For Bug No. 2991818 Start */
	   q_sql_stmt := 'Select a.meaning '||
			 '  From Fnd_Common_lookups a , '||
			      l_select_tab||' '||l_alias1||
		   ' Where a.lookup_type = '||''''||
		   l_lookup_type||''''||
		   ' and a.lookup_code = '||
		     l_alias1||'.'||Attr_type_rec.select_column||
		   ' and '||l_alias1||'.'||l_select_key||
		   ' = :v_param_value';

	   if (Attr_type_rec.select_where is not null) then
	      q_sql_stmt := q_sql_stmt||' and '||Attr_type_rec.select_where;
	   end if;

	   dbms_sql.parse(v_qcursorid,q_sql_stmt,dbms_sql.v7);
           dbms_sql.bind_variable(v_qcursorid,':v_param_value',l_param_value);
           /*For Bug No : 2991818 End*/
 	   dbms_sql.define_column(v_qcursorid,1,v_qsegment,80);

	   v_qdummy := DBMS_SQL.EXECUTE(v_qcursorid);

	   loop

	    if DBMS_SQL.FETCH_ROWS(v_qcursorid) = 0 then
	       exit;
	    end if;

	    dbms_sql.column_value(v_qcursorid,1,v_qsegment);
	    lp_attribute_value := v_qsegment;
	   end loop;

	  end if;
	  end loop;

      elsif (l_definition_type = 'TABLE'
         and p_position_id <> FND_API.G_MISS_NUM   --bug:8468347
      ) then
      -- Handle table defn types
       For Attr_Type_Rec in C_Attribute_Type
       Loop

       if ((Attr_Type_Rec.link_type = 'HR_ALL_POSITIONS')
	   and (Attr_Type_Rec.select_tab = 'HR_ALL_POSITIONS')) then

	    l_valid_attribute := 'Y' ;

            l_select_tab := 'HR_ALL_POSITIONS';
	    l_select_key := 'POSITION_ID';
	    l_param_value   := p_position_id;

	   if dbms_sql.is_open(v_ocursorid) then
	      dbms_sql.close_cursor(v_ocursorid);
	   end if;

	   v_ocursorid := dbms_sql.open_cursor;
	   Begin
	     Select ltrim(rtrim(substr(Attr_type_rec.select_table,
		    instr(Attr_type_rec.select_table,' ',1),
		    length(Attr_type_rec.select_table)
	     - instr(Attr_type_rec.select_table,' ',1) + 1))) into l_alias1
	      from dual;
	   End;

	   /*For Bug No : 2991818 Start*/
	   o_sql_stmt := 'Select '||
		      Attr_type_rec.select_column||
		   '  From '||l_select_tab||' '||l_alias1||
		   '  Where '||l_alias1||'.'||l_select_key||
		   ' = :v_param_value';

	  if (Attr_type_rec.select_where is not null) then
	      o_sql_stmt := o_sql_stmt||' and '||Attr_type_rec.select_where;
	  end if;

	  dbms_sql.parse(v_ocursorid,o_sql_stmt,dbms_sql.v7);
          dbms_sql.bind_variable(v_ocursorid,':v_param_value',l_param_value);
          /*For Bug No : 2991818 End*/

	  if (C_Attribute_Rec.data_type = 'D') then
	      dbms_sql.define_column(v_ocursorid,1,v_odate);
	  elsif (C_Attribute_Rec.data_type = 'N') then
	     dbms_sql.define_column(v_ocursorid,1,v_onumber);
	  elsif (C_Attribute_Rec.data_type = 'C') then
	     dbms_sql.define_column(v_ocursorid,1,v_osegment,80);
	  end if;

	  v_odummy := DBMS_SQL.EXECUTE(v_ocursorid);

	  loop

	     if DBMS_SQL.FETCH_ROWS(v_ocursorid) = 0 then
		exit;
	     end if;

	     if (C_Attribute_Rec.data_type = 'D') then
	     begin
	       dbms_sql.column_value(v_ocursorid,1,v_odate);
	       v_osegment := fnd_date.date_to_canonical(v_odate);
	       exception
	       when OTHERS then -- Bug #4658351: Changed VALUE_ERROR to OTHERS

                 -- Changed the exception part for Bug#4658351
                 FND_MESSAGE.SET_NAME('PSB', 'PSB_ATTRIBUTE_VALUE_DATE_ERR');
                 FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', l_attribute_name);
                 l_message_text := fnd_message.get;
                 RAISE_APPLICATION_ERROR(-20001,l_message_text);

	    end;
	    elsif (C_Attribute_Rec.data_type = 'N') then
	    begin
	      dbms_sql.column_value(v_ocursorid,1,v_onumber);
	      v_osegment := fnd_number.number_to_canonical(v_onumber);
	      exception
	      when INVALID_NUMBER then

                -- Changed the exception part for Bug#4658351
                FND_MESSAGE.SET_NAME('PSB', 'PSB_ATTRIBUTE_VALUE_NUMBER_ERR');
                FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME', l_attribute_name);
                l_message_text := fnd_message.get;
                RAISE_APPLICATION_ERROR(-20000,l_message_text);

	    end;

	   elsif (C_Attribute_Rec.data_type = 'C') then
	     dbms_sql.column_value(v_ocursorid,1,v_osegment);
	   end if;
	   lp_attribute_value := v_osegment;
	   end loop;
	 end if;
	 end loop;
      end if; /* if KFF */
    end if; -- I1

    -- Process only if it's one of the tested attributes i.e., people kff,
    -- other info dff are not to be processed; only position related

    hr_utility.set_location(' %% VALID AttrValue '||l_valid_attribute,888);

    --++ proceed only if a valid attribute;

    IF l_valid_attribute =  'Y'  THEN

    hr_utility.set_location(' Attribute Value '||lp_attribute_value,888);
    hr_utility.set_location(' Attribute ID '||C_Attribute_Rec.attribute_id,888);
    hr_utility.set_location(' name '||C_Attribute_Rec.name,888);

    l_attribute_id     := C_Attribute_Rec.attribute_id;
    l_value_table_flag := C_Attribute_Rec.value_table_flag;
    l_definition_type  := C_Attribute_Rec.definition_type;

    l_attribute_value_id := NULL;
    l_attribute_value    := NULL;

    IF (l_value_table_flag = 'Y') THEN

      -- Find the attribute_value_id based on the current attribute_name
      -- AND attribute_value FROM psb_attribute_values table.

	FOR C_pos_value_rec in C_pos_values
	LOOP
	  l_attribute_value_id := C_pos_value_rec.attribute_value_id;
	END LOOP;

	IF (l_attribute_value_id IS NULL) THEN
	    l_last_update_date  := sysdate;
	    l_last_updated_BY   := FND_GLOBAL.USER_ID;
	    l_last_update_login := FND_GLOBAL.LOGIN_ID;
	    l_creation_date     := sysDATE;
	    l_created_by        := FND_GLOBAL.USER_ID;

	  -- Insert the new value in PSB_ATTRIBUTE_VALUES
	  select psb_attribute_values_s.nextval into
	     l_attribute_value_id from dual;

	  PSB_ATTRIBUTE_VALUES_PVT.INSERT_ROW
	  ( p_api_version             =>  1.0,
	    p_init_msg_lISt           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_rowid                   => l_rowid,
	    p_attribute_value_id      => l_attribute_value_id,
	    p_attribute_id            => l_attribute_id,
	    p_attribute_value         => lp_attribute_value,
	    p_hr_value_id             => NULL,
	    p_description             => NULL,
	    p_data_extract_id         => p_data_extract_id,
	    p_context                 => NULL,
	    p_attribute1              => NULL,
	    p_attribute2              => NULL,
	    p_attribute3              => NULL,
	    p_attribute4              => NULL,
	    p_attribute5              => NULL,
	    p_attribute6              => NULL,
	    p_attribute7              => NULL,
	    p_attribute8              => NULL,
	    p_attribute9              => NULL,
	    p_attribute10             => NULL,
	    p_attribute11             => NULL,
	    p_attribute12             => NULL,
	    p_attribute13             => NULL,
	    p_attribute14             => NULL,
	    p_attribute15             => NULL,
	    p_attribute16             => NULL,
	    p_attribute17             => NULL,
	    p_attribute18             => NULL,
	    p_attribute19             => NULL,
	    p_attribute20             => NULL,
	    p_attribute21             => NULL,
	    p_attribute22             => NULL,
	    p_attribute23             => NULL,
	    p_attribute24             => NULL,
	    p_attribute25             => NULL,
	    p_attribute26             => NULL,
	    p_attribute27             => NULL,
	    p_attribute28             => NULL,
	    p_attribute29             => NULL,
	    p_attribute30             => NULL,
	    p_last_upDATE_DATE        => l_last_update_date,
	    p_last_upDATEd_BY         => l_last_updated_BY,
	    p_last_upDATE_login       => l_last_update_login,
	    p_created_BY              => l_created_by,
	    p_creation_DATE           => l_creation_date
	   ) ;

	  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     RAISE FND_API.G_EXC_ERROR;
	  END IF;

	  l_attribute_value := lp_attribute_value;
	else
	  l_attribute_value := NULL;
	END IF;

    else

	l_attribute_value_id := NULL;
	l_attribute_value := lp_attribute_value;

    END IF;  -- END IF ( l_value_table_flag = 'Y')

    IF l_attribute_value_id is not null or
       l_attribute_value is not null THEN

      PSB_POSITION_ASSIGNMENTS_PVT.INSERT_ROW
      (
	 p_api_version             => 1,
	 p_init_msg_list           => NULL,
	 p_commit                  => NULL,
	 p_validation_level        => NULL,
	 p_return_status           => l_return_status,
	 p_msg_count               => l_msg_count,
	 p_msg_data                => l_msg_data,
	 p_rowid                   => l_rowid,
	 p_position_assignment_id  => l_position_assignment_id,
	 p_data_extract_id         => p_data_extract_id,
	 p_worksheet_id            => NULL,
	 p_position_id             => p_new_position_id,
	 p_assignment_type         => 'ATTRIBUTE',
	 p_attribute_id            => l_attribute_id,
	 p_attribute_value_id      => l_attribute_value_id,
	 p_attribute_value         => l_attribute_value,
	 p_pay_element_id          => NULL,
	 p_pay_element_option_id   => NULL,
	 p_effective_start_date    => p_date_effective,
	 p_effective_end_date      => p_date_end,
	 p_element_value_type      => NULL,
	 p_element_value           => NULL,
	 p_currency_code           => NULL,
	 p_pay_basis               => NULL,
	 p_employee_id             => NULL,
	 p_primary_employee_flag   => NULL,
	 p_global_default_flag     => NULL,
	 p_assignment_default_rule_id => NULL,
	 p_modify_flag             => NULL,
	 p_mode                    => 'R'
      ) ;

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  RAISE FND_API.G_EXC_ERROR;
	END IF;

    END IF; -- end of l_valid_attribute
    END IF; -- test of attribute val/id

    hr_utility.set_location(' Attribute Assign Success YYY',999);
  End Loop; --L1
  --hr_utility.trace_off;

END Populate_Attribute_Assignments;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                       PROCEDURE Insert_Position_Txn_Info                  |
 +===========================================================================*/
PROCEDURE Insert_Position_Txn_Info
(
 p_position_transaction_id        in number ,
 p_action_date                    in date ,
 p_position_id                    in number ,
 p_availability_status_id         in number ,
 p_business_group_id              in number ,
 p_entry_step_id                  in number ,
 p_entry_grade_rule_id            in number ,
 p_job_id                         in number ,
 p_location_id                    in number ,
 p_organization_id                in number ,
 p_pay_freq_payroll_id            in number ,
 p_position_definition_id         in number ,
 p_prior_position_id              in number ,
 p_relief_position_id             in number ,
 p_entry_grade_id                 in number ,
 p_successor_position_id          in number ,
 p_supervisor_position_id         in number ,
 p_amendment_date                 in date ,
 p_amendment_recommendation       in varchar2 ,
 p_amendment_ref_number           in varchar2 ,
 p_avail_status_prop_end_date     in date ,
 p_bargaining_unit_cd             in varchar2 ,
 p_comments                       in long ,
 p_country1                       in varchar2 ,
 p_country2                       in varchar2 ,
 p_country3                       in varchar2 ,
 p_current_job_prop_end_date      in date ,
 p_current_org_prop_end_date      in date ,
 p_date_effective                 in date ,
 p_date_end                       in date ,
 p_earliest_hire_date             in date ,
 p_fill_by_date                   in date ,
 p_frequency                      in varchar2 ,
 p_fte                            in number ,
 p_location1                      in varchar2 ,
 p_location2                      in varchar2 ,
 p_location3                      in varchar2 ,
 p_max_persons                    in number ,
 p_name                           in varchar2 ,
 p_other_requirements             in varchar2 ,
 p_overlap_period                 in number ,
 p_overlap_unit_cd                in varchar2 ,
 p_passport_required              in varchar2 ,
 p_pay_term_end_day_cd            in varchar2 ,
 p_pay_term_end_month_cd          in varchar2 ,
 p_permanent_temporary_flag       in varchar2 ,
 p_permit_recruitment_flag        in varchar2 ,
 p_position_type                  in varchar2 ,
 p_posting_description            in varchar2 ,
 p_probation_period               in number ,
 p_probation_period_unit_cd       in varchar2 ,
 p_relocate_domestically          in varchar2 ,
 p_relocate_internationally       in varchar2 ,
 p_replacement_required_flag      in varchar2 ,
 p_review_flag                    in varchar2 ,
 p_seasonal_flag                  in varchar2 ,
 p_security_requirements          in varchar2 ,
 p_service_minimum                in varchar2 ,
 p_term_start_day_cd              in varchar2 ,
 p_term_start_month_cd            in varchar2 ,
 p_time_normal_finish             in varchar2 ,
 p_time_normal_start              in varchar2 ,
 p_transaction_status             in varchar2 ,
 p_travel_required                in varchar2 ,
 p_working_hours                  in number ,
 p_works_council_approval_flag    in varchar2 ,
 p_work_any_country               in varchar2 ,
 p_work_any_location              in varchar2 ,
 p_work_period_type_cd            in varchar2 ,
 p_work_schedule                  in varchar2 ,
 p_work_term_end_day_cd           in varchar2 ,
 p_work_term_end_month_cd         in varchar2 ,
 p_proposed_fte_for_layoff        in  number,
 p_proposed_date_for_layoff       in  date,
 p_information1                   in varchar2 ,
 p_information2                   in varchar2 ,
 p_information3                   in varchar2 ,
 p_information4                   in varchar2 ,
 p_information5                   in varchar2 ,
 p_information6                   in varchar2 ,
 p_information7                   in varchar2 ,
 p_information8                   in varchar2 ,
 p_information9                   in varchar2 ,
 p_information10                  in varchar2 ,
 p_information11                  in varchar2 ,
 p_information12                  in varchar2 ,
 p_information13                  in varchar2 ,
 p_information14                  in varchar2 ,
 p_information15                  in varchar2 ,
 p_information16                  in varchar2 ,
 p_information17                  in varchar2 ,
 p_information18                  in varchar2 ,
 p_information19                  in varchar2 ,
 p_information20                  in varchar2 ,
 p_information21                  in varchar2 ,
 p_information22                  in varchar2 ,
 p_information23                  in varchar2 ,
 p_information24                  in varchar2 ,
 p_information25                  in varchar2 ,
 p_information26                  in varchar2 ,
 p_information27                  in varchar2 ,
 p_information28                  in varchar2 ,
 p_information29                  in varchar2 ,
 p_information30                  in varchar2 ,
 p_information_category           in varchar2 ,
 p_attribute1                     in varchar2 ,
 p_attribute2                     in varchar2 ,
 p_attribute3                     in varchar2 ,
 p_attribute4                     in varchar2 ,
 p_attribute5                     in varchar2 ,
 p_attribute6                     in varchar2 ,
 p_attribute7                     in varchar2 ,
 p_attribute8                     in varchar2 ,
 p_attribute9                     in varchar2 ,
 p_attribute10                    in varchar2 ,
 p_attribute11                    in varchar2 ,
 p_attribute12                    in varchar2 ,
 p_attribute13                    in varchar2 ,
 p_attribute14                    in varchar2 ,
 p_attribute15                    in varchar2 ,
 p_attribute16                    in varchar2 ,
 p_attribute17                    in varchar2 ,
 p_attribute18                    in varchar2 ,
 p_attribute19                    in varchar2 ,
 p_attribute20                    in varchar2 ,
 p_attribute21                    in varchar2 ,
 p_attribute22                    in varchar2 ,
 p_attribute23                    in varchar2 ,
 p_attribute24                    in varchar2 ,
 p_attribute25                    in varchar2 ,
 p_attribute26                    in varchar2 ,
 p_attribute27                    in varchar2 ,
 p_attribute28                    in varchar2 ,
 p_attribute29                    in varchar2 ,
 p_attribute30                    in varchar2 ,
 p_attribute_category             in varchar2 ,
 p_object_version_number          in number ,
 p_effective_date                 in date ,
 p_pay_basis_id                   in number ,
 p_supervisor_id                  in number
)
IS
  --
  l_api_name         CONSTANT VARCHAR2(30)  := 'Insert_Position_Txn_Info';
  l_api_version      CONSTANT NUMBER        := 1.0;
  --
  l_rowid                varchar2(100);
  l_vacant_position_flag varchar2(1);
  l_date_end             date;
  l_data_extract_id      number ;
  l_set_of_books_id      number;
  l_position_id_flex_num number;
  segs                   FND_FLEX_EXT.SegmentArray;
  isegs                  FND_FLEX_EXT.SegmentArray;
  l_init_index           BINARY_INTEGER;
  l_pos_index            BINARY_INTEGER;
  l_ccid                 number;
  l_position_id          number;
  l_concat_pos_name      varchar2(240);
  l_availability_status  varchar2(30);

  /*For Bug No : 2602027 Start*/
  l_pos_id_flex_num     number;
  l_per_index           BINARY_INTEGER;
  tf                    BOOLEAN;
  nsegs                 NUMBER;
  possegs               FND_FLEX_EXT.SegmentArray;
  /*For Bug No : 2602027 End*/

  l_return_status          varchar2(1);
  l_validity_date          date := null;
  l_msg_count              number;
  l_msg_data               varchar2(1000);
  l_msg                    varchar2(2000);

  Cursor C_avail_status is
 /*For Bug No : 1527423 Start*/
  --SELECT shared_type_name
    SELECT system_type_cd
 /*For Bug No : 1527423 End*/
      FROM per_shared_types
     WHERE lookup_type = 'POSITION_AVAILABILITY_STATUS'
       AND shared_type_id = p_availability_status_id;

  Cursor C_data_extract is
    SELECT business_group_id,
	   set_of_books_id,
	   position_id_flex_num,
	   req_data_as_of_date
      FROM psb_data_extracts
     WHERE data_extract_id = l_data_extract_id;

  /*For Bug No : 2602027 Start*/
  Cursor C_flex_num is
	select position_structure
	  from per_business_groups
	 where business_group_id = p_business_group_id;

  Cursor C_pos_segs is
    select application_column_name
      from fnd_id_flex_segments_vl
     where id_flex_code = 'POS'
       and id_flex_num = l_pos_id_flex_num
       and enabled_flag = 'Y'
    order by segment_num;
  /*For Bug No : 2602027 End*/
  --
BEGIN
  --hr_utility.trace_on;
  hr_utility.set_location('>> insert position trans',777);

  if (get_global('G_PSB_APPLICATION_ID') = 8401) then
    hr_utility.set_location('>> appl id is 8401',777);

    if (get_global('G_PSB_CURRENT_FORM') in ('PSBMNPOS', 'PSBBGRVS','PSBWMPMD'))
    then
      if (p_date_end = to_date('31124712','DDMMYYYY')) then
        l_date_end := to_date(null);
      else
        l_date_end := p_date_end;
      end if;

      -- Get Data Extract Id value from Global.
      l_data_extract_id := get_global('G_PSB_DATA_EXTRACT_ID');
      For C_data_extract_rec in C_data_extract
      Loop
        l_set_of_books_id      := C_data_extract_rec.set_of_books_id;
        l_position_id_flex_num := C_data_extract_rec.position_id_flex_num;
      End Loop;

      /*For Bug No : 2602027 Start*/
      For C_flex_rec in C_flex_num
      Loop
        l_pos_id_flex_num := C_flex_rec.position_structure;
      End Loop;

      tf := FND_FLEX_EXT.GET_SEGMENTS('PER', 'POS', l_pos_id_flex_num,
                                       p_position_definition_id, nsegs, segs);
      if (tf = FALSE) then
        l_msg := FND_MESSAGE.Get;
        FND_MESSAGE.SET_NAME('PSB','PSB_POS_DEFN_VALUE_ERROR');
        FND_MESSAGE.SET_TOKEN('POSITION_NAME',p_name );
        FND_MESSAGE.SET_TOKEN('ERR_MESG',l_msg);
        FND_MSG_PUB.Add;
        hr_utility.set_location('error in get segments',9867);
        RAISE FND_API.G_EXC_ERROR;
      end if;

      l_per_index := 1;
      l_init_index := 0;

      For k in 1..30
      Loop
        possegs(k) := null;
      End Loop;

      For C_pos_seg_rec in C_pos_segs
      Loop
      l_init_index := l_init_index + 1;

      If (C_pos_seg_rec.application_column_name = 'SEGMENT1') then
         possegs(1) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT2') then
	 possegs(2) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT3') then
	 possegs(3) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT4') then
	 possegs(4) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT5') then
	 possegs(5) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT6') then
	 possegs(6) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT7') then
	 possegs(7) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT8') then
	 possegs(8) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT9') then
	 possegs(9) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT10') then
	 possegs(10) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT11') then
	 possegs(11) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT12') then
	 possegs(12) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT13') then
	 possegs(13) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT14') then
	 possegs(14) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT15') then
	 possegs(15) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT16') then
	 possegs(16) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT17') then
	 possegs(17) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT18') then
	 possegs(18) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT19') then
	 possegs(19) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT20') then
	 possegs(20) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT21') then
	 possegs(21) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT22') then
	 possegs(22) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT23') then
	 possegs(23) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT24') then
	 possegs(24) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT25') then
	 possegs(25) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT26') then
	 possegs(26) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT27') then
	 possegs(27) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT28') then
	 possegs(28) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT29') then
	 possegs(29) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT30') then
	 possegs(30) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      End Loop;
      /*For Bug No : 2602027 End*/

      For k in 1..30
      Loop
        isegs(k) := null;
      End Loop;

      l_pos_index := 0;

      FOR C_flex_rec in
      (
        Select application_column_name
        FROM   fnd_id_flex_segments_vl
        WHERE  id_flex_code = 'BPS'
        AND    id_flex_num  = l_position_id_flex_num
        AND    enabled_flag = 'Y'
        ORDER  BY segment_num
      )
      LOOP
	l_pos_index := l_pos_index + 1;
	isegs(l_pos_index) := NULL;

	IF (C_flex_rec.application_column_name = 'SEGMENT1') THEN
	    isegs(l_pos_index)   := possegs(1);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT2') THEN
	    isegs(l_pos_index)   := possegs(2);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT3') THEN
	    isegs(l_pos_index)   := possegs(3);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT4') THEN
	    isegs(l_pos_index)   := possegs(4);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT5') THEN
	    isegs(l_pos_index)   := possegs(5);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT6') THEN
	    isegs(l_pos_index)   := possegs(6);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT7') THEN
	    isegs(l_pos_index)   := possegs(7);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT8') THEN
	    isegs(l_pos_index)   := possegs(8);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT9') THEN
	    isegs(l_pos_index)   := possegs(9);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT10') THEN
	    isegs(l_pos_index)   := possegs(10);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT11') THEN
	    isegs(l_pos_index)   := possegs(11);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT12') THEN
	    isegs(l_pos_index)   := possegs(12);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT13') THEN
	    isegs(l_pos_index)   := possegs(13);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT14') THEN
	    isegs(l_pos_index)   := possegs(14);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT15') THEN
	    isegs(l_pos_index)   := possegs(15);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT16') THEN
	    isegs(l_pos_index)   := possegs(16);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT17') THEN
	    isegs(l_pos_index)   := possegs(17);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT18') THEN
	    isegs(l_pos_index)   := possegs(18);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT19') THEN
	    isegs(l_pos_index)   := possegs(19);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT20') THEN
	    isegs(l_pos_index)   := possegs(20);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT21') THEN
	    isegs(l_pos_index)   := possegs(21);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT22') THEN
	    isegs(l_pos_index)   := possegs(22);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT23') THEN
	    isegs(l_pos_index)   := possegs(23);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT24') THEN
	    isegs(l_pos_index)   := possegs(24);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT25') THEN
	    isegs(l_pos_index)   := possegs(25);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT26') THEN
	    isegs(l_pos_index)   := possegs(26);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT27') THEN
	    isegs(l_pos_index)   := possegs(27);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT28') THEN
	    isegs(l_pos_index)   := possegs(28);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT29') THEN
	    isegs(l_pos_index)   := possegs(29);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT30') THEN
	    isegs(l_pos_index)   := possegs(30);
	END IF;

      END LOOP; -- END LOOP ( C_flex_rec in C_flex )

      l_msg := null;
      if not fnd_flex_ext.Get_combination_id
             ( application_short_name => 'PSB',
               key_flex_code => 'BPS',
               structure_number => l_position_id_flex_num,
               validation_date => sysdate,
               n_segments => l_pos_index,
               segments => isegs,
               combination_id => l_ccid
             )
      then
        l_msg := FND_MESSAGE.get;
        FND_MSG_PUB.Add;
        FND_MESSAGE.SET_NAME('PSB', 'PSB_INCREMENTAL_CCID_FAILURE');
        FND_MESSAGE.SET_TOKEN('ERRMESG',l_msg);
        hr_utility.set_location('error in get combination id',9867);
        RAISE FND_API.G_EXC_ERROR;
      end if;

      l_concat_pos_name := null;
      l_concat_pos_name := FND_FLEX_EXT.Get_Segs
                           ( application_short_name => 'PSB',
                             key_flex_code          => 'BPS',
                             structure_number       => l_position_id_flex_num,
                             combination_id         => l_ccid
                           );
      For C_avail_status_rec in C_avail_status
      Loop
        -- For Bug No 1527423
        /* l_availability_status := C_avail_status_rec.shared_type_name; */
        l_availability_status := C_avail_status_rec.system_type_cd;
      End loop;

      -- Create new position in PSB
      SELECT psb_positions_s.nextval INTO l_position_id
      FROM   dual;

      PSB_POSITIONS_PVT.INSERT_ROW
      (
        p_api_version            => 1.0,
        p_init_msg_list          => NULL,
        p_commit                 => NULL,
        p_validation_level       => NULL,
        p_return_status          => l_return_status,
        p_msg_count              => l_msg_count,
        p_msg_data               => l_msg_data,
        p_rowid                  => l_rowid,
        p_position_id            => l_position_id,
        -- de by org
        p_organization_id        => p_organization_id,
        p_data_extract_id        => l_data_extract_id,
        p_position_definition_id => l_ccid,
        p_hr_position_id         => p_position_id,
        p_hr_employee_id         => NULL,
        p_business_group_id      => p_business_group_id,
        p_effective_start_date   => p_date_effective,
        p_effective_end_date     => l_date_end,
        p_set_of_books_id        => l_set_of_books_id,
        p_vacant_position_flag   => 'Y',
        p_availability_status    => l_availability_status,
        p_transaction_id         => p_position_transaction_id,
        p_transaction_status     => p_transaction_status,
        p_new_position_flag      => 'Y',
        p_attribute1             => NULL,
        p_attribute2             => NULL,
        p_attribute3             => NULL,
        p_attribute4             => NULL,
        p_attribute5             => NULL,
        p_attribute6             => NULL,
        p_attribute7             => NULL,
        p_attribute8             => NULL,
        p_attribute9             => NULL,
        p_attribute10            => NULL,
        p_attribute11            => NULL,
        p_attribute12            => NULL,
        p_attribute13            => NULL,
        p_attribute14            => NULL,
        p_attribute15            => NULL,
        p_attribute16            => NULL,
        p_attribute17            => NULL,
        p_attribute18            => NULL,
        p_attribute19            => NULL,
        p_attribute20            => NULL,
        p_attribute_category     => NULL,
        p_name                   => l_concat_pos_name,
        p_mode                   => 'R'
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('PSB', 'PSB_PQH_INSERT_FAILURE');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- Addto position sets for WS recalc
      /*Bug:5450510:Added parameter p_data_extract_id to the following api */
      PSB_Budget_Position_Pvt.Add_Position_To_Position_Sets
      (
        p_api_version       => 1.0,
        p_init_msg_list     => FND_API.G_TRUE,
        p_commit            => NULL,
        p_validation_level  => NULL,
        p_return_status     => l_return_status,
        p_msg_count         => l_msg_count,
        p_msg_data          => l_msg_data,
        p_position_id       => l_position_id,
        p_data_extract_id   => l_data_extract_id
      ) ;

      hr_utility.set_location('>> added to pos set id ' || l_position_id,876);
      hr_utility.set_location('>> stat is ' || l_return_status,877);

      -- Populate Salary Assignments

      Populate_Salary_Assignments
      ( p_return_status   =>  l_return_status,
        p_position_id     =>  l_position_id,
        p_date_effective  =>  p_date_effective,
        p_date_end        =>  l_date_end,
        p_data_extract_id =>  l_data_extract_id,
        p_business_group_id =>  p_business_group_id,
        p_set_of_books_id   =>  l_set_of_books_id,
        p_entry_grade_rule_id  => p_entry_grade_rule_id,
        p_entry_step_id   => p_entry_step_id,
        p_entry_grade_id  => p_entry_grade_id,
        p_pay_basis_id    => p_pay_basis_id
      );
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('PSB', 'PSB_INCREMENTAL_SALARY_FAILURE');
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      Populate_Attribute_Assignments
      ( p_return_status            =>  l_return_status,
        p_new_position_id          =>  l_position_id,
        p_position_transaction_id  =>  p_position_transaction_id,
        p_job_id                   =>  p_job_id,
        p_organization_id          =>  p_organization_id,
        p_fte                      =>  p_fte,
        p_frequency                =>  p_frequency,
        p_working_hours            =>  p_working_hours,
        p_earliest_hire_date       =>  p_earliest_hire_date,
        p_entry_grade_id           =>  p_entry_grade_id,
        p_date_effective           =>  p_date_effective,
        p_date_end                 =>  l_date_end,
        p_data_extract_id          =>  l_data_extract_id,
        p_business_group_id        =>  p_business_group_id
      ) ;
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.SET_NAME('PSB', 'PSB_INCREMENTAL_ATTRIBUTE_FAIL');
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Update WS/BR; do only in add since org is cannot be diff than input
      Update_Worksheet_Values ( p_return_status => l_return_status,
                                p_position_id   => l_position_id,
                                p_org_id        => p_organization_id
                              ) ;
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        hr_utility.set_location(' fail to update ws value ',888);
        FND_MESSAGE.SET_NAME('PSB', 'PSB_INCREMENTAL_WS_FAILURE'  );
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      hr_utility.set_location('>> END insert position trans',777);
      --hr_utility.trace_off;

    end if;
    -- End checking G_PSB_CURRENT_FORM.

  end if;
  -- End checking G_PSB_APPLICATION_ID.

EXCEPTION
  --
  WHEN OTHERS THEN
    Process_Exception( l_api_name ) ;
  --
END Insert_Position_Txn_Info;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                      PROCEDURE Update_Position_Txn_Info                   |
 +===========================================================================*/
PROCEDURE Update_Position_Txn_Info
(p_position_transaction_id     in NUMBER,
 p_action_date                 in DATE ,
 p_position_id                 in NUMBER,
 p_availability_status_id      in NUMBER,
 p_business_group_id           in NUMBER,
 p_entry_step_id               in NUMBER,
 p_entry_grade_rule_id         in NUMBER,
 p_job_id                      in NUMBER,
 p_location_id                 in NUMBER,
 p_organization_id             in NUMBER,
 p_pay_freq_payroll_id         in NUMBER,
 p_position_definition_id      in NUMBER,
 p_entry_grade_id              in NUMBER,
 p_bargaining_unit_cd          in VARCHAR2,
 p_date_effective              in DATE,
 p_date_end                    in DATE,
 p_earliest_hire_date          in DATE,
 p_frequency                   in VARCHAR2,
 p_fte                         in NUMBER,
 p_name                        in VARCHAR2,
 p_position_type               in VARCHAR2,
 p_transaction_status          in VARCHAR2,
 p_working_hours               in NUMBER,
 p_pay_basis_id_o              in NUMBER,
 p_object_version_number       in NUMBER,
 p_effective_date              in DATE
)
IS
  --
  l_api_name         CONSTANT VARCHAR2(30)  := 'Update_Position_Txn_Info' ;
  l_api_version      CONSTANT NUMBER        := 1.0 ;
  --
  l_data_extract_id     number := 0;
  l_position_id_flex_num number;
  segs                  FND_FLEX_EXT.SegmentArray;
  l_init_index          BINARY_INTEGER;
  l_ccid                number;
  l_position_id         number;
  -- de by org
  l_organization_id     number;
  l_concat_pos_name     varchar2(240);

  Cursor C_trn_exist is
     Select 'Position Transaction Exists in PSB'
       from dual
      where exists
    (Select 1
       from psb_positions
      where transaction_id = p_position_transaction_id);

  Cursor C_pos_trx is
     Select *
       from psb_positions
      where transaction_id = p_position_transaction_id;

  Cursor C_availability_status  is
 /*For Bug No : 1527423 Start*/
  --select shared_type_name
    select system_type_cd
 /*For Bug No : 1527423 End*/
      from per_shared_types
     where lookup_type = 'POSITION_AVAILABILITY_STATUS'
       and shared_type_id = p_availability_status_id;

  Cursor C_data_extract is
    SELECT req_data_as_of_date,
	   set_of_books_id,
	   position_id_flex_num,
	   business_group_id
      FROM psb_data_extracts
     WHERE data_extract_id = l_data_extract_id;

  l_trn_exist              VARCHAR2(1) := FND_API.G_FALSE;
  l_psb_position_id        number := '';
  l_set_of_books_id        number := '';
  l_validity_date          date := null;
  l_availability_status    varchar2(30);
  l_return_status          varchar2(1);
  l_msg_count              number;
  l_msg_data               varchar2(1000);
  l_msg                    varchar2(2000);

  /*For Bug No : 2602027 Start*/
  l_pos_id_flex_num     number;
  l_per_index           BINARY_INTEGER;
  l_pos_index           BINARY_INTEGER;
  tf                    BOOLEAN;
  nsegs                 NUMBER;
  possegs               FND_FLEX_EXT.SegmentArray;
  isegs                 FND_FLEX_EXT.SegmentArray;
  /*For Bug No : 2602027 End*/

  cursor c_ws_positions is
    select wpl.position_line_id, wlp.worksheet_id
      from psb_ws_position_lines  wpl,
           psb_ws_lines_positions wlp,
           psb_worksheets         ws
     where wpl.position_id = l_psb_position_id
       and wlp.position_line_id = wpl.position_line_id
       and ws.worksheet_id = wlp.worksheet_id
       and ws.global_worksheet_flag = 'Y';

  Cursor C_br_positions is
    Select brp.budget_revision_pos_line_id, brpl.budget_revision_id
      from psb_budget_revision_positions brp, psb_budget_revision_pos_lines brpl
     where brp.position_id = l_psb_position_id
       and brpl.budget_revision_pos_line_id = brp.budget_revision_pos_line_id;

  /*For Bug No : 2602027 Start*/
  Cursor C_flex_num is
	select position_structure
	  from per_business_groups
	 where business_group_id = p_business_group_id;

  Cursor C_pos_segs is
    select application_column_name
      from fnd_id_flex_segments_vl
     where id_flex_code = 'POS'
       and id_flex_num = l_pos_id_flex_num
       and enabled_flag = 'Y'
    order by segment_num;
  /*For Bug No : 2602027 End*/

Begin

  --hr_utility.trace_on;
  hr_utility.set_location('>> update position trans',777);
  hr_utility.set_location('>> p_position_transaction_id' || p_position_transaction_id,777);

 for c_trn_exist_rec in c_trn_exist loop
       l_trn_exist := FND_API.G_TRUE;
 end loop;

 if fnd_api.to_Boolean(l_trn_exist) THEN
 --++ main if ... do not process transaction if trn not in psb
 --++ update psb if called from create position and for apply process
 --++ for name and hr position id update  (a)

  /*For Bug No : 2738939 Start*/
  --added the TERMINATE in the following condition
  if ( (get_global('G_PSB_APPLICATION_ID') = 8401  and
	p_transaction_status not in ('REJECT','TERMINATE'))
     )  OR
       (p_transaction_status =  'APPLIED' ) then
  /*For Bug No : 2738939 End*/

    hr_utility.set_location('>> applid 8401 ' ,1777);

    For C_pos_trx_rec in C_pos_trx        -- psb_positions
    Loop
       l_psb_position_id := C_pos_trx_rec.position_id;
       -- de by org
       l_organization_id  := C_pos_trx_rec.organization_id;
       l_availability_status := null;
       l_data_extract_id := C_pos_trx_rec.data_extract_id;

       For C_data_extract_rec in C_data_extract
       Loop
	 l_set_of_books_id := C_data_extract_rec.set_of_books_id;
	 l_position_id_flex_num := C_data_extract_rec.position_id_flex_num;
       End Loop;

       hr_utility.set_location('>> l_position_id_flex_num '||
				   l_position_id_flex_num,777);

       For C_Avail_Status_Rec in C_Availability_Status
       Loop
	/*For Bug No 1527423 Start */
	--l_availability_status := C_avail_status_rec.shared_type_name;
	l_availability_status := C_avail_status_rec.system_type_cd;
	/*For Bug No 1527423 End */
       End loop;

       --++ restructure position name

     /*For Bug No : 2602027 Start*/

     For C_flex_rec in C_flex_num
     Loop
       l_pos_id_flex_num := C_flex_rec.position_structure;
     End Loop;

     tf := FND_FLEX_EXT.GET_SEGMENTS('PER', 'POS', l_pos_id_flex_num, p_position_definition_id, nsegs, segs);

     if (tf = FALSE) then
	l_msg := FND_MESSAGE.Get;
	FND_MESSAGE.SET_NAME('PSB','PSB_POS_DEFN_VALUE_ERROR');
	FND_MESSAGE.SET_TOKEN('POSITION_NAME',p_name );
	FND_MESSAGE.SET_TOKEN('ERR_MESG',l_msg);
	FND_MSG_PUB.Add;
	hr_utility.set_location('error in get segments',9850);
	RAISE FND_API.G_EXC_ERROR;
     end if;

     l_per_index := 1;
     l_init_index := 0;

     For k in 1..30
     Loop
      possegs(k) := null;
     End Loop;

     For C_pos_seg_rec in C_pos_segs
     Loop

      l_init_index := l_init_index + 1;

      If (C_pos_seg_rec.application_column_name = 'SEGMENT1') then
	 possegs(1) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT2') then
	 possegs(2) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT3') then
	 possegs(3) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT4') then
	 possegs(4) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT5') then
	 possegs(5) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT6') then
	 possegs(6) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT7') then
	 possegs(7) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT8') then
	 possegs(8) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT9') then
	 possegs(9) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT10') then
	 possegs(10) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT11') then
	 possegs(11) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT12') then
	 possegs(12) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT13') then
	 possegs(13) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT14') then
	 possegs(14) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT15') then
	 possegs(15) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT16') then
	 possegs(16) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT17') then
	 possegs(17) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT18') then
	 possegs(18) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT19') then
	 possegs(19) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT20') then
	 possegs(20) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT21') then
	 possegs(21) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT22') then
	 possegs(22) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT23') then
	 possegs(23) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT24') then
	 possegs(24) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT25') then
	 possegs(25) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT26') then
	 possegs(26) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT27') then
	 possegs(27) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT28') then
	 possegs(28) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT29') then
	 possegs(29) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT30') then
	 possegs(30) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;

     End Loop;
    /*For Bug No : 2602027 End*/

   For k in 1..30
   Loop
      isegs(k) := null;
   End Loop;

   l_pos_index := 0;

   FOR C_flex_rec in
   (
	Select application_column_name
	FROM   fnd_id_flex_segments_vl
	WHERE  id_flex_code = 'BPS'
	AND    id_flex_num  = l_position_id_flex_num
	AND    enabled_flag = 'Y'
	ORDER  BY segment_num
   )
   LOOP
	l_pos_index := l_pos_index + 1;
	isegs(l_pos_index) := NULL;

	IF (C_flex_rec.application_column_name = 'SEGMENT1') THEN
	    isegs(l_pos_index)   := possegs(1);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT2') THEN
	    isegs(l_pos_index)   := possegs(2);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT3') THEN
	    isegs(l_pos_index)   := possegs(3);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT4') THEN
	    isegs(l_pos_index)   := possegs(4);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT5') THEN
	    isegs(l_pos_index)   := possegs(5);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT6') THEN
	    isegs(l_pos_index)   := possegs(6);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT7') THEN
	    isegs(l_pos_index)   := possegs(7);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT8') THEN
	    isegs(l_pos_index)   := possegs(8);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT9') THEN
	    isegs(l_pos_index)   := possegs(9);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT10') THEN
	    isegs(l_pos_index)   := possegs(10);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT11') THEN
	    isegs(l_pos_index)   := possegs(11);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT12') THEN
	    isegs(l_pos_index)   := possegs(12);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT13') THEN
	    isegs(l_pos_index)   := possegs(13);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT14') THEN
	    isegs(l_pos_index)   := possegs(14);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT15') THEN
	    isegs(l_pos_index)   := possegs(15);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT16') THEN
	    isegs(l_pos_index)   := possegs(16);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT17') THEN
	    isegs(l_pos_index)   := possegs(17);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT18') THEN
	    isegs(l_pos_index)   := possegs(18);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT19') THEN
	    isegs(l_pos_index)   := possegs(19);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT20') THEN
	    isegs(l_pos_index)   := possegs(20);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT21') THEN
	    isegs(l_pos_index)   := possegs(21);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT22') THEN
	    isegs(l_pos_index)   := possegs(22);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT23') THEN
	    isegs(l_pos_index)   := possegs(23);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT24') THEN
	    isegs(l_pos_index)   := possegs(24);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT25') THEN
	    isegs(l_pos_index)   := possegs(25);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT26') THEN
	    isegs(l_pos_index)   := possegs(26);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT27') THEN
	    isegs(l_pos_index)   := possegs(27);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT28') THEN
	    isegs(l_pos_index)   := possegs(28);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT29') THEN
	    isegs(l_pos_index)   := possegs(29);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT30') THEN
	    isegs(l_pos_index)   := possegs(30);
	END IF;

      END LOOP; -- END LOOP ( C_flex_rec in C_flex )

   l_msg := null;
   if not fnd_flex_ext.Get_combination_id
	  ( application_short_name => 'PSB',
	    key_flex_code => 'BPS',
	    structure_number => l_position_id_flex_num,
	    validation_date => sysdate,
	    n_segments => l_pos_index,
	    segments => isegs,
	    combination_id => l_ccid)
   then
      l_msg := FND_MESSAGE.get;
      FND_MSG_PUB.Add;
      FND_MESSAGE.SET_NAME('PSB', 'PSB_INCREMENTAL_CCID_FAILURE');
      FND_MESSAGE.SET_TOKEN('ERRMESG',l_msg);
      hr_utility.set_location('error in get combination id',9867);
      RAISE FND_API.G_EXC_ERROR;
   end if;

   l_concat_pos_name := null;
   l_concat_pos_name := FND_FLEX_EXT.Get_Segs
			(application_short_name => 'PSB',
			 key_flex_code => 'BPS',
			 structure_number => l_position_id_flex_num,
			 combination_id => l_ccid);

  hr_utility.set_location('>> l_ccid '|| l_ccid,777);

  --++ end restructure

  PSB_POSITIONS_PVT.UPDATE_ROW
	  (
	    p_api_version            => 1.0,
	    p_init_msg_lISt          => FND_API.G_FALSE,
	    p_commit                 => FND_API.G_FALSE,
	    p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
	    p_return_status          => l_return_status,
	    p_msg_count              => l_msg_count,
	    p_msg_data               => l_msg_data,
	    p_position_id            => l_psb_position_id,
            -- de by org
            p_organization_id        => l_organization_id,
	    p_data_extract_id        => c_pos_trx_rec.data_extract_id,
	    p_position_definition_id => l_ccid,
	    p_hr_position_id         => p_position_id,
	    p_hr_employee_id         => c_pos_trx_rec.hr_employee_id,
	    p_business_group_id      => p_business_group_id,
	    p_effective_start_DATE   => p_effective_date,
	    p_effective_END_DATE     => p_date_end,
	    p_set_of_books_id        => c_pos_trx_rec.set_of_books_id,
	    p_vacant_position_flag   => c_pos_trx_rec.vacant_position_flag,
	    p_availability_status    => l_availability_status,
	    p_transaction_id         => p_position_transaction_id,
	    p_transaction_status     => p_transaction_status,
	    p_new_position_flag      => c_pos_trx_rec.new_position_flag ,
	    p_attribute1             => NULL,
	    p_attribute2             => NULL,
	    p_attribute3             => NULL,
	    p_attribute4             => NULL,
	    p_attribute5             => NULL,
	    p_attribute6             => NULL,
	    p_attribute7             => NULL,
	    p_attribute8             => NULL,
	    p_attribute9             => NULL,
	    p_attribute10            => NULL,
	    p_attribute11            => NULL,
	    p_attribute12            => NULL,
	    p_attribute13            => NULL,
	    p_attribute14            => NULL,
	    p_attribute15            => NULL,
	    p_attribute16            => NULL,
	    p_attribute17            => NULL,
	    p_attribute18            => NULL,
	    p_attribute19            => NULL,
	    p_attribute20            => NULL,
	    p_attribute_category     => NULL,
	    p_name                   => l_concat_pos_name,
	    p_mode                   => 'R'
	  );

   --++ update name and hr_position_id; when applied hr_position_id is set
   --++ to hr's position id

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.SET_NAME('PSB', 'PSB_PQH_UPDATE_FAILURE'  );

      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (p_transaction_status <>  'APPLIED') then

   hr_utility.set_location('>> DELETING records to recreate .... ' ,1777);
   Delete psb_position_assignments
    where position_id = l_psb_position_id;

   Populate_Salary_Assignments
     ( p_return_status   =>  l_return_status,
       p_position_id     =>  l_psb_position_id,
       p_date_effective  =>  p_date_effective,
       p_date_end        =>  p_date_end,
       p_data_extract_id =>  c_pos_trx_rec.data_extract_id,
       p_business_group_id => p_business_group_id,
       p_set_of_books_id   =>  l_set_of_books_id,
       p_entry_grade_rule_id  => p_entry_grade_rule_id,
       p_entry_step_id   => p_entry_step_id,
       p_entry_grade_id  => p_entry_grade_id,
       p_pay_basis_id    => p_pay_basis_id_o);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.SET_NAME('PSB', 'PSB_INCREMENTAL_SALARY_FAILURE'  );

      RAISE FND_API.G_EXC_ERROR;
   end if;

   Populate_Attribute_Assignments
   ( p_return_status            =>  l_return_status,
     p_new_position_id          =>  l_psb_position_id,
     p_position_transaction_id  =>  p_position_transaction_id,
     p_job_id                   =>  p_job_id,
     p_organization_id          =>  p_organization_id,
     p_fte                      =>  p_fte,
     p_frequency                =>  p_frequency,
     p_working_hours            =>  p_working_hours,
     p_earliest_hire_date       =>  p_earliest_hire_date,
     p_entry_grade_id           =>  p_entry_grade_id,
     p_date_effective           =>  p_date_effective,
     p_date_end                 =>  p_date_end,
     p_data_extract_id          =>  c_pos_trx_rec.data_extract_id,
     p_business_group_id        =>  p_business_group_id);

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     FND_MESSAGE.SET_NAME('PSB', 'PSB_INCREMENTAL_ATTRIBUTE_FAIL'  );
     RAISE FND_API.G_EXC_ERROR;
   end if;

   end if; --end of p_transaction_status <> applied

   End Loop;

  end if;
  --++ end process of modification

  --++ R e j e c t   process

  hr_utility.set_location('>> ....1 continue .... ' ,1777);

  /*For Bug No : 2738939 Start*/
  --included the TERMINATE also in the following check
  if (p_transaction_status in ('REJECT','TERMINATE'))
  then
  /*For Bug No : 2738939 End*/
    hr_utility.set_location('>> '||p_transaction_status ,1777);
    hr_utility.set_location('>> p_position_transaction_id' || p_position_transaction_id,777);
    For C_pos_trx_rec in C_pos_trx
    Loop
      l_psb_position_id := C_pos_trx_rec.position_id;
      hr_utility.set_location('>> l_psb_position_id '|| l_psb_position_id,1777);
    End Loop;

   if l_psb_position_id is not null then
    For c_ws_positions_rec in c_ws_positions loop

      PSB_WORKSHEET.Delete_WPL
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_worksheet_id => c_ws_positions_rec.worksheet_id,
	  p_position_line_id => c_ws_positions_rec.position_line_id);

    end loop;

    For c_br_positions_rec in c_br_positions loop

      PSB_BUDGET_REVISIONS_PVT.Delete_Revision_Positions
	 (p_api_version => 1.0,
	  p_return_status => l_return_status,
	  p_msg_count => l_msg_count,
	  p_msg_data => l_msg_data,
	  p_budget_revision_id => c_br_positions_rec.budget_revision_id,
	  p_budget_revision_pos_line_id => c_br_positions_rec.budget_revision_pos_line_id);

    end loop;

    delete from psb_position_assignments
    where position_id = l_psb_position_id;

    if sql%notfound then
       null;
    end if;

    PSB_POSITIONS_PVT.DELETE_ROW
    (
     p_api_version            => 1.0,
     p_init_msg_liSt          => FND_API.G_FALSE,
     p_commit                 => FND_API.G_FALSE,
     p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
     p_return_status          => l_return_status,
     p_msg_count              => l_msg_count,
     p_msg_data               => l_msg_data,
     p_position_id            => l_psb_position_id);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       hr_utility.set_location('>> pos delete row Error ' ,1777);
       RAISE FND_API.G_EXC_ERROR;
    END IF;
   end if; -- end of rejecct

  end if; -- end of application_id test
  end if; -- end of test l_trn_exist (a)
  --hr_utility.trace_off;

EXCEPTION
  --
  WHEN OTHERS THEN
    Process_Exception( l_api_name ) ;
  --
END Update_Position_Txn_Info;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                      PROCEDURE Insert_Position_Info                       |
 +===========================================================================*/
PROCEDURE Insert_Position_Info
(p_position_id                in NUMBER ,
 p_effective_start_date       in DATE   ,
 p_effective_end_date         in DATE   ,
 p_availability_status_id     in NUMBER ,
 p_business_group_id          in NUMBER ,
 p_entry_step_id              in NUMBER ,
 p_entry_grade_rule_id        in NUMBER ,
 p_job_id                     in NUMBER ,
 p_location_id                in NUMBER ,
 p_organization_id            in NUMBER ,
 p_position_definition_id     in NUMBER ,
 p_position_transaction_id    in NUMBER ,
 p_entry_grade_id             in NUMBER ,
 p_bargaining_unit_cd         in VARCHAR2 ,
 p_date_effective             in DATE   ,
 p_date_end                   in DATE   ,
 p_earliest_hire_date         in DATE   ,
 p_fill_by_date               in DATE   ,
 p_frequency                  in VARCHAR2  ,
 p_working_hours              in NUMBER ,
 p_fte                        in NUMBER    ,
 p_name                       in VARCHAR2  ,
 p_position_type              in VARCHAR2  ,
 p_pay_basis_id               in NUMBER    ,
 p_object_version_number      in NUMBER
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Position_Info';
  l_api_version         CONSTANT NUMBER         := 1.0;
  --
  l_rowid               varchar2(100);
  l_vacant_position_flag varchar2(1);
  l_date_end            date := to_date(null);
  l_data_extract_id     number := 0;
  l_validity_date       date := null;
  l_set_of_books_id     NUMBER;
  l_position_id_flex_num  number;
  segs                  FND_FLEX_EXT.SegmentArray;
  isegs                 FND_FLEX_EXT.SegmentArray;
  l_init_index          BINARY_INTEGER;
  l_pos_index           BINARY_INTEGER;
  l_ccid                NUMBER;
  l_position_id         NUMBER;
  l_concat_pos_name     varchar2(240);
  l_availability_status varchar2(30);

  /*For Bug No : 2602027 Start*/
  l_pos_id_flex_num     number;
  l_per_index           BINARY_INTEGER;
  tf                    BOOLEAN;
  nsegs                 NUMBER;
  possegs               FND_FLEX_EXT.SegmentArray;
  /*For Bug No : 2602027 End*/

  l_return_status          varchar2(1);
  l_msg_count              number;
  l_msg_data               varchar2(1000);
  l_msg                    varchar2(2000);

  Cursor C_avail_status is
   /*For Bug No : 1527423 Start*/
  --SELECT shared_type_name
    SELECT system_type_cd
   /*For Bug No : 1527423 End*/
      FROM per_shared_types
     WHERE lookup_type = 'POSITION_AVAILABILITY_STATUS'
       AND shared_type_id = p_availability_status_id;

  Cursor C_data_extract is
    SELECT business_group_id,
	   set_of_books_id,
	   position_id_flex_num,
	   req_data_as_of_date
      FROM psb_data_extracts
     WHERE data_extract_id = l_data_extract_id;

  /*For Bug No : 2602027 Start*/
  Cursor C_flex_num is
	select position_structure
	  from per_business_groups
	 where business_group_id = p_business_group_id;

  Cursor C_pos_segs is
    select application_column_name
      from fnd_id_flex_segments_vl
     where id_flex_code = 'POS'
       and id_flex_num = l_pos_id_flex_num
       and enabled_flag = 'Y'
    order by segment_num;
  /*For Bug No : 2602027 End*/

Begin

/* For Bug No : 2739450 Start*/
IF (p_position_transaction_id IS NULL) THEN
/*For Bug No. 2739450 End*/
  --hr_utility.trace_on;
   hr_utility.set_location(' Start Insert Position',777);

   hr_utility.set_location(' position_id '||p_position_id,881);
   hr_utility.set_location(' effective_start_date'||p_effective_start_date,881);
   hr_utility.set_location(' effective_end  _date '||p_effective_end_date,881);
   hr_utility.set_location(' availability stat '||p_availability_status_id,881);
   hr_utility.set_location(' business group stat '||p_business_group_id,881);
   hr_utility.set_location(' entry step id '||p_entry_step_id,881);
   hr_utility.set_location(' entry grade rule id '||p_entry_grade_rule_id,881);
   hr_utility.set_location(' entry job id '||p_job_id,881);
   hr_utility.set_location(' entry location id '||p_location_id,881);
   hr_utility.set_location(' entry org id '||p_organization_id,881);
   hr_utility.set_location(' pos definitio'||p_position_definition_id,881);
   hr_utility.set_location(' pos trans id'||p_position_transaction_id,881);
   hr_utility.set_location(' entry grage id'||p_entry_grade_id,881);
   hr_utility.set_location(' barganingin  d'||p_bargaining_unit_cd,881);
   hr_utility.set_location(' date eff   '||p_date_effective,881);
   hr_utility.set_location(' date end   '||p_date_end,881);
   hr_utility.set_location(' earliest hire date '||p_earliest_hire_date,881);
   hr_utility.set_location(' earliest fill date '||p_fill_by_date,881);
   hr_utility.set_location(' frequency '||p_frequency,881);
   hr_utility.set_location(' working hours '||p_working_hours,881);
   hr_utility.set_location(' fte '||p_fte,881);
   hr_utility.set_location(' name '||p_name,881);
   hr_utility.set_location(' position type '||p_position_type,881);
   hr_utility.set_location(' pay basis '||p_pay_basis_id,881);
   hr_utility.set_location(' object version # '||p_object_version_number,881);
   hr_utility.set_location(' applid >> '||get_global('G_PSB_APPLICATION_ID'),881);
   hr_utility.set_location(' revS   >> '||get_global('G_PSB_REVISION_START_DATE'),881);
   hr_utility.set_location(' revE   >> '||get_global('G_PSB_REVISION_END_DATE'),881);

   ---++++  start of code

   if (get_global('G_PSB_APPLICATION_ID') = 8401) then

   if (p_date_end = to_date('31124712','DDMMYYYY')) then
       l_date_end := to_date(null);
   else
       l_date_end := p_date_end;
   end if;

   l_data_extract_id := get_global('G_PSB_DATA_EXTRACT_ID');
   hr_utility.set_location(' Extract Id'||l_data_extract_id,881);

   For C_data_extract_rec in C_data_extract
   Loop
      l_set_of_books_id := C_data_extract_rec.set_of_books_id;
      l_position_id_flex_num := C_data_extract_rec.position_id_flex_num;
      --l_validity_date := C_data_extract_rec.req_data_as_of_date;
   End Loop;

   hr_utility.set_location(' Validity Date '||l_validity_date,881);
   hr_utility.set_location(' After Validity Date '||l_validity_date,881);

  /*For Bug No : 2602027 Start*/
  For C_flex_rec in C_flex_num
  Loop
    l_pos_id_flex_num := C_flex_rec.position_structure;
  End Loop;

  tf := FND_FLEX_EXT.GET_SEGMENTS('PER', 'POS', l_pos_id_flex_num, p_position_definition_id, nsegs, segs);
  if (tf = FALSE) then
	l_msg := FND_MESSAGE.Get;
	FND_MESSAGE.SET_NAME('PSB','PSB_POS_DEFN_VALUE_ERROR');
	FND_MESSAGE.SET_TOKEN('POSITION_NAME',p_name );
	FND_MESSAGE.SET_TOKEN('ERR_MESG',l_msg);
	FND_MSG_PUB.Add;
        hr_utility.set_location('error in get segments',9850);
	RAISE FND_API.G_EXC_ERROR;
  end if;

  l_per_index := 1;
  l_init_index := 0;
  For k in 1..30
  Loop
   possegs(k) := null;
  End Loop;

  For C_pos_seg_rec in C_pos_segs
  Loop
      l_init_index := l_init_index + 1;

      If (C_pos_seg_rec.application_column_name = 'SEGMENT1') then
	 possegs(1) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT2') then
	 possegs(2) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT3') then
	 possegs(3) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT4') then
	 possegs(4) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT5') then
	 possegs(5) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT6') then
	 possegs(6) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT7') then
	 possegs(7) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT8') then
	 possegs(8) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT9') then
	 possegs(9) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT10') then
	 possegs(10) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT11') then
	 possegs(11) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT12') then
	 possegs(12) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT13') then
	 possegs(13) := segs(l_per_index);
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT14') then
	 possegs(14) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT15') then
	 possegs(15) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT16') then
	 possegs(16) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT17') then
	 possegs(17) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT18') then
	 possegs(18) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT19') then
	 possegs(19) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT20') then
	 possegs(20) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT21') then
	 possegs(21) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT22') then
	 possegs(22) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT23') then
	 possegs(23) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT24') then
	 possegs(24) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT25') then
	 possegs(25) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT26') then
	 possegs(26) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT27') then
	 possegs(27) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT28') then
	 possegs(28) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT29') then
	 possegs(29) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT30') then
	 possegs(30) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;

   End Loop;
  /*For Bug No : 2602027 End*/

   For k in 1..30
   Loop
      isegs(k) := null;
   End Loop;

   l_pos_index := 0;

   FOR C_flex_rec in
   (
	Select application_column_name
	FROM   fnd_id_flex_segments_vl
	WHERE  id_flex_code = 'BPS'
	AND    id_flex_num  = l_position_id_flex_num
	AND    enabled_flag = 'Y'
	ORDER  BY segment_num
   )
   LOOP
	l_pos_index := l_pos_index + 1;
	isegs(l_pos_index) := NULL;

	IF (C_flex_rec.application_column_name = 'SEGMENT1') THEN
	    isegs(l_pos_index)   := possegs(1);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT2') THEN
	    isegs(l_pos_index)   := possegs(2);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT3') THEN
	    isegs(l_pos_index)   := possegs(3);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT4') THEN
	    isegs(l_pos_index)   := possegs(4);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT5') THEN
	    isegs(l_pos_index)   := possegs(5);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT6') THEN
	    isegs(l_pos_index)   := possegs(6);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT7') THEN
	    isegs(l_pos_index)   := possegs(7);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT8') THEN
	    isegs(l_pos_index)   := possegs(8);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT9') THEN
	    isegs(l_pos_index)   := possegs(9);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT10') THEN
	    isegs(l_pos_index)   := possegs(10);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT11') THEN
	    isegs(l_pos_index)   := possegs(11);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT12') THEN
	    isegs(l_pos_index)   := possegs(12);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT13') THEN
	    isegs(l_pos_index)   := possegs(13);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT14') THEN
	    isegs(l_pos_index)   := possegs(14);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT15') THEN
	    isegs(l_pos_index)   := possegs(15);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT16') THEN
	    isegs(l_pos_index)   := possegs(16);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT17') THEN
	    isegs(l_pos_index)   := possegs(17);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT18') THEN
	    isegs(l_pos_index)   := possegs(18);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT19') THEN
	    isegs(l_pos_index)   := possegs(19);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT20') THEN
	    isegs(l_pos_index)   := possegs(20);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT21') THEN
	    isegs(l_pos_index)   := possegs(21);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT22') THEN
	    isegs(l_pos_index)   := possegs(22);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT23') THEN
	    isegs(l_pos_index)   := possegs(23);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT24') THEN
	    isegs(l_pos_index)   := possegs(24);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT25') THEN
	    isegs(l_pos_index)   := possegs(25);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT26') THEN
	    isegs(l_pos_index)   := possegs(26);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT27') THEN
	    isegs(l_pos_index)   := possegs(27);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT28') THEN
	    isegs(l_pos_index)   := possegs(28);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT29') THEN
	    isegs(l_pos_index)   := possegs(29);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT30') THEN
	    isegs(l_pos_index)   := possegs(30);
	END IF;

      END LOOP; -- END LOOP ( C_flex_rec in C_flex )

   l_msg := null;
   if not fnd_flex_ext.Get_combination_id
	  ( application_short_name => 'PSB',
	    key_flex_code => 'BPS',
	    structure_number => l_position_id_flex_num,
	    validation_date => sysdate,
	    n_segments => l_pos_index,
	    segments => isegs,
	    combination_id => l_ccid)
   then
      l_msg := FND_MESSAGE.get;
      FND_MSG_PUB.ADD;
      FND_MESSAGE.SET_NAME('PSB', 'PSB_INCREMENTAL_CCID_FAILURE');
      FND_MESSAGE.SET_TOKEN('ERRMESG',l_msg);
      hr_utility.set_location('error in get combination id',9867);
      RAISE FND_API.G_EXC_ERROR;
   end if;

   hr_utility.set_location('pos id flex num in '||
		    l_position_id_flex_num || ' ccid ' || l_ccid ,9867);

   l_concat_pos_name := null;
   l_concat_pos_name := FND_FLEX_EXT.Get_Segs
			(application_short_name => 'PSB',
			 key_flex_code => 'BPS',
			 structure_number => l_position_id_flex_num,
			 combination_id => l_ccid);

   hr_utility.set_location('concat pos name is '|| l_concat_pos_name,9877);

   For C_avail_status_rec in C_avail_status
   Loop
     /*For Bug No 1527423 Start */
     --l_availability_status := C_avail_status_rec.shared_type_name;
     l_availability_status := C_avail_status_rec.system_type_cd;
     /*For Bug No 1527423 End */
   End loop;

   -- Create new position in PSB
      select psb_positions_s.nextval INTO l_position_id
	from dual;

      hr_utility.set_location('l_position_id '||l_position_id  ,9833);
      hr_utility.set_location('l_data_extract_id '||l_data_extract_id,   9833);
      hr_utility.set_location('l_ccid '||l_ccid  ,9833);
      hr_utility.set_location('p_position_id '||p_position_id  ,9833);
      hr_utility.set_location('p_business_group_id '||p_business_group_id,9833);
      hr_utility.set_location('p_date_effective, '||p_date_effective,   9833);
      hr_utility.set_location('l_date_end '||l_date_end  ,9833);
      hr_utility.set_location('l_set_of_books_id '||l_set_of_books_id  ,9833);
      hr_utility.set_location('l_vacant_position_flag '||
			       l_vacant_position_flag  ,9833);
      hr_utility.set_location('_availability_status '||
			       l_availability_status  ,9833);
      hr_utility.set_location('l_concat_pos_name '||l_concat_pos_name  ,9833);

    PSB_POSITIONS_PVT.INSERT_ROW
	(
	  p_api_version            => 1.0,
	  p_init_msg_lISt          => NULL,
	  p_commit                 => NULL,
	  p_validation_level       => NULL,
	  p_return_status          => l_return_status,
	  p_msg_count              => l_msg_count,
	  p_msg_data               => l_msg_data,
	  p_rowid                  => l_rowid,
	  p_position_id            => l_position_id,
          -- de by org
          p_organization_id        => p_organization_id,
	  p_data_extract_id        => l_data_extract_id,
	  p_position_definition_id => l_ccid,
	  p_hr_position_id         => p_position_id,
	  p_hr_employee_id         => NULL,
	  p_business_group_id      => p_business_group_id,
	  p_effective_start_DATE   => p_date_effective,
	  p_effective_END_DATE     => l_date_end,
	  p_set_of_books_id        => l_set_of_books_id,
	  p_vacant_position_flag   => 'Y',
	  p_availability_status    => l_availability_status,
	  p_transaction_id         => null,
	  p_transaction_status     => 'SUCCESS',
	  p_new_position_flag      => 'Y',
	  p_attribute1             => NULL,
	  p_attribute2             => NULL,
	  p_attribute3             => NULL,
	  p_attribute4             => NULL,
	  p_attribute5             => NULL,
	  p_attribute6             => NULL,
	  p_attribute7             => NULL,
	  p_attribute8             => NULL,
	  p_attribute9             => NULL,
	  p_attribute10            => NULL,
	  p_attribute11            => NULL,
	  p_attribute12            => NULL,
	  p_attribute13            => NULL,
	  p_attribute14            => NULL,
	  p_attribute15            => NULL,
	  p_attribute16            => NULL,
	  p_attribute17            => NULL,
	  p_attribute18            => NULL,
	  p_attribute19            => NULL,
	  p_attribute20            => NULL,
	  p_attribute_category     => NULL,
	  p_name                   => l_concat_pos_name,
	  p_mode                   => 'R'
	);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      hr_utility.set_location('error in insert position',9877);
      FND_MESSAGE.SET_NAME('PSB', 'PSB_POS_INSERT_FAILURE'  );

      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /*Bug:5450510: Added parameter p_data_extract_id to the following api.*/
   --++ add  to position sets for WS recalc
   PSB_Budget_Position_Pvt.Add_Position_To_Position_Sets (
	    p_api_version       => 1.0,
	    p_init_msg_list     => FND_API.G_TRUE,
	    p_commit            => NULL,
	    p_validation_level  => NULL,
	    p_return_status     => l_return_status,
	    p_msg_count         => l_msg_count,
	    p_msg_data          => l_msg_data,
	    p_position_id       => l_position_id,
	    p_data_extract_id   => l_data_extract_id
	  ) ;

   hr_utility.set_location(' end add psb positions'||l_position_id,1333);

   -- Populate Salary Assignments
   hr_utility.set_location(' Before Salary Assignment'||l_position_id,333);

   Populate_Salary_Assignments
     ( p_return_status   =>  l_return_status,
       p_position_id     =>  l_position_id,
       p_date_effective  =>  p_date_effective,
       p_date_end        =>  p_date_end,
       p_data_extract_id =>  l_data_extract_id,
       p_business_group_id => p_business_group_id,
       p_set_of_books_id   =>  l_set_of_books_id,
       p_entry_grade_rule_id  => p_entry_grade_rule_id,
       p_entry_step_id   => p_entry_step_id,
       p_entry_grade_id  => p_entry_grade_id,
       p_pay_basis_id    => p_pay_basis_id);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.SET_NAME('PSB', 'PSB_INCREMENTAL_SALARY_FAILURE'  );

      RAISE FND_API.G_EXC_ERROR;
   END IF;

   Populate_Attribute_Assignments
   ( p_return_status            =>  l_return_status,
     p_new_position_id          =>  l_position_id,
     p_position_id              =>  p_position_id,
     p_job_id                   =>  p_job_id,
     p_organization_id          =>  p_organization_id,
     p_fte                      =>  p_fte,
     p_frequency                =>  p_frequency,
     p_working_hours            =>  p_working_hours,
     p_earliest_hire_date       =>  p_earliest_hire_date,
     p_entry_grade_id           =>  p_entry_grade_id,
     p_date_effective           =>  p_date_effective,
     p_date_end                 =>  l_date_end,
     p_data_extract_id          =>  l_data_extract_id,
     p_business_group_id        =>  p_business_group_id
   ) ;
   --
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     FND_MESSAGE.SET_NAME('PSB', 'PSB_INCREMENTAL_ATTRIBUTE_FAIL'  );
     RAISE FND_API.G_EXC_ERROR;
   END IF;

    hr_utility.set_location(' org id is ' || get_global('G_PSB_ORG_ID')  ,888);
    hr_utility.set_location(' bg id is ' || get_global('G_PSB_BUDGET_GROUP_ID')  ,888);
    hr_utility.set_location(' ws id is ' || get_global('G_PSB_WORKSHEET_ID')  ,888);

    Update_Worksheet_Values ( p_return_status  => l_return_status,
			      p_position_id    => l_position_id,
			      p_org_id         => p_organization_id);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      hr_utility.set_location(' fail to update ws value ',888);
      FND_MESSAGE.SET_NAME('PSB', 'PSB_INCREMENTAL_WS_FAILURE'  );
      RAISE FND_API.G_EXC_ERROR;

      RAISE FND_API.G_EXC_ERROR;
   END IF;
   hr_utility.set_location(' Insert Position Info Success',555);

 end if;

  --hr_utility.trace_off;
/* For Bug No : 2739450 Start*/
 END IF;
/* For Bug No : 2739450 End*/

EXCEPTION
  --
  WHEN OTHERS THEN
    Process_Exception( l_api_name ) ;
  --
END Insert_Position_Info;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                       PROCEDURE Update_Position_Info                      |
 +===========================================================================*/
PROCEDURE Update_Position_Info
(p_position_id                in NUMBER ,
 p_effective_start_date       in DATE   ,
 p_effective_end_date         in DATE   ,
 p_availability_status_id     in NUMBER ,
 p_business_group_id_o        in NUMBER ,
 p_entry_step_id              in NUMBER ,
 p_entry_grade_rule_id        in NUMBER ,
 p_job_id_o                   in NUMBER ,
 p_location_id                in NUMBER ,
 p_organization_id_o          in NUMBER ,
 p_position_definition_id     in NUMBER ,
 p_position_transaction_id    in NUMBER ,
 p_entry_grade_id             in NUMBER ,
 p_bargaining_unit_cd         in VARCHAR2 ,
 p_date_effective             in DATE   ,
 p_date_end                   in DATE   ,
 p_earliest_hire_date         in DATE   ,
 p_fill_by_date               in DATE   ,
 p_frequency                  in VARCHAR2  ,
 p_working_hours              in NUMBER,
 p_fte                        in NUMBER    ,
 p_name                       in VARCHAR2  ,
 p_position_type              in VARCHAR2  ,
 p_pay_basis_id               in NUMBER    ,
 p_object_version_number      in NUMBER    ,
 p_effective_date             in DATE
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Position_Info' ;
  l_api_version         CONSTANT NUMBER         := 1.0 ;
  --
  l_data_extract_id NUMBER := 0;
  l_position_id_flex_num  number;
  l_concat_pos_name     varchar2(240);
  l_init_index          BINARY_INTEGER;
  l_ccid                number;
  segs                  FND_FLEX_EXT.SegmentArray;

  /*For Bug No : 2602027 Start*/
  l_pos_id_flex_num     number;
  l_per_index           BINARY_INTEGER;
  l_pos_index           BINARY_INTEGER;
  tf                    BOOLEAN;
  nsegs                 NUMBER;
  possegs               FND_FLEX_EXT.SegmentArray;
  isegs                 FND_FLEX_EXT.SegmentArray;
  /*For Bug No : 2602027 End*/

  Cursor C_pos_trx is
     Select *
       from psb_positions
      where hr_position_id  = p_position_id
	and data_extract_id = l_data_extract_id;

  Cursor C_availability_status  is
   /*For Bug No : 1527423 Start*/
  --select shared_type_name
    select system_type_cd
   /*For Bug No : 1527423 End*/
      from per_shared_types
     where lookup_type = 'POSITION_AVAILABILITY_STATUS'
       and shared_type_id = p_availability_status_id;

  Cursor C_data_extract is
    --SELECT req_data_as_of_date
    SELECT business_group_id,
	   set_of_books_id,
	   position_id_flex_num,
	   req_data_as_of_date
      FROM psb_data_extracts
     WHERE data_extract_id = l_data_extract_id;

  /*For Bug No : 2602027 Start*/
  Cursor C_flex_num is
	select position_structure
	  from per_business_groups
	 where business_group_id = p_business_group_id_o;

  Cursor C_pos_segs is
    select application_column_name
      from fnd_id_flex_segments_vl
     where id_flex_code = 'POS'
       and id_flex_num = l_pos_id_flex_num
       and enabled_flag = 'Y'
    order by segment_num;
  /*For Bug No : 2602027 End*/

  l_psb_position_id        number := '';
  -- de by org
  l_organization_id        number;
  l_validity_date          date := null;
  l_availability_status    varchar2(30);
  l_return_status          varchar2(1);
  l_msg_count              number;
  l_msg_data               varchar2(1000);
  l_msg                    varchar2(2000);

Begin

/* For Bug No : 2739450 Start*/
IF (p_position_transaction_id IS NULL) THEN
/*For Bug No. 2739450 End*/
  --hr_utility.trace_on;
  hr_utility.set_location(' position_id '||p_position_id,881);
   hr_utility.set_location(' effective_start_date '||p_effective_start_date,881);
   hr_utility.set_location(' effective_end  _date '||p_effective_end_date,881);
   hr_utility.set_location(' availability stat '||p_availability_status_id,881);
   hr_utility.set_location(' business group stat '||p_business_group_id_o,881);
   hr_utility.set_location(' entry step id '||p_entry_step_id,881);
   hr_utility.set_location(' entry grade rule id '||p_entry_grade_rule_id,881);
   hr_utility.set_location(' entry job id '||p_job_id_o,881);
   hr_utility.set_location(' entry location id '||p_location_id,881);
   hr_utility.set_location(' entry org id '||p_organization_id_o,881);
   hr_utility.set_location(' pos definitio'||p_position_definition_id,881);
   hr_utility.set_location(' pos trans id'||p_position_transaction_id,881);
   hr_utility.set_location(' entry grage id'||p_entry_grade_id,881);
   hr_utility.set_location(' barganingin  d'||p_bargaining_unit_cd,881);
   hr_utility.set_location(' date eff   '||p_date_effective,881);
   hr_utility.set_location(' date end   '||p_date_end,881);
   hr_utility.set_location(' earliest hire date '||p_earliest_hire_date,881);
   hr_utility.set_location(' earliest fill date '||p_fill_by_date,881);
   hr_utility.set_location(' frequency '||p_frequency,881);
   hr_utility.set_location(' working hours '||p_working_hours,881);
   hr_utility.set_location(' fte '||p_fte,881);
   hr_utility.set_location(' name '||p_name,881);
   hr_utility.set_location(' position type '||p_position_type,881);
   hr_utility.set_location(' pay basis '||p_pay_basis_id,881);
   hr_utility.set_location(' object version # '||p_object_version_number,881);
   hr_utility.set_location(' p_effective_date '||p_effective_date, 8887);
   hr_utility.set_location(' *****************set up ************', 8887);
   hr_utility.set_location(' ****  in update position info',777);

   if (get_global('G_PSB_APPLICATION_ID') = 8401) then

    l_data_extract_id := get_global('G_PSB_DATA_EXTRACT_ID');
    hr_utility.set_location(' l_data_extract '||l_data_extract_id, 8887);

    For C_data_extract_rec in C_data_extract
    Loop
      l_validity_date := C_data_extract_rec.req_data_as_of_date;
      l_position_id_flex_num := C_data_extract_rec.position_id_flex_num;
    End Loop;

  For C_pos_trx_rec in C_pos_trx
  Loop
    l_psb_position_id := C_pos_trx_rec.position_id;
    l_organization_id := C_pos_trx_rec.organization_id;
    l_availability_status := null;

    For C_Avail_Status_Rec in C_Availability_Status
    Loop
     /*For Bug No 1527423 Start */
     --l_availability_status := C_avail_status_rec.shared_type_name;
     l_availability_status := C_avail_status_rec.system_type_cd;
     /*For Bug No 1527423 End */
    End loop;

    /*For Bug No : 2602027 Start*/
    For C_flex_rec in C_flex_num
    Loop
      l_pos_id_flex_num := C_flex_rec.position_structure;
    End Loop;

    tf := FND_FLEX_EXT.GET_SEGMENTS('PER', 'POS', l_pos_id_flex_num, p_position_definition_id, nsegs, segs);
    if (tf = FALSE) then
	l_msg := FND_MESSAGE.Get;
	FND_MESSAGE.SET_NAME('PSB','PSB_POS_DEFN_VALUE_ERROR');
	FND_MESSAGE.SET_TOKEN('POSITION_NAME',p_name );
	FND_MESSAGE.SET_TOKEN('ERR_MESG',l_msg);
	FND_MSG_PUB.Add;
	hr_utility.set_location('error in get segments',9850);
	RAISE FND_API.G_EXC_ERROR;
    end if;

    l_per_index := 1;
    l_init_index := 0;

    For k in 1..30
    Loop
     possegs(k) := null;
    End Loop;

    For C_pos_seg_rec in C_pos_segs
    Loop
      l_init_index := l_init_index + 1;

      If (C_pos_seg_rec.application_column_name = 'SEGMENT1') then
	 possegs(1) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT2') then
	 possegs(2) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT3') then
	 possegs(3) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT4') then
	 possegs(4) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT5') then
	 possegs(5) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT6') then
	 possegs(6) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT7') then
	 possegs(7) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT8') then
	 possegs(8) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT9') then
	 possegs(9) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT10') then
	 possegs(10) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT11') then
	 possegs(11) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT12') then
	 possegs(12) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT13') then
	 possegs(13) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT14') then
	 possegs(14) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT15') then
	 possegs(15) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT16') then
	 possegs(16) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT17') then
	 possegs(17) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT18') then
	 possegs(18) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT19') then
	 possegs(19) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT20') then
	 possegs(20) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT21') then
	 possegs(21) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT22') then
	 possegs(22) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT23') then
	 possegs(23) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT24') then
	 possegs(24) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT25') then
	 possegs(25) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT26') then
	 possegs(26) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT27') then
	 possegs(27) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT28') then
	 possegs(28) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT29') then
	 possegs(29) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;
      If (C_pos_seg_rec.application_column_name = 'SEGMENT30') then
	 possegs(30) := segs(l_per_index);
	 l_per_index := l_per_index + 1;
      end if;

    End Loop;
   /*For Bug No : 2602027 End*/

   For k in 1..30
   Loop
      isegs(k) := null;
   End Loop;

   l_pos_index := 0;

   FOR C_flex_rec in
   (
	Select application_column_name
	FROM   fnd_id_flex_segments_vl
	WHERE  id_flex_code = 'BPS'
	AND    id_flex_num  = l_position_id_flex_num
	AND    enabled_flag = 'Y'
	ORDER  BY segment_num
   )
   LOOP
	l_pos_index := l_pos_index + 1;
	isegs(l_pos_index) := NULL;

	IF (C_flex_rec.application_column_name = 'SEGMENT1') THEN
	    isegs(l_pos_index)   := possegs(1);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT2') THEN
	    isegs(l_pos_index)   := possegs(2);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT3') THEN
	    isegs(l_pos_index)   := possegs(3);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT4') THEN
	    isegs(l_pos_index)   := possegs(4);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT5') THEN
	    isegs(l_pos_index)   := possegs(5);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT6') THEN
	    isegs(l_pos_index)   := possegs(6);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT7') THEN
	    isegs(l_pos_index)   := possegs(7);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT8') THEN
	    isegs(l_pos_index)   := possegs(8);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT9') THEN
	    isegs(l_pos_index)   := possegs(9);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT10') THEN
	    isegs(l_pos_index)   := possegs(10);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT11') THEN
	    isegs(l_pos_index)   := possegs(11);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT12') THEN
	    isegs(l_pos_index)   := possegs(12);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT13') THEN
	    isegs(l_pos_index)   := possegs(13);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT14') THEN
	    isegs(l_pos_index)   := possegs(14);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT15') THEN
	    isegs(l_pos_index)   := possegs(15);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT16') THEN
	    isegs(l_pos_index)   := possegs(16);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT17') THEN
	    isegs(l_pos_index)   := possegs(17);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT18') THEN
	    isegs(l_pos_index)   := possegs(18);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT19') THEN
	    isegs(l_pos_index)   := possegs(19);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT20') THEN
	    isegs(l_pos_index)   := possegs(20);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT21') THEN
	    isegs(l_pos_index)   := possegs(21);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT22') THEN
	    isegs(l_pos_index)   := possegs(22);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT23') THEN
	    isegs(l_pos_index)   := possegs(23);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT24') THEN
	    isegs(l_pos_index)   := possegs(24);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT25') THEN
	    isegs(l_pos_index)   := possegs(25);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT26') THEN
	    isegs(l_pos_index)   := possegs(26);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT27') THEN
	    isegs(l_pos_index)   := possegs(27);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT28') THEN
	    isegs(l_pos_index)   := possegs(28);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT29') THEN
	    isegs(l_pos_index)   := possegs(29);
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT30') THEN
	    isegs(l_pos_index)   := possegs(30);
	END IF;

    END LOOP; -- END LOOP ( C_flex_rec in C_flex )

   l_msg := null;

   if not fnd_flex_ext.Get_combination_id
	  ( application_short_name => 'PSB',
	    key_flex_code => 'BPS',
	    structure_number => l_position_id_flex_num,
	    validation_date => sysdate,
	    n_segments => l_pos_index,
	    segments => isegs,
	    combination_id => l_ccid)
   then
      l_msg := FND_MESSAGE.get;
      FND_MSG_PUB.Add;
      FND_MESSAGE.SET_NAME('PSB', 'PSB_INCREMENTAL_CCID_FAILURE');
      FND_MESSAGE.SET_TOKEN('ERRMESG',l_msg);
      hr_utility.set_location('error in get combination id',9867);
      RAISE FND_API.G_EXC_ERROR;
   end if;

   hr_utility.set_location('pos id flex num in '||
                         l_position_id_flex_num || ' ccid ' || l_ccid ,9867);

   l_concat_pos_name := null;
   l_concat_pos_name := FND_FLEX_EXT.Get_Segs
			(application_short_name => 'PSB',
			 key_flex_code => 'BPS',
			 structure_number => l_position_id_flex_num,
			 combination_id => l_ccid);
   hr_utility.set_location('concat pos name is '|| l_concat_pos_name,9877);
   hr_utility.set_location(' before insert ' ,881);
   hr_utility.set_location(' l_psb_position_id '|| l_psb_position_id , 881);
   hr_utility.set_location(' l_data_extract_id '|| l_data_extract_id ,881);
   hr_utility.set_location(' p_position_definition_id '|| p_position_definition_id ,881);
   hr_utility.set_location(' p_position_id '|| p_position_id ,881);
   hr_utility.set_location(' c_pos_trx_rec.hr_employee_id '||
			     c_pos_trx_rec.hr_employee_id ,881);
   hr_utility.set_location(' p_business_group_id_o '|| p_business_group_id_o ,881);
   hr_utility.set_location(' p_effective_dat '|| p_effective_date ,881);
   hr_utility.set_location(' p_date_end '|| p_date_end ,881);
   hr_utility.set_location(' c_pos_trx_rec.set_of_books_id '||
			     c_pos_trx_rec.set_of_books_id ,881);
   hr_utility.set_location(' c_pos_trx_rec.vacant_position_flag '||
			     c_pos_trx_rec.vacant_position_flag ,881);
   hr_utility.set_location(' l_availability_status '|| l_availability_status ,881);
   hr_utility.set_location(' c_pos_trx_rec.transaction_id '||
			     c_pos_trx_rec.transaction_id ,881);
   hr_utility.set_location(' c_pos_trx_rec.transaction_status '||
			     c_pos_trx_rec.transaction_status ,881);
   hr_utility.set_location('  p_name '||p_name,881);

   hr_utility.set_location(' before update position', 1887);
   -- ++++++

   PSB_POSITIONS_PVT.UPDATE_ROW
       (
	 p_api_version            => 1.0,
	 p_init_msg_lISt          => FND_API.G_FALSE,
	 p_commit                 => FND_API.G_FALSE,
	 p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
	 p_return_status          => l_return_status,
	 p_msg_count              => l_msg_count,
	 p_msg_data               => l_msg_data,
	 p_position_id            => l_psb_position_id,
         -- de by org
         p_organization_id        => p_organization_id_o,
	 p_data_extract_id        => l_data_extract_id,
	 p_position_definition_id => l_ccid,
	 p_hr_position_id         => p_position_id,
	 p_hr_employee_id         => c_pos_trx_rec.hr_employee_id,
	 p_business_group_id      => p_business_group_id_o,
	 p_effective_start_DATE   => p_effective_date,
	 p_effective_END_DATE     => p_date_end,
	 p_set_of_books_id        => c_pos_trx_rec.set_of_books_id,
	 p_vacant_position_flag   => c_pos_trx_rec.vacant_position_flag,
	 p_availability_status    => l_availability_status,
	 p_transaction_id         => c_pos_trx_rec.transaction_id,
	 p_transaction_status     => c_pos_trx_rec.transaction_status,
	 p_new_position_flag      => c_pos_trx_rec.new_position_flag ,
	 p_attribute1             => NULL,
	 p_attribute2             => NULL,
	 p_attribute3             => NULL,
	 p_attribute4             => NULL,
	 p_attribute5             => NULL,
	 p_attribute6             => NULL,
	 p_attribute7             => NULL,
	 p_attribute8             => NULL,
	 p_attribute9             => NULL,
	 p_attribute10            => NULL,
	 p_attribute11            => NULL,
	 p_attribute12            => NULL,
	 p_attribute13            => NULL,
	 p_attribute14            => NULL,
	 p_attribute15            => NULL,
	 p_attribute16            => NULL,
	 p_attribute17            => NULL,
	 p_attribute18            => NULL,
	 p_attribute19            => NULL,
	 p_attribute20            => NULL,
	 p_attribute_category     => NULL,
	 p_name                   => l_concat_pos_name,
	 p_mode                   => 'R'
       );

   hr_utility.set_location(' after update position', 1887);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      hr_utility.set_location(' posb fail after update position', 1887);
      FND_MESSAGE.SET_NAME('PSB', 'PSB_POS_UPDATE_FAILURE'  );

      RAISE FND_API.G_EXC_ERROR;
   END IF;

   Delete psb_position_assignments
    where position_id = l_psb_position_id;

   Populate_Salary_Assignments
     ( p_return_status   =>  l_return_status,
       p_position_id     =>  l_psb_position_id,
       p_date_effective  =>  p_date_effective,
       p_date_end        =>  p_date_end,
       p_data_extract_id =>  c_pos_trx_rec.data_extract_id,
       p_business_group_id => p_business_group_id_o,
       p_set_of_books_id   =>  c_pos_trx_rec.set_of_books_id,
       p_entry_grade_rule_id  => p_entry_grade_rule_id,
       p_entry_step_id   => p_entry_step_id,
       p_entry_grade_id  => p_entry_grade_id,
       p_pay_basis_id    => p_pay_basis_id);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.SET_NAME('PSB', 'PSB_INCREMENTAL_SALARY_FAILURE'  );

      RAISE FND_API.G_EXC_ERROR;
   END IF;

 Populate_Attribute_Assignments
 ( p_return_status            =>  l_return_status,
   p_new_position_id          =>  l_psb_position_id,
   p_position_id              =>  p_position_id,
   p_job_id                   =>  p_job_id_o,
   p_organization_id          =>  p_organization_id_o,
   p_fte                      =>  p_fte,
   p_frequency                =>  p_frequency,
   p_working_hours            =>  p_working_hours,
   p_earliest_hire_date       =>  p_earliest_hire_date,
   p_entry_grade_id           =>  p_entry_grade_id,
   p_date_effective           =>  p_date_effective,
   p_date_end                 =>  p_date_end,
   p_data_extract_id          =>  c_pos_trx_rec.data_extract_id,
   p_business_group_id        =>  p_business_group_id_o);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
      FND_MESSAGE.SET_NAME('PSB', 'PSB_INCREMENTAL_ATTRIBUTE_FAIL'  );

   END IF;

   End Loop;

   Update_Worksheet_Values ( p_return_status   => l_return_status,
			      p_position_id    => l_psb_position_id,
			      p_org_id         => p_organization_id_o);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      hr_utility.set_location(' fail to update ws value ',888);
      FND_MESSAGE.SET_NAME('PSB', 'PSB_INCREMENTAL_WS_FAILURE'  );
      RAISE FND_API.G_EXC_ERROR;

      RAISE FND_API.G_EXC_ERROR;
   END IF;

  end if;

  --hr_utility.trace_off;
/* For Bug No : 2739450 Start*/
 END IF;
/* For Bug No : 2739450 End*/

EXCEPTION
  --
  WHEN OTHERS THEN
    Process_Exception( l_api_name ) ;
  --
END Update_Position_Info;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
-- Update worksheet if incremental called from worksheet or budget revision
PROCEDURE Update_Worksheet_Values
 ( p_return_status            OUT  NOCOPY  VARCHAR2,
   p_position_id               in  NUMBER ,
   p_org_id                    in  NUMBER)
AS
  l_position_line_id number;
  l_return_status          varchar2(1);
  l_msg_count              number;
  l_msg_data               varchar2(1000);

  l_org_budget_group_id    number;
  l_in_org_id              number;
  l_in_bg_id               number;
  l_budget_rev_pos_line_id    NUMBER;

  -- start bug 3253644
  l_budget_group_id        NUMBER;
  l_budget_revision_id     NUMBER;
  l_root_budget_group 	   VARCHAR2(1);
  -- end bug 3253644

  cursor bgorg is
     select budget_group_id
     from psb_budget_groups
     where (organization_id = l_in_org_id or
	    business_group_id = l_in_org_id   )
     start with budget_group_id = l_in_bg_id
     connect by prior budget_group_id = parent_budget_group_id;

BEGIN

  --hr_utility.trace_on;
  IF get_global('G_PSB_CURRENT_FORM') <>  'PSBWMPMD'  and
     get_global('G_PSB_CURRENT_FORM') <>  'PSBBGRVS' THEN
     hr_utility.set_location(' exiting.. not from ws/bg',333);
     RETURN;
  END IF;

   hr_utility.set_location(' Inside update ws values',333);
   hr_utility.set_location(' WS id' || PSB_HR_POPULATE_DATA_PVT.get_global('G_PSB_WORKSHEET_ID'),333);
   hr_utility.set_location(' BG id' || PSB_HR_POPULATE_DATA_PVT.get_global('G_PSB_BUDGET_GROUP_ID'),333);
   hr_utility.set_location(' org id is ' || get_global('G_PSB_ORG_ID')  ,888);
   hr_utility.set_location(' positionid  ' || p_position_id ,888);

   -- get first budget group associated to input organization starting within the input bg's hierarchy
   -- use position's org id
   --l_in_org_id := get_global('G_PSB_ORG_ID');

   l_in_org_id := p_org_id;
   l_in_bg_id  := get_global('G_PSB_BUDGET_GROUP_ID');

   open bgorg;
   fetch bgorg into l_org_budget_group_id;
   if (bgorg%notfound) then
      close bgorg;
      raise FND_API.G_EXC_ERROR ;
   end if;
   close bgorg;


   hr_utility.set_location(' out org id   ' || l_org_budget_group_id ,888);
   IF get_global('G_PSB_CURRENT_FORM') = 'PSBWMPMD' THEN
      PSB_WS_POSITION_CR_LINES_I_PVT.Insert_Row
	    (
	    p_api_version                =>    1.0,
	    p_init_msg_list              =>    FND_API.G_TRUE,
	    p_commit                     =>    FND_API.G_FALSE,
	    p_validation_level           =>    FND_API.G_VALID_LEVEL_FULL,
	    p_return_status              =>    l_return_status,
	    p_msg_count                  =>    l_msg_count,
	    p_msg_data                   =>    l_msg_data,
	    p_worksheet_id               =>    PSB_HR_POPULATE_DATA_PVT.get_global('G_PSB_WORKSHEET_ID'),
	    p_position_id                =>    p_position_id,
	    p_budget_group_id            =>    l_org_budget_group_id,
	    p_position_line_id           =>    l_position_line_id);

      hr_utility.set_location(' l_position_line_id is ' || l_position_line_id,333);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS then
	   hr_utility.set_location(' fail to insert row ',888);
	   --hr_utility.trace_off;
	 FND_MESSAGE.SET_NAME('PSB', 'PSB_INCR_INSERT_POS_WS_FAIL');
	 raise FND_API.G_EXC_ERROR;
      END IF;
    --++ end ws
    ELSE

      PSB_BUDGET_REVISIONS_PVT.Create_Revision_Positions
	    (p_api_version => 1.0,
	     p_return_status => l_return_status,
	     p_msg_count => l_msg_count,
	     p_msg_data => l_msg_data,
	     p_budget_revision_id =>  PSB_HR_POPULATE_DATA_PVT.get_global('G_PSB_WORKSHEET_ID'),
	     p_budget_revision_pos_line_id => l_budget_rev_pos_line_id,
	     p_position_id => p_position_id,
	     p_budget_group_id => l_org_budget_group_id,
	     p_effective_start_date =>
				   PSB_HR_POPULATE_DATA_PVT.get_global('G_PSB_REVISION_START_DATE'),
	     p_effective_end_date => PSB_HR_POPULATE_DATA_PVT.get_global('G_PSB_REVISION_END_DATE'),
	     p_revision_type => null,
	     p_revision_value_type => null,
	     p_revision_value => null,
	     p_note_id => null,
	     p_freeze_flag => 'N',
	     p_view_line_flag => 'Y');

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	FND_MESSAGE.SET_NAME('PSB', 'PSB_INCR_INSERT_POS_REV_FAIL');
	raise FND_API.G_EXC_ERROR;
      else
        -- update the position table for system data extract with budget group ID
	-- start bug 3253644

	l_budget_revision_id := PSB_HR_POPULATE_DATA_PVT.get_global('G_PSB_WORKSHEET_ID');

        FOR l_bud_group_csr IN (
            SELECT a.budget_group_id, b.root_budget_group
  	      FROM psb_budget_revisions a,
                   psb_budget_groups b
  	     WHERE a.budget_revision_id = l_budget_revision_id
               AND a.budget_group_id = b.budget_group_id) lOOP

	  l_budget_group_id   := l_bud_group_csr.budget_group_id;
	  l_root_budget_group := l_bud_group_csr.root_budget_group;

        END LOOP;

	IF NVL(l_root_budget_group, 'N') = 'Y' THEN
	  UPDATE psb_positions
	     SET budget_group_id = l_org_budget_group_id
	   WHERE position_id = p_position_id;
        ELSE
	  UPDATE psb_positions
	     SET budget_group_id = l_budget_group_id
	   WHERE position_id = p_position_id;
        END IF;
	-- end bug 3253644
      end if;

   END IF;

   p_return_status := FND_API.G_RET_STS_SUCCESS;
   --hr_utility.trace_off;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
   --hr_utility.trace_off;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   --hr_utility.trace_off;

  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   --hr_utility.trace_off;

END Update_Worksheet_Values;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Salary_Distributions
( p_return_status       OUT  NOCOPY  VARCHAR2,
  p_data_extract_id     IN   NUMBER,
  p_extract_method      IN   VARCHAR2,
  p_restart_position_id IN   NUMBER,
  -- de by org
  p_extract_by_org      IN   VARCHAR2
) AS

  l_return_status    VARCHAR2(1);
  l_msg_data         VARCHAR2(1000);
  l_msg_count        number;
  l_position_name    varchar2(240);
  --UTF8 changes for Bug#2615261
  l_employee_name    varchar2(310);
  l_position_ctr     number := 0;
  l_fin_position_id  number := 0;

  -- Bug#3615301: Perf issue.
  -- Bug#3073519: Modified cursor.
  CURSOR c_Positions IS
  SELECT PP.position_id,
         -- de by org
         PP.organization_id,
         PP.hr_employee_id,
         PP.effective_start_DATE,
         PP.effective_END_DATE
  FROM   PSB_POSITIONS PP,
         PSB_POSITIONS_I PPI
  WHERE  PP.data_extract_id = p_data_extract_id
  AND    PP.data_extract_id = PPI.data_extract_id
  AND    PP.position_id     > p_restart_position_id
  AND    PP.hr_position_id = PPI.hr_position_id
  AND    PP.hr_employee_id = PPI.hr_employee_id
  AND    ( PP.vacant_position_flag IS NULL OR PP.vacant_position_flag = 'N' )
  ORDER BY position_id;

BEGIN

  -- Create salary dIStribution FOR all the positions.
  FOR c_Positions_Rec in c_Positions
  LOOP
    l_position_ctr := l_position_ctr + 1;
    l_fin_position_id := c_Positions_Rec.position_id;

    l_position_name := NULL;
    l_employee_name := NULL;

    IF (c_Positions_Rec.position_id IS NOT NULL) THEN
      FOR Pos_Name_Rec in G_Position_Details(p_position_id => c_Positions_Rec.position_id)
      LOOP
    	l_position_name := Pos_Name_Rec.name;
      END LOOP;
    END IF;

    IF (c_Positions_Rec.hr_employee_id IS NOT NULL) THEN
      FOR Emp_Name_Rec in G_Employee_Details(p_person_id => c_Positions_rec.hr_employee_id)
      LOOP
	l_employee_name := Emp_Name_Rec.first_name||' '||Emp_Name_Rec.last_name;
      END LOOP;
    END IF;

    Create_Salary_Dist_Pos
    ( p_return_status       => l_return_status,
      p_data_extract_id     => p_data_extract_id,
      p_position_id         => c_Positions_Rec.position_id,
      p_position_start_DATE => c_Positions_Rec.effective_start_DATE,
      p_position_END_DATE   => c_Positions_Rec.effective_END_DATE
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    if l_position_ctr = PSB_WS_ACCT1.g_checkpoint_save then
    PSB_HR_EXTRACT_DATA_PVT.Update_Reentry
    ( p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_msg_count                => l_msg_count,
      p_msg_data                 => l_msg_data,
      p_data_extract_id          => p_data_extract_id,
      p_extract_method           => p_extract_method,
      p_process                  => 'PSB Costing',
      p_restart_id               => c_Positions_Rec.position_id
    );

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       raise FND_API.G_EXC_ERROR;
    end if;
    commit work;
    /*For Bug No : 2642012 Start*/
    l_position_ctr := 0;
    /*For Bug No : 2642012 End*/
    Savepoint Populate_Costing;
  end if;

  END LOOP;

  PSB_HR_EXTRACT_DATA_PVT.Update_Reentry
  ( p_api_version              => 1.0  ,
    p_return_status            => l_return_status,
    p_msg_count                => l_msg_count,
    p_msg_data                 => l_msg_data,
    p_data_extract_id          => p_data_extract_id,
    p_extract_method           => p_extract_method,
    p_process                  => 'PSB Costing',
    p_restart_id               => l_fin_position_id
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  end if;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('PSB', 'PSB_POSITION_DETAILS');
    FND_MESSAGE.SET_TOKEN('POSITION_NAME',l_position_name );
    FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME',l_employee_name );
    FND_MSG_PUB.Add;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('PSB', 'PSB_POSITION_DETAILS');
    FND_MESSAGE.SET_TOKEN('POSITION_NAME',l_position_name );
    FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME',l_employee_name );
    FND_MSG_PUB.Add;

  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.SET_NAME('PSB', 'PSB_POSITION_DETAILS');
    FND_MESSAGE.SET_TOKEN('POSITION_NAME',l_position_name );
    FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME',l_employee_name );
    FND_MSG_PUB.Add;

END Create_Salary_Distributions;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
PROCEDURE Create_Salary_Dist_Pos
( p_return_status        OUT  NOCOPY  VARCHAR2,
  p_data_extract_id      IN   NUMBER,
  p_position_id          IN   NUMBER,
  p_position_start_date  IN   DATE,
  p_position_end_date    IN   DATE
)
AS

  TYPE l_assignment_rec_type IS RECORD
  ( chart_of_accounts_id  NUMBER,
    proportion            NUMBER,
    effective_start_date  DATE,
    project_id            NUMBER,
    task_id               NUMBER,
    award_id              NUMBER,
    expenditure_type      VARCHAR2(30),
    expenditure_org_id    NUMBER,
    --UTF8 changes for Bug No : 2615261
    description           psb_cost_distributions_i.description%TYPE,
    cost_allocation_keyflex_id NUMBER,
    segment1  VARCHAR2(25), segment2  VARCHAR2(25), segment3  VARCHAR2(25),
    segment4  VARCHAR2(25), segment5  VARCHAR2(25), segment6  VARCHAR2(25),
    segment7  VARCHAR2(25), segment8  VARCHAR2(25), segment9  VARCHAR2(25),
    segment10  VARCHAR2(25), segment11  VARCHAR2(25), segment12  VARCHAR2(25),
    segment13  VARCHAR2(25), segment14  VARCHAR2(25), segment15  VARCHAR2(25),
    segment16  VARCHAR2(25), segment17  VARCHAR2(25), segment18  VARCHAR2(25),
    segment19  VARCHAR2(25), segment20  VARCHAR2(25), segment21  VARCHAR2(25),
    segment22  VARCHAR2(25), segment23  VARCHAR2(25), segment24  VARCHAR2(25),
    segment25  VARCHAR2(25), segment26  VARCHAR2(25), segment27  VARCHAR2(25),
    segment28  VARCHAR2(25), segment29  VARCHAR2(25), segment30  VARCHAR2(25)
  );
  --
  TYPE l_assignment_tbl_type IS TABLE OF l_assignment_rec_type
      INDEX BY BINARY_INTEGER;

  l_assignment               l_assignment_tbl_type;
  l_num_assignment           NUMBER := 0;
  l_num_organization         NUMBER := 0;
  l_num_payroll              NUMBER := 0;
  l_num_element              NUMBER := 0;
  l_process_num              NUMBER := 0;
  l_proportion               NUMBER := 0;
  l_project_id               NUMBER(15);
  l_task_id                  NUMBER(15);
  l_award_id                 NUMBER(15);
  l_expenditure_type         VARCHAR2(30);
  l_expenditure_org_id       NUMBER(15);
  l_error_message            VARCHAR2(100);

  -- UTF8 changes for Bug No : 2615261
  l_description              psb_cost_distributions_i.description%TYPE;
  l_position_name            VARCHAR2(240);
  l_process_start_date       DATE;
  l_default_start_date       DATE := fnd_date.canonical_to_date('1941/01/01');
  l_rep_req_id               NUMBER;
  l_reqid                    NUMBER;
  l_userid                   NUMBER;
  lh_distribution            gl_distribution_tbl_type;
  i                          number := 0;

  TYPE l_payroll_rec_type IS RECORD
  ( chart_of_accounts_id  NUMBER,
    effective_start_date  DATE,
    cost_allocation_keyflex_id NUMBER,
    segment1  VARCHAR2(25), segment2  VARCHAR2(25), segment3  VARCHAR2(25),
    segment4  VARCHAR2(25), segment5  VARCHAR2(25), segment6  VARCHAR2(25),
    segment7  VARCHAR2(25), segment8  VARCHAR2(25), segment9  VARCHAR2(25),
    segment10  VARCHAR2(25), segment11  VARCHAR2(25), segment12  VARCHAR2(25),
    segment13  VARCHAR2(25), segment14  VARCHAR2(25), segment15  VARCHAR2(25),
    segment16  VARCHAR2(25), segment17  VARCHAR2(25), segment18  VARCHAR2(25),
    segment19  VARCHAR2(25), segment20  VARCHAR2(25), segment21  VARCHAR2(25),
    segment22  VARCHAR2(25), segment23  VARCHAR2(25), segment24  VARCHAR2(25),
    segment25  VARCHAR2(25), segment26  VARCHAR2(25), segment27  VARCHAR2(25),
    segment28  VARCHAR2(25), segment29  VARCHAR2(25), segment30  VARCHAR2(25)
  );
  --
  TYPE l_payroll_tbl_type IS TABLE OF l_payroll_rec_type
      INDEX BY BINARY_INTEGER;
  --
  l_payroll                  l_payroll_tbl_type;

  TYPE l_org_rec_type IS RECORD
  ( chart_of_accounts_id  NUMBER,
    effective_start_date  DATE,
    cost_allocation_keyflex_id NUMBER,
    segment1  VARCHAR2(25), segment2  VARCHAR2(25), segment3  VARCHAR2(25),
    segment4  VARCHAR2(25), segment5  VARCHAR2(25), segment6  VARCHAR2(25),
    segment7  VARCHAR2(25), segment8  VARCHAR2(25), segment9  VARCHAR2(25),
    segment10  VARCHAR2(25), segment11  VARCHAR2(25), segment12  VARCHAR2(25),
    segment13  VARCHAR2(25), segment14  VARCHAR2(25), segment15  VARCHAR2(25),
    segment16  VARCHAR2(25), segment17  VARCHAR2(25), segment18  VARCHAR2(25),
    segment19  VARCHAR2(25), segment20  VARCHAR2(25), segment21  VARCHAR2(25),
    segment22  VARCHAR2(25), segment23  VARCHAR2(25), segment24  VARCHAR2(25),
    segment25  VARCHAR2(25), segment26  VARCHAR2(25), segment27  VARCHAR2(25),
    segment28  VARCHAR2(25), segment29  VARCHAR2(25), segment30  VARCHAR2(25)
  );
  --
  TYPE l_org_tbl_type IS TABLE OF l_org_rec_type
      INDEX BY BINARY_INTEGER;
  --
  l_organization             l_org_tbl_type;

  TYPE l_elemlink_rec_type IS RECORD
  ( chart_of_accounts_id  NUMBER,
    effective_start_date  DATE,
    cost_allocation_keyflex_id NUMBER,
    segment1  VARCHAR2(25), segment2  VARCHAR2(25), segment3  VARCHAR2(25),
    segment4  VARCHAR2(25), segment5  VARCHAR2(25), segment6  VARCHAR2(25),
    segment7  VARCHAR2(25), segment8  VARCHAR2(25), segment9  VARCHAR2(25),
    segment10  VARCHAR2(25), segment11  VARCHAR2(25), segment12  VARCHAR2(25),
    segment13  VARCHAR2(25), segment14  VARCHAR2(25), segment15  VARCHAR2(25),
    segment16  VARCHAR2(25), segment17  VARCHAR2(25), segment18  VARCHAR2(25),
    segment19  VARCHAR2(25), segment20  VARCHAR2(25), segment21  VARCHAR2(25),
    segment22  VARCHAR2(25), segment23  VARCHAR2(25), segment24  VARCHAR2(25),
    segment25  VARCHAR2(25), segment26  VARCHAR2(25), segment27  VARCHAR2(25),
    segment28  VARCHAR2(25), segment29  VARCHAR2(25), segment30  VARCHAR2(25)
  );
  --
  TYPE l_elemlink_tbl_type IS TABLE OF l_elemlink_rec_type
       INDEX BY BINARY_INTEGER;
  --
  l_element_link             l_elemlink_tbl_type;
  l_ccid_val                 FND_FLEX_EXT.SegmentArray;
  l_ccid                     NUMBER;
  l_init_index               BINARY_INTEGER;
  l_assign_index             BINARY_INTEGER;
  l_segment_index            BINARY_INTEGER;
  l_flex_code                NUMBER;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_msg                      VARCHAR2(5000);
  l_msg_buf                  VARCHAR2(1000);
  l_return_status            VARCHAR2(1);
  l_dIStribution_id          NUMBER;
  l_rowid                    VARCHAR2(100);
  tf                         boolean;

  -- Bug#3467512: Group costing info to avoid duplicate distribution lines.
  CURSOR l_dist_csr
  IS
  SELECT a.costing_level,
         a.proportion,
         a.chart_of_accounts_id,
         a.project_id,
         a.task_id,
         a.award_id,
         a.expenditure_type,
         a.expenditure_organization_id,
         a.description,
         a.cost_allocation_keyflex_id,
         a.segment1,  a.segment2,  a.segment3,  a.segment4,  a.segment5,
         a.segment6,  a.segment7,  a.segment8,  a.segment9,  a.segment10,
         a.segment11, a.segment12, a.segment13, a.segment14, a.segment15,
         a.segment16, a.segment17, a.segment18, a.segment19, a.segment20,
         a.segment21, a.segment22, a.segment23, a.segment24, a.segment25,
         a.segment26, a.segment27, a.segment28, a.segment29, a.segment30,
         a.effective_start_date
  FROM   psb_cost_distributions_i a,
         psb_employees_i          b,
         psb_employees            be,
         psb_positions            c,
         psb_position_assignments d
  WHERE  a.assignment_id         = b.assignment_id
  AND    a.data_extract_id       = p_data_extract_id
  AND    b.hr_position_id        = c.hr_position_id
  AND    b.hr_employee_id        = be.hr_employee_id
  AND    b.data_extract_id       = p_data_extract_id
  AND    be.data_extract_id      = p_data_extract_id
  AND    c.data_extract_id       = p_data_extract_id
  AND    c.position_id           = p_position_id
  AND    c.position_id           = d.position_id
  AND    be.employee_id          = d.employee_id
  AND    d.primary_employee_flag = 'Y'
  AND    d.assignment_type       = 'EMPLOYEE'
  ORDER BY a.chart_of_accounts_id;
  --
  l_use_account_generator_flag  VARCHAR2(1);
  l_appl_short_name             VARCHAR2(2000);
  l_message_name                VARCHAR2(2000);
  l_message_text                VARCHAR2(2000);
  l_ccid_exists                 BOOLEAN;
  --
BEGIN

  --
  -- Find if account generator process is to be used to generate ccids from
  -- the POETA information. The default value is 'Y'.
  --
  FND_PROFILE.GET ( name => 'PSB_USE_ACCOUNT_GENERATOR_FOR_DE' ,
		    val  => l_use_account_generator_flag );

  -- The default value is 'Y'.
  IF l_use_account_generator_flag IS NULL THEN
     l_use_account_generator_flag := 'Y';
  END IF;

  if lh_distribution.count > 0 then
     lh_distribution.delete;
     i := 0;
  end if;

  l_assignment(1).effective_start_date := NULL;
  l_assignment(1).chart_of_accounts_id := NULL;
  l_assignment(1).project_id := NULL;
  l_assignment(1).task_id    := NULL;
  l_assignment(1).award_id    := NULL;
  l_assignment(1).expenditure_type := NULL;
  l_assignment(1).expenditure_org_id := NULL;
  l_assignment(1).description := NULL;
  l_assignment(1).cost_allocation_keyflex_id := NULL;
  l_assignment(1).segment1  := NULL;
  l_assignment(1).segment2  := NULL;
  l_assignment(1).segment3  := NULL;
  l_assignment(1).segment4  := NULL;
  l_assignment(1).segment5  := NULL;
  l_assignment(1).segment6  := NULL;
  l_assignment(1).segment7  := NULL;
  l_assignment(1).segment8  := NULL;
  l_assignment(1).segment9  := NULL;
  l_assignment(1).segment10 := NULL;
  l_assignment(1).segment11 := NULL;
  l_assignment(1).segment12 := NULL;
  l_assignment(1).segment13 := NULL;
  l_assignment(1).segment14 := NULL;
  l_assignment(1).segment15 := NULL;
  l_assignment(1).segment16 := NULL;
  l_assignment(1).segment17 := NULL;
  l_assignment(1).segment18 := NULL;
  l_assignment(1).segment19 := NULL;
  l_assignment(1).segment20 := NULL;
  l_assignment(1).segment21 := NULL;
  l_assignment(1).segment22 := NULL;
  l_assignment(1).segment23 := NULL;
  l_assignment(1).segment24 := NULL;
  l_assignment(1).segment25 := NULL;
  l_assignment(1).segment26 := NULL;
  l_assignment(1).segment27 := NULL;
  l_assignment(1).segment28 := NULL;
  l_assignment(1).segment29 := NULL;
  l_assignment(1).segment30 := NULL;


  l_payroll(1).chart_of_accounts_id := NULL;
  l_payroll(1).effective_start_date := NULL;
  l_payroll(1).cost_allocation_keyflex_id := NULL;

  l_payroll(1).segment1  := NULL;
  l_payroll(1).segment2  := NULL;
  l_payroll(1).segment3  := NULL;
  l_payroll(1).segment4  := NULL;
  l_payroll(1).segment5  := NULL;
  l_payroll(1).segment6  := NULL;
  l_payroll(1).segment7  := NULL;
  l_payroll(1).segment8  := NULL;
  l_payroll(1).segment9  := NULL;
  l_payroll(1).segment10 := NULL;
  l_payroll(1).segment11 := NULL;
  l_payroll(1).segment12 := NULL;
  l_payroll(1).segment13 := NULL;
  l_payroll(1).segment14 := NULL;
  l_payroll(1).segment15 := NULL;
  l_payroll(1).segment16 := NULL;
  l_payroll(1).segment17 := NULL;
  l_payroll(1).segment18 := NULL;
  l_payroll(1).segment19 := NULL;
  l_payroll(1).segment20 := NULL;
  l_payroll(1).segment21 := NULL;
  l_payroll(1).segment22 := NULL;
  l_payroll(1).segment23 := NULL;
  l_payroll(1).segment24 := NULL;
  l_payroll(1).segment25 := NULL;
  l_payroll(1).segment26 := NULL;
  l_payroll(1).segment27 := NULL;
  l_payroll(1).segment28 := NULL;
  l_payroll(1).segment29 := NULL;
  l_payroll(1).segment30 := NULL;

  l_element_link(1).chart_of_accounts_id := NULL;
  l_element_link(1).effective_start_date := NULL;
  l_element_link(1).cost_allocation_keyflex_id := NULL;

  l_element_link(1).segment1  := NULL;
  l_element_link(1).segment2  := NULL;
  l_element_link(1).segment3  := NULL;
  l_element_link(1).segment4  := NULL;
  l_element_link(1).segment5  := NULL;
  l_element_link(1).segment6  := NULL;
  l_element_link(1).segment7  := NULL;
  l_element_link(1).segment8  := NULL;
  l_element_link(1).segment9  := NULL;
  l_element_link(1).segment10 := NULL;
  l_element_link(1).segment11 := NULL;
  l_element_link(1).segment12 := NULL;
  l_element_link(1).segment13 := NULL;
  l_element_link(1).segment14 := NULL;
  l_element_link(1).segment15 := NULL;
  l_element_link(1).segment16 := NULL;
  l_element_link(1).segment17 := NULL;
  l_element_link(1).segment18 := NULL;
  l_element_link(1).segment19 := NULL;
  l_element_link(1).segment20 := NULL;
  l_element_link(1).segment21 := NULL;
  l_element_link(1).segment22 := NULL;
  l_element_link(1).segment23 := NULL;
  l_element_link(1).segment24 := NULL;
  l_element_link(1).segment25 := NULL;
  l_element_link(1).segment26 := NULL;
  l_element_link(1).segment27 := NULL;
  l_element_link(1).segment28 := NULL;
  l_element_link(1).segment29 := NULL;
  l_element_link(1).segment30 := NULL;

  l_organization(1).chart_of_accounts_id := NULL;
  l_organization(1).effective_start_date := NULL;
  l_organization(1).cost_allocation_keyflex_id := NULL;

  l_organization(1).segment1  := NULL;
  l_organization(1).segment2  := NULL;
  l_organization(1).segment3  := NULL;
  l_organization(1).segment4  := NULL;
  l_organization(1).segment5  := NULL;
  l_organization(1).segment6  := NULL;
  l_organization(1).segment7  := NULL;
  l_organization(1).segment8  := NULL;
  l_organization(1).segment9  := NULL;
  l_organization(1).segment10 := NULL;
  l_organization(1).segment11 := NULL;
  l_organization(1).segment12 := NULL;
  l_organization(1).segment13 := NULL;
  l_organization(1).segment14 := NULL;
  l_organization(1).segment15 := NULL;
  l_organization(1).segment16 := NULL;
  l_organization(1).segment17 := NULL;
  l_organization(1).segment18 := NULL;
  l_organization(1).segment19 := NULL;
  l_organization(1).segment20 := NULL;
  l_organization(1).segment21 := NULL;
  l_organization(1).segment22 := NULL;
  l_organization(1).segment23 := NULL;
  l_organization(1).segment24 := NULL;
  l_organization(1).segment25 := NULL;
  l_organization(1).segment26 := NULL;
  l_organization(1).segment27 := NULL;
  l_organization(1).segment28 := NULL;
  l_organization(1).segment29 := NULL;
  l_organization(1).segment30 := NULL;


  -- Processing cost distribution data from interface.
  FOR l_dist_rec in l_dist_csr LOOP

    IF l_dist_rec.costing_level = 'ASSIGNMENT' THEN

      l_num_assignment := nvl(l_num_assignment, 0) + 1;

      l_assignment(l_num_assignment).chart_of_accounts_id :=
					 l_dist_rec.chart_of_accounts_id;
      l_assignment(l_num_assignment).proportion := l_dist_rec.proportion;
      l_assignment(l_num_assignment).project_id := l_dist_rec.project_id;
      l_assignment(l_num_assignment).task_id    := l_dist_rec.task_id;
      l_assignment(l_num_assignment).expenditure_type :=
					 l_dist_rec.expenditure_type;
      l_assignment(l_num_assignment).expenditure_org_id :=
					 l_dist_rec.expenditure_organization_id;
      l_assignment(l_num_assignment).award_id :=
					 l_dist_rec.award_id;
      l_assignment(l_num_assignment).description := l_dist_rec.description;
      l_assignment(l_num_assignment).cost_allocation_keyflex_id :=
					 l_dist_rec.cost_allocation_keyflex_id;
      l_assignment(l_num_assignment).effective_start_date :=
					 l_dist_rec.effective_start_date;
      l_assignment(l_num_assignment).segment1 := l_dist_rec.segment1;
      l_assignment(l_num_assignment).segment2 := l_dist_rec.segment2;
      l_assignment(l_num_assignment).segment3 := l_dist_rec.segment3;
      l_assignment(l_num_assignment).segment4 := l_dist_rec.segment4;
      l_assignment(l_num_assignment).segment5 := l_dist_rec.segment5;
      l_assignment(l_num_assignment).segment6 := l_dist_rec.segment6;
      l_assignment(l_num_assignment).segment7 := l_dist_rec.segment7;
      l_assignment(l_num_assignment).segment8 := l_dist_rec.segment8;
      l_assignment(l_num_assignment).segment9 := l_dist_rec.segment9;
      l_assignment(l_num_assignment).segment10 := l_dist_rec.segment10;
      l_assignment(l_num_assignment).segment11 := l_dist_rec.segment11;
      l_assignment(l_num_assignment).segment12 := l_dist_rec.segment12;
      l_assignment(l_num_assignment).segment13 := l_dist_rec.segment13;
      l_assignment(l_num_assignment).segment14 := l_dist_rec.segment14;
      l_assignment(l_num_assignment).segment15 := l_dist_rec.segment15;
      l_assignment(l_num_assignment).segment16 := l_dist_rec.segment16;
      l_assignment(l_num_assignment).segment17 := l_dist_rec.segment17;
      l_assignment(l_num_assignment).segment18 := l_dist_rec.segment18;
      l_assignment(l_num_assignment).segment19 := l_dist_rec.segment19;
      l_assignment(l_num_assignment).segment20 := l_dist_rec.segment20;
      l_assignment(l_num_assignment).segment21 := l_dist_rec.segment21;
      l_assignment(l_num_assignment).segment22 := l_dist_rec.segment22;
      l_assignment(l_num_assignment).segment23 := l_dist_rec.segment23;
      l_assignment(l_num_assignment).segment24 := l_dist_rec.segment24;
      l_assignment(l_num_assignment).segment25 := l_dist_rec.segment25;
      l_assignment(l_num_assignment).segment26 := l_dist_rec.segment26;
      l_assignment(l_num_assignment).segment27 := l_dist_rec.segment27;
      l_assignment(l_num_assignment).segment28 := l_dist_rec.segment28;
      l_assignment(l_num_assignment).segment29 := l_dist_rec.segment29;
      l_assignment(l_num_assignment).segment30 := l_dist_rec.segment30;

    ELSIF l_dist_rec.costing_level = 'PAYROLL' THEN

      l_num_payroll  := 1;
      l_payroll(1).chart_of_accounts_id := l_dist_rec.chart_of_accounts_id;
      l_payroll(1).cost_allocation_keyflex_id :=
				     l_dist_rec.cost_allocation_keyflex_id;
      l_payroll(1).segment1 := l_dist_rec.segment1;
      l_payroll(1).segment2 := l_dist_rec.segment2;
      l_payroll(1).segment3 := l_dist_rec.segment3;
      l_payroll(1).segment4 := l_dist_rec.segment4;
      l_payroll(1).segment5 := l_dist_rec.segment5;
      l_payroll(1).segment6 := l_dist_rec.segment6;
      l_payroll(1).segment7 := l_dist_rec.segment7;
      l_payroll(1).segment8 := l_dist_rec.segment8;
      l_payroll(1).segment9 := l_dist_rec.segment9;
      l_payroll(1).segment10 := l_dist_rec.segment10;
      l_payroll(1).segment11 := l_dist_rec.segment11;
      l_payroll(1).segment12 := l_dist_rec.segment12;
      l_payroll(1).segment13 := l_dist_rec.segment13;
      l_payroll(1).segment14 := l_dist_rec.segment14;
      l_payroll(1).segment15 := l_dist_rec.segment15;
      l_payroll(1).segment16 := l_dist_rec.segment16;
      l_payroll(1).segment17 := l_dist_rec.segment17;
      l_payroll(1).segment18 := l_dist_rec.segment18;
      l_payroll(1).segment19 := l_dist_rec.segment19;
      l_payroll(1).segment20 := l_dist_rec.segment20;
      l_payroll(1).segment21 := l_dist_rec.segment21;
      l_payroll(1).segment22 := l_dist_rec.segment22;
      l_payroll(1).segment23 := l_dist_rec.segment23;
      l_payroll(1).segment24 := l_dist_rec.segment24;
      l_payroll(1).segment25 := l_dist_rec.segment25;
      l_payroll(1).segment26 := l_dist_rec.segment26;
      l_payroll(1).segment27 := l_dist_rec.segment27;
      l_payroll(1).segment28 := l_dist_rec.segment28;
      l_payroll(1).segment29 := l_dist_rec.segment29;
      l_payroll(1).segment30 := l_dist_rec.segment30;

    ELSIF l_dist_rec.costing_level = 'ORGANIZATION' THEN

      l_num_organization  := 1;
      l_organization(1).chart_of_accounts_id := l_dist_rec.chart_of_accounts_id;
      l_organization(1).cost_allocation_keyflex_id :=
			l_dist_rec.cost_allocation_keyflex_id;
      l_organization(1).segment1 := l_dist_rec.segment1;
      l_organization(1).segment2 := l_dist_rec.segment2;
      l_organization(1).segment3 := l_dist_rec.segment3;
      l_organization(1).segment4 := l_dist_rec.segment4;
      l_organization(1).segment5 := l_dist_rec.segment5;
      l_organization(1).segment6 := l_dist_rec.segment6;
      l_organization(1).segment7 := l_dist_rec.segment7;
      l_organization(1).segment8 := l_dist_rec.segment8;
      l_organization(1).segment9 := l_dist_rec.segment9;
      l_organization(1).segment10 := l_dist_rec.segment10;
      l_organization(1).segment11 := l_dist_rec.segment11;
      l_organization(1).segment12 := l_dist_rec.segment12;
      l_organization(1).segment13 := l_dist_rec.segment13;
      l_organization(1).segment14 := l_dist_rec.segment14;
      l_organization(1).segment15 := l_dist_rec.segment15;
      l_organization(1).segment16 := l_dist_rec.segment16;
      l_organization(1).segment17 := l_dist_rec.segment17;
      l_organization(1).segment18 := l_dist_rec.segment18;
      l_organization(1).segment19 := l_dist_rec.segment19;
      l_organization(1).segment20 := l_dist_rec.segment20;
      l_organization(1).segment21 := l_dist_rec.segment21;
      l_organization(1).segment22 := l_dist_rec.segment22;
      l_organization(1).segment23 := l_dist_rec.segment23;
      l_organization(1).segment24 := l_dist_rec.segment24;
      l_organization(1).segment25 := l_dist_rec.segment25;
      l_organization(1).segment26 := l_dist_rec.segment26;
      l_organization(1).segment27 := l_dist_rec.segment27;
      l_organization(1).segment28 := l_dist_rec.segment28;
      l_organization(1).segment29 := l_dist_rec.segment29;
      l_organization(1).segment30 := l_dist_rec.segment30;

    ELSIF l_dist_rec.costing_level = 'ELEMENT LINK' THEN

      l_num_element   := 1;
      l_element_link(1).chart_of_accounts_id := l_dist_rec.chart_of_accounts_id;
      l_element_link(1).cost_allocation_keyflex_id :=
					  l_dist_rec.cost_allocation_keyflex_id;
      l_element_link(1).segment1 := l_dist_rec.segment1;
      l_element_link(1).segment2 := l_dist_rec.segment2;
      l_element_link(1).segment3 := l_dist_rec.segment3;
      l_element_link(1).segment4 := l_dist_rec.segment4;
      l_element_link(1).segment5 := l_dist_rec.segment5;
      l_element_link(1).segment6 := l_dist_rec.segment6;
      l_element_link(1).segment7 := l_dist_rec.segment7;
      l_element_link(1).segment8 := l_dist_rec.segment8;
      l_element_link(1).segment9 := l_dist_rec.segment9;
      l_element_link(1).segment10 := l_dist_rec.segment10;
      l_element_link(1).segment11 := l_dist_rec.segment11;
      l_element_link(1).segment12 := l_dist_rec.segment12;
      l_element_link(1).segment13 := l_dist_rec.segment13;
      l_element_link(1).segment14 := l_dist_rec.segment14;
      l_element_link(1).segment15 := l_dist_rec.segment15;
      l_element_link(1).segment16 := l_dist_rec.segment16;
      l_element_link(1).segment17 := l_dist_rec.segment17;
      l_element_link(1).segment18 := l_dist_rec.segment18;
      l_element_link(1).segment19 := l_dist_rec.segment19;
      l_element_link(1).segment20 := l_dist_rec.segment20;
      l_element_link(1).segment21 := l_dist_rec.segment21;
      l_element_link(1).segment22 := l_dist_rec.segment22;
      l_element_link(1).segment23 := l_dist_rec.segment23;
      l_element_link(1).segment24 := l_dist_rec.segment24;
      l_element_link(1).segment25 := l_dist_rec.segment25;
      l_element_link(1).segment26 := l_dist_rec.segment26;
      l_element_link(1).segment27 := l_dist_rec.segment27;
      l_element_link(1).segment28 := l_dist_rec.segment28;
      l_element_link(1).segment29 := l_dist_rec.segment29;
      l_element_link(1).segment30 := l_dist_rec.segment30;

    END IF;

  END LOOP;

  IF (l_num_assignment > 0) THEN
    l_process_num := l_num_assignment;
  ELSIF (l_num_payroll > 0) THEN
    l_process_num := l_num_payroll;
    l_flex_code   := l_payroll(1).chart_of_accounts_id;
    l_proportion  := 100;
  ELSIF (l_num_organization > 0) THEN
    l_process_num := l_num_organization;
    l_flex_code   := l_organization(1).chart_of_accounts_id;
    l_proportion  := 100;
  ELSIF (l_num_element > 0) THEN
    l_process_num := l_num_element;
    l_flex_code   := l_element_link(1).chart_of_accounts_id;
    l_proportion  := 100;
  END IF;

  FOR l_assign_index in 1..l_process_num LOOP

    IF l_num_assignment > 0 THEN
      l_flex_code          := l_assignment(l_assign_index).chart_of_accounts_id;
      l_proportion         := l_assignment(l_assign_index).proportion;
      l_project_id         := l_assignment(l_assign_index).project_id;
      l_task_id            := l_assignment(l_assign_index).task_id;
      l_expenditure_type   := l_assignment(l_assign_index).expenditure_type;
      l_expenditure_org_id := l_assignment(l_assign_index).expenditure_org_id;
      l_award_id           := l_assignment(l_assign_index).award_id;
      l_description        := l_assignment(l_assign_index).description;
    END IF;

    l_ccid := NULL;

    --
    -- Check project_id, if it is not null means we have POETA information
    -- available. Call Account Generator API to generate CCID from the POETA.
    --
    IF l_assignment(l_assign_index).project_id IS NOT NULL THEN

      --
      -- Generate accounts as per the profile value defined by the user. The
      -- l_use_account_generator_flag is populated at the beginning of this API.
      --
      IF l_use_account_generator_flag = 'Y' THEN
        --
        PSB_Workflow_Pvt.Generate_Account
        (  p_api_version                 => 1.0,
           p_return_status               => l_return_status,
           p_msg_count                   => l_msg_count,
           p_msg_data                    => l_msg_data,
           p_project_id                  => l_project_id,
           p_task_id                     => l_task_id,
           p_award_id                    => l_award_id,
           p_expenditure_type            => l_expenditure_type,
           p_expenditure_organization_id => l_expenditure_org_id,
           p_chart_of_accounts_id        => l_flex_code,
           p_description                 => l_description,
           p_code_combination_id         => l_ccid,
           p_error_message               => l_error_message
        );
	-- If API did not complete normally, raise error coming from called API.
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  RAISE FND_API.G_EXC_ERROR;
	END IF ;

        -- Check if CCID got generated.
	IF l_ccid IS NULL THEN

	  -- Fetching position name to be used for messaging.
	  IF p_position_id IS NOT NULL THEN
	    FOR Pos_Name_Rec IN
              G_Position_Details(p_position_id => p_position_id)
	    LOOP
	      l_position_name := Pos_Name_Rec.name;
	    END LOOP;
	  END IF;

	  --
	  -- Decode l_error_message as l_error_message is always supposed to be
	  -- in encoded format only as per Workflow Account Generator standards.
	  --
	  fnd_message.parse_encoded( l_error_message   ,
                                     l_appl_short_name ,
                                     l_message_name
                                   ) ;
	  l_message_text := fnd_message.get_string( l_appl_short_name,
                                                    l_message_name);
	  -- End encoding the messages retrieved as l_error_message.

	  FND_MESSAGE.SET_NAME('PSB', 'PSB_POETA_TO_CCID_FAILURE');
	  FND_MESSAGE.SET_TOKEN('POSITION_NAME',    l_position_name );
	  FND_MESSAGE.SET_TOKEN('PROJECT_ID',       l_project_id );
	  FND_MESSAGE.SET_TOKEN('TASK_ID',          l_task_id );
	  FND_MESSAGE.SET_TOKEN('AWARD_ID',         l_award_id );
	  FND_MESSAGE.SET_TOKEN('EXPENDITURE_TYPE', l_expenditure_type );
	  FND_MESSAGE.SET_TOKEN('EXPENDITURE_ORGANIZATION_ID',
						  l_expenditure_org_id );
	  FND_MSG_PUB.ADD;

	  -- Added an extra message as one message was getting truncated in
	  -- the request out file.
	  FND_MESSAGE.SET_NAME('PSB', 'PSB_POETA_AG_ERROR_MESSAGE');
	  FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE',    l_message_text);
	  FND_MSG_PUB.ADD;

        END IF;
        -- End checking if CCID got generated.

      END IF; -- End ( IF l_use_account_generator_flag = 'Y' )
      --

    -- If project_id is null, we generate CCID out of segment information.
    ELSIF (l_assignment(l_assign_index).project_id IS NULL) THEN

      IF l_flex_code <> NVL(PSB_WS_ACCT1.g_flex_code, FND_API.G_MISS_NUM) THEN
        --
        PSB_WS_ACCT1.Flex_Info
        ( p_flex_code     => l_flex_code,
          p_return_status => l_return_status
        ) ;
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  RAISE FND_API.G_EXC_ERROR;
	END IF;
        --
      END IF;

      -- Concatenate cost_allocation_keyflex_id and store it in description.
      l_description := NULL;

      IF l_assignment(l_assign_index).cost_allocation_keyflex_id IS NOT NULL
      THEN
	 l_description := l_description || '#A;' ||
	       to_char(l_assignment(l_assign_index).cost_allocation_keyflex_id)
		      || ';' ;
      END IF;

      IF l_organization(1).cost_allocation_keyflex_id IS NOT NULL THEN
	 l_description := l_description || 'O;' ||
	       to_char(l_organization(1).cost_allocation_keyflex_id) || ';';
      END IF;

      IF l_element_link(1).cost_allocation_keyflex_id IS NOT NULL THEN
	 l_description := l_description || 'E;' ||
	       to_char(l_element_link(1).cost_allocation_keyflex_id) || ';';
      END IF;

      IF l_payroll(1).cost_allocation_keyflex_id IS NOT NULL THEN
	 l_description := l_description || 'P;' ||
	       to_char(l_payroll(1).cost_allocation_keyflex_id) || ';#';
      END IF;

      FOR l_init_index in 1..PSB_WS_ACCT1.g_num_segs LOOP
	l_ccid_val(l_init_index) := NULL;
      END LOOP;

      FOR l_segment_index in 1..PSB_WS_ACCT1.g_num_segs
      LOOP

	IF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT1' THEN

	  IF l_assignment(l_assign_index).segment1 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
					 l_assignment(l_assign_index).segment1;
	  ELSIF (l_organization(1).segment1 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment1;
	  ELSIF (l_element_link(1).segment1 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment1;
	  ELSIF (l_payroll(1).segment1 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment1;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT2' THEN

	  IF l_assignment(l_assign_index).segment2 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
					 l_assignment(l_assign_index).segment2;
	  ELSIF (l_organization(1).segment2 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment2;
	  ELSIF (l_element_link(1).segment2 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment2;
	  ELSIF (l_payroll(1).segment2 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment2;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT3' THEN

	  IF l_assignment(l_assign_index).segment3 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
					 l_assignment(l_assign_index).segment3;
	  ELSIF (l_organization(1).segment3 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment3;
	  ELSIF (l_element_link(1).segment3 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment3;
	  ELSIF (l_payroll(1).segment3 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment3;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT4' THEN

	  IF l_assignment(l_assign_index).segment4 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
					 l_assignment(l_assign_index).segment4;
	  ELSIF (l_organization(1).segment4 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment4;
	  ELSIF (l_element_link(1).segment4 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment4;
	  ELSIF (l_payroll(1).segment4 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment4;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT5' THEN

	  IF l_assignment(l_assign_index).segment5 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
					 l_assignment(l_assign_index).segment5;
	  ELSIF (l_organization(1).segment5 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment5;
	  ELSIF (l_element_link(1).segment5 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment5;
	  ELSIF (l_payroll(1).segment5 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment5;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT6' THEN

	  IF l_assignment(l_assign_index).segment6 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
					 l_assignment(l_assign_index).segment6;
	  ELSIF (l_organization(1).segment6 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment6;
	  ELSIF (l_element_link(1).segment6 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment6;
	  ELSIF (l_payroll(1).segment6 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment6;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT7' THEN

	  IF l_assignment(l_assign_index).segment7 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
					 l_assignment(l_assign_index).segment7;
	  ELSIF (l_organization(1).segment7 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment7;
	  ELSIF (l_element_link(1).segment7 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment7;
	  ELSIF (l_payroll(1).segment7 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment7;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT8' THEN

	  IF l_assignment(l_assign_index).segment8 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
					 l_assignment(l_assign_index).segment8;
	  ELSIF (l_organization(1).segment8 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment8;
	  ELSIF (l_element_link(1).segment8 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment8;
	  ELSIF (l_payroll(1).segment8 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment8;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT9' THEN

	  IF l_assignment(l_assign_index).segment9 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
					 l_assignment(l_assign_index).segment9;
	  ELSIF (l_organization(1).segment9 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment9;
	  ELSIF (l_element_link(1).segment9 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment9;
	  ELSIF (l_payroll(1).segment9 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment9;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT10' THEN

	  IF l_assignment(l_assign_index).segment10 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
					l_assignment(l_assign_index).segment10;
	  ELSIF (l_organization(1).segment10 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment10;
	  ELSIF (l_element_link(1).segment10 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment10;
	  ELSIF (l_payroll(1).segment10 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment10;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT11' THEN

	  IF l_assignment(l_assign_index).segment11 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
					l_assignment(l_assign_index).segment11;
	  ELSIF (l_organization(1).segment11 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment11;
	  ELSIF (l_element_link(1).segment11 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment11;
	  ELSIF (l_payroll(1).segment11 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment11;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT12' THEN

	  IF l_assignment(l_assign_index).segment12 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
					l_assignment(l_assign_index).segment12;
	  ELSIF (l_organization(1).segment12 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment12;
	  ELSIF (l_element_link(1).segment12 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment12;
	  ELSIF (l_payroll(1).segment12 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment12;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT13' THEN

	  IF l_assignment(l_assign_index).segment13 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
					l_assignment(l_assign_index).segment13;
	  ELSIF (l_organization(1).segment13 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment13;
	  ELSIF (l_element_link(1).segment13 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment13;
	  ELSIF (l_payroll(1).segment13 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment13;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT14' THEN

	  IF l_assignment(l_assign_index).segment14 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment14;
	  ELSIF (l_organization(1).segment14 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment14;
	  ELSIF (l_element_link(1).segment14 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment14;
	  ELSIF (l_payroll(1).segment14 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment14;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT15' THEN

	  IF l_assignment(l_assign_index).segment15 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment15;
	  ELSIF (l_organization(1).segment15 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment15;
	  ELSIF (l_element_link(1).segment15 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment15;
	  ELSIF (l_payroll(1).segment15 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment15;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT16' THEN

	  IF l_assignment(l_assign_index).segment16 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment16;
	  ELSIF (l_organization(1).segment16 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment16;
	  ELSIF (l_element_link(1).segment16 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment16;
	  ELSIF (l_payroll(1).segment16 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment16;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT17' THEN

	  IF l_assignment(l_assign_index).segment17 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment17;
	  ELSIF (l_organization(1).segment17 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment17;
	  ELSIF (l_element_link(1).segment17 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment17;
	  ELSIF (l_payroll(1).segment17 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment17;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT18' THEN

	  IF l_assignment(l_assign_index).segment18 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment18;
	  ELSIF (l_organization(1).segment18 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment18;
	  ELSIF (l_element_link(1).segment18 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment18;
	  ELSIF (l_payroll(1).segment18 IS NOT NULL) THEN
	  l_ccid_val(l_segment_index) := l_payroll(1).segment18;
	    END IF;

	  ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT19' THEN

	  IF l_assignment(l_assign_index).segment19 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment19;
	  ELSIF (l_organization(1).segment19 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment19;
	  ELSIF (l_element_link(1).segment19 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment19;
	  ELSIF (l_payroll(1).segment19 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment19;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT20' THEN

	  IF l_assignment(l_assign_index).segment20 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment20;
	  ELSIF (l_organization(1).segment20 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment20;
	  ELSIF (l_element_link(1).segment20 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment20;
	  ELSIF (l_payroll(1).segment20 IS NOT NULL)  THEN
	      l_ccid_val(l_segment_index) := l_payroll(1).segment20;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT21' THEN

	  IF l_assignment(l_assign_index).segment21 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment21;
	  ELSIF (l_organization(1).segment21 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment21;
	  ELSIF (l_element_link(1).segment21 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment21;
	  ELSIF (l_payroll(1).segment21 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment21;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT22' THEN

	  IF l_assignment(l_assign_index).segment22 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment22;
	  ELSIF (l_organization(1).segment22 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment22;
	  ELSIF (l_element_link(1).segment22 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment22;
	  ELSIF (l_payroll(1).segment22 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment22;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT23' THEN

	  IF l_assignment(l_assign_index).segment23 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment23;
	  ELSIF (l_organization(1).segment23 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment23;
	  ELSIF (l_element_link(1).segment23 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment23;
	  ELSIF (l_payroll(1).segment23 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment23;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT24' THEN

	  IF l_assignment(l_assign_index).segment24 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment24;
	  ELSIF (l_organization(1).segment24 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment24;
	  ELSIF (l_element_link(1).segment24 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment24;
	  ELSIF (l_payroll(1).segment24 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment24;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT25' THEN

	  IF l_assignment(l_assign_index).segment25 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment25;
	  ELSIF (l_organization(1).segment25 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment25;
	  ELSIF (l_element_link(1).segment25 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment25;
	  ELSIF (l_payroll(1).segment25 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment25;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT26' THEN

	  IF l_assignment(l_assign_index).segment26 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment26;
	  ELSIF (l_organization(1).segment26 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment26;
	  ELSIF (l_element_link(1).segment26 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment26;
	  ELSIF (l_payroll(1).segment26 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment26;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT27' THEN

	  IF l_assignment(l_assign_index).segment27 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment27;
	  ELSIF (l_organization(1).segment27 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment27;
	  ELSIF (l_element_link(1).segment27 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment27;
	  ELSIF (l_payroll(1).segment27 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment27;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT28' THEN

	  IF l_assignment(l_assign_index).segment28 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment28;
	  ELSIF (l_organization(1).segment28 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment28;
	  ELSIF (l_element_link(1).segment28 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment28;
	  ELSIF (l_payroll(1).segment28 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment28;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT29' THEN

	  IF l_assignment(l_assign_index).segment29 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment29;
	  ELSIF (l_organization(1).segment29 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment29;
	  ELSIF (l_element_link(1).segment29 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment29;
	  ELSIF (l_payroll(1).segment29 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment29;
	  END IF;

	ELSIF PSB_WS_ACCT1.g_seg_name(l_segment_index) = 'SEGMENT30' THEN

	  IF l_assignment(l_assign_index).segment30 IS NOT NULL THEN
	    l_ccid_val(l_segment_index) :=
				       l_assignment(l_assign_index).segment30;
	  ELSIF (l_organization(1).segment30 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_organization(1).segment30;
	  ELSIF (l_element_link(1).segment30 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_element_link(1).segment30;
	  ELSIF (l_payroll(1).segment30 IS NOT NULL) THEN
	    l_ccid_val(l_segment_index) := l_payroll(1).segment30;
	  END IF;

	END IF;

      END LOOP;

      IF (p_position_id IS NOT NULL) THEN
	FOR Pos_Name_Rec in G_Position_Details(p_position_id => p_position_id)
	LOOP
	  l_position_name := Pos_Name_Rec.name;
	END LOOP;
      END IF;

      IF NOT FND_FLEX_EXT.Get_Combination_ID
      ( application_short_name => 'SQLGL',
	key_flex_code          => 'GL#',
	structure_number       => l_flex_code,
	validation_date        => sysdate,
	n_segments             => PSB_WS_ACCT1.g_num_segs,
	segments               => l_ccid_val,
	combination_id         => l_ccid
      )
      THEN
        --
	FND_FILE.put_line(FND_FILE.LOG,
			  'Cannot create CCID FOR position '|| p_position_id);
	l_msg := FND_MESSAGE.Get;
	FND_FILE.put_line(FND_FILE.LOG,l_msg);
	FND_MESSAGE.SET_NAME('PSB','PSB_POSITION_COST_CCID_FAILURE');
	FND_MESSAGE.SET_TOKEN('POSITION_NAME',l_position_name );
	FND_MESSAGE.SET_TOKEN('ERR_MESG',l_msg);
	FND_MSG_PUB.Add;
	RETURN;
        --
      END IF;

    END IF ;
    -- End generating CCID from POETA or segments.

    IF (l_process_num > 1) THEN
      l_payroll(l_process_num).effective_start_date := NULL;
      l_organization(l_process_num).effective_start_date := NULL;
      l_element_link(l_process_num).effective_start_date := NULL;
    END IF;

    l_process_start_date :=
	    greatest( nvl(l_payroll(l_process_num).effective_start_date,
					    l_default_start_date),
	    nvl(l_assignment(l_process_num).effective_start_date,
	    l_default_start_date),
	    nvl(l_organization(l_process_num).effective_start_date,
	    l_default_start_date),
	    nvl(l_element_link(l_process_num).effective_start_date,
	    l_default_start_date),
	    p_position_start_date);

    --
    -- Bug#3467512: As psb_cost_distributions_i is open interface table, it can
    -- be populated with duplicate records where CCID and Effective start dates
    -- are same but percent is different as reported in bug. To fix this, we
    -- need to consolidate percent by CCID and Effective start date.
    --
    l_ccid_exists := FALSE;
    FOR j IN 1..i LOOP
      --
      IF lh_distribution(j).ccid = l_ccid
         AND
         lh_distribution(j).effective_start_date = l_process_start_date
      THEN
        lh_distribution(j).distr_percent := NVL(l_proportion, 0)    +
                           NVL(lh_distribution(j).distr_percent, 0) ;
        --
        IF  lh_distribution(j).distr_percent > 100 THEN
          lh_distribution(j).distr_percent := 100 ;
        END IF;
        --
        l_ccid_exists := TRUE;
        EXIT;
      END IF;
      --
    END LOOP;

    IF NOT l_ccid_exists THEN
      i := i + 1 ;
      lh_distribution(i).ccid                 := l_ccid;
      lh_distribution(i).distr_percent        := l_proportion;
      lh_distribution(i).effective_start_date := l_process_start_date;
      lh_distribution(i).effective_end_date   := p_position_end_date;
      lh_distribution(i).project_id           := l_project_id;
      lh_distribution(i).task_id              := l_task_id;
      lh_distribution(i).award_id             := l_award_id;
      lh_distribution(i).expenditure_type     := l_expenditure_type;
      lh_distribution(i).expenditure_org_id   := l_expenditure_org_id;
      lh_distribution(i).exist_flag           := 'N';
      lh_distribution(i).description          := l_description;
    END IF;
    -- Bug#3467512: End

  END LOOP;
  -- End processing l_dist_csr cursor.

  PSB_POSITION_PAY_DISTR_PVT.Modify_Extract_Distribution
  ( p_api_version          => 1.0,
    p_init_msg_list        => FND_API.G_FALSE,
    p_commit               => FND_API.G_FALSE,
    p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
    p_return_status        => l_return_status,
    p_msg_count            => l_msg_count,
    p_msg_data             => l_msg_data,
    p_position_id          => p_position_id,
    p_data_extract_id      => p_data_extract_id,
    p_chart_of_accounts_id => l_flex_code,
    p_distribution         => lh_distribution
  ) ;
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Create_Salary_Dist_Pos;
/*---------------------------------------------------------------------------*/


/*===========================================================================+
 |                     PROCEDURE Populate_Position_Information               |
 +===========================================================================*/
PROCEDURE Populate_Position_Information
( p_api_version         IN         NUMBER,
  p_init_msg_lISt       IN         VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN         VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN         NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT NOCOPY VARCHAR2,
  p_msg_count           OUT NOCOPY NUMBER,
  p_msg_data            OUT NOCOPY VARCHAR2,
  p_data_extract_id     IN         NUMBER,
  -- DE by Org
  p_extract_by_org      IN         VARCHAR2,
  p_extract_method      IN         VARCHAR2,
  p_business_group_id   IN         NUMBER,
  p_set_of_books_id     IN         NUMBER
)
IS
  --
  l_api_name            CONSTANT VARCHAR2(30) :='Populate_Position_Information';
  l_api_version         CONSTANT NUMBER       := 1.0;

  l_last_update_date    DATE;
  l_last_updated_by     number;
  l_last_update_login   number;
  l_creation_date       DATE;
  l_created_BY          number;
  segs                  FND_FLEX_EXT.SegmentArray;
  tf                    boolean;
  l_ccid                NUMBER;
  l_id_flex_num         NUMBER;
  l_concat_pos_name     varchar2(240);

  l_init_index          BINARY_INTEGER;
  l_status              varchar2(1);

  l_rowid                  varchar2(100);
  l_position_name          varchar2(240);
  l_employee_name          varchar2(310);
  l_urowid                 varchar2(100);
  l_dummy                  number := 0;
  l_elem_assign_dummy      number := 0;
  l_position_assignment_id number := 0;
  r_count                  number := 0;
  l_restart_hr_position_id number := 0;
  l_hr_position_ctr        number := 0;
  prev_hr_position_id      number := -1;
  l_position_id            number;
  l_vacant_position_flag   varchar2(1);
  l_return_status          varchar2(1);
  l_msg_count              number;
  l_msg_data               varchar2(1000);
  l_msg                    varchar2(2000);

  l_rate_or_payscale_id   number := -1;
  l_rate_or_payscale_name varchar2(30);
  l_grade_step            number;
  l_grade_id              number;
  l_grade_name            varchar2(80);
  l_sequence_number       number;

  l_pay_element_id         number;
  l_pay_element_option_id  number;
  l_pay_element_rate_id    number;
  l_element_value          number;
  l_effective_start_date   date;
  l_effective_end_date     date;
  l_salary_type            varchar2(10);
  l_currency_code          varchar2(30);

  -- DE by Org
  l_extract_method         varchar2(30);
  l_status_flag            varchar2(1):='C';
  l_update_flag            varchar2(1):='N';
  l_last_success_flag      varchar2(1):='Y';
  --
  Cursor C_salary IS
     Select rate_or_payscale_name,grade_name
       FROM psb_salary_i
      WHERE rate_or_payscale_id  = l_rate_or_payscale_id
	AND grade_id             = l_grade_id
	AND grade_step           = l_grade_step
	AND sequence_number      = l_sequence_number
	AND data_extract_id      = p_data_extract_id;

  Cursor C_rate_salary IS
     Select rate_or_payscale_name,grade_name
       FROM psb_salary_i
      WHERE rate_or_payscale_id = l_rate_or_payscale_id
	AND grade_id            = l_grade_id
	AND data_extract_id     = p_data_extract_id;

  Cursor C_pay_elements_step IS
     Select ppe.pay_element_id ,ppe.salary_type,
	    ppo.pay_element_option_id
       FROM psb_pay_elements ppe,
	    psb_pay_element_options ppo
      WHERE ppe.data_extract_id = p_data_extract_id
	AND ppe.salary_type     = 'STEP'
	AND ppe.name            = l_rate_or_payscale_name
	AND ppe.pay_element_id  = ppo.pay_element_id
	AND ppo.name            = l_grade_name
	AND ppo.grade_step      = l_grade_step
	AND ppo.sequence_number = l_sequence_number;

  Cursor C_pay_elements_rate IS
     Select ppe.pay_element_id ,ppe.salary_type,
	    ppo.pay_element_option_id
       FROM psb_pay_elements ppe,
	    psb_pay_element_options ppo
      WHERE ppe.data_extract_id = p_data_extract_id
	AND ppe.salary_type     = 'RATE'
	AND ppe.name            = l_rate_or_payscale_name
	AND ppe.pay_element_id  = ppo.pay_element_id
	AND ppo.name            = l_grade_name;

  Cursor C_pay_element_rates IS
     Select pay_element_rate_id,
	    effective_start_date,
	    effective_end_date,
	    element_value,
	    currency_code
       FROM psb_pay_element_rates
      WHERE pay_element_id        = l_pay_element_id
	AND pay_element_option_id = l_pay_element_option_id;

  /* start bug 4213882 */
  -- Bug # 4886277: Changed the cursor name from l_elm_asign_csr
  --                to l_elem_assign_csr
  Cursor l_elem_assign_csr(vc_position_id IN NUMBER)
  IS
    SELECT pas.position_assignment_id
    FROM   psb_position_assignments pas, -- bug #4886277: Used the table
                                         -- instead of View.
           psb_pay_elements pe
    WHERE  pas.pay_element_id = pe.pay_element_id (+)
    AND   pas.assignment_type = 'ELEMENT'
    AND   pas.data_extract_id = p_data_extract_id
    AND   pas.position_id     = vc_position_id
    AND   NVL(pe.salary_flag, 'Y')  = 'Y'
    ORDER BY pe.PAY_ELEMENT_ID;

  /* end bug 4213882 */

  /* Bug 3417868 Start */

  CURSOR l_position_source IS
  SELECT * FROM psb_positions_i
   WHERE data_extract_id = p_data_extract_id
     AND hr_position_id  > l_restart_hr_position_id
   ORDER BY hr_position_id,
            hr_employee_id;

  l_pos_record l_position_source%rowtype;

  -- bug 4551061 added the column availability_status in the
  -- following record
  TYPE l_position_i_rec_type IS RECORD
    (hr_position_id        NUMBER,
     hr_employee_id        NUMBER,
     organization_id       NUMBER,
     rate_or_payscale_id   NUMBER,
     grade_id              NUMBER,
     grade_step            NUMBER,
     sequence_number       NUMBER,
     salary_type           VARCHAR2(10),
     hr_position_name      VARCHAR2(240),
     id_flex_num           NUMBER,
     effective_start_date  DATE,
     effective_end_date    DATE,
     transaction_id        NUMBER,
     transaction_status    VARCHAR2(30),
     pay_basis             VARCHAR2(30),
     value                 NUMBER,
     segment1              VARCHAR2(60),
     segment2              VARCHAR2(60),
     segment3              VARCHAR2(60),
     segment4              VARCHAR2(60),
     segment5              VARCHAR2(60),
     segment6              VARCHAR2(60),
     segment7              VARCHAR2(60),
     segment8              VARCHAR2(60),
     segment9              VARCHAR2(60),
     segment10             VARCHAR2(60),
     segment11             VARCHAR2(60),
     segment12             VARCHAR2(60),
     segment13             VARCHAR2(60),
     segment14             VARCHAR2(60),
     segment15             VARCHAR2(60),
     segment16             VARCHAR2(60),
     segment17             VARCHAR2(60),
     segment18             VARCHAR2(60),
     segment19             VARCHAR2(60),
     segment20             VARCHAR2(60),
     segment21             VARCHAR2(60),
     segment22             VARCHAR2(60),
     segment23             VARCHAR2(60),
     segment24             VARCHAR2(60),
     segment25             VARCHAR2(60),
     segment26             VARCHAR2(60),
     segment27             VARCHAR2(60),
     segment28             VARCHAR2(60),
     segment29             VARCHAR2(60),
     segment30             VARCHAR2(60),
     availability_status   VARCHAR2(30),
     update_insert_flag    VARCHAR2(1),
     position_id           NUMBER
    );

  TYPE l_position_i_tbl_type IS TABLE OF l_position_i_rec_type
       INDEX BY BINARY_INTEGER;

  --bug#4166493, rec type modified to add additional columns necessary to update
  --psb positions in refresh mode.

  TYPE l_position_rec_type IS RECORD
    ( hr_position_id  NUMBER,
      hr_employee_id  NUMBER,
      position_id     NUMBER,
      update_insert_flag VARCHAR2(1),
      organization_id NUMBER,
      effective_start_date DATE,
      effective_end_date DATE,
      position_definition_id NUMBER,
      transaction_id NUMBER,
      transaction_status VARCHAR2(30),
      name  VARCHAR2(240)
    );

  TYPE l_position_tbl_type IS TABLE OF l_position_rec_type
       INDEX BY BINARY_INTEGER;

  l_source_cache_count      NUMBER;
  l_target_cache_count      NUMBER;
  l_last_hr_position_id     NUMBER(20);
  l_position_i_cache        l_position_i_tbl_type;
  l_position_cache          l_position_tbl_type;
  /* Bug 3417868 End */

  /* start bug 4213882 */
  l_assignment_rec_no		NUMBER := 0;
  l_eff_start_date			DATE;
  l_eff_end_date			DATE;
  l_assignment_exists		BOOLEAN := FALSE;
  /* end bug 4213882 */


BEGIN
  --
  Savepoint Populate_Position;
  IF NOT FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  --
  IF FND_API.to_Boolean (p_init_msg_lISt) THEN
    FND_MSG_PUB.initialize;
  END IF;
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- for bug 4213882
  PSB_HR_POPULATE_DATA_PVT.g_extract_method := p_extract_method;
  PSB_HR_POPULATE_DATA_PVT.g_pop_assignment := 'Y';

  -- Populate WHO columns.
  l_last_update_date  := sysdate;
  l_last_updated_BY   := FND_GLOBAL.USER_ID;
  l_last_update_login := FND_GLOBAL.LOGIN_ID;
  l_creation_date     := sysdate;
  l_created_BY        := FND_GLOBAL.USER_ID;

  -- DE by Org
  -- If extract_method is REFRESH do nothing.
  -- Else use the appropriate extract_method based on  the organization's
  -- extract status. cache_org_status caches statuses of all organizations.

  IF (p_extract_by_org = 'N' OR p_extract_method = 'REFRESH') THEN
    l_extract_method := p_extract_method;
  ELSE
    cache_org_status
    ( l_return_status,
      p_data_extract_id,
      p_extract_by_org
    ) ;
    --
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    --
  END IF;

  PSB_HR_EXTRACT_DATA_PVT.Check_Reentry
  (  p_api_version              => 1.0  ,
     p_return_status            => l_return_status,
     p_msg_count                => l_msg_count,
     p_msg_data                 => l_msg_data,
     p_data_extract_id          => p_data_extract_id,
     p_process                  => 'PSB Positions',
     p_status                   => l_status,
     p_restart_id               => l_restart_hr_position_id
  ) ;
  --
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- SR:For testing only.
  -- l_status := 'I'; l_restart_hr_position_id := 0;

  IF (l_status = 'I') THEN

  /*Bug 3417868 Start */
  OPEN l_position_source;
  LOOP
  FETCH l_position_source INTO l_pos_record;

  IF   (l_last_hr_position_id <> l_pos_record.hr_position_id
    AND l_last_hr_position_id IS NOT NULL)
    OR  l_position_source%NOTFOUND
  THEN

    l_position_cache.delete;
    l_target_cache_count := 0;

    --populating target pl/sql table
    FOR position_target_rec in
    (
      --Bug#4166493, picking up additonal data, necessary for updating psb_positions.
      Select hr_position_id,
             hr_employee_id,
             position_id,
             organization_id,
             effective_start_date,
             effective_end_date,
             position_definition_id,
             transaction_id,
             transaction_status,
             name
      FROM   psb_positions
      WHERE  data_extract_id = p_data_extract_id
      AND    hr_position_id  = l_last_hr_position_id
      ORDER BY hr_position_id,
               hr_employee_id
    )
    LOOP

      l_target_cache_count := nvl(l_target_cache_count,0) + 1;
      l_position_cache(l_target_cache_count).hr_position_id
                      := position_target_rec.hr_position_id;
      l_position_cache(l_target_cache_count).hr_employee_id
                      := position_target_rec.hr_employee_id;
      l_position_cache(l_target_cache_count).position_id
                      := position_target_rec.position_id;
      l_position_cache(l_target_cache_count).organization_id
                      := position_target_rec.organization_id;
      l_position_cache(l_target_cache_count).effective_start_date
                      := position_target_rec.effective_start_date;
      l_position_cache(l_target_cache_count).effective_end_date
                      := position_target_rec.effective_end_date;
      l_position_cache(l_target_cache_count).position_definition_id
                      := position_target_rec.position_definition_id;
      l_position_cache(l_target_cache_count).transaction_id
                      := position_target_rec.transaction_id;
      l_position_cache(l_target_cache_count).transaction_status
                      := position_target_rec.transaction_status;
      l_position_cache(l_target_cache_count).name
                      := position_target_rec.name;

    END LOOP;

    --code for comparing similar records
    FOR i in 1..l_position_i_cache.count
    LOOP

      FOR j in 1..l_position_cache.count
      LOOP

        IF  NVL(l_position_i_cache(i).hr_employee_id,-9999)
          = NVL(l_position_cache(j).hr_employee_id,-9999)
        AND l_position_cache(j).position_id IS NOT NULL
        AND l_position_cache(j).update_insert_flag IS NULL
        AND l_position_i_cache(i).update_insert_flag IS NULL THEN

          l_position_cache(j).update_insert_flag   := 'U';
          l_position_i_cache(i).update_insert_flag := 'U';
          l_position_i_cache(i).position_id
                      := l_position_cache(j).position_id;

        END IF;

      END LOOP;

    END LOOP;

  --code for comparing modified and new records
  FOR i in 1..l_position_i_cache.count
  LOOP

    FOR j in 1..l_position_cache.count
    LOOP


    IF l_position_i_cache(i).hr_employee_id IS NOT NULL
    AND l_position_cache(j).hr_employee_id IS NULL
    AND l_position_cache(j).update_insert_flag IS NULL
    AND l_position_cache(j).position_id IS NOT NULL
    AND l_position_i_cache(i).update_insert_flag IS NULL THEN

      l_position_cache(j).update_insert_flag   := 'U';
      l_position_i_cache(i).update_insert_flag := 'U';
      l_position_i_cache(i).position_id := l_position_cache(j).position_id;

    ELSIF l_position_i_cache(i).hr_employee_id IS NULL
    AND l_position_cache(j).hr_employee_id IS NOT NULL
    AND l_position_cache(j).update_insert_flag IS NULL
    AND l_position_cache(j).position_id IS NOT NULL
    AND l_position_i_cache(i).update_insert_flag IS NULL THEN

      l_position_cache(j).update_insert_flag   := 'U';
      l_position_i_cache(i).update_insert_flag := 'U';
      l_position_i_cache(i).position_id := l_position_cache(j).position_id;

    ELSIF l_position_i_cache(i).hr_employee_id IS NOT NULL
    AND l_position_cache(j).hr_employee_id IS NOT NULL
    AND l_position_cache(j).update_insert_flag IS NULL
    AND l_position_cache(j).position_id IS NOT NULL
    AND l_position_i_cache(i).update_insert_flag IS NULL THEN

      l_position_cache(j).update_insert_flag   := 'U';
      l_position_i_cache(i).update_insert_flag := 'U';
      l_position_i_cache(i).position_id := l_position_cache(j).position_id;

    END IF;

    END LOOP;

  END LOOP;

  FOR i in 1..l_position_i_cache.count
  LOOP
    IF l_position_i_cache(i).hr_position_id IS NOT NULL
    AND l_position_i_cache(i).update_insert_flag IS NULL THEN
      l_position_i_cache(i).update_insert_flag := 'I';
    END IF;
  END LOOP;
  /* Bug 3417868 End */

  /*Bug#4166493, , if we reach this stage and
  still have update_insert_flag as null for the data in PSB,
  then these are terminated records and we need to update the employee id
  as null in PSB. Note that for shared positions, we would have created multiple
  position records in PSB for the same position in HR,
  if there are multiple assignments in HR. This scenario is only applicable during
  REFRESH, but we do not need any additional condition to prevent, this for CREATE */

  FOR j in 1..l_position_cache.count
  LOOP

     IF l_position_cache(j).update_insert_flag IS NULL THEN

      -- Only thing we update here is the employee_id to NULL,
      --rest of the data remains same.
            PSB_POSITIONS_PVT.UPDATE_ROW
            (
            p_api_version            => 1.0,
            p_init_msg_lISt          => FND_API.G_FALSE,
            p_commit                 => FND_API.G_FALSE,
            p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
            p_return_status          => l_return_status,
            p_msg_count              => l_msg_count,
            p_msg_data               => l_msg_data,
            p_position_id            => l_position_cache(j).position_id,
            -- de by org
            p_organization_id        => l_position_cache(j).organization_id,
            p_data_extract_id        => p_data_extract_id,
            p_position_definition_id => l_position_cache(j).position_definition_id,
            p_hr_position_id         => l_position_cache(j).hr_position_id,
            p_hr_employee_id         => NULL,
            p_business_group_id      => p_business_group_id,
            p_effective_start_date   => l_position_cache(j).effective_start_date,
            p_effective_end_date     => l_position_cache(j).effective_end_date,
            p_set_of_books_id        => p_set_of_books_id,
            p_vacant_position_flag   => 'Y',
            p_transaction_id         => l_position_cache(j).transaction_id,
            p_transaction_status     => l_position_cache(j).transaction_status,
            p_attribute1             => NULL,
            p_attribute2             => NULL,
            p_attribute3             => NULL,
            p_attribute4             => NULL,
            p_attribute5             => NULL,
            p_attribute6             => NULL,
            p_attribute7             => NULL,
            p_attribute8             => NULL,
            p_attribute9             => NULL,
            p_attribute10            => NULL,
            p_attribute11            => NULL,
            p_attribute12            => NULL,
            p_attribute13            => NULL,
            p_attribute14            => NULL,
            p_attribute15            => NULL,
            p_attribute16            => NULL,
            p_attribute17            => NULL,
            p_attribute18            => NULL,
            p_attribute19            => NULL,
            p_attribute20            => NULL,
            p_attribute_category     => NULL,
            p_name                   => l_position_cache(j).name,
            p_mode                   => 'R'
            ) ;

     END IF;

  END LOOP;

  FOR i in 1..l_position_i_cache.count
  LOOP
      --
      -- DE by Org
      --
      -- If extract method is not REFRESH, get the status of the organization
      -- to which the position belongs from the already cached organization
      -- statuses.
      IF p_extract_method <> 'REFRESH' and p_extract_by_org = 'Y' THEN
        l_extract_method := g_org_status(l_position_i_cache(i).organization_id);
      END IF;

      IF (l_position_i_cache(i).hr_employee_id IS NOT NULL) THEN
        l_vacant_position_flag :=  'N';
      ELSE
        l_vacant_position_flag   := 'Y';
	l_rate_or_payscale_name  := NULL;
	l_grade_name             := NULL;
	l_rate_or_payscale_id    := l_position_i_cache(i).rate_or_payscale_id;
	l_grade_id               := l_position_i_cache(i).grade_id;
	l_grade_step             := l_position_i_cache(i).grade_step;
	l_sequence_number        := l_position_i_cache(i).sequence_number;
	l_pay_element_id         := NULL;
	l_pay_element_option_id  := NULL;

        IF (l_position_i_cache(i).salary_type = 'STEP') THEN
          --
	  FOR C_Sal_Rec in C_salary
	  LOOP
	    l_rate_or_payscale_name := C_Sal_Rec.rate_or_payscale_name;
	    l_grade_name            := C_Sal_Rec.grade_name;
	  END LOOP;
          --
	  FOR C_pay_elements_step_rec in C_pay_elements_step
	  LOOP
	   l_pay_element_id        := C_pay_elements_step_rec.pay_element_id;
	   l_salary_type           := C_pay_elements_step_rec.salary_type;
	   l_pay_element_option_id :=
                               C_pay_elements_step_rec.pay_element_option_id;
	  END LOOP;
          --
        END IF;

	IF (l_position_i_cache(i).salary_type = 'RATE') THEN
          --
	  FOR C_Sal_Rate_Rec in C_rate_salary
	  LOOP
	    l_rate_or_payscale_name := C_Sal_Rate_Rec.rate_or_payscale_name;
	    l_grade_name            := C_Sal_Rate_Rec.grade_name;
	  END LOOP;
          --
	  FOR C_pay_elements_rate_rec in C_pay_elements_rate
	  LOOP
	   l_pay_element_id        := C_pay_elements_rate_rec.pay_element_id;
	   l_salary_type           := C_pay_elements_rate_rec.salary_type;
	   l_pay_element_option_id :=
                                C_pay_elements_rate_rec.pay_element_option_id;
	  END LOOP;
          --
	END IF;

	FOR C_pay_element_rates_rec in C_pay_element_rates
	LOOP
	l_pay_element_rate_id  := C_pay_element_rates_rec.pay_element_rate_id;
	l_effective_start_date := C_pay_element_rates_rec.effective_start_date;
	l_effective_end_date   := C_pay_element_rates_rec.effective_end_date;
	l_element_value        := C_pay_element_rates_rec.element_value;
	l_currency_code        := C_pay_element_rates_rec.currency_code;
	END LOOP;
	-- Handle Grade,salary assignments for Position
      END IF;

      l_employee_name := NULL;
      l_position_name := NULL;

      if ((l_position_i_cache(i).hr_position_id <> prev_hr_position_id)
           and (prev_hr_position_id <> -1))
      then
        --l_hr_position_ctr := l_hr_position_ctr + 1; /* For Bug: 3066598 */
        /* Do Update_Reentry only at the time of the first failure
           with the last successful position or when the record
           count reaches g_checkpoint_save with no failed positions */

	if ((l_hr_position_ctr = PSB_WS_ACCT1.g_checkpoint_save) AND (l_status_flag <> 'I'))
            OR
            (l_last_success_flag = 'N')
        then
	  PSB_HR_EXTRACT_DATA_PVT.Update_Reentry
          ( p_api_version              => 1.0  ,
  	    p_return_status            => l_return_status,
	    p_msg_count                => l_msg_count,
  	    p_msg_data                 => l_msg_data,
	    p_data_extract_id          => p_data_extract_id,
	    p_extract_method           => p_extract_method,
	    p_process                  => 'PSB Positions',
	    p_restart_id               => prev_hr_position_id
	  ) ;
          --
          if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    raise FND_API.G_EXC_ERROR;
          end if;
          COMMIT WORK;
          l_last_success_flag := 'Y';
          l_hr_position_ctr := 0;
          Savepoint Populate_Position;
          --
        end if;
      end if;

      IF (l_position_i_cache(i).hr_employee_id IS NOT NULL) THEN
        FOR Emp_Name_Rec in G_Employee_Details(p_person_id =>
					       l_position_i_cache(i).hr_employee_id)
	LOOP
	  l_employee_name := Emp_Name_Rec.first_name || ' ' ||
                             Emp_Name_Rec.last_name;
	END LOOP;
      END IF;

      l_position_name := l_position_i_cache(i).hr_position_name;
      l_init_index    := 0;
      l_id_flex_num   := l_position_i_cache(i).id_flex_num;

      FOR C_flex_rec in
      (
	Select application_column_name
	FROM   fnd_id_flex_segments_vl
	WHERE  id_flex_code = 'BPS'
	AND    id_flex_num  = l_id_flex_num
	AND    enabled_flag = 'Y'
	ORDER  BY segment_num
      )
      LOOP
	l_init_index := l_init_index + 1;
	segs(l_init_index) := NULL;

	IF (C_flex_rec.application_column_name = 'SEGMENT1') THEN
	    segs(l_init_index)   := l_position_i_cache(i).segment1;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT2') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment2;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT3') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment3;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT4') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment4;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT5') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment5;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT6') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment6;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT7') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment7;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT8') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment8;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT9') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment9;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT10') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment10;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT11') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment11;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT12') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment12;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT13') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment13;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT14') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment14;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT15') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment15;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT16') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment16;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT17') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment17;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT18') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment18;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT19') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment19;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT20') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment20;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT21') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment21;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT22') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment22;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT23') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment23;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT24') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment24;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT25') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment25;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT26') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment26;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT27') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment27;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT28') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment28;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT29') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment29;
	END IF;
	IF (C_flex_rec.application_column_name = 'SEGMENT30') THEN
	   segs(l_init_index)   := l_position_i_cache(i).segment30;
	END IF;

      END LOOP; -- END LOOP ( C_flex_rec in C_flex )

      IF NOT FND_FLEX_EXT.Get_Combination_ID
	( application_short_name => 'PSB',
	  key_flex_code          => 'BPS',
	  structure_number       =>  l_position_i_cache(i).id_flex_num,
	  validation_date        =>  SYSDATE,
	  n_segments             =>  l_init_index,
	  segments               =>  segs,
	  combination_id         =>  l_ccid)
      THEN
        /* Whenever a failure occurs set the l_status_flag to 'I' and
           set the l_last_success_flag to 'N' but continue the extract
           process */
        /* For Bug No: 3066598 Start */
        IF l_status_flag <> 'I' THEN
          l_status_flag := 'I';
          l_last_success_flag := 'N';
        END IF;
        /* For Bug No: 3066598 End */

        l_msg := FND_MESSAGE.Get;
	FND_FILE.put_line(FND_FILE.LOG, 'Cannot import HRMS Position: '||
                                         l_position_i_cache(i).hr_position_id) ;
	FND_FILE.put_line(FND_FILE.LOG,l_msg);
	FND_MESSAGE.SET_NAME('PSB','PSB_POSITION_CCID_FAILURE');
	FND_MESSAGE.SET_TOKEN('POSITION_NAME',l_position_name );
	FND_MESSAGE.SET_TOKEN('ERR_MESG',l_msg);

       /* start bug no 4170600 */
        l_msg := FND_MESSAGE.GET;
        INSERT INTO PSB_ERROR_MESSAGES (
            CONCURRENT_REQUEST_ID,
            PROCESS_ID,
            SOURCE_PROCESS,
            SEQUENCE_NUMBER,
            DESCRIPTION,
            CREATION_DATE,
            CREATED_BY)
        VALUES (
        -4712, -4712, 'XXX', null, l_msg, SYSDATE, -1);
       /* end bug no 4170600 */

	FND_MSG_PUB.Add;
        --RAISE FND_API.G_EXC_ERROR;

      ELSE

        /* For Bug No: 3066598 Start */
        IF ((l_position_i_cache(i).hr_position_id <> prev_hr_position_id)
             AND (prev_hr_position_id <> -1))
        THEN
          l_hr_position_ctr := l_hr_position_ctr + 1;
        END IF;
        /* For Bug No: 3066598 End */
        l_concat_pos_name := NULL;

        l_concat_pos_name := FND_FLEX_EXT.Get_Segs
			   (application_short_name => 'PSB',
			    key_flex_code          => 'BPS',
			    structure_number       =>  l_position_i_cache(i).id_flex_num,
			    combination_id         =>  l_ccid);


-- commented out the old refresh cursor
/*      --
        -- Update the position in 'REFRESH' mode.
        --
        -- DE by Org
        --
        -- l_extract_method contains the organization's status. Hence using it
        -- in lieu of p_extract_method
        --
        IF (l_extract_method = 'REFRESH')  or (l_update_flag = 'Y') THEN

	  -- Variable to determine whether 'REFRESH' occurred or NOT.
	  l_dummy := 0;

	  FOR C_Refresh_Rec in
	  (
	    SELECT position_id,organization_id
	    FROM   psb_positions
	    WHERE  hr_position_id  = position_rec.hr_position_id
	    AND    ( NVL(hr_employee_id,-1)=NVL(position_rec.hr_employee_id,-1)
                                        OR
                     ( hr_employee_id IS NULL
                       AND
                       NOT EXISTS
                       ( SELECT 1
                         FROM   psb_positions
                         WHERE  hr_position_id = position_rec.hr_position_id
                         AND    hr_employee_id = position_rec.hr_employee_id
                         AND    data_extract_id = p_data_extract_id
                       )
                     )

                     OR
                     ( hr_employee_id IS NOT NULL
                       AND
                       NOT EXISTS
                       ( SELECT 1
                         FROM   psb_positions
                         WHERE  hr_position_id = position_rec.hr_position_id
                         AND    hr_employee_id  IS NULL
                         AND    data_extract_id = p_data_extract_id
                       )
                     )

                   )
	   AND     data_extract_id   = p_data_extract_id
	   AND     business_group_id = p_business_group_id
	  )
          LOOP
	    l_dummy := 1;

*/
    /* Bug 3417868 Start */
    IF l_position_i_cache(i).update_insert_flag = 'U' THEN
    /* Bug 3417868 End */


            -- bug 4551061 added the in parameter p_availability_status
	    PSB_POSITIONS_PVT.UPDATE_ROW
	    (
	    p_api_version            => 1.0,
	    p_init_msg_lISt          => FND_API.G_FALSE,
    	    p_commit                 => FND_API.G_FALSE,
	    p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
	    p_return_status          => l_return_status,
	    p_msg_count              => l_msg_count,
	    p_msg_data               => l_msg_data,
	    p_position_id            => l_position_i_cache(i).position_id,
            -- de by org
            p_organization_id        => l_position_i_cache(i).organization_id,
	    p_data_extract_id        => p_data_extract_id,
	    p_position_definition_id => l_ccid,
	    p_hr_position_id         => l_position_i_cache(i).hr_position_id,
	    p_hr_employee_id         => l_position_i_cache(i).hr_employee_id,
	    p_business_group_id      => p_business_group_id,
	    p_effective_start_date   => l_position_i_cache(i).effective_start_date,
	    p_effective_end_date     => l_position_i_cache(i).effective_end_date,
	    p_set_of_books_id        => p_set_of_books_id,
	    p_vacant_position_flag   => l_vacant_position_flag,
            p_availability_status    => l_position_i_cache(i).availability_status,
	    p_transaction_id         => l_position_i_cache(i).transaction_id,
	    p_transaction_status     => l_position_i_cache(i).transaction_status,
	    p_attribute1             => NULL,
	    p_attribute2             => NULL,
	    p_attribute3             => NULL,
	    p_attribute4             => NULL,
	    p_attribute5             => NULL,
	    p_attribute6             => NULL,
	    p_attribute7             => NULL,
	    p_attribute8             => NULL,
	    p_attribute9             => NULL,
	    p_attribute10            => NULL,
	    p_attribute11            => NULL,
	    p_attribute12            => NULL,
	    p_attribute13            => NULL,
	    p_attribute14            => NULL,
	    p_attribute15            => NULL,
	    p_attribute16            => NULL,
	    p_attribute17            => NULL,
	    p_attribute18            => NULL,
	    p_attribute19            => NULL,
	    p_attribute20            => NULL,
	    p_attribute_category     => NULL,
	    p_name                   => l_concat_pos_name,
	    p_mode                   => 'R'
	    ) ;
            --
	    l_elem_assign_dummy := 0;
	    l_position_id       := l_position_i_cache(i).position_id;

            /* start bug no 4213882 */
		l_assignment_rec_no := 0;
		l_assignment_exists := FALSE;

		-- Bug # 4886277: Used psb_data_extracts instead of
                -- fnd_sessions to get req_data_as_of_date.
                FOR l_assignment_rec IN
                    (SELECT a.effective_start_date,
                            a.effective_end_date
                     FROM per_all_assignments_f a,
                          psb_data_extracts b
                     WHERE a.position_id =l_position_i_cache(i).hr_position_id
                     AND a.person_id = l_position_i_cache(i).hr_employee_id
                     AND b.data_extract_id = p_data_extract_id
                     AND b.req_data_as_of_date between
                         a.effective_start_date AND a.effective_end_date)
		LOOP
		   l_assignment_exists := TRUE;
		   l_eff_start_date := l_assignment_rec.effective_start_date;

		   IF (l_assignment_rec.effective_end_date =
                             to_date('31124712','DDMMYYYY')) THEN
       	             l_eff_end_date := to_date(null);
   		   ELSE
                     l_eff_end_date := l_assignment_rec.effective_end_date;
                   END IF;
		END LOOP;

		IF NOT l_assignment_exists THEN
		 -- Bug # 4886277: Used psb_data_extracts instead of
                 -- fnd_sessions to get req_data_as_of_date.
                 FOR l_hr_position_rec IN
                     (SELECT a.effective_start_date,
                             a.effective_end_date
                      FROM hr_all_positions_f a,
                           psb_data_extracts b
                      WHERE a.position_id =l_position_i_cache(i).hr_position_id
                      AND b.data_extract_id = p_data_extract_id
                      AND b.req_data_as_of_date between
                          a.effective_start_date AND a.effective_end_date)
		 LOOP
		   l_eff_start_date := l_hr_position_rec.effective_start_date;
		   IF (l_hr_position_rec.effective_end_date =
                          to_date('31124712','DDMMYYYY')) THEN
       	             l_eff_end_date := to_date(null);
   		   ELSE
                     l_eff_end_date := l_hr_position_rec.effective_end_date;
                  END IF;
		 END LOOP;
		END IF;

	    /* end bug no 4213882 */

            -- for bug 4213882
	    -- changed the query to fetch from the table and moved the
            -- change from
	    -- from view to local cursor l_elm_asign_csr

	    -- Bug # 4886277: Changed the cursor name from l_elm_asign_csr
            --                to l_elem_assign_csr
	    For C_Pos_Elem_Rec in l_elem_assign_csr
                  (l_position_i_cache(i).position_id)
            LOOP
	      l_elem_assign_dummy := 1;

              /* start bug no 4213882 */
	      l_assignment_rec_no := l_assignment_rec_no + 1;
	      /* end bug no 4213882 */

	      /* start bug no 4213882 */
	      if l_assignment_rec_no < 2 then
	      /* end bug no 4213882 */

              PSB_POSITIONS_PVT.ModIFy_Assignment(
	      p_api_version            => 1.0,
	      p_return_status          => l_return_status,
	      p_msg_count              => l_msg_count,
	      p_msg_data               => l_msg_data,
	      p_position_assignment_id => C_Pos_Elem_Rec.position_assignment_id,
	      p_data_extract_id        => p_data_extract_id,
	      p_worksheet_id           => NULL,
	      p_position_id            => l_position_i_cache(i).position_id,
	      p_assignment_type        => 'ELEMENT',
	      p_attribute_id           => NULL,
	      p_attribute_value_id     => NULL,
	      p_attribute_value        => NULL,
	      p_pay_element_id         => l_pay_element_id,
	      p_pay_element_option_id  => l_pay_element_option_id,
	      p_effective_start_DATE   => l_position_i_cache(i).effective_start_date, --bug:7444415 --l_eff_start_date,
	      p_effective_END_DATE     => l_position_i_cache(i).effective_end_date, --bug:7444415 --l_eff_end_date,
	      p_element_value_type     => 'A',
	      p_element_value          => l_element_value,
	      p_currency_code          => l_currency_code,  --bug:7444415
	      p_pay_basIS              => l_position_i_cache(i).pay_basis,
	      p_global_default_flag    => NULL,
	      p_assignment_default_rule_id => NULL,
	      p_modIFy_flag            => NULL,
	      p_rowid                  => l_rowid,
	      p_employee_id            => NULL,
	      p_primary_employee_flag  => NULL
	      );
              --
	      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
              --

              /* start bug no 4213882 */
	      end if;
	      /* end bug no 4213882 */

            END LOOP;



/*          END LOOP;  -- END LOOP ( C_Refresh_Rec in C_Refresh )

	 -- l_update_flag := 'N';
        END IF; -- END IF (l_extract_method = 'REFRESH').

        --

*/

/*      -- Create new position in 'CREATE' mode.
        --
        IF ((l_extract_method = 'CREATE') or (l_dummy = 0))
          AND (l_update_flag <> 'Y')
*/
--        THEN /* For Bug No: 3066598 */
          --
    /* Bug 3417868 Start */
    ELSIF l_position_i_cache(i).update_insert_flag = 'I' THEN
    /* Bug 3417868 End */
          SELECT psb_positions_s.nextval INTO l_position_id
	  FROM   dual;

          -- bug 4551061 added the in parameter p_availability_status
	  PSB_POSITIONS_PVT.INSERT_ROW
	  (
	  p_api_version            => 1.0,
	  p_init_msg_lISt          => NULL,
	  p_commit                 => NULL,
	  p_validation_level       => NULL,
	  p_return_status          => l_return_status,
	  p_msg_count              => l_msg_count,
	  p_msg_data               => l_msg_data,
	  p_rowid                  => l_rowid,
	  p_position_id            => l_position_id,
          -- de by org
          p_organization_id        => l_position_i_cache(i).organization_id,
	  p_data_extract_id        => p_data_extract_id,
	  p_position_definition_id => l_ccid,
	  p_hr_position_id         => l_position_i_cache(i).hr_position_id,
	  p_hr_employee_id         => l_position_i_cache(i).hr_employee_id,
	  p_business_group_id      => p_business_group_id,
	  p_effective_start_date   => l_position_i_cache(i).effective_start_date,
	  p_effective_END_date     => l_position_i_cache(i).effective_END_date,
	  p_set_of_books_id        => p_set_of_books_id,
	  p_vacant_position_flag   => l_vacant_position_flag,
          p_availability_status    => l_position_i_cache(i).availability_status,
	  p_transaction_id         => l_position_i_cache(i).transaction_id,
	  p_transaction_status     => l_position_i_cache(i).transaction_status,
	  p_new_position_flag      => 'N',
	  p_attribute1             => NULL,
	  p_attribute2             => NULL,
	  p_attribute3             => NULL,
	  p_attribute4             => NULL,
	  p_attribute5             => NULL,
	  p_attribute6             => NULL,
	  p_attribute7             => NULL,
	  p_attribute8             => NULL,
	  p_attribute9             => NULL,
	  p_attribute10            => NULL,
	  p_attribute11            => NULL,
	  p_attribute12            => NULL,
	  p_attribute13            => NULL,
	  p_attribute14            => NULL,
	  p_attribute15            => NULL,
	  p_attribute16            => NULL,
	  p_attribute17            => NULL,
	  p_attribute18            => NULL,
	  p_attribute19            => NULL,
	  p_attribute20            => NULL,
	  p_attribute_category     => NULL,
	  p_name                   => l_concat_pos_name,
	  p_mode                   => 'R'
	  ) ;
	/*
        -- if vacant position
        END IF;  -- END FOR IF (p_extract_method = 'CREATE') or (l_dummy = 0)).
        */

        if (l_vacant_position_flag = 'Y') then

          IF l_position_i_cache(i).update_insert_flag = 'I' OR
            ((l_elem_assign_dummy = 0) and (l_pay_element_id is not null)) THEN
          --
        /*   if (((l_extract_method = 'CREATE') or (l_dummy = 0)) AND l_update_flag <> 'Y' )
             or ((l_elem_assign_dummy = 0) and (l_pay_element_id is not null))
             then  */
            --
            PSB_POSITION_ASSIGNMENTS_PVT.INSERT_ROW
	    (
	      p_api_version             => 1,
	      p_init_msg_lISt           => NULL,
    	      p_commit                  => NULL,
	      p_validation_level        => NULL,
	      p_return_status           => l_return_status,
	      p_msg_count               => l_msg_count,
	      p_msg_data                => l_msg_data,
	      p_rowid                   => l_rowid,
	      p_position_assignment_id  => l_position_assignment_id,
	      p_data_extract_id         => p_data_extract_id,
	      p_worksheet_id            => NULL,
	      p_position_id             => l_position_id,
	      p_assignment_type         => 'ELEMENT',
	      p_attribute_id            => NULL,
	      p_attribute_value_id      => NULL,
	      p_attribute_value         => NULL,
	      p_pay_element_id          => l_pay_element_id,
	      p_pay_element_option_id   => l_pay_element_option_id,
	      p_effective_start_date    => l_position_i_cache(i).effective_start_date,
	      p_effective_END_date      => l_position_i_cache(i).effective_end_date,
	      p_element_value_type      => 'A',
	      p_element_value           => l_position_i_cache(i).value,
	      p_currency_code           => l_currency_code,
	      p_pay_basIS               => l_position_i_cache(i).pay_basis,
	      p_employee_id             => NULL,
	      p_primary_employee_flag   => NULL,
	      p_global_default_flag     => NULL,
	      p_assignment_default_rule_id => NULL,
	      p_modIFy_flag             => NULL,
	      p_mode                    => 'R'
	    ) ;
            --
            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;

	  END IF;

        END IF; -- l_vacant_position_flag = 'Y'
        prev_hr_position_id := l_position_i_cache(i).hr_position_id;
        --
      END IF;  -- l_position_i_cache(i).update_insert_flag = 'U'
      END IF;  -- IF NOT FND_FLEX_EXT.Get_Combination_ID

    END LOOP;  --    FOR i in 1..l_position_i_cache.count
    END IF;    --    IF   (l_last_hr_position_id <> l_pos_record.hr_position_id

  -- populating the source pl/sql table
  /* Bug 3417868 Start */
  IF l_last_hr_position_id <> l_pos_record.hr_position_id
    OR l_last_hr_position_id IS NULL THEN
    l_position_i_cache.delete;
    l_source_cache_count := 0;
  END IF;

    l_source_cache_count := nvl(l_source_cache_count,0) + 1;

    l_position_i_cache(l_source_cache_count).hr_position_id
                                   := l_pos_record.hr_position_id;
    l_position_i_cache(l_source_cache_count).hr_employee_id
                                   := l_pos_record.hr_employee_id;
    l_position_i_cache(l_source_cache_count).organization_id
                                   := l_pos_record.organization_id;
    l_position_i_cache(l_source_cache_count).rate_or_payscale_id
                                  := l_pos_record.rate_or_payscale_id;
    l_position_i_cache(l_source_cache_count).grade_id
                                  := l_pos_record.grade_id;
    l_position_i_cache(l_source_cache_count).grade_step
                                  := l_pos_record.grade_step;
    l_position_i_cache(l_source_cache_count).sequence_number
                                  := l_pos_record.sequence_number;
    l_position_i_cache(l_source_cache_count).salary_type
                                  := l_pos_record.salary_type;
    l_position_i_cache(l_source_cache_count).hr_position_name
                                  := l_pos_record.hr_position_name;
    l_position_i_cache(l_source_cache_count).id_flex_num
                                  := l_pos_record.id_flex_num;
    l_position_i_cache(l_source_cache_count).effective_start_date
                                  := l_pos_record.effective_start_date;
    l_position_i_cache(l_source_cache_count).effective_end_date
                                  := l_pos_record.effective_end_date;
    l_position_i_cache(l_source_cache_count).transaction_id
                                  := l_pos_record.transaction_id;
    l_position_i_cache(l_source_cache_count).transaction_status
                                  := l_pos_record.transaction_status;
    l_position_i_cache(l_source_cache_count).pay_basis   := l_pos_record.pay_basis;
    l_position_i_cache(l_source_cache_count).value       := l_pos_record.value;
    l_position_i_cache(l_source_cache_count).segment1    := l_pos_record.segment1;
    l_position_i_cache(l_source_cache_count).segment2    := l_pos_record.segment2;
    l_position_i_cache(l_source_cache_count).segment3    := l_pos_record.segment3;
    l_position_i_cache(l_source_cache_count).segment4    := l_pos_record.segment4;
    l_position_i_cache(l_source_cache_count).segment5    := l_pos_record.segment5;
    l_position_i_cache(l_source_cache_count).segment6    := l_pos_record.segment6;
    l_position_i_cache(l_source_cache_count).segment7    := l_pos_record.segment7;
    l_position_i_cache(l_source_cache_count).segment8    := l_pos_record.segment8;
    l_position_i_cache(l_source_cache_count).segment9    := l_pos_record.segment9;
    l_position_i_cache(l_source_cache_count).segment10   := l_pos_record.segment10;
    l_position_i_cache(l_source_cache_count).segment11   := l_pos_record.segment11;
    l_position_i_cache(l_source_cache_count).segment12   := l_pos_record.segment12;
    l_position_i_cache(l_source_cache_count).segment13   := l_pos_record.segment13;
    l_position_i_cache(l_source_cache_count).segment14   := l_pos_record.segment14;
    l_position_i_cache(l_source_cache_count).segment15   := l_pos_record.segment15;
    l_position_i_cache(l_source_cache_count).segment16   := l_pos_record.segment16;
    l_position_i_cache(l_source_cache_count).segment17   := l_pos_record.segment17;
    l_position_i_cache(l_source_cache_count).segment18   := l_pos_record.segment18;
    l_position_i_cache(l_source_cache_count).segment19   := l_pos_record.segment19;
    l_position_i_cache(l_source_cache_count).segment20   := l_pos_record.segment20;
    l_position_i_cache(l_source_cache_count).segment21   := l_pos_record.segment21;
    l_position_i_cache(l_source_cache_count).segment22   := l_pos_record.segment22;
    l_position_i_cache(l_source_cache_count).segment23   := l_pos_record.segment23;
    l_position_i_cache(l_source_cache_count).segment24   := l_pos_record.segment24;
    l_position_i_cache(l_source_cache_count).segment25   := l_pos_record.segment25;
    l_position_i_cache(l_source_cache_count).segment26   := l_pos_record.segment26;
    l_position_i_cache(l_source_cache_count).segment27   := l_pos_record.segment27;
    l_position_i_cache(l_source_cache_count).segment28   := l_pos_record.segment28;
    l_position_i_cache(l_source_cache_count).segment29   := l_pos_record.segment29;
    l_position_i_cache(l_source_cache_count).segment30   := l_pos_record.segment30;

    /* Bug 4551061 Start */
    l_position_i_cache(l_source_cache_count).availability_status
                                  := l_pos_record.availability_status;
    /* Bug 4551061 End */

  IF l_position_source%NOTFOUND THEN
    EXIT;
  END IF;

    l_last_hr_position_id:= l_pos_record.hr_position_id;

  END LOOP; -- END processing all the positions FROM psb_positions_i table.
  CLOSE l_position_source;
  /* Bug 3417868 End */

    /* For Bug No: 3066598 Start */
    IF (l_status_flag <> 'I' ) or (l_last_success_flag = 'N') THEN
      --
      PSB_HR_EXTRACT_DATA_PVT.Update_Reentry
      ( p_api_version      =>  1.0  ,
        p_return_status    =>  l_return_status,
        p_msg_count        =>  l_msg_count,
        p_msg_data         =>  l_msg_data,
        p_data_extract_id  =>  p_data_extract_id,
        p_extract_method   =>  p_extract_method,
        p_process          =>  'PSB Positions',
        p_restart_id       =>  prev_hr_position_id
      );
      --
      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
      end if;
      --
    END IF;

    /* For Bug No: 3066598  Start*/
    IF (l_status_flag <> 'I' ) THEN
      --
      PSB_HR_EXTRACT_DATA_PVT.Reentrant_Process
      ( p_api_version     => 1.0  ,
        p_return_status   => l_return_status,
        p_msg_count       => l_msg_count,
        p_msg_data        => l_msg_data,
        p_data_extract_id => p_data_extract_id,
        p_extract_method  => p_extract_method,
        p_process         => 'PSB Positions'
      );
      --
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
    END IF;

    COMMIT WORK;

  END IF; -- Check IF (l_status = 'I')
  --
  -- for bug 4213882
  PSB_HR_POPULATE_DATA_PVT.g_extract_method := null;
  PSB_HR_POPULATE_DATA_PVT.g_pop_assignment := null;

EXCEPTION
  --
  WHEN FND_API.G_EXC_ERROR THEN
    --
    ROLLBACK to Populate_Position;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
		               p_data  => p_msg_data);
    FND_MESSAGE.SET_NAME('PSB', 'PSB_POSITION_DETAILS');
    FND_MESSAGE.SET_TOKEN('POSITION_NAME',l_position_name );
    FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME',l_employee_name );
    FND_MSG_PUB.Add;
  --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK to Populate_Position;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                               p_data  => p_msg_data);
    FND_MESSAGE.SET_NAME('PSB', 'PSB_POSITION_DETAILS');
    FND_MESSAGE.SET_TOKEN('POSITION_NAME',l_position_name );
    FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME',l_employee_name );
    FND_MSG_PUB.Add;
  --
  WHEN OTHERS THEN
    --
    ROLLBACK to Populate_Position;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                               p_data  => p_msg_data);

    FND_MESSAGE.SET_NAME('PSB', 'PSB_POSITION_DETAILS');
    FND_MESSAGE.SET_TOKEN('POSITION_NAME',l_position_name );
    FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME',l_employee_name );
    FND_MSG_PUB.Add;

    IF FND_MSG_PUB.Check_Msg_Level
      (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME ,
	                       l_api_name ) ;
    END IF;
    --
END Populate_Position_Information;
/*---------------------------------------------------------------------------*/


/* ----------------------------------------------------------------------- */
PROCEDURE Populate_Employee_Information
( p_api_version         IN      NUMBER,
  p_init_msg_lISt       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  -- de by org
  p_extract_by_org      IN      VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_business_group_id   IN      NUMBER,
  p_set_of_books_id     IN      NUMBER
) AS

  l_last_update_date    DATE;
  l_last_upDATEd_BY     number;
  l_last_upDATE_login   number;
  l_creation_DATE       DATE;
  l_created_BY          number;
  l_employee_id         number;
  l_position_name       varchar2(240);
  --UTF8 changes for Bug No : 2615261
  l_employee_name       varchar2(310);
  l_status              varchar2(1);
  l_restart_hr_position_id number := 0;
  l_hr_postion_ctr      number := 0;
  -- de by org
  l_extract_method      varchar2(30);

  l_api_name            CONSTANT VARCHAR2(30)   := 'Populate_Employee';
  l_api_version         CONSTANT NUMBER         := 1.0;

  -- Outer join IS NOT needed FOR ( pe.hr_employee_id  = pp.hr_employee_id)
  -- because psb_positions IS populated with proper hr_employee_id prior to
  -- running thIS process.
  /*For Bug No : 2594575 Start*/
  --Stop extracting secured data of employee
  --Removed the columns in psb_employees table
  /*For Bug No : 2594575 End*/

  Cursor C_Employees IS
    Select pe.hr_employee_id,
	   pe.hr_position_id,
	   position_id,
           -- de by org
           organization_id,
	   assignment_id,first_name,
	   full_name, known_as,
	   last_name, middle_names, title,
	   pe.effective_start_DATE,
	   pe.change_DATE,
	   grade_id,grade_step,sequence_number,
	   pay_basIS,rate_id,
	   salary_type,rate_or_payscale_id,
	   element_value,proposed_salary,
	   employee_number,
	   pp.set_of_books_id
      FROM psb_employees_i  pe,
	   psb_positions    pp
     WHERE pe.data_extract_id = p_data_extract_id
       AND pe.data_extract_id = pp.data_extract_id
       AND pe.hr_position_id  = pp.hr_position_id
       AND pe.hr_employee_id  = pp.hr_employee_id
       AND pe.hr_position_id > l_restart_hr_position_id
     ORDER BY pe.hr_position_id, proposed_salary;

 /*Bug: 5879418: Modified the cursor c_Terminated_Employees so that the cursor
                 picks only the Terminated employees from the Orgs that are
                 selected for Refresh in DE. Also modified the subquery which
                 picks the active population in HRMS as of DE date*/

  /*Cursor Added for Bug#4135280 */
  /*Modified the cursor for Bug#4166493, to take care of date tracked HR data*/
   CURSOR C_Terminated_Employees IS
   SELECT distinct position_assignment_id,pp.position_id,pe.hr_employee_id
      FROM psb_position_assignments ppa,psb_positions pp,psb_employees pe,
           per_all_assignments_f paf
      WHERE ppa.position_id=pp.position_id
      AND ppa.data_extract_id=p_data_extract_id
      -- start: 5879418
      AND pe.data_extract_id = ppa.data_extract_id
      AND pp.data_extract_id = pe.data_extract_id
      -- end: 5879418
      AND pp.hr_position_id > l_restart_hr_position_id
      AND paf.position_id=pp.hr_position_id
      AND paf.person_id=pe.hr_employee_id
      --start: 5879418
      AND paf.organization_id in (select organization_id
                                  from   psb_data_extract_orgs
                                  where  data_extract_id = p_data_extract_id
                                  and    (p_extract_by_org = 'N' or
                                          (p_extract_by_org = 'Y' and select_flag = 'Y')))
      --end: 5879418
      AND paf.person_id not in
                             (select person_id
                              from   per_all_assignments_f paf2,fnd_sessions fs,
                                     per_assignment_status_types past
                              where  fs.effective_date between paf2.effective_start_date
                                                             and paf2.effective_end_date
                                and paf2.assignment_type='E'
                                /*start bug:5879418*/
                                and past.assignment_status_type_id = paf2.assignment_status_type_id
                                and past.per_system_status = 'ACTIVE_ASSIGN'
                              --and position_id=paf.position_id     -- commented for bug:5879418
                                /*end bug:5879418*/
                              and fs.session_id=USERENV('sessionid'))
      AND paf.assignment_type='E'
      AND pp.hr_employee_id IS NULL
      AND ppa.assignment_type='EMPLOYEE';

/*      SELECT distinct position_assignment_id,pp.position_id,pe.hr_employee_id
      FROM psb_position_assignments ppa,psb_positions pp,psb_employees pe,
           per_all_assignments_f paf
      WHERE ppa.position_id=pp.position_id
      AND ppa.data_extract_id=p_data_extract_id
      AND pp.hr_position_id > l_restart_hr_position_id
      AND paf.position_id=pp.hr_position_id
      AND paf.person_id=pe.hr_employee_id
      AND not exists (select fs.session_id from fnd_sessions fs
                      where fs.effective_date between paf.effective_start_date
                         and paf.effective_end_date
                      and fs.session_id=USERENV('sessionid') )
      AND paf.assignment_type='E'
      AND pp.hr_employee_id IS NULL
      AND ppa.assignment_type ='EMPLOYEE'; */

    refresh_employee_id        number ;
    prev_hr_position_id        number := -1;
    prev_rate_or_payscale_id   number := -1;
    prev_rate_or_payscale_name varchar2(30);
    prev_grade_step            number;
    prev_grade_id              number;
    prev_grade_name            varchar2(80);
    prev_sequence_number       number;
    prev_element_value         number;
    prev_proposed_salary       number;
    prev_change_DATE           DATE;
    prev_pay_basIS             varchar2(30);
    prev_salary_type           varchar2(10);

    l_rowid                    varchar2(100);
    lr_position_id             number;
    lr_position_assignment_id  number;
    l_position_assignment_id   number;
    l_ppay_element_id          number;
    ln_pay_element_id          number := 0;
    l_ppay_element_option_id   number;
    l_ppay_element_rate_id     number;
    l_peffective_start_DATE    DATE;
    l_peffective_END_DATE      DATE;
    l_pelement_value           number;
    l_proposed_salary          number;
    l_currency_code            varchar2(30);
    l_return_status            varchar2(1);
    l_salary_type              varchar2(10);
    l_msg_count                number;
    l_msg_data                 varchar2(2000);
    l_employee_dummy           number := 1 ;
    l_element_dummy            number := 1 ;
    l_non_grade_salary         varchar2(1) := 'N';
    l_tmp                      varchar2(1);
    l_non_grade_salary_name    varchar2(30);
    l_hr_position_ctr        number := 0;

    Cursor C_currency IS
       Select currency_code
	 FROM gl_sets_of_books
	WHERE set_of_books_id = p_set_of_books_id;

    Cursor C_salary IS
       Select rate_or_payscale_name,grade_name
	 FROM psb_salary_i
	WHERE rate_or_payscale_id  = prev_rate_or_payscale_id
	  AND grade_id             = prev_grade_id
	  AND grade_step           = prev_grade_step
	  AND sequence_number      = prev_sequence_number
	  AND data_extract_id      = p_data_extract_id;

    Cursor C_rate_salary IS
       Select rate_or_payscale_name,grade_name
	 FROM psb_salary_i
	WHERE rate_or_payscale_id = prev_rate_or_payscale_id
	  AND grade_id            = prev_grade_id
	  AND data_extract_id     = p_data_extract_id;

    Cursor C_pay_elements_step IS
       Select ppe.pay_element_id ,ppe.salary_type,
	      ppo.pay_element_option_id
	 FROM psb_pay_elements ppe,
	      psb_pay_element_options ppo
	WHERE ppe.data_extract_id = p_data_extract_id
	  AND ppe.salary_type     = 'STEP'
	  AND ppe.name            = prev_rate_or_payscale_name
	  AND ppe.pay_element_id  = ppo.pay_element_id
	  AND ppo.name            = prev_grade_name
	  AND ppo.grade_step      = prev_grade_step
	  AND ppo.sequence_number = prev_sequence_number;

    Cursor C_pay_elements_rate IS
       Select ppe.pay_element_id ,ppe.salary_type,
	      ppo.pay_element_option_id
	 FROM psb_pay_elements ppe,
	      psb_pay_element_options ppo
	WHERE ppe.data_extract_id = p_data_extract_id
	  AND ppe.salary_type     = 'RATE'
	  AND ppe.name            = prev_rate_or_payscale_name
	  AND ppe.pay_element_id  = ppo.pay_element_id
	  AND ppo.name            = prev_grade_name;

    /*Cursor C_pay_element_options IS
       Select pay_element_option_id
	 FROM psb_pay_element_options
	WHERE pay_element_id  = l_ppay_element_id
	  AND name            = prev_grade_name
	  AND grade_step      = prev_grade_step
	  AND sequence_number = prev_sequence_number;

    Cursor C_pay_element_rate_options IS
       Select pay_element_option_id
	 FROM psb_pay_element_options
	WHERE pay_element_id  = l_ppay_element_id
	  AND name            = prev_grade_name; */

    Cursor C_pay_element_rates IS
       Select pay_element_rate_id,
	      effective_start_DATE,
	      effective_END_DATE,
	      element_value,
	      currency_code
	 FROM psb_pay_element_rates
	WHERE pay_element_id        = l_ppay_element_id
	  AND pay_element_option_id = l_ppay_element_option_id;

    Cursor C_non_grade_salary IS
       Select pay_element_id
	 FROM psb_pay_elements
	WHERE data_extract_id = p_data_extract_id
	  AND option_flag    = 'N'
	  AND overwrite_flag = 'Y'
	  AND name           = l_non_grade_salary_name;

BEGIN

  Savepoint Populate_Employee;

  l_last_upDATE_DATE  := sysDATE;
  l_last_upDATEd_BY   := FND_GLOBAL.USER_ID;
  l_last_upDATE_login := FND_GLOBAL.LOGIN_ID;
  l_creation_DATE     := sysDATE;
  l_created_BY        := FND_GLOBAL.USER_ID;

  -- StANDard call to check FOR call compatibility.

  IF NOT FND_API.Compatible_API_Call (l_api_version,
					p_api_version,
					l_api_name,
					G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message lISt IF p_init_msg_lISt IS set to TRUE.

  IF FND_API.to_Boolean (p_init_msg_lISt) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  -- de by org

  --  If extract_method is REFRESH do nothing.
  --  Else use the appropriate extract_method based on  the organization's
  --  extract status. cache_org_status caches statuses of all organizations.

  IF (p_extract_by_org = 'N' OR p_extract_method = 'REFRESH') THEN
     l_extract_method := p_extract_method;
  ELSE
     cache_org_status
         ( l_return_status,
           p_data_extract_id,
           p_extract_by_org
          );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

  END IF;



  PSB_HR_EXTRACT_DATA_PVT.Check_Reentry
  (  p_api_version              => 1.0  ,
     p_return_status            => l_return_status,
     p_msg_count                => l_msg_count,
     p_msg_data                 => l_msg_data,
     p_data_extract_id          => p_data_extract_id,
     p_process                  => 'PSB Employees',
     p_status                   => l_status,
     p_restart_id               => l_restart_hr_position_id
    );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (l_status = 'I') THEN

    -- Retrieve currency_code FOR the extract related set_of_books_id.
    FOR C_currency_rec in C_currency
    LOOP
      l_currency_code := C_currency_rec.currency_code;
    END LOOP;

    FOR employee_rec in C_Employees
    LOOP

      -- Initialize the local variables.
      prev_rate_or_payscale_name := NULL;
      prev_grade_name            := NULL;
      prev_rate_or_payscale_id := employee_rec.rate_or_payscale_id;
      prev_grade_id            := employee_rec.grade_id;
      prev_grade_step          := employee_rec.grade_step;
      prev_sequence_number     := employee_rec.sequence_number;
      prev_proposed_salary     := employee_rec.proposed_salary;
      prev_element_value       := employee_rec.element_value;
      prev_change_DATE         := employee_rec.change_DATE;
      prev_pay_basIS           := employee_rec.pay_basIS;
      prev_salary_type         := employee_rec.salary_type;
      l_position_name          := NULL;
      l_employee_name          := NULL;

    -- de by org
    -- If extract method is not REFRESH, get the status of the organization
    -- to which the employee belongs from the already cached organization
    -- statuses.

      IF p_extract_method <> 'REFRESH' and p_extract_by_org = 'Y' THEN
        l_extract_method := g_org_status(employee_rec.organization_id);
      END IF;


      IF (employee_rec.hr_employee_id IS NOT NULL) THEN
       FOR Emp_Name_Rec in G_Employee_Details(p_person_id => employee_rec.hr_employee_id)
       LOOP
	 l_employee_name := Emp_Name_Rec.first_name||' '||Emp_Name_Rec.last_name;
       END LOOP;
      END IF;

      IF (employee_rec.position_id IS NOT NULL) THEN
       FOR Pos_Name_Rec in G_Position_Details(p_position_id => employee_rec.position_id)
       LOOP
	 l_position_name := Pos_Name_Rec.name;
       END LOOP;
      END IF;

      l_non_grade_salary       := 'N';
      l_ppay_element_id        := 0;
      l_ppay_element_option_id := 0;
      l_ppay_element_rate_id   := 0;

      if ((employee_rec.hr_position_id <> prev_hr_position_id)
	and (prev_hr_position_id <> -1)) then
	l_hr_position_ctr := l_hr_position_ctr + 1;

       if l_hr_position_ctr = PSB_WS_ACCT1.g_checkpoint_save then
	   PSB_HR_EXTRACT_DATA_PVT.Update_Reentry
	   ( p_api_version              => 1.0  ,
	     p_return_status            => l_return_status,
	     p_msg_count                => l_msg_count,
	     p_msg_data                 => l_msg_data,
	     p_data_extract_id          => p_data_extract_id,
             p_extract_method           => p_extract_method,
	     p_process                  => 'PSB Employees',
	     p_restart_id               => prev_hr_position_id
	  );
	  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     raise FND_API.G_EXC_ERROR;
	  end if;
	  commit work;
	  l_hr_position_ctr := 0;
	  Savepoint Populate_Employee;
       end if;
      end if;

      /*IF (p_extract_method <> 'CREATE') THEN

	-- Store the employee_id FOR which refreshing will take place.
	-- Note thIS refresh_employee_id also points to a unique position.
	refresh_employee_id := employee_rec.hr_employee_id ;

	-- To refresh, first remove refresh employee_id related assignments.
	-- Note these assignments will be created/upDATEd later as part of
	-- refreshing.
	Begin

	  -- Delete 'ELEMENT' assignments.
	  Delete Psb_Position_Assignments
	   WHERE position_id     = employee_rec.position_id
	     AND data_extract_id = p_data_extract_id
	     AND assignment_type = 'ELEMENT';

	  -- Delete 'ATTRIBUTE' assignments.
	  Delete Psb_Position_Assignments
	   WHERE position_id     = employee_rec.position_id
	     AND data_extract_id = p_data_extract_id
	     AND assignment_type = 'ATTRIBUTE';

	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	    NULL;
	END; -- END remove FOR the refresh employe related assignments..

      END IF; -- END (p_extract_method <> 'CREATE') FOR Remove phase.*/

      -- Check whether the salary IS Grade one or NOT.
      IF ((prev_rate_or_payscale_id IS NULL) or (prev_rate_or_payscale_id = 0)
	 or (prev_grade_id IS NULL) or (prev_grade_id = 0))
      THEN

	l_non_grade_salary := 'Y';
	ln_pay_element_id := 0;
	l_non_grade_salary_name := '';
	fnd_message.set_name('PSB','PSB_NON_GRADE_SALARY');
	l_non_grade_salary_name  := FND_MESSAGE.GET;
	prev_rate_or_payscale_name := l_non_grade_salary_name;

	FOR C_non_grade_salary_rec in C_non_grade_salary
	LOOP
	  ln_pay_element_id := C_non_grade_salary_rec.pay_element_id;
	END LOOP;

	-- Create a pay element.
	IF (ln_pay_element_id = 0) THEN

	  Select psb_pay_elements_s.nextval INTO ln_pay_element_id
	  FROM   dual;

	  PSB_PAY_ELEMENTS_PVT.INSERT_ROW
	  ( p_api_version             =>  1.0,
	    p_init_msg_lISt           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_row_id                  => l_rowid,
	    p_pay_element_id          => ln_pay_element_id,
	    p_business_group_id       => p_business_group_id,
	    p_data_extract_id         => p_data_extract_id,
	    p_name                    => l_non_grade_salary_name,
	    p_description             => NULL,
	    p_element_value_type      => 'A',
	    p_FORmula_id              => NULL,
	    p_overwrite_flag          => 'Y',
	    p_required_flag           => NULL,
	    p_follow_salary           => NULL,
	    p_pay_basIS               => prev_pay_basIS,
	    p_start_DATE              => prev_change_DATE,
	    p_END_DATE                => NULL,
	    p_processing_type         => 'R',
	    p_period_type             => NULL,
	    p_process_period_type     => NULL,
	    p_max_element_value_type  => NULL,
	    p_max_element_value       => NULL,
	    p_salary_flag             => 'Y',
	    p_salary_type             => 'VALUE',
	    p_option_flag             => 'N',
	    p_hr_element_type_id      => NULL,
	    p_attribute_category      => NULL,
	    p_attribute1              => NULL,
	    p_attribute2              => NULL,
	    p_attribute3              => NULL,
	    p_attribute4              => NULL,
	    p_attribute5              => NULL,
	    p_attribute6              => NULL,
	    p_attribute7              => NULL,
	    p_attribute8              => NULL,
	    p_attribute9              => NULL,
	    p_attribute10             => NULL,
	    p_last_upDATE_DATE        => l_last_update_date,
	    p_last_upDATEd_BY         => l_last_upDATEd_BY,
	    p_last_upDATE_login       => l_last_upDATE_login,
	    p_created_BY              => l_created_BY,
	    p_creation_DATE           => l_creation_DATE
	  );

	  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;

	END IF; -- Check IF (ln_pay_element_id = 0) to create a pay element.

      END IF; -- ENd checking whether the salary IS Grade one or NOT.

      IF (l_non_grade_salary = 'N') THEN

	IF (prev_salary_type = 'STEP') THEN
	  FOR C_Sal_Rec in C_salary
	    LOOP
	      prev_rate_or_payscale_name := C_Sal_Rec.rate_or_payscale_name;
	      prev_grade_name            := C_Sal_Rec.grade_name;
	  END LOOP;
	  FOR C_pay_elements_step_rec in C_pay_elements_step
	  LOOP
	   l_ppay_element_id        := C_pay_elements_step_rec.pay_element_id;
	   l_salary_type            := C_pay_elements_step_rec.salary_type;
	   l_ppay_element_option_id := C_pay_elements_step_rec.pay_element_option_id;
	  END LOOP;
	END IF;

	IF (prev_salary_type = 'RATE') THEN
	  FOR C_Sal_Rate_Rec in C_rate_salary
	  LOOP
	    prev_rate_or_payscale_name :=
				      C_Sal_Rate_Rec.rate_or_payscale_name;
	    prev_grade_name            := C_Sal_Rate_Rec.grade_name;
	  END LOOP;
	  FOR C_pay_elements_rate_rec in C_pay_elements_rate
	  LOOP
	   l_ppay_element_id        := C_pay_elements_rate_rec.pay_element_id;
	   l_salary_type            := C_pay_elements_rate_rec.salary_type;
	   l_ppay_element_option_id := C_pay_elements_rate_rec.pay_element_option_id;
	  END LOOP;
	END IF;

	FOR C_pay_element_rates_rec in C_pay_element_rates
	LOOP
	  l_ppay_element_rate_id :=
				C_pay_element_rates_rec.pay_element_rate_id;
	  l_peffective_start_DATE :=
			       C_pay_element_rates_rec.effective_start_DATE;
	  l_peffective_END_DATE := C_pay_element_rates_rec.effective_END_DATE;
	  l_pelement_value      := C_pay_element_rates_rec.element_value;
	  l_currency_code       := C_pay_element_rates_rec.currency_code;
	END LOOP;

      else

	l_ppay_element_id := ln_pay_element_id;

      END IF; -- IF (l_non_grade_salary = 'N') clause.




      --
      -- UpDATE 'EMPLOYEE' type assignments in 'REFRESH' mode..
      -- UpDATE psb_employees table as well.
      --
      -- de by org
      --
      -- l_extract_method contains the organization's status. Hence using it
      -- in lieu of p_extract_method

      IF (l_extract_method = 'REFRESH') THEN

         /*For Bug No : 2594575 Start*/
         --Stop extracting secured data of employee
         --Removed the columns in psb_employees table
         /*For Bug No : 2594575 End*/

	 -- UpDATE psb_employees table.
	 UpDATE Psb_Employees
	     set first_name           = employee_rec.first_name,
		 full_name            = employee_rec.full_name,
		 known_as             = employee_rec.known_as,
		 last_name            = employee_rec.last_name,
		 middle_names         = employee_rec.middle_names,
		 title                = employee_rec.title,
		 last_upDATE_DATE     = l_last_update_date,
		 last_upDATEd_BY      = l_last_upDATEd_BY,
		 last_upDATE_login    = l_last_upDATE_login,
		 created_BY           = l_created_BY,
		 creation_DATE        = l_creation_DATE
	   WHERE hr_employee_id       = employee_rec.hr_employee_id
	     AND data_extract_id      = p_data_extract_id
	     AND business_group_id    = p_business_group_id;

	--
	l_employee_dummy := 0;

	-- UpDATE position related assignment
	-- (position_id = hr_employee_id + hr_position_id)
	FOR l_pos_assignment_rec in
	(
	  Select employee_id, position_assignment_id
	  FROM   psb_position_assignments
	  WHERE  data_extract_id = p_data_extract_id
	  AND    assignment_type = 'EMPLOYEE'
	  AND    position_id     = employee_rec.position_id
	)
	LOOP

	  l_employee_dummy := 1;

	  PSB_POSITIONS_PVT.ModIFy_Assignment
	  (
	    p_api_version             => 1.0,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_position_assignment_id  =>
				 l_pos_assignment_rec.position_assignment_id,
	    p_data_extract_id         => p_data_extract_id,
	    p_worksheet_id            => NULL,
	    p_position_id             => employee_rec.position_id,
	    p_assignment_type         => 'EMPLOYEE',
	    p_attribute_id            => NULL,
	    p_attribute_value_id      => NULL,
	    p_attribute_value         => NULL,
	    p_pay_element_id          => NULL,
	    p_pay_element_option_id   => NULL,
	    p_effective_start_DATE    => employee_rec.effective_start_DATE,
	    p_effective_END_DATE      => NULL,
	    p_element_value_type      => NULL,
	    p_element_value           => NULL,
	    p_currency_code           => NULL,
	    p_pay_basIS               => NULL,
	    p_global_default_flag     => NULL,
	    p_assignment_default_rule_id => NULL,
	    p_modIFy_flag             => NULL,
	    p_rowid                   => l_rowid,
	    p_employee_id             => l_pos_assignment_rec.employee_id,
	    p_primary_employee_flag   => 'Y'
	  );

	  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;

	END LOOP; -- END upDATE position related assignment.

      END IF; -- END updating 'EMPLOYEE' type assignments in 'REFRESH' mode.

      --
      -- UpDATE 'ELEMENT' type assignments in 'REFRESH' mode..
      --
      -- de by org
      --
      -- l_extract_method contains the organization's status. Hence using it
      -- in lieu of p_extract_method

      IF (l_extract_method = 'REFRESH') THEN

	-- l_element_dummy determines whether at least one record got refreshed
	-- or NOT. If NOT, we consider 'CREATE' mode later FOR updation etc.
	l_element_dummy := 0;

	-- Refresh position element assignments with the new element value.
	FOR C_element_assignments_rec in
	(
	   Select position_assignment_id,
		  employee_id
	   FROM   psb_position_assign_element_v
	   WHERE  data_extract_id = p_data_extract_id
	   AND    position_id     = employee_rec.position_id
	   AND    salary_flag     = 'Y'
	)
	LOOP

	  l_element_dummy := 1;

	  IF ((prev_element_value is not null) and (prev_proposed_salary = prev_element_value)) THEN
	    l_proposed_salary := NULL;
	  else
	    l_proposed_salary := prev_proposed_salary;
	  END IF;

	  PSB_POSITION_ASSIGNMENTS_PVT.UPDATE_ROW
	  (
	    p_api_version             => 1,
	    p_init_msg_lISt           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_position_assignment_id  =>
			      C_element_assignments_rec.position_assignment_id,
	    p_pay_element_id          => l_ppay_element_id,
	    p_pay_element_option_id   => l_ppay_element_option_id,
	    p_attribute_value_id      => NULL,
	    p_attribute_value         => NULL,
	    p_effective_END_DATE      => NULL,
	    p_element_value_type      => 'A',
	    p_element_value           => l_proposed_salary,
	    p_pay_basIS               => prev_pay_basIS,
	    p_employee_id             => C_element_assignments_rec.employee_id,
	    p_primary_employee_flag   => NULL,
	    p_global_default_flag     => NULL,
	    p_assignment_default_rule_id => NULL,
	    p_modIFy_flag             => NULL,
	    p_mode                    => 'R'
	  ) ;

	  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;

	END LOOP; -- END refreshing position element assignments.

      END IF; -- Check (p_extract_method = 'REFRESH') to refresh element_value.

      --
      -- Create 'EMPLOYEE' assignments in 'CREATE' mode.
      -- Populate employees in psb_employees table as well.
      --
      IF (l_extract_method = 'CREATE' or l_employee_dummy = 0) THEN

	Select psb_employees_s.nextval INTO l_employee_id
	FROM   dual;

        /*For Bug No : 2594575 Start*/
        --Stop extracting secured data of employee
        --Removed the columns in psb_employees table
        /*For Bug No : 2594575 End*/

	-- Populate PSB_EMPLOOYEES table as it IS 'CREATE' mode.
	INSERT INTO PSB_EMPLOYEES
	( EMPLOYEE_ID       ,
	  HR_EMPLOYEE_ID    ,
	  EMPLOYEE_NUMBER   ,
	  FIRST_NAME        ,
	  FULL_NAME         ,
	  KNOWN_AS          ,
	  LAST_NAME         ,
	  MIDDLE_NAMES      ,
	  TITLE             ,
	  BUSINESS_GROUP_ID ,
	  LAST_UPDATE_DATE   ,
	  LAST_UPDATED_BY    ,
	  LAST_UPDATE_LOGIN  ,
	  CREATED_BY         ,
	  CREATION_DATE      ,
	  DATA_EXTRACT_ID    )
	VALUES
	( l_employee_id,
	  employee_rec.hr_employee_id,
	  employee_rec.employee_number,
	  employee_rec.first_name,
	  employee_rec.full_name,
	  employee_rec.known_as,
	  employee_rec.last_name,
	  employee_rec.middle_names,
	  employee_rec.title,
	  p_business_group_id,
	  l_last_update_date,
	  l_last_upDATEd_BY ,
	  l_last_upDATE_login ,
	  l_created_BY,
	  l_creation_DATE,
	  p_data_extract_id
	);

	-- Create an 'EMPLOYEE' assignment FOR the related position_id.
	PSB_POSITION_ASSIGNMENTS_PVT.INSERT_ROW
	(
	  p_api_version             => 1,
	  p_init_msg_lISt           => NULL,
	  p_commit                  => NULL,
	  p_validation_level        => NULL,
	  p_return_status           => l_return_status,
	  p_msg_count               => l_msg_count,
	  p_msg_data                => l_msg_data,
	  p_rowid                   => l_rowid,
	  p_position_assignment_id  => l_position_assignment_id,
	  p_data_extract_id         => p_data_extract_id,
	  p_worksheet_id            => NULL,
	  p_position_id             => employee_rec.position_id,
	  p_assignment_type         => 'EMPLOYEE',
	  p_attribute_id            => NULL,
	  p_attribute_value_id      => NULL,
	  p_attribute_value         => NULL,
	  p_pay_element_id          => NULL,
	  p_pay_element_option_id   => NULL,
	  p_effective_start_DATE    => employee_rec.effective_start_DATE,
	  p_effective_END_DATE      => NULL,
	  p_element_value_type      => NULL,
	  p_element_value           => NULL,
	  p_currency_code           => NULL,
	  p_pay_basIS               => NULL,
	  p_employee_id             => l_employee_id,
	  p_primary_employee_flag   => 'Y' ,
	  p_global_default_flag     => NULL,
	  p_assignment_default_rule_id => NULL,
	  p_modIFy_flag             => NULL,
	  p_mode                    => 'R'
	) ;

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  RAISE FND_API.G_EXC_ERROR;
	END IF;

      END IF; -- END creating 'EMPLOYEE' assignments in 'CREATE' mode.

      --
      -- Create 'ELEMENT' type assignments in 'CREATE' mode.
      --
      IF ( l_extract_method = 'CREATE' or l_element_dummy = 0 ) THEN

	IF ((prev_element_value is not null) and (prev_proposed_salary = prev_element_value)) THEN
	  l_proposed_salary := NULL;
	else
	  l_proposed_salary := prev_proposed_salary;
	END IF;

	PSB_POSITION_ASSIGNMENTS_PVT.INSERT_ROW
	(
	  p_api_version             => 1,
	  p_init_msg_lISt           => NULL,
	  p_commit                  => NULL,
	  p_validation_level        => NULL,
	  p_return_status           => l_return_status,
	  p_msg_count               => l_msg_count,
	  p_msg_data                => l_msg_data,
	  p_rowid                   => l_rowid,
	  p_position_assignment_id  => l_position_assignment_id,
	  p_data_extract_id         => p_data_extract_id,
	  p_worksheet_id            => NULL,
	  p_position_id             => employee_rec.position_id,
	  p_assignment_type         => 'ELEMENT',
	  p_attribute_id            => NULL,
	  p_attribute_value_id      => NULL,
	  p_attribute_value         => NULL,
	  p_pay_element_id          => l_ppay_element_id,
	  p_pay_element_option_id   => l_ppay_element_option_id,
	  p_effective_start_DATE    => prev_change_DATE,
	  p_effective_END_DATE      => NULL,
	  p_element_value_type      => 'A',
	  p_element_value           => l_proposed_salary,
	  p_currency_code           => l_currency_code,
	  p_pay_basIS               => prev_pay_basIS,
	  p_employee_id             => l_employee_id,
	  p_primary_employee_flag   => NULL,
	  p_global_default_flag     => NULL,
	  p_assignment_default_rule_id => NULL,
	  p_modIFy_flag             => NULL,
	  p_mode                    => 'R'
	) ;

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	  RAISE FND_API.G_EXC_ERROR;
	END IF;

      END IF; -- END creating 'ELEMENT' type assignments in 'CREATE' mode..

      prev_hr_position_id := employee_rec.hr_position_id;

    END LOOP; -- FOR employee_rec in C_Employees

    --Logic added to fix bug#4135280
        --Delete the employee related assignments for terminated employees.
        -- Assumption is such employee's hr_employee_id column of position
        -- records will already be updated  to NULL
        --This is applicable only while refreshing the DE.

    IF (l_extract_method = 'REFRESH') THEN

       FOR terminated_rec IN C_Terminated_Employees
       LOOP

          PSB_POSITION_ASSIGNMENTS_PVT.Delete_Row
            ( p_api_version => 1.0,
              p_return_status => l_return_status,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_position_assignment_id =>terminated_rec.position_assignment_id);

          --Delete the terminated and to be orphanned record in psb_employees
          --Note that we are deleting for the DE and hence all the
          -- worksheets for this DE.

         delete from psb_employees
         where hr_employee_id=terminated_rec.hr_employee_id
         and data_extract_id=p_data_extract_id;

      END LOOP; -- FOR terminated_rec
    END IF;

   PSB_HR_EXTRACT_DATA_PVT.Update_Reentry
   ( p_api_version              => 1.0  ,
     p_return_status            => l_return_status,
     p_msg_count                => l_msg_count,
     p_msg_data                 => l_msg_data,
     p_data_extract_id          => p_data_extract_id,
     p_extract_method           => p_extract_method,
     p_process                  => 'PSB Employees',
     p_restart_id               => prev_hr_position_id
   );
   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    end if;

    PSB_HR_EXTRACT_DATA_PVT.Reentrant_Process
    ( p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_msg_count                => l_msg_count,
      p_msg_data                 => l_msg_data,
      p_data_extract_id          => p_data_extract_id,
      p_extract_method           => p_extract_method,
      p_process                  => 'PSB Employees'
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    commit work;

  END IF;

  -- END of API body.

  EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK to Populate_Employee;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);
     FND_MESSAGE.SET_NAME('PSB', 'PSB_POSITION_DETAILS');
     FND_MESSAGE.SET_TOKEN('POSITION_NAME',l_position_name );
     FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME',l_employee_name );
     FND_MSG_PUB.Add;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK to Populate_Employee;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);
     FND_MESSAGE.SET_NAME('PSB', 'PSB_POSITION_DETAILS');
     FND_MESSAGE.SET_TOKEN('POSITION_NAME',l_position_name );
     FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME',l_employee_name );
     FND_MSG_PUB.Add;

   WHEN OTHERS THEN
     ROLLBACK to Populate_Employee;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);

     FND_MESSAGE.SET_NAME('PSB', 'PSB_POSITION_DETAILS');
     FND_MESSAGE.SET_TOKEN('POSITION_NAME',l_position_name );
     FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME',l_employee_name );
     FND_MSG_PUB.Add;

     IF FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
     END IF;

END Populate_Employee_Information;

/* ----------------------------------------------------------------------- */

PROCEDURE Populate_Element_Information
( p_api_version         IN      NUMBER,
  p_init_msg_lISt       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  p_extract_method      IN      VARCHAR2,
  p_business_group_id   IN      NUMBER,
  p_set_of_books_id     IN      NUMBER
) AS

  l_last_update_date        DATE;
  l_last_upDATEd_BY         number;
  l_last_upDATE_login       number;
  l_creation_DATE           DATE;
  l_created_BY              number;
  l_dummy                   number;
  l_option_dummy            number;
  l_status                  varchar2(1);
  lr_rate_or_payscale_name  varchar2(30);
  lr_salary_type            varchar2(10);
  lr_grade_name             varchar2(240);
  lr_grade_step             number;
  lr_sequence_number        number;
  lm_rate_or_payscale_name  varchar2(30);
  lm_salary_type            varchar2(10);
  lm_grade_name             varchar2(240);
  lm_grade_step             number;
  lm_sequence_number        number;
  l_restart_salary_id       number := 0;
  l_api_name            CONSTANT VARCHAR2(30)   := 'Populate_Element';
  l_api_version         CONSTANT NUMBER         := 1.0;

  Cursor C_Elements IS
    Select salary_type, rate_or_payscale_id,
	   rate_or_payscale_name, grade_id,
	   grade_name, grade_step, sequence_number,
	   minimum_value, maximum_value,
	   mid_value, element_value,pay_basIS,
	   element_type_id,
	   effective_start_DATE, effective_END_DATE
      FROM psb_salary_i
     WHERE data_extract_id   = p_data_extract_id
       AND rate_or_payscale_id > l_restart_salary_id
     ORDER BY rate_or_payscale_id, salary_type;

  Cursor C_Refresh IS
     Select rowid,pay_element_id, budget_set_id,period_type
       FROM psb_pay_elements
      WHERE data_extract_id   = p_data_extract_id
	AND name              = lr_rate_or_payscale_name
	AND salary_type       = lr_salary_type;

  Cursor C_currency IS
     Select currency_code
       FROM gl_sets_of_books
      WHERE set_of_books_id = p_set_of_books_id;

    l_rowid varchar2(100);
    l_orowid varchar2(100);
    l_rrowid varchar2(100);
    l_return_status     varchar2(1);
    l_pay_element_option_id number;
    l_pay_element_rate_id   number;
    l_pay_element_id  number;
    l_msg_count number;
    l_msg_data  varchar2(2000);
    prev_rate_or_payscale_id number := -1;
    prev_salary_type varchar2(10) := 'X';
    l_currency_code varchar2(30);
    l_salary_ctr number := 0;

  Cursor C_Ref_Option IS
     Select rowid, pay_element_option_id
       FROM PSB_PAY_ELEMENT_OPTIONS
      WHERE pay_element_id = l_pay_element_id
	AND name = lr_grade_name
	AND grade_step = lr_grade_step
	AND sequence_number = lr_sequence_number;

  Cursor C_Ref_Rate_Option IS
     Select rowid, pay_element_option_id
       FROM PSB_PAY_ELEMENT_OPTIONS
      WHERE pay_element_id = l_pay_element_id
	AND name = lr_grade_name;
Begin

    Savepoint Populate_Element;
    l_last_update_date := sysDATE;
    l_last_upDATEd_BY := FND_GLOBAL.USER_ID;
    l_last_upDATE_login :=FND_GLOBAL.LOGIN_ID;
    l_creation_DATE     := sysDATE;
    l_created_BY        := FND_GLOBAL.USER_ID;


    IF NOT FND_API.Compatible_API_Call (l_api_version,
					p_api_version,
					l_api_name,
					G_PKG_NAME)
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message lISt IF p_init_msg_lISt IS set to TRUE.

    IF FND_API.to_Boolean (p_init_msg_lISt) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body


    PSB_HR_EXTRACT_DATA_PVT.Check_Reentry
    (p_api_version              => 1.0  ,
     p_return_status            => l_return_status,
     p_msg_count                => l_msg_count,
     p_msg_data                 => l_msg_data,
     p_data_extract_id          => p_data_extract_id,
     p_process                  => 'PSB Elements',
     p_status                   => l_status,
     p_restart_id               => l_restart_salary_id
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_status = 'I') THEN
       FOR C_currency_rec in C_currency
       LOOP
	 l_currency_code := C_currency_rec.currency_code;
       END LOOP;

       FOR C_Element_Rec in C_Elements
       LOOP
	  lm_rate_or_payscale_name := NULL;
	  lm_salary_type           := NULL;
	  lm_grade_name            := NULL;
	  lm_grade_step            := NULL;
	  lm_sequence_number       := NULL;

	  lm_rate_or_payscale_name := C_Element_Rec.rate_or_payscale_name;
	  lm_salary_type           := C_Element_Rec.salary_type;
	  lm_grade_name            := C_Element_Rec.grade_name;
	  lm_grade_step            := C_Element_Rec.grade_step;
	  lm_sequence_number       := C_Element_Rec.sequence_number;

	if ((C_Element_Rec.rate_or_payscale_id <> prev_rate_or_payscale_id) and
	   (prev_rate_or_payscale_id <> -1)) then
	   l_salary_ctr  := l_salary_ctr + 1;
	   if l_salary_ctr = PSB_WS_ACCT1.g_checkpoint_save then
	      PSB_HR_EXTRACT_DATA_PVT.Update_Reentry
	      ( p_api_version              => 1.0  ,
		p_return_status            => l_return_status,
		p_msg_count                => l_msg_count,
		p_msg_data                 => l_msg_data,
		p_data_extract_id          => p_data_extract_id,
		p_extract_method           => p_extract_method,
		p_process                  => 'PSB Elements',
		p_restart_id               => prev_rate_or_payscale_id
	      );

	     if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		raise FND_API.G_EXC_ERROR;
	     end if;
	     commit work;
	     l_salary_ctr := 0;
	     Savepoint Populate_Element;
	   end if;
       end if;

       IF (p_extract_method = 'REFRESH') THEN
	  lr_rate_or_payscale_name :=  C_Element_Rec.rate_or_payscale_name;
	  lr_salary_type := C_Element_Rec.salary_type;
	  l_dummy := 0;
	  FOR C_Refresh_Rec in C_Refresh
	  LOOP
	  l_dummy := 1;
	  IF ((C_Element_Rec.rate_or_payscale_id <> prev_rate_or_payscale_id)
	      or (C_Element_Rec.salary_type <> prev_salary_type)
	      or (prev_salary_type = 'X')
	      or (prev_rate_or_payscale_id = -1)) THEN
	  PSB_PAY_ELEMENTS_PVT.UPDATE_ROW
	  ( p_api_version             =>  1.0,
	    p_init_msg_lISt           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_row_id                  => C_Refresh_Rec.rowid,
	    p_pay_element_id          => C_Refresh_Rec.pay_element_id,
	    p_budget_set_id           => C_Refresh_Rec.budget_set_id,
	    p_business_group_id       => p_business_group_id,
	    p_data_extract_id         => p_data_extract_id,
	    p_name                    => lr_rate_or_payscale_name,
	    p_description             => NULL,
	    p_element_value_type      => 'A',
	    p_FORmula_id              => NULL,
	    p_overwrite_flag          => NULL,
	    p_required_flag           => NULL,
	    p_follow_salary           => NULL,
	    p_pay_basIS               => C_Element_Rec.pay_basIS,
	    p_start_DATE              => C_Element_Rec.effective_start_DATE,
	    p_END_DATE                => C_Element_Rec.effective_END_DATE,
	    p_processing_type         => 'R',
    	/*
	   Pass the existing period_type istead of NULL to resolve the issue in Bug No: 2852998
	   We should not set/override the period_type to NULL in case of REFRESH mode,
      since the period_type    doesn't come from HR
	   */
	    p_period_type             => C_Refresh_Rec.period_type,
	    p_process_period_type     => NULL,
	    p_max_element_value_type  => NULL,
	    p_max_element_value       => NULL,
	    p_salary_flag             => 'Y',
	    p_salary_type             => C_Element_Rec.salary_type,
	    p_option_flag             => 'Y',
	    p_hr_element_type_id      => C_Element_Rec.element_type_id,
	    p_attribute_category      => NULL,
	    p_attribute1              => NULL,
	    p_attribute2              => NULL,
	    p_attribute3              => NULL,
	    p_attribute4              => NULL,
	    p_attribute5              => NULL,
	    p_attribute6              => NULL,
	    p_attribute7              => NULL,
	    p_attribute8              => NULL,
	    p_attribute9              => NULL,
	    p_attribute10             => NULL,
	    p_last_upDATE_DATE        => l_last_update_date,
	    p_last_upDATEd_BY         => l_last_upDATEd_BY,
	    p_last_upDATE_login       => l_last_upDATE_login
	  );

	   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     RAISE FND_API.G_EXC_ERROR;
	   END IF;
	 END IF;

	 lr_grade_name := C_Element_Rec.grade_name;
	 lr_grade_step := C_Element_Rec.grade_step;
	 lr_sequence_number := C_Element_Rec.sequence_number;
	 l_pay_element_id := C_Refresh_Rec.pay_element_id;

	 l_option_dummy := 0;

	 IF (C_Element_Rec.salary_type = 'STEP') THEN
	 FOR C_Ref_Option_Rec in C_Ref_Option
	 LOOP
	  l_option_dummy := 1;
	  l_pay_element_option_id := C_Ref_Option_Rec.pay_element_option_id;
	  PSB_PAY_ELEMENT_OPTIONS_PVT.UPDATE_ROW
	  ( p_api_version             =>  1.0,
	    p_init_msg_lISt           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_pay_element_option_id   => C_Ref_Option_Rec.pay_element_option_id,
	    p_pay_element_id          => C_Refresh_Rec.pay_element_id,
	    p_name                    => C_Element_Rec.grade_name,
	    p_grade_step              => C_Element_Rec.grade_step,
	    p_sequence_number         => C_Element_Rec.sequence_number,
	    p_last_upDATE_DATE        => l_last_update_date,
	    p_last_upDATEd_BY         => l_last_upDATEd_BY,
	    p_last_upDATE_login       => l_last_upDATE_login
	 );

	   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     RAISE FND_API.G_EXC_ERROR;
	   END IF;
	  END LOOP;
	 END IF;

	 IF (C_Element_Rec.salary_type = 'RATE') THEN
	 FOR C_Ref_Rate_Rec in C_Ref_Rate_Option
	 LOOP
	  l_option_dummy := 1;
	  l_pay_element_option_id := C_Ref_Rate_Rec.pay_element_option_id;
	  PSB_PAY_ELEMENT_OPTIONS_PVT.UPDATE_ROW
	  ( p_api_version             =>  1.0,
	    p_init_msg_lISt           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_pay_element_option_id   => C_Ref_Rate_Rec.pay_element_option_id,
	    p_pay_element_id          => C_Refresh_Rec.pay_element_id,
	    p_name                    => C_Element_Rec.grade_name,
	    p_grade_step              => C_Element_Rec.grade_step,
	    p_sequence_number         => C_Element_Rec.sequence_number,
	    p_last_upDATE_DATE        => l_last_update_date,
	    p_last_upDATEd_BY         => l_last_upDATEd_BY,
	    p_last_upDATE_login       => l_last_upDATE_login
	 );

	   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     RAISE FND_API.G_EXC_ERROR;
	   END IF;
	  END LOOP;
	 END IF;

	IF (l_option_dummy = 0) THEN
	   Select psb_pay_element_options_s.nextval
	     INTO l_pay_element_option_id
	     FROM dual;

	  PSB_PAY_ELEMENT_OPTIONS_PVT.INSERT_ROW
	  ( p_api_version             =>  1.0,
	    p_init_msg_lISt           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_pay_element_option_id   => l_pay_element_option_id,
	    p_pay_element_id          => l_pay_element_id,
	    p_name                    => C_Element_Rec.grade_name,
	    p_grade_step              => C_Element_Rec.grade_step,
	    p_sequence_number         => C_Element_Rec.sequence_number,
	    p_last_upDATE_DATE        => l_last_update_date,
	    p_last_upDATEd_BY         => l_last_upDATEd_BY,
	    p_last_upDATE_login       => l_last_upDATE_login,
	    p_created_BY              => l_created_BY,
	    p_creation_DATE           => l_creation_DATE
	   );

	  END IF;

	   PSB_PAY_ELEMENT_RATES_PVT.ModIFy_Element_Rates
	  ( p_api_version             =>  1.0,
	    p_init_msg_lISt           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_pay_element_id          => l_pay_element_id,
	    p_pay_element_option_id   => l_pay_element_option_id,
	    p_effective_start_DATE    => C_Element_Rec.effective_start_DATE,
	    p_effective_END_DATE      => NULL,
	    p_worksheet_id            => NULL,
	    p_element_value_type      => 'A',
	    p_element_value           => C_Element_Rec.element_value,
	    p_pay_basIS               => C_Element_Rec.pay_basIS,
	    p_FORmula_id              => NULL,
	    p_maximum_value           => C_Element_Rec.maximum_value,
	    p_mid_value               => C_Element_Rec.mid_value,
	    p_minimum_value           => C_Element_Rec.minimum_value,
	    p_currency_code           => l_currency_code
	  );

	   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     RAISE FND_API.G_EXC_ERROR;
	   END IF;
	END LOOP;
       END IF;

	IF ((p_extract_method = 'CREATE') or (l_dummy = 0)) THEN
	  IF ((C_Element_Rec.rate_or_payscale_id <> prev_rate_or_payscale_id)
	      or (C_Element_Rec.salary_type <> prev_salary_type)
	      or (prev_salary_type = 'X')
	      or (prev_rate_or_payscale_id = -1)) THEN

	   Select psb_pay_elements_s.nextval
	     INTO l_pay_element_id
	     FROM dual;

	  PSB_PAY_ELEMENTS_PVT.INSERT_ROW
	  ( p_api_version             =>  1.0,
	    p_init_msg_lISt           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_row_id                  => l_rowid,
	    p_pay_element_id          => l_pay_element_id,
	    p_business_group_id       => p_business_group_id,
	    p_data_extract_id         => p_data_extract_id,
	    p_name                    => C_Element_Rec.rate_or_payscale_name,
	    p_description             => NULL,
	    p_element_value_type      => 'A',
	    p_FORmula_id              => NULL,
	    p_overwrite_flag          => NULL,
	    p_required_flag           => NULL,
	    p_follow_salary           => NULL,
	    p_pay_basIS               => C_Element_Rec.pay_basIS,
	    p_start_DATE              => C_Element_Rec.effective_start_DATE,
	    p_END_DATE                => C_Element_Rec.effective_END_DATE,
	    p_processing_type         => 'R',
	    p_period_type             => NULL,
	    p_process_period_type     => NULL,
	    p_max_element_value_type  => NULL,
	    p_max_element_value       => NULL,
	    p_salary_flag             => 'Y',
	    p_salary_type             => C_Element_Rec.salary_type,
	    p_option_flag             => 'Y',
	    p_hr_element_type_id      => C_Element_Rec.element_type_id,
	    p_attribute_category      => NULL,
	    p_attribute1              => NULL,
	    p_attribute2              => NULL,
	    p_attribute3              => NULL,
	    p_attribute4              => NULL,
	    p_attribute5              => NULL,
	    p_attribute6              => NULL,
	    p_attribute7              => NULL,
	    p_attribute8              => NULL,
	    p_attribute9              => NULL,
	    p_attribute10             => NULL,
	    p_last_upDATE_DATE        => l_last_update_date,
	    p_last_upDATEd_BY         => l_last_upDATEd_BY,
	    p_last_upDATE_login       => l_last_upDATE_login,
	    p_created_BY              => l_created_BY,
	    p_creation_DATE           => l_creation_DATE
	  );

	   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     RAISE FND_API.G_EXC_ERROR;
	   END IF;
	  END IF;

	   Select psb_pay_element_options_s.nextval
	     INTO l_pay_element_option_id
	     FROM dual;

	  PSB_PAY_ELEMENT_OPTIONS_PVT.INSERT_ROW
	  ( p_api_version             =>  1.0,
	    p_init_msg_lISt           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_pay_element_option_id   => l_pay_element_option_id,
	    p_pay_element_id          => l_pay_element_id,
	    p_name                    => C_Element_Rec.grade_name,
	    p_grade_step              => C_Element_Rec.grade_step,
	    p_sequence_number         => C_Element_Rec.sequence_number,
	    p_last_upDATE_DATE        => l_last_update_date,
	    p_last_upDATEd_BY         => l_last_upDATEd_BY,
	    p_last_upDATE_login       => l_last_upDATE_login,
	    p_created_BY              => l_created_BY,
	    p_creation_DATE           => l_creation_DATE
	 );

	   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     RAISE FND_API.G_EXC_ERROR;
	   END IF;


	   Select psb_pay_element_rates_s.nextval
	     INTO l_pay_element_rate_id
	     FROM dual;

	  PSB_PAY_ELEMENT_RATES_PVT.INSERT_ROW
	  ( p_api_version             =>  1.0,
	    p_init_msg_lISt           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_pay_element_rate_id     => l_pay_element_rate_id,
	    p_pay_element_option_id   => l_pay_element_option_id,
	    p_pay_element_id          => l_pay_element_id,
	    p_effective_start_DATE    => C_Element_Rec.effective_start_DATE,
	    p_effective_END_DATE      => C_Element_Rec.effective_END_DATE,
	    p_worksheet_id            => NULL,
	    p_element_value_type      => 'A',
	    p_element_value           => C_Element_Rec.element_value,
	    p_pay_basIS               => C_Element_Rec.pay_basIS,
	    p_FORmula_id              => NULL,
	    p_maximum_value           => C_Element_Rec.maximum_value,
	    p_mid_value               => C_Element_Rec.mid_value,
	    p_minimum_value           => C_Element_Rec.minimum_value,
	    p_currency_code           => l_currency_code,
	    p_last_upDATE_DATE        => l_last_update_date,
	    p_last_upDATEd_BY         => l_last_upDATEd_BY,
	    p_last_upDATE_login       => l_last_upDATE_login,
	    p_created_BY              => l_created_BY,
	    p_creation_DATE           => l_creation_DATE
	   ) ;

	   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	     RAISE FND_API.G_EXC_ERROR;
	   END IF;
       END IF;

     prev_rate_or_payscale_id := C_Element_Rec.rate_or_payscale_id;
     prev_salary_type := C_Element_Rec.salary_type;
     END LOOP;

     PSB_HR_EXTRACT_DATA_PVT.Update_Reentry
     ( p_api_version              => 1.0  ,
       p_return_status            => l_return_status,
       p_msg_count                => l_msg_count,
       p_msg_data                 => l_msg_data,
       p_data_extract_id          => p_data_extract_id,
       p_extract_method           => p_extract_method,
       p_process                  => 'PSB Elements',
       p_restart_id               => prev_rate_or_payscale_id
     );

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       raise FND_API.G_EXC_ERROR;
    end if;

    PSB_HR_EXTRACT_DATA_PVT.Reentrant_Process
    ( p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_msg_count                => l_msg_count,
      p_msg_data                 => l_msg_data,
      p_data_extract_id          => p_data_extract_id,
      p_extract_method           => p_extract_method,
      p_process                  => 'PSB Elements'
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

   commit work;
   END IF;
    -- END of API body.

  EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK to Populate_Element;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);
     FND_MESSAGE.SET_NAME('PSB', 'PSB_SALARY_DETAILS');
     FND_MESSAGE.SET_TOKEN('SALARY_TYPE',lm_salary_type );
     FND_MESSAGE.SET_TOKEN('RATE_OR_PAYSCALE_NAME',lm_rate_or_payscale_name );
     FND_MESSAGE.SET_TOKEN('GRADE_NAME',lm_grade_name );
     FND_MESSAGE.SET_TOKEN('GRADE_STEP',lm_grade_step );
     FND_MESSAGE.SET_TOKEN('GRADE_SEQUENCE',lm_sequence_number);
     FND_MSG_PUB.Add;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK to Populate_Element;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);
     FND_MESSAGE.SET_NAME('PSB', 'PSB_SALARY_DETAILS');
     FND_MESSAGE.SET_TOKEN('SALARY_TYPE',lm_salary_type );
     FND_MESSAGE.SET_TOKEN('RATE_OR_PAYSCALE_NAME',lm_rate_or_payscale_name );
     FND_MESSAGE.SET_TOKEN('GRADE_NAME',lm_grade_name );
     FND_MESSAGE.SET_TOKEN('GRADE_STEP',lm_grade_step );
     FND_MESSAGE.SET_TOKEN('GRADE_SEQUENCE',lm_sequence_number);
     FND_MSG_PUB.Add;

   WHEN OTHERS THEN
     ROLLBACK to Populate_Element;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);

     FND_MESSAGE.SET_NAME('PSB', 'PSB_SALARY_DETAILS');
     FND_MESSAGE.SET_TOKEN('SALARY_TYPE',lm_salary_type );
     FND_MESSAGE.SET_TOKEN('RATE_OR_PAYSCALE_NAME',lm_rate_or_payscale_name );
     FND_MESSAGE.SET_TOKEN('GRADE_NAME',lm_grade_name );
     FND_MESSAGE.SET_TOKEN('GRADE_STEP',lm_grade_step );
     FND_MESSAGE.SET_TOKEN('GRADE_SEQUENCE',lm_sequence_number);
     FND_MSG_PUB.Add;

     IF FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
    END IF;

END Populate_Element_Information;

/* ----------------------------------------------------------------------- */

FUNCTION check_vacancy(p_position_id in NUMBER,
		       p_data_extract_id in NUMBER)
	 RETURN VARCHAR2 AS

 lcount number := 0;
 vacancy_flag  varchar2(1) := 'N';

BEGIN
  Select count(*) INTO lcount
    FROM psb_employees_i
   WHERE hr_position_id = p_position_id
     AND data_extract_id = p_data_extract_id;

 IF (lcount >= 1) THEN
    vacancy_flag := 'N';
 else
    vacancy_flag := 'Y';
 END IF;

 return  vacancy_flag;

END;

/* ----------------------------------------------------------------------- */

PROCEDURE Populate_Attribute_Values
( p_api_version         IN      NUMBER,
  p_init_msg_lISt       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  p_extract_method      IN      VARCHAR2,
  p_business_group_id   IN      NUMBER
) AS

  l_last_update_date    DATE;
  l_last_upDATEd_BY     number;
  l_last_upDATE_login   number;
  l_creation_DATE       DATE;
  l_created_BY          number;
  l_dummy               number;
  l_rowid               varchar2(100);
  l_return_status       varchar2(1);
  l_msg_count           number;
  l_msg_data            varchar2(2000);
  l_status              varchar2(1);
  lr_attribute_id       number;
  --UTF8 changes for Bug No : 2615261
  lr_attribute_value    psb_attribute_values.attribute_value%TYPE;
  l_attr_dummy          number := 1;
  l_attribute_name      varchar2(30);
  --UTF8 changes for Bug No : 2615261
  l_attribute_value     psb_attribute_values.attribute_value%TYPE;
  l_attribute_value_id  NUMBER;
  l_restart_attribute_value_id number := 0;
  l_fin_attribute_value_id number := 0;
  l_attr_val_ctr         number := 0;

  l_api_name            CONSTANT VARCHAR2(30)   := 'Populate_Attribute_Values';
  l_api_version         CONSTANT NUMBER         := 1.0;

  Cursor C_Attrval IS
    Select b.attribute_value_id,b.attribute_id,
	   a.name, b.attribute_value,b.description,b.value_id
      FROM psb_attribute_values_i b, psb_attributes_vl a
     WHERE data_extract_id = p_data_extract_id
       AND b.attribute_id  = a.attribute_id
       AND b.attribute_value_id > l_restart_attribute_value_id
     order by b.attribute_value_id;

  Cursor C_ref_attr IS
    Select attribute_value_id
      FROM psb_attribute_values
     WHERE attribute_id = lr_attribute_id
       AND attribute_value = lr_attribute_value
       AND data_extract_id = p_data_extract_id;

BEGIN

    Savepoint Populate_Attributes;

    l_last_update_date := sysDATE;
    l_last_upDATEd_BY := FND_GLOBAL.USER_ID;
    l_last_upDATE_login :=FND_GLOBAL.LOGIN_ID;
    l_creation_DATE     := sysDATE;
    l_created_BY        := FND_GLOBAL.USER_ID;


    IF NOT FND_API.Compatible_API_Call (l_api_version,
					p_api_version,
					l_api_name,
					G_PKG_NAME)
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message lISt IF p_init_msg_lISt IS set to TRUE.

    IF FND_API.to_Boolean (p_init_msg_lISt) THEN
       FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body
    PSB_HR_EXTRACT_DATA_PVT.Check_Reentry
    (p_api_version              => 1.0  ,
     p_return_status            => l_return_status,
     p_msg_count                => l_msg_count,
     p_msg_data                 => l_msg_data,
     p_data_extract_id          => p_data_extract_id,
     p_process                  => 'PSB Attribute Values',
     p_status                   => l_status,
     p_restart_id               => l_restart_attribute_value_id
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_status = 'I') THEN

    FOR C_Attribute_Rec in C_Attrval
    LOOP
      l_attribute_name     := NULL;
      l_attribute_value    := NULL;
      l_attribute_name     := C_Attribute_Rec.name;
      l_attribute_value    := C_Attribute_Rec.attribute_value;
      l_fin_attribute_value_id := C_Attribute_Rec.attribute_value_id;
      l_attr_val_ctr       := l_attr_val_ctr + 1;

      IF (p_extract_method = 'REFRESH') THEN
	 l_attr_dummy       := 0;
	 lr_attribute_id    := C_Attribute_Rec.attribute_id;
	 lr_attribute_value := C_Attribute_Rec.attribute_value;

	 FOR C_ref_attr_rec in C_ref_attr
	 LOOP
	  l_attr_dummy := 1;
	  PSB_ATTRIBUTE_VALUES_PVT.UPDATE_ROW
	  ( p_api_version             =>  1.0,
	    p_init_msg_lISt           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_attribute_value_id      => C_ref_attr_rec.attribute_value_id,
	    p_attribute_id            => C_Attribute_Rec.attribute_id,
	    p_attribute_value         => C_Attribute_Rec.attribute_value,
	    p_hr_value_id             => C_Attribute_Rec.value_id,
	    p_description             => C_Attribute_Rec.description,
	    p_data_extract_id         => p_data_extract_id,
	    p_context                 => NULL,
	    p_attribute1              => NULL,
	    p_attribute2              => NULL,
	    p_attribute3              => NULL,
	    p_attribute4              => NULL,
	    p_attribute5              => NULL,
	    p_attribute6              => NULL,
	    p_attribute7              => NULL,
	    p_attribute8              => NULL,
	    p_attribute9              => NULL,
	    p_attribute10             => NULL,
	    p_attribute11             => NULL,
	    p_attribute12             => NULL,
	    p_attribute13             => NULL,
	    p_attribute14             => NULL,
	    p_attribute15             => NULL,
	    p_attribute16             => NULL,
	    p_attribute17             => NULL,
	    p_attribute18             => NULL,
	    p_attribute19             => NULL,
	    p_attribute20             => NULL,
	    p_attribute21             => NULL,
	    p_attribute22             => NULL,
	    p_attribute23             => NULL,
	    p_attribute24             => NULL,
	    p_attribute25             => NULL,
	    p_attribute26             => NULL,
	    p_attribute27             => NULL,
	    p_attribute28             => NULL,
	    p_attribute29             => NULL,
	    p_attribute30             => NULL,
	    p_last_upDATE_DATE        => l_last_update_date,
	    p_last_upDATEd_BY         => l_last_upDATEd_BY,
	    p_last_upDATE_login       => l_last_upDATE_login
	  );
	 END LOOP;
      END IF;

      IF ((p_extract_method = 'CREATE') or (l_attr_dummy = 0)) THEN

	 /* The following code(check for the attribute_value and update_row if
	    it exists else use insert_row. Insert_row was already existing)
	    has been added to fix the unique
	    constraint violation error as mentioned in bug 1735018.
	    Fixed by Siva Annamalai on 30 Apr 2001 */

	 l_attribute_value_id := NULL;
	 lr_attribute_id    := C_Attribute_Rec.attribute_id;
	 lr_attribute_value := C_Attribute_Rec.attribute_value;

	 FOR C_ref_attr_rec in C_ref_attr
	 LOOP
	    l_attribute_value_id := c_ref_attr_rec.attribute_value_id;
	 END LOOP;

	 IF l_attribute_value_id IS NOT NULL THEN
	   PSB_ATTRIBUTE_VALUES_PVT.UPDATE_ROW
	   ( p_api_version             =>  1.0,
	    p_init_msg_lISt           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_attribute_value_id      => l_attribute_value_id,
	    p_attribute_id            => C_Attribute_Rec.attribute_id,
	    p_attribute_value         => C_Attribute_Rec.attribute_value,
	    p_hr_value_id             => C_Attribute_Rec.value_id,
	    p_description             => C_Attribute_Rec.description,
	    p_data_extract_id         => p_data_extract_id,
	    p_context                 => NULL,
	    p_attribute1              => NULL,
	    p_attribute2              => NULL,
	    p_attribute3              => NULL,
	    p_attribute4              => NULL,
	    p_attribute5              => NULL,
	    p_attribute6              => NULL,
	    p_attribute7              => NULL,
	    p_attribute8              => NULL,
	    p_attribute9              => NULL,
	    p_attribute10             => NULL,
	    p_attribute11             => NULL,
	    p_attribute12             => NULL,
	    p_attribute13             => NULL,
	    p_attribute14             => NULL,
	    p_attribute15             => NULL,
	    p_attribute16             => NULL,
	    p_attribute17             => NULL,
	    p_attribute18             => NULL,
	    p_attribute19             => NULL,
	    p_attribute20             => NULL,
	    p_attribute21             => NULL,
	    p_attribute22             => NULL,
	    p_attribute23             => NULL,
	    p_attribute24             => NULL,
	    p_attribute25             => NULL,
	    p_attribute26             => NULL,
	    p_attribute27             => NULL,
	    p_attribute28             => NULL,
	    p_attribute29             => NULL,
	    p_attribute30             => NULL,
	    p_last_upDATE_DATE        => l_last_update_date,
	    p_last_upDATEd_BY         => l_last_upDATEd_BY,
	    p_last_upDATE_login       => l_last_upDATE_login
	  );

	  ELSE

	   PSB_ATTRIBUTE_VALUES_PVT.INSERT_ROW
	   ( p_api_version             =>  1.0,
	    p_init_msg_lISt           => NULL,
	    p_commit                  => NULL,
	    p_validation_level        => NULL,
	    p_return_status           => l_return_status,
	    p_msg_count               => l_msg_count,
	    p_msg_data                => l_msg_data,
	    p_rowid                   => l_rowid,
	    p_attribute_value_id      => C_Attribute_Rec.attribute_value_id,
	    p_attribute_id            => C_Attribute_Rec.attribute_id,
	    p_attribute_value         => C_Attribute_Rec.attribute_value,
	    p_hr_value_id             => C_Attribute_Rec.value_id,
	    p_description             => C_Attribute_Rec.description,
	    p_data_extract_id         => p_data_extract_id,
	    p_context                 => NULL,
	    p_attribute1              => NULL,
	    p_attribute2              => NULL,
	    p_attribute3              => NULL,
	    p_attribute4              => NULL,
	    p_attribute5              => NULL,
	    p_attribute6              => NULL,
	    p_attribute7              => NULL,
	    p_attribute8              => NULL,
	    p_attribute9              => NULL,
	    p_attribute10             => NULL,
	    p_attribute11             => NULL,
	    p_attribute12             => NULL,
	    p_attribute13             => NULL,
	    p_attribute14             => NULL,
	    p_attribute15             => NULL,
	    p_attribute16             => NULL,
	    p_attribute17             => NULL,
	    p_attribute18             => NULL,
	    p_attribute19             => NULL,
	    p_attribute20             => NULL,
	    p_attribute21             => NULL,
	    p_attribute22             => NULL,
	    p_attribute23             => NULL,
	    p_attribute24             => NULL,
	    p_attribute25             => NULL,
	    p_attribute26             => NULL,
	    p_attribute27             => NULL,
	    p_attribute28             => NULL,
	    p_attribute29             => NULL,
	    p_attribute30             => NULL,
	    p_last_upDATE_DATE        => l_last_update_date,
	    p_last_upDATEd_BY         => l_last_upDATEd_BY,
	    p_last_upDATE_login       => l_last_upDATE_login,
	    p_created_BY              => l_created_BY,
	    p_creation_DATE           => l_creation_DATE
	   ) ;
	END IF;

      END IF;

      if l_attr_val_ctr = PSB_WS_ACCT1.g_checkpoint_save then
      PSB_HR_EXTRACT_DATA_PVT.Update_Reentry
      ( p_api_version              => 1.0  ,
	p_return_status            => l_return_status,
	p_msg_count                => l_msg_count,
	p_msg_data                 => l_msg_data,
	p_data_extract_id          => p_data_extract_id,
	p_extract_method           => p_extract_method,
	p_process                  => 'PSB Attribute Values',
	p_restart_id               => C_Attribute_Rec.attribute_value_id
      );

      if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 raise FND_API.G_EXC_ERROR;
      end if;
      commit work;
      Savepoint Populate_Attributes;
      l_attr_val_ctr := 0;
      end if;

    END LOOP;

    PSB_HR_EXTRACT_DATA_PVT.Update_Reentry
    ( p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_msg_count                => l_msg_count,
      p_msg_data                 => l_msg_data,
      p_data_extract_id          => p_data_extract_id,
      p_extract_method           => p_extract_method,
      p_process                  => 'PSB Attribute Values',
      p_restart_id               => l_fin_attribute_value_id
    );

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       raise FND_API.G_EXC_ERROR;
    end if;

    PSB_HR_EXTRACT_DATA_PVT.Reentrant_Process
    ( p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_msg_count                => l_msg_count,
      p_msg_data                 => l_msg_data,
      p_data_extract_id          => p_data_extract_id,
      p_extract_method           => p_extract_method,
      p_process                  => 'PSB Attribute Values'
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    commit work;

    END IF;
   -- END of API body.

  EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK to Populate_Attributes;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);
     FND_MESSAGE.SET_NAME('PSB','PSB_ATTRIBUTE_NAME');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME',l_attribute_name);
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE_VALUE',l_attribute_value);
     FND_MSG_PUB.Add;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK to Populate_Attributes;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);
     FND_MESSAGE.SET_NAME('PSB','PSB_ATTRIBUTE_NAME');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME',l_attribute_name);
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE_VALUE',l_attribute_value);
     FND_MSG_PUB.Add;

   WHEN OTHERS THEN
     ROLLBACK to Populate_Attributes;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);

     FND_MESSAGE.SET_NAME('PSB','PSB_ATTRIBUTE_NAME');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME',l_attribute_name);
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE_VALUE',l_attribute_value);
     FND_MSG_PUB.Add;

     IF FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
    END IF;

END Populate_Attribute_Values;

/* ----------------------------------------------------------------------- */

PROCEDURE Populate_Costing_Information
( p_api_version         IN      NUMBER,
  p_init_msg_lISt       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  -- de by org
  p_extract_by_org      IN      VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_business_group_id   IN      NUMBER
) AS

 l_return_status  varchar2(1);
 l_msg_count      number;
 l_msg_data       varchar2(1000);
 l_status         varchar2(1);
 l_restart_position_id number := 0;
 l_api_name       CONSTANT VARCHAR2(30) := 'Populate_Costing';
 l_api_version    CONSTANT NUMBER       := 1.0;

Begin

  Savepoint Populate_Costing;

  IF NOT FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message lISt IF p_init_msg_lISt IS set to TRUE.

  IF FND_API.to_Boolean (p_init_msg_lISt) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  PSB_HR_EXTRACT_DATA_PVT.Check_Reentry
  (  p_api_version              => 1.0  ,
     p_return_status            => l_return_status,
     p_msg_count                => l_msg_count,
     p_msg_data                 => l_msg_data,
     p_data_extract_id          => p_data_extract_id,
     p_process                  => 'PSB Costing',
     p_status                   => l_status,
     p_restart_id               => l_restart_position_id
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (l_status = 'I') THEN
    --
    Create_Salary_Distributions
    (
      p_return_status   => l_return_status,
      p_data_extract_id => p_data_extract_id,
      p_extract_method  => p_extract_method,
      p_restart_position_id => l_restart_position_id,
      -- de by org
      p_extract_by_org  => p_extract_by_org
    );

    IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
      --
      PSB_HR_EXTRACT_DATA_PVT.Reentrant_Process
      ( p_api_version              => 1.0  ,
	p_return_status            => l_return_status,
	p_msg_count                => l_msg_count,
	p_msg_data                 => l_msg_data,
	p_data_extract_id          => p_data_extract_id,
	p_extract_method           => p_extract_method,
	p_process                  => 'PSB Costing'
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
    else
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    commit work;
  END IF;

  EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK to Populate_Costing;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK to Populate_Costing;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);

   WHEN OTHERS THEN
     ROLLBACK to Populate_Costing;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);

     IF FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
    END IF;

END Populate_Costing_Information;

/* ----------------------------------------------------------------------- */

PROCEDURE Populate_Pos_Assignments
( p_api_version         IN      NUMBER,
  p_init_msg_lISt       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  -- de by org
  p_extract_by_org      IN      VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_business_group_id   IN      NUMBER,
  p_set_of_books_id     IN      NUMBER
) AS

  l_last_update_date    DATE;
  l_last_upDATEd_BY     number;
  l_last_upDATE_login   number;
  l_creation_DATE       DATE;
  l_created_BY          number;
  l_dummy               number;
  l_rowid               varchar2(100);
  l_return_status       varchar2(1);
  l_msg_count           number;
  l_msg_data            varchar2(2000);
  l_position_assignment_id number;
  lp_attribute_name     varchar2(30);
  --UTF8 changes for Bug No : 2615261
  lp_attribute_value    psb_attribute_values.attribute_value%TYPE;
  lp_position_id        number;
  l_attribute_id        number;
  l_attribute_value_id  number;
  --UTF8 changes for Bug No : 2615261
  l_attribute_value     psb_attribute_values.attribute_value%TYPE;
  lr_attribute_id       number;
  lr_attribute_value_id number;
  --UTF8 changes for Bug No : 2615261
  lr_attribute_value    psb_attribute_values.attribute_value%TYPE;
  lr_position_id        number;
  lm_position_assignment_id number;
  lr_max_dummy          number := 0;
  lp_max_flag           varchar2(1);
  l_value_table_flag    varchar2(1);
  l_currency_code       varchar2(30);
  l_definition_type     varchar2(30);
  l_status              varchar2(1);
  l_position_name       varchar2(240);
  --UTF8 changes for Bug No : 2615261
  l_employee_name       varchar2(310);
  l_pos_assign_ctr      number := 0;
  lp_hr_position_id     number := 0;
  l_fin_hr_position_id  number := 0;
  l_restart_hr_position_id number := 0;
  prev_hr_position_id   number := -1;
  -- de by org
  l_extract_method      varchar2(30);

  l_debug VARCHAR2(1) := 'N';

  l_api_name    CONSTANT VARCHAR2(30)   := 'Populate_Position_Assignment';
  l_api_version CONSTANT NUMBER         := 1.0;

  Cursor C_currency IS
    Select currency_code
      FROM gl_sets_of_books
     WHERE set_of_books_id = p_set_of_books_id;

  Cursor C_pos_values IS
    Select attribute_value_id
      FROM psb_attribute_values
     WHERE attribute_id = l_attribute_id
       AND decode(l_definition_type, 'DFF',hr_value_id,
		  attribute_value) = lp_attribute_value
       AND data_extract_id  = p_data_extract_id;

BEGIN

  Savepoint Populate_Position_Assignments;

  l_last_update_date  := sysDATE;
  l_last_upDATEd_BY   := FND_GLOBAL.USER_ID;
  l_last_upDATE_login := FND_GLOBAL.LOGIN_ID;
  l_creation_DATE     := sysDATE;
  l_created_BY        := FND_GLOBAL.USER_ID;

  /* start bug 4153562 */
  -- initialize the packaged varible with the extract method.
  PSB_HR_POPULATE_DATA_PVT.g_extract_method := p_extract_method;
  /* end bug 4153562 */

  IF NOT FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message lISt IF p_init_msg_lISt IS set to TRUE.

  IF FND_API.to_Boolean (p_init_msg_lISt) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  -- de by org
  --
  -- If extract_method is REFRESH do nothing.
  -- Else use the appropriate extract_method based on  the organization's
  -- extract status. cache_org_status caches statuses of all organizations.

  IF (p_extract_by_org = 'N' OR p_extract_method = 'REFRESH') THEN
        l_extract_method := p_extract_method;
    ELSE
        cache_org_status
         (l_return_status,
           p_data_extract_id,
           p_extract_by_org
         );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;


  PSB_HR_EXTRACT_DATA_PVT.Check_Reentry
  (  p_api_version              => 1.0  ,
     p_return_status            => l_return_status,
     p_msg_count                => l_msg_count,
     p_msg_data                 => l_msg_data,
     p_data_extract_id          => p_data_extract_id,
     p_process                  => 'PSB Position Assignments',
     p_status                   => l_status,
     p_restart_id               => l_restart_hr_position_id
  );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (l_status = 'I') THEN

    -- Retrieve currency inFORmation.
    FOR C_currency_rec in C_currency
    LOOP
      l_currency_code := C_currency_rec.currency_code;
    END LOOP;
    --
    -- Process all the employees FROM psb_employees along with their ATTRIBUTE
    -- assignment inFORmation FROM psb_employee_assignments_i
    --
    FOR C_Assignment_Rec in
    (
      /*For Bug No : 2109120 Start*/
      /*Select pe.employee_id,
	     pea.hr_position_id,
	     pea.hr_employee_id,
	     pea.attribute_name,
	     pea.attribute_value,
	     pea.effective_start_DATE,
	     pea.effective_END_DATE
	FROM psb_employee_assignments_i pea,
	     psb_employees              pe
       WHERE pea.data_extract_id   = p_data_extract_id
	 AND pe.hr_employee_id(+)  = pea.hr_employee_id
	 AND pe.data_extract_id(+) = p_data_extract_id
	 AND pea.hr_position_id    > l_restart_hr_position_id
       ORDER by pea.hr_position_id*/

      SELECT ppa.employee_id,
             -- de by org
             pp.organization_id,
	     pea.hr_position_id,
	     pea.hr_employee_id,
	     pea.attribute_name,
	     pea.attribute_value,
	     pea.effective_start_DATE,
	     pea.effective_END_DATE
	FROM psb_positions pp,
	     psb_position_assignments ppa,
	     psb_employee_assignments_i pea
       WHERE pp.data_extract_id = p_data_extract_id
	 AND pp.position_id = ppa.position_id
	 AND ppa.assignment_type = 'EMPLOYEE'
	 AND ppa.employee_id IS NOT NULL
	 AND pp.hr_position_id = pea.hr_position_id
	 AND pp.hr_employee_id = pea.hr_employee_id
	 AND pea.data_extract_id = p_data_extract_id
	 AND pea.hr_position_id    > l_restart_hr_position_id
   UNION ALL
      SELECT to_number(NULL),
             -- de by org
             pp.organization_id,
	     pea.hr_position_id,
             pea.hr_employee_id,
	     pea.attribute_name,
	     pea.attribute_value,
	     pea.effective_start_DATE,
	     pea.effective_END_DATE
      	FROM psb_employee_assignments_i pea,
             psb_positions pp
       WHERE pea.data_extract_id   = p_data_extract_id
         AND pea.hr_position_id = pp.hr_position_id
	 AND pea.hr_employee_id IS NULL
	 AND pp.hr_employee_id IS NULL
         AND pp.data_extract_id = p_data_extract_id
	 AND pea.hr_position_id    > l_restart_hr_position_id
       ORDER by 3
      /*For Bug No : 2109120 End*/
    )
    LOOP
      lp_hr_position_id  := C_Assignment_rec.hr_position_id;
      lp_attribute_name  := C_Assignment_Rec.attribute_name;
      lp_attribute_value := C_Assignment_Rec.attribute_value;

    -- de by org
    -- If extract method is not REFRESH, get the status of the organization
    -- to which the employee belongs from the already cached organization
    -- statuses.

      IF p_extract_method <> 'REFRESH' and p_extract_by_org = 'Y' THEN
         l_extract_method := g_org_status(c_assignment_rec.organization_id);
      END IF;

      if ((lp_hr_position_id <> prev_hr_position_id) and (prev_hr_position_id <> -1)) then
	 l_pos_assign_ctr   := l_pos_assign_ctr + 1;
	 if l_pos_assign_ctr = PSB_WS_ACCT1.g_checkpoint_save then
	    PSB_HR_EXTRACT_DATA_PVT.Update_Reentry
	    ( p_api_version              => 1.0  ,
	      p_return_status            => l_return_status,
	      p_msg_count                => l_msg_count,
	      p_msg_data                 => l_msg_data,
	      p_data_extract_id          => p_data_extract_id,
	      p_extract_method           => p_extract_method,
	      p_process                  => 'PSB Position Assignments',
	      p_restart_id               => C_Assignment_Rec.hr_position_id
	    );


	 if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    raise FND_API.G_EXC_ERROR;
	 end if;
	 commit work;
	 /*For Bug No : 2642012 Start*/
	 l_pos_assign_ctr := 0;
	 /*For Bug No : 2642012 End*/
	 Savepoint Populate_Position_Assignments;
       end if;
      end if;

      IF (c_Assignment_Rec.hr_employee_id IS NOT NULL) THEN
       FOR Emp_Name_Rec in G_Employee_Details(p_person_id => c_Assignment_Rec.hr_employee_id)
	LOOP
	  l_employee_name := Emp_Name_Rec.first_name||' '||Emp_Name_Rec.last_name;
	END LOOP;
      END IF;

      -- lp_max_flag determines whether a position_id exISts FOR the current
      -- C_Assignment_Rec.hr_employee_id.
      lp_max_flag := 'N';
      -- Find attribute inFORmation FROM psb_attributes_vl based on current
      -- attribute name.
      FOR C_pos_attr_rec in
      (
	Select attribute_id                                ,
	       nvl(value_table_flag ,'N') value_table_flag ,
	       definition_type
	  FROM psb_attributes_VL
	 WHERE business_group_id = p_business_group_id
	   AND name              = lp_attribute_name
      )
      LOOP
	l_attribute_id     := C_pos_attr_rec.attribute_id;
	l_value_table_flag := C_pos_attr_rec.value_table_flag;
	l_definition_type  := C_pos_attr_rec.definition_type;
      END LOOP;
      l_attribute_value_id := NULL;
      l_attribute_value    := NULL;

      IF (l_value_table_flag = 'Y') THEN

	-- Find the attribute_value_id based on the current attribute_name
	-- AND attribute_value FROM psb_attribute_values table.
	FOR C_pos_value_rec in C_pos_values
	LOOP
	  l_attribute_value_id := C_pos_value_rec.attribute_value_id;
	END LOOP;

	IF (l_attribute_value_id IS NULL) THEN
	  l_attribute_value := C_Assignment_rec.attribute_value;
	else
	  l_attribute_value := NULL;
	END IF;

      else

	l_attribute_value_id := NULL;
	l_attribute_value := C_Assignment_rec.attribute_value;

      END IF;  -- END IF ( l_value_table_flag = 'Y')
      -- Find the position_id to be upDATEd FOR.
      IF (C_Assignment_rec.hr_employee_id IS NULL) THEN

	-- As hr_employee_id IS NULL, retrieve position_id FROM psb_positions.
	FOR C_max_pos_rec in
	(
	  Select position_id
	    FROM psb_positions
	   WHERE data_extract_id = p_data_extract_id
	     AND hr_position_id  = C_Assignment_rec.hr_position_id
             AND hr_employee_id is null
	)
	LOOP
	  lp_position_id := C_max_pos_rec.position_id;
	  lp_max_flag := 'Y';
	END LOOP;

      else

       -- To handle  positions with non null hr_employee_id

	FOR C_max_rec in
	(
	  Select position_id
	    FROM psb_positions
	   WHERE data_extract_id = p_data_extract_id
	     AND hr_position_id  = C_Assignment_rec.hr_position_id
	     AND hr_employee_id     = C_Assignment_rec.hr_employee_id
	)
	LOOP
	  lp_position_id  := C_max_rec.position_id;
	  lp_max_flag := 'Y';
	END LOOP;

      END IF; -- Check IF (C_Assignment_rec.hr_employee_id IS NULL)

      -- debug('(lp_max_flag : ' || lp_max_flag );

      --
      -- We can only INSERT/upDATE position assignments WHEN we find a
      -- matching position_id corresponding to the current employee in the
      -- C_Assignment_rec rec. The lp_max_flag = 'Y' means we found a match.
      --
      IF (lp_position_id IS NOT NULL) THEN
       FOR Pos_Name_Rec in G_Position_Details(p_position_id => lp_position_id)
	LOOP
	  l_position_name := Pos_Name_Rec.name;
	END LOOP;
      END IF;
      IF (lp_max_flag = 'Y') THEN

      -- de by org
      --
      -- l_extract_method contains the organization's status. Hence using it
      -- in lieu of p_extract_method.

	IF (l_extract_method = 'REFRESH') THEN

	  lr_max_dummy := 0;
	  lr_position_id        := lp_position_id;
	  lr_attribute_value_id := l_attribute_value_id;
	  lr_attribute_value    := l_attribute_value;
	  lr_attribute_id       := l_attribute_id;

	  -- Find all the assignments as per the current position_id.
	  FOR C_ref_assign_rec in
	  (
	     Select position_assignment_id
	       FROM psb_position_assignments
	      WHERE data_extract_id = p_data_extract_id
		AND position_id     = lr_position_id
		AND attribute_id    = lr_attribute_id
		AND assignment_type = 'ATTRIBUTE'
	  )
	  LOOP
	    lr_max_dummy := 1;

	    PSB_POSITIONS_PVT.ModIFy_Assignment
	    (
	      p_api_version            => 1.0,
	      p_return_status          => l_return_status,
	      p_msg_count              => l_msg_count,
	      p_msg_data               => l_msg_data,
	      p_position_assignment_id => lm_position_assignment_id,
	      p_data_extract_id        => p_data_extract_id,
	      p_worksheet_id           => NULL,
	      p_position_id            => lr_position_id,
	      p_assignment_type        => 'ATTRIBUTE',
	      p_attribute_id           => lr_attribute_id,
	      p_attribute_value_id     => lr_attribute_value_id,
	      p_attribute_value        => lr_attribute_value,
	      p_pay_element_id         => NULL,
	      p_pay_element_option_id  => NULL,
	      p_effective_start_DATE   => C_Assignment_Rec.effective_start_DATE,
	      p_effective_END_DATE     => C_Assignment_Rec.effective_end_DATE,
	      p_element_value_type     => NULL,
	      p_element_value          => NULL,
	      p_currency_code          => NULL,
	      p_pay_basIS              => NULL,
	      p_global_default_flag    => NULL,
	      p_assignment_default_rule_id => NULL,
	      p_modIFy_flag            => NULL,
	      p_rowid                  => l_rowid,
	      p_employee_id            => NULL,
	      p_primary_employee_flag  => NULL
	    );

	    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      RAISE FND_API.G_EXC_ERROR;
	    END IF;

	  END LOOP;

	END IF; -- END creating 'ATTRIBUTE' type assignment in 'REFRESH' mode.
	IF (l_extract_method = 'CREATE' OR lr_max_dummy = 0 ) THEN
	  --
	  PSB_POSITION_ASSIGNMENTS_PVT.INSERT_ROW
	  (
	     p_api_version             => 1,
	     p_init_msg_lISt           => NULL,
	     p_commit                  => NULL,
	     p_validation_level        => NULL,
	     p_return_status           => l_return_status,
	     p_msg_count               => l_msg_count,
	     p_msg_data                => l_msg_data,
	     p_rowid                   => l_rowid,
	     p_position_assignment_id  => l_position_assignment_id,
	     p_data_extract_id         => p_data_extract_id,
	     p_worksheet_id            => NULL,
	     p_position_id             => lp_position_id,
	     p_assignment_type         => 'ATTRIBUTE',
	     p_attribute_id            => l_attribute_id,
	     p_attribute_value_id      => l_attribute_value_id,
	     p_attribute_value         => l_attribute_value,
	     p_pay_element_id          => NULL,
	     p_pay_element_option_id   => NULL,
	     p_effective_start_DATE    => C_Assignment_Rec.effective_start_DATE,
	     p_effective_END_DATE      => C_Assignment_Rec.effective_END_DATE,
	     p_element_value_type      => NULL,
	     p_element_value           => NULL,
	     p_currency_code           => NULL,
	     p_pay_basIS               => NULL,
	     p_employee_id             => NULL,
	     p_primary_employee_flag   => NULL,
	     p_global_default_flag     => NULL,
	     p_assignment_default_rule_id => NULL,
	     p_modIFy_flag             => NULL,
	     p_mode                    => 'R'
	  ) ;
	  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    RAISE FND_API.G_EXC_ERROR;
	  END IF;
	END IF; -- END creating 'ATTRIBUTE' type assignment in 'CREATE' mode.

      END IF; -- Check IF (lp_max_flag = 'Y').

      prev_hr_position_id := lp_hr_position_id;
    END LOOP; -- END processing all the employees thru C_Assignment_Rec.
   PSB_HR_EXTRACT_DATA_PVT.Update_Reentry
   ( p_api_version              => 1.0  ,
     p_return_status            => l_return_status,
     p_msg_count                => l_msg_count,
     p_msg_data                 => l_msg_data,
     p_data_extract_id          => p_data_extract_id,
     p_extract_method           => p_extract_method,
     p_process                  => 'PSB Position Assignments',
     p_restart_id               => lp_hr_position_id
   );

   if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
   end if;

    PSB_HR_EXTRACT_DATA_PVT.Reentrant_Process
    ( p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_msg_count                => l_msg_count,
      p_msg_data                 => l_msg_data,
      p_data_extract_id          => p_data_extract_id,
      p_extract_method           => p_extract_method,
      p_process                  => 'PSB Position Assignments'
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

   /* start bug 4153562 */
   -- re-initialize the packaged variable back to null
   -- at the end of the populate_position_assignment API.
   PSB_HR_POPULATE_DATA_PVT.g_extract_method := null;
   /* end bug 4153562 */

    commit work;
  END IF;
  -- END of API body.
  EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK to Populate_Position_Assignments;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);
     FND_MESSAGE.SET_NAME('PSB', 'PSB_POSITION_DETAILS');
     FND_MESSAGE.SET_TOKEN('POSITION_NAME',l_position_name );
     FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME',l_employee_name );
     FND_MSG_PUB.Add;
     FND_MESSAGE.SET_NAME('PSB','PSB_ATTRIBUTE_NAME');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME',lp_attribute_name);
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE_VALUE',lp_attribute_value);
     FND_MSG_PUB.Add;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK to Populate_Position_Assignments;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);
     FND_MESSAGE.SET_NAME('PSB', 'PSB_POSITION_DETAILS');
     FND_MESSAGE.SET_TOKEN('POSITION_NAME',l_position_name );
     FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME',l_employee_name );
     FND_MSG_PUB.Add;
     FND_MESSAGE.SET_NAME('PSB','PSB_ATTRIBUTE_NAME');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME',lp_attribute_name);
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE_VALUE',lp_attribute_value);
     FND_MSG_PUB.Add;

   WHEN OTHERS THEN
     ROLLBACK to Populate_Position_Assignments;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);
     FND_MESSAGE.SET_NAME('PSB', 'PSB_POSITION_DETAILS');
     FND_MESSAGE.SET_TOKEN('POSITION_NAME',l_position_name );
     FND_MESSAGE.SET_TOKEN('EMPLOYEE_NAME',l_employee_name );
     FND_MSG_PUB.Add;
     FND_MESSAGE.SET_NAME('PSB','PSB_ATTRIBUTE_NAME');
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE_NAME',lp_attribute_name);
     FND_MESSAGE.SET_TOKEN('ATTRIBUTE_VALUE',lp_attribute_value);
     FND_MSG_PUB.Add;

     IF FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
    END IF;

END Populate_Pos_Assignments;

/* ----------------------------------------------------------------------- */

/* Bug 4649730 reverted back the changes done for MPA as
   the following api will be called only
   as part of Extract process */

PROCEDURE Apply_Defaults
( p_api_version         IN      NUMBER,
  p_init_msg_lISt       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  p_extract_method      IN      VARCHAR2
) AS

  l_last_update_date    DATE;
  l_last_upDATEd_BY     number;
  l_last_upDATE_login   number;
  l_creation_DATE       DATE;
  l_created_BY          number;
  l_status              varchar2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(1000);
  l_return_status       varchar2(1);
  l_restart_id          NUMBER := 0;

  l_api_name            CONSTANT VARCHAR2(30) := 'Apply_Defaults';
  l_api_version         CONSTANT NUMBER      := 1.0;

Begin

    -- StANDard Start of API savepoint

    Savepoint Apply_Defaults;

    l_last_upDATE_DATE := sysDATE;
    l_last_upDATEd_BY := FND_GLOBAL.USER_ID;
    l_last_upDATE_login :=FND_GLOBAL.LOGIN_ID;
    l_creation_DATE     := sysDATE;
    l_created_BY        := FND_GLOBAL.USER_ID;

    -- StANDard call to check FOR call compatibility.

    IF NOT FND_API.Compatible_API_Call (l_api_version,
					p_api_version,
					l_api_name,
					G_PKG_NAME)
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message lISt IF p_init_msg_lISt IS set to TRUE.

    IF FND_API.to_Boolean (p_init_msg_lISt) THEN
       FND_MSG_PUB.initialize;
    END IF;

    p_return_status := FND_API.G_RET_STS_SUCCESS;
    -- API body

    PSB_HR_EXTRACT_DATA_PVT.Check_Reentry
    (p_api_version              => 1.0  ,
     p_return_status            => l_return_status,
     p_msg_count                => l_msg_count,
     p_msg_data                 => l_msg_data,
     p_data_extract_id          => p_data_extract_id,
     p_process                  => 'PSB Apply Defaults',
     p_status                   => l_status,
     p_restart_id               => l_restart_id
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_status = 'I') THEN


       PSB_POSITIONS_PVT.Create_Default_Assignments
       ( p_api_version              =>  1.0,
	 p_commit                   =>  FND_API.G_FALSE,
	 p_validation_level         =>  FND_API.G_VALID_LEVEL_FULL,
	 p_init_msg_lISt            =>  FND_API.G_FALSE,
	 p_return_status            =>  l_return_status,
	 p_msg_count                =>  l_msg_count,
	 p_msg_data                 =>  l_msg_data,
	 p_data_extract_id          =>  p_data_extract_id,
	 p_position_id              =>  FND_API.G_MISS_NUM,
	 p_position_start_DATE      =>  FND_API.G_MISS_DATE,
	 p_position_END_DATE        =>  FND_API.G_MISS_DATE,
         p_ruleset_id               =>  NULL  -- Bug 4649730
       );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	 RAISE FND_API.G_EXC_ERROR;
      END IF;

    PSB_HR_EXTRACT_DATA_PVT.Reentrant_Process
    ( p_api_version              => 1.0  ,
      p_return_status            => l_return_status,
      p_msg_count                => l_msg_count,
      p_msg_data                 => l_msg_data,
      p_data_extract_id          => p_data_extract_id,
      p_extract_method           => p_extract_method,
      p_process                  => 'PSB Apply Defaults'
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    UpDATE PSB_DATA_EXTRACTS
       set default_data_status  = 'C'
       WHERE data_extract_id = p_data_extract_id;

    commit work;
    END IF;

   -- END of API body.

  EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK to Apply_Defaults;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK to Apply_Defaults;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);

   WHEN OTHERS THEN
     ROLLBACK to Apply_Defaults;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				 p_data  => p_msg_data);

     IF FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);
    END IF;

END Apply_Defaults;
/*---------------------------------------------------------------------------*/


/*---------------------------------------------------------------------------*/
-- Get Debug Information
FUNCTION get_debug RETURN VARCHAR2 AS
BEGIN
  RETURN(g_dbug);
END get_debug;
/*---------------------------------------------------------------------------*/


END PSB_HR_POPULATE_DATA_PVT;

/
