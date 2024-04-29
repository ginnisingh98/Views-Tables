--------------------------------------------------------
--  DDL for Package Body BIS_CREATE_REQUESTSET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_CREATE_REQUESTSET" AS
/*$Header: BISCRSTB.pls 120.16 2006/09/07 14:30:19 aguwalan ship $*/

 g_set_application varchar2(30);
 g_fnd_stats varchar2(30);
 g_fnd_stats_app varchar2(30);
 g_parameter_default_type varchar2(30);
 g_create_snpl varchar2(30);
 g_create_snpl_app varchar2(30);
 g_reset_flag varchar2(30);
 g_reset_flag_app varchar2(30);
 g_start_stage number ;
-- g_set_all_name varchar2(30);
-- g_set_all_longname varchar2(240);
 g_current_user_id         NUMBER  :=  FND_GLOBAL.User_id;
 g_current_login_id        NUMBER  :=  FND_GLOBAL.Login_id;
 g_req_monitoring_err EXCEPTION;

 g_bsc_loader_ind_program varchar2(30):='BSC_REFRESH_SUMMARY_IND';
 g_bsc_loader_dim_program varchar2(30):='BSC_REFRESH_DIM_IND';
 g_bsc_loader_del_program varchar2(30):='BSC_DELETE_DATA_IND';

 g_bsc_auto_gen_exist varchar2(1);

  -- FOR PING
  TYPE T_PING_REC IS RECORD (
    object_owner           bis_obj_dependency.object_owner%TYPE,
    object_type            bis_obj_dependency.object_type%TYPE,
    OBJECT_NAME            bis_obj_dependency.OBJECT_NAME%TYPE,
    HAS_DATA               VARCHAR2(10));
  TYPE T_PING_TABLE IS TABLE OF T_PING_REC;

  g_ping_table  T_PING_TABLE;

  TYPE object_rec is record(
    object_type bis_obj_dependency.object_type%TYPE,
    OBJECT_NAME  bis_obj_dependency.OBJECT_NAME%TYPE
  );
  TYPE object_table is table of object_rec;

  g_apps_schema_name varchar2(30);
  g_stage_prompt varchar2(30);


procedure log(MODULE    IN VARCHAR2,
              MESSAGE   IN VARCHAR2) IS
begin
  IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_ERROR, module, message);
  END IF;
end;

procedure logmsg(p_text in varchar2) is
begin
-- dbms_output.put_Line(p_text);
 null;
end;

 ---added for bug 4610116
function get_impl_flag_temp (p_set_name varchar2,
                             p_set_app varchar2,
							 p_top_object_type varchar2,
							 p_top_object_name varchar2,
							 p_object_type varchar2,
							 p_object_name varchar2) return varchar2 is
l_temp_impl_flag varchar2(1);
cursor c_impl_flag is
select 'Y'
from dual
where exists
(select 'Y'
  from BIS_BIA_RSG_IMPL_FLAG_TEMP
  where set_name=p_set_name
  and set_app=p_set_app
  and top_object_type=p_top_object_type
  and top_object_name=p_top_object_name
  and object_type=p_object_type
  and object_name=p_object_name
  and  object_impl_flag='Y');

begin
  l_temp_impl_flag:='N';
  open c_impl_flag;
  fetch c_impl_flag into l_temp_impl_flag;
  if c_impl_flag%notfound then
     l_temp_impl_flag:='N';
  end if;
  close c_impl_flag;
  return l_temp_impl_flag;
 exception
  when others then
   raise;
end;

function is_mvlog_mgt_enabled return varchar2 is
 begin
  return fnd_profile.value('BIS_BIA_MVLOG_ENABLE');
 end;

  FUNCTION duration(
	p_duration		number) return VARCHAR2 IS
  BEGIN
   return(to_char(floor(p_duration)) ||' Days '||
        to_char(mod(floor(p_duration*24), 24))||':'||
        to_char(mod(floor(p_duration*24*60), 60))||':'||
        to_char(mod(floor(p_duration*24*60*60), 60)));
  END duration;

 procedure delete_set_all(p_setname in varchar2,p_setlongname in varchar2,p_setapp in varchar2) is
  l_group_name varchar2(30);
  l_group_app varchar2(30);

  cursor c_setname is
  select
  REQUEST_SET_NAME
  from
  fnd_request_sets_vl a,
  fnd_application b
  where a.USER_REQUEST_SET_NAME=p_setlongname
  and a.application_id=b.application_id
  and b.application_short_name=p_setapp;

 l_setname varchar2(30);

 begin
   l_group_name:='DBI Requests and Reports';
   l_group_app:='BIS';
     --g_set_application:=fnd_global.application_short_name;
   --- g_set_application:='BIS';
    ----Based on the demo meeting on August 28, 2002
   ----Need to add the set to DBI requests group attached to Business Intelligence Administrator resp
  if  set_in_group(p_setname,p_setapp,l_group_name,l_group_app)='Y' then
    fnd_set.remove_set_from_group(
    request_set=>upper(p_setname),
    set_application=>p_setapp,
    request_group=>l_group_name,
    group_application=>l_group_app
    );
    commit;
  end if;
  -----get the set name from set longname
  ----this is to avoid the bug in UI.
  ----If the user types in set name and longname instead of using LOV
  ----The set name and longname may not in synyc with the existing request set
  open   c_setname;
  fetch c_setname into l_setname;
  close c_setname;

  if l_setname is not null then
      fnd_set.delete_set(upper(l_setname),p_setapp);
        /* changes for 'view request set history': delete from
    	bis_request_set_options and bis_request_set_objects if the request
        set already exists in these tables. */
	delete_rs_objects(upper(l_setname), p_setapp);
	delete_rs_option(upper(l_setname), p_setapp);
  else
    fnd_set.delete_set(upper(p_setname),p_setapp);
      /* changes for 'view request set history': delete from
	bis_request_set_options and bis_request_set_objects if the request
        set already exists in these tables. */
	delete_rs_objects(upper(p_setname), p_setapp);
	delete_rs_option(upper(p_setname), p_setapp);
  end if;
  commit;
  end delete_set_all;


 function check_bsc_auto_gen return varchar2 is
  cursor c_exist is
   select 'Y'
  from dual
  where exists
 (select 'Y'
  from user_objects
  where object_name='BSC_DBGEN_UTILS' and object_type='PACKAGE' );

  l_dummy varchar2(1);

  begin
   l_dummy:='N';
   open c_exist;
   fetch c_exist into l_dummy;
   close c_exist;
   return   l_dummy;
 exception
  when others then
    raise;
  end;


 procedure create_set_all(p_setname in varchar2,p_setlongname in varchar2,p_setapp in varchar2) is
  l_group_name varchar2(30);
  l_group_app varchar2(30);

   cursor c_setname is
  select
  REQUEST_SET_NAME
  from
  fnd_request_sets_vl a,
  fnd_application b
  where a.USER_REQUEST_SET_NAME=p_setlongname
  and a.application_id=b.application_id
   and b.application_short_name=p_setapp;




 l_setname varchar2(30);
 l_temp_table_owner varchar2(30);

 begin
   ---this global variable is added for fixing bug 3503046
   g_stage_prompt:=fnd_message.get_string('BIS','BIS_BIA_RSG_STAGE_PROMPT');

   g_bsc_auto_gen_exist:=check_bsc_auto_gen;

   l_group_name:='DBI Requests and Reports';
   l_group_app:='BIS';


     --g_set_application:=fnd_global.application_short_name;
   --- g_set_application:='BIS';
    ----Based on the demo meeting on August 28, 2002
   ----Need to add the set to DBI requests group attached to Business Intelligence Administrator resp
  if  set_in_group(p_setname,p_setapp,l_group_name,l_group_app)='Y' then
    fnd_set.remove_set_from_group(
    request_set=>upper(p_setname),
    set_application=>p_setapp,
    request_group=>l_group_name,
    group_application=>l_group_app
    );
    commit;
  end if;


  -----get the set name from set longname
  ----this is to avoid the bug in UI.
  ----If the user types in set name and longname instead of using LOV
  ----The set name and longname may not in synyc with the existing request set
  open   c_setname;
  fetch c_setname into l_setname;
  close c_setname;

  if l_setname is not null then
      fnd_set.delete_set(upper(l_setname),p_setapp);
        /* changes for 'view request set history': delete from
    	bis_request_set_options and bis_request_set_objects if the request
        set already exists in these tables. */
	delete_rs_objects(upper(l_setname), p_setapp);
	delete_rs_option(upper(l_setname), p_setapp);

  else
    fnd_set.delete_set(upper(p_setname),p_setapp);
      /* changes for 'view request set history': delete from
	bis_request_set_options and bis_request_set_objects if the request
        set already exists in these tables. */
	delete_rs_objects(upper(p_setname), p_setapp);
	delete_rs_option(upper(p_setname), p_setapp);
  end if;

    commit;



     fnd_set.create_set
      (name=>p_setlongname,
      short_name=>upper(p_setname),
      application=>p_setapp,
      description=>p_setlongname||'(created by request set generator)',
      owner=>null,
      start_date=>sysdate,
      end_date=>null,
      print_together=>'N',
      incompatibilities_allowed=>'N',
      LANGUAGE_CODE=>'US');
      commit;

       fnd_set.add_set_to_group(
      request_set=>upper(p_setname),
      set_application=>p_setapp,
      request_group=>'DBI Requests and Reports',
      group_application=> 'BIS'
      );
      commit;

     ---clean up global temp table whenever a request set is to be created
     ---bug 4724296
     l_temp_table_owner:=bis_create_requestset.get_object_owner('BIS_BIA_RSG_IMPL_FLAG_TEMP','TABLE');
     execute immediate 'truncate table '||l_temp_table_owner||'.BIS_BIA_RSG_IMPL_FLAG_TEMP';
     l_temp_table_owner:=bis_create_requestset.get_object_owner('BIS_BIA_RSG_STAGE_OBJECTS','TABLE');
     execute immediate 'truncate table '||l_temp_table_owner||'.BIS_BIA_RSG_STAGE_OBJECTS';

 exception
    when others then

    raise;
 end;


function object_not_linked_to_reports(p_top_object_name varchar2,
                                      p_top_object_type varchar2,
                                      p_object_name varchar2,
                                      p_object_type varchar2) return varchar2 is
l_dummy varchar2(1);
cursor c_obj_not_linked_to_reports is
select 'Y'
from
( select distinct
   obj.depend_OBJECT_NAME obj_name,
   obj.depend_object_type obj_type
 from
  ( select object_name,
           object_type,
           depend_object_name,
           depend_object_type,
           enabled_flag
     from
     bis_obj_dependency
     where enabled_flag='Y'
     and depend_object_type<>'REPORT'
     and object_type<>'REPORT'
    ) obj
  start with obj.object_type =p_top_object_type
  and obj.object_name=p_top_object_name
  connect by prior obj.DEPEND_OBJECT_NAME=obj.object_name
  and prior obj.DEPEND_OBJECT_TYPE=obj.object_type ) depend_objects
  where depend_objects.obj_type=p_object_type
  and depend_objects.obj_name=p_object_name;

begin
  l_dummy:='N';
 open c_obj_not_linked_to_reports;
 fetch c_obj_not_linked_to_reports into l_dummy;
 if c_obj_not_linked_to_reports%notfound then
    l_dummy:='N';
 end if;
 close c_obj_not_linked_to_reports;
 return l_dummy;
 exception
  when others then
    raise;
end;


procedure  process_impl_temp_table(p_set_name varchar2,
                                   p_set_app varchar2,
								   p_top_object_type varchar2,
								   p_top_object_name varchar2) is
 cursor c_unimpl_reports is
   select object_name
    from BIS_BIA_RSG_IMPL_FLAG_TEMP
    where set_name=p_set_name
    and set_app=p_set_app
    and top_object_type=p_top_object_type
    and top_object_name=p_top_object_name
    and object_type='REPORT'
	and object_impl_flag='N';

 cursor c_impl_reports is
   select object_name
    from BIS_BIA_RSG_IMPL_FLAG_TEMP
    where set_name=p_set_name
    and set_app=p_set_app
    and top_object_type=p_top_object_type
    and top_object_name=p_top_object_name
    and object_type='REPORT'
	and object_impl_flag='Y';

  cursor c_obj_under_reports (p_report_name varchar2) is
  select distinct dep.depend_object_name, dep.depend_object_type
  from
  ( select object_name,
           object_type,
           depend_object_name,
           depend_object_type
           from  bis_obj_dependency
		   where enabled_flag='Y') dep
  where dep.depend_object_type<>'REPORT'
  start with dep.object_type = 'REPORT'
   and dep.object_name=p_report_name
  connect by prior dep.depend_object_name = dep.object_name
  and prior dep.depend_object_type = dep.object_type;

 l_unimpl_report_rec 	c_unimpl_reports%rowtype;
 l_impl_report_rec c_impl_reports%rowtype;
 l_obj_rec c_obj_under_reports%rowtype;

begin
   for   l_unimpl_report_rec in c_unimpl_reports loop
     for l_obj_rec in c_obj_under_reports(l_unimpl_report_rec.object_name) loop
       ---added for bug 4664831
       ---we should not set the impl flag to 'N' in case
       ---the object is also linked to region (KPI list for example)
       ---without report in between
       if object_not_linked_to_reports(p_top_object_name,
                                      p_top_object_type,
                                      l_obj_rec.depend_object_name,
                                      l_obj_rec.depend_object_type)='N' then
         update BIS_BIA_RSG_IMPL_FLAG_TEMP
         set object_impl_flag='N'
         where set_name=p_set_name
          and set_app=p_set_app
          and top_object_type=p_top_object_type
          and top_object_name=p_top_object_name
          and object_type=l_obj_rec.depend_object_type
          and object_name=l_obj_rec.depend_object_name;
       end if;---end if object_not_linked_to_reports
     end loop;
   end loop;


   for   l_impl_report_rec in c_impl_reports loop
     for l_obj_rec in c_obj_under_reports(l_impl_report_rec.object_name) loop
       update BIS_BIA_RSG_IMPL_FLAG_TEMP
       set object_impl_flag='Y'
       where set_name=p_set_name
        and set_app=p_set_app
        and top_object_type=p_top_object_type
        and top_object_name=p_top_object_name
        and object_type=l_obj_rec.depend_object_type
        and object_name=l_obj_rec.depend_object_name;
     end loop;
   end loop;
   commit;
 exception
   when others then
     raise;
end;

procedure insert_stage_objects(p_set_name in varchar2,
                               p_set_app in varchar2,
                               p_object_name in varchar2,
							   p_object_type in varchar2) is

l_sql_stmt varchar2(2000);

cursor c_objects_per_page is
select depend_objects.obj_type object_type,depend_objects.obj_name object_name
from
( select distinct
   obj.depend_OBJECT_NAME obj_name,
   obj.depend_object_type obj_type,
   obj.depend_object_owner obj_owner
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
     where enabled_flag='Y' ) obj
  start with obj.object_type =p_object_type
  and obj.object_name = p_object_name
  connect by prior obj.DEPEND_OBJECT_NAME=obj.object_name
  and prior obj.DEPEND_OBJECT_TYPE=obj.object_type ) depend_objects
   union---the object itself could have program so we need union here
  select object_type,object_name
  from bis_obj_properties
  where object_type= p_object_type
  and object_name=p_object_name;


l_obj_rec c_objects_per_page%rowtype;
l_stage varchar2(30);
l_impl_flag varchar2(1);


begin
 ---added for bug 4610116
 for l_obj_rec in c_objects_per_page loop
    l_impl_flag:= BIS_IMPL_OPT_PKG.get_impl_flag(l_obj_rec.object_name,l_obj_rec.object_type);
    l_sql_stmt:='insert into BIS_BIA_RSG_IMPL_FLAG_TEMP(set_name,set_app,top_object_type,top_object_name,object_type,object_name,object_impl_flag)
	             values (:1,:2,:3,:4,:5,:6,:7)';
    EXECUTE IMMEDIATE l_sql_stmt USING p_set_name,p_set_app,p_object_type,p_object_name,l_obj_rec.object_type ,l_obj_rec.object_name,l_impl_flag;
 end loop;

 ---Process BIS_BIA_RSG_IMPL_FLAG_TEMP.
 ---Reset impl flag for objects within a page
 ---The purpose is to exclude objects under an unimplemented report from a request set
 if p_object_type='PAGE' then
    process_impl_temp_table(p_set_name,p_set_app,p_object_type,p_object_name);
 end if;

 l_stage:=null;
 for l_obj_rec in c_objects_per_page loop
   ---added for bug 4532066
   if get_impl_flag_temp(p_set_name,p_set_app,p_object_type,p_object_name,l_obj_rec.object_type,l_obj_rec.object_name)='Y' then
      l_sql_stmt := 'insert into BIS_BIA_RSG_STAGE_OBJECTS(set_name,set_app,stage_name,object_type,object_name)
                           values (:1,:2,:3,:4,:5)';
      EXECUTE IMMEDIATE l_sql_stmt USING p_set_name,p_set_app,l_stage,l_obj_rec.object_type ,l_obj_rec.object_name;
   end if;
 end loop;
 commit;
exception
 when others then
   raise;
end;


function get_lookup_meaning(p_type in varchar2,
                            p_code in varchar2) return varchar2 is

 l_meaning varchar2(80);
 begin
   select meaning into l_meaning
   from fnd_common_lookups
   where lookup_type=p_type
   and lookup_code=p_code;
   return l_meaning;
 exception
   when no_data_found then
     return null;
   when others then
     raise;
 end;


procedure get_stage_sequence(p_set_name in varchar2,
                               p_set_app in varchar2,
                               p_process_name in varchar2,
                               p_process_app in varchar2,
                               x_stage out NOCOPY varchar2,
                               x_sequence out NOCOPY number) is

cursor c_stage is
select
c.stage_name,
b.sequence
from
fnd_request_sets a,
fnd_request_set_programs b,
fnd_request_set_stages c,
fnd_concurrent_programs d,
fnd_application e,
fnd_application f
where a.request_set_id=b.request_set_id
and b.request_set_stage_id=c.request_set_stage_id
and a.request_set_id=c.request_set_id
and b.concurrent_program_id=d.concurrent_program_id
and b.program_application_id=d.application_id
and a.application_id=e.application_id
and d.application_id=f.application_id
and a.request_set_name=p_set_name
and d.concurrent_program_name=p_process_name
and e.application_short_name=p_set_app
and f.application_short_name=p_process_app
-- added to pickup indexes on FND_REQUEST_SET_STAGES and FND_REQUEST_SET_PROGRAMS
-- bug3143536
and c.set_application_id = a.application_id
and b.request_set_id  = c.request_set_id
and a.application_id = b.set_application_id;

l_stage varchar2(30);
l_sequence number;
l_stage_rec c_stage%rowtype;
begin
  l_stage:=null;
  l_sequence:=null;
  for l_stage_rec in c_stage loop
    l_stage:=l_stage_rec.stage_name;
    l_sequence:=l_stage_rec.sequence;
  end loop;
  x_stage:=l_stage;
  x_sequence:=l_sequence;
exception
  when others then
   x_stage:=null;
   x_sequence:=null;
   raise;
end;


function get_max_prog_sequence(p_set_name in varchar2,p_set_app in varchar2, p_stage_name varchar2) return number is

cursor c_max_seq is
select
 max(b.sequence) max_prog_seq
from
 fnd_request_sets a,
fnd_request_set_programs b,
fnd_request_set_stages c,
fnd_application d
where  a.request_set_id=b.request_set_id
and b.request_set_stage_id=c.request_set_stage_id
and a.request_set_id=c.request_set_id
and a.application_id=d.application_id
and d.application_short_name=p_set_app
and a.request_set_name=p_set_name
and c.stage_name=p_stage_name
-- added to pickup indexes on FND_REQUEST_SET_STAGES and FND_REQUEST_SET_PROGRAMS
-- bug3143536
and c.set_application_id = a.application_id
and b.request_set_id  = c.request_set_id
and a.application_id = b.set_application_id
group by c.stage_name;
l_max_seq number;
begin
  l_max_seq:=null;
  open c_max_seq;
  fetch c_max_seq into l_max_seq;
  return l_max_seq;
