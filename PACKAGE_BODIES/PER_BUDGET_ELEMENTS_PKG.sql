--------------------------------------------------------
--  DDL for Package Body PER_BUDGET_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BUDGET_ELEMENTS_PKG" as
/* $Header: pebge01t.pkb 115.10 2004/02/16 10:19:58 nsanghal ship $ */

-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
g_package  varchar2(33) := '  per_budget_elements_pkg.';  -- Global package name

-- ----------------------------------------------------------------------------
-- |---------------------------< Chk_Unique >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Chk_Unique(X_Rowid                   VARCHAR2,
                     X_Budget_Version_Id       NUMBER,
                     X_Organization_Id         NUMBER,
                     X_Job_Id                  NUMBER,
                     X_Position_Id             NUMBER,
                     X_Grade_Id                NUMBER,
		     X_Training_Plan_Id        NUMBER,
		     X_Training_Plan_Member_Id NUMBER,
		     X_Event_Id                NUMBER) is

   l_result VARCHAR2(255);
   l_proc   VARCHAR2(72) := g_package||'Chk_Unique';

Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
SELECT  NULL
INTO l_result
FROM    PER_BUDGET_ELEMENTS E
WHERE   E.BUDGET_VERSION_ID = X_Budget_Version_Id
AND    (E.ROWID <> X_Rowid OR X_Rowid IS NULL)
AND     NVL(E.ORGANIZATION_ID,-1)         = NVL(X_Organization_Id,-1)
AND     NVL(E.JOB_ID,-1)                  = NVL(X_Job_Id,-1)
AND     NVL(E.POSITION_ID,-1)             = NVL(X_Position_Id,-1)
AND     NVL(E.GRADE_ID,-1)                = NVL(X_Grade_Id,-1)
AND     NVL(E.TRAINING_PLAN_ID,-1)        = NVL(X_Training_Plan_Id,-1)
AND     NVL(E.TRAINING_PLAN_MEMBER_ID,-1) = NVL(X_Training_Plan_Member_Id,-1)
AND     NVL(E.EVENT_ID,-1)                = NVL(X_Event_Id,-1);

  IF (SQL%FOUND) then
    hr_utility.set_message(801,'PER_7231_BUDGET_UNIQUE_COMB');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
EXCEPTION
  when NO_DATA_FOUND then
    null;

end Chk_Unique;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< Chk_Training_Plan_Id >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Chk_Training_Plan_Id(X_Training_Plan_Id IN NUMBER,
	                       X_Business_Group IN NUMBER) IS
   l_proc   VARCHAR2(72) := g_package||'Chk_Training_Plan_Id';
   l_status    varchar2(30);
   l_industry  varchar2(30);
   l_owner     varchar2(30);
   l_ret       boolean := FND_INSTALLATION.GET_APP_INFO ('OTA', l_status,
                                                      l_industry, l_owner);
   l_result VARCHAR2(255);

   l_stmt_chk_tpc_exist varchar2(32000) :=
     'select ''Y'' from all_tables where table_name = ''OTA_TRAINING_PLANS''
          and owner = '''||l_owner||'''';

   l_stmt_get_tpc_rows varchar2(32000) :=
     'select ''Y'' from OTA_TRAINING_PLANS where training_plan_id = ' --
      ||X_Training_Plan_Id ||' and Business_Group_Id = '||X_Business_Group;

   l_dyn_curs   integer;
   l_dyn_rows   integer;

--

BEGIN

  hr_utility.set_location(' Entering:'|| l_proc, 5);

  --
  l_dyn_curs := dbms_sql.open_cursor;
  --
  -- Determine if the OTA_TRAINING_PLANS table exists
  --
  dbms_sql.parse(l_dyn_curs,l_stmt_chk_tpc_exist,dbms_sql.v7);
  l_dyn_rows := dbms_sql.execute_and_fetch(l_dyn_curs);
  --
  if dbms_sql.last_row_count > 0
  then
     -- Check if the training plan is referenced in training plans table
     dbms_sql.parse(l_dyn_curs,l_stmt_get_tpc_rows,dbms_sql.v7);
     l_dyn_rows := dbms_sql.execute_and_fetch(l_dyn_curs);
     --
     if dbms_sql.last_row_count < 1 then
        dbms_sql.close_cursor(l_dyn_curs);
        hr_utility.set_message(800,'PER_52877_TPID_NOT_EXISTS');
        hr_utility.raise_error;
    end if;
  end if;
  if dbms_sql.is_open(l_dyn_curs) then
     dbms_sql.close_cursor(l_dyn_curs);
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
  --
