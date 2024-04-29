--------------------------------------------------------
--  DDL for Package Body PER_FR_BIAF_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_FR_BIAF_REPORT" AS
/* $Header: pefrbiaf.pkb 120.11 2006/09/20 20:08:01 aparkes noship $ */

level_cnt NUMBER;
vCtr NUMBER;


PROCEDURE fill_table (p_employee_number IN varchar2,p_bg_id IN NUMBER ,p_asg_id NUMBER,p_effective_date date) is

cursor c_get_data(lp_employee_number varchar2,lp_bg_id number,c_effective_date date) is
select       distinct
             apf.person_id,
             paf.establishment_id est_id,
             paf.contract_id,
             apf.full_name ,
             apf.date_of_birth,
             apf.middle_names,
             apf.per_information1 maiden,
             apf.last_name ,
	     apf.first_name,
	     apf.national_identifier,
	     apf.original_date_of_hire,
             hout.name establishment_name,
	     hla.address_line_1 Number_Road ,
	     hla.address_line_2 Complement ,
	     hla.address_line_3 Other ,
             hla.region_2 INSEE_Code ,
	     hla.region_3 Small_Town ,
	     hla.postal_code Postal_Code ,
             hla.town_or_city City ,
	     hla.region_1 Department ,
	     hla.country Country ,
	     hla.telephone_number_1 Telephone,
             hla.telephone_number_2 Fax,
	     hla.telephone_number_3 Telephone3,
	     pav.address_line1 PNumber_Road,
	     pav.address_line2 PComplement,
	     pav.address_line3 POther,
	     pav.region_2 PINSEE_Code,
	     pav.region_3 PSmall_Town,
	     pav.postal_code PPostal_Code,
	     pav.town_or_city PCity,
	     pav.region_1 PDepartment,
	     pav.country  PCountry,
	     pav.telephone_number_1 PTelephone,
	     pav.telephone_number_2 PFax,
	     pav.telephone_number_3 PTelephone3,
	     hoi.org_information2   siret,
	     hoi.org_information3   NAF,
	     hoi.org_information19  trg_bd_id,
	     pcf.ctr_information3 proposed_end_date,
	     pcf.ctr_information11 durationF,
             pcf.ctr_information12 unitsF ,
	     pcf.duration duration,
	     pcf.duration_units units,
	     pcf.status status,
	     pcf.effective_start_date c_start_date,
	     pcf.effective_end_date   c_end_date,
	     ppos.actual_termination_date actual_termination_date
  from
         hr_locations_all hla,
         hr_all_organization_units hou,
	 hr_all_organization_units_tl hout,
         per_all_assignments_f paf ,
	 per_all_people_f apf,
	 per_addresses  pav,
	 hr_organization_information hoi,
	 per_contracts_f pcf,
	 hr_soft_coding_keyflex hsck,
	 per_periods_of_service ppos
 where hou.organization_id= paf.establishment_id
  and hout.organization_id=hou.organization_id
  and hout.language=userenv('lang')
  and hla.location_id(+)=hou.location_id
  and hoi.organization_id(+)=paf.establishment_id
  and hoi.org_information_context(+) ='FR_ESTAB_INFO'
  and hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id
  and hsck.segment2 <> 'STUDENT'
  and ppos.person_id=paf.person_id
  and ppos.period_of_service_id=paf.period_of_service_id
  and ppos.actual_termination_date is not null
  and paf.person_id=apf.person_id
  and paf.contract_id is not null
  and paf.contract_id = pcf.contract_id
  and paf.person_id=pcf.person_id
  and pcf.ctr_information2 like 'FIXED_TERM'
  and pcf.type not in ('APPRENTICESHIP','ORIENTATION','ADAPTATION','QUALIFICATION')
  and pav.person_id(+)=apf.person_id
  and pav.primary_flag(+)='Y'
  and pav.business_group_id(+)=apf.business_group_id
  and apf.employee_number=lp_employee_number
  and apf.business_group_id=lp_bg_id
  and c_effective_date between apf.effective_start_date and apf.effective_end_date
  and c_effective_date between pcf.effective_start_date and pcf.effective_end_date
  and c_effective_date >= paf.effective_end_date
  and paf.effective_end_date=ppos.actual_termination_date;



 cursor c_trg_addr(l_tr_bd_id number, l_bg_id number)is
  select     hrvt.name trg_bd_name,
	     hla.address_line_1 Number_Road ,
	     hla.address_line_2 Complement ,
	     hla.address_line_3 Other ,
             hla.region_2 INSEE_Code ,
	     hla.region_3 Small_Town ,
	     hla.postal_code Postal_Code ,
             hla.town_or_city City ,
	     hla.region_1 Department ,
	     hla.country Country ,
	     hla.telephone_number_1 Telephone,
             hla.telephone_number_2 Fax,
	     hla.telephone_number_3 Telephone3
