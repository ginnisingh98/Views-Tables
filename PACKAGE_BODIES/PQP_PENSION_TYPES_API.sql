--------------------------------------------------------
--  DDL for Package Body PQP_PENSION_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PENSION_TYPES_API" as
/* $Header: pqptyapi.pkb 120.6 2006/12/13 12:10:56 vjhanak noship $ */
--
-- Package Variables
--
g_package       varchar2(50) := '  pqp_pension_types_api.';
g_bg_grp_id     per_business_groups.business_group_id%TYPE;
g_bg_grp_name   per_business_groups.name%TYPE;
g_leg_code      per_business_groups.legislation_code%TYPE;
g_currency_code per_business_groups.currency_code%TYPE;


-- ---------------------------------------------------------------------------
-- |------------------------< Create_EE_Balance >-------------------------|
-- ---------------------------------------------------------------------------
Procedure Create_EE_Balance
  (p_effective_date     in date
  ,p_business_group_id  in number
  ,p_legislation_code   in varchar2
  ,p_pension_type_name  in varchar2
  ,p_ee_balance_typeid  out nocopy number
  ) Is

  Cursor csr_bg Is
   Select currency_code,legislation_code,name
     from per_business_groups_perf
    where business_group_id = p_business_group_id;

  Cursor csr_bal_name(c_balance_name in varchar2) Is
   Select 'x'
     from pay_balance_types
    where balance_name = c_balance_name
      and business_group_id = p_business_group_id;

  Cursor csr_bal_dim ( c_legislation_code in varchar2 ) Is
   Select balance_dimension_id
     from pay_balance_dimensions
    where legislation_code = c_legislation_code
      and database_item_suffix in ('_ASG_ITD',   '_ASG_QTD',
                                   '_ASG_MONTH', '_ASG_PTD',
                                   '_ASG_YTD',   '_ASG_RUN',
				   '_PER_ITD',   '_PER_PTD',
				   '_PER_QTD',   '_PER_YTD'
                                   );

  Cursor csr_get_balance_cat_id(c_category_name in varchar2
                               ,c_legislation_code in varchar2
			       ,c_effective_date in date) Is
   Select balance_category_id
      from pay_balance_categories_f
   where category_name 	= c_category_name
   and legislation_code = c_legislation_code
   and c_effective_date between effective_start_date and effective_end_date;

  l_proc                 varchar2(150) := g_package||'Create_EE_ER_Balances';
  l_bal_name_exists      varchar2(3);
  l_row_id               rowid;
  l_balance_type_id      pay_balance_types.balance_type_id%TYPE;
  l_currency_code        pay_balance_types.currency_code%TYPE;
  l_legislation_code     per_business_groups.legislation_code%TYPE;
  l_balance_name         pay_balance_types.balance_name%TYPE;
  l_reporting_name       pay_balance_types.reporting_name%TYPE;
  l_defined_balance_id   pay_defined_balances.defined_balance_id%TYPE;
  l_balance_dimension_id pay_balance_dimensions.balance_dimension_id%TYPE;
  l_balance_cat_id        pay_balance_categories_f.balance_category_id%TYPE := Null;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if the EE Contribution
  -- balances already exist for the BG
  --
  Open csr_bal_name(c_balance_name => p_pension_type_name ||' EE Contribution');
  Fetch csr_bal_name Into l_bal_name_exists;
  If csr_bal_name%FOUND Then
     close csr_bal_name;
     fnd_message.set_name('PQP', 'PQP_230805_EE_BAL_NAME_EXISTS');
     fnd_message.raise_error;
  End If;
  --
  -- Get the currency code for the business group or leg code
  --
  If p_business_group_id Is Not Null Then
     Open csr_bg;
     fetch csr_bg Into l_currency_code,l_legislation_code,g_bg_grp_name;
     Close csr_bg;
     hr_utility.set_location(' Fetched the currency code :'||l_currency_code,15);
  ElsIf p_legislation_code Is Not Null Then
     l_currency_code    := hr_general.default_currency_code(p_legislation_code);
     l_legislation_code := p_legislation_code;
  Else
     fnd_message.set_name('PQP', 'PQP_230807_INV_BUSGRP_LEGCODE');
     fnd_message.raise_error;
  End If;

  If (l_legislation_code is Not Null and l_legislation_code = 'NL') Then
     l_balance_cat_id := Null;
  End If;

  --
  -- These global variables would be used by other procedures
  --
  g_leg_code      := l_legislation_code;
  g_bg_grp_id     := p_business_group_id;
  g_currency_code := l_currency_code;

  --
  -- Create the EE Contribution balances
  --

      l_balance_name   := p_pension_type_name||' EE Contribution';
      l_reporting_name := l_balance_name;

   hr_utility.set_location(' Creating balance : '||l_balance_name,20);
   Pay_Balance_Types_pkg.Insert_Row
     (x_Rowid                         => l_row_id
     ,x_Balance_Type_Id               => l_balance_type_id
     ,x_Business_Group_Id             => p_business_group_id
     ,x_Legislation_Code              => p_legislation_code
     ,x_Currency_Code                 => l_currency_code
     ,x_Assignment_Remuneration_Flag  => 'N'
     ,x_Balance_Name                  => l_balance_name
     ,x_Base_Balance_Name             => l_balance_name
     ,x_Balance_Uom                   => 'M'
     ,x_Comments                      => Null
     ,x_Legislation_Subgroup          => Null
     ,x_Reporting_Name                => l_reporting_name
     ,x_Attribute_Category            => Null
     ,X_Attribute1                    => Null
     ,x_Attribute2                    => Null
     ,x_Attribute3                    => Null
     ,x_Attribute4                    => Null
     ,x_Attribute5                    => Null
     ,x_Attribute6                    => Null
     ,x_Attribute7                    => Null
     ,x_Attribute8                    => Null
     ,x_Attribute9                    => Null
     ,x_Attribute10                   => Null
     ,x_Attribute11                   => Null
     ,x_Attribute12                   => Null
     ,x_Attribute13                   => Null
     ,x_Attribute14                   => Null
     ,x_Attribute15                   => Null
     ,x_Attribute16                   => Null
     ,x_Attribute17                   => Null
     ,x_Attribute18                   => Null
     ,x_Attribute19                   => Null
     ,x_Attribute20                   => Null
     ,x_balance_category_id           => l_balance_cat_id
     ,x_base_balance_type_id          => Null
     ,x_input_value_id                => Null
     );
    hr_utility.set_location(' Created balance :'||l_balance_name,22);

       p_ee_balance_typeid := l_balance_type_id;

    l_balance_type_id := Null;
    l_row_id := null;

  --
  -- Create the dimensions for the balances.
  --
  hr_utility.set_location(' Creating Defined balances', 25);


      l_balance_type_id  := p_ee_balance_typeid;

   For csr_dim in csr_bal_dim
                   (c_legislation_code => l_legislation_code )
   Loop
     Pay_Defined_Balances_pkg.Insert_Row
       (x_rowid                     => l_row_id
       ,x_defined_balance_id        => l_defined_balance_id
       ,x_business_group_id         => p_business_group_id
       ,x_legislation_code          => p_legislation_code
       ,x_balance_type_id           => l_balance_type_id
       ,x_balance_dimension_id      => csr_dim.balance_dimension_id
       ,x_force_latest_balance_flag => 'N'
       ,x_legislation_subgroup      => null
       ,x_grossup_allowed_flag      => 'N'
       );
       l_row_id := null; l_defined_balance_id := null;
   End Loop;


Exception
  When Others Then
  hr_utility.set_location('Exception in Create_EE_Balance',150);
  raise;

End Create_EE_Balance;


-- ---------------------------------------------------------------------------
-- |------------------------< Create_ER_Balance >-------------------------|
-- ---------------------------------------------------------------------------
Procedure Create_ER_Balance
  (p_effective_date     in date
  ,p_business_group_id  in number
  ,p_legislation_code   in varchar2
  ,p_pension_type_name  in varchar2
  ,p_er_balance_typeid  out nocopy number
  ) Is

  Cursor csr_bg Is
   Select currency_code,legislation_code,name
     from per_business_groups_perf
    where business_group_id = p_business_group_id;

  Cursor csr_bal_name(c_balance_name in varchar2) Is
   Select 'x'
     from pay_balance_types
    where balance_name = c_balance_name
      and business_group_id = p_business_group_id;

  Cursor csr_bal_dim ( c_legislation_code in varchar2 ) Is
   Select balance_dimension_id
     from pay_balance_dimensions
    where legislation_code = c_legislation_code
      and database_item_suffix in ('_ASG_ITD',   '_ASG_QTD',
                                   '_ASG_MONTH', '_ASG_PTD',
                                   '_ASG_YTD',   '_ASG_RUN',
				   '_PER_ITD',   '_PER_PTD',
				   '_PER_QTD',   '_PER_YTD'
                                   );

  Cursor csr_get_balance_cat_id(c_category_name in varchar2
                               ,c_legislation_code in varchar2
			       ,c_effective_date in date) Is
   Select balance_category_id
      from pay_balance_categories_f
   where category_name 	= c_category_name
   and legislation_code = c_legislation_code
   and c_effective_date between effective_start_date and effective_end_date;

  l_proc                 varchar2(150) := g_package||'Create_EE_ER_Balances';
  l_bal_name_exists      varchar2(3);
  l_row_id               rowid;
  l_balance_type_id      pay_balance_types.balance_type_id%TYPE;
  l_currency_code        pay_balance_types.currency_code%TYPE;
  l_legislation_code     per_business_groups.legislation_code%TYPE;
  l_balance_name         pay_balance_types.balance_name%TYPE;
  l_reporting_name       pay_balance_types.reporting_name%TYPE;
  l_defined_balance_id   pay_defined_balances.defined_balance_id%TYPE;
  l_balance_dimension_id pay_balance_dimensions.balance_dimension_id%TYPE;
  l_balance_cat_id        pay_balance_categories_f.balance_category_id%TYPE := Null;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if the ER Contribution
  -- balances already exist for the BG
  --
  Open csr_bal_name(c_balance_name => p_pension_type_name ||' ER Contribution');
  Fetch csr_bal_name Into l_bal_name_exists;
  If csr_bal_name%FOUND Then
     close csr_bal_name;
     fnd_message.set_name('PQP', 'PQP_230805_EE_BAL_NAME_EXISTS');
     fnd_message.raise_error;
  End If;
  --
  -- Get the currency code for the business group or leg code
  --
  If p_business_group_id Is Not Null Then
     Open csr_bg;
     fetch csr_bg Into l_currency_code,l_legislation_code,g_bg_grp_name;
     Close csr_bg;
     hr_utility.set_location(' Fetched the currency code :'||l_currency_code,15);
  ElsIf p_legislation_code Is Not Null Then
     l_currency_code    := hr_general.default_currency_code(p_legislation_code);
     l_legislation_code := p_legislation_code;
  Else
     fnd_message.set_name('PQP', 'PQP_230807_INV_BUSGRP_LEGCODE');
     fnd_message.raise_error;
  End If;

  If (l_legislation_code is Not Null and l_legislation_code = 'NL') Then
     l_balance_cat_id := Null;
  End If;

  --
  -- These global variables would be used by other procedures
  --
  g_leg_code      := l_legislation_code;
  g_bg_grp_id     := p_business_group_id;
  g_currency_code := l_currency_code;

  --
  -- Create the EE Contribution balances
  --

      l_balance_name   := p_pension_type_name||' ER Contribution';
      l_reporting_name := l_balance_name;

   hr_utility.set_location(' Creating balance : '||l_balance_name,20);
   Pay_Balance_Types_pkg.Insert_Row
     (x_Rowid                         => l_row_id
     ,x_Balance_Type_Id               => l_balance_type_id
     ,x_Business_Group_Id             => p_business_group_id
     ,x_Legislation_Code              => p_legislation_code
     ,x_Currency_Code                 => l_currency_code
     ,x_Assignment_Remuneration_Flag  => 'N'
     ,x_Balance_Name                  => l_balance_name
     ,x_Base_Balance_Name             => l_balance_name
     ,x_Balance_Uom                   => 'M'
     ,x_Comments                      => Null
     ,x_Legislation_Subgroup          => Null
     ,x_Reporting_Name                => l_reporting_name
     ,x_Attribute_Category            => Null
     ,X_Attribute1                    => Null
     ,x_Attribute2                    => Null
     ,x_Attribute3                    => Null
     ,x_Attribute4                    => Null
     ,x_Attribute5                    => Null
     ,x_Attribute6                    => Null
     ,x_Attribute7                    => Null
     ,x_Attribute8                    => Null
     ,x_Attribute9                    => Null
     ,x_Attribute10                   => Null
     ,x_Attribute11                   => Null
     ,x_Attribute12                   => Null
     ,x_Attribute13                   => Null
     ,x_Attribute14                   => Null
     ,x_Attribute15                   => Null
     ,x_Attribute16                   => Null
     ,x_Attribute17                   => Null
     ,x_Attribute18                   => Null
     ,x_Attribute19                   => Null
     ,x_Attribute20                   => Null
     ,x_balance_category_id           => l_balance_cat_id
     ,x_base_balance_type_id          => Null
     ,x_input_value_id                => Null
     );
    hr_utility.set_location(' Created balance :'||l_balance_name,22);

       p_er_balance_typeid := l_balance_type_id;

    l_balance_type_id := Null;
    l_row_id := null;

  --
  -- Create the dimensions for the balances.
  --
  hr_utility.set_location(' Creating Defined balances', 25);


      l_balance_type_id  := p_er_balance_typeid;

   For csr_dim in csr_bal_dim
                   (c_legislation_code => l_legislation_code )
   Loop
     Pay_Defined_Balances_pkg.Insert_Row
       (x_rowid                     => l_row_id
       ,x_defined_balance_id        => l_defined_balance_id
       ,x_business_group_id         => p_business_group_id
       ,x_legislation_code          => p_legislation_code
       ,x_balance_type_id           => l_balance_type_id
       ,x_balance_dimension_id      => csr_dim.balance_dimension_id
       ,x_force_latest_balance_flag => 'N'
       ,x_legislation_subgroup      => null
       ,x_grossup_allowed_flag      => 'N'
       );
       l_row_id := null; l_defined_balance_id := null;
   End Loop;


Exception
  When Others Then
  hr_utility.set_location('Exception in Create_ER_Balance',150);
  raise;

