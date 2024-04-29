--------------------------------------------------------
--  DDL for Package Body FND_GENERIC_POLICY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_GENERIC_POLICY" AS
/* $Header: AFSCGPLB.pls 120.2 2005/10/25 18:57:31 tmorrow noship $ */


FUNCTION GET_PREDICATE(    p_schema IN VARCHAR2,
                           p_object IN VARCHAR2)
                           RETURN VARCHAR2 is
    retval varchar2(32767);
    l_object_name varchar2(30);
    status_code varchar2(30);
begin
    retval := NULL;
    begin
      select o.obj_name
        into l_object_name
        from fnd_objects o, fnd_form_functions f
       where f.function_name = p_object
        and o.object_id = f.object_id;

      fnd_data_security.get_security_predicate(
                p_api_version => 1.0,
                p_function => p_object,
                p_object_name => l_object_name,
                p_statement_type => 'VPD',
                x_predicate => retval,
                x_return_status => status_code);
      if (status_code <> 'T') then
         retval := NULL;
         if (fnd_log.LEVEL_EXCEPTION >= fnd_log.g_current_runtime_level) then
            fnd_log.message(FND_LOG.LEVEL_EXCEPTION,
                     'fnd.plsql.FND_GENERIC_POLICY.GET_PREDICATE.gsp_fail');
         end if;
      end if;

    exception
      when no_data_found then
        retval := NULL;
    end;

    /* If the user doesn't have access, then return no-access predicate*/
    if(retval is NULL) then
      retval := '(1=2)';
    end if;

    return retval;
end;

END FND_GENERIC_POLICY;

/
