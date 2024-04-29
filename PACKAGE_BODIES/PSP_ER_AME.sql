--------------------------------------------------------
--  DDL for Package Body PSP_ER_AME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ER_AME" as
/* $Header: PSPERAMB.pls 120.4 2005/09/30 02:46 dpaudel noship $*/
g_retry_request_id integer;
procedure insert_error(p_request_id    in integer,
                       p_message_level in varchar2,
                       p_source_id     in integer,
                       p_err_mesg      in varchar2,
                       p_retry_request_id in integer) is
 l_return_status varchar2(1);
 failed_insertion exception;
begin
  psp_general.add_report_error(p_request_id,
                               p_message_level,
                               p_source_id    ,
                               p_retry_request_id,
                               nULL,
                               p_err_mesg     ,
                               l_return_status ) ;
  if l_return_status = 'E' then
    fnd_msg_pub.add_exc_msg('PSP_ER_AME','INSERT_ERROR');
    raise failed_insertion;
  end if;
end;
procedure get_first_approvers(p_request_id    in integer,
                              p_start_person  in integer,
                              p_end_person    in integer,
                              p_return_status out nocopy varchar2,
                              p_retry_request_id in integer default null) is

  l_err_mesg varchar2(2000);
  no_approver_found exception;
  l_no_approver_found boolean;
  populate_error    exception;
  type er_rec_type is
        record (effort_report_detail_id integer,
                person_id          integer,
                assignment_id      integer,
                project_id         integer,
                award_id           integer,
                task_id            integer,
                expenditure_org_id integer,
                expenditure_type   varchar2(30),
                segment1           varchar2(25),
                segment2           varchar2(25),
                segment3           varchar2(25),
                segment4           varchar2(25),
                segment5           varchar2(25),
                segment6           varchar2(25),
                segment7           varchar2(25),
                segment8           varchar2(25),
                segment9         varchar2(25),
                segment10        varchar2(25),
                segment11        varchar2(25),
                segment12        varchar2(25),
                segment13        varchar2(25),
                segment14        varchar2(25),
                segment15        varchar2(25),
                segment16        varchar2(25),
                segment17        varchar2(25),
                segment18        varchar2(25),
                segment19        varchar2(25),
                segment20        varchar2(25),
                segment21        varchar2(25),
                segment22        varchar2(25),
                segment23        varchar2(25),
                segment24        varchar2(25),
                segment25        varchar2(25),
                segment26        varchar2(25),
                segment27        varchar2(25),
                segment28        varchar2(25),
                segment29        varchar2(25),
                segment30        varchar2(25));

  type er_cur_type is ref cursor;
  er_cur      er_cur_type;
  er_rec      er_rec_type;
  er_rec_prev er_rec_type;
  sql_string varchar2(2000) := '';
  l_ame_txn_id varchar2(50);
  l_counter integer;
  l_process_complete varchar2(1000);
  l_next_approver ame_util.approversTable2;
  l_approver_sql_stmnt varchar2(2000) := null;
  l_sqlerrm varchar2(4000);
  type t_integer is table of number(15) index by binary_integer;
  type break_rec_type  is record
       (array_detail_id        t_integer,
        array_break_attribute  t_integer,
        array_break_attribute2 t_integer);

  break_rec break_rec_type;
  t_erd_id t_integer;


  cursor wf_approval_cur is
  select decode(approval_type,'PRE','N','Y') workflow_approval_req_flag,
         approval_type,
         custom_approval_code,
         sup_levels
  from psp_report_templates_h
  where request_id = p_request_id;

  cursor check_valid_prj is
  select er.person_id
    from psp_eff_report_details erd,
         psp_eff_reports er
   where erd.project_id is null
     and erd.effort_Report_id  = er.effort_report_id
     and er.request_id = p_request_id;

  cursor get_report_layout is
  select substr(report_Template_code,6,3)
    from psp_report_templates_h
   where request_id = p_request_id;

  l_report_layout_code varchar2(20);
  l_err_person_id      number;

  cursor check_non_sponsered_prj is
  select er.person_id
    from psp_eff_report_details erd,
         psp_eff_reports er
   where erd.award_id is null
     and erd.effort_Report_id  = er.effort_report_id
     and er.request_id = p_request_id;

 --- changed following 3 cursors to remove ame calls
  cursor er_cur_gpi_pmg_tmg is
                      select min(erd.effort_report_detail_id),
                             erd.investigator_person_id,
                            null
                     from psp_eff_reports er,
                          psp_eff_report_details erd
                     where er.effort_report_id = erd.effort_report_id
                       and er.status_code = 'N'
                       and er.request_id =  p_request_id
                       and er.person_id between p_start_person  and  p_end_person
                      group by erd.investigator_person_id;

