--------------------------------------------------------
--  DDL for Package Body PAY_SUB_CLASS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SUB_CLASS_RULES_PKG" as
/* $Header: pysbr.pkb 120.0 2005/05/29 01:50:52 appldev noship $ */
--
-- Declare global variables and cursors
--
-- Dummy variable for selecting into when not interested in the value returned
g_dummy	number(1);
c_user_id	number;
c_login_id	number;
--------------------------------------------------------------------------------
-- Start of auto-generated code
--------------------------------------------------------------------------------
PROCEDURE Insert_Row(p_Rowid                        IN OUT NOCOPY VARCHAR2,
                     p_Sub_Classification_Rule_Id   IN OUT NOCOPY NUMBER,
                     p_Effective_Start_Date                DATE,
                     p_Effective_End_Date                  DATE,
                     p_Element_Type_Id                     NUMBER,
                     p_Classification_Id                   NUMBER,
                     p_Business_Group_Id                   NUMBER,
                     p_Legislation_Code                    VARCHAR2,
                     p_Last_Update_Date                    DATE,
                     p_Last_Updated_By                     NUMBER,
                     p_Last_Update_Login                   NUMBER,
                     p_Created_By                          NUMBER,
                     p_Creation_Date                       DATE) IS

cursor csr_new_rowid is
	select	rowid
	from	pay_sub_classification_rules_f
	where	sub_classification_rule_id	= p_sub_classification_rule_id
	and	effective_start_date		= p_effective_start_date;



cursor csr_next_id is
	select pay_sub_classification_rules_s.nextval
	from sys.dual;
BEGIN

hr_utility.set_location ('PAY_SUB_CLASS_RULES_PKG.INSERT_ROW',1);

   if p_sub_classification_rule_id is null then
     open csr_next_id;
     fetch csr_next_id into p_sub_classification_rule_id;
     close csr_next_id;
   end if;

hr_utility.set_location ('PAY_SUB_CLASS_RULES_PKG.INSERT_ROW',2);
  insert into pay_sub_classification_rules_f(

          sub_classification_rule_id,
          effective_start_date,
          effective_end_date,
          element_type_id,
          classification_id,
          business_group_id,
          legislation_code,
          last_update_date,
          last_updated_by,
          last_update_login,
          created_by,
          creation_date
         ) VALUES (
          p_Sub_Classification_Rule_Id,
          p_Effective_Start_Date,
          p_Effective_End_Date,
          p_Element_Type_Id,
          p_Classification_Id,
          p_Business_Group_Id,
          p_Legislation_Code,
          sysdate,
          c_user_id,
          c_login_id,
          c_user_id,
          sysdate

  );
hr_utility.set_location ('PAY_SUB_CLASS_RULES_PKG.INSERT_ROW',3);

  open csr_new_rowid;
  fetch csr_new_rowid into p_rowid;
  if csr_new_rowid%notfound then
	close csr_new_rowid;
	hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
	hr_utility.set_message_token('PROCEDURE','PAY_SUB_CLASS_RULES_PKG.INSERT_ROW');
	hr_utility.set_message_token('STEP','1');
	hr_utility.raise_error;
  end if;
  close csr_new_rowid;
--
  -- Create application ownership for startup data
  if p_legislation_code is not null then
    --
    -- The 'not exists' clause is used to ensure that duplicate rows are not
    -- entered. This could arise because the forms startup code also handles
    -- application ownerships where a user enters a value on the form, but
    -- this code is intended to handle third party insertion from the element
    --
hr_utility.set_location ('PAY_SUB_CLASS_RULES_PKG.INSERT_ROW',4);
    insert into hr_application_ownerships
        (key_name,
         key_value,
         product_name)
        select  'SUB_CLASSIFICATION_RULE_ID',
                p_sub_classification_rule_id,
                ao.product_name
        from    hr_application_ownerships ao
        where   ao.key_name = 'ELEMENT_TYPE_ID'
        and     ao.key_value = p_element_type_id
	and not exists (select  'SUB_CLASSIFICATION_RULE_ID',
        	        	p_sub_classification_rule_id,
        	        	ao.product_name
        		from    hr_application_ownerships ao
        		where   ao.key_name = 'ELEMENT_TYPE_ID'
        		and     ao.key_value = p_element_type_id);
  --
  end if;
  --