END Chk_Training_Plan_Id;
--
--
-- ----------------------------------------------------------------------------
-- |----------------< Chk_Training_Plan_Member_Id>----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Chk_Training_Plan_Member_Id(X_Training_Plan_Id IN NUMBER,
                                      X_Training_Plan_Member_Id IN NUMBER,
				      X_Business_Group IN NUMBER) IS

   l_proc   VARCHAR2(72) := g_package||'Chk_Training_Plan_Member_Id';
   l_status    varchar2(30);
   l_industry  varchar2(30);
   l_owner     varchar2(30);
   l_ret       boolean := FND_INSTALLATION.GET_APP_INFO ('OTA', l_status,
                                                      l_industry, l_owner);

   l_result VARCHAR2(255);
   -- dynamic sql statments to check if the training plan member table exists
   --
   l_stmt_chk_tpc_exist varchar2(32000) := 'select ''Y'' from all_tables
          where table_name = ''OTA_TRAINING_PLAN_MEMBERS''
          and owner = '''||l_owner||'''';
   --
   -- dynamic sql statment to check if a row exists in training plan members
   --
   l_stmt_get_tpc_rows varchar2(32000) := 'select ''Y'' from OTA_TRAINING_PLAN_MEMBERS
     where training_plan_member_id = '||X_Training_Plan_Member_id
     ||' and training_plan_id = '||X_Training_Plan_Id
     ||' and business_group_id = '||X_Business_Group;

   --
   l_dyn_curs   integer;
   l_dyn_rows   integer;
   --
   --
   --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  l_dyn_curs := dbms_sql.open_cursor;
  --
  -- Determine if the OTA_TRAINING_PLAN_MEMBERS table exists
  --
  dbms_sql.parse(l_dyn_curs,l_stmt_chk_tpc_exist,dbms_sql.v7);
  l_dyn_rows := dbms_sql.execute_and_fetch(l_dyn_curs);
  --
  if dbms_sql.last_row_count > 0 then
    -- Check that the training plan member record exists
    dbms_sql.parse(l_dyn_curs,l_stmt_get_tpc_rows,dbms_sql.v7);
    l_dyn_rows := dbms_sql.execute_and_fetch(l_dyn_curs);
    --
    if dbms_sql.last_row_count < 1 then
      dbms_sql.close_cursor(l_dyn_curs);
      hr_utility.set_message(800,'PER_52878_TPMID_NOT_EXISTS');
      hr_utility.raise_error;
    end if;
  end if;
  if dbms_sql.is_open(l_dyn_curs) then
    dbms_sql.close_cursor(l_dyn_curs);
  end if;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 10);
  --
END Chk_Training_Plan_Member_Id;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< Chk_Event_Id >------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Chk_Event_Id(X_Event_Id IN NUMBER,
	               X_Business_Group IN NUMBER) IS
   l_result VARCHAR2(255);
   l_proc   VARCHAR2(72) := g_package||'Chk_Event_Id';
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  SELECT  NULL
  INTO l_result
  FROM OTA_EVENTS OE
  WHERE OE.Event_Id = X_Event_Id
  AND OE.Business_Group_Id = X_Business_Group;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
EXCEPTION
  when NO_DATA_FOUND then
    hr_utility.set_message(800,'PER_52879_EID_NOT_EXISTS');
    hr_utility.raise_error;

END Chk_Event_Id;

-- ----------------------------------------------------------------------------
-- |----------------------< chk_budget_element_id >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_budget_element_id(X_budget_element_id IN NUMBER,
		                X_rowid IN VARCHAR2) IS
   l_result VARCHAR2(255);
   l_proc   VARCHAR2(72) := g_package||'chk_budget_element_id';
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  SELECT NULL
  INTO l_result
  FROM per_budget_elements pge
  WHERE pge.budget_element_id = x_budget_element_id
  AND (pge.rowid <> X_rowid OR X_rowid IS NULL);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  IF SQL%FOUND THEN
    hr_utility.set_message(800,'PER_52880_BUD_ELE_EXISTS');
    hr_utility.raise_error;
  END IF;
--
EXCEPTION
  when NO_DATA_FOUND then
    null;
END chk_budget_element_id;

