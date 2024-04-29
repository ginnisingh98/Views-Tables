--------------------------------------------------------
--  DDL for Package Body FF_FORMULAS_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_FORMULAS_F_PKG" as
/* $Header: fffra01t.pkb 120.1 2005/07/29 04:55:46 shisriva noship $ */
--
g_dummy	number(1);	-- Dummy for cursor returns which are not needed
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   payroll_del_validation                                                --
 -- Purpose                                                                 --
 --   Provides referential integrity checks for payroll tables using        --
 --   formula when a formula is deleted.                                    --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -- History                                                                 --
 --   13-Sep-04
 --   Added delete integrity checks for the following tables                --
 --   1. PAY_AU_MODULES                                                     --
 --   2. PAY_SHADOW_ELEMENT_TYPES                                           --
 --   3. PER_CAGR_ENTITLEMENT_ITEMS                                         --
 --   4. PER_CAGR_RETAINED_RIGHTS                                           --
 --   5. PER_CAGR_ENTITLEMENTS                                              --
 --   6. PER_CAGR_ENTITLEMENT_RESULTS                                       --
 --   7. PAY_ACCRUAL_PLANS                                                  --
 --   Included the delete integrity check for proration formula in          --
 --   csr_element_type cursor and added input parameter p_formula_details.  --
 --   Bug No 3703492
 --
--For MLS-----------------------------------------------------------------------
g_dummy_number number (30);
g_business_group_id number(15);   -- For validating translation.
g_legislation_code  varchar2(150);   -- For validating translation.

--------------------------------------------------------------------------------
 -----------------------------------------------------------------------------
--
 procedure payroll_del_validation
 (
  p_formula_id            number,
  p_dt_delete_mode        varchar2,
  p_validation_start_date date,
  p_validation_end_date   date,
  p_formula_details       FormulaRec
 ) Is

--
   v_dummy number;
   l_formula_type_name ff_formula_types.formula_type_name%type;

--
-- Cursor to check for presence of formula in ff_qp_reports table.
--
   cursor csr_qp_report is
     select fqr.formula_id
     from   ff_qp_reports fqr
     where  fqr.formula_id = p_formula_id;
--
-- Cursor to check if the formula is referenced in hr_assignment_sets table.
--
   cursor csr_assignment_set is
     SELECT has.formula_id
     from   hr_assignment_sets has
     where  has.formula_id = p_formula_id;
--
-- Cursor to check if the formula is referenced in pay_user_columns table.
--
   cursor csr_user_column is
     select puc.formula_id
     from   pay_user_columns puc
     where  puc.formula_id = p_formula_id;
--
-- Cursor to check if the formula is referenced in pay_input_vales_f table.
--
   cursor csr_input_value is
     select piv.formula_id
     from   pay_input_values_f piv
     where  piv.formula_id = p_formula_id
       and  piv.effective_start_date <= p_validation_end_date
       and  piv.effective_end_date   >= p_validation_start_date;
--
-- Cursor to check if the formula is referenced in pay_status_processing_rules_f table.
--
   cursor csr_stat_proc_rule is
     select psr.formula_id
     from   pay_status_processing_rules_f psr
     where  psr.formula_id = p_formula_id
       and  psr.effective_start_date <= p_validation_end_date
       and  psr.effective_end_date   >= p_validation_start_date;

--
-- Cursor to check if the formula is referenced in pay_magnetic_records table.
--
   cursor csr_magnetic_record is
     select pmr.formula_id
     from   pay_magnetic_records pmr
     where  pmr.formula_id = p_formula_id;


--
-- Cursor to check if the formula is referenced in pay_accrual_plans table.
--
 cursor csr_accrual_plans is
     select 1
     from   pay_accrual_plans pap
     where  pap.accrual_formula_id = p_formula_id
            or pap.ineligibility_formula_id = p_formula_id
	    or pap.co_formula_id = p_formula_id
	    or pap.payroll_formula_id = p_formula_id;

--
-- Cursor to check if the formula is referenced in pay_element_types_f table.
--
   cursor csr_element_type is
     select 1
     from   pay_element_types_f pet
     where  ( pet.proration_formula_id = p_formula_id
	      or pet.formula_id = p_formula_id
	      or pet.iterative_formula_id = p_formula_id )
       and  pet.effective_start_date <= p_validation_end_date
       and  pet.effective_end_date   >= p_validation_start_date;

