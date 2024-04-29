--------------------------------------------------------
--  DDL for Package PER_US_VETS_TAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_VETS_TAP" AUTHID CURRENT_USER AS
/* $Header: petapvts.pkh 120.0 2005/05/31 22:12:57 appldev noship $ */
/*
 * **************************************************************************
*

  Copyright (c) Oracle Corporation (UK) Ltd 1993.
  All Rights Reserved.

  PRODUCT
    Oracle Human Resources

  NAME


  DESCRIPTION
    Magnetic tape format procedure.

1.0 Overview

  A PL/SQL package will be written for each type of magnetic tape. The packag
e
  will include all cursors and procedures required for the particular magneti
c
  tape format. A stored procedure provides the top level of control flow for
  the magnetic tape file generation. This may call other procedures dependant

  on the state of the cursors and the input parameters.

  The stored procedure will be called before each execution of a
  formula. Parameters returned as results of the previous formula execution
  will be passed to the procedure. The procedure must handle all context
  cursors needed and may also set parameters required by the formula.

  Using NACHA as an example, for the file header record formula, a call
  to a cursor which fetches legal_company_id must be performed.

  The interface between the 'C' process and the stored procedure will make
  extensive use of PL/SQL tables. PL/SQL tables are single column tables whic
h
  are accessed by an integer index value. Items in the tables will use indexe
s
  begining with 1 and increasing contiguously to the number of elements. The
  index number will be used to match items in the name and value tables.

  The first element in the value tables will always be the number of elements
  available in the table. The elements in the tables will be of type VARCHAR2
  any conversion necessary should be performed within the PL/SQL procedure.

  The parameters returned by formula execution will be passed
  to the stored procedure. Parameters may or may not be altered by the PL/SQL
  procedure and will be passed back to the formula for the next execution.
  Context tables will always be reset by the PL/SQL procedure.

  The names of the tables used to interface with the PL/SQL procedure are
       param_names     type IN/OUT
       param_values    type IN/OUT
       context_names   type OUT
       context_values  type OUT

  The second item in the output_parameter_value table will be the formula ID
  of the next formula to be executed (the first item is the number of values
  in the table).

    Change List
    -----------
    Date        Name      Vers    Bug No     Description
    ----        ----      ----    ------     -----------
    18-AUG-98   ASAHAY    110.0              Created.
    18-SEP-00   ASAHAY    110.2              added cursor for min count
    20-SEP-00   ASAHAY    110.3              Commented check for GRE
					     in VETS count
    28-SEP-00   ASAHAY    110.4              Corrected Date format
    18-SEP-02   GPERRY    115.7              Fixed WWBUG 2529757
                                             Convert to use generic hierarchy

  Package header:
*/
-- Cursors



LEVEL_CNT NUMBER;

    CURSOR S_VETS_GRE IS
	select 	'TRANSFER_TAX_UNIT_ID=P',
		 pgn.entity_id,
		'TRANSFER_ESTABLISHMENT_ID1=P',
		 pgn.entity_id
	FROM    per_gen_hierarchy_versions pgv,
        per_gen_hierarchy_nodes pgn
where   pgv.hierarchy_version_id =
 	pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
AND     pgv.hierarchy_version_id = pgn.hierarchy_version_id
and     pgn.node_type = 'PAR';
--
CURSOR S_VETS_RE IS
SELECT  'TRANSFER_ESTABLISHMENT_ID=P',
		pghn.entity_id,
	'TRANSFER_VETS100_COMPANY_NUMBER=P',
		hoi1.org_information2,
	'TRANSFER_TYPE_OF_ORG=P',
		hoi1.org_information1,
        'TRANSFER_VETS100_UNIT_NUMBER=P',
		hlei1.lei_information2,
        'TRANSFER_SIC=P',
		hlei2.lei_information3 ,
        'TRANSFER_HQ_VETS100_REPORTING_NAME=P',
		upper(nvl(hoi1.org_information1, hou.name)),
       	'TRANSFER_EST_VETS100_REPORTING_NAME=P',
		upper(nvl(hlei2.lei_information1, hou.name))   ,
        'TRANSFER_HQLOC_ADDRESS=P',
		upper(rpad(cloc.address_line_1 ||' '|| cloc.address_line_2 ||' '|| cloc.address_line_3,35)),
        'TRANSFER_ELOC_ADDRESS=P',
		upper(rpad(eloc.address_line_1 ||' '|| eloc.address_line_2 ||' '|| eloc.address_line_3,35))  ,
        'TRANSFER_HQLOC_TOWN_OR_CITY=P',
		upper(cloc.town_or_city),
        'TRANSFER_HQLOC_REGION_1=P',
		upper(cloc.region_1) ,
        'TRANSFER_ELOC_TOWN_OR_CITY=P',
		upper(eloc.town_or_city),
        'TRANSFER_ELOC_REGION_1=P',
		upper(eloc.region_1),
        'TRANSFER_HQLOC_REGION_2=P',
		upper(cloc.region_2) ,
        'TRANSFER_HQLOC_POSTAL_CODE=P',
		upper(cloc.postal_code),
        'TRANSFER_ELOC_REGION_2=P',
		upper(eloc.region_2) ,
        'TRANSFER_ELOC_POSTAL_CODE=P',
		upper(eloc.postal_code),
        'TRANSFER_HQ_ORAGANIZATION_ID=P',
		hou.organization_id -- for debug
	,'TRANSFER_DUN=P',
	hoi2.org_information4,
	'TRANSFER_EIN=P',
	hoi3.org_information1
