--------------------------------------------------------
--  DDL for Package Body PER_CA_EE_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CA_EE_EXTRACT_PKG" AS
/* $Header: pecaeerp.pkb 115.29 2003/06/16 19:59:09 ssouresr noship $ */

v_naic                naic_tab;
v_naic_count          naic_count_tab;
v_sorted_naic         naic_tab;
v_sorted_naic_count   naic_count_tab;

v_person_type_temp    person_type_tab;
v_person_type         person_type_tab;
v_job_id_temp         job_id_tab;
v_job_id              job_id_tab;
v_job_temp            job_tab;
v_job                 job_tab;


FUNCTION job_exists (p_job_id IN NUMBER)
RETURN VARCHAR2 IS
BEGIN
     IF v_job_id.COUNT > 0 THEN
         IF v_job_id.EXISTS(p_job_id) THEN
              RETURN v_job(p_job_id);
         END IF;
     END IF;

     RETURN NULL;

END  job_exists;

FUNCTION person_type_exists (p_person_type IN NUMBER)
RETURN VARCHAR2 IS
BEGIN
     IF v_person_type.COUNT > 0 THEN
         IF v_person_type.EXISTS(p_person_type) THEN
              RETURN 'Y';
         END IF;
     END IF;

     RETURN NULL;

END  person_type_exists;

FUNCTION employee_promotions (p_assignment_id     IN NUMBER,
                              p_person_id         IN NUMBER,
                              p_business_group_id IN NUMBER,
                              p_start_date        IN DATE,
                              p_end_date          IN DATE,
                              p_boolean           IN VARCHAR2)
RETURN NUMBER IS
v_promotions_count  NUMBER := 0;
BEGIN
     SELECT count(*)
     INTO v_promotions_count
     FROM per_pay_proposals_v2
     WHERE assignment_id  = p_assignment_id
     AND   approved       = 'Y'
     AND   change_date BETWEEN p_start_date
                       AND     p_end_date
     AND   proposal_reason = 'PROM';

     v_promotions_count :=
      v_promotions_count +
      per_fastformula_events_utility.per_fastformula_event('PROMOTION',
                                                           'Promotion',
                                                            p_business_group_id,
                                                            p_person_id,
                                                            p_start_date,
                                                            p_end_date);
     IF p_boolean = 'Y' THEN

        IF v_promotions_count > 0 THEN
           RETURN 1;
        ELSE
           RETURN 0;
        END IF;

     ELSE

        RETURN v_promotions_count;

     END IF;

END employee_promotions;

FUNCTION find_naic (p_naic_code IN VARCHAR2)
RETURN NUMBER IS
BEGIN
     IF p_naic_code IS NOT NULL THEN

          IF v_naic.COUNT > 0 THEN

               FOR i IN v_naic.first..v_naic.last LOOP
                    IF p_naic_code = v_naic(i) THEN
                         RETURN i;
                    END IF;
               END LOOP;

          END IF;

     END IF;

     RETURN 0;

END find_naic;

PROCEDURE sort_naic IS
v_max         number;
v_max_index   number;
BEGIN
     IF v_naic.COUNT > 0 THEN

          FOR i IN v_naic.first..v_naic.last LOOP

               v_max       := 0;
               v_max_index := 0;

               IF v_naic_count.COUNT > 0 THEN

                    FOR j IN v_naic_count.first..v_naic_count.last LOOP

                         IF v_max < v_naic_count(j) THEN
                             v_max := v_naic_count(j);
                             v_max_index := j;
                         END IF;

                    END LOOP;

               END IF;

               IF v_max_index > 0 THEN

                    v_sorted_naic(i)          := v_naic(v_max_index);
                    v_sorted_naic_count(i)    := v_naic_count(v_max_index);
                    v_naic_count(v_max_index) := -1;

               END IF;

          END LOOP;
     END IF;

END sort_naic;

PROCEDURE calc_naic_totals (p_naic_code         IN VARCHAR2,
                            p_date_all_emp      IN DATE,
                            p_business_group_id IN NUMBER,
                            p_year              IN VARCHAR2) IS

  v_person_id          person_tab;
  v_softcoding_keyflex softcoding_tab;
  v_org_information8   org_info8_tab;
  v_organization_id    organization_id_tab;
  v_segment1           segment1_tab;
  v_segment6           segment6_tab;
  v_commit_limit     NATURAL  := 200;
  v_old_row_count    NUMBER   := 0;
  v_new_row_count    NUMBER   := 0;
  v_rows_in_collect  NUMBER   := 0;
  v_index            NUMBER   := 0;
  v_init             NUMBER   := 0;
  v_count            NUMBER   := 0;
  v_year_end         DATE :=  ADD_MONTHS(TRUNC(TO_DATE(p_year,'YYYY'),'Y'), 12) -1;

  CURSOR cur_person  IS
  SELECT DISTINCT paf.person_id,
                  paf.soft_coding_keyflex_id,
                  hsck.segment1,
                  hsck.segment6
  FROM  per_assignments_f  paf,
        per_people_f  ppf,
        per_person_types ppt,
        per_jobs pj,
        hr_soft_coding_keyflex hsck
  WHERE
      p_date_all_emp BETWEEN
                    paf.effective_start_date AND
                    paf.effective_end_date
  AND paf.business_group_id = p_business_group_id
  AND paf.primary_flag      = 'Y'
  AND paf.job_id + 0        = pj.job_id
  AND pj.job_information_category = 'CA'
  AND paf.person_id         =ppf.person_id
  AND p_date_all_emp BETWEEN
                    ppf.effective_start_date AND
                    ppf.effective_end_date
  AND ppf.person_type_id    =ppt.person_type_id
  AND ppt.system_person_type='EMP'
  AND paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
  AND EXISTS
     (SELECT 'X'
      FROM  per_pay_proposals_v2 pppv
      WHERE pppv.business_group_id = p_business_group_id
      AND   pppv.assignment_id     = paf.assignment_id
      AND   pppv.approved          = 'Y'
      AND   pppv.change_date      <= v_year_end)
  AND EXISTS
  (SELECT 1
   FROM    hr_lookups hl
   WHERE   pj.job_information1 = hl.lookup_code
   AND     hl.lookup_type      = 'EEOG' );

  CURSOR cur_gre_naic IS
  SELECT hoi.organization_id,
         hoi.org_information8
  FROM hr_organization_information hoi,
       hr_organization_units hou
  WHERE hou.business_group_id       = p_business_group_id
  AND   hou.organization_id         = hoi.organization_id
  AND   hoi.org_information_context = 'Canada Employer Identification'
  AND   hoi.org_information8 IS NOT NULL;

BEGIN

 OPEN cur_gre_naic;
 FETCH cur_gre_naic BULK COLLECT INTO
   v_organization_id,
   v_org_information8;

 CLOSE cur_gre_naic;

 OPEN cur_person;
 LOOP
     FETCH cur_person BULK COLLECT INTO
        v_person_id,
        v_softcoding_keyflex,
        v_segment1,
        v_segment6
     LIMIT v_commit_limit;

     v_old_row_count  := v_new_row_count;
     v_new_row_count  := cur_person%ROWCOUNT;

     v_rows_in_collect := v_new_row_count - v_old_row_count;

     EXIT WHEN (v_rows_in_collect = 0);

     IF v_person_id.COUNT > 0 THEN

          FOR i IN v_person_id.first..v_person_id.last LOOP

              IF p_naic_code IS NOT NULL THEN

                   IF (v_segment6(i) = p_naic_code) THEN

                        IF v_init = 0 THEN
                             v_naic(1)       := p_naic_code;
                             v_naic_count(1) := 1;
                             v_init          := 1;
                        ELSE
                             v_naic_count(1) := v_naic_count(1) + 1;
                        END IF;

                   ELSIF (v_segment6(i) IS NULL) THEN

                        IF v_organization_id.COUNT > 0 THEN

                             FOR k IN v_organization_id.first..v_organization_id.last LOOP

                                 IF (v_segment1(i) = to_char (v_organization_id(k)) AND
                                      v_org_information8(k) = p_naic_code) THEN

                                      IF v_init = 0 THEN
                                           v_naic(1)       := p_naic_code;
                                           v_naic_count(1) := 1;
                                           v_init          := 1;
                                      ELSE
                                           v_naic_count(1) := v_naic_count(1) + 1;
                                      END IF;

                                      EXIT;

                                 END IF;

                             END LOOP;

                        END IF;

                   END IF;
              ELSE
                   IF (v_segment6(i) IS NOT NULL) THEN

                        v_index := find_naic(v_segment6(i));

                        IF v_index = 0 THEN
                           v_count := v_naic.COUNT;
                           v_naic(v_count + 1) := v_segment6(i);
                           v_naic_count(v_count + 1) := 1;
                        ELSE
                           v_naic_count(v_index) := v_naic_count(v_index) + 1;
                        END IF;

                        v_index := 0;

                   ELSE
                        IF v_organization_id.COUNT > 0 THEN

                             FOR k IN v_organization_id.first..v_organization_id.last LOOP

                                 IF (v_segment1(i) = to_char(v_organization_id(k)))  THEN

                                      v_index := find_naic(v_org_information8(k));

                                      IF v_index = 0 THEN
                                         v_count := v_naic.COUNT;
                                         v_naic(v_count + 1) := v_org_information8(k);
                                         v_naic_count(v_count + 1) := 1;
                                      ELSE
                                         v_naic_count(v_index) := v_naic_count(v_index) + 1;
                                      END IF;

                                      v_index   := 0;
                                      EXIT;

                                 END IF;

                             END LOOP;

                        END IF;

                   END IF;

              END IF;

          END LOOP;

     END IF;

     COMMIT;

 END LOOP;
 CLOSE cur_person;

 sort_naic;

END calc_naic_totals;

--
function check_gre_without_naic(p_business_group_id NUMBER,
                                p_gre_name OUT NOCOPY tab_varchar2)
                                return number is
begin

declare

  cursor cur_gre_without_naic is
  select
    hou.name 	gre_name
  from
    hr_organization_information hoi,
    hr_organization_units hou
  where
    hou.business_group_id = p_business_group_id and
    hou.organization_id = hoi.organization_id and
    hoi.org_information_context = 'Canada Employer Identification' and
    hoi.org_information8 is null;

    j		number := 1;

begin

   hr_utility.trace('Function check_gre_without_naic starte Here !!!!!');

   for i in cur_gre_without_naic loop

     p_gre_name(j) := i.gre_name;
     j 		   := j + 1;

   end loop;

   if j <> 1 then
     return -1;
   else
     return 1;
   end if;

end;

exception
   when others then
     p_gre_name.delete;
     raise;

end; -- End of function check_gre_without_naic
--
-----------------------------------------------------------------------------
-- Name     form1                                              --
-- Purpose                                                                 --
--   This procedure is used to populate per_ca_ee_report_lines for the     --
--   form1 in the Employment Equity Report.                                --
--                                                                         --
--                                                                         --
-----------------------------------------------------------------------------
--
function form1(p_business_group_id in number,
               p_request_id     in number,
               p_year           in varchar2,
               p_naic_code      in varchar2,
               p_date_all_emp   in date,
               p_date_tmp_emp   in date) return number is

  l_year_start date;
  l_year_end date;

begin

  l_year_start :=  trunc(to_date(p_year,'YYYY'),'Y');
  l_year_end   :=  add_months(trunc(to_date(p_year,'YYYY'),'Y'), 12) -1;

declare

  cursor cur_org_info is
  select
    houv.name,houv.address_line_1,
    houv.address_line_2,houv.address_line_3,
    houv.town_or_city, houv.region_1,
    houv.postal_code,houv.country, houv.organization_id ,
    hoi.org_information1
  from
    hr_organization_units_v houv,
    hr_organization_information hoi
  where
    houv.organization_id=hoi.organization_id and
    upper(ltrim(rtrim(hoi.org_information_context)))
             = 'BUSINESS GROUP INFORMATION'
    and houv.business_group_id = p_business_group_id;

   v_name      		   hr_organization_units_v.name%TYPE;
   v_address_line_1        hr_organization_units_v.address_line_1%TYPE;
   v_address_line_2        hr_organization_units_v.address_line_2%TYPE;
   v_address_line_3        hr_organization_units_v.address_line_3%TYPE;
   v_town_or_city          hr_organization_units_v.town_or_city%TYPE;
   v_region_1              hr_organization_units_v.region_1%TYPE;
   v_postal_code           hr_organization_units_v.postal_code%TYPE;
   v_country               hr_organization_units_v.country%TYPE;
   v_organization_id       hr_organization_units_v.organization_id%TYPE;
   v_short_name		   hr_organization_information.org_information1%TYPE;


   cursor cur_employee_info is
   select
     org_information1		ceo_name,
     org_information3		ceo_position,
     org_information2		contact_name,
     org_information4		contact_position,
     org_information5		contact_phone
   from
     hr_organization_information
   where
     upper(ltrim(rtrim(org_information_context)))
            = 'EMPLOYMENT EQUITY INFORMATION' and
     organization_id = v_organization_id;

  cursor cur_employment_category is
  select
    employment_category             employment_category,
    count(distinct l_person_id)     count_category
    from (
    select
      distinct(paf.person_id) l_person_id,
      substr(paf.employment_category,1,2) employment_category
    from
      per_people_f ppf,
      per_assignments_f paf,
      per_person_types ppt,
      hr_soft_coding_keyflex hsck,
      per_jobs pj,
      hr_lookups hl
    where
      ppf.person_type_id = ppt.person_type_id and
      upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
     decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
        ppf.effective_start_date and
        ppf.effective_end_date and
        ppf.person_id = paf.person_id and
     decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
        paf.effective_start_date and
        paf.effective_end_date and
      paf.business_group_id = p_business_group_id and
      paf.primary_flag = 'Y' and
      paf.employment_category is not null and
      substr(paf.employment_category,1,2) in ('FR','PR','PT') and
      paf.job_id = pj.job_id and
      pj.job_information_category = 'CA' and
      pj.job_information1 = hl.lookup_code and
      hl.lookup_type = 'EEOG' and
      (
        (p_naic_code is not null and
          (
          (
            hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
            hsck.segment6 is not null and
            hsck.segment6 = p_naic_code
          )
          OR
          (
            hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
            hsck.segment6 is null and
            hsck.segment1 in (select segment3
                           from per_ca_ee_report_lines
                           where request_id = p_request_id and
                                 context = 'FORM13' and
                                 segment1 = 'NAIC' and
                                 segment2 = p_naic_code)
           )
           )

        ) -- End of p_naic_code is not null
        OR
        (p_naic_code is null and
           (
           (
             hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
             hsck.segment6 is not null and
             hsck.segment6 in (select segment3
                               from  per_ca_ee_report_lines
                               where request_id = p_request_id and
                               context = 'FORM13' and
                               segment1 = 'NAIC')
            )
            OR
            (
              hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
              hsck.segment6 is null and
              hsck.segment1 in (select segment3
                           from per_ca_ee_report_lines
                           where request_id = p_request_id and
                                 context = 'FORM13' and
                                 segment1 = 'NAIC')
            )
            )
        ) -- End of p_naic_code is null
      ) and
    exists
      (
        select 'X'
        from per_pay_proposals_v2  pppv
        where pppv.business_group_id = p_business_group_id and
              pppv.assignment_id = paf.assignment_id and
              pppv.approved = 'Y' and
              pppv.change_date <=
                  decode(substr(paf.employment_category,1,2),
                                'PT',p_date_tmp_emp,l_year_end)
      ) -- End of exists
    union all
    select
      distinct(paf.person_id) l_person_id,
      'FR' employment_category
    from
       per_people_f ppf,
       per_assignments_f paf,
       per_person_types ppt,
       hr_soft_coding_keyflex hsck,
       per_jobs pj,
       hr_lookups hl
    where
       ppf.person_type_id = ppt.person_type_id and
       upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
       l_year_end between
         ppf.effective_start_date and
         ppf.effective_end_date and
       ppf.person_id = paf.person_id and
       l_year_end between
         paf.effective_start_date and
         paf.effective_end_date and
       paf.business_group_id = p_business_group_id and
       paf.primary_flag = 'Y' and
       paf.job_id = pj.job_id and
       pj.job_information_category = 'CA' and
       pj.job_information1 = hl.lookup_code and
       hl.lookup_type = 'EEOG' and
       (paf.employment_category is null OR
        substr(paf.employment_category,1,2) not in ('FR','PR','PT')
       ) and
       (
         (p_naic_code is not null and
            (
            (
               hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
               hsck.segment6 is not null and
               hsck.segment6 = p_naic_code
             )
             OR
             (
               hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
               hsck.segment6 is null and
               hsck.segment1 in (select segment3
                           from per_ca_ee_report_lines
                           where request_id = p_request_id and
                                 context = 'FORM13' and
                                 segment1 = 'NAIC' and
                                 segment2 = p_naic_code)
             )
             )

          ) -- End of p_naic_code is not null
          OR
          (p_naic_code is null and
             (
             (
               hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
               hsck.segment6 is not null and
               hsck.segment6 in (select segment3
                                  from  per_ca_ee_report_lines
                                  where request_id = p_request_id and
                                        context = 'FORM13' and
                                        segment1 = 'NAIC')
             )
             OR
             (
               hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
               hsck.segment6 is null and
               hsck.segment1 in (select segment3
                           from per_ca_ee_report_lines
                           where request_id = p_request_id and
                                 context = 'FORM13' and
                                 segment1 = 'NAIC')
              )
              )
           ) -- End od p_naic_code is null
           ) and
          exists
          (
          select 'X'
          from  per_pay_proposals_v2 pppv
          where pppv.business_group_id = p_business_group_id and
                pppv.assignment_id = paf.assignment_id and
                pppv.approved = 'Y' and
                pppv.change_date <=
                  decode(substr(paf.employment_category,1,2),
                             'PT',p_date_tmp_emp,l_year_end)
          ) -- End of exists
        ) -- End of from
        group by employment_category
        order by employment_category;

  cursor cur_province_cma(pc number) is
  select
    count(distinct paf.person_id) count_province_cma,
    hl1.meaning meaning
  from
    per_assignments_f paf,
    hr_locations hl,
    hr_lookups hl1,
    per_people_f ppf ,
    per_person_types ppt,
    per_jobs pj,
    hr_lookups hl2
  where
    upper(ltrim(rtrim(hl1.lookup_type)))=decode(pc,1,'CA_PROVINCE',
                                                   2,'CA_CMA')and
    upper(ltrim(rtrim(hl1.lookup_code)))
                           = decode(pc,1,upper(ltrim(rtrim(hl.region_1))),
                                       2,upper(ltrim(rtrim(hl.region_2)))) and
    hl.location_id=paf.location_id and
    p_date_all_emp between
      paf.effective_start_date and
      paf.effective_end_date  and
    paf.business_group_id=p_business_group_id and
    paf.primary_flag = 'Y' and
    paf.job_id = pj.job_id and
    pj.job_information_category = 'CA' and
    pj.job_information1 = hl2.lookup_code and
    hl2.lookup_type = 'EEOG' and
    paf.person_id=ppf.person_id and
    p_date_all_emp between
      ppf.effective_start_date and
      ppf.effective_end_date  and
    ppf.person_type_id=ppt.person_type_id and
    ppt.system_person_type='EMP' and
    exists
    (
    select 'X'
    from  per_pay_proposals_v2 pppv
    where pppv.business_group_id = p_business_group_id and
          pppv.assignment_id     = paf.assignment_id and
          pppv.approved          = 'Y' and
          pppv.change_date       <= l_year_end
    ) -- End of exists
  group by hl1.meaning;

  cursor cur_cma_notfound is
  select
    ltrim(rtrim(hl.meaning)) meaning
  from
    hr_lookups hl
  where
    hl.lookup_type='CA_CMA' and
    upper(ltrim(rtrim(hl.meaning))) in
          ('CALGARY','EDMONTON','HALIFAX','MONTREAL','REGINA','TORONTO',
            'VANCOUVER','WINNIPEG')
  minus
  select
    ltrim(rtrim(segment2))
  from
    per_ca_ee_report_lines
  where
    request_id=p_request_id and
    ltrim(rtrim(context))='FORM13' and
    ltrim(rtrim(segment1))='CMA';

  cursor cur_province_notfound is
  select
    ltrim(rtrim(hl.meaning)) meaning
  from
    hr_lookups hl
  where
    hl.lookup_type='CA_PROVINCE'
  minus
  select
    ltrim(rtrim(segment2))
  from
    per_ca_ee_report_lines
  where
    request_id=p_request_id and
    ltrim(rtrim(context))='FORM14' and
    ltrim(rtrim(segment1))='PROVINCE';
/*
  cursor cur_naic_person is
  select
    count(distinct paf.person_id) count_naic_person,
    hl.lookup_code lcode
  from
    hr_lookups hl,
    hr_soft_coding_keyflex  hsck ,
    hr_organization_information hoi,
    per_assignments_f  paf,
    per_people_f  ppf,
    per_person_types ppt,
    per_jobs pj,
    hr_lookups hl1
  where
    (
    (
     p_naic_code is not null and
     hl.lookup_type='NAIC' and
     (
     (
     hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
     hsck.segment6 is not null and
     hsck.segment6 = p_naic_code and
     hl.lookup_code = hsck.segment6
    )
     OR
     (
     hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
     hsck.segment6 is null and
     hoi.org_information8 is not null and
     hl.lookup_code=hoi.org_information8 and
     hoi.org_information8 = p_naic_code and
     hsck.segment1 = to_char(hoi.organization_id) and
     hoi.org_information_context = 'Canada Employer Identification'
     )
     )
    )
    OR
    (
       p_naic_code is null and
       hl.lookup_type='NAIC' and
       (
        (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is not null and
         hl.lookup_code = hsck.segment6
        )
        OR
        (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is null and
         hoi.org_information8 is not null and
         hl.lookup_code=hoi.org_information8 and
         hsck.segment1 = to_char(hoi.organization_id) and
         hoi.org_information_context = 'Canada Employer Identification'
        )
      )
    )
    ) and
    p_date_all_emp between
      paf.effective_start_date and
      paf.effective_end_date  and
    paf.business_group_id = p_business_group_id and
    paf.primary_flag = 'Y' and
    paf.job_id = pj.job_id and
    pj.job_information_category = 'CA' and
    pj.job_information1 = hl1.lookup_code and
    hl1.lookup_type = 'EEOG' and
    paf.person_id=ppf.person_id and
    p_date_all_emp between
      ppf.effective_start_date and
      ppf.effective_end_date  and
    ppf.person_type_id=ppt.person_type_id and
    ppt.system_person_type='EMP' and
    exists
    (
    select 'X'
    from  per_pay_proposals_v2 pppv
    where pppv.business_group_id = p_business_group_id and
          pppv.assignment_id     = paf.assignment_id and
          pppv.approved          = 'Y' and
          pppv.change_date       <= l_year_end
    ) -- End of exists
    group by hl.lookup_code
    order by 1 desc;
*/
  v_max_naic varchar2(1) := 'Y';

    cursor cur_hl_meaning(lc VARCHAR2) is
    select
      meaning
    from
      hr_lookups
    where
      lookup_type='NAIC' and
      lookup_code=lc;

    v_meaning       hr_lookups.meaning%TYPE;
    dummy           varchar2(1);

  cursor cur_legislation_info(p_lookup_type varchar2) is
  select
    pcli.lookup_code
  from
    pay_ca_legislation_info pcli
  where
    pcli.lookup_type = p_lookup_type;

  v_legislation_info		pay_ca_legislation_info.lookup_code%TYPE;
  v_print			varchar2(1);

  cursor cur_gre_id(p_naic varchar2) is
  select hou.organization_id
  from
    hr_organization_units hou,
    hr_organization_information hoi
  where
    hoi.organization_id = hou.organization_id   and
    hou.business_group_id = p_business_group_id and
    hoi.org_information_context = 'Canada Employer Identification' and
    hoi.org_information8 is not null and
    hoi.org_information8 = p_naic;

begin

	--hr_utility.trace_on(1,'pg');

  	open cur_org_info;
        fetch cur_org_info into
          v_name,
          v_address_line_1,
          v_address_line_2,
          v_address_line_3,
          v_town_or_city,
          v_region_1,
          v_postal_code,
          v_country,
          v_organization_id,
          v_short_name;
        close cur_org_info;

        insert into per_ca_ee_report_lines
        (   request_id,
            line_number,
            context,
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
      	    segment8,
            segment16) values
         ( p_request_id,
          per_ca_ee_extract_pkg.k,
          'FORM11',
    	  v_name,
          v_address_line_1,
          v_address_line_2,
    	  v_address_line_3,
          v_town_or_city,
          v_region_1,
          v_postal_code,
          v_country,
          v_short_name);

  for i in cur_employee_info loop

    update per_ca_ee_report_lines set
      segment9 =  i.ceo_name,          	-- CEO name
      segment10 = i.ceo_position,      	-- and his Position
      segment11 = i.contact_name,       -- EE relevant personnel
      segment12 = i.contact_position,   -- and his Position
      segment17 = i.contact_phone       -- and Phone Number
    where request_id = p_request_id and
          context = 'FORM11' and
          line_number = per_ca_ee_extract_pkg.k;
  end loop;

  -- The first NAIC will always have the maximum
  -- value as the cur_naic_person is ordered by
  -- count

  /* open  cur_legislation_info('EER1');
  fetch cur_legislation_info
      into  v_legislation_info;
  close cur_legislation_info; */

-- Calculate the employee totals for each naic
-- This improves performance by replacing the
-- cursor cur_naic_person

  calc_naic_totals (p_naic_code,
                    p_date_all_emp,
                    p_business_group_id,
                    p_year);

  IF v_sorted_naic.COUNT > 0 THEN

       FOR i IN v_sorted_naic.first..v_sorted_naic.last LOOP

--  for i in cur_naic_person loop

         per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

         open cur_hl_meaning(v_sorted_naic(i));
         fetch cur_hl_meaning into v_meaning;
         close cur_hl_meaning;

    /* if i.count_naic_person  > to_number(v_legislation_info) then
       v_max_naic := 'Y';
    else
       v_max_naic := 'N';
    end if;

    if i = 1 then
      v_max_naic := 'Y';
    end if; */

         insert into per_ca_ee_report_lines
         (
           request_id,
           line_number,
           context,
           segment1,
           segment2,
           segment3,
           segment4,
           segment5
          )
         values
         (
           p_request_id,
           per_ca_ee_extract_pkg.k,
           'FORM12',
           'NAIC',
           v_meaning,
--      i.count_naic_person,
--      i.lcode,
           v_sorted_naic_count(i),
           v_sorted_naic(i),
           v_max_naic
          );

         v_max_naic := 'N';

         for gre_id in cur_gre_id(v_sorted_naic(i)) loop

         insert into per_ca_ee_report_lines
         (
           request_id,
           line_number,
           context,
           segment1,
           segment2,
           segment3
          )
         values
         (
           p_request_id,
           per_ca_ee_extract_pkg.k,
           'FORM13',
           'NAIC',
--      i.lcode,
           v_sorted_naic(i),
           gre_id.organization_id
         );

        end loop; -- End loop GRE ID

        END LOOP; -- End loop cur_naic_person

   END IF;

   for i in cur_employment_category
   loop

   if i.employment_category = 'FR' then

      update per_ca_ee_report_lines set
        segment13 = i.count_category
      where request_id = p_request_id and
         --line_number = per_ca_ee_extract_pkg.k and
         context = 'FORM11';

   elsif i.employment_category = 'PR' then

     update per_ca_ee_report_lines set
       segment14 = i.count_category
     where request_id = p_request_id and
       --line_number = per_ca_ee_extract_pkg.k and
       context = 'FORM11';


    elsif i.employment_category = 'PT' then

     hr_utility.trace('Form1: Employment Category: ' || i.employment_category);

      update per_ca_ee_report_lines set
        segment15 = i.count_category
      where request_id = p_request_id and
        --line_number = per_ca_ee_extract_pkg.k and
        context = 'FORM11';

    end if;

    end loop; -- End loop cur_emplyment_category


  for i  in 1..2 loop

    for l in  cur_province_cma(i) loop

    per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

    open  cur_legislation_info('EER2');
    fetch cur_legislation_info
      into  v_legislation_info;
    close cur_legislation_info;

    if l.count_province_cma >= to_number(v_legislation_info) then
      v_print := 'Y';
    else
      v_print := 'N';
    end if;

    insert into per_ca_ee_report_lines
         (request_id,
         line_number,
         context,
         segment1,
         segment2,
         segment3,
         segment4) values
         (p_request_id,
         per_ca_ee_extract_pkg.k,
         decode(i,1,'FORM14',2,'FORM13'),
         decode(i,1,'PROVINCE',2,'CMA'),
         l.meaning,
         l.count_province_cma,
	 v_print);

    end loop; -- End loop cur_cma_province

  end loop; -- End loop CMA/Province

  for i in cur_cma_notfound loop

    per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

    insert into per_ca_ee_report_lines
      (request_id,
       line_number,
       context,
       segment1,
       segment2,
       segment3,
       segment4) values
       (p_request_id,
       per_ca_ee_extract_pkg.k,
       'FORM13',
       'CMA',
       i.meaning,
       0,
       'N');

  end loop;

  for i in cur_province_notfound loop

    per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

    insert into per_ca_ee_report_lines
      (request_id,
      line_number,
      context,
      segment1,
      segment2,
      segment3,
      segment4) values
     (p_request_id,
      per_ca_ee_extract_pkg.k,
      'FORM14',
      'PROVINCE',
      i.meaning,
      0,
      'N');

  end loop;

  return 1;

end;

end form1;


 function form2n(p_business_group_id in number,
               p_request_id     in number,
               p_year           in varchar2,
               p_date_tmp_emp   in date) return number is

  --l_year_start date;
  l_year_end date;

begin

  --l_year_start :=  trunc(to_date(p_year,'YYYY'),'Y');
  l_year_end   :=  add_months(trunc(to_date(p_year,'YYYY'),'Y'), 12) -1;

