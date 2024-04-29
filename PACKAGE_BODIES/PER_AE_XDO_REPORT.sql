--------------------------------------------------------
--  DDL for Package Body PER_AE_XDO_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_AE_XDO_REPORT" AS
/* $Header: peaexdor.pkb 120.9.12010000.5 2008/08/06 08:53:56 ubhat ship $ */
  PROCEDURE get_visa_data
    (p_request_id                 IN  NUMBER
     ,p_report_name               IN  VARCHAR2
     ,p_date                      IN  VARCHAR2 DEFAULT NULL
     ,p_business_group_id         IN  NUMBER DEFAULT NULL
     ,p_org_structure_id          IN  NUMBER DEFAULT NULL
     ,p_org_structure_version_id  IN  NUMBER DEFAULT NULL
     ,p_expires_in                IN  NUMBER
     ,p_units                     IN  VARCHAR2
     ,l_xfdf_blob                 OUT NOCOPY BLOB) AS
    l_parent_id           NUMBER;
    l_date                DATE;
    l_business_group_id   NUMBER;
    l_organization_id     NUMBER;
    CURSOR csr_get_bg_id IS
    SELECT business_group_id
    FROM   per_business_groups
    WHERE  business_group_id = nvl(p_business_group_id, business_group_id)
    AND    legislation_code = 'AE';
    rec_get_bg_id  csr_get_bg_id%ROWTYPE;
    CURSOR csr_get_org_id(c_business_group_id number) IS
    SELECT org.organization_id
           ,org.name
    FROM   hr_all_organization_units org
    WHERE  org.organization_id IN (SELECT pose.organization_id_child
                                   FROM   per_org_structure_elements pose
                                   CONNECT BY pose.organization_id_parent = PRIOR pose.organization_id_child
                                   AND    pose.org_structure_version_id = p_org_structure_version_id
                                   START WITH pose.organization_id_parent = nvl(c_business_group_id, l_parent_id)
                                   AND    pose.org_structure_version_id = p_org_structure_version_id
                                   UNION
                                   SELECT nvl(p_business_group_id, l_parent_id)
                                   FROM   DUAL)
    AND    p_org_structure_version_id IS NOT NULL
    UNION
    SELECT org.organization_id
           ,org.name
    FROM   hr_all_organization_units org
    WHERE  org.organization_id = NVL(c_business_group_id,org.organization_id)
    AND    org.business_group_id = c_business_group_id
    AND    p_org_structure_version_id IS NULL;
    rec_get_org_id       csr_get_org_id%ROWTYPE;
CURSOR csr_get_visa_det(c_business_group_id number, c_organization_id number) IS
SELECT org.name
      ,people.employee_number
      ,people.full_name
      ,dei.dei_information1 visa_number
      ,dei.dei_information9 place_of_issue
      ,dei.date_to expiry_date
      ,assg.assignment_id assignment_id
FROM   per_all_assignments_f assg
      ,per_all_people_f     people
      ,hr_document_extra_info dei
      ,hr_document_types_tl hdtl
      ,hr_all_organization_units org
WHERE assg.person_id = people.person_id
AND     (l_date) BETWEEN assg.effective_start_date
		 AND   assg.effective_end_date
AND     (l_date) BETWEEN people.effective_start_date
		 AND   people.effective_end_date
AND    dei.person_id = people.person_id
AND    dei.document_type_id = hdtl.document_type_id
AND    hdtl.document_type = 'AE_VISA'
AND    hdtl.language = 'US'
AND    dei.dei_information_category = hdtl.document_type
AND    assg.organization_id = org.organization_id
AND    org.organization_id = c_organization_id
AND    org.business_group_id = c_business_group_id
--AND    org.organization_id = p_business_group_id
AND    dei.date_to
BETWEEN NVL(l_date,sysdate) AND
DECODE(p_units,'D',(NVL(l_date,sysdate)+p_expires_in),
               'W',(NVL(l_date,sysdate)+(p_expires_in*7)),
               'M',(add_months(NVL(l_date,sysdate),p_expires_in)),
	       'Y',(add_months(NVL(l_date,sysdate),(p_expires_in*12))))
ORDER BY org.name, expiry_date, full_name;
CURSOR csr_get_job(p_assignment_id NUMBER) IS
SELECT pjb.name
FROM   per_all_assignments_f paa,
       per_jobs pjb
