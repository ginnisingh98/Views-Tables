--------------------------------------------------------
--  DDL for Package Body PAY_FORMULA_RESULT_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FORMULA_RESULT_RULES_PKG" as
/* $Header: pyfrr.pkb 115.6 2002/12/10 18:44:52 dsaxby ship $ */
-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
g_dummy number(1);      -- Dummy for cursor returns which are not needed
--------------------------------------------------------------------------------
procedure CHECK_UNIQUE (
--
--******************************************************************************
--* Performs checks for uniqueness of result rules. Each rule type is tested   *
--* in separate cursors to simplify the code and to modularise the procedure.  *
--* The procedure will work for both insert and update tests as it tests rowid.*
--******************************************************************************
--
        p_status_processing_rule_id     number,
        p_result_rule_type              varchar2,
        p_result_name                   varchar2,
        p_effective_end_date            date,
        p_session_date                  date,
        p_rowid                         varchar2 default null,
        p_element_type_id               number default null,
        p_input_value_id                number default null) is
--
  function DIRECT_RESULT_RULE_NOT_UNIQUE
        -- Returns TRUE if the tested direct rule already exists
        -- Only one direct result rule is allowed for each SPR
        return boolean is
        v_duplicate_found       boolean := FALSE;
        cursor csr_duplicate_rule is
                select  1
                from    PAY_FORMULA_RESULT_RULES_F
                where   status_processing_rule_id = p_status_processing_rule_id
                and     result_rule_type        = 'D'
                and     (p_rowid is null
                        or (p_rowid is not null and p_rowid <> rowid))
                and     effective_start_date    <=p_effective_end_date
                and     effective_end_date      >=p_session_date;
        begin
        --
        hr_utility.set_location ('pay_formula_result_rules_pkg.check_unique',3);
        --
        open csr_duplicate_rule;
        fetch csr_duplicate_rule into g_dummy;
        v_duplicate_found := csr_duplicate_rule%found;
        close csr_duplicate_rule;
        --
        return v_duplicate_found;
        --
        end direct_result_rule_not_unique;
        --
  function MESSAGE_RULE_NOT_UNIQUE
        -- Returns TRUE if the tested message rule already exists
        -- Only one message rule is allowed for each SPR/result name combination
        return boolean is
        v_duplicate_found       boolean := FALSE;
        cursor csr_duplicate_rule is
                select  1
                from    pay_formula_result_rules_f
                where   status_processing_rule_id = p_status_processing_rule_id
                and     result_rule_type        = 'M'
                and     result_name             = p_result_name
                and     effective_start_date    <=p_effective_end_date
                and     effective_end_date      >=p_session_date
                and     (p_rowid is null
                        or (p_rowid is not null and p_rowid <> rowid));
        begin
        --
        hr_utility.set_location ('pay_formula_result_rules_pkg.check_unique',4);
        --
        open csr_duplicate_rule;
        fetch csr_duplicate_rule into g_dummy;
        v_duplicate_found := csr_duplicate_rule%found;
        close csr_duplicate_rule;
        --
        return v_duplicate_found;
        --
        end message_rule_not_unique;
        --
  function STOP_ENTRY_RULE_NOT_UNIQUE
        -- Returns TRUE if the tested stop-entry rule already exists
        -- Only one stop-entry rule is allowed for each combination of
        -- result name, SPR and element type
        return boolean is
        v_duplicate_found       boolean := FALSE;
        cursor csr_duplicate_rule is
                select  1
                from    pay_formula_result_rules_f
                where   status_processing_rule_id = p_status_processing_rule_id
                and     result_rule_type        = 'S'
                and     result_name             = p_result_name
                and     (p_rowid is null
                        or (p_rowid is not null and p_rowid <> rowid))
                and     effective_start_date    <=p_effective_end_date
                and     effective_end_date      >=p_session_date
                and     element_type_id         = p_element_type_id;
        begin
        --
        hr_utility.set_location ('pay_formula_result_rules_pkg.check_unique',5);
        --
        open csr_duplicate_rule;
        fetch csr_duplicate_rule into g_dummy;
        v_duplicate_found := csr_duplicate_rule%found;
        close csr_duplicate_rule;
        --
        return v_duplicate_found;
        --
        end stop_entry_rule_not_unique;
        --
  function OTHER_RULE_TYPE_NOT_UNIQUE
        -- Returns TRUE if any duplicate rule/rule-type/input-value is found
        -- Only one indirect and one update-recurring rule is allowed for each
        -- combination of SPR, result name and input value
        return boolean is
        v_duplicate_found       boolean := FALSE;
        cursor csr_duplicate_rule is
                select  1
                from    pay_formula_result_rules_f
                where   status_processing_rule_id = p_status_processing_rule_id
                and     result_rule_type        = p_result_rule_type
                and     result_name             = p_result_name
                and     input_value_id          = p_input_value_id
                and     (p_rowid is null
                        or (p_rowid is not null and p_rowid <> rowid))
                and     effective_start_date    <=p_effective_end_date
                and     effective_end_date      >=p_session_date;
        begin
        --
        hr_utility.set_location ('pay_formula_result_rules_pkg.check_unique',6);
        --
        open csr_duplicate_rule;
        fetch csr_duplicate_rule into g_dummy;
        v_duplicate_found := csr_duplicate_rule%found;
        close csr_duplicate_rule;
        --
        return v_duplicate_found;
        --
        end other_rule_type_not_unique;
        --
