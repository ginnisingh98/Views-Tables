--------------------------------------------------------
--  DDL for Package Body BIS_SUBMIT_REQUESTSET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_SUBMIT_REQUESTSET" AS
/*$Header: BISSRSUB.pls 120.18.12010000.2 2008/08/12 07:46:54 bijain ship $*/
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(120.18.12000000.2=120.19):~PROD:~PATH:~FILE

procedure log(MODULE    IN VARCHAR2,
              MESSAGE   IN VARCHAR2) IS
begin
  IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_ERROR, module, message);
  END IF;
end;

function get_parameter_flag(p_program_name varchar2, p_app_id number) return varchar2 is
   cursor c_parameter is
   select 'Y'
   from dual
   where exists
   (select descriptive_flexfield_name
   from fnd_descr_flex_column_usages
   where application_id=p_app_id
   and descriptive_flex_context_code = 'Global Data Elements'
   and descriptive_flexfield_name='$SRS$.'||p_program_name
   and enabled_flag='Y'
   and display_flag='Y');

  l_dummy varchar2(1);

   begin
     open c_parameter;
     fetch c_parameter into l_dummy;
     if c_parameter%notfound then
      return 'N';
     else
      return l_dummy;
     end if;
   exception
     when others then
      raise;
   end;

  procedure update_default_value(p_program_name varchar2, p_app_id number) is
   sqlstmt varchar2(2000);
   begin
     /** comment out the code because this procedure logic will not
     be used in current RSG
     sqlstmt:='update fnd_descr_flex_column_usages '||
              'set default_value=null '||
              'where application_id='||p_app_id||
              ' and descriptive_flexfield_name='||'''$SRS$.'||p_program_name||''''||
              ' and default_value is not null '||
              ' and enabled_flag =''Y'''||
              ' and display_flag=''Y'''||
              ' and upper(END_USER_COLUMN_NAME) like ''%DATE%'''||
              ' and default_type=''S''';
    --dbms_output.put_line(substr(sqlstmt,1,200));
    --dbms_output.put_line(substr(sqlstmt,201,200));
    execute immediate sqlstmt;
    commit;
    exception
      when others then
            raise;
      **/
     null;
   end;



procedure sort_table(p_sorting_tbl in out NOCOPY table_sorting_tbl_type) is

 l_length			NUMBER;
 l_incr 			NUMBER;
 l_first        		number;
 l_temp_amt 			date;
 l_temp_index			NUMBER;
 l_temp_num     		NUMBER;
 l_sorted_tbl table_sorting_tbl_type;
begin


 l_length := p_sorting_tbl.COUNT;
 l_incr := trunc(l_length/2);
 l_first := p_sorting_tbl.FIRST;


  -- sorting p_sorting_tbl using SHELL sort method
  --

  WHILE l_incr >= 1 LOOP

    FOR i IN l_incr + l_first .. l_first + l_length - 1 LOOP

      -- hold the values at the current index intemporary variables
      --
      l_temp_index := p_sorting_tbl(i).tbl_index;
      l_temp_amt := p_sorting_tbl(i).refresh_date;
      l_temp_num := i;

      WHILE ( l_temp_num  >= l_incr + l_first AND l_temp_amt >
               p_sorting_tbl(l_temp_num - l_incr).refresh_date ) LOOP


        p_sorting_tbl(l_temp_num).tbl_index :=
                          p_sorting_tbl(l_temp_num - l_incr).tbl_index;

        p_sorting_tbl(l_temp_num).refresh_date :=
                         p_sorting_tbl(l_temp_num - l_incr).refresh_date;
        l_temp_num := l_temp_num - l_incr;

      END LOOP;


      p_sorting_tbl(l_temp_num).tbl_index := l_temp_index;
      p_sorting_tbl(l_temp_num).refresh_date := l_temp_amt;

    END LOOP;

    l_incr := trunc(l_incr/2);

  END LOOP;


end;

----added for bug 4532066
function portlet_has_impl_report(p_portlet_name in varchar2) return varchar2 is
 cursor c_reports is
   select distinct
   obj.depend_OBJECT_NAME  ,
   obj.depend_object_type
       from
       (select object_name,
           object_type,
           object_owner,
           depend_object_name,
           depend_object_type,
           depend_object_owner,
           enabled_flag
        from
        bis_obj_dependency
        where enabled_flag='Y') obj
       where depend_object_type='REPORT'
       start with
         obj.object_type ='PORTLET'
         and obj.object_name=p_portlet_name
       connect by prior obj.DEPEND_OBJECT_NAME=obj.object_name
       and prior obj.DEPEND_OBJECT_TYPE=obj.object_TYPE	;

l_report_rec c_reports%rowtype;
l_impl_report varchar2(1);
l_dummy number;
begin
 l_impl_report:='N';
 l_dummy:=0;
 for l_report_rec in c_reports loop
  l_dummy:=l_dummy+1;
  if BIS_IMPL_OPT_PKG.get_impl_flag(l_report_rec.depend_object_name,'REPORT')='Y' then
    l_impl_report:='Y';
    exit;
  end if;
 end loop;

 ---added for bug 4675702
 ---handle the corner case where objects are linked to portlets directly
 ---without reports in between.
 if l_dummy=0 then
   l_impl_report:='Y';
 end if;
 return l_impl_report;
 exception
  when others then
    raise;
end;


function get_last_refreshtime(p_obj_type varchar2,p_obj_owner varchar2,p_obj_name varchar2) return varchar2
is
begin
 if p_obj_type<>'PAGE' then
   if get_last_refreshdate(p_obj_type,p_obj_owner,p_obj_name) <>to_date('01-01-1900','DD-MM-YYYY') then
    return  fnd_date.date_to_charDT(get_last_refreshdate(p_obj_type,p_obj_owner,p_obj_name)) ;
   else
    return null;
   end if;
 else ----this api is used by RSG only. Now we don't show time for pages in RSG
   return null;
 end if;
exception
  when others then
    --dbms_output.put_line(sqlerrm);
   raise;
end;


function get_obj_refresh_date_old(p_obj_type varchar2,p_obj_owner varchar2,p_obj_name varchar2) return date
is

cursor c_obj_latest_date is
select max(temp.latest_date) latest_date
from
(select
max(aa.actual_completion_date) latest_date,
aa.program_application_id,
aa.concurrent_program_id
from
fnd_concurrent_requests  aa,
( select distinct
  b.application_id application_id,
  b.CONCURRENT_PROGRAM_ID concurrent_program_id
 from
 bis_obj_prog_linkages   a,
 fnd_concurrent_programs  b
 where a.object_name=p_obj_name
 and a.object_type=p_obj_type
 and a.CONC_PROGRAM_NAME=b.concurrent_program_name
 and a.conc_program_name <>'BSC_REFRESH_SUMMARY_IND'
 and a.CONC_APP_ID=b.application_id
 and a.enabled_flag='Y'
 and b.enabled_flag='Y'
 and a.refresh_mode in ('INIT','INCR','INIT_INCR')) bb
where
aa.program_application_id= bb.application_id
and aa.concurrent_program_id=bb.concurrent_program_id
and aa.status_code in ('I','R','G','C')
and aa.phase_code='C'
group by aa.program_application_id,aa.concurrent_program_id) temp;