End Create_ER_Balance;
--
-- ---------------------------------------------------------------------------
-- |------------------------< Create_EE_ER_Balances >-------------------------|
-- ---------------------------------------------------------------------------
Procedure Create_EE_ER_Balances
  (p_effective_date     in date
  ,p_business_group_id  in number
  ,p_legislation_code   in varchar2
  ,p_pension_type_name  in varchar2
  ,p_ee_balance_typeid  out nocopy number
  ,p_er_balance_typeid  out nocopy number
  ) Is

  Cursor csr_bg Is
   Select currency_code,legislation_code,name
     from per_business_groups_perf
    where business_group_id = p_business_group_id;

  Cursor csr_bal_name(c_balance_name in varchar2) Is
   Select 'x'
     from pay_balance_types
    where balance_name = c_balance_name
      and business_group_id = p_business_group_id;

  Cursor csr_bal_dim ( c_legislation_code in varchar2 ) Is
   Select balance_dimension_id
     from pay_balance_dimensions
    where legislation_code = c_legislation_code
      and database_item_suffix in ('_ASG_ITD',   '_ASG_QTD',
                                   '_ASG_MONTH', '_ASG_PTD',
                                   '_ASG_YTD',   '_ASG_RUN',
				   '_PER_ITD',   '_PER_PTD',
				   '_PER_QTD',   '_PER_YTD'
                                   );

  Cursor csr_get_balance_cat_id(c_category_name in varchar2
                               ,c_legislation_code in varchar2
			       ,c_effective_date in date) Is
   Select balance_category_id
      from pay_balance_categories_f
   where category_name 	= c_category_name
   and legislation_code = c_legislation_code
   and c_effective_date between effective_start_date and effective_end_date;

  l_proc                 varchar2(150) := g_package||'Create_EE_ER_Balances';
  l_bal_name_exists      varchar2(3);
  l_row_id               rowid;
  l_balance_type_id      pay_balance_types.balance_type_id%TYPE;
  l_currency_code        pay_balance_types.currency_code%TYPE;
  l_legislation_code     per_business_groups.legislation_code%TYPE;
  l_balance_name         pay_balance_types.balance_name%TYPE;
  l_reporting_name       pay_balance_types.reporting_name%TYPE;
  l_defined_balance_id   pay_defined_balances.defined_balance_id%TYPE;
  l_balance_dimension_id pay_balance_dimensions.balance_dimension_id%TYPE;
  l_balance_cat_id        pay_balance_categories_f.balance_category_id%TYPE := Null;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check if the EE Contribution and ER Contribution
  -- balances already exist for the BG
  --
  Open csr_bal_name(c_balance_name => p_pension_type_name ||' EE Contribution');
  Fetch csr_bal_name Into l_bal_name_exists;
  If csr_bal_name%FOUND Then
     close csr_bal_name;
     fnd_message.set_name('PQP', 'PQP_230805_EE_BAL_NAME_EXISTS');
     fnd_message.raise_error;
  Else
   close csr_bal_name;
    Open csr_bal_name(c_balance_name => p_pension_type_name ||' ER Contribution');
    Fetch csr_bal_name Into l_bal_name_exists;
    If csr_bal_name%FOUND Then
     close csr_bal_name;
     fnd_message.set_name('PQP', 'PQP_230806_ER_BAL_NAME_EXISTS');
     fnd_message.raise_error;
    End If;
    close csr_bal_name;
  End If;
  --
  -- Get the currency code for the business group or leg code
  --
  If p_business_group_id Is Not Null Then
     Open csr_bg;
     fetch csr_bg Into l_currency_code,l_legislation_code,g_bg_grp_name;
     Close csr_bg;
     hr_utility.set_location(' Fetched the currency code :'||l_currency_code,15);
  ElsIf p_legislation_code Is Not Null Then
     l_currency_code    := hr_general.default_currency_code(p_legislation_code);
     l_legislation_code := p_legislation_code;
  Else
     fnd_message.set_name('PQP', 'PQP_230807_INV_BUSGRP_LEGCODE');
     fnd_message.raise_error;
  End If;

  --
  --Get the balance category id for 'Other Deductions' category (UK pensions only)
  --
  If (l_legislation_code is Not Null and l_legislation_code = 'GB') Then
     Open csr_get_balance_cat_id(c_category_name  => 'Other Deductions'
                                                     ,c_legislation_code => 'GB'
                                                     ,c_effective_date    => p_effective_date);
     Fetch csr_get_balance_cat_id into l_balance_cat_id;
     close csr_get_balance_cat_id;
     hr_utility.set_location('Fetched the category id :'||l_balance_cat_id,17);
  ElsIf (l_legislation_code is Not Null and l_legislation_code = 'NL') Then
     l_balance_cat_id := Null;
  End If;

  --
  -- These global variables would be used by other procedures
  --
  g_leg_code      := l_legislation_code;
  g_bg_grp_id     := p_business_group_id;
  g_currency_code := l_currency_code;
  --
  -- Create the EE and ER Contribution balances
  --
  For i in 1..2 Loop
   If i = 1 Then
      l_balance_name   := p_pension_type_name||' EE Contribution';
      l_reporting_name := l_balance_name;
   Else
      l_balance_name   := p_pension_type_name||' ER Contribution';
      l_reporting_name := l_balance_name;
   End if;
   hr_utility.set_location(' Creating balance : '||l_balance_name,20);
   Pay_Balance_Types_pkg.Insert_Row
     (x_Rowid                         => l_row_id
     ,x_Balance_Type_Id               => l_balance_type_id
     ,x_Business_Group_Id             => p_business_group_id
     ,x_Legislation_Code              => p_legislation_code
     ,x_Currency_Code                 => l_currency_code
     ,x_Assignment_Remuneration_Flag  => 'N'
     ,x_Balance_Name                  => l_balance_name
     ,x_Base_Balance_Name             => l_balance_name
     ,x_Balance_Uom                   => 'M'
     ,x_Comments                      => Null
     ,x_Legislation_Subgroup          => Null
     ,x_Reporting_Name                => l_reporting_name
     ,x_Attribute_Category            => Null
     ,X_Attribute1                    => Null
     ,x_Attribute2                    => Null
     ,x_Attribute3                    => Null
     ,x_Attribute4                    => Null
     ,x_Attribute5                    => Null
     ,x_Attribute6                    => Null
     ,x_Attribute7                    => Null
     ,x_Attribute8                    => Null
     ,x_Attribute9                    => Null
     ,x_Attribute10                   => Null
     ,x_Attribute11                   => Null
     ,x_Attribute12                   => Null
     ,x_Attribute13                   => Null
     ,x_Attribute14                   => Null
     ,x_Attribute15                   => Null
     ,x_Attribute16                   => Null
     ,x_Attribute17                   => Null
     ,x_Attribute18                   => Null
     ,x_Attribute19                   => Null
     ,x_Attribute20                   => Null
     ,x_balance_category_id           => l_balance_cat_id
     ,x_base_balance_type_id          => Null
     ,x_input_value_id                => Null
     );
    hr_utility.set_location(' Created balance :'||l_balance_name,22);
    If i = 1 Then
       p_ee_balance_typeid := l_balance_type_id;
    Else
       p_er_balance_typeid := l_balance_type_id;
    End If;
    l_balance_type_id := Null;
    l_row_id := null;
  End Loop;
  --
  -- Create the dimensions for the balances.
  --
  hr_utility.set_location(' Creating Defined balances', 25);
  For i in 1..2 Loop
   If i = 1 Then
      l_balance_type_id  := p_ee_balance_typeid;
   Else
      l_balance_type_id  := p_er_balance_typeid;
   End if;
   For csr_dim in csr_bal_dim
                   (c_legislation_code => l_legislation_code )
   Loop
     Pay_Defined_Balances_pkg.Insert_Row
       (x_rowid                     => l_row_id
       ,x_defined_balance_id        => l_defined_balance_id
       ,x_business_group_id         => p_business_group_id
       ,x_legislation_code          => p_legislation_code
       ,x_balance_type_id           => l_balance_type_id
       ,x_balance_dimension_id      => csr_dim.balance_dimension_id
       ,x_force_latest_balance_flag => 'N'
       ,x_legislation_subgroup      => null
       ,x_grossup_allowed_flag      => 'N'
       );
       l_row_id := null; l_defined_balance_id := null;
   End Loop;
  End Loop;

Exception
  When Others Then
  hr_utility.set_location('Exception in Create_EE_ER_Balances',150);
  raise;

End Create_EE_ER_Balances;

--
-- ---------------------------------------------------------------------------
-- |------------------------< Create_ABP_EE_ER_Balances >---------------------|
-- ---------------------------------------------------------------------------
Procedure Create_ABP_EE_ER_Balances
  (p_effective_date       in date
  ,p_business_group_id    in number
  ,p_legislation_code     in varchar2
  ,p_pension_sub_cat      in varchar2
  ,p_ee_balance_typeid    out nocopy number
  ,p_er_balance_typeid    out nocopy number
  ) Is

  Cursor csr_bg Is
   Select currency_code,legislation_code,name
     from per_business_groups_perf
    where business_group_id = p_business_group_id;

  Cursor csr_bal_typ_id(c_balance_name in varchar2) Is
   Select balance_type_id
     from pay_balance_types
    where balance_name = c_balance_name
      and business_group_id = p_business_group_id;

  Cursor csr_bal_dim ( c_legislation_code in varchar2 ) Is
   Select balance_dimension_id
     from pay_balance_dimensions
    where legislation_code = c_legislation_code
      and database_item_suffix in ('_ASG_ITD',   '_ASG_QTD',
                                   '_ASG_MONTH', '_ASG_PTD',
                                   '_ASG_YTD',   '_ASG_RUN',
				   '_PER_ITD',   '_PER_PTD',
				   '_PER_QTD',   '_PER_YTD'
                                   );

  l_proc                 varchar2(150) := g_package||'Create_ABP_EE_ER_Balances';
  l_row_id               rowid;
  l_balance_type_id      pay_balance_types.balance_type_id%TYPE;
  l_currency_code        pay_balance_types.currency_code%TYPE;
  l_legislation_code     per_business_groups.legislation_code%TYPE;
  l_balance_name         pay_balance_types.balance_name%TYPE;
  l_reporting_name       pay_balance_types.reporting_name%TYPE;
  l_defined_balance_id   pay_defined_balances.defined_balance_id%TYPE;
  l_balance_dimension_id pay_balance_dimensions.balance_dimension_id%TYPE;
  l_pension_sub_cat      varchar2(80) := '';
  l_balance_cat_id       pay_balance_categories_f.balance_category_id%TYPE;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  -- First construct the EE and ER sub category level balance names
  If p_pension_sub_cat IS NOT NULL THEN

     Select DECODE(p_pension_sub_cat
                   ,'OPNP','OPNP'
                   ,'OPNP_65','OPNP65'
                   ,'OPNP_AOW','OPNPAOW'
                   ,'OPNP_W25','OPNPW25'
                   ,'OPNP_W50','OPNPW50'
                   ,'FPU_E','FPU Extra'
                   ,'FPU_R','FPU Raise'
                   ,'FPU_S','FPU Standard'
                   ,'FPU_T','FPU Total'
                   ,'FUR_S','FUR Standard'
                   ,'IPAP','IPAP'
                   ,'IPBW_H','IPBW High'
                   ,'IPBW_L','IPBW Low'
                   ,'VSG','VSG'
                   ,'FPU_B','FPU Base'
                   ,'FPU_C','FPU Composition'
                   ,'PPP','Partner Plus Pension'
		   ,'FPB','FP Basis'
		   ,'AAOP','ABP Disability'
                   ,l_pension_sub_cat)
            INTO l_pension_sub_cat
        From dual;
     --
     -- Get the currency code for the business group or leg code
     --
     If p_business_group_id Is Not Null Then
        Open csr_bg;
        fetch csr_bg Into l_currency_code,l_legislation_code,g_bg_grp_name;
        Close csr_bg;
        hr_utility.set_location(' Fetched the currency code :'||l_currency_code,15);
     ElsIf p_legislation_code Is Not Null Then
        l_currency_code    := hr_general.default_currency_code(p_legislation_code);
        l_legislation_code := p_legislation_code;
     Else
        fnd_message.set_name('PQP', 'PQP_230807_INV_BUSGRP_LEGCODE');
        fnd_message.raise_error;
     End If;

     --
     -- These global variables would be used by other procedures
     --
     g_leg_code      := l_legislation_code;
     g_bg_grp_id     := p_business_group_id;
     g_currency_code := l_currency_code;

     -- only for NL Pensions the balances need to be created
     If l_legislation_code is Not Null AND l_legislation_code = 'NL' THEN

        --
        -- Create the EE and ER Contribution balances
        --
        For i in 1..2 Loop
         If i = 1 Then
            l_balance_name   := l_pension_sub_cat||' EE Contribution';
            l_reporting_name := l_balance_name;
         Else
            l_balance_name   := l_pension_sub_cat||' ER Contribution';
            l_reporting_name := l_balance_name;
         End if;

         -- if the balance already exists, dont create it, return the bal type id
         Open csr_bal_typ_id(l_balance_name);
         Fetch csr_bal_typ_id INTO l_balance_type_id;

         If csr_bal_typ_id%FOUND THEN
            Close csr_bal_typ_Id;
            If i = 1 Then

               p_ee_balance_typeid := l_balance_type_id;

            Else

               p_er_balance_typeid := l_balance_type_id;

            End If;

         Else
            Close csr_bal_typ_id;

            hr_utility.set_location(' Creating balance : '||l_balance_name,20);
            Pay_Balance_Types_pkg.Insert_Row
              (x_Rowid                         => l_row_id
              ,x_Balance_Type_Id               => l_balance_type_id
              ,x_Business_Group_Id             => p_business_group_id
              ,x_Legislation_Code              => p_legislation_code
              ,x_Currency_Code                 => l_currency_code
              ,x_Assignment_Remuneration_Flag  => 'N'
              ,x_Balance_Name                  => l_balance_name
              ,x_Base_Balance_Name             => l_balance_name
              ,x_Balance_Uom                   => 'M'
              ,x_Comments                      => Null
              ,x_Legislation_Subgroup          => Null
              ,x_Reporting_Name                => l_reporting_name
              ,x_Attribute_Category            => Null
              ,X_Attribute1                    => Null
              ,x_Attribute2                    => Null
              ,x_Attribute3                    => Null
              ,x_Attribute4                    => Null
              ,x_Attribute5                    => Null
              ,x_Attribute6                    => Null
              ,x_Attribute7                    => Null
              ,x_Attribute8                    => Null
              ,x_Attribute9                    => Null
              ,x_Attribute10                   => Null
              ,x_Attribute11                   => Null
              ,x_Attribute12                   => Null
              ,x_Attribute13                   => Null
              ,x_Attribute14                   => Null
              ,x_Attribute15                   => Null
              ,x_Attribute16                   => Null
              ,x_Attribute17                   => Null
              ,x_Attribute18                   => Null
              ,x_Attribute19                   => Null
              ,x_Attribute20                   => Null
              ,x_balance_category_id           => l_balance_cat_id
              ,x_base_balance_type_id          => Null
              ,x_input_value_id                => Null
              );
             hr_utility.set_location(' Created balance :'||l_balance_name,22);
             If i = 1 Then
                p_ee_balance_typeid := l_balance_type_id;
             Else
                p_er_balance_typeid := l_balance_type_id;
             End If;

             --
             -- Create the dimensions for the balances.
             --
             hr_utility.set_location(' Creating Defined balances', 25);
             If i = 1 Then
               l_balance_type_id  := p_ee_balance_typeid;
             Else
               l_balance_type_id  := p_er_balance_typeid;
             End if;
             For csr_dim in csr_bal_dim
                            (c_legislation_code => l_legislation_code )
             Loop
               Pay_Defined_Balances_pkg.Insert_Row
                (x_rowid                     => l_row_id
                ,x_defined_balance_id        => l_defined_balance_id
                ,x_business_group_id         => p_business_group_id
                ,x_legislation_code          => p_legislation_code
                ,x_balance_type_id           => l_balance_type_id
                ,x_balance_dimension_id      => csr_dim.balance_dimension_id
                ,x_force_latest_balance_flag => 'N'
                ,x_legislation_subgroup      => null
                ,x_grossup_allowed_flag      => 'N'
                );
              l_row_id := null; l_defined_balance_id := null;
            End Loop;

        End If;
        l_balance_type_id := Null;
        l_row_id := null;

     End Loop;

   End If; /* end of chk for NL*/
 End If; /* end of chk for non null sub category*/
