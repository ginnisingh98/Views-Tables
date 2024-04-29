--------------------------------------------------------
--  DDL for Package Body FF_FFXWSDFF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_FFXWSDFF_PKG" as
/* $Header: ffxwsdff.pkb 115.1 99/07/16 02:04:17 porting ship $ */

--------------------------------------------------------
-- I : Row handlers for FF_FUNCTIONS                  --
--------------------------------------------------------

procedure insert_function(x_rowid       in out varchar2,
                          x_function_id in out number,
                          x_class              varchar2,
                          x_name               varchar2,
                          x_alias_name         varchar2,
                          x_business_group_id  number,
                          x_created_by         number,
                          x_creation_date      date,
                          x_data_type          varchar2,
                          x_definition         varchar2,
                          x_last_updated_by    number,
                          x_last_update_date   date,
                          x_last_update_login  number,
                          x_legislation_code   varchar2,
                          x_description        varchar2
                         ) is

  cursor c_rowid is
    select rowid
    from ff_functions
    where function_id = x_function_id;

  cursor c_sequence is
    select ff_functions_s.nextval
    from dual;

begin

  open c_sequence;
  fetch c_sequence into x_function_id;
  if (c_sequence%notfound) then
    close c_sequence;
    raise no_data_found;
  end if;
  close c_sequence;

  insert into ff_functions(
    function_id,
    class,
    name,
    alias_name,
    business_group_id,
    created_by,
    creation_date,
    data_type,
    definition,
    last_updated_by,
    last_update_date,
    last_update_login,
    legislation_code,
    description
  )values(
    x_function_id,
    x_class,
    x_name,
    x_alias_name,
    x_business_group_id,
    x_created_by,
    x_creation_date,
    x_data_type,
    x_definition,
    x_last_updated_by,
    x_last_update_date,
    x_last_update_login,
    x_legislation_code,
    x_description
  );

  open c_rowid;
  fetch c_rowid into x_rowid;
  if (c_rowid%notfound) then
   close c_rowid;
    raise no_data_found;
  end if;
  close c_rowid;

end insert_function;


procedure lock_function(x_rowid              varchar2,
                        x_function_id        number,
                        x_class              varchar2,
                        x_name               varchar2,
                        x_alias_name         varchar2,
                        x_business_group_id  number,
                        x_created_by         number,
                        x_creation_date      date,
                        x_data_type          varchar2,
                        x_definition         varchar2,
                        x_last_updated_by    number,
                        x_last_update_date   date,
                        x_last_update_login  number,
                        x_legislation_code   varchar2,
                        x_description        varchar2
                       ) is

  cursor c_row is
    select function_id,
    class,
    name,
    alias_name,
    business_group_id,
    data_type,
    definition,
    legislation_code,
    description
  from ff_functions
  where rowid = x_rowid
  for update of function_id nowait;

  recinfo c_row%rowtype;

begin

  open c_row;
  fetch c_row into recinfo;
  if (c_row%notfound) then
    close c_row;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c_row;
  if (
          (recinfo.function_id = x_function_id)
      and (recinfo.class = x_class)
      and (recinfo.name = x_name)
      and (   (recinfo.alias_name = x_alias_name)
           or (    (recinfo.alias_name is null)
               and (x_alias_name is null)))
      and (   (recinfo.business_group_id = x_business_group_id)
           or (    (recinfo.business_group_id is null)
               and (x_business_group_id is null)))
      and (   (recinfo.data_type = x_data_type)
           or (    (recinfo.data_type is null)
               and (x_data_type is null)))
      and (   (recinfo.definition = x_definition)
           or (    (recinfo.definition is null)
               and (x_definition is null)))
      and (   (recinfo.legislation_code = x_legislation_code)
           or (    (recinfo.legislation_code is null)
               and (x_legislation_code is null)))
      and (   (recinfo.description = x_description)
           or (    (recinfo.description is null)
               and (x_description is null)))
     ) then
    return;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end lock_function;


procedure update_function(x_rowid              varchar2,
                          x_function_id        number,
                          x_class              varchar2,
                          x_name               varchar2,
                          x_alias_name         varchar2,
                          x_business_group_id  number,
                          x_created_by         number,
                          x_creation_date      date,
                          x_data_type          varchar2,
                          x_definition         varchar2,
                          x_last_updated_by    number,
                          x_last_update_date   date,
                          x_last_update_login  number,
                          x_legislation_code   varchar2,
                          x_description        varchar2
                         ) is

