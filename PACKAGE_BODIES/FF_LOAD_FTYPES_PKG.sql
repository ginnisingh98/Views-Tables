--------------------------------------------------------
--  DDL for Package Body FF_LOAD_FTYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_LOAD_FTYPES_PKG" as
/* $Header: ffftypapi.pkb 115.1 2004/06/29 05:01 sspratur noship $ */
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ff_load_ftypes_pkg.';  -- Global package name
--
--
-- ----------------------------------------------------------------------------
-- |                     Private Procedures                                    |
-- ----------------------------------------------------------------------------
-- Called from load row and will insert new rows into ff_formula_types table
Procedure insert_formula_types(
                p_formula_type_name  in ff_formula_types.formula_type_name%TYPE
               ,p_type_description   in ff_formula_types.type_description%TYPE
               ,p_created_by         in ff_formula_types.CREATED_BY%TYPE
               ,p_creation_date      in ff_formula_types.CREATION_DATE%TYPE
               ,p_last_update_date   in ff_formula_types.LAST_UPDATE_DATE%TYPE
               ,p_last_updated_by    in ff_formula_types.LAST_UPDATED_BY%TYPE
               ,p_last_update_login  in ff_formula_types.LAST_UPDATE_LOGIN%TYPE);

-- Called from load row and will update existing rows in ff_formula_types table
Procedure update_formula_types(
                p_formula_type_name  in ff_formula_types.formula_type_name%TYPE
               ,p_type_description   in ff_formula_types.type_description%TYPE
               ,p_last_update_date   in ff_formula_types.LAST_UPDATE_DATE%TYPE
               ,p_last_updated_by    in ff_formula_types.LAST_UPDATED_BY%TYPE
               ,p_last_update_login  in ff_formula_types.LAST_UPDATE_LOGIN%TYPE);

-- Called from load_row_context_usages and will insert new rows
-- into FF_FTYPE_CONTEXT_USAGES table
Procedure insert_fcontext_usages(
               p_formula_type_name  in FF_FORMULA_TYPES.formula_type_name%TYPE
              ,p_context_name       in FF_CONTEXTS.context_name%TYPE);

-- Called from insert_fcontext_usages and will
-- check if the formula type id is valid one......
Function chk_formula_type_name(p_formula_type_name  in FF_FORMULA_TYPES.formula_type_name%TYPE) Return Number;

-- Called from insert_fcontext_usages and will
-- check if the context is valid one......
Function chk_context_name(p_context_name       in FF_CONTEXTS.context_name%TYPE) Return Number;
-- ----------------------------------------------------------------------------
-- |---------------------------< LOAD_ROW >------------------------------------|
-- ----------------------------------------------------------------------------
Procedure load_row (
   p_formula_type_name   in ff_formula_types.formula_type_name%TYPE
  ,p_type_description    in ff_formula_types.type_description%TYPE
 ) is
  --
  l_existing_form_id      number;
  --WHO variables
  l_sysdate            date := sysdate;
  l_created_by         ff_formula_types.CREATED_BY%TYPE;
  l_creation_date      ff_formula_types.CREATION_DATE%TYPE;
  l_last_updated_by    ff_formula_types.LAST_UPDATED_BY%TYPE;
  l_last_update_login  ff_formula_types.LAST_UPDATE_LOGIN%TYPE;
  l_last_update_date   ff_formula_types.LAST_UPDATE_DATE%TYPE;
  --
  l_proc   varchar2(100) := g_package || 'load_row';
  --
  --Cursor to see if the existing formula type is updated.....
  cursor csr_existing is
    select  fft.formula_type_id
      from   ff_formula_types fft
     where fft.formula_type_name = p_formula_type_name;

BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);
  -- Set the WHO Columns
  l_created_by        := fnd_global.user_id;
  l_creation_date     := l_sysdate;
  l_last_update_date  := l_sysdate;
  l_last_updated_by   := fnd_global.user_id;
  l_last_update_login := fnd_global.login_id;


  open csr_existing;
  fetch csr_existing into l_existing_form_id;
  if csr_existing%FOUND
  then
    close csr_existing;
    update_formula_types(
      p_formula_type_name   => p_formula_type_name
     ,p_type_description    => p_type_description
     ,p_last_update_date    => l_last_update_date
     ,p_last_updated_by     => l_last_updated_by
     ,p_last_update_login   => l_last_update_login);
  else
    close csr_existing;
    -- This is not an update
    -- call the insert procedure
    --
    insert_formula_types(
      p_formula_type_name   => p_formula_type_name
     ,p_type_description    => p_type_description
     ,p_created_by          => l_created_by
     ,p_creation_date       => l_creation_date
     ,p_last_update_date    => l_last_update_date
     ,p_last_updated_by     => l_last_updated_by
     ,p_last_update_login   => l_last_update_login);

  end if;