Exception
  When Others Then
  hr_utility.set_location('Exception in Create_ABP_EE_ER_Balances',150);
  raise;

End Create_ABP_EE_ER_Balances;

-- ----------------------------------------------------------------------------
-- |------------------------< Create_Balance_Init_Ele >------------------------|
-- ----------------------------------------------------------------------------
Procedure Create_Balance_Init_Ele
  (p_effective_date                in date
  ,p_business_group_id             in number
  ,p_legislation_code              in varchar2
  ,p_pension_type_name             in varchar2
  ,p_pension_sub_cat               in varchar2
  ,p_balance_init_element_type_id  out nocopy number
  ) Is

  Cursor csr_bal_type (c_balance_name in varchar2) Is
   Select balance_type_id
     from pay_balance_types
    where balance_name       = c_balance_name
      and (business_group_id = p_business_group_id
           or
           legislation_code  = g_leg_code);

  Type Bal_feeds_Rec Is Record
         (balance_type_id        Number
         ,input_value_id         Number
         );
  Type Bal_feeds_info Is Table Of Bal_feeds_Rec
                      Index By Binary_Integer;

  l_balfeeds_tab         Bal_feeds_info;
  l_row_id               rowid;
  l_count                number :=0;
  l_proc                 varchar2(150) := g_package||'Create_Balance_Init_Ele';
  l_balance_feed_Id      pay_balance_feeds_f.balance_feed_id%TYPE;
  l_ipv_ee_contr         pay_input_values_f.input_value_id%TYPE;
  l_ipv_er_contr         pay_input_values_f.input_value_id%TYPE;
  l_business_group_name  per_business_groups.name%TYPE;
  l_pension_sub_cat_mean varchar2(80) := '';

Begin
    hr_utility.set_location(' Entering:'|| l_proc, 10);
    l_business_group_name := g_bg_grp_name;

    hr_utility.set_location(' Setting the session date to :'||p_effective_date,11);
    pay_db_pay_setup.set_session_date(nvl(p_effective_date, trunc(sysdate)));

    hr_utility.set_location(' Creating the balance initialization element', 15);
    p_balance_init_element_type_id :=
         pay_db_pay_setup.create_element
                ( p_element_name          => 'Setup '||p_pension_type_name ||' Contribution Element'
                 ,p_description           => 'Element for initializing '||p_pension_type_name||' balances'
                 ,p_classification_name   => 'Balance Initialization'
                 ,p_post_termination_rule => 'Last Standard Process'
                 ,p_mult_entries_allowed  => 'Y'
                 ,p_adjustment_only_flag  => 'Y'
                 ,p_third_party_pay_only  => NULL
                 ,p_processing_type       => 'N'
                 ,p_processing_priority   =>  0
                 ,p_standard_link_flag    => 'N'
                 ,p_business_group_name   => l_business_group_name
                 ,p_legislation_code      => p_legislation_code
                 ,p_effective_start_date  => p_effective_date
                 ,p_effective_end_date    => hr_api.g_eot
                 );

    hr_utility.set_location(' Creating input value EE Contribution', 20);
    l_ipv_ee_contr := pay_db_pay_setup.create_input_value
                 (
                  p_element_name          => 'Setup '||p_pension_type_name ||' Contribution Element'
                 ,p_name                  => 'EE Contribution'
                 ,p_uom_code              => 'M'
                 ,p_mandatory_flag        => 'N'
                 ,p_display_sequence      => 1
                 ,p_business_group_name   => l_business_group_name
                 ,p_effective_start_date  => p_effective_date
                 ,p_effective_end_date    => hr_api.g_eot
                 ,p_legislation_code      => p_legislation_code
                 );
    hr_utility.set_location(' Creating input value ER Contribution', 25);
    l_ipv_er_contr := pay_db_pay_setup.create_input_value
                 (
                  p_element_name          => 'Setup '||p_pension_type_name ||' Contribution Element'
                 ,p_name                  => 'ER Contribution'
                 ,p_uom_code              => 'M'
                 ,p_mandatory_flag        => 'N'
                 ,p_display_sequence      => 2
                 ,p_business_group_name   => l_business_group_name
                 ,p_effective_start_date  => p_effective_date
                 ,p_effective_end_date    => hr_api.g_eot
                 ,p_legislation_code      => p_legislation_code
                 );

    If p_pension_sub_cat IS NOT NULL THEN
       Select DECODE(p_pension_sub_cat
                     ,'OPNP','OPNP'
                     ,'OPNP_65','OPNP65'
                     ,'OPNP_AOW','OPNPAOW'
                     ,'OPNP_W25','OPNPW25'
                     ,'OPNP_W50','OPNPW50'
                     ,'FPU_E','FPU Extra'
                     ,'FPU_R','FPU Raise'
                     ,'FPU_S','FPU Standard'
                     ,'FPU_T','FPU Total'
                     ,'FUR_S','FUR Standard'
                     ,'IPAP','IPAP'
                     ,'IPBW_H','IPBW High'
                     ,'IPBW_L','IPBW Low'
                     ,'VSG','VSG'
                     ,'FPU_B','FPU Base'
                     ,'FPU_C','FPU Composition'
                     ,'PPP','Partner Plus Pension'
		     ,'FPB','FP Basis'
                     ,l_pension_sub_cat_mean)
             INTO l_pension_sub_cat_mean
         From dual;
    End If;

    If p_pension_sub_cat IS NULL THEN
       For c_rec in csr_bal_type
        (c_balance_name => p_pension_type_name ||' ER Contribution')
       Loop
         l_count := l_count + 1 ;
         l_balfeeds_tab(l_count).balance_type_id := c_rec.balance_type_id;
         l_balfeeds_tab(l_count).input_value_id  := l_ipv_er_contr;
       End Loop;
    Else
       For c_rec in csr_bal_type
        (c_balance_name => l_pension_sub_cat_mean ||' ER Contribution')
       Loop
         l_count := l_count + 1 ;
         l_balfeeds_tab(l_count).balance_type_id := c_rec.balance_type_id;
         l_balfeeds_tab(l_count).input_value_id  := l_ipv_er_contr;
       End Loop;
    End If;

    For c_rec in csr_bal_type
     (c_balance_name => 'Employer Pension Contribution')
    Loop
      l_count := l_count + 1 ;
      l_balfeeds_tab(l_count).balance_type_id := c_rec.balance_type_id;
      l_balfeeds_tab(l_count).input_value_id  := l_ipv_er_contr;
      hr_utility.set_location(' Found seeded balance ER Pension Contribution',30);
    End Loop;

    If p_pension_sub_cat IS NULL THEN
       For c_rec in csr_bal_type
        (c_balance_name => p_pension_type_name ||' EE Contribution')
       Loop
         l_count := l_count + 1 ;
         l_balfeeds_tab(l_count).balance_type_id := c_rec.balance_type_id;
         l_balfeeds_tab(l_count).input_value_id  := l_ipv_ee_contr;
       End Loop;
    Else
       For c_rec in csr_bal_type
        (c_balance_name => l_pension_sub_cat_mean ||' EE Contribution')
       Loop
         l_count := l_count + 1 ;
         l_balfeeds_tab(l_count).balance_type_id := c_rec.balance_type_id;
         l_balfeeds_tab(l_count).input_value_id  := l_ipv_ee_contr;
       End Loop;
    End If;

    For c_rec in csr_bal_type
     (c_balance_name => 'Employee Pension Contribution')
    Loop
      l_count := l_count + 1 ;
      l_balfeeds_tab(l_count).balance_type_id := c_rec.balance_type_id;
      l_balfeeds_tab(l_count).input_value_id  := l_ipv_ee_contr;
      hr_utility.set_location(' Found seeded balance EE Pension Contribution',35);
    End Loop;

    hr_utility.set_location(' Creating input value ER,EE Contribution, balance feeds', 40);
    For i in 1..l_count Loop
      Pay_Balance_Feeds_f_pkg.Insert_Row(
          X_Rowid                => l_row_id,
          X_Balance_Feed_Id      => l_Balance_Feed_Id,
          X_Effective_Start_Date => p_effective_date,
          X_Effective_End_Date   => hr_api.g_eot,
          X_Business_Group_Id    => p_business_group_id,
          X_Legislation_Code     => p_legislation_code,
          X_Balance_Type_Id      => l_balfeeds_tab(i).balance_type_id,
          X_Input_Value_Id       => l_balfeeds_tab(i).input_value_id,
          X_Scale                => '1',
          X_Legislation_Subgroup => Null,
          X_Initial_Balance_Feed => false );

          l_Balance_Feed_Id := Null;
          l_row_id          := Null;
    End Loop;
    hr_utility.set_location(' Leaving:'|| l_proc, 80);

Exception
  When Others Then
  hr_utility.set_location('Exception in Create_Balance_Init_Ele',150);
  raise;

End Create_Balance_Init_Ele;

-- ----------------------------------------------------------------------------
-- |------------------------< chk_pension_type_name >------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_pension_type_name
  (p_pension_type_name_in  in varchar2
  ) IS

element_name varchar2(100) := p_pension_type_name_in;
l_output     varchar2(100);
l_rgeflg     varchar2(100);

begin

   -- Check if the pension type name has any special chars
   hr_chkfmt.checkformat
   (
      value   => element_name,
      format  => 'PAY_NAME',
      output  => l_output,
      minimum => NULL,
      maximum => NULL,
      nullok  => 'N',
      rgeflg  => l_rgeflg,
      curcode => NULL
   );

EXCEPTION

WHEN OTHERS THEN
  fnd_message.set_name('PQP', 'PQP_230922_PEN_TYPE_NAME_ERR');
  fnd_message.raise_error;

END chk_pension_type_name;

-- ----------------------------------------------------------------------------
-- |------------------------< chk_dup_pension_type >--------------------------|
-- ----------------------------------------------------------------------------
Procedure chk_dup_pension_type
  (p_pension_type_name_in  in varchar2
  ,p_bg_id                 in number
  ) IS

-- Cursor to check if the pension type already exists
CURSOR csr_pension_type IS
SELECT 'x'
  FROM pqp_pension_types_f
 WHERE pension_type_name = p_pension_type_name_in
   AND business_group_id = p_bg_id
   AND rownum = 1;

l_dummy      varchar2(1);

begin

   -- Check if the pension type already exists
   OPEN csr_pension_type;
   FETCH csr_pension_type INTO l_dummy;
     IF csr_pension_type%FOUND THEN
        CLOSE csr_pension_type;
        fnd_message.set_name('PQP', 'PQP_230813_PEN_TYPE_EXISTS');
        fnd_message.raise_error;
     ELSE
        CLOSE csr_pension_type;
     END IF;

END chk_dup_pension_type;