--
-- Cursor to check if the formuls is referenced in per_cagr_entitlements table.
--
   cursor csr_per_cagr_entitlements is
     select pce.formula_id
      from  per_cagr_entitlements pce
     where    pce.formula_id  = p_formula_id
      and     pce.start_date <= p_validation_end_date
      and     (pce.end_date is null or pce.end_date >= p_validation_start_date );

--
-- Cursor to check if the formula is referenced in per_cagr_entitlement_items table.
--
   cursor csr_per_cagr_entitle_items is
     select pcei.beneficial_formula_id
      from  per_cagr_entitlement_items pcei
     where    pcei.beneficial_formula_id = p_formula_id;

--
-- Cursor to check if the formula is referenced in per_cagr_entitlement_results.
--
   cursor csr_per_cagr_entitle_results is
     select pcer.formula_id
      from  per_cagr_entitlement_results pcer
     where  pcer.formula_id = p_formula_id
     and    pcer.start_date <= p_validation_end_date
     and    (pcer.end_date is null or pcer.end_date >= p_validation_start_date );

--
-- Cursor to check if the formula is referenced in per_cagr_retained_rights table.
--
   cursor csr_cagr_retained_rights is
     select pcrr.formula_id
      from  per_cagr_retained_rights pcrr
     where  pcrr.formula_id = p_formula_id
      and   pcrr.start_date <= p_validation_end_date
      and   (pcrr.end_date is null or pcrr.end_date >= p_validation_start_date );


--
-- Cursor to check if the formula is referenced in pay_au_modules table.
--
   cursor csr_au_modules is
	select 1
	from   pay_au_modules pam
	where  pam.formula_name = p_formula_details.formula_name
	  and  (
		(pam.legislation_code is null and pam.business_group_id is null)

		or (pam.business_group_id is null and pam.legislation_code=p_formula_details.legislation_code)

		or (pam.legislation_code is null and pam.business_group_id=p_formula_details.business_group_id)
		);
--
-- Cursor to check if the formula is referenced in pay_shadow_element_types table.
--

  cursor csr_element_template is
		select 1
		from   pay_shadow_element_types pset
		where (pset.skip_formula = p_formula_details.formula_name or pset.iterative_formula_name=
			p_formula_details.formula_name )
		   and exists(
				select null
				from   pay_element_templates pet
				where  pet.template_id = pset.template_id
				and (
				       ( pet.legislation_code is null and pet.business_group_id is null)

				       or (pet.legislation_code is null
	                                     and  (
					           pet.business_group_id = p_formula_details.business_group_id
	          			           or p_formula_details.legislation_code =
						 	(
							 select legislation_code
							 from  per_business_groups
							 where business_group_id = pet.business_group_id
							 )
					            )
				               )
			        	or (pet.business_group_id is null
					    and pet.legislation_code = p_formula_details.legislation_code)
				    )
			     );
