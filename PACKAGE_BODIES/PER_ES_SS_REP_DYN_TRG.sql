--------------------------------------------------------
--  DDL for Package Body PER_ES_SS_REP_DYN_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ES_SS_REP_DYN_TRG" AS
/* $Header: peesssdy.pkb 115.3 2004/03/16 23:12:42 srjanard noship $ */

-----------------------------------------------------
--GET_ASSIGNMENT_ID
-----------------------------------------------------
FUNCTION get_assignment_id(p_element_entry_id NUMBER) RETURN NUMBER IS
CURSOR  csr_find_asg_id IS
SELECT  assignment_id
FROM    pay_element_entries_f
WHERE   element_entry_id = p_element_entry_id;

l_assignment_id NUMBER;
BEGIN
    OPEN  csr_find_asg_id;
    FETCH csr_find_asg_id INTO l_assignment_id;
    CLOSE csr_find_asg_id;
    RETURN l_assignment_id;
END get_assignment_id;
-----------------------------------------------------------
--GET_BUSINESS_GROUP_ID
-----------------------------------------------------------
FUNCTION   get_business_group_id(p_element_entry_id NUMBER) RETURN NUMBER IS
CURSOR csr_find_business_grp_id IS
SELECT business_group_id
FROM   per_all_assignments_f paf
      ,pay_element_entries_f peef
WHERE  peef.element_entry_id = p_element_entry_id
AND    peef.assignment_id = paf.assignment_id;

l_business_group_id  NUMBER;
BEGIN
    OPEN csr_find_business_grp_id;
    FETCH csr_find_business_grp_id INTO l_business_group_id;
    CLOSE csr_find_business_grp_id;
    RETURN l_business_group_id;
END get_business_group_id;
--------------------------------------------------------------
--asg_check_update
--------------------------------------------------------------
PROCEDURE asg_check_update(p_assignment_id                            NUMBER,
                           p_assignment_type                          VARCHAR2,
                           p_effective_start_date                     DATE,
                           p_effective_end_date                       DATE,
                           p_asg_status_type_id                       NUMBER,
                           p_employment_category                      VARCHAR2,
     	                     p_soft_coding_keyflex_id                   NUMBER,
                           p_primary_flag                             VARCHAR) AS

CURSOR csr_asg_status IS
SELECT assignment_extra_info_id
      ,object_version_number
      ,aei_information2          last_reported_date
      ,aei_information3          event
      ,nvl(aei_information4,'X') value
      ,aei_information6          action_type
      ,aei_information7          first_change_date
FROM   per_assignment_extra_info
WHERE  assignment_id = p_assignment_id
AND    information_type = 'ES_SS_REP'
AND    aei_information5 <> 'Y';

CURSOR csr_find_contribution_code IS
SELECT sck.segment5
FROM   hr_soft_coding_keyflex sck
WHERE  sck.soft_coding_keyflex_id = p_soft_coding_keyflex_id;

CURSOR csr_asg_status_type IS
SELECT per_system_status
FROM   per_assignment_status_types
WHERE  assignment_status_type_id = p_asg_status_type_id;

l_ovn                  NUMBER;
l_contribution_code    VARCHAR2(60);
l_system_status        per_assignment_status_types.per_system_status%TYPE;