WHERE  paa.assignment_id = p_assignment_id
AND    paa.job_id = pjb.job_id;
    rec_get_visa_det csr_get_visa_det%ROWTYPE;
    l_org_name            VARCHAR2(80);
    l_structure_name      VARCHAR2(80);
    l_job                 VARCHAR2(80);
    l_version             NUMBER;
    l_emp_found           NUMBER;
    i                     NUMBER;
    j                     NUMBER;
    l_pg_count            NUMBER;
    l_units               VARCHAR2(80);
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
    l_emp_found := 0;
    i := 1;
    j := 0;
    gxmltable.DELETE;
    gCtr := 1;
    IF p_org_structure_version_id IS NOT NULL
        AND 1 IS NULL THEN
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
    --Populate parameter labels and values
    gxmltable(gCtr).tagName := 'report_date_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','REPORT_DATE_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'page_number_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','PAGE_NO_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'report_date_value';
    gxmltable(gCtr).tagValue := fnd_date.date_to_displaydate(sysdate);
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'of_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','OF_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'one_value';
    gxmltable(gCtr).tagValue := 1;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'count_value';
    gxmltable(gCtr).tagValue := null;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'report_parameters_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','REPORT_PARAMETERS_LABEL_VISA');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_name_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','ORGANIZATION_NAME_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_name_value';
    gxmltable(gCtr).tagValue := l_org_name;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_hierarchy_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','ORGANIZATION_HIERARCHY_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_hierarchy_value';
    gxmltable(gCtr).tagValue := l_structure_name;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_version_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','ORGANIZATION_VERSION_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_version_value';
    gxmltable(gCtr).tagValue := l_version;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'duration_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','DURATION_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'duration_value';
    gxmltable(gCtr).tagValue := p_expires_in;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'duration_units_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','DURATION_UNITS_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'duration_units_value';
    gxmltable(gCtr).tagValue := l_units;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'effective_date_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','EFFECTIVE_DATE_LABEL');
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
    OPEN csr_get_org_id(l_business_group_id);
    LOOP
      FETCH csr_get_org_id INTO rec_get_org_id;
      EXIT WHEN csr_get_org_id%NOTFOUND;
      l_organization_id:= rec_get_org_id.organization_id;
      l_emp_found := 0;
      i := 1;
      OPEN csr_get_visa_det(l_business_group_id, l_organization_id);
      LOOP
        FETCH csr_get_visa_det INTO rec_get_visa_det;
        EXIT WHEN csr_get_visa_det%NOTFOUND;
        IF i = 19 THEN
          i := 1;
        END IF;
        IF l_emp_found = 0 OR i = 1 THEN
          l_pg_count := l_pg_count + 1;
          gxmltable(gCtr).tagName := 'report_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','REPORT_LABEL_VISA');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'report_date_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','REPORT_DATE_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'report_date_body_value';
          gxmltable(gCtr).tagValue := fnd_date.date_to_displaydate(sysdate);
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'page_number_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','PAGE_NO_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'of_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','OF_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'current_value';
          gxmltable(gCtr).tagValue := l_pg_count;
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'count_body_value';
          gxmltable(gCtr).tagValue := null;
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'organization_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','ORGANIZATION_LABEL');
          gctr := gctr + 1;
	  gxmltable(gCtr).tagName := 'organization_value';
          gxmltable(gCtr).tagValue := rec_get_org_id.name;
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'employee_number_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','EMPLOYEE_NUMBER_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'full_name_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','FULL_NAME_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'job_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','JOB_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'visa_number_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','VISA_NUMBER_BODY_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'visa_place_of_issue_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','PLACE_OF_ISSUE_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'expiry_date_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','EXPIRY_DATE');
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
          gxmltable(gCtr).tagValue := ('---------------------');
          gctr := gctr + 1;
          l_emp_found := 1;
        END IF;
	OPEN csr_get_job(rec_get_visa_det.assignment_id);
		FETCH csr_get_job INTO l_job;
	CLOSE csr_get_job;
	gxmltable(gCtr).tagName := 'employee_number_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_visa_det.employee_number);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'full_name_value'||' '||i;
        gxmltable(gCtr).tagValue := (SUBSTR(rec_get_visa_det.full_name,1,80));
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'job_value'||' '||i;
        gxmltable(gCtr).tagValue := (l_job);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'visa_number_body_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_visa_det.visa_number);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'visa_place_of_issue_body_value'||' '||i;
        gxmltable(gCtr).tagValue := (get_lookup_meaning('AE_EMIRATE',rec_get_visa_det.place_of_issue));
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'expiry_date_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_visa_det.expiry_date);
        gctr := gctr + 1;
        i := i + 1;
      END LOOP;
      CLOSE csr_get_visa_det;
      IF i < 18 AND l_emp_found = 1 THEN
        FOR j in i..18 LOOP
        gxmltable(gCtr).tagName := 'employee_number_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'full_name_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'job_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'visa_number_body_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'visa_place_of_issue_body_value'||' '||j;
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
  END get_visa_data;
 --------------------------------------------------------------------------------------------------------