begin

  update ff_functions set
    function_id       = x_function_id,
    class             = x_class,
    name              = x_name,
    alias_name        = x_alias_name,
    business_group_id = x_business_group_id,
    created_by        = x_created_by,
    creation_date     = x_creation_date,
    data_type         = x_data_type,
    definition        = x_definition,
    last_updated_by   = x_last_updated_by,
    last_update_date  = x_last_update_date,
    last_update_login = x_last_update_login,
    legislation_code  = x_legislation_code,
    description       = x_description
  where rowid = x_rowid;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end update_function;


procedure delete_function(x_rowid       varchar2,
                          x_function_id number) is

begin

  delete from ff_functions
  where rowid = x_rowid;

  delete from ff_function_context_usages
  where function_id = x_function_id;

  delete from ff_function_parameters
  where function_id = x_function_id;

end delete_function;


-------------------------------------------------------------
-- II : Row handlers for FF_FUNCTION_CONTEXT_USAGES        --
-------------------------------------------------------------

procedure insert_context_usage(x_rowid       in out varchar2,
                               x_function_id        number,
                               x_sequence_number    number,
                               x_context_id         number
                              ) is

  cursor c_rowid is
    select rowid
    from ff_function_context_usages
    where function_id = x_function_id;

begin

  insert into ff_function_context_usages(
    function_id,
    sequence_number,
    context_id
  )values(
    x_function_id,
    x_sequence_number,
    x_context_id
  );

  open c_rowid;
  fetch c_rowid into x_rowid;
  if (c_rowid%notfound) then
   close c_rowid;
    raise no_data_found;
  end if;
  close c_rowid;

end insert_context_usage;


procedure lock_context_usage(x_rowid              varchar2,
                             x_function_id        number,
                             x_sequence_number    number,
                             x_context_id         number
                            ) is

  cursor c_row is
    select function_id,
    sequence_number,
    context_id
  from ff_function_context_usages
  where rowid = x_rowid
  for update of function_id nowait;

  recinfo c_row%rowtype;

begin

  open c_row;
  fetch c_row into recinfo;
  if (c_row%notfound) then
    close c_row;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c_row;
  if (
          (recinfo.function_id = x_function_id)
      and (recinfo.sequence_number = x_sequence_number)
      and (recinfo.context_id = x_context_id)
     ) then
    return;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end lock_context_usage;


procedure update_context_usage(x_rowid              varchar2,
                               x_function_id        number,
                               x_sequence_number    number,
                               x_context_id         number
                              ) is

begin

  update ff_function_context_usages set
    function_id       = x_function_id,
    sequence_number   = x_sequence_number,
    context_id        = x_context_id
  where rowid = x_rowid;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end update_context_usage;


procedure delete_context_usage(x_rowid varchar2) is

begin

  delete from ff_function_context_usages
  where rowid = x_rowid;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end delete_context_usage;


-----------------------------------------------------------
-- III : Row handlers for FF_FUNCTION_PARAMETERS         --
-----------------------------------------------------------

procedure insert_parameter(x_rowid         in out varchar2,
                           x_function_id          number,
                           x_sequence_number      number,
                           x_class                varchar2,
                           x_continuing_parameter varchar2,
                           x_data_type            varchar2,
                           x_name                 varchar2,
                           x_optional             varchar2
                          ) is

  cursor c_rowid is
    select rowid
    from ff_function_parameters
    where function_id = x_function_id;

begin

  insert into ff_function_parameters(
    function_id,
    sequence_number,
    class,
    continuing_parameter,
    data_type,
    name,
    optional
  )values(
    x_function_id,
    x_sequence_number,
    x_class,
    x_continuing_parameter,
    x_data_type,
    x_name,
    x_optional
  );

  open c_rowid;
  fetch c_rowid into x_rowid;
  if (c_rowid%notfound) then
    close c_rowid;
    raise no_data_found;
  end if;
  close c_rowid;

end insert_parameter;