exception
 when others then
  return null;
  raise;
end;


procedure add_mv_to_set(
  p_setname in varchar2,
  p_set_application in varchar2,
  p_level in number,
  p_start_stage in number,
  p_refresh_mode in varchar2,
  p_object_name in varchar2,
  p_max_level in number,
  p_process_counter out nocopy integer)
IS
  l_exist_stage varchar2(30);
  l_exist_stage_number number;
  l_exist_sequence number;
  l_process_name varchar2(30);
  l_process_app varchar2(30);
  l_max_program_seq number;
  l_level_stage varchar2(30);
begin

  l_process_name := 'BIS_MV_REFRESH';
  l_process_app := 'BIS';

    --------dbms_output.put_Line('p_max_level:'||p_max_level);

   -- ----dbms_output.put_Line('p_level:'||p_level);

  l_level_stage:= 'Stage_'||to_char((p_max_level-p_level+1)*100+p_start_stage);

  ----dbms_output.put_Line('MV stage by level: '||l_level_stage);

  p_process_counter:=p_process_counter+1;



  get_stats_stage_sequence(upper(p_setname),
                           p_set_application,
                           l_process_name,
                           p_object_name,
                           g_parameter_default_type,
                           l_exist_stage,
                           l_exist_sequence);

  if l_exist_stage is null then
    l_max_program_seq:=get_max_prog_sequence(upper(p_setname),
                                             p_set_application,
                                             l_level_stage);
    if l_max_program_seq is null then
       l_max_program_seq:=0;
    end if;
    begin

      fnd_set.add_program(
                program =>l_process_name ,
  	            program_application=>l_process_app ,
  	            request_set=>upper(p_setname) ,
          	    set_application=>p_set_application ,
                stage=>l_level_stage,
                program_sequence=>l_max_program_seq+10,
                critical=>'Y'       ,
                number_of_copies =>0,
                save_output =>'Y',
                style=>null,
                printer=>null);

      fnd_set.PROGRAM_PARAMETER(
                PROGRAM=>l_process_name,
                PROGRAM_APPLICATION=>l_process_app,
                REQUEST_SET=>upper(p_setname),
                SET_APPLICATION=>p_set_application,
                STAGE=>l_level_stage,
                PROGRAM_SEQUENCE=>l_max_program_seq+10,
                PARAMETER=>'Refresh Mode',
                DISPLAY=>'Y',
                MODIFY=> 'Y' ,
                SHARED_PARAMETER=>null ,
                DEFAULT_TYPE=>'Constant',
                DEFAULT_VALUE=>p_refresh_mode
             );

      fnd_set.PROGRAM_PARAMETER(
                PROGRAM=>l_process_name,
                PROGRAM_APPLICATION=>l_process_app,
                REQUEST_SET=>upper(p_setname),
                SET_APPLICATION=>p_set_application,
                STAGE=>l_level_stage,
                PROGRAM_SEQUENCE=>l_max_program_seq+10,
                PARAMETER=>'Materialized View',
                DISPLAY=>'Y',
                MODIFY=> 'Y' ,
                SHARED_PARAMETER=>null ,
                DEFAULT_TYPE=>'Constant',
                DEFAULT_VALUE=>p_object_name
             );

      commit;

    exception
      when others then
      raise;
    end;
  else
    l_exist_stage_number:=to_number(substr(l_exist_stage,7));
    -----if a same process alreay defined in a set and the stage is later than the current process needed
    ----then we need to remove this process and re-add it to the set on an earlier stage
  --  if l_exist_stage_number>p_level*100+p_start_stage  then
     if l_exist_stage_number>(p_max_level-p_level+1)*100+p_start_stage  then
      begin
        fnd_set.remove_program
       (program=>l_process_name,
        program_application=>l_process_app,
        request_set=>upper(p_setname),
        set_application=>p_set_application,
        stage=>l_exist_stage,
        program_sequence=>l_exist_sequence);
        commit;
      exception
       when others then
         raise;
      end;
      l_max_program_seq:=get_max_prog_sequence(upper(p_setname),
                                               p_set_application,
                                               l_level_stage);
      if l_max_program_seq is null then
       l_max_program_seq:=0;
      end if;

      begin

        fnd_set.add_program(
                program =>l_process_name ,
  	            program_application=>l_process_app ,
  	            request_set=>upper(p_setname) ,
          	    set_application=>p_set_application ,
                stage=>l_level_stage,
                program_sequence=>l_max_program_seq+10,
                critical=>'Y'       ,
                number_of_copies =>0,
                save_output =>'Y',
                style=>null,
                printer=>null);

        fnd_set.PROGRAM_PARAMETER(
                PROGRAM=>l_process_name,
                PROGRAM_APPLICATION=>l_process_app,
                REQUEST_SET=>upper(p_setname),
                SET_APPLICATION=>p_set_application,
                STAGE=>l_level_stage,
                PROGRAM_SEQUENCE=>l_max_program_seq+10,
                PARAMETER=>'Refresh Mode',
                DISPLAY=>'Y',
                MODIFY=> 'Y' ,
                SHARED_PARAMETER=>null ,
                DEFAULT_TYPE=>'Constant',
                DEFAULT_VALUE=>p_refresh_mode
             );

        fnd_set.PROGRAM_PARAMETER(
                PROGRAM=>l_process_name,
                PROGRAM_APPLICATION=>l_process_app,
                REQUEST_SET=>upper(p_setname),
                SET_APPLICATION=>p_set_application,
                STAGE=>l_level_stage,
                PROGRAM_SEQUENCE=>l_max_program_seq+10,
                PARAMETER=>'Materialized View',
                DISPLAY=>'Y',
                MODIFY=> 'Y' ,
                SHARED_PARAMETER=>null ,
                DEFAULT_TYPE=>'Constant',
                DEFAULT_VALUE=>p_object_name
             );
         commit;
       exception
         when others then
           raise;
       end;
    end if; ---end if l_exist_stage_number>(l_max_leve..
  end if; ---end if exist stage is null

end;






function object_has_program(p_object_type in varchar2,p_object_name in varchar2) return varchar2 is
l_dummy varchar2(1);

cursor c_obj_has_program is
select 'Y'
from dual
where exists
(select 1
from bis_obj_prog_linkages
where object_type=p_object_type
and object_name=p_object_name
and enabled_flag='Y');
begin
 open c_obj_has_program;
 fetch c_obj_has_program into l_dummy;
 if c_obj_has_program%notfound then
   l_dummy:='N';
 end if;
 close c_obj_has_program;
 return l_dummy;
end;


function get_report_type(p_object_name in varchar2) return varchar2 is
l_sql varchar2(1000):='begin :1 :=BSC_DBGEN_UTILS.get_Objective_Type(:2); end;';
l_report_type varchar2(30);
begin
  execute immediate l_sql using OUT l_report_type,IN p_object_name;
  return l_report_type;
 exception
   when others then
     raise;
end;


function get_indicator_auto_gen(p_object_name in varchar2) return number is
l_indicator number;
begin
  execute immediate 'select distinct indicator from bsc_kpis_b where short_name=:1' into l_indicator using p_object_name;
  return   l_indicator;
 exception
 when no_data_found then
  return null;
 when others then
   raise;
end;

procedure add_auto_gen_reports(p_setname in varchar2,
                               p_set_application in varchar2,
                               p_level in number,
                               p_max_level in number,
                               p_object_name in varchar2) is

 l_exist_stage varchar2(30);
 l_exist_stage_number number;
 l_exist_sequence number;
 l_process_name varchar2(30);
 l_process_app varchar2(30);
 l_max_program_seq number;
 l_level_stage varchar2(30);
 l_indicator number;
begin

  --dbms_output.put_Line('beginning of add_auto_gemn');
  l_process_name := g_bsc_loader_ind_program;
  l_process_app := 'BSC';
  l_indicator :=to_char(get_indicator_auto_gen(p_object_name));
  if l_indicator is null then
    return;
  end if;

  l_level_stage:= 'Stage_'||to_char((p_max_level-p_level+1)*100);


  get_stats_stage_sequence(upper(p_setname),
                           p_set_application,
                           l_process_name,
                           l_indicator,
                           g_parameter_default_type,
                           l_exist_stage,
                           l_exist_sequence);


  if l_exist_stage is null then
    l_max_program_seq:=get_max_prog_sequence(upper(p_setname),
                                             p_set_application,
                                             l_level_stage);
    if l_max_program_seq is null then
       l_max_program_seq:=0;
    end if;
    begin
      --dbms_output.put_Line('point1');
      fnd_set.add_program(
                program =>l_process_name ,
  	            program_application=>l_process_app ,
  	            request_set=>upper(p_setname) ,
          	    set_application=>p_set_application ,
                stage=>l_level_stage,
                program_sequence=>l_max_program_seq+10,
                critical=>'Y'       ,
                number_of_copies =>0,
                save_output =>'Y',
                style=>null,
                printer=>null);
          --dbms_output.put_Line('point2');
      fnd_set.PROGRAM_PARAMETER(
                PROGRAM=>l_process_name,
                PROGRAM_APPLICATION=>l_process_app,
                REQUEST_SET=>upper(p_setname),
                SET_APPLICATION=>p_set_application,
                STAGE=>l_level_stage,
                PROGRAM_SEQUENCE=>l_max_program_seq+10,
                PARAMETER=>'x_indicators',
                DISPLAY=>'Y',
                MODIFY=> 'Y' ,
                SHARED_PARAMETER=>null ,
                DEFAULT_TYPE=>'Constant',
                DEFAULT_VALUE=>l_indicator
              );
                    --dbms_output.put_Line('point3');

      commit;

    exception
      when others then
      raise;
    end;
  else
    l_exist_stage_number:=to_number(substr(l_exist_stage,7));
    -----if a same process alreay defined in a set and the stage is later than the current process needed
    ----then we need to remove this process and re-add it to the set on an earlier stage
  --  if l_exist_stage_number>p_level*100+p_start_stage  then
     if l_exist_stage_number>(p_max_level-p_level+1)*100  then
      begin
        fnd_set.remove_program
       (program=>l_process_name,
        program_application=>l_process_app,
        request_set=>upper(p_setname),
        set_application=>p_set_application,
        stage=>l_exist_stage,
        program_sequence=>l_exist_sequence);
        commit;
      exception
       when others then
         raise;
      end;
      l_max_program_seq:=get_max_prog_sequence(upper(p_setname),
                                               p_set_application,
                                               l_level_stage);
      if l_max_program_seq is null then
       l_max_program_seq:=0;
      end if;

      begin

        fnd_set.add_program(
                program =>l_process_name ,
  	            program_application=>l_process_app ,
  	            request_set=>upper(p_setname) ,
          	    set_application=>p_set_application ,
                stage=>l_level_stage,
                program_sequence=>l_max_program_seq+10,
                critical=>'Y'       ,
                number_of_copies =>0,
                save_output =>'Y',
                style=>null,
                printer=>null);

            --dbms_output.put_Line('point4');
        fnd_set.PROGRAM_PARAMETER(
                PROGRAM=>l_process_name,
                PROGRAM_APPLICATION=>l_process_app,
                REQUEST_SET=>upper(p_setname),
                SET_APPLICATION=>p_set_application,
                STAGE=>l_level_stage,
                PROGRAM_SEQUENCE=>l_max_program_seq+10,
                PARAMETER=>'x_indicators',
                DISPLAY=>'Y',
                MODIFY=> 'Y' ,
                SHARED_PARAMETER=>null ,
                DEFAULT_TYPE=>'Constant',
                DEFAULT_VALUE=>l_indicator
             );

                   --dbms_output.put_Line('point5');
         commit;
       exception
         when others then
           raise;
       end;
    end if; ---end if l_exist_stage_number>(l_max_leve..
  end if; ---end if exist stage is null
      --dbms_output.put_Line('end of add_auto_gen_report');
end;


---------******this procedure replaces old procedure add_page_to_set
procedure add_any_object_to_set(p_object_name in varchar2,
                             p_object_type in varchar2,
                             p_setname in varchar2,
                             p_set_application in varchar2,
                             p_option in varchar2,
                             p_analyze_table in varchar2,
                             p_refresh_mode in varchar2,
                             p_force_full_refresh in varchar2) is



---This cursor is modified in enhancement 3999465
----The report itself can be linked to a program
----so we have to add the union part
cursor c_objects is
  select distinct
 depend_object_owner object_owner,
 depend_object_type object_type,
 depend_OBJECT_NAME object_name,
 level+1  mylevel
 from
 (select distinct
  a.depend_object_owner ,
  a.depend_object_type ,
  a.depend_object_name ,
  a.object_type ,
  a.object_owner ,
  a.object_name
  from
  bis_obj_dependency a
  where enabled_flag='Y') temp
  start with object_type =p_object_type
  and object_name = p_object_name
  connect by prior DEPEND_OBJECT_NAME=object_name
  and prior DEPEND_OBJECT_TYPE=object_type
  union
  select distinct
  object_owner,
  object_type,
   object_name,
   1 mylevel
 from
  bis_obj_dependency
  where enabled_flag='Y'
  and object_type =p_object_type
  and object_name = p_object_name
  union
  select distinct
  depend_object_owner object_owner,
  depend_object_type object_type,
  depend_object_name object_name,
   1 mylevel
 from
  bis_obj_dependency
  where enabled_flag='Y'
  and depend_object_type =p_object_type
  and depend_object_name = p_object_name
  union --added for bug 4648079 auto gen report with custom calendar
  select distinct
  object_owner,
  object_type,
  object_name,
  1 mylevel
  from bis_obj_prog_linkages
  where object_type=p_object_type
  and object_name=p_object_name
  order by mylevel desc;


 cursor c_max_level is
 select nvl(max(level),0)+1 from
 (select distinct
  a.depend_object_owner ,
  a.depend_object_type ,
  a.depend_object_name ,
  a.object_type ,
  a.object_owner ,
  a.object_name
  from
  bis_obj_dependency a
  where enabled_flag='Y') temp
 start with object_type=p_object_type
 and object_name = p_object_name
 connect by prior depend_object_name=object_name
 and prior depend_object_type=object_type;


  ----a refresh program with INIT_INCR type can be used in both initial loading request set and
  -----incremental request set
  ------For enhancement 4251030, exclude bsc loader program because it needs
  ------special logic for parameter being passed in
  ------We will handle it separately in procedure add_auto_gen_reports
  cursor c_process (p_objectname varchar2,p_objecttype varchar2,p_mode varchar2) is
  select distinct
   a.CONC_PROGRAM_NAME  CONCURRENT_PROGRAM_NAME,
   a.CONC_APP_SHORT_NAME APPLICATION_SHORT_NAME
  from
   bis_obj_prog_linkages a,
   fnd_concurrent_programs b
  where a.object_name=p_objectname
  and a.object_type=p_objecttype
  and a.enabled_flag='Y'
  and a.CONC_PROGRAM_NAME<>g_bsc_loader_ind_program
  and (decode(nvl(a.refresh_mode,'INCR'),'INIT_INCR','INCR',nvl(a.refresh_mode,'INCR'))=p_mode
       or
       decode(nvl(a.refresh_mode,'INCR'),'INIT_INCR','INIT',nvl(a.refresh_mode,'INCR'))=p_mode)
  and a.CONC_PROGRAM_NAME=b.concurrent_program_name
  and a.CONC_APP_ID=b.application_id
  and b.ENABLED_FLAG='Y'  ;


 cursor c_max_stage is
  select
   max(b.display_sequence)
  from
  fnd_request_sets a,
  fnd_request_set_stages b,
  fnd_application c
  where a.request_set_id=b.request_set_id
  and a.application_id=b.set_application_id
  and a.application_id=c.application_id
  and c.application_short_name=p_set_application
  and a.request_set_name=upper(p_setname);


  l_max_level number;
  l_max_stage number;
  l_objects_rec c_objects%rowtype;
  l_process_rec c_process%rowtype;
  l_process_name varchar2(30);
  l_process_app varchar2(30);
  l_exist_stage varchar2(30);
  l_exist_stage_number number;
  l_exist_sequence number;
  l_max_program_seq number;
  l_objectname bis_obj_dependency.object_name%type;
  l_level number;
  l_set_application varchar2(30);
  l_setname varchar2(30);
  l_process_counter integer;
  l_level_stage varchar2(30);
  l_mode varchar2(30);

  -- FOR PING
  l_ping_result VARCHAR2(10);
  l_module varchar2(300) := 'bis.BIS_CREATE_REQUESTSET.add_any_object_to_set';


begin



   g_parameter_default_type:='C';

   If p_refresh_mode is null and p_analyze_table='Y' then
      -----dbms_output.put_Line('in add_any_object_to_set');
    return;
 end if;


   logmsg('page/report name: '|| p_object_name);
   log( l_module, 'object name ' ||p_object_name);
   l_set_application:=p_set_application;
   if p_set_application is null then
      l_set_application:=g_set_application;
   end if;

   if p_setname is not null then
     l_setname :=upper(p_setname);
   end if;

  insert_stage_objects(upper(l_setname),
                       l_set_application,
                       p_object_name,
					   p_object_type );


  open c_max_stage;
  fetch c_max_stage into l_max_stage;
  close c_max_stage;

  open c_max_level;
  fetch c_max_level into l_max_level;
  close c_max_level;

 if l_max_stage is null then
     l_max_stage:=0;
  end if;

    logmsg('l_max_stage: '||l_max_stage);
    logmsg('l_max_level:'||l_max_level);
    logmsg('l_set_name: '||l_setname);


 if l_max_level>0 and l_max_level*100>l_max_stage then
      ----adding stages if this page has more levels of dependencies
      for i in trunc(l_max_stage/100+1)..l_max_level loop
       --- --dbms_output.put_Line('stages added: '||'Stage_'||to_char(i*100));
        if i=1 then
          fnd_set.add_stage
         (name=>g_stage_prompt||' '||to_char(i*100),
          request_set=>upper(l_setname),
          set_application=>l_set_application,
          short_name=>'Stage_'||to_char(i*100),
          description=>null,
          display_sequence=>i*100,
          function_short_name=>'FNDRSSTE',
          function_application=>'FND',
          critical=>'N',
          incompatibilities_allowed=>'N',
          start_stage=>'Y',
          language_code=>'US');
       else
          fnd_set.add_stage
         (name=>g_stage_prompt||' '||to_char(i*100),
          request_set=>upper(l_setname),
          set_application=>l_set_application,
          short_name=>'Stage_'||to_char(i*100),
          description=>null,
          display_sequence=>i*100,
          function_short_name=>'FNDRSSTE',
          function_application=>'FND',
          critical=>'N',
          incompatibilities_allowed=>'N',
          start_stage=>'N',
          language_code=>'US');
       end if;
    end loop;
  commit;
 end if; -----end if l_max_level>0 and l_m.....


 ----for each process, check if it exists in the set
 ----no, then add the process to corresponding stage
 --- yes , check the stage to decide if the process needs to be relocated
for l_objects_rec in c_objects loop
  ---added for bug 4532066
  if  get_impl_flag_temp(l_setname,l_set_application,p_object_type,p_object_name,l_objects_rec.object_type,l_objects_rec.object_name) ='Y' then
     l_objectname:=l_objects_rec.object_name;
     l_level:=l_objects_rec.mylevel;
     l_level_stage:= 'Stage_'||to_char((l_max_level-l_level+1)*100);
     logmsg('object name: '||l_objects_rec.object_name);
     log( l_module, 'object name: '||l_objects_rec.object_name||' object type: '||l_objects_rec.object_type||' level: '||l_level);
     l_process_counter:=0;

     ---check if the object has been initial loaded or not. If yes, pull in incremental refresh program
     l_mode:=p_refresh_mode;
     -- FOR PING. Since one object can be shared in multiple pages/reports and check if it has data is time consuming
     ----Here we cache the result to improve performance
     if p_refresh_mode='INIT'
	    and p_force_full_refresh='N'
	    and ( l_objects_rec.object_type ='MV'
		      OR (l_objects_rec.object_type in ('VIEW','TABLE') and object_has_program(l_objects_rec.object_type,l_objects_rec.object_name)='Y'))	 then
       l_ping_result := NULL;
       log( l_module, 'g_ping_table size ' || g_ping_table.count());
       FOR i in 1..g_ping_table.count()
       LOOP
         IF (g_ping_table(i).object_type = l_objects_rec.object_type AND
             g_ping_table(i).object_name = l_objects_rec.object_name) THEN
           l_ping_result := g_ping_table(i).HAS_DATA;
           log( l_module, 'reuse existing result for ' || l_objects_rec.object_name || ' : ' || l_ping_result);
           exit when (l_ping_result iS NOT NULL);
         END IF;
       END LOOP;
       if (l_ping_result = 'Y') THEN
         l_mode:='INCR';
       elsif (l_ping_result = 'N') THEN
         NULL;
       else
        g_ping_table.extend;

       log( l_module, 'No existing result for ' || l_objects_rec.object_name);
       l_ping_result := object_has_data(l_objects_rec.object_name,l_objects_rec.object_type,l_objects_rec.object_owner);
       log( l_module, 'Enqueue ' || l_ping_result || ' for '|| l_objects_rec.object_name);
       g_ping_table(g_ping_table.last).object_owner := l_objects_rec.object_owner;
       g_ping_table(g_ping_table.last).object_type := l_objects_rec.object_type;
       g_ping_table(g_ping_table.last).object_name := l_objects_rec.object_name;
       g_ping_table(g_ping_table.last).has_data := l_ping_result;
       if l_ping_result ='Y' then
          l_mode:='INCR';
        end if;
      end if;
    end if;
------dbms_output.put_Line('l_mode: '||l_mode);
    log( l_module, 'l_mode:  ' || l_mode);

 for l_process_rec in c_process(l_objects_rec.object_name,l_objects_rec.object_type,l_mode) loop
     l_process_name:=l_process_rec.concurrent_program_name;
     l_process_app:=l_process_rec.application_short_name;
     -----dbms_output.put_Line('process name:'||l_process_name);
      log( l_module, ' refresh program:   ' ||l_process_name  );
     l_process_counter:=l_process_counter+1;


     get_stage_sequence(upper(l_setname),
                        l_set_application,
                        l_process_name,
                        l_process_app,
                        l_exist_stage,
                        l_exist_sequence);
    if l_exist_stage is null then ---the program doesn't exist in the set
          l_max_program_seq:=get_max_prog_sequence(upper(l_setname),
                                     l_set_application,
                                     l_level_stage);
         if l_max_program_seq is null then
            l_max_program_seq:=0;
         end if;
        begin
          fnd_set.add_program
          (program =>l_process_name ,
  	       program_application=>l_process_app ,
  	       request_set=>upper(l_setname) ,
  	       set_application=>l_set_application ,
           stage=>l_level_stage,
           program_sequence=>l_max_program_seq+10,
           critical=>'Y'       ,
           number_of_copies =>0,
           save_output =>'Y',
           style=>null,
           printer=>null);
           commit;
      exception
       when others then
        raise;
      end;

  else  ----the program already exist in the set
      l_exist_stage_number:=to_number(substr(l_exist_stage,7));
     -----if a same process alreay defined in a set and the stage is later than current process needed
     ----then we need to remove this process and re-add it to the set on an earlier stage
     if l_exist_stage_number>(l_max_level-l_level+1)*100 then
       begin
        fnd_set.remove_program
       (program=>l_process_name,
        program_application=>l_process_app,
        request_set=>upper(l_setname),
        set_application=>l_set_application,
        stage=>l_exist_stage,
        program_sequence=>l_exist_sequence);
        commit;

      exception
       when others then
        raise;
      end;
      l_max_program_seq:=get_max_prog_sequence(upper(l_setname),
                                               l_set_application,
                                               l_level_stage);
      if l_max_program_seq is null then
          l_max_program_seq:=0;
      end if;
      begin
            fnd_set.add_program
         (program =>l_process_name ,
    	  program_application=>l_process_app ,
    	  request_set=>upper(l_setname) ,
    	  set_application=>l_set_application ,
          stage=>l_level_stage,
          program_sequence=>l_max_program_seq+10,
          critical=>'Y'       ,
          number_of_copies =>0,
          save_output =>'Y',
          style=>null,
          printer=>null);
          commit;
        exception
         when others then
          raise;
      end;
   end if;---end if l_exist_stage_number>(l_max_level-l...
   end if; ---end if exist stage is null
  end loop;----end loop of processes


  if ( l_process_counter = 0 and           -- no product team Refresh Program Defined in RSG
       l_objects_rec.object_type = 'MV'    -- 'MV' type
   --    and l_objects_rec.object_owner<>'BSC'----exclude BSC MVs because they are loaded by BSC loader
       and p_refresh_mode not in ('DATA_VAL','SETUP_VAL') ) then

   -- For 'MV' type object, call add_mv_to_set.
    add_mv_to_set(l_setname, l_set_application,  l_level, 0,
                 l_mode, l_objectname,l_max_level, l_process_counter);

  end if; -- end if for 'MV'  object type

  -----for enhancement 4251030. Generate request sets for auto gen reports
  if g_bsc_auto_gen_exist='Y' and l_objects_rec.object_type='REPORT' and get_report_type(l_objectname)='BSCREPORT' then

     add_auto_gen_reports(l_setname ,
                               l_set_application,
                               l_level ,
                               l_max_level ,
                               l_objectname) ;

  end if;

 end if;---end if implementation_flag='Y'
end loop;----end loop of objects
  -----dbms_output.put_Line('end of all objects');
   log(l_module, 'end of all objects in the page');

end;
--------******



function set_in_group(p_set_name varchar2,p_setapp varchar2,p_group_name varchar2,p_group_app varchar2) return varchar2 is
  cursor c_set_exist is
  select 'Y'
  from dual
  where exists
  (select a.request_set_name
   from fnd_request_sets a,
        fnd_request_group_units b,
        fnd_request_groups c,
        fnd_application d1,
        fnd_application d2
    where a.application_id=b.unit_application_id
    and a.request_set_id=b.request_unit_id
    and b.request_unit_type='S'
    and a.application_id=d1.application_id
    and a.request_set_name=p_set_name
    and d1.application_short_name=p_setapp
    and c.application_id=b.application_id
    and c.request_group_id=b.request_group_id
    and c.application_id=d2.application_id
    and d2.application_short_name=p_group_app
    and c.request_group_name=p_group_name);
   l_dummy varchar2(1);

  begin
    open c_set_exist;
    fetch c_set_exist into l_dummy;
    if c_set_exist%notfound then
      return 'N';
    else
      return 'Y';
    end if;
   close c_set_exist;
  exception
    when others then
    raise;
 end;


-----This procedure will check if any stage in the set is empty.
----If yes, remove the empty stages, relink stages and reset start stage
procedure remove_empty_stages(p_set_name varchar2,
                               p_setapp varchar2) is
cursor c_stages is
select
a.application_id set_app_id ,
a.request_set_id set_id ,
c.REQUEST_SET_STAGE_ID stage_id,
c.STAGE_NAME stage_name,
c.display_sequence
from
fnd_request_sets a,
fnd_application b,
fnd_request_set_stages c
where
a.application_id=b.application_id
and b.application_short_name=p_setapp
and a.application_id=c.SET_APPLICATION_ID
and a.request_set_id=c.REQUEST_SET_ID
and a.request_set_name=upper(p_set_name)
order by c.display_sequence;

cursor c_start_stage is
select start_stage
from
fnd_request_sets a,
fnd_application b
where
a.application_id=b.application_id
and a.request_set_name=p_set_name
and b.application_short_name=p_setapp;

l_stage_rec c_stages%rowtype;
l_stage_array varcharTableType;
l_counter integer;
l_first_stage_id number;
l_start_stage_id number;
l_set_id number;
l_set_app_id number;

begin
 ---------remove empty stages
 for l_stage_rec in c_stages loop
  if is_stage_empty(l_stage_rec.set_app_id,
                    l_stage_rec.set_id,
                    l_stage_rec.stage_id)='Y' then
     fnd_set.remove_stage(
            request_set=>upper(p_set_name),
            set_application=>p_setapp,
            stage=>l_stage_rec.stage_name);
     commit;
  end if;
end loop;

-----relink stages after the empty stages have been removed
l_counter:=0;
for l_stage_rec in c_stages loop
   l_counter:=l_counter+1;
   if l_counter=1 then
     l_first_stage_id:=l_stage_rec.stage_id;
     l_set_id:=l_stage_rec.set_id;
     l_set_app_id:=l_stage_rec.set_app_id;
   end if;
   l_stage_array(l_counter):=l_stage_rec.stage_name;
end loop;

if l_counter>1 then
 for i in 1..l_counter-1 loop
  fnd_set.link_stages
     (request_set=>upper(p_set_name),
      set_application=>p_setapp,
      from_stage=>l_stage_array(i),
      to_stage=>l_stage_array(i+1),
      success=>'Y',
      warning=>'Y',
      error=>'N');
 end loop;
end if;
commit;

-----check if start stage is valid. If not, reset the start stage
 open c_start_stage;
 fetch c_start_stage into l_start_stage_id;
 if c_start_stage%notfound then
  l_start_stage_id:=null;
 end if;
 close c_start_stage;
 if nvl(l_start_stage_id, -1)<>nvl(l_first_stage_id,-1) then
     ---update the start stage
     update fnd_request_sets
     set start_stage=l_first_stage_id
     where request_set_id=l_set_id
     and application_id=l_set_app_id;
    commit;
 end if;

end;


function is_stage_empty(p_setapp_id number,
                        p_set_id number,
                        p_set_stage_id number) return varchar2 is
cursor c_stage_empty is
select 'N'
from dual
where exists
(select request_set_program_id
 from
  fnd_request_set_programs
 where set_application_id=p_setapp_id
 and request_set_id=p_set_id
 and request_set_stage_id=p_set_stage_id);
l_dummy varchar2(1);
begin
 open c_stage_empty;
 fetch c_stage_empty into l_dummy;
 if c_stage_empty%notfound then
   l_dummy:='Y';
 end if;
 close c_stage_empty;
 return l_dummy;
end;




procedure get_stats_stage_sequence(p_set_name in varchar2,
                               p_set_app in varchar2,
                               p_process_name in varchar2,
                               p_parameter_value in varchar2,
                               p_parameter_type in varchar2,
                               x_stage out NOCOPY varchar2,
                               x_sequence out NOCOPY number) is

cursor c_stage is
select
distinct
b.stage_name,
c.sequence
from
fnd_request_sets a,
fnd_request_set_stages b,
fnd_request_set_programs c,
fnd_request_set_program_args d,
fnd_application e
where a.request_set_id=b.request_set_id
and a.application_id=b.set_application_id
and a.application_id=e.application_id
and e.application_short_name=p_set_app
and a.request_set_name=p_set_name
and b.set_application_id=c.set_application_id
and b.request_set_id=c.request_set_id
and b.request_set_stage_id=c.request_set_stage_id
and c.request_set_id=d.request_set_id
and c.set_application_id=d.application_id
and c.request_set_program_id=d.request_set_program_id
and d.descriptive_flexfield_name='$SRS$.'||p_process_name
and d.default_type=p_parameter_type
and d.default_value=p_parameter_value;


l_stage varchar2(30);
l_sequence number;
l_stage_rec c_stage%rowtype;

begin
  l_stage:=null;
  l_sequence:=null;
  for l_stage_rec in c_stage loop
    l_stage:=l_stage_rec.stage_name;
    l_sequence:=l_stage_rec.sequence;
  end loop;
  x_stage:=l_stage;
  x_sequence:=l_sequence;
exception
  when others then
   x_stage:=null;
   x_sequence:=null;
   raise;
end;

FUNCTION get_apps_schema_name RETURN VARCHAR2 IS

   l_apps_schema_name VARCHAR2(30);

   CURSOR c_apps_schema_name IS
      SELECT oracle_username
	FROM fnd_oracle_userid WHERE oracle_id
	BETWEEN 900 AND 999 AND read_only_flag = 'U';
BEGIN

   OPEN c_apps_schema_name;
   FETCH c_apps_schema_name INTO l_apps_schema_name;
   CLOSE c_apps_schema_name;
   RETURN l_apps_schema_name;

EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_apps_schema_name;


function get_object_owner(p_obj_name in varchar2,p_obj_type in varchar2) return varchar2 is

l_owner varchar2(30);

/**
cursor c_mv_owner(p_apps_schema_name varchar2) is
   (SELECT owner
    FROM all_mviews
    WHERE owner = p_apps_schema_name
    AND  Upper(mview_name) = Upper(p_obj_name))
    UNION ALL
   (SELECT s.table_owner owner
    FROM all_mviews mv, user_synonyms s
    WHERE mv.owner = s.table_owner
    AND mv.mview_name = s.table_name
    AND Upper(mv.mview_name) = Upper(p_obj_name)
    );**/

  cursor c_mv_owner1(p_apps_schema_name varchar2) is
  select owner
  from all_mviews
  where owner=p_apps_schema_name
  and mview_name = Upper(p_obj_name);

    cursor c_mv_owner2 is
    SELECT s.table_owner owner
    FROM all_mviews mv, user_synonyms s
    WHERE mv.owner = s.table_owner
    AND mv.mview_name = s.table_name
    AND s.synonym_name = Upper(p_obj_name);


/**
CURSOR c_tab_owner(p_apps_schema_name varchar2) IS
   (SELECT owner
    FROM all_tables
    WHERE owner = p_apps_schema_name
    AND Upper(table_name) = Upper(p_obj_name))
   UNION ALL
   (SELECT s.table_owner owner
     FROM user_synonyms s, all_tables t
    WHERE t.owner = s.table_owner
    AND t.table_name = s.table_name
    AND t.table_name = Upper(p_obj_name));**/

cursor c_tab_owner1 is
  SELECT s.table_owner owner
     FROM user_synonyms s, all_tables t
    WHERE t.owner = s.table_owner
    AND t.table_name = s.table_name
    AND s.synonym_name = Upper(p_obj_name);

cursor c_tab_owner2(p_apps_schema_name varchar2) IS
select owner
from all_tables
where owner= p_apps_schema_name
and table_name = Upper(p_obj_name);

CURSOR c_view_owner(p_apps_schema_name varchar2) IS
   SELECT p_apps_schema_name owner
     FROM user_views
     WHERE view_name = Upper(p_obj_name);

l_view_owner_rec c_view_owner%rowtype;

begin
if g_apps_schema_name is null then
 g_apps_schema_name:=get_apps_schema_name;
end if;

 if p_obj_type='MV' then
   open c_mv_owner1(g_apps_schema_name);
   fetch c_mv_owner1 into l_owner;
   if c_mv_owner1%notfound then
      open c_mv_owner2;
      fetch c_mv_owner2 into l_owner;
      if c_mv_owner2%notfound then
        l_owner:='NOTFOUND';
      end if;
      close c_mv_owner2;
    end if;
   close c_mv_owner1;
 end if;

if p_obj_type='TABLE' then
  open c_tab_owner1;
  fetch c_tab_owner1 into l_owner;
  if c_tab_owner1%notfound then
    open c_tab_owner2(g_apps_schema_name);
    fetch c_tab_owner2 into l_owner;
    if c_tab_owner2%notfound then
      l_owner:='NOTFOUND';
    end if;
    close c_tab_owner2;
  end if;
  close c_tab_owner1;
end if;
if p_obj_type='VIEW' then
 l_owner:='NOTFOUND';
 for l_view_owner_rec in c_view_owner(g_apps_schema_name) loop
  l_owner:=l_view_owner_rec.owner;
 end loop;
end if;
return l_owner;
exception
 when others then
  raise;
end;






---This procedure will move the dimension's dependent
---dimensions to the earlier stage than the stage
---for the dimension itself

-- aguwalan - The following procedure is no longer in use. Also it has issues
-- reported in the Performance Repository
/*
procedure move_depend_dimensions(p_dim_name in varchar2,
                         p_dim_type in varchar2,
                         p_setname in varchar2,
                         p_setapp in varchar2,
                         p_option in varchar2,
                         p_analyze_table in varchar2,
                         p_refresh_mode in varchar2,
                         p_start_stage in number) is

-----this cursor fetches depend dimensions only.
-----if a dimension depdends on non-dimension objects,
----those will be handled in add_table_to_set
cursor c_depend_dimensions is
select distinct
 depend_object_type object_type,
 depend_OBJECT_NAME object_name,
 level
 from bis_obj_dependency a
 where a.enabled_flag='Y'
 and a.object_type<>'VIEW'
 and EXISTS( Select 'Y' from bis_obj_properties b
             where a.depend_object_name=b.object_name
 and a.depend_object_type=b.object_type
 and b.DIMENSION_FLAG='Y' )
 start with a.object_type= p_dim_type and a.object_name=p_dim_name
 connect by prior a.DEPEND_OBJECT_NAME=a.object_name
 and prior a.depend_object_type= a.object_type
 order by level desc;

cursor c_max_level is
select max(level)
 from bis_obj_dependency a
 where a.enabled_flag='Y'
 and EXISTS ( Select 'Y' from bis_obj_properties b
                    where a.depend_object_name=b.object_name
                    and a.depend_object_type=b.object_type
                    and b.DIMENSION_FLAG='Y')
 start with a.object_type= p_dim_type and a.object_name=p_dim_name
 connect by prior a.DEPEND_OBJECT_NAME=a.object_name
 and prior a.depend_object_type=a.object_type
 order by level desc;

 cursor c_process (p_objectname varchar2,p_objecttype varchar2) is
  select distinct
   a.CONC_PROGRAM_NAME  CONCURRENT_PROGRAM_NAME,
   a.CONC_APP_SHORT_NAME APPLICATION_SHORT_NAME
  from
   bis_obj_prog_linkages a,
   fnd_concurrent_programs b
  where a.object_name=p_objectname
  and a.object_type=p_objecttype
  and a.enabled_flag='Y'
  ---and (nvl(a.refresh_mode,'INCR')=p_refresh_mode or nvl(a.refresh_mode,'INCR')='INIT_INCR')
  and decode(nvl(a.refresh_mode,'INCR'),'INIT_INCR','INCR',nvl(a.refresh_mode,'INCR'))=p_refresh_mode
  and a.CONC_PROGRAM_NAME=b.concurrent_program_name
  and a.CONC_APP_ID=b.application_id
  and b.ENABLED_FLAG='Y';

cursor c_min_stage is
  select
   min(b.display_sequence)
  from
  fnd_request_sets a,
  fnd_request_set_stages b,
  fnd_application c
  where a.request_set_id=b.request_set_id
  and a.application_id=b.set_application_id
  and a.application_id=c.application_id
  and c.application_short_name=p_setapp
  and a.request_set_name=upper(p_setname);

l_max_dim_depend_level number;
l_min_stage number;
l_depend_dimension_rec  c_depend_dimensions%rowtype;
l_process_counter integer;
l_process_rec c_process%rowtype;
l_process_name varchar2(30);
l_process_app varchar2(30);
l_exist_stage varchar2(30);
l_exist_stage_number number;
l_exist_sequence number;
l_max_program_seq number;
l_level integer;


begin
  ---add stages if needed
  open c_min_stage;
  fetch c_min_stage into l_min_stage;
  close c_min_stage;
  open c_max_level;
  fetch c_max_level into l_max_dim_depend_level;
  close c_max_level;
--   ----dbms_output.put_Line('dim type: '||p_dim_type);
 --   ----dbms_output.put_Line('dim name: '||p_dim_name);

  ------dbms_output.put_Line('min stage: '||l_min_stage);
   ------dbms_output.put_Line('max level: '||l_max_dim_depend_level);
    -- ----dbms_output.put_Line('p_start_stage: '||p_start_stage);

 ----adding stages if this dimension has more levels of dependencies
 if (l_max_dim_depend_level>0 and p_start_stage-l_max_dim_depend_level*100 <l_min_stage) then
     for i in trunc(l_min_stage/100-1)..p_start_stage/100-l_max_dim_depend_level loop
         -- ----dbms_output.put_Line('i : '||i);
          fnd_set.add_stage
         (name=>g_stage_prompt||' '||to_char(i*100),
          request_set=>upper(p_setname),
          set_application=>p_setapp,
          short_name=>'Stage_'||to_char(i*100),
          description=>null,
          display_sequence=>i*100,
          function_short_name=>'FNDRSSTE',
          function_application=>'FND',
          critical=>'N',
          incompatibilities_allowed=>'N',
          start_stage=>'N',
          language_code=>'US');
    end loop;
    commit;
 end if; --end if l_max_dim_depend_level>0 and......


  ----for each process, check if it exists in the set
  ----no, then add the process to corresponding stage
  --- yes , check the stage to decide
for l_depend_dimension_rec in c_depend_dimensions loop
     --l_objectname:=l_depend_dimension_rec.object_name;
    -- ----dbms_output.put_Line('depend dim: '||l_depend_dimension_rec.object_name);
     l_level:=l_depend_dimension_rec.level;
     l_process_counter:=0;
 for l_process_rec in c_process(l_depend_dimension_rec.object_name,l_depend_dimension_rec.object_type) loop
     l_process_name:=l_process_rec.concurrent_program_name;
    -- ----dbms_output.put_Line('depend dim program name: '||l_process_name);
     l_process_app:=l_process_rec.application_short_name;
     l_process_counter:=l_process_counter+1;
     get_stage_sequence(upper(p_setname),
                        p_setapp,
                        l_process_name,
                        l_process_app,
                        l_exist_stage,
                        l_exist_sequence);

       l_max_program_seq:=get_max_prog_sequence(upper(p_setname),
                                     p_setapp,
                                     'Stage_'||to_char(p_start_stage-l_level*100));
      if l_max_program_seq is null then
            l_max_program_seq:=0;
       end if;

  if l_exist_stage is null then
        begin
          fnd_set.add_program
          (program =>l_process_name ,
  	       program_application=>l_process_app ,
  	       request_set=>upper(p_setname) ,
  	       set_application=>p_setapp ,
           stage=>'Stage_'||to_char(p_start_stage-l_level*100),
           program_sequence=>l_max_program_seq+10,
           critical=>'Y'       ,
           number_of_copies =>0,
           save_output =>'Y',
           style=>null,
           printer=>null);
           commit;
      exception
       when others then
        raise;
      end;
  else
      l_exist_stage_number:=to_number(substr(l_exist_stage,7));
     -----if a same process alreay exist in a set and the stage is later than the current process needed
     ----then we need to remove the existing process and re-add it to the set on an ealier stage
     if l_exist_stage_number>p_start_stage-l_level*100  then
       begin
        fnd_set.remove_program
       (program=>l_process_name,
        program_application=>l_process_app,
        request_set=>upper(p_setname),
        set_application=>p_setapp,
        stage=>l_exist_stage,
        program_sequence=>l_exist_sequence);
        commit;
      exception
       when others then
        raise;
      end;

      begin
           fnd_set.add_program
         (program =>l_process_name ,
    	  program_application=>l_process_app ,
    	  request_set=>upper(p_setname) ,
    	  set_application=>p_setapp,
          stage=>'Stage_'||to_char(p_start_stage-l_level*100),
          program_sequence=>l_max_program_seq+10,
          critical=>'Y'       ,
          number_of_copies =>0,
          save_output =>'Y',
          style=>null,
          printer=>null);
         commit;
        exception
         when others then
          raise;
      end;
   end if; ---end if  l_exist_stage_number>p_s....
  end if; ---end if exist stage is null
  end loop; ---end loop of processes

  ---- if the depend dimension is a MV and
  -----product teams didn't define MV refresh program in RSG
  ----then call RSG generic MV refresh program
 if (l_process_counter = 0 and           -- no product team Refresh Program Defined in RSG
      l_depend_dimension_rec.object_type  = 'MV'    -- 'MV' type
  ) then

  l_process_name := 'BIS_MV_REFRESH';
  l_process_app := 'BIS';

  get_stats_stage_sequence(upper(p_setname),
                           p_setapp,
                           l_process_name,
                           l_depend_dimension_rec.object_name,
                           g_parameter_default_type,
                           l_exist_stage,
                           l_exist_sequence);

   l_max_program_seq:=get_max_prog_sequence(upper(p_setname),
                                             p_setapp,
                                            'Stage_'||to_char(p_start_stage-l_level*100));
   if l_max_program_seq is null then
       l_max_program_seq:=0;
   end if;



 if l_exist_stage is null then
    begin
      fnd_set.add_program(
                program =>l_process_name ,
  	            program_application=>l_process_app ,
  	            request_set=>upper(p_setname) ,
          	    set_application=>p_setapp,
                stage=>'Stage_'||to_char(p_start_stage-l_level*100),
                program_sequence=>l_max_program_seq+10,
                critical=>'Y'       ,
                number_of_copies =>0,
                save_output =>'Y',
                style=>null,
                printer=>null);

      fnd_set.PROGRAM_PARAMETER(
                PROGRAM=>l_process_name,
                PROGRAM_APPLICATION=>l_process_app,
                REQUEST_SET=>upper(p_setname),
                SET_APPLICATION=>p_setapp,
                STAGE=>'Stage_'||to_char(p_start_stage-l_level*100),
                PROGRAM_SEQUENCE=>l_max_program_seq+10,
                PARAMETER=>'Refresh Mode',
                DISPLAY=>'Y',
                MODIFY=> 'Y' ,
                SHARED_PARAMETER=>null ,
                DEFAULT_TYPE=>'Constant',
                DEFAULT_VALUE=>p_refresh_mode
             );

      fnd_set.PROGRAM_PARAMETER(
                PROGRAM=>l_process_name,
                PROGRAM_APPLICATION=>l_process_app,
                REQUEST_SET=>upper(p_setname),
                SET_APPLICATION=>p_setapp,
                STAGE=>'Stage_'||to_char(p_start_stage-l_level*100),
                PROGRAM_SEQUENCE=>l_max_program_seq+10,
                PARAMETER=>'Materialized View',
                DISPLAY=>'Y',
                MODIFY=> 'Y' ,
                SHARED_PARAMETER=>null ,
                DEFAULT_TYPE=>'Constant',
                DEFAULT_VALUE=>l_depend_dimension_rec.object_name );

      commit;
    exception
      when others then
      raise;
    end;
  else
    l_exist_stage_number:=to_number(substr(l_exist_stage,7));
     ----For dimensions, if a same process alreay exist in a set and the stage is later than the current process needed
     ----then we need to remove the existing process and re-add it to the set on an ealier stage
    if l_exist_stage_number>p_start_stage-l_level*100   then
      begin
        fnd_set.remove_program
       (program=>l_process_name,
        program_application=>l_process_app,
        request_set=>upper(p_setname),
        set_application=>p_setapp,
        stage=>l_exist_stage,
        program_sequence=>l_exist_sequence);
        commit;
      exception
       when others then
         raise;
      end;

     begin
        fnd_set.add_program(
                program =>l_process_name ,
  	            program_application=>l_process_app ,
  	            request_set=>upper(p_setname) ,
          	    set_application=>p_setapp,
                stage=>'Stage_'||to_char(p_start_stage-l_level*100),
                program_sequence=>l_max_program_seq+10,
                critical=>'Y'       ,
                number_of_copies =>0,
                save_output =>'Y',
                style=>null,
                printer=>null);

        fnd_set.PROGRAM_PARAMETER(
                PROGRAM=>l_process_name,
                PROGRAM_APPLICATION=>l_process_app,
                REQUEST_SET=>upper(p_setname),
                SET_APPLICATION=>p_setapp,
                STAGE=>'Stage_'||to_char(p_start_stage-l_level*100),
                PROGRAM_SEQUENCE=>l_max_program_seq+10,
                PARAMETER=>'Refresh Mode',
                DISPLAY=>'Y',
                MODIFY=> 'Y' ,
                SHARED_PARAMETER=>null ,
                DEFAULT_TYPE=>'Constant',
                DEFAULT_VALUE=>p_refresh_mode
             );

        fnd_set.PROGRAM_PARAMETER(
                PROGRAM=>l_process_name,
                PROGRAM_APPLICATION=>l_process_app,
                REQUEST_SET=>upper(p_setname),
                SET_APPLICATION=>p_setapp,
                STAGE=>'Stage_'||to_char(p_start_stage-l_level*100),
                PROGRAM_SEQUENCE=>l_max_program_seq+10,
                PARAMETER=>'Materialized View',
                DISPLAY=>'Y',
                MODIFY=> 'Y' ,
                SHARED_PARAMETER=>null ,
                DEFAULT_TYPE=>'Constant',
                DEFAULT_VALUE=>l_depend_dimension_rec.object_name
             );
         commit;
       exception
         when others then
           raise;
       end;
    end if; ---end if l_exist_stage_number>(l_max_leve..
  end if; ---end if exist stage is null
 end if; -- end if for 'MV'  object type

end loop; ---end loop of depend dimensions l_depend_dimension_rec


end;*/



procedure add_object_to_set(p_object_type in varchar2,
                            p_object_name in varchar2,
                            p_object_owner in varchar2,
                            p_setname in varchar2,
                            p_setapp in varchar2,
                            p_option in varchar2,
                            p_analyze_table in varchar2,
                            p_refresh_mode in varchar2,
                            p_portal_exist in varchar2,
                            p_force_full_refresh in varchar2) is

begin
  -- FOR PING
  g_ping_table := T_PING_TABLE();
   add_any_object_to_set(p_object_name,
                             p_object_type,
                             p_setname  ,
                             p_setapp  ,
                             p_option  ,
                             p_analyze_table ,
                             p_refresh_mode  ,
                             p_force_full_refresh );

   /* changes for 'view request set history': insert record into
	bis_request_set_objects. */
	create_rs_objects(upper(p_setname), p_setapp, p_object_type,
	 p_object_name , p_object_owner);



end;






---?????Need to validate this part of logic
----this function will return 'N' if the object has no direct dependency except dimensions
function dependency_exist(p_object_name in varchar2, p_object_type in varchar2) return varchar2 is
cursor c_dependency_exist is
select 'Y'
from dual
where exists
(select a.depend_object_name
from bis_obj_dependency a,
     bis_obj_properties b
where a.depend_object_name=b.object_name(+)
and a.depend_object_type=b.object_type(+)
and a.object_name=p_object_name
and a.object_type=p_object_type
and a.enabled_flag='Y'
and nvl(b.dimension_flag,'N')='N');
l_dummy varchar2(1);
begin
  open c_dependency_exist;
  fetch c_dependency_exist into l_dummy;
  if c_dependency_exist%notfound then
    l_dummy:='N';
  end if;
  close c_dependency_exist;
  return l_dummy;
 exception
  when others then
     raise;
end;




procedure add_mv_log_mgt_programs(p_setname in varchar2,
                                  p_setapp in varchar2,
                                  p_stage_number in number,
                                  p_obj_type in varchar2,
                                  p_obj_name in varchar2,
                                  p_custom_api in varchar2,
                                  p_mode in varchar2,
                                  p_program_name in varchar2,
                                  p_program_app in varchar2) is

L_MAX_PROGRAM_SEQ number;

begin
 l_max_program_seq:=get_max_prog_sequence(upper(p_setname),
                                               p_setapp,
                                                'Stage_'||to_char(p_stage_number));
      if l_max_program_seq is null then
          l_max_program_seq:=0;
      end if;
       begin
        fnd_set.add_program
        (program =>p_program_name ,
  	    program_application=>p_program_app,
  	    request_set=>upper(p_setname),
   	    set_application=>p_setapp ,
        stage=>'Stage_'||to_char(p_stage_number),
        program_sequence=>l_max_program_seq+10,
        critical=>'Y'       ,
        number_of_copies =>0,
        save_output =>'Y',
        style=>null,
        printer=>null);
       commit;

       ------register parameters
       fnd_set.PROGRAM_PARAMETER(
       PROGRAM=>p_program_name,
       PROGRAM_APPLICATION=>p_program_app,
       REQUEST_SET=>upper(p_setname),
       SET_APPLICATION=>p_setapp,
       STAGE=>'Stage_'||to_char(p_stage_number),
       PROGRAM_SEQUENCE=>l_max_program_seq+10,
       PARAMETER=>'API Name',
       DISPLAY=>'Y',
       MODIFY=> 'Y' ,
       SHARED_PARAMETER=>null ,
       DEFAULT_TYPE=>'Constant',
       DEFAULT_VALUE=>p_custom_api
       );

       fnd_set.PROGRAM_PARAMETER(
       PROGRAM=>p_program_name,
       PROGRAM_APPLICATION=>p_program_app,
       REQUEST_SET=>upper(p_setname),
       SET_APPLICATION=>p_setapp,
       STAGE=>'Stage_'||to_char(p_stage_number),
       PROGRAM_SEQUENCE=>l_max_program_seq+10,
       PARAMETER=>'Object Name',
       DISPLAY=>'Y',
       MODIFY=> 'Y' ,
       SHARED_PARAMETER=>null ,
       DEFAULT_TYPE=>'Constant',
       DEFAULT_VALUE=>p_obj_name
       );

       fnd_set.PROGRAM_PARAMETER(
       PROGRAM=>p_program_name,
       PROGRAM_APPLICATION=>p_program_app,
       REQUEST_SET=>upper(p_setname),
       SET_APPLICATION=>p_setapp,
       STAGE=>'Stage_'||to_char(p_stage_number),
       PROGRAM_SEQUENCE=>l_max_program_seq+10,
       PARAMETER=>'Object Type',
       DISPLAY=>'Y',
       MODIFY=> 'Y' ,
       SHARED_PARAMETER=>null ,
       DEFAULT_TYPE=>'Constant',
       DEFAULT_VALUE=>p_obj_type
       );

       fnd_set.PROGRAM_PARAMETER(
       PROGRAM=>p_program_name,
       PROGRAM_APPLICATION=>p_program_app,
       REQUEST_SET=>upper(p_setname),
       SET_APPLICATION=>p_setapp,
       STAGE=>'Stage_'||to_char(p_stage_number),
       PROGRAM_SEQUENCE=>l_max_program_seq+10,
       PARAMETER=>'Mode',
       DISPLAY=>'Y',
       MODIFY=> 'Y' ,
       SHARED_PARAMETER=>null ,
       DEFAULT_TYPE=>'Constant',
       DEFAULT_VALUE=>p_mode
       );
       commit;
      end;

 end;


function get_mv_log (p_object_name in varchar2,p_schema_name in varchar2 ) return varchar2 is
cursor c_logs_for_analyze is
 SELECT DISTINCT LOG_TABLE
   FROM all_snapshot_logs
   WHERE master = p_object_name
   AND log_owner = p_schema_name;

 l_log_name varchar2(30);
begin
  l_log_name:=null;
  open  c_logs_for_analyze;
  fetch c_logs_for_analyze into l_log_name;
  if c_logs_for_analyze%notfound then
      l_log_name:=null;
  end if;
  close c_logs_for_analyze;
  return l_log_name;
 exception
  when no_data_found then
    return null;
  when others then
    raise;
end;




----Added for enhancement 3549337
procedure analyze_objects_in_set(
    p_request_set_code	   IN VARCHAR2,
    p_set_app              IN varchar2) is

cursor c_pages is
select distinct a.object_name,a.object_type
from
bis_request_set_objects a,
fnd_request_sets b,
fnd_application c
where a.request_set_name=b.request_set_name
and a.set_app_id=b.application_id
and b.request_set_name=upper(p_request_set_code)
and b.application_id=c.application_id
and c.application_short_name=p_set_app;

cursor c_objects(p_object_name varchar2,p_object_type varchar2) is
select depend_objects.obj_type,depend_objects.obj_name
from
( select distinct
   obj.depend_OBJECT_NAME obj_name,
   obj.depend_object_type obj_type,
   obj.depend_object_owner obj_owner
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
     where enabled_flag='Y' ) obj
  start with obj.object_type =p_object_type
  and obj.object_name = p_object_name
  connect by prior obj.DEPEND_OBJECT_NAME=obj.object_name
  and prior depend_object_type=object_type
  ) depend_objects
  where depend_objects.obj_type='MV'
  or (depend_objects.obj_type in ('MV','TABLE') and
     depend_objects.obj_type||depend_objects.obj_name in
    (select object_type||object_name from bis_obj_prog_linkages where enabled_flag='Y'));

l_all_objects object_table;
l_pages_rec c_pages%rowtype;
l_obj_rec  c_objects%rowtype;
l_max_program_seq number;


l_exist_flag varchar2(1);
l_obj_owner varchar2(30);
l_log_name varchar2(30);

begin

 g_set_application:='BIS';
 g_fnd_stats:='BIS_BIA_STATS_TABLE';
 g_fnd_stats_app:='BIS';
 l_all_objects:=object_table();


 for l_pages_rec in c_pages loop
   for l_obj_rec in c_objects(l_pages_rec.object_name,l_pages_rec.object_type) loop
      -----dbms_output.put_Line(l_obj_rec.obj_name);
      l_exist_flag:='N';
      if l_all_objects.count()>0 then
         for i in 1..l_all_objects.count() loop
           if l_obj_rec.obj_type=l_all_objects(i).object_type and
               l_obj_rec.obj_name=l_all_objects(i).object_name then
              l_exist_flag:='Y';
              exit;
           end if;
         end loop;
         if l_exist_flag='N' then
            l_all_objects.extend;
           l_all_objects(l_all_objects.last).object_type:=l_obj_rec.obj_type;
           l_all_objects(l_all_objects.last).object_name:=l_obj_rec.obj_name;
         end if;
      else
          l_all_objects.extend;
          l_all_objects(l_all_objects.last).object_type:=l_obj_rec.obj_type;
          l_all_objects(l_all_objects.last).object_name:=l_obj_rec.obj_name;
      end if;
   end loop; --end loop of objects in a page
 end loop; ---end loop of pages


  fnd_set.add_stage
         (name=>g_stage_prompt||' '||to_char(100),
          request_set=>upper(p_request_set_code),
          set_application=> p_set_app,
          short_name=>'Stage_'||to_char(100),
          description=>null,
          display_sequence=>100,
          function_short_name=>'FNDRSSTE',
          function_application=>'FND',
          critical=>'N',
          incompatibilities_allowed=>'N',
          start_stage=>'Y',
          language_code=>'US');
    commit;


   for j in 1..l_all_objects.count() loop

    l_max_program_seq:=get_max_prog_sequence(upper(p_request_set_code),
                                             p_set_app,
                                             'Stage_'||to_char(100));
    if l_max_program_seq is null then
       l_max_program_seq:=0;
    end if;
    --- --dbms_output.put_Line('prog sequence '||l_max_program_seq);

       -------add analyze program for the object
       begin
        fnd_set.add_program
        (program =>g_fnd_stats ,
  	    program_application=>g_fnd_stats_app,
  	    request_set=>upper(p_request_set_code) ,
   	    set_application=>p_set_app ,
        stage=>'Stage_'||to_char(100),
        program_sequence=>l_max_program_seq+10,
        critical=>'Y'       ,
        number_of_copies =>0,
        save_output =>'Y',
        style=>null,
        printer=>null);
       commit;

       fnd_set.PROGRAM_PARAMETER(
       PROGRAM=>g_fnd_stats,
       PROGRAM_APPLICATION=>g_fnd_stats_app,
       REQUEST_SET=>upper(p_request_set_code),
       SET_APPLICATION=>p_set_app,
       STAGE=>'Stage_'||to_char(100),
       PROGRAM_SEQUENCE=>l_max_program_seq+10,
       PARAMETER=>'Object Type',
       DISPLAY=>'Y',
       MODIFY=> 'Y' ,
       SHARED_PARAMETER=>null ,
       DEFAULT_TYPE=>'Constant',
       DEFAULT_VALUE=>l_all_objects(j).object_type
       );

       fnd_set.PROGRAM_PARAMETER(
       PROGRAM=>g_fnd_stats,
       PROGRAM_APPLICATION=>g_fnd_stats_app,
       REQUEST_SET=>upper(p_request_set_code),
       SET_APPLICATION=>p_set_app,
       STAGE=>'Stage_'||to_char(100),
       PROGRAM_SEQUENCE=>l_max_program_seq+10,
       PARAMETER=>'Object Name',
       DISPLAY=>'Y',
       MODIFY=> 'Y' ,
       SHARED_PARAMETER=>null ,
       DEFAULT_TYPE=>'Constant',
       DEFAULT_VALUE=>l_all_objects(j).object_name
       );
       commit;
    end;

  end loop;
 exception
  when others then
   raise;
end;


----this procedure is added for enhancement 3999465 and 4251030
----for RSG to support auto-gen reports
-----it adds load dimension program and delete indicator data program
----before the load summary program
procedure add_other_loader_programs(p_setname in varchar2,
                                    p_setapp in varchar2,
                                    p_refresh_mode in varchar2,
                                    p_force_full_refresh in varchar2,
                                    p_set_id number,
									p_set_app_id number,
									p_stage_id number,
									p_stage_name varchar2) is

cursor c_stage_objects  is
select distinct
'REPORT' object_type,
c.default_value object_name
from
fnd_request_set_programs a,
fnd_request_set_program_args c
where a.set_application_id=p_set_app_id
and a.request_set_id=p_set_id
and a.request_set_stage_id=p_stage_id
and a.request_set_id=c.request_set_id
and a.set_application_id=c.application_id
and a.request_set_program_id=c.request_set_program_id
and c.descriptive_flexfield_name='$SRS$.'||g_bsc_loader_ind_program
and c.default_type=g_parameter_default_type
and c.application_column_name='ATTRIBUTE1';

l_object_rec c_stage_objects%rowtype;
l_counter number;
l_current_stage_number number;
l_dim_stage_number number;
l_del_stage_number number;
l_max_program_seq number;


begin

  l_current_stage_number:=to_number(substr(p_stage_name,7));
---  dbms_output.put_line('l_current_stage_number: '||l_current_stage_number);
  l_counter:=0;
  for l_object_rec in c_stage_objects loop
    l_counter:=l_counter+1;

    if   l_counter=1 then
       if l_current_stage_number>=300 then
            l_dim_stage_number:=l_current_stage_number-100;
         if   p_refresh_mode='INIT' then
		    l_del_stage_number:=l_current_stage_number-200;
		 end if ;----p_refresh_mode
       elsif l_current_stage_number>=200 then
           l_dim_stage_number:=l_current_stage_number-100;
        	 --dbms_output.put_line('l_dim_stage_number '||l_dim_stage_number);
           if   p_refresh_mode='INIT' then
	         l_del_stage_number:=l_current_stage_number-100-35;
			-- dbms_output.put_line('l_del_stage_number '||l_del_stage_number);
	          fnd_set.add_stage
             (name=>g_stage_prompt||' '||to_char(l_del_stage_number),
              request_set=>upper(p_setname),
              set_application=>p_setapp,
              short_name=>'Stage_'||to_char(l_del_stage_number),
              description=>null,
              display_sequence=>l_del_stage_number,
              function_short_name=>'FNDRSSTE',
              function_application=>'FND',
              critical=>'N',
              incompatibilities_allowed=>'N',
              start_stage=>'N',
              language_code=>'US');
			  commit;
    	   end if ;----p_refresh_mode
      else ---l_current_stage_number>=100
           l_dim_stage_number:=l_current_stage_number-30;
             fnd_set.add_stage
             (name=>g_stage_prompt||' '||to_char(l_dim_stage_number),
              request_set=>upper(p_setname),
              set_application=>p_setapp,
              short_name=>'Stage_'||to_char(l_dim_stage_number),
              description=>null,
              display_sequence=>l_dim_stage_number,
              function_short_name=>'FNDRSSTE',
              function_application=>'FND',
              critical=>'N',
              incompatibilities_allowed=>'N',
              start_stage=>'N',
              language_code=>'US');
			  commit;
           if   p_refresh_mode='INIT' then
              l_del_stage_number:=l_current_stage_number-35;
		    fnd_set.add_stage
             (name=>g_stage_prompt||' '||to_char(l_del_stage_number),
              request_set=>upper(p_setname),
              set_application=>p_setapp,
              short_name=>'Stage_'||to_char(l_del_stage_number),
              description=>null,
              display_sequence=>l_del_stage_number,
              function_short_name=>'FNDRSSTE',
              function_application=>'FND',
              critical=>'N',
              incompatibilities_allowed=>'N',
              start_stage=>'N',
              language_code=>'US');
			  commit;
    	   end if ;----p_refresh_mode
	  end if;---end if   l_current_stage_number>300
    end if;---end if l_counter=1



   if p_refresh_mode='INIT' and p_force_full_refresh='Y' then
      l_max_program_seq:=get_max_prog_sequence(upper(p_setname),
                                               p_setapp,
                                              'Stage_'||to_char(l_del_stage_number));

	  if l_max_program_seq is null then
           l_max_program_seq:=0;
      end if;

      fnd_set.add_program
        (program =>g_bsc_loader_del_program ,
  	    program_application=>'BSC',
  	    request_set=>upper(p_setname) ,
   	    set_application=>p_setapp ,
        stage=>'Stage_'||to_char(l_del_stage_number),
        program_sequence=>l_max_program_seq+10,
        critical=>'Y'       ,
        number_of_copies =>0,
        save_output =>'Y',
        style=>null,
        printer=>null);



       fnd_set.PROGRAM_PARAMETER(
       PROGRAM=>g_bsc_loader_del_program,
       PROGRAM_APPLICATION=>'BSC',
       REQUEST_SET=>upper(p_setname),
       SET_APPLICATION=>p_setapp,
       STAGE=>'Stage_'||to_char(l_del_stage_number),
       PROGRAM_SEQUENCE=>l_max_program_seq+10,
       PARAMETER=>'x_indicators',
       DISPLAY=>'Y',
       MODIFY=> 'Y' ,
       SHARED_PARAMETER=>null ,
       DEFAULT_TYPE=>'Constant',
       DEFAULT_VALUE=>l_object_rec.object_name
       );

       fnd_set.PROGRAM_PARAMETER(
       PROGRAM=>g_bsc_loader_del_program,
       PROGRAM_APPLICATION=>'BSC',
       REQUEST_SET=>upper(p_setname),
       SET_APPLICATION=>p_setapp,
       STAGE=>'Stage_'||to_char(l_del_stage_number),
       PROGRAM_SEQUENCE=>l_max_program_seq+10,
       PARAMETER=>'x_keep_input_table_data',
       DISPLAY=>'Y',
       MODIFY=> 'Y' ,
       SHARED_PARAMETER=>null ,
       DEFAULT_TYPE=>'Constant',
       DEFAULT_VALUE=>'Y'
       );
       commit;
   end if; ----p_refresh_mode ='INIT' and force full refresh='Y'

   l_max_program_seq:=get_max_prog_sequence(upper(p_setname),
                                               p_setapp,
                                              'Stage_'||to_char(l_dim_stage_number));

    if l_max_program_seq is null then
           l_max_program_seq:=0;
      end if;

   fnd_set.add_program
        (program =>g_bsc_loader_dim_program ,
  	    program_application=>'BSC',
  	    request_set=>upper(p_setname) ,
   	    set_application=>p_setapp ,
        stage=>'Stage_'||to_char(l_dim_stage_number),
        program_sequence=>l_max_program_seq+10,
        critical=>'Y'       ,
        number_of_copies =>0,
        save_output =>'Y',
        style=>null,
        printer=>null);


    fnd_set.PROGRAM_PARAMETER(
       PROGRAM=>g_bsc_loader_dim_program,
       PROGRAM_APPLICATION=>'BSC',
       REQUEST_SET=>upper(p_setname),
       SET_APPLICATION=>p_setapp,
       STAGE=>'Stage_'||to_char(l_dim_stage_number),
       PROGRAM_SEQUENCE=>l_max_program_seq+10,
       PARAMETER=>'x_indicators',
       DISPLAY=>'Y',
       MODIFY=> 'Y' ,
       SHARED_PARAMETER=>null ,
       DEFAULT_TYPE=>'Constant',
       DEFAULT_VALUE=>l_object_rec.object_name
       );

   commit;

 end loop;

end;

/*
 * Overloading wrapup api to support Enh#4418520-aguwalan
 */
PROCEDURE wrapup( p_setname IN VARCHAR2,
                     p_setapp IN VARCHAR2,
                     p_option IN VARCHAR2,
                     p_analyze_table IN VARCHAR2,
                    p_refresh_mode IN VARCHAR2,
                    p_force_full_refresh IN VARCHAR2,
                    p_alert_flag IN VARCHAR2) IS
BEGIN
  wrapup(p_setname, p_setapp, p_option, p_analyze_table, p_refresh_mode, p_force_full_refresh, p_alert_flag, 'Y');
END;

/**
The wrapup performs the following activities
(1) add stages for analyzing MV and other objects
(2) add stages for MV log management
(3) Add stages: first stage---Update object implementation flag
                last stage---MV dummy refresh programs
                             Alerting
(4) remove empty stages
It is called from UI
**/
procedure wrapup( p_setname in varchar2,
                     p_setapp in varchar2,
                     p_option in varchar2,
                     p_analyze_table in varchar2,
                    p_refresh_mode in varchar2,
                    p_force_full_refresh in varchar2,
                    p_alert_flag in varchar2,
                    p_rsg_history_flag in varchar2) is


cursor c_stages is
select
a.application_id set_app_id ,
a.request_set_id set_id ,
a.request_set_name set_name,
b.application_short_name set_app,
c.REQUEST_SET_STAGE_ID stage_id,
c.STAGE_NAME stage_name,
c.display_sequence
from
fnd_request_sets a,
fnd_application b,
fnd_request_set_stages c
where
a.application_id=b.application_id
and b.application_short_name=p_setapp
and a.application_id=c.SET_APPLICATION_ID
and a.request_set_id=c.REQUEST_SET_ID
and a.request_set_name=upper(p_setname)
order by c.display_sequence;

 cursor c_max_stage is
 select
  max(b.display_sequence)
 from
  fnd_request_sets a,
  fnd_request_set_stages b,
  fnd_application c
  where a.request_set_id=b.request_set_id
  and a.application_id=b.set_application_id
  and a.application_id=c.application_id
  and c.application_short_name=p_setapp
  and a.request_set_name=upper(p_setname);

 cursor c_min_stage is
  select
   min(b.display_sequence)
  from
  fnd_request_sets a,
  fnd_request_set_stages b,
  fnd_application c
  where a.request_set_id=b.request_set_id
  and a.application_id=b.set_application_id
  and a.application_id=c.application_id
  and c.application_short_name=p_setapp
  and a.request_set_name=upper(p_setname);


l_stage_rec c_stages%rowtype;

l_max_stage number;
l_min_stage number;


----For fixing bug 3647514. Store objects in set into global temp table
---BIS_BIA_RSG_STAGE_OBJECTS
----join to BIS_BIA_RSG_STAGE_OBJECTS when retrieve objects to analyze
---This cursor should also fetch those MVs that are refreshed by
----RSG generic MV refresh program
cursor c_stage_objects(p_set_id number,p_set_app_id number,p_stage_id number,p_set_name varchar2,p_set_app varchar2) is
select distinct
c.object_type,
c.object_name
from
fnd_request_set_programs a,
fnd_concurrent_programs b,
bis_obj_prog_linkages c,
BIS_BIA_RSG_STAGE_OBJECTS d
where a.set_application_id=p_set_app_id
and a.request_set_id=p_set_id
and a.request_set_stage_id=p_stage_id
and a.program_application_id=b.application_id
and a.concurrent_program_id=b.concurrent_program_id
and b.application_id=c.CONC_APP_ID
and b.concurrent_program_name=c.CONC_PROGRAM_NAME
and c.enabled_flag='Y'
and c.object_type=d.object_type
and c.object_name=d.object_name
and d.set_name=p_set_name
and d.set_app=p_set_app
union
select distinct
'MV' object_type,
c.default_value object_name
from
fnd_request_set_programs a,
fnd_request_set_program_args c
where a.set_application_id=p_set_app_id
and a.request_set_id=p_set_id
and a.request_set_stage_id=p_stage_id
and a.request_set_id=c.request_set_id
and a.set_application_id=c.application_id
and a.request_set_program_id=c.request_set_program_id
and c.descriptive_flexfield_name='$SRS$.BIS_MV_REFRESH'
and c.default_type=g_parameter_default_type
and c.application_column_name='ATTRIBUTE2';


cursor c_custom_api (p_set_id number,p_set_app_id number,p_stage_id number,p_obj_name varchar2,p_obj_type varchar2)
is
select
distinct d.CUSTOM_API  custom_api
from
fnd_request_set_programs a,
fnd_concurrent_programs b,
bis_obj_prog_linkages c,
bis_obj_properties d
where a.set_application_id=p_set_app_id
and a.request_set_id=p_set_id
and a.request_set_stage_id=p_stage_id
and a.program_application_id=b.application_id
and a.concurrent_program_id=b.concurrent_program_id
and b.application_id=c.CONC_APP_ID
and b.concurrent_program_name=c.CONC_PROGRAM_NAME
and c.enabled_flag='Y'
and c.refresh_mode in ('INIT','INIT_INCR')-----?? can we use INIT_INCR here
and c.object_type=d.object_type
and c.object_name=d.object_name
and d.object_type=p_obj_type
and d.object_name=p_obj_name;


l_dummy varchar2(1);
l_stage_object_rec c_stage_objects%rowtype;
l_counter integer;
l_mv_stage_number number;
l_snp_drop_stage_number number;
l_snp_create_stage_number number;
l_max_program_seq number;
l_reset_stage_number number;
l_log_name varchar2(30);
l_object_owner varchar2(30);
l_custom_api varchar2(80);

begin
   g_set_application:='BIS';
    g_fnd_stats:='BIS_BIA_STATS_TABLE';
   g_fnd_stats_app:='BIS';
   g_parameter_default_type:='C';

   g_create_snpl:='BIS_BIA_RSG_LOG_MGMNT';
   g_create_snpl_app:='BIS';

----Added for enhancement 3549337. Request set for analyzing programs only
if p_refresh_mode is null and p_analyze_table='Y' then

    analyze_objects_in_set(
    p_setname,
    p_setapp );


open c_max_stage;
fetch c_max_stage into l_max_stage;
close c_max_stage;


  -- Add the last stage as the RSG Report History collection program Enh#3473874 aguwalan
  -- this case handles Request set for analyzing programs only

  -- Enh#4418520-aguwalan
  add_link_history_stage(p_setname, p_setapp, l_max_stage, p_rsg_history_flag);

 remove_empty_stages(p_setname,
                    p_setapp);

 create_rs_option(upper(p_setname), p_setapp,
	p_refresh_mode, p_analyze_table,p_force_full_refresh, p_alert_flag, p_rsg_history_flag);

    return;
end if;


for l_stage_rec in c_stages loop
  l_counter:=0;
  l_mv_stage_number:=to_number(substr(l_stage_rec.stage_name,7))+50;
  l_snp_drop_stage_number:=to_number(substr(l_stage_rec.stage_name,7))-10;
  l_snp_create_stage_number:=to_number(substr(l_stage_rec.stage_name,7))+10;

  for l_stage_object_rec in c_stage_objects(l_stage_rec.set_id,l_stage_rec.set_app_id,l_stage_rec.stage_id,l_stage_rec.set_name,l_stage_rec.set_app) loop
     l_counter:=l_counter+1;
     if l_counter=1 then
       ----adding one stage for analyzing objects after current stage
        if p_analyze_table='Y' then
             fnd_set.add_stage
             (name=>g_stage_prompt||' '||to_char(l_mv_stage_number),
              request_set=>upper(p_setname),
              set_application=>p_setapp,
              short_name=>'Stage_'||to_char(l_mv_stage_number),
              description=>null,
              display_sequence=>l_mv_stage_number,
              function_short_name=>'FNDRSSTE',
              function_application=>'FND',
              critical=>'N',
              incompatibilities_allowed=>'N',
              start_stage=>'N',
              language_code=>'US');
              commit;
        end if;---end if analyze table='Y'
        -------adding stages for dropping/creating snapshot logs for tables
        if p_refresh_mode='INIT' then
          fnd_set.add_stage
             (name=>g_stage_prompt||' '||to_char(l_snp_drop_stage_number),
              request_set=>upper(p_setname),
              set_application=>p_setapp,
              short_name=>'Stage_'||to_char(l_snp_drop_stage_number),
              description=>null,
              display_sequence=>l_snp_drop_stage_number,
              function_short_name=>'FNDRSSTE',
              function_application=>'FND',
              critical=>'N',
              incompatibilities_allowed=>'N',
              start_stage=>'N',
              language_code=>'US');
              commit;

              fnd_set.add_stage
             (name=>g_stage_prompt||' '||to_char(l_snp_create_stage_number),
              request_set=>upper(p_setname),
              set_application=>p_setapp,
              short_name=>'Stage_'||to_char(l_snp_create_stage_number),
              description=>null,
              display_sequence=>l_snp_create_stage_number,
              function_short_name=>'FNDRSSTE',
              function_application=>'FND',
              critical=>'N',
              incompatibilities_allowed=>'N',
              start_stage=>'N',
              language_code=>'US');
              commit;
        end if;-----end if refresh mode ='INIT'
    end if; ---end if counter=1


    --------call analyze object for each MV , table and log
    if  p_analyze_table='Y' and (l_stage_object_rec.object_type='MV' or l_stage_object_rec.object_type='TABLE') then
     --  ----dbms_output.put_Line('debug point 1');
      -- ----dbms_output.put_Line('object name +type'||l_stage_object_rec.object_name||'+'||l_stage_object_rec.object_type);

        l_max_program_seq:=get_max_prog_sequence(upper(p_setname),
                                               p_setapp,
                                                'Stage_'||to_char(l_mv_stage_number));
      if l_max_program_seq is null then
          l_max_program_seq:=0;
      end if;
       begin
        fnd_set.add_program
        (program =>g_fnd_stats ,
  	    program_application=>g_fnd_stats_app,
  	    request_set=>upper(p_setname) ,
   	    set_application=>p_setapp ,
        stage=>'Stage_'||to_char(l_mv_stage_number),
        program_sequence=>l_max_program_seq+10,
        critical=>'Y'       ,
        number_of_copies =>0,
        save_output =>'Y',
        style=>null,
        printer=>null);
       commit;
      -- ----dbms_output.put_Line('debug point 2');
       -------register parameters for STATS program for the current object
       fnd_set.PROGRAM_PARAMETER(
       PROGRAM=>g_fnd_stats,
       PROGRAM_APPLICATION=>g_fnd_stats_app,
       REQUEST_SET=>upper(p_setname),
       SET_APPLICATION=>p_setapp,
       STAGE=>'Stage_'||to_char(l_mv_stage_number),
       PROGRAM_SEQUENCE=>l_max_program_seq+10,
       PARAMETER=>'Object Type',
       DISPLAY=>'Y',
       MODIFY=> 'Y' ,
       SHARED_PARAMETER=>null ,
       DEFAULT_TYPE=>'Constant',
       DEFAULT_VALUE=>l_stage_object_rec.object_type
       );
        -------dbms_output.put_Line('debug point 3');
       fnd_set.PROGRAM_PARAMETER(
       PROGRAM=>g_fnd_stats,
       PROGRAM_APPLICATION=>g_fnd_stats_app,
       REQUEST_SET=>upper(p_setname),
       SET_APPLICATION=>p_setapp,
       STAGE=>'Stage_'||to_char(l_mv_stage_number),
       PROGRAM_SEQUENCE=>l_max_program_seq+10,
       PARAMETER=>'Object Name',
       DISPLAY=>'Y',
       MODIFY=> 'Y' ,
       SHARED_PARAMETER=>null ,
       DEFAULT_TYPE=>'Constant',
       DEFAULT_VALUE=>l_stage_object_rec.object_name
       );
       commit;
       --------dbms_output.put_Line('debug point 4');
      end;

        end if;---end if object type ='MV' or 'TABLE'


    -------Add MV log management programs (drop/create) for tables that have custom api defined
    ------and its initial loading program is pulled into the request set
    ----in BIA 4.0.8, we add one more condition p_force_full_refresh='Y'
    ----so that table MV log management is in sync with MV log management for MVs
    ---i.e only manage MV logs in clear and initial load
    l_custom_api:=null;
    --  --dbms_output.put_Line('object name: '||l_stage_object_rec.object_name);
     -- --dbms_output.put_Line('object type: '||l_stage_object_rec.object_type);
    if l_stage_object_rec.object_type='TABLE' and p_refresh_mode='INIT' and p_force_full_refresh='Y' then
      open c_custom_api (l_stage_rec.set_id,l_stage_rec.set_app_id,l_stage_rec.stage_id,l_stage_object_rec.object_name,l_stage_object_rec.object_type);
      fetch c_custom_api into l_custom_api;
      close c_custom_api;
      ------dbms_output.put_Line('custom api: '||l_custom_api);
      if l_custom_api is not null then
          add_mv_log_mgt_programs(p_setname ,
                                  p_setapp ,
                                  l_snp_drop_stage_number,
                                  l_stage_object_rec.object_type,
                                  l_stage_object_rec.object_name,
                                  l_custom_api ,
                                  'BEFORE',
                                  g_create_snpl,
                                  g_create_snpl_app);
          -----dbms_output.put_Line('added drop log programs');

           add_mv_log_mgt_programs(p_setname ,
                        p_setapp ,
                        l_snp_create_stage_number,
                        l_stage_object_rec.object_type,
                        l_stage_object_rec.object_name,
                        l_custom_api ,
                        'AFTER',
                        g_create_snpl,
                        g_create_snpl_app);

         ----  --dbms_output.put_Line('added create log programs');

      end if ;----l_custom_api is not null
    end if ;-----object_type='TABLE' and p_refresh_mode='INIT' and p_force_full_refresh='Y'

  end loop;---end loop for objects in the stage

  ----add this API call for enhancement 3999465 and 4251030
   add_other_loader_programs(p_setname ,
                                    p_setapp,
                                    p_refresh_mode ,
                                    p_force_full_refresh ,
                                    l_stage_rec.set_id ,
									l_stage_rec.set_app_id,
									l_stage_rec.stage_id ,
									l_stage_rec.stage_name );

end loop;----end loop for stages in the set

-----add First and last stages for MV dummy refresh
open c_max_stage;
fetch c_max_stage into l_max_stage;
close c_max_stage;

open c_min_stage;
fetch c_min_stage into l_min_stage;
close c_min_stage;

--------dbms_output.put_Line('before calling add_first_last');
if p_refresh_mode in ('INIT','INCR') then
  -- Adds the last Report History Collection Stage also Enh#3473874
  -- Enh#4418520-aguwalan
  add_first_last_stages(p_setname,p_setapp,l_max_stage,l_min_stage, p_rsg_history_flag);
end if;
-------dbms_output.put_Line('after calling add_first_last');

------The last step is to cleanup empty stages
remove_empty_stages(p_setname,
                    p_setapp);



/* changes for 'view request set history': insert record into
	bis_request_set_options. */
	create_rs_option(upper(p_setname), p_setapp,
	p_refresh_mode, p_analyze_table,p_force_full_refresh, p_alert_flag, p_rsg_history_flag);


end;  ---end wrapup;

-- Enh#4418520-aguwalan; Adding another option for RSG History Collection
procedure create_rs_option(p_set_name in varchar2, p_set_app in varchar2,
p_refresh_mode in varchar2, p_analyze_table in varchar2,p_force_full in varchar2,
p_alert_flag in varchar2, p_rsg_history_flag in VARCHAR2) is
l_stmt       VARCHAR2 (2000);
l_set_app_id number;

begin
  -- perform
   g_current_user_id            :=  FND_GLOBAL.User_id;
   g_current_login_id           :=  FND_GLOBAL.Login_id;

  select APPLICATION_ID into l_set_app_id from fnd_application where
 	application_short_name=p_set_app;
  l_stmt := 'insert into bis_request_set_options(request_set_name, set_app_id,
	option_name,option_value, CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,LAST_UPDATE_DATE) values
	(:1,:2,:3,:4,:5,:6,:7,:8,:9)';
  EXECUTE IMMEDIATE l_stmt USING p_set_name, l_set_app_id,'REFRESH_MODE',p_refresh_mode,
    g_current_user_id, sysdate,g_current_user_id,
   g_current_login_id, sysdate ;
  commit;

  EXECUTE IMMEDIATE l_stmt USING p_set_name, l_set_app_id,'ANALYZE_OBJECT',p_analyze_table,
    g_current_user_id, sysdate,g_current_user_id,
   g_current_login_id, sysdate ;
  commit;

  EXECUTE IMMEDIATE l_stmt USING p_set_name, l_set_app_id,'FORCE_FULL',p_force_full,
    g_current_user_id, sysdate,g_current_user_id,
   g_current_login_id, sysdate ;
  commit;

  EXECUTE IMMEDIATE l_stmt USING p_set_name, l_set_app_id,'ALERT_FLAG',p_alert_flag,
    g_current_user_id, sysdate,g_current_user_id,
   g_current_login_id, sysdate ;
  commit;

  -- Enh#4418520-aguwalan
  EXECUTE IMMEDIATE l_stmt USING p_set_name, l_set_app_id,'HISTORY_COLLECT',p_rsg_history_flag,
    g_current_user_id, sysdate, g_current_user_id, g_current_login_id, sysdate ;
  commit;

end create_rs_option ;

procedure create_rs_objects(p_set_name in varchar2, p_set_app in varchar2,
p_object_type in varchar2, p_object_name in varchar2, p_object_owner in
varchar2) is
l_stmt       VARCHAR2 (2000);
l_object_owner varchar2(50):=null;
l_set_app_id number;
cursor c_owner is select distinct OBJECT_OWNER from bis_obj_dependency
where object_type=p_object_type and object_name=p_object_name;
l_module varchar2(300) := 'bis.BIS_CREATE_REQUESTSET.create_rs_objects';
l_func1  varchar2(300);
l_func2  varchar2(300);
l_cursor_id integer;
l_rows integer;

begin
  log(l_module, 'Inside ' || l_module );
   g_current_user_id            :=  FND_GLOBAL.User_id;
   g_current_login_id           :=  FND_GLOBAL.Login_id;

  -- bug#3426783.
  -- added to strip _OA on the fly, if the page name has been migrated
  IF(p_object_type = 'PAGE') THEN
    l_stmt := 'BEGIN :function_name := bis_impl_dev_pkg.get_function_by_page(:page_name); END;';
    l_cursor_id:=DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.parse(l_cursor_id,l_stmt,DBMS_SQL.V7);
    DBMS_SQL.bind_variable(l_cursor_id,'page_name',p_object_name, 300);
    DBMS_SQL.bind_variable(l_cursor_id,'function_name',l_func1, 300);
    l_rows:=DBMS_SQL.execute(l_cursor_id);
    DBMS_SQL.variable_value(l_cursor_id,'function_name',l_func1);
    DBMS_SQL.close_cursor(l_cursor_id);
    log(l_module, 'Function name for ' || p_object_name || ' : ' || l_func1);

    l_cursor_id:=DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.parse(l_cursor_id,l_stmt,DBMS_SQL.V7);
    DBMS_SQL.bind_variable(l_cursor_id,'page_name',p_object_name, 300);
    DBMS_SQL.bind_variable(l_cursor_id,'function_name', l_func2 || '_OA', 300);
    l_rows:=DBMS_SQL.execute(l_cursor_id);
    DBMS_SQL.variable_value(l_cursor_id,'function_name',l_func2);
    DBMS_SQL.close_cursor(l_cursor_id);
    log(l_module, 'Function name for ' || p_object_name || '_OA' || ' : ' || l_func2);

    IF( p_object_name = l_func1 AND
        l_func1 = l_func2 ) THEN
        log(l_module, 'Migrating ' || p_object_name || '_OA' || ' to '|| p_object_name);
        l_stmt :='
        UPDATE bis_request_set_objects
        set object_name = :1
        where object_name = :2
        and object_type = ''PAGE''
        ';
        EXECUTE IMMEDIATE l_stmt USING p_object_name, p_object_name||'_OA';

        log(l_module, 'Migrated ' || SQL%ROWCOUNT || ' rows');

    END IF;
  END IF;

  --------dbms_output.put_Line('within create rs objects');
  select APPLICATION_ID into l_set_app_id from fnd_application where
 	application_short_name=p_set_app;
  if (p_object_owner is null) then
   open c_owner;
   fetch c_owner into l_object_owner;
   close c_owner;
  else l_object_owner:=p_object_owner;
  end if;
  l_stmt := 'insert into bis_request_set_objects(request_set_name, set_app_id,
	object_type,object_name, object_owner, CREATED_BY,
	CREATION_DATE,LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,LAST_UPDATE_DATE) values
	(:1,:2,:3,:4,:5,:6,:7,:8,:9,:10)';
    --------dbms_output.put_Line('before insert');
  EXECUTE IMMEDIATE l_stmt USING p_set_name, l_set_app_id,p_object_type,
	p_object_name, l_object_owner,
    g_current_user_id, sysdate,g_current_user_id,
   g_current_login_id, sysdate ;
      --- ----dbms_output.put_Line('after insert');
  commit;
  EXCEPTION WHEN OTHERS THEN
    log(l_module, sqlerrm);
   --- ----dbms_output.put_Line('end of create rs objects');