-- ----------------------------------------------------------------------------
-- |--------------------------< Create_Pension_Type >--------------------------|
-- ----------------------------------------------------------------------------
--
Procedure Create_Pension_Type
  (p_validate                     in     Boolean
  ,p_effective_date               in     date
  ,p_pension_type_name            in     varchar2
  ,p_pension_category             in     varchar2
  ,p_pension_provider_type        in     varchar2
  ,p_salary_calculation_method    in     varchar2
  ,p_threshold_conversion_rule    in     varchar2
  ,p_contribution_conversion_rule in     varchar2
  ,p_er_annual_limit              in     number
  ,p_ee_annual_limit              in     number
  ,p_er_annual_salary_threshold   in     number
  ,p_ee_annual_salary_threshold   in     number
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_description                  in     varchar2
  ,p_minimum_age                  in     number
  ,p_ee_contribution_percent      in     number
  ,p_maximum_age                  in     number
  ,p_er_contribution_percent      in     number
  ,p_ee_annual_contribution       in     number
  ,p_er_annual_contribution       in     number
  ,p_annual_premium_amount        in     number
  ,p_ee_contribution_bal_type_id  in     number
  ,p_er_contribution_bal_type_id  in     number
  ,p_balance_init_element_type_id in     number
  ,p_ee_contribution_fixed_rate   in     number --added for UK
  ,p_er_contribution_fixed_rate   in     number --added for UK
  ,p_pty_attribute_category       in     varchar2
  ,p_pty_attribute1               in     varchar2
  ,p_pty_attribute2               in     varchar2
  ,p_pty_attribute3               in     varchar2
  ,p_pty_attribute4               in     varchar2
  ,p_pty_attribute5               in     varchar2
  ,p_pty_attribute6               in     varchar2
  ,p_pty_attribute7               in     varchar2
  ,p_pty_attribute8               in     varchar2
  ,p_pty_attribute9               in     varchar2
  ,p_pty_attribute10              in     varchar2
  ,p_pty_attribute11              in     varchar2
  ,p_pty_attribute12              in     varchar2
  ,p_pty_attribute13              in     varchar2
  ,p_pty_attribute14              in     varchar2
  ,p_pty_attribute15              in     varchar2
  ,p_pty_attribute16              in     varchar2
  ,p_pty_attribute17              in     varchar2
  ,p_pty_attribute18              in     varchar2
  ,p_pty_attribute19              in     varchar2
  ,p_pty_attribute20              in     varchar2
  ,p_pty_information_category     in     varchar2
  ,p_pty_information1             in     varchar2
  ,p_pty_information2             in     varchar2
  ,p_pty_information3             in     varchar2
  ,p_pty_information4             in     varchar2
  ,p_pty_information5             in     varchar2
  ,p_pty_information6             in     varchar2
  ,p_pty_information7             in     varchar2
  ,p_pty_information8             in     varchar2
  ,p_pty_information9             in     varchar2
  ,p_pty_information10            in     varchar2
  ,p_pty_information11            in     varchar2
  ,p_pty_information12            in     varchar2
  ,p_pty_information13            in     varchar2
  ,p_pty_information14            in     varchar2
  ,p_pty_information15            in     varchar2
  ,p_pty_information16            in     varchar2
  ,p_pty_information17            in     varchar2
  ,p_pty_information18            in     varchar2
  ,p_pty_information19            in     varchar2
  ,p_pty_information20            in     varchar2
  ,p_special_pension_type_code    in     varchar2     -- added for NL Phase 2B
  ,p_pension_sub_category         in     varchar2     -- added for NL Phase 2B
  ,p_pension_basis_calc_method    in     varchar2     -- added for NL Phase 2B
  ,p_pension_salary_balance       in     number       -- added for NL Phase 2B
  ,p_recurring_bonus_percent      in     number       -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent  in     number       -- added for NL Phase 2B
  ,p_recurring_bonus_balance      in     number       -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance  in     number       -- added for NL Phase 2B
  ,p_std_tax_reduction            in     varchar2     -- added for NL Phase 2B
  ,p_spl_tax_reduction            in     varchar2     -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction    in     varchar2     -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction    in     varchar2     -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction    in     varchar2     -- added for NL Phase 2B
  ,p_sii_std_tax_reduction        in     varchar2     -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction        in     varchar2     -- added for NL Phase 2B
  ,p_sii_non_tax_reduction        in     varchar2     -- added for NL Phase 2B
  ,p_previous_year_bonus_included in     varchar2     -- added for NL Phase 2B
  ,p_recurring_bonus_period       in     varchar2     -- added for NL Phase 2B
  ,p_non_recurring_bonus_period   in     varchar2     -- added for NL Phase 2B
  ,p_ee_age_threshold             in     varchar2     -- added for ABP TAR fixes
  ,p_er_age_threshold             in     varchar2     -- added for ABP TAR fixes
  ,p_ee_age_contribution          in     varchar2     -- added for ABP TAR fixes
  ,p_er_age_contribution          in     varchar2     -- added for ABP TAR fixes
  ,p_pension_type_id              out nocopy number
  ,p_object_version_number        out nocopy number
  ,p_effective_start_date         out nocopy date
  ,p_effective_end_date           out nocopy date
  ,p_api_warning                  out nocopy varchar2
  ) Is

  --
  -- Declare cursors and local variables
  --

  CURSOR c_get_leg_code IS
  SELECT legislation_code
   FROM  per_business_groups
  WHERE  business_group_id = p_business_group_id;

  l_proc                         varchar2(150) := g_package||'Create_Pension_Type';
  l_effective_date               date;
  l_pension_type_id              pqp_pension_types_f.pension_type_id%TYPE;
  l_object_version_number        pqp_pension_types_f.object_version_number%TYPE;
  l_ee_contribution_bal_type_id  pay_balance_types.balance_type_id%TYPE;
  l_er_contribution_bal_type_id  pay_balance_types.balance_type_id%TYPE;
  l_balance_init_element_type_id pay_element_types_f.element_type_id%TYPE;
  l_effective_start_date         date;
  l_effective_end_date           date;
  l_api_warning                  varchar2(250);
  l_sum_percent                  number(7,4);
  l_er_annual_limit              number;
  l_ee_annual_limit              number;
  l_er_annual_salary_threshold   number;
  l_ee_annual_salary_threshold   number;
  l_leg_code                     varchar2(10);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Issue a savepoint
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  savepoint Create_Pension_Type;

  chk_pension_type_name(p_pension_type_name_in => p_pension_type_name);

  chk_dup_pension_type(p_pension_type_name_in => p_pension_type_name
                      ,p_bg_id                => p_business_group_id);


   -- Check if the EE and ER percentages sum up to 100 for NL legislation
   if(p_salary_calculation_method = '3') then
     l_sum_percent := p_ee_contribution_percent + p_er_contribution_percent;

     if l_sum_percent Is Null then
         fnd_message.set_name('PQP', 'PQP_230892_PEN_TYPE_PERCNT_INV');
         fnd_message.raise_error;
     end if;

     if((l_sum_percent  > 100) or (l_sum_percent  < 100)) then
         fnd_message.set_name('PQP', 'PQP_230892_PEN_TYPE_PERCNT_INV');
         fnd_message.raise_error;
     end if;

   end if;

  -- check to see if the annual limits have been entered for Savings Pension Type
  -- when the salary calculation method is null

  if (p_salary_calculation_method is Null and p_pension_category = 'S') then

     if(p_er_annual_limit is Null or p_ee_annual_limit is Null) then

	fnd_message.set_name('PQP', 'PQP_230990_SAV_NULL_ANN_LIMITS');
        fnd_message.raise_error;

     end if;

   end if;

  -- Check the defaults for EE and ER limits/thresholds
   if(p_salary_calculation_method = '3') then
        l_er_annual_limit            := NULL;
        l_ee_annual_limit            := NULL;
        l_er_annual_salary_threshold := NULL;
        l_ee_annual_salary_threshold := NULL;
   else
        l_er_annual_limit            := p_er_annual_limit;
        l_ee_annual_limit            := p_ee_annual_limit;
        l_er_annual_salary_threshold := p_er_annual_salary_threshold;
        l_ee_annual_salary_threshold := p_ee_annual_salary_threshold;
   end if;

   --
   -- check that the sub category is not null for ABP and PGGM pension types
   --
   if p_special_pension_type_code IS NOT NULL THEN
      if p_special_pension_type_code IN('ABP','PGGM') THEN
         if p_pension_sub_category IS NULL THEN
            fnd_message.set_name('PQP','PQP_230069_PEN_SUB_CAT_REQ');
            fnd_message.raise_error;
         end if;
      end if;
   end if;

   --
   -- check that the total contribution percentage is atleast equal to the
   -- employee contribution percentage
   --
   IF p_special_pension_type_code IS NOT NULL THEN
      IF p_special_pension_type_code = 'PGGM' THEN
         IF nvl(p_er_contribution_percent,0) <
            nvl(p_ee_contribution_percent,0) THEN
            fnd_message.set_name('PQP','PQP_230221_PGGM_INV_PERCENTAGE');
            fnd_message.raise_error;
         END IF;
      END IF;
   END IF;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Truncate the time portion from all IN date parameters
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  l_effective_date := Trunc(p_effective_date);

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Create the EE, ER Contribution balances(only for NL,GB)
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     hr_utility.set_location('Creating EE, ER Balances ',14);
  OPEN c_get_leg_code;
  FETCH c_get_leg_code INTO l_leg_code;
  CLOSE c_get_leg_code;

  If l_leg_code <> 'HU' THEN
     If (
          (p_special_pension_type_code IS NULL and p_pension_category <> 'S')
        )
       THEN
        Create_EE_ER_Balances
         (p_effective_date     => l_effective_date
         ,p_business_group_id  => p_business_group_id
         ,p_legislation_code   => p_legislation_code
         ,p_pension_type_name  => p_pension_type_name
         ,p_ee_balance_typeid  => l_ee_contribution_bal_type_id
         ,p_er_balance_typeid  => l_er_contribution_bal_type_id
         );

     Elsif p_special_pension_type_code = 'ABP' THEN
        Create_ABP_EE_ER_Balances
         (p_effective_date     => l_effective_date
         ,p_business_group_id  => p_business_group_id
         ,p_legislation_code   => p_legislation_code
         ,p_pension_sub_cat    => p_pension_sub_category
         ,p_ee_balance_typeid  => l_ee_contribution_bal_type_id
         ,p_er_balance_typeid  => l_er_contribution_bal_type_id
         );

     End If;
     hr_utility.set_location('Created EE, ER Balances ',15);
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Create Balance Initialization Element
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  IF (NVL(p_special_pension_type_code,'X') <> 'PGGM'  and p_pension_category = 'P') THEN
   Create_Balance_Init_Ele
      (p_effective_date                => l_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_legislation_code              => p_legislation_code
      ,p_pension_type_name             => p_pension_type_name
      ,p_pension_sub_cat               => p_pension_sub_category
      ,p_balance_init_element_type_id  => l_balance_init_element_type_id
      );
  END IF;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- For Savings create EE/ER balances for basis=User Defined Balance
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  IF p_pension_basis_calc_method = '10' and p_pension_category = 'S' THEN
   --Check for Employee Contribution balance
   IF p_ee_contribution_bal_type_id  = '0' THEN
    Create_EE_Balance(
                  p_effective_date    => l_effective_date
                 ,p_business_group_id => p_business_group_id
                 ,p_legislation_code  => p_legislation_code
                 ,p_pension_type_name => p_pension_type_name
                 ,p_ee_balance_typeid => l_ee_contribution_bal_type_id
                 );

    Else
    l_ee_contribution_bal_type_id:=p_ee_contribution_bal_type_id;
   END IF;

   --Check for Employer Contribution balance
    IF p_er_contribution_bal_type_id  = '0' THEN
      Create_ER_Balance(
                  p_effective_date    => l_effective_date
                 ,p_business_group_id => p_business_group_id
                 ,p_legislation_code  => p_legislation_code
                 ,p_pension_type_name => p_pension_type_name
                 ,p_er_balance_typeid => l_er_contribution_bal_type_id
                 );

    Else
       l_er_contribution_bal_type_id:=p_er_contribution_bal_type_id;
    END IF;

  ELSIF p_pension_basis_calc_method <> '10' and p_pension_category = 'S' THEN

          Create_EE_ER_Balances
         (p_effective_date     => l_effective_date
         ,p_business_group_id  => p_business_group_id
         ,p_legislation_code   => p_legislation_code
         ,p_pension_type_name  => p_pension_type_name
         ,p_ee_balance_typeid  => l_ee_contribution_bal_type_id
         ,p_er_balance_typeid  => l_er_contribution_bal_type_id
         );

  END IF;

  END IF;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Call Before Process User Hook
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  begin
    hr_utility.set_location('Before Calling User Hook Create_PensionType_b',20);
    PQP_Pension_Types_BK1.Create_Pension_Type_b
      (p_validate                     => p_validate
      ,p_effective_date               => l_effective_date
      ,p_pension_type_name            => p_pension_type_name
      ,p_pension_category             => p_pension_category
      ,p_pension_provider_type        => p_pension_provider_type
      ,p_salary_calculation_method    => p_salary_calculation_method
      ,p_threshold_conversion_rule    => p_threshold_conversion_rule
      ,p_contribution_conversion_rule => p_contribution_conversion_rule
      ,p_er_annual_limit              => l_er_annual_limit
      ,p_ee_annual_limit              => l_ee_annual_limit
      ,p_er_annual_salary_threshold   => l_er_annual_salary_threshold
      ,p_ee_annual_salary_threshold   => l_ee_annual_salary_threshold
      ,p_business_group_id            => p_business_group_id
      ,p_legislation_code             => p_legislation_code
      ,p_description                  => p_description
      ,p_minimum_age                  => p_minimum_age
      ,p_ee_contribution_percent      => p_ee_contribution_percent
      ,p_maximum_age                  => p_maximum_age
      ,p_er_contribution_percent      => p_er_contribution_percent
      ,p_ee_annual_contribution       => p_ee_annual_contribution
      ,p_er_annual_contribution       => p_er_annual_contribution
      ,p_annual_premium_amount        => p_annual_premium_amount
      ,p_ee_contribution_bal_type_id  => p_ee_contribution_bal_type_id
      ,p_er_contribution_bal_type_id  => p_er_contribution_bal_type_id
      ,p_balance_init_element_type_id => p_balance_init_element_type_id
      ,p_ee_contribution_fixed_rate   => p_ee_contribution_fixed_rate
      ,p_er_contribution_fixed_rate   => p_er_contribution_fixed_rate
      ,p_pty_attribute_category       => p_pty_attribute_category
      ,p_pty_attribute1               => p_pty_attribute1
      ,p_pty_attribute2               => p_pty_attribute2
      ,p_pty_attribute3               => p_pty_attribute3
      ,p_pty_attribute4               => p_pty_attribute4
      ,p_pty_attribute5               => p_pty_attribute5
      ,p_pty_attribute6               => p_pty_attribute6
      ,p_pty_attribute7               => p_pty_attribute7
      ,p_pty_attribute8               => p_pty_attribute8
      ,p_pty_attribute9               => p_pty_attribute9
      ,p_pty_attribute10              => p_pty_attribute10
      ,p_pty_attribute11              => p_pty_attribute11
      ,p_pty_attribute12              => p_pty_attribute12
      ,p_pty_attribute13              => p_pty_attribute13
      ,p_pty_attribute14              => p_pty_attribute14
      ,p_pty_attribute15              => p_pty_attribute15
      ,p_pty_attribute16              => p_pty_attribute16
      ,p_pty_attribute17              => p_pty_attribute17
      ,p_pty_attribute18              => p_pty_attribute18
      ,p_pty_attribute19              => p_pty_attribute19
      ,p_pty_attribute20              => p_pty_attribute20
      ,p_pty_information_category     => p_pty_information_category
      ,p_pty_information1             => p_pty_information1
      ,p_pty_information2             => p_pty_information2
      ,p_pty_information3             => p_pty_information3
      ,p_pty_information4             => p_pty_information4
      ,p_pty_information5             => p_pty_information5
      ,p_pty_information6             => p_pty_information6
      ,p_pty_information7             => p_pty_information7
      ,p_pty_information8             => p_pty_information8
      ,p_pty_information9             => p_pty_information9
      ,p_pty_information10            => p_pty_information10
      ,p_pty_information11            => p_pty_information11
      ,p_pty_information12            => p_pty_information12
      ,p_pty_information13            => p_pty_information13
      ,p_pty_information14            => p_pty_information14
      ,p_pty_information15            => p_pty_information15
      ,p_pty_information16            => p_pty_information16
      ,p_pty_information17            => p_pty_information17
      ,p_pty_information18            => p_pty_information18
      ,p_pty_information19            => p_pty_information19
      ,p_pty_information20            => p_pty_information20
      ,p_special_pension_type_code    => p_special_pension_type_code    -- added for NL Phase 2B
      ,p_pension_sub_category         => p_pension_sub_category         -- added for NL Phase 2B
      ,p_pension_basis_calc_method    => p_pension_basis_calc_method    -- added for NL Phase 2B
      ,p_pension_salary_balance       => p_pension_salary_balance       -- added for NL Phase 2B
      ,p_recurring_bonus_percent      => p_recurring_bonus_percent      -- added for NL Phase 2B
      ,p_non_recurring_bonus_percent  => p_non_recurring_bonus_percent  -- added for NL Phase 2B
      ,p_recurring_bonus_balance      => p_recurring_bonus_balance      -- added for NL Phase 2B
      ,p_non_recurring_bonus_balance  => p_non_recurring_bonus_balance  -- added for NL Phase 2B
      ,p_std_tax_reduction            => p_std_tax_reduction            -- added for NL Phase 2B
      ,p_spl_tax_reduction            => p_spl_tax_reduction            -- added for NL Phase 2B
      ,p_sig_sal_spl_tax_reduction    => p_sig_sal_spl_tax_reduction    -- added for NL Phase 2B
      ,p_sig_sal_non_tax_reduction    => p_sig_sal_non_tax_reduction    -- added for NL Phase 2B
      ,p_sig_sal_std_tax_reduction    => p_sig_sal_std_tax_reduction    -- added for NL Phase 2B
      ,p_sii_std_tax_reduction        => p_sii_std_tax_reduction        -- added for NL Phase 2B
      ,p_sii_spl_tax_reduction        => p_sii_spl_tax_reduction        -- added for NL Phase 2B
      ,p_sii_non_tax_reduction        => p_sii_non_tax_reduction        -- added for NL Phase 2B
      ,p_previous_year_bonus_included => p_previous_year_bonus_included -- added for NL Phase 2B
      ,p_recurring_bonus_period       => p_recurring_bonus_period       -- added for NL Phase 2B
      ,p_non_recurring_bonus_period   => p_non_recurring_bonus_period   -- added for NL Phase 2B
      ,p_ee_age_threshold             => p_ee_age_threshold             -- added for ABP TAR fixes
      ,p_er_age_threshold             => p_er_age_threshold             -- added for ABP TAR fixes
      ,p_ee_age_contribution          => p_ee_age_contribution          -- added for ABP TAR fixes
      ,p_er_age_contribution          => p_er_age_contribution          -- added for ABP TAR fixes
      );
      hr_utility.set_location('After Calling User Hook Create_PensionType_b',20);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_utility.set_location('Exception in User Hook Create_PensionType_b',25);
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Create_Pension_Type'
        ,p_hook_type   => 'BP'
        );
  end;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Validation in addition to Row Handlers
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler ins procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     hr_utility.set_location('Before calling row-handler pqp_pty_ins.ins',30);
     pqp_pty_ins.ins
      (p_effective_date                 => l_effective_date
      ,p_pension_type_name              => p_pension_type_name
      ,p_pension_category               => p_pension_category
      ,p_pension_provider_type          => p_pension_provider_type
      ,p_salary_calculation_method      => p_salary_calculation_method
      ,p_threshold_conversion_rule      => p_threshold_conversion_rule
      ,p_contribution_conversion_rule   => p_contribution_conversion_rule
      ,p_er_annual_limit                => l_er_annual_limit
      ,p_ee_annual_limit                => l_ee_annual_limit
      ,p_er_annual_salary_threshold     => l_er_annual_salary_threshold
      ,p_ee_annual_salary_threshold     => l_ee_annual_salary_threshold
      ,p_business_group_id              => p_business_group_id
      ,p_legislation_code               => p_legislation_code
      ,p_description                    => p_description
      ,p_minimum_age                    => p_minimum_age
      ,p_ee_contribution_percent        => p_ee_contribution_percent
      ,p_maximum_age                    => p_maximum_age
      ,p_er_contribution_percent        => p_er_contribution_percent
      ,p_ee_annual_contribution         => p_ee_annual_contribution
      ,p_er_annual_contribution         => p_er_annual_contribution
      ,p_annual_premium_amount          => p_annual_premium_amount
      ,p_ee_contribution_bal_type_id    => l_ee_contribution_bal_type_id
      ,p_er_contribution_bal_type_id    => l_er_contribution_bal_type_id
      ,p_balance_init_element_type_id   => l_balance_init_element_type_id
      ,p_ee_contribution_fixed_rate     => p_ee_contribution_fixed_rate   --added for UK
      ,p_er_contribution_fixed_rate     => p_er_contribution_fixed_rate   --added for UK
      ,p_pty_attribute_category         => p_pty_attribute_category
      ,p_pty_attribute1                 => p_pty_attribute1
      ,p_pty_attribute2                 => p_pty_attribute2
      ,p_pty_attribute3                 => p_pty_attribute3
      ,p_pty_attribute4                 => p_pty_attribute4
      ,p_pty_attribute5                 => p_pty_attribute5
      ,p_pty_attribute6                 => p_pty_attribute6
      ,p_pty_attribute7                 => p_pty_attribute7
      ,p_pty_attribute8                 => p_pty_attribute8
      ,p_pty_attribute9                 => p_pty_attribute9
      ,p_pty_attribute10                => p_pty_attribute10
      ,p_pty_attribute11                => p_pty_attribute11
      ,p_pty_attribute12                => p_pty_attribute12
      ,p_pty_attribute13                => p_pty_attribute13
      ,p_pty_attribute14                => p_pty_attribute14
      ,p_pty_attribute15                => p_pty_attribute15
      ,p_pty_attribute16                => p_pty_attribute16
      ,p_pty_attribute17                => p_pty_attribute17
      ,p_pty_attribute18                => p_pty_attribute18
      ,p_pty_attribute19                => p_pty_attribute19
      ,p_pty_attribute20                => p_pty_attribute20
      ,p_pty_information_category       => p_pty_information_category
      ,p_pty_information1               => p_pty_information1
      ,p_pty_information2               => p_pty_information2
      ,p_pty_information3               => p_pty_information3
      ,p_pty_information4               => p_pty_information4
      ,p_pty_information5               => p_pty_information5
      ,p_pty_information6               => p_pty_information6
      ,p_pty_information7               => p_pty_information7
      ,p_pty_information8               => p_pty_information8
      ,p_pty_information9               => p_pty_information9
      ,p_pty_information10              => p_pty_information10
      ,p_pty_information11              => p_pty_information11
      ,p_pty_information12              => p_pty_information12
      ,p_pty_information13              => p_pty_information13
      ,p_pty_information14              => p_pty_information14
      ,p_pty_information15              => p_pty_information15
      ,p_pty_information16              => p_pty_information16
      ,p_pty_information17              => p_pty_information17
      ,p_pty_information18              => p_pty_information18
      ,p_pty_information19              => p_pty_information19
      ,p_pty_information20              => p_pty_information20
      ,p_special_pension_type_code    => p_special_pension_type_code    -- added for NL Phase 2B
      ,p_pension_sub_category         => p_pension_sub_category         -- added for NL Phase 2B
      ,p_pension_basis_calc_method    => p_pension_basis_calc_method    -- added for NL Phase 2B
      ,p_pension_salary_balance       => p_pension_salary_balance       -- added for NL Phase 2B
      ,p_recurring_bonus_percent      => p_recurring_bonus_percent      -- added for NL Phase 2B
      ,p_non_recurring_bonus_percent  => p_non_recurring_bonus_percent  -- added for NL Phase 2B
      ,p_recurring_bonus_balance      => p_recurring_bonus_balance      -- added for NL Phase 2B
      ,p_non_recurring_bonus_balance  => p_non_recurring_bonus_balance  -- added for NL Phase 2B
      ,p_std_tax_reduction            => p_std_tax_reduction            -- added for NL Phase 2B
      ,p_spl_tax_reduction            => p_spl_tax_reduction            -- added for NL Phase 2B
      ,p_sig_sal_spl_tax_reduction    => p_sig_sal_spl_tax_reduction    -- added for NL Phase 2B
      ,p_sig_sal_non_tax_reduction    => p_sig_sal_non_tax_reduction    -- added for NL Phase 2B
      ,p_sig_sal_std_tax_reduction    => p_sig_sal_std_tax_reduction    -- added for NL Phase 2B
      ,p_sii_std_tax_reduction        => p_sii_std_tax_reduction        -- added for NL Phase 2B
      ,p_sii_spl_tax_reduction        => p_sii_spl_tax_reduction        -- added for NL Phase 2B
      ,p_sii_non_tax_reduction        => p_sii_non_tax_reduction        -- added for NL Phase 2B
      ,p_previous_year_bonus_included => p_previous_year_bonus_included -- added for NL Phase 2B
      ,p_recurring_bonus_period       => p_recurring_bonus_period       -- added for NL Phase 2B
      ,p_non_recurring_bonus_period   => p_non_recurring_bonus_period   -- added for NL Phase 2B
      ,p_ee_age_threshold             => p_ee_age_threshold             -- added for ABP TAR fixes
      ,p_er_age_threshold             => p_er_age_threshold             -- added for ABP TAR fixes
      ,p_ee_age_contribution          => p_ee_age_contribution          -- added for ABP TAR fixes
      ,p_er_age_contribution          => p_er_age_contribution          -- added for ABP TAR fixes
      ,p_pension_type_id               => l_pension_type_id
      ,p_object_version_number          => l_object_version_number
      ,p_effective_start_date           => l_effective_start_date
      ,p_effective_end_date             => l_effective_end_date
      );

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Call After Process User Hook
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  begin
    PQP_Pension_Types_BK1.Create_Pension_Type_a
      (p_validate                     => p_validate
      ,p_effective_date               => l_effective_date
      ,p_pension_type_name            => p_pension_type_name
      ,p_pension_category             => p_pension_category
      ,p_pension_provider_type        => p_pension_provider_type
      ,p_salary_calculation_method    => p_salary_calculation_method
      ,p_threshold_conversion_rule    => p_threshold_conversion_rule
      ,p_contribution_conversion_rule => p_contribution_conversion_rule
      ,p_er_annual_limit              => l_er_annual_limit
      ,p_ee_annual_limit              => l_ee_annual_limit
      ,p_er_annual_salary_threshold   => l_er_annual_salary_threshold
      ,p_ee_annual_salary_threshold   => l_ee_annual_salary_threshold
      ,p_business_group_id            => p_business_group_id
      ,p_legislation_code             => p_legislation_code
      ,p_description                  => p_description
      ,p_minimum_age                  => p_minimum_age
      ,p_ee_contribution_percent      => p_ee_contribution_percent
      ,p_maximum_age                  => p_maximum_age
      ,p_er_contribution_percent      => p_er_contribution_percent
      ,p_ee_annual_contribution       => p_ee_annual_contribution
      ,p_er_annual_contribution       => p_er_annual_contribution
      ,p_annual_premium_amount        => p_annual_premium_amount
      ,p_ee_contribution_bal_type_id  => p_ee_contribution_bal_type_id
      ,p_er_contribution_bal_type_id  => p_er_contribution_bal_type_id
      ,p_balance_init_element_type_id => p_balance_init_element_type_id
      ,p_ee_contribution_fixed_rate   => p_ee_contribution_fixed_rate
      ,p_er_contribution_fixed_rate   => p_er_contribution_fixed_rate
      ,p_pty_attribute_category       => p_pty_attribute_category
      ,p_pty_attribute1               => p_pty_attribute1
      ,p_pty_attribute2               => p_pty_attribute2
      ,p_pty_attribute3               => p_pty_attribute3
      ,p_pty_attribute4               => p_pty_attribute4
      ,p_pty_attribute5               => p_pty_attribute5
      ,p_pty_attribute6               => p_pty_attribute6
      ,p_pty_attribute7               => p_pty_attribute7
      ,p_pty_attribute8               => p_pty_attribute8
      ,p_pty_attribute9               => p_pty_attribute9
      ,p_pty_attribute10              => p_pty_attribute10
      ,p_pty_attribute11              => p_pty_attribute11
      ,p_pty_attribute12              => p_pty_attribute12
      ,p_pty_attribute13              => p_pty_attribute13
      ,p_pty_attribute14              => p_pty_attribute14
      ,p_pty_attribute15              => p_pty_attribute15
      ,p_pty_attribute16              => p_pty_attribute16
      ,p_pty_attribute17              => p_pty_attribute17
      ,p_pty_attribute18              => p_pty_attribute18
      ,p_pty_attribute19              => p_pty_attribute19
      ,p_pty_attribute20              => p_pty_attribute20
      ,p_pty_information_category     => p_pty_information_category
      ,p_pty_information1             => p_pty_information1
      ,p_pty_information2             => p_pty_information2
      ,p_pty_information3             => p_pty_information3
      ,p_pty_information4             => p_pty_information4
      ,p_pty_information5             => p_pty_information5
      ,p_pty_information6             => p_pty_information6
      ,p_pty_information7             => p_pty_information7
      ,p_pty_information8             => p_pty_information8
      ,p_pty_information9             => p_pty_information9
      ,p_pty_information10            => p_pty_information10
      ,p_pty_information11            => p_pty_information11
      ,p_pty_information12            => p_pty_information12
      ,p_pty_information13            => p_pty_information13
      ,p_pty_information14            => p_pty_information14
      ,p_pty_information15            => p_pty_information15
      ,p_pty_information16            => p_pty_information16
      ,p_pty_information17            => p_pty_information17
      ,p_pty_information18            => p_pty_information18
      ,p_pty_information19            => p_pty_information19
      ,p_pty_information20            => p_pty_information20
      ,p_special_pension_type_code    => p_special_pension_type_code    -- added for NL Phase 2B
      ,p_pension_sub_category         => p_pension_sub_category         -- added for NL Phase 2B
      ,p_pension_basis_calc_method    => p_pension_basis_calc_method    -- added for NL Phase 2B
      ,p_pension_salary_balance       => p_pension_salary_balance       -- added for NL Phase 2B
      ,p_recurring_bonus_percent      => p_recurring_bonus_percent      -- added for NL Phase 2B
      ,p_non_recurring_bonus_percent  => p_non_recurring_bonus_percent  -- added for NL Phase 2B
      ,p_recurring_bonus_balance      => p_recurring_bonus_balance      -- added for NL Phase 2B
      ,p_non_recurring_bonus_balance  => p_non_recurring_bonus_balance  -- added for NL Phase 2B
      ,p_std_tax_reduction            => p_std_tax_reduction            -- added for NL Phase 2B
      ,p_spl_tax_reduction            => p_spl_tax_reduction            -- added for NL Phase 2B
      ,p_sig_sal_spl_tax_reduction    => p_sig_sal_spl_tax_reduction    -- added for NL Phase 2B
      ,p_sig_sal_non_tax_reduction    => p_sig_sal_non_tax_reduction    -- added for NL Phase 2B
      ,p_sig_sal_std_tax_reduction    => p_sig_sal_std_tax_reduction    -- added for NL Phase 2B
      ,p_sii_std_tax_reduction        => p_sii_std_tax_reduction        -- added for NL Phase 2B
      ,p_sii_spl_tax_reduction        => p_sii_spl_tax_reduction        -- added for NL Phase 2B
      ,p_sii_non_tax_reduction        => p_sii_non_tax_reduction        -- added for NL Phase 2B
      ,p_previous_year_bonus_included => p_previous_year_bonus_included -- added for NL Phase 2B
      ,p_recurring_bonus_period       => p_recurring_bonus_period       -- added for NL Phase 2B
      ,p_non_recurring_bonus_period   => p_non_recurring_bonus_period   -- added for NL Phase 2B
      ,p_ee_age_threshold             => p_ee_age_threshold             -- added for ABP TAR fixes
      ,p_er_age_threshold             => p_er_age_threshold             -- added for ABP TAR fixes
      ,p_ee_age_contribution          => p_ee_age_contribution          -- added for ABP TAR fixes
      ,p_er_age_contribution          => p_er_age_contribution          -- added for ABP TAR fixes
      ,p_pension_type_id              => l_pension_type_id
      ,p_object_version_number        => l_object_version_number
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_api_warning                  => l_api_warning

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Create_Pension_Type'
        ,p_hook_type   => 'AP'
        );
  end;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- When in validation only mode raise the Validate_Enabled exception
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  If p_validate Then
    raise hr_api.validate_enabled;
  End If;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Set all output arguments
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  p_pension_type_id        := l_pension_type_id;
  p_object_version_number  := l_object_version_number;
  p_api_warning            := l_api_warning;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
