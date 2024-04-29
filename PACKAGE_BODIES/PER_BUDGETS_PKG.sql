--------------------------------------------------------
--  DDL for Package Body PER_BUDGETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BUDGETS_PKG" as
/* $Header: pebgt01t.pkb 115.6 2004/02/16 10:20:09 nsanghal ship $ */

-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
g_package  varchar2(33)	:= '  per_budgets_pkg.';  -- Global package name


-- ----------------------------------------------------------------------------
-- |---------------------------< Chk_Unique >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Chk_Unique(X_Rowid             VARCHAR2,
                     X_Business_Group_Id NUMBER,
                     X_Name              VARCHAR2,
		     X_Budget_Type_Code  VARCHAR2) is
     l_result VARCHAR2(255);
     l_proc   VARCHAR2(72) := g_package||'Chk_Unique';

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  SELECT NULL
  INTO l_result
  FROM per_budgets b
  WHERE UPPER(X_Name) = UPPER(b.Name)
  AND UPPER(X_Budget_Type_Code) = UPPER(b.Budget_Type_Code)
  AND X_Business_Group_Id = b.Business_Group_Id + 0
  AND (b.Rowid <> X_Rowid or X_Rowid is null);

  IF (SQL%FOUND) then
    hr_utility.set_message(801,'PER_7852_DEF_BUDGET_EXISTS');
    hr_utility.raise_error;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
EXCEPTION
  when NO_DATA_FOUND then
    null;

END Chk_Unique;

-- ----------------------------------------------------------------------------
-- |-------------------------< Chk_OTA_Budget_Type >--------------------------|
-- ----------------------------------------------------------------------------
-- Determine budget_type_code of per_budgets rec.
-- Accepts Budget_id or Budget_Version_Id or Rowid
--
FUNCTION Chk_OTA_Budget_Type(X_Budget_Id IN NUMBER,
			     X_Budget_Version_Id IN NUMBER,
			     X_Rowid in VARCHAR2) RETURN BOOLEAN IS

--
  CURSOR c_bdv IS
    SELECT NULL
    FROM per_budget_versions bdv, per_budgets bd
    WHERE bdv.budget_id = bd.budget_id
    AND  bdv.budget_version_id = X_Budget_Version_Id
    AND bd.budget_type_code = 'OTA_BUDGET';
--
  CURSOR c_bdg1 IS
    SELECT NULL
    FROM per_budgets pb
    WHERE pb.budget_id = X_Budget_Id
    AND budget_type_code = 'OTA_BUDGET';
--
  CURSOR c_bdg2 IS
    SELECT NULL
    FROM per_budgets pb
    WHERE pb.rowid = X_Rowid
    AND budget_type_code = 'OTA_BUDGET';
--
  l_result VARCHAR2(255);
  l_proc   VARCHAR2(72) := g_package||'Chk_OTA_Budget_Type';
--
  BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  IF X_Budget_Id IS NOT NULL AND X_Budget_Version_Id IS NULL AND X_Rowid IS NULL THEN
    OPEN c_bdg1;
    FETCH c_bdg1 into l_result;
    IF c_bdg1%NOTFOUND THEN
      CLOSE c_bdg1;
      RETURN FALSE;
    ELSE
      CLOSE c_bdg1;
      RETURN TRUE;
    END IF;
  ELSIF X_rowid IS NOT NULL AND X_Budget_Id IS NULL AND X_budget_Version_Id IS NULL THEN
    OPEN c_bdg2;
    FETCH c_bdg2 into l_result;
    IF c_bdg2%NOTFOUND THEN
      CLOSE c_bdg2;
      RETURN FALSE;
    ELSE
      CLOSE c_bdg2;
      RETURN TRUE;
    END IF;
  ELSIF X_Budget_Version_Id IS NOT NULL AND X_Budget_Id IS NULL AND X_Rowid IS NULL THEN
    OPEN c_bdv;
    FETCH c_bdv into l_result;
    IF c_bdv%NOTFOUND THEN
      CLOSE c_bdv;
      RETURN FALSE;
    ELSE
      CLOSE c_bdv;
      RETURN TRUE;
    END IF;
  ELSIF X_Budget_Id IS NULL AND X_Budget_Version_Id IS NULL AND X_Rowid IS NULL THEN
    hr_utility.set_message(800,'PER_52867_INV_ARGS');
    hr_utility.raise_error;
  ELSE
    hr_utility.set_message(800,'PER_52868_TOO_MANY_ARGS');
    hr_utility.raise_error;
  END IF;
 --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