end create_rs_objects;

procedure delete_rs_objects(p_set_name in varchar2, p_set_app in varchar2) is
l_stmt       VARCHAR2 (2000);
l_set_app_id number;
begin
 ---- ----dbms_output.put_Line('within delete rs objects');
  select APPLICATION_ID into l_set_app_id from fnd_application where
 	application_short_name=p_set_app;
  l_stmt := 'delete bis_request_set_objects where request_set_name=:a and
	set_app_id=:b';
  EXECUTE IMMEDIATE l_stmt USING p_set_name, l_set_app_id;
  commit;
   --------dbms_output.put_Line('end of delete rs objects');
end delete_rs_objects;

procedure delete_rs_option(p_set_name in varchar2, p_set_app in varchar2) is
l_stmt       VARCHAR2 (2000);
l_set_app_id number;
begin
 -- ----dbms_output.put_Line('within delete rs options');
  select APPLICATION_ID into l_set_app_id from fnd_application where
 	application_short_name=p_set_app;
  l_stmt := 'delete bis_request_set_options where request_set_name=:a and
	set_app_id=:b';
  EXECUTE IMMEDIATE l_stmt USING p_set_name, l_set_app_id;
  COMMIT;
  --------dbms_output.put_Line('end of delete rs options');
end delete_rs_option;