---- uva fix end

  cursor er_cur_emp is select min(effort_report_detail_id),
                            person_id,
                            null
                     from psp_eff_reports er,
                          psp_eff_report_details erd
                     where er.effort_report_id = erd.effort_report_id
                       and er.status_code = 'N'
                       and er.request_id =  p_request_id
                       and er.person_id between p_start_person  and  p_end_person
                      group by person_id;

      --- AME will be called only for supervisor, i.e min person, min of er_detail_id
  cursor er_cur_sup_1 is select min(erd.effort_report_detail_id),
                            min(er.person_id),
                            asg.supervisor_id
                       from per_assignments_f asg,
                            psp_eff_reports er,
                            psp_eff_report_details erd
                      where asg.person_id = er.person_id
                        and er.status_code = 'N'
                        and asg.assignment_type ='E'
                        and trunc(er.end_date) between asg.effective_start_date and
                                                       asg.effective_end_date
                        and asg.primary_flag = 'Y'
                        and er.effort_report_id = erd.effort_report_id
                        and er.request_id =  p_request_id
                        and er.person_id between p_start_person  and  p_end_person
                      group by asg.supervisor_id;

  i integer;
  l_error_out varchar2(4000);
  approval_type_rec wf_approval_cur%rowtype;
   approver_rec     ame_util.approverRecord2;


  ---=============  Local Procedures =============---

   --- Function to build Select stmnt for custom approvals -----
   function make_select return varchar2 is
      select_string varchar2(1000) := null;
   begin
     hr_utility.trace ('psperamb--> Entered make_select');

      if instr(g_approver_basis, 'assignment_id') > 0 then
          select_string := ',assignment_id' ;
      else
          select_string := ',null';
      end if;

      if instr(g_approver_basis, 'project_id') > 0 then
          select_string := select_string||',project_id' ;
      else
          select_string := select_string||',null';
      end if;

      if instr(g_approver_basis, 'award_id') > 0 then
          select_string := select_string ||',award_id' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'task_id') > 0 then
          select_string := select_string ||',task_id' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'expenditure_organization_id') > 0 then
          select_string := select_string ||',expenditure_organization_id' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'expenditure_type') > 0 then
          select_string := select_string ||',expenditure_type' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment1') > 0 then
          select_string := select_string ||',segment1' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment2') > 0 then
          select_string := select_string ||',segment2' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment3') > 0 then
          select_string := select_string ||',segment3' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment4') > 0 then
          select_string := select_string ||',segment4' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment5') > 0 then
          select_string := select_string ||',segment5' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment6') > 0 then
          select_string := select_string ||',segment6' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment7') > 0 then
          select_string := select_string ||',segment7' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment8') > 0 then
          select_string := select_string ||',segment8' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment9') > 0 then
          select_string := select_string ||',segment9' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment10') > 0 then
          select_string := select_string ||',segment10' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment11') > 0 then
          select_string := select_string ||',segment11' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment12') > 0 then
          select_string := select_string ||',segment12' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment13') > 0 then
          select_string := select_string ||',segment13' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment14') > 0 then
          select_string := select_string ||',segment14' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment15') > 0 then
          select_string := select_string ||',segment15' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment16') > 0 then
          select_string := select_string ||',segment16' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment17') > 0 then
          select_string := select_string ||',segment17' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment18') > 0 then
          select_string := select_string ||',segment18' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment19') > 0 then
          select_string := select_string ||',segment19' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment20') > 0 then
          select_string := select_string ||',segment20' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment21') > 0 then
          select_string := select_string ||',segment21' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment22') > 0 then
          select_string := select_string ||',segment22' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment23') > 0 then
          select_string := select_string ||',segment23' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment24') > 0 then
          select_string := select_string ||',segment24' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment25') > 0 then
          select_string := select_string ||',segment25' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment26') > 0 then
          select_string := select_string ||',segment26' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment27') > 0 then
          select_string := select_string ||',segment27' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment28') > 0 then
          select_string := select_string ||',segment28' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment29') > 0 then
          select_string := select_string ||',segment29' ;
      else
          select_string := select_string ||',null';
      end if;

      if instr(g_approver_basis, 'segment30') > 0 then
          select_string := select_string ||',segment30' ;
      else
          select_string := select_string ||',null';
      end if;
     hr_utility.trace ('psperamb--> Exiting make_select, string='||select_string);
      return select_string;
   exception
      when others then
        fnd_msg_pub.add_exc_msg('PSP_ER_AME','MAKE_SELECT');
        raise;
   end;


   --- Function to determine break group, hence call AME for custom  approval---
   function break_group return boolean is
     i integer := 1;
   begin

      --- the first record, don't break the group
      if er_rec_prev.effort_report_detail_id is null then
         return true;
      end if;

      if instr(g_approver_basis, 'assignment_id') > 0 then
        if nvl(er_rec.assignment_id, -999) <> nvl(er_rec_prev.assignment_id, -999) then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'project_id') > 0 then
        if nvl(er_rec.project_id, -999) <> nvl(er_rec_prev.project_id, -999) then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'award_id') > 0 then
        if nvl(er_rec.award_id, -999) <> nvl(er_rec_prev.award_id, -999) then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'task_id') > 0 then
        if nvl(er_rec.task_id, -999) <> nvl(er_rec_prev.task_id, -999) then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'expenditure_organization_id') > 0 then
        if nvl(er_rec.expenditure_org_id, -999) <> nvl(er_rec_prev.expenditure_org_id, -999) then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'expenditure_type') > 0 then
        if (er_rec.expenditure_type is null and
           er_rec_prev.expenditure_type is null ) OR
           er_rec.expenditure_type <> er_rec_prev.expenditure_type then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment1') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment2') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment3') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment4') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment5') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment6') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment7') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment8') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment9') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment10') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment11') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment12') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment13') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment14') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment15') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment16') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment17') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment18') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment19') > 0 then
        if (er_rec.segment1 is null and er_rec_prev.segment1 is null ) or
            er_rec.segment1 <> er_rec_prev.segment1 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment20') > 0 then
        if (er_rec.segment20 is null and er_rec_prev.segment20 is null ) or
            er_rec.segment20 <> er_rec_prev.segment20 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment21') > 0 then
        if (er_rec.segment21 is null and er_rec_prev.segment21 is null ) or
            er_rec.segment21 <> er_rec_prev.segment21 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment22') > 0 then
        if (er_rec.segment22 is null and er_rec_prev.segment22 is null ) or
            er_rec.segment22 <> er_rec_prev.segment22 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment23') > 0 then
        if (er_rec.segment23 is null and er_rec_prev.segment23 is null ) or
            er_rec.segment23 <> er_rec_prev.segment23 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment24') > 0 then
        if (er_rec.segment24 is null and er_rec_prev.segment24 is null ) or
            er_rec.segment24 <> er_rec_prev.segment24 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment25') > 0 then
        if (er_rec.segment25 is null and er_rec_prev.segment25 is null ) or
            er_rec.segment25 <> er_rec_prev.segment25 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment26') > 0 then
        if (er_rec.segment26 is null and er_rec_prev.segment26 is null ) or
            er_rec.segment26 <> er_rec_prev.segment26 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment27') > 0 then
        if (er_rec.segment27 is null and er_rec_prev.segment27 is null ) or
            er_rec.segment27 <> er_rec_prev.segment27 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment28') > 0 then
        if (er_rec.segment28 is null and er_rec_prev.segment28 is null ) or
            er_rec.segment28 <> er_rec_prev.segment28 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment29') > 0 then
        if (er_rec.segment29 is null and er_rec_prev.segment29 is null ) or
            er_rec.segment29 <> er_rec_prev.segment29 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

      if instr(g_approver_basis, 'segment30') > 0 then
        if (er_rec.segment30 is null and er_rec_prev.segment30 is null ) or
            er_rec.segment30 <> er_rec_prev.segment30 then
          return true;
        elsif i = g_no_of_attributes then
          return false;
        end if;
        i := i + 1;
      end if;

    return false;
   exception
      when others then
        fnd_msg_pub.add_exc_msg('PSP_ER_AME','BREAK_GROUP');
        raise;
   end;

   procedure insert_into_approvals(p_custom_approvals        in varchar2,
                                  p_approval_type           in varchar2,
                                  p_effort_report_detail_id in integer,
                                  p_break_attribute         in integer,
                                  p_break_attribute2        in integer,
                                  p_wf_role_name            in varchar2,
                                  p_wf_orig_system          in varchar2,
                                  p_wf_orig_system_id       in integer,
                                  p_er_approval_status      in varchar2,
                                  p_approver_order_number   in integer,
                                  p_ame_transaction_id      in varchar2,
                                  p_approver_display_name   in varchar2) is

     l_approval_status varchar2(1) := nvl( p_er_approval_status,'P');
     l_user_id fnd_user.user_id%type := fnd_global.user_id;
     l_login_id number:= fnd_global.conc_login_id;

   begin
      if p_custom_approvals = 'Y' then
         insert into psp_eff_report_approvals
                 (effort_report_approval_id,
                  effort_report_detail_id,
                  wf_role_name,
                  wf_orig_system_id,
                  wf_orig_system,
                  approver_order_num,
                  approval_status,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  creation_date,
                  created_by,
                  wf_role_display_name,
                  object_version_number)
          values (psp_eff_report_approvals_s.nextval,
                  p_effort_report_detail_id,
                  p_wf_role_name,
                  p_wf_orig_system_id,
                  p_wf_orig_system,
                  p_approver_order_number,
                  l_approval_status,
                  sysdate,
                  l_user_id,
                  l_login_id,
                  sysdate,
                  l_user_id,
                  p_approver_display_name,
                  1);
      else --- seeded options
         if p_approval_type in ( 'GPI', 'PMG', 'TMG') then
            insert into psp_eff_report_approvals
                 (effort_report_approval_id,
                  effort_report_detail_id,
                  wf_role_name,
                  wf_orig_system,
                  wf_orig_system_id,
                  approver_order_num,
                  approval_status,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  creation_date,
                  created_by,
                  wf_role_display_name,
                  object_version_number)
            select psp_eff_report_approvals_s.nextval,
                   effort_report_detail_id,
                   p_wf_role_name,
                   p_wf_orig_system,
                   p_wf_orig_system_id,
                   p_approver_order_number,
                   l_approval_status,
                    sysdate,
                  l_user_id,
                  l_login_id,
                  sysdate,
                  l_user_id,
                  p_approver_display_name,
                  1
              from psp_eff_report_details erd,
                   psp_eff_reports er
             where erd.effort_report_id = er.effort_report_id
               and er.request_id = p_request_id
               and nvl(investigator_person_id,-999) = nvl(p_break_attribute,-999)
               and er.person_id between p_start_person and p_end_person
               and er.status_code = 'N';

                 --- Employee or Employee/Supervisor
          elsif p_approval_type in ('EMP', 'ESU') then
            hr_utility.trace('psperamb-->emp and esu insert');
            hr_utility.trace('psperamb-->brk attrib ,rquest id,st person, end person==='||p_break_attribute||'='|| p_request_id||'='|| p_start_person||'='|| p_end_person);
            insert into psp_eff_report_approvals
                 (effort_report_approval_id,
                  effort_report_detail_id,
                  wf_role_name,
                  wf_orig_system,
                  wf_orig_system_id,
                  approver_order_num,
                  approval_status,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  creation_date,
                  created_by,
                  wf_role_display_name,
                  object_version_number)
            select psp_eff_report_approvals_s.nextval,
                   effort_report_detail_id,
                   p_wf_role_name,
                   p_wf_orig_system,
                   p_wf_orig_system_id,
                   p_approver_order_number,
                   l_approval_status,
                  sysdate,
                  l_user_id,
                  l_login_id,
                  sysdate,
                  l_user_id,
                  p_approver_display_name,
                  1
              from psp_eff_report_details erd,
                   psp_eff_reports er
             where erd.effort_report_id = er.effort_report_id
               and er.request_id = p_request_id
               and nvl(er.person_id,-999) = nvl(p_break_attribute,-999)
               and er.person_id between p_start_person and p_end_person
               and er.status_code = 'N';

              hr_utility.trace('psperamb-->emp and esu insert -1');

          elsif p_approval_type in ('SUP') then
             insert into psp_eff_report_approvals
                 (effort_report_approval_id,
                  effort_report_detail_id,
                  wf_role_name,
                  wf_orig_system,
                  wf_orig_system_id,
                  approver_order_num,
                  approval_status,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  creation_date,
                  created_by,
                  wf_role_display_name,
                  object_version_number)
            select psp_eff_report_approvals_s.nextval,
                   effort_report_detail_id,
                   p_wf_role_name,
                   p_wf_orig_system,
                   p_wf_orig_system_id,
                   p_approver_order_number,
                   l_approval_status,
                  sysdate,
                  l_user_id,
                  l_login_id,
                  sysdate,
                  l_user_id,
                  p_approver_display_name,
                  1
              from psp_eff_report_details erd,
                   psp_eff_reports er,
                   per_all_assignments_f asg
             where erd.effort_report_id = er.effort_report_id
               and er.request_id = p_request_id
               and er.person_id between p_start_person and p_end_person
               and er.status_code = 'N'
               and asg.person_id = er.person_id
               and asg.assignment_type ='E'
               and trunc(er.end_date) between asg.effective_start_date
                                   and asg.effective_end_date
               and asg.primary_flag = 'Y'
               and nvl(asg.supervisor_id,-999) = nvl(p_break_attribute2,-999);

           end if;
      end if;
   exception
      when others then
        fnd_msg_pub.add_exc_msg('PSP_ER_AME','INSERT_INTO_APPROVALS');
        raise;
   end;

 --- procedure to populate the PSP_REPORT_ERRORS table.
 procedure populate_errors(p_approval_type    in varchar2,
                           p_sup_levels       in number,
                           p_group_attribute  in number,
                           p_group_attribute2 in number,
                           p_er_detail_id     in number,
                           p_ame_transaction_id in varchar2,
                           p_sqlerrm            in varchar2,
                           p_error_out          out  NOCOPY varchar2) is


  cursor er_PTA_cur(p_effort_Report_detail_id integer) is
  select project_id, task_id, award_id
    from psp_eff_Report_details
   where effort_report_Detail_id = p_effort_Report_Detail_id;

  er_pta_rec er_pta_cur%rowtype;

  cursor task_manager_error is
     select er.person_id,
            erd.task_number,
            erd.assignment_number
     from psp_eff_report_details erd,
          psp_eff_reports er
     where erd.effort_report_id = er.effort_report_id
       and er.request_id = p_request_id
       and nvl(erd.task_id,-9999) = nvl(p_group_attribute, -9999)
       and er.person_id between p_start_person  and  p_end_person
     group by er.person_id,
              erd.task_number,
              erd.assignment_number;
  task_rec task_manager_error%rowtype;

  cursor project_manager_error is
     select er.person_id,
            erd.project_number,
            erd.assignment_number
     from psp_eff_report_details erd,
          psp_eff_reports er
     where erd.effort_report_id = er.effort_report_id
       and er.request_id = p_request_id
       and nvl(erd.project_id,-9999) = nvl(p_group_attribute, -9999)
       and er.person_id between p_start_person  and  p_end_person
     group by er.person_id,
              erd.project_number,
              erd.assignment_number;
   project_rec project_manager_error%rowtype;

  cursor principal_investigator_error(p_request_id  integer,
                                      p_group_attribute  integer) is
     select er.person_id,
            erd.award_number,
            erd.assignment_number
     from psp_eff_report_details erd,
          psp_eff_reports er
     where erd.effort_report_id = er.effort_report_id
       and er.request_id = p_request_id
       and nvl(erd.award_id,-9999) = nvl(p_group_attribute, -9999)
       and er.person_id between p_start_person  and  p_end_person
     group by er.person_id,
              erd.award_number,
              erd.assignment_number;

   cursor get_supervisor_1_emps is
     select distinct er.person_id
       from psp_eff_reports er,
            psp_eff_report_details erd
      where er.effort_report_id = erd.effort_report_id
        and erd.ame_transaction_id = p_ame_transaction_id
        and er.person_id between p_start_person  and  p_end_person
        and er.request_id = p_request_id;

   award_rec  principal_investigator_error%rowtype;
   l_person_id per_all_people_f.person_id%type;

   type t_error_source_id    is table of integer index by binary_integer;
   type t_error_message     is table of psp_report_errors.error_message%type
                index by binary_integer;

   t_source_id t_error_source_id;
   t_err_mesg  t_error_message;
   i integer;
   l_incorrect_apr_type_msg varchar2(4000);


   procedure insert_errors is
     pragma autonomous_transaction;
     l_sqlerrm psp_report_errors.error_message%type;
   begin
	p_error_out := NULL;

     forall i in 1..t_source_id.count
       insert into psp_report_errors (error_sequence_id,
                                      request_id,
                                      message_level,
                                      source_id,
                                      error_message,
                                      retry_request_id)
                               values (psp_report_errors_s.nextval,
                                       p_request_id,
                                       'E',
                                       t_source_id(i) ,
                                       t_err_mesg(i),
                                       p_retry_request_id);
      commit;
   exception
     when others then
       l_sqlerrm := sqlerrm;
       hr_utility.trace('PSPERAMB-->POPULATER_ERRORS--> INSERT_ERRORS When others='||l_sqlerrm);
       insert into psp_report_errors
                    (error_sequence_id,
                     request_id,
                     message_level,
                     source_id,
                     error_message,
                     retry_request_id)
        select psp_report_errors_s.nextval,
               p_request_id,
               'E',
                null ,
      'Package, procedure = PSP_ER_AME,insert_errors-->ERROR inserting into psp_report_errors ',
               p_retry_request_id
        from dual;
       commit;
   end;



 begin
    if (approval_type_rec.approval_type in ('GPI','TMG','PMG')) then
           open er_PTA_cur(p_er_detail_id);
           fetch er_PTA_cur into er_PTA_rec;
           close er_PTA_cur;
           if (er_PTA_rec.project_id is null and approval_type_rec.approval_type = 'PMG') or
              (er_PTA_rec.award_id is null and approval_type_rec.approval_type = 'GPI') or
              (er_PTA_rec.task_id is null and approval_type_rec.approval_type = 'TMG') then
                  fnd_message.set_name('PSP','PSP_ER_AME_WRONG_APR_TYP');
                  l_incorrect_apr_type_msg := substr(fnd_message.get,1,2000);
           end if;
     end if;
     hr_utility.trace('psperamb--> POPULATE ERROR p_approval_type ='|| p_approval_type ||
                           ', p_sup_levels ='|| p_sup_levels ||
                           ', p_group_attribute ='|| p_group_attribute ||
                           ', p_group_attribute2 ='||  p_group_attribute2 ||
                           ', p_er_detail_id ='|| p_er_detail_id ||
                           ', p_ame_transaction_id ='||p_ame_transaction_id ||
                           ', p_sqlerrm ='|| p_sqlerrm||
                           ',  approval_type_rec.approval_type ='|| approval_type_rec.approval_type||
                           ', p_request_id =' || p_request_id);


      if approval_type_rec.approval_type = 'EMP' then
        fnd_message.set_name('PSP','PSP_ER_AME_EMP_APPRV_ERR');
          fnd_message.set_token('Error',p_sqlerrm);
        l_err_mesg := substr(fnd_message.get,1,2000);
        insert_error(p_request_id, 'E', p_group_attribute, l_err_mesg, p_retry_request_id);
      elsif approval_type_rec.approval_type = 'ESU' then
        fnd_message.set_name('PSP','PSP_ER_AME_ESU_APPRV_ERR');
          fnd_message.set_token('Error',p_sqlerrm);
        l_err_mesg := substr(fnd_message.get,1,2000);
        insert_error(p_request_id, 'E', p_group_attribute, l_err_mesg, p_retry_request_id);
      elsif approval_type_rec.approval_type = 'SUP' then
        fnd_message.set_name('PSP','PSP_ER_AME_SUP_APPRV_ERR');
          fnd_message.set_token('Error',p_sqlerrm);
        l_err_mesg := substr(fnd_message.get,1,2000);
          open get_supervisor_1_emps;
          fetch get_supervisor_1_emps bulk collect into t_source_id;
          close get_supervisor_1_emps;
          if t_source_id.count > 0 then
           i := 1;
           loop
              if i > t_source_id.count then
                exit;
              end if;
              t_err_mesg(i) := l_err_mesg;
              i := i + 1;
            end loop;
           end if;
           insert_errors;

      elsif approval_type_rec.approval_type = 'TMG' then
            open task_manager_error;
            i := 1;
            loop
              fetch task_manager_error into task_rec;
              if task_manager_error%notfound then
                close task_manager_error;
                exit;
              end if;
              if l_incorrect_apr_type_msg is not null then
                 t_err_mesg(i) := l_incorrect_apr_type_msg;
                 t_source_id(i) := task_rec.person_id;
               else
                  fnd_message.set_name('PSP','PSP_ER_AME_TMG_APPRV_ERR');
                  fnd_message.set_token('TASK_NUMBER',task_rec.task_number);
                  fnd_message.set_token('ASG_NUMBER',task_rec.assignment_number);
                  fnd_message.set_token('Error',p_sqlerrm);
                  l_err_mesg := substr(fnd_message.get,1,2000);
                  t_source_id(i) := task_rec.person_id;
                  t_err_mesg(i)  := l_err_mesg;
              end if;
              i := i + 1;
            end loop;
            if i > 1 then
               insert_errors;
            end if;


      elsif approval_type_rec.approval_type = 'PMG' then
        open project_manager_error;
        i := 1;
        loop
          fetch project_manager_error into project_rec;
          if project_manager_error%notfound then
             close project_manager_error;
             exit;
          end if;

          if l_incorrect_apr_type_msg is not null then
             t_err_mesg(i) := l_incorrect_apr_type_msg;
             t_source_id(i) := project_rec.person_id;
          else
              fnd_message.set_name('PSP','PSP_ER_AME_PMG_APPRV_ERR');
              fnd_message.set_token('PROJECT_NUMBER',project_rec.project_number);
              fnd_message.set_token('ASG_NUMBER',project_rec.assignment_number);
              fnd_message.set_token('Error',p_sqlerrm);
              l_err_mesg := substr(fnd_message.get,1,2000);
              t_source_id(i) := project_rec.person_id;
              t_err_mesg(i)  := l_err_mesg;
          end if;

          i := i + 1;
        end loop;
        if i > 1 then
           insert_errors;
        end if;
      elsif approval_type_rec.approval_type = 'GPI' then
        i := 1;
        open principal_investigator_error(p_request_id, p_group_attribute);
        loop
          fetch principal_investigator_error into award_rec;
          if principal_investigator_error%notfound then
             close  principal_investigator_error;
             exit;
          end if;
          if l_incorrect_apr_type_msg is not null then
             t_err_mesg(i) := l_incorrect_apr_type_msg;
             t_source_id(i) := award_rec.person_id;
          else
              fnd_message.set_name('PSP','PSP_ER_AME_GPI_APPRV_ERR');
              fnd_message.set_token('AWARD_NUMBER',award_rec.award_number);
              fnd_message.set_token('ASG_NUMBER',award_rec.assignment_number);
              fnd_message.set_token('Error',p_sqlerrm);
              l_err_mesg := substr(fnd_message.get,1,2000);
              hr_utility.trace('before insert into GPI');
              t_source_id(i) := award_rec.person_id;
              t_err_mesg(i)  := l_err_mesg;
           end if;
          i := i + 1;
        end loop;
        if i > 1 then
           insert_errors;
        end if;
      end if;
   hr_utility.trace('PSPERAMB-->POPULATER_ERRORS--> COMMIT');
    exception
     when others then
        p_error_out := sqlerrm;
        p_error_out :=  'Error in PSP_ER_AME - POPULATE_ERRORS '||p_error_out ;
        ---fnd_msg_pub.add_exc_msg('PSP_ER_AME','POPULATE_ERRORS');
        hr_utility.trace('psperamb--> POPULATE ERROR when others:'||p_error_out);
        p_error_out := substr(p_error_out,1,2000);
        insert_error(p_request_id, 'E', null, p_error_out, p_retry_request_id);
        raise;
  end;


  ---=============  END Local Procedures =============---

    ---- BEGIN main procedure body.
 begin

   --hr_utility.trace_on('Y','ORACLE');
   g_retry_request_id := p_retry_request_id;
   hr_utility.trace( 'psperamb-->Start rqid, stp, end person==='||p_request_id   ||'='||   p_start_person  ||'='||                      p_end_person    );
  l_no_approver_found := false;

 open  wf_approval_cur;
  --- need to check if it moves to history at this point
 fetch wf_approval_cur into approval_type_rec;
 close wf_approval_cur;

 if nvl(approval_type_rec.workflow_approval_req_flag,'N') = 'N' then

  open get_report_layout;
  fetch get_report_layout into l_report_layout_code;
  close get_report_layout;

  if l_report_layout_code in ('PIV','PMG', 'TMG') then
     l_counter := 0;
     open check_valid_prj;
     loop
       fetch check_valid_prj into l_err_person_id;
       if check_valid_prj%notfound then
           close check_valid_prj;
           exit;
       end if;
       fnd_message.set_name('PSP','PSP_ER_WRNG_RPT_LAYOUT');
       l_error_out := substr(fnd_message.get,1,2000);
       insert_error(p_request_id, 'E', l_err_person_id, l_error_out, p_retry_request_id);
       l_counter := l_counter + 1;
     end loop;
     if l_counter > 0 then
           p_return_status := fnd_api.g_ret_sts_error;
           return;
     end if;

     if l_report_layout_code = 'PIV' then
        open check_non_sponsered_prj;
        loop
        fetch check_non_sponsered_prj into l_err_person_id;
        if check_non_sponsered_prj%notfound then
           close check_non_sponsered_prj;
           exit;
        end if;
        fnd_message.set_name('PSP','PSP_ER_WRNG_RPT_LAYOUT');
        l_error_out := substr(fnd_message.get,1,2000);
        insert_error(p_request_id, 'E', l_err_person_id, l_error_out, p_retry_request_id);
        l_counter := l_counter + 1;
        end loop;
      end if;
     if l_counter > 0 then
           p_return_status := fnd_api.g_ret_sts_error;
           return;
     end if;
     l_counter := 0;
  end if;
   hr_utility.trace( 'psperamb--> Workflow approval not reqd .. exiting'    );
   update psp_eff_reports
     set status_code = 'A'
    where status_code = 'N'
      and request_id = p_request_id
      and person_id between p_start_person and  p_end_person;
   p_return_status := fnd_api.g_ret_sts_success;
   return;
 end if;

 if approval_type_rec.approval_type = 'CUS' then
     hr_utility.trace ('psperamb--> Entered Custom approval');

    --- ensure g_approver_basis will have lower case characters
    g_approver_basis := lower(g_approver_basis);
   sql_string :=  'select dtls.effort_report_detail_id,
                            rep.person_id '
                            ||make_select||
                     '  from psp_eff_report_details dtls,
                             psp_eff_reports rep
                        where rep.effort_report_id = dtls.effort_report_id
                          and rep.status_code ='|| ''''||'N'||'''' || '
                          and rep.request_id = :1
                          and rep.person_id between :1 and  :2 ';
   hr_utility.trace('psperamb--> custom select string='||sql_string);
   if trim(rtrim(g_approver_basis)) is not null then
       sql_string := sql_string ||' order by '||g_approver_basis;
   else
       g_approver_basis := null;
   end if;

   l_counter := 0;
   open er_cur for sql_string using p_request_id, p_start_person, p_end_person;
   loop
      fetch er_cur into er_rec;
      if er_cur%notfound then
         close er_cur;
         exit;
      end if;
      t_erd_id(l_counter) := er_rec.effort_report_detail_id;
      l_ame_txn_id := rpad(approval_type_rec.custom_approval_code,30)||rpad(' ',5)||
                       lpad(er_rec.effort_report_detail_id,15);
      hr_utility.trace('psperamb-->'||er_rec.person_id||'--'||er_rec.assignment_id||'--'||er_rec.project_id);
      begin
     hr_utility.trace ('psperamb-->size, AME TXN Id before ame call-102 length, txn_id ='||length( l_ame_txn_id)||' '||l_ame_Txn_id);
         if g_approver_basis is not null then
            if break_group then
                    forall i in 1..t_erd_id.count
                      update psp_eff_report_details
                         set ame_transaction_id = l_ame_txn_id
                      where effort_report_detail_id = t_erd_id(i);
                      ame_api2.getNextApprovers4(applicationidIn => 8403,
                                                 transactiontypeIn => 'PSP-ER-APPROVAL',
                                                 transactionIdIn => l_ame_txn_id,
                                                 flagApproversAsNotifiedIn => 'Y',
                                                 approvalProcessCompleteYNout => l_process_complete,
                                                 nextApproversOut=> l_next_approver);
                    l_counter := 0;
            end if;
         else
                      update psp_eff_report_details
                         set ame_transaction_id = l_ame_txn_id
                      where effort_report_detail_id = er_rec.effort_report_detail_id;

                      ame_api2.getNextApprovers4(applicationidIn => 8403,
                                                 transactiontypeIn => 'PSP-ER-APPROVAL',
                                                 transactionIdIn => l_ame_txn_id,
                                                 flagApproversAsNotifiedIn => 'Y',
                                                 approvalProcessCompleteYNout => l_process_complete,
                                                 nextApproversOut=> l_next_approver);
         end if;
      exception
      when others then
        l_sqlerrm := sqlerrm;
        hr_utility.trace(sqlerrm);
        fnd_msg_pub.add_exc_msg('PSP_ER_AME','GET_FIRST_APPROVER - AME CUSTOM ERR');
        fnd_message.set_name('PSP','PSP_ER_AME_CUST_APPRV_ERR');
        fnd_message.set_token('Error',l_sqlerrm);
        l_err_mesg := substr(fnd_message.get,1,2000);
                insert_error(p_request_id,
                     'E',
                     null ,
                     l_err_mesg, p_retry_request_id);
         begin
        select er.person_id
          into l_error_out
        from psp_eff_reports er,
             psp_eff_report_details erd
        where er.effort_report_id = erd.effort_report_id
          and er.request_id = p_request_id
          and erd.effort_report_detail_id = er_rec.effort_report_detail_id;
          l_sqlerrm := substr(l_sqlerrm,1,2000);
          insert_error(p_request_id,
                     'E',
                     l_error_out,
                     l_sqlerrm, p_retry_request_id);
        ---commit;
        exception
          when others then
              null;
       end;
     hr_utility.trace ('psperamb-->exception when others: '||length( l_ame_txn_id)||' '||l_ame_Txn_id);
    ---raise;
     p_return_status := fnd_api.g_ret_sts_unexp_error;
      end;
      update psp_eff_report_details
         set ame_transaction_id = l_ame_txn_id
       where effort_report_detail_id = er_rec.effort_report_detail_id;
       i := 1;
       loop
          if i > l_next_approver.count then
            exit;
          end if;
          insert_into_approvals('Y',
                                approval_type_rec.approval_type,
                                er_rec.effort_report_detail_id,
                                null,
                                null,
                                l_next_approver(i).name,
                                l_next_approver(i).orig_system,
                                l_next_approver(i).orig_system_id,
                                l_next_approver(i).approval_status,
                                l_next_approver(i).approver_order_number,
                                l_ame_txn_id,
                                l_next_approver(i).display_name);
           i := i + 1; --- i > 1 only for parallel approvers
      end loop;
      er_rec_prev := er_rec;
   end loop;

