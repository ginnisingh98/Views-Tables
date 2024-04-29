--------------------------------------------------------
--  DDL for Package Body PY_AUDIT_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_AUDIT_REP_PKG" as
/* $Header: pyadyn.pkb 120.1.12000000.2 2007/02/28 06:13:32 ckesanap noship $ */
--
-- flemonni bug 630622
--
-- specific exception required for size of sql parse string
--
-- logic behind revision:  all of the _text? variables expanded
-- to accommodate possible large values (origin of bug 630622 was that
-- one variable was too small) so that only the overall length raises
-- an error if length  > 32K.
--
 g_parse_string_too_big	EXCEPTION;
 g_audit_table		VARCHAR2 (100);
--
procedure py_audit_rep_proc
 (p_table       in varchar2,
  p_primary     in varchar2,
  p_session_id  in number,
  p_start_date  in varchar2,
  p_end_date    in varchar2,
  p_username    in varchar2,
  p_table_type  in varchar2)
is
--
error_message                 varchar2(100);
--
-- datetrack text varchars for use in building dynamic cursor text
--
dt_text1                      varchar2(32000);
dt_text2                      varchar2(32000);
dt_text3                      varchar2(32000);
dt_text4                      varchar2(32000);
dt_text5                      varchar2(32000);
dt_text6                      varchar2(32000);
dt_text7                      varchar2(32000);
dt_text8                      varchar2(32000);
dt_text9                      varchar2(32000);
dt_text10                     varchar2(32000);
dt_text11                     varchar2(32000);
dt_text12                     varchar2(32000);
dt_text12a                    varchar2(32000);
dt_text12b                    varchar2(32000);
dt_text13a                    varchar2(32000);
dt_text13                     varchar2(32000);
dt_text14                     varchar2(32000);
--
-- non-datetrack text varchars for use in building dynamic cursor text
--
ndt_text1                     varchar2(32000);
ndt_text2                     varchar2(32000);
ndt_text3                     varchar2(32000);
ndt_text4                     varchar2(32000);
ndt_text5                     varchar2(32000);
ndt_text6                     varchar2(32000);
ndt_text7                     varchar2(32000);
ndt_text8                     varchar2(1);  -- not used ?
ndt_text9                     varchar2(1);  -- not used ?
ndt_text10                    varchar2(32000);
ndt_text11                    varchar2(32000);
ndt_text12                    varchar2(32000);
ndt_text13                    varchar2(32000);
ndt_text14                    varchar2(32000);
ndt_text15                    varchar2(32000);
ndt_text16                    varchar2(32000);
ndt_text17                    varchar2(32000);
ndt_text18                    varchar2(32000);
ndt_text19                    varchar2(32000);
ndt_text20                    varchar2(32000);
ndt_text21                    varchar2(32000);
--
-- procedure cursor variables
--
-- datetrack cursor
--
dt_proc_cursor                integer;
dt_proc_cursor_text           varchar2(32767);
dt_proc_rows                  integer;
--
-- non datetrack cursor variables
--
ndt_proc_cursor               integer;
ndt_proc_cursor_text          varchar2(32767);
ndt_proc_rows                 integer;
--
-- loop variable
--
t_loop_count                  integer;
--
-- column_details cursor variables
--
t_column_name                 varchar2(30);
t_column_id                   number;
t_column_type                 varchar2(1);
t_column_width                number;
--
l_result boolean;
l_prod_status    varchar2(1);
l_industry       varchar2(1);
l_oracle_schema  varchar2(30);
l_appl_short_name varchar2(50);
l_dummy          number(1);
--
-- column_curs cursor to retrieve column related information from column tables
--
cursor column_curs is
select a.column_name,
       a.column_id,
       a.column_type,
       a.width
from   fnd_columns       a,
       fnd_audit_columns b,
       fnd_tables        c
where  b.table_id      = a.table_id
and    b.table_id      = c.table_id
and    c.table_name    = P_TABLE
and    b.column_id     = a.column_id
and    b.table_app_id  = a.application_id
and    b.schema_id    <> -1
and    a.column_name  <> P_PRIMARY
and    a.column_name  <> 'EFFECTIVE_START_DATE'
and    a.column_name  <> 'EFFECTIVE_END_DATE'
order by sequence_id;
--
-- cursor to check that audit table exists
--
cursor csr_chk_tabname(p_table_name varchar2, p_oracle_schema varchar2) is
select 1
from   dual
where  exists (
    select 1
    from   all_tables tab
    where  tab.table_name  = p_table_name
    and    tab.owner       = p_oracle_schema
    );
--
begin
--
--  Confirm that Audit objects have been created for the table
--
 select fa.application_short_name
 into   l_appl_short_name
 from   fnd_application  fa,
        fnd_tables       ft
 where  ft.table_name = P_TABLE
 and    fa.application_id = ft.application_id;

 l_result := fnd_installation.get_app_info ( l_appl_short_name,
                                 l_prod_status,
                                 l_industry,
                                 l_oracle_schema );
 --
 open csr_chk_tabname(substr(P_TABLE,1,24)||'_A',l_oracle_schema);
 fetch csr_chk_tabname into l_dummy;
 if csr_chk_tabname%notfound Then
   close csr_chk_tabname;
   hr_utility.set_message(800, 'HR_34865_NO_AUDIT_TABLE');
   hr_utility.set_message_token('AUDIT_TABLE',substr(P_TABLE,1,24)||'_A');
   hr_utility.set_message_token('BASE_TABLE',P_TABLE);
   hr_utility.raise_error;
 end if;
 close csr_chk_tabname;