BEGIN
   IF p_assignment_type = 'E' AND p_primary_flag= 'Y' THEN

       OPEN  csr_find_contribution_code;
       FETCH csr_find_contribution_code INTO l_contribution_code;
       CLOSE csr_find_contribution_code;

       OPEN  csr_asg_status_type;
       FETCH csr_asg_status_type INTO l_system_status;
       CLOSE csr_asg_status_type;

   FOR csr_extra_info IN csr_asg_status
   LOOP
       -- Checking for Assignment Status Type ID
       IF (csr_extra_info.event = 'AS' AND csr_extra_info.value  <>  p_asg_status_type_id
                                       AND l_system_status = 'ACTIVE_ASSIGN') THEN
           IF p_effective_end_date >= fnd_date.canonical_to_date(csr_extra_info.last_reported_date) THEN
               UPDATE per_assignment_extra_info
               SET    aei_information5         = 'Y'
                     ,aei_information7         =  fnd_date.date_to_canonical(p_effective_start_date)
               WHERE  assignment_id            =  p_assignment_id
               AND    aei_information3         = 'AS'
               AND    aei_information_category = 'ES_SS_REP'
               AND    object_version_number    =  csr_extra_info.object_version_number;
           END IF;
       END IF;
       -- Checking for Termination Status Type ID
       IF (csr_extra_info.event = 'TS' AND csr_extra_info.value  <>  p_asg_status_type_id
                                       AND l_system_status = 'TERM_ASSIGN') THEN
           IF p_effective_end_date >= fnd_date.canonical_to_date(csr_extra_info.last_reported_date) THEN
               UPDATE per_assignment_extra_info
               SET    aei_information5           = 'Y'
                     ,aei_information7           =  fnd_date.date_to_canonical(p_effective_start_date-1)
		                 ,aei_information4           =  p_asg_status_type_id
               WHERE  assignment_id              =  p_assignment_id
               AND    aei_information3           = 'TS'
               AND    aei_information_category   = 'ES_SS_REP'
               AND    object_version_number      =  csr_extra_info.object_version_number;
           END IF;
       END IF;

       -- Checking for Employement Category
      /* IF (csr_extra_info.event = 'EC' AND csr_extra_info.value  <>  nvl(p_employment_category, 'X')) THEN
           IF  p_effective_end_date  >= fnd_date.canonical_to_date(csr_extra_info.last_reported_date) THEN
               UPDATE per_assignment_extra_info
               SET    aei_information5           = 'Y'
                     ,aei_information7           = fnd_date.date_to_canonical(p_effective_start_date)
               WHERE  assignment_id              = p_assignment_id
               AND    aei_information3           = 'EC'
               AND    aei_information_category   = 'ES_SS_REP'
               AND    object_version_number      = csr_extra_info.object_version_number;
           END IF;
       END IF;*/

       -- Checking for contribution group
       IF (csr_extra_info.event = 'CG' AND csr_extra_info.value  <>  nvl(l_contribution_code, 'X')) THEN
           IF p_effective_end_date >= fnd_date.canonical_to_date(csr_extra_info.last_reported_date) THEN
               UPDATE per_assignment_extra_info
               SET    aei_information5           = 'Y'
                     ,aei_information7           = fnd_date.date_to_canonical(p_effective_start_date)
               WHERE  assignment_id              = p_assignment_id
               AND    aei_information3           = 'CG'
               AND    aei_information_category   = 'ES_SS_REP'
               AND    object_version_number      = csr_extra_info.object_version_number;
           END IF;
       END IF;
   END LOOP;
END IF;
EXCEPTION
WHEN others THEN
  NULL;
END asg_check_update;
-----------------------------------------------------
--asg_check_insert
------------------------------------------------------
PROCEDURE asg_check_insert( p_assignment_id                           NUMBER,
                            p_assignment_type                         VARCHAR2,
                            p_effective_start_date                    DATE,
                            p_effective_end_date                      DATE,
                            p_asg_status_type_id                      NUMBER,
                            p_employment_category                     VARCHAR2,
 		                        p_soft_coding_keyflex_id                  NUMBER,
                            p_primary_flag                            VARCHAR) IS
CURSOR csr_check_asg IS
SELECT assignment_id
FROM   per_assignment_extra_info
WHERE  assignment_id  =  p_assignment_id;