hr_utility.trace('psperamb--> **** CUSTOM APPROVAL TYPE **** make_select return='||make_select);
     p_return_status := fnd_api.g_ret_sts_success;
   return;
else
      hr_utility.trace('psperamb-->Seeded options approval type='||
            approval_type_rec.approval_type||' Worflow approval reqd '||
             approval_type_rec.workflow_approval_req_flag);
  --- seeded approval options
  if approval_type_rec.approval_type in ( 'GPI', 'PMG', 'TMG') then
     open er_cur_gpi_pmg_tmg;
     fetch er_cur_gpi_pmg_tmg bulk collect into break_rec.array_detail_id,
                                                break_rec.array_break_attribute,
                                                break_rec.array_break_attribute2;
     close er_cur_gpi_pmg_tmg;
  elsif approval_type_rec.approval_type in ( 'EMP', 'ESU')  then
      hr_utility.trace('psperamb-->to open EMP Cursor ');
     open er_cur_emp;
     fetch er_cur_emp bulk collect into break_rec.array_detail_id,
                                    break_rec.array_break_attribute,
                                    break_rec.array_break_attribute2;
     close er_cur_emp;
  elsif approval_type_rec.approval_type = 'SUP'  then
     open er_cur_sup_1;
     fetch er_cur_sup_1 bulk collect into break_rec.array_detail_id,
                                    break_rec.array_break_attribute,
                                    break_rec.array_break_attribute2;
     close er_cur_sup_1;
  end if;