from hr_organization_information hoi,
     hr_all_organization_units hrv,
     hr_all_organization_units_tl hrvt,
     hr_locations_all hla
where hoi.ORG_INFORMATION_CONTEXT='CLASS'
and hoi.org_information1='FR_OPAC'
and hrv.business_group_id=l_bg_id
and hrv.organization_id=hoi.organization_id
and hrv.organization_id=l_tr_bd_id
and hla.location_id(+)=hrv.location_id
and hrvt.organization_id=hrv.organization_id
and hrvt.language=userenv('lang');

  cursor c_get_lookup is
  select lookup_code,meaning from hr_lookups
  where lookup_type='BIAF_LOOKUP_CODE';

    lc_trg_addr   c_trg_addr%ROWTYPE;
    l_naf_meaning  varchar2(40);
begin

  ------hr_utility.trace('Into fill_table get_data emp no '||p_employee_number||' BG ID '||to_char(p_bg_id)||' Date '||to_char(p_effective_date));

 PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'report_date';
 PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := to_char(sysdate,'YYYY-MM-DD');
 vCtr:=vCtr+1;

 PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'effective_date';
 PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := to_char(p_effective_date
                                                       ,'YYYY-MM-DD');
 vCtr:=vCtr+1;

 for l_cursor_get_data in c_get_data(p_employee_number,p_bg_id ,p_effective_date)----For each person Body of Template
  loop

   PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'L_REPORT';
   vCtr:=vCtr+1;

   PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'FLAG';
    PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := '1';
    vCtr:=vCtr+1;
   ------hr_utility.trace('Into cursor '||p_employee_number);
  for l_c_get_lookup in c_get_lookup ----From Lookup BIAF_LOOKUP_CODE --
  loop


    PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := l_c_get_lookup.lookup_code;
    PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_c_get_lookup.meaning);
    vCtr:=vCtr+1;


  end loop; ---Label of the template


------------hr_utility.trace('Into fill_table get_data emp no '||(p_employee_number));
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'employee_number';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := p_employee_number;
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'last_name';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.last_name);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'first_name';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.first_name);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'full_name';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.full_name);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'maiden';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.maiden);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'date_of_birth';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := to_char(l_cursor_get_data.date_of_birth,'YYYY-MM-DD');
  vCtr:=vCtr+1;

   PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'national_identifier';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.national_identifier);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'original_date_of_hire';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := to_char(get_contract_start_date(l_cursor_get_data.person_id),'YYYY-MM-DD');
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'contract_start_date';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := to_char(hr_contract_api.get_active_start_date(l_cursor_get_data.contract_id,p_effective_date,l_cursor_get_data.status),'YYYY-MM-DD');
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'contract_end_date';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := to_char(hr_contract_api.get_active_end_date(l_cursor_get_data.contract_id,p_effective_date,l_cursor_get_data.status),'YYYY-MM-DD');
  vCtr:=vCtr+1;

   PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'proposed_end_date';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := to_char(fnd_date.canonical_to_date(l_cursor_get_data.proposed_end_date),'YYYY-MM-DD');
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'duration';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := to_char(l_cursor_get_data.duration);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'unit';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (hr_contract_api.get_meaning(l_cursor_get_data.units,'QUALIFYING_UNITS'));
  vCtr:=vCtr+1;


  -----Person Address Section-------------



  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADP1';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.PNumber_Road);
  vCtr:=vCtr+1;

   PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADP2';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.PComplement);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADP3';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.POther);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADP4';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.PINSEE_Code);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADP5';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.PSmall_Town);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADP6';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.PPostal_Code);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADP7';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.PCity);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADP8';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue :=  (l_cursor_get_data.PDepartment);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADP9';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.PCountry);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADP10';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.PTelephone);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADP11';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue :=(l_cursor_get_data.PFax);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADP12';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.PTelephone3);
  vCtr:=vCtr+1;