--
-- Cursor to get the formula type name.
--
   cursor csr_formula_type_name is
     select upper(formula_type_name)
      from  ff_formula_types
      where formula_type_id = p_formula_details.formula_type_id;
   --



 begin

   --
   -- Get formula type name.
   --
      open  csr_formula_type_name;
      fetch csr_formula_type_name into l_formula_type_name;
      close csr_formula_type_name;

   --
   -- Validate Non-Dt Tables.
   --


   if p_dt_delete_mode = 'ZAP' then

   open csr_element_template;
   fetch csr_element_template into v_dummy;
   if csr_element_template%found then
      close csr_element_template;
      hr_utility.set_message(801, 'PAY_34031_FORMULA_DEL_TMPL');
      hr_utility.raise_error;
   else
      close csr_element_template;
   end if;

  --

   open csr_au_modules;
   fetch csr_au_modules into v_dummy;
   if csr_au_modules%found then
      close csr_au_modules;
      hr_utility.set_message(801, 'PAY_34032_FORMULA_DEL_AU_MOD');
      hr_utility.raise_error;
   else
      close csr_au_modules;
   end if;

  --

     open csr_accrual_plans;
     fetch csr_accrual_plans into v_dummy;
     if csr_accrual_plans%found then
       close csr_accrual_plans;
       hr_utility.set_message(801, 'PAY_34033_FORMULA_DEL_ACCRUAL');
       hr_utility.raise_error;
     else
       close csr_accrual_plans;
     end if;

     --
     open csr_per_cagr_entitle_items;
     fetch csr_per_cagr_entitle_items into v_dummy;
     if csr_per_cagr_entitle_items%found then
       close csr_per_cagr_entitle_items;
       hr_utility.set_message(801, 'PAY_34034_FORMULA_DEL_CAGR');
       hr_utility.raise_error;
     else
       close csr_per_cagr_entitle_items;
     end if;

     --
     open csr_qp_report;
     fetch csr_qp_report into v_dummy;
     if csr_qp_report%found then
       close csr_qp_report;
       hr_utility.set_message(801, 'HR_6871_FORMULA_DEL_QP_I');
       hr_utility.raise_error;
     else
       close csr_qp_report;
     end if;
     --
     open csr_assignment_set;
     fetch csr_assignment_set into v_dummy;
     if csr_assignment_set%found then
       close csr_assignment_set;
       hr_utility.set_message(801, 'HR_6872_FORMULA_DEL_ASS_SET');
       hr_utility.raise_error;
     else
       close csr_assignment_set;
     end if;
     --
     open csr_user_column;
     fetch csr_user_column into v_dummy;
     if csr_user_column%found then
       close csr_user_column;
       hr_utility.set_message(801, 'HR_6879_FORMULA_DEL_USER_COL');
       hr_utility.raise_error;
     else
       close csr_user_column;
     end if;
     --
     open csr_magnetic_record;
     fetch csr_magnetic_record into v_dummy;
     if csr_magnetic_record%found then
       close csr_magnetic_record;
       hr_utility.set_message(801, 'HR_7341_FORMULA_DEL_MAG_REC');
       hr_utility.raise_error;
     else
       close csr_magnetic_record;
     end if;
     --
   end if;

   --
   --   Validate all DT tables that use formula NB.
   --   Only need to check when shortening or completely removing the formula.
   --

   if p_dt_delete_mode in ('ZAP','DELETE') then
     --
     open csr_cagr_retained_rights;
     fetch csr_cagr_retained_rights into v_dummy;
     if csr_cagr_retained_rights%found then
       close csr_cagr_retained_rights;
       hr_utility.set_message(801, 'PAY_34034_FORMULA_DEL_CAGR');
       hr_utility.raise_error;
     else
       close csr_cagr_retained_rights;
     end if;

     --
     open csr_per_cagr_entitle_results;
     fetch csr_per_cagr_entitle_results into v_dummy;
     if csr_per_cagr_entitle_results%found then
       close csr_per_cagr_entitle_results;
       hr_utility.set_message(801, 'PAY_34034_FORMULA_DEL_CAGR');
       hr_utility.raise_error;
     else
       close csr_per_cagr_entitle_results;
     end if;

     --
     open csr_per_cagr_entitlements;
     fetch csr_per_cagr_entitlements into v_dummy;
     if csr_per_cagr_entitlements%found then
       close csr_per_cagr_entitlements;
       hr_utility.set_message(801, 'PAY_34034_FORMULA_DEL_CAGR');
       hr_utility.raise_error;
     else
       close csr_per_cagr_entitlements;
     end if;
     --
     open csr_input_value;
     fetch csr_input_value into v_dummy;
     if csr_input_value%found then
       close csr_input_value;
       hr_utility.set_message(801, 'HR_6873_FORMULA_DEL_INP_VAL');
       hr_utility.raise_error;
     else
       close csr_input_value;
     end if;
     --
     open csr_stat_proc_rule;
     fetch csr_stat_proc_rule into v_dummy;
     if csr_stat_proc_rule%found then
       close csr_stat_proc_rule;
       hr_utility.set_message(801, 'HR_6878_FORMULA_DEL_PRO_RULE');
       hr_utility.raise_error;
     else
       close csr_stat_proc_rule;
     end if;
     --
     open csr_element_type;
     fetch csr_element_type into v_dummy;
     if csr_element_type%found then
        close csr_element_type;
     --
     -- Raise appropirate error message depending on the type of formula.
     --
        if l_formula_type_name = 'PAYROLL RUN PRORATION' then

        hr_utility.set_message(801, 'PAY_33160_FORMULA_DEL_ELE_PRO');
        hr_utility.raise_error;

        elsif l_formula_type_name = 'NET TO GROSS' then

        hr_utility.set_message(801, 'PAY_34035_FORMULA_DEL_ELE_NTG');
        hr_utility.raise_error;

        else
        hr_utility.set_message(801, 'HR_6955_PAY_FORMULA_DEL_ELE');
        hr_utility.raise_error;

        end if;
     else
       close csr_element_type;
     end if;
     --

   end if;
   --
 end payroll_del_validation;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   payroll_dnc_validation                                                --
 -- Purpose                                                                 --
 --   Provides check for conflicting records when selecting delete next     --
 --   change of future change operations.                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -- History                                                                 --
 --   13-Sep-04.							    --
 --   Added input parameter p_formula_details.                              --
 -----------------------------------------------------------------------------
