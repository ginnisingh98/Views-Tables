--------------------------------------------------------
--  DDL for Package Body CS_SR_LOG_DATA_TEMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_LOG_DATA_TEMP_PVT" AS
/* $Header: csvlogb.pls 115.6 2002/11/30 11:50:51 pkesani noship $ */

  procedure delete_log(  p_session_id  number
                       , p_incident_id number)
  is

    PRAGMA AUTONOMOUS_TRANSACTION;

  begin
    delete from cs_sr_log_data_temp
    where session_id  = p_session_id
    and   incident_id = p_incident_id;

    commit;
    exception
       when NO_DATA_FOUND then
          null;

  end delete_log;

  procedure insert_log(  p_session_id  number
                       , p_incident_id number
                       , p_log_text    varchar2)
  is

    PRAGMA AUTONOMOUS_TRANSACTION;

  begin

    insert into cs_sr_log_data_temp
                              ( session_id,
                                incident_id,
                                log_text,
                                display_seq)
                     VALUES   ( p_session_id,
                                p_incident_id,
                                p_log_text,
				cs_sr_log_data_temp_pvt.display_seq);
    commit;

  end insert_log;

  procedure get_log_report(p_incident_id in number,
                           x_session_id  out NOCOPY number) is
     i_return number := 0 ;
     l_session_id number := 0;
  begin

     select userenv('SESSIONID') into l_session_id from dual;

     cs_sr_log_data_temp_pvt.get_log_details(p_incident_id);

     i_return := cs_sr_log_data_temp_pvt.sort_log_data(1, cs_sr_log_data_temp_pvt.i_total_records);

     cs_sr_log_data_temp_pvt.insert_log_data(l_session_id, p_incident_id );

     x_session_id := l_session_id;

  exception
    when OTHERS then
       null;

  end get_log_report;

  procedure get_log_details(p_incident_id in number) is

     cursor log_cursor is
        select 'AUDIT' source_type,
        audi.incident_id,
        AUDI.incident_audit_id,
        FU.USER_NAME last_updated_by,
        AUDI.last_update_date last_update_date,
        to_char(AUDI.old_incident_severity_id) severity_old,
        to_char(AUDI.incident_severity_id) severity_new,
        AUDI.CHANGE_INCIDENT_SEVERITY_FLAG incident_severity_flag,
        to_char(AUDI.old_incident_type_id) type_old,
        to_char(AUDI.incident_type_id) type_new,
        AUDI.CHANGE_INCIDENT_TYPE_FLAG incident_type_flag,
        to_char(AUDI.old_incident_status_id) status_old,
        to_char(AUDI.incident_status_id) status_new,
        AUDI.CHANGE_INCIDENT_STATUS_FLAG incident_status_flag,
        to_char(AUDI.old_incident_urgency_id) urgency_old,
        to_char(AUDI.incident_urgency_id) urgency_new,
        AUDI.CHANGE_INCIDENT_URGENCY_FLAG incident_urgency_flag,
        to_char(AUDI.old_incident_owner_id) owner_old,
        to_char(AUDI.incident_owner_id) owner_new,
        AUDI.CHANGE_INCIDENT_OWNER_FLAG incident_owner_flag,
        to_char(AUDI.old_expected_resolution_date) date_old,
        to_char(AUDI.expected_resolution_date) date_new,
        AUDI.CHANGE_RESOLUTION_FLAG resolution_date_flag,
        severity1.name old_severity_name ,
        severity2.name new_severity_name ,
        type1.name old_type_name ,
        type2.name new_type_name ,
        status1.name old_status_name ,
        status2.name new_status_name ,
        urgency1.name old_urgency_name ,
        urgency2.name new_urgency_name ,
        decode(audi.old_resource_type,'RS_EMPLOYEE',ext1.source_last_name||' '||ext1.source_first_name,'RS_TEAM',team1.team_name,'RS_GROUP',grp1.group_name) old_owner,
        decode(audi.resource_type,'RS_EMPLOYEE',ext2.source_last_name||' '||ext2.source_first_name,'RS_TEAM',team2.team_name,'RS_GROUP',grp2.group_name) new_owner,
        obj1.name old_resource_type ,
        obj2.name resource_type ,
        audi.change_resource_type_flag
        from fnd_user FU,
         cs_incidents_AUDIT_vl AUDI ,
         cs_incident_severities_tl severity1 ,
         cs_incident_severities_tl severity2 ,
         cs_incident_types_tl type1 ,
         cs_incident_types_tl type2 ,
         cs_incident_statuses_tl status1 ,
         cs_incident_statuses_tl status2 ,
         cs_incident_urgencies_tl urgency1 ,
         cs_incident_urgencies_tl urgency2 ,
         jtf_rs_resource_extns ext1,
         jtf_rs_teams_tl team1,
         jtf_rs_groups_tl grp1,
         jtf_rs_resource_extns ext2,
         jtf_rs_teams_tl team2,
         jtf_rs_groups_tl grp2,
         jtf_objects_tl obj1 ,
         jtf_objects_tl obj2
         where audi.incident_id = p_incident_id
         and FU.user_id = AUDI.last_updated_by
         and severity1.incident_severity_id(+) = audi.old_incident_severity_id
         and (severity1.language = userenv('LANG') or severity1.language is null)
         and severity2.incident_severity_id(+) = audi.incident_severity_id
         and (severity2.language = userenv('LANG') or severity2.language is null)
         and type1.incident_type_id(+) = audi.old_incident_type_id
         and (type1.language = userenv('LANG') or type1.language is null)
         and type2.incident_type_id(+) = audi.incident_type_id
         and (type2.language = userenv('LANG') or type2.language is null)
         and status1.incident_status_id(+) = audi.old_incident_status_id
         and (status1.language = userenv('LANG') or status1.language is null)
         and status2.incident_status_id(+) = audi.incident_status_id
         and (status2.language = userenv('LANG') or status2.language is null)
         and urgency1.incident_urgency_id(+) = audi.old_incident_urgency_id
         and (urgency1.language = userenv('LANG') or urgency1.language is null)
         and urgency2.incident_urgency_id(+) = audi.incident_urgency_id
         and (urgency2.language = userenv('LANG') or urgency2.language is null)
         and ext1.resource_id(+) = audi.old_incident_owner_id
         and team1.team_id(+) = audi.old_incident_owner_id
         and (team1.language = userenv('LANG') or team1.language is null)
         and grp1.group_id(+) = audi.old_incident_owner_id
         and (grp1.language = userenv('LANG') or grp1.language is null)
         and ext2.resource_id(+) = audi.incident_owner_id
         and team2.team_id(+) = audi.incident_owner_id
         and (team2.language = userenv('LANG') or team2.language is null)
         and grp2.group_id(+) = audi.incident_owner_id
         and (grp2.language = userenv('LANG') or grp2.language is null)
         and obj1.object_code(+) = audi.old_resource_type
         and (obj1.language = userenv('LANG') or obj1.language is null)
         and obj2.object_code(+) = audi.resource_type
         and (obj2.language = userenv('LANG') or obj2.language is null);

     cursor task_cursor is select 'TASK' source_type,jtf.task_id,fnd.user_name,
                                  jtf.last_update_date,jtf.description
            from jtf_tasks_vl jtf, fnd_user fnd
            where source_object_type_code='SR'
            and source_object_id=p_incident_id
            and jtf.last_updated_by = fnd.user_id;

     cursor note_cursor is select 'NOTE' source_type,jtf.jtf_note_id,fnd.user_name,
                                  jtf.last_update_date,jtf.notes
            from jtf_notes_vl jtf, fnd_user fnd
            where source_object_code='SR'
            and source_object_id=p_incident_id
            and jtf.last_updated_by = fnd.user_id;

     cursor activity_cursor is select 'ACTIVITY' source_type,jtf.interaction_id,
            act.short_description,fnd.user_name,jtf.last_update_date
             from jtf_ih_activities jtf, jtf_ih_actions_tl act,
             fnd_user fnd
             where doc_ref = 'SR'
             and doc_id    = p_incident_id
             and jtf.action_id = act.action_id
             and act.language  = userenv('LANG')
            and jtf.last_updated_by = fnd.user_id;

     cursor soln_cursor is
                 select 'SOLN' source_type, setv.set_id,
                 setv.name set_summary, sett.name set_type_name,
                 elev.name element_summary, elet.name element_type_name,
                 setl.last_update_date, fnd.user_name
                 from cs_kb_set_links setl, cs_kb_sets_vl setv,
                 cs_kb_set_types_tl sett, cs_kb_element_links elel,
                 cs_kb_elements_vl elev, cs_kb_element_types_tl elet,
                 fnd_user fnd
                 where setl.object_code ='SR'
                 and setl.other_id = p_incident_id
                 and setl.set_id=setv.set_id
                 and sett.set_type_id=setv.set_type_id(+)
                 and (sett.language = userenv('LANG') or sett.language is null)
                 and (elel.object_code='KB' or elel.object_code is null)
                 and elel.other_id(+)=setv.set_id
                 and elel.element_id=elev.element_id(+)
                 and elev.element_type_id = elet.element_type_id(+)
                 and (elet.language = userenv('LANG') or elet.language is null)
                 and setl.last_updated_by = fnd.user_id;

     i_main_pointer integer;
     i_other_pointer integer;
     i_size_of_kb    integer;
     l_incident_id 	number;
     l_formated_string	varchar2(100);
     old_set_id		number;
     length_of_string   number;
  gs_newline varchar2(1) := substr('

',1,1);

  begin

/* This function executes each of the SQL and stores the data in
   the Main array and Other Array	*/
     l_formated_string := null;
     cs_sr_log_data_temp_pvt.i_total_records := 0;
     cs_sr_log_data_temp_pvt.i_other_records := 0;

     for i_ctn in log_cursor
     loop

        length_of_string := 0;

        if i_ctn.incident_severity_flag = 'Y' then
           length_of_string := cs_sr_log_data_temp_pvt.format_data('parameter.log_severity'||': ',
                                     i_ctn.old_severity_name,
                                     i_ctn.new_severity_name,
                                     i_ctn.incident_severity_flag,
                                     i_ctn.last_update_date,
                                     i_ctn.last_updated_by,
                                     i_ctn.source_type);
        end if;

        if i_ctn.incident_type_flag = 'Y' then
           length_of_string := cs_sr_log_data_temp_pvt.format_data('parameter.log_type'||': ',
                                     i_ctn.old_type_name,
                                     i_ctn.new_type_name,
                                     i_ctn.incident_type_flag,
                                     i_ctn.last_update_date,
                                     i_ctn.last_updated_by,
                                     i_ctn.source_type);
        end if;

        if i_ctn.incident_status_flag = 'Y' then
           length_of_string := cs_sr_log_data_temp_pvt.format_data('parameter.log_status'||': ',
                                     i_ctn.old_status_name,
                                     i_ctn.new_status_name,
                                     i_ctn.incident_status_flag,
                                     i_ctn.last_update_date,
                                     i_ctn.last_updated_by,
                                     i_ctn.source_type);
        end if;

        if i_ctn.incident_urgency_flag = 'Y' then
           length_of_string := cs_sr_log_data_temp_pvt.format_data('parameter.log_urgency'||': ',
                                     i_ctn.old_urgency_name,
                                     i_ctn.new_urgency_name,
                                     i_ctn.incident_urgency_flag,
                                     i_ctn.last_update_date,
                                     i_ctn.last_updated_by,
                                     i_ctn.source_type);
        end if;

        if i_ctn.change_resource_type_flag = 'Y' then
           length_of_string := cs_sr_log_data_temp_pvt.format_data('parameter.log_owner_type'||': ',
                                     i_ctn.old_resource_type,
                                     i_ctn.resource_type,
                                     i_ctn.change_resource_type_flag,
                                     i_ctn.last_update_date,
                                     i_ctn.last_updated_by,
                                     i_ctn.source_type);
        end if;

        if i_ctn.incident_owner_flag = 'Y' then
           length_of_string := cs_sr_log_data_temp_pvt.format_data('parameter.log_owner'||': ',
                                     i_ctn.old_owner,
                                     i_ctn.new_owner,
                                     i_ctn.incident_owner_flag,
                                     i_ctn.last_update_date,
                                     i_ctn.last_updated_by,
                                     i_ctn.source_type);
        end if;

        if i_ctn.resolution_date_flag = 'Y' then
           length_of_string := cs_sr_log_data_temp_pvt.format_data('parameter.log_date'||': ',
                                     i_ctn.date_old,
                                     i_ctn.date_new,
                                     i_ctn.resolution_date_flag,
                                     i_ctn.last_update_date,
                                     i_ctn.last_updated_by,
                                     i_ctn.source_type);
        end if;

     end loop;		-- end of log_cursor loop

-- Task Cursor. Collecting all Task data into the arrays.
     i_main_pointer := cs_sr_log_data_temp_pvt.i_total_records;
     i_other_pointer := cs_sr_log_data_temp_pvt.i_other_records ;
     for i_ctn in task_cursor
     loop

        i_main_pointer := i_main_pointer + 1;
        cs_sr_log_data_temp_pvt.main_log_date(i_main_pointer)   := i_ctn.last_update_date;
        cs_sr_log_data_temp_pvt.main_log_pointer(i_main_pointer)   := i_main_pointer;

        cs_sr_log_data_temp_pvt.main_log_source(i_main_pointer) := i_ctn.source_type;
        cs_sr_log_data_temp_pvt.main_log_text(i_main_pointer)   := i_ctn.task_id;

        i_other_pointer := i_other_pointer + 1;
        cs_sr_log_data_temp_pvt.other_log_source(i_other_pointer):= i_ctn.source_type;
        cs_sr_log_data_temp_pvt.other_log_id(i_other_pointer)   := i_ctn.task_id;
        cs_sr_log_data_temp_pvt.other_log_text(i_other_pointer) := '*** '||'parameter.log_tasks'||': '||i_ctn.user_name||'  '||rpad(to_char(i_ctn.last_update_date,'DD-MON-YYYY HH24:MI:SS'),20,' ')||gs_newline||i_ctn.description||gs_newline;
        cs_sr_log_data_temp_pvt.main_log_page(i_main_pointer)   := length(cs_sr_log_data_temp_pvt.other_log_text(i_other_pointer));

     end loop;		-- end of task_cursor loop

     cs_sr_log_data_temp_pvt.i_total_records := i_main_pointer ;
     cs_sr_log_data_temp_pvt.i_other_records := i_other_pointer ;

-- Notes Cursor. Collecting all Notes data into the arrays.
     i_main_pointer := cs_sr_log_data_temp_pvt.i_total_records;
     i_other_pointer := cs_sr_log_data_temp_pvt.i_other_records ;

     for i_ctn in note_cursor
     loop

        i_main_pointer := i_main_pointer + 1;
        cs_sr_log_data_temp_pvt.main_log_date(i_main_pointer)   := i_ctn.last_update_date;
        cs_sr_log_data_temp_pvt.main_log_pointer(i_main_pointer)   := i_main_pointer;

        cs_sr_log_data_temp_pvt.main_log_source(i_main_pointer) := i_ctn.source_type;
        cs_sr_log_data_temp_pvt.main_log_text(i_main_pointer)   := i_ctn.jtf_note_id;

        i_other_pointer := i_other_pointer + 1;
        cs_sr_log_data_temp_pvt.other_log_source(i_other_pointer):= i_ctn.source_type;
        cs_sr_log_data_temp_pvt.other_log_id(i_other_pointer)   := i_ctn.jtf_note_id;
        cs_sr_log_data_temp_pvt.other_log_text(i_other_pointer) := '*** '||'parameter.log_notes'||': '||i_ctn.user_name||'  '||rpad(to_char(i_ctn.last_update_date,'DD-MON-YYYY HH24:MI:SS'),20,' ')||gs_newline||i_ctn.notes||gs_newline;
        cs_sr_log_data_temp_pvt.main_log_page(i_main_pointer)   := length(cs_sr_log_data_temp_pvt.other_log_text(i_other_pointer));

     end loop;		-- end of note_cursor loop

     cs_sr_log_data_temp_pvt.i_total_records := i_main_pointer ;
     cs_sr_log_data_temp_pvt.i_other_records := i_other_pointer ;

-- Activity Cursor. Collecting all Activity data into the arrays.
     i_main_pointer := cs_sr_log_data_temp_pvt.i_total_records;

     for i_ctn in activity_cursor
     loop

        i_main_pointer := i_main_pointer + 1;
        cs_sr_log_data_temp_pvt.main_log_date(i_main_pointer)   := i_ctn.last_update_date;
        cs_sr_log_data_temp_pvt.main_log_pointer(i_main_pointer)   := i_main_pointer;

        cs_sr_log_data_temp_pvt.main_log_source(i_main_pointer) := i_ctn.source_type;
        cs_sr_log_data_temp_pvt.main_log_text(i_main_pointer) := '*** '||'parameter.log_interaction'||': '||i_ctn.interaction_id||'  '||i_ctn.user_name;
        cs_sr_log_data_temp_pvt.main_log_text(i_main_pointer):=  cs_sr_log_data_temp_pvt.main_log_text(i_main_pointer)||'  '||rpad(to_char(i_ctn.last_update_date,'DD-MON-YYYY HH24:MI:SS'),20,' ')||'  '||i_ctn.short_description||gs_newline;
        cs_sr_log_data_temp_pvt.main_log_page(i_main_pointer)   := length(cs_sr_log_data_temp_pvt.main_log_text(i_main_pointer));

     end loop;		-- end of note_cursor loop

     cs_sr_log_data_temp_pvt.i_total_records := i_main_pointer ;

-- All Data from Knowledge base is fetched in this Cursor

     i_main_pointer := cs_sr_log_data_temp_pvt.i_total_records;
     i_other_pointer := cs_sr_log_data_temp_pvt.i_other_records ;
     old_set_id := 0;

     for i_ctn in soln_cursor
     loop

        if old_set_id <> i_ctn.set_id then
           i_size_of_kb := 0;
           i_main_pointer := i_main_pointer + 1;
           cs_sr_log_data_temp_pvt.main_log_date(i_main_pointer)   := i_ctn.last_update_date;
           cs_sr_log_data_temp_pvt.main_log_pointer(i_main_pointer)   := i_main_pointer;

           cs_sr_log_data_temp_pvt.main_log_source(i_main_pointer) := i_ctn.source_type||'-'||i_ctn.set_id;
           cs_sr_log_data_temp_pvt.main_log_text(i_main_pointer) := '*** '||'parameter.log_knowledge'||': '||i_ctn.user_name||'  '||rpad(to_char(i_ctn.last_update_date,'DD-MON-YYYY HH24:MI:SS'),20,' ');
           cs_sr_log_data_temp_pvt.main_log_text(i_main_pointer):= cs_sr_log_data_temp_pvt.main_log_text(i_main_pointer)||i_ctn.set_id||gs_newline||i_ctn.set_type_name||gs_newline||i_ctn.set_summary||gs_newline;
           i_size_of_kb := i_size_of_kb + length(cs_sr_log_data_temp_pvt.main_log_text(i_main_pointer));
           old_set_id:=i_ctn.set_id;
        end if;
        i_other_pointer := i_other_pointer + 1;
        cs_sr_log_data_temp_pvt.other_log_source(i_other_pointer):= i_ctn.source_type||'-'||i_ctn.set_id;
        cs_sr_log_data_temp_pvt.other_log_id(i_other_pointer)   := i_ctn.set_id;
        cs_sr_log_data_temp_pvt.other_log_text(i_other_pointer) := '              '||i_ctn.element_type_name||' : '||i_ctn.element_summary||gs_newline;
        i_size_of_kb := i_size_of_kb + length(cs_sr_log_data_temp_pvt.other_log_text(i_other_pointer));
        cs_sr_log_data_temp_pvt.main_log_page(i_main_pointer) := i_size_of_kb;

     end loop;

     cs_sr_log_data_temp_pvt.i_total_records := i_main_pointer ;
     cs_sr_log_data_temp_pvt.i_other_records := i_other_pointer ;

  end get_log_details;

  function format_data(column_name in varchar2,
                        old_field_name   in  varchar2,
                        new_field_name   in  varchar2,
                        changed_flag     in  varchar2,
                        last_update_date in  date,
                        last_updated_by  in  varchar2,
                        source_type      in varchar2) return number is

     l_formated_string varchar2(200);
  gs_newline varchar2(1) := substr('

',1,1);

     i_sort_pointer  integer;
     i_counter  integer;

  begin

/* This function formats all Audit data 	*/

     i_sort_pointer := cs_sr_log_data_temp_pvt.i_total_records;
     if changed_flag = 'Y' then
        l_formated_string := '*** '||'parameter.log_audit'||': '||last_updated_by||'  '||rpad(to_char(last_update_date,'DD-MON-YYYY HH24:MI:SS'),20,' ')||'  '||rpad(column_name,20,' ')||'  '||old_field_name||' --> '||new_field_name;

        l_formated_string := l_formated_string||gs_newline;
        i_sort_pointer := i_sort_pointer + 1;
        cs_sr_log_data_temp_pvt.main_log_date(i_sort_pointer)   := last_update_date;
        cs_sr_log_data_temp_pvt.main_log_pointer(i_sort_pointer)   := i_sort_pointer;

        cs_sr_log_data_temp_pvt.main_log_source(i_sort_pointer) := source_type;
        cs_sr_log_data_temp_pvt.main_log_text(i_sort_pointer)   := l_formated_string;
        cs_sr_log_data_temp_pvt.main_log_page(i_sort_pointer)   := length(l_formated_string);
     else
        l_formated_string := null;
     end if;

     cs_sr_log_data_temp_pvt.i_total_records := i_sort_pointer ;
     return length(l_formated_string);

  end format_data;

  function sort_log_data(p_low in integer, p_high in integer) RETURN INTEGER is
     l_mid_date		date;
     l_mid_source	varchar2(10);
     l_mid_log_text	varchar2(200);

     l_swap_date	date;
     l_swap_pointer	integer;
     l_swap_source	varchar2(10);
     l_swap_log_text	varchar2(200);

     i_start		integer;
     i_end		integer;
     i_mid		integer;
     i_return		integer;
     p_return		integer;

  begin
/* This procedure is an implementation of the Quick sort algorithm.
   www.maths.lse.ac.uk/Courses/MA309/quicksort.html -
   Some modification was done to the above Algorithm.
   Basically all the data in the main Array is sorted.
*/
     p_return := 0;
     if (p_low >= p_high) then
        return p_return;
     end if;

     i_start := p_low-1;
     i_end   := p_high;

     i_mid := i_end;    -- Selecting an arbitary mid point
     l_mid_date := cs_sr_log_data_temp_pvt.main_log_date(i_mid);

     while i_start < i_end		-- Main while loop
     loop
        loop
           i_start := i_start + 1;
           if (i_start > i_end) then
              i_start := i_end;
              exit;
           end if;
           if (cs_sr_log_data_temp_pvt.main_log_date(i_start) < l_mid_date) then
              exit;
           end if;
        end loop;

        loop
           i_end := i_end - 1;
           if ((i_end < i_start) or
            (cs_sr_log_data_temp_pvt.main_log_date(i_end) > l_mid_date)) then
              exit;
           end if;
        end loop;

        if (i_start < i_end) then
           --Swap data in i_start  i_end
           l_swap_date := cs_sr_log_data_temp_pvt.main_log_date(i_start);
           l_swap_pointer := cs_sr_log_data_temp_pvt.main_log_pointer(i_start);

           cs_sr_log_data_temp_pvt.main_log_date(i_start):= cs_sr_log_data_temp_pvt.main_log_date(i_end);
           cs_sr_log_data_temp_pvt.main_log_pointer(i_start):= cs_sr_log_data_temp_pvt.main_log_pointer(i_end);

           cs_sr_log_data_temp_pvt.main_log_date(i_end):= l_swap_date;
           cs_sr_log_data_temp_pvt.main_log_pointer(i_end):= l_swap_pointer;

        end if;
     end loop;			-- End of main while loop

     l_swap_date := cs_sr_log_data_temp_pvt.main_log_date(i_start);
     l_swap_pointer := cs_sr_log_data_temp_pvt.main_log_pointer(i_start);

     cs_sr_log_data_temp_pvt.main_log_date(i_start):= cs_sr_log_data_temp_pvt.main_log_date(p_high);
     cs_sr_log_data_temp_pvt.main_log_pointer(i_start):= cs_sr_log_data_temp_pvt.main_log_pointer(p_high);

     cs_sr_log_data_temp_pvt.main_log_date(p_high):= l_swap_date;
     cs_sr_log_data_temp_pvt.main_log_pointer(p_high):= l_swap_pointer;

     i_return := cs_sr_log_data_temp_pvt.sort_log_data(p_low, i_start - 1);
     i_return := cs_sr_log_data_temp_pvt.sort_log_data(i_start + 1, p_high);
     return p_return;

  end sort_log_data;

  procedure insert_log_data(p_session_id  NUMBER,
                            p_incident_id NUMBER) is

    i_counter      integer;
    i_location     integer:=1;
    i_position     integer;
    l_source_id    number;
    l_set_id	   varchar2(30);
    total_log_size number:=0;
    start_location integer := 1;

  begin

    /*
    This function is used to insert data from the memory arrays to
    the field LOG_NOTES.LOG_DETAILS.
    */
    -- Delete the records first
    --
    cs_sr_log_data_temp_pvt.delete_log( p_session_id, p_incident_id);

    cs_sr_log_data_temp_pvt.display_seq := 0;
    total_log_size := 0;
    for i_location in start_location..cs_sr_log_data_temp_pvt.i_total_records
    loop
      i_counter := cs_sr_log_data_temp_pvt.main_log_pointer(i_location);
      cs_sr_log_data_temp_pvt.display_seq := cs_sr_log_data_temp_pvt.display_seq+1;

      if cs_sr_log_data_temp_pvt.main_log_source(i_counter) ='AUDIT' then

        cs_sr_log_data_temp_pvt.insert_log( p_session_id, p_incident_id,
                                            cs_sr_log_data_temp_pvt.main_log_text(i_counter));

      elsif cs_sr_log_data_temp_pvt.main_log_source(i_counter) ='ACTIVITY' then

        cs_sr_log_data_temp_pvt.insert_log( p_session_id, p_incident_id,
                                            cs_sr_log_data_temp_pvt.main_log_text(i_counter));

      elsif cs_sr_log_data_temp_pvt.main_log_source(i_counter) ='TASK' then
        l_source_id := to_number(rtrim(cs_sr_log_data_temp_pvt.main_log_text(i_counter)));
        cs_sr_log_data_temp_pvt.get_data_location('TASK', l_source_id, i_position);

        cs_sr_log_data_temp_pvt.insert_log( p_session_id, p_incident_id,
                                            cs_sr_log_data_temp_pvt.other_log_text(i_position));

      elsif cs_sr_log_data_temp_pvt.main_log_source(i_counter) ='NOTE' then
        l_source_id := to_number(rtrim(cs_sr_log_data_temp_pvt.main_log_text(i_counter)));
        cs_sr_log_data_temp_pvt.get_data_location('NOTE', l_source_id, i_position);

        cs_sr_log_data_temp_pvt.insert_log( p_session_id, p_incident_id,
                                            cs_sr_log_data_temp_pvt.other_log_text(i_position));

      elsif substr(cs_sr_log_data_temp_pvt.main_log_source(i_counter),1,4) ='SOLN'
         and cs_sr_log_data_temp_pvt.i_other_records > 0 then

        cs_sr_log_data_temp_pvt.insert_log( p_session_id, p_incident_id,
                                            cs_sr_log_data_temp_pvt.main_log_text(i_counter));
        l_set_id := substr(cs_sr_log_data_temp_pvt.main_log_source(i_counter),6,length(cs_sr_log_data_temp_pvt.main_log_source(i_counter)));
        l_source_id := to_number(rtrim(l_set_id));
        cs_sr_log_data_temp_pvt.get_data_location(cs_sr_log_data_temp_pvt.main_log_source(i_counter), l_source_id, i_position);

        i_position := 1;
        while (i_position <= cs_sr_log_data_temp_pvt.i_other_records)
        loop
           if (cs_sr_log_data_temp_pvt.other_log_source(i_position) = cs_sr_log_data_temp_pvt.main_log_source(i_counter)
            and cs_sr_log_data_temp_pvt.other_log_id(i_position)=l_source_id) then

              cs_sr_log_data_temp_pvt.insert_log( p_session_id, p_incident_id, cs_sr_log_data_temp_pvt.other_log_text(i_position));
          end if;
          i_position := i_position + 1;
        end loop;


      end if;	-- End of if for all Source Types.

    end loop;

  end insert_log_data;

  procedure get_data_location(source_type in varchar2, source_id in number, position out  NOCOPY integer) is
     count number;
  begin

/* Given parameters of source_type and source_id this function
   searches the Other Array and returns the pointer of the data.
   This function will not be used later as the pointer will be directly
   stored			*/

     if source_id is not null and source_type is not null then
        if cs_sr_log_data_temp_pvt.i_other_records = 1 then
           if cs_sr_log_data_temp_pvt.other_log_id(1)=source_id
              and cs_sr_log_data_temp_pvt.other_log_source(1)=source_type then
              position := 1;
           end if;

        else
           for i_position in 1..cs_sr_log_data_temp_pvt.i_other_records
           loop
              if cs_sr_log_data_temp_pvt.other_log_id(i_position)=source_id
                 and cs_sr_log_data_temp_pvt.other_log_source(i_position)=source_type then
                 position := i_position;
                 exit;
              end if;
           end loop;
        end if;              -- End of if at i_other_records=1
     end if;

  end get_data_location;

  procedure inc_display_seq is
    ctn number;

  begin
      cs_sr_log_data_temp_pvt.display_seq := cs_sr_log_data_temp_pvt.display_seq+1;

  end inc_display_seq;

END;

/