-- ----------------------------------------------------------------------------
-- |----------------------< chk_grade_id >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_grade_id(X_grade_id IN NUMBER,
		       X_Business_Group IN NUMBER) IS
   l_result VARCHAR2(255);
   l_proc   VARCHAR2(72) := g_package||'chk_grade_id';
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  SELECT  NULL
  INTO l_result
  FROM per_grades pg
  WHERE pg.grade_id = X_Grade_Id
  AND pg.business_group_id = X_Business_Group;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --

EXCEPTION
  when NO_DATA_FOUND then
    hr_utility.set_message(801,'HR_51082_GRADE_INVALID_BG');
    hr_utility.raise_error;
END chk_grade_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< chk_job_id >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_job_id(X_Job_Id IN NUMBER,
		     X_Business_Group IN NUMBER) IS

   l_result VARCHAR2(255);
   l_proc   VARCHAR2(72) := g_package||'chk_job_id';
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  SELECT  NULL
  INTO l_result
  FROM per_jobs_v job
  WHERE job.job_id = X_job_id
  AND job.Business_Group_Id = X_Business_Group;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --

EXCEPTION
  when NO_DATA_FOUND then
    hr_utility.set_message(801,'HR_51090_JOB_NOT_EXIST');
    hr_utility.raise_error;
END chk_job_id;

-- ----------------------------------------------------------------------------
-- |----------------------< chk_position_id >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_position_id(X_position_id IN NUMBER,
		          X_Business_Group IN NUMBER) IS
   l_result VARCHAR2(255);
   l_proc   VARCHAR2(72) := g_package||'Chk_position_id';

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  SELECT  NULL
  INTO l_result
  FROM per_positions pos
  WHERE pos.position_id = X_position_id
  AND pos.Business_Group_Id = X_Business_Group;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --

EXCEPTION
  when NO_DATA_FOUND then
    hr_utility.set_message(801,'HR_51093_POS_INVALID_BG');
    hr_utility.raise_error;

END chk_position_id;

-- ----------------------------------------------------------------------------
-- |----------------------< chk_organization_id >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_organization_id(X_organization_id IN NUMBER,
		              X_Business_Group IN NUMBER,
			      X_Budget_Version_Id NUMBER) IS
   l_result VARCHAR2(255);
   l_proc   VARCHAR2(72) := g_package||'Chk_Organization_Id';

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  SELECT  NULL
  INTO l_result
  FROM per_all_organization_units org
  WHERE org.organization_id = X_organization_id
  AND org.business_group_id = X_business_group
  AND org.internal_external_flag = 'INT'
  AND org.date_from <= (select date_from
		        from per_budget_versions pbv
		        where pbv.budget_version_id = X_Budget_Version_Id)
  AND nvl(org.date_to,hr_general.end_of_time) >= (select nvl(date_to,hr_general.end_of_time)
		                                  from per_budget_versions pbv
		                                  where pbv.budget_version_id = X_Budget_Version_Id);

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --

EXCEPTION
  when NO_DATA_FOUND then
    hr_utility.set_message(801,'HR_51371_POS_ORG_NOT_EXIST');
    hr_utility.raise_error;

END chk_organization_id;

-- ----------------------------------------------------------------------------
-- |--------------------< chk_budget_version_id >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_budget_version_id(X_budget_version_id IN NUMBER,
		                X_business_group IN NUMBER) IS

   l_result VARCHAR2(255);
   l_proc   VARCHAR2(72) := g_package||'chk_budget_version_id';
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  SELECT null
  INTO l_result
  FROM per_budget_versions pbv
  WHERE pbv.budget_version_id = X_budget_version_id
  AND pbv.business_group_id = X_Business_Group;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    hr_utility.set_message(800,'PER_52881_BUD_VER_NOT_EXISTS');
    hr_utility.raise_error;
  WHEN TOO_MANY_ROWS THEN
    null;

END chk_budget_version_id;

