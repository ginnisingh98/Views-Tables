--------------------------------------------------------
--  DDL for Package Body PER_VETS_MAG_100A_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_VETS_MAG_100A_REPORT" as
/* $Header: pevetmag100a.pkb 120.0.12010000.10 2009/10/30 11:21:47 emunisek noship $ */
type org_rec is record
  (company_number   varchar2(20),
   contractor_type  varchar2(80),
   form_type        varchar2(80),
   number_of_estabs number(8),
   ending_period    varchar2(30),
   parent_company   varchar2(200),
   street           varchar2(200),
   street2           varchar2(200),
   city             varchar2(200),
   county           varchar2(200),
   state            varchar2(200),
   zip_code         varchar2(200),
   contact          varchar2(200),
   telephone        varchar2(200),
   email            varchar2(200),
   naics            varchar2(200),
   duns             varchar2(200),
   ein              varchar2(200));
--
l_org_rec org_rec;
--
type month_rec is record
  (jan            number,
   feb            number,
   mar            number,
   apr            number,
   may            number,
   jun            number,
   jul            number,
   aug            number,
   sep            number,
   oct            number,
   nov            number,
   dec            number);
--
l_month_rec month_rec;
l_month_rec_blank month_rec;
--
type estab_rec is record
  (unit_number    varchar2(30),
   reporting_name varchar2(200),
   street         varchar2(200),
   street2         varchar2(200),
   city           varchar2(200),
   county         varchar2(200),
   state          varchar2(200),
   zip_code       varchar2(200),
   naics          varchar2(200),
   duns           varchar2(200),
   ein            varchar2(200),
   hq             varchar2(200),

   l1_total       number(8),
   m1_total       number(8),
   n1_total       number(8),
   o1_total       number(8),
   p1_total       number(8),
   q1_total       number(8),
   r1_total       number(8),
   s1_total       number(8),
   t1_total       number(8),
   u1_total       number(8),
   l2_total       number(8),
   m2_total       number(8),
   n2_total       number(8),
   o2_total       number(8),
   p2_total       number(8),
   q2_total       number(8),
   r2_total       number(8),
   s2_total       number(8),
   t2_total       number(8),
   u2_total       number(8),
   l3_total       number(8),
   m3_total       number(8),
   n3_total       number(8),
   o3_total       number(8),
   p3_total       number(8),
   q3_total       number(8),
   r3_total       number(8),
   s3_total       number(8),
   t3_total       number(8),
   u3_total       number(8),
   l4_total       number(8),
   m4_total       number(8),
   n4_total       number(8),
   o4_total       number(8),
   p4_total       number(8),
   q4_total       number(8),
   r4_total       number(8),
   s4_total       number(8),
   t4_total       number(8),
   u4_total       number(8),
   l5_total       number(8),
   m5_total       number(8),
   n5_total       number(8),
   o5_total       number(8),
   p5_total       number(8),
   q5_total       number(8),
   r5_total       number(8),
   s5_total       number(8),
   t5_total       number(8),
   u5_total       number(8),
   l6_total       number(8),
   m6_total       number(8),
   n6_total       number(8),
   o6_total       number(8),
   p6_total       number(8),
   q6_total       number(8),
   r6_total       number(8),
   s6_total       number(8),
   t6_total       number(8),
   u6_total       number(8),
   l7_total       number(8),
   m7_total       number(8),
   n7_total       number(8),
   o7_total       number(8),
   p7_total       number(8),
   q7_total       number(8),
   r7_total       number(8),
   s7_total       number(8),
   t7_total       number(8),
   u7_total       number(8),
   l8_total       number(8),
   m8_total       number(8),
   n8_total       number(8),
   o8_total       number(8),
   p8_total       number(8),
   q8_total       number(8),
   r8_total       number(8),
   s8_total       number(8),
   t8_total       number(8),
   u8_total       number(8),
   l9_total       number(8),
   m9_total       number(8),
   n9_total       number(8),
   o9_total       number(8),
   p9_total       number(8),
   q9_total       number(8),
   r9_total       number(8),
   s9_total       number(8),
   t9_total       number(8),
   u9_total       number(8),
   l10_total       number(8),
   m10_total       number(8),
   n10_total       number(8),
   o10_total       number(8),
   p10_total       number(8),
   q10_total       number(8),
   r10_total       number(8),
   s10_total       number(8),
   t10_total       number(8),
   u10_total       number(8),

   l_grand_total  number(8),
   m_grand_total  number(8),
   n_grand_total  number(8),
   o_grand_total  number(8),
   p_grand_total  number(8),
   q_grand_total  number(8),
   r_grand_total  number(8),
   s_grand_total  number(8),
   t_grand_total  number(8),
   u_grand_total  number(8),

   min_count      number(8),
   max_count      number(8));
--
l_estab_rec estab_rec;
l_consol_rec estab_rec;
l_holder_rec estab_rec;
l_estab_rec_blank estab_rec;
l_all_estab varchar2(1);
l_tot_emps number;
--

function check_recent_or_not(l_person_id IN per_all_people_f.person_id%TYPE,
                             l_report_end_date IN date)
return number
is
l_count number;
begin
select count(person_id) into l_count
         from PER_PEOPLE_EXTRA_INFO  ppei where
         l_person_id = ppei.person_id
         and ppei.information_type ='VETS 100A'
         and pei_information1 is not null
         and
    ( months_between(l_report_end_date,add_months(to_char(to_date(substr(pei_information1,1,10),'YYYY/MM/DD'),'DD-MON-YYYY'),0)) between 0 and 12
     or
     months_between(l_report_end_date,add_months(to_char(to_date(substr(pei_information1,1,10),'YYYY/MM/DD'),'DD-MON-YYYY'),12)) between 0 and 12
     or
     months_between(l_report_end_date,add_months(to_char(to_date(substr(pei_information1,1,10),'YYYY/MM/DD'),'DD-MON-YYYY'),24)) between 0 and 12
     or
     months_between(l_report_end_date,(add_months(to_char(to_date(substr(pei_information1,1,10),'YYYY/MM/DD'),'DD-MON-YYYY'),36)-2)) between 0 and 12
     );
return l_count;
exception
when others then
return 0;
end;


procedure set_org_details(p_hierarchy_version_id in number,
                          p_business_group_id in number) is
  --
  cursor c1 is
    select substr(hoi1.org_information2,1,20) company_number,
        decode(hoi1.org_information3,'2S','S','1P','P','3B','B') contractor_type,
           replace(nvl(hoi1.org_information1,hou.name),',',' ') parent_company,
           upper(replace(loc.address_line_1,',',' ')||
                 ' ') street1,
            upper(replace(loc.address_line_2,',',' ')||
                 ' '||
                 replace(loc.address_line_3,',',' ')) street2,
           upper(loc.town_or_city) city,
           upper(loc.region_1) county,
           loc.region_2 state,
           loc.postal_code zip_code,
           hoi2.org_information2 naics,
           hoi2.org_information4 duns,
           hoi2.org_information3 ein
    from   per_gen_hierarchy_nodes pgn,
           hr_all_organization_units hou,
           hr_organization_information hoi1,
           hr_organization_information hoi2,
           hr_locations_all loc
    where  pgn.hierarchy_version_id = p_hierarchy_version_id
    and    pgn.node_type = 'PAR'
    and    pgn.entity_id = hou.organization_id
    and    pgn.business_group_id = p_business_group_id
    and    hoi1.org_information_context  = 'VETS_Spec'
    and    hoi1.organization_id = hou.organization_id
    and    hoi2.org_information_context  = 'VETS_EEO_Dup'
    and    hoi2.organization_id = hou.organization_id
    and    hou.location_id = loc.location_id(+);
   --

   cursor c2 is
select
   hoi2.org_information17  contact_name
  ,substr(hoi2.org_information18,1,20)  contact_telnum
  ,hoi2.org_information20 contact_email
from
      hr_organization_information      hoi1
     ,hr_locations_all                 cloc
     ,hr_organization_units            hou
     ,hr_organization_information      hoi2
     ,per_gen_hierarchy_nodes          pgn
where
      hoi1.organization_id                      = pgn.entity_id
      and hoi1.org_information_context  = 'VETS_Spec'
      and hoi1.organization_id                  = hou.organization_id
      and hou.location_id = cloc.location_id
      and hoi2.organization_id = p_business_group_id
      and hoi2.org_information_context = 'EEO_REPORT'
      and pgn.hierarchy_version_id = p_hierarchy_version_id
      and pgn.node_type = 'PAR'  ;

begin
  --
  open c1;
    --
    fetch c1 into l_org_rec.company_number,
                  l_org_rec.contractor_type,
                  l_org_rec.parent_company,
                  l_org_rec.street,
                  l_org_rec.street2,
                  l_org_rec.city,
                  l_org_rec.county,
                  l_org_rec.state,
                  l_org_rec.zip_code,
                  l_org_rec.naics,
                  l_org_rec.duns,
                  l_org_rec.ein;
    --
  close c1;
   --
   --
  open c2;
    --
    fetch c2 into l_org_rec.contact,
                  l_org_rec.telephone,
                  l_org_rec.email;
    --
  close c2;
   --

end set_org_details;

procedure get_min_max(p_value1  in number,
                      p_value2  in number,
                      p_value3  in number,
                      p_value4  in number,
                      p_value5  in number,
                      p_value6  in number,
                      p_value7  in number,
                      p_value8  in number,
                      p_value9  in number,
                      p_value10 in number,
                      p_value11 in number,
                      p_value12 in number,
                      p_min_out out nocopy number,
                      p_max_out out nocopy number) is
  --
  l_min number := p_value1;
  l_max number := p_value1;
  --
begin
  --
  if l_max < p_value2 then
    --
    l_max := p_value2;
    --
  elsif l_min > p_value2 then
    --
    l_min := p_value2;
    --
  end if;
  --
  if l_max < p_value3 then
    --
    l_max := p_value3;
    --
  elsif l_min > p_value3 then
    --
    l_min := p_value3;
    --
  end if;
  --
  if l_max < p_value4 then
    --
    l_max := p_value4;
    --
  elsif l_min > p_value4 then
    --
    l_min := p_value4;
    --
  end if;
  --
  if l_max < p_value5 then
    --
    l_max := p_value5;
    --
  elsif l_min > p_value5 then
    --
    l_min := p_value5;
    --
  end if;
  --
  if l_max < p_value6 then
    --
    l_max := p_value6;
    --
  elsif l_min > p_value6 then
    --
    l_min := p_value6;
    --
  end if;
  --
  if l_max < p_value7 then
    --
    l_max := p_value7;
    --
  elsif l_min > p_value7 then
    --
    l_min := p_value7;
    --
  end if;
  --
  if l_max < p_value8 then
    --
    l_max := p_value8;
    --
  elsif l_min > p_value8 then
    --
    l_min := p_value8;
    --
  end if;
  --
  if l_max < p_value9 then
    --
    l_max := p_value9;
    --
  elsif l_min > p_value9 then
    --
    l_min := p_value9;
    --
  end if;
  --
  if l_max < p_value10 then
    --
    l_max := p_value10;
    --
  elsif l_min > p_value10 then
    --
    l_min := p_value10;
    --
  end if;
  --
  if l_max < p_value11 then
    --
    l_max := p_value11;
    --
  elsif l_min > p_value11 then
    --
    l_min := p_value11;
    --
  end if;
  --
  if l_max < p_value12 then
    --
    l_max := p_value12;
    --
  elsif l_min > p_value12 then
    --
    l_min := p_value12;
    --
  end if;
  --
  p_max_out := l_max;
  p_min_out := l_min;
  --
end get_min_max;
--
procedure write_consolidated_record is
  --
  l_string varchar2(2000);
  --
