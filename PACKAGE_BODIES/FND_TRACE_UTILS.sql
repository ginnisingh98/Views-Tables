--------------------------------------------------------
--  DDL for Package Body FND_TRACE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_TRACE_UTILS" as
/* $Header: AFPMUTLB.pls 120.2 2005/11/03 14:55:41 rtikku noship $ */

G_CUTOFF_PCT NUMBER;
l_db_user varchar2(40);

procedure ol(p_str IN varchar2) is
PRAGMA AUTONOMOUS_TRANSACTION;

begin
null;
  -- dbms_output.put_line(substr(p_str,1,250));
    fnd_file.put_line(fnd_file.output,p_str);
-- fnd_file.put_line(fnd_file.output, replace(p_str, fnd_global.local_chr(0)));
end ol;

procedure dlog(p_str IN varchar2) is
PRAGMA AUTONOMOUS_TRANSACTION;

begin
  -- dbms_output.put_line(substr(p_str,1,250));
        FND_FILE.put_line(FND_FILE.log,p_str);
end dlog;

procedure PRINT_GRAND_SUMMARY(RELATED_RUN IN varchar2) is
l_sql_str varchar2(600);
l_tmp_str varchar2(200);
l_runid NUMBER;
l_ts varchar2(100);
l_run_total NUMBER;
l_grand_total NUMBER;
l_comment varchar2(200);
TYPE CurTyp IS REF CURSOR;
   c_runs   CurTyp;
begin

  l_sql_str :='select trunc(sum(total_time/1000000000),2) '||
              'from plsql_profiler_units ' ||
              'where runid in ( select runid from plsql_profiler_runs ' ||
              '                  where related_run = :RELATED_RUN)';
  EXECUTE IMMEDIATE l_sql_str into l_grand_total using RELATED_RUN;

ol('<table >');
ol('<tr><td class=OraTableTitle>');
ol('Grand Summary For Related Run : '||RELATED_RUN);
ol('</td></tr><tr><td>');
ol('<table class="OraTable">');
ol('<tr>');
ol('<td class="tshn" width=60 >Run ID</td>');
ol('<td class="tshc" width=125>Date</td>');
ol('<td class="tshn" width=125 >Total Time (s)</td>');
ol('<td class="tshn" width=125 >% Total </td>');
ol('<td  class="tshc" width=250>Run Comment</td>');
ol('</tr>');

IF l_grand_total > 0 THEN
  l_sql_str:='select runid,TO_CHAR(run_date,''DD-MON-RR HH24:MI:SS''),'||
             '(select to_char(sum(total_time/1000000000),''999,999.00'') '||
             '   from plsql_profiler_units u '||
             '   where r.runid=u.runid), '||
             'run_comment||''   '' ||run_comment1 ' ||
             'from plsql_profiler_runs r '||
             'where related_run=:related_run order by runid';
       open c_runs for l_sql_str using related_run;
       loop
         fetch c_runs into l_runid,l_ts,l_run_total,l_comment;
         EXIT WHEN c_runs%NOTFOUND;
          -- l_tmp_str:='begin dbms_profiler.rollup_run(:RUN_ID); end;';
          -- EXECUTE IMMEDIATE l_tmp_str USING l_runid;

          ol('<tr class=tdc>');
          ol('<td class=tdn> <a href="#R'||l_runid||'">'||l_runid||'</a></td>');
          ol('<td >'||l_ts||'</td>');
          ol('<td class=tdn >'||l_run_total||'</td>');
          ol('<td class=tdn >');
          ol(to_char((l_run_total*100)/(l_grand_total),'999.00'));
          ol('</td>');
          ol('<td>'||l_comment||'</td>');
          ol('</tr>');
       end loop;
       close c_runs;
          ol('<tr class=tdc>');
          ol('<td colspan=2>Total</td>');
          ol('<td class=tdn >'||l_grand_total||'</td>');
          ol('<td class=tdn colspan=2></td>');
          ol('</tr>');