--
-- do not pass back any out parameters from the API calls
--
  hr_utility.set_location('Leaving:'|| l_proc, 20);
end load_row;

--
-- -------------------------------------------------------------------------------------------
-- |---------------------------< load_row_context_usages >------------------------------------|
-- -------------------------------------------------------------------------------------------
Procedure load_row_context_usages (
               p_formula_type_name  in FF_FORMULA_TYPES.formula_type_name%TYPE
              ,p_context_name       in FF_CONTEXTS.context_name%TYPE)
is
  --
  l_exist_form_con_id      number;
  l_proc   varchar2(100) := g_package || 'load_row_context_usages';

  --Cursor to see if the formula type context usage is existing.....
   Cursor csr_existing IS
    SELECT fcu.FORMULA_TYPE_ID
     FROM FF_FTYPE_CONTEXT_USAGES fcu
         ,FF_FORMULA_TYPES fft
         ,FF_CONTEXTS fco
    WHERE fcu.FORMULA_TYPE_ID = fft.FORMULA_TYPE_ID
      AND fcu.context_id = fco.context_id
      AND fft.FORMULA_TYPE_NAME = p_formula_type_name
      AND fco.context_name = p_context_name;

BEGIN
--
    hr_utility.set_location('Entering:'|| l_proc, 10);

  open csr_existing;
  fetch csr_existing into l_exist_form_con_id;
  if csr_existing%NOTFOUND
  then
    close csr_existing;
    -- call the insert procedure
    --
    insert_fcontext_usages(
         p_formula_type_name     => p_formula_type_name
        ,p_context_name          => p_context_name);

  end if;
--
-- do not pass back any out parameters from the API calls
--
  hr_utility.set_location('Leaving:'|| l_proc, 20);

end load_row_context_usages;

--
-- ----------------------------------------------------------------------------
-- |                     Private Procedures                                    |
-- ----------------------------------------------------------------------------
-- Called from load row and will insert new rows into ff_formula_types table
Procedure insert_formula_types(
                p_formula_type_name  in ff_formula_types.formula_type_name%TYPE
               ,p_type_description   in ff_formula_types.type_description%TYPE
               ,p_created_by         in ff_formula_types.CREATED_BY%TYPE
               ,p_creation_date      in ff_formula_types.CREATION_DATE%TYPE
               ,p_last_update_date   in ff_formula_types.LAST_UPDATE_DATE%TYPE
               ,p_last_updated_by    in ff_formula_types.LAST_UPDATED_BY%TYPE
               ,p_last_update_login  in ff_formula_types.LAST_UPDATE_LOGIN%TYPE) Is
  l_proc   varchar2(100) := g_package || 'insert_formula_types';
Begin

--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--Insert into ff_formula_types table
 Insert Into FF_FORMULA_TYPES(
                    FORMULA_TYPE_ID
                   ,FORMULA_TYPE_NAME
                   ,TYPE_DESCRIPTION
                   ,LAST_UPDATE_DATE
                   ,LAST_UPDATED_BY
                   ,LAST_UPDATE_LOGIN
                   ,CREATED_BY
                   ,CREATION_DATE) Values
                   (FF_FORMULA_TYPES_S.NEXTVAL
                   ,p_formula_type_name
                   ,p_type_description
                   ,p_last_update_date
                   ,p_last_updated_by
                   ,p_last_update_login
                   ,p_created_by
                   ,p_creation_date);
--
  hr_utility.set_location('Leaving:'|| l_proc, 20);