end if;
  if break_rec.array_detail_id.count = 0 then
     hr_utility.trace('psperamb-->no data found in the seed break groups ');
     --- nothing to process for this chunk
      p_return_status := fnd_api.g_ret_sts_success;
     return;
  end if;

   hr_utility.trace('psperamb-->count='||break_rec.array_detail_id.count);
  l_counter := 1;
  loop
    if l_counter > break_rec.array_detail_id.count then
     exit;
    end if;


  l_ame_txn_id := 'SEED-'|| rpad(approval_type_rec.approval_type,15)
                         || rpad(nvl(break_rec.array_break_attribute(l_counter),-9),15)
                         || lpad(break_rec.array_detail_id(l_counter),15);

         if approval_type_rec.approval_type = 'GPI'
          or approval_type_rec.approval_type = 'PMG'
          or approval_type_rec.approval_type = 'TMG' then
             update psp_eff_report_details
                set ame_transaction_id = l_ame_txn_id
              where nvl(investigator_person_id,-999) = nvl(break_rec.array_break_attribute(l_counter),-999)
                and effort_report_id in
                     (select effort_report_id
                        from psp_eff_reports er
                       where er.request_id = p_request_id
                         and er.person_id between p_start_person and p_end_person
                         and er.status_code = 'N');
                 --- Employee or Employee/Supervisor
          elsif approval_type_rec.approval_type in ('EMP', 'ESU') then
             update psp_eff_report_details
                set ame_transaction_id = l_ame_txn_id
              where effort_report_id in
                     (select erd.effort_report_id
                        from psp_eff_report_details  erd
                       where erd.effort_report_detail_id = break_rec.array_detail_id(l_counter));
          elsif approval_type_rec.approval_type in ('SUP') then
             update psp_eff_report_details erd
                set erd.ame_transaction_id = l_ame_txn_id
              where erd.effort_report_id in
                     (select er.effort_report_id
                        from psp_eff_reports er,
                             per_all_assignments_f asg
                       where er.request_id = p_request_id
                         and er.person_id between p_start_person and p_end_person
                         and er.status_code = 'N'
                         and asg.person_id = er.person_id
                         and asg.assignment_type ='E'
                         and trunc(er.end_date) between asg.effective_start_date
                                                   and asg.effective_end_date
                         and asg.primary_flag = 'Y'
                         and nvl(asg.supervisor_id,-999) = nvl(break_rec.array_break_attribute2(l_counter),-999));
           end if;

     if approval_type_rec.approval_type  not in ('GPI' , 'PMG' , 'TMG') then
     hr_utility.trace ('psperamb-->size,AME TXN Id='||length( l_ame_txn_id)||','||l_ame_Txn_id);

  begin
     hr_utility.trace ('psperamb-->size, AME TXN Id before ame call-101= length, txn_id '||length( l_ame_txn_id)||' '||l_ame_Txn_id);

    ame_api2.getNextApprovers4(applicationidIn => 8403,
                        transactiontypeIn => 'PSP-ER-APPROVAL',
                        transactionIdIn => l_ame_txn_id,
                        flagApproversAsNotifiedIn => 'N',
                        approvalProcessCompleteYNout => l_process_complete,
                        nextApproversOut=> l_next_approver);
     hr_utility.trace ('psperamb-->2L='||length( l_ame_txn_id)||' '||l_ame_Txn_id);
   exception
    when others then
        l_sqlerrm := sqlerrm;
        hr_utility.trace(l_sqlerrm);
        hr_utility.trace ('psperamb-->L ERR 1000='||length( l_ame_txn_id)||' '||l_ame_Txn_id);
        fnd_msg_pub.add_exc_msg('PSP_ER_AME','GET_FIRST_APPROVER - AME CALL ERR');
        l_sqlerrm := substr(l_Sqlerrm,1,1700);
        l_no_approver_found := true;
         /* insert_error(p_request_id,
                     'E',
                     null,
                     l_sqlerrm); */
        populate_errors(approval_type_rec.approval_type,
                        approval_type_rec.sup_levels,
                        break_rec.array_break_attribute(l_counter),
                        break_rec.array_break_attribute2(l_counter),
                        break_rec.array_detail_id(l_counter),
                        l_ame_Txn_id,
                        l_sqlerrm,
                        l_error_out);
        if l_error_out is not null then
            raise populate_error;
        end if;
    end;

   if l_sqlerrm is null then
    if l_next_approver.count = 0 then
        hr_utility.trace ('psperamb-->#### APPRVL COUNT ZERO #### TXN Length, Id ='||length( l_ame_txn_id)||' '||l_ame_Txn_id);
        --- AME did not return approver.
        fnd_msg_pub.add_exc_msg('PSP_ER_AME','GET_FIRST_APPROVER - AME CALL');
        l_no_approver_found := true;
        populate_errors(approval_type_rec.approval_type,
                        approval_type_rec.sup_levels,
                        break_rec.array_break_attribute(l_counter),
                        break_rec.array_break_attribute2(l_counter),
                        break_rec.array_detail_id(l_counter),
                        l_ame_Txn_id,
                        l_sqlerrm,
                        l_error_out);
        if l_error_out is not null then
            raise populate_error;
        end if;
        hr_utility.trace ('psperamb-->#### APPRVL COUNT ZERO #### After Populate Error');
    else
       i := 1;
       loop
          if i > l_next_approver.count then
            hr_utility.trace ('psperamb-->L= inside array loop'||l_ame_Txn_id);
            exit;
          end if;

          insert_into_approvals('N',
                                approval_type_rec.approval_type,
                                break_rec.array_detail_id(l_counter),
                                break_rec.array_break_attribute(l_counter),
                                break_rec.array_break_attribute2(l_counter),
                                l_next_approver(i).name,
                                l_next_approver(i).orig_system,
                                l_next_approver(i).orig_system_id,
                                l_next_approver(i).approval_status,
                                l_next_approver(i).approver_order_number,
                                l_ame_txn_id,
                                l_next_approver(i).display_name);
           i := i + 1; --- i > 1 only for parallel approvers
       end loop;
   end if;
   else
   l_sqlerrm := null;
   end if;
  else
          wf_directory.getUserName('PER',
                                   break_rec.array_break_attribute(l_counter),
                                   l_next_approver(1).name,
                                   l_next_approver(1).display_name);

          l_next_approver(1).approval_status := 'P';
          l_next_approver(1).approver_order_number := 1;
          l_next_approver(1).orig_system := 'PER';
          l_next_approver(1).orig_system_id := break_rec.array_break_attribute(l_counter);

          insert_into_approvals('N',
                                approval_type_rec.approval_type,
                                break_rec.array_detail_id(l_counter),
                                break_rec.array_break_attribute(l_counter),
                                break_rec.array_break_attribute2(l_counter),
                                l_next_approver(1).name,
                                l_next_approver(1).orig_system,
                                l_next_approver(1).orig_system_id,
                                l_next_approver(1).approval_status,
                                l_next_approver(1).approver_order_number,
                                l_ame_txn_id,
                                l_next_approver(1).display_name);

  /*
    approver_rec.name :=  l_next_approver(1).name;
    approver_rec.orig_system := l_next_approver(1).orig_system;
    approver_rec.orig_system_id := l_next_approver(1).orig_system_id;
    approver_rec.approval_status:= ame_util.notifiedstatus;
    ame_api2.updateapprovalstatus(applicationidin => 8403,
                                    transactiontypein => 'PSP-ER-APPROVAL',
                                    transactionidin => l_ame_txn_id,
                                    approverin => approver_rec); */
  end if;
   l_counter := l_counter + 1;
  end loop;
     break_rec.array_detail_id.delete;
     break_rec.array_break_attribute.delete;
     break_rec.array_break_attribute2.delete;
  if l_no_approver_found then
    raise no_approver_found;
  else
     p_return_status := fnd_api.g_ret_sts_success;
  end if;
 hr_utility.trace_off;