-----------END OF PERSONAL ADDRESS--------------------------------------------------------



  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'siret';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.siret);
  vCtr:=vCtr+1;

   select meaning into l_naf_meaning from fnd_common_lookups where lookup_type='FR_NAF_CODE'
   and lookup_code=l_cursor_get_data.NAF;

   PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ape';
   PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_naf_meaning);
   vCtr:=vCtr+1;




  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'establishment_headcount';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue :=to_char( get_emp_total(lp_effective_date   =>l_cursor_get_data.actual_termination_date, --get_contract_start_date(l_cursor_get_data.person_id),
                                                                       lp_est_id           =>l_cursor_get_data.est_id ,
                                                                      -- lp_ent_id           =>null,
                                                                      -- lp_sex              =>null,
                                                                       lp_udt_column       => 'INCLUDE_DUE'
								      -- lp_include_suspended =>'Y'
								       ));
   vCtr:=vCtr+1;
                       hr_utility.trace('Establishment Headcount ');

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'establishment_name';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.establishment_name);
  vCtr:=vCtr+1;

  ------ESTABLISHMENT ADDRESS SECTION---------------------------------------

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADE1';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.Number_Road);
  vCtr:=vCtr+1;

   PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADE2';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.Complement);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADE3';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.Other);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADE4';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.INSEE_Code);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADE5';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.Small_Town);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADE6';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.Postal_Code);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADE7';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.City);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADE8';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue :=  (l_cursor_get_data.Department);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADE9';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.Country);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADE10';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.Telephone);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADE11';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue :=(l_cursor_get_data.Fax);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADE12';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_cursor_get_data.Telephone3);
  vCtr:=vCtr+1;

  -----------------------END OF ESTABLISHMENT ADDRESS--------------------

/*
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'establishment_address';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (l_establishment_address);
  vCtr:=vCtr+1; */

  -----------------------TRAINING BODY ADDRESS SECTION---------------------

  open  c_trg_addr(l_cursor_get_data.trg_bd_id, p_bg_id);
  fetch c_trg_addr into lc_trg_addr;

    hr_utility.trace('Training Address ');

   PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'tax_paid_to';
   PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (lc_trg_addr.trg_bd_name);
   vCtr:=vCtr+1;


  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADT1';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (lc_trg_addr.Number_Road);
  vCtr:=vCtr+1;

   PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADT2';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (lc_trg_addr.Complement);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADT3';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (lc_trg_addr.Other);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADT4';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (lc_trg_addr.INSEE_Code);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADT5';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (lc_trg_addr.Small_Town);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADT6';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (lc_trg_addr.Postal_Code);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADT7';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (lc_trg_addr.City);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADT8';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue :=  (lc_trg_addr.Department);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADT9';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (lc_trg_addr.Country);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADT10';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (lc_trg_addr.Telephone);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADT11';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue :=(lc_trg_addr.Fax);
  vCtr:=vCtr+1;

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'ADT12';
  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagValue := (lc_trg_addr.Telephone3);
  vCtr:=vCtr+1;
  close c_trg_addr; --Cursor for each person Traning Body Address

  PER_FR_BIAF_REPORT.vXMLTable(vCtr).TagName := 'L_REPORT';
  vCtr:=vCtr+1;

end loop;----For each Person
end fill_table;


FUNCTION get_emp_total (lp_effective_date    IN DATE,
                        lp_est_id            IN NUMBER ,
                        --lp_ent_id            IN NUMBER ,
                       -- lp_sex               IN VARCHAR2,
                        lp_udt_column        IN VARCHAR2
                       -- lp_include_suspended IN VARCHAR2
			) RETURN NUMBER IS
