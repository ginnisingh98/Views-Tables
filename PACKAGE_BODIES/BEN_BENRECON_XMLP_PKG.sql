--------------------------------------------------------
--  DDL for Package Body BEN_BENRECON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENRECON_XMLP_PKG" AS
/* $Header: BENRECONB.pls 120.1 2007/12/10 08:38:02 vjaganat noship $ */

function Format_Mask(p_uom varchar2) return varchar2 is
   v_format_mask varchar2(50) := null;
   v_field_length number(3) := 22;
begin
    v_format_mask := fnd_currency.get_format_mask(p_uom, v_field_length);

   return v_format_mask;
end;

function AfterPForm return boolean is
l_plip_name varchar2(1000);
l_date varchar2(50);
l_date_dsply boolean;

l_rep_start_date date;
l_rep_end_date date;
l_op_file_name varchar2(200);
begin

T_DSPLY_PL_RECN_REP := P_DSPLY_PL_RECN_REP;
T_DSPLY_PL_DISC_REP := P_DSPLY_PL_DISC_REP;
T_DSPLY_PL_PRTT_REP := P_DSPLY_PL_PRTT_REP;
T_DSPLY_LFE_REP	    := P_DSPLY_LFE_REP;


    p_run_date := p_report_end_date;
    if (p_person_id is not null ) and
     (p_per_sel_rule is not null) then
          fnd_message.set_name('BEN','BEN_91745_RULE_AND_PERSON');
     fnd_message.set_token('PROC','BEN_RECN_REP');
     fnd_message.set_token('PERSON_ID',p_person_id);
     fnd_message.set_token('PER_SELECT_RL',p_per_sel_rule);
          p_error := fnd_message.get;
     p_dsply_disc := 'N';
     p_dsply_recn := 'N';
     p_dsply_lfe := 'N';
     p_dsply_pl_prtt := 'N';
     return (true);
  end if;

    if p_per_sel_rule is not null then
	ben_recn_rep.exec_per_selection_rule
	(p_pl_id	    	=> p_pl_id,
	p_pgm_id		=> p_pgm_id,
	p_business_group_id	=> p_business_group_id,
	p_run_date		=> p_run_date,
	p_report_start_date	=> p_report_start_date,
	p_prem_type		=> p_prem_type,
	p_payroll_id		=> p_payroll_id,
	p_organization_id	=> p_organization_id,
	p_location_id		=> p_location_id,
	p_benfts_grp_id		=> p_benfts_grp_id,
	p_rptg_grp_id		=> p_rptg_grp_id,
	p_person_selection_rule_id  => p_per_sel_rule,
	p_benefit_action_id	=> p_benefit_action_id);
  end if;

  p_rep_st_dt := p_report_start_date;
  p_rep_end_dt := p_report_end_date;

      if ceil(months_between(p_report_end_date,p_report_start_date)) = 1 then
     l_date_dsply := TRUE;
  else
     l_date_dsply := FALSE;
  end if;
    if not l_date_dsply or p_dsply_prtt_reps = 'N' then
     p_dsply_disc := 'N';
     p_dsply_recn := 'N';
     p_dsply_lfe := 'N';
     p_dsply_pl_prtt := 'Y';
  else
     p_dsply_disc    := p_dsply_pl_disc_rep;
     p_dsply_recn    := p_dsply_pl_recn_rep;
     p_dsply_lfe     := p_dsply_lfe_rep;
     p_dsply_pl_prtt := p_dsply_pl_prtt_rep;
  end if;
  if p_output_typ = 'CSV' then
     ben_recn_rep.recon_report
          (p_pl_id  		=> p_pl_id  		 ,
           p_pgm_id		=> p_pgm_id		 ,
           p_person_id		=> p_person_id		 ,
           p_per_sel_rule	=> p_per_sel_rule	 ,
           p_business_group_id	=> p_business_group_id	 ,
           p_benefit_action_id	=> p_benefit_action_id	 ,
           p_organization_id	=> p_organization_id	 ,
           p_location_id	=> p_location_id	 ,
           p_ntl_identifier	=> p_ntl_identifier	 ,
           p_rptg_grp_id 	=> p_rptg_grp_id 	 ,
           p_benfts_grp_id 	=> p_benfts_grp_id 	 ,
           p_run_date 		=> p_run_date 		 ,
           p_report_start_date  => p_report_start_date  ,
           p_report_end_date    => p_report_end_date    ,
           p_prem_type		=> p_prem_type		 ,
           p_payroll_id		=> p_payroll_id	 ,
           p_dsply_pl_disc_rep  => p_dsply_pl_disc_rep  ,
           p_dsply_pl_recn_rep  => p_dsply_pl_recn_rep  ,
           p_dsply_pl_prtt_rep  => p_dsply_pl_prtt_rep  ,
           p_dsply_prtt_reps    => p_dsply_prtt_reps    ,
           p_dsply_lfe_rep      => p_dsply_lfe_rep      ,
           p_emp_name_format	=> p_emp_name_format	 ,
     	   p_conc_request_id    => p_conc_request_id    ,
           p_rep_st_dt	  	=> p_rep_st_dt	  	 ,
           p_rep_end_dt	  	=> p_rep_end_dt	 ,
           p_dsply_recn	    	=> p_dsply_recn	 ,
           p_dsply_disc	    	=> p_dsply_disc	 ,
           p_dsply_lfe	    	=> p_dsply_lfe	  	 ,
           p_dsply_pl_prtt  	=> p_dsply_pl_prtt	 ,
	   p_output_typ	 	=> p_output_typ	 ,
           p_op_file_name       => l_op_file_name       );
		p_op_file_name := l_op_file_name;
                p_dsply_disc := 'N';
        p_dsply_recn := 'N';
        p_dsply_lfe := 'N';
        p_dsply_pl_prtt := 'N';

  end if;



  return (TRUE);