END Chk_OTA_Budget_Type;

-- ----------------------------------------------------------------------------
-- |---------------------< Chk_Measurement_Type_Exists >----------------------|
-- ----------------------------------------------------------------------------
-- Check there is a measurement_type for the UNIT within the business_group
-- (used for OTA_BUDGET budget_type_code records)
--
PROCEDURE Chk_Measurement_Type_Exists(X_Business_Group_Id NUMBER,
				      X_Unit              VARCHAR2) IS
--
   l_status    varchar2(30);
   l_industry  varchar2(30);
   l_owner     varchar2(30);
   l_ret       boolean := FND_INSTALLATION.GET_APP_INFO ('OTA', l_status,
                                                      l_industry, l_owner);

   -- dynamic sql statments to check if the training plan measurement types exit
   --
   l_stmt_chk_tpc_exist varchar2(32000) := 'select ''Y'' from all_tables
                 where table_name = ''OTA_TP_MEASUREMENT_TYPES''
                 and   owner      = '''||l_owner||'''';
   --
   -- dynamic sql statment to check if a row exists in training plan members
   --
   l_stmt_get_tpc_rows varchar2(32000) := 'select ''Y'' from OTA_TP_MEASUREMENT_TYPES --
   where upper(tp_measurement_code) = upper('''||X_unit ||''') --
   and business_group_id = '||X_Business_Group_id;
   --
   l_dyn_curs   integer;
   l_dyn_rows   integer;
   l_exists VARCHAR2(255);


   l_proc   VARCHAR2(72) := g_package||'Chk_Measurement_Type_Exists';

   --
BEGIN
--
  hr_utility.set_location('Entering:'||l_proc, 5);

  l_dyn_curs := dbms_sql.open_cursor;
  --
  -- Determine if the OTA_TP_MEASUREEMNT_TYPES table exists
  --
  dbms_sql.parse(l_dyn_curs,l_stmt_chk_tpc_exist,dbms_sql.v7);
  l_dyn_rows := dbms_sql.execute_and_fetch(l_dyn_curs);
  --
  if dbms_sql.last_row_count > 0 then
    -- Check that the training plan measurement record exists
    dbms_sql.parse(l_dyn_curs,l_stmt_get_tpc_rows,dbms_sql.v7);
    l_dyn_rows := dbms_sql.execute_and_fetch(l_dyn_curs);
    --
    if dbms_sql.last_row_count < 1 then
      dbms_sql.close_cursor(l_dyn_curs);
    hr_utility.set_message(800,'PER_52869_MEASURE_NOT_EXISTS');
    hr_utility.raise_error;
    end if;
  end if;
  if dbms_sql.is_open(l_dyn_curs) then
    dbms_sql.close_cursor(l_dyn_curs);
  end if;

  hr_utility.set_location(' Leaving:'|| l_proc, 10);
  --
END Chk_Measurement_Type_Exists;
-- ----------------------------------------------------------------------------
-- |------------------------< Chk_Budget_Type_Code >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Chk_Budget_Type_Code(X_Budget_Type_Code IN VARCHAR2) IS
--
  l_proc   VARCHAR2(72) := g_package||'Chk_Budget_Type_Code';
--
BEGIN
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  IF (UPPER(X_Budget_Type_Code) <> 'HR_BUDGET' AND UPPER(X_Budget_Type_Code) <> 'OTA_BUDGET') OR X_Budget_Type_Code IS NULL THEN
    hr_utility.set_message(800,'PER_52870_INV_BUD_TYPE');
    hr_utility.raise_error;
  END IF;
 --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 --
END Chk_Budget_Type_Code;


-- ----------------------------------------------------------------------------
-- |------------------------< Chk_Period_Set_Name >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Chk_Period_Set_Name(X_Period_Set_Name   IN VARCHAR2) IS
--
   CURSOR c_ptp IS
     SELECT null
     FROM pay_calendars pc
     WHERE pc.period_set_name = X_Period_Set_Name;