begin
--
hr_utility.set_location ('pay_formula_result_rules_pkg.check_unique',1);
--
--if (p_result_rule_type = 'D'  and direct_result_rule_not_unique) then
  --
 -- hr_utility.set_message (801, 'HR_6503_FF_DIRECT');
  --hr_utility.raise_error;
  --
if      (p_result_rule_type = 'M'       and message_rule_not_unique)
or      (p_result_rule_type = 'S'       and stop_entry_rule_not_unique)
or      (p_result_rule_type in('U','I','D')     and other_rule_type_not_unique) then
  --
  hr_utility.set_message (801, 'HR_6478_FF_UNI_FRR');
  hr_utility.raise_error;
  --
end if;
--
end check_unique;
--------------------------------------------------------------------------------
function TARGET_PAY_VALUE (
--*******************************************************************************
--* Returns the ID of the pay value for the target element of the result rule.  *
--* This is needed for the input value in the case of direct result rules,      *
--* because we do not allow the user to select the input value himself.         *
--* NB The element type passed in MUST be that of the element type from the     *
--* parent SPR and not one selected by the user as the element type for the     *
--* result rule.                                                                *
--*******************************************************************************
--
--
        p_element_type_id       number,
        p_result_data_type      varchar2) return number is
--
v_pay_value             varchar2(80) := hr_general.pay_value;
v_input_value_id        number(10);
--
cursor csr_input_value is
  select  ipv.input_value_id
  from    pay_input_values_f_tl ipv_tl,
          pay_input_values_f ipv
  where   ipv_tl.input_value_id = ipv.input_value_id
  and     userenv('LANG') = ipv_tl.language
  and     ipv.element_type_id = p_element_type_id
  and     ipv_tl.name = v_pay_value
  and     ((p_result_data_type = 'D' and ipv.uom = 'D')
  or      (p_result_data_type = 'T' and ipv.uom = 'C')
  or      (p_result_data_type = 'N' and substr(ipv.uom,1,1) in ('H','I','M','N')));

--
begin
--
hr_utility.set_location ('pay_formula_result_rules_pkg.target_pay_value',1);
--
open csr_input_value;
fetch csr_input_value into v_input_value_id;
--
if csr_input_value%notfound then
  close csr_input_value;
  hr_utility.set_message (801,'HR_6501_FF_INVALID_UOM');
  hr_utility.raise_error;
else
  close csr_input_value;
