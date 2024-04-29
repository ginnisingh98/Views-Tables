--------------------------------------------------------
--  DDL for Package Body PER_BUDGET_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_BUDGET_VALUES_PKG" as
/* $Header: pebgv01t.pkb 115.9 2004/02/16 10:20:27 nsanghal ship $ */
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
g_package  varchar2(33) := '  per_budget_values_pkg.';  -- Global package name

-- ----------------------------------------------------------------------------
-- |---------------------------< Chk_Unique >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Chk_Unique(X_Rowid             VARCHAR2,
                     X_Business_Group_Id NUMBER,
                     X_Budget_Element_Id NUMBER,
                     X_Time_Period_Id    NUMBER) is
          l_result VARCHAR2(255);
          l_proc   VARCHAR2(72) := g_package||'Chk_Unique';
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  SELECT NULL
  INTO l_result
  FROM per_budget_values bv
  WHERE X_Budget_Element_Id = bv.budget_element_id
  AND X_Time_Period_Id = bv.time_period_id
  AND X_Business_group_Id = bv.Business_Group_Id + 0
  AND (bv.Rowid <> X_Rowid or X_Rowid is null);

  IF (SQL%FOUND) then
    hr_utility.set_message(801,'PER_7228_BUDGET_ONE_PER_PERIOD');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
EXCEPTION
  when NO_DATA_FOUND then
    null;
END Chk_Unique;

-- ----------------------------------------------------------------------------
-- |--------------------< chk_budget_element_id >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_budget_element_id(x_budget_element_id IN NUMBER,
				x_business_group_id IN NUMBER,
				x_budget_version_id OUT NOCOPY NUMBER) IS
  l_result VARCHAR2(255);
  l_proc   VARCHAR2(72) := g_package||'chk_budget_element_id';
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  SELECT budget_version_id
  INTO x_budget_version_id
  FROM per_budget_elements pbe
  WHERE pbe.budget_element_id = x_budget_element_id
  AND pbe.business_group_id = x_business_group_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    hr_utility.set_message(800,'PER_52866_INV_BUD_ELE');
    hr_utility.raise_error;
END chk_budget_element_id;

-- ----------------------------------------------------------------------------
-- |----------------------< chk_budget_value_id >-------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE chk_budget_value_id(X_budget_value_id IN NUMBER,
		              X_rowid IN VARCHAR2) IS
   l_result VARCHAR2(255);
   l_proc   VARCHAR2(72) := g_package||'chk_budget_value_id';
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  SELECT NULL
  INTO l_result
  FROM per_budget_values pbv
  WHERE pbv.budget_value_id = x_budget_value_id
  AND (pbv.rowid <> X_rowid OR X_rowid IS NULL);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
  IF SQL%FOUND THEN
    hr_utility.set_message(800,'PER_52888_BUD_VAL_EXISTS');
    hr_utility.raise_error;
  END IF;
--
EXCEPTION
  when NO_DATA_FOUND then
    null;
END chk_budget_value_id;

-- ----------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |--------------------< get_many_budget_values >-----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_many_budget_values(x_business_group_id IN NUMBER,
				x_budget_version_id IN NUMBER) RETURN BOOLEAN IS

  l_proc   VARCHAR2(72) := g_package||'get_many_budget_values';
  l_status    varchar2(30);
  l_industry  varchar2(30);
  l_owner     varchar2(30);
  l_ret       boolean := FND_INSTALLATION.GET_APP_INFO ('OTA', l_status,
                                                      l_industry, l_owner);

   -- dynamic sql statments to check if the training plan measurement table exists
   --
   l_stmt_chk_tpc_exist varchar2(32000) := --
       'select ''Y'' from all_tables where table_name = ''OTA_TP_MEASUREMENT_TYPES''
          and owner = '''||l_owner||'''';
   --
   -- dynamic sql statment to check if a row exists in ota_tp_measurement_types
   --
   l_stmt_get_tpc_rows varchar2(32000) := 'select ''Y'' from OTA_TP_MEASUREMENT_TYPES ota
     where UPPER(ota.tp_measurement_code) = (select UPPER(unit)
                                             FROM per_budgets
                                             WHERE budget_id = (SELECT budget_id
                                                                FROM   per_budget_versions
                                                                WHERE  budget_version_id = '
                                                                ||x_budget_version_id || '))
    AND ota.many_budget_values_flag = ''Y''
    AND ota.business_group_id = ' ||x_business_group_id;
   --
   l_dyn_curs   integer;
   l_dyn_rows   integer;

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- if OTA is installed,
  -- check if training measurement type record exists with multiple values
  l_dyn_curs := dbms_sql.open_cursor;
  --
  -- Determine if the OTA_TP_MEASUREMENT_TYPES table exists
  --
  dbms_sql.parse(l_dyn_curs,l_stmt_chk_tpc_exist,dbms_sql.v7);
  l_dyn_rows := dbms_sql.execute_and_fetch(l_dyn_curs);
  --
  if dbms_sql.last_row_count > 0 then
    -- Check that the training measurement type record exists with multiple values
    dbms_sql.parse(l_dyn_curs,l_stmt_get_tpc_rows,dbms_sql.v7);
    l_dyn_rows := dbms_sql.execute_and_fetch(l_dyn_curs);
    --
    if dbms_sql.last_row_count > 0 then
      if dbms_sql.is_open(l_dyn_curs) then
        dbms_sql.close_cursor(l_dyn_curs);
      end if;
      RETURN TRUE;
    end if;
  end if;
  if dbms_sql.is_open(l_dyn_curs) then
    dbms_sql.close_cursor(l_dyn_curs);
  end if;
  --
  RETURN FALSE;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
  WHEN TOO_MANY_ROWS THEN
    RETURN TRUE;
--
END get_many_budget_values;
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
                ,x_attribute20         varchar2
                ,x_attribute21         varchar2
                ,x_attribute22         varchar2
                ,x_attribute23         varchar2
                ,x_attribute24         varchar2
                ,x_attribute25         varchar2
                ,x_attribute26         varchar2
                ,x_attribute27         varchar2
                ,x_attribute28         varchar2
                ,x_attribute29         varchar2
                ,x_attribute30         varchar2) IS

     l_proc   VARCHAR2(72) := g_package||'Chk_df';

BEGIN
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
   hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'PER_BUDGET_VALUES'
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
      ,p_attribute20_value  => x_attribute20
      ,p_attribute21_name   => 'ATTRIBUTE21'
      ,p_attribute21_value  => x_attribute21
      ,p_attribute22_name   => 'ATTRIBUTE22'
      ,p_attribute22_value  => x_attribute22
      ,p_attribute23_name   => 'ATTRIBUTE23'
      ,p_attribute23_value  => x_attribute23
      ,p_attribute24_name   => 'ATTRIBUTE24'
      ,p_attribute24_value  => x_attribute24
      ,p_attribute25_name   => 'ATTRIBUTE25'
      ,p_attribute25_value  => x_attribute25
      ,p_attribute26_name   => 'ATTRIBUTE26'
      ,p_attribute26_value  => x_attribute26
      ,p_attribute27_name   => 'ATTRIBUTE27'
      ,p_attribute27_value  => x_attribute27
      ,p_attribute28_name   => 'ATTRIBUTE28'
      ,p_attribute28_value  => x_attribute28
      ,p_attribute29_name   => 'ATTRIBUTE29'
      ,p_attribute29_value  => x_attribute29
      ,p_attribute30_name   => 'ATTRIBUTE30'
      ,p_attribute30_value  => x_attribute30);
 --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 --