hr_utility.set_location ('PAY_SUB_CLASS_RULES_PKG.INSERT_ROW',5);
  hr_balance_feeds.ins_bf_sub_class_rule (p_Sub_Classification_Rule_Id);

end insert_row;





procedure LOCK_ROW(

		p_rowid                                 VARCHAR2,
                p_Sub_Classification_Rule_Id            NUMBER,
                p_Effective_Start_Date                  DATE,
                p_Effective_End_Date                    DATE,
                p_Element_Type_Id                       NUMBER,
                p_Classification_Id                     NUMBER,
                p_Business_Group_Id                     NUMBER,
                p_Legislation_Code                      VARCHAR2) IS

cursor csr_existing_row is
      select *
      from   pay_sub_classification_rules_f
      where  rowid = p_rowid
      for update of sub_classification_rule_id NOWAIT;

  fetched_record csr_existing_row%rowtype;

begin
  open csr_existing_row;
  fetch csr_existing_row into fetched_record;
  if csr_existing_row%notfound then
    close csr_existing_row;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_SUB_CLASS_RULES_PKG.LOCK_ROW');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;
  close csr_existing_row;
  if (
          (   (fetched_record.sub_classification_rule_id = p_Sub_Classification_Rule_Id)
           OR (    (fetched_record.sub_classification_rule_id IS NULL)
               AND (p_Sub_Classification_Rule_Id IS NULL)))
      AND (   (fetched_record.effective_start_date = p_Effective_Start_Date)
           OR (    (fetched_record.effective_start_date IS NULL)
               AND (p_Effective_Start_Date IS NULL)))
      AND (   (fetched_record.effective_end_date = p_Effective_End_Date)
           OR (    (fetched_record.effective_end_date IS NULL)
               AND (p_Effective_End_Date IS NULL)))
      AND (   (fetched_record.element_type_id = p_Element_Type_Id)
           OR (    (fetched_record.element_type_id IS NULL)
               AND (p_Element_Type_Id IS NULL)))
      AND (   (fetched_record.classification_id = p_Classification_Id)
           OR (    (fetched_record.classification_id IS NULL)
               AND (p_Classification_Id IS NULL)))
      AND (   (fetched_record.business_group_id = p_Business_Group_Id)
           OR (    (fetched_record.business_group_id IS NULL)
               AND (p_Business_Group_Id IS NULL)))
      AND (   (fetched_record.legislation_code = p_Legislation_Code)
           OR (    (fetched_record.legislation_code IS NULL)
               AND (p_Legislation_Code IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
end Lock_Row;

PROCEDURE Update_Row(p_Rowid                               VARCHAR2,
                     p_Sub_Classification_Rule_Id          NUMBER,
                     p_Effective_Start_Date                DATE,
                     p_Effective_End_Date                  DATE,
                     p_Element_Type_Id                     NUMBER,
                     p_Classification_Id                   NUMBER,
                     p_Business_Group_Id                   NUMBER,
                     p_Legislation_Code                    VARCHAR2,
                     p_Last_Update_Date                    DATE,
                     p_Last_Updated_By                     NUMBER,
                     p_Last_Update_Login                   NUMBER) IS
BEGIN
  UPDATE pay_sub_classification_rules_f
  SET

    sub_classification_rule_id                =    p_Sub_Classification_Rule_Id,
    effective_start_date                      =    p_Effective_Start_Date,
    effective_end_date                        =    p_Effective_End_Date,
    element_type_id                           =    p_Element_Type_Id,
    classification_id                         =    p_Classification_Id,
    business_group_id                         =    p_Business_Group_Id,
    legislation_code                          =    p_Legislation_Code,
    last_update_date                          =    sysdate,
    last_updated_by                           =    c_user_id,
    last_update_login                         =    c_login_id
  WHERE rowid = p_rowid;

  if (SQL%NOTFOUND) then
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','PAY_SUB_CLASS_RULES_PKG.UPDATE_ROW');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end if;

END Update_Row;
--------------------------------------------------------------------------------
-- End of Auto-generated code
--------------------------------------------------------------------------------
procedure INSERT_DEFAULTS (
--
--******************************************************************************
--* Inserts a row into the base table for each default sub-classification      *
--* belonging to the primary classification of a newly inserted element type   *
--******************************************************************************
--
-- Parameters are:
--
p_element_type_id       number,
p_classification_id     number,
p_effective_start_date  date,
p_effective_end_date    date,
p_business_group_id     number,
p_legislation_code      varchar2        ) is
--
cursor csr_legislation_code is
	select 	legislation_code
	from	per_business_groups_perf
	where	business_group_id = p_business_group_id;
--
dummy_rowid		varchar2(18) default null;
dummy_id		number(38) default null;
--
cursor csr_next_default is
        select  classification_id
	from    pay_element_classifications
	where   parent_classification_id = p_classification_id
	and     create_by_default_flag = 'Y'
	and     (p_business_group_id = business_group_id + 0
        	or (business_group_id is null
		and (legislation_code =
		     nvl(hr_api.return_legislation_code(p_business_group_id)
		        ,p_legislation_code))
                ));
--
begin
--
hr_utility.set_location ('pay_sub_class_rules_pkg.insert_defaults',1);
--
for default_insertion in csr_next_default LOOP
--
  insert_row (
	dummy_rowid,
	dummy_id,
	p_effective_start_date,
	p_effective_end_date,
	p_element_type_id,
	default_insertion.classification_id,
	p_business_group_id,
	p_legislation_code,
	null,null,null,null,null);
--
dummy_rowid := null;
dummy_id := null;
--
end loop;
--
end insert_defaults;
--------------------------------------------------------------------------------
function MAX_ALLOWABLE_END_DATE (
--
--******************************************************************************
--* Returns date of the last allowable end date which may be used for a row    *
--* in order to maintain its uniqueness within time.			       *
--******************************************************************************
--
-- Parameters to be passed in are:
--
p_element_type_id	number,
p_classification_id	number,
p_session_date		date,
p_error_if_true		boolean	default FALSE	)
--
return date is
--
v_end_date	date;
--
cursor csr_end_date is
	select	min(effective_start_date) -1
	from	pay_sub_classification_rules_f
	where	element_type_id		= p_element_type_id
	and	classification_id	= p_classification_id
	and	effective_end_date	> p_session_date;
--
begin
hr_utility.set_location ('pay_sub_class_rules_pkg.allowable_end_date',1);
--
open csr_end_date;
fetch csr_end_date into v_end_date;
close csr_end_date;
--
hr_utility.trace ('End Date = '||v_end_date);
--
-- Return an error if the maximum allowable end date is prior to session date
if p_error_if_true and v_end_date <= p_session_date then
  hr_utility.set_message (801,'HR_7128_SUB_CLASS_OVERLAPS');
  hr_utility.raise_error;
end if;
--
return v_end_date;
--
end max_allowable_end_date;
--------------------------------------------------------------------------------
function NEXT_RULE_ID return number is
--
--******************************************************************************
--* Retrieves next sequence number for rule id.
--******************************************************************************
--
cursor csr_new_row is
	select	pay_sub_classification_rules_s.nextval
	from	sys.dual;
--
v_next_id	number(30);
--
begin
open csr_new_row;
fetch csr_new_row into v_next_id;
close csr_new_row;
return v_next_id;
--
end next_rule_id;
--------------------------------------------------------------------------------
procedure MAINTAIN_DELETION_INTEGRITY (
--
--******************************************************************************
--* Ensures that no children of a deleted row are orphaned.
--******************************************************************************
--
-- Parameters are:
--
p_sub_classification_rule_id    number,
p_delete_mode                   varchar2,
p_validation_start_date         date,
p_validation_end_date           date            ) is
--
begin
--
hr_utility.set_location ('pay_sub_class_rules_pkg.MAINTAIN_DELETION_INTEGRITY',1);
--
-- Delete balance feeds for this sub classification rule
hr_balance_feeds.del_bf_sub_class_rule (
--
	p_sub_classification_rule_id,
	p_delete_mode,
	p_validation_start_date,
	p_validation_end_date		);
--
end MAINTAIN_DELETION_INTEGRITY;
--------------------------------------------------------------------------------
procedure DELETE_ROW (
--
--******************************************************************************
--* Handles deletion from the base table either for forms based on	       *
--* non-updatable view or for implicit deletions caused by action on other     *
--* entities. 								       *
--******************************************************************************
--
-- Parameters to be passed in are:
--
p_rowid				varchar2,
p_sub_classification_rule_id    number,
p_delete_mode                   varchar2,
p_validation_start_date         date,
p_validation_end_date           date		) is
--
begin
--
hr_utility.set_location ('pay_sub_class_rules_pkg.DELETE_ROW',1);
--
pay_sub_class_rules_pkg.maintain_deletion_integrity (
--
	p_sub_classification_rule_id,
	p_delete_mode,
	p_validation_start_date,
	p_validation_end_date		);
--
-- Delete row from base table
--
delete from pay_sub_classification_rules_f
where	rowid	= p_rowid;
--
if sql%notfound then	-- system error trap
  hr_utility.set_message (801,'HR_6153_ALL_PROCEDURE_FAIL');
  hr_utility.set_message_token('PROCEDURE',
					'PAY_SUB_CLASS_RULES_PKG.DELETE_ROW');
  hr_utility.set_message_token('STEP','2');
  hr_utility.raise_error;
end if;
--
delete from hr_application_ownerships
where key_name = 'SUB_CLASSIFICATION_RULE_ID'
and key_value = p_sub_classification_rule_id;
--
end delete_row;
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
p_parent_id		number,-- The foreign key for the deleted parent
p_session_date		date		default trunc (sysdate),
p_validation_start_date	date,
p_validation_end_date	date,
p_delete_mode		varchar2	default 'DELETE',
p_parent_name		varchar2 -- The name of the parent entity
) is
--
-- The following cursor fetches all rows identified by the foreign key to
-- the parent being deleted. The parent name identifies foreign key column
-- to use, thus the procedure is generic to any parent deletion
--
cursor csr_rows_owned_by_parent is
	select	rowid,pay_sub_classification_rules_f.*
	from	pay_sub_classification_rules_f
	where	p_parent_id	= decode (p_parent_name,
					'PAY_ELEMENT_TYPES_F',element_type_id,
					classification_id)
	for update;
--
begin
hr_utility.set_location ('pay_sub_class_rules_pkg.parent_deleted',1);
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
    delete_row(	fetched_rule.rowid,
		fetched_rule.sub_classification_rule_id,
		p_delete_mode,
		p_validation_start_date,
		p_validation_end_date			);
--
  elsif p_delete_mode = 'DELETE'
  and p_session_date 	between	fetched_rule.effective_start_date
			and	fetched_rule.effective_end_date then
--
	update pay_sub_classification_rules_f
	set effective_end_date	= p_session_date
	where current of csr_rows_owned_by_parent;
--
   -- Fix for bug 3660866.
   -- If parent is deleted in DELETE_NEXT_CHANGE or FUTURE_CHANGE mode
   -- then all child rows (Secondary balance classification) should
   -- also be updated as per same.
  elsif (p_delete_mode in ('DELETE_NEXT_CHANGE','FUTURE_CHANGE')) then
    update pay_sub_classification_rules_f
	set effective_end_date	= p_validation_end_date
	where current of csr_rows_owned_by_parent;
--
  end if;
--
end loop remove_orphaned_rows;
--
end parent_deleted;
--------------------------------------------------------------------------------
begin
--
c_user_id	:= fnd_global.user_id;
c_login_id	:= fnd_global.login_id;
--
end PAY_SUB_CLASS_RULES_PKG;

/