--
procedure payroll_dnc_validation
  (p_formula_id            number
  ,p_dt_delete_mode        varchar2
  ,p_validation_start_date date
  ,p_validation_end_date   date
  ,p_formula_details       FormulaRec
  ) is
--

--
  cursor csr_future_clash(p_formula_name       varchar2
                         ,p_formula_type_id    number
                         ,p_business_group_id  number
                         ,p_legislation_code   varchar2
                         ,p_val_start_date     date
                         ,p_startup_mode       varchar2) is
    select 'X'
    from   ff_formulas_f ff
    where  ff.formula_name = p_formula_name
    and    ff.formula_type_id = p_formula_type_id
    and    ff.effective_start_date > p_val_start_date
    and    ((p_startup_mode = 'MASTER')
    or     (p_startup_mode = 'SEED'
    and    ((ff.legislation_code = p_legislation_code)
    or     (ff.legislation_code is null
    and    ff.business_group_id is null)))
    or     (p_startup_mode = 'NON-SEED'
    and    ((ff.business_group_id +0 = p_business_group_id)
    or     (ff.legislation_code is null
    and    ff.business_group_id is null)
    or     (ff.business_group_Id is null
    and    ff.legislation_code = p_legislation_code))));
--
  l_startup_mode       varchar2(10);
  l_dummy              varchar2(1);
--
begin

--
  l_startup_mode := ffstup.get_mode(p_formula_details.business_group_id, p_formula_details.legislation_code);
--
  open csr_future_clash(p_formula_details.formula_name,
			p_formula_details.formula_type_id,
			p_formula_details.business_group_id,
                        p_formula_details.legislation_code,
			p_formula_details.effective_start_date,
			l_startup_mode);
  fetch csr_future_clash into l_dummy;
  if csr_future_clash%found then
  --
    close csr_future_clash;
    fnd_message.set_name('PAY','HR_72033_CANNOT_DNC_RECORD');
    fnd_message.raise_error;
  --
  else
  --
    close csr_future_clash;
  --
  end if;
--
end payroll_dnc_validation;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a formula via the --
 --   Write Formula form.                                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   A check is made to ensure the formula name is unique.                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                      X_Formula_Id                   IN OUT NOCOPY NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Formula_Type_Id                     NUMBER,
                      X_Formula_Name                 IN OUT NOCOPY VARCHAR2,
                      X_Description                         VARCHAR2,
                      X_Formula_Text                        VARCHAR2,
                      X_Sticky_Flag                         VARCHAR2,
                      X_Last_Update_Date             IN OUT NOCOPY DATE) IS
--
   CURSOR C IS SELECT rowid row_id, last_update_date FROM ff_formulas_f
               WHERE  formula_id = X_Formula_Id;
--
   CURSOR C2 IS SELECT ff_formulas_s.nextval FROM sys.dual;
--
   ReturnInfo C%RowType;
   L_Effective_End_Date  Date;
--
 BEGIN
--
   L_Effective_End_Date := X_Effective_End_Date;
   -- Make sure formula name is unique and valid ie. no spaces etc ....
   ffdict.validate_formula
     (X_Formula_Name,
      X_Formula_Type_Id,
      X_Business_Group_Id,
      X_Legislation_Code,
      X_Effective_Start_Date,
      L_Effective_End_Date);