function object_has_data(p_object_name in varchar2, p_object_type in varchar2,p_object_owner in varchar2) return varchar2
is
l_sql varchar2(2000);
l_count number;
l_owner varchar2(30);
l_timestamp date;
l_module varchar2(300) := 'bis.BIS_CREATE_REQUESTSET.object_has_data';

begin
 ---First check if the object physically exists
l_owner:=get_object_owner(p_object_name,p_object_type);
log(l_module, 'Owner ' || l_owner);

l_timestamp := sysdate;
if nvl(l_owner,'NOTFOUND')<>'NOTFOUND' then
   l_sql:='select /*+ FIRST_ROWS */ 1 from '||l_owner||'.'||p_object_name||' where rownum=1';
   log(l_module, 'Executing ' || l_sql);
  --- ----dbms_output.put_Line('before execute :'||l_sql);
   execute immediate l_sql into l_count;
  ---- ----dbms_output.put_Line('after execute :'||l_sql);
  log(l_module, duration(sysdate - l_timestamp));

  if l_count=1 then
    return 'Y';
  else
    return 'N';
  end if;
else
  return 'N';
end if ; ---l_owner<>'NOTFOUND'
exception
 when no_data_found then
    return 'N';
 when others then
   raise;
end;


procedure add_first_last_stages(p_set_name in varchar2,p_set_app in varchar2,p_max_stage in number,p_min_stage in number,
                                p_rsg_history_flag in varchar2) is

