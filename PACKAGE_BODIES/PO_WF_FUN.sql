--------------------------------------------------------
--  DDL for Package Body PO_WF_FUN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WF_FUN" AS
/* $Header: powffunb.pls 120.0 2005/06/01 13:23:00 appldev noship $ */

PROCEDURE EXTRACT_STR(in_str varchar2,
                      out_str out NOCOPY varchar2)
IS
  x_left number;
  x_right number;
BEGIN
  select instr(in_str, ''''), instr(in_str,'''',1,2)
  into x_left, x_right
  from dual;

  select substr(in_str,x_left+1, x_right-x_left-1)
  into out_str
  from dual;

END EXTRACT_STR;


PROCEDURE PRINT_FUNCTION(x_item_type varchar2)
IS
    x_wf_function wf_functions_cursor%rowtype;
    x_wf_function_code wf_function_codes_cursor%rowtype;
    x_line_s number;
    x_line_e number;
    x_count  number :=0 ;
    x_text varchar2(300);
    x_temp varchar2(300) :=x_item_type;
    x_item_type_name varchar2(200);
    x_function_name  varchar2(200);
    l_apps_schema_name fnd_oracle_userid.oracle_username%type; --bug4025028

BEGIN

    if (x_item_type like 'ALL') then
      x_temp := '%';
    end if;
   --bug4025028 Start
   -- Deriving the APPS Universal Schema name
   -- This value would be used in queries below instead of using hardcoded 'APPS'
    BEGIN
      SELECT oracle_username
      INTO l_apps_schema_name
      FROM fnd_oracle_userid
      WHERE read_only_flag = 'U';
    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
    END;
   --bug4025028 End
    open wf_functions_cursor(x_temp);

    loop

      fetch wf_functions_cursor into x_wf_function;
      exit when wf_functions_cursor%notfound;

      select display_name
        into x_item_type_name
        from wf_item_types_tl
       where name = x_wf_function.item_type
         and language = 'US';

      select distinct display_name
        into x_function_name
        from wf_activities_tl
       where item_type = x_wf_function.item_type
         and name      = x_wf_function.name
         and language = 'US' ;

      select min(line)
        into x_line_s
        from all_source
       where name= x_wf_function.package_name
         and owner= l_apps_schema_name  --bug4025028
         and type='PACKAGE BODY'
         and upper(text) like '%PROCEDURE'||'% '||x_wf_function.procedure_name||'%' ;

      select max(line)
        into x_line_e
        from all_source
       where name= x_wf_function.package_name
         and owner= l_apps_schema_name --bug4025028
         and type='PACKAGE BODY'
         and (upper(text) like '%END'||'% '||x_wf_function.procedure_name||'%');

      open  wf_function_codes_cursor(x_wf_function.package_name, x_line_s, x_line_e,l_apps_schema_name);

      loop
        fetch wf_function_codes_cursor into x_wf_function_code;
        exit when wf_function_codes_cursor%NOTFOUND;

        if(x_count =0) then
          dbms_output.put_line(' /***************************************************/');
          dbms_output.put_line(' Item type                '||x_item_type_name);
          dbms_output.put_line(' Item type(Internal name) '||x_wf_function.item_type);
          dbms_output.put_line(' Function Activity        '||x_function_name);
          dbms_output.put_line(' Package                  '||x_wf_function.package_name);
          dbms_output.put_line(' Procedure                '||x_wf_function.procedure_name);
          dbms_output.put_line(' /***************************************************/');
          x_count :=1;
        end if;

        if (upper(x_wf_function_code.text) like '%SETITEMATTR%' ) then
           select text
             into x_text
             from all_source
            where name = x_wf_function.package_name
              and owner= l_apps_schema_name --bug4025028
              and type='PACKAGE BODY'
              and line >=x_wf_function_code.line and line <= (x_wf_function_code.line+5)
              and upper(text) like '%ANAME%';

            extract_str(x_text,x_temp);
            dbms_output.put_line('SETITEMATTR   '||x_temp);

        elsif (upper(x_wf_function_code.text) like '%GETITEMATTR%')  then
           select text
             into x_text
             from all_source
            where name = x_wf_function.package_name
              and owner= l_apps_schema_name --bug4025028
              and type='PACKAGE BODY'
              and line >=x_wf_function_code.line and line <= (x_wf_function_code.line+3)
              and upper(text) like '%ANAME%';

            extract_str(x_text,x_temp);
            dbms_output.put_line('GETITEMATTR   '||x_temp);
        else
            dbms_output.put_line(x_wf_function_code.text);
        end if;

      end loop;

      close wf_function_codes_cursor;

      dbms_output.put_line('  ');
      x_count := 0;
    end loop;

    close wf_functions_cursor;

EXCEPTION

 WHEN OTHERS THEN
       dbms_output.put_line ('In exception');
       raise_application_error(-20001,sqlerrm||'---');
END PRINT_FUNCTION;


END PO_WF_FUN;

/