Exception
  When hr_api.validate_enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    Rollback To Create_Pension_Type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    l_pension_type_id        := Null;
    p_object_version_number  := Null;
    p_effective_start_date   := Null;
    p_effective_end_date     := Null;
    p_api_warning            := l_api_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  When Others Then
    --
    -- A validation or unexpected error has occured
    --
    Rollback to Create_Pension_Type;
    hr_utility.set_location('error is : '||SQLERRM,85);
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;
End Create_Pension_Type;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_Pension_Type >--------------------------|
-- ----------------------------------------------------------------------------
Procedure Update_Pension_Type
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_pension_type_id             in     number
  ,p_object_version_number        in out nocopy number
  ,p_pension_type_name            in     varchar2 --x
  ,p_pension_category             in     varchar2 --x
  ,p_pension_provider_type        in     varchar2
  ,p_salary_calculation_method    in     varchar2
  ,p_threshold_conversion_rule    in     varchar2
  ,p_contribution_conversion_rule in     varchar2
  ,p_er_annual_limit              in     number
  ,p_ee_annual_limit              in     number
  ,p_er_annual_salary_threshold   in     number
  ,p_ee_annual_salary_threshold   in     number
  ,p_business_group_id            in     number --x
  ,p_legislation_code             in     varchar2 --x
  ,p_description                  in     varchar2
  ,p_minimum_age                  in     number
  ,p_ee_contribution_percent      in     number
  ,p_maximum_age                  in     number
  ,p_er_contribution_percent      in     number
  ,p_ee_annual_contribution       in     number
  ,p_er_annual_contribution       in     number
  ,p_annual_premium_amount        in     number
  ,p_ee_contribution_bal_type_id  in     number --x
  ,p_er_contribution_bal_type_id  in     number --x
  ,p_balance_init_element_type_id in     number --x
  ,p_ee_contribution_fixed_rate   in     number --added for UK
  ,p_er_contribution_fixed_rate   in     number --added for UK
  ,p_pty_attribute_category       in     varchar2
  ,p_pty_attribute1               in     varchar2
  ,p_pty_attribute2               in     varchar2
  ,p_pty_attribute3               in     varchar2
  ,p_pty_attribute4               in     varchar2
  ,p_pty_attribute5               in     varchar2
  ,p_pty_attribute6               in     varchar2
  ,p_pty_attribute7               in     varchar2
  ,p_pty_attribute8               in     varchar2
  ,p_pty_attribute9               in     varchar2
  ,p_pty_attribute10              in     varchar2
  ,p_pty_attribute11              in     varchar2
  ,p_pty_attribute12              in     varchar2
  ,p_pty_attribute13              in     varchar2
  ,p_pty_attribute14              in     varchar2
  ,p_pty_attribute15              in     varchar2
  ,p_pty_attribute16              in     varchar2
  ,p_pty_attribute17              in     varchar2
  ,p_pty_attribute18              in     varchar2
  ,p_pty_attribute19              in     varchar2
  ,p_pty_attribute20              in     varchar2
  ,p_pty_information_category     in     varchar2
  ,p_pty_information1             in     varchar2
  ,p_pty_information2             in     varchar2
  ,p_pty_information3             in     varchar2
  ,p_pty_information4             in     varchar2
  ,p_pty_information5             in     varchar2
  ,p_pty_information6             in     varchar2
  ,p_pty_information7             in     varchar2
  ,p_pty_information8             in     varchar2
  ,p_pty_information9             in     varchar2
  ,p_pty_information10            in     varchar2
  ,p_pty_information11            in     varchar2
  ,p_pty_information12            in     varchar2
  ,p_pty_information13            in     varchar2
  ,p_pty_information14            in     varchar2
  ,p_pty_information15            in     varchar2
  ,p_pty_information16            in     varchar2
  ,p_pty_information17            in     varchar2
  ,p_pty_information18            in     varchar2
  ,p_pty_information19            in     varchar2
  ,p_pty_information20            in     varchar2
  ,p_special_pension_type_code    in     varchar2     -- added for NL Phase 2B
  ,p_pension_sub_category         in     varchar2     -- added for NL Phase 2B
  ,p_pension_basis_calc_method    in     varchar2     -- added for NL Phase 2B
  ,p_pension_salary_balance       in     number       -- added for NL Phase 2B
  ,p_recurring_bonus_percent      in     number       -- added for NL Phase 2B
  ,p_non_recurring_bonus_percent  in     number       -- added for NL Phase 2B
  ,p_recurring_bonus_balance      in     number       -- added for NL Phase 2B
  ,p_non_recurring_bonus_balance  in     number       -- added for NL Phase 2B
  ,p_std_tax_reduction            in     varchar2     -- added for NL Phase 2B
  ,p_spl_tax_reduction            in     varchar2     -- added for NL Phase 2B
  ,p_sig_sal_spl_tax_reduction    in     varchar2     -- added for NL Phase 2B
  ,p_sig_sal_non_tax_reduction    in     varchar2     -- added for NL Phase 2B
  ,p_sig_sal_std_tax_reduction    in     varchar2     -- added for NL Phase 2B
  ,p_sii_std_tax_reduction        in     varchar2     -- added for NL Phase 2B
  ,p_sii_spl_tax_reduction        in     varchar2     -- added for NL Phase 2B
  ,p_sii_non_tax_reduction        in     varchar2     -- added for NL Phase 2B
  ,p_previous_year_bonus_included in     varchar2     -- added for NL Phase 2B
  ,p_recurring_bonus_period       in     varchar2     -- added for NL Phase 2B
  ,p_non_recurring_bonus_period   in     varchar2     -- added for NL Phase 2B
  ,p_ee_age_threshold             in     varchar2     -- added for ABP TAR fixes
  ,p_er_age_threshold             in     varchar2     -- added for ABP TAR fixes
  ,p_ee_age_contribution          in     varchar2     -- added for ABP TAR fixes
  ,p_er_age_contribution          in     varchar2     -- added for ABP TAR fixes
  ,p_effective_start_date         out nocopy date
  ,p_effective_end_date           out nocopy date
  ,p_api_warning                  out nocopy varchar2
  ) Is
  l_proc                         varchar2(150) := g_package||'Update_Pension_Type';
  l_object_version_number        pqp_pension_types_f.object_version_number%TYPE;
  l_effective_date               date;
  l_effective_start_date         date;
  l_effective_end_date           date;
  l_sum_percent                  number(7,4);
  l_er_annual_limit              number;
  l_ee_annual_limit              number;
  l_er_annual_salary_threshold   number;
  l_ee_annual_salary_threshold   number;
  l_category                     varchar2(30);
  l_schm_exists                  number;
  l_api_warning                  number := hr_api.g_number;

  CURSOR c_chk_scheme IS
  SELECT 1
   FROM  pay_element_type_extra_info
  WHERE  information_type = 'HU_PENSION_SCHEME_INFO'
   AND   eei_information_category = 'HU_PENSION_SCHEME_INFO'
   AND   eei_information3 = fnd_number.number_to_canonical(p_pension_type_id);

  CURSOR c_get_category IS
  SELECT pension_category
    FROM pqp_pension_types_f
  WHERE  pension_type_id = p_pension_type_id
    AND  p_effective_date BETWEEN effective_start_date
    AND  effective_end_date;