begin
--- ----dbms_output.put_Line('min stage :'||p_min_stage);
 --------dbms_output.put_Line('max stage :'||p_max_stage);
 if p_min_stage>0 then
 --Add Update object implementation flag program at the begining of the request set
     fnd_set.add_stage
         (name=>g_stage_prompt||' '||to_char(p_min_stage-50),
          request_set=>upper(p_set_name),
          set_application=>p_set_app,
          short_name=>'Stage_'||to_char(p_min_stage-50),
          description=>null,
          display_sequence=>p_min_stage-50,
          function_short_name=>'FNDRSSTE',
          function_application=>'FND',
          critical=>'N',
          incompatibilities_allowed=>'N',
          start_stage=>'N',
          language_code=>'US');

          commit;
         -------dbms_output.put_Line('added stage: '||'Stage_'||to_char(p_min_stage-50));

       fnd_set.add_program
        (program =>'BIS_RSG_PREP' ,
  	    program_application=>'BIS',
  	    request_set=>upper(p_set_name) ,
   	    set_application=>p_set_app ,
        stage=>'Stage_'||to_char(p_min_stage-50),
        program_sequence=>10,
        critical=>'Y'       ,
        number_of_copies =>0,
        save_output =>'Y',
        style=>null,
        printer=>null);
       commit;

     fnd_set.PROGRAM_PARAMETER(
                PROGRAM=>'BIS_RSG_PREP',
                PROGRAM_APPLICATION=>'BIS',
                REQUEST_SET=>upper(p_set_name),
                SET_APPLICATION=>p_set_app,
                STAGE=>'Stage_'||to_char(p_min_stage-50),
                PROGRAM_SEQUENCE=>10,
                PARAMETER=>'Request Set Code',
                DISPLAY=>'Y',
                MODIFY=> 'Y' ,
                SHARED_PARAMETER=>null ,
                DEFAULT_TYPE=>'Constant',
                DEFAULT_VALUE=>upper(p_set_name)
             );