cursor c_mv_latest_date is
select
 max(aa.actual_completion_date) latest_time
-- aa.program_application_id program_application_id,
-- aa.concurrent_program_id concurrent_program_id
from
fnd_concurrent_requests aa,
fnd_concurrent_programs bb
where bb.concurrent_program_name='BIS_MV_REFRESH'
and bb.application_id=191
and aa.program_application_id=bb.application_id
and aa.concurrent_program_id=bb.concurrent_program_id
and aa.status_code in ('I','R','G','C')
and aa.phase_code='C'
and aa.argument2=p_obj_name
and aa.argument1 in ('INIT','INCR');
---group by aa.program_application_id,aa.concurrent_program_id;

cursor c_mv_has_program is
select 'Y'
from dual
where exists
(select 'Y'
from bis_obj_prog_linkages a,
     fnd_concurrent_programs b
where a.object_name=p_obj_name
and a.object_type='MV'
and a.enabled_flag='Y'
and a.CONC_APP_ID=b.application_id
and a.CONC_PROGRAM_NAME=b.concurrent_program_name
and b.enabled_flag='Y');

cursor c_auto_gen_report_date is
select
 max(aa.actual_completion_date) latest_time
-- aa.program_application_id program_application_id,
-- aa.concurrent_program_id concurrent_program_id
from
fnd_concurrent_requests aa,
fnd_concurrent_programs bb
where bb.concurrent_program_name='BSC_REFRESH_SUMMARY_IND'
and bb.application_id=271
and aa.program_application_id=bb.application_id
and aa.concurrent_program_id=bb.concurrent_program_id
and aa.status_code in ('I','R','G','C')
and aa.phase_code='C'
and aa.argument1=to_char(bis_create_requestset.get_indicator_auto_gen(p_obj_name));


l_obj_latest_date date;
l_dummy varchar2(1);
l_module varchar2(300) := 'bis.GET_LAST_REFRESH_DATE.'||p_obj_type||'.'||p_obj_name;

begin
 l_obj_latest_date:=null;
 l_dummy:=null;

 if p_obj_type='MV'  then
    open     c_mv_has_program;
    fetch c_mv_has_program into l_dummy;
    if c_mv_has_program%notfound then
       l_dummy:='N';
    end if;
    close c_mv_has_program;
   if l_dummy='Y' then
      open c_obj_latest_date;
      fetch c_obj_latest_date into l_obj_latest_date;
      close c_obj_latest_date;
   else
      open c_mv_latest_date;
      fetch c_mv_latest_date into l_obj_latest_date;
      close c_mv_latest_date;
   end if;
 else
    open c_obj_latest_date;
    fetch c_obj_latest_date into l_obj_latest_date;
    close c_obj_latest_date;
 end if;

 if p_obj_type='REPORT' and bis_create_requestset.get_report_type(p_obj_name)='BSCREPORT' then
    open c_auto_gen_report_date;
	fetch c_auto_gen_report_date into   l_obj_latest_date;
	close c_auto_gen_report_date;
 end if;

 log(l_module, 'Got ' || l_obj_latest_date ||  ' from FND for (' || p_obj_name ||','|| p_obj_type ||')' );
 -- bis_collection_utilities.put_line('Got ' || l_obj_latest_date ||  ' from FND for (' || p_obj_name ||','|| p_obj_type ||')' );
 return l_obj_latest_date;
exception
   when others then
     raise;
end;

-- for backward compatibility, call get_obj_refresh_date_old if new logic get nothing.
function get_obj_refresh_date(p_obj_type varchar2,p_obj_owner varchar2,p_obj_name varchar2) return date
is
  CURSOR C_OBJ_LST_REFDAT(p_obj_name VARCHAR2, p_obj_type VARCHAR2)
  IS
  select last_refresh_date
  from bis_obj_properties
  where object_name= p_obj_name
    and object_type= p_obj_type;
  l_date DATE;
  l_module varchar2(300) := 'bis.GET_LAST_REFRESH_DATE.'||p_obj_type||'.'||p_obj_name;
begin
  open C_OBJ_LST_REFDAT(p_obj_name, p_obj_type);
  fetch C_OBJ_LST_REFDAT into l_date;
  close C_OBJ_LST_REFDAT;
  log(l_module, 'Got ' || l_date ||  ' from bis_obj_properties.last_refresh_date for (' || p_obj_name ||','|| p_obj_type ||')' );
   bis_collection_utilities.put_line('   '||p_obj_type||'.'||p_obj_name||': '||to_char(l_date,'DD-MON-YYYY'));
  if (l_date is null ) then
   return get_obj_refresh_date_old(p_obj_type,p_obj_owner,p_obj_name);
  else
    return l_date;
  end if;
end;



 ---Modify the logic in this function for bug 4257955 so that it has the following behavior
 ---- (0)If the user never run the request set to refresh the report/portlet, the
 ------ last refresh date will be null. No matter if the reports are real time reports or
 ------the reports that need run refresh programs.
 --- (1)After the request set has been run,if the report or portlet doesn't have any programs or MVs attached to it
 ---RSG will not maintain its last refresh date. It is treated the same
 ----as those reports/portlets not registered in RSG, Hence we return null
 ----instead of "Date not available"
 ----(2)After the request set has been run, If the report or portlet has programs or MVs attached to it, RSG will
 ---- update its last refresh date accordingly every time when the request set is run
 ---- If all objects under the report or portlet are refreshed successfully, the report
 -----or portlet will have last refresh date updated; if for some reason, one or more objects under
 ----the report or portlet are never being refreshed, then the report or portlet will
 -----have special date '01-01-1900'. Then the get_last_refreshdate api will recognize this
 -----and return 'Date not available' for this case
 ----Please note that we can also move this check logic (check if programs or MVs exist) into get last refresh date API
 -----then we don't need to set a special date (01-01-1900) here for report/portlet. However the concern is that it may
 ---cause runtime performance issue, because the api is called by PMV during rendering time
function derive_portlet_report_date(p_object_name in varchar2,p_object_type in varchar2,p_refresh_mode in varchar2) return date is

 cursor c_objects is
 select distinct
---  obj.depend_object_owner object_owner,
  obj.depend_object_type object_type,
  obj.depend_OBJECT_NAME object_name
 from
  ( select object_name,
           object_type,
           object_owner,
           depend_object_name,
           depend_object_type,
           depend_object_owner,
           enabled_flag
     from
     bis_obj_dependency
     where enabled_flag='Y')obj
 start with obj.object_type =p_object_type and obj.object_name=p_object_name
 connect by prior obj.DEPEND_OBJECT_NAME=obj.object_name
 and  prior obj.DEPEND_OBJECT_TYPE=obj.object_type
 union----the following part is for picking up the report itself
 select distinct
---  objdep.object_owner object_owner,
  objp.object_type object_type,
  objp.object_name object_name
 from
 bis_obj_properties objp
 where objp.object_name=p_object_name
 and objp.object_type = p_object_type;


