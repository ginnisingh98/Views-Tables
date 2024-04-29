--------------------------------------------------------
--  DDL for Package Body PAY_STATUS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_STATUS_RULES_PKG" as
/* $Header: pyspr.pkb 115.10 2003/10/21 02:03:00 alogue ship $ */
--
--------------------------------------------------------------------------------
g_dummy	number(1)	:= null; -- dummy output from cursors
--------------------------------------------------------------------------------
--
PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Status_Processing_Rule_Id    IN OUT NOCOPY NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Legislation_Code                    VARCHAR2,
                     X_Element_Type_Id                     NUMBER,
                     X_Assignment_Status_Type_Id           NUMBER,
                     X_Formula_Id                          NUMBER,
                     X_Processing_Rule                     VARCHAR2,
                     X_Comment_Id                          NUMBER,
                     X_Legislation_Subgroup                VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Created_By                          NUMBER,
                     X_Creation_Date                       DATE) IS

   CURSOR C IS SELECT rowid FROM pay_status_processing_rules_f
             WHERE  status_processing_rule_id= X_status_processing_rule_id
             AND   effective_start_date = X_Effective_Start_Date;



    CURSOR C2 IS SELECT pay_status_processing_rules_s.nextval FROM sys.dual;
BEGIN

   if (X_status_processing_rule_id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_status_processing_rule_id;
     CLOSE C2;
   end if;
  INSERT INTO pay_status_processing_rules_f(
          status_processing_rule_id,
          effective_start_date,
          effective_end_date,
          business_group_id,
          legislation_code,
          element_type_id,
          assignment_status_type_id,
          formula_id,
          processing_rule,
          comment_id,
          legislation_subgroup,
          last_update_date,
          last_updated_by,
          last_update_login,
          created_by,
          creation_date
         ) VALUES (
          X_Status_Processing_Rule_Id,
          X_Effective_Start_Date,
          X_Effective_End_Date,
          X_Business_Group_Id,
          X_Legislation_Code,
          X_Element_Type_Id,
          X_Assignment_Status_Type_Id,
          X_Formula_Id,
          X_Processing_Rule,
          X_Comment_Id,
          X_Legislation_Subgroup,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Last_Update_Login,
          X_Created_By,
          X_Creation_Date

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
                   X_Status_Processing_Rule_Id             NUMBER,
                   X_Effective_Start_Date                  DATE,
                   X_Effective_End_Date                    DATE,
                   X_Business_Group_Id                     NUMBER,
                   X_Legislation_Code                      VARCHAR2,
                   X_Element_Type_Id                       NUMBER,
                   X_Assignment_Status_Type_Id             NUMBER,
                   X_Formula_Id                            NUMBER,
                   X_Processing_Rule                       VARCHAR2,
                   X_Comment_Id                            NUMBER,
                   X_Legislation_Subgroup                  VARCHAR2) IS
  CURSOR C IS
      SELECT *
      FROM   pay_status_processing_rules_f
      WHERE  rowid = X_Rowid
      FOR UPDATE of status_processing_rule_id NOWAIT;
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
          (   (Recinfo.status_processing_rule_id = X_Status_Processing_Rule_Id)
           OR (    (Recinfo.status_processing_rule_id IS NULL)
               AND (X_Status_Processing_Rule_Id IS NULL)))
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
      AND (   (Recinfo.element_type_id = X_Element_Type_Id)
           OR (    (Recinfo.element_type_id IS NULL)
               AND (X_Element_Type_Id IS NULL)))
      AND (   (Recinfo.assignment_status_type_id = X_Assignment_Status_Type_Id)
           OR (    (Recinfo.assignment_status_type_id IS NULL)
               AND (X_Assignment_Status_Type_Id IS NULL)))
      AND (   (Recinfo.formula_id = X_Formula_Id)
           OR (    (Recinfo.formula_id IS NULL)
               AND (X_Formula_Id IS NULL)))
      AND (   (Recinfo.processing_rule = X_Processing_Rule)
           OR (    (Recinfo.processing_rule IS NULL)
               AND (X_Processing_Rule IS NULL)))
      AND (   (Recinfo.comment_id = X_Comment_Id)
           OR (    (Recinfo.comment_id IS NULL)
               AND (X_Comment_Id IS NULL)))
      AND (   (Recinfo.legislation_subgroup = X_Legislation_Subgroup)
           OR (    (Recinfo.legislation_subgroup IS NULL)
               AND (X_Legislation_Subgroup IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Status_Processing_Rule_Id           NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Business_Group_Id                   NUMBER,
                     X_Legislation_Code                    VARCHAR2,
                     X_Element_Type_Id                     NUMBER,
                     X_Assignment_Status_Type_Id           NUMBER,
                     X_Formula_Id                          NUMBER,
                     X_Processing_Rule                     VARCHAR2,
                     X_Comment_Id                          NUMBER,
                     X_Legislation_Subgroup                VARCHAR2,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Last_Update_Login                   NUMBER
) IS
BEGIN
  UPDATE pay_status_processing_rules_f
  SET

    status_processing_rule_id                 =    X_Status_Processing_Rule_Id,
    effective_start_date                      =    X_Effective_Start_Date,
    effective_end_date                        =    X_Effective_End_Date,
    business_group_id                         =    X_Business_Group_Id,
    legislation_code                          =    X_Legislation_Code,
    element_type_id                           =    X_Element_Type_Id,
    assignment_status_type_id                 =    X_Assignment_Status_Type_Id,
    formula_id                                =    X_Formula_Id,
    processing_rule                           =    X_Processing_Rule,
    comment_id                                =    X_Comment_Id,
    legislation_subgroup                      =    X_Legislation_Subgroup,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    last_update_login                         =    X_Last_Update_Login
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2,
			p_session_date date,
			p_delete_mode varchar2,
			p_status_processing_rule_id number) IS
BEGIN
  DELETE FROM pay_status_processing_rules_f
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
--
    -- Cascade the action to formula result rules for this SPR
    pay_formula_result_rules_pkg.parent_deleted (
    --
        'PAY_STATUS_PROCESSING_RULES_F',
        p_status_processing_rule_id,
        p_session_date,
        p_delete_mode                           );
--
END Delete_Row;
--------------------------------------------------------------------------------
function SPR_END_DATE (p_status_processing_rule_id	number,
                       p_formula_id                     number) return date is
--
--******************************************************************************
--*Returns the final date effective end date of the given status processing rule
--******************************************************************************
--
cursor csr_spr_end_date is
	select	max(effective_end_date)
	from	pay_status_processing_rules_f
	where	status_processing_rule_id	= p_status_processing_rule_id;
--
cursor csr_spr_formula_end_date is
        select min(effective_start_date) -1
        from   pay_status_processing_rules_f
        where  status_processing_rule_id = p_status_processing_rule_id
        and    formula_id                <> p_formula_id;
--
v_date1         date;
v_date2         date  := null;
v_end_date	date;
--
begin
--
hr_utility.set_location ('PAY_STATUS_RULES_PKG',1);
--
open csr_spr_end_date;
fetch csr_spr_end_date into v_date1;
close csr_spr_end_date;
--
open csr_spr_formula_end_date;
fetch csr_spr_formula_end_date into v_date2;
  if csr_spr_formula_end_date%notfound then
    close csr_spr_formula_end_date;
  end if;
close csr_spr_formula_end_date;
--
  if v_date2 is not null and v_date2 < v_date1 then
    v_end_date := v_date2;
  else
    v_end_date := v_date1;
  end if;
--
return v_end_date;
--
end spr_end_date;
--------------------------------------------------------------------------------
procedure PARENT_DELETED (
					--
--******************************************************************************
--* Handles the case when any row referenced by a foreign key of the base      *
--* is deleted (in whatever Date Track mode). ie If a parent record is zapped  *
--* then the deletion is cascaded; if it is date-effectively deleted, then the *
--* rows referencing it are updated to have the same end-date.		       *
--******************************************************************************
					--
-- Parameters to be passed in are:
	--
	-- The value of the foreign key for the deleted parent
	p_element_type_id	number,
					--
	-- The date of date-effective deletion
	p_session_date	date		default trunc (sysdate),
					--
	-- The type of deletion action being performed
	p_delete_mode	varchar2	default 'DELETE'
					--
						) is
					--
-- The following cursor fetches all rows identified by the foreign key to
-- the parent being deleted.
					--
cursor csr_rows_owned_by_parent is
	select	*
	from	pay_status_processing_rules_f
	where	element_type_id	= p_element_type_id
	for update;
					--
begin
					--
hr_utility.set_location ('PAY_STATUS_RULES_PKG.PARENT_DELETED',1);
--
<<REMOVE_ORPHANED_ROWS>>
for fetched_rule in csr_rows_owned_by_parent LOOP
	--
	-- If in ZAP mode then all rows belonging to the deleted
	-- parent must be deleted. If in DELETE (ie date-effective
	-- delete) mode then only rows with a future start date
	-- must be deleted, and current rows must be updated so
	-- that their end dates match that of their closed-down
	-- parent. Current and future are determined by session
	-- date.
	--
  if p_delete_mode = 'ZAP' 	-- ie delete all rows
  or (p_delete_mode = 'DELETE' 	-- ie delete all future rows
	and fetched_rule.effective_start_date > p_session_date) then
    --
    hr_utility.set_location ('PAY_STATUS_RULES_PKG.PARENT_DELETED',2);
    --
    delete from pay_status_processing_rules_f
    where current of csr_rows_owned_by_parent;
    --
    hr_utility.set_location ('PAY_STATUS_RULES_PKG.PARENT_DELETED',3);
    --
    delete from hr_application_ownerships
    where key_name = 'STATUS_PROCESSING_RULE_ID'
    and key_value = fetched_rule.status_processing_rule_id;
    --
  elsif p_delete_mode = 'DELETE'
  and p_session_date 	between	fetched_rule.effective_start_date
			and	fetched_rule.effective_end_date then
  --
  hr_utility.set_location ('PAY_STATUS_RULES_PKG.PARENT_DELETED',4);
	--
	update pay_status_processing_rules_f
	set effective_end_date	= p_session_date
	where current of csr_rows_owned_by_parent;
	--
  end if;
  --
  hr_utility.set_location ('PAY_STATUS_RULES_PKG.PARENT_DELETED',5);
  --
  -- Cascade the action to formula result rules for this SPR
  pay_formula_result_rules_pkg.parent_deleted (
    	--
	'PAY_STATUS_PROCESSING_RULES_F',
	fetched_rule.status_processing_rule_id,
	p_session_date,
	p_delete_mode				);
	--
end loop remove_orphaned_rows;
--
end parent_deleted;
--------------------------------------------------------------------------------
function NO_INPUT_VALUES_MATCH_FORMULA (
--
--******************************************************************************
--* Returns TRUE if ANY of the input values for the element do not match the
--* data type of any of the inputs of the selected formula OR if the formula
--* is still uncompiled so that the datatypes cannot be verified.
--* This is used to initiate a warning to the user that his selection may be
--* invalid, but because changes may be made before the processing rule is
--* applied, the selection is not prevented.
--******************************************************************************
--
-- Parameters are:
--
	p_element_type_id	number,
	p_formula_id		number) return boolean is
--
-- Returns a row if the datatypes correctly match between the formula
-- and the element
--
cursor csr_number_of_input_values is
        select  count(iv.element_type_id)
        from    pay_input_values_f_tl IV_TL,
                pay_input_values_f IV
        where   iv_tl.input_value_id = iv.input_value_id
        and     iv.element_type_id = p_element_type_id
        and     userenv('LANG') = iv_tl.language
	and     translate(upper(iv_tl.name),' ','_') in
		(select item_name from ff_fdi_usages_f
		 where formula_id = p_formula_id);

cursor csr_matching_data_types is
	select  count(fdi.formula_id)
	from    pay_input_values_f_tl IV_TL,
                pay_input_values_f IV,
                ff_fdi_usages_f    FDI
	where   iv_tl.input_value_id = iv.input_value_id
        and     fdi.formula_id  =  p_formula_id
        and     userenv('LANG') =  iv_tl.language
        and     fdi.usage in ( 'I', 'B' ) -- either input or in/output item
        and     iv.element_type_id = p_element_type_id
        and     translate (upper(iv_tl.name),' ','_')
				= translate (upper(fdi.item_name),' ','_')
        and     ((fdi.data_type	= 'D' and iv.uom    = 'D')
           	  or (fdi.data_type = 'T' and iv.uom    = 'C')
                  or (fdi.data_type = 'N'
                      and substr(iv.uom,1,1) in ('H','I','M','N')));
--  Cursors rewritten for bug 436741
--		and exists (	-- input value with matching data type
--
--		select 1
--           		from   pay_input_values_f  IV
--           		where  iv.element_type_id = p_element_type_id
--           		and    translate (upper(iv.name),' ','_')
--				= translate (upper(fdi.item_name),' ','_')
--           		and  ((fdi.data_type	= 'D' and iv.uom    = 'D')
--           	     		or (fdi.data_type = 'T' and iv.uom    = 'C')
--               			or (fdi.data_type 	= 'N'
--               		    		and substr(iv.uom,1,1)
--						in('H','I','M','N')))))
--	or	(not exists (	-- a compiled version of the formula
--
--		select 	1
--		from 	ff_fdi_usages compiled
--		where 	compiled.formula_id = p_formula_id)
--		and exists (	-- an uncompiled version of the formula
--
--		select	1
--		from 	ff_formulas_f	formula
--		where	formula.formula_id	= p_formula_id));
--
v_number_to_match       number(2) := 0;
v_number_of_matches     number(2) := 0;
v_match_not_found	boolean := FALSE;
--
begin
--
hr_utility.set_location('PAY_STATUS_RULES_PKG.NO_INPUT_VALUES_MATCH_FORMULA',1);
--
open csr_number_of_input_values;
fetch csr_number_of_input_values into v_number_to_match;
close csr_number_of_input_values;
--
hr_utility.set_location('PAY_STATUS_RULES_PKG.NO_INPUT_VALUES_MATCH_FORMULA',5);
open csr_matching_data_types;
fetch csr_matching_data_types into v_number_of_matches;
close csr_matching_data_types;
--
if v_number_to_match = v_number_of_matches and
   v_number_of_matches <> 0 then
   v_match_not_found := FALSE;
elsif v_number_to_match = 0 then
   v_match_not_found := FALSE;
else
   v_match_not_found := TRUE;
end if;
--
return v_match_not_found;
--
end no_input_values_match_formula;
--------------------------------------------------------------------------------
function DATE_EFFECTIVELY_UPDATED (
--
--******************************************************************************
--* Returns TRUE if the record has more than one date-effective row
--******************************************************************************
--
	p_status_processing_rule_id number,
	p_rowid				varchar2) return boolean is
--
cursor csr_dated_updates is
        select 1
        from pay_status_processing_rules_f
        where status_processing_rule_id = p_status_processing_rule_id
        and rowid <> p_rowid;

date_effective_updates_exist	boolean := FALSE;

begin

hr_utility.set_location ('PAY_STATUS_RULES_PKG.DATE_EFFECTIVELY_UPDATED',1);

open csr_dated_updates;
fetch csr_dated_updates into g_dummy;
date_effective_updates_exist := csr_dated_updates%found;
close csr_dated_updates;

return date_effective_updates_exist;

end date_effectively_updated;
--------------------------------------------------------------------------------
function RESULT_RULES_EXIST (
--******************************************************************************
--* Returns TRUE if the SPR has result rules within the date range specified
--******************************************************************************

	p_status_processing_rule_id	number,
	p_start_date			date,
	p_end_date			date) return boolean is

cursor csr_result_rules is
	select	1
	from 	pay_formula_result_rules_f
	where	status_processing_rule_id = p_status_processing_rule_id
	and	effective_start_date	<= p_end_date
	and	effective_end_date	>= p_start_date;

rules_exist	boolean := FALSE;

begin

open csr_result_rules;
fetch csr_result_rules into g_dummy;
rules_exist := csr_result_rules%found;
close csr_result_rules;

return rules_exist;

end result_rules_exist;
------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- pay_status_rules_pkg.status_rule_end_date                                --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Returns the correct end date for a status rule. It takes into account    --
 -- the end date of the formula and also any future status rules             --
 ------------------------------------------------------------------------------
--
 function status_rule_end_date
 (
  p_status_processing_rule_id    number,
  p_element_type_id              number,
  p_formula_id                   number,
  p_assignment_status_type_id    number,
  p_processing_rule              varchar2,
  p_session_date                 date,
  p_max_element_end_date         date,
  p_validation_start_date        date,
  p_business_group_id            number,
  p_legislation_code             varchar2
  ) return date is
--
  v_next_status_rule_start_date date;
  v_max_formula_end_date        date;
  v_status_rule_end_date        date;
--
 begin
--
  -- Get the start date of the earliest future status rule if it exists.
  begin
    select min(sprf.effective_start_date)
    into   v_next_status_rule_start_date
    from   pay_status_processing_rules_f sprf
    where  sprf.element_type_id = p_element_type_id
    and    nvl(sprf.assignment_status_type_id,0) = nvl(p_assignment_status_type_id,0)
    and     sprf.processing_rule = p_processing_rule
    and    sprf.effective_end_date >= p_session_date
    and    sprf.status_processing_rule_id <> nvl(p_status_processing_rule_id,0)
    and    (
    --
    --     The row on the database is 'Generic'
    --
           (sprf.business_group_id is null
    and    sprf.legislation_code is null)
    --
    --     The row to be inserted is 'Generic'
    --
    or     (p_business_group_id is null
    and    p_legislation_code is null)
    --
    --     The bg of the row to be inserted conflicts with the bg
    --     of an existing row or an existing legislation row with
    --     the same legislation as the bg of the row being inserted.
    --
    or     (p_business_group_id is not null
    and    (nvl(sprf.business_group_id,-1) = p_business_group_id
    or     nvl(sprf.legislation_code,'~') = p_legislation_code))
    --
    --     The legislation of the row to be inserted conflicts with an
    --     existing legislative row or with the legislation of an existing
    --     bg specific row.
    --
    or     (p_business_group_id is null
    and    p_legislation_code is not null
    and    (p_legislation_code = nvl(sprf.legislation_code,'~')
    or     p_legislation_code = (select legislation_code
                                 from   per_business_groups
                                 where  business_group_id = nvl(sprf.business_group_id,-1))))
           );
  exception
    when no_data_found then
      null;
  end;
--
  -- If there are no future status rules , get the max end date of the
  -- formula.
  if v_next_status_rule_start_date is null then
    begin
      select max(ff.effective_end_date)
      into   v_max_formula_end_date
      from   ff_formulas_f   ff
      where  ff.formula_id = p_formula_id;
    exception
      when no_data_found then
        null;
    end;
      if v_max_formula_end_date is not null and
      v_max_formula_end_date <= p_max_element_end_date then
        v_status_rule_end_date := v_max_formula_end_date;
      else
        v_status_rule_end_date := p_max_element_end_date;
      end if;
  else
    v_status_rule_end_date := v_next_status_rule_start_date - 1;
  end if;
--
  -- Trying to open up a status rule that would either overlap with an existing
  -- status rule or extend beyond the lifetime of the formula or element type.
  if v_status_rule_end_date < p_validation_start_date then
    if v_next_status_rule_start_date is null and
    v_max_formula_end_date is null then
    --- Trying to extend beyond life of element
      hr_utility.set_message(801, 'HR_34858_RULE_PAST_ELEMENT');
    elsif v_next_status_rule_start_date is null and
    v_max_formula_end_date <= p_max_element_end_date then
    -- Trying to extend beyond life of the formula
      hr_utility.set_message(801, 'HR_34857_RULE_PAST_FORMULA');
    else
    -- Trying to extend beyond life of status rule causing overlap
      hr_utility.set_message(801, 'HR_34856_STATUS_RULE_FUT_EXIST');
    end if;
    hr_utility.raise_error;
  end if;
--
  return v_status_rule_end_date;
--
 end status_rule_end_date;
--------------------------------------------------------------------------------
end PAY_STATUS_RULES_PKG;

/
