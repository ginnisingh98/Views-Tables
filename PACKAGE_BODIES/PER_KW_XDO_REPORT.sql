--------------------------------------------------------
--  DDL for Package Body PER_KW_XDO_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_KW_XDO_REPORT" AS
/* $Header: pekwxdor.pkb 120.4 2006/12/06 06:49:57 spendhar noship $ */
  PROCEDURE get_disability_data
    (p_request_id                 IN  NUMBER
     ,p_report_name               IN  VARCHAR2
     ,p_date                      IN  VARCHAR2 DEFAULT NULL
     ,p_business_group_id         IN  NUMBER DEFAULT NULL
     ,p_org_structure_id          IN  NUMBER DEFAULT NULL
     ,p_org_structure_version_id  IN  NUMBER DEFAULT NULL
     --,p_organization_id           IN  NUMBER DEFAULT NULL
     ,p_legal_employer            IN  NUMBER DEFAULT NULL
     ,p_disability_type           IN  VARCHAR2 DEFAULT NULL
     ,p_disability_status         IN  VARCHAR2 DEFAULT NULL
     ,l_xfdf_blob                 OUT NOCOPY BLOB) AS
    l_parent_id           NUMBER;
    l_date                DATE;
    l_business_group_id   NUMBER;
    CURSOR csr_get_bg_id IS
    SELECT business_group_id
    FROM   per_business_groups
    WHERE  business_group_id = nvl(p_business_group_id, business_group_id)
    AND    legislation_code = 'KW';
    rec_get_bg_id  csr_get_bg_id%ROWTYPE;
    CURSOR csr_get_org_id IS
    SELECT org.organization_id
           ,org.name
    FROM   hr_all_organization_units org
           ,hr_organization_information hoi
    WHERE  org.organization_id IN (SELECT pose.organization_id_child
                                   FROM   per_org_structure_elements pose
                                   CONNECT BY pose.organization_id_parent = PRIOR pose.organization_id_child
                                   AND    pose.org_structure_version_id = p_org_structure_version_id
                                   START WITH pose.organization_id_parent = nvl(p_legal_employer, l_parent_id)
                                   AND    pose.org_structure_version_id = p_org_structure_version_id
                                   UNION
                                   SELECT nvl(p_legal_employer, l_parent_id)
                                   FROM   DUAL)
    AND    p_org_structure_version_id IS NOT NULL
    AND    (p_legal_employer IS NOT NULL OR l_parent_id IS NOT NULL)
    AND    org.organization_id = hoi.organization_id
    AND    hoi.org_information_context = 'CLASS'
    AND    hoi.org_information1 = 'HR_LEGAL_EMPLOYER'
    UNION
    SELECT org.organization_id
           ,org.name
    FROM   hr_all_organization_units org
           ,hr_organization_information hoi
    WHERE  org.organization_id = NVL(p_legal_employer,org.organization_id)
    AND    org.business_group_id = l_business_group_id
    AND    p_org_structure_version_id IS NULL
    AND    org.organization_id = hoi.organization_id
    AND    hoi.org_information_context = 'CLASS'
    AND    hoi.org_information1 = 'HR_LEGAL_EMPLOYER';
    rec_get_org_id       csr_get_org_id%ROWTYPE;
    CURSOR csr_get_dis_emp IS
    SELECT /*+ INDEX(disb, PER_DISABILITIES_F_PK) */ people.employee_number
           ,people.full_name
           ,period.date_start
           ,hr3.meaning disability_status
           ,job.name job_name
           ,pos.name position_name
           --,emp.name employment_office
           ,hr1.meaning disability_type
           ,hr2.meaning reason
           ,nvl(to_char(disb.degree),get_lookup_meaning('KW_DISABILITY_RANGE',(dis_information1))) rate
           --, null RATE
           ,disb.dis_information2 rep_description
           ,disb.incident_id
           ,disb.disability_id
    FROM   per_all_assignments_f      assg
           ,per_all_people_f          people
           ,per_disabilities_f        disb
           ,per_jobs                  job
           ,per_all_positions         pos
           ,per_periods_of_service    period
           ,hr_lookups hr1
           ,hr_lookups hr2
           ,hr_lookups hr3
           ,hr_all_organization_units org
           --,hr_all_organization_units emp
           ,hr_soft_coding_keyflex    hsck
    WHERE assg.person_id = people.person_id
    AND   assg.assignment_type = 'E'
    AND   (l_date) BETWEEN assg.effective_start_date
                  AND   assg.effective_end_date
    AND   (l_date) between people.effective_start_date
                  AND   people.effective_end_date
    AND   (l_date) between disb.effective_start_date
                  AND   disb.effective_end_date
    AND   assg.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
    AND   assg.job_id = job.job_id(+)
    AND   assg.position_id = pos.position_id(+)
    AND   people.person_id = period.person_id
    --AND   assg.business_group_id = org.business_group_id
    --AND   assg.organization_id = rec_get_org_id.organization_id
    AND   assg.business_group_id = org.business_group_id
    AND   org.business_group_id = l_business_group_id
    AND   hr1.lookup_type = 'DISABILITY_CATEGORY'
    AND   hr1.lookup_code = disb.category
    --AND   assg.organization_id = org.organization_id
    AND   disb.person_id = people.person_id
    AND   disb.reason = hr2.lookup_code(+)
    AND   hr2.lookup_type(+) = 'DISABILITY_REASON'
    AND   disb.status = hr3.lookup_code
    AND   hr3.lookup_type = 'DISABILITY_STATUS'
    AND   org.organization_id = rec_get_org_id.organization_id
    AND   nvl(p_disability_type, hr1.lookup_code) = hr1.lookup_code
    AND   nvl(p_disability_status, hr3.lookup_code) = hr3.lookup_code
    --AND   emp.organization_id = hsck.segment1
    AND   to_char(org.organization_id) = hsck.segment1
    AND   hsck.segment1 = to_char(rec_get_org_id.organization_id)
    ORDER BY  full_name, employee_number;
    rec_get_dis_emp       csr_get_dis_emp%ROWTYPE;
    l_org_name            VARCHAR2(80);
    l_structure_name      VARCHAR2(80);
    l_version             NUMBER;
    l_disability_type     VARCHAR2(80);
    l_disability_status   VARCHAR2(80);
    l_legal_employer      VARCHAR2(80);
    l_emp_found           NUMBER;
    i                     NUMBER;
    j                     NUMBER;
    l_incident_date       DATE;
    l_consultation_date   DATE;
    l_pg_count            NUMBER;
  BEGIN
    l_pg_count := 1;
    IF p_date IS NOT NULL THEN
      BEGIN
        SELECT fnd_date.canonical_to_date(p_date)
        INTO   l_date
        FROM   DUAL;
      EXCEPTION
        WHEN OTHERS THEN
          l_date := TRUNC(sysdate);
      END;
    ELSE
      l_date := TRUNC(sysdate);
    END IF;
    INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES (userenv('SESSIONID'), l_date);
    l_parent_id := NULL;
    l_org_name := NULL;
    l_structure_name := NULL;
    l_version := NULL;
    l_disability_type := NULL;
    l_disability_status := NULL;
    l_legal_employer := NULL;
    l_emp_found := 0;
    i := 1;
    j := 0;
    gxmltable.DELETE;
    gCtr := 1;
    IF p_org_structure_version_id IS NOT NULL
        AND p_legal_employer IS NULL THEN
      BEGIN
        SELECT distinct pose.organization_id_parent
        INTO   l_parent_id
        FROM   per_org_structure_elements pose
        WHERE  pose.org_structure_version_id = p_org_structure_version_id
        AND    pose.organization_id_parent NOT IN (SELECT pose1.organization_id_child
                                                   FROM   per_org_structure_elements pose1
                                                   WHERE  pose1.org_structure_version_id
                                                          = p_org_structure_version_id);
      EXCEPTION
        WHEN OTHERS THEN
          l_parent_id := NULL;
      END;
    END IF;
    IF p_business_group_id IS NOT NULL THEN
      BEGIN
        SELECT name
        INTO   l_org_name
        FROM   hr_organization_units
        WHERE  organization_id = p_business_group_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    IF p_org_structure_id IS NOT NULL THEN
      BEGIN
        SELECT name
        INTO   l_structure_name
        FROM   per_organization_structures
        WHERE  organization_structure_id = p_org_structure_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    IF p_org_structure_version_id IS NOT NULL THEN
      BEGIN
        SELECT version_number
        INTO   l_version
        FROM   per_org_structure_versions
        WHERE  org_structure_version_id = p_org_structure_version_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    IF p_disability_type IS NOT NULL THEN
      BEGIN
        SELECT meaning
        INTO   l_disability_type
        FROM   hr_lookups
        WHERE  lookup_type = 'DISABILITY_CATEGORY'
        AND    lookup_code = p_disability_type;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    IF p_disability_status IS NOT NULL THEN
      BEGIN
        SELECT meaning
        INTO   l_disability_status
        FROM   hr_lookups
        WHERE  lookup_type = 'DISABILITY_STATUS'
        AND    lookup_code = p_disability_status;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    IF p_legal_employer IS NOT NULL THEN
      BEGIN
        SELECT name
        INTO   l_legal_employer
        FROM   hr_organization_units
        WHERE  organization_id = p_legal_employer;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    --Populate parameter labels and values
    gxmltable(gCtr).tagName := 'report_date_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','REPORT_DATE_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'page_number_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','PAGE_NO_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'report_date_value';
    gxmltable(gCtr).tagValue := fnd_date.date_to_displaydate(sysdate);
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'of_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','OF_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'one_value';
    gxmltable(gCtr).tagValue := 1;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'count_value';
    gxmltable(gCtr).tagValue := null;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'report_parameters_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','REPORT_PARAMETERS_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_name_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','ORGANIZATION_NAME_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_name_value';
    gxmltable(gCtr).tagValue := l_org_name;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_hierarchy_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','ORGANIZATION_HIERARCHY_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_hierarchy_value';
    gxmltable(gCtr).tagValue := l_structure_name;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_version_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','ORGANIZATION_VERSION_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_version_value';
    gxmltable(gCtr).tagValue := l_version;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'disability_type_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','DISABILITY_TYPE_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'disability_type_value';
    gxmltable(gCtr).tagValue := l_disability_type;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'disability_status_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','DISABILITY_STATUS_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'disability_status_value';
    gxmltable(gCtr).tagValue := l_disability_status;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'legal_employer_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','LEGAL_EMPLOYER_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'legal_employer_value';
    gxmltable(gCtr).tagValue := l_legal_employer;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'effective_date_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','EFFECTIVE_DATE_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'effective_date_value';
    gxmltable(gCtr).tagValue := fnd_date.date_to_displaydate(l_date);
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := '0';
    gxmltable(gCtr).tagValue := ('-----------------------------------------------------');
    gctr := gctr + 1;
    OPEN csr_get_bg_id;
    LOOP
      FETCH csr_get_bg_id INTO rec_get_bg_id;
      EXIT WHEN csr_get_bg_id%NOTFOUND;
      l_business_group_id := rec_get_bg_id.business_group_id;
    OPEN csr_get_org_id;
    LOOP
      FETCH csr_get_org_id INTO rec_get_org_id;
      EXIT WHEN csr_get_org_id%NOTFOUND;
      --fnd_file.put_line(fnd_file.log,'in org cursor: '||rec_get_org_id.name);
      l_emp_found := 0;
      i := 1;
      OPEN csr_get_dis_emp;
      LOOP
        FETCH csr_get_dis_emp INTO rec_get_dis_emp;
        EXIT WHEN csr_get_dis_emp%NOTFOUND;
        IF i = 19 THEN
          i := 1;
        END IF;
        IF l_emp_found = 0 OR i = 1 THEN
          l_pg_count := l_pg_count + 1;
          gxmltable(gCtr).tagName := 'report_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','REPORT_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'report_date_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','REPORT_DATE_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'report_date_body_value';
          gxmltable(gCtr).tagValue := fnd_date.date_to_displaydate(sysdate);
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'page_number_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','PAGE_NO_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'of_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','OF_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'current_value';
          gxmltable(gCtr).tagValue := l_pg_count;
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'count_body_value';
          gxmltable(gCtr).tagValue := null;
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'organization_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','ORGANIZATION_LABEL');
          gctr := gctr + 1;
	      gxmltable(gCtr).tagName := 'organization_value';
          gxmltable(gCtr).tagValue := rec_get_org_id.name;
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'employee_number_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','EMPLOYEE_NUMBER_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'full_name_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','FULL_NAME_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'start_date_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','START_DATE_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'job_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','JOB_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'disability_type_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','DISABILITY_TYPE_BODY_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'reason_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','REASON_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'rate_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','RATE_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'disability_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','DISABILITY_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'incident_date_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','INCIDENT_DATE_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'assessment_date_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','ASSESSMENT_DATE_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '1';
          gxmltable(gCtr).tagValue := ('--------------------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '2';
          gxmltable(gCtr).tagValue := ('------------------------------------------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '3';
          gxmltable(gCtr).tagValue := ('--------------------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '4';
          gxmltable(gCtr).tagValue := ('--------------------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '5';
          gxmltable(gCtr).tagValue := ('---------------------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '6';
          gxmltable(gCtr).tagValue := ('------------------------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '7';
          gxmltable(gCtr).tagValue := ('----------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '8';
          gxmltable(gCtr).tagValue := ('-------------------------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '9';
          gxmltable(gCtr).tagValue := ('--------------------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '10';
          gxmltable(gCtr).tagValue := ('----------------');
          gctr := gctr + 1;
          l_emp_found := 1;
        END IF;
      --fnd_file.put_line(fnd_file.log,'in dis procedure: '||rec_get_dis_emp.employee_number||'*'||rec_get_org_id.name);
        l_incident_date := NULL;
        IF rec_get_dis_emp.incident_id IS NOT NULL THEN
          BEGIN
            SELECT incident_date
            INTO   l_incident_date
            FROM   per_work_incidents
            WHERE  incident_id = rec_get_dis_emp.incident_id;
          EXCEPTION
            WHEN OTHERS THEN
              l_incident_date := NULL;
          END;
        END IF;
        l_consultation_date := NULL;
        BEGIN
          SELECT consultation_date
          INTO   l_consultation_date
          FROM   per_disabilities_v
          WHERE  disability_id = rec_get_dis_emp.disability_id
          AND    l_date BETWEEN effective_start_date and effective_end_date;
        EXCEPTION
          WHEN OTHERS THEN
            l_consultation_date := NULL;
        END;
	gxmltable(gCtr).tagName := 'employee_number_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_dis_emp.employee_number);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'full_name_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_dis_emp.full_name);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'start_date_value'||' '||i;
        gxmltable(gCtr).tagValue := fnd_date.date_to_displaydate(rec_get_dis_emp.date_start);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'job_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_dis_emp.job_name);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'disability_type_body_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_dis_emp.disability_type);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'reason_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_dis_emp.reason);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'rate_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_dis_emp.rate);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'disability_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_dis_emp.rep_description);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'incident_date_value'||' '||i;
        gxmltable(gCtr).tagValue := fnd_date.date_to_displaydate(l_incident_date);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'assessment_date_value'||' '||i;
        gxmltable(gCtr).tagValue := fnd_date.date_to_displaydate(l_consultation_date);
        gctr := gctr + 1;
        i := i + 1;
      END LOOP;
      CLOSE csr_get_dis_emp;
      IF i < 18 AND l_emp_found = 1 THEN
        FOR j in i..18 LOOP
        gxmltable(gCtr).tagName := 'employee_number_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'full_name_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'start_date_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'job_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'disability_type_body_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'reason_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'rate_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'disability_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'incident_date_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'assessment_date_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        END LOOP;
      END IF;
    END LOOP;
    CLOSE csr_get_org_id;
    END LOOP;
    CLOSE csr_get_bg_id;
    WritetoCLOB ( l_xfdf_blob, l_pg_count );
  END get_disability_data;
 --------------------------------------------------------------------------------------------------------
 PROCEDURE get_contract_data
    (p_request_id                 IN  NUMBER
     ,p_report_name               IN  VARCHAR2
     ,p_date                      IN  VARCHAR2 DEFAULT NULL
     ,p_business_group_id         IN  NUMBER DEFAULT NULL
     ,p_org_structure_id          IN  NUMBER DEFAULT NULL
     ,p_org_structure_version_id  IN  NUMBER DEFAULT NULL
     ,p_legal_employer            IN  NUMBER DEFAULT NULL
     ,p_duration                  IN  NUMBER
     ,p_units                     IN  VARCHAR2
     ,l_xfdf_blob                 OUT NOCOPY BLOB) AS
    l_parent_id           NUMBER;
    l_date                DATE;
    l_business_group_id   NUMBER;
    CURSOR csr_get_bg_id IS
    SELECT business_group_id
    FROM   per_business_groups
    WHERE  business_group_id = nvl(p_business_group_id, business_group_id)
    AND    legislation_code = 'KW';
    rec_get_bg_id  csr_get_bg_id%ROWTYPE;
    CURSOR csr_get_org_id IS
    SELECT org.organization_id
           ,org.name
    FROM   hr_all_organization_units org
           ,hr_organization_information hoi
    WHERE  org.organization_id IN (SELECT pose.organization_id_child
                                   FROM   per_org_structure_elements pose
                                   CONNECT BY pose.organization_id_parent = PRIOR pose.organization_id_child
                                   AND    pose.org_structure_version_id = p_org_structure_version_id
                                   START WITH pose.organization_id_parent = nvl(p_legal_employer, l_parent_id)
                                   AND    pose.org_structure_version_id = p_org_structure_version_id
                                   UNION
                                   SELECT nvl(p_legal_employer, l_parent_id)
                                   FROM   DUAL)
    AND    p_org_structure_version_id IS NOT NULL
    AND    (p_legal_employer IS NOT NULL OR l_parent_id IS NOT NULL)
    AND    org.organization_id = hoi.organization_id
    AND    hoi.org_information_context = 'CLASS'
    AND    hoi.org_information1 = 'HR_LEGAL_EMPLOYER'
    UNION
    SELECT org.organization_id
           ,org.name
    FROM   hr_all_organization_units org
           ,hr_organization_information hoi
    WHERE  org.organization_id = NVL(p_legal_employer,org.organization_id)
    AND    org.business_group_id = l_business_group_id
    AND    p_org_structure_version_id IS NULL
    AND    org.organization_id = hoi.organization_id
    AND    hoi.org_information_context = 'CLASS'
    AND    hoi.org_information1 = 'HR_LEGAL_EMPLOYER';
    rec_get_org_id       csr_get_org_id%ROWTYPE;
    CURSOR csr_get_cont_emp IS
    SELECT people.employee_number
           ,people.full_name
           ,period.date_start
           ,job.name job_name
      	   ,cont.reference cont_reference
	   ,get_lookup_meaning('CONTRACT_TYPE',cont.type) cont_type
	   ,cont.ctr_information1 employment_status
	   ,fnd_date.canonical_to_date(cont.ctr_information2) expiry_date
    FROM   per_all_assignments_f      assg
           ,per_all_people_f          people
	   ,per_contracts             cont
           ,per_jobs                  job
           ,per_periods_of_service    period
           ,hr_all_organization_units org
           ,hr_soft_coding_keyflex    hsck
    WHERE assg.person_id = people.person_id
    AND   assg.contract_id = cont.contract_id
    AND   assg.assignment_type = 'E'
    AND   (l_date) BETWEEN assg.effective_start_date
                       AND   assg.effective_end_date
    AND   (l_date) between people.effective_start_date
                       AND   people.effective_end_date
    AND   assg.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
    AND   assg.job_id = job.job_id(+)
    AND   people.person_id = period.person_id
--    AND   assg.organization_id = org.organization_id
    AND   org.business_group_id = l_business_group_id
    AND   cont.person_id = people.person_id
    AND   cont.ctr_information_category = 'KW'
    AND   org.organization_id = rec_get_org_id.organization_id
    AND   hsck.segment1 = to_char(rec_get_org_id.organization_id)
    AND   NVL(to_date(ctr_information2,'YYYY/MM/DD HH24:MI:SS'),
    DECODE(duration_units,'D',(active_start_date+duration),
                          'W',(active_start_date+(duration*7)),
                          'M',(add_months(active_start_date,duration)),
                          'Y',(add_months(active_start_date,(duration*12)))))
    BETWEEN NVL(l_date,sysdate)
        AND DECODE(p_units,'D',(NVL(l_date,sysdate)+p_duration),
                           'W',(NVL(l_date,sysdate)+(p_duration*7)),
                           'M',(add_months(NVL(l_date,sysdate),p_duration)),
                           'Y',(add_months(NVL(l_date,sysdate),(p_duration*12))))
    ORDER BY  full_name, employee_number;
    rec_get_cont_emp      csr_get_cont_emp%ROWTYPE;
    l_org_name            VARCHAR2(80);
    l_structure_name      VARCHAR2(80);
    l_version             NUMBER;
    l_contract_type       VARCHAR2(80);
    l_employment_status   VARCHAR2(80);
    l_expiry_date         DATE;
    l_legal_employer      VARCHAR2(80);
    l_emp_found           NUMBER;
    l_duration            NUMBER;
    l_units               VARCHAR2(80);
    i                     NUMBER;
    j                     NUMBER;
    l_incident_date       DATE;
    l_consultation_date   DATE;
    l_pg_count            NUMBER;
  BEGIN
    l_pg_count := 1;
    IF p_date IS NOT NULL THEN
      BEGIN
        SELECT fnd_date.canonical_to_date(p_date)
        INTO   l_date
        FROM   DUAL;
      EXCEPTION
        WHEN OTHERS THEN
          l_date := TRUNC(sysdate);
      END;
    ELSE
      l_date := TRUNC(sysdate);
    END IF;
    INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES (userenv('SESSIONID'), l_date);
    fnd_file.put_line(fnd_file.log,'l_date: '|| l_date);
    l_parent_id := NULL;
    l_org_name := NULL;
    l_structure_name := NULL;
    l_version := NULL;
    l_legal_employer := NULL;
    l_emp_found := 0;
    i := 1;
    j := 0;
    gxmltable.DELETE;
    gCtr := 1;
    IF p_org_structure_version_id IS NOT NULL
        AND p_legal_employer IS NULL THEN
      BEGIN
        SELECT distinct pose.organization_id_parent
        INTO   l_parent_id
        FROM   per_org_structure_elements pose
        WHERE  pose.org_structure_version_id = p_org_structure_version_id
        AND    pose.organization_id_parent NOT IN (SELECT pose1.organization_id_child
                                                   FROM   per_org_structure_elements pose1
                                                   WHERE  pose1.org_structure_version_id
                                                          = p_org_structure_version_id);
      EXCEPTION
        WHEN OTHERS THEN
          l_parent_id := NULL;
      END;
    END IF;
    IF p_business_group_id IS NOT NULL THEN
      BEGIN
        SELECT name
        INTO   l_org_name
        FROM   hr_organization_units
        WHERE  organization_id = p_business_group_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    IF p_org_structure_id IS NOT NULL THEN
      BEGIN
        SELECT name
        INTO   l_structure_name
        FROM   per_organization_structures
        WHERE  organization_structure_id = p_org_structure_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    IF p_org_structure_version_id IS NOT NULL THEN
      BEGIN
        SELECT version_number
        INTO   l_version
        FROM   per_org_structure_versions
        WHERE  org_structure_version_id = p_org_structure_version_id;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    IF p_units IS NOT NULL THEN
      BEGIN
        SELECT meaning
        INTO   l_units
        FROM   hr_lookups
        WHERE  lookup_type = 'QUALIFYING_UNITS'
        AND    lookup_code = p_units;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    IF p_legal_employer IS NOT NULL THEN
      BEGIN
        SELECT name
        INTO   l_legal_employer
        FROM   hr_organization_units
        WHERE  organization_id = p_legal_employer;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    --Populate parameter labels and values
    gxmltable(gCtr).tagName := 'report_date_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','REPORT_DATE_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'page_number_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','PAGE_NO_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'report_date_value';
    gxmltable(gCtr).tagValue := fnd_date.date_to_displaydate(sysdate);
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'of_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','OF_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'one_value';
    gxmltable(gCtr).tagValue := 1;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'count_value';
    gxmltable(gCtr).tagValue := null;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'report_parameters_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','REPORT_PARAMETERS_LABEL_CTR');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_name_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','ORGANIZATION_NAME_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_name_value';
    gxmltable(gCtr).tagValue := l_org_name;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_hierarchy_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','ORGANIZATION_HIERARCHY_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_hierarchy_value';
    gxmltable(gCtr).tagValue := l_structure_name;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_version_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','ORGANIZATION_VERSION_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_version_value';
    gxmltable(gCtr).tagValue := l_version;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'duration_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','DURATION');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'duration_value';
    gxmltable(gCtr).tagValue := p_duration;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'duration_units_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','DURATION_UNITS');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'duration_units_value';
    gxmltable(gCtr).tagValue := l_units;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'legal_employer_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','LEGAL_EMPLOYER_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'legal_employer_value';
    gxmltable(gCtr).tagValue := l_legal_employer;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'effective_date_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','EFFECTIVE_DATE_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'effective_date_value';
    gxmltable(gCtr).tagValue := fnd_date.date_to_displaydate(l_date);
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := '0';
    gxmltable(gCtr).tagValue := ('-----------------------------------------------------');
    gctr := gctr + 1;
    OPEN csr_get_bg_id;
    LOOP
      FETCH csr_get_bg_id INTO rec_get_bg_id;
      EXIT WHEN csr_get_bg_id%NOTFOUND;
      l_business_group_id := rec_get_bg_id.business_group_id;
      fnd_file.put_line(fnd_file.log,'BG ID: '|| l_business_group_id);
    OPEN csr_get_org_id;
    LOOP
      FETCH csr_get_org_id INTO rec_get_org_id;
      fnd_file.put_line(fnd_file.log,'rec_get_org_id.organization_id: '|| rec_get_org_id.organization_id);
      EXIT WHEN csr_get_org_id%NOTFOUND;
      --fnd_file.put_line(fnd_file.log,'in org cursor: '||rec_get_org_id.name);
      fnd_file.put_line(fnd_file.log,'rec_get_org_id.organization_id: '|| rec_get_org_id.organization_id);
      l_emp_found := 0;
      i := 1;
      OPEN csr_get_cont_emp;
      LOOP
        FETCH csr_get_cont_emp INTO rec_get_cont_emp;
        EXIT WHEN csr_get_cont_emp%NOTFOUND;
        IF i = 19 THEN
          i := 1;
        END IF;
        IF l_emp_found = 0 OR i = 1 THEN
          l_pg_count := l_pg_count + 1;
          gxmltable(gCtr).tagName := 'report_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','REPORT_LABEL_CTR');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'report_date_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','REPORT_DATE_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'report_date_body_value';
          gxmltable(gCtr).tagValue := fnd_date.date_to_displaydate(sysdate);
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'page_number_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','PAGE_NO_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'of_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','OF_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'current_value';
          gxmltable(gCtr).tagValue := l_pg_count;
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'count_body_value';
          gxmltable(gCtr).tagValue := null;
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'organization_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','ORGANIZATION_LABEL');
          gctr := gctr + 1;
     	  gxmltable(gCtr).tagName := 'organization_value';
          gxmltable(gCtr).tagValue := rec_get_org_id.name;
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'employee_number_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','EMPLOYEE_NUMBER_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'full_name_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','FULL_NAME_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'appointment_date_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','START_DATE_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'job_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','JOB_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'contract_reference_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','CONTRACT_REFERENCE');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'contract_type_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','CONTRACT_TYPE');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'employment_status_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','EMPLOYMENT_STATUS');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'expiry_date_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('KW_FORM_LABELS','EXPIRY_DATE');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '1';
          gxmltable(gCtr).tagValue := ('------------------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '2';
          gxmltable(gCtr).tagValue := ('------------------------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '3';
          gxmltable(gCtr).tagValue := ('--------------------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '4';
          gxmltable(gCtr).tagValue := ('------------------------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '5';
          gxmltable(gCtr).tagValue := ('-------------------------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '6';
          gxmltable(gCtr).tagValue := ('--------------------------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '7';
          gxmltable(gCtr).tagValue := ('---------------------');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := '8';
          gxmltable(gCtr).tagValue := ('----------------------');
          gctr := gctr + 1;
          l_emp_found := 1;
        END IF;
	gxmltable(gCtr).tagName := 'employee_number_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_cont_emp.employee_number);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'full_name_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_cont_emp.full_name);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'appointment_date_value'||' '||i;
        gxmltable(gCtr).tagValue := fnd_date.date_to_displaydate(rec_get_cont_emp.date_start);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'job_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_cont_emp.job_name);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'reference_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_cont_emp.cont_reference);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'contract_type_body_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_cont_emp.cont_type);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'employment_status_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_cont_emp.employment_status);
        gctr := gctr + 1;
	gxmltable(gCtr).tagName := 'expiry_date_value'||' '||i;
        gxmltable(gCtr).tagValue := fnd_date.date_to_displaydate(rec_get_cont_emp.expiry_date);
        gctr := gctr + 1;
        i := i + 1;
      END LOOP;
      CLOSE csr_get_cont_emp;
      IF i < 18 AND l_emp_found = 1 THEN
        FOR j in i..18 LOOP
        gxmltable(gCtr).tagName := 'employee_number_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'full_name_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'appointment_date_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'job_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'contract_reference_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'contract_type_body_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'employment_status_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'expiry_date_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        END LOOP;
      END IF;
    END LOOP;
    CLOSE csr_get_org_id;
    END LOOP;
    CLOSE csr_get_bg_id;
    WritetoCLOB ( l_xfdf_blob, l_pg_count );
  END get_contract_data;
 --------------------------------------------------------------------------------------------------------
  PROCEDURE Writetoclob
    (p_xfdf_blob out nocopy blob
    ,p_tot_pg_count IN NUMBER) IS
    l_xfdf_string clob;
    l_str1 varchar2(1000);
    l_str2 varchar2(20);
    l_str3 varchar2(20);
    l_str4 varchar2(20);
    l_str5 varchar2(20);
    l_str6 varchar2(30);
    l_str7 varchar2(1000);
    l_str8 varchar2(240);
    l_str9 varchar2(240);
  BEGIN
    hr_utility.set_location('Entered Procedure Write to clob ',100);
    l_str1 := '<?xml version="1.0" encoding="UTF-8"?>
	       <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
               <fields> ' ;
    l_str2 := '<field name="';
    l_str3 := '">';
    l_str4 := '<value>' ;
    l_str5 := '</value> </field>' ;
    l_str6 := '</fields> </xfdf>';
    l_str7 := '<?xml version="1.0" encoding="UTF-8"?>
               <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
               <fields>
               </fields> </xfdf>';
    dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
    if gxmltable.count > 0 then
      dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );
      FOR ctr_table IN gxmltable.FIRST .. gxmltable.LAST LOOP
        l_str8 := gxmltable(ctr_table).tagName;
        l_str9 := gxmltable(ctr_table).tagValue;
        IF gxmltable(ctr_table).tagName IN ('count_body_value', 'count_value') THEN
         l_str9 := p_tot_pg_count;
        END IF;
        IF (l_str9 is not null) THEN
          dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2 );
          dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
          dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );
          dbms_lob.writeAppend( l_xfdf_string, length(l_str4), l_str4 );
          dbms_lob.writeAppend( l_xfdf_string, length(l_str9), l_str9);
          dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5 );
        ELSIF (l_str9 IS NULL AND l_str8 IS NOT NULL) THEN
          dbms_lob.writeAppend(l_xfdf_string,length(l_str2),l_str2);
          dbms_lob.writeAppend(l_xfdf_string,length(l_str8),l_str8);
          dbms_lob.writeAppend(l_xfdf_string,length(l_str3),l_str3);
          dbms_lob.writeAppend(l_xfdf_string,length(l_str4),l_str4);
          dbms_lob.writeAppend(l_xfdf_string,length(l_str5),l_str5);
        ELSE
          NULL;
        END IF;
      END LOOP;
      dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6 );
    ELSE
      dbms_lob.writeAppend( l_xfdf_string, length(l_str7), l_str7 );
    END IF;
    DBMS_LOB.CREATETEMPORARY(p_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,p_xfdf_blob);
    hr_utility.set_location('Finished Procedure Write to CLOB ,Before clob to blob ',110);
  EXCEPTION
    WHEN OTHERS then
      HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
      HR_UTILITY.RAISE_ERROR;
  END Writetoclob;