l_obj_rec c_objects%rowtype;


-----Fix for bug 3278518
-----If an object has only initial loading program,skip it while deriving the last refresh date
----for report or portlet in incremental loading mode
-----If an object has only incremental loading program, skip it while deriving the
----last refresh date for report or portlet in initial loading mode
--- After bug fix 4257955, if the report or portlet has only one refresh program
----in the dependency tree,if the program has mode 'INIT', then the report will have
----last refresh date =null in incremental loading mode; if the program has mode 'INCR', then
---the report will have last refresh date=null in initial loading mode.
----This is better than return 'Not available' we had before
cursor c_obj_has_program(p_obj_type varchar2, p_obj_name varchar2,p_refresh_mode varchar2)
is
select 'Y'
from dual
where exists (select 'Y'
from bis_obj_prog_linkages a,
     fnd_concurrent_programs b
where a.object_name=p_obj_name
and a.object_type=p_obj_type
and (a.refresh_mode=p_refresh_mode or a.refresh_mode='INIT_INCR')
and a.enabled_flag='Y'
and a.CONC_APP_ID=b.application_id
and a.CONC_PROGRAM_NAME=b.concurrent_program_name
and b.enabled_flag='Y'
);


l_prog_flag varchar2(1);

l_date date;
l_temp_date date;
l_obj_refresh_dates    table_sorting_tbl_type;
l_dummy varchar2(1);
l_counter number;
l_module varchar2(300) := 'bis.DERIVE_PORTLET_REPORT_DATE.'||p_object_type||'.'||p_object_name;

begin
 l_dummy:=null;
 l_counter:=0;
 for l_obj_rec in c_objects loop
    ----added for bug 4532066
    if BIS_IMPL_OPT_PKG.get_impl_flag(l_obj_rec.object_name,l_obj_rec.object_type)='Y' then
           l_temp_date:=null;
           open c_obj_has_program(l_obj_rec.object_type, l_obj_rec.object_name,p_refresh_mode);
           fetch c_obj_has_program into l_prog_flag;
           if c_obj_has_program%notfound then
               if l_obj_rec.object_type='MV' then
                  l_prog_flag:='Y';
               else
                 l_prog_flag:='N';
                 log(l_module, 'found no program defined for obj: ' || l_obj_rec.object_name );
               end if;
           end if;
           close c_obj_has_program;

          if l_prog_flag='Y' then
            l_temp_date:=get_obj_refresh_date(l_obj_rec.object_type,null,l_obj_rec.object_name);
            log(l_module, 'found (program, last_refresh_date)= (' || l_obj_rec.object_name || ', ' || to_char(l_temp_date, 'dd-Mon-yyyy hh:mi:ss') ||')');
          end if;

         ---Bug 4257955.If the object has never been refreshed successfully, it has '01-01-1900'
         ----After sorting with other objects, it will make the repor/portlet
         ----have the last refresh date as '01-01-1900' automatically
         ----So the get last refresh date api will return 'Date not available'


          if l_temp_date is not null then
              l_counter:=l_counter+1;
             l_obj_refresh_dates(l_counter).tbl_index:=l_counter;
             l_obj_refresh_dates(l_counter).refresh_date:=l_temp_date;
         end if;
    end if;

 end loop;

 if l_counter>0 then
   log(l_module, 'sorting...' );
   sort_table(l_obj_refresh_dates);
   --- for i in 1..l_counter loop
   ---dbms_output.put_line('index: '||l_obj_refresh_dates(i).tbl_index||' date: '||l_obj_refresh_dates(i).refresh_date);
   ---end loop;
   l_date:=l_obj_refresh_dates(l_counter).refresh_date; ---the minimum date among all objects
 else
   -----Bug 4257955. if the report has no programs or MVs in the dependency tree
   -----the last refresh date will be null and the
   -----get last refresh date api will return null instead of 'Not available'
   l_date:=null;
   log(l_module, 'returning date ' || l_date );
 end if;
 return l_date;
exception
 when others then
   raise;
end;


function get_portlet_report_date(p_object_name in varchar2,p_object_type in varchar2) return date is
cursor c_direct_date is
select LAST_REFRESH_DATE,object_name
from bis_obj_properties
where object_name= p_object_name
and object_type in ('REPORT','PORTLET');
--and object_type=p_object_type;

l_date date;
l_object_name bis_obj_properties.object_name%type; --enhancement 4106617

begin
 open c_direct_date;
 fetch c_direct_date into l_date,l_object_name;
 close c_direct_date;


 /** Bug 4257955--this piece of logic is moved to update last refresh date program.
     Objects with programs or MVs but not refreshed successfully
     will be updated to '01-01-1900' to differenciate from those without
     programs or MVs defined.
 ---The following change is for enhancement 3426538
 if l_object_name is not null then ---object registered in RSG
   if l_date is null then
     l_date:=to_date('01-01-1900','DD-MM-YYYY');
   end if;
 end if;
 **/

 if  l_object_name is null then ---object not registered in RSG
   l_date:=null;
 end if;

 ---Bug 4257955. if the object resides in RSG, whatever date in bis_Obj_porperties should be returned
 ---a real date, null or '01-01-1900'
 return l_date;
/** Per management requirement, remove the backward compatible logic
We no longer derive last refresh date on the fly. The last refresh date will be updated to
bis_obj_properties table whenever the request set is re-generated in 4.0.7 and gets run
successfully

 if l_date is not null then
   return l_date;
 else
   l_date:=derive_portlet_report_date(p_object_name,p_object_type);
   return l_date;
 end if;
**/
exception
  when others then
   raise;

end;


----Bug 4257955. The logic of the following  function
----is changed to have such behaviors
----(1) If request set has never been run for the page, the last refresh date will be null
----(2) After request set has been run, if the page has no refresh program or MV in the
--------whole dependency tree, the last refresh date will be null
----(3) After the request set has been run, if all the objects in the dependency tree
-------have been refreshed successfully, the page will have the earliest last refresh date among
-------all of them
-----(4) After the request set has been run, if some of the objects in the dependency tree
------have never been refreshed successfully ('01-01-1900'), the page last refresh date will
------be '01-01-1900' so the get last refresh date API will return 'Date not available"

----This function is added for bug 3310316----
function derive_page_date(p_page_name varchar2) return date
is
---modified this cursor for bug 4532066
---derive dashboard date based on reports under the dashboard
---bug 4675702: portlets should also be considered because
---in RSG product teams can link objects to portlets directly without reports in between.
cursor c_depend_objects is
  select distinct
   obj.depend_OBJECT_NAME  ,
   obj.depend_object_type
       from
       (select object_name,
           object_type,
           object_owner,
           depend_object_name,
           depend_object_type,
           depend_object_owner,
           enabled_flag
        from
        bis_obj_dependency
        where enabled_flag='Y') obj
       where depend_object_type in ('REPORT','PORTLET')
       start with
         obj.object_type ='PAGE'
         and obj.object_name=p_page_name
       connect by prior obj.DEPEND_OBJECT_NAME=obj.object_name
       and prior obj.DEPEND_OBJECT_TYPE=obj.object_TYPE	;