--
-- DATETRACK TABLE OPERATIONS
--
if p_table_type = 'DT' then
  --
  -- assignments of procedure cursor text
  --
  --  l_err     error handling
  --  l_trans   datetrack_transaction
  --  l_tstamp  audit_timestamp
  --  l_type    audit_transaction_type
  --  l_uname   audit_user_name
  --  l_sess    audit_session_id
  --  l_comm    audit_commit_id
  --  l_seq     audit_sequence_id
  --  l_nulls   audit_true_nulls
  --  l_pkval   primary_key_value
  --  l_sd      effective_start_date
  --  l_ed      effective_end_date
  --  l_audit   audit_id from NEXTVAL
  --  l_stat    procedure ..._VP status return
  --  l_grkey_cur current group key (primary key||session_id||commit_id)
  --  l_grkey_prv previous group key
  --
  -- DT TEXT 1
  --
  dt_text1:= 'declare l_err varchar2(100);'    ||
                     'l_trans varchar2(40);'   ||
                     'l_tstamp date;'          ||
                     'l_type varchar2(1);'     ||
                     'l_uname varchar2(100);'  ||
                     'l_sess number;'          ||
                     'l_comm number;'          ||
                     'l_seq number;'           ||
                     'l_nulls varchar2(250);'  ||
                     'l_pkval number;'         ||
                     'l_sd date;'              ||
                     'l_ed date;'              ||
                     'do_alt boolean;'         ||
                     'do_proc boolean;'        ||
                     'do_ass boolean;'         ||
                     'do_ins boolean;'         ||
                     'do_dates boolean;'       ||
                     'do_comp boolean;'        ||
                     'do_nass boolean;'        ||
                     'o_sd date;'              ||
                     'o_ed date;'              ||
                     'n_sd date;'              ||
                     'n_ed date;'              ||
                     'n_type varchar2(1);'     ||
                     'st_sd varchar2(40);'     ||
                     'st_ed varchar2(40);'     ||
                     't_sd date;'              ||
                     't_ed date;'              ||
                     'a_sd date;'              ||
                     'a_ed date;'              ||
                     'l_stat varchar2(40);'    ||
                     'l_audit number;'         ||
                     'l_grkey_cur varchar2(200);' ||
                     'l_grkey_prv varchar2(200);' ||
                     'dct number;'             ||
                     'ict number;'             ||
                     'D1 number;'              ||
                     'D2 number;'              ||
                     'D3 number;'              ||
                     'D4 number;'              ||
		     --
                     -- added for multiple changes
		     --
		     'o_dt_start date;'        ||
		     'o_dt_end date;'          ||
		     'multiple_start_flag boolean;' ||
		     'multiple_end_flag boolean;';
		     --
  --
  -- DT TEXT 5
  --
  dt_text5:= 'cursor dt_curs is select '              ||
              '{DT_TABLE}_TT(audit_session_id,'       ||
                            'audit_commit_id,'        ||
                            '{DT_PRIMARY}),'          ||
                            'audit_timestamp,'        ||
                            'audit_transaction_type,' ||
                            'audit_user_name,'        ||
                            'audit_session_id,'       ||
                            'audit_commit_id,'        ||
                            'audit_sequence_id,'      ||
                            'audit_true_nulls,'       ||
                            '{DT_PRIMARY},'           ||
                            'effective_start_date,'   ||
                            'effective_end_date ';
  --
  dt_text5 := replace(dt_text5, '{DT_TABLE}', substr(P_TABLE,1,24));
  dt_text5 := replace(dt_text5, '{DT_PRIMARY}', P_PRIMARY);
  --
  -- DT TEXT 6
  --
  dt_text6 := ' from {DT_TABLE}_A '                        ||
              'where audit_timestamp >= '                  ||
              'to_date(''' || P_START_DATE                 ||
              ''',''DD-MM-YYYY HH24:MI'') '                ||
              'and audit_timestamp   < '                   ||
              'to_date(''' || P_END_DATE                   ||
              ''',''DD-MM-YYYY HH24:MI'') '                ||
              'and audit_user_name like ''' || P_USERNAME  ||
              ''' order by {DT_PRIMARY}'    ||
              --
              -- datetrack function for checking varchar2 differences
              --
              'function dv(pa in varchar2,'               ||
                             'pb in varchar2,'            ||
                             'pp in number)'              ||
              'return boolean is result boolean:=false;'  ||
              'begin '                                    ||
              'IF pa IS NOT NULL AND pb IS NOT NULL AND pa<>pb '        ||
              'THEN result:=true;END IF;'                 ||
              'IF pa IS NULL AND pb IS NOT NULL AND '     ||
              '((l_nulls IS NOT NULL AND SUBSTR(l_nulls,pp+3,1)=''Y'') '||
              'OR (l_nulls IS NULL AND l_type=''I'')) '   ||
              'THEN result:=true;END IF;'                 ||
              'IF pa IS NOT NULL AND pb IS NULL  '        ||
              'THEN result:=true;END IF;'                 ||
              'RETURN result;'                            ||
              'end dv;'                                   ||
              --
              -- datetrack function for checking number differences
              --
              'function dn(pa in number,'                 ||
                             'pb in number,'              ||
                             'pp in number)'              ||
              'return boolean is result boolean:=false;'  ||
              'begin '                                    ||
              'IF pa IS NOT NULL AND pb IS NOT NULL AND pa<>pb '         ||
              'THEN result:=true;END IF;'                 ||
              'IF pa IS NULL AND pb IS NOT NULL AND '     ||
              '((l_nulls IS NOT NULL AND SUBSTR(l_nulls,pp+3,1)=''Y'') ' ||
              'OR (l_nulls IS NULL AND l_type=''I'')) '   ||
              'THEN result:=true;END IF;'                 ||
              'IF pa IS NOT NULL AND pb IS NULL '         ||
              'THEN result:=true;END IF;'                 ||
              'RETURN result;'                            ||
              'end dn;'                                   ||
              --
              -- datetrack insert procedure for the hr_audits_columns table
              --
              -- cid      column_id
              -- cn       column_name
              -- ov       old value
              -- nv       new value
              -- lov      local old value
              -- lnv      local new value
              -- varchar2 format
              --
              'procedure ins(cid in number,'              ||
                            'cn in varchar2,'             ||
                            'ov in varchar2,'             ||
                            'nv in varchar2)is '          ||
              'lov varchar2(240);lnv varchar2(240);'      ||
              'l_cid number;l_cn varchar2(240);'          ||
              'BEGIN '                                    ||
              'IF cid IS NULL THEN l_cid:=0;'             ||
              'ELSE l_cid:=cid;END IF;'                   ||
              'IF cn IS NULL THEN l_cn:=''***'' || '      ||
              ' to_char(l_cid);ELSE l_cn:=cn;END IF;'     ||
              'lov:=ov;lnv:=nv;'                          ||
              'if ov=''31-12-4712'' then '                ||
              'lov:=''** END OF TIME **'';end if;'        ||
              'if nv=''31-12-4712'' then '                ||
              'lnv:=''** END OF TIME **'';end if;'        ||
              'insert into hr_audit_columns'              ||
              '(audit_id,column_id,column_name,old_value,new_value)' ||
              'values(hr_audits_s.currval,'               ||
              'l_cid,'                                    ||
              'l_cn,'                                     ||
              'lov,lnv);'                                 ||
              ' exception when others then null;raise;'   ||
              'end ins;'                                  ||
              --
              -- number format
              --
              'procedure ins(cid in number,'              ||
                            'cn in varchar2,'             ||
                            'ov in number,'               ||
                            'nv in number)is '            ||
              'begin ins(cid,cn,to_char(ov),to_char(nv));'||
              'end ins;'                                  ||
              --
              -- date format
              --
              'procedure ins(cid in number,'              ||
                            'cn in varchar2,'             ||
                            'ov in date,'                 ||
                            'nv in date)is '              ||
              'begin ins(cid,cn,to_char(ov,''DD-MM-YYYY''),' ||
              'to_char(nv,''DD-MM-YYYY''));'              ||
              'end ins;'                                  ||
              --
              'begin '                                    ||
              'select hr_audits_s.nextval into '          ||
              'l_audit from dual;'                        ||
              'open dt_curs;'                             ||
              'loop '                                     ||
              'fetch dt_curs into l_trans,'               ||
                                 'l_tstamp,'              ||
                                 'l_type,'                ||
                                 'l_uname,'               ||
                                 'l_sess,'                ||
                                 'l_comm,'                ||
                                 'l_seq,'                 ||
                                 'l_nulls,'               ||
                                 'l_pkval,'               ||
                                 'l_sd,'                  ||
                                 'l_ed';
  --
  dt_text6 := replace(dt_text6, '{DT_TABLE}', substr(P_TABLE,1,24));
  --
  dt_text6 := replace(dt_text6,'{DT_PRIMARY}',
         ' 9 ASC,5 ASC,6 ASC,3 DESC,10 ASC,11 ASC;');
  --  9 responds to primary key
  --  5 responds to session id
  --  6 responds to commit id
  --  3 responds to audit transaction type
  -- 10 responds to effective start date
  -- 11 responds to effective end date
  --
  -- DT TEXT 7
  --
  dt_text7 := 'if dt_curs%notfound then '                           ||
              'close dt_curs;exit;end if;'                          ||
              'l_grkey_cur:=to_char(l_pkval)||to_char(l_sess)|| '   ||
              'to_char(l_comm);'                                    ||
              'dbms_output.put_line(l_grkey_cur);' ||
              'if l_grkey_prv IS NULL or l_grkey_prv<>l_grkey_cur ' ||
              'then  l_stat:=''ERROR''; ';
  --
  -- DT TEXT 9
  --
  -- initialization for each new group
  dt_text9:=  'a_sd:=null;a_ed:=null;'               ||
              't_sd:=null;t_ed:=null;'               ||
              'st_sd:=null;st_ed:=null;'             ||
              'n_type:=null;'                        ||
              'dct:=0;ict:=0;'                       ||
              'D1:=1;D2:=2;D3:=3;D4:=4;'             ||
	      'o_dt_start:=null; '                   ||
	      'o_dt_end:=null;'                      ||
     	      'multiple_start_flag:=false;'          ||
	      'multiple_end_flag:=false;'            ||
              'end if;'                              ||
  -- end of initialization for each new group
  -- initialization for each row in a group
              'do_proc:=false;'                      ||
              'do_ass:=false;'                       ||
              'do_ins:=false;'                       ||
              'do_dates:=false;'                     ||
              'do_alt:=false;'                       ||
              'do_comp:=false;'                      ||
              'do_nass:=false;'                      ||
              'o_sd:=null;o_ed:=null;'               ||
              'n_sd:=null;n_ed:=null;'               ||
              'n_type:=null;';

  -- end of initialization for each row
  --
  -- DT TEXT 10
  -- datetrack transaction logic
  --
              -- dt first insert logic
              --
  dt_text10:= 'if l_trans=''FIRST_INSERT'' then '          ||
              'do_ins:=true;do_comp:=true;'                ||
              'do_alt:=false;do_dates:=true;'              ||
              'do_ass:=true;do_proc:=true;do_nass:=false;' ||
              'n_sd:=l_sd;'                                ||
              'n_ed:=l_ed;'                                ||
              --
              -- dt correction logic
              --
              'elsif l_trans=''CORRECTION'' then '         ||
              'do_ins:=true;do_comp:=true;'                ||
              'do_alt:=false;do_dates:=true;'              ||
              'do_ass:=true;do_proc:=true;do_nass:=false;' ||
              'n_sd:=l_sd;'                                ||
              'n_ed:=l_ed;'                                ||
              --
              -- dt update/update change insert logic
              --
              'elsif l_trans in(''UPDATE'',''UPDATE_CHANGE_INSERT'')then '||
              'if l_type=''I'' then '                      ||
              'ict:=ict+1;'                                ||
              'if t_sd is null then '                      ||
              't_sd:=l_sd;t_ed:=l_ed;'                     ||
              'elsif t_sd is not null then '               ||
              'if l_sd > t_sd then '                       ||
              'n_sd:=l_sd;n_ed:=l_ed;'                     ||
              'o_sd:=t_sd;o_ed:=t_ed;'                     ||
              'else n_sd:=t_sd;n_ed:=t_ed;'                ||
              'o_sd:=l_sd;o_ed:=l_ed;'                     ||
              'end if;'                                    ||
              'end if;'                                    ||
              'if ict=1 then '                             ||
              'do_ins:=false;do_comp:=false;'              ||
              'do_alt:=false;do_dates:=false;'             ||
              'do_ass:=false;do_proc:=true;do_nass:=false;'||
              'end if;'                                    ||
              'if ict=2 then '                             ||
              'do_ins:=true;do_comp:=false;'               ||
              'do_alt:=false;do_dates:=true;'              ||
              'do_ass:=false;do_proc:=true;do_nass:=false;'||
              'end if;'                                    ||
              'elsif l_type=''D'' then '                   ||
              'dct:=dct+1;'                                ||
              'a_sd:=l_sd;a_ed:=l_ed;'                     ||
              'st_sd:=''Former From Date'';'               ||
              'st_ed:=''Former To Date'';'                 ||
              'do_ins:=false;do_comp:=true;'               ||
              'do_alt:=true;do_dates:=false;'              ||
              'do_ass:=true;do_proc:=false;do_nass:=false;'||
              'end if;'                                    ||
              --
              -- dt change hire date logic
              --
          'elsif l_trans=''CHANGE_HIRE_DATE'' then ' ||
              'if l_type =''I'' then '               ||
              'ict:=ict+1;'                          ||
              't_sd:=l_sd;t_ed:=l_ed;'               ||
              'a_sd:=l_sd;a_ed:=l_ed;'               ||
              'do_ins:=false;do_comp:=false;'        ||
              'do_alt:=false;do_dates:=false;'       ||
              'do_ass:=false;do_proc:=false;do_nass:=false;' ||
              'elsif l_type =''D'' then '            ||
              'dct:=dct+1;'                          ||
              'o_sd:=l_sd;o_ed:=l_ed;'               ||
              'n_sd:=a_sd;n_ed:=a_ed;'               ||
              'if dct=1 then '                       ||
              'do_ins:=true;do_comp:=true;'          ||
              'do_alt:=false;do_dates:=true;'        ||
              'do_ass:=true;do_proc:=false;do_nass:=false;'  ||
              'end if; '                             ||
              'if dct>1 then '                       ||
              'do_ins:=true;do_comp:=true;'          ||
              'do_alt:=false;do_dates:=true;'        ||
              'do_ass:=true;do_proc:=false;do_nass:=false;'  ||
              'end if;'                              ||
              'end if;'                              ||
              --
              -- dt reverse termination logic
              --
          'elsif l_trans=''REVERSE_TERMINATION'' then '      ||
              'if l_type =''I'' then '               ||
              'ict:=ict+1;'                          ||
              'do_ins:=false;do_comp:=false;'        ||
              'do_alt:=false;do_dates:=false;'       ||
              'do_ass:=false;do_proc:=false;do_nass:=false;' ||
              'elsif l_type =''D'' then '            ||
              'dct:=dct+1;'                          ||
              'o_sd:=l_sd;o_ed:=l_ed;'               ||
              'if dct=1 then '                       ||
              'do_ins:=false;do_comp:=false;'        ||
              'do_alt:=false;do_dates:=false;'       ||
              'do_ass:=true;do_proc:=false;do_nass:=true;'   ||
              'end if;'                              ||
              'if dct=2 then '                       ||
              'n_sd:=a_sd;n_ed:=a_ed;'               ||
              'do_ins:=false;do_comp:=true;'         ||
              'do_alt:=false;do_dates:=true;'        ||
              'do_ass:=false;do_proc:=false;do_nass:=true;'  ||
              'end if;'                              ||
              'elsif l_type =''U'' then '            ||
              'a_sd:=l_sd;a_ed:=l_ed;'               ||
              'do_ins:=true;do_comp:=false;'         ||
              'do_alt:=false;do_dates:=false;'       ||
              'do_ass:=false;do_proc:=false;do_nass:=false;' ||
              'end if;'                              ||
              --
              -- dt delete next change/future change logic
              --
              -- VT 02/06/96 changed options for Forms 2.3
              -- cancellation of termination.
              -- previous options were :
              -- I do_proc:=false;
              -- D first do_ins:=true;do_comp:=true;do_dates:=true;
              --         do_ass:=true;

/* Bug 5277170 logic changes for 'Delete Next' : The if condition (dct>1) was changed
 to (dct>0) thus eliminating the need for the if condition (dct=1). This change will
 affect all the Delete transactions to appear on the Audit Report with appripriate old and
 new dates. This logic holds good for 'Future Change' transaction also. */

          'elsif l_trans in(''DELETE_NEXT_CHANGE'',''FUTURE_CHANGE'') then ' ||
              'if l_type =''I'' then '               ||
              'ict:=ict+1;'                          ||
              't_sd:=l_sd;t_ed:=l_ed;'               ||
              'do_ins:=false;do_comp:=false;'        ||
              'do_alt:=false;do_dates:=false;'       ||
              'do_ass:=false;do_proc:=true;do_nass:=false;'  ||
              'elsif l_type =''D'' then '            ||
              'dct:=dct+1;'                          ||
              'o_sd:=l_sd;o_ed:=l_ed;'               ||
        /*    'if dct=1 then '                       ||
              'do_ins:=false;do_comp:=false;'        ||
              'do_alt:=false;do_dates:=false;'       ||
              'do_ass:=false;do_proc:=false;do_nass:=false;' ||
              'end if;'                              ||   */
              'if dct>0 then '                       ||      -- bug 5277170
              'do_ins:=true;do_comp:=true;'          ||
              'do_alt:=false;do_dates:=true;'        ||
              'do_ass:=true;do_proc:=false;do_nass:=false;'  ||
              'end if;'                              ||
              'if l_sd=t_sd then '                   ||
              'n_sd:=t_sd;n_ed:=t_ed;'               ||
              'do_comp:=false;'                      ||
              'else n_sd:=null;n_ed:=null;'          ||
              'end if;end if;'                       ||
              --
              -- dt zap logic
              --
              'elsif l_trans=''ZAP'' then '                  ||
              'dct:=dct+1;'                                  ||
              'o_sd:=l_sd;o_ed:=l_ed;'                       ||
              'do_ins:=true;do_comp:=true;'                  ||
              'do_alt:=false;do_dates:=true;'                ||
              'do_ass:=true;do_proc:=false;do_nass:=false;'  ||
              --
              -- dt delete logic
              --
/* Bug 5277170 logic changes for 'Delete'(End Date) : In 'I' transaction type, t_sd and t_ed
 are being initialised to make sure appropriate new start and end dates appear in the
 audit report. The n_sd and n_ed need not be intialised in 'I' type as they are being assigned
 t_sd and t_ed in 'D' type. Hence two statements have been commented. */

              'elsif l_trans=''DELETE'' then '       ||
              'if l_type= ''I'' then '               ||
              'ict:=ict+1;'                          ||
       --     'n_sd:=l_sd;n_ed:=l_ed;'               ||      -- bug 5277170
              't_sd:=l_sd;t_ed:=l_ed;'               ||
              'elsif l_type=''D'' then '             ||
              'dct:=dct+1;'                          ||
              'o_sd:=l_sd;o_ed:=l_ed;'               ||
              'if l_sd<>t_sd then '                  ||
              'n_sd:=null;n_ed:=null;'               ||
              'elsif l_sd=t_sd then '                ||
              'n_sd:=t_sd;n_ed:=t_ed;end if;'        ||
              'do_ins:=true;do_comp:=true;'          ||
              'do_alt:=false;do_dates:=true;'        ||
              'do_ass:=true;do_proc:=false;do_nass:=false;' ||
              'end if;'                              ||
              --
              -- dt update override logic
              --
/* Bug 5277170 logic changes for 'Update Override' : After 'I' type, 'TABLE_NAME'_VP procedure
is called to update the new values of all the audit columns to which n_sd and n_ed are sent as
parameters. In the two 'I' type transactions for 'Update Override', n_sd and n_ed were null before.
Now, they are being assigned appropriate values so that all the audit columns' values are updated.
Also, do_comp is assigned 'false' in the if (l_sd=t_sd) condition in 'D' type. */

              'elsif l_trans=''UPDATE_OVERRIDE'' then '     ||
              'if l_type=''I'' then '                       ||
              'ict:=ict+1;'                                 ||
              'if t_sd is null then '                       ||
              't_sd:=l_sd;t_ed:=l_ed;'                      ||
              'do_ins:=false;do_comp:=false;'               ||
              'do_alt:=false;do_dates:=false;'              ||
              'do_ass:=false;do_proc:=true;do_nass:=false;' ||
              'elsif t_sd is not null and l_sd > t_sd '     ||
              'then a_sd:=l_sd;a_ed:=l_ed;'                 ||
	      'n_sd:=l_sd;n_ed:=l_ed;'                      ||  -- bug 5277170
              'do_ins:=false;do_comp:=false;'               ||
              'do_alt:=false;do_dates:=false;'              ||
              'do_ass:=false;do_proc:=true;do_nass:=false;' ||
              'end if;'                                     ||
              'elsif l_type=''D'' then '                    ||
              'dct:=dct+1;'                                 ||
              'if l_sd=t_sd then '                          ||
              'do_ins:=true;do_comp:=false;'                ||  -- bug 5277170
              'do_alt:=false;do_dates:=true;'               ||
              'do_ass:=true;do_proc:=false;do_nass:=false;' ||
              'o_sd:=l_sd;o_ed:=l_ed;'                      ||
              'n_sd:=t_sd;n_ed:=t_ed;'                      ||
              'else '                                       ||
              'do_ins:=true;do_comp:=true;'                 ||
              'do_alt:=false;do_dates:=true;'               ||
              'do_ass:=true;do_proc:=false;do_nass:=false;' ||
              'o_sd:=l_sd;o_ed:=l_ed;'                      ||
              'n_sd:=a_sd;n_ed:=a_ed;'                      ||
              'end if;'                                     ||
              'end if;'                                     ||
	                    --
              -- Multiple changes logic
              --
              'elsif l_trans in(''MULTIPLE_CHANGES'')then '||
              'if l_type=''I'' then '                      ||
	      'if o_dt_start is null then '                ||
	      'o_dt_start := l_sd; '                       ||
	      'o_dt_end := l_ed; '                         ||
	      'multiple_start_flag := true; '              ||
	      'multiple_end_flag := true; '                ||
	      'elsif l_sd > o_dt_end then '                ||
	      'o_dt_start := l_sd; '                       ||
	      'o_dt_end := l_ed; '                         ||
	      'multiple_end_flag := true; '                ||
	      'end if; '                                   ||
              'if (multiple_start_flag=true and multiple_end_flag=true) then ' ||
              'multiple_end_flag:=false;'          ||
              'do_ins:=true;do_comp:=true;'                ||
              'do_alt:=false;do_dates:=true;'             ||
              'do_ass:=false;do_proc:=true;do_nass:=false;'||
              'end if; '                                   ||
              'end if; '                                   ||

              --
              -- Error returned by ..._TT function
              --
              'elsif l_trans=''ERROR - Not a DateTrack Transaction'' then ' ||
              'l_trans:=SUBSTR(l_trans,1,30);'              ||
              'ict:=ict+1;'                                 ||
              'if ict=1 then '                              ||
              'do_ins:=true;do_comp:=true;'                 ||
              'do_alt:=false;do_dates:=false;'              ||
              'do_ass:=true;do_proc:=false;do_nass:=false;' ||
              'end if;'                                     ||
              'end if;if do_ass then ';
  --
  --
  -- DT TEXT 12
  -- special dt correction logic
  --
  dt_text12:= 'end if;if do_proc then '                     ||
              'if l_trans=''CORRECTION'' then '             ||
              'n_type:=''U'';'                              ||
              'else n_type:=''I'';'                         ||
              'end if;';

              --
              -- Call the datetrack specific procedure <TABLE_NAME>_F_VP
              --
--   dt_text12a:='if (l_trans=''MULTIPLE_CHANGES''  and '||
--	      '(multiple_start_flag=true and multiple_end_flag=true)) then '  ||
--              '{DT_TABLE}_VP(l_sess,l_comm,l_pkval,'        ||
--              'o_dt_start,o_dt_end,n_type,l_trans,l_tstamp,l_nulls,l_stat ';

 dt_text12a:='if (l_trans=''MULTIPLE_CHANGES'') then '||
              '{DT_TABLE}_VP(l_sess,l_comm,l_pkval,'        ||
              'o_dt_start,o_dt_end,n_type,l_trans,l_tstamp,l_nulls,l_stat ';

   dt_text12b:='else '||
               'if l_stat<>''OK'' then '                  ||
              '{DT_TABLE}_VP(l_sess,l_comm,l_pkval,'        ||
              'n_sd,n_ed,n_type,l_trans,l_tstamp,l_nulls,l_stat ';


  --
  dt_text12a := REPLACE(dt_text12a, '{DT_TABLE}', substr(P_TABLE,1,24));
  dt_text12b := REPLACE(dt_text12b, '{DT_TABLE}', substr(P_TABLE,1,24));
  --
  -- DT TEXT 13
  -- evaluation of operations and inserting into the hr_audits_table
  --
  dt_text13a:= 'end if;'                                    ||
              'if do_nass then ';
  dt_text13:= 'if do_ins then '                             ||
              --
              -- insert transaction details into the hr_audits table
              --
              'begin '                                                  ||
              'insert into hr_audits '                                  ||
              '(audit_id,commit_id,current_session_id,primary_key,'     ||
              'primary_key_value,sequence_id,session_id,table_name,'    ||
              'timestamp,transaction,transaction_type,user_name,'       ||
              'effective_end_date,effective_start_date)'                ||
              'values '                                                 ||
              '(hr_audits_s.nextval,l_comm,''' || to_char(p_session_id) ||
              ''',''' || p_primary || ''',l_pkval, l_seq, l_sess'       ||
              ',''' || p_table || ''',l_tstamp,l_trans,l_type,l_uname,' ||
              'l_ed,l_sd);'                                             ||
              ' exception when others then null;raise;'                 ||
              'end;'                                                    ||
              'end if;'                                                 ||
              'if do_alt then '                                         ||
              'ins(1, st_sd, to_char(a_sd,''DD-MM-YYYY''),null);'       ||
              'ins(2, st_ed, to_char(a_ed,''DD-MM-YYYY''),null);'       ||
              'end if;'                                                 ||
              'if do_dates then '                                       ||
	      'if (l_trans=''MULTIPLE_CHANGES'') then '                 ||
	      'ins(3,''From Date'',null,to_char(o_dt_start,''DD-MM-YYYY''));'||
              'ins(4,''To Date'',null,to_char(o_dt_end,''DD-MM-YYYY''));'||
              'else  '                                                  ||
              'ins(3,''From Date'',to_char(o_sd,''DD-MM-YYYY''),'       ||
              'to_char(n_sd,''DD-MM-YYYY''));'                          ||
              'ins(4,''To Date'',to_char(o_ed,''DD-MM-YYYY''),'         ||
              'to_char(n_ed,''DD-MM-YYYY''));'                          ||
	      'end if;'                                                 ||
              'end if;if do_comp then ';
  --
  -- DT TEXT 14
  -- commit operations and exception handling
  --
  dt_text14:= 'end if;commit;l_grkey_prv:=l_grkey_cur;end loop;exception ' ||
              'when others then close dt_curs;'               ||
              'hr_utility.set_location(''ERROR:''||'          ||
              'to_char(dbms_sql.last_sql_function_code),00);' ||
              'hr_utility.set_location(''ERROR:''||'          ||
              'to_char(dbms_sql.last_error_position),00);'    ||
              'l_err:=hr_utility.get_message;'                ||
              'hr_utility.trace(l_err);'                      ||
              'raise;end;';
  --
  -- open the column_curs cursor fetching in column information and
  -- building up the dynamic text for each column
  --
  open column_curs;
  --
  -- initialise loop counter
  --
  t_loop_count := 0;
  --
  loop
    --
    -- fetch column information
    --
    hr_utility.set_location('py_audit_rep_pkg.py_audit_rep_proc',10);
    fetch column_curs into   t_column_name,
                             t_column_id,
                             t_column_type,
                             t_column_width;
    if column_curs%notfound then
      close column_curs;
      exit;
    end if;
    --
    -- increment the count
    --
    t_loop_count := t_loop_count + 1;
    --
    -- build up cursor text using the column details retrieved
    --
   dt_text2 := dt_text2 || 'L' || to_char(t_loop_count);
   dt_text3 := dt_text3 || 'O' || to_char(t_loop_count);
   dt_text4 := dt_text4 || 'N' || to_char(t_loop_count);
   dt_text13a := dt_text13a || 'N'    || to_char(t_loop_count) || ':=O' ||
                to_char(t_loop_count) || ';O'  || to_char(t_loop_count) ||
                ':=L' || to_char(t_loop_count) || ';';
    --
    -- special logic for varchar2 columns over the length of 240
    --
    if t_column_type = 'V' and t_column_width > 240 then
      dt_text5:= dt_text5 || ',substr(' || t_column_name || ',1,240)';
    else
      dt_text5:= dt_text5 || ','  || t_column_name ;
    end if;
    --
    dt_text6  := dt_text6 || ',L' || to_char(t_loop_count);
    dt_text7  := dt_text7 || 'O'  || to_char(t_loop_count) || ':=null;';
    dt_text8  := dt_text8 || 'N'  || to_char(t_loop_count) || ':=null;';
    dt_text11 :=dt_text11 || 'O'  || to_char(t_loop_count) ||
                            ':=L' || to_char(t_loop_count) || ';';
    dt_text12a :=dt_text12a || ',N' || to_char(t_loop_count);
    dt_text12b :=dt_text12b || ',N' || to_char(t_loop_count);
    --
    -- date column logic
    --
    if t_column_type = 'D' then
      dt_text2  := dt_text2  || ' date;';
      dt_text3  := dt_text3  || ' date;';
      dt_text4  := dt_text4  || ' date;';
      dt_text13 := dt_text13 || 'if dv(to_char(O'   ||
                       to_char(t_loop_count)        ||
                       ',''DD-MM-YYYY''),to_char(N' ||
                       to_char(t_loop_count)        ||
                       ',''DD-MM-YYYY'')'           ||
                       ',' || to_char(t_loop_count) || ') ';
    --
    -- varchar2 column logic
    --
    elsif t_column_type = 'V' then
    if t_column_width >= 240  then
      dt_text2 := dt_text2 || ' varchar2(240);';
      dt_text3 := dt_text3 || ' varchar2(240);';
      dt_text4 := dt_text4 || ' varchar2(240);';
    else
      dt_text2 := dt_text2 || ' varchar2(' ||
                  to_char(t_column_width)  || ');';
      dt_text3 := dt_text3 || ' varchar2(' ||
                  to_char(t_column_width)  || ');';
      dt_text4 := dt_text4 || ' varchar2(' ||
                  to_char(t_column_width)  || ');';
    end if;
    dt_text13  := dt_text13 || 'if dv(O' || to_char(t_loop_count) ||
                                    ',N' || to_char(t_loop_count) ||
                                    ','  || to_char(t_loop_count) || ') ';
    --
    -- number column logic
    --
    elsif t_column_type = 'N' then
      dt_text2  := dt_text2  || ' number;';
      dt_text3  := dt_text3  || ' number;';
      dt_text4  := dt_text4  || ' number;';
      dt_text13 := dt_text13 || 'if dn(O' || to_char(t_loop_count) ||
                               ',N' || to_char(t_loop_count) ||
                               ','  || to_char(t_loop_count) || ') ';
    end if;
    dt_text13 := dt_text13 ||
                 ' then '  ||
                 'ins(' || t_column_id || ','''  || t_column_name || ''',' ||
                 'O'    || to_char(t_loop_count) || ',N' ||
                 to_char(t_loop_count) || ');end if;';
  end loop;
  --
  -- assign the ends of the text
  --
  dt_text12a   := dt_text12a  || ');';
  dt_text12b   := dt_text12b  || ');end if; end if;';
  dt_text6    := dt_text6   || ';';
  --
  -- if there were column cursor rows fetched, assign the ends of the text
  --
  if t_loop_count > 0 then
    dt_text13a  := dt_text13a || 'null; end if;';
  end if;
  --
  -- if there were no column cursor rows fetched, assign the primary key rules
  if t_loop_count = 0 then
    dt_text10   := dt_text10 || ' null;';
    dt_text13   := dt_text13 || ' null; end if;';
  end if;
    --
    -- CONCATENATE DATETRACK DYNAMIC SQL TEXT
    --
--
-- flemonni 630622
--
-- put this in its own block, so that if variable length is exceeded can raise
-- a specific error
--
    BEGIN
    hr_utility.set_location('py_audit_rep_pkg.py_audit_rep_proc',20);
    dt_proc_cursor_text := dt_text1   ||
                           dt_text2   ||
                           dt_text3   ||
                           dt_text4   ||
                           dt_text5   ||
                           dt_text6   ||
                           dt_text7   ||
                           dt_text8   ||
                           dt_text9   ||
                           dt_text10  ||
                           dt_text11  ||
                           dt_text12  ||
                           dt_text12a ||
                           dt_text12b ||
                           dt_text13a ||
                           dt_text13  ||
                           dt_text14;
    EXCEPTION
      WHEN OTHERS THEN
        g_audit_table := p_table;
        RAISE g_parse_string_too_big;
    END;
    --
    -- open parse and execute the dynamic sql cursor text
    --
    hr_utility.set_location('py_audit_rep_pkg.py_audit_rep_proc',30);
    dt_proc_cursor := dbms_sql.open_cursor;
    --
    hr_utility.set_location('py_audit_rep_pkg.py_audit_rep_proc',40);
    dbms_sql.parse(dt_proc_cursor, dt_proc_cursor_text, dbms_sql.v7);
    --
    hr_utility.set_location('py_audit_rep_pkg.py_audit_rep_proc',50);
    dt_proc_rows   := dbms_sql.execute(dt_proc_cursor);
    --
    hr_utility.set_location('py_audit_rep_pkg.py_audit_rep_proc',60);
    if dbms_sql.is_open(dt_proc_cursor) then
      dbms_sql.close_cursor(dt_proc_cursor);
     end if;
    --
    -- commit all transactions
    --
    commit;
--
-- NON-DATETRACK TABLE OPERATIONS
--
elsif p_table_type = 'NDT' then
  --
  -- assignments of procedure cursor text
  --
  --  l_trans   non-datetrack_transaction
  --  l_tstamp  audit_timestamp
  --  l_type    audit_transaction_type
  --  l_uname   audit_user_name
  --  l_nulls   audit_true_nulls
  --  l_sess    audit_session_id
  --  l_comm    audit_commit_id
  --  l_seq     audit_sequence_id
  --  l_pkval   primary_key_value current
  --  l_prev_pk primary_key_value previous
  --  l_hist    history_check_field
  --
  -- NDT TEXT 1
  --
  ndt_text1 := 'declare l_err varchar2(100);'    ||
                       'l_trans varchar2(40);'   ||
                       'l_tstamp date;'          ||
                       'l_type varchar2(1);'     ||
                       'l_uname varchar2(100);'  ||
                       'l_nulls varchar2(250);'  ||
                       'l_sess number;'          ||
                       'l_comm number;'          ||
                       'l_seq number;'           ||
                       'l_hist varchar2(40);'    ||
                       'l_prev_pk number;'       ||
                       'l_pkval number;'         ||
                       'l_audit number;';
  --
  -- NDT TEXT 4
  --
  ndt_text4 := 'cursor ndt_curs is select '      ||
                       'audit_timestamp,'        ||
                       'audit_transaction_type,' ||
                       'audit_user_name,'        ||
                       'audit_true_nulls,'       ||
                       'audit_session_id,'       ||
                       'audit_commit_id,'        ||
                       'audit_sequence_id,'      ||
                       '{NDT_PRIMARY} ';
  --
  ndt_text4 := replace(ndt_text4, '{NDT_PRIMARY}', P_PRIMARY);
  --
  -- NDT TEXT 5
  --
  ndt_text5 := ' from {NDT_TABLE}_A '                       ||
               'where audit_timestamp >= '                  ||
               'to_date(''' || P_START_DATE                 ||
               ''',''DD-MM-YYYY HH24:MI'') '                ||
               'and audit_timestamp < '                     ||
               'to_date(''' || P_END_DATE                   ||
               ''',''DD-MM-YYYY HH24:MI'') '                ||
               'and audit_user_name like ''' || P_USERNAME  ||
               ''' order by {NDT_PRIMARY} asc,'             ||
               'audit_timestamp desc;'                      ||
               --
               -- nondatetrack insert procedure for the hr_audits_columns table
               --
               'procedure ins(c_id in number,'                 ||
                             'c_name in varchar2,'             ||
                             'o_val in varchar2,'              ||
                             'n_val in varchar2) is '          ||
               'l_c_id number;l_c_name varchar2(30);'          ||
               'BEGIN '                                        ||
               'IF c_id IS NULL THEN l_c_id:=0; '              ||
               'ELSE l_c_id:=c_id;END IF;'                     ||
               'IF c_name IS NULL THEN l_c_name:=''***'' || '  ||
               ' to_char(l_c_id);ELSE l_c_name:=c_name;END IF;'||
               'insert into hr_audit_columns '                 ||
               '(audit_id,column_id,column_name,old_value,new_value)' ||
               'values(hr_audits_s.currval,'                   ||
               'l_c_id,'                                       ||
               'l_c_name,'                                     ||
               'o_val,n_val);'                                 ||
               'exception when others then null;raise;'        ||
               'end;';
  --
  ndt_text5 := replace(ndt_text5, '{NDT_TABLE}', substr(P_TABLE,1,24));
  ndt_text5 := replace(ndt_text5, '{NDT_PRIMARY}', P_PRIMARY);
  --
  -- NDT TEXT 6
  -- define procedure for obtaining new values in non datetrack mode
  --
  ndt_text6 := ' procedure hist_values (P_{NDT_PRIMARY} in out number,' ||
                                      'P_TYPE in varchar2, '            ||
                                      'P_HIST in out varchar2)';
--
  ndt_text6 := replace(ndt_text6, '{NDT_PRIMARY}', P_PRIMARY);
  --
  -- NDT TEXT 7
  --
  ndt_text7 := ' is status_field varchar2(40);';
  --
  -- NDT TEXT 8
  --
  -- NDT TEXT 9
  --
  -- NDT TEXT 10
  -- definition of the base table search cursor
  --
  ndt_text10:= ' cursor base_curs is select ';
  --
  -- NDT TEXT 11
  --
  ndt_text11:= ' from {NDT_TABLE} where {NDT_PRIMARY} = P_{NDT_PRIMARY};' ||
               'begin status_field:=''OK'';';
  --
  ndt_text11:= replace(ndt_text11, '{NDT_TABLE}', P_TABLE);
  ndt_text11:= replace(ndt_text11, '{NDT_PRIMARY}', P_PRIMARY);
  --
  -- NDT TEXT 12
  --
  ndt_text12:= 'if p_type = ''D'' then ';
  --
  -- NDT TEXT 13
  -- if there is nothing found under the shadow table
  --
  ndt_text13:= ' elsif p_type = ''U'' or p_type = ''I'' then ' ||
               'open base_curs; '                              ||
               'loop '                                         ||
               'fetch base_curs into ';
  --
  -- NDT TEXT 14
  -- if there is nothing found under the base table
  --
  ndt_text14:= 'if base_curs%notfound then '                        ||
               'status_field:=''ERROR - NO VALUES IN BASE '';'      ||
               'p_hist := status_field;'                            ||
               'end if;exit;end loop;close base_curs;'              ||
               'end if; '                                           ||
               'end;';
  --
  -- NDT TEXT 15
  --
  ndt_text15:= 'begin '                           ||
               'select hr_audits_s.nextval into ' ||
               'l_audit from dual;'               ||
               'open ndt_curs;'                   ||
               'loop '                            ||
               'fetch ndt_curs into l_tstamp,'    ||
                                   'l_type,'      ||
                                   'l_uname,'     ||
                                   'l_nulls,'     ||
                                   'l_sess,'      ||
                                   'l_comm,'      ||
                                   'l_seq,'       ||
                                   'l_pkval';
  --
  -- NDT TEXT 16
  --
  ndt_text16:= 'if ndt_curs%notfound then close ndt_curs;'  ||
               'exit;end if;';
  --
  -- NDT TEXT 17
  -- evaluation of the non datetrack audit transaction types
  --
  ndt_text17:= 'if l_prev_pk is null or l_pkval <> l_prev_pk then '   ||
               'l_hist:= ''OK'';'                                     ||
               'hist_values(l_pkval, l_type, l_hist);end if;'         ||
               'if substr(l_hist,1,2) = ''OK'' then '                 ||
               'if l_type=''I'' then '                                ||
               'l_trans :=''NORMAL_INSERT'';'                         ||
               'elsif l_type=''U'' then '                             ||
               'l_trans :=''NORMAL_UPDATE'';'                         ||
               'elsif l_type=''D'' then '                             ||
               'l_trans :=''NORMAL_DELETE'';'                         ||
               'end if;';
  --
  -- NDT TEXT 18
  -- inserting into the hr_audits_table
  --
               --
               -- insert transaction details into the hr_audits table
               --
  ndt_text18:= 'begin ' ||
               'insert into hr_audits '                                  ||
               '(audit_id,commit_id,current_session_id,primary_key,'     ||
               'primary_key_value,sequence_id,session_id,table_name,'    ||
               'timestamp,transaction,transaction_type,user_name,'       ||
               'effective_end_date,effective_start_date)'                ||
               'values '                                                 ||
               '(hr_audits_s.nextval,l_comm,''' || to_char(p_session_id) ||
               ''',''' || p_primary || ''',l_pkval, l_seq, l_sess'       ||
               ',''' || p_table || ''',l_tstamp,l_trans,l_type,l_uname,' ||
               'null,null);'                                             ||
               'exception when others then null;raise;end;';
  --
  -- NDT TEXT 19
  --
  ndt_text19 := 'if l_type = ''D'' then ';
  --
  -- NDT TEXT 21
  -- commit operations and exception handling
  --
  ndt_text21 := 'elsif l_type = ''I'' then null;end if;'                 ||
                'commit;end if;l_prev_pk:=l_pkval;'                      ||
                'end loop;exception when others then close ndt_curs;'    ||
                'hr_utility.set_location(''ERROR:''||'                   ||
                'to_char(dbms_sql.last_sql_function_code),00);'          ||
                'hr_utility.set_location(''ERROR:''||'                   ||
                'to_char(dbms_sql.last_error_position),00);'             ||
                'l_err:=hr_utility.get_message;'                         ||
                'hr_utility.trace(l_err);'                               ||
                'end;';
  --
  -- open the column_curs cursor fetching in column information and
  -- building up the dynamic text for each column
  --
  open column_curs;
  --
  -- initialise loop counter
  --
  t_loop_count := 0;
  --
  loop
  --
  -- fetch column information
  --
    hr_utility.set_location('py_audit_rep_pkg.py_audit_rep_proc',60);
    fetch column_curs into    t_column_name,
                              t_column_id,
                              t_column_type,
                              t_column_width;
    -- if no rows are fetched in use only the primary key to drive off
    if column_curs%notfound then
      close column_curs;
      exit;
    end if;
    --
    -- increment the count
    --
    t_loop_count := t_loop_count + 1;
    --
    -- build up cursor text using the column details retrieved
    --
    ndt_text2 := ndt_text2   || 'O' || to_char(t_loop_count);
    ndt_text3 := ndt_text3   || 'N' || to_char(t_loop_count);
    --
    -- special logic for varchar2 columns over the length of 240
    --
    if t_column_type = 'V' and t_column_width > 240 then
      ndt_text4 := ndt_text4  || ', substr(' || t_column_name || ',1,240)';
    else
      ndt_text4 := ndt_text4  || ',' || t_column_name ;
    end if;
    ndt_text15  := ndt_text15 || ',O'   || to_char(t_loop_count);
    ndt_text18  := ndt_text18 || 'if '                              ||
                      '(O'                                          ||
                      to_char(t_loop_count)                         ||
                      ' is not null and N' || to_char(t_loop_count) ||
                      ' is not null and O' || to_char(t_loop_count) ||
                      '<>N' || to_char(t_loop_count) || ')'         ||
                      ' or '                                        ||
                      '(O'                                          ||
                      to_char(t_loop_count)                         ||
                      ' is null and N' || to_char(t_loop_count)     ||
                      ' is not null and ((l_nulls is not null and ' ||
                      'substr(l_nulls,' || to_char(t_loop_count+1)  ||
                      ',1)=''Y'') or (l_nulls is null and l_type=''I'')))' ||
                      ' or '                                        ||
                      '(O'                                          ||
                      to_char(t_loop_count)                         ||
                      ' is not null and N' || to_char(t_loop_count) ||
                      ' is null)'                                   ||
                      ' then ins('                                  ||
                      t_column_id || ','''  || t_column_name || ''',' ;
    ndt_text19  := ndt_text19 || 'N' || to_char(t_loop_count) || ':=O' ||
                      to_char(t_loop_count) || ';';
    ndt_text20  := ndt_text20 || 'if O' || to_char(t_loop_count)    ||
                      ' is not null and O'                          ||
                      to_char(t_loop_count)                         ||
                      '<> N'                                        ||
                      to_char(t_loop_count) || ' then N'            ||
                      to_char(t_loop_count) || ':=O'                ||
                      to_char(t_loop_count)                         ||
                      ';end if;';
   ndt_text20  := ndt_text20 || 'if l_nulls is not null and substr(l_nulls,'||
                      to_char(t_loop_count+1) || ',1)=''Y'' and O'          ||
                      to_char(t_loop_count) || ' is null then N'            ||
                      to_char(t_loop_count) || ':=null; end if;';
    --
    -- a condition to cover the first time the loop is entered as
    -- the texts require a different concatenation
    --
    if t_loop_count = 1 then
      ndt_text10 := ndt_text10 || t_column_name;
      ndt_text12 := ndt_text12 || 'N'  || to_char(t_loop_count) || ':=null;';
      ndt_text13 := ndt_text13 || 'N'  || to_char(t_loop_count);
    else
      ndt_text10 := ndt_text10 || ','  || t_column_name;
      ndt_text12 := ndt_text12 || 'N'  || to_char(t_loop_count) || ':=null;';
      ndt_text13 := ndt_text13 || ',N' || to_char(t_loop_count);
    end if;
    --
    -- date column logic
    --
    if t_column_type = 'D' then
      ndt_text2  := ndt_text2  || ' date;';
      ndt_text3  := ndt_text3  || ' date;';
      ndt_text18 := ndt_text18 || ' to_char(O' || to_char(t_loop_count)  ||
          ',''DD-MM-YYYY'') '  || ', to_char(N' || to_char(t_loop_count) ||
          ',''DD-MM-YYYY''));end if;';
    --
    -- varchar2 column logic
    --
    elsif t_column_type = 'V' then
      if t_column_width >= 240 then
        ndt_text2  := ndt_text2   || ' VARCHAR(240);';
        ndt_text3  := ndt_text3   || ' VARCHAR(240);';
      else
        ndt_text2  := ndt_text2   || ' varchar2(' ||
          to_char(t_column_width) || ');';
        ndt_text3  := ndt_text3   || ' varchar2(' ||
          to_char(t_column_width) || ');';
      end if;
      ndt_text18 := ndt_text18  || ' O' || to_char(t_loop_count) ||
                                   ',N' || to_char(t_loop_count) ||');end if;';
    --
    -- number column logic
    --
    elsif t_column_type = 'N' then
      ndt_text2  := ndt_text2  || ' number;';
      ndt_text3  := ndt_text3  || ' number;';
      ndt_text18 := ndt_text18 || ' to_char(O' || to_char(t_loop_count) ||
        '),to_char(N' || to_char(t_loop_count) || '));end if;';
    end if;
  end loop;
  --
  -- if there were column cursor rows fetched in assign the ends of the text
  --
  ndt_text15       := ndt_text15 || ';';

  if t_loop_count > 0 then
    ndt_text13       := ndt_text13 || ';';
  --  if there were no column cursor rows fetched, assign the primary key rules
  else
    ndt_text10 := ndt_text10 || ' {NDT_PRIMARY} ';
    ndt_text10 := replace(ndt_text10, '{NDT_PRIMARY}', P_PRIMARY);
    ndt_text12 := ndt_text12 || ' null; ';
    ndt_text13 := ndt_text13 || ' P_{NDT_PRIMARY};';
    ndt_text13 := replace(ndt_text13, '{NDT_PRIMARY}', P_PRIMARY);
    ndt_text19 := ndt_text19 || 'null; ';
    ndt_text20 := 'null; ';
  end if;
  --
  ndt_text19   := ndt_text19 || 'elsif l_type = ''U'' then ';
  --
  -- CONCATENATE NON-DATETRACK DYNAMIC SQL TEXT
  --
--
-- flemonni 630622
--
-- put this in its own block, so that if variable length is exceeded can raise
-- a specific error
--
    BEGIN
    ndt_proc_cursor_text := ndt_text1   ||
                            ndt_text2   ||
                            ndt_text3   ||
                            ndt_text4   ||
                            ndt_text5   ||
                            ndt_text6   ||
                            ndt_text7   ||
                            ndt_text8   ||
                            ndt_text9   ||
                            ndt_text10  ||
                            ndt_text11  ||
                            ndt_text12  ||
                            ndt_text13  ||
                            ndt_text14  ||
                            ndt_text15  ||
                            ndt_text16  ||
                            ndt_text17  ||
                            ndt_text18  ||
                            ndt_text19  ||
                            ndt_text20  ||
                            ndt_text21;

    EXCEPTION
      WHEN OTHERS THEN
        g_audit_table := p_table;
        RAISE g_parse_string_too_big;
    END;

  --
  -- open parse and execute the dynamic sql cursor text
  --
  hr_utility.set_location('py_audit_rep_pkg.py_audit_rep_proc',70);
  ndt_proc_cursor      := dbms_sql.open_CURSOR;
  --
  hr_utility.set_location('py_audit_rep_pkg.py_audit_rep_proc',80);
  dbms_sql.parse(ndt_proc_cursor, ndt_proc_cursor_text, dbms_sql.v7);
  --
  hr_utility.set_location('py_audit_rep_pkg.py_audit_rep_proc',90);
  ndt_proc_rows := dbms_sql.EXECUTE(ndt_proc_cursor);
  --
  hr_utility.set_location('py_audit_rep_pkg.py_audit_rep_proc',100);
  if dbms_sql.is_open(ndt_proc_cursor) then
    dbms_sql.close_CURSOR(ndt_proc_cursor);
  end if;
  --
  --  commit all transactions
  --
    commit;
end if;
--
-- EXCEPTION HANDLING
-- close down cursors when the exception is raised
--
exception
--
-- flemonni 630622
--
--
  WHEN g_parse_string_too_big THEN
    hr_utility.set_location('py_audit_rep_pkg.py_audit_rep_proc',101);
    fnd_message.set_name('PER', 'PER_52348_AUDIT_SQL_TOO_LARGE');
    fnd_message.set_token ('AUDITTABLE', g_audit_table);
    --
    RAISE;
when others then
  --
  -- if the datetrack cursor is open close it.
  --
  if dbms_sql.is_open(dt_proc_cursor) then
    dbms_sql.close_cursor(dt_proc_cursor);
  end if;
  --
  -- if the non datetrack cursor is open close it
  --
  if dbms_sql.is_open(ndt_proc_cursor) then
    dbms_sql.close_cursor(ndt_proc_cursor);
  end if;
  --
  -- display the error
  --
  hr_utility.set_location('error is : ' ||
             to_char(dbms_sql.last_sql_function_code),00);
  hr_utility.set_location('error is : ' ||
             to_char(dbms_sql.last_error_position),00);
  error_message := hr_utility.get_message;
  hr_utility.trace(error_message);
  hr_utility.trace('all cursors closed');
  raise;
end py_audit_rep_proc;
end py_audit_rep_pkg;

/