l_ovn                  NUMBER;
l_csr_find_asg_id      per_all_assignments_f.assignment_id%TYPE;
BEGIN
    IF p_assignment_type  = 'E' AND p_primary_flag = 'Y' THEN
        /* Check whether there is any record in the table */
        OPEN csr_check_asg;
        FETCH csr_check_asg INTO l_csr_find_asg_id;
        IF csr_check_asg%FOUND THEN
            /* Call the update procedure to update the report type */
            asg_check_update(p_assignment_id,
                             p_assignment_type,
                             p_effective_start_date,
                             p_effective_end_date,
                             p_asg_status_type_id,
                             p_employment_category,
			                       p_soft_coding_keyflex_id,
                             p_primary_flag);
        ELSE
           /* Insert the records directly into the table because the api used to insert the values uses savepoint*/
           /* savepoint cannot be used in triggers */
           INSERT INTO per_assignment_extra_info
                    (assignment_extra_info_id,
	                   assignment_id,
	                   information_type,
	                   aei_information_category,
	                   aei_information2,
	                   aei_information3,
                     aei_information4,
	                   aei_information5,
	                   aei_information6,
	                   aei_information7,
                     object_version_number
                      )
           VALUES
                    (per_assignment_extra_info_s.nextval,
	                   p_assignment_id,
	                  'ES_SS_REP',
	                  'ES_SS_REP',
	                   fnd_date.date_to_canonical(P_EFFECTIVE_START_DATE),
	                  'AS',
	                   p_asg_status_type_id,
	                  'Y',
	                  'I',
	                   fnd_date.date_to_canonical(P_EFFECTIVE_START_DATE),
	                   1
                      );
           /* Inserting the Termination Status as One */
           INSERT INTO per_assignment_extra_info
                    (assignment_extra_info_id,
                     assignment_id,
                     information_type,
                     aei_information_category,
	                   aei_information2,
	                   aei_information3,
	                   aei_information4,
	                   aei_information5,
      	             aei_information6,
	                   aei_information7,
                     object_version_number
                      )
           VALUES
                    (per_assignment_extra_info_s.nextval,
	                   p_assignment_id,
	                  'ES_SS_REP',
           	        'ES_SS_REP',
	                   fnd_date.date_to_canonical(P_EFFECTIVE_START_DATE),
	                  'TS',
	                   p_asg_status_type_id,
	                  'N',
	                  'U',
	                   fnd_date.date_to_canonical(P_EFFECTIVE_START_DATE),
	                   1
                     );
          /* INSERT INTO per_assignment_extra_info
                   (assignment_extra_info_id,
	                  assignment_id,
	                  information_type,
	                  aei_information_category,
	                  aei_information2,
	                  aei_information3,
	                  aei_information4,
	                  aei_information5,
	                  aei_information6,
	                  aei_information7,
                    object_version_number
                   )
           VALUES
                  (per_assignment_extra_info_s.nextval,
 	                 p_assignment_id,
	                'ES_SS_REP',
 	                'ES_SS_REP',
	                 fnd_date.date_to_canonical(P_EFFECTIVE_START_DATE),
	                'EC',
	                 p_employment_category,
	                'Y',
	                'I',
	                 fnd_date.date_to_canonical(P_EFFECTIVE_START_DATE),
	                 1
                    );
           */
           INSERT INTO per_assignment_extra_info
                  (assignment_extra_info_id,
	                 assignment_id,
	                 information_type,
	                 aei_information_category,
	                 aei_information2,
	                 aei_information3,
	                 aei_information4,
	                 aei_information5,
	                 aei_information6,
	                 aei_information7,
                   object_version_number
                    )
           VALUES
                 (per_assignment_extra_info_s.nextval,
	                p_assignment_id,
	               'ES_SS_REP',
	               'ES_SS_REP',
	                fnd_date.date_to_canonical(P_EFFECTIVE_START_DATE),
	               'CG',
	                NULL,
	               'Y',
	               'I',
	                fnd_date.date_to_canonical(P_EFFECTIVE_START_DATE),
	                1
                  );
       END IF;
       CLOSE csr_check_asg;
   END IF;
EXCEPTION
WHEN OTHERS THEN
NULL;
END asg_check_insert;
----------------------------------------------------------------
--ELEMENT_CHECK_INSERT
----------------------------------------------------------------
PROCEDURE element_check_insert(p_element_entry_id         NUMBER,
                               p_effective_start_date     DATE,
                               p_effective_end_date       DATE,
                               p_epigraph_code            VARCHAR2,
                               p_input_value_id           NUMBER) AS

CURSOR  csr_chk_element_eit(p_assignment_id NUMBER) IS
SELECT  assignment_extra_info_id
FROM    per_assignment_extra_info
WHERE   assignment_id    = p_assignment_id
AND     information_type = 'ES_SS_REP'
AND     aei_information3 IN ('EP','EC');

CURSOR csr_input_value_id(p_name VARCHAR2) IS
SELECT input_value_id
FROM   pay_input_values_f piv
WHERE  piv.name         = p_name
AND    legislation_code = 'ES';