l_obj_rec c_depend_objects%rowtype;
l_date date;
l_temp_date date;
l_obj_refresh_dates    table_sorting_tbl_type;
l_dummy varchar2(1);
l_counter number;
l_module varchar2(300) := 'bis.GET_LAST_REFRESH_DATE.'||'PAGE'||'.'||p_page_name;
begin
 l_counter:=0;
  -----loop through objects under the page to derive the last refresh date for page
  -----it is possible that a table or MV is attached to page directly
for l_obj_rec in c_depend_objects loop
   ---added for bug 4532066
   if (l_obj_rec.depend_object_type='REPORT'
        and BIS_IMPL_OPT_PKG.get_impl_flag(l_obj_rec.depend_object_name,l_obj_rec.depend_object_type)='Y' )
      ---added for bug 4675702
      ---The check is necessary. If none of the reports under a portlet is implement
      --then the portlet should not affect page's date
      OR (l_obj_rec.depend_object_type='PORTLET'
           and BIS_IMPL_OPT_PKG.get_impl_flag(l_obj_rec.depend_object_name,l_obj_rec.depend_object_type)='Y'
	       and portlet_has_impl_report(l_obj_rec.depend_object_name)='Y') then

        l_temp_date:=get_last_refreshdate(l_obj_rec.depend_object_type,null,l_obj_rec.depend_object_name);

     /** comment out the following logic for bug 4257955
       If a report or portlet has date '01-01-1900', it should
       make the page last refresh date '01-01-1900' automatically
	   if l_temp_date=to_date('01-01-1900','DD-MM-YYYY')   then
         l_temp_date:=null;
       end if;
       **/
       log(l_module, 'found last_refresh_date= ('||l_obj_rec.depend_object_type||'.'|| l_obj_rec.depend_object_name || ', ' || to_char(l_temp_date, 'dd-Mon-yyyy hh:mi:ss') ||')');
       bis_collection_utilities.put_line('   '||l_obj_rec.depend_object_type||'.'|| l_obj_rec.depend_object_name || ': ' || to_char(l_temp_date, 'DD-MON-YYYY'));
       if l_temp_date is not null then
         l_counter:=l_counter+1;
         l_obj_refresh_dates(l_counter).tbl_index:=l_counter;
         l_obj_refresh_dates(l_counter).refresh_date:=l_temp_date;
       end if;
    end if;
end loop;
log(l_module, 'sorting...' );
sort_table(l_obj_refresh_dates);
if l_counter >0 then
 l_date:=l_obj_refresh_dates(l_counter).refresh_date; ---the minimum date among all reports
else
 l_date:=null;
end if;
log(l_module, 'returning date ' || l_date );
return l_date;

exception
  when others then
   raise;
end;


----This function is added for bug 3310316----
function get_page_date(p_page_name varchar2) return date
is

/**The following cursor has the correct logic
but it caused number of sqls being executed exceed 10
cursor c_direct_date is
select LAST_REFRESH_DATE
from bis_obj_properties
where bis_impl_dev_pkg.get_function_by_page(object_name)=bis_impl_dev_pkg.get_function_by_page(p_page_name)
and object_type='PAGE';
**/

/**The following cursor has logic hole
It can't handle the case where form function A and
A_OA exist for two OA pages, then two rows will be returned
cursor c_direct_date is
select LAST_REFRESH_DATE
from bis_obj_properties
where object_name=p_page_name||'_OA'
and object_type='PAGE'
union
select LAST_REFRESH_DATE
from bis_obj_properties
where object_name=p_page_name
and object_type='PAGE';
**/
cursor c_direct_date1 is
select LAST_REFRESH_DATE,object_name
from bis_obj_properties
where object_name=p_page_name
and object_type='PAGE';

cursor c_direct_date2 is
select LAST_REFRESH_DATE,object_name
from bis_obj_properties
where object_name=p_page_name||'_OA'
and object_type='PAGE';


l_date date;
l_object_name bis_obj_properties.object_name%type; --Enhancement 4106617

begin
 open c_direct_date1;
 fetch c_direct_date1 into l_date,l_object_name;
 close c_direct_date1;

 if l_date is null then
    open c_direct_date2;
    fetch c_direct_date2 into l_date,l_object_name;
    close c_direct_date2;
 end if;


 -----The following code is changed for enhancement 3426538
 if l_object_name is not null then ----the page exists in RSG
  /** Bug 4257955. Return whatever date in bis_Obj_properties
      The logic of '01-01-1900' is moved to update last
      refresh date program for individual object
    if l_date is null then
      l_date:=to_date('01-01-1900','DD-MM-YYYY');
    end if;
  **/
   null;
 else---the page does't exist in RSG
    l_date:=null;
 end if;


 /**
 if l_date is not null then
   return l_date;
 else
   l_date:=derive_page_date(p_page_name);
   return l_date;
 end if;
 **/
 -----commented the above logic per Mandar's requirement
 ----We no longer derive page last refresh date
 ----To see the date on page, the user has to re-generate and run the request set to
 ----uptake the 4.0.7 enhancement 3040249
 ---The purpose of doing this is to reduce number of sqls executed when PMV render the page
 return l_date;
exception
  when others then
   raise;

end;


-----Bug 4257955
-----The following API can only be used internally by RSG
-----To get last refresh date for any object, the public API is
-----get_last_refreshdate_url
function get_last_refreshdate(p_obj_type varchar2,p_obj_owner varchar2,p_obj_name varchar2) return date
is

l_date date;
----cursor c_olap_function had been commented out since enh 3426538
----the piece of code is removed on Dec 15, 2004 to avoid future confusion

l_dummy varchar2(1);
l_module varchar2(300) := 'bis.GET_LAST_REFRESH_DATE.'||p_obj_type||'.'||p_obj_name;
begin
 l_dummy:=null;
 if p_obj_type='PORTLET' or p_obj_type='REPORT' then

   /** commented out the following code for enhancement 3426538
      open c_oltp_function;
      fetch c_oltp_function into l_dummy;
      if c_oltp_function%notfound then
        l_dummy:='N';
      end if;
      close c_oltp_function;
      if l_dummy='Y' then ----per PMV team requirement, form functions not existing in RSG means it is for OLTP
           log(l_module, 'returning sysdate for OLTP funtion ' || sysdate );
           l_date:=sysdate;---in this case, we need to return sysdate
      else
         log(l_module, 'non OLTP funtion ' );
         l_date:=get_portlet_report_date(p_obj_name,p_obj_type) ;
      end if;----end if dummy='Y' **/

      l_date:=get_portlet_report_date(p_obj_name,p_obj_type) ;
      log(l_module, 'returning '||l_date||' for REPORT and PORTLET type object'||p_obj_name);
 elsif (p_obj_type='PAGE') then-----change for bug 3310316
    l_date := get_page_date(p_obj_name);
    log(l_module, 'returning '||l_date||' for PAGE type object'||p_obj_name);

 else ----other types of objects
   l_date:=get_obj_refresh_date(p_obj_type,p_obj_owner,p_obj_name);
   log(l_module, 'returning date for other type of obj: ' || l_date );
 end if;
  return l_date;