--
CURSOR c_get_total(p_effective_date    IN DATE ,
                        p_est_id            IN NUMBER ,
                      -- p_ent_id            IN NUMBER ,
                       -- p_sex               IN VARCHAR2 ,
                        p_udt_column        IN VARCHAR2
                        --p_include_suspended IN VARCHAR2
			) IS
SELECT COUNT(asg.assignment_id)
FROM   per_all_assignments_f       asg,
       per_assignment_status_types ast,
     --  per_person_types_v pt,
       per_all_people_f            peo
WHERE  asg.establishment_id=p_est_id
AND    asg.person_id = peo.person_id
AND    (ast.per_system_status IN ('ACTIVE_ASSIGN','SUSP_ASSIGN')) -- AND p_include_suspended = 'Y')
AND    asg.assignment_status_type_id = ast.assignment_status_type_id
AND    asg.primary_flag = 'Y'
and    exists ( select null
                 from per_person_type_usages_f pf,
		      per_person_types pt
		 where pf.person_id=peo.person_id
		 and   pf.person_type_id = pt.person_type_id
		 --and   pt.language=userenv('lang')
		 and   'Y' = pefrusdt.get_table_value(peo.business_group_id
                                     ,'FR_USER_PERSON_TYPE'
                                     ,p_udt_column
                                     ,pt.user_person_type
                                     ,p_effective_date)
		 and p_effective_date between pf.effective_start_date and pf.effective_end_date
				     )
/*AND    peo.person_type_id = pt.person_type_id
AND    'Y' = pefrusdt.get_table_value(peo.business_group_id
                                     ,'FR_USER_PERSON_TYPE'
                                     ,p_udt_column
                                     ,pt.user_person_type
                                     ,p_effective_date)*/
AND    p_effective_date >= asg.effective_start_date
AND    p_effective_date <= asg.effective_end_date
AND    p_effective_date >= peo.effective_start_date
AND    p_effective_date <= peo.effective_end_date;
/*
AND   (LEAST(asg.effective_end_date,peo.effective_end_date) > p_effective_date
       OR EXISTS (SELECT null
                  FROM   per_all_assignments_f       asg2,
                         per_assignment_status_types ast2,
                        -- per_person_types_v          pt2,
                         per_all_people_f            peo2
                  WHERE  asg2.establishment_id =p_est_id
                  AND    asg2.person_id = peo.person_id
                  AND    asg2.person_id = peo2.person_id
                  AND    (ast2.per_system_status IN ('ACTIVE_ASSIGN','SUSP_ASSIGN') AND p_include_suspended = 'Y')
                  AND    asg2.assignment_status_type_id = ast2.assignment_status_type_id
                  AND    asg2.primary_flag = 'Y'
		  and    exists ( select null
                                  from per_person_type_usages_f pf2, per_person_types pt2
		                       where pf2.person_id=peo2.person_id
		                       and   pf2.person_type_id = pt2.person_type_id
		                       and   'Y' = pefrusdt.get_table_value(peo2.business_group_id
                                                                            ,'FR_USER_PERSON_TYPE'
                                                                            ,p_udt_column
                                                                            ,pt2.user_person_type
                                                                            ,p_effective_date)
				     )
                  /*AND    peo2.person_type_id = pt2.person_type_id
                  AND    'Y' = pefrusdt.get_table_value(peo2.business_group_id
                                                        ,'FR_USER_PERSON_TYPE'
                                                        ,p_udt_column
                                                        ,pt2.user_person_type
                                                        ,p_effective_date)
                  AND    p_effective_date+1 >= asg2.effective_start_date
                  AND    p_effective_date+1 <= asg2.effective_end_date
                  AND    p_effective_date+1 >= peo2.effective_start_date
                  AND    p_effective_date+1 <= peo2.effective_end_date)
      ); */
--
l_total        NUMBER:=0;

--
BEGIN
  --
  OPEN c_get_total(lp_effective_date,lp_est_id,lp_udt_column);
  FETCH c_get_total INTO l_total;
  CLOSE c_get_total;
  --
  RETURN l_total;
  --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
       CLOSE c_get_total;
       RETURN(0);
end get_emp_total;