declare

  cursor cur_legislation_info(p_lookup_type varchar2) is
  select lookup_code
  from   pay_ca_legislation_info
  where  lookup_type = p_lookup_type;

  v_leg_info		pay_ca_legislation_info.lookup_code%TYPE;

  cursor cur_naic is
  select
    pert.segment3       tot_number_emp,
    pert.segment4	naic_code,
    pert.segment5       max_naic_flag
  from
    per_ca_ee_report_lines	pert
  where
    pert.request_id = p_request_id and
    --(pert.segment5 = 'Y' OR
    -- to_number(pert.segment3) >= to_number(v_leg_info)) and
    pert.context = 'FORM12' ;

  v_tot_number_emp      per_ca_ee_report_lines.segment3%TYPE;
  v_naic_code		hr_lookups.lookup_code%TYPE;
  v_max_naic_flag	varchar2(1);

  cursor cur_min_max is select
    max(max_salary)		max_salary,
    min(min_salary)		min_salary,
    meaning			meaning,
    employment_category		employment_category
  from
  (
  select
    trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor
                                                               max_salary,
    trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor
                                                               min_salary,
    hl.meaning meaning,
    substr(paf.employment_category,1,2) employment_category
  from
    hr_lookups hl,
    per_jobs pj,
    per_pay_proposals_v2 pppv,
    per_people_f ppf,
    per_assignments_f paf,
    per_person_types ppt,
    hr_soft_coding_keyflex  hsck,
    per_pay_bases ppb
  where
    hl.lookup_type='EEOG' and
    hl.lookup_code=pj.job_information1 and
    pj.job_information_category='CA' and
    pj.job_id=paf.job_id and
    paf.primary_flag = 'Y' and
    decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      paf.effective_start_date and
      paf.effective_end_date  and
    paf.pay_basis_id      = ppb.pay_basis_id and
    ppb.business_group_id = p_business_group_id and
    paf.person_id=ppf.person_id and
    paf.assignment_id=pppv.assignment_id and
    pppv.change_date = (select max(pppv2.change_date)
                         from   per_pay_proposals_v2 pppv2
                         where  pppv2.assignment_id = paf.assignment_id
                         and    pppv2.change_date <=
       				decode(substr(paf.employment_category,1,2),
                                          'PT',p_date_tmp_emp,l_year_end)
                        ) and
    ppf.person_type_id=ppt.person_type_id and
    decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      ppf.effective_start_date and
      ppf.effective_end_date  and
    upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
    ppf.business_group_id=p_business_group_id and
    paf.employment_category is not null and
    paf.employment_category in ('FR','PR','PT') and
    (
    (
    hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
    hsck.segment6 is not null and
    hsck.segment6 = v_naic_code OR
    hsck.segment6 in ( select segment4
                       from per_ca_ee_report_lines
                       where request_id = p_request_id and
                       context = 'FORM12' and
                       to_number(segment3) <= to_number(v_leg_info) and
                       v_max_naic_flag = 'Y')
    )
    OR
    (
    hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
    hsck.segment6 is null and
    hsck.segment1 in (select segment3
                           from per_ca_ee_report_lines
			   where request_id = p_request_id and
			         context = 'FORM13' and
			         segment1 = 'NAIC' and
			         segment2 = v_naic_code OR
 				 segment2 in
 				   ( select segment4
                                     from per_ca_ee_report_lines
                                     where request_id = p_request_id and
                                     context = 'FORM12' and
                                     to_number(segment3)
                                            <= to_number(v_leg_info) and
                                     v_max_naic_flag = 'Y')
                     )
    )
    )
  union all
  select
    trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor
                                                               max_salary,
    trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor
                                                               min_salary,
    hl.meaning meaning,
    'FR' employment_category
  from
    hr_lookups hl,
    per_jobs pj,
    per_pay_proposals_v2 pppv,
    per_people_f ppf,
    per_assignments_f paf,
    per_person_types ppt,
    hr_soft_coding_keyflex  hsck,
    per_pay_bases ppb
  where
    hl.lookup_type='EEOG' and
    hl.lookup_code=pj.job_information1 and
    pj.job_information_category='CA' and
    pj.job_id=paf.job_id and
    paf.primary_flag = 'Y' and
    l_year_end between
      paf.effective_start_date and
      paf.effective_end_date   and
    paf.pay_basis_id      = ppb.pay_basis_id and
    ppb.business_group_id = p_business_group_id and
    paf.person_id=ppf.person_id and
    paf.assignment_id=pppv.assignment_id and
    pppv.change_date = (select max(pppv2.change_date)
                         from   per_pay_proposals_v2 pppv2
                         where  pppv2.assignment_id = paf.assignment_id
                         and    pppv2.change_date <= l_year_end
                        ) and
    ppf.person_type_id=ppt.person_type_id and
    l_year_end between
      ppf.effective_start_date and
      ppf.effective_end_date   and
    upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
    ppf.business_group_id=p_business_group_id and
    ( paf.employment_category is null OR
      paf.employment_category not in ('FR','PR','PT')
     ) and
    (
    (
    hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
    hsck.segment6 is not null and
    hsck.segment6 = v_naic_code OR
    hsck.segment6 in ( select segment4
                       from per_ca_ee_report_lines
                       where request_id = p_request_id and
                       context = 'FORM12' and
                       to_number(segment3) <= to_number(v_leg_info) and
                       v_max_naic_flag = 'Y')
    )
    OR
    (
    hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
    hsck.segment6 is null and
    hsck.segment1 in   (select segment3
                       from per_ca_ee_report_lines
		       where request_id = p_request_id and
		       context = 'FORM13' and
		         segment1 = 'NAIC' and
		         segment2 = v_naic_code OR
 			 segment2 in
 			   ( select segment4
                             from per_ca_ee_report_lines
                             where request_id = p_request_id and
                             context = 'FORM12' and
                             to_number(segment3)
                             <= to_number(v_leg_info) and
                              v_max_naic_flag = 'Y')
                       )
    )
    )
  )
  group by meaning,employment_category
  order by meaning,employment_category;

  v_max_salary    		number;
  v_min_salary    		number;
  v_meaning   			hr_lookups.meaning%TYPE;
  v_employment_category   	per_assignments_f.employment_category%TYPE;

  j_flag      varchar2(1) := 'F';

  v_range     number;
  v_q1_min    number;
  v_q1_max    number;
  v_q2_min    number;
  v_q2_max    number;
  v_q3_min    number;
  v_q3_max    number;
  v_q4_min    number;
  v_q4_max    number;

  v_max_salary_range_min  number;
  v_max_salary_range_max  number;
  v_min_salary_range_min  number;
  v_min_salary_range_max  number;

  cursor cur_count_total(i_range number)is select
    count(distinct paf.person_id) count_total,
    ppf.sex
  from
    hr_lookups hl,
    per_jobs pj,
    per_assignments_f paf,
    per_people_f ppf,
    per_pay_proposals_v2 pppv,
    per_person_types ppt,
    hr_soft_coding_keyflex  hsck,
    per_pay_bases ppb
  where
    hl.lookup_type='EEOG' and
    upper(ltrim(rtrim(hl.meaning)))=upper(ltrim(rtrim(v_meaning))) and
    upper(ltrim(rtrim(hl.lookup_code)))
                  = upper(ltrim(rtrim(pj.job_information1))) and
    upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
    pj.job_id=paf.job_id and
    paf.primary_flag = 'Y' and
    decode(substr(NVL(paf.employment_category,'FR'),1,2),
           'FR','FR','PR','PR','PT','PT','FR')
               = ltrim(rtrim(v_employment_category)) and
    decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      paf.effective_start_date and
      paf.effective_end_date  and
    paf.person_id=ppf.person_id and
    ppf.person_type_id=ppt.person_type_id and
    decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      ppf.effective_start_date and
      ppf.effective_end_date  and
    paf.pay_basis_id      = ppb.pay_basis_id and
    ppb.business_group_id = p_business_group_id and
    paf.person_id=ppf.person_id and
    upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
    ppf.business_group_id=p_business_group_id and
    paf.assignment_id=pppv.assignment_id and
    pppv.change_date = (select max(pppv2.change_date)
                         from   per_pay_proposals_v2 pppv2
                         where  pppv2.assignment_id = paf.assignment_id
                         and    pppv2.change_date <=
       				decode(substr(paf.employment_category,1,2),
                                          'PT',p_date_tmp_emp,l_year_end)
                        ) and
    trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor >=
         decode(i_range,1,v_q1_min,
                        2,v_q2_min,
                        3,v_q3_min,
                        4,v_q4_min) and
    trunc(to_number(pppv.proposed_salary))  * ppb.pay_annualization_factor <=
         decode(i_range,1,v_q1_max,
                        2,v_q2_max,
                        3,v_q3_max,
                        4,v_q4_max) and
    (
    (
    hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
    hsck.segment6 is not null and
    hsck.segment6 = v_naic_code OR
    hsck.segment6 in ( select segment4
                       from per_ca_ee_report_lines
                       where request_id = p_request_id and
                       context = 'FORM12' and
                       to_number(segment3) <= to_number(v_leg_info) and
                       v_max_naic_flag = 'Y')
    )
    OR
    (
    hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
    hsck.segment6 is null and
    hsck.segment1 in (select segment3
                           from per_ca_ee_report_lines
			   where request_id = p_request_id and
			         context = 'FORM13' and
			         segment1 = 'NAIC' and
			         segment2 = v_naic_code OR
                                 segment2 in
                                 ( select segment4
                                   from per_ca_ee_report_lines
                                   where request_id = p_request_id and
                                   context = 'FORM12' and
                                   to_number(segment3)
                                   <= to_number(v_leg_info) and
                                    v_max_naic_flag = 'Y')
                     )
    )
    )
    group by ppf.sex
    order by ppf.sex;

  v_count       		number(10);
  v_sex       			per_people_f.sex%TYPE;
  prev_employment_category  	per_assignments_f.employment_category%TYPE;
  prev_sex      		per_people_f.sex%TYPE;
  prev_j        		number := 0;
  prev_naic_code                hr_lookups.lookup_code%TYPE;
  prev_meaning   	        hr_lookups.meaning%TYPE;

  cursor cur_count(range number,
                  desig number) is
  select
    count(distinct paf.person_id) count,
    ppf.sex
  from
    hr_lookups hl,
    per_jobs pj,
    per_assignments_f paf,
    per_people_f ppf,
    per_pay_proposals_v2 pppv,
    per_person_types ppt,
    hr_soft_coding_keyflex  hsck,
    per_pay_bases ppb
  where
    hl.lookup_type='EEOG' and
    upper(ltrim(rtrim(hl.meaning))) = upper(ltrim(rtrim(v_meaning))) and
    upper(ltrim(rtrim(hl.lookup_code)))
           = upper(ltrim(rtrim(pj.job_information1))) and
    upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
    pj.job_id=paf.job_id and
    paf.primary_flag = 'Y' and
    paf.pay_basis_id = ppb.pay_basis_id and
    decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      paf.effective_start_date and
      paf.effective_end_date  and
    paf.person_id=ppf.person_id and
    ppf.person_type_id=ppt.person_type_id and
    decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      ppf.effective_start_date and
      ppf.effective_end_date  and
    upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
    ppf.business_group_id=p_business_group_id and
    decode(desig,1,per_information5,
        2,per_information6,
        3,per_information7)='Y' and
    --substr(NVL(paf.employment_category,'FR'),1,2)=v_employment_category and
    decode(substr(NVL(paf.employment_category,'FR'),1,2),
           'FR','FR','PR','PR','PT','PT','FR') = v_employment_category and
    paf.assignment_id=pppv.assignment_id and
    pppv.change_date = (select max(pppv2.change_date)
                         from   per_pay_proposals_v2 pppv2
                         where  pppv2.assignment_id = paf.assignment_id
                         and    pppv2.change_date <=
       				decode(substr(paf.employment_category,1,2),
                                          'PT',p_date_tmp_emp,l_year_end)
                        ) and
    trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor
      >= decode(range,1,v_q1_min,
                      2,v_q2_min,
                      3,v_q3_min,
                      4,v_q4_min) and
    trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor
      <= decode(range,1,v_q1_max,
                      2,v_q2_max,
                      3,v_q3_max,
                      4,v_q4_max) and
    (
    (
    hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
    hsck.segment6 is not null and
    hsck.segment6 = v_naic_code OR
    hsck.segment6 in ( select segment4
                       from per_ca_ee_report_lines
                       where request_id = p_request_id and
                       context = 'FORM12' and
                       to_number(segment3) <= to_number(v_leg_info) and
                       v_max_naic_flag = 'Y')

    )
    OR
    (
    hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
    hsck.segment6 is null and
    hsck.segment1 in 	   (select segment3
                           from per_ca_ee_report_lines
			   where request_id = p_request_id and
			         context = 'FORM13' and
			         segment1 = 'NAIC' and
			         segment2 = v_naic_code OR
                                 segment2 in
                                 ( select segment4
                                   from per_ca_ee_report_lines
                                   where request_id = p_request_id and
                                   context = 'FORM12' and
                                   to_number(segment3)
                                   <= to_number(v_leg_info) and
                                    v_max_naic_flag = 'Y')
                           )
    )
    )
    group by ppf.sex
    order by ppf.sex;

begin

  open cur_legislation_info('EER1');
  fetch cur_legislation_info
  into  v_leg_info;
  close cur_legislation_info;

  for naic in cur_naic loop

    v_tot_number_emp    := naic.tot_number_emp;
    v_naic_code 	:= naic.naic_code;
    v_max_naic_flag 	:= naic.max_naic_flag;

  if ( ( v_max_naic_flag = 'Y' ) OR
     (to_number(v_tot_number_emp) >= to_number(v_leg_info)) ) then

  hr_utility.trace('Form2n starts Here !!!!!!!');

  for i in cur_min_max loop

    v_max_salary := nvl(to_number(i.max_salary),0);
    v_min_salary := nvl(to_number(i.min_salary),0);
    v_meaning    := i.meaning;
    v_employment_category := i.employment_category;

    hr_utility.trace('Form2: v_max_salary: ' || to_char(v_max_salary));
    hr_utility.trace('Form2: v_min_salary: ' || to_char(v_min_salary));
    hr_utility.trace('Form2: v_meaning: ' || v_meaning);
    hr_utility.trace('Form2: v_employment_category: '||v_employment_category);

    -- To check the salary range in the predefined
    -- salary ranges

    if v_max_salary >= 0 and v_max_salary < 5000 then

       v_max_salary_range_min := 0;
       v_max_salary_range_max := 5000;

    elsif v_max_salary >= 5000 and v_max_salary <= 9999 then

       v_max_salary_range_min := 5000;
       v_max_salary_range_max := 9999;

    elsif v_max_salary >= 10000 and v_max_salary <= 14999 then

       v_max_salary_range_min := 10000;
       v_max_salary_range_max := 14999;

    elsif v_max_salary >= 15000 and v_max_salary <= 19999 then

       v_max_salary_range_min := 15000;
       v_max_salary_range_max := 19999;

    elsif v_max_salary >= 20000 and v_max_salary <= 24999 then

       v_max_salary_range_min := 20000;
       v_max_salary_range_max := 24999;

    elsif v_max_salary >= 25000 and v_max_salary <= 29999 then

       v_max_salary_range_min := 25000;
       v_max_salary_range_max := 29999;

    elsif v_max_salary >= 30000 and v_max_salary <= 34999 then

       v_max_salary_range_min := 30000;
       v_max_salary_range_max := 34999;

    elsif v_max_salary >= 35000 and v_max_salary <= 39999 then

       v_max_salary_range_min := 35000;
       v_max_salary_range_max := 39999;

    elsif v_max_salary >= 40000 and v_max_salary <= 44999 then

       v_max_salary_range_min := 40000;
       v_max_salary_range_max := 44999;

    elsif v_max_salary >= 45000 and v_max_salary <= 49999 then

       v_max_salary_range_min := 45000;
       v_max_salary_range_max := 49999;

    elsif v_max_salary >= 50000 and v_max_salary <= 54999 then

       v_max_salary_range_min := 50000;
       v_max_salary_range_max := 54999;

    elsif v_max_salary >= 55000 and v_max_salary <= 59999 then

       v_max_salary_range_min := 55000;
       v_max_salary_range_max := 59999;

    elsif v_max_salary >= 60000 and v_max_salary <= 64999 then

       v_max_salary_range_min := 60000;
       v_max_salary_range_max := 64999;

    elsif v_max_salary >= 65000 and v_max_salary <= 69999 then

       v_max_salary_range_min := 65000;
       v_max_salary_range_max := 69999;

    elsif v_max_salary >= 70000 and v_max_salary <= 74999 then

       v_max_salary_range_min := 70000;
       v_max_salary_range_max := 74999;

    elsif v_max_salary >= 75000 and v_max_salary <= 79999 then

       v_max_salary_range_min := 75000;
       v_max_salary_range_max := 79999;

    elsif v_max_salary >= 80000 and v_max_salary <= 84999 then

       v_max_salary_range_min := 80000;
       v_max_salary_range_max := 84999;

    elsif v_max_salary >= 85000 and v_max_salary <= 89999 then

       v_max_salary_range_min := 85000;
       v_max_salary_range_max := 89999;

    elsif v_max_salary >= 90000 and v_max_salary <= 94999 then

       v_max_salary_range_min := 90000;
       v_max_salary_range_max := 94999;

    elsif v_max_salary >= 95000 and v_max_salary <= 99999 then

       v_max_salary_range_min := 95000;
       v_max_salary_range_max := 99999;

    elsif v_max_salary > 100000 then
       v_max_salary_range_min := 100000;
       v_max_salary_range_max := 9999999;

    end if ;

    if v_min_salary >= 0 and v_min_salary < 5000 then

       v_min_salary_range_min := 0;
       v_min_salary_range_max := 5000;

    elsif v_min_salary >= 5000 and v_min_salary <= 9999 then

       v_min_salary_range_min := 5000;
       v_min_salary_range_max := 9999;

    elsif v_min_salary >= 10000 and v_min_salary <= 14999 then

       v_min_salary_range_min := 10000;
       v_min_salary_range_max := 14999;

    elsif v_min_salary >= 15000 and v_min_salary <= 19999 then

       v_min_salary_range_min := 15000;
       v_min_salary_range_max := 19999;

    elsif v_min_salary >= 20000 and v_min_salary <= 24999 then

       v_min_salary_range_min := 20000;
       v_min_salary_range_max := 24999;

    elsif v_min_salary >= 25000 and v_min_salary <= 29999 then

       v_min_salary_range_min := 25000;
       v_min_salary_range_max := 29999;

    elsif v_min_salary >= 30000 and v_min_salary <= 34999 then

       v_min_salary_range_min := 30000;
       v_min_salary_range_max := 34999;

    elsif v_min_salary >= 35000 and v_min_salary <= 39999 then

       v_min_salary_range_min := 35000;
       v_min_salary_range_max := 39999;

    elsif v_min_salary >= 40000 and v_min_salary <= 44999 then

       v_min_salary_range_min := 40000;
       v_min_salary_range_max := 44999;

    elsif v_min_salary >= 45000 and v_min_salary <= 49999 then

       v_min_salary_range_min := 45000;
       v_min_salary_range_max := 49999;

    elsif v_min_salary >= 50000 and v_min_salary <= 54999 then

       v_min_salary_range_min := 50000;
       v_min_salary_range_max := 54999;

    elsif v_min_salary >= 55000 and v_min_salary <= 59999 then

       v_min_salary_range_min := 55000;
       v_min_salary_range_max := 59999;

    elsif v_min_salary >= 60000 and v_min_salary <= 64999 then

       v_min_salary_range_min := 60000;
       v_min_salary_range_max := 64999;

    elsif v_min_salary >= 65000 and v_min_salary <= 69999 then

       v_min_salary_range_min := 65000;
       v_min_salary_range_max := 69999;

    elsif v_min_salary >= 70000 and v_min_salary <= 74999 then

       v_min_salary_range_min := 70000;
       v_min_salary_range_max := 74999;

    elsif v_min_salary >= 75000 and v_min_salary <= 79999 then

       v_min_salary_range_min := 75000;
       v_min_salary_range_max := 79999;

    elsif v_min_salary >= 80000 and v_min_salary <= 84999 then

       v_min_salary_range_min := 80000;
       v_min_salary_range_max := 84999;

    elsif v_min_salary >= 85000 and v_min_salary <= 89999 then

       v_min_salary_range_min := 85000;
       v_min_salary_range_max := 89999;

    elsif v_min_salary >= 90000 and v_min_salary <= 94999 then

       v_min_salary_range_min := 90000;
       v_min_salary_range_max := 94999;

    elsif v_min_salary >= 95000 and v_min_salary <= 99999 then

       v_min_salary_range_min := 95000;
       v_min_salary_range_max := 99999;

    elsif v_min_salary > 100000 then

       v_min_salary_range_min := 100000;
       v_min_salary_range_max := 9999999;

    end if;

    v_range := (nvl(v_max_salary,0)-nvl(v_min_salary,0))/4;

    v_q1_min := nvl(v_min_salary,0);
    v_q1_max := v_q1_min + v_range;

    v_q2_min := v_q1_max + 1;
    v_q2_max := v_q2_min + v_range - 1;

    v_q3_min := v_q2_max + 1;
    v_q3_max := v_q3_min + v_range - 1;

    v_q4_min := v_q3_max + 1;
    v_q4_max := v_q4_min + v_range -1;

    hr_utility.trace('Form2: v_q1_min: ' ||to_char(v_q1_min));
    hr_utility.trace('Form2: v_q1_max: ' ||to_char(v_q1_max));
    hr_utility.trace('Form2: v_q2_min: ' ||to_char(v_q2_min));
    hr_utility.trace('Form2: v_q2_max: ' ||to_char(v_q2_max));
    hr_utility.trace('Form2: v_q3_min: ' ||to_char(v_q3_min));
    hr_utility.trace('Form2: v_q3_max: ' ||to_char(v_q3_max));
    hr_utility.trace('Form2: v_q4_min: ' ||to_char(v_q4_min));
    hr_utility.trace('Form2: v_q4_max: ' ||to_char(v_q4_max));

    for j in 1..4 loop

      j_flag := 'F';

      for l in cur_count_total(j) loop

      v_count := l.count_total;
      v_sex   := l.sex;

      hr_utility.trace('Form2n: '
                              ||'EEOG ' || v_meaning
                              ||'j = '  || to_char(j)
                              ||'v_count = ' || to_char(v_count)
                              ||'v_emp_cat = '|| v_employment_category
                              ||'v_sex = ' || v_sex);
      if (
          (ltrim(rtrim(prev_employment_category)) <>
				ltrim(rtrim(v_employment_category))) or
          (ltrim(rtrim(prev_naic_code)) <> ltrim(rtrim(v_naic_code))) or
          (ltrim(rtrim(prev_meaning))   <> ltrim(rtrim(v_meaning))) or
          (prev_j <> j)
        )  then

        per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

         hr_utility.trace('If .....');

        insert into per_ca_ee_report_lines
        ( request_id,
         line_number,
         context,
         segment1,
         segment2,
         segment3,
         segment4,
         segment5,
         segment6,
         segment7,
         segment8,
         segment9,
         segment10,
         segment11,
         segment12,
         segment13,
         segment14,
         segment15,
         segment16,
         segment17,
	 segment21) values
         (p_request_id,
         per_ca_ee_extract_pkg.k,
         'FORM2',
         'NATIONAL',
         v_meaning,
         v_employment_category,
         v_min_salary_range_min||'..'||
         v_min_salary_range_max||'  '||
         v_max_salary_range_min||'..'||
         v_max_salary_range_max,
         to_char(j),
         nvl(v_count,0),
         decode(v_sex,'F',v_count,0),
         decode(v_sex,'M',v_count,0),
         '0',
         '0',
         '0',
         '0',
         '0',
         '0',
         '0',
         '0',
         '0',
	 v_naic_code);

         j_flag := 'T';

       else

         hr_utility.trace('else prev_employment_category ' || prev_employment_category);

         if prev_employment_category = v_employment_category and
            prev_naic_code = v_naic_code and
            prev_meaning   = v_meaning and
            prev_sex <> v_sex then

            hr_utility.trace('Inside ........');
           if v_sex = 'M' then

            hr_utility.trace('Update Male');

            update per_ca_ee_report_lines set
              segment6=segment6 + nvl(v_count,0),
              segment8=nvl(v_count,0)
            where request_id=p_request_id and
              line_number=per_ca_ee_extract_pkg.k and
              segment1='NATIONAL' and
              segment21 = v_naic_code;

           elsif v_sex = 'F' then

            hr_utility.trace('Update Female');

            update per_ca_ee_report_lines set
              segment6=segment6 + nvl(v_count,0),
              segment7=nvl(v_count,0)
            where request_id=p_request_id and
              line_number=per_ca_ee_extract_pkg.k and
              segment1='NATIONAL' and
              segment21 = v_naic_code;

          end if;
        end if;
      end if;

      prev_employment_category := v_employment_category;
      prev_naic_code := v_naic_code;
      prev_sex := v_sex;
      prev_meaning := v_meaning;
      prev_j := j;

    end loop;

    if j_flag = 'F' then

      per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

    insert into per_ca_ee_report_lines
    ( request_id,
     line_number,
     context,
     segment1,
     segment2,
     segment3,
     segment4,
     segment5,
     segment6,
     segment7,
     segment8,
     segment9,
     segment10,
     segment11,
     segment12,
     segment13,
     segment14,
     segment15,
     segment16,
     segment17,
     segment21) values
     (p_request_id,
     per_ca_ee_extract_pkg.k,
     'FORM2',
     'NATIONAL',
     v_meaning,
     v_employment_category,
     v_min_salary_range_min||'..'||
     v_min_salary_range_max||'  '||
     v_max_salary_range_min||'..'||
     v_max_salary_range_max,
     to_char(j),
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     v_naic_code);

    j_flag := 'T';

    end if ;

    end loop;
  ---------------------------------
  -- Updation designated Group   --
  ---------------------------------

  hr_utility.trace('Form2n: Before updation of designated Group');
  hr_utility.trace('Form2n: Before updation of desig Grp: v_meaning: '
                            || v_meaning);

  for j in 1..4 loop

    for k in 1..3 loop

    for l in cur_count(j,k) loop

      hr_utility.trace('Form2n: Updation of designated Group');

      if k = 1 then

        if l.sex = 'F' then

        update per_ca_ee_report_lines set
          segment9=nvl(segment9,0) + nvl(l.count,0),
          segment10=nvl(l.count,0)
        where
          request_id=p_request_id and
          context='FORM2' and
          segment1='NATIONAL' and
          upper(ltrim(rtrim(segment2)))=upper(ltrim(rtrim(v_meaning))) and
          upper(ltrim(rtrim(segment3)))
               =upper(ltrim(rtrim(v_employment_category))) and
          segment5=to_char(j) and
          segment21 = v_naic_code;

        elsif l.sex = 'M' then

        update per_ca_ee_report_lines set
          segment9=nvl(segment9,0) + nvl(l.count,0),
          segment11=nvl(l.count,0)
        where
          request_id=p_request_id and
          context='FORM2' and
          segment1='NATIONAL' and
          upper(ltrim(rtrim(segment2))) = upper(ltrim(rtrim(v_meaning))) and
          upper(ltrim(rtrim(segment3))) =
                   upper(ltrim(rtrim(v_employment_category))) and
          segment5=to_char(j) and
          segment21 = v_naic_code;

        end if;

      elsif k = 2 then

        if l.sex = 'F' then

        update per_ca_ee_report_lines set
          segment12=nvl(segment12,0) + nvl(l.count,0),
          segment13=nvl(l.count,0)
        where
         request_id=p_request_id and
         context='FORM2' and
         segment1='NATIONAL' and
         upper(ltrim(rtrim(segment2)))
           =upper(ltrim(rtrim(v_meaning))) and
         upper(ltrim(rtrim(segment3)))
           =upper(ltrim(rtrim(v_employment_category))) and
        segment5=to_char(j) and
        segment21 = v_naic_code;

      else

        update per_ca_ee_report_lines set
          segment12=nvl(segment12,0) + nvl(l.count,0),
          segment14=nvl(l.count,0)
        where
          request_id=p_request_id and
          context='FORM2' and
          segment1='NATIONAL' and
          upper(ltrim(rtrim(segment2)))=upper(ltrim(rtrim(v_meaning))) and
          upper(ltrim(rtrim(segment3)))=upper(ltrim(rtrim(v_employment_category))) and
          segment5  =to_char(j) and
          segment21 = v_naic_code;
        end if;

      elsif k = 3 then

        if l.sex = 'F' then
          update per_ca_ee_report_lines set
            segment15=nvl(segment15,0) + nvl(l.count,0),
            segment16=nvl(l.count,0)
          where
            request_id=p_request_id and
            context = 'FORM2' and
            segment1 = 'NATIONAL' and
            upper(ltrim(rtrim(segment2))) = upper(ltrim(rtrim(v_meaning))) and
            upper(ltrim(rtrim(segment3)))
		= upper(ltrim(rtrim(v_employment_category))) and
            segment5  = to_char(j) and
            segment21 = v_naic_code;
       else
         update per_ca_ee_report_lines set
           segment15=nvl(segment15,0) + nvl(l.count,0),
          segment17=nvl(l.count,0)
         where
          request_id=p_request_id and
          context='FORM2' and
          segment1='NATIONAL' and
          upper(ltrim(rtrim(segment2))) =
                upper(ltrim(rtrim(v_meaning))) and
          upper(ltrim(rtrim(segment3)))
		= upper(ltrim(rtrim(v_employment_category))) and
          segment5=to_char(j) and
          segment21 = v_naic_code;

        end if;

      end if;
    end loop;
    end loop;
  end loop;

  end loop;

  prev_naic_code := v_naic_code;

  end if; -- if v_max_naic_code = Y or segment3 greater than v_leg_info.

  end loop; -- End loop cur_naic

return 1;
end;

end form2n;


function form2(p_business_group_id in number,
               p_request_id     in number,
               p_year           in varchar2,
               p_date_tmp_emp   in date) return number is

  --l_year_start date;
  l_year_end date;

begin

  --l_year_start :=  trunc(to_date(p_year,'YYYY'),'Y');
  l_year_end   :=  add_months(trunc(to_date(p_year,'YYYY'),'Y'), 12) -1;