END Chk_df;

-- ----------------------------------------------------------------------------
-- |----------------------------< Chk_ddf >------------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Chk_ddf(x_information_category  varchar2
                ,x_information1          varchar2
                ,x_information2          varchar2
                ,x_information3          varchar2
                ,x_information4          varchar2
                ,x_information5          varchar2
                ,x_information6          varchar2
                ,x_information7          varchar2
                ,x_information8          varchar2
                ,x_information9          varchar2
                ,x_information10         varchar2
                ,x_information11         varchar2
                ,x_information12         varchar2
                ,x_information13         varchar2
                ,x_information14         varchar2
                ,x_information15         varchar2
                ,x_information16         varchar2
                ,x_information17         varchar2
                ,x_information18         varchar2
                ,x_information19         varchar2
                ,x_information20         varchar2
                ,x_information21         varchar2
                ,x_information22         varchar2
                ,x_information23         varchar2
                ,x_information24         varchar2
                ,x_information25         varchar2
                ,x_information26         varchar2
                ,x_information27         varchar2
                ,x_information28         varchar2
                ,x_information29         varchar2
                ,x_information30         varchar2) IS

     l_proc   VARCHAR2(72) := g_package||'Chk_ddf';

BEGIN
 --
  hr_utility.set_location('Entering:'||l_proc, 5);
 --
   hr_dflex_utility.ins_or_upd_descflex_attribs
      (p_appl_short_name    => 'PER'
      ,p_descflex_name      => 'Budget Values Developer DF'
      ,p_attribute_category => x_information_category
      ,p_attribute1_name    => 'BUDGET_INFORMATION1'
      ,p_attribute1_value   => x_information1
      ,p_attribute2_name    => 'BUDGET_INFORMATION2'
      ,p_attribute2_value   => x_information2
      ,p_attribute3_name    => 'BUDGET_INFORMATION3'
      ,p_attribute3_value   => x_information3
      ,p_attribute4_name    => 'BUDGET_INFORMATION4'
      ,p_attribute4_value   => x_information4
      ,p_attribute5_name    => 'BUDGET_INFORMATION5'
      ,p_attribute5_value   => x_information5
      ,p_attribute6_name    => 'BUDGET_INFORMATION6'
      ,p_attribute6_value   => x_information6
      ,p_attribute7_name    => 'BUDGET_INFORMATION7'
      ,p_attribute7_value   => x_information7
      ,p_attribute8_name    => 'BUDGET_INFORMATION8'
      ,p_attribute8_value   => x_information8
      ,p_attribute9_name    => 'BUDGET_INFORMATION9'
      ,p_attribute9_value   => x_information9
      ,p_attribute10_name   => 'BUDGET_INFORMATION10'
      ,p_attribute10_value  => x_information10
      ,p_attribute11_name   => 'BUDGET_INFORMATION11'
      ,p_attribute11_value  => x_information11
      ,p_attribute12_name   => 'BUDGET_INFORMATION12'
      ,p_attribute12_value  => x_information12
      ,p_attribute13_name   => 'BUDGET_INFORMATION13'
      ,p_attribute13_value  => x_information13
      ,p_attribute14_name   => 'BUDGET_INFORMATION14'
      ,p_attribute14_value  => x_information14
      ,p_attribute15_name   => 'BUDGET_INFORMATION15'
      ,p_attribute15_value  => x_information15
      ,p_attribute16_name   => 'BUDGET_INFORMATION16'
      ,p_attribute16_value  => x_information16
      ,p_attribute17_name   => 'BUDGET_INFORMATION17'
      ,p_attribute17_value  => x_information17
      ,p_attribute18_name   => 'BUDGET_INFORMATION18'
      ,p_attribute18_value  => x_information18
      ,p_attribute19_name   => 'BUDGET_INFORMATION19'
      ,p_attribute19_value  => x_information19
      ,p_attribute20_name   => 'BUDGET_INFORMATION20'
      ,p_attribute20_value  => x_information20
      ,p_attribute21_name   => 'BUDGET_INFORMATION21'
      ,p_attribute21_value  => x_information21
      ,p_attribute22_name   => 'BUDGET_INFORMATION22'
      ,p_attribute22_value  => x_information22
      ,p_attribute23_name   => 'BUDGET_INFORMATION23'
      ,p_attribute23_value  => x_information23
      ,p_attribute24_name   => 'BUDGET_INFORMATION24'
      ,p_attribute24_value  => x_information24
      ,p_attribute25_name   => 'BUDGET_INFORMATION25'
      ,p_attribute25_value  => x_information25
      ,p_attribute26_name   => 'BUDGET_INFORMATION26'
      ,p_attribute26_value  => x_information26
      ,p_attribute27_name   => 'BUDGET_INFORMATION27'
      ,p_attribute27_value  => x_information27
      ,p_attribute28_name   => 'BUDGET_INFORMATION28'
      ,p_attribute28_value  => x_information28
      ,p_attribute29_name   => 'BUDGET_INFORMATION29'
      ,p_attribute29_value  => x_information29
      ,p_attribute30_name   => 'BUDGET_INFORMATION30'
      ,p_attribute30_value  => x_information30);
 --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 --