from
   hr_location_extra_info          hlei1
  ,hr_location_extra_info          hlei2
  ,per_gen_hierarchy_nodes         pghn
  ,per_gen_hierarchy_nodes         pgn
  ,hr_locations_all                eloc
  ,hr_organization_units           hou
  ,hr_organization_information     hoi1
  ,hr_organization_information     hoi2
  ,hr_organization_information     hoi3
  ,hr_locations_all                cloc
where pgn.hierarchy_version_id = pghn.hierarchy_version_id
and pgn.node_type = 'PAR'
and pgn.entity_id = hou.organization_id
and hoi1.org_information_context  = 'VETS_Spec'
and hoi1.organization_id = hou.organization_id
and hoi2.org_information_context  = 'VETS_EEO_Dup'
and hoi2.organization_id = hou.organization_id
and hoi3.org_information_context  = 'Employer Identification'
and hoi3.organization_id = hou.organization_id
and hou.location_id(+)= cloc.location_id
and pghn.hierarchy_version_id = pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
and pghn.node_type = 'EST'
and eloc.location_id = pghn.entity_id
and hlei1.location_id = pghn.entity_id
and hlei1.location_id = hlei2.location_id
and hlei1.information_type = 'VETS-100 Specific Information'
and hlei1.lei_information_category= 'VETS-100 Specific Information'
and hlei2.information_type = 'Establishment Information'
and hlei2.lei_information_category= 'Establishment Information';


CURSOR S_VETS_JOBS IS
SELECT  'TRANSFER_JOB_CATEGORY_NAME=P',
	upper(rpad(meaning,32,'.'))|| lookup_code,
	'TRANSFER_JOB_CATEGORY_CODE=P',
	lookup_code
FROM    hr_lookups
WHERE   lookup_type = 'US_EEO1_JOB_CATEGORIES'
ORDER BY lookup_code ;


CURSOR S_VETS_VETS IS
SELECT 	'TRANSFER_NO_DIS_VETS=P',
	nvl(count(decode(peo.per_information5,'VETDIS',1,'VIETVETDIS',1,'OTEDV',1,'DVOEV',1,'NSDIS',1,'NSDISOP',1,'VIETDISNS',1,'VIETDISNSOP',1,null)),0) ,
       	'TRANSFER_NO_VIET_VETS=P',
	nvl(count(decode(peo.per_information5,'VIETVET',1,'VIETVETDIS',1,'DVOEV',1,'VOEVV',1,'VIETNS',1,'VIETDISNS',1,'VIETNSOP',1,'VIETDISNSOP',1,null)),0) ,
       	'TRANSFER_NO_EMPS=P',
	nvl(count(peo.person_id),0),
        'TRANSFER_NO_OT_EV=P',
nvl(count(decode(peo.per_information5,'OTEV',1,'OTEDV',1,'DVOEV',1,'VOEVV',1,'NSOP',1,'NSDISOP',1,'VIETNSOP',1,'VIETDISNSOP',1,null)),0)
FROM    per_periods_of_service          pds,
        per_people_f			peo,
        per_assignments_f              	ass,
        hr_organization_information  	hoi1,
        hr_organization_information 	hoi2,
        per_jobs                       	job
WHERE   (pds.date_start <= to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
and nvl(pds.actual_termination_date,to_date('31-12-4712','DD-MM-YYYY')) >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
or   pds.date_start between to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
and   to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
and to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
between pds.date_start
and nvl(pds.actual_termination_date,to_date('31-12-4712','DD-MM-YYYY')))
and     pds.person_id = ass.person_id
and     peo.person_id = ass.person_id
AND     job.job_information_category    = 'US'
AND     job.date_from <=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     nvl(job.date_to, to_date('31-12-4712', 'DD-MM-YYYY'))   >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
AND     job.job_information1            =
	pay_magtape_generic.get_parameter_value('TRANSFER_JOB_CATEGORY_CODE')