CURSOR csr_primary_flag_value(p_assignment_id NUMBER
                             ,p_effective_start_date DATE) IS
SELECT paf.primary_flag, paf.assignment_type
FROM   per_all_assignments_f paf
WHERE  paf.assignment_id = p_assignment_id
AND    p_effective_start_date BETWEEN paf.effective_start_date
                              AND     paf.effective_end_date;

l_assg_id              pay_element_entries_f.assignment_id%TYPE;
l_assg_info_id         per_assignment_extra_info.assignment_extra_info_id%TYPE;
l_input_value_id       pay_input_values_f.input_value_id%TYPE;
l_primary_flag         per_all_assignments_f.primary_flag%TYPE;
l_assignment_type      per_all_assignments_f.assignment_type%TYPE;

BEGIN
OPEN csr_input_value_id('SS Epigraph Code');
FETCH csr_input_value_id INTO l_input_value_id;
CLOSE csr_input_value_id;

IF p_input_value_id = l_input_value_id  THEN
    l_assg_id := PER_ES_SS_REP_DYN_TRG.get_assignment_id(p_element_entry_id);
    OPEN csr_primary_flag_value(l_assg_id,p_effective_start_date);
    FETCH csr_primary_flag_value INTO l_primary_flag,l_assignment_type ;
    CLOSE csr_primary_flag_value;
    IF l_assignment_type = 'E' AND l_primary_flag = 'Y' THEN
        OPEN csr_chk_element_eit(l_assg_id);
        FETCH csr_chk_element_eit INTO l_assg_info_id;
        IF csr_chk_element_eit%FOUND THEN
            element_check_update(p_element_entry_id,
                                 p_effective_start_date,
                                 p_effective_end_date,
                                 p_epigraph_code,
                                 p_input_value_id);
        ELSE
           /*inserting for EPIGRAPH CODE EP*/
            INSERT INTO per_assignment_extra_info
                    (assignment_extra_info_id,
  	                 assignment_id,
	                   information_type,
                     aei_information_category,
                     aei_information2,
                     aei_information3,
                     aei_information4,
	                   aei_information5,
                     aei_information6,
                     aei_information7,
                     object_version_number
                    )
            VALUES
                   (per_assignment_extra_info_s.nextval,
                    l_assg_id,
                   'ES_SS_REP',
                   'ES_SS_REP',
  	                fnd_date.date_to_canonical(P_EFFECTIVE_START_DATE),
  	               'EP',
	                  NULL,
	                 'Y',
	                 'I',
	                  fnd_date.date_to_canonical(P_EFFECTIVE_START_DATE),
	                  1
                    );
           /*Inserting for contract key change*/
            INSERT INTO per_assignment_extra_info
                    (assignment_extra_info_id,
  	                 assignment_id,
	                   information_type,
                     aei_information_category,
                     aei_information2,
                     aei_information3,
                     aei_information4,
	                   aei_information5,
                     aei_information6,
                     aei_information7,
                     object_version_number
                    )
            VALUES
                   (per_assignment_extra_info_s.nextval,
                    l_assg_id,
                   'ES_SS_REP',
                   'ES_SS_REP',
  	                fnd_date.date_to_canonical(P_EFFECTIVE_START_DATE),
  	               'EC',
	                  NULL,
	                 'Y',
	                 'I',
	                  fnd_date.date_to_canonical(P_EFFECTIVE_START_DATE),
	                  1
                    );
        END IF;
       CLOSE csr_chk_element_eit;
    END IF;
END IF;
END element_check_insert;
-----------------------------------------------------------------
--ELEMENT_CHECK_UPDATE
------------------------------------------------------------------
PROCEDURE  element_check_update(p_element_entry_id            NUMBER,
                                p_effective_start_date        DATE,
                                p_effective_end_date          DATE,
                                p_epigraph_code               VARCHAR2,
                                p_input_value_id              NUMBER) AS

CURSOR  csr_get_eit_value(p_assignment_id NUMBER
                         ,p_event_type    VARCHAR2) IS
SELECT  assignment_extra_info_id
       ,object_version_number
       ,aei_information2          last_reported_date
       ,nvl(aei_information4,'X') value
	     ,aei_information6          action_type
	     ,aei_information7          last_changed_date
