--------------------------------------------------------
--  DDL for Package Body PAY_LINK_INPUT_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_LINK_INPUT_VALUES_PKG" as
/* $Header: pyliv.pkb 120.0 2005/05/29 01:50:44 appldev noship $ */
--------------------------------------------------------------------------------
g_dummy	number (1);
g_package constant varchar2 (72) := 'PAY_LINK_INPUT_VALUES_PKG';
--------------------------------------------------------------------------------
PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
BEGIN
  DELETE FROM PAY_LINK_INPUT_VALUES_F
  WHERE  rowid = X_Rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;
END Delete_Row;
--------------------------------------------------------------------------------
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,

                   X_Link_Input_Value_Id                   NUMBER,
                   X_Effective_Start_Date                  DATE,
                   X_Effective_End_Date                    DATE,
                   X_Element_Link_Id                       NUMBER,
                   X_Input_Value_Id                        NUMBER,
                   X_Costed_Flag                           VARCHAR2,
                   X_Default_Value                         VARCHAR2,
                   X_Max_Value                             VARCHAR2,
                   X_Min_Value                             VARCHAR2,
                   X_Warning_Or_Error                      VARCHAR2) IS
  CURSOR C IS
      SELECT *
      FROM   PAY_LINK_INPUT_VALUES_F
      WHERE  rowid = X_Rowid
      FOR UPDATE of Link_Input_Value_Id NOWAIT;
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
          (   (Recinfo.link_input_value_id = X_Link_Input_Value_Id)
           OR (    (Recinfo.link_input_value_id IS NULL)
               AND (X_Link_Input_Value_Id IS NULL)))
      AND (   (Recinfo.effective_start_date = X_Effective_Start_Date)
           OR (    (Recinfo.effective_start_date IS NULL)
               AND (X_Effective_Start_Date IS NULL)))
      AND (   (Recinfo.effective_end_date = X_Effective_End_Date)
           OR (    (Recinfo.effective_end_date IS NULL)
               AND (X_Effective_End_Date IS NULL)))
      AND (   (Recinfo.element_link_id = X_Element_Link_Id)
           OR (    (Recinfo.element_link_id IS NULL)
               AND (X_Element_Link_Id IS NULL)))
      AND (   (Recinfo.input_value_id = X_Input_Value_Id)
           OR (    (Recinfo.input_value_id IS NULL)
               AND (X_Input_Value_Id IS NULL)))
      AND (   (Recinfo.costed_flag = X_Costed_Flag)
           OR (    (Recinfo.costed_flag IS NULL)
               AND (X_Costed_Flag IS NULL)))
      AND (   (Recinfo.default_value = X_Default_Value)
           OR (    (Recinfo.default_value IS NULL)
               AND (X_Default_Value IS NULL)))
      AND (   (Recinfo.max_value = X_Max_Value)
           OR (    (Recinfo.max_value IS NULL)
               AND (X_Max_Value IS NULL)))
      AND (   (Recinfo.min_value = X_Min_Value)
           OR (    (Recinfo.min_value IS NULL)
               AND (X_Min_Value IS NULL)))
      AND (   (Recinfo.warning_or_error = X_Warning_Or_Error)
           OR (    (Recinfo.warning_or_error IS NULL)
               AND (X_Warning_Or_Error IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;
--------------------------------------------------------------------------------
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Link_Input_Value_Id                 NUMBER,
                     X_Effective_Start_Date                DATE,
                     X_Effective_End_Date                  DATE,
                     X_Element_Link_Id                     NUMBER,
                     X_Input_Value_Id                      NUMBER,
                     X_Costed_Flag                         VARCHAR2,
                     X_Default_Value                       VARCHAR2,
                     X_Max_Value                           VARCHAR2,
                     X_Min_Value                           VARCHAR2,
                     X_Warning_Or_Error                    VARCHAR2) IS
BEGIN
  UPDATE PAY_LINK_INPUT_VALUES_F
  SET

    link_input_value_id                       =    X_Link_Input_Value_Id,
    effective_start_date                      =    X_Effective_Start_Date,
    effective_end_date                        =    X_Effective_End_Date,
    element_link_id                           =    X_Element_Link_Id,
    input_value_id                            =    X_Input_Value_Id,
    costed_flag                               =    X_Costed_Flag,
    default_value                             =    X_Default_Value,
    max_value                                 =    X_Max_Value,
    min_value                                 =    X_Min_Value,
    warning_or_error                          =    X_Warning_Or_Error
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;
--------------------------------------------------------------------------------
procedure CREATE_LINK_INPUT_VALUE(
--
--******************************************************************************
--* Creates link input values for a new link.
--******************************************************************************
--
	p_element_link_id       number,
	p_costable_type	   	varchar2,
	p_effective_start_date 	date,
	p_effective_end_date   	date,
	p_element_type_id       number) is
--
l_proc constant varchar2 (72) := g_package||'create_link_input_value';
--
v_link_input_value_id   number;
v_input_value_id        number := null;
v_default_value		varchar2(255);
v_min_value		varchar2(255);
v_max_value		varchar2(255);
v_warning_or_error	varchar2(1);
v_costed_flag		varchar2(1);
v_effective_start_date	date;
v_effective_end_date	date;
l_link_is_costable	boolean := (p_costable_type in ('F', 'C', 'D'));
--
-- This selects all input values for an element type
--
cursor csr_input_value is
	select	*
	from	pay_input_values_f
	where	element_type_id	 = p_element_type_id
	and	effective_start_date	<= p_effective_end_date
	and	effective_end_date	>= p_effective_start_date
    order by input_value_id,effective_start_date;
--
procedure check_parameters is
	--
	begin
	--
	hr_api.mandatory_arg_error (
		p_api_name      => l_proc,
		p_argument      => 'element_link_id',
		p_argument_value=> p_element_link_id);
	--
	hr_api.mandatory_arg_error (
		p_api_name      => l_proc,
		p_argument      => 'costable_type',
		p_argument_value=> p_costable_type);
	--
	hr_api.mandatory_arg_error (
		p_api_name      => l_proc,
		p_argument      => 'effective_start_date',
		p_argument_value=> p_effective_start_date);
	--
	hr_api.mandatory_arg_error (
		p_api_name      => l_proc,
		p_argument      => 'effective_end_date',
		p_argument_value=> p_effective_end_date);
	--
	hr_api.mandatory_arg_error (
		p_api_name      => l_proc,
		p_argument      => 'element_type_id',
		p_argument_value=> p_element_type_id);
	--
	end check_parameters;
	--
begin
--
hr_utility.set_location(l_proc,1);
--
check_parameters;
--
for fetched_input_value in csr_input_value LOOP
  --
  -- Default the costed flag
  -- AR MLS Change - added hard coded PAY VALUE
  -- because the base table now contains the
  -- system names of input values.  Therefore, we can
  -- guarantee that the input value name
  -- is pay value in the base table.
  --
  if upper(fetched_input_value.name) = 'PAY VALUE'
  and l_link_is_costable
  then
    v_costed_flag := 'Y' ;
  else
    v_costed_flag := 'N';
  end if;
  --
  -- Set up hot or cold defaults
  --
  if fetched_input_value.hot_default_flag = 'Y' then -- hot defaults
    --
    v_default_value := null;
    v_min_value := null;
    v_max_value := null;
    v_warning_or_error := null;
    --
  else -- cold defaults
    --
    v_default_value := fetched_input_value.default_value;
    v_min_value := fetched_input_value.min_value;
    v_max_value := fetched_input_value.max_value;
    v_warning_or_error :=  fetched_input_value.warning_or_error;
    --
  end if;
  --
  -- Set the new link input value's effective dates to be constrained within
  -- the overlap in existence between the element link and the date effective
  -- row for the input value.
  --
  v_effective_start_date := greatest (p_effective_start_date,
    				fetched_input_value.effective_start_date);
  v_effective_end_date := least (p_effective_end_date,
				fetched_input_value.effective_end_date);
  --
  hr_utility.set_location (l_proc, 10);
  --
  -- Only increment the link input value if the input value is different.
  if (v_input_value_id is null or v_input_value_id <> fetched_input_value.input_value_id) then
     select pay_link_input_values_s.nextval
       into v_link_input_value_id
       from sys.dual;
     --
     v_input_value_id := fetched_input_value.input_value_id;
  end if;
  --
  insert into pay_link_input_values_f
	(link_input_value_id,
	effective_start_date,
	effective_end_date,
	element_link_id,
	input_value_id,
	costed_flag,
	default_value,
	max_value,
	min_value,
	warning_or_error,
	creation_date)
  values (
	v_link_input_value_id,
	v_effective_start_date,
	v_effective_end_date,
	p_element_link_id,
	fetched_input_value.input_value_id,
	v_costed_flag,
	v_default_value,
	v_max_value,
	v_min_value,
	v_warning_or_error,
	sysdate);
  --
end loop;
--
end create_link_input_value;
--------------------------------------------------------------------------------
procedure CREATE_LINK_INPUT_VALUE (
--
--******************************************************************************
--* Creates link input values for existing links when a new input value is     *
--* created at the type level.						       *
--******************************************************************************
--
	p_input_value_id	number,
	p_element_type_id	number,
	p_effective_start_date	date,
	p_effective_end_date	date,
	p_name			varchar2,
	p_hot_default_flag	varchar2,
	p_default_value		varchar2,
	p_min_value		varchar2,
	p_max_value		varchar2,
	p_warning_or_error	varchar2) is
--
cursor csr_links is
	select	*
	from	pay_element_links_f
	where	element_type_id		=  p_element_type_id
	and	effective_start_date	<= p_effective_end_date
	and	effective_end_date	>= p_effective_start_date
    order by element_link_id,effective_start_date;
--
v_link_input_value_id	number;
v_link_id               number := null;
v_costed_flag		varchar2(1);
v_min_value		varchar2(255);
v_max_value		varchar2(255);
v_default_value		varchar2(255);
v_warning_or_error	varchar2(1);
--
begin
--
for fetched_link in csr_links LOOP
--
-- Set up default costed flag
--
if fetched_link.costable_type in ('F', 'C', 'D')
and p_name = hr_general.pay_value then
  v_costed_flag := 'Y';
else
  v_costed_flag := 'N';
end if;
--
-- Set up hot or cold defaults
--
if p_hot_default_flag = 'Y' then
  v_min_value := null;
  v_max_value := null;
  v_default_value := null;
  v_warning_or_error := null;
else
  v_min_value := p_min_value;
  v_max_value := p_max_value;
  v_default_value := p_default_value;
  v_warning_or_error := p_warning_or_error;
end if;
--
     -- Only increment the link id is different.
     if (v_link_id is null or v_link_id <> fetched_link.element_link_id) then
        select pay_link_input_values_s.nextval
          into v_link_input_value_id
          from sys.dual;
        --
        v_link_id := fetched_link.element_link_id;
     end if;
     --
     insert into pay_link_input_values_f
     (link_input_value_id,
      effective_start_date,
      effective_end_date,
      element_link_id,
      input_value_id,
      costed_flag,
      default_value,
      max_value,
      min_value,
      warning_or_error,
      creation_date)
    values(
     	v_link_input_value_id,
      	greatest(fetched_link.effective_start_date,p_effective_start_date),
      	least(fetched_link.effective_end_date,p_effective_end_date),
      	fetched_link.element_link_id,
      	p_input_value_id,
	v_costed_flag,
	v_default_value,
	v_max_value,
	v_min_value,
	v_warning_or_error,
      	sysdate);
--
end loop;
--
end create_link_input_value;
--------------------------------------------------------------------------------
procedure CHECK_REQUIRED_DEFAULTS (
--
--*****************************************************************************
--* Checks that all required default values are present
--*****************************************************************************
--
p_element_link_id	number,
p_session_date		date) is
--
cursor csr_defaults is
	select	1
	from	pay_input_values_f	TYPE,
		pay_link_input_values_f	LINK
	where	p_session_date between type.effective_start_date
				and type.effective_end_date
	and	p_session_date between link.effective_start_date
				and link.effective_end_date
	and	type.input_value_id = link.input_value_id
	and	link.element_link_id = p_element_link_id
	and	type.mandatory_flag = 'Y'
	and	((type.hot_default_flag = 'N'
			and link.default_value is null)
		or (type.hot_default_flag = 'Y'
			and nvl (link.default_value,
				type.default_value) is null));
	--
Missing_required_default	boolean := FALSE;
--
begin
--
hr_utility.set_location ('PAY_LINK_INPUT_VALUES_PKG.CHECK_REQUIRED_DEFAULTS',1);
--
open csr_defaults;
fetch csr_defaults into g_dummy;
Missing_required_default := csr_defaults%found;
close csr_defaults;
--
if missing_required_default then
  hr_utility.set_message (801, 'PAY_6219_INPVAL_NO_STAN_LINK');
  hr_utility.raise_error;
end if;
--
end check_required_defaults;
--------------------------------------------------------------------------------
function NO_DEFAULT_AT_TYPE (
--
--******************************************************************************
--* Returns TRUE if there is no default value specified at the element type    *
--******************************************************************************
--
-- Parameters are:
--
	p_input_value_id	number,
	p_effective_start_date	date,
	p_effective_end_date	date,
	p_error_if_true		boolean default FALSE	) return boolean is
--
cursor csr_link is
	select	1
	from	pay_input_values_f
	where	input_value_id		= p_input_value_id
	and	effective_start_date	<=p_effective_end_date
	and	effective_end_date	>=p_effective_start_date
	and	default_value is null;
--
v_dummy		number(1);
v_no_default	boolean := FALSE;
--
begin
open csr_link;
fetch csr_link into v_dummy;
v_no_default := csr_link%found;
close csr_link;
--
if p_error_if_true and v_no_default then
  hr_utility.set_message (801, 'PAY_INPVAL_MUST_HAVE_DEFAULT');
  hr_utility.raise_error;
end if;
--
return v_no_default;
--
end no_default_at_type;
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
p_delete_mode		varchar2,
p_parent_name		varchar2 -- The name of the parent entity
) is
--
-- The following cursor fetches all rows identified by the foreign key to
-- the parent being deleted. The parent name identifies foreign key column
-- to use, thus the procedure is generic to any parent deletion
--
cursor csr_rows_owned_by_parent is
	select	rowid,pay_link_input_values_f.*
	from	pay_link_input_values_f
	where	p_parent_id	= decode (p_parent_name,
				'PAY_INPUT_VALUES_F',input_value_id,
				'PAY_ELEMENT_LINKS_F',element_link_id)
	for update;
--
c_end_of_time	constant date := to_date('31/12/4712','DD/MM/YYYY');
--
begin
hr_utility.set_location ('pay_link_input_values_pkg.parent_deleted',1);
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
  if p_delete_mode = 'ZAP' 	-- ie delete all rows
  or (p_delete_mode = 'DELETE' 	-- ie delete all future rows
	and fetched_row.effective_start_date > p_session_date) then
--
	delete from pay_link_input_values_f
	where current of csr_rows_owned_by_parent;
--
  elsif p_delete_mode = 'DELETE'
  and p_session_date 	between	fetched_row.effective_start_date
			and	fetched_row.effective_end_date then
--
	update pay_link_input_values_f
	set effective_end_date	= p_session_date
	where current of csr_rows_owned_by_parent;
--
  -- For delete next changes when there are no future rows for the parent,
  -- extend the input value's end date to the end of time to match the action
  -- which will be performed on the parent
--
  elsif p_delete_mode = 'DELETE_NEXT_CHANGE'
  and p_validation_end_date = c_end_of_time then
--
    update pay_link_input_values_f
    set effective_end_date = c_end_of_time
    where current of csr_rows_owned_by_parent;
--
  end if;
--
end loop remove_orphaned_rows;
--
end parent_deleted;
--------------------------------------------------------------------------------
function LINK_END_DATE (p_link_id number) return date is
--
--******************************************************************************
--* Returns the end date of the Link.
--******************************************************************************
v_link_end_date	date;
--
cursor csr_link is
	select max(effective_end_date)
	from	pay_element_links_f
	where	element_link_id	= p_link_id;
--
begin
open csr_link;
fetch csr_link into v_link_end_date;
close csr_link;
return v_link_end_date;
end link_end_date;
--------------------------------------------------------------------------------
end PAY_LINK_INPUT_VALUES_PKG;

/
