--------------------------------------------------------
--  DDL for Package Body MSD_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_VALIDATE" as
/* $Header: msdvaleb.pls 115.30 2004/05/12 16:59:36 jarora ship $ */

   v_m2a_dblink                     VARCHAR2(128);
   v_a2m_dblink                     VARCHAR2(128);
   v_instance_type  number;
   v_apps_ver  number;
   v_user_name         VARCHAR2(100):= NULL;
   v_resp_name         VARCHAR2(100):= NULL;
   v_application_name  VARCHAR2(240):= NULL;
   v_application_code varchar2(3);

   v_instance_id  number;
   v_plan_id  number;
   v_instance_code  varchar2(4);
   v_cp_enabled                 NUMBER;
procedure write_output(p_text in varchar2) is
begin
  /* remove occurences of null string and write to output */
  fnd_file.put_line(fnd_file.output, replace(p_text, fnd_global.local_chr(0)));
  /* dbms_output.put_line(p_text);
  insert into msd_test values(p_text);*/
end write_output;


procedure write_log(p_text in varchar2) is
begin
  fnd_file.put_line(fnd_file.log, p_text);
  /*insert into msd_test values(p_text);*/
end write_log;



procedure run_validation(errbuf out nocopy varchar2,
                         retcode out nocopy varchar2,
                         p_function in varchar2) is

begin
run_validation(errbuf 			=> errbuf,
               retcode 			=> retcode,
               p_function  		=> p_function,
               p_detail  		=> '1',
               p_application_code  	=> 'MSD',
               p_token1  		=> null,
               p_token2  		=> null,
               p_token3  		=> null);
end;


procedure run_validation(errbuf out nocopy varchar2,
                         retcode out nocopy varchar2,
                         p_function in varchar2,
                         p_detail in varchar2) is

begin
run_validation(errbuf 			=> errbuf,
               retcode 			=> retcode,
               p_function  		=> p_function,
               p_detail  		=> p_detail,
               p_application_code  	=> 'MSD',
               p_token1  		=> null,
               p_token2  		=> null,
               p_token3  		=> null);
end;


procedure run_validation_all (errbuf out nocopy varchar2,
                              retcode out nocopy varchar2,
                              p_application_code in varchar2,
                              p_function in varchar2,
                              p_plan_id in number,
                              p_instance_id in number,
                              p_report_type in varchar2) is
begin
run_validation_all (errbuf 		=> errbuf,
                    retcode 		=> retcode,
                    p_application_code 	=> p_application_code,
                    p_function 		=> p_function,
                    p_plan_id 		=> p_plan_id,
                    p_instance_id 	=> p_instance_id,
                    p_report_type 	=> p_report_type,
                    p_token1 		=> null,
                    p_token2 		=> null,
                    p_token3 		=> null);
end;

/* run_validation is the original procedure called by MSD. Retaining this for existing customers
of MSD. This package will call run_validation_all. This procedure is now a wrapper procedure */

procedure run_validation(errbuf out nocopy varchar2,
                         retcode out nocopy varchar2,
                         p_function in varchar2,
                         p_detail in varchar2,
                         p_application_code varchar2,
                         p_token1 in number,
                         p_token2 in number,
                         p_token3 in number) is

 lv_errbuf            VARCHAR2(500);
 lv_ret_code number ;
 lv_report_type varchar2(1);

begin

        select DECODE(p_detail,'1','2','2','1') into lv_report_type from DUAL;
        run_validation_all (lv_errbuf,
                            lv_ret_code,
                            'MSD',
                            p_function,
                            -1, --plan
                            0, --instance
                            lv_report_type, -- Detail report complete
                            p_token1 ,
                            p_token2 ,
                            p_token3 );

errbuf:= lv_errbuf;
retcode := lv_ret_code;

end run_validation;

/* Added generic procedure run_all_validation for MSC, MSD, MSR, MSO, ATP, UI*/
/* report type 1 = SUMMARY
               2 = Complete Detail
               3 = Detail with Errors
               4 = Detail with Errors and Warnings */