PROCEDURE get_passport_data
    (p_request_id                 IN  NUMBER
     ,p_report_name               IN  VARCHAR2
     ,p_date                      IN  VARCHAR2 DEFAULT NULL
     ,p_business_group_id         IN  NUMBER DEFAULT NULL
     ,p_org_structure_id          IN  NUMBER DEFAULT NULL
     ,p_org_structure_version_id  IN  NUMBER DEFAULT NULL
     ,p_expires_in                IN  NUMBER
     ,p_units                     IN  VARCHAR2
     ,l_xfdf_blob                 OUT NOCOPY BLOB) AS
    l_parent_id           NUMBER;
    l_date                DATE;
    l_business_group_id   NUMBER;
    l_organization_id     NUMBER;
    CURSOR csr_get_bg_id IS
    SELECT business_group_id
    FROM   per_business_groups
    WHERE  business_group_id = nvl(p_business_group_id, business_group_id)
    AND    legislation_code = 'AE';
    rec_get_bg_id  csr_get_bg_id%ROWTYPE;
    CURSOR csr_get_org_id(c_business_group_id number) IS
    SELECT org.organization_id
           ,org.name
    FROM   hr_all_organization_units org
    WHERE  org.organization_id IN (SELECT pose.organization_id_child
                                   FROM   per_org_structure_elements pose
                                   CONNECT BY pose.organization_id_parent = PRIOR pose.organization_id_child
                                   AND    pose.org_structure_version_id = p_org_structure_version_id
                                   START WITH pose.organization_id_parent = nvl(c_business_group_id, l_parent_id)
                                   AND    pose.org_structure_version_id = p_org_structure_version_id
                                   UNION
                                   SELECT nvl(c_business_group_id, l_parent_id)
                                   FROM   DUAL)
    AND    p_org_structure_version_id IS NOT NULL
    UNION
    SELECT org.organization_id
           ,org.name
    FROM   hr_all_organization_units org
    WHERE  org.organization_id = NVL(c_business_group_id,org.organization_id)
    AND    org.business_group_id = c_business_group_id
    AND    p_org_structure_version_id IS NULL;
    rec_get_org_id       csr_get_org_id%ROWTYPE;
CURSOR csr_get_pass_det(c_business_group_id number, c_organization_id number) IS
SELECT org.name
      ,people.employee_number
      ,people.full_name
      ,dei.dei_information1 passport_number
      ,dei.issued_at place_of_issue
      ,dei.date_to expiry_date
      ,assg.assignment_id assignment_id
FROM   per_all_assignments_f assg
      ,per_all_people_f people
      ,hr_document_extra_info dei
      ,hr_document_types_tl hdtl
      ,hr_all_organization_units   org
WHERE assg.person_id = people.person_id
AND     (l_date) BETWEEN assg.effective_start_date
		 AND   assg.effective_end_date
AND     (l_date) BETWEEN people.effective_start_date
		 AND   people.effective_end_date
AND    dei.person_id = people.person_id
AND    dei.document_type_id = hdtl.document_type_id
AND    hdtl.document_type = 'AE_PASSPORT'
AND    hdtl.language = 'US'
AND    dei.dei_information_category = hdtl.document_type
AND    assg.organization_id = org.organization_id
AND    org.organization_id = c_organization_id
AND    org.business_group_id = c_business_group_id
--AND    org.organization_id = p_business_group_id
AND    dei.date_to
BETWEEN NVL(l_date,sysdate) AND
DECODE(p_units,'D',(NVL(l_date,sysdate)+p_expires_in),
               'W',(NVL(l_date,sysdate)+(p_expires_in*7)),
               'M',(add_months(NVL(l_date,sysdate),p_expires_in)),
	       'Y',(add_months(NVL(l_date,sysdate),(p_expires_in*12))))
ORDER BY org.name, expiry_date, full_name;
CURSOR csr_get_job(p_assignment_id NUMBER) IS
SELECT pjb.name
FROM   per_all_assignments_f paa,
       per_jobs pjb