Begin
  p_api_warning := hr_api.g_varchar2;
  hr_utility.set_location('Entering:'|| l_proc, 10);
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Issue a savepoint
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  savepoint Update_Pension_Type;

     if(p_salary_calculation_method = '3') then
     l_sum_percent := p_ee_contribution_percent + p_er_contribution_percent;

     if l_sum_percent Is Null then
         fnd_message.set_name('PQP', 'PQP_230892_PEN_TYPE_PERCNT_INV');
         fnd_message.raise_error;
     end if;

     if((l_sum_percent  > 100) or (l_sum_percent  < 100)) then
       fnd_message.set_name('PQP', 'PQP_230892_PEN_TYPE_PERCNT_INV');
       fnd_message.raise_error;
     end if;
   end if;

  -- check to see if the annual limits have been entered for Savings Pension Type
  -- when the salary calculation method is null

  if (p_salary_calculation_method is Null and p_pension_category = 'S') then

     if(p_er_annual_limit is Null or p_ee_annual_limit is Null) then

	fnd_message.set_name('PQP', 'PQP_230990_SAV_NULL_ANN_LIMITS');
        fnd_message.raise_error;

     end if;

   end if;

 -- Check the defaults for EE and ER limits/thresholds
   if(p_salary_calculation_method = '3') then
        l_er_annual_limit            := NULL;
        l_ee_annual_limit            := NULL;
        l_er_annual_salary_threshold := NULL;
        l_ee_annual_salary_threshold := NULL;
   else
        l_er_annual_limit            := p_er_annual_limit;
        l_ee_annual_limit            := p_ee_annual_limit;
        l_er_annual_salary_threshold := p_er_annual_salary_threshold;
        l_ee_annual_salary_threshold := p_ee_annual_salary_threshold;
   end if;

   --
   -- check that the total contribution percentage is atleast equal to the
   -- employee contribution percentage
   --
   IF p_special_pension_type_code IS NOT NULL THEN
      IF p_special_pension_type_code = 'PGGM' THEN
         IF nvl(p_er_contribution_percent,0) <
            nvl(p_ee_contribution_percent,0) THEN
            fnd_message.set_name('PQP','PQP_230221_PGGM_INV_PERCENTAGE');
            fnd_message.raise_error;
         END IF;
      END IF;
   END IF;

 --validation added for HU (allow change of category only if no scheme exists)
 OPEN c_get_category;
 FETCH c_get_category INTO l_category;
 CLOSE c_get_category;

 IF l_category <> p_pension_category THEN
    OPEN c_chk_scheme;
    FETCH c_chk_scheme INTO l_schm_exists;
    IF c_chk_scheme%FOUND THEN
       CLOSE c_chk_scheme;
       fnd_message.set_name('PQP','PQP_230125_PT_UPD_NOT_ALLOWED');
       fnd_message.raise_error;
    ELSE
       CLOSE c_chk_scheme;
    END IF;
 END IF;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Truncate the time portion from all IN date parameters
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  l_effective_date := Trunc(p_effective_date);
  l_object_version_number := p_object_version_number;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Call Before Process User Hook
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  begin
    hr_utility.set_location('Before Calling User Hook Update_Pension_Type_b',20);
    PQP_Pension_Types_BK2.Update_Pension_Type_b
      (p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_datetrack_mode               => p_datetrack_mode
      ,p_pension_type_id              => p_pension_type_id
      ,p_object_version_number        => l_object_version_number
      ,p_pension_type_name            => p_pension_type_name
      ,p_pension_category             => p_pension_category
      ,p_pension_provider_type        => p_pension_provider_type
      ,p_salary_calculation_method    => p_salary_calculation_method
      ,p_threshold_conversion_rule    => p_threshold_conversion_rule
      ,p_contribution_conversion_rule => p_contribution_conversion_rule
      ,p_er_annual_limit              => l_er_annual_limit
      ,p_ee_annual_limit              => l_ee_annual_limit
      ,p_er_annual_salary_threshold   => l_er_annual_salary_threshold
      ,p_ee_annual_salary_threshold   => l_ee_annual_salary_threshold
      ,p_business_group_id            => p_business_group_id
      ,p_legislation_code             => p_legislation_code
      ,p_description                  => p_description
      ,p_minimum_age                  => p_minimum_age
      ,p_ee_contribution_percent      => p_ee_contribution_percent
      ,p_maximum_age                  => p_maximum_age
      ,p_er_contribution_percent      => p_er_contribution_percent
      ,p_ee_annual_contribution       => p_ee_annual_contribution
      ,p_er_annual_contribution       => p_er_annual_contribution
      ,p_annual_premium_amount        => p_annual_premium_amount
      ,p_ee_contribution_bal_type_id  => p_ee_contribution_bal_type_id
      ,p_er_contribution_bal_type_id  => p_er_contribution_bal_type_id
      ,p_balance_init_element_type_id => p_balance_init_element_type_id
      ,p_ee_contribution_fixed_rate   => p_ee_contribution_fixed_rate   --added for UK
     ,p_er_contribution_fixed_rate   => p_er_contribution_fixed_rate   --added for UK
      ,p_pty_attribute_category       => p_pty_attribute_category
      ,p_pty_attribute1               => p_pty_attribute1
      ,p_pty_attribute2               => p_pty_attribute2
      ,p_pty_attribute3               => p_pty_attribute3
      ,p_pty_attribute4               => p_pty_attribute4
      ,p_pty_attribute5               => p_pty_attribute5
      ,p_pty_attribute6               => p_pty_attribute6
      ,p_pty_attribute7               => p_pty_attribute7
      ,p_pty_attribute8               => p_pty_attribute8
      ,p_pty_attribute9               => p_pty_attribute9
      ,p_pty_attribute10              => p_pty_attribute10
      ,p_pty_attribute11              => p_pty_attribute11
      ,p_pty_attribute12              => p_pty_attribute12
      ,p_pty_attribute13              => p_pty_attribute13
      ,p_pty_attribute14              => p_pty_attribute14
      ,p_pty_attribute15              => p_pty_attribute15
      ,p_pty_attribute16              => p_pty_attribute16
      ,p_pty_attribute17              => p_pty_attribute17
      ,p_pty_attribute18              => p_pty_attribute18
      ,p_pty_attribute19              => p_pty_attribute19
      ,p_pty_attribute20              => p_pty_attribute20
      ,p_pty_information_category     => p_pty_information_category
      ,p_pty_information1             => p_pty_information1
      ,p_pty_information2             => p_pty_information2
      ,p_pty_information3             => p_pty_information3
      ,p_pty_information4             => p_pty_information4
      ,p_pty_information5             => p_pty_information5
      ,p_pty_information6             => p_pty_information6
      ,p_pty_information7             => p_pty_information7
      ,p_pty_information8             => p_pty_information8
      ,p_pty_information9             => p_pty_information9
      ,p_pty_information10            => p_pty_information10
      ,p_pty_information11            => p_pty_information11
      ,p_pty_information12            => p_pty_information12
      ,p_pty_information13            => p_pty_information13
      ,p_pty_information14            => p_pty_information14
      ,p_pty_information15            => p_pty_information15
      ,p_pty_information16            => p_pty_information16
      ,p_pty_information17            => p_pty_information17
      ,p_pty_information18            => p_pty_information18
      ,p_pty_information19            => p_pty_information19
      ,p_pty_information20            => p_pty_information20
      ,p_special_pension_type_code    => p_special_pension_type_code    -- added for NL Phase 2B
      ,p_pension_sub_category         => p_pension_sub_category         -- added for NL Phase 2B
      ,p_pension_basis_calc_method    => p_pension_basis_calc_method    -- added for NL Phase 2B
      ,p_pension_salary_balance       => p_pension_salary_balance       -- added for NL Phase 2B
      ,p_recurring_bonus_percent      => p_recurring_bonus_percent      -- added for NL Phase 2B
      ,p_non_recurring_bonus_percent  => p_non_recurring_bonus_percent  -- added for NL Phase 2B
      ,p_recurring_bonus_balance      => p_recurring_bonus_balance      -- added for NL Phase 2B
      ,p_non_recurring_bonus_balance  => p_non_recurring_bonus_balance  -- added for NL Phase 2B
      ,p_std_tax_reduction            => p_std_tax_reduction            -- added for NL Phase 2B
      ,p_spl_tax_reduction            => p_spl_tax_reduction            -- added for NL Phase 2B
      ,p_sig_sal_spl_tax_reduction    => p_sig_sal_spl_tax_reduction    -- added for NL Phase 2B
      ,p_sig_sal_non_tax_reduction    => p_sig_sal_non_tax_reduction    -- added for NL Phase 2B
      ,p_sig_sal_std_tax_reduction    => p_sig_sal_std_tax_reduction    -- added for NL Phase 2B
      ,p_sii_std_tax_reduction        => p_sii_std_tax_reduction        -- added for NL Phase 2B
      ,p_sii_spl_tax_reduction        => p_sii_spl_tax_reduction        -- added for NL Phase 2B
      ,p_sii_non_tax_reduction        => p_sii_non_tax_reduction        -- added for NL Phase 2B
      ,p_previous_year_bonus_included => p_previous_year_bonus_included -- added for NL Phase 2B
      ,p_recurring_bonus_period       => p_recurring_bonus_period       -- added for NL Phase 2B
      ,p_non_recurring_bonus_period   => p_non_recurring_bonus_period   -- added for NL Phase 2B
      ,p_ee_age_threshold             => p_ee_age_threshold             -- added for ABP TAR fixes
      ,p_er_age_threshold             => p_er_age_threshold             -- added for ABP TAR fixes
      ,p_ee_age_contribution          => p_ee_age_contribution          -- added for ABP TAR fixes
      ,p_er_age_contribution          => p_er_age_contribution          -- added for ABP TAR fixes
      );
      hr_utility.set_location('After Calling User Hook Update_Pension_Type_b',20);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_utility.set_location('Exception in User Hook Update_Pension_Type_b',25);
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Pension_Type'
        ,p_hook_type   => 'BP'
        );
  end;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Validation in addition to Row Handlers
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler ins procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     hr_utility.set_location('Before calling row-handler pqp_pty_upd.upd',30);
     pqp_pty_upd.upd
      (p_effective_date               => l_effective_date
      ,p_datetrack_mode               => p_datetrack_mode
      ,p_pension_type_id              => p_pension_type_id
      ,p_object_version_number        => l_object_version_number
      --,p_pension_type_name            => p_pension_type_name
      ,p_pension_category             => p_pension_category
      ,p_pension_provider_type        => p_pension_provider_type
      ,p_salary_calculation_method    => p_salary_calculation_method
      ,p_threshold_conversion_rule    => p_threshold_conversion_rule
      ,p_contribution_conversion_rule => p_contribution_conversion_rule
      ,p_er_annual_limit              => l_er_annual_limit
      ,p_ee_annual_limit              => l_ee_annual_limit
      ,p_er_annual_salary_threshold   => l_er_annual_salary_threshold
      ,p_ee_annual_salary_threshold   => l_ee_annual_salary_threshold
      ,p_business_group_id            => p_business_group_id
      ,p_legislation_code             => p_legislation_code
      ,p_description                  => p_description
      ,p_minimum_age                  => p_minimum_age
      ,p_ee_contribution_percent      => p_ee_contribution_percent
      ,p_maximum_age                  => p_maximum_age
      ,p_er_contribution_percent      => p_er_contribution_percent
      ,p_ee_annual_contribution       => p_ee_annual_contribution
      ,p_er_annual_contribution       => p_er_annual_contribution
      ,p_annual_premium_amount        => p_annual_premium_amount
      --,p_ee_contribution_bal_type_id  => p_ee_contribution_bal_type_id
      --,p_er_contribution_bal_type_id  => p_er_contribution_bal_type_id
      --,p_balance_init_element_type_id => p_balance_init_element_type_id
      ,p_ee_contribution_fixed_rate   => p_ee_contribution_fixed_rate   --added for UK
      ,p_er_contribution_fixed_rate   => p_er_contribution_fixed_rate   --added for UK
      ,p_pty_attribute_category       => p_pty_attribute_category
      ,p_pty_attribute1               => p_pty_attribute1
      ,p_pty_attribute2               => p_pty_attribute2
      ,p_pty_attribute3               => p_pty_attribute3
      ,p_pty_attribute4               => p_pty_attribute4
      ,p_pty_attribute5               => p_pty_attribute5
      ,p_pty_attribute6               => p_pty_attribute6
      ,p_pty_attribute7               => p_pty_attribute7
      ,p_pty_attribute8               => p_pty_attribute8
      ,p_pty_attribute9               => p_pty_attribute9
      ,p_pty_attribute10              => p_pty_attribute10
      ,p_pty_attribute11              => p_pty_attribute11
      ,p_pty_attribute12              => p_pty_attribute12
      ,p_pty_attribute13              => p_pty_attribute13
      ,p_pty_attribute14              => p_pty_attribute14
      ,p_pty_attribute15              => p_pty_attribute15
      ,p_pty_attribute16              => p_pty_attribute16
      ,p_pty_attribute17              => p_pty_attribute17
      ,p_pty_attribute18              => p_pty_attribute18
      ,p_pty_attribute19              => p_pty_attribute19
      ,p_pty_attribute20              => p_pty_attribute20
      ,p_pty_information_category     => p_pty_information_category
      ,p_pty_information1             => p_pty_information1
      ,p_pty_information2             => p_pty_information2
      ,p_pty_information3             => p_pty_information3
      ,p_pty_information4             => p_pty_information4
      ,p_pty_information5             => p_pty_information5
      ,p_pty_information6             => p_pty_information6
      ,p_pty_information7             => p_pty_information7
      ,p_pty_information8             => p_pty_information8
      ,p_pty_information9             => p_pty_information9
      ,p_pty_information10            => p_pty_information10
      ,p_pty_information11            => p_pty_information11
      ,p_pty_information12            => p_pty_information12
      ,p_pty_information13            => p_pty_information13
      ,p_pty_information14            => p_pty_information14
      ,p_pty_information15            => p_pty_information15
      ,p_pty_information16            => p_pty_information16
      ,p_pty_information17            => p_pty_information17
      ,p_pty_information18            => p_pty_information18
      ,p_pty_information19            => p_pty_information19
      ,p_pty_information20            => p_pty_information20
      ,p_special_pension_type_code    => p_special_pension_type_code    -- added for NL Phase 2B
      ,p_pension_sub_category         => p_pension_sub_category         -- added for NL Phase 2B
      ,p_pension_basis_calc_method    => p_pension_basis_calc_method    -- added for NL Phase 2B
      ,p_pension_salary_balance       => p_pension_salary_balance       -- added for NL Phase 2B
      ,p_recurring_bonus_percent      => p_recurring_bonus_percent      -- added for NL Phase 2B
      ,p_non_recurring_bonus_percent  => p_non_recurring_bonus_percent  -- added for NL Phase 2B
      ,p_recurring_bonus_balance      => p_recurring_bonus_balance      -- added for NL Phase 2B
      ,p_non_recurring_bonus_balance  => p_non_recurring_bonus_balance  -- added for NL Phase 2B
      ,p_std_tax_reduction            => p_std_tax_reduction            -- added for NL Phase 2B
      ,p_spl_tax_reduction            => p_spl_tax_reduction            -- added for NL Phase 2B
      ,p_sig_sal_spl_tax_reduction    => p_sig_sal_spl_tax_reduction    -- added for NL Phase 2B
      ,p_sig_sal_non_tax_reduction    => p_sig_sal_non_tax_reduction    -- added for NL Phase 2B
      ,p_sig_sal_std_tax_reduction    => p_sig_sal_std_tax_reduction    -- added for NL Phase 2B
      ,p_sii_std_tax_reduction        => p_sii_std_tax_reduction        -- added for NL Phase 2B
      ,p_sii_spl_tax_reduction        => p_sii_spl_tax_reduction        -- added for NL Phase 2B
      ,p_sii_non_tax_reduction        => p_sii_non_tax_reduction        -- added for NL Phase 2B
      ,p_previous_year_bonus_included => p_previous_year_bonus_included -- added for NL Phase 2B
      ,p_recurring_bonus_period       => p_recurring_bonus_period       -- added for NL Phase 2B
      ,p_non_recurring_bonus_period   => p_non_recurring_bonus_period   -- added for NL Phase 2B
      ,p_ee_age_threshold             => p_ee_age_threshold             -- added for ABP TAR fixes
      ,p_er_age_threshold             => p_er_age_threshold             -- added for ABP TAR fixes
      ,p_ee_age_contribution          => p_ee_age_contribution          -- added for ABP TAR fixes
      ,p_er_age_contribution          => p_er_age_contribution          -- added for ABP TAR fixes
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      );
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Call After Process User Hook
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  begin
    hr_utility.set_location(' Before Calling User Hook : Update_Pension_Type_a',20);
    PQP_Pension_Types_BK2.Update_Pension_Type_a
      (p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_datetrack_mode               => p_datetrack_mode
      ,p_pension_type_id              => p_pension_type_id
      ,p_object_version_number        => l_object_version_number
      ,p_pension_type_name            => p_pension_type_name
      ,p_pension_category             => p_pension_category
      ,p_pension_provider_type        => p_pension_provider_type
      ,p_salary_calculation_method    => p_salary_calculation_method
      ,p_threshold_conversion_rule    => p_threshold_conversion_rule
      ,p_contribution_conversion_rule => p_contribution_conversion_rule
      ,p_er_annual_limit              => l_er_annual_limit
      ,p_ee_annual_limit              => l_ee_annual_limit
      ,p_er_annual_salary_threshold   => l_er_annual_salary_threshold
      ,p_ee_annual_salary_threshold   => l_ee_annual_salary_threshold
      ,p_business_group_id            => p_business_group_id
      ,p_legislation_code             => p_legislation_code
      ,p_description                  => p_description
      ,p_minimum_age                  => p_minimum_age
      ,p_ee_contribution_percent      => p_ee_contribution_percent
      ,p_maximum_age                  => p_maximum_age
      ,p_er_contribution_percent      => p_er_contribution_percent
      ,p_ee_annual_contribution       => p_ee_annual_contribution
      ,p_er_annual_contribution       => p_er_annual_contribution
      ,p_annual_premium_amount        => p_annual_premium_amount
      ,p_ee_contribution_bal_type_id  => p_ee_contribution_bal_type_id
      ,p_er_contribution_bal_type_id  => p_er_contribution_bal_type_id
      ,p_balance_init_element_type_id => p_balance_init_element_type_id
      ,p_ee_contribution_fixed_rate   => p_ee_contribution_fixed_rate   --added for UK
      ,p_er_contribution_fixed_rate   => p_er_contribution_fixed_rate   --added for UK
      ,p_pty_attribute_category       => p_pty_attribute_category
      ,p_pty_attribute1               => p_pty_attribute1
      ,p_pty_attribute2               => p_pty_attribute2
      ,p_pty_attribute3               => p_pty_attribute3
      ,p_pty_attribute4               => p_pty_attribute4
      ,p_pty_attribute5               => p_pty_attribute5
      ,p_pty_attribute6               => p_pty_attribute6
      ,p_pty_attribute7               => p_pty_attribute7
      ,p_pty_attribute8               => p_pty_attribute8
      ,p_pty_attribute9               => p_pty_attribute9
      ,p_pty_attribute10              => p_pty_attribute10
      ,p_pty_attribute11              => p_pty_attribute11
      ,p_pty_attribute12              => p_pty_attribute12
      ,p_pty_attribute13              => p_pty_attribute13
      ,p_pty_attribute14              => p_pty_attribute14
      ,p_pty_attribute15              => p_pty_attribute15
      ,p_pty_attribute16              => p_pty_attribute16
      ,p_pty_attribute17              => p_pty_attribute17
      ,p_pty_attribute18              => p_pty_attribute18
      ,p_pty_attribute19              => p_pty_attribute19
      ,p_pty_attribute20              => p_pty_attribute20
      ,p_pty_information_category     => p_pty_information_category
      ,p_pty_information1             => p_pty_information1
      ,p_pty_information2             => p_pty_information2
      ,p_pty_information3             => p_pty_information3
      ,p_pty_information4             => p_pty_information4
      ,p_pty_information5             => p_pty_information5
      ,p_pty_information6             => p_pty_information6
      ,p_pty_information7             => p_pty_information7
      ,p_pty_information8             => p_pty_information8
      ,p_pty_information9             => p_pty_information9
      ,p_pty_information10            => p_pty_information10
      ,p_pty_information11            => p_pty_information11
      ,p_pty_information12            => p_pty_information12
      ,p_pty_information13            => p_pty_information13
      ,p_pty_information14            => p_pty_information14
      ,p_pty_information15            => p_pty_information15
      ,p_pty_information16            => p_pty_information16
      ,p_pty_information17            => p_pty_information17
      ,p_pty_information18            => p_pty_information18
      ,p_pty_information19            => p_pty_information19
      ,p_pty_information20            => p_pty_information20
      ,p_special_pension_type_code    => p_special_pension_type_code    -- added for NL Phase 2B
      ,p_pension_sub_category         => p_pension_sub_category         -- added for NL Phase 2B
      ,p_pension_basis_calc_method    => p_pension_basis_calc_method    -- added for NL Phase 2B
      ,p_pension_salary_balance       => p_pension_salary_balance       -- added for NL Phase 2B
      ,p_recurring_bonus_percent      => p_recurring_bonus_percent      -- added for NL Phase 2B
      ,p_non_recurring_bonus_percent  => p_non_recurring_bonus_percent  -- added for NL Phase 2B
      ,p_recurring_bonus_balance      => p_recurring_bonus_balance      -- added for NL Phase 2B
      ,p_non_recurring_bonus_balance  => p_non_recurring_bonus_balance  -- added for NL Phase 2B
      ,p_std_tax_reduction            => p_std_tax_reduction            -- added for NL Phase 2B
      ,p_spl_tax_reduction            => p_spl_tax_reduction            -- added for NL Phase 2B
      ,p_sig_sal_spl_tax_reduction    => p_sig_sal_spl_tax_reduction    -- added for NL Phase 2B
      ,p_sig_sal_non_tax_reduction    => p_sig_sal_non_tax_reduction    -- added for NL Phase 2B
      ,p_sig_sal_std_tax_reduction    => p_sig_sal_std_tax_reduction    -- added for NL Phase 2B
      ,p_sii_std_tax_reduction        => p_sii_std_tax_reduction        -- added for NL Phase 2B
      ,p_sii_spl_tax_reduction        => p_sii_spl_tax_reduction        -- added for NL Phase 2B
      ,p_sii_non_tax_reduction        => p_sii_non_tax_reduction        -- added for NL Phase 2B
      ,p_previous_year_bonus_included => p_previous_year_bonus_included -- added for NL Phase 2B
      ,p_recurring_bonus_period       => p_recurring_bonus_period       -- added for NL Phase 2B
      ,p_non_recurring_bonus_period   => p_non_recurring_bonus_period   -- added for NL Phase 2B
      ,p_ee_age_threshold             => p_ee_age_threshold             -- added for ABP TAR fixes
      ,p_er_age_threshold             => p_er_age_threshold             -- added for ABP TAR fixes
      ,p_ee_age_contribution          => p_ee_age_contribution          -- added for ABP TAR fixes
      ,p_er_age_contribution          => p_er_age_contribution          -- added for ABP TAR fixes
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      );
      hr_utility.set_location(' After Calling User Hook : Update_Pension_Type_a',20);
  Exception
    When hr_api.cannot_find_prog_unit Then
      hr_utility.set_location('Exception in User Hook : Update_Pension_Type_a',25);
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_Pension_Type'
        ,p_hook_type   => 'AP'
        );
  End;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- When in validation only mode raise the Validate_Enabled exception
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  If p_validate Then
     raise hr_api.validate_enabled;
  End If;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Set all output arguments
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_object_version_number  := l_object_version_number;
  --p_api_warning            := l_api_warning;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
