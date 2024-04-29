--------------------------------------------------------
--  DDL for Package Body PAY_DEFINED_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DEFINED_BALANCES_PKG" as
/* $Header: pydfb01t.pkb 120.1 2006/03/10 02:30:52 alogue noship $ */
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   chk_defined_balance                                                   --
 -- Purpose                                                                 --
 --   Make sure that the defined balance is unique.                         --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 procedure chk_defined_balance
 (
  p_row_id               varchar2,
  p_business_group_id    number,
  p_legislation_code     varchar2,
  p_balance_type_id      number,
  p_balance_dimension_id number
 ) is
--
   cursor csr_unique_defined_balance is
     select dfb.defined_balance_id
     from   pay_defined_balances dfb
     where  dfb.balance_type_id = p_balance_type_id
       and  dfb.balance_dimension_id = p_balance_dimension_id
       and  nvl(dfb.business_group_id,nvl(p_business_group_id,0)) =
              nvl(p_business_group_id,0)
       and  nvl(dfb.legislation_code,nvl(p_legislation_code,' ')) =
              nvl(p_legislation_code,' ')
       and  (p_row_id is null or
	    (p_row_id is not null and chartorowid(p_row_id) <> dfb.rowid));
--
   v_defined_balance_id number;
--
 begin
--
   open csr_unique_defined_balance;
   fetch csr_unique_defined_balance into v_defined_balance_id;
   if csr_unique_defined_balance%found then
     close csr_unique_defined_balance;
     hr_utility.set_message(801, 'HR_6117_BAL_UNI_DIMENSION');
     hr_utility.raise_error;
   else
     close csr_unique_defined_balance;
   end if;
--
 end chk_defined_balance;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   chk_delete_defined_balance                                            --
 -- Purpose                                                                 --
 --   Check to see if it valid to remove a defined balance.                 --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 procedure chk_delete_defined_balance
 (
  p_defined_balance_id number
 ) is
--
   cursor csr_org_pay_meth is
     select opm.org_payment_method_id
     from   pay_org_payment_methods_f opm
     where  opm.defined_balance_id = p_defined_balance_id;
--
   cursor csr_backpay_set is
     select br.backpay_set_id
     from   pay_backpay_rules br
     where  br.defined_balance_id = p_defined_balance_id;
--
   cursor get_pbas(p_def_bal number) is
   select balance_attribute_id
   from   pay_balance_attributes
   where  defined_balance_id = p_def_bal;
--
   v_org_pay_meth_id number;
   v_backpay_set_id  number;
--
 begin
--
   -- See if defined balance is being used by an organization payment method.
   open csr_org_pay_meth;
   fetch csr_org_pay_meth into v_org_pay_meth_id;
   if csr_org_pay_meth%found then
     close csr_org_pay_meth;
     hr_utility.set_message(801, 'HR_6958_PAY_ORG_PAY_MTHD_EXIST');
     hr_utility.raise_error;
   else
     close csr_org_pay_meth;
   end if;
--
   -- See if defined balance is being used by a backpay set.
   open csr_backpay_set;
   fetch csr_backpay_set into v_backpay_set_id;
   if csr_backpay_set%found then
     close csr_backpay_set;
     hr_utility.set_message(801, 'HR_7046_BACK_PAY_EXIST');
     hr_utility.raise_error;
   else
     close csr_backpay_set;
   end if;
--
   for each_pba in get_pbas(p_defined_balance_id) loop
      pay_balance_attribute_api.delete_balance_attribute
         (p_balance_attribute_id => each_pba.balance_attribute_id);
   end loop;
 end chk_delete_defined_balance;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   delete_defined_balance                                                --
 -- Purpose                                                                 --
 --   Remove children of defined balance NB. a trigger on defined balance   --
 --   will remove some children ie. DB Item.                                --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 procedure delete_defined_balance
 (
  p_defined_balance_id number
 ) is
--
 begin
--
   delete /*+ INDEX(alb PAY_ASSIGNMENT_LATEST_BALA_FK2)*/
   from pay_assignment_latest_balances alb
   where  alb.defined_balance_id = p_defined_balance_id;
--
   delete /*+ INDEX(plb PAY_PERSON_LATEST_BALANCES_FK1)*/
   from pay_person_latest_balances plb
   where  plb.defined_balance_id = p_defined_balance_id;
--
 end delete_defined_balance;