WHERE  paa.assignment_id = p_assignment_id
AND    paa.job_id = pjb.job_id;
    rec_get_pass_det csr_get_pass_det%ROWTYPE;
    l_org_name            VARCHAR2(80);
    l_structure_name      VARCHAR2(80);
    l_job                 VARCHAR2(80);
    l_version             NUMBER;
    l_emp_found           NUMBER;
    i                     NUMBER;
    j                     NUMBER;
    l_pg_count            NUMBER;
    l_units               VARCHAR2(80);
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
    l_emp_found := 0;
    i := 1;
    j := 0;
    gxmltable.DELETE;
    gCtr := 1;
    IF p_org_structure_version_id IS NOT NULL
        AND 1 IS NULL THEN
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
    --Populate parameter labels and values
    gxmltable(gCtr).tagName := 'report_date_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','REPORT_DATE_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'page_number_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','PAGE_NO_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'report_date_value';
    gxmltable(gCtr).tagValue := fnd_date.date_to_displaydate(sysdate);
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'of_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','OF_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'one_value';
    gxmltable(gCtr).tagValue := 1;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'count_value';
    gxmltable(gCtr).tagValue := null;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'report_parameters_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','REPORT_PARAMETERS_LABEL_PASS');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_name_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','ORGANIZATION_NAME_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_name_value';
    gxmltable(gCtr).tagValue := l_org_name;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_hierarchy_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','ORGANIZATION_HIERARCHY_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_hierarchy_value';
    gxmltable(gCtr).tagValue := l_structure_name;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_version_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','ORGANIZATION_VERSION_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'organization_version_value';
    gxmltable(gCtr).tagValue := l_version;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'duration_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','DURATION_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'duration_value';
    gxmltable(gCtr).tagValue := p_expires_in;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'duration_units_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','DURATION_UNITS_LABEL');
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'duration_units_value';
    gxmltable(gCtr).tagValue := l_units;
    gctr := gctr + 1;
    gxmltable(gCtr).tagName := 'effective_date_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','EFFECTIVE_DATE_LABEL');
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
    OPEN csr_get_org_id(l_business_group_id);
    LOOP
      FETCH csr_get_org_id INTO rec_get_org_id;
      EXIT WHEN csr_get_org_id%NOTFOUND;
     l_organization_id := rec_get_org_id.organization_id;
      l_emp_found := 0;
      i := 1;
      OPEN csr_get_pass_det(l_business_group_id, l_organization_id);
      LOOP
        FETCH csr_get_pass_det INTO rec_get_pass_det;
        EXIT WHEN csr_get_pass_det%NOTFOUND;
        IF i = 19 THEN
          i := 1;
        END IF;
        IF l_emp_found = 0 OR i = 1 THEN
          l_pg_count := l_pg_count + 1;
          gxmltable(gCtr).tagName := 'report_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','REPORT_LABEL_PASS');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'report_date_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','REPORT_DATE_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'report_date_body_value';
          gxmltable(gCtr).tagValue := fnd_date.date_to_displaydate(sysdate);
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'page_number_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','PAGE_NO_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'of_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','OF_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'current_value';
          gxmltable(gCtr).tagValue := l_pg_count;
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'count_body_value';
          gxmltable(gCtr).tagValue := null;
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'organization_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','ORGANIZATION_LABEL');
          gctr := gctr + 1;
	  gxmltable(gCtr).tagName := 'organization_value';
          gxmltable(gCtr).tagValue := rec_get_org_id.name;
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'employee_number_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','EMPLOYEE_NUMBER_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'full_name_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','FULL_NAME_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'job_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','JOB_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'passport_number_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','PASSPORT_NUMBER_BODY_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'passport_place_of_issue_body_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','PLACE_OF_ISSUE_LABEL');
          gctr := gctr + 1;
          gxmltable(gCtr).tagName := 'expiry_date_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','EXPIRY_DATE');
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
          gxmltable(gCtr).tagValue := ('---------------------');
          gctr := gctr + 1;
          l_emp_found := 1;
        END IF;
	OPEN csr_get_job(rec_get_pass_det.assignment_id);
		FETCH csr_get_job INTO l_job;
	CLOSE csr_get_job;
	gxmltable(gCtr).tagName := 'employee_number_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_pass_det.employee_number);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'full_name_value'||' '||i;
        gxmltable(gCtr).tagValue := (SUBSTR(rec_get_pass_det.full_name,1,80));
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'job_value'||' '||i;
        gxmltable(gCtr).tagValue := (l_job);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'passport_number_body_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_pass_det.passport_number);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'passport_place_of_issue_body_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_pass_det.place_of_issue);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'expiry_date_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_pass_det.expiry_date);
        gctr := gctr + 1;
        i := i + 1;
      END LOOP;
      CLOSE csr_get_pass_det;
      IF i < 18 AND l_emp_found = 1 THEN
        FOR j in i..18 LOOP
        gxmltable(gCtr).tagName := 'employee_number_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'full_name_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'job_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'passport_number_body_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
        gxmltable(gCtr).tagName := 'passport_place_of_issue_body_value'||' '||j;
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
  END get_passport_data;
--------------------------------------------------------------------------------------------------
 PROCEDURE get_contract_data
    (p_request_id                 IN  NUMBER
     ,p_report_name               IN  VARCHAR2
     ,p_date                      IN  VARCHAR2 DEFAULT NULL
     ,p_business_group_id         IN  NUMBER DEFAULT NULL
     ,p_org_structure_id          IN  NUMBER DEFAULT NULL
     ,p_org_structure_version_id  IN  NUMBER DEFAULT NULL
     ,p_org_id			  IN  NUMBER DEFAULT NULL
     ,p_expires_in                IN  NUMBER
     ,p_units                     IN  VARCHAR2
     ,l_xfdf_blob                 OUT NOCOPY BLOB) AS
    l_parent_id           NUMBER;
    l_date                DATE;
    l_business_group_id   NUMBER;
    l_xfdf_string CLOB;
