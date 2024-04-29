--------------------------------------------------------
--  DDL for Package Body BEN_BENLESUM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENLESUM_XMLP_PKG" AS
/* $Header: BENLESUMB.pls 120.1 2007/12/10 08:36:35 vjaganat noship $ */

function cf_transfer_valuesformula(CS_detected_name_potnl_rep in number, CS_unprocessed_name_potnl_rep in number, CS_processed_name_potnl_rep in number,
CS_voided_name_potnl_rep in number,
CS_settoman_name_potnl_rep in number, CS_manover_name_potnl_rep in number, CS_total_name_potnl_rep in number,
CS_detected_name_potnl_comp in number, CS_unprocessed_name_potnl_comp in number, CS_processed_name_potnl_comp in number,
CS_voided_name_potnl_comp in number, CS_settoman_name_potnl_comp in number,
CS_manover_name_potnl_comp in number, CS_total_name_potnl_comp in number,
CS_started_name_processed_rep in number, CS_proc_name_processed_rep in number, CS_backedout_name_proc_rep in number,
CS_voided_name_proc_rep in number, CS_total_name_proc_rep in number,
CS_started_name_processed_comp in number, CS_proc_name_processed_comp in number,
CS_backedout_name_proc_comp in number, CS_voided_name_proc_comp in number, CS_total_name_proc_comp in number) return number is

cursor c_report_module is
Select meaning from hr_lookups where lookup_type = 'BEN_LESUM_REPT_MODL_CD' and lookup_code = p_report_module_cd;

cursor c_asg_type is
Select meaning from hr_lookups where lookup_type = 'BEN_LESUM_ASG_TYPE' and lookup_code = p_assignment_type;

cursor c_ler_type is
Select meaning from hr_lookups where lookup_type = 'BEN_LESUM_LER_TYPE' and lookup_code = p_ler_type;

cursor c_BG_info is
select hr_general.decode_organization(p_organization_id),hr_general.decode_location(p_location_id),hr_general.decode_organization(p_business_group_id) from dual;

cursor c_benefit_group_name is
Select name from BEN_BENFTS_GRP where benfts_grp_id=p_benefit_group_id and business_group_id=p_business_group_id;

cursor c_reporting_group_name is
Select tl.name from ben_rptg_grp rpt,ben_rptg_grp_tl tl where rpt.rptg_grp_id=p_reporting_group_id and business_group_id=p_business_group_id and rpt.rptg_grp_id=tl.rptg_grp_id
and tl.language=userenv('LANG');

cursor c_ler_name is
Select tl.name from ben_ler_f ler, ben_ler_f_tl tl
	where
	ler.ler_id = tl.ler_id and
	ler.effective_start_date = tl.effective_start_date and
	tl.language = userenv('LANG') and
	ler.ler_id=p_ler_id and business_group_id=p_business_group_id;

cursor c_person_name is
Select full_name from per_all_people_f where person_id=p_person_id and business_group_id=p_business_group_id;

cursor c_displ_flex is
Select meaning from hr_lookups where lookup_type = 'YES_NO' and lookup_code = p_disp_flex_fields_flag;