declare

  cursor cur_legislation_info(p_lookup_type varchar2) is
  select lookup_code
  from   pay_ca_legislation_info
  where  lookup_type = p_lookup_type;

  v_leg_info		pay_ca_legislation_info.lookup_code%TYPE;

  cursor cur_naic is
  select
    pert.segment3       tot_number_emp,
    pert.segment4	naic_code,
    pert.segment5       max_naic_flag
  from
    per_ca_ee_report_lines	pert
  where
    pert.request_id = p_request_id and
    --(pert.segment5 = 'Y' OR
    -- to_number(pert.segment3) >= to_number(v_leg_info)) and
    pert.context = 'FORM12' ;

  v_tot_number_emp      per_ca_ee_report_lines.segment3%TYPE;
  v_naic_code		hr_lookups.lookup_code%TYPE;
  v_max_naic_flag	varchar2(1);

  cursor cur_min_max(cma_province_count number) is
  select
    max(max_salary) 		max_salary,
    min(min_salary) 		min_salary,
    meaning 			meaning,
    employment_category		employment_category,
    cma_province		cma_province
  from
  (
    select
      trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor
                                                max_salary,
      trunc(to_number(pppv.proposed_salary))  * ppb.pay_annualization_factor 								min_salary,
      hl.meaning 				meaning,
      substr(paf.employment_category,1,2) 	employment_category,
      decode(cma_province_count,1,hl1.region_1
           ,2,hl1.region_2) 			cma_province
    from
      hr_lookups hl,
      per_jobs pj,
      per_pay_proposals_v2 pppv,
      per_people_f ppf,
      per_assignments_f paf,
      hr_locations hl1,
      per_person_types ppt,
      per_ca_ee_report_lines pert,
      hr_lookups hl2,
      hr_soft_coding_keyflex  hsck,
      per_pay_bases ppb
    where
      hl.lookup_type='EEOG' and
      hl.lookup_code=pj.job_information1 and
      pj.job_information_category='CA' and
      pj.job_id=paf.job_id and
      paf.primary_flag = 'Y' and
     decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      paf.effective_start_date and
      paf.effective_end_date  and
      paf.employment_category is not null and
      paf.employment_category in ('FR','PR','PT') and
      paf.pay_basis_id = ppb.pay_basis_id and
      ppb.business_group_id = p_business_group_id and
      paf.person_id=ppf.person_id and
     decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      ppf.effective_start_date and
      ppf.effective_end_date  and
      paf.assignment_id=pppv.assignment_id and
      pppv.change_date = (select max(pppv2.change_date)
                         from   per_pay_proposals_v2 pppv2
                         where  pppv2.assignment_id = paf.assignment_id
                         and    pppv2.change_date <=
       				decode(substr(paf.employment_category,1,2),
                                          'PT',p_date_tmp_emp,l_year_end)
                        ) and
      paf.location_id=hl1.location_id and
      ppf.person_type_id=ppt.person_type_id and
      upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
      ppf.business_group_id=p_business_group_id and
      hl2.lookup_type=decode(cma_province_count,1,'CA_PROVINCE'
        					,2,'CA_CMA') and
      hl2.lookup_code=decode(cma_province_count,1,hl1.region_1
        					,2,hl1.region_2) and
      --pert.segment4  = 'Y' and
      pert.request_id=p_request_id and
      pert.context=decode(cma_province_count,1,'FORM14'
      					    ,2,'FORM13') and
      pert.segment1=decode(cma_province_count,1,'PROVINCE'
           			            ,2,'CMA') and
      hl2.lookup_type=decode(cma_province_count,1,'CA_PROVINCE'
           				    ,2,'CA_CMA') and
      pert.segment2=hl2.meaning and
      (
      (
        hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
        hsck.segment6 is not null and
        hsck.segment6 = v_naic_code OR
        hsck.segment6 in ( select segment4
                       from per_ca_ee_report_lines
                       where request_id = p_request_id and
                       context = 'FORM12' and
                       to_number(segment3) < to_number(v_leg_info) and
                       v_max_naic_flag = 'Y')
      )
      OR
      (
        hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
        hsck.segment6 is null and
        hsck.segment1 in (select segment3
                           from per_ca_ee_report_lines
			   where request_id = p_request_id and
			         context = 'FORM13' and
			         segment1 = 'NAIC' and
			         segment2 = v_naic_code OR
 				 segment2 in
 				   ( select segment4
                                     from per_ca_ee_report_lines
                                     where request_id = p_request_id and
                                     context = 'FORM12' and
                                     to_number(segment3)
                                            < to_number(v_leg_info) and
                                     v_max_naic_flag = 'Y')
                          )
      )
      )
   union all
    select
      trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor
                                                        max_salary,
      trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor
                                                        min_salary,
      hl.meaning 				meaning,
      'FR'					employment_category,
      decode(cma_province_count,1,hl1.region_1
           ,2,hl1.region_2) 			cma_province
    from
      hr_lookups hl,
      per_jobs pj,
      per_pay_proposals_v2 pppv,
      per_people_f ppf,
      per_assignments_f paf,
      hr_locations hl1,
      per_person_types ppt,
      per_ca_ee_report_lines pert,
      hr_lookups hl2,
      hr_soft_coding_keyflex  hsck,
      per_pay_bases ppb
    where
      hl.lookup_type='EEOG' and
      hl.lookup_code=pj.job_information1 and
      pj.job_information_category='CA' and
      pj.job_id=paf.job_id and
      paf.primary_flag = 'Y' and
      l_year_end between
        paf.effective_start_date and
        paf.effective_end_date  and
      (paf.employment_category is null OR
       paf.employment_category not in ('FR','PR','PT')
      ) and
      paf.pay_basis_id = ppb.pay_basis_id and
      ppb.business_group_id = p_business_group_id and
      paf.person_id=ppf.person_id and
      paf.assignment_id=pppv.assignment_id and
      pppv.change_date = (select max(pppv2.change_date)
                         from   per_pay_proposals_v2 pppv2
                         where  pppv2.assignment_id = paf.assignment_id
                         and    pppv2.change_date <= l_year_end
                        ) and
      l_year_end between
        ppf.effective_start_date and
        ppf.effective_end_date  and
      paf.location_id=hl1.location_id and
      ppf.person_type_id=ppt.person_type_id and
      upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
      ppf.business_group_id=p_business_group_id and
      hl2.lookup_type=decode(cma_province_count,1,'CA_PROVINCE'
        					,2,'CA_CMA') and
      hl2.lookup_code=decode(cma_province_count,1,hl1.region_1
        					,2,hl1.region_2) and
      --pert.segment4  = 'Y' and
      pert.request_id=p_request_id and
      pert.context=decode(cma_province_count,1,'FORM14'
      					    ,2,'FORM13') and
      pert.segment1=decode(cma_province_count,1,'PROVINCE'
           			            ,2,'CMA') and
      hl2.lookup_type=decode(cma_province_count,1,'CA_PROVINCE'
           				    ,2,'CA_CMA') and
      pert.segment2=hl2.meaning and
      (
      (
        hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
        hsck.segment6 is not null and
        hsck.segment6 = v_naic_code OR
        hsck.segment6 in ( select segment4
                       from per_ca_ee_report_lines
                       where request_id = p_request_id and
                       context = 'FORM12' and
                       to_number(segment3) < to_number(v_leg_info) and
                       v_max_naic_flag = 'Y')
      )
      OR
      (
        hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
        hsck.segment6 is null and
        hsck.segment1 in   (select segment3
                           from per_ca_ee_report_lines
			   where request_id = p_request_id and
			         context = 'FORM13' and
			         segment1 = 'NAIC' and
			         segment2 = v_naic_code OR
 				 segment2 in
 				   ( select segment4
                                     from per_ca_ee_report_lines
                                     where request_id = p_request_id and
                                     context = 'FORM12' and
                                     to_number(segment3)
                                            < to_number(v_leg_info) and
                                     v_max_naic_flag = 'Y')
                           )
      )
      )
   )
  group by meaning,employment_category,cma_province
  order by meaning,employment_category,cma_province;

  v_max_salary    		number;
  v_min_salary    		number;
  v_meaning   			hr_lookups.meaning%TYPE;
  v_employment_category   	per_assignments_f.employment_category%TYPE;
  v_cma_province      		hr_locations.region_1%TYPE;

  j_flag      varchar2(1) := 'F';

  cursor cur_meaning(cp number) is
  select
    meaning
  from
    hr_lookups
  where
    upper(ltrim(rtrim(lookup_type)))=decode(cp,1,'CA_PROVINCE'
          				      ,2,'CA_CMA') and
    upper(ltrim(rtrim(lookup_code)))=upper(ltrim(rtrim(v_cma_province)));

  v_meaning1    hr_lookups.meaning%TYPE;
  v_range     number;
  v_q1_min    number;
  v_q1_max    number;
  v_q2_min    number;
  v_q2_max    number;
  v_q3_min    number;
  v_q3_max    number;
  v_q4_min    number;
  v_q4_max    number;

  v_max_salary_range_min  number;
  v_max_salary_range_max  number;
  v_min_salary_range_min  number;
  v_min_salary_range_max  number;

  cursor cur_count_total(i_range number,
             i_x    number) is
  select
    count(distinct paf.person_id) count_total,
    ppf.sex  --sex
  from
    hr_lookups hl,
    per_jobs pj,
    per_assignments_f paf,
    per_people_f ppf,
    per_pay_proposals_v2 pppv,
    hr_locations hl1,
    per_person_types ppt,
    hr_soft_coding_keyflex  hsck,
    per_pay_bases ppb
  where
    hl.lookup_type='EEOG' and
    upper(ltrim(rtrim(hl.meaning)))=upper(ltrim(rtrim(v_meaning))) and
    upper(ltrim(rtrim(hl.lookup_code)))
                         =upper(ltrim(rtrim(pj.job_information1))) and
    upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
    pj.job_id=paf.job_id and
    paf.primary_flag = 'Y' and
    decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      paf.effective_start_date and
      paf.effective_end_date  and
    decode(substr(NVL(paf.employment_category,'FR'),1,2),
           'FR','FR','PR','PR','PT','PT','FR')
               = ltrim(rtrim(v_employment_category)) and
    /* substr(NVL(paf.employment_category,'FR'),1,2) =
                             ltrim(rtrim(v_employment_category)) and */
    paf.person_id=ppf.person_id and
    decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      ppf.effective_start_date and
      ppf.effective_end_date  and
    paf.pay_basis_id = ppb.pay_basis_id and
    ppb.business_group_id = p_business_group_id and
    ppf.person_type_id=ppt.person_type_id and
    upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
    ppf.business_group_id=p_business_group_id and
    paf.location_id=hl1.location_id and
    decode(i_x,1,hl1.region_1,
        2,hl1.region_2) = v_cma_province and
    paf.assignment_id=pppv.assignment_id and
    pppv.change_date = (select max(pppv2.change_date)
                         from   per_pay_proposals_v2 pppv2
                         where  pppv2.assignment_id = paf.assignment_id
                         and    pppv2.change_date <=
                                decode(substr(paf.employment_category,1,2),
                                       'PT',p_date_tmp_emp,l_year_end)
                        ) and
    trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor
         >= decode(i_range,1,v_q1_min,
                           2,v_q2_min,
                           3,v_q3_min,
                           4,v_q4_min) and
    trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor
         <= decode(i_range,1,v_q1_max,
                           2,v_q2_max,
                           3,v_q3_max,
                           4,v_q4_max) and
      (
      (
        hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
        hsck.segment6 is not null and
        hsck.segment6 = v_naic_code OR
        hsck.segment6 in ( select segment4
                       from per_ca_ee_report_lines
                       where request_id = p_request_id and
                       context = 'FORM12' and
                       to_number(segment3) < to_number(v_leg_info) and
                       v_max_naic_flag = 'Y')
      )
      OR
      (
        hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
        hsck.segment6 is null and
        hsck.segment1 in (select segment3
                           from per_ca_ee_report_lines
			   where request_id = p_request_id and
			         context = 'FORM13' and
			         segment1 = 'NAIC' and
			         segment2 = v_naic_code OR
 				 segment2 in
 				   ( select segment4
                                     from per_ca_ee_report_lines
                                     where request_id = p_request_id and
                                     context = 'FORM12' and
                                     to_number(segment3)
                                            < to_number(v_leg_info) and
                                     v_max_naic_flag = 'Y')
                         )
      )
      )
  group by ppf.sex
  order by ppf.sex;

  v_count       		number(10);
  v_sex       			per_people_f.sex%TYPE;
  prev_employment_category  	per_assignments_f.employment_category%TYPE;
  prev_sex      		per_people_f.sex%TYPE;
  prev_j        		number := 0;
  prev_cma_province   		hr_locations.region_1%TYPE;
  prev_naic_code		hr_lookups.lookup_code%TYPE;
  prev_meaning			hr_lookups.meaning%TYPE;

  cursor cur_count(range number,
             desig number,
             i_y   number) is
  select
    count(distinct paf.person_id) count,
    ppf.sex  --sex
  from
    hr_lookups hl,
    per_jobs pj,
    per_assignments_f paf,
    per_people_f ppf,
    per_pay_proposals_v2 pppv,
    hr_locations hl1,
    per_person_types ppt,
    hr_soft_coding_keyflex  hsck,
    per_pay_bases ppb
  where
    hl.lookup_type='EEOG' and
    upper(ltrim(rtrim(hl.meaning)))=upper(ltrim(rtrim(v_meaning))) and
    upper(ltrim(rtrim(hl.lookup_code)))
                  = upper(ltrim(rtrim(pj.job_information1))) and
    upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
    pj.job_id=paf.job_id and
    paf.primary_flag = 'Y' and
    decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      paf.effective_start_date and
      paf.effective_end_date  and
    paf.pay_basis_id = ppb.pay_basis_id and
    ppb.business_group_id = p_business_group_id and
    paf.location_id=hl1.location_id and
    decode(i_y,1,hl1.region_1,
        2,hl1.region_2) = v_cma_province and
    paf.person_id=ppf.person_id and
    decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      ppf.effective_start_date and
      ppf.effective_end_date  and
    ppf.person_type_id=ppt.person_type_id and
    upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
    ppf.business_group_id=p_business_group_id and
        decode(desig,1,per_information5,
        2,per_information6,
        3,per_information7)='Y' and
    --substr(NVL(paf.employment_category,'FR'),1,2)=v_employment_category and
    decode(substr(NVL(paf.employment_category,'FR'),1,2),
           'FR','FR','PR','PR','PT','PT','FR')
               = ltrim(rtrim(v_employment_category)) and
    paf.assignment_id=pppv.assignment_id and
    pppv.change_date = (select max(pppv2.change_date)
                         from   per_pay_proposals_v2 pppv2
                         where  pppv2.assignment_id = paf.assignment_id
                         and    pppv2.change_date <=
                                decode(substr(paf.employment_category,1,2),
                                         'PT',p_date_tmp_emp,l_year_end)
                        ) and
    trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor
         >= decode(range,1,v_q1_min,
                         2,v_q2_min,
                         3,v_q3_min,
                         4,v_q4_min) and
    trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor
        <= decode(range,1,v_q1_max,
                        2,v_q2_max,
                        3,v_q3_max,
                        4,v_q4_max) and
    (
    (
      hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
      hsck.segment6 is not null and
      hsck.segment6 = v_naic_code OR
      hsck.segment6 in ( select segment4
                       from per_ca_ee_report_lines
                       where request_id = p_request_id and
                       context = 'FORM12' and
                       to_number(segment3) < to_number(v_leg_info) and
                       v_max_naic_flag = 'Y')
    )
    OR
    (
      hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
      hsck.segment6 is null and
      hsck.segment1 in (select segment3
                         from per_ca_ee_report_lines
	   		where request_id = p_request_id and
	         	context = 'FORM13' and
	         	segment1 = 'NAIC' and
	         	segment2 = v_naic_code OR
 		 	segment2 in
 		   	( select segment4
                       	  from per_ca_ee_report_lines
                          where request_id = p_request_id and
                          context = 'FORM12' and
                          to_number(segment3)
                                   < to_number(v_leg_info) and
                          v_max_naic_flag = 'Y')
                      )
     )
     )
  group by ppf.sex
  order by ppf.sex;

begin

  open  cur_legislation_info('EER1');
  fetch cur_legislation_info
  into  v_leg_info;
  close cur_legislation_info;

  hr_utility.trace('Form2 starts Here !!!');

  for naic in cur_naic loop

    v_tot_number_emp := naic.tot_number_emp;
    v_naic_code     := naic.naic_code;
    v_max_naic_flag := naic.max_naic_flag;

  if ( (v_max_naic_flag = 'Y') OR
     (to_number(v_tot_number_emp) >= to_number(v_leg_info)) ) then

  for x in 1..2 loop

  for i in cur_min_max(x) loop

    hr_utility.trace('Form2: cur_min_max');

    v_max_salary := nvl(to_number(i.max_salary),0);
    v_min_salary := nvl(to_number(i.min_salary),0);
    v_meaning    := i.meaning;
    v_employment_category := i.employment_category;
    v_cma_province        := i.cma_province;


    hr_utility.trace('Form2: v_cma_province: ' || v_cma_province);
    hr_utility.trace('Form2: v_employment_category: ' || v_employment_category);
    hr_utility.trace('Form2: v_meaning: ' || v_meaning);

    open cur_meaning(x);
    fetch cur_meaning into v_meaning1;
    close cur_meaning;

    -- To check the salary range in the predefined
    -- salary ranges

    if v_max_salary >= 0 and v_max_salary < 5000 then

       v_max_salary_range_min := 0;
       v_max_salary_range_max := 5000;

    elsif v_max_salary >= 5000 and v_max_salary <= 9999 then

       v_max_salary_range_min := 5000;
       v_max_salary_range_max := 9999;

    elsif v_max_salary >= 10000 and v_max_salary <= 14999 then

       v_max_salary_range_min := 10000;
       v_max_salary_range_max := 14999;

    elsif v_max_salary >= 15000 and v_max_salary <= 19999 then

       v_max_salary_range_min := 15000;
       v_max_salary_range_max := 19999;

    elsif v_max_salary >= 20000 and v_max_salary <= 24999 then

       v_max_salary_range_min := 20000;
       v_max_salary_range_max := 24999;

    elsif v_max_salary >= 25000 and v_max_salary <= 29999 then

       v_max_salary_range_min := 25000;
       v_max_salary_range_max := 29999;

    elsif v_max_salary >= 30000 and v_max_salary <= 34999 then

       v_max_salary_range_min := 30000;
       v_max_salary_range_max := 34999;

    elsif v_max_salary >= 35000 and v_max_salary <= 39999 then

       v_max_salary_range_min := 35000;
       v_max_salary_range_max := 39999;

    elsif v_max_salary >= 40000 and v_max_salary <= 44999 then

       v_max_salary_range_min := 40000;
       v_max_salary_range_max := 44999;

    elsif v_max_salary >= 45000 and v_max_salary <= 49999 then

       v_max_salary_range_min := 45000;
       v_max_salary_range_max := 49999;

    elsif v_max_salary >= 50000 and v_max_salary <= 54999 then

       v_max_salary_range_min := 50000;
       v_max_salary_range_max := 54999;

    elsif v_max_salary >= 55000 and v_max_salary <= 59999 then

       v_max_salary_range_min := 55000;
       v_max_salary_range_max := 59999;

    elsif v_max_salary >= 60000 and v_max_salary <= 64999 then

       v_max_salary_range_min := 60000;
       v_max_salary_range_max := 64999;

    elsif v_max_salary >= 65000 and v_max_salary <= 69999 then

       v_max_salary_range_min := 65000;
       v_max_salary_range_max := 69999;

    elsif v_max_salary >= 70000 and v_max_salary <= 74999 then

       v_max_salary_range_min := 70000;
       v_max_salary_range_max := 74999;

    elsif v_max_salary >= 75000 and v_max_salary <= 79999 then

       v_max_salary_range_min := 75000;
       v_max_salary_range_max := 79999;

    elsif v_max_salary >= 80000 and v_max_salary <= 84999 then

       v_max_salary_range_min := 80000;
       v_max_salary_range_max := 84999;

    elsif v_max_salary >= 85000 and v_max_salary <= 89999 then

       v_max_salary_range_min := 85000;
       v_max_salary_range_max := 89999;

    elsif v_max_salary >= 90000 and v_max_salary <= 94999 then

       v_max_salary_range_min := 90000;
       v_max_salary_range_max := 94999;

    elsif v_max_salary >= 95000 and v_max_salary <= 99999 then

       v_max_salary_range_min := 95000;
       v_max_salary_range_max := 99999;

    elsif v_max_salary > 100000 then

       v_max_salary_range_min := 100000;
       v_max_salary_range_max := 9999999;

    end if ;

    if v_min_salary >= 0 and v_min_salary < 5000 then

       v_min_salary_range_min := 0;
       v_min_salary_range_max := 5000;

    elsif v_min_salary >= 5000 and v_min_salary <= 9999 then

       v_min_salary_range_min := 5000;
       v_min_salary_range_max := 9999;

    elsif v_min_salary >= 10000 and v_min_salary <= 14999 then

       v_min_salary_range_min := 10000;
       v_min_salary_range_max := 14999;

    elsif v_min_salary >= 15000 and v_min_salary <= 19999 then

       v_min_salary_range_min := 15000;
       v_min_salary_range_max := 19999;

    elsif v_min_salary >= 20000 and v_min_salary <= 24999 then

       v_min_salary_range_min := 20000;
       v_min_salary_range_max := 24999;

    elsif v_min_salary >= 25000 and v_min_salary <= 29999 then

       v_min_salary_range_min := 25000;
       v_min_salary_range_max := 29999;

    elsif v_min_salary >= 30000 and v_min_salary <= 34999 then

       v_min_salary_range_min := 30000;
       v_min_salary_range_max := 34999;

    elsif v_min_salary >= 35000 and v_min_salary <= 39999 then

       v_min_salary_range_min := 35000;
       v_min_salary_range_max := 39999;

    elsif v_min_salary >= 40000 and v_min_salary <= 44999 then

       v_min_salary_range_min := 40000;
       v_min_salary_range_max := 44999;

    elsif v_min_salary >= 45000 and v_min_salary <= 49999 then

       v_min_salary_range_min := 45000;
       v_min_salary_range_max := 49999;

    elsif v_min_salary >= 50000 and v_min_salary <= 54999 then

       v_min_salary_range_min := 50000;
       v_min_salary_range_max := 54999;

    elsif v_min_salary >= 55000 and v_min_salary <= 59999 then

       v_min_salary_range_min := 55000;
       v_min_salary_range_max := 59999;

    elsif v_min_salary >= 60000 and v_min_salary <= 64999 then

       v_min_salary_range_min := 60000;
       v_min_salary_range_max := 64999;

    elsif v_min_salary >= 65000 and v_min_salary <= 69999 then

       v_min_salary_range_min := 65000;
       v_min_salary_range_max := 69999;

    elsif v_min_salary >= 70000 and v_min_salary <= 74999 then

       v_min_salary_range_min := 70000;
       v_min_salary_range_max := 74999;

    elsif v_min_salary >= 75000 and v_min_salary <= 79999 then

       v_min_salary_range_min := 75000;
       v_min_salary_range_max := 79999;

    elsif v_min_salary >= 80000 and v_min_salary <= 84999 then

       v_min_salary_range_min := 80000;
       v_min_salary_range_max := 84999;

    elsif v_min_salary >= 85000 and v_min_salary <= 89999 then

       v_min_salary_range_min := 85000;
       v_min_salary_range_max := 89999;

    elsif v_min_salary >= 90000 and v_min_salary <= 94999 then

       v_min_salary_range_min := 90000;
       v_min_salary_range_max := 94999;

    elsif v_min_salary >= 95000 and v_min_salary <= 99999 then

       v_min_salary_range_min := 95000;
       v_min_salary_range_max := 99999;

    elsif v_min_salary > 100000 then

       v_min_salary_range_min := 100000;
       v_min_salary_range_max := 9999999;

    end if;

    v_range := (nvl(v_max_salary,0)-nvl(v_min_salary,0))/4;

    v_q1_min := nvl(v_min_salary,0);
    v_q1_max := v_q1_min + v_range;

    v_q2_min := v_q1_max + 1;
    v_q2_max := v_q2_min + v_range - 1;

    v_q3_min := v_q2_max + 1;
    v_q3_max := v_q3_min + v_range - 1;

    v_q4_min := v_q3_max + 1;
    v_q4_max := v_q4_min + v_range -1;

    for j in 1..4 loop

      j_flag := 'F';

      for l in cur_count_total(j,x) loop

      v_count         := l.count_total;
      v_sex := l.sex;

      if
        (
         (ltrim(rtrim(prev_cma_province)) <> ltrim(rtrim(v_meaning1))) or
         (ltrim(rtrim(prev_naic_code))    <> ltrim(rtrim(v_naic_code))) or
         (ltrim(rtrim(prev_meaning))      <> ltrim(rtrim(v_meaning))) or
         (ltrim(rtrim(prev_employment_category)) <>
           ltrim(rtrim(v_employment_category))) or
         (prev_j <> j)
      ) then

        per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

        insert into per_ca_ee_report_lines
        ( request_id,
         line_number,
         context,
         segment1,
         segment2,
         segment3,
         segment4,
         segment5,
         segment6,
         segment7,
         segment8,
         segment9,
         segment10,
         segment11,
         segment12,
         segment13,
         segment14,
         segment15,
         segment16,
         segment17,
         segment18,
         segment21) values
        ( p_request_id,
         per_ca_ee_extract_pkg.k,
         'FORM2',
         decode(x,1,'PROVINCE'
           ,2,'CMA'),
         v_meaning1,
         v_meaning,
         v_employment_category,
         v_min_salary_range_min||'..'||
         v_min_salary_range_max||'  '||
         v_max_salary_range_min||'..'||
         v_max_salary_range_max,
         to_char(j),
         nvl(v_count,0),
         decode(v_sex,'F',v_count,0),
         decode(v_sex,'M',v_count,0),
         '0',
         '0',
         '0',
         '0',
         '0',
         '0',
         '0',
         '0',
         '0',
         v_naic_code) ;

         j_flag := 'T';
       else
         if prev_cma_province     = v_meaning1 and
         prev_employment_category = v_employment_category and
         prev_naic_code           = v_naic_code and
         prev_meaning             = v_meaning and
         prev_sex <> v_sex then

           if v_sex = 'M' then

            update per_ca_ee_report_lines set
              segment7=segment7 + nvl(v_count,0),
              segment9=nvl(v_count,0)
            where request_id=p_request_id and
              line_number=per_ca_ee_extract_pkg.k and
              segment1=decode(x,1,'PROVINCE',
                  2,'CMA') and
              segment2=v_meaning1 and
              segment21 = v_naic_code;

           elsif v_sex = 'F' then

             update per_ca_ee_report_lines set
               segment7=segment7 + nvl(v_count,0),
               segment9=nvl(v_count,0)
             where request_id=p_request_id and
               line_number=per_ca_ee_extract_pkg.k and
               segment1  = decode(x,1,'PROVINCE',
                                 2,'CMA') and
               segment2  = v_meaning1 and
               segment21 = v_naic_code;

          end if;
        end if;
      end if;

      prev_cma_province := v_meaning1;
      prev_employment_category := v_employment_category;
      prev_sex := v_sex;
      prev_j := j;
      prev_naic_code := v_naic_code;
      prev_meaning   := v_meaning;

    end loop;


    if j_flag = 'F' then

    per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

    insert into per_ca_ee_report_lines
    ( request_id,
     line_number,
     context,
     segment1,
     segment2,
     segment3,
     segment4,
     segment5,
     segment6,
     segment7,
     segment8,
     segment9,
     segment10,
     segment11,
     segment12,
     segment13,
     segment14,
     segment15,
     segment16,
     segment17,
     segment18,
     segment21) values
    ( p_request_id,
     per_ca_ee_extract_pkg.k,
     'FORM2',
     decode(x,1,'PROVINCE'
       ,2,'CMA'),
     v_meaning1,
     v_meaning,
     v_employment_category,
     v_min_salary_range_min||'..'||
     v_min_salary_range_max||'  '||
     v_max_salary_range_min||'..'||
     v_max_salary_range_max,
     to_char(j),
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     v_naic_code);

    j_flag := 'T';

    end if ;

    end loop;
  ---------------------------------
  -- Updation designated Group   --
  ---------------------------------

  for j in 1..4 loop

    for k in 1..3 loop

    for l in cur_count(j,k,x) loop

      if k = 1 then

        if l.sex = 'F' then

        update per_ca_ee_report_lines set
          segment10=nvl(segment10,0) + nvl(l.count,0),
          segment11=nvl(l.count,0)
        where
          request_id=p_request_id and
          context='FORM2' and
          ltrim(rtrim(segment1))=decode(x,1,'PROVINCE'
                                         ,2,'CMA') and
          ltrim(rtrim(segment2))=ltrim(rtrim(v_meaning1)) and
          upper(ltrim(rtrim(segment3)))=upper(ltrim(rtrim(v_meaning))) and
          upper(ltrim(rtrim(segment4)))
                  =upper(ltrim(rtrim(v_employment_category))) and
          segment6=to_char(j) and
          segment21 = v_naic_code;

        elsif l.sex = 'M' then

        update per_ca_ee_report_lines set
          segment10=nvl(segment10,0) + nvl(l.count,0),
          segment12=nvl(l.count,0)
        where
          request_id=p_request_id and
          context='FORM2' and
          ltrim(rtrim(segment1))=decode(x,1,'PROVINCE'
                                         ,2,'CMA') and
          ltrim(rtrim(segment2))=ltrim(rtrim(v_meaning1)) and
          upper(ltrim(rtrim(segment3))) =
                upper(ltrim(rtrim(v_meaning))) and
          upper(ltrim(rtrim(segment4))) =
               upper(ltrim(rtrim(v_employment_category))) and
          segment6=to_char(j) and
          segment21 = v_naic_code;

        end if;

      elsif k = 2 then

        if l.sex = 'F' then

          update per_ca_ee_report_lines set
            segment13=nvl(segment13,0) + nvl(l.count,0),
            segment14=nvl(l.count,0)
          where
            request_id=p_request_id and
            context='FORM2' and
            ltrim(rtrim(segment1))=decode(x,1,'PROVINCE'
                                           ,2,'CMA') and
            ltrim(rtrim(segment2))=ltrim(rtrim(v_meaning1)) and
            upper(ltrim(rtrim(segment3)))=upper(ltrim(rtrim(v_meaning))) and
            upper(ltrim(rtrim(segment4)))=
			upper(ltrim(rtrim(v_employment_category))) and
            segment6=to_char(j) and
            segment21 = v_naic_code;
        else

          update per_ca_ee_report_lines set
            segment13=nvl(segment13,0) + nvl(l.count,0),
            segment15=nvl(l.count,0)
          where
            request_id=p_request_id and
            context='FORM2' and
            ltrim(rtrim(segment1))=decode(x,1,'PROVINCE'
                                           ,2,'CMA') and
            ltrim(rtrim(segment2))=ltrim(rtrim(v_meaning1)) and
            upper(ltrim(rtrim(segment3))) = upper(ltrim(rtrim(v_meaning))) and
            upper(ltrim(rtrim(segment4))) =
                    upper(ltrim(rtrim(v_employment_category))) and
            segment6=to_char(j) and
            segment21 = v_naic_code;

        end if;

      elsif k = 3 then

        if l.sex = 'F' then

          update per_ca_ee_report_lines set
            segment16=nvl(segment16,0) + nvl(l.count,0),
            segment17=nvl(l.count,0)
          where
            request_id=p_request_id and
            context='FORM2' and
            ltrim(rtrim(segment1))=decode(x,1,'PROVINCE'
                                           ,2,'CMA') and
            ltrim(rtrim(segment2))=ltrim(rtrim(v_meaning1)) and
            upper(ltrim(rtrim(segment3)))=upper(ltrim(rtrim(v_meaning))) and
            upper(ltrim(rtrim(segment4)))=
                  upper(ltrim(rtrim(v_employment_category))) and
            segment6=to_char(j) and
            segment21 = v_naic_code;

        else

        update per_ca_ee_report_lines set
          segment16=nvl(segment16,0) + nvl(l.count,0),
          segment18=nvl(l.count,0)
        where
          request_id=p_request_id and
          context='FORM2' and
          ltrim(rtrim(segment1))=decode(x,1,'PROVINCE'
                                         ,2,'CMA') and
          ltrim(rtrim(segment2))=ltrim(rtrim(v_meaning1)) and
          upper(ltrim(rtrim(segment3)))=upper(ltrim(rtrim(v_meaning))) and
          upper(ltrim(rtrim(segment4))) =
              upper(ltrim(rtrim(v_employment_category))) and
          segment6=to_char(j) and
          segment21 = v_naic_code;

        end if;

      end if;
    end loop;
    end loop;
  end loop;

  end loop;
  end loop;

  prev_naic_code := v_naic_code;

  end if; -- if v_max_naic_code = Y or segment3 greater than v_leg_info.

  end loop; -- End loop cur_naic

return 1;
end;

end form2;


function form3(p_business_group_id in number,
               p_request_id     in number,
               p_year           in varchar2,
               p_date_tmp_emp   in date) return number is

  --l_year_start date;
  l_year_end date;

begin

  --l_year_start :=  trunc(to_date(p_year,'YYYY'),'Y');
  l_year_end   :=  add_months(trunc(to_date(p_year,'YYYY'),'Y'), 12) -1;