l_rep_param_name varchar2(100);
l_rep_label varchar2(100);
l_rep_date_label varchar2(100);
l_rep_date varchar2(100);
l_rep_page varchar2(100);
l_one_value varchar2(100);
l_count_value varchar2(100);
l_page_num varchar2(100);
l_of_label varchar2(100);
l_str_9 varchar2(100);
l_str_8 varchar2(100);
l_str_7 varchar2(100);
l_str_6 varchar2(100);
l_str_5 varchar2(100);
l_str_4 varchar2(100);
l_str_3 varchar2(100);
l_str_2 varchar2(100);
l_str_1 varchar2(100);
l_str_0 varchar2(100);
l_str_0a varchar2(100);
l_str_0b varchar2(100);
l_str_9b varchar2(100);
l_str_8b varchar2(100);
l_str_7b varchar2(100);
l_str_6b varchar2(100);
l_str_5b varchar2(100);
l_str_4b varchar2(100);
l_str_3b varchar2(100);
l_str_2b varchar2(100);
l_str_1b varchar2(100);
l_str_0bb varchar2(100);
l_eno varchar2(100);
l_fname varchar2(100);
l_ref varchar2(100);
l_type varchar2(100);
l_status varchar2(100);
l_appdate varchar2(100);
l_edate varchar2(100);
l_b_eno varchar2(100);
l_b_fname varchar2(100);
l_b_job varchar2(100);
l_b_ref varchar2(100);
l_b_type varchar2(100);
l_b_status varchar2(100);
l_b_appdate varchar2(100);
l_b_edate varchar2(100);
    CURSOR csr_get_bg_id IS
    SELECT business_group_id
    FROM   per_business_groups
    WHERE  business_group_id = nvl(p_business_group_id, business_group_id)
    AND    legislation_code = 'AE';
    rec_get_bg_id  csr_get_bg_id%ROWTYPE;
    CURSOR csr_get_org_id IS
    SELECT org.organization_id
           ,org.name
    FROM   hr_all_organization_units org
    WHERE  org.organization_id IN (SELECT pose.organization_id_child
                                   FROM   per_org_structure_elements pose
                                   CONNECT BY pose.organization_id_parent = PRIOR pose.organization_id_child
                                   AND    pose.org_structure_version_id = p_org_structure_version_id
                                   START WITH pose.organization_id_parent = nvl(p_org_id, l_parent_id)
                                   AND    pose.org_structure_version_id = p_org_structure_version_id
                                   UNION
                                   SELECT nvl(p_org_id, l_parent_id)
                                   FROM   DUAL)
    AND    p_org_structure_version_id IS NOT NULL
    UNION
    SELECT org.organization_id
           ,org.name
    FROM   hr_all_organization_units org
    WHERE  org.organization_id = NVL(p_org_id,org.organization_id)
    AND    org.business_group_id = p_business_group_id
    AND    p_org_structure_version_id IS NULL;
    rec_get_org_id       csr_get_org_id%ROWTYPE;
CURSOR csr_get_contract_det IS
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
WHERE assg.person_id = people.person_id
AND     (l_date) BETWEEN assg.effective_start_date
		 AND   assg.effective_end_date
AND     (l_date) BETWEEN people.effective_start_date
		 AND   people.effective_end_date
AND   assg.job_id = job.job_id(+)
AND   people.person_id = period.person_id
AND   assg.organization_id = org.organization_id
AND   org.business_group_id = p_business_group_id
AND   org.organization_id = rec_get_org_id.organization_id
AND   cont.person_id = people.person_id
AND   cont.ctr_information_category = 'AE'
AND   NVL(to_date(ctr_information2,'YYYY/MM/DD HH24:MI:SS'),
      DECODE(duration_units,'D',(active_start_date+duration),
                          'W',(active_start_date+(duration*7)),
                          'M',(add_months(active_start_date,duration)),
                          'Y',(add_months(active_start_date,(duration*12)))))
      BETWEEN NVL(l_date,sysdate)
      AND DECODE(p_units,'D',(NVL(l_date,sysdate)+p_expires_in),
                           'W',(NVL(l_date,sysdate)+(p_expires_in*7)),
                           'M',(add_months(NVL(l_date,sysdate),p_expires_in)),
                           'Y',(add_months(NVL(l_date,sysdate),(p_expires_in*12))))