end if;

if p_max_stage >0 then
---Add MV dummy refresh program at the end of the request set
     fnd_set.add_stage
         (name=>g_stage_prompt||' '||to_char(p_max_stage+50),
          request_set=>upper(p_set_name),
          set_application=>p_set_app,
          short_name=>'Stage_'||to_char(p_max_stage+50),
          description=>null,
          display_sequence=>p_max_stage+50,
          function_short_name=>'FNDRSSTE',
          function_application=>'FND',
          critical=>'N',
          incompatibilities_allowed=>'N',
          start_stage=>'N',
          language_code=>'US');

         commit;
         -------dbms_output.put_Line('added stage: '||'Stage_'||to_char(p_max_stage+50));

     fnd_set.add_program
        (program =>'BIS_RSG_FINAL' ,
  	    program_application=>'BIS',
  	    request_set=>upper(p_set_name) ,
   	    set_application=>p_set_app ,
        stage=>'Stage_'||to_char(p_max_stage+50),
        program_sequence=>10,
        critical=>'Y'       ,
        number_of_copies =>0,
        save_output =>'Y',
        style=>null,
        printer=>null);

     fnd_set.PROGRAM_PARAMETER(
                PROGRAM=>'BIS_RSG_FINAL',
                PROGRAM_APPLICATION=>'BIS',
                REQUEST_SET=>upper(p_set_name),
                SET_APPLICATION=>p_set_app,
                STAGE=>'Stage_'||to_char(p_max_stage+50),
                PROGRAM_SEQUENCE=>10,
                PARAMETER=>'Request Set Code',
                DISPLAY=>'Y',
                MODIFY=> 'Y' ,
                SHARED_PARAMETER=>null ,
                DEFAULT_TYPE=>'Constant',
                DEFAULT_VALUE=>upper(p_set_name)
             );
   commit;
              -------dbms_output.put_Line('added program BIS_MV_DUMMY_REFRESH');
   -- Add the last stage as the RSG Reporting program Enh#3473874 aguwalan
   -- Enh#4418520-aguwalan
   add_link_history_stage(p_set_name, p_set_app, p_max_stage+100, p_rsg_history_flag);
   commit;
end if;

end add_first_last_stages;

function is_req_alive(p_req_id	   IN NUMBER)
  return boolean IS
    l_req_id         number;
    l_call_Status    boolean;
    l_phase          varchar2(200);
    l_status          varchar2(200);
    l_req_phase          varchar2(200);
    l_dev_status          varchar2(200);
    l_message          varchar2(200);

  begin
    --  := FND_GLOBAL.conc_request_id
    l_req_id := p_req_id;
    -- make it runnable under sql-plus, as the current req-id will be
    -- set to -1.
    if l_req_id = -1 THEN
      BIS_COLLECTION_UTILITIES.debug(' Req#' || l_req_id || ', can not moniter the status!' );
      return TRUE;
    end if;

    l_call_status := FND_CONCURRENT.get_request_status(l_req_id , null, null,
 			    l_phase, l_status, l_req_phase, l_dev_status, l_message);
    if (NOT l_call_status ) then
      RAISE_APPLICATION_ERROR (-20000,'Error happened in request: ' || l_req_id);
    end if;

    if (l_req_phase is null ) THEN
       BIS_COLLECTION_UTILITIES.debug(' Req#' || l_req_id || ' not exists' );
       return FALSE;
    elsif (l_req_phase='COMPLETE' ) THEN
       BIS_COLLECTION_UTILITIES.debug(' Req#' || l_req_id || ' is completed!' );
       IF (l_status = 'Error' OR l_dev_status = 'ERROR') THEN
         RAISE_APPLICATION_ERROR (-20000,'Error happened in request: ' || l_req_id);
       ELSIF (l_status = 'Terminated' OR l_dev_status = 'TERMINATED') THEN
         l_call_status := fnd_concurrent.set_completion_status('TERMINATED' ,NULL);
         RAISE_APPLICATION_ERROR (-20000,'request: ' || l_req_id || ' was terminated!');
       ELSIF (l_status = 'Warning' OR l_dev_status = 'WARNING') THEN
         l_call_status := fnd_concurrent.set_completion_status('WARNING' ,NULL);
         return FALSE;
       ELSE
         return FALSE;
       END IF;
    else
       BIS_COLLECTION_UTILITIES.debug(' Req#' || l_req_id || ' is running!' );
       return TRUE;
    end if;
end;

FUNCTION isSubmitAlert(pReqCode VARCHAR2) RETURN BOOLEAN
IS
  CURSOR C_ALERT_FLAG ( pReqCode bis_request_set_options.OPTION_NAME%type )
    IS
      select NVL(OPTION_VALUE, 'N')
      from bis_request_set_options
      where request_set_name = pReqCode
      and OPTION_NAME = 'ALERT_FLAG';
  l_flag  VARCHAR2(10) := NULL;
BEGIN

    OPEN C_ALERT_FLAG(pReqCode);
    fetch C_ALERT_FLAG into l_flag;
    CLOSE C_ALERT_FLAG;
    IF( NVL(l_flag, 'N') = 'Y' ) THEN
      BIS_COLLECTION_UTILITIES.put_line( pReqCode || ' is flagged to submit alert!');
      RETURN TRUE;
    ELSE
      BIS_COLLECTION_UTILITIES.put_line( pReqCode || ' is not flagged to submit alert!');
      RETURN FALSE;
    END IF;
END;

/**
procedure waitForCQComplete(
    p_cp_Short_name	   IN VARCHAR,
    p_request_id       IN NUMBER
) is
   l_message VARCHAR2(500) := NULL;
   l_status INTEGER;
   l_alertname VARCHAR2(30) := NULL;
begin
   l_alertname := SUBSTR(p_request_id || p_cp_Short_name, 1, 30);
   dbms_alert.register(l_alertname);
   LOOP
     --dbms_alert.waitone(l_alertname,l_message,l_status, 60*5);
      dbms_alert.waitone(l_alertname,l_message,l_status, 60*1);
     EXIT WHEN NOT ( l_status = 1  and is_req_alive(FND_GLOBAL.conc_request_id) and is_req_alive(p_request_id) );
   END LOOP;
   dbms_alert.remove(l_alertname);
end;
**/

procedure waitForRequest(
  p_request_id       IN NUMBER
)
 is
begin
   commit;
   LOOP
     dbms_lock.sleep(10);
     BIS_COLLECTION_UTILITIES.put_line('inside the loop of waitforrequest');
     BIS_COLLECTION_UTILITIES.put_line('FND_GLOBAL.conc_request_id '||FND_GLOBAL.conc_request_id);
     BIS_COLLECTION_UTILITIES.put_line('p_request_id'||p_request_id);
     EXIT WHEN NOT ( is_req_alive(FND_GLOBAL.conc_request_id) and is_req_alive(p_request_id) );
    --EXIT WHEN NOT ( is_req_alive(p_request_id) );
   END LOOP;