begin

      	CP_detected_name_potnl_rep :=CS_detected_name_potnl_rep;
	CP_unprocessed_name_potnl_rep :=CS_unprocessed_name_potnl_rep;
	CP_processed_name_potnl_rep :=CS_processed_name_potnl_rep;
	CP_voided_name_potnl_rep :=CS_voided_name_potnl_rep;
	CP_settomanual_name_potnl_rep :=CS_settoman_name_potnl_rep;
	CP_manover_name_potnl_rep :=CS_manover_name_potnl_rep;
	CP_total_name_potnl_rep :=CS_total_name_potnl_rep;


	CP_detected_name_potnl_comp :=CS_detected_name_potnl_comp;
	CP_unprocessed_name_potnl_comp :=CS_unprocessed_name_potnl_comp;
	CP_processed_name_potnl_comp :=CS_processed_name_potnl_comp;
	CP_voided_name_potnl_comp :=CS_voided_name_potnl_comp;
	CP_settomanual_name_potnl_comp :=CS_settoman_name_potnl_comp;
	CP_manover_name_potnl_comp :=CS_manover_name_potnl_comp;
	CP_total_name_potnl_comp :=CS_total_name_potnl_comp;


        	CP_started_name_proc_rep :=CS_started_name_processed_rep;
	CP_processed_name_proc_rep :=CS_proc_name_processed_rep;
	CP_backedout_name_proc_rep :=CS_backedout_name_proc_rep;
	CP_voided_name_proc_rep :=CS_voided_name_proc_rep;
	CP_total_name_proc_rep :=CS_total_name_proc_rep;

 	CP_started_name_proc_comp :=CS_started_name_processed_comp;
	CP_processed_name_proc_comp :=CS_proc_name_processed_comp;
	CP_backedout_name_proc_comp :=CS_backedout_name_proc_comp;
	CP_voided_name_proc_comp :=CS_voided_name_proc_comp;
	CP_total_name_proc_comp :=CS_total_name_proc_comp;

	cp_rept_strt_end_dt := to_char(p_rept_perd_strt_dt,p_date_mask)|| ' - '||to_char(p_rept_perd_end_dt,p_date_mask);

	if p_comp_perd_strt_dt is null and p_comp_perd_end_dt is null then
		cp_comp_strt_end_dt :=null;
	else
	cp_comp_strt_end_dt := to_char(p_comp_perd_strt_dt,p_date_mask)|| ' - '||to_char(p_comp_perd_end_dt,p_date_mask);
	end if;


    open c_report_module;
  fetch c_report_module into CP_report_module_name;

  close c_report_module;

  open c_asg_type ;
  fetch c_asg_type  into CP_asg_type;
  if cp_asg_type is null then
  	cp_asg_type:='All';
  	end if;
  close c_asg_type;

  open c_ler_type;
  fetch c_ler_type into CP_ler_type;
  if cp_ler_type is null then
  	cp_ler_type:='All';
  	end if;
  close c_ler_type;

  open c_bg_info;
  fetch c_bg_info into cp_organization_name,cp_location_name,cp_business_group_name;
   if cp_organization_name is null then
  	cp_organization_name:='All';
   end if;
    if cp_location_name is null then
  	cp_location_name:='All';
    end if;
  close c_bg_info;


  open c_reporting_group_name;
  fetch c_reporting_group_name into cp_reporting_group_name;
  if cp_reporting_group_name is null then
  	cp_reporting_group_name:='All';
  	end if;
  close c_reporting_group_name;


  open c_benefit_group_name;
  fetch c_benefit_group_name into cp_benefit_group_name;
  if cp_benefit_group_name is null then
  	cp_benefit_group_name:='All';
  	end if;
  close c_benefit_group_name;


  if p_pl_id is not null then
  cp_pln_name:=ben_batch_utils.get_pl_name(p_pl_id, p_business_group_id,p_run_date);
  	if cp_pln_name='PLAN NOT FOUND' then
		cp_pln_name:='All';
	end if;
  else
  	cp_pln_name:='All';
  end if;


  open c_person_name;
  fetch c_person_name into cp_person_name;
  if cp_person_name is null then
  	cp_person_name:='All';
  	end if;
  close c_person_name;

  open c_ler_name;
  fetch c_ler_name into cp_ler_name;
  if cp_ler_name is null then
  	cp_ler_name:='All';
  	end if;
  close c_ler_name;

open c_displ_flex;
  fetch c_displ_flex into cp_displ_flex;
    close c_displ_flex;


  if p_nat_ident is null then
	cp_nat_ident:='All';
   else
	cp_nat_ident:=p_nat_ident;
   end if;



  return 1;
end;