-- ----------------------------------------------------------------------------
-- |---------------------------< Insert_Row >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Budget_Element_Id             IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Grade_Id                            NUMBER,
                     X_Job_Id                              NUMBER,
                     X_Position_Id                         NUMBER,
                     X_Organization_Id                     NUMBER,
                     X_Budget_Version_Id                   NUMBER,
                     X_Training_Plan_Id                    NUMBER,
                     X_Training_Plan_Member_Id             NUMBER,
		     X_Event_Id                            NUMBER
 ) IS

   CURSOR C1 IS SELECT rowid FROM per_budget_elements
             WHERE X_budget_element_id = X_Budget_Element_Id;

   CURSOR C2 IS SELECT per_budget_elements_s.nextval
                FROM dual;

   l_proc   VARCHAR2(72) := g_package||'Insert_Row';

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- validate mandatory business_group
    hr_api.validate_bus_grp_id(X_Business_Group_Id);

  -- validate mandatory budget_version_id
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'budget_version_id',
     p_argument_value => X_budget_version_id);

  chk_budget_version_id(x_budget_version_id,x_business_group_id);


  -- validate grade_id
  IF x_grade_id IS NOT NULL THEN
    chk_grade_id(x_grade_id,x_business_group_id);
  END IF;

  -- validate job_id
  IF x_job_id IS NOT NULL THEN
    chk_job_id(x_job_id,x_business_group_id);
  END IF;

  -- validate position_id
  IF x_position_id IS NOT NULL THEN
    chk_position_id(x_position_id,x_business_group_id);
  END IF;

  -- validate organization_id
  IF x_organization_id IS NOT NULL THEN
    chk_organization_id(x_organization_id,x_business_group_id,x_budget_version_id);
  END IF;
  -- validate training_plan_id, training_plan_member_id, event_id
  -- and enforce associated business rules if parent 'OTA_BUDGET'
  -- per_budgets record exists
  IF per_budgets_pkg.chk_ota_budget_type(null,x_budget_version_id,null) THEN

    -- ensure one of training_plan_id, training_plan_member_id, event_id are set if OTA_BUDGET
    IF x_training_plan_id IS NULL AND x_training_plan_member_id IS NULL AND x_event_id IS NULL THEN
      hr_utility.set_message(800,'PER_52882_TP_NOT_NULL');
      hr_utility.raise_error;
    END IF;

    -- ensure x_training_plan_member_id is not null if x_event_id is set
    IF x_event_id IS NOT NULL AND x_training_plan_member_id IS NULL THEN
      hr_utility.set_message(800,'PER_52883_TPMID_NOT_NULL');
      hr_utility.raise_error;
    END IF;

    -- ensure x_training_plan_id is not null if x_training_plan_member_id is set
    IF x_training_plan_member_id IS NOT NULL AND x_training_plan_id IS NULL THEN
      hr_utility.set_message(800,'PER_52884_TPID_NOT_NULL');
      hr_utility.raise_error;
    END IF;

    -- validate event_id
    IF x_event_id IS NOT NULL THEN
      chk_event_id(x_event_id,x_business_group_id);
    END IF;

    -- validate x_training_plan_id
    IF x_training_plan_id IS NOT NULL THEN
      chk_training_plan_id(x_training_plan_id,x_business_group_id);
    END IF;

    -- validate x_training_plan_member_id
    IF x_training_plan_member_id IS NOT NULL THEN
      chk_training_plan_member_id(x_training_plan_id,x_training_plan_member_id,x_business_group_id);
    END IF;

  -- raise error as these should not be set if 'HR_BUDGET' per_budgets is parent.
  ELSIF x_training_plan_id IS NOT NULL OR x_training_plan_member_id IS NOT NULL OR x_event_id IS NOT NULL THEN
    hr_utility.set_message(800,'PER_52885_TP_NULL');
    hr_utility.raise_error;
  END IF;

  -- check uniqueness of the record
  Chk_Unique(X_Rowid,
             X_Budget_Version_Id,
             X_Organization_Id,
             X_Job_Id,
             X_Position_Id,
             X_Grade_Id,
             X_Training_Plan_Id,
             X_Training_Plan_Member_Id,
             X_Event_Id);

  -- generate new budget_element_id from sequence.
  OPEN C2;
  FETCH C2 INTO X_Budget_Element_Id;
  CLOSE C2;

  INSERT INTO per_budget_elements(
          budget_element_id,
          business_group_id,
          grade_id,
          job_id,
          position_id,
          organization_id,
          budget_version_id,
	  training_plan_id,
	  training_plan_member_id,
	  event_id
         ) VALUES (
          X_Budget_Element_Id,
          X_Business_Group_Id,
          X_Grade_Id,
          X_Job_Id,
          X_Position_Id,
          X_Organization_Id,
          X_Budget_Version_Id,
	  X_Training_Plan_Id,
	  X_Training_Plan_Member_Id,
	  X_Event_Id);

  OPEN C1;
  FETCH C1 INTO X_Rowid;
  if (C1%NOTFOUND) then
    CLOSE C1;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Insert_Row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