declare

  cursor cur_naic is
  select
    pert.segment4	naic_code
  from
    per_ca_ee_report_lines	pert
  where
    pert.request_id = p_request_id and
    pert.context = 'FORM12';

  v_naic_code			hr_lookups.lookup_code%TYPE;

  v_min_range   number;
  v_max_range   number;
  v_fr_min_range   number;
  v_fr_max_range   number;

  cursor cur_count_total(cma_province_count number,
             range number) is
  select
    count(distinct count_total) count_total,
    employment_category       employment_category,
    sex  		      sex,
    cma_province	      cma_province
  from
  (
  select
    paf.person_id 			count_total,
    substr(paf.employment_category,1,2) employment_category,
    ppf.sex  				sex,
    decode(cma_province_count,1,hl1.region_1,2,hl1.region_2) cma_province
  from
    per_jobs pj,
    per_assignments_f paf,
    per_people_f ppf,
    per_pay_proposals_v2 pppv,
    per_person_types ppt,
    hr_locations hl1,
    per_ca_ee_report_lines pert,
    hr_lookups hl2,
    hr_soft_coding_keyflex hsck,
    per_pay_bases ppb
  where
    upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
    pj.job_id=paf.job_id and
    paf.primary_flag = 'Y' and
    decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      paf.effective_start_date and
      paf.effective_end_date   and
    paf.employment_category is not null and
    substr(paf.employment_category,1,2) in ('FR','PR','PT') and
    paf.person_id=ppf.person_id and
    decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      ppf.effective_start_date and
      ppf.effective_end_date   and
    paf.pay_basis_id = ppb.pay_basis_id and
    ppb.business_group_id = p_business_group_id and
    ppf.person_type_id=ppt.person_type_id and
    upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
    ppf.business_group_id=p_business_group_id and
    paf.location_id=hl1.location_id and
    hl2.lookup_type=decode(cma_province_count,1,'CA_PROVINCE'
                                ,2,'CA_CMA') and
    hl2.lookup_code=decode(cma_province_count,1,hl1.region_1
                                ,2,hl1.region_2) and
    --pert.segment4 = 'Y' and
    pert.request_id=p_request_id and
    pert.context=decode(cma_province_count,1,'FORM14'
                           ,2,'FORM13') and
    pert.segment1=decode(cma_province_count,1,'PROVINCE'
                             ,2,'CMA') and
    pert.segment2=hl2.meaning and
    paf.assignment_id=pppv.assignment_id and
    pppv.change_date = (select max(pppv2.change_date)
                         from   per_pay_proposals_v2 pppv2
                         where  pppv2.assignment_id = paf.assignment_id
                         and    pppv2.approved = 'Y'
                         and    pppv2.change_date <=
                                decode(substr(paf.employment_category,1,2),
                                          'PT',p_date_tmp_emp,l_year_end)
                        ) and
    trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor >=
                            decode(substr(paf.employment_category,1,2),
                            'FR',v_fr_min_range,v_min_range) and
    trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor <=
                            decode(substr(paf.employment_category,1,2),
                            'FR',v_fr_max_range,v_max_range) and
    (
    (
     hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
     hsck.segment6 is not null and
     hsck.segment6 = v_naic_code
    )
    OR
    (
     hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
     hsck.segment6 is null and
     hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
	   where request_id = p_request_id and
	         context = 'FORM13' and
	         segment1 = 'NAIC' and
	         segment2 = v_naic_code)
    )
   )
  union all
  select
    paf.person_id 			count_total,
    'FR' 				employment_category,
    ppf.sex  				sex,
    decode(cma_province_count,1,hl1.region_1,2,hl1.region_2)    cma_province
  from
    per_jobs pj,
    per_assignments_f paf,
    per_people_f ppf,
    per_pay_proposals_v2 pppv,
    per_person_types ppt,
    hr_locations hl1,
    per_ca_ee_report_lines pert,
    hr_lookups hl2,
    hr_soft_coding_keyflex hsck,
    per_pay_bases ppb
  where
    upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
    pj.job_id=paf.job_id and
    paf.primary_flag = 'Y' and
    l_year_end between
      paf.effective_start_date and
      paf.effective_end_date   and
    (paf.employment_category is null OR
     substr(paf.employment_category,1,2) not in ('FR','PR','PT')) and
    paf.pay_basis_id = ppb.pay_basis_id and
    ppb.business_group_id = p_business_group_id and
    paf.person_id=ppf.person_id and
    l_year_end between
      ppf.effective_start_date and
      ppf.effective_end_date   and
    ppf.person_type_id=ppt.person_type_id and
    upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
    ppf.business_group_id=p_business_group_id and
    paf.location_id=hl1.location_id and
    hl2.lookup_type=decode(cma_province_count,1,'CA_PROVINCE'
                                ,2,'CA_CMA') and
    hl2.lookup_code=decode(cma_province_count,1,hl1.region_1
                                ,2,hl1.region_2) and
    --pert.segment4 = 'Y' and
    pert.request_id=p_request_id and
    pert.context=decode(cma_province_count,1,'FORM14'
                           ,2,'FORM13') and
    pert.segment1=decode(cma_province_count,1,'PROVINCE'
                             ,2,'CMA') and
    pert.segment2=hl2.meaning and
    paf.assignment_id=pppv.assignment_id and
    pppv.change_date = (select max(pppv2.change_date)
                         from   per_pay_proposals_v2 pppv2
                         where  pppv2.assignment_id = paf.assignment_id
                         and    pppv2.approved     = 'Y'
                         and    pppv2.change_date <= l_year_end
                        ) and
    --to_number(pppv.proposed_salary) >= v_min_range and
    --pppv.change_date <= l_year_end and
    trunc(to_number(pppv.proposed_salary))* ppb.pay_annualization_factor
                                          >= v_fr_min_range and
    trunc(to_number(pppv.proposed_salary))* ppb.pay_annualization_factor
                                          <= v_fr_max_range and
    (
    (
     hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
     hsck.segment6 is not null and
     hsck.segment6 = v_naic_code
    )
    OR
    (
     hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
     hsck.segment6 is null and
     hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
	   where request_id = p_request_id and
	         context = 'FORM13' and
	         segment1 = 'NAIC' and
	         segment2 = v_naic_code)
    )
   )
  )
  group by employment_category,sex,cma_province
  order by cma_province,employment_category,sex;

  v_count       		number(10);
  v_sex       			per_people_f.sex%TYPE;
  v_employment_category   	per_assignments_f.employment_category%TYPE;
  prev_employment_category  	per_assignments_f.employment_category%TYPE;
  prev_sex      		per_people_f.sex%TYPE;
  prev_x        		number := 0;
  v_cma_province      		hr_locations.region_1%TYPE;
  prev_naic_code                hr_lookups.lookup_code%TYPE;


  cursor cur_meaning(cp number) is
  select
    meaning from hr_lookups
  where
    upper(ltrim(rtrim(lookup_type)))=decode(cp,1,'CA_PROVINCE'
                                  ,2,'CA_CMA') and
    upper(ltrim(rtrim(lookup_code)))=upper(ltrim(rtrim(v_cma_province)));

  v_meaning            hr_lookups.meaning%TYPE;
  prev_meaning         hr_lookups.meaning%TYPE;

  cursor cur_count(cma_province_ct number,
      count number,
      desig number) is
  select
    count(distinct person_id)	 		count,
    employment_category 		employment_category,
    sex   				sex,
    cma_province			cma_province
  from
  (
    select
      paf.person_id 			person_id,
      substr(paf.employment_category,1,2) employment_category,
      ppf.sex  				sex,
      decode(cma_province_ct,1,hl1.region_1,2,hl1.region_2) cma_province
    from
      per_jobs pj,
      per_assignments_f paf,
      per_people_f ppf,
      per_pay_proposals_v2 pppv,
      per_person_types ppt,
      hr_locations hl1,
      per_ca_ee_report_lines pert,
      hr_lookups hl2,
      hr_soft_coding_keyflex hsck,
      per_pay_bases ppb
    where
      upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
      pj.job_id=paf.job_id and
      paf.primary_flag = 'Y' and
      decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
        paf.effective_start_date and
        paf.effective_end_date   and
      paf.employment_category is not null and
      substr(paf.employment_category,1,2) in ('FR','PR','PT') and
      paf.person_id=ppf.person_id and
      decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
        ppf.effective_start_date and
        ppf.effective_end_date   and
      paf.pay_basis_id = ppb.pay_basis_id and
      ppb.business_group_id = p_business_group_id and
      ppf.person_type_id=ppt.person_type_id and
      upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
      ppf.business_group_id=p_business_group_id and
      paf.location_id=hl1.location_id and
      hl2.lookup_type=decode(cma_province_ct,1,'CA_PROVINCE'
                                ,2,'CA_CMA') and
      hl2.lookup_code=decode(cma_province_ct,1,hl1.region_1
                                ,2,hl1.region_2) and
      --pert.segment4 = 'Y' and
      pert.request_id=p_request_id and
      pert.context=decode(cma_province_ct,1,'FORM14'
                            ,2,'FORM13') and
      pert.segment1=decode(cma_province_ct,1,'PROVINCE'
                             ,2,'CMA') and
      pert.segment2=hl2.meaning and
      decode(desig,1,per_information5,
        2,per_information6,
        3,per_information7)='Y' and
      substr(NVL(paf.employment_category,'FR'),1,2)=v_employment_category and
      paf.assignment_id=pppv.assignment_id and
      pppv.change_date = (select max(pppv2.change_date)
                         from   per_pay_proposals_v2 pppv2
                         where  pppv2.assignment_id = paf.assignment_id
                         and    pppv2.approved = 'Y'
                         and    pppv2.change_date <=
                                decode(substr(paf.employment_category,1,2),
                                          'PT',p_date_tmp_emp,l_year_end)
                        ) and
      trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor >=
                            decode(substr(paf.employment_category,1,2),
                            'FR',v_fr_min_range,v_min_range) and
      trunc(to_number(pppv.proposed_salary)) * ppb.pay_annualization_factor <=
                            decode(substr(paf.employment_category,1,2),
                            'FR',v_fr_max_range,v_max_range) and
      (
      (
       hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
       hsck.segment6 is not null and
       hsck.segment6 = v_naic_code
      )
      OR
      (
       hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
       hsck.segment6 is null and
       hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
	   where request_id = p_request_id and
	         context = 'FORM13' and
	         segment1 = 'NAIC' and
	         segment2 = v_naic_code)
     )
     )
    union all
    select
      paf.person_id 			person_id,
      'FR'                              employment_category,
      ppf.sex  				sex,
      decode(cma_province_ct,1,hl1.region_1,2,hl1.region_2) cma_province
    from
      per_jobs pj,
      per_assignments_f paf,
      per_people_f ppf,
      per_pay_proposals_v2 pppv,
      per_person_types ppt,
      hr_locations hl1,
      per_ca_ee_report_lines pert,
      hr_lookups hl2,
      hr_soft_coding_keyflex hsck,
      per_pay_bases ppb
    where
      upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
      pj.job_id=paf.job_id and
      paf.primary_flag = 'Y' and
      l_year_end between
        paf.effective_start_date and
        paf.effective_end_date   and
      (paf.employment_category is null OR
      substr(paf.employment_category,1,2) not in ('FR','PR','PT')) and
      paf.person_id=ppf.person_id and
      l_year_end between
        paf.effective_start_date and
        paf.effective_end_date   and
      ppf.person_type_id=ppt.person_type_id and
      upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
      ppf.business_group_id=p_business_group_id and
      paf.location_id=hl1.location_id and
      hl2.lookup_type=decode(cma_province_ct,1,'CA_PROVINCE'
                                ,2,'CA_CMA') and
      hl2.lookup_code=decode(cma_province_ct,1,hl1.region_1
                                ,2,hl1.region_2) and
      --pert.segment4 = 'Y' and
      pert.request_id=p_request_id and
      pert.context=decode(cma_province_ct,1,'FORM14'
                            ,2,'FORM13') and
      pert.segment1=decode(cma_province_ct,1,'PROVINCE'
                             ,2,'CMA') and
      pert.segment2=hl2.meaning and
      decode(desig,1,per_information5,
        2,per_information6,
        3,per_information7)='Y' and
      --substr(NVL(paf.employment_category,'FR'),1,2)=v_employment_category and
      paf.pay_basis_id = ppb.pay_basis_id and
      ppb.business_group_id = p_business_group_id and
      paf.assignment_id=pppv.assignment_id and
      pppv.change_date = (select max(pppv2.change_date)
                         from   per_pay_proposals_v2 pppv2
                         where  pppv2.assignment_id = paf.assignment_id
                         and    pppv2.approved = 'Y'
                         and    pppv2.change_date <= l_year_end
                        ) and
      trunc(to_number(pppv.proposed_salary))
                    * ppb.pay_annualization_factor >= v_fr_min_range and
      trunc(to_number(pppv.proposed_salary))
                    * ppb.pay_annualization_factor <= v_fr_max_range and
      (
      (
       hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
       hsck.segment6 is not null and
       hsck.segment6 = v_naic_code
      )
      OR
      (
       hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
       hsck.segment6 is null and
       hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
	   where request_id = p_request_id and
	         context = 'FORM13' and
	         segment1 = 'NAIC' and
	         segment2 = v_naic_code)
     )
     )
   )
   group by employment_category,sex,cma_province
   order by employment_category,sex,cma_province;

  cursor cur_notfound(range varchar2,
                      pc    number,
                      p_category varchar2) is
  select
    decode(pc,1,'PROVINCE','CMA') provcma,
    segment2			  provcma_name,
    p_category			  emp_category,
    decode(p_category,'FR',v_fr_min_range|| ' - ' || v_fr_max_range,
                           v_min_range   || ' - ' || v_max_range)
                                  max_min_range

  from
    per_ca_ee_report_lines
  where
    request_id = p_request_id and
    context=decode(pc,1,'FORM14','FORM13') and
    segment1 = decode(pc,1,'PROVINCE','CMA') and
    segment3 <> '0'
  minus
  select
    segment1,
    segment2,
    segment4,
    segment3
  from
    per_ca_ee_report_lines
  where
    request_id = p_request_id and
    context   = 'FORM3' and
    segment1  = decode(pc,1,'PROVINCE','CMA') and
    segment21 = v_naic_code;

   cursor cur_count_national is
   select
     segment3,
     segment4,
     sum(to_number(segment5))		segment5,
     sum(to_number(segment6))		segment6,
     sum(to_number(segment7))		segment7,
     sum(to_number(segment8))		segment8,
     sum(to_number(segment9))		segment9,
     sum(to_number(segment10))		segment10,
     sum(to_number(segment11))		segment11,
     sum(to_number(segment12))		segment12,
     sum(to_number(segment13))		segment13,
     sum(to_number(segment14))		segment14,
     sum(to_number(segment15))		segment15,
     sum(to_number(segment16))		segment16
   from
     per_ca_ee_report_lines
   where
     request_id = p_request_id and
     context = 'FORM3' and
     segment1 = 'PROVINCE' and
     segment21 = v_naic_code
   group by segment3,segment4;

   pc_count 	number;
   emp_cat	varchar2(2);

begin

  hr_utility.trace('Form3 starts here !!!!!');

  for naic in cur_naic loop

    v_naic_code := naic.naic_code;

  for i in 1..2 loop
  for x in 1..14 loop

  if x = 1 then

   v_min_range := 0;
   v_max_range := 4999;

   v_fr_min_range := 0;
   v_fr_max_range := 14999;

  elsif x = 2 then

   v_min_range := 5000;
   v_max_range := 7499;

   v_fr_min_range := 15000;
   v_fr_max_range := 19999;

  elsif x = 3 then

   v_min_range := 7500;
   v_max_range := 9999;

   v_fr_min_range := 20000;
   v_fr_max_range := 24999;

  elsif x = 4 then

   v_min_range := 10000;
   v_max_range := 12499;

   v_fr_min_range := 25000;
   v_fr_max_range := 29999;

  elsif x = 5 then

   v_min_range := 12500;
   v_max_range := 14999;

   v_fr_min_range := 30000;
   v_fr_max_range := 34999;

  elsif x = 6 then

   v_min_range := 15000;
   v_max_range := 17499;

   v_fr_min_range := 35000;
   v_fr_max_range := 37499;

  elsif x = 7 then

   v_min_range := 17500;
   v_max_range := 19999;

   v_fr_min_range := 37500;
   v_fr_max_range := 39999;

  elsif x = 8 then

   v_min_range := 20000;
   v_max_range := 22499;

   v_fr_min_range := 40000;
   v_fr_max_range := 44999;

  elsif x = 9 then

   v_min_range := 22500;
   v_max_range := 24999;

   v_fr_min_range := 45000;
   v_fr_max_range := 49999;

   elsif x = 10 then

    v_min_range := 25000;
    v_max_range := 29999;

   v_fr_min_range := 50000;
   v_fr_max_range := 59999;

  elsif x = 11 then

   v_min_range := 30000;
   v_max_range := 34499;

   v_fr_min_range := 60000;
   v_fr_max_range := 69999;

  elsif x = 12 then

   v_min_range := 35000;
   v_max_range := 39999;

   v_fr_min_range := 70000;
   v_fr_max_range := 84999;

  elsif x = 13 then

   v_min_range := 40000;
   v_max_range := 49999;

   v_fr_min_range := 85000;
   v_fr_max_range := 99999;

  elsif x = 14 then

   v_min_range := 50000;
   v_max_range := 9999999;

   v_fr_min_range := 100000;
   v_fr_max_range := 9999999;

  end if;

  hr_utility.trace('v_min_range = '||to_char(v_min_range));
  hr_utility.trace('v_max_range = '||to_char(v_max_range));
  hr_utility.trace('cur_count_total = ');

  for l in cur_count_total(i,x) loop

  v_count         	:= l.count_total;
  v_sex     		:= l.sex;
  v_employment_category := l.employment_category;
  v_cma_province        := l.cma_province;

  hr_utility.trace('v_count = ' || to_char(v_count));
  hr_utility.trace('v_sex = '||  v_sex);
  hr_utility.trace('v_employment_category = ' || v_employment_category);
  hr_utility.trace('v_cma_province = '|| v_cma_province );

  open cur_meaning(i);
  fetch cur_meaning into v_meaning;
  close cur_meaning;

  if
  (
    (ltrim(rtrim(prev_meaning)) <> ltrim(rtrim(v_meaning))) or
    (ltrim(rtrim(prev_employment_category)) <>
               ltrim(rtrim(v_employment_category)))  or
    (ltrim(rtrim(prev_naic_code)) <> ltrim(rtrim(v_naic_code))) or
    (prev_x <> x)
  ) then

    hr_utility.trace('v_meaning = '|| v_meaning );

    per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

    insert into per_ca_ee_report_lines
      ( request_id,
       line_number,
       context,
       segment1,
       segment2,
       segment3,
       segment4,
       segment5,
       segment6,
       segment7,
       segment8,
       segment9,
       segment10,
       segment11,
       segment12,
       segment13,
       segment14,
       segment15,
       segment16,
       segment21) values
      ( p_request_id,
       per_ca_ee_extract_pkg.k,
       'FORM3',
       decode(i,1,'PROVINCE',
          2,'CMA'),
       v_meaning,
       decode(v_employment_category,'FR',
                       v_fr_min_range||' - '||v_fr_max_range,
                       v_min_range||' - '||v_max_range),
       v_employment_category,
       nvl(v_count,0),
       decode(v_sex,'F',v_count,0),
       decode(v_sex,'M',v_count,0),
       0,
       0,
       0,
       0,
       0,
       0,
       0,
       0,
       0,
       v_naic_code) ;

     else
       if prev_meaning = v_meaning and
          prev_employment_category = v_employment_category and
          prev_naic_code = v_naic_code and
          prev_x = x and
          prev_sex <> v_sex then

           if v_sex = 'M' then
            update per_ca_ee_report_lines set
              segment5 = segment5 + nvl(v_count,0),
              segment7 = nvl(v_count,0)
            where
              request_id=p_request_id and
              line_number=per_ca_ee_extract_pkg.k and
              context   = 'FORM3' and
              segment1  = decode(i,1,'PROVINCE',2,'CMA') and
              segment2  = v_meaning and
              segment3  = decode(v_employment_category,'FR',
                            v_fr_min_range|| ' - '||v_fr_max_range,
                            v_min_range|| ' - '||v_max_range) and
              segment4  = v_employment_category and
              segment21 = v_naic_code;

           elsif v_sex = 'F' then

            update per_ca_ee_report_lines set
              segment5=segment5 + nvl(v_count,0),
              segment6=nvl(v_count,0)
            where
              request_id=p_request_id and
              line_number=per_ca_ee_extract_pkg.k and
              context='FORM3' and
              segment1=decode(i,1,'PROVINCE',2,'CMA') and
              segment2=v_meaning and
              segment3=decode(v_employment_category,'FR',
                         v_fr_min_range|| ' - '||v_fr_max_range ,
                         v_min_range|| ' - '||v_max_range) and
              segment4=v_employment_category and
              segment21 = v_naic_code;

          end if;
        end if;
      end if;

      prev_employment_category := v_employment_category;
      prev_sex := v_sex;
      prev_x := x;
      prev_meaning := v_meaning;
      prev_naic_code := v_naic_code;

    end loop;


  ---------------------------------
  -- Updation designated Group   --
  ---------------------------------

    hr_utility.trace('Form3: v_fr_min_range: ' || to_char(v_fr_min_range));
    hr_utility.trace('Form3: v_fr_max_range: ' || to_char(v_fr_max_range));

    for k in 1..3 loop

    for l in cur_count(i,x,k) loop

      hr_utility.trace('Form3: Updation Designated Group');

      v_cma_province        := l.cma_province;
      v_employment_category := l.employment_category;

      hr_utility.trace('Form3: v_meaning: ' || v_meaning);
      hr_utility.trace('Form3: v_cma_province: ' || v_cma_province);
      hr_utility.trace('Form3: v_employment_category: '
                                              || v_employment_category);
      hr_utility.trace('Form3: v_fr_min_range: ' || to_char(v_fr_min_range));
      hr_utility.trace('Form3: v_fr_max_range: ' || to_char(v_fr_max_range));

      open cur_meaning(i);
      fetch cur_meaning into v_meaning;
      close cur_meaning;

      if k = 1 then

        hr_utility.trace('Form3: Updation Designated Grp: k = 1. ');
        if l.sex = 'F' then

        update per_ca_ee_report_lines set
          segment8=nvl(segment8,0) + nvl(l.count,0),
          segment9=nvl(l.count,0)
        where
          request_id = p_request_id and
          context    = 'FORM3' and
          ltrim(rtrim(segment1)) = decode(i,1,'PROVINCE',2,'CMA') and
          ltrim(rtrim(segment2)) = v_meaning and
          ltrim(rtrim(segment3)) = decode(v_employment_category,'FR',
                                   v_fr_min_range|| ' - '||v_fr_max_range,
                                   v_min_range||    ' - ' ||v_max_range) and
          upper(ltrim(rtrim(segment4))) =
                              upper(ltrim(rtrim(v_employment_category))) and
          segment21 = v_naic_code;

        elsif l.sex = 'M' then

        update per_ca_ee_report_lines set
          segment8  = nvl(segment8,0) + nvl(l.count,0),
          segment10 = nvl(l.count,0)
        where
          request_id = p_request_id and
          context    = 'FORM3' and
          ltrim(rtrim(segment1)) = decode(i,1,'PROVINCE',2,'CMA') and
          ltrim(rtrim(segment2)) = v_meaning and
          rtrim(ltrim(segment3)) = decode(v_employment_category,'FR',
                                   v_fr_min_range|| ' - '||v_fr_max_range,
                                   v_min_range||    ' - ' ||v_max_range) and
          upper(ltrim(rtrim(segment4)))
               = upper(ltrim(rtrim(v_employment_category))) and
          segment21 = v_naic_code;

        end if;

      elsif k = 2 then

        hr_utility.trace('Form3: Updation Designated Grp: k = 2. ');

        if l.sex = 'F' then

        update per_ca_ee_report_lines set
          segment11=nvl(segment11,0) + nvl(l.count,0),
          segment12=nvl(l.count,0)
        where
          request_id=p_request_id and
          context='FORM3' and
          ltrim(rtrim(segment1))=decode(i,1,'PROVINCE',2,'CMA') and
          ltrim(rtrim(segment2))=v_meaning and
          ltrim(rtrim(segment3))=decode(v_employment_category,'FR',
                                   v_fr_min_range|| ' - '||v_fr_max_range,
                                   v_min_range||    ' - ' ||v_max_range) and
          upper(ltrim(rtrim(segment4)))
                        = upper(ltrim(rtrim(v_employment_category))) and
          segment21 = v_naic_code;

        else

        update per_ca_ee_report_lines set
          segment11=nvl(segment11,0) + nvl(l.count,0),
          segment13=nvl(l.count,0)
        where
          request_id=p_request_id and
          context='FORM3' and
          ltrim(rtrim(segment1))=decode(i,1,'PROVINCE',2,'CMA') and
          ltrim(rtrim(segment2))=v_meaning and
          ltrim(rtrim(segment3))= decode(v_employment_category,'FR',
                                   v_fr_min_range|| ' - '||v_fr_max_range,
                                   v_min_range||    ' - ' ||v_max_range) and
          upper(ltrim(rtrim(segment4)))
                      = upper(ltrim(rtrim(v_employment_category))) and
          segment21 = v_naic_code;

        end if;

      elsif k = 3 then

        hr_utility.trace('Form3: Updation Designated Grp: k = 3. ');

        if l.sex = 'F' then

        hr_utility.trace('Form3: Updation Designated Grp: k = 3. F ');

        update per_ca_ee_report_lines set
          segment14=nvl(segment14,0) + nvl(l.count,0),
          segment16=nvl(l.count,0)
        where
          request_id=p_request_id and
          context='FORM3' and
          ltrim(rtrim(segment1))=decode(i,1,'PROVINCE',2,'CMA') and
          ltrim(rtrim(segment2))=v_meaning and
          ltrim(rtrim(segment3))= decode(v_employment_category,'FR',
                                   v_fr_min_range|| ' - '||v_fr_max_range,
                                   v_min_range||    ' - ' ||v_max_range) and
          upper(ltrim(rtrim(segment4)))
                =upper(ltrim(rtrim(v_employment_category))) and
          segment21 = v_naic_code;

        else

        hr_utility.trace('Form3: Updation Designated Grp: k = 3. M ');
        --hr_utility.trace('Form3: v_meaning: ' || v_meaning);
        --hr_utility.trace('Form3: v_cma_province: ' || v_cma_province);
        --hr_utility.trace('Form3: v_employment_category: '
        --                                      || v_employment_category);
        --hr_utility.trace('Form3: v_fr_min_range: ' || to_char(v_fr_min_range));
        --hr_utility.trace('Form3: v_fr_max_range: ' || to_char(v_fr_max_range));

        update per_ca_ee_report_lines set
          segment14=nvl(segment14,0) + nvl(l.count,0),
          segment15=nvl(l.count,0)
        where
          request_id=p_request_id and
          context='FORM3' and
          ltrim(rtrim(segment1)) = decode(i,1,'PROVINCE',2,'CMA') and
          ltrim(rtrim(segment2)) = v_meaning and
          ltrim(rtrim(segment3)) = decode(v_employment_category,'FR',
                                   v_fr_min_range|| ' - '||v_fr_max_range,
                                   v_min_range||    ' - ' ||v_max_range) and
          upper(ltrim(rtrim(segment4)))
                      =upper(ltrim(rtrim(v_employment_category))) and
          segment21 = v_naic_code;
        end if;

      end if;
    end loop;
    end loop;

  end loop;
  end loop;


  for x in 1..14 loop

  if x = 1 then

   v_min_range := 0;
   v_max_range := 4999;

   v_fr_min_range := 0;
   v_fr_max_range := 14999;

  elsif x = 2 then

   v_min_range := 5000;
   v_max_range := 7499;

   v_fr_min_range := 15000;
   v_fr_max_range := 19999;

  elsif x = 3 then

   v_min_range := 7500;
   v_max_range := 9999;

   v_fr_min_range := 20000;
   v_fr_max_range := 24999;

  elsif x = 4 then

   v_min_range := 10000;
   v_max_range := 12499;

   v_fr_min_range := 25000;
   v_fr_max_range := 29999;

  elsif x = 5 then

   v_min_range := 12500;
   v_max_range := 14999;

   v_fr_min_range := 30000;
   v_fr_max_range := 34999;

  elsif x = 6 then

   v_min_range := 15000;
   v_max_range := 17499;

   v_fr_min_range := 35000;
   v_fr_max_range := 37499;

  elsif x = 7 then

   v_min_range := 17500;
   v_max_range := 19999;

   v_fr_min_range := 37500;
   v_fr_max_range := 39999;

  elsif x = 8 then

   v_min_range := 20000;
   v_max_range := 22499;

   v_fr_min_range := 40000;
   v_fr_max_range := 44999;

  elsif x = 9 then

   v_min_range := 22500;
   v_max_range := 24999;

   v_fr_min_range := 45000;
   v_fr_max_range := 49999;

   elsif x = 10 then

    v_min_range := 25000;
    v_max_range := 29999;

   v_fr_min_range := 50000;
   v_fr_max_range := 59999;

  elsif x = 11 then

   v_min_range := 30000;
   v_max_range := 34499;

   v_fr_min_range := 60000;
   v_fr_max_range := 69999;

  elsif x = 12 then

   v_min_range := 35000;
   v_max_range := 39999;

   v_fr_min_range := 70000;
   v_fr_max_range := 84999;

  elsif x = 13 then

   v_min_range := 40000;
   v_max_range := 49999;

   v_fr_min_range := 85000;
   v_fr_max_range := 99999;

  elsif x = 14 then

   v_min_range := 50000;
   v_max_range := 9999999;

   v_fr_min_range := 100000;
   v_fr_max_range := 9999999;

  end if;

  for l_pc_count in 1..2 loop

    if l_pc_count = 1 then
      pc_count := 1;
    else
      pc_count := 2;
    end if;

  for l_emp_cat in 1..3 loop

    if l_emp_cat = 1 then
      emp_cat := 'FR';
    elsif l_emp_cat = 2 then
      emp_cat := 'PR';
    elsif l_emp_cat = 3 then
      emp_cat := 'PT';
    end if;

  for l in cur_notfound(x,
                        pc_count,
                        emp_cat)
  loop

  per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

  insert into per_ca_ee_report_lines
    ( request_id,
     line_number,
     context,
     segment1,
     segment2,
     segment3,
     segment4,
     segment5,
     segment6,
     segment7,
     segment8,
     segment9,
     segment10,
     segment11,
     segment12,
     segment13,
     segment14,
     segment15,
     segment16,
     segment21) values
    ( p_request_id,
     per_ca_ee_extract_pkg.k,
     'FORM3',
     decode(pc_count,1,'PROVINCE','CMA'),
     l.provcma_name,
     decode(emp_cat,'FR',v_fr_min_range||' - '||v_fr_max_range,
                    v_min_range||' - '||v_max_range),
     emp_cat,
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     '0',
     v_naic_code);

  end loop;

  end loop; --End loop emp_cat.

  end loop; -- End loop pc_count
  end loop;

  for count_national in cur_count_national loop

  hr_utility.trace('Form3: cur_count_national. ');

           insert into per_ca_ee_report_lines
           (request_id,
            line_number,
            context,
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment21) values
            ( p_request_id,
             per_ca_ee_extract_pkg.k,
             'FORM3',
             'NATIONAL',
             count_national.segment3,
             count_national.segment4,
             count_national.segment5,
             count_national.segment6,
             count_national.segment7,
             count_national.segment8,
             count_national.segment9,
             count_national.segment10,
             count_national.segment11,
             count_national.segment12,
             count_national.segment13,
             count_national.segment14,
             count_national.segment15,
             count_national.segment16,
             v_naic_code);

  end loop; --End of loop cur_national_count

  prev_naic_code := v_naic_code;

  end loop; -- End loop for cur_naic