----------------------------------------------------------------
  Procedure  clob_to_blob(p_clob clob,
                          p_blob IN OUT NOCOPY Blob)
  is
    l_length_clob number;
    l_offset pls_integer;
    l_varchar_buffer varchar2(32767);
    l_raw_buffer raw(32767);
    l_buffer_len number:= 20000;
    l_chunk_len number;
    l_blob blob;
    g_nls_db_char varchar2(60);

    l_raw_buffer_len pls_integer;
    l_blob_offset    pls_integer := 1;

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
        	--l_raw_buffer := utl_raw.cast_to_raw(l_varchar_buffer);
                l_raw_buffer := utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',g_nls_db_char);
                l_raw_buffer_len := utl_raw.length(utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',g_nls_db_char));
        	hr_utility.trace('l_varchar_buffer '|| l_varchar_buffer);
                --dbms_lob.write(p_blob,l_chunk_len, l_offset, l_raw_buffer);
                dbms_lob.write(p_blob,l_raw_buffer_len, l_blob_offset, l_raw_buffer);
            	l_blob_offset := l_blob_offset + l_raw_buffer_len;

            	l_offset := l_offset + l_chunk_len;
	        l_length_clob := l_length_clob - l_chunk_len;
                hr_utility.trace('l_length_blob '|| dbms_lob.getlength(p_blob));
	end loop;
	hr_utility.set_location('Finished Procedure clob to blob ',130);
  end;

------------------------------------------------------------------
  PROCEDURE fetch_pdf_blob
    (p_report IN VARCHAR2
    ,P_date   IN VARCHAR2
    ,p_pdf_blob OUT NOCOPY blob) IS
  BEGIN
    IF (p_report='Disability') THEN
      SELECT file_data
      INTO   p_pdf_blob
      FROM   fnd_lobs
      WHERE  file_id = (SELECT MAX(file_id)
                       FROM    fnd_lobs
                       WHERE   file_name like '%PER_DIS_ar_KW.pdf');
    ELSE
      SELECT file_data
      INTO   p_pdf_blob
      FROM   fnd_lobs
      WHERE  file_id = (SELECT MAX(file_id)
                       FROM    fnd_lobs
                       WHERE   file_name like '%PER_CTR_ar_KW.pdf');
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END fetch_pdf_blob;
-----------------------------------------------------------------
  FUNCTION get_lookup_meaning
    (p_lookup_type varchar2
    ,p_lookup_code varchar2)
    RETURN VARCHAR2 IS
    CURSOR csr_lookup IS
    select meaning
    from   hr_lookups
    where  lookup_type = p_lookup_type
    and    lookup_code = p_lookup_code;
    l_meaning hr_lookups.meaning%type;
  BEGIN
    OPEN csr_lookup;
    FETCH csr_lookup INTO l_Meaning;
    CLOSE csr_lookup;
    RETURN l_meaning;
  END get_lookup_meaning;
END per_kw_xdo_report;

/