exception
  when others then
    --dbms_output.put_line(sqlerrm);
   raise;


end;

----find out the latest time that program "Data Loader - Refresh Summary Levels by Indicators"
----being run for the given indicator
function get_kpi_refresh_date(p_indicator in varchar2) return date is
cursor c_kpi_refresh_date(indicator_id number) is
   Select
	 max(aa.actual_completion_date) last_refresh_date
	from
	fnd_concurrent_requests aa,
	fnd_concurrent_programs bb
	where bb.concurrent_program_name='BSC_REFRESH_SUMMARY_IND'
	and bb.application_id=271
	and aa.program_application_id=bb.application_id
	and aa.concurrent_program_id=bb.concurrent_program_id
	and aa.status_code in ('I','R','G','C')
	and aa.phase_code='C'
	and aa.argument1 like '%'||indicator_id||'%'
    and aa.argument2='N';
l_date date;

begin
  l_date:=null;
  open c_kpi_refresh_date(p_indicator);
  fetch c_kpi_refresh_date into l_date;
  close c_kpi_refresh_date;
  return l_date;
exception
  when others then
    raise;
end;




procedure update_page_portlet_date (p_request_id in number) is
----fixing bug 4053299
---remove the condition parent_request_id=-1 for
cursor request_set_id is
select to_number(argument2), to_number(argument1)
from fnd_concurrent_requests
----where parent_request_id=-1
where request_id=p_request_id;


cursor request_set_option(p_request_set_id varchar2, p_req_set_app_id varchar2) is
select distinct  a.option_value refresh_mode
from bis_request_set_options a,
     fnd_request_sets b
where a.request_set_name=b.request_set_name
and a.set_app_id=b.application_id
and a.option_name='REFRESH_MODE'
and b.request_set_id=p_request_set_id
and b.application_id=p_req_set_app_id;

l_refresh_mode varchar2(30);


cursor c_portlet_report_in_set (p_request_id number) is
select distinct object_type,
      object_name,
      object_owner
from BIS_OBJ_SET_TEMP
where request_id=p_request_id
and object_type in ('REPORT','PORTLET');



cursor c_pages_in_set(p_request_id number) is
select distinct object_type,
      object_name,
      object_owner
from BIS_OBJ_SET_TEMP
where request_id=p_request_id
and object_type ='PAGE';


l_object_rec c_portlet_report_in_set%rowtype;
l_page_obj_rec c_pages_in_set%rowtype;
l_request_set_id number;
l_req_set_app_id number;
l_sql varchar2(2000);
l_date date;
l_indicator varchar2(10);
l_request_id_this number;

begin

 l_request_id_this:=fnd_global.CONC_REQUEST_ID;

 open request_set_id;
 fetch request_set_id into l_request_set_id, l_req_set_app_id;
 close request_set_id;

---  BIS_COLLECTION_UTILITIES.put_line('request set id '||l_request_set_id);

 l_refresh_mode:=null;
 open request_set_option(l_request_set_id, l_req_set_app_id);
 fetch request_set_option into l_refresh_mode;
 close request_set_option;

 if l_refresh_mode is null then
    l_refresh_mode:='INCR';
 end if;

 BIS_COLLECTION_UTILITIES.put_line('=====Start updating dates for reports/portlets in the request set===');
 for l_object_rec in  c_portlet_report_in_set(l_request_id_this) loop

   ---added for bug 4532066
   if l_object_rec.object_type='PORTLET' and BIS_IMPL_OPT_PKG.get_impl_flag(l_object_rec.object_name,l_object_rec.object_type)='Y' and portlet_has_impl_report(l_object_rec.object_name)='N' then
      BIS_COLLECTION_UTILITIES.put_line('*****'||l_object_rec.object_type||' '||l_object_rec.object_name||' has no implemented reports. Not to update its date.');
   else if BIS_IMPL_OPT_PKG.get_impl_flag(l_object_rec.object_name,l_object_rec.object_type)='N' then
      BIS_COLLECTION_UTILITIES.put_line('*****'||l_object_rec.object_type||' '||l_object_rec.object_name||' is not implemented. Not to update its date.');
   else
      l_date:=null;
      l_indicator:=null;
      if l_object_rec.object_owner=bis_create_requestset.get_bsc_schema_name
          and l_object_rec.object_type='REPORT'
          and  l_object_rec.object_name like 'BSC%' then
          l_indicator:=bis_create_requestset.get_indicator(l_object_rec.object_name);
      end if;
      if l_indicator is not null then
          l_date:=get_kpi_refresh_date(l_indicator);
      else
         l_date:=derive_portlet_report_date(l_object_rec.object_name,l_object_rec.object_type,l_refresh_mode);
      end if;
      BIS_COLLECTION_UTILITIES.put_line('*****'||l_object_rec.object_type||'.'||l_object_rec.object_name||': '||to_char(l_date,'DD-MON-YYYY'));
      bis_impl_dev_pkg.update_obj_last_refresh_date(l_object_rec.object_type,l_object_rec.object_name, l_date);

   commit;
    end if;
  end if;----implementation flag='N'
 end loop;

 BIS_COLLECTION_UTILITIES.put_line('        ');
 BIS_COLLECTION_UTILITIES.put_line('=========Start updating dates for pages in the request set====');
 BIS_COLLECTION_UTILITIES.put_line('Please be informed that if a page/report has date ''01-01-1900'',');
 BIS_COLLECTION_UTILITIES.put_line('it means that at least one program for the page/report failed or has not been run.');
 BIS_COLLECTION_UTILITIES.put_line('In this case, ''Data Last Update: Date is not available for Display'' will be displayed on UI');


for l_page_obj_rec in  c_pages_in_set(l_request_id_this) loop
    l_date:=null;
    l_date:=derive_page_date(l_page_obj_rec.object_name);
    BIS_COLLECTION_UTILITIES.put_line('*****'||l_page_obj_rec.object_type||'.'||l_page_obj_rec.object_name||': '||to_char(l_date,'DD-MON-YYYY'));
    bis_impl_dev_pkg.update_obj_last_refresh_date('PAGE',l_page_obj_rec.object_name,l_date);
    commit;
end loop;


  BIS_COLLECTION_UTILITIES.put_line('End updating dates for pages and portlets/reports');

 exception
   when others then
     raise;
end;


function has_loader_sum_prog(p_report_name in varchar2) return varchar2 is

cursor c_report_program(p_report_name varchar2) is
select 'Y'
from bis_obj_prog_linkages
where object_name=p_report_name
and object_type='REPORT'
and CONC_PROGRAM_NAME='BSC_REFRESH_SUMMARY_IND';

l_dummy varchar2(1);
begin
 l_dummy:='N';
 open c_report_program(p_report_name);
 fetch c_report_program into l_dummy;
 close c_report_program;
 return  l_dummy ;