FUNCTION  get_contract_start_date(f_person_id IN number) return date
is
    cursor get_date(f_person_id number) is
     select pcf.effective_start_date,
            pcf.effective_end_date
     from per_contracts_f pcf ,
          per_all_assignments_f paf,
	  per_all_people_f ppf
     where ppf.person_id=f_person_id
	 and paf.person_id=ppf.person_id
	 and paf.contract_id(+)=pcf.contract_id
	 and pcf.effective_start_date=(select min(pcf1.effective_start_date)
	                               from  per_contracts_f pcf1
	                               where pcf1.contract_id=pcf.contract_id);

     l_start_date date;
     l_end_date   date;
 begin

  open get_date(f_person_id);
  fetch get_date into l_start_date,l_end_date;
  close get_date;

 return l_start_date;
end get_contract_start_date;




FUNCTION  get_contract_end_date(f_person_id IN number) return date
 is
    cursor get_date(f_person_id number) is
     select active_end_date
     from per_contracts
     where person_id=f_person_id
           and active_start_date=( select max(active_end_date) from
                                  per_contracts where person_id=f_person_id);

    l_end_date date;
 begin

   open get_date(f_person_id);
   fetch get_date into l_end_date;
   close get_date;

   return l_end_date;
end get_contract_end_date;



PROCEDURE POPULATE_REPORT_DATA(p_employee_number IN varchar2,p_bg_id IN NUMBER ,p_asg_id NUMBER,p_asg_emp varchar2 ,p_effective_date varchar2 ,p_xfdf_blob OUT NOCOPY BLOB) IS

/* cursor c_get_data(lp_person_id number) is
 select apf.full_name ,apf.last_name ,apf.first_name, apf.national_identifier,apf.original_date_of_hire  from
  per_all_people_f apf where apf.person_id=lp_person_id;*/

cursor c_asg_set1(l_asg_id number,l_bg_id number, p_effective_date date) is
 select distinct paf.person_id ,l_asg_id ,pef.employee_number
 from  per_all_assignments_f paf,
       hr_assignment_sets hs,
       per_all_people_f pef
 where hs.assignment_set_id=l_asg_id
 and nvl(hs.payroll_id,paf.payroll_id)=paf.payroll_id
 and hs.business_group_id=paf.business_group_id
 and pef.person_id=paf.person_id
 and paf.business_group_id=l_bg_id
 and paf.assignment_id  in ( select assignment_id
                                 from  hr_assignment_set_amendments hsa
                                 where hsa.assignment_set_id =l_asg_id
                                 and hsa.include_or_exclude='I')
 and p_effective_date between pef.effective_start_date and pef.effective_end_date ;


cursor c_asg_set2(l_asg_id number,l_bg_id number, p_effective_date date) is
 select distinct paf.person_id ,l_asg_id ,pef.employee_number
 from per_all_assignments_f paf,
      hr_assignment_sets hs,
      per_all_people_f pef
 where hs.assignment_set_id=l_asg_id
 and hs.business_group_id=paf.business_group_id
 and nvl(hs.payroll_id,paf.payroll_id)=paf.payroll_id
 and pef.person_id=paf.person_id
 and paf.business_group_id=l_bg_id
 and paf.assignment_id not in ( select assignment_id
                                 from  hr_assignment_set_amendments hsa
                                 where hsa.assignment_set_id =l_asg_id
                                 and hsa.include_or_exclude='E')
 and p_effective_date between pef.effective_start_date and pef.effective_end_date ;

  cursor c_asg_amendments is
  select /*count(hsa.include_or_exclude) cnt , */ hsa.include_or_exclude ioe
    from  hr_assignment_set_amendments hsa
    where hsa.assignment_set_id =p_asg_id;
   -- group by hsa.include_or_exclude;

 /*
 UNION
 select paf.person_id ,l_asg_id ,pef.employee_number
 from per_all_assignments_f paf,hr_assignment_sets hs,per_all_people_f pef
 where hs.assignment_set_id=l_asg_id
 and hs.payroll_id is null
 and hs.business_group_id=paf.business_group_id
 and pef.person_id=paf.person_id
 and paf.business_group_id= l_bg_id
 and paf.assignment_id not in ( select assignment_id from  hr_assignment_set_amendments hsa
                                 where hsa.assignment_set_id =hs.assignment_set_id
                                  and hsa.include_or_exclude='E'
                                  )
 and p_effective_date between pef.effective_start_date and pef.effective_end_date
 and p_effective_date between paf.effective_start_date and paf.effective_end_date ;
 */
  l_c_asg_amendments c_asg_amendments%ROWTYPE ;
  l_establishment_address varchar2(1000);
  l_person_address   varchar2(1000);
  l_effective_date   date;
  l_ioex varchar2(1);
  l_count number;
  begin

 l_effective_date:=trunc(fnd_date.canonical_to_date(p_effective_date));



  --hr_utility.trace_on(null,'BIAF1');
  PER_FR_BIAF_REPORT.vXMLTable.DELETE;
  vCtr:=0;

  hr_utility.TRACE('Effective Date ' || to_char(l_effective_date));
  ------hr_utility.TRACE('Business Group ID ' || p_bg_id);
  ------hr_utility.TRACE('Assignment Or Employee ' || p_asg_emp);