PROCEDURE  RUN_VALIDATION_ALL (errbuf out nocopy varchar2,
                         retcode out nocopy varchar2,
                         p_application_code in varchar2,
                         p_function in varchar2,
                         p_plan_id in number,
                         p_instance_id in number,
                         p_report_type in varchar2, -- Detail report complete
                         p_token1 in number,
                         p_token2 in number,
                         p_token3 in number) is

 TYPE CurTyp is ref cursor;
 TYPE SelectRec is record(c1 msd_audit_sql_statements.column1%TYPE,
                          c2 msd_audit_sql_statements.column1%TYPE,
                          c3 msd_audit_sql_statements.column1%TYPE,
                          c4 msd_audit_sql_statements.column1%TYPE,
                          c5 msd_audit_sql_statements.column1%TYPE,
                          c6 msd_audit_sql_statements.column1%TYPE,
                          c7 msd_audit_sql_statements.column1%TYPE,
                          c8 msd_audit_sql_statements.column1%TYPE,
                          c9 msd_audit_sql_statements.column1%TYPE,
                          c10 msd_audit_sql_statements.column1%TYPE,
                          c11 msd_audit_sql_statements.column1%TYPE);

 p_summary boolean := (p_report_type = '1');
 write_label boolean := FALSE;
 existing_dp_functionality boolean := FALSE;
 label varchar2(4000);
 log_label varchar2(4000);
 p_report_type_summ boolean ;
 p_report_type_err boolean ;
 p_report_type_warn_err boolean ;
 noop boolean := true;
 v_function_name varchar2(200);
 v_appl_name varchar2(200);
 lv_where_clause varchar2(1);
 lv_count number := 0;
 lv_count_summ number := 0;

 cv CurTyp;
 selrow SelectRec;

 v_sql_stmt long;
 norows boolean := true;
 str varchar2(4000);
 log_str varchar2(4000);

 cursor statements (c_application_code in varchar2) is
  select * from msd_audit_sql_statements
  where function = p_function
  and application_code = c_application_code
  and nvl(enabled, 'Y') = 'Y'
  order by statement_id, STATEMENT_DESCRIPTION;

 cursor c_instances(c_instance_id in number) is
 SELECT DECODE( M2A_DBLINK, NULL, NULL_DBLINK, '@'||M2A_DBLINK||' ') M2A_DBLINK,
                INSTANCE_TYPE, apps_ver,
               DECODE( A2M_DBLINK, NULL, NULL_DBLINK, '@'||A2M_DBLINK||' ') A2M_DBLINK,
               instance_code,
                instance_id
 FROM MSC_APPS_INSTANCES
 where instance_id = decode(c_instance_id, -1, instance_id,
                                            0, instance_id,
                                               c_instance_id);


BEGIN
  retcode := '0';
  v_instance_id := nvl(p_INSTANCE_ID,-1);
  v_application_code := p_application_code;
  v_plan_id := p_plan_id;
  IF v_instance_id = 0 THEN
      existing_dp_functionality := TRUE;
      v_application_code := p_application_code;
  END IF;
/*
   The application Code being passed are MSC, MSD, MSD, IO, ATP
   For IO and ATP THe appropriate application code needs to be populated
     The following combinations need to be converted appropriate application_code
     application ATP + function COLL_DATA ---> application MSC
     application ATP + function ATP_DATA ---> application MSC
     application IO + function IO_DATA ---> application MSO
     application IO + function COLL_DATA ---> application MSC
     application IO + function UI_DATA ---> application MSC
     HLS queries will be seeded as MSC
  */

  IF existing_dp_functionality = FALSE THEN
      /* With ATP COLL_DATA and ATP_DATA are being passed */
      IF p_application_code = 'ATP' THEN
             v_application_code := 'MSC';
      END IF;
      /* With IO COLL_DATA , UI_DATA and IO_DATA are being passed */
      IF p_application_code = 'IO' and p_function in ('COLL_DATA','UI_DATA') THEN
             v_application_code := 'MSC';
      END IF;
      IF p_application_code = 'IO' and p_function = 'IO_DATA'  THEN
             v_application_code := 'MSR';
      END IF;

      /* For USER DEFINED CUSTOM QUERIES functions which are not in the seeded functions
         For IO and ATP THe appropriate application code needs to be populated*/
      IF p_application_code = 'ATP' THEN
             v_application_code := 'MSC';
      END IF;

      IF p_application_code = 'IO'
          and p_function not in ('COLL_DATA','UI_DATA', 'IO_DATA', 'PLN_DATA','ATP_DATA',
                                        'FACT_DATA','LEVEL_VALUES')
      THEN v_application_code := 'MSR';
      END IF;


  END IF; --existing DP functionality