function AfterPForm return boolean is
begin


	if ((p_rept_perd_strt_dt is not null) and (p_rept_perd_end_dt is null))
		or ((p_rept_perd_strt_dt is null) and (p_rept_perd_end_dt is not null)) then
			fnd_message.set_name('BEN','BEN_93336_LES_STRT_END_DT_NULL');
      fnd_message.set_token('PARAM','Reporting',TRUE);
      p_error := fnd_message.get;
      p_run_report:='N';
  end if;

	if ((p_comp_perd_strt_dt is not null) and (p_comp_perd_end_dt is null))
		or ((p_comp_perd_strt_dt is null) and (p_comp_perd_end_dt is not null)) then

		fnd_message.set_name('BEN','BEN_93336_LES_STRT_END_DT_NULL');
      fnd_message.set_token('PARAM','Comparison',TRUE);
  p_run_report:='N';
     p_error := fnd_message.get;
	end if;


	if (p_pl_id is not null and p_reporting_group_id is not null) then
		declare
			l_dummy varchar2(1);
			l_rpt_grp_name varchar2(300):=null;
			cursor c_pl is select null from ben_popl_rptg_grp_f rgr
				where rgr.rptg_grp_id = p_reporting_group_id
				and rgr.pl_id=p_pl_id
				and p_run_date between rgr.effective_start_date and rgr.effective_end_date;
			cursor c_rpt_grp is Select tl.name from ben_rptg_grp rpt,ben_rptg_grp_tl tl
				where rpt.rptg_grp_id=p_reporting_group_id and
				business_group_id=p_business_group_id and rpt.rptg_grp_id=tl.rptg_grp_id
				and tl.language=userenv('LANG');

		begin
			open c_rpt_grp;
					fetch c_rpt_grp into l_rpt_grp_name;
					close c_rpt_grp;
			open c_pl;
			fetch c_pl into l_dummy;
			if c_pl%found then
			close c_pl;
			else
				fnd_message.set_name('BEN','BEN_93334_PL_NOT_IN_RPTG_GRP');
			      fnd_message.set_token('PL_NAME',ben_batch_utils.get_pl_name(p_pl_id, p_business_group_id,p_run_date));
			      fnd_message.set_token('RPTG_GRP',l_rpt_grp_name);
				p_run_report:='N';
			       p_error := fnd_message.get;
				close c_pl;
			end if;
		end;

end if;



  	if ((p_rept_perd_strt_dt is not null) and (p_rept_perd_end_dt is not null)) then
  		if p_rept_perd_strt_dt > p_rept_perd_end_dt then
  			fnd_message.set_name('BEN','BEN_93335_LES_STRT_GRT_END_DT');
      fnd_message.set_token('PARAM','Reporting',TRUE);
  p_run_report:='N';
  p_error := fnd_message.get;
  		end if;
  	end if;


  	if ((p_comp_perd_strt_dt is not null) and (p_comp_perd_end_dt is not null)) then
  		if p_comp_perd_strt_dt > p_comp_perd_end_dt then
  			fnd_message.set_name('BEN','BEN_93335_LES_STRT_GRT_END_DT');
      fnd_message.set_token('PARAM','Comparison',TRUE);
  p_run_report:='N';
  p_error := fnd_message.get;
  		end if;
  	end if;






  if p_sort_order_1 is not null then
  	append_order_by(p_sort_order_1);
  	end if;
  if p_sort_order_2 is not null then
  	append_order_by(p_sort_order_2);
  end if;
  if p_sort_order_3 is not null then
  	append_order_by(p_sort_order_3);
  end if;
  if p_sort_order_4 is not null then
  	append_order_by(p_sort_order_4);
  end if;


  if p_sort is null then
  	p_sort :=' order by '||' PERNAME';
  	p_sort1 :=' order by '||' PERNAME'; --Added during DT Fixes
	p_user_sort:=hr_general.decode_lookup('BEN_LESUM_SORT_ORDR', 'PERNAME');
  else
  	p_sort:=' order by '||p_sort;
  	p_sort1:=' order by '||p_sort1; --Added during DT Fixes
  end if;
 p_sort_dff := p_sort||  ',PER_IN_LER_ID, COUNTER ';

 p_sort_dff2 := ' order by '||p_sort_dff2||  ',PER_IN_LER_ID, COUNTER '; --Added during DT Fixes
 p_sort_dff3 := ' order by '||p_sort_dff3||  ',PER_IN_LER_ID1, COUNTER1 '; --Added during DT Fixes



  return (TRUE);