begin
  --
  -- Set l_consol_rec.min_count and l_consol_rec.max_count
  --
  get_min_max(p_value1  => l_month_rec.jan,
              p_value2  => l_month_rec.feb,
              p_value3  => l_month_rec.mar,
              p_value4  => l_month_rec.apr,
              p_value5  => l_month_rec.may,
              p_value6  => l_month_rec.jun,
              p_value7  => l_month_rec.jul,
              p_value8  => l_month_rec.aug,
              p_value9  => l_month_rec.sep,
              p_value10 => l_month_rec.oct,
              p_value11 => l_month_rec.nov,
              p_value12 => l_month_rec.dec,
              p_min_out => l_consol_rec.min_count,
              p_max_out => l_consol_rec.max_count);
  --
  l_string := l_org_rec.company_number||','||
              l_org_rec.contractor_type||','||
              'MSC'||','||
              to_char(l_org_rec.number_of_estabs)||','||
              l_org_rec.ending_period||','||
              substr(l_org_rec.parent_company,1,40)||','||
              substr(l_org_rec.street,1,40)||','||
              substr(l_org_rec.street2,1,40)||','||
              substr(l_org_rec.city,1,20)||','||
              substr(l_org_rec.county,1,20)||','||
              substr(l_org_rec.state,1,20)||','||
              substr(l_org_rec.zip_code,1,10)||','||
              substr(l_org_rec.contact,1,40)||','||
              substr(l_org_rec.telephone,1,20)||','||
              substr(l_org_rec.email,1,40)||','||
              substr(l_consol_rec.reporting_name,1,40)||','||
              substr(l_consol_rec.street,1,40)||','||
              substr(l_consol_rec.street2,1,40)||','||
              substr(l_consol_rec.city,1,20)||','||
              substr(l_consol_rec.county,1,20)||','||
              substr(l_consol_rec.state,1,20)||','||
              substr(l_consol_rec.zip_code,1,10)||','||
              substr(l_org_rec.naics,1,10)||','||
              substr(l_org_rec.duns,1,20)||','||
              substr(l_org_rec.ein,1,20)||','||
              nvl(l_consol_rec.l1_total,0)||','||
              nvl(l_consol_rec.l2_total,0)||','||
              nvl(l_consol_rec.l3_total,0)||','||
              nvl(l_consol_rec.l4_total,0)||','||
              nvl(l_consol_rec.l5_total,0)||','||
              nvl(l_consol_rec.l6_total,0)||','||
              nvl(l_consol_rec.l7_total,0)||','||
              nvl(l_consol_rec.l8_total,0)||','||
              nvl(l_consol_rec.l9_total,0)||','||
              nvl(l_consol_rec.l10_total,0)||','||
              nvl(l_consol_rec.l_grand_total,0)||','||
              nvl(l_consol_rec.m1_total,0)||','||
              nvl(l_consol_rec.m2_total,0)||','||
              nvl(l_consol_rec.m3_total,0)||','||
              nvl(l_consol_rec.m4_total,0)||','||
              nvl(l_consol_rec.m5_total,0)||','||
              nvl(l_consol_rec.m6_total,0)||','||
              nvl(l_consol_rec.m7_total,0)||','||
              nvl(l_consol_rec.m8_total,0)||','||
              nvl(l_consol_rec.m9_total,0)||','||
              nvl(l_consol_rec.m10_total,0)||','||
              nvl(l_consol_rec.m_grand_total,0)||','||
              nvl(l_consol_rec.n1_total,0)||','||
              nvl(l_consol_rec.n2_total,0)||','||
              nvl(l_consol_rec.n3_total,0)||','||
              nvl(l_consol_rec.n4_total,0)||','||
              nvl(l_consol_rec.n5_total,0)||','||
              nvl(l_consol_rec.n6_total,0)||','||
              nvl(l_consol_rec.n7_total,0)||','||
              nvl(l_consol_rec.n8_total,0)||','||
              nvl(l_consol_rec.n9_total,0)||','||
              nvl(l_consol_rec.n10_total,0)||','||
              nvl(l_consol_rec.n_grand_total,0)||','||
              nvl(l_consol_rec.o1_total,0)||','||
              nvl(l_consol_rec.o2_total,0)||','||
              nvl(l_consol_rec.o3_total,0)||','||
              nvl(l_consol_rec.o4_total,0)||','||
              nvl(l_consol_rec.o5_total,0)||','||
              nvl(l_consol_rec.o6_total,0)||','||
              nvl(l_consol_rec.o7_total,0)||','||
              nvl(l_consol_rec.o8_total,0)||','||
              nvl(l_consol_rec.o9_total,0)||','||
              nvl(l_consol_rec.o10_total,0)||','||
              nvl(l_consol_rec.o_grand_total,0)||','||
              nvl(l_consol_rec.p1_total,0)||','||
              nvl(l_consol_rec.p2_total,0)||','||
              nvl(l_consol_rec.p3_total,0)||','||
              nvl(l_consol_rec.p4_total,0)||','||
              nvl(l_consol_rec.p5_total,0)||','||
              nvl(l_consol_rec.p6_total,0)||','||
              nvl(l_consol_rec.p7_total,0)||','||
              nvl(l_consol_rec.p8_total,0)||','||
              nvl(l_consol_rec.p9_total,0)||','||
              nvl(l_consol_rec.p10_total,0)||','||
              nvl(l_consol_rec.p_grand_total,0)||','||
              nvl(l_consol_rec.q1_total,0)||','||
              nvl(l_consol_rec.q2_total,0)||','||
              nvl(l_consol_rec.q3_total,0)||','||
              nvl(l_consol_rec.q4_total,0)||','||
              nvl(l_consol_rec.q5_total,0)||','||
              nvl(l_consol_rec.q6_total,0)||','||
              nvl(l_consol_rec.q7_total,0)||','||
              nvl(l_consol_rec.q8_total,0)||','||
              nvl(l_consol_rec.q9_total,0)||','||
              nvl(l_consol_rec.q10_total,0)||','||
              nvl(l_consol_rec.q_grand_total,0)||','||
              nvl(l_consol_rec.r1_total,0)||','||
              nvl(l_consol_rec.r2_total,0)||','||
              nvl(l_consol_rec.r3_total,0)||','||
              nvl(l_consol_rec.r4_total,0)||','||
              nvl(l_consol_rec.r5_total,0)||','||
              nvl(l_consol_rec.r6_total,0)||','||
              nvl(l_consol_rec.r7_total,0)||','||
              nvl(l_consol_rec.r8_total,0)||','||
              nvl(l_consol_rec.r9_total,0)||','||
              nvl(l_consol_rec.r10_total,0)||','||
              nvl(l_consol_rec.r_grand_total,0)||','||
              nvl(l_consol_rec.s1_total,0)||','||
              nvl(l_consol_rec.s2_total,0)||','||
              nvl(l_consol_rec.s3_total,0)||','||
              nvl(l_consol_rec.s4_total,0)||','||
              nvl(l_consol_rec.s5_total,0)||','||
              nvl(l_consol_rec.s6_total,0)||','||
              nvl(l_consol_rec.s7_total,0)||','||
              nvl(l_consol_rec.s8_total,0)||','||
              nvl(l_consol_rec.s9_total,0)||','||
              nvl(l_consol_rec.s10_total,0)||','||
              nvl(l_consol_rec.s_grand_total,0)||','||
              nvl(l_consol_rec.t1_total,0)||','||
              nvl(l_consol_rec.t2_total,0)||','||
              nvl(l_consol_rec.t3_total,0)||','||
              nvl(l_consol_rec.t4_total,0)||','||
              nvl(l_consol_rec.t5_total,0)||','||
              nvl(l_consol_rec.t6_total,0)||','||
              nvl(l_consol_rec.t7_total,0)||','||
              nvl(l_consol_rec.t8_total,0)||','||
              nvl(l_consol_rec.t9_total,0)||','||
              nvl(l_consol_rec.t10_total,0)||','||
              nvl(l_consol_rec.t_grand_total,0)||','||
              nvl(l_consol_rec.u1_total,0)||','||
              nvl(l_consol_rec.u2_total,0)||','||
              nvl(l_consol_rec.u3_total,0)||','||
              nvl(l_consol_rec.u4_total,0)||','||
              nvl(l_consol_rec.u5_total,0)||','||
              nvl(l_consol_rec.u6_total,0)||','||
              nvl(l_consol_rec.u7_total,0)||','||
              nvl(l_consol_rec.u8_total,0)||','||
              nvl(l_consol_rec.u9_total,0)||','||
              nvl(l_consol_rec.u10_total,0)||','||
              nvl(l_consol_rec.u_grand_total,0)||','||
              nvl(l_consol_rec.max_count,0)||','||
              nvl(l_consol_rec.min_count,0);
  --
  fnd_file.put_line(fnd_file.OUTPUT, l_string);
  --
  l_org_rec.number_of_estabs := null;
  --
end write_consolidated_record;
--
procedure write_establishment_record is
  --
  l_string varchar2(2000);
  l_proc   varchar2(40) := 'write_establishment_record';
  --