--
-----------------------------------------------------------------------------
-- function set_save_run_bals_flag
-- Description - sets the value of save_run_balance on pay_defined_balances,
-- the value is determined by the values of save_run_balance_enabled on
-- pay_balance_categories_f and pay_balance_dimensions.
-----------------------------------------------------------------------------
function set_save_run_bals_flag(p_balance_category_id  number
                               ,p_effective_date       date
                               ,p_balance_dimension_id number)
return varchar2
is
--
cursor get_cat_flag(p_cat_id   number
                   ,p_eff_date date)
is
select pbc.save_run_balance_enabled
from   pay_balance_categories_f pbc
where  pbc.balance_category_id = (p_cat_id)
and    p_eff_date between pbc.effective_start_date
                      and pbc.effective_end_date;
--
cursor get_dim_flag(p_dim_id number)
is
select dim.save_run_balance_enabled
from   pay_balance_dimensions dim
where  dim.balance_dimension_id = p_dim_id
and    dim.dimension_type = 'R';
--
l_cat_flag pay_balance_categories_f.save_run_balance_enabled%type;
l_dim_flag pay_balance_dimensions.save_run_balance_enabled%type;
l_save_run_bal_flag pay_defined_balances.save_run_balance%type;
--
BEGIN
open  get_cat_flag(p_balance_category_id, p_effective_date);
fetch get_cat_flag into l_cat_flag;
if    get_cat_flag%notfound then
  close get_cat_flag;
else
  close get_cat_flag;
end if;
--
open  get_dim_flag(p_balance_dimension_id);
fetch get_dim_flag into l_dim_flag;
if    get_dim_flag%notfound then
  close get_dim_flag;
else
  close get_dim_flag;
end if;
--
if l_cat_flag = 'Y' and l_dim_flag = 'Y' then
--
  l_save_run_bal_flag := 'Y';
elsif
  l_cat_flag = 'N' and l_dim_flag = 'N' then
  --
  l_save_run_bal_flag := 'N';
else
  l_save_run_bal_flag := '';
end if;
return l_save_run_bal_flag;
END set_save_run_bals_flag;
-----------------------------------------------------------------------------
-- insert_default_attrib_wrapper
-- wrapper procedure insert_default_attributes used when not called directly
-- from forms.
-----------------------------------------------------------------------------
procedure insert_default_attrib_wrapper(p_balance_dimension_id number
                                       ,p_balance_category_id  number
                                       ,p_def_bal_bg_id        number
                                       ,p_def_bal_leg_code     varchar2
                                       ,p_defined_balance_id   number
                                       ,p_effective_date       date)
is
cursor get_bg_leg(p_bg number)
is
select legislation_code
from   per_business_groups
where  business_group_id = p_bg;
--
cursor get_sess_date
is
select effective_date
from   fnd_sessions
where  session_id = userenv('sessionid');
--
l_exists                number;
l_leg_code              varchar2(30);
l_ctl_business_group_id number;
l_ctl_legislation_code  varchar2(30);
l_ctl_session_date      date;
--
begin
-- setup contol variable, similar to ctl_globals variables i the form.
-- The values are based on the mode of the def bal being inserted.
--
if p_def_bal_bg_id is not null and p_def_bal_leg_code is null then
--
  open  get_bg_leg(p_def_bal_bg_id);
  fetch get_bg_leg into l_leg_code;
  close get_bg_leg;
  --
  l_ctl_business_group_id := p_def_bal_bg_id;
  l_ctl_legislation_code  := l_leg_code;
  --
elsif p_def_bal_bg_id is null and p_def_bal_leg_code is not null then
  l_ctl_business_group_id := '';
  l_ctl_legislation_code  := p_def_bal_leg_code;
else
  l_ctl_business_group_id := '';
  l_ctl_legislation_code  := '';
end if;
--
-- now get a default date, if one hasn't been passed in
--
if p_effective_date is null then
  open  get_sess_date;
  fetch get_sess_date into l_ctl_session_date;
  if get_sess_date%notfound then
    close get_sess_date;
    l_ctl_session_date := trunc(sysdate);
  end if;
else
  l_ctl_session_date := p_effective_date;
end if;
--
-- now call the main procedure
--
  insert_default_attributes
        (p_balance_dimension_id => p_balance_dimension_id
        ,p_balance_category_id  => p_balance_category_id
        ,p_ctl_bg_id            => l_ctl_business_group_id
        ,p_ctl_leg_code         => l_ctl_legislation_code
        ,p_ctl_sess_date        => l_ctl_session_date
        ,p_defined_balance_id   => p_defined_balance_id
        ,p_dfbl_bg_id           => p_def_bal_bg_id
        ,p_dfbl_leg_code        => p_def_bal_leg_code);
