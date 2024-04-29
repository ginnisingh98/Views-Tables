--------------------------------------------------------
--  DDL for Package Body OTFR2483
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTFR2483" AS
/* $Header: otfr2483.pkb 120.9 2006/09/19 18:20:08 aparkes noship $ */
--
procedure trace_sql (p_sql IN  VARCHAR2) is
  l_start number;
  l_len   number;
begin
  l_start := 1;
  hr_utility.trace('/* The ('||lengthb(p_sql)||
                   ' byte) SQL being executed is: */');
  loop
    l_len := instr(p_sql||'
','
',l_start) - l_start;
    hr_utility.trace(substr(p_sql,l_start,l_len));
    l_start := l_start + l_len +1;
    exit when l_start > length(p_sql);
  end loop;
  hr_utility.trace('/* end SQL */');
end trace_sql;
--
procedure load_xml (p_xml            in out nocopy clob,
                    p_data           varchar2) is
begin
  dbms_lob.writeappend(p_xml, length(p_data), p_data);
end load_xml;
--
procedure load_xml_declaration(p_xml            in out nocopy clob)
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
  load_xml(p_xml,'<?xml version="1.0" encoding="'||rec_lookup.tag||'" ?>
');
--
end load_xml_declaration;
--
procedure load_xml (p_xml            in out nocopy clob,
                    p_node           varchar2,
                    p_open_not_close boolean,
                    p_attribs        varchar2 default null) is
begin
  if p_open_not_close is null then
    load_xml (p_xml,'<'||p_node||rtrim(' '||p_attribs)||'/>
');
  elsif p_open_not_close then
    load_xml (p_xml,'<'||p_node||rtrim(' '||p_attribs)||'>
');
  else
    load_xml (p_xml,'</'||p_node||'>
');
  end if;
end load_xml;
--
procedure load_xml (p_xml            in out nocopy clob,
                    p_node           varchar2,
                    p_data           varchar2,
                    p_attribs        varchar2 default null)
is
  l_data varchar2(2000);
begin
  /* Handle special characters in data */
  l_data := REPLACE (p_data, '&', '&amp;');
  l_data := REPLACE (l_data, '>', '&gt;');
  l_data := REPLACE (l_data, '<', '&lt;');
  l_data := REPLACE (l_data, '''', '&apos;');
  l_data := REPLACE (l_data, '"', '&quot;');
  load_xml (p_xml,'<'||p_node||rtrim(' '||p_attribs)||'>'||
            l_data||'</'||p_node||'>
');
end load_xml;
--
procedure load_xml (p_xml            in out nocopy clob,
                    p_node           varchar2,
                    p_data           number,
                    p_attribs        varchar2 default null) is
begin
  load_xml(p_xml
          ,'<'||p_node||rtrim(' '||p_attribs)||'>'||
             fnd_number.number_to_canonical(p_data)
           ||'</'||p_node||'>
');
end load_xml;
--
procedure load_xml (p_xml            in out nocopy clob,
                    p_node           varchar2,
                    p_data           date,
                    p_attribs        varchar2 default null) is
begin
  load_xml (p_xml,'<'||p_node||rtrim(' '||p_attribs)||'>'||
            to_char(p_data,'YYYY-MM-DD')||'</'||p_node||'>
');
end load_xml;
--
FUNCTION get_dif_balance(p_assignment_id     IN NUMBER,
                         p_accrual_plan_id   IN NUMBER,
                         p_payroll_id        IN NUMBER,
                         p_business_group_id IN NUMBER,
                         p_end_date          IN DATE)  RETURN NUMBER IS
--
l_bal_accrual        number;
l_start_date         date;
l_End_Date           date;
l_Accrual_End_Date   date;
l_accrual            number;
--
BEGIN
--
  per_accrual_calc_functions.get_net_accrual(
       p_assignment_id      => p_assignment_id,
       p_plan_id            => p_accrual_plan_id,
       p_payroll_id         => p_payroll_id,
       p_business_group_id  => p_business_group_id,
       p_calculation_date   => p_end_date,
       p_accrual_start_date => TRUNC(p_end_date,'YEAR'),
       p_start_date         => l_start_date,
       p_End_Date           => l_End_Date,
       p_Accrual_End_Date   => l_Accrual_End_Date,
       p_accrual            => l_accrual,
       p_net_entitlement    => l_bal_accrual);
  --
  RETURN  l_bal_accrual;
  --
END get_dif_balance;
--
procedure build_XML (P_COMPANY_ID     IN  NUMBER,
                     P_YEAR           IN  NUMBER,
                     P_DATE_TO        IN  VARCHAR2 DEFAULT NULL,
                     P_DETAIL_SECTION IN  VARCHAR2,
                     P_TEMPLATE_NAME  IN  VARCHAR2 DEFAULT NULL,
                     p_xml            OUT NOCOPY CLOB) is
--
  TYPE t_ref_cursor IS REF CURSOR;
  l_ref_csr         t_ref_cursor;
--
  /* Bulk fetches from dynamic cursors not supported in 8.1.7; use a record: */
  TYPE t_rec  is RECORD
   (full_name    per_all_people_f.full_name%TYPE,
    order_name   per_all_people_f.order_name%TYPE,
    emp_num      per_all_people_f.employee_number%TYPE,
    trn_start    date,
    trn_end      date,
    class_name   ota_events_tl.title%TYPE,
    plan_name    ota_training_plans.name%TYPE,
    supplier     po_vendors.vendor_name%TYPE,
    leave_cat    hr_lookups.meaning%TYPE,
    legal_cat    hr_lookups.meaning%TYPE,
    act_hrs_chr  varchar2(150),
    out_hrs_chr  varchar2(150),
    chr1         varchar2(150),
    num1         number,
    num2         number,
    num3         number,
    num4         number,
    num5         number,
    num6         number,
    num7         number,
    num8         number,
    num9         number,
    num10        number,
    num11        number,
    num12        number,
    num13        number);
  /* Bulk fetches from dynamic cursors not supported in 8.1.7; dont use tables
  TYPE t_char_tbl  is TABLE of varchar2(2000) INDEX by BINARY_INTEGER;
  TYPE t_date_tbl  is TABLE of date           INDEX by BINARY_INTEGER;
  TYPE t_num_tbl   is TABLE of number         INDEX by BINARY_INTEGER;
  tbl_full_name    t_char_tbl;
  tbl_order_name   t_char_tbl;
  tbl_emp_num      t_char_tbl;
  tbl_trn_start    t_date_tbl;
  tbl_trn_end      t_date_tbl;
  tbl_class_name   t_char_tbl;
  tbl_plan_name    t_char_tbl;
  tbl_supplier     t_char_tbl;
  tbl_legal_cat    t_char_tbl;
  tbl_leave_cat    t_char_tbl;
  tbl_act_hrs_chr  t_char_tbl;
  tbl_out_hrs_chr  t_char_tbl;
  tbl_num1         t_num_tbl;
  tbl_num2         t_num_tbl;
  tbl_num3         t_num_tbl;
  tbl_num4         t_num_tbl;
  tbl_num5         t_num_tbl;
  tbl_num6         t_num_tbl;
  tbl_num7         t_num_tbl;*/
  -- Records for selecting debug data into for all sections:
  l_curr_rec       t_rec;
  l_prev_rec       t_rec;
  l_empt_rec       t_rec;  -- Empty record for re-initialising previous two
  -- "Lexical" parameters
  L_SELECT_OUTER   varchar2(3000);
  L_SELECT_INNER1  varchar2(10000);
  L_SELECT_INNER2  varchar2(3000);
  L_WHERE_INNER1   varchar2(2000);
  L_WHERE_INNER2   varchar2(2000);
  L_WHERE_TP_ORG   varchar2(400);
  L_GROUP_INNER1   varchar2(2000);
  L_ORDER_BY       varchar2(2000);
  --
  l_sql            varchar2(29000);
  --
  c_OpenGrpTag     constant boolean := TRUE;
  c_CloseGrpTag    constant boolean := FALSE;
  c_EmptyTag       constant boolean := NULL;
  --
  l_year_start     date := to_date(p_year||'0101','yyyymmdd');
  l_year_end       date := to_date(p_year||'1231','yyyymmdd');
  -- variables for pdf layout and running debug totals:
  l_tot_trn_sal    number;
  l_tot_admin_sal  number;
  l_tot_run_costs  number;
  l_tot_trn_tran   number;
  l_tot_trn_accom  number;
  l_tot_other      number;
  l_total          number;
  l_tot_act_hrs    number;
  l_tot_out_hrs    number;
  l_NOMBRE         number;  -- A
  l_b11            number;  -- B2a
  l_b12            number;  -- B2b
  l_b13            number;  -- B2c
  l_b14            number;  -- B2d
  l_b15            number;  -- B2e
  l_b16            number;  -- B2f
  l_b17            number;  -- B2g
  l_b18            number;  -- B2h
  l_b21            number;  -- B3a
  l_b22            number;  -- B3b
  l_b23            number;  -- B3c
  l_b24            number;  -- B3d
  l_b25            number;  -- B3e
  l_b26            number;  -- B3f
  l_b27            number;  -- B3g
  l_b28            number;  -- B3h
  l_b31            number;  -- B4a
  l_b32            number;  -- B4b
  l_b33            number;  -- B4c
  l_b34            number;  -- B4d
  l_b35            number;  -- B4e
  l_b36            number;  -- B4f
  l_b37            number;  -- B4g
  l_b38            number;  -- B4h
  l_b41            number;  -- B5a
  l_b42            number;  -- B5b
  l_b43            number;  -- B5c
  l_b44            number;  -- B5d
  l_b45            number;  -- B5e
  l_b46            number;  -- B5f
  l_b47            number;  -- B5g
  l_b48            number;  -- B5h
  l_c1             number;  -- B7
  l_c2             number;  -- B8
  l_c3             number;  -- B9
  l_c4             number;  -- B10
  l_c5             number;  -- B11
  l_c6             number;  -- B12
  l_C91            number;  -- Fa
  l_x1             number;  -- Fb Contracted
  l_x2             number;  -- Fb Skills Assessment
  l_x3             number;  -- Fb VAE
  l_C111           number;  -- Fc
  l_C121           number;  -- Fd
  l_C151           number;  -- Fh
  l_er_cif_contrib_rate        number;
  l_er_alternance_contrib_rate number;
  l_er_tp_contrib_rate         number;
  l_currency_rate_type         varchar2(100);
  --
  cursor csr_measurement_types(p_bg_id number) is
  select
    max(decode(tmt.tp_measurement_code,
               'FR_DEDUCT_EXT_TRN_PLAN',TMT.tp_measurement_type_id))
                                                        DEDUCTIBLE_EXT_TRN_PLAN
   ,max(decode(tmt.tp_measurement_code,
               'FR_DEDUCT_EXT_TRN_PLAN_SA',TMT.tp_measurement_type_id))
                                                     DEDUCTIBLE_EXT_TRN_PLAN_SA
   ,max(decode(tmt.tp_measurement_code,
               'FR_DEDUCT_EXT_TRN_PLAN_VAE',TMT.tp_measurement_type_id))
                                                    DEDUCTIBLE_EXT_TRN_PLAN_VAE
   ,max(decode(tmt.tp_measurement_code,
               'FR_OTHER_PLAN_DEDUCT_COSTS',TMT.tp_measurement_type_id))
                                                    OTHER_PLAN_DEDUCTIBLE_COSTS
   ,max(decode(tmt.tp_measurement_code,
               'FR_DEDUCT_TRAINER_SALARY',TMT.tp_measurement_type_id))
                                                      DEDUCTIBLE_TRAINER_SALARY
   ,max(decode(tmt.tp_measurement_code,
               'FR_DEDUCT_ADMIN_SALARY',TMT.tp_measurement_type_id))
                                                        DEDUCTIBLE_ADMIN_SALARY
   ,max(decode(tmt.tp_measurement_code,
               'FR_DEDUCT_RUNNING_COSTS',TMT.tp_measurement_type_id))
                                                       DEDUCTIBLE_RUNNING_COSTS
   ,max(decode(tmt.tp_measurement_code,
               'FR_DEDUCT_TRAINER_TRANSPRT',TMT.tp_measurement_type_id))
                                                    DEDUCTIBLE_TRAINER_TRANSPRT
   ,max(decode(tmt.tp_measurement_code,
               'FR_DEDUCT_TRAINER_ACCOM',TMT.tp_measurement_type_id))
                                                       DEDUCTIBLE_TRAINER_ACCOM
   ,max(decode(tmt.tp_measurement_code,
               'FR_DEDUCT_EXT_TRN_CLASS',TMT.tp_measurement_type_id))
                                                       DEDUCTIBLE_EXT_TRN_CLASS
   ,max(decode(tmt.tp_measurement_code,
               'FR_OTHER_CLASS_DEDUCT_COST',TMT.tp_measurement_type_id))
                                                    OTHER_CLASS_DEDUCTIBLE_COST
   ,max(decode(tmt.tp_measurement_code,
               'FR_ACTUAL_HOURS',TMT.tp_measurement_type_id))      ACTUAL_HOURS
   ,max(decode(tmt.tp_measurement_code,
               'FR_SKILLS_ASSESSMENT',TMT.tp_measurement_type_id))
                                                              SKILLS_ASSESSMENT
   ,max(decode(tmt.tp_measurement_code,
               'FR_VAE',TMT.tp_measurement_type_id))                        VAE
   ,max(decode(tmt.tp_measurement_code,
               'FR_DEDUCT_LEARNER_SALARY',TMT.tp_measurement_type_id))
                                                      DEDUCTIBLE_LEARNER_SALARY
   ,max(decode(tmt.tp_measurement_code,
               'FR_DEDUCT_TRN_ALLOWANCE',TMT.tp_measurement_type_id))
                                                       DEDUCTIBLE_TRN_ALLOWANCE
   ,max(decode(tmt.tp_measurement_code,
               'FR_OTHER_LEARN_DEDUCT_INT',TMT.tp_measurement_type_id))
                                                    OTHER_LEARN_DEDUCT_COST_INT
   ,max(decode(tmt.tp_measurement_code,
               'FR_OTHER_LEARN_DEDUCT_EXT',TMT.tp_measurement_type_id))
                                                    OTHER_LEARN_DEDUCT_COST_EXT
  from   ota_tp_measurement_types    tmt
  where  TMT.business_group_id       = p_bg_id
  and    tmt.tp_measurement_code    in ('FR_DEDUCT_EXT_TRN_PLAN',
                                        'FR_DEDUCT_EXT_TRN_PLAN_SA',
                                        'FR_DEDUCT_EXT_TRN_PLAN_VAE',
                                        'FR_OTHER_PLAN_DEDUCT_COSTS',
                                        'FR_DEDUCT_TRAINER_SALARY',
                                        'FR_DEDUCT_ADMIN_SALARY',
                                        'FR_DEDUCT_RUNNING_COSTS',
                                        'FR_DEDUCT_TRAINER_TRANSPRT',
                                        'FR_DEDUCT_TRAINER_ACCOM',
                                        'FR_DEDUCT_EXT_TRN_CLASS',
                                        'FR_OTHER_CLASS_DEDUCT_COST',
                                        'FR_ACTUAL_HOURS',
                                        'FR_SKILLS_ASSESSMENT',
                                        'FR_VAE',
                                        'FR_DEDUCT_LEARNER_SALARY',
                                        'FR_DEDUCT_TRN_ALLOWANCE',
                                        'FR_OTHER_LEARN_DEDUCT_INT',
                                        'FR_OTHER_LEARN_DEDUCT_EXT')
  and    ((tmt.tp_measurement_code  in ('FR_DEDUCT_EXT_TRN_PLAN',
                                        'FR_DEDUCT_EXT_TRN_PLAN_SA',
                                        'FR_DEDUCT_EXT_TRN_PLAN_VAE',
                                        'FR_OTHER_PLAN_DEDUCT_COSTS') and
           TMT.cost_level            = 'PLAN') or
          (tmt.tp_measurement_code  in ('FR_DEDUCT_TRAINER_SALARY',
                                        'FR_DEDUCT_ADMIN_SALARY',
                                        'FR_DEDUCT_RUNNING_COSTS',
                                        'FR_DEDUCT_TRAINER_TRANSPRT',
                                        'FR_DEDUCT_TRAINER_ACCOM',
                                        'FR_DEDUCT_EXT_TRN_CLASS',
                                        'FR_OTHER_CLASS_DEDUCT_COST') and
           TMT.cost_level            = 'EVENT') or
          (tmt.tp_measurement_code  in ('FR_ACTUAL_HOURS',
                                        'FR_SKILLS_ASSESSMENT',
                                        'FR_VAE',
                                        'FR_DEDUCT_LEARNER_SALARY',
                                        'FR_DEDUCT_TRN_ALLOWANCE',
                                        'FR_OTHER_LEARN_DEDUCT_INT',
                                        'FR_OTHER_LEARN_DEDUCT_EXT') and
           TMT.cost_level            = 'DELEGATE'))
  and    ((tmt.tp_measurement_code   = 'FR_ACTUAL_HOURS' and
           tmt.unit                  = 'N') or
          (tmt.tp_measurement_code  <> 'FR_ACTUAL_HOURS' and
           tmt.unit                  = 'M'));
  --
  l_meas_types_rec     csr_measurement_types%ROWTYPE;
  --
  cursor csr_classifications is
  select
     max(decode(pri_class.classification_name
               ,'Information',pri_class.classification_id))      inf_pri_cls_id
    ,max(decode(pri_class.classification_name
               ,'Absence',pri_class.classification_id))          abs_pri_cls_id
    ,max(decode(pri_class.classification_name
               ,'Information',sub_class.classification_id))  dif_inf_sub_cls_id
    ,max(decode(pri_class.classification_name
               ,'Absence',sub_class.classification_id))      dif_abs_sub_cls_id
  from  pay_element_classifications pri_class,
        pay_element_classifications sub_class
  where pri_class.classification_name     in ('Information','Absence')
    and pri_class.business_group_id       is null
    and pri_class.legislation_code         = 'FR'
    and sub_class.parent_classification_id = pri_class.classification_id
    and sub_class.classification_name      = 'DIF Absence : '||
                                                  pri_class.classification_name
    and sub_class.business_group_id       is null
    and sub_class.legislation_code         = 'FR';
  --
  l_classification_rec   csr_classifications%ROWTYPE;
  --
  cursor csr_header is
  select
    greatest(comp.date_from,l_year_start)                                 date1
   ,least(nvl(comp.date_to,l_year_end),l_year_end)                        date2
   ,substr(tax_office_loc.address_line_1,1,45)                              ad1
   ,substr(tax_office_loc.address_line_2,1,45)                              ad2
   ,substr(tax_office_loc.region_3,1,45)                                    ad3
   ,substr(tax_office_loc.postal_code||' '||
           tax_office_loc.town_or_city,1,45)                                ad4
   ,substr(comp_tl.name,1,45)                                               ad5
   ,substr(comp_loc.address_line_1,1,45)                                    ad6
   ,substr(ltrim(rtrim(comp_loc.address_line_2||', '||
           comp_loc.region_3,', '),', '),1,45)                              ad7
   ,substr(comp_loc.postal_code||' '||
           comp_loc.town_or_city,1,45)                                      ad8
   ,comp_2483_info.org_information2                                     recette
   ,comp_2483_info.org_information3                                     dossier
   ,comp_2483_info.org_information4                                         cle
   ,comp_2483_info.org_information5                                      regime
   ,comp_2483_info.org_information6                                       impot
   ,substr(hq_info.org_information2,1,9)                                 siret1
   ,substr(hq_info.org_information2,10,5)                                  code
   ,nvl(comp_info.org_information2,hq_info.org_information3)                ape
   ,comp_2483_info.org_information7                intermittent_and_homeworkers
   ,comp_2483_info.org_information8                                    tp_level
   ,comp.business_group_id                                                bg_id
   ,ceil(months_between(
           decode(
               least(nvl(comp.date_to,l_year_end),l_year_end),
               last_day(least(nvl(comp.date_to,l_year_end),l_year_end)),
               least(nvl(comp.date_to,l_year_end),l_year_end),
               trunc(least(nvl(comp.date_to,l_year_end),l_year_end),'MM')),
           greatest(comp.date_from,l_year_start)))   comp_active_mths_in_yr
  from
    hr_all_organization_units    comp,
    hr_organization_information  comp_2483_info,
    hr_all_organization_units    tax_office,
    hr_locations_all             tax_office_loc,
    hr_all_organization_units_TL comp_tl,
    hr_locations_all             comp_loc,
    hr_organization_information  comp_info,
    hr_organization_information  HQ_info
  where comp.organization_id        = p_company_id
    and comp.date_from             <= l_year_end
    and (comp.date_to              is null or
         comp.date_to              >= l_year_start)
    and comp_2483_info.org_information_context(+) = 'FR_COMP_2483_INFO'
    and comp_2483_info.organization_id        (+) = comp.organization_id
    and tax_office.organization_id(+) = comp_2483_info.org_information1
    and tax_office_loc.location_id(+) = tax_office.location_id
    and comp_tl.organization_id     = comp.organization_id
    and comp_tl.language            = USERENV('LANG')
    and comp_loc.location_id(+)     = comp.location_id
    and comp_info.org_information_context(+) = 'FR_COMP_INFO'
    and comp_info.organization_id        (+) = comp.organization_id
    and HQ_info.organization_id        (+) = comp_info.org_information5
    and HQ_info.org_information_context(+) = 'FR_ESTAB_INFO';
  --
  l_header_rec     csr_header%ROWTYPE;
  --
  cursor csr_comp_training_contrib_info(p_effective_date_chr varchar2) is
  select org_information3 reduction_chr
  from   hr_organization_information tng_cntrib
  where  tng_cntrib.organization_id = p_company_id
  and    tng_cntrib.org_information_context = 'FR_COMP_TRAINING_CONTRIB'
  and    p_effective_date_chr between tng_cntrib.org_information1
                                  and nvl(tng_cntrib.org_information2
                                         ,p_effective_date_chr);
  --
  l_training_contrib_rec csr_comp_training_contrib_info%ROWTYPE;
--
begin
  dbms_lob.createtemporary(p_xml, TRUE, dbms_lob.session);
  dbms_lob.open(p_xml,dbms_lob.lob_readwrite);
  load_xml_declaration(p_xml);
  load_xml(p_xml,'FIELDS',c_OpenGrpTag);
  --
  open csr_header;
  fetch csr_header into l_header_rec;
  close csr_header;
  --
  if p_detail_section = 'NA' then
    -- write XML for pdf Header
    -- (setting date1 and date2 to null if company active all year)
    if l_header_rec.date1 <> l_year_start
    or l_header_rec.date2 <> l_year_end
    then
      load_xml(p_xml,'date1',to_char(l_header_rec.date1,'dd/mm/yyyy'));
      load_xml(p_xml,'date2',to_char(l_header_rec.date2,'dd/mm/yyyy'));
    end if;
    load_xml(p_xml,'ad1',l_header_rec.ad1);
    load_xml(p_xml,'ad2',l_header_rec.ad2);
    load_xml(p_xml,'ad3',l_header_rec.ad3);
    load_xml(p_xml,'ad4',l_header_rec.ad4);
    load_xml(p_xml,'ad5',l_header_rec.ad5);
    load_xml(p_xml,'ad6',l_header_rec.ad6);
    load_xml(p_xml,'ad7',l_header_rec.ad7);
    load_xml(p_xml,'ad8',l_header_rec.ad8);
    load_xml(p_xml,'recette',l_header_rec.recette);
    load_xml(p_xml,'dossier',l_header_rec.dossier);
    load_xml(p_xml,'cle',l_header_rec.cle);
    load_xml(p_xml,'regime',l_header_rec.regime);
    load_xml(p_xml,'impot',l_header_rec.impot);
    load_xml(p_xml,'siret1',l_header_rec.siret1);
    load_xml(p_xml,'code',l_header_rec.code);
    load_xml(p_xml,'ape',l_header_rec.ape);
    --
    -- get the currency rate type for conversions.
    l_currency_rate_type := hr_currency_pkg.get_rate_type(l_header_rec.bg_id
                                                         ,sysdate,'R');
    --
  else
    -- write XML for rtf Header
    load_xml(p_xml,'date',sysdate);
    load_xml(p_xml,'HEADER',c_OpenGrpTag);
    load_xml(p_xml,'COMPANY_NAME',l_header_rec.ad5);
    load_xml(p_xml,'DATE_FROM',l_header_rec.date1);
    load_xml(p_xml,'DATE_TO',l_header_rec.date2);
    load_xml(p_xml,'DETAIL_SECTION',
             hr_general.decode_lookup('FR_2483_DEBUG_SECTIONS',
                                      p_detail_section));
    load_xml(p_xml,'HEADER',c_CloseGrpTag);
  end if;
  --
  if l_header_rec.tp_level = 'ESTAB' then
    L_WHERE_TP_ORG := '
  and tp_org_info.org_information_context = ''FR_ESTAB_INFO''
  and tp_org_info.org_information1        = to_char(comp.organization_id)';
  else -- default to Company level
    L_WHERE_TP_ORG := '
  and tp_org_info.org_information_context = ''FR_COMP_INFO''
  and tp_org_info.organization_id         = comp.organization_id';
  end if;
  --
  open csr_measurement_types(l_header_rec.bg_id);
  fetch csr_measurement_types into l_meas_types_rec;
  close csr_measurement_types;
  --
  if p_detail_section in ('A','NA') then
    hr_utility.trace('comp_active_mths_in_yr: '||
                     l_header_rec.comp_active_mths_in_yr);
    if p_detail_section = 'NA' then
      hr_utility.trace('Section A PDF');
      L_SELECT_OUTER := 'select
   round((
       trunc(nvl(sum(decode(emp_mth.mth_num,1 ,mth_count)),0))+
       trunc(nvl(sum(decode(emp_mth.mth_num,2 ,mth_count)),0))+
       trunc(nvl(sum(decode(emp_mth.mth_num,3 ,mth_count)),0))+
       trunc(nvl(sum(decode(emp_mth.mth_num,4 ,mth_count)),0))+
       trunc(nvl(sum(decode(emp_mth.mth_num,5 ,mth_count)),0))+
       trunc(nvl(sum(decode(emp_mth.mth_num,6 ,mth_count)),0))+
       trunc(nvl(sum(decode(emp_mth.mth_num,7 ,mth_count)),0))+
       trunc(nvl(sum(decode(emp_mth.mth_num,8 ,mth_count)),0))+
       trunc(nvl(sum(decode(emp_mth.mth_num,9 ,mth_count)),0))+
       trunc(nvl(sum(decode(emp_mth.mth_num,10,mth_count)),0))+
       trunc(nvl(sum(decode(emp_mth.mth_num,11,mth_count)),0))+
       trunc(nvl(sum(decode(emp_mth.mth_num,12,mth_count)),0)))/
       :num_comp_months)                                                 NOMBRE
FROM (';
      L_ORDER_BY     := ') emp_mth';
    else
      hr_utility.trace('Section A RTF');
      L_SELECT_OUTER := 'select
       emp_mth.full_name,
       emp_mth.order_name,
       emp_mth.employee_number,
       sum(decode(emp_mth.mth_num,1 ,mth_count))                          m1,
       sum(decode(emp_mth.mth_num,2 ,mth_count))                          m2,
       sum(decode(emp_mth.mth_num,3 ,mth_count))                          m3,
       sum(decode(emp_mth.mth_num,4 ,mth_count))                          m4,
       sum(decode(emp_mth.mth_num,5 ,mth_count))                          m5,
       sum(decode(emp_mth.mth_num,6 ,mth_count))                          m6,
       sum(decode(emp_mth.mth_num,7 ,mth_count))                          m7,
       sum(decode(emp_mth.mth_num,8 ,mth_count))                          m8,
       sum(decode(emp_mth.mth_num,9 ,mth_count))                          m9,
       sum(decode(emp_mth.mth_num,10,mth_count))                         m10,
       sum(decode(emp_mth.mth_num,11,mth_count))                         m11,
       sum(decode(emp_mth.mth_num,12,mth_count))                         m12,
       sum(mth_count)                                                EMP_TOT
from (';
      L_ORDER_BY     := ') emp_mth
group by emp_mth.order_name,emp_mth.employee_number,emp_mth.full_name
order by emp_mth.order_name,emp_mth.employee_number';
    end if; -- debug or PDF
    if l_header_rec.intermittent_and_homeworkers = 'INCL' then
      L_WHERE_INNER1 := null;
    else
      L_WHERE_INNER1 := '
  /* Exclude intermittent and home workers as per 2483 company info */
  and  substr(hruserdt.get_table_value(
                 org_comp.business_group_id,
                 ''FR_CIPDZ'',
                 ''CIPDZ'',
                 nvl(ass.employment_category,''FR''),
                 month.end_date),1,1) not in (''I'', ''D'')';
    end if;
    l_sql := L_SELECT_OUTER||' /* emp_mth */
Select
  per.full_name,
  per.order_name,
  per.employee_number,
  month.num mth_num,
  decode(
     substr(hruserdt.get_table_value(org_comp.business_group_id,''FR_CIPDZ'',
                                     ''CIPDZ'',
                                     nvl(ass.employment_category,''FR''),
                                     month.end_date),1,1)
    ,''C'',decode(
            sign(greatest(sign(pos.date_start- month.start_date) ,0) +
                 GREATEST(sign(nvl(month.end_date -
                                   pos.actual_termination_date,0)),0))
           ,1,/* Starter or Leaver*/
              decode(
                 length(scl.segment5)+length(scl.segment11)
                ,null,/*No work pattern; use Cal days*/
                      ((Least(nvl(pos.actual_termination_date,month.end_date)
                             ,month.end_date) + 1 -
                        greatest(month.START_DATE,pos.date_start))/30)*
                      pay_fr_general.CONVERT_HOURS(
                        month.end_date,
                        org_comp.business_group_id,
                        ass.assignment_id,
                        decode(ctr.ctr_information12
                              ,''HOUR'',fnd_number.canonical_to_number(
                                                         ctr.ctr_information11)
                              ,nvl(ass.normal_hours,0)),
                        nvl(decode(ctr.ctr_information12
                                  ,''HOUR'',ctr.ctr_information13
                                  ,ass.frequency),''M''),
                        ''M'') /200
                ,pay_fr_schedule_calculation.scheduled_working_hours
                   (ass.assignment_id,
                    month.end_date,
                    greatest(month.start_date,pos.date_start),
                    Least(nvl(pos.actual_termination_date,month.end_date)
                         ,month.end_date))/200 )
           ,1)
    ,''P'',pay_fr_general.CONVERT_HOURS(
           month.end_date,
           org_comp.business_group_id,
           ass.assignment_id,
           decode(
              ctr.ctr_information12
             ,''HOUR'',fnd_number.canonical_to_number(ctr.ctr_information11)
             ,nvl(ass.normal_hours,0)),
           nvl(decode(ctr.ctr_information12
                     ,''HOUR'',ctr.ctr_information13
                     ,ass.frequency)
              ,''M''),
           ''M'') /
        fnd_number.canonical_to_number(org_info_estab.org_information4)
     ,1 /*I or D*/)                                                   mth_count
from hr_all_organization_units   org_comp,
     hr_all_organization_units   org_estab,
     hr_organization_information org_info_estab,
     per_all_assignments_f       ass,
     (select
         to_number(hlu.lookup_code)                                        num,
         to_date(''01''||hlu.lookup_code||:p_year,''DDMMYYYY'')     start_date,
         last_day(to_date(''01''||hlu.lookup_code||:p_year,''DDMMYYYY''))
                                                                      end_date
      from hr_lookups hlu
      where lookup_type = ''MONTH_OF_YEAR'') month,
     per_contracts_f             ctr,
     hr_soft_coding_keyflex      scl,
     per_periods_of_service      pos,
     per_all_people_f            per
where org_comp.organization_id        = :p_company_id
  and org_comp.date_from             <= :p_year_end
  and (org_comp.date_to              is null or
       org_comp.date_to              >= :p_year_start)
  and org_info_estab.org_information1 = org_comp.organization_id
  and org_info_estab.org_information_context = ''FR_ESTAB_INFO''
  and org_info_estab.organization_id  = org_estab.organization_id
  and org_estab.organization_id       = ass.establishment_id
  and org_estab.date_from            <= :p_year_end
  and (org_estab.date_to             is null or
       org_estab.date_to             >= :p_year_start)
  and ass.primary_flag                = ''Y''
  /* rough filter on asg dates: */
  and ass.effective_start_date       <= :p_year_end
  and ass.effective_end_date         >= :p_year_start
  /* Get 1 asg row for each month.  Assumes final close would be at end of
     month of ATD or beyond */
  and month.end_date            between ass.effective_start_date
                                    and ass.effective_end_date
  and month.end_date            between org_comp.date_from
                                    and nvl(org_comp.date_to,:p_year_end)
  and month.end_date            between org_estab.date_from
                                    and nvl(org_estab.date_to,:p_year_end)
  and pos.period_of_service_id        = ass.period_of_service_id
  /* filter out months where no overlapping active period of service */
  /* Also exclude CWKs; they wont have a period of service*/
  and pos.date_start                 <= month.end_date
  and (pos.actual_termination_date   is null or
       pos.actual_termination_date   >= month.start_date)
  /* exclude specific contract types */
  and ctr.contract_id                 = ass.contract_id
  and month.end_date            between ctr.effective_start_date
                                    and ctr.effective_end_date
  and ctr.type                   not in (''APPRENTICESHIP'', ''ADAPTATION'',
                                         ''QUALIFICATION'', ''ORIENTATION'',
                                         ''SOLIDARITY'',
                                         ''PROFESSIONALISATION'')
  /* exclude detaches */
  and ass.soft_coding_keyflex_id      = scl.soft_coding_keyflex_id
  and scl.segment12                  is null   /* Detache Status */'||
  L_WHERE_INNER1||'
  and per.person_id                   = ass.person_id
  and :p_comp_end               between per.effective_start_date
                                    and per.effective_end_date'||L_ORDER_BY;
    --
    -- trace_sql(l_sql);
    l_NOMBRE           := 0;
    if p_detail_section = 'NA' then
      if l_header_rec.comp_active_mths_in_yr <> 0 then
        OPEN l_ref_csr for l_sql using l_header_rec.comp_active_mths_in_yr
          ,p_year,p_year,p_company_id,l_year_end,l_year_start,l_year_end
          ,l_year_start,l_year_end,l_year_start,l_year_end,l_year_end
          ,l_header_rec.date2;
        fetch l_ref_csr into l_NOMBRE;
        close l_ref_csr;
      end if;
      --  Assemble pdf XML...
      load_xml(p_xml,'nombre',l_NOMBRE);
    else -- debug
      --  Assemble rtf XML...
      load_xml(p_xml,'SECTION_A',c_OpenGrpTag);
      -- Use l_prev_rec to maintain month totals
      l_prev_rec.num1 := 0;
      l_prev_rec.num2 := 0;
      l_prev_rec.num3 := 0;
      l_prev_rec.num4 := 0;
      l_prev_rec.num5 := 0;
      l_prev_rec.num6 := 0;
      l_prev_rec.num7 := 0;
      l_prev_rec.num8 := 0;
      l_prev_rec.num9 := 0;
      l_prev_rec.num10 := 0;
      l_prev_rec.num11 := 0;
      l_prev_rec.num12 := 0;
      l_prev_rec.num13 := 0;
      if l_header_rec.comp_active_mths_in_yr <> 0 then
        OPEN l_ref_csr for l_sql using
           p_year,p_year,p_company_id,l_year_end,l_year_start,l_year_end
          ,l_year_start,l_year_end,l_year_start,l_year_end,l_year_end
          ,l_header_rec.date2;
        /* Bulk fetches from dynamic cursors not supported in 8.1.7 */
        loop
          fetch l_ref_csr into l_curr_rec.full_name, l_curr_rec.order_name,
            l_curr_rec.emp_num, l_curr_rec.num1, l_curr_rec.num2,
            l_curr_rec.num3, l_curr_rec.num4, l_curr_rec.num5, l_curr_rec.num6,
            l_curr_rec.num7, l_curr_rec.num8, l_curr_rec.num9, l_curr_rec.num10,
            l_curr_rec.num11, l_curr_rec.num12, l_curr_rec.num13;
          exit when l_ref_csr%NOTFOUND;
          -- Load emp row
          load_xml(p_xml,'EMP',c_OpenGrpTag);
          load_xml(p_xml,'FULL_NAME',      l_curr_rec.full_name);
          load_xml(p_xml,'EMPLOYEE_NUMBER',l_curr_rec.emp_num);
          load_xml(p_xml,'M1',             l_curr_rec.num1);
          load_xml(p_xml,'M2',             l_curr_rec.num2);
          load_xml(p_xml,'M3',             l_curr_rec.num3);
          load_xml(p_xml,'M4',             l_curr_rec.num4);
          load_xml(p_xml,'M5',             l_curr_rec.num5);
          load_xml(p_xml,'M6',             l_curr_rec.num6);
          load_xml(p_xml,'M7',             l_curr_rec.num7);
          load_xml(p_xml,'M8',             l_curr_rec.num8);
          load_xml(p_xml,'M9',             l_curr_rec.num9);
          load_xml(p_xml,'M10',            l_curr_rec.num10);
          load_xml(p_xml,'M11',            l_curr_rec.num11);
          load_xml(p_xml,'M12',            l_curr_rec.num12);
          load_xml(p_xml,'EMP_TOT',        l_curr_rec.num13);
          load_xml(p_xml,'EMP',c_CloseGrpTag);
          -- Use l_prev_rec to maintain month totals
          l_prev_rec.num1 := l_prev_rec.num1 + nvl(l_curr_rec.num1,0);
          l_prev_rec.num2 := l_prev_rec.num2 + nvl(l_curr_rec.num2,0);
          l_prev_rec.num3 := l_prev_rec.num3 + nvl(l_curr_rec.num3,0);
          l_prev_rec.num4 := l_prev_rec.num4 + nvl(l_curr_rec.num4,0);
          l_prev_rec.num5 := l_prev_rec.num5 + nvl(l_curr_rec.num5,0);
          l_prev_rec.num6 := l_prev_rec.num6 + nvl(l_curr_rec.num6,0);
          l_prev_rec.num7 := l_prev_rec.num7 + nvl(l_curr_rec.num7,0);
          l_prev_rec.num8 := l_prev_rec.num8 + nvl(l_curr_rec.num8,0);
          l_prev_rec.num9 := l_prev_rec.num9 + nvl(l_curr_rec.num9,0);
          l_prev_rec.num10 := l_prev_rec.num10 + nvl(l_curr_rec.num10,0);
          l_prev_rec.num11 := l_prev_rec.num11 + nvl(l_curr_rec.num11,0);
          l_prev_rec.num12 := l_prev_rec.num12 + nvl(l_curr_rec.num12,0);
          l_prev_rec.num13 := l_prev_rec.num13 + nvl(l_curr_rec.num13,0);
        end loop;
        close l_ref_csr;
      end if; -- l_header_rec.comp_active_mths_in_yr <> 0
      load_xml(p_xml,'T1',             l_prev_rec.num1);
      load_xml(p_xml,'T2',             l_prev_rec.num2);
      load_xml(p_xml,'T3',             l_prev_rec.num3);
      load_xml(p_xml,'T4',             l_prev_rec.num4);
      load_xml(p_xml,'T5',             l_prev_rec.num5);
      load_xml(p_xml,'T6',             l_prev_rec.num6);
      load_xml(p_xml,'T7',             l_prev_rec.num7);
      load_xml(p_xml,'T8',             l_prev_rec.num8);
      load_xml(p_xml,'T9',             l_prev_rec.num9);
      load_xml(p_xml,'T10',            l_prev_rec.num10);
      load_xml(p_xml,'T11',            l_prev_rec.num11);
      load_xml(p_xml,'T12',            l_prev_rec.num12);
      load_xml(p_xml,'CMP_TOT',        l_prev_rec.num13);
      if l_header_rec.comp_active_mths_in_yr <> 0 then
        l_NOMBRE := round((
         trunc(l_prev_rec.num1) +
         trunc(l_prev_rec.num2) +
         trunc(l_prev_rec.num3) +
         trunc(l_prev_rec.num4) +
         trunc(l_prev_rec.num5) +
         trunc(l_prev_rec.num6) +
         trunc(l_prev_rec.num7) +
         trunc(l_prev_rec.num8) +
         trunc(l_prev_rec.num9) +
         trunc(l_prev_rec.num10) +
         trunc(l_prev_rec.num11) +
         trunc(l_prev_rec.num12)) / l_header_rec.comp_active_mths_in_yr);
      end if; -- l_header_rec.comp_active_mths_in_yr <> 0
      load_xml(p_xml,'NOMBRE', l_NOMBRE);
      load_xml(p_xml,'SECTION_A',c_CloseGrpTag);
    end if; -- debug
  end if; -- section A
  --
  if p_detail_section in ('B2','B3','B4','B5','NA') then
    open  csr_classifications;
    fetch csr_classifications into l_classification_rec;
    close csr_classifications;
    if p_detail_section = 'NA' then
      hr_utility.trace('Section B2-5 PDF');
      L_SELECT_OUTER := 'select
   nvl(sum(decode(emp_cat,2,mcnt)),0)                                       b11
  ,nvl(sum(decode(emp_cat,2,fcnt)),0)                                       b12
  ,count(distinct decode(emp_cat,2,mtrn_id))                                b13
  ,count(distinct decode(emp_cat,2,ftrn_id))                                b14
  ,round(nvl(sum(decode(emp_cat,2,trn_hrs)),0))                             b15
  ,count(distinct decode(emp_cat,2,dif_trn_id))                             b16
  ,round(nvl(sum(decode(emp_cat,2,dif_hrs)),0))                             b17
  ,round(nvl(sum(decode(emp_cat,2,dif_bal)),0))                             b18
  ,nvl(sum(decode(emp_cat,3,mcnt)),0)                                       b21
  ,nvl(sum(decode(emp_cat,3,fcnt)),0)                                       b22
  ,count(distinct decode(emp_cat,3,mtrn_id))                                b23
  ,count(distinct decode(emp_cat,3,ftrn_id))                                b24
  ,round(nvl(sum(decode(emp_cat,3,trn_hrs)),0))                             b25
  ,count(distinct decode(emp_cat,3,dif_trn_id))                             b26
  ,round(nvl(sum(decode(emp_cat,3,dif_hrs)),0))                             b27
  ,round(nvl(sum(decode(emp_cat,3,dif_bal)),0))                             b28
  ,nvl(sum(decode(emp_cat,4,mcnt)),0)                                       b31
  ,nvl(sum(decode(emp_cat,4,fcnt)),0)                                       b32
  ,count(distinct decode(emp_cat,4,mtrn_id))                                b33
  ,count(distinct decode(emp_cat,4,ftrn_id))                                b34
  ,round(nvl(sum(decode(emp_cat,4,trn_hrs)),0))                             b35
  ,count(distinct decode(emp_cat,4,dif_trn_id))                             b36
  ,round(nvl(sum(decode(emp_cat,4,dif_hrs)),0))                             b37
  ,round(nvl(sum(decode(emp_cat,4,dif_bal)),0))                             b38
  ,nvl(sum(decode(emp_cat,5,mcnt)),0)                                       b41
  ,nvl(sum(decode(emp_cat,5,fcnt)),0)                                       b42
  ,count(distinct decode(emp_cat,5,mtrn_id))                                b43
  ,count(distinct decode(emp_cat,5,ftrn_id))                                b44
  ,round(nvl(sum(decode(emp_cat,5,trn_hrs)),0))                             b45
  ,count(distinct decode(emp_cat,5,dif_trn_id))                             b46
  ,round(nvl(sum(decode(emp_cat,5,dif_hrs)),0))                             b47
  ,round(nvl(sum(decode(emp_cat,5,dif_bal)),0))                             b48
FROM (
';
      L_ORDER_BY     := ')';
      L_SELECT_INNER1:= '
      decode(substr(job.job_information1,1,1)
            ,''5'',3
            ,''4'',4
            ,''3'',5
            ,''6'',2)                                                   emp_cat
     ,';
      L_WHERE_INNER1 := '
  AND (job.job_information1           LIKE ''3%'' OR
       job.job_information1           LIKE ''4%'' OR
       job.job_information1           LIKE ''5%'' OR
       job.job_information1           LIKE ''62%'' OR
       job.job_information1           LIKE ''63%'' OR
       job.job_information1           LIKE ''64%'' OR
       job.job_information1           LIKE ''65%'' OR
       job.job_information1           LIKE ''66%'' OR
       job.job_information1           LIKE ''67%'' OR
       job.job_information1           LIKE ''68%'' OR
       job.job_information1           LIKE ''69%'')';
    else -- debug
      hr_utility.trace('Section '||p_detail_section||' RTF');
      L_SELECT_OUTER := 'select
   full_name
  ,order_name
  ,employee_number
  ,sum(mcnt)                                                               mcnt
  ,sum(fcnt)                                                               fcnt
  ,count(distinct mtrn_id)                                                 mtrn
  ,count(distinct ftrn_id)                                                 ftrn
  ,sum(trn_hrs)                                                         trn_hrs
  ,count(distinct dif_trn_id)                                           dif_trn
  ,sum(dif_hrs)                                                         dif_hrs
  ,sum(dif_bal)                                                         dif_bal
FROM (
';
      L_ORDER_BY     := ')
GROUP BY order_name,employee_number,full_name
ORDER BY order_name,employee_number';

      L_SELECT_INNER1:= '
      per.full_name                                                   full_name
     ,per.order_name                                                 order_name
     ,per.employee_number                                       employee_number
     ,';
      if p_detail_section = 'B2' then
        L_WHERE_INNER1 := '
  AND substr(job.job_information1,2,1) BETWEEN ''2'' AND ''9''
  AND job.job_information1            LIKE :emp_cat||''%''';
      else
        L_WHERE_INNER1 := '
  AND job.job_information1            LIKE :emp_cat||''%''';
      end if; -- debug line
    end if; -- debug or PDF
    l_sql := L_SELECT_OUTER||'SELECT /* a and b */'||L_SELECT_INNER1||
     'decode(per.sex, ''M'',1, 0)                                          mcnt
     ,decode(per.sex, ''F'',1, 0)                                          fcnt
     ,to_number(NULL)                                                   mtrn_id
     ,to_number(NULL)                                                   ftrn_id
     ,to_number(NULL)                                                   trn_hrs
     ,to_number(NULL)                                                dif_trn_id
     ,to_number(NULL)                                                   dif_hrs
     ,to_number(NULL)                                                   dif_bal
FROM hr_all_organization_units    comp,
     hr_organization_information  estab_info,
     hr_all_organization_units    estab,
     per_all_assignments_f        ass,
     per_jobs                     job,
     per_periods_of_service       ppos,
     per_all_people_f             per
WHERE comp.organization_id               = :p_company_id
  AND comp.date_from                    <= :p_year_end
  AND (comp.date_to                     IS NULL OR
       comp.date_to                     >= :p_year_start)
  AND estab_info.org_information1        = to_char(comp.organization_id)
  AND estab_info.org_information_context = ''FR_ESTAB_INFO''
  AND estab.organization_id              = estab_info.organization_id
  AND estab.date_from                   <= :p_year_end
  AND (estab.date_to                    IS NULL OR
       estab.date_to                    >= :p_year_start)
  AND estab.organization_id              = ass.establishment_id
  AND ass.primary_flag                   = ''Y''
  AND :p_comp_end                  BETWEEN ass.effective_start_date
                                       AND ass.effective_end_date
  AND ass.job_id                         = job.job_id
  AND job.job_information_category       = ''FR'' '||L_WHERE_INNER1||'
  AND ass.person_id                      = per.person_id
  AND :p_comp_end                  BETWEEN per.effective_start_date
                                       AND per.effective_end_date
  /* exclude contingent workers by joining with periods of service
     and also check for active employees */
  AND ppos.period_of_service_id          = ass.period_of_service_id
  and ppos.date_start                   <= :p_comp_end
  and (ppos.actual_termination_date     is null or
       ppos.actual_termination_date     >= :p_comp_end)
UNION ALL
SELECT /* c, d, e, f, and g absences */'||L_SELECT_INNER1||
     'TO_NUMBER(NULL)                                                      mcnt
     ,TO_NUMBER(NULL)                                                      fcnt
     ,DECODE(pabs.abs_information18 /* Within Training Plan */
            ,''N'',DECODE(per.sex, ''M'', per.person_id))               mtrn_id
     ,DECODE(pabs.abs_information18 /* Within Training Plan */
            ,''N'',DECODE(per.sex, ''F'', per.person_id))               ftrn_id
     ,DECODE(pabs.abs_information18 /* Within Training Plan */
            ,''N'',nvl(pabs.absence_hours,0))                           trn_hrs
     ,DECODE(sub_class.classification_id
            ,NULL,TO_NUMBER(NULL)
            ,decode(pabs.abs_information1
                   ,''OTHER'',per.person_id))                        dif_trn_id
     ,DECODE(sub_class.classification_id
            ,NULL,TO_NUMBER(NULL)
            ,decode(pabs.abs_information1
                   ,''OTHER'',nvl(pabs.absence_hours,0)))               dif_hrs
     ,to_number(NULL)                                                   dif_bal
FROM hr_all_organization_units      comp,
     hr_organization_information    estab_info,
     hr_all_organization_units      estab,
     per_all_assignments_f          ass,
     per_jobs                       job,
     per_all_people_f               per,
     per_absence_attendances        pabs,
     per_absence_attendance_types   pabt,
     per_contracts_f                con,
     pay_input_values_f             piv,
     pay_element_types_f            ele,
     pay_sub_classification_rules_f sub_class
WHERE comp.organization_id               = :p_company_id
  AND comp.date_from                    <= :p_year_end
  AND (comp.date_to                     IS NULL OR
       comp.date_to                     >= :p_year_start)
  AND estab_info.org_information1        = to_char(comp.organization_id)
  AND estab_info.org_information_context = ''FR_ESTAB_INFO''
  AND estab.organization_id              = estab_info.organization_id
  AND estab.date_from                   <= :p_year_end
  AND (estab.date_to                    IS NULL OR
       estab.date_to                    >= :p_year_start)
  AND estab.organization_id              = ass.establishment_id
  AND ass.primary_flag                   = ''Y''
  /* rough filter on asg dates: */
  and ass.effective_start_date          <= :p_comp_end
  and ass.effective_end_date            >= :p_comp_start
  AND ass.job_id                         = job.job_id
  AND job.job_information_category       = ''FR'' '||L_WHERE_INNER1||'
  AND ass.person_id                      = per.person_id
  AND :p_comp_end                  BETWEEN per.effective_start_date
                                       AND per.effective_end_date
  AND ass.person_id                      = pabs.person_id
  AND pabs.abs_information_category      = ''FR_TRAINING_ABSENCE''
  AND pabs.date_end                BETWEEN ass.effective_start_date
                                       AND ass.effective_end_date
  AND pabs.date_end                BETWEEN :p_comp_start
                                       AND :p_comp_end
  AND pabs.absence_attendance_type_id    = pabt.absence_attendance_type_id
  AND pabt.absence_category              = ''TRAINING_ABSENCE''
  AND con.contract_id                    = ass.contract_id
  AND pabs.date_end                BETWEEN con.effective_start_date
                                       AND con.effective_end_date
  AND pabt.input_value_id                = piv.input_value_id (+)
  AND pabt.date_effective          BETWEEN piv.effective_start_date (+)
                                       AND piv.effective_end_date   (+)
  AND ele.element_type_id(+)             = piv.element_type_id
  AND piv.effective_start_date     BETWEEN ele.effective_start_date (+)
                                       AND ele.effective_end_date   (+)
  AND sub_class.element_type_id(+)       = ele.element_type_id
  AND ele.effective_start_date     BETWEEN sub_class.effective_start_date(+)
                                       AND sub_class.effective_end_date  (+)
  AND sub_class.classification_id(+)     = decode(ele.classification_id
                                                ,:inf_pri_cls,:dif_inf_sub_cls
                                                ,:abs_pri_cls,:dif_abs_sub_cls)
  AND con.type                      NOT IN (''APPRENTICESHIP'',
                                            ''ADAPTATION'',
                                            ''QUALIFICATION'',
                                            ''PROFESSIONALISATION'')
  AND ((/*c, d and e*/
        pabs.abs_information1           IN (''VAE'',
                                            ''OTHER'',
                                            ''SKILLS_ASSESSMENT'',
                                            ''PP'') AND
        /*Not Within Training Plan */
        pabs.abs_information18           = ''N''/* nullable */) OR
       (/*f and g*/
        pabs.abs_information1            = ''OTHER'' AND
        /* DIF absences only */
        sub_class.classification_id     IS NOT NULL))
UNION ALL
SELECT /* c, d, and e OTA costs */'||L_SELECT_INNER1||
     'TO_NUMBER(NULL)                                                      mcnt
     ,TO_NUMBER(NULL)                                                      fcnt
     ,DECODE(per.sex, ''M'', per.person_id)                             mtrn_id
     ,DECODE(per.sex, ''F'', per.person_id)                             ftrn_id
     ,decode(tmt.tp_measurement_code
            ,''FR_ACTUAL_HOURS'',tpc.amount
            ,nvl(fnd_number.canonical_to_number(tpc.tp_cost_information3)
                ,0))                                                    trn_hrs
     ,to_number(NULL)                                                dif_trn_id
     ,to_number(NULL)                                                   dif_hrs
     ,to_number(NULL)                                                   dif_bal
from
  hr_all_organization_units   comp,
  hr_organization_information tp_org_info,
  hr_all_organization_units   org,
  ota_training_plans          TP,
  per_time_periods            PTP,
  ota_training_plan_costs     TPC,
  ota_tp_measurement_types    TMT,
  ota_delegate_bookings       ODB,
  per_all_people_f            PER,
  ota_events                  EVT,
  per_all_assignments_f       ass,
  per_jobs                    job,
  per_contracts_f             con
where comp.organization_id        = :p_company_id
  and comp.date_from             <= :p_year_end
  and (comp.date_to              is null or
       comp.date_to              >= :p_year_start) '
  ||L_WHERE_TP_ORG||'
  and org.organization_id         = tp_org_info.organization_id
  and org.date_from              <= :p_year_end
  and (org.date_to               is null or
       org.date_to               >= :p_year_start)
  and org.organization_id         = TP.organization_id
/*and TP.plan_status_type_id     <> ''CANCELLED''*/
  and TP.time_period_id           = PTP.time_period_id
  and PTP.period_type             = ''Year''
  and PTP.start_date              = :p_year_start
  and TP.training_plan_id         = TPC.training_plan_id
  and TPC.tp_measurement_type_id  = TMT.tp_measurement_type_id
  and TMT.business_group_id       = org.business_group_id
  and TPC.tp_measurement_type_id IN (:ACTUAL_HOURS,
                                     :SKILLS_ASSESSMENT,
                                     :VAE)
  AND TPC.booking_id              = ODB.booking_id
  and ODB.delegate_person_id      = PER.person_id
  and :p_comp_end           between PER.effective_start_date
                                AND PER.effective_end_date
  AND ODB.event_id                = EVT.event_id
  AND ass.person_id               = per.person_id
  AND ass.primary_flag            = ''Y''
  and evt.course_end_date   between ass.effective_start_date
                                and ass.effective_end_date
  AND ass.job_id                  = job.job_id
  AND job.job_information_category= ''FR'' '||L_WHERE_INNER1||'
  AND con.contract_id             = ass.contract_id
  AND evt.course_end_date   BETWEEN con.effective_start_date
                                AND con.effective_end_date
  AND con.type               NOT IN (''APPRENTICESHIP'',
                                     ''ADAPTATION'',
                                     ''QUALIFICATION'',
                                     ''PROFESSIONALISATION'')
UNION ALL
SELECT /* DIF balance */'||L_SELECT_INNER1||
     'to_number(NULL)                                                      mcnt
     ,to_number(NULL)                                                      fcnt
     ,to_number(NULL)                                                   mtrn_id
     ,to_number(NULL)                                                   ftrn_id
     ,to_number(NULL)                                                   trn_hrs
     ,to_number(NULL)                                                dif_trn_id
     ,to_number(NULL)                                                   dif_hrs
     ,otfr2483.get_dif_balance(ass.assignment_id,
                               acc.accrual_plan_id,
                               ass.payroll_id,
                               comp.business_group_id,
                               :p_comp_end)                             dif_bal
FROM hr_all_organization_units      comp,
     hr_organization_information    estab_info,
     hr_all_organization_units      estab,
     per_all_assignments_f          ass,
     per_jobs                       job,
     pay_element_entries_f          ent,
     pay_accrual_plans              acc,
     pay_input_values_f             piv,
     pay_sub_classification_rules_f sub_class,
     per_all_people_f               per
WHERE comp.organization_id               = :p_company_id
  AND comp.date_from                    <= :p_year_end
  AND (comp.date_to                     IS NULL OR
       comp.date_to                     >= :p_year_start)
  AND estab_info.org_information1        = to_char(comp.organization_id)
  AND estab_info.org_information_context = ''FR_ESTAB_INFO''
  AND estab.organization_id              = estab_info.organization_id
  AND estab.date_from                   <= :p_year_end
  AND (estab.date_to                    IS NULL OR
       estab.date_to                    >= :p_year_start)
  AND estab.organization_id              = ass.establishment_id
  AND ass.primary_flag                   = ''Y''
  AND :p_comp_end                  BETWEEN ass.effective_start_date
                                       AND ass.effective_end_date
  AND ass.job_id                         = job.job_id
  AND job.job_information_category       = ''FR'' '||L_WHERE_INNER1||'
  AND ass.assignment_id                  = ent.assignment_id
  and :p_comp_end                  BETWEEN ent.effective_start_date
                                       AND ent.effective_end_date
  and ent.element_type_id                = acc.accrual_plan_element_type_id
  AND acc.business_group_id              = comp.business_group_id
  AND piv.input_value_id                 = acc.pto_input_value_id
  and :p_comp_end                  BETWEEN piv.effective_start_date
                                       AND piv.effective_end_date
  AND sub_class.element_type_id          = piv.element_type_id
  AND :p_comp_end                  BETWEEN sub_class.effective_start_date
                                       AND sub_class.effective_end_date
  AND sub_class.classification_id       IN (:dif_inf_sub_cls,
                                            :dif_abs_sub_cls)
  AND ass.person_id                      = per.person_id
  AND :p_comp_end                  BETWEEN per.effective_start_date
                                       AND per.effective_end_date'||L_ORDER_BY;
    --
    -- trace_sql(l_sql);
    if p_detail_section = 'NA' then
      OPEN l_ref_csr for l_sql using
        /* a and b */
         p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
        ,l_header_rec.date2,l_header_rec.date2
        ,l_header_rec.date2,l_header_rec.date2
        /* c, d, e, f, and g absences */
        ,p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
        ,l_header_rec.date2,l_header_rec.date1
        ,l_header_rec.date2,l_header_rec.date1,l_header_rec.date2
        ,l_classification_rec.inf_pri_cls_id
        ,l_classification_rec.dif_inf_sub_cls_id
        ,l_classification_rec.abs_pri_cls_id
        ,l_classification_rec.dif_abs_sub_cls_id
        /* c, d, and e OTA costs */
        ,p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
        ,l_year_start,l_meas_types_rec.ACTUAL_HOURS
        ,l_meas_types_rec.SKILLS_ASSESSMENT,l_meas_types_rec.VAE
        ,l_header_rec.date2
        /* DIF balance */
        ,l_header_rec.date2
        ,p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
        ,l_header_rec.date2,l_header_rec.date2
        ,l_header_rec.date2,l_header_rec.date2
        ,l_classification_rec.dif_inf_sub_cls_id
        ,l_classification_rec.dif_abs_sub_cls_id
        ,l_header_rec.date2;
      fetch l_ref_csr into l_b11,l_b12,l_b13,l_b14,l_b15,l_b16,l_b17,l_b18,
                           l_b21,l_b22,l_b23,l_b24,l_b25,l_b26,l_b27,l_b28,
                           l_b31,l_b32,l_b33,l_b34,l_b35,l_b36,l_b37,l_b38,
                           l_b41,l_b42,l_b43,l_b44,l_b45,l_b46,l_b47,l_b48;
      --  Assemble pdf XML...
      load_xml(p_xml,'b11',l_b11);
      load_xml(p_xml,'b12',l_b12);
      load_xml(p_xml,'b13',l_b13);
      load_xml(p_xml,'b14',l_b14);
      load_xml(p_xml,'b15',l_b15);
      load_xml(p_xml,'b16',l_b16);
      load_xml(p_xml,'b17',l_b17);
      load_xml(p_xml,'b18',l_b18);
      load_xml(p_xml,'b21',l_b21);
      load_xml(p_xml,'b22',l_b22);
      load_xml(p_xml,'b23',l_b23);
      load_xml(p_xml,'b24',l_b24);
      load_xml(p_xml,'b25',l_b25);
      load_xml(p_xml,'b26',l_b26);
      load_xml(p_xml,'b27',l_b27);
      load_xml(p_xml,'b28',l_b28);
      load_xml(p_xml,'b31',l_b31);
      load_xml(p_xml,'b32',l_b32);
      load_xml(p_xml,'b33',l_b33);
      load_xml(p_xml,'b34',l_b34);
      load_xml(p_xml,'b35',l_b35);
      load_xml(p_xml,'b36',l_b36);
      load_xml(p_xml,'b37',l_b37);
      load_xml(p_xml,'b38',l_b38);
      load_xml(p_xml,'b41',l_b41);
      load_xml(p_xml,'b42',l_b42);
      load_xml(p_xml,'b43',l_b43);
      load_xml(p_xml,'b44',l_b44);
      load_xml(p_xml,'b45',l_b45);
      load_xml(p_xml,'b46',l_b46);
      load_xml(p_xml,'b47',l_b47);
      load_xml(p_xml,'b48',l_b48);
      load_xml(p_xml,'zca',l_b11+l_b21+l_b31+l_b41);
      load_xml(p_xml,'zcb',l_b12+l_b22+l_b32+l_b42);
      load_xml(p_xml,'zcc',l_b13+l_b23+l_b33+l_b43);
      load_xml(p_xml,'zcd',l_b14+l_b24+l_b34+l_b44);
      load_xml(p_xml,'zce',l_b15+l_b25+l_b35+l_b45);
      load_xml(p_xml,'zcf',l_b16+l_b26+l_b36+l_b46);
      load_xml(p_xml,'zcg',l_b17+l_b27+l_b37+l_b47);
      load_xml(p_xml,'zch',l_b18+l_b28+l_b38+l_b48);
    else -- debug
      l_b11  := 0;
      l_b12  := 0;
      l_b13  := 0;
      l_b14  := 0;
      l_b15  := 0;
      l_b16  := 0;
      l_b17  := 0;
      l_b18  := 0;
      if p_detail_section = 'B2' then
        L_WHERE_INNER1 := '6';
      elsif p_detail_section = 'B3' then
        L_WHERE_INNER1 := '5';
      elsif p_detail_section = 'B4' then
        L_WHERE_INNER1 := '4';
      else -- p_detail_section = 'B5'
        L_WHERE_INNER1 := '3';
      end if;
      OPEN l_ref_csr for l_sql using
        /* a and b */
         p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
        ,l_header_rec.date2,L_WHERE_INNER1,l_header_rec.date2
        ,l_header_rec.date2,l_header_rec.date2
        /* c, d, e, f, and g absences */
        ,p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
        ,l_header_rec.date2,l_header_rec.date1,L_WHERE_INNER1
        ,l_header_rec.date2,l_header_rec.date1,l_header_rec.date2
        ,l_classification_rec.inf_pri_cls_id
        ,l_classification_rec.dif_inf_sub_cls_id
        ,l_classification_rec.abs_pri_cls_id
        ,l_classification_rec.dif_abs_sub_cls_id
        /* c, d, and e OTA costs */
        ,p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
        ,l_year_start,l_meas_types_rec.ACTUAL_HOURS
        ,l_meas_types_rec.SKILLS_ASSESSMENT,l_meas_types_rec.VAE
        ,l_header_rec.date2,L_WHERE_INNER1
        /* h (DIF balance) */
        ,l_header_rec.date2
        ,p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
        ,l_header_rec.date2,L_WHERE_INNER1,l_header_rec.date2
        ,l_header_rec.date2,l_header_rec.date2
        ,l_classification_rec.dif_inf_sub_cls_id
        ,l_classification_rec.dif_abs_sub_cls_id
        ,l_header_rec.date2;
      --  Assemble rtf XML...
      load_xml(p_xml,'SECTION_B2_5',c_OpenGrpTag);
      /* Bulk fetches from dynamic cursors not supported in 8.1.7 */
      loop
        fetch l_ref_csr into l_curr_rec.full_name, l_curr_rec.order_name,
          l_curr_rec.emp_num, l_curr_rec.num1, l_curr_rec.num2,
          l_curr_rec.num3, l_curr_rec.num4, l_curr_rec.num5, l_curr_rec.num6,
          l_curr_rec.num7, l_curr_rec.num8;
        if  l_ref_csr%NOTFOUND and l_ref_csr%ROWCOUNT > 0 then
          -- Close emp_list
            load_xml(p_xml,'EMP_LIST',c_CloseGrpTag);
        end if;
        exit when l_ref_csr%NOTFOUND;
        if  l_ref_csr%ROWCOUNT = 1 then
          -- Open emp_list
            load_xml(p_xml,'EMP_LIST',c_OpenGrpTag);
        end if;
        -- Load emp row
        load_xml(p_xml,'EMP',c_OpenGrpTag);
        load_xml(p_xml,'FULL_NAME',      l_curr_rec.full_name);
        load_xml(p_xml,'EMPLOYEE_NUMBER',l_curr_rec.emp_num);
        load_xml(p_xml,'MCNT',           l_curr_rec.num1);
        load_xml(p_xml,'FCNT',           l_curr_rec.num2);
        load_xml(p_xml,'MTRN',           l_curr_rec.num3);
        load_xml(p_xml,'FTRN',           l_curr_rec.num4);
        load_xml(p_xml,'TRN_HRS',        l_curr_rec.num5);
        load_xml(p_xml,'DIF_TRN',        l_curr_rec.num6);
        load_xml(p_xml,'DIF_HRS',        l_curr_rec.num7);
        load_xml(p_xml,'DIF_BAL',        l_curr_rec.num8);
        load_xml(p_xml,'EMP',c_CloseGrpTag);
        --
        l_b11 := l_b11 + nvl(l_curr_rec.num1,0);
        l_b12 := l_b12 + nvl(l_curr_rec.num2,0);
        l_b13 := l_b13 + l_curr_rec.num3;
        l_b14 := l_b14 + l_curr_rec.num4;
        l_b15 := l_b15 + nvl(l_curr_rec.num5,0);
        l_b16 := l_b16 + l_curr_rec.num6;
        l_b17 := l_b17 + nvl(l_curr_rec.num7,0);
        l_b18 := l_b18 + nvl(l_curr_rec.num8,0);
      end loop;
      load_xml(p_xml,'bn1',l_b11);
      load_xml(p_xml,'bn2',l_b12);
      load_xml(p_xml,'bn3',l_b13);
      load_xml(p_xml,'bn4',l_b14);
      load_xml(p_xml,'bn5',l_b15);
      load_xml(p_xml,'bn6',l_b16);
      load_xml(p_xml,'bn7',l_b17);
      load_xml(p_xml,'bn8',l_b18);
      load_xml(p_xml,'SECTION_B2_5',c_CloseGrpTag);
    end if; -- debug fetch
    close l_ref_csr;
  end if; -- Section B2-5
  --
  if p_detail_section in ('B7_8','NA') then
    if p_detail_section = 'NA' then
      hr_utility.trace('Section B7 and 8 PDF');
      L_SELECT_OUTER := 'select
   count(distinct per.person_id)                                             c1
  ,round(nvl(sum(pabs.absence_hours),0))                                     c2
';
      L_ORDER_BY     := null;
      L_SELECT_INNER1:= null;
    else -- debug
      hr_utility.trace('Section B7 and 8 RTF');
      L_SELECT_OUTER := null;
      L_SELECT_INNER1:= 'select
   per.order_name                                                    order_name
  ,per.full_name                                                      full_name
  ,per.employee_number                                          employee_number
  ,pabs.date_start                                                    abs_start
  ,pabs.date_end                                                        abs_end
  ,nvl(pabs.absence_hours,0)                                            abs_hrs
';
      L_ORDER_BY     := '
ORDER BY 1,3,4,5 desc';
    end if; -- debug or PDF
    l_sql := L_SELECT_OUTER||L_SELECT_INNER1||'FROM
     hr_all_organization_units    comp,
     hr_organization_information  estab_info,
     hr_all_organization_units    estab,
     per_all_assignments_f        ass,
     per_all_people_f             per,
     per_absence_attendances      pabs,
     per_absence_attendance_types pabt
WHERE comp.organization_id               = :p_company_id
  AND comp.date_from                    <= :p_year_end
  AND (comp.date_to                     IS NULL OR
       comp.date_to                     >= :p_year_start)
  AND estab_info.org_information1        = to_char(comp.organization_id)
  AND estab_info.org_information_context = ''FR_ESTAB_INFO''
  AND estab.organization_id              = estab_info.organization_id
  AND estab.date_from                   <= :p_year_end
  AND (estab.date_to                    IS NULL OR
       estab.date_to                    >= :p_year_start)
  AND estab.organization_id              = ass.establishment_id
  AND ass.primary_flag                   = ''Y''
  /* rough filter on asg dates: */
  and ass.effective_start_date          <= :p_comp_end
  and ass.effective_end_date            >= :p_comp_start
  AND ass.person_id                      = per.person_id
  AND :p_comp_end                  BETWEEN per.effective_start_date
                                       AND per.effective_end_date
  AND per.person_id                      = pabs.person_id
  AND pabs.abs_information_category      = ''FR_TRAINING_ABSENCE''
  AND nvl(pabs.date_end,pabs.date_start) BETWEEN ass.effective_start_date
                                             AND ass.effective_end_date
  AND pabs.date_start                   <= :p_comp_end
  AND (pabs.date_end                    IS NULL OR
       pabs.date_end                    >= :p_comp_start)
  AND pabs.abs_information1              = ''PP''
  AND pabs.absence_attendance_type_id    = pabt.absence_attendance_type_id
  AND pabt.absence_category              = ''TRAINING_ABSENCE'' '||L_ORDER_BY;
    --
    --trace_sql(l_sql);
    l_c1 := 0;
    l_c2 := 0;
    OPEN l_ref_csr for l_sql using
         p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
        ,l_header_rec.date2,l_header_rec.date1,l_header_rec.date2
        ,l_header_rec.date2,l_header_rec.date1;
    if p_detail_section = 'NA' then
      fetch l_ref_csr into l_c1, l_c2;
      --  Assemble pdf XML...
      load_xml(p_xml,'c1',l_c1);
      load_xml(p_xml,'c2',l_c2);
    else -- debug
      /* Bulk fetches from dynamic cursors not supported in 8.1.7 */
      l_prev_rec := l_empt_rec;
      --  Assemble rtf XML...
      load_xml(p_xml,'SECTION_B7_8',c_OpenGrpTag);
      loop
        FETCH l_ref_csr INTO l_curr_rec.order_name, l_curr_rec.full_name,
          l_curr_rec.emp_num, l_curr_rec.trn_start,
          l_curr_rec.trn_end, l_curr_rec.num1;
        if  (l_ref_csr%NOTFOUND
             or l_prev_rec.full_name <> l_curr_rec.full_name
             or l_prev_rec.emp_num   <> l_curr_rec.emp_num)
        and l_ref_csr%ROWCOUNT > 0
        then
          -- Close previous emp
            load_xml(p_xml,'EMP',c_CloseGrpTag);
            l_c1 := l_c1 + 1;
        end if;
        exit when l_ref_csr%NOTFOUND;
        if nvl(l_prev_rec.full_name,' ') <> l_curr_rec.full_name
        or nvl(l_prev_rec.emp_num,' ')   <> l_curr_rec.emp_num
        then
          -- Open new EMP
          load_xml(p_xml,'EMP',c_OpenGrpTag);
          load_xml(p_xml,'FULL_NAME',l_curr_rec.full_name);
          load_xml(p_xml,'EMPLOYEE_NUMBER',l_curr_rec.emp_num);
        end if;
        load_xml(p_xml,'ABS',c_OpenGrpTag);
        load_xml(p_xml,'ABS_START',l_curr_rec.trn_start);
        load_xml(p_xml,'ABS_END',l_curr_rec.trn_end);
        load_xml(p_xml,'ABS_HRS',l_curr_rec.num1);
        load_xml(p_xml,'ABS',c_CloseGrpTag);
        l_c2 := l_c2 + l_curr_rec.num1;
        l_prev_rec := l_curr_rec;
      end loop;
      load_xml(p_xml,'c1',l_c1);
      load_xml(p_xml,'c2',l_c2);
      load_xml(p_xml,'SECTION_B7_8',c_CloseGrpTag);
    end if; -- debug or pdf
    close l_ref_csr;
  end if; -- B7_8
  --
  if p_detail_section in ('B9_10_FD','NA') then
    if p_detail_section = 'NA' then
      hr_utility.trace('Section B9 and 10 and Fd PDF');
      L_SELECT_OUTER := 'select
   count(distinct person_id)                                                 c3
  ,round(nvl(sum(out_hrs),0))                                                c4
  ,round(nvl(sum(trn_al),0))                                               C121
from (
';
      L_ORDER_BY     := ')';
      L_SELECT_INNER1:= 'select
   per.person_id
  ,fnd_number.canonical_to_number(tp_cost_hrs.tp_cost_information4)     out_hrs
  ,decode(tp_cost.currency_code
         ,''EUR'',tp_cost.amount
         ,hr_currency_pkg.convert_amount_sql(
            tp_cost.currency_code
           ,''EUR''
           ,sysdate
           ,tp_cost.amount
           ,:CURRENCY_RATE_TYPE))                                        trn_al
';

      L_SELECT_INNER2:= 'select
   per.person_id
  ,fnd_number.canonical_to_number(pabs.abs_information20)               out_hrs
  ,decode(bg_info.org_information10
         ,''EUR'',fnd_number.canonical_to_number(pabs.abs_information22)
         ,hr_currency_pkg.convert_amount_sql(
            bg_info.org_information10
           ,''EUR''
           ,sysdate
           ,nvl(fnd_number.canonical_to_number(pabs.abs_information22),0)
           ,:CURRENCY_RATE_TYPE))                                        trn_al
';
    else -- debug
      hr_utility.trace('Section B9 and 10 and Fd RTF');
      L_SELECT_OUTER := null;
      L_SELECT_INNER1:= 'select
   per.order_name                                                    order_name
  ,per.full_name                                                      full_name
  ,per.employee_number                                          employee_number
  ,evt.course_start_date                                              trn_start
  ,evt.course_end_date                                                  trn_end
  ,tp.name                                                                 plan
  ,evt_tl.title                                                           class
  ,hlu_legal.meaning                                                  legal_cat
  ,tp_cost_hrs.amount                                                   act_hrs
  ,nvl(tp_cost_hrs.tp_cost_information4,''0'')                          out_hrs
  ,tp_cost.amount                                                        trn_al
  ,tp_cost.currency_code                                              trn_al_cc
';
      L_SELECT_INNER2:= 'select
   per.order_name                                                    order_name
  ,per.full_name                                                      full_name
  ,per.employee_number                                          employee_number
  ,pabs.date_start                                                    trn_start
  ,pabs.date_end                                                        trn_end
  ,null                                                                    plan
  ,null                                                                   class
  ,hlu_legal.meaning                                                  legal_cat
  ,nvl(pabs.absence_hours,0)                                            act_hrs
  ,nvl(pabs.abs_information20,''0'')                                    out_hrs
  ,fnd_number.canonical_to_number(pabs.abs_information22)                trn_al
  ,bg_info.org_information10                                          trn_al_cc
';
      L_ORDER_BY     := '
ORDER BY 1,3,4,5 desc';
    end if; -- debug or PDF
    l_sql := L_SELECT_OUTER||L_SELECT_INNER1||'FROM
     hr_all_organization_units      comp,
     hr_organization_information    tp_org_info,
     hr_all_organization_units      org,
     ota_training_plans             tp,
     per_time_periods               ptp,
     ota_training_plan_costs        tp_cost,
     ota_training_plan_costs        tp_cost_hrs,
     ota_delegate_bookings          delegate,
     per_all_people_f               per,
     ota_events                     evt,
     ota_events_tl                  evt_tl,
     hr_lookups                     hlu_legal
WHERE comp.organization_id              = :p_company_id
  AND comp.date_from                   <= :p_end_year
  AND (comp.date_to                    IS NULL OR
       comp.date_to                    >= :p_start_year) '
  ||L_WHERE_TP_ORG||'
  AND org.organization_id               = tp_org_info.organization_id
  AND org.date_from                    <= :p_end_year
  AND (org.date_to                     IS NULL OR
       org.date_to                     >= :p_start_year)
  AND tp.organization_id                = org.organization_id
  AND ptp.time_period_id                = tp.time_period_id
  AND ptp.period_type                   = ''Year''
  AND PTP.start_date                    = :p_start_year
  AND tp.training_plan_id               = tp_cost.training_plan_id
  AND tp_cost.tp_measurement_type_id    = :DEDUCTIBLE_TRN_ALLOWANCE
  AND tp_cost.training_plan_id          = tp_cost_hrs.training_plan_id
  AND tp_cost_hrs.booking_id            = tp_cost.booking_id
  AND tp_cost_hrs.tp_measurement_type_id= :ACTUAL_HOURS
  AND tp_cost.booking_id                = delegate.booking_id
  AND delegate.delegate_person_id       = per.person_id
  AND :p_end_comp                 BETWEEN PER.effective_start_date
                                      AND PER.effective_end_date
  AND delegate.event_id                 = evt.event_id
  and EVT_tl.event_id                   = EVT.event_id
  and EVT_tl.language                   = userenv(''LANG'')
  AND hlu_legal.lookup_type(+)          = ''FR_LEGAL_TRG_CATG''
  AND hlu_legal.lookup_code(+)          = tp_cost_hrs.tp_cost_information3
UNION ALL
'||L_SELECT_INNER2||'FROM
     hr_all_organization_units    COMP,
     hr_organization_information  estab_info,
     hr_all_organization_units    estab,
     per_all_assignments_f        ass,
     per_all_people_f             per,
     per_absence_attendances      pabs,
     per_absence_attendance_types pabt,
     hr_lookups                   hlu_legal,
     hr_organization_information  bg_info
WHERE comp.organization_id               = :p_company_id
  AND comp.date_from                    <= :p_year_end
  AND (comp.date_to                     IS NULL OR
       comp.date_to                     >= :p_year_start)
  AND estab_info.org_information1        = to_char(comp.organization_id)
  AND estab_info.org_information_context = ''FR_ESTAB_INFO''
  AND estab.organization_id              = estab_info.organization_id
  AND estab.date_from                   <= :p_year_end
  AND (estab.date_to                    IS NULL OR
       estab.date_to                    >= :p_year_start)
  AND estab.organization_id              = ass.establishment_id
  AND ass.primary_flag                   = ''Y''
  /* rough filter on asg dates: */
  and ass.effective_start_date          <= :p_comp_end
  and ass.effective_end_date            >= :p_comp_start
  AND ass.person_id                      = per.person_id
  AND :p_comp_end                  BETWEEN per.effective_start_date
                                       AND per.effective_end_date
  AND per.person_id                      = pabs.person_id
  AND pabs.abs_information_category      = ''FR_TRAINING_ABSENCE''
  AND pabs.date_end                BETWEEN ass.effective_start_date
                                       AND ass.effective_end_date
  AND pabs.date_end                BETWEEN :p_comp_start
                                       AND :p_comp_end
  /*Not Within Training Plan */
  AND pabs.abs_information18             = ''N''/* nullable */
  AND pabs.abs_information22            <> ''0''
  AND pabs.absence_attendance_type_id    = pabt.absence_attendance_type_id
  AND pabt.absence_category              = ''TRAINING_ABSENCE''
  AND hlu_legal.lookup_code(+)           = pabs.abs_information19 /*NULLABLE*/
  AND hlu_legal.lookup_type(+)           = ''FR_LEGAL_TRG_CATG''
  AND bg_info.organization_id            = comp.business_group_id
  and bg_info.org_information_context    = ''Business Group Information'' '||
  L_ORDER_BY;
    --
    --trace_sql(l_sql);
    l_c3 := 0;
    l_c4 := 0;
    l_C121 := 0;
    if p_detail_section = 'NA' then
      OPEN l_ref_csr for l_sql using l_currency_rate_type
          ,p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
          ,l_year_start,l_meas_types_rec.DEDUCTIBLE_TRN_ALLOWANCE
          ,l_meas_types_rec.ACTUAL_HOURS,l_header_rec.date2
          ,l_currency_rate_type
          ,p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
          ,l_header_rec.date2,l_header_rec.date1,l_header_rec.date2
          ,l_header_rec.date1,l_header_rec.date2;
      fetch l_ref_csr into l_c3, l_c4, l_C121;
      --  Assemble pdf XML...
      load_xml(p_xml,'c3',l_c3);
      load_xml(p_xml,'c4',l_c4);
      close l_ref_csr;
    else -- debug
      l_currency_rate_type := hr_currency_pkg.get_rate_type(l_header_rec.bg_id
                                                           ,sysdate,'R');
      --
      OPEN l_ref_csr for l_sql using
           p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
          ,l_year_start,l_meas_types_rec.DEDUCTIBLE_TRN_ALLOWANCE
          ,l_meas_types_rec.ACTUAL_HOURS,l_header_rec.date2
          ,p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
          ,l_header_rec.date2,l_header_rec.date1,l_header_rec.date2
          ,l_header_rec.date1,l_header_rec.date2;
      /* Bulk fetches from dynamic cursors not supported in 8.1.7 */
      l_tot_act_hrs := 0;
      l_prev_rec := l_empt_rec;
      --  Assemble rtf XML...
      load_xml(p_xml,'SECTION_B9_10_Fd',c_OpenGrpTag);
      loop
        FETCH l_ref_csr INTO l_curr_rec.order_name, l_curr_rec.full_name,
          l_curr_rec.emp_num, l_curr_rec.trn_start,
          l_curr_rec.trn_end, l_curr_rec.plan_name, l_curr_rec.class_name,
          l_curr_rec.legal_cat,l_curr_rec.num1,l_curr_rec.out_hrs_chr,
          l_curr_rec.num2,l_curr_rec.chr1;
        if  (l_ref_csr%NOTFOUND
             or l_prev_rec.full_name <> l_curr_rec.full_name
             or l_prev_rec.emp_num   <> l_curr_rec.emp_num)
        and l_ref_csr%ROWCOUNT > 0
        then
          -- Close previous emp
            load_xml(p_xml,'EMP',c_CloseGrpTag);
            l_c3 := l_c3 + 1;
        end if;
        exit when l_ref_csr%NOTFOUND;
        if nvl(l_prev_rec.full_name,' ') <> l_curr_rec.full_name
        or nvl(l_prev_rec.emp_num,' ')   <> l_curr_rec.emp_num
        then
          -- Open new EMP
          load_xml(p_xml,'EMP',c_OpenGrpTag);
          load_xml(p_xml,'FULL_NAME',l_curr_rec.full_name);
          load_xml(p_xml,'EMPLOYEE_NUMBER',l_curr_rec.emp_num);
        end if;
        load_xml(p_xml,'TRAINING',c_OpenGrpTag);
        load_xml(p_xml,'TRN_START',l_curr_rec.trn_start);
        load_xml(p_xml,'TRN_END',l_curr_rec.trn_end);
        load_xml(p_xml,'PLAN',l_curr_rec.plan_name);
        load_xml(p_xml,'CLASS',l_curr_rec.class_name);
        load_xml(p_xml,'LEGAL_CAT',l_curr_rec.legal_cat);
        load_xml(p_xml,'ACT_HRS',l_curr_rec.num1);
        load_xml(p_xml,'OUT_HRS',l_curr_rec.out_hrs_chr);
        if l_curr_rec.chr1 = 'EUR' then
          -- no need to convert currency
          load_xml(p_xml,'TRN_AL',l_curr_rec.num2);
        else
          load_xml(p_xml,'TRN_AL'
                  ,hr_currency_pkg.convert_amount(
                      l_curr_rec.chr1
                     ,'EUR'
                     ,sysdate
                     ,l_curr_rec.num2
                     ,l_currency_rate_type));
        end if;
        load_xml(p_xml,'TRAINING',c_CloseGrpTag);
        l_tot_act_hrs := l_tot_act_hrs + l_curr_rec.num1;
        l_c4 := l_c4 + fnd_number.canonical_to_number(l_curr_rec.out_hrs_chr);
        l_C121 := l_C121 + l_curr_rec.num2;
        l_prev_rec := l_curr_rec;
      end loop;
      load_xml(p_xml,'c3',l_c3);
      load_xml(p_xml,'TOT_ACT',l_tot_act_hrs);
      load_xml(p_xml,'c4',l_c4);
      load_xml(p_xml,'C121',l_C121);
      load_xml(p_xml,'SECTION_B9_10_Fd',c_CloseGrpTag);
      close l_ref_csr;
    end if; -- debug or pdf
  end if; -- Section B9 and 10 and Fd
  --
  if p_detail_section in ('B11','B12','NA') then
    if p_detail_section = 'NA' then
      hr_utility.trace('Section B11 and 12 PDF');
      L_SELECT_OUTER := 'select
  round(nvl(sum(decode(trn_type,''SA'', num_courses)),0)) c5,
  round(nvl(sum(decode(trn_type,''VAE'',num_courses)),0)) c6
from (
';
      L_ORDER_BY     := ')';
      L_SELECT_INNER1:= 'select
  decode(meas_type.tp_measurement_code,
         ''FR_DEDUCT_EXT_TRN_PLAN_VAE'',''VAE'',
         ''FR_DEDUCT_EXT_TRN_PLAN_SA'', ''SA'',
         ''FR_SKILLS_ASSESSMENT'',      ''SA'',
         ''FR_VAE'',                    ''VAE'')                       trn_type
 ,decode(tp_cost.booking_id,
         NULL,fnd_number.canonical_to_number(tp_cost.tp_cost_information1),
         1)                                                     num_courses
';
      L_SELECT_INNER2:= 'select
  decode(pabs.abs_information1,
         ''SKILLS_ASSESSMENT'',''SA'',
         ''VAE'',''VAE'')                                              trn_type
 ,1                                                             num_courses
';
    else -- p_detail_section in ('B11','B12')
      hr_utility.trace('Section '||p_detail_section||' RTF');
      L_SELECT_OUTER := null;
      L_SELECT_INNER1:= 'select
       per.order_name                                                order_name
      ,per.full_name                                                  full_name
      ,per.employee_number                                      employee_number
      ,event.course_start_date                                        trn_start
      ,event.course_end_date                                            trn_end
      ,tp.name                                                             plan
      ,event_tl.title                                                     class
      ,decode(tp_cost.booking_id
             ,NULL,fnd_number.canonical_to_number(tp_cost.tp_cost_information1)
             ,1)                                                    num_courses
';
      L_SELECT_INNER2:= 'select
       per.order_name                                                order_name
      ,per.full_name                                                  full_name
      ,per.employee_number                                      employee_number
      ,pabs.date_start                                                trn_start
      ,pabs.date_end                                                    trn_end
      ,null                                                                plan
      ,null                                                               class
      ,1                                                            num_courses
';
      L_ORDER_BY     := '
ORDER BY 1, 3, 4, 5 DESC, 6, 7';
      --
    end if; -- p_detail_section = 'NA'
    l_sql := L_SELECT_OUTER||L_SELECT_INNER1||'FROM
      hr_all_organization_units      comp,
      hr_organization_information    tp_org_info,
      hr_all_organization_units      org,
      ota_training_plans             tp,
      per_time_periods               ptp,
      ota_training_plan_costs        tp_cost,
      ota_tp_measurement_types       meas_type,
      ota_delegate_bookings          delegate,
      ota_events                     event,
      ota_events_tl                  event_tl,
      per_all_people_f               per
WHERE comp.organization_id              = :p_company_id
  AND comp.date_from                   <= :p_end_year
  AND (comp.date_to                    IS NULL OR
       comp.date_to                    >= :p_start_year) '
  ||L_WHERE_TP_ORG||'
  AND org.organization_id               = tp_org_info.organization_id
  AND org.date_from                    <= :p_end_year
  AND (org.date_to                     IS NULL OR
       org.date_to                     >= :p_start_year)
  AND tp.organization_id                = org.organization_id
  AND ptp.time_period_id                = tp.time_period_id
  AND ptp.period_type                   = ''Year''
  AND ptp.start_date                    = :p_start_year
  AND tp.training_plan_id               = tp_cost.training_plan_id
  AND ((tp_cost.tp_measurement_type_id IN (:FR_SKILLS_ASSESSMENT,:FR_VAE) AND
        meas_type.cost_level            = ''DELEGATE'' AND
        tp_cost.tp_cost_information1    = ''EMPLOYER'') OR
       (tp_cost.tp_measurement_type_id IN (:FR_DEDUCTIBLE_EXT_TRN_PLAN_SA,
                                           :FR_DEDUCTIBLE_EXT_TRN_PLAN_VAE) AND
        meas_type.cost_level            = ''PLAN'' AND
        tp_cost.tp_cost_information1   <> ''0''))
  AND tp_cost.tp_measurement_type_id    = meas_type.tp_measurement_type_id
  AND meas_type.unit                    = ''M''
  AND tp_cost.information_category      =''FR_''||meas_type.tp_measurement_code
  AND tp_cost.booking_id                = delegate.booking_id(+)
  AND delegate.delegate_person_id       = per.person_id(+)
  AND :p_comp_end                 BETWEEN per.effective_start_date(+)
                                      AND per.effective_end_date(+)
  AND delegate.event_id                 = event.event_id(+)
  AND event_tl.event_id(+)              = event.event_id
  AND event_tl.language(+)              = userenv (''LANG'')
UNION ALL
'||L_SELECT_INNER2||'FROM
     hr_all_organization_units    COMP,
     hr_organization_information  estab_info,
     hr_all_organization_units    estab,
     per_all_assignments_f        ass,
     per_all_people_f             per,
     per_absence_attendances      pabs,
     per_absence_attendance_types pabt
WHERE comp.organization_id               = :p_company_id
  AND comp.date_from                    <= :p_year_end
  AND (comp.date_to                     IS NULL OR
       comp.date_to                     >= :p_year_start)
  AND estab_info.org_information_context = ''FR_ESTAB_INFO''
  AND estab_info.org_information1        = to_char(comp.organization_id)
  AND estab.organization_id              = estab_info.organization_id
  AND estab.date_from                   <= :p_year_end
  AND (estab.date_to                    IS NULL OR
       estab.date_to                    >= :p_year_start)
  AND estab.organization_id              = ass.establishment_id
  AND ass.primary_flag                   = ''Y''
  /* rough filter on asg dates: */
  and ass.effective_start_date          <= :p_comp_end
  and ass.effective_end_date            >= :p_comp_start
  AND ass.person_id                      = per.person_id
  AND :p_comp_end                  BETWEEN per.effective_start_date
                                       AND per.effective_end_date
  AND per.person_id                      = pabs.person_id
  AND pabs.abs_information_category      = ''FR_TRAINING_ABSENCE''
  AND pabs.date_end                BETWEEN ass.effective_start_date
                                       AND ass.effective_end_date
  AND pabs.date_end                BETWEEN :p_comp_start
                                       AND :p_comp_end
  /*Not Within Training Plan */
  AND pabs.abs_information18             = ''N''/* nullable */
  /* include some training categories */
  AND pabs.abs_information1             IN (:SKILLS_ASSESSMENT,:VAE)
  /*and pabs.abs_information3              = ota_pv.vendor_id  Training provider*/
  AND pabs.abs_information5              = ''EMPLOYER'' /* Subsidized type */
  AND pabs.absence_attendance_type_id    = pabt.absence_attendance_type_id
  AND pabt.absence_category              = ''TRAINING_ABSENCE'''||L_ORDER_BY;
    --
    --trace_sql(l_sql);
    l_c5 := 0;
    l_c6 := 0;
    if p_detail_section = 'NA' then
      OPEN l_ref_csr for l_sql using
         p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
        ,l_year_start,l_meas_types_rec.SKILLS_ASSESSMENT,l_meas_types_rec.VAE
        ,l_meas_types_rec.DEDUCTIBLE_EXT_TRN_PLAN_SA
        ,l_meas_types_rec.DEDUCTIBLE_EXT_TRN_PLAN_VAE,l_header_rec.date2
        ,p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
        ,l_header_rec.date2,l_header_rec.date1,l_header_rec.date2
        ,l_header_rec.date1,l_header_rec.date2
        ,'SKILLS_ASSESSMENT','VAE';
      fetch l_ref_csr into l_c5, l_c6;
      --  Assemble pdf XML...
      load_xml(p_xml,'c5',l_c5);
      load_xml(p_xml,'c6',l_c6);
    else -- debug
      if p_detail_section = 'B11' then
        OPEN l_ref_csr for l_sql using
           p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
          ,l_year_start,l_meas_types_rec.SKILLS_ASSESSMENT
          ,l_meas_types_rec.SKILLS_ASSESSMENT
          ,l_meas_types_rec.DEDUCTIBLE_EXT_TRN_PLAN_SA
          ,l_meas_types_rec.DEDUCTIBLE_EXT_TRN_PLAN_SA,l_header_rec.date2
          ,p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
          ,l_header_rec.date2,l_header_rec.date1
          ,l_header_rec.date2,l_header_rec.date1,l_header_rec.date2
          ,'SKILLS_ASSESSMENT','SKILLS_ASSESSMENT';
      else -- p_detail_section = 'B12'
        OPEN l_ref_csr for l_sql using
           p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
          ,l_year_start,l_meas_types_rec.VAE,l_meas_types_rec.VAE
          ,l_meas_types_rec.DEDUCTIBLE_EXT_TRN_PLAN_VAE
          ,l_meas_types_rec.DEDUCTIBLE_EXT_TRN_PLAN_VAE,l_header_rec.date2
          ,p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
          ,l_header_rec.date2,l_header_rec.date1
          ,l_header_rec.date2,l_header_rec.date1,l_header_rec.date2
          ,'VAE','VAE';
      end if; -- p_detail_section = 'B11'
      /* Bulk fetches from dynamic cursors not supported in 8.1.7 */
      l_prev_rec := l_empt_rec;
      --  Assemble rtf XML...
      load_xml(p_xml,'SECTION_'||p_detail_section,c_OpenGrpTag);
      loop
        FETCH l_ref_csr INTO l_curr_rec.order_name, l_curr_rec.full_name,
          l_curr_rec.emp_num, l_curr_rec.trn_start,
          l_curr_rec.trn_end, l_curr_rec.plan_name, l_curr_rec.class_name,
          l_curr_rec.num1;
        if  (l_ref_csr%NOTFOUND
             or (l_curr_rec.full_name is null and
                 l_prev_rec.full_name is not null))
        and l_ref_csr%ROWCOUNT > 0
        then
          if l_prev_rec.full_name is null then
            -- close previous PLAN_LIST
            load_xml(p_xml,'PLAN_LIST',c_CloseGrpTag);
          else
            -- Close previous EMP_LIST
            load_xml(p_xml,'EMP_LIST',c_CloseGrpTag);
          end if;
        end if;
        exit when l_ref_csr%NOTFOUND;
        if l_curr_rec.full_name is not null then
          if l_ref_csr%ROWCOUNT = 1 then
            -- open EMP_LIST
            load_xml(p_xml,'EMP_LIST',c_OpenGrpTag);
          end if;
          -- write EMP row
          load_xml(p_xml,'EMP',c_OpenGrpTag);
          load_xml(p_xml,'FULL_NAME',l_curr_rec.full_name);
          load_xml(p_xml,'EMPLOYEE_NUMBER',l_curr_rec.emp_num);
          load_xml(p_xml,'TRN_START',l_curr_rec.trn_start);
          load_xml(p_xml,'TRN_END',l_curr_rec.trn_end);
          load_xml(p_xml,'PLAN',l_curr_rec.plan_name);
          load_xml(p_xml,'CLASS',l_curr_rec.class_name);
          load_xml(p_xml,'EMP',c_CloseGrpTag);
        else -- PLAN row
          if l_prev_rec.full_name is not null
          or l_ref_csr%ROWCOUNT = 1 then
            -- open PLAN_LIST
            load_xml(p_xml,'PLAN_LIST',c_OpenGrpTag);
          end if; -- first PLAN
          -- write PLAN row
          load_xml(p_xml,'PLAN',c_OpenGrpTag);
          load_xml(p_xml,'PLAN_NAME',l_curr_rec.plan_name);
          load_xml(p_xml,'NUM_COURSES',l_curr_rec.num1);
          load_xml(p_xml,'PLAN',c_CloseGrpTag);
        end if;
        l_c5 := l_c5 + l_curr_rec.num1;
        l_prev_rec := l_curr_rec;
      end loop;
      load_xml(p_xml,'c5',l_c5);
      load_xml(p_xml,'SECTION_'||p_detail_section,c_CloseGrpTag);
    end if; -- p_detail_section = 'NA'
    close l_ref_csr;
  end if; -- p_detail_section in ('B11','B12','NA')
  --
  if p_detail_section = 'NA' then
    -- write XML for report date in pdf Declaration section
    load_xml(p_xml,'date',to_char(sysdate,'dd/mm/yyyy'));
    --
    -- Obtain training contribution rates and reduction if any
    open csr_comp_training_contrib_info(
                               fnd_date.date_to_canonical(l_header_rec.date2));
    fetch csr_comp_training_contrib_info into l_training_contrib_rec;
    begin
      l_er_tp_contrib_rate  :=
        fnd_number.canonical_to_number(
          hruserdt.get_table_value(l_header_rec.bg_id
                                  ,'FR_CONTRIBUTION_RATES'
                                  ,'Value (EUR)'
                                  ,'ER_TRAINING_PLAN_CONTRIBUTION'
                                  ,l_header_rec.date2));
      l_er_cif_contrib_rate :=
        fnd_number.canonical_to_number(
          hruserdt.get_table_value(l_header_rec.bg_id
                                  ,'FR_CONTRIBUTION_RATES'
                                  ,'Value (EUR)'
                                  ,'ER_CIF_CONTRIBUTION'
                                  ,l_header_rec.date2));
      l_er_alternance_contrib_rate :=
        fnd_number.canonical_to_number(
          hruserdt.get_table_value(l_header_rec.bg_id
                                  ,'FR_CONTRIBUTION_RATES'
                                  ,'Value (EUR)'
                                  ,'ER_ALTERNANCE_CONTRIBUTION'
                                  ,l_header_rec.date2));
    exception when others then
      null;
    end;
    --
    -- write XML for section C
    load_xml(p_xml,'C21'
            ,round((l_er_tp_contrib_rate
                   +l_er_cif_contrib_rate
                   +l_er_alternance_contrib_rate)
                   *(100 - nvl(fnd_number.canonical_to_number(
                                          l_training_contrib_rec.reduction_chr)
                              ,0))
                   /100
                  ,2));
    -- write XML for section D
    load_xml(p_xml,'C31'
            ,round(l_er_cif_contrib_rate
                  *(100 - nvl(fnd_number.canonical_to_number(
                                          l_training_contrib_rec.reduction_chr)
                             ,0))
                  /100
                  ,3));
    -- write XML for section E
    load_xml(p_xml,'C61'
            ,round(l_er_alternance_contrib_rate
                  *(100 - nvl(fnd_number.canonical_to_number(
                                          l_training_contrib_rec.reduction_chr)
                             ,0))
                  /100
                  ,3));
    --
    close csr_comp_training_contrib_info;
  end if;
  if p_detail_section in ('FA','NA') then
    if p_detail_section = 'NA' then
      hr_utility.trace('Section Fa PDF');
      L_SELECT_OUTER := 'select round(nvl(sum(tot),0)) C91 from (';
      L_ORDER_BY     := ')';
      L_SELECT_INNER1:= 'select sum(decode(tpc.currency_code
                 ,''EUR'',TPC.amount
                 ,hr_currency_pkg.convert_amount_sql(tpc.currency_code
                                                    ,''EUR''
                                                    ,sysdate
                                                    ,tpc.amount
                                                    ,:CURR_RATE_TYPE)))  tot ';
      L_GROUP_INNER1 := '
';
      L_SELECT_INNER2:= 'select
  sum(decode(nvl(pabs.abs_information8,bg_info.org_information10)
            ,''EUR'',fnd_number.canonical_to_number(pabs.abs_information11)
            ,hr_currency_pkg.convert_amount_sql(
                nvl(pabs.abs_information8,bg_info.org_information10)
               ,''EUR''
               ,sysdate
               ,nvl(fnd_number.canonical_to_number(pabs.abs_information11),0)
               ,:CURR_RATE_TYPE)))                                          tot
';
    else -- p_detail_section = 'FA'
      hr_utility.trace('Section Fa RTF');
      L_SELECT_OUTER := null;
      L_SELECT_INNER1:= 'select
  costs.full_name
 ,costs.order_name
 ,costs.employee_number
 ,decode(costs.full_name,
         null,to_date(null),
         evt.course_start_date)                                       trn_start
 ,decode(costs.full_name,
         null,to_date(null),
         evt.course_end_date)                                           trn_end
 ,EVT_tl.title                                                       class_name
 ,costs.plan_name                                                     plan_name
 ,costs.trn_sal
 ,costs.admin_sal
 ,costs.running_costs
 ,costs.trn_tran
 ,costs.trn_accom
 ,costs.other
 ,costs.emp_tot
from
(select /*+ORDERED*/
  PER.full_name                                                       full_name
 ,PER.order_name                                                     order_name
 ,PER.employee_number                                           employee_number
 ,nvl(odb.event_id,tpc.event_id)                                       event_id
 ,tp.name                                                             plan_name
 ,sum(decode(TMT.tp_measurement_code
            ,''FR_DEDUCT_TRAINER_SALARY''
            ,decode(tpc.currency_code
                   ,''EUR'',TPC.amount
                   ,hr_currency_pkg.convert_amount_sql(tpc.currency_code
                                                      ,''EUR''
                                                      ,sysdate
                                                      ,tpc.amount
                                                      ,:CURR_RATE_TYPE))
            ,0))                                                        trn_sal
 ,sum(decode(TMT.tp_measurement_code
            ,''FR_DEDUCT_ADMIN_SALARY''
            ,decode(tpc.currency_code
                   ,''EUR'',TPC.amount
                   ,hr_currency_pkg.convert_amount_sql(tpc.currency_code
                                                      ,''EUR''
                                                      ,sysdate
                                                      ,tpc.amount
                                                      ,:CURR_RATE_TYPE))
            ,0))                                                      admin_sal
 ,sum(decode(TMT.tp_measurement_code
            ,''FR_DEDUCT_RUNNING_COSTS''
            ,decode(tpc.currency_code
                   ,''EUR'',TPC.amount
                   ,hr_currency_pkg.convert_amount_sql(tpc.currency_code
                                                      ,''EUR''
                                                      ,sysdate
                                                      ,tpc.amount
                                                      ,:CURR_RATE_TYPE))
            ,0))                                                  running_costs
 ,sum(decode(TMT.tp_measurement_code
            ,''FR_DEDUCT_TRAINER_TRANSPRT''
            ,decode(tpc.currency_code
                   ,''EUR'',TPC.amount
                   ,hr_currency_pkg.convert_amount_sql(tpc.currency_code
                                                      ,''EUR''
                                                      ,sysdate
                                                      ,tpc.amount
                                                      ,:CURR_RATE_TYPE))
            ,0))                                                       trn_tran
 ,sum(decode(TMT.tp_measurement_code
            ,''FR_DEDUCT_TRAINER_ACCOM''
            ,decode(tpc.currency_code
                   ,''EUR'',TPC.amount
                   ,hr_currency_pkg.convert_amount_sql(tpc.currency_code
                                                      ,''EUR''
                                                      ,sysdate
                                                      ,tpc.amount
                                                      ,:CURR_RATE_TYPE))
            ,0))                                                      trn_accom
 ,sum(decode(TMT.tp_measurement_code
            ,''FR_OTHER_CLASS_DEDUCT_COST''
            ,decode(tpc.currency_code
                   ,''EUR'',TPC.amount
                   ,hr_currency_pkg.convert_amount_sql(tpc.currency_code
                                                      ,''EUR''
                                                      ,sysdate
                                                      ,tpc.amount
                                                      ,:CURR_RATE_TYPE))
            ,0))                                                          other
 ,sum(decode(TMT.tp_measurement_code
            ,''FR_OTHER_LEARN_DEDUCT_INT''
            ,decode(tpc.currency_code
                   ,''EUR'',TPC.amount
                   ,hr_currency_pkg.convert_amount_sql(tpc.currency_code
                                                      ,''EUR''
                                                      ,sysdate
                                                      ,tpc.amount
                                                      ,:CURR_RATE_TYPE))
            ,0))                                                        emp_tot
';
      L_GROUP_INNER1 := '
  group by PER.order_name,PER.employee_number
        ,nvl(ODB.event_id,TPC.event_id),tp.name,PER.full_name) costs,
  ota_events                  EVT,
  ota_events_tl               evt_tl
where costs.event_id              = EVT.event_id
  and EVT.event_id                = EVT_tl.event_id
  and EVT_tl.language             = userenv(''LANG'')
/*and EVT.vendor_id              is null        Internal training */
/*and EVT.event_type              = ''SCHEDULED''*/
/*and evt.event_status           <> ''A''     A=Cancelled.  Nb. event_status is
                                              not null for SCHEDULED events*/
/*and evt.course_start_date between PTP.start_date    COURSE_START_DATE is */
/*                              and ptp.end_date      only not null for
                                                      SCHEDULED events where
                                                      they are Normal or Full*/
';
      L_SELECT_INNER2:= 'select
  per.full_name
 ,per.order_name
 ,per.employee_number
 ,pabs.date_start                                                     trn_start
 ,pabs.date_end                                                         trn_end
 ,null                                                               class_name
 ,null                                                                plan_name
 ,null                                                                  trn_sal
 ,null                                                                admin_sal
 ,null                                                            running_costs
 ,null                                                                 trn_tran
 ,null                                                                trn_accom
 ,null                                                                    other
 ,decode(nvl(pabs.abs_information8,bg_info.org_information10)
        ,''EUR'',fnd_number.canonical_to_number(pabs.abs_information11)
        ,hr_currency_pkg.convert_amount_sql(
            nvl(pabs.abs_information8,bg_info.org_information10)
           ,''EUR''
           ,sysdate
           ,nvl(fnd_number.canonical_to_number(pabs.abs_information11),0)
           ,:CURR_RATE_TYPE))                                           emp_tot
';
      L_ORDER_BY     := '
  order by 2 NULLS FIRST,3 NULLS FIRST,4 NULLS FIRST,6,7';
    end if; -- p_detail_section = 'NA'
    l_sql := L_SELECT_OUTER||L_SELECT_INNER1||' from
  hr_all_organization_units   comp,
  hr_organization_information tp_org_info,
  hr_all_organization_units   org,
  ota_training_plans          TP,
  per_time_periods            PTP,
  ota_training_plan_costs     TPC,
  ota_tp_measurement_types    TMT,
  ota_delegate_bookings       ODB,
  per_all_people_f            PER
where comp.organization_id        = :p_company_id
  and comp.date_from             <= :p_year_end
  and (comp.date_to              is null or
       comp.date_to              >= :p_year_start) '
  ||L_WHERE_TP_ORG||'
  and org.organization_id         = tp_org_info.organization_id
  and org.date_from              <= :p_year_end
  and (org.date_to               is null or
       org.date_to               >= :p_year_start)
  and org.organization_id         = TP.organization_id
/*and TP.plan_status_type_id     <> ''CANCELLED''*/
  and TP.time_period_id           = PTP.time_period_id
  and PTP.period_type             = ''Year''
  and PTP.start_date              = :p_year_start
  and TP.training_plan_id         = TPC.training_plan_id
  and TPC.tp_measurement_type_id  = TMT.tp_measurement_type_id
  and TMT.business_group_id       = org.business_group_id
  and ((TPC.tp_measurement_type_id in (:DEDUCTIBLE_TRAINER_SALARY,
                                       :DEDUCTIBLE_ADMIN_SALARY,
                                       :DEDUCTIBLE_RUNNING_COSTS,
                                       :DEDUCTIBLE_TRAINER_TRANSPRT,
                                       :DEDUCTIBLE_TRAINER_ACCOM,
                                       :OTHER_CLASS_DEDUCTIBLE_COST) AND
        TMT.cost_level            = ''EVENT'') or
       (TPC.tp_measurement_type_id= :OTHER_LEARN_DEDUCT_COST_INT AND
        TMT.cost_level            = ''DELEGATE''))
  AND TMT.unit                    = ''M''
  AND TPC.booking_id              = ODB.booking_id(+)
  and ODB.delegate_person_id      = PER.person_id(+)
  and :p_comp_end           between PER.effective_start_date(+)
                                AND PER.effective_end_date  (+) '||
  L_GROUP_INNER1||' UNION ALL '||L_SELECT_INNER2||' from
  hr_all_organization_units    comp,
  hr_organization_information  estab_info,
  hr_all_organization_units    estab,
  per_all_assignments_f        ass,
  per_all_people_f             per,
  per_absence_attendances      pabs,
  per_absence_attendance_types pabt,
  hr_organization_information  bg_info
where comp.organization_id           = :p_company_id
  and comp.date_from                <= :p_year_end
  and (comp.date_to                 is null or
       comp.date_to                 >= :p_year_start)
  and estab_info.org_information_context = ''FR_ESTAB_INFO''
  and estab_info.org_information1    = to_char(comp.organization_id)
  and estab.organization_id          = estab_info.organization_id
  and estab.date_from               <= :p_year_end
  and (estab.date_to                is null or
       estab.date_to                >= :p_year_start)
  and estab.organization_id          = ass.establishment_id
  AND ass.primary_flag               = ''Y''
  /* rough filter on asg dates: */
  and ass.effective_start_date      <= :p_comp_end
  and ass.effective_end_date        >= :p_comp_start
  and ass.person_id                  = per.person_id
  and :p_comp_end              between per.effective_start_date
                                   and per.effective_end_date
  and per.person_id                  = pabs.person_id
  and pabs.abs_information_category  = ''FR_TRAINING_ABSENCE''
  and pabs.date_end            between ass.effective_start_date
                                   and ass.effective_end_date
  and pabs.date_end            between :p_comp_start
                                   and :p_comp_end
  /*Not Within Training Plan*/
  and pabs.abs_information18         = ''N''/* nullable */
  /* Training leave category */
  and (pabs.abs_information1        is null or
       pabs.abs_information1    not in (''TRAINING_CREDIT'',
                                        ''TRAINING_LEAVE''))
  and pabs.abs_information3         is null /* Training provider */
  and pabs.abs_information5          = ''EMPLOYER'' /* Subsidized type */
  and pabs.abs_information11        <> ''0''
  and pabs.absence_attendance_type_id= pabt.absence_attendance_type_id
  and pabt.absence_category          = ''TRAINING_ABSENCE''
  AND bg_info.organization_id            = comp.business_group_id
  and bg_info.org_information_context    = ''Business Group Information'' '||
  L_ORDER_BY;
    --
    --trace_sql(l_sql);
    l_C91 := 0;
    if p_detail_section = 'NA' then
      OPEN l_ref_csr for l_sql using l_currency_rate_type
                                  ,p_company_id,l_year_end,l_year_start
                                  ,l_year_end,l_year_start,l_year_start
                                  ,l_meas_types_rec.DEDUCTIBLE_TRAINER_SALARY
                                  ,l_meas_types_rec.DEDUCTIBLE_ADMIN_SALARY
                                  ,l_meas_types_rec.DEDUCTIBLE_RUNNING_COSTS
                                  ,l_meas_types_rec.DEDUCTIBLE_TRAINER_TRANSPRT
                                  ,l_meas_types_rec.DEDUCTIBLE_TRAINER_ACCOM
                                  ,l_meas_types_rec.OTHER_CLASS_DEDUCTIBLE_COST
                                  ,l_meas_types_rec.OTHER_LEARN_DEDUCT_COST_INT
                                  ,l_header_rec.date2,l_currency_rate_type
                                  ,p_company_id,l_year_end
                                  ,l_year_start,l_year_end,l_year_start
                                  ,l_header_rec.date2,l_header_rec.date1
                                  ,l_header_rec.date2,l_header_rec.date1
                                  ,l_header_rec.date2;
      fetch l_ref_csr into l_C91;
      --  Assemble pdf XML...
      load_xml(p_xml,'C91',l_C91);
      close l_ref_csr;
    else
      l_currency_rate_type := hr_currency_pkg.get_rate_type(l_header_rec.bg_id
                                                           ,sysdate,'R');
      --
      OPEN l_ref_csr for l_sql using l_currency_rate_type,l_currency_rate_type
                                  ,l_currency_rate_type,l_currency_rate_type
                                  ,l_currency_rate_type,l_currency_rate_type
                                  ,l_currency_rate_type
                                  ,p_company_id,l_year_end,l_year_start
                                  ,l_year_end,l_year_start,l_year_start
                                  ,l_meas_types_rec.DEDUCTIBLE_TRAINER_SALARY
                                  ,l_meas_types_rec.DEDUCTIBLE_ADMIN_SALARY
                                  ,l_meas_types_rec.DEDUCTIBLE_RUNNING_COSTS
                                  ,l_meas_types_rec.DEDUCTIBLE_TRAINER_TRANSPRT
                                  ,l_meas_types_rec.DEDUCTIBLE_TRAINER_ACCOM
                                  ,l_meas_types_rec.OTHER_CLASS_DEDUCTIBLE_COST
                                  ,l_meas_types_rec.OTHER_LEARN_DEDUCT_COST_INT
                                  ,l_header_rec.date2,l_currency_rate_type
                                  ,p_company_id,l_year_end
                                  ,l_year_start,l_year_end,l_year_start
                                  ,l_header_rec.date2,l_header_rec.date1
                                  ,l_header_rec.date2,l_header_rec.date1
                                  ,l_header_rec.date2;
      /* Bulk fetches from dynamic cursors not supported in 8.1.7
      FETCH l_ref_csr BULK COLLECT INTO
        tbl_full_name, tbl_order_name, tbl_emp_num, tbl_trn_start, tbl_trn_end,
        tbl_class_name, tbl_plan_name, tbl_num1, tbl_num2, tbl_num3, tbl_num4,
        tbl_num5, tbl_num6, tbl_num7;*/
      l_prev_rec := l_empt_rec;
      l_tot_trn_sal    := 0;
      l_tot_admin_sal  := 0;
      l_tot_run_costs  := 0;
      l_tot_trn_tran   := 0;
      l_tot_trn_accom  := 0;
      l_tot_other      := 0;
      l_total          := 0;
      --  Assemble rtf XML...
      load_xml(p_xml,'SECTION_Fa',c_OpenGrpTag);
      loop
        FETCH l_ref_csr INTO
          l_curr_rec.full_name, l_curr_rec.order_name, l_curr_rec.emp_num,
          l_curr_rec.trn_start, l_curr_rec.trn_end, l_curr_rec.class_name,
          l_curr_rec.plan_name, l_curr_rec.num1, l_curr_rec.num2,
          l_curr_rec.num3, l_curr_rec.num4, l_curr_rec.num5, l_curr_rec.num6,
          l_curr_rec.num7;
        if  (l_ref_csr%NOTFOUND
             or nvl(l_prev_rec.full_name,' ') <> nvl(l_curr_rec.full_name,' ')
             or nvl(l_prev_rec.emp_num,' ') <> nvl(l_curr_rec.emp_num,' '))
        and l_ref_csr%ROWCOUNT > 0
        then
          if l_prev_rec.full_name is not null then
            -- Close previous EMP
            load_xml(p_xml,'EMP',c_CloseGrpTag);
            if l_ref_csr%NOTFOUND then
              -- close previous EMP_LIST
              load_xml(p_xml,'TOTAL',l_total);
              load_xml(p_xml,'EMP_LIST',c_CloseGrpTag);
              l_C91   := l_C91+l_total;
            end if;
          elsif l_prev_rec.class_name is not null then
            -- close previous CLASS_LIST
            load_xml(p_xml,'TOT_TRN_SAL',l_tot_trn_sal);
            load_xml(p_xml,'TOT_ADMIN_SAL',l_tot_admin_sal);
            load_xml(p_xml,'TOT_RUN_COSTS',l_tot_run_costs);
            load_xml(p_xml,'TOT_TRN_TRAN',l_tot_trn_tran);
            load_xml(p_xml,'TOT_TRN_ACCOM',l_tot_trn_accom);
            load_xml(p_xml,'TOT_OTHER',l_tot_other);
            load_xml(p_xml,'TOTAL',l_total);
            load_xml(p_xml,'CLASS_LIST',c_CloseGrpTag);
            l_C91   := l_total;
            l_total := 0;
          end if;
        end if;
        exit when l_ref_csr%NOTFOUND;
        if l_curr_rec.full_name is null then
          if l_ref_csr%ROWCOUNT = 1 then
            -- open CLASS_LIST
            load_xml(p_xml,'CLASS_LIST',c_OpenGrpTag);
          end if;
          load_xml(p_xml,'CLASS',c_OpenGrpTag);
          load_xml(p_xml,'CLASS_NAME',l_curr_rec.class_name);
          load_xml(p_xml,'PLAN_NAME',l_curr_rec.plan_name);
          load_xml(p_xml,'TRN_SAL',l_curr_rec.num1);
          load_xml(p_xml,'ADMIN_SAL',l_curr_rec.num2);
          load_xml(p_xml,'RUNNING_COSTS',l_curr_rec.num3);
          load_xml(p_xml,'TRN_TRAN',l_curr_rec.num4);
          load_xml(p_xml,'TRN_ACCOM',l_curr_rec.num5);
          load_xml(p_xml,'OTHER',l_curr_rec.num6);
          l_curr_rec.num7 :=  l_curr_rec.num1
                             +l_curr_rec.num2
                             +l_curr_rec.num3
                             +l_curr_rec.num4
                             +l_curr_rec.num5
                             +l_curr_rec.num6;
          load_xml(p_xml,'TOT',l_curr_rec.num7);
          load_xml(p_xml,'CLASS',c_CloseGrpTag);
          l_tot_trn_sal    := l_tot_trn_sal + l_curr_rec.num1;
          l_tot_admin_sal  := l_tot_admin_sal + l_curr_rec.num2;
          l_tot_run_costs  := l_tot_run_costs + l_curr_rec.num3;
          l_tot_trn_tran   := l_tot_trn_tran + l_curr_rec.num4;
          l_tot_trn_accom  := l_tot_trn_accom + l_curr_rec.num5;
          l_tot_other      := l_tot_other + l_curr_rec.num6;
          l_total          := l_total + l_curr_rec.num7;
        else -- delegate / absence
          if nvl(l_prev_rec.full_name,' ') <> l_curr_rec.full_name
          or nvl(l_prev_rec.emp_num,' ') <> l_curr_rec.emp_num
          then
            if  l_prev_rec.full_name is null
            and l_prev_rec.emp_num is null then
              -- open EMP_LIST
              load_xml(p_xml,'EMP_LIST',c_OpenGrpTag);
            end if;
            -- open EMP
            load_xml(p_xml,'EMP',c_OpenGrpTag);
            load_xml(p_xml,'FULL_NAME',l_curr_rec.full_name);
            load_xml(p_xml,'EMPLOYEE_NUMBER',l_curr_rec.emp_num);
          end if;
          load_xml(p_xml,'TRAINING',c_OpenGrpTag);
          load_xml(p_xml,'TRN_START',l_curr_rec.trn_start);
          load_xml(p_xml,'TRN_END',l_curr_rec.trn_end);
          load_xml(p_xml,'CLASS',l_curr_rec.class_name);
          load_xml(p_xml,'PLAN',l_curr_rec.plan_name);
          load_xml(p_xml,'TOT',l_curr_rec.num7);
          load_xml(p_xml,'TRAINING',c_CloseGrpTag);
          l_total          := l_total + l_curr_rec.num7;
        end if;
        l_prev_rec := l_curr_rec;
      end loop;
      load_xml(p_xml,'C91',l_C91);
      load_xml(p_xml,'SECTION_Fa',c_CloseGrpTag);
      close l_ref_csr;
    end if; -- p_detail_section
  end if; --  section Fa
  --
  if p_detail_section in ('FB_CONTRACTED','FB_SA','FB_VAE','NA') then
    if p_detail_section = 'NA' then
      hr_utility.trace('Section Fb PDF');
      L_SELECT_OUTER := 'select
    round(nvl(sum(decode(trn_type,''CONTRACTED'',trn_cost)),0)) x1,
    round(nvl(sum(decode(trn_type,''SA'',        trn_cost)),0)) x2,
    round(nvl(sum(decode(trn_type,''VAE'',       trn_cost)),0)) x3
from (
';
      L_ORDER_BY     := ')';
      L_SELECT_INNER1:= 'select
  decode(TMT.tp_measurement_code,
         ''FR_DEDUCT_EXT_TRN_PLAN_VAE'',''VAE'',
         ''FR_DEDUCT_EXT_TRN_PLAN_SA'', ''SA'',
         ''FR_SKILLS_ASSESSMENT'',      ''SA'',
         ''FR_VAE'',                    ''VAE'',
                                      ''CONTRACTED'')                  trn_type
 ,decode(tpc.currency_code
        ,''EUR'',TPC.amount
        ,hr_currency_pkg.convert_amount_sql(tpc.currency_code
                                           ,''EUR''
                                           ,sysdate
                                           ,tpc.amount
                                           ,:CURR_RATE_TYPE))        trn_cost
';
      L_GROUP_INNER1 := '
';
      L_SELECT_INNER2:= 'select
  decode(pabs.abs_information1,
         ''SKILLS_ASSESSMENT'',''SA'',
         ''VAE'',              ''VAE'',
                             ''CONTRACTED'')                           trn_type
  ,decode(nvl(pabs.abs_information8,bg_info.org_information10)
        ,''EUR'',fnd_number.canonical_to_number(pabs.abs_information11)
        ,hr_currency_pkg.convert_amount_sql(
            nvl(pabs.abs_information8,bg_info.org_information10)
           ,''EUR''
           ,sysdate
           ,nvl(fnd_number.canonical_to_number(pabs.abs_information11),0)
           ,:CURR_RATE_TYPE))                                       trn_cost
';
      L_WHERE_INNER2 := null;
    else -- p_detail_section like 'FB%'
      hr_utility.trace('Section '||p_detail_section||' RTF');
      L_SELECT_OUTER := null;
      L_SELECT_INNER1:= 'select
  costs.full_name
 ,costs.order_name
 ,costs.employee_number
 ,decode(costs.full_name,
         null,to_date(null),
         evt.course_start_date)                                       trn_start
 ,decode(costs.full_name,
         null,to_date(null),
         evt.course_end_date)                                           trn_end
 ,EVT_tl.title                                                       class_name
 ,ota_pv.vendor_name                                              supplier_name
 ,costs.plan_name                                                     plan_name
 ,costs.trn_cost                                                       trn_cost
 ,costs.trn_cost_cc                                                 trn_cost_cc
from
(select /*+ORDERED*/
  PER.full_name                                                       full_name
 ,PER.order_name                                                     order_name
 ,PER.employee_number                                           employee_number
 ,nvl(ODB.event_id,TPC.event_id)                                       EVENT_ID
 ,tp.name                                                             plan_name
 ,tpc.amount                                                           trn_cost
 ,tpc.currency_code                                                 trn_cost_cc
';
      L_GROUP_INNER1 := ') costs,
  ota_events                  EVT,
  ota_events_tl               evt_tl,
  po_vendors                  ota_pv
where costs.event_id              = EVT.event_id (+)
  and EVT.event_id                = EVT_tl.event_id (+)
  and EVT_tl.language(+)          = userenv(''LANG'')
  and EVT.vendor_id               = ota_pv.vendor_id(+)
/*and EVT.vendor_id              is not null        External training */
/*and EVT.event_type              = ''SCHEDULED''*/
/*and evt.event_status           <> ''A''     A=Cancelled.  Nb. event_status is
                                              not null for SCHEDULED events*/
/*and evt.course_start_date between PTP.start_date    COURSE_START_DATE is */
/*                              and ptp.end_date      only not null for
                                                      SCHEDULED events where
                                                      they are Normal or Full*/
';
      L_SELECT_INNER2:= 'select
  per.full_name
 ,per.order_name
 ,per.employee_number
 ,pabs.date_start                                                   trn_start
 ,pabs.date_end                                                       trn_end
 ,null                                                             class_name
 ,ota_pv.vendor_name                                            supplier_name
 ,null                                                              plan_name
 ,nvl(fnd_number.canonical_to_number(pabs.abs_information11),0)      trn_cost
 ,nvl(pabs.abs_information8,bg_info.org_information10)            trn_cost_cc
';
      L_WHERE_INNER2:= '
  and decode(pabs.abs_information1,
             ''SKILLS_ASSESSMENT'',''FB_SA'',
             ''VAE'',              ''FB_VAE'',
                                 ''FB_CONTRACTED'')           = :TRN_TYPE ';
      L_ORDER_BY     := '
order by 2 NULLS FIRST,3 NULLS FIRST ,4 NULLS FIRST,6 NULLS FIRST,8';
    end if; -- p_detail_section = 'NA'
    l_sql := L_SELECT_OUTER||L_SELECT_INNER1||' from
  hr_all_organization_units   comp,
  hr_organization_information tp_org_info,
  hr_all_organization_units   org,
  ota_training_plans          TP,
  per_time_periods            PTP,
  ota_training_plan_costs     TPC,
  ota_tp_measurement_types    TMT,
  ota_delegate_bookings       ODB,
  per_all_people_f            PER
where comp.organization_id        = :p_company_id
  and comp.date_from             <= :p_year_end
  and (comp.date_to              is null or
       comp.date_to              >= :p_year_start) '
  ||L_WHERE_TP_ORG||'
  and org.organization_id         = tp_org_info.organization_id
  and org.date_from              <= :p_year_end
  and (org.date_to               is null or
       org.date_to               >= :p_year_start)
  and org.organization_id         = TP.organization_id
/*and TP.plan_status_type_id     <> ''CANCELLED''*/
  and TP.time_period_id           = PTP.time_period_id
  and PTP.period_type             = ''Year''
  and PTP.start_date              = :p_year_start
  and TP.training_plan_id         = TPC.training_plan_id
  and TPC.tp_measurement_type_id  = TMT.tp_measurement_type_id
  and TMT.business_group_id       = org.business_group_id
  and ((TPC.tp_measurement_type_id in (:DEDUCTIBLE_EXT_TRN_PLAN,
                                       :DEDUCTIBLE_EXT_TRN_PLAN_SA,
                                       :DEDUCTIBLE_EXT_TRN_PLAN_VAE) AND
        TMT.cost_level            = ''PLAN'') or
       (TPC.tp_measurement_type_id= :DEDUCTIBLE_EXT_TRN_CLASS AND
        TMT.cost_level            = ''EVENT'') or
       (TPC.tp_measurement_type_id in (:SKILLS_ASSESSMENT,
                                       :VAE,
                                       :OTHER_LEARN_DEDUCT_COST_EXT) AND
        TMT.cost_level            = ''DELEGATE''))
  AND TMT.unit                    = ''M''
  AND TPC.booking_id              = ODB.booking_id(+)
  and ODB.delegate_person_id      = PER.person_id(+)
  and :p_comp_end           between PER.effective_start_date(+)
                                AND PER.effective_end_date  (+) '||
  L_GROUP_INNER1||'UNION ALL '||L_SELECT_INNER2||' from
  hr_all_organization_units    comp,
  hr_organization_information  estab_info,
  hr_all_organization_units    estab,
  per_all_assignments_f        ass,
  per_all_people_f             per,
  per_absence_attendances      pabs,
  per_absence_attendance_types pabt,
  po_vendors                   ota_pv,
  hr_organization_information  bg_info
where comp.organization_id               = :p_company_id
  and comp.date_from                    <= :p_year_end
  and (comp.date_to                     is null or
       comp.date_to                     >= :p_year_start)
  and estab_info.org_information_context = ''FR_ESTAB_INFO''
  and estab_info.org_information1        = to_char(comp.organization_id)
  and estab.organization_id              = estab_info.organization_id
  and estab.date_from                   <= :p_year_end
  and (estab.date_to                    is null or
       estab.date_to                    >= :p_year_start)
  and estab.organization_id              = ass.establishment_id
  AND ass.primary_flag                   = ''Y''
  /* rough filter on asg dates: */
  and ass.effective_start_date          <= :p_comp_end
  and ass.effective_end_date            >= :p_comp_start
  and ass.person_id                      = per.person_id
  and :p_comp_end                  between per.effective_start_date
                                       and per.effective_end_date
  and per.person_id                      = pabs.person_id
  and pabs.abs_information_category      = ''FR_TRAINING_ABSENCE''
  and pabs.date_end                between ass.effective_start_date
                                       and ass.effective_end_date
  and pabs.date_end                between :p_comp_start
                                       and :p_comp_end
  /*Not Within Training Plan*/
  and pabs.abs_information18             = ''N''/* nullable */
  /* Training leave category */ '||L_WHERE_INNER2||'
  and (pabs.abs_information1            is null or
       pabs.abs_information1        not in (''TRAINING_CREDIT'',
                                            ''TRAINING_LEAVE''))
  and pabs.abs_information3              = ota_pv.vendor_id /* Training provider*/
  and pabs.abs_information5              = ''EMPLOYER'' /* Subsidized type */
  and pabs.abs_information11            <> ''0''
  and pabs.absence_attendance_type_id    = pabt.absence_attendance_type_id
  and pabt.absence_category              = ''TRAINING_ABSENCE''
  AND bg_info.organization_id            = comp.business_group_id
  and bg_info.org_information_context    = ''Business Group Information'' '||
  L_ORDER_BY;
    --
    --trace_sql(l_sql);
    l_x1 := 0;
    l_x2 := 0;
    l_x3 := 0;
    if p_detail_section = 'NA' then
      OPEN l_ref_csr for l_sql using  l_currency_rate_type
        ,p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
        ,l_year_start,l_meas_types_rec.DEDUCTIBLE_EXT_TRN_PLAN
        ,l_meas_types_rec.DEDUCTIBLE_EXT_TRN_PLAN_SA
        ,l_meas_types_rec.DEDUCTIBLE_EXT_TRN_PLAN_VAE
        ,l_meas_types_rec.DEDUCTIBLE_EXT_TRN_CLASS
        ,l_meas_types_rec.SKILLS_ASSESSMENT,l_meas_types_rec.VAE
        ,l_meas_types_rec.OTHER_LEARN_DEDUCT_COST_EXT
        ,l_header_rec.date2,l_currency_rate_type
        ,p_company_id,l_year_end,l_year_start,l_year_end
        ,l_year_start,l_header_rec.date2,l_header_rec.date1
        ,l_header_rec.date2,l_header_rec.date1,l_header_rec.date2;
      fetch l_ref_csr into l_x1,l_x2,l_x3;
      --  Assemble pdf XML...
      load_xml(p_xml,'x1',l_x1);
      load_xml(p_xml,'x2',l_x2);
      load_xml(p_xml,'x3',l_x3);
      load_xml(p_xml,'C101',l_x1+l_x2+l_x3);
      close l_ref_csr;
    else -- Fb debug
      l_currency_rate_type := hr_currency_pkg.get_rate_type(l_header_rec.bg_id
                                                           ,sysdate,'R');
      --
      if p_detail_section = 'FB_CONTRACTED' then
        OPEN l_ref_csr for l_sql using
           p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
          ,l_year_start,l_meas_types_rec.DEDUCTIBLE_EXT_TRN_PLAN
          ,to_number(null),to_number(null)
          ,l_meas_types_rec.DEDUCTIBLE_EXT_TRN_CLASS
          ,to_number(null),to_number(null)
          ,l_meas_types_rec.OTHER_LEARN_DEDUCT_COST_EXT
          ,l_header_rec.date2
          ,p_company_id,l_year_end,l_year_start,l_year_end
          ,l_year_start,l_header_rec.date2,l_header_rec.date1
          ,l_header_rec.date2,l_header_rec.date1
          ,l_header_rec.date2,p_detail_section;
      elsif p_detail_section = 'FB_SA' then
        OPEN l_ref_csr for l_sql using
           p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
          ,l_year_start,to_number(null)
          ,l_meas_types_rec.DEDUCTIBLE_EXT_TRN_PLAN_SA,to_number(null)
          ,to_number(null)
          ,l_meas_types_rec.SKILLS_ASSESSMENT,to_number(null)
          ,to_number(null)
          ,l_header_rec.date2
          ,p_company_id,l_year_end,l_year_start,l_year_end
          ,l_year_start,l_header_rec.date2,l_header_rec.date1
          ,l_header_rec.date2,l_header_rec.date1
          ,l_header_rec.date2,p_detail_section;
      else -- VAE
        OPEN l_ref_csr for l_sql using
           p_company_id,l_year_end,l_year_start,l_year_end,l_year_start
          ,l_year_start,to_number(null),to_number(null)
          ,l_meas_types_rec.DEDUCTIBLE_EXT_TRN_PLAN_VAE
          ,to_number(null),to_number(null),l_meas_types_rec.VAE
          ,to_number(null)
          ,l_header_rec.date2
          ,p_company_id,l_year_end,l_year_start,l_year_end
          ,l_year_start,l_header_rec.date2,l_header_rec.date1
          ,l_header_rec.date2,l_header_rec.date1
          ,l_header_rec.date2,p_detail_section;
      end if;
      /* Bulk fetches from dynamic cursors not supported in 8.1.7
      FETCH l_ref_csr BULK COLLECT INTO
        tbl_full_name, tbl_order_name, tbl_emp_num, tbl_trn_start, tbl_trn_end,
        tbl_class_name, tbl_plan_name, tbl_supplier, tbl_num1;*/
      l_prev_rec := l_empt_rec;
      --  Assemble rtf XML...
      load_xml(p_xml,'SECTION_Fb',c_OpenGrpTag);
      --load_xml(p_xml,'EMP_LIST',c_OpenGrpTag);
      loop
        FETCH l_ref_csr INTO l_curr_rec.full_name,
          l_curr_rec.order_name, l_curr_rec.emp_num, l_curr_rec.trn_start,
          l_curr_rec.trn_end, l_curr_rec.class_name, l_curr_rec.supplier,
          l_curr_rec.plan_name, l_curr_rec.num1, l_curr_rec.chr1;
        if  (l_ref_csr%NOTFOUND and l_ref_csr%ROWCOUNT > 0) or
            ((nvl(l_prev_rec.full_name,' ') <> nvl(l_curr_rec.full_name,' ') or
              nvl(l_prev_rec.emp_num,' ') <> nvl(l_curr_rec.emp_num,' '))
             and l_ref_csr%ROWCOUNT > 1 )
        then
          -- close previous EMP
          load_xml(p_xml,'EMP',c_CloseGrpTag);
        end if;
        exit when l_ref_csr%NOTFOUND;
        if l_curr_rec.chr1 <> 'EUR' then
          l_curr_rec.num1 :=
            hr_currency_pkg.convert_amount(l_curr_rec.chr1
                                          ,'EUR'
                                          ,sysdate
                                          ,l_curr_rec.num1
                                          ,l_currency_rate_type);
        end if;
        if  (l_ref_csr%ROWCOUNT = 1
             or nvl(l_prev_rec.full_name,' ') <> nvl(l_curr_rec.full_name,' ')
             or nvl(l_prev_rec.emp_num,' ') <> nvl(l_curr_rec.emp_num,' '))
        then
          -- open new EMP
          load_xml(p_xml,'EMP',c_OpenGrpTag);
          load_xml(p_xml,'FULL_NAME',l_curr_rec.full_name);
          load_xml(p_xml,'EMPLOYEE_NUMBER',l_curr_rec.emp_num);
        end if;
        load_xml(p_xml,'TRAINING',c_OpenGrpTag);
        load_xml(p_xml,'TRN_START',l_curr_rec.trn_start);
        load_xml(p_xml,'TRN_END',l_curr_rec.trn_end);
        load_xml(p_xml,'CLASS',l_curr_rec.class_name);
        load_xml(p_xml,'SUPPLIER_NAME',l_curr_rec.supplier);
        load_xml(p_xml,'PLAN',l_curr_rec.plan_name);
        load_xml(p_xml,'TRN_COST',l_curr_rec.num1);
        load_xml(p_xml,'TRAINING',c_CloseGrpTag);
        l_x1 := l_x1 + l_curr_rec.num1;
        l_prev_rec := l_curr_rec;
      end loop;
      --load_xml(p_xml,'EMP_LIST',c_CloseGrpTag);
      load_xml(p_xml,'TOTAL',l_x1);
      load_xml(p_xml,'SECTION_Fb',c_CloseGrpTag);
      close l_ref_csr;
    end if; -- p_detail_section
  end if; --  section Fb
  --
  if p_detail_section in ('FC','NA') then
    if p_detail_section = 'NA' then
      hr_utility.trace('Section Fc PDF');
      L_SELECT_OUTER := 'select round(nvl(sum(sal),0)) C111
from (
';
      L_ORDER_BY     := ')';
      L_SELECT_INNER1:= 'select
  decode(tpc_sal.currency_code
        ,''EUR'',TPC_sal.amount
        ,hr_currency_pkg.convert_amount_sql(tpc_sal.currency_code
                                           ,''EUR''
                                           ,sysdate
                                           ,tpc_sal.amount
                                           ,:CURR_RATE_TYPE))               sal
';
      L_SELECT_INNER2:= 'select
  decode(bg_info.org_information10
        ,''EUR'',fnd_number.canonical_to_number(pabs.abs_information21)
        ,hr_currency_pkg.convert_amount_sql(
            bg_info.org_information10
           ,''EUR''
           ,sysdate
           ,nvl(fnd_number.canonical_to_number(pabs.abs_information21),0)
           ,:CURR_RATE_TYPE))                                               sal
';
    else -- p_detail_section = 'FC'
      hr_utility.trace('Section Fc RTF');
      L_SELECT_OUTER := null;
      L_SELECT_INNER1:= 'select /*+ORDERED*/
  decode(tmt.tp_measurement_code,
         ''FR_SKILLS_ASSESSMENT'',2,
         ''FR_VAE'',3,
         1)                                                         class_order
 ,decode(tmt.tp_measurement_code,
         ''FR_SKILLS_ASSESSMENT'',HLK_tmt.meaning,
         ''FR_VAE'',HLK_tmt.meaning,
         EVT_tl.title)                                               class_name
 ,PER.full_name                                                       full_name
 ,PER.order_name                                                     order_name
 ,PER.employee_number                                                   emp_num
 ,null                                                                 leav_cat
 ,to_date(null)                                                          abs_st
 ,to_date(null)                                                          abs_en
 ,tp.name                                                             plan_name
 ,decode(tmt.tp_measurement_code,
        ''FR_ACTUAL_HOURS'',fnd_number.number_to_canonical(TPC_hrs.amount),
        ''FR_SKILLS_ASSESSMENT'',TPC_hrs.tp_cost_information3,
        ''FR_VAE'',TPC_hrs.tp_cost_information3)                        act_hrs
 ,decode(tmt.tp_measurement_code,
        ''FR_ACTUAL_HOURS'',TPC_hrs.tp_cost_information4,
        ''FR_SKILLS_ASSESSMENT'',TPC_hrs.tp_cost_information4,
        ''FR_VAE'',TPC_hrs.tp_cost_information4)                        out_hrs
 ,decode(tmt.tp_measurement_code,
        ''FR_ACTUAL_HOURS'',hlk_lcat.meaning)                         legal_cat
 ,tpc_sal.amount                                                            sal
 ,tpc_sal.currency_code                                                  sal_cc
';
      L_SELECT_INNER2:= 'select
  4                                                                 class_order
 ,''ABSENCE''                                                        class_name
 ,PER.full_name                                                       full_name
 ,PER.order_name                                                     order_name
 ,PER.employee_number                                                   emp_num
 ,leavecat.meaning                                                     leav_cat
 ,pabs.date_start                                                        abs_st
 ,pabs.date_end                                                          abs_en
 ,null                                                                plan_name
 ,fnd_number.number_to_canonical(pabs.absence_hours)                    act_hrs
 ,pabs.abs_information20                                                out_hrs
 ,legalcat.meaning                                                    legal_cat
 ,nvl(fnd_number.canonical_to_number(pabs.abs_information21),0)             sal
 ,bg_info.org_information10                                              sal_cc
';
      L_ORDER_BY     := '
order by 1,2,4,5,6,8';
    end if; -- p_detail_section = 'NA'
    l_sql := L_SELECT_OUTER||L_SELECT_INNER1||' from
  hr_all_organization_units   comp,
  hr_organization_information tp_org_info,
  hr_all_organization_units   org,
  ota_training_plans          TP,
  per_time_periods            PTP,
  ota_training_plan_costs     TPC_sal,
  ota_training_plan_costs     TPC_hrs,
  ota_tp_measurement_types    TMT,
  ota_delegate_bookings       ODB,
  ota_events                  EVT,
  per_all_people_f            PER,
  hr_lookups                  HLK_tmt,
  hr_lookups                  HLK_lcat,
  ota_events_tl               evt_tl
where comp.organization_id        = :p_company_id
  and comp.date_from             <= :p_end_year
  and (comp.date_to              is null or
       comp.date_to              >= :p_start_year) '
  ||L_WHERE_TP_ORG||'
  and org.organization_id         = tp_org_info.organization_id
  and org.date_from              <= :p_end_year
  and (org.date_to               is null or
       org.date_to               >= :p_start_year)
  and org.organization_id         = TP.organization_id
/*and TP.plan_status_type_id     <> ''CANCELLED''*/
  and TP.time_period_id           = PTP.time_period_id
  and PTP.period_type             = ''Year''
  and PTP.start_date              = :p_start_year
  and TP.training_plan_id         = TPC_sal.training_plan_id
  and TPC_sal.tp_measurement_type_id = :DEDUCTIBLE_LEARNER_SALARY
  and TPC_sal.booking_id          = TPC_hrs.booking_id
  and TPC_sal.training_plan_id    = TPC_hrs.training_plan_id
  and TPC_hrs.tp_measurement_type_id in (:ACTUAL_HOURS,
                                         :SKILLS_ASSESSMENT,
                                         :VAE)
  and TMT.tp_measurement_type_id  = TPC_hrs.tp_measurement_type_id
  and TMT.cost_level              = ''DELEGATE''
  and TMT.unit                   in (''M'',''N'')
  AND TPC_sal.booking_id          = ODB.booking_id
  and ODB.delegate_person_id      = PER.person_id
  and :p_end_comp           between PER.effective_start_date
                                AND PER.effective_end_date
  AND ODB.event_id                = EVT.event_id
/*and EVT.event_type              = ''SCHEDULED''*/
/*and evt.event_status           <> ''A''     A=Cancelled.  Nb. event_status is
                                            not null for SCHEDULED events*/
/*and evt.course_start_date between p_start_year
                                and p_end_year*/
  /* COURSE_START_DATE is only not null for SCHEDULED events where they are
     Normal or Full*/
  and hlk_tmt.lookup_type         = ''OTA_PLAN_MEASUREMENT_TYPE''
  and hlk_tmt.lookup_code         = TMT.tp_measurement_code
  and hlk_lcat.lookup_type(+)     = ''FR_LEGAL_TRG_CATG''
  and hlk_lcat.lookup_code(+)     = TPC_hrs.tp_cost_information3
  and EVT_tl.event_id             = EVT.event_id
  and EVT_tl.language             = userenv(''LANG'')
UNION ALL '||L_SELECT_INNER2||' from
  hr_all_organization_units    comp,
  hr_organization_information  estab_info,
  hr_all_organization_units    estab,
  per_all_assignments_f        ass,
  per_all_people_f             per,
  per_absence_attendances      pabs,
  per_absence_attendance_types pabt,
  hr_lookups                   leavecat,
  hr_lookups                   legalcat,
  hr_organization_information  bg_info
where comp.organization_id               = :p_company_id
  and comp.date_from                    <= :p_end_year
  and (comp.date_to                     is null or
       comp.date_to                     >= :p_start_year)
  and pabt.absence_category          = ''TRAINING_ABSENCE''
  and pabs.absence_attendance_type_id    = pabt.absence_attendance_type_id
  and pabs.abs_information_category      = ''FR_TRAINING_ABSENCE''
  /* Not Within Training Plan */
  and pabs.abs_information18             = ''N''/*nullable*/
  and pabs.date_end                between ass.effective_start_date
                                       and ass.effective_end_date
  and pabs.date_end                between :p_start_comp
                                       and :p_end_comp
  and pabs.abs_information21            <> ''0''
  and per.person_id                      = pabs.person_id
  and ass.person_id                      = per.person_id
  and :p_end_comp                  between per.effective_start_date
                                       and per.effective_end_date
  and estab_info.organization_id         = ass.establishment_id
  AND ass.primary_flag                   = ''Y''
  and estab.date_from                   <= :p_end_year
  and (estab.date_to                    is null or
       estab.date_to                    >= :p_start_year)
  and estab.organization_id              = estab_info.organization_id
  and estab_info.org_information_context = ''FR_ESTAB_INFO''
  and estab_info.org_information1        = to_char(comp.organization_id)
  and leavecat.lookup_code(+)            = pabs.abs_information1
  and leavecat.lookup_type(+)            = ''FR_TRAINING_LEAVE_CATEGORY''
  and legalcat.lookup_code(+)            = pabs.abs_information19
  and legalcat.lookup_type(+)            = ''FR_LEGAL_TRG_CATG''
  /* rough filter on asg dates: */
  and ass.effective_start_date          <= :p_comp_end
  and ass.effective_end_date            >= :p_comp_start
  AND bg_info.organization_id            = comp.business_group_id
  and bg_info.org_information_context    = ''Business Group Information'' '||
  L_ORDER_BY;
    --
    --trace_sql(l_sql);
    l_C111 := 0;
    if p_detail_section = 'NA' then
      OPEN l_ref_csr for l_sql using l_currency_rate_type
                                  ,p_company_id,l_year_end,l_year_start
                                  ,l_year_end,l_year_start,l_year_start
                                  ,l_meas_types_rec.DEDUCTIBLE_LEARNER_SALARY
                                  ,l_meas_types_rec.ACTUAL_HOURS
                                  ,l_meas_types_rec.SKILLS_ASSESSMENT
                                  ,l_meas_types_rec.VAE
                                  ,l_header_rec.date2,l_currency_rate_type
                                  ,p_company_id,l_year_end,l_year_start
                                  ,l_header_rec.date1,l_header_rec.date2
                                  ,l_header_rec.date2,l_year_end,l_year_start
                                  ,l_header_rec.date2,l_header_rec.date1;
      fetch l_ref_csr into l_C111;
      --  Assemble pdf XML...
      load_xml(p_xml,'C111',l_C111);
      close l_ref_csr;
    else
      l_currency_rate_type := hr_currency_pkg.get_rate_type(l_header_rec.bg_id
                                                           ,sysdate,'R');
      --
      OPEN l_ref_csr for l_sql using p_company_id,l_year_end,l_year_start
                                  ,l_year_end,l_year_start,l_year_start
                                  ,l_meas_types_rec.DEDUCTIBLE_LEARNER_SALARY
                                  ,l_meas_types_rec.ACTUAL_HOURS
                                  ,l_meas_types_rec.SKILLS_ASSESSMENT
                                  ,l_meas_types_rec.VAE
                                  ,l_header_rec.date2
                                  ,p_company_id,l_year_end,l_year_start
                                  ,l_header_rec.date1,l_header_rec.date2
                                  ,l_header_rec.date2,l_year_end,l_year_start
                                  ,l_header_rec.date2,l_header_rec.date1;
      /* Bulk fetches from dynamic cursors not supported in 8.1.7
      FETCH l_ref_csr BULK COLLECT INTO tbl_num1,tbl_class_name, tbl_full_name,
                                        tbl_order_name, tbl_emp_num,
                                        tbl_leave_cat, tbl_trn_start,
                                        tbl_trn_end, tbl_plan_name,
                                        tbl_act_hrs_chr, tbl_out_hrs_chr,
                                        tbl_legal_cat, tbl_num2;*/
      --  Assemble rtf XML...
      load_xml(p_xml,'SECTION_Fc',c_OpenGrpTag);
      l_total := 0;
      l_tot_act_hrs := 0;
      l_tot_out_hrs := 0;
      l_prev_rec := l_empt_rec;
      loop
        FETCH l_ref_csr INTO
          l_curr_rec.num1,l_curr_rec.class_name, l_curr_rec.full_name,
          l_curr_rec.order_name, l_curr_rec.emp_num,
          l_curr_rec.leave_cat, l_curr_rec.trn_start,
          l_curr_rec.trn_end, l_curr_rec.plan_name,
          l_curr_rec.act_hrs_chr, l_curr_rec.out_hrs_chr,
          l_curr_rec.legal_cat, l_curr_rec.num2, l_curr_rec.chr1;
        if l_prev_rec.num1 = 4 then
          if l_ref_csr%NOTFOUND
          or l_prev_rec.full_name <> l_curr_rec.full_name
          or l_prev_rec.emp_num <> l_curr_rec.emp_num
          then
            -- close EMP
            load_xml(p_xml,'EMP',c_CloseGrpTag);
            if l_ref_csr%NOTFOUND then
              -- close ABS_LIST
              load_xml(p_xml,'TOT_ACTHRS',l_tot_act_hrs);
              load_xml(p_xml,'TOT_OUTHRS',l_tot_out_hrs);
              load_xml(p_xml,'TOT_SAL',l_total);
              load_xml(p_xml,'ABS_LIST',c_CloseGrpTag);
              l_C111 := l_C111 + l_total;
            end if;
          end if;
        elsif l_ref_csr%ROWCOUNT > 0 then -- l_prev_rec.num1 in (1,2,3) or null
          if (l_ref_csr%NOTFOUND
             or l_prev_rec.num1 <> l_curr_rec.num1
             or l_prev_rec.class_name <> l_curr_rec.class_name)
          then
            -- Close CLASS
            load_xml(p_xml,'TOT_ACTHRS',l_tot_act_hrs);
            load_xml(p_xml,'TOT_OUTHRS',l_tot_out_hrs);
            load_xml(p_xml,'TOT_SAL',l_total);
            load_xml(p_xml,'CLASS',c_CloseGrpTag);
            l_C111 := l_C111 + l_total;
            l_total:= 0;
            l_tot_act_hrs := 0;
            l_tot_out_hrs := 0;
          end if;
        end if;
        exit when l_ref_csr%NOTFOUND;
        if l_curr_rec.chr1 <> 'EUR' then
          l_curr_rec.num2 :=
            hr_currency_pkg.convert_amount(l_curr_rec.chr1
                                          ,'EUR'
                                          ,sysdate
                                          ,l_curr_rec.num2
                                          ,l_currency_rate_type);
        end if;
        if l_curr_rec.num1 = 4 then
          if nvl(l_prev_rec.num1,3) <> 4
          or l_prev_rec.full_name <> l_curr_rec.full_name
          or l_prev_rec.emp_num <> l_curr_rec.emp_num
          then
            if nvl(l_prev_rec.num1,3) <> 4 then
              -- Open ABS_LIST
              load_xml(p_xml,'ABS_LIST',c_OpenGrpTag);
            end if;
            -- Open EMP
            load_xml(p_xml,'EMP',c_OpenGrpTag);
            load_xml(p_xml,'FULL_NAME',l_curr_rec.full_name);
            load_xml(p_xml,'EMPLOYEE_NUMBER',l_curr_rec.emp_num);
          end if;
          load_xml(p_xml,'ABS',c_OpenGrpTag);
          load_xml(p_xml,'LEAV_CAT',l_curr_rec.leave_cat);
          load_xml(p_xml,'ABS_ST',l_curr_rec.trn_start);
          load_xml(p_xml,'ABS_EN',l_curr_rec.trn_end);
          load_xml(p_xml,'LEGAL_CAT',l_curr_rec.legal_cat);
          load_xml(p_xml,'ACT_HRS',l_curr_rec.act_hrs_chr);
          load_xml(p_xml,'OUT_HRS',l_curr_rec.out_hrs_chr);
          load_xml(p_xml,'SAL',l_curr_rec.num2);
          load_xml(p_xml,'ABS',c_CloseGrpTag);
          l_tot_act_hrs := l_tot_act_hrs +
               fnd_number.canonical_to_number(nvl(l_curr_rec.act_hrs_chr,'0'));
          l_tot_out_hrs := l_tot_out_hrs +
               fnd_number.canonical_to_number(nvl(l_curr_rec.out_hrs_chr,'0'));
          l_total       := l_total + l_curr_rec.num2;
        else -- l_curr_rec.num1 in (1,2,3)
          if nvl(l_prev_rec.num1,0) <> l_curr_rec.num1
          or l_prev_rec.class_name <> l_curr_rec.class_name
          then
            -- Open CLASS
            load_xml(p_xml,'CLASS',c_OpenGrpTag);
            load_xml(p_xml,'CLASS_NAME',l_curr_rec.class_name);
          end if;
          load_xml(p_xml,'STUDENT',c_OpenGrpTag);
          load_xml(p_xml,'FULL_NAME',l_curr_rec.full_name);
          load_xml(p_xml,'EMPLOYEE_NUMBER',l_curr_rec.emp_num);
          load_xml(p_xml,'PLAN_NAME',l_curr_rec.plan_name);
          load_xml(p_xml,'LEGAL_CAT',l_curr_rec.legal_cat);
          load_xml(p_xml,'ACT_HRS',l_curr_rec.act_hrs_chr);
          load_xml(p_xml,'OUT_HRS',l_curr_rec.out_hrs_chr);
          load_xml(p_xml,'SAL',l_curr_rec.num2);
          load_xml(p_xml,'STUDENT',c_CloseGrpTag);
          l_tot_act_hrs := l_tot_act_hrs +
               fnd_number.canonical_to_number(nvl(l_curr_rec.act_hrs_chr,'0'));
          l_tot_out_hrs := l_tot_out_hrs +
               fnd_number.canonical_to_number(nvl(l_curr_rec.out_hrs_chr,'0'));
          l_total       := l_total + l_curr_rec.num2;
        end if;
        l_prev_rec := l_curr_rec;
      end loop;
      load_xml(p_xml,'C111',l_C111);
      load_xml(p_xml,'SECTION_Fc',c_CloseGrpTag);
      close l_ref_csr;
    end if;
  end if; --  section Fc
  --
  if p_detail_section = 'NA' then
    hr_utility.trace('Section Fd PDF');
    --  Assemble pdf XML for section Fd using l_C121
    load_xml(p_xml,'C121',l_C121);
  end if; -- section Fd
  --
  if p_detail_section in ('FH','NA') then
    if p_detail_section = 'NA' then
      hr_utility.trace('Section Fh PDF');
      L_SELECT_OUTER := 'select round(nvl(sum(decode(tpc.currency_code
        ,''EUR'',TPC.amount
        ,hr_currency_pkg.convert_amount_sql(tpc.currency_code
                                           ,''EUR''
                                           ,sysdate
                                           ,tpc.amount
                                           ,:CURR_RATE_TYPE))),0))         C151
';
      L_ORDER_BY     := null;
      L_SELECT_INNER1:= null;
    else -- p_detail_section = 'FH'
      hr_utility.trace('Section Fh RTF');
      L_SELECT_OUTER := 'select /*+ORDERED*/
  TP.name                                                             plan_name
 ,tpc.amount                                                             amount
 ,tpc.currency_code                                                          cc
';
      L_SELECT_INNER1:= null;
      L_ORDER_BY     := '
order by tp.name';
    end if; -- p_detail_section = 'NA'
    l_sql := L_SELECT_OUTER||' from
  hr_all_organization_units   comp,
  hr_organization_information tp_org_info,
  hr_all_organization_units   org,
  ota_training_plans          TP,
  per_time_periods            PTP,
  ota_training_plan_costs     TPC
where comp.organization_id        = :p_company_id
  and comp.date_from             <= :p_end_year
  and (comp.date_to              is null or
       comp.date_to              >= :p_start_year) '
  ||L_WHERE_TP_ORG||'
  and org.organization_id         = tp_org_info.organization_id
  and org.date_from              <= :p_end_year
  and (org.date_to               is null or
       org.date_to               >= :p_start_year)
  and org.organization_id         = TP.organization_id
  and TP.time_period_id           = PTP.time_period_id
  and PTP.period_type             = ''Year''
  and TP.training_plan_id         = TPC.training_plan_id
  and TPC.tp_measurement_type_id  = :OTHER_PLAN_DEDUCTIBLE_COSTS
  and PTP.start_date              = :p_start_year
  and tpc.event_id               is null
  and tpc.booking_id             is null'||L_ORDER_BY;
    --
    --trace_sql(l_sql);
    l_C151 := 0;
    if p_detail_section = 'NA' then
      OPEN l_ref_csr for l_sql using l_currency_rate_type
                                  ,p_company_id,l_year_end,l_year_start
                                  ,l_year_end,l_year_start
                                  ,l_meas_types_rec.OTHER_PLAN_DEDUCTIBLE_COSTS
                                  ,l_year_start;
      fetch l_ref_csr into l_C151;
      --  Assemble pdf XML...
      load_xml(p_xml,'C151',l_C151);
      close l_ref_csr;
    else
      l_currency_rate_type := hr_currency_pkg.get_rate_type(l_header_rec.bg_id
                                                           ,sysdate,'R');
      --
      OPEN l_ref_csr for l_sql using p_company_id,l_year_end,l_year_start
                                  ,l_year_end,l_year_start
                                  ,l_meas_types_rec.OTHER_PLAN_DEDUCTIBLE_COSTS
                                  ,l_year_start;
      /* Bulk fetches from dynamic cursors not supported in 8.1.7
      FETCH l_ref_csr BULK COLLECT INTO tbl_plan_name, tbl_num1;*/
      --  Assemble rtf XML...
      load_xml(p_xml,'SECTION_Fh',c_OpenGrpTag);
      loop
        FETCH l_ref_csr INTO l_curr_rec.plan_name, l_curr_rec.num1,
                             l_curr_rec.chr1;
        exit when l_ref_csr%NOTFOUND;
        load_xml(p_xml,'PLAN',c_OpenGrpTag);
        load_xml(p_xml,'PLAN_NAME',l_curr_rec.plan_name);
        if l_curr_rec.chr1 = 'EUR' then
          -- no need to convert currency
          load_xml(p_xml,'AMOUNT',l_curr_rec.num1);
        else
          load_xml(p_xml,'AMOUNT'
                  ,hr_currency_pkg.convert_amount(
                      l_curr_rec.chr1
                     ,'EUR'
                     ,sysdate
                     ,l_curr_rec.num1
                     ,l_currency_rate_type));
        end if;
        load_xml(p_xml,'PLAN',c_CloseGrpTag);
        l_C151 := l_C151 + l_curr_rec.num1;
      end loop;
      load_xml(p_xml,'C151',l_C151);
      load_xml(p_xml,'SECTION_Fh',c_CloseGrpTag);
      close l_ref_csr;
    end if;
  end if; --  section Fh
  load_xml(p_xml,'FIELDS',c_CloseGrpTag);
  --
  --dbms_lob.createtemporary(p_xml,TRUE);
  --p_xml := g_xml;
  hr_utility.trace('Leaving otfr2483.build_XML');
end build_XML;
--
PROCEDURE run_2483 (errbuf              OUT NOCOPY VARCHAR2
                   ,retcode             OUT NOCOPY NUMBER
                   ,p_business_group_id IN NUMBER
                   ,p_template_id       IN NUMBER
                   ,p_company_id        IN NUMBER
                   ,p_calendar          IN VARCHAR2
                   ,p_time_period_id    IN NUMBER
                   ,p_currency_code     IN VARCHAR2
                   ,p_process_name      IN VARCHAR2
                   ,p_debug             IN VARCHAR2) IS
--
l_prmrec        hr_summary_util.prmTabType;
l_stmt          VARCHAR2(32000);
l_start_of_plan VARCHAR2(100);
l_end_of_plan	VARCHAR2(100);
l_select2       VARCHAR2(200);
l_new_tp_string VARCHAR2(300);
l_new_est_string VARCHAR2(300);
--
BEGIN
--
l_select2 := '(SELECT organization_id establishment_id FROM  hr_fr_establishments_v  WHERE company_org_id = ''';
l_select2 := l_select2 || to_char(p_company_id) ||  ''''  ||  ' OR    organization_id = ';
l_select2 := l_select2 || to_char(p_company_id) || ') v ';
--
l_new_tp_string := '(SELECT training_plan_id FROM  ota_training_plans  WHERE time_period_id = ';
l_new_tp_string := l_new_tp_string || to_char(p_time_period_id) || ' and ( ( organization_id in ( select organization_id ';
l_new_tp_string := l_new_tp_string || ' from hr_fr_establishments_v where company_org_id = ''' ;
l_new_tp_string := l_new_tp_string || to_char(p_company_id) || '''' ||  ')) or ( organization_id = ';
l_new_tp_string := l_new_tp_string || to_char(p_company_id) || ' )))';
--
l_new_est_string := '(SELECT organization_id organization_id FROM  hr_fr_establishments_v  WHERE company_org_id = ''';
l_new_est_string := l_new_est_string || to_char(p_company_id) || ''''  || ' OR organization_id = ';
l_new_est_string := l_new_est_string || to_char(p_company_id) || ' )';
--
  begin
   SELECT 'to_date('''||to_char(ptp.start_date,'YYYYMMDD')||''',''YYYYMMDD'')'
   ,      'to_date('''||to_char(ptp.end_date,'YYYYMMDD')||''',''YYYYMMDD'')'
   INTO l_start_of_plan,
        l_end_of_plan
   FROM per_time_periods ptp
   WHERE ptp.time_period_id = p_time_period_id;
  exception
    when others then null;
  end;
--
   l_prmrec(1).name := 'P_BUSINESS_GROUP_ID';
   l_prmrec(1).value := p_business_group_id;
--
   l_prmrec(2).name := 'P_COMPANY_ID';
   l_prmrec(2).value := p_company_id;
--
   l_prmrec(3).name := 'P_TIME_PERIOD_ID';
   l_prmrec(3).value := p_time_period_id;
--
   l_prmrec(4).name := 'P_TRAINING_PLAN_LIST';
   l_prmrec(4).value := l_new_tp_string;
--
   l_prmrec(5).name := 'P_START_OF_PLAN';
   l_prmrec(5).value := l_start_of_plan;
--
   l_prmrec(6).name := 'P_END_OF_PLAN';
   l_prmrec(6).value := l_end_of_plan;
--
   l_prmrec(7).name := 'P_CURRENCY_CODE';
   l_prmrec(7).value := ''''||p_currency_code||'''';
--
   l_prmrec(8).name := 'P_ESTABLISHMENT_TABLE';
   l_prmrec(8).value := l_select2;
--
   l_prmrec(9).name := 'P_ESTABLISHMENT_LIST';
   l_prmrec(9).value := l_new_est_string;
--
hrsumrep.process_run(p_business_group_id => p_business_group_id
                    ,p_process_type      => '2483'
                    ,p_template_id       => p_template_id
                    ,p_process_name      => p_process_name
                    ,p_parameters        => l_prmrec
                    ,p_store_data        => TRUE
                    ,p_statement         => l_stmt
                    ,p_retcode		 => retcode
                    ,p_debug             => 'N');
--
EXCEPTION WHEN OTHERS THEN
  retcode :=2;  /* Critical Error */
  errbuf := sqlerrm;
END run_2483;
--
END otfr2483;

/