begin
  --
  -- Set form type
  --
  hr_utility.set_location(l_proc,10);
  hr_utility.trace('l_estab_rec.max_count : ' || l_estab_rec.max_count);
  if l_estab_rec.hq = 'Y' and
    nvl(l_org_rec.form_type,'-1') <> 'S' then
    --
    hr_utility.set_location(l_proc,20);
    l_org_rec.form_type := 'MHQ';
    --
  end if;
  --
  if l_estab_rec.hq = 'N' and
    nvl(l_org_rec.form_type,'-1') <> 'S' and
    (
    --   l_estab_rec.max_count >= 50
       l_tot_emps >= 50
       or l_all_estab = 'N'
    ) then
    --
    hr_utility.set_location(l_proc,30);
    l_org_rec.form_type := 'MHL';
    --
  end if;
  --
  -- Set totals
  --
  l_estab_rec.l_grand_total := nvl(l_estab_rec.l1_total,0)+
                               nvl(l_estab_rec.l2_total,0)+
                               nvl(l_estab_rec.l3_total,0)+
                               nvl(l_estab_rec.l4_total,0)+
                               nvl(l_estab_rec.l5_total,0)+
                               nvl(l_estab_rec.l6_total,0)+
                               nvl(l_estab_rec.l7_total,0)+
                               nvl(l_estab_rec.l8_total,0)+
                               nvl(l_estab_rec.l9_total,0)+
                               nvl(l_estab_rec.l10_total,0);
  --
  l_estab_rec.m_grand_total := nvl(l_estab_rec.m1_total,0)+
                               nvl(l_estab_rec.m2_total,0)+
                               nvl(l_estab_rec.m3_total,0)+
                               nvl(l_estab_rec.m4_total,0)+
                               nvl(l_estab_rec.m5_total,0)+
                               nvl(l_estab_rec.m6_total,0)+
                               nvl(l_estab_rec.m7_total,0)+
                               nvl(l_estab_rec.m8_total,0)+
                               nvl(l_estab_rec.m9_total,0)+
                               nvl(l_estab_rec.m10_total,0);
  --
  l_estab_rec.n_grand_total := nvl(l_estab_rec.n1_total,0)+
                               nvl(l_estab_rec.n2_total,0)+
                               nvl(l_estab_rec.n3_total,0)+
                               nvl(l_estab_rec.n4_total,0)+
                               nvl(l_estab_rec.n5_total,0)+
                               nvl(l_estab_rec.n6_total,0)+
                               nvl(l_estab_rec.n7_total,0)+
                               nvl(l_estab_rec.n8_total,0)+
                               nvl(l_estab_rec.n9_total,0)+
                               nvl(l_estab_rec.n10_total,0);
  --
  l_estab_rec.o_grand_total := nvl(l_estab_rec.o1_total,0)+
                               nvl(l_estab_rec.o2_total,0)+
                               nvl(l_estab_rec.o3_total,0)+
                               nvl(l_estab_rec.o4_total,0)+
                               nvl(l_estab_rec.o5_total,0)+
                               nvl(l_estab_rec.o6_total,0)+
                               nvl(l_estab_rec.o7_total,0)+
                               nvl(l_estab_rec.o8_total,0)+
                               nvl(l_estab_rec.o9_total,0)+
                               nvl(l_estab_rec.o10_total,0);
  --
  l_estab_rec.p_grand_total := nvl(l_estab_rec.p1_total,0)+
                               nvl(l_estab_rec.p2_total,0)+
                               nvl(l_estab_rec.p3_total,0)+
                               nvl(l_estab_rec.p4_total,0)+
                               nvl(l_estab_rec.p5_total,0)+
                               nvl(l_estab_rec.p6_total,0)+
                               nvl(l_estab_rec.p7_total,0)+
                               nvl(l_estab_rec.p8_total,0)+
                               nvl(l_estab_rec.p9_total,0)+
                               nvl(l_estab_rec.p10_total,0);
  --
  l_estab_rec.q_grand_total := nvl(l_estab_rec.q1_total,0)+
                               nvl(l_estab_rec.q2_total,0)+
                               nvl(l_estab_rec.q3_total,0)+
                               nvl(l_estab_rec.q4_total,0)+
                               nvl(l_estab_rec.q5_total,0)+
                               nvl(l_estab_rec.q6_total,0)+
                               nvl(l_estab_rec.q7_total,0)+
                               nvl(l_estab_rec.q8_total,0)+
                               nvl(l_estab_rec.q9_total,0)+
                               nvl(l_estab_rec.q10_total,0);
  --
  l_estab_rec.r_grand_total := nvl(l_estab_rec.r1_total,0)+
                               nvl(l_estab_rec.r2_total,0)+
                               nvl(l_estab_rec.r3_total,0)+
                               nvl(l_estab_rec.r4_total,0)+
                               nvl(l_estab_rec.r5_total,0)+
                               nvl(l_estab_rec.r6_total,0)+
                               nvl(l_estab_rec.r7_total,0)+
                               nvl(l_estab_rec.r8_total,0)+
                               nvl(l_estab_rec.r9_total,0)+
                               nvl(l_estab_rec.r10_total,0);
  --
  l_estab_rec.s_grand_total := nvl(l_estab_rec.s1_total,0)+
                               nvl(l_estab_rec.s2_total,0)+
                               nvl(l_estab_rec.s3_total,0)+
                               nvl(l_estab_rec.s4_total,0)+
                               nvl(l_estab_rec.s5_total,0)+
                               nvl(l_estab_rec.s6_total,0)+
                               nvl(l_estab_rec.s7_total,0)+
                               nvl(l_estab_rec.s8_total,0)+
                               nvl(l_estab_rec.s9_total,0)+
                               nvl(l_estab_rec.s10_total,0);
   --
  l_estab_rec.t_grand_total := nvl(l_estab_rec.t1_total,0)+
                               nvl(l_estab_rec.t2_total,0)+
                               nvl(l_estab_rec.t3_total,0)+
                               nvl(l_estab_rec.t4_total,0)+
                               nvl(l_estab_rec.t5_total,0)+
                               nvl(l_estab_rec.t6_total,0)+
                               nvl(l_estab_rec.t7_total,0)+
                               nvl(l_estab_rec.t8_total,0)+
                               nvl(l_estab_rec.t9_total,0)+
                               nvl(l_estab_rec.t10_total,0);
  --
  l_estab_rec.u_grand_total := nvl(l_estab_rec.u1_total,0)+
                               nvl(l_estab_rec.u2_total,0)+
                               nvl(l_estab_rec.u3_total,0)+
                               nvl(l_estab_rec.u4_total,0)+
                               nvl(l_estab_rec.u5_total,0)+
                               nvl(l_estab_rec.u6_total,0)+
                               nvl(l_estab_rec.u7_total,0)+
                               nvl(l_estab_rec.u8_total,0)+
                               nvl(l_estab_rec.u9_total,0)+
                               nvl(l_estab_rec.u10_total,0);

  --
  -- This means we are dealing with a state consolidated report
  -- which means we have to do some clever processing
  --
  if l_org_rec.form_type is null then
    --
    -- we need to add the new totals to the consolidate totals
    --
    l_consol_rec.state         := l_estab_rec.state;
    l_consol_rec.max_count     := nvl(l_consol_rec.max_count,0)+
                                  l_estab_rec.max_count;
    l_consol_rec.min_count     := nvl(l_consol_rec.min_count,0)+
                                  l_estab_rec.min_count;
    l_consol_rec.l_grand_total := nvl(l_consol_rec.l_grand_total,0)+
                                  l_estab_rec.l_grand_total;
    l_consol_rec.m_grand_total := nvl(l_consol_rec.m_grand_total,0)+
                                  l_estab_rec.m_grand_total;
    l_consol_rec.n_grand_total := nvl(l_consol_rec.n_grand_total,0)+
                                  l_estab_rec.n_grand_total;
    l_consol_rec.o_grand_total := nvl(l_consol_rec.o_grand_total,0)+
                                  l_estab_rec.o_grand_total;
    l_consol_rec.p_grand_total := nvl(l_consol_rec.p_grand_total,0)+
                                  l_estab_rec.p_grand_total;
    l_consol_rec.q_grand_total := nvl(l_consol_rec.q_grand_total,0)+
                                  l_estab_rec.q_grand_total;
    l_consol_rec.r_grand_total := nvl(l_consol_rec.r_grand_total,0)+
                                  l_estab_rec.r_grand_total;
    l_consol_rec.s_grand_total := nvl(l_consol_rec.s_grand_total,0)+
                                  l_estab_rec.s_grand_total;
    l_consol_rec.t_grand_total := nvl(l_consol_rec.t_grand_total,0)+
                                  l_estab_rec.t_grand_total;
    l_consol_rec.u_grand_total := nvl(l_consol_rec.u_grand_total,0)+
                                  l_estab_rec.u_grand_total;

    l_consol_rec.l1_total := nvl(l_consol_rec.l1_total,0)+
                             nvl(l_estab_rec.l1_total,0);
    l_consol_rec.l2_total := nvl(l_consol_rec.l2_total,0)+
                             nvl(l_estab_rec.l2_total,0);
    l_consol_rec.l3_total := nvl(l_consol_rec.l3_total,0)+
                             nvl(l_estab_rec.l3_total,0);
    l_consol_rec.l4_total := nvl(l_consol_rec.l4_total,0)+
                             nvl(l_estab_rec.l4_total,0);
    l_consol_rec.l5_total := nvl(l_consol_rec.l5_total,0)+
                             nvl(l_estab_rec.l5_total,0);
    l_consol_rec.l6_total := nvl(l_consol_rec.l6_total,0)+
                             nvl(l_estab_rec.l6_total,0);
    l_consol_rec.l7_total := nvl(l_consol_rec.l7_total,0)+
                             nvl(l_estab_rec.l7_total,0);
    l_consol_rec.l8_total := nvl(l_consol_rec.l8_total,0)+
                             nvl(l_estab_rec.l8_total,0);
    l_consol_rec.l9_total := nvl(l_consol_rec.l9_total,0)+
                             nvl(l_estab_rec.l9_total,0);
    l_consol_rec.l10_total := nvl(l_consol_rec.l10_total,0)+
                             nvl(l_estab_rec.l10_total,0);


    l_consol_rec.m1_total := nvl(l_consol_rec.m1_total,0)+
                             nvl(l_estab_rec.m1_total,0);
    l_consol_rec.m2_total := nvl(l_consol_rec.m2_total,0)+
                             nvl(l_estab_rec.m2_total,0);
    l_consol_rec.m3_total := nvl(l_consol_rec.m3_total,0)+
                             nvl(l_estab_rec.m3_total,0);
    l_consol_rec.m4_total := nvl(l_consol_rec.m4_total,0)+
                             nvl(l_estab_rec.m4_total,0);
    l_consol_rec.m5_total := nvl(l_consol_rec.m5_total,0)+
                             nvl(l_estab_rec.m5_total,0);
    l_consol_rec.m6_total := nvl(l_consol_rec.m6_total,0)+
                             nvl(l_estab_rec.m6_total,0);
    l_consol_rec.m7_total := nvl(l_consol_rec.m7_total,0)+
                             nvl(l_estab_rec.m7_total,0);
    l_consol_rec.m8_total := nvl(l_consol_rec.m8_total,0)+
                             nvl(l_estab_rec.m8_total,0);
    l_consol_rec.m9_total := nvl(l_consol_rec.m9_total,0)+
                             nvl(l_estab_rec.m9_total,0);
    l_consol_rec.m10_total := nvl(l_consol_rec.m10_total,0)+
                             nvl(l_estab_rec.m10_total,0);


    l_consol_rec.n1_total := nvl(l_consol_rec.n1_total,0)+
                             nvl(l_estab_rec.n1_total,0);
    l_consol_rec.n2_total := nvl(l_consol_rec.n2_total,0)+
                             nvl(l_estab_rec.n2_total,0);
    l_consol_rec.n3_total := nvl(l_consol_rec.n3_total,0)+
                             nvl(l_estab_rec.n3_total,0);
    l_consol_rec.n4_total := nvl(l_consol_rec.n4_total,0)+
                             nvl(l_estab_rec.n4_total,0);
    l_consol_rec.n5_total := nvl(l_consol_rec.n5_total,0)+
                             nvl(l_estab_rec.n5_total,0);
    l_consol_rec.n6_total := nvl(l_consol_rec.n6_total,0)+
                             nvl(l_estab_rec.n6_total,0);
    l_consol_rec.n7_total := nvl(l_consol_rec.n7_total,0)+
                             nvl(l_estab_rec.n7_total,0);
    l_consol_rec.n8_total := nvl(l_consol_rec.n8_total,0)+
                             nvl(l_estab_rec.n8_total,0);
    l_consol_rec.n9_total := nvl(l_consol_rec.n9_total,0)+
                             nvl(l_estab_rec.n9_total,0);
    l_consol_rec.n10_total := nvl(l_consol_rec.n10_total,0)+
                             nvl(l_estab_rec.n10_total,0);


    l_consol_rec.o1_total := nvl(l_consol_rec.o1_total,0)+
                             nvl(l_estab_rec.o1_total,0);
    l_consol_rec.o2_total := nvl(l_consol_rec.o2_total,0)+
                             nvl(l_estab_rec.o2_total,0);
    l_consol_rec.o3_total := nvl(l_consol_rec.o3_total,0)+
                             nvl(l_estab_rec.o3_total,0);
    l_consol_rec.o4_total := nvl(l_consol_rec.o4_total,0)+
                             nvl(l_estab_rec.o4_total,0);
    l_consol_rec.o5_total := nvl(l_consol_rec.o5_total,0)+
                             nvl(l_estab_rec.o5_total,0);
    l_consol_rec.o6_total := nvl(l_consol_rec.o6_total,0)+
                             nvl(l_estab_rec.o6_total,0);
    l_consol_rec.o7_total := nvl(l_consol_rec.o7_total,0)+
                             nvl(l_estab_rec.o7_total,0);
    l_consol_rec.o8_total := nvl(l_consol_rec.o8_total,0)+
                             nvl(l_estab_rec.o8_total,0);
    l_consol_rec.o9_total := nvl(l_consol_rec.o9_total,0)+
                             nvl(l_estab_rec.o9_total,0);
    l_consol_rec.o10_total := nvl(l_consol_rec.o10_total,0)+
                             nvl(l_estab_rec.o10_total,0);


    l_consol_rec.p1_total := nvl(l_consol_rec.p1_total,0)+
                             nvl(l_estab_rec.p1_total,0);
    l_consol_rec.p2_total := nvl(l_consol_rec.p2_total,0)+
                             nvl(l_estab_rec.p2_total,0);
    l_consol_rec.p3_total := nvl(l_consol_rec.p3_total,0)+
                             nvl(l_estab_rec.p3_total,0);
    l_consol_rec.p4_total := nvl(l_consol_rec.p4_total,0)+
                             nvl(l_estab_rec.p4_total,0);
    l_consol_rec.p5_total := nvl(l_consol_rec.p5_total,0)+
                             nvl(l_estab_rec.p5_total,0);
    l_consol_rec.p6_total := nvl(l_consol_rec.p6_total,0)+
                             nvl(l_estab_rec.p6_total,0);
    l_consol_rec.p7_total := nvl(l_consol_rec.p7_total,0)+
                             nvl(l_estab_rec.p7_total,0);
    l_consol_rec.p8_total := nvl(l_consol_rec.p8_total,0)+
                             nvl(l_estab_rec.p8_total,0);
    l_consol_rec.p9_total := nvl(l_consol_rec.p9_total,0)+
                             nvl(l_estab_rec.p9_total,0);
    l_consol_rec.p10_total := nvl(l_consol_rec.p10_total,0)+
                             nvl(l_estab_rec.p10_total,0);


    l_consol_rec.q1_total := nvl(l_consol_rec.q1_total,0)+
                             nvl(l_estab_rec.q1_total,0);
    l_consol_rec.q2_total := nvl(l_consol_rec.q2_total,0)+
                             nvl(l_estab_rec.q2_total,0);
    l_consol_rec.q3_total := nvl(l_consol_rec.q3_total,0)+
                             nvl(l_estab_rec.q3_total,0);
    l_consol_rec.q4_total := nvl(l_consol_rec.q4_total,0)+
                             nvl(l_estab_rec.q4_total,0);
    l_consol_rec.q5_total := nvl(l_consol_rec.q5_total,0)+
                             nvl(l_estab_rec.q5_total,0);
    l_consol_rec.q6_total := nvl(l_consol_rec.q6_total,0)+
                             nvl(l_estab_rec.q6_total,0);
    l_consol_rec.q7_total := nvl(l_consol_rec.q7_total,0)+
                             nvl(l_estab_rec.q7_total,0);
    l_consol_rec.q8_total := nvl(l_consol_rec.q8_total,0)+
                             nvl(l_estab_rec.q8_total,0);
    l_consol_rec.q9_total := nvl(l_consol_rec.q9_total,0)+
                             nvl(l_estab_rec.q9_total,0);
    l_consol_rec.q10_total := nvl(l_consol_rec.q10_total,0)+
                             nvl(l_estab_rec.q10_total,0);


    l_consol_rec.r1_total := nvl(l_consol_rec.r1_total,0)+
                             nvl(l_estab_rec.r1_total,0);
    l_consol_rec.r2_total := nvl(l_consol_rec.r2_total,0)+
                             nvl(l_estab_rec.r2_total,0);
    l_consol_rec.r3_total := nvl(l_consol_rec.r3_total,0)+
                             nvl(l_estab_rec.r3_total,0);
    l_consol_rec.r4_total := nvl(l_consol_rec.r4_total,0)+
                             nvl(l_estab_rec.r4_total,0);
    l_consol_rec.r5_total := nvl(l_consol_rec.r5_total,0)+
                             nvl(l_estab_rec.r5_total,0);
    l_consol_rec.r6_total := nvl(l_consol_rec.r6_total,0)+
                             nvl(l_estab_rec.r6_total,0);
    l_consol_rec.r7_total := nvl(l_consol_rec.r7_total,0)+
                             nvl(l_estab_rec.r7_total,0);
    l_consol_rec.r8_total := nvl(l_consol_rec.r8_total,0)+
                             nvl(l_estab_rec.r8_total,0);
    l_consol_rec.r9_total := nvl(l_consol_rec.r9_total,0)+
                             nvl(l_estab_rec.r9_total,0);
    l_consol_rec.r10_total := nvl(l_consol_rec.r10_total,0)+
                             nvl(l_estab_rec.r10_total,0);


    l_consol_rec.s1_total := nvl(l_consol_rec.s1_total,0)+
                             nvl(l_estab_rec.s1_total,0);
    l_consol_rec.s2_total := nvl(l_consol_rec.s2_total,0)+
                             nvl(l_estab_rec.s2_total,0);
    l_consol_rec.s3_total := nvl(l_consol_rec.s3_total,0)+
                             nvl(l_estab_rec.s3_total,0);
    l_consol_rec.s4_total := nvl(l_consol_rec.s4_total,0)+
                             nvl(l_estab_rec.s4_total,0);
    l_consol_rec.s5_total := nvl(l_consol_rec.s5_total,0)+
                             nvl(l_estab_rec.s5_total,0);
    l_consol_rec.s6_total := nvl(l_consol_rec.s6_total,0)+
                             nvl(l_estab_rec.s6_total,0);
    l_consol_rec.s7_total := nvl(l_consol_rec.s7_total,0)+
                             nvl(l_estab_rec.s7_total,0);
    l_consol_rec.s8_total := nvl(l_consol_rec.s8_total,0)+
                             nvl(l_estab_rec.s8_total,0);
    l_consol_rec.s9_total := nvl(l_consol_rec.s9_total,0)+
                             nvl(l_estab_rec.s9_total,0);
    l_consol_rec.s10_total := nvl(l_consol_rec.s10_total,0)+
                             nvl(l_estab_rec.s10_total,0);

    l_consol_rec.t1_total := nvl(l_consol_rec.t1_total,0)+
                             nvl(l_estab_rec.t1_total,0);
    l_consol_rec.t2_total := nvl(l_consol_rec.t2_total,0)+
                             nvl(l_estab_rec.t2_total,0);
    l_consol_rec.t3_total := nvl(l_consol_rec.t3_total,0)+
                             nvl(l_estab_rec.t3_total,0);
    l_consol_rec.t4_total := nvl(l_consol_rec.t4_total,0)+
                             nvl(l_estab_rec.t4_total,0);
    l_consol_rec.t5_total := nvl(l_consol_rec.t5_total,0)+
                             nvl(l_estab_rec.t5_total,0);
    l_consol_rec.t6_total := nvl(l_consol_rec.t6_total,0)+
                             nvl(l_estab_rec.t6_total,0);
    l_consol_rec.t7_total := nvl(l_consol_rec.t7_total,0)+
                             nvl(l_estab_rec.t7_total,0);
    l_consol_rec.t8_total := nvl(l_consol_rec.t8_total,0)+
                             nvl(l_estab_rec.t8_total,0);
    l_consol_rec.t9_total := nvl(l_consol_rec.t9_total,0)+
                             nvl(l_estab_rec.t9_total,0);
    l_consol_rec.t10_total := nvl(l_consol_rec.t10_total,0)+
                             nvl(l_estab_rec.t10_total,0);

    l_consol_rec.u1_total := nvl(l_consol_rec.u1_total,0)+
                             nvl(l_estab_rec.u1_total,0);
    l_consol_rec.u2_total := nvl(l_consol_rec.u2_total,0)+
                             nvl(l_estab_rec.u2_total,0);
    l_consol_rec.u3_total := nvl(l_consol_rec.u3_total,0)+
                             nvl(l_estab_rec.u3_total,0);
    l_consol_rec.u4_total := nvl(l_consol_rec.u4_total,0)+
                             nvl(l_estab_rec.u4_total,0);
    l_consol_rec.u5_total := nvl(l_consol_rec.u5_total,0)+
                             nvl(l_estab_rec.u5_total,0);
    l_consol_rec.u6_total := nvl(l_consol_rec.u6_total,0)+
                             nvl(l_estab_rec.u6_total,0);
    l_consol_rec.u7_total := nvl(l_consol_rec.u7_total,0)+
                             nvl(l_estab_rec.u7_total,0);
    l_consol_rec.u8_total := nvl(l_consol_rec.u8_total,0)+
                             nvl(l_estab_rec.u8_total,0);
    l_consol_rec.u9_total := nvl(l_consol_rec.u9_total,0)+
                             nvl(l_estab_rec.u9_total,0);
    l_consol_rec.u10_total := nvl(l_consol_rec.u10_total,0)+
                             nvl(l_estab_rec.u10_total,0);

    --
    l_org_rec.number_of_estabs := nvl(l_org_rec.number_of_estabs,0)+1;
    return;
    --
  end if;
  --
  l_string := l_org_rec.company_number||','||
              l_org_rec.contractor_type||','||
              l_org_rec.form_type||','||
              to_char(l_org_rec.number_of_estabs)||','||
              l_org_rec.ending_period||','||
              substr(l_org_rec.parent_company,1,40)||','||
              substr(l_org_rec.street,1,40)||','||
              substr(l_org_rec.street2,1,40)||','||
              substr(l_org_rec.city,1,20)||','||
              substr(l_org_rec.county,1,20)||','||
              substr(l_org_rec.state,1,20)||','||
              substr(l_org_rec.zip_code,1,10)||','||
              substr(l_org_rec.contact,1,40)||','||
              substr(l_org_rec.telephone,1,20)||','||
              substr(l_org_rec.email,1,40)||','||
              substr(l_estab_rec.reporting_name,1,40)||','||
              substr(l_estab_rec.street,1,40)||','||
              substr(l_estab_rec.street2,1,40)||','||
              substr(l_estab_rec.city,1,20)||','||
              substr(l_estab_rec.county,1,20)||','||
              substr(l_estab_rec.state,1,20)||','||
              substr(l_estab_rec.zip_code,1,10)||','||
              substr(nvl(l_estab_rec.naics,l_org_rec.naics),1,10)||','||
              substr(nvl(l_estab_rec.duns,l_org_rec.duns),1,20)||','||
              substr(nvl(l_estab_rec.ein,l_org_rec.ein),1,20)||','||
              nvl(l_estab_rec.l1_total,0)||','||
              nvl(l_estab_rec.l2_total,0)||','||
              nvl(l_estab_rec.l3_total,0)||','||
              nvl(l_estab_rec.l4_total,0)||','||
              nvl(l_estab_rec.l5_total,0)||','||
              nvl(l_estab_rec.l6_total,0)||','||
              nvl(l_estab_rec.l7_total,0)||','||
              nvl(l_estab_rec.l8_total,0)||','||
              nvl(l_estab_rec.l9_total,0)||','||
              nvl(l_estab_rec.l10_total,0)||','||
              nvl(l_estab_rec.l_grand_total,0)||','||
              nvl(l_estab_rec.m1_total,0)||','||
              nvl(l_estab_rec.m2_total,0)||','||
              nvl(l_estab_rec.m3_total,0)||','||
              nvl(l_estab_rec.m4_total,0)||','||
              nvl(l_estab_rec.m5_total,0)||','||
              nvl(l_estab_rec.m6_total,0)||','||
              nvl(l_estab_rec.m7_total,0)||','||
              nvl(l_estab_rec.m8_total,0)||','||
              nvl(l_estab_rec.m9_total,0)||','||
              nvl(l_estab_rec.m10_total,0)||','||
              nvl(l_estab_rec.m_grand_total,0)||','||
              nvl(l_estab_rec.n1_total,0)||','||
              nvl(l_estab_rec.n2_total,0)||','||
              nvl(l_estab_rec.n3_total,0)||','||
              nvl(l_estab_rec.n4_total,0)||','||
              nvl(l_estab_rec.n5_total,0)||','||
              nvl(l_estab_rec.n6_total,0)||','||
              nvl(l_estab_rec.n7_total,0)||','||
              nvl(l_estab_rec.n8_total,0)||','||
              nvl(l_estab_rec.n9_total,0)||','||
              nvl(l_estab_rec.n10_total,0)||','||
              nvl(l_estab_rec.n_grand_total,0)||','||
              nvl(l_estab_rec.o1_total,0)||','||
              nvl(l_estab_rec.o2_total,0)||','||
              nvl(l_estab_rec.o3_total,0)||','||
              nvl(l_estab_rec.o4_total,0)||','||
              nvl(l_estab_rec.o5_total,0)||','||
              nvl(l_estab_rec.o6_total,0)||','||
              nvl(l_estab_rec.o7_total,0)||','||
              nvl(l_estab_rec.o8_total,0)||','||
              nvl(l_estab_rec.o9_total,0)||','||
              nvl(l_estab_rec.o10_total,0)||','||
              nvl(l_estab_rec.o_grand_total,0)||','||
              nvl(l_estab_rec.p1_total,0)||','||
              nvl(l_estab_rec.p2_total,0)||','||
              nvl(l_estab_rec.p3_total,0)||','||
              nvl(l_estab_rec.p4_total,0)||','||
              nvl(l_estab_rec.p5_total,0)||','||
              nvl(l_estab_rec.p6_total,0)||','||
              nvl(l_estab_rec.p7_total,0)||','||
              nvl(l_estab_rec.p8_total,0)||','||
              nvl(l_estab_rec.p9_total,0)||','||
              nvl(l_estab_rec.p10_total,0)||','||
              nvl(l_estab_rec.p_grand_total,0)||','||
              nvl(l_estab_rec.q1_total,0)||','||
              nvl(l_estab_rec.q2_total,0)||','||
              nvl(l_estab_rec.q3_total,0)||','||
              nvl(l_estab_rec.q4_total,0)||','||
              nvl(l_estab_rec.q5_total,0)||','||
              nvl(l_estab_rec.q6_total,0)||','||
              nvl(l_estab_rec.q7_total,0)||','||
              nvl(l_estab_rec.q8_total,0)||','||
              nvl(l_estab_rec.q9_total,0)||','||
              nvl(l_estab_rec.q10_total,0)||','||
              nvl(l_estab_rec.q_grand_total,0)||','||
              nvl(l_estab_rec.r1_total,0)||','||
              nvl(l_estab_rec.r2_total,0)||','||
              nvl(l_estab_rec.r3_total,0)||','||
              nvl(l_estab_rec.r4_total,0)||','||
              nvl(l_estab_rec.r5_total,0)||','||
              nvl(l_estab_rec.r6_total,0)||','||
              nvl(l_estab_rec.r7_total,0)||','||
              nvl(l_estab_rec.r8_total,0)||','||
              nvl(l_estab_rec.r9_total,0)||','||
              nvl(l_estab_rec.r10_total,0)||','||
              nvl(l_estab_rec.r_grand_total,0)||','||
              nvl(l_estab_rec.s1_total,0)||','||
              nvl(l_estab_rec.s2_total,0)||','||
              nvl(l_estab_rec.s3_total,0)||','||
              nvl(l_estab_rec.s4_total,0)||','||
              nvl(l_estab_rec.s5_total,0)||','||
              nvl(l_estab_rec.s6_total,0)||','||
              nvl(l_estab_rec.s7_total,0)||','||
              nvl(l_estab_rec.s8_total,0)||','||
              nvl(l_estab_rec.s9_total,0)||','||
              nvl(l_estab_rec.s10_total,0)||','||
              nvl(l_estab_rec.s_grand_total,0)||','||
              nvl(l_estab_rec.t1_total,0)||','||
              nvl(l_estab_rec.t2_total,0)||','||
              nvl(l_estab_rec.t3_total,0)||','||
              nvl(l_estab_rec.t4_total,0)||','||
              nvl(l_estab_rec.t5_total,0)||','||
              nvl(l_estab_rec.t6_total,0)||','||
              nvl(l_estab_rec.t7_total,0)||','||
              nvl(l_estab_rec.t8_total,0)||','||
              nvl(l_estab_rec.t9_total,0)||','||
              nvl(l_estab_rec.t10_total,0)||','||
              nvl(l_estab_rec.t_grand_total,0)||','||
              nvl(l_estab_rec.u1_total,0)||','||
              nvl(l_estab_rec.u2_total,0)||','||
              nvl(l_estab_rec.u3_total,0)||','||
              nvl(l_estab_rec.u4_total,0)||','||
              nvl(l_estab_rec.u5_total,0)||','||
              nvl(l_estab_rec.u6_total,0)||','||
              nvl(l_estab_rec.u7_total,0)||','||
              nvl(l_estab_rec.u8_total,0)||','||
              nvl(l_estab_rec.u9_total,0)||','||
              nvl(l_estab_rec.u10_total,0)||','||
              nvl(l_estab_rec.u_grand_total,0)||','||
              nvl(l_estab_rec.max_count,0)||','||
              nvl(l_estab_rec.min_count,0);
  --
  l_org_rec.form_type := null;
  l_month_rec := l_month_rec_blank;
  --
  fnd_file.put_line
    (which => fnd_file.output,
     buff  => l_string);
  --