end insert_default_attrib_wrapper;
-----------------------------------------------------------------------------
-- insert_default_attributes
-- Called directly when called from forms, or using the wrapper procedure
-- insert_default_attrib_wrapper when called from serverside code.
-----------------------------------------------------------------------------
procedure insert_default_attributes(p_balance_dimension_id number
                                   ,p_balance_category_id  number
                                   ,p_ctl_bg_id            number
                                   ,p_ctl_leg_code         varchar2
                                   ,p_ctl_sess_date        date
                                   ,p_defined_balance_id   number
                                   ,p_dfbl_bg_id           number
                                   ,p_dfbl_leg_code        varchar2)
is
--
cursor get_default_attributes(p_dim_id              number
                             ,p_cat_id              number
                             ,ctl_business_group_id number
                             ,ctl_legislation_code  varchar2
                             ,ctl_session_date      date)
is
select pbd.attribute_id
,      pbd.bal_attribute_default_id
from   pay_bal_attribute_defaults pbd
,      pay_balance_categories_f pbc
,      pay_bal_attribute_definitions bad
where  bad.attribute_id = pbd.attribute_id
and    ((ctl_business_group_id is not null
       and bad.alterable = 'Y')
       or ctl_business_group_id is null)
and nvl(pbd.business_group_id, nvl(ctl_business_group_id,-1))
                               = nvl(ctl_business_group_id,-1)
and nvl(pbd.legislation_code, nvl(ctl_legislation_code,' '))
                            = nvl(ctl_legislation_code,' ')
and    pbc.balance_category_id = pbd.balance_category_id
and    ctl_session_date between pbc.effective_start_date
                            and pbc.effective_end_date
and    pbd.balance_dimension_id = p_dim_id
and    pbd.balance_category_id = p_cat_id
order by pbd.attribute_id;
--
cursor attribute_exists(p_att_id     number
                       ,p_def_bal_id number
                       ,p_bg         number
                       ,p_leg        varchar2)
is
select null
from   pay_balance_attributes
where  attribute_id = p_att_id
and    defined_balance_id = p_def_bal_id
and    nvl(business_group_id,-1) = nvl(p_bg, -1)
and    nvl(legislation_code, 'NULL') = nvl(p_leg,'NULL');
--
l_exists                number;
l_balance_attribute_id  pay_balance_attributes.balance_attribute_id%type;
--
begin
for each_attribute in get_default_attributes(p_balance_dimension_id
                                            ,p_balance_category_id
                                            ,p_ctl_bg_id
                                            ,p_ctl_leg_code
                                            ,p_ctl_sess_date) loop
--
open  attribute_exists(each_attribute.attribute_id
                      ,p_defined_balance_id
                      ,p_dfbl_bg_id
                      ,p_dfbl_leg_code);
fetch attribute_exists into l_exists;
if attribute_exists%notfound then
  close attribute_exists;
  --
  pay_balance_attribute_api.create_balance_attribute
  (p_validate             => false
  ,p_attribute_id         => each_attribute.attribute_id
  ,p_defined_balance_id   => p_defined_balance_id
  ,p_business_group_id    => p_dfbl_bg_id
  ,p_legislation_code     => p_dfbl_leg_code
  ,p_balance_attribute_id => l_balance_attribute_id
  );
else
  close attribute_exists;
end if;
end loop;
end insert_default_attributes;
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of a defined         --
 --   balance via the Define Balance Type form.                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --  x_mode only needs to be set when called from forms. Procedure          --
 --  insert_default_attributes is called directly from the form, so don't   --
 --  need to call it in insert_row. But if insert row is being called from  --
 --  serverside code then x_mode is null, and the code will know to call    --
 --  insert_default_attrib_wrapper to insert default attributes, if any     --
 --  exist.                                                                 --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                    IN OUT NOCOPY VARCHAR2,
                      X_Defined_Balance_Id       IN OUT NOCOPY NUMBER,
                      X_Business_Group_Id               NUMBER,
                      X_Legislation_Code                VARCHAR2,
                      X_Balance_Type_Id                 NUMBER,
                      X_Balance_Dimension_Id            NUMBER,
                      X_Force_Latest_Balance_Flag       VARCHAR2,
                      X_Legislation_Subgroup            VARCHAR2,
                      X_Grossup_Allowed_Flag            VARCHAR2 DEFAULT 'N',
                      x_balance_category_id             number default null,
                      x_effective_date                  date default null,
                      x_mode                            varchar2 default null)
 IS