FROM   per_assignment_extra_info
WHERE  assignment_id     =   p_assignment_id
AND    information_type  =  'ES_SS_REP'
AND    aei_information3  =   p_event_type
AND    aei_information5  <> 'Y';

CURSOR csr_input_value_id(p_name VARCHAR2) IS
SELECT input_value_id
FROM   pay_input_values_f piv
WHERE  piv.name         = p_name
AND    legislation_code = 'ES';

CURSOR csr_primary_flag_value(p_assignment_id NUMBER
                             ,p_effective_start_date DATE) IS
SELECT paf.primary_flag, paf.assignment_type
FROM   per_all_assignments_f paf
WHERE  paf.assignment_id = p_assignment_id
AND    p_effective_start_date BETWEEN paf.effective_start_date
                              AND     paf.effective_end_date;

l_assignment_id        pay_element_entries_f.assignment_id%type;
l_input_value_id       pay_input_values_f.input_value_id%type;
l_primary_flag         per_all_assignments_f.primary_flag%TYPE;
l_assignment_type      per_all_assignments_f.assignment_type%TYPE;

BEGIN
    OPEN csr_input_value_id('SS Epigraph Code');
    FETCH csr_input_value_id INTO l_input_value_id;
    CLOSE csr_input_value_id;
    IF p_input_value_id = l_input_value_id THEN
        l_assignment_id := PER_ES_SS_REP_DYN_TRG.get_assignment_id(P_ELEMENT_ENTRY_ID);
        OPEN csr_primary_flag_value(l_assignment_id,p_effective_start_date);
        FETCH csr_primary_flag_value INTO l_primary_flag,l_assignment_type ;
        CLOSE csr_primary_flag_value;
        IF l_assignment_type = 'E' AND l_primary_flag = 'Y' THEN
            FOR csr_extra_info IN csr_get_eit_value(l_assignment_id,'EP')
            LOOP
                IF csr_extra_info.value <> p_epigraph_code THEN
                     IF p_effective_end_date >= fnd_date.canonical_to_date(csr_extra_info.last_reported_date) THEN
                         UPDATE per_assignment_extra_info
		                 SET    aei_information5         = 'Y'
			                     ,aei_information7         = fnd_date.date_to_canonical(p_effective_start_date)
		                 WHERE  assignment_id            = l_assignment_id
		                 AND    aei_information_category = 'ES_SS_REP'
		                 AND    aei_information3         = 'EP'
		                 AND    object_version_number    = csr_extra_info.object_version_number;
                     END IF;
	            END IF;
            END LOOP;
        END IF;
    END IF;
    --
    OPEN csr_input_value_id('Contract Key');
    FETCH csr_input_value_id INTO l_input_value_id;
    CLOSE csr_input_value_id;
    IF p_input_value_id = l_input_value_id THEN
        l_assignment_id := PER_ES_SS_REP_DYN_TRG.get_assignment_id(P_ELEMENT_ENTRY_ID);
        OPEN csr_primary_flag_value(l_assignment_id,p_effective_start_date);
        FETCH csr_primary_flag_value INTO l_primary_flag,l_assignment_type ;
        CLOSE csr_primary_flag_value;
        IF l_assignment_type = 'E' AND l_primary_flag = 'Y' THEN
            FOR csr_extra_info IN csr_get_eit_value(l_assignment_id,'EC')
            LOOP
                IF csr_extra_info.value <> p_epigraph_code THEN
                    IF p_effective_end_date >= fnd_date.canonical_to_date(csr_extra_info.last_reported_date) THEN
                        UPDATE per_assignment_extra_info
		                SET    aei_information5         = 'Y'
			                    ,aei_information7         = fnd_date.date_to_canonical(p_effective_start_date)
		                WHERE  assignment_id            = l_assignment_id
		                AND    aei_information_category = 'ES_SS_REP'
		                AND    aei_information3         = 'EC'
		                AND    object_version_number    = csr_extra_info.object_version_number;
                    END IF;
	            END IF;
            END LOOP;
        END IF;
    END IF;
END element_check_update;
END PER_ES_SS_REP_DYN_TRG;

/