end;


 procedure update_last_refresh_date(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR2,
    p_request_id           IN NUMBER
 ) is


  cursor c_obj_direct_in_set (P_REQSET_ID NUMBER)   is
    select distinct  a.object_name,	 a.object_type,a.object_owner
             from
             bis_request_set_objects a,
             fnd_request_sets b,
             fnd_concurrent_requests c
             where a.request_set_name=b.request_set_name
             and a.SET_APP_ID=b.application_id
             and b.request_set_id=to_number(c.argument2)
             and b.application_id=to_number(c.argument1)
             and c.request_id=P_REQSET_ID;

    l_direct_obj_rec c_obj_direct_in_set%rowtype;



   CURSOR C_OBJ_TO_BE_UPDATED(p_obj_type varchar2,p_obj_name varchar2)
   IS
	   select distinct
       obj.depend_OBJECT_NAME object_name,
       obj.depend_object_type object_type,
       obj.depend_object_owner object_owner
       from
       (select object_name,
           object_type,
           object_owner,
           depend_object_name,
           depend_object_type,
           depend_object_owner,
           enabled_flag
        from
        bis_obj_dependency
        where enabled_flag='Y') obj
       start with
	      obj.object_type =p_obj_type
          and obj.object_name=p_obj_name
       connect by prior obj.DEPEND_OBJECT_NAME=obj.object_name
       and prior obj.DEPEND_OBJECT_TYPE=obj.object_TYPE	;

l_indirect_obj_rec C_OBJ_TO_BE_UPDATED%rowtype;

cursor c_page_name(p_name varchar2) is
select object_name
from bis_obj_properties
where bis_impl_dev_pkg.get_function_by_page(object_name)=bis_impl_dev_pkg.get_function_by_page(p_name)
     and object_type='PAGE';

----This cursor is added for  bug 4257955
----Please note we don't check program refresh mode in this cursor
cursor c_obj_has_program(p_obj_type varchar2, p_obj_name varchar2)
is
select 'Y'
from dual
where exists (select 'Y'
from bis_obj_prog_linkages a,
     fnd_concurrent_programs b
where a.object_name=p_obj_name
and a.object_type=p_obj_type
and a.enabled_flag='Y'
and a.CONC_APP_ID=b.application_id
and a.CONC_PROGRAM_NAME=b.concurrent_program_name
and b.enabled_flag='Y'
);

cursor c_obj_with_program(p_request_id number) is
select distinct object_type,
      object_name
from BIS_OBJ_SET_TEMP
where request_id=p_request_id
and has_program='Y'
union
select distinct object_type,
      object_name
from BIS_OBJ_SET_TEMP
where request_id=p_request_id
and object_type='MV';



   l_last_refresh_date BIS_OBJ_PROPERTIES.LAST_REFRESH_DATE%TYPE;
   l_obj_name BIS_OBJ_PROPERTIES.OBJECT_NAME%TYPE;
   l_obj_type BIS_OBJ_PROPERTIES.OBJECT_TYPE%TYPE;
   l_obj_owner BIS_OBJ_PROPERTIES.OBJECT_OWNER%TYPE;
   l_request_id NUMBER;
   l_obj_has_program varchar2(1);
   l_top_obj_name BIS_OBJ_PROPERTIES.OBJECT_NAME%TYPE;
   l_top_obj_type  BIS_OBJ_PROPERTIES.OBJECT_TYPE%TYPE;
   l_top_obj_owner  BIS_OBJ_PROPERTIES.OBJECT_OWNER%TYPE;
   l_sql varchar2(2000);
   l_request_id_this number;

 begin

    l_request_id_this:=fnd_global.CONC_REQUEST_ID;
    BIS_COLLECTION_UTILITIES.put_line('root request id ' || p_request_id);
    BIS_COLLECTION_UTILITIES.put_line('request id of this program ' || l_request_id_this);
    l_request_id := p_request_id;
    if (l_request_id is null) then
      l_request_id := FND_GLOBAL.CONC_PRIORITY_REQUEST;
      BIS_COLLECTION_UTILITIES.put_line('FND_GLOBAL.CONC_PRIORITY_REQUEST: ' || l_request_id);
    end if;


   ---preparing the temp table

   for  l_direct_obj_rec in c_obj_direct_in_set(l_request_id) loop
      l_top_obj_name:=l_direct_obj_rec.object_name;
      l_top_obj_type:=l_direct_obj_rec.object_type;
      l_top_obj_owner:=l_direct_obj_rec.object_owner;
	  if l_direct_obj_rec.object_type='PAGE' then
         open   c_page_name(l_direct_obj_rec.object_name) ;
         fetch c_page_name into l_top_obj_name;
         close c_page_name;
      end if;

	 ---added for bug 4532066
     if BIS_IMPL_OPT_PKG.get_impl_flag(l_top_obj_name,l_top_obj_type)='N' then
         BIS_COLLECTION_UTILITIES.put_line(l_top_obj_type||' '||l_top_obj_name||' is not implemented. Not to update its date.');

     else

       l_obj_has_program:='N';
       open  c_obj_has_program(l_top_obj_type, l_top_obj_name);
       fetch c_obj_has_program into l_obj_has_program;
       close c_obj_has_program;

	    l_sql:='insert into  BIS_OBJ_SET_TEMP(request_id,'||
	                                      'object_name,'||
	                                      'object_type,'||
	                                      'object_owner,'||
	                                      'has_program) '||
	                                'values (:1,:2,:3,:4,:5)';
	   execute immediate l_sql using  l_request_id_this, l_top_obj_name,l_top_obj_type,l_top_obj_owner,l_obj_has_program;

	   For l_indirect_obj_rec in  C_OBJ_TO_BE_UPDATED(l_top_obj_type,l_top_obj_name) loop
         l_obj_has_program:='N';
         open  c_obj_has_program(l_indirect_obj_rec.object_type, l_indirect_obj_rec.object_name);
         fetch c_obj_has_program into l_obj_has_program;
         close c_obj_has_program;
         execute immediate l_sql using l_request_id_this,l_indirect_obj_rec.object_name,l_indirect_obj_rec.object_type,l_indirect_obj_rec.object_owner,l_obj_has_program;
       end  loop;
     end if;-----implementation_flag='N'
   end loop;
  commit;

   BIS_COLLECTION_UTILITIES.put_line('                ');
   BIS_COLLECTION_UTILITIES.put_line('Please be informed that if an object has date ''01-01-1900'',');
   BIS_COLLECTION_UTILITIES.put_line('it means that the refresh program for this object failed or has not been run.');
   BIS_COLLECTION_UTILITIES.put_line('                ');
   BIS_COLLECTION_UTILITIES.put_line('=====Start updating dates for MVs or objects linked to programs===');


    open c_obj_with_program(l_request_id_this);
    loop
      fetch c_obj_with_program into  l_obj_type, l_obj_name;
      exit when c_obj_with_program%NOTFOUND;

      ---added for bug 4532066
     if BIS_IMPL_OPT_PKG.get_impl_flag(l_obj_name,l_obj_type)='N' then
         BIS_COLLECTION_UTILITIES.put_line(l_obj_type||' '||l_obj_name||' is not implemented. Not to update its date.');
     else


       ------Added for bug 4451368
       -----Handle the corner case: In case of data corruption, not able to find objective
       -----corresponding to the auto-gen report, then we should set the date to null for the report
       -----so that it doesn't affect the page date
      if l_obj_type='REPORT'
	      and has_loader_sum_prog(l_obj_name)='Y'
          and (bis_create_requestset.get_indicator_auto_gen(l_obj_name) is null
		        or bis_create_requestset.get_report_type(l_obj_name)<>'BSCREPORT') then
		   l_last_refresh_date:=null;

   	  else
         l_last_refresh_date:=get_obj_refresh_date_old(l_obj_type,null,l_obj_name);

        --------the following logic is added for bug 4257955
        -----(0)If the request set has never been run, the object will have last refresh date as null
        -----(1)After the request set has been run, if the object is not mv and no program being defined
        --------then the last refresh date for this object is still null
        -----(2)After the request set has been run, if the object is MV or has program defined
        -------but not refreshed successfully (or the program has not been run), then it has date set to '01-01-1900'
        ------- The get last refresh date API will return 'Date not available' in this case
        ------(3)Normal case: After the request set has been run, and the object has been refreshed
        --------successfully, then we set the last refresh date to the date got from FND table
       if l_last_refresh_date is null  then
               l_last_refresh_date:=to_date('01-01-1900','DD-MM-YYYY');
       end if;
       ------end bug 4257955

       end if; ---end if for bug 4451368

       bis_impl_dev_pkg.update_obj_last_refresh_date(l_obj_type,l_obj_name, l_last_refresh_date);
       BIS_COLLECTION_UTILITIES.put_line('  '||l_obj_type ||'.'||l_obj_name ||': ' || to_char(l_last_refresh_date,'DD-MON-YYYY'));
      end if;---implementation_flag ='N'
     end loop;
    close c_obj_with_program;
    commit;
    BIS_COLLECTION_UTILITIES.put_line('     ');


    update_page_portlet_date(l_request_id);

 exception
   when others then
    if C_OBJ_TO_BE_UPDATED%isopen then
      close C_OBJ_TO_BE_UPDATED;
    end if;
    commit;
    raise;
 end;