--
   CURSOR C IS SELECT rowid FROM pay_defined_balances
               WHERE  defined_balance_id = X_Defined_Balance_Id;
--
   CURSOR C2 IS SELECT pay_defined_balances_s.nextval FROM sys.dual;
--
   CURSOR C3 IS SELECT count(*) from pay_defined_balances
                WHERE  Balance_Type_Id = X_Balance_Type_Id
                AND    Grossup_Allowed_Flag = 'Y';
--
   cursor get_bal_cat_id(p_bal_type number)
   is
   select balance_category_id
   from   pay_balance_types
   where  balance_type_id = p_bal_type;
   --
   cursor get_eff_date
   is
   select effective_date
   from   fnd_sessions
   where  session_id = userenv('sessionid');
   --
   l_exists number ;
   l_save_run_bal_flag pay_defined_balances.save_run_balance%type;
   l_bal_cat_id        pay_balance_categories_f.balance_category_id%type;
   l_eff_date          date;
--
 BEGIN
 hr_utility.set_location('Entering pay_defined_balances_pkg.insert_row', 5);
--
   -- Make sure that defined balance is unique.
   chk_defined_balance
     (X_Rowid,
      X_Business_Group_Id,
      X_Legislation_Code,
      X_Balance_Type_Id,
      X_Balance_Dimension_Id);
   hr_utility.set_location('pay_defined_balances_pkg.insert_row', 10);
--
   if (X_Defined_Balance_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Defined_Balance_Id;
     CLOSE C2;
   end if;
--
   OPEN C3;
   FETCH C3 INTO l_exists;
   if ( (l_exists = 0  and X_Grossup_Allowed_Flag = 'Y')
         or (X_Grossup_Allowed_Flag = 'N') ) then
   --
   hr_utility.set_location('pay_defined_balances_pkg.insert_row', 15);
   --
   -- check whether save_run_balance can be automatically derived
   -- from the category and dimension flags.
   --
   if x_balance_category_id is null then -- could be called from serverside
   --
   -- get bal cat id for the balance type, if there is one
   --
   hr_utility.set_location('pay_defined_balances_pkg.insert_row', 20);
   --
     open  get_bal_cat_id(x_balance_type_id);
     fetch get_bal_cat_id into l_bal_cat_id;
     if get_bal_cat_id%notfound then
       close get_bal_cat_id;
       l_bal_cat_id := x_balance_category_id;
     else
     --
       close get_bal_cat_id;
       --
       -- row returned, so if the effective date is null, default it.
       --
       if x_effective_date is null then
       hr_utility.set_location('pay_defined_balances_pkg.insert_row', 25);
         open get_eff_date;
         fetch get_eff_date into l_eff_date;
         if get_eff_date%notfound then
           l_eff_date := trunc(sysdate);
         end if;
       else
       hr_utility.set_location('pay_defined_balances_pkg.insert_row', 30);
         l_eff_date := x_effective_date;
       end if;
     end if;
  else -- x_balance_category is not null
    hr_utility.set_location('pay_defined_balances_pkg.insert_row', 35);
    l_bal_cat_id := x_balance_category_id;
    --
    if x_effective_date is null then
      hr_utility.set_message(801, 'PAY_34262_CAT_EFF_DATE_NULL');
      hr_utility.raise_error;
    else
      hr_utility.set_location('pay_defined_balances_pkg.insert_row', 40);
      l_eff_date := x_effective_date;
    end if;
  end if;
  --
   l_save_run_bal_flag := set_save_run_bals_flag(l_bal_cat_id
                                                ,l_eff_date
                                                ,x_balance_dimension_id);
   --
   hr_utility.set_location('pay_defined_balances_pkg.insert_row', 45);
   --
     INSERT INTO pay_defined_balances
     (defined_balance_id,
      business_group_id,
      legislation_code,
      balance_type_id,
      balance_dimension_id,
      force_latest_balance_flag,
      legislation_subgroup,
      grossup_allowed_flag,
      save_run_balance)
     VALUES
     (X_Defined_Balance_Id,
      X_Business_Group_Id,
      X_Legislation_Code,
      X_Balance_Type_Id,
      X_Balance_Dimension_Id,
      X_Force_Latest_Balance_Flag,
      X_Legislation_Subgroup,
      X_Grossup_Allowed_Flag,
      l_save_run_bal_flag);
--
hr_utility.trace('here');
     OPEN C;
     FETCH C INTO X_Rowid;
     if (C%NOTFOUND) then
       CLOSE C;
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                                    'pay_defined_balances_pkg.insert_row');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
     end if;
     CLOSE C;
  --
  -- insert balance attributes after defined balance created. Check the
  -- pay_bal_attribute_defaults table. If a row exists for the category_id
  -- of the balance_type of the defined balance just inserted, and the dimension
  -- just inserted, then create the associated attribute.
  --
  hr_utility.trace('x_mode: '||x_mode);
  --
  if x_mode is null or x_mode <> 'FORM' then
  --
  -- if the variable l_bal_cat_id is null, then no need to try and insert
  -- attribute_defaults
  --
    hr_utility.set_location('pay_defined_balances_pkg.insert_row', 50);
    if l_bal_cat_id is not null then
    --
      hr_utility.set_location('pay_defined_balances_pkg.insert_row', 55);
      insert_default_attrib_wrapper
           (p_balance_dimension_id => x_balance_dimension_id
           ,p_balance_category_id  => l_bal_cat_id
           ,p_def_bal_bg_id        => x_business_group_id
           ,p_def_bal_leg_code     => x_legislation_code
           ,p_defined_balance_id   => x_defined_balance_id
           ,p_effective_date       => l_eff_date
           );
    hr_utility.set_location('pay_defined_balances_pkg.insert_row', 60);
    end if;
  end if;
  else
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                    'pay_defined_balances_pkg.insert_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  end if;
 END Insert_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a defined balance by applying a lock on a defined balance  in the  --
 --   Define Balance Type form.                                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Defined_Balance_Id                    NUMBER,
                    X_Business_Group_Id                     NUMBER,
                    X_Legislation_Code                      VARCHAR2,
                    X_Balance_Type_Id                       NUMBER,
                    X_Balance_Dimension_Id                  NUMBER,
                    X_Force_Latest_Balance_Flag             VARCHAR2,
                    X_Legislation_Subgroup                  VARCHAR2,
                    X_Grossup_Allowed_Flag                  VARCHAR2) IS