END Insert_Row;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< Lock_Row >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Budget_Element_Id                     NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Grade_Id                              NUMBER,
                   X_Job_Id                                NUMBER,
                   X_Position_Id                           NUMBER,
                   X_Organization_Id                       NUMBER,
                   X_Budget_Version_Id                     NUMBER,
                   X_Training_Plan_Id                      NUMBER,
                   X_Training_Plan_Member_Id               NUMBER,
		   X_Event_Id                              NUMBER
) IS
  CURSOR C IS
      SELECT *
      FROM   per_budget_elements
      WHERE  rowid = X_Rowid
      FOR UPDATE of Budget_Element_Id NOWAIT;
  Recinfo C%ROWTYPE;
   l_proc   VARCHAR2(72) := g_package||'Lock_Row';
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Lock_Row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.budget_element_id = X_Budget_Element_Id)
           OR (    (Recinfo.budget_element_id IS NULL)
               AND (X_Budget_Element_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.grade_id = X_Grade_Id)
           OR (    (Recinfo.grade_id IS NULL)
               AND (X_Grade_Id IS NULL)))
      AND (   (Recinfo.job_id = X_Job_Id)
           OR (    (Recinfo.job_id IS NULL)
               AND (X_Job_Id IS NULL)))
      AND (   (Recinfo.position_id = X_Position_Id)
           OR (    (Recinfo.position_id IS NULL)
               AND (X_Position_Id IS NULL)))
      AND (   (Recinfo.organization_id = X_Organization_Id)
           OR (    (Recinfo.organization_id IS NULL)
               AND (X_Organization_Id IS NULL)))
      AND (   (Recinfo.budget_version_id = X_Budget_Version_Id)
           OR (    (Recinfo.budget_version_id IS NULL)
               AND (X_Budget_Version_Id IS NULL)))
      AND (   (Recinfo.training_plan_id = X_Training_Plan_Id)
           OR (    (Recinfo.training_plan_id IS NULL)
               AND (X_Training_Plan_Id IS NULL)))
      AND (   (Recinfo.training_plan_member_id = X_Training_Plan_Member_Id)
           OR (    (Recinfo.training_plan_member_id IS NULL)
               AND (X_Training_Plan_Member_Id IS NULL)))
      AND (   (Recinfo.event_id = X_Event_Id)
           OR (    (Recinfo.event_id IS NULL)
               AND (X_Event_Id IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
END Lock_Row;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< Update_Row >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Budget_Element_Id                   NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Grade_Id                            NUMBER,
                     X_Job_Id                              NUMBER,
                     X_Position_Id                         NUMBER,
                     X_Organization_Id                     NUMBER,
                     X_Budget_Version_Id                   NUMBER,
                     X_Training_Plan_Id                    NUMBER,
                     X_Training_Plan_Member_Id             NUMBER,
		     X_Event_Id                            NUMBER
) IS

  l_proc   VARCHAR2(72) := g_package||'Update_Row';

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- validate mandatory business_group
    hr_api.validate_bus_grp_id(X_Business_Group_Id);

  -- validate mandatory budget_version_id
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'budget_version_id',
     p_argument_value => X_budget_version_id);

  chk_budget_version_id(x_budget_version_id,x_business_group_id);

  -- validate mandatory x_rowid
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'rowid',
     p_argument_value => X_rowid);

  -- validate mandatory x_budget_element_id
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'budget_element_id',
     p_argument_value => x_budget_element_id);

    chk_budget_element_id(x_budget_element_id,x_rowid);
  -- validate grade_id
  IF x_grade_id IS NOT NULL THEN
    chk_grade_id(x_grade_id,x_business_group_id);
  END IF;

  -- validate job_id
  IF x_job_id IS NOT NULL THEN
    chk_job_id(x_job_id,x_business_group_id);
  END IF;

  -- validate position_id
  IF x_position_id IS NOT NULL THEN
    chk_position_id(x_position_id,x_business_group_id);
  END IF;

  -- validate organization_id
  IF x_organization_id IS NOT NULL THEN
    chk_organization_id(x_organization_id,x_business_group_id,x_budget_version_id);
  END IF;

  -- validate training_plan_id, training_plan_member_id, event_id
  -- and enforce associated business rules if parent 'OTA_BUDGET'
  -- per_budgets record exists
  IF per_budgets_pkg.chk_ota_budget_type(null,x_budget_version_id,null) THEN

    -- ensure one of training_plan_id, training_plan_member_id, event_id are set if OTA_BUDGET
    IF x_training_plan_id IS NULL AND x_training_plan_member_id IS NULL AND x_event_id IS NULL THEN
      hr_utility.set_message(800,'PER_52882_TP_NOT_NULL');
      hr_utility.raise_error;
    END IF;

    -- ensure x_training_plan_member_id is not null if x_event_id is set
    IF x_event_id IS NOT NULL AND x_training_plan_member_id IS NULL THEN
      hr_utility.set_message(800,'PER_52883_TPMID_NOT_NULL');
      hr_utility.raise_error;
    END IF;

    -- ensure x_training_plan_id is not null if x_training_plan_member_id is set
    IF x_training_plan_member_id IS NOT NULL AND x_training_plan_id IS NULL THEN
      hr_utility.set_message(800,'PER_52884_TPID_NOT_NULL');
      hr_utility.raise_error;
    END IF;

    -- validate event_id
    IF x_event_id IS NOT NULL THEN
      chk_event_id(x_event_id,x_business_group_id);
    END IF;

    -- validate x_training_plan_id
    IF x_training_plan_id IS NOT NULL THEN
      chk_training_plan_id(x_training_plan_id,x_business_group_id);
    END IF;

    -- validate x_training_plan_member_id
    IF x_training_plan_member_id IS NOT NULL THEN
      chk_training_plan_member_id(x_training_plan_id,x_training_plan_member_id,x_business_group_id);
    END IF;

  -- raise error as these should not be set if 'HR_BUDGET' per_budgets is parent.
  ELSIF x_training_plan_id IS NOT NULL OR x_training_plan_member_id IS NOT NULL OR x_event_id IS NOT NULL THEN
    hr_utility.set_message(800,'PER_52885_TP_NULL');
    hr_utility.raise_error;
  END IF;

  -- check uniqueness of the record
  Chk_Unique(X_Rowid,
             X_Budget_Version_Id,
             X_Organization_Id,
             X_Job_Id,
             X_Position_Id,
             X_Grade_Id,
             X_Training_Plan_Id,
             X_Training_Plan_Member_Id,
             X_Event_Id);


  UPDATE per_budget_elements
  SET
    budget_element_id                         =    X_Budget_Element_Id,
    business_group_id                         =    X_Business_Group_Id,
    grade_id                                  =    X_Grade_Id,
    job_id                                    =    X_Job_Id,
    position_id                               =    X_Position_Id,
    organization_id                           =    X_Organization_Id,
    budget_version_id                         =    X_Budget_Version_Id,
    training_plan_id                          =    X_Training_Plan_Id,
    training_plan_member_id                   =    X_Training_Plan_Member_Id,
    event_id                                  =    X_Event_Id
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Update_Row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
END Update_Row;

