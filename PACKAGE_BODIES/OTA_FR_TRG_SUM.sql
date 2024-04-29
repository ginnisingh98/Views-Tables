--------------------------------------------------------
--  DDL for Package Body OTA_FR_TRG_SUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FR_TRG_SUM" AS
/* $Header: otfrtrgsm.pkb 120.0.12010000.2 2008/11/28 05:39:04 parusia noship $ */

vCtr NUMBER;
g_utf8  boolean;
g_catg1_t number:=0;
g_catg2_t number:=0;
g_catg3_t number:=0;
g_catg1_o number:=0;
g_catg2_o number:=0;
g_catg3_o number:=0;


function get_lookup_value(p_lookup_type varchar2,
                          p_lookup_code  varchar2)return varchar2 IS
l_lookup_meaning varchar2(80);
begin

 select meaning into l_lookup_meaning
   from hr_lookups
   where lookup_type=p_lookup_type
   and   lookup_code=p_lookup_code;

   return l_lookup_meaning ;
end get_lookup_value;


function xml_d(p_data varchar2)return varchar2 is
l_data varchar2(1000);
begin
  if g_utf8 then
    l_data:= convert(p_data,'UTF8');
  else
   l_data:= p_data;
  end if;
  return l_data;
end xml_d;


procedure xml_t    (p_xml            in out nocopy clob,
                    p_tag           varchar2) is
begin

    dbms_lob.writeappend(p_xml, length(p_tag), p_tag);

end xml_t;



procedure xml_utf8(p_xml in out nocopy clob)
is
  cursor csr_get_lookup(p_lookup_type    varchar2
                       ,p_lookup_code    varchar2
                       ,p_view_app_id    number default 3) is
  select meaning,tag
  FROM   fnd_lookup_values flv
  WHERE  lookup_type         = p_lookup_type
  AND    lookup_code         = p_lookup_code
  AND    language            = userenv('LANG')
  AND    view_application_id = p_view_app_id
  and    SECURITY_GROUP_ID   = decode(substr(userenv('CLIENT_INFO'),55,1),
                                 ' ', 0,
                                 NULL, 0,
                                 '0', 0,
                                 fnd_global.lookup_security_group(
                                     FLV.LOOKUP_TYPE,FLV.VIEW_APPLICATION_ID));
  rec_lookup  csr_get_lookup%ROWTYPE;
  --
begin
  open csr_get_lookup('FND_ISO_CHARACTER_SET_MAP',
                  substr(USERENV('LANGUAGE'),instr(USERENV('LANGUAGE'),'.')+1),
                  0);
  fetch csr_get_lookup into rec_lookup;
  close csr_get_lookup;
  --
  if rec_lookup.tag is null then
    g_utf8 := TRUE;
  else
    g_utf8 := FALSE;
  end if;
  xml_t(p_xml,'<?xml version="1.0" encoding="'||
                 nvl(rec_lookup.tag,'UTF-8')||'" ?>');
  hr_utility.trace('<?xml version="1.0" encoding="'||
                 nvl(rec_lookup.tag,'UTF-8')||'" ?>');
--
end  xml_utf8;

--

PROCEDURE POPULATE_REPORT_DATA(P_ASG_NUM  IN varchar2,
                               dummy      IN varchar2,
			       dummy1     IN varchar2,
                               P_COMPANY_ID IN NUMBER ,
                               P_ESTABLISHMENT_ID IN NUMBER ,
			       P_BUSINESS_GROUP_ID IN NUMBER,
			       P_ASSIGNMENT_SET_ID IN NUMBER,
			       P_PERSON_ID IN NUMBER ,
			       P_DATE_FROM IN VARCHAR2 default NULL,
			       P_DATE_TO IN VARCHAR2 default NULL,
			       P_TEMPLATE_NAME IN VARCHAR2 ,
			       P_SORT_ORDER IN VARCHAR2,
			       p_xml OUT NOCOPY CLOB
			       )IS

TYPE ref_cur IS REF CURSOR;
c_ref_cur ref_cur;

TYPE rec IS RECORD
(
person_id per_all_people_f.person_id%TYPE,
employee_number per_all_people_f.employee_number%TYPE,
full_name    per_all_people_f.full_name%TYPE
);


  cursor c_asg_amendments is
  select  hsa.include_or_exclude ioe
    from  hr_assignment_set_amendments hsa
    where hsa.assignment_set_id =p_assignment_set_id;

  p_asg_emp varchar2(30);
  l_c_asg_amendments c_asg_amendments%ROWTYPE ;
  l_date_from date;
  l_date_to date;
  l_c_asg_set rec;


BEGIN

-- hr_utility.trace_on(NULL,'TRG');
  dbms_lob.createtemporary(p_xml, TRUE, dbms_lob.session);
  dbms_lob.open(p_xml,dbms_lob.lob_readwrite);
  xml_utf8(p_xml);
  xml_t(p_xml,'<REPORT>');
  l_date_from:=trunc(fnd_date.canonical_to_date(p_date_from));
  l_date_to:=trunc(fnd_date.canonical_to_date(p_date_to));

  --OTA_FR_TRG_SUM.vXMLTable.DELETE;
   --vCtr:=0;

  hr_utility.TRACE('l_date_to ' || to_char(l_date_to,'YYYY-MON-DD'));


