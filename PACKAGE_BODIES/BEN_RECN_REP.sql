--------------------------------------------------------
--  DDL for Package Body BEN_RECN_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RECN_REP" as
/* $Header: bercnrep.pkb 120.0 2005/05/28 11:36:03 appldev noship $ */
/* ===========================================================================
 * Name:
 *   ben_recn_rep
 * Purpose:
 *   This package writes the Reconciliation of Premium to Element Entries
 *   Report in  CSV format. There are procedures in this package which
 *   can be used to write to a file.
 * History:
 *   Date        Who       Version  What?
 *   ----------- --------- -------  -----------------------------------------
 *   20-Jan-2003 vsethi    115.0    Created.
 *   22-Jan-2003 vsethi    115.1    Modified after unit testing
 *   23-Jan-2003 vsethi    115.3    Plan Disc 'Total' not displayed
 *   28-Jan-2003 vsethi    115.4    Payroll Name not displayed
 *				    Person Selection rule failing as seesion
 *				    info is not present in fnd_sessions
 *   28-Jan-2003 vsethi    115.5    In reconciliation and discrepancy sections
 *				    added a clause to restrict enrt records
 *				    whose cvg begins before the report end date.
 *   30-Jan-2003 vsethi    115.6    Life event name not getting diplayed
 *   07-Feb-2003 vsethi    115.7    Removed the p_run_date and p_mon_year parameters
 *   19-Feb-2003 vsethi    115.8    2791345 - For person enrolled in multiple options
 *				            premium is not displayed for the second record.
 *   30-Jun-03   vsethi    115.9    Changed reference for table ben_rptg_grp
 *			                 MLS compliant view ben_rptg_grp_v
 *   18-May-04   rpgupta   115.10   3608119 - picks up sum of all rates
 *                                  when an unerstricted enrollment is
 *                                  done, rates are changed and recalculate
 *                                  participant rates is run
 *   08-Jun-04   rpgupta   115.11   3608119 - added date check in FUNCTION
 *                                  get_prtt_rate_val
 *   20-Jul-04   nhunur    115.12   3775260 - Report should not be restricted to Employees.
 *                                  and also look at ERPYC acty typ rates in get_rate_val and get_element_val.
 *   5-apr-05   nhunur     115.13    Use pds.end_date for queries to pickup rate / element values properly
 *                                   if rate changes midway thru pay period.
 *   19-May-05   rbingi    115.15   Bug-4383835 Removed to_date for p_report_start_date because its
 *                                   already of type date. part of GSCC FireDrill
 * ===========================================================================
 */
--
-- Package Variables
--
f_out   utl_file.file_type ;

--
-- ============================================================================
--                            <<open_log_file>>
-- ============================================================================
--
procedure open_log_file(p_log_file_name  in out nocopy varchar2 )
as
   l_output_log_file       varchar2(250)    ;
   l_audit_log_dir         varchar2(250);
   l_temp                  varchar2(5)     ;
   l_temp_num              number(5) ;
   --