if (p_asg_emp='A') then

  open c_asg_amendments;
  fetch c_asg_amendments into l_c_asg_amendments;


   if (c_asg_amendments%FOUND) then

   if (l_c_asg_amendments.ioe='I' /*and l_c_asg_amendments.cnt > 0*/) then
     for l_c_asg_set in c_asg_set1(p_asg_id,p_bg_id,l_effective_date) ----Assignment Set Loop
      loop
    ------hr_utility.TRACE('Inside assignment Set ' );

       hr_utility.TRACE('Employee Number ' || to_char(l_c_asg_set.employee_number));
       fill_table(l_c_asg_set.employee_number,p_bg_id,p_asg_id,l_effective_date);

     end loop ; ----For Assignment Set
    end if;

    if (l_c_asg_amendments.ioe='E' /* and l_c_asg_amendments.cnt > 0*/) then

       for l_c_asg_set in c_asg_set2(p_asg_id,p_bg_id,l_effective_date) ----Assignment Set Loop
      loop
    ------hr_utility.TRACE('Inside assignment Set ' );

       hr_utility.TRACE('Employee Number2 ' || to_char(l_c_asg_set.employee_number));
       fill_table(l_c_asg_set.employee_number,p_bg_id,p_asg_id,l_effective_date);

     end loop ; ----For Assignment Set
    end if;


   else    ---- No amendment is mentioned
     for l_c_asg_set in c_asg_set2(p_asg_id,p_bg_id,l_effective_date) ----Assignment Set Loop
      loop
    ------hr_utility.TRACE('Inside assignment Set ' );

       hr_utility.TRACE('Employee Number3 ' || to_char(l_c_asg_set.employee_number));
       fill_table(l_c_asg_set.employee_number,p_bg_id,p_asg_id,l_effective_date);

     end loop ; ----For Assignment Set
   end if;

   close c_asg_amendments;
else
 hr_utility.TRACE('Employee Number4 ' || to_char(p_employee_number));
 fill_table(p_employee_number,p_bg_id,p_asg_id,l_effective_date);

end if;

--hr_utility.TRACE('Counter ' || (vCtr));

PER_FR_BIAF_REPORT.WritetoCLOB (p_xfdf_blob );



end POPULATE_REPORT_DATA;




PROCEDURE WritetoCLOB (p_xfdf_blob out nocopy blob) IS

l_xfdf_string clob;
l_str1 varchar2(1000);
l_str2 varchar2(20);
l_str3 varchar2(20);
l_str4 varchar2(20);
l_str5 varchar2(20);
l_str6 varchar2(30);
l_str7 varchar2(1000);
l_str8 varchar2(1000);
l_str9 varchar2(1000);
l_boo   number :=1;
begin
----------hr_utility.set_location('Entered Procedure Write to clob ',100);
	l_str1 := '<?xml version="1.0" encoding="UTF-8"?>
	       		 <FIELDS> ';
       			-- <fields> ' ;
	l_str2 := '<';
	l_str3 := '>';