--
   if (X_Formula_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Formula_Id;
     CLOSE C2;
   end if;
--
   INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (X_Formula_Id,
      X_Effective_Start_Date,
      L_Effective_End_Date,
      X_Business_Group_Id,
      X_Legislation_Code,
      X_Formula_Type_Id,
      X_Formula_Name,
      X_Description,
      X_Formula_Text,
      X_Sticky_Flag);
--
--  insert into MLS table (TL)
--
--For MLS-----------------------------------------------------------------------
g_dml_status := TRUE;
ff_fft_ins.ins_tl(userenv('LANG'),X_FORMULA_ID,
                 X_FORMULA_NAME,X_DESCRIPTION);
g_dml_status := FALSE;
--------------------------------------------------------------------------------

--
   OPEN C;
   FETCH C INTO ReturnInfo;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'ff_formulas_f_pkg.insert_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
   X_Rowid            := ReturnInfo.row_id;
   X_Last_Update_Date := ReturnInfo.last_update_date;
--
Exception
  When Others then
  g_dml_status := FALSE;
  raise;
 END Insert_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row (OVERLOADED)                                                 --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a formula by applying a lock on a formula in the Write Formula     --
 --   form.                                                                 --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   This version checks each column to see if the formula has changed.    --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Formula_Id                            NUMBER,
                    X_Effective_Start_Date                  DATE,
                    X_Effective_End_Date                    DATE,
                    X_Business_Group_Id                     NUMBER,
                    X_Legislation_Code                      VARCHAR2,
                    X_Formula_Type_Id                       NUMBER,
                    X_Formula_Name                          VARCHAR2,
                    X_Description                           VARCHAR2,
                    X_Formula_Text                          VARCHAR2,
                    X_Sticky_Flag                           VARCHAR2,
		    X_Base_Formula_Name              VARCHAR2 default NULL,
		    X_Base_Description                    VARCHAR2 default NULL) IS
--
   CURSOR C IS SELECT * FROM ff_formulas_f
               WHERE  rowid = X_Rowid FOR UPDATE NOWAIT;
--
   Recinfo C%ROWTYPE;
--
 BEGIN
--
   OPEN C;
   FETCH C INTO Recinfo;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'ff_formulas_f_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
   -- Remove trailing spaces.
   Recinfo.legislation_code := rtrim(Recinfo.legislation_code);
   Recinfo.formula_name := rtrim(Recinfo.formula_name);
   Recinfo.description := rtrim(Recinfo.description);
   Recinfo.formula_text := rtrim(Recinfo.formula_text);
   Recinfo.sticky_flag := rtrim(Recinfo.sticky_flag);
--
   if (    (   (Recinfo.formula_id = X_Formula_Id)
            OR (    (Recinfo.formula_id IS NULL)
                AND (X_Formula_Id IS NULL)))
       AND (   (Recinfo.effective_start_date = X_Effective_Start_Date)
            OR (    (Recinfo.effective_start_date IS NULL)
                AND (X_Effective_Start_Date IS NULL)))
       AND (   (Recinfo.effective_end_date = X_Effective_End_Date)
            OR (    (Recinfo.effective_end_date IS NULL)
                AND (X_Effective_End_Date IS NULL)))
       AND (   (Recinfo.business_group_id = X_Business_Group_Id)
            OR (    (Recinfo.business_group_id IS NULL)
                AND (X_Business_Group_Id IS NULL)))
       AND (   (Recinfo.legislation_code = X_Legislation_Code)
            OR (    (Recinfo.legislation_code IS NULL)
                AND (X_Legislation_Code IS NULL)))
       AND (   (Recinfo.formula_type_id = X_Formula_Type_Id)
            OR (    (Recinfo.formula_type_id IS NULL)
                AND (X_Formula_Type_Id IS NULL)))
       AND (   (Recinfo.formula_name = X_Base_Formula_Name)
            OR (    (Recinfo.formula_name IS NULL)
                AND (X_Base_Formula_Name IS NULL)))
       AND (   (Recinfo.description = X_Base_Description)
            OR (    (Recinfo.description IS NULL)
                AND (X_Base_Description IS NULL)))
       AND (   (Recinfo.formula_text = X_Formula_Text)
            OR (    (Recinfo.formula_text IS NULL)
                AND (X_Formula_Text IS NULL)))
       AND (   (Recinfo.sticky_flag = X_Sticky_Flag)
            OR (    (Recinfo.sticky_flag IS NULL)
                AND (X_Sticky_Flag IS NULL)))
           ) then
     return;
   else
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.RAISE_EXCEPTION;
   end if;
--
 END Lock_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row (OVERLOADED)                                                 --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a formula by applying a lock on a formula in the Write Formula     --
 --   form.                                                                 --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   This version tests the last_update_date to see if the formula has     --
 --   changed.                                                              --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(x_rowid                                 VARCHAR2,
                    x_last_update_date                      DATE) IS
--
   CURSOR C IS SELECT last_update_date FROM ff_formulas_f
               WHERE  rowid = x_rowid FOR UPDATE NOWAIT;
--
   v_current_update_date date;
--
 BEGIN