begin
      -- Get  log file name using fnd routines
      if p_log_file_name is null then
        --
      	fnd_file.get_names(P_LOG  => g_log_file_name,
                         P_OUT  => l_output_log_file);
      	--g_log_file_name := replace(g_log_file_name,'.tmp','.csv');
      	--
      else
      	g_log_file_name := p_log_file_name;
      end if;
      --
      -- Get utl file dir from v$parameters change this query for only one dir
      -- in utl_file_dir
      --
      select  decode(instr(value,','),0,value,
      	      substrb(translate(ltrim(value),',',' '),
              1,
              instr(translate(ltrim(value),',',' '),' ') - 1))
      into    l_audit_log_dir
      from    v$parameter
      where   name = 'utl_file_dir';

      -- Open the log File using FND routines
      f_out := utl_file.fopen(l_audit_log_dir,g_log_file_name,'w',32767);
      --

      -- Form the Audit Log File Name
      -- Get the file separator for the platform

      --  Check for a / in audit log dir
      --  If a / is found then use / as file seperator (unix)
      --  else use \ ( for win nt
      l_temp_num := instr(l_audit_log_dir,'/');

      if l_temp_num <=0 then
            l_temp :='\' ;
      else
            l_temp :='/' ;
      end if;


      g_log_file_name := l_audit_log_dir || l_temp || g_log_file_name ;
      p_log_file_name := g_log_file_name ;
      --
exception
	when others then
	raise;
end open_log_file ;
--
-- ============================================================================
--                            <<put_line>>
-- ============================================================================
--
procedure put_line(p_message  in varchar2) as
begin
        -- do logging only if log flag is true and severity level is
        -- greater than current level
        /*fnd_file.put_line(
                          WHICH    =>FND_FILE.LOG ,
                          BUFF     =>p_message );*/
        utl_file.put_line(f_out,p_message);
        utl_file.fflush(f_out);
end put_line ;
--
-- ============================================================================
--                            <<close_log_file>>
-- ============================================================================
--
procedure close_log_file as
begin
   utl_file.fclose(f_out) ;
   g_log_file_name := null;
end close_log_file;
--
-- ============================================================================
--                            <<print_report>>
-- ============================================================================
--
procedure print_report(p_log_file_name  IN OUT nocopy varchar2,
		      p_report_array    IN ben_recn_rep.g_report_array ,
		      p_close_file 	IN boolean default TRUE )
as
  l_record varchar2(10000);
  --
begin
    -- open the file
    if g_log_file_name is null then
        open_log_file(p_log_file_name);
    else
	p_log_file_name :=  g_log_file_name;
    end if;
    --
    for l_array_count in p_report_array.first..p_report_array.last loop
    -- loop through the array and print the output

	l_record := '"'||p_report_array(l_array_count).col1||'",'||
		'"'||p_report_array(l_array_count).col2||'",'||
		'"'||p_report_array(l_array_count).col3||'",'||
		'"'||p_report_array(l_array_count).col4||'",'||
		'"'||p_report_array(l_array_count).col5||'",'||
		'"'||p_report_array(l_array_count).col6||'",'||
		'"'||p_report_array(l_array_count).col7||'",'||
		'"'||p_report_array(l_array_count).col8||'",'||
		'"'||p_report_array(l_array_count).col9||'",'||
		'"'||p_report_array(l_array_count).col10||'",'||
		'"'||p_report_array(l_array_count).col11||'",'||
		'"'||p_report_array(l_array_count).col12||'",'||
		'"'||p_report_array(l_array_count).col13||'",'||
		'"'||p_report_array(l_array_count).col14||'",'||
		'"'||p_report_array(l_array_count).col15||'",'||
		'"'||p_report_array(l_array_count).col16||'",'||
		'"'||p_report_array(l_array_count).col17||'",'||
		'"'||p_report_array(l_array_count).col18||'",'||
		'"'||p_report_array(l_array_count).col19||'",'||
		'"'||p_report_array(l_array_count).col20 ||'"';
	--
        put_line(l_record);
        l_record := null;
    end loop;
    put_line('End Of Section');
    --
    -- close the file
    if p_close_file then
    	close_log_file;
    end if;
    --
exception
when others then
     close_log_file;
     raise;
end print_report;
--
-- ============================================================================
--                            <<recon_report>>
-- ============================================================================
--
procedure recon_report
          (p_pl_id  		number,
           p_pgm_id		number,
           p_person_id		number,
           p_per_sel_rule	number,
           p_business_group_id	number,
           p_benefit_action_id	number,
           p_organization_id	number,
           p_location_id	number,
           p_ntl_identifier	varchar2,
           p_rptg_grp_id 	number,
           p_benfts_grp_id 	number,
           p_run_date 		date,
           p_report_start_date  date,
           p_report_end_date    date,
           p_prem_type		varchar2,
           p_payroll_id		number,
           p_dsply_pl_disc_rep  varchar2,
           p_dsply_pl_recn_rep  varchar2,
           p_dsply_pl_prtt_rep  varchar2,
           p_dsply_prtt_reps    varchar2,
           p_dsply_lfe_rep      varchar2,
           p_emp_name_format	varchar2,
           p_conc_request_id	number,
           p_rep_st_dt	  	date, -- original rep start date as submitted in the concurrent request
           p_rep_end_dt	  	date, -- original rep start date as submitted in the concurrent request
	   p_dsply_recn	        varchar2,
	   p_dsply_disc	        varchar2,
	   p_dsply_lfe	        varchar2,
	   p_dsply_pl_prtt   	varchar2,
	   p_output_typ		varchar2,
           p_op_file_name       IN OUT nocopy varchar2
          ) is

	--

	cursor c_plan_recn is
	select  pl_oraganization_name  pl_org_name,
		pl_location_name       pl_loc_name,
		pl_payroll_name        pl_pay_name,
		pl_full_name           pl_per_name,
		pl_national_identifier pl_ntnl_id,
		pl_bnft_amount         pl_bnft_amt,
		pl_prem_val            pl_prem_val,
		pl_sql_uom             pl_uom,
		pl_period_type         pl_perd_typ,
		sum(ee_ptax_rt_val)   ee_ptax_rt_val_tot,
		sum(ee_atax_rt_val)   ee_atax_rt_val_tot,
		sum(er_rt_val )       er_rt_val_tot,
		sum(ee_ptax_rt_val +  ee_atax_rt_val + er_rt_val) pay_perd_total,
		sum(ee_ptax_elem_val) ee_ptax_elem_val_tot,
		sum(ee_atax_elem_val) ee_atax_elem_val_tot,
		sum(er_elem_val )     er_elem_val_tot ,
		sum(ee_ptax_elem_val +  ee_atax_elem_val + er_elem_val) actual_total
	from (select distinct hr_general.decode_organization(asg.organization_id)   pl_oraganization_name
	      ,hr_general.decode_location(asg.location_id)		   pl_location_name
	      ,pay.payroll_name 	   pl_payroll_name
	      ,decode(p_emp_name_format,'JP',( per.last_name || ' ' || per.first_name || ' / ' ||    -- the japanese name format should be kept in sync with hrjputil.pkb
					       per.per_information18 || ' ' || per.per_information19)
				      , per.full_name)  pl_full_name
	      ,per.national_identifier pl_national_identifier
	      ,pen.bnft_amt 	       pl_bnft_amount
	      ,mpr.val		       pl_prem_val
	      ,nvl(pen.uom, mpr.uom)    pl_sql_uom
	      ,pay.period_type 	       pl_period_type
	      ,pds.period_name 	       pl_period_name
	      ,to_char(pds.start_date,'MM/DD')|| ' - '|| to_char(pds.end_date,'MM/DD') pl_pay_prd
	      ,ben_recn_rep.get_rate_val(pen.prtt_enrt_rslt_id,pds.end_date,p_business_group_id,'PRETAX','EEPYC',pen.per_in_ler_id, pds.end_date) ee_ptax_rt_val
	      ,ben_recn_rep.get_rate_val(pen.prtt_enrt_rslt_id,pds.end_date,p_business_group_id,'AFTERTAX','EEPYC',pen.per_in_ler_id, pds.end_date) ee_atax_rt_val
	      ,ben_recn_rep.get_rate_val(pen.prtt_enrt_rslt_id,pds.end_date,p_business_group_id,null,'ERC',pen.per_in_ler_id, pds.end_date) er_rt_val
	      ,ben_recn_rep.get_element_val(pen.prtt_enrt_rslt_id,pds.end_date,p_business_group_id,'PRETAX','EEPYC',pen.per_in_ler_id, pds.end_date) ee_ptax_elem_val
	      ,ben_recn_rep.get_element_val(pen.prtt_enrt_rslt_id,pds.end_date,p_business_group_id,'AFTERTAX','EEPYC',pen.per_in_ler_id, pds.end_date) ee_atax_elem_val
	      ,ben_recn_rep.get_element_val(pen.prtt_enrt_rslt_id,pds.end_date,p_business_group_id,null,'ERC',pen.per_in_ler_id, pds.end_date) er_elem_val
	from  ben_prtt_enrt_rslt_f pen
	     ,ben_actl_prem_f acp
	     ,ben_prtt_prem_f prm
	     ,ben_prtt_prem_by_mo_f mpr
	     ,ben_per_in_ler pil
	     ,per_all_people_f per
	     ,per_person_types ptp
	     ,pay_all_payrolls_f pay
	     ,per_time_periods pds
	     ,per_all_assignments_f asg
	where pen.pl_id = p_pl_id
	and   (pen.pgm_id = p_pgm_id or p_pgm_id is null)
	and   pen.prtt_enrt_rslt_stat_cd is null
	and   pen.business_group_id = p_business_group_id
	and   pen.enrt_cvg_thru_dt >= pen.effective_end_date
	and   (p_report_start_date between pen.enrt_cvg_strt_dt  and pen.enrt_cvg_thru_dt
       	      or p_report_end_date between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
       	      or (p_report_start_date >= pen.enrt_cvg_strt_dt and p_report_end_date <= pen.enrt_cvg_thru_dt)
       	      or (p_report_start_date <= pen.enrt_cvg_strt_dt and p_report_end_date >= pen.enrt_cvg_thru_dt))
	and   ((pen.effective_end_date < pen.enrt_cvg_thru_dt
  	        and (p_report_start_date between pen.effective_start_date and pen.effective_end_date
            	or p_report_end_date between pen.effective_start_date and pen.effective_end_date
            	or (p_report_start_date >= pen.effective_start_date and p_report_end_date <= pen.effective_end_date)
            	or (p_report_start_date <= pen.effective_start_date and p_report_end_date >= pen.effective_end_date)))
	      or pen.effective_end_date >= pen.enrt_cvg_thru_dt   )
       	and   pen.sspndd_flag = 'N'
	and   pen.per_in_ler_id = pil.per_in_ler_id
	and   pil.per_in_ler_stat_cd not in ( 'VOIDD' , 'BCKDT')
	and   pil.person_id = per.person_id
	and   ptp.person_type_id = per.person_type_id
	and   ptp.system_person_type in ( 'EMP' , 'EX_EMP' , 'EX_EMP_APL' , 'EMP_APL' , 'PRTN' )
	and   (p_person_id is null or pen.person_id = p_person_id)
	and   (p_per_sel_rule is null or pen.person_id in (select person_id
							    from ben_person_actions pac
							    where pac.benefit_action_id = p_benefit_action_id) )
	and   (p_ntl_identifier is null or per.national_identifier = p_ntl_identifier)
	and   pen.prtt_enrt_rslt_id = prm.prtt_enrt_rslt_id (+)
	and   mpr.prtt_prem_id(+) = prm.prtt_prem_id
	and   mpr.yr_num(+) = to_number(to_char(p_report_start_date,'YYYY'))
	and   mpr.mo_num(+) = to_number(to_char(p_report_start_date,'MM'))
	and   prm.per_in_ler_id (+) = pen.per_in_ler_id
	and   acp.actl_prem_id (+) = prm.actl_prem_id
	and   (p_prem_type is null or acp.prsptv_r_rtsptv_cd = p_prem_type )
	and   pen.person_id = asg.person_id
	and   pen.business_group_id = p_business_group_id
	and   asg.business_group_id = p_business_group_id
/*	and   asg.assignment_type = 'E' */
	and   asg.primary_flag = 'Y'
	and   (p_payroll_id is null or asg.payroll_id = p_payroll_id )
	and   asg.payroll_id = pay.payroll_id
	and   pds.payroll_id = pay.payroll_id
	and   pds.start_date >= p_report_start_date
	and   pds.end_date   <= p_report_end_date
	and   per.business_group_id = p_business_group_id
	and   p_run_date between per.effective_start_date and per.effective_end_date
	and   p_run_date between asg.effective_start_date and asg.effective_end_date
	and   p_run_date between pay.effective_start_date and pay.effective_end_date
	and   p_run_date between acp.effective_start_date (+) and acp.effective_end_date (+)
	and	  p_run_date >= prm.effective_start_date (+)
	and	  p_run_date <= prm.effective_end_date (+)
	and   (p_organization_id is null
		       or asg.organization_id = p_organization_id )
		and   (p_location_id is null
		       or asg.location_id = p_location_id)
		and   (p_benfts_grp_id is null
		       or per.benefit_group_id = p_benfts_grp_id)
		and   (p_rptg_grp_id is null
		       or exists (select null
				  from   ben_popl_rptg_grp_f   prpg
				  where  (pen.pl_id = prpg.pl_id
			  	  or     pen.pgm_id = prpg.pgm_id )
				  and    prpg.rptg_grp_id = p_rptg_grp_id))
	) pl
	group by pl_oraganization_name, pl_location_name,  pl_payroll_name ,
		pl_full_name, pl_national_identifier, pl_bnft_amount , pl_prem_val, pl_sql_uom, pl_period_type
	order by 1,2,3,4;
	--
	cursor c_plan_disc is
	select pl.*
	       ,ee_ptax_rt_val + ee_atax_rt_val + er_rt_val pay_perd_total
	       ,ee_ptax_elem_val + ee_atax_elem_val + er_elem_val actual_total
	       ,((ee_ptax_elem_val + ee_atax_elem_val + er_elem_val) -
		 (ee_ptax_rt_val + ee_atax_rt_val + er_rt_val)) std_rt_dis
	       ,nvl(((ee_ptax_elem_val + ee_atax_elem_val + er_elem_val ) - pl_prem_val),0) prem_dis
	from (select distinct hr_general.decode_organization(asg.organization_id)   pl_oraganization_name
	      ,hr_general.decode_location(asg.location_id)		   pl_location_name
	      ,pay.payroll_name 	   pl_payroll_name
	      ,decode(p_emp_name_format,'JP',( per.last_name || ' ' || per.first_name || ' / ' ||    -- the japanese name format should be kept in sync with hrjputil.pkb
	      				       per.per_information18 || ' ' || per.per_information19)
	      			       , per.full_name)  pl_full_name
	      ,per.person_id		   pl_person_id
	      ,per.national_identifier 	   pl_national_id
	      ,pen.bnft_amt 		   pl_bnft_amount
	      ,mpr.val			   pl_prem_val
	      ,nvl(pen.uom,mpr.uom)	   pl_sql_uom
	      ,pay.period_type 		   pl_period_type
	      ,pds.period_name 		   pl_period_name
	      ,to_char(pds.start_date,'MM/DD')|| ' - '|| to_char(pds.end_date,'MM/DD') pl_pay_prd
	      ,ben_recn_rep.get_rate_val(pen.prtt_enrt_rslt_id,pds.end_date,p_business_group_id,'PRETAX','EEPYC',pen.per_in_ler_id, pds.end_date)      ee_ptax_rt_val
	      ,ben_recn_rep.get_rate_val(pen.prtt_enrt_rslt_id,pds.end_date,p_business_group_id,'AFTERTAX','EEPYC',pen.per_in_ler_id, pds.end_date)    ee_atax_rt_val
	      ,ben_recn_rep.get_rate_val(pen.prtt_enrt_rslt_id,pds.end_date,p_business_group_id,null,'ERC',pen.per_in_ler_id, pds.end_date) 	 	 er_rt_val
	      ,ben_recn_rep.get_element_val(pen.prtt_enrt_rslt_id,pds.end_date,p_business_group_id,'PRETAX','EEPYC',pen.per_in_ler_id, pds.end_date)   ee_ptax_elem_val
	      ,ben_recn_rep.get_element_val(pen.prtt_enrt_rslt_id,pds.end_date,p_business_group_id,'AFTERTAX','EEPYC',pen.per_in_ler_id, pds.end_date) ee_atax_elem_val
	      ,ben_recn_rep.get_element_val(pen.prtt_enrt_rslt_id,pds.end_date,p_business_group_id,null,'ERC',pen.per_in_ler_id, pds.end_date) 	 er_elem_val
	from  ben_prtt_enrt_rslt_f pen
	     ,ben_actl_prem_f acp
	     ,ben_prtt_prem_f prm
	     ,ben_prtt_prem_by_mo_f mpr
	     ,ben_per_in_ler pil
	     ,per_all_people_f per
	     ,per_person_types ptp
	     ,pay_all_payrolls_f pay
	     ,per_time_periods pds
	     ,per_all_assignments_f asg
	where pen.pl_id = p_pl_id
	and   (pen.pgm_id = p_pgm_id or p_pgm_id is null)
	and   pen.prtt_enrt_rslt_stat_cd is null
	and   pen.business_group_id = p_business_group_id
	and   pen.enrt_cvg_thru_dt >= pen.effective_end_date
	and   (p_report_start_date between pen.enrt_cvg_strt_dt  and pen.enrt_cvg_thru_dt
       	      or p_report_end_date between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
       	      or (p_report_start_date >= pen.enrt_cvg_strt_dt and p_report_end_date <= pen.enrt_cvg_thru_dt)
       	      or (p_report_start_date <= pen.enrt_cvg_strt_dt and p_report_end_date >= pen.enrt_cvg_thru_dt))
	and   ((pen.effective_end_date < pen.enrt_cvg_thru_dt
  	        and (p_report_start_date between pen.effective_start_date and pen.effective_end_date
            	or p_report_end_date between pen.effective_start_date and pen.effective_end_date
            	or (p_report_start_date >= pen.effective_start_date and p_report_end_date <= pen.effective_end_date)
            	or (p_report_start_date <= pen.effective_start_date and p_report_end_date >= pen.effective_end_date)))
	      or pen.effective_end_date >= pen.enrt_cvg_thru_dt   )
       	and   pen.sspndd_flag = 'N'
	and   pen.per_in_ler_id = pil.per_in_ler_id
	and   pil.per_in_ler_stat_cd not in ( 'VOIDD' , 'BCKDT')
	and   pil.person_id = per.person_id
	and   ptp.person_type_id = per.person_type_id
	and   ptp.system_person_type in ( 'EMP', 'EX_EMP' , 'EX_EMP_APL' , 'EMP_APL' , 'PRTN' )
	and   (p_person_id is null or pen.person_id = p_person_id)
	and   (p_per_sel_rule is null or pen.person_id in (select person_id
	                                                    from ben_person_actions pac
	                                                    where pac.benefit_action_id = p_benefit_action_id) )
	and   (p_ntl_identifier is null or per.national_identifier = p_ntl_identifier)
	and   pen.prtt_enrt_rslt_id = prm.prtt_enrt_rslt_id (+)
	and   mpr.prtt_prem_id(+) = prm.prtt_prem_id
	and   mpr.yr_num(+) = to_number(to_char(p_report_start_date,'YYYY'))
	and   mpr.mo_num(+) = to_number(to_char(p_report_start_date,'MM'))
	and   prm.per_in_ler_id (+) = pen.per_in_ler_id
	and   acp.actl_prem_id (+) = prm.actl_prem_id
	and   (p_prem_type is null or acp.prsptv_r_rtsptv_cd = p_prem_type )
	and   pen.person_id = asg.person_id
	and   pen.business_group_id = p_business_group_id
	and   asg.business_group_id = p_business_group_id
/*	and   asg.assignment_type = 'E' */
	and   asg.primary_flag = 'Y'
	and   (p_payroll_id is null or asg.payroll_id = p_payroll_id )
	and   asg.payroll_id = pay.payroll_id
	and   pds.payroll_id = pay.payroll_id
	and   pds.start_date >= p_report_start_date
	and   pds.end_date   <= p_report_end_date
	and   per.business_group_id = p_business_group_id
	and   p_run_date between per.effective_start_date and per.effective_end_date
	and   p_run_date between asg.effective_start_date and asg.effective_end_date
	and   p_run_date between pay.effective_start_date and pay.effective_end_date
	and   p_run_date between acp.effective_start_date (+) and acp.effective_end_date (+)
	and   p_run_date >= prm.effective_start_date (+)
	and   p_run_date <= prm.effective_end_date (+)
	and   (p_organization_id is null
	       or asg.organization_id = p_organization_id )
	and   (p_location_id is null
	       or asg.location_id = p_location_id)
	and   (p_benfts_grp_id is null
	       or per.benefit_group_id = p_benfts_grp_id)
	and   (p_rptg_grp_id is null
	       or exists (select null
	                  from   ben_popl_rptg_grp_f   prpg
			  where  (pen.pl_id = prpg.pl_id
			  or     pen.pgm_id = prpg.pgm_id )
			  and    prpg.rptg_grp_id = p_rptg_grp_id))
	) pl
	where ((ee_ptax_elem_val + ee_atax_elem_val + er_elem_val) -
		   (ee_ptax_rt_val + ee_atax_rt_val + er_rt_val)) <> 0
	or    decode(((ee_ptax_elem_val + ee_atax_elem_val + er_elem_val ) - pl_prem_val),null,0,1) = 1
	order by 1,2,3,4;
	--
	cursor c_lf_prem is
	select * from (
	select hr_general.decode_organization(asg.organization_id) lf_org_name,
	       hr_general.decode_location(asg.location_id) lf_location_name,
	       hr_general.decode_payroll(asg.payroll_id) lf_payroll_name,
	       decode(p_emp_name_format,'JP',( per.last_name || ' ' || per.first_name || ' / ' ||
	      				       per.per_information18 || ' ' || per.per_information19)
	      			       , per.full_name) lf_full_name,
	       per.national_identifier lf_national_identifier ,
	       ler.name lf_ler_name ,
	       nvl(pen.uom,popl.uom) lf_uom,
	       pil.lf_evt_ocrd_dt,
	       ben_recn_rep.get_change_eff_dt(pen.prtt_enrt_rslt_id,	p_report_start_date,p_run_date) lf_chng_eff_dt,
	       ben_recn_rep.old_premium_val(pen.person_id,p_pl_id ,pen.pgm_id, pen.oipl_id, p_report_start_date, p_run_date, p_business_group_id, 'PREMIUM') lf_old_prem,
	       popl.val lf_val,
	       ben_recn_rep.old_premium_val(pen.person_id,p_pl_id ,pen.pgm_id, pen.oipl_id, p_report_start_date, p_run_date, p_business_group_id, 'RATE') lf_old_rate,
	       ben_recn_rep.get_new_rates(pen.prtt_enrt_rslt_id,p_report_start_date,p_run_date,p_business_group_id,'RATE',pen.per_in_ler_id) lf_rate,
	       ben_recn_rep.get_new_rates(pen.prtt_enrt_rslt_id,p_report_start_date,p_run_date,p_business_group_id,'ELEMENT',pen.per_in_ler_id ) lf_elem_val
	       /*,
	       ( select sum(cmcd_rt_val)
		 from 	ben_prtt_rt_val
		 where 	prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id) lf_rate ,
	       ( select sum(screen_entry_value)
		 from ben_prtt_rt_val prv
		      ,pay_element_entry_values_f env
	         where prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
		 and   env.element_entry_value_id = prv.element_entry_value_id) lf_elem_val */
	from  ben_prtt_enrt_rslt_f pen,
	      ben_per_in_ler pil,
	      ben_ler_f ler ,
	      ben_prtt_prem_f prm ,
	      ben_prtt_prem_by_mo_f popl,
	      per_all_people_f per,
	      per_all_assignments_f asg,
	      per_person_types ptp
	where pen.pl_id = p_pl_id
	and   (p_pgm_id is null or pen.pgm_id = p_pgm_id )
	and   pen.prtt_enrt_rslt_stat_cd is null
	and   pen.business_group_id = p_business_group_id
	and   pen.enrt_cvg_thru_dt <= pen.effective_end_date
	and   p_run_date between pen.enrt_cvg_strt_dt and enrt_cvg_thru_dt
	and   pen.sspndd_flag = 'N'
	and   (p_person_id is null or pen.person_id = p_person_id)
	and   (p_per_sel_rule is null or pen.person_id in (select person_id
	                                                    from ben_person_actions pac
	                                                    where pac.benefit_action_id = p_benefit_action_id) )
	and   pil.per_in_ler_id = pen.per_in_ler_id
	and   pil.per_in_ler_stat_cd not in ( 'VOIDD' , 'BCKDT')
	and   pil.lf_evt_ocrd_dt  = ( select max(pil2.LF_EVT_OCRD_DT)
	                              from 	   ben_per_in_ler pil2
	                              where  pil2.per_in_ler_id = pen.per_in_ler_id
	                              and    pil2.per_in_ler_stat_cd in ( 'STRTD','PROCD')
	                              and    pil2.lf_evt_ocrd_dt
	                              between p_report_start_date and p_report_end_date )
	and   pil.ler_id = ler.ler_id
	and   per.person_id = pil.person_id
	and   (p_ntl_identifier is null or per.national_identifier = p_ntl_identifier)
	and   p_run_date between per.effective_start_date and per.effective_end_date
	and   ptp.person_type_id = per.person_type_id
	and   ptp.system_person_type in ( 'EMP' , 'EX_EMP' , 'EX_EMP_APL' , 'EMP_APL' , 'PRTN' )
	and   asg.person_id = pen.person_id
	and   asg.business_group_id = p_business_group_id
/*	and   asg.assignment_type = 'E' */
	and   asg.primary_flag = 'Y'
	and   p_run_date between asg.effective_start_date and asg.effective_end_date
	and   prm.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
	and   p_run_date between prm.effective_start_date and prm.effective_end_date
	and   p_run_date between ler.effective_start_date and ler.effective_end_date
	and   prm.prtt_prem_id = popl.prtt_prem_id
	and   popl.yr_num =  to_number(to_char(p_report_start_date,'YYYY'))
	and   popl.mo_num =  to_number(to_char(p_report_start_date,'MM'))
	and   popl.business_group_id = p_business_group_id
	and   (p_organization_id is null
	       or asg.organization_id = p_organization_id )
	and   (p_location_id is null
	       or asg.location_id = p_location_id)
	and   (p_benfts_grp_id is null
	       or per.benefit_group_id = p_benfts_grp_id)
	and   (p_rptg_grp_id is null
	       or exists (select null
	                  from   ben_popl_rptg_grp_f   prpg
			  where  (pen.pl_id = prpg.pl_id
			  or     pen.pgm_id = prpg.pgm_id )
			  and    prpg.rptg_grp_id = p_rptg_grp_id))
	order by 1,2,3,4) pl
	where lf_old_prem <> lf_val ;
	--
	cursor c_pl_oipl is
	select distinct decode(apr.pl_id,null,'OIPL','PL') levels ,
	       hr_general.decode_organization(asg.organization_id) prtt_org_name,
	       hr_general.decode_location(asg.location_id) prtt_location_name,
	       hr_general.decode_payroll(asg.payroll_id) prtt_payroll_name,
	       decode(p_emp_name_format,'JP',( per.last_name || ' ' || per.first_name || ' / ' ||
	      				       per.per_information18 || ' ' || per.per_information19)
	      			       , per.full_name) full_name ,
	       per.national_identifier,
	       pen.enrt_cvg_strt_dt,
	       decode(pen.enrt_cvg_thru_dt,to_date('31-12-4712','dd-mm-yyyy'),null,pen.enrt_cvg_thru_dt) enrt_cvg_thru_dt ,
	       popl.val,
	       nvl(pen.uom, popl.uom) uom,
	       decode(apr.pl_id, null, ben_batch_utils.get_opt_name(apr.oipl_id, p_business_group_id, p_run_date)) option_name,
	       apr.oipl_id,
	       apr.pl_id ,
	       ben_recn_rep.get_prtt_rate_val(pen.prtt_enrt_rslt_id , p_report_start_date, pen.per_in_ler_id, p_report_end_date) rate-- 3608119
	from   ben_prtt_enrt_rslt_f pen
	       ,ben_per_in_ler pil
	       ,per_all_people_f per
	       ,per_person_types ptp
	       ,per_all_assignments_f asg
	       ,ben_actl_prem_f apr
	       ,ben_prtt_prem_f prm
	       ,ben_prtt_prem_by_mo_f popl
	where pen.pl_id = p_pl_id
	and   (p_pgm_id is null or pen.pgm_id = p_pgm_id )
	and   pen.prtt_enrt_rslt_stat_cd is null
	and   pen.business_group_id = p_business_group_id
	and   pen.enrt_cvg_thru_dt >= pen.effective_end_date
	and   (p_report_start_date between pen.enrt_cvg_strt_dt  and pen.enrt_cvg_thru_dt
       	      or p_report_end_date between pen.enrt_cvg_strt_dt and pen.enrt_cvg_thru_dt
       	      or (p_report_start_date >= pen.enrt_cvg_strt_dt and p_report_end_date <= pen.enrt_cvg_thru_dt)
       	      or (p_report_start_date <= pen.enrt_cvg_strt_dt and p_report_end_date >= pen.enrt_cvg_thru_dt))
       	and   pen.sspndd_flag = 'N'
	and   (p_person_id is null or pen.person_id = p_person_id)
	and   (p_per_sel_rule is null or pen.person_id in (select person_id
	                                                    from ben_person_actions pac
	                                                    where pac.benefit_action_id = p_benefit_action_id) )
	and   pil.per_in_ler_id = pen.per_in_ler_id
	and   pil.per_in_ler_stat_cd not in ( 'VOIDD' , 'BCKDT')
	and   per.person_id = pil.person_id
	and   (p_ntl_identifier is null or per.national_identifier = p_ntl_identifier)
	and   p_run_date between per.effective_start_date and per.effective_end_date
	and   ptp.person_type_id = per.person_type_id
	and   ptp.system_person_type in ( 'EMP' , 'EX_EMP' , 'EX_EMP_APL' , 'EMP_APL' , 'PRTN' )
	and   asg.person_id = pen.person_id
	and   asg.business_group_id = p_business_group_id
/*	and   asg.assignment_type = 'E' */
	and   asg.primary_flag = 'Y'
	and   p_run_date between asg.effective_start_date and asg.effective_end_date
	and   prm.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
	and   prm.per_in_ler_id  = pen.per_in_ler_id
	and   apr.actl_prem_id = prm.actl_prem_id
	and   prm.prtt_prem_id = popl.prtt_prem_id
	and   popl.yr_num||lpad(popl.mo_num,2,0) between to_number(to_char(p_report_start_date,'YYYYMM'))
	      and   to_number(to_char(p_report_end_date,'YYYYMM'))
	and   apr.business_group_id = p_business_group_id
	and   (p_prem_type is null or apr.prsptv_r_rtsptv_cd = p_prem_type )
	and   p_run_date between apr.effective_start_date and apr.effective_end_date
	and   popl.business_group_id = p_business_group_id
	and   p_run_date between prm.effective_start_date and prm.effective_end_date
	and   ( ( apr.oipl_id is null and apr.pl_id = p_pl_id )
	       or ( apr.pl_id is null
	            and apr.oipl_id in ( select oipl_id from ben_oipl_f oipl
	                                 where  oipl.pl_id = p_pl_id
	 	 	                 and    oipl.business_group_id = p_business_group_id
	                                 and    p_run_date between oipl.effective_start_date and oipl.effective_end_date )))
        and   (p_payroll_id is null or asg.payroll_id = p_payroll_id )
	and   (p_organization_id is null
	       or asg.organization_id = p_organization_id )
	and   (p_location_id is null
	       or asg.location_id = p_location_id)
	and   (p_benfts_grp_id is null
	       or per.benefit_group_id = p_benfts_grp_id)
	and   (p_rptg_grp_id is null
	       or exists (select null
	                  from   ben_popl_rptg_grp_f   prpg
			  where  (pen.pl_id = prpg.pl_id
			  or     pen.pgm_id = prpg.pgm_id )
			  and    prpg.rptg_grp_id = p_rptg_grp_id))
	order by  1,2,3,4,5;
	--
	l_grp_header_pos 	number := 5;
	l_rec_pointer 		number := 0;
	l_report 		ben_recn_rep.g_report_array := ben_recn_rep.g_report_array(); -- Plan Reconciliation Report Array
	l_disc_report 		ben_recn_rep.g_report_array := ben_recn_rep.g_report_array(); -- Plan Discrepency Report Array
	l_disc_rec_pointer 	number := 0;
	l_person_id 		varchar2(200) := -1;
	l_total_record		g_report_cols_rec;
	l_subtotal_record	g_report_cols_rec;
	l_prtt_count		number := 0;
	l_level 		varchar2(10);
	l_uom			varchar2(30);
	l_format_mask   	varchar2(100);
	l_pgm_name 		ben_pgm_f.name%type;
	l_pl_name 		varchar2(1000);
	l_date 			varchar2(50);
	l_plan_recn_rep_header 	varchar2(2000);
	l_plan_disc_rep_header 	varchar2(2000);
	l_plan_prtt_rep_header 	varchar2(2000);
	l_lfe_rep_header       	varchar2(2000);
	--
  	l_person		per_all_people_f.full_name%type;
 	l_emp_name_format	varchar2(80);
  	l_pgm			ben_pgm_f.name%type;
  	l_pl			ben_pl_f.name%type;
  	l_per_sel_rule	ff_formulas_f.formula_name%type;
  	l_business_group	varchar2(250);
  	l_organization	varchar2(250);
  	l_location		varchar2(250);
  	l_benfts_grp		varchar2(250);
  	l_rptg_grp		varchar2(250);
  	l_prem_type		varchar2(80);
  	l_payroll		varchar2(250);
  	l_output_typ		varchar2(80);
  	l_dsply_pl_disc_rep	varchar2(80);
  	l_dsply_pl_recn_rep	varchar2(80);
  	l_dsply_pl_prtt_rep	varchar2(80);
  	l_dsply_prtt_reps  	varchar2(80);
  	l_dsply_lfe_rep    	varchar2(80);
begin

   -- Report Headers
   if p_pgm_id is not null then
        l_pgm_name :=  ben_batch_utils.get_pgm_name(p_pgm_id, p_business_group_id,p_run_date);
   end if;
   --
   l_pl_name :=  ben_batch_utils.get_pl_name(p_pl_id,p_business_group_id,p_run_date);
   l_date := ' ' || to_char(p_report_start_date,'DD Month YYYY')
   	   || ' - ' || to_char(p_report_end_date,'DD Month YYYY');
   l_plan_recn_rep_header :=  l_pl_name ||' Reconciliations for'|| l_date;
   l_plan_disc_rep_header :=  l_pl_name ||' Discrepancies for'|| l_date;
   l_plan_prtt_rep_header :=  l_pl_name ||' Plan Participant Details for'|| l_date;
   l_lfe_rep_header :=  'Life Events Affecting Premiums for'|| l_date;
   --

   -- csv file name
   p_op_file_name  := to_char(p_conc_request_id)||'.csv';
   --

   --------------------  Report Parameters  ----------------------
   l_report.extend(29);
   l_report(2).col2  := 'ORACLE ADVANCED BENEFITS';
   l_report(4).col2  := 'Reconciliation of Premium Contributions to Element Entries Report';
   l_report(5).col1  := 'Execution ID '|| p_conc_request_id;
   l_report(5).col3  := 'Start Date '|| trunc(sysdate);
   --

   l_report(7).col1 := 'Reporting Start Date';
   l_report(8).col1 := 'Reporting End Date';
   l_report(9).col1  := 'Employee Name';
   l_report(10).col1  := 'National Identifier';
   l_report(11).col1  := 'Employee Name Format';
   l_report(12).col1 := 'Program';
   l_report(13).col1 := 'Plan';
   l_report(14).col1 := 'Person Selection Rule';
   l_report(15).col1 := 'Organization';
   l_report(16).col1 := 'Location';
   l_report(17).col1 := 'Benefits Group';
   l_report(18).col1 := 'Reporting Group';
   l_report(19).col1 := 'Premium Type';
   l_report(20).col1 := 'Payroll';
   l_report(21).col1 := 'Output Type';
   l_report(22).col1 := 'Display Plan Reconciliation Report';
   l_report(23).col1 := 'Display Plan Discrepancy Report';
   l_report(24).col1 := 'Display Life Event Report';
   l_report(25).col1 := 'Display Plan Plan Participant Details Report';
   l_report(26).col1 := 'Display Participant Details Report';
   --
   ben_recn_rep.report_header
     (p_run_date	     => p_run_date
    ,p_person_id	     => p_person_id
    ,p_emp_name_format	     => p_emp_name_format
    ,p_pgm_id		     => p_pgm_id
    ,p_pl_id		     => p_pl_id
    ,p_per_sel_rule_id	     => p_per_sel_rule
    ,p_business_group_id     => p_business_group_id
    ,p_organization_id	     => p_organization_id
    ,p_location_id	     => p_location_id
    ,p_benfts_grp_id	     => p_benfts_grp_id
    ,p_rptg_grp_id	     => p_rptg_grp_id
    ,p_prem_type	     => p_prem_type
    ,p_payroll_id	     => p_payroll_id
    ,p_output_typ	     => p_output_typ
    ,p_dsply_pl_disc_rep     => p_dsply_pl_disc_rep
    ,p_dsply_pl_recn_rep     => p_dsply_pl_recn_rep
    ,p_dsply_pl_prtt_rep     => p_dsply_pl_prtt_rep
    ,p_dsply_prtt_reps       => p_dsply_prtt_reps
    ,p_dsply_lfe_rep         => p_dsply_lfe_rep
    ,p_ret_person	     => l_person
    ,p_ret_emp_name_format   => l_emp_name_format
    ,p_ret_pgm		     => l_pgm
    ,p_ret_pl		     => l_pl
    ,p_ret_per_sel_rule	     => l_per_sel_rule
    ,p_ret_business_group    => l_business_group
    ,p_ret_organization	     => l_organization
    ,p_ret_location	     => l_location
    ,p_ret_benfts_grp	     => l_benfts_grp
    ,p_ret_rptg_grp	     => l_rptg_grp
    ,p_ret_prem_type	     => l_prem_type
    ,p_ret_payroll	     => l_payroll
    ,p_ret_output_typ	     => l_output_typ
    ,p_ret_dsply_pl_disc_rep => l_dsply_pl_disc_rep
    ,p_ret_dsply_pl_recn_rep => l_dsply_pl_recn_rep
    ,p_ret_dsply_pl_prtt_rep => l_dsply_pl_prtt_rep
    ,p_ret_dsply_prtt_reps   => l_dsply_prtt_reps
    ,p_ret_dsply_lfe_rep     => l_dsply_lfe_rep  );
   --
   l_report(7).col2   :=  p_rep_st_dt;
   l_report(8).col2   :=  p_rep_end_dt;
   l_report(9).col2   :=  l_person;
   l_report(10).col2   :=  nvl(p_ntl_identifier,'All');
   l_report(11).col2  :=  l_emp_name_format;
   l_report(12).col2  :=  l_pgm;
   l_report(13).col2  :=  l_pl;
   l_report(14).col2  :=  l_per_sel_rule;
   l_report(15).col2  :=  l_organization;
   l_report(16).col2  :=  l_location;
   l_report(17).col2  :=  l_benfts_grp;
   l_report(18).col2  :=  l_rptg_grp;
   l_report(19).col2  :=  l_prem_type;
   l_report(20).col2  :=  l_payroll;
   l_report(21).col2  :=  l_output_typ;
   l_report(22).col2  :=  l_dsply_pl_recn_rep;
   l_report(23).col2  :=  l_dsply_pl_disc_rep;
   l_report(24).col2  :=  l_dsply_lfe_rep;
   l_report(25).col2  :=  l_dsply_pl_prtt_rep;
   l_report(26).col2  :=  l_dsply_prtt_reps;

   --
   l_report.extend;
   print_report(p_log_file_name => p_op_file_name,
   		p_report_array => l_report,
   		p_close_file => FALSE);
   --


   l_report.delete;
   l_rec_pointer := 0;
   ---------------------Plan Reconciliation Section---------------
   if p_dsply_recn = 'Y' then
	   l_report.extend(l_grp_header_pos);
   	   l_report(2).col1 := l_pgm_name;
   	   l_report(3).col1 := l_plan_recn_rep_header;
	   --
	   l_report(l_grp_header_pos).col1 := 'Participant';
	   l_report(l_grp_header_pos).col2 := 'National Id';
	   l_report(l_grp_header_pos).col3 := 'Payroll';
	   l_report(l_grp_header_pos).col4 := 'Coverage';
	   l_report(l_grp_header_pos).col5 := 'Participant Monthly Premium';
	   l_report(l_grp_header_pos).col6 := 'Payroll Frequency';
	   l_report(l_grp_header_pos).col7 := 'Standard Rate Amounts Employee Pre-Tax Contribution';
	   l_report(l_grp_header_pos).col8 := 'Standard Rate Amounts Employee Post-Tax Contribution';
	   l_report(l_grp_header_pos).col9 := 'Standard Rate Amounts Employer Contribution';
	   l_report(l_grp_header_pos).col10 := 'Standard Rate Amounts Pay Period Total';
	   l_report(l_grp_header_pos).col11 := 'Element Entry(per pay period) Employee Pre-Tax Contribution';
	   l_report(l_grp_header_pos).col12 := 'Element Entry(per pay period) Employee Post-Tax Contribution';
	   l_report(l_grp_header_pos).col13 := 'Element Entry(per pay period) Employer Contribtion';
	   l_report(l_grp_header_pos).col14 := 'Element Entry(per pay period) Actual Total Contributions';
	   l_report(l_grp_header_pos).col15 := 'Discrepancy';
	   --
	   l_rec_pointer := l_grp_header_pos ;
	   for l_plan_recn in c_plan_recn loop
	   	if l_uom is null then
	   	   l_uom := l_plan_recn.pl_uom ;
	   	end if;
	   	--
	   	l_prtt_count := c_plan_recn%rowcount;
	   	l_report.extend;
	   	l_rec_pointer := l_rec_pointer + 1;


		l_report(l_rec_pointer).col1  := l_plan_recn.pl_per_name ; 		-- 'Participant'
		l_report(l_rec_pointer).col2  := l_plan_recn.pl_ntnl_id ; 		-- 'National Id'
		l_report(l_rec_pointer).col3  := l_plan_recn.pl_pay_name ; 		-- 'Payroll'
		l_report(l_rec_pointer).col4  := l_plan_recn.pl_bnft_amt ; 		-- 'Coverage'
		l_report(l_rec_pointer).col5  := l_plan_recn.pl_prem_val ; 		-- 'Participant Monthly Premium'
		l_report(l_rec_pointer).col6  := l_plan_recn.pl_perd_typ ; 		-- 'Payroll Frequency'
		l_report(l_rec_pointer).col7  := l_plan_recn.ee_ptax_rt_val_tot ; 	-- 'Standard Rate Amounts Employee Pre-Tax Contribution'
		l_report(l_rec_pointer).col8  := l_plan_recn.ee_atax_rt_val_tot ; 	-- 'Standard Rate Amounts Employee Post-Tax Contribution'
		l_report(l_rec_pointer).col9  := l_plan_recn.er_rt_val_tot ; 		-- 'Standard Rate Amounts Employer Contribution'
		l_report(l_rec_pointer).col10 := l_plan_recn.pay_perd_total ; 		-- 'Standard Rate Amounts Pay Period Total'
		l_report(l_rec_pointer).col11 := l_plan_recn.ee_ptax_elem_val_tot ; 	-- 'Element Entry(per pay period) Employee Pre-Tax Contribution'
		l_report(l_rec_pointer).col12 := l_plan_recn.ee_atax_elem_val_tot ; 	-- 'Element Entry(per pay period) Employee Post-Tax Contribution'
		l_report(l_rec_pointer).col13 := l_plan_recn.er_elem_val_tot; 		-- 'Element Entry(per pay period) Employer Contribtion'
		l_report(l_rec_pointer).col14 := l_plan_recn.actual_total ; 		-- 'Element Entry(per pay period) Actual Total Contributions'

		-- discrepency
		if l_report(l_rec_pointer).col10 <> l_report(l_rec_pointer).col14 and
	        	l_report(l_rec_pointer).col14 <> l_report(l_rec_pointer).col5 then
		   	l_report(l_rec_pointer).col15 := 'Standard Rate and Premium';
	   	elsif l_report(l_rec_pointer).col10 <> l_report(l_rec_pointer).col14 then
		   	l_report(l_rec_pointer).col15 := 'Standard Rate';
	   	elsif l_report(l_rec_pointer).col14 <> l_report(l_rec_pointer).col5 then
		   	l_report(l_rec_pointer).col15 := 'Premium';
	   	end if;
	   	--
		l_total_record.col1  := 'Total:'; 	-- 'Total'
		l_total_record.col5  := nvl(l_total_record.col5 ,0) + nvl(l_plan_recn.pl_prem_val,0) ; 		-- 'Participant Monthly Premium'
		l_total_record.col7  := nvl(l_total_record.col7 ,0) + nvl(l_plan_recn.ee_ptax_rt_val_tot,0) ; 	-- 'Standard Rate Amounts Employee Pre-Tax Contribution'
		l_total_record.col8  := nvl(l_total_record.col8 ,0) + nvl(l_plan_recn.ee_atax_rt_val_tot,0) ; 	-- 'Standard Rate Amounts Employee Post-Tax Contribution'
		l_total_record.col9  := nvl(l_total_record.col9 ,0) + nvl(l_plan_recn.er_rt_val_tot,0) ; 	-- 'Standard Rate Amounts Employer Contribution'
		l_total_record.col10 := nvl(l_total_record.col10,0) + nvl(l_plan_recn.pay_perd_total,0) ; 	-- 'Standard Rate Amounts Pay Period Total'
		l_total_record.col11 := nvl(l_total_record.col11,0) + nvl(l_plan_recn.ee_ptax_elem_val_tot,0) ; -- 'Element Entry(per pay period) Employee Pre-Tax Contribution'
		l_total_record.col12 := nvl(l_total_record.col12,0) + nvl(l_plan_recn.ee_atax_elem_val_tot,0) ; -- 'Element Entry(per pay period) Employee Post-Tax Contribution'
		l_total_record.col13 := nvl(l_total_record.col13,0) + nvl(l_plan_recn.er_elem_val_tot,0); 	-- 'Element Entry(per pay period) Employer Contribtion'
		l_total_record.col14 := nvl(l_total_record.col14,0) + nvl(l_plan_recn.actual_total,0) ; 	-- 'Element Entry(per pay period) Actual Total Contribu


	   end loop;
	   if l_grp_header_pos <> l_rec_pointer then
	   	 l_report.extend;
	   	 l_rec_pointer := l_rec_pointer + 1;
	   	 l_report(l_rec_pointer) := l_total_record;
	   end if;
	   --
	   l_report.extend;
   	   l_rec_pointer := l_rec_pointer + 1;
   	   l_report(l_rec_pointer).col1 := 'Participant Count:' || l_prtt_count;
   	   --
   	   if l_prtt_count = 0  then
   	   	l_report(l_grp_header_pos) := null;
   	   end if;
   	   --
	   l_format_mask := fnd_currency.get_format_mask(l_uom, 30);
	   if l_format_mask is not null then
	      for l_loop_count in (l_grp_header_pos + 1)..l_report.last loop
		l_report(l_loop_count).col4  := to_char(to_number(l_report(l_loop_count).col4 ) ,l_format_mask); -- 'Coverage'
		l_report(l_loop_count).col5  := to_char(to_number(l_report(l_loop_count).col5 ) ,l_format_mask); -- 'Participant Monthly Premium'
		l_report(l_loop_count).col7  := to_char(to_number(l_report(l_loop_count).col7 ) ,l_format_mask); -- 'Standard Rate Amounts Employee Pre-Tax Contribution'
		l_report(l_loop_count).col8  := to_char(to_number(l_report(l_loop_count).col8 ) ,l_format_mask); -- 'Standard Rate Amounts Employee Post-Tax Contribution'
		l_report(l_loop_count).col9  := to_char(to_number(l_report(l_loop_count).col9 ) ,l_format_mask); -- 'Standard Rate Amounts Employer Contribution'
		l_report(l_loop_count).col10 := to_char(to_number(l_report(l_loop_count).col10) ,l_format_mask); -- 'Standard Rate Amounts Pay Period Total'
		l_report(l_loop_count).col11 := to_char(to_number(l_report(l_loop_count).col11) ,l_format_mask); -- 'Element Entry(per pay period) Employee Pre-Tax Contribution'
		l_report(l_loop_count).col12 := to_char(to_number(l_report(l_loop_count).col12) ,l_format_mask); -- 'Element Entry(per pay period) Employee Post-Tax Contribution'
		l_report(l_loop_count).col13 := to_char(to_number(l_report(l_loop_count).col13) ,l_format_mask); -- 'Element Entry(per pay period) Employer Contribtion'
		l_report(l_loop_count).col14 := to_char(to_number(l_report(l_loop_count).col14) ,l_format_mask); -- 'Element Entry(per pay period) Actual Total Contributions'
	      end loop;
	      --
	   end if;
   	   --
   	   l_report.extend;
      	   print_report(p_log_file_name => p_op_file_name,
	    		p_report_array => l_report,
   			p_close_file => FALSE);
	   --
   end if;
   --

   l_report.delete;
   l_rec_pointer := 0;
   l_prtt_count := 0;
   l_total_record := null;

   if p_dsply_disc = 'Y' then
	   l_disc_report.extend(l_grp_header_pos);
	   l_disc_report(2).col1 := l_pgm_name;
	   l_disc_report(3).col1 := l_plan_disc_rep_header;
	   l_disc_report(l_grp_header_pos).col1 := 'Participant';
	   l_disc_report(l_grp_header_pos).col2 := 'National Id';
	   l_disc_report(l_grp_header_pos).col3 := 'Payroll';
	   l_disc_report(l_grp_header_pos).col4 := 'Coverage';
	   l_disc_report(l_grp_header_pos).col5 := 'Participant Monthly Premium';
	   l_disc_report(l_grp_header_pos).col6 := 'Pay Period';
	   l_disc_report(l_grp_header_pos).col7 := 'Standard Rate Amounts Employee Pre-Tax Contribution';
	   l_disc_report(l_grp_header_pos).col8 := 'Standard Rate Amounts Employee Post-Tax Contribution';
	   l_disc_report(l_grp_header_pos).col9 := 'Standard Rate Amounts Employer Contribution';
	   l_disc_report(l_grp_header_pos).col10 := 'Standard Rate Amounts Pay Period Total';
	   l_disc_report(l_grp_header_pos).col11 := 'Element Entry(per pay period) Employee Pre-Tax Contribution';
	   l_disc_report(l_grp_header_pos).col12 := 'Element Entry(per pay period) Employee Post-Tax Contribution';
	   l_disc_report(l_grp_header_pos).col13 := 'Element Entry(per pay period) Employer Contribtion';
	   l_disc_report(l_grp_header_pos).col14 := 'Element Entry(per pay period) Actual Total Contributions';
	   l_disc_report(l_grp_header_pos).col15 := 'Premium Discrepancy';
	   l_disc_report(l_grp_header_pos).col16 := 'Standard Rate Discrepancy';

	   l_disc_rec_pointer := l_grp_header_pos;

	   for l_plan_recn in c_plan_disc loop
		--
		if l_uom is null then
		   l_uom := l_plan_recn.pl_sql_uom;
	        end if;
		--
		if l_plan_recn.pl_person_id||l_plan_recn.pl_bnft_amount||l_plan_recn.pl_prem_val <> l_person_id then
		   l_person_id := l_plan_recn.pl_person_id||l_plan_recn.pl_bnft_amount||l_plan_recn.pl_prem_val ;
		   l_prtt_count := l_prtt_count + 1;
		   if l_disc_rec_pointer <> l_grp_header_pos then
			   -- Fill the Subtotals for the previous person
			   l_disc_report.extend(1);
			   l_disc_rec_pointer := l_disc_rec_pointer + 1;

			   l_disc_report(l_disc_rec_pointer) := l_subtotal_record;

			   -- Report Total
			   l_total_record.col1 := 'Total:';
			   l_total_record.col7  := nvl(l_total_record.col7,0)  + l_subtotal_record.col7 ; -- 'Standard Rate Amounts Employee Pre-Tax Contribution'
			   l_total_record.col8  := nvl(l_total_record.col8,0)  + l_subtotal_record.col8 ; -- 'Standard Rate Amounts Employee Post-Tax Contribution'
			   l_total_record.col9  := nvl(l_total_record.col9,0)  + l_subtotal_record.col9 ; -- 'Standard Rate Amounts Employer Contribution'
			   l_total_record.col10 := nvl(l_total_record.col10,0) + l_subtotal_record.col10; -- 'Standard Rate Amounts Pay Period Total'
			   l_total_record.col11 := nvl(l_total_record.col11,0) + l_subtotal_record.col11; -- 'Element Entry(per pay period) Employee Pre-Tax Contribution'
			   l_total_record.col12 := nvl(l_total_record.col12,0) + l_subtotal_record.col12; -- 'Element Entry(per pay period) Employee Post-Tax Contribution'
			   l_total_record.col13 := nvl(l_total_record.col13,0) + l_subtotal_record.col13; -- 'Element Entry(per pay period) Employer Contribtion'
			   l_total_record.col14 := nvl(l_total_record.col14,0) + l_subtotal_record.col14; -- 'Element Entry(per pay period) Actual Total Contributions'
			   l_total_record.col15 := nvl(l_total_record.col15,0) + l_subtotal_record.col15; -- 'Premium Discrepency'
			   l_total_record.col16 := nvl(l_total_record.col16,0) + l_subtotal_record.col16; -- 'Standard Rate Discrepancy'

			   l_subtotal_record := null;
			   --
			   --
		   end if;
		   --
		   l_subtotal_record.col7  := l_plan_recn.ee_ptax_rt_val ; -- 'Standard Rate Amounts Employee Pre-Tax Contribution'
		   l_subtotal_record.col8  := l_plan_recn.ee_atax_rt_val ; -- 'Standard Rate Amounts Employee Post-Tax Contribution'
		   l_subtotal_record.col9  := l_plan_recn.er_rt_val ; 	-- 'Standard Rate Amounts Employer Contribution'
		   l_subtotal_record.col10 := l_plan_recn.pay_perd_total ; -- 'Standard Rate Amounts Pay Period Total'
		   l_subtotal_record.col11 := l_plan_recn.ee_ptax_elem_val;-- 'Element Entry(per pay period) Employee Pre-Tax Contribution'
		   l_subtotal_record.col12 := l_plan_recn.ee_atax_elem_val;-- 'Element Entry(per pay period) Employee Post-Tax Contribution'
		   l_subtotal_record.col13 := l_plan_recn.er_elem_val; 	-- 'Element Entry(per pay period) Employer Contribtion'
		   l_subtotal_record.col14 := l_plan_recn.actual_total ; 	-- 'Element Entry(per pay period) Actual Total Contributions'
		   l_subtotal_record.col15 := l_plan_recn.prem_dis;     	-- 'Premium Discrepency'
		   l_subtotal_record.col16 := l_plan_recn.std_rt_dis;      -- 'Standard Rate Discrepancy'

		   l_disc_report.extend(1);
		   l_disc_rec_pointer := l_disc_rec_pointer + 1;

		   l_disc_report(l_disc_rec_pointer).col1  := l_plan_recn.pl_full_name ; 	-- 'Participant'
		   l_disc_report(l_disc_rec_pointer).col2  := l_plan_recn.pl_national_id ; -- 'National Id'
		   l_disc_report(l_disc_rec_pointer).col3  := l_plan_recn.pl_payroll_name; -- 'Payroll'
		   l_disc_report(l_disc_rec_pointer).col4  := l_plan_recn.pl_bnft_amount ; -- 'Coverage'
		   l_disc_report(l_disc_rec_pointer).col5  := l_plan_recn.pl_prem_val ; 	-- 'Participant Monthly Premium'
		   l_disc_report(l_disc_rec_pointer).col6  := l_plan_recn.pl_pay_prd ;     -- 'Payroll Period'
		   l_disc_report(l_disc_rec_pointer).col7  := l_plan_recn.ee_ptax_rt_val ; -- 'Standard Rate Amounts Employee Pre-Tax Contribution'
		   l_disc_report(l_disc_rec_pointer).col8  := l_plan_recn.ee_atax_rt_val ; -- 'Standard Rate Amounts Employee Post-Tax Contribution'
		   l_disc_report(l_disc_rec_pointer).col9  := l_plan_recn.er_rt_val ; 	-- 'Standard Rate Amounts Employer Contribution'
		   l_disc_report(l_disc_rec_pointer).col10 := l_plan_recn.pay_perd_total ; -- 'Standard Rate Amounts Pay Period Total'
		   l_disc_report(l_disc_rec_pointer).col11 := l_plan_recn.ee_ptax_elem_val;-- 'Element Entry(per pay period) Employee Pre-Tax Contribution'
		   l_disc_report(l_disc_rec_pointer).col12 := l_plan_recn.ee_atax_elem_val;-- 'Element Entry(per pay period) Employee Post-Tax Contribution'
		   l_disc_report(l_disc_rec_pointer).col13 := l_plan_recn.er_elem_val; 	-- 'Element Entry(per pay period) Employer Contribtion'
		   l_disc_report(l_disc_rec_pointer).col14 := l_plan_recn.actual_total ; 	-- 'Element Entry(per pay period) Actual Total Contributions'
		   l_disc_report(l_disc_rec_pointer).col15 := l_plan_recn.prem_dis;     	-- 'Premium Discrepency'
		   l_disc_report(l_disc_rec_pointer).col16 := l_plan_recn.std_rt_dis;      -- 'Standard Rate Discrepancy'
		else
		   l_subtotal_record.col7  := l_subtotal_record.col7  + l_plan_recn.ee_ptax_rt_val; 	-- 'Standard Rate Amounts Employee Pre-Tax Contribution'
		   l_subtotal_record.col8  := l_subtotal_record.col8  + l_plan_recn.ee_atax_rt_val; 	-- 'Standard Rate Amounts Employee Post-tax Contribution'
		   l_subtotal_record.col9  := l_subtotal_record.col9  + l_plan_recn.er_rt_val; 	-- 'Standard Rate Amounts Employer Contribution'
		   l_subtotal_record.col10 := l_subtotal_record.col10 + l_plan_recn.pay_perd_total; 	-- 'Standard Rate Amounts Pay Period Total'
		   l_subtotal_record.col11 := l_subtotal_record.col11 + l_plan_recn.ee_ptax_elem_val;  -- 'Element Entry(per pay period) Employee Pre-Tax Contribution'
		   l_subtotal_record.col12 := l_subtotal_record.col12 + l_plan_recn.ee_atax_elem_val;  -- 'Element Entry(per pay period) Employee Post-Tax Contribution'
		   l_subtotal_record.col13 := l_subtotal_record.col13 + l_plan_recn.er_elem_val; 	-- 'Element Entry(per pay period) Employer Contribtion'
		   l_subtotal_record.col14 := l_subtotal_record.col14 + l_plan_recn.actual_total; 	-- 'Element Entry(per pay period) Actual Total Contributions'
		   l_subtotal_record.col15 := l_subtotal_record.col15 + l_plan_recn.prem_dis ;    	-- 'Premium Discrepency'
		   l_subtotal_record.col16 := l_subtotal_record.col16 + l_plan_recn.std_rt_dis;        -- 'Standard Rate Discrepancy'
		   --
		   l_disc_report.extend(1);
		   l_disc_rec_pointer := l_disc_rec_pointer + 1;
		   l_disc_report(l_disc_rec_pointer).col6  := l_plan_recn.pl_pay_prd ;     -- 'Payroll Period'
		   l_disc_report(l_disc_rec_pointer).col7  := l_plan_recn.ee_ptax_rt_val ; -- 'Standard Rate Amounts Employee Pre-Tax Contribution'
		   l_disc_report(l_disc_rec_pointer).col8  := l_plan_recn.ee_atax_rt_val ; -- 'Standard Rate Amounts Employee Post-Tax Contribution'
		   l_disc_report(l_disc_rec_pointer).col9  := l_plan_recn.er_rt_val ; 	-- 'Standard Rate Amounts Employer Contribution'
		   l_disc_report(l_disc_rec_pointer).col10 := l_plan_recn.pay_perd_total ; -- 'Standard Rate Amounts Pay Period Total'
		   l_disc_report(l_disc_rec_pointer).col11 := l_plan_recn.ee_ptax_elem_val;-- 'Element Entry(per pay period) Employee Pre-Tax Contribution'
		   l_disc_report(l_disc_rec_pointer).col12 := l_plan_recn.ee_atax_elem_val;-- 'Element Entry(per pay period) Employee Post-Tax Contribution'
		   l_disc_report(l_disc_rec_pointer).col13 := l_plan_recn.er_elem_val; 	-- 'Element Entry(per pay period) Employer Contribtion'
		   l_disc_report(l_disc_rec_pointer).col14 := l_plan_recn.actual_total ; 	-- 'Element Entry(per pay period) Actual Total Contributions'
		   l_disc_report(l_disc_rec_pointer).col15 := l_plan_recn.prem_dis;     	-- 'Premium Discrepency'
		   l_disc_report(l_disc_rec_pointer).col16 := l_plan_recn.std_rt_dis;      -- 'Standard Rate Discrepancy'
	        end if;
	   end loop;
	   --
	   -- subtotal for the last record
	   if l_person_id <> -1 then

		   l_disc_report.extend(1);
		   l_disc_rec_pointer := l_disc_rec_pointer + 1;

		   l_disc_report(l_disc_rec_pointer) := l_subtotal_record;
		   -- Report Total
		   l_total_record.col7  := nvl(l_total_record.col7,0)  + l_subtotal_record.col7 ; -- 'Standard Rate Amounts Employee Pre-Tax Contribution'
		   l_total_record.col8  := nvl(l_total_record.col8,0)  + l_subtotal_record.col8 ; -- 'Standard Rate Amounts Employee Post-Tax Contribution'
		   l_total_record.col9  := nvl(l_total_record.col9,0)  + l_subtotal_record.col9 ; -- 'Standard Rate Amounts Employer Contribution'
		   l_total_record.col10 := nvl(l_total_record.col10,0) + l_subtotal_record.col10; -- 'Standard Rate Amounts Pay Period Total'
		   l_total_record.col11 := nvl(l_total_record.col11,0) + l_subtotal_record.col11; -- 'Element Entry(per pay period) Employee Pre-Tax Contribution'
		   l_total_record.col12 := nvl(l_total_record.col12,0) + l_subtotal_record.col12; -- 'Element Entry(per pay period) Employee Post-Tax Contribution'
		   l_total_record.col13 := nvl(l_total_record.col13,0) + l_subtotal_record.col13; -- 'Element Entry(per pay period) Employer Contribtion'
		   l_total_record.col14 := nvl(l_total_record.col14,0) + l_subtotal_record.col14; -- 'Element Entry(per pay period) Actual Total Contributions'
		   l_total_record.col15 := nvl(l_total_record.col15,0) + l_subtotal_record.col15; -- 'Premium Discrepency'
		   l_total_record.col16 := nvl(l_total_record.col16,0) + l_subtotal_record.col16; -- 'Standard Rate Discrepancy'

		   --
		   l_disc_report.extend(1);
		   l_disc_rec_pointer := l_disc_rec_pointer + 1;
		   l_disc_report(l_disc_rec_pointer) :=  l_total_record;

		   l_disc_report.extend(1);
		   l_disc_rec_pointer := l_disc_rec_pointer + 1;
		   l_disc_report(l_disc_rec_pointer).col1 := 'Participant Count:' || l_prtt_count;
		   --
	   end if;
	   --
	   -- apply the format mask for number columns
	   l_format_mask := fnd_currency.get_format_mask(l_uom, 30);
	   if l_format_mask is not null then
	     --
	     for l_loop_count in (l_grp_header_pos + 1)..l_disc_report.last loop
		l_disc_report(l_loop_count).col4  :=  to_char(to_number(l_disc_report(l_loop_count).col4) ,l_format_mask);-- Coverage'
		l_disc_report(l_loop_count).col5  :=  to_char(to_number(l_disc_report(l_loop_count).col5) ,l_format_mask);-- Participant Monthly Premium'
		l_disc_report(l_loop_count).col7  :=  to_char(to_number(l_disc_report(l_loop_count).col7) ,l_format_mask);-- Standard Rate Amounts Employee Pre-Tax Contribution'
		l_disc_report(l_loop_count).col8  :=  to_char(to_number(l_disc_report(l_loop_count).col8) ,l_format_mask);-- Standard Rate Amounts Employee Post-Tax Contribution'
		l_disc_report(l_loop_count).col9  :=  to_char(to_number(l_disc_report(l_loop_count).col9) ,l_format_mask);-- Standard Rate Amounts Employer Contribution'
		l_disc_report(l_loop_count).col10 :=  to_char(to_number(l_disc_report(l_loop_count).col10),l_format_mask);-- Standard Rate Amounts Pay Period Total'
		l_disc_report(l_loop_count).col11 :=  to_char(to_number(l_disc_report(l_loop_count).col11),l_format_mask);-- Element Entry(per pay period) Employee Pre-Tax Contribution'
		l_disc_report(l_loop_count).col12 :=  to_char(to_number(l_disc_report(l_loop_count).col12),l_format_mask);-- Element Entry(per pay period) Employee Post-Tax Contribution'
		l_disc_report(l_loop_count).col13 :=  to_char(to_number(l_disc_report(l_loop_count).col13),l_format_mask);-- Element Entry(per pay period) Employer Contribtion'
		l_disc_report(l_loop_count).col14 :=  to_char(to_number(l_disc_report(l_loop_count).col14),l_format_mask);-- Element Entry(per pay period) Actual Total Contributions'
		l_disc_report(l_loop_count).col15 :=  to_char(to_number(l_disc_report(l_loop_count).col15),l_format_mask);-- Premium Discrepency'
		l_disc_report(l_loop_count).col16 :=  to_char(to_number(l_disc_report(l_loop_count).col16),l_format_mask);-- Standard Rate Discrepancy'
	     end loop;
	     --
	   end if;
	   --

	   --
	   if l_prtt_count = 0  then
		l_disc_report(l_grp_header_pos) := null;
	   end if;
	   --
	   l_disc_report.extend;
      	   print_report(p_log_file_name => p_op_file_name,
	    		p_report_array => l_disc_report,
   			p_close_file => FALSE);
	   --
   end if;
   --
   l_report.delete;
   l_disc_report.delete;
   l_rec_pointer := 0;
   l_disc_rec_pointer := 0;
   l_prtt_count := 0;
   l_total_record := null;
   l_subtotal_record := null;

   ---------------------Life Event Section---------------
   if p_dsply_lfe = 'Y' then
   	   l_report.extend(l_grp_header_pos);
   	   l_report(2).col1 := l_pgm_name;
   	   l_report(3).col1 := l_lfe_rep_header;
	   --
	   l_report(l_grp_header_pos).col1  := 'Participant';
	   l_report(l_grp_header_pos).col2  := 'National Id';
	   l_report(l_grp_header_pos).col3  := 'Life Event Name';
	   l_report(l_grp_header_pos).col4  := 'Date of Life Event';
	   l_report(l_grp_header_pos).col5  := 'Change Effective Date';
	   l_report(l_grp_header_pos).col6  := 'Old Monthly Premium';
	   l_report(l_grp_header_pos).col7  := 'New Monthly Premium';
	   l_report(l_grp_header_pos).col8  := 'Old Rate';
	   l_report(l_grp_header_pos).col9  := 'New Rate';
	   l_report(l_grp_header_pos).col10 := 'Total Element Entries';
           --
	   l_rec_pointer := l_grp_header_pos ;
	   for l_lf_prem in c_lf_prem loop
	        if l_uom is null then
	   	   l_uom := l_lf_prem.lf_uom;
	   	end if;
	   	--
	   	l_prtt_count := c_lf_prem%rowcount;
	   	l_report.extend;
	   	l_rec_pointer := l_rec_pointer + 1;

		l_report(l_rec_pointer).col1  := l_lf_prem.lf_full_name ; 	-- 'Participant';
		l_report(l_rec_pointer).col2  := l_lf_prem.lf_national_identifier ; 	-- 'National Id';
		l_report(l_rec_pointer).col3  := l_lf_prem.lf_ler_name ; 	-- 'Life Event Name';
		l_report(l_rec_pointer).col4  := l_lf_prem.lf_evt_ocrd_dt ; 	-- 'Date of Life Event';
		l_report(l_rec_pointer).col5  := l_lf_prem.lf_chng_eff_dt ; 	-- 'Change Effective Date';
		l_report(l_rec_pointer).col6  := l_lf_prem.lf_old_prem ; 	-- 'Old Monthly Premium';
		l_report(l_rec_pointer).col7  := l_lf_prem.lf_val ; 		-- 'New Monthly Premium';
		l_report(l_rec_pointer).col8  := l_lf_prem.lf_old_rate ; 	-- 'Old Rate';
		l_report(l_rec_pointer).col9  := l_lf_prem.lf_rate ; 		-- 'New Rate';
		l_report(l_rec_pointer).col10 := l_lf_prem.lf_elem_val ; 	-- 'Total Element Entries';
	   end loop;
	   --
	   l_report.extend;
   	   l_rec_pointer := l_rec_pointer + 1;
   	   l_report(l_rec_pointer).col1 := 'Participant Count:' || l_prtt_count;
   	   --
   	   if l_prtt_count = 0  then
   	   	l_report(l_grp_header_pos) := null;
   	   end if;
   	   --
	   l_format_mask := fnd_currency.get_format_mask(l_uom, 30);
	   if l_format_mask is not null then
	     for l_loop_count in (l_grp_header_pos + 1)..l_report.last loop
		l_report(l_loop_count).col6  :=  to_char(to_number(l_report(l_loop_count).col6 ),l_format_mask);-- 'Old Monthly Premium';
		l_report(l_loop_count).col7  :=  to_char(to_number(l_report(l_loop_count).col7 ),l_format_mask);-- 'New Monthly Premium';
		l_report(l_loop_count).col8  :=  to_char(to_number(l_report(l_loop_count).col8 ),l_format_mask);-- 'Old Rate';
		l_report(l_loop_count).col9  :=  to_char(to_number(l_report(l_loop_count).col9 ),l_format_mask);-- 'New Rate';
		l_report(l_loop_count).col10 :=  to_char(to_number(l_report(l_loop_count).col10),l_format_mask);-- 'Total Element Entries';
	     end loop;
	     --
	   end if;
	   --
	   l_report.extend;
      	   print_report(p_log_file_name => p_op_file_name,
	    		p_report_array => l_report,
   			p_close_file => FALSE);
	   --
   end if;
   --

   l_report.delete;
   l_rec_pointer := 0;
   l_prtt_count := 0;
   l_total_record := null;

   ---------------------Plan Participant Details Section---------------
   if p_dsply_pl_prtt = 'Y' then
	   l_report.extend(l_grp_header_pos);
   	   l_report(2).col1 := l_pgm_name;
   	   l_report(3).col1 := l_plan_prtt_rep_header;
	   --
	   l_report(l_grp_header_pos).col1  := 'Participant';
	   l_report(l_grp_header_pos).col2  := 'National Id';
	   l_report(l_grp_header_pos).col3  := 'Coverage Start Date';
	   l_report(l_grp_header_pos).col4  := 'Coverage End Date';
	   l_report(l_grp_header_pos).col5  := 'Option';
	   l_report(l_grp_header_pos).col6  := 'Participant Monthly Premium';
	   l_report(l_grp_header_pos).col7  := 'Defined Amount';
	   --
	   l_rec_pointer := l_grp_header_pos ;
	   for l_pl_oipl in c_pl_oipl loop
	        if l_uom is null then
	           l_uom := l_pl_oipl.uom;
	   	end if;
	   	--
	   	if l_pl_oipl.levels <> nvl(l_level,'STRANGE LEVEL') then
	   	     -- For the First record in the sub group
		     if l_grp_header_pos <> l_rec_pointer then
		        --
	   	 	if l_level = 'PL' then
	   	 		l_subtotal_record.col1 := 'Total for Plan :';
	   	 	elsif l_level = 'OIPL' then
	   	 		l_subtotal_record.col1 := 'Total for Option in Plan :';
	   	 	end if;
	   	 	--
	   	     	l_report.extend;
	   	     	l_rec_pointer := l_rec_pointer + 1;
	   	     	l_report(l_rec_pointer) := l_subtotal_record;
	   	     	l_subtotal_record := null;
	   	     end if;
	   	     --
	   	     l_total_record.col1 := 'Total:';
	   	     l_total_record.col6 := nvl(l_total_record.col6,0) + nvl(l_pl_oipl.val,0);

	   	     l_subtotal_record.col6 := l_pl_oipl.val;

	   	     l_level := l_pl_oipl.levels;
	   	else
	   	     l_subtotal_record.col6 := nvl(l_subtotal_record.col6,0) + nvl(l_pl_oipl.val,0);
	   	     l_total_record.col6 := nvl(l_total_record.col6,0) + nvl(l_pl_oipl.val,0);
		end if;
		--
	   	l_prtt_count := c_pl_oipl%rowcount;
	   	l_report.extend;
	   	l_rec_pointer := l_rec_pointer + 1;

	   	l_report(l_rec_pointer).col1  := l_pl_oipl.full_name ; 	        -- 'Participant';
	   	l_report(l_rec_pointer).col2  := l_pl_oipl.national_identifier ;-- 'National Id';
	   	l_report(l_rec_pointer).col3  := l_pl_oipl.enrt_cvg_strt_dt ; 	-- 'Coverage Start Date';
	   	l_report(l_rec_pointer).col4  := l_pl_oipl.enrt_cvg_thru_dt ; 	-- 'Coverage End Date';
	   	l_report(l_rec_pointer).col5  := l_pl_oipl.option_name ; 	-- 'Option';
	   	l_report(l_rec_pointer).col6  := l_pl_oipl.val ; 		-- 'Participant Monthly Premium';
	   	l_report(l_rec_pointer).col7  := l_pl_oipl.rate; 		-- 'Defined Amount';
		--
	   end loop;
	   --
	   if l_grp_header_pos <> l_rec_pointer then
	   	 l_report.extend;
	   	 l_rec_pointer := l_rec_pointer + 1;
	   	 if l_level = 'PL' then
	   	 	l_subtotal_record.col1 := 'Total for Plan :';
	   	 elsif l_level = 'OIPL' then
	   	 	l_subtotal_record.col1 := 'Total for Option in Plan :';
	   	 end if;

	   	 l_report(l_rec_pointer) := l_subtotal_record;

	   	 l_report.extend;
	   	 l_rec_pointer := l_rec_pointer + 1;
	   	 l_report(l_rec_pointer) := l_total_record;
	   end if;
	   --
	   l_report.extend;
   	   l_rec_pointer := l_rec_pointer + 1;
   	   l_report(l_rec_pointer).col1 := 'Participant Count:' || l_prtt_count;
   	   --
   	   if l_prtt_count = 0  then
   	   	l_report(l_grp_header_pos) := null;
   	   end if;
   	   --
	   l_format_mask := fnd_currency.get_format_mask(l_uom, 30);
	   if l_format_mask is not null then
	      for l_loop_count in (l_grp_header_pos + 1)..l_report.last loop
		l_report(l_loop_count).col6  :=  to_char(to_number(l_report(l_loop_count).col6) ,l_format_mask);-- 'Participant Monthly Premium';
		l_report(l_loop_count).col7  :=  to_char(to_number(l_report(l_loop_count).col7) ,l_format_mask);-- 'Defined Amount';
	      end loop;
	      --
	   end if;
   	   --
   	   l_report.extend;
      	   print_report(p_log_file_name => p_op_file_name,
	    		p_report_array => l_report,
   			p_close_file => TRUE);
	   --
   end if;
   --
   if g_log_file_name is not null then
       	close_log_file;
   end if;
   --
   if p_op_file_name is null then
   p_op_file_name := 'no output';
   end if;
/*
exception
when others then
raise;
*/
end recon_report;

--
-- ============================================================================
--                     << exec_per_selection_rule >>
-- This procedure creates a person action for people who pass the person
-- selection rule and returns the benefit action item (for a set).
-- ============================================================================
--
procedure exec_per_selection_rule
(p_pl_id	    	number,
p_pgm_id		number,
p_business_group_id	number,
p_run_date		date,
p_report_start_date	date,
p_prem_type		varchar2,
p_payroll_id		number,
p_organization_id	number,
p_location_id		number,
p_benfts_grp_id		number,
p_rptg_grp_id		number,
p_person_selection_rule_id number,
p_benefit_action_id	out nocopy number
) as
--
cursor c_person is
select distinct per.person_id, pil.ler_id
from  ben_prtt_enrt_rslt_f pen
     ,ben_actl_prem_f acp
     ,ben_prtt_prem_f prm
     ,ben_prtt_prem_by_mo_f mpr
     ,ben_per_in_ler pil
     ,per_all_people_f per
     ,per_all_assignments_f asg
where pen.pl_id = p_pl_id
and   (p_pgm_id is null or pen.pgm_id = p_pgm_id)
and   pen.prtt_enrt_rslt_stat_cd is null
and   pen.business_group_id = p_business_group_id
and   pen.enrt_cvg_thru_dt <= pen.effective_end_date
and   p_run_date between pen.enrt_cvg_strt_dt and enrt_cvg_thru_dt
and   pen.sspndd_flag = 'N'
and   pen.per_in_ler_id = pil.per_in_ler_id
and   pil.per_in_ler_stat_cd not in ( 'VOIDD' , 'BCKDT')
and   pil.person_id = per.person_id
and   pen.prtt_enrt_rslt_id = prm.prtt_enrt_rslt_id (+)
and   mpr.prtt_prem_id(+) = prm.prtt_prem_id
and   mpr.yr_num(+) = to_number(to_char(p_report_start_date,'YYYY'))
and   mpr.mo_num(+) = to_number(to_char(p_report_start_date,'MM'))
and   prm.per_in_ler_id (+) = pen.per_in_ler_id
and   acp.actl_prem_id (+) = prm.actl_prem_id
and   (p_prem_type is null or acp.prsptv_r_rtsptv_cd = p_prem_type )
and   pen.person_id = asg.person_id
and   pen.business_group_id = p_business_group_id
and   asg.business_group_id = p_business_group_id
/* and   asg.assignment_type = 'E' */
and   asg.primary_flag = 'Y'
and   (p_payroll_id is null or asg.payroll_id = p_payroll_id )
and   per.business_group_id = p_business_group_id
and   p_run_date between per.effective_start_date and per.effective_end_date
and   p_run_date between asg.effective_start_date and asg.effective_end_date
and   p_run_date between acp.effective_start_date (+) and acp.effective_end_date (+)
and   p_run_date >= prm.effective_start_date (+)
and   p_run_date <= prm.effective_end_date (+)
and   (p_organization_id is null
       or asg.organization_id = p_organization_id )
and   (p_location_id is null
       or asg.location_id = p_location_id)
and   (p_benfts_grp_id is null
       or per.benefit_group_id = p_benfts_grp_id)
and   (p_rptg_grp_id is null
       or exists (select null
                  from   ben_popl_rptg_grp_f   prpg
  		  where  pen.pl_id = prpg.pl_id(+)
  		  and    pen.pgm_id = prpg.pgm_id(+)
  		  and    prpg.rptg_grp_id = p_rptg_grp_id));
--
l_object_version_number number;
l_benefit_action_id 	number;
skip 			boolean;
l_err_message		varchar2(4000);
l_rl_ret		varchar2(100);
l_person_action_id	number;
l_commit                number;
--
begin
    -- Put row in fnd_sessions
    --
    dt_fndate.change_ses_date
           (p_ses_date => p_run_date,
            p_commit   => l_commit);

    -- create a benefit action
    ben_benefit_actions_api.create_perf_benefit_actions
         ( p_benefit_action_id      => l_benefit_action_id
          ,p_process_date           => p_run_date
          ,p_pgm_id                 => p_pgm_id
          ,p_business_group_id      => p_business_group_id
          ,p_pl_id                  => p_pl_id
          ,p_person_selection_rl    => p_person_selection_rule_id
          ,p_organization_id        => p_organization_id
          ,p_location_id            => p_location_id
          ,p_request_id             => fnd_global.conc_request_id
          ,p_program_application_id => fnd_global.prog_appl_id
          ,p_program_id             => fnd_global.conc_program_id
          ,p_program_update_date    => sysdate
          ,p_object_version_number  => l_object_version_number
          ,p_effective_date         => p_run_date
          ,p_benfts_grp_id          => p_benfts_grp_id
          ,p_payroll_id             => p_payroll_id
          ,p_rptg_grp_id	    => p_rptg_grp_id
          ,p_mode_cd                => 'U'
	  ,p_derivable_factors_flag => 'N'
	  ,p_validate_flag          => 'N'
          ,p_debug_messages_flag    => 'Y'
          ,p_audit_log_flag         => 'N'
          ,p_no_plans_flag          => 'N'
          ,p_no_programs_flag       => 'N'
         );
    --
    p_benefit_action_id := l_benefit_action_id ;
    -- execute the formula for each person
    for l_person in c_person loop
        --
    	ben_conc_reports.rep_person_selection_rule
	       		(p_person_id                => l_person.person_id
	       		,p_business_group_id        => p_business_group_id
	       		,p_person_selection_rule_id => p_person_selection_rule_id
	       		,p_effective_date           => p_run_date
	       	        ,p_return                   => l_rl_ret
      			,p_err_message              => l_err_message ) ;
      	--

	if l_rl_ret = 'Y' then
	    -- person has passed the rule, so create a person action
            ben_person_actions_api.create_person_actions(
    	      p_validate              => false
	     ,p_person_action_id      => l_person_action_id
	     ,p_person_id             => l_person.person_id
	     ,p_ler_id                => l_person.ler_id
	     ,p_benefit_action_id     => l_benefit_action_id
	     ,p_action_status_cd      => 'U'
	     ,p_object_version_number => l_object_version_number
    	     ,p_effective_date        => p_run_date);
            --
       	end if;
       	--
    end loop;
    --
    commit;
exception
  when others then
    -- fnd_file.put_line(fnd_file.log, sqlerrm || ' ' || sqlcode);
    rollback;
    p_benefit_action_id := null;
    raise;

end exec_per_selection_rule;
--
-- ============================================================================
--                            <<old_premium_val>>
-- ============================================================================
--
FUNCTION old_premium_val
	 (p_person_id 		number,
 	  p_pl_id		number,
	  p_pgm_id		number,
	  p_oipl_id		number,
	  p_report_start_date 	date,
	  p_run_date	      	date,
	  p_business_group_id 	number,
	  p_return_type	 	varchar2  -- ('PREMIUM','RATE')
	 ) RETURN NUMBER  is
--
cursor c_premium(c_pgm_id number, c_oipl_id number) is
select popl.val,
       pen.prtt_enrt_rslt_id
from   ben_prtt_enrt_rslt_f pen
      ,ben_per_in_ler pil
      ,ben_prtt_prem_f prm
      ,ben_prtt_prem_by_mo_f popl
where pen.pl_id = p_pl_id
and   (c_pgm_id is null or pen.pgm_id = c_pgm_id )
and   (c_oipl_id is null  or pen.oipl_id = c_oipl_id )
and   pen.person_id = p_person_id
and   pen.prtt_enrt_rslt_stat_cd is null
and   pen.enrt_cvg_thru_dt >= pen.effective_end_date
--and   enrt_cvg_thru_dt < p_report_start_date --p_run_date
and   pen.sspndd_flag = 'N'
and   pil.per_in_ler_id = pen.per_in_ler_id
and   pil.per_in_ler_stat_cd in ('PROCD' , 'STRTD')
and   pil.lf_evt_ocrd_dt  = ( select max(pil2.LF_EVT_OCRD_DT)
                              from   ben_per_in_ler pil2
                              where  pil2.per_in_ler_stat_cd in ( 'PROCD' , 'STRTD')
                              and    pil2.lf_evt_ocrd_dt < p_report_start_date
			      and    pil2.person_id = p_person_id )
and   prm.effective_start_date =  (select max(prm2.effective_start_date)
                              from   ben_prtt_prem_f prm2
                              where  prm2.prtt_prem_id = prm.prtt_prem_id
                              and    prm2.effective_start_date <= p_report_start_date )
and   prm.prtt_enrt_rslt_id = pen.prtt_enrt_rslt_id
--and   p_report_start_date >= prm.effective_end_date
and   prm.prtt_prem_id = popl.prtt_prem_id
and   popl.yr_num||lpad(popl.mo_num,2,0) = to_char(add_months(last_day(p_report_start_date),-1),'YYYYMM')
and   popl.business_group_id = p_business_group_id;
--
cursor c_rate(c_prtt_enrt_rslt_id number) is
select sum(prv.cmcd_rt_val)
from   ben_prtt_rt_val prv
where  prv.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
and    tx_typ_cd in ('PRETAX' , 'AFTERTAX' , 'NOTAPPLICABLE')
and    acty_typ_cd in ('EEPYC','ERC', 'ERPYC')
and    add_months(last_day(p_report_start_date),-1) between rt_strt_dt and rt_end_dt;
--
cursor c_mult_enrt is
select count(*)
from   ben_prtt_enrt_rslt_f pen
where  pen.pl_id = p_pl_id
and    pen.person_id = p_person_id
and    pen.prtt_enrt_rslt_stat_cd is null
and    pen.business_group_id = p_business_group_id
and    pen.enrt_cvg_thru_dt <= pen.effective_end_date
and    p_run_date between pen.enrt_cvg_strt_dt and enrt_cvg_thru_dt
and    pen.sspndd_flag = 'N' ;
--
l_premium number := 0;
l_rate number := 0;
l_dummy number;
l_pgm_id number;
l_oipl_id number;
l_prtt_enrt_rslt_id number;
--
BEGIN
  --
  /*
  open c_mult_enrt;
  fetch c_mult_enrt into l_dummy;
  close c_mult_enrt;
  --
  if l_dummy > 1 then
  	-- person enrolled in multiple comp objects having the same plan
  	l_pgm_id := p_pgm_id;
  	l_oipl_id := p_oipl_id;
  end if;
  --
  */
  open c_premium(l_pgm_id , l_oipl_id );
  fetch c_premium into l_premium, l_prtt_enrt_rslt_id;
  close c_premium;
  --
  if p_return_type = 'PREMIUM' then
  	return l_premium;
  elsif p_return_type = 'RATE' then
        --
  	open c_rate(l_prtt_enrt_rslt_id);
  	fetch c_rate into l_rate;
  	close c_rate;
  	--
  	return nvl(l_rate,0);
  end if;
  --
END old_premium_val;
--
-- ============================================================================
--                            <<get_new_rates>>
-- ============================================================================
--
FUNCTION get_new_rates
	 (p_prtt_enrt_rslt_id	number,
	  p_report_start_date 	date,
	  p_run_date	      	date,
	  p_business_group_id 	number,
	  p_return_type	 	varchar2,  -- ('ELEMENT','RATE')
	  p_per_in_ler_id	number
	 ) RETURN NUMBER  is
--
cursor c_rate(c_prtt_enrt_rslt_id number) is
select sum(prv.cmcd_rt_val)
from   ben_prtt_rt_val prv
where  prv.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
and    tx_typ_cd in ('PRETAX' , 'AFTERTAX' , 'NOTAPPLICABLE' )
and    acty_typ_cd in ('EEPYC','ERC' , 'ERPYC' )
and    prv.per_in_ler_id = p_per_in_ler_id;

--and    p_run_date between rt_strt_dt and rt_end_dt;
--
cursor c_total_elem_entry(c_prtt_enrt_rslt_id number) is
select sum(screen_entry_value)
from   ben_prtt_rt_val prv,
       pay_element_entry_values_f env
where  prv.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
and    env.element_entry_value_id = prv.element_entry_value_id
and    tx_typ_cd in ('PRETAX' , 'AFTERTAX' , 'NOTAPPLICABLE' )
and    acty_typ_cd in ('EEPYC','ERC' , 'ERPYC')
and    prv.per_in_ler_id = p_per_in_ler_id
and    p_run_date between env.effective_start_date and env.effective_end_date;
--

--
l_element number := 0;
l_rate number := 0;
l_dummy number;
l_pgm_id number;
l_oipl_id number;
l_prtt_enrt_rslt_id number;
--
BEGIN
  --
  --
  if p_return_type = 'ELEMENT' then
    	open  c_total_elem_entry(p_prtt_enrt_rslt_id);
    	fetch c_total_elem_entry into l_element;
  	close c_total_elem_entry;

  	return nvl(l_element,0);
  elsif p_return_type = 'RATE' then
        --
  	open c_rate(p_prtt_enrt_rslt_id);
  	fetch c_rate into l_rate;
  	close c_rate;
  	--
  	return nvl(l_rate,0);
  end if;
  --
END get_new_rates;
--
-- ============================================================================
--                            <<get_change_eff_dt>>
-- ============================================================================
--
FUNCTION get_change_eff_dt
	 (p_prtt_enrt_rslt_id	number,
	  p_report_start_date 	date,
	  p_run_date	      	date
	 ) RETURN date  is
--
cursor c_rate(c_prtt_enrt_rslt_id number) is
select min(prv.rt_strt_dt)
from   ben_prtt_rt_val prv
where  prv.prtt_enrt_rslt_id = c_prtt_enrt_rslt_id
and    tx_typ_cd in ('PRETAX' , 'AFTERTAX')
and    acty_typ_cd in ('EEPYC','ERC') ;
--and    p_report_start_date <= rate_strt_dt;
--

--
l_change_eff_date date;
--
BEGIN
  --
  --
  open  c_rate(p_prtt_enrt_rslt_id);
  fetch c_rate into l_change_eff_date;
  close c_rate;

  return l_change_eff_date;
  --
END GET_CHANGE_EFF_DT;
--
-- ============================================================================
--                            <<get_element_val>>
-- ============================================================================
--
FUNCTION get_element_val
	 (p_prtt_enrt_rslt_id 	number,
	  p_run_date	      	date,
	  p_business_group_id 	number,
	  p_tx_typ_cd		varchar2,
	  p_acty_typ_cd		varchar2,
	  p_per_in_ler_id	number,
          p_run_date_end        date default null -- 3608119
	 ) RETURN NUMBER  is
--
cursor c_element_val is
select sum(env.screen_entry_value)
from   ben_prtt_rt_val prv,
       pay_element_entry_values_f env
where  prv.prtt_enrt_rslt_id     = p_prtt_enrt_rslt_id
and    (p_tx_typ_cd is null or prv.tx_typ_cd = p_tx_typ_cd)
and    prv.acty_typ_cd 		 = p_acty_typ_cd
and    prv.prtt_rt_val_stat_cd is null
--and    p_run_date between prv.rt_strt_dt and prv.rt_end_dt
and    prv.per_in_ler_id = p_per_in_ler_id
and    env.element_entry_value_id = prv.element_entry_value_id
and    prv.rt_strt_dt between env.effective_start_date and env.effective_end_date
and    (p_run_date between prv.rt_strt_dt and prv.rt_end_dt
        or
        nvl(p_run_date_end, prv.rt_strt_dt) between prv.rt_strt_dt and prv.rt_end_dt
        );-- 3608119
--
cursor c_er_element_val is
select sum(env.screen_entry_value)
from   ben_prtt_rt_val prv,
       pay_element_entry_values_f env
where  prv.prtt_enrt_rslt_id     = p_prtt_enrt_rslt_id
and    (p_tx_typ_cd is null or prv.tx_typ_cd = p_tx_typ_cd)
and    prv.acty_typ_cd 		 in ('ERC' , 'ERPYC' )
and    prv.prtt_rt_val_stat_cd is null
--and    p_run_date between prv.rt_strt_dt and prv.rt_end_dt
and    prv.per_in_ler_id = p_per_in_ler_id
and    env.element_entry_value_id = prv.element_entry_value_id
and    prv.rt_strt_dt between env.effective_start_date and env.effective_end_date
and    (p_run_date between prv.rt_strt_dt and prv.rt_end_dt
        or
        nvl(p_run_date_end, prv.rt_strt_dt) between prv.rt_strt_dt and prv.rt_end_dt
        );
--
l_element_value number;
--
BEGIN
  --
  if p_acty_typ_cd = 'ERC'
  then
     open c_er_element_val;
     fetch c_er_element_val into l_element_value;
     close c_er_element_val;
  else
     open c_element_val;
     fetch c_element_val into l_element_value;
     close c_element_val;
  end if;

  return nvl(l_element_value , 0);
  --
end  GET_ELEMENT_VAL;
--
-- ============================================================================
--                            <<get_rate_val>>
-- ============================================================================
--
FUNCTION get_rate_val
	 (p_prtt_enrt_rslt_id 	number,
	  p_run_date	      	date,
	  p_business_group_id 	number,
	  p_tx_typ_cd		varchar2,
	  p_acty_typ_cd		varchar2,
	  p_per_in_ler_id	number,
          p_run_date_end    date default null-- 3608119
	 ) RETURN NUMBER  is
--
cursor c_rate_val is
select sum(prv.cmcd_rt_val)
from   ben_prtt_rt_val prv
where  prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
and    (p_tx_typ_cd is null or prv.tx_typ_cd = p_tx_typ_cd)
and    prv.acty_typ_cd 	 = p_acty_typ_cd
and    prv.per_in_ler_id = p_per_in_ler_id
and    (p_run_date between prv.rt_strt_dt and prv.rt_end_dt
        or
        nvl(p_run_date_end, prv.rt_strt_dt) between prv.rt_strt_dt and prv.rt_end_dt
        )-- 3608119
;
cursor c_er_rate_val is
select sum(prv.cmcd_rt_val)
from   ben_prtt_rt_val prv
where  prv.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
and    (p_tx_typ_cd is null or prv.tx_typ_cd = p_tx_typ_cd)
and    prv.acty_typ_cd 	 in ('ERC' , 'ERPYC' )
and    prv.per_in_ler_id = p_per_in_ler_id
and    (p_run_date between prv.rt_strt_dt and prv.rt_end_dt
        or
        nvl(p_run_date_end, prv.rt_strt_dt) between prv.rt_strt_dt and prv.rt_end_dt
        );
--
l_rate_value number;
--
BEGIN
  --
  if p_acty_typ_cd = 'ERC' then
     open c_er_rate_val;
     fetch c_er_rate_val into l_rate_value ;
     close c_er_rate_val;
  else
     open c_rate_val;
     fetch c_rate_val into l_rate_value ;
     close c_rate_val;
  end if;

  return nvl(l_rate_value , 0);
  --
end  get_rate_val;
--
-- ============================================================================
--                            <<get_prtt_rate_val>>
-- ============================================================================
--
FUNCTION get_prtt_rate_val
	 (p_prtt_enrt_rslt_id 	number,
	  p_run_date	      	date,
	  p_per_in_ler_id	number,
	  p_run_date_end        date default null -- 3608119
	  ) RETURN NUMBER  is
--
cursor c_prtt_defn_amt is
select sum(rt_val)  rate
from   ben_prtt_rt_val prv
where  prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
and    tx_typ_cd in ('PRETAX' , 'AFTERTAX', 'NOTAPPLICABLE')
and    acty_typ_cd in ('EEPYC','ERC')
and    prv.per_in_ler_id = p_per_in_ler_id
and    (p_run_date between prv.rt_strt_dt and prv.rt_end_dt
        or
        nvl(p_run_date_end, prv.rt_strt_dt) between prv.rt_strt_dt and prv.rt_end_dt)--3608119
;
--
l_rate_value number;
--
BEGIN
  --
  open c_prtt_defn_amt;
  fetch c_prtt_defn_amt into l_rate_value ;
  close c_prtt_defn_amt;

  return nvl(l_rate_value , 0);
  --
end  get_prtt_rate_val;

--
-- ============================================================================
--                            <<report_header>>
-- ============================================================================
--
procedure report_header
(p_run_date		IN  date,
p_person_id		IN  number,
p_emp_name_format	IN  varchar2,
p_pgm_id		IN  number,
p_pl_id			IN  number,
p_per_sel_rule_id	IN  number,
p_business_group_id	IN  number,
p_organization_id	IN  number,
p_location_id		IN  number,
p_benfts_grp_id		IN  number,
p_rptg_grp_id		IN  number,
p_prem_type		IN  varchar2,
p_payroll_id		IN  number,
p_output_typ		IN  varchar2,
p_dsply_pl_disc_rep	IN  varchar2,
p_dsply_pl_recn_rep	IN  varchar2,
p_dsply_pl_prtt_rep	IN  varchar2,
p_dsply_prtt_reps  	IN  varchar2,
p_dsply_lfe_rep    	IN  varchar2,
p_ret_person		OUT NOCOPY varchar2,
p_ret_emp_name_format	OUT NOCOPY varchar2,
p_ret_pgm		OUT NOCOPY varchar2,
p_ret_pl		OUT NOCOPY varchar2,
p_ret_per_sel_rule	OUT NOCOPY varchar2,
p_ret_business_group	OUT NOCOPY varchar2,
p_ret_organization	OUT NOCOPY varchar2,
p_ret_location		OUT NOCOPY varchar2,
p_ret_benfts_grp	OUT NOCOPY varchar2,
p_ret_rptg_grp		OUT NOCOPY varchar2,
p_ret_prem_type		OUT NOCOPY varchar2,
p_ret_payroll		OUT NOCOPY varchar2,
p_ret_output_typ	OUT NOCOPY varchar2,
p_ret_dsply_pl_disc_rep	OUT NOCOPY varchar2,
p_ret_dsply_pl_recn_rep	OUT NOCOPY varchar2,
p_ret_dsply_pl_prtt_rep	OUT NOCOPY varchar2,
p_ret_dsply_prtt_reps  	OUT NOCOPY varchar2,
p_ret_dsply_lfe_rep    	OUT NOCOPY varchar2)
as
--
cursor c_person is
select per.full_name
from   per_all_people_f per
where  per.person_id = p_person_id
and    p_run_date between nvl(per.effective_start_date,p_run_date)
       and     nvl(per.effective_end_date,p_run_date);
--

cursor c_formula is
select formula_name
from   ff_formulas_f ff
where  ff.formula_id(+) = p_per_sel_rule_id
and    p_run_date between nvl(ff.effective_start_date,p_run_date)
               and nvl(ff.effective_end_date,p_run_date);
--
cursor c_benefits_group is
select name
from   ben_benfts_grp
where  benfts_grp_id = p_benfts_grp_id;
--
cursor c_reporting_group is
select name
from   ben_rptg_grp_v
where  rptg_grp_id = p_rptg_grp_id;
--
cursor  c_payroll is
select  pay.payroll_name
from    pay_all_payrolls_f pay
where   pay.payroll_id = p_payroll_id
and     p_run_date between pay.effective_start_date and pay.effective_end_date ;

--
l_all                     varchar2(80) := 'All';
l_none                    varchar2(80) := 'None';
--
BEGIN
	--
	if p_person_id is not null then
	   open c_person;
	   fetch c_person into p_ret_person;
	   close c_person;
	else
	   p_ret_person := l_all;
        end if;
        --
	p_ret_emp_name_format := hr_general.decode_lookup('BEN_PER_NAME_FMT',p_emp_name_format );
	--
	if p_pgm_id is not null then
		p_ret_pgm := ben_batch_utils.get_pgm_name(p_pgm_id, p_business_group_id,p_run_date);
	else
		p_ret_pgm := l_all;
	end if;
	--
	p_ret_pl := ben_batch_utils.get_pl_name(p_pl_id,p_business_group_id,p_run_date);
	--
	if p_per_sel_rule_id is not null then
	      open  c_formula;
	      fetch c_formula into p_ret_per_sel_rule;
	      close c_formula;
	else
		p_ret_per_sel_rule := l_none;
	end if;
	--
	p_ret_business_group := hr_general.decode_organization(p_business_group_id);
	--
	if p_organization_id is not null then
		p_ret_organization := hr_general.decode_organization(p_organization_id);
	else
		p_ret_organization := l_all;
	end if;
	--
	if p_location_id is not null then
		p_ret_location := hr_general.decode_location(p_location_id);
	else
		p_ret_location := l_all;
	end if;
	--
	if p_benfts_grp_id is not null then
	      open  c_benefits_group;
	      fetch c_benefits_group into p_ret_benfts_grp;
	      close c_benefits_group;
	else
		p_ret_benfts_grp := l_all;
	end if;
	--
	if p_rptg_grp_id is not null then
	      open  c_reporting_group;
	      fetch c_reporting_group into p_ret_rptg_grp;
	      close c_reporting_group;
	else
	      p_ret_rptg_grp := l_all;
	end if;
	--
	if p_payroll_id is not null then
	       	open  c_payroll;
	      	fetch c_payroll into p_ret_payroll;
	      	close c_payroll;
	else
		p_ret_payroll := l_all;
	end if;
	--
	if p_prem_type is not null then
		p_ret_prem_type := hr_general.decode_lookup('BEN_PRSPCTV_R_RTSPCTV',p_prem_type);
	else
		p_ret_prem_type := l_all;
	end if;
	--
	p_ret_output_typ := hr_general.decode_lookup('BEN_FILE_OP_TYP',p_output_typ);
	p_ret_dsply_pl_disc_rep  := hr_general.decode_lookup('YES_NO',p_dsply_pl_disc_rep);
	p_ret_dsply_pl_recn_rep  := hr_general.decode_lookup('YES_NO',p_dsply_pl_recn_rep);
	p_ret_dsply_pl_prtt_rep  := hr_general.decode_lookup('YES_NO',p_dsply_pl_prtt_rep);
	p_ret_dsply_prtt_reps    := hr_general.decode_lookup('YES_NO',p_dsply_prtt_reps);
	p_ret_dsply_lfe_rep      := hr_general.decode_lookup('YES_NO',p_dsply_lfe_rep);
--
END report_header;
--
end ben_recn_rep;

/