-- If an instance is passed
  IF v_instance_id not in (-1,0) THEN
  BEGIN
         SELECT DECODE( M2A_DBLINK, NULL, NULL_DBLINK, '@'||M2A_DBLINK||' '),
                INSTANCE_TYPE, apps_ver,
               DECODE( A2M_DBLINK, NULL, NULL_DBLINK, '@'||A2M_DBLINK||' '),
               instance_code
           INTO v_m2a_dblink,
                v_instance_type, v_apps_ver,
                v_a2m_dblink,
                v_instance_code
           FROM MSC_APPS_INSTANCES
          WHERE INSTANCE_ID= p_INSTANCE_ID;


  EXCEPTION

         WHEN NO_DATA_FOUND THEN
            RETCODE := 2;
            FND_MESSAGE.SET_NAME('MSC', 'MSC_DP_INVALID_INSTANCE_ID');
            FND_MESSAGE.SET_TOKEN('INSTANCE_ID', p_INSTANCE_ID);
            ERRBUF:= FND_MESSAGE.GET;
            RETURN;
         WHEN OTHERS THEN
            RETCODE := 2;
            ERRBUF  := SQLERRM;
            RETURN;


    END;
   END IF;
/* Get the User Information */
  SELECT FND_GLOBAL.USER_NAME,
          FND_GLOBAL.RESP_NAME,
          FND_GLOBAL.APPLICATION_NAME
          INTO  v_user_name,
                v_resp_name,
                v_application_name
          FROM  dual;

/* If the input to Instances is ALL INSTANCES (-1) THEN LOOP thru all the instances
 If the input to Instances is 0 It indicates that the existing DP Reports are making a call
 exit after first loop. This is being done to retain existing functionality of DP
 If an actual instance is passed then the loop will only work once */
For c_inst in c_instances (v_instance_id) LOOP --Instance Loop

v_instance_id := c_inst.instance_id;
v_a2m_dblink := c_inst.a2m_dblink;
v_m2a_dblink := c_inst.m2a_dblink;
v_apps_ver := c_inst.apps_ver;
v_instance_code := c_inst.instance_code;
v_instance_type := c_inst.instance_type;


/* get descriptive name */
  begin
    select meaning
    into v_function_name
    from fnd_lookup_values_vl
    where lookup_type = 'MSD_AUDIT_REPORT'
      and lookup_code = p_function;

    EXCEPTION
      when others then
        v_function_name := p_function;
  end;

IF existing_dp_functionality THEN /* For existing functionality of DP*/
  str := get_translated_string('MSD_AUDIT_REPORT_TITLE', 'MSD', 'REPORT_TITLE', v_function_name);
  write_output('<title>' || str || '</title>'||
               '<h3>' || str || '</h3>');
  write_log(str);
ELSE
  str := get_translated_string('MSC_AUDIT_REPORT_TITLE', 'MSC', 'REPORT_TITLE', v_function_name);
  str := str || ' For Instance '||v_instance_code;
  write_output('<title>' || str || '</title>'||
               '<h3>' || str || '</h3>');
  write_log(str);