return 1;
end;

end form3;

function form4(p_business_group_id in number,
               p_request_id     in number,
               p_year           in varchar2,
               p_date_tmp_emp   in date) return number is

  l_year_start date;
  l_year_end date;

begin

  l_year_start :=  trunc(to_date(p_year,'YYYY'),'Y');
  l_year_end   :=  add_months(trunc(to_date(p_year,'YYYY'),'Y'), 12) -1;

declare

  cursor cur_naic is
  select
    pert.segment4	naic_code
  from
    per_ca_ee_report_lines	pert
  where
    pert.request_id = p_request_id and
    pert.context = 'FORM12';

  v_naic_code			hr_lookups.lookup_code%TYPE;

  cursor cur_hired_total is
  select
    count(distinct count_total)	count_total,
    meaning 			meaning,
    sex  			sex,
    employment_category 	employment_category,
    province 			province
   from
   (
     select
       paf.person_id 			count_total,
       hl.meaning 			meaning,
       ppf.sex  			sex,
       substr(employment_category,1,2) 	employment_category,
       hl1.region_1 			province
     from
       hr_lookups hl,
       per_jobs pj,
       per_assignments_f paf,
       per_people_f ppf,
       per_person_types ppt,
       hr_locations hl1,
       per_ca_ee_report_lines pert,
       hr_lookups hl2,
       hr_soft_coding_keyflex hsck
     where
       hl.lookup_type='EEOG' and
       upper(ltrim(rtrim(hl.lookup_code)))
              = upper(ltrim(rtrim(pj.job_information1))) and
       upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
       pj.job_id=paf.job_id and
       paf.primary_flag = 'Y' and
       --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
       --  paf.effective_start_date and
       --  paf.effective_end_date   and
       --paf.effective_start_date < l_year_end and
       --paf.effective_end_date  > l_year_start and
       ppf.start_date between
         paf.effective_start_date and
         paf.effective_end_date   and
       paf.employment_category is not null and
       substr(employment_category,1,2) in ('FR','PR','PT') and
       paf.person_id=ppf.person_id and
       --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
        -- ppf.effective_start_date and
        -- ppf.effective_end_date   and
       ppf.effective_start_date < l_year_end and
       ppf.effective_end_date  > l_year_start and
       ppf.start_date between l_year_start and
                              l_year_end and
       ppf.person_type_id=ppt.person_type_id and
       upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
       ppf.business_group_id=p_business_group_id and
       paf.location_id=hl1.location_id and
       hl1.region_1=hl2.lookup_code and
       hl2.lookup_type='CA_PROVINCE' and
       pert.request_id=p_request_id and
       hl2.meaning=pert.segment2 and
       --pert.segment4 = 'Y' and
       pert.context='FORM14' and
       pert.segment1='PROVINCE' and
      (
      (
       hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
       hsck.segment6 is not null and
       hsck.segment6 = v_naic_code
      )
      OR
      (
       hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
       hsck.segment6 is null and
       hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
	   where request_id = p_request_id and
	         context = 'FORM13' and
	         segment1 = 'NAIC' and
	         segment2 = v_naic_code)
     )
     ) and
     exists
     (
         select 'X'
           from per_pay_proposals_v2 pppv
         where
           pppv.assignment_id = paf.assignment_id and
           pppv.approved = 'Y' and
           pppv.change_date <= l_year_end
     )
   union all
     select
       paf.person_id 			count_total,
       hl.meaning 			meaning,
       ppf.sex  			sex,
       'FR'                      	employment_category,
       hl1.region_1 			province
     from
       hr_lookups hl,
       per_jobs pj,
       per_assignments_f paf,
       per_people_f ppf,
       per_person_types ppt,
       hr_locations hl1,
       per_ca_ee_report_lines pert,
       hr_lookups hl2,
       hr_soft_coding_keyflex hsck
     where
       hl.lookup_type='EEOG' and
       upper(ltrim(rtrim(hl.lookup_code)))
                     =upper(ltrim(rtrim(pj.job_information1))) and
       upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
       pj.job_id=paf.job_id and
       paf.primary_flag = 'Y' and
       --l_year_end between
       --  paf.effective_start_date and
       --  paf.effective_end_date   and
       --paf.effective_start_date < l_year_end and
       --paf.effective_end_date  > l_year_start and
       ppf.start_date between
         paf.effective_start_date and
         paf.effective_end_date   and
       (paf.employment_category is null OR
       substr(paf.employment_category,1,2) not in ('FR','PR','PT')) and
       paf.person_id=ppf.person_id and
       --l_year_end between
       --  ppf.effective_start_date and
       --  ppf.effective_end_date   and
       ppf.effective_start_date < l_year_end and
       ppf.effective_end_date  > l_year_start and
       ppf.start_date between l_year_start and
                              l_year_end and
       ppf.person_type_id=ppt.person_type_id and
       upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
       ppf.business_group_id=p_business_group_id and
       paf.location_id=hl1.location_id and
       hl1.region_1=hl2.lookup_code and
       hl2.lookup_type='CA_PROVINCE' and
       pert.request_id=p_request_id and
       hl2.meaning=pert.segment2 and
       --pert.segment4 = 'Y' and
       pert.context='FORM14' and
       pert.segment1='PROVINCE' and
      (
      (
       hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
       hsck.segment6 is not null and
       hsck.segment6 = v_naic_code
      )
      OR
      (
       hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
       hsck.segment6 is null and
       hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
	   where request_id = p_request_id and
	         context = 'FORM13' and
	         segment1 = 'NAIC' and
	         segment2 = v_naic_code)
     )
     ) and
     exists
     (
         select 'X'
           from per_pay_proposals_v2 pppv
         where
           pppv.assignment_id = paf.assignment_id and
           pppv.approved = 'Y' and
           pppv.change_date <= l_year_end
     ) -- End of Exists
    )
    group by province,meaning,employment_category,sex
    order by province,meaning,employment_category,sex;

    v_count                 	number(10);
    v_meaning               	hr_lookups.meaning%TYPE;
    v_employment_category   	per_assignments_f.employment_category%TYPE;
    v_sex                   	per_people_f.sex%TYPE;
    v_province    		hr_locations.region_1%TYPE;
    prev_meaning                hr_lookups.meaning%TYPE := 'test';
    prev_employment_category    per_assignments_f.employment_category%TYPE := 'test';
    prev_sex                    per_people_f.sex%TYPE := 'test';
    prev_naic_code              hr_lookups.lookup_code%TYPE;

  cursor cur_meaning is
  select
    meaning
  from
    hr_lookups
  where
    upper(ltrim(rtrim(lookup_type)))='CA_PROVINCE' and
    upper(ltrim(rtrim(lookup_code)))=upper(ltrim(rtrim(v_province)));

  v_province_name   		hr_lookups.meaning%TYPE;
  prev_province_name  		hr_lookups.meaning%TYPE;

  cursor cur_hired(desig NUMBER) is
  select
    count(distinct person_id) 	count,
    meaning 			meaning,
    employment_category 	employment_category,
    sex  			sex,
    province			province
  from
  (
    select
      paf.person_id 			person_id,
      hl.meaning 			meaning,
      substr(paf.employment_category,1,2) employment_category,
      ppf.sex  				sex,
      hl1.region_1 			province
   from
      hr_lookups hl,
      per_jobs pj,
      per_assignments_f paf,
      per_people_f ppf,
      per_person_types ppt,
      hr_locations hl1,
      per_ca_ee_report_lines pert,
      hr_lookups hl2,
      hr_soft_coding_keyflex hsck
   where
      upper(ltrim(rtrim(hl.lookup_type)))='EEOG' and
      upper(ltrim(rtrim(hl.lookup_code)))=
              upper(ltrim(ltrim(pj.job_information1))) and
      upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
      pj.job_id=paf.job_id and
      paf.primary_flag = 'Y' and
      --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      --  paf.effective_start_date and
      --  paf.effective_end_date   and
      --paf.effective_start_date < l_year_end and
      --paf.effective_end_date  > l_year_start and
      ppf.start_date between
        paf.effective_start_date and
        paf.effective_end_date   and
      paf.employment_category is not null and
      substr(paf.employment_category,1,2) in ('FR','PR','PT') and
      paf.person_id=ppf.person_id and
      --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      --  ppf.effective_start_date and
      --  ppf.effective_end_date   and
      ppf.effective_start_date < l_year_end and
      ppf.effective_end_date  > l_year_start and
      ppf.start_date between l_year_start and
                             l_year_end and
      ppf.person_type_id=ppt.person_type_id and
      upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
      ppf.business_group_id=p_business_group_id and
      paf.location_id=hl1.location_id and
      hl1.region_1=hl2.lookup_code and
      hl2.lookup_type='CA_PROVINCE' and
      pert.request_id=p_request_id and
      hl2.meaning=pert.segment2 and
      --pert.segment4 = 'Y' and
      pert.context='FORM14' and
      pert.segment1='PROVINCE' and
      decode(desig,1,ppf.per_information5,
        2,ppf.per_information6,
        3,ppf.per_information7)='Y' and
      (
      (
       hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
       hsck.segment6 is not null and
       hsck.segment6 = v_naic_code
      )
      OR
      (
       hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
       hsck.segment6 is null and
       hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
	   where request_id = p_request_id and
	         context = 'FORM13' and
	         segment1 = 'NAIC' and
	         segment2 = v_naic_code)
     )
     ) and
     exists
     (
         select 'X'
           from per_pay_proposals_v2 pppv
         where
           pppv.assignment_id = paf.assignment_id and
           pppv.approved = 'Y' and
           pppv.change_date <= l_year_end
     ) -- End of Exists
    union all
    select
      paf.person_id 			person_id,
      hl.meaning 			meaning,
      'FR' 			        employment_category,
      ppf.sex  				sex,
      hl1.region_1 			province
   from
      hr_lookups hl,
      per_jobs pj,
      per_assignments_f paf,
      per_people_f ppf,
      per_person_types ppt,
      hr_locations hl1,
      per_ca_ee_report_lines pert,
      hr_lookups hl2,
      hr_soft_coding_keyflex hsck
   where
      upper(ltrim(rtrim(hl.lookup_type)))='EEOG' and
      upper(ltrim(rtrim(hl.lookup_code)))
          = upper(ltrim(ltrim(pj.job_information1))) and
      upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
      pj.job_id=paf.job_id and
      paf.primary_flag = 'Y' and
      --l_year_end between
      --  paf.effective_start_date and
      --  paf.effective_end_date   and
      --  paf.effective_start_date < l_year_end and
      --  paf.effective_end_date  > l_year_start and
      ppf.start_date between
        paf.effective_start_date and
        paf.effective_end_date   and
      (paf.employment_category is null OR
       substr(paf.employment_category,1,2) not in ('FR','PR','PT')) and
      paf.person_id=ppf.person_id and
      --l_year_end between
      --  ppf.effective_start_date and
      --  ppf.effective_end_date   and
      ppf.effective_start_date < l_year_end and
      ppf.effective_end_date  > l_year_start and
      ppf.start_date between l_year_start and
                             l_year_end and
      ppf.person_type_id=ppt.person_type_id and
      upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
      ppf.business_group_id=p_business_group_id and
      paf.location_id=hl1.location_id and
      hl1.region_1=hl2.lookup_code and
      hl2.lookup_type='CA_PROVINCE' and
      pert.request_id=p_request_id and
      hl2.meaning=pert.segment2 and
      --pert.segment4 = 'Y' and
      pert.context='FORM14' and
      pert.segment1='PROVINCE' and
      decode(desig,1,ppf.per_information5,
        2,ppf.per_information6,
        3,ppf.per_information7)='Y' and
      (
      (
       hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
       hsck.segment6 is not null and
       hsck.segment6 = v_naic_code
      )
      OR
      (
       hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
       hsck.segment6 is null and
       hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
	   where request_id = p_request_id and
	         context = 'FORM13' and
	         segment1 = 'NAIC' and
	         segment2 = v_naic_code)
     )
     ) and
     exists
     (
         select 'X'
           from per_pay_proposals_v2 pppv
         where
           pppv.assignment_id = paf.assignment_id and
           pppv.approved = 'Y' and
           pppv.change_date <= l_year_end
     ) -- End of Exists
    )
    group by province,meaning,employment_category,sex
    order by province,meaning,employment_category,sex;

  cursor cur_eeog is
  select
    meaning
  from
    hr_lookups
  where
   lookup_type='EEOG';

  cursor cur_notfound(p_emp_cat number) is
  select
    segment2,
    v_meaning,
    decode(p_emp_cat,1,'FR',2,'PR',3,'PT') emp_category
  from
    per_ca_ee_report_lines where
    request_id=p_request_id and
    context='FORM14' and
    segment1='PROVINCE' and
    segment3 <> '0'
  minus
  select
    segment2,
    segment3,
    segment4
  from
    per_ca_ee_report_lines
  where
    request_id=p_request_id and
    context='FORM4' and
    segment1='PROVINCE'and
    segment21 = v_naic_code;

   cursor cur_count_national is
   select
     segment3,
     segment4,
     sum(to_number(segment5))		segment5,
     sum(to_number(segment6))		segment6,
     sum(to_number(segment7))		segment7,
     sum(to_number(segment8))		segment8,
     sum(to_number(segment9))		segment9,
     sum(to_number(segment10))		segment10,
     sum(to_number(segment11))		segment11,
     sum(to_number(segment12))		segment12,
     sum(to_number(segment13))		segment13,
     sum(to_number(segment14))		segment14,
     sum(to_number(segment15))		segment15,
     sum(to_number(segment16))		segment16
   from
     per_ca_ee_report_lines
   where
     request_id = p_request_id and
     context = 'FORM4' and
     segment1 = 'PROVINCE' and
     segment21 = v_naic_code
   group by segment3,segment4;

begin

   hr_utility.trace('Form4 starts Here !!!!!!');

   for naic in cur_naic loop

     v_naic_code := naic.naic_code;

     hr_utility.trace('Form4: v_naic = ' || v_naic_code );

   for j in cur_hired_total
   loop

      v_count           	:= j.count_total;
      v_meaning         	:= j.meaning;
      v_employment_category   	:= j.employment_category;
      v_sex       		:= j.sex;
      v_province    		:= j.province;

      hr_utility.trace('Form4: v_meaning = ' || v_meaning );

  open cur_meaning;
  fetch cur_meaning into v_province_name;
  close cur_meaning;

  if ((ltrim(rtrim(v_province_name))<>ltrim(rtrim(prev_province_name))) or
        (ltrim(rtrim(prev_meaning)) <> ltrim(rtrim(v_meaning))) or
        (ltrim(rtrim(prev_naic_code)) <> ltrim(rtrim(v_naic_code))) or
        (ltrim(rtrim(prev_employment_category)) <> ltrim(rtrim(v_employment_category)))) then

     per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

           insert into per_ca_ee_report_lines
           (request_id,
            line_number,
            context,
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
      	    segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment16,
            segment21) values
            ( p_request_id,
             per_ca_ee_extract_pkg.k,
             'FORM4',
            'PROVINCE',
            v_province_name,
             v_meaning,
             v_employment_category,
             nvl(v_count,0),
             decode(v_sex,'F',v_count,0),
             decode(v_sex,'M',v_count,0),
             '0',
             '0',
             '0',
             '0',
             '0',
             '0',
             '0',
             '0',
             '0',
            v_naic_code);

        else

           if prev_province_name = v_province_name and
           prev_meaning = v_meaning and
           prev_naic_code = v_naic_code and
           prev_employment_category = v_employment_category and
           prev_sex <> v_sex then

           if v_sex = 'M' then

             update per_ca_ee_report_lines set
                segment7=nvl(v_count,0),
                segment5=segment5 + nvl(v_count,0)
             where request_id=p_request_id and
                   line_number=per_ca_ee_extract_pkg.k and
                   context='FORM4' and
                   segment1='PROVINCE' and
                   segment2=v_province_name and
                   segment3=v_meaning and
                   segment4=v_employment_category and
                   segment21 = v_naic_code;

           elsif v_sex = 'F' then

             update per_ca_ee_report_lines set
                segment6=nvl(v_count,0),
                segment5=segment5 + nvl(v_count,0)
             where request_id=p_request_id and
                line_number=per_ca_ee_extract_pkg.k and
                context='FORM4' and
                segment1='PROVINCE' and
                segment2=v_province_name and
                segment3=v_meaning and
                segment4=v_employment_category and
                segment21 = v_naic_code;

           end if;

           end if;
        end if;

        prev_meaning 			:= v_meaning;
        prev_employment_category 	:= v_employment_category;
        prev_sex                	:= v_sex;
        prev_province_name 		:= v_province_name;
        prev_naic_code     		:= v_naic_code;

        end loop; -- End loop cur_hired_total

   for i in 1..3 loop

                for j in cur_hired(i)
                loop

                v_sex := j.sex;
                v_employment_category := j.employment_category;
                v_meaning := j.meaning;
                v_count := j.count;
    		v_province    := j.province;

    open cur_meaning;
    fetch cur_meaning into v_province_name;
    close cur_meaning;

                if i = 1 then
                        if v_sex = 'M' then
                                update per_ca_ee_report_lines set
                                  segment8 = nvl(segment8,0) + nvl(v_count,0),
                                  segment10 = nvl(v_count,0)
                                where
                                  request_id = p_request_id and
                                  context='FORM4' and
                                  segment1 = 'PROVINCE' and
          segment2 = v_province_name and
                                  segment3 = v_meaning and
                                  segment4 = v_employment_category;
                        elsif v_sex = 'F' then
                                update per_ca_ee_report_lines set
                                  segment8 = nvl(segment8,0) + nvl(v_count,0),
                                  segment9 = nvl(v_count,0)
                                where
                                  request_id = p_request_id and
                                  context='FORM4' and
                                  segment1 = 'PROVINCE' and
          segment2 = v_province_name and
                                  segment3 = v_meaning and
                                  segment4 = v_employment_category;
                        end if;
                elsif i = 2 then
                        if v_sex = 'M' then
                                update per_ca_ee_report_lines set
                                  segment11 = nvl(segment11,0) + nvl(v_count,0),
                                  segment13 = nvl(v_count,0)
                                where
                                  request_id = p_request_id and
                                  context='FORM4' and
                                  segment1 = 'PROVINCE' and
          segment2 = v_province_name and
                                  segment3 = v_meaning and
                                  segment4 = v_employment_category;
                        elsif v_sex = 'F' then
                                update per_ca_ee_report_lines set
                                  segment11 = nvl(segment11,0) + nvl(v_count,0),
                                  segment12 = nvl(v_count,0)
        where
                                  request_id = p_request_id and
                                  context='FORM4' and
                                  segment1 = 'PROVINCE' and
          segment2 = v_province_name and
                                  segment3 = v_meaning and
                                  segment4 = v_employment_category;
                        end if;
    elsif i = 3 then
                        if v_sex = 'M' then
                                update per_ca_ee_report_lines set
                                  segment14 = nvl(segment14,0) + nvl(v_count,0),
                                  segment16 = nvl(v_count,0)
                                where
                                  request_id = p_request_id and
                                  context='FORM4' and
                                  segment1 = 'PROVINCE' and
          segment2 = v_province_name and
                                  segment3 = v_meaning and
                                  segment4 = v_employment_category;
                        elsif v_sex = 'F' then
                                update per_ca_ee_report_lines set
                                  segment14 = nvl(segment14,0) + nvl(v_count,0),
                                  segment15 = nvl(v_count,0)
                                where
                                  request_id = p_request_id and
                                  context='FORM4' and
                                  segment1 = 'PROVINCE' and
          segment2 = v_province_name and
                                  segment3 = v_meaning and
                                  segment4 = v_employment_category;
                        end if;
                end if;
                end loop; -- End loop cur_hired

        end loop; -- End loop for designated group

   for i in cur_eeog loop

    v_meaning := i.meaning;

    hr_utility.trace('Form4: cur_eeog: v_eeog' || v_meaning);

     for emp_cat in 1..3 loop

     for x in cur_notfound(emp_cat) loop

     per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

           insert into per_ca_ee_report_lines
           (request_id,
            line_number,
            context,
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment16,
            segment21) values
            ( p_request_id,
             per_ca_ee_extract_pkg.k,
             'FORM4',
             'PROVINCE',
             x.segment2,
             v_meaning,
             x.emp_category,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             v_naic_code);

    end loop;

   end loop;

  end loop;


  hr_utility.trace('Form4: End of loop cur_naic');

  for count_national in cur_count_national loop

  hr_utility.trace('Form4: cur_count_national. ');

           insert into per_ca_ee_report_lines
           (request_id,
            line_number,
            context,
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment21) values
            ( p_request_id,
             per_ca_ee_extract_pkg.k,
             'FORM4',
             'NATIONAL',
             count_national.segment3,
             count_national.segment4,
             count_national.segment5,
             count_national.segment6,
             count_national.segment7,
             count_national.segment8,
             count_national.segment9,
             count_national.segment10,
             count_national.segment11,
             count_national.segment12,
             count_national.segment13,
             count_national.segment14,
             count_national.segment15,
             count_national.segment16,
             v_naic_code);

  end loop; -- End loop cur_count_total

  prev_naic_code     		:= v_naic_code;

  end loop; -- End of loop cur_naic


  return 1;

end;

