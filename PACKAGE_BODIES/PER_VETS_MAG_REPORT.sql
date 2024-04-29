--------------------------------------------------------
--  DDL for Package Body PER_VETS_MAG_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_VETS_MAG_REPORT" as
/* $Header: pevetmag.pkb 120.6.12010000.2 2008/08/06 09:38:52 ubhat ship $ */
--
type org_rec is record
  (company_number   varchar2(20),
   ending_period    varchar2(30),
   contractor_type  varchar2(80),
   form_type        varchar2(80),
   msc_number       varchar2(80),
   number_of_estabs number,
   parent_company   varchar2(200),
   street           varchar2(200),
   city             varchar2(200),
   county           varchar2(200),
   state            varchar2(200),
   zip_code         varchar2(200),
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
   city           varchar2(200),
   county         varchar2(200),
   state          varchar2(200),
   zip_code       varchar2(200),
   naics          varchar2(200),
   duns           varchar2(200),
   ein            varchar2(200),
   hq             varchar2(200),
   l1_total       number,
   m1_total       number,
   n1_total       number,
   o1_total       number,
   p1_total       number,
   q1_total       number,
   r1_total       number,
   s1_total       number,
   l2_total       number,
   m2_total       number,
   n2_total       number,
   o2_total       number,
   p2_total       number,
   q2_total       number,
   r2_total       number,
   s2_total       number,
   l3_total       number,
   m3_total       number,
   n3_total       number,
   o3_total       number,
   p3_total       number,
   q3_total       number,
   r3_total       number,
   s3_total       number,
   l4_total       number,
   m4_total       number,
   n4_total       number,
   o4_total       number,
   p4_total       number,
   q4_total       number,
   r4_total       number,
   s4_total       number,
   l5_total       number,
   m5_total       number,
   n5_total       number,
   o5_total       number,
   p5_total       number,
   q5_total       number,
   r5_total       number,
   s5_total       number,
   l6_total       number,
   m6_total       number,
   n6_total       number,
   o6_total       number,
   p6_total       number,
   q6_total       number,
   r6_total       number,
   s6_total       number,
   l7_total       number,
   m7_total       number,
   n7_total       number,
   o7_total       number,
   p7_total       number,
   q7_total       number,
   r7_total       number,
   s7_total       number,
   l8_total       number,
   m8_total       number,
   n8_total       number,
   o8_total       number,
   p8_total       number,
   q8_total       number,
   r8_total       number,
   s8_total       number,
   l9_total       number,
   m9_total       number,
   n9_total       number,
   o9_total       number,
   p9_total       number,
   q9_total       number,
   r9_total       number,
   s9_total       number,
   l_grand_total  number,
   m_grand_total  number,
   n_grand_total  number,
   o_grand_total  number,
   p_grand_total  number,
   q_grand_total  number,
   r_grand_total  number,
   s_grand_total  number,
   min_count      number,
   max_count      number);
--
l_estab_rec estab_rec;
l_consol_rec estab_rec;
l_holder_rec estab_rec;
l_estab_rec_blank estab_rec;
l_all_estab varchar2(1); -- BUG3695203
l_tot_emps number;
--
/* old: cost 45
procedure set_org_details(p_hierarchy_version_id in number) is
  --
  cursor c1 is
    select hoi1.org_information2 company_number,
           decode(hoi1.org_information3,'2S','S','1P','P','3B','B') contractor_type,
           nvl(hoi1.org_information1,hou.name) parent_company,
           upper(loc.address_line_1||
                 ' '||
                 loc.address_line_2||
                 ' '||
                 loc.address_line_3) street,
           upper(loc.town_or_city) city,
           upper(loc.region_1) county,
           loc.region_2 state,
           loc.postal_code zip_code,
           hoi2.org_information2 naics,
           hoi2.org_information4 duns,
           hoi2.org_information3 ein
    from   --per_gen_hierarchy_nodes pghn,
           per_gen_hierarchy_nodes pgn,
           hr_organization_units hou,
           hr_organization_information hoi1,
           hr_organization_information hoi2,
           hr_locations_all loc
    where  pgn.hierarchy_version_id = p_hierarchy_version_id
    and    pgn.node_type = 'PAR'
    and    pgn.entity_id = hou.organization_id
    and    hoi1.org_information_context  = 'VETS_Spec'
    and    hoi1.organization_id = hou.organization_id
    and    hoi2.org_information_context  = 'VETS_EEO_Dup'
    and    hoi2.organization_id = hou.organization_id
    --and    hou.location_id(+)= loc.location_id;
    and    hou.location_id = loc.location_id(+);
*/
-- new: cost 12
procedure set_org_details(p_hierarchy_version_id in number,
                          p_business_group_id in number) is
  --
  cursor c1 is
    select hoi1.org_information2 company_number,
           decode(hoi1.org_information3,'2S','S','1P','P','3B','B') contractor_type,
           replace(nvl(hoi1.org_information1,hou.name),',',' ') parent_company,
           upper(replace(loc.address_line_1,',',' ')||
                 ' '||
                 replace(loc.address_line_2,',',' ')||
                 ' '||
                 replace(loc.address_line_3,',',' ')) street,
           upper(loc.town_or_city) city,
           upper(loc.region_1) county,
           loc.region_2 state,
           loc.postal_code zip_code,
           hoi2.org_information2 naics,
           hoi2.org_information4 duns,
           hoi2.org_information3 ein
    from   per_gen_hierarchy_nodes pgn,
           hr_all_organization_units hou,  -- vik
           -- hr_organization_units hou,   -- vik
           hr_organization_information hoi1,
           hr_organization_information hoi2,
           hr_locations_all loc
    where  pgn.hierarchy_version_id = p_hierarchy_version_id
    and    pgn.node_type = 'PAR'
    and    pgn.entity_id = hou.organization_id
    and    pgn.business_group_id = p_business_group_id -- vik
    --and    hou.organization_id = p_business_group_id -- vik BUG4179427
    -- and    loc.business_group_id =  p_business_group_id -- vik  bg_id
    and    hoi1.org_information_context  = 'VETS_Spec'
    and    hoi1.organization_id = hou.organization_id
    and    hoi2.org_information_context  = 'VETS_EEO_Dup'
    and    hoi2.organization_id = hou.organization_id
    --and    hou.location_id(+)= loc.location_id;
    and    hou.location_id = loc.location_id(+);
  --