End insert_formula_types;
--
-- Called from load row and will update existing rows in ff_formula_types table
Procedure update_formula_types(
                p_formula_type_name  in ff_formula_types.formula_type_name%TYPE
               ,p_type_description   in ff_formula_types.type_description%TYPE
               ,p_last_update_date   in ff_formula_types.LAST_UPDATE_DATE%TYPE
               ,p_last_updated_by    in ff_formula_types.LAST_UPDATED_BY%TYPE
               ,p_last_update_login  in ff_formula_types.LAST_UPDATE_LOGIN%TYPE) Is
--
  l_proc   varchar2(100) := g_package || 'update_formula_types';

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
    Update ff_formula_types
       set type_description  = p_type_description
          ,last_update_date  = p_last_update_date
          ,last_updated_by   = p_last_updated_by
          ,last_update_login = p_last_update_login
     Where formula_type_name = p_formula_type_name;
--
  hr_utility.set_location('Leaving:'|| l_proc, 20);
End update_formula_types;
--

--
-- Called from load_row_context_usages and will insert new rows into FF_FTYPE_CONTEXT_USAGES table
Procedure insert_fcontext_usages(
               p_formula_type_name  in FF_FORMULA_TYPES.formula_type_name%TYPE
              ,p_context_name       in FF_CONTEXTS.context_name%TYPE) IS

  l_proc   varchar2(100) := g_package || 'insert_fcontext_usages';

  l_formula_type_id    FF_FORMULA_TYPES.formula_type_id%TYPE := 0;
  l_context_id         FF_CONTEXTS.context_name%TYPE := 0;
Begin
   hr_utility.set_location('Entering:'|| l_proc, 10);
   --Check if the formula type id is valid one......
   l_formula_type_id := chk_formula_type_name(p_formula_type_name => p_formula_type_name);

   --Check if the context is valid one......
   l_context_id := chk_context_name(p_context_name => p_context_name);

   If (l_formula_type_id <> 0 and l_context_id <> 0) Then
     Insert into FF_FTYPE_CONTEXT_USAGES
                 (formula_type_id
                 ,context_id)
                 Values (l_formula_type_id
                        ,l_context_id);
   End If;
   --
   hr_utility.set_location('Leaving:'|| l_proc, 20);

End insert_fcontext_usages;
--

-- Called from insert_fcontext_usages and will
-- check if the formula type id is valid one, also will return the formula_type_id......
Function chk_formula_type_name(p_formula_type_name in FF_FORMULA_TYPES.formula_type_name%TYPE)
Return Number
IS
--Cursor to see if the formula_type_id exists
 Cursor csr_ftype_id Is
    Select formula_type_id
      From FF_FORMULA_TYPES
     Where formula_type_name =  p_formula_type_name;

--local variable
 l_formula_type_id NUMBER;
 l_proc   varchar2(100) := g_package || 'chk_fomula_type_id';
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN csr_ftype_id;
  FETCH  csr_ftype_id into l_formula_type_id;
  If csr_ftype_id%notfound Then
    CLOSE csr_ftype_id;
    fnd_message.set_name('FF', 'FF_34862_INV_FORMULA_TYPE');
    fnd_message.set_token('FORMULA_TYPE',p_formula_type_name);
    fnd_message.raise_error;
    return 0;
  End if;
  CLOSE csr_ftype_id;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  return l_formula_type_id;
  --
End chk_formula_type_name;

-- Called from insert_fcontext_usages and will
-- check if the context is valid one, also will return the contextid......
Function chk_context_name(p_context_name in FF_CONTEXTS.context_name%TYPE)
Return Number
IS
--Cursor to see if the formula_type_id exists
 Cursor csr_fcon_id Is
    Select context_id
      From FF_CONTEXTS
     Where context_name =  p_context_name;

--local variable
 l_context_id NUMBER;
 l_proc   varchar2(100) := g_package || 'chk_context_name';
--
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

  OPEN csr_fcon_id;
  FETCH  csr_fcon_id into l_context_id;
  If csr_fcon_id%notfound Then
    CLOSE csr_fcon_id;
    fnd_message.set_name('FF', 'FF_34861_INV_CONTEXT_TYPE');
    fnd_message.set_token('CONTEXT',p_context_name);
    fnd_message.raise_error;
    return 0;
  End if;
  CLOSE csr_fcon_id;

  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  return l_context_id;
  --
End chk_context_name;

------------------------------------------------------------------------------------------------
End ff_load_ftypes_pkg;

/