END Chk_ddf;


-- ----------------------------------------------------------------------------
-- |---------------------------< Insert_Row >---------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE Insert_Row(x_Rowid                         IN   OUT NOCOPY VARCHAR2,
                     x_Budget_Value_Id               IN   OUT NOCOPY   NUMBER,
                     x_Business_Group_Id             IN       NUMBER,
                     x_Budget_Element_Id             IN       NUMBER,
                     x_Time_Period_Id                IN       NUMBER,
                     x_Value                         IN       NUMBER,
		     x_attribute_category            IN     VARCHAR2,
		     x_attribute1                    IN     VARCHAR2,
                     x_attribute2                    IN     VARCHAR2,
                     x_attribute3                    IN     VARCHAR2,
                     x_attribute4                    IN     VARCHAR2,
                     x_attribute5                    IN     VARCHAR2,
                     x_attribute6                    IN     VARCHAR2,
                     x_attribute7                    IN     VARCHAR2,
                     x_attribute8                    IN     VARCHAR2,
                     x_attribute9                    IN     VARCHAR2,
                     x_attribute10                   IN     VARCHAR2,
                     x_attribute11                   IN     VARCHAR2,
                     x_attribute12                   IN     VARCHAR2,
                     x_attribute13                   IN     VARCHAR2,
                     x_attribute14                   IN     VARCHAR2,
                     x_attribute15                   IN     VARCHAR2,
                     x_attribute16                   IN     VARCHAR2,
                     x_attribute17                   IN     VARCHAR2,
                     x_attribute18                   IN     VARCHAR2,
                     x_attribute19                   IN     VARCHAR2,
                     x_attribute20                   IN     VARCHAR2,
                     x_attribute21                   IN     VARCHAR2,
                     x_attribute22                   IN     VARCHAR2,
                     x_attribute23                   IN     VARCHAR2,
                     x_attribute24                   IN     VARCHAR2,
                     x_attribute25                   IN     VARCHAR2,
                     x_attribute26                   IN     VARCHAR2,
                     x_attribute27                   IN     VARCHAR2,
                     x_attribute28                   IN     VARCHAR2,
                     x_attribute29                   IN     VARCHAR2,
                     x_attribute30                   IN     VARCHAR2,
                     x_information_category          IN     VARCHAR2,
		     x_information1                  IN     VARCHAR2,
                     x_information2                  IN     VARCHAR2,
                     x_information3                  IN     VARCHAR2,
                     x_information4                  IN     VARCHAR2,
                     x_information5                  IN     VARCHAR2,
                     x_information6                  IN     VARCHAR2,
                     x_information7                  IN     VARCHAR2,
                     x_information8                  IN     VARCHAR2,
                     x_information9                  IN     VARCHAR2,
                     x_information10                 IN     VARCHAR2,
                     x_information11                 IN     VARCHAR2,
                     x_information12                 IN     VARCHAR2,
                     x_information13                 IN     VARCHAR2,
                     x_information14                 IN     VARCHAR2,
                     x_information15                 IN     VARCHAR2,
                     x_information16                 IN     VARCHAR2,
                     x_information17                 IN     VARCHAR2,
                     x_information18                 IN     VARCHAR2,
                     x_information19                 IN     VARCHAR2,
                     x_information20                 IN     VARCHAR2,
                     x_information21                 IN     vARCHAR2,
                     x_information22                 IN     VARCHAR2,
                     x_information23                 IN     VARCHAR2,
                     x_information24                 IN     VARCHAR2,
                     x_information25                 IN     VARCHAR2,
                     x_information26                 IN     VARCHAR2,
                     x_information27                 IN     VARCHAR2,
                     x_information28                 IN     VARCHAR2,
                     x_information29                 IN     VARCHAR2,
                     x_information30                 IN     VARCHAR2
 ) IS
   CURSOR C1 IS SELECT rowid FROM per_budget_values
             WHERE budget_value_id = X_Budget_Value_Id;

   CURSOR C2 IS SELECT per_budget_values_s.nextval FROM dual;

   CURSOR C3 IS
   SELECT null
   from per_budget_values pb
   where pb.budget_element_id = x_budget_element_id;

   l_proc                VARCHAR2(72) := g_package||'Insert_Row';
   l_budget_version_id   NUMBER(15);
   l_result              VARCHAR2(255);
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- validate mandatory business_group
  hr_api.validate_bus_grp_id(X_Business_Group_Id);
  --
  -- validate mandatory budget_element_id, and return parent budget_version_id value.
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'budget_element_id',
     p_argument_value => x_Budget_Element_Id);

    chk_budget_element_id(x_budget_element_id,x_business_group_id,l_budget_version_id);
  -- validate mandatory time_period_id
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'time_period_id',
     p_argument_value => x_time_period_id);
  --
  -- Is the parent per_budgets rec 'OTA_BUDGET'
  -- If so, does a per_budget_values rec already exist for the budget_element_id
  -- If so, check many_budget_values flag to see if another per_budget_values record
  -- should be created otherwise raise error.
  IF per_budgets_pkg.chk_OTA_budget_type(NULL,l_budget_version_id,NULL) THEN
    OPEN C3;
    FETCH C3 into l_result;
    IF C3%FOUND THEN
      IF get_many_budget_values(x_business_group_id, l_budget_version_id) = FALSE THEN
        hr_utility.set_message(800,'PER_52865_SINGLE_BDGT_VAL');
        hr_utility.raise_error;
      END IF;
    END IF;
  ELSE
  -- only allow 1 record to exist for the business_group, budget_element_id, and time_period
  -- parent per_budgets record is 'HR_BUDGET' budget_type_code.

   chk_unique(X_Rowid,
             X_Business_Group_id,
             X_Budget_Element_Id,
             X_Time_Period_Id);
  --
  END IF;
  --

  -- validate developer desc flex
  Chk_ddf(x_information_category,
          x_information1,
          x_information2,
          x_information3,
          x_information4,
          x_information5,
          x_information6,
          x_information7,
          x_information8,
          x_information9,
          x_information10,
          x_information11,
          x_information12,
          x_information13,
          x_information14,
          x_information15,
          x_information16,
          x_information17,
          x_information18,
          x_information19,
          x_information20,
          x_information21,
          x_information22,
          x_information23,
          x_information24,
          x_information25,
          x_information26,
          x_information27,
          x_information28,
          x_information29,
          x_information30);

  -- validate desc flex
  Chk_df(x_Attribute_Category,
         x_Attribute1,
         x_Attribute2,
         x_Attribute3,
         x_Attribute4,
         x_Attribute5,
         x_Attribute6,
         x_Attribute7,
         x_Attribute8,
         x_Attribute9,
         x_Attribute10,
         x_Attribute11,
         x_Attribute12,
         x_Attribute13,
         x_Attribute14,
         x_Attribute15,
         x_Attribute16,
         x_Attribute17,
         x_Attribute18,
         x_Attribute19,
         x_Attribute20,
         x_Attribute21,
         x_Attribute22,
         x_Attribute23,
         x_Attribute24,
         x_Attribute25,
         x_Attribute26,
         x_Attribute27,
         x_Attribute28,
         x_Attribute29,
         x_Attribute30);

  OPEN C2;
  FETCH C2 INTO X_Budget_Value_Id;
  CLOSE C2;

  INSERT INTO per_budget_values(
          budget_value_id,
          business_group_id,
          budget_element_id,
          time_period_id,
          value,
          information_category,
          budget_information1,
          budget_information2,
          budget_information3,
          budget_information4,
          budget_information5,
          budget_information6,
          budget_information7,
          budget_information8,
          budget_information9,
          budget_information10,
          budget_information11,
          budget_information12,
          budget_information13,
          budget_information14,
          budget_information15,
          budget_information16,
          budget_information17,
          budget_information18,
          budget_information19,
          budget_information20,
          budget_information21,
          budget_information22,
          budget_information23,
          budget_information24,
          budget_information25,
          budget_information26,
          budget_information27,
          budget_information28,
          budget_information29,
          budget_information30,
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
          attribute21,
          attribute22,
          attribute23,
          attribute24,
          attribute25,
          attribute26,
          attribute27,
          attribute28,
          attribute29,
          attribute30
         ) VALUES (
          x_budget_value_id,
          x_business_group_id,
          x_budget_element_id,
          x_time_period_id,
          x_value,
          x_information_category,
          x_information1,
          x_information2,
          x_information3,
          x_information4,
          x_information5,
          x_information6,
          x_information7,
          x_information8,
          x_information9,
          x_information10,
          x_information11,
          x_information12,
          x_information13,
          x_information14,
          x_information15,
          x_information16,
          x_information17,
          x_information18,
          x_information19,
          x_information20,
          x_information21,
          x_information22,
          x_information23,
          x_information24,
          x_information25,
          x_information26,
          x_information27,
          x_information28,
          x_information29,
          x_information30,
          x_attribute_category,
          x_attribute1,
          x_attribute2,
          x_attribute3,
          x_attribute4,
          x_attribute5,
          x_attribute6,
          x_attribute7,
          x_attribute8,
          x_attribute9,
          x_attribute10,
          x_attribute11,
          x_attribute12,
          x_attribute13,
          x_attribute14,
          x_attribute15,
          x_attribute16,
          x_attribute17,
          x_attribute18,
          x_attribute19,
          x_attribute20,
          x_attribute21,
          x_attribute22,
          x_attribute23,
          x_attribute24,
          x_attribute25,
          x_Attribute26,
          x_attribute27,
          x_attribute28,
          x_attribute29,
          x_attribute30);

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
PROCEDURE   Lock_Row(X_Rowid                         IN     VARCHAR2,
                     X_Budget_Value_Id               IN       NUMBER,
                     X_Business_Group_Id             IN       NUMBER,
                     X_Budget_Element_Id             IN       NUMBER,
                     X_Time_Period_Id                IN       NUMBER,
                     X_Value                         IN       NUMBER,
		     X_attribute_category            IN     VARCHAR2,
		     X_attribute1                    IN     VARCHAR2,
                     X_attribute2                    IN     VARCHAR2,
                     X_attribute3                    IN     VARCHAR2,
                     X_attribute4                    IN     VARCHAR2,
                     X_attribute5                    IN     VARCHAR2,
                     X_attribute6                    IN     VARCHAR2,
                     X_attribute7                    IN     VARCHAR2,
                     X_attribute8                    IN     VARCHAR2,
                     X_attribute9                    IN     VARCHAR2,
                     X_attribute10                   IN     VARCHAR2,
                     X_attribute11                   IN     VARCHAR2,
                     X_attribute12                   IN     VARCHAR2,
                     X_attribute13                   IN     VARCHAR2,
                     X_attribute14                   IN     VARCHAR2,
                     X_attribute15                   IN     VARCHAR2,
                     X_attribute16                   IN     VARCHAR2,
                     X_attribute17                   IN     VARCHAR2,
                     X_attribute18                   IN     VARCHAR2,
                     X_attribute19                   IN     VARCHAR2,
                     X_attribute20                   IN     VARCHAR2,
                     X_attribute21                   IN     VARCHAR2,
                     X_attribute22                   IN     VARCHAR2,
                     X_attribute23                   IN     VARCHAR2,
                     X_attribute24                   IN     VARCHAR2,
                     X_attribute25                   IN     VARCHAR2,
                     X_attribute26                   IN     VARCHAR2,
                     X_attribute27                   IN     VARCHAR2,
                     X_attribute28                   IN     VARCHAR2,
                     X_attribute29                   IN     VARCHAR2,
                     X_attribute30                   IN     VARCHAR2,
                     X_information_category          IN     VARCHAR2,
		     X_information1                  IN     VARCHAR2,
                     X_information2                  IN     VARCHAR2,
                     X_information3                  IN     VARCHAR2,
                     X_information4                  IN     VARCHAR2,
                     X_information5                  IN     VARCHAR2,
                     X_information6                  IN     VARCHAR2,
                     X_information7                  IN     VARCHAR2,
                     X_information8                  IN     VARCHAR2,
                     X_information9                  IN     VARCHAR2,
                     X_information10                 IN     VARCHAR2,
                     X_information11                 IN     VARCHAR2,
                     X_information12                 IN     VARCHAR2,
                     X_information13                 IN     VARCHAR2,
                     X_information14                 IN     VARCHAR2,
                     X_information15                 IN     VARCHAR2,
                     X_information16                 IN     VARCHAR2,
                     X_information17                 IN     VARCHAR2,
                     X_information18                 IN     VARCHAR2,
                     X_information19                 IN     VARCHAR2,
                     X_information20                 IN     VARCHAR2,
                     X_information21                 IN     vARCHAR2,
                     X_information22                 IN     VARCHAR2,
                     X_information23                 IN     VARCHAR2,
                     X_information24                 IN     VARCHAR2,
                     X_information25                 IN     VARCHAR2,
                     X_information26                 IN     VARCHAR2,
                     X_information27                 IN     VARCHAR2,
                     X_information28                 IN     VARCHAR2,
                     X_information29                 IN     VARCHAR2,
                     X_information30                 IN     VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   per_budget_values
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
          (   (Recinfo.budget_value_id = X_Budget_Value_Id)
           OR (    (Recinfo.budget_value_id IS NULL)
               AND (X_Budget_Value_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.budget_element_id = X_Budget_Element_Id)
           OR (    (Recinfo.budget_element_id IS NULL)
               AND (X_Budget_Element_Id IS NULL)))
      AND (   (Recinfo.time_period_id = X_Time_Period_Id)
           OR (    (Recinfo.time_period_id IS NULL)
               AND (X_Time_Period_Id IS NULL)))
      AND (   (Recinfo.value = X_Value)
           OR (    (Recinfo.value IS NULL)
               AND (X_Value IS NULL)))
      AND (   (Recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR (    (Recinfo.ATTRIBUTE_CATEGORY IS NULL)
               AND (X_ATTRIBUTE_CATEGORY IS NULL)))
      AND (   (Recinfo.ATTRIBUTE1  = X_ATTRIBUTE1 )
           OR (    (Recinfo.ATTRIBUTE1  IS NULL)
               AND (X_ATTRIBUTE1  IS NULL)))
      AND (   (Recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR (    (Recinfo.ATTRIBUTE2 IS NULL)
               AND (X_ATTRIBUTE2 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR (    (Recinfo.ATTRIBUTE3 IS NULL)
               AND (X_ATTRIBUTE3 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR (    (Recinfo.ATTRIBUTE4 IS NULL)
               AND (X_ATTRIBUTE4 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR (    (Recinfo.ATTRIBUTE5 IS NULL)
               AND (X_ATTRIBUTE5 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR (    (Recinfo.ATTRIBUTE6 IS NULL)
               AND (X_ATTRIBUTE6 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR (    (Recinfo.ATTRIBUTE7 IS NULL)
               AND (X_ATTRIBUTE7 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR (    (Recinfo.ATTRIBUTE8 IS NULL)
               AND (X_ATTRIBUTE8 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR (    (Recinfo.ATTRIBUTE9 IS NULL)
               AND (X_ATTRIBUTE9 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR (    (Recinfo.ATTRIBUTE10 IS NULL)
               AND (X_ATTRIBUTE10 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR (    (Recinfo.ATTRIBUTE11 IS NULL)
               AND (X_ATTRIBUTE11 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE12  = X_ATTRIBUTE12 )
           OR (    (Recinfo.ATTRIBUTE12  IS NULL)
               AND (X_ATTRIBUTE12  IS NULL)))
      AND (   (Recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR (    (Recinfo.ATTRIBUTE13 IS NULL)
               AND (X_ATTRIBUTE13 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR (    (Recinfo.ATTRIBUTE14 IS NULL)
               AND (X_ATTRIBUTE14 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR (    (Recinfo.ATTRIBUTE15 IS NULL)
               AND (X_ATTRIBUTE15 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
           OR (    (Recinfo.ATTRIBUTE16 IS NULL)
               AND (X_ATTRIBUTE16 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
           OR (    (Recinfo.ATTRIBUTE17 IS NULL)
               AND (X_ATTRIBUTE17 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
           OR (    (Recinfo.ATTRIBUTE18 IS NULL)
               AND (X_ATTRIBUTE18 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
           OR (    (Recinfo.ATTRIBUTE19 IS NULL)
               AND (X_ATTRIBUTE19 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
           OR (    (Recinfo.ATTRIBUTE20 IS NULL)
               AND (X_ATTRIBUTE20 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE21 = X_ATTRIBUTE21)
           OR (    (Recinfo.ATTRIBUTE21 IS NULL)
               AND (X_ATTRIBUTE21 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE22 = X_ATTRIBUTE22)
           OR (    (Recinfo.ATTRIBUTE22 IS NULL)
               AND (X_ATTRIBUTE22 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE23 = X_ATTRIBUTE23)
           OR (    (Recinfo.ATTRIBUTE23 IS NULL)
               AND (X_ATTRIBUTE23 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE24 = X_ATTRIBUTE24)
           OR (    (Recinfo.ATTRIBUTE24 IS NULL)
               AND (X_ATTRIBUTE24 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE25 = X_ATTRIBUTE25)
           OR (    (Recinfo.ATTRIBUTE25 IS NULL)
               AND (X_ATTRIBUTE25 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE26 = X_ATTRIBUTE26)
           OR (    (Recinfo.ATTRIBUTE26 IS NULL)
               AND (X_ATTRIBUTE26 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE27 = X_ATTRIBUTE27)
           OR (    (Recinfo.ATTRIBUTE27 IS NULL)
               AND (X_ATTRIBUTE27 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE28 = X_ATTRIBUTE28)
           OR (    (Recinfo.ATTRIBUTE28 IS NULL)
               AND (X_ATTRIBUTE28 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE29 = X_ATTRIBUTE29)
           OR (    (Recinfo.ATTRIBUTE29 IS NULL)
               AND (X_ATTRIBUTE29 IS NULL)))
      AND (   (Recinfo.ATTRIBUTE30 = X_ATTRIBUTE30)
           OR (    (Recinfo.ATTRIBUTE30 IS NULL)
               AND (X_ATTRIBUTE30 IS NULL)))
      AND (   (Recinfo.INFORMATION_CATEGORY = X_INFORMATION_CATEGORY)
           OR (    (Recinfo.INFORMATION_CATEGORY IS NULL)
               AND (X_INFORMATION_CATEGORY IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION1  = X_INFORMATION1 )
           OR (    (Recinfo.BUDGET_INFORMATION1 IS NULL)
               AND (X_INFORMATION1  IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION2 = X_INFORMATION2)
           OR (    (Recinfo.BUDGET_INFORMATION2 IS NULL)
               AND (X_INFORMATION2 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION3 = X_INFORMATION3)
           OR (    (Recinfo.BUDGET_INFORMATION3 IS NULL)
               AND (X_INFORMATION3 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION4 = X_INFORMATION4)
           OR (    (Recinfo.BUDGET_INFORMATION4 IS NULL)
               AND (X_INFORMATION4 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION5 = X_INFORMATION5)
           OR (    (Recinfo.BUDGET_INFORMATION5 IS NULL)
               AND (X_INFORMATION5 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION6 = X_INFORMATION6)
           OR (    (Recinfo.BUDGET_INFORMATION6 IS NULL)
               AND (X_INFORMATION6 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION7 = X_INFORMATION7)
           OR (    (Recinfo.BUDGET_INFORMATION7 IS NULL)
               AND (X_INFORMATION7 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION8 = X_INFORMATION8)
           OR (    (Recinfo.BUDGET_INFORMATION8 IS NULL)
               AND (X_INFORMATION8 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION9 = X_INFORMATION9)
           OR (    (Recinfo.BUDGET_INFORMATION9 IS NULL)
               AND (X_INFORMATION9 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION10 = X_INFORMATION10)
           OR (    (Recinfo.BUDGET_INFORMATION10 IS NULL)
               AND (X_INFORMATION10 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION11 = X_INFORMATION11)
           OR (    (Recinfo.BUDGET_INFORMATION11 IS NULL)
               AND (X_INFORMATION11 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION12  = X_INFORMATION12 )
           OR (    (Recinfo.BUDGET_INFORMATION12  IS NULL)
               AND (X_INFORMATION12  IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION13 = X_INFORMATION13)
           OR (    (Recinfo.BUDGET_INFORMATION13 IS NULL)
               AND (X_INFORMATION13 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION14 = X_INFORMATION14)
           OR (    (Recinfo.BUDGET_INFORMATION14 IS NULL)
               AND (X_INFORMATION14 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION15 = X_INFORMATION15)
           OR (    (Recinfo.BUDGET_INFORMATION15 IS NULL)
               AND (X_INFORMATION15 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION16 = X_INFORMATION16)
           OR (    (Recinfo.BUDGET_INFORMATION16 IS NULL)
               AND (X_INFORMATION16 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION17 = X_INFORMATION17)
           OR (    (Recinfo.BUDGET_INFORMATION17 IS NULL)
               AND (X_INFORMATION17 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION18 = X_INFORMATION18)
           OR (    (Recinfo.BUDGET_INFORMATION18 IS NULL)
               AND (X_INFORMATION18 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION19 = X_INFORMATION19)
           OR (    (Recinfo.BUDGET_INFORMATION19 IS NULL)
               AND (X_INFORMATION19 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION20 = X_INFORMATION20)
           OR (    (Recinfo.BUDGET_INFORMATION20 IS NULL)
               AND (X_INFORMATION20 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION21 = X_INFORMATION21)
           OR (    (Recinfo.BUDGET_INFORMATION21 IS NULL)
               AND (X_INFORMATION21 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION22  = X_INFORMATION22 )
           OR (    (Recinfo.BUDGET_INFORMATION22  IS NULL)
               AND (X_INFORMATION22  IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION23 = X_INFORMATION23)
           OR (    (Recinfo.BUDGET_INFORMATION23 IS NULL)
               AND (X_INFORMATION23 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION24 = X_INFORMATION24)
           OR (    (Recinfo.BUDGET_INFORMATION24 IS NULL)
               AND (X_INFORMATION24 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION25 = X_INFORMATION25)
           OR (    (Recinfo.BUDGET_INFORMATION25 IS NULL)
               AND (X_INFORMATION25 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION26 = X_INFORMATION26)
           OR (    (Recinfo.BUDGET_INFORMATION26 IS NULL)
               AND (X_INFORMATION26 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION27 = X_INFORMATION27)
           OR (    (Recinfo.BUDGET_INFORMATION27 IS NULL)
               AND (X_INFORMATION27 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION28 = X_INFORMATION28)
           OR (    (Recinfo.BUDGET_INFORMATION28 IS NULL)
               AND (X_INFORMATION28 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION29 = X_INFORMATION29)
           OR (    (Recinfo.BUDGET_INFORMATION29 IS NULL)
               AND (X_INFORMATION29 IS NULL)))
      AND (   (Recinfo.BUDGET_INFORMATION30 = X_INFORMATION30)
           OR (    (Recinfo.BUDGET_INFORMATION30 IS NULL)
               AND (X_INFORMATION30 IS NULL)))
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
PROCEDURE Update_Row(X_Rowid                         IN     VARCHAR2,
                     X_Budget_Value_Id               IN     NUMBER,
                     X_Business_Group_Id             IN     NUMBER,
                     X_Budget_Element_Id             IN     NUMBER,
                     X_Time_Period_Id                IN     NUMBER,
                     X_Value                         IN     NUMBER,
		     X_attribute_category            IN     VARCHAR2,
		     X_attribute1                    IN     VARCHAR2,
                     X_attribute2                    IN     VARCHAR2,
                     X_attribute3                    IN     VARCHAR2,
                     X_attribute4                    IN     VARCHAR2,
                     X_attribute5                    IN     VARCHAR2,
                     X_attribute6                    IN     VARCHAR2,
                     X_attribute7                    IN     VARCHAR2,
                     X_attribute8                    IN     VARCHAR2,
                     X_attribute9                    IN     VARCHAR2,
                     X_attribute10                   IN     VARCHAR2,
                     X_attribute11                   IN     VARCHAR2,
                     X_attribute12                   IN     VARCHAR2,
                     X_attribute13                   IN     VARCHAR2,
                     X_attribute14                   IN     VARCHAR2,
                     X_attribute15                   IN     VARCHAR2,
                     X_attribute16                   IN     VARCHAR2,
                     X_attribute17                   IN     VARCHAR2,
                     X_attribute18                   IN     VARCHAR2,
                     X_attribute19                   IN     VARCHAR2,
                     X_attribute20                   IN     VARCHAR2,
                     X_attribute21                   IN     VARCHAR2,
                     X_attribute22                   IN     VARCHAR2,
                     X_attribute23                   IN     VARCHAR2,
                     X_attribute24                   IN     VARCHAR2,
                     X_attribute25                   IN     VARCHAR2,
                     X_attribute26                   IN     VARCHAR2,
                     X_attribute27                   IN     VARCHAR2,
                     X_attribute28                   IN     VARCHAR2,
                     X_attribute29                   IN     VARCHAR2,
                     X_attribute30                   IN     VARCHAR2,
                     X_information_category          IN     VARCHAR2,
		     X_information1                  IN     VARCHAR2,
                     X_information2                  IN     VARCHAR2,
                     X_information3                  IN     VARCHAR2,
                     X_information4                  IN     VARCHAR2,
                     X_information5                  IN     VARCHAR2,
                     X_information6                  IN     VARCHAR2,
                     X_information7                  IN     VARCHAR2,
                     X_information8                  IN     VARCHAR2,
                     X_information9                  IN     VARCHAR2,
                     X_information10                 IN     VARCHAR2,
                     X_information11                 IN     VARCHAR2,
                     X_information12                 IN     VARCHAR2,
                     X_information13                 IN     VARCHAR2,
                     X_information14                 IN     VARCHAR2,
                     X_information15                 IN     VARCHAR2,
                     X_information16                 IN     VARCHAR2,
                     X_information17                 IN     VARCHAR2,
                     X_information18                 IN     VARCHAR2,
                     X_information19                 IN     VARCHAR2,
                     X_information20                 IN     VARCHAR2,
                     X_information21                 IN     vARCHAR2,
                     X_information22                 IN     VARCHAR2,
                     X_information23                 IN     VARCHAR2,
                     X_information24                 IN     VARCHAR2,
                     X_information25                 IN     VARCHAR2,
                     X_information26                 IN     VARCHAR2,
                     X_information27                 IN     VARCHAR2,
                     X_information28                 IN     VARCHAR2,
                     X_information29                 IN     VARCHAR2,
                     X_information30                 IN     VARCHAR2
) IS

   CURSOR C3 IS
   SELECT null
   from per_budget_values pb
   where pb.budget_element_id = x_budget_element_id;

  l_proc   VARCHAR2(72) := g_package||'Update_Row';
  l_result              VARCHAR2(255);
  l_budget_version_id   NUMBER(15);
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- validate mandatory business_group
    hr_api.validate_bus_grp_id(X_Business_Group_Id);
  --
  -- validate mandatory rowid
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'rowid',
     p_argument_value => x_rowid);

  -- validate mandatory budget_value_id
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'budget_value_id',
     p_argument_value => x_budget_value_id);

  chk_budget_value_id(x_budget_value_id,x_rowid);

  -- validate mandatory budget_element_id, and return parent budget_version_id value.
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'budget_element_id',
     p_argument_value => x_Budget_Element_Id);

    chk_budget_element_id(x_budget_element_id,x_business_group_id,l_budget_version_id);
  -- validate mandatory time_period_id
  hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'time_period_id',
     p_argument_value => x_time_period_id);
  --
  -- Is the parent per_budgets rec 'OTA_BUDGET'
  -- If so, does a per_budget_values rec already exist for the budget_element_id
  -- If so, check many_budget_values flag to see if another per_budget_values record
  -- should be created otherwise raise error.
  IF per_budgets_pkg.chk_OTA_budget_type(NULL,l_budget_version_id,NULL) THEN
    OPEN C3;
    FETCH C3 into l_result;
    IF C3%FOUND THEN
      null;
    END IF;
  ELSE
  -- only allow 1 record to exist for the business_group, budget_element_id, and time_period
  -- parent per_budgets record is 'HR_BUDGET' budget_type_code.

   chk_unique(X_Rowid,
             X_Business_Group_id,
             X_Budget_Element_Id,
             X_Time_Period_Id);
  --
  END IF;


  -- validate developer desc flex
  Chk_ddf(x_information_category,
          x_information1,
          x_information2,
          x_information3,
          x_information4,
          x_information5,
          x_information6,
          x_information7,
          x_information8,
          x_information9,
          x_information10,
          x_information11,
          x_information12,
          x_information13,
          x_information14,
          x_information15,
          x_information16,
          x_information17,
          x_information18,
          x_information19,
          x_information20,
          x_information21,
          x_information22,
          x_information23,
          x_information24,
          x_information25,
          x_information26,
          x_information27,
          x_information28,
          x_information29,
          x_information30);

  -- validate desc flex
  Chk_df(x_Attribute_Category,
         x_Attribute1,
         x_Attribute2,
         x_Attribute3,
         x_Attribute4,
         x_Attribute5,
         x_Attribute6,
         x_Attribute7,
         x_Attribute8,
         x_Attribute9,
         x_Attribute10,
         x_Attribute11,
         x_Attribute12,
         x_Attribute13,
         x_Attribute14,
         x_Attribute15,
         x_Attribute16,
         x_Attribute17,
         x_Attribute18,
         x_Attribute19,
         x_Attribute20,
         x_Attribute21,
         x_Attribute22,
         x_Attribute23,
         x_Attribute24,
         x_Attribute25,
         x_Attribute26,
         x_Attribute27,
         x_Attribute28,
         x_Attribute29,
         x_Attribute30);


  UPDATE per_budget_values
  SET
    budget_value_id                           =    X_Budget_Value_Id,
    business_group_id                         =    X_Business_Group_Id,
    budget_element_id                         =    X_Budget_Element_Id,
    time_period_id                            =    X_Time_Period_Id,
    value                                     =    X_Value,
    attribute_category		              =    X_attribute_category,
    attribute1                                =    X_attribute1,
    attribute2                                =    X_attribute2,
    attribute3                                =    X_attribute3,
    attribute4                                =    X_attribute4,
    attribute5                                =    X_attribute5,
    attribute6                                =    X_attribute6,
    attribute7                                =    X_attribute7,
    attribute8                                =    X_attribute8,
    attribute9                                =    X_attribute9,
    attribute10                               =    X_attribute10,
    attribute11                               =    X_attribute11,
    attribute12                               =    X_attribute12,
    attribute13                               =    X_attribute13,
    attribute14                               =    X_attribute14,
    attribute15                               =    X_attribute15,
    attribute16                               =    X_attribute16,
    attribute17                               =    X_attribute17,
    attribute18                               =    X_attribute18,
    attribute19                               =    X_attribute19,
    attribute20                               =    X_attribute20,
    attribute21                               =    X_attribute21,
    attribute22                               =    X_attribute22,
    attribute23                               =    X_attribute23,
    attribute24                               =    X_attribute24,
    attribute25                               =    X_attribute25,
    attribute26                               =    X_attribute26,
    attribute27                               =    X_attribute27,
    attribute28                               =    X_attribute28,
    attribute29                               =    X_attribute29,
    attribute30                               =    X_attribute30,
    information_category                      =    X_information_category,
    budget_information1	                      =    X_information1,
    budget_information2                       =    X_information2,
    budget_information3                       =    X_information3,
    budget_information4                       =    X_information4,
    budget_information5                       =    X_information5,
    budget_information6                       =    X_information6,
    budget_information7                       =    X_information7,
    budget_information8                       =    X_information8,
    budget_information9                       =    X_information9,
    budget_information10                      =    X_information10,
    budget_information11                      =    X_information11,
    budget_information12                      =    X_information12,
    budget_information13                      =    X_information13,
    budget_information14                      =    X_information14,
    budget_information15                      =    X_information15,
    budget_information16                      =    X_information16,
    budget_information17                      =    X_information17,
    budget_information18                      =    X_information18,
    budget_information19                      =    X_information19,
    budget_information20                      =    X_information20,
    budget_information21                      =    X_information21,
    budget_information22                      =    X_information22,
    budget_information23                      =    X_information23,
    budget_information24                      =    X_information24,
    budget_information25                      =    X_information25,
    budget_information26                      =    X_information26,
    budget_information27                      =    X_information27,
    budget_information28                      =    X_information28,
    budget_information29                      =    X_information29,
    budget_information30                      =    X_information30
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
   l_proc                  VARCHAR2(72) := g_package||'Delete_Row';
   l_count                 NUMBER(7);
   l_budget_version_id     PER_BUDGET_ELEMENTS.BUDGET_VERSION_ID%TYPE;
   l_ele_rowid             VARCHAR2(255) := NULL;

BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine the budget_type of the parent record
  SELECT budget_version_id
  INTO l_budget_version_id
  FROM per_budget_elements
  WHERE budget_element_id = (SELECT budget_element_id
                             FROM per_budget_values
			     WHERE rowid = X_Rowid);
   --
   -- As this is an OTA_BUDGET record, determine how many value
   -- records exist for a parent budget element
   -- If this is the last, then prepare to delete parent budget element.
  IF per_budgets_pkg.chk_OTA_Budget_Type(NULL, l_budget_version_id, NULL) = TRUE THEN
    BEGIN
      SELECT count(rowid)
      INTO l_count
      FROM per_budget_values
      WHERE budget_element_id = (SELECT budget_element_id
                                 FROM per_budget_values
                                 WHERE rowid = X_Rowid);
      --
      IF l_count = 1 THEN
        SELECT rowid
	INTO l_ele_rowid
        FROM per_budget_elements
	WHERE budget_element_id = (SELECT budget_element_id
				   FROM per_budget_values
		                   WHERE rowid = X_Rowid);
      END IF;
    --
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
        hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE','Delete_Row');
        hr_utility.set_message_token('STEP','1');
        hr_utility.raise_error;
    END;
  END IF;
  --
  -- delete the value record
  DELETE FROM per_budget_values
  WHERE  rowid = X_Rowid;
  --
  if (SQL%NOTFOUND) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','Delete_Row');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  --
  -- delete the parent record also
  IF l_ele_rowid IS NOT NULL THEN
    --
    DELETE FROM per_budget_elements
    WHERE  rowid = l_ele_rowid;
    --
    IF (SQL%NOTFOUND) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','Delete_Row');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
    END IF;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
END Delete_Row;

END PER_BUDGET_VALUES_PKG;

/