end form4;
/*
function form5(p_business_group_id in number,
               p_request_id     in number,
               p_year           in varchar2,
               p_date_tmp_emp   in date) return number is

  l_year_start date;
  l_year_end date;

begin

  l_year_start :=  trunc(to_date(p_year,'YYYY'),'Y');
  l_year_end   :=  add_months(trunc(to_date(p_year,'YYYY'),'Y'), 12) -1;

declare

  cursor cur_naic is
  select
    pert.segment4       naic_code
  from
    per_ca_ee_report_lines      pert
  where
    pert.request_id = p_request_id and
    pert.context = 'FORM12';

  v_naic_code			hr_lookups.lookup_code%TYPE;

  cursor cur_promoted_total is
  select
    count(distinct count_total) count_total,
    meaning 			meaning,
    sex 			sex,
    employment_category 	employment_category,
    province			province
  from
  (
     select
       paf.person_id 				count_total,
       hl.meaning 				meaning,
       ppf.sex 					sex,
       substr(paf.employment_category,1,2) 	employment_category,
       hl1.region_1 				province
     from
       hr_lookups hl,
       per_jobs pj,
       per_assignments_f paf,
       per_people_f ppf,
       per_person_types ppt,
       hr_locations hl1,
       per_ca_ee_report_lines pert,
       hr_lookups hl2,
       hr_soft_coding_keyflex hsck
     where
       hl.lookup_type='EEOG' and
       upper(ltrim(rtrim(hl.lookup_code)))
           =upper(ltrim(rtrim(pj.job_information1))) and
       upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
       pj.job_id=paf.job_id and
       paf.primary_flag = 'Y' and
       --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
       --  paf.effective_start_date and
       --  paf.effective_end_date   and
       ppf.start_date between
         paf.effective_start_date and
         paf.effective_end_date and
       paf.employment_category is not null and
       substr(paf.employment_category,1,2) in ('FR','PR','PT') and
       paf.person_id=ppf.person_id and
       --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
       --  ppf.effective_start_date and
       --  ppf.effective_end_date   and
       ppf.effective_start_date < l_year_end and
       ppf.effective_end_date  > l_year_start and
       ppf.person_type_id=ppt.person_type_id and
       upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
       ppf.business_group_id=p_business_group_id and
       paf.location_id=hl1.location_id and
       hl1.region_1=hl2.lookup_code and
       hl2.lookup_type='CA_PROVINCE' and
       pert.request_id=p_request_id and
       hl2.meaning=pert.segment2 and
       --pert.segment4 = 'Y' and
       pert.context='FORM14' and
       pert.segment1='PROVINCE' and
       (
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is not null and
         hsck.segment6 = v_naic_code
       )
       OR
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is null and
         hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
                        where request_id = p_request_id and
                              context = 'FORM13' and
                              segment1 = 'NAIC' and
                              segment2 = v_naic_code)
      )
      ) and
      exists
      (
         select 'X'
           from per_pay_proposals_v2 pppv
         where
           pppv.assignment_id = paf.assignment_id and
           pppv.approved = 'Y' and
           pppv.change_date between l_year_start and
                                    l_year_end and
           pppv.proposal_reason =
           (
             select 	lookup_code
             from 	hr_lookups
             where	lookup_type = 'PROPOSAL_REASON' and
	          	upper(meaning) = 'PROMOTION'
           )
       )
    union all
     select
       paf.person_id 				count_total,
       hl.meaning 				meaning,
       ppf.sex 					sex,
       'FR' 	                                employment_category,
       hl1.region_1 				province
     from
       hr_lookups hl,
       per_jobs pj,
       per_assignments_f paf,
       per_people_f ppf,
       per_person_types ppt,
       hr_locations hl1,
       per_ca_ee_report_lines pert,
       hr_lookups hl2,
      hr_soft_coding_keyflex hsck
     where
       hl.lookup_type='EEOG' and
       upper(ltrim(rtrim(hl.lookup_code)))
                     =upper(ltrim(rtrim(pj.job_information1))) and
       upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
       pj.job_id=paf.job_id and
       paf.primary_flag = 'Y' and
       --l_year_end between
       --  ppf.effective_start_date and
       --  ppf.effective_end_date   and
       ppf.start_date between
         paf.effective_start_date and
         paf.effective_end_date   and
       (paf.employment_category is null OR
       substr(paf.employment_category,1,2) not in ('FR','PR','PT')) and
       paf.person_id=ppf.person_id and
       ppf.effective_start_date < l_year_end and
       ppf.effective_end_date  > l_year_start and
       --l_year_end between
       --  ppf.effective_start_date and
       --  ppf.effective_end_date   and
       ppf.person_type_id=ppt.person_type_id and
       upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
       ppf.business_group_id=p_business_group_id and
       paf.location_id=hl1.location_id and
       hl1.region_1=hl2.lookup_code and
       hl2.lookup_type='CA_PROVINCE' and
       pert.request_id=p_request_id and
       hl2.meaning=pert.segment2 and
       --pert.segment4 = 'Y' and
       pert.context='FORM14' and
       pert.segment1='PROVINCE' and
       (
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is not null and
         hsck.segment6 = v_naic_code
       )
       OR
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is null and
         hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
           where request_id = p_request_id and
                 context = 'FORM13' and
                 segment1 = 'NAIC' and
                 segment2 = v_naic_code)
      )
      ) and
       exists
       (
         select 'X'
           from per_pay_proposals_v2 pppv
         where
           pppv.assignment_id = paf.assignment_id and
           pppv.approved = 'Y' and
           pppv.change_date between l_year_start and
                                    l_year_end and
           pppv.proposal_reason =
           (
             select 	lookup_code
             from 	hr_lookups
             where	lookup_type = 'PROPOSAL_REASON' and
	          	upper(meaning) = 'PROMOTION'
           )
       )
    )
    group by province,meaning,employment_category,sex
    order by province,meaning,employment_category,sex;

    v_count                 number(10);
    v_meaning               hr_lookups.meaning%TYPE;
    v_employment_category   per_assignments_f.employment_category%TYPE;
    v_sex                   per_people_f.sex%TYPE;
    v_province              hr_locations.region_1%TYPE;
    prev_meaning            hr_lookups.meaning%TYPE := 'test';
    prev_employment_category per_assignments_f.employment_category%TYPE := 'test';
    prev_sex                per_people_f.sex%TYPE := 'test';
    prev_naic_code          hr_lookups.lookup_code%TYPE;

  cursor cur_meaning is select
    meaning
  from
    hr_lookups
  where
    upper(ltrim(rtrim(lookup_type)))='CA_PROVINCE' and
    upper(ltrim(rtrim(lookup_code)))=upper(ltrim(rtrim(v_province)));

  v_province_name         hr_lookups.meaning%TYPE;
  prev_province_name      hr_lookups.meaning%TYPE;

  cursor cur_promoted(desig NUMBER) is
  select
    count(distinct person_id) 		count,
    meaning 				meaning,
    employment_category			employment_category,
    sex   				sex,
    province 				province
  from
  (
    select
      paf.person_id 				person_id,
      hl.meaning 				meaning,
      substr(paf.employment_category,1,2) 	employment_category,
      ppf.sex 					sex,
      hl1.region_1 				province
    from
      hr_lookups hl,
      per_jobs pj,
      per_assignments_f paf,
      per_people_f ppf,
      per_person_types ppt,
      hr_locations hl1,
      per_ca_ee_report_lines pert,
      hr_lookups hl2,
      hr_soft_coding_keyflex hsck
    where
      upper(ltrim(rtrim(hl.lookup_type)))='EEOG' and
      upper(ltrim(rtrim(hl.lookup_code)))=upper(ltrim(ltrim(pj.job_information1))) and
      upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
      pj.job_id=paf.job_id and
      paf.primary_flag = 'Y' and
      --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      --   ppf.effective_start_date and
      --   ppf.effective_end_date   and
      ppf.start_date between
        paf.effective_start_date and
        paf.effective_end_date and
      paf.employment_category is not null and
      substr(paf.employment_category,1,2) in ('FR','PR','PT')and
      paf.person_id=ppf.person_id and
      --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      --  ppf.effective_start_date and
      --  ppf.effective_end_date   and
      ppf.effective_start_date < l_year_end and
      ppf.effective_end_date  > l_year_start and
      ppf.person_type_id=ppt.person_type_id and
      upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
      ppf.business_group_id=p_business_group_id and
      paf.location_id=hl1.location_id and
      hl1.region_1=hl2.lookup_code and
      hl2.lookup_type='CA_PROVINCE' and
      pert.request_id=p_request_id and
      hl2.meaning=pert.segment2 and
      --pert.segment4 = 'Y' and
      pert.context='FORM14' and
      pert.segment1='PROVINCE' and
      decode(desig,1,per_information5,
        2,per_information6,
        3,per_information7)='Y' and
       (
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is not null and
         hsck.segment6 = v_naic_code
       )
       OR
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is null and
         hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
           where request_id = p_request_id and
                 context = 'FORM13' and
                 segment1 = 'NAIC' and
                 segment2 = v_naic_code)
      )
      ) and
      exists
      (
        select 'X'
          from per_pay_proposals_v2 pppv
        where
          pppv.assignment_id = paf.assignment_id and
          pppv.change_date between l_year_start and
 			    l_year_end and
          pppv.approved = 'Y' and
          pppv.proposal_reason =
          (
            select 	lookup_code
            from 	hr_lookups
            where	lookup_type = 'PROPOSAL_REASON' and
	          	upper(meaning) = 'PROMOTION'
          )
      )
    union all
    select
      paf.person_id 				person_id,
      hl.meaning 				meaning,
      'FR'             	                        employment_category,
      ppf.sex 					sex,
      hl1.region_1 				province
    from
      hr_lookups hl,
      per_jobs pj,
      per_assignments_f paf,
      per_people_f ppf,
      per_person_types ppt,
      hr_locations hl1,
      per_ca_ee_report_lines pert,
      hr_lookups hl2,
      hr_soft_coding_keyflex hsck
    where
      upper(ltrim(rtrim(hl.lookup_type)))='EEOG' and
      upper(ltrim(rtrim(hl.lookup_code)))=upper(ltrim(ltrim(pj.job_information1))) and
      upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
      pj.job_id=paf.job_id and
      paf.primary_flag = 'Y' and
      --l_year_end between
      --  paf.effective_start_date and
      --  paf.effective_end_date   and
      ppf.effective_start_date between
        paf.effective_start_date and
        paf.effective_end_date   and
      (paf.employment_category is null OR
       substr(paf.employment_category,1,2) not in ('FR','PR','PT'))and
      paf.person_id=ppf.person_id and
      --l_year_end between
      --  ppf.effective_start_date and
      --  ppf.effective_end_date   and
      ppf.effective_start_date < l_year_end and
      ppf.effective_end_date  > l_year_start and
      ppf.person_type_id=ppt.person_type_id and
      upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
      ppf.business_group_id=p_business_group_id and
      paf.location_id=hl1.location_id and
      hl1.region_1=hl2.lookup_code and
      hl2.lookup_type='CA_PROVINCE' and
      pert.request_id=p_request_id and
      hl2.meaning=pert.segment2 and
      --pert.segment4 = 'Y' and
      pert.context='FORM14' and
      pert.segment1='PROVINCE' and
      decode(desig,1,per_information5,
        2,per_information6,
        3,per_information7)='Y' and
       (
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is not null and
         hsck.segment6 = v_naic_code
       )
       OR
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is null and
         hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
           where request_id = p_request_id and
                 context = 'FORM13' and
                 segment1 = 'NAIC' and
                 segment2 = v_naic_code)
      )
      ) and
      exists
      (
        select 'X'
          from per_pay_proposals_v2 pppv
        where
          pppv.assignment_id = paf.assignment_id and
          pppv.approved = 'Y'and
          pppv.change_date between l_year_start and
 			    l_year_end and
          pppv.proposal_reason =
          (
            select 	lookup_code
            from 	hr_lookups
            where	lookup_type = 'PROPOSAL_REASON' and
	          	upper(meaning) = 'PROMOTION'
          )
      )
   )
   group by province,meaning,employment_category,sex
   order by province,meaning,employment_category,sex;

  cursor cur_eeog is
  select
    meaning
  from
    hr_lookups
  where
   lookup_type='EEOG';

  cursor cur_notfound(p_emp_cat number) is
  select
    segment2,
    v_meaning,
    decode(p_emp_cat,1,'FR',2,'PR',3,'PT') emp_category
  from
    per_ca_ee_report_lines where
    request_id=p_request_id and
    context='FORM14' and
    segment1='PROVINCE' and
    segment3 <> '0'
  minus
  select
    segment2,
    segment3,
    segment4
  from
    per_ca_ee_report_lines
  where
    request_id=p_request_id and
    context='FORM5' and
    segment1='PROVINCE'and
    segment21 = v_naic_code;

  cursor cur_count_national is
  select
     segment3,
     segment4,
     sum(to_number(segment5))           segment5,
     sum(to_number(segment6))           segment6,
     sum(to_number(segment7))           segment7,
     sum(to_number(segment8))           segment8,
     sum(to_number(segment9))           segment9,
     sum(to_number(segment10))          segment10,
     sum(to_number(segment11))          segment11,
     sum(to_number(segment12))          segment12,
     sum(to_number(segment13))          segment13,
     sum(to_number(segment14))          segment14,
     sum(to_number(segment15))          segment15,
     sum(to_number(segment16))          segment16
   from
     per_ca_ee_report_lines
   where
     request_id = p_request_id and
     context = 'FORM5' and
     segment1 = 'PROVINCE' and
     segment21 = v_naic_code
   group by segment3,segment4;

  cursor cur_count_promotions is
  select
    count(count_total) count_total,
    sex                         sex,
    employment_category         employment_category,
    province                    province
  from
  (
     select
       paf.person_id                            count_total,
       ppf.sex                                  sex,
       substr(paf.employment_category,1,2)      employment_category,
       hl1.region_1                             province
     from
       hr_lookups hl,
       per_jobs pj,
       per_assignments_f paf,
       per_people_f ppf,
       per_person_types ppt,
       hr_locations hl1,
       per_ca_ee_report_lines pert,
       hr_lookups hl2,
       hr_soft_coding_keyflex hsck,
       per_pay_proposals_v2 pppv
     where
       hl.lookup_type='EEOG' and
       upper(ltrim(rtrim(hl.lookup_code)))
           =upper(ltrim(rtrim(pj.job_information1))) and
       upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
       pj.job_id=paf.job_id and
       paf.primary_flag = 'Y' and
       --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
       --  paf.effective_start_date and
       --  paf.effective_end_date   and
       ppf.start_date between
         paf.effective_start_date and
         paf.effective_end_date and
       paf.employment_category is not null and
       substr(paf.employment_category,1,2) in ('FR','PR','PT') and
       paf.person_id=ppf.person_id and
       --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
       --  ppf.effective_start_date and
       --  ppf.effective_end_date   and
       ppf.effective_start_date < l_year_end and
       ppf.effective_end_date  >  l_year_start and
       ppf.person_type_id=ppt.person_type_id and
       upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
       ppf.business_group_id=p_business_group_id and
       paf.location_id=hl1.location_id and
       hl1.region_1=hl2.lookup_code and
       hl2.lookup_type='CA_PROVINCE' and
       pert.request_id=p_request_id and
       hl2.meaning=pert.segment2 and
       --pert.segment4 = 'Y' and
       pert.context='FORM14' and
       pert.segment1='PROVINCE' and
       (
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is not null and
         hsck.segment6 = v_naic_code
       )
       OR
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is null and
         hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
                        where request_id = p_request_id and
                              context = 'FORM13' and
                              segment1 = 'NAIC' and
                              segment2 = v_naic_code)
      )
      ) and
       pppv.assignment_id = paf.assignment_id and
       pppv.approved = 'Y' and
       pppv.change_date between l_year_start and
                                l_year_end and
       pppv.proposal_reason =
           (
             select     lookup_code
             from       hr_lookups
             where      lookup_type = 'PROPOSAL_REASON' and
                        upper(meaning) = 'PROMOTION'
           )
     union all
     select
       paf.person_id                            count_total,
       ppf.sex                                  sex,
       'FR'                                     employment_category,
       hl1.region_1                             province
     from
       hr_lookups hl,
       per_jobs pj,
       per_assignments_f paf,
       per_people_f ppf,
       per_person_types ppt,
       hr_locations hl1,
       per_ca_ee_report_lines pert,
       hr_lookups hl2,
       hr_soft_coding_keyflex hsck,
       per_pay_proposals_v2 pppv
     where
       hl.lookup_type='EEOG' and
       upper(ltrim(rtrim(hl.lookup_code)))
                     =upper(ltrim(rtrim(pj.job_information1))) and
       upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
       pj.job_id=paf.job_id and
       paf.primary_flag = 'Y' and
       --l_year_end between
       --  ppf.effective_start_date and
       --  ppf.effective_end_date   and
       ppf.start_date between
         paf.effective_start_date and
         paf.effective_end_date   and
       (paf.employment_category is null OR
       substr(paf.employment_category,1,2) not in ('FR','PR','PT')) and
       paf.person_id=ppf.person_id and
       ppf.effective_start_date < l_year_end and
       ppf.effective_end_date  > l_year_start and
       --l_year_end between
       --  ppf.effective_start_date and
       --  ppf.effective_end_date   and
       ppf.person_type_id=ppt.person_type_id and
       upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
       ppf.business_group_id=p_business_group_id and
       paf.location_id=hl1.location_id and
       hl1.region_1=hl2.lookup_code and
       hl2.lookup_type='CA_PROVINCE' and
       pert.request_id=p_request_id and
       hl2.meaning=pert.segment2 and
       --pert.segment4 = 'Y' and
       pert.context='FORM14' and
       pert.segment1='PROVINCE' and
       (
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is not null and
         hsck.segment6 = v_naic_code
       )
       OR
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is null and
         hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
           where request_id = p_request_id and
                 context = 'FORM13' and
                 segment1 = 'NAIC' and
                 segment2 = v_naic_code)
      )
      ) and
      pppv.assignment_id = paf.assignment_id and
      pppv.approved = 'Y' and
      pppv.change_date between l_year_start and
                               l_year_end and
      pppv.proposal_reason =
      (
        select     lookup_code
        from       hr_lookups
        where      lookup_type = 'PROPOSAL_REASON' and
                   upper(meaning) = 'PROMOTION'
      )
    )
    group by province,employment_category,sex
    order by province,employment_category,sex;


  cursor cur_total_promotions is
  select
    count(count_total) count_total,
    sex                         sex,
    employment_category         employment_category,
    province                    province
  from
  (
     select
       paf.person_id                            count_total,
       ppf.sex                                  sex,
       substr(paf.employment_category,1,2)      employment_category,
       hl1.region_1                             province
     from
       hr_lookups hl,
       per_jobs pj,
       per_assignments_f paf,
       per_people_f ppf,
       per_person_types ppt,
       hr_locations hl1,
       per_ca_ee_report_lines pert,
       hr_lookups hl2,
       hr_soft_coding_keyflex hsck,
       per_pay_proposals_v2 pppv
     where
       hl.lookup_type='EEOG' and
       upper(ltrim(rtrim(hl.lookup_code)))
           =upper(ltrim(rtrim(pj.job_information1))) and
       upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
       pj.job_id=paf.job_id and
       paf.primary_flag = 'Y' and
       --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
       --  paf.effective_start_date and
       --  paf.effective_end_date   and
       ppf.start_date between
         paf.effective_start_date and
         paf.effective_end_date and
       paf.employment_category is not null and
       substr(paf.employment_category,1,2) in ('FR','PR','PT') and
       paf.person_id=ppf.person_id and
       --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
       --  ppf.effective_start_date and
       --  ppf.effective_end_date   and
       ppf.effective_start_date < l_year_end and
       ppf.effective_end_date  > l_year_start and
       ppf.person_type_id=ppt.person_type_id and
       upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
       ppf.business_group_id=p_business_group_id and
       paf.location_id=hl1.location_id and
       hl1.region_1=hl2.lookup_code and
       hl2.lookup_type='CA_PROVINCE' and
       pert.request_id=p_request_id and
       hl2.meaning=pert.segment2 and
       --pert.segment4 = 'Y' and
       pert.context='FORM14' and
       pert.segment1='PROVINCE' and
       (
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is not null and
         hsck.segment6 = v_naic_code
       )
       OR
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is null and
         hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
                        where request_id = p_request_id and
                              context = 'FORM13' and
                              segment1 = 'NAIC' and
                              segment2 = v_naic_code)
      )
      ) and
       pppv.assignment_id = paf.assignment_id and
       pppv.approved = 'Y' and
       pppv.change_date between l_year_start and
                                l_year_end and
       pppv.proposal_reason =
           (
             select     lookup_code
             from       hr_lookups
             where      lookup_type = 'PROPOSAL_REASON' and
                        upper(meaning) = 'PROMOTION'
           )
     union all
     select
       paf.person_id                            count_total,
       ppf.sex                                  sex,
       'FR'                                     employment_category,
       hl1.region_1                             province
     from
       hr_lookups hl,
       per_jobs pj,
       per_assignments_f paf,
       per_people_f ppf,
       per_person_types ppt,
       hr_locations hl1,
       per_ca_ee_report_lines pert,
       hr_lookups hl2,
       hr_soft_coding_keyflex hsck,
       per_pay_proposals_v2 pppv
     where
       hl.lookup_type='EEOG' and
       upper(ltrim(rtrim(hl.lookup_code)))
                     =upper(ltrim(rtrim(pj.job_information1))) and
       upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
       pj.job_id=paf.job_id and
       paf.primary_flag = 'Y' and
       --l_year_end between
       --  ppf.effective_start_date and
       --  ppf.effective_end_date   and
       ppf.start_date between
         paf.effective_start_date and
         paf.effective_end_date   and
       (paf.employment_category is null OR
       substr(paf.employment_category,1,2) not in ('FR','PR','PT')) and
       paf.person_id=ppf.person_id and
       ppf.effective_start_date < l_year_end and
       ppf.effective_end_date  > l_year_start and
       --l_year_end between
       --  ppf.effective_start_date and
       --  ppf.effective_end_date   and
       ppf.person_type_id=ppt.person_type_id and
       upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
       ppf.business_group_id=p_business_group_id and
       paf.location_id=hl1.location_id and
       hl1.region_1=hl2.lookup_code and
       hl2.lookup_type='CA_PROVINCE' and
       pert.request_id=p_request_id and
       hl2.meaning=pert.segment2 and
       --pert.segment4 = 'Y' and
       pert.context='FORM14' and
       pert.segment1='PROVINCE' and
       (
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is not null and
         hsck.segment6 = v_naic_code
       )
       OR
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is null and
         hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
           where request_id = p_request_id and
                 context = 'FORM13' and
                 segment1 = 'NAIC' and
                 segment2 = v_naic_code)
      )
      ) and
      pppv.assignment_id = paf.assignment_id and
      pppv.approved = 'Y' and
      pppv.change_date between l_year_start and
                               l_year_end and
      pppv.proposal_reason =
      (
        select     lookup_code
        from       hr_lookups
        where      lookup_type = 'PROPOSAL_REASON' and
                   upper(meaning) = 'PROMOTION'
      )
    )
    group by province,employment_category,sex
    order by province,employment_category,sex;

  cursor cur_promotions(desig number) is
  select
    count(person_id)           	count,
    employment_category         employment_category,
    sex                         sex,
    province                    province
  from
  (
    select
      paf.person_id                             person_id,
      substr(paf.employment_category,1,2)       employment_category,
      ppf.sex                                   sex,
      hl1.region_1                              province
    from
      hr_lookups hl,
      per_jobs pj,
      per_assignments_f paf,
      per_people_f ppf,
      per_person_types ppt,
      hr_locations hl1,
      per_ca_ee_report_lines pert,
      hr_lookups hl2,
      hr_soft_coding_keyflex hsck,
      per_pay_proposals_v2 pppv
    where
      upper(ltrim(rtrim(hl.lookup_type)))='EEOG' and
      upper(ltrim(rtrim(hl.lookup_code)))
                      = upper(ltrim(ltrim(pj.job_information1))) and
      upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
      pj.job_id=paf.job_id and
      paf.primary_flag = 'Y' and
      --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      --   ppf.effective_start_date and
      --   ppf.effective_end_date   and
      ppf.start_date between
        paf.effective_start_date and
        paf.effective_end_date and
      paf.employment_category is not null and
      substr(paf.employment_category,1,2) in ('FR','PR','PT')and
      paf.person_id=ppf.person_id and
      --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
      --  ppf.effective_start_date and
      --  ppf.effective_end_date   and
      ppf.effective_start_date < l_year_end and
      ppf.effective_end_date  > l_year_start and
      ppf.person_type_id=ppt.person_type_id and
            upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
      ppf.business_group_id=p_business_group_id and
      paf.location_id=hl1.location_id and
      hl1.region_1=hl2.lookup_code and
      hl2.lookup_type='CA_PROVINCE' and
      pert.request_id=p_request_id and
      hl2.meaning=pert.segment2 and
      --pert.segment4 = 'Y' and
      pert.context='FORM14' and
      pert.segment1='PROVINCE' and
      decode(desig,1,per_information5,
        2,per_information6,
        3,per_information7)='Y' and
       (
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is not null and
         hsck.segment6 = v_naic_code
       )
       OR
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is null and
                  hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
           where request_id = p_request_id and
                 context = 'FORM13' and
                 segment1 = 'NAIC' and
                 segment2 = v_naic_code)
      )
      ) and
      pppv.assignment_id = paf.assignment_id and
      pppv.change_date between l_year_start and
                               l_year_end and
      pppv.approved = 'Y' and
      pppv.proposal_reason =
        (
          select      lookup_code
          from        hr_lookups
          where       lookup_type = 'PROPOSAL_REASON' and
                      upper(meaning) = 'PROMOTION'
        )
    union all
    select
      paf.person_id                             person_id,
      'FR'                                      employment_category,
      ppf.sex                                   sex,
      hl1.region_1                              province
    from
      hr_lookups hl,
      per_jobs pj,
      per_assignments_f paf,
      per_people_f ppf,
      per_person_types ppt,
      hr_locations hl1,
      per_ca_ee_report_lines pert,
      hr_lookups hl2,
      hr_soft_coding_keyflex hsck,
      per_pay_proposals_v2 pppv
    where
      upper(ltrim(rtrim(hl.lookup_type)))='EEOG' and
      upper(ltrim(rtrim(hl.lookup_code)))
           = upper(ltrim(ltrim(pj.job_information1))) and
      upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
      pj.job_id=paf.job_id and
      paf.primary_flag = 'Y' and
      --l_year_end between
      --  paf.effective_start_date and
      --  paf.effective_end_date   and
      ppf.effective_start_date between
        paf.effective_start_date and
        paf.effective_end_date   and
      (paf.employment_category is null OR
       substr(paf.employment_category,1,2) not in ('FR','PR','PT'))and
      paf.person_id=ppf.person_id and
      --l_year_end between
      --  ppf.effective_start_date and
      --  ppf.effective_end_date   and
      ppf.effective_start_date < l_year_end and
      ppf.effective_end_date  >  l_year_start and
      ppf.person_type_id=ppt.person_type_id and
      upper(ltrim(rtrim(ppt.system_person_type)))='EMP' and
      ppf.business_group_id=p_business_group_id and
      paf.location_id=hl1.location_id and
            hl1.region_1=hl2.lookup_code and
      hl2.lookup_type='CA_PROVINCE' and
      pert.request_id=p_request_id and
      hl2.meaning=pert.segment2 and
      --pert.segment4 = 'Y' and
      pert.context='FORM14' and
      pert.segment1='PROVINCE' and
      decode(desig,1,per_information5,
        2,per_information6,
        3,per_information7)='Y' and
       (
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is not null and
         hsck.segment6 = v_naic_code
       )
       OR
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is null and
         hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
           where request_id = p_request_id and
                            context = 'FORM13' and
                 segment1 = 'NAIC' and
                 segment2 = v_naic_code)
      )
      ) and
      pppv.assignment_id = paf.assignment_id and
      pppv.approved = 'Y'and
      pppv.change_date between l_year_start and
                               l_year_end and
      pppv.proposal_reason =
      (
        select      lookup_code
        from        hr_lookups
        where       lookup_type = 'PROPOSAL_REASON' and
                    upper(meaning) = 'PROMOTION'
      )
   )
   group by province,employment_category,sex
   order by province,employment_category,sex;

  cursor cur_count_national_promotions is
  select
    segment3,
    sum(to_number(segment4))		segment4,
    sum(to_number(segment5))		segment5,
    sum(to_number(segment6))		segment6,
    sum(to_number(segment7))		segment7,
    sum(to_number(segment8))		segment8,
    sum(to_number(segment9))		segment9,
    sum(to_number(segment10))		segment10,
    sum(to_number(segment11))		segment11,
    sum(to_number(segment12))		segment12,
    sum(to_number(segment13))		segment13,
    sum(to_number(segment14))		segment14,
    sum(to_number(segment15))		segment15
  from
    per_ca_ee_report_lines
  where
    request_id = p_request_id and
    context  = 'FORM5P' and
    segment1 = 'PROVINCE' and
    segment21 = v_naic_code
  group by segment3;

  cursor cur_notfound_promotions(emp_cat number) is
  select
    segment2,
    decode(emp_cat,1,'FR','2','PR',3,'PT')	emp_category
  from
    per_ca_ee_report_lines
  where
    request_id = p_request_id and
    segment3 <> '0' and
    context = 'FORM14'
  minus
  select
    segment2,
    segment3
  from
    per_ca_ee_report_lines
  where
    request_id = p_request_id and
    context = 'FORM5P' and
    segment1 = 'PROVINCE' ;

begin

   for naic in cur_naic loop

     v_naic_code := naic.naic_code;

     hr_utility.trace('Form5: v_naic = ' || v_naic_code );

        for j in cur_promoted_total
        loop
        v_count         	:= j.count_total;
        v_meaning       	:= j.meaning;
        v_employment_category 	:= j.employment_category;
        v_sex 			:= j.sex;
        v_province              := j.province;

        open cur_meaning;
        fetch cur_meaning into v_province_name;
        close cur_meaning;

        if ((ltrim(rtrim(v_province_name))
                            <>ltrim(rtrim(prev_province_name))) or
        (ltrim(rtrim(prev_meaning)) <> ltrim(rtrim(v_meaning))) or
        (ltrim(rtrim(prev_naic_code)) <> ltrim(rtrim(v_naic_code))) or
        (ltrim(rtrim(prev_employment_category)) <>
                       ltrim(rtrim(v_employment_category)))) then

           per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

           insert into per_ca_ee_report_lines
           (request_id,
            line_number,
            context,
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment16,
            segment21) values
            ( p_request_id,
             per_ca_ee_extract_pkg.k,
             'FORM5',
             'PROVINCE',
             v_province_name,
             v_meaning,
             v_employment_category,
             nvl(v_count,0),
             decode(v_sex,'F',v_count,0),
             decode(v_sex,'M',v_count,0),
             '0',
             '0',
             '0',
             '0',
             '0',
             '0',
             '0',
             '0',
             '0',
             v_naic_code);
        else

           if prev_province_name = v_province_name and
           prev_meaning = v_meaning and
           prev_naic_code = v_naic_code and
           prev_employment_category = v_employment_category and
           prev_sex <> v_sex then

           if v_sex = 'M' then

             update per_ca_ee_report_lines set
                segment7=nvl(v_count,0),
                segment5=segment5 + nvl(v_count,0)
             where request_id=p_request_id and
                   line_number = per_ca_ee_extract_pkg.k and
                   context='FORM5' and
                   segment1='PROVINCE' and
                   segment2=v_province_name and
                   segment3=v_meaning and
                   segment4=v_employment_category and
                   segment21=v_naic_code;

           elsif v_sex = 'F' then

             update per_ca_ee_report_lines set
                segment6=nvl(v_count,0),
                segment5=segment5 + nvl(v_count,0)
             where request_id=p_request_id and
                   line_number = per_ca_ee_extract_pkg.k and
                   context='FORM5' and
                   segment1='PROVINCE' and
                   segment2=v_province_name and
                   segment3=v_meaning and
                   segment4=v_employment_category and
                   segment21=v_naic_code;

           end if;

           end if;
        end if;

        prev_meaning 			:= v_meaning;
        prev_employment_category 	:= v_employment_category;
        prev_sex                	:= v_sex;
        prev_province_name 		:= v_province_name;
        prev_naic_code 			:= v_naic_code;

        end loop; -- End loop cur_promoted_total

        for i in 1..3 loop

          for j in cur_promoted(i)
          loop

           v_sex 			:= j.sex;
           v_employment_category 	:= j.employment_category;
           v_meaning 			:= j.meaning;
           v_count 			:= j.count;
           v_province              	:= j.province;

           open cur_meaning;
           fetch cur_meaning into v_province_name;
           close cur_meaning;


           if i = 1 then

             if v_sex = 'M' then

                update per_ca_ee_report_lines set
                   segment8 = nvl(segment8,0) + nvl(v_count,0),
                   segment10 = nvl(v_count,0)
                where
                   request_id = p_request_id and
                   context = 'FORM5' and
                   segment1 = 'PROVINCE' and
                   segment2 = v_province_name and
                   segment3 = v_meaning and
                   segment4 = v_employment_category and
	           segment21 = v_naic_code;

            elsif v_sex = 'F' then

                update per_ca_ee_report_lines set
                  segment8 = nvl(segment8,0) + nvl(v_count,0),
                  segment9 = nvl(v_count,0)
                where
                  request_id = p_request_id and
                  context = 'FORM5' and
                  segment1 = 'PROVINCE' and
                  segment2 = v_province_name and
                  segment3 = v_meaning and
                  segment4 = v_employment_category and
	          segment21 = v_naic_code;

            end if;

          elsif i = 2 then

            if v_sex = 'M' then

              update per_ca_ee_report_lines set
                segment11 = nvl(segment11,0) + nvl(v_count,0),
                segment13 = nvl(v_count,0)
              where
                request_id = p_request_id and
                context = 'FORM5' and
                segment1 = 'PROVINCE' and
                segment2 = v_province_name and
                segment3 = v_meaning and
                segment4 = v_employment_category and
                segment21 = v_naic_code;

            elsif v_sex = 'F' then

              update per_ca_ee_report_lines set
                segment11 = nvl(segment11,0) + nvl(v_count,0),
                segment12 = nvl(v_count,0)
              where
                request_id = p_request_id and
                context    = 'FORM5' and
                segment1   = 'PROVINCE' and
                segment2   = v_province_name and
                segment3   = v_meaning and
                segment4   = v_employment_category and
                segment21  = v_naic_code;

            end if;

          elsif i = 3 then

            if v_sex = 'M' then

              update per_ca_ee_report_lines set
                segment14 = nvl(segment14,0) + nvl(v_count,0),
                segment16 = nvl(v_count,0)
              where
                request_id = p_request_id and
                context = 'FORM5' and
                segment1 = 'PROVINCE' and
                segment2 = v_province_name and
                segment3 = v_meaning and
                segment4 = v_employment_category and
                segment21 = v_naic_code;

           elsif v_sex = 'F' then

             update per_ca_ee_report_lines set
               segment14 = nvl(segment14,0) + nvl(v_count,0),
               segment15 = nvl(v_count,0)
             where
               request_id = p_request_id and
               context = 'FORM5' and
               segment1 = 'PROVINCE' and
               segment2 = v_province_name and
               segment3 = v_meaning and
               segment4 = v_employment_category and
               segment21 = v_naic_code;

           end if;
        end if;
      end loop; -- End loop cur_hired
      end loop; -- End loop Designated Group

   for i in cur_eeog loop

    v_meaning := i.meaning;

    hr_utility.trace('Form5: cur_eeog: v_eeog' || v_meaning);

     for emp_cat in 1..3 loop

     for x in cur_notfound(emp_cat) loop

     per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

           insert into per_ca_ee_report_lines
           (request_id,
            line_number,
            context,
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment16,
            segment21) values
            ( p_request_id,
             per_ca_ee_extract_pkg.k,
             'FORM5',
             'PROVINCE',
             x.segment2,
             v_meaning,
             x.emp_category,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             v_naic_code);

    end loop; -- End loop cur_notfound

    end loop; -- End loop emp_cat

  end loop; -- End loop cur_eeog

  prev_province_name := 'test';
  prev_employment_category := 'te';
  prev_naic_code := 'te';

  for i in cur_total_promotions loop

    hr_utility.trace('Form5P: cur_total_promotions');

    v_count         	        := i.count_total;
    v_employment_category 	:= i.employment_category;
    v_sex 			:= i.sex;
    v_province                  := i.province;

    open cur_meaning;
    fetch cur_meaning into v_province_name;
    close cur_meaning;

    hr_utility.trace('Form5P: prev_province_name: ' || prev_province_name);
    hr_utility.trace('Form5P: v_province_name: ' || v_province_name);
    hr_utility.trace('Form5P: prev_naic_code: ' || prev_naic_code);
    hr_utility.trace('Form5P: v_naic_code: ' || v_naic_code);
    hr_utility.trace('Form5P: prev_emp_category: ' || prev_employment_category);
    hr_utility.trace('Form5P: v_emp_category: ' || v_employment_category);

    if ((ltrim(rtrim(v_province_name))
                            <>ltrim(rtrim(prev_province_name))) or
       (ltrim(rtrim(prev_naic_code)) <> ltrim(rtrim(v_naic_code))) or
       (ltrim(rtrim(prev_employment_category)) <>
                     ltrim(rtrim(v_employment_category)))) then

      hr_utility.trace('Form5P: cur_total_promotions : Inside If');
      per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

      insert into per_ca_ee_report_lines
      (request_id,
       line_number,
       context,
       segment1,
       segment2,
       segment3,
       segment4,
       segment5,
       segment6,
       segment7,
       segment8,
       segment9,
       segment10,
       segment11,
       segment12,
       segment13,
       segment14,
       segment15,
       segment21) values
       (p_request_id,
        per_ca_ee_extract_pkg.k,
        'FORM5P',
        'PROVINCE',
        v_province_name,
        v_employment_category,
        nvl(v_count,0),
        decode(v_sex,'M',v_count,0),
        decode(v_sex,'F',v_count,0),
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        v_naic_code);

      else

        if prev_province_name = v_province_name and
           prev_naic_code = v_naic_code and
           prev_employment_category = v_employment_category and
           prev_sex <> v_sex then

           if v_sex = 'M' then

             update per_ca_ee_report_lines set
               segment5=nvl(v_count,0),
               segment4=segment4 + nvl(v_count,0)
             where request_id=p_request_id and
               line_number = per_ca_ee_extract_pkg.k and
               context='FORM5P' and
               segment1='PROVINCE' and
               segment2=v_province_name and
               segment3=v_employment_category and
               segment21=v_naic_code;

           elsif v_sex = 'F' then

             update per_ca_ee_report_lines set
               segment6=nvl(v_count,0),
               segment4=segment4 + nvl(v_count,0)
             where request_id=p_request_id and
               line_number = per_ca_ee_extract_pkg.k and
               context='FORM5P' and
               segment1='PROVINCE' and
               segment2=v_province_name and
               segment3=v_employment_category and
               segment21=v_naic_code;

           end if;

           end if;

        end if;

        prev_meaning 			:= v_meaning;
        prev_employment_category 	:= v_employment_category;
        prev_sex                	:= v_sex;

  end loop; -- End loop cur_total_promotions

  for i in 1..3 loop

  for j in cur_promotions(i) loop

    v_sex 			:= j.sex;
    v_employment_category 	:= j.employment_category;
    --v_meaning 		:= j.meaning;
    v_count 			:= j.count;
    v_province              	:= j.province;

    open cur_meaning;
    fetch cur_meaning into v_province_name;
    close cur_meaning;


    if i = 1 then

      if v_sex = 'M' then

        update per_ca_ee_report_lines set
          segment7 = nvl(segment7,0) + nvl(v_count,0),
          segment8 = nvl(v_count,0)
        where
          request_id = p_request_id and
          context = 'FORM5P' and
          segment1 = 'PROVINCE' and
          segment2 = v_province_name and
          segment3 = v_employment_category and
	  segment21 = v_naic_code;

      elsif v_sex = 'F' then

        update per_ca_ee_report_lines set
          segment7 = nvl(segment7,0) + nvl(v_count,0),
          segment9 = nvl(v_count,0)
        where
          request_id = p_request_id and
          context = 'FORM5P' and
          segment1 = 'PROVINCE' and
          segment2 = v_province_name and
          segment3 = v_employment_category and
	  segment21 = v_naic_code;

      end if;

    elsif i = 2 then

      if v_sex = 'M' then

        update per_ca_ee_report_lines set
          segment10 = nvl(segment10,0) + nvl(v_count,0),
          segment11 = nvl(v_count,0)
        where
          request_id = p_request_id and
          context = 'FORM5P' and
          segment1 = 'PROVINCE' and
          segment2 = v_province_name and
          segment3 = v_employment_category and
          segment21 = v_naic_code;

      elsif v_sex = 'F' then

        update per_ca_ee_report_lines set
          segment10 = nvl(segment10,0) + nvl(v_count,0),
          segment12 = nvl(v_count,0)
        where
          request_id = p_request_id and
          context    = 'FORM5P' and
          segment1   = 'PROVINCE' and
          segment2   = v_province_name and
          segment3   = v_employment_category and
          segment21  = v_naic_code;

      end if;

    elsif i = 3 then

      if v_sex = 'M' then

        update per_ca_ee_report_lines set
          segment13 = nvl(segment13,0) + nvl(v_count,0),
          segment14 = nvl(v_count,0)
        where
          request_id = p_request_id and
          context = 'FORM5P' and
          segment1 = 'PROVINCE' and
          segment2 = v_province_name and
          segment3 = v_employment_category and
          segment21 = v_naic_code;

       elsif v_sex = 'F' then

         update per_ca_ee_report_lines set
           segment13 = nvl(segment13,0) + nvl(v_count,0),
           segment15 = nvl(v_count,0)
         where
           request_id = p_request_id and
           context = 'FORM5P' and
           segment1 = 'PROVINCE' and
           segment2 = v_province_name and
           segment3 = v_employment_category and
           segment21 = v_naic_code;

        end if;

      end if;

  end loop; -- End loop cur_promotions.

  end loop; -- End loop for designated group members.

  for i in 1..3 loop
    for j in cur_notfound_promotions(i) loop

      insert into per_ca_ee_report_lines
      (request_id,
       line_number,
       context,
       segment1,
       segment2,
       segment3,
       segment4,
       segment5,
       segment6,
       segment7,
       segment8,
       segment9,
       segment10,
       segment11,
       segment12,
       segment13,
       segment14,
       segment15,
       segment21) values
       (p_request_id,
        per_ca_ee_extract_pkg.k,
        'FORM5P',
        'PROVINCE',
        j.segment2,
        j.emp_category,
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        v_naic_code);

    end loop;
  end loop; -- End loop for designated group members.

  for i in cur_count_national_promotions loop

    insert into per_ca_ee_report_lines
      (request_id,
       line_number,
       context,
       segment1,
       segment2,
       segment3,
       segment4,
       segment5,
       segment6,
       segment7,
       segment8,
       segment9,
       segment10,
       segment11,
       segment12,
       segment13,
       segment14,
       segment21) values
      (p_request_id,
       per_ca_ee_extract_pkg.k,
       'FORM5P',
       'NATIONAL',
       i.segment3,
       i.segment4,
       i.segment5,
       i.segment6,
       i.segment7,
       i.segment8,
       i.segment9,
       i.segment10,
       i.segment11,
       i.segment12,
       i.segment13,
       i.segment14,
       i.segment15,
  --     i.segment16,
       v_naic_code);

  end loop;

  for count_national in cur_count_national loop

   hr_utility.trace('Form5: cur_count_national. ');

    insert into per_ca_ee_report_lines
           (request_id,
            line_number,
            context,
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment21) values
            ( p_request_id,
             per_ca_ee_extract_pkg.k,
             'FORM5',
             'NATIONAL',
             count_national.segment3,
             count_national.segment4,
             count_national.segment5,
             count_national.segment6,
             count_national.segment7,
             count_national.segment8,
             count_national.segment9,
             count_national.segment10,
             count_national.segment11,
             count_national.segment12,
             count_national.segment13,
             count_national.segment14,
             count_national.segment15,
             count_national.segment16,
             v_naic_code);

    end loop; -- End loop cur_count_total

    prev_naic_code := v_naic_code;

  end loop; -- End loop cur_naic


  return 1;
end;
end form5;
*/