if (p_asg_num='A') then

  open c_asg_amendments;
  fetch c_asg_amendments into l_c_asg_amendments;


  if (c_asg_amendments%FOUND) then

   if (l_c_asg_amendments.ioe='I' /*and l_c_asg_amendments.cnt > 0*/) then

       open c_ref_cur for   -- ASG 1
      'select distinct paf.person_id person_id ,pef.employee_number employee_number,pef.full_name full_name
         from  per_all_assignments_f paf,
               hr_assignment_sets hs,
               per_all_people_f pef,
	        per_periods_of_service ppos
         where hs.assignment_set_id=:p_assignment_set_id
         and nvl(hs.payroll_id,paf.payroll_id)=paf.payroll_id
         and hs.business_group_id=paf.business_group_id
         and pef.person_id=paf.person_id
         and paf.business_group_id=:p_business_group_id
         and paf.business_group_id=pef.business_group_id
         and paf.assignment_id  in ( select assignment_id
                                 from  hr_assignment_set_amendments hsa
                                 where hsa.assignment_set_id =:p_assignment_set_id
                                 and hsa.include_or_exclude=''I'')
	  and   ppos.person_id=pef.person_id
          and   ppos.period_of_service_id=paf.period_of_service_id
          and   :l_date_from <=nvl(ppos.actual_termination_date,to_date(''31-12-4712'',''DD-MM-YYYY''))
         and    :l_date_to between pef.effective_start_date and pef.effective_end_date
         and   ((:l_date_to between paf.effective_start_date and paf.effective_end_date)
	         or
	       (:l_date_to >= (select max(effective_end_date)
                                            from per_all_assignments_f p1    /*To include TERMINATED employee*/
				            where p1.person_id=pef.person_id))
					    )
	     ORDER BY '||p_sort_order
		 using p_assignment_set_id,p_business_group_id,p_assignment_set_id,l_date_from,l_date_to,l_date_to,l_date_to;

   --  for l_c_asg_set in c_asg_set1 ----Assignment Set Loop
       loop
         fetch c_ref_cur into l_c_asg_set ;
         exit when c_ref_cur%NOTFOUND;
         make_employee(l_c_asg_set.person_id,l_date_from,l_date_to,p_xml);
       end loop ; ----For Assignment Set
    end if;

    if (l_c_asg_amendments.ioe='E' /* and l_c_asg_amendments.cnt > 0*/) then
       open c_ref_cur for
       'select distinct paf.person_id person_id  ,pef.employee_number employee_number,pef.full_name full_name
            from per_all_assignments_f paf,
                 hr_assignment_sets hs,
                 per_all_people_f pef,
		  per_periods_of_service ppos
           where hs.assignment_set_id=:p_assignment_set_id
           and hs.business_group_id=paf.business_group_id
           and nvl(hs.payroll_id,paf.payroll_id)=paf.payroll_id
           and pef.person_id=paf.person_id
           and paf.business_group_id=:p_business_group_id
           and paf.business_group_id=pef.business_group_id
           and paf.assignment_id not in ( select assignment_id
                                 from  hr_assignment_set_amendments hsa
                                 where hsa.assignment_set_id =:p_assignment_set_id
                                 and hsa.include_or_exclude=''E'')
	    and   ppos.person_id=pef.person_id
            and   ppos.period_of_service_id=paf.period_of_service_id
            and   :l_date_from <=nvl(ppos.actual_termination_date,to_date(''31-12-4712'',''DD-MM-YYYY''))
            and   :l_date_to between pef.effective_start_date and pef.effective_end_date
            and  ((:l_date_to between paf.effective_start_date and paf.effective_end_date)
	         or
	        (:l_date_to >= (select max(effective_end_date)
                                            from per_all_assignments_f p1    /*To include TERMINATED employee*/
				            where p1.person_id=pef.person_id))
					    )
		   ORDER BY '||p_sort_order
		   using p_assignment_set_id,p_business_group_id,p_assignment_set_id,l_date_from,l_date_to,l_date_to,l_date_to;

      loop
       fetch c_ref_cur into l_c_asg_set ;
         exit when c_ref_cur%NOTFOUND;
         make_employee(l_c_asg_set.person_id,l_date_from,l_date_to,p_xml);
     end loop ; ----For Assignment Set
    end if;
   else
	---- No amendment is mentioned
           open c_ref_cur for
       'select distinct paf.person_id  ,pef.employee_number employee_number,pef.full_name full_name
            from per_all_assignments_f paf,
                 hr_assignment_sets hs,
                 per_all_people_f pef,
		  per_periods_of_service ppos
           where hs.assignment_set_id=:p_assignment_set_id
           and hs.business_group_id=paf.business_group_id
           and nvl(hs.payroll_id,paf.payroll_id)=paf.payroll_id
           and pef.person_id=paf.person_id
           and paf.business_group_id=:p_business_group_id
           and paf.business_group_id=pef.business_group_id
           and paf.assignment_id not in ( select assignment_id
                                 from  hr_assignment_set_amendments hsa
                                 where hsa.assignment_set_id =:p_assignment_set_id
                                 and hsa.include_or_exclude=''E'')
	    and   ppos.person_id=pef.person_id
            and   ppos.period_of_service_id=paf.period_of_service_id
            and   :l_date_from <=nvl(ppos.actual_termination_date,to_date(''31-12-4712'',''DD-MM-YYYY''))
            and   :l_date_to between pef.effective_start_date and pef.effective_end_date
            and  ((:l_date_to between paf.effective_start_date and paf.effective_end_date)
	         or
	        (:l_date_to >= (select max(effective_end_date)
                                            from per_all_assignments_f p1    /*To include TERMINATED employee*/
				            where p1.person_id=pef.person_id))
					    )
		   ORDER BY '||p_sort_order
		   using p_assignment_set_id,p_business_group_id,p_assignment_set_id,l_date_from,l_date_to,l_date_to,l_date_to;

      loop
       fetch c_ref_cur into l_c_asg_set ;
         exit when c_ref_cur%NOTFOUND;
         make_employee(l_c_asg_set.person_id,l_date_from,l_date_to,p_xml);
     end loop ; ----For Assignment Set
   end if;

   close c_asg_amendments;
else

 open c_ref_cur for
 'Select DISTINCT pap.person_id person_id,pap.employee_number employee_number,pap.full_name full_name
  from per_all_people_f pap,
       per_all_assignments_f paa,
       hr_all_organization_units hao,
       hr_organization_information hoi,
       per_periods_of_service ppos
  where pap.person_id =paa.person_id
  and   pap.business_group_id=:l_business_group_id
  and   pap.business_group_id=paa.business_group_id
  and   pap.person_id=nvl(:l_person_id,pap.person_id)
  and   paa.establishment_id=nvl(:l_establishment_id,paa.establishment_id)
  and   paa.establishment_id=hao.organization_id
  and   hoi.organization_id=hao.organization_id
  and   hoi.org_information_context =''FR_ESTAB_INFO''
  and   hoi.org_information1=nvl(:l_company_id,hoi.org_information1)
  and   ppos.person_id=pap.person_id
  and   ppos.period_of_service_id=paa.period_of_service_id
  and   :l_date_from <=nvl(ppos.actual_termination_date,to_date(''31-12-4712'',''DD-MM-YYYY''))
  and   :l_date_to between pap.effective_start_date and pap.effective_end_date
  and  ((:l_date_to between paa.effective_start_date and paa.effective_end_date)
	         or
	(:l_date_to >= (select max(effective_end_date)
                                            from per_all_assignments_f p1    /*To include TERMINATED employee*/
				            where p1.person_id=pap.person_id))
					    )
  ORDER BY '||p_sort_order
  using
  p_business_group_id,p_person_id,p_establishment_id,p_company_id,l_date_from,l_date_to,l_date_to,l_date_to;

  loop

       fetch c_ref_cur into l_c_asg_set ;
         exit when c_ref_cur%NOTFOUND;
         make_employee(l_c_asg_set.person_id,l_date_from,l_date_to,p_xml);
  end loop ;

end if;
xml_t(p_xml,'</REPORT>');
--WritetoCLOB(p_xml);

END POPULATE_REPORT_DATA ;



PROCEDURE make_employee ( L_P_PERSON_ID IN NUMBER,
                          L_P_DATE_FROM IN DATE ,
			  L_P_DATE_TO IN DATE,
			  p_xml   in out nocopy clob
                        )
		      IS