--
     l_exists VARCHAR2(255);
     l_proc   VARCHAR2(72) := g_package||'Chk_Period_Set_Name';
--
BEGIN
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
  OPEN c_ptp;
  FETCH c_ptp INTO l_exists;
  IF c_ptp%NOTFOUND THEN
    hr_utility.set_message(800,'PER_52871_CAL_NOT_EXIST');
    hr_utility.raise_error;
  END IF;
  CLOSE c_ptp;
 --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 --
END Chk_Period_Set_Name;


-- ----------------------------------------------------------------------------
-- |----------------------------< Chk_df >------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Chk_df(x_attribute_category  varchar2
                ,x_attribute1          varchar2
                ,x_attribute2          varchar2
                ,x_attribute3          varchar2
                ,x_attribute4          varchar2
                ,x_attribute5          varchar2
                ,x_attribute6          varchar2
                ,x_attribute7          varchar2
                ,x_attribute8          varchar2
                ,x_attribute9          varchar2
                ,x_attribute10         varchar2
                ,x_attribute11         varchar2
                ,x_attribute12         varchar2
                ,x_attribute13         varchar2
                ,x_attribute14         varchar2
                ,x_attribute15         varchar2
                ,x_attribute16         varchar2
                ,x_attribute17         varchar2
                ,x_attribute18         varchar2
                ,x_attribute19         varchar2
                ,x_attribute20         varchar2) IS

     l_proc   VARCHAR2(72) := g_package||'Chk_df';

BEGIN
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
   hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name     => 'PER'
      ,p_descflex_name      => 'PER_BUDGETS'
      ,p_attribute_category => x_attribute_category
      ,p_attribute1_name    => 'ATTRIBUTE1'
      ,p_attribute1_value   => x_attribute1
      ,p_attribute2_name    => 'ATTRIBUTE2'
      ,p_attribute2_value   => x_attribute2
      ,p_attribute3_name    => 'ATTRIBUTE3'
      ,p_attribute3_value   => x_attribute3
      ,p_attribute4_name    => 'ATTRIBUTE4'
      ,p_attribute4_value   => x_attribute4
      ,p_attribute5_name    => 'ATTRIBUTE5'
      ,p_attribute5_value   => x_attribute5
      ,p_attribute6_name    => 'ATTRIBUTE6'
      ,p_attribute6_value   => x_attribute6
      ,p_attribute7_name    => 'ATTRIBUTE7'
      ,p_attribute7_value   => x_attribute7
      ,p_attribute8_name    => 'ATTRIBUTE8'
      ,p_attribute8_value   => x_attribute8
      ,p_attribute9_name    => 'ATTRIBUTE9'
      ,p_attribute9_value   => x_attribute9
      ,p_attribute10_name   => 'ATTRIBUTE10'
      ,p_attribute10_value  => x_attribute10
      ,p_attribute11_name   => 'ATTRIBUTE11'
      ,p_attribute11_value  => x_attribute11
      ,p_attribute12_name   => 'ATTRIBUTE12'
      ,p_attribute12_value  => x_attribute12
      ,p_attribute13_name   => 'ATTRIBUTE13'
      ,p_attribute13_value  => x_attribute13
      ,p_attribute14_name   => 'ATTRIBUTE14'
      ,p_attribute14_value  => x_attribute14
      ,p_attribute15_name   => 'ATTRIBUTE15'
      ,p_attribute15_value  => x_attribute15
      ,p_attribute16_name   => 'ATTRIBUTE16'
      ,p_attribute16_value  => x_attribute16
      ,p_attribute17_name   => 'ATTRIBUTE17'
      ,p_attribute17_value  => x_attribute17
      ,p_attribute18_name   => 'ATTRIBUTE18'
      ,p_attribute18_value  => x_attribute18
      ,p_attribute19_name   => 'ATTRIBUTE19'
      ,p_attribute19_value  => x_attribute19
      ,p_attribute20_name   => 'ATTRIBUTE20'
      ,p_attribute20_value  => x_attribute20);
 --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 --
END Chk_df;