-- ----------------------------------------------------------------------------
-- |---------------------------< Delete_Row >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS

  CURSOR C_Values is
         SELECT pbv.Rowid
         FROM per_budget_values pbv
         WHERE pbv.budget_element_id = (SELECT pbe.budget_element_id
                                        FROM per_budget_elements pbe
                                        WHERE pbe.rowid = X_Rowid);

  l_val_rowid           VARCHAR2(30);
  l_proc                VARCHAR2(72) := g_package||'Delete_Row';
  l_budget_version_id   NUMBER(15);
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  SELECT budget_version_id into l_budget_version_id
  FROM per_budget_elements pbe
  WHERE pbe.rowid = x_rowid;
  --
  OPEN C_Values;
  -- Cascade delete the appropriate child budget_elements recs if
  -- parent per_budgets budget_type_code is 'HR_BUDGET';
  IF per_budgets_pkg.chk_OTA_Budget_Type(NULL, l_budget_version_id, NULL) = FALSE THEN
    LOOP
      FETCH C_Values into l_val_rowid;
      EXIT when (C_Values%NOTFOUND);
      PER_BUDGET_VALUES_PKG.Delete_Row(X_Rowid => l_val_rowid);
    END LOOP;
  ELSE
    FETCH C_Values into l_val_rowid;
    IF C_Values%FOUND THEN
      CLOSE C_Values;
      --raise error as child record has been found
      hr_utility.set_message(800,'PER_52886_BUD_VAL_DELETE_FAIL');
      hr_utility.raise_error;
    END IF;
  END IF;
  CLOSE C_Values;
  --
  --now delete the parent element
    DELETE FROM PER_BUDGET_ELEMENTS
      WHERE rowid = X_Rowid;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    hr_utility.set_message(800,'PER_52881_BUD_VER_NOT_EXISTS');
    hr_utility.raise_error;
END Delete_Row;

END PER_BUDGET_ELEMENTS_PKG;

/