end;

function cf_levelformula(levels in varchar2) return number is
l_return number;
begin
  if levels = 'OIPL' then
	p_plan_prtt_subtotal_name := 'Premium for Option in Plan :';
        l_return := 1;
  else
	p_plan_prtt_subtotal_name := 'Premium for Plan :';
        l_return := 2;
  end if;
  return l_return;
end;

function cf_uomformula(pl_sql_uom in varchar2) return number is
begin
  if pl_uom is null then
    pl_uom := pl_sql_uom;
  end if;
  return 1;
end;

function CF_LFE_PRTT_COUNTFormula return Number is
begin
  cp_lfe_prtt_count := cp_lfe_prtt_count +  1;
  return 0;
end;

function cf_1formula(uom2 in varchar2) return number is
begin
  cp_pl_prtt_count := cp_pl_prtt_count + 1;
  if pl_uom is null then
    pl_uom := uom2;
  end if;
  return 1;
end;

function cf_dsicrepencyformula(pay_perd_total1 in number, actual_total1 in number, pl_prem_val1 in number, pl_sql_uom1 in varchar2) return char is
l_output varchar2(100);
begin
    if pay_perd_total1 <> actual_total1 and
     actual_total1 <> pl_prem_val1 then
	l_output := 'SP' ;  elsif pay_perd_total1 <> actual_total1 then
	l_output := 'S';   elsif actual_total1 <> pl_prem_val1 then
	l_output := 'P';   end if;
    cp_pl_recn_prtt_count := cp_pl_recn_prtt_count + 1;
    if pl_uom is null then
    pl_uom := pl_sql_uom1;
  end if;
  return l_output;
end;

function CF_DISC_PRTT_COUNTFormula return Number is
begin
  cp_disc_prtt_count := cp_disc_prtt_count + 1;
   return 1;
end;

function CF_headerFormula return Number is
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
  ben_recn_rep.report_header
     (p_run_date	 => p_run_date
    ,p_person_id	 => p_person_id
    ,p_emp_name_format	 => p_emp_name_format
    ,p_pgm_id		 => p_pgm_id
    ,p_pl_id		 => p_pl_id
    ,p_per_sel_rule_id	 => p_per_sel_rule
    ,p_business_group_id => p_business_group_id
    ,p_organization_id	 => p_organization_id
    ,p_location_id	 => p_location_id
    ,p_benfts_grp_id	 => p_benfts_grp_id
    ,p_rptg_grp_id	 => p_rptg_grp_id
    ,p_prem_type	 => p_prem_type
    ,p_payroll_id	 => p_payroll_id
    ,p_output_typ	 => p_output_typ
    ,p_dsply_pl_disc_rep => p_dsply_pl_disc_rep
    ,p_dsply_pl_recn_rep => p_dsply_pl_recn_rep
    ,p_dsply_pl_prtt_rep => p_dsply_pl_prtt_rep
    ,p_dsply_prtt_reps   => p_dsply_prtt_reps
    ,p_dsply_lfe_rep     => p_dsply_lfe_rep
    ,p_ret_person	 => l_person
    ,p_ret_emp_name_format => l_emp_name_format
    ,p_ret_pgm		   => l_pgm
    ,p_ret_pl		   => l_pl
    ,p_ret_per_sel_rule	   => l_per_sel_rule
    ,p_ret_business_group  => l_business_group
    ,p_ret_organization	   => l_organization
    ,p_ret_location	   => l_location
    ,p_ret_benfts_grp	   => l_benfts_grp
    ,p_ret_rptg_grp	   => l_rptg_grp
    ,p_ret_prem_type	   => l_prem_type
    ,p_ret_payroll	   => l_payroll
    ,p_ret_output_typ	   => l_output_typ
    ,p_ret_dsply_pl_disc_rep => l_dsply_pl_disc_rep
    ,p_ret_dsply_pl_recn_rep => l_dsply_pl_recn_rep
    ,p_ret_dsply_pl_prtt_rep => l_dsply_pl_prtt_rep
    ,p_ret_dsply_prtt_reps   => l_dsply_prtt_reps
    ,p_ret_dsply_lfe_rep     => l_dsply_lfe_rep );
     cp_person		:= l_person;
  cp_emp_name_format	:= l_emp_name_format;
  cp_pgm		:= l_pgm;
  cp_pl		:= l_pl;
  cp_per_sel_rule	:= l_per_sel_rule;
  cp_business_group	:= l_business_group;
  cp_organization	:= l_organization;
  cp_location		:= l_location;
  cp_benfts_grp	:= l_benfts_grp;
  cp_rptg_grp		:= l_rptg_grp;
  cp_prem_type		:= l_prem_type;
  cp_payroll		:= l_payroll;
  cp_output_typ	:= l_output_typ	;
  p_dsply_pl_disc_rep	:= l_dsply_pl_disc_rep;
  p_dsply_pl_recn_rep	:= l_dsply_pl_recn_rep;
  p_dsply_pl_prtt_rep	:= l_dsply_pl_prtt_rep;
  p_dsply_prtt_reps  	:= l_dsply_prtt_reps;
  p_dsply_lfe_rep    	:= l_dsply_lfe_rep;
  cp_ntl_identifier := nvl(p_ntl_identifier,'All');
  return 1;