Exception
  When hr_api.validate_enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    Rollback To Update_Pension_Type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date   := Null;
    p_effective_end_date     := Null;
    --p_api_warning            := l_api_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  When Others Then
    --
    -- A validation or unexpected error has occured
    --
    Rollback to Update_Pension_Type;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;

End Update_Pension_Type;

-- ----------------------------------------------------------------------------
-- |--------------------------< get_pty_bal_ele_info >------------------------|
-- ----------------------------------------------------------------------------
Procedure Get_Pty_Bal_Ele_Info
  (p_pension_type_id             in            number
  ,p_effective_date              in            date
  ,p_ee_contribution_bal_type_id    out nocopy number
  ,p_er_contribution_bal_type_id    out nocopy number
  ,p_balance_init_ele_type_id       out nocopy number
  )
Is
  --
  Cursor csr_get_pty_bal_ele_info
  Is
  Select ee_contribution_bal_type_id
        ,er_contribution_bal_type_id
        ,balance_init_element_type_id
    From pqp_pension_types_f
   Where pension_type_id = p_pension_type_id
     And p_effective_date Between effective_start_date
                              And effective_end_date;

  l_proc               varchar2(80) := g_package || 'Get_Pty_Bal_Ele_Info';
  l_pty_rec            csr_get_pty_bal_ele_info%ROWTYPE;
  --
Begin
  --
  hr_utility.set_location ('Entering: '||l_proc, 10);

  OPEN csr_get_pty_bal_ele_info;
  FETCH csr_get_pty_bal_ele_info INTO l_pty_rec;
  -- No need to check for cursor found as this
  -- will be handled in the row handler
  CLOSE csr_get_pty_bal_ele_info;

  p_ee_contribution_bal_type_id := l_pty_rec.ee_contribution_bal_type_id;
  p_er_contribution_bal_type_id := l_pty_rec.er_contribution_bal_type_id;
  p_balance_init_ele_type_id    := l_pty_rec.balance_init_element_type_id;

  --
  hr_utility.set_location ('Leaving: '||l_proc, 20);
  --
