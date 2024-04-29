--------------------------------------------------------
--  DDL for Package Body FF_LOAD_CONTEXTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_LOAD_CONTEXTS_PKG" as
/* $Header: ffconapi.pkb 120.1 2005/09/23 10:37 arashid noship $ */
-- ----------------------------------------------------------------------------
-- |                     Data Structure Definitions                           |
-- ----------------------------------------------------------------------------
type r_context is record
(context_name ff_contexts.context_name%type
,data_type    ff_contexts.data_type%type
);

type t_contexts is table of r_context index by binary_integer;
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ff_load_ftypes_pkg.';  -- Global package name
g_permitted_list t_contexts;
g_list_not_built boolean := true;
--
--
-- ----------------------------------------------------------------------------
-- |                     Private Procedures                                    |
-- ----------------------------------------------------------------------------
-- Called from load row and will insert new rows into ff_formula_types table
Procedure insert_contexts(
               p_context_name    in ff_contexts.context_name%TYPE
               ,p_context_level   in ff_contexts.context_level%TYPE
               ,p_data_type       in ff_contexts.data_type%TYPE);

--
-- Build the list of permitted contexts.
--
Procedure build_permitted_list is
i binary_integer := 1;
begin
  g_permitted_list(i).context_name := 'ACCRUAL_PLAN_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'ACT_TYP_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'ASSIGNMENT_ACTION_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'ASSIGNMENT_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'BALANCE_DATE';
  g_permitted_list(i).data_type := 'D';
  i := i + 1;

  g_permitted_list(i).context_name := 'BUSINESS_GROUP_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'COMM_TYP_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'DATE_EARNED';
  g_permitted_list(i).data_type := 'D';
  i := i + 1;

  g_permitted_list(i).context_name := 'ELEMENT_ENTRY_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'ELEMENT_TYPE_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'JURISDICTION_CODE';
  g_permitted_list(i).data_type := 'T';
  i := i + 1;

  g_permitted_list(i).context_name := 'LER_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'LOCAL_UNIT_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'OPT_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'ORGANIZATION_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'ORG_PAY_METHOD_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'ORIGINAL_ENTRY_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'PAYROLL_ACTION_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'PAYROLL_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'PERSON_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'PER_PAY_METHOD_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'PGM_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'PL_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'PL_TYP_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'SOURCE_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'SOURCE_NUMBER';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'SOURCE_NUMBER2';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'SOURCE_TEXT';
  g_permitted_list(i).data_type := 'T';
  i := i + 1;

  g_permitted_list(i).context_name := 'SOURCE_TEXT2';
  g_permitted_list(i).data_type := 'T';
  i := i + 1;

  g_permitted_list(i).context_name := 'TAX_GROUP';
  g_permitted_list(i).data_type := 'T';
  i := i + 1;

  g_permitted_list(i).context_name := 'TAX_UNIT_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;

  g_permitted_list(i).context_name := 'TIME_DEFINITION_ID';
  g_permitted_list(i).data_type := 'N';
  i := i + 1;
end build_permitted_list;

-- ----------------------------------------------------------------------------
-- |-------------------------< VALIDATE_NAME >--------------------------------|
-- ----------------------------------------------------------------------------
Procedure validate_name
(p_context_name in varchar2
,p_data_type    in varchar2
) is
begin
  --
  -- Build the permitted list if necessary.
  --
  if g_list_not_built then
    build_permitted_list;
    g_list_not_built := false;
  end if;
  --
  -- Try to match the contexts. Be super strict - insist on uppercase
  -- input.
  --
  for i in 1 .. g_permitted_list.count loop
    if p_context_name =  g_permitted_list(i).context_name and
       p_data_type    = g_permitted_list(i).data_type
    then
      return;
    end if;
  end loop;

  --
  -- The context does not match any in the list.
  --
  hr_utility.set_message(801, 'FF_33290_CONTEXT_NOT_ALLOWED');
  hr_utility.set_message_token('1', p_context_name);
  hr_utility.raise_error;
end validate_name;

-- ----------------------------------------------------------------------------
-- |---------------------------< LOAD_ROW >------------------------------------|
-- ----------------------------------------------------------------------------
Procedure load_row (
             p_context_name    in ff_contexts.context_name%TYPE
            ,p_context_level   in ff_contexts.context_level%TYPE
            ,p_data_type       in ff_contexts.data_type%TYPE) is
  --
  l_existing_con_id      number;
  l_proc   varchar2(100) := g_package || 'load_row';
  --
  --Cursor to see if the existing formula type is updated.....
  cursor csr_existing is
    select  fcon.context_id
      from   ff_contexts fcon
     where  fcon.context_name   = p_context_name;

BEGIN
 --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  open csr_existing;
  fetch csr_existing into l_existing_con_id;

  if csr_existing%FOUND
  then
    close csr_existing;
    --Do nothing, since update of contexts is not allowed
  else
    close csr_existing;
    -- call the insert procedure
    --
    insert_contexts(
                p_context_name   => p_context_name
               ,p_context_level  => p_context_level
               ,p_data_type      => p_data_type);
  end if;
--
-- do not pass back any out parameters from the API calls
--
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
--
end load_row;

--
-- ----------------------------------------------------------------------------
-- |                     Private Procedures                                    |
-- ----------------------------------------------------------------------------
-- Called from load row and will insert new rows into ff_formula_types table
Procedure insert_contexts(
                p_context_name    in ff_contexts.context_name%TYPE
               ,p_context_level   in ff_contexts.context_level%TYPE
               ,p_data_type       in ff_contexts.data_type%TYPE) Is
--
  l_proc   varchar2(100) := g_package || 'insert_contexts';
--
Begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);

--Insert into ff_formula_types table
 Insert Into FF_CONTEXTS(
                     CONTEXT_ID
                    ,CONTEXT_LEVEL
                    ,CONTEXT_NAME
                    ,DATA_TYPE) Values
                   (FF_CONTEXTS_S.NEXTVAL
                   ,p_context_level
                   ,p_context_name
                   ,p_data_type);
--
  hr_utility.set_location('Leaving:'|| l_proc, 10);

End insert_contexts;
--
------------------------------------------------------------------------------------------------
End FF_LOAD_CONTEXTS_PKG;


/