end;

function BeforeReport return boolean is
l_plip_name varchar2(1000);
l_date varchar2(50);
l_date_dsply boolean;
begin




  /*srw.user_exit('FND SRWINIT');*/null;

P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
  p_date_format := fnd_profile.value('ICX_DATE_FORMAT_MASK');

        if p_pgm_id is not null then
       l_plip_name :=  ben_batch_utils.get_pgm_name(p_pgm_id, p_business_group_id,p_run_date) || ' - ';
    end if;
    l_plip_name :=  l_plip_name || ben_batch_utils.get_pl_name(p_pl_id, p_business_group_id,p_run_date);
    l_date := ' ' || to_char(p_report_start_date,p_date_format)
		|| ' to ' || to_char(p_report_end_date,p_date_format);
    p_plan_recn_rep_header :=  l_plip_name ||' '||p_plan_recn_rep_header|| l_date;
    p_plan_disc_rep_header :=  l_plip_name ||' '||p_plan_disc_rep_header|| l_date;
    p_plan_prtt_rep_header :=  l_plip_name ||' '||p_plan_prtt_rep_header|| l_date;
    p_lfe_rep_header :=  p_lfe_rep_header|| l_date;

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_PL_RECN_PRTT_COUNT_p return number is
	Begin
	 return CP_PL_RECN_PRTT_COUNT;
	 END;
 Function CP_PL_PRTT_COUNT_p return number is
	Begin
	 return CP_PL_PRTT_COUNT;
	 END;
 Function CP_LFE_PRTT_COUNT_p return number is
	Begin
	 return CP_LFE_PRTT_COUNT;
	 END;
 Function CP_DISC_PRTT_COUNT_p return number is
	Begin
	 return CP_DISC_PRTT_COUNT;
	 END;
 Function CP_DSPLY_RECN_p return varchar2 is
	Begin
	 return CP_DSPLY_RECN;
	 END;
 Function CP_DSPLY_DISC_p return varchar2 is
	Begin
	 return CP_DSPLY_DISC;
	 END;
 Function CP_DSPLY_LFE_p return varchar2 is
	Begin
	 return CP_DSPLY_LFE;
	 END;
 Function CP_DSPLY_PL_PRTT_p return varchar2 is
	Begin
	 return CP_DSPLY_PL_PRTT;
	 END;
 Function CP_PERSON_p return varchar2 is
	Begin
	 return CP_PERSON;
	 END;
 Function CP_LOCATION_p return varchar2 is
	Begin
	 return CP_LOCATION;
	 END;
 Function CP_BENFTS_GRP_p return varchar2 is
	Begin
	 return CP_BENFTS_GRP;
	 END;
 Function CP_RPTG_GRP_p return varchar2 is
	Begin
	 return CP_RPTG_GRP;
	 END;
 Function CP_PREM_TYPE_p return varchar2 is
	Begin
	 return CP_PREM_TYPE;
	 END;
 Function CP_OUTPUT_TYP_p return varchar2 is
	Begin
	 return CP_OUTPUT_TYP;
	 END;
 Function CP_EMP_NAME_FORMAT_p return varchar2 is
	Begin
	 return CP_EMP_NAME_FORMAT;
	 END;
 Function CP_PGM_p return varchar2 is
	Begin
	 return CP_PGM;
	 END;
 Function CP_PL_p return varchar2 is
	Begin
	 return CP_PL;
	 END;
 Function CP_PER_SEL_RULE_p return varchar2 is
	Begin
	 return CP_PER_SEL_RULE;
	 END;
 Function CP_BUSINESS_GROUP_p return varchar2 is
	Begin
	 return CP_BUSINESS_GROUP;
	 END;
 Function CP_ORGANIZATION_p return varchar2 is
	Begin
	 return CP_ORGANIZATION;
	 END;
 Function CP_PAYROLL_p return varchar2 is
	Begin
	 return CP_PAYROLL;
	 END;
 Function CP_NTL_IDENTIFIER_p return varchar2 is
	Begin
	 return CP_NTL_IDENTIFIER;
	 END;
END BEN_BENRECON_XMLP_PKG ;

/