ELSE -- if l_grand_total > 0
  ol('<tr><td class=tdc colspan=5> Grand Total Time is 0.</td></tr>');
END IF;
ol('</table>');
ol('</td></tr></table>');
ol('<!-- ENDOFGRANDSUM -->');
ol('<br>');
ol('<br>');
ol('<br>');
end PRINT_GRAND_SUMMARY;


procedure PRINT_HEADER is
l_timestamp varchar2(40);
l_instance varchar2(40);
begin
  -- l_timestamp:=to_char(sysdate,'dd-Mon-yy hh24:mi');
   l_timestamp:=fnd_date.date_to_displaydate(sysdate);
  select instance_name into l_instance
  from v$instance;
  -- ol('<tr><td>');
  ol('<table width=100%><tr><td class=applicationName>');
  ol('PL/SQL Profiler Report');
  ol('</td><td>');
  ol('<table>');
    ol('<tr class=reportDataCell>');
      ol('<td align=right>Instance : </td>');
      ol('<td>'||l_instance||'</td></tr>');
      ol('<tr class=reportDataCell>');
      ol('<td align=right>Report Date : </td>');
      ol('<td>'||l_timestamp||'</td></tr>');
  ol('</table>');
  ol('</td></tr>');
  ol('</table>');
  -- ol('</td></tr>');
  ol('<br>');
  ol('<br>');
end PRINT_HEADER;


procedure PRINT_UNIT(RUN_ID IN number,
                     U_NUMBER IN number,
                     U_TYPE IN varchar2,
                     U_OWNER IN varchar2,
                     U_NAME IN varchar2 ) is
l_sql_str varchar2(4000);
l_line_num varchar2(40);
l_line_min number;
l_line_max number;
l_occ varchar2(80);
l_exec varchar2(80);
l_text varchar2(4000);

TYPE CurTyp IS REF CURSOR;
   c_units   CurTyp;
begin

ol('<table>');
ol('<tr><td class=OraTableTitle>');
ol('<A NAME="U'||RUN_ID||'_'||U_NUMBER||'"></A>');
ol('Execution Details For Program Units : '||U_OWNER||'.'||U_NAME);
ol('</td></tr>');
  ol('<tr><td>');