begin
  --
  open c1;
    --
    fetch c1 into l_org_rec.company_number,
                  l_org_rec.contractor_type,
                  l_org_rec.parent_company,
                  l_org_rec.street,
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
end set_org_details;
--
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
              l_org_rec.ending_period||','||
              l_org_rec.contractor_type||','||
              'MSC'||','||
              l_org_rec.number_of_estabs||','||
              l_org_rec.parent_company||','||
              l_org_rec.street||','||
              l_org_rec.city||','||
              l_org_rec.county||','||
              l_org_rec.state||','||
              l_org_rec.zip_code||','||
              l_consol_rec.unit_number||','||
              l_consol_rec.reporting_name||','||
              l_consol_rec.street||','||
              l_consol_rec.city||','||
              l_consol_rec.county||','||
              l_consol_rec.state||','||
              l_consol_rec.zip_code||','||
              l_org_rec.naics||','||
              l_org_rec.duns||','||
              l_org_rec.ein||','||
              nvl(l_consol_rec.l1_total,0)||','||
              nvl(l_consol_rec.m1_total,0)||','||
              nvl(l_consol_rec.n1_total,0)||','||
              nvl(l_consol_rec.o1_total,0)||','||
              nvl(l_consol_rec.p1_total,0)||','||
              nvl(l_consol_rec.q1_total,0)||','||
              nvl(l_consol_rec.r1_total,0)||','||
              nvl(l_consol_rec.s1_total,0)||','||
              nvl(l_consol_rec.l2_total,0)||','||
              nvl(l_consol_rec.m2_total,0)||','||
              nvl(l_consol_rec.n2_total,0)||','||
              nvl(l_consol_rec.o2_total,0)||','||
              nvl(l_consol_rec.p2_total,0)||','||
              nvl(l_consol_rec.q2_total,0)||','||
              nvl(l_consol_rec.r2_total,0)||','||
              nvl(l_consol_rec.s2_total,0)||','||
              nvl(l_consol_rec.l3_total,0)||','||
              nvl(l_consol_rec.m3_total,0)||','||
              nvl(l_consol_rec.n3_total,0)||','||
              nvl(l_consol_rec.o3_total,0)||','||
              nvl(l_consol_rec.p3_total,0)||','||
              nvl(l_consol_rec.q3_total,0)||','||
              nvl(l_consol_rec.r3_total,0)||','||
              nvl(l_consol_rec.s3_total,0)||','||
              nvl(l_consol_rec.l4_total,0)||','||
              nvl(l_consol_rec.m4_total,0)||','||
              nvl(l_consol_rec.n4_total,0)||','||
              nvl(l_consol_rec.o4_total,0)||','||
              nvl(l_consol_rec.p4_total,0)||','||
              nvl(l_consol_rec.q4_total,0)||','||
              nvl(l_consol_rec.r4_total,0)||','||
              nvl(l_consol_rec.s4_total,0)||','||
              nvl(l_consol_rec.l5_total,0)||','||
              nvl(l_consol_rec.m5_total,0)||','||
              nvl(l_consol_rec.n5_total,0)||','||
              nvl(l_consol_rec.o5_total,0)||','||
              nvl(l_consol_rec.p5_total,0)||','||
              nvl(l_consol_rec.q5_total,0)||','||
              nvl(l_consol_rec.r5_total,0)||','||
              nvl(l_consol_rec.s5_total,0)||','||
              nvl(l_consol_rec.l6_total,0)||','||
              nvl(l_consol_rec.m6_total,0)||','||
              nvl(l_consol_rec.n6_total,0)||','||
              nvl(l_consol_rec.o6_total,0)||','||
              nvl(l_consol_rec.p6_total,0)||','||
              nvl(l_consol_rec.q6_total,0)||','||
              nvl(l_consol_rec.r6_total,0)||','||
              nvl(l_consol_rec.s6_total,0)||','||
              nvl(l_consol_rec.l7_total,0)||','||
              nvl(l_consol_rec.m7_total,0)||','||
              nvl(l_consol_rec.n7_total,0)||','||
              nvl(l_consol_rec.o7_total,0)||','||
              nvl(l_consol_rec.p7_total,0)||','||
              nvl(l_consol_rec.q7_total,0)||','||
              nvl(l_consol_rec.r7_total,0)||','||
              nvl(l_consol_rec.s7_total,0)||','||
              nvl(l_consol_rec.l8_total,0)||','||
              nvl(l_consol_rec.m8_total,0)||','||
              nvl(l_consol_rec.n8_total,0)||','||
              nvl(l_consol_rec.o8_total,0)||','||
              nvl(l_consol_rec.p8_total,0)||','||
              nvl(l_consol_rec.q8_total,0)||','||
              nvl(l_consol_rec.r8_total,0)||','||
              nvl(l_consol_rec.s8_total,0)||','||
              nvl(l_consol_rec.l9_total,0)||','||
              nvl(l_consol_rec.m9_total,0)||','||
              nvl(l_consol_rec.n9_total,0)||','||
              nvl(l_consol_rec.o9_total,0)||','||
              nvl(l_consol_rec.p9_total,0)||','||
              nvl(l_consol_rec.q9_total,0)||','||
              nvl(l_consol_rec.r9_total,0)||','||
              nvl(l_consol_rec.s9_total,0)||','||
              nvl(l_consol_rec.l_grand_total,0)||','||
              nvl(l_consol_rec.m_grand_total,0)||','||
              nvl(l_consol_rec.n_grand_total,0)||','||
              nvl(l_consol_rec.o_grand_total,0)||','||
              nvl(l_consol_rec.p_grand_total,0)||','||
              nvl(l_consol_rec.q_grand_total,0)||','||
              nvl(l_consol_rec.r_grand_total,0)||','||
              nvl(l_consol_rec.s_grand_total,0)||','||
              nvl(l_consol_rec.max_count,0)||','||
              nvl(l_consol_rec.min_count,0);
  --
  fnd_file.put_line
    (which => fnd_file.output,
     buff  => l_string);
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
                               nvl(l_estab_rec.l9_total,0);
  --
  l_estab_rec.m_grand_total := nvl(l_estab_rec.m1_total,0)+
                               nvl(l_estab_rec.m2_total,0)+
                               nvl(l_estab_rec.m3_total,0)+
                               nvl(l_estab_rec.m4_total,0)+
                               nvl(l_estab_rec.m5_total,0)+
                               nvl(l_estab_rec.m6_total,0)+
                               nvl(l_estab_rec.m7_total,0)+
                               nvl(l_estab_rec.m8_total,0)+
                               nvl(l_estab_rec.m9_total,0);
  --
  l_estab_rec.m_grand_total := nvl(l_estab_rec.m1_total,0)+
                               nvl(l_estab_rec.m2_total,0)+
                               nvl(l_estab_rec.m3_total,0)+
                               nvl(l_estab_rec.m4_total,0)+
                               nvl(l_estab_rec.m5_total,0)+
                               nvl(l_estab_rec.m6_total,0)+
                               nvl(l_estab_rec.m7_total,0)+
                               nvl(l_estab_rec.m8_total,0)+
                               nvl(l_estab_rec.m9_total,0);
  --
  l_estab_rec.n_grand_total := nvl(l_estab_rec.n1_total,0)+
                               nvl(l_estab_rec.n2_total,0)+
                               nvl(l_estab_rec.n3_total,0)+
                               nvl(l_estab_rec.n4_total,0)+
                               nvl(l_estab_rec.n5_total,0)+
                               nvl(l_estab_rec.n6_total,0)+
                               nvl(l_estab_rec.n7_total,0)+
                               nvl(l_estab_rec.n8_total,0)+
                               nvl(l_estab_rec.n9_total,0);
  --
  l_estab_rec.o_grand_total := nvl(l_estab_rec.o1_total,0)+
                               nvl(l_estab_rec.o2_total,0)+
                               nvl(l_estab_rec.o3_total,0)+
                               nvl(l_estab_rec.o4_total,0)+
                               nvl(l_estab_rec.o5_total,0)+
                               nvl(l_estab_rec.o6_total,0)+
                               nvl(l_estab_rec.o7_total,0)+
                               nvl(l_estab_rec.o8_total,0)+
                               nvl(l_estab_rec.o9_total,0);
  --
  l_estab_rec.p_grand_total := nvl(l_estab_rec.p1_total,0)+
                               nvl(l_estab_rec.p2_total,0)+
                               nvl(l_estab_rec.p3_total,0)+
                               nvl(l_estab_rec.p4_total,0)+
                               nvl(l_estab_rec.p5_total,0)+
                               nvl(l_estab_rec.p6_total,0)+
                               nvl(l_estab_rec.p7_total,0)+
                               nvl(l_estab_rec.p8_total,0)+
                               nvl(l_estab_rec.p9_total,0);
  --
  l_estab_rec.q_grand_total := nvl(l_estab_rec.q1_total,0)+
                               nvl(l_estab_rec.q2_total,0)+
                               nvl(l_estab_rec.q3_total,0)+
                               nvl(l_estab_rec.q4_total,0)+
                               nvl(l_estab_rec.q5_total,0)+
                               nvl(l_estab_rec.q6_total,0)+
                               nvl(l_estab_rec.q7_total,0)+
                               nvl(l_estab_rec.q8_total,0)+
                               nvl(l_estab_rec.q9_total,0);
  --
  l_estab_rec.r_grand_total := nvl(l_estab_rec.r1_total,0)+
                               nvl(l_estab_rec.r2_total,0)+
                               nvl(l_estab_rec.r3_total,0)+
                               nvl(l_estab_rec.r4_total,0)+
                               nvl(l_estab_rec.r5_total,0)+
                               nvl(l_estab_rec.r6_total,0)+
                               nvl(l_estab_rec.r7_total,0)+
                               nvl(l_estab_rec.r8_total,0)+
                               nvl(l_estab_rec.r9_total,0);
  --
  l_estab_rec.s_grand_total := nvl(l_estab_rec.s1_total,0)+
                               nvl(l_estab_rec.s2_total,0)+
                               nvl(l_estab_rec.s3_total,0)+
                               nvl(l_estab_rec.s4_total,0)+
                               nvl(l_estab_rec.s5_total,0)+
                               nvl(l_estab_rec.s6_total,0)+
                               nvl(l_estab_rec.s7_total,0)+
                               nvl(l_estab_rec.s8_total,0)+
                               nvl(l_estab_rec.s9_total,0);
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
    --
    l_org_rec.number_of_estabs := nvl(l_org_rec.number_of_estabs,0)+1;
    return;
    --
  end if;
  --
  l_string := l_org_rec.company_number||','||
              l_org_rec.ending_period||','||
              l_org_rec.contractor_type||','||
              l_org_rec.form_type||','||
              l_org_rec.msc_number||','||
              l_org_rec.parent_company||','||
              l_org_rec.street||','||
              l_org_rec.city||','||
              l_org_rec.county||','||
              l_org_rec.state||','||
              l_org_rec.zip_code||','||
              l_estab_rec.unit_number||','||
              l_estab_rec.reporting_name||','||
              l_estab_rec.street||','||
              l_estab_rec.city||','||
              l_estab_rec.county||','||
              l_estab_rec.state||','||
              l_estab_rec.zip_code||','||
              nvl(l_estab_rec.naics,l_org_rec.naics)||','||
              nvl(l_estab_rec.duns,l_org_rec.duns)||','||
              nvl(l_estab_rec.ein,l_org_rec.ein)||','||
              nvl(l_estab_rec.l1_total,0)||','||
              nvl(l_estab_rec.m1_total,0)||','||
              nvl(l_estab_rec.n1_total,0)||','||
              nvl(l_estab_rec.o1_total,0)||','||
              nvl(l_estab_rec.p1_total,0)||','||
              nvl(l_estab_rec.q1_total,0)||','||
              nvl(l_estab_rec.r1_total,0)||','||
              nvl(l_estab_rec.s1_total,0)||','||
              nvl(l_estab_rec.l2_total,0)||','||
              nvl(l_estab_rec.m2_total,0)||','||
              nvl(l_estab_rec.n2_total,0)||','||
              nvl(l_estab_rec.o2_total,0)||','||
              nvl(l_estab_rec.p2_total,0)||','||
              nvl(l_estab_rec.q2_total,0)||','||
              nvl(l_estab_rec.r2_total,0)||','||
              nvl(l_estab_rec.s2_total,0)||','||
              nvl(l_estab_rec.l3_total,0)||','||
              nvl(l_estab_rec.m3_total,0)||','||
              nvl(l_estab_rec.n3_total,0)||','||
              nvl(l_estab_rec.o3_total,0)||','||
              nvl(l_estab_rec.p3_total,0)||','||
              nvl(l_estab_rec.q3_total,0)||','||
              nvl(l_estab_rec.r3_total,0)||','||
              nvl(l_estab_rec.s3_total,0)||','||
              nvl(l_estab_rec.l4_total,0)||','||
              nvl(l_estab_rec.m4_total,0)||','||
              nvl(l_estab_rec.n4_total,0)||','||
              nvl(l_estab_rec.o4_total,0)||','||
              nvl(l_estab_rec.p4_total,0)||','||
              nvl(l_estab_rec.q4_total,0)||','||
              nvl(l_estab_rec.r4_total,0)||','||
              nvl(l_estab_rec.s4_total,0)||','||
              nvl(l_estab_rec.l5_total,0)||','||
              nvl(l_estab_rec.m5_total,0)||','||
              nvl(l_estab_rec.n5_total,0)||','||
              nvl(l_estab_rec.o5_total,0)||','||
              nvl(l_estab_rec.p5_total,0)||','||
              nvl(l_estab_rec.q5_total,0)||','||
              nvl(l_estab_rec.r5_total,0)||','||
              nvl(l_estab_rec.s5_total,0)||','||
              nvl(l_estab_rec.l6_total,0)||','||
              nvl(l_estab_rec.m6_total,0)||','||
              nvl(l_estab_rec.n6_total,0)||','||
              nvl(l_estab_rec.o6_total,0)||','||
              nvl(l_estab_rec.p6_total,0)||','||
              nvl(l_estab_rec.q6_total,0)||','||
              nvl(l_estab_rec.r6_total,0)||','||
              nvl(l_estab_rec.s6_total,0)||','||
              nvl(l_estab_rec.l7_total,0)||','||
              nvl(l_estab_rec.m7_total,0)||','||
              nvl(l_estab_rec.n7_total,0)||','||
              nvl(l_estab_rec.o7_total,0)||','||
              nvl(l_estab_rec.p7_total,0)||','||
              nvl(l_estab_rec.q7_total,0)||','||
              nvl(l_estab_rec.r7_total,0)||','||
              nvl(l_estab_rec.s7_total,0)||','||
              nvl(l_estab_rec.l8_total,0)||','||
              nvl(l_estab_rec.m8_total,0)||','||
              nvl(l_estab_rec.n8_total,0)||','||
              nvl(l_estab_rec.o8_total,0)||','||
              nvl(l_estab_rec.p8_total,0)||','||
              nvl(l_estab_rec.q8_total,0)||','||
              nvl(l_estab_rec.r8_total,0)||','||
              nvl(l_estab_rec.s8_total,0)||','||
              nvl(l_estab_rec.l9_total,0)||','||
              nvl(l_estab_rec.m9_total,0)||','||
              nvl(l_estab_rec.n9_total,0)||','||
              nvl(l_estab_rec.o9_total,0)||','||
              nvl(l_estab_rec.p9_total,0)||','||
              nvl(l_estab_rec.q9_total,0)||','||
              nvl(l_estab_rec.r9_total,0)||','||
              nvl(l_estab_rec.s9_total,0)||','||
              nvl(l_estab_rec.l_grand_total,0)||','||
              nvl(l_estab_rec.m_grand_total,0)||','||
              nvl(l_estab_rec.n_grand_total,0)||','||
              nvl(l_estab_rec.o_grand_total,0)||','||
              nvl(l_estab_rec.p_grand_total,0)||','||
              nvl(l_estab_rec.q_grand_total,0)||','||
              nvl(l_estab_rec.r_grand_total,0)||','||
              nvl(l_estab_rec.s_grand_total,0)||','||
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
  --
  l_hierarchy_node_id number;
  --
  -- orig cursor, cost of 9 as stands.
  cursor c1 is
    select upper(replace(hlei1.lei_information1,',',' ')) reporting_name,
           hlei1.lei_information2 unit_number,
           upper(replace(eloc.address_line_1,',',' ')||
                 ' '||
                 replace(eloc.address_line_2,',',' ')||
                 ' '||
                 replace(eloc.address_line_3,',',' ')) street,
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
  --
  l_c1 c1%rowtype;
  --
  --Modified for Bug#	6759680
  cursor c2 is
  /* old cost 453
    select nvl(count(decode(peo.per_information5,'VETDIS',1,'VIETVETDIS',1,
               'OTEDV',1,'DVOEV',1,'NSDIS',1,'NSDISOP',1,'VIETDISNS',1,
               'VIETDISNSOP',1,null)),0) no_dis_vets,
           nvl(count(decode(peo.per_information5,'VIETVET',1,'VIETVETDIS',1,
               'DVOEV',1,'VOEVV',1,'VIETNS',1,'VIETDISNS',1,'VIETNSOP',1,
               'VIETDISNSOP',1,null)),0) no_viet_vets,
           nvl(count(decode(peo.per_information5,'OTEV',1,'OTEDV',1,'DVOEV',1,
               'VOEVV',1,'NSOP',1,'NSDISOP',1,'VIETNSOP',1,'VIETDISNSOP',1,
               null)),0) no_other_vets,
           hrl.lookup_code
    from   per_periods_of_service          pds,
           per_people_f                    peo,
           per_assignments_f               ass,
           hr_organization_information     hoi1,
           hr_organization_information     hoi2,
           per_jobs                        job,
           hr_lookups                      hrl
    where  (pds.date_start <= p_end_date
    and    nvl(pds.actual_termination_date,hr_api.g_eot) >= p_end_date
    or     pds.date_start between p_start_date and p_end_date
    and    p_end_date between pds.date_start and     nvl(pds.actual_termination_date,hr_api.g_eot))
    and    pds.person_id = ass.person_id
    and    peo.person_id = ass.person_id
    and    job.date_from <= p_end_date
    and    nvl(job.date_to,hr_api.g_eot) >= p_start_date
    and    job.job_information1 = hrl.lookup_code
    and    hrl.lookup_type = 'US_EEO1_JOB_CATEGORIES'
    and    ass.job_id = job.job_id
    and    peo.effective_start_date <= p_end_date
    and    peo.effective_end_date >= p_start_date
    and    peo.current_employee_flag        = 'Y'
    and    ass.assignment_type             = 'E'
    and    ass.primary_flag                = 'Y'
    and    ass.effective_start_date =
             (select max(paf2.effective_start_date)
              from   per_assignments_f paf2
              where  paf2.person_id = ass.person_id
              and    paf2.primary_flag = 'Y'
              and    paf2.assignment_type = 'E'
              and    paf2.effective_start_date <= p_end_date)
    and    peo.effective_start_date =
             (select max(peo2.effective_start_date)
              from   per_people_f peo2
              where  peo2.person_id = peo.person_id
              and    peo.current_employee_flag = 'Y'
              and    peo2.effective_start_date < p_end_date)
    and     to_char(ass.assignment_status_type_id) = hoi1.org_information1
    and     hoi1.org_information_context = 'Reporting Statuses'
    and     hoi1.organization_id = p_business_group_id
    and     ass.employment_category = hoi2.org_information1
    and     hoi2.organization_id = p_business_group_id
    and     hoi2.org_information_context = 'Reporting Categories'
    and     ass.effective_start_date <= p_end_date
    and     ass.effective_end_date >= p_start_date
    and     to_char(ass.location_id) in
            (select entity_id
             from   per_gen_hierarchy_nodes
             where  hierarchy_version_id = p_hierarchy_version_id
             and    (hierarchy_node_id = l_hierarchy_node_id
                     or parent_hierarchy_node_id = l_hierarchy_node_id))
    group by hrl.lookup_code;  */

 -- new; cost 169

   select nvl(
           count(decode(peo.per_information5,'VETDIS',1,'VIETVETDIS',1,
               'OTEDV',1,'DVOEV',1,'NSDIS',1,'NSDISOP',1,'VIETDISNS',1,
               'VIETDISNSOP',1,'AFSMDIS',1,'AFSMDISOP',1,'AFSMDISNS',1,
               'AFSMNSDISOP',1,'AFSMDISVIET',1,'AFSMVIETNSDIS',1,'AFSMVIETOPDIS'
               ,1,'AFSMVIETNSDISOP',1,null))
               ,0)
            no_dis_vets,
            nvl(
           count(decode(peo.per_information5,'VIETVET',1,'VIETVETDIS',1,
               'DVOEV',1,'VOEVV',1,'VIETNS',1,'VIETDISNS',1,'VIETNSOP',1,
               'VIETDISNSOP',1,'AFSMVIET',1,'AFSMVIETOP',1,'AFSMNSVIET',1,
               'AFSMVIETNSOP',1,'AFSMDISVIET',1,'AFSMVIETNSDIS',1,'AFSMVIETOPDIS',1,
               'AFSMVIETNSDISOP',1,null))
                ,0)
               no_viet_vets,
            nvl(
           count(decode(peo.per_information5,'OTEV',1,'OTEDV',1,'DVOEV',1,
               'VOEVV',1,'NSOP',1,'NSDISOP',1,'VIETNSOP',1,'VIETDISNSOP',1,
               'AFSMOP',1,'AFSMDISOP',1,'AFSMNSOP',1,'AFSMNSDISOP', 1,'AFSMVIETNSOP',1,
               'AFSMVIETOPDIS',1,'AFSMVIETNSDISOP',1,'AFSMVIETOP',1,
               null))
                ,0)
               no_other_vets,
           decode(hrl.lookup_code,10,1,hrl.lookup_code) lookup_code
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
    -- Bug# 5000214
    --and    job.date_from <= p_end_date
    --and    nvl(job.date_to,(p_end_date + 1)) >= p_start_date
    and    p_end_date between job.date_from and nvl(job.date_to, p_end_date)
    and    job.job_information1 = hrl.lookup_code
    and    hrl.lookup_type = 'US_EEO1_JOB_CATEGORIES'
    and    ass.job_id = job.job_id
    -- Bug# 5000214
    --and    peo.effective_start_date <= p_end_date
    --and    peo.effective_end_date >= p_start_date
    and p_end_date between peo.effective_start_date and peo.effective_end_date
    and    peo.current_employee_flag        = 'Y'
    and    ass.assignment_type             = 'E'
    and    ass.primary_flag                = 'Y'
    --
    and    ass.effective_start_date =
             (select max(paf2.effective_start_date)
              from   per_all_assignments_f paf2
              where  paf2.person_id = ass.person_id
              and    paf2.primary_flag = 'Y'
              and    paf2.assignment_type = 'E'
              and    paf2.effective_start_date <= p_end_date
              )
    --
    and    peo.effective_start_date =
             (select max(peo2.effective_start_date)
              from   per_all_people_f peo2
              where  peo2.person_id = peo.person_id
              and    peo.current_employee_flag = 'Y'
              and    peo2.effective_start_date < p_end_date
              )
    --
    and     to_char(ass.assignment_status_type_id) = hoi1.org_information1
    and     hoi1.org_information_context = 'Reporting Statuses'
    and     hoi1.organization_id = p_business_group_id
    and     ass.employment_category = hoi2.org_information1
    and     hoi2.organization_id = p_business_group_id
    and     hoi2.org_information_context = 'Reporting Categories'
    -- Bug 5000214
    --and     ass.effective_start_date <= p_end_date
    --and     ass.effective_end_date >= p_start_date
    and p_end_date between ass.effective_start_date and ass.effective_end_date
    --
    and     ass.location_id in
            (select entity_id
             from   per_gen_hierarchy_nodes
             where  hierarchy_version_id = p_hierarchy_version_id
             and    (hierarchy_node_id = l_hierarchy_node_id
                     or parent_hierarchy_node_id = l_hierarchy_node_id
                     ))
    group by decode(hrl.lookup_code,10,1,hrl.lookup_code);

  --
  l_c2 c2%rowtype;
  --
  cursor c3 is
  -----
    /* old c3: cost 448
    select count(decode(peo.per_information5,'NOTVET',1,NULL,1,
                 null)) tot_new_hires,
           count(decode(peo.per_information5,'VETDIS',1,'VIETVETDIS',1,
                 'OTEDV',1,'DVOEV',1,'NSDIS',1,'NSDISOP',1,'VIETDISNSOP',1,
                 'VIETDISNS',1,null)) no_nh_dis_vets,
           count(decode(peo.per_information5,'VIETVET',1,'VIETVETDIS',1,
                 'DVOEV',1,'VOEVV',1,'VIETNS',1,'VIETDISNS',1,'VIETNSOP',1,
                 'VIETDISNSOP',1,null)) no_nh_viet_vets,
           count(decode(peo.per_information5,'OTEV',1,'OTEDV',1,'DVOEV',1,
                 'VOEVV',1,'NSOP',1,'NSDISOP',1,'VIETNSOP',1,'VIETDISNSOP',1,
                 null)) no_nh_other_vets,
           count(decode(peo.per_information5,'NS',1,'NSDIS',1,'NSOP',1,
                 'NSDISOP',1,'VIETNS',1,'VIETDISNS',1,'VIETNSOP',1,
                 'VIETDISNSOP',1,null)) no_nh_newly_sep_vets,
           hrl.lookup_code
    from   per_periods_of_service       pds,
           per_people_f                 peo,
           per_assignments_f            ass,
           hr_organization_information  hoi1,
           hr_organization_information  hoi2,
           per_jobs                     job,
           hr_lookups                   hrl
    where  peo.person_id  = ass.person_id
    and    peo.current_employee_flag  = 'Y'
    and    pds.date_start
           between p_start_date
           and     p_end_date
    and    pds.person_id  = ass.person_id
    and    ass.assignment_type        = 'E'
    and    ass.primary_flag           = 'Y'
    and    ass.effective_start_date <= p_end_date
    and    ass.effective_end_date   >= p_start_date
    and    ass.effective_start_date =
             (select max(paf2.effective_start_date)
              from   per_assignments_f paf2
              where  paf2.person_id = ass.person_id
              and    paf2.primary_flag = 'Y'
              and    paf2.assignment_type = 'E'
              and    paf2.effective_start_date <= p_end_date)
    and    peo.effective_start_date =
             (select max(peo2.effective_start_date)
              from   per_people_f peo2
              where  peo2.person_id = peo.person_id
              and    peo2.current_employee_flag = 'Y'
              and    peo2.effective_start_date <= p_end_date)
    and     to_char(ass.assignment_status_type_id) = hoi1.org_information1
    and     hoi1.org_information_context = 'Reporting Statuses'
    and     hoi1.organization_id = p_business_group_id
    and     ass.employment_category = hoi2.org_information1
    and     hoi2.org_information_context = 'Reporting Categories'
    and     hoi2.organization_id = p_business_group_id
    and     ass.job_id = job.job_id
    and     job.job_information_category = 'US'
    and     job.date_from <= p_end_date
    and     nvl(job.date_to,hr_api.g_eot) >= p_start_date
    and     job.job_information1 = hrl.lookup_code
    and     hrl.lookup_type = 'US_EEO1_JOB_CATEGORIES'
    and     to_char(ass.location_id) in
            (select entity_id
             from   per_gen_hierarchy_nodes
             where  hierarchy_version_id = p_hierarchy_version_id
             and    (hierarchy_node_id = l_hierarchy_node_id
                     or parent_hierarchy_node_id = l_hierarchy_node_id))
    group by hrl.lookup_code;
    */
    -- new more performant c3: (cost 122)
    -- cursor to retrieve new hires
    -- The following query is modified for the bugs# 5000214 and 5608926
    --Modified for Bug#	6759680
    select count(decode(peo.per_information5,'NOTVET',1,NULL,1,
                 null)) tot_new_hires,
        count(decode(peo.per_information5,'VETDIS',1,'VIETVETDIS',1,
                 'OTEDV',1,'DVOEV',1,'NSDIS',1,'NSDISOP',1,'VIETDISNSOP',1,
                 'VIETDISNS',1,'AFSMDIS',1,'AFSMDISOP',1,'AFSMDISNS',1,
                 'AFSMNSDISOP',1,'AFSMDISVIET',1, 'AFSMVIETNSDIS',1,
                 'AFSMVIETOPDIS',1,'AFSMVIETNSDISOP',1,null)) no_nh_dis_vets,
        count(decode(peo.per_information5,'VIETVET',1,'VIETVETDIS',1,
                 'DVOEV',1,'VOEVV',1,'VIETNS',1,'VIETDISNS',1,'VIETNSOP',1,
                 'VIETDISNSOP',1,'AFSMVIET',1,'AFSMVIETOP',1,'AFSMNSVIET',1,
                 'AFSMVIETNSOP',1,'AFSMDISVIET',1,'AFSMVIETNSDIS',1,'AFSMVIETOPDIS',1,
                 'AFSMVIETNSDISOP',1,null)) no_nh_viet_vets,
        count(decode(peo.per_information5,'OTEV',1,'OTEDV',1,'DVOEV',1,
                 'VOEVV',1,'NSOP',1,'NSDISOP',1,'VIETNSOP',1,'VIETDISNSOP',1,
                 'AFSMOP',1,'AFSMDISOP',1,'AFSMNSOP',1,'AFSMNSDISOP',1,'AFSMVIETNSOP',1,
                 'AFSMVIETOPDIS',1,'AFSMVIETNSDISOP',1,'AFSMVIETOP',1,
                 null)) no_nh_other_vets,
        count(decode(peo.per_information5,'NS',1,'NSDIS',1,'NSOP',1,
                 'NSDISOP',1,'VIETNS',1,'VIETDISNS',1,'VIETNSOP',1,
                 'VIETDISNSOP',1,'AFSMNS',1,'AFSMDISNS',1,'AFSMNSOP',1,
                 'AFSMNSVIET',1,'AFSMNSDISOP',1,'AFSMVIETNSOP',1,'AFSMVIETNSDIS',1,
                 'AFSMVIETNSDISOP',1,null)) no_nh_newly_sep_vets,
        decode(hrl.lookup_code,'10','1',hrl.lookup_code) lookup_code
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
group by decode(hrl.lookup_code,'10','1',hrl.lookup_code);
  --
  l_c3 c3%rowtype;
  -- Bug# 5000214
  --l_start_date date := p_start_date;
  --
  -- cursor c_min_max is
  /* old version taking a long time to run on cust sites */
  /*
    select count(*) num_people
    from   per_people_f ppf,
           per_assignments_f paf
    where  ppf.person_id = paf.person_id
    and    ppf.business_group_id = p_business_group_id
    and    ppf.current_employee_flag = 'Y'
    and    paf.primary_flag = 'Y'
    and    paf.assignment_type = 'E'
    and    l_start_date
           between paf.effective_start_date
           and     paf.effective_end_date
    and    l_start_date
           between ppf.effective_start_date
           and     ppf.effective_end_date
    and    to_char(paf.location_id) in
           (select entity_id
            from   per_gen_hierarchy_nodes
            where  hierarchy_version_id = p_hierarchy_version_id
            and    (hierarchy_node_id = l_hierarchy_node_id
                    or parent_hierarchy_node_id = l_hierarchy_node_id));
  */
   --
  -- This one is quicker, more accurate and has cost of just 102
  /* BUT this doesn't pick up correct emp number 18-FEB-2005
  cursor c_min_max is
  select    count ('x') num_people
    from    per_all_assignments_f            ass,
            hr_organization_information      hoi1,
            hr_organization_information      hoi2
   where     ass.assignment_type = 'e'
     and     ass.primary_flag = 'y'
     and     l_month_start_date between ass.effective_start_date and  ass.effective_end_date
     and     ass.business_group_id = p_business_group_id
     --
     and     to_char(ass.assignment_status_type_id) = hoi1.org_information1
     and     hoi1.org_information_context = 'REPORTING STATUSES'
     and     hoi1.organization_id = p_business_group_id
     and     ass.employment_category = hoi2.org_information1
     and     hoi2.org_information_context = 'REPORTING CATEGORIES'
     and     hoi2.organization_id = p_business_group_id
     --
     and     ass.location_id in
             (select entity_id
                from   per_gen_hierarchy_nodes
               where  hierarchy_version_id = p_hierarchy_version_id
                 and    (hierarchy_node_id = l_hierarchy_node_id
                  or parent_hierarchy_node_id = l_hierarchy_node_id
              ));
  */
  --
  -- This is new c_min_max cursor   115.11
  --
   l_month_start_date date := null;
  l_month_end_date date := null;
  cursor c_min_max is
  SELECT count(*) num_people
    FROM  per_all_assignments_f paf
    WHERE paf.business_group_id = p_business_group_id
    AND    paf.primary_flag = 'Y'
    AND    paf.assignment_type = 'E'
    -- The following condition is modified for the bug# 5000214
    AND    l_month_start_date BETWEEN paf.effective_start_date AND paf.effective_end_date
    -- The following 2 condtions are added to sync with perusvts.rdf min-max cursor query.
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
  --
  l_min_max c_min_max%rowtype;

  --
  -- Count total employee at the end of reporting period
  --
  cursor c_tot_emps is
  SELECT count(*) num_people
    FROM  per_all_assignments_f paf
    WHERE paf.business_group_id = p_business_group_id
    AND   paf.primary_flag = 'Y'
    AND   paf.assignment_type = 'E'
    -- Bug# 5000214
    and p_end_date between paf.effective_start_date and paf.effective_end_date
    /*and   paf.effective_start_date <= p_end_date
    and   paf.effective_end_date >= p_start_date*/
    and   paf.effective_start_date = (select max(paf2.effective_start_date)
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
          if l_c2.lookup_code = '1' then
            --
            l_estab_rec.l1_total := l_c2.no_dis_vets;
            l_estab_rec.m1_total := l_c2.no_viet_vets;
            l_estab_rec.n1_total := l_c2.no_other_vets;
            --
          elsif l_c2.lookup_code = '2' then
            --
            l_estab_rec.l2_total := l_c2.no_dis_vets;
            l_estab_rec.m2_total := l_c2.no_viet_vets;
            l_estab_rec.n2_total := l_c2.no_other_vets;
            --
          elsif l_c2.lookup_code = '3' then
            --
            l_estab_rec.l3_total := l_c2.no_dis_vets;
            l_estab_rec.m3_total := l_c2.no_viet_vets;
            l_estab_rec.n3_total := l_c2.no_other_vets;
            --
          elsif l_c2.lookup_code = '4' then
            --
            l_estab_rec.l4_total := l_c2.no_dis_vets;
            l_estab_rec.m4_total := l_c2.no_viet_vets;
            l_estab_rec.n4_total := l_c2.no_other_vets;
            --
          elsif l_c2.lookup_code = '5' then
            --
            l_estab_rec.l5_total := l_c2.no_dis_vets;
            l_estab_rec.m5_total := l_c2.no_viet_vets;
            l_estab_rec.n5_total := l_c2.no_other_vets;
            --
          elsif l_c2.lookup_code = '6' then
            --
            l_estab_rec.l6_total := l_c2.no_dis_vets;
            l_estab_rec.m6_total := l_c2.no_viet_vets;
            l_estab_rec.n6_total := l_c2.no_other_vets;
            --
          elsif l_c2.lookup_code = '7' then
            --
            l_estab_rec.l7_total := l_c2.no_dis_vets;
            l_estab_rec.m7_total := l_c2.no_viet_vets;
            l_estab_rec.n7_total := l_c2.no_other_vets;
            --
          elsif l_c2.lookup_code = '8' then
            --
            l_estab_rec.l8_total := l_c2.no_dis_vets;
            l_estab_rec.m8_total := l_c2.no_viet_vets;
            l_estab_rec.n8_total := l_c2.no_other_vets;
            --
          elsif l_c2.lookup_code = '9' then
            --
            l_estab_rec.l9_total := l_c2.no_dis_vets;
            l_estab_rec.m9_total := l_c2.no_viet_vets;
            l_estab_rec.n9_total := l_c2.no_other_vets;
            --
          end if;
          --
        end loop;
        --
      close c2;
      --
      open c3;
        --
        loop
          --
          fetch c3 into l_c3;
          exit when c3%notfound;
          --
          hr_utility.set_location(l_proc,40);
          if l_c3.lookup_code = '1' then
            --
            l_estab_rec.o1_total := l_c3.no_nh_dis_vets;
            l_estab_rec.p1_total := l_c3.no_nh_viet_vets;
            l_estab_rec.q1_total := l_c3.no_nh_newly_sep_vets;
            l_estab_rec.r1_total := l_c3.no_nh_other_vets;
            l_estab_rec.s1_total := l_c3.tot_new_hires+
                                    l_c3.no_nh_dis_vets+
                                    l_c3.no_nh_viet_vets+
                                    l_c3.no_nh_newly_sep_vets+
                                    l_c3.no_nh_other_vets;
            --
          elsif l_c3.lookup_code = '2' then
            --
            l_estab_rec.o2_total := l_c3.no_nh_dis_vets;
            l_estab_rec.p2_total := l_c3.no_nh_viet_vets;
            l_estab_rec.q2_total := l_c3.no_nh_newly_sep_vets;
            l_estab_rec.r2_total := l_c3.no_nh_other_vets;
            l_estab_rec.s2_total := l_c3.tot_new_hires+
                                    l_c3.no_nh_dis_vets+
                                    l_c3.no_nh_viet_vets+
                                    l_c3.no_nh_newly_sep_vets+
                                    l_c3.no_nh_other_vets;
            --
          elsif l_c3.lookup_code = '3' then
            --
            l_estab_rec.o3_total := l_c3.no_nh_dis_vets;
            l_estab_rec.p3_total := l_c3.no_nh_viet_vets;
            l_estab_rec.q3_total := l_c3.no_nh_newly_sep_vets;
            l_estab_rec.r3_total := l_c3.no_nh_other_vets;
            l_estab_rec.s3_total := l_c3.tot_new_hires+
                                    l_c3.no_nh_dis_vets+
                                    l_c3.no_nh_viet_vets+
                                    l_c3.no_nh_newly_sep_vets+
                                    l_c3.no_nh_other_vets;
            --
          elsif l_c3.lookup_code = '4' then
            --
            l_estab_rec.o4_total := l_c3.no_nh_dis_vets;
            l_estab_rec.p4_total := l_c3.no_nh_viet_vets;
            l_estab_rec.q4_total := l_c3.no_nh_newly_sep_vets;
            l_estab_rec.r4_total := l_c3.no_nh_other_vets;
            l_estab_rec.s4_total := l_c3.tot_new_hires+
                                    l_c3.no_nh_dis_vets+
                                    l_c3.no_nh_viet_vets+
                                    l_c3.no_nh_newly_sep_vets+
                                    l_c3.no_nh_other_vets;
            --
          elsif l_c3.lookup_code = '5' then
            --
            l_estab_rec.o5_total := l_c3.no_nh_dis_vets;
            l_estab_rec.p5_total := l_c3.no_nh_viet_vets;
            l_estab_rec.q5_total := l_c3.no_nh_newly_sep_vets;
            l_estab_rec.r5_total := l_c3.no_nh_other_vets;
            l_estab_rec.s5_total := l_c3.tot_new_hires+
                                    l_c3.no_nh_dis_vets+
                                    l_c3.no_nh_viet_vets+
                                    l_c3.no_nh_newly_sep_vets+
                                    l_c3.no_nh_other_vets;
            --
          elsif l_c3.lookup_code = '6' then
            --
            l_estab_rec.o6_total := l_c3.no_nh_dis_vets;
            l_estab_rec.p6_total := l_c3.no_nh_viet_vets;
            l_estab_rec.q6_total := l_c3.no_nh_newly_sep_vets;
            l_estab_rec.r6_total := l_c3.no_nh_other_vets;
            l_estab_rec.s6_total := l_c3.tot_new_hires+
                                    l_c3.no_nh_dis_vets+
                                    l_c3.no_nh_viet_vets+
                                    l_c3.no_nh_newly_sep_vets+
                                    l_c3.no_nh_other_vets;
            --
          elsif l_c3.lookup_code = '7' then
            --
            l_estab_rec.o7_total := l_c3.no_nh_dis_vets;
            l_estab_rec.p7_total := l_c3.no_nh_viet_vets;
            l_estab_rec.q7_total := l_c3.no_nh_newly_sep_vets;
            l_estab_rec.r7_total := l_c3.no_nh_other_vets;
            l_estab_rec.s7_total := l_c3.tot_new_hires+
                                    l_c3.no_nh_dis_vets+
                                    l_c3.no_nh_viet_vets+
                                    l_c3.no_nh_newly_sep_vets+
                                    l_c3.no_nh_other_vets;
            --
          elsif l_c3.lookup_code = '8' then
            --
            l_estab_rec.o8_total := l_c3.no_nh_dis_vets;
            l_estab_rec.p8_total := l_c3.no_nh_viet_vets;
            l_estab_rec.q8_total := l_c3.no_nh_newly_sep_vets;
            l_estab_rec.r8_total := l_c3.no_nh_other_vets;
            l_estab_rec.s8_total := l_c3.tot_new_hires+
                                    l_c3.no_nh_dis_vets+
                                    l_c3.no_nh_viet_vets+
                                    l_c3.no_nh_newly_sep_vets+
                                    l_c3.no_nh_other_vets;
            --
          elsif l_c3.lookup_code = '9' then
            --
            l_estab_rec.o9_total := l_c3.no_nh_dis_vets;
            l_estab_rec.p9_total := l_c3.no_nh_viet_vets;
            l_estab_rec.q9_total := l_c3.no_nh_newly_sep_vets;
            l_estab_rec.r9_total := l_c3.no_nh_other_vets;
            l_estab_rec.s9_total := l_c3.tot_new_hires+
                                    l_c3.no_nh_dis_vets+
                                    l_c3.no_nh_viet_vets+
                                    l_c3.no_nh_newly_sep_vets+
                                    l_c3.no_nh_other_vets;
            --
          end if;
          --
        end loop;
        --
      close c3;
      --
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

        l_month_start_date := ADD_MONTHS(p_end_date,-l_month_number);
        l_month_end_date := ADD_MONTHS(l_month_start_date,1);

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
--
procedure vets_mag_report
  (errbuf                        out nocopy varchar2,
   retcode                       out nocopy number,
   p_start_date                  in  varchar2,
   p_end_date                    in  varchar2,
   p_hierarchy_id                in  number,
   p_hierarchy_version_id        in  number,
   p_business_group_id           in  number,
   p_all_establishments          in  varchar2 -- BUG3695203
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
  l_all_estab := p_all_establishments; -- BUG3695203
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
end per_vets_mag_report;

/