ORDER BY  full_name, employee_number;
    rec_get_contract_det csr_get_contract_det%ROWTYPE;
    l_org_name            VARCHAR2(80);
    l_structure_name      VARCHAR2(80);
    l_job                 VARCHAR2(80);
    l_version             NUMBER;
    l_emp_found           NUMBER;
    i                     NUMBER;
    j                     NUMBER;
    l_pg_count            NUMBER;
    l_units               VARCHAR2(80);
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
    l_emp_found := 0;
    i := 1;
    j := 0;
    gxmltable.DELETE;
    gCtr := 1;
    IF p_org_structure_version_id IS NOT NULL
        /*AND 1 IS NULL*/ THEN
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
    IF /*p_business_group_id*/ p_org_id  IS NOT NULL THEN
      BEGIN
        SELECT name
        INTO   l_org_name
        FROM   hr_organization_units
        WHERE  organization_id =/* p_business_group_id*/ p_org_id ;
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
    dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
    DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,l_xfdf_blob);
    --Populate parameter labels and values
   /********** COMMENTED ON 3-NOV-05 FOR RTF FORMAT
   gxmltable(gCtr).tagName := 'report_date_label';
    gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','REPORT_DATE_LABEL');
    gctr := gctr + 1;
		etc. etc.
    END OF COMMENTED ON 3-NOV-05 FOR RTF FORMAT******************************/
      dbms_lob.writeAppend( l_xfdf_string, length('<START>'),'<START>');
	    l_rep_date_label := '<REPORT-DATE-LABEL>' ||get_lookup_meaning('AE_FORM_LABELS','REPORT_DATE_LABEL')||'</REPORT-DATE-LABEL>';
	    l_rep_date := '<REPORT-DATE-VALUE>' ||fnd_date.date_to_displaydate(sysdate)||'</REPORT-DATE-VALUE>';
	    l_rep_page := '<PAGE>'||get_lookup_meaning('AE_FORM_LABELS','PAGE_NO_LABEL')||'</PAGE>';
	    l_one_value := '<ONE-VALUE>' || '1' || '</ONE-VALUE>';
      	    l_rep_param_name := '<REPORT-PARAM-LABEL>'||get_lookup_meaning('AE_FORM_LABELS','REPORT_PARAMETERS_LABEL_CTR')||'</REPORT-PARAM-LABEL>';
            l_str_9 := '<ORG-NAME-HEADER>'||get_lookup_meaning('AE_FORM_LABELS','ORGANIZATION_NAME_LABEL')||'</ORG-NAME-HEADER>';
            --l_str_8 := '<ORG-NAME-HEADER-VALUE>'||l_org_name||'</ORG-NAME-HEADER-VALUE>';
	    l_str_8 := '<ORG-NAME-HEADER-VALUE>'||'<![CDATA['||l_org_name||']]>'||'</ORG-NAME-HEADER-VALUE>';
	    l_str_7 := '<ORG-HIERARCHY-LABEL>'||get_lookup_meaning('AE_FORM_LABELS','ORGANIZATION_HIERARCHY_LABEL')||'</ORG-HIERARCHY-LABEL>';
           -- l_str_6 := '<ORG-HIERARCHY-VALUE>'||l_structure_name||'</ORG-HIERARCHY-VALUE>';
	    l_str_6 := '<ORG-HIERARCHY-VALUE>'||'<![CDATA['||l_structure_name||']]>'||'</ORG-HIERARCHY-VALUE>';
            l_str_5 := '<ORG-VERSION-LABEL>'||get_lookup_meaning('AE_FORM_LABELS','ORGANIZATION_VERSION_LABEL')||'</ORG-VERSION-LABEL>';
            l_str_4 := '<ORG-VERSION-VALUE>'||l_version||'</ORG-VERSION-VALUE>';
            l_str_3 := '<DURATION-HEADER-LABEL>'||get_lookup_meaning('AE_FORM_LABELS','DURATION_LABEL')||'</DURATION-HEADER-LABEL>';
            l_str_2 := '<DURATION-HEADER-VALUE>'||p_expires_in||'</DURATION-HEADER-VALUE>';
            l_str_1 := '<DURATION-UNITS-LABEL>'||get_lookup_meaning('AE_FORM_LABELS','DURATION_UNITS_LABEL')||'</DURATION-UNITS-LABEL>';
            l_str_0 := '<DURATION-UNITS-VALUE>'||l_units||'</DURATION-UNITS-VALUE>';
            l_str_0a := '<EFFECTIVE-DATE-LABEL>'||get_lookup_meaning('AE_FORM_LABELS','EFFECTIVE_DATE_LABEL')||'</EFFECTIVE-DATE-LABEL>';
            l_str_0bb := '<EFFECTIVE-DATE-VALUE>'||fnd_date.date_to_displaydate(l_date)||'</EFFECTIVE-DATE-VALUE>';
            dbms_lob.writeAppend( l_xfdf_string, length(l_rep_date_label), l_rep_date_label);
	    dbms_lob.writeAppend( l_xfdf_string, length(l_rep_date), l_rep_date);
	    dbms_lob.writeAppend( l_xfdf_string, length(l_rep_page), l_rep_page);
	    dbms_lob.writeAppend( l_xfdf_string, length(l_one_value), l_one_value);
	    dbms_lob.writeAppend( l_xfdf_string, length(l_rep_param_name), l_rep_param_name);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_9), l_str_9);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_8), l_str_8);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_7), l_str_7);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_6), l_str_6);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_5), l_str_5);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_4), l_str_4);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_3), l_str_3);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_2), l_str_2);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_1), l_str_1);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_0), l_str_0);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_0a), l_str_0a);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_0bb), l_str_0bb);
    OPEN csr_get_bg_id;
    LOOP
      FETCH csr_get_bg_id INTO rec_get_bg_id;
      EXIT WHEN csr_get_bg_id%NOTFOUND;
      l_business_group_id := rec_get_bg_id.business_group_id;
    OPEN csr_get_org_id;
    LOOP
      FETCH csr_get_org_id INTO rec_get_org_id;
      EXIT WHEN csr_get_org_id%NOTFOUND;
      l_emp_found := 0;
      i := 1;
      OPEN csr_get_contract_det;
      LOOP
        FETCH csr_get_contract_det INTO rec_get_contract_det;
        EXIT WHEN csr_get_contract_det%NOTFOUND;
        IF i = 10 THEN
          i := 1;
        END IF;
        IF l_emp_found = 0 OR i = 1 THEN
        	dbms_lob.writeAppend( l_xfdf_string, length('<ORG-REC>'),'<ORG-REC>');
        	l_pg_count := l_pg_count + 1;
	    l_rep_date_label := '<REPORT-DATE-LABEL>' ||get_lookup_meaning('AE_FORM_LABELS','REPORT_DATE_LABEL')||'</REPORT-DATE-LABEL>';
	    l_rep_date := '<REPORT-DATE-VALUE>' ||fnd_date.date_to_displaydate(sysdate)||'</REPORT-DATE-VALUE>';
	    l_rep_page := '<PAGE>'||get_lookup_meaning('AE_FORM_LABELS','PAGE_NO_LABEL')||'</PAGE>';
	    l_page_num := '<CURRENT-VALUE>'||l_pg_count||'</CURRENT-VALUE>';
      	    l_rep_label := '<REPORT-LABEL>'||get_lookup_meaning('AE_FORM_LABELS','REPORT_LABEL_CTR')||'</REPORT-LABEL>';
            l_str_9b := '<ORG-NAME>'||get_lookup_meaning('AE_FORM_LABELS','ORGANIZATION_LABEL')||'</ORG-NAME>';
           -- l_str_8b := '<ORG-VALUE>'||rec_get_org_id.name||'</ORG-VALUE>';
            l_str_8b := '<ORG-VALUE>'||'<![CDATA['||rec_get_org_id.name||']]>'||'</ORG-VALUE>';
	    l_str_7b := '<EMPNO-L>'||get_lookup_meaning('AE_FORM_LABELS','EMPLOYEE_NUMBER_LABEL')||'</EMPNO-L>';
            l_str_6b := '<FULLNAME-L>'||get_lookup_meaning('AE_FORM_LABELS','FULL_NAME_LABEL')||'</FULLNAME-L>';
            l_str_5b := '<JOB-L>'||get_lookup_meaning('AE_FORM_LABELS','JOB_LABEL')||'</JOB-L>';
            l_str_4b := '<CONREF-L>'||get_lookup_meaning('AE_FORM_LABELS','CONTRACT_REFERENCE')||'</CONREF-L>';
            l_str_3b := '<CONTYPE-L>'||get_lookup_meaning('AE_FORM_LABELS','CONTRACT_TYPE')||'</CONTYPE-L>';
            l_str_2b := '<EMPSTATUS-L>'||get_lookup_meaning('AE_FORM_LABELS','EMPLOYMENT_STATUS')||'</EMPSTATUS-L>';
            l_str_1b := '<APPDATE-L>'||get_lookup_meaning('AE_FORM_LABELS','START_DATE_LABEL')||'</APPDATE-L>';
            l_str_0b := '<EXPDATE-L>'||get_lookup_meaning('AE_FORM_LABELS','EXPIRY_DATE')||'</EXPDATE-L>';
	    fnd_file.put_line(fnd_file.log,'Test1');

	    dbms_lob.writeAppend( l_xfdf_string, length(l_rep_date_label), l_rep_date_label);
	    dbms_lob.writeAppend( l_xfdf_string, length(l_rep_date), l_rep_date);
	    dbms_lob.writeAppend( l_xfdf_string, length(l_rep_page), l_rep_page);
	    dbms_lob.writeAppend( l_xfdf_string, length(l_page_num), l_page_num);
            dbms_lob.writeAppend( l_xfdf_string, length(l_rep_label), l_rep_label);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_9b), l_str_9b);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_8b), l_str_8b);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_7b), l_str_7b);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_6b), l_str_6b);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_5b), l_str_5b);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_4b), l_str_4b);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_3b), l_str_3b);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_2b), l_str_2b);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_1b), l_str_1b);
            dbms_lob.writeAppend( l_xfdf_string, length(l_str_0b), l_str_0b);
	    fnd_file.put_line(fnd_file.log,'Test2');
         /********* COMMENTED ON 3-NOV-05 FOR RTF FORMAT
	  gxmltable(gCtr).tagName := 'report_label';
          gxmltable(gCtr).tagValue := get_lookup_meaning('AE_FORM_LABELS','REPORT_LABEL_CTR');
          gctr := gctr + 1;
		etc. etc.
          END OF COMMENTED ON 3-NOV-05 FOR RTF FORMAT *******************/
          l_emp_found := 1;
        END IF;
        /*********** COMMENTED ON 3-NOV-05 FOR RTF FORMAT
	gxmltable(gCtr).tagName := 'employee_number_value'||' '||i;
        gxmltable(gCtr).tagValue := (rec_get_contract_det.employee_number);
        gctr := gctr + 1;
		etc. etc.
	END OF COMMENTED ON 3-NOV-05 FOR RTF FORMAT **************/
      	    l_eno := '<ENO-' || i || '>'||(rec_get_contract_det.employee_number)||'</ENO-' || i || '>';
            --l_fname := '<FNAME-' || i || '>'||substr((rec_get_contract_det.full_name),1,60)||'</FNAME-' || i || '>';
	    l_fname := '<FNAME-' || i || '>'||'<![CDATA['||substr((rec_get_contract_det.full_name),1,60)||']]>'||'</FNAME-' || i || '>';
            --l_job:= '<JOB-' || i || '>'|| (rec_get_contract_det.job_name)||'</JOB-' || i || '>';
	    l_job:= '<JOB-' || i || '>'|| '<![CDATA['||(rec_get_contract_det.job_name)||']]>'||'</JOB-' || i || '>';
            --l_ref := '<REF-' || i || '>'|| (rec_get_contract_det.cont_reference) ||'</REF-' || i || '>';
	    l_ref := '<REF-' || i || '>'||'<![CDATA['||(rec_get_contract_det.cont_reference)||']]>'  ||'</REF-' || i || '>';
            --l_type := '<TYPE-' || i || '>'|| (rec_get_contract_det.cont_type) ||'</TYPE-' || i || '>';
            l_type := '<TYPE-' || i || '>'||'<![CDATA['||(rec_get_contract_det.cont_type)||']]>'  ||'</TYPE-' || i || '>';
            l_status := '<STATUS-' || i || '>'|| (rec_get_contract_det.employment_status) ||'</STATUS-' || i || '>';
            l_appdate := '<APPDATE-' || i || '>'||fnd_date.date_to_displaydate(rec_get_contract_det.date_start)||'</APPDATE-' || i || '>';
            l_edate := '<EDATE-' || i || '>'|| fnd_date.date_to_displaydate(rec_get_contract_det.expiry_date) ||'</EDATE-' || i || '>';
            dbms_lob.writeAppend( l_xfdf_string, length(l_eno), l_eno);
            dbms_lob.writeAppend( l_xfdf_string, length(l_fname), l_fname);
            dbms_lob.writeAppend( l_xfdf_string, length(l_job), l_job);
            dbms_lob.writeAppend( l_xfdf_string, length(l_ref), l_ref);
            dbms_lob.writeAppend( l_xfdf_string, length(l_type), l_type);
            dbms_lob.writeAppend( l_xfdf_string, length(l_status), l_status);
            dbms_lob.writeAppend( l_xfdf_string, length(l_appdate), l_appdate);
            dbms_lob.writeAppend( l_xfdf_string, length(l_edate), l_edate);
        i := i + 1;
		IF i = 10 then
			dbms_lob.writeAppend( l_xfdf_string, length('</ORG-REC>'),'</ORG-REC>');
		END IF;
      END LOOP;
      CLOSE csr_get_contract_det;
      IF i < 9 AND l_emp_found = 1 THEN
        FOR j in i..9 LOOP
       	/******** COMMENTED ON 3-NOV-05 FOR RTF FORMAT
       	gxmltable(gCtr).tagName := 'employee_number_value'||' '||j;
        gxmltable(gCtr).tagValue := (null);
        gctr := gctr + 1;
	etc. etc.
        END OF COMMENTED ON 3-NOV-05 FOR RTF FORMAT *********/
      	    l_b_eno := '<ENO-' || j || '>'||null||'</ENO-' || j || '>';
            l_b_fname := '<FNAME-' || j || '>'|| null ||'</FNAME-' || j || '>';
            l_b_job:= '<JOB-' || j || '>'|| null||'</JOB-' || j || '>';
            l_b_ref := '<REF-' || j || '>'|| null ||'</REF-' || j || '>';
            l_b_type := '<TYPE-' || j || '>'|| null ||'</TYPE-' || j || '>';
            l_b_status := '<STATUS-' || j || '>'|| null ||'</STATUS-' || j || '>';
            l_b_appdate := '<APPDATE-' || j || '>'|| null ||'</APPDATE-' || j || '>';
            l_b_edate := '<EDATE-' || j || '>'|| null ||'</EDATE-' || j || '>';
            dbms_lob.writeAppend( l_xfdf_string, length(l_b_eno), l_b_eno);
            dbms_lob.writeAppend( l_xfdf_string, length(l_b_fname), l_b_fname);
            dbms_lob.writeAppend( l_xfdf_string, length(l_b_job), l_b_job);
            dbms_lob.writeAppend( l_xfdf_string, length(l_b_ref), l_b_ref);
            dbms_lob.writeAppend( l_xfdf_string, length(l_b_type), l_b_type);
            dbms_lob.writeAppend( l_xfdf_string, length(l_b_status), l_b_status);
            dbms_lob.writeAppend( l_xfdf_string, length(l_b_appdate), l_b_appdate);
            dbms_lob.writeAppend( l_xfdf_string, length(l_b_edate), l_b_edate);
       END LOOP;