end if;
--
return v_input_value_id;
--
end target_pay_value;
--------------------------------------------------------------------------------
PROCEDURE Insert_Row(p_Rowid                        IN OUT NOCOPY VARCHAR2,
                     p_Formula_Result_Rule_Id       IN OUT NOCOPY NUMBER,
                     p_Effective_Start_Date                DATE,
                     p_Effective_End_Date                  DATE,
                     p_Business_Group_Id                   NUMBER,
                     p_Legislation_Code                    VARCHAR2,
                     p_Element_Type_Id                     NUMBER,
                     p_Status_Processing_Rule_Id           NUMBER,
                     p_Result_Name                         VARCHAR2,
                     p_Result_Rule_Type                    VARCHAR2,
                     p_Legislation_Subgroup                VARCHAR2,
                     p_Severity_Level                      VARCHAR2,
                     p_Input_Value_Id                      NUMBER,
                     p_Created_By                          NUMBER,
                        p_session_date                          date
 ) IS
   CURSOR C IS SELECT rowid FROM pay_formula_result_rules_f
             WHERE  formula_result_rule_id = p_formula_result_rule_id
             AND   effective_start_date = p_Effective_Start_Date;



    CURSOR C2 IS SELECT pay_formula_result_rules_s.nextval FROM sys.dual;
BEGIN
--
hr_utility.set_location ('pay_formula_result_rules_pkg.insert_row',1);
--
check_unique (p_status_processing_rule_id,
                p_result_rule_type,
                p_result_name,
                p_effective_end_date,
                p_session_date,
                p_rowid,
                p_element_type_id,
                p_input_value_id) ;
--
hr_utility.set_location ('pay_formula_result_rules_pkg.insert_row',2);
--
   if (p_formula_result_rule_id is NULL) then
     OPEN C2;
     FETCH C2 INTO p_formula_result_rule_id;
     CLOSE C2;
   end if;
--
hr_utility.set_location ('pay_formula_result_rules_pkg.insert_row',3);
--
  insert into pay_formula_result_rules_f(
          formula_result_rule_id,
          effective_start_date,
          effective_end_date,
          business_group_id,
          legislation_code,
          element_type_id,
          status_processing_rule_id,
          result_name,
          result_rule_type,
          legislation_subgroup,
          severity_level,
          input_value_id,
          creation_date
         )
  values (
          p_Formula_Result_Rule_Id,
          p_Effective_Start_Date,
          p_Effective_End_Date,
          p_Business_Group_Id,
          p_Legislation_Code,
          p_Element_Type_Id,
          p_Status_Processing_Rule_Id,
          p_Result_Name,
          p_Result_Rule_Type,
          p_Legislation_Subgroup,
          p_Severity_Level,
          p_Input_Value_Id,
          sysdate);

--
hr_utility.set_location ('pay_formula_result_rules_pkg.insert_row',4);
--
  OPEN C;
  FETCH C INTO p_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