--
   OPEN C;
   FETCH C INTO v_current_update_date;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'ff_formulas_f_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
   -- Compare the last_update_date from the client against that held on the
   -- DB. If they are different then the row has been chnaged since it was
   -- queried. The use of nvl is to cope when either of the dates is null which
   -- would immediately fail the comparison.
   if nvl(x_last_update_date,to_date('01/01/0001','DD/MM/YYYY')) <>
      nvl(v_current_update_date,to_date('01/01/0001','DD/MM/YYYY')) then
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.RAISE_EXCEPTION;
   end if;
--
 END Lock_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a formula via the --
 --   Write Formula form.                                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Formula_Id                          NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Formula_Type_Id                     NUMBER,
		      X_Formula_Name                        VARCHAR2,
                      X_Description                         VARCHAR2,
                      X_Formula_Text                        VARCHAR2,
                      X_Sticky_Flag                         VARCHAR2,
                      X_Last_Update_Date             IN OUT NOCOPY DATE,
		      X_Base_Formula_Name              VARCHAR2 default hr_api.g_varchar2,
		      X_Base_Description                    VARCHAR2 default hr_api.g_varchar2) IS
--
   CURSOR C IS SELECT last_update_date FROM ff_formulas_f
               WHERE  rowid = x_rowid;
--
   v_current_update_date date;
--
l_formula_name varchar2(80);
l_description varchar2(240);
--
 BEGIN
--
--
--Fixed for bug 4348013--
/* Checking if the Base values of formula_name and description are of type hr_api.g_varchar2 i.e.
the procedure is not being called from the form but from outside then copy the translated
values into them.*/

l_formula_name := X_Base_Formula_Name;
l_description := X_Base_Description;

if(l_formula_name = hr_api.g_varchar2) then
l_formula_name := X_Formula_Name;
end if;
if( l_description = hr_api.g_varchar2 ) then
l_description := X_Description;
end if;
----
   UPDATE ff_formulas_f
   SET    formula_id           =    X_Formula_Id,
          effective_start_date =    X_Effective_Start_Date,
          effective_end_date   =    X_Effective_End_Date,
          business_group_id    =    X_Business_Group_Id,
          legislation_code     =    X_Legislation_Code,
          formula_type_id      =    X_Formula_Type_Id,
          formula_name         =    l_formula_name,
          description          =   l_description,
          formula_text         =    X_Formula_Text,
          sticky_flag          =    X_Sticky_Flag
   WHERE  rowid = X_rowid;
--
--For MLS-----------------------------------------------------------------------
g_dml_status := TRUE;
ff_fft_upd.upd_tl(userenv('LANG'),X_FORMULA_ID,
                 X_FORMULA_NAME,X_DESCRIPTION);
g_dml_status := FALSE;
--------------------------------------------------------------------------------

---
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'ff_formulas_f_pkg.update_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
   OPEN C;
   FETCH C INTO v_current_update_date;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'ff_formulas_f_pkg.update_row');
     hr_utility.set_message_token('STEP','2');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
   X_Last_Update_Date := v_current_update_date;
--
Exception
  When Others then
  g_dml_status := FALSE;
  raise;
 END Update_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a formula via the --
 --   Write Formula form.                                                   --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   Referential integrity checks are done against any payroll tables that --
 --   make use of formula.						    --
 -- History								    --
 --   13-Sep-04.
 --   Added X_Effective_Date input parameter to check for delete integrity  --
 --   violation against Oracle Advanced Benefits tables by calling          --
 --   chk_formula_exists_in_ben function.
 --   Derived formula details here rather than in payroll_dnc_validation    --
 --   and passed the details to payroll_del_validation,                     --
 --   payroll_dnc_validation and chk_formula_exists_in_ben.Bug 3703492      --
 --   16-Sep-04                                                             --
 --   Changed the order of arguments.                                       --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid                 VARCHAR2,
                      X_Formula_Id            NUMBER,
                      X_Dt_Delete_Mode        VARCHAR2,
                      X_Validation_Start_Date DATE,
                      X_Validation_End_Date   DATE,
		      X_Effective_Date        DATE) IS

  l_oab_installed       boolean;
  l_prod_status		varchar2(1);
  l_industry		varchar2(1);
  l_oracle_schema	varchar2(30);
  l_formula_in_oab      boolean;
  formula_details       FormulaRec;
  l_start_of_time       date;