exception
  -- removed the usage of this exception.. LOOP to continue till it finishes the
  -- all eff records.
  when no_approver_found then
     hr_utility.trace ('psperamb--> no_approver_found: '||length( l_ame_txn_id)||','||l_ame_Txn_id);
    ----raise;
    --- commit;
    fnd_msg_pub.add_exc_msg('PSP_ER_AME','GET_FIRST_APPROVER NO-APP-FOUND');
     p_return_status := fnd_api.g_ret_sts_error;
  when populate_error then
    fnd_msg_pub.add_exc_msg('PSP_ER_AME','', l_error_out);
    p_return_status := fnd_api.g_ret_sts_error;
  when others then
    fnd_msg_pub.add_exc_msg('PSP_ER_AME','GET_FIRST_APPROVER');
       l_sqlerrm := sqlerrm;
       hr_utility.trace(l_sqlerrm);
       begin
        select er.person_id
          into l_error_out
        from psp_eff_reports er,
             psp_eff_report_details erd
        where er.effort_report_id = erd.effort_report_id
          and er.request_id = p_request_id
          and erd.effort_report_detail_id = break_rec.array_detail_id(l_counter);
          l_sqlerrm := substr(l_sqlerrm,1,2000);
          insert_error(p_request_id,
                     'E',
                     l_error_out,
                     l_sqlerrm, p_retry_request_id);
        ---commit;
        exception
          when others then
              null;
       end;
     hr_utility.trace ('psperamb-->exception when others: '||length( l_ame_txn_id)||' '||l_ame_Txn_id);
    ---raise;
     p_return_status := fnd_api.g_ret_sts_unexp_error;
end;
end;

/
