--------------------------------------------------------
--  DDL for Package Body PAY_ACCRUAL_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ACCRUAL_PLANS_PKG" as
/* $Header: pyappap.pkb 115.3 99/08/24 06:49:02 porting shi $ */


PROCEDURE Insert_Row(X_Rowid                        IN OUT VARCHAR2,
                     X_Accrual_Plan_Id                     IN OUT NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Accrual_Plan_Element_Type_Id        NUMBER,
                     X_Pto_Input_Value_Id                  NUMBER,
                     X_Co_Input_Value_Id                   NUMBER,
                     X_Residual_Input_Value_Id             NUMBER,
                     X_Accrual_Category                    VARCHAR2,
                     X_Accrual_Plan_Name                   VARCHAR2,
                     X_Accrual_Start                       VARCHAR2,
                     X_Accrual_Units_Of_Measure            VARCHAR2,
                     X_Ineligible_Period_Length            NUMBER,
                     X_Ineligible_Period_Type              VARCHAR2
 ) IS
   CURSOR C IS SELECT rowid FROM PAY_ACCRUAL_PLANS
             WHERE accrual_plan_id = X_Accrual_Plan_Id;

    CURSOR C2 IS SELECT pay_accrual_plans_s.nextval FROM sys.dual;
BEGIN

   if (X_Accrual_Plan_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Accrual_Plan_Id;
     CLOSE C2;
   end if;
  INSERT INTO PAY_ACCRUAL_PLANS(
          accrual_plan_id,
          business_group_id,
          accrual_plan_element_type_id,
          pto_input_value_id,
          co_input_value_id,
          residual_input_value_id,
          accrual_category,
          accrual_plan_name,
          accrual_start,
          accrual_units_of_measure,
          ineligible_period_length,
          ineligible_period_type
         ) VALUES (
          X_Accrual_Plan_Id,
          X_Business_Group_Id,
          X_Accrual_Plan_Element_Type_Id,
          X_Pto_Input_Value_Id,
          X_Co_Input_Value_Id,
          X_Residual_Input_Value_Id,
          X_Accrual_Category,
          X_Accrual_Plan_Name,
          X_Accrual_Start,
          X_Accrual_Units_Of_Measure,
          X_Ineligible_Period_Length,
          X_Ineligible_Period_Type
  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Accrual_Plan_Id                       NUMBER,
                   X_Business_Group_Id                     NUMBER,
                   X_Accrual_Plan_Element_Type_Id          NUMBER,
                   X_Pto_Input_Value_Id                    NUMBER,
                   X_Co_Input_Value_Id                     NUMBER,
                   X_Residual_Input_Value_Id               NUMBER,
                   X_Accrual_Category                      VARCHAR2,
                   X_Accrual_Plan_Name                     VARCHAR2,
                   X_Accrual_Start                         VARCHAR2,
                   X_Accrual_Units_Of_Measure              VARCHAR2,
                   X_Ineligible_Period_Length              NUMBER,
                   X_Ineligible_Period_Type                VARCHAR2
) IS
  CURSOR C IS
      SELECT *
      FROM   PAY_ACCRUAL_PLANS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Accrual_Plan_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
-- Added by RMAMGAIN
--
Recinfo.accrual_category := RTRIM(Recinfo.accrual_category);
Recinfo.accrual_plan_name := RTRIM(Recinfo.accrual_plan_name);
Recinfo.accrual_start := RTRIM(Recinfo.accrual_start);
Recinfo.accrual_units_of_measure := RTRIM(Recinfo.accrual_units_of_measure);
Recinfo.ineligible_period_type := RTRIM(Recinfo.ineligible_period_type);
--
-- END
  if (
          (   (Recinfo.accrual_plan_id = X_Accrual_Plan_Id)
           OR (    (Recinfo.accrual_plan_id IS NULL)
               AND (X_Accrual_Plan_Id IS NULL)))
      AND (   (Recinfo.business_group_id = X_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (X_Business_Group_Id IS NULL)))
      AND (   (Recinfo.accrual_plan_element_type_id = X_Accrual_Plan_Element_Type_Id)
           OR (    (Recinfo.accrual_plan_element_type_id IS NULL)
               AND (X_Accrual_Plan_Element_Type_Id IS NULL)))
      AND (   (Recinfo.pto_input_value_id = X_Pto_Input_Value_Id)
           OR (    (Recinfo.pto_input_value_id IS NULL)
               AND (X_Pto_Input_Value_Id IS NULL)))
      AND (   (Recinfo.co_input_value_id = X_Co_Input_Value_Id)
           OR (    (Recinfo.co_input_value_id IS NULL)
               AND (X_Co_Input_Value_Id IS NULL)))
      AND (   (Recinfo.residual_input_value_id = X_Residual_Input_Value_Id)
           OR (    (Recinfo.residual_input_value_id IS NULL)
               AND (X_Residual_Input_Value_Id IS NULL)))
      AND (   (Recinfo.accrual_category = X_Accrual_Category)
           OR (    (Recinfo.accrual_category IS NULL)
               AND (X_Accrual_Category IS NULL)))
      AND (   (Recinfo.accrual_plan_name = X_Accrual_Plan_Name)
           OR (    (Recinfo.accrual_plan_name IS NULL)
               AND (X_Accrual_Plan_Name IS NULL)))
      AND (   (Recinfo.accrual_start = X_Accrual_Start)
           OR (    (Recinfo.accrual_start IS NULL)
               AND (X_Accrual_Start IS NULL)))
      AND (   (Recinfo.accrual_units_of_measure = X_Accrual_Units_Of_Measure)
           OR (    (Recinfo.accrual_units_of_measure IS NULL)
               AND (X_Accrual_Units_Of_Measure IS NULL)))
      AND (   (Recinfo.ineligible_period_length = X_Ineligible_Period_Length)
           OR (    (Recinfo.ineligible_period_length IS NULL)
               AND (X_Ineligible_Period_Length IS NULL)))
      AND (   (Recinfo.ineligible_period_type = X_Ineligible_Period_Type)
           OR (    (Recinfo.ineligible_period_type IS NULL)
               AND (X_Ineligible_Period_Type IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Accrual_Plan_Id                     NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Accrual_Plan_Element_Type_Id        NUMBER,
                     X_Pto_Input_Value_Id                  NUMBER,
                     X_Co_Input_Value_Id                   NUMBER,
                     X_Residual_Input_Value_Id             NUMBER,
                     X_Accrual_Category                    VARCHAR2,
                     X_Accrual_Plan_Name                   VARCHAR2,
                     X_Accrual_Start                       VARCHAR2,
                     X_Accrual_Units_Of_Measure            VARCHAR2,
                     X_Ineligible_Period_Length            NUMBER,
                     X_Ineligible_Period_Type              VARCHAR2
) IS
BEGIN
  UPDATE PAY_ACCRUAL_PLANS
  SET
    accrual_plan_id                           =    X_Accrual_Plan_Id,
    business_group_id                         =    X_Business_Group_Id,
    accrual_plan_element_type_id              =    X_Accrual_Plan_Element_Type_Id,
    pto_input_value_id                        =    X_Pto_Input_Value_Id,
    co_input_value_id                         =    X_Co_Input_Value_Id,
    residual_input_value_id                   =    X_Residual_Input_Value_Id,
    accrual_category                          =    X_Accrual_Category,
    accrual_plan_name                         =    X_Accrual_Plan_Name,
    accrual_start                             =    X_Accrual_Start,
    accrual_units_of_measure                  =    X_Accrual_Units_Of_Measure,
    ineligible_period_length                  =    X_Ineligible_Period_Length,
    ineligible_period_type                    =    X_Ineligible_Period_Type
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM PAY_ACCRUAL_PLANS
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;
--
--
--
/*
   ****************************************************************************
   NAME        chk_plan_name

   DESCRIPTION validates the plan name - the name must not be duplicated within
               the accrual plans table; the name must not cause any clashes
               with the element type names that the plan will create

   NOTES       none
   ****************************************************************************
*/
PROCEDURE chk_plan_name(p_plan_name       IN varchar2,
                        p_accrual_plan_id IN number) IS
--
   l_comb_exists VARCHAR2(2);
--
   CURSOR dup_rec1 IS
   select 'Y'
   from   PAY_ACCRUAL_PLANS
   where  upper(ACCRUAL_PLAN_NAME) = upper(p_plan_name)
   and  ((p_accrual_plan_id is null)
     or
         (p_accrual_plan_id is not null
      and
          ACCRUAL_PLAN_ID <> p_accrual_plan_id));
--
   CURSOR dup_rec2 IS
   select 'Y'
   from   PAY_ELEMENT_TYPES_F
   where  upper(ELEMENT_NAME) in
            (upper(p_plan_name),
             'RESIDUAL ' || upper(p_plan_name),
             'CARRIED OVER ' || upper(p_plan_name));
--
BEGIN
--
   l_comb_exists := 'N';
--
-- determine whether the plan name has been duplicated - if a record is found
-- then the local variable will be set to 'Y', otherwise it will remain 'N'
--
   OPEN dup_rec1;
   FETCH dup_rec1 INTO l_comb_exists;
   CLOSE dup_rec1;
--
-- go ahead and check the value of the local variable
--
   IF (l_comb_exists = 'Y') THEN
      hr_utility.set_message(801, 'HR_13163_PTO_DUP_PLAN_NAME');
      hr_utility.raise_error;
   END IF;
--
--
   l_comb_exists := 'N';
--
-- determine whether any element types exist which would cause a clash with the
-- plan's elements that it will create
--
   OPEN dup_rec2;
   FETCH dup_rec2 INTO l_comb_exists;
   CLOSE dup_rec2;
--
   IF (l_comb_exists = 'Y') THEN
      hr_utility.set_message(801, 'HR_13164_PTO_INVALID_PLAN_NAME');
      hr_utility.raise_error;
   END IF;
--
END chk_plan_name;
--
--
--
/*
   ****************************************************************************
   NAME        insert_validation

   DESCRIPTION performs all of the validation required at insert time

   NOTES       none
   ****************************************************************************
*/
PROCEDURE insert_validation(p_plan_name       IN varchar2,
                            p_accrual_plan_id IN number) IS
--
BEGIN
--
  PAY_ACCRUAL_PLANS_PKG.CHK_PLAN_NAME(p_plan_name,
                                      p_accrual_plan_id);
END insert_validation;
--
--
--
/*
   ****************************************************************************
   NAME        create_element

   DESCRIPTION calls the function PAY_DB_PAY_SETUP.CREATE_ELEMENT,The sole
	       reason for this is to cut down on space and reduce the margin
	       for errors in the call, apssing only the things that change.

   NOTES       anticipate the only use for this is to be called from the
               pre_insert_actions routine in this package.

	       Added p_legislation_code and p_currency_code to the param list
	       passed in and used them instead of the hard coded US and USD
	       in the calls to PAY_DB_PAY_SETUP.create_element. RMF 27-Nov-95.
   ****************************************************************************
*/
FUNCTION create_element(p_element_name          IN varchar2,
                        p_element_description   IN varchar2,
                        p_processing_type       IN varchar2,
                        p_bg_name               IN varchar2,
                        p_classification_name   IN varchar2,
			p_legislation_code      IN varchar2,
			p_currency_code         IN varchar2,
                        p_post_termination_rule IN varchar2)
   RETURN number IS
--
   l_effective_start_date date;
   l_effective_end_date  date;
   l_element_type_id      number;
BEGIN
--
   hr_utility.set_location('pay_accrual_plans_pkg.create_element',1);
   l_effective_start_date := hr_general.start_of_time;
   l_effective_end_date   := hr_general.end_of_time;
--
   l_element_type_id := PAY_DB_PAY_SETUP.create_element
      (p_element_name           => p_element_name,
       p_description            => p_element_description,
       p_reporting_name         => '',
       p_classification_name    => p_classification_name,
       p_input_currency_code    => p_currency_code,
       p_output_currency_code   => p_currency_code,
       p_processing_type        => p_processing_type,
       p_mult_entries_allowed   => 'N',
       p_formula_id             => '',
       p_processing_priority    => '',
       p_closed_for_entry_flag  => 'N',
       p_standard_link_flag     => 'N',
       p_qual_length_of_service => '',
       p_qual_units             => '',
       p_qual_age               => '',
       p_process_in_run_flag    => 'Y',
       p_post_termination_rule  => p_post_termination_rule,
       p_indirect_only_flag     => 'N',
       p_adjustment_only_flag   => 'N',
       p_add_entry_allowed_flag => 'N',
       p_multiply_value_flag    => 'N',
       p_effective_start_date   => l_effective_start_date,
       p_effective_end_date     => l_effective_end_date,
       p_business_group_name    => p_bg_name,
       p_legislation_code       => p_legislation_code,
       p_legislation_subgroup   => '');
--
   return l_element_type_id;
--
end create_element;
--
--
--
/*
   ****************************************************************************
   NAME        create_input_value

   DESCRIPTION performs all that is required to create an input value -

                  create the input value

                  validate the values

                  create the DBI'd, balance feeds, etc

   NOTES       anticipate the only use for this is to be called from the
               pre_insert_actions routine in this package.

	       Added p_legislation_code to the param list passed in and used
	       it instead of the hard coded US in the calls below.
	       RMF 27-Nov-95.
   ****************************************************************************
*/
FUNCTION create_input_value(p_element_name              IN varchar2,
                            p_input_value_name          IN varchar2,
                            p_uom_code                  IN varchar2,
                            p_bg_name                   IN varchar2,
                            p_element_type_id           IN number,
                            p_primary_classification_id IN number,
                            p_business_group_id         IN number,
                            p_recurring_flag            IN varchar2,
			    p_legislation_code          IN varchar2,
                            p_classification_type       IN varchar2)
   RETURN number IS
--
   l_effective_start_date date;
   l_effective_end_date   date;
   l_input_value_id       number;
--
BEGIN
--
   hr_utility.set_location('pay_accrual_plans_pkg.create_input_value',1);
   l_effective_start_date := hr_general.start_of_time;
   l_effective_end_date   := hr_general.end_of_time;
--
   l_input_value_id := pay_db_pay_setup.create_input_value(
      p_element_name              => p_element_name,
      p_name                      => p_input_value_name,
      p_uom                       => '',
      p_uom_code                  => p_uom_code,
      p_mandatory_flag            => 'N',
      p_generate_db_item_flag     => 'Y',
      p_default_value             => '',
      p_min_value                 => '',
      p_max_value                 => '',
      p_warning_or_error          => '',
      p_lookup_type               => '',
      p_formula_id                => '',
      p_hot_default_flag          => 'N',
      p_display_sequence          => 1,
      p_business_group_name       => p_bg_name,
      p_effective_start_date      => l_effective_start_date,
      p_effective_end_date        => l_effective_end_date);
--
   hr_input_values.chk_input_value(
      p_element_type_id           => p_element_type_id,
      p_legislation_code          => p_legislation_code,
      p_val_start_date            => l_effective_start_date,
      p_val_end_date              => l_effective_end_date,
      p_insert_update_flag        => 'INSERT',
      p_input_value_id            => l_input_value_id,
      p_rowid                     => '',
      p_recurring_flag            => p_recurring_flag,
      p_mandatory_flag            => 'N',
      p_hot_default_flag          => 'N',
      p_standard_link_flag        => 'N',
      p_classification_type       => p_classification_type,
      p_name                      => p_input_value_name,
      p_uom                       => p_uom_code,
      p_min_value                 => '',
      p_max_value                 => '',
      p_default_value             => '',
      p_lookup_type               => '',
      p_formula_id                => '',
      p_generate_db_items_flag    => 'Y',
      p_warning_or_error          => '');
--
   hr_input_values.ins_3p_input_values(
      p_val_start_date            => l_effective_start_date,
      p_val_end_date              => l_effective_end_date,
      p_element_type_id           => p_element_type_id,
      p_primary_classification_id => p_primary_classification_id,
      p_input_value_id            => l_input_value_id,
      p_default_value             => '',
      p_max_value                 => '',
      p_min_value                 => '',
      p_warning_or_error_flag     => '',
      p_input_value_name          => p_input_value_name,
      p_db_items_flag             => 'Y',
      p_costable_type             => '',
      p_hot_default_flag          => 'N',
      p_business_group_id         => p_business_group_id,
      p_legislation_code          => p_legislation_code,
      p_startup_mode               => '');
--
   return l_input_value_id;
--
end create_input_value;
--
--
--
/*
   ****************************************************************************
   NAME        pre_insert_actions

   DESCRIPTION handles all of the pre-insert actions for pay_accrual_plans; at
               the moment all it does is creates the element types and input
               values, but it may need to do more in the future (there's nothing
               wrong with anticipating expansion in functionality)

   NOTES       none
   ****************************************************************************
*/
PROCEDURE pre_insert_actions(p_plan_name                    IN  varchar2,
			     p_bg_name                      IN  varchar2,
			     p_plan_uom                     IN  varchar2,
			     p_business_group_id            IN  number,
			     p_accrual_plan_element_type_id OUT number,
			     p_co_input_value_id            OUT number,
			     p_co_element_type_id           OUT number,
			     p_residual_input_value_id      OUT number,
			     p_residual_element_type_id     OUT number) IS
	   --
	   l_element_type_id           number;
	   l_element_name              varchar2(80);
	   l_element_description       varchar2(240);
	   l_classification_name       varchar2(240);
	   l_post_termination_rule     varchar2(240);
	   l_input_value_id            number;
	   l_input_value_name          varchar2(30);
	   l_uom_code                  varchar2(80);
	   l_primary_classification_id number;
	   l_classification_type       varchar2(2);
	   l_bg_name                   varchar2(80);
	   l_leg_code		       varchar2(150);
	   l_curr_code		       varchar2(150);
	   --
	   -- cursor to get a primary classification (i.e. one where the
	   -- parent_classification_id is null) for the legislation or business
	   -- group. Get the 'Information' classification if there is one,
	   -- failing that get a non-payments one, otherwise just get the
	   -- first one retrieved. Note that both US and GB legislations have
	   -- a startup Information classification. RMF 27-Nov-95.
	   --
	   cursor   class_name is
	   select   classification_name
	   from     pay_element_classifications
	   where    (business_group_id = p_business_group_id
		     or legislation_code = l_leg_code)
	   and      parent_classification_id is null
	   order by decode (classification_name, 'Information', 1, 2),
		    nvl (non_payments_flag, 'X') desc, classification_name;
	   --
	BEGIN
	   hr_utility.set_location
				('pay_accrual_plans_pkg.pre_insert_actions',1);
	   --
	   -- create the accrual plan element type and input value...
	   --
	   -- Added by RMAMGAIN
	   -- p_bg_name is a in params to this proc. but it is null and hence
	   -- element creation is failing because it thinks it has to create a
	   -- startup element.  To avoid network traffic on the forms side we
	   -- can get BG name in this package and avoid changes to other forms
	   -- and package. Also in this proc all references to P_bg_name are
	   -- changed to l_bg_name.
	   --
	   -- Added the legislation code and currency code to the list of
	   -- columns returned by the following select. These are then used
	   -- in setting up the elements with the correct leg code and currency
	   -- code. RMF 27-Nov-95.
	   --
	   select name, legislation_code, currency_code
           into   l_bg_name, l_leg_code, l_curr_code
           from   per_business_groups
           where  business_group_id + 0 = p_business_group_id;
	   --
	   -- If this is a US legislation, use the classification name
	   -- 'PTO Accruals'. Otherwise, pick any classification, preferably a
	   -- non-payments one. RMF 27-Nov-95.
	   --
	   if l_leg_code = 'US' then
	     l_classification_name   := 'PTO Accruals';
	   else
	     open  class_name;
	     fetch class_name into l_classification_name;
	     close class_name;
	   end if;
	   --
	   -- VT #500299 06/05/97
	   --l_post_termination_rule := 'Final Close';
	   begin
	     select hl.meaning
	     into l_post_termination_rule
	     from hr_lookups hl
	     where hl.lookup_type='TERMINATION_RULE'
	       and hl.lookup_code='F';
	     exception
	       when no_data_found then
	         hr_utility.set_message(801,'HR_NO_F_TERM_RULE');
	         hr_utility.raise_error;
	   end;
	   --
	   l_element_name          := p_plan_name;
	   l_element_description   := 'Accrual plan for ' || l_element_name;
	   l_primary_classification_id := 37;
	   l_classification_type       := 'N';
	   --
	   l_element_type_id       := PAY_ACCRUAL_PLANS_PKG.CREATE_ELEMENT(
	      l_element_name,
	      l_element_description,
	      'R',
	      l_bg_name,
	      l_classification_name,
	      l_leg_code,
	      l_curr_code,
	      l_post_termination_rule);
	--
	   p_accrual_plan_element_type_id := l_element_type_id;
	--
	   l_input_value_name := 'Continuous Service Date';
	   l_uom_code         := 'D';
	--
	   l_input_value_id   := PAY_ACCRUAL_PLANS_PKG.CREATE_INPUT_VALUE(
	      l_element_name,
	      l_input_value_name,
	      l_uom_code,
	      l_bg_name,
	      l_element_type_id,
	      l_primary_classification_id,
	      p_business_group_id,
	      'R',
	      l_leg_code,
	      l_classification_type);
	--
	--
	-- now create the carried-over element type and input value...
	--
	--
	-- set up input value names and units of measure
	--
	   if p_plan_uom = 'D' then
	      l_input_value_name := 'Days';
	      l_uom_code         := 'ND';
	   else
	      l_input_value_name := 'Hours';
	      l_uom_code         := 'H_DECIMAL3';
	   end if;
	--
	   l_element_name        := substr('Carried Over ' || p_plan_name, 1, 80);
	   l_element_description :=
	      'Carried over entitlement for accrual plan ' || p_plan_name;
	   --
	   -- If this is a US legislation, use the classification name
	   -- 'Information'. Otherwise, stick with the classification retrieved
	   -- above. RMF 27-Nov-95.
	   --
	   if l_leg_code = 'US' then
	     l_classification_name   := 'Information';
	   end if;
	   --
	   l_primary_classification_id := 40;
	   l_classification_type       := 'Y';
	--
	   l_element_type_id     := PAY_ACCRUAL_PLANS_PKG.CREATE_ELEMENT(
	      l_element_name,
	      l_element_description,
	      'N',
	      l_bg_name,
	      l_classification_name,
	      l_leg_code,
	      l_curr_code,
	      l_post_termination_rule);
	--
	   l_input_value_id      := PAY_ACCRUAL_PLANS_PKG.CREATE_INPUT_VALUE(
	      l_element_name,
	      l_input_value_name,
	      l_uom_code,
	      l_bg_name,
	      l_element_type_id,
	      l_primary_classification_id,
	      p_business_group_id,
	      'N',
	      l_leg_code,
	      l_classification_type);
	--
	   p_co_element_type_id  := l_element_type_id;
	   p_co_input_value_id   := l_input_value_id;
	--
	--
	-- and finally, Esther, the residual element type and input value.
	--
	--
	   l_element_name        := substr('Residual ' || p_plan_name, 1, 80);
	   l_element_description :=
	      'Residual entitlement for accrual plan ' || p_plan_name;
	--
	   l_element_type_id     := PAY_ACCRUAL_PLANS_PKG.CREATE_ELEMENT(
	      l_element_name,
	      l_element_description,
	      'N',
	      l_bg_name,
	      l_classification_name,
	      l_leg_code,
	      l_curr_code,
	      l_post_termination_rule);
	--
	   l_input_value_id      := PAY_ACCRUAL_PLANS_PKG.CREATE_INPUT_VALUE(
	      l_element_name,
	      l_input_value_name,
	      l_uom_code,
	      l_bg_name,
	      l_element_type_id,
	      l_primary_classification_id,
	      p_business_group_id,
	      'N',
	      l_leg_code,
	      l_classification_type);
	--
	   p_residual_element_type_id  := l_element_type_id;
	   p_residual_input_value_id := l_input_value_id;
	--
	--
	END pre_insert_actions;
	--
--
--
/*
   ****************************************************************************
   NAME        post_insert_actions

   DESCRIPTION handles all of the post-insert actions for pay_accrual_plans; at
               the moment all it does is creates the default net calculation
               rules for the plan.

	04-AUG-95	hparicha	279860	Update Pay Value mand_flag
						to 'X' - ie. not enterable
						by user.
   NOTES       none
   ****************************************************************************
*/
PROCEDURE post_insert_actions(p_accrual_plan_id    IN number,
                              p_business_group_id  IN number,
                              p_pto_input_value_id IN number,
                              p_co_input_value_id  IN number) IS
--
  v_accrual_payval_id	NUMBER(9);

BEGIN
--
-- insert the pto input value (always reduces entitlement)
--
   hr_utility.set_location('pay_accrual_plans_pkg.post_insert_actions',1);
   insert into pay_net_calculation_rules(
      net_calculation_rule_id,
      accrual_plan_id,
      business_group_id,
      input_value_id,
      add_or_subtract)
   select
      pay_net_calculation_rules_s.nextval,
      p_accrual_plan_id,
      p_business_group_id,
      p_pto_input_value_id,
      -1
   from dual;
--
-- insert the carried over input value (always increases entitlement)
--
   hr_utility.set_location('pay_accrual_plans_pkg.post_insert_actions',2);
   insert into pay_net_calculation_rules(
      net_calculation_rule_id,
      accrual_plan_id,
      business_group_id,
      input_value_id,
      add_or_subtract)
   select
      pay_net_calculation_rules_s.nextval,
      p_accrual_plan_id,
      p_business_group_id,
      p_co_input_value_id,
      1
   from dual;
--
   hr_utility.set_location('pay_accrual_plans_pkg.post_insert_actions',3);
   --
   -- The update below was originally written as a separate implicit SELECT
   -- and UPDATE. Changed to a single UPDATE, because non-US accrual plans
   -- create all element as non-payment, hence have no PAY INPUT VALUE. The
   -- SELECT was failing with NO_DATA_FOUND. RMF 27-Nov-1995.
   --
   UPDATE	pay_input_values_f
   SET		mandatory_flag = 'X'
   WHERE	input_value_id =
	      ( SELECT 	piv.input_value_id
   		FROM	pay_input_values_f	piv,
			pay_accrual_plans	pap,
			hr_lookups		hrl
   		WHERE	pap.accrual_plan_id = p_accrual_plan_id
   		AND	pap.accrual_plan_element_type_id = piv.element_type_id
   		AND	piv.name = hrl.meaning
   		AND	hrl.lookup_code = 'PAY VALUE'
   		AND	hrl.lookup_type = 'NAME_TRANSLATIONS'
	      );

END post_insert_actions;
--
--
--
/*
   ****************************************************************************
   NAME        update_validation

   DESCRIPTION performs all of the validation required at update time

   NOTES       none
   ****************************************************************************
*/
PROCEDURE update_validation(p_plan_name       IN varchar2,
                            p_old_plan_name   IN varchar2,
                            p_accrual_plan_id IN number) IS
--
BEGIN
--
   if p_plan_name <> p_old_plan_name then
     PAY_ACCRUAL_PLANS_PKG.CHK_PLAN_NAME(p_plan_name,
                                         p_accrual_plan_id);
   end if;
--
END update_validation;
--
--
--
/*
   ****************************************************************************
   NAME        post_update_actions

   DESCRIPTION performs all of the actions required after changing a plan's
               details -

                  changes the net calculation rule if the pto element has
                  changed

   NOTES       none
   ****************************************************************************
*/
PROCEDURE post_update_actions(p_accrual_plan_id        IN number,
                              p_business_group_id      IN number,
                              p_pto_input_value_id     IN number,
                              p_old_pto_input_value_id IN number) IS
--
BEGIN
--
   if p_pto_input_value_id <> p_old_pto_input_value_id then
--
--    delete the old pto input value from the net calculation rules
--
      hr_utility.set_location('pay_accrual_plans_pkg.post_update_actions',1);
      delete from pay_net_calculation_rules
      where  input_value_id = p_old_pto_input_value_id
      and    accrual_plan_id = p_accrual_plan_id;
--
--   create a new net calculation rule for the new pto input value if one
--   does not already exist
--
      hr_utility.set_location('pay_accrual_plans_pkg.post_update_actions',2);
      insert into pay_net_calculation_rules(
         net_calculation_rule_id,
         accrual_plan_id,
         business_group_id,
         input_value_id,
         add_or_subtract)
      select
         pay_net_calculation_rules_s.nextval,
         p_accrual_plan_id,
         p_business_group_id,
         p_pto_input_value_id,
         -1
      from dual
      where not exists(
            select 1
            from   pay_net_calculation_rules
            where  input_value_id = p_pto_input_value_id
            and    accrual_plan_id = p_accrual_plan_id);
   end if;
--
END post_update_actions;
--
--
--
/*
   ****************************************************************************
   NAME        pre_delete_actions

   DESCRIPTION performs all of the actions required before deleting the plan -
                  delete all child accrual bands;
                  delete all child net calculation rules;
                  delete the element type created for the accrual plan;
                  delete the residual element type;
                  delete the carried over element type.

   NOTES       none
   ****************************************************************************
*/
PROCEDURE pre_delete_actions(p_accrual_plan_id              IN number,
                             p_accrual_plan_element_type_id IN number,
                             p_co_element_type_id           IN number,
                             p_residual_element_type_id     IN number,
                             p_session_date                 IN date) IS
--
   l_effective_start_date date;
   l_effective_end_date   date;
--
BEGIN
   l_effective_start_date := hr_general.start_of_time;
   l_effective_end_date   := hr_general.end_of_time;
--
--
-- delete the accrual bands
--
   hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 1);
   delete from pay_accrual_bands
   where  accrual_plan_id = p_accrual_plan_id;
--
-- delete the net calculation rules
--
   hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 2);
   delete from pay_net_calculation_rules
   where  accrual_plan_id = p_accrual_plan_id;
--
-- delete the element types created for the plan
--
-- first the accrual plan element type...
--
   hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 3);
   hr_elements.chk_del_element_type (
      'ZAP',
      p_accrual_plan_element_type_id,
      '',
      p_session_date,
      l_effective_start_date,
      l_effective_end_date);
--
   hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 4);
   hr_elements.del_3p_element_type (
      p_accrual_plan_element_type_id,
      'ZAP',
      p_session_date,
      l_effective_start_date,
      l_effective_end_date,
      '');