-- ----------------------------------------------------------------------------
-- |----------------------------< Insert_Row >--------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Budget_Id                    IN OUT NOCOPY NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Period_Set_Name                     VARCHAR2,
                     X_Name                                VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Unit                                VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2,
		     X_Budget_Type_Code                    VARCHAR2
 ) IS

   CURSOR C1 IS SELECT rowid FROM PER_BUDGETS
             WHERE budget_id = X_budget_id;

   CURSOR C2 IS SELECT per_budgets_s.nextval FROM dual;

   l_proc   VARCHAR2(72) := g_package||'Insert_Row';
   l_name   PER_BUDGETS.NAME%TYPE;

BEGIN
  --
  --hr_utility.trace_on;
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- validate mandatory business_group
    hr_api.validate_bus_grp_id(X_Business_Group_Id);
  --
  -- validate mandatory period_set_name
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'period_set_name',
       p_argument_value => X_Period_Set_Name);

    chk_period_set_name(X_Period_Set_Name);
  --
  -- validate mandatory name
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'name',
       p_argument_value => X_Name);
  --
  -- check budget type code is valid
    chk_budget_type_code(X_budget_Type_Code);

  -- get X_budget_id from sequence now, (used in name for OTA_BUDGET recs)
  OPEN C2;
  FETCH C2 INTO X_budget_id;
  CLOSE C2;
  --
  -- check measurement_type exists if OTA_BUDGET record
  -- nb. UNIT should not be null if OTA_BUDGET type
  IF UPPER(X_Budget_Type_Code) = 'OTA_BUDGET' THEN

    -- Set name field to x_name ||'-'|| budget_id for OTA.
    l_name := X_Name ||'-'||to_char(X_budget_id);

    -- validate mandatory unit
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'unit',
       p_argument_value => X_Unit);

      Chk_Measurement_Type_Exists(X_Business_Group_Id,X_Unit);
  ELSE
    l_name := X_Name;
  END IF;
  --
  -- check per_budgets record does not exists for
  -- this name+bg+btc combination.
  Chk_Unique(NULL,
             X_Business_Group_Id,
             X_Name,
	     X_Budget_Type_Code);

  -- validate desc flex
  Chk_df(X_Attribute_Category,
         X_Attribute1,
         X_Attribute2,
         X_Attribute3,
         X_Attribute4,
         X_Attribute5,
         X_Attribute6,
         X_Attribute7,
         X_Attribute8,
         X_Attribute9,
         X_Attribute10,
         X_Attribute11,
         X_Attribute12,
         X_Attribute13,
         X_Attribute14,
         X_Attribute15,
         X_Attribute16,
         X_Attribute17,
         X_Attribute18,
         X_Attribute19,
         X_Attribute20);




  INSERT INTO PER_BUDGETS(
          budget_id,
          business_group_id,
          period_set_name,
          name,
          comments,
          unit,
          attribute_category,
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
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
	  budget_type_code
         ) VALUES (
          X_budget_id,
          X_Business_Group_Id,
          X_Period_Set_Name,
          l_name,
          X_Comments,
          X_Unit,
          X_Attribute_Category,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Attribute11,
          X_Attribute12,
          X_Attribute13,
          X_Attribute14,
          X_Attribute15,
          X_Attribute16,
          X_Attribute17,
          X_Attribute18,
          X_Attribute19,
          X_Attribute20,
	  X_Budget_Type_Code
  );

  OPEN C1;
  FETCH C1 INTO X_Rowid;
  if (C1%NOTFOUND) then
    CLOSE C1;
/*    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Insert_Row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;*/
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C1;
 --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 --
END Insert_Row;


