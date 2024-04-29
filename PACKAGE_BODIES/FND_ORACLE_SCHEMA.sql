--------------------------------------------------------
--  DDL for Package Body FND_ORACLE_SCHEMA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ORACLE_SCHEMA" AS
/* $Header: AFSCSHMB.pls 120.1 2005/07/02 03:09:53 appldev ship $ */



function GetOuValue (
  x_lookup_code in varchar2
) return varchar2 is
  ret_value varchar(150);
begin
  begin
    select tag
    into ret_value
    from fnd_lookup_values
    where lookup_type = 'EXTERNAL_SCHEMA'
    and lookup_code = x_lookup_code
    and language = userenv('LANG');
    return(ret_value);
  exception
    when no_data_found then
      return('');
    when others then
      raise;
  end;
end GetOuValue;

function GetOpValue (
  schema_name in varchar2,
  applsyspwd in varchar2
) return varchar2 is
  cnt number;
begin
  if (schema_name is null or applsyspwd is null) then
    return('');
  else
    -- validate this is an existing schema name
    begin
      select oracle_id
      into cnt
      from fnd_oracle_userid
      where oracle_username = upper(schema_name);
    exception
      when no_data_found then
        fnd_message.set_name('FND', 'FND_NO_SCHEMA_NAME');
        fnd_message.set_token('SCHEMA_NAME', schema_name);
        app_exception.raise_exception;
    end;
    return(fnd_web_sec.get_op_value(schema_name, applsyspwd));
  end if;
end GetOpValue;

END FND_ORACLE_SCHEMA;

/

  GRANT EXECUTE ON "APPS"."FND_ORACLE_SCHEMA" TO "EM_OAM_MONITOR_ROLE";