--
   hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions',5);
   delete from pay_element_types_f
   where  element_type_id = p_accrual_plan_element_type_id;
--
--
-- ...then the carried over element type...
--
--
   hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 6);
   hr_elements.chk_del_element_type (
      'ZAP',
      p_co_element_type_id,
      '',
      p_session_date,
      l_effective_start_date,
      l_effective_end_date);
--
   hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 7);
   hr_elements.del_3p_element_type (
      p_co_element_type_id,
      'ZAP',
      p_session_date,
      l_effective_start_date,
      l_effective_end_date,
      '');
--
   hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions',8);
   delete from pay_element_types_f
   where  element_type_id = p_co_element_type_id;
--
--
-- ...then the residual element type.
--
--
   hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 9);
   hr_elements.chk_del_element_type (
      'ZAP',
      p_residual_element_type_id,
      '',
      p_session_date,
      l_effective_start_date,
      l_effective_end_date);
--
   hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 10);
   hr_elements.del_3p_element_type (
      p_residual_element_type_id,
      'ZAP',
      p_session_date,
      l_effective_start_date,
      l_effective_end_date,
      '');
--
   hr_utility.set_location('pay_accrual_plans_pkg.pre_delete_actions', 11);
   delete from pay_element_types_f
   where  element_type_id = p_residual_element_type_id;
--
END pre_delete_actions;
--
--
--
END PAY_ACCRUAL_PLANS_PKG;

/