procedure lock_parameter(x_rowid                varchar2,
                         x_function_id          number,
                         x_sequence_number      number,
                         x_class                varchar2,
                         x_continuing_parameter varchar2,
                         x_data_type            varchar2,
                         x_name                 varchar2,
                         x_optional             varchar2
                        ) is

  cursor c_row is
    select function_id,
    sequence_number,
    class,
    continuing_parameter,
    data_type,
    name,
    optional
  from ff_function_parameters
  where rowid = x_rowid
  for update of function_id nowait;

  recinfo c_row%rowtype;

begin

  open c_row;
  fetch c_row into recinfo;
  if (c_row%notfound) then
    close c_row;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c_row;
  if (
          (recinfo.function_id = x_function_id)
      and (recinfo.sequence_number = x_sequence_number)
      and (recinfo.class = x_class)
      and (recinfo.continuing_parameter = x_continuing_parameter)
      and (recinfo.data_type = x_data_type)
      and (recinfo.name = x_name)
      and (recinfo.optional = x_optional)
     ) then
    return;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end lock_parameter;


procedure update_parameter(x_rowid                varchar2,
                           x_function_id          number,
                           x_sequence_number      number,
                           x_class                varchar2,
                           x_continuing_parameter varchar2,
                           x_data_type            varchar2,
                           x_name                 varchar2,
                           x_optional             varchar2
                          ) is

begin

  update ff_function_parameters set
    function_id          = x_function_id,
    sequence_number      = x_sequence_number,
    class                = x_class,
    continuing_parameter = x_continuing_parameter,
    data_type            = x_data_type,
    name                 = x_name,
    optional             = x_optional
  where rowid = x_rowid;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end update_parameter;


procedure delete_parameter(x_rowid varchar2) is

begin

  delete from ff_function_parameters
  where rowid = x_rowid;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end delete_parameter;


---------------------------------------------------------------------
-- IV : Other functions and procedures needed for FFXWSDFF         --
---------------------------------------------------------------------

---------------------------------------------------------------------
-- next_parameter_sequence
--
-- Returns the next available parameter sequence number
-- to maintain a sequence of parameters within a particular function.
---------------------------------------------------------------------

function next_parameter_sequence(p_function_id number) return number is

  v_parameter_sequence number := null;

  cursor c_next_parameter_sequence is
    select  nvl (max (sequence_number), 0) + 1
    from    ff_function_parameters
    where   function_id = p_function_id;

begin

  open c_next_parameter_sequence;
  fetch c_next_parameter_sequence into v_parameter_sequence;
  close c_next_parameter_sequence;

  return v_parameter_sequence;

end next_parameter_sequence;


---------------------------------------------------------------------
-- next_context_usage_sequence
--
-- Returns the next available context usage sequence number
-- to maintain a sequence of contexts within a particular function.
---------------------------------------------------------------------

function next_context_usage_sequence(p_function_id number) return number is

  v_context_sequence number := null;

  cursor c_next_context_sequence is
    select  nvl (max (sequence_number), 0) + 1
    from    ff_function_context_usages
    where   function_id = p_function_id;

begin

  open c_next_context_sequence;
  fetch c_next_context_sequence into v_context_sequence;
  close c_next_context_sequence;

  return v_context_sequence;

end next_context_usage_sequence;


---------------------------------------------------------------------
-- check_alias_name
--
-- Ensures that the alias name is different to the function name
-- within the FUNCTION block.
---------------------------------------------------------------------

procedure check_alias_name(p_function_name varchar2,
                           p_alias_name    varchar2) is

begin

  if p_alias_name = p_function_name then
    fnd_message.set_name('FF','FF_52245_BAD_ALIAS_NAME');
    app_exception.raise_exception;
  end if;

end check_alias_name;


---------------------------------------------------------------------
-- set_parameter_properties
--
-- Sets the correct OPTIOANL and CONTINUING_PARAMETER properties for
-- a parameter class of 'out' or 'in out'.
---------------------------------------------------------------------

procedure set_parameter_properties(p_class                       varchar2,
                                   p_optional             in out varchar2,
                                   p_continuing_parameter in out varchar2) is

begin

  if (p_class <> 'I') then
    p_optional := 'N';
    p_continuing_parameter := 'N';
  end if;

end set_parameter_properties;


end ff_ffxwsdff_pkg;


/