END IF;

  for s in statements(v_application_code) loop
   lv_count := 0;
   lv_count_summ := 0;
    noop := false;
    norows := true;
    write_label:= true;

    /* Generate sql for dynamic cursor. The goal is to generate columns
       of the form <td>column</td> for all the non-null COLUMN columns.
    */
    if s.summary_message_only = 'Y' then
      /* query should only return tokenized summary message rows */

      v_sql_stmt :=
       'SELECT ' ||
         get_td_tag('msd_validate.get_translated_string(' ||
                    '''' || s.summary_message          || ''', ' ||
                    '''' || v_application_code         || ''', ' ||
                    '''' || s.summary_token1           || ''', ' ||
                    nvl(s.summary_token1_value,'''''') || ',   ' ||
                    '''' || s.summary_token2           || ''', ' ||
                    nvl(s.summary_token2_value,'''''') || ',   ' ||
                    '''' || s.summary_token3           || ''', ' ||
                    nvl(s.summary_token3_value,'''''') || ')')   ||
         ', '''', '''', '''', '''', '''', '''', '''', '''', '''', '''' ';
    else
     /* select all query columns */
      v_sql_stmt :=
       'SELECT ' ||
         get_td_tag(s.column1) || ',' ||
         get_td_tag(s.column2) || ',' ||
         get_td_tag(s.column3) || ',' ||
         get_td_tag(s.column4) || ',' ||
         get_td_tag(s.column5) || ',' ||
         get_td_tag(s.column6) || ',' ||
         get_td_tag(s.column7) || ',' ||
         get_td_tag(s.column8) || ',' ||
         get_td_tag(s.column9) || ',' ||
         get_td_tag(s.column10) || ',' ||
         get_td_tag(s.column11);
    end if;

    select decode(nvl(s.where_clause,'N'),'N','N','Y') into lv_where_clause  from dual;
    If lv_where_clause = 'Y' then
    v_sql_stmt := v_sql_stmt || ' FROM ' || replace(s.from_clause,'@M2A_DBLINK',v_m2a_dblink) ||
                                ' WHERE '|| replace(replace(replace(replace(replace(s.where_clause,'@M2A_DBLINK',v_m2a_dblink),'@INSTANCE_ID',v_instance_id),'@PLAN_ID',v_plan_id),'@INSTANCE_CODE',v_instance_code),'@A2M_DBLINK',v_a2m_dblink);
    else
    v_sql_stmt := v_sql_stmt || ' FROM ' || replace(s.from_clause,'@M2A_DBLINK',v_m2a_dblink);

    end if;

    v_sql_stmt := replace(replace(v_sql_stmt,'@USER_NAME',v_user_name),'@RESP_NAME',v_resp_name);


    /* process this sql statement */
    write_output('<i>'||
                  get_translated_string(s.statement_description,
                                        s.application_code) ||
                 '</i><br>');
    write_log( get_translated_string(s.statement_description, s.application_code) );


    begin
      write_output('<table border=1 cellspacing=1 cellpadding=1>');

      /* open cursor for tokenized query */
      if (p_token1 is null) then
        open cv for v_sql_stmt;
      elsif (p_token2 is null) then
        open cv for v_sql_stmt using p_token1;
      elsif (p_token3 is null) then
        open cv for v_sql_stmt using p_token1, p_token2;
      else
        open cv for v_sql_stmt using p_token1, p_token2, p_token3;
      end if;

      loop
        fetch cv into selrow;
        exit when cv%NOTFOUND;

        /* warning code */
        retcode := '1';

        /* write header row if detailed output is needed */
        if (norows and
            not(p_summary) and
            nvl(s.summary_message_only, 'N') <> 'Y') then
          log_str := ' ' ||
              ' ' ||
              get_translated_string(s.description1, s.application_code) ||
              ' ' ||
              get_translated_string(s.description2, s.application_code) ||
              ' ' ||
              get_translated_string(s.description3, s.application_code) ||
              ' ' ||
              get_translated_string(s.description4, s.application_code) ||
              ' ' ||
              get_translated_string(s.description5, s.application_code) ||
              ' ' ||
              get_translated_string(s.description6, s.application_code) ||
              ' ' ||
              get_translated_string(s.description7, s.application_code) ||
              ' ' ||
              get_translated_string(s.description8, s.application_code) ||
              ' ' ||
              get_translated_string(s.description9, s.application_code) ||
              ' ' ||
              get_translated_string(s.description10, s.application_code) ||
              ' ' ||
              get_translated_string(s.description11, s.application_code) ||
              ' '  ;
          log_str := replace (replace (log_str, '<td>',' '),'</td>',' ');

          str := '<tr>' ||
              '<th>' ||
              get_translated_string(s.description1, s.application_code) ||
              '</th><th>' ||
              get_translated_string(s.description2, s.application_code) ||
              '</th><th>' ||
              get_translated_string(s.description3, s.application_code) ||
              '</th><th>' ||
              get_translated_string(s.description4, s.application_code) ||
              '</th><th>' ||
              get_translated_string(s.description5, s.application_code) ||
              '</th><th>' ||
              get_translated_string(s.description6, s.application_code) ||
              '</th><th>' ||
              get_translated_string(s.description7, s.application_code) ||
              '</th><th>' ||
              get_translated_string(s.description8, s.application_code) ||
              '</th><th>' ||
              get_translated_string(s.description9, s.application_code) ||
              '</th><th>' ||
              get_translated_string(s.description10, s.application_code) ||
              '</th><th>' ||
              get_translated_string(s.description11, s.application_code) ||
              '</th></tr>';

          str := replace(str, '<th></th>');
          label:=str;
          log_label := log_str;