end;

PROCEDURE append_order_by(colname varchar2) IS
BEGIN

  	if colname is not null and p_sort is not null then
  	p_sort :=p_sort||' , '||colname;
  	p_user_sort:=p_user_sort||' , '||hr_general.decode_lookup('BEN_LESUM_SORT_ORDR',colname);
        --Added for DT Fixes
        p_sort1 :=p_sort1||' , '||colname||'1';
        p_sort_dff2 := p_sort_dff2||' , '||colname||'2';
        p_sort_dff3 := p_sort_dff3||' , '||colname||'3';
        --End of add during DT Fixes
  elsif colname is not null and p_sort is null then
  	p_sort:=colname;
        --Added for DT Fixes
        p_sort1 :=colname||'1';
        p_sort_dff2 :=colname||'2';
        p_sort_dff3 :=colname||'3';
        --End of add during DT Fixes
  	p_user_sort:=hr_general.decode_lookup('BEN_LESUM_SORT_ORDR',colname);
  	  end if;
END;

FUNCTION FIND_COL(col_name varchar2) RETURN varchar2 IS

BEGIN
if   col_name='PERNAME' then
	return('FULL_NAME_REP');
end if;
if   col_name='PERSSN' then
	return('SSN_rep');
end if;
if   col_name='LERNAME' then
	return('ler_name_plan_rep');
end if;
if   col_name='LESTAT' then
	return('ler_status_plan_rep');
end if;
if   col_name='LERTYPE' then
	return('le_type_plan_rep');
end if;
if   col_name='PERLOC' then
	return('loc_code_plan_rep');
end if;
if   col_name='LEOCRDDT' then
	return('lf_evt_dt_plan_rep');
end if;
return(null);
END;

function BeforeReport return boolean is
begin
  /*srw.user_exit('FND SRWINIT');*/null;
p_date_mask := fnd_profile.value('ICX_DATE_FORMAT_MASK');