function form5(p_business_group_id in number,
               p_request_id     in number,
               p_year           in varchar2,
               p_date_tmp_emp   in date) return number is

  l_year_start date;
  l_year_end date;

begin

  l_year_start :=  trunc(to_date(p_year,'YYYY'),'Y');
  l_year_end   :=  add_months(trunc(to_date(p_year,'YYYY'),'Y'), 12) -1;

declare

  cursor cur_naic is
  select  pert.segment4  naic_code
  from  per_ca_ee_report_lines  pert
  where  pert.request_id = p_request_id
  and    pert.context    = 'FORM12';

  v_naic_code			hr_lookups.lookup_code%TYPE;

  cursor cur_jobs is
  select job_id,
         meaning
  from per_jobs,
       hr_lookups
  where lookup_type = 'EEOG'
  and   upper(ltrim(rtrim(lookup_code)))
           =upper(ltrim(rtrim(job_information1)))
  and   upper(ltrim(rtrim(job_information_category))) = 'CA'
  and   business_group_id = p_business_group_id;


  cursor cur_person_types is
  select person_type_id
  from  per_person_types
  where  upper(ltrim(rtrim(system_person_type)))='EMP'
  and    business_group_id = p_business_group_id;

  cursor cur_promoted_total(desig number) is
  select
    sum(employee_total)         employee_total,
    meaning 			meaning,
    sex 			sex,
    employment_category 	employment_category,
    province			province
  from
  (
     select
       employee_promotions(paf.assignment_id,
                           paf.person_id,
                           p_business_group_id,
                           l_year_start,
                           l_year_end,
                           'Y')                 employee_total,
       job_exists(paf.job_id)                   meaning,
       ppf.sex 					sex,
       substr(paf.employment_category,1,2) 	employment_category,
       hl1.region_1 				province
     from
       per_assignments_f paf,
       per_people_f ppf,
       hr_locations hl1,
       per_ca_ee_report_lines pert,
       hr_lookups hl2,
       hr_soft_coding_keyflex hsck
     where  job_exists(paf.job_id) is not null
     and paf.primary_flag = 'Y'
     and paf.assignment_id =
            (select max(pafm.assignment_id)                -- This select ensures that
             from  per_assignments_f pafm                  -- for rehires only the last
             where pafm.person_id         = ppf.person_id  -- assignment is used
             and   pafm.primary_flag      = 'Y'
             and   pafm.business_group_id = p_business_group_id)
--     and    ppf.start_date between
--                        paf.effective_start_date and
--                        paf.effective_end_date
     and paf.effective_start_date <= l_year_end
     and paf.effective_end_date   >= l_year_start
     and paf.effective_start_date =
            (select max(paf_max.effective_start_date)  -- The last assignment
             from  per_assignments_f paf_max           -- in the year
             where paf_max.assignment_id     = paf.assignment_id
             and   paf_max.primary_flag      = 'Y'
             and   paf_max.effective_start_date <= l_year_end
             and   paf_max.effective_end_date   >= l_year_start
             and   paf_max.business_group_id = p_business_group_id)
     and paf.employment_category is not null
     and substr(paf.employment_category,1,2) in ('FR','PR','PT')
     and paf.person_id = ppf.person_id
     and ppf.effective_start_date <= l_year_end
     and ppf.effective_end_date   >= l_year_start
     and ppf.effective_start_date =
            (select max(ppf_max.effective_start_date)  -- The last person
             from  per_people_f ppf_max                -- record in the year
             where ppf_max.person_id         = ppf.person_id
             and   ppf_max.effective_start_date <= l_year_end
             and   ppf_max.effective_end_date   >= l_year_start
             and   ppf_max.business_group_id = p_business_group_id
             and   person_type_exists(ppf_max.person_type_id) is not null)
     and person_type_exists(ppf.person_type_id) is not null
     and ppf.business_group_id = p_business_group_id
     and paf.location_id = hl1.location_id
     and hl1.region_1    = hl2.lookup_code
     and hl2.lookup_type = 'CA_PROVINCE'
     and pert.request_id = p_request_id
     and hl2.meaning     = pert.segment2
     and pert.context    = 'FORM14'
     and pert.segment1   = 'PROVINCE'
     and decode (desig, 0, 'Y',
                   1, per_information5,
                   2, per_information6,
                   3, per_information7) = 'Y'
     and (
           (
             hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
             hsck.segment6 is not null and
             hsck.segment6 = v_naic_code
           )
           OR
          (
             hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
             hsck.segment6 is null and
             hsck.segment1 in (select segment3
                               from per_ca_ee_report_lines
                               where request_id = p_request_id
                               and   context = 'FORM13'
                               and   segment1 = 'NAIC'
                               and   segment2 = v_naic_code)
          )
         )
    union all
     select
       employee_promotions(paf.assignment_id,
                           paf.person_id,
                           p_business_group_id,
                           l_year_start,
                           l_year_end,
                           'Y')                 employee_total,
       job_exists(paf.job_id) 	                meaning,
       ppf.sex 					sex,
       'FR' 	                                employment_category,
       hl1.region_1 				province
     from
       per_assignments_f paf,
       per_people_f ppf,
       hr_locations hl1,
       per_ca_ee_report_lines pert,
       hr_lookups hl2,
      hr_soft_coding_keyflex hsck
     where
         job_exists(paf.job_id) is not null
     and paf.primary_flag = 'Y'
     and paf.assignment_id =
            (select max(pafm.assignment_id)                -- This select ensures that
             from  per_assignments_f pafm                  -- for rehires only the last
             where pafm.person_id         = ppf.person_id  -- assignment is used
             and   pafm.primary_flag      = 'Y'
             and   pafm.business_group_id = p_business_group_id)
--     and ppf.start_date between
--            paf.effective_start_date and
--            paf.effective_end_date
     and paf.effective_start_date <= l_year_end
     and paf.effective_end_date   >= l_year_start
     and paf.effective_start_date =
            (select max(paf_max.effective_start_date)
             from  per_assignments_f paf_max
             where paf_max.assignment_id     = paf.assignment_id
             and   paf_max.primary_flag      = 'Y'
             and   paf_max.effective_start_date <= l_year_end
             and   paf_max.effective_end_date   >= l_year_start
             and   paf_max.business_group_id = p_business_group_id)
     and (paf.employment_category is null OR
          substr(paf.employment_category,1,2) not in ('FR','PR','PT'))
     and paf.person_id = ppf.person_id
     and ppf.effective_start_date <= l_year_end
     and ppf.effective_end_date   >= l_year_start
     and ppf.effective_start_date =
            (select max(ppf_max.effective_start_date)  -- The last person
             from  per_people_f ppf_max                -- record in the year
             where ppf_max.person_id         = ppf.person_id
             and   ppf_max.effective_start_date <= l_year_end
             and   ppf_max.effective_end_date   >= l_year_start
             and   ppf_max.business_group_id = p_business_group_id
             and   person_type_exists(ppf_max.person_type_id) is not null)
     and person_type_exists(ppf.person_type_id) is not null
     and ppf.business_group_id = p_business_group_id
     and paf.location_id = hl1.location_id
     and hl1.region_1    = hl2.lookup_code
     and hl2.lookup_type = 'CA_PROVINCE'
     and pert.request_id = p_request_id
     and hl2.meaning     = pert.segment2
     and pert.context    = 'FORM14'
     and pert.segment1   = 'PROVINCE'
     and decode (desig, 0, 'Y',
                      1, per_information5,
                      2, per_information6,
                      3, per_information7) = 'Y'
     and
       (
        (
          hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
          hsck.segment6 is not null and
          hsck.segment6 = v_naic_code
        )
        OR
        (
          hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
          hsck.segment6 is null and
          hsck.segment1 in
            (select segment3
             from per_ca_ee_report_lines
             where request_id = p_request_id
             and   context    = 'FORM13'
             and   segment1   = 'NAIC'
             and   segment2   = v_naic_code)
        )
       )
    )
    group by province,meaning,employment_category,sex
    order by province,meaning,employment_category,sex;

    v_count                 number(10);
    v_meaning               hr_lookups.meaning%TYPE;
    v_employment_category   per_assignments_f.employment_category%TYPE;
    v_sex                   per_people_f.sex%TYPE;
    v_province              hr_locations.region_1%TYPE;
    prev_meaning            hr_lookups.meaning%TYPE := 'test';
    prev_employment_category per_assignments_f.employment_category%TYPE := 'test';
    prev_sex                per_people_f.sex%TYPE := 'test';
    prev_naic_code          hr_lookups.lookup_code%TYPE;

  cursor cur_meaning is
  select meaning
  from  hr_lookups
  where upper(ltrim(rtrim(lookup_type)))='CA_PROVINCE'
  and   upper(ltrim(rtrim(lookup_code)))=upper(ltrim(rtrim(v_province)));

  v_province_name         hr_lookups.meaning%TYPE;
  prev_province_name      hr_lookups.meaning%TYPE;

  cursor cur_eeog is
  select meaning
  from hr_lookups
  where lookup_type='EEOG';

  cursor cur_notfound(p_emp_cat number) is
  select
    segment2,
    v_meaning,
    decode(p_emp_cat,1,'FR',2,'PR',3,'PT') emp_category
  from
    per_ca_ee_report_lines where
    request_id=p_request_id and
    context='FORM14' and
    segment1='PROVINCE' and
    segment3 <> '0'
  minus
  select
    segment2,
    segment3,
    segment4
  from
    per_ca_ee_report_lines
  where
    request_id=p_request_id and
    context='FORM5' and
    segment1='PROVINCE'and
    segment21 = v_naic_code;

  cursor cur_count_national is
  select
     segment3,
     segment4,
     sum(to_number(segment5))           segment5,
     sum(to_number(segment6))           segment6,
     sum(to_number(segment7))           segment7,
     sum(to_number(segment8))           segment8,
     sum(to_number(segment9))           segment9,
     sum(to_number(segment10))          segment10,
     sum(to_number(segment11))          segment11,
     sum(to_number(segment12))          segment12,
     sum(to_number(segment13))          segment13,
     sum(to_number(segment14))          segment14,
     sum(to_number(segment15))          segment15,
     sum(to_number(segment16))          segment16
   from
     per_ca_ee_report_lines
   where
     request_id = p_request_id and
     context = 'FORM5' and
     segment1 = 'PROVINCE' and
     segment21 = v_naic_code
   group by segment3,segment4;

  cursor cur_total_promotions(desig number) is
  select
    sum(promotion_total)        promotion_total,
    sex                         sex,
    employment_category         employment_category,
    province                    province
  from
  (
     select
       employee_promotions(paf.assignment_id,
                           paf.person_id,
                           p_business_group_id,
                           l_year_start,
                           l_year_end,
                           'N')                 promotion_total,
       ppf.sex                                  sex,
       substr(paf.employment_category,1,2)      employment_category,
       hl1.region_1                             province
     from
       per_assignments_f paf,
       per_people_f ppf,
       hr_locations hl1,
       per_ca_ee_report_lines pert,
       hr_lookups hl2,
       hr_soft_coding_keyflex hsck
     where
         job_exists(paf.job_id) is not null
     and paf.primary_flag = 'Y'
     and paf.assignment_id =
            (select max(pafm.assignment_id)                -- This select ensures that
             from  per_assignments_f pafm                  -- for rehires only the last
             where pafm.person_id         = ppf.person_id  -- assignment is used
             and   pafm.primary_flag      = 'Y'
             and   pafm.business_group_id = p_business_group_id)
--       ppf.start_date between
--         paf.effective_start_date and
--         paf.effective_end_date and
     and paf.effective_start_date <= l_year_end
     and paf.effective_end_date   >= l_year_start
     and paf.effective_start_date =
            (select max(paf_max.effective_start_date)
             from  per_assignments_f paf_max
             where paf_max.assignment_id     = paf.assignment_id
             and   paf_max.primary_flag      = 'Y'
             and   paf_max.effective_start_date <= l_year_end
             and   paf_max.effective_end_date   >= l_year_start
             and   paf_max.business_group_id = p_business_group_id)
    and   paf.employment_category is not null
    and   substr(paf.employment_category,1,2) in ('FR','PR','PT')
    and   paf.person_id=ppf.person_id
    and   ppf.effective_start_date <= l_year_end
    and   ppf.effective_end_date   >= l_year_start
    and   ppf.effective_start_date =
            (select max(ppf_max.effective_start_date)  -- The last person
             from  per_people_f ppf_max                -- record in the year
             where ppf_max.person_id         = ppf.person_id
             and   ppf_max.effective_start_date <= l_year_end
             and   ppf_max.effective_end_date   >= l_year_start
             and   ppf_max.business_group_id = p_business_group_id
             and   person_type_exists(ppf_max.person_type_id) is not null)
    and   person_type_exists(ppf.person_type_id) is not null
    and   ppf.business_group_id=p_business_group_id
    and   paf.location_id=hl1.location_id
    and   hl1.region_1=hl2.lookup_code
    and   hl2.lookup_type='CA_PROVINCE'
    and   pert.request_id=p_request_id
    and   hl2.meaning=pert.segment2
    and   pert.context='FORM14'
    and   pert.segment1='PROVINCE'
    and   decode (desig, 0, 'Y',
                      1, per_information5,
                      2, per_information6,
                      3, per_information7) = 'Y'
    and (
         (
           hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
           hsck.segment6 is not null and
           hsck.segment6 = v_naic_code
         )
         OR
         (
           hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
           hsck.segment6 is null and
           hsck.segment1 in (select segment3
                          from per_ca_ee_report_lines
                          where request_id = p_request_id and
                                context = 'FORM13' and
                                segment1 = 'NAIC' and
                                segment2 = v_naic_code)
         )
        )
     union all
     select
       employee_promotions(paf.assignment_id,
                           paf.person_id,
                           p_business_group_id,
                           l_year_start,
                           l_year_end,
                           'N')                 promotion_total,
       ppf.sex                                  sex,
       'FR'                                     employment_category,
       hl1.region_1                             province
     from
       per_assignments_f paf,
       per_people_f ppf,
       hr_locations hl1,
       per_ca_ee_report_lines pert,
       hr_lookups hl2,
       hr_soft_coding_keyflex hsck
     where
         job_exists(paf.job_id) is not null
     and paf.primary_flag = 'Y'
     and paf.assignment_id =
            (select max(pafm.assignment_id)                -- This select ensures that
             from  per_assignments_f pafm                  -- for rehires only the last
             where pafm.person_id         = ppf.person_id  -- assignment is used
             and   pafm.primary_flag      = 'Y'
             and   pafm.business_group_id = p_business_group_id)
--       ppf.start_date between
--         paf.effective_start_date and
--         paf.effective_end_date   and
     and paf.effective_start_date <= l_year_end
     and paf.effective_end_date   >= l_year_start
     and paf.effective_start_date =
            (select max(paf_max.effective_start_date)
             from  per_assignments_f paf_max
             where paf_max.assignment_id     = paf.assignment_id
             and   paf_max.primary_flag      = 'Y'
             and   paf_max.effective_start_date <= l_year_end
             and   paf_max.effective_end_date   >= l_year_start
             and   paf_max.business_group_id = p_business_group_id)
     and (paf.employment_category is null OR
         substr(paf.employment_category,1,2) not in ('FR','PR','PT'))
     and paf.person_id=ppf.person_id
     and ppf.effective_start_date <= l_year_end
     and ppf.effective_end_date   >= l_year_start
     and ppf.effective_start_date =
            (select max(ppf_max.effective_start_date)  -- The last person
             from  per_people_f ppf_max                -- record in the year
             where ppf_max.person_id         = ppf.person_id
             and   ppf_max.effective_start_date <= l_year_end
             and   ppf_max.effective_end_date   >= l_year_start
             and   ppf_max.business_group_id = p_business_group_id
             and   person_type_exists(ppf_max.person_type_id) is not null)
     and person_type_exists(ppf.person_type_id) is not null
     and ppf.business_group_id=p_business_group_id
     and paf.location_id=hl1.location_id
     and hl1.region_1=hl2.lookup_code
     and hl2.lookup_type='CA_PROVINCE'
     and pert.request_id=p_request_id
     and hl2.meaning=pert.segment2
     and pert.context='FORM14'
     and pert.segment1='PROVINCE'
     and decode (desig, 0, 'Y',
                     1, per_information5,
                     2, per_information6,
                     3, per_information7) = 'Y'
     and
        (
         (
           hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
           hsck.segment6 is not null and
           hsck.segment6 = v_naic_code
         )
         OR
         (
           hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
           hsck.segment6 is null and
           hsck.segment1 in
                      (select segment3
                       from per_ca_ee_report_lines
                       where request_id = p_request_id
                       and   context = 'FORM13'
                       and   segment1 = 'NAIC'
                       and   segment2 = v_naic_code)
         )
        )
    )
    group by province,employment_category,sex
    order by province,employment_category,sex;

  cursor cur_count_national_promotions is
  select
    segment3,
    sum(to_number(segment4))		segment4,
    sum(to_number(segment5))		segment5,
    sum(to_number(segment6))		segment6,
    sum(to_number(segment7))		segment7,
    sum(to_number(segment8))		segment8,
    sum(to_number(segment9))		segment9,
    sum(to_number(segment10))		segment10,
    sum(to_number(segment11))		segment11,
    sum(to_number(segment12))		segment12,
    sum(to_number(segment13))		segment13,
    sum(to_number(segment14))		segment14,
    sum(to_number(segment15))		segment15
  from
    per_ca_ee_report_lines
  where
    request_id = p_request_id and
    context  = 'FORM5P' and
    segment1 = 'PROVINCE' and
    segment21 = v_naic_code
  group by segment3;

  cursor cur_notfound_promotions(emp_cat number) is
  select
    segment2,
    decode(emp_cat,1,'FR','2','PR',3,'PT')	emp_category
  from
    per_ca_ee_report_lines
  where
    request_id = p_request_id and
    segment3 <> '0' and
    context = 'FORM14'
  minus
  select
    segment2,
    segment3
  from
    per_ca_ee_report_lines
  where
    request_id = p_request_id and
    context = 'FORM5P' and
    segment1 = 'PROVINCE' ;

begin

  /* Caching data from per_jobs and per_person_types tables */

   open cur_jobs;
   fetch cur_jobs bulk collect into
   v_job_id_temp,
   v_job_temp;

   close cur_jobs;

   if v_job_id_temp.count > 0 then
       for i in v_job_id_temp.first..v_job_id_temp.last LOOP
            v_job_id(v_job_id_temp(i)) := v_job_id_temp(i);
            v_job(v_job_id_temp(i))    := v_job_temp(i);
       end loop;
   end if;

   open cur_person_types;
   fetch cur_person_types bulk collect into
   v_person_type_temp;

   close cur_person_types;

   if v_person_type_temp.count > 0 then
       for i in v_person_type_temp.first..v_person_type_temp.last LOOP
            v_person_type(v_person_type_temp(i)) := v_person_type_temp(i);
       end loop;
   end if;

   for naic in cur_naic loop

     v_naic_code := naic.naic_code;

     hr_utility.trace('Form5: v_naic = ' || v_naic_code );

     for i in 0..3 loop

        for j in cur_promoted_total(i)
        loop
        v_count         	:= j.employee_total;
        v_meaning       	:= j.meaning;
        v_employment_category 	:= j.employment_category;
        v_sex 			:= j.sex;
        v_province              := j.province;

        open cur_meaning;
        fetch cur_meaning into v_province_name;
        close cur_meaning;

        if v_count <> 0 then    -- Only employees who have been promoted

             if i = 0 then

                  if ((ltrim(rtrim(v_province_name))
                                      <>ltrim(rtrim(prev_province_name))) or
                  (ltrim(rtrim(prev_meaning)) <> ltrim(rtrim(v_meaning))) or
                  (ltrim(rtrim(prev_naic_code)) <> ltrim(rtrim(v_naic_code))) or
                  (ltrim(rtrim(prev_employment_category)) <>
                                 ltrim(rtrim(v_employment_category)))) then

                     per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

                     insert into per_ca_ee_report_lines
                     (request_id,
                      line_number,
                      context,
                      segment1,
                      segment2,
                      segment3,
                      segment4,
                      segment5,
                      segment6,
                      segment7,
                      segment8,
                      segment9,
                      segment10,
                      segment11,
                      segment12,
                      segment13,
                      segment14,
                      segment15,
                      segment16,
                      segment21) values
                      ( p_request_id,
                       per_ca_ee_extract_pkg.k,
                       'FORM5',
                       'PROVINCE',
                       v_province_name,
                       v_meaning,
                       v_employment_category,
                       nvl(v_count,0),
                       decode(v_sex,'F',v_count,0),
                       decode(v_sex,'M',v_count,0),
                       '0',
                       '0',
                       '0',
                       '0',
                       '0',
                       '0',
                       '0',
                       '0',
                       '0',
                       v_naic_code);
                  else

                     if prev_province_name = v_province_name and
                     prev_meaning = v_meaning and
                     prev_naic_code = v_naic_code and
                     prev_employment_category = v_employment_category and
                     prev_sex <> v_sex then

                     if v_sex = 'M' then

                       update per_ca_ee_report_lines set
                          segment7=nvl(v_count,0),
                          segment5=segment5 + nvl(v_count,0)
                       where request_id=p_request_id and
                             line_number = per_ca_ee_extract_pkg.k and
                             context='FORM5' and
                             segment1='PROVINCE' and
                             segment2=v_province_name and
                             segment3=v_meaning and
                             segment4=v_employment_category and
                             segment21=v_naic_code;

                     elsif v_sex = 'F' then

                       update per_ca_ee_report_lines set
                          segment6=nvl(v_count,0),
                          segment5=segment5 + nvl(v_count,0)
                       where request_id=p_request_id and
                             line_number = per_ca_ee_extract_pkg.k and
                             context='FORM5' and
                             segment1='PROVINCE' and
                             segment2=v_province_name and
                             segment3=v_meaning and
                             segment4=v_employment_category and
                             segment21=v_naic_code;

                     end if;

                     end if;
                  end if;

                  prev_meaning 		   := v_meaning;
                  prev_employment_category := v_employment_category;
                  prev_sex                 := v_sex;
                  prev_province_name 	   := v_province_name;
                  prev_naic_code 	   := v_naic_code;

                elsif i = 1 then

                  if v_sex = 'M' then

                     update per_ca_ee_report_lines set
                        segment8 = nvl(segment8,0) + nvl(v_count,0),
                        segment10 = nvl(v_count,0)
                     where
                        request_id = p_request_id and
                        context = 'FORM5' and
                        segment1 = 'PROVINCE' and
                        segment2 = v_province_name and
                        segment3 = v_meaning and
                        segment4 = v_employment_category and
     	                segment21 = v_naic_code;

                 elsif v_sex = 'F' then

                     update per_ca_ee_report_lines set
                       segment8 = nvl(segment8,0) + nvl(v_count,0),
                       segment9 = nvl(v_count,0)
                     where
                       request_id = p_request_id and
                       context = 'FORM5' and
                       segment1 = 'PROVINCE' and
                       segment2 = v_province_name and
                       segment3 = v_meaning and
                       segment4 = v_employment_category and
	               segment21 = v_naic_code;

                 end if;

               elsif i = 2 then

                 if v_sex = 'M' then

                   update per_ca_ee_report_lines set
                     segment11 = nvl(segment11,0) + nvl(v_count,0),
                     segment13 = nvl(v_count,0)
                   where
                     request_id = p_request_id and
                     context = 'FORM5' and
                     segment1 = 'PROVINCE' and
                     segment2 = v_province_name and
                     segment3 = v_meaning and
                     segment4 = v_employment_category and
                     segment21 = v_naic_code;

                 elsif v_sex = 'F' then

                   update per_ca_ee_report_lines set
                     segment11 = nvl(segment11,0) + nvl(v_count,0),
                     segment12 = nvl(v_count,0)
                   where
                     request_id = p_request_id and
                     context    = 'FORM5' and
                     segment1   = 'PROVINCE' and
                     segment2   = v_province_name and
                     segment3   = v_meaning and
                     segment4   = v_employment_category and
                     segment21  = v_naic_code;

                 end if;

               elsif i = 3 then

                 if v_sex = 'M' then

                   update per_ca_ee_report_lines set
                     segment14 = nvl(segment14,0) + nvl(v_count,0),
                     segment16 = nvl(v_count,0)
                   where
                     request_id = p_request_id and
                     context = 'FORM5' and
                     segment1 = 'PROVINCE' and
                     segment2 = v_province_name and
                     segment3 = v_meaning and
                     segment4 = v_employment_category and
                     segment21 = v_naic_code;

                elsif v_sex = 'F' then

                  update per_ca_ee_report_lines set
                    segment14 = nvl(segment14,0) + nvl(v_count,0),
                    segment15 = nvl(v_count,0)
                  where
                    request_id = p_request_id and
                    context = 'FORM5' and
                    segment1 = 'PROVINCE' and
                    segment2 = v_province_name and
                    segment3 = v_meaning and
                    segment4 = v_employment_category and
                    segment21 = v_naic_code;

                end if;
              end if;
           end if;
        end loop; -- End loop cur_promoted_total
      end loop; -- End loop Designated Group

   for i in cur_eeog loop

    v_meaning := i.meaning;

    hr_utility.trace('Form5: cur_eeog: v_eeog' || v_meaning);

     for emp_cat in 1..3 loop

     for x in cur_notfound(emp_cat) loop

     per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

           insert into per_ca_ee_report_lines
           (request_id,
            line_number,
            context,
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment16,
            segment21) values
            ( p_request_id,
             per_ca_ee_extract_pkg.k,
             'FORM5',
             'PROVINCE',
             x.segment2,
             v_meaning,
             x.emp_category,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             v_naic_code);

    end loop; -- End loop cur_notfound

    end loop; -- End loop emp_cat

  end loop; -- End loop cur_eeog

  prev_province_name := 'test';
  prev_employment_category := 'te';
  prev_naic_code := 'te';

  for i in 0..3 loop

      for j in cur_total_promotions(i) loop

      hr_utility.trace('Form5P: cur_total_promotions');

      v_count         	        := j.promotion_total;
      v_employment_category 	:= j.employment_category;
      v_sex 			:= j.sex;
      v_province                := j.province;

      open cur_meaning;
      fetch cur_meaning into v_province_name;
      close cur_meaning;

      if v_count <> 0 then    -- Only process when promotions exist

           if i = 0 then

              hr_utility.trace('Form5P: prev_province_name: ' || prev_province_name);
              hr_utility.trace('Form5P: v_province_name: ' || v_province_name);
              hr_utility.trace('Form5P: prev_naic_code: ' || prev_naic_code);
              hr_utility.trace('Form5P: v_naic_code: ' || v_naic_code);
              hr_utility.trace('Form5P: prev_emp_category: ' || prev_employment_category);
              hr_utility.trace('Form5P: v_emp_category: ' || v_employment_category);

              if ((ltrim(rtrim(v_province_name))
                                 <>ltrim(rtrim(prev_province_name))) or
                 (ltrim(rtrim(prev_naic_code)) <> ltrim(rtrim(v_naic_code))) or
                 (ltrim(rtrim(prev_employment_category)) <>
                          ltrim(rtrim(v_employment_category)))) then

                hr_utility.trace('Form5P: cur_total_promotions : Inside If');
                per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

                insert into per_ca_ee_report_lines
                (request_id,
                 line_number,
                 context,
                 segment1,
                 segment2,
                 segment3,
                 segment4,
                 segment5,
                 segment6,
                 segment7,
                 segment8,
                 segment9,
                 segment10,
                 segment11,
                 segment12,
                 segment13,
                 segment14,
                 segment15,
                 segment21) values
                 (p_request_id,
                  per_ca_ee_extract_pkg.k,
                  'FORM5P',
                  'PROVINCE',
                  v_province_name,
                  v_employment_category,
                  nvl(v_count,0),
                  decode(v_sex,'M',v_count,0),
                  decode(v_sex,'F',v_count,0),
                  '0',
                  '0',
                  '0',
                  '0',
                  '0',
                  '0',
                  '0',
                  '0',
                  '0',
                  v_naic_code);

              else

                 if prev_province_name = v_province_name and
                    prev_naic_code = v_naic_code and
                    prev_employment_category = v_employment_category and
                    prev_sex <> v_sex then

                    if v_sex = 'M' then

                      update per_ca_ee_report_lines set
                        segment5=nvl(v_count,0),
                        segment4=segment4 + nvl(v_count,0)
                      where request_id=p_request_id and
                        line_number = per_ca_ee_extract_pkg.k and
                        context='FORM5P' and
                        segment1='PROVINCE' and
                        segment2=v_province_name and
                        segment3=v_employment_category and
                        segment21=v_naic_code;

                    elsif v_sex = 'F' then

                      update per_ca_ee_report_lines set
                        segment6=nvl(v_count,0),
                        segment4=segment4 + nvl(v_count,0)
                      where request_id=p_request_id and
                        line_number = per_ca_ee_extract_pkg.k and
                        context='FORM5P' and
                        segment1='PROVINCE' and
                        segment2=v_province_name and
                        segment3=v_employment_category and
                        segment21=v_naic_code;

                    end if;

                 end if;

              end if;

              prev_province_name 	:= v_province_name;
              prev_naic_code            := v_naic_code;
              prev_employment_category 	:= v_employment_category;
              prev_sex                	:= v_sex;

          elsif i = 1 then


           if v_sex = 'M' then

             update per_ca_ee_report_lines set
               segment7 = nvl(segment7,0) + nvl(v_count,0),
               segment8 = nvl(v_count,0)
             where
               request_id = p_request_id and
               context = 'FORM5P' and
               segment1 = 'PROVINCE' and
               segment2 = v_province_name and
               segment3 = v_employment_category and
     	       segment21 = v_naic_code;

           elsif v_sex = 'F' then

             update per_ca_ee_report_lines set
               segment7 = nvl(segment7,0) + nvl(v_count,0),
               segment9 = nvl(v_count,0)
             where
               request_id = p_request_id and
               context = 'FORM5P' and
               segment1 = 'PROVINCE' and
               segment2 = v_province_name and
               segment3 = v_employment_category and
               segment21 = v_naic_code;

           end if;

         elsif i = 2 then

           if v_sex = 'M' then

             update per_ca_ee_report_lines set
               segment10 = nvl(segment10,0) + nvl(v_count,0),
               segment11 = nvl(v_count,0)
             where
               request_id = p_request_id and
               context = 'FORM5P' and
               segment1 = 'PROVINCE' and
               segment2 = v_province_name and
               segment3 = v_employment_category and
               segment21 = v_naic_code;

           elsif v_sex = 'F' then

             update per_ca_ee_report_lines set
               segment10 = nvl(segment10,0) + nvl(v_count,0),
               segment12 = nvl(v_count,0)
             where
               request_id = p_request_id and
               context    = 'FORM5P' and
               segment1   = 'PROVINCE' and
               segment2   = v_province_name and
               segment3   = v_employment_category and
               segment21  = v_naic_code;

           end if;

         elsif i = 3 then

           if v_sex = 'M' then

             update per_ca_ee_report_lines set
               segment13 = nvl(segment13,0) + nvl(v_count,0),
               segment14 = nvl(v_count,0)
             where
               request_id = p_request_id and
               context = 'FORM5P' and
               segment1 = 'PROVINCE' and
               segment2 = v_province_name and
               segment3 = v_employment_category and
               segment21 = v_naic_code;

            elsif v_sex = 'F' then

              update per_ca_ee_report_lines set
                segment13 = nvl(segment13,0) + nvl(v_count,0),
                segment15 = nvl(v_count,0)
              where
                request_id = p_request_id and
                context = 'FORM5P' and
                segment1 = 'PROVINCE' and
                segment2 = v_province_name and
                segment3 = v_employment_category and
                segment21 = v_naic_code;

             end if;

         end if;
     end if;
  end loop; -- End loop cur_total_promotions
  end loop; -- End loop for designated group members.

  for i in 1..3 loop
    for j in cur_notfound_promotions(i) loop

      insert into per_ca_ee_report_lines
      (request_id,
       line_number,
       context,
       segment1,
       segment2,
       segment3,
       segment4,
       segment5,
       segment6,
       segment7,
       segment8,
       segment9,
       segment10,
       segment11,
       segment12,
       segment13,
       segment14,
       segment15,
       segment21) values
       (p_request_id,
        per_ca_ee_extract_pkg.k,
        'FORM5P',
        'PROVINCE',
        j.segment2,
        j.emp_category,
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        '0',
        v_naic_code);

    end loop;
  end loop; -- End loop for designated group members.

  for i in cur_count_national_promotions loop

    insert into per_ca_ee_report_lines
      (request_id,
       line_number,
       context,
       segment1,
       segment2,
       segment3,
       segment4,
       segment5,
       segment6,
       segment7,
       segment8,
       segment9,
       segment10,
       segment11,
       segment12,
       segment13,
       segment14,
       segment21) values
      (p_request_id,
       per_ca_ee_extract_pkg.k,
       'FORM5P',
       'NATIONAL',
       i.segment3,
       i.segment4,
       i.segment5,
       i.segment6,
       i.segment7,
       i.segment8,
       i.segment9,
       i.segment10,
       i.segment11,
       i.segment12,
       i.segment13,
       i.segment14,
       i.segment15,
       v_naic_code);

  end loop;

  for count_national in cur_count_national loop

   hr_utility.trace('Form5: cur_count_national. ');

    insert into per_ca_ee_report_lines
           (request_id,
            line_number,
            context,
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment21) values
            ( p_request_id,
             per_ca_ee_extract_pkg.k,
             'FORM5',
             'NATIONAL',
             count_national.segment3,
             count_national.segment4,
             count_national.segment5,
             count_national.segment6,
             count_national.segment7,
             count_national.segment8,
             count_national.segment9,
             count_national.segment10,
             count_national.segment11,
             count_national.segment12,
             count_national.segment13,
             count_national.segment14,
             count_national.segment15,
             count_national.segment16,
             v_naic_code);

    end loop; -- End loop cur_count_national

    prev_naic_code := v_naic_code;

  end loop; -- End loop cur_naic

  return 1;