--          write_output(str);
        end if;

        norows := false;

         log_str := ' ' || selrow.c1 || selrow.c2 || selrow.c3 || selrow.c4 ||selrow.c5 ||
                    selrow.c6 || selrow.c7 || selrow.c8 || selrow.c9 ||selrow.c10 || selrow.c11 || ' ';
          log_str := replace (replace (log_str, '<td>',' '),'</td>',' ');

          str := '<tr>' || selrow.c1 || selrow.c2 || selrow.c3 || selrow.c4 ||selrow.c5 ||
              selrow.c6 || selrow.c7 || selrow.c8 || selrow.c9 || selrow.c10 || selrow.c11 || '</tr>';
          str := replace(str, '<td></td>', '<td>&nbsp;</td>');

         /* The Summary report will print a count for Warnings and Errors only */
          p_report_type_summ := ((instr(str,'INVALID') + instr(str,'ERROR') + instr(str,'WARNING')) <> 0);
          IF p_report_type_summ THEN
             lv_count_summ := lv_count_summ + 1 ;
          END IF;
         /* The Summary report will print a count for Warnings and Errors only */

        /* write to output */
        if not(p_summary) then
          -- All Details
          IF p_report_type = '2' THEN
              IF write_label then
                 write_output(label);
                 write_log(log_label);
                 write_label := FALSE;
              END IF;
              lv_count:= lv_count + 1;
               write_output(str);
          write_log(log_str);
          END IF;
          -- Errors, Invalids only
          p_report_type_err := ((instr(str,'INVALID') + instr(str,'ERROR')) <> 0);
          IF p_report_type = '3' and p_report_type_err THEN
              IF write_label then
                 write_output(label);
                 write_log(log_label);
                 write_label := FALSE;
              END IF;
              lv_count:= lv_count + 1;
              write_output(str);
          write_log(log_str);
          END IF;
          -- Errors and Warnings Only
          p_report_type_warn_err := ((instr(str,'WARNING') + instr(str,'ERROR')) <> 0);
          IF p_report_type = '4' and p_report_type_warn_err THEN
              IF write_label then
                 write_output(label);
                 write_log(log_label);
                 write_label := FALSE;
              END IF;
              lv_count:= lv_count + 1;
               write_output(str);
          write_log(log_str);
          END IF;

        end if;

      end loop;

      /* print error count */
     if not(p_summary) then --1
      if (lv_count = 0) then  -- 2
        str := get_translated_string('MSD_AUDIT_NO_ERRORS');
      else
       str := '';
       if s.error_message is not null then --3
          str := get_translated_string(s.error_message, v_application_code, 'COUNT', lv_count);
       end if;  --3
      end if; --2
     else --1
      IF existing_dp_functionality THEN --2
       if (cv%rowcount = 0) then --3
        str := get_translated_string('MSD_AUDIT_NO_ERRORS');
       else
       str := '';
        if s.error_message is not null then --4
          str := get_translated_string(s.error_message, v_application_code, 'COUNT', cv%rowcount);
        end if; --4
       end if; --3
      ELSE --2
       if (lv_count_summ = 0) then --3
        str := get_translated_string('MSD_AUDIT_NO_ERRORS');
       else
       str := '';
        if s.error_message is not null then --4
          str := get_translated_string(s.error_message, v_application_code, 'COUNT', lv_count_summ);
        end if; --4
       end if; --3
      END IF; --2
     end if; --1
     log_str := str;
      write_output('</table>' || str || '<br><br>');
      write_log (log_str);
      close cv;
      exception
        when others then
           write_output('</table><font color=red>' ||
                         get_translated_string('MSD_AUDIT_SQL_ERROR') ||
                        '</font><br><br>');
           write_log('Error executing statement: ' || v_sql_stmt);
           write_log(substr(sqlerrm, 1, 150));
           retcode := '1';
    end;


  end loop;

  if noop then
    retcode := 1;

    /* get application name */
    begin
      select application_name
      into v_appl_name
      from fnd_application_vl
      where application_short_name = v_application_code;

      EXCEPTION
        when others then
          v_appl_name := v_application_code;
    end;

    str := get_translated_string('MSD_AUDIT_NO_STATEMENTS', 'MSD',
                                 'REPORT', v_function_name,
                                 'APPLICATION', v_appl_name) || '<br>';

    write_output(str);
  end if;

 IF existing_dp_functionality THEN
     EXIT ;
 END IF; -- If called from existing DP Reports then loop once

 END LOOP; --Instance Loop
  EXCEPTION
    when others then
      retcode := '2';
      errbuf := substr(SQLERRM,1,150);