T_CONC_REQUEST_ID	:= FND_GLOBAL.CONC_REQUEST_ID;
T_RUN_DATE		:= to_char(P_RUN_DATE,p_date_mask);
T_COMP_PERD_STRT_DT	:= to_char(P_COMP_PERD_STRT_DT,p_date_mask);
T_COMP_PERD_END_DT	:= to_char(P_COMP_PERD_END_DT,p_date_mask);
T_REPT_PERD_STRT_DT	:= to_char(P_REPT_PERD_STRT_DT,p_date_mask);
T_REPT_PERD_END_DT	:= to_char(P_REPT_PERD_END_DT,p_date_mask);



  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_detected_name_potnl_rep_p return number is
	Begin
	 return CP_detected_name_potnl_rep;
	 END;
 Function CP_unprocessed_name_potnl_rep1 return number is
	Begin
	 return CP_unprocessed_name_potnl_rep;
	 END;
 Function CP_processed_name_potnl_rep_p return number is
	Begin
	 return CP_processed_name_potnl_rep;
	 END;
 Function CP_total_name_potnl_rep_p return number is
	Begin
	 return CP_total_name_potnl_rep;
	 END;
 Function CP_voided_name_potnl_rep_p return number is
	Begin
	 return CP_voided_name_potnl_rep;
	 END;
 Function CP_settomanual_name_potnl_rep1 return number is
	Begin
	 return CP_settomanual_name_potnl_rep;
	 END;
 Function CP_manover_name_potnl_rep_p return number is
	Begin
	 return CP_manover_name_potnl_rep;
	 END;
 Function CP_detected_name_potnl_comp_p return number is
	Begin
	 return CP_detected_name_potnl_comp;
	 END;
 Function CP_unprocessed_name_potnl_com return number is
	Begin
	 return CP_unprocessed_name_potnl_comp;
	 END;
 Function CP_processed_name_potnl_comp_p return number is
	Begin
	 return CP_processed_name_potnl_comp;
	 END;
 Function CP_total_name_potnl_comp_p return number is
	Begin
	 return CP_total_name_potnl_comp;
	 END;
 Function CP_voided_name_potnl_comp_p return number is
	Begin
	 return CP_voided_name_potnl_comp;
	 END;
 Function CP_settomanual_name_potnl_com return number is
	Begin
	 return CP_settomanual_name_potnl_comp;
	 END;
 Function CP_manover_name_potnl_comp_p return number is
	Begin
	 return CP_manover_name_potnl_comp;
	 END;
 Function CP_started_name_proc_rep_p return number is
	Begin
	 return CP_started_name_proc_rep;
	 END;
 Function CP_processed_name_proc_rep_p return number is
	Begin
	 return CP_processed_name_proc_rep;
	 END;
 Function CP_backedout_name_proc_rep_p return number is
	Begin
	 return CP_backedout_name_proc_rep;
	 END;
 Function CP_voided_name_proc_rep_p return number is
	Begin
	 return CP_voided_name_proc_rep;
	 END;
 Function CP_total_name_proc_rep_p return number is
	Begin
	 return CP_total_name_proc_rep;
	 END;
 Function CP_started_name_proc_comp_p return number is
	Begin
	 return CP_started_name_proc_comp;
	 END;
 Function CP_processed_name_proc_comp_p return number is
	Begin
	 return CP_processed_name_proc_comp;
	 END;
 Function CP_backedout_name_proc_comp_p return number is
	Begin
	 return CP_backedout_name_proc_comp;
	 END;
 Function CP_voided_name_proc_comp_p return number is
	Begin
	 return CP_voided_name_proc_comp;
	 END;
 Function CP_total_name_proc_comp_p return number is
	Begin
	 return CP_total_name_proc_comp;
	 END;
 Function CP_report_module_name_p return varchar2 is
	Begin
	 return CP_report_module_name;
	 END;
 Function CP_asg_type_p return varchar2 is
	Begin
	 return CP_asg_type;
	 END;
 Function CP_ler_type_p return varchar2 is
	Begin
	 return CP_ler_type;
	 END;
 Function CP_business_group_name_p return varchar2 is
	Begin
	 return CP_business_group_name;
	 END;
 Function CP_location_name_p return varchar2 is
	Begin
	 return CP_location_name;
	 END;
 Function CP_organization_name_p return varchar2 is
	Begin
	 return CP_organization_name;
	 END;
 Function CP_reporting_group_name_p return varchar2 is
	Begin
	 return CP_reporting_group_name;
	 END;
 Function CP_benefit_group_name_p return varchar2 is
	Begin
	 return CP_benefit_group_name;
	 END;
 Function CP_pln_name_p return varchar2 is
	Begin
	 return CP_pln_name;
	 END;
 Function CP_ler_name_p return varchar2 is
	Begin
	 return CP_ler_name;
	 END;
 Function CP_person_name_p return varchar2 is
	Begin
	 return CP_person_name;
	 END;
 Function CP_nat_ident_p return varchar2 is
	Begin
	 return CP_nat_ident;
	 END;
 Function CP_displ_flex_p return varchar2 is
	Begin
	 return CP_displ_flex;
	 END;
 Function CP_rept_strt_end_dt_p return varchar2 is
	Begin
	 return CP_rept_strt_end_dt;
	 END;
 Function CP_comp_strt_end_dt_p return varchar2 is
	Begin
	 return CP_comp_strt_end_dt;
	 END;
END BEN_BENLESUM_XMLP_PKG ;

/