--
   CURSOR C IS SELECT * FROM pay_defined_balances
               WHERE  rowid = X_Rowid FOR UPDATE of Defined_Balance_Id NOWAIT;
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
                                  'pay_defined_balances_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
   -- Removed trailing spaces.
   Recinfo.legislation_code := rtrim(Recinfo.legislation_code);
   Recinfo.force_latest_balance_flag := rtrim(Recinfo.force_latest_balance_flag);
   Recinfo.grossup_allowed_flag := rtrim(Recinfo.grossup_allowed_flag);
   Recinfo.legislation_subgroup := rtrim(Recinfo.legislation_subgroup);
--
   if (    (   (Recinfo.defined_balance_id = X_Defined_Balance_Id)
            OR (    (Recinfo.defined_balance_id IS NULL)
                AND (X_Defined_Balance_Id IS NULL)))
       AND (   (Recinfo.business_group_id = X_Business_Group_Id)
            OR (    (Recinfo.business_group_id IS NULL)
                AND (X_Business_Group_Id IS NULL)))
       AND (   (Recinfo.legislation_code = X_Legislation_Code)
            OR (    (Recinfo.legislation_code IS NULL)
                AND (X_Legislation_Code IS NULL)))
       AND (   (Recinfo.balance_type_id = X_Balance_Type_Id)
            OR (    (Recinfo.balance_type_id IS NULL)
                AND (X_Balance_Type_Id IS NULL)))
       AND (   (Recinfo.balance_dimension_id = X_Balance_Dimension_Id)
            OR (    (Recinfo.balance_dimension_id IS NULL)
                AND (X_Balance_Dimension_Id IS NULL)))
       AND (   (Recinfo.force_latest_balance_flag = X_Force_Latest_Balance_Flag)
            OR (    (Recinfo.force_latest_balance_flag IS NULL)
                AND (X_Force_Latest_Balance_Flag IS NULL)))
       AND (   (Recinfo.grossup_allowed_flag = X_Grossup_Allowed_Flag)
            OR (    (Recinfo.grossup_allowed_flag IS NULL)
                AND (X_Grossup_Allowed_Flag IS NULL)))
       AND (   (Recinfo.legislation_subgroup = X_Legislation_Subgroup)
            OR (    (Recinfo.legislation_subgroup IS NULL)
                AND (X_Legislation_Subgroup IS NULL)))
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
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of a defined         --
 --   balance via the Define Balance Type form.                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Defined_Balance_Id                  NUMBER,
                      X_Business_Group_Id                   NUMBER,
                      X_Legislation_Code                    VARCHAR2,
                      X_Balance_Type_Id                     NUMBER,
                      X_Balance_Dimension_Id                NUMBER,
                      X_Force_Latest_Balance_Flag           VARCHAR2,
                      X_Legislation_Subgroup                VARCHAR2,
                      X_Grossup_Allowed_Flag                VARCHAR2) IS