end run_validation_all ;


/*
  If str is null then return ''
  otherwise, return <td>||str||</td>
*/
function get_td_tag(string varchar2) return varchar2 is
begin
  if (string is null)
    then return '''''';
    else return ('''<td>''|| ' || string || ' || ''</td>''');
  end if;
end get_td_tag;


/*
  Get translated message
*/
function get_translated_string(string 		varchar2) return varchar2 is
begin
return
get_translated_string(string 		=> string,
                      appcode 		=> 'MSD',
                      p_token1  	=> null,
                      p_token1_value 	=> null,
                      p_token2 		=> null,
                      p_token2_value 	=> null,
                      p_token3 		=> null,
                      p_token3_value 	=> null);
end;

/*
  Get translated message
*/
function get_translated_string(string 		varchar2,
                               appcode 		varchar2) return varchar2 is
begin
return
get_translated_string(string 		=> string ,
                      appcode 		=> appcode,
                      p_token1  	=> null,
                      p_token1_value 	=> null,
                      p_token2 		=> null,
                      p_token2_value 	=> null,
                      p_token3 		=> null,
                      p_token3_value 	=> null);
end;

/*
  Get translated message
*/
function get_translated_string(string 		varchar2,
                               appcode 		varchar2,
                               p_token1 	varchar2,
                               p_token1_value 	varchar2) return varchar2 is
begin
return
get_translated_string(string 		=> string ,
                      appcode 		=> appcode,
                      p_token1  	=> p_token1,
                      p_token1_value 	=> p_token1_value,
                      p_token2 		=> null,
                      p_token2_value 	=> null,
                      p_token3 		=> null,
                      p_token3_value 	=> null);
end;



/*
  Get translated message
*/
function get_translated_string(string 		varchar2,
                               appcode 		varchar2,
                               p_token1 	varchar2,
                               p_token1_value 	varchar2,
                               p_token2 	varchar2,
                               p_token2_value 	varchar2) return varchar2 is
begin
return
get_translated_string(string 		=> string ,
                      appcode 		=> appcode,
                      p_token1  	=> p_token1,
                      p_token1_value 	=> p_token1_value,
                      p_token2 		=> p_token2,
                      p_token2_value 	=> p_token2_value,
                      p_token3 		=> null,
                      p_token3_value 	=> null);
end;



/*
  Get translated message
*/
function get_translated_string(string varchar2,
                               appcode varchar2,
                               p_token1 varchar2,
                               p_token1_value varchar2,
                               p_token2 varchar2,
                               p_token2_value varchar2,
                               p_token3 varchar2,
                               p_token3_value varchar2) return varchar2 is
begin

  fnd_message.set_name(appcode, string);

  /* set message tokens */
  if p_token1 is not null then
    fnd_message.set_token(p_token1, p_token1_value);
  end if;
  if p_token2 is not null then
    fnd_message.set_token(p_token2, p_token2_value);
  end if;
  if p_token3 is not null then
    fnd_message.set_token(p_token3, p_token3_value);
  end if;

  return fnd_message.get;

  exception
    when others then
      return string;

end get_translated_string;


/*
  Returns 0 if p_sr_pk is a valid source level pk for the
  given level_id and instance, -1 otherwise
*/
function is_valid_sr_pk(p_sr_pk varchar2, p_level_id number, p_instance varchar2) return varchar2 is
  v_count number;
begin
  select count(*)
  into v_count
  from msd_level_values
  where level_id = p_level_id
    and instance = p_instance
    and sr_level_pk = p_sr_pk;


  if (v_count > 0) then
    return 0; /*ok*/
  else
    return -1; /*error*/
  end if;

end is_valid_sr_pk;


end;

/