end;
--
procedure loop_through_establishments(p_hierarchy_version_id in number,
                                      p_business_group_id    in number,
                                      p_start_date           in date,
                                      p_end_date             in date) is

  l_hierarchy_node_id number;

  -- orig cursor, cost of 9 as stands.
  cursor c1 is
    select upper(replace(hlei1.lei_information1,',',' ')) reporting_name,
           hlei1.lei_information2 unit_number,
           upper(replace(eloc.address_line_1,',',' ')||
                 ' ') street,
            upper(
                 replace(eloc.address_line_2,',',' ')||
                 ' '||
                 replace(eloc.address_line_3,',',' ')
                 ) street2,
           upper(eloc.town_or_city) city,
           upper(eloc.region_1) county,
           upper(eloc.region_2) state,
           eloc.postal_code zip_code,
           hlei2.lei_information4 naics,
           hlei2.lei_information2 duns,
           hlei2.lei_information6 ein,
           hlei2.lei_information10 hq,
           eloc.location_id,
           pghn.hierarchy_node_id
    from   per_gen_hierarchy_nodes pghn,
           hr_location_extra_info hlei1,
           hr_location_extra_info hlei2,
           hr_locations_all eloc
    where  pghn.hierarchy_version_id = p_hierarchy_version_id
    and    pghn.node_type = 'EST'
    and    eloc.location_id = pghn.entity_id
    and    hlei1.location_id = pghn.entity_id
    and    hlei1.location_id = hlei2.location_id
    and    hlei1.information_type = 'VETS-100 Specific Information'
    and    hlei1.lei_information_category= 'VETS-100 Specific Information'
    and    hlei2.information_type = 'Establishment Information'
    and    hlei2.lei_information_category= 'Establishment Information'
    order  by eloc.region_2,decode(hlei2.lei_information10,'Y',1,2);

  l_c1 c1%rowtype;

  cursor c2 is

   select
 count(decode(peo.per_information25,'VETDIS',1,'AFSMNSDIS',1,'OTEDV',1,'AFSMDIS',
 1,'NSDIS',1,'AFSMDISOP',1,'AFSMNSDISOP',1,'NSDISOP',1,null)) no_dis_vets,
 count(decode(peo.per_information25,'OTEV',1,'OTEDV',1,'AFSMDISOP',1,'AFSMNSDISOP',
 1,'AFSMOP',1,'NSOP',1,'AFSMNSOP',1,'NSDISOP',1,null)) no_other_vets ,
 count(decode(peo.per_information25,'AFSM',1,'AFSMNSDIS',1,'AFSMDIS',1,'AFSMDISOP',
 1,'AFSMNSDISOP',1,'AFSMOP',1,'AFSMNSOP',1,'AFSMNS',1,null)) no_armed_vets,
 count(decode(peo.per_information25,'NOTVET',1,NULL,1,'VET',1,null)) no_not_vets,
 hrl.lookup_code lookup_code
   from   per_periods_of_service          pds,
           per_all_people_f                peo,
           per_all_assignments_f           ass,
           hr_organization_information     hoi1,
           hr_organization_information     hoi2,
           per_jobs                        job,
           hr_lookups                      hrl
    where
           pds.date_start <= p_end_date
    and    nvl(pds.actual_termination_date,p_end_date + 1) >= p_end_date
    and    pds.person_id = ass.person_id
    and    peo.person_id = ass.person_id
    and    p_end_date between job.date_from and nvl(job.date_to, p_end_date)
    and    job.job_information1 = hrl.lookup_code
    and    hrl.lookup_type = 'US_EEO1_JOB_CATEGORIES'
    and    ass.job_id = job.job_id
    and p_end_date between peo.effective_start_date and peo.effective_end_date
    and    peo.current_employee_flag        = 'Y'
    and    ass.assignment_type             = 'E'
    and    ass.primary_flag                = 'Y'
    and    ass.effective_start_date =
             (select max(paf2.effective_start_date)
              from   per_all_assignments_f paf2
              where  paf2.person_id = ass.person_id
              and    paf2.primary_flag = 'Y'
              and    paf2.assignment_type = 'E'
              and    paf2.effective_start_date <= p_end_date
              )
    and    peo.effective_start_date =
             (select max(peo2.effective_start_date)
              from   per_all_people_f peo2
              where  peo2.person_id = peo.person_id
              and    peo.current_employee_flag = 'Y'
              and    peo2.effective_start_date < p_end_date
              )
    and     to_char(ass.assignment_status_type_id) = hoi1.org_information1
    and     hoi1.org_information_context = 'Reporting Statuses'
    and     hoi1.organization_id = p_business_group_id
    and     ass.employment_category = hoi2.org_information1
    and     hoi2.organization_id = p_business_group_id
    and     hoi2.org_information_context = 'Reporting Categories'
    and p_end_date between ass.effective_start_date and ass.effective_end_date
    and     ass.location_id in
            (select entity_id
             from   per_gen_hierarchy_nodes
             where  hierarchy_version_id = p_hierarchy_version_id
             and    (hierarchy_node_id = l_hierarchy_node_id
                     or parent_hierarchy_node_id = l_hierarchy_node_id
                     ))
    group by hrl.lookup_code;


  l_c2 c2%rowtype;

   cursor c2_ns is

   select