CURSOR c_emp_h is
  select  distinct papf.full_name EMP_NAME,
         papf.employee_number EMP_NUM,
	 pa.address_line1||' '||pa.address_line2||' '|| pa.address_line3 ||' '|| pa.region_2 ||' '||
	 pa.region_3 ||' '|| pa.postal_code ||' '|| pa.town_or_city||' '|| pa.region_1 ||' '||pa.country
	 ||' '||pa.telephone_number_1||' '|| pa.telephone_number_2||' '||pa.telephone_number_3  E_ADDRESS,
	 to_char(papf.original_date_of_hire,'YYYY-MM-DD') HIRE_DATE,
         to_char(ppos.adjusted_svc_date,'YYYY-MM-DD') ADJUSTED_SVC_DATE,
	 to_char(ppos.actual_termination_date,'YYYY-MM-DD') TERM_DATE,
         OTA_FR_TRG_SUM.get_lookup_value('FR_CONTRACT_CATEGORY',pcf.ctr_information2)  CONTRACT_CATEGORY,
	 pcf.type  CONTRACT_TYPE,
	 case
	 when pcf.ctr_information11 is null then
         paaf.normal_hours
	 else
	 fnd_number.canonical_to_number(pcf.ctr_information11)
	 end CONT_WRK_HRS,---CONTRACTUAL_WORKING_HOURS                  --It is the hours in the DDF segment with unit ,display unit also
         case
	 when pcf.ctr_information11 is null then
         OTA_FR_TRG_SUM.get_lookup_value('FREQUENCY',paaf.frequency)
	 else
	 OTA_FR_TRG_SUM.get_lookup_value('FR_FIXED_TIME_UNITS',pcf.ctr_information12)
	 end CONT_WRK_UNT, --Contractual working hours unit
	 pca.name COLLECTIVE_AGREEMENT,
	 paaf.assignment_category ASSGN_CATEGORY,
	 to_char(L_P_DATE_FROM,'YYYY-MM-DD') PERIOD_FROM,
	 to_char(L_P_DATE_TO,'YYYY-MM-DD')   PERIOD_TO,
	 hout1.name EST_NAME,
	 hla1.address_line_1||' '||hla1.address_line_2||' '||hla1.address_line_3||' '||hla1.region_2
	 ||' '||hla1.region_3||' '||hla1.postal_code||' '||hla1.town_or_city||' '||hla1.region_1||' '||
	 hla1.country||' '||hla1.telephone_number_1||' '||hla1.telephone_number_2||' '||
	 hla1.telephone_number_3 EST_ADDRESS,
	 hoi1.org_information2 SIRET,
	 hout2.name COM_NAME,
         hla2.address_line_1||' '||hla2.address_line_2||' '||hla2.address_line_3||' '||
	 hla2.region_2||' '||hla2.region_3||' '||hla2.postal_code||' '||hla2.town_or_city||' '||
	 hla2.region_1||' '||hla2.country||' '||hla2.telephone_number_1||' '||hla2.telephone_number_2||' '||
	 hla2.telephone_number_3 COM_ADDRESS
   from per_all_people_f papf,
        per_addresses pa,
	per_all_assignments_f paaf,
	per_periods_of_service ppos,
	per_contracts_f pcf,
	per_collective_agreements pca,
	hr_all_organization_units hou1,
	hr_all_organization_units_tl hout1,
	hr_locations_all hla1,
	hr_organization_information hoi1,
        hr_all_organization_units hou2,
        hr_all_organization_units_tl hout2,
	hr_locations_all hla2
   where papf.person_id=l_p_person_id
   and   pa.person_id(+)=papf.person_id
   and   pa.primary_flag(+)='Y'
   and   pa.business_group_id(+)=papf.business_group_id
   and   paaf.business_group_id=paaf.business_group_id
   and   paaf.person_id=papf.person_id
   and   ppos.person_id=papf.person_id
   and   ppos.period_of_service_id=paaf.period_of_service_id
   and   paaf.contract_id=pcf.contract_id(+)
   and   paaf.person_id=pcf.person_id(+)
   and   nvl(paaf.collective_agreement_id,-1)=pca.collective_agreement_id(+)
   and   paaf.establishment_id=hou1.organization_id
   and   hout1.organization_id=hou1.organization_id
   and   hout1.language=userenv('lang')
   and   nvl(hou1.location_id,-1)=hla1.location_id
   and   hoi1.organization_id=hou1.organization_id
   and   hoi1.org_information_context='FR_ESTAB_INFO'
   and   hoi1.org_information1=hout2.organization_id
   and   hout2.language=userenv('lang')
   and   hou2.organization_id=hout2.organization_id
   and   nvl(hou2.location_id,-1)=hla2.location_id(+)
   and   l_p_date_to between papf.effective_start_date and papf.effective_end_date
   and   ((l_p_date_to between paaf.effective_start_date and paaf.effective_end_date)
	         or
	 (l_p_date_to >= (select max(effective_end_date)
                                            from per_all_assignments_f p1    /*To include TERMINATED employee*/
				            where p1.person_id=papf.person_id))
					    )
   and   l_p_date_to between pcf.effective_start_date and pcf.effective_end_date;



   cursor c_emp_w_trg is           /* Cursor for Within Training Plan*/
   select distinct odb.booking_id C_W_REF, -- Enrollment reference
          obst.name      ENR_STATUS ,--Enrollment Status
	  oeventl.title   C_W_NAME ,  --Class Name
	  to_char(oevent.course_start_date,'YYYY-MM-DD') C_W_S_DAT ,--Course Start Date
	  to_char(oevent.course_end_date,'YYYY-MM-DD')  C_W_E_DAT , --Course End date
	  odb.source_of_booking   ENR_SOURCE , --Source
	  odb.failure_reason      FAIL_REASON,  --Failure Reason of Attendance
	  decode(otmt.tp_measurement_code,'FR_ACTUAL_HOURS',
	   case otpc.tp_cost_information3
	   when 'JOB_ADAPT' then
	   'I-'||OTA_FR_TRG_SUM.get_lookup_value('FR_LEGAL_TRG_CATG',otpc.tp_cost_information3)
	   when 'JOB_EVOL' then
	   'II-'||OTA_FR_TRG_SUM.get_lookup_value('FR_LEGAL_TRG_CATG',otpc.tp_cost_information3)
	   when 'COMP_DEV' then
	   'III-'||OTA_FR_TRG_SUM.get_lookup_value('FR_LEGAL_TRG_CATG',otpc.tp_cost_information3)
	   end) C_W_L_CAT,--Legal category
          fnd_number.canonical_to_number(otpc.tp_cost_information4) C_W_O_HR , --Hours Outside working
	  decode(otmt.tp_measurement_code,'FR_ACTUAL_HOURS',nvl(otpc.amount,0),
	  nvl(fnd_number.canonical_to_number(otpc.tp_cost_information3),0))C_W_TOT_HR  --Total Hours
     from per_all_people_f papf,
          ota_delegate_bookings odb,
	  ota_booking_status_types obst,
	  ota_events oevent,
	  ota_events_tl oeventl,
	  ota_training_plan_costs otpc,
	  ota_tp_measurement_types otmt
     where papf.person_id=l_p_person_id
     and   papf.person_id=odb.delegate_person_id
     and   odb.booking_status_type_id=obst.booking_status_type_id
     and   oevent.event_id=odb.event_id
     and   oeventl.event_id=oevent.event_id
     and   oeventl.language=userenv('lang')
     and   odb.booking_id=otpc.booking_id
    --and   otpc.training_plan_id=otp.training_plan_id
     and   otpc.tp_measurement_type_id = otmt.tp_measurement_type_id
     and   otmt.business_group_id=odb.business_group_id
     and   otmt.tp_measurement_code in ('FR_ACTUAL_HOURS','FR_SKILLS_ASSESSMENT','FR_VAE')
     and   oevent.course_start_date between L_P_DATE_FROM and L_P_DATE_TO
     --       or oevent.course_end_date<=L_P_DATE_TO
     and   l_p_date_to between papf.effective_start_date and papf.effective_end_date
     order by C_W_S_DAT asc;


    cursor c_emp_w_trg_tot  is
    select sum(decode(otmt.tp_measurement_code,'FR_ACTUAL_HOURS',otpc.amount,
	  fnd_number.canonical_to_number(nvl(otpc.tp_cost_information3,0)))) W_TOT_HOURS ,
	  sum(fnd_number.canonical_to_number(nvl(otpc.tp_cost_information4,0)))  W_TOT_OUT_WK_HR,
          decode(otmt.tp_measurement_code,'FR_ACTUAL_HOURS',
	  otpc.tp_cost_information3,
	  ' ') LEGAL_CATG --i)JOB_ADAPT ii) JOB_EVOL , iii)COMP_DEV
    from per_all_people_f papf,
         ota_delegate_bookings odb,
         ota_training_plan_costs otpc,
	 ota_tp_measurement_types otmt,
	 ota_events oevent
     where papf.person_id=l_p_person_id
     and   papf.person_id=odb.delegate_person_id
     and   odb.booking_id=otpc.booking_id
     and   otpc.tp_measurement_type_id = otmt.tp_measurement_type_id
     and   otmt.tp_measurement_code in ('FR_ACTUAL_HOURS','FR_SKILLS_ASSESSMENT','FR_VAE')
     and   oevent.event_id=odb.event_id
     and   oevent.course_start_date between L_P_DATE_FROM and L_P_DATE_TO
     --and   oevent.course_end_date<=L_P_DATE_TO
     and   l_p_date_to between papf.effective_start_date and papf.effective_end_date
     group by  decode(otmt.tp_measurement_code,'FR_ACTUAL_HOURS',
	  otpc.tp_cost_information3,
	  ' ');



   cursor c_emp_o_trg is                /* Cursor for Outside Training plan*/
   select  distinct paat.name ABS_TYPE,-- Absence Type
           to_char(paa.DATE_START,'YYYY-MM-DD')  C_O_S_DAT, --Start Date
	   to_char(paa.DATE_END,'YYYY-MM-DD')    C_O_E_DAT, --End date
	   fnd_number.canonical_to_number(nvl(paa.ABSENCE_DAYS,0))  DURATION_DAYS, --Duration days
	   fnd_number.canonical_to_number(nvl(paa.ABSENCE_HOURS,0)) C_O_TOT_HR, --Duration hours
	   OTA_FR_TRG_SUM.get_lookup_value('FR_TRAINING_LEAVE_CATEGORY',paa.ABS_INFORMATION1) TRG_LEAV_CATG,-- Training Leave Category
	   paa.ABS_INFORMATION2 C_O_NAME, --Course
	   pv.VENDOR_NAME TRG_PROV,--Training Provider
	   OTA_FR_TRG_SUM.get_lookup_value('FR_TRAINING_TYPE',paa.ABS_INFORMATION4) TYPE_OF_TRG, --Type Of Training
	   paa.ABS_INFORMATION17 C_O_REF, --Training reference
	   paa.ABS_INFORMATION18 WITH_TRG_PLAN, --Within Training Plan
	   case paa.ABS_INFORMATION19
	   when 'JOB_ADAPT' then
	   'I-'||OTA_FR_TRG_SUM.get_lookup_value('FR_LEGAL_TRG_CATG',paa.ABS_INFORMATION19)
	   when 'JOB_EVOL' then
	   'II-'||OTA_FR_TRG_SUM.get_lookup_value('FR_LEGAL_TRG_CATG',paa.ABS_INFORMATION19)
	   when 'COMP_DEV' then
	   'III-'||OTA_FR_TRG_SUM.get_lookup_value('FR_LEGAL_TRG_CATG',paa.ABS_INFORMATION19)
	   end C_O_L_CAT, ---Legal Category
	   fnd_number.canonical_to_number(nvl(paa.ABS_INFORMATION20,0)) C_O_O_HR, --Hours Outside Working Hours
           OTA_FR_TRG_SUM.get_lookup_value('FR_TRAINING_SUBSIDY_TYPE',paa.ABS_INFORMATION5)  SUBSI_TYPE, --Subsidized Type
           hfov.name  SUBSI_ORG --Subsidizing Organization
   from per_all_people_f papf,
        per_absence_attendances paa,
	per_absence_attendance_types paat,
	po_vendors pv,
	HR_FR_OPCA_V hfov
   where papf.person_id=l_p_person_id
   and   papf.person_id=paa.person_id
   and   papf.business_group_id=paa.business_group_id
   and   paa.ABSENCE_ATTENDANCE_TYPE_ID=paat.ABSENCE_ATTENDANCE_TYPE_ID
   and   paat.ABSENCE_CATEGORY='TRAINING_ABSENCE'
   and   paa.ABS_INFORMATION_CATEGORY='FR_TRAINING_ABSENCE'
   and   paa.ABS_INFORMATION18='N'
   and   paa.ABS_INFORMATION19 is not null
   and   paa.ABS_INFORMATION3=pv.vendor_id(+)
   and   paa.ABS_INFORMATION6=hfov.organization_id(+)
   and   paa.date_start between L_P_DATE_FROM and  L_P_DATE_TO
   --and   paa.date_end<=L_P_DATE_TO
   and   l_p_date_to between papf.effective_start_date and papf.effective_end_date
   order by C_O_S_DAT asc;


   cursor c_emp_o_trg_tot is
    Select sum(fnd_number.canonical_to_number(nvl(paa.ABSENCE_HOURS,0))) O_TOT_HOURS ,
           sum(fnd_number.canonical_to_number(nvl(paa.ABS_INFORMATION20,0))) O_TOT_OUT_WK_HR,
           (paa.ABS_INFORMATION19) LEGAL_CATG --i)JOB_ADAPT ii) JOB_EVOL , iii)COMP_DEV
    from  per_all_people_f papf,
          per_absence_attendances paa
   where papf.person_id=l_p_person_id
   and   papf.person_id=paa.person_id
   and   papf.business_group_id=paa.business_group_id
   and   paa.ABS_INFORMATION_CATEGORY='FR_TRAINING_ABSENCE'  -- Absence Should be Training Leave category
   and   paa.ABS_INFORMATION18='N'   -- Within Training Plan should be 'NO'
   and   paa.ABS_INFORMATION19 is not null  --Legal category can not be null
   and   paa.date_start between L_P_DATE_FROM and  L_P_DATE_TO
  -- and   paa.date_end<=L_P_DATE_TO
   and   l_p_date_to between papf.effective_start_date and papf.effective_end_date
   group by paa.ABS_INFORMATION19;