--
-- Cursor to get details of the formula to be deleted.
--
   cursor csr_current_record is
    select ff.formula_name
    ,      ff.formula_type_id
    ,      ff.business_group_id
    ,      nvl(bg.legislation_code,ff.legislation_code)
    ,      ff.effective_start_date
    ,      ff.effective_end_date
    from   ff_formulas_f         ff
    ,      per_business_groups   bg
    where  ff.formula_id = X_formula_id
    and    ff.business_group_id = bg.business_group_id (+)
    and    (
	     (X_Dt_Delete_Mode in ('DELETE_NEXT_CHANGE','FUTURE_CHANGE')
	      and ff.effective_end_date+1 = X_validation_start_date)

	      or ( X_Dt_Delete_Mode = 'DELETE' and X_Effective_Date+1 = X_validation_start_date)

	      or ( X_Dt_Delete_Mode = 'ZAP' and l_start_of_time = X_validation_start_date)
	    );

--
 BEGIN

  l_start_of_time := to_date('01/01/0001','dd/mm/yyyy');
--
-- Fetch the details of the formula to be deleted.
--
  open csr_current_record;
  fetch csr_current_record into formula_details;

  if csr_current_record%notfound then
   --
    close csr_current_record;
    fnd_message.set_name('PER','HR_51022_HR_INV_PRIMARY_KEY');
    fnd_message.raise_error;
  --
  else
  --
    close csr_current_record;
  --
  end if;

  --
  -- Make sure that no payroll or per tables using the formula are affected by a
  -- delete of formula.
  --
  payroll_del_validation
    (X_Formula_Id
    ,X_Dt_Delete_Mode
    ,X_Validation_Start_Date
    ,X_Validation_End_Date
    ,Formula_Details);

--
  --
  -- Make sure no clashes exist if end date of formula is being extended.
  --
  if X_Dt_Delete_Mode NOT IN ('ZAP','DELETE') then
  --
      payroll_dnc_validation
      (X_Formula_Id
      ,X_Dt_Delete_Mode
      ,X_Validation_Start_Date
      ,X_Validation_End_Date
      ,Formula_Details);
  --
  end if;

  --
--
-- Check if Oracle Advanced Benefits is installed.
--
    l_oab_installed := fnd_installation.get_app_info ( 'BEN',
  				  		        l_prod_status,
  				  		        l_industry,
				  		        l_oracle_schema );
--
-- If OAB is installed, check if delete integrity is being violated.
--

  if ( l_prod_status = 'I' ) then

     l_formula_in_oab:=ben_fastformula_check.chk_formula_exists_in_ben
		      (
		      p_formula_id        => X_formula_id,
		      p_formula_type_id   => Formula_Details.formula_type_id,
		      p_effective_date    => X_Effective_Date,
		      p_business_group_id => Formula_Details.business_group_id,
		      p_legislation_cd    => Formula_Details.legislation_code
		      );

     if l_formula_in_oab = true then
         hr_utility.set_message(801, 'PAY_34036_FORMULA_DEL_OAB');
         hr_utility.raise_error;
     end if;


   end if;
--
--For MLS-----------------------------------------------------------------------
if X_Dt_Delete_Mode IN ('ZAP') then
begin
g_dml_status := TRUE;
ff_fft_del.del_tl(X_FORMULA_ID);
g_dml_status := FALSE;
Exception
  When Others then
  g_dml_status := FALSE;
  raise;
end;
end if;
--------------------------------------------------------------------------------

   DELETE FROM ff_formulas_f
   WHERE  rowid = X_Rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'ff_formulas_f_pkg.delete_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
 END Delete_Row;