count(decode(peo.per_information25,'NS',1,'AFSMNSDIS',1,'NSDIS',1,'AFSMNSDISOP',
1,'NSOP',1,'AFSMNSOP',1,'AFSMNS',1,'NSDISOP',1,null)) no_recently_vets ,
 hrl.lookup_code lookup_code
   from   per_periods_of_service          pds,
           per_all_people_f                peo,
           per_all_assignments_f           ass,
           hr_organization_information     hoi1,
           hr_organization_information     hoi2,
           per_jobs                        job,
           hr_lookups                      hrl
    where
           pds.date_start <= p_end_date
    and    nvl(pds.actual_termination_date,p_end_date + 1) >= p_end_date
    and    pds.person_id = ass.person_id
    and    peo.person_id = ass.person_id
    and    p_end_date between job.date_from and nvl(job.date_to, p_end_date)
    and    job.job_information1 = hrl.lookup_code
    and    hrl.lookup_type = 'US_EEO1_JOB_CATEGORIES'
    and    ass.job_id = job.job_id
    and p_end_date between peo.effective_start_date and peo.effective_end_date
    and    peo.current_employee_flag        = 'Y'
    and    ass.assignment_type             = 'E'
    and    ass.primary_flag                = 'Y'
    and    ass.effective_start_date =
             (select max(paf2.effective_start_date)
              from   per_all_assignments_f paf2
              where  paf2.person_id = ass.person_id
              and    paf2.primary_flag = 'Y'
              and    paf2.assignment_type = 'E'
              and    paf2.effective_start_date <= p_end_date
              )
    and    peo.effective_start_date =
             (select max(peo2.effective_start_date)
              from   per_all_people_f peo2
              where  peo2.person_id = peo.person_id
              and    peo.current_employee_flag = 'Y'
              and    peo2.effective_start_date < p_end_date
              )
    and     to_char(ass.assignment_status_type_id) = hoi1.org_information1
    and     hoi1.org_information_context = 'Reporting Statuses'
    and     hoi1.organization_id = p_business_group_id
    and     ass.employment_category = hoi2.org_information1
    and     hoi2.organization_id = p_business_group_id
    and     hoi2.org_information_context = 'Reporting Categories'
    and p_end_date between ass.effective_start_date and ass.effective_end_date
    and     ass.location_id in
            (select entity_id
             from   per_gen_hierarchy_nodes
             where  hierarchy_version_id = p_hierarchy_version_id
             and    (hierarchy_node_id = l_hierarchy_node_id
                     or parent_hierarchy_node_id = l_hierarchy_node_id
                     ))
    and check_recent_or_not(peo.person_id,p_end_date) > 0

    group by hrl.lookup_code;


  l_c2_ns c2_ns%rowtype;

 cursor c3 is
 select
 count(decode(peo.per_information25,'VETDIS',1,'AFSMNSDIS',1,'OTEDV',1,
 'AFSMDIS',1,'NSDIS',1,'AFSMDISOP',1,'AFSMNSDISOP',1,'NSDISOP',1,null)) nh_dis_vets,
 count(decode(peo.per_information25,'OTEV',1,'OTEDV',1,'AFSMDISOP',1,
 'AFSMNSDISOP',1,'AFSMOP',1,'NSOP',1,'AFSMNSOP',1,'NSDISOP',1,null)) nh_other_vets ,
 count(decode(peo.per_information25,'AFSM',1,'AFSMNSDIS',1,'AFSMDIS',1,'AFSMDISOP',1,
 'AFSMNSDISOP',1,'AFSMOP',1,'AFSMNSOP',1,'AFSMNS',1,null)) nh_armed_vets,
 count(decode(peo.per_information25,'NOTVET',1,NULL,1,'VET',1,null)) nh_not_vets,
 hrl.lookup_code lookup_code