--Enh#4289567; API to find out if a request set is running for a Dashboard/Report
FUNCTION request_set_running(p_obj_type IN VARCHAR2, p_obj_name IN VARCHAR2, start_time OUT NOCOPY VARCHAR2)
RETURN VARCHAR2 IS
  l_return_flag VARCHAR2(1);
  l_start_time DATE;
  CURSOR c_dashboards_rs IS
    SELECT 'Y', START_DATE
    FROM BIS_RS_RUN_HISTORY HISTORY, BIS_REQUEST_SET_OBJECTS OBJECTS, FND_CONCURRENT_REQUESTS FND
    WHERE OBJECTS.object_name = p_obj_name
      AND OBJECTS.object_type = p_obj_type
      AND BIS_BIA_RSG_PSTATE.get_refresh_mode(OBJECTS.REQUEST_SET_NAME) <> 'ANAL'
      AND OBJECTS.request_set_name =  HISTORY.request_set_name
      AND HISTORY.PHASE_CODE = 'R'
      AND HISTORY.REQUEST_ID = FND.REQUEST_ID
      AND FND.STATUS_CODE <> 'X'
      ORDER BY START_DATE;

  CURSOR c_reports_rs IS
      SELECT 'Y', START_DATE
      FROM (
              SELECT request_set_name --request set for dashboard that has this report
              FROM bis_request_set_objects
              WHERE object_name IN (
                                    SELECT DISTINCT obj.OBJECT_NAME
                                    FROM bis_obj_dependency  obj
                                    WHERE object_type IN ('PAGE') AND enabled_flag='Y'
                                    START WITH obj.depend_object_type  IN ('REPORT','PORTLET')
                                          AND obj.depend_object_name= p_obj_name
                                    CONNECT BY PRIOR obj.OBJECT_NAME=obj.depend_object_name
                                          AND PRIOR obj.OBJECT_TYPE=obj.depend_object_TYPE
                                   )
              AND object_type ='PAGE'
            UNION -- request set for report directly
              SELECT request_set_name
              FROM bis_request_set_objects
              WHERE object_name = p_obj_name
              AND object_type IN ('REPORT','PORTLET')
           ) RS, BIS_RS_RUN_HISTORY HISTORY, FND_CONCURRENT_REQUESTS FND
      WHERE BIS_BIA_RSG_PSTATE.get_refresh_mode(RS.REQUEST_SET_NAME) <> 'ANAL'
        AND RS.REQUEST_SET_NAME =  HISTORY.REQUEST_SET_NAME AND HISTORY.PHASE_CODE = 'R'
        AND HISTORY.REQUEST_ID = FND.REQUEST_ID AND FND.STATUS_CODE <> 'X'
      ORDER BY START_DATE;
BEGIN
  l_return_flag := 'N';
  IF (p_obj_type = 'PAGE') THEN
    OPEN c_dashboards_rs;
    FETCH c_dashboards_rs INTO l_return_flag, l_start_time;
    CLOSE c_dashboards_rs;
  ELSE
    IF (p_obj_type IN ('REPORT','PORTLET')) THEN
      OPEN c_reports_rs;
      FETCH c_reports_rs INTO l_return_flag, l_start_time;
      CLOSE c_reports_rs;
    END IF;
  END IF;
  IF (l_start_time IS NOT NULL) THEN
    start_time := BIS_RSG_PMV_REPORT_PKG.date_to_charDTTZ(l_start_time); --rkumar:bug#5154379
  END IF;
  RETURN l_return_flag;
END;


function  get_last_refreshdate_url(p_obj_type in varchar2,
                               p_obj_owner in varchar2,
                               p_obj_name in varchar2,
            		       p_url_flag in varchar2 default 'Y') return varchar2 is

begin
return get_last_refreshdate_url(p_obj_type,p_obj_owner,p_obj_name,p_url_flag,'');
end;

---Bug 4257955. Modify the function so that it has the following behavior
---(1) It is the only public API that should be called to get last refreshed date for any object
---(2) It will return string with hyper link and/or html tags
------if p_url_flag is set to 'Y'; Otherwise, it will just return the String itself
---(4) The API will return null if the object has last refresh date as null in bis_obj_properties
-------OR if the object doesn't exist in RSG at all
----(5) The API will return 'Date not available' if the object has last refresh date as '01-01-1900' in
--------bis_obj_properties
function  get_last_refreshdate_url(p_obj_type in varchar2,
                               p_obj_owner in varchar2,
                               p_obj_name in varchar2,
            		       p_url_flag in varchar2 default 'Y',
                               p_RF_Url in varchar2) return varchar2 is

l_function_html varchar2(240);
l_function_parameters varchar2(2000);
l_web_agent varchar2(240);
l_message_text1 varchar2(240);
l_module varchar2(300) := 'bis.GET_LAST_REFRESH_DATE_PROC.'||p_obj_type||'.'||p_obj_name;
l_return_string varchar2(2000);
l_last_refresh_date date;
l_formatted_date varchar2(200);
l_function_id number;