--
---For MLS----------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from FF_FORMULAS_F_TL T
  where not exists
    (select NULL
    from FF_FORMULAS_F B
    where B.FORMULA_ID = T.FORMULA_ID
    );
  update FF_FORMULAS_F_TL T set (
      FORMULA_NAME,
      DESCRIPTION
    ) = (select
      B.FORMULA_NAME,
      B.DESCRIPTION
    from FF_FORMULAS_F_TL B
    where B.FORMULA_ID = T.FORMULA_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.FORMULA_ID,
      T.LANGUAGE
  ) in (select
      SUBT.FORMULA_ID,
      SUBT.LANGUAGE
    from FF_FORMULAS_F_TL SUBB, FF_FORMULAS_F_TL SUBT
    where SUBB.FORMULA_ID = SUBT.FORMULA_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.FORMULA_NAME <> SUBT.FORMULA_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FF_FORMULAS_F_TL (
    FORMULA_ID,
    FORMULA_NAME,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.FORMULA_ID,
    B.FORMULA_NAME,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FF_FORMULAS_F_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FF_FORMULAS_F_TL T
    where T.FORMULA_ID = B.FORMULA_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
-----
procedure TRANSLATE_ROW (
   X_B_FORMULA_NAME in VARCHAR2,
   X_B_LEGISLATION_CODE in VARCHAR2,
   X_FORMULA_NAME in VARCHAR2,
   X_DESCRIPTION in VARCHAR2,
   X_OWNER in VARCHAR2
) is
begin
  UPDATE ff_formulas_f_tl
    SET FORMULA_NAME = nvl(X_FORMULA_NAME,FORMULA_NAME),
        DESCRIPTION = nvl(X_DESCRIPTION,DESCRIPTION),
        last_update_date = SYSDATE,
        last_updated_by = decode(x_owner,'SEED',1,0),
        last_update_login = 0,
        source_lang = userenv('LANG')
  WHERE userenv('LANG') IN (language,source_lang)
    AND FORMULA_ID in
        (select FORMULA_ID
           from FF_FORMULAS_F
          where nvl(FORMULA_NAME,'~null~')=nvl(X_B_FORMULA_NAME,'~null~')
            and nvl(LEGISLATION_CODE,'~null~') = nvl(X_B_LEGISLATION_CODE,'~null~')
            and BUSINESS_GROUP_ID is NULL);
  if (sql%notfound) then
  null;
  end if;
end TRANSLATE_ROW;
--
---
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
                                  p_legislation_code  IN VARCHAR2) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code  := p_legislation_code;
END set_translation_globals;
--
---
procedure validate_translation(formula_id	NUMBER,
			       language		VARCHAR2,
			       formula_name	VARCHAR2,
			       description	VARCHAR2,
			       p_business_group_id IN NUMBER DEFAULT NULL,
			       p_legislation_code IN VARCHAR2 DEFAULT NULL) IS
/*

This procedure fails if a formula translation is already present in
the table for a given language.  Otherwise, no action is performed.  It is
used to ensure uniqueness of translated formula names.

*/

--
-- This cursor implements the validation we require,
-- and expects that the various package globals are set before
-- the call to this procedure is made.  This is done from the
-- user-named trigger 'TRANSLATIONS' in the form
--
cursor c_translation(p_language IN VARCHAR2,
                     p_formula_name IN VARCHAR2,
                     p_formula_id IN NUMBER,
                     p_bus_grp_id IN NUMBER,
		     p_leg_code IN varchar2)  IS
       SELECT  1
	 FROM  ff_formulas_f_tl fft,
	       ff_formulas_f    fff
	 WHERE upper(fft.formula_name)=upper(p_formula_name)
	 AND   fft.formula_id = fff.formula_id
	 AND   fft.language = p_language
	 AND   (fff.formula_id <> p_formula_id OR p_formula_id IS NULL)
	 AND   (nvl(fff.business_group_id,-1) = nvl(p_bus_grp_id,-1) OR p_bus_grp_id IS NULL)
	 AND   (nvl(fff.LEGISLATION_CODE,'~null~') = nvl(p_leg_code,'~null~') OR p_leg_code IS NULL);

       l_package_name VARCHAR2(80);
       l_business_group_id NUMBER;
       l_legislation_code VARCHAR2(150);

BEGIN
   l_package_name  := 'FF_FORMULAS_F_PKG.VALIDATE_TRANSLATION';
   l_business_group_id := p_business_group_id;
   l_legislation_code  := p_legislation_code;
   hr_utility.set_location (l_package_name,10);
   OPEN c_translation(language, formula_name,formula_id,
		     l_business_group_id,l_legislation_code);
      	hr_utility.set_location (l_package_name,50);
       FETCH c_translation INTO g_dummy;

       IF c_translation%NOTFOUND THEN
      	hr_utility.set_location (l_package_name,60);
	  CLOSE c_translation;
       ELSE
      	hr_utility.set_location (l_package_name,70);
	  CLOSE c_translation;
	  fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
	  fnd_message.raise_error;
       END IF;
      	hr_utility.set_location ('Leaving:'||l_package_name,80);
END validate_translation;
--
function return_dml_status
return boolean
IS
begin
return g_dml_status;
end return_dml_status;
---
END FF_FORMULAS_F_PKG;

/