end;

---added for bug 4532066
---this procedure will print out the request sets which
---contain unimplemented dashboards/reports
---and set the Preparation program to warning status
---the user should re-generate these request sets
procedure check_unimpl_objects_is_sets(p_request_set_code in varchar2) is

cursor c_unimpl_obj_in_set is
select distinct a.object_type, bis_impl_dev_pkg.get_user_object_name(a.object_type,a.object_name) user_object_name
from bis_request_set_objects a,
     bis_obj_properties b
where a.request_set_name=p_request_set_code
and a.set_app_id=191
and a.object_type=b.object_type
and a.object_name=b.object_name
and b.implementation_flag='N';

l_obj_rec c_unimpl_obj_in_set%rowtype;


cursor c_set_with_unimpl_obj is
 select distinct c.user_request_set_name from
 bis_request_set_objects a,
 bis_obj_properties b,
 fnd_request_sets_vl c
 where a.object_name=b.object_name
 and a.object_type=b.object_type
 and b.implementation_flag='N'
 and a.request_set_name=c.request_set_name
 and a.set_app_id=c.application_id;

l_counter number;
l_set_rec  c_set_with_unimpl_obj%rowtype;
l_program_status     boolean  :=true;

begin
  l_counter:=0;
  BIS_COLLECTION_UTILITIES.put_line('The following dashboards/reports in this request set are not implemented.');
  BIS_COLLECTION_UTILITIES.put_line('Data can not be loaded properly for unimplemented dashboards/reports.');
  BIS_COLLECTION_UTILITIES.put_line('Please go to RSG UI to remove them by updating this request set.');
  BIS_COLLECTION_UTILITIES.put_line('-----------Start of the dashboards/reports list------');
  for   l_obj_rec  in c_unimpl_obj_in_set loop
      l_counter:=l_counter+1;
      BIS_COLLECTION_UTILITIES.put_line(l_obj_rec.object_type||' '||l_obj_rec.user_object_name);
  end loop;
  BIS_COLLECTION_UTILITIES.put_line('-----------End of the dashboards/reoprts list------');

  if l_counter>0 then
      BIS_COLLECTION_UTILITIES.put_line('For your information only. Following is a list of request sets that contain unimplemented dashboards/reports. ');
      BIS_COLLECTION_UTILITIES.put_line('-----------Start of the request set list------');
      for l_set_rec in c_set_with_unimpl_obj loop
        BIS_COLLECTION_UTILITIES.put_line(l_set_rec.user_request_set_name);
      end loop;
      BIS_COLLECTION_UTILITIES.put_line('-----------End of the request set list------');
      l_program_status := fnd_concurrent.set_completion_status('WARNING' ,NULL);
  end if;
end;


procedure preparation_conc(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR,
    p_request_set_code	   IN VARCHAR
) is
   l_request_id      INTEGER;
   l_phase VARCHAR2(500) := NULL;
   --l_status VARCHAR2(500) := NULL;
   l_status INTEGER;
   l_devphase VARCHAR2(500) := NULL;
   l_devstatus VARCHAR2(500) := NULL;
   l_message VARCHAR2(500) := NULL;
   l_result BOOLEAN;
   l_stmt            varchar2(20000);
   l_cursor_id       integer;
   l_rows            integer:=0;
   l_program_status     boolean  :=true;

cursor refresh_mode is
select option_value
from bis_request_set_options
where request_set_name=p_request_set_code
and  SET_APP_ID=191
and option_name='REFRESH_MODE';

cursor force_full_refresh is
select option_value
from bis_request_set_options
where request_set_name=p_request_set_code
and set_app_id=191
and option_name='FORCE_FULL';

l_refresh_mode varchar2(30);
l_force_full_refresh varchar2(30);

cursor get_req_set_details(p_req_id number) is
select
req.argument1,
req.argument2
from
fnd_concurrent_requests req
where
req.request_id = p_req_id ;

CURSOR mv_log_truncate_running IS
SELECT req.request_id REQUEST, req.phase_code Phase, requested_start_date s_date
FROM fnd_concurrent_programs prog, fnd_concurrent_requests req
WHERE prog.CONCURRENT_PROGRAM_NAME = 'BIS_BIA_TRUNCATE_EMPTY_MV_LOGS'
AND req.concurrent_program_id = prog.concurrent_program_id
AND req.program_application_id = prog.application_id
AND req.phase_code = 'R';

l_req_set_appl_id	number;
l_req_set_id		number;

begin
   BIS_COLLECTION_UTILITIES.put_line('Checking if Empty MV Log Truncation is running ...');
   FOR mv_log_truncate_running_rec IN mv_log_truncate_running LOOP
    EXIT WHEN mv_log_truncate_running%NOTFOUND;
    BIS_COLLECTION_UTILITIES.put_line(' - Req. Id:'||mv_log_truncate_running_rec.REQUEST||' Phase:'|| mv_log_truncate_running_rec.Phase || ' Started:' ||mv_log_truncate_running_rec.s_Date);
    RAISE_APPLICATION_ERROR (-20000,'Empty MV Log Truncation Program Running');
    RETURN;
   END LOOP;
   IF (Not BIS_COLLECTION_UTILITIES.setup('preparation_conc')) THEN
      RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || sqlerrm);
      return;
   END IF;
   fnd_profile.put ('CONC_SINGLE_THREAD','N');

  -- Enh#4418520-aguwalan
  IF(is_history_collect_on(p_request_set_code, 191)) THEN
     --Add entry of this request set in table BIS_RS_RUN_HISTORY Enh#3473874 aguwalan
     open get_req_set_details(FND_GLOBAL.CONC_PRIORITY_REQUEST);
     fetch get_req_set_details into l_req_set_appl_id, l_req_set_id;
     close get_req_set_details;

     BEGIN
     BIS_COLL_RS_HISTORY.update_terminated_rs;

     BIS_COLL_RS_HISTORY.add_rsg_rs_run_record(p_request_set_id	   =>l_req_set_id,
                                             p_request_set_appl_id  => l_req_set_appl_id,
                                             p_request_name	   => p_request_set_code,
                                             p_root_req_id	   =>FND_GLOBAL.CONC_PRIORITY_REQUEST);
     EXCEPTION WHEN OTHERS THEN
       BIS_COLLECTION_UTILITIES.put_line('Exception while adding record for RS Run in BIS_RS_RUN_HISTORY_TABLE or updating terminated request set. ignorable exception ' ||  sqlerrm);
       errbuf := sqlerrm;
       retcode := sqlcode;
       l_program_status := fnd_concurrent.set_completion_status('WARNING' ,NULL);
     END;
  ELSE
    BIS_COLLECTION_UTILITIES.put_line('------------------------------------------------------------------');
    BIS_COLLECTION_UTILITIES.put_line('Request Set History Collection Option is off for this Request Set.');
    BIS_COLLECTION_UTILITIES.put_line('No History Collection will happen for this request set.');
    BIS_COLLECTION_UTILITIES.put_line('------------------------------------------------------------------');
  END IF;

  BEGIN
     BIS_COLLECTION_UTILITIES.put_line('********************************************************');
     BIS_COLLECTION_UTILITIES.put_line('kicking off RSG seed data validation program');
      l_request_id := FND_REQUEST.SUBMIT_REQUEST (
                      APPLICATION=> 'BIS',
                      PROGRAM=>'BIS_BIA_RSG_VALIDATION',
                      DESCRIPTION=>NULL,
                      START_TIME=>NULL ,
                      SUB_REQUEST=>FALSE,
                      ARGUMENT1=>p_request_set_code,
                      ARGUMENT2=>'BIS');

     BIS_COLLECTION_UTILITIES.put_line('request id for RSG seed data validation program: '||l_request_id);
     BIS_COLLECTION_UTILITIES.put_line('********************************************************');

     /**
      ------added for enhancement 3999465. But commented for 4422645
	  ------ THis call can be removed if in the future we have UI
	  ------for the user to set impl flag for reports
     BIS_COLLECTION_UTILITIES.put_line('Set implementation flag for reports directly included in this request set');
     BIS_IMPL_OPT_PKG.set_implflag_reports_in_set(p_request_set_code,l_req_set_appl_id);
     **/

     BIS_COLLECTION_UTILITIES.put_line('Invoking ' || 'BIS_IMPL_OPT_PKG.setImplementationOptions');
     l_stmt := 'BEGIN BIS_IMPL_OPT_PKG.setImplementationOptions(:errbuf, :retcode); END;';
     l_cursor_id:=DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.parse(l_cursor_id,l_stmt,DBMS_SQL.V7);
     DBMS_SQL.bind_variable(l_cursor_id,'errbuf',errbuf, 32767);
     DBMS_SQL.bind_variable(l_cursor_id,'retcode',retcode, 200);
     l_rows:=DBMS_SQL.execute(l_cursor_id);
     DBMS_SQL.close_cursor(l_cursor_id);

     BIS_COLLECTION_UTILITIES.put_line('Done ' || 'BIS_IMPL_OPT_PKG.setImplementationOptions');
     BIS_COLLECTION_UTILITIES.put_line('********************************************************');

      ---Added for bug 4532066
      check_unimpl_objects_is_sets(p_request_set_code);


     if is_mvlog_mgt_enabled='Y' then
         open refresh_mode;
         fetch refresh_mode into l_refresh_mode;
         if  refresh_mode%notfound then
             l_refresh_mode:='INCR';
         end if;
         close refresh_mode;
         open force_full_refresh ;
         fetch force_full_refresh into l_force_full_refresh;
         if force_full_refresh%notfound then
            l_force_full_refresh:='N';
          end if;
          close  force_full_refresh ;

        if l_refresh_mode='INIT' and l_force_full_refresh='Y' then
           l_request_id := FND_REQUEST.SUBMIT_REQUEST (
                      APPLICATION=> 'BIS',
                      PROGRAM=>'BIS_BIA_RSG_MLOG_CAD',
                      DESCRIPTION=>NULL,
                      START_TIME=>NULL ,
                      SUB_REQUEST=>FALSE,
                      ARGUMENT1=>p_request_set_code);
          BIS_COLLECTION_UTILITIES.put_line('Submitted request for MV log management program' || l_request_id);
          waitForRequest(l_request_id);
        end if;
    end if;

   EXCEPTION WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in preparation program, ' ||  sqlerrm);
     errbuf := sqlerrm;
     retcode := sqlcode;
     l_program_status := fnd_concurrent.set_completion_status('WARNING' ,NULL);
   END;

end preparation_conc;

procedure finalization_conc(
    errbuf  			   OUT NOCOPY VARCHAR2,
    retcode		           OUT NOCOPY VARCHAR,
    p_request_set_code	   IN VARCHAR
)is
  l_request_id      INTEGER;
  l_root_request_id  INTEGER;

  l_stmt            varchar2(20000);
  l_cursor_id       integer;
  l_rows            integer:=0;
  l_program_status     boolean  :=true;
  l_program_message  varchar2(200);
begin
   IF (Not BIS_COLLECTION_UTILITIES.setup('finalization_conc')) THEN
      RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || sqlerrm);
      return;
   END IF;

   l_root_request_id := FND_GLOBAL.CONC_PRIORITY_REQUEST;
   BIS_COLLECTION_UTILITIES.put_line('FND_GLOBAL.CONC_PRIORITY_REQUEST: ' || l_root_request_id);
   fnd_profile.put ('CONC_SINGLE_THREAD','N');

  l_request_id := FND_REQUEST.SUBMIT_REQUEST (
                      'BIS',
                      'BIS_MV_DUMMY_REFRESH',
                      NULL,
                      NULL,
                      FALSE);
   BIS_COLLECTION_UTILITIES.put_line('Submitted request for BIS_MV_DUMMY_REFRESH ' || l_request_id);

 --changed for enh 3473874
   BIS_COLLECTION_UTILITIES.put_line('Wait for MV consider refresh program to complete ');
   waitForRequest(l_request_id);

    ---Add the following API call for refreshing data for custom KPIs
    bsc_loader_wrapper(p_request_set_code);


   ---launch update last refresh date program at last so that
   ---it can update last refresh time for custom KPI objects
   l_request_id := FND_REQUEST.SUBMIT_REQUEST (
                      'BIS',
                      'BIS_LAST_REFRESH_DATE_CONC',
                      NULL,
                      NULL,
                      FALSE,
                      l_root_request_id);
   BIS_COLLECTION_UTILITIES.put_line('Submitted request for BIS_LAST_REFRESH_DATE_CONC ' || l_request_id);
   waitForRequest(l_request_id);

   EXCEPTION WHEN OTHERS THEN
     BIS_COLLECTION_UTILITIES.put_line('Exception happens in finalization program, ' ||  sqlerrm);
     errbuf := sqlerrm;
     retcode := sqlcode;

end finalization_conc;



---we use dynamic sql and query BSC table at runtime
----but this would introduce runtime dependency on BSC product
----An alternative would be using the naming convention of the kpi report
function get_indicator(p_object_name varchar2) return varchar2 is
l_kpi varchar2(30);
l_sql varchar2(2000);
l_table_owner varchar2(30);
begin
---- select rtrim(ltrim(ltrim(P_OBJECT_NAME,substr(P_OBJECT_NAME,0,instr(P_OBJECT_NAME,'[')-1)),'['),']') into l_kpi from dual;
--- select substr(ltrim(p_object_name,'BSC_S'),0,instr(ltrim(p_object_name,'BSC_S'),'_')-1) into l_kpi from dual;
----select substr(ltrim(p_object_name,'BSC_'),0,instr(ltrim(p_object_name,'BSC_'),'_')-1) into l_kpi from dual ;

---first check if the bsc table exists or not
l_table_owner:=get_object_owner(upper('bsc_kpi_analysis_measures_b'),'TABLE');
if l_table_owner='NOTFOUND' then
  return null;
end if;

l_sql:='select distinct to_char(b.indicator) indicator_id from '||
       '      bis_indicators a, '||
       '      bsc_kpi_analysis_measures_b b '||
       '      where a.dataset_id=b.dataset_id '||
       '       and a.function_name=:1';
 execute immediate l_sql into l_kpi using p_object_name;

 return l_kpi;
exception
   when no_data_found then
    return null;
   when others then
    raise;
end;

----This function checks if the new loader program for indicators exists
function loader_exist return varchar2 is
 l_exist_flag varchar2(1);
begin
  l_exist_flag:='N';
  select 'Y'
  into l_exist_flag
  from fnd_concurrent_programs
  where concurrent_program_name='BSC_LOAD_INDICATORS_DATA'
  and application_id=271;
  return l_exist_flag;
exception
  when no_data_found then
    l_exist_flag:='N';
    return l_exist_flag;
  when others then
    raise;
end;

----this function returns the loading mode of the request set
function loading_mode(p_request_set_name in varchar2) return varchar2 is
l_loading_mode varchar2(30);
begin
 l_loading_mode:=null;
 select distinct option_value into l_loading_mode
 from bis_request_set_options
 where request_set_name=p_request_set_name
 and option_name='REFRESH_MODE';
 return l_loading_mode;
exception
  when no_data_found then
    l_loading_mode:='INCR' ;
    return l_loading_mode;
   when others then
     raise;
end;


function force_full_refresh(p_request_set_name in varchar2) return varchar2 is
l_force_full_refresh varchar2(30);
begin
 l_force_full_refresh:=null;
 select distinct option_value into l_force_full_refresh
 from bis_request_set_options
 where request_set_name=p_request_set_name
 and option_name='FORCE_FULL';
 return l_force_full_refresh;
exception
  when no_data_found then
    l_force_full_refresh:='N' ;
    return l_force_full_refresh;
   when others then
     raise;
end;

function kpi_in_list(p_kpi_list in varchar2, p_kpi in varchar2) return varchar2 is
begin
  if p_kpi_list is null then
    return 'N';
  else
    if instr(p_kpi_list,','||p_kpi||',')=0
        and instr(p_kpi_list,p_kpi||',')=0
        and instr(p_kpi_list,','||p_kpi)=0 then
      return 'N';
    else
      return 'Y';
    end if;
  end if;
end;


procedure bsc_loader_wrapper(
    p_request_set_code	   IN VARCHAR
)is

cursor c_page_objects is
select distinct a.object_name,a.object_type
from
bis_request_set_objects a,
fnd_request_sets b
where a.request_set_name=b.request_set_name
and a.set_app_id=b.application_id
and b.request_set_name=p_request_set_code
and b.application_id=191;

l_page_object_rec c_page_objects%rowtype;

cursor c_custom_kpi_in_page(p_object_name varchar2,p_object_type varchar2)
is
select distinct get_indicator(obj_name) kpi
from
( select distinct
   obj.depend_OBJECT_NAME obj_name,
   obj.depend_object_type obj_type,
   obj.depend_object_owner obj_owner
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
     where enabled_flag='Y' ) obj
  start with obj.object_type =p_object_type
  and obj.object_name = p_object_name
  connect by prior obj.DEPEND_OBJECT_NAME=obj.object_name
  and prior depend_object_type=object_type
  ) depend_objects
  where obj_type ='REPORT'
  and obj_owner=get_bsc_schema_name
  and obj_name like 'BSC%';

l_custom_kpi_rec c_custom_kpi_in_page%rowtype;
l_kpi_list	varchar2(2000);
l_kpi_name_list varchar2(2000);

l_request_id number;

 l_result BOOLEAN;
 l_phase VARCHAR2(500) := NULL;
 l_status VARCHAR2(500) := NULL;
 l_devphase VARCHAR2(500) := NULL;
 l_devstatus VARCHAR2(500) := NULL;
 l_message VARCHAR2(500) := NULL;

 l_hist_coll_on  BOOLEAN;
begin
  -- Enh#4418520-aguwalan
  l_hist_coll_on := is_history_collect_on(p_request_set_code, 191);

  l_kpi_list:=null;
  l_kpi_name_list :=null;
  BIS_COLLECTION_UTILITIES.put_line('***********************************');
  For l_page_object_rec in c_page_objects loop
    for l_custom_kpi_rec in c_custom_kpi_in_page(l_page_object_rec.object_name,l_page_object_rec.object_type) loop
      if l_custom_kpi_rec.kpi is not null and kpi_in_list(l_kpi_list,l_custom_kpi_rec.kpi)='N' then
        l_kpi_list:=l_kpi_list||l_custom_kpi_rec.kpi||',';
	--l_kpi_name_list := l_kpi_name_list || l_custom_kpi_rec.kpi_name || ',';
      end if;
    end loop;
  end loop;
  if l_kpi_list is not null then
    l_kpi_list:=rtrim(l_kpi_list,',');
  end if;

 /* if l_kpi_name_list is not null then
    l_kpi_name_list:=rtrim(l_kpi_name_list,',');
  end if;*/

  BIS_COLLECTION_UTILITIES.put_line('l_kpi_list:'||l_kpi_list);
  BIS_COLLECTION_UTILITIES.put_line('loader_exist:'||loader_exist);

  -----turning off sequential execution before spawning sub-program