-- Enh#4289567
l_rs_run_time VARCHAR2(20);
l_current_stat_message VARCHAR2(240);
l_current_status_gif VARCHAR2(100);

cursor c_form_function is
 select
 function_id,
 web_html_call,
 parameters
from
fnd_form_functions
where function_name='BIS_BIA_RSG_PSTATE_REPORT';

begin

 --moved the code out of if condition for enhancement 4638578
 --CODE FIX FOR 4653272, CHANGED form apps_web_agent to apps_jsp_agent
 l_web_agent:=fnd_profile.value('APPS_JSP_AGENT');
 log(l_module, 'applications web agent:'||l_web_agent);
 log(l_module, 'getting the refresh details');
 open c_form_function;
 fetch c_form_function into l_function_id,l_function_html,l_function_parameters;
 close c_form_function;
 log(l_module, 'form function html call:'||l_function_id);
 log(l_module, 'form function html call:'||l_function_html);
 log(l_module, 'form function parameters:'||l_function_parameters);

 l_last_refresh_date:=get_last_refreshdate(p_obj_type,p_obj_owner,p_obj_name);

 if p_obj_type='PAGE' then
   if l_last_refresh_date is not null and l_last_refresh_date<>to_date('01-01-1900','DD-MM-YYYY') then
     --bug 4314736
     --l_formatted_date:=to_char(l_last_refresh_date,fnd_profile.value_specific('ICX_DATE_FORMAT_MASK'));
     l_formatted_date:= BIS_RSG_PMV_REPORT_PKG.date_to_charDTTZ(l_last_refresh_date);

     l_message_text1:=fnd_message.get_string('BIS','BIS_BIA_PMV_RFH_DATE_API_MSG');
     log(l_module, 'message text:'||l_message_text1);
     if p_url_flag='Y' then
       --CODE FIX FOR 4653272, replaced ? with &
       -- CODE FIX FOR 4710006, added call to icx_sec.CreateRFURL, to convert to MAC compliant
       -- RF.jsp url
       l_return_string:='<span class="OraTipText">'||l_message_text1||' '||'<A HREF="'||
                      /*icx_sec.CreateRFURL(p_function_id => l_function_id
                                  , p_session_id => fnd_global.session_id
                                  , p_parameters => l_function_parameters||
                      '&fromLastUpdateDate=Y&'||'pParameters=pParamIds'||'@'||'Y'||'~'||'DBI_REQUEST_SET'||'^'||'DBI_REQUEST_SET'||
                      '@'||p_obj_name||'~'||'DBI_CONTENT_TYPE'||'^'||'DBI_CONTENT_TYPE@PAGE'
                                  , p_application_id =>fnd_global.resp_appl_id
                                  , p_responsibility_id => fnd_global.resp_id
                                  , p_security_group_id => icx_sec.g_security_group_id) */
                     p_RF_Url||'" class="OraLinkText">'||l_formatted_date||'</A>'||'</span>';
     else
       l_return_string:=l_message_text1||' '||l_formatted_date;
     end if;
      log(l_module, 'got details url: '||l_return_string);
   else if   l_last_refresh_date=to_date('01-01-1900','DD-MM-YYYY') then
      if  p_url_flag='Y' then
       l_return_string:='<span class="OraTipText">'||fnd_message.get_string('BIS','BIS_PMV_LAST_UPDATE_ERR')||'</span>';
    else
        l_return_string:=fnd_message.get_string('BIS','BIS_PMV_LAST_UPDATE_ERR');
      end if;
     else
      l_return_string:=null;
     end if;
    end if;
 end if;
 if p_obj_type in ('REPORT','PORTLET','TABLE','VIEW','MV') then
   if l_last_refresh_date is not null and l_last_refresh_date<>to_date('01-01-1900','DD-MM-YYYY') then
       l_message_text1:=fnd_message.get_string('BIS','BIS_BIA_PMV_RFH_DATE_API_MSG');
       --bug 4314736
       --l_formatted_date:=to_char(l_last_refresh_date,fnd_profile.value_specific('ICX_DATE_FORMAT_MASK'));
       l_formatted_date:= BIS_RSG_PMV_REPORT_PKG.date_to_charDTTZ(l_last_refresh_date);

       if p_url_flag='Y' then
         l_return_string:='<span class="OraTipText">'||l_message_text1||' '||'<A HREF="'||
                     /* icx_sec.CreateRFURL(p_function_id => l_function_id
                                  , p_session_id => fnd_global.session_id
                                  , p_parameters => l_function_parameters||
                      '&fromLastUpdateDate=Y&'||'pParameters=pParamIds'||'@'||'Y'||'~'||'DBI_REQUEST_SET'||'^'||'DBI_REQUEST_SET'||
                      '@'||p_obj_name||'~'||'DBI_CONTENT_TYPE'||'^'||'DBI_CONTENT_TYPE@REPORT'
                                  , p_application_id =>fnd_global.resp_appl_id
                                  , p_responsibility_id => fnd_global.resp_id
                                  , p_security_group_id => icx_sec.g_security_group_id) */
                     p_RF_Url||'" class="OraLinkText">'||l_formatted_date||'</A>'||'</span>';
       --rkumar:bug#5161136
         if p_obj_name in ('BIS_BIA_RSG_TABLESPACE_PGE', 'BIS_BIA_RSG_SETS_DET_PGE', 'BIS_BIA_RSG_SETS_LVL_PGE',
                           'BIS_BIA_RSG_SPACE_DET_PGE','BIS_BIA_RSG_SUB_REQS_PGE','BIS_BIA_RSG_REQ_DETAILS_PGE') then
           l_return_string:=l_message_text1||' '||l_formatted_date;
         end if;
       else
          l_return_string:=l_message_text1||' '||l_formatted_date;
       end if;
       log(l_module, 'got details url: '||l_return_string);
   else if   l_last_refresh_date=to_date('01-01-1900','DD-MM-YYYY') then
        if p_url_flag='Y' then
          l_return_string:='<span class="OraTipText">'||fnd_message.get_string('BIS','BIS_PMV_LAST_UPDATE_ERR')||'</span>';
        else
          l_return_string:=fnd_message.get_string('BIS','BIS_PMV_LAST_UPDATE_ERR');
        end if;
     else
       l_return_string:=null;
     end if;
  end if;
 end if;

 -- Enh#4289567 :: to display Current Status Icon with Data Last Update Date
 IF (p_url_flag='Y' AND p_obj_type IN ('REPORT','PAGE','PORTLET') AND request_set_running(p_obj_type, p_obj_name, l_rs_run_time) = 'Y') THEN
   l_current_stat_message := FND_MESSAGE.get_string('BIS','BIS_RSG_RS_CURRENT_STATUS');
   l_current_status_gif := '/OA_MEDIA/bispro16.gif';
   l_return_string := '<IMG alt="'||l_current_stat_message|| l_rs_run_time ||
                      '" title="'||l_current_stat_message|| l_rs_run_time ||
                      '"src="'||l_current_status_gif||'" >' || l_return_string;
 END IF;

 return l_return_string;
exception
when others then
        raise;

end;

END BIS_SUBMIT_REQUESTSET;

/