dbms_lob.writeAppend( l_xfdf_string, length('</ORG-REC>'),'</ORG-REC>');
      END IF;
    END LOOP;
    CLOSE csr_get_org_id;
    END LOOP;
    CLOSE csr_get_bg_id;
     dbms_lob.writeAppend( l_xfdf_string, length('</START>'),'</START>');
        DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
        clob_to_blob(l_xfdf_string,l_xfdf_blob);
/*    WritetoCLOB ( l_xfdf_blob, l_pg_count );*/
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
	  /* Added new check for bug:6721310 */
	  l_str9 := '<![CDATA['||l_str9||']]>';
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
  -------------------------------------------------------------------------------------------
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
 fnd_file.put_line(fnd_file.log,l_varchar_buffer);
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
    IF (p_report='Visa') THEN
      SELECT file_data
      INTO   p_pdf_blob
      FROM   fnd_lobs
      WHERE  file_id = (SELECT MAX(file_id)
                       FROM    fnd_lobs
                       WHERE   file_name like '%PER_VIS_ar_AE.pdf');
    ELSIF (p_report='Passport') THEN
      SELECT file_data
      INTO   p_pdf_blob
      FROM   fnd_lobs
      WHERE  file_id = (SELECT MAX(file_id)
                       FROM    fnd_lobs
                       WHERE   file_name like '%PER_PASS_ar_AE.pdf');
      ELSE
      SELECT file_data
      INTO   p_pdf_blob
      FROM   fnd_lobs
      WHERE  file_id = (SELECT MAX(file_id)
                       FROM    fnd_lobs
                       WHERE   file_name like '%PER_CTR_ar_AE.rtf');
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
END per_ae_xdo_report;

/