end;
end form5;

function form6(p_business_group_id in number,
               p_request_id     in number,
               p_year           in varchar2,
               p_date_tmp_emp   in date) return number is

  l_year_start date;
  l_year_end date;

begin

  l_year_start :=  trunc(to_date(p_year,'YYYY'),'Y');
  l_year_end   :=  add_months(trunc(to_date(p_year,'YYYY'),'Y'), 12) -1;

declare

  cursor cur_naic is
  select
    pert.segment4       naic_code
  from
    per_ca_ee_report_lines      pert
  where
    pert.request_id = p_request_id and
    pert.context = 'FORM12';

  v_naic_code			hr_lookups.lookup_code%TYPE;

   cursor cur_terminated_total is
   select
     count(distinct count_total) count_total,
     meaning 			meaning,
     sex 			sex,
     employment_category	employment_category,
     region_1  			region_1
   from
   (
     select
       paf.person_id				count_total,
       hl.meaning 				meaning,
       ppf.sex 					sex,
       substr(paf.employment_category,1,2) 	employment_category,
       hl1.region_1  				region_1
     from
       hr_lookups hl,
       per_jobs pj,
       per_assignments_f paf,
       per_people_f ppf,
       per_person_types ppt,
       per_periods_of_service ppos,
       hr_locations hl1,
       hr_soft_coding_keyflex hsck
     where
       hl.lookup_type='EEOG' and
       upper(ltrim(rtrim(hl.lookup_code)))
                       = upper(ltrim(rtrim(pj.job_information1))) and
       upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
       pj.job_id=paf.job_id and
       paf.primary_flag = 'Y' and
       paf.employment_category is not null and
       substr(paf.employment_category,1,2) in ('FR','PR','PT') and
       --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
       ppos.actual_termination_date between
         paf.effective_start_date and
         paf.effective_end_date   and
       paf.location_id=hl1.location_id and
       paf.person_id=ppf.person_id and
       --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
       ppos.actual_termination_date between
         ppf.effective_start_date and
         ppf.effective_end_date   and
       ppf.person_type_id = ppt.person_type_id and
       --upper(ltrim(rtrim(ppt.system_person_type)))='EX_EMP' and
       ppf.business_group_id=p_business_group_id and
       ppf.person_id=ppos.person_id and
       ppos.actual_termination_date is not null and
       ppos.actual_termination_date >= l_year_start and
       ppos.actual_termination_date <=  l_year_end and
       (
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is not null and
         hsck.segment6 = v_naic_code
       )
       OR
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is null and
         hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
                        where request_id = p_request_id and
                              context = 'FORM13' and
                              segment1 = 'NAIC' and
                              segment2 = v_naic_code)
      )
      ) and
      exists
       (
         select 'X'
           from per_pay_proposals_v2 pppv
         where
           pppv.assignment_id = paf.assignment_id and
           pppv.approved = 'Y' and
           pppv.change_date <= l_year_end
       )
     union all
     select
       paf.person_id			count_total,
       hl.meaning 			meaning,
       ppf.sex 				sex,
       'FR' 	                        employment_category,
       hl1.region_1  		        region_1
     from
       hr_lookups hl,
       per_jobs pj,
       per_assignments_f paf,
       per_people_f ppf,
       per_person_types ppt,
       per_periods_of_service ppos,
       hr_locations hl1,
       hr_soft_coding_keyflex hsck
     where
       hl.lookup_type='EEOG' and
       upper(ltrim(rtrim(hl.lookup_code)))
                     = upper(ltrim(rtrim(pj.job_information1))) and
       upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
       pj.job_id=paf.job_id and
       paf.primary_flag = 'Y' and
       --l_year_end between
       ppos.actual_termination_date between
         paf.effective_start_date and
         paf.effective_end_date   and
       (paf.employment_category is null OR
       substr(paf.employment_category,1,2) in ('FR','PR','PT')) and
       paf.location_id=hl1.location_id and
       paf.person_id=ppf.person_id and
       --l_year_end between
       ppos.actual_termination_date between
         ppf.effective_start_date and
         ppf.effective_end_date   and
       ppf.person_type_id = ppt.person_type_id and
       --upper(ltrim(rtrim(ppt.system_person_type)))='EX_EMP' and
       ppf.business_group_id=p_business_group_id and
       ppf.person_id=ppos.person_id and
       ppos.actual_termination_date is not null and
       ppos.actual_termination_date >= l_year_start and
       ppos.actual_termination_date <=  l_year_end and
       (
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is not null and
         hsck.segment6 = v_naic_code
       )
       OR
       (
         hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
         hsck.segment6 is null and
         hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
                        where request_id = p_request_id and
                              context = 'FORM13' and
                              segment1 = 'NAIC' and
                              segment2 = v_naic_code)
      )
      ) and
      exists
       (
         select 'X'
           from per_pay_proposals_v2 pppv
         where
           pppv.assignment_id = paf.assignment_id and
           pppv.approved = 'Y' and
           pppv.change_date <= l_year_end
       )
    )
    group by region_1,meaning,employment_category,sex
    order by region_1,meaning,employment_category,sex;

    v_count                 	number(10);
    v_meaning               	hr_lookups.meaning%TYPE;
    v_employment_category   	per_assignments_f.employment_category%TYPE;
    v_sex                   	per_people_f.sex%TYPE;
    v_region_1    		hr_locations.region_1%TYPE;
    prev_meaning                hr_lookups.meaning%TYPE := 'test';
    prev_employment_category    per_assignments_f.employment_category%TYPE := '
';
    prev_naic_code              hr_lookups.lookup_code%TYPE;
    prev_sex                    per_people_f.sex%TYPE := '';
    prev_region_1     		hr_locations.region_1%TYPE;

  cursor cur_hr_lookups is
  select
    meaning
  from
    hr_lookups
  where
    lookup_type='CA_PROVINCE' and
    lookup_code=v_region_1;

  v_province_name    hr_lookups.meaning%TYPE;

  cursor cur_terminated(desig NUMBER) is
  select
    count(distinct person_id) 	count,
    meaning 			meaning,
    employment_category 	employment_category,
    sex  			sex,
    region_1  			region_1
  from
  (
    select
      paf.person_id 				person_id,
      hl.meaning 				meaning,
      substr(paf.employment_category,1,2) 	employment_category,
      ppf.sex 					sex,
      hl1.region_1  				region_1
    from
      hr_lookups hl,
      per_jobs pj,
      per_assignments_f paf,
      per_people_f ppf,
      per_person_types ppt,
      per_periods_of_service ppos ,
      hr_locations hl1,
      hr_soft_coding_keyflex hsck
    where
      upper(ltrim(rtrim(hl.lookup_type)))='EEOG' and
      upper(ltrim(rtrim(hl.lookup_code)))
                    = upper(ltrim(ltrim(pj.job_information1))) and
      upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
      pj.job_id=paf.job_id and
      paf.primary_flag = 'Y' and
      --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
       ppos.actual_termination_date between
        paf.effective_start_date and
        paf.effective_end_date   and
      paf.employment_category is not null and
      substr(paf.employment_category,1,2) in ('FR','PR','PT') and
      paf.location_id=hl1.location_id and
      paf.person_id=ppf.person_id and
      --decode(paf.employment_category,'PT',p_date_tmp_emp,l_year_end) between
       ppos.actual_termination_date between
        ppf.effective_start_date and
        ppf.effective_end_date   and
      ppf.person_type_id = ppt.person_type_id and
      --UPPER(LTRIM(RTRIM(ppt.system_person_type)))='EX_EMP' and
      ppf.business_group_id=p_business_group_id and
      ppf.person_id=ppos.person_id and
      ppos.actual_termination_date is not null and
      ppos.actual_termination_date >= l_year_start and
      ppos.actual_termination_date <=  l_year_end and
      decode(desig,1,per_information5,
        2,per_information6,
        3,per_information7)='Y' and
      (
      (
        hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
        hsck.segment6 is not null and
        hsck.segment6 = v_naic_code
      )
      OR
      (
        hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
        hsck.segment6 is null and
        hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
                        where request_id = p_request_id and
                              context = 'FORM13' and
                              segment1 = 'NAIC' and
                              segment2 = v_naic_code)
      )
     ) and
      exists
       (
         select 'X'
           from per_pay_proposals_v2 pppv
         where
           pppv.assignment_id = paf.assignment_id and
           pppv.approved = 'Y' and
           pppv.change_date <= l_year_end
       )
    union all
    select
      paf.person_id 				person_id,
      hl.meaning 				meaning,
      'FR' 					employment_category,
      ppf.sex 					sex,
      hl1.region_1  				region_1
    from
      hr_lookups hl,
      per_jobs pj,
      per_assignments_f paf,
      per_people_f ppf,
      per_person_types ppt,
      per_periods_of_service ppos ,
      hr_locations hl1,
      hr_soft_coding_keyflex hsck
    where
      upper(ltrim(rtrim(hl.lookup_type)))='EEOG' and
      upper(ltrim(rtrim(hl.lookup_code)))
                     = upper(ltrim(ltrim(pj.job_information1))) and
      upper(ltrim(rtrim(pj.job_information_category))) = 'CA' and
      pj.job_id=paf.job_id and
      paf.primary_flag = 'Y' and
      --l_year_end between
      ppos.actual_termination_date between
        paf.effective_start_date and
        paf.effective_end_date   and
      (paf.employment_category is null OR
       substr(paf.employment_category,1,2) in ('FR','PR','PT')) and
      paf.location_id=hl1.location_id and
      paf.person_id=ppf.person_id and
      --l_year_end between
      ppos.actual_termination_date between
        ppf.effective_start_date and
        ppf.effective_end_date   and
      ppf.person_type_id = ppt.person_type_id and
      --UPPER(LTRIM(RTRIM(ppt.system_person_type)))='EX_EMP' and
      ppf.business_group_id=p_business_group_id and
      ppf.person_id=ppos.person_id and
      ppos.actual_termination_date is not null and
      ppos.actual_termination_date >= l_year_start and
      ppos.actual_termination_date <=  l_year_end and
      decode(desig,1,per_information5,
        2,per_information6,
        3,per_information7)='Y' and
      (
      (
        hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
        hsck.segment6 is not null and
        hsck.segment6 = v_naic_code
      )
      OR
      (
        hsck.soft_coding_keyflex_id=paf.soft_coding_keyflex_id and
        hsck.segment6 is null and
        hsck.segment1 in (select segment3
                        from per_ca_ee_report_lines
                        where request_id = p_request_id and
                              context = 'FORM13' and
                              segment1 = 'NAIC' and
                              segment2 = v_naic_code)
      )
      ) and
      exists
      (
        select 'X'
          from per_pay_proposals_v2 pppv
        where
          pppv.assignment_id = paf.assignment_id and
          pppv.approved = 'Y' and
          pppv.change_date <= l_year_end
      )
    )
    group by region_1,meaning,employment_category,sex
    order by region_1,meaning,employment_category,sex;

  cursor cur_eeog is
  select
    meaning
  from
    hr_lookups
  where
   lookup_type='EEOG';

  cursor cur_notfound(p_emp_cat number) is
  select
    segment2,
    v_meaning,
    decode(p_emp_cat,1,'FR',2,'PR',3,'PT')    emp_category
  from
    per_ca_ee_report_lines where
    request_id=p_request_id and
    context='FORM14' and
    segment1='PROVINCE' and
    segment3 <> '0'
  minus
  select
    segment2,
    segment3,
    segment4
  from
    per_ca_ee_report_lines
  where
    request_id=p_request_id and
    context='FORM6' and
    segment1='PROVINCE'and
    segment21 = v_naic_code;

  cursor cur_count_national is
  select
     segment3,
     segment4,
     sum(to_number(segment5))           segment5,
     sum(to_number(segment6))           segment6,
     sum(to_number(segment7))           segment7,
     sum(to_number(segment8))           segment8,
     sum(to_number(segment9))           segment9,
     sum(to_number(segment10))          segment10,
     sum(to_number(segment11))          segment11,
     sum(to_number(segment12))          segment12,
     sum(to_number(segment13))          segment13,
     sum(to_number(segment14))          segment14,
     sum(to_number(segment15))          segment15,
     sum(to_number(segment16))          segment16
   from
     per_ca_ee_report_lines
   where
     request_id = p_request_id and
     context = 'FORM6' and
     segment1 = 'PROVINCE' and
     segment21 = v_naic_code
   group by segment3,segment4;

begin

   hr_utility.trace('Form6 starts Here !!!!!!');

   for naic in cur_naic loop

     v_naic_code := naic.naic_code;

     hr_utility.trace('Form6: v_naic = ' || v_naic_code );

     for j in cur_terminated_total
     loop

       v_count         		:= j.count_total;
       v_meaning       		:= j.meaning;
       v_employment_category 	:= j.employment_category;
       v_sex 			:= j.sex;
       v_region_1 		:= j.region_1;

       open cur_hr_lookups;
       fetch cur_hr_lookups into v_province_name;
       close cur_hr_lookups;

        if ((prev_region_1 <> v_region_1) or
        (ltrim(rtrim(prev_meaning)) <> ltrim(rtrim(v_meaning))) or
        (ltrim(rtrim(prev_naic_code)) <> ltrim(rtrim(v_naic_code))) or
        (ltrim(rtrim(prev_employment_category)) <>
                   ltrim(rtrim(v_employment_category)))) then

           per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

           insert into per_ca_ee_report_lines
           (request_id,
            line_number,
            context,
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment16,
            segment21
            ) values
            (p_request_id,
             k,
             'FORM6',
             'PROVINCE',
             v_province_name,
             v_meaning,
             v_employment_category,
             nvl(v_count,0),
             decode(v_sex,'F',v_count,0),
             decode(v_sex,'M',v_count,0),
             '0',
             '0',
             '0',
             '0',
             '0',
             '0',
             '0',
             '0',
             '0',
	     v_naic_code
             );

        else

           if prev_region_1 		= v_region_1 and
           prev_meaning 		= v_meaning and
           prev_naic_code 		= v_naic_code and
           prev_employment_category 	= v_employment_category and
           prev_sex 			<> v_sex then

           if v_sex = 'M' then

             update per_ca_ee_report_lines set
                segment7=nvl(v_count,0),
                segment5=segment5 + nvl(v_count,0)
             where request_id=p_request_id and
                   line_number = per_ca_ee_extract_pkg.k and
                   context='FORM5' and
                   segment1='PROVINCE' and
                   segment2=v_province_name and
                   segment3=v_meaning and
                   segment4=v_employment_category and
                   segment21=v_naic_code;

           elsif v_sex = 'F' then

             update per_ca_ee_report_lines set
                segment6=nvl(v_count,0),
                segment5=segment5 + nvl(v_count,0)
             where request_id=p_request_id and
                   line_number = per_ca_ee_extract_pkg.k and
                   context='FORM5' and
                   segment1='PROVINCE' and
                   segment2=v_province_name and
                   segment3=v_meaning and
                   segment4=v_employment_category and
                   segment21=v_naic_code;

              end if;

           end if;

        end if;

        prev_meaning 			:= v_meaning;
        prev_employment_category 	:= v_employment_category;
        prev_sex                	:= v_sex;
        prev_region_1   		:= v_region_1;
        prev_naic_code 			:= v_naic_code;

     end loop; -- End loop cur_terminated_total

     for i in 1..3 loop

        for j in cur_terminated(i)
        loop

          v_sex 		:= j.sex;
          v_employment_category := j.employment_category;
          v_meaning 		:= j.meaning;
          v_count 		:= j.count;
          v_region_1 		:= j.region_1;

          open cur_hr_lookups;
          fetch cur_hr_lookups into v_province_name;
          close cur_hr_lookups;

          if i = 1 then

             if v_sex = 'M' then

             update per_ca_ee_report_lines set
               segment8 = nvl(segment8,0) + nvl(v_count,0),
               segment9 = 0,
               segment10 = nvl(v_count,0)
             where
               request_id = p_request_id and
               context  = 'FORM6' and
               segment1 = 'PROVINCE' and
               segment2 = v_province_name and
               segment3 = v_meaning and
               segment3 = v_employment_category and
               segment21 = v_naic_code;

            elsif v_sex = 'F' then

            update per_ca_ee_report_lines set
              segment8 = nvl(segment8,0) + nvl(v_count,0),
              segment9 = nvl(v_count,0),
              segment10 = 0
            where
              request_id = p_request_id and
              context='FORM6' and
              segment1 = 'PROVINCE' and
              segment2 = v_province_name and
              segment3 = v_meaning and
              segment3 = v_employment_category and
              segment21 = v_naic_code;

            end if;

          elsif i = 2 then

            if v_sex = 'M' then

              update per_ca_ee_report_lines set
                segment11 = nvl(segment11,0) + nvl(v_count,0),
                segment12 = 0,
                segment13 = nvl(v_count,0)
              where
                request_id = p_request_id and
                context='FORM6' and
                segment1 = 'PROVINCE' and
                segment2 = v_province_name and
                segment3 = v_meaning and
                segment3 = v_employment_category and
                segment21 = v_naic_code;

            elsif v_sex = 'F' then

              update per_ca_ee_report_lines set
                segment11 = nvl(segment11,0) + nvl(v_count,0),
                segment12 = nvl(v_count,0),
                segment13 = 0
              where
                request_id = p_request_id and
                context='FORM6' and
                segment1 = 'PROVINCE' and
                segment2 = v_province_name and
                segment3 = v_meaning and
                segment3 = v_employment_category and
                segment21 = v_naic_code;

            end if;

         elsif i = 3 then

           if v_sex = 'M' then

             update per_ca_ee_report_lines set
               segment14 = nvl(segment14,0) + nvl(v_count,0),
               segment15 = 0,
               segment16 = nvl(v_count,0)
              where
                request_id = p_request_id and
                context='FORM6' and
                segment1 = 'PROVINCE' and
                segment2 = v_province_name and
                segment3 = v_meaning and
                segment3 = v_employment_category and
                segment21 = v_naic_code;

            elsif v_sex = 'F' then

              update per_ca_ee_report_lines set
              segment14 = nvl(segment14,0) + nvl(v_count,0),
              segment15 = nvl(v_count,0),
              segment16 = 0
              where
                request_id = p_request_id and
                context='FORM6' and
                segment1 = 'PROVINCE' and
                segment2 = v_province_name and
                segment3 = v_meaning and
                segment3 = v_employment_category and
                segment21 = v_naic_code;

            end if;
          end if;

          end loop; -- End loop cur_terminated

        end loop; -- End loop Designated Group


   for i in cur_eeog loop

    v_meaning := i.meaning;

    hr_utility.trace('Form6: cur_eeog: v_eeog' || v_meaning);

     for emp_cat in 1..3 loop

     for x in cur_notfound(emp_cat) loop

       hr_utility.trace('Form6: cur_notfound' );

     per_ca_ee_extract_pkg.k := per_ca_ee_extract_pkg.k + 1;

           insert into per_ca_ee_report_lines
           (request_id,
            line_number,
            context,
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment16,
            segment21) values
            ( p_request_id,
             per_ca_ee_extract_pkg.k,
             'FORM6',
             'PROVINCE',
             x.segment2,
             v_meaning,
             x.emp_category,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             0,
             v_naic_code);

    end loop; -- End loop cur_notfound

    end loop; -- End loop emp_cat

  end loop; -- End loop cur_eeog

  for count_national in cur_count_national loop

    hr_utility.trace('Form6: cur_count_national. ');

    insert into per_ca_ee_report_lines
           (request_id,
            line_number,
            context,
            segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment21) values
            ( p_request_id,
             per_ca_ee_extract_pkg.k,
             'FORM6',
             'NATIONAL',
             count_national.segment3,
             count_national.segment4,
             count_national.segment5,
             count_national.segment6,
             count_national.segment7,
             count_national.segment8,
             count_national.segment9,
             count_national.segment10,
             count_national.segment11,
             count_national.segment12,
             count_national.segment13,
             count_national.segment14,
             count_national.segment15,
             count_national.segment16,
             v_naic_code);

    end loop; -- End loop cur_count_total

  prev_naic_code := v_naic_code;

  end loop; --End loop of cur_naic

  return 1;

end;
end form6;


function update_rec(p_request_id number) return number is

begin

declare

  cursor cur_temp_count is select
    segment13,
    segment14,
    segment15
  from
    per_ca_ee_report_lines
  where
    request_id=p_request_id and
    context='FORM11';

  v_tot_fr        number;
  v_tot_pr        number;
  v_tot_pt        number;

  cursor cur_max_naic is
  select
    segment4 max_naic_code,
    max(to_number(segment3))
  from
    per_ca_ee_report_lines
  where
    request_id = p_request_id and
    context = 'FORM12' and
    segment1 = 'NAIC'
  group by segment4;

  v_max_naic_code	hr_lookups.lookup_code%TYPE;
  v_max_naic_count	number;

  cursor cur_less_than_max_naic is
  select
    segment4 naic_code
  from
    per_ca_ee_report_lines
  where request_id = p_request_id
  and   to_number(segment3) < (select to_number(lookup_code)
                  from pay_ca_legislation_info
                  where lookup_type = 'EER1')
  and context = 'FORM12' and
      segment4 <> v_max_naic_code;

  v_not_max_naic     hr_lookups.lookup_code%TYPE;

  cursor cur_not_max_naic_data is
  select
    context,
    segment1,
    segment2,
    segment3,
    segment4,
    segment5,
    segment6,
    segment7,
    segment8,
    segment9,
    segment10,
    segment11,
    segment12,
    segment13,
    segment14,
    segment15,
    segment16,
    segment17,
    segment18,
    segment19,
    segment20
    segment21
  from per_ca_ee_report_lines
  where
   request_id = p_request_id and
   context   in ('FORM3','FORM4','FORM5','FORM6') and
   segment1   = 'NATIONAL' and
   segment21  = v_not_max_naic;

begin

  hr_utility.trace('Function update_rec starts here !!!!');

  open cur_temp_count;
  fetch cur_temp_count
  into v_tot_fr,
       v_tot_pr,
       v_tot_pt;
  close cur_temp_count;

  if (nvl(v_tot_fr,0) + nvl(v_tot_pr,0) + nvl(v_tot_pt,0)) <= 0 then
    return -1;
  else

    if
     ( ((nvl(v_tot_pt,0)/(nvl(v_tot_fr,0) + nvl(v_tot_pr,0) + nvl(v_tot_pt,0))) * 100)     >= 20 ) then

      update per_ca_ee_report_lines set
        segment20 = 'Y'
      WHERE
        request_id=p_request_id and
        context in ('FORM2','FORM3','FORM4','FORM5','FORM6');
    else

      update per_ca_ee_report_lines set
        segment20 = decode(segment3,'PT','N','Y')
      WHERE
        request_id=p_request_id and
        context   in ('FORM2','FORM3','FORM4','FORM5','FORM6') and
        segment1  = 'NATIONAL';

      update per_ca_ee_report_lines set
        segment20 = decode(segment4,'PT','N','Y')
      WHERE
        request_id=p_request_id and
        context  in ('FORM2','FORM3','FORM4','FORM5','FORM6') and
        segment1 in ('CMA','PROVINCE');

    end if;

   ------------------------------------------------------------
   -- update the NAIC record which has more than 1000 people --
   -- or max number of people with other NAIC.               --
   ------------------------------------------------------------

   open cur_max_naic;
   fetch cur_max_naic
   into  v_max_naic_code,
         v_max_naic_count;
   close cur_max_naic;

   hr_utility.trace('UPDATE_REC: v_max_naic_code: ' || v_max_naic_code);

   for naic in cur_less_than_max_naic loop

     v_not_max_naic := naic.naic_code;

     hr_utility.trace('UPDATE_REC: v_not_max_naic: ' || v_not_max_naic);

       for i in cur_not_max_naic_data  loop

         hr_utility.trace('UPDATE_REC: Form3 - 6' );

         update per_ca_ee_report_lines
         set
           segment4  = segment4 + i.segment4,
           segment5  = segment5 + i.segment5,
           segment6  = segment6 + i.segment6,
           segment7  = segment7 + i.segment7,
           segment8  = segment8 + i.segment8,
           segment9  = segment9 + i.segment9,
           segment10 = segment10 + i.segment10,
           segment11 = segment11 + i.segment11,
           segment12 = segment12 + i.segment12,
           segment13 = segment13 + i.segment13,
           segment14 = segment14 + i.segment14,
           segment15 = segment15 + i.segment15
         where
           request_id = p_request_id and
           context  = i.context and
           segment1 = i.segment1 and
           segment2 = i.segment2 and
           segment3 = i.segment3 and
           segment21 = v_max_naic_code;

           hr_utility.trace('UPDATE_REC: Form3 - 6 End' );

       end loop; -- End loop cur_not_max_naic_data

       delete from per_ca_ee_report_lines
       where  request_id = p_request_id and
              segment21  = v_not_max_naic;
     end loop;

  commit;
  return 1;

  end if;

end;

end update_rec;

end per_ca_ee_extract_pkg;

/