AND     ass.job_id                      = job.job_id
AND     peo.effective_start_date        <=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     peo.effective_end_date          >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     peo.current_employee_flag        = 'Y'
AND     ass.assignment_type             = 'E'
AND     ass.primary_flag                = 'Y'
AND     ass.effective_start_date = (select max(paf2.effective_start_date)
                                    from per_assignments_f paf2
                                    where paf2.person_id = ass.person_id
                                    and paf2.primary_flag = 'Y'
                                    and paf2.assignment_type = 'E'
                                    and paf2.effective_start_date <=
                                    to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS'))
AND     to_char(ass.assignment_status_type_id) = hoi1.org_information1
AND     hoi1.org_information_context    = 'Reporting Statuses'
AND     hoi1.organization_id            =
	pay_magtape_generic.get_parameter_value('TRANSFER_BG_ID')
AND     ass.employment_category         = hoi2.org_information1
AND     hoi2.organization_id            =
	pay_magtape_generic.get_parameter_value('TRANSFER_BG_ID')
AND     hoi2.org_information_context    = 'Reporting Categories'
AND     ass.effective_start_date        <=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.effective_end_date          >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.location_id in
(select entity_id
from  per_gen_hierarchy_nodes
where node_type = 'EST'
and   entity_id = pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
and hierarchy_version_id = pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
union
select pghn2.entity_id
from   per_gen_hierarchy_nodes pghn,
       per_gen_hierarchy_nodes pghn2
where  pghn.entity_id = pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
and pghn.hierarchy_version_id = pghn2.hierarchy_version_id
and pghn2.parent_hierarchy_node_id = pghn.hierarchy_node_id
and pghn2.node_type = 'LOC'
and pghn.node_type = 'EST'
and pghn.hierarchy_version_id = pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID'))
;


CURSOR 	S_VETS_VETS_NH IS
SELECT  'TRANSFER_TOT_NEW_HIRES=P',
	nvl(count(peo.person_id),0) ,
        'TRANSFER_NO_NH_DIS_VETS=P',
	nvl(count(decode(peo.per_information5,'VETDIS',1,'VIETVETDIS',1,'OTEDV',1,'DVOEV',1,'NSDIS',1,'NSDISOP',1,'VIETDISNS',1,'VIETDISNSOP',1,null)),0) ,
        'TRANSFER_NO_NH_VIET_VETS=P',
	nvl(count(decode(peo.per_information5,'VIETVET',1,'VIETVETDIS',1,'DVOEV',1,'VOEVV',1,'VIETNS',1,'VIETDISNS',1,'VIETNSOP',1,'VIETDISNSOP',1,null)),0),
        'TRANSFER_NO_NH_OT_EV=P',
nvl(count(decode(peo.per_information5,'OTEV',1,'OTEDV',1,'DVOEV',1,'VOEVV',1,'NSOP',1,'NSDISOP',1,'VIETNSOP',1,'VIETDISNSOP',1,null)),0),
        'TRANSFER_NO_NH_SEP_VETS=P',
nvl(count(decode(peo.per_information5,'NS',1,'NSDIS',1,'NSOP',1,'NSDISOP',1,'VIETNS',1,'VIETDISNS',1,'VIETNSOP',1,'VIETDISNSOP',1,null)),0)
FROM    per_people_f                    peo,
        per_assignments_f               ass,
        hr_organization_information     hoi1,
        hr_organization_information     hoi2,
        per_periods_of_service          pds,
        per_jobs                        job
WHERE   peo.person_id                   = ass.person_id
and   pds.date_start between to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
and   to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
and to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
between pds.date_start
and nvl(pds.actual_termination_date,to_date('31-12-4712','DD-MM-YYYY'))
and     pds.person_id = peo.person_id
AND     job.job_information_category    = 'US'
AND     job.date_from                   <=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     nvl(job.date_to, to_date('31-12-4712', 'DD-MM-YYYY'))   >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
AND     job.job_information1            =
	pay_magtape_generic.get_parameter_value('TRANSFER_JOB_CATEGORY_CODE')
AND     ass.job_id                      = job.job_id
AND     peo.effective_start_date        <=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     peo.effective_end_date          >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND    peo.current_employee_flag        = 'Y'
AND     ass.assignment_type             = 'E'
AND     ass.primary_flag                = 'Y'
AND     ass.effective_start_date = (select max(paf2.effective_start_date)
                                    from per_assignments_f paf2
                                    where paf2.person_id = ass.person_id
                                    and paf2.primary_flag = 'Y'
                                    and paf2.assignment_type = 'E'
                                    and paf2.effective_start_date <=
                                    to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS'))
AND     to_char(ass.assignment_status_type_id)   = hoi1.org_information1
AND     hoi1.org_information_context    = 'Reporting Statuses'
AND     hoi1.organization_id            =
	pay_magtape_generic.get_parameter_value('TRANSFER_BG_ID')
AND     ass.employment_category         = hoi2.org_information1
AND     hoi2.org_information_context    = 'Reporting Categories'
AND     hoi2.organization_id            =
	pay_magtape_generic.get_parameter_value('TRANSFER_BG_ID')
AND    ass.effective_start_date        <=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.effective_end_date          >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.location_id in
(select entity_id
from  per_gen_hierarchy_nodes
where node_type = 'EST'
and   entity_id = pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
and hierarchy_version_id = pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
union
select pghn2.entity_id
from   per_gen_hierarchy_nodes pghn,
       per_gen_hierarchy_nodes pghn2
where  pghn.entity_id = pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
and pghn.hierarchy_version_id = pghn2.hierarchy_version_id
and pghn2.parent_hierarchy_node_id = pghn.hierarchy_node_id
and pghn2.node_type = 'LOC'
and pghn.node_type = 'EST'
and pghn.hierarchy_version_id = pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID'))
;


/*	Count employee assignments. We use this to determine company size and
	so distinguish between those companies with 50 or more employees.  */

cursor S_VETS_ASG_COUNT is
SELECT	'TRANSFER_COUNT_ASSIGNMENTS=P',
	count(ass.assignment_id)
FROM    per_assignments_f            ass,
        hr_organization_information  hoi1,
--         hr_organization_information  hoi2,
        per_jobs                     job
WHERE   job.job_information_category   	= 'US'
AND     job.date_from <=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     nvl(job.date_to, to_date('4712/12/31', 'YYYY/MM/DD'))   >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
AND     job.job_information1           is not null
AND     ass.job_id                     	= job.job_id
AND     ass.business_group_id +0		=
	pay_magtape_generic.get_parameter_value('TRANSFER_BG_ID')
AND     ass.assignment_type = 'E'
AND     ass.primary_flag = 'Y'
AND     to_char(ass.assignment_status_type_id) = hoi1.org_information1
AND     hoi1.org_information_context   	= 'Reporting Statuses'
AND     hoi1.organization_id           	=
 	pay_magtape_generic.get_parameter_value('TRANSFER_BG_ID')
AND     ass.effective_start_date        <=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.effective_end_date          >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.location_id IN
(select entity_id
from  per_gen_hierarchy_nodes
where node_type = 'EST'
and   entity_id = pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
and hierarchy_version_id = pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
union
select pghn2.entity_id
from   per_gen_hierarchy_nodes pghn,
       per_gen_hierarchy_nodes pghn2
where  pghn.entity_id = pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
and pghn.hierarchy_version_id = pghn2.hierarchy_version_id
and pghn2.parent_hierarchy_node_id = pghn.hierarchy_node_id
and pghn2.node_type = 'LOC'
and pghn.node_type = 'EST'
and pghn.hierarchy_version_id = pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID'))
;

cursor S_VETS_MIN_COUNT is
SELECT	'TRANSFER_MIN_COUNT_ASSIGNMENTS=P',
	count (distinct pds.person_id)
FROM 	per_periods_of_service		pds,
	per_assignments_f		ass,
        hr_organization_information     hoi1,
        hr_organization_information     hoi2,
	per_jobs			job
WHERE 	pds.date_start <=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
AND     (nvl(pds.actual_termination_date,
	to_date('12/31/4712','MM/DD/YYYY')) >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS'))
AND     pds.person_id 		= ass.person_id
AND     ass.assignment_type	= 'E'
AND     ass.primary_flag	= 'Y'
AND     ass.business_group_id 	=
	pay_magtape_generic.get_parameter_value('TRANSFER_BG_ID')
AND    	ass.effective_start_date <
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
	and ass.effective_end_date >
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
AND    	ass.job_id = job.job_id
AND    	job.job_information_category = 'US'
AND    	job.date_from 		<=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_END'),'YYYY/MM/DD HH24:MI:SS')
AND   	nvl(job.date_to,to_date('31/12/4712','DD/MM/YYYY')) >=
to_date(pay_magtape_generic.get_parameter_value('TRANSFER_DATE_START'),'YYYY/MM/DD HH24:MI:SS')
AND     ass.location_id IN
(select entity_id
from  per_gen_hierarchy_nodes
where node_type = 'EST'
and   entity_id = pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
and hierarchy_version_id = pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID')
union
select pghn2.entity_id
from   per_gen_hierarchy_nodes pghn,
       per_gen_hierarchy_nodes pghn2
where  pghn.entity_id = pay_magtape_generic.get_parameter_value('TRANSFER_ESTABLISHMENT_ID')
and pghn.hierarchy_version_id = pghn2.hierarchy_version_id
and pghn2.parent_hierarchy_node_id = pghn.hierarchy_node_id
and pghn2.node_type = 'LOC'
and pghn.node_type = 'EST'
and pghn.hierarchy_version_id = pay_magtape_generic.get_parameter_value('TRANSFER_ORG_STR_V_ID'))
;

END per_us_vets_tap;

 

/