--	l_str4 := '</xfdf>' ;
	l_str5 := '</' ;
	l_str6 := '</FIELDS> ';
	l_str7 := '<?xml version="1.0" encoding="UTF-8"?>
		       		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       			 </xfdf>';
	dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
	dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
	----hr_utility.TRACE('TAble count :'||(vXMLTable.count));
	if vXMLTable.count > 2 then
		dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );
		--hr_utility.trace(l_str1);
        	FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
        		l_str8 := vXMLTable(ctr_table).TagName;
        		l_str9 := vXMLTable(ctr_table).TagValue;

        		IF (l_str8='L_REPORT') THEN

				  IF (l_boo=1) THEN
        		    dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2 );--- <
				    dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);------ name
				    dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );---->
				    --hr_utility.trace(l_str2||l_str8||l_str3);
			      ELSE
				    dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5 );---- </
				    dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);----- name
				    dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );----- >
				    --hr_utility.trace(l_str5||l_str8||l_str3);
				  END IF;
				     l_boo:=l_boo*(-1);
				END IF;


        		if ((l_str9 is not null)and (l_str8 not like 'L_REPORT')) then
				dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2 );--- <
				dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);------ name
				dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );---->
				--dbms_lob.writeAppend( l_xfdf_string, length(l_str4), l_str4 );
				dbms_lob.writeAppend( l_xfdf_string, length(l_str9), l_str9);-----value
				dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5 );---- </
				dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);----- name
				dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );----- >
                 --hr_utility.trace(l_str2||l_str8||l_str3||l_str9||l_str5||l_str8||l_str3);
			 else
			    null;
		  end if;

		END LOOP;
		dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6 );
	--hr_utility.trace(l_str6);
	else
		dbms_lob.writeAppend( l_xfdf_string, length(l_str7), l_str7 );
		--hr_utility.trace(l_str7);
	end if;
	DBMS_LOB.CREATETEMPORARY(p_xfdf_blob,TRUE);
	clob_to_blob(l_xfdf_string,p_xfdf_blob);
	----hr_utility.set_location('Finished Procedure Write to CLOB ,Before clob to blob ',110);
	--return p_xfdf_blob;
	EXCEPTION
		WHEN OTHERS then
		 ----hr_utility.TRACE('sqleerm ' || SQLERRM);
	     ----hr_utility.RAISE_ERROR;
         null;
END WritetoCLOB;



Procedure  clob_to_blob(p_clob clob,
                          p_blob IN OUT NOCOPY Blob)
  is
    l_length_clob number;
    l_offset pls_integer;
    l_varchar_buffer varchar2(32767);
    l_raw_buffer raw(32767);
    l_buffer_len number:= /*32000*/ 20000;
    l_chunk_len number;
    l_blob blob;
    g_nls_db_char varchar2(60);

    l_raw_buffer_len pls_integer;
    l_blob_offset pls_integer := 1;

  begin
  	hr_utility.set_location('Entered Procedure clob to blob',120);
	select userenv('LANGUAGE') into g_nls_db_char from dual;
  	l_length_clob := dbms_lob.getlength(p_clob);
	l_offset := 1;
	while l_length_clob > 0 loop
		hr_utility.trace('l_length_clob '|| l_length_clob);
		if l_length_clob < l_buffer_len then
			l_chunk_len := l_length_clob;
		else
                        l_chunk_len := l_buffer_len;
		end if;
		DBMS_LOB.READ(p_clob,l_chunk_len,l_offset,l_varchar_buffer);
               -- fnd_file.put_line(fnd_file.log,l_varchar_buffer);
                l_raw_buffer := utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.AL32UTF8',g_nls_db_char);

                l_raw_buffer_len := utl_raw.length(utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.AL32UTF8',g_nls_db_char));


--              dbms_lob.write(p_blob,l_chunk_len, l_offset, l_raw_buffer);
                dbms_lob.write(p_blob,l_raw_buffer_len, l_blob_offset, l_raw_buffer);
		--fnd_file.put_line(fnd_file.log,l_varchar_buffer);
                l_blob_offset := l_blob_offset + l_raw_buffer_len;
            	l_offset := l_offset + l_chunk_len;
	        l_length_clob := l_length_clob - l_chunk_len;
                hr_utility.trace('l_length_blob '|| dbms_lob.getlength(p_blob));
	end loop;
	hr_utility.set_location('Finished Procedure clob to blob ',130);
  end;


end PER_FR_BIAF_REPORT;



/