END Insert_Row;
PROCEDURE Lock_Row(p_Rowid                                 VARCHAR2,
                   p_Formula_Result_Rule_Id                NUMBER,
                   p_Effective_Start_Date                  DATE,
                   p_Effective_End_Date                    DATE,
                   p_Business_Group_Id                     NUMBER,
                   p_Legislation_Code                      VARCHAR2,
                   p_Element_Type_Id                       NUMBER,
                   p_Status_Processing_Rule_Id             NUMBER,
                   p_Result_Name                           VARCHAR2,
                   p_Result_Rule_Type                      VARCHAR2,
                   p_Legislation_Subgroup                  VARCHAR2,
                   p_Severity_Level                        VARCHAR2,
                   p_Input_Value_Id                        NUMBER
) IS
  CURSOR C IS
      SELECT *
      FROM   pay_formula_result_rules_f
      WHERE  rowid = p_Rowid
      FOR UPDATE of formula_result_rule_id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.formula_result_rule_id = p_Formula_Result_Rule_Id)
           OR (    (Recinfo.formula_result_rule_id IS NULL)
               AND (p_Formula_Result_Rule_Id IS NULL)))
      AND (   (Recinfo.effective_start_date = p_Effective_Start_Date)
           OR (    (Recinfo.effective_start_date IS NULL)
               AND (p_Effective_Start_Date IS NULL)))
      AND (   (Recinfo.effective_end_date = p_Effective_End_Date)
           OR (    (Recinfo.effective_end_date IS NULL)
               AND (p_Effective_End_Date IS NULL)))
      AND (   (Recinfo.business_group_id = p_Business_Group_Id)
           OR (    (Recinfo.business_group_id IS NULL)
               AND (p_Business_Group_Id IS NULL)))
      AND (   (Recinfo.legislation_code = p_Legislation_Code)
           OR (    (Recinfo.legislation_code IS NULL)
               AND (p_Legislation_Code IS NULL)))
      AND (   (Recinfo.element_type_id = p_Element_Type_Id)
           OR (    (Recinfo.element_type_id IS NULL)
               AND (p_Element_Type_Id IS NULL)))
      AND (   (Recinfo.status_processing_rule_id = p_Status_Processing_Rule_Id)
           OR (    (Recinfo.status_processing_rule_id IS NULL)
               AND (p_Status_Processing_Rule_Id IS NULL)))
      AND (   (Recinfo.result_name = p_Result_Name)
           OR (    (Recinfo.result_name IS NULL)
               AND (p_Result_Name IS NULL)))
      AND (   (Recinfo.result_rule_type = p_Result_Rule_Type)
           OR (    (Recinfo.result_rule_type IS NULL)
               AND (p_Result_Rule_Type IS NULL)))
      AND (   (Recinfo.legislation_subgroup = p_Legislation_Subgroup)
           OR (    (Recinfo.legislation_subgroup IS NULL)
               AND (p_Legislation_Subgroup IS NULL)))
      AND (   (Recinfo.severity_level = p_Severity_Level)
           OR (    (Recinfo.severity_level IS NULL)
               AND (p_Severity_Level IS NULL)))
      AND (   (Recinfo.input_value_id = p_Input_Value_Id)
           OR (    (Recinfo.input_value_id IS NULL)
               AND (p_Input_Value_Id IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(p_Rowid                               VARCHAR2,
                     p_Formula_Result_Rule_Id              NUMBER,
                     p_Effective_Start_Date                DATE,
                     p_Effective_End_Date                  DATE,
                     p_Business_Group_Id                   NUMBER,
                     p_Legislation_Code                    VARCHAR2,
                     p_Element_Type_Id                     NUMBER,
                     p_Status_Processing_Rule_Id           NUMBER,
                     p_Result_Name                         VARCHAR2,
                     p_Result_Rule_Type                    VARCHAR2,
                     p_Legislation_Subgroup                VARCHAR2,
                     p_Severity_Level                      VARCHAR2,
                     p_Input_Value_Id                      NUMBER,
                     p_Last_Update_Date                    DATE,
                     p_Last_Updated_By                     NUMBER,
                     p_Last_Update_Login                   NUMBER
) IS
BEGIN
  UPDATE pay_formula_result_rules_f
  SET

    formula_result_rule_id                    =    p_Formula_Result_Rule_Id,
    effective_start_date                      =    p_Effective_Start_Date,
    effective_end_date                        =    p_Effective_End_Date,
    business_group_id                         =    p_Business_Group_Id,
    legislation_code                          =    p_Legislation_Code,
    element_type_id                           =    p_Element_Type_Id,
    status_processing_rule_id                 =    p_Status_Processing_Rule_Id,
    result_name                               =    p_Result_Name,
    result_rule_type                          =    p_Result_Rule_Type,
    legislation_subgroup                      =    p_Legislation_Subgroup,
    severity_level                            =    p_Severity_Level,
    input_value_id                            =    p_Input_Value_Id,
    last_update_date                          =    p_Last_Update_Date,
    last_updated_by                           =    p_Last_Updated_By,
    last_update_login                         =    p_Last_Update_Login
  WHERE rowid = p_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;
--------------------------------------------------------------------------------

PROCEDURE Delete_Row(p_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM pay_formula_result_rules_f
  WHERE  rowid = p_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;
--------------------------------------------------------------------------------
procedure PARENT_DELETED (
--
--******************************************************************************
--* Handles the case when any row referenced by a foreign key of the base      *
--* is deleted (in whatever Date Track mode). ie If a parent record is zapped  *
--* then the deletion is cascaded; if it is date-effectively deleted, then the *
--* rows referencing it are updated to have the same end-date.                 *
--******************************************************************************
--
-- Parameters to be passed in are:
--
p_parent_name           varchar2, -- The name of the parent entity
p_parent_id             number,-- The foreign key for the deleted parent
p_session_date          date,
p_delete_mode           varchar2
) is
--
-- The following cursor fetches all rows identified by the foreign key to
-- the parent being deleted. The parent name identifies foreign key column
-- to use, thus the procedure is generic to any parent deletion
--
cursor csr_rows_owned_by_parent is
        select  rowid,pay_formula_result_rules_f.*
        from    pay_formula_result_rules_f
        where   p_parent_id     = decode (p_parent_name,
                'PAY_STATUS_PROCESSING_RULES_F',status_processing_rule_id,
                'PAY_ELEMENT_TYPES_F',element_type_id,
                'PAY_INPUT_VALUES_F',input_value_id)
        for update;
--
begin
hr_utility.set_location ('pay_sub_class_rules_pkg.parent_deleted',1);
--
<<REMOVE_ORPHANED_ROWS>>
for fetched_row in csr_rows_owned_by_parent LOOP
--
        -- If in ZAP mode then all rows belonging to the deleted
        -- parent must be deleted. If in DELETE (ie date-effective
        -- delete) mode then only rows with a future start date
        -- must be deleted, and current rows must be updated so
        -- that their end dates match that of their closed-down
        -- parent. Current and future are determined by session
        -- date.
--
  if p_delete_mode = 'ZAP'      -- ie delete all rows
  or (p_delete_mode = 'DELETE'  -- ie delete all future rows
        and fetched_row.effective_start_date > p_session_date) then
--
    -- Do not allow zapping of result rules which target the parent element
    -- (and thereby prevent zapping of the parent element)

    if p_delete_mode = 'ZAP' and fetched_row.result_rule_type = 'S'
    and p_parent_name = 'PAY_ELEMENT_TYPES_F' then
      hr_utility.set_message (801,'PAY_6157_ELEMENT_NO_DEL_FRR');
      hr_utility.raise_error;
    end if;
--
        delete from pay_formula_result_rules_f
        where current of csr_rows_owned_by_parent;
--
        delete from hr_application_ownerships
        where key_name = 'FORMULA_RESULT_RULE_ID'
        and key_value = fetched_row.formula_result_rule_id;
--
  elsif p_delete_mode = 'DELETE'
  and p_session_date    between fetched_row.effective_start_date
                        and     fetched_row.effective_end_date then
--
        update pay_formula_result_rules_f
        set effective_end_date  = p_session_date
        where current of csr_rows_owned_by_parent;
--
  elsif p_delete_mode = 'DELETE_NEXT_CHANGE'
  and p_parent_name = 'PAY_STATUS_PROCESSING_RULES_F' then
    --
    -- Do not allow delete-next-change to orphan result rules
    --
    hr_utility.set_message (801,'HR_7451_SPR_NO_DEL_NEXT_CHANGE');
    hr_utility.raise_error;
    --
  end if;
--
end loop remove_orphaned_rows;
--
end parent_deleted;
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- pay_formula_result_rules_pkg.result_rule_end_date                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Returns the correct end date for a result rule. It takes into account    --
 -- the end date of any future result rules and corresponding business rules --
 ------------------------------------------------------------------------------
--
 function result_rule_end_date
 (
  p_formula_result_rule_id       number,
  p_result_rule_type             varchar2,
  p_result_name                  varchar2,
  p_status_processing_rule_id    number,
  p_element_type_id              number,
  p_input_value_id               number,
  p_session_date                 date,
  p_max_spr_end_date             date
  ) return date is
--
  v_result_rule_end_date        date;
--
  cursor c_direct_rule is
    select min(frr.effective_start_date) -1
    from   pay_formula_result_rules_f frr
    where  frr.status_processing_rule_id = p_status_processing_rule_id
    and    frr.result_rule_type = 'D'
    and    frr.formula_result_rule_id <> nvl(p_formula_result_rule_id,0)
    and    frr.effective_end_date >= p_session_date;
--
  cursor c_message_rule is
    select min(frr.effective_start_date) -1
    from   pay_formula_result_rules_f frr
    where  frr.status_processing_rule_id = p_status_processing_rule_id
    and    frr.result_rule_type = 'M'
    and    frr.result_name = p_result_name
    and    frr.formula_result_rule_id <> nvl(p_formula_result_rule_id,0)
    and    frr.effective_end_date >= p_session_date;
--
  cursor c_stop_entry is
    select min(frr.effective_start_date) -1
    from   pay_formula_result_rules_f frr
    where  frr.status_processing_rule_id = p_status_processing_rule_id
    and    frr.result_rule_type = 'S'
    and    frr.result_name = p_result_name
    and    frr.element_type_id = p_element_type_id
    and    frr.formula_result_rule_id <> nvl(p_formula_result_rule_id,0)
    and    frr.effective_end_date >= p_session_date;
--
  cursor c_other_rules is
    select min(frr.effective_start_date) -1
    from   pay_formula_result_rules_f frr
    where  frr.status_processing_rule_id = p_status_processing_rule_id
    and    frr.result_rule_type = p_result_rule_type
    and    frr.result_name = p_result_name
    and    frr.input_value_id = p_input_value_id
    and    frr.formula_result_rule_id <> nvl(p_formula_result_rule_id,0)
    and    frr.effective_end_date >= p_session_date;
--
 begin
--
 -- if p_result_rule_type = 'D' then
  --  open c_direct_rule;
 --   fetch c_direct_rule into v_result_rule_end_date;
  --    if c_direct_rule%notfound then
   --     close c_direct_rule;
   --   end if;
   -- close c_direct_rule;
  if p_result_rule_type = 'M' then
    open c_message_rule;
    fetch c_message_rule into v_result_rule_end_date;
      if c_message_rule%notfound then
        close c_message_rule;
      end if;
    close c_message_rule;
  elsif p_result_rule_type = 'S' then
    open c_stop_entry;
    fetch c_stop_entry into v_result_rule_end_date;
      if c_stop_entry%notfound then
        close c_stop_entry;
      end if;
    close c_stop_entry;
  else
    open c_other_rules;
    fetch c_other_rules into v_result_rule_end_date;
      if c_other_rules%notfound then
        close c_other_rules;
      end if;
    close c_other_rules;
  end if;
--
  if v_result_rule_end_date is null then
    v_result_rule_end_date := p_max_spr_end_date;
  end if;
--
  return v_result_rule_end_date;
--
 end result_rule_end_date;
--------------------------------------------------------------------------------
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- pay_formula_result_rules_pkg.formula_results_changed                     --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Returns 'TRUE' if the formula has been changed to return different       --
 -- results which will now invalidate result rules.                          --
 ------------------------------------------------------------------------------
--
 function formula_results_changed
 (
  p_formula_id            number,
  p_result_name           varchar2,
  p_result_rule_type      varchar2,
  p_effective_start_date  date,
  p_effective_end_date    date
  ) return boolean is
--
  cursor c_results_changed is
    select 1
    from   dual
    where  p_result_name not in (select ffu.item_name
                                 from   ff_fdi_usages_f ffu
                                 where  ffu.formula_id = p_formula_id
                                 and    ffu.usage in ('O','B')
                                 and    effective_start_date <= p_effective_end_date
                                 and    effective_end_date >= p_effective_start_date
                                 and    (ffu.data_type = 'N'
                                 or     p_result_rule_type is null
                                 or     p_result_rule_type <> 'O'));
--
results_changed   boolean  := FALSE;
--
begin
--
open c_results_changed;
fetch c_results_changed into g_dummy;
results_changed := c_results_changed%found;
close c_results_changed;
--
return results_changed;
end formula_results_changed;
--------------------------------------------------------------------------------
end PAY_FORMULA_RESULT_RULES_PKG;

/