l_catg23_t number :=0;
l_catg23_o number :=0;
l_catg23_t_w number :=0;
l_catg23_o_w number :=0;


BEGIN


 for l_c_emp_h in c_emp_h --Employee Header
 loop

   xml_t(p_xml,'<RECORD>'); ---Start tag of an Employee
   xml_t(p_xml,'<EMP_NAME>'||xml_d(l_c_emp_h.EMP_NAME)||'</EMP_NAME>');
   xml_t(p_xml,'<EMP_NUM>'||xml_d(l_c_emp_h.EMP_NUM)||'</EMP_NUM>');
   xml_t(p_xml,'<E_ADDRESS>'||xml_d(l_c_emp_h.E_ADDRESS)||'</E_ADDRESS>');
   xml_t(p_xml,'<HIRE_DATE>'||xml_d(l_c_emp_h.HIRE_DATE)||'</HIRE_DATE>');
   xml_t(p_xml,'<ADJUSTED_SVC_DATE>'||xml_d(l_c_emp_h.ADJUSTED_SVC_DATE)||'</ADJUSTED_SVC_DATE>');
   xml_t(p_xml,'<TERM_DATE>'||xml_d(l_c_emp_h.TERM_DATE)||'</TERM_DATE>');
   xml_t(p_xml,'<CONTRACT_CATEGORY>'||xml_d(l_c_emp_h.CONTRACT_CATEGORY)||'</CONTRACT_CATEGORY>');
   xml_t(p_xml,'<CONTRACT_TYPE>'||xml_d(l_c_emp_h.CONTRACT_TYPE)||'</CONTRACT_TYPE>');
   xml_t(p_xml,'<COLLECTIVE_AGREEMENT>'||xml_d(l_c_emp_h.COLLECTIVE_AGREEMENT)||'</COLLECTIVE_AGREEMENT>');
   xml_t(p_xml,'<ASSGN_CATEGORY>'||xml_d(l_c_emp_h.ASSGN_CATEGORY)||'</ASSGN_CATEGORY>');
   xml_t(p_xml,'<PERIOD_FROM>'||xml_d(l_c_emp_h.PERIOD_FROM)||'</PERIOD_FROM>');
   xml_t(p_xml,'<PERIOD_TO>'||xml_d(l_c_emp_h.PERIOD_TO)||'</PERIOD_TO>');
   xml_t(p_xml,'<EST_NAME>'||xml_d(l_c_emp_h.EST_NAME)||'</EST_NAME>');
   xml_t(p_xml,'<EST_ADDRESS>'||xml_d(l_c_emp_h.EST_ADDRESS)||'</EST_ADDRESS>');
   xml_t(p_xml,'<SIRET>'||xml_d(l_c_emp_h.SIRET)||'</SIRET>');
   xml_t(p_xml,'<COM_NAME>'||xml_d(l_c_emp_h.COM_NAME)||'</COM_NAME>');
   xml_t(p_xml,'<COM_ADDRESS>'||xml_d(l_c_emp_h.COM_ADDRESS)||'</COM_ADDRESS>');

   hr_utility.trace('<RECORD>'); ---Start tag of an Employee
   hr_utility.trace('<EMP_NAME>'||xml_d(l_c_emp_h.EMP_NAME)||'</EMP_NAME>');
   hr_utility.trace('<EMP_NUM>'||xml_d(l_c_emp_h.EMP_NUM)||'</EMP_NUM>');
   hr_utility.trace('<E_ADDRESS>'||xml_d(l_c_emp_h.E_ADDRESS)||'</E_ADDRESS>');
   hr_utility.trace('<HIRE_DATE>'||xml_d(l_c_emp_h.HIRE_DATE)||'</HIRE_DATE>');
   hr_utility.trace('<ADJUSTED_SVC_DATE>'||xml_d(l_c_emp_h.ADJUSTED_SVC_DATE)||'</ADJUSTED_SVC_DATE>');
   hr_utility.trace('<TERM_DATE>'||xml_d(l_c_emp_h.TERM_DATE)||'</TERM_DATE>');
   hr_utility.trace('<CONTRACT_CATEGORY>'||xml_d(l_c_emp_h.CONTRACT_CATEGORY)||'</CONTRACT_CATEGORY>');
   hr_utility.trace('<CONTRACT_TYPE>'||xml_d(l_c_emp_h.CONTRACT_TYPE)||'</CONTRACT_TYPE>');
   hr_utility.trace('<COLLECTIVE_AGREEMENT>'||xml_d(l_c_emp_h.COLLECTIVE_AGREEMENT)||'</COLLECTIVE_AGREEMENT>');
   hr_utility.trace('<ASSGN_CATEGORY>'||xml_d(l_c_emp_h.ASSGN_CATEGORY)||'</ASSGN_CATEGORY>');
   hr_utility.trace('<PERIOD_FROM>'||xml_d(l_c_emp_h.PERIOD_FROM)||'</PERIOD_FROM>');
   hr_utility.trace('<PERIOD_TO>'||xml_d(l_c_emp_h.PERIOD_TO)||'</PERIOD_TO>');
   hr_utility.trace('<EST_NAME>'||xml_d(l_c_emp_h.EST_NAME)||'</EST_NAME>');
   hr_utility.trace('<EST_ADDRESS>'||xml_d(l_c_emp_h.EST_ADDRESS)||'</EST_ADDRESS>');
   hr_utility.trace('<SIRET>'||xml_d(l_c_emp_h.SIRET)||'</SIRET>');
   hr_utility.trace('<COM_NAME>'||xml_d(l_c_emp_h.COM_NAME)||'</COM_NAME>');
   hr_utility.trace('<COM_ADDRESS>'||xml_d(l_c_emp_h.COM_ADDRESS)||'</COM_ADDRESS>');

  for l_c_emp_w_trg in c_emp_w_trg  --- Courses Within Training Plan
 loop

   xml_t(p_xml,'<W_CLASS>');
   xml_t(p_xml,'<C_W_NAME>'||xml_d(l_c_emp_w_trg.C_W_NAME)||'</C_W_NAME>');
   xml_t(p_xml,'<ENR_STATUS>'||xml_d(l_c_emp_w_trg.ENR_STATUS)||'</ENR_STATUS>');
   xml_t(p_xml,'<C_W_E_DAT>'||xml_d(l_c_emp_w_trg.C_W_E_DAT)||'</C_W_E_DAT>');
   xml_t(p_xml,'<C_W_S_DAT>'||xml_d(l_c_emp_w_trg.C_W_S_DAT)||'</C_W_S_DAT>');
   xml_t(p_xml,'<ENR_SOURCE>'||xml_d(l_c_emp_w_trg.ENR_SOURCE)||'</ENR_SOURCE>');
   xml_t(p_xml,'<C_W_TOT_HR>'||xml_d(l_c_emp_w_trg.C_W_TOT_HR)||'</C_W_TOT_HR>');
   xml_t(p_xml,'<C_W_O_HR>'||xml_d(l_c_emp_w_trg.C_W_O_HR)||'</C_W_O_HR>');
   xml_t(p_xml,'<FAIL_REASON>'||xml_d(l_c_emp_w_trg.FAIL_REASON)||'</FAIL_REASON>');
   xml_t(p_xml,'<C_W_REF>'||xml_d(l_c_emp_w_trg.C_W_REF)||'</C_W_REF>');
   xml_t(p_xml,'<C_W_L_CAT>'||xml_d(l_c_emp_w_trg.C_W_L_CAT)||'</C_W_L_CAT>');
   xml_t(p_xml,'</W_CLASS>');


   hr_utility.trace('<W_CLASS>');
   hr_utility.trace('<C_W_NAME>'||xml_d(l_c_emp_w_trg.C_W_NAME)||'</C_W_NAME>');
   hr_utility.trace('<ENR_STATUS>'||xml_d(l_c_emp_w_trg.ENR_STATUS)||'</ENR_STATUS>');
   hr_utility.trace('<C_W_E_DAT>'||xml_d(l_c_emp_w_trg.C_W_E_DAT)||'</C_W_E_DAT>');
   hr_utility.trace('<C_W_S_DAT>'||xml_d(l_c_emp_w_trg.C_W_S_DAT)||'</C_W_S_DAT>');
   hr_utility.trace('<ENR_SOURCE>'||xml_d(l_c_emp_w_trg.ENR_SOURCE)||'</ENR_SOURCE>');
   hr_utility.trace('<C_W_TOT_HR>'||xml_d(l_c_emp_w_trg.C_W_TOT_HR)||'</C_W_TOT_HR>');
   hr_utility.trace('<C_W_O_HR>'||xml_d(l_c_emp_w_trg.C_W_O_HR)||'</C_W_O_HR>');
   hr_utility.trace('<FAIL_REASON>'||xml_d(l_c_emp_w_trg.FAIL_REASON)||'</FAIL_REASON>');
   hr_utility.trace('<C_W_REF>'||xml_d(l_c_emp_w_trg.C_W_REF)||'</C_W_REF>');
   hr_utility.trace('<C_W_L_CAT>'||xml_d(l_c_emp_w_trg.C_W_L_CAT)||'</C_W_L_CAT>');
   hr_utility.trace('</W_CLASS>');
  end loop;


  for l_c_emp_w_trg_tot in c_emp_w_trg_tot  --Category Total for Courses Within Training Plan
  loop

   if  l_c_emp_w_trg_tot.LEGAL_CATG = 'JOB_ADAPT'  then
     g_catg1_t :=l_c_emp_w_trg_tot.W_TOT_HOURS+g_catg1_t ;          -- ii) JOB_EVOL , iii)COMP_DEV
     g_catg1_o :=l_c_emp_w_trg_tot.W_TOT_OUT_WK_HR+g_catg1_o ;
     xml_t(p_xml,'<c_w_c1>'||xml_d(l_c_emp_w_trg_tot.W_TOT_HOURS)||'</c_w_c1>');
     xml_t(p_xml,'<c_w_o_c1>'||xml_d(l_c_emp_w_trg_tot.W_TOT_OUT_WK_HR)||'</c_w_o_c1>');

     hr_utility.trace('<c_w_c1>'||xml_d(l_c_emp_w_trg_tot.W_TOT_HOURS)||'</c_w_c1>');
     hr_utility.trace('<c_w_o_c1>'||xml_d(l_c_emp_w_trg_tot.W_TOT_OUT_WK_HR)||'</c_w_o_c1>');
   else
     if l_c_emp_w_trg_tot.LEGAL_CATG = 'JOB_EVOL' then
     g_catg2_t :=l_c_emp_w_trg_tot.W_TOT_HOURS+g_catg2_t ;          -- ii) JOB_EVOL , iii)COMP_DEV
     g_catg2_o :=l_c_emp_w_trg_tot.W_TOT_OUT_WK_HR+g_catg2_o ;
     l_catg23_t_w :=l_c_emp_w_trg_tot.W_TOT_HOURS+l_catg23_t_w ;          -- ii) JOB_EVOL , iii)COMP_DEV
     l_catg23_o_w :=l_c_emp_w_trg_tot.W_TOT_OUT_WK_HR+l_catg23_o_w ;
     xml_t(p_xml,'<c_w_c2>'||xml_d(l_c_emp_w_trg_tot.W_TOT_HOURS)||'</c_w_c2>');
     xml_t(p_xml,'<c_w_o_c2>'||xml_d(l_c_emp_w_trg_tot.W_TOT_OUT_WK_HR)||'</c_w_o_c2>');

     hr_utility.trace('<c_w_c2>'||xml_d(l_c_emp_w_trg_tot.W_TOT_HOURS)||'</c_w_c2>');
     hr_utility.trace('<c_w_o_c2>'||xml_d(l_c_emp_w_trg_tot.W_TOT_OUT_WK_HR)||'</c_w_o_c2>');
     else
       if l_c_emp_w_trg_tot.LEGAL_CATG = 'COMP_DEV' then
         g_catg3_t :=l_c_emp_w_trg_tot.W_TOT_HOURS+g_catg3_t ;          -- ii) JOB_EVOL , iii)COMP_DEV
         g_catg3_o :=l_c_emp_w_trg_tot.W_TOT_OUT_WK_HR+g_catg3_o ;
	 l_catg23_t_w :=l_c_emp_w_trg_tot.W_TOT_HOURS+l_catg23_t_w ;          -- ii) JOB_EVOL , iii)COMP_DEV
         l_catg23_o_w :=l_c_emp_w_trg_tot.W_TOT_OUT_WK_HR+l_catg23_o_w ;
         xml_t(p_xml,'<c_w_c3>'||xml_d(l_c_emp_w_trg_tot.W_TOT_HOURS)||'</c_w_c3>');
         xml_t(p_xml,'<c_w_o_c3>'||xml_d(l_c_emp_w_trg_tot.W_TOT_OUT_WK_HR)||'</c_w_o_c3>');

	 hr_utility.trace('<c_w_c3>'||xml_d(l_c_emp_w_trg_tot.W_TOT_HOURS)||'</c_w_c3>');
         hr_utility.trace('<c_w_o_c3>'||xml_d(l_c_emp_w_trg_tot.W_TOT_OUT_WK_HR)||'</c_w_o_c3>');
       end if;
      end if;
    end if;



     /* l_catg23_t_w:=0;
      l_catg23_o_w:=0;*/

   end loop;
         xml_t(p_xml,'<c_w_c23>'||xml_d(l_catg23_t_w)||'</c_w_c23>');
         xml_t(p_xml,'<c_w_o_c23>'||xml_d(l_catg23_o_w)||'</c_w_o_c23>');
         hr_utility.trace('<c_w_c23>'||xml_d(l_catg23_t_w)||'</c_w_c23>');
         hr_utility.trace('<c_w_o_c23>'||xml_d(l_catg23_o_w)||'</c_w_o_c23>');
 for l_c_emp_o_trg in c_emp_o_trg  --- Courses Outside Training Plan
 loop

   xml_t(p_xml,'<O_CLASS>');
   xml_t(p_xml,'<C_O_NAME>'||xml_d(l_c_emp_o_trg.C_O_NAME)||'</C_O_NAME>');
   xml_t(p_xml,'<ABS_TYPE>'||xml_d(l_c_emp_o_trg.ABS_TYPE)||'</ABS_TYPE>');
   xml_t(p_xml,'<C_O_E_DAT>'||xml_d(l_c_emp_o_trg.C_O_E_DAT)||'</C_O_E_DAT>');
   xml_t(p_xml,'<C_O_S_DAT>'||xml_d(l_c_emp_o_trg.C_O_S_DAT)||'</C_O_S_DAT>');
   xml_t(p_xml,'<DURATION_DAYS>'||xml_d(l_c_emp_o_trg.DURATION_DAYS)||'</DURATION_DAYS>');
   xml_t(p_xml,'<C_O_TOT_HR>'||xml_d(l_c_emp_o_trg.C_O_TOT_HR)||'</C_O_TOT_HR>');
   xml_t(p_xml,'<TRG_LEAV_CATG>'||xml_d(l_c_emp_o_trg.TRG_LEAV_CATG)||'</TRG_LEAV_CATG>');
   xml_t(p_xml,'<TRG_PROV>'||xml_d(l_c_emp_o_trg.TRG_PROV)||'</TRG_PROV>');
   xml_t(p_xml,'<TYPE_OF_TRG>'||xml_d(l_c_emp_o_trg.TYPE_OF_TRG)||'</TYPE_OF_TRG>');
   xml_t(p_xml,'<C_O_REF>'||xml_d(l_c_emp_o_trg.C_O_REF)||'</C_O_REF>');
   xml_t(p_xml,'<WITH_TRG_PLAN>'||xml_d(l_c_emp_o_trg.WITH_TRG_PLAN)||'</WITH_TRG_PLAN>');
   xml_t(p_xml,'<C_O_L_CAT>'||xml_d(l_c_emp_o_trg.C_O_L_CAT)||'</C_O_L_CAT>');
   xml_t(p_xml,'<C_O_O_HR>'||xml_d(l_c_emp_o_trg.C_O_O_HR)||'</C_O_O_HR>');
   xml_t(p_xml,'<SUBSI_TYPE>'||xml_d(l_c_emp_o_trg.SUBSI_TYPE)||'</SUBSI_TYPE>');
   xml_t(p_xml,'<SUBSI_ORG>'||xml_d(l_c_emp_o_trg.SUBSI_ORG)||'</SUBSI_ORG>');
   xml_t(p_xml,'</O_CLASS>');


   hr_utility.trace('<O_CLASS>');
   hr_utility.trace('<C_O_NAME>'||xml_d(l_c_emp_o_trg.C_O_NAME)||'</C_O_NAME>');
   hr_utility.trace('<ABS_TYPE>'||xml_d(l_c_emp_o_trg.ABS_TYPE)||'</ABS_TYPE>');
   hr_utility.trace('<C_O_E_DAT>'||xml_d(l_c_emp_o_trg.C_O_E_DAT)||'</C_O_E_DAT>');
   hr_utility.trace('<C_O_S_DAT>'||xml_d(l_c_emp_o_trg.C_O_S_DAT)||'</C_O_S_DAT>');
   hr_utility.trace('<DURATION_DAYS>'||xml_d(l_c_emp_o_trg.DURATION_DAYS)||'</DURATION_DAYS>');
   hr_utility.trace('<C_O_TOT_HR>'||xml_d(l_c_emp_o_trg.C_O_TOT_HR)||'</C_O_TOT_HR>');
   hr_utility.trace('<TRG_LEAV_CATG>'||xml_d(l_c_emp_o_trg.TRG_LEAV_CATG)||'</TRG_LEAV_CATG>');
   hr_utility.trace('<TRG_PROV>'||xml_d(l_c_emp_o_trg.TRG_PROV)||'</TRG_PROV>');
   hr_utility.trace('<TYPE_OF_TRG>'||xml_d(l_c_emp_o_trg.TYPE_OF_TRG)||'</TYPE_OF_TRG>');
   hr_utility.trace('<C_O_REF>'||xml_d(l_c_emp_o_trg.C_O_REF)||'</C_O_REF>');
   hr_utility.trace('<WITH_TRG_PLAN>'||xml_d(l_c_emp_o_trg.WITH_TRG_PLAN)||'</WITH_TRG_PLAN>');
   hr_utility.trace('<C_O_L_CAT>'||xml_d(l_c_emp_o_trg.C_O_L_CAT)||'</C_O_L_CAT>');
   hr_utility.trace('<C_O_O_HR>'||xml_d(l_c_emp_o_trg.C_O_O_HR)||'</C_O_O_HR>');
   hr_utility.trace('<SUBSI_TYPE>'||xml_d(l_c_emp_o_trg.SUBSI_TYPE)||'</SUBSI_TYPE>');
   hr_utility.trace('<SUBSI_ORG>'||xml_d(l_c_emp_o_trg.SUBSI_ORG)||'</SUBSI_ORG>');
   hr_utility.trace('</O_CLASS>');



  end loop;

  for l_c_emp_o_trg_tot in c_emp_o_trg_tot  --Category Total for Courses outside Training Plan
  loop

   if  l_c_emp_o_trg_tot.LEGAL_CATG = 'JOB_ADAPT'  then
     g_catg1_t :=l_c_emp_o_trg_tot.O_TOT_HOURS+g_catg1_t ;          -- ii) JOB_EVOL , iii)COMP_DEV
     g_catg1_o :=l_c_emp_o_trg_tot.O_TOT_OUT_WK_HR+g_catg1_o ;
     xml_t(p_xml,'<c_o_c1>'||xml_d(l_c_emp_o_trg_tot.O_TOT_HOURS)||'</c_o_c1>');
     xml_t(p_xml,'<c_o_o_c1>'||xml_d(l_c_emp_o_trg_tot.O_TOT_OUT_WK_HR)||'</c_o_o_c1>');

     hr_utility.trace('<c_o_c1>'||xml_d(l_c_emp_o_trg_tot.O_TOT_HOURS)||'</c_o_c1>');
     hr_utility.trace('<c_o_o_c1>'||xml_d(l_c_emp_o_trg_tot.O_TOT_OUT_WK_HR)||'</c_o_o_c1>');
   else
     if l_c_emp_o_trg_tot.LEGAL_CATG = 'JOB_EVOL' then
     g_catg2_t :=l_c_emp_o_trg_tot.O_TOT_HOURS+g_catg2_t ;          -- ii) JOB_EVOL , iii)COMP_DEV
     g_catg2_o :=l_c_emp_o_trg_tot.O_TOT_OUT_WK_HR+g_catg2_o ;

     l_catg23_t :=l_c_emp_o_trg_tot.O_TOT_HOURS+l_catg23_t ;          -- ii) JOB_EVOL , iii)COMP_DEV
     l_catg23_o :=l_c_emp_o_trg_tot.O_TOT_OUT_WK_HR+l_catg23_o ;

     xml_t(p_xml,'<c_o_c2>'||xml_d(l_c_emp_o_trg_tot.O_TOT_HOURS)||'</c_o_c2>');
     xml_t(p_xml,'<c_o_o_c2>'||xml_d(l_c_emp_o_trg_tot.O_TOT_OUT_WK_HR)||'</c_o_o_c2>');

     hr_utility.trace('<c_o_c2>'||xml_d(l_c_emp_o_trg_tot.O_TOT_HOURS)||'</c_o_c2>');
     hr_utility.trace('<c_o_o_c2>'||xml_d(l_c_emp_o_trg_tot.O_TOT_OUT_WK_HR)||'</c_o_o_c2>');
     else
        if l_c_emp_o_trg_tot.LEGAL_CATG = 'COMP_DEV' then
         g_catg3_t :=l_c_emp_o_trg_tot.O_TOT_HOURS+g_catg3_t ;          -- ii) JOB_EVOL , iii)COMP_DEV
         g_catg3_o :=l_c_emp_o_trg_tot.O_TOT_OUT_WK_HR+g_catg3_o ;

	 l_catg23_t :=l_c_emp_o_trg_tot.O_TOT_HOURS+l_catg23_t ;          -- ii) JOB_EVOL , iii)COMP_DEV
         l_catg23_o :=l_c_emp_o_trg_tot.O_TOT_OUT_WK_HR+l_catg23_o ;

         xml_t(p_xml,'<c_o_c3>'||xml_d(l_c_emp_o_trg_tot.O_TOT_HOURS)||'</c_o_c3>');
         xml_t(p_xml,'<c_o_o_c3>'||xml_d(l_c_emp_o_trg_tot.O_TOT_OUT_WK_HR)||'</c_o_o_c3>');

	 hr_utility.trace('<c_o_c3>'||xml_d(l_c_emp_o_trg_tot.O_TOT_HOURS)||'</c_o_c3>');
         hr_utility.trace('<c_o_o_c3>'||xml_d(l_c_emp_o_trg_tot.O_TOT_OUT_WK_HR)||'</c_o_o_c3>');
	end if;
      end if;
    end if;

        /* l_catg23_t:=0;
         l_catg23_o:=0;*/

   end loop;
         xml_t(p_xml,'<c_o_c23>'||xml_d(l_catg23_t)||'</c_o_c23>');
	 xml_t(p_xml,'<c_o_o_c23>'||xml_d(l_catg23_o)||'</c_o_o_c23>');

	 hr_utility.trace('<c_o_c23>'||xml_d(l_catg23_t)||'</c_o_c23>');
	 hr_utility.trace('<c_o_o_c23>'||xml_d(l_catg23_o)||'</c_o_o_c23>');

 xml_t(p_xml,'<g_catg1_t>'||xml_d(g_catg1_t)||'</g_catg1_t>');
 xml_t(p_xml,'<g_catg2_t>'||xml_d(g_catg2_t)||'</g_catg2_t>');
 xml_t(p_xml,'<g_catg3_t>'||xml_d(g_catg3_t)||'</g_catg3_t>');
 xml_t(p_xml,'<g_catg1_o>'||xml_d(g_catg1_o)||'</g_catg1_o>');
 xml_t(p_xml,'<g_catg2_o>'||xml_d(g_catg2_o)||'</g_catg2_o>');
 xml_t(p_xml,'<g_catg3_o>'||xml_d(g_catg3_o)||'</g_catg3_o>');
 xml_t(p_xml,'<g_catg23_t>'||xml_d(g_catg2_t+g_catg3_t)||'</g_catg23_t>');
 xml_t(p_xml,'<g_catg23_o>'||xml_d(g_catg2_o+g_catg3_o)||'</g_catg23_o>');

 hr_utility.trace('<g_catg1_t>'||xml_d(g_catg1_t)||'</g_catg1_t>');
 hr_utility.trace('<g_catg2_t>'||xml_d(g_catg2_t)||'</g_catg2_t>');
 hr_utility.trace('<g_catg3_t>'||xml_d(g_catg3_t)||'</g_catg3_t>');
 hr_utility.trace('<g_catg1_o>'||xml_d(g_catg1_o)||'</g_catg1_o>');
 hr_utility.trace('<g_catg2_o>'||xml_d(g_catg2_o)||'</g_catg2_o>');
 hr_utility.trace('<g_catg3_o>'||xml_d(g_catg3_o)||'</g_catg3_o>');
 hr_utility.trace('<g_catg23_t>'||xml_d(g_catg2_t+g_catg3_t)||'</g_catg23_t>');
 hr_utility.trace('<g_catg23_o>'||xml_d(g_catg2_o+g_catg3_o)||'</g_catg23_o>');

g_catg1_t :=0;
g_catg2_t :=0;
g_catg3_t :=0;
g_catg1_o :=0;
g_catg2_o :=0;
g_catg3_o :=0;
xml_t(p_xml,'</RECORD>');
hr_utility.TRACE('</RECORD>');
end loop;

END make_employee;


end OTA_FR_TRG_SUM;



/