--
 l_exists number;
--
   CURSOR C3 IS SELECT count(*) from pay_defined_balances
                WHERE  Balance_Type_Id = X_Balance_Type_Id
                AND    Grossup_Allowed_Flag = 'Y';
--
 BEGIN
--
   OPEN C3;
   FETCH C3 INTO l_exists;
   if ( (l_exists = 0  and X_Grossup_Allowed_Flag = 'Y')
         or (X_Grossup_Allowed_Flag = 'N') ) then
--
     UPDATE pay_defined_balances
     SET defined_balance_id          =    X_Defined_Balance_Id,
         business_group_id           =    X_Business_Group_Id,
         legislation_code            =    X_Legislation_Code,
         balance_type_id             =    X_Balance_Type_Id,
         balance_dimension_id        =    X_Balance_Dimension_Id,
         force_latest_balance_flag   =    X_Force_Latest_Balance_Flag,
         legislation_subgroup        =    X_Legislation_Subgroup,
         grossup_allowed_flag        =    X_Grossup_Allowed_Flag
     WHERE rowid = X_rowid;
--
     if (SQL%NOTFOUND) then
       hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE',
                                    'pay_defined_balances_pkg.update_row');
       hr_utility.set_message_token('STEP','1');
       hr_utility.raise_error;
     end if;
  --
   else
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                    'pay_defined_balances_pkg.update_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
   END Update_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a defined         --
 --   balance via the Define Balance Type form.                             --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid               VARCHAR2,
		      -- Extra Columns
		      X_Defined_Balance_Id  NUMBER) IS
--
 BEGIN
--
   -- Check that the delete is valid.
   chk_delete_defined_balance(X_Defined_Balance_Id);
--
   -- Remove any latest balances for the defined balance.
   delete_defined_balance(X_Defined_Balance_Id);
--
   DELETE FROM pay_defined_balances
   WHERE  rowid = X_Rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_defined_balances_pkg.delete_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
 END Delete_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   verify_save_run_bal_flag_upd                                          --
 -- Purpose                                                                 --
 --   Called from trigger pay_defined_balances_bru to prevent the update of --
 --   SAVE_RUN_BALANCE flag from 'Y' to 'N' or null, when valid run         --
 --   balances exist for the defined balance.
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --
 -----------------------------------------------------------------------------
 PROCEDURE verify_save_run_bal_flag_upd(p_defined_balance_id    number
                                       ,p_old_save_run_bal_flag varchar2
                                       ,p_new_save_run_bal_flag varchar2) IS
 --
 cursor check_runbals (p_def_bal_id in number)
 is
 select 1
 from   pay_balance_validation pbv
 ,      pay_run_balances prb
 where  pbv.run_balance_status = 'V'
 and    pbv.defined_balance_id = p_def_bal_id
 and    pbv.defined_balance_id = prb.defined_balance_id;
 --
 l_exists number;
 --
 BEGIN
 --
 hr_utility.set_location('Entering: pay_defined_balance_pkg.verify_save_run_bal_flag_upd', 5);
 --
   if p_old_save_run_bal_flag = 'Y' then
   --
     if p_new_save_run_bal_flag is null
     or p_new_save_run_bal_flag <> 'Y' then
     --
       open check_runbals (p_defined_balance_id);
       fetch check_runbals into l_exists;
       if check_runbals%found then
       --
       -- raise error
       --
         close check_runbals;
         hr_utility.set_location('pay_defined_balance_pkg.verify_save_run_bal_flag_upd', 10);
         --
         hr_utility.set_message(801, 'PAY_33528_SAVERUNBAL_INV_UPD');
         hr_utility.raise_error;
         --
       else
         close check_runbals;
         hr_utility.set_location('pay_defined_balance_pkg.verify_save_run_bal_flag_upd', 20);
       end if;
     end if;
   end if;
 hr_utility.set_location('Leaving: pay_defined_balance_pkg.verify_save_run_bal_flag_upd', 30);
 --
 END verify_save_run_bal_flag_upd;
 -----------------------------------------------------------------------------
END PAY_DEFINED_BALANCES_PKG;

/