-- ----------------------------------------------------------------------------
-- |----------------------------< Lock_Row >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Budget_Id                             NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Period_Set_Name                       VARCHAR2,
                   X_Name                                  VARCHAR2,
                   X_Comments                              VARCHAR2,
                   X_Unit                                  VARCHAR2,
                   X_Attribute_Category                    VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Attribute11                           VARCHAR2,
                   X_Attribute12                           VARCHAR2,
                   X_Attribute13                           VARCHAR2,
                   X_Attribute14                           VARCHAR2,
                   X_Attribute15                           VARCHAR2,
                   X_Attribute16                           VARCHAR2,
                   X_Attribute17                           VARCHAR2,
                   X_Attribute18                           VARCHAR2,
                   X_Attribute19                           VARCHAR2,
                   X_Attribute20                           VARCHAR2,
		   X_Budget_Type_Code                      VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   PER_BUDGETS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Budget_Id  NOWAIT;
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
--
Recinfo.budget_id := rtrim(Recinfo.budget_id);
Recinfo.business_group_id := rtrim(Recinfo.business_group_id);
Recinfo.period_set_name := rtrim(Recinfo.period_set_name);
Recinfo.name := rtrim(Recinfo.name);
Recinfo.comments := rtrim(Recinfo.comments);
Recinfo.unit := rtrim(Recinfo.unit);
Recinfo.attribute_category := rtrim(Recinfo.attribute_category);
Recinfo.attribute1 := rtrim(Recinfo.attribute1);
Recinfo.attribute2 := rtrim(Recinfo.attribute2);
Recinfo.attribute3 := rtrim(Recinfo.attribute3);
Recinfo.attribute4 := rtrim(Recinfo.attribute4);
Recinfo.attribute5 := rtrim(Recinfo.attribute5);
Recinfo.attribute6 := rtrim(Recinfo.attribute6);
Recinfo.attribute7 := rtrim(Recinfo.attribute7);
Recinfo.attribute8 := rtrim(Recinfo.attribute8);
Recinfo.attribute9 := rtrim(Recinfo.attribute9);
Recinfo.attribute10 := rtrim(Recinfo.attribute10);
Recinfo.attribute11 := rtrim(Recinfo.attribute11);
Recinfo.attribute12 := rtrim(Recinfo.attribute12);
Recinfo.attribute13 := rtrim(Recinfo.attribute13);
Recinfo.attribute14 := rtrim(Recinfo.attribute14);
Recinfo.attribute15 := rtrim(Recinfo.attribute15);
Recinfo.attribute16 := rtrim(Recinfo.attribute16);
Recinfo.attribute17 := rtrim(Recinfo.attribute17);
Recinfo.attribute18 := rtrim(Recinfo.attribute18);
Recinfo.attribute19 := rtrim(Recinfo.attribute19);
Recinfo.attribute20 := rtrim(Recinfo.attribute20);
Recinfo.budget_type_code := rtrim(Recinfo.budget_type_code);
  if (
          (   (Recinfo.budget_id = X_Budget_Id)
           OR (    (Recinfo.budget_id IS NULL)
               AND (X_Budget_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.period_set_name = X_Period_Set_Name)
           OR (    (Recinfo.period_set_name IS NULL)
               AND (X_Period_Set_Name IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.comments = X_Comments)
           OR (    (Recinfo.comments IS NULL)
               AND (X_Comments IS NULL)))
      AND (   (Recinfo.unit = X_Unit)
           OR (    (Recinfo.unit IS NULL)
               AND (X_Unit IS NULL)))
      AND (   (Recinfo.attribute_category = X_Attribute_Category)
           OR (    (Recinfo.attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
      AND (   (Recinfo.attribute16 = X_Attribute16)
           OR (    (Recinfo.attribute16 IS NULL)
               AND (X_Attribute16 IS NULL)))
      AND (   (Recinfo.attribute17 = X_Attribute17)
           OR (    (Recinfo.attribute17 IS NULL)
               AND (X_Attribute17 IS NULL)))
      AND (   (Recinfo.attribute18 = X_Attribute18)
           OR (    (Recinfo.attribute18 IS NULL)
               AND (X_Attribute18 IS NULL)))
      AND (   (Recinfo.attribute19 = X_Attribute19)
           OR (    (Recinfo.attribute19 IS NULL)
               AND (X_Attribute19 IS NULL)))
      AND (   (Recinfo.attribute20 = X_Attribute20)
           OR (    (Recinfo.attribute20 IS NULL)
               AND (X_Attribute20 IS NULL)))
      AND (   (Recinfo.budget_type_code = X_budget_type_code)
           OR (    (Recinfo.budget_type_code IS NULL)
               AND (X_budget_type_code IS NULL)))
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

-- ----------------------------------------------------------------------------
-- |---------------------------< Update_Row >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Budget_Id                           NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Period_Set_Name                     VARCHAR2,
                     X_Name                                VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Unit                                VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2,
		     X_Budget_Type_Code                    VARCHAR2
) IS
  l_proc   VARCHAR2(72) := g_package||'Update_Row';
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- validate mandatory business_group
    hr_api.validate_bus_grp_id(X_Business_Group_Id);

  -- validate mandatory budget_id
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'budget_id',
       p_argument_value => X_Budget_Id);

  -- validate mandatory rowid
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'rowid',
       p_argument_value => X_rowid);

  -- validate mandatory period_set_name
    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'period_set_name',
       p_argument_value => X_Period_Set_Name);

    chk_period_set_name(X_Period_Set_Name);

  -- validate mandatory name

    hr_api.mandatory_arg_error
      (p_api_name       => l_proc,
       p_argument       => 'name',
       p_argument_value => X_Name);

  --
  -- check budget type code is valid
    chk_budget_type_code(X_budget_Type_Code);
  --

  -- check measurement_type exists if OTA_BUDGET record
  -- nb. UNIT should not be null if OTA_BUDGET type
  IF UPPER(X_Budget_Type_Code) = 'OTA_BUDGET' THEN

      hr_api.mandatory_arg_error
        (p_api_name       => l_proc,
         p_argument       => 'unit',
         p_argument_value => X_Unit);

      Chk_Measurement_Type_Exists(X_Business_Group_Id,X_Unit);

  END IF;

  -- check per_budgets record does not exists for
  -- this name+bg+btc combination.
  Chk_Unique(x_Rowid,
             X_Business_Group_Id,
             X_Name,
	     X_Budget_Type_Code);

  -- validate desc flex
  Chk_df(X_Attribute_Category,
         X_Attribute1,
         X_Attribute2,
         X_Attribute3,
         X_Attribute4,
         X_Attribute5,
         X_Attribute6,
         X_Attribute7,
         X_Attribute8,
         X_Attribute9,
         X_Attribute10,
         X_Attribute11,
         X_Attribute12,
         X_Attribute13,
         X_Attribute14,
         X_Attribute15,
         X_Attribute16,
         X_Attribute17,
         X_Attribute18,
         X_Attribute19,
         X_Attribute20);

  -- now perform update
  UPDATE PER_BUDGETS
  SET
    budget_id                                 =    X_Budget_Id,
    business_group_id                         =    X_Business_Group_Id,
    period_set_name                           =    X_Period_Set_Name,
    name                                      =    X_Name,
    comments                                  =    X_Comments,
    unit                                      =    X_Unit,
    attribute_category                        =    X_Attribute_Category,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    attribute16                               =    X_Attribute16,
    attribute17                               =    X_Attribute17,
    attribute18                               =    X_Attribute18,
    attribute19                               =    X_Attribute19,
    attribute20                               =    X_Attribute20,
    budget_type_code                          =    X_Budget_Type_Code
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
--
  CURSOR C_Version is SELECT Rowid
                      FROM   per_budget_versions pbv
                      where pbv.budget_id = (SELECT pb.budget_id
                                             FROM per_budgets pb
                                             WHERE pb.Rowid = X_Rowid);
--
  l_ver_rowid VARCHAR2(30);
  l_proc      VARCHAR2(72) := g_package||'Delete_Row';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  OPEN C_Version;
  -- Cascade delete the appropriate child budget_versions recs if
  -- budget_type_code is 'HR_BUDGET';
  IF chk_OTA_Budget_Type(NULL, NULL, X_Rowid) = FALSE THEN
    LOOP
      FETCH C_Version into l_ver_rowid;
      EXIT WHEN (C_Version%NOTFOUND);
      PER_BUDGET_VERSION_RULES_PKG.Delete_Row(X_Rowid => l_ver_rowid);
    END LOOP;
  ELSE
    FETCH C_Version into l_ver_rowid;
    IF C_Version%FOUND THEN
      CLOSE C_Version;
      --raise error as child record has been found
      hr_utility.set_message(800,'PER_52872_BUD_DELETE_FAIL');
      hr_utility.raise_error;
    END IF;
  END IF;
  CLOSE C_Version;

  --now delete the parent budget
  DELETE FROM PER_BUDGETS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Delete_Row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
 --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 --
END Delete_Row;

END PER_BUDGETS_PKG;

/