FROM    per_all_people_f             peo,
               per_all_assignments_f             ass,
               per_jobs                                job,
               hr_lookups                             hrl,
	       per_periods_of_service          pps
WHERE   peo.person_id  = ass.person_id
AND     peo.person_id  = pps.person_id
AND     peo.business_group_id =  p_business_group_id
AND     ass.business_group_id  =  p_business_group_id
AND     job.business_group_id  =  p_business_group_id
AND     pps.business_group_id  =  p_business_group_id
AND     ass.job_id  = job.job_id
AND     peo.current_employee_flag     = 'Y'
AND     ass.assignment_type                = 'E'
AND     ass.primary_flag                      = 'Y'
AND     job.job_information_category  = 'US'
AND     ass.effective_start_date  <= p_end_date
AND     job.job_information1 = hrl.lookup_code
AND     hrl.lookup_type = 'US_EEO1_JOB_CATEGORIES'
AND     ass.effective_start_date = (select max(paf2.effective_start_date)
                  from per_all_assignments_f paf2
                  where paf2.person_id = ass.person_id
						      and paf2.assignment_id = ass.assignment_id
                  and paf2.effective_start_date = peo.effective_start_date
                  and paf2.primary_flag = 'Y'
                  and paf2.assignment_type = 'E'
                  and paf2.effective_start_date <= p_end_date)
AND months_between (p_end_date,pps.date_start) <= 12
AND months_between (p_end_date,pps.date_start) >= 0
AND peo.effective_start_date     = pps.date_start
AND EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE TO_CHAR(ASS.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND hoi1.org_information_context = 'Reporting Statuses'
              AND hoi1.organization_id         = p_business_group_id
              AND ass.employment_category      = hoi2.org_information1
              AND hoi2.organization_id         = p_business_group_id
              AND hoi2.org_information_context = 'Reporting Categories'
              AND hoi1.organization_id         =  hoi2.organization_id)
and     ass.location_id in
            (select entity_id
             from   per_gen_hierarchy_nodes
             where  hierarchy_version_id = p_hierarchy_version_id
             and    (hierarchy_node_id = l_hierarchy_node_id
                     or parent_hierarchy_node_id = l_hierarchy_node_id
                     ))
group by hrl.lookup_code;

l_c3 c3%rowtype;

cursor c3_ns is
 select
count(decode(peo.per_information25,'NS',1,'AFSMNSDIS',1,'NSDIS',1,
'AFSMNSDISOP',1,'NSOP',1,'AFSMNSOP',1,'AFSMNS',
1,'NSDISOP',1,null)) nh_recently_vets ,
hrl.lookup_code lookup_code
FROM    per_all_people_f             peo,
               per_all_assignments_f             ass,
               per_jobs                                job,
               hr_lookups                             hrl,
	       per_periods_of_service          pps
WHERE   peo.person_id  = ass.person_id
AND     peo.person_id  = pps.person_id
AND     peo.business_group_id =  p_business_group_id
AND     ass.business_group_id  =  p_business_group_id
AND     job.business_group_id  =  p_business_group_id
AND     pps.business_group_id  =  p_business_group_id
AND     ass.job_id  = job.job_id
AND     peo.current_employee_flag     = 'Y'
AND     ass.assignment_type                = 'E'
AND     ass.primary_flag                      = 'Y'
AND     job.job_information_category  = 'US'
AND     ass.effective_start_date  <= p_end_date
AND     job.job_information1 = hrl.lookup_code
AND     hrl.lookup_type = 'US_EEO1_JOB_CATEGORIES'
AND     ass.effective_start_date = (select max(paf2.effective_start_date)
                                    from per_all_assignments_f paf2
                                    where paf2.person_id = ass.person_id
						      and paf2.assignment_id = ass.assignment_id
                  and paf2.effective_start_date = peo.effective_start_date
                  and paf2.primary_flag = 'Y'
                  and paf2.assignment_type = 'E'
                  and paf2.effective_start_date <= p_end_date)
AND months_between (p_end_date,pps.date_start) <= 12
AND months_between (p_end_date,pps.date_start) >= 0
AND peo.effective_start_date     = pps.date_start
AND EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION HOI2
            WHERE TO_CHAR(ASS.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND hoi1.org_information_context = 'Reporting Statuses'
              AND hoi1.organization_id         = p_business_group_id
              AND ass.employment_category      = hoi2.org_information1
              AND hoi2.organization_id         = p_business_group_id
              AND hoi2.org_information_context = 'Reporting Categories'
              AND hoi1.organization_id         =  hoi2.organization_id)
and     ass.location_id in
            (select entity_id
             from   per_gen_hierarchy_nodes
             where  hierarchy_version_id = p_hierarchy_version_id
             and    (hierarchy_node_id = l_hierarchy_node_id
                     or parent_hierarchy_node_id = l_hierarchy_node_id
                     ))
 and check_recent_or_not(peo.person_id,p_end_date) > 0

    group by hrl.lookup_code;