--  fnd_profile.put ('CONC_SINGLE_THREAD','N');

  if l_kpi_list is not null and loader_exist='Y' then
   if loading_mode(p_request_set_code)='INIT' and force_full_refresh(p_request_set_code)='Y' then
     BIS_COLLECTION_UTILITIES.put_line('Initial loading mode. calling loader program to delete data from indicators');

      l_request_id := FND_REQUEST.SUBMIT_REQUEST (
                      'BSC',
                      'BSC_DELETE_DATA_IND',
                      NULL,
                      NULL,
                      FALSE,
                      l_kpi_list,
                      'Y');---'Y' means keep input tables data

    BIS_COLLECTION_UTILITIES.put_line('Submitted request for BSC_DELETE_INDICATORS_DATA ' || l_request_id);
    waitForRequest(l_request_id);
    -- Enh#4418520-aguwalan
    IF (l_hist_coll_on) THEN
      BIS_COLL_RS_HISTORY.insert_program_object_data(x_request_id    => l_request_id,
                                                     x_stage_req_id  => null,
                                                     x_object_name   => l_kpi_list,
                                                     x_object_type   => 'BSC_CUSTOM_KPI',
                                                     x_refresh_type  =>  loading_mode(p_request_set_code),
                                                     x_set_request_id => FND_GLOBAL.CONC_PRIORITY_REQUEST);
    END IF;
   end if;
   BIS_COLLECTION_UTILITIES.put_line('Call loader program to load custom dimensions');
   l_request_id := FND_REQUEST.SUBMIT_REQUEST (
                      'BSC',
                      'BSC_REFRESH_DIM_IND',
                      NULL,
                      NULL,
                      FALSE,
                      l_kpi_list,
                      'N');
   BIS_COLLECTION_UTILITIES.put_line('Submitted request for BSC_LOAD_INDICATORS_DIMS ' || l_request_id);
   waitForRequest(l_request_id);
   -- Enh#4418520-aguwalan
   IF (l_hist_coll_on) THEN
     BIS_COLL_RS_HISTORY.insert_program_object_data( x_request_id   => l_request_id,
                                                     x_stage_req_id  => null,
                                                     x_object_name   => l_kpi_list,
                                                     x_object_type   => 'BSC_CUSTOM_KPI',
                                                     x_refresh_type  =>  loading_mode(p_request_set_code),
                                                     x_set_request_id => FND_GLOBAL.CONC_PRIORITY_REQUEST);
   END IF;
   BIS_COLLECTION_UTILITIES.put_line('Call loader program to load data for indicators');
   l_request_id := FND_REQUEST.SUBMIT_REQUEST (
                      'BSC',
                      'BSC_REFRESH_SUMMARY_IND',
                      NULL,
                      NULL,
                      FALSE,
                      l_kpi_list,
                      'N');

   BIS_COLLECTION_UTILITIES.put_line('Submitted request for BSC_LOAD_INDICATORS_DATA ' || l_request_id);
   waitForRequest(l_request_id);
   -- Enh#4418520-aguwalan
   IF (l_hist_coll_on) THEN
     BIS_COLL_RS_HISTORY.insert_program_object_data( x_request_id    => l_request_id,
                                                     x_stage_req_id  => null,
                                                     x_object_name   => l_kpi_list,
                                                     x_object_type   => 'BSC_CUSTOM_KPI',
                                                     x_refresh_type  =>  loading_mode(p_request_set_code),
                                                     x_set_request_id => FND_GLOBAL.CONC_PRIORITY_REQUEST);
   END IF;
  end if;
  BIS_COLLECTION_UTILITIES.put_line('********************************************');

 exception
 when others then
  raise;
end;

function form_function_exist(p_object_type in varchar2, p_object_name in varchar2) return varchar2 is
cursor c_report_function is
select 'Y'
from fnd_form_functions
where function_name=p_object_name
and type in ('WWW','JSP');

---add WEBPORTLETX for bug 4067976
cursor c_portlet_function is
select 'Y'
from fnd_form_functions
where function_name=p_object_name
and type in ('WEBPORTLET','WEBPORTLETX');

cursor c_page_function is
select 'Y'
from  fnd_form_functions
where function_name= bis_impl_dev_pkg.get_function_by_page(p_object_name)
and upper(web_html_call) like '%BIS_COMPONENT_PAGE'||'&'||'AKREGIONAPPLICATIONID=191%';
l_dummy varchar2(1);
begin
 l_dummy:='N';
 if p_object_type='REPORT' then
   open c_report_function;
   fetch c_report_function into l_dummy;
   if c_report_function%notfound then
      l_dummy:='N';
   end if;
 end if;

 if p_object_type='PORTLET' then
   open  c_portlet_function;
   fetch c_portlet_function into l_dummy;
   if c_portlet_function%notfound then
      l_dummy:='N';
   end if;
 end if;

  if p_object_type='PAGE' then
   open  c_page_function;
   fetch c_page_function into l_dummy;
   if c_page_function%notfound then
      l_dummy:='N';
   end if;
 end if;
    return l_dummy;
 exception
   when others then
    raise;
end;

----this program will print out the invalid RSG seed data
procedure seed_data_validation(
        errbuf  		OUT NOCOPY VARCHAR2,
        retcode		        OUT NOCOPY VARCHAR,
     p_request_set_code		IN VARCHAR2,
     p_set_app			IN varchar2
) is

cursor c_pages is
select distinct a.object_name,a.object_type
from
bis_request_set_objects a,
fnd_request_sets b,
fnd_application c
where a.request_set_name=b.request_set_name
and a.set_app_id=b.application_id
and b.request_set_name=upper(p_request_set_code)
and b.application_id=c.application_id
and c.application_short_name=p_set_app;

l_page_rec c_pages%rowtype;


cursor c_objects_per_page(p_object_name varchar2,p_object_type varchar2) is
select depend_objects.obj_type object_type,depend_objects.obj_name object_name,depend_objects.obj_owner object_owner
from
( select distinct
   obj.depend_OBJECT_NAME obj_name,
   obj.depend_object_type obj_type,
   obj.depend_object_owner obj_owner
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
     where enabled_flag='Y' ) obj
  start with obj.object_type =p_object_type
  and obj.object_name = p_object_name
  connect by prior obj.DEPEND_OBJECT_NAME=obj.object_name
  and prior depend_object_type=object_type
  ) depend_objects;

l_obj_rec c_objects_per_page%rowtype;
l_obj_phy_owner varchar2(30);
l_sql_stmt varchar2(2000);
l_function_exist varchar2(1);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_invalid_obj_type varchar2(30);
l_invalid_obj_owner varchar2(50);
l_invalid_obj_name  bis_obj_properties.object_name%type;
l_report_title varchar2(500);
l_report_comment varchar2(2000);
l_report_end varchar2(500);
l_obj_type_prompt varchar2(100);
l_obj_owner_prompt varchar2(100);
l_obj_name_prompt varchar2(100);


 l_program_status     boolean  :=true;

begin

  IF (Not BIS_COLLECTION_UTILITIES.setup('seed_data_validation')) THEN
      RAISE_APPLICATION_ERROR (-20000,'Error in SETUP: ' || sqlerrm);
      return;
  END IF;

 -----write invalid objects into global temp table
 for l_page_rec in c_pages loop
    for l_obj_rec in c_objects_per_page(l_page_rec.object_name,l_page_rec.object_type) loop
      if l_obj_rec.object_type in ('TABLE','MV','VIEW') then
        l_obj_phy_owner:=get_object_owner(l_obj_rec.object_name,l_obj_rec.object_type);
        if l_obj_phy_owner='NOTFOUND' then
            l_sql_stmt := 'insert into BIS_BIA_RSG_SEED_VALIDATION(object_type,object_name,object_owner)
                           values (:1,:2,:3)';
            EXECUTE IMMEDIATE l_sql_stmt USING l_obj_rec.object_type,l_obj_rec.object_name,l_obj_rec.object_owner ;
            commit;
        end if;---end if DB object not found
      end if;----end if DB objects
      if l_obj_rec.object_type in ('REPORT','PORTLET','PAGE') then
        l_function_exist:=form_function_exist(l_obj_rec.object_type,l_obj_rec.object_name);
        if     l_function_exist='N' then
          l_sql_stmt := 'insert into BIS_BIA_RSG_SEED_VALIDATION(object_type,object_name,object_owner)
                           values (:1,:2,:3)';
          EXECUTE IMMEDIATE l_sql_stmt USING l_obj_rec.object_type,l_obj_rec.object_name,l_obj_rec.object_owner ;
          commit;
        end if;---end if form function not exist
      end if;----end if form function objects
    end loop; ---end loop of objects
 end loop;---end loop of pages


----print out invalid objects from the global temp table

l_report_title:=fnd_message.get_string('BIS','BIS_BIA_RSG_VALIDATION_TITLE');
l_report_comment:=fnd_message.get_string('BIS','BIS_BIA_RSG_VALIDATION_COMMENT');
l_report_end:=fnd_message.get_string('BIS','BIS_BIA_RSG_VALIDATION_END');
l_obj_type_prompt:=fnd_message.get_string('BIS','BIS_BIA_RSG_VALIDATION_TYPE');
l_obj_owner_prompt:=fnd_message.get_string('BIS','BIS_BIA_RSG_VALIDATION_OWNER');
l_obj_name_prompt :=fnd_message.get_string('BIS','BIS_BIA_RSG_VALIDATION_NAME');


l_sql_stmt:='select distinct object_type,object_owner,object_name from BIS_BIA_RSG_SEED_VALIDATION
            order by object_type,object_owner,object_name';
 open cv for l_sql_stmt;

 BIS_COLLECTION_UTILITIES.put_line_out(l_report_comment);
 BIS_COLLECTION_UTILITIES.put_line_out('     ');
 BIS_COLLECTION_UTILITIES.put_line_out('     ');
 BIS_COLLECTION_UTILITIES.put_line_out(l_report_title);
 BIS_COLLECTION_UTILITIES.put_line_out(l_obj_type_prompt||'     '||l_obj_owner_prompt||'     '||l_obj_name_prompt);



 loop
    fetch cv into l_invalid_obj_type,l_invalid_obj_owner,l_invalid_obj_name;
    exit when cv%notfound;
    if l_invalid_obj_type='MV' then
       l_invalid_obj_type:=l_invalid_obj_type||'     ';
    end if;
    if l_invalid_obj_type='VIEW' then
       l_invalid_obj_type:=l_invalid_obj_type||'   ';
    end if;

    if l_invalid_obj_type='TABLE' then
       l_invalid_obj_type:=l_invalid_obj_type||'  ';
    end if;

     if l_invalid_obj_type='REPORT' then
       l_invalid_obj_type:=l_invalid_obj_type||' ';
    end if;

    if l_invalid_obj_type='PAGE' then
       l_invalid_obj_type:=l_invalid_obj_type||'   ';
    end if;



    BIS_COLLECTION_UTILITIES.put_line_out(l_invalid_obj_type||'         '||l_invalid_obj_owner||'              '||l_invalid_obj_name);
 end loop;
 close cv;
 BIS_COLLECTION_UTILITIES.put_line(l_report_end);

 exception
 when others then
    BIS_COLLECTION_UTILITIES.put_line('Exception happens in ' || 'bis_create_requestset.seed_data_validation, ' ||  sqlerrm);
    errbuf := sqlerrm;
    retcode := '2';
    l_program_status := fnd_concurrent.set_completion_status('WARNING' ,NULL);
end;

/*
 Enh#3473874
 This programs is called while creation of a request set.
 This will add one extra stage at the end of the request set and
 link history collection program to it.
 Then it links this stage to the stages in case of error.
*/

PROCEDURE add_link_history_stage(p_set_name in varchar2,p_set_app in varchar2,p_max_stage in number,
                                 p_rsg_history_flag in varchar2)
IS
report_stage_name varchar2(200);
cursor c_stages
is
select s.STAGE_NAME
from fnd_request_sets r ,fnd_request_set_stages s,
fnd_application app
where r.REQUEST_SET_ID= s.REQUEST_SET_ID
and r.application_id = s.set_Application_id
and r.REQUEST_SET_NAME = p_set_name
and r.application_id = app.application_id
and app.application_short_name=p_set_app;

c_stages_rec c_stages%rowtype;

l_root_request_id integer;

BEGIN
	---Add RSG History Report program at the end of the request set

  l_root_request_id := FND_GLOBAL.CONC_PRIORITY_REQUEST;
  if (p_rsg_history_flag = 'Y') then
    fnd_set.add_stage
         (name=>g_stage_prompt||' '||to_char(p_max_stage+50),
          request_set=>upper(p_set_name),
          set_application=>p_set_app,
          short_name=>'Stage_'||to_char(p_max_stage+50),
          description=>null,
          display_sequence=>p_max_stage+50,
          function_short_name=>'FNDRSSTE',
          function_application=>'FND',
          critical=>'N',
          incompatibilities_allowed=>'N',
          start_stage=>'N',
          language_code=>'US');

    fnd_set.add_program
		(program =>'BIS_BIA_RSG_HISTORY_PROG' ,
  		 program_application=>'BIS',
		 request_set=>upper(p_set_name) ,
		 set_application=>p_set_app ,
		stage=>'Stage_'||to_char(p_max_stage+50),
		program_sequence=>10,
		critical=>'Y',
		number_of_copies =>0,
		save_output =>'Y',
		style=>null,
		printer=>null);

    fnd_set.PROGRAM_PARAMETER(
                PROGRAM=>'BIS_BIA_RSG_HISTORY_PROG',
                PROGRAM_APPLICATION=>'BIS',
                REQUEST_SET=>upper(p_set_name),
                SET_APPLICATION=>p_set_app,
                STAGE=>'Stage_'||to_char(p_max_stage+50),
                PROGRAM_SEQUENCE=>10,
                PARAMETER=>'Root Request ID',
                DISPLAY=>'Y',
                MODIFY=> 'Y' ,
                SHARED_PARAMETER=>null ,
                DEFAULT_TYPE=>'Constant',
                DEFAULT_VALUE=>null
             );
    commit;
    report_stage_name := 'Stage_'||to_char(p_max_stage+50);

    --Now loop through all the stages and link this last stage  with all the stages in case of error
    for c_stages_rec in c_stages loop
	if (c_stages_rec.STAGE_NAME <> report_stage_name) then
		fnd_set.link_stages (request_set =>upper(p_set_name),
                       set_application =>'BIS',
                       from_stage =>c_stages_rec.STAGE_NAME,
                       to_stage=>report_stage_name,
                       success => 'N',
                       warning => 'N',
                       error => 'Y');
	end if;
    end loop;
    commit;
  end if;
  -- Bug#4881518 :: Adding a new stage and a new program to fix the issue with
  -- incorrect Request Set Status due to RSG History Collection program
  fnd_set.add_stage(name=>g_stage_prompt||' '||to_char(p_max_stage+150),
                      request_set=>upper(p_set_name),
                      set_application=>p_set_app,
                      short_name=>'Stage_'||to_char(p_max_stage+150),
                      description=>null,
                      display_sequence=>p_max_stage+150,
                      function_short_name=>'FNDRSSTE',
                      function_application=>'FND',
                      critical=>'N',
                      incompatibilities_allowed=>'N',
                      start_stage=>'N',
                      language_code=>'US');

  fnd_set.add_program(program =>'BIS_BIA_RS_STATUS_CHK' ,
                      program_application=>'BIS',
                      request_set=>upper(p_set_name) ,
                      set_application=>p_set_app ,
                      stage=>'Stage_'||to_char(p_max_stage+150),
                      program_sequence=>20,
                      critical=>'Y',
                      number_of_copies =>0,
                      save_output =>'Y',
                      style=>null,
                      printer=>null);
  commit;
  EXCEPTION WHEN OTHERS THEN
    BIS_COLLECTION_UTILITIES.put_line('Exception happens in add_link_history_stage ' ||  sqlerrm);
    raise;

END add_link_history_stage;

function get_bsc_schema_name return varchar is
cursor get_appl_short_name is
select application_short_name from fnd_application
where application_id =271;

begin
  for get_appl_rec in get_appl_short_name loop
	return get_appl_rec.application_short_name;
  end loop;

end;

/*
 * Added for Bug#4881518 :: API to check the status of all the requests inside the request set
 */
PROCEDURE set_rs_status(errbuf   OUT NOCOPY VARCHAR2,
                        retcode  OUT NOCOPY VARCHAR) IS

  l_root_request_id  NUMBER;

  CURSOR c_get_all_prog_status IS
    SELECT request_id, user_concurrent_program_name NAME, 'PROG' TYPE
    FROM BIS_RS_PROG_RUN_HISTORY bis, FND_CONCURRENT_PROGRAMS_VL fnd
    WHERE bis.set_request_id = l_root_request_id AND bis.status_code ='E'
      AND bis.prog_app_id = fnd.application_id AND bis.program_id = fnd.concurrent_program_id
    UNION
    SELECT request_id, user_stage_name NAME, 'STAGE' TYPE
    FROM BIS_RS_STAGE_RUN_HISTORY bis, FND_REQUEST_SET_STAGES_VL fnd
    WHERE set_request_id = l_root_request_id AND status_code ='E'
      AND bis.set_app_id = fnd.set_application_id AND bis.request_set_id = fnd.request_set_id
      AND bis.stage_id = fnd.request_set_stage_id ;

  l_request_id  VARCHAR2(100);
  l_name  VARCHAR2(240);
  l_type  VARCHAR2(10);
  l_program_status  BOOLEAN;
BEGIN
  l_root_request_id := FND_GLOBAL.CONC_PRIORITY_REQUEST;
  BIS_COLLECTION_UTILITIES.put_line('Checking the status of all the program of the Request Set :: RequestId#'||l_root_request_id);
  OPEN c_get_all_prog_status;
  FETCH c_get_all_prog_status INTO l_request_id, l_name, l_type;
  CLOSE c_get_all_prog_status;
  IF (l_type = 'PROG') THEN
    BIS_COLLECTION_UTILITIES.put_line('Program - '||l_name || ', Request Id # '||l_request_id ||' completed with status=Error');
    BIS_COLLECTION_UTILITIES.put_line('Hence setting status of the current program (BIS Request Set Status Check Program) to Error.');
    l_program_status := fnd_concurrent.set_completion_status('ERROR' ,NULL);
  ELSIF (l_type = 'STAGE') THEN
    BIS_COLLECTION_UTILITIES.put_line(l_name || ', Request Id # '||l_request_id ||' completed with status=Error');
    BIS_COLLECTION_UTILITIES.put_line('Hence setting status of the current program to Error.');
    l_program_status := fnd_concurrent.set_completion_status('ERROR' ,NULL);
  ELSE
    BIS_COLLECTION_UTILITIES.put_line('All the programs in the request set completed Successfully.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
   BIS_COLLECTION_UTILITIES.put_line('Exception in set_rs_status' ||  sqlerrm);
   l_program_status := fnd_concurrent.set_completion_status('ERROR' ,NULL);
   BIS_COLLECTION_UTILITIES.put_line('BIS Request Set Status Check Program completed with internal exception,');
   BIS_COLLECTION_UTILITIES.put_line('due to this the correct status of the programs in the request set can not be found.');
   BIS_COLLECTION_UTILITIES.put_line('Note that the status of Request set can be Normal or Warning even though one of the');
   BIS_COLLECTION_UTILITIES.put_line('program might have completed with error.');
END;

/*
 * API to return the value of the request set option='HISTORY_COLLECT' :: Enh#4418520-aguwalan
 */
FUNCTION is_history_collect_on(p_request_set_name IN VARCHAR2, p_request_app_id IN NUMBER) RETURN BOOLEAN
IS
  CURSOR c_history_coll_option(rs_name VARCHAR2, rs_app_id NUMBER)
    IS
      select NVL(OPTION_VALUE, 'Y')
      from bis_request_set_options
      where request_set_name = rs_name
      and set_app_id = rs_app_id
      and OPTION_NAME = 'HISTORY_COLLECT';
  l_flag  VARCHAR2(10);
BEGIN
  l_flag := NULL;
  OPEN c_history_coll_option(p_request_set_name, p_request_app_id);
  FETCH c_history_coll_option into l_flag;
  CLOSE c_history_coll_option;
  IF( NVL(l_flag, 'Y') = 'Y' ) THEN
    RETURN true;
  ELSE
    RETURN false;
  END IF;
END;

/*
 * Overloading is_history_collect_on API to take the root_Request_id and return the request set
 * option='HISTORY_COLLECT' :: Enh#4418520-aguwalan
 */
FUNCTION is_history_collect_on(p_root_request_id IN NUMBER) RETURN BOOLEAN
IS
  CURSOR c_request_set_details IS
    SELECT rs.request_set_name
    FROM fnd_concurrent_requests cr, fnd_request_sets rs
    WHERE cr.request_id = p_root_request_id
    AND rs.application_id = cr.argument1
    AND rs.request_set_id = cr.argument2;
  l_request_set_name  VARCHAR2(1000);
BEGIN
  OPEN c_request_set_details;
  FETCH c_request_set_details into l_request_set_name;
  CLOSE c_request_set_details;
  IF(l_request_set_name is not null) THEN
    RETURN is_history_collect_on(l_request_set_name,191);
  ELSE
    RETURN true;
  END IF;
END;

END BIS_CREATE_REQUESTSET;

/