Exception

  When Others Then
    hr_utility.set_location ('Others Exception occurred in '||l_proc, 30);
    p_ee_contribution_bal_type_id := NULL;
    p_er_contribution_bal_type_id := NULL;
    p_balance_init_ele_type_id    := NULL;
    RAISE;

End Get_Pty_Bal_Ele_Info;
--

-- ----------------------------------------------------------------------------
-- |--------------------------< Delete_Balance_Init_Ele >---------------------|
-- ----------------------------------------------------------------------------
Procedure Delete_Balance_Init_Ele
  (p_balance_init_ele_type_id     in     number
  ,p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  )
Is
  --
  -- Cursor to retrieve input value information
  Cursor csr_get_ipv_info
  Is
  Select input_value_id
        ,object_version_number
    From pay_input_values_f
   Where element_type_id = p_balance_init_ele_type_id
     And p_effective_date Between effective_start_date
                              And effective_end_date;

  -- Cursor to retrieve element ovn
  Cursor csr_get_ele_ovn
  Is
  Select object_version_number
    From pay_element_types_f
   Where element_type_id  = p_balance_init_ele_type_id
     And p_effective_date Between effective_start_date
                              And effective_end_date;

  l_proc           varchar2(80) := g_package || 'Delete_Balance_Init_Ele';
  l_bal_feed_warn  boolean;
  l_prs_rule_warn  boolean;
  l_ele_ovn        number;
  l_eff_start_date date;
  l_eff_end_date   date;

  --
Begin
  --
  hr_utility.set_location ('Entering: '||l_proc, 10);
  --

  -- Delete the input values for this element first
  -- Only do this if datetrack mode is not 'DELETE'

  IF p_datetrack_mode <> 'DELETE' THEN

    FOR csr_get_ipv_rec IN csr_get_ipv_info
    LOOP

      -- Call the api to delete input values
      hr_utility.set_location (l_proc, 20);
      --
      pay_input_value_api.delete_input_value
        (p_validate              => p_validate
        ,p_effective_date        => p_effective_date
        ,p_datetrack_delete_mode => p_datetrack_mode
        ,p_input_value_id        => csr_get_ipv_rec.input_value_id
        ,p_object_version_number => csr_get_ipv_rec.object_version_number
        ,p_effective_start_date  => l_eff_start_date
        ,p_effective_end_date    => l_eff_end_date
        ,p_balance_feeds_warning => l_bal_feed_warn
        );

    END LOOP;

  END IF; -- End if of date track mode not delete check ...

  -- Delete the element now
  hr_utility.set_location (l_proc, 30);

  -- Get ele ovn
  OPEN csr_get_ele_ovn;
  FETCH csr_get_ele_ovn INTO l_ele_ovn;

  IF csr_get_ele_ovn%FOUND THEN
     -- Call API to delete element types
    pay_element_types_api.delete_element_type
      (p_validate                 => p_validate
      ,p_effective_date           => p_effective_date
      ,p_datetrack_delete_mode    => p_datetrack_mode
      ,p_element_type_id          => p_balance_init_ele_type_id
      ,p_object_version_number    => l_ele_ovn
      ,p_effective_start_date     => l_eff_start_date
      ,p_effective_end_date       => l_eff_end_date
      ,p_balance_feeds_warning    => l_bal_feed_warn
      ,p_processing_rules_warning => l_prs_rule_warn
      );

  END IF; -- End if of check element exists check ...

  CLOSE csr_get_ele_ovn;
  --
  hr_utility.set_location ('Leaving: '||l_proc, 40);
  --
End Delete_Balance_Init_Ele;
--

-- ----------------------------------------------------------------------------
-- |--------------------------< Delete_EE_ER_Balances >-----------------------|
-- ----------------------------------------------------------------------------
Procedure Delete_EE_ER_Balances
  (p_ee_contribution_bal_type_id in     number
  ,p_er_contribution_bal_type_id in     number
  )
Is
  --
  -- Cursor to retrieve the rowid for balances
  Cursor csr_get_bal_rowid (c_balance_type_id number)
  Is
  Select rowid
    From pay_balance_types
   Where balance_type_id = c_balance_type_id;

  l_proc        varchar2(80) := g_package || 'Delete_EE_ER_Balances';
  l_rowid       ROWID;
  i             NUMBER;

  TYPE t_number IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

  l_bal_type_id t_number;
  --
Begin
  --
  hr_utility.set_location ('Entering: '||l_proc, 10);
  --
  i := 0;
  i := i + 1 ;
  l_bal_type_id (i) := p_ee_contribution_bal_type_id;

  i := i + 1;
  l_bal_type_id (i) := p_er_contribution_bal_type_id;

  FOR i IN 1..l_bal_type_id.COUNT LOOP

    -- Get the row id information for the balance
    OPEN csr_get_bal_rowid (l_bal_type_id (i));
    FETCH csr_get_bal_rowid INTO l_rowid;

    IF csr_get_bal_rowid%FOUND THEN

      -- Call api to delete balances
      -- This api does a delete cascade
      -- so no need to delete feeds / dimensions
      -- separately

      pay_balance_types_pkg.delete_row
        (x_rowid           => l_rowid
        ,x_balance_type_id => l_bal_type_id (i)
        );
    END IF; -- End if of balance row found check ...
    CLOSE csr_get_bal_rowid;

  END LOOP;
  --
  hr_utility.set_location ('Leaving: '||l_proc, 20);
  --
End Delete_EE_ER_Balances;
--

-- ---------------------------------------------------------------------
--|-----------------------<end_date_org_info>---------------------------|
-- ---------------------------------------------------------------------
--
PROCEDURE end_date_org_info (
                            p_pension_type_id    in pqp_pension_types_f.pension_type_id%TYPE
                           ,p_effective_end_date in date
                            ) IS

CURSOR c_get_org_info IS
  SELECT rowid,
         org_information_id,
         organization_id,
         org_information1,
         nvl(org_information2,'31/12/4712') org_information2,
         org_information3
    FROM hr_organization_information
  WHERE  org_information_context = 'PQP_NL_ABP_PT'
    AND  org_information3 = to_char(p_pension_type_id)
    AND  trunc(to_date(nvl(org_information2,'31/12/4712'),'DD/MM/RRRR')) > p_effective_end_date;

BEGIN

SAVEPOINT end_date_org_info;
hr_utility.set_location('In end date org info'||p_pension_type_id,10);
-- fetch all the org information rows in the org information EIT
-- where the pension type is the same as the current pension type
-- and the end date is greater than the effective end date
FOR temp_rec in c_get_org_info
 LOOP
   hr_utility.set_location('In end date org info',20);
   -- for each of these rows call the hr_org_information_pkg.update_row proc
   hr_org_information_pkg.update_row
     (x_rowid                   =>    temp_rec.rowid
     ,x_org_information_id      =>    temp_rec.org_information_id
     ,x_org_information_context =>    'PQP_NL_ABP_PT'
     ,x_organization_id         =>    temp_rec.organization_id
     ,x_org_information1        =>    temp_rec.org_information1
     ,x_org_information2        =>    to_char(p_effective_end_date,'DD-MON-RR')
     ,x_org_information3        =>    temp_rec.org_information3
     ,x_org_information4        =>    null
     ,x_org_information5        =>    null
     ,x_org_information6        =>    null
     ,x_org_information7        =>    null
     ,x_org_information8        =>    null
     ,x_org_information9        =>    null
     ,x_org_information10       =>    null
     ,x_org_information11       =>    null
     ,x_org_information12       =>    null
     ,x_org_information13       =>    null
     ,x_org_information14       =>    null
     ,x_org_information15       =>    null
     ,x_org_information16       =>    null
     ,x_org_information17       =>    null
     ,x_org_information18       =>    null
     ,x_org_information19       =>    null
     ,x_org_information20       =>    null
     ,x_attribute_category      =>    null
     ,x_attribute1              =>    null
     ,x_attribute2              =>    null
     ,x_attribute3              =>    null
     ,x_attribute4              =>    null
     ,x_attribute5              =>    null
     ,x_attribute6              =>    null
     ,x_attribute7              =>    null
     ,x_attribute8              =>    null
     ,x_attribute9              =>    null
     ,x_attribute10             =>    null
     ,x_attribute11             =>    null
     ,x_attribute12             =>    null
     ,x_attribute13             =>    null
     ,x_attribute14             =>    null
     ,x_attribute15             =>    null
     ,x_attribute16             =>    null
     ,x_attribute17             =>    null
     ,x_attribute18             =>    null
     ,x_attribute19             =>    null
     ,x_attribute20             =>    null
     );

 END LOOP;

EXCEPTION

WHEN Others THEN

    rollback to end_date_org_info;
    RAISE;

END end_date_org_info;


-- ----------------------------------------------------------------------------
-- |--------------------------< Delete_Pension_Type >--------------------------|
-- ----------------------------------------------------------------------------
Procedure Delete_Pension_Type
  (p_validate                     in     Boolean
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_pension_type_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_api_warning                     out nocopy varchar2
  )Is

  l_proc                         varchar2(150) := g_package||'Delete_Pension_Type';
  l_object_version_number        pqp_pension_types_f.object_version_number%TYPE;
  l_effective_date               date;
  l_effective_start_date         date;
  l_effective_end_date           date;
  l_ee_contribution_bal_type_id  number;
  l_er_contribution_bal_type_id  number;
  l_balance_init_ele_type_id     number;
  l_chk_abp_pt                   number;

--Cursor to check that the pension type is a ABP Pension Type
CURSOR c_chk_abp_pt IS
   SELECT 1
    FROM  pqp_pension_types_f
   WHERE  pension_type_id = p_pension_type_id
    AND   special_pension_type_code = 'ABP';

Begin
--  hr_utility.trace_on(null,'rkpipe');
  -- if the start date is earlier than the least start date of the PT,raise error
  hr_utility.set_location('Entering:'|| l_proc, 10);
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Issue a savepoint
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  savepoint Delete_Pension_Type;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Truncate the time portion from all IN date parameters
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  l_effective_date := Trunc(p_effective_date);
  l_object_version_number := p_object_version_number;

  OPEN c_chk_abp_pt;
  FETCH c_chk_abp_pt INTO l_chk_abp_pt;
  IF c_chk_abp_pt%FOUND THEN
     -- if the pension type is a NL ABP PT,do not delete the EE/ER balances
     CLOSE c_chk_abp_pt;
     l_chk_abp_pt := 1;
  ELSE
     CLOSE c_chk_abp_pt;
     l_chk_abp_pt := 0;
  END IF;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Call Before Process User Hook
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Begin
    p_api_warning := hr_api.g_varchar2;
    hr_utility.set_location('Before Calling User Hook Delete_Pension_Type_b',20);
    PQP_Pension_Types_BK3.Delete_Pension_Type_b
      (p_validate              =>  p_validate
      ,p_effective_date        =>  p_effective_date
      ,p_datetrack_mode        =>  p_datetrack_mode
      ,p_pension_type_id       =>  p_pension_type_id
      ,p_object_version_number =>  l_object_version_number
      );
      hr_utility.set_location('After Calling User Hook Delete_Pension_Type_b',20);
  Exception
    When hr_api.cannot_find_prog_unit Then
      hr_utility.set_location('Exception in User Hook Delete_Pension_Type_b',25);
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Delete_Pension_Type'
        ,p_hook_type   => 'BP'
        );
  End;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Validation in addition to Row Handlers
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  --
  -- Added code to delete EE and ER balances plus the intialization
  -- Element created by the pension types API before deleting
  -- pension type in ver 115.17
  -- We do not want to delete these objects now but only after deleting
  -- pension types, as there may be validations preventing
  -- deleting a pension type, so we want to validate this information
  -- first. But we will have to get the balance and element information
  -- associated with this pension type as this will be lost after
  -- calling del rhi procedure

  -- Call function get_pty_bal_ele_info
     hr_utility.set_location (l_proc, 25);
     get_pty_bal_ele_info
       (p_pension_type_id             => p_pension_type_id
       ,p_effective_date              => p_effective_date
       ,p_ee_contribution_bal_type_id => l_ee_contribution_bal_type_id
       ,p_er_contribution_bal_type_id => l_er_contribution_bal_type_id
       ,p_balance_init_ele_type_id    => l_balance_init_ele_type_id
       );

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Process Logic - Call the row-handler del procedure
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     hr_utility.set_location('Before calling row-handler pqp_pty_del.del',30);
     pqp_pty_del.del
      (p_effective_date        =>  p_effective_date
      ,p_datetrack_mode        =>  p_datetrack_mode
      ,p_pension_type_id       =>  p_pension_type_id
      ,p_object_version_number =>  l_object_version_number
      ,p_effective_start_date  =>  l_effective_start_date
      ,p_effective_end_date    =>  l_effective_end_date
      );

  -- Delete the EE and ER balances and Balance Init Element
  -- First delete the element

     hr_utility.set_location (l_proc, 35);
     delete_balance_init_ele
       (p_balance_init_ele_type_id  => l_balance_init_ele_type_id
       ,p_validate                  => p_validate
       ,p_effective_date            => p_effective_date
       ,p_datetrack_mode            => p_datetrack_mode
       );

     -- Delete balance only if date track mode is ZAP
     hr_utility.set_location (l_proc, 36);

     IF p_datetrack_mode = hr_api.g_zap THEN
       --only if the PT is not a ABP PT, delete the EE/ER balances
       IF l_chk_abp_pt = 0 THEN
          delete_ee_er_balances
            (p_ee_contribution_bal_type_id => l_ee_contribution_bal_type_id
            ,p_er_contribution_bal_type_id => l_er_contribution_bal_type_id
            );
        END IF;

     END IF; -- End if of date track mode is ZAP check ...

  -- End of changes for deleting balance and init elements

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Call After Process User Hook
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Begin
    hr_utility.set_location('Before Calling User Hook Delete_Pension_Type_a',20);
    PQP_Pension_Types_BK3.Delete_Pension_Type_a
      (p_validate              =>  p_validate
      ,p_effective_date        =>  p_effective_date
      ,p_datetrack_mode        =>  p_datetrack_mode
      ,p_pension_type_id       =>  p_pension_type_id
      ,p_object_version_number =>  l_object_version_number
      ,p_effective_start_date  =>  l_effective_start_date
      ,p_effective_end_date    =>  l_effective_end_date
      );
      hr_utility.set_location('After Calling User Hook Delete_Pension_Type_a',20);
  Exception
    When hr_api.cannot_find_prog_unit Then
      hr_utility.set_location('Exception in User Hook Delete_Pension_Type_a',25);
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Delete_Pension_Type'
        ,p_hook_type   => 'AP'
        );
  End;

  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- When in validation only mode raise the Validate_Enabled exception
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  If p_validate Then
     raise hr_api.validate_enabled;
  End If;
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  -- Set all output arguments
  -- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
--  hr_utility.trace_off;
Exception
  When hr_api.validate_enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    Rollback To Delete_Pension_Type;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date   := Null;
    p_effective_end_date     := Null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  When Others Then
    --
    -- A validation or unexpected error has occured
    --
    Rollback to Delete_Pension_Type;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    Raise;

End Delete_Pension_Type;

End PQP_Pension_Types_api;

/