l_c3_ns c3_ns%rowtype;

  -- cursor c_min_max is

  l_month_start_date date := null;
  l_month_end_date date := null;

  cursor c_min_max is
  SELECT count(*) num_people
    FROM  per_all_assignments_f paf
    WHERE paf.business_group_id = p_business_group_id
    AND    paf.primary_flag = 'Y'
    AND    paf.assignment_type = 'E'
    --9011580
    --AND  l_month_start_date between asg.effective_start_date and asg.effective_end_date
    and  paf.effective_end_date >= l_month_start_date
    AND  l_month_end_date between paf.effective_start_date and paf.effective_end_date
    AND     paf.effective_start_date = (select max(paf2.effective_start_date)
                                      from per_all_assignments_f paf2
                                     where paf2.person_id = paf.person_id
                                       and paf2.primary_flag = 'Y'
                                       and paf2.assignment_type = 'E'
                                       and paf2.effective_start_date
                                           <= l_month_end_date
                                     )
    AND     paf.business_group_id = p_business_group_id
    AND    to_char(paf.location_id) in
           (SELECT entity_id
            FROM   per_gen_hierarchy_nodes
            WHERE  hierarchy_version_id = p_hierarchy_version_id
            AND    (hierarchy_node_id = l_hierarchy_node_id
                    OR parent_hierarchy_node_id = l_hierarchy_node_id
           ))
    AND EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION  HOI2
            WHERE TO_CHAR(paf.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND   hoi1.org_information_context     = 'Reporting Statuses'
              AND    hoi1.organization_id            = P_BUSINESS_GROUP_ID
              AND    paf.employment_category         = hoi2.org_information1
              AND    hoi2.organization_id            = P_BUSINESS_GROUP_ID
              AND    hoi2.org_information_context    = 'Reporting Categories');

  l_min_max c_min_max%rowtype;

  cursor c_tot_emps is
  SELECT count(distinct paf.person_id) num_people
    FROM  per_all_assignments_f paf
    --, per_jobs_vl job
    ,per_periods_of_service pps --8667924
    WHERE
   -- job.job_information_category   = 'US'
  --  and  p_end_date between job.date_from and nvl(job.date_to,p_end_date)
     paf.person_id = pps.person_id
    and paf.business_group_id = pps.business_group_id
   -- and  job.job_information1             is not null
    --and  paf.job_id                     = job.job_id
    and  paf.business_group_id = p_business_group_id
    AND  paf.primary_flag = 'Y'
    AND  paf.assignment_type = 'E'
    and  p_end_date between paf.effective_start_date and paf.effective_end_date
    and  paf.effective_start_date = (select max(paf2.effective_start_date)
                                         from per_all_assignments_f paf2
                                        where paf2.person_id = paf.person_id
                                          and paf2.primary_flag = 'Y'
                                          and paf2.assignment_type = 'E'
                                          and paf2.effective_start_date
                                              <= p_end_date)
    AND    to_char(paf.location_id) in
           (SELECT entity_id
            FROM   per_gen_hierarchy_nodes
            WHERE  hierarchy_version_id = p_hierarchy_version_id
            AND    (hierarchy_node_id = l_hierarchy_node_id
                    OR parent_hierarchy_node_id = l_hierarchy_node_id
           ))
    AND
    ( EXISTS (
           SELECT 'X'
             FROM HR_ORGANIZATION_INFORMATION  HOI1,
                  HR_ORGANIZATION_INFORMATION  HOI2
            WHERE TO_CHAR(paf.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
              AND   hoi1.org_information_context     = 'Reporting Statuses'
              AND    hoi1.organization_id            = P_BUSINESS_GROUP_ID
              AND    paf.employment_category         = hoi2.org_information1
              AND    hoi2.organization_id            = P_BUSINESS_GROUP_ID
              AND    hoi2.org_information_context    = 'Reporting Categories')
        OR /*8667924*/
      months_between(p_end_date,pps.actual_termination_date) between 0 and 12 );


  l_proc varchar2(40) := 'loop_through_establishments';
  --
begin
  --
  hr_utility.set_location(l_proc,10);
  --
  open c1;
    --
    loop
      --
      fetch c1 into l_c1;
      exit when c1%notfound;
      --
      hr_utility.set_location(l_proc,20);
      hr_utility.trace('l_c1.street : ' || l_c1.street);
      l_estab_rec := l_estab_rec_blank;
      --
      l_hierarchy_node_id := l_c1.hierarchy_node_id;
      l_estab_rec.reporting_name := l_c1.reporting_name;
      l_estab_rec.unit_number := l_c1.unit_number;
      l_estab_rec.street := l_c1.street;
      l_estab_rec.street2 := l_c1.street2;
      l_estab_rec.city := l_c1.city;
      l_estab_rec.county := l_c1.county;
      l_estab_rec.state := l_c1.state;
      l_estab_rec.zip_code := l_c1.zip_code;
      l_estab_rec.naics := l_c1.naics;
      l_estab_rec.duns := l_c1.duns;
      l_estab_rec.ein := l_c1.ein;
      l_estab_rec.hq := l_c1.hq;
      --
      open c2;
        --
        loop
          --
          fetch c2 into l_c2;
          exit when c2%notfound;
          --
          hr_utility.set_location(l_proc,30);
          if l_c2.lookup_code = '10' then
            --Executive/Senior Level Officials and Managers
            l_estab_rec.l1_total := l_c2.no_dis_vets;
            l_estab_rec.m1_total := l_c2.no_other_vets;
            l_estab_rec.n1_total := l_c2.no_armed_vets;
            --l_estab_rec.o1_total := l_c2.no_recently_vets;
            l_estab_rec.p1_total := l_c2.no_dis_vets
                                     + l_c2.no_other_vets
                                     + l_c2.no_armed_vets
                                     + l_c2.no_not_vets;

          elsif l_c2.lookup_code = '1' then
            --First/Mid Level Officials and Managers
            l_estab_rec.l2_total := l_c2.no_dis_vets;
            l_estab_rec.m2_total := l_c2.no_other_vets;
            l_estab_rec.n2_total := l_c2.no_armed_vets;
            --l_estab_rec.o2_total := l_c2.no_recently_vets;
            l_estab_rec.p2_total := l_c2.no_dis_vets
                                    + l_c2.no_other_vets
                                    + l_c2.no_armed_vets
                                    + l_c2.no_not_vets;

          elsif l_c2.lookup_code = '2' then
            --Professionals
            l_estab_rec.l3_total := l_c2.no_dis_vets;
            l_estab_rec.m3_total := l_c2.no_other_vets;
            l_estab_rec.n3_total := l_c2.no_armed_vets;
            --l_estab_rec.o3_total := l_c2.no_recently_vets;
            l_estab_rec.p3_total := l_c2.no_dis_vets
                                     + l_c2.no_other_vets
                                     + l_c2.no_armed_vets
                                     + l_c2.no_not_vets;

          elsif l_c2.lookup_code = '3' then
            --Technicians
            l_estab_rec.l4_total := l_c2.no_dis_vets;
            l_estab_rec.m4_total := l_c2.no_other_vets;
            l_estab_rec.n4_total := l_c2.no_armed_vets;
            --l_estab_rec.o4_total := l_c2.no_recently_vets;
            l_estab_rec.p4_total := l_c2.no_dis_vets
                                    + l_c2.no_other_vets
                                    + l_c2.no_armed_vets
                                    + l_c2.no_not_vets;

          elsif l_c2.lookup_code = '4' then
            --Sales Workers
            l_estab_rec.l5_total := l_c2.no_dis_vets;
            l_estab_rec.m5_total := l_c2.no_other_vets;
            l_estab_rec.n5_total := l_c2.no_armed_vets;
            --l_estab_rec.o5_total := l_c2.no_recently_vets;
            l_estab_rec.p5_total := l_c2.no_dis_vets
                                    + l_c2.no_other_vets
                                    + l_c2.no_armed_vets
                                    + l_c2.no_not_vets;

          elsif l_c2.lookup_code = '5' then
            --Administrative Support Workers
            l_estab_rec.l6_total := l_c2.no_dis_vets;
            l_estab_rec.m6_total := l_c2.no_other_vets;
            l_estab_rec.n6_total := l_c2.no_armed_vets;
            --l_estab_rec.o6_total := l_c2.no_recently_vets;
            l_estab_rec.p6_total := l_c2.no_dis_vets
                                     + l_c2.no_other_vets
                                     + l_c2.no_armed_vets
                                     +  l_c2.no_not_vets;

          elsif l_c2.lookup_code = '6' then
            --Craft Workers
            l_estab_rec.l7_total := l_c2.no_dis_vets;
            l_estab_rec.m7_total := l_c2.no_other_vets;
            l_estab_rec.n7_total := l_c2.no_armed_vets;
            --l_estab_rec.o7_total := l_c2.no_recently_vets;
            l_estab_rec.p7_total := l_c2.no_dis_vets
                                     + l_c2.no_other_vets
                                     + l_c2.no_armed_vets
                                     +  l_c2.no_not_vets;

          elsif l_c2.lookup_code = '7' then
            --Operatives
            l_estab_rec.l8_total := l_c2.no_dis_vets;
            l_estab_rec.m8_total := l_c2.no_other_vets;
            l_estab_rec.n8_total := l_c2.no_armed_vets;
            --l_estab_rec.o8_total := l_c2.no_recently_vets;
            l_estab_rec.p8_total := l_c2.no_dis_vets
                                     + l_c2.no_other_vets
                                     + l_c2.no_armed_vets
                                     + l_c2.no_not_vets;

          elsif l_c2.lookup_code = '8' then
            --Laborers and Helpers
            l_estab_rec.l9_total := l_c2.no_dis_vets;
            l_estab_rec.m9_total := l_c2.no_other_vets;
            l_estab_rec.n9_total := l_c2.no_armed_vets;
            --l_estab_rec.o9_total := l_c2.no_recently_vets;
            l_estab_rec.p9_total := l_c2.no_dis_vets
                                    + l_c2.no_other_vets
                                    + l_c2.no_armed_vets
                                    +  l_c2.no_not_vets;

          elsif l_c2.lookup_code = '9' then
            --Service Workers
            l_estab_rec.l10_total := l_c2.no_dis_vets;
            l_estab_rec.m10_total := l_c2.no_other_vets;
            l_estab_rec.n10_total := l_c2.no_armed_vets;
            --l_estab_rec.o10_total := l_c2.no_recently_vets;
            l_estab_rec.p10_total := l_c2.no_dis_vets
                                     + l_c2.no_other_vets
                                     + l_c2.no_armed_vets
                                     + l_c2.no_not_vets;

          end if;

        end loop;

      close c2;

      open c2_ns;
        loop
         fetch c2_ns into l_c2_ns;
         exit when c2_ns%notfound;

           if l_c2_ns.lookup_code = '10' then
            --Executive/Senior Level Officials and Managers
           l_estab_rec.o1_total := l_c2_ns.no_recently_vets;
           l_estab_rec.p1_total := l_estab_rec.p1_total
                                   + l_c2_ns.no_recently_vets;

          elsif l_c2_ns.lookup_code = '1' then
            --First/Mid Level Officials and Managers
            l_estab_rec.o2_total := l_c2_ns.no_recently_vets;
            l_estab_rec.p2_total := l_estab_rec.p2_total
                                     + l_c2_ns.no_recently_vets;

          elsif l_c2_ns.lookup_code = '2' then
            --Professionals
            l_estab_rec.o3_total := l_c2_ns.no_recently_vets;
            l_estab_rec.p3_total := l_estab_rec.p3_total
                                    + l_c2_ns.no_recently_vets;

          elsif l_c2_ns.lookup_code = '3' then
            --Technicians
            l_estab_rec.o4_total := l_c2_ns.no_recently_vets;
            l_estab_rec.p4_total := l_estab_rec.p4_total
                                     + l_c2_ns.no_recently_vets;

          elsif l_c2_ns.lookup_code = '4' then
            --Sales Workers
             l_estab_rec.o5_total := l_c2_ns.no_recently_vets;
             l_estab_rec.p5_total := l_estab_rec.p5_total
                                     + l_c2_ns.no_recently_vets;

          elsif l_c2_ns.lookup_code = '5' then
            --Administrative Support Workers
              l_estab_rec.o6_total := l_c2_ns.no_recently_vets;
              l_estab_rec.p6_total := l_estab_rec.p6_total
                                      + l_c2_ns.no_recently_vets;

          elsif l_c2_ns.lookup_code = '6' then
            --Craft Workers
                l_estab_rec.o7_total := l_c2_ns.no_recently_vets;
                l_estab_rec.p7_total := l_estab_rec.p7_total
                                        + l_c2_ns.no_recently_vets;

          elsif l_c2_ns.lookup_code = '7' then
            --Operatives
             l_estab_rec.o8_total := l_c2_ns.no_recently_vets;
             l_estab_rec.p8_total := l_estab_rec.p8_total
                                    + l_c2_ns.no_recently_vets;

          elsif l_c2_ns.lookup_code = '8' then
            --Laborers and Helpers
             l_estab_rec.o9_total := l_c2_ns.no_recently_vets;
             l_estab_rec.p9_total := l_estab_rec.p9_total
                                    + l_c2_ns.no_recently_vets;

          elsif l_c2_ns.lookup_code = '9' then
            --Service Workers
            l_estab_rec.o10_total := l_c2_ns.no_recently_vets;
            l_estab_rec.p10_total := l_estab_rec.p10_total
                                    + l_c2_ns.no_recently_vets;

          end if;

        end loop;
      close c2_ns;

      open c3;
        --
        loop
          --
          fetch c3 into l_c3;
          exit when c3%notfound;
          --
          hr_utility.set_location(l_proc,40);
          if l_c3.lookup_code = '10' then
            --
            l_estab_rec.q1_total := l_c3.nh_dis_vets;
            l_estab_rec.r1_total := l_c3.nh_other_vets;
            l_estab_rec.s1_total := l_c3.nh_armed_vets;
            l_estab_rec.u1_total := l_c3.nh_not_vets+
                                    l_c3.nh_dis_vets+
                                    l_c3.nh_other_vets+
                                    l_c3.nh_armed_vets;
            --
          elsif l_c3.lookup_code = '1' then
            --
            l_estab_rec.q2_total := l_c3.nh_dis_vets;
            l_estab_rec.r2_total := l_c3.nh_other_vets;
            l_estab_rec.s2_total := l_c3.nh_armed_vets;
            l_estab_rec.u2_total := l_c3.nh_not_vets+
                                    l_c3.nh_dis_vets+
                                    l_c3.nh_other_vets+
                                    l_c3.nh_armed_vets;
            --
          elsif l_c3.lookup_code = '2' then
            --
            l_estab_rec.q3_total := l_c3.nh_dis_vets;
            l_estab_rec.r3_total := l_c3.nh_other_vets;
            l_estab_rec.s3_total := l_c3.nh_armed_vets;
            l_estab_rec.u3_total := l_c3.nh_not_vets+
                                    l_c3.nh_dis_vets+
                                    l_c3.nh_other_vets+
                                    l_c3.nh_armed_vets;
            --
          elsif l_c3.lookup_code = '3' then
            --
            l_estab_rec.q4_total := l_c3.nh_dis_vets;
            l_estab_rec.r4_total := l_c3.nh_other_vets;
            l_estab_rec.s4_total := l_c3.nh_armed_vets;
            l_estab_rec.u4_total := l_c3.nh_not_vets+
                                    l_c3.nh_dis_vets+
                                    l_c3.nh_other_vets+
                                    l_c3.nh_armed_vets;
            --
          elsif l_c3.lookup_code = '4' then
            --
            l_estab_rec.q5_total := l_c3.nh_dis_vets;
            l_estab_rec.r5_total := l_c3.nh_other_vets;
            l_estab_rec.s5_total := l_c3.nh_armed_vets;
            l_estab_rec.u5_total := l_c3.nh_not_vets+
                                    l_c3.nh_dis_vets+
                                    l_c3.nh_other_vets+
                                    l_c3.nh_armed_vets;
            --
          elsif l_c3.lookup_code = '5' then
            --
            l_estab_rec.q6_total := l_c3.nh_dis_vets;
            l_estab_rec.r6_total := l_c3.nh_other_vets;
            l_estab_rec.s6_total := l_c3.nh_armed_vets;
            l_estab_rec.u6_total := l_c3.nh_not_vets+
                                    l_c3.nh_dis_vets+
                                    l_c3.nh_other_vets+
                                    l_c3.nh_armed_vets;

          elsif l_c3.lookup_code = '6' then
            --
            l_estab_rec.q7_total := l_c3.nh_dis_vets;
            l_estab_rec.r7_total := l_c3.nh_other_vets;
            l_estab_rec.s7_total := l_c3.nh_armed_vets;
            l_estab_rec.u7_total := l_c3.nh_not_vets+
                                    l_c3.nh_dis_vets+
                                    l_c3.nh_other_vets+
                                    l_c3.nh_armed_vets;
            --
          elsif l_c3.lookup_code = '7' then
            --
            l_estab_rec.q8_total := l_c3.nh_dis_vets;
            l_estab_rec.r8_total := l_c3.nh_other_vets;
            l_estab_rec.s8_total := l_c3.nh_armed_vets;
            l_estab_rec.u8_total := l_c3.nh_not_vets+
                                    l_c3.nh_dis_vets+
                                    l_c3.nh_other_vets+
                                    l_c3.nh_armed_vets;
            --
          elsif l_c3.lookup_code = '8' then
            --
            l_estab_rec.q9_total := l_c3.nh_dis_vets;
            l_estab_rec.r9_total := l_c3.nh_other_vets;
            l_estab_rec.s9_total := l_c3.nh_armed_vets;
            l_estab_rec.u9_total := l_c3.nh_not_vets+
                                    l_c3.nh_dis_vets+
                                    l_c3.nh_other_vets+
                                    l_c3.nh_armed_vets;
            --
          elsif l_c3.lookup_code = '9' then
            --
            l_estab_rec.q10_total := l_c3.nh_dis_vets;
            l_estab_rec.r10_total := l_c3.nh_other_vets;
            l_estab_rec.s10_total := l_c3.nh_armed_vets;
            l_estab_rec.u10_total := l_c3.nh_not_vets+
                                    l_c3.nh_dis_vets+
                                    l_c3.nh_other_vets+
                                    l_c3.nh_armed_vets;
            --
          end if;
          --
        end loop;
        --
      close c3;

        open c3_ns;
        --
        loop
          --
          fetch c3_ns into l_c3_ns;
          exit when c3_ns%notfound;
          --

          if l_c3_ns.lookup_code = '10' then
            --
            l_estab_rec.t1_total := l_c3_ns.nh_recently_vets;
            l_estab_rec.u1_total := l_estab_rec.u1_total
                                    +l_c3_ns.nh_recently_vets;
            --
          elsif l_c3_ns.lookup_code = '1' then
            --
            l_estab_rec.t2_total := l_c3_ns.nh_recently_vets;
            l_estab_rec.u2_total := l_estab_rec.u2_total
                                  +l_c3_ns.nh_recently_vets;
            --
          elsif l_c3_ns.lookup_code = '2' then
            --
            l_estab_rec.t3_total := l_c3_ns.nh_recently_vets;
            l_estab_rec.u3_total := l_estab_rec.u3_total
                                    +l_c3_ns.nh_recently_vets;
            --
          elsif l_c3_ns.lookup_code = '3' then
            --
            l_estab_rec.t4_total := l_c3_ns.nh_recently_vets;
            l_estab_rec.u4_total := l_estab_rec.u4_total
                                    +l_c3_ns.nh_recently_vets;
            --
          elsif l_c3_ns.lookup_code = '4' then
            --
            l_estab_rec.t5_total := l_c3_ns.nh_recently_vets;
            l_estab_rec.u5_total := l_estab_rec.u5_total
                                    +l_c3_ns.nh_recently_vets;
            --
          elsif l_c3_ns.lookup_code = '5' then
            --
            l_estab_rec.t6_total := l_c3_ns.nh_recently_vets;
            l_estab_rec.u6_total := l_estab_rec.u6_total
                                    +l_c3_ns.nh_recently_vets;

          elsif l_c3_ns.lookup_code = '6' then
            --
            l_estab_rec.t7_total := l_c3_ns.nh_recently_vets;
            l_estab_rec.u7_total := l_estab_rec.u7_total
                                    +l_c3_ns.nh_recently_vets;
            --
          elsif l_c3_ns.lookup_code = '7' then
            --
            l_estab_rec.t8_total := l_c3_ns.nh_recently_vets;
            l_estab_rec.u8_total := l_estab_rec.u8_total
                                    +l_c3_ns.nh_recently_vets;
            --
          elsif l_c3_ns.lookup_code = '8' then
            --
            l_estab_rec.t9_total := l_c3_ns.nh_recently_vets;
            l_estab_rec.u9_total := l_estab_rec.u9_total
                                    +l_c3_ns.nh_recently_vets;
            --
          elsif l_c3_ns.lookup_code = '9' then
            --
            l_estab_rec.t10_total := l_c3_ns.nh_recently_vets;
            l_estab_rec.u10_total := l_estab_rec.u10_total
                                    +l_c3_ns.nh_recently_vets;
            --
          end if;
          --
        end loop;
        --
      close c3_ns;
      hr_utility.trace('l_c1.state : ' || l_c1.state);
      hr_utility.trace('l_consol_rec.state : ' || l_consol_rec.state);
      if l_c1.state <> nvl(l_consol_rec.state,l_c1.state) then
        --
        -- Write out the old consolidated report and
        -- process the next record which is for a different state.
        --
        hr_utility.set_location(l_proc,50);
        write_consolidated_record;
        l_consol_rec := l_estab_rec_blank;
        l_month_rec := l_month_rec_blank;
        --
      end if;
      --

      --
      open c_tot_emps;
      fetch c_tot_emps into l_tot_emps;
      close c_tot_emps;
      hr_utility.trace('l_tot_emps : ' || l_tot_emps);

      --while l_start_date < p_end_date loop
      for l_month_number in 1 .. 12 loop

           --9000119
        l_month_start_date := ADD_MONTHS(p_end_date,-l_month_number)+1;
        l_month_end_date := ADD_MONTHS(l_month_start_date,1)-1;


	hr_utility.trace('l_month_start_date : ' || l_month_start_date);
	hr_utility.trace('l_month_end_date : ' || l_month_end_date);
        --
        open c_min_max;
          --
          fetch c_min_max into l_min_max;

          --
          hr_utility.set_location(l_proc,60);
          hr_utility.trace('l_min_max : ' || l_min_max.num_people);
          hr_utility.trace('p_hierarchy_version_id : ' || p_hierarchy_version_id);
          hr_utility.trace('l_hierarchy_node_id : ' || l_hierarchy_node_id);
          if l_estab_rec.min_count is null then
            --
            l_estab_rec.min_count := l_min_max.num_people;
            --
          end if;
          --
          if l_estab_rec.max_count is null then
            --
            l_estab_rec.max_count := l_min_max.num_people;
            --
          end if;
          --
          if l_estab_rec.min_count > l_min_max.num_people then
            --
            l_estab_rec.min_count := l_min_max.num_people;
            --
          end if;
          --
          if l_estab_rec.max_count < l_min_max.num_people then
            --
            l_estab_rec.max_count := l_min_max.num_people;
            --
          end if;
          --
          if to_char(l_month_start_date,'MM') = '01' then
            --
            l_month_rec.jan := nvl(l_month_rec.jan,0) +
                               l_min_max.num_people;
            --
          elsif to_char(l_month_start_date,'MM') = '02' then
            --
            l_month_rec.feb := nvl(l_month_rec.feb,0) +
                               l_min_max.num_people;
            --
          elsif to_char(l_month_start_date,'MM') = '03' then
            --
            l_month_rec.mar := nvl(l_month_rec.mar,0) +
                               l_min_max.num_people;
            --
          elsif to_char(l_month_start_date,'MM') = '04' then
            --
            l_month_rec.apr := nvl(l_month_rec.apr,0) +
                               l_min_max.num_people;
            --
          elsif to_char(l_month_start_date,'MM') = '05' then
            --
            l_month_rec.may := nvl(l_month_rec.may,0) +
                               l_min_max.num_people;
            --
          elsif to_char(l_month_start_date,'MM') = '06' then
            --
            l_month_rec.jun := nvl(l_month_rec.jun,0) +
                               l_min_max.num_people;
            --
          elsif to_char(l_month_start_date,'MM') = '07' then
            --
            l_month_rec.jul := nvl(l_month_rec.jul,0) +
                               l_min_max.num_people;
            --
          elsif to_char(l_month_start_date,'MM') = '08' then
            --
            l_month_rec.aug := nvl(l_month_rec.aug,0) +
                               l_min_max.num_people;
            --
          elsif to_char(l_month_start_date,'MM') = '09' then
            --
            l_month_rec.sep := nvl(l_month_rec.sep,0) +
                               l_min_max.num_people;
            --
          elsif to_char(l_month_start_date,'MM') = '10' then
            --
            l_month_rec.oct := nvl(l_month_rec.oct,0) +
                               l_min_max.num_people;
            --
          elsif to_char(l_month_start_date,'MM') = '11' then
            --
            l_month_rec.nov := nvl(l_month_rec.nov,0) +
                               l_min_max.num_people;
            --
          elsif to_char(l_month_start_date,'MM') = '12' then
            --
            l_month_rec.dec := nvl(l_month_rec.dec,0) +
                               l_min_max.num_people;
            --
          end if;
          --
          --l_start_date := add_months(l_start_date,1);
          --
        close c_min_max;
        --
      end loop;
      --
      write_establishment_record;
      --
    end loop;
    --
  close c1;
  --
  -- Last case unhandled MSC records
  --
  if l_consol_rec.state is not null then
    --
    write_consolidated_record;
    --
  end if;
  --
end loop_through_establishments;

procedure vets_mag_report
  (errbuf                        out nocopy varchar2,
   retcode                       out nocopy number,
   p_start_date                  in  varchar2,
   p_end_date                    in  varchar2,
   p_hierarchy_id                in  number,
   p_hierarchy_version_id        in  number,
   p_business_group_id           in  number,
   p_all_establishments          in  varchar2
  ) is
  --
  l_start_date date := fnd_date.canonical_to_date(p_start_date);
  l_end_date date := fnd_date.canonical_to_date(p_end_date);
  l_string varchar2(2000);
  --
  cursor c2 is
    select count(*)
    from   per_gen_hierarchy_nodes
    where  node_type = 'EST'
    and    hierarchy_version_id = p_hierarchy_version_id;
  --
  l_count number;
  --
begin
  --
  --hr_utility.trace_on(null,'ORACLE');
  l_org_rec.ending_period := to_char(l_end_date,'MMDDYYYY');
  l_all_estab := p_all_establishments;
  set_org_details(p_hierarchy_version_id => p_hierarchy_version_id,
                  p_business_group_id    => p_business_group_id);
  --
  open c2;
    --
    fetch c2 into l_count;
    --
    if l_count = 1 then
      --
      l_org_rec.form_type := 'S';
      --
    end if;
    --
  close c2;
  --
  loop_through_establishments(p_hierarchy_version_id => p_hierarchy_version_id,
                              p_business_group_id    => p_business_group_id,
                              p_start_date           => l_start_date,
                              p_end_date             => l_end_date);
  --
end vets_mag_report;
--
end per_vets_mag_100a_report;

/