ol('<table class="OraTable" border=0>');
ol('<tr>');
ol('<td class="tshn" width=60 >Line #</td>');
ol('<td class="tshn" width=100 >Executions</td>');
ol('<td class="tshn" width=100 >Time (ms)</td>');
ol('<td class="tshc" width=600>Line Text </td>');
ol('</tr>');
      -- l_sql_str:='select min(line#)-5,max(line#)+5 from plsql_profiler_data '||
                 -- 'where runid= :RUN_ID and unit_number = :U_NUMBER  '||
                 -- 'and (total_occur > 0 or total_time > 0) ';
    -- dlog(l_sql_str);

      -- EXECUTE IMMEDIATE l_sql_str into l_line_min,l_line_max
              -- using RUN_ID,U_NUMBER;

      l_sql_str:='select p.line||decode(d.line#,null,null,'||
                 '''<a name="l''||d.line#||''">''), '||
       'to_char(d.total_occur,''999,999,999''),'||
       'to_char((d.total_time/1000000),''999,999.00'') ,ltrim(p.text) '||
  'from plsql_profiler_data d, '||
       'dba_source p '||
 'where p.line = d.line#(+)   '||
   'and p.type in (''PACKAGE'',''PACKAGE BODY'',''PROCEDURE'',''FUNCTION'') '||
   'and p.owner = :U_OWNER '||
   'and p.name = upper(:u_NAME ) '||
   -- 'and p.line between :l_line_min and :l_line_max '||
   'and d.runid(+)  = :RUN_ID '||
   'and d.unit_number(+)   = :U_NUMBER '||
   'and p.type = :U_TYPE '||
 'order by p.line ';
    -- dlog(l_sql_str);
       open c_units for l_sql_str
            -- using U_OWNER,U_name,l_line_min,l_line_max,RUN_ID,U_NUMBER,U_TYPE;
             using U_OWNER,U_name,RUN_ID,U_NUMBER,U_TYPE;
       loop
         fetch c_units
               into l_line_num,l_occ,l_exec,l_text;
         EXIT WHEN c_units%NOTFOUND;
           ol('<tr class=tdn>');
            ol('<td >'||l_line_num||'</td>');
            ol('<td >'||l_occ||'</td>');
            ol('<td >'||l_exec||'</td>');
            ol('<td class=tdc>'||l_text||'</td>');
           ol('</tr>');
       end loop;
       close c_units;
ol('</table> ');
ol('</td></tr></table> ');
  -- ol('</td></tr>');
ol('<!-- ENDOFUNIT -->');
  ol('<br>');
  ol('<br>');

end PRINT_UNIT;


procedure PRINT_RUN(run_id IN number) is
l_tmp_str varchar2(100);
l_sql_str varchar2(4096);
l_buf varchar2(8192);
l_run_total number;
TYPE CurTyp IS REF CURSOR;
   c_units   CurTyp;
   u_number  number;
   u_type  varchar2(32);
   u_owner  varchar2(32);
   u_name  varchar2(32);
   u_timestamp  varchar2(32);
   u_total_time  varchar2(40);
   u_percent  number;
   u_comm  varchar2(400);

begin

  -- ol('<tr><td>');


   l_tmp_str:='select nvl(ROUND(sum(total_time)/1000000000,3),0) '||
                  'from plsql_profiler_units where runid= :RUN_ID';

   EXECUTE IMMEDIATE l_tmp_str INTO l_run_total USING RUN_ID;



 dlog('Run total is '||l_run_total);


ol('<table class="OraTable">');
ol('<tr>');
ol('<td class="tshn" width=60 >');
ol('<a name="R'||RUN_ID||'" </a>Run ID</td>');
ol('<td class="tshc" width=100>Date</td>');
ol('<td class="tshn" width=125 >Total Time (s)</td>');
ol('<td  class="tshc" width=250>Run Comment</td>');
--ol('<td class="tshc" width=125>Description</td>');
ol('</tr>');

l_sql_str:=' SELECT ''<tr>''||
        ''<td class="tdn" >''||runid||''</td>''||
       ''<td class="tdc">''||TO_CHAR(run_date,''DD-MON-RR HH24:MI:SS'')||
       ''</td>''|| ''<td class="tdn" >''||:l_run_total||''</td>''||
       ''<td class="tdc">''||run_comment||''   '' ||run_comment1||''</td>''||
       ''</tr>''
  FROM plsql_profiler_runs
 WHERE runid = :RUN_ID';

EXECUTE IMMEDIATE l_sql_str INTO l_buf USING l_run_total,RUN_ID;
ol(l_buf);
ol('</table> ');
IF l_run_total =0 THEN
  ol('<table><tr><td colspan=4> <br></td></tr>');
  ol('<tr><td colspan=4 class=OraTableTitle> ');
  ol('Program Unit Summary/Details for this run not printed as Run Total is 0.');
  ol('</td></tr></table>');
END IF;

  -- ol('</td></tr>');
  ol('<br>');


IF(l_run_total > 0) THEN
ol('<table >');
ol('<tr><td class=OraTableTitle>');
ol('Execution Summary By Program Units (consuming > '||G_CUTOFF_PCT);
ol('% of Total Time) For Run ID : '||RUN_ID);
ol('</td></tr>');
  ol('<tr><td>');

  ol('<table class="OraTable" border=0>');
  ol('<tr>');
  ol('<td class="tshn" width=50 >Unit #</td>');
  ol('<td class="tshc" width=100>Type</td>');
  ol('<td class="tshc" width=75>Owner</td>');
  ol('<td class="tshc" width=250>Program Unit Name</td>');
  ol('<td class="tshn" width=100 >Total Time(s)</td>');
  ol('<td class="tshn" width=100 >% Total</td>');
  ol('<td class="tshn" width=200 >Comment</td>');
  ol('</tr>');


   /* l_sql_str:='select unit_number,unit_type,unit_owner,unit_name, ' ||
              ' unit_timestamp, '||
              'to_char((total_time/1000000000),''999,999,999.00''), '||
              'to_char(((total_time*100)/(1000000000*:l_run_total)),''999,999,999.00'') '||
              ',decode(unit_owner,'''||l_db_user||''',
                         (select text from dba_source where type=unit_type and owner=unit_owner and name=unit_name and line=2),'' '')' ||
               'from plsql_profiler_units  '||
              -- 'where runid = :RUN_ID and total_time > 1000000 '||
              'where runid = :RUN_ID  '||
              'and (total_time*100)/(1000000000*:l_run_total) > :G_CUTOFF_PCT '||
              ' order by total_time desc';
*/
    l_sql_str:='select unit_number,unit_type,unit_owner,unit_name, ' ||
              ' unit_timestamp, '||
              'trunc((total_time/1000000000),2), '||
              'trunc(((total_time*100)/(1000000000*:l_run_total)),2) '||
              ',decode(unit_owner,'''||l_db_user||''',
                         (select text from dba_source where type=unit_type and owner=unit_owner and name=unit_name and line=2),'' '')' ||
               'from plsql_profiler_units  '||
              'where runid = :RUN_ID  '||
              'and (total_time*100)/(1000000000*:l_run_total) > :G_CUTOFF_PCT '||
              ' order by total_time desc';
   open c_units for l_sql_str
        using l_run_total,RUN_ID,l_run_total,G_CUTOFF_PCT;
     loop
       fetch c_units
        into u_number,u_type,u_owner,u_name,u_timestamp,u_total_time,u_percent,u_comm;
         EXIT WHEN c_units%NOTFOUND;
           ol('<tr class=tdc>');
            ol('<td class=tdn>'||u_number||'</td>');
            ol('<td>'||u_type||'</td>');
            ol('<td>'||u_owner||'</td>');
            IF u_owner=l_db_user THEN
              ol('<td><a href="#U'||run_id||'_'||u_number||'">'||u_name||'</a></td>');
            ELSE
              ol('<td>'||u_name||'</td>');
            END IF;
            ol('<td class=tdn>'||u_total_time||'</td>');
            ol('<td class=tdn>'||u_percent||'</td>');
            ol('<td class=tdn>'||u_comm||'</td>');
           ol('</tr>');
       end loop;
       close c_units;

ol('</table> ');
  ol('</td></tr>');
ol('</table> ');

  ol('<br>');

  l_sql_str:='select unit_number,unit_type,unit_owner,unit_name ' ||
           'from plsql_profiler_units  '||
           'where runid = :RUN_ID and total_time > 1000000 '||
           'and unit_owner = '''||l_db_user||''' and unit_type IN '||
           '(''PACKAGE'',''PACKAGE BODY'',''PROCEDURE'',''FUNCTION'') '||
            'and (total_time*100)/(1000000000*:l_run_total) > :G_CUTOFF_PCT '||
           ' order by total_time desc';

       open c_units for l_sql_str
        using RUN_ID,l_run_total,G_CUTOFF_PCT;
       loop
         fetch c_units
               into u_number,u_type,u_owner,u_name;
         EXIT WHEN c_units%NOTFOUND;
            PRINT_UNIT(RUN_ID,u_number,u_type,u_owner,u_name);
       end loop;
       close c_units;


END IF;

ol('<!-- ENDOFRUN -->');
  ol('<br>');
  ol('<br>');

end PRINT_RUN;

procedure PLSQL_PROF_RPT( errbuf OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
                          retcode OUT NOCOPY /* file.sql.39 change */ NUMBER,
                          RUN_ID in NUMBER,
                          RELATED_RUN in NUMBER,
                          PURGE_DATA IN VARCHAR2 DEFAULT 'Y',
                          CUTOFF_PCT in NUMBER)  IS

BEGIN
 G_CUTOFF_PCT:=CUTOFF_PCT;

      PLSQL_PROF_RPT(RUN_ID,RELATED_RUN,PURGE_DATA,CUTOFF_PCT);

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
     -- errbuf := 'ERROR:'||sqlerrm ;
     -- retcode := '2';
     FND_FILE.put_line(FND_FILE.log,errbuf);
     FND_FILE.put_line(FND_FILE.log,'No Profiler Data was Found for the given Run');
     WHEN OTHERS THEN
        errbuf := 'Error:'||sqlerrm ;
        retcode := '2';
        FND_FILE.put_line(FND_FILE.log,'Error running PLSQL_PROF_RPT');
 END PLSQL_PROF_RPT;

procedure PLSQL_PROF_RPT( RUN_ID in NUMBER,
                          RELATED_RUN in NUMBER,
                          PURGE_DATA IN VARCHAR2 DEFAULT 'Y',
                          CUTOFF_PCT in NUMBER)  IS

l_tmp_str varchar2(100);
l_sql_str varchar2(4096);
l_buf varchar2(8192);
l_run_total number;
l_run_ok varchar2(1) :='N';
l_single_runid varchar2(1) :='Y';
l_run_count number :=1;
l_runid number;

TYPE CurTyp IS REF CURSOR;
   c_runs   CurTyp;

--cursor c_runs(rel_run number) is
  -- select runid from plsql_profiler_runs1 where related_run=rel_run;

BEGIN
G_CUTOFF_PCT:=CUTOFF_PCT;

  -- Check if the profiler package and the tables exist, if not log and exit.
  BEGIN
    select 'Y' into l_run_ok from all_objects
    where owner='SYS' and object_type='PACKAGE' and object_name='DBMS_PROFILER';
    select 'Y' into l_run_ok from all_objects
    where owner='SYS' and object_type='PACKAGE BODY'
    and object_name='DBMS_PROFILER';

    select 'Y' into l_run_ok from all_tables
    where table_name='PLSQL_PROFILER_RUNS' and rownum =1 and owner like '%';
    select 'Y' into l_run_ok from all_tables
    where table_name='PLSQL_PROFILER_UNITS' and rownum =1 and owner like '%';
    select 'Y' into l_run_ok from all_tables
    where table_name='PLSQL_PROFILER_DATA' and rownum =1 and owner like '%';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     dlog('Profiler Package and/or Profiler Tables could not be accessed.');
     dlog(' ');
     dlog(' ');
     dlog(' ');
     dlog('Please run the following scripts to install the PL/SQL Profiler objects and repeat the run.');
     dlog(' ');
     dlog(' ');
     dlog('To install the PL/SQL Profiler package, run this as the SYS user:');
     dlog('  $ORACLE_HOME/rdbms/admin/profload.sql ');
     dlog(' ');
     dlog('To install the PL/SQL Profiler tables, run this as the APPS user:');
     dlog('  $ORACLE_HOME/rdbms/admin/proftab.sql ');
     dlog(' ');
     dlog(' ');
     raise ;
  END;

ol('<html><head><title>PL/SQL Profiler Output</title>');
ol('<style type="text/css">');
ol('h1  { font-family:Arial,Helvetica,Geneva,sans-serif;font-size:16pt }');
ol('h2  { font-family:Arial,Helvetica,Geneva,sans-serif;font-size:12pt }');
ol('h3  { font-family:Arial,Helvetica,Geneva,sans-serif;font-size:10pt }');
ol('pre { font-family:Courier New,Geneva;font-size:8pt }');
ol('HR { color: #CCCC99; height: 1px; }');

ol('.applicationBody { background-image: url(/OA_MEDIA/jtfulnon_med.gif); background-repeat: no-repeat; background-color: #FFFFFF }');
ol('.applicationName { font-family: Times New Roman, Times, serif; font-size: 18pt; font-weight: bold; color: #336699 }');

ol('.OraTableTitle {font-family:Arial,Helvetica,Geneva,sans-serif;font-size:13pt;background-color:#ffffff;color:#336699}');
ol('.OraTable {background-color:#999966}');

ol('.tdn { background-color: #f7f7e7; font-family: Arial, Helvetica, Geneva, sans-serif; font-size: 9pt; text-align:right }');
ol('.tdc { background-color: #f7f7e7; font-family: Arial, Helvetica, Geneva, sans-serif; font-size: 9pt; text-align:left }');
ol('.OraLinkText { background-color: #f7f7e7; font-family: Arial, Helvetica, Geneva, sans-serif; font-size: 9pt; color: #663300; }');
ol('.tableBigHeaderCell { background-color: #CCCC99; font-family: Arial, Helvetica, sans-serif; font-size: 12pt; font-weight: bold; color:#336699 }');
ol('.tableRowHeader { background-color: #FFFFCC; font-family: Arial, Helvetica, sans-serif; font-size: 10pt; font-weight: bold }');
ol('.tshc { background-color: #CCCC99; font-family: Arial, Helvetica, sans-serif; font-size: 10pt; font-weight: bold; color:#336699; text-align:left }');
ol('.tshn { background-color: #CCCC99; font-family: Arial, Helvetica, sans-serif; font-size: 10pt; font-weight: bold; color:#336699; text-align:right }');
ol('.tableSubHeaderCell { background-color: #CCCC99; font-family: Arial, Helvetica, sans-serif; font-size: 10pt; color: #336699 }');
ol('.tableTotal { font-family: Arial, Helvetica, sans-serif; font-size: 10pt; font-weight: bold; text-align: right }');
ol('.reportDataCell { background-color: #FFFFFF; font-size: 8pt }');
ol('.reportFootnote { background-color: #FFFFFF; font-family: Arial, Helvetica, sans-serif; font-size: 8pt; color: #336699 }');

ol('</style></head><body class="applicationBody">');

-- start outer holding table.
  -- ol('<table width=800 cellpadding=0 cellspacing=0 border=0 > <tr><td>');

  -- Print Report Header
  PRINT_HEADER;

-- Check if data for the given run exists.
  if RELATED_RUN is not null then
    -- get how many runs we have, if multiple, print grand summary
    -- and then iterate over individual runs, elsif single, print it
    -- using the RUNID if provided else try to get the runid using RELATED_RUN.
    -- If still not found, log message.
    l_sql_str:='select count(*) from plsql_profiler_runs '||
               'where related_run = :RELATED_RUN ';
    EXECUTE IMMEDIATE l_sql_str INTO l_run_count using RELATED_RUN;

    dlog(l_run_count||' Runs found for Related Run Id '||RELATED_RUN);
    if l_run_count > 0 then
       l_sql_str:='select runid from plsql_profiler_runs '||
                 'where related_run=:related_run order by runid';
       open c_runs for l_sql_str using related_run;
       loop
         -- rollup all runs, so that grand summary can be printed
         fetch c_runs into l_runid;
         EXIT WHEN c_runs%NOTFOUND;
         dlog('Rolling Up Run '||l_runid);
         l_sql_str:='begin dbms_profiler.rollup_run(:RUN_ID); end;';
         EXECUTE IMMEDIATE l_sql_str USING l_runid;
       end loop;
       close c_runs;
      dlog('Printing Grand Summary');
      print_grand_summary(RELATED_RUN);
       -- then print each run
       l_sql_str:='select runid from plsql_profiler_runs '||
                 'where related_run=:related_run order by runid';
       open c_runs for l_sql_str using related_run;
       loop
         fetch c_runs into l_runid;
         EXIT WHEN c_runs%NOTFOUND;
         dlog('Processing Run Id '||l_runid);
         print_run(l_runid);
       end loop;
       close c_runs;

    elsif l_run_count =1 then
       -- print single run, use RUNID if provided else get it
      if RUN_ID is not null then
         dlog('Rolling Up Run '||RUN_ID);
         l_sql_str:='begin dbms_profiler.rollup_run(:RUN_ID); end;';
         EXECUTE IMMEDIATE l_sql_str USING RUN_ID;
         dlog('Printing Run Id '||RUN_ID);

         print_run(RUN_ID);
      else
         -- get the runid based on related run and print it
         l_runid:=-1;
         l_sql_str:='select runid from plsql_profiler_runs '||
                    'where related_run=:RELATED_RUN';
         EXECUTE IMMEDIATE l_sql_str INTO l_runid using RELATED_RUN;

         if l_runid > -1 then
         dlog('Rolling Up Run '||l_runid);
            l_sql_str:='begin dbms_profiler.rollup_run(:RUN_ID); end;';
            EXECUTE IMMEDIATE l_sql_str USING l_runid;
            dlog('Printing Run Id '||l_runid);
            print_run(l_runid);
         else
            dlog('Data for the given profiler run could not be found.');
         end if; -- if l_runid > -1
      end if;  -- if RUNID is not null
    else -- that means l_run_count = 0 and not run was found
      dlog('No runs were found for the given RELATED RUN');
    end if;
  else -- RELATED_RUN was null, so we will use the supplied RUNID
    if RUN_ID is not null then
      dlog('Rolling Up Run '||RUN_ID);
      l_sql_str:='begin dbms_profiler.rollup_run(:RUN_ID); end;';
      EXECUTE IMMEDIATE l_sql_str USING RUN_ID;
      dlog('Processing Run Id '||RUN_ID);
      print_run(RUN_ID);
    else
      dlog('Data for Profiler Run Id : '||RUN_ID||' could not be found.');
    end if;  -- if RUNID is not null
  end if;  -- if RELATED_RUN is not null

  -- IF PURGE_DATA flag is 'Y', then purge the profiler tables for this run

 if ( (UPPER(PURGE_DATA) = 'Y') OR  (UPPER(PURGE_DATA) = 'YES') ) then
  if RELATED_RUN is not null then
   begin
    dlog('Purging Profiler Data for Related Run '||RELATED_RUN);

    l_sql_str:='delete plsql_profiler_data where runid in '||
       '(select runid from plsql_profiler_runs where related_run=:RELATED_RUN)';
      EXECUTE IMMEDIATE l_sql_str USING RELATED_RUN;

    l_sql_str:='delete plsql_profiler_units where runid in '||
       '(select runid from plsql_profiler_runs where related_run=:RELATED_RUN)';
      EXECUTE IMMEDIATE l_sql_str USING RELATED_RUN;

    l_sql_str:='delete plsql_profiler_runs where related_run=:RELATED_RUN';
      EXECUTE IMMEDIATE l_sql_str USING RELATED_RUN;

    commit;
   exception
     when NO_DATA_FOUND then
      null;
   end;

  elsif RUN_ID is not null then
   begin
    dlog('Purging Profiler Data  for Run Id '||RUN_ID);

    l_sql_str:='delete plsql_profiler_data where runid =:RUN_ID';
      EXECUTE IMMEDIATE l_sql_str USING RUN_ID;

    l_sql_str:='delete plsql_profiler_units where runid =:RUN_ID';
      EXECUTE IMMEDIATE l_sql_str USING RUN_ID;

    l_sql_str:='delete plsql_profiler_runs where runid=:RUN_ID';
      EXECUTE IMMEDIATE l_sql_str USING RUN_ID;

    commit;
   exception
     when NO_DATA_FOUND then
      null;
   end;
  else
    dlog('No Profiler Data found for purging');
  end if;  -- if RELATED_RUN is null
 else
    dlog('No Profiler Data Purged');
 end if;  -- if PURGE_DATA = 'Y'

ol('</body></html>');

END PLSQL_PROF_RPT;


BEGIN

  select upper(user) into l_db_user from dual;

END FND_TRACE_UTILS;

/
